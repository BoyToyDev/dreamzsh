#!/usr/bin/env sh

set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEST_ROOT=$(mktemp -d)
SYSTEM_PATH=$PATH
TESTS_PASSED=0

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup 0 HUP INT TERM

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

pass() {
  TESTS_PASSED=$((TESTS_PASSED + 1))
  printf 'PASS: %s\n' "$*"
}

make_repo_fixture() {
  home_dir=$1
  mkdir -p "$home_dir/.dreamzsh/.git"
  cp "$REPO_ROOT/dreamzsh.conf.example" "$home_dir/.dreamzsh/dreamzsh.conf.example"
}

MOCK_BIN="$TEST_ROOT/mock-bin"
MOCK_STATE_DIR="$TEST_ROOT/mock-state"
mkdir -p "$MOCK_BIN" "$MOCK_STATE_DIR"

cat > "$MOCK_BIN/git" <<'EOF'
#!/bin/sh
exit 0
EOF

cat > "$MOCK_BIN/zsh" <<'EOF'
#!/bin/sh
exit 0
EOF

cat > "$MOCK_BIN/getent" <<'EOF'
#!/bin/sh
if [ -f "$MOCK_STATE_DIR/shell-switched" ]; then
  login_shell="$MOCK_ZSH_PATH"
else
  login_shell="${MOCK_LOGIN_SHELL:-$MOCK_ZSH_PATH}"
fi
printf '%s:x:1000:1000:DreamZSH Test:/tmp:%s\n' "$2" "$login_shell"
EOF

cat > "$MOCK_BIN/chsh" <<'EOF'
#!/bin/sh
touch "$MOCK_STATE_DIR/shell-switched"
EOF

chmod +x "$MOCK_BIN/git" "$MOCK_BIN/zsh" "$MOCK_BIN/getent" "$MOCK_BIN/chsh"
export MOCK_BIN MOCK_STATE_DIR
MOCK_ZSH_PATH="$MOCK_BIN/zsh"
export MOCK_ZSH_PATH

repeat_home="$TEST_ROOT/repeat-home"
make_repo_fixture "$repeat_home"
MOCK_LOGIN_SHELL="$MOCK_ZSH_PATH"
export MOCK_LOGIN_SHELL

PATH="$MOCK_BIN:$SYSTEM_PATH" HOME="$repeat_home" \
  sh "$REPO_ROOT/install.sh" </dev/null >/dev/null 2>&1
PATH="$MOCK_BIN:$SYSTEM_PATH" HOME="$repeat_home" \
  sh "$REPO_ROOT/install.sh" </dev/null >/dev/null 2>&1

block_count=$(grep -c '^# >>> dreamzsh >>>$' "$repeat_home/.zshrc")
[ "$block_count" -eq 1 ] || fail "repeated install duplicated the .zshrc block"
pass "repeated install is idempotent"

zdot_home="$TEST_ROOT/zdot-home"
zdot_dir="$TEST_ROOT/zdot-config"
make_repo_fixture "$zdot_home"
mkdir -p "$zdot_dir"
PATH="$MOCK_BIN:$SYSTEM_PATH" HOME="$zdot_home" ZDOTDIR="$zdot_dir" \
  sh "$REPO_ROOT/install.sh" </dev/null >/dev/null 2>&1
grep -Fq '# >>> dreamzsh >>>' "$zdot_dir/.zshrc" \
  || fail "installer ignored ZDOTDIR"
[ ! -e "$zdot_home/.zshrc" ] || fail "installer wrote HOME/.zshrc while ZDOTDIR was set"
pass "installer respects ZDOTDIR"

missing_bin="$TEST_ROOT/missing-bin"
missing_home="$TEST_ROOT/missing-home"
mkdir -p "$missing_bin" "$missing_home"
cp "$MOCK_BIN/git" "$missing_bin/git"

if PATH="$missing_bin" HOME="$missing_home" \
  /bin/sh "$REPO_ROOT/install.sh" </dev/null >"$TEST_ROOT/missing.out" 2>&1; then
  fail "install without zsh returned success"
fi
grep -Fq 'zsh is required' "$TEST_ROOT/missing.out" \
  || fail "install without zsh did not explain the requirement"
[ ! -e "$missing_home/.dreamzsh" ] \
  || fail "install without zsh changed the installation directory"
pass "missing zsh stops installation"

SCRIPT_BIN=$(command -v script || true)
if [ -z "$SCRIPT_BIN" ]; then
  printf 'SKIP: interactive installer tests require util-linux script\n'
  printf 'All %s available installer smoke tests passed.\n' "$TESTS_PASSED"
  exit 0
fi

package_bin="$TEST_ROOT/package-bin"
package_home="$TEST_ROOT/package-home"
mkdir -p "$package_bin"
make_repo_fixture "$package_home"

for utility in awk cat cp grep id mkdir mktemp mv rm; do
  utility_path=$(PATH="$SYSTEM_PATH" command -v "$utility")
  ln -s "$utility_path" "$package_bin/$utility"
done
cp "$MOCK_BIN/git" "$package_bin/git"
cp "$MOCK_BIN/getent" "$package_bin/getent"

cat > "$package_bin/sudo" <<'EOF'
#!/bin/sh
exec "$@"
EOF

cat > "$package_bin/apt-get" <<'EOF'
#!/bin/sh
case " $* " in
  *" install "*)
    /bin/cp "$MOCK_ZSH_TEMPLATE" "$MOCK_PACKAGE_BIN/zsh"
    /bin/chmod +x "$MOCK_PACKAGE_BIN/zsh"
    ;;
esac
exit 0
EOF

chmod +x "$package_bin/git" "$package_bin/getent" \
  "$package_bin/sudo" "$package_bin/apt-get"

printf 'y\n' | env PATH="$package_bin" HOME="$package_home" \
  MOCK_STATE_DIR="$MOCK_STATE_DIR" MOCK_ZSH_PATH="$package_bin/zsh" \
  MOCK_LOGIN_SHELL="$package_bin/zsh" MOCK_PACKAGE_BIN="$package_bin" \
  MOCK_ZSH_TEMPLATE="$MOCK_BIN/zsh" \
  "$SCRIPT_BIN" -q -e -c "/bin/sh '$REPO_ROOT/install.sh'" /dev/null \
  >/dev/null 2>&1

[ -x "$package_bin/zsh" ] || fail "interactive install did not install zsh"
pass "interactive zsh installation"

switch_home="$TEST_ROOT/switch-home"
make_repo_fixture "$switch_home"
MOCK_LOGIN_SHELL=/bin/bash
export MOCK_LOGIN_SHELL
rm -f "$MOCK_STATE_DIR/shell-switched"

printf 'y\n' | env PATH="$MOCK_BIN:$SYSTEM_PATH" HOME="$switch_home" \
  MOCK_BIN="$MOCK_BIN" MOCK_STATE_DIR="$MOCK_STATE_DIR" \
  MOCK_ZSH_PATH="$MOCK_ZSH_PATH" MOCK_LOGIN_SHELL="$MOCK_LOGIN_SHELL" \
  "$SCRIPT_BIN" -q -e -c "sh '$REPO_ROOT/install.sh'" /dev/null >/dev/null 2>&1

[ -f "$MOCK_STATE_DIR/shell-switched" ] \
  || fail "interactive install did not call chsh"
pass "interactive login shell switch"

printf 'All %s installer smoke tests passed.\n' "$TESTS_PASSED"
