#!/usr/bin/env zsh

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

DREAMZSH_DIR="$HOME/dreamzsh"

show_menu() {
    echo ""
    echo "=========================================="
    echo "        DREAMZSH MANAGER"
    echo "=========================================="
    echo ""
    echo "  1) Theme builder"
    echo "  2) Download ohmyzsh theme"
    echo "  3) Plugins manager"
    echo "  4) Install fonts"
    echo "  5) Edit .zshrc"
    echo "  6) Reload config"
    echo "  7) Information"
    echo "  0) Exit"
    echo ""
}

configure_theme() {
    if [ -f "$DREAMZSH_DIR/theme-builder.sh" ]; then
        "$DREAMZSH_DIR/theme-builder.sh"
        if [ -f "$DREAMZSH_DIR/themes/custom.zsh-theme" ]; then
            sed -i '/source.*themes/d' ~/.zshrc
            echo "source \$DREAMZSH_DIR/themes/custom.zsh-theme" >> ~/.zshrc
            source ~/.zshrc
        fi
    else
        echo -e "${RED}Theme builder not found${NC}"
        sleep 2
    fi
}

install_ohmyzsh_theme() {
    echo ""
    echo -e "${CYAN}Available themes:${NC}"
    echo "  1) robbyrussell"
    echo "  2) agnoster"
    echo "  3) pure"
    echo "  4) bira"
    echo "  0) Back"
    echo -n "Choose: "
    read theme_choice
    case $theme_choice in
        1) theme_name="robbyrussell" ;;
        2) theme_name="agnoster" ;;
        3) theme_name="pure" ;;
        4) theme_name="bira" ;;
        0) return ;;
        *) return ;;
    esac
    mkdir -p "$DREAMZSH_DIR/themes/available"
    curl -s -o "$DREAMZSH_DIR/themes/available/${theme_name}.zsh-theme" \
        "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/themes/${theme_name}.zsh-theme"
    if [ -f "$DREAMZSH_DIR/themes/available/${theme_name}.zsh-theme" ]; then
        echo -e "${GREEN}Theme downloaded${NC}"
        echo -n "Apply now? (y/n): "
        read apply
        if [ "$apply" = "y" ]; then
            sed -i '/source.*themes/d' ~/.zshrc
            echo "source \$DREAMZSH_DIR/themes/available/${theme_name}.zsh-theme" >> ~/.zshrc
            source ~/.zshrc
        fi
    fi
    sleep 2
}

manage_plugins() {
    echo ""
    local plugins=()
    for plugin in "$DREAMZSH_DIR/plugins"/*.zsh; do
        [ -f "$plugin" ] && plugins+=("$(basename "$plugin" .zsh)")
    done
    if [ ${#plugins[@]} -eq 0 ]; then
        echo -e "${RED}No plugins${NC}"
        sleep 2
        return
    fi
    for i in "${!plugins[@]}"; do
        if grep -q "plugins/${plugins[$i]}.zsh" ~/.zshrc; then
            echo "  $((i+1))) ${plugins[$i]} [ON]"
        else
            echo "  $((i+1))) ${plugins[$i]} [OFF]"
        fi
    done
    echo "  0) Back"
    echo -n "Choose: "
    read plugin_choice
    if [ "$plugin_choice" -gt 0 ] && [ "$plugin_choice" -le "${#plugins[@]}" ]; then
        selected="${plugins[$((plugin_choice-1))]}"
        if grep -q "plugins/${selected}.zsh" ~/.zshrc; then
            sed -i "/plugins\/${selected}.zsh/d" ~/.zshrc
            echo -e "${RED}Disabled: $selected${NC}"
        else
            echo "source \$DREAMZSH_DIR/plugins/${selected}.zsh" >> ~/.zshrc
            echo -e "${GREEN}Enabled: $selected${NC}"
        fi
    fi
    sleep 2
}

install_fonts() {
    if [ -f "$DREAMZSH_DIR/fonts/install.sh" ]; then
        "$DREAMZSH_DIR/fonts/install.sh"
    else
        echo -e "${RED}Fonts installer not found${NC}"
        sleep 2
    fi
}

show_info() {
    echo ""
    echo -e "${CYAN}DreamZSH Info:${NC}"
    echo "  Dir: $DREAMZSH_DIR"
    current=$(grep "source.*themes/" ~/.zshrc | head -1 | sed 's/.*\/\(.*\)\.zsh-theme/\1/')
    echo "  Theme: ${current:-none}"
    echo "  Plugins:"
    for p in "$DREAMZSH_DIR/plugins"/*.zsh; do
        n=$(basename "$p" .zsh)
        grep -q "plugins/${n}.zsh" ~/.zshrc && echo "    $n"
    done
    read "?Press Enter..."
}

while true; do
    show_menu
    echo -n "Action (0-7): "
    read choice
    case $choice in
        1) configure_theme ;;
        2) install_ohmyzsh_theme ;;
        3) manage_plugins ;;
        4) install_fonts ;;
        5) nano ~/.zshrc ;;
        6) source ~/.zshrc; echo "Reloaded"; sleep 1 ;;
        7) show_info ;;
        0) exit 0 ;;
    esac
done
