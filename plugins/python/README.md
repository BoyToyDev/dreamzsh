# python

Python development helpers — venv, package managers, and utilities.

## What it does

- Quick venv creation and activation
- Aliases for pip, poetry, conda, uv
- Cache cleanup, HTTP server, code formatting

## Commands

| Command | Description |
|---------|-------------|
| `venv [name]` | Create venv and activate it |
| `va` | Activate `.venv` |
| `vd` | Deactivate venv |
| `pyclean` | Remove all `__pycache__`, `.pyc`, cache dirs |
| `pyserve [port]` | Start HTTP server (default :8000) |
| `pyformat [path]` | Format with ruff or black+isort |

## Poetry aliases

| Alias | Command |
|-------|---------|
| `po` | `poetry` |
| `poi` | `poetry install` |
| `poa` | `poetry add` |
| `por` | `poetry run` |

## Conda aliases

| Alias | Command |
|-------|---------|
| `ca` | `conda activate` |
| `cl` | `conda env list` |

## uv aliases

| Alias | Command |
|-------|---------|
| `uvr` | `uv run` |
| `uva` | `uv add` |
| `uvs` | `uv sync` |
