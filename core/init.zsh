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
unset __DREAMZSH_COMPLETIONS_LOADED

: "${DREAMZSH_DIR:=${HOME}/.dreamzsh}"

zmodload zsh/datetime 2>/dev/null || true
typeset -g __DREAMZSH_INIT_STARTED_AT="${EPOCHREALTIME:-}"

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1
source "${DREAMZSH_DIR}/core/config.zsh" || return 1
source "${DREAMZSH_DIR}/core/hooks.zsh" || return 1
source "${DREAMZSH_DIR}/core/plugins.zsh" || return 1
source "${DREAMZSH_DIR}/core/theme.zsh" || return 1
source "${DREAMZSH_DIR}/core/update.zsh" || return 1
source "${DREAMZSH_DIR}/core/completions.zsh" || return 1

dz::hook::fire PRE_INIT

dz::config::load || return 1

setopt PROMPT_SUBST

dz::completion::prepare

autoload -Uz add-zsh-hook
add-zsh-hook -d precmd dz::hook::dispatch_pre_prompt 2>/dev/null || true
add-zsh-hook -d precmd dz::hook::dispatch_post_prompt 2>/dev/null || true
add-zsh-hook precmd dz::hook::dispatch_pre_prompt

dz::plugin::load_all
dz::completion::init
dz::theme::load

add-zsh-hook precmd dz::hook::dispatch_post_prompt

dz::hook::fire POST_INIT

if [[ -n "${__DREAMZSH_INIT_STARTED_AT:-}" && -n "${EPOCHREALTIME:-}" ]]; then
  typeset -gx __DREAMZSH_STARTUP_SECONDS="$(( EPOCHREALTIME - __DREAMZSH_INIT_STARTED_AT ))"
else
  unset __DREAMZSH_STARTUP_SECONDS
fi
unset __DREAMZSH_INIT_STARTED_AT

dz::update::check_background
