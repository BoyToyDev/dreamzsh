# docker

Docker and Docker Compose aliases and helpers.

## What it does

Short aliases for common Docker commands plus helper functions for interactive shell access and cleanup.

Gracefully does nothing if Docker is not installed.

## Commands

| Alias | Expands to |
|-------|-----------|
| `d` | `docker` |
| `dc` | `docker compose` |
| `dcu` | `docker compose up` |
| `dcud` | `docker compose up -d` |
| `dcd` | `docker compose down` |
| `dps` | `docker ps` |
| `dpsa` | `docker ps -a` |
| `dexec` | `docker exec -it` |
| `dprune` | `docker system prune -af` |

## Functions

| Function | Description |
|----------|-------------|
| `dsh [container] [shell]` | Interactive shell into container (fzf picker if no name) |
| `dip <container>` | Show container IP address |
| `dclean` | Full system prune including volumes |

## Notes

`dsh` uses `fzf` for interactive container selection if available.
