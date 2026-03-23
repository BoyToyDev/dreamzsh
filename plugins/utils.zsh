# Useful functions
alias ..='cd ..'
alias ...='cd ../..'
alias reload='source ~/.zshrc'
alias ee='${EDITOR:-nano} ~/.zshrc'

function mkcd() {
    mkdir -p "$1" && cd "$1"
}

function ports() {
    lsof -i -P -n | grep LISTEN
}
