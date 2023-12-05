-- Utilities for creating configurations
local util = require 'formatter.util'

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require('formatter').setup {
  -- Enable or disable logging
  logging = true,
  -- Set the log level
  log_level = vim.log.levels.WARN,
  -- All formatter configurations are opt-in
  filetype = {
    -- Formatter configurations for filetype "lua" go here
    -- and will be executed in order
    lua = {
      -- You can also define your own configuration
      function()
        -- Full specification of configurations is down below and in Vim help
        -- files
        return {
          exe = 'stylua',
          args = {
            '--search-parent-directories',
            '--stdin-filepath',
            util.escape_path(util.get_current_buffer_file_path()),
            '--',
            '-',
          },
          stdin = true,
        }
      end,
    },

    -- Web development
    html = {
      require('formatter.filetypes.html').prettier,
    },
    css = {
      require('formatter.filetypes.css').prettier,
    },
    json = {
      require('formatter.filetypes.json').prettier,
    },
    jsonc = {
      require('formatter.filetypes.json').prettier,
    },
    javascript = {
      require('formatter.filetypes.javascript').prettier,
    },
    javascriptreact = {
      require('formatter.filetypes.javascriptreact').prettier,
    },
    typescript = {
      require('formatter.filetypes.typescript').prettier,
    },
    typescriptreact = {
      require('formatter.filetypes.typescriptreact').prettier,
    },
    astro = {
      require('formatter.defaults').prettier,
    },

    -- Python
    python = {
      require('formatter.filetypes.python').black,
    },

    -- Rust
    rust = {
      require('formatter.filetypes.rust').rustfmt,
    },

    -- C++
    cpp = {
      require('formatter.filetypes.cpp').clangformat,
    },
    -- C
    c = {
      require('formatter.filetypes.c').clangformat,
    },

    -- Use the special "*" filetype for defining formatter configurations on
    -- any filetype
    ['*'] = {
      -- "formatter.filetypes.any" defines default configurations for any
      -- filetype
      require('formatter.filetypes.any').remove_trailing_whitespace,
    },
  },
}

vim.keymap.set('n', '<leader>h', vim.cmd.Format, { desc = '[F]ormat current buffer' })

-- Switch for controlling whether you want autoformatting.
-- Use :FormatToggle to toggle autoformatting on or off
local format_is_enabled = true
vim.api.nvim_create_user_command('FormatToggle', function()
  format_is_enabled = not format_is_enabled
  print('Setting autoformatting to: ' .. tostring(format_is_enabled))
end, {})

-- Format on save
local group = vim.api.nvim_create_augroup('formatter.nvim', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*',
  group = group,
  callback = function()
    -- Could check if no errors, but then it wouldn't format if there's an unused variable...
    -- #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }) > 0
    if not format_is_enabled then
      return
    end
    vim.cmd 'FormatWrite'
  end,
})
