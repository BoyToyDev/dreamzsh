# dreamzsh/core/theme.zsh

if [[ -n "${__DREAMZSH_THEME_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_THEME_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1

dz::theme::list() {
  local file name
  [[ -d "$DREAMZSH_THEMES_DIR" ]] || return 0

  for file in "$DREAMZSH_THEMES_DIR"/*.zsh-theme(N); do
    name="${file:t}"
    name="${name%.zsh-theme}"
    print -r -- "$name"
  done
}

dz::theme::current() {
  print -r -- "$DREAMZSH_THEME"
}

dz::theme::reset_runtime() {
  RPROMPT=''

  if typeset -f add-zsh-hook >/dev/null 2>&1; then
    add-zsh-hook -d precmd build_prompt 2>/dev/null || true
    add-zsh-hook -d precmd dz_build_dream_smart_prompt 2>/dev/null || true
  fi

  unfunction build_prompt 2>/dev/null || true
  unfunction dz_build_dream_smart_prompt 2>/dev/null || true
  unfunction dz_git_prompt_info 2>/dev/null || true
  unfunction dz_git_branch 2>/dev/null || true
  unfunction dz_segment 2>/dev/null || true
  unfunction dz_prompt_user_color 2>/dev/null || true
  unfunction dz_prompt_git_branch 2>/dev/null || true
  unfunction dz::theme::apply 2>/dev/null || true
}

dz::theme::apply_by_name() {
  local theme="$1"
  local theme_file

  [[ -n "$theme" ]] || {
    dz::error "Theme name is required"
    return 1
  }

  dz::is_valid_name "$theme" || {
    dz::error "Invalid theme name: $theme"
    return 1
  }

  theme_file="$(dz::theme_file "$theme")"

  [[ -f "$theme_file" ]] || {
    dz::error "Theme not found: $theme"
    return 1
  }

  dz::theme::reset_runtime

  source "$theme_file" || {
    dz::warn "Failed to load theme: $theme"
    return 1
  }

  if typeset -f dz::theme::apply >/dev/null 2>&1; then
    dz::theme::apply
  fi
}

dz::theme::set() {
  local theme="$1"

  [[ -n "$theme" ]] || {
    dz::error "Theme name is required"
    return 1
  }

  dz::is_valid_name "$theme" || {
    dz::error "Invalid theme name: $theme"
    return 1
  }

  dz::theme_exists "$theme" || {
    dz::error "Theme not found: $theme"
    return 1
  }

  DREAMZSH_THEME="$theme"
  dz::config::save || return 1
  dz::success "Theme set to: $theme"
}

dz::theme::preview() {
  local theme="$1"

  dz::theme::apply_by_name "$theme" || return 1
  dz::success "Previewing theme: $theme"
  dz::info "Run 'dreamzsh reload' to return to saved theme, or 'dreamzsh theme set $theme' to keep it."
}

dz::theme::load() {
  [[ -n "$DREAMZSH_THEME" ]] || return 0
  dz::theme::apply_by_name "$DREAMZSH_THEME"
}
