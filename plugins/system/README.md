# system

System utilities and modern tool replacements.

## What it does

- Disk usage, memory, process, and network aliases
- Auto-replaces `ls`/`cat`/`top` with modern alternatives if installed (`eza`, `bat`, `htop`)
- File-finding helpers (big files, old files, big directories)
- Safe copy/move with progress via `rsync`

## Aliases

| Alias | Description |
|-------|-------------|
| `df` | Human-readable disk free |
| `du`, `dus`, `dud` | Disk usage shortcuts |
| `ports` | Show listening ports |
| `myip` | Public IP address |
| `localip` | Local IP address |
| `bigfiles` | Find files > 100MB |
| `bigdirs` | Largest directories |
| `oldfiles` | Files older than 90 days |
| `reload!` | `exec zsh` |
| `cpv`, `mvv` | Copy/move with progress |
| `chx` | `chmod +x` |

## Modern tool replacements

If installed, these tools replace standard commands:
- `eza`/`exa` → `ls`, `ll`, `la`, `lt`
- `bat` → `cat`
- `htop` → `top`
- `ncdu` → disk usage browser
