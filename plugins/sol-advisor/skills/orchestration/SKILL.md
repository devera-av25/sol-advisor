---
name: orchestration
description: "Sol-led capability router: plan with GPT-5.6 Sol / High, delegate easy-medium implementation to Luna / Max, medium-hard to Terra / High, hard-complex to a separate Sol / High implementer, then require a fresh Sol / High review."
---

# Sol Advisor Orchestration

Act as the architect and router. Own the user's intent, architecture, decomposition,
complete task specification, parent verification, escalation decisions, and final
acceptance. Keep the primary session on GPT-5.6 Sol / High for planning and judgment.
Delegate implementation through the lowest capable native lane, preferring Luna so
routine and medium work does not consume Terra or Sol unnecessarily.

Read [references/role-contracts.md](references/role-contracts.md) before the first
native delegation in a session. The separate
[references/luna-task-lane.md](references/luna-task-lane.md) remains available only
when the user explicitly asks for a user-visible Codex app task instead of the native
router.

## Confirm the primary session

Run the primary Codex session on `gpt-5.6-sol` with high reasoning. Verify the current
model and effort when runtime metadata exposes them. If either differs, tell the user
to select Sol / High and stop before delegation. If runtime metadata does not expose
them, ask the user to confirm Sol / High before delegation. A skill cannot change the
primary model itself.

## Native routing policy

The normal path is the native capability router:

1. **Luna / Max — default, easy to medium.** Use for bounded, well-specified,
   predictable implementation where the architecture is settled and most work is
   execution rather than discovery.
2. **Terra / High — medium to hard escalation.** Use when implementation requires
   substantial judgment, difficult debugging, broader context, non-obvious cross-file
   interactions, higher risk, or a wider blast radius.
3. **Sol / High implementer — hard to complex escalation.** Use when sustained
   frontier-level reasoning must continue throughout implementation, especially when
   architecture and execution repeatedly inform each other.

Prefer the lowest lane that can complete the work reliably. Do not route by file count
alone. A large mechanical change may still belong to Luna; a tiny concurrency or
security bug may require Terra or Sol.

### Escalation is part of normal operation

A lower lane may discover that the task was misclassified. Treat a clear escalation
report as useful evidence, not failure.

- Luna may escalate to Terra or directly to Sol when the discovered issue clearly
  requires it.
- Terra may escalate to Sol when implementation requires sustained frontier-level
  reasoning or invalidates settled architectural assumptions.
- Never repeatedly send the same unchanged specification to a struggling worker.
  Update the specification with discovered evidence before escalation.
- Never silently fall back to another model or reasoning level. Every lane must be
  explicit and runtime-verifiable.

## Preflight native companion roles

The four native custom-agent TOML files are installed separately from the plugin.
Before every native delegation:

1. Resolve `../../scripts/install-agents.sh` relative to this SKILL.md and run:

   ~~~sh
   skill_dir=<directory-containing-this-SKILL.md>
   installer="$skill_dir/../../scripts/install-agents.sh"
   sh "$installer" --check
   ~~~

   It must exit zero.

2. Confirm the native spawn tool exposes all four exact agent types:

   - `sol_advisor_luna_implementer`
   - `sol_advisor_terra_implementer`
   - `sol_advisor_sol_implementer`
   - `sol_advisor_sol_reviewer`

3. After spawning a lane, inspect public native spawn/details metadata first. It must
   identify the selected custom role. When model or effort is exposed, require:

   - Luna implementer -> `gpt-5.6-luna` / `max`
   - Terra implementer -> `gpt-5.6-terra` / `high`
   - Sol implementer -> `gpt-5.6-sol` / `high`
   - Sol reviewer -> `gpt-5.6-sol` / `high`

   If public metadata omits model or effort and the local rollout is accessible, use
   `../../scripts/inspect-agent-runtime.sh <native-subagent-thread-id>` as the
   authoritative read-only fallback. Public and local evidence must agree when both
   exist.

4. For the final Sol reviewer, capture the observed sandbox policy type and permission
   profile type. The role requests read-only sandboxing; never claim enforced
   read-only isolation unless the host reports it.

A missing, stale, conflicting, unavailable, inconsistent, or unobservable role/model/
effort stops the affected lane. The custom-agent TOML pins model and effort; do not add
per-spawn overrides.

## Keep architect work in the primary session

Keep these responsibilities in the primary Sol / High session:

- resolve requirements and material ambiguity;
- choose architecture, interfaces, and decomposition;
- classify implementation difficulty and choose the initial lane;
- write the complete five-part implementation specification;
- inspect the actual diff and rerun verification;
- interpret escalation reports and reviewer findings;
- accept or reject the deliverable.

Do not type implementation code, tests, boilerplate, or mechanical configuration in
the primary planning session when a delegated lane can do it. Even when the hard lane
uses Sol, spawn `sol_advisor_sol_implementer` as a separate context so architect,
implementer, and reviewer remain distinct.

## Spawn the selected implementation lane

Use exactly one of these native agent types with `fork_turns: none`:

~~~text
Easy-medium:
agent_type: sol_advisor_luna_implementer
fork_turns: none

Medium-hard:
agent_type: sol_advisor_terra_implementer
fork_turns: none

Hard-complex:
agent_type: sol_advisor_sol_implementer
fork_turns: none
~~~

Use the shared implementation packet from `references/role-contracts.md`. Give each
worker one owned file set or bounded responsibility. Independent non-overlapping work
may run concurrently; shared-file edits and dependency chains stay serial.

## Classification guidance

### Prefer Luna / Max

Examples include straightforward features, CRUD, UI implementation from an existing
design, localized bug fixes with a known cause, test additions, validation, wiring
existing APIs, mechanical refactors, generated boilerplate, and medium-sized multi-file
work whose architecture is already determined.

### Escalate to Terra / High

Examples include difficult state-management bugs, unclear root causes, complicated
async flows, race-condition investigation, performance work, broad refactors with
meaningful interactions, moderately complex algorithms, unfamiliar subsystem
integration, or changes with elevated operational/security risk.

### Escalate to Sol / High implementer

Examples include deeply coupled architectural migrations, hard concurrency or
distributed-systems behavior, severe performance pathologies, security-sensitive
implementation where design decisions evolve during execution, difficult algorithms,
or debugging loops where evidence repeatedly changes the architecture or plan.

These are heuristics, not rigid categories. The controlling rule is to maximize safe
Luna delegation while escalating promptly when execution itself requires more
reasoning.

## Verify every implementation

Treat worker reports as claims. Before acceptance:

1. Inspect the working tree and complete diff.
2. Confirm only in-scope files changed.
3. Rerun the specification's verification commands in the primary session.
4. Compare evidence with the objective, interfaces, and constraints.
5. If fixes are needed, delegate them to the appropriate lane. Do not silently repair
   a child patch in the primary session.

## Require a fresh Sol / High final review

After implementation and parent verification, always spawn a fresh reviewer:

~~~text
agent_type: sol_advisor_sol_reviewer
fork_turns: none
~~~

Use the final-review packet from `references/role-contracts.md`. The reviewer remains
behaviorally read-only and returns exactly `ship`, `fix-first`, or `rethink`.

- `ship`: report completion with verification evidence.
- `fix-first`: delegate the bounded corrections, verify again, then obtain a new fresh
  review.
- `rethink`: revise architecture and do not report completion.

Any change after a review invalidates that verdict and requires a new fresh review.
The final reviewer must never implement its own fixes.

## Optional user-visible Luna app task

If the user explicitly asks for a separate user-visible Luna task, the existing app
lane in `references/luna-task-lane.md` may be used instead of the native Luna worker.
That lane uses Codex app task tools, isolated task/worktree semantics, and Luna / Max.
It is not the default router and must never be activated implicitly. After the app task
returns, the primary still inspects the actual diff and verification evidence; for this
fork, obtain the same fresh native Sol reviewer verdict before reporting completion.
