local bun_group = vim.api.nvim_create_augroup('bun', { clear = true })
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = 'bun.lock',
  group = bun_group,
  callback = function()
    vim.bo.filetype = 'jsonc'
  end,
})
