-- General configset
vim.o.guicursor = ''
vim.o.mouse = ''

vim.o.exrc = true
vim.o.hlsearch = false
vim.o.hidden = true
vim.o.errorbells = false

-- Line Numbers
vim.o.rnu = true
vim.o.nu = true

-- Tabs and indenting
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.smartindent = true
vim.o.wrap = false

-- Searching
vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.incsearch = true

-- File stuff
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv 'HOME' .. '/.vim/undodir'
vim.o.undofile = true

-- Colors
vim.o.termguicolors = true

-- Scrolling
vim.o.scrolloff = 8

-- Modes
vim.o.showmode = false

-- Autocomplete
vim.o.completeopt = 'menuone,noinsert,noselect'

-- TODO: Re-enable when https://github.com/nvim-lua/plenary.nvim/pull/649 is merged
-- Rounded borders for all floating windows
-- vim.o.winborder = 'rounded'

-- Random
vim.o.updatetime = 50
vim.o.timeoutlen = 500
vim.opt.shortmess:append 'c'
vim.opt.isfname:append '@-@'

-- Space for LSP messages
vim.o.signcolumn = 'yes'

-- Sync MacOS clipboard with Neovim clipboard
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Set filetype of justfiles
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('SetJustfile', { clear = true }),
  pattern = 'justfile',
  callback = function()
    vim.bo.filetype = 'just'
  end,
})

-- Highlight current line
vim.o.cursorline = true
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#EE8F6A', bold = true })
