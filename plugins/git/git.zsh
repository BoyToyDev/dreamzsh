git_branch() {
  command git rev-parse --abbrev-ref HEAD 2>/dev/null
}

git_prompt() {
  local branch=$(git_branch)
  if [[ -n "$branch" ]]; then
    echo " ($branch)"
  fi
}
