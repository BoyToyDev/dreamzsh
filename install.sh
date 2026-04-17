#!/usr/bin/env sh
set -eu

REPO_URL="https://github.com/BoyToyDev/dreamzsh.git"
REPO_BRANCH="master"
INSTALL_DIR="${HOME}/.dreamzsh"
ZSHRC="${HOME}/.zshrc"
BLOCK_START="# >>> dreamzsh >>>"
BLOCK_END="# <<< dreamzsh <<<"

info() { printf '==> %s\n' "$*"; }
success() { printf '✔ %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
error() { printf 'ERROR: %s\n' "$*" >&2; }

ensure_repo() {
  if [ -d "$INSTALL_DIR/.git" ]; then
    info "Updating DreamZSH in $INSTALL_DIR"
    git -C "$INSTALL_DIR" fetch origin
    git -C "$INSTALL_DIR" checkout "$REPO_BRANCH"
    git -C "$INSTALL_DIR" pull --ff-only origin "$REPO_BRANCH"
  elif [ -e "$INSTALL_DIR" ]; then
    error "Path exists but is not a git repository: $INSTALL_DIR"
    exit 1
  else
    info "Cloning DreamZSH into $INSTALL_DIR"
    git clone --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"
  fi
}

ensure_zshrc() {
  [ -f "$ZSHRC" ] || : > "$ZSHRC"
}

ensure_config() {
  if [ -f "$INSTALL_DIR/dreamzsh.conf" ]; then
    return 0
  fi

  if [ -f "$INSTALL_DIR/dreamzsh.conf.example" ]; then
    cp "$INSTALL_DIR/dreamzsh.conf.example" "$INSTALL_DIR/dreamzsh.conf"
    success "Created config from example"
  fi
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
  tmp_file="$(mktemp)"
  cp "$ZSHRC" "$tmp_file"
  [ -s "$tmp_file" ] && printf '\n' >> "$tmp_file"
  build_block >> "$tmp_file"
  mv "$tmp_file" "$ZSHRC"
  success "DreamZSH block added to $ZSHRC"
}

main() {
  command -v git >/dev/null 2>&1 || { error "git is required"; exit 1; }

  ensure_repo
  ensure_zshrc
  ensure_config

  if grep -Fq "$BLOCK_START" "$ZSHRC" || grep -Fq "$BLOCK_END" "$ZSHRC"; then
    warn "DreamZSH block already exists in $ZSHRC"
  else
    append_block
  fi

  printf '\n'
  success "DreamZSH installed successfully."
  printf 'Run: source "%s"\n' "$ZSHRC"
  printf 'Or open a new terminal.\n'
}

main "$@"
