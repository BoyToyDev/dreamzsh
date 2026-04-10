# dreamzsh/plugins/history/plugin.zsh

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE="${HISTSIZE:-10000}"
SAVEHIST="${SAVEHIST:-10000}"

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

h() {
  history 1
}

hgrep() {
  [[ -n "$1" ]] || {
    print -u2 -- "usage: hgrep <pattern>"
    return 1
  }

  history 1 | grep -i -- "$1"
}
