<p align="center">
  <strong>English</strong> · <a href="README.ru.md">Русский</a>
</p>

<div align="center">

# ✨ DreamZSH

### Your Zsh setup, managed through a CLI

Plugins, themes, and portable profiles without manually editing shell config.

[![CI](https://github.com/BoyToyDev/dreamzsh/actions/workflows/ci.yml/badge.svg)](https://github.com/BoyToyDev/dreamzsh/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Zsh](https://img.shields.io/badge/shell-Zsh-6f42c1.svg)](https://www.zsh.org/)

[Quick start](#-quick-start) · [Plugins](#-plugins) · [Profiles](#-portable-profiles) · [Commands](#-command-map)

</div>

## Why DreamZSH?

- Manage your shell through discoverable commands and TAB completion.
- Enable, disable, inspect, and update plugins without editing `.zshrc`.
- Install plugins from the official catalog or any compatible Git repository.
- Export themes and external plugins as self-contained, shareable profiles.
- Keep configuration changes safe with atomic writes and verified imports.
- Extend a small, readable Zsh codebase instead of learning a private format.

> DreamZSH is currently developed and tested for Linux. macOS support is not a
> current target.

## 🚀 Quick start

```zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/BoyToyDev/dreamzsh/master/install.sh)"
```

The interactive installer checks for Zsh, can install it through a supported
Linux package manager, and can offer to make it your login shell. Start a new
shell after installation:

```zsh
exec zsh
dreamzsh doctor
```

Discover the CLI without memorizing it:

```text
dreamzsh <TAB><TAB>
dreamzsh plugin <TAB><TAB>
dreamzsh theme preview <TAB><TAB>
```

## 📼 Live demo

![DreamZSH live demo](https://raw.githubusercontent.com/BoyToyDev/dreamzsh/master/docs/assets/dreamzsh-demo.gif)

## 🧩 Plugins

### Built-in plugins

```zsh
dreamzsh plugin list
dreamzsh plugin enable git history
dreamzsh plugin disable history
dreamzsh plugin info git
```

Disabling a plugin keeps it installed and available for profiles.

### Official catalog

The official [DreamZSH plugin catalog](https://github.com/BoyToyDev/dreamzsh-plugins)
is built in. It is fetched automatically on the first `browse`, `info`, or
`install` command—there is no repository setup step.

```zsh
dreamzsh plugin browse
dreamzsh plugin info <name>
dreamzsh plugin install <name>
```

Installation enables the plugin immediately. If dependency validation or
activation fails, DreamZSH rolls the installation back.

### Extra catalogs and Git repositories

```zsh
dreamzsh plugin repo add owner/repository
dreamzsh plugin repo list
dreamzsh plugin repo update --all
dreamzsh plugin repo remove repository

dreamzsh plugin install owner/plugin
dreamzsh plugin install https://github.com/owner/plugin.git
```

Registry metadata is read as data rather than executed. Repository caches,
plugin installs, and plugin updates are replaced atomically.

## 🎨 Themes

```zsh
dreamzsh theme list
dreamzsh theme preview dream-mini
dreamzsh theme set dream-powerline
dreamzsh theme current
```

`preview` renders a theme without saving it. `set` makes it active.

## 📦 Portable profiles

A profile can carry the active theme, additional themes, enabled plugins, and
snapshots of external plugins. That makes a shell setup reproducible and easy
to share without relying on the original plugin repositories.

```zsh
dreamzsh profile export My_super_profile
dreamzsh profile import ./My_super_profile.tar.gz
dreamzsh profile apply My_super_profile
```

Imports validate paths and SHA-256 checksums before changing local state.

## 🗺️ Command map

| Task | Command |
|---|---|
| Check the installation | `dreamzsh doctor` |
| Show current state | `dreamzsh status` |
| Browse official plugins | `dreamzsh plugin browse` |
| Install and enable a plugin | `dreamzsh plugin install <name>` |
| Enable an installed plugin | `dreamzsh plugin enable <name>` |
| Preview a theme | `dreamzsh theme preview <name>` |
| Export a portable profile | `dreamzsh profile export <name>` |
| Reload the current shell | `dreamzsh reload` |
| Show startup statistics | `dreamzsh stats` |
| Update DreamZSH | `dreamzsh update` |
| Remove shell integration | `dreamzsh uninstall` |

Every command has focused help:

```zsh
dreamzsh help plugin
dreamzsh plugin install --help
dreamzsh profile export --help
```

## 🛠️ Creating extensions

```zsh
dreamzsh plugin create my-plugin
dreamzsh theme create my-theme
```

A catalog plugin uses a compact layout:

```text
plugins/plugin-name/
├── plugin.zsh
├── plugin.meta
└── README.md
```

Catalog entries may also reference an original upstream Git repository instead
of copying third-party source code:

```zsh
source_url="https://github.com/owner/project.git"
source_ref="main"
source_entrypoint="project.plugin.zsh"
```

DreamZSH clones, validates, and updates that upstream source while the official
catalog provides its reviewed metadata and documentation.

Plugin metadata distinguishes DreamZSH plugin dependencies from required system
commands through `requires_plugins` and `requires_commands`.

## 🧪 Reliability

DreamZSH uses isolated CLI smoke tests, lifecycle and dependency tests, registry
tests with local Git fixtures, update and uninstall tests, installer tests, Zsh
syntax checks, and Linux CI.
Configuration writes, repository refreshes, plugin updates, and profile imports
are designed to avoid partial state.

## Roadmap

- Grow the official plugin catalog beyond autosuggestions, syntax highlighting,
  and kubectl tools.
- Improve dependency diagnostics and profile portability.
- Add more themes and extension documentation.
- Explore optional lazy loading when the metadata design is ready.

See [CHANGELOG.md](CHANGELOG.md) for development history. Contributions and
focused issue reports are welcome.

## License

[MIT](LICENSE)
