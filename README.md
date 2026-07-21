# 🚀 DreamZSH

![GitHub stars](https://img.shields.io/github/stars/BoyToyDev/dreamzsh?style=flat)
![GitHub last commit](https://img.shields.io/github/last-commit/BoyToyDev/dreamzsh)
![License](https://img.shields.io/github/license/BoyToyDev/dreamzsh)

> **Stop editing `.zshrc`. Manage your shell like a system.**  
> **Zsh config as managed state, not handwritten files.**

DreamZSH is a lightweight, CLI-driven Zsh framework focused on usability and
predictable behavior. Plugins, themes, profiles, backups, and diagnostics are
managed with commands instead of manual edits to `.zshrc`.

---

## 🧠 Concept

Traditional Zsh setups are usually managed by editing shell files. DreamZSH
takes a different approach:

- use a CLI for everyday configuration;
- keep built-in resources separate from user-managed resources;
- make profiles portable and safe to share;
- report configuration problems instead of failing silently.

---

## ⚡ Installation

DreamZSH currently targets Linux with Zsh 5.0 or newer.

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/BoyToyDev/dreamzsh/master/install.sh)"
```

The interactive installer checks whether Zsh is installed, can offer to install
it through a supported Linux package manager, and checks whether the login shell
was switched successfully.

After installation, start a new Zsh session when prompted.

---

## ⚡ Quick start

```console
dreamzsh status
dreamzsh doctor
dreamzsh plugin list
dreamzsh theme list
dreamzsh profile list
dreamzsh help
```

Use command-specific help when needed:

```console
dreamzsh plugin install --help
dreamzsh help profile export
```

---

## 🔌 Plugins

Enable or disable one or more installed plugins:

```console
dreamzsh plugin enable git navigation history
dreamzsh plugin disable history
dreamzsh reload
```

### Official plugin repository

The official [DreamZSH plugin repository](https://github.com/BoyToyDev/dreamzsh-plugins)
is configured automatically.

```console
dreamzsh plugin repo add
dreamzsh plugin browse
dreamzsh plugin info <name>
dreamzsh plugin install <name> --enable
```

`plugin repo add` without a URL fetches the built-in official repository. Extra
repositories can be connected without assigning an alias manually:

```console
dreamzsh plugin repo add owner/repository
dreamzsh plugin repo list
dreamzsh plugin repo update --all
dreamzsh plugin repo remove repository
```

A plugin repository uses this layout:

```text
plugins/
└── plugin-name/
    ├── plugin.zsh
    ├── plugin.meta
    └── README.md
```

Repository metadata is read as data when browsing; it is not executed. Plugin
installation and updates are atomic, and the source URL, ref, commit, and path
are recorded locally.

### Any Git repository

Plugins can also be installed directly from a GitHub shorthand or HTTPS Git
URL:

```console
dreamzsh plugin install user/repository
dreamzsh plugin install https://github.com/user/repository.git --enable
dreamzsh plugin update --all
dreamzsh plugin remove <name>
```

### Creating a plugin

```console
dreamzsh plugin create my-plugin
dreamzsh plugin enable my-plugin
```

User-created and downloaded plugins are stored under `~/.dreamzsh/custom/`, so
they do not modify the framework's Git worktree.

Plugin metadata can declare two kinds of requirements:

```zsh
requires_plugins="git"
requires_commands="git fzf"
```

---

## 🎨 Themes

```console
dreamzsh theme list
dreamzsh theme set minimal
dreamzsh theme preview dream-smart
dreamzsh theme create my-theme
```

Themes can register runtime hooks and provide a cleanup function, allowing
DreamZSH to switch themes without leaving stale prompt hooks behind.

---

## 🧬 Profiles

Profiles combine a theme, a plugin set, and shareable custom resources.

```console
dreamzsh profile apply default
dreamzsh profile export My_super_prof
dreamzsh profile import My_super_prof.tar.gz --apply
```

An exported profile can use any new name. Self-contained archives include
selected themes and external plugin snapshots, source metadata, and SHA-256
checksums, so the profile can be shared and imported offline.

---

## 🛠 Maintenance

```console
dreamzsh backup create --all
dreamzsh backup list
dreamzsh doctor
dreamzsh doctor --fix
dreamzsh stats
dreamzsh update
dreamzsh reload
dreamzsh uninstall
```

`dreamzsh reload` replaces the current interactive Zsh process and loads the
updated configuration. `dreamzsh update` uses a fast-forward Git update and
refuses to overwrite local framework changes.

---

## ⚙️ Configuration

DreamZSH adds a small managed block to `.zshrc` and keeps its managed state in
`~/.dreamzsh/dreamzsh.conf`.

Common paths:

```text
~/.dreamzsh/
├── core/                 framework code
├── plugins/              built-in plugins
├── themes/               built-in themes
├── profiles/             built-in profiles
├── custom/               user-managed resources
│   ├── plugins/
│   ├── themes/
│   ├── profiles/
│   └── plugin-repos/     cached plugin repositories
└── backups/
```

Configuration writes are atomic. Existing configuration symlinks are preserved
by replacing their target instead of the symlink itself.

## ⚔️ Why DreamZSH?

| | Traditional Zsh setup | DreamZSH |
|---|---|---|
| Configuration | edit `.zshrc` manually | managed CLI |
| Visibility | scattered shell code | `status`, `info`, `stats` |
| Diagnostics | manual investigation | `doctor` |
| Recovery | manual copies | atomic writes and backups |
| Switching setups | rewrite config | portable profiles |
| Plugins | manual cloning | registry and Git installation |

---

## 🧪 Development

The project includes isolated CLI smoke tests, installer tests, lifecycle and
dependency tests, plugin registry tests, Zsh syntax checks, and an Ubuntu GitHub
Actions workflow.

Notable changes are recorded in [CHANGELOG.md](CHANGELOG.md) and
[CHANGELOG.ru.md](CHANGELOG.ru.md).

---

## 🧠 Philosophy

- CLI-driven management;
- minimal manual intervention;
- transparent and reversible behavior;
- useful diagnostics;
- no unnecessary startup overhead.

Your shell configuration should be predictable, reproducible, and debuggable.
DreamZSH treats it as managed state rather than an unstructured text file.

Ideas, issues, and pull requests are welcome.

## ⭐ Support

If you like the project, give it a star ⭐
