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
git -C "$seed" commit -qam update
git -C "$seed" push -qu origin main
dz::update::run >/dev/null || fail "update from configured upstream"
[[ "$(<"$install/version")" == two ]] || fail "update did not fast-forward checkout"
pass "update follows configured upstream branch"

print -r -- dirty > "$install/version"
if dz::update::run >/dev/null 2>&1; then
  fail "update accepted tracked local changes"
fi
[[ "$(<"$install/version")" == dirty ]] || fail "update overwrote tracked local changes"
git -C "$install" checkout -q -- version
pass "update protects tracked local changes"

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
