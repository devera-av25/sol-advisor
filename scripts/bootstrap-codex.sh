#!/bin/sh
# Bootstrap this Sol Advisor checkout into Codex and install its native agent roles.

set -eu

usage() {
  cat <<'USAGE'
Usage: sh scripts/bootstrap-codex.sh [--expected-branch BRANCH]

Registers this checkout as a local Codex marketplace, installs sol-advisor@sol-advisor,
installs the five native custom-agent profiles, and validates exact model/reasoning
pins. It does not change the primary Codex model and does not spawn/test newly installed
agents in the current task.

Options:
  --expected-branch BRANCH  Fail unless this checkout is currently on BRANCH.
  --help                    Show this help text.
USAGE
}

fail() {
  printf '%s\n' "BOOTSTRAP ERROR: $*" >&2
  exit 1
}

note() {
  printf '%s\n' "==> $*"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "required command '$1' was not found in PATH."
}

expected_branch=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    --expected-branch)
      [ "$#" -ge 2 ] || fail "--expected-branch requires a value."
      [ -n "$2" ] || fail "--expected-branch requires a non-empty value."
      expected_branch=$2
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      fail "unknown argument: $1"
      ;;
  esac
done

require_command git
require_command codex
require_command jq
require_command cmp
require_command grep
require_command shasum

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 1
repo_root=$(CDPATH= cd "$script_dir/.." && pwd) || exit 1
plugin_root=$repo_root/plugins/sol-advisor

git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
  fail "this script must run from a Git checkout: $repo_root"
[ -f "$plugin_root/.codex-plugin/plugin.json" ] || fail "plugin manifest is missing from this checkout."
[ -f "$plugin_root/scripts/install-agents.sh" ] || fail "agent installer is missing from this checkout."
sh -n "$plugin_root/scripts/install-agents.sh" || fail "agent installer has invalid shell syntax."

current_branch=$(git -C "$repo_root" branch --show-current)
[ -n "$current_branch" ] || fail "could not determine the current Git branch (detached HEAD is not supported for bootstrap)."
if [ -n "$expected_branch" ] && [ "$current_branch" != "$expected_branch" ]; then
  fail "expected branch '$expected_branch' but checkout is on '$current_branch'."
fi

note "Repository: $repo_root"
note "Branch: $current_branch"
note "Codex CLI: $(codex --version 2>/dev/null || printf '%s' 'version unavailable')"

if ! git -C "$repo_root" diff --quiet -- || ! git -C "$repo_root" diff --cached --quiet --; then
  printf '%s\n' "WARNING: checkout has local changes. Bootstrap will not modify repository files." >&2
fi

for required in \
  "$plugin_root/agents/sol-advisor-luna-low-implementer.toml" \
  "$plugin_root/agents/sol-advisor-luna-implementer.toml" \
  "$plugin_root/agents/sol-advisor-terra-implementer.toml" \
  "$plugin_root/agents/sol-advisor-sol-implementer.toml" \
  "$plugin_root/agents/sol-advisor-sol-reviewer.toml"
do
  [ -f "$required" ] && [ ! -L "$required" ] || fail "required native role template is missing or unsafe: $required"
done

note "Registering local checkout as a Codex marketplace"
marketplace_output=''
if marketplace_output=$(codex plugin marketplace add "$repo_root" 2>&1); then
  [ -z "$marketplace_output" ] || printf '%s\n' "$marketplace_output"
else
  printf '%s\n' "WARNING: marketplace add did not succeed; continuing only to detect an already-registered/installed copy." >&2
  [ -z "$marketplace_output" ] || printf '%s\n' "$marketplace_output" >&2
fi

note "Installing sol-advisor@sol-advisor"
plugin_add_output=''
if plugin_add_output=$(codex plugin add sol-advisor@sol-advisor 2>&1); then
  [ -z "$plugin_add_output" ] || printf '%s\n' "$plugin_add_output"
else
  printf '%s\n' "WARNING: plugin add did not succeed; checking whether the plugin is already installed." >&2
  [ -z "$plugin_add_output" ] || printf '%s\n' "$plugin_add_output" >&2
fi

plugin_json=$(codex plugin list --json) || fail "could not read installed Codex plugins as JSON."
match_count=$(printf '%s\n' "$plugin_json" | jq '[.installed[]? | select(.pluginId == "sol-advisor@sol-advisor")] | length')
[ "$match_count" -eq 1 ] || fail "expected exactly one installed sol-advisor@sol-advisor entry, found $match_count. Remove conflicting installations/marketplaces and rerun."

plugin_dir=$(printf '%s\n' "$plugin_json" | jq -r '.installed[] | select(.pluginId == "sol-advisor@sol-advisor") | .source.path')
[ -n "$plugin_dir" ] && [ "$plugin_dir" != "null" ] || fail "installed Sol Advisor entry did not expose a source path."
[ -d "$plugin_dir" ] || fail "installed plugin path does not exist: $plugin_dir"
note "Installed plugin path: $plugin_dir"

for relative in \
  .codex-plugin/plugin.json \
  agents/sol-advisor-luna-low-implementer.toml \
  agents/sol-advisor-luna-implementer.toml \
  agents/sol-advisor-terra-implementer.toml \
  agents/sol-advisor-sol-implementer.toml \
  agents/sol-advisor-sol-reviewer.toml \
  skills/orchestration/SKILL.md \
  scripts/install-agents.sh
do
  [ -f "$plugin_dir/$relative" ] || fail "installed plugin is missing expected file: $plugin_dir/$relative"
  cmp -s "$plugin_root/$relative" "$plugin_dir/$relative" ||
    fail "installed plugin does not match this checkout at $relative. Remove the stale/conflicting Sol Advisor installation and rerun."
done

jq empty "$plugin_dir/.codex-plugin/plugin.json" || fail "installed plugin manifest is invalid JSON."
sh -n "$plugin_dir/scripts/install-agents.sh" || fail "installed agent installer has invalid shell syntax."

note "Installing five native custom-agent profiles"
sh "$plugin_dir/scripts/install-agents.sh"

note "Running exact companion-profile check"
sh "$plugin_dir/scripts/install-agents.sh" --check

if [ -n "${CODEX_HOME-}" ]; then
  agents_dir=$CODEX_HOME/agents
else
  [ -n "${HOME-}" ] || fail "HOME is unset and CODEX_HOME was not supplied."
  agents_dir=$HOME/.codex/agents
fi

[ -d "$agents_dir" ] || fail "Codex agents directory does not exist after installation: $agents_dir"

check_line() {
  file=$1
  expected=$2
  grep -Fqx "$expected" "$file" || fail "expected line not found in $file: $expected"
}

luna_low=$agents_dir/sol-advisor-luna-low-implementer.toml
luna=$agents_dir/sol-advisor-luna-implementer.toml
terra=$agents_dir/sol-advisor-terra-implementer.toml
sol_impl=$agents_dir/sol-advisor-sol-implementer.toml
sol_review=$agents_dir/sol-advisor-sol-reviewer.toml

check_line "$luna_low" 'name = "sol_advisor_luna_low_implementer"'
check_line "$luna_low" 'model = "gpt-5.6-luna"'
check_line "$luna_low" 'model_reasoning_effort = "low"'

check_line "$luna" 'name = "sol_advisor_luna_implementer"'
check_line "$luna" 'model = "gpt-5.6-luna"'
check_line "$luna" 'model_reasoning_effort = "medium"'

check_line "$terra" 'name = "sol_advisor_terra_implementer"'
check_line "$terra" 'model = "gpt-5.6-terra"'
check_line "$terra" 'model_reasoning_effort = "medium"'

check_line "$sol_impl" 'name = "sol_advisor_sol_implementer"'
check_line "$sol_impl" 'model = "gpt-5.6-sol"'
check_line "$sol_impl" 'model_reasoning_effort = "high"'

check_line "$sol_review" 'name = "sol_advisor_sol_reviewer"'
check_line "$sol_review" 'model = "gpt-5.6-sol"'
check_line "$sol_review" 'model_reasoning_effort = "high"'
check_line "$sol_review" 'sandbox_mode = "read-only"'

printf '\n%s\n' 'BOOTSTRAP PASSED'
printf '%s\n' "Repository: $repo_root"
printf '%s\n' "Branch: $current_branch"
printf '%s\n' "Plugin: $plugin_dir"
printf '%s\n' "Agents: $agents_dir"
printf '%s\n' 'Validated routing pins:'
printf '%s\n' '  Luna low         -> gpt-5.6-luna / low'
printf '%s\n' '  Luna medium      -> gpt-5.6-luna / medium'
printf '%s\n' '  Terra medium     -> gpt-5.6-terra / medium'
printf '%s\n' '  Sol implementer  -> gpt-5.6-sol / high'
printf '%s\n' '  Sol reviewer     -> gpt-5.6-sol / high / requested read-only'
printf '\n%s\n' 'NEXT STEP: fully quit/restart Codex Desktop, then start a NEW task with GPT-5.6 Sol / High.'
printf '%s\n' 'Do not test the newly installed native roles in the bootstrap task; discovery happens in a fresh task.'
