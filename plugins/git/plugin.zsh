# dreamzsh/plugins/git/plugin.zsh

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gbd='git branch -d'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git pull'
alias gp='git push'
alias gs='git status'
alias gss='git status --short'
alias glog='git log --oneline --graph --decorate --all'

groot() {
  git rev-parse --show-toplevel 2>/dev/null
}

gclean-merged() {
  local branch
  local -a merged=()
  while IFS= read -r branch; do
    branch="${branch#"${branch%%[![:space:]]*}"}"
    [[ -z "$branch" || "$branch" == \** || "$branch" == main || "$branch" == master ]] && continue
    merged+=("$branch")
  done < <(git branch --merged)
  (( ${#merged[@]} > 0 )) && git branch -d -- "${merged[@]}"
}
