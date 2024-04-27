-- General configset
vim.opt.guicursor = ''
vim.opt.mouse = ''

vim.opt.exrc = true
vim.opt.hlsearch = false
vim.opt.hidden = true
vim.opt.errorbells = false

-- Line Numbers
vim.opt.rnu = true
vim.opt.nu = true

-- Tabs and indenting
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.wrap = false

-- Searching
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.incsearch = true

-- File stuff
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv 'HOME' .. '/.vim/undodir'
vim.opt.undofile = true

-- Colors
vim.opt.termguicolors = true

-- Scrolling
vim.opt.scrolloff = 8

-- Modes
vim.opt.showmode = false

-- Autocomplete
vim.opt.completeopt = 'menuone,noinsert,noselect'

-- Random
vim.opt.updatetime = 50
vim.o.timeoutlen = 500
vim.opt.shortmess:append 'c'
vim.opt.isfname:append '@-@'

-- Space for LSP messages
vim.opt.signcolumn = 'yes'

-- Sync MacOS clipboard with Neovim clipboard
vim.opt.clipboard:append { 'unnamedplus' }

-- Set filetype of justfiles
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('SetJustfile', { clear = true }),
  pattern = 'justfile',
  callback = function()
    vim.bo.filetype = 'just'
  end,
})
