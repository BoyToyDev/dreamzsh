_autosuggest() {
    local suggestion=$(fc -ln -1 | grep "^$BUFFER" | head -n1)

    if [[ -n "$suggestion" && "$suggestion" != "$BUFFER" ]]; then
        POSTDISPLAY="${suggestion#$BUFFER}"
    else
        POSTDISPLAY=""
    fi
}

zle -N autosuggest _autosuggest
bindkey '^ ' autosuggest
