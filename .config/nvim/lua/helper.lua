P = function(v)
  print(vim.inspect(v))
  return v
end

local M = {}

local function apply_action(client, action, bufnr)
  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
  end
  if action.command then
    local cmd = action.command
    if type(cmd.command) == "string" and vim.lsp.commands[cmd.command] then
      vim.lsp.commands[cmd.command](cmd, { client_id = client.id, bufnr = bufnr })
    else
      client:request("workspace/executeCommand", cmd, function() end, bufnr)
    end
  end
end

local function to_lsp_diag(d)
  return {
    range = {
      start = { line = d.lnum, character = d.col },
      ["end"] = { line = d.end_lnum or d.lnum, character = d.end_col or d.col },
    },
    message = d.message,
    severity = d.severity,
    code = d.code,
    source = d.source,
  }
end

--- Format action for display (used both in item and format_item for compatibility)
---@param item table Action item with title, source, lnum fields
---@return string Formatted display string
local function format_action(item)
  local line = item.lnum and string.format("L%-3d", item.lnum + 1) or "BUF "
  return string.format("[%s] %s: %s", line, item.source, item.title)
end

local function show_menu(all_actions, bufnr)
  if #all_actions == 0 then
    vim.notify("No more actions", vim.log.levels.INFO)
    return
  end

  -- Pre-format display text into each item
  -- This ensures Telescope/dressing shows our format, not just index
  for _, item in ipairs(all_actions) do
    item.display = format_action(item)
  end

  vim.ui.select(all_actions, {
    prompt = string.format("Code Actions (%d remaining)", #all_actions),
    format_item = function(item)
      -- Return pre-computed display (works with builtin backend)
      -- For Telescope, the 'display' field is also checked
      return item.display
    end,
  }, function(choice, idx)
    if choice then
      apply_action(choice.client, choice.action, bufnr)
      -- Remove applied action and reopen menu
      table.remove(all_actions, idx)
      vim.defer_fn(function()
        show_menu(all_actions, bufnr)
      end, 100)
    end
  end)
end

function M.code_actions_all()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    vim.notify("No LSP attached", vim.log.levels.WARN)
    return
  end

  local all_actions = {}
  local pending = 0

  local function done()
    pending = pending - 1
    if pending > 0 then return end

    if #all_actions == 0 then
      vim.notify("No code actions", vim.log.levels.INFO)
      return
    end

    -- Sort by line number (nil/BUF actions go last)
    table.sort(all_actions, function(a, b)
      local a_line = a.lnum or math.huge
      local b_line = b.lnum or math.huge
      if a_line ~= b_line then
        return a_line < b_line
      end
      return a.title < b.title
    end)

    show_menu(all_actions, bufnr)
  end

  -- Diagnostic-based requests
  local diags = vim.diagnostic.get(bufnr)
  local by_line = {}
  for _, d in ipairs(diags) do
    by_line[d.lnum] = by_line[d.lnum] or {}
    table.insert(by_line[d.lnum], d)
  end

  for lnum, lds in pairs(by_line) do
    local lsp_diags = vim.tbl_map(to_lsp_diag, lds)
    pending = pending + 1
    vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", {
      textDocument = vim.lsp.util.make_text_document_params(bufnr),
      range = {
        start = { line = lnum, character = 0 },
        ["end"] = { line = lnum, character = 999 },
      },
      context = { diagnostics = lsp_diags, triggerKind = 2 },
    }, function(results)
      for cid, res in pairs(results or {}) do
        local c = vim.lsp.get_client_by_id(cid)
        if c and res.result then
          for _, a in ipairs(res.result) do
            table.insert(all_actions, {
              title = a.title,
              action = a,
              client = c,
              source = c.name,
              lnum = lnum,
            })
          end
        end
      end
      done()
    end)
  end

  -- Global request
  pending = pending + 1
  vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
    },
    context = { diagnostics = {}, only = { "source", "refactor", "quickfix" }, triggerKind = 1 },
  }, function(results)
    for cid, res in pairs(results or {}) do
      local c = vim.lsp.get_client_by_id(cid)
      if c and res.result then
        for _, a in ipairs(res.result) do
          table.insert(all_actions, {
            title = a.title,
            action = a,
            client = c,
            source = c.name,
            lnum = nil,
          })
        end
      end
    end
    done()
  end)
end

return M
