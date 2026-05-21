# dreamzsh/core/hooks.zsh

if [[ -n "${__DREAMZSH_HOOKS_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_HOOKS_LOADED=1

typeset -gHa DREAMZSH_HOOK_PRE_INIT=()
typeset -gHa DREAMZSH_HOOK_POST_INIT=()
typeset -gHa DREAMZSH_HOOK_PRE_PLUGIN=()
typeset -gHa DREAMZSH_HOOK_POST_PLUGIN=()
typeset -gHa DREAMZSH_HOOK_PRE_PROMPT=()
typeset -gHa DREAMZSH_HOOK_POST_PROMPT=()

dz::hook::fire() {
  local hook_name="$1"
  local hook_var="DREAMZSH_HOOK_${hook_name}"
  local -a hooks
  local fn

  hooks=("${(@P)hook_var}")
  for fn in "${hooks[@]}"; do
    "${fn}" 2>/dev/null || true
  done
}

dz::hook::register() {
  local hook_name="$1"
  local fn_name="$2"
  local hook_var="DREAMZSH_HOOK_${hook_name}"

  if [[ -z "${(P)hook_var}" ]]; then
    dz::error "Unknown hook: $hook_name"
    return 1
  fi

  typeset -ga "$hook_var"
  eval "${hook_var}+=(\"$fn_name\")"
}
