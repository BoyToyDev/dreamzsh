# dreamzsh/core/backup.zsh

if [[ -n "${__DREAMZSH_BACKUP_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_BACKUP_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1

: "${DREAMZSH_BACKUPS_DIR:=$DREAMZSH_DIR/backups}"

dz::backup::ensure_dir() {
  dz::ensure_dir "$DREAMZSH_BACKUPS_DIR"
}

dz::backup::create() {
  local archive_name archive_path tmpdir item source
  local -a components=()
  local -a staged_files=()
  local answer

  while (( $# > 0 )); do
    case "$1" in
      --all)
        components=(config profiles plugins themes)
        shift
        ;;
      --only)
        (( $# >= 2 )) || {
          dz::error "--only requires a comma-separated component list"
          return 1
        }
        shift
        for item in ${(s:,:)1}; do
          [[ "$item" == config || "$item" == profiles || "$item" == plugins || "$item" == themes ]] || {
            dz::error "Unknown backup component: $item"
            return 1
          }
          components+=("$item")
        done
        shift
        ;;
      *)
        dz::error "Unknown backup create option: $1"
        return 1
        ;;
    esac
  done

  if (( ${#components[@]} == 0 )); then
    print -r -- "Select what to include in backup."

    printf "Include config? [Y/n]: "
    read -r answer
    [[ -z "$answer" || "$answer" == [Yy] ]] && components+=(config)

    printf "Include profiles? [Y/n]: "
    read -r answer
    [[ -z "$answer" || "$answer" == [Yy] ]] && components+=(profiles)

    printf "Include plugins? [Y/n]: "
    read -r answer
    [[ -z "$answer" || "$answer" == [Yy] ]] && components+=(plugins)

    printf "Include themes? [Y/n]: "
    read -r answer
    [[ -z "$answer" || "$answer" == [Yy] ]] && components+=(themes)
  fi

  (( ${#components[@]} > 0 )) || {
    dz::error "No components selected for backup."
    return 1
  }

  dz::backup::ensure_dir || return 1

  tmpdir="$(mktemp -d)" || {
    dz::error "Failed to create backup staging directory"
    return 1
  }

  for item in "${components[@]}"; do
    case "$item" in
      config)
        if [[ -f "$DREAMZSH_CONFIG_FILE" ]]; then
          cp -- "$DREAMZSH_CONFIG_FILE" "$tmpdir/dreamzsh.conf" || {
            rm -rf -- "$tmpdir"
            dz::error "Failed to stage DreamZSH config"
            return 1
          }
        fi
        ;;
      profiles)
        source="$DREAMZSH_CUSTOM_PROFILES_DIR"
        if [[ -d "$source" ]]; then
          mkdir -p "$tmpdir/custom" \
            && cp -R -- "$source" "$tmpdir/custom/profiles" || {
              rm -rf -- "$tmpdir"
              dz::error "Failed to stage custom profiles"
              return 1
            }
        fi
        ;;
      plugins)
        source="$DREAMZSH_CUSTOM_PLUGINS_DIR"
        if [[ -d "$source" ]]; then
          mkdir -p "$tmpdir/custom" \
            && cp -R -- "$source" "$tmpdir/custom/plugins" || {
              rm -rf -- "$tmpdir"
              dz::error "Failed to stage custom plugins"
              return 1
            }
        fi
        if [[ -f "$DREAMZSH_PLUGIN_REPOS_FILE" ]]; then
          mkdir -p "$tmpdir/custom" \
            && cp -- "$DREAMZSH_PLUGIN_REPOS_FILE" "$tmpdir/custom/plugin-repos.conf" || {
              rm -rf -- "$tmpdir"
              dz::error "Failed to stage plugin repository config"
              return 1
            }
        fi
        ;;
      themes)
        source="$DREAMZSH_CUSTOM_THEMES_DIR"
        if [[ -d "$source" ]]; then
          mkdir -p "$tmpdir/custom" \
            && cp -R -- "$source" "$tmpdir/custom/themes" || {
              rm -rf -- "$tmpdir"
              dz::error "Failed to stage custom themes"
              return 1
            }
        fi
        ;;
    esac
  done

  staged_files=("$tmpdir"/**/*(.N))
  if (( ${#staged_files[@]} == 0 )); then
    rm -rf -- "$tmpdir"
    dz::error "Selected backup components do not contain any files"
    return 1
  fi

  archive_name="backup-$(date +%F_%H-%M-%S).tar.gz"
  archive_path="$DREAMZSH_BACKUPS_DIR/$archive_name"
  [[ ! -e "$archive_path" ]] || {
    archive_name="backup-$(date +%F_%H-%M-%S)-$$.tar.gz"
    archive_path="$DREAMZSH_BACKUPS_DIR/$archive_name"
  }

  (
    cd "$tmpdir" || exit 1
    tar -czf "$archive_path" .
  ) || {
    rm -rf -- "$tmpdir"
    dz::error "Failed to create backup archive."
    return 1
  }
  rm -rf -- "$tmpdir"

  dz::success "Backup created: $archive_name"
}

dz::backup::list() {
  local file
  dz::backup::ensure_dir || return 1

  print -r -- "AVAILABLE BACKUPS"
  print -r -- "-----------------"

  for file in "$DREAMZSH_BACKUPS_DIR"/*.tar.gz(N); do
    print -r -- "${file:t}"
  done
}

dz::backup::restore() {
  local archive_name="$1"
  local archive_path confirm tmpdir line member part type source destination staged old
  local config_destination
  local -a sources=() destinations=() installed_destinations=() old_destinations=()

  [[ -n "$archive_name" ]] || {
    dz::error "Missing backup archive name."
    return 1
  }

  [[ "${archive_name:t}" == "$archive_name" && "$archive_name" == *.tar.gz ]] || {
    dz::error "Invalid backup archive name: $archive_name"
    return 1
  }

  archive_path="$DREAMZSH_BACKUPS_DIR/$archive_name"
  [[ -f "$archive_path" ]] || {
    dz::error "Backup not found: $archive_name"
    return 1
  }

  printf "This will overwrite current DreamZSH files. Continue? [y/N]: "
  read -r confirm
  [[ "$confirm" == [Yy] ]] || {
    dz::warn "Restore cancelled."
    return 1
  }

  while IFS= read -r member; do
    [[ -n "$member" && "$member" != /* ]] || {
      dz::error "Backup contains an unsafe path"
      return 1
    }
    for part in ${(s:/:)member}; do
      [[ "$part" != ".." ]] || {
        dz::error "Backup contains an unsafe path: $member"
        return 1
      }
    done
  done < <(tar -tzf "$archive_path" 2>/dev/null) || {
    dz::error "Backup archive is invalid"
    return 1
  }

  while IFS= read -r line; do
    type="${line[1]}"
    [[ "$type" == "-" || "$type" == "d" ]] || {
      dz::error "Backup contains links or unsupported file types"
      return 1
    }
  done < <(LC_ALL=C tar -tvzf "$archive_path" 2>/dev/null) || {
    dz::error "Backup archive is invalid"
    return 1
  }

  tmpdir="$(mktemp -d)" || return 1
  tar -xzf "$archive_path" -C "$tmpdir" || {
    rm -rf -- "$tmpdir"
    dz::error "Failed to extract backup."
    return 1
  }

  if [[ -n "$(find "$tmpdir" \( -type l -o ! -type f ! -type d \) -print -quit 2>/dev/null)" ]]; then
    rm -rf -- "$tmpdir"
    dz::error "Backup contains unsupported file types"
    return 1
  fi

  config_destination="$DREAMZSH_CONFIG_FILE"
  [[ -L "$config_destination" ]] && config_destination="${config_destination:A}"
  [[ -f "$tmpdir/dreamzsh.conf" ]] && {
    sources+=("$tmpdir/dreamzsh.conf")
    destinations+=("$config_destination")
  }
  for member in custom/profiles custom/plugins custom/themes custom/plugin-repos.conf; do
    [[ -e "$tmpdir/$member" ]] || continue
    sources+=("$tmpdir/$member")
    case "$member" in
      custom/profiles) destinations+=("$DREAMZSH_CUSTOM_PROFILES_DIR") ;;
      custom/plugins) destinations+=("$DREAMZSH_CUSTOM_PLUGINS_DIR") ;;
      custom/themes) destinations+=("$DREAMZSH_CUSTOM_THEMES_DIR") ;;
      custom/plugin-repos.conf) destinations+=("$DREAMZSH_PLUGIN_REPOS_FILE") ;;
    esac
  done

  (( ${#sources[@]} > 0 )) || {
    rm -rf -- "$tmpdir"
    dz::error "Backup does not contain supported DreamZSH user data"
    return 1
  }

  for (( part=1; part<=${#sources[@]}; part++ )); do
    source="${sources[part]}"
    destination="${destinations[part]}"
    mkdir -p "${destination:h}" || break
    staged="${destination}.restore-new.$$"
    old="${destination}.restore-old.$$"
    rm -rf -- "$staged" "$old"
    cp -R -- "$source" "$staged" || { rm -rf -- "$staged"; break; }
    if [[ -e "$destination" || -L "$destination" ]]; then
      mv -- "$destination" "$old" || { rm -rf -- "$staged"; break; }
    else
      old=""
    fi
    if ! mv -- "$staged" "$destination"; then
      [[ -n "$old" ]] && mv -- "$old" "$destination" 2>/dev/null || true
      break
    fi
    installed_destinations+=("$destination")
    old_destinations+=("$old")
  done

  if (( ${#installed_destinations[@]} != ${#sources[@]} )); then
    for (( part=${#installed_destinations[@]}; part>=1; part-- )); do
      destination="${installed_destinations[part]}"
      old="${old_destinations[part]}"
      rm -rf -- "$destination"
      [[ -n "$old" ]] && mv -- "$old" "$destination" 2>/dev/null || true
    done
    rm -rf -- "$tmpdir"
    dz::error "Failed to restore backup; previous state was restored"
    return 1
  fi

  for old in "${old_destinations[@]}"; do
    [[ -n "$old" ]] && rm -rf -- "$old"
  done
  rm -rf -- "$tmpdir"

  dz::success "Backup restored: $archive_name"
}

dz::backup::clean() {
  local mode="${1:-keep}"
  local confirm
  local -a files=()
  local keep_count=10
  local i

  dz::backup::ensure_dir || return 1
  files=("$DREAMZSH_BACKUPS_DIR"/*.tar.gz(Nom))

  if [[ "$mode" == "--all" ]]; then
    printf "This will delete all backups. Continue? [y/N]: "
    read -r confirm
    [[ "$confirm" == [Yy] ]] || {
      dz::warn "Clean cancelled."
      return 1
    }
    rm -f -- "${files[@]}"
    dz::success "All backups deleted."
    return 0
  fi

  if (( ${#files[@]} <= keep_count )); then
    dz::info "Nothing to clean. Backups count: ${#files[@]}"
    return 0
  fi

  printf "Keep last %d backups and delete older ones? [y/N]: " "$keep_count"
  read -r confirm
  [[ "$confirm" == [Yy] ]] || {
    dz::warn "Clean cancelled."
    return 1
  }

  for (( i=keep_count+1; i<=${#files[@]}; i++ )); do
    rm -f -- "${files[i]}"
  done

  dz::success "Old backups cleaned."
}
