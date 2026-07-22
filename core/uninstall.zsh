# dreamzsh/core/uninstall.zsh

if [[ -n "${__DREAMZSH_UNINSTALL_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_UNINSTALL_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1

dz::uninstall::remove_block() {
  local zshrc="${ZDOTDIR:-$HOME}/.zshrc"
  local block_start="# >>> dreamzsh >>>"
  local block_end="# <<< dreamzsh <<<"
  local tmp_file line
  local in_block=0 found_start=0 found_end=0

  if [[ ! -f "$zshrc" ]]; then
    dz::warn "$zshrc not found. Nothing to remove."
    return 0
  fi
  if ! grep -Fq "$block_start" "$zshrc"; then
    dz::warn "DreamZSH block not found in $zshrc"
    return 0
  fi

  tmp_file="$(mktemp "${zshrc}.dreamzsh.XXXXXX")" || {
    dz::error "Failed to create a temporary file beside $zshrc"
    return 1
  }
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "$block_start" ]]; then
      (( ++found_start ))
      in_block=1
      continue
    fi
    if [[ "$line" == "$block_end" ]]; then
      (( ++found_end ))
      in_block=0
      continue
    fi
    (( in_block )) || print -r -- "$line" >> "$tmp_file"
  done < "$zshrc"

  if (( found_start != found_end || in_block )); then
    rm -f -- "$tmp_file"
    dz::error "The DreamZSH block in $zshrc is incomplete; no changes were made."
    return 1
  fi
  chmod --reference="$zshrc" "$tmp_file" 2>/dev/null || chmod 600 "$tmp_file" 2>/dev/null || true
  mv -f -- "$tmp_file" "$zshrc" || {
    rm -f -- "$tmp_file"
    dz::error "Failed to update $zshrc"
    return 1
  }
  dz::success "DreamZSH block removed from $zshrc"
}

dz::uninstall::run() {
  local assume_yes=0 confirm
  [[ "${1:-}" == "--yes" ]] && assume_yes=1

  cat <<EOF

${DZ_COLOR_RED}╔══════════════════════════════════════╗
║       Uninstall DreamZSH             ║
╚══════════════════════════════════════╝${DZ_COLOR_RESET}

This removes the DreamZSH block from ${ZDOTDIR:-$HOME}/.zshrc.
Your plugins, themes, profiles, and backups remain in ${DREAMZSH_DIR}.

EOF

  if (( ! assume_yes )); then
    printf "Continue? [y/N]: "
    read -r confirm
    [[ "$confirm" == [Yy] ]] || { dz::warn "Uninstall cancelled."; return 0; }
  fi

  dz::uninstall::remove_block || return 1
  dz::info "DreamZSH files remain at: $DREAMZSH_DIR"
  dz::info "Run 'exec zsh' to start a fresh shell."
}

dz::uninstall::purge() {
  local assume_yes=0 confirm parent_dir
  [[ "${1:-}" == "--yes" ]] && assume_yes=1

  cat <<EOF

${DZ_COLOR_RED}╔══════════════════════════════════════╗
║       PURGE DreamZSH                 ║
╚══════════════════════════════════════╝${DZ_COLOR_RESET}

This removes the DreamZSH block from ${ZDOTDIR:-$HOME}/.zshrc and permanently
deletes ${DREAMZSH_DIR}, including custom plugins, themes, profiles, and backups.

EOF

  if (( ! assume_yes )); then
    printf "Type 'yes' to confirm: "
    read -r confirm
    [[ "$confirm" == "yes" ]] || { dz::warn "Purge cancelled."; return 0; }
  fi

  dz::uninstall::remove_block || return 1
  parent_dir="${DREAMZSH_DIR:h}"
  rm -rf -- "$DREAMZSH_DIR" || {
    dz::error "Failed to remove $DREAMZSH_DIR"
    return 1
  }
  dz::success "DreamZSH completely removed."
  dz::info "Run 'exec zsh' to start a fresh shell."
  cd "$parent_dir" 2>/dev/null || true
}
