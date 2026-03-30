# DreamZSH Default Theme

autoload -Uz colors && colors

git_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

precmd() {
    branch=$(git_branch)

    if [[ -n "$branch" ]]; then
        branch=" (%F{yellow}$branch%f)"
    fi

    PROMPT="%F{green}%n@%m%f:%F{blue}%~%f$branch
%F{magenta}❯%f "
}