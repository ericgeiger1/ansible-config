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

-- F5: Save, Compile, and Run in a REAL interactive terminal
vim.keymap.set('n', '<F5>', function()
  vim.cmd("w") -- Save the file
  local file = vim.fn.expand("%:p") -- Full path to test.cpp
  local output = vim.fn.expand("%:p:r") -- Full path to executable 'test'
  
  -- Compile and then open a terminal to run it
  local compile_cmd = string.format("g++ %s -o %s", file, output)
  vim.fn.system(compile_cmd)
  
  if vim.v.shell_error == 0 then
    vim.cmd("split | term " .. output) -- Open terminal in a split
    vim.cmd("startinsert") -- Put you in 'Type' mode immediately
  else
    print("Compilation Failed!")
  end
end, { desc = "Interactive Compile & Run" })
