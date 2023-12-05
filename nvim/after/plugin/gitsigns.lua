local gs = require 'gitsigns'

gs.setup {
  -- See `:help gitsigns.txt`
  current_line_blame = true,
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = '[H]unk [P]review' })
    vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = '[H]unk [S]tage' })
    vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = '[H]unk [U]ndo' })
    vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = '[H]unk [R]eset' })
    vim.keymap.set('n', '<leader>hd', function()
      gs.diffthis '~'
    end, { buffer = bufnr, desc = '[H]unk [D]iff' })
    vim.keymap.set('n', '<leader>hb', function()
      gs.blame_line { full = true }
    end, { buffer = bufnr, desc = '[H]unk [B]lame' })

    -- don't override the built-in and fugitive keymaps
    vim.keymap.set({ 'n', 'v' }, ']c', function()
      if vim.wo.diff then
        return ']c'
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return '<Ignore>'
    end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
    vim.keymap.set({ 'n', 'v' }, '[c', function()
      if vim.wo.diff then
        return '[c'
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return '<Ignore>'
    end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
  end,
}
