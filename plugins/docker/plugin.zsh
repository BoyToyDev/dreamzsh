# dreamzsh/plugins/docker/plugin.zsh

(( $+commands[docker] )) || return 0

alias d='docker'
alias dc='docker compose'
alias dcb='docker compose build'
alias dcd='docker compose down'
alias dce='docker compose exec'
alias dck='docker compose kill'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f'
alias dcp='docker compose ps'
alias dcr='docker compose run'
alias dcu='docker compose up'
alias dcud='docker compose up -d'

alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dst='docker stats'
alias dlogs='docker logs'
alias dlogs-f='docker logs -f'
alias dexec='docker exec -it'
alias dprune='docker system prune -af'
alias dprunev='docker volume prune -f'

dsh() {
  local container="${1:-}"
  if [[ -z "$container" ]]; then
    container="$(docker ps --format '{{.Names}}' | fzf --prompt='container> ' 2>/dev/null)"
    [[ -z "$container" ]] && return 1
  fi
  docker exec -it "$container" "${2:-sh}"
}

dip() {
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${1:-}"
}

dclean() {
  docker system prune -af --volumes
}
