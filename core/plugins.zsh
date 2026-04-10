# dreamzsh/core/plugins.zsh

if [[ -n "${__DREAMZSH_PLUGINS_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_PLUGINS_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1

dz::plugin::list() {
  local dir name plugin_state meta_file description
  [[ -d "$DREAMZSH_PLUGINS_DIR" ]] || return 0

  printf '%-18s %-10s %s\n' "PLUGIN" "STATUS" "DESCRIPTION"
  printf '%-18s %-10s %s\n' "------" "------" "-----------"

  for dir in "$DREAMZSH_PLUGINS_DIR"/*(N/); do
    [[ -f "$dir/plugin.zsh" ]] || continue
    name="${dir:t}"
    description=""

    if dz::array_contains "$name" "${DREAMZSH_PLUGINS[@]}"; then
      plugin_state="enabled"
    else
      plugin_state="disabled"
    fi

    meta_file="$(dz::plugin_meta_file "$name")"
    if [[ -f "$meta_file" ]]; then
      local plugin_name="" version="" author="" tags=""
      source "$meta_file" 2>/dev/null
      description="${description:-}"
    fi

    [[ -n "$description" ]] || description="-"

    printf '%-18s %-10s %s\n' "$name" "$plugin_state" "$description"
  done
}

dz::plugin::info() {
  local name="$1"
  local dir meta_file readme_file
  local plugin_name="" description="" version="" author="" tags=""

  [[ -n "$name" ]] || {
    dz::error "Plugin name is required"
    return 1
  }

  dz::is_valid_name "$name" || {
    dz::error "Invalid plugin name: $name"
    return 1
  }

  dir="$(dz::plugin_dir "$name")"

  [[ -d "$dir" ]] || {
    dz::error "Plugin not found: $name"
    return 1
  }

  [[ -f "$dir/plugin.zsh" ]] || {
    dz::error "Plugin is invalid, missing plugin.zsh: $name"
    return 1
  }

  print -r -- "Name: $name"

  meta_file="$(dz::plugin_meta_file "$name")"
  if [[ -f "$meta_file" ]]; then
    source "$meta_file" 2>/dev/null
    [[ -n "$plugin_name" ]] && print -r -- "Title: $plugin_name"
    [[ -n "$description" ]] && print -r -- "Description: $description"
    [[ -n "$version" ]] && print -r -- "Version: $version"
    [[ -n "$author" ]] && print -r -- "Author: $author"
    [[ -n "$tags" ]] && print -r -- "Tags: $tags"
  fi

  if dz::array_contains "$name" "${DREAMZSH_PLUGINS[@]}"; then
    print -r -- "Status: enabled"
  else
    print -r -- "Status: disabled"
  fi

  readme_file="$dir/README.md"
  if [[ -f "$readme_file" ]]; then
    print -r -- ""
    print -r -- "--- README ---"
    cat "$readme_file"
  fi
}

dz::plugin::enable() {
  local -a normalized updated invalid missing
  local name

  normalized=($(dz::normalize_name_args "$@"))
  normalized=($(dz::unique_array "${normalized[@]}"))

  (( ${#normalized[@]} > 0 )) || {
    dz::error "At least one plugin name is required"
    return 1
  }

  updated=("${DREAMZSH_PLUGINS[@]}")

  for name in "${normalized[@]}"; do
    if ! dz::is_valid_name "$name"; then
      invalid+=("$name")
      continue
    fi

    if ! dz::plugin_exists "$name"; then
      missing+=("$name")
      continue
    fi

    dz::array_contains "$name" "${updated[@]}" || updated+=("$name")
  done

  if (( ${#invalid[@]} > 0 )); then
    dz::error "Invalid plugin names: ${invalid[*]}"
    return 1
  fi

  if (( ${#missing[@]} > 0 )); then
    dz::error "Plugins not found: ${missing[*]}"
    return 1
  fi

  DREAMZSH_PLUGINS=("${updated[@]}")
  dz::config::save || return 1
  dz::success "Enabled plugins: ${normalized[*]}"
}

dz::plugin::disable() {
  local -a normalized updated
  local name existing

  normalized=($(dz::normalize_name_args "$@"))
  normalized=($(dz::unique_array "${normalized[@]}"))

  (( ${#normalized[@]} > 0 )) || {
    dz::error "At least one plugin name is required"
    return 1
  }

  for name in "${normalized[@]}"; do
    dz::is_valid_name "$name" || {
      dz::error "Invalid plugin name: $name"
      return 1
    }
  done

  updated=()
  for existing in "${DREAMZSH_PLUGINS[@]}"; do
    if ! dz::array_contains "$existing" "${normalized[@]}"; then
      updated+=("$existing")
    fi
  done

  DREAMZSH_PLUGINS=("${updated[@]}")
  dz::config::save || return 1
  dz::success "Disabled plugins: ${normalized[*]}"
}

dz::plugin::load_one() {
  local name="$1"
  local plugin_file completion_dir

  dz::is_valid_name "$name" || {
    dz::warn "Skipping invalid plugin name: $name"
    return 1
  }

  plugin_file="$(dz::plugin_main_file "$name")"

  if [[ ! -f "$plugin_file" ]]; then
    dz::warn "Plugin not found: $name"
    return 1
  fi

  completion_dir="$(dz::plugin_dir "$name")/completions"
  if [[ -d "$completion_dir" ]]; then
    fpath=("$completion_dir" $fpath)
  fi

  source "$plugin_file" || {
    dz::warn "Failed to load plugin: $name"
    return 1
  }
}

dz::plugin::load_all() {
  local plugin
  for plugin in "${DREAMZSH_PLUGINS[@]}"; do
    dz::plugin::load_one "$plugin"
  done
}
