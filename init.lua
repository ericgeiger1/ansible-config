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
  "ThePrimeagen/vim-be-good",

  {
    'akinsho/toggleterm.nvim', 
    version = "*", 
    config = true
  },

{
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Define your custom cybersecurity-style colors
    local my_colors = {
      blue   = '#1904d4',
      green  = '#01bd29',
      purple = '#5f0057',
      teal   = '#045658',
      black  = '#1c1c1c',
      white  = '#ffffff',
      orange = '#ff5f00',
    }

   local my_theme = {
  normal = {
    a = { fg = my_colors.white, bg = my_colors.blue, gui = 'bold' },
    b = { fg = my_colors.white, bg = my_colors.blue }, -- Changed to blue
    c = { fg = my_colors.white, bg = my_colors.blue }, -- The "Whole Bar" color
  },
  insert = {
    a = { fg = my_colors.white, bg = my_colors.green, gui = 'bold' },
    b = { fg = my_colors.white, bg = my_colors.green },
    c = { fg = my_colors.white, bg = my_colors.green },
  },
  visual = {
    a = { fg = my_colors.white, bg = my_colors.purple, gui = 'bold' },
    b = { fg = my_colors.white, bg = my_colors.purple },
    c = { fg = my_colors.white, bg = my_colors.purple },
  },
  replace = { -- New mode added here
    a = { fg = my_colors.white, bg = my_colors.orange, gui = 'bold' }, -- Vibrant orange
    b = { fg = my_colors.white, bg = my_colors.orange },
    c = { fg = my_colors.white, bg = my_colors.orange },
  },
  command = {
    a = { fg = my_colors.white, bg = my_colors.teal, gui = 'bold' },
    b = { fg = my_colors.white, bg = my_colors.teal },
    c = { fg = my_colors.white, bg = my_colors.teal },
  },
}

    require('lualine').setup({
      options = {
        theme = my_theme, -- This tells Lualine to use your colors above
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      }
    })
  end
},

  {
    "williamboman/mason.nvim",
    dependencies = { "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({ 
        ensure_installed = { "clangd", "ansiblels", "lua_ls", "gopls" } 
      })

      -- This is the "New Native API" way to enable servers
      vim.lsp.enable('clangd')
      vim.lsp.enable('lua_ls')
      vim.lsp.enable('gopls')
      vim.lsp.enable('ansiblels')
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

      dapui.setup()
      
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = vim.fn.stdpath("data") .. '/mason/bin/OpenDebugAD7',
      }

      dap.configurations.cpp = {
        {
          name = "Launch executable",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = true,
          setupCommands = {  
            { text = '-enable-pretty-printing', description =  'enable pretty printing', ignoreFailures = false },
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
vim.opt.clipboard = "unnamedplus"

-- Diagnostic / Error Signs (E and W)
vim.diagnostic.config({
  virtual_text = true, 
  signs = true,        
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- WSL Clipboard Fix
vim.opt.clipboard = "unnamedplus"

-- 5. Plugin Initialization
require('nvim-web-devicons').setup({ default = true })
require("nvim-tree").setup({
  renderer = {
    icons = { web_devicons = { file = { enable = true, color = true } } },
  },
})
require("gitsigns").setup()
require("Comment").setup()
require("nvim-autopairs").setup()

-- 6. Keybindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', {})

-- Diagnostic Navigation (Jump to Errors)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to prev error' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next error' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show error detail' })

-- F6: Save, Compile (with debug symbols), and Run
vim.keymap.set('n', '<F6>', function()
  vim.cmd("w") 
  local file = vim.fn.expand("%:p") 
  local output = vim.fn.expand("%:p:r") 
  
  local compile_cmd = string.format("g++ -g %s -o %s", file, output)
  vim.fn.system(compile_cmd)
  
  if vim.v.shell_error == 0 then
    vim.cmd("split | term " .. output) 
    vim.cmd("startinsert") 
  else
    -- If compilation fails, open the Quickfix window to show why
    vim.cmd("copen")
    print("Compilation Failed! Check errors above.")
  end
end, { desc = "Interactive Compile & Run" })

-- 7. Auto-commands
-- Open Quickfix window automatically on errors
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = "[^l]*",
    command = "cwindow",
})

-- Move to end of line in Insert Mode with Ctrl+l
vim.keymap.set('i', '<C-l>', '<Esc>A')

-- If using lazy.nvim

