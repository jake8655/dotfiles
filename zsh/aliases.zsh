alias nf='neofetch'
alias ls="eza --icons --group-directories-first --git -@1 -l -la -lb -m"
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
