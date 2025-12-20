alias pf='pfetch'
alias ls="eza --icons --group-directories-first --git -@1 -l -la -lb -m"
alias lst="eza --icons --group-directories-first --git -@1 -l -la -lb -m -snew"
alias lsb="eza --icons --group-directories-first --git -@1 -G -l -la -lb -m"
alias c="clear && printf '\e[3J' && pfetch"
alias so="source"
alias pn="pnpm"
alias py="python3"
alias bb="cd ~-"
alias dt="cd ~/.dotfiles/"
alias vim="nvim"
alias v="vim"
alias diskusage="ncdu"
alias tms="~/.dotfiles/scripts/tmux-sessionizer"
alias lock="~/.dotfiles/scripts/lock"
alias sleep-pc="~/.dotfiles/scripts/sleep-pc"
alias zen="zen-browser"
alias lg="lazygit"
# Connect to my bluetooth headphones
alias hp="bluetoothctl connect 14:C8:8B:D1:82:86"
alias dhp="bluetoothctl disconnect"
# Connect to my bluetooth mouse
alias bm="bluetoothctl connect 94:F6:D6:B6:6B:42"
alias dbm="bluetoothctl disconnect"
alias wallp="wallpaper-cava --config /home/jake/.dotfiles/cava/config.toml"
alias gdvim="nvim --listen ~/.cache/nvim/godot.pipe"
alias glg="g lg"
alias oc="opencode"

# Browse projects
function pj() {
  PROJECT_DIR="$(find ~/Desktop/projects/ -maxdepth 1 -type d -exec basename {} \; | fzf)"
  if [ -z "$PROJECT_DIR" ]; then
    return
  fi

  if [ "$PROJECT_DIR" = "projects" ]; then
    cd ~/Desktop/projects/
    return
  fi

  cd ~/Desktop/projects/$PROJECT_DIR
}

# Browse school projects
function spj() {
  SCHOOL_PROJECT_DIR="$(find ~/Desktop/projects/school/ -maxdepth 1 -type d -exec basename {} \; | fzf)"
  if [ -z "$SCHOOL_PROJECT_DIR" ]; then
    return
  fi

  if [ "$SCHOOL_PROJECT_DIR" = "school" ]; then
    cd ~/Desktop/projects/school/
    return
  fi

  cd ~/Desktop/projects/school/$SCHOOL_PROJECT_DIR
}

function timer() {
    start="$(( $(date '+%s') + $1))"
    while [ $start -ge $(date +%s) ]; do
        ttime="$(( $start - $(date +%s) ))"
        printf '%s\r' "$(date -u -d "@$ttime" +%H:%M:%S)"
        sleep 0.1
    done
}

function stopwatch() {
    start=$(date +%s)
    while true; do
        ttime="$(( $(date +%s) - $start))"
        printf '%s\r' "$(date -u -d "@$ttime" +%H:%M:%S)"
        sleep 0.1
    done
}
