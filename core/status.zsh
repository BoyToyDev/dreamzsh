# dreamzsh/core/status.zsh

if [[ -n "${__DREAMZSH_STATUS_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_STATUS_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1
source "${DREAMZSH_DIR}/core/backup.zsh" || return 1

dz::status::print_section() {
  local title="$1"
  print -P -- ""
  print -P -- "${DZ_COLOR_BOLD}${title}${DZ_COLOR_RESET}"
}

dz::status::print_kv() {
  local key="$1"
  local value="$2"
  printf '  %-10s %s\n' "${key}:" "$value"
}

dz::status::backup_total() {
  local -a files
  files=("$DREAMZSH_BACKUPS_DIR"/*.tar.gz(N))
  print -r -- "${#files[@]}"
}

dz::status::backup_last() {
  local -a files
  local latest

  files=("$DREAMZSH_BACKUPS_DIR"/*.tar.gz(Nom))
  if (( ${#files[@]} == 0 )); then
    print -r -- "none"
    return 0
  fi

  latest="${files[1]:t}"
  latest="${latest#backup-}"
  latest="${latest%.tar.gz}"
  latest="${latest//_/ }"
  print -r -- "$latest"
}

dz::status::plugins_text() {
  if (( ${#DREAMZSH_PLUGINS[@]} == 0 )); then
    print -P -- "${DZ_COLOR_YELLOW}none${DZ_COLOR_RESET}"
    return 0
  fi

  print -P -- "${DZ_COLOR_GREEN}$(dz::join_by ', ' "${DREAMZSH_PLUGINS[@]}")${DZ_COLOR_RESET}"
}

dz::status::run() {
  local plugins_text backup_total backup_last

  plugins_text="$(dz::status::plugins_text)"
  backup_total="$(dz::status::backup_total)"
  backup_last="$(dz::status::backup_last)"

  print -P -- "${DZ_COLOR_BOLD}DreamZSH Status${DZ_COLOR_RESET}"

  dz::status::print_section "Install"
  dz::status::print_kv "dir" "$DREAMZSH_DIR"
  dz::status::print_kv "config" "$DREAMZSH_CONFIG_FILE"

  dz::status::print_section "Theme"
  dz::status::print_kv "current" "${DREAMZSH_THEME:-"-"}"

  dz::status::print_section "Profile"
  dz::status::print_kv "current" "${DREAMZSH_PROFILE:-"-"}"

  dz::status::print_section "Plugins"
  dz::status::print_kv "enabled" "$plugins_text"

  dz::status::print_section "Paths"
  dz::status::print_kv "plugins" "$DREAMZSH_PLUGINS_DIR"
  dz::status::print_kv "themes" "$DREAMZSH_THEMES_DIR"
  dz::status::print_kv "profiles" "$DREAMZSH_PROFILES_DIR"
  dz::status::print_kv "custom" "$DREAMZSH_CUSTOM_DIR"

  dz::status::print_section "Backups"
  dz::status::print_kv "total" "$backup_total"
  dz::status::print_kv "last" "$backup_last"
}
