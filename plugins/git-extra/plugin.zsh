# dreamzsh/plugins/git-extra/plugin.zsh

(( $+commands[git] )) || return 0

alias gwip='git add -A && git commit -m "WIP"'
alias gunwip='git log -n 1 --format="%s" | grep -q WIP && git reset HEAD~1'
alias gundo='git reset --soft HEAD~1'
alias gamend='git commit --amend --no-edit'
alias gfixup='git commit --fixup'
alias gautosquash='git rebase -i --autosquash'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gstash='git stash'
alias gstashp='git stash pop'
alias gstashl='git stash list'
alias gstashd='git stash drop'
alias gblame='git blame'
alias gcount='git shortlog -sn'
alias gtags='git tag -l --sort=-version:refname'
alias gdt='git difftool'
alias gmt='git mergetool'

gignore() {
  [[ -n "$1" ]] || { print -u2 -- "usage: gignore <pattern>"; return 1; }
  print -r -- "$1" >> .gitignore
}

gcontrib() {
  git shortlog -sn --all --no-merges "${1:-HEAD}"
}

gchurn() {
  git log --all --find-copies --find-renames --name-only --format='format:' "$@" \
    | grep -v '^$' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -20
}

gremoved() {
  git log --all --diff-filter=D --summary "${@:-HEAD}" \
    | grep delete \
    | awk '{print $NF}'
}

grecent() {
  local n="${1:-10}"
  for branch in $(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/); do
    print -r -- "$(git log -1 --format='%C(yellow)%ad %C(green)%an %C(reset)%s %C(blue)%d' --date=relative "$branch")"
  done | head -n "$n"
}

gwhoami() {
  git config user.name && git config user.email
}

alias gbs='git bisect start'
alias gbb='git bisect bad'
alias gbg='git bisect good'
alias gbr='git bisect reset'
