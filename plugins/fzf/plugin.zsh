# dreamzsh/plugins/fzf/plugin.zsh

(( $+commands[fzf] )) || return 0

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 40% --layout=reverse --border}"

if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif (( $+commands[rg] )); then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
fi

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
    ssh)          fzf --preview 'dig {}' "$@" ;;
    *)            fzf --preview "bat --style=numbers --color=always --line-range :500 {}" "$@" ;;
  esac
}

fkill() {
  local pid
  if [[ "$UID" != "0" ]]; then
    pid=$(ps -f -u "$UID" | sed 1d | fzf -m | awk '{print $2}')
  else
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  fi
  [[ -n "$pid" ]] && kill -"${1:-9}" "$pid" && print -r -- "Killed: $pid"
}

fbr() {
  local branches branch
  branches=$(git --no-pager branch --all --format='%(refname:short)') &&
  branch=$(echo "$branches" | fzf +m --prompt='branch> ') &&
  git checkout "$(echo "$branch" | sed 's|.*/||')"
}

fenv() {
  local out
  out=$(env | fzf --prompt='env> ')
  [[ -n "$out" ]] && print -r -- "$(echo "$out" | cut -d= -f2)"
}

fcd() {
  local dir
  dir=$(find "${1:-.}" -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf +m --prompt='cd> ') &&
  cd "$dir"
}

fhistory() {
  print -z -- "$(fc -ln 1 | fzf --tac --prompt='history> ')"
}

alias fzf-preview='fzf --preview "bat --style=numbers --color=always --line-range :500 {}"'

source <(fzf --zsh) 2>/dev/null || true
