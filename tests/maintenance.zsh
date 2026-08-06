#!/usr/bin/env zsh

setopt ERR_EXIT NO_UNSET PIPE_FAIL

repo_root="${0:A:h:h}"
test_root="$(mktemp -d)"
typeset -gi tests_passed=0

cleanup() { rm -rf -- "$test_root" }
trap cleanup EXIT
fail() { print -u2 -r -- "FAIL: $*"; exit 1 }
pass() { (( ++tests_passed )); print -r -- "PASS: $*" }

export GIT_CONFIG_GLOBAL="$test_root/gitconfig"
export HOME="$test_root/home"
mkdir -p "$HOME"

export DREAMZSH_DIR="$repo_root"
source "$repo_root/core/utils.zsh"
source "$repo_root/core/update.zsh"
source "$repo_root/core/uninstall.zsh"
source "$repo_root/core/config.zsh"
source "$repo_root/core/backup.zsh"
source "$repo_root/core/doctor.zsh"

remote="$test_root/remote.git"
seed="$test_root/seed"
install="$test_root/install"
git init -q --bare "$remote"
git init -q -b main "$seed"
git -C "$seed" config user.name "DreamZSH Tests"
git -C "$seed" config user.email "tests@dreamzsh.invalid"
print -r -- one > "$seed/version"
git -C "$seed" add version
git -C "$seed" commit -qm initial
git -C "$seed" remote add origin "$remote"
git -C "$seed" push -qu origin main
git --git-dir="$remote" symbolic-ref HEAD refs/heads/main
git clone -q "$remote" "$install"

export DREAMZSH_DIR="$install"
print -r -- two > "$seed/version"
mkdir -p "$seed/docs/assets" "$install/docs/assets"
print -r -- demo > "$seed/docs/assets/dreamzsh-demo.gif"
print -r -- demo > "$install/docs/assets/dreamzsh-demo.gif"
git -C "$seed" add version docs/assets/dreamzsh-demo.gif
git -C "$seed" commit -qm update
git -C "$seed" push -qu origin main
dz::update::run >/dev/null || fail "update from configured upstream"
[[ "$(<"$install/version")" == two ]] || fail "update did not fast-forward checkout"
git -C "$install" ls-files --error-unmatch docs/assets/dreamzsh-demo.gif >/dev/null \
  || fail "identical untracked file was not adopted"
pass "update follows configured upstream branch"
pass "update adopts identical untracked files from upstream"

print -r -- upstream > "$seed/incoming"
git -C "$seed" add incoming
git -C "$seed" commit -qm conflict
git -C "$seed" push -qu origin main
print -r -- local > "$install/incoming"
before_conflict="$(git -C "$install" rev-parse HEAD)"
if dz::update::run >/dev/null 2>&1; then
  fail "update overwrote a differing untracked file"
fi
[[ "$(<"$install/incoming")" == local ]] || fail "differing untracked file was changed"
[[ "$(git -C "$install" rev-parse HEAD)" == "$before_conflict" ]] \
  || fail "checkout advanced despite an untracked conflict"
rm -f -- "$install/incoming"
dz::update::run >/dev/null || fail "update after resolving untracked conflict"
pass "update preserves differing untracked files"

print -r -- dirty > "$install/version"
if dz::update::run >/dev/null 2>&1; then
  fail "update accepted tracked local changes"
fi
[[ "$(<"$install/version")" == dirty ]] || fail "update overwrote tracked local changes"
git -C "$install" checkout -q -- version
pass "update protects tracked local changes"

backup_root="$test_root/backup-install"
export DREAMZSH_DIR="$backup_root"
export DREAMZSH_CONFIG_FILE="$backup_root/dreamzsh.conf"
export DREAMZSH_CUSTOM_DIR="$backup_root/custom"
export DREAMZSH_CUSTOM_PLUGINS_DIR="$backup_root/custom/plugins"
export DREAMZSH_CUSTOM_THEMES_DIR="$backup_root/custom/themes"
export DREAMZSH_CUSTOM_PROFILES_DIR="$backup_root/custom/profiles"
export DREAMZSH_PLUGIN_REPOS_FILE="$backup_root/custom/plugin-repos.conf"
export DREAMZSH_BACKUPS_DIR="$backup_root/backups"
mkdir -p "$DREAMZSH_CUSTOM_PLUGINS_DIR/example" "$DREAMZSH_CUSTOM_THEMES_DIR" \
  "$DREAMZSH_CUSTOM_PROFILES_DIR" "$backup_root/plugins/builtin"
print -r -- original > "$DREAMZSH_CONFIG_FILE"
print -r -- custom > "$DREAMZSH_CUSTOM_PLUGINS_DIR/example/plugin.zsh"
print -r -- builtin > "$backup_root/plugins/builtin/plugin.zsh"
dz::backup::create --all >/dev/null || fail "backup create"
backup_archive=("$DREAMZSH_BACKUPS_DIR"/*.tar.gz(N))
(( ${#backup_archive[@]} == 1 )) || fail "backup archive was not created"
tar -tzf "$backup_archive[1]" | grep -Fq 'custom/plugins/example/plugin.zsh' \
  || fail "backup omitted custom plugin"
tar -tzf "$backup_archive[1]" | grep -Fq 'plugins/builtin' \
  && fail "backup included built-in plugins"
print -r -- changed > "$DREAMZSH_CONFIG_FILE"
print -r -- changed > "$DREAMZSH_CUSTOM_PLUGINS_DIR/example/plugin.zsh"
print y | dz::backup::restore "${backup_archive[1]:t}" >/dev/null || fail "backup restore"
[[ "$(<"$DREAMZSH_CONFIG_FILE")" == original ]] || fail "backup did not restore config"
[[ "$(<"$DREAMZSH_CUSTOM_PLUGINS_DIR/example/plugin.zsh")" == custom ]] \
  || fail "backup did not restore custom plugin"
dz::backup::restore ../outside.tar.gz >/dev/null 2>&1 \
  && fail "backup restore accepted a path outside backups"
pass "backup protects framework files and archive boundaries"

export DREAMZSH_DIR="$repo_root"
export DREAMZSH_CONFIG_FILE="$test_root/missing-config"
export DREAMZSH_THEMES_DIR="$repo_root/themes"
export DREAMZSH_PLUGINS_DIR="$repo_root/plugins"
DREAMZSH_THEME=minimal
DREAMZSH_PLUGINS=(git)
if dz::doctor::run >/dev/null 2>&1; then
  fail "doctor accepted a missing config"
fi
pass "doctor returns failure for missing core state"

history_doctor_root="$test_root/history-doctor"
export DREAMZSH_CONFIG_FILE="$repo_root/dreamzsh.conf.example"
export HISTFILE="$history_doctor_root/history"
DREAMZSH_PLUGINS=(history)
if dz::doctor::run >/dev/null 2>&1; then
  fail "doctor accepted missing history directory"
fi
mkdir -p "$history_doctor_root"
: > "$HISTFILE"
dz::doctor::run >/dev/null 2>&1 || fail "doctor rejected writable history file"
pass "doctor validates history storage"

reload_home="$test_root/reload-home"
mkdir -p "$reload_home/custom/cache"
print -r -- "$(( $(date +%s) ))" > "$reload_home/custom/cache/update-check"
cat > "$reload_home/config" <<'EOF'
DREAMZSH_THEME="minimal"
DREAMZSH_PROFILE="default"
DREAMZSH_PLUGINS=(git history navigation)
EOF
HOME="$reload_home" DREAMZSH_DIR="$repo_root" \
  DREAMZSH_CONFIG_FILE="$reload_home/config" DREAMZSH_CUSTOM_DIR="$reload_home/custom" \
  zsh -c '
    source "$DREAMZSH_DIR/core/update.zsh"
    dz::update::run() { print -r -- stale-updater }
    source "$DREAMZSH_DIR/core/init.zsh" >/dev/null 2>&1
    [[ "$(dz::update::run 2>/dev/null)" != stale-updater ]]
  ' || fail "reload kept the old update module"
pass "reload refreshes the update module"

export DREAMZSH_DIR="$test_root/dreamzsh-data"
mkdir -p "$DREAMZSH_DIR"
cat > "$HOME/.zshrc" <<'EOF'
before
# >>> dreamzsh >>>
source "$HOME/.dreamzsh/core/init.zsh"
# <<< dreamzsh <<<
after
EOF
dz::uninstall::run --yes >/dev/null || fail "non-interactive uninstall"
[[ "$(<"$HOME/.zshrc")" == $'before\nafter' ]] || fail "uninstall removed unrelated zshrc content"
[[ -d "$DREAMZSH_DIR" ]] || fail "normal uninstall removed DreamZSH files"
pass "uninstall preserves files and unrelated zshrc content"

cat > "$HOME/.zshrc" <<'EOF'
before
# >>> dreamzsh >>>
broken block
EOF
before_hash="$(cksum < "$HOME/.zshrc")"
if dz::uninstall::remove_block >/dev/null 2>&1; then
  fail "uninstall accepted an incomplete managed block"
fi
[[ "$(cksum < "$HOME/.zshrc")" == "$before_hash" ]] || fail "incomplete block changed zshrc"
pass "uninstall rejects incomplete managed blocks atomically"

cat > "$HOME/.zshrc" <<'EOF'
# >>> dreamzsh >>>
source "$HOME/.dreamzsh/core/init.zsh"
# <<< dreamzsh <<<
EOF
print -r -- user-data > "$DREAMZSH_DIR/custom-file"
dz::uninstall::purge --yes >/dev/null || fail "non-interactive purge"
[[ ! -e "$DREAMZSH_DIR" ]] || fail "purge left DreamZSH files behind"
grep -Fq '# >>> dreamzsh >>>' "$HOME/.zshrc" && fail "purge left zshrc block behind"
pass "purge removes integration and files with one confirmation"

print -r -- "All $tests_passed maintenance tests passed."
