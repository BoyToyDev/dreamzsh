#!/usr/bin/env zsh

setopt ERR_EXIT NO_UNSET PIPE_FAIL

repo_root="${0:A:h:h}"
test_root="$(mktemp -d)"
test_home="$test_root/home"
install_dir="$test_home/.dreamzsh"
tests_passed=0

cleanup() {
  rm -rf -- "$test_root"
}
trap cleanup EXIT

fail() {
  print -u2 -r -- "FAIL: $*"
  exit 1
}

pass() {
  (( ++tests_passed ))
  print -r -- "PASS: $*"
}

assert_contains() {
  local text="$1"
  local expected="$2"
  local label="$3"
  [[ "$text" == *"$expected"* ]] || fail "$label (missing: $expected)"
  pass "$label"
}

run_cli() {
  local output
  output="$("$install_dir/bin/dreamzsh" "$@" 2>&1)" || {
    print -u2 -r -- "$output"
    fail "dreamzsh $* returned a non-zero status"
  }
  print -r -- "$output"
}

mkdir -p "$install_dir"
cp -R "$repo_root/bin" "$repo_root/core" "$repo_root/plugins" \
  "$repo_root/themes" "$repo_root/profiles" "$repo_root/completions" "$install_dir/"
cp "$repo_root/dreamzsh.conf.example" "$install_dir/dreamzsh.conf"
chmod +x "$install_dir/bin/dreamzsh"

export HOME="$test_home"
export DREAMZSH_DIR="$install_dir"

output="$(run_cli version)"
assert_contains "$output" "DreamZSH 0.2.0" "version command"

output="$(run_cli help)"
assert_contains "$output" "Usage:" "main help"

output="$(run_cli plugin enable --help)"
assert_contains "$output" "Usage: dreamzsh plugin enable" "subcommand --help"

output="$(run_cli help profile import)"
assert_contains "$output" "Usage: dreamzsh profile import" "help topic routing"

output="$(run_cli update --help)"
assert_contains "$output" "Usage: dreamzsh update" "update help"

output="$(run_cli uninstall --help)"
assert_contains "$output" "Usage: dreamzsh uninstall" "uninstall help"

output="$(run_cli plugin list)"
assert_contains "$output" "PLUGIN" "plugin list"

source "$install_dir/core/completions.zsh"
dz::completion::init
[[ "${_comps[dreamzsh]:-}" == _dreamzsh ]] \
  || fail "dreamzsh completion was not registered"
pass "completion registration"

export __DREAMZSH_STARTUP_SECONDS="0.042"
export DZ_COLOR_RESET='%f%b%k'
export DZ_COLOR_GREEN='%F{2}'
export DZ_COLOR_MAGENTA='%F{5}'
export DZ_COLOR_CYAN='%F{6}'
export DZ_COLOR_BOLD='%B'
output="$(run_cli stats)"
assert_contains "$output" "42 ms" "startup statistics"
[[ "$output" != *'%F{'* && "$output" != *'%B'* && "$output" != *'%f'* ]] \
  || fail "stats exposed raw Zsh prompt escapes"
pass "stats color rendering"

run_cli plugin disable history >/dev/null
run_cli plugin enable history >/dev/null
[[ -f "$install_dir/dreamzsh.conf" ]] || fail "config file was not saved"
typeset -a temporary_configs
temporary_configs=("$install_dir"/.dreamzsh.conf.tmp.*(N))
(( ${#temporary_configs[@]} == 0 )) || fail "temporary config files were left behind"
pass "atomic config save"

run_cli profile apply default >/dev/null
grep -Fq 'DREAMZSH_PROFILE="default"' "$install_dir/dreamzsh.conf" \
  || fail "default profile was not saved"
pass "profile apply"

typeset -ga precmd_functions=()
source "$install_dir/core/utils.zsh"
source "$install_dir/core/config.zsh"
source "$install_dir/core/theme.zsh"
dz::config::load

dz::theme::apply_by_name dream-mini
(( ${precmd_functions[(I)_dz_mini_prompt]} > 0 )) \
  || fail "dream-mini hook was not registered"

dz::theme::apply_by_name dream-context
(( ${precmd_functions[(I)_dz_mini_prompt]} == 0 )) \
  || fail "dream-mini hook survived theme switch"
(( ${precmd_functions[(I)_dz_ctx_build]} > 0 )) \
  || fail "dream-context hook was not registered"

dz::theme::apply_by_name minimal
if (( ${+precmd_functions} )) && (( ${precmd_functions[(I)_dz_ctx_build]} > 0 )); then
  fail "dream-context hook survived theme switch"
fi
pass "theme hook cleanup"

output="$(run_cli theme list)"
for palette_theme in catppuccin tokyo-night dracula gruvbox; do
  [[ "$output" == *"$palette_theme"* ]] || fail "palette theme is missing: $palette_theme"
  dz::theme::apply_by_name "$palette_theme"
  (( ${precmd_functions[(I)_dz_palette_build]} > 0 )) \
    || fail "palette hook was not registered: $palette_theme"
  [[ "$PROMPT" == *''* && "$PROMPT" == *'❯'* ]] \
    || fail "palette prompt was not built: $palette_theme"
done
[[ "$output" != *$'\ndream\n'* && "$output" != *$'\nwork\n'* && "$output" != *$'\npro\n'* ]] \
  || fail "deprecated themes are still listed"
pass "segmented palette themes"

dz::theme::apply_by_name dream >/dev/null
(( ${precmd_functions[(I)dz_build_dream_smart_prompt]} > 0 )) \
  || fail "deprecated dream theme did not migrate to dream-smart"
dz::theme::set work >/dev/null
[[ "$DREAMZSH_THEME" == dream-mini ]] \
  || fail "deprecated work theme did not migrate to dream-mini"
dz::theme::set dream-powerline >/dev/null
pass "deprecated theme migration"

dreamzsh theme preview dream-context >/dev/null
(( ${precmd_functions[(I)_dz_ctx_build]} > 0 )) \
  || fail "theme preview wrapper did not affect the current shell"
[[ "$PROMPT" == *'❯'* ]] || fail "theme preview did not update the current prompt"
grep -Fq 'DREAMZSH_THEME="dream-powerline"' "$install_dir/dreamzsh.conf" \
  || fail "theme preview changed the saved theme"
pass "current-shell theme preview"

plugin_source="$test_root/test-plugin"
mkdir -p "$plugin_source"
git -C "$plugin_source" init -q -b main
git -C "$plugin_source" config user.name "DreamZSH Tests"
git -C "$plugin_source" config user.email "tests@dreamzsh.local"
cat > "$plugin_source/test-plugin.plugin.zsh" <<'EOF'
alias dreamzsh_test_plugin='print external-plugin'
EOF
git -C "$plugin_source" add test-plugin.plugin.zsh
git -C "$plugin_source" commit -q -m "Initial plugin"

if (( $+commands[cygpath] )); then
  plugin_source_url="file:///$(cygpath -am "$plugin_source")"
else
  plugin_source_url="file://$plugin_source"
fi
git config --global --add url."$plugin_source_url".insteadOf \
  'https://example.invalid/test-plugin.git'

run_cli plugin install https://example.invalid/test-plugin.git >/dev/null
[[ -f "$install_dir/custom/plugins/test-plugin/source.meta" ]] \
  || fail "external plugin metadata was not created"
grep -Fq 'test-plugin' "$install_dir/dreamzsh.conf" \
  || fail "external plugin was not enabled"
output="$(run_cli plugin list)"
assert_contains "$output" "external" "external plugin install"
output="$(zsh -c 'source "$DREAMZSH_DIR/core/init.zsh"; alias dreamzsh_test_plugin' 2>&1)" \
  || fail "enabled external plugin could not be loaded"
assert_contains "$output" "external-plugin" "external plugin load"

print -r -- '# updated' >> "$plugin_source/test-plugin.plugin.zsh"
git -C "$plugin_source" add test-plugin.plugin.zsh
git -C "$plugin_source" commit -q -m "Update plugin"
old_commit="$(awk -F= '$1 == "commit" { print $2 }' "$install_dir/custom/plugins/test-plugin/source.meta")"
run_cli plugin update test-plugin >/dev/null
new_commit="$(awk -F= '$1 == "commit" { print $2 }' "$install_dir/custom/plugins/test-plugin/source.meta")"
[[ "$old_commit" != "$new_commit" ]] || fail "external plugin commit did not change"
pass "external plugin update"

run_cli theme create extra-theme >/dev/null
archive="$test_root/My_super_prof.tar.gz"
run_cli profile export My_super_prof --output "$archive" --include-theme extra-theme >/dev/null
[[ -f "$archive" ]] || fail "profile archive was not created"
tar -xOzf "$archive" manifest.txt | grep -Fq 'profile=My_super_prof' \
  || fail "export profile name was not written to manifest"
tar -tzf "$archive" | grep -Fq 'plugins/test-plugin/source/test-plugin.plugin.zsh' \
  || fail "external plugin snapshot was not packaged"
pass "self-contained profile export"

saved_archive="$test_root/Saved_copy.tar.gz"
run_cli profile export Saved_copy --from default --output "$saved_archive" >/dev/null
tar -xOzf "$saved_archive" manifest.txt | grep -Fq 'source_profile=default' \
  || fail "--from profile was not recorded"
pass "saved profile export source"

run_cli plugin remove test-plugin --yes >/dev/null
[[ ! -e "$install_dir/custom/plugins/test-plugin" ]] \
  || fail "external plugin was not removed"
pass "external plugin remove"

run_cli profile import "$archive" --yes --apply >/dev/null
[[ -f "$install_dir/custom/plugins/test-plugin/source/test-plugin.plugin.zsh" ]] \
  || fail "profile import did not restore external plugin"
output="$(run_cli profile current)"
assert_contains "$output" "My_super_prof" "self-contained profile import"

if output="$("$install_dir/bin/dreamzsh" definitely-unknown 2>&1)"; then
  fail "unknown command returned success"
fi
assert_contains "$output" "Unknown command" "unknown command failure"

print -r -- "All $tests_passed CLI smoke tests passed."
