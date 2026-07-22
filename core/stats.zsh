# dreamzsh/core/stats.zsh

if [[ -n "${__DREAMZSH_STATS_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_STATS_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1

dz::stats::run() {
  local startup="${__DREAMZSH_STARTUP_SECONDS:-}"
  local startup_display="unavailable"
  local plugin_count="${#DREAMZSH_PLUGINS[@]}"
  local theme_count backup_count profile_count
  local zsh_ver dz_ver dir_size dreamzsh_dir theme profile

  zsh_ver="$ZSH_VERSION"
  dz_ver="${DREAMZSH_VERSION:-0.2.0}"

  if [[ "$startup" == <->(|.<->) ]]; then
    startup_display="$(printf '%.0f ms' "$(( startup * 1000.0 ))")"
  fi

  theme_count=$(( $(find "$DREAMZSH_THEMES_DIR" -maxdepth 1 -name '*.zsh-theme' 2>/dev/null | wc -l) + $(find "$DREAMZSH_CUSTOM_THEMES_DIR" -maxdepth 1 -name '*.zsh-theme' 2>/dev/null | wc -l) ))
  profile_count=$(( $(find "$DREAMZSH_PROFILES_DIR" -maxdepth 1 -name '*.profile' 2>/dev/null | wc -l) + $(find "$DREAMZSH_CUSTOM_PROFILES_DIR" -maxdepth 1 -name '*.profile' 2>/dev/null | wc -l) ))
  backup_count=$(find "${DREAMZSH_BACKUPS_DIR:-$DREAMZSH_DIR/backups}" -maxdepth 1 -name '*.tar.gz' 2>/dev/null | wc -l | tr -d ' ')

  if (( $+commands[du] )); then
    dir_size="$(du -sh "$DREAMZSH_DIR" 2>/dev/null | cut -f1)"
  else
    dir_size="?"
  fi

  dreamzsh_dir="${DREAMZSH_DIR//\%/%%}"
  theme="${${DREAMZSH_THEME:-none}//\%/%%}"
  profile="${${DREAMZSH_PROFILE:-none}//\%/%%}"
  dz_ver="${dz_ver//\%/%%}"
  zsh_ver="${zsh_ver//\%/%%}"
  dir_size="${dir_size//\%/%%}"

  print -P -- "

${DZ_COLOR_BOLD}${DZ_COLOR_CYAN}⚡ DreamZSH Stats${DZ_COLOR_RESET}

${DZ_COLOR_BOLD}Version${DZ_COLOR_RESET}
  DreamZSH   ${DZ_COLOR_GREEN}${dz_ver}${DZ_COLOR_RESET}
  Zsh        ${DZ_COLOR_GREEN}${zsh_ver}${DZ_COLOR_RESET}

${DZ_COLOR_BOLD}Performance${DZ_COLOR_RESET}
  Startup    ${DZ_COLOR_GREEN}${startup_display}${DZ_COLOR_RESET}

${DZ_COLOR_BOLD}Configuration${DZ_COLOR_RESET}
  Theme      ${DZ_COLOR_MAGENTA}${theme}${DZ_COLOR_RESET}
  Profile    ${DZ_COLOR_MAGENTA}${profile}${DZ_COLOR_RESET}
  Plugins    ${DZ_COLOR_GREEN}${plugin_count} enabled${DZ_COLOR_RESET}

${DZ_COLOR_BOLD}Assets${DZ_COLOR_RESET}
  Themes     ${theme_count} available
  Profiles   ${profile_count} available
  Backups    ${backup_count}
  Disk       ${dir_size} (${dreamzsh_dir})

"

  if (( plugin_count > 0 )); then
    print -P -- "  ${DZ_COLOR_BOLD}Enabled plugins:${DZ_COLOR_RESET}"
    local p
    for p in "${DREAMZSH_PLUGINS[@]}"; do
      print -Pn -- "    ${DZ_COLOR_GREEN}•${DZ_COLOR_RESET} "
      print -r -- "$p"
    done
    print -r -- ""
  fi
}
