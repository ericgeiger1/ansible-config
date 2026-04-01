-- 1. Leader Key
vim.g.mapleader = " "

-- 2. Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Plugins Setup
require("lazy").setup({
  -- Appearance & UI
  { 
    "catppuccin/nvim", 
    name = "catppuccin", 
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end
  },
  "nvim-tree/nvim-web-devicons",
  
  {
    "lewis6991/gitsigns.nvim",
    opts = {} -- Replaces require('gitsigns').setup() at the bottom
  },
  
  -- File Navigation
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        renderer = {
          icons = { web_devicons = { file = { enable = true, color = true } } },
        },
      })
    end
  },
  {
    'stevearc/oil.nvim',
    opts = { view_options = { show_hidden = true } },
    config = function(_, opts)
      require("oil").setup(opts)
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    end
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
    },
  },

  -- Statusline with Custom Theme
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local my_colors = {
        blue   = '#1904d4', green  = '#01bd29', purple = '#5f0057',
        teal   = '#045658', black  = '#1c1c1c', white  = '#ffffff',
        orange = '#ff5f00',
      }
      local my_theme = {
        normal  = { a = { fg = my_colors.white, bg = my_colors.blue, gui = 'bold' }, b = { fg = my_colors.white, bg = my_colors.blue }, c = { fg = my_colors.white, bg = my_colors.blue } },
        insert  = { a = { fg = my_colors.white, bg = my_colors.green, gui = 'bold' }, b = { fg = my_colors.white, bg = my_colors.green }, c = { fg = my_colors.white, bg = my_colors.green } },
        visual  = { a = { fg = my_colors.white, bg = my_colors.purple, gui = 'bold' }, b = { fg = my_colors.white, bg = my_colors.purple }, c = { fg = my_colors.white, bg = my_colors.purple } },
        replace = { a = { fg = my_colors.white, bg = my_colors.orange, gui = 'bold' }, b = { fg = my_colors.white, bg = my_colors.orange }, c = { fg = my_colors.white, bg = my_colors.orange } },
        command = { a = { fg = my_colors.white, bg = my_colors.teal, gui = 'bold' }, b = { fg = my_colors.white, bg = my_colors.teal }, c = { fg = my_colors.white, bg = my_colors.teal } },
      }
      require('lualine').setup({
        options = {
          theme = my_theme,
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
        }
      })
    end
  },

  -- Search & Utilities
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "windwp/nvim-autopairs", opts = {} },
  { "numToStr/Comment.nvim", opts = {} },
  "ThePrimeagen/vim-be-good",
  { 'akinsho/toggleterm.nvim', version = "*", opts = {} },

  -- Treesitter (FIXED: Added configuration for syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "svelte", "javascript", "bash" },
        auto_install = true,
        highlight = { enable = true },
      })
    end
  },

  -- LSP, Snippets, & Completion
  {
    "williamboman/mason.nvim",
    dependencies = { 
      "williamboman/mason-lspconfig.nvim", 
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({ ensure_installed = { "clangd", "lua_ls", "gopls", "ansiblels" } })

      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local servers = { "clangd", "lua_ls", "gopls", "ansiblels" }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({ capabilities = capabilities })
      end

      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { 'i', 's' }),
        }),
        sources = { { name = 'nvim_lsp' }, { name = 'luasnip' } }
      })
    end
  },

  -- Debugger Setup
  {
    "mfussenegger/nvim-dap",
    dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      
      dap.adapters.cppdbg = {
        id = 'cppdbg', type = 'executable',
        command = vim.fn.stdpath("data") .. '/mason/bin/OpenDebugAD7',
      }
      dap.configurations.cpp = {
        {
          name = "Launch executable", type = "cppdbg", request = "launch",
          program = function() return vim.fn.input('Path: ', vim.fn.getcwd() .. '/', 'file') end,
          cwd = '${workspaceFolder}', stopAtEntry = true,
        },
      }
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Start Debugger' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint' })
    end
  },
})

-- 4. Settings & UI
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

-- Diagnostic Signs Setup
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

-- 5. Extra Logic & Keybindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', {})
vim.keymap.set('i', '<C-l>', '<Esc>A')

-- Restored Diagnostic Navigation (Jump to Errors)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to prev error' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next error' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show error detail' })

-- F6: Compile and Run C++
vim.keymap.set('n', '<F6>', function()
  vim.cmd("w")
  local file = vim.fn.expand("%:p")
  local output = vim.fn.expand("%:p:r")
  vim.fn.system(string.format("g++ -g %s -o %s", file, output))
  if vim.v.shell_error == 0 then
    vim.cmd("split | term " .. output)
    vim.cmd("startinsert")
  else
    vim.cmd("copen")
    print("Compilation Failed! Check errors above.")
  end
end, { desc = "Interactive Compile & Run" })

-- Restored Auto-commands
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = "[^l]*",
    command = "cwindow",
})
