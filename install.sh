#!/usr/bin/env zsh

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

DREAMZSH_DIR="$HOME/dreamzsh"

# Выбор языка
select_language() {
    clear
    echo ""
    echo "=========================================="
    echo "        DREAMZSH INSTALLER"
    echo "=========================================="
    echo ""
    echo "Select language / Выберите язык:"
    echo "  1) English"
    echo "  2) Русский"
    echo ""
    echo -n "Choice (1-2): "
    read lang_choice
    
    case $lang_choice in
        1) LANG="en" ;;
        2) LANG="ru" ;;
        *) LANG="en" ;;
    esac
}

# Тексты на русском
ru_text() {
    HEADER="DREAMZSH INSTALLER"
    SUBHEADER="Минималистичная ZSH конфигурация"
    CHECK_ZSH="Проверка ZSH..."
    ZSH_OK="ZSH установлен"
    ZSH_NOT="ZSH не установлен"
    INSTALL_ZSH="Установите ZSH:"
    SELECT_COMPONENTS="Выберите компоненты для установки:"
    
    THEME_TITLE="Кастомная тема"
    THEME_DESC="Двухстрочный промпт в стиле Dracula"
    THEME_COLORS="Пользователь: зелёный | Сервер: пурпурный | Директория: жёлтый"
    
    PLUGINS_TITLE="Плагины"
    PLUGINS_DESC_GIT="git - алиасы для Git (gs, ga, gc, gp, gl)"
    PLUGINS_DESC_DOCKER="docker - алиасы для Docker (d, dps, dexec)"
    PLUGINS_DESC_UTILS="utils - утилиты (mkcd, ports, .., ...)"
    
    FONTS_TITLE="Nerd Fonts"
    FONTS_DESC="Шрифты с иконками для красивого отображения"
    FONTS_LIST="Hack, Fira Code, Meslo, JetBrains Mono"
    
    MANAGER_TITLE="DreamZSH Manager"
    MANAGER_DESC="Интерактивный менеджер для управления конфигурацией"
    
    ALIASES_TITLE="Алиасы"
    ALIASES_DESC1="dreamzsh - открыть менеджер"
    ALIASES_DESC2="dreamzsh-theme - открыть конструктор темы"
    ALIASES_DESC3="reload - перезагрузить конфиг"
    
    SUMMARY="ИТОГО"
    CONFIRM="Продолжить установку?"
    CANCEL="Установка отменена"
    
    INSTALLING_THEME="Установка кастомной темы..."
    THEME_INSTALLED="Тема установлена"
    INSTALLING_PLUGINS="Установка плагинов..."
    INSTALLING_BUILDER="Установка конструктора тем..."
    BUILDER_INSTALLED="Конструктор тем установлен"
    INSTALLING_FONTS="Установка скрипта для шрифтов..."
    FONTS_INSTALLED="Скрипт установки шрифтов готов"
    INSTALLING_MANAGER="Установка DreamZSH Manager..."
    MANAGER_INSTALLED="DreamZSH Manager установлен"
    CONFIGURING="Настройка .zshrc..."
    BACKUP_CREATED="Бэкап создан"
    ZSHRC_CONFIGURED=".zshrc настроен"
    
    COMPLETE="УСТАНОВКА ЗАВЕРШЕНА"
    INSTALLED="Установленные компоненты:"
    QUICK_START="Быстрый старт:"
    TIP="Совет: Если не отображаются иконки, установите Nerd Font через менеджер (пункт 4)"
    PRESS_ENTER="Нажмите Enter для завершения..."
    
    YES="y"
    NO="n"
    INSTALL="Установить"
    ADD="Добавить"
    CHOOSE="Выберите"
}

# English texts
en_text() {
    HEADER="DREAMZSH INSTALLER"
    SUBHEADER="Minimalistic ZSH configuration"
    CHECK_ZSH="Checking ZSH..."
    ZSH_OK="ZSH installed"
    ZSH_NOT="ZSH not found"
    INSTALL_ZSH="Install ZSH:"
    SELECT_COMPONENTS="Select components to install:"
    
    THEME_TITLE="Custom theme"
    THEME_DESC="Two-line prompt in Dracula style"
    THEME_COLORS="User: green | Host: magenta | Directory: yellow"
    
    PLUGINS_TITLE="Plugins"
    PLUGINS_DESC_GIT="git - aliases for Git (gs, ga, gc, gp, gl)"
    PLUGINS_DESC_DOCKER="docker - aliases for Docker (d, dps, dexec)"
    PLUGINS_DESC_UTILS="utils - utilities (mkcd, ports, .., ...)"
    
    FONTS_TITLE="Nerd Fonts"
    FONTS_DESC="Fonts with icons for beautiful display"
    FONTS_LIST="Hack, Fira Code, Meslo, JetBrains Mono"
    
    MANAGER_TITLE="DreamZSH Manager"
    MANAGER_DESC="Interactive manager for configuration management"
    
    ALIASES_TITLE="Aliases"
    ALIASES_DESC1="dreamzsh - open manager"
    ALIASES_DESC2="dreamzsh-theme - open theme builder"
    ALIASES_DESC3="reload - reload config"
    
    SUMMARY="SUMMARY"
    CONFIRM="Proceed with installation?"
    CANCEL="Installation cancelled"
    
    INSTALLING_THEME="Installing custom theme..."
    THEME_INSTALLED="Theme installed"
    INSTALLING_PLUGINS="Installing plugins..."
    INSTALLING_BUILDER="Installing theme builder..."
    BUILDER_INSTALLED="Theme builder installed"
    INSTALLING_FONTS="Installing fonts script..."
    FONTS_INSTALLED="Fonts installer ready"
    INSTALLING_MANAGER="Installing DreamZSH Manager..."
    MANAGER_INSTALLED="DreamZSH Manager installed"
    CONFIGURING="Configuring .zshrc..."
    BACKUP_CREATED="Backup created"
    ZSHRC_CONFIGURED=".zshrc configured"
    
    COMPLETE="INSTALLATION COMPLETE"
    INSTALLED="Installed components:"
    QUICK_START="Quick start:"
    TIP="Tip: If icons don't display, install Nerd Font via manager (option 4)"
    PRESS_ENTER="Press Enter to finish..."
    
    YES="y"
    NO="n"
    INSTALL="Install"
    ADD="Add"
    CHOOSE="Choose"
}

print_header() {
    clear
    echo ""
    echo -e "${CYAN}=========================================="
    echo -e "        $HEADER"
    echo -e "        $SUBHEADER"
    echo -e "==========================================${NC}"
    echo ""
}

check_zsh() {
    echo -e "${BLUE}$CHECK_ZSH${NC}"
    if ! command -v zsh &> /dev/null; then
        echo -e "${RED}$ZSH_NOT${NC}"
        echo -e "${YELLOW}$INSTALL_ZSH${NC}"
        echo "  Ubuntu/Debian: sudo apt install zsh"
        echo "  macOS: brew install zsh"
        exit 1
    fi
    echo -e "${GREEN}$ZSH_OK: $(zsh --version | cut -d' ' -f2)${NC}\n"
}

select_components() {
    echo -e "${CYAN}$SELECT_COMPONENTS${NC}\n"
    
    echo -e "${WHITE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│${NC}  ${GREEN}1) $THEME_TITLE${NC}                                        ${WHITE}│${NC}"
    echo -e "${WHITE}│${NC}     ${YELLOW}$THEME_DESC${NC}                               ${WHITE}│${NC}"
    echo -e "${WHITE}│${NC}     $THEME_COLORS${NC} ${WHITE}│${NC}"
    echo -e "${WHITE}└─────────────────────────────────────────────────────────┘${NC}"
    echo -n "$INSTALL theme? (y/n) [y]: "
    read install_theme
    install_theme=${install_theme:-y}
    echo ""
    
    echo -e "${WHITE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│${NC}  ${GREEN}2) $PLUGINS_TITLE${NC}                                         ${WHITE}│${NC}"
    echo -e "${WHITE}│${NC}     ${YELLOW}$PLUGINS_DESC_GIT${NC}${WHITE}│${NC}"
    echo -e "${WHITE}│${NC}     ${YELLOW}$PLUGINS_DESC_DOCKER${NC}${WHITE}│${NC}"
    echo -e "${WHITE}│${NC}     ${YELLOW}$PLUGINS_DESC_UTILS${NC}${WHITE}│${NC}"
    echo -e "${WHITE}└─────────────────────────────────────────────────────────┘${NC}"
    echo -n "$INSTALL plugins? (y/n) [y]: "
    read install_plugins
    install_plugins=${install_plugins:-y}
    
    if [ "$install_plugins" = "y" ]; then
        echo ""
        echo -e "${CYAN}  $CHOOSE plugins to install:${NC}"
        echo -n "    git (y/n) [y]: "
        read install_git
        install_git=${install_git:-y}
        echo -n "    docker (y/n) [y]: "
        read install_docker
        install_docker=${install_docker:-y}
        echo -n "    utils (y/n) [y]: "
        read install_utils
        install_utils=${install_utils:-y}
    fi
    echo ""
    
    echo -e "${WHITE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│${NC}  ${GREEN}3) $FONTS_TITLE${NC}                                        ${WHITE}│${NC}"
    echo -e "${WHITE}│${NC}     ${YELLOW}$FONTS_DESC${NC}                           ${WHITE}│${NC}"
    echo -e "${WHITE}│${NC}     $FONTS_LIST${NC}${WHITE}│${NC}"
    echo -e "${WHITE}└─────────────────────────────────────────────────────────┘${NC}"
    echo -n "$INSTALL fonts installer? (y/n) [n]: "
    read install_fonts
    install_fonts=${install_fonts:-n}
    echo ""
    
    echo -e "${WHITE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│${NC}  ${GREEN}4) $MANAGER_TITLE${NC}                                    ${WHITE}│${NC}"
    echo -e "${WHITE}│${NC}     ${YELLOW}$MANAGER_DESC${NC}                         ${WHITE}│${NC}"
    echo -e "${WHITE}└─────────────────────────────────────────────────────────┘${NC}"
    echo -n "$INSTALL manager? (y/n) [y]: "
    read install_manager
    install_manager=${install_manager:-y}
    echo ""
    
    echo -e "${WHITE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│${NC}  ${GREEN}5) $ALIASES_TITLE${NC}                                         ${WHITE}│${NC}"
    echo -e "${WHITE}│${NC}     ${YELLOW}$ALIASES_DESC1${NC}${WHITE}│${NC}"
    echo -e "${WHITE}│${NC}     ${YELLOW}$ALIASES_DESC2${NC}${WHITE}│${NC}"
    echo -e "${WHITE}│${NC}     ${YELLOW}$ALIASES_DESC3${NC}${WHITE}│${NC}"
    echo -e "${WHITE}└─────────────────────────────────────────────────────────┘${NC}"
    echo -n "$ADD aliases? (y/n) [y]: "
    read install_aliases
    install_aliases=${install_aliases:-y}
    echo ""
    
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}                    ${WHITE}$SUMMARY${NC}                              ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────────────┤${NC}"
    [ "$install_theme" = "y" ] && echo -e "${CYAN}│${NC}  ${GREEN}$THEME_TITLE${NC}                                          ${CYAN}│${NC}"
    [ "$install_plugins" = "y" ] && echo -e "${CYAN}│${NC}  ${GREEN}$PLUGINS_TITLE${NC}                                          ${CYAN}│${NC}"
    [ "$install_fonts" = "y" ] && echo -e "${CYAN}│${NC}  ${GREEN}$FONTS_TITLE${NC}                                         ${CYAN}│${NC}"
    [ "$install_manager" = "y" ] && echo -e "${CYAN}│${NC}  ${GREEN}$MANAGER_TITLE${NC}                                      ${CYAN}│${NC}"
    [ "$install_aliases" = "y" ] && echo -e "${CYAN}│${NC}  ${GREEN}$ALIASES_TITLE${NC}                                         ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    echo -n "$CONFIRM (y/n) [y]: "
    read confirm
    confirm=${confirm:-y}
    
    if [ "$confirm" != "y" ]; then
        echo -e "${RED}$CANCEL${NC}"
        exit 0
    fi
}

install_theme() {
    if [ "$install_theme" = "y" ]; then
        echo -e "${BLUE}$INSTALLING_THEME${NC}"
        mkdir -p "$DREAMZSH_DIR/themes"
        
        cat > "$DREAMZSH_DIR/themes/custom.zsh-theme" << 'THEME_EOF'
precmd() {
    PROMPT="%F{green}%n%f@%F{magenta}%m%f:%F{yellow}%~%f
%F{cyan}❯%f "
}
THEME_EOF
        echo -e "${GREEN}  $THEME_INSTALLED${NC}\n"
    fi
}

install_plugins() {
    if [ "$install_plugins" = "y" ]; then
        echo -e "${BLUE}$INSTALLING_PLUGINS${NC}"
        mkdir -p "$DREAMZSH_DIR/plugins"
        
        if [ "$install_git" = "y" ]; then
            cat > "$DREAMZSH_DIR/plugins/git.zsh" << 'GIT_EOF'
# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
GIT_EOF
            echo -e "${GREEN}  git${NC}"
        fi
        
        if [ "$install_docker" = "y" ]; then
            cat > "$DREAMZSH_DIR/plugins/docker.zsh" << 'DOCKER_EOF'
# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'
alias dstop='docker stop'
alias drm='docker rm'
DOCKER_EOF
            echo -e "${GREEN}  docker${NC}"
        fi
        
        if [ "$install_utils" = "y" ]; then
            cat > "$DREAMZSH_DIR/plugins/utils.zsh" << 'UTILS_EOF'
# Useful functions
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias reload='source ~/.zshrc'
alias ee='${EDITOR:-nano} ~/.zshrc'

function mkcd() {
    mkdir -p "$1" && cd "$1"
}

function ports() {
    lsof -i -P -n | grep LISTEN
}
UTILS_EOF
            echo -e "${GREEN}  utils${NC}"
        fi
        
        echo ""
    fi
}

install_theme_builder() {
    if [ "$install_theme" = "y" ]; then
        echo -e "${BLUE}$INSTALLING_BUILDER${NC}"
        
        cat > "$DREAMZSH_DIR/theme-builder.sh" << 'BUILDER_EOF'
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
BUILDER_EOF
        
        chmod +x "$DREAMZSH_DIR/theme-builder.sh"
        echo -e "${GREEN}  $BUILDER_INSTALLED${NC}\n"
    fi
}

install_fonts_script() {
    if [ "$install_fonts" = "y" ]; then
        echo -e "${BLUE}$INSTALLING_FONTS${NC}"
        mkdir -p "$DREAMZSH_DIR/fonts"
        
        cat > "$DREAMZSH_DIR/fonts/install.sh" << 'FONTS_EOF'
#!/usr/bin/env zsh

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

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
    echo "  0) Back"
    echo ""
}

install_font() {
    font_name="$1"
    font_display="$2"
    echo ""
    echo -e "${CYAN}Downloading ${font_display}...${NC}"
    font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    cd /tmp
    curl -L -o "${font_name}.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/${font_name}.zip" --progress-bar
    if [ -f "${font_name}.zip" ]; then
        unzip -q "${font_name}.zip" -d "${font_name}Font"
        find "${font_name}Font" -name "*.ttf" -o -name "*.otf" 2>/dev/null | while read f; do
            cp "$f" "$font_dir/" 2>/dev/null
        done
        rm -rf "${font_name}.zip" "${font_name}Font"
        fc-cache -fv 2>/dev/null
        echo -e "${GREEN} Font installed: ${font_display}${NC}"
    else
        echo -e "${RED} Download failed${NC}"
    fi
    read "?Press Enter..."
}

while true; do
    show_menu
    echo -n "Choose font (0-4): "
    read choice
    case $choice in
        1) install_font "Hack" "Hack Nerd Font" ;;
        2) install_font "FiraCode" "Fira Code Nerd Font" ;;
        3) install_font "Meslo" "Meslo Nerd Font" ;;
        4) install_font "JetBrainsMono" "JetBrains Mono Nerd Font" ;;
        0) exit 0 ;;
    esac
done
FONTS_EOF
        
        chmod +x "$DREAMZSH_DIR/fonts/install.sh"
        echo -e "${GREEN}  $FONTS_INSTALLED${NC}\n"
    fi
}

install_manager() {
    if [ "$install_manager" = "y" ]; then
        echo -e "${BLUE}$INSTALLING_MANAGER${NC}"
        
        cat > "$DREAMZSH_DIR/manager.sh" << 'MANAGER_EOF'
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
MANAGER_EOF
        
        chmod +x "$DREAMZSH_DIR/manager.sh"
        echo -e "${GREEN}  $MANAGER_INSTALLED${NC}\n"
    fi
}

configure_zshrc() {
    echo -e "${BLUE}$CONFIGURING${NC}"
    
    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${YELLOW}  $BACKUP_CREATED${NC}"
    fi
    
    cat > ~/.zshrc << 'ZSHRC_EOF'
export DREAMZSH_DIR="$HOME/dreamzsh"

# History settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Shell options
setopt interactivecomments
setopt NO_CASE_GLOB

# OS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi

ZSHRC_EOF
    
    if [ "$install_theme" = "y" ]; then
        echo "" >> ~/.zshrc
        echo "# DreamZSH theme" >> ~/.zshrc
        echo "source \$DREAMZSH_DIR/themes/custom.zsh-theme" >> ~/.zshrc
    fi
    
    if [ "$install_aliases" = "y" ]; then
        echo "" >> ~/.zshrc
        echo "# DreamZSH aliases" >> ~/.zshrc
        echo "alias dreamzsh='\$DREAMZSH_DIR/manager.sh'" >> ~/.zshrc
        echo "alias dreamzsh-theme='\$DREAMZSH_DIR/theme-builder.sh'" >> ~/.zshrc
        echo "alias reload='source ~/.zshrc'" >> ~/.zshrc
    fi
    
    echo -e "${GREEN}  $ZSHRC_CONFIGURED${NC}\n"
}

show_complete() {
    echo -e "${CYAN}=========================================="
    echo -e "        $COMPLETE"
    echo -e "==========================================${NC}"
    echo ""
    echo -e "${WHITE}$INSTALLED${NC}"
    [ "$install_theme" = "y" ] && echo -e "  ${GREEN}$THEME_TITLE${NC}"
    [ "$install_plugins" = "y" ] && echo -e "  ${GREEN}$PLUGINS_TITLE${NC}"
    [ "$install_fonts" = "y" ] && echo -e "  ${GREEN}$FONTS_TITLE${NC}"
    [ "$install_manager" = "y" ] && echo -e "  ${GREEN}$MANAGER_TITLE${NC}"
    [ "$install_aliases" = "y" ] && echo -e "  ${GREEN}$ALIASES_TITLE${NC}"
    echo ""
    echo -e "${WHITE}$QUICK_START${NC}"
    echo -e "  ${CYAN}reload${NC}         - $ALIASES_DESC3"
    echo -e "  ${CYAN}dreamzsh${NC}       - $ALIASES_DESC1"
    echo -e "  ${CYAN}dreamzsh-theme${NC} - $ALIASES_DESC2"
    echo ""
    echo -e "${YELLOW}$TIP${NC}"
    echo ""
    read "?$PRESS_ENTER"
    source ~/.zshrc
}

main() {
    select_language
    if [ "$LANG" = "ru" ]; then
        ru_text
    else
        en_text
    fi
    print_header
    check_zsh
    select_components
    install_theme
    install_plugins
    install_theme_builder
    install_fonts_script
    install_manager
    configure_zshrc
    show_complete
}

main
