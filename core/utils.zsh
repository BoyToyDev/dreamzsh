# dreamzsh/core/utils.zsh

if [[ -n "${__DREAMZSH_UTILS_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_UTILS_LOADED=1

: "${DREAMZSH_DIR:=${HOME}/.dreamzsh}"

: "${DREAMZSH_CONFIG_FILE:=$DREAMZSH_DIR/dreamzsh.conf}"
: "${DREAMZSH_THEMES_DIR:=$DREAMZSH_DIR/themes}"
: "${DREAMZSH_PLUGINS_DIR:=$DREAMZSH_DIR/plugins}"
: "${DREAMZSH_PROFILES_DIR:=$DREAMZSH_DIR/profiles}"

if [[ -t 1 ]]; then
  : "${DZ_COLOR_RESET:=%f%b%k}"
  : "${DZ_COLOR_RED:=%F{1}}"
  : "${DZ_COLOR_GREEN:=%F{2}}"
  : "${DZ_COLOR_YELLOW:=%F{3}}"
  : "${DZ_COLOR_BLUE:=%F{4}}"
  : "${DZ_COLOR_MAGENTA:=%F{5}}"
  : "${DZ_COLOR_CYAN:=%F{6}}"
  : "${DZ_COLOR_BOLD:=%B}"
else
  : "${DZ_COLOR_RESET:=}"
  : "${DZ_COLOR_RED:=}"
  : "${DZ_COLOR_GREEN:=}"
  : "${DZ_COLOR_YELLOW:=}"
  : "${DZ_COLOR_BLUE:=}"
  : "${DZ_COLOR_MAGENTA:=}"
  : "${DZ_COLOR_CYAN:=}"
  : "${DZ_COLOR_BOLD:=}"
fi

dz::print() {
  print -r -- "$*"
}

dz::pprint() {
  print -P -- "$*"
}

dz::info() {
  print -P -- "${DZ_COLOR_BLUE}==>${DZ_COLOR_RESET} $*"
}

dz::success() {
  print -P -- "${DZ_COLOR_GREEN}✔${DZ_COLOR_RESET} $*"
}

dz::warn() {
  print -P -- "${DZ_COLOR_YELLOW}WARN:${DZ_COLOR_RESET} $*" >&2
}

dz::error() {
  print -P -- "${DZ_COLOR_RED}ERROR:${DZ_COLOR_RESET} $*" >&2
}

dz::die() {
  dz::error "$*"
  exit 1
}

dz::usage_error() {
  local message="$1"
  local help_hint="$2"

  dz::error "$message"
  [[ -n "$help_hint" ]] && dz::info "$help_hint"
  return 1
}

dz::did_you_mean() {
  local input="$1"
  shift
  local candidate

  for candidate in "$@"; do
    [[ "$candidate" == "$input" ]] && continue

    if [[ "$candidate" == ${input}* || "$input" == ${candidate}* ]]; then
      print -r -- "$candidate"
      return 0
    fi
  done

  for candidate in "$@"; do
    if [[ "$candidate" == *"$input"* || "$input" == *"$candidate"* ]]; then
      print -r -- "$candidate"
      return 0
    fi
  done

  return 1
}

dz::unknown_command() {
  local bad="$1"
  shift
  local suggestion=""

  suggestion="$(dz::did_you_mean "$bad" "$@")" || true

  dz::error "Unknown command: $bad"
  if [[ -n "$suggestion" ]]; then
    dz::info "Did you mean: $suggestion ?"
  fi
  return 1
}

dz::is_valid_name() {
  local name="$1"
  [[ "$name" =~ '^[a-zA-Z0-9._-]+$' ]]
}

dz::ensure_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || mkdir -p "$dir"
}

dz::join_by() {
  local delimiter="$1"
  shift
  local first=1
  local item

  for item in "$@"; do
    if (( first )); then
      printf '%s' "$item"
      first=0
    else
      printf '%s%s' "$delimiter" "$item"
    fi
  done
}

dz::normalize_name_args() {
  local raw piece
  local -a result=()

  for raw in "$@"; do
    [[ -z "$raw" ]] && continue
    for piece in ${(s:,:)raw}; do
      [[ -z "$piece" ]] && continue
      result+=("$piece")
    done
  done

  print -r -- "${result[@]}"
}

dz::array_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

dz::unique_array() {
  local item
  local -a out=()
  for item in "$@"; do
    dz::array_contains "$item" "${out[@]}" || out+=("$item")
  done
  print -r -- "${out[@]}"
}

dz::plugin_dir() {
  local name="$1"
  print -r -- "$DREAMZSH_PLUGINS_DIR/$name"
}

dz::plugin_main_file() {
  local name="$1"
  print -r -- "$DREAMZSH_PLUGINS_DIR/$name/plugin.zsh"
}

dz::plugin_meta_file() {
  local name="$1"
  print -r -- "$DREAMZSH_PLUGINS_DIR/$name/plugin.meta"
}

dz::theme_file() {
  local name="$1"
  print -r -- "$DREAMZSH_THEMES_DIR/$name.zsh-theme"
}

dz::plugin_exists() {
  local name="$1"
  [[ -f "$(dz::plugin_main_file "$name")" ]]
}

dz::theme_exists() {
  local name="$1"
  [[ -f "$(dz::theme_file "$name")" ]]
}
