#!/usr/bin/env zsh

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

DREAMZSH_DIR="$HOME/dreamzsh"

print_header() {
    clear
    echo ""
    echo -e "${RED}=========================================="
    echo "        DREAMZSH UNINSTALLER"
    echo -e "==========================================${NC}"
    echo ""
}

check_installation() {
    if [ ! -d "$DREAMZSH_DIR" ]; then
        echo -e "${RED}❌ DreamZSH not found in $DREAMZSH_DIR${NC}"
        echo "Nothing to uninstall."
        exit 1
    fi
    echo -e "${GREEN}✓ DreamZSH found at: $DREAMZSH_DIR${NC}\n"
}

show_warning() {
    echo -e "${YELLOW}⚠️  WARNING! This will remove:${NC}"
    echo ""
    echo "  1) DreamZSH directory: $DREAMZSH_DIR"
    echo "  2) DreamZSH configuration from .zshrc"
    echo "  3) Custom theme files"
    echo "  4) Plugins"
    echo "  5) Font installer"
    echo ""
    echo -e "${RED}This action cannot be undone!${NC}"
    echo ""
    echo -n "Continue with uninstallation? (y/N): "
    read confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Uninstallation cancelled.${NC}"
        exit 0
    fi
    echo ""
}

backup_zshrc() {
    if [ -f ~/.zshrc ]; then
        BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp ~/.zshrc "$BACKUP_FILE"
        echo -e "${GREEN}✓ Backup created: $BACKUP_FILE${NC}"
    fi
}

clean_zshrc() {
    echo -e "${CYAN}Cleaning .zshrc...${NC}"
    
    # Удаляем строки, связанные с DreamZSH
    sed -i '/export DREAMZSH_DIR/d' ~/.zshrc
    sed -i '/source.*dreamzsh/d' ~/.zshrc
    sed -i '/alias dreamzsh/d' ~/.zshrc
    sed -i '/alias dreamzsh-theme/d' ~/.zshrc
    
    # Удаляем пустые строки в конце
    sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' ~/.zshrc 2>/dev/null
    
    echo -e "${GREEN}✓ DreamZSH entries removed from .zshrc${NC}"
}

remove_dreamzsh_dir() {
    echo -e "${CYAN}Removing DreamZSH directory...${NC}"
    
    # Спрашиваем про сохранение настроек
    echo ""
    echo -n "Keep theme settings for future installation? (y/N): "
    read keep_settings
    
    if [[ "$keep_settings" =~ ^[Yy]$ ]]; then
        # Удаляем всё, кроме настроек темы
        find "$DREAMZSH_DIR" -maxdepth 1 -type f ! -name ".theme_settings" -delete 2>/dev/null
        find "$DREAMZSH_DIR" -mindepth 1 -type d -exec rm -rf {} + 2>/dev/null
        echo -e "${GREEN}✓ DreamZSH removed, theme settings preserved${NC}"
    else
        # Удаляем всё
        rm -rf "$DREAMZSH_DIR"
        echo -e "${GREEN}✓ DreamZSH completely removed${NC}"
    fi
}

restore_shell() {
    echo ""
    echo -e "${CYAN}Checking default shell...${NC}"
    
    CURRENT_SHELL=$(basename "$SHELL")
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        echo -e "${YELLOW}⚠️  ZSH is your default shell.${NC}"
        echo -n "Do you want to switch back to bash? (y/N): "
        read switch_shell
        
        if [[ "$switch_shell" =~ ^[Yy]$ ]]; then
            if command -v bash &> /dev/null; then
                chsh -s "$(which bash)"
                echo -e "${GREEN}✓ Default shell changed to bash${NC}"
                echo -e "${YELLOW}Changes will take effect after logout/restart${NC}"
            else
                echo -e "${RED}bash not found, keeping zsh${NC}"
            fi
        fi
    fi
}

show_complete() {
    echo ""
    echo -e "${CYAN}=========================================="
    echo "        UNINSTALLATION COMPLETE"
    echo -e "==========================================${NC}"
    echo ""
    echo -e "${GREEN}✓ DreamZSH has been removed${NC}"
    echo ""
    echo "To complete the uninstallation:"
    echo "  1) Restart your terminal"
    echo "  2) Or run: exec bash"
    echo ""
    echo -e "${YELLOW}Note: Your custom fonts (if installed) remain in ~/.local/share/fonts/${NC}"
    echo "      To remove them manually: rm -rf ~/.local/share/fonts/*Nerd*"
    echo ""
}

main() {
    print_header
    check_installation
    show_warning
    backup_zshrc
    clean_zshrc
    remove_dreamzsh_dir
    restore_shell
    show_complete
}

main
