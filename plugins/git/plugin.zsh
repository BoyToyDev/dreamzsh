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
  git branch --merged | grep -v '\*' | grep -v 'main' | grep -v 'master' | xargs -r git branch -d
}
