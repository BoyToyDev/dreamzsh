# =========================
# DreamZSH Loader (stable)
# =========================

# --- Core vars ---
DREAMZSH_DIR="${DREAMZSH_DIR:-$HOME/.dreamzsh}"
PLUGIN_DIR="$DREAMZSH_DIR/plugins"
PLUGIN_FILE="$PLUGIN_DIR/enabled_plugins"
THEME_FILE="$DREAMZSH_DIR/themes/active/theme.zsh-theme"

# --- ZSH options ---
setopt null_glob
setopt prompt_subst

# =========================
# ?? HARD PATH PROTECTION
# =========================

# Если PATH сломан > полностью восстанавливаем
if [[ -z "$PATH" || "$PATH" != *"/usr/bin"* ]]; then
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
fi

# =========================
# ?? LOAD PLUGINS
# =========================

if [[ -f "$PLUGIN_FILE" ]]; then
  while IFS= read -r plugin; do
    [[ -z "$plugin" ]] && continue

    path="$PLUGIN_DIR/$plugin"

    # ?? plugin as folder
    if [[ -d "$path" ]]; then
      for file in "$path"/*.zsh(N); do
        source "$file"
      done

    # ?? plugin as single file
    elif [[ -f "$path.zsh" ]]; then
      source "$path.zsh"
    fi

  done < "$PLUGIN_FILE"
fi

# =========================
# ?? POST INIT HOOK
# =========================

# Если плагин объявил init — запускаем
if typeset -f dreamzsh_init >/dev/null; then
  dreamzsh_init
fi

# =========================
# ?? LOAD THEME
# =========================

if [[ -f "$THEME_FILE" ]]; then
  source "$THEME_FILE"
fi