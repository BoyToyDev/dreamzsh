# dreamzsh/themes/dream.zsh-theme

dz_git_prompt_info() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local branch
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
    || branch=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return 0

  print -r -- " %F{8}[%f%F{7}${branch}%f%F{8}]%f"
}

dz::theme::apply() {
  PROMPT='%F{2}%n%f@%F{4}%m%f %F{6}%~%f$(dz_git_prompt_info)
%F{5}>%f '
  RPROMPT=''
}
