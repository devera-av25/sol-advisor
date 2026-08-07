# Sol Advisor

**Sol plans and verifies. Luna handles as much routine execution as possible at Low or
Medium reasoning. Terra takes harder work at Medium. A separate Sol worker is reserved
for genuinely hard-to-complex implementation. Fresh Sol review is risk-based rather
than mandatory for every change.**

This fork is optimized for practical Codex Desktop development where latency and token
usage matter as well as correctness.

## Routing model

| Stage | Native agent / session | Pinned profile | Typical use |
|---|---|---|---|
| Planner/router/verifier | Primary session | GPT-5.6 Sol / High | Requirements, architecture, routing, verification, acceptance |
| Trivial implementation | `sol_advisor_luna_low_implementer` | GPT-5.6 Luna / Low | Tiny deterministic low-risk edits |
| Easy-medium implementation | `sol_advisor_luna_implementer` | GPT-5.6 Luna / Medium | Normal bounded app/UI/API/test work |
| Medium-hard implementation | `sol_advisor_terra_implementer` | GPT-5.6 Terra / Medium | Harder debugging, async/state, performance, interacting refactors |
| Hard-complex implementation | `sol_advisor_sol_implementer` | GPT-5.6 Sol / High | Architecture-coupled or frontier-level execution |
| Conditional independent review | `sol_advisor_sol_reviewer` | GPT-5.6 Sol / High, requests read-only | Only when material risk or uncertainty warrants it |

The primary task should normally stay on **GPT-5.6 Sol / High**. The router optimizes
worker model **and reasoning effort**, not model family alone.

## Efficiency philosophy

Use the lowest capable lane and escalate only on evidence:

- **Luna / Low** for trivial, mechanical, low-risk work.
- **Luna / Medium** for most normal easy-to-medium implementation.
- **Terra / Medium** when execution needs substantial judgment.
- **Sol / High implementer** only when sustained high-end reasoning is necessary.

Primary Sol verification is mandatory. A fresh Sol reviewer is **not** spawned merely
because a task completed. It is required for material risk/uncertainty such as security,
auth/payments, data migration/loss risk, concurrency/background/native lifecycle risk,
major architecture/public API/data-model changes, incomplete verification, Sol-level
implementation, or explicit user request.

For fully verified low-risk work the router records:

~~~text
REVIEW GATE: skipped-low-risk
~~~

This avoids paying for a second Sol context on routine edits.

## Recommended first-run setup in Codex Desktop

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
Desktop and start a new task using GPT-5.6 Sol with High reasoning. Do not test newly
installed native agents from this setup task.
~~~

The bootstrap checks dependencies, registers the local marketplace, installs the plugin,
confirms the installed copy matches the checkout, installs/migrates companion profiles,
validates exact role/model/effort pins, and prints the restart boundary.

## Upgrade an existing 0.5 routing installation

If you already bootstrapped the earlier branch version that used Luna / Max and Terra /
High, update the checkout and rerun the bootstrap:

~~~sh
cd /path/to/your/sol-advisor
git pull --ff-only
sh scripts/bootstrap-codex.sh --expected-branch agent/luna-terra-sol-routing
~~~

The installer recognizes the exact prior Sol Advisor Luna/Max and Terra/High templates
and migrates only those known versions. It still refuses unknown or locally modified
agent files.

After `BOOTSTRAP PASSED`, fully quit/restart Codex Desktop and start a new task so the
five current agent types are discovered.

## What gets installed

~~~text
sol-advisor-luna-low-implementer.toml
sol-advisor-luna-implementer.toml
sol-advisor-terra-implementer.toml
sol-advisor-sol-implementer.toml
sol-advisor-sol-reviewer.toml
~~~

Expected runtime pins:

~~~text
sol_advisor_luna_low_implementer -> gpt-5.6-luna / low
sol_advisor_luna_implementer     -> gpt-5.6-luna / medium
sol_advisor_terra_implementer    -> gpt-5.6-terra / medium
sol_advisor_sol_implementer      -> gpt-5.6-sol / high
sol_advisor_sol_reviewer         -> gpt-5.6-sol / high / requested read-only
~~~

## Normal use

After setup, open the actual project you want to work on, start a new primary Codex task
with **GPT-5.6 Sol / High**, and invoke the skill:

~~~text
Use $sol-advisor:orchestration to implement this feature. Route through the lowest
capable model/effort lane, verify the actual diff, and use independent Sol review only
when the risk gate requires it.
~~~

The skill cannot silently change the primary model. Worker model and effort are pinned
by their native custom-agent profiles.

## Example routing

A tiny copy/config/utility change should normally become:

~~~text
Sol / High -> Luna / Low -> primary verification -> done
~~~

A normal mobile screen or bounded feature should normally become:

~~~text
Sol / High -> Luna / Medium -> primary verification -> done
~~~

A difficult async/state bug may become:

~~~text
Sol / High -> Terra / Medium -> primary verification -> review only if risk warrants
~~~

A difficult architecture-coupled migration may become:

~~~text
Sol / High architect -> separate Sol / High implementer -> primary verification
                    -> fresh Sol / High reviewer
~~~

Lower lanes may return evidence-backed escalation requests. The primary updates the task
packet with discoveries before escalating rather than repeating an unchanged attempt.

## Runtime verification

Native spawn/details metadata is the primary routing evidence. If Desktop omits model or
effort and a native thread ID is available, use the existing read-only inspector:

~~~sh
plugin_dir="$(codex plugin list --json | jq -r '.installed[] | select(.pluginId == "sol-advisor@sol-advisor") | .source.path')"
sh "$plugin_dir/scripts/inspect-agent-runtime.sh" <native-subagent-thread-id>
~~~

There is no silent role/model/effort fallback.

The reviewer requests a read-only sandbox, but hosts may expose broader permissions. The
router reports observed isolation rather than claiming requested isolation was enforced;
when broader permissions are observed, repository state must be checked before and
after review.

## Optional user-visible Luna task lane

The separate app-task workflow remains available in
`plugins/sol-advisor/skills/orchestration/references/luna-task-lane.md` only when the
user explicitly requests a visible Codex app task/worktree. Its default Luna effort is
Medium and the same risk-based final-review gate applies.

## Local development without the bootstrap

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
