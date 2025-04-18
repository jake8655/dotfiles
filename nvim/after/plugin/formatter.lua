-- Utilities for creating configurations
local util = require 'formatter.util'

---@param fileNames table<integer, string>
local function areFilesPresentInCWD(fileNames)
  local cwDir = vim.fn.getcwd()

  -- Get all files and directories in CWD
  local cwdContent = vim.split(vim.fn.glob(cwDir .. '/*'), '\n', { trimempty = true })

  -- Check if specified file or directory exists
  local fullNamesToCheck = {}
  for _, fileName in pairs(fileNames) do
    table.insert(fullNamesToCheck, cwDir .. '/' .. fileName)
  end

  for _, cwdItem in pairs(cwdContent) do
    for _, fullNameToCheck in pairs(fullNamesToCheck) do
      if cwdItem == fullNameToCheck then
        return true
      end
    end
  end
  return false
end

local WEB_LANGUAGES = { 'html', 'css', 'json', { 'jsonc', 'json' }, 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', { 'astro', 'defaults' } }
local BIOME_CONFIG = { 'biome.json', 'biome.jsonc' }

---@param lang string
local function prettierOrBiome(lang)
  if areFilesPresentInCWD(BIOME_CONFIG) then
    if lang == 'defaults' then
      return require('formatter.' .. lang).biome
    else
      return require('formatter.filetypes.' .. lang).biome
    end
  else
    if lang == 'defaults' then
      return require('formatter.' .. lang).prettier
    else
      return require('formatter.filetypes.' .. lang).prettier
    end
  end
end

local web_langs_config = {}
for _, lang in pairs(WEB_LANGUAGES) do
  if type(lang) == 'table' then
    web_langs_config[lang[1]] = prettierOrBiome(lang[2])
  else
    web_langs_config[lang] = prettierOrBiome(lang)
  end
end

---@param table1 table
---@param table2 table
local function spread(table1, table2)
  local result = {}
  for k, v in pairs(table1) do
    result[k] = v
  end
  for k, v in pairs(table2) do
    result[k] = v
  end
  return result
end

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require('formatter').setup {
  -- Enable or disable logging
  logging = true,
  -- Set the log level
  log_level = vim.log.levels.WARN,
  -- All formatter configurations are opt-in
  filetype = spread({
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

    python = {
      require('formatter.filetypes.python').black,
    },

    rust = {
      require('formatter.filetypes.rust').rustfmt,
    },

    go = {
      require('formatter.filetypes.go').gofumpt,
    },

    cpp = {
      require('formatter.filetypes.cpp').clangformat,
    },
    c = {
      require('formatter.filetypes.c').clangformat,
    },

    toml = {
      require('formatter.filetypes.toml').taplo,
    },

    gdscript = {
      function()
        return {
          exe = 'gdformat',
          stdin = false,
        }
      end,
    },

    java = {
      require('formatter.filetypes.java').google_java_format,
    },

    -- Use the special "*" filetype for defining formatter configurations on
    -- any filetype
    ['*'] = {
      -- "formatter.filetypes.any" defines default configurations for any
      -- filetype
      require('formatter.filetypes.any').remove_trailing_whitespace,
    },
  }, web_langs_config),
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

local bun_group = vim.api.nvim_create_augroup('bun', { clear = true })
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = 'bun.lock',
  group = bun_group,
  callback = function()
    vim.bo.filetype = 'jsonc'
  end,
})
