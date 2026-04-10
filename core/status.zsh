# dreamzsh/core/status.zsh

if [[ -n "${__DREAMZSH_STATUS_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_STATUS_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1

dz::status::run() {
  local plugins_text="-"

  if (( ${#DREAMZSH_PLUGINS[@]} > 0 )); then
    plugins_text="${DREAMZSH_PLUGINS[*]}"
  fi

  print -r -- "DreamZSH status"
  print -r -- "Profile: ${DREAMZSH_PROFILE:-"-"}"
  print -r -- "Theme: ${DREAMZSH_THEME:-"-"}"
  print -r -- "Plugins: $plugins_text"
  print -r -- "Config: $DREAMZSH_CONFIG_FILE"
  print -r -- "Themes dir: $DREAMZSH_THEMES_DIR"
  print -r -- "Plugins dir: $DREAMZSH_PLUGINS_DIR"
  print -r -- "Profiles dir: $DREAMZSH_PROFILES_DIR"
}
