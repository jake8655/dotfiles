#!/bin/bash

song_info=$(playerctl metadata --format '{{title}}      {{artist}}' status 2>/dev/null)

echo "$song_info"
