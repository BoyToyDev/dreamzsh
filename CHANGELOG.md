# Changelog

All notable changes to DreamZSH are documented in this file.

This changelog is maintained in English. The synchronized Russian version is
available in `CHANGELOG.ru.md`. New changes should first be recorded under
`Unreleased` and moved to a versioned section when a release is published.

## Unreleased

### 2026-07-24

#### Added

- Added segmented Catppuccin, Tokyo Night, Dracula, and Gruvbox themes with
  Git state, command status, and time.
- Added macOS support with native `shasum` checksums and a dedicated CI job.

#### Changed

- Consolidated the overlapping `dream`, `work`, and `pro` themes into
  compatibility migrations to `dream-smart` and `dream-mini`.

### 2026-07-23

#### Added

- Added registry entries backed by original upstream Git repositories through
  `source_url`, `source_ref`, and `source_entrypoint` metadata.
- Added atomic installation and updates that track both catalog and upstream
  commits for referenced plugins.
- Added registry coverage for browsing, inspecting, installing, loading, and
  updating upstream-backed plugins.
- Added dependency preflight for catalog installs so missing plugins and system
  commands are reported before any source is downloaded or configuration changed.

### 2026-07-22

#### Added

- Added synchronized English and Russian README versions with a language switch
  and a recorded terminal demonstration.
- Added `--yes` automation support and `ZDOTDIR` awareness to
  `dreamzsh uninstall`.
- Added focused update and uninstall tests to Linux CI.

#### Changed

- `plugin install` now enables newly installed plugins immediately; the
  redundant `--enable` option was removed from the CLI.
- The official plugin catalog is now fetched automatically by `browse`, `info`,
  and `install`; `plugin repo add` is reserved for additional repositories.
- `dreamzsh update` now follows the configured upstream branch instead of
  assuming `origin/master`, refuses tracked local changes or diverged history,
  and keeps its daily check marker outside the Git worktree.
- `dreamzsh reload` now sources `.zshrc` in the current shell to preserve
  runtime state; `--exec` remains available for a full process replacement.
- Theme previews now apply to the current interactive shell without changing
  the saved theme.
- Startup statistics now report measured loading time in milliseconds.
- Uninstall operations now update `.zshrc` atomically and validate the managed
  integration block before making changes.

### 2026-07-21

#### Added

- Added the built-in `official` plugin repository backed by
  `BoyToyDev/dreamzsh-plugins`.
- Added plugin repository management through `plugin repo list`, `add`,
  `remove`, and `update`.
- Added `plugin browse`, remote `plugin info`, and installation by registry
  plugin name with optional `--repo` selection.
- Added safe non-executing metadata reads while browsing repositories, atomic
  registry caching and plugin installation, and source-aware registry updates.
- Added offline registry tests using isolated local Git repositories.
- Added a shell-level `dreamzsh` wrapper so `dreamzsh reload` replaces the
  current interactive Zsh process instead of only printing an instruction.
- Added lifecycle hook unregistration, duplicate-registration protection,
  failure diagnostics, and plugin-name arguments for `PRE_PLUGIN` and
  `POST_PLUGIN` callbacks.
- Connected `PRE_PROMPT` and `POST_PROMPT` lifecycle hooks around theme prompt
  processing.
- Added separate `requires_plugins` and `requires_commands` plugin metadata
  fields, while preserving legacy `requires` as a plugin-dependency alias.
- Added lifecycle, reload, and plugin dependency tests to CI.

#### Changed

- Updated README documentation to cover the current installer, CLI, official
  plugin repository, portable profiles, maintenance commands, and tests.
- Changed `plugin info` and new plugin scaffolds to expose the two explicit
  dependency types.
- Changed direct CLI reload messaging to explain the parent-process limitation
  and provide `exec zsh` as a fallback.

#### Fixed

- Fixed `plugin enable` still calling the removed legacy dependency checker.
- Fixed registration of the first callback in an empty lifecycle hook.
- Fixed repeated registration of the same callback and silent hook failures.
- Fixed system command requirements being treated as DreamZSH plugin names.

### 2026-07-10

#### Added

- Added separate `custom/plugins`, `custom/themes`, and `custom/profiles`
  directories for user-managed resources.
- Added external plugin installation from `owner/repo` shorthand or HTTPS Git
  URLs with automatic entrypoint detection and optional `--name`, `--ref`,
  and `--entry` options.
- Added atomic external plugin updates and confirmed removal through
  `plugin update` and `plugin remove`.
- Added self-contained profile format version 1 with SHA-256 checksums,
  packaged external plugin snapshots, source metadata, and additional themes.
- Added `--output`, `--from`, and repeatable `--include-theme` options to
  `profile export`.
- Added verified profile import with conflict detection, `--overwrite`,
  `--yes`, and optional `--apply`.
- Added an interactive installer check for the `zsh` executable.
- Added optional Zsh installation through supported Linux package managers.
- Added login shell detection and an interactive offer to switch it with
  `chsh`.
- Added command-specific help for plugin, theme, profile, and backup
  subcommands, including forms such as `dreamzsh plugin enable --help` and
  `dreamzsh help plugin enable`.
- Added a compact CLI smoke test suite that runs with an isolated temporary
  `HOME`.
- Added installer smoke tests for repeated installation, missing Zsh,
  interactive Zsh installation, and login shell switching.
- Added an Ubuntu-only GitHub Actions workflow for POSIX shell checks, Zsh
  syntax checks, ShellCheck, and smoke tests.

#### Changed

- Changed `profile export <name>` to export the current managed state under an
  arbitrary new profile name instead of requiring an existing profile file.
- Changed locally created plugins and themes to be stored under `custom/`
  instead of modifying the DreamZSH Git worktree.
- Changed plugin, theme, and profile discovery to combine built-in and custom
  resources while preserving built-in resources.
- Changed backups to include selected custom plugins, themes, and profiles.
- Changed configuration saving to write a temporary file and atomically replace
  the previous configuration only after a successful write.
- Preserved configuration symlinks by atomically replacing their target instead
  of the symlink itself.
- Changed the installer completion message to distinguish between systems where
  Zsh is and is not the active login shell.
- Introduced the `dz::theme::cleanup()` lifecycle contract for themes that
  register runtime resources.

#### Fixed

- Fixed installations that appeared successful even though Zsh was not
  installed.
- Fixed installations that did not warn when the login shell remained different
  from Zsh.
- Fixed stale `precmd` hooks and helper functions remaining active after
  switching away from `dream-mini`, `dream-context`, `dream-smart`, or
  `dream-powerline`.
- Fixed the risk of truncating `dreamzsh.conf` when configuration writing fails.
