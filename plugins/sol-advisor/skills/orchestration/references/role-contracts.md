# Native Codex role contracts

Use these contracts with Sol Advisor's namespaced, role-pinned native agents. The
primary session plans and routes; implementation runs in a separate Luna, Terra, or Sol
context; independent Sol review is conditional on the risk gate.

The separate [Luna task-lane contract](luna-task-lane.md) covers explicitly requested
user-visible Codex app tasks. It is optional and does not replace the native router.

## Required preflight

Before the first native delegation in a fresh primary task:

1. Require the non-mutating companion check to prove all five installed files exactly
   match current templates.
2. Require native exposure of:
   - `sol_advisor_luna_low_implementer`
   - `sol_advisor_luna_implementer`
   - `sol_advisor_terra_implementer`
   - `sol_advisor_sol_implementer`
   - `sol_advisor_sol_reviewer`
3. Observe the selected role/model/effort through public metadata first, using the local
   runtime inspector only for omitted fields. Accept only:
   - Luna / Low for `sol_advisor_luna_low_implementer`
   - Luna / Medium for `sol_advisor_luna_implementer`
   - Terra / Medium for `sol_advisor_terra_implementer`
   - Sol / High for `sol_advisor_sol_implementer`
   - Sol / High for `sol_advisor_sol_reviewer`
4. For reviewer spawns, capture actual sandbox and permission-profile types.

A successful preflight may be reused within the same primary task unless installation,
configuration, or runtime evidence changes. Never silently fall back. Model and effort
are pinned by custom-agent TOML, so omit native per-spawn overrides.

## Compact implementation contract

Use this for the Luna / Low fast path when the task is deterministic and low risk.

~~~text
ROLE
Execute this trivial, bounded task directly. Do not perform broad discovery or redesign.
Escalate early if the task is not actually mechanical/low risk.

OBJECTIVE
<Exact observable outcome.>

OWNERSHIP
You may modify only:
- <exact path(s)>
Preserve unrelated/concurrent edits.

ACCEPTANCE
- <concrete behavior/result>
- <compatibility constraint if any>

VERIFY
- Run: <targeted command>
  Success: <expected evidence>

RETURN
STATUS: complete | blocked | escalate
CHANGES: <actual diff summary>
VERIFIED: <exact command + evidence>
ESCALATION: none | luna-medium: <reason> | terra: <reason> | sol: <reason>
~~~

## Full implementation contract

Use this for Luna / Medium, Terra / Medium, Sol / High, or any task whose contract needs
more detail.

~~~text
OBJECTIVE
<Observable outcome and why it matters.>

FILES AND OWNERSHIP
You own only:
- <exact file or module>

You are not alone in the codebase. Preserve concurrent edits, do not revert unrelated
work, and do not modify files outside your ownership.

INTERFACES
- <Signatures, types, schemas, commands, or behavior that must remain compatible.>

CONSTRAINTS
- <Repository conventions, safety boundaries, excluded scope, and settled decisions.>

VERIFICATION
- Run: <exact command>
  Success: <concrete expected result>
- Inspect: <exact file, diff, or generated artifact>
  Success: <concrete expected evidence>

RETURN
Return exact commands and actual evidence. A completion claim without evidence is
invalid. If the lane is materially underpowered, return an escalation report instead
of repeatedly attempting the same failed approach.

IMPLEMENTATION REPORT
STATUS: complete | partial | blocked | escalate
OBJECTIVE: <one-line restatement>
CHANGES: <file-by-file summary from the actual diff>
VERIFIED: <exact commands plus concrete output evidence>
JUDGMENT CALLS: <decisions the specification left open, or none>
GAPS: <unfinished work, ambiguity, or none>
ESCALATION: <none | luna-medium: reason | terra: reason | sol: reason | primary: reason>
~~~

The primary session must inspect the diff and rerun appropriate verification itself.

## Luna / Low - trivial fast path

Spawn exactly:

~~~text
agent_type: sol_advisor_luna_low_implementer
fork_turns: none
~~~

Use only when the desired change is deterministic, explicitly bounded, low risk, and
requires little or no discovery. Examples: copy/config edits, tiny utilities,
straightforward styling, mechanical renames, obvious test additions, and known-cause
localized fixes.

Use the Compact implementation contract. If meaningful reasoning appears, escalate
instead of stretching this lane.

## Luna / Medium - default easy-medium lane

Spawn exactly:

~~~text
agent_type: sol_advisor_luna_implementer
fork_turns: none
~~~

Use for bounded implementation that needs normal reasoning but has settled architecture:
ordinary mobile UI/screens, forms, hooks, validation, CRUD, API integration, tests, and
medium-sized predictable multi-file changes.

Prompt role header:

~~~text
ROLE
Act as Sol Advisor's default easy-to-medium implementation worker. Execute the supplied
specification proportionally within the settled architecture. If implementation reveals
substantial ambiguity, difficult debugging, cross-system coupling, elevated risk, or a
materially wider blast radius, stop early and return an evidence-backed escalation.

<paste and complete the Full implementation contract>
~~~

## Terra / Medium - medium-hard lane

Spawn exactly:

~~~text
agent_type: sol_advisor_terra_implementer
fork_turns: none
~~~

Use when execution requires substantial judgment: unclear root cause, complicated
async/state behavior, performance analysis, broad interacting refactors, moderately
complex algorithms, or unfamiliar subsystem integration. Terra should still avoid
unnecessary exploration and should escalate to Sol when sustained frontier reasoning is
required.

Prompt role header:

~~~text
ROLE
Act as Sol Advisor's medium-to-hard implementation worker. Resolve difficult
implementation details within the supplied architecture. If evidence shows architecture
and implementation can no longer be separated or sustained frontier-level reasoning is
needed, return an evidence-backed Sol escalation.

<paste and complete the Full implementation contract>
~~~

## Sol / High - hard-complex implementation lane

Spawn exactly:

~~~text
agent_type: sol_advisor_sol_implementer
fork_turns: none
~~~

Use only where architecture/debugging/code changes must continually inform each other:
difficult migrations, security-sensitive implementation, hard concurrency/distributed
correctness, severe performance issues, difficult algorithms, or deeply coupled legacy
systems.

This must be a separate context from the primary Sol architect and, when required, the
fresh reviewer.

Prompt role header:

~~~text
ROLE
Act as Sol Advisor's hard-to-complex implementation worker. Use sustained frontier-level
reasoning while executing the supplied specification. Challenge assumptions only when
implementation evidence requires it and report conflicts explicitly. Do not broaden
scope silently.

<paste and complete the Full implementation contract>
~~~

## Review gate

Primary verification is mandatory. Fresh Sol review is conditional.

Set `REVIEW GATE: required` if any material trigger applies:

- Sol implementation was required;
- auth/authz/security/privacy/cryptography/payments or another sensitive trust boundary
  changed;
- destructive persistence/schema/data migration or meaningful data-loss risk exists;
- concurrency/race correctness, background execution, native iOS/Android lifecycle,
  permissions, signing/release, or similarly high-impact platform behavior changed;
- architecture, public API, durable data model, or broad/high-blast-radius refactor
  changed materially;
- verification is incomplete, flaky, ambiguous, or leaves material residual risk;
- implementation invalidated important planning assumptions;
- the user explicitly requests independent review;
- the primary remains materially uncertain after verification.

If none applies and verification fully passes, use:

~~~text
REVIEW GATE: skipped-low-risk
REVIEW REASON: <short evidence-based reason>
~~~

Do not spawn the reviewer merely to satisfy ritual process.

## Fresh Sol / High reviewer

When the review gate is required, spawn a new native thread exactly:

~~~text
agent_type: sol_advisor_sol_reviewer
fork_turns: none
~~~

The role pins GPT-5.6 Sol / High and requests read-only sandboxing. Observe actual role,
pin, sandbox policy, and permission profile before accepting its verdict.

Prompt:

~~~text
ROLE
Act as the fresh final reviewer. Remain strictly read-only: do not edit files, implement
fixes, or broaden scope.

STATED GOAL
<The user's requested outcome.>

ACCUMULATED CHANGE SET
<Exact allowed files plus complete working-tree diff, or explicit base/head revisions.>

INTERFACES AND CONSTRAINTS
- <Compatibility, repository rules, safety boundaries, and excluded scope.>

VERIFICATION EVIDENCE
- <command> -> <actual primary-session evidence>

REVIEW
Judge correctness, completeness, regressions, scope discipline, interface preservation,
test adequacy, and material risk.

SOL REVIEW
VERDICT: ship | fix-first | rethink
REASON: <decisive evidence-based reason>
FINDINGS: <precise file references and required fixes, or none>
RESIDUAL RISK: <most important remaining risk, or none>
~~~

Any fix after review invalidates the verdict and requires a fresh review if the review
gate still applies. The reviewer never implements its own fixes.

Use observed isolation, not requested isolation:

- With observed `read-only`, proceed with enforced isolation.
- If the host broadens permissions, proceed only when hard isolation is not required,
  the prompt forbids edits, and the primary records exact before/after repository state
  and verifies no mutation. Report the broader policy.
- If isolation is unobservable, hard isolation is required, or mutation occurs, stop the
  reviewer lane and do not hide the problem.

## Optional user-visible Luna app task

When explicitly requested, follow [luna-task-lane.md](luna-task-lane.md). After the task
returns, the primary verifies the actual diff and applies this same review gate.

## Commitment-boundary Sol consult

For pre-implementation review of a consequential architecture, migration, public API,
or wide refactor, the reviewer role may be used as a fresh read-only consult. Give it
the proposed decision, goal, constraints, alternatives, and the one question that can
change the plan. Require `proceed`, `change`, or `stop`, plus the decisive reason and
largest risk. This is separate from the post-implementation review gate.
