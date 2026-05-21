# dreamzsh/plugins/sudo/plugin.zsh

_sudo_zle() {
  zle beginning-of-line
  zle -U "sudo "
}

zle -N _sudo_zle

bindkey '^[^[' _sudo_zle
bindkey '^[^[^[' _sudo_zle
