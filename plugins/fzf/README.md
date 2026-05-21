# fzf

Fuzzy finder integration for Zsh. Supercharges your terminal workflow.

## What it does

- Sets up fzf with sensible defaults (height, layout, border)
- Uses `fd` or `rg` for faster file listing
- Adds helper functions for common fuzzy-finding tasks
- Loads native Zsh keybindings (Ctrl+T, Ctrl+R, Alt+C)

## Functions

| Function | Description |
|----------|-------------|
| `fkill` | Interactive process killer |
| `fbr` | Fuzzy git branch checkout |
| `fenv` | Fuzzy environment variable viewer |
| `fcd [dir]` | Fuzzy cd into subdirectory |
| `fhistory` | Fuzzy history search (places on prompt) |

## Requirements

Install `fzf` first: `brew install fzf` / `apt install fzf` / `pacman -S fzf`.

Optional but recommended: `fd`, `rg` (ripgrep), `bat`, `eza`.
