-- 1. Leader Key
vim.g.mapleader = " "

-- 2. Bootstrap Lazy.nvim (The Plugin Manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Plugins setup
require("lazy").setup({
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  "nvim-lualine/lualine.nvim",
  "nvim-treesitter/nvim-treesitter",
  "nvim-telescope/telescope.nvim",
  "nvim-lua/plenary.nvim",
  "lewis6991/gitsigns.nvim",
  "windwp/nvim-autopairs",
  "numToStr/Comment.nvim",

  {
    'akinsho/toggleterm.nvim', 
    version = "*", 
    config = true
  },

  {
    "williamboman/mason.nvim",
    dependencies = { "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({ ensure_installed = { "clangd", "ansiblels", "lua_ls", "gopls" } })
    end
  },

  -- ---> THE C++ DEBUGGER (cpptools) <---
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup the Visual Interface
      dapui.setup()
      
      -- Automatically open/close the UI when debugging starts/stops
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Tell Neovim where Mason put cpptools
      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = vim.fn.stdpath("data") .. '/mason/bin/OpenDebugAD7',
      }

      -- Configure how C++ programs launch
      dap.configurations.cpp = {
        {
          name = "Launch executable",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = true, -- Stops at main() so you can step through line-by-line
          setupCommands = {  
            { 
              text = '-enable-pretty-printing', 
              description =  'enable pretty printing', 
              ignoreFailures = false 
            },
          },
        },
      }

      -- Debugger Keybindings
      vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = 'Start/Continue Debugger' })
      vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = 'Step Over' })
      vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = 'Step Into' })
      vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, { desc = 'Toggle Breakpoint' })
    end
  },
})

-- 4. Global Settings
vim.opt.termguicolors = true
vim.cmd.colorscheme "catppuccin"
vim.opt.number = true
vim.opt.relativenumber = true

-- Activate win32yank for WSL to Windows clipboard syncing
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
  name = 'win32yank-wsl',
  copy = {
    ['+'] = 'win32yank.exe -i --crlf',
    ['*'] = 'win32yank.exe -i --crlf',
  },
  paste = {
    ['+'] = 'win32yank.exe -o --lf',
    ['*'] = 'win32yank.exe -o --lf',
  },
  cache_enabled = 0,
}

-- 5. Plugin Initialization (Ordering is key!)
require('nvim-web-devicons').setup({ default = true })

require("nvim-tree").setup({
  renderer = {
    icons = {
      web_devicons = { file = { enable = true, color = true } },
    },
  },
})

require("gitsigns").setup()
require("Comment").setup()
require("nvim-autopairs").setup()

-- 6. Keybindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', {})

-- F6: Save, Compile (with debug symbols), and Run in a REAL interactive terminal
vim.keymap.set('n', '<F6>', function()
  vim.cmd("w") -- Save the file
  local file = vim.fn.expand("%:p") -- Full path to test.cpp
  local output = vim.fn.expand("%:p:r") -- Full path to executable 'test'
  
  -- Added the -g flag here so it is ALWAYS ready to be debugged!
  local compile_cmd = string.format("g++ -g %s -o %s", file, output)
  vim.fn.system(compile_cmd)
  
  if vim.v.shell_error == 0 then
    vim.cmd("split | term " .. output) -- Open terminal in a split
    vim.cmd("startinsert") -- Put you in 'Type' mode immediately
  else
    print("Compilation Failed!")
  end
end, { desc = "Interactive Compile & Run" })
