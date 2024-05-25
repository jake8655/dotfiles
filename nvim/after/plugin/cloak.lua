local cloak = require 'cloak'

cloak.setup {
  cloak_telescope = true,
}

vim.keymap.set('n', '<leader>;', vim.cmd.CloakToggle)
