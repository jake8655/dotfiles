#!/bin/bash

swayidle -w \
timeout 60 'hyprctl dispatch dpms off' \
timeout 80 'waylock -fork-on-lock' \
timeout 100 'loginctl suspend' \
resume 'hyprctl dispatch dpms on' \
before-sleep 'waylock -fork-on-lock'
