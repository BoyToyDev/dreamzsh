# Utils plugin

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

mkcd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi

  mkdir -p -- "$1" && cd -- "$1"
}

# FIX: remove alias if exists
unalias reload 2>/dev/null

reload() {
  source ~/.zshrc
}

ee() {
  nano ~/.zshrc
}