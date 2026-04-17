# 🚀 DreamZSH

> **Stop editing `.zshrc`. Manage your shell like a system.**  
> **Zsh config as managed state, not handwritten files.**

---

## 🤔 Why DreamZSH exists

Working with Zsh configs is painful.

- you edit `.zshrc` manually  
- you read tons of docs and wikis  
- you install plugins without really knowing what they do  
- you break things and don’t know why  

There is no structure. No visibility. No safety.

So DreamZSH was built to fix that.

---

## 🧠 The idea

Instead of editing config files:

👉 you manage your shell through a CLI

You can:

- enable plugins  
- preview and switch themes  
- inspect what is installed  
- read descriptions before using anything  
- validate your setup  
- backup and restore everything  

---

## ⚡ Example

```bash
dreamzsh plugin list
dreamzsh plugin enable git history
dreamzsh plugin info git

dreamzsh theme list
dreamzsh theme preview dream-powerline
dreamzsh theme set minimal

dreamzsh profile list
dreamzsh profile apply work

dreamzsh doctor
dreamzsh backup create --all
```

---

## 💎 Core features

### 🔌 Plugin management via CLI

No more guessing what plugins do.

```bash
dreamzsh plugin list
dreamzsh plugin info <name>
dreamzsh plugin enable <name>
```

---

### 🎨 Themes with preview

Try before you commit.

```bash
dreamzsh theme preview <name>
```

---

### 🧬 Profiles (full environments)

Switch your entire setup instantly.

```bash
dreamzsh profile apply work
```

---

### 🩺 Doctor (built-in diagnostics)

Debug your shell in one command.

```bash
dreamzsh doctor
```

---

### 💾 Backup & restore

Never break your shell again.

```bash
dreamzsh backup create --all
dreamzsh backup restore <archive>
```

---

## ⚔️ Why not oh-my-zsh?

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

## 🔮 What's coming next

### 📦 Shareable profiles (packages)

In the future:

- you will be able to create your own profile  
- bundle it with plugins and a theme  
- share it with others  

Example:

```bash
dreamzsh profile export my-setup
dreamzsh profile install someone/cool-setup
```

👉 This means:

- no setup time  
- no config editing  
- just install and use  

---

## ⚡ Installation

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/BoyToyDev/dreamzsh/master/install.sh)"
```

---


## 🤝 Contributing

Ideas, issues and pull requests are welcome.

---

## ⭐ Support

If you like the project — give it a star ⭐
