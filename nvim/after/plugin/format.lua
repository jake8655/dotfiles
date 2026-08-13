local utils = require 'jake.utils'

local bun_group = vim.api.nvim_create_augroup('bun', { clear = true })
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = 'bun.lock',
  group = bun_group,
  callback = function()
    vim.bo.filetype = 'jsonc'
  end,
})

local formatters_by_ft = {
  lua = { 'stylua' },
  python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
  rust = { 'rustfmt' },
  go = { 'gofumpt' },
  cpp = { 'clang-format' },
  c = { 'clang-format' },
  toml = { 'taplo' },
  gdscript = { 'gdformat' },
  java = { 'google-java-format' },
  cs = { 'csharpier' },
  -- ['*'] = { 'codespell' },
  ['_'] = { 'trim_whitespace' },
  -- Conform can also run multiple formatters sequentially
  -- python = { "isort", "black" },
  --
  -- You can use 'stop_after_first' to run the first available formatter from the list
  -- javascript = { "prettierd", "prettier", stop_after_first = true },
}

---@param bufnr integer
---@return conform.FiletypeFormatter
local function web_formatters(bufnr)
  if utils.webToolchain(bufnr) == 'ox' then
    return {
      lsp_format = 'prefer',
      name = 'oxfmt',
    }
  end
  return { 'biome-check' }
end

for _, filetype in ipairs {
  'html',
  'css',
  'json',
  'jsonc',
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'astro',
} do
  formatters_by_ft[filetype] = web_formatters
end

local conform = require 'conform'

conform.setup {
  notify_on_error = false,
  default_format_opts = {
    lsp_format = 'fallback',
  },
  format_on_save = function(bufnr)
    -- Disable "format_on_save lsp_fallback" for languages that don't
    -- have a well standardized coding style. You can add additional
    -- languages here or re-enable it for the disabled ones.
    local disable_filetypes = { c = true, cpp = true, plaintex = true, tex = true, text = true }
    if vim.g.disable_autoformat or disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    end

    -- Disable autoformat for files in a certain path
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname:match '/node_modules/' then
      return
    end

    return {
      timeout_ms = 2000,
    }
  end,

  formatters_by_ft = formatters_by_ft,

  formatters = {
    ['biome-check'] = {
      append_args = { '--unsafe' },
    },
  },
}

vim.api.nvim_create_user_command('FormatDisable', function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})
vim.api.nvim_create_user_command('FormatEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = 'Re-enable autoformat-on-save',
})
