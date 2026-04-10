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
