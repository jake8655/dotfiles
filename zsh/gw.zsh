# Small, shell-native Git worktree manager.

_gw_source=${${(%):-%N}:A}
_gw_config_file=${WORKTREE_CONFIG_FILE:-"${_gw_source:h:h}/config/worktrees.sh"}

if [[ ! -f $_gw_config_file ]]; then
  print -u2 "gw: config not found: $_gw_config_file"
  return 1
fi

source "$_gw_config_file"
unset _gw_source _gw_config_file

_gw_repository() {
  local common_dir project_root

  common_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
    print -u2 'gw: not inside a Git repository'
    return 1
  }

  if [[ ${common_dir:t} == '.git' ]]; then
    project_root=${common_dir:h}
  else
    project_root=$common_dir
  fi

  reply=("$project_root" "${project_root:t}")
}

_gw_worktree_path() {
  local name=$1

  git worktree list --porcelain | awk -v target="$name" '
    /^worktree / { path = substr($0, 10) }
    /^branch refs\/heads\// {
      branch = substr($0, 19)
      if (branch == target) {
        print path
        exit
      }
    }
  '
}

_gw_worktree_names() {
  git worktree list --porcelain 2>/dev/null | sed -n 's|^branch refs/heads/||p'
}

_gw_list() {
  _gw_repository || return 1

  git worktree list --porcelain | awk '
    function emit() {
      if (path == "") return
      if (branch == "") branch = "(detached " substr(head, 1, 8) ")"
      entries[++count] = branch SUBSEP path
      if (length(branch) > branch_width) branch_width = length(branch)
      path = branch = head = ""
    }
    /^worktree / { emit(); path = substr($0, 10) }
    /^HEAD / { head = substr($0, 6) }
    /^branch refs\/heads\// { branch = substr($0, 19) }
    /^detached$/ { branch = "" }
    /^$/ { emit() }
    END {
      emit()
      if (branch_width < length("BRANCH")) branch_width = length("BRANCH")
      printf "%-*s  %s\n", branch_width, "BRANCH", "LOCATION"
      for (i = 1; i <= count; i++) {
        split(entries[i], fields, SUBSEP)
        printf "%-*s  %s\n", branch_width, fields[1], fields[2]
      }
    }
  '
}

_gw_run_codex_setup() {
  local worktree_path=$1
  local environment_file="$worktree_path/.codex/environments/environment.toml"
  local setup_script

  [[ -f $environment_file ]] || return 0

  setup_script=$(python3 - "$environment_file" <<'PY'
import pathlib
import sys
import tomllib

environment = tomllib.loads(pathlib.Path(sys.argv[1]).read_text())
print(environment.get("setup", {}).get("script", ""), end="")
PY
  ) || {
    print -u2 "gw: could not read Codex environment at $environment_file"
    return 1
  }

  [[ -n $setup_script ]] || return 0

  print "gw: running Codex environment setup"
  CODEX_WORKTREE_PATH=$worktree_path bash -c "$setup_script"
}

_gw_create() {
  local name=$1
  local project_root project_name worktree_path

  [[ -n $name ]] || {
    print -u2 'usage: gw c <worktree-name>'
    return 2
  }

  git check-ref-format --branch "$name" >/dev/null || return 1
  _gw_repository || return 1
  project_root=$reply[1]
  project_name=$reply[2]
  worktree_path="$WORKTREE_ROOT/$project_name/$name/$project_name"

  [[ ! -e $worktree_path ]] || {
    print -u2 "gw: path already exists: $worktree_path"
    return 1
  }

  mkdir -p "${worktree_path:h}" || return 1
  git worktree add -b "$name" "$worktree_path" || return 1

  if ! _gw_run_codex_setup "$worktree_path"; then
    print -u2 "gw: worktree was created, but its Codex setup failed: $worktree_path"
    return 1
  fi

  print "gw: created $worktree_path"
}

_gw_delete() {
  local name=$1
  local project_root project_name worktree_path current_root branch

  _gw_repository || return 1
  project_root=$reply[1]
  project_name=$reply[2]

  if [[ -z $name ]]; then
    current_root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
    if [[ ! -f "$current_root/.git" ]]; then
      print -u2 'gw: no worktree name given and the current checkout is the main worktree'
      return 2
    fi

    worktree_path=$current_root
    branch=$(git -C "$worktree_path" symbolic-ref --quiet --short HEAD 2>/dev/null)
    name=$branch
  else
    worktree_path=$(_gw_worktree_path "$name")
    [[ -n $worktree_path ]] || {
      print -u2 "gw: no worktree found for branch: $name"
      return 1
    }
    branch=$name
  fi

  if [[ ${PWD:A} == ${worktree_path:A} || ${PWD:A} == ${worktree_path:A}/* ]]; then
    builtin cd "$project_root" || return 1
  fi

  git -C "$project_root" worktree remove --force "$worktree_path" || return 1

  if [[ -n $branch ]] && git -C "$project_root" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$project_root" branch -D "$branch" || return 1
  fi

  print "gw: deleted ${name:-$worktree_path}"
}

_gw_switch() {
  local name=$1
  local worktree_path

  [[ -n $name ]] || {
    print -u2 'usage: gw s <worktree-name>'
    return 2
  }

  _gw_repository || return 1
  worktree_path=$(_gw_worktree_path "$name")
  [[ -n $worktree_path ]] || {
    print -u2 "gw: no worktree found for branch: $name"
    return 1
  }

  builtin cd "$worktree_path"
}

gw() {
  local command=$1
  shift 2>/dev/null || true

  case $command in
    c|create) _gw_create "$@" ;;
    d|delete) _gw_delete "$@" ;;
    l|list) _gw_list "$@" ;;
    s|switch) _gw_switch "$@" ;;
    *)
      print -u2 'usage: gw <c|d|l|s> [worktree-name]'
      return 2
      ;;
  esac
}

_gw() {
  local context state state_descr line
  typeset -A opt_args

  _arguments -C \
    '1:command:(c\:create d\:delete l\:list s\:switch)' \
    '2:worktree:->worktree' \
    '*::argument:->args'

  case $state in
    worktree)
      if [[ $words[2] == d || $words[2] == delete || $words[2] == s || $words[2] == switch ]]; then
        local -a worktrees
        worktrees=("${(@f)$(_gw_worktree_names)}")
        _describe 'worktree branch' worktrees
      fi
      ;;
  esac
}

compdef _gw gw
