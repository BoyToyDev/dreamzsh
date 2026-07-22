# DreamZSH README demo
Output docs/assets/dreamzsh-demo.gif

Require zsh

Set Shell "zsh"
Set FontSize 18
Set FontFamily "DejaVu Sans Mono"
Set Width 1100
Set Height 650
Set Padding 24
Set Margin 24
Set MarginFill "#171526"
Set BorderRadius 10
Set WindowBar Colorful
Set Theme "Catppuccin Mocha"
Set TypingSpeed 45ms
Set Framerate 30
Set PlaybackSpeed 1
Set CursorBlink false

# Start from a predictable state without showing setup commands.
Hide
Type "source ~/.zshrc"
Enter
Type "dreamzsh plugin disable extract >/dev/null 2>&1 || true"
Enter
Type "clear"
Enter
Show

Sleep 1s

# Discover commands with TAB completion.
Type "dreamzsh "
Tab@300ms 2
Sleep 2s
Ctrl+C
Type "clear"
Enter

# Enable a plugin without typing the full command or plugin name.
Type "dreamzsh pl"
Tab
Type "en"
Tab
Type "ex"
Tab
Sleep 700ms
Enter
Sleep 2s

# Inspect plugin metadata.
Type "dreamzsh pl"
Tab
Type "inf"
Tab
Type "git"
Tab
Enter
Sleep 3s

# Disable the plugin while keeping it installed.
Type "dreamzsh plugin dis"
Tab
Type "ex"
Tab
Enter
Sleep 2s

# Explore and preview themes without changing the config.
Type "dreamzsh th"
Tab
Type "pre"
Tab
Type "dream-"
Tab@300ms 2
Sleep 2s
Type "mini"
Tab
Enter
Sleep 3s

Type "# Everything through the CLI. No config editing."
Sleep 4s
