# dreamzsh/core/update.zsh

if [[ -n "${__DREAMZSH_UPDATE_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_UPDATE_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1

dz::update::upstream() {
  local repo_dir="$1" upstream

  upstream="$(git -C "$repo_dir" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)" \
    || upstream=""
  if [[ -z "$upstream" ]]; then
    upstream="$(git -C "$repo_dir" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)" \
      || upstream=""
  fi

  [[ -n "$upstream" ]] || {
    dz::error "No upstream branch is configured for this DreamZSH checkout."
    dz::info "Configure one with: git -C $repo_dir branch --set-upstream-to <remote>/<branch>"
    return 1
  }
  print -r -- "$upstream"
}

dz::update::reconcile_untracked() {
  local repo_dir="$1" upstream="$2" file_path
  local -a identical conflicts

  while IFS= read -r -d '' file_path; do
    git -C "$repo_dir" cat-file -e "$upstream:$file_path" 2>/dev/null || continue
    if git -C "$repo_dir" show "$upstream:$file_path" 2>/dev/null \
        | cmp -s - "$repo_dir/$file_path"; then
      identical+=("$file_path")
    else
      conflicts+=("$file_path")
    fi
  done < <(git -C "$repo_dir" ls-files --others --exclude-standard -z)

  if (( ${#conflicts} )); then
    dz::error "Update contains files that conflict with untracked local files:"
    for file_path in "${conflicts[@]}"; do
      print -u2 -r -- "  $file_path"
    done
    dz::info "Move these files outside $repo_dir and run 'dreamzsh update' again."
    return 1
  fi

  for file_path in "${identical[@]}"; do
    rm -f -- "$repo_dir/$file_path" || {
      dz::error "Could not replace the identical local file: $file_path"
      return 1
    }
    dz::info "Adopting identical local file from the update: $file_path"
  done
}

dz::update::run() {
  local repo_dir="${DREAMZSH_DIR}"
  local upstream remote branch before after

  command -v git >/dev/null 2>&1 || {
    dz::error "git is required to update DreamZSH."
    return 1
  }
  if [[ ! -d "$repo_dir/.git" ]]; then
    dz::error "DreamZSH was not installed via git. Cannot auto-update."
    dz::info "Reinstall with: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/BoyToyDev/dreamzsh/master/install.sh)\""
    return 1
  fi

  upstream="$(dz::update::upstream "$repo_dir")" || return 1
  remote="${upstream%%/*}"
  branch="${upstream#*/}"

  if [[ -n "$(git -C "$repo_dir" status --porcelain --untracked-files=no 2>/dev/null)" ]]; then
    dz::error "DreamZSH has local tracked changes; update was not started."
    dz::info "Review them with: git -C $repo_dir status"
    return 1
  fi

  dz::info "Checking $upstream for updates..."
  git -C "$repo_dir" fetch "$remote" "$branch" 2>&1 || {
    dz::error "Failed to fetch updates. Check your network and repository settings."
    return 1
  }

  before="$(git -C "$repo_dir" rev-parse HEAD)" || return 1
  after="$(git -C "$repo_dir" rev-parse "$upstream")" || return 1
  dz::update::reconcile_untracked "$repo_dir" "$upstream" || return 1

  if [[ "$before" == "$after" ]]; then
    dz::success "DreamZSH is already up to date."
    return 0
  fi
  if git -C "$repo_dir" merge-base --is-ancestor "$after" "$before"; then
    dz::warn "This DreamZSH checkout is ahead of $upstream; nothing was changed."
    return 0
  fi
  if ! git -C "$repo_dir" merge-base --is-ancestor "$before" "$after"; then
    dz::error "Local and remote DreamZSH histories have diverged."
    dz::info "Resolve this manually in: $repo_dir"
    return 1
  fi

  dz::info "New version available. Updating..."
  git -C "$repo_dir" merge --ff-only "$upstream" 2>&1 || {
    dz::error "Failed to apply the update. No forced changes were made."
    return 1
  }

  dz::success "DreamZSH updated successfully: ${before[1,12]} -> ${after[1,12]}"
  dz::info "Run 'dreamzsh reload' to load the new version."
}

dz::update::check_background() {
  local repo_dir="${DREAMZSH_DIR}"
  local cache_dir="${DREAMZSH_CUSTOM_DIR:-${DREAMZSH_DIR}/custom}/cache"
  local cache_file="$cache_dir/update-check"
  local now last_check upstream remote branch before after

  [[ -d "$repo_dir/.git" ]] || return 0
  command -v git >/dev/null 2>&1 || return 0

  now="$(date +%s)"
  last_check="$(cat "$cache_file" 2>/dev/null)" || last_check=0
  (( now - last_check >= 86400 )) || return 0
  mkdir -p "$cache_dir" 2>/dev/null || return 0
  print -r -- "$now" > "$cache_file" 2>/dev/null || return 0

  (
    upstream="$(dz::update::upstream "$repo_dir" 2>/dev/null)" || exit
    remote="${upstream%%/*}"
    branch="${upstream#*/}"
    git -C "$repo_dir" fetch "$remote" "$branch" --quiet 2>/dev/null || exit
    before="$(git -C "$repo_dir" rev-parse HEAD 2>/dev/null)" || exit
    after="$(git -C "$repo_dir" rev-parse "$upstream" 2>/dev/null)" || exit
    if [[ "$before" != "$after" ]] && git -C "$repo_dir" merge-base --is-ancestor "$before" "$after"; then
      print -P -- "${DZ_COLOR_YELLOW}DreamZSH update available. Run: dreamzsh update${DZ_COLOR_RESET}"
    fi
  ) &!
}
