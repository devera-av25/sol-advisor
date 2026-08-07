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

## Recommended first-run setup in Codex Desktop

The preferred setup is intentionally short: give Codex this repository and branch and
let it run the checked-in bootstrap script.

Repository:

~~~text
https://github.com/devera-av25/sol-advisor
~~~

Development branch before PR #1 is merged:

~~~text
agent/luna-terra-sol-routing
~~~

A suitable one-time Codex instruction is:

~~~text
Set up my Sol Advisor fork for Codex Desktop.

Repository: https://github.com/devera-av25/sol-advisor
Branch: agent/luna-terra-sol-routing

Clone or update a local checkout, switch to exactly that branch, then run:

sh scripts/bootstrap-codex.sh --expected-branch agent/luna-terra-sol-routing

Do not modify or merge the repository. Do not manually overwrite conflicting custom
agent files. If the bootstrap reports a missing prerequisite or conflict, stop and show
me the exact error. If it reports BOOTSTRAP PASSED, tell me to fully restart Codex
Desktop and start a new task using GPT-5.6 Sol with High reasoning. Do not test the
newly installed native agents from this setup task.
~~~

The bootstrap script performs the deterministic setup work:

1. Checks that `git`, `codex`, and `jq` are available.
2. Confirms the checkout and optional expected branch.
3. Registers the local checkout as a Codex marketplace.
4. Installs `sol-advisor@sol-advisor`.
5. Confirms the installed plugin matches this checkout rather than a stale/upstream copy.
6. Runs the shipped conflict-safe native-agent installer.
7. Runs the installer's byte-exact `--check` validation.
8. Verifies all four role names and their exact model/reasoning pins.
9. Prints `BOOTSTRAP PASSED` and the required restart/new-task boundary.

It intentionally does **not** change the parent task's model and does **not** spawn the
newly installed roles in the bootstrap task. Native agent discovery must be validated
from a fresh task after restart.

## Manual setup fallback

If you prefer to run the setup yourself, clone the development branch:

~~~sh
mkdir -p ~/Developer
cd ~/Developer
git clone --branch agent/luna-terra-sol-routing --single-branch \
  https://github.com/devera-av25/sol-advisor.git \
  sol-advisor-router-test
cd sol-advisor-router-test
~~~

Then run the same canonical bootstrap:

~~~sh
sh scripts/bootstrap-codex.sh --expected-branch agent/luna-terra-sol-routing
~~~

If a prerequisite is missing, install it using the normal package manager for your
machine and rerun. The bootstrap deliberately does not silently install package
managers or overwrite unknown custom-agent files.

## What gets installed

The native companion installer manages exactly these role profiles:

~~~text
sol-advisor-luna-implementer.toml
sol-advisor-terra-implementer.toml
sol-advisor-sol-implementer.toml
sol-advisor-sol-reviewer.toml
~~~

Expected runtime pins:

~~~text
sol_advisor_luna_implementer  -> gpt-5.6-luna / max
sol_advisor_terra_implementer -> gpt-5.6-terra / high
sol_advisor_sol_implementer   -> gpt-5.6-sol / high
sol_advisor_sol_reviewer      -> gpt-5.6-sol / high / requested read-only
~~~

The installer refuses to overwrite unrecognized or modified files. It may migrate only
exact older Sol Advisor templates that the script can identify safely.

## After bootstrap

When the bootstrap prints `BOOTSTRAP PASSED`:

1. Fully quit/restart Codex Desktop.
2. Start a **new** Codex task for the project you actually want to work on.
3. Select **GPT-5.6 Sol** with **High** reasoning for the primary task.
4. Invoke the orchestration skill normally.

For example:

~~~text
Use $sol-advisor:orchestration to implement this feature. Plan with Sol / High, prefer
Luna for bounded implementation, escalate to Terra or Sol only when needed, verify the
actual diff, and obtain the fresh Sol review before reporting done.
~~~

The skill cannot switch the primary model itself. If the primary is not Sol / High, it
must stop before delegation rather than claim the prerequisite is satisfied.

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

## Runtime verification

Before native delegation, the skill requires the installer check to pass and all four
agent types to be available. Native spawn/details metadata is the primary routing
evidence. When the host exposes model and effort, they must match the role pins above.

If Desktop omits model or effort and local rollout metadata is accessible, use the
read-only runtime inspector:

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

## Local development without the bootstrap

The underlying manual commands remain available for debugging:

~~~sh
cd /absolute/path/to/sol-advisor
codex plugin marketplace add /absolute/path/to/sol-advisor
codex plugin add sol-advisor@sol-advisor
plugin_dir="$(codex plugin list --json | jq -r '.installed[] | select(.pluginId == "sol-advisor@sol-advisor") | .source.path')"
sh "$plugin_dir/scripts/install-agents.sh"
sh "$plugin_dir/scripts/install-agents.sh" --check
~~~

Start a new Codex task after any successful native-agent install or update.

## Attribution

This repository is a fork of DannyMac180/sol-advisor and retains the original project's
license and authorship metadata while changing its routing policy for this fork.

## License

See [LICENSE](LICENSE).
