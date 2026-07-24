#!/usr/bin/env sh
set -eu

REPO_URL="https://github.com/BoyToyDev/dreamzsh.git"
REPO_BRANCH="master"
INSTALL_DIR="${HOME}/.dreamzsh"
ZSHRC="${HOME}/.zshrc"
BLOCK_START="# >>> dreamzsh >>>"
BLOCK_END="# <<< dreamzsh <<<"
LOGIN_SHELL_IS_ZSH=0

info() { printf '==> %s\n' "$*"; }
success() { printf '✔ %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
error() { printf 'ERROR: %s\n' "$*" >&2; }

is_interactive() {
  [ -t 0 ] && [ -r /dev/tty ] && [ -w /dev/tty ]
}

confirm() {
  prompt="$1"

  is_interactive || return 1
  printf '%s [Y/n] ' "$prompt" > /dev/tty
  IFS= read -r reply < /dev/tty || return 1

  case "$reply" in
    ''|[Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    error "Root privileges are required. Install zsh manually and run this installer again."
    return 1
  fi
}

install_zsh() {
  if command -v apt-get >/dev/null 2>&1; then
    run_as_root apt-get update
    run_as_root apt-get install -y zsh
  elif command -v dnf >/dev/null 2>&1; then
    run_as_root dnf install -y zsh
  elif command -v yum >/dev/null 2>&1; then
    run_as_root yum install -y zsh
  elif command -v pacman >/dev/null 2>&1; then
    run_as_root pacman -S --needed --noconfirm zsh
  elif command -v zypper >/dev/null 2>&1; then
    run_as_root zypper --non-interactive install zsh
  elif command -v apk >/dev/null 2>&1; then
    run_as_root apk add zsh
  elif command -v brew >/dev/null 2>&1; then
    brew install zsh
  else
    error "No supported package manager found. Install zsh manually and run this installer again."
    return 1
  fi
}

ensure_zsh() {
  if command -v zsh >/dev/null 2>&1; then
    ZSH_BIN="$(command -v zsh)"
    success "zsh found: $ZSH_BIN"
    return 0
  fi

  warn "zsh is not installed. DreamZSH cannot run without it."
  if ! confirm "Install zsh now?"; then
    error "zsh is required. Install it and run this installer again."
    exit 1
  fi

  info "Installing zsh"
  install_zsh

  if ! command -v zsh >/dev/null 2>&1; then
    error "zsh installation finished, but zsh is still not available in PATH."
    exit 1
  fi

  ZSH_BIN="$(command -v zsh)"
  success "zsh installed: $ZSH_BIN"
}

current_login_shell() {
  username="$(id -un 2>/dev/null || printf '%s' "${USER:-}")"

  if command -v getent >/dev/null 2>&1 && [ -n "$username" ]; then
    getent passwd "$username" | awk -F: 'NR == 1 { print $7 }'
  elif command -v dscl >/dev/null 2>&1 && [ -n "$username" ]; then
    dscl . -read "/Users/$username" UserShell 2>/dev/null | awk '{ print $2 }'
  else
    printf '%s\n' "${SHELL:-}"
  fi
}

is_zsh_shell() {
  case "$1" in
    */zsh|zsh) return 0 ;;
    *) return 1 ;;
  esac
}

ensure_login_shell() {
  login_shell="$(current_login_shell)"
  if is_zsh_shell "$login_shell"; then
    LOGIN_SHELL_IS_ZSH=1
    success "Login shell is already zsh: $login_shell"
    return 0
  fi

  if [ -n "$login_shell" ]; then
    warn "Current login shell is $login_shell, not zsh."
  else
    warn "Could not determine the current login shell."
  fi

  if ! command -v chsh >/dev/null 2>&1; then
    warn "chsh is not available; change your login shell to $ZSH_BIN manually."
    return 0
  fi

  if ! confirm "Change the login shell to $ZSH_BIN now?"; then
    warn "Login shell was not changed. Later, run: chsh -s \"$ZSH_BIN\""
    return 0
  fi

  info "Changing login shell to $ZSH_BIN"
  if ! chsh -s "$ZSH_BIN"; then
    error "Could not change the login shell. Make sure $ZSH_BIN is listed in /etc/shells, then run: chsh -s \"$ZSH_BIN\""
    return 1
  fi

  LOGIN_SHELL_IS_ZSH=1
  updated_shell="$(current_login_shell)"
  if is_zsh_shell "$updated_shell"; then
    success "Login shell changed to $updated_shell"
  else
    warn "chsh completed, but the change could not be confirmed. Open a new terminal and check: echo \"\$SHELL\""
  fi
}

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

  ensure_zsh
  ensure_login_shell
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
  if [ "$LOGIN_SHELL_IS_ZSH" -eq 1 ]; then
    printf 'Open a new terminal to start zsh and load DreamZSH.\n'
  else
    warn "Your login shell is not zsh, so a new terminal may not load DreamZSH automatically."
  fi
  printf 'To start it in this terminal now, run: exec "%s"\n' "$ZSH_BIN"
}

main "$@"
