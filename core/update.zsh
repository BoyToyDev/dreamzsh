# dreamzsh/core/update.zsh

if [[ -n "${__DREAMZSH_UPDATE_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_UPDATE_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1

dz::update::run() {
  local repo_dir="${DREAMZSH_DIR}"
  local before after

  if [[ ! -d "$repo_dir/.git" ]]; then
    dz::error "DreamZSH was not installed via git. Cannot auto-update."
    dz::info "Reinstall with: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/BoyToyDev/dreamzsh/master/install.sh)\""
    return 1
  fi

  dz::info "Checking for updates..."

  cd "$repo_dir" || return 1

  git fetch origin master 2>&1 || {
    dz::error "Failed to fetch updates. Check your network connection."
    return 1
  }

  before="$(git rev-parse HEAD)"
  after="$(git rev-parse origin/master)"

  if [[ "$before" == "$after" ]]; then
    dz::success "DreamZSH is already up to date."
    return 0
  fi

  dz::info "New version available. Updating..."

  git pull --ff-only origin master 2>&1 || {
    dz::error "Failed to pull updates. You may have local changes."
    dz::info "Run: cd ~/.dreamzsh && git status"
    return 1
  }

  dz::success "DreamZSH updated successfully."
  dz::info "Run 'exec zsh' to reload."
}

dz::update::check_background() {
  local repo_dir="${DREAMZSH_DIR}"
  local cache_file="${DREAMZSH_DIR}/.update-check"
  local now last_check before after

  [[ -d "$repo_dir/.git" ]] || return 0

  now="$(date +%s)"
  last_check="$(cat "$cache_file" 2>/dev/null)" || last_check=0

  if (( now - last_check < 86400 )); then
    return 0
  fi

  print -r -- "$now" > "$cache_file" 2>/dev/null || true

  (
    cd "$repo_dir" || exit
    git fetch origin master --quiet 2>/dev/null || exit
    before="$(git rev-parse HEAD 2>/dev/null)" || exit
    after="$(git rev-parse origin/master 2>/dev/null)" || exit
    if [[ "$before" != "$after" ]]; then
      print -P -- "${DZ_COLOR_YELLOW}DreamZSH update available. Run: dreamzsh update${DZ_COLOR_RESET}"
    fi
  ) &!
}
