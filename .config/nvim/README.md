# Neovim config

## Markdown preview

`:MarkdownPreview` opens the current file in the browser, rendered locally by
`md-preview/server.mjs`: markdown-it for GFM, github-slugger for GitHub's exact
heading ids (so table-of-contents links resolve), github-markdown-css and
highlight.js for the look. **Nothing touches the network at runtime** — no
GitHub API — so it works offline and cannot hit a rate limit.

It replaces two earlier attempts: `markdown-preview.nvim` (its slugify kept
punctuation, so `#1-first-step` links never matched) and `grip` (it rendered
every page through the GitHub API, 60 requests/hour unauthenticated, which is
useless without internet).

### Requirement

Node.js on `PATH`, plus a one-time install of the preview's own dependencies:

```sh
:MarkdownPreviewInstall   # npm install --prefix ~/.config/nvim/md-preview
```

That install needs internet once. After it, previews are fully offline. The
packages live in `md-preview/node_modules` (gitignored) and can be removed at
any time by deleting that folder. `grip` is no longer needed
(`pipx uninstall grip` if you want it gone).

### Toolbar

Every preview has a floating `Aa` button (bottom right):

| Control | Detail |
| --- | --- |
| Text size | A− / A+ — opens at 18px by default |
| Theme | System plus 12: GitHub Light/Dark/Dimmed, One Dark, One Light, Dracula, Nord, Gruvbox Dark, Monokai, Tokyo Night, Night Owl, Comfort |
| Width | Comfortable (980px) or Wide (1400px) |
| Font | Sans or Serif |
| Contents | Panel listing every h2/h3, click to jump — the text shifts right so it is never covered |
| Reset | Back to the saved defaults |
| Save as default | Writes `md-preview/settings.json`, so every new preview opens this way |

Keys: `Alt+T` next theme, `Alt+C` contents, `Alt+=` / `Alt+-` text size, `Esc`
close the panel. Alt combinations on purpose: plain letters are swallowed by
vim-style browser extensions (Vimium's `t` opens a new tab).

Saved defaults live in `md-preview/settings.json` (safe to commit — it is your
config, and it travels to your other machines). Edits apply to the preview you
are in until you press Save as default. Code blocks follow the chosen theme.

### Behaviour

- One preview per buffer, each on its own automatically chosen port.
- Open as many as you like; each gets its own browser tab.
- Switching buffers never closes a preview.
- The page live-reloads when the file is written.
- Closing a buffer (`:bd`, `:bw`, `:Bdelete`) or quitting Neovim stops that
  preview's server, including a hard kill (`setpriv --pdeathsig`). The browser
  tab itself cannot be closed by a server, so it stays until you close it.
- Follows the OS light/dark preference.

### Commands

| Command | Effect |
| --- | --- |
| `:MarkdownPreview` | Open this buffer's preview (re-opens its URL if already running) |
| `:MarkdownPreviewToggle` | Open or stop this buffer's preview |
| `:MarkdownPreviewStop` | Stop this buffer's preview |
| `:MarkdownPreviewInstall` | Install the preview's npm dependencies |

Implemented in `lua/config/md_preview.lua` and `md-preview/`.
