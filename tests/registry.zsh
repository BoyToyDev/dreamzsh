#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

REPO_DIR="${0:A:h:h}"
if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then
  TEST_ROOT="$(mktemp -d "./.test-registry.XXXXXX")"
else
  TEST_ROOT="$(mktemp -d)"
fi
trap 'rm -rf -- "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export GIT_CONFIG_GLOBAL="$TEST_ROOT/gitconfig"
export DREAMZSH_DIR="$REPO_DIR"
export DREAMZSH_CONFIG_FILE="$TEST_ROOT/dreamzsh.conf"
export DREAMZSH_CUSTOM_DIR="$TEST_ROOT/custom"
export DREAMZSH_CUSTOM_PLUGINS_DIR="$DREAMZSH_CUSTOM_DIR/plugins"
export DREAMZSH_CUSTOM_THEMES_DIR="$DREAMZSH_CUSTOM_DIR/themes"
export DREAMZSH_CUSTOM_PROFILES_DIR="$DREAMZSH_CUSTOM_DIR/profiles"
export DREAMZSH_PLUGIN_REPOS_DIR="$DREAMZSH_CUSTOM_DIR/plugin-repos"
export DREAMZSH_PLUGIN_REPOS_FILE="$DREAMZSH_CUSTOM_DIR/plugin-repos.conf"
export DREAMZSH_OFFICIAL_PLUGIN_REPO_URL="https://example.invalid/dreamzsh-plugins.git"

mkdir -p "$HOME"

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

pass() {
  print -r -- "PASS: $*"
}

run_cli() {
  zsh "$DREAMZSH_DIR/bin/dreamzsh" "$@"
}

make_registry() {
  local repo="$1" plugin="$2" version="$3"
  mkdir -p "$repo/plugins/$plugin"
  cat > "$repo/plugins/$plugin/plugin.zsh" <<EOF
typeset -g REGISTRY_PLUGIN_VERSION="$version"
EOF
  cat > "$repo/plugins/$plugin/plugin.meta" <<EOF
plugin_name="$plugin"
description="Registry test plugin"
version="$version"
author="DreamZSH tests"
tags="test registry"
requires_plugins=""
requires_commands="git"
EOF
  cat > "$repo/plugins/$plugin/README.md" <<EOF
# $plugin

Test plugin from a DreamZSH registry.
EOF
  git -C "$repo" init -q
  git -C "$repo" config user.name "DreamZSH Tests"
  git -C "$repo" config user.email "tests@dreamzsh.invalid"
  git -C "$repo" add .
  git -C "$repo" commit -qm "registry $version"
}

file_url() {
  local file_path="$1"
  if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then
    file_path="$(cmd.exe //d //c "for %I in ($file_path) do @echo %~fsI" | tr -d '\r')"
    file_path="${file_path//\\//}"
    print -r -- "file:///$file_path"
  elif (( $+commands[cygpath] )); then
    print -r -- "file:///$(cygpath -m "$file_path")"
  elif [[ "$file_path" == [A-Za-z]:[\\/]* ]]; then
    file_path="${file_path//\\//}"
    print -r -- "file:///$file_path"
  else
    print -r -- "file://$file_path"
  fi
}

official_source="$TEST_ROOT/official-source"
extra_source="$TEST_ROOT/extra-source"
make_registry "$official_source" catalog-test 1.0.0
make_registry "$extra_source" extra-test 1.0.0

cat > "$GIT_CONFIG_GLOBAL" <<EOF
[protocol "file"]
  allow = always
[url "$(file_url "$official_source")"]
  insteadOf = $DREAMZSH_OFFICIAL_PLUGIN_REPO_URL
[url "$(file_url "$extra_source")"]
  insteadOf = https://example.invalid/dreamzsh-extra.git
EOF

source "$DREAMZSH_DIR/core/utils.zsh" || fail "load utils"
source "$DREAMZSH_DIR/core/config.zsh" || fail "load config"
source "$DREAMZSH_DIR/core/hooks.zsh" || fail "load hooks"
source "$DREAMZSH_DIR/core/plugins.zsh" || fail "load plugins"

DREAMZSH_PLUGINS=(git)

output="$(dz::registry::repo_list)" || fail "list repositories"
[[ "$output" == *official*not-fetched* ]] || fail "official repository is not built in"
run_cli plugin repo add >/dev/null || fail "sync official repository through CLI"
output="$(dz::registry::browse)" || fail "browse registry"
[[ "$output" == *catalog-test*official*available* ]] || fail "official plugin was not listed"
output="$(run_cli plugin browse --repo official)" || fail "CLI registry browse routing"
[[ "$output" == *catalog-test*official* ]] || fail "CLI did not list the official plugin"
output="$(dz::registry::plugin_info catalog-test)" || fail "remote plugin info"
[[ "$output" == *"Description: Registry test plugin"* ]] || fail "remote metadata was not read"
output="$(run_cli plugin info catalog-test --repo official)" || fail "CLI remote info routing"
[[ "$output" == *"Repository: official"* ]] || fail "CLI did not show remote plugin info"
pass "official repository browse and metadata"

run_cli plugin install catalog-test >/dev/null || fail "install registry plugin through CLI"
dz::config::load || fail "reload configuration after CLI install"
[[ -f "$DREAMZSH_CUSTOM_PLUGINS_DIR/catalog-test/source.meta" ]] || fail "registry source metadata missing"
[[ "$(dz::plugin::source_value catalog-test type)" == registry ]] || fail "registry source type missing"
dz::plugin::load_one catalog-test || fail "load registry plugin"
[[ "${REGISTRY_PLUGIN_VERSION:-}" == 1.0.0 ]] || fail "wrong installed plugin version"
[[ " ${DREAMZSH_PLUGINS[*]} " == *" catalog-test "* ]] || fail "registry plugin was not enabled"
pass "registry plugin installation and loading"

cat > "$official_source/plugins/catalog-test/plugin.zsh" <<'EOF'
typeset -g REGISTRY_PLUGIN_VERSION="2.0.0"
EOF
git -C "$official_source" add .
git -C "$official_source" commit -qm "registry 2.0.0"
dz::plugin::update_one catalog-test >/dev/null || fail "update registry plugin"
unset REGISTRY_PLUGIN_VERSION
dz::plugin::load_one catalog-test || fail "load updated registry plugin"
[[ "${REGISTRY_PLUGIN_VERSION:-}" == 2.0.0 ]] || fail "registry plugin was not updated"
pass "atomic registry plugin update"

dz::registry::repo_add https://example.invalid/dreamzsh-extra.git >/dev/null \
  || fail "add custom repository"
output="$(dz::registry::browse --repo dreamzsh-extra)" || fail "browse custom repository"
[[ "$output" == *extra-test*dreamzsh-extra* ]] || fail "custom repository plugin was not listed"
dz::registry::repo_remove dreamzsh-extra >/dev/null || fail "remove custom repository"
if dz::registry::source_record dreamzsh-extra >/dev/null 2>&1; then
  fail "custom repository was not removed"
fi
pass "custom plugin repository lifecycle"

print -r -- "All registry tests passed."
