# dreamzsh/themes/dream-powerline.zsh-theme

dz_git_branch() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1

  command git symbolic-ref --quiet --short HEAD 2>/dev/null \
    || command git rev-parse --short HEAD 2>/dev/null
}

dz_build_dream_powerline_prompt() {
  local git_branch
  local user_color

  if [[ "$EUID" -eq 0 ]]; then
    user_color="1"
  else
    user_color="2"
  fi

  git_branch="$(dz_git_branch)"

  PROMPT="%K{${user_color}}%F{0} %n@%m %f%k"
  PROMPT+="%K{6}%F{0} %~ %f%k"

  if [[ -n "$git_branch" ]]; then
    PROMPT+="%K{8}%F{7} ${git_branch} %f%k"
  fi

  PROMPT+="
%F{5}>%f "

  RPROMPT=''
}

dz::theme::apply() {
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd dz_build_dream_powerline_prompt
  dz_build_dream_powerline_prompt
}
