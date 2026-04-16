#!/usr/bin/env sh

set -eu

INSTALL_DIR="${HOME}/.dreamzsh"
ZSHRC="${HOME}/.zshrc"
BLOCK_START="# >>> dreamzsh >>>"
BLOCK_END="# <<< dreamzsh <<<"

timestamp() {
  date +"%Y%m%d-%H%M%S"
}

info() {
  printf '==> %s\n' "$*"
}

success() {
  printf '✔ %s\n' "$*"
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
}

error() {
  printf 'ERROR: %s\n' "$*" >&2
}

require_file() {
  if [ ! -f "$1" ]; then
    error "Required file not found: $1"
    exit 1
  fi
}

backup_file() {
  file="$1"

  if [ -f "$file" ]; then
    backup="${file}.dreamzsh.bak.$(timestamp)"
    cp "$file" "$backup"
    success "Backup created: $backup"
  fi
}

ensure_zshrc() {
  if [ ! -f "$ZSHRC" ]; then
    : > "$ZSHRC"
    success "Created: $ZSHRC"
  fi
}

ensure_config() {
  config_file="${INSTALL_DIR}/dreamzsh.conf"
  example_file="${INSTALL_DIR}/dreamzsh.conf.example"

  if [ -f "$config_file" ]; then
    info "Config already exists: $config_file"
    return 0
  fi

  if [ -f "$example_file" ]; then
    cp "$example_file" "$config_file"
    success "Created config from example: $config_file"
    return 0
  fi

  cat > "$config_file" <<'EOCONF'
DREAMZSH_THEME="minimal"
DREAMZSH_PROFILE="default"
DREAMZSH_PLUGINS=(git history navigation)
EOCONF

  success "Created default config: $config_file"
}

build_block() {
  cat <<'EOBLOCK'
# >>> dreamzsh >>>
export DREAMZSH_DIR="$HOME/.dreamzsh"

if [ -d "$DREAMZSH_DIR/bin" ]; then
  case ":$PATH:" in
    *:"$DREAMZSH_DIR/bin":*) ;;
    *) export PATH="$DREAMZSH_DIR/bin:$PATH" ;;
  esac
fi

if [ -f "$DREAMZSH_DIR/core/init.zsh" ]; then
  source "$DREAMZSH_DIR/core/init.zsh"
else
  printf 'dreamzsh: init file not found: %s\n' "$DREAMZSH_DIR/core/init.zsh" >&2
fi
# <<< dreamzsh <<<
EOBLOCK
}

append_block() {
  tmp_file=$(mktemp)

  cp "$ZSHRC" "$tmp_file"

  if [ -s "$tmp_file" ]; then
    printf '\n' >> "$tmp_file"
  fi

  build_block >> "$tmp_file"
  mv "$tmp_file" "$ZSHRC"

  success "DreamZSH block added to $ZSHRC"
}

main() {
  if [ ! -e "$INSTALL_DIR" ]; then
    error "DreamZSH is not installed at $INSTALL_DIR"
    printf 'Expected installation path: %s\n' "$INSTALL_DIR" >&2
    printf '\n' >&2
    printf 'Recommended install flow:\n' >&2
    printf '  git clone https://github.com/BoyToyDev/dreamzsh "%s"\n' "$INSTALL_DIR" >&2
    printf '  cd "%s"\n' "$INSTALL_DIR" >&2
    printf '  ./install.sh\n' >&2
    exit 1
  fi

  require_file "$INSTALL_DIR/core/init.zsh"
  require_file "$INSTALL_DIR/bin/dreamzsh"

  ensure_zshrc
  backup_file "$ZSHRC"
  ensure_config

  if grep -Fq "$BLOCK_START" "$ZSHRC" || grep -Fq "$BLOCK_END" "$ZSHRC"; then
    warn "DreamZSH is already installed."
    warn "DreamZSH block markers already exist in $ZSHRC"
    printf '\n'
    printf 'If needed later:\n'
    printf '  update support can be added as a separate command\n'
    printf '  uninstall can remove the block from %s and delete %s\n' "$ZSHRC" "$INSTALL_DIR"
    exit 0
  fi

  append_block

  printf '\n'
  success "DreamZSH installed successfully."
  printf '\n'
  printf 'Start using DreamZSH now:\n'
  printf '  source "%s"\n' "$ZSHRC"
  printf '\n'
  printf 'Or open a new terminal.\n'
}

main "$@"
