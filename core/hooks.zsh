# dreamzsh/core/hooks.zsh

if [[ -n "${__DREAMZSH_HOOKS_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_HOOKS_LOADED=1

typeset -ga DREAMZSH_HOOK_PRE_INIT=()
typeset -ga DREAMZSH_HOOK_POST_INIT=()
typeset -ga DREAMZSH_HOOK_PRE_PLUGIN=()
typeset -ga DREAMZSH_HOOK_POST_PLUGIN=()
typeset -ga DREAMZSH_HOOK_PRE_PROMPT=()
typeset -ga DREAMZSH_HOOK_POST_PROMPT=()

dz::hook::fire() {
  local hook_name="$1"
  local hook_var="DREAMZSH_HOOK_${hook_name}"
  local -a hooks
  local fn
  local failed=0

  shift

  if (( ! ${+parameters[$hook_var]} )); then
    dz::error "Unknown hook: $hook_name"
    return 1
  fi

  hooks=("${(@P)hook_var}")
  for fn in "${hooks[@]}"; do
    if (( ! $+functions[$fn] )); then
      dz::warn "Hook function not found: $fn ($hook_name)"
      failed=1
      continue
    fi

    "$fn" "$@" || {
      dz::warn "Hook failed: $fn ($hook_name)"
      failed=1
    }
  done

  return "$failed"
}

dz::hook::register() {
  local hook_name="$1"
  local fn_name="$2"
  local hook_var="DREAMZSH_HOOK_${hook_name}"
  local registered

  if (( ! ${+parameters[$hook_var]} )); then
    dz::error "Unknown hook: $hook_name"
    return 1
  fi

  [[ -n "$fn_name" ]] || {
    dz::error "Hook function name is required"
    return 1
  }

  for registered in "${(@P)hook_var}"; do
    [[ "$registered" == "$fn_name" ]] && return 0
  done

  eval "${hook_var}+=(\${(q)fn_name})"
}

dz::hook::unregister() {
  local hook_name="$1"
  local fn_name="$2"
  local hook_var="DREAMZSH_HOOK_${hook_name}"
  local registered
  local -a remaining=()

  if (( ! ${+parameters[$hook_var]} )); then
    dz::error "Unknown hook: $hook_name"
    return 1
  fi

  for registered in "${(@P)hook_var}"; do
    [[ "$registered" == "$fn_name" ]] || remaining+=("$registered")
  done

  eval "${hook_var}=(\${(q)remaining[@]})"
}

dz::hook::dispatch_pre_prompt() {
  dz::hook::fire PRE_PROMPT
}

dz::hook::dispatch_post_prompt() {
  dz::hook::fire POST_PROMPT
}
