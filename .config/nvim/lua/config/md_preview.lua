-- Markdown preview in the browser, rendered locally by md-preview/server.mjs
-- (markdown-it + github-slugger + github-markdown-css). Nothing talks to GitHub
-- or any network at runtime, so it works offline; the only setup step is a
-- one-time `npm install` inside md-preview (~/.config/nvim/README.md).
--
-- One preview per buffer, each on an automatically chosen port. A preview
-- survives switching buffers, and stops when its buffer is deleted, when Neovim
-- exits, or through :MarkdownPreviewStop.
local M = {}

local PREVIEW_DIR = vim.fs.joinpath(vim.fn.stdpath('config'), 'md-preview')
local SERVER = vim.fs.joinpath(PREVIEW_DIR, 'server.mjs')
local DEPENDENCY = vim.fs.joinpath(PREVIEW_DIR, 'node_modules', 'markdown-it')

local previews = {} -- buffer number -> { job, url, port, output }

local function buffer_path(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return nil
  end
  return vim.fn.fnamemodify(name, ":p")
end

local function stop(bufnr)
  local preview = previews[bufnr]
  if not preview then
    return
  end
  previews[bufnr] = nil
  if preview.job then
    vim.fn.jobstop(preview.job)
  end
end

local function stop_all()
  for _, bufnr in ipairs(vim.tbl_keys(previews)) do
    stop(bufnr)
  end
end

local function dependencies_installed()
  return vim.fn.isdirectory(DEPENDENCY) == 1
end

local function install(on_done)
  local npm = vim.fn.exepath("npm")
  if npm == "" then
    vim.notify(
      "npm is missing: install Node.js, then run :MarkdownPreviewInstall",
      vim.log.levels.ERROR
    )
    return
  end
  vim.notify("Installing the markdown preview dependencies...", vim.log.levels.INFO)
  vim.fn.jobstart({ npm, "install", "--prefix", PREVIEW_DIR, "--no-fund", "--no-audit" }, {
    on_exit = function(_, code)
      if code == 0 and dependencies_installed() then
        vim.notify("Markdown preview ready", vim.log.levels.INFO)
        if on_done then
          on_done()
        end
      else
        vim.notify(
          "npm install failed (exit " .. code .. "): run it yourself with "
            .. "`npm install --prefix " .. PREVIEW_DIR .. "`",
          vim.log.levels.ERROR
        )
      end
    end,
  })
end

local function open_when_listening(preview, bufnr, attempts)
  if previews[bufnr] ~= preview or not preview.url then
    return
  end
  local client = vim.uv.new_tcp()
  client:connect("127.0.0.1", preview.port, function(err)
    if not client:is_closing() then
      client:close()
    end
    vim.schedule(function()
      if previews[bufnr] ~= preview or not preview.url then
        return
      end
      if not err then
        vim.ui.open(preview.url)
      elseif attempts > 1 then
        vim.defer_fn(function()
          open_when_listening(preview, bufnr, attempts - 1)
        end, 250)
      else
        vim.notify("the preview is not answering on " .. preview.url, vim.log.levels.WARN)
      end
    end)
  end)
end

local function start(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local running = previews[bufnr]
  if running then
    if running.url then
      vim.ui.open(running.url)
    end
    return
  end
  local file = buffer_path(bufnr)
  if not file then
    vim.notify("md-preview: save the buffer to a file first", vim.log.levels.WARN)
    return
  end
  local node = vim.fn.exepath("node")
  if node == "" then
    vim.notify(
      "md-preview needs Node.js: install nodejs, then run :MarkdownPreviewInstall",
      vim.log.levels.ERROR
    )
    return
  end
  if not dependencies_installed() then
    local question = "The markdown preview needs its dependencies. Install them now with npm?"
    if vim.fn.confirm(question, "&Yes\n&No", 1) == 1 then
      install(function()
        start(bufnr)
      end)
    end
    return
  end

  local preview = { output = "" }

  local function read(data)
    if preview.url then
      return
    end
    preview.output = preview.output .. table.concat(data, "\n")
    local port = preview.output:match("Running on http://127%.0%.0%.1:(%d+)")
    if not port then
      return
    end
    preview.port = tonumber(port)
    preview.url = "http://127.0.0.1:" .. port .. "/"
    open_when_listening(preview, bufnr, 20)
  end

  -- Port 0 lets the server pick a free port, so previews never fight over one.
  local command = { node, SERVER, file, "0" }
  local setpriv = vim.fn.exepath("setpriv")
  if setpriv ~= "" then
    -- SIGTERM the preview whenever Neovim dies, including a hard kill.
    command = { setpriv, "--pdeathsig=SIGTERM", "--", node, SERVER, file, "0" }
  end
  local job = vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      read(data)
    end,
    on_stderr = function(_, data)
      read(data)
    end,
    on_exit = function(_, code)
      if previews[bufnr] == preview then
        previews[bufnr] = nil
        if code ~= 0 then
          vim.notify("the preview server exited with code " .. code, vim.log.levels.WARN)
        end
      end
    end,
  })
  if job <= 0 then
    vim.notify("md-preview: could not start the preview server", vim.log.levels.ERROR)
    return
  end

  preview.job = job
  previews[bufnr] = preview
end

function M.start()
  start(vim.api.nvim_get_current_buf())
end

function M.stop()
  stop(vim.api.nvim_get_current_buf())
end

function M.toggle()
  local bufnr = vim.api.nvim_get_current_buf()
  if previews[bufnr] then
    stop(bufnr)
  else
    start(bufnr)
  end
end

function M.install()
  install()
end

function M.setup()
  vim.api.nvim_create_user_command("MarkdownPreview", M.start, {
    desc = "Preview this buffer in the browser (local markdown-it renderer)",
  })
  vim.api.nvim_create_user_command("MarkdownPreviewToggle", M.toggle, {
    desc = "Toggle this buffer's preview",
  })
  vim.api.nvim_create_user_command("MarkdownPreviewStop", M.stop, {
    desc = "Stop this buffer's preview",
  })
  vim.api.nvim_create_user_command("MarkdownPreviewInstall", M.install, {
    desc = "Install the preview's npm dependencies",
  })
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    callback = function(args)
      stop(args.buf)
    end,
    desc = "Stop the preview of a deleted buffer",
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = stop_all,
    desc = "Stop every preview on exit",
  })
end

return M
