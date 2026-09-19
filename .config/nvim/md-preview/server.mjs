#!/usr/bin/env node
// Local markdown preview server for Neovim's :MarkdownPreview.
//
// Renders with markdown-it, gives headings GitHub's exact ids (github-slugger,
// so [text](#anchor) links in a table of contents resolve), and serves
// github-markdown-css plus the themes in style/themes.css. Nothing here talks to
// the network at runtime: the only setup step is a one-time `npm install`.
import { createServer } from 'node:http';
import { readFile, rename, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import GithubSlugger from 'github-slugger';
import hljs from 'highlight.js';
import MarkdownIt from 'markdown-it';
import taskLists from 'markdown-it-task-lists';

const here = path.dirname(fileURLToPath(import.meta.url));

const file = process.argv[2];
if (!file) {
  process.stderr.write('usage: server.mjs <file.md> [port]\n');
  process.exit(2);
}
const filePath = path.resolve(file);
const requestedPort = Number(process.argv[3] ?? 0);

const THEMES = [
  { key: 'github-light', label: 'GitHub Light', hljs: 'github.css' },
  { key: 'github-dark', label: 'GitHub Dark', hljs: 'github-dark.css' },
  { key: 'github-dimmed', label: 'GitHub Dimmed', hljs: 'github-dark-dimmed.css' },
  { key: 'one-dark', label: 'One Dark', hljs: 'atom-one-dark.css' },
  { key: 'one-light', label: 'One Light', hljs: 'atom-one-light.css' },
  { key: 'dracula', label: 'Dracula', hljs: 'base16/dracula.css' },
  { key: 'nord', label: 'Nord', hljs: 'base16/nord.css' },
  { key: 'gruvbox-dark', label: 'Gruvbox Dark', hljs: 'base16/gruvbox-dark-medium.css' },
  { key: 'monokai', label: 'Monokai', hljs: 'monokai.css' },
  { key: 'tokyo-night', label: 'Tokyo Night', hljs: 'tokyo-night-dark.css' },
  { key: 'night-owl', label: 'Night Owl', hljs: 'night-owl.css' },
  { key: 'comfort', label: 'Comfort', hljs: 'atom-one-light.css' },
];
const SCALES = [0.8, 0.9, 1, 1.1, 1.25, 1.4, 1.6, 1.8, 2];
const DEFAULTS = { theme: 'system', scale: 3, width: 'comfortable', font: 'sans', toc: false };
const HIGHLIGHT_FILES = new Set(THEMES.map((theme) => theme.hljs));

// Saved preferences live next to this script, so every new preview (and every
// port, which is a different browser origin) opens with them.
const SETTINGS_FILE = path.join(here, 'settings.json');
const THEME_KEYS = new Set(['system', ...THEMES.map((theme) => theme.key)]);

function sanitizeSettings(value) {
  const settings = {};
  if (!value || typeof value !== 'object') {
    return settings;
  }
  if (THEME_KEYS.has(value.theme)) {
    settings.theme = value.theme;
  }
  if (Number.isInteger(value.scale) && value.scale >= 0 && value.scale < SCALES.length) {
    settings.scale = value.scale;
  }
  if (value.width === 'comfortable' || value.width === 'wide') {
    settings.width = value.width;
  }
  if (value.font === 'sans' || value.font === 'serif') {
    settings.font = value.font;
  }
  if (typeof value.toc === 'boolean') {
    settings.toc = value.toc;
  }
  return settings;
}

async function readSettings() {
  try {
    const stored = JSON.parse(await readFile(SETTINGS_FILE, 'utf8'));
    return { ...DEFAULTS, ...sanitizeSettings(stored) };
  } catch (error) {
    return { ...DEFAULTS };
  }
}

async function writeSettings(value) {
  const settings = { ...DEFAULTS, ...sanitizeSettings(value) };
  const temporary = SETTINGS_FILE + '.tmp';
  await writeFile(temporary, JSON.stringify(settings, null, 2) + '\n');
  await rename(temporary, SETTINGS_FILE);
  return settings;
}

const ANCHOR_ICON =
  '<svg class="octicon octicon-link" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true">' +
  '<path d="M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0' +
  ' .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83' +
  'l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25' +
  'a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z"></path></svg>';

const md = new MarkdownIt({
  html: true,
  linkify: true,
  highlight(code, language) {
    if (language && hljs.getLanguage(language)) {
      try {
        const highlighted = hljs.highlight(code, {
          language,
          ignoreIllegals: true,
        }).value;
        return `<pre class="hljs"><code>${highlighted}</code></pre>`;
      } catch {
        return '';
      }
    }
    return '';
  },
}).use(taskLists);

// GitHub wraps a heading and its permalink link in .markdown-heading, and
// github-markdown-css styles that. The id is what a table of contents links to.
md.renderer.rules.heading_open = (tokens, idx, options, env) => {
  const token = tokens[idx];
  const inline = tokens[idx + 1];
  const text =
    inline && inline.type === 'inline'
      ? inline.children
          .filter((child) => child.type === 'text' || child.type === 'code_inline')
          .map((child) => child.content)
          .join('')
      : '';
  env.headingSlug = env.slugger.slug(text);
  const label = md.utils.escapeHtml(text);
  return `<div class="markdown-heading"><${token.tag} class="heading-element" id="${env.headingSlug}" aria-label="${label}">`;
};

md.renderer.rules.heading_close = (tokens, idx, options, env) => {
  const tag = tokens[idx].tag;
  return `</${tag}><a class="anchor" aria-label="Permalink" href="#${env.headingSlug}">${ANCHOR_ICON}</a></div>`;
};

async function renderBody() {
  let source;
  try {
    source = await readFile(filePath, 'utf8');
  } catch (error) {
    return `<p>Could not read <code>${md.utils.escapeHtml(filePath)}</code>: ${md.utils.escapeHtml(error.message)}</p>`;
  }
  try {
    return md.render(source, { slugger: new GithubSlugger() });
  } catch (error) {
    return `<p>Could not render the file: ${md.utils.escapeHtml(error.message)}</p>`;
  }
}

function page(body, defaults) {
  const title = md.utils.escapeHtml(path.basename(filePath));
  const config = JSON.stringify({
    themes: THEMES,
    scales: SCALES,
    defaults,
  });
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title}</title>
<link rel="stylesheet" href="/style/github-markdown.css">
<link id="hljs-theme" rel="stylesheet" href="/style/hljs/github.css">
<link rel="stylesheet" href="/style/themes.css">
<link rel="stylesheet" href="/style/page.css">
<script>window.PREVIEW_CONFIG = ${config};</script>
<script>
  // Apply the saved settings before the first paint so the page opens the way
  // it was configured, with no flash of the wrong theme or size.
  (() => {
    const config = window.PREVIEW_CONFIG;
    const settings = config.defaults;
    const key =
      settings.theme === 'system'
        ? window.matchMedia('(prefers-color-scheme: dark)').matches
          ? 'github-dark'
          : 'github-light'
        : settings.theme;
    const root = document.documentElement;
    root.dataset.theme = key;
    root.dataset.width = settings.width;
    root.dataset.font = settings.font;
    root.dataset.toc = settings.toc ? 'on' : 'off';
    const size = Math.round(16 * config.scales[settings.scale]) + 'px';
    root.style.fontSize = size;
    root.style.setProperty('--preview-font-size', size);
    const theme = config.themes.find((entry) => entry.key === key);
    if (theme) {
      document.getElementById('hljs-theme').href = '/style/hljs/' + theme.hljs;
    }
  })();
</script>
</head>
<body>
<article class="markdown-body" id="content">${body}</article>
<nav class="preview-toc" id="toc" hidden aria-label="Contents"></nav>
<div class="preview-toolbar">
  <button class="preview-fab" id="fab" aria-label="Preview settings" aria-expanded="false">Aa</button>
  <div class="preview-panel" id="panel" hidden>
    <div class="row"><span>Text size</span>
      <span class="controls">
        <button data-size="-1" aria-label="Smaller text">A&minus;</button>
        <button data-size="1" aria-label="Larger text">A+</button>
      </span>
    </div>
    <div class="row"><label for="theme">Theme</label><select id="theme"></select></div>
    <div class="row"><span>Width</span>
      <span class="controls">
        <button data-width="comfortable">Comfortable</button>
        <button data-width="wide">Wide</button>
      </span>
    </div>
    <div class="row"><span>Font</span>
      <span class="controls">
        <button data-font="sans">Sans</button>
        <button data-font="serif">Serif</button>
      </span>
    </div>
    <div class="row"><span>Contents</span>
      <span class="controls"><button id="toc-toggle" aria-pressed="false">Show</button></span>
    </div>
    <div class="row footer">
      <button id="reset">Reset</button>
      <button id="save">Save as default</button>
    </div>
    <p class="hint" id="status">Alt+T theme &middot; Alt+C contents &middot; Alt++/&minus; text size</p>
  </div>
</div>
<script src="/style/preview.js"></script>
</body>
</html>
`;
}

const staticFiles = {
  '/style/github-markdown.css': path.join(here, 'node_modules/github-markdown-css/github-markdown.css'),
  '/style/themes.css': path.join(here, 'style/themes.css'),
  '/style/page.css': path.join(here, 'style/page.css'),
  '/style/preview.js': path.join(here, 'style/preview.js'),
};

const clients = new Set();

async function broadcast() {
  const body = await renderBody();
  const payload = JSON.stringify({ content: body });
  for (const client of clients) {
    client.write(`data: ${payload}\n\n`);
  }
}

const server = createServer(async (request, response) => {
  const { pathname } = new URL(request.url, 'http://127.0.0.1');

  if (pathname === '/events') {
    response.writeHead(200, {
      'content-type': 'text/event-stream',
      'cache-control': 'no-cache',
      connection: 'keep-alive',
    });
    response.write(':\n\n');
    clients.add(response);
    request.on('close', () => clients.delete(response));
    return;
  }

  if (pathname === '/settings') {
    if (request.method !== 'POST') {
      response.writeHead(405).end('method not allowed');
      return;
    }
    let body = '';
    for await (const chunk of request) {
      body += chunk;
      if (body.length > 4096) {
        response.writeHead(413).end('too large');
        return;
      }
    }
    try {
      await writeSettings(JSON.parse(body));
      response.writeHead(204).end();
    } catch (error) {
      response.writeHead(400).end('invalid settings');
    }
    return;
  }

  if (pathname === '/favicon.ico') {
    response.writeHead(204).end();
    return;
  }

  if (pathname.startsWith('/style/hljs/')) {
    const name = decodeURIComponent(pathname.slice('/style/hljs/'.length));
    if (!HIGHLIGHT_FILES.has(name)) {
      response.writeHead(404).end('not found');
      return;
    }
    try {
      const body = await readFile(path.join(here, 'node_modules/highlight.js/styles', name));
      response.writeHead(200, { 'content-type': 'text/css', 'cache-control': 'no-store' });
      response.end(body);
    } catch {
      response.writeHead(404).end('not found');
    }
    return;
  }

  const staticFile = staticFiles[pathname];
  if (staticFile) {
    try {
      const body = await readFile(staticFile);
      const contentType = pathname.endsWith('.js')
        ? 'text/javascript; charset=utf-8'
        : pathname.endsWith('.css')
          ? 'text/css; charset=utf-8'
          : 'text/plain; charset=utf-8';
      response.writeHead(200, { 'content-type': contentType, 'cache-control': 'no-store' });
      response.end(body);
    } catch {
      response.writeHead(404).end('not found');
    }
    return;
  }

  if (pathname === '/' || pathname === '/index.html') {
    response.writeHead(200, {
      'content-type': 'text/html; charset=utf-8',
      'cache-control': 'no-store',
    });
    response.end(page(await renderBody(), await readSettings()));
    return;
  }

  response.writeHead(404).end('not found');
});

server.listen(requestedPort, '127.0.0.1', () => {
  process.stdout.write(` * Running on http://127.0.0.1:${server.address().port}\n`);
});

// Live reload: poll mtime/size so it also notices editors that replace the file.
let stamp = '';
setInterval(async () => {
  try {
    const info = await stat(filePath);
    const next = `${info.mtimeMs}:${info.size}`;
    if (stamp === '') {
      stamp = next;
      return;
    }
    if (next !== stamp) {
      stamp = next;
      await broadcast();
    }
  } catch {
    // File briefly unavailable (atomic save); keep the last render.
  }
}, 400);
