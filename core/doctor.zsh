# dreamzsh/core/doctor.zsh

if [[ -n "${__DREAMZSH_DOCTOR_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_DOCTOR_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1

dz::doctor::check_item() {
  local exit_code="$1"
  local message="$2"

  if [[ "$exit_code" -eq 0 ]]; then
    dz::success "$message"
  else
    dz::error "$message"
  fi
}

dz::doctor::run() {
  local ok=1
  local plugin
  local zshrc_file="${HOME}/.zshrc"
  local block_start_count=0
  local block_end_count=0

  dz::info "DreamZSH doctor"

  [[ -d "$DREAMZSH_DIR" ]]
  dz::doctor::check_item "$?" "DreamZSH directory exists: $DREAMZSH_DIR"

  [[ -f "$DREAMZSH_CONFIG_FILE" ]]
  dz::doctor::check_item "$?" "Config file exists: $DREAMZSH_CONFIG_FILE"

  [[ -d "$DREAMZSH_THEMES_DIR" ]]
  dz::doctor::check_item "$?" "Themes directory exists: $DREAMZSH_THEMES_DIR"

  [[ -d "$DREAMZSH_PLUGINS_DIR" ]]
  dz::doctor::check_item "$?" "Plugins directory exists: $DREAMZSH_PLUGINS_DIR"

  if dz::theme_exists "$DREAMZSH_THEME"; then
    dz::success "Active theme exists: $DREAMZSH_THEME"
  else
    dz::error "Active theme missing: $DREAMZSH_THEME"
    ok=0
  fi

  for plugin in "${DREAMZSH_PLUGINS[@]}"; do
    if dz::plugin_exists "$plugin"; then
      dz::success "Enabled plugin exists: $plugin"
    else
      dz::error "Enabled plugin missing: $plugin"
      ok=0
    fi
  done

  if [[ -f "$zshrc_file" ]]; then
    block_start_count=$(grep -c '^# >>> dreamzsh >>>$' "$zshrc_file" 2>/dev/null)
    block_end_count=$(grep -c '^# <<< dreamzsh <<<$' "$zshrc_file" 2>/dev/null)

    if (( block_start_count == 1 && block_end_count == 1 )); then
      dz::success ".zshrc contains one DreamZSH block"
    elif (( block_start_count == 0 && block_end_count == 0 )); then
      dz::warn ".zshrc does not contain a DreamZSH block yet"
    else
      dz::error ".zshrc contains duplicated or broken DreamZSH block markers"
      ok=0
    fi
  else
    dz::warn ".zshrc not found: $zshrc_file"
  fi

  if command -v zsh >/dev/null 2>&1; then
    dz::success "zsh found: $(command -v zsh)"
  else
    dz::error "zsh binary not found in PATH"
    ok=0
  fi

  if (( ok )); then
    dz::success "Doctor finished: no critical problems found"
    return 0
  else
    dz::error "Doctor finished: critical problems found"
    return 1
  fi
}
