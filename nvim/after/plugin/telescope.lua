local builtin = require 'telescope.builtin'

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

require('telescope').setup {
  defaults = {
    file_ignore_patterns = {
      'node_modules/',
      '.git/',
      '.next/',
      'target/',
      'dist/',
      'build/',
      '.cargo/',
      'bun.lock',
      'package-lock.json',
      'yarn.lock',
      '.turbo/',
      '.react-router/',
      '.godot/',
      'assets/',
      '.expo/',
    },
  },
}

vim.keymap.set('n', '<leader>f', function()
  builtin.find_files {
    hidden = true,
    no_ignore = true,
  }
end, {})
vim.keymap.set('n', '<leader><leader>', builtin.resume)
vim.keymap.set('n', '<leader>ld', function()
  builtin.diagnostics { bufnr = 0 }
end)
vim.keymap.set('n', '<leader>ln', builtin.diagnostics)
vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>lg', builtin.live_grep, { desc = 'Search by [L]ive [G]rep' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Find existing [B]uffers' })
