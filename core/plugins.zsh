# dreamzsh/core/plugins.zsh

if [[ -n "${__DREAMZSH_PLUGINS_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_PLUGINS_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1
source "${DREAMZSH_DIR}/core/hooks.zsh" || return 1
source "${DREAMZSH_DIR}/core/registry.zsh" || return 1

dz::plugin::list() {
  local dir name plugin_state meta_file description origin
  local plugin_name="" version="" author="" tags=""
  local -A seen=()

  printf '%-18s %-10s %-9s %s\n' "PLUGIN" "STATUS" "ORIGIN" "DESCRIPTION"
  printf '%-18s %-10s %-9s %s\n' "------" "------" "------" "-----------"

  for dir in "$DREAMZSH_CUSTOM_PLUGINS_DIR"/*(N/) "$DREAMZSH_PLUGINS_DIR"/*(N/); do
    [[ -f "$dir/plugin.zsh" ]] || continue

    name="${dir:t}"
    [[ -n "${seen[$name]:-}" ]] && continue
    seen[$name]=1
    description=""
    plugin_name=""
    version=""
    author=""
    tags=""

    if dz::array_contains "$name" "${DREAMZSH_PLUGINS[@]}"; then
      plugin_state="${DZ_COLOR_GREEN}enabled${DZ_COLOR_RESET}"
    else
      plugin_state="${DZ_COLOR_RED}disabled${DZ_COLOR_RESET}"
    fi

    origin="$(dz::plugin_origin "$name")"

    meta_file="$(dz::plugin_meta_file "$name")"
    if [[ -f "$meta_file" ]]; then
      source "$meta_file" 2>/dev/null
    fi

    [[ -n "$description" ]] || description="-"
    print -P -- "$(printf '%-18s %-10s %-9s %s' "$name" "$plugin_state" "$origin" "$description")"
  done
}

dz::plugin::info() {
  local name="$1"
  local requested_repo=""
  local dir meta_file readme_file
  local plugin_name="" description="" version="" author="" tags=""
  local requires="" requires_plugins="" requires_commands=""

  [[ -n "$name" ]] || {
    dz::error "Plugin name is required"
    return 1
  }
  shift

  while (( $# > 0 )); do
    case "$1" in
      --repo)
        (( $# >= 2 )) || { dz::error "--repo requires a value"; return 1; }
        requested_repo="$2"
        shift 2
        ;;
      *) dz::error "Unknown plugin info option: $1"; return 1 ;;
    esac
  done

  dz::is_valid_name "$name" || {
    dz::error "Invalid plugin name: $name"
    return 1
  }

  dir="$(dz::plugin_dir "$name")"

  if [[ -n "$requested_repo" || ! -d "$dir" ]]; then
    dz::registry::plugin_info "$name" "$requested_repo"
    return $?
  fi

  [[ -d "$dir" ]] || {
    dz::error "Plugin not found: $name"
    return 1
  }

  [[ -f "$dir/plugin.zsh" ]] || {
    dz::error "Plugin is invalid, missing plugin.zsh: $name"
    return 1
  }

  print -r -- "Name: $name"
  print -r -- "Origin: $(dz::plugin_origin "$name")"

  meta_file="$(dz::plugin_meta_file "$name")"
  if [[ -f "$meta_file" ]]; then
    source "$meta_file" 2>/dev/null
    [[ -n "$plugin_name" ]] && print -r -- "Title: $plugin_name"
    [[ -n "$description" ]] && print -r -- "Description: $description"
    [[ -n "$version" ]] && print -r -- "Version: $version"
    [[ -n "$author" ]] && print -r -- "Author: $author"
    [[ -n "$tags" ]] && print -r -- "Tags: $tags"
    [[ -n "${requires_plugins:-${requires:-}}" ]] && \
      print -r -- "Required plugins: ${requires_plugins:-${requires:-}}"
    [[ -n "$requires_commands" ]] && print -r -- "Required commands: $requires_commands"
  fi

  if dz::array_contains "$name" "${DREAMZSH_PLUGINS[@]}"; then
    print -P -- "Status: ${DZ_COLOR_GREEN}enabled${DZ_COLOR_RESET}"
  else
    print -P -- "Status: ${DZ_COLOR_RED}disabled${DZ_COLOR_RESET}"
  fi

  readme_file="$dir/README.md"
  if [[ -f "$readme_file" ]]; then
    print -r -- ""
    print -r -- "--- README ---"
    cat "$readme_file"
  fi

  if dz::plugin::is_external "$name"; then
    local source_type
    source_type="$(dz::plugin::source_value "$name" type 2>/dev/null)" || source_type="git"
    print -r -- ""
    print -r -- "--- External source ---"
    print -r -- "Type: $source_type"
    if [[ "$source_type" == "registry" ]]; then
      print -r -- "Repository: $(dz::plugin::source_value "$name" repo)"
      print -r -- "Path: $(dz::plugin::source_value "$name" path)"
    fi
    print -r -- "URL: $(dz::plugin::source_value "$name" url)"
    print -r -- "Ref: $(dz::plugin::source_value "$name" ref)"
    print -r -- "Commit: $(dz::plugin::source_value "$name" commit)"
    print -r -- "Entrypoint: $(dz::plugin::source_value "$name" entrypoint)"
  fi
}

dz::plugin::create() {
  local name="$1"
  local dir plugin_file meta_file readme_file

  [[ -n "$name" ]] || {
    dz::error "Plugin name is required"
    return 1
  }

  dz::is_valid_name "$name" || {
    dz::error "Invalid plugin name: $name"
    return 1
  }

  dir="$DREAMZSH_CUSTOM_PLUGINS_DIR/$name"

  if dz::plugin_exists "$name" || [[ -e "$dir" ]]; then
    dz::error "Plugin already exists: $name"
    return 1
  fi

  mkdir -p "$dir" || {
    dz::error "Failed to create plugin directory: $dir"
    return 1
  }

  plugin_file="$dir/plugin.zsh"
  meta_file="$dir/plugin.meta"
  readme_file="$dir/README.md"

  cat > "$plugin_file" <<EOF_PLUGIN
# DreamZSH plugin: $name
#
# Add your aliases, functions, environment variables,
# completions, and setup logic here.

# Example:
# alias ll='ls -lah'
EOF_PLUGIN

  cat > "$meta_file" <<EOF_META
plugin_name="$name"
description="Custom DreamZSH plugin"
version="0.1.0"
author=""
tags=""
requires_plugins=""
requires_commands=""
EOF_META

  cat > "$readme_file" <<EOF_README
# $name

Short description of this plugin.

## What it does

Describe what this plugin adds.

## Commands

List commands, aliases, or functions provided by this plugin.

## Notes

Add any usage notes here.
EOF_README

  dz::success "Plugin created: $name"
  print -r -- "Path: $dir"
  print -r -- ""
  print -r -- "Next steps:"
  print -r -- "  edit $plugin_file"
  print -r -- "  dreamzsh plugin enable $name"
  print -r -- "  dreamzsh plugin info $name"
}

dz::plugin::all_available() {
  local dir name
  local -A seen=()
  for dir in "$DREAMZSH_CUSTOM_PLUGINS_DIR"/*(N/) "$DREAMZSH_PLUGINS_DIR"/*(N/); do
    [[ -f "$dir/plugin.zsh" ]] || continue
    name="${dir:t}"
    [[ -n "${seen[$name]:-}" ]] && continue
    seen[$name]=1
    print -r -- "$name"
  done
}

dz::plugin::is_external() {
  local name="$1"
  [[ -f "$DREAMZSH_CUSTOM_PLUGINS_DIR/$name/source.meta" ]]
}

dz::plugin::source_value() {
  local name="$1"
  local wanted="$2"
  local meta_file="$DREAMZSH_CUSTOM_PLUGINS_DIR/$name/source.meta"
  local key value

  [[ -f "$meta_file" ]] || return 1
  while IFS='=' read -r key value; do
    if [[ "$key" == "$wanted" ]]; then
      print -r -- "$value"
      return 0
    fi
  done < "$meta_file"
  return 1
}

dz::plugin::normalize_source() {
  local source="$1"

  if [[ "$source" =~ '^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$' ]]; then
    print -r -- "https://github.com/${source%.git}.git"
    return 0
  fi

  if [[ "$source" =~ '^https://[^[:space:]]+$' ]]; then
    print -r -- "$source"
    return 0
  fi

  dz::error "Unsupported plugin source: $source"
  dz::info "Use owner/repo or an HTTPS Git URL."
  return 1
}

dz::plugin::source_name() {
  local source="$1"
  local name="${source:t}"
  print -r -- "${name%.git}"
}

dz::plugin::valid_entrypoint() {
  local entry="$1"
  local part

  [[ -n "$entry" && "$entry" != /* ]] || return 1
  [[ "$entry" =~ '^[A-Za-z0-9._/-]+$' ]] || return 1

  for part in ${(s:/:)entry}; do
    [[ -n "$part" && "$part" != "." && "$part" != ".." ]] || return 1
  done
}

dz::plugin::valid_ref() {
  local ref="$1"
  [[ -z "$ref" ]] && return 0
  [[ "$ref" != -* && "$ref" =~ '^[A-Za-z0-9._/-]+$' ]]
}

dz::plugin::detect_entrypoint() {
  local source_dir="$1"
  local plugin_name="$2"
  local repo_name="$3"
  local requested="${4:-}"
  local candidate
  local -a matches=()

  if [[ -n "$requested" ]]; then
    dz::plugin::valid_entrypoint "$requested" || {
      dz::error "Invalid plugin entrypoint: $requested"
      return 1
    }
    [[ -f "$source_dir/$requested" ]] || {
      dz::error "Plugin entrypoint not found: $requested"
      return 1
    }
    print -r -- "$requested"
    return 0
  fi

  for candidate in plugin.zsh "$repo_name.plugin.zsh" "$repo_name.zsh" \
    "$plugin_name.plugin.zsh" "$plugin_name.zsh"; do
    [[ -f "$source_dir/$candidate" ]] || continue
    print -r -- "$candidate"
    return 0
  done

  matches=("$source_dir"/*.plugin.zsh(N))
  if (( ${#matches[@]} == 1 )); then
    print -r -- "${matches[1]:t}"
    return 0
  fi

  dz::error "Could not determine the plugin entrypoint."
  dz::info "Use: dreamzsh plugin install <source> --entry <path>"
  return 1
}

dz::plugin::prepare_external() {
  local target="$1"
  local source_url="$2"
  local name="$3"
  local ref="$4"
  local requested_entry="$5"
  local repo_name entrypoint commit normalized_source

  dz::plugin::valid_ref "$ref" || {
    dz::error "Invalid plugin ref: $ref"
    return 1
  }
  normalized_source="$(dz::plugin::normalize_source "$source_url")" || return 1
  [[ "$normalized_source" == "$source_url" ]] || {
    dz::error "External plugin metadata must contain a normalized HTTPS URL"
    return 1
  }

  mkdir -p "$target" || return 1
  git clone "$source_url" "$target/source" 2>&1 || {
    dz::error "Failed to clone plugin: $source_url"
    return 1
  }

  if [[ -n "$ref" ]]; then
    git -C "$target/source" checkout --quiet "$ref" 2>&1 || {
      dz::error "Plugin ref not found: $ref"
      return 1
    }
  fi

  repo_name="$(dz::plugin::source_name "$source_url")"
  entrypoint="$(dz::plugin::detect_entrypoint "$target/source" "$name" "$repo_name" "$requested_entry")" \
    || return 1
  commit="$(git -C "$target/source" rev-parse HEAD 2>/dev/null)" || {
    dz::error "Could not determine plugin commit"
    return 1
  }

  cat > "$target/plugin.zsh" <<EOF
# Managed by DreamZSH. Do not edit this file manually.
source "\${DREAMZSH_CUSTOM_PLUGINS_DIR}/$name/source/$entrypoint"
EOF

  cat > "$target/plugin.meta" <<EOF
plugin_name="$name"
description="External plugin from $source_url"
version="${commit[1,12]}"
author=""
tags="external"
EOF

  cat > "$target/source.meta" <<EOF
url=$source_url
ref=$ref
commit=$commit
entrypoint=$entrypoint
EOF
}

dz::plugin::install() {
  local source="${1:-}"
  local source_url name ref="" entrypoint=""
  local tmp_dir destination

  [[ -n "$source" ]] || {
    dz::error "Plugin source is required"
    return 1
  }

  if dz::is_valid_name "$source"; then
    dz::registry::install "$@"
    return $?
  fi
  shift

  source_url="$(dz::plugin::normalize_source "$source")" || return 1
  name="$(dz::plugin::source_name "$source_url")"

  while (( $# > 0 )); do
    case "$1" in
      --name)
        (( $# >= 2 )) || { dz::error "--name requires a value"; return 1; }
        name="$2"
        shift 2
        ;;
      --ref)
        (( $# >= 2 )) || { dz::error "--ref requires a value"; return 1; }
        ref="$2"
        shift 2
        ;;
      --entry)
        (( $# >= 2 )) || { dz::error "--entry requires a value"; return 1; }
        entrypoint="$2"
        shift 2
        ;;
      *)
        dz::error "Unknown plugin install option: $1"
        return 1
        ;;
    esac
  done

  dz::is_valid_name "$name" || {
    dz::error "Invalid plugin name: $name"
    return 1
  }

  destination="$DREAMZSH_CUSTOM_PLUGINS_DIR/$name"
  if dz::plugin_exists "$name" || [[ -e "$destination" ]]; then
    dz::error "Plugin already exists: $name"
    return 1
  fi

  command -v git >/dev/null 2>&1 || {
    dz::error "git is required to install external plugins"
    return 1
  }

  mkdir -p "$DREAMZSH_CUSTOM_PLUGINS_DIR" || return 1
  tmp_dir="$(mktemp -d "$DREAMZSH_CUSTOM_PLUGINS_DIR/.install.XXXXXX")" || return 1

  dz::info "Cloning plugin from $source_url"
  dz::plugin::prepare_external "$tmp_dir" "$source_url" "$name" "$ref" "$entrypoint" || {
    rm -rf -- "$tmp_dir"
    return 1
  }

  mv -- "$tmp_dir" "$destination" || {
    rm -rf -- "$tmp_dir"
    dz::error "Failed to install plugin: $name"
    return 1
  }

  dz::success "Plugin installed: $name"
  dz::info "Commit: $(dz::plugin::source_value "$name" commit)"
  dz::info "Entrypoint: $(dz::plugin::source_value "$name" entrypoint)"

  dz::plugin::enable "$name" || {
    rm -rf -- "$destination"
    dz::error "Plugin installation rolled back because it could not be enabled: $name"
    return 1
  }
}

dz::plugin::update_one() {
  local name="$1" source_type
  local source_url ref entrypoint tmp_dir destination old_dir old_commit new_commit

  dz::is_valid_name "$name" && dz::plugin::is_external "$name" || {
    dz::error "Not an external plugin: $name"
    return 1
  }

  source_type="$(dz::plugin::source_value "$name" type 2>/dev/null)" || source_type="git"
  if [[ "$source_type" == "registry" ]]; then
    dz::registry::update_installed "$name"
    return $?
  fi

  source_url="$(dz::plugin::source_value "$name" url)" || return 1
  ref="$(dz::plugin::source_value "$name" ref)"
  entrypoint="$(dz::plugin::source_value "$name" entrypoint)" || return 1
  old_commit="$(dz::plugin::source_value "$name" commit)"
  destination="$DREAMZSH_CUSTOM_PLUGINS_DIR/$name"
  tmp_dir="$(mktemp -d "$DREAMZSH_CUSTOM_PLUGINS_DIR/.update.XXXXXX")" || return 1

  dz::plugin::prepare_external "$tmp_dir" "$source_url" "$name" "$ref" "$entrypoint" || {
    rm -rf -- "$tmp_dir"
    return 1
  }

  new_commit="$(awk -F= '$1 == "commit" { print $2 }' "$tmp_dir/source.meta")"
  if [[ "$old_commit" == "$new_commit" ]]; then
    rm -rf -- "$tmp_dir"
    dz::success "Plugin is already up to date: $name"
    return 0
  fi

  old_dir="$DREAMZSH_CUSTOM_PLUGINS_DIR/.old-${name}-$$"
  mv -- "$destination" "$old_dir" || { rm -rf -- "$tmp_dir"; return 1; }
  if ! mv -- "$tmp_dir" "$destination"; then
    mv -- "$old_dir" "$destination" 2>/dev/null || true
    rm -rf -- "$tmp_dir"
    dz::error "Failed to replace plugin: $name"
    return 1
  fi
  rm -rf -- "$old_dir"
  dz::success "Plugin updated: $name"
  dz::info "Commit: ${old_commit[1,12]} -> ${new_commit[1,12]}"
}

dz::plugin::update_external() {
  local -a names=()
  local dir name

  if [[ "${1:-}" == "--all" ]]; then
    for dir in "$DREAMZSH_CUSTOM_PLUGINS_DIR"/*(N/); do
      [[ -f "$dir/source.meta" ]] && names+=("${dir:t}")
    done
  else
    names=("$@")
  fi

  (( ${#names[@]} > 0 )) || {
    dz::error "At least one external plugin name is required"
    return 1
  }

  for name in "${names[@]}"; do
    dz::plugin::update_one "$name" || return 1
  done
}

dz::plugin::remove_external() {
  local name="${1:-}"
  local assume_yes=0 answer=""

  [[ -n "$name" ]] || { dz::error "Plugin name is required"; return 1; }
  shift
  while (( $# > 0 )); do
    case "$1" in
      --yes) assume_yes=1 ;;
      *) dz::error "Unknown plugin remove option: $1"; return 1 ;;
    esac
    shift
  done

  dz::is_valid_name "$name" && dz::plugin::is_external "$name" || {
    dz::error "Only external plugins can be removed: $name"
    return 1
  }

  if (( ! assume_yes )); then
    [[ -t 0 ]] || {
      dz::error "Confirmation required. Re-run with --yes."
      return 1
    }
    printf "Remove external plugin '%s'? [y/N]: " "$name"
    read -r answer
    [[ "$answer" == [Yy] ]] || { dz::warn "Removal cancelled."; return 0; }
  fi

  if dz::array_contains "$name" "${DREAMZSH_PLUGINS[@]}"; then
    dz::plugin::disable "$name" || return 1
  fi

  rm -rf -- "$DREAMZSH_CUSTOM_PLUGINS_DIR/$name" || return 1
  dz::success "External plugin removed: $name"
}

dz::plugin::enable() {
  local -a normalized updated invalid missing
  local name

  if [[ "${1:-}" == "--all" ]]; then
    shift
    normalized=($(dz::plugin::all_available))
    (( ${#normalized[@]} > 0 )) || {
      dz::error "No plugins found to enable"
      return 1
    }
  else
    normalized=($(dz::normalize_name_args "$@"))
    normalized=($(dz::unique_array "${normalized[@]}"))

    (( ${#normalized[@]} > 0 )) || {
      dz::error "At least one plugin name is required"
      return 1
    }
  fi

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

  local dep
  for name in "${normalized[@]}"; do
    local -a unmet_plugins unmet_commands
    unmet_plugins=($(dz::plugin::check_plugin_deps "$name"))
    if (( ${#unmet_plugins[@]} > 0 )); then
      dz::error "Plugin '$name' requires enabled plugins: ${unmet_plugins[*]}"
      return 1
    fi
    unmet_commands=($(dz::plugin::check_command_deps "$name"))
    if (( ${#unmet_commands[@]} > 0 )); then
      dz::error "Plugin '$name' requires installed commands: ${unmet_commands[*]}"
      return 1
    fi
  done

  DREAMZSH_PLUGINS=("${updated[@]}")
  dz::config::save || return 1
  dz::success "Enabled plugins: ${normalized[*]}"
  dz::info "Run 'dreamzsh reload' to apply changes in the current shell."
}

dz::plugin::disable() {
  local -a normalized updated
  local name existing

  if [[ "${1:-}" == "--all" ]]; then
    shift
    DREAMZSH_PLUGINS=()
    dz::config::save || return 1
    dz::success "All plugins disabled."
    dz::info "Run 'dreamzsh reload' to apply changes in the current shell."
    return 0
  fi

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
  dz::info "Run 'dreamzsh reload' to apply changes in the current shell."
}

dz::plugin::get_requirements() {
  local name="$1"
  local requirement_type="$2"
  local meta_file requires="" requires_plugins="" requires_commands=""
  local value=""
  local piece
  local -a result=()

  meta_file="$(dz::plugin_meta_file "$name")"
  if [[ -f "$meta_file" ]]; then
    source "$meta_file" 2>/dev/null
  fi

  case "$requirement_type" in
    plugins)
      # `requires` remains a compatibility alias for plugin dependencies in
      # metadata created before the requirements were split.
      value="${requires_plugins:-${requires:-}}"
      ;;
    commands)
      value="${requires_commands:-}"
      ;;
    *)
      dz::error "Unknown requirement type: $requirement_type"
      return 1
      ;;
  esac

  [[ -z "$value" ]] && return 0

  value="${value//,/ }"
  for piece in ${(z)value}; do
    [[ -z "$piece" ]] || result+=("$piece")
  done

  print -r -- "${result[@]}"
}

dz::plugin::check_plugin_deps() {
  local name="$1"
  local -a required missing
  local dep

  required=($(dz::plugin::get_requirements "$name" plugins))
  for dep in "${required[@]}"; do
    if ! dz::plugin_exists "$dep" || ! dz::array_contains "$dep" "${DREAMZSH_PLUGINS[@]}"; then
      missing+=("$dep")
    fi
  done

  (( ${#missing[@]} == 0 )) || {
    print -r -- "${missing[@]}"
    return 1
  }
}

dz::plugin::check_command_deps() {
  local name="$1"
  local -a required missing
  local dep

  required=($(dz::plugin::get_requirements "$name" commands))
  for dep in "${required[@]}"; do
    (( $+commands[$dep] )) || missing+=("$dep")
  done

  (( ${#missing[@]} == 0 )) || {
    print -r -- "${missing[@]}"
    return 1
  }
}

dz::plugin::load_one() {
  local name="$1"
  local plugin_file completion_dir
  local -a missing_plugins missing_commands

  dz::is_valid_name "$name" || {
    dz::warn "Skipping invalid plugin name: $name"
    return 1
  }

  plugin_file="$(dz::plugin_main_file "$name")"
  if [[ ! -f "$plugin_file" ]]; then
    dz::warn "Plugin not found: $name"
    return 1
  fi

  missing_plugins=($(dz::plugin::check_plugin_deps "$name"))
  if (( ${#missing_plugins[@]} > 0 )); then
    dz::warn "Skipping '$name': required plugins are not enabled — ${missing_plugins[*]}"
    return 1
  fi

  missing_commands=($(dz::plugin::check_command_deps "$name"))
  if (( ${#missing_commands[@]} > 0 )); then
    dz::warn "Skipping '$name': required commands are not installed — ${missing_commands[*]}"
    return 1
  fi

  completion_dir="$(dz::plugin_dir "$name")/completions"
  if [[ -d "$completion_dir" ]]; then
    fpath=("$completion_dir" $fpath)
  fi

  dz::hook::fire PRE_PLUGIN "$name" || true

  source "$plugin_file" || {
    dz::warn "Failed to load plugin: $name"
    return 1
  }

  dz::hook::fire POST_PLUGIN "$name" || true
}

dz::plugin::load_all() {
  local plugin
  local -a remaining failed
  local max_passes=3 pass

  remaining=("${DREAMZSH_PLUGINS[@]}")

  for (( pass=1; pass<=max_passes; pass++ )); do
    [[ ${#remaining[@]} -gt 0 ]] || break

    failed=()
    for plugin in "${remaining[@]}"; do
      dz::plugin::load_one "$plugin" || failed+=("$plugin")
    done

    if [[ ${#failed[@]} -eq ${#remaining[@]} ]]; then
      break
    fi

    remaining=("${failed[@]}")
  done
}
