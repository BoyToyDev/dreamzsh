# dreamzsh/core/init.zsh

unset __DREAMZSH_INIT_LOADED
unset __DREAMZSH_UTILS_LOADED
unset __DREAMZSH_CONFIG_LOADED
unset __DREAMZSH_PLUGINS_LOADED
unset __DREAMZSH_THEME_LOADED
unset __DREAMZSH_HELP_LOADED
unset __DREAMZSH_DOCTOR_LOADED
unset __DREAMZSH_PROFILES_LOADED
unset __DREAMZSH_HOOKS_LOADED
unset __DREAMZSH_REGISTRY_LOADED

: "${DREAMZSH_DIR:=${HOME}/.dreamzsh}"

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1
source "${DREAMZSH_DIR}/core/hooks.zsh" || return 1
source "${DREAMZSH_DIR}/core/plugins.zsh" || return 1
source "${DREAMZSH_DIR}/core/theme.zsh" || return 1
source "${DREAMZSH_DIR}/core/update.zsh" || return 1

dz::hook::fire PRE_INIT

dz::config::load || return 1

setopt PROMPT_SUBST

autoload -Uz add-zsh-hook
add-zsh-hook -d precmd dz::hook::dispatch_pre_prompt 2>/dev/null || true
add-zsh-hook -d precmd dz::hook::dispatch_post_prompt 2>/dev/null || true
add-zsh-hook precmd dz::hook::dispatch_pre_prompt

dz::plugin::load_all
dz::theme::load

add-zsh-hook precmd dz::hook::dispatch_post_prompt

dz::hook::fire POST_INIT

typeset -g __DREAMZSH_STARTUP_SECONDS="$SECONDS"

dz::update::check_background
