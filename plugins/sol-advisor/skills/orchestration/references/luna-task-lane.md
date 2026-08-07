# Luna app-task lane contract

This contract covers the optional, explicit **user-visible Codex app-task** version of
Luna execution. It is separate from the normal native Luna lanes and is used only when
the user specifically asks for a separate Codex app task/worktree.

The normal primary GPT-5.6 Terra / Medium task remains controller, routine planner,
verification owner, PR authority, and acceptor. It uses the same graduated planning and
verification ladders as the native router.

## Authorization and capability gate

- Do not activate this lane from ordinary implementation requests.
- Confirm the app exposes the required project/thread/task tools.
- Prefer `gpt-5.6-luna` with `medium` thinking for normal app-task execution.
- If a required capability is unavailable, stop this optional lane rather than silently
  substituting another model or effort.

Native Luna and app-task Luna are separate execution mechanisms.

## Tool sequence

1. Select the intended project and confirm Git/worktree state.
2. Build a concise task packet; the child does not inherit the parent's full context.
3. Create the task with `gpt-5.6-luna` / `medium` by default.
4. Resolve the real task identity from trustworthy host metadata.
5. Wait/read the handoff and inspect the actual worktree/diff independently.
6. Send corrections to the same task when needed.
7. Authorize PR creation only after primary acceptance.
8. Apply the same graduated verification ladder as the native router.

## Task packet

~~~text
ROLE
Implement the settled task in this visible Luna app-task lane. Do not redesign
architecture, broaden ownership, or push/create a PR without primary authorization.

OBJECTIVE
<Observable outcome.>

OWNERSHIP
You own only:
- <exact paths>
Preserve unrelated/concurrent edits.

INTERFACES / CONSTRAINTS
- <only relevant contracts and boundaries>

STARTING STATE
- Project/worktree/base: <observed state>

VERIFICATION
- <checks useful during implementation>
- Primary final acceptance check: <targeted command>

RETURN
STATUS: complete | partial | blocked | escalate
CHANGES: <concise file summary>
VERIFIED: <short evidence>
GIT: <branch/base/changed files>
PR: not authorized | authorized | <URL>
ESCALATION: none | recommend Terra: <reason> | recommend Sol: <reason>
~~~

Do not return large logs or full diffs when the parent can inspect them directly.

## Primary acceptance

The Terra / Medium primary:

- inspects the actual worktree/changed-file scope;
- runs proportionate final verification;
- uses Terra / High verification when stronger same-model reasoning is warranted;
- upgrades verification to Sol / Low, then Sol / Medium, and only exceptionally Sol /
  High when stronger model capability/risk justifies it;
- uses the same planning ladder Terra Medium -> Terra High -> Sol Low -> Sol Medium if
  a new material planning decision appears;
- authorizes PR actions explicitly.
