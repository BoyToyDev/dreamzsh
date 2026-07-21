# dreamzsh/themes/dream-powerline.zsh-theme

dz_git_branch() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1

  command git symbolic-ref --quiet --short HEAD 2>/dev/null \
    || command git rev-parse --short HEAD 2>/dev/null
}

dz_build_dream_powerline_prompt() {
  local exit_code=$?
  local git_branch=""
  local user_bg="2"
  local user_fg="0"
  local path_bg="6"
  local path_fg="0"
  local git_bg="8"
  local git_fg="7"
  local status_color="2"

  if [[ "$EUID" -eq 0 ]]; then
    user_bg="1"
  fi

  if (( exit_code != 0 )); then
    status_color="1"
  fi

  git_branch="$(dz_git_branch)"

  PROMPT="%K{${user_bg}}%F{${user_fg}} %n@%m %f%k"
  PROMPT+="%K{${path_bg}}%F{${path_fg}} %~ %f%k"

  if [[ -n "$git_branch" ]]; then
    PROMPT+="%K{${git_bg}}%F{${git_fg}}  ${git_branch} %f%k"
  fi

  PROMPT+="
%F{${status_color}}❯%f "
  RPROMPT=''
}

dz::theme::apply() {
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd dz_build_dream_powerline_prompt
  dz_build_dream_powerline_prompt
}

dz::theme::cleanup() {
  add-zsh-hook -d precmd dz_build_dream_powerline_prompt 2>/dev/null || true
  unfunction dz_build_dream_powerline_prompt 2>/dev/null || true
  unfunction dz_git_branch 2>/dev/null || true
}
