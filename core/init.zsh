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

dz::plugin::load_all
dz::theme::load

dz::hook::fire POST_INIT

typeset -g __DREAMZSH_STARTUP_SECONDS="$SECONDS"

dz::update::check_background
