# git-extra

Advanced Git helpers beyond basic aliases. Complements the `git` plugin.

## What it does

- WIP commit workflow (quick save/restore)
- Interactive rebase shortcuts
- Bisect helpers
- Repository analysis (churn, contributors, recent branches)

## Aliases

| Alias | Command |
|-------|---------|
| `gwip` | Stage all + commit "WIP" |
| `gunwip` | Undo last WIP commit |
| `gundo` | Undo last commit (keep changes) |
| `gamend` | Amend without editing message |
| `grbi` | `git rebase -i` |
| `grbc` | `git rebase --continue` |
| `grba` | `git rebase --abort` |

## Functions

| Function | Description |
|----------|-------------|
| `gignore <pattern>` | Append to .gitignore |
| `gcontrib [ref]` | Show contributor counts |
| `gchurn` | Top 20 most-changed files |
| `gremoved` | List deleted files in history |
| `grecent [n]` | Show N most recent branches |
| `gwhoami` | Show git user.name and user.email |
