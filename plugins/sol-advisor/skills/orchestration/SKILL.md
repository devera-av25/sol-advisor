---
name: orchestration
description: "Token-efficient capability router: Terra / Medium is the normal planner-controller-verifier, planning escalates Terra High -> Sol Low -> Sol Medium only when needed, implementation prefers Luna Low/Medium then Terra Medium, and verification normally stops at Terra High with Sol reserved for break-glass cases."
---

# Sol Advisor Orchestration

Optimize for the **lowest model tier, reasoning effort, and context footprint that can
reliably complete the task**. The normal primary Codex task is GPT-5.6 Terra / Medium.
Use stronger planning or verification only when evidence justifies it.

Read [references/role-contracts.md](references/role-contracts.md) before the first native
spawn in a fresh primary task. The separate
[references/luna-task-lane.md](references/luna-task-lane.md) is optional and only for an
explicitly requested visible Codex app task.

## Primary controller

Preferred primary:

~~~text
model: gpt-5.6-terra
reasoning: medium
~~~

The primary owns routing, routine planning, final targeted verification, escalation
interpretation, and acceptance. If the user intentionally starts another model/effort,
report what is observed and do not pretend the skill changed it.

Keep routine reasoning concise. Do not perform broad repository discovery, long planning
narratives, repeated summaries, or full-project scans for a bounded task.

## Planning ladder

Planning should start with the Terra / Medium primary. Upsize reasoning/model only when
the current tier cannot confidently settle a material planning decision.

~~~text
Terra / Medium primary
        ↓ if more reasoning is needed on the same model
Terra / High consultant
        ↓ only if a stronger model is actually needed
Sol / Low consultant
        ↓ only if low effort is insufficient
Sol / Medium consultant
        ↓
STOP: Sol / Medium is the maximum normal planning tier
~~~

Use `MODE: planning` when spawning a consultant.

### Planning escalation triggers

Escalate beyond Terra / Medium only for material decisions such as consequential
architecture/interface choices, persistence/schema/migration design, security/auth/privacy
boundaries, concurrency/background/native-lifecycle design, broad high-blast-radius
refactors, difficult performance tradeoffs, or material ambiguity that changes execution.

Prefer **Terra / High before changing model family**. Upgrade to Sol only when the issue
is capability-bound rather than merely needing more reasoning effort. When upgrading to
Sol, start at Low and normally stop at Medium. Do not use Sol / High for planning.

## Implementation routing

Implementation remains cheap-first and separate from planning:

1. **Luna / Low** — trivial/mechanical, deterministic, low-risk work.
2. **Luna / Medium** — normal bounded easy-to-medium app/UI/API/test work.
3. **Terra / Medium** — medium-to-hard implementation needing substantial judgment.
4. **Sol / High implementer** — genuinely hard-to-complex execution requiring sustained
   frontier-level reasoning throughout implementation.

Do not route by file count. A large mechanical change may still be Luna / Low; a small
security/concurrency bug may require a stronger lane.

### Escalation

- Luna / Low -> Luna / Medium, Terra, or Sol.
- Luna / Medium -> Terra or Sol.
- Terra / Medium -> Sol only when execution itself requires stronger-model reasoning.
- Sol implementer -> primary when implementation evidence changes architecture.

Stop lower lanes early when underpowered rather than letting them burn tokens thrashing.
Update the packet with discovered evidence before escalation and never silently
substitute role/model/effort.

## Native preflight

Run preflight once before the first native spawn in a fresh primary task and reuse the
result unless installation/configuration/runtime evidence changes.

1. Run `../../scripts/install-agents.sh --check` relative to this SKILL.md.
2. Confirm native exposure of all eight roles:
   - `sol_advisor_luna_low_implementer`
   - `sol_advisor_luna_implementer`
   - `sol_advisor_terra_implementer`
   - `sol_advisor_terra_high_consultant`
   - `sol_advisor_sol_low_consultant`
   - `sol_advisor_sol_medium_consultant`
   - `sol_advisor_sol_implementer`
   - `sol_advisor_sol_reviewer`
3. When runtime metadata exposes pins, require:
   - Luna low -> `gpt-5.6-luna` / `low`
   - Luna medium -> `gpt-5.6-luna` / `medium`
   - Terra implementer -> `gpt-5.6-terra` / `medium`
   - Terra high consultant -> `gpt-5.6-terra` / `high`
   - Sol low consultant -> `gpt-5.6-sol` / `low`
   - Sol medium consultant -> `gpt-5.6-sol` / `medium`
   - Sol implementer -> `gpt-5.6-sol` / `high`
   - Sol reviewer -> `gpt-5.6-sol` / `high`
4. If model/effort metadata is omitted and a thread ID exists, use
   `../../scripts/inspect-agent-runtime.sh <thread-id>` as the read-only fallback.

Consultants/reviewer request read-only sandboxing. Report observed isolation rather than
claiming requested isolation was enforced.

## Token-efficient delegation

Capture only a small baseline before delegation:

- `git status --short` for pre-existing changes;
- exact worker-owned paths;
- only interfaces/snippets actually needed.

Do not paste complete repository diffs or broad conversation history into routine
workers. Use the compact Luna / Low packet for trivial work. The Luna / Low worker does
not need to rerun the parent's final test suite just to report it; the primary owns the
single final acceptance run.

## Verification policy

Verification scales independently from the implementation model, but **normal
verification stops at Terra / High**.

~~~text
Terra / Medium primary verification
        ↓ only when stronger same-model reasoning is warranted
Terra / High consultant
        ↓
NORMAL STOP

Sol verification is a separate BREAK-GLASS path, not the next routine tier.
~~~

Use `MODE: verification` for consultant spawns.

### Terra / Medium verification — default

Use for trivial and ordinary low-risk changes with clear acceptance criteria and strong
targeted checks. For these tasks:

1. compare `git status --short` with the captured baseline;
2. inspect only worker-owned changed hunks/paths;
3. run the narrowest meaningful targeted test/check once in the primary;
4. run full typecheck/lint/test suites only when repository policy, changed surface, or
   evidence makes them relevant;
5. confirm acceptance criteria and preserve unrelated work.

### Terra / High verification — normal ceiling

Use when verification is reasoning-heavy or the blast radius is wider: subtle state
logic, broader refactors, difficult edge cases, performance-sensitive behavior,
moderately complex integration, or important changes where Terra / Medium leaves
material uncertainty.

Terra / High is the **normal verification ceiling**. If it can reach a confident verdict,
stop. Do not use Sol merely because a stronger model might produce a better review.

### Sol verification — strict break-glass gate

Sol verification MUST NOT be spawned as a routine continuation after Terra / High.
Except for an explicit user request for Sol/strongest review or an obviously critical
case where Terra / High would add no useful intermediate evidence, all of the following
must be true first:

1. Terra / High verification has already been attempted.
2. Terra / High reports **material unresolved correctness uncertainty** rather than a
   generic preference for stronger review.
3. The unresolved uncertainty has meaningful consequences such as severe security/auth
   failure, destructive or irreversible data loss, high-impact migration/schema risk,
   payment/financial correctness, signing/release-critical behavior, public
   API/protocol compatibility, or similarly high-impact correctness risk.

These are NOT sufficient reasons by themselves:

- normal feature work;
- UI or React Native changes;
- ordinary bug fixes/refactors/utilities/tests;
- medium-complexity work;
- touching multiple files;
- implementation by Terra;
- implementation by Sol;
- "Sol would review this better."

Using Sol for implementation does **not** imply Sol verification. A valid route is Sol /
High implementation followed by Terra / High verification when Terra can confidently
judge the resulting evidence.

If the strict gate is satisfied, use the lowest sufficient Sol tier:

~~~text
BREAK GLASS
Sol / Low consultant
        ↓ only if still materially unresolved
Sol / Medium consultant
        ↓ only for exceptional residual risk/uncertainty
Sol / High reviewer
~~~

#### Sol / Low break-glass verification

Use only after the gate above is satisfied, for a bounded high-consequence uncertainty
where stronger model capability may resolve the issue without deep Sol reasoning.

#### Sol / Medium break-glass verification

Use only when Sol / Low still leaves material high-consequence uncertainty, or when the
break-glass issue clearly requires deeper Sol reasoning. Do not select it merely because
the implementation used Sol or touched architecture/data-model code.

#### Sol / High break-glass review — exceptional

Use the existing `sol_advisor_sol_reviewer` only when the strongest independent review
is justified after lower break-glass tiers remain insufficient, or when the user
explicitly requests strongest review. Typical cases are severe unresolved
security/data-loss/signing/release risk or incomplete/conflicting critical evidence.

Do not spawn an independent verifier merely as ritual. Low-risk work can complete after
Terra / Medium verification; harder ordinary work should normally complete by Terra /
High.

## Consultant contract

For planning or verification, send only the decision/change context needed and specify:

~~~text
MODE: planning | verification
OBJECTIVE: <one sentence>
RELEVANT PATHS/INTERFACES: <small bounded set>
EVIDENCE/QUESTION: <what must be decided or verified>
RETURN: <concise decision/verdict + escalation recommendation if needed>
~~~

For verification, a recommendation to use Sol must identify the unresolved material
uncertainty and its concrete high-consequence risk. Without both, the primary must not
spawn Sol verification.

Do not send unrelated repository history.

## Completion output

Unless the user asks for benchmark diagnostics, keep the report compact:

~~~text
PLAN: <Terra Medium | Terra High | Sol Low | Sol Medium>
IMPLEMENT: <lane>
VERIFY: <Terra Medium | Terra High | Sol Low | Sol Medium | Sol High> — <checks/result>
SOL VERIFY: no | yes — <break-glass reason>
ESCALATION: none | <path + reason>
~~~

## Optional visible Luna app task

If explicitly requested, follow `references/luna-task-lane.md`. The Terra / Medium
primary remains controller. Planning uses the normal graduated ladder; verification
normally stops at Terra / High and uses Sol only through the same strict break-glass
gate.
