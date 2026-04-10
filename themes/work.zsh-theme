# dreamzsh/themes/work.zsh-theme

dz_git_prompt_info() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local branch
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
    || branch=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return 0

  print -r -- " %F{8}[%f%F{7}${branch}%f%F{8}]%f"
}

PROMPT='%F{8}%n@%m%f %F{6}%~%f$(dz_git_prompt_info)
%# '
RPROMPT=''
