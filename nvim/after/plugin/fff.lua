local fff = require 'fff'

local function project_root()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  local start = buffer_path ~= '' and buffer_path or vim.fn.getcwd()
  return vim.fs.root(start, '.git') or vim.fn.getcwd()
end

vim.keymap.set('n', '<leader>f', function()
  fff.find_files { cwd = project_root() }
end, { desc = 'Find files' })

vim.keymap.set('n', '<leader><leader>', function()
  if not fff.resume() then
    Snacks.picker.resume()
  end
end, { desc = 'Resume last picker' })

vim.keymap.set('n', '<leader>ld', Snacks.picker.diagnostics_buffer, { desc = 'Buffer diagnostics' })
vim.keymap.set('n', '<leader>ln', Snacks.picker.diagnostics, { desc = 'Workspace diagnostics' })
vim.keymap.set('n', '<leader>/', Snacks.picker.lines, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>lg', function()
  fff.live_grep { cwd = project_root() }
end, { desc = 'Search by [L]ive [G]rep' })

vim.keymap.set('n', '<leader>b', Snacks.picker.buffers, { desc = 'Find existing [B]uffers' })
