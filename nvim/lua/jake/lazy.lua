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

  -- Comments
  {
    'folke/ts-comments.nvim',
    opts = {},
    event = 'VeryLazy',
    enabled = vim.fn.has 'nvim-0.10.0' == 1,
  },

  -- Startup screen
  {
    'startup-nvim/startup.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
    config = function()
      ---@diagnostic disable-next-line: missing-parameter
      require('startup').setup()
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
      { 'williamboman/mason.nvim', config = true, commit = 'fc98833b6da5de5a9c5b1446ac541577059555be' },
      { 'williamboman/mason-lspconfig.nvim', commit = '1a31f824b9cd5bc6f342fc29e9a53b60d74af245' },

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
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { '<leader>g', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },

  {
    -- Lines indicating when inside function/condition... blocks
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    main = 'ibl',
    opts = {},
  },

  -- Markdown preview
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },

  -- Practice vim commands
  'ThePrimeagen/vim-be-good',

  -- Hide env variables
  'laytan/cloak.nvim',

  -- Clipboard history
  'royanirudd/clipboard-history.nvim',

  -- Curosr.ai
  -- {
  --   'yetone/avante.nvim',
  --   event = 'VeryLazy',
  --   lazy = false,
  --   version = false, -- set this if you want to always pull the latest change
  --   opts = {
  --     provider = 'copilot',
  --   },
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   build = 'make',
  --   -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  --   dependencies = {
  --     'stevearc/dressing.nvim',
  --     'nvim-lua/plenary.nvim',
  --     'MunifTanjim/nui.nvim',
  --     --- The below dependencies are optional,
  --     'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
  --     'zbirenbaum/copilot.lua', -- for providers='copilot'
  --     {
  --       -- support for image pasting
  --       'HakonHarnes/img-clip.nvim',
  --       event = 'VeryLazy',
  --       opts = {
  --         -- recommended settings
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           -- required for Windows users
  --           use_absolute_path = true,
  --         },
  --       },
  --     },
  --     {
  --       -- Make sure to set this up properly if you have lazy=true
  --       'MeanderingProgrammer/render-markdown.nvim',
  --       opts = {
  --         file_types = { 'markdown', 'Avante' },
  --       },
  --       ft = { 'markdown', 'Avante' },
  --     },
  --   },
  -- },

  -- Merge conflicts
  { 'akinsho/git-conflict.nvim', version = '*', config = true },

  -- AI agent
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('codecompanion').setup {
        strategies = {
          chat = {
            keymaps = {
              close = {
                modes = { n = '<C-t>', i = '<C-t>' },
              },
            },
          },
        },
      }
    end,
  },

  -- require 'kickstart.plugins.autoformat',
  ---@diagnostic disable-next-line: missing-fields
}, {
  ui = { border = 'rounded' },
})
