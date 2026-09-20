-- Haskell layout (do/where/let/of) is whitespace-sensitive.
-- Never use tabs: GHC treats them as 8-wide and fourmolu/HLS expect spaces.
-- fourmolu defaults to 4-space indent; keep editor in sync.
vim.bo.expandtab = true
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4

-- smartindent is C-style and actively breaks Haskell layout.
-- There is no bundled indent/haskell.vim and no treesitter indents.scm
-- for Haskell, so rely on manual layout + fourmolu (:ConformInfo / <leader>h).
vim.bo.smartindent = false
vim.bo.autoindent = true
vim.bo.indentexpr = ''
