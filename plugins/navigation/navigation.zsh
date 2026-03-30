alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

mkcd() {
  mkdir -p "$1" && cd "$1"
}
