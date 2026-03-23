#!/usr/bin/env zsh

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m'

DREAMZSH_DIR="$HOME/dreamzsh"

show_menu() {
    echo ""
    echo "=========================================="
    echo "     DREAMZSH FONT INSTALLER"
    echo "=========================================="
    echo ""
    echo "  1) Hack Nerd Font (recommended)"
    echo "  2) Fira Code Nerd Font"
    echo "  3) Meslo Nerd Font"
    echo "  4) JetBrains Mono Nerd Font"
    echo "  5) Show setup instructions"
    echo "  0) Back"
    echo ""
}

install_font() {
    local font_name="$1"
    local font_display="$2"
    
    echo ""
    echo -e "${CYAN}Downloading ${font_display}...${NC}"
    
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    
    cd /tmp
    curl -L -o "${font_name}.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/${font_name}.zip" --progress-bar
    
    if [ -f "${font_name}.zip" ]; then
        unzip -q "${font_name}.zip" -d "${font_name}Font"
        # Копируем все файлы шрифтов (ttf, otf, и т.д.)
        if [ -d "${font_name}Font" ]; then
            # Используем find для поиска всех файлов шрифтов
            find "${font_name}Font" -name "*.ttf" -o -name "*.otf" -o -name "*.ttc" 2>/dev/null | while read font_file; do
                cp "$font_file" "$font_dir/" 2>/dev/null
            done
        fi
        rm -rf "${font_name}.zip" "${font_name}Font"
        
        if command -v fc-cache &> /dev/null; then
            fc-cache -fv 2>/dev/null
        fi
        
        echo -e "${GREEN}? Font installed: ${font_display}${NC}"
        echo -e "${YELLOW}?? Don't forget to select the font in your terminal settings!${NC}"
    else
        echo -e "${RED}? Download failed${NC}"
    fi
    echo ""
    read "?Press Enter..."
}

show_instruction() {
    echo ""
    echo -e "${WHITE}?? Font setup instructions:${NC}"
    echo ""
    echo "  ${CYAN}macOS (Terminal):${NC}"
    echo "    Cmd+, > Profiles > Text > Font > Select Nerd Font"
    echo ""
    echo "  ${CYAN}macOS (iTerm2):${NC}"
    echo "    Cmd+, > Profiles > Text > Font > Change Font"
    echo ""
    echo "  ${CYAN}Linux (GNOME Terminal):${NC}"
    echo "    Preferences > Text > Custom font > Select Nerd Font"
    echo ""
    echo "  ${CYAN}Linux (Konsole):${NC}"
    echo "    Settings > Edit Current Profile > Appearance > Font"
    echo ""
    echo "  ${CYAN}Windows Terminal:${NC}"
    echo '    settings.json > "font": {"face": "Hack Nerd Font"}'
    echo ""
    read "?Press Enter..."
}

while true; do
    show_menu
    read "choice?Choose font (0-5): "
    
    case $choice in
        1) install_font "Hack" "Hack Nerd Font" ;;
        2) install_font "FiraCode" "Fira Code Nerd Font" ;;
        3) install_font "Meslo" "Meslo Nerd Font" ;;
        4) install_font "JetBrainsMono" "JetBrains Mono Nerd Font" ;;
        5) show_instruction ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
    esac
done