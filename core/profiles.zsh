# dreamzsh/core/profiles.zsh

if [[ -n "${__DREAMZSH_PROFILES_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_PROFILES_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1

dz::profile::file() {
  local name="$1"
  print -r -- "$DREAMZSH_PROFILES_DIR/$name.profile"
}

dz::profile::exists() {
  local name="$1"
  [[ -f "$(dz::profile::file "$name")" ]]
}

dz::profile::list() {
  local file name active
  local profile_theme=""
  local -a profile_plugins=()
  local plugins_text

  [[ -d "$DREAMZSH_PROFILES_DIR" ]] || return 0

  printf '%-14s %-8s %-14s %s\n' "PROFILE" "ACTIVE" "THEME" "PLUGINS"
  printf '%-14s %-8s %-14s %s\n' "-------" "------" "-----" "-------"

  for file in "$DREAMZSH_PROFILES_DIR"/*.profile(N); do
    name="${file:t}"
    name="${name%.profile}"

    if [[ "$name" == "$DREAMZSH_PROFILE" ]]; then
      active="yes"
    else
      active="no"
    fi

    unset DREAMZSH_THEME
    unset DREAMZSH_PLUGINS

    source "$file" || continue

    profile_theme="${DREAMZSH_THEME:-"-"}"
    profile_plugins=("${DREAMZSH_PLUGINS[@]}")

    if (( ${#profile_plugins[@]} > 0 )); then
      plugins_text="${profile_plugins[*]}"
    else
      plugins_text="-"
    fi

    printf '%-14s %-8s %-14s %s\n' "$name" "$active" "$profile_theme" "$plugins_text"
  done
}

dz::profile::current() {
  print -r -- "$DREAMZSH_PROFILE"
}

dz::profile::info() {
  local name="$1"
  local profile_file
  local profile_theme=""
  local -a profile_plugins=()
  local current_theme current_profile
  local -a current_plugins=()
  local current_plugins_text="-"

  [[ -n "$name" ]] || {
    dz::error "Profile name is required"
    return 1
  }

  dz::is_valid_name "$name" || {
    dz::error "Invalid profile name: $name"
    return 1
  }

  profile_file="$(dz::profile::file "$name")"

  [[ -f "$profile_file" ]] || {
    dz::error "Profile not found: $name"
    return 1
  }

  current_theme="${DREAMZSH_THEME:-}"
  current_profile="${DREAMZSH_PROFILE:-}"
  current_plugins=("${DREAMZSH_PLUGINS[@]}")

  if (( ${#current_plugins[@]} > 0 )); then
    current_plugins_text="${current_plugins[*]}"
  fi

  unset DREAMZSH_THEME
  unset DREAMZSH_PLUGINS

  source "$profile_file" || {
    dz::error "Failed to load profile: $name"
    return 1
  }

  profile_theme="${DREAMZSH_THEME:-}"
  profile_plugins=("${DREAMZSH_PLUGINS[@]}")

  print -r -- "Name: $name"
  if [[ "$name" == "$current_profile" ]]; then
    print -r -- "Active: yes"
  else
    print -r -- "Active: no"
  fi

  print -r -- ""
  print -r -- "--- Profile config ---"
  print -r -- "Theme: ${profile_theme:-"-"}"
  if (( ${#profile_plugins[@]} > 0 )); then
    print -r -- "Plugins: ${profile_plugins[*]}"
  else
    print -r -- "Plugins: -"
  fi

  print -r -- ""
  print -r -- "--- Current state ---"
  print -r -- "Profile: ${current_profile:-"-"}"
  print -r -- "Theme: ${current_theme:-"-"}"
  print -r -- "Plugins: $current_plugins_text"

  print -r -- ""
  print -r -- "File: $profile_file"

  DREAMZSH_THEME="$current_theme"
  DREAMZSH_PROFILE="$current_profile"
  DREAMZSH_PLUGINS=("${current_plugins[@]}")
}

dz::profile::apply() {
  local name="$1"
  local profile_file
  local profile_theme=""
  local -a profile_plugins=()

  [[ -n "$name" ]] || {
    dz::error "Profile name is required"
    return 1
  }

  dz::is_valid_name "$name" || {
    dz::error "Invalid profile name: $name"
    return 1
  }

  profile_file="$(dz::profile::file "$name")"

  [[ -f "$profile_file" ]] || {
    dz::error "Profile not found: $name"
    return 1
  }

  unset DREAMZSH_THEME
  unset DREAMZSH_PLUGINS

  source "$profile_file" || {
    dz::error "Failed to load profile: $name"
    return 1
  }

  profile_theme="${DREAMZSH_THEME:-}"
  profile_plugins=("${DREAMZSH_PLUGINS[@]}")

  [[ -n "$profile_theme" ]] || {
    dz::error "Profile does not define DREAMZSH_THEME: $name"
    return 1
  }

  dz::theme_exists "$profile_theme" || {
    dz::error "Profile theme not found: $profile_theme"
    return 1
  }

  if (( ${#profile_plugins[@]} == 0 )); then
    dz::error "Profile does not define DREAMZSH_PLUGINS: $name"
    return 1
  fi

  local plugin
  for plugin in "${profile_plugins[@]}"; do
    dz::plugin_exists "$plugin" || {
      dz::error "Profile plugin not found: $plugin"
      return 1
    }
  done

  DREAMZSH_THEME="$profile_theme"
  DREAMZSH_PLUGINS=("${profile_plugins[@]}")
  DREAMZSH_PROFILE="$name"

  dz::config::save || return 1
  dz::success "Profile applied: $name"
}

dz::profile::export() {
  local name="$1"
  local output="${2:-}"
  local profile_file profile_theme=""
  local -a profile_plugins=()
  local tmpdir archive_name
  local plugin theme_file

  [[ -n "$name" ]] || {
    dz::error "Profile name is required"
    return 1
  }

  dz::is_valid_name "$name" || {
    dz::error "Invalid profile name: $name"
    return 1
  }

  profile_file="$(dz::profile::file "$name")"
  [[ -f "$profile_file" ]] || {
    dz::error "Profile not found: $name"
    return 1
  }

  unset DREAMZSH_THEME
  unset DREAMZSH_PLUGINS
  source "$profile_file" || {
    dz::error "Failed to load profile: $name"
    return 1
  }

  profile_theme="${DREAMZSH_THEME:-}"
  profile_plugins=("${DREAMZSH_PLUGINS[@]}")

  [[ -n "$profile_theme" ]] || {
    dz::error "Profile does not define DREAMZSH_THEME"
    return 1
  }

  if [[ -z "$output" ]]; then
    output="${name}-dreamzsh-profile.tar.gz"
  fi

  tmpdir="$(mktemp -d)" || {
    dz::error "Failed to create temporary directory"
    return 1
  }

  mkdir -p "$tmpdir/profile" "$tmpdir/themes" "$tmpdir/plugins" || {
    rm -rf "$tmpdir"
    dz::error "Failed to create export structure"
    return 1
  }

  cp "$profile_file" "$tmpdir/profile/${name}.profile" || {
    rm -rf "$tmpdir"
    dz::error "Failed to copy profile"
    return 1
  }

  theme_file="${DREAMZSH_THEMES_DIR}/${profile_theme}.zsh-theme"
  if [[ -f "$theme_file" ]]; then
    cp "$theme_file" "$tmpdir/themes/" || {
      rm -rf "$tmpdir"
      dz::error "Failed to copy theme: $profile_theme"
      return 1
    }
  fi

  for plugin in "${profile_plugins[@]}"; do
    local plugin_dir="${DREAMZSH_PLUGINS_DIR}/${plugin}"
    if [[ -d "$plugin_dir" ]]; then
      cp -r "$plugin_dir" "$tmpdir/plugins/${plugin}" || {
        rm -rf "$tmpdir"
        dz::error "Failed to copy plugin: $plugin"
        return 1
      }
    fi
  done

  cat > "$tmpdir/manifest.txt" <<EOF
profile=$name
theme=$profile_theme
plugins=${profile_plugins[*]}
exported_by=${USER:-unknown}
exported_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
dreamzsh_version=${DREAMZSH_VERSION:-unknown}
EOF

  archive_name="${output:t}"
  (
    cd "$tmpdir" || exit 1
    tar -czf "$archive_name" manifest.txt profile themes plugins
  ) || {
    rm -rf "$tmpdir"
    dz::error "Failed to create archive"
    return 1
  }

  mv "$tmpdir/$archive_name" "$output" 2>/dev/null || cp "$tmpdir/$archive_name" "$output" || {
    rm -rf "$tmpdir"
    dz::error "Failed to move archive to: $output"
    return 1
  }

  rm -rf "$tmpdir"

  dz::success "Profile exported: $output"
  print -r -- ""
  print -r -- "Share this file with others. They can import it with:"
  print -r -- "  dreamzsh profile import $output"
}

dz::profile::import() {
  local archive="$1"
  local apply_flag="${2:-}"
  local tmpdir manifest_file
  local import_profile="" import_theme=""
  local -a import_plugins=()
  local line key value

  [[ -n "$archive" ]] || {
    dz::error "Archive path is required"
    return 1
  }

  [[ -f "$archive" ]] || {
    dz::error "Archive not found: $archive"
    return 1
  }

  tmpdir="$(mktemp -d)" || {
    dz::error "Failed to create temporary directory"
    return 1
  }

  tar -xzf "$archive" -C "$tmpdir" 2>/dev/null || {
    rm -rf "$tmpdir"
    dz::error "Failed to extract archive (not a valid DreamZSH profile?)"
    return 1
  }

  manifest_file="$tmpdir/manifest.txt"
  [[ -f "$manifest_file" ]] || {
    rm -rf "$tmpdir"
    dz::error "Archive does not contain a manifest (not a valid DreamZSH profile?)"
    return 1
  }

  while IFS='=' read -r key value; do
    case "$key" in
      profile) import_profile="$value" ;;
      theme)   import_theme="$value" ;;
      plugins) import_plugins=(${=value}) ;;
    esac
  done < "$manifest_file"

  [[ -n "$import_profile" ]] || {
    rm -rf "$tmpdir"
    dz::error "Manifest missing profile name"
    return 1
  }

  if dz::profile::exists "$import_profile"; then
    local overwrite
    printf "Profile '%s' already exists. Overwrite? [y/N]: " "$import_profile"
    read -r overwrite
    [[ "$overwrite" == [Yy] ]] || {
      dz::warn "Import cancelled."
      rm -rf "$tmpdir"
      return 0
    }
  fi

  if [[ -f "$tmpdir/themes/${import_theme}.zsh-theme" ]]; then
    cp "$tmpdir/themes/${import_theme}.zsh-theme" "$DREAMZSH_THEMES_DIR/" || {
      rm -rf "$tmpdir"
      dz::error "Failed to install theme: $import_theme"
      return 1
    }
    dz::success "Theme installed: $import_theme"
  fi

  local plugin
  for plugin in "${import_plugins[@]}"; do
    if [[ -d "$tmpdir/plugins/${plugin}" ]]; then
      if [[ -d "${DREAMZSH_PLUGINS_DIR}/${plugin}" ]]; then
        dz::warn "Plugin already exists, skipping: $plugin"
      else
        cp -r "$tmpdir/plugins/${plugin}" "${DREAMZSH_PLUGINS_DIR}/${plugin}" && {
          dz::success "Plugin installed: $plugin"
        }
      fi
    fi
  done

  cp "$tmpdir/profile/${import_profile}.profile" "$DREAMZSH_PROFILES_DIR/" || {
    rm -rf "$tmpdir"
    dz::error "Failed to install profile: $import_profile"
    return 1
  }

  rm -rf "$tmpdir"

  dz::success "Profile imported: $import_profile"

  if [[ "$apply_flag" == "--apply" ]]; then
    dz::profile::apply "$import_profile" || return 1
  else
    print -r -- ""
    dz::info "To apply this profile, run:"
    print -r -- "  dreamzsh profile apply $import_profile"
  fi
}
