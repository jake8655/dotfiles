-- Initialize lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require('lazy').setup({
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
    -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  -- Colorscheme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha',
        transparent_background = true,
      }
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  -- Miscellaneous
  { 'ThePrimeagen/harpoon' },
  {
    'mbbill/undotree',
    config = function()
      vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
    end,
  },
  {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup {
        keymaps = {
          accept_suggestion = '<C-l>',
        },
      }
    end,
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
  },
  { 'arkav/lualine-lsp-progress' },

  -- Autotype paranthesis pairs
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup { map_c_h = true }
    end,
  },

  -- Autotype HTML tag pairs
  {
    'windwp/nvim-ts-autotag',
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-ts-autotag').setup {}
    end,
  },

  -- Rename both HTML tags
  { 'AndrewRadev/tagalong.vim' },

  -- Change surrounding quotes...
  { 'tpope/vim-surround' },

  -- Commenting shortcuts
  { 'numToStr/Comment.nvim', opts = {}, branch = 'jsx' },

  -- Startup screen
  {
    'startup-nvim/startup.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
    config = function()
      require('startup').setup {}
    end,
  },

  -- Colorful background of color words
  -- Would be cool but doesnt work fsr (termguicolors must be set)
  -- { "norcalli/nvim-colorizer.lua" },

  {
    -- LSP
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',

      -- Crates.io utilities
      {
        'nvimtools/none-ls.nvim',
        config = function()
          require('null-ls').setup {}
        end,
      },
      {
        'saecki/crates.nvim',
        tag = 'stable',
        dependencies = {
          'nvimtools/none-ls.nvim',
        },
      },

      -- Code formatter
      'mhartington/formatter.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
  },

  {
    -- Lines indicating when inside function/condition... blocks
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    main = 'ibl',
    opts = {},
  },

  {
    'iamcco/markdown-preview.nvim',
    config = function()
      vim.fn['mkdp#util#install']()
    end,
  },

  -- Practice vim commands
  'ThePrimeagen/vim-be-good',

  -- Hide env variables
  'laytan/cloak.nvim',

  -- require 'kickstart.plugins.autoformat',
}, {
  ui = { border = 'rounded' },
})
