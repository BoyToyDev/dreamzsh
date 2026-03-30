# plugins/git.zsh

g() { git "$@"; }

gs() { git status; }
ga() { git add .; }
gc() { git commit -m "$1"; }
gp() { git push; }
gl() { git pull; }
