# Native Codex role contracts

Use these contracts with Sol Advisor's namespaced, role-pinned native custom agents.
The primary session plans and routes; implementation runs in a separate Luna, Terra,
or Sol context; final review runs in a fresh Sol context. Adapt every placeholder
without removing a required field.

The separate [Luna task-lane contract](luna-task-lane.md) covers explicitly requested
user-visible Codex app tasks. It is optional and does not replace the native router.

## Required preflight

Before every native spawn:

1. Require the non-mutating companion check to prove all four installed files exactly
   match current templates.
2. Require native exposure of exactly:
   - `sol_advisor_luna_implementer`
   - `sol_advisor_terra_implementer`
   - `sol_advisor_sol_implementer`
   - `sol_advisor_sol_reviewer`
3. Observe the selected role, model, and effort through public spawn/details metadata
   first, using the local runtime inspector only for omitted fields. Accept only:
   - Luna / Max for `sol_advisor_luna_implementer`
   - Terra / High for `sol_advisor_terra_implementer`
   - Sol / High for `sol_advisor_sol_implementer`
   - Sol / High for `sol_advisor_sol_reviewer`
4. For the reviewer, capture actual sandbox policy and permission profile types.

A missing, stale, unsafe, conflicting, unavailable, inconsistent, or unobservable
role/model/effort stops the lane. Never silently fall back. Model and effort are pinned
by custom-agent TOML, so omit native per-spawn overrides.

## Shared implementation contract

Every implementation prompt must contain all five sections:

~~~text
OBJECTIVE
<Observable outcome and why it matters.>

FILES AND OWNERSHIP
You own only:
- <exact file or module>

You are not alone in the codebase. Other agents or the user may be editing concurrently.
Preserve their edits, do not revert unrelated work, and adapt to changes already present.
Do not modify files outside your ownership.

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
Return exact commands and actual evidence. A completion claim without evidence is invalid.
If the lane is materially underpowered for the discovered problem, return an escalation
report instead of repeatedly attempting the same failed approach.

IMPLEMENTATION REPORT
STATUS: complete | partial | blocked | escalate
OBJECTIVE: <one-line restatement>
CHANGES: <file-by-file summary from the actual diff>
VERIFIED: <exact commands plus concrete output evidence>
JUDGMENT CALLS: <decisions the specification left open, or none>
GAPS: <unfinished work, ambiguity, or none>
ESCALATION: <none | Terra: reason | Sol: reason>
~~~

The primary session must inspect the diff and rerun verification itself.

## Luna / Max - default easy-medium lane

Spawn exactly:

~~~text
agent_type: sol_advisor_luna_implementer
fork_turns: none
~~~

Use Luna when the implementation is bounded and mostly determined by the specification.
This is the preferred lane for straightforward features, UI work from an existing
design, CRUD, localized known-cause fixes, tests, validation, API wiring, mechanical
refactors, boilerplate, and medium-sized work with settled architecture.

Prompt role header:

~~~text
ROLE
Act as Sol Advisor's default easy-to-medium implementation worker. Execute the supplied
specification within the settled architecture. If implementation reveals substantial
ambiguity, difficult debugging, cross-system coupling, elevated risk, or a materially
wider blast radius, stop thrashing and return an evidence-backed escalation request.

<paste and complete the Shared implementation contract>
~~~

## Terra / High - medium-hard escalation lane

Spawn exactly:

~~~text
agent_type: sol_advisor_terra_implementer
fork_turns: none
~~~

Use Terra when execution itself requires substantial judgment, difficult debugging,
broader context, non-obvious interactions, moderately complex algorithms, performance
work, or elevated operational/security risk, but does not yet require sustained Sol-
level reasoning throughout implementation.

Prompt role header:

~~~text
ROLE
Act as Sol Advisor's medium-to-hard implementation worker. Resolve difficult
implementation details within the settled architecture. If evidence shows the task
requires sustained frontier-level reasoning or invalidates core architectural
assumptions, return an evidence-backed Sol escalation request.

<paste and complete the Shared implementation contract>
~~~

## Sol / High - hard-complex implementation lane

Spawn exactly:

~~~text
agent_type: sol_advisor_sol_implementer
fork_turns: none
~~~

Use this lane for implementation where architecture, debugging, and code changes must
continually inform each other: difficult migrations, hard concurrency/distributed
behavior, severe performance issues, security-sensitive implementation with evolving
design decisions, difficult algorithms, or deeply coupled legacy systems.

This must be a separate context from both the primary Sol architect and final reviewer.

Prompt role header:

~~~text
ROLE
Act as Sol Advisor's hard-to-complex implementation worker. Use sustained frontier-level
reasoning while executing the supplied specification. Challenge settled assumptions
only when implementation evidence requires it, and report those conflicts explicitly.
Do not broaden scope silently.

<paste and complete the Shared implementation contract>
~~~

## Fresh Sol / High - requested-read-only final reviewer

After parent verification, spawn a new native thread exactly:

~~~text
agent_type: sol_advisor_sol_reviewer
fork_turns: none
~~~

The installed role pins GPT-5.6 Sol at high reasoning and requests a read-only sandbox.
Observe the actual role, pin, sandbox policy, and permission profile before accepting
its verdict.

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
- <command> -> <actual primary-session output evidence>
- <artifact or diff inspection> -> <actual evidence>

REVIEW
Inspect the actual files and accumulated change set. Judge correctness, completeness,
regressions, scope discipline, interface preservation, test adequacy, and material risk.

SOL REVIEW
VERDICT: ship | fix-first | rethink
REASON: <decisive evidence-based reason>
FINDINGS: <precise file references and required fixes, or none>
RESIDUAL RISK: <most important remaining risk, or none>
~~~

If any fix is made after review, discard the verdict and run a new fresh review.
Sol reviewing Sol is context-clean, not cross-model-family independence.

Use observed isolation, not requested isolation:

- With observed `read-only`, proceed with enforced isolation.
- If the host broadens it, proceed only when hard isolation is not required, the
  prompt forbids edits, and the parent captures and verifies exact before-and-after
  repository and artifact state. Report the broader policy and profile.
- If isolation is unobservable, hard isolation is required, or any mutation occurs,
  stop the lane and do not hide or repair the mutation under that verdict.

## Optional user-visible Luna app task

When the user explicitly asks for a separate user-visible Luna task, follow
[luna-task-lane.md](luna-task-lane.md). Use the app-task packet and Luna / Max routing
defined there. After the task returns, the primary still inspects its actual diff,
reruns verification, and then obtains the same fresh native Sol reviewer verdict before
reporting completion.

## Commitment-boundary Sol consult

For pre-implementation review of a consequential architecture, migration, public API,
or wide refactor, spawn the fresh Sol reviewer with `fork_turns: none`. Give it the
proposed decision, goal, constraints, relevant paths, alternatives, and the one question
that changes the plan. Require `proceed`, `change`, or `stop`, plus the decisive reason
and largest risk. Apply the same preflight, runtime-observation, sandbox-reporting, and
no-fallback rules.
