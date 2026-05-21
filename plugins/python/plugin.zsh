# dreamzsh/plugins/python/plugin.zsh

(( $+commands[python3] )) || (( $+commands[python] )) || return 0

alias py='python3'
alias py3='python3'
alias pip='pip3'
alias ipy='ipython'

alias ve='python3 -m venv'
alias va='source .venv/bin/activate'
alias vd='deactivate'

venv() {
  local name="${1:-.venv}"
  python3 -m venv "$name" && source "$name/bin/activate" && print -r -- "venv: activated '$name'"
}

pyclean() {
  find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null
  find . -type f -name '*.pyc' -delete 2>/dev/null
  find . -type f -name '*.pyo' -delete 2>/dev/null
  find . -type d -name '*.egg-info' -exec rm -rf {} + 2>/dev/null
  find . -type d -name '.mypy_cache' -exec rm -rf {} + 2>/dev/null
  find . -type d -name '.pytest_cache' -exec rm -rf {} + 2>/dev/null
  find . -type d -name '.ruff_cache' -exec rm -rf {} + 2>/dev/null
  print -r -- "pyclean: cache files removed"
}

pyserve() {
  local port="${1:-8000}"
  print -r -- "Serving at http://localhost:$port"
  python3 -m http.server "$port"
}

pyformat() {
  local target="${1:-.}"
  if (( $+commands[ruff] )); then
    ruff format "$target" && ruff check --fix "$target"
  elif (( $+commands[black] )); then
    black "$target" && isort "$target"
  else
    print -u2 -- "pyformat: install ruff or black+isort"
    return 1
  fi
}

(( $+commands[poetry] )) && {
  alias po='poetry'
  alias poi='poetry install'
  alias poa='poetry add'
  alias poad='poetry add --dev'
  alias porm='poetry remove'
  alias por='poetry run'
  alias pos='poetry shell'
  alias poup='poetry update'
  alias pob='poetry build'
  alias popub='poetry publish'
}

(( $+commands[conda] )) && {
  alias ca='conda activate'
  alias cdac='conda deactivate'
  alias cl='conda env list'
  alias cc='conda create -n'
}

(( $+commands[uv] )) && {
  alias uvr='uv run'
  alias uva='uv add'
  alias uvad='uv add --dev'
  alias uvrm='uv remove'
  alias uvs='uv sync'
  alias uvv='uv venv'
}
