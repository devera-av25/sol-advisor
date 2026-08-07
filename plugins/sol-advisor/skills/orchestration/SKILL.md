---
name: orchestration
description: "Efficiency-first Sol-led router: plan with GPT-5.6 Sol / High, prefer Luna / Low or Medium, use Terra / Medium for harder work, reserve Sol / High for genuinely hard-complex implementation, verify every diff, and use fresh Sol review only when risk or uncertainty warrants it."
---

# Sol Advisor Orchestration

Act as architect and capability router. Own the user's intent, architecture,
decomposition, lane selection, parent verification, escalation decisions, review-gate
decision, and final acceptance. Keep the primary session on GPT-5.6 Sol / High unless
the user explicitly chooses another primary configuration.

Optimize both **model tier and reasoning effort**. Prefer the cheapest and lowest-effort
lane that can reliably complete the work. Do not spend Max/High reasoning merely because
it is available.

Read [references/role-contracts.md](references/role-contracts.md) before the first native
delegation in a primary task. The separate
[references/luna-task-lane.md](references/luna-task-lane.md) is optional and only for an
explicitly requested user-visible Codex app task.

## Confirm the primary session

The supported default primary is `gpt-5.6-sol` with high reasoning. Verify the model and
effort when runtime metadata exposes them. If the primary differs, do not pretend the
skill changed it. Tell the user what was observed and either continue only when their
request explicitly accepts it or stop for correction.

The primary should reason proportionally. Small settled tasks need a concise routing
decision and compact specification, not broad architecture discovery.

## Native routing policy

Use the lowest capable lane:

1. **Luna / Low — trivial fast path.** Use for deterministic, low-risk work with explicit
   scope and acceptance criteria: tiny utilities, copy/config changes, straightforward
   styling, mechanical renames, obvious tests, and localized known-cause fixes.
2. **Luna / Medium — default easy-to-medium lane.** Use for normal bounded feature work
   whose architecture is settled: UI components/screens from a clear design, forms,
   validation, CRUD, API wiring, hooks, tests, and medium-sized predictable multi-file
   implementation.
3. **Terra / Medium — medium-to-hard lane.** Use when implementation itself requires
   substantial judgment: unclear root cause, complicated async/state behavior,
   performance work, wider interacting refactors, moderately complex algorithms, or
   unfamiliar subsystem integration.
4. **Sol / High implementer — hard-to-complex lane.** Reserve for sustained frontier-level
   reasoning where architecture and implementation repeatedly inform each other:
   difficult migrations, security-critical implementation, hard concurrency/distributed
   correctness, severe performance pathologies, difficult algorithms, or deeply coupled
   legacy systems.

Do not route by file count alone. A large mechanical edit may still be Luna / Low. A
small security or concurrency bug may require Sol / High.

## Escalation is normal

A lower lane should stop early when it is underpowered instead of consuming more tokens
thrashing.

- Luna / Low may recommend Luna / Medium, Terra, or Sol.
- Luna / Medium may recommend Terra or Sol.
- Terra / Medium may recommend Sol.
- Sol implementer may return an architectural issue to the primary.

Update the specification with discovered evidence before escalation. Never resend the
same unchanged task to a struggling worker. Never silently substitute a different role,
model, or effort.

## Preflight native companion roles

Run native preflight **once before the first native delegation in a fresh primary task**.
A successful result may be reused for later spawns in that task unless installation,
configuration, or runtime evidence changes.

1. Resolve `../../scripts/install-agents.sh` relative to this SKILL.md and run:

   ~~~sh
   skill_dir=<directory-containing-this-SKILL.md>
   installer="$skill_dir/../../scripts/install-agents.sh"
   sh "$installer" --check
   ~~~

2. Confirm the native spawn tool exposes all five exact agent types:

   - `sol_advisor_luna_low_implementer`
   - `sol_advisor_luna_implementer`
   - `sol_advisor_terra_implementer`
   - `sol_advisor_sol_implementer`
   - `sol_advisor_sol_reviewer`

3. After spawning a role, inspect public spawn/details metadata. When model or effort is
   exposed, require:

   - Luna low -> `gpt-5.6-luna` / `low`
   - Luna medium -> `gpt-5.6-luna` / `medium`
   - Terra medium -> `gpt-5.6-terra` / `medium`
   - Sol implementer -> `gpt-5.6-sol` / `high`
   - Sol reviewer -> `gpt-5.6-sol` / `high`

   If model/effort is omitted and local rollout metadata is accessible, use
   `../../scripts/inspect-agent-runtime.sh <native-subagent-thread-id>` as the read-only
   fallback. Public and local evidence must agree when both exist.

4. For a reviewer spawn, record the observed sandbox/permission policy. The role requests
   read-only. Never claim enforced read-only isolation unless the host reports it. If the
   host broadens permissions, use before/after repository-state verification as described
   in `references/role-contracts.md`.

A missing, stale, conflicting, unavailable, inconsistent, or unobservable role/model/
effort stops the affected lane. Agent TOML pins model and effort; do not add per-spawn
overrides.

## Keep architect work in the primary session

The primary owns requirements, architecture, decomposition, routing, verification,
escalation interpretation, review-gate decisions, and acceptance. Do not write delegated
implementation code in the primary merely to avoid spawning the appropriate worker.

Use **proportionate specification depth**:

- Luna / Low gets a compact packet: objective, exact owned files, acceptance criteria,
  and targeted verification.
- Luna / Medium, Terra, and Sol get the full implementation contract from
  `references/role-contracts.md` when the task needs it.

Avoid broad codebase discovery for an explicitly standalone or already-understood tiny
change.

## Spawn the selected implementation lane

Use `fork_turns: none`:

~~~text
Trivial / low risk:
agent_type: sol_advisor_luna_low_implementer

Easy-medium:
agent_type: sol_advisor_luna_implementer

Medium-hard:
agent_type: sol_advisor_terra_implementer

Hard-complex:
agent_type: sol_advisor_sol_implementer
~~~

Give each worker one owned file set or bounded responsibility. Independent non-overlap
may run concurrently; shared-file edits and dependency chains remain serial.

## Verify every implementation

Primary verification is mandatory even when a fresh reviewer is skipped:

1. Inspect the working tree and complete diff.
2. Confirm only in-scope files changed.
3. Run the task's targeted verification/tests.
4. Compare the actual result with objective, interfaces, and constraints.
5. Delegate any required fixes; do not silently repair child code in the primary.

For tiny tasks, keep verification targeted rather than running expensive unrelated test
suites unless repository policy requires them.

## Risk-based fresh Sol review

A fresh `sol_advisor_sol_reviewer` is **not required for every task**. After primary
verification, apply a review gate.

### Require fresh Sol / High review when any material trigger applies

- a Sol implementer was required;
- authentication, authorization, security, privacy, cryptography, payments, or other
  sensitive trust-boundary behavior changed;
- data migration, destructive persistence/schema change, or meaningful data-loss risk
  exists;
- concurrency/race correctness, background execution, or native iOS/Android lifecycle,
  permissions, signing/release, or similarly high-impact platform behavior changed;
- architecture, public API, durable data model, or a broad/high-blast-radius refactor
  changed materially;
- verification is incomplete, flaky, ambiguous, or leaves material residual risk;
- implementation evidence invalidated important planning assumptions;
- the user explicitly requests independent review;
- the primary has material uncertainty after verification.

### Skip fresh review for verified low-risk work

If none of the triggers apply and primary verification fully passes, finish without a
fresh reviewer. Record `REVIEW GATE: skipped-low-risk` and a short reason.

Typical skip candidates include copy/styling changes, utilities, ordinary components,
forms, validation, tests, CRUD/API wiring, mechanical refactors, and known localized
bugs with strong targeted verification.

### When review is required

Spawn:

~~~text
agent_type: sol_advisor_sol_reviewer
fork_turns: none
~~~

The reviewer returns `ship`, `fix-first`, or `rethink`. Any post-review change invalidates
the verdict. The reviewer never implements its own fixes.

## Completion report

Report enough routing evidence to make efficiency visible:

~~~text
ROUTING REPORT
PRIMARY: <model / effort>
IMPLEMENTATION: <agent type / model / effort>
ROUTING REASON: <why this was the lowest capable lane>
VERIFICATION: <targeted commands/evidence>
REVIEW GATE: skipped-low-risk | required
REVIEW REASON: <why>
REVIEWER: <agent/model/effort/verdict, or not spawned>
ESCALATIONS: <none or path + evidence>
~~~

## Optional user-visible Luna app task

If the user explicitly asks for a separate user-visible Luna task, follow
`references/luna-task-lane.md`. It remains a distinct mechanism. The primary still
verifies the actual diff and applies the same risk-based final-review gate before
acceptance.
