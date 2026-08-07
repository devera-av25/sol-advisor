# Native Codex role contracts

The normal primary is GPT-5.6 Terra / Medium. Planning and verification scale upward
independently and only when evidence justifies the extra reasoning/model cost.

## Required preflight

Before the first native spawn in a fresh primary task:

1. Require `install-agents.sh --check` to prove all eight installed profiles match.
2. Require native exposure of:
   - `sol_advisor_luna_low_implementer`
   - `sol_advisor_luna_implementer`
   - `sol_advisor_terra_implementer`
   - `sol_advisor_terra_high_consultant`
   - `sol_advisor_sol_low_consultant`
   - `sol_advisor_sol_medium_consultant`
   - `sol_advisor_sol_implementer`
   - `sol_advisor_sol_reviewer`
3. Accept only these pins when runtime metadata exposes them:
   - Luna / Low
   - Luna / Medium
   - Terra implementer / Medium
   - Terra consultant / High
   - Sol consultant / Low
   - Sol consultant / Medium
   - Sol implementer / High
   - Sol reviewer / High
4. Use the local runtime inspector only for omitted metadata fields.

Reuse a successful preflight within the same primary task unless runtime/configuration
evidence changes. Never silently fall back.

## Read-only consultant contract

The three consultant profiles can perform either planning or verification. The prompt
must set `MODE` explicitly.

~~~text
MODE: planning | verification

OBJECTIVE
<One concise outcome.>

RELEVANT CONTEXT
- <only paths/interfaces/constraints needed>

QUESTION OR EVIDENCE
<planning decision to resolve, or verification evidence/change set to judge>

RETURN
DECISION/VERDICT: <concise result>
REASON: <decisive evidence>
RISKS/FINDINGS: <material items or none>
NEXT TIER: none | terra-high | sol-low | sol-medium | sol-high-review
~~~

For planning, `sol-high-review` is invalid: Sol / Medium is the maximum normal planning
tier. Consultants never edit files or implement fixes.

## Planning ladder

Start in the Terra / Medium primary.

### Terra / High consultant

~~~text
agent_type: sol_advisor_terra_high_consultant
fork_turns: none
MODE: planning
~~~

Use when the same Terra model is capable but the planning decision needs more reasoning.
If a stronger model is genuinely required, recommend Sol / Low.

### Sol / Low consultant

~~~text
agent_type: sol_advisor_sol_low_consultant
fork_turns: none
MODE: planning
~~~

Use only after the decision is judged capability-bound rather than merely effort-bound.
Start the stronger Sol model at Low. Escalate to Sol / Medium only with evidence.

### Sol / Medium consultant

~~~text
agent_type: sol_advisor_sol_medium_consultant
fork_turns: none
MODE: planning
~~~

This is the maximum normal planning tier. If material ambiguity remains, return a
blocker to the primary rather than escalating planning to Sol / High.

## Compact Luna / Low implementation contract

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
The primary will run: <targeted command>
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

Use when more context is genuinely needed.

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
- Primary final acceptance check: <targeted command>

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

Use for deterministic low-risk copy/config edits, tiny utilities, simple styling,
mechanical renames, obvious tests, and known-cause localized fixes.

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

Use for medium-to-hard work with unclear root cause, complicated async/state behavior,
performance analysis, interacting refactors, moderately complex algorithms, or
unfamiliar subsystem work.

### Sol / High implementer

~~~text
agent_type: sol_advisor_sol_implementer
fork_turns: none
~~~

Reserve for genuinely hard-to-complex execution requiring sustained frontier reasoning.

## Verification ladder

The Terra / Medium primary is the default verifier. It captures a small pre-delegation
baseline, inspects only worker-owned changed hunks, and runs the narrowest meaningful
final test/check once. Broader full-project checks run only when policy, blast radius,
or evidence requires them.

### Terra / High verification

~~~text
agent_type: sol_advisor_terra_high_consultant
fork_turns: none
MODE: verification
~~~

Use for subtle logic, wider refactors, harder edge cases, performance-sensitive changes,
or other verification that needs more reasoning but not a stronger model.

### Sol / Low verification

~~~text
agent_type: sol_advisor_sol_low_consultant
fork_turns: none
MODE: verification
~~~

Use when Terra is insufficient to judge a bounded consequential change reliably. This is
the first stronger-model verification tier.

### Sol / Medium verification

~~~text
agent_type: sol_advisor_sol_medium_consultant
fork_turns: none
MODE: verification
~~~

Use for higher-impact architecture/API/data-model changes, difficult concurrency/native
lifecycle behavior, security-sensitive changes, Sol-implemented work, or unresolved
material uncertainty after Sol / Low.

### Sol / High final review

~~~text
agent_type: sol_advisor_sol_reviewer
fork_turns: none
~~~

Use only for exceptional residual uncertainty or very high-impact risk: severe
security/data-loss/signing/release concerns, incomplete/conflicting evidence, extremely
complex implementation, or explicit strongest-review request.

Send only the goal, relevant owned-file change set or base/head reference, material
constraints, and concise verification evidence. The reviewer never edits files.

## Isolation

Consultants and reviewer request read-only sandboxing. Observe actual host policy. If the
host broadens permissions, verify repository state did not change before accepting a
verdict. Do not claim requested isolation was enforced when it was not.

## Optional visible Luna app task

When explicitly requested, follow [luna-task-lane.md](luna-task-lane.md). The Terra /
Medium primary uses the same graduated planning and verification ladders.
