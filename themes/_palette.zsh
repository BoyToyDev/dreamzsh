# Shared segmented prompt engine for DreamZSH palette themes.

_dz_palette_git() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local branch dirty=""
  branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null)" \
    || branch="$(command git rev-parse --short HEAD 2>/dev/null)" \
    || return 0

  [[ -n "$(command git status --porcelain 2>/dev/null)" ]] && dirty=" *"
  print -r -- "${branch}${dirty}"
}

_dz_palette_build() {
  local exit_code=$?
  local git_info=""
  local user_bg="$DZ_PALETTE_USER_BG"
  local status_color="$DZ_PALETTE_SUCCESS"

  (( EUID == 0 )) && user_bg="$DZ_PALETTE_ERROR"
  (( exit_code != 0 )) && status_color="$DZ_PALETTE_ERROR"
  git_info="$(_dz_palette_git)"

  PROMPT="%K{${user_bg}}%F{${DZ_PALETTE_DARK}} %n@%m %f%k"
  PROMPT+="%K{${DZ_PALETTE_PATH_BG}}%F{${user_bg}}%f"
  PROMPT+="%F{${DZ_PALETTE_PATH_FG}} %~ %f%k"

  if [[ -n "$git_info" ]]; then
    PROMPT+="%K{${DZ_PALETTE_GIT_BG}}%F{${DZ_PALETTE_PATH_BG}}%f"
    PROMPT+="%F{${DZ_PALETTE_GIT_FG}} git:${git_info} %f%k"
    PROMPT+="%F{${DZ_PALETTE_GIT_BG}}%f"
  else
    PROMPT+="%F{${DZ_PALETTE_PATH_BG}}%f"
  fi

  PROMPT+=$'\n'
  if (( exit_code != 0 )); then
    PROMPT+="%F{${status_color}}${exit_code} ✗%f "
  fi
  PROMPT+="%F{${DZ_PALETTE_ACCENT}}❯%f "
  RPROMPT="%F{${DZ_PALETTE_MUTED}}%D{%H:%M}%f"
}

dz::theme::apply() {
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _dz_palette_build
  _dz_palette_build
}

dz::theme::cleanup() {
  add-zsh-hook -d precmd _dz_palette_build 2>/dev/null || true
  unfunction _dz_palette_build 2>/dev/null || true
  unfunction _dz_palette_git 2>/dev/null || true

  unset DZ_PALETTE_USER_BG DZ_PALETTE_PATH_BG DZ_PALETTE_PATH_FG
  unset DZ_PALETTE_GIT_BG DZ_PALETTE_GIT_FG DZ_PALETTE_ACCENT
  unset DZ_PALETTE_SUCCESS DZ_PALETTE_ERROR DZ_PALETTE_MUTED DZ_PALETTE_DARK
}
