local lint = require 'lint'

lint.linters.edulint = {
  cmd = 'edulint',
  stdin = false, -- filename auto-appended, lints file on disk
  args = { 'check', '--json', '--disable-version-check', '--disable-explanations-update' },
  ignore_exitcode = true,
  stream = 'stdout',
  parser = function(output, bufnr)
    if not output or output == '' then
      return {}
    end
    local ok, decoded = pcall(vim.json.decode, output)
    if not ok or type(decoded) ~= 'table' then
      return {}
    end
    local out, bufname = {}, vim.api.nvim_buf_get_name(bufnr)
    for _, p in ipairs(decoded.problems or {}) do
      if p.path == bufname then
        -- pylint cols are 0-based, flake8 cols are 1-based
        local col = p.source == 'pylint' and (p.column or 0) or math.max(0, (p.column or 1) - 1)
        local sev = vim.diagnostic.severity.WARN
        if p.code and p.code:match '^[EF]' then
          sev = vim.diagnostic.severity.ERROR
        end
        table.insert(out, {
          lnum = math.max(0, (p.line or 1) - 1),
          col = col,
          end_lnum = p.end_line and (p.end_line - 1) or nil,
          end_col = p.end_column or nil,
          message = string.format('%s %s', p.code or '', p.text or ''),
          source = 'edulint:' .. (p.source or ''),
          severity = sev,
        })
      end
    end
    return out
  end,
}

lint.linters_by_ft = { python = { 'dmypy', 'edulint' } }

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
  group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
  callback = function()
    require('lint').try_lint()
  end,
})
vim.keymap.set('n', '<leader>l', function()
  require('lint').try_lint()
end, { desc = 'Lint buffer' })
