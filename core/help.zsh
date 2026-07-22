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
  dreamzsh plugin browse [--repo <name>] [--refresh]
  dreamzsh plugin repo list
  dreamzsh plugin repo add <owner/repo|https-url> [--ref <ref>]
  dreamzsh plugin repo remove <name>
  dreamzsh plugin repo update [<name>|--all]
  dreamzsh plugin create <name>
  dreamzsh plugin install <name> [--repo <name>]
  dreamzsh plugin install <owner/repo|https-url> [options]
  dreamzsh plugin update <name> [name...]
  dreamzsh plugin update --all
  dreamzsh plugin remove <name> [--yes]
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
  dreamzsh plugin install <owner/repo|https-url> [options]
  dreamzsh plugin update <name> [name...]
  dreamzsh plugin update --all
  dreamzsh plugin remove <name> [--yes]
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
  dreamzsh profile export <new-name> [--output <archive>] [--from <profile>]
                           [--include-theme <theme>...]
  dreamzsh profile import <archive.tar.gz> [--apply] [--overwrite] [--yes]
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

dz::help::reload() {
  cat <<'EOF'
Usage: dreamzsh reload [--exec]

Source ~/.zshrc in the current interactive shell, preserving shell history,
jobs, directory stack, and other runtime state.

Options:
  --exec    Flush history and replace the current process with a fresh Zsh.
EOF
}

dz::help::command() {
  local group="${1:-}"
  local command="${2:-}"

  if [[ -z "$group" ]]; then
    dz::help::main
    return 0
  fi

  if [[ -z "$command" || "$command" == "help" ]]; then
    case "$group" in
      plugin)  dz::help::plugin ;;
      theme)   dz::help::theme ;;
      profile) dz::help::profile ;;
      backup)  dz::help::backup ;;
      reload)  dz::help::reload ;;
      *)
        dz::error "Unknown help topic: $group"
        return 1
        ;;
    esac
    return 0
  fi

  case "$group:$command" in
    plugin:list)
      print -r -- "Usage: dreamzsh plugin list"
      print -r -- "List installed plugins and their current state."
      ;;
    plugin:browse)
      print -r -- "Usage: dreamzsh plugin browse [--repo <name>] [--refresh]"
      print -r -- "List plugins published by the official and configured repositories."
      ;;
    plugin:repo)
      print -r -- "Usage: dreamzsh plugin repo <list|add|remove|update> [arguments]"
      print -r -- "Manage plugin repositories. The official repository is built in."
      print -r -- "Running 'dreamzsh plugin repo add' with no URL fetches the official repository."
      ;;
    plugin:create)
      print -r -- "Usage: dreamzsh plugin create <name>"
      print -r -- "Create a local plugin scaffold."
      ;;
    plugin:install)
      print -r -- "Usage: dreamzsh plugin install <registry-name> [--repo <name>]"
      print -r -- "       dreamzsh plugin install <owner/repo|https-url> [--name <name>]"
      print -r -- "       [--ref <branch|tag|commit>] [--entry <path>]"
      print -r -- "Installs and enables the plugin immediately."
      print -r -- "Clone and validate an external Zsh plugin without enabling it by default."
      ;;
    plugin:update)
      print -r -- "Usage: dreamzsh plugin update <name> [name...]"
      print -r -- "       dreamzsh plugin update --all"
      print -r -- "Atomically update installed external plugins."
      ;;
    plugin:remove)
      print -r -- "Usage: dreamzsh plugin remove <name> [--yes]"
      print -r -- "Disable and remove an external plugin."
      ;;
    plugin:enable)
      print -r -- "Usage: dreamzsh plugin enable <name> [name...]"
      print -r -- "       dreamzsh plugin enable --all"
      ;;
    plugin:disable)
      print -r -- "Usage: dreamzsh plugin disable <name> [name...]"
      print -r -- "       dreamzsh plugin disable --all"
      ;;
    plugin:info)
      print -r -- "Usage: dreamzsh plugin info <name> [--repo <name>]"
      print -r -- "Show installed or repository plugin metadata and documentation."
      ;;
    theme:list)
      print -r -- "Usage: dreamzsh theme list"
      print -r -- "List available themes."
      ;;
    theme:create)
      print -r -- "Usage: dreamzsh theme create <name>"
      print -r -- "Create a local theme scaffold."
      ;;
    theme:set)
      print -r -- "Usage: dreamzsh theme set <name>"
      print -r -- "Save a theme as the active theme."
      ;;
    theme:preview)
      print -r -- "Usage: dreamzsh theme preview <name>"
      print -r -- "Apply a theme without saving it."
      ;;
    theme:current)
      print -r -- "Usage: dreamzsh theme current"
      print -r -- "Print the active theme name."
      ;;
    profile:list)
      print -r -- "Usage: dreamzsh profile list"
      print -r -- "List available profiles."
      ;;
    profile:info)
      print -r -- "Usage: dreamzsh profile info <name>"
      print -r -- "Show profile contents and current state."
      ;;
    profile:apply)
      print -r -- "Usage: dreamzsh profile apply <name>"
      print -r -- "Apply a profile to the saved configuration."
      ;;
    profile:current)
      print -r -- "Usage: dreamzsh profile current"
      print -r -- "Print the active profile name."
      ;;
    profile:export)
      print -r -- "Usage: dreamzsh profile export <new-name> [--output <archive>]"
      print -r -- "       [--from <profile>] [--include-theme <theme>...]"
      print -r -- "Export current state under an arbitrary profile name."
      ;;
    profile:import)
      print -r -- "Usage: dreamzsh profile import <archive.tar.gz> [--apply] [--overwrite] [--yes]"
      print -r -- "Verify and import a self-contained profile package."
      ;;
    backup:create)
      print -r -- "Usage: dreamzsh backup create [--all|--only <items>]"
      print -r -- "Create a backup of selected DreamZSH state."
      ;;
    backup:list)
      print -r -- "Usage: dreamzsh backup list"
      print -r -- "List available backups."
      ;;
    backup:restore)
      print -r -- "Usage: dreamzsh backup restore <archive>"
      print -r -- "Restore a DreamZSH backup."
      ;;
    backup:clean)
      print -r -- "Usage: dreamzsh backup clean [--all]"
      print -r -- "Remove old backups or all backups."
      ;;
    *)
      dz::error "Unknown help topic: $group $command"
      return 1
      ;;
  esac
}
