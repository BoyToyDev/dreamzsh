# dreamzsh/plugins/system/plugin.zsh

alias df='df -h'
alias du='du -h'
alias dus='du -sh'
alias dud='du -hd 1'
alias free='free -h'
alias meminfo='free -h'

alias psme='ps -u "$USER"'
alias psg='ps aux | grep -v grep | grep -i'

alias ports='ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null'
alias myip='curl -s ifconfig.me && print'
alias localip='hostname -I 2>/dev/null || ipconfig getifaddr en0 2>/dev/null || ip addr show | grep "inet " | grep -v 127.0.0.1'

alias path='print -l $path'
alias fpath='print -l $fpath'
alias envs='env | sort'

alias bigfiles='find . -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -k5 -hr | head -20'
alias bigdirs='du -hd 1 . 2>/dev/null | sort -hr | head -20'
alias oldfiles='find . -type f -mtime +90 -exec ls -lt {} \; 2>/dev/null | head -20'

alias reload!='exec zsh'
alias zshrc='${EDITOR:-nano} ~/.zshrc'
alias hosts='${EDITOR:-nano} /etc/hosts'

alias week='date +%V'
alias timestamp='date +%s'
alias now='date +"%Y-%m-%d %H:%M:%S"'

alias cpv='rsync -ah --progress'
alias mvv='rsync -ah --progress --remove-source-files'

alias mkdir1='mkdir -p'

alias chx='chmod +x'

alias less='less -R'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

if (( $+commands[htop] )); then
  alias top='htop'
fi

if (( $+commands[ncdu] )); then
  alias ncdu='ncdu --color dark'
fi

if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
fi

if (( $+commands[eza] )); then
  alias ls='eza'
  alias ll='eza -l'
  alias la='eza -la'
  alias lt='eza --tree'
  alias llt='eza -l --tree'
elif (( $+commands[exa] )); then
  alias ls='exa'
  alias ll='exa -l'
  alias la='exa -la'
  alias lt='exa --tree'
else
  alias ll='ls -lh'
  alias la='ls -lAh'
fi
