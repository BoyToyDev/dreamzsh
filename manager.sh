#!/usr/bin/env zsh

# ------------------------
# SAFE ENV
# ------------------------

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

DREAMZSH_DIR="$HOME/.dreamzsh"
PLUGIN_DIR="$DREAMZSH_DIR/plugins"
ENABLED_FILE="$PLUGIN_DIR/enabled_plugins"

THEMES_DIR="$DREAMZSH_DIR/themes"
ACTIVE_THEME="$THEMES_DIR/active/theme.zsh-theme"

mkdir -p "$PLUGIN_DIR" "$THEMES_DIR/active" "$THEMES_DIR/custom"
touch "$ENABLED_FILE"

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
NC="\033[0m"

# ------------------------
# PLUGINS
# ------------------------

list_plugins() {
    echo "Plugins:"
    for plugin in "$PLUGIN_DIR"/*(N); do
        name=$(basename "$plugin")

        if /bin/grep -qx "$name" "$ENABLED_FILE" 2>/dev/null; then
            echo -e "  ${GREEN}[ON]${NC}  $name"
        else
            echo -e "  ${RED}[OFF]${NC} $name"
        fi
    done
}

enable_plugin() {
    for plugin in "$@"; do
        if ! /bin/grep -qx "$plugin" "$ENABLED_FILE" 2>/dev/null; then
            echo "$plugin" >> "$ENABLED_FILE"
            echo -e "${GREEN}Enabled:${NC} $plugin"
        fi
    done
    reload_config
}

disable_plugin() {
    for plugin in "$@"; do
        if /bin/grep -qx "$plugin" "$ENABLED_FILE" 2>/dev/null; then
            /bin/grep -vx "$plugin" "$ENABLED_FILE" > "$ENABLED_FILE.tmp"
            /bin/mv "$ENABLED_FILE.tmp" "$ENABLED_FILE"
            echo -e "${RED}Disabled:${NC} $plugin"
        fi
    done
    reload_config
}

install_plugin() {
    url="$1"

    if [[ -z "$url" ]]; then
        echo "Usage: dreamzsh plugin install <git-url>"
        return
    fi

    if ! command -v git >/dev/null; then
        echo "Git required"
        return
    fi

    name=$(basename "$url" .git)
    dest="$PLUGIN_DIR/$name"

    if [[ -d "$dest" ]]; then
        echo "Already installed"
        return
    fi

    echo "Cloning plugin..."
    git clone --depth=1 "$url" "$dest"

    echo -e "${GREEN}Installed:${NC} $name"
    echo "Enable with: dreamzsh pluginon $name"
}

# ------------------------
# THEMES
# ------------------------

list_themes() {
    echo "Themes:"
    for theme in "$THEMES_DIR"/*.zsh-theme(N); do
        echo "  $(basename "$theme" .zsh-theme)"
    done
    for theme in "$THEMES_DIR/custom/"*.zsh-theme(N); do
        echo "  custom/$(basename "$theme" .zsh-theme)"
    done
}

set_theme() {
    theme="$1"

    [[ -z "$theme" ]] && echo "Usage: theme set <name>" && return

    if [[ "$theme" == custom/* ]]; then
        path="$THEMES_DIR/${theme}.zsh-theme"
    else
        path="$THEMES_DIR/${theme}.zsh-theme"
    fi

    if [[ -f "$path" ]]; then
        /bin/cp "$path" "$ACTIVE_THEME"
        echo -e "${GREEN}Theme applied:${NC} $theme"
        reload_config
    else
        echo -e "${RED}Theme not found${NC}"
    fi
}

preview_theme() {
    theme="$1"
    path="$THEMES_DIR/${theme}.zsh-theme"

    if [[ -f "$path" ]]; then
        echo -e "${CYAN}Preview:${NC} $theme"
        source "$path"
    else
        echo -e "${RED}Theme not found${NC}"
    fi
}

theme_wizard() {
    echo "DreamZSH Theme Wizard"

    read -rp "User color (green): " uc
    uc=${uc:-green}

    read -rp "Host color (magenta): " hc
    hc=${hc:-magenta}

    read -rp "Dir color (yellow): " dc
    dc=${dc:-yellow}

    read -rp "Symbol (?): " sym
    sym=${sym:-?}

    read -rp "Symbol color (magenta): " sc
    sc=${sc:-magenta}

    name="custom/wizard_$(date +%s)"
    file="$THEMES_DIR/custom/${name##*/}.zsh-theme"

    cat > "$file" <<EOF
autoload -Uz colors && colors
setopt prompt_subst

PROMPT="%F{${uc}}%n%f@%F{${hc}}%m%f:%F{${dc}}%~%f
%F{${sc}}${sym}%f "
EOF

    echo -e "${GREEN}Created:${NC} $name"
}

# ------------------------
# PROFILES
# ------------------------

apply_profile() {
    profile="$1"
    file="$DREAMZSH_DIR/profiles/$profile.profile"

    [[ ! -f "$file" ]] && echo "Profile not found" && return

    source "$file"

    echo "$PLUGINS" | tr ' ' '\n' > "$ENABLED_FILE"
    set_theme "$THEME"

    echo -e "${GREEN}Profile applied:${NC} $profile"
}

# ------------------------
# SYSTEM
# ------------------------

reload_config() {
    shell_path=$(command -v zsh)

    if [[ -n "$shell_path" ]]; then
        echo -e "${YELLOW}Run:${NC} exec $shell_path"
    else
        echo -e "${RED}ZSH not found${NC}"
    fi
}

doctor() {
    echo "DreamZSH Doctor:"
    echo "- PATH: $PATH"
    echo "- ZSH: $(command -v zsh || echo 'missing')"
    echo "- Plugins:"
    cat "$ENABLED_FILE" 2>/dev/null || echo "none"
    echo "- Theme:"
    ls "$ACTIVE_THEME" 2>/dev/null || echo "none"
}

# ------------------------
# COMMANDS
# ------------------------

case "$1" in

    help)
        echo "DreamZSH:"
        echo "  list"
        echo "  pluginon <name>"
        echo "  pluginoff <name>"
        echo "  plugin install <git>"
        echo "  themes"
        echo "  theme set <name>"
        echo "  theme preview <name>"
        echo "  theme wizard"
        echo "  profile <name>"
        echo "  doctor"
        ;;

    list) list_plugins ;;

    pluginon) shift; enable_plugin "$@" ;;
    pluginoff) shift; disable_plugin "$@" ;;

    plugin)
        case "$2" in
            install) install_plugin "$3" ;;
            *) echo "Usage: plugin install <git>" ;;
        esac
        ;;

    themes) list_themes ;;

    theme)
        case "$2" in
            set) set_theme "$3" ;;
            preview) preview_theme "$3" ;;
            wizard) theme_wizard ;;
            *) echo "Usage: theme set|preview|wizard" ;;
        esac
        ;;

    profile) apply_profile "$2" ;;

    doctor) doctor ;;

    *)
        echo "DreamZSH (use 'dreamzsh help')"
        ;;

esac