# dreamzsh/core/help.zsh

if [[ -n "${__DREAMZSH_HELP_LOADED:-}" ]]; then
  return 0
fi
__DREAMZSH_HELP_LOADED=1

source "${DREAMZSH_DIR}/core/utils.zsh" || return 1

dz::help::main() {
  cat <<'TXT'
DreamZSH — simple Zsh framework with themes and plugins

Usage:
  dreamzsh <command> [subcommand] [options]

Commands:
  plugin     Manage plugins
  theme      Manage themes
  profile    Manage profiles
  status     Show current DreamZSH status
  config     Show current configuration
  doctor     Check installation and configuration
  reload     Reload DreamZSH in current shell
  help       Show help

Plugin commands:
  dreamzsh plugin list
  dreamzsh plugin enable <name...>
  dreamzsh plugin disable <name...>
  dreamzsh plugin info <name>

Theme commands:
  dreamzsh theme list
  dreamzsh theme set <name>
  dreamzsh theme preview <name>
  dreamzsh theme current

Profile commands:
  dreamzsh profile list
  dreamzsh profile info <name>
  dreamzsh profile apply <name>
  dreamzsh profile current

Examples:
  dreamzsh status
  dreamzsh plugin enable git history
  dreamzsh theme set pro
  dreamzsh theme preview dream-powerline
  dreamzsh profile info default
  dreamzsh profile apply minimal
  dreamzsh doctor
TXT
}

dz::help::plugin() {
  cat <<'TXT'
Usage:
  dreamzsh plugin list
  dreamzsh plugin enable <name...>
  dreamzsh plugin disable <name...>
  dreamzsh plugin info <name>
TXT
}

dz::help::theme() {
  cat <<'TXT'
Usage:
  dreamzsh theme list
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