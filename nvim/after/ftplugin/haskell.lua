-- Haskell layout (do/where/let/of) is whitespace-sensitive.
-- Never use tabs: GHC treats them as 8-wide and fourmolu/HLS expect spaces.
-- fourmolu defaults to 4-space indent; keep editor in sync.
vim.bo.expandtab = true
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4

-- smartindent is C-style and actively breaks Haskell layout.
-- Neovim ships no indent/haskell.vim and Treesitter has no Haskell
-- indents.scm, so vim-haskell-indent supplies indentexpr. fourmolu still owns
-- whole-file layout on save (:ConformInfo / <leader>h).
vim.bo.smartindent = false
vim.bo.autoindent = true

-- Indent case alternatives by one shiftwidth (fourmolu style) instead of
-- aligning them under the scrutinee.
vim.g.haskell_indent_disable_case = 1
