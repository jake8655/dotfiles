local lint = require 'lint'

-- Plain `mypy` (and anything shelling out to it, e.g. edulint helpers) drops
-- `.mypy_cache/` into the cwd by default. Point it at a central location for
-- anything spawned from Neovim; the dmypy override below passes an explicit
-- --cache-dir which takes precedence for dmypy itself.
if vim.env.MYPY_CACHE_DIR == nil or vim.env.MYPY_CACHE_DIR == '' then
  vim.env.MYPY_CACHE_DIR = vim.fs.joinpath(vim.fn.stdpath 'cache', 'mypy')
end

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

-- Keep dmypy artifacts out of project directories.
-- By default dmypy drops `.dmypy.json` (status file) and `.mypy_cache/`
-- into whatever directory it runs in (here: Neovim's cwd), littering every
-- project. Redirect both under stdpath('cache')/dmypy/<cwd-key>/, keeping
-- one daemon+cache per cwd but in a central location.
local function dmypy_base_dir()
  local cwd = vim.fn.getcwd()
  local key = cwd:gsub('[^%w%.%-_]', '_'):gsub('_+', '_'):gsub('^_', ''):gsub('_$', '')
  if key == '' then
    key = 'root'
  end
  local base = vim.fs.joinpath(vim.fn.stdpath 'cache', 'dmypy', key)
  vim.fn.mkdir(base, 'p')
  return base
end

local function dmypy_status_file()
  return vim.fs.joinpath(dmypy_base_dir(), 'dmypy.json')
end

local function dmypy_cache_dir()
  return vim.fs.joinpath(dmypy_base_dir(), 'mypy_cache')
end

local dmypy = require 'lint.linters.dmypy'
dmypy.args = {
  '--status-file',
  dmypy_status_file,
  'run',
  '--timeout',
  '50000',
  '--',
  '--show-column-numbers',
  '--show-error-end',
  '--hide-error-context',
  '--no-color-output',
  '--no-error-summary',
  '--no-pretty',
  '--python-executable',
  function()
    return vim.fn.exepath 'python3' or vim.fn.exepath 'python'
  end,
  '--cache-dir',
  dmypy_cache_dir,
}
lint.linters.dmypy = dmypy

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
  group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
  callback = function()
    require('lint').try_lint()
  end,
})
vim.keymap.set('n', '<leader>l', function()
  require('lint').try_lint()
end, { desc = 'Lint buffer' })
