# dreamzsh/plugins/history/plugin.zsh

typeset -g HISTFILE="${HISTFILE:-$HOME/.zsh_history}"

# Zsh initializes these special parameters to 30 and 0. Parameter-default
# expansion therefore cannot distinguish a fresh shell from a configured one.
(( HISTSIZE == 30 )) && typeset -gi HISTSIZE=10000
(( SAVEHIST == 0 )) && typeset -gi SAVEHIST=10000

typeset history_dir="${HISTFILE:h}"
if [[ ! -d "$history_dir" ]]; then
  mkdir -p -- "$history_dir" 2>/dev/null \
    || print -u2 -r -- "dreamzsh: cannot create history directory: $history_dir"
fi

if [[ -d "$history_dir" && ! -e "$HISTFILE" ]]; then
  if : > "$HISTFILE" 2>/dev/null; then
    chmod 600 -- "$HISTFILE" 2>/dev/null || true
  else
    print -u2 -r -- "dreamzsh: cannot create history file: $HISTFILE"
  fi
fi

if [[ -e "$HISTFILE" && ! -w "$HISTFILE" ]]; then
  print -u2 -r -- "dreamzsh: history file is not writable: $HISTFILE"
fi
unset history_dir

if [[ -r "$HISTFILE" ]]; then
  fc -RI "$HISTFILE" 2>/dev/null || true
fi

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
