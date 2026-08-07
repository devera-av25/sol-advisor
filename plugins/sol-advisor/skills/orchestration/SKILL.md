---
name: orchestration
description: "Token-efficient Sol-led router: use GPT-5.6 Sol / Medium as the normal controller, Luna / Low or Medium for routine execution, Terra / Medium for harder work, on-demand Sol / High planning or implementation only when justified, targeted parent verification, and independent Sol review only when risk warrants it."
---

# Sol Advisor Orchestration

Act as controller, router, verifier, and acceptor. Optimize for the **lowest model tier,
reasoning effort, and context footprint that can reliably complete the task**.

The normal primary session is GPT-5.6 Sol / Medium. Do not pay for Sol / High merely to
classify or verify routine work. When consequential planning genuinely requires more
reasoning, spawn the separate read-only `sol_advisor_sol_planner` at Sol / High and then
return execution control to the Sol / Medium primary.

Read [references/role-contracts.md](references/role-contracts.md) before the first native
delegation in a fresh primary task. The separate
[references/luna-task-lane.md](references/luna-task-lane.md) is optional and only for an
explicitly requested visible Codex app task.

## Primary session

Preferred primary:

~~~text
model: gpt-5.6-sol
reasoning: medium
~~~

Sol / High primary is supported when the user deliberately selects it, but it is not the
efficiency default. If runtime metadata exposes another primary model/effort, report the
observed configuration and do not pretend the skill changed it.

The primary should do only the reasoning needed to route, verify, and accept. Avoid
broad discovery, long planning narratives, repeated summaries, or full-project scans
when a bounded task does not need them.

## Planning gate: use Sol / High only when it earns the cost

Most trivial and normal bounded tasks **do not need a separate planning agent**. The
Sol / Medium primary should create a concise implementation packet and delegate.

Spawn `sol_advisor_sol_planner` only when a material planning trigger applies, such as:

- a significant architecture or subsystem boundary decision;
- public API, durable data model, persistence/schema, or migration design;
- security/auth/privacy/payments or another consequential trust-boundary design;
- concurrency/distributed/background/native-lifecycle correctness whose design is not
  already settled;
- a broad refactor with multiple viable architectures or high blast radius;
- difficult performance work requiring architectural tradeoffs;
- requirements are materially ambiguous and the choice affects implementation shape;
- the primary has material uncertainty about interfaces, decomposition, or risk.

Spawn:

~~~text
agent_type: sol_advisor_sol_planner
fork_turns: none
~~~

Send only the context needed for the planning decision. Require a compact return:
`DECISION`, `INTERFACES`, `OWNERSHIP`, `RISKS`, `VERIFICATION`, and
`RECOMMENDED EXECUTION LANE`. Do not ask the planner to implement code.

## Implementation routing

Use the lowest capable lane:

1. **Luna / Low — trivial fast path.** Deterministic, low-risk, explicitly bounded work:
   copy/config changes, tiny utilities, simple styling, mechanical renames, obvious
   tests, and localized known-cause fixes.
2. **Luna / Medium — normal easy-to-medium.** Bounded features with settled architecture:
   mobile UI/screens from a clear design, forms, validation, CRUD, API wiring, hooks,
   tests, and predictable multi-file implementation.
3. **Terra / Medium — medium-to-hard.** Execution requires substantial judgment:
   unclear root cause, complicated async/state behavior, performance work, interacting
   refactors, moderately complex algorithms, or unfamiliar subsystem integration.
4. **Sol / High implementer — hard-to-complex.** Sustained frontier-level reasoning is
   required throughout execution: difficult migrations, hard concurrency/distributed
   correctness, security-critical implementation, severe performance pathologies,
   difficult algorithms, or deeply coupled legacy systems.

Do not route by file count. A large mechanical edit may still be Luna / Low; a tiny
security/concurrency bug may require higher capability.

## Escalation

Stop early rather than letting a lower lane burn tokens while thrashing.

- Luna / Low -> Luna / Medium, Terra, or Sol.
- Luna / Medium -> Terra or Sol.
- Terra / Medium -> Sol.
- Sol implementer -> primary when implementation evidence changes architecture.

Update the task packet with discovered evidence before escalation. Never resend the same
unchanged prompt to a struggling worker and never silently substitute role/model/effort.

## Native preflight

Run preflight **once before the first native spawn in a fresh primary task** and reuse it
within that task unless installation/configuration/runtime evidence changes.

1. Run `../../scripts/install-agents.sh --check` relative to this SKILL.md.
2. Confirm native exposure of all six roles:
   - `sol_advisor_luna_low_implementer`
   - `sol_advisor_luna_implementer`
   - `sol_advisor_terra_implementer`
   - `sol_advisor_sol_planner`
   - `sol_advisor_sol_implementer`
   - `sol_advisor_sol_reviewer`
3. When public metadata exposes pins, require:
   - Luna low -> `gpt-5.6-luna` / `low`
   - Luna medium -> `gpt-5.6-luna` / `medium`
   - Terra medium -> `gpt-5.6-terra` / `medium`
   - Sol planner -> `gpt-5.6-sol` / `high`
   - Sol implementer -> `gpt-5.6-sol` / `high`
   - Sol reviewer -> `gpt-5.6-sol` / `high`
4. If metadata omits model/effort and a native thread ID is available, use
   `../../scripts/inspect-agent-runtime.sh <thread-id>` as the read-only fallback.

The planner and reviewer request read-only sandboxing. Report observed isolation rather
than claiming requested isolation was enforced.

## Token-efficient delegation

Before spawning a worker, capture a **small baseline** rather than ingesting the entire
working tree:

- `git status --short` to identify pre-existing changes;
- the intended owned paths/files;
- only the relevant interfaces or snippets the worker actually needs.

Do not paste the complete repository diff or broad conversation history into a routine
worker. Prefer exact paths and concise acceptance criteria.

### Luna / Low packet

Use the compact contract from `references/role-contracts.md`. For the fast path:

- do not perform broad codebase discovery;
- do not ask the worker to run the final test suite merely so the parent can rerun it;
- worker self-checks should be minimal and only when useful to implementation;
- primary owns the single final targeted verification run.

### Other implementation lanes

Use the full contract only when the task needs it. Keep reports concise and avoid
returning full diffs because the primary can inspect the actual files directly.

## Primary verification

Verification remains mandatory, but it must be proportionate.

For low-risk/trivial work:

1. Compare `git status --short` with the captured baseline.
2. Inspect only the worker-owned file delta/hunks, not unrelated pre-existing diffs.
3. Run the narrowest meaningful targeted test/check **once in the primary**.
4. Run broader checks such as full typecheck/lint/test suites only when the changed
   surface, repository policy, or evidence makes them relevant.
5. Confirm acceptance criteria and preserve unrelated changes.

For normal/harder work, widen verification as risk and blast radius increase.

Do not duplicate expensive verification simply as ritual. If a worker needed a test
while debugging, the parent still performs the final acceptance check, but avoid
replaying large redundant logs into the conversation.

## Risk-based fresh Sol review

A fresh `sol_advisor_sol_reviewer` is **not required for every task**.

Require it when any material trigger applies:

- Sol / High implementation was required;
- auth/authz/security/privacy/cryptography/payments or another sensitive trust boundary
  changed;
- destructive persistence/schema migration or meaningful data-loss risk exists;
- concurrency/race correctness, background execution, native iOS/Android lifecycle,
  permissions, signing/release, or similarly high-impact platform behavior changed;
- architecture, public API, durable data model, or broad/high-blast-radius refactor
  changed materially;
- verification is incomplete, flaky, ambiguous, or leaves material residual risk;
- implementation invalidated important planning assumptions;
- the user explicitly requests independent review;
- the primary remains materially uncertain after verification.

If none applies and verification passes, record:

~~~text
REVIEW GATE: skipped-low-risk
~~~

When review is required, spawn `sol_advisor_sol_reviewer` with `fork_turns: none`. Any
post-review change invalidates the verdict.

## Completion output

Normal completion reports should be compact to avoid spending tokens narrating the
orchestration itself. Unless the user asks for diagnostics/testing details, report only:

~~~text
ROUTE: <primary> -> <implementation lane> [-> reviewer if used]
VERIFY: <concise checks/results>
REVIEW: skipped-low-risk | <reviewer verdict>
ESCALATION: none | <path>
~~~

Use the full routing report only when debugging or benchmarking the router.

## Optional visible Luna app task

If the user explicitly asks for a separate visible Luna task/worktree, follow
`references/luna-task-lane.md`. The Sol / Medium primary remains controller/verifier;
use the same planning gate and risk-based review gate.
