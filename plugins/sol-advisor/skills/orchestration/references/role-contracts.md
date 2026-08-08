# Native Codex role contracts

The normal primary is GPT-5.6 Terra / Medium. Planning and verification scale upward
independently and only when evidence justifies the extra reasoning/model cost. Normal
verification stops at Terra / High; Sol verification is break-glass only.

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
UNRESOLVED MATERIAL UNCERTAINTY: none | <specific uncertainty>
CONSEQUENCE IF WRONG: none | <specific meaningful consequence>
NEXT TIER: none | terra-high | sol-low | sol-medium | sol-high-review
~~~

For planning, `sol-high-review` is invalid: Sol / Medium is the maximum normal planning
tier. Consultants never edit files or implement fixes.

For verification, `sol-low`, `sol-medium`, or `sol-high-review` is invalid unless the
strict break-glass gate in the Verification section is satisfied. A generic statement
that Sol would provide a better review is not sufficient.

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

## Verification policy

The Terra / Medium primary is the default verifier. It captures a small pre-delegation
baseline, inspects only worker-owned changed hunks, and runs the narrowest meaningful
final test/check once. Broader full-project checks run only when policy, blast radius,
or evidence requires them.

Normal verification has two tiers:

~~~text
Terra / Medium primary
        ↓ only if stronger same-model reasoning is needed
Terra / High consultant
        ↓
NORMAL STOP
~~~

### Terra / High verification — normal ceiling

~~~text
agent_type: sol_advisor_terra_high_consultant
fork_turns: none
MODE: verification
~~~

Use for subtle logic, wider refactors, harder edge cases, performance-sensitive changes,
or other verification that needs more reasoning. If Terra / High can reach a confident
verdict, stop. It is the normal verification ceiling.

### Strict Sol break-glass gate

Sol verification is not the next routine tier after Terra / High. Except when the user
explicitly requests Sol/strongest review or an obviously critical case makes a Terra /
High intermediate pass clearly wasteful, all three conditions are mandatory before any
Sol verifier may be spawned:

1. Terra / High verification has already been attempted.
2. Terra / High identifies **specific material unresolved correctness uncertainty**.
3. That uncertainty has meaningful high-consequence impact, such as:
   - severe security/auth/authorization failure;
   - destructive or irreversible data loss;
   - high-impact migration/schema risk;
   - payment or financial correctness;
   - signing/release-critical correctness;
   - public API/protocol compatibility with substantial downstream impact;
   - similarly high-impact correctness risk.

The following do not satisfy the gate by themselves:

- normal feature work;
- UI/mobile changes;
- ordinary bugs/refactors/utilities/tests;
- medium complexity;
- multiple changed files;
- Terra implementation;
- Sol implementation;
- architecture/data-model involvement without unresolved high-consequence uncertainty;
- a preference for a "better" or more independent review.

**Implementation tier never determines verification tier.** In particular, Sol / High
implementation may still finish with Terra / High verification when Terra can confidently
judge the resulting change and evidence.

A verification consultant recommending Sol must return both:

~~~text
UNRESOLVED MATERIAL UNCERTAINTY: <specific unresolved issue>
CONSEQUENCE IF WRONG: <specific high-consequence impact>
~~~

If either is `none`, vague, or unsupported by evidence, the primary MUST NOT spawn Sol
verification.

### Sol / Low break-glass verification

~~~text
agent_type: sol_advisor_sol_low_consultant
fork_turns: none
MODE: verification
~~~

This is the first break-glass Sol tier, not a normal escalation step. Use only after the
strict gate is satisfied, for a bounded high-consequence uncertainty where stronger
model capability may resolve the issue without deep Sol reasoning.

### Sol / Medium break-glass verification

~~~text
agent_type: sol_advisor_sol_medium_consultant
fork_turns: none
MODE: verification
~~~

Use only if Sol / Low still leaves material high-consequence uncertainty, or the gated
issue clearly requires deeper Sol reasoning. Do not choose it merely because Sol /
High implemented the change.

### Sol / High break-glass final review

~~~text
agent_type: sol_advisor_sol_reviewer
fork_turns: none
~~~

Use only when lower break-glass tiers remain insufficient for exceptional residual
uncertainty or very high-impact risk, or when the user explicitly requests strongest
review. Typical examples are unresolved severe security/data-loss/signing/release risk
or incomplete/conflicting critical evidence.

Send only the goal, relevant owned-file change set or base/head reference, material
constraints, the unresolved uncertainty, its consequence, and concise verification
evidence. The reviewer never edits files.

## Isolation

Consultants and reviewer request read-only sandboxing. Observe actual host policy. If the
host broadens permissions, verify repository state did not change before accepting a
verdict. Do not claim requested isolation was enforced when it was not.

## Optional visible Luna app task

When explicitly requested, follow [luna-task-lane.md](luna-task-lane.md). The Terra /
Medium primary uses the same planning ladder and the same Terra-normal/Sol-break-glass
verification policy.
