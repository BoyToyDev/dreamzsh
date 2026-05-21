# dreamzsh/core/help.zsh

if [[ -n "${__DREAMZSH_HELP_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_HELP_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1

dz::help::main() {
  cat <<'TXT'
DreamZSH - simple Zsh framework with themes and plugins

Usage:
  dreamzsh <command> [subcommand] [options]

Commands:
  plugin    Manage plugins
  theme     Manage themes
  profile   Manage profiles
  status    Show current DreamZSH status
  config    Show current configuration
  doctor    Check installation and configuration
  reload    Reload DreamZSH in current shell
  update    Update DreamZSH to latest version
  uninstall Remove DreamZSH from .zshrc
  stats     Show statistics and performance
  version   Show DreamZSH version
  help      Show help

Plugin commands:
  dreamzsh plugin list
  dreamzsh plugin create <name>
  dreamzsh plugin enable <name> [name...]
  dreamzsh plugin enable --all
  dreamzsh plugin disable <name> [name...]
  dreamzsh plugin disable --all
  dreamzsh plugin info <name>

Theme commands:
  dreamzsh theme list
  dreamzsh theme create <name>
  dreamzsh theme set <name>
  dreamzsh theme preview <name>
  dreamzsh theme current

Profile commands:
  dreamzsh profile list
  dreamzsh profile info <name>
  dreamzsh profile apply <name>
  dreamzsh profile current
  dreamzsh profile export <name> [output.tar.gz]
  dreamzsh profile import <archive.tar.gz> [--apply]

Examples:
  dreamzsh status
  dreamzsh plugin create my-plugin
  dreamzsh plugin enable git history
  dreamzsh theme create my-theme
  dreamzsh theme preview my-theme
  dreamzsh theme set pro
  dreamzsh profile info default
  dreamzsh profile apply minimal
  dreamzsh doctor
TXT
}

dz::help::plugin() {
  cat <<'TXT'
Usage:
  dreamzsh plugin list
  dreamzsh plugin create <name>
  dreamzsh plugin enable <name> [name...]
  dreamzsh plugin disable <name> [name...]
  dreamzsh plugin info <name>
TXT
}

dz::help::theme() {
  cat <<'TXT'
Usage:
  dreamzsh theme list
  dreamzsh theme create <name>
  dreamzsh theme set <name>
  dreamzsh theme preview <name>
  dreamzsh theme current
TXT
}

dz::help::profile() {
  cat <<'TXT'
Usage:
  dreamzsh profile list
  dreamzsh profile info <name>
  dreamzsh profile apply <name>
  dreamzsh profile current
TXT
}

dz::help::backup() {
  cat <<'TXT'
Usage:
  dreamzsh backup create
  dreamzsh backup create --all
  dreamzsh backup create --only config,themes
  dreamzsh backup list
  dreamzsh backup restore <archive>
  dreamzsh backup clean
  dreamzsh backup clean --all
TXT
}
