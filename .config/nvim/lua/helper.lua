P = function(v)
  print(vim.inspect(v))
  return v
end

local M = {}

local notify = function(msg, level)
  local ok, fidget = pcall(require, "fidget")
  if ok and fidget.notify then
    pcall(fidget.notify, msg, level)
  else
    vim.notify(msg, level)
  end
end

-- Convert Neovim diagnostic to LSP diagnostic format
local function to_lsp_diagnostic(diag)
  return {
    range = {
      start = { line = diag.lnum, character = diag.col },
      ["end"] = { line = diag.end_lnum or diag.lnum, character = diag.end_col or diag.col },
    },
    message = diag.message,
    severity = diag.severity,
    code = diag.code,
    source = diag.source,
  }
end

local function apply_action(client, action, bufnr)
  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
  end

  local cmd = action.command
  if not cmd then return end

  local cmd_name = cmd.command
  if type(cmd_name) == "string" and vim.lsp.commands[cmd_name] then
    vim.lsp.commands[cmd_name](cmd, { client_id = client.id, bufnr = bufnr })
    return
  end

  client:request("workspace/executeCommand", cmd, function() end, bufnr)
end

local function show_actions(actions, bufnr)
  if not actions or #actions == 0 then
    notify("No code actions available", vim.log.levels.INFO)
    return
  end

  -- Sort by line number
  table.sort(actions, function(a, b)
    return (a.line or 0) < (b.line or 0)
  end)

  -- Dedupe by title + source + line
  local seen = {}
  local unique = {}
  for _, a in ipairs(actions) do
    local key = (a.action.title or "") .. "::" .. (a.source or "") .. "::" .. (a.line or 0)
    if not seen[key] then
      seen[key] = true
      table.insert(unique, a)
    end
  end

  vim.ui.select(unique, {
    prompt = ("All Code Actions (%d)"):format(#unique),
    format_item = function(item)
      local prefix = item.line and string.format("L%-3d", item.line) or "[G] "
      return string.format("%s [%s] %s", prefix, item.source or "?", item.action.title or "<no title>")
    end,
  }, function(choice)
    if not choice then return end
    local client = vim.lsp.get_client_by_id(choice.client_id)
    if not client then
      notify("LSP client not found", vim.log.levels.WARN)
      return
    end
    apply_action(client, choice.action, bufnr)
  end)
end

function M.code_actions_all()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    notify("No LSP clients attached", vim.log.levels.INFO)
    return
  end

  -- Debug: show which clients are attached
  local client_names = {}
  for _, c in ipairs(clients) do
    table.insert(client_names, c.name)
  end
  notify("Clients: " .. table.concat(client_names, ", "), vim.log.levels.DEBUG)

  local collected = {}
  local pending = 0

  local function try_finish()
    pending = pending - 1
    if pending == 0 then
      show_actions(collected, bufnr)
    end
  end

  local function handle_results(results, line_hint, source_hint)
    results = results or {}
    for client_id, entry in pairs(results) do
      local client = vim.lsp.get_client_by_id(client_id)
      local client_name = client and client.name or tostring(client_id)

      if entry and entry.result then
        for _, action in ipairs(entry.result) do
          local line = line_hint
          -- Try to get line from action's diagnostics if available
          if action.diagnostics and #action.diagnostics > 0 then
            local r = action.diagnostics[1].range
            if r and r.start then
              line = r.start.line + 1
            end
          end

          table.insert(collected, {
            action = action,
            client_id = tonumber(client_id),
            line = line,
            source = source_hint or client_name,
          })
        end
      end
    end
    try_finish()
  end

  -- Get all diagnostics and group by line
  local all_diags = vim.diagnostic.get(bufnr)
  local diags_by_line = {}
  for _, d in ipairs(all_diags) do
    diags_by_line[d.lnum] = diags_by_line[d.lnum] or {}
    table.insert(diags_by_line[d.lnum], d)
  end

  -- Request code actions for each line that has diagnostics
  for lnum, diags in pairs(diags_by_line) do
    -- Convert to LSP format
    local lsp_diags = {}
    for _, d in ipairs(diags) do
      table.insert(lsp_diags, to_lsp_diagnostic(d))
    end

    -- Use the range of the first diagnostic on this line
    local first = diags[1]
    local params = {
      textDocument = vim.lsp.util.make_text_document_params(bufnr),
      range = {
        start = { line = first.lnum, character = first.col },
        ["end"] = { line = first.end_lnum or first.lnum, character = first.end_col or first.col },
      },
      context = {
        diagnostics = lsp_diags,
        triggerKind = 1, -- Invoked
      },
    }

    pending = pending + 1
    vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", params, function(results)
      handle_results(results, lnum + 1, nil)
    end)
  end

  -- Also request source/refactor actions for entire buffer
  local last_line = math.max(0, vim.api.nvim_buf_line_count(bufnr) - 1)
  local global_params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = last_line, character = 0 },
    },
    context = {
      diagnostics = {},
      only = { "source", "refactor", "quickfix" },
      triggerKind = 1,
    },
  }

  pending = pending + 1
  vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", global_params, function(results)
    handle_results(results, nil, nil)
  end)

  -- Edge case: no diagnostics and global request is the only one
  if pending == 0 then
    show_actions({}, bufnr)
  end
end

return M
