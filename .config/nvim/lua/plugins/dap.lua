return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local set = vim.keymap.set

      set("n", "<F1>", function()
        dap.step_into()
      end, { desc = "Dap step into" })

      set("n", "<F2>", function()
        dap.step_over()
      end, { desc = "Dap step over" })

      set("n", "<F3>", function()
        dap.step_out()
      end, { desc = "Dap step out" })

      set("n", "<F5>", function()
        dap.continue()
      end, { desc = "Dap continue" })

      set("n", "<Leader>b", function()
        dap.toggle_breakpoint()
      end, { desc = "Dap toggle breakpoint" })

      set("n", "<Leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Dap set conditional breakpoint(write expression here)" })

      -- set("n", "<Leader>B", function()
      --   dap.set_breakpoint()
      -- end, { desc = "Dap set breakpoint" })
      -- set("n", "<Leader>lp", function()
      --   dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      -- end, { desc = "Dap set breakpoint with log point message" })
      -- set("n", "<Leader>dr", function()
      --   dap.repl.open()
      -- end, { desc = "Dap open repl" })
      -- set("n", "<Leader>dl", function()
      --   dap.run_last()
      -- end, { desc = "Dap run last command" })
    end,
  },
  {
    "leoluz/nvim-dap-go",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local dapgo = require("dap-go")
      dapgo.setup()

      vim.keymap.set("n", "<leader>dt", function()
        dapgo.debug_test()
      end, { desc = "[Go] Dap debug test" })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      -- conncect dapui to dap events so its open and close automatically
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup({ commented = false })
    end,
  },
}
