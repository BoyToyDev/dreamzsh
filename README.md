# DreamZSH

A lightweight and customizable ZSH framework for developers.  
Inspired by Oh My Zsh, but with simplified structure and easy plugin/theme management.

---

## Features

- Fully contained in `~/.dreamzsh`
- Plugin system: enable/disable, install from git
- Theme system: one-line/two-line layouts, color customization
- Profiles for quick environment setup
- Safety checks (PATH guard, plugin doctor)
- Live reloading (`dz` / `zreload`)

---

## Installation

### Fresh install

```bash
# Clone repository
git clone https://github.com/BoyToyDev/dreamzsh.git ~/.dreamzsh

# Run installer
bash ~/.dreamzsh/install.sh

# Reload ZSH
exec /usr/bin/zsh

# List available plugins
dreamzsh list

# Enable plugin
dreamzsh pluginon git

# Disable plugin
dreamzsh pluginoff git

# Install plugin from git
dreamzsh plugin install https://github.com/username/plugin.git

# List themes
dreamzsh themes

# Set theme
dreamzsh theme set wizarder

# Preview theme
dreamzsh theme preview wizarder

# Apply profile
dreamzsh profile dev

# Run plugin doctor
dreamzsh doctor

Plugins

Plugins are stored in ~/.dreamzsh/plugins.
Enable them by adding their name to ~/.dreamzsh/plugins/enabled_plugins or using dreamzsh pluginon <name>.

Themes

Themes are stored in:

Default: ~/.dreamzsh/themes/active
Custom: ~/.dreamzsh/themes/custom

Set active theme with:

dreamzsh theme set <theme_name>
Profiles

Profiles allow quick switching of environment setups.

dreamzsh profile <profile_name>

Profiles are stored in ~/.dreamzsh/profiles.

Safety
DreamZSH ensures $PATH is safe
Plugin doctor checks for dangerous commands
All scripts are loaded via loader.zsh for controlled execution
