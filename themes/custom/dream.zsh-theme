autoload -Uz colors && colors
setopt prompt_subst

# Git branch
git_branch() {
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ -n "$branch" ]] && echo "%F{blue}[$branch]%f "
}

# Prompt
PROMPT='%F{green}%n%f@%F{magenta}%m%f:%F{yellow}%~%f
%F{magenta}?%f '
RPROMPT='$(git_branch)'