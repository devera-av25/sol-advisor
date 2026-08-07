# Luna app-task lane contract

This contract covers the optional, explicit **user-visible Codex app-task** version of
Luna execution. It is separate from this fork's normal native Luna custom-agent lane.
Use it only when the user specifically asks for a separate Codex app task/worktree.

The primary GPT-5.6 Sol / High task remains architect, router, verification owner, PR
authority, and acceptor.

## Authorization and capability gate

- Do not activate this lane from ordinary implementation requests. The user must
  explicitly request the user-visible Luna task lane in the current request.
- Confirm the app exposes `list_projects`, `list_threads`, `create_thread`,
  `wait_threads`, `read_thread`, and `send_message_to_thread`.
- Confirm the host accepts `gpt-5.6-luna` with `max` thinking.
- If a required capability is unavailable, stop this optional lane rather than
  silently substituting another model or effort. The primary may separately choose the
  normal native router only when that is consistent with the user's request.

The existence of `sol_advisor_luna_implementer` does not mean this app-task lane uses
`spawn_agent`. Native Luna and app-task Luna are two different execution mechanisms.

## Tool sequence

1. Call `list_projects` and select the intended `projectId`. Confirm
   `isGitRepository` before task creation.
2. Build the complete task packet below; the child does not inherit the parent's full
   conversation.
3. Call `create_thread` with `model = gpt-5.6-luna` and `thinking = max`. For a Git
   project, prefer the app's isolated worktree behavior unless the user requested a
   different supported starting state.
4. If creation returns only a `clientThreadId`, treat it only as a setup handle. Call
   `list_threads` without passing that client ID and correlate the new task using
   trustworthy identity, project, time, path, and state metadata. Do not pass a pending
   client ID to thread-id-only tools.
5. Monitor a ready task with `wait_threads`, then read its handoff with `read_thread`.
6. Independently inspect the actual worktree, branch, diff, base, commits, and checks.
   A child report is evidence to inspect, not acceptance.
7. Send corrections to the same real task with `send_message_to_thread`, then wait,
   read, and inspect again.
8. Authorize PR creation explicitly only after the primary accepts the diff and checks.

## Complete task packet

~~~text
ROLE
Act as the implementation worker in Sol Advisor's explicit user-visible Luna / Max app
task lane. Execute the settled plan. Do not redesign architecture, broaden ownership,
or create/push a PR without primary authorization.

OBJECTIVE
<Observable outcome, why it matters, and acceptance condition.>

FILES AND OWNERSHIP
You own only:
- <exact paths>
Preserve unrelated/concurrent edits. Do not modify files outside this ownership.

INTERFACES
- <signatures, schemas, routes, APIs, behavior to preserve>

CONSTRAINTS
- <repository conventions, safety boundaries, settled decisions, excluded scope>
- This task is GPT-5.6 Luna / Max through Codex app-task tools.

STARTING STATE / BASE
- Project ID: <projectId>
- Repository: <isGitRepository true|false>
- Environment: <worktree|local>
- Base branch/ref/state: <exact observed base>
- Existing task identity if correcting: <threadId and hostId>

VERIFICATION
- Run: <exact command>
  Success: <expected evidence>
- Inspect: <diff/artifact/runtime evidence>
  Success: <expected evidence>

GIT / PR BOUNDARY
- Report status, base, branch, changed files, diff, and commit state.
- Commit only when requested.
- Do not push or create/update a PR until the primary explicitly authorizes it.

STRUCTURED RETURN
STATUS: complete | partial | blocked | escalate
TASK ID: <threadId, hostId, clientThreadId history if any>
OBJECTIVE: <one line>
STARTING STATE: <project/environment/base/worktree>
CHANGES: <file-by-file actual diff summary>
VERIFIED: <commands plus concrete evidence>
GIT: <status/changed files/commit/branch/base>
PR: <not authorized | authorized | URL/evidence>
JUDGMENT CALLS: <decisions or none>
GAPS: <unfinished work/blockers or none>
ESCALATION: <none | recommend Terra: reason | recommend Sol: reason>
~~~

## Worktree and stack rules

- Isolated worktrees reduce interference but do not make overlapping edits merge-safe.
- Independent non-overlapping stacks may run concurrently in separate tasks/worktrees.
- Shared-file or dependent stacks remain serial.
- Corrections stay in the original task rather than creating a replacement task merely
  to avoid feedback.
- The child does not merge, rebase, cherry-pick, push, or open another stack's PR.

## Primary acceptance checklist

The primary may accept an app-task result only after it has:

- monitored and read the real task identity;
- inspected actual worktree/branch/base/diff and changed-file scope;
- rerun requested verification and compared concrete evidence;
- resolved corrections through the same task when needed;
- recorded observed task-routing evidence without inventing unavailable metadata;
- authorized any PR action explicitly; and
- obtained the same fresh native `sol_advisor_sol_reviewer` verdict required by the
  normal router before reporting completion.
