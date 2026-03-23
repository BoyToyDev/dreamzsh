#!/usr/bin/env zsh

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

DREAMZSH_DIR="$HOME/dreamzsh"
THEME_FILE="$DREAMZSH_DIR/themes/custom.zsh-theme"

USER_COLOR="green"
HOST_COLOR="magenta"
DIR_COLOR="yellow"
PROMPT_SYMBOL="❯"
PROMPT_COLOR="cyan"
SEPARATOR="@"
SEPARATOR_COLOR="white"

show_current() {
    echo ""
    echo "=========================================="
    echo "     DREAMZSH THEME BUILDER"
    echo "=========================================="
    echo ""
    echo "Current theme:"
    echo "  ${GREEN}username${NC}${SEPARATOR}${CYAN}hostname${NC}:${YELLOW}directory${NC}"
    echo "  ${CYAN}${PROMPT_SYMBOL}${NC}"
    echo ""
    echo "Settings:"
    echo "  1) User color   : $USER_COLOR"
    echo "  2) Host color   : $HOST_COLOR"
    echo "  3) Dir color    : $DIR_COLOR"
    echo "  4) Prompt color : $PROMPT_COLOR"
    echo "  5) Prompt symbol: $PROMPT_SYMBOL"
    echo "  6) Separator    : $SEPARATOR"
    echo "  7) Sep color    : $SEPARATOR_COLOR"
    echo "  8) Save and apply"
    echo "  0) Exit"
    echo ""
}

save_and_apply() {
    echo "precmd() {" > "$THEME_FILE"
    echo "    PROMPT=\"%F{$USER_COLOR}%n%f%F{$SEPARATOR_COLOR}$SEPARATOR%f%F{$HOST_COLOR}%m%f:%F{$DIR_COLOR}%~%f" >> "$THEME_FILE"
    echo "%F{$PROMPT_COLOR}$PROMPT_SYMBOL%f \"" >> "$THEME_FILE"
    echo "}" >> "$THEME_FILE"
    sed -i '/source.*themes/d' ~/.zshrc
    echo "source \$DREAMZSH_DIR/themes/custom.zsh-theme" >> ~/.zshrc
    source ~/.zshrc
    echo -e "${GREEN}Theme applied${NC}"
    sleep 1
}

while true; do
    show_current
    echo -n "Choose (0-8): "
    read choice
    case $choice in
        1) echo -n "User color: "; read USER_COLOR ;;
        2) echo -n "Host color: "; read HOST_COLOR ;;
        3) echo -n "Dir color: "; read DIR_COLOR ;;
        4) echo -n "Prompt color: "; read PROMPT_COLOR ;;
        5) echo -n "Prompt symbol: "; read PROMPT_SYMBOL ;;
        6) echo -n "Separator: "; read SEPARATOR ;;
        7) echo -n "Separator color: "; read SEPARATOR_COLOR ;;
        8) save_and_apply ;;
        0) exit 0 ;;
    esac
done
