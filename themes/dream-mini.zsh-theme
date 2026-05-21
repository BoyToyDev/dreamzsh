# dreamzsh/themes/dream-mini.zsh-theme

_dz_mini_git() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local branch dirty=""
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
    || branch=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return 0

  if ! command git diff --quiet 2>/dev/null || \
     ! command git diff --cached --quiet 2>/dev/null; then
    dirty="*"
  fi

  print -r -- " %F{8}git:%F{7}${branch}%F{3}${dirty}%f"
}

_dz_mini_prompt() {
  local exit_code=$?
  local arrow_color="5"

  if (( exit_code != 0 )); then
    arrow_color="1"
  fi

  PROMPT="%F{6}%1~%f$(_dz_mini_git) %F{${arrow_color}}❯%f "
  RPROMPT="%F{8}%*%f"
}

dz::theme::apply() {
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _dz_mini_prompt
  _dz_mini_prompt
}
