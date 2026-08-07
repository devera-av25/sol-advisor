# Sol Advisor

**Sol plans. Luna handles as much easy-to-medium execution as possible. Terra takes
medium-to-hard work. A separate Sol worker handles hard-to-complex implementation. A
fresh Sol reviewer stands between the diff and done.**

This fork changes Sol Advisor from a Terra-default workflow into a capability router
that deliberately pushes routine and medium implementation downward while preserving
strict role/model verification and final review.

## Routing model

| Stage | Native agent / session | Pinned profile | Purpose |
|---|---|---|---|
| Planner / router | Primary session | GPT-5.6 Sol / High | Requirements, architecture, decomposition, lane selection, verification, acceptance |
| Easy-medium implementation | `sol_advisor_luna_implementer` | GPT-5.6 Luna / Max | Default worker for bounded, well-specified execution |
| Medium-hard implementation | `sol_advisor_terra_implementer` | GPT-5.6 Terra / High | Escalation for harder debugging, broader context, interactions, or risk |
| Hard-complex implementation | `sol_advisor_sol_implementer` | GPT-5.6 Sol / High | Separate implementation context for sustained frontier-level reasoning |
| Final review | `sol_advisor_sol_reviewer` | GPT-5.6 Sol / High, requests read-only | Fresh independent-context review of the verified diff |

The primary session should stay on **GPT-5.6 Sol / High**. Even when implementation
escalates to Sol, it runs in a separate native agent context so planner, implementer,
and final reviewer remain distinct.

## Routing philosophy

The router prefers the lowest capable lane rather than reserving Luna only for trivial
work:

- **Luna / Max first** for easy-to-medium work whose architecture and acceptance
  criteria are already clear.
- **Terra / High** when execution requires substantial judgment, difficult debugging,
  broader context, non-obvious interactions, or elevated risk.
- **Sol / High implementer** when architecture and implementation must repeatedly
  inform each other or the task requires sustained frontier-level reasoning.

Lower lanes may return an evidence-backed escalation request. The primary updates the
specification with what was discovered and escalates rather than repeating the same
unchanged attempt.

## Requirements

- A current Codex environment with plugins, native subagents, and custom agents enabled.
- Access to GPT-5.6 Sol / High, GPT-5.6 Terra / High, and GPT-5.6 Luna / Max.
- `jq` for the companion-install lookup shown below.

The native router is the preferred setup for portability across Codex surfaces that
support plugins/custom agents. The existing user-visible Luna app-task workflow remains
available when explicitly requested, but it is no longer the only way to use Luna.

## Install this fork from GitHub

Add this repository as a marketplace and install the plugin:

~~~sh
codex plugin marketplace add devera-av25/sol-advisor --ref main
codex plugin add sol-advisor@sol-advisor
~~~

For development of the routing branch before merge, point the marketplace at a local
checkout or the desired branch/ref instead of `main`.

## Install the four native companion agents

Plugin installation does not automatically write user-owned custom-agent files. Install
the shipped templates separately:

~~~sh
plugin_dir="$(codex plugin list --json | jq -r '.installed[] | select(.pluginId == "sol-advisor@sol-advisor") | .source.path')"
test -n "$plugin_dir"
test -d "$plugin_dir"
sh "$plugin_dir/scripts/install-agents.sh"
sh "$plugin_dir/scripts/install-agents.sh" --check
~~~

The installer manages these exact files:

~~~text
sol-advisor-luna-implementer.toml
sol-advisor-terra-implementer.toml
sol-advisor-sol-implementer.toml
sol-advisor-sol-reviewer.toml
~~~

It refuses to overwrite unrecognized or modified files. It recognizes the exact older
Sol Advisor Luna and Terra templates that this fork supersedes and may migrate only
those byte-identifiable versions.

Start a **new Codex task** after installing or updating native agent profiles so the
host discovers the current types.

## Use

Select **GPT-5.6 Sol / High** for the primary task and ask for implementation work
normally, or invoke the orchestration skill explicitly:

~~~text
Use $sol-advisor:orchestration to build this feature. Plan with Sol / High, prefer Luna
for bounded implementation, escalate to Terra or Sol only when needed, verify the
actual diff, and obtain the fresh Sol review before reporting done.
~~~

The skill cannot switch the primary model itself. If the primary is not Sol / High, it
must stop before delegation rather than pretend the prerequisite is satisfied.

## Native runtime verification

Before native delegation the skill requires the installer check to pass and all four
agent types to be available. Spawn/details metadata is the primary routing evidence.
When the host exposes model and effort, they must match the role pins:

~~~text
sol_advisor_luna_implementer  -> gpt-5.6-luna / max
sol_advisor_terra_implementer -> gpt-5.6-terra / high
sol_advisor_sol_implementer   -> gpt-5.6-sol / high
sol_advisor_sol_reviewer      -> gpt-5.6-sol / high
~~~

If Desktop omits model or effort and local rollout metadata is accessible, the existing
read-only runtime inspector can be used:

~~~sh
plugin_dir="$(codex plugin list --json | jq -r '.installed[] | select(.pluginId == "sol-advisor@sol-advisor") | .source.path')"
sh "$plugin_dir/scripts/inspect-agent-runtime.sh" <native-subagent-thread-id>
~~~

There is no silent model, effort, or role fallback.

## Verification and final review

Every implementation worker receives a complete specification covering objective,
file ownership, interfaces, constraints, and verification. Worker completion reports
are treated as claims: the primary inspects the actual diff, confirms scope, and reruns
verification.

After parent verification, the primary always spawns a fresh
`sol_advisor_sol_reviewer`. The reviewer returns exactly:

- `ship` — completion may be reported;
- `fix-first` — delegate corrections, verify again, then obtain another fresh review;
- `rethink` — revise architecture before continuing.

Any post-review change invalidates the previous verdict.

## Optional user-visible Luna task lane

The original user-visible Luna app-task workflow remains in
`plugins/sol-advisor/skills/orchestration/references/luna-task-lane.md`. Use it only
when the user explicitly requests a separate Codex app task. The native Luna worker is
the normal easy-to-medium lane for this fork.

## Local development

Install a checkout as a local marketplace:

~~~sh
cd /absolute/path/to/sol-advisor
codex plugin marketplace add /absolute/path/to/sol-advisor
codex plugin add sol-advisor@sol-advisor
~~~

Then install/check the companion roles and start a fresh Codex task.

## Attribution

This repository is a fork of DannyMac180/sol-advisor and retains the original project's
license and authorship metadata while changing its routing policy for this fork.

## License

See [LICENSE](LICENSE).
