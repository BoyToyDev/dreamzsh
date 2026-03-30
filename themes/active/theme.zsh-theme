autoload -Uz colors && colors
setopt prompt_subst

git_branch() {
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ -n "$branch" ]] && echo "%F{blue}[$branch]%f "
}

PROMPT='%F{green}%n@%m%f %F{yellow}%~%f $(git_branch)
%F{magenta}>%f '