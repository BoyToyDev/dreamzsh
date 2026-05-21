# dreamzsh/themes/dream-context.zsh-theme

_dz_ctx_git_branch() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  local branch
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
    || branch=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return 0
  print -r -- "$branch"
}

_dz_ctx_python() {
  local venv_name=""
  if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    venv_name="${VIRTUAL_ENV:t}"
  elif [[ -n "${CONDA_DEFAULT_ENV:-}" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
    venv_name="$CONDA_DEFAULT_ENV"
  fi

  if [[ -n "$venv_name" ]]; then
    print -r -- " %F{3}py:${venv_name}%f"
  elif [[ -f "Pipfile" || -f "pyproject.toml" || -f "requirements.txt" || -f "setup.py" ]]; then
    local py_ver
    py_ver="$(python3 --version 2>/dev/null | cut -d' ' -f2)"
    [[ -n "$py_ver" ]] && print -r -- " %F{3}py:${py_ver}%f"
  fi
}

_dz_ctx_node() {
  if [[ -f "package.json" ]]; then
    local node_ver
    node_ver="$(node -v 2>/dev/null)"
    [[ -n "$node_ver" ]] && print -r -- " %F{2}${node_ver}%f"
  fi
}

_dz_ctx_docker() {
  if [[ -f "Dockerfile" || -f "docker-compose.yml" || -f "docker-compose.yaml" ]]; then
    print -r -- " %F{4}docker%f"
  fi
}

_dz_ctx_git_segment() {
  local branch
  branch="$(_dz_ctx_git_branch)"
  if [[ -n "$branch" ]]; then
    local dirty=""
    if ! command git diff --quiet 2>/dev/null || \
       ! command git diff --cached --quiet 2>/dev/null; then
      dirty="%F{1}●%f"
    fi
    print -r -- " %F{8}[%F{7}${branch}%f${dirty}%F{8}]%f"
  fi
}

_dz_ctx_build() {
  local exit_code=$?
  local arrow_color="5"
  local context=""

  if (( exit_code != 0 )); then
    arrow_color="1"
  fi

  context+="$(_dz_ctx_git_segment)"
  context+="$(_dz_ctx_python)"
  context+="$(_dz_ctx_node)"
  context+="$(_dz_ctx_docker)"

  PROMPT="%F{6}%1~%f${context} %F{${arrow_color}}❯%f "
  RPROMPT="%F{8}%*%f"
}

dz::theme::apply() {
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _dz_ctx_build
  _dz_ctx_build
}
