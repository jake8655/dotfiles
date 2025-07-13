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
  python = { 'black' },
  rust = { 'rustfmt' },
  go = { 'gofumpt' },
  cpp = { 'clang-format' },
  c = { 'clang-format' },
  toml = { 'taplo' },
  gdscript = { 'gdformat' },
  java = { 'google-java-format' },
  html = { 'biome', 'biome-check' },
  css = { 'biome', 'biome-check' },
  json = { 'biome', 'biome-check' },
  jsonc = { 'biome', 'biome-check' },
  javascript = { 'biome', 'biome-check' },
  javascriptreact = { 'biome', 'biome-check' },
  typescript = { 'biome', 'biome-check' },
  typescriptreact = { 'biome', 'biome-check' },
  astro = { 'biome', 'biome-check' },
  ['*'] = { 'codespell' },
  ['_'] = { 'trim_whitespace' },
  -- Conform can also run multiple formatters sequentially
  -- python = { "isort", "black" },
  --
  -- You can use 'stop_after_first' to run the first available formatter from the list
  -- javascript = { "prettierd", "prettier", stop_after_first = true },
}

if utils.areFilesPresentInCWD(utils.PRETTIER_CONFIG) then
  formatters_by_ft.javascript = { 'prettierd' }
  formatters_by_ft.javascriptreact = { 'prettierd' }
  formatters_by_ft.typescript = { 'prettierd' }
  formatters_by_ft.typescriptreact = { 'prettierd' }
  formatters_by_ft.html = { 'prettierd' }
  formatters_by_ft.css = { 'prettierd' }
end

local conform = require 'conform'

conform.setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- Disable "format_on_save lsp_fallback" for languages that don't
    -- have a well standardized coding style. You can add additional
    -- languages here or re-enable it for the disabled ones.
    local disable_filetypes = { c = true, cpp = true, plaintex = true, tex = true }
    if vim.g.disable_autoformat or disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    end

    -- Disable autoformat for files in a certain path
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname:match '/node_modules/' then
      return
    end

    return {
      timeout_ms = 500,
      lsp_format = 'fallback',
    }
  end,

  formatters_by_ft = formatters_by_ft,
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
