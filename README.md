# 🚀 DreamZSH

![GitHub stars](https://img.shields.io/github/stars/BoyToyDev/dreamzsh?style=flat)
![GitHub last commit](https://img.shields.io/github/last-commit/BoyToyDev/dreamzsh)
![License](https://img.shields.io/github/license/BoyToyDev/dreamzsh)

> **Stop editing `.zshrc`. Manage your shell like a system.**  
> **Zsh config as managed state, not handwritten files.**

---

## ⚡ Installation

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/BoyToyDev/dreamzsh/master/install.sh)"
```

---

## 🤔 Why DreamZSH exists

Working with Zsh configs is painful.

- you edit `.zshrc` manually  
- you read tons of docs and wikis  
- you install plugins without really knowing what they do  
- you break things and don’t know why  

There is no structure. No visibility. No safety.

DreamZSH fixes that.

---

## 🧠 The idea

Instead of editing config files:

👉 you manage your shell through a CLI

---

## ⚡ What can you actually do?

You can control your entire shell setup from the terminal.

### 🔌 Plugins

View all available plugins:

```bash
dreamzsh plugin list
```

Get detailed info about any plugin:

```bash
dreamzsh plugin info git
```

Enable multiple plugins at once:

```bash
dreamzsh plugin enable git history
```

Disable plugins just as easily:

```bash
dreamzsh plugin disable git history
```

---

### 🎨 Themes

Preview themes before applying:

```bash
dreamzsh theme preview dream-powerline
```

Set your theme:

```bash
dreamzsh theme set dream-powerline
```

---

### 🧬 Profiles

Apply a full environment instantly:

```bash
dreamzsh profile apply default
```

---

### 🩺 Diagnostics

Check your setup:

```bash
dreamzsh doctor
```

---

### 💾 Backup

Create a snapshot:

```bash
dreamzsh backup create --all
```

---

## ⚡ Try it in 30 seconds

```bash
dreamzsh profile apply default
dreamzsh plugin list
dreamzsh plugin info git
dreamzsh theme preview dream-powerline
dreamzsh doctor
```

---

## ⚔️ Why not traditional Zsh setup?

| | Traditional Zsh | DreamZSH |
|--|--|--|
| Config | edit `.zshrc` | CLI |
| Visibility | low | full |
| Debugging | manual | `doctor` |
| Safety | none | backup system |
| Switching setups | hard | profiles |

---

## 🧠 Philosophy

Your shell configuration should be:

- predictable  
- reproducible  
- debuggable  

DreamZSH treats your shell config as a **system**, not a text file.

---

## 🔮 What's next

### 📦 Shareable profiles (packages)

Soon you will be able to:

```bash
dreamzsh profile export my-setup
dreamzsh profile install someone/cool-setup
```

👉 No setup. Just install and use.

---

## ⭐ Support

If you like the project — give it a star ⭐
