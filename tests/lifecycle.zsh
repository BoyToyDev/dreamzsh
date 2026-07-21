#!/usr/bin/env zsh

setopt NO_UNSET PIPE_FAIL

REPO_DIR="${0:A:h:h}"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf -- "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export DREAMZSH_DIR="$REPO_DIR"
export DREAMZSH_CONFIG_FILE="$TEST_ROOT/dreamzsh.conf"
export DREAMZSH_CUSTOM_DIR="$TEST_ROOT/custom"
export DREAMZSH_CUSTOM_PLUGINS_DIR="$DREAMZSH_CUSTOM_DIR/plugins"
export DREAMZSH_CUSTOM_THEMES_DIR="$DREAMZSH_CUSTOM_DIR/themes"
export DREAMZSH_CUSTOM_PROFILES_DIR="$DREAMZSH_CUSTOM_DIR/profiles"

mkdir -p "$HOME" "$DREAMZSH_CUSTOM_PLUGINS_DIR"

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

pass() {
  print -r -- "PASS: $*"
}

source "$DREAMZSH_DIR/core/utils.zsh" || fail "load utils"
source "$DREAMZSH_DIR/core/config.zsh" || fail "load config"
source "$DREAMZSH_DIR/core/hooks.zsh" || fail "load hooks"
source "$DREAMZSH_DIR/core/plugins.zsh" || fail "load plugins"

typeset -ga hook_events=()

test_pre_plugin_hook() {
  hook_events+=("pre:$1")
}

test_post_plugin_hook() {
  hook_events+=("post:$1")
}

test_failing_hook() {
  return 1
}

test_pre_prompt_hook() {
  hook_events+=("pre-prompt")
}

test_post_prompt_hook() {
  hook_events+=("post-prompt")
}

dz::hook::register PRE_PLUGIN test_pre_plugin_hook || fail "register first hook"
dz::hook::register PRE_PLUGIN test_pre_plugin_hook || fail "register duplicate hook"
(( ${#DREAMZSH_HOOK_PRE_PLUGIN[@]} == 1 )) || fail "duplicate hook was registered"
dz::hook::fire PRE_PLUGIN sample >/dev/null || fail "fire hook"
[[ "${hook_events[*]}" == "pre:sample" ]] || fail "hook did not receive plugin name"
dz::hook::unregister PRE_PLUGIN test_pre_plugin_hook || fail "unregister hook"
(( ${#DREAMZSH_HOOK_PRE_PLUGIN[@]} == 0 )) || fail "hook was not removed"
dz::hook::register PRE_PLUGIN test_failing_hook || fail "register failing hook"
if dz::hook::fire PRE_PLUGIN sample >/dev/null 2>&1; then
  fail "failing hook returned success"
fi
dz::hook::unregister PRE_PLUGIN test_failing_hook || fail "remove failing hook"
pass "lifecycle hook registration and arguments"

hook_events=()
dz::hook::register PRE_PROMPT test_pre_prompt_hook || fail "register pre-prompt hook"
dz::hook::register POST_PROMPT test_post_prompt_hook || fail "register post-prompt hook"
dz::hook::dispatch_pre_prompt || fail "dispatch pre-prompt hook"
dz::hook::dispatch_post_prompt || fail "dispatch post-prompt hook"
[[ "${hook_events[*]}" == "pre-prompt post-prompt" ]] \
  || fail "prompt hooks fired in the wrong order"
pass "prompt lifecycle dispatch order"

mkdir -p "$DREAMZSH_CUSTOM_PLUGINS_DIR/requirements-ok"
cat > "$DREAMZSH_CUSTOM_PLUGINS_DIR/requirements-ok/plugin.meta" <<'EOF'
plugin_name="requirements-ok"
requires_plugins="git"
requires_commands="git"
EOF
cat > "$DREAMZSH_CUSTOM_PLUGINS_DIR/requirements-ok/plugin.zsh" <<'EOF'
typeset -g REQUIREMENTS_PLUGIN_LOADED=1
EOF

mkdir -p "$DREAMZSH_CUSTOM_PLUGINS_DIR/requirements-missing"
cat > "$DREAMZSH_CUSTOM_PLUGINS_DIR/requirements-missing/plugin.meta" <<'EOF'
plugin_name="requirements-missing"
requires_plugins="missing-plugin"
requires_commands="dreamzsh-command-that-does-not-exist"
EOF
cat > "$DREAMZSH_CUSTOM_PLUGINS_DIR/requirements-missing/plugin.zsh" <<'EOF'
typeset -g REQUIREMENTS_MISSING_PLUGIN_LOADED=1
EOF

mkdir -p "$DREAMZSH_CUSTOM_PLUGINS_DIR/requirements-legacy"
cat > "$DREAMZSH_CUSTOM_PLUGINS_DIR/requirements-legacy/plugin.meta" <<'EOF'
plugin_name="requirements-legacy"
requires="git"
EOF
cat > "$DREAMZSH_CUSTOM_PLUGINS_DIR/requirements-legacy/plugin.zsh" <<'EOF'
typeset -g REQUIREMENTS_LEGACY_PLUGIN_LOADED=1
EOF

DREAMZSH_PLUGINS=(git requirements-ok requirements-missing requirements-legacy)
[[ "$(dz::plugin::get_requirements requirements-ok plugins)" == "git" ]] \
  || fail "plugin requirements were not parsed"
[[ "$(dz::plugin::get_requirements requirements-ok commands)" == "git" ]] \
  || fail "command requirements were not parsed"
[[ "$(dz::plugin::get_requirements requirements-legacy plugins)" == "git" ]] \
  || fail "legacy requirements were not preserved"
[[ "$(dz::plugin::check_plugin_deps requirements-missing 2>/dev/null)" == "missing-plugin" ]] \
  || fail "missing plugin dependency was not reported"
[[ "$(dz::plugin::check_command_deps requirements-missing 2>/dev/null)" == "dreamzsh-command-that-does-not-exist" ]] \
  || fail "missing command dependency was not reported"

dz::hook::register PRE_PLUGIN test_pre_plugin_hook || fail "register plugin pre-hook"
dz::hook::register POST_PLUGIN test_post_plugin_hook || fail "register plugin post-hook"
hook_events=()
dz::plugin::load_one requirements-ok || fail "load plugin with satisfied requirements"
(( ${REQUIREMENTS_PLUGIN_LOADED:-0} == 1 )) || fail "plugin body was not sourced"
[[ "${hook_events[*]}" == "pre:requirements-ok post:requirements-ok" ]] \
  || fail "plugin lifecycle hooks fired in the wrong order"
if dz::plugin::load_one requirements-missing >/dev/null 2>&1; then
  fail "plugin with missing requirements was loaded"
fi
(( ${REQUIREMENTS_MISSING_PLUGIN_LOADED:-0} == 0 )) \
  || fail "plugin with missing requirements sourced its body"
pass "separate plugin and command requirements"

real_zsh="${commands[zsh]:-/usr/bin/zsh}"
mkdir -p "$TEST_ROOT/zdot"
cat > "$TEST_ROOT/zdot/.zshenv" <<EOF
print -r -- reloaded > "$TEST_ROOT/reloaded"
EOF

ZDOTDIR="$TEST_ROOT/zdot" \
DREAMZSH_ZSH_BIN="$real_zsh" \
DREAMZSH_DIR="$REPO_DIR" \
  "$real_zsh" -c 'source "$DREAMZSH_DIR/core/utils.zsh"; dreamzsh reload' \
  || fail "reload wrapper failed"
[[ "$(cat "$TEST_ROOT/reloaded" 2>/dev/null)" == "reloaded" ]] \
  || fail "reload did not exec zsh"

output="$(DREAMZSH_ZSH_BIN="$real_zsh" DREAMZSH_DIR="$REPO_DIR" \
  "$real_zsh" -c 'source "$DREAMZSH_DIR/core/utils.zsh"; dreamzsh --version')" \
  || fail "CLI delegation failed"
[[ "$output" == DreamZSH\ * ]] || fail "wrapper did not delegate to CLI"
pass "real shell reload and CLI delegation"

print -r -- "All lifecycle tests passed."
