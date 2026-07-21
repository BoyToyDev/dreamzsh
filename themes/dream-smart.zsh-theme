# dreamzsh/themes/dream-smart.zsh-theme

dz_prompt_user_color() {
  if [[ "$EUID" -eq 0 ]]; then
    print -r -- "1"
  else
    print -r -- "2"
  fi
}

dz_prompt_git_branch() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local branch
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
    || branch=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return 0

  print -r -- "$branch"
}

dz_build_dream_smart_prompt() {
  local last_exit="$?"
  local user_color git_branch first_line second_line

  user_color="$(dz_prompt_user_color)"
  git_branch="$(dz_prompt_git_branch)"

  first_line="%F{${user_color}}%n%f@%F{4}%m%f %F{6}%~%f"

  if [[ -n "$git_branch" ]]; then
    first_line+=" %F{8}[%f%F{7}${git_branch}%f%F{8}]%f"
  fi

  if (( last_exit == 0 )); then
    second_line="%F{5}>%f "
  else
    second_line="%F{1}[${last_exit}]%f %F{5}>%f "
  fi

  PROMPT="${first_line}
${second_line}"
  RPROMPT=''
}

dz::theme::apply() {
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd dz_build_dream_smart_prompt
  dz_build_dream_smart_prompt
}

dz::theme::cleanup() {
  add-zsh-hook -d precmd dz_build_dream_smart_prompt 2>/dev/null || true
  unfunction dz_build_dream_smart_prompt 2>/dev/null || true
  unfunction dz_prompt_git_branch 2>/dev/null || true
  unfunction dz_prompt_user_color 2>/dev/null || true
}
