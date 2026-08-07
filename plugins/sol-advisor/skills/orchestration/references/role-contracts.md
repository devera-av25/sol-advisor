# Native Codex role contracts

Use these contracts with Sol Advisor's namespaced native agents. The normal primary is
GPT-5.6 Sol / Medium. High reasoning is invoked only at a material planning,
implementation, or review boundary.

## Required preflight

Before the first native spawn in a fresh primary task:

1. Require `install-agents.sh --check` to prove all six installed profiles match.
2. Require native exposure of:
   - `sol_advisor_luna_low_implementer`
   - `sol_advisor_luna_implementer`
   - `sol_advisor_terra_implementer`
   - `sol_advisor_sol_planner`
   - `sol_advisor_sol_implementer`
   - `sol_advisor_sol_reviewer`
3. Accept only these observed pins when metadata exposes them:
   - Luna / Low for `sol_advisor_luna_low_implementer`
   - Luna / Medium for `sol_advisor_luna_implementer`
   - Terra / Medium for `sol_advisor_terra_implementer`
   - Sol / High for `sol_advisor_sol_planner`
   - Sol / High for `sol_advisor_sol_implementer`
   - Sol / High for `sol_advisor_sol_reviewer`
4. Use the local runtime inspector only for metadata fields the host omits.

Reuse a successful preflight within the same primary task unless runtime/configuration
evidence changes. Never silently fall back.

## Sol / High planning consult

Spawn only when the Sol / Medium primary hits a material planning boundary:

~~~text
agent_type: sol_advisor_sol_planner
fork_turns: none
~~~

The planner is read-only by behavior and requests read-only sandboxing. Send only the
context needed to resolve the decision.

~~~text
ROLE
Resolve this planning boundary without implementing code or broadening scope.

OBJECTIVE
<What outcome must be achieved?>

RELEVANT CONTEXT
- <only files/interfaces/constraints needed for the decision>

QUESTION
<The architecture/interface/decomposition decision that materially changes execution.>

RETURN
DECISION: <concise chosen approach>
INTERFACES: <contracts to preserve/create>
OWNERSHIP: <implementation boundaries>
RISKS: <material risks only>
VERIFICATION: <acceptance checks>
RECOMMENDED EXECUTION LANE: luna-low | luna-medium | terra-medium | sol-high
BLOCKERS: none | <unresolved blocker>
~~~

Do not ask the planner to restate the whole codebase or produce implementation code.

## Compact Luna / Low contract

Use for deterministic low-risk work. The worker should implement; the primary performs
the single final acceptance test run.

~~~text
ROLE
Execute this trivial bounded change directly. No broad discovery or redesign. Escalate
early if it is not actually mechanical/low risk.

OBJECTIVE
<Exact outcome.>

OWNERSHIP
Only modify:
- <exact paths>
Preserve unrelated changes.

ACCEPTANCE
- <observable behavior>
- <compatibility constraint if any>

PARENT VERIFICATION
The parent will run: <targeted command>
Do not rerun the final suite merely for reporting. Use only minimal self-checks needed
while implementing.

RETURN
STATUS: complete | blocked | escalate
CHANGES: <very short changed-file summary>
SELF-CHECK: none | <minimal check actually needed>
ESCALATION: none | luna-medium: <reason> | terra: <reason> | sol: <reason>
~~~

Do not return the full diff; the primary inspects it directly.

## Full implementation contract

Use only when the task actually needs more context than the compact packet.

~~~text
OBJECTIVE
<Observable outcome.>

FILES AND OWNERSHIP
You own only:
- <exact paths/modules>
Preserve concurrent/unrelated changes.

INTERFACES
- <contracts that must remain compatible>

CONSTRAINTS
- <relevant repository/safety/scope constraints>

VERIFICATION
- <checks useful during implementation>
- Parent final acceptance check: <targeted final command>

RETURN
STATUS: complete | partial | blocked | escalate
CHANGES: <concise file summary, no full diff>
VERIFIED: <only checks actually run + short evidence>
JUDGMENT CALLS: <material decisions or none>
GAPS: <none or blocker>
ESCALATION: <none | luna-medium: reason | terra: reason | sol: reason | primary: reason>
~~~

## Implementation lanes

### Luna / Low

~~~text
agent_type: sol_advisor_luna_low_implementer
fork_turns: none
~~~

Use for copy/config edits, tiny utilities, simple styling, mechanical renames, obvious
tests, and known-cause localized fixes. Use the compact contract.

### Luna / Medium

~~~text
agent_type: sol_advisor_luna_implementer
fork_turns: none
~~~

Use for ordinary bounded mobile UI/screens, forms, hooks, validation, CRUD, API wiring,
tests, and predictable multi-file work with settled architecture.

### Terra / Medium

~~~text
agent_type: sol_advisor_terra_implementer
fork_turns: none
~~~

Use for unclear root cause, complicated async/state behavior, performance analysis,
interacting refactors, moderately complex algorithms, or unfamiliar subsystem work.

### Sol / High implementer

~~~text
agent_type: sol_advisor_sol_implementer
fork_turns: none
~~~

Reserve for sustained high-end reasoning during implementation: difficult migrations,
security-critical implementation, hard concurrency/distributed correctness, severe
performance issues, difficult algorithms, or deeply coupled legacy systems.

## Token-efficient primary verification

Primary verification is mandatory but proportionate.

For trivial/low-risk work:

1. Capture `git status --short` before delegation.
2. After delegation, compare status and inspect only the worker-owned path delta/hunks.
3. Run the narrowest meaningful final test/check once in the primary.
4. Run broader typecheck/lint/full tests only when the changed surface, repository policy,
or evidence makes them relevant.
5. Do not ingest unrelated pre-existing diffs merely to prove they remain untouched.

For higher-risk work, widen verification with blast radius.

## Review gate

Fresh Sol review is conditional. Set `REVIEW GATE: required` when any material trigger
applies:

- Sol / High implementation was required;
- auth/authz/security/privacy/cryptography/payments or another trust boundary changed;
- destructive persistence/schema/data migration or meaningful data-loss risk exists;
- concurrency/race correctness, background execution, native iOS/Android lifecycle,
  permissions, signing/release, or similarly high-impact platform behavior changed;
- architecture, public API, durable data model, or broad/high-blast-radius refactor
  changed materially;
- verification is incomplete/flaky/ambiguous or leaves material residual risk;
- implementation invalidated important planning assumptions;
- the user explicitly requests independent review;
- the primary remains materially uncertain.

Otherwise:

~~~text
REVIEW GATE: skipped-low-risk
~~~

## Fresh Sol / High reviewer

When required:

~~~text
agent_type: sol_advisor_sol_reviewer
fork_turns: none
~~~

Send only the goal, owned-file change set or base/head revisions, material constraints,
and concise primary verification evidence. Do not send unrelated repository history.

~~~text
ROLE
Read-only final review. Do not edit files.

GOAL
<requested outcome>

CHANGE SET
<owned files and relevant diff/base-head reference>

CONSTRAINTS
- <material compatibility/safety constraints>

VERIFICATION
- <concise primary evidence>

RETURN
VERDICT: ship | fix-first | rethink
REASON: <decisive short reason>
FINDINGS: <precise issues or none>
RESIDUAL RISK: <material residual risk or none>
~~~

Observe actual sandbox policy rather than assuming requested read-only isolation. If the
host broadens permissions, verify repository state did not change before accepting the
verdict. Any post-review fix invalidates the verdict when the review gate still applies.

## Optional visible Luna app task

When explicitly requested, follow [luna-task-lane.md](luna-task-lane.md). The Sol /
Medium primary uses the same high-planning gate, targeted verification, and risk-based
review gate.
