# 🚀 DreamZSH

> Zsh made easy to use.

**DreamZSH** is a lightweight Zsh framework focused on usability.  
Instead of editing configuration files, you manage everything through a simple CLI.

Supports:
- plugins  
- themes  
- profiles  
- ability to create your own plugins and themes  

Includes:
- error checking system  
- predictable and transparent behavior  

---

## 🎯 Concept

Traditional Zsh workflow is based on editing config files.

DreamZSH takes a different approach:

- you don’t edit config files  
- you control the system through commands  

---

## ⚡ Installation

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/BoyToyDev/dreamzsh/main/install.sh)"

After installation, you can start using it immediately.

⚙️ Configuration

DreamZSH does not require manual editing of .zshrc.

It uses an embedded block that:

works alongside your existing configuration
does not break your current setup
delegates control to the CLI
🧩 Features

Currently available:

profiles combining plugins and themes
full configuration via CLI
built-in help system
command autocompletion
improved navigation
extensible architecture focused on community development
🔌 Plugins

Plugins are enabled via CLI — no manual setup required.

You can enable multiple plugins at once:

dreamzsh plugin enable git navigation history

Each plugin is an isolated module:

plugins/<name>/
├── plugin.zsh
└── plugin.meta

plugin.meta contains plugin description, used by CLI for selection and management.

🧬 Profiles

Profiles represent a complete configuration set:

plugins
theme
settings

This allows you to:

quickly switch environments
maintain multiple setups
safely experiment

Example:

dreamzsh profile use default
📖 Help

All documentation is available directly in CLI:

dreamzsh help
dreamzsh plugin help
dreamzsh profile help
🧱 Principles
CLI-driven management
minimal manual intervention
simplicity of use
⚡ Performance
minimal overhead
fast shell startup
no unnecessary dependencies
🤝 Contributing

Ideas, issues and pull requests are welcome.

⭐ Support

If you like the project — give it a star ⭐

