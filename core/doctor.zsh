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
  local zshrc_file="${ZDOTDIR:-$HOME}/.zshrc"
  local block_start_count=0
  local block_end_count=0

  dz::info "DreamZSH doctor"

  if [[ -d "$DREAMZSH_DIR" ]]; then
    dz::doctor::check_item 0 "DreamZSH directory exists: $DREAMZSH_DIR"
  else
    dz::doctor::check_item 1 "DreamZSH directory exists: $DREAMZSH_DIR"
    ok=0
  fi

  if [[ -f "$DREAMZSH_CONFIG_FILE" ]]; then
    dz::doctor::check_item 0 "Config file exists: $DREAMZSH_CONFIG_FILE"
  else
    dz::doctor::check_item 1 "Config file exists: $DREAMZSH_CONFIG_FILE"
    ok=0
  fi

  if [[ -d "$DREAMZSH_THEMES_DIR" ]]; then
    dz::doctor::check_item 0 "Themes directory exists: $DREAMZSH_THEMES_DIR"
  else
    dz::doctor::check_item 1 "Themes directory exists: $DREAMZSH_THEMES_DIR"
    ok=0
  fi

  if [[ -d "$DREAMZSH_PLUGINS_DIR" ]]; then
    dz::doctor::check_item 0 "Plugins directory exists: $DREAMZSH_PLUGINS_DIR"
  else
    dz::doctor::check_item 1 "Plugins directory exists: $DREAMZSH_PLUGINS_DIR"
    ok=0
  fi

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
    local zsh_path zsh_ver zsh_major zsh_minor
    zsh_path="$(command -v zsh)"
    zsh_ver="$("$zsh_path" --version 2>/dev/null | head -1)"
    if [[ "$zsh_ver" =~ 'zsh ([0-9]+)\.([0-9]+)' ]]; then
      zsh_major="$match[1]"
      zsh_minor="$match[2]"
      if (( zsh_major > 5 || (zsh_major == 5 && zsh_minor >= 0) )); then
        dz::success "zsh $zsh_major.$zsh_minor found: $zsh_path"
      else
        dz::error "zsh $zsh_major.$zsh_minor is too old (need 5.0+): $zsh_path"
        ok=0
      fi
    else
      dz::success "zsh found: $zsh_path"
    fi
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

dz::doctor::fix() {
  local fixed=0
  local zshrc_file="${ZDOTDIR:-$HOME}/.zshrc"
  local block_start="# >>> dreamzsh >>>"
  local block_end="# <<< dreamzsh <<<"
  local repair_failed=0

  dz::info "Doctor --fix: repairing..."

  if [[ ! -d "$DREAMZSH_DIR" ]]; then
    mkdir -p "$DREAMZSH_DIR" && {
      dz::success "Created: $DREAMZSH_DIR"
      (( fixed++ ))
    }
  fi

  if [[ ! -d "$DREAMZSH_THEMES_DIR" ]]; then
    mkdir -p "$DREAMZSH_THEMES_DIR" && {
      dz::success "Created: $DREAMZSH_THEMES_DIR"
      (( fixed++ ))
    }
  fi

  if [[ ! -d "$DREAMZSH_PLUGINS_DIR" ]]; then
    mkdir -p "$DREAMZSH_PLUGINS_DIR" && {
      dz::success "Created: $DREAMZSH_PLUGINS_DIR"
      (( fixed++ ))
    }
  fi

  if [[ ! -d "$DREAMZSH_PROFILES_DIR" ]]; then
    mkdir -p "$DREAMZSH_PROFILES_DIR" && {
      dz::success "Created: $DREAMZSH_PROFILES_DIR"
      (( fixed++ ))
    }
  fi

  if [[ ! -f "$DREAMZSH_CONFIG_FILE" && -f "${DREAMZSH_DIR}/dreamzsh.conf.example" ]]; then
    cp "${DREAMZSH_DIR}/dreamzsh.conf.example" "$DREAMZSH_CONFIG_FILE" && {
      dz::success "Config created from example"
      (( fixed++ ))
    }
  fi

  if [[ -L "$zshrc_file" ]]; then
    zshrc_file="${zshrc_file:A}"
  fi
  if [[ ! -f "$zshrc_file" ]]; then
    mkdir -p "${zshrc_file:h}" || return 1
    : > "$zshrc_file" || return 1
  fi

  if [[ -f "$zshrc_file" ]]; then
    local start_count end_count
    start_count=$(grep -cF "$block_start" "$zshrc_file" 2>/dev/null || true)
    end_count=$(grep -cF "$block_end" "$zshrc_file" 2>/dev/null || true)

    if (( start_count != end_count )); then
      dz::error "Cannot safely repair an incomplete DreamZSH block in $zshrc_file"
      repair_failed=1
    elif (( start_count != 1 )); then
      local tmp_file
      tmp_file="$(mktemp "${zshrc_file}.dreamzsh.XXXXXX")" || return 1

      local in_block=0
      while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "$block_start" ]]; then
          (( in_block > 0 )) && continue
          in_block=1
          continue
        fi
        if [[ "$line" == "$block_end" ]]; then
          in_block=0
          continue
        fi
        (( in_block )) && continue
        print -r -- "$line" >> "$tmp_file"
      done < "$zshrc_file"

      print -r -- "" >> "$tmp_file"
      print -r -- "$block_start" >> "$tmp_file"
      cat <<'EOBLOCK' >> "$tmp_file"
export DREAMZSH_DIR="$HOME/.dreamzsh"
if [ -d "$DREAMZSH_DIR/bin" ]; then
  case ":$PATH:" in
    *:"$DREAMZSH_DIR/bin":*) ;;
    *) export PATH="$DREAMZSH_DIR/bin:$PATH" ;;
  esac
fi
if [ -f "$DREAMZSH_DIR/core/init.zsh" ]; then
  source "$DREAMZSH_DIR/core/init.zsh"
fi
EOBLOCK
      print -r -- "$block_end" >> "$tmp_file"

      chmod --reference="$zshrc_file" "$tmp_file" 2>/dev/null || chmod 600 "$tmp_file" 2>/dev/null || true
      mv -f -- "$tmp_file" "$zshrc_file" && {
        dz::success "Fixed broken DreamZSH block in .zshrc"
        (( fixed++ ))
      }
    fi
  fi

  local -a missing_plugins=()
  local p
  for p in "${DREAMZSH_PLUGINS[@]}"; do
    dz::plugin_exists "$p" || missing_plugins+=("$p")
  done

  if (( ${#missing_plugins[@]} > 0 )); then
    local -a cleaned=()
    for p in "${DREAMZSH_PLUGINS[@]}"; do
      dz::plugin_exists "$p" && cleaned+=("$p")
    done
    DREAMZSH_PLUGINS=("${cleaned[@]}")
    dz::config::save && {
      dz::success "Removed missing plugins from config: ${missing_plugins[*]}"
      (( fixed++ ))
    }
  fi

  if ! dz::theme_exists "$DREAMZSH_THEME"; then
    DREAMZSH_THEME="minimal"
    dz::config::save && {
      dz::success "Reset theme to 'minimal' (previous was missing)"
      (( fixed++ ))
    }
  fi

  if (( repair_failed )); then
    dz::error "Doctor --fix finished with an unresolved .zshrc problem."
    return 1
  elif (( fixed > 0 )); then
    dz::success "Doctor --fix: $fixed issue(s) repaired."
  else
    dz::success "Doctor --fix: nothing to fix."
  fi
}
