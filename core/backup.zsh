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
  local archive_name archive_path
  local -a components=()
  local -a tar_items=()
  local answer

  while (( $# > 0 )); do
    case "$1" in
      --all)
        components=(config profiles plugins themes)
        shift
        ;;
      --only)
        shift
        for item in ${(s:,:)1}; do
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

  for item in "${components[@]}"; do
    case "$item" in
      config) [[ -f "$DREAMZSH_CONFIG_FILE" ]] && tar_items+=("dreamzsh.conf") ;;
      profiles) [[ -d "$DREAMZSH_PROFILES_DIR" ]] && tar_items+=("profiles") ;;
      plugins) [[ -d "$DREAMZSH_PLUGINS_DIR" ]] && tar_items+=("plugins") ;;
      themes) [[ -d "$DREAMZSH_THEMES_DIR" ]] && tar_items+=("themes") ;;
    esac
  done

  archive_name="backup-$(date +%F_%H-%M-%S).tar.gz"
  archive_path="$DREAMZSH_BACKUPS_DIR/$archive_name"

  (
    cd "$DREAMZSH_DIR"
    tar -czf "$archive_path" "${tar_items[@]}"
  ) || {
    dz::error "Failed to create backup archive."
    return 1
  }

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
  local archive_path confirm

  [[ -n "$archive_name" ]] || {
    dz::error "Missing backup archive name."
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

  tar -xzf "$archive_path" -C "$DREAMZSH_DIR" || {
    dz::error "Failed to restore backup."
    return 1
  }

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