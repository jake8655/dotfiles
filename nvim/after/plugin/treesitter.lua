local parsers = { 'javascript', 'typescript', 'tsx', 'c', 'lua', 'vim', 'rust', 'diff', 'haskell', 'python' }

require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath 'data' .. '/site',
}

require('nvim-treesitter').install(parsers)

require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true,
  },
  move = {
    set_jumps = true,
  },
}

vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    -- Start Treesitter for every filetype with an installed parser. Parser
    -- names are not filetypes (e.g. `tsx` is the parser for `typescriptreact`),
    -- so checking for a parser avoids maintaining a separate list.
    local ok, parser = pcall(vim.treesitter.get_parser, ev.buf)
    if not ok or not parser then
      return
    end

    vim.treesitter.start(ev.buf)

    -- Treesitter indentation is experimental and needs the language's
    -- `indents.scm`. Haskell, Vim and diff don't ship one, so keep the
    -- filetype's own indent settings. Haskell gets its indentexpr from
    -- vim-haskell-indent. See after/ftplugin/haskell.lua.
    if vim.treesitter.query.get(parser:lang(), 'indents') then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

vim.keymap.set({ 'x', 'o' }, 'aa', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@parameter.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'ia', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@parameter.inner', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'af', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'if', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'ac', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'ic', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
end)

vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
  require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
  require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
  require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
  require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
  require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
  require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
  require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
  require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer', 'textobjects')
end)

vim.keymap.set('n', '<leader>o', function()
  require('nvim-treesitter-textobjects.swap').swap_next '@parameter.inner'
end)
vim.keymap.set('n', '<leader>O', function()
  require('nvim-treesitter-textobjects.swap').swap_previous '@parameter.inner'
end)
