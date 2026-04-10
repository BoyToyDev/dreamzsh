# dreamzsh/themes/pro.zsh-theme

dz_git_prompt_info() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local branch
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
    || branch=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return 0

  print -r -- " %F{5}git:(${branch})%f"
}

PROMPT="%F{6}%n%f at %F{4}%m%f in %F{2}%~%f\$(dz_git_prompt_info)
%# "
RPROMPT=''
