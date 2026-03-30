autoload -Uz colors && colors
setopt prompt_subst

git_branch() {
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ -n "$branch" ]] && echo "%F{cyan}[$branch]%f "
}

PROMPT='%F{cyan}%n%f@%F{magenta}%m%f:%F{green}%~%f
%F{magenta}➤%f '
RPROMPT='$(git_branch)'