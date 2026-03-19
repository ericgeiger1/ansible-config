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
    "williamboman/mason.nvim",
    dependencies = { "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({ ensure_installed = { "clangd", "ansiblels", "lua_ls" } })
    end
  },
})

-- 4. Global Settings
vim.opt.termguicolors = true
vim.cmd.colorscheme "catppuccin"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

-- 5. Plugin Initialization (Ordering is key!)
-- Setup icons FIRST
require('nvim-web-devicons').setup({
  default = true,
})

-- Setup nvim-tree SECOND
require("nvim-tree").setup({
  renderer = {
    icons = {
      web_devicons = {
        file = { enable = true, color = true },
      },
    },
  },
})

-- Setup others
require("gitsigns").setup()
require("Comment").setup()
require("nvim-autopairs").setup()

-- 6. Keybindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', {})
vim.keymap.set('n', '<F5>', ':w | !g++ % -o %:r && ./%:r; echo; read -p "Press Enter to return to Neovim..."<CR>', { desc = "Compile & Run" })
