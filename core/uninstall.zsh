# dreamzsh/core/uninstall.zsh

if [[ -n "${__DREAMZSH_UNINSTALL_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_UNINSTALL_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1

dz::uninstall::run() {
  local zshrc="${HOME}/.zshrc"
  local block_start="# >>> dreamzsh >>>"
  local block_end="# <<< dreamzsh <<<"
  local confirm

  cat <<EOF

${DZ_COLOR_RED}╔══════════════════════════════════════╗
║       Uninstall DreamZSH             ║
╚══════════════════════════════════════╝${DZ_COLOR_RESET}

This will:
  1. Remove the DreamZSH block from ${zshrc}
  2. Leave ${DREAMZSH_DIR} intact (your plugins, themes, backups)

EOF

  printf "Continue? [y/N]: "
  read -r confirm
  [[ "$confirm" == [Yy] ]] || {
    dz::warn "Uninstall cancelled."
    return 0
  }

  if [[ ! -f "$zshrc" ]]; then
    dz::warn "$zshrc not found. Nothing to remove."
    return 0
  fi

  if ! grep -Fq "$block_start" "$zshrc"; then
    dz::warn "DreamZSH block not found in $zshrc"
    return 0
  fi

  local tmp_file
  tmp_file="$(mktemp)" || {
    dz::error "Failed to create temporary file"
    return 1
  }

  local in_block=0
  while IFS= read -r line; do
    if [[ "$line" == "$block_start" ]]; then
      in_block=1
      continue
    fi
    if [[ "$line" == "$block_end" ]]; then
      in_block=0
      continue
    fi
    (( in_block )) && continue
    print -r -- "$line" >> "$tmp_file"
  done < "$zshrc"

  mv "$tmp_file" "$zshrc" || {
    dz::error "Failed to update $zshrc"
    rm -f "$tmp_file"
    return 1
  }

  dz::success "DreamZSH block removed from $zshrc"
  print -r -- ""
  dz::info "DreamZSH files remain at: $DREAMZSH_DIR"
  dz::info "To completely remove: rm -rf $DREAMZSH_DIR"
  dz::info "Run 'exec zsh' to start a fresh shell."
}

dz::uninstall::purge() {
  local confirm

  cat <<EOF

${DZ_COLOR_RED}╔══════════════════════════════════════╗
║       PURGE DreamZSH                 ║
╚══════════════════════════════════════╝${DZ_COLOR_RESET}

This will DELETE:
  1. The DreamZSH block from ${HOME}/.zshrc
  2. ALL DreamZSH files: ${DREAMZSH_DIR}
     (including plugins, themes, profiles, backups)

EOF

  printf "Type 'yes' to confirm: "
  read -r confirm
  if [[ "$confirm" != "yes" ]]; then
    dz::warn "Purge cancelled."
    return 0
  fi

  dz::uninstall::run || return 1

  rm -rf "$DREAMZSH_DIR" || {
    dz::error "Failed to remove $DREAMZSH_DIR"
    return 1
  }

  dz::success "DreamZSH completely removed."
  dz::info "Run 'exec zsh' to start a fresh shell."
}
