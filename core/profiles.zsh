# dreamzsh/core/profiles.zsh

if [[ -n "${__DREAMZSH_PROFILES_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_PROFILES_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1

dz::profile::file() {
  local name="$1"
  if [[ -f "$DREAMZSH_CUSTOM_PROFILES_DIR/$name.profile" ]]; then
    print -r -- "$DREAMZSH_CUSTOM_PROFILES_DIR/$name.profile"
  else
    print -r -- "$DREAMZSH_PROFILES_DIR/$name.profile"
  fi
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
  local -A seen=()

  printf '%-14s %-8s %-14s %s\n' "PROFILE" "ACTIVE" "THEME" "PLUGINS"
  printf '%-14s %-8s %-14s %s\n' "-------" "------" "-----" "-------"

  for file in "$DREAMZSH_CUSTOM_PROFILES_DIR"/*.profile(N) "$DREAMZSH_PROFILES_DIR"/*.profile(N); do
    name="${file:t}"
    name="${name%.profile}"
    [[ -n "${seen[$name]:-}" ]] && continue
    seen[$name]=1

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

dz::profile::export_legacy() {
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

dz::profile::import_legacy() {
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
    mkdir -p "$DREAMZSH_CUSTOM_THEMES_DIR" || return 1
    cp "$tmpdir/themes/${import_theme}.zsh-theme" "$DREAMZSH_CUSTOM_THEMES_DIR/" || {
      rm -rf "$tmpdir"
      dz::error "Failed to install theme: $import_theme"
      return 1
    }
    dz::success "Theme installed: $import_theme"
  fi

  local plugin
  for plugin in "${import_plugins[@]}"; do
    if [[ -d "$tmpdir/plugins/${plugin}" ]]; then
      if dz::plugin_exists "$plugin"; then
        dz::warn "Plugin already exists, skipping: $plugin"
      else
        mkdir -p "$DREAMZSH_CUSTOM_PLUGINS_DIR" || return 1
        cp -r "$tmpdir/plugins/${plugin}" "${DREAMZSH_CUSTOM_PLUGINS_DIR}/${plugin}" && {
          dz::success "Plugin installed: $plugin"
        }
      fi
    fi
  done

  mkdir -p "$DREAMZSH_CUSTOM_PROFILES_DIR" || return 1
  cp "$tmpdir/profile/${import_profile}.profile" "$DREAMZSH_CUSTOM_PROFILES_DIR/" || {
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

dz::profile::manifest_value() {
  local manifest_file="$1"
  local wanted="$2"
  local key value

  while IFS='=' read -r key value; do
    if [[ "$key" == "$wanted" ]]; then
      print -r -- "$value"
      return 0
    fi
  done < "$manifest_file"
  return 1
}

dz::profile::sha256() {
  local file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{ print $1 }'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{ print $1 }'
  else
    dz::error "SHA-256 support requires sha256sum or shasum"
    return 1
  fi
}

dz::profile::has_sha256() {
  command -v sha256sum >/dev/null 2>&1 || command -v shasum >/dev/null 2>&1
}

dz::profile::safe_archive_members() {
  local archive="$1"
  local member part

  while IFS= read -r member; do
    [[ -n "$member" && "$member" != /* ]] || return 1
    for part in ${(s:/:)member}; do
      [[ "$part" != ".." ]] || return 1
    done
  done < <(tar -tzf "$archive" 2>/dev/null) || return 1
}

dz::profile::export() {
  local export_name="${1:-}"
  local output="" source_profile=""
  local profile_theme profile_file tmpdir archive_name
  local current_theme current_profile
  local -a current_plugins=() profile_plugins=() extra_themes=() package_themes=()
  local -a builtin_plugins=() custom_plugins=() external_plugins=()
  local theme plugin theme_file plugin_dir destination origin

  [[ -n "$export_name" ]] || {
    dz::error "Export profile name is required"
    return 1
  }
  dz::is_valid_name "$export_name" || {
    dz::error "Invalid export profile name: $export_name"
    return 1
  }
  shift

  while (( $# > 0 )); do
    case "$1" in
      --output)
        (( $# >= 2 )) || { dz::error "--output requires a path"; return 1; }
        output="$2"
        shift 2
        ;;
      --from)
        (( $# >= 2 )) || { dz::error "--from requires a profile name"; return 1; }
        source_profile="$2"
        shift 2
        ;;
      --include-theme)
        (( $# >= 2 )) || { dz::error "--include-theme requires a theme name"; return 1; }
        extra_themes+=("$2")
        shift 2
        ;;
      --*)
        dz::error "Unknown profile export option: $1"
        return 1
        ;;
      *)
        if [[ -z "$output" ]]; then
          output="$1"
          shift
        else
          dz::error "Unexpected profile export argument: $1"
          return 1
        fi
        ;;
    esac
  done

  if [[ -n "$source_profile" ]]; then
    dz::is_valid_name "$source_profile" || {
      dz::error "Invalid source profile name: $source_profile"
      return 1
    }
    profile_file="$(dz::profile::file "$source_profile")"
    [[ -f "$profile_file" ]] || {
      dz::error "Profile not found: $source_profile"
      return 1
    }

    current_theme="$DREAMZSH_THEME"
    current_profile="$DREAMZSH_PROFILE"
    current_plugins=("${DREAMZSH_PLUGINS[@]}")
    unset DREAMZSH_THEME DREAMZSH_PLUGINS
    source "$profile_file" || {
      DREAMZSH_THEME="$current_theme"
      DREAMZSH_PROFILE="$current_profile"
      DREAMZSH_PLUGINS=("${current_plugins[@]}")
      dz::error "Failed to load profile: $source_profile"
      return 1
    }
    profile_theme="${DREAMZSH_THEME:-}"
    profile_plugins=("${DREAMZSH_PLUGINS[@]}")
    DREAMZSH_THEME="$current_theme"
    DREAMZSH_PROFILE="$current_profile"
    DREAMZSH_PLUGINS=("${current_plugins[@]}")
  else
    profile_theme="$DREAMZSH_THEME"
    profile_plugins=("${DREAMZSH_PLUGINS[@]}")
    source_profile="current"
  fi

  [[ -n "$profile_theme" ]] || {
    dz::error "Current state does not define a theme"
    return 1
  }
  dz::theme_exists "$profile_theme" || {
    dz::error "Theme not found: $profile_theme"
    return 1
  }

  package_themes=("$profile_theme" "${extra_themes[@]}")
  package_themes=($(dz::unique_array "${package_themes[@]}"))
  for theme in "${package_themes[@]}"; do
    dz::is_valid_name "$theme" && dz::theme_exists "$theme" || {
      dz::error "Theme not found or invalid: $theme"
      return 1
    }
  done

  for plugin in "${profile_plugins[@]}"; do
    dz::plugin_exists "$plugin" || {
      dz::error "Plugin not found: $plugin"
      return 1
    }
    origin="$(dz::plugin_origin "$plugin")"
    if [[ "$origin" == "builtin" ]]; then
      builtin_plugins+=("$plugin")
    else
      custom_plugins+=("$plugin")
      [[ "$origin" == "external" ]] && external_plugins+=("$plugin")
    fi
  done

  dz::profile::has_sha256 || {
    dz::error "SHA-256 support requires sha256sum or shasum"
    return 1
  }

  [[ -n "$output" ]] || output="${export_name}-dreamzsh-profile.tar.gz"
  tmpdir="$(mktemp -d)" || return 1
  mkdir -p "$tmpdir/profile" "$tmpdir/themes" "$tmpdir/plugins" || {
    rm -rf -- "$tmpdir"
    return 1
  }

  cat > "$tmpdir/profile/${export_name}.profile" <<EOF
DREAMZSH_THEME="${profile_theme}"
DREAMZSH_PLUGINS=(${(j: :)${(q)profile_plugins[@]}})
EOF

  for theme in "${package_themes[@]}"; do
    theme_file="$(dz::theme_file "$theme")"
    cp -- "$theme_file" "$tmpdir/themes/$theme.zsh-theme" || {
      rm -rf -- "$tmpdir"
      return 1
    }
  done

  for plugin in "${custom_plugins[@]}"; do
    plugin_dir="$(dz::plugin_dir "$plugin")"
    destination="$tmpdir/plugins/$plugin"
    if dz::plugin::is_external "$plugin"; then
      mkdir -p "$destination/source" || { rm -rf -- "$tmpdir"; return 1; }
      cp -- "$plugin_dir/plugin.zsh" "$plugin_dir/plugin.meta" \
        "$plugin_dir/source.meta" "$destination/" || {
        rm -rf -- "$tmpdir"
        return 1
      }
      if [[ -d "$plugin_dir/source/.git" ]]; then
        git -C "$plugin_dir/source" archive HEAD \
          | tar -x -C "$destination/source" || {
          rm -rf -- "$tmpdir"
          dz::error "Failed to snapshot external plugin: $plugin"
          return 1
        }
      else
        cp -R "$plugin_dir/source/." "$destination/source/" || {
          rm -rf -- "$tmpdir"
          return 1
        }
      fi
    else
      cp -R -- "$plugin_dir" "$destination" || {
        rm -rf -- "$tmpdir"
        return 1
      }
      rm -rf -- "$destination/.git"
    fi
  done

  cat > "$tmpdir/manifest.txt" <<EOF
format_version=1
profile=$export_name
source_profile=$source_profile
active_theme=$profile_theme
themes=${package_themes[*]}
builtin_plugins=${builtin_plugins[*]}
custom_plugins=${custom_plugins[*]}
external_plugins=${external_plugins[*]}
exported_by=${USER:-unknown}
exported_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
dreamzsh_version=${DREAMZSH_VERSION:-unknown}
EOF

  (
    cd "$tmpdir" || exit 1
    local checksum_path checksum_hash
    local -a checksum_files=(
      manifest.txt
      profile/**/*(.N)
      themes/**/*(.N)
      plugins/**/*(.N)
    )
    for checksum_path in "${checksum_files[@]}"; do
      checksum_hash="$(dz::profile::sha256 "$checksum_path")" || exit 1
      print -r -- "$checksum_hash  $checksum_path"
    done > checksums.sha256
  ) || {
    rm -rf -- "$tmpdir"
    dz::error "Failed to create profile checksums"
    return 1
  }

  archive_name="${output:t}"
  (
    cd "$tmpdir" || exit 1
    tar -czf "$archive_name" manifest.txt checksums.sha256 profile themes plugins
  ) || {
    rm -rf -- "$tmpdir"
    dz::error "Failed to create profile archive"
    return 1
  }

  mv -- "$tmpdir/$archive_name" "$output" || {
    rm -rf -- "$tmpdir"
    dz::error "Failed to move profile archive to: $output"
    return 1
  }
  rm -rf -- "$tmpdir"

  dz::success "Current state exported as profile: $export_name"
  dz::info "Archive: $output"
}

dz::profile::install_file() {
  local source_file="$1"
  local destination="$2"
  local overwrite="$3"
  local origin="$4"
  local temporary

  if [[ -e "$destination" ]]; then
    cmp -s -- "$source_file" "$destination" && return 0
    if [[ "$origin" == "builtin" || "$overwrite" -ne 1 ]]; then
      dz::error "Import conflict: $destination"
      return 1
    fi
  fi

  mkdir -p "${destination:h}" || return 1
  temporary="${destination}.import.$$"
  cp -- "$source_file" "$temporary" || return 1
  mv -f -- "$temporary" "$destination" || { rm -f -- "$temporary"; return 1; }
}

dz::profile::install_dir() {
  local source_dir="$1"
  local destination="$2"
  local overwrite="$3"
  local origin="$4"
  local temporary old_destination=""

  if [[ -d "$destination" ]]; then
    diff -qr -- "$source_dir" "$destination" >/dev/null 2>&1 && return 0
    if [[ "$origin" == "builtin" || "$overwrite" -ne 1 ]]; then
      dz::error "Import conflict: $destination"
      return 1
    fi
  fi

  mkdir -p "${destination:h}" || return 1
  temporary="${destination}.import.$$"
  rm -rf -- "$temporary"
  cp -R -- "$source_dir" "$temporary" || return 1
  if [[ -d "$destination" ]]; then
    old_destination="${destination}.old.$$"
    mv -- "$destination" "$old_destination" || { rm -rf -- "$temporary"; return 1; }
  fi
  if ! mv -- "$temporary" "$destination"; then
    [[ -n "$old_destination" ]] && mv -- "$old_destination" "$destination" 2>/dev/null || true
    rm -rf -- "$temporary"
    return 1
  fi
  if [[ -n "$old_destination" ]]; then
    rm -rf -- "$old_destination"
  fi
  return 0
}

dz::profile::import() {
  local archive="${1:-}"
  local apply_flag=0 overwrite=0 assume_yes=0
  local tmpdir manifest_file format_version import_profile active_theme answer=""
  local -a themes=() builtin_plugins=() custom_plugins=() external_plugins=()
  local -a imported_plugins=()
  local theme plugin source_file destination origin checksum_path checksum_hash
  local manifest_themes manifest_builtin manifest_custom manifest_external
  local source_meta source_url source_ref source_entry source_commit normalized_source

  [[ -n "$archive" && -f "$archive" ]] || {
    dz::error "Profile archive not found: $archive"
    return 1
  }
  shift

  while (( $# > 0 )); do
    case "$1" in
      --apply) apply_flag=1 ;;
      --overwrite) overwrite=1 ;;
      --yes) assume_yes=1 ;;
      *) dz::error "Unknown profile import option: $1"; return 1 ;;
    esac
    shift
  done

  dz::profile::safe_archive_members "$archive" || {
    dz::error "Archive contains unsafe paths or is invalid"
    return 1
  }

  tmpdir="$(mktemp -d)" || return 1
  tar --no-same-owner --no-same-permissions -xzf "$archive" -C "$tmpdir" || {
    rm -rf -- "$tmpdir"
    dz::error "Failed to extract profile archive"
    return 1
  }

  if [[ -n "$(find "$tmpdir" \( -type l -o ! -type f ! -type d \) -print -quit 2>/dev/null)" ]]; then
    rm -rf -- "$tmpdir"
    dz::error "Profile archive contains unsupported file types"
    return 1
  fi

  manifest_file="$tmpdir/manifest.txt"
  [[ -f "$manifest_file" ]] || { rm -rf -- "$tmpdir"; dz::error "Manifest missing"; return 1; }
  format_version="$(dz::profile::manifest_value "$manifest_file" format_version 2>/dev/null)"
  if [[ -z "$format_version" ]]; then
    rm -rf -- "$tmpdir"
    dz::warn "Importing legacy profile archive without checksums"
    dz::profile::import_legacy "$archive" "$([[ $apply_flag -eq 1 ]] && print -- --apply)"
    return $?
  fi
  [[ "$format_version" == "1" ]] || {
    rm -rf -- "$tmpdir"
    dz::error "Unsupported profile format: $format_version"
    return 1
  }

  [[ -f "$tmpdir/checksums.sha256" ]] || {
    rm -rf -- "$tmpdir"
    dz::error "Profile checksums are missing"
    return 1
  }
  dz::profile::has_sha256 || {
    rm -rf -- "$tmpdir"
    dz::error "SHA-256 support requires sha256sum or shasum"
    return 1
  }
  while IFS=' ' read -r checksum_hash checksum_path; do
    checksum_path="${checksum_path# }"
    [[ "$checksum_path" != /* && "$checksum_path" != *"../"* ]] || {
      rm -rf -- "$tmpdir"
      dz::error "Unsafe checksum path: $checksum_path"
      return 1
    }
    [[ "$(dz::profile::sha256 "$tmpdir/$checksum_path")" == "$checksum_hash" ]] || {
      rm -rf -- "$tmpdir"
      dz::error "Profile checksum verification failed: $checksum_path"
      return 1
    }
  done < "$tmpdir/checksums.sha256"

  import_profile="$(dz::profile::manifest_value "$manifest_file" profile)"
  active_theme="$(dz::profile::manifest_value "$manifest_file" active_theme)"
  manifest_themes="$(dz::profile::manifest_value "$manifest_file" themes)"
  manifest_builtin="$(dz::profile::manifest_value "$manifest_file" builtin_plugins)"
  manifest_custom="$(dz::profile::manifest_value "$manifest_file" custom_plugins)"
  manifest_external="$(dz::profile::manifest_value "$manifest_file" external_plugins)"
  themes=(${=manifest_themes})
  builtin_plugins=(${=manifest_builtin})
  custom_plugins=(${=manifest_custom})
  external_plugins=(${=manifest_external})
  imported_plugins=("${builtin_plugins[@]}" "${custom_plugins[@]}")

  dz::is_valid_name "$import_profile" || { rm -rf -- "$tmpdir"; dz::error "Invalid profile name"; return 1; }
  dz::is_valid_name "$active_theme" || { rm -rf -- "$tmpdir"; dz::error "Invalid active theme"; return 1; }
  [[ -f "$tmpdir/profile/$import_profile.profile" ]] || {
    rm -rf -- "$tmpdir"; dz::error "Packaged profile file is missing"; return 1
  }
  for theme in "${themes[@]}"; do
    dz::is_valid_name "$theme" && [[ -f "$tmpdir/themes/$theme.zsh-theme" ]] || {
      rm -rf -- "$tmpdir"; dz::error "Invalid packaged theme: $theme"; return 1
    }
  done
  for plugin in "${builtin_plugins[@]}"; do
    dz::is_valid_name "$plugin" && [[ -f "$DREAMZSH_PLUGINS_DIR/$plugin/plugin.zsh" ]] || {
      rm -rf -- "$tmpdir"; dz::error "Required built-in plugin is missing: $plugin"; return 1
    }
  done
  dz::array_contains "$active_theme" "${themes[@]}" || {
    rm -rf -- "$tmpdir"; dz::error "Active theme is not included in the package"; return 1
  }
  for plugin in "${custom_plugins[@]}"; do
    dz::is_valid_name "$plugin" && [[ -f "$tmpdir/plugins/$plugin/plugin.zsh" ]] || {
      rm -rf -- "$tmpdir"; dz::error "Invalid packaged plugin: $plugin"; return 1
    }
  done
  for plugin in "${external_plugins[@]}"; do
    dz::array_contains "$plugin" "${custom_plugins[@]}" || {
      rm -rf -- "$tmpdir"; dz::error "External plugin is not bundled: $plugin"; return 1
    }
    source_meta="$tmpdir/plugins/$plugin/source.meta"
    [[ -f "$source_meta" ]] || {
      rm -rf -- "$tmpdir"; dz::error "External plugin metadata is missing: $plugin"; return 1
    }
    source_url="$(awk -F= '$1 == "url" { sub(/^[^=]*=/, ""); print; exit }' "$source_meta")"
    source_ref="$(awk -F= '$1 == "ref" { sub(/^[^=]*=/, ""); print; exit }' "$source_meta")"
    source_commit="$(awk -F= '$1 == "commit" { print $2; exit }' "$source_meta")"
    source_entry="$(awk -F= '$1 == "entrypoint" { sub(/^[^=]*=/, ""); print; exit }' "$source_meta")"
    normalized_source="$(dz::plugin::normalize_source "$source_url")" || { rm -rf -- "$tmpdir"; return 1; }
    [[ "$normalized_source" == "$source_url" ]] || {
      rm -rf -- "$tmpdir"; dz::error "Invalid external source URL: $source_url"; return 1
    }
    dz::plugin::valid_ref "$source_ref" || {
      rm -rf -- "$tmpdir"; dz::error "Invalid external plugin ref: $source_ref"; return 1
    }
    dz::plugin::valid_entrypoint "$source_entry" \
      && [[ -f "$tmpdir/plugins/$plugin/source/$source_entry" ]] || {
      rm -rf -- "$tmpdir"; dz::error "Invalid external plugin entrypoint: $plugin"; return 1
    }
    [[ "$source_commit" =~ '^[0-9a-fA-F]{40}$' ]] || {
      rm -rf -- "$tmpdir"; dz::error "Invalid external plugin commit: $plugin"; return 1
    }
  done

  print -r -- "Profile: $import_profile"
  print -r -- "Active theme: $active_theme"
  print -r -- "Themes: ${themes[*]:--}"
  print -r -- "Built-in plugins: ${builtin_plugins[*]:--}"
  print -r -- "Bundled plugins: ${custom_plugins[*]:--}"
  print -r -- "External plugins: ${external_plugins[*]:--}"
  for plugin in "${external_plugins[@]}"; do
    source_meta="$tmpdir/plugins/$plugin/source.meta"
    source_url="$(awk -F= '$1 == "url" { sub(/^[^=]*=/, ""); print; exit }' "$source_meta")"
    source_commit="$(awk -F= '$1 == "commit" { print $2; exit }' "$source_meta")"
    print -r -- "  $plugin: $source_url @ ${source_commit[1,12]}"
  done

  if (( ! assume_yes )); then
    [[ -t 0 ]] || { rm -rf -- "$tmpdir"; dz::error "Confirmation required. Re-run with --yes."; return 1; }
    printf "Import this profile package? [y/N]: "
    read -r answer
    [[ "$answer" == [Yy] ]] || { rm -rf -- "$tmpdir"; dz::warn "Import cancelled."; return 0; }
  fi

  for theme in "${themes[@]}"; do
    source_file="$tmpdir/themes/$theme.zsh-theme"
    origin="$(dz::theme_origin "$theme")"
    if [[ "$origin" == "builtin" ]]; then
      destination="$DREAMZSH_THEMES_DIR/$theme.zsh-theme"
    else
      destination="$DREAMZSH_CUSTOM_THEMES_DIR/$theme.zsh-theme"
    fi
    dz::profile::install_file "$source_file" "$destination" "$overwrite" "$origin" || {
      rm -rf -- "$tmpdir"; return 1
    }
  done

  for plugin in "${custom_plugins[@]}"; do
    origin="$(dz::plugin_origin "$plugin")"
    [[ "$origin" != "builtin" ]] || { rm -rf -- "$tmpdir"; dz::error "Plugin conflicts with built-in: $plugin"; return 1; }
    dz::profile::install_dir "$tmpdir/plugins/$plugin" \
      "$DREAMZSH_CUSTOM_PLUGINS_DIR/$plugin" "$overwrite" "$origin" || {
      rm -rf -- "$tmpdir"; return 1
    }
  done

  origin="missing"
  [[ -f "$DREAMZSH_PROFILES_DIR/$import_profile.profile" ]] && origin="builtin"
  [[ -f "$DREAMZSH_CUSTOM_PROFILES_DIR/$import_profile.profile" ]] && origin="custom"
  cat > "$tmpdir/imported.profile" <<EOF
DREAMZSH_THEME="$active_theme"
DREAMZSH_PLUGINS=(${(j: :)${(q)imported_plugins[@]}})
EOF
  dz::profile::install_file "$tmpdir/imported.profile" \
    "$DREAMZSH_CUSTOM_PROFILES_DIR/$import_profile.profile" "$overwrite" "$origin" || {
    rm -rf -- "$tmpdir"; return 1
  }

  rm -rf -- "$tmpdir"
  dz::success "Profile imported: $import_profile"
  if (( apply_flag )); then
    dz::profile::apply "$import_profile" || return 1
  else
    dz::info "Apply it with: dreamzsh profile apply $import_profile"
  fi
}
