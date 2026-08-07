---
name: orchestration
description: "Token-efficient capability router: Terra / Medium is the normal planner-controller-verifier, planning escalates Terra High -> Sol Low -> Sol Medium only when needed, implementation prefers Luna Low/Medium then Terra Medium, and verification escalates Terra High -> Sol Low/Medium/High by risk and complexity."
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

## Verification ladder

Verification starts with the Terra / Medium primary and scales independently from the
implementation model.

~~~text
Terra / Medium primary verification
        ↓ if stronger reasoning on same model is warranted
Terra / High consultant
        ↓ only if stronger model capability is warranted
Sol / Low consultant
        ↓ if insufficient
Sol / Medium consultant
        ↓ only for exceptional residual risk/uncertainty
Sol / High reviewer
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

### Terra / High verification

Use when verification is reasoning-heavy or the blast radius is wider, but a stronger
model is not yet necessary: subtle state logic, broader refactors, difficult edge cases,
performance-sensitive behavior, or moderately complex integration.

### Sol / Low verification

Upgrade models only when Terra is not sufficient to judge the change reliably. Start at
Sol / Low for bounded but consequential verification where stronger model capability is
useful without deep reasoning.

### Sol / Medium verification

Use for higher-impact architecture/API/data-model changes, difficult concurrency or
native lifecycle behavior, security-sensitive changes, Sol-implemented work, or when Sol
/ Low leaves material uncertainty.

### Sol / High verification — exceptional

Use the existing `sol_advisor_sol_reviewer` only when the strongest independent review
is justified: severe residual uncertainty, very high-impact security/data-loss/signing/
release risk, incomplete or conflicting evidence, extremely complex implementation, or
an explicit request for strongest review.

Do not spawn an independent verifier merely as ritual. Low-risk work can complete after
Terra / Medium primary verification.

## Consultant contract

For planning or verification, send only the decision/change context needed and specify:

~~~text
MODE: planning | verification
OBJECTIVE: <one sentence>
RELEVANT PATHS/INTERFACES: <small bounded set>
EVIDENCE/QUESTION: <what must be decided or verified>
RETURN: <concise decision/verdict + escalation recommendation if needed>
~~~

Do not send unrelated repository history.

## Completion output

Unless the user asks for benchmark diagnostics, keep the report compact:

~~~text
PLAN: <Terra Medium | Terra High | Sol Low | Sol Medium>
IMPLEMENT: <lane>
VERIFY: <Terra Medium | Terra High | Sol Low | Sol Medium | Sol High> — <checks/result>
ESCALATION: none | <path + reason>
~~~

## Optional visible Luna app task

If explicitly requested, follow `references/luna-task-lane.md`. The Terra / Medium
primary remains controller and uses the same graduated planning and verification ladders.
