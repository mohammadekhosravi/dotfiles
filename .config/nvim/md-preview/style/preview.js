/* Preview settings toolbar, contents panel and live reload.
   The saved defaults live in md-preview/settings.json (see server.mjs), so
   every preview — each on its own port, which is a separate browser origin —
   opens with the same settings. "Save as default" writes that file. */
(() => {
  const config = window.PREVIEW_CONFIG;
  const content = document.getElementById('content');
  const toc = document.getElementById('toc');
  const panel = document.getElementById('panel');
  const fab = document.getElementById('fab');
  const themeSelect = document.getElementById('theme');
  const tocToggle = document.getElementById('toc-toggle');
  const hljsLink = document.getElementById('hljs-theme');
  const resetButton = document.getElementById('reset');
  const saveButton = document.getElementById('save');
  const status = document.getElementById('status');
  const hint = status.textContent;
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');

  let settings = { ...config.defaults };
  let statusTimer;

  function sizeInPx() {
    return Math.round(16 * config.scales[settings.scale]) + 'px';
  }

  function effectiveTheme() {
    if (settings.theme !== 'system') {
      return settings.theme;
    }
    return prefersDark.matches ? 'github-dark' : 'github-light';
  }

  function syncButtons() {
    for (const button of panel.querySelectorAll('[data-width]')) {
      button.setAttribute('aria-pressed', String(button.dataset.width === settings.width));
    }
    for (const button of panel.querySelectorAll('[data-font]')) {
      button.setAttribute('aria-pressed', String(button.dataset.font === settings.font));
    }
    tocToggle.setAttribute('aria-pressed', String(settings.toc));
    tocToggle.textContent = settings.toc ? 'Hide' : 'Show';
    toc.hidden = !settings.toc || toc.childElementCount === 0;
  }

  function applySettings() {
    const key = effectiveTheme();
    const theme = config.themes.find((entry) => entry.key === key);
    const root = document.documentElement;
    root.dataset.theme = key;
    root.dataset.width = settings.width;
    root.dataset.font = settings.font;
    root.dataset.toc = settings.toc ? 'on' : 'off';
    root.style.fontSize = sizeInPx();
    root.style.setProperty('--preview-font-size', sizeInPx());
    if (theme) {
      hljsLink.href = '/style/hljs/' + theme.hljs;
    }
    themeSelect.value = settings.theme;
    syncButtons();
  }

  function buildToc() {
    toc.textContent = '';
    for (const heading of content.querySelectorAll('h2, h3')) {
      if (!heading.id) {
        continue;
      }
      const link = document.createElement('a');
      link.href = '#' + heading.id;
      link.textContent = heading.textContent;
      link.className = heading.tagName === 'H3' ? 'toc-h3' : 'toc-h2';
      toc.append(link);
    }
    syncButtons();
  }

  function setStatus(message) {
    status.textContent = message;
    clearTimeout(statusTimer);
    statusTimer = setTimeout(() => {
      status.textContent = hint;
    }, 2500);
  }

  function update(mutate) {
    mutate(settings);
    applySettings();
  }

  function setScale(index) {
    const last = config.scales.length - 1;
    update((value) => {
      value.scale = Math.min(last, Math.max(0, index));
    });
  }

  function cycleTheme() {
    const keys = ['system', ...config.themes.map((theme) => theme.key)];
    const index = keys.indexOf(settings.theme);
    update((value) => {
      value.theme = keys[(index + 1) % keys.length];
    });
  }

  function toggleContents() {
    update((value) => {
      value.toc = !value.toc;
    });
  }

  function togglePanel(open) {
    const next = typeof open === 'boolean' ? open : panel.hidden;
    panel.hidden = !next;
    fab.setAttribute('aria-expanded', String(next));
  }

  async function saveAsDefault() {
    try {
      const response = await fetch('/settings', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify(settings),
      });
      if (!response.ok) {
        throw new Error('save failed with status ' + response.status);
      }
      config.defaults = { ...settings };
      setStatus('Saved as default');
    } catch (error) {
      setStatus('Could not save');
    }
  }

  panel.addEventListener('click', (event) => {
    const button = event.target instanceof Element ? event.target.closest('button') : null;
    if (!button) {
      return;
    }
    if (button.dataset.size === '-1') {
      setScale(settings.scale - 1);
    } else if (button.dataset.size === '1') {
      setScale(settings.scale + 1);
    } else if (button.dataset.width) {
      update((value) => {
        value.width = button.dataset.width;
      });
    } else if (button.dataset.font) {
      update((value) => {
        value.font = button.dataset.font;
      });
    } else if (button === tocToggle) {
      toggleContents();
    } else if (button === resetButton) {
      settings = { ...config.defaults };
      applySettings();
      setStatus('Reset to the saved defaults');
    } else if (button === saveButton) {
      saveAsDefault();
    }
  });

  themeSelect.addEventListener('change', () => {
    update((value) => {
      value.theme = themeSelect.value;
    });
  });

  fab.addEventListener('click', () => togglePanel());

  document.addEventListener('click', (event) => {
    const target = event.target;
    if (target instanceof Node && !panel.contains(target) && target !== fab) {
      togglePanel(false);
    }
  });

  // Alt combinations, because plain letters clash with vim-style browser
  // extensions (Vimium's "t" opens a new tab). Capture phase so the page sees
  // the key before the browser or an extension does.
  window.addEventListener(
    'keydown',
    (event) => {
      if (event.key === 'Escape') {
        togglePanel(false);
        return;
      }
      if (!event.altKey) {
        return;
      }
      const target = event.target;
      if (target instanceof Element && target.closest('input, select, textarea')) {
        return;
      }
      const key = event.key.toLowerCase();
      if (key === 't') {
        cycleTheme();
      } else if (key === 'c') {
        toggleContents();
      } else if (event.key === '+' || event.key === '=') {
        setScale(settings.scale + 1);
      } else if (event.key === '-' || event.key === '_') {
        setScale(settings.scale - 1);
      } else {
        return;
      }
      event.preventDefault();
      event.stopPropagation();
    },
    true
  );

  prefersDark.addEventListener('change', () => {
    if (settings.theme === 'system') {
      applySettings();
    }
  });

  // Live reload: the server streams the re-rendered body when the file changes.
  const source = new EventSource('/events');
  source.onmessage = (event) => {
    const message = JSON.parse(event.data);
    if (typeof message.content === 'string') {
      content.innerHTML = message.content;
      buildToc();
    }
  };

  // The server stops when its buffer is closed in Neovim. A script cannot close
  // a tab it did not open, so say so instead of leaving the last render alive.
  source.onerror = () => {
    setTimeout(async () => {
      try {
        await fetch('/', { cache: 'no-store' });
      } catch (error) {
        source.close();
        content.innerHTML =
          '<div class="preview-closed">Preview closed &mdash; its buffer was closed in Neovim.</div>';
        document.title = 'Preview closed';
      }
    }, 800);
  };

  themeSelect.append(new Option('System', 'system'));
  for (const theme of config.themes) {
    themeSelect.append(new Option(theme.label, theme.key));
  }
  applySettings();
  buildToc();
})();
