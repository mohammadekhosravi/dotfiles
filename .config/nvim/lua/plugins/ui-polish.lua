-- ═══════════════════════════════════════════════════════════════════════════
-- UI POLISH
-- ═══════════════════════════════════════════════════════════════════════════
-- This plugin handles ONLY visual styling:
--   • Global rounded borders for all floating windows (vim.o.winborder)
--   • Highlight groups for popup menu (Pmenu*) and floating windows
--   • Dynamic color extraction from current colorscheme
--   • Wildmenu (command-line completion) styling
--   • Window separator styling
--
-- NOTE: Keymaps are NOT set here (see lsp.lua and keymaps.lua)
-- NOTE: Diagnostic config is NOT set here (see lsp.lua)
-- NOTE: pumheight/pumblend are NOT set here (see options.lua)
-- ═══════════════════════════════════════════════════════════════════════════

return {
  dir = vim.fn.stdpath("config"),
  name = "ui-polish",
  lazy = false,
  priority = 900, -- Load after colorscheme (1000) but before other plugins

  config = function()
    -- ═════════════════════════════════════════════════════════════════════
    -- GLOBAL FLOATING WINDOW BORDER (Neovim 0.11+)
    -- ═════════════════════════════════════════════════════════════════════
    vim.o.winborder = "rounded"

    -- ═════════════════════════════════════════════════════════════════════
    -- HELPER: Extract colors from current colorscheme
    -- ═════════════════════════════════════════════════════════════════════
    local function get_theme_colors()
      local function get_hl(name)
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        if ok and hl then
          return {
            fg = hl.fg and string.format("#%06x", hl.fg) or nil,
            bg = hl.bg and string.format("#%06x", hl.bg) or nil,
          }
        end
        return { fg = nil, bg = nil }
      end

      local normal = get_hl("Normal")
      local normal_float = get_hl("NormalFloat")
      local visual = get_hl("Visual")
      local comment = get_hl("Comment")
      local special = get_hl("Special")
      local float_border = get_hl("FloatBorder")
      local cursor_line = get_hl("CursorLine")

      return {
        -- Main backgrounds
        menu_bg = normal_float.bg or normal.bg or "#1e222a",
        float_bg = normal_float.bg or normal.bg or "#1e222a",

        -- Main foregrounds
        menu_fg = normal.fg or "#abb2bf",
        float_fg = normal_float.fg or normal.fg or "#abb2bf",

        -- Selection (use theme's visual colors for consistency)
        sel_bg = visual.bg or "#3e4452",
        sel_fg = visual.fg, -- nil = inherit, preserves readability

        -- Borders and subtle elements
        border = float_border.fg or comment.fg or "#5c6370",

        -- Scrollbar
        scrollbar_bg = comment.bg or normal_float.bg or normal.bg or "#1e222a",
        scrollbar_thumb = special.fg or comment.fg or "#5c6370",

        -- Cursor line (for quickfix, etc.)
        cursorline_bg = cursor_line.bg or "#2c323c",
      }
    end

    -- ═════════════════════════════════════════════════════════════════════
    -- APPLY HIGHLIGHT GROUPS
    -- ═════════════════════════════════════════════════════════════════════
    local function apply_ui_highlights()
      local c = get_theme_colors()

      -- ─────────────────────────────────────────────────────────────────
      -- Popup Menu (native completion, wildmenu)
      -- ─────────────────────────────────────────────────────────────────
      vim.api.nvim_set_hl(0, "Pmenu", {
        bg = c.menu_bg,
        fg = c.menu_fg,
      })

      vim.api.nvim_set_hl(0, "PmenuSel", {
        bg = c.sel_bg,
        fg = c.sel_fg, -- nil inherits, avoids harsh white
        bold = true,
      })

      vim.api.nvim_set_hl(0, "PmenuSbar", {
        bg = c.scrollbar_bg,
      })

      vim.api.nvim_set_hl(0, "PmenuThumb", {
        bg = c.scrollbar_thumb,
      })

      vim.api.nvim_set_hl(0, "PmenuKind", {
        bg = c.menu_bg,
        fg = c.scrollbar_thumb,
      })

      vim.api.nvim_set_hl(0, "PmenuExtra", {
        bg = c.menu_bg,
        fg = c.scrollbar_thumb,
      })

      -- ─────────────────────────────────────────────────────────────────
      -- Floating Windows (LSP hover, diagnostics, etc.)
      -- ─────────────────────────────────────────────────────────────────
      vim.api.nvim_set_hl(0, "NormalFloat", {
        bg = c.float_bg,
        fg = c.float_fg,
      })

      vim.api.nvim_set_hl(0, "FloatBorder", {
        bg = c.float_bg,
        fg = c.border,
      })

      vim.api.nvim_set_hl(0, "FloatTitle", {
        bg = c.float_bg,
        fg = c.menu_fg,
        bold = true,
      })

      -- ─────────────────────────────────────────────────────────────────
      -- Window Separators (splits)
      -- ─────────────────────────────────────────────────────────────────
      vim.api.nvim_set_hl(0, "WinSeparator", {
        fg = c.border,
        bg = "NONE",
      })

      -- ─────────────────────────────────────────────────────────────────
      -- QuickFix (complements nvim-bqf)
      -- ─────────────────────────────────────────────────────────────────
      vim.api.nvim_set_hl(0, "QuickFixLine", {
        bg = c.cursorline_bg,
        bold = true,
      })
    end

    -- ═════════════════════════════════════════════════════════════════════
    -- COLORSCHEME CHANGE HANDLER
    -- ═════════════════════════════════════════════════════════════════════
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("UiPolishHighlights", { clear = true }),
      pattern = "*",
      callback = apply_ui_highlights,
      desc = "Re-apply UI polish highlights after colorscheme change",
    })

    -- Apply immediately on startup
    apply_ui_highlights()

    -- ═════════════════════════════════════════════════════════════════════
    -- WILDMENU (Command-line completion)
    -- ═════════════════════════════════════════════════════════════════════
    vim.opt.wildmenu = true
    vim.opt.wildmode = "longest:full,full"
    vim.opt.wildoptions = "pum"
  end,
}
