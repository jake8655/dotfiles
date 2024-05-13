local cloak = require 'cloak'

cloak.setup {}

vim.keymap.set('n', '<leader>;', vim.cmd.CloakToggle)
