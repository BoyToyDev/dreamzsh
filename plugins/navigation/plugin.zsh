# dreamzsh/plugins/navigation/plugin.zsh

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias -- -='cd -'
alias md='mkdir -p'
alias rd='rmdir'

cdb() {
  cd "$OLDPWD" || return 1
}

mkcd() {
  [[ -n "$1" ]] || {
    print -u2 -- "usage: mkcd <directory>"
    return 1
  }

  mkdir -p -- "$1" && cd -- "$1"
}

up() {
  local count path
  count="${1:-1}"

  [[ "$count" == <-> ]] || {
    print -u2 -- "usage: up [levels]"
    return 1
  }

  path=""
  while (( count > 0 )); do
    path+="../"
    (( count-- ))
  done

  cd "$path" || return 1
}
