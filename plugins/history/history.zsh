# Better history search
bindkey '^R' history-incremental-search-backward

# Don't store duplicates
setopt hist_ignore_all_dups
setopt sharehistory

# Big history
HISTSIZE=50000
SAVEHIST=50000
