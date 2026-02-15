#!/bin/bash
# Startup script for niri

LOG_FILE="/tmp/niri-startup.log"

# Clear log
echo "=== Niri Startup Log $(date) ===" > "$LOG_FILE"

# D-Bus environment (needed first, no delay)
echo "[$(date '+%H:%M:%S')] Setting up D-Bus environment" >> "$LOG_FILE"
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Start swww-daemon first (needed for wallpaper)
echo "[$(date '+%H:%M:%S')] Starting swww-daemon" >> "$LOG_FILE"
swww-daemon &
sleep 2

# Wallpaper
echo "[$(date '+%H:%M:%S')] Setting wallpaper" >> "$LOG_FILE"
/home/jake/.dotfiles/scripts/wall >> "$LOG_FILE" 2>&1 &

# Waybar
echo "[$(date '+%H:%M:%S')] Starting waybar" >> "$LOG_FILE"
waybar -c ~/.dotfiles/waybar/config.jsonc -s ~/.dotfiles/waybar/style.css >> "$LOG_FILE" 2>&1 &

# Notifications
echo "[$(date '+%H:%M:%S')] Starting swaync" >> "$LOG_FILE"
swaync >> "$LOG_FILE" 2>&1 &

# Polkit agent - delayed to avoid black window
echo "[$(date '+%H:%M:%S')] Queueing polkit-agent (5s delay)" >> "$LOG_FILE"
(sleep 5 && /usr/lib/polkit-kde-authentication-agent-1 >> "$LOG_FILE" 2>&1) &

echo "[$(date '+%H:%M:%S')] All startup apps queued" >> "$LOG_FILE"
