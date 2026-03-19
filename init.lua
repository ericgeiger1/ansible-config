-- 1. SET LEADER KEY (CRITICAL: Must be at the very top)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 2. BOOTSTRAP: Install Lazy.nvim if missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 3. PLUGINS
require("lazy").setup({
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  "nvim-tree/nvim-tree.lua",
  "nvim-lualine/lualine.nvim",
  "nvim-treesitter/nvim-treesitter",
  "nvim-telescope/telescope.nvim",
  "nvim-lua/plenary.nvim",
  "lewis6991/gitsigns.nvim",      -- Shows changes in the "Sign Column"
  "windwp/nvim-autopairs",        -- The {} () auto-closer
  "numToStr/Comment.nvim",        -- Use 'gcc' to comment/uncomment lines
  
  -- LSP & Mason
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "ansiblels", "lua_ls" }
      })
      
      -- Native 0.12 LSP
      vim.lsp.config('clangd', {})
      vim.lsp.config('ansiblels', {})
      vim.lsp.config('lua_ls', {})
      
      vim.lsp.enable('clangd')
      vim.lsp.enable('ansiblels')
      vim.lsp.enable('lua_ls')
    end
  },
})

-- 4. BASIC SETTINGS & UI
vim.cmd.colorscheme "catppuccin"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"        -- Keep space for error/warning icons
vim.opt.cursorline = true         -- Highlight the current line
vim.opt.shiftwidth = 4            -- Standard C++ indentation
vim.opt.tabstop = 4
vim.opt.clipboard = "unnamedplus" -- Sync with Windows clipboard (via win32yank)

-- Initialize Plugin Settings
require("nvim-tree").setup()
require("gitsigns").setup()
require("Comment").setup()
require("nvim-autopairs").setup({
    check_ts = true,
    fast_wrap = {},               -- Allows wrapping words with Alt + e
})

-- 5. KEYBINDINGS
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find Files" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Search Text" })
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { desc = "Toggle Sidebar" })

-- F5: Save, Compile, and Run C++
vim.keymap.set('n', '<F5>', ':w | !g++ % -o %:r && ./%:r<CR>', { desc = "Compile & Run" })
