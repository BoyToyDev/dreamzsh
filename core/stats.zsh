# dreamzsh/core/stats.zsh

if [[ -n "${__DREAMZSH_STATS_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_STATS_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1

dz::stats::run() {
  local startup="${__DREAMZSH_STARTUP_SECONDS:-?}"
  local plugin_count="${#DREAMZSH_PLUGINS[@]}"
  local theme_count backup_count profile_count
  local zsh_ver dz_ver dir_size

  zsh_ver="$ZSH_VERSION"
  dz_ver="${DREAMZSH_VERSION:-0.2.0}"

  theme_count=$(find "$DREAMZSH_THEMES_DIR" -maxdepth 1 -name '*.zsh-theme' 2>/dev/null | wc -l | tr -d ' ')
  profile_count=$(find "$DREAMZSH_PROFILES_DIR" -maxdepth 1 -name '*.profile' 2>/dev/null | wc -l | tr -d ' ')
  backup_count=$(find "${DREAMZSH_BACKUPS_DIR:-$DREAMZSH_DIR/backups}" -maxdepth 1 -name '*.tar.gz' 2>/dev/null | wc -l | tr -d ' ')

  if (( $+commands[du] )); then
    dir_size="$(du -sh "$DREAMZSH_DIR" 2>/dev/null | cut -f1)"
  else
    dir_size="?"
  fi

  cat <<EOF

${DZ_COLOR_BOLD}${DZ_COLOR_CYAN}⚡ DreamZSH Stats${DZ_COLOR_RESET}

${DZ_COLOR_BOLD}Version${DZ_COLOR_RESET}
  DreamZSH   ${DZ_COLOR_GREEN}${dz_ver}${DZ_COLOR_RESET}
  Zsh        ${DZ_COLOR_GREEN}${zsh_ver}${DZ_COLOR_RESET}

${DZ_COLOR_BOLD}Performance${DZ_COLOR_RESET}
  Startup    ${DZ_COLOR_GREEN}${startup}s${DZ_COLOR_RESET}

${DZ_COLOR_BOLD}Configuration${DZ_COLOR_RESET}
  Theme      ${DZ_COLOR_MAGENTA}${DREAMZSH_THEME:-none}${DZ_COLOR_RESET}
  Profile    ${DZ_COLOR_MAGENTA}${DREAMZSH_PROFILE:-none}${DZ_COLOR_RESET}
  Plugins    ${DZ_COLOR_GREEN}${plugin_count} enabled${DZ_COLOR_RESET}

${DZ_COLOR_BOLD}Assets${DZ_COLOR_RESET}
  Themes     ${theme_count} available
  Profiles   ${profile_count} available
  Backups    ${backup_count}
  Disk       ${dir_size} (${DREAMZSH_DIR})

EOF

  if (( plugin_count > 0 )); then
    print -P -- "  ${DZ_COLOR_BOLD}Enabled plugins:${DZ_COLOR_RESET}"
    local p
    for p in "${DREAMZSH_PLUGINS[@]}"; do
      print -P -- "    ${DZ_COLOR_GREEN}•${DZ_COLOR_RESET} $p"
    done
    print -r -- ""
  fi
}
