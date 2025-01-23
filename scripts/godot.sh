#!/bin/bash
nvim --server ~/.cache/nvim/godot.pipe --remote-send "<esc>:n $1<CR>:call cursor($2,$3)<CR>"
