# Shared worktree and project locations used by gw and tmux-sessionizer.
# Change these values when a machine uses a different directory layout.

DOTFILES_DATA_ROOT=${DOTFILES_DATA_ROOT:-/data}
WORKTREE_ROOT=${WORKTREE_ROOT:-"$DOTFILES_DATA_ROOT/.worktrees"}
CODEX_WORKTREE_ROOT=${CODEX_WORKTREE_ROOT:-"$DOTFILES_DATA_ROOT/.codex/worktrees"}

SESSIONIZER_SEARCH_ROOTS=(
  "$DOTFILES_DATA_ROOT/projects"
  "$DOTFILES_DATA_ROOT/projects/fivem"
  "$HOME/.config"
  "$HOME"
)
