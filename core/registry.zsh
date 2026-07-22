# dreamzsh/core/registry.zsh

if [[ -n "${__DREAMZSH_REGISTRY_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_REGISTRY_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1

: "${DREAMZSH_OFFICIAL_PLUGIN_REPO_URL:=https://github.com/BoyToyDev/dreamzsh-plugins.git}"

dz::registry::normalize_source() {
  local source="$1"

  if [[ "$source" =~ '^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$' ]]; then
    print -r -- "https://github.com/${source%.git}.git"
  elif [[ "$source" =~ '^https://[^[:space:]]+$' ]]; then
    print -r -- "$source"
  else
    dz::error "Unsupported plugin repository: $source"
    dz::info "Use owner/repo or an HTTPS Git URL."
    return 1
  fi
}

dz::registry::source_id() {
  local source="$1"
  local name="${source:t}"
  name="${name%.git}"
  dz::is_valid_name "$name" || return 1
  print -r -- "$name"
}

dz::registry::sources() {
  local url ref
  local -A seen=(official 1)

  print -r -- "official|$DREAMZSH_OFFICIAL_PLUGIN_REPO_URL|"
  [[ -f "$DREAMZSH_PLUGIN_REPOS_FILE" ]] || return 0

  while IFS=$'\t' read -r url ref; do
    [[ -n "$url" ]] || continue
    local id
    id="$(dz::registry::source_id "$url")" || continue
    [[ -n "${seen[$id]:-}" ]] && continue
    seen[$id]=1
    print -r -- "$id|$url|$ref"
  done < "$DREAMZSH_PLUGIN_REPOS_FILE"
}

dz::registry::source_record() {
  local wanted="$1"
  local id url ref

  while IFS='|' read -r id url ref; do
    if [[ "$id" == "$wanted" ]]; then
      print -r -- "$id|$url|$ref"
      return 0
    fi
  done < <(dz::registry::sources)

  dz::error "Plugin repository not found: $wanted"
  return 1
}

dz::registry::cache_dir() {
  print -r -- "$DREAMZSH_PLUGIN_REPOS_DIR/$1"
}

dz::registry::sync() {
  local id="$1"
  local record url ref cache tmp old

  record="$(dz::registry::source_record "$id")" || return 1
  IFS='|' read -r id url ref <<< "$record"

  command -v git >/dev/null 2>&1 || {
    dz::error "git is required to update plugin repositories"
    return 1
  }

  mkdir -p "$DREAMZSH_PLUGIN_REPOS_DIR" || return 1
  cache="$(dz::registry::cache_dir "$id")"
  tmp="$(mktemp -d "$DREAMZSH_PLUGIN_REPOS_DIR/.sync-${id}.XXXXXX")" || return 1

  dz::info "Updating plugin repository: $id"
  git clone --quiet "$url" "$tmp" 2>&1 || {
    rm -rf -- "$tmp"
    dz::error "Failed to clone plugin repository: $url"
    return 1
  }

  if [[ -n "$ref" ]]; then
    git -C "$tmp" checkout --quiet "$ref" 2>&1 || {
      rm -rf -- "$tmp"
      dz::error "Plugin repository ref not found: $ref"
      return 1
    }
  fi

  old="$DREAMZSH_PLUGIN_REPOS_DIR/.old-${id}-$$"
  if [[ -e "$cache" ]]; then
    mv -- "$cache" "$old" || { rm -rf -- "$tmp"; return 1; }
  fi
  if ! mv -- "$tmp" "$cache"; then
    [[ -e "$old" ]] && mv -- "$old" "$cache" 2>/dev/null || true
    rm -rf -- "$tmp"
    dz::error "Failed to replace plugin repository cache: $id"
    return 1
  fi
  [[ -e "$old" ]] && rm -rf -- "$old"
  dz::success "Plugin repository updated: $id"
}

dz::registry::ensure_cache() {
  local id="$1"
  local cache="$(dz::registry::cache_dir "$id")"
  [[ -d "$cache/.git" ]] || dz::registry::sync "$id"
}

dz::registry::repo_add() {
  local source="${1:-}"
  local ref="" url id tmp_file existing_id existing_url existing_ref

  [[ -n "$source" ]] || {
    dz::error "Plugin repository URL is required"
    dz::info "The official repository is loaded automatically by browse, info, and install."
    return 1
  }
  shift

  while (( $# > 0 )); do
    case "$1" in
      --ref)
        (( $# >= 2 )) || { dz::error "--ref requires a value"; return 1; }
        ref="$2"
        shift 2
        ;;
      *) dz::error "Unknown plugin repo add option: $1"; return 1 ;;
    esac
  done

  dz::plugin::valid_ref "$ref" || { dz::error "Invalid repository ref: $ref"; return 1; }
  command -v git >/dev/null 2>&1 || {
    dz::error "git is required to add plugin repositories"
    return 1
  }
  url="$(dz::registry::normalize_source "$source")" || return 1
  id="$(dz::registry::source_id "$url")" || { dz::error "Invalid repository name"; return 1; }
  [[ "$id" != "official" ]] || { dz::error "Repository name 'official' is reserved"; return 1; }

  while IFS='|' read -r existing_id existing_url existing_ref; do
    if [[ "$existing_id" == "$id" || "$existing_url" == "$url" ]]; then
      dz::error "Plugin repository already exists: $existing_id"
      return 1
    fi
  done < <(dz::registry::sources)

  mkdir -p "$DREAMZSH_CUSTOM_DIR" || return 1
  # Validate the source before persisting it.
  mkdir -p "$DREAMZSH_PLUGIN_REPOS_DIR" || return 1
  local probe="$(mktemp -d "$DREAMZSH_PLUGIN_REPOS_DIR/.probe-${id}.XXXXXX")" || return 1
  git clone --quiet "$url" "$probe" 2>&1 || {
    rm -rf -- "$probe"; dz::error "Failed to clone plugin repository: $url"; return 1
  }
  if [[ -n "$ref" ]]; then
    git -C "$probe" checkout --quiet "$ref" 2>&1 || {
      rm -rf -- "$probe"; dz::error "Plugin repository ref not found: $ref"; return 1
    }
  fi

  tmp_file="$(mktemp "$DREAMZSH_CUSTOM_DIR/.plugin-repos.conf.XXXXXX")" || {
    rm -rf -- "$probe"; return 1
  }
  [[ -f "$DREAMZSH_PLUGIN_REPOS_FILE" ]] && cat "$DREAMZSH_PLUGIN_REPOS_FILE" > "$tmp_file"
  print -r -- "$url"$'\t'"$ref" >> "$tmp_file"
  mv -f -- "$tmp_file" "$DREAMZSH_PLUGIN_REPOS_FILE" || {
    rm -f -- "$tmp_file"; rm -rf -- "$probe"; return 1
  }
  mv -- "$probe" "$(dz::registry::cache_dir "$id")" || return 1
  dz::success "Plugin repository added: $id"
}

dz::registry::repo_remove() {
  local wanted="${1:-}" id url ref tmp_file removed=0
  [[ -n "$wanted" ]] || { dz::error "Plugin repository name is required"; return 1; }
  [[ "$wanted" != "official" ]] || { dz::error "The official repository cannot be removed"; return 1; }
  [[ -f "$DREAMZSH_PLUGIN_REPOS_FILE" ]] || { dz::error "Plugin repository not found: $wanted"; return 1; }

  tmp_file="$(mktemp "$DREAMZSH_CUSTOM_DIR/.plugin-repos.conf.XXXXXX")" || return 1
  while IFS=$'\t' read -r url ref; do
    [[ -n "$url" ]] || continue
    id="$(dz::registry::source_id "$url")" || continue
    if [[ "$id" == "$wanted" || "$url" == "$wanted" ]]; then
      removed=1
      rm -rf -- "$(dz::registry::cache_dir "$id")"
    else
      print -r -- "$url"$'\t'"$ref" >> "$tmp_file"
    fi
  done < "$DREAMZSH_PLUGIN_REPOS_FILE"

  (( removed )) || { rm -f -- "$tmp_file"; dz::error "Plugin repository not found: $wanted"; return 1; }
  mv -f -- "$tmp_file" "$DREAMZSH_PLUGIN_REPOS_FILE" || return 1
  dz::success "Plugin repository removed: $wanted"
}

dz::registry::repo_list() {
  local id url ref cache cache_state
  printf '%-18s %-9s %-12s %s\n' "REPOSITORY" "TYPE" "STATUS" "URL"
  printf '%-18s %-9s %-12s %s\n' "----------" "----" "------" "---"
  while IFS='|' read -r id url ref; do
    cache="$(dz::registry::cache_dir "$id")"
    [[ -d "$cache/.git" ]] && cache_state="cached" || cache_state="not-fetched"
    [[ "$id" == official ]] && print -r -- "$(printf '%-18s %-9s %-12s %s' "$id" "built-in" "$cache_state" "$url")" \
      || print -r -- "$(printf '%-18s %-9s %-12s %s' "$id" "custom" "$cache_state" "$url")"
  done < <(dz::registry::sources)
}

dz::registry::repo_update() {
  local wanted="${1:---all}" id url ref
  if [[ "$wanted" != "--all" ]]; then
    dz::registry::sync "$wanted"
    return $?
  fi
  while IFS='|' read -r id url ref; do
    dz::registry::sync "$id" || return 1
  done < <(dz::registry::sources)
}

dz::registry::plugin_dirs() {
  local id="$1" cache base dir
  cache="$(dz::registry::cache_dir "$id")"
  base="$cache/plugins"
  [[ -d "$base" ]] || base="$cache"
  for dir in "$base"/*(N/); do
    [[ "${dir:t}" == ".git" || ! -f "$dir/plugin.zsh" ]] && continue
    print -r -- "$dir"
  done
}

dz::registry::meta_value() {
  local file="$1" wanted="$2" line key value
  [[ -f "$file" ]] || return 1
  while IFS= read -r line; do
    [[ "$line" == "$wanted="* ]] || continue
    value="${line#*=}"
    if [[ "$value" == \"*\" ]]; then
      value="${value#\"}"
      value="${value%\"}"
    elif [[ "$value" == \'*\' ]]; then
      value="${value#\'}"
      value="${value%\'}"
    fi
    print -r -- "$value"
    return 0
  done < "$file"
  return 1
}

dz::registry::find_plugin() {
  local name="$1" wanted_repo="${2:-}" id url ref dir cache rel
  while IFS='|' read -r id url ref; do
    [[ -z "$wanted_repo" || "$id" == "$wanted_repo" ]] || continue
    dz::registry::ensure_cache "$id" || return 1
    cache="$(dz::registry::cache_dir "$id")"
    for dir in ${(f)"$(dz::registry::plugin_dirs "$id")"}; do
      if [[ "${dir:t}" == "$name" ]]; then
        rel="${dir#$cache/}"
        print -r -- "$id|$url|$ref|$rel|$dir"
        return 0
      fi
    done
  done < <(dz::registry::sources)
  dz::error "Plugin not found in configured repositories: $name"
  return 1
}

dz::registry::browse() {
  local wanted_repo="" refresh=0 id url ref dir meta name version description state
  while (( $# > 0 )); do
    case "$1" in
      --repo) (( $# >= 2 )) || { dz::error "--repo requires a value"; return 1; }; wanted_repo="$2"; shift 2 ;;
      --refresh) refresh=1; shift ;;
      *) dz::error "Unknown plugin browse option: $1"; return 1 ;;
    esac
  done

  if (( refresh )); then
    dz::registry::repo_update "${wanted_repo:---all}" || return 1
  fi
  printf '%-18s %-18s %-11s %-10s %s\n' "PLUGIN" "REPOSITORY" "STATUS" "VERSION" "DESCRIPTION"
  printf '%-18s %-18s %-11s %-10s %s\n' "------" "----------" "------" "-------" "-----------"
  while IFS='|' read -r id url ref; do
    [[ -z "$wanted_repo" || "$id" == "$wanted_repo" ]] || continue
    dz::registry::ensure_cache "$id" || return 1
    for dir in ${(f)"$(dz::registry::plugin_dirs "$id")"}; do
      name="${dir:t}"
      meta="$dir/plugin.meta"
      version="$(dz::registry::meta_value "$meta" version 2>/dev/null)"
      description="$(dz::registry::meta_value "$meta" description 2>/dev/null)"
      dz::plugin_exists "$name" && state="installed" || state="available"
      print -r -- "$(printf '%-18s %-18s %-11s %-10s %s' "$name" "$id" "$state" "${version:--}" "${description:--}")"
    done
  done < <(dz::registry::sources)
}

dz::registry::plugin_info() {
  local name="$1" wanted_repo="${2:-}" record id url ref rel dir meta key value
  record="$(dz::registry::find_plugin "$name" "$wanted_repo")" || return 1
  IFS='|' read -r id url ref rel dir <<< "$record"
  meta="$dir/plugin.meta"

  print -r -- "Name: $name"
  print -r -- "Origin: repository"
  print -r -- "Repository: $id"
  print -r -- "URL: $url"
  for key in plugin_name description version author tags requires_plugins requires_commands; do
    value="$(dz::registry::meta_value "$meta" "$key" 2>/dev/null)" || continue
    [[ -n "$value" ]] && print -r -- "${(C)${key//_/ }}: $value"
  done
  dz::plugin_exists "$name" && print -r -- "Status: installed" || print -r -- "Status: available"
  if [[ -f "$dir/README.md" ]]; then
    print -r -- ""
    print -r -- "--- README ---"
    cat "$dir/README.md"
  fi
}

dz::registry::prepare_plugin() {
  local target="$1" name="$2" repo="$3" url="$4" ref="$5" rel="$6" source_dir="$7"
  local commit link meta

  [[ -f "$source_dir/plugin.zsh" ]] || { dz::error "Registry plugin is missing plugin.zsh: $name"; return 1; }
  link="$(find "$source_dir" -type l -print -quit 2>/dev/null)"
  [[ -z "$link" ]] || { dz::error "Registry plugin contains a symbolic link: $name"; return 1; }
  mkdir -p "$target/source" || return 1
  cp -R -- "$source_dir/." "$target/source/" || return 1
  rm -rf -- "$target/source/.git"

  cat > "$target/plugin.zsh" <<EOF
# Managed by DreamZSH. Do not edit this file manually.
source "\${DREAMZSH_CUSTOM_PLUGINS_DIR}/$name/source/plugin.zsh"
EOF
  meta="$target/plugin.meta"
  if [[ -f "$source_dir/plugin.meta" ]]; then
    cp -- "$source_dir/plugin.meta" "$meta" || return 1
  else
    cat > "$meta" <<EOF
plugin_name="$name"
description="Plugin from $repo repository"
version=""
author=""
tags="registry"
requires_plugins=""
requires_commands=""
EOF
  fi
  [[ -f "$source_dir/README.md" ]] && cp -- "$source_dir/README.md" "$target/README.md"
  commit="$(git -C "$(dz::registry::cache_dir "$repo")" rev-parse HEAD 2>/dev/null)" || return 1
  cat > "$target/source.meta" <<EOF
type=registry
repo=$repo
url=$url
ref=$ref
commit=$commit
path=$rel
entrypoint=plugin.zsh
EOF
}

dz::registry::install() {
  local name="$1" wanted_repo="" record id url ref rel dir destination tmp
  shift
  while (( $# > 0 )); do
    case "$1" in
      --repo) (( $# >= 2 )) || { dz::error "--repo requires a value"; return 1; }; wanted_repo="$2"; shift 2 ;;
      *) dz::error "Unknown registry plugin install option: $1"; return 1 ;;
    esac
  done

  dz::is_valid_name "$name" || { dz::error "Invalid plugin name: $name"; return 1; }
  destination="$DREAMZSH_CUSTOM_PLUGINS_DIR/$name"
  if dz::plugin_exists "$name" || [[ -e "$destination" ]]; then
    dz::error "Plugin already exists: $name"
    return 1
  fi
  record="$(dz::registry::find_plugin "$name" "$wanted_repo")" || return 1
  IFS='|' read -r id url ref rel dir <<< "$record"

  mkdir -p "$DREAMZSH_CUSTOM_PLUGINS_DIR" || return 1
  tmp="$(mktemp -d "$DREAMZSH_CUSTOM_PLUGINS_DIR/.install.XXXXXX")" || return 1
  dz::registry::prepare_plugin "$tmp" "$name" "$id" "$url" "$ref" "$rel" "$dir" || {
    rm -rf -- "$tmp"; return 1
  }
  mv -- "$tmp" "$destination" || { rm -rf -- "$tmp"; return 1; }
  dz::success "Plugin installed from $id: $name"
  dz::plugin::enable "$name" || {
    rm -rf -- "$destination"
    dz::error "Plugin installation rolled back because it could not be enabled: $name"
    return 1
  }
}

dz::registry::update_installed() {
  local name="$1" repo url ref rel old_commit record id found_url found_ref found_rel dir tmp destination old new_commit
  repo="$(dz::plugin::source_value "$name" repo)" || return 1
  old_commit="$(dz::plugin::source_value "$name" commit)"
  dz::registry::sync "$repo" || return 1
  record="$(dz::registry::find_plugin "$name" "$repo")" || return 1
  IFS='|' read -r id found_url found_ref found_rel dir <<< "$record"
  new_commit="$(git -C "$(dz::registry::cache_dir "$repo")" rev-parse HEAD 2>/dev/null)" || return 1
  if [[ "$old_commit" == "$new_commit" ]]; then
    dz::success "Plugin is already up to date: $name"
    return 0
  fi

  destination="$DREAMZSH_CUSTOM_PLUGINS_DIR/$name"
  tmp="$(mktemp -d "$DREAMZSH_CUSTOM_PLUGINS_DIR/.update.XXXXXX")" || return 1
  dz::registry::prepare_plugin "$tmp" "$name" "$id" "$found_url" "$found_ref" "$found_rel" "$dir" || {
    rm -rf -- "$tmp"; return 1
  }
  old="$DREAMZSH_CUSTOM_PLUGINS_DIR/.old-${name}-$$"
  mv -- "$destination" "$old" || { rm -rf -- "$tmp"; return 1; }
  if ! mv -- "$tmp" "$destination"; then
    mv -- "$old" "$destination" 2>/dev/null || true
    rm -rf -- "$tmp"
    return 1
  fi
  rm -rf -- "$old"
  dz::success "Plugin updated from $repo: $name"
  dz::info "Commit: ${old_commit[1,12]} -> ${new_commit[1,12]}"
}
