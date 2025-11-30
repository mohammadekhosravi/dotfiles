-- ═══════════════════════════════════════════════════════════════════════════
-- UI POLISH
-- ═══════════════════════════════════════════════════════════════════════════
-- This plugin handles ONLY visual styling:
--   • Global rounded borders for all floating windows (vim.o.winborder)
--   • Highlight groups for popup menu (Pmenu*) and floating windows
--   • Dynamic color extraction from current colorscheme
--   • Wildmenu (command-line completion) styling
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
    -- This single setting applies rounded borders to ALL floating windows:
    --   • LSP hover (K)
    --   • LSP signature help (<C-k>)
    --   • Diagnostic floats (<leader>sh)
    --   • Any plugin using vim.api.nvim_open_win with relative="editor/win"
    --
    -- Options: "none", "single", "double", "rounded", "solid", "shadow"
    -- Or custom: { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
    vim.o.winborder = "rounded"

    -- ═════════════════════════════════════════════════════════════════════
    -- HELPER: Extract colors from current colorscheme
    -- ═════════════════════════════════════════════════════════════════════
    -- This function reads highlight groups from whatever colorscheme is active
    -- and returns a color table. Works with ANY colorscheme, not just onedark.
    --
    -- It tries to get colors from existing highlight groups:
    --   • Normal      → Main editor background/foreground
    --   • NormalFloat → Floating window background (falls back to Normal)
    --   • Visual      → Selection color (used for PmenuSel)
    --   • Comment     → Used for scrollbar
    --   • Special     → Used for scrollbar thumb
    --   • FloatBorder → Border color (falls back to Comment)

    local function get_theme_colors()
      -- Helper to safely get a highlight group's colors
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

      -- Extract colors from current theme's highlight groups
      local normal = get_hl("Normal")
      local normal_float = get_hl("NormalFloat")
      local visual = get_hl("Visual")
      local comment = get_hl("Comment")
      local special = get_hl("Special")
      local float_border = get_hl("FloatBorder")

      -- Build color table with fallbacks
      -- Each color has a "source" (which hl group) and sensible fallback
      return {
        -- Popup menu background (from NormalFloat → Normal → fallback)
        menu_bg = normal_float.bg or normal.bg or "#1e222a",

        -- Popup menu foreground text (from Normal → fallback)
        menu_fg = normal.fg or "#abb2bf",

        -- Selected item background (from Visual → fallback blue)
        sel_bg = visual.bg or "#3e4452",

        -- Selected item foreground (keep readable, use bright white)
        sel_fg = "#ffffff",

        -- Scrollbar track (slightly lighter than menu_bg, use Comment bg or dim)
        scrollbar_bg = comment.bg or normal_float.bg or normal.bg or "#1e222a",

        -- Scrollbar thumb (from Special → Comment fg → fallback)
        scrollbar_thumb = special.fg or comment.fg or "#5c6370",

        -- Border color (from FloatBorder → Comment → fallback)
        border = float_border.fg or comment.fg or "#5c6370",

        -- Float background (same as menu for consistency)
        float_bg = normal_float.bg or normal.bg or "#1e222a",

        -- Float foreground
        float_fg = normal_float.fg or normal.fg or "#abb2bf",
      }
    end

    -- ═════════════════════════════════════════════════════════════════════
    -- APPLY HIGHLIGHT GROUPS
    -- ═════════════════════════════════════════════════════════════════════
    -- These highlight groups control the appearance of:
    --
    -- POPUP MENU (native completion, wildmenu):
    --   • Pmenu       → Normal items in popup menu
    --   • PmenuSel    → Selected/highlighted item
    --   • PmenuSbar   → Scrollbar track (background)
    --   • PmenuThumb  → Scrollbar thumb (the draggable part)
    --   • PmenuKind   → "Kind" column (function, variable, etc.)
    --   • PmenuExtra  → Extra info column
    --
    -- FLOATING WINDOWS (LSP hover, diagnostics, etc.):
    --   • NormalFloat → Background/foreground of float content
    --   • FloatBorder → Border characters color
    --   • FloatTitle  → Title bar of floating windows
    --
    -- NOTE: The actual border SHAPE comes from vim.o.winborder = "rounded"
    --       These highlights only control the COLORS

    local function apply_ui_highlights()
      local c = get_theme_colors()

      -- ─────────────────────────────────────────────────────────────────
      -- Popup Menu Highlights
      -- ─────────────────────────────────────────────────────────────────
      vim.api.nvim_set_hl(0, "Pmenu", {
        bg = c.menu_bg,
        fg = c.menu_fg,
      })

      vim.api.nvim_set_hl(0, "PmenuSel", {
        bg = c.sel_bg,
        fg = c.sel_fg,
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
        fg = c.scrollbar_thumb, -- Dimmer than main text
      })

      vim.api.nvim_set_hl(0, "PmenuExtra", {
        bg = c.menu_bg,
        fg = c.scrollbar_thumb,
      })

      -- ─────────────────────────────────────────────────────────────────
      -- Floating Window Highlights
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
    end

    -- ═════════════════════════════════════════════════════════════════════
    -- COLORSCHEME CHANGE HANDLER
    -- ═════════════════════════════════════════════════════════════════════
    -- Re-apply our custom highlights whenever the colorscheme changes.
    -- This ensures ui-polish works with ANY theme, not just onedark.
    --
    -- The autocmd fires AFTER the new colorscheme is loaded, so we can
    -- read its colors and apply our consistent styling on top.

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
    -- When you type `:` and press Tab, this controls the completion behavior.
    --
    -- wildmenu     → Enable enhanced command-line completion
    -- wildmode     → "longest:full,full"
    --                 • First Tab: complete longest common string, show menu
    --                 • Next Tabs: cycle through full matches
    -- wildoptions  → "pum" makes wildmenu use popup menu (styled by Pmenu*)
    --                 instead of the old horizontal bar

    vim.opt.wildmenu = true
    vim.opt.wildmode = "longest:full,full"
    vim.opt.wildoptions = "pum"
  end,
}
