# sudo

Quickly prepend `sudo` to any command.

## What it does

Binds double-ESC to insert `sudo` at the beginning of the current line. Works on empty lines too (inserts sudo before the previous command via history).

## Usage

- Type a command, press **ESC ESC** → `sudo` is prepended.
- Press **ESC ESC** on an empty line → `sudo !!` (re-run last command with sudo).

No configuration needed — just enable the plugin.
