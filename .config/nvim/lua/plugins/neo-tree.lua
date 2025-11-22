return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = false,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,

      default_component_configs = {
        icon = {
          folder_closed = "",
          folder_open   = "",
          folder_empty  = "",
          default       = "*",
          highlight     = "NeoTreeFileIcon",
        },
        name       = { highlight = "NeoTreeFileName", use_git_status_colors = true },
        modified   = { symbol = "[+]" },
        git_status = {
          symbols = {
            added     = "",
            modified  = "",
            deleted   = "",
            renamed   = "➜",
            untracked = "U",
            ignored   = "◌",
            unstaged  = "",
            staged    = "",
            conflict  = "",
          },
        },
      },

      window = {
        position = "left",
        width = 30,
        mappings = {
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          ["<esc>"] = "cancel",
          ["P"] = { "toggle_preview", config = { use_float = true } },
          ["l"] = "open",
          ["h"] = "close_node",
          ["s"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["z"] = "close_all_nodes",
          ["Z"] = "expand_all_nodes",
          ["a"] = { "add", config = { show_path = "none" } },
          ["A"] = "add_directory",
          ["d"] = "delete",
          ["r"] = "rename",
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
        },
      },

      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_hidden = true,
        },
        follow_current_file = { enabled = false },
        use_libuv_file_watcher = false,
      },

      buffers = {
        follow_current_file = { enabled = true },
        group_empty_dirs = true,
        window = {
          mappings = { ["bd"] = "buffer_delete", ["<bs>"] = "navigate_up", ["."] = "set_root" },
        },
      },

      git_status = {
        window = {
          position = "float",
          mappings = {
            ["A"]  = "git_add_all",
            ["gu"] = "git_unstage_file",
            ["ga"] = "git_add_file",
            ["gr"] = "git_revert_file",
            ["gc"] = "git_commit",
            ["gp"] = "git_push",
            ["gg"] = "git_commit_and_push",
          },
        },
      },
    })

    vim.cmd([[nnoremap \ :Neotree reveal<cr>]])
  end,
}
