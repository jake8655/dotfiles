#!/usr/bin/env bash

LAYOUT="$HOME/.dotfiles/wlogout/layout"
STYLE="$HOME/.dotfiles/wlogout/style.css"

if [[ ! `pidof wlogout` ]]; then
    wlogout --layout ${LAYOUT} --css ${STYLE} \
        --buttons-per-row 3 \
        --column-spacing 50 \
        --row-spacing 50 \
        --margin-top 290 \
        --margin-bottom 290 \
        --margin-left 300 \
        --margin-right 300
else
    pkill wlogout
fi
