# dreamzsh/core/completions.zsh

if [[ -n "${__DREAMZSH_COMPLETIONS_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_COMPLETIONS_LOADED=1

dz::completion::prepare() {
  local completion_dir="${DREAMZSH_DIR}/completions"

  [[ -d "$completion_dir" ]] || return 0
  (( ${fpath[(Ie)$completion_dir]} )) || fpath=("$completion_dir" $fpath)
}

dz::completion::init() {
  dz::completion::prepare

  autoload -Uz compinit
  if (( ! $+functions[compdef] )); then
    compinit -i
  fi

  autoload -Uz _dreamzsh
  compdef _dreamzsh dreamzsh
}
