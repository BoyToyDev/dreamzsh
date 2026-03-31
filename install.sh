#!/usr/bin/env bash
set -e

echo "Installing/Updating DreamZSH..."

DREAMZSH_DIR="$HOME/.dreamzsh"

# Если папка есть — обновляем только core
if [ -d "$DREAMZSH_DIR" ]; then
    echo "Updating DreamZSH..."
    cd "$DREAMZSH_DIR"
    git pull || echo "Update skipped (not a git repo)"
else
    echo "Fresh install..."
    git clone https://github.com/BoyToyDev/dreamzsh.git "$DREAMZSH_DIR"
fi

# Создаем необходимые подпапки (без удаления старого)
mkdir -p "$DREAMZSH_DIR/plugins"
mkdir -p "$DREAMZSH_DIR/themes/active"
mkdir -p "$DREAMZSH_DIR/themes/custom"
mkdir -p "$DREAMZSH_DIR/profiles"

# Создаем файл enabled_plugins если его нет
touch "$DREAMZSH_DIR/plugins/enabled_plugins"

# Создаем корректный ~/.zshrc, не трогаем плагины и темы
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"
    echo "Backup saved: ~/.zshrc.backup.*"
fi

cat > "$HOME/.zshrc" <<'EOF'
# DreamZSH config
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DREAMZSH_DIR="$HOME/.dreamzsh"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Load DreamZSH
source $DREAMZSH_DIR/core/loader.zsh

# Aliases
dreamzsh() {
    /usr/bin/zsh "$DREAMZSH_DIR/manager.sh" "$@"
}
alias dz="dreamzsh"
alias zreload="exec /usr/bin/zsh"
EOF

echo ""
echo "✔ DreamZSH installed/updated!"
echo ""
echo "Next steps:"
echo "  exec /usr/bin/zsh"
echo "  dreamzsh doctor"
echo "  dreamzsh list"