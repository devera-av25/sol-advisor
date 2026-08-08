# Sol Advisor

**Terra / Medium controls by default. Luna handles routine execution. Planning scales
upward only when needed, while normal verification stops at Terra / High and reserves
Sol for break-glass cases.**

This fork is optimized for practical Codex Desktop development where token/credit usage,
latency, and correctness all matter.

## Routing model

### Primary controller

Start normal Codex tasks with:

~~~text
GPT-5.6 Terra / Medium
~~~

The primary handles routine planning, routing, targeted verification, escalation
interpretation, and acceptance.

### Planning ladder

~~~text
Terra / Medium primary
        ↓ if more same-model reasoning is needed
Terra / High consultant
        ↓ only if a stronger model is actually needed
Sol / Low consultant
        ↓ only if low effort is insufficient
Sol / Medium consultant
~~~

Sol / Medium is the maximum normal planning tier. Sol / High is not used merely for
planning.

### Implementation ladder

~~~text
trivial / mechanical       -> Luna / Low
normal easy-medium         -> Luna / Medium
medium-hard                -> Terra / Medium
hard-complex               -> separate Sol / High implementer
~~~

### Verification policy

Normal verification now has a hard Terra ceiling:

~~~text
Terra / Medium primary
        ↓ when stronger same-model reasoning is warranted
Terra / High consultant
        ↓
NORMAL STOP
~~~

Sol is **not** the next normal verification tier. It is a separate break-glass path.
Except for an explicit request for strongest/Sol review or an obviously critical case
where Terra / High would add no useful intermediate evidence, Sol verification requires:

1. Terra / High verification has already been attempted.
2. Terra / High still has specific material unresolved correctness uncertainty.
3. That uncertainty has meaningful high-consequence impact such as severe security/auth,
   destructive or irreversible data loss, high-impact migration/schema risk,
   payment/financial correctness, signing/release-critical behavior, or substantial
   public API/protocol compatibility risk.

If that gate is satisfied, use the lowest sufficient Sol tier:

~~~text
BREAK GLASS
Sol / Low
   ↓ only if still materially unresolved
Sol / Medium
   ↓ exceptional residual risk only
Sol / High reviewer
~~~

Routine feature work, UI changes, ordinary bugs/refactors/tests, multiple changed files,
or use of Terra/Sol for implementation do not qualify by themselves. In particular,
**Sol implementation does not imply Sol verification**.

This means routine low-risk work can plan with Terra / Medium, implement with Luna /
Low or Medium, and finish after targeted Terra / Medium verification without paying for
an additional Sol context. Harder ordinary work should normally finish by Terra / High.

## Efficiency rules

- Use the lowest capable model and reasoning effort.
- Prefer increasing reasoning effort before changing to a more expensive model family.
- When upgrading from Terra to Sol for planning, start Sol at Low.
- Planning normally stops at Sol / Medium.
- Normal verification stops at Terra / High.
- Sol verification is break-glass only and requires unresolved high-consequence risk.
- Sol implementation never automatically triggers Sol verification.
- Capture only a small pre-delegation Git baseline and inspect worker-owned deltas.
- Run the narrowest meaningful final test/check once in the primary for trivial work.
- Do not run full typecheck/lint/test suites unless repository policy, changed surface,
  or evidence makes them relevant.
- Do not paste broad repository context or full diffs into agents that can inspect the
  relevant files directly.

## Native agent profiles

The bootstrap installs eight profiles:

~~~text
sol_advisor_luna_low_implementer    -> gpt-5.6-luna / low
sol_advisor_luna_implementer        -> gpt-5.6-luna / medium
sol_advisor_terra_implementer       -> gpt-5.6-terra / medium
sol_advisor_terra_high_consultant   -> gpt-5.6-terra / high
sol_advisor_sol_low_consultant      -> gpt-5.6-sol / low
sol_advisor_sol_medium_consultant   -> gpt-5.6-sol / medium
sol_advisor_sol_implementer         -> gpt-5.6-sol / high
sol_advisor_sol_reviewer            -> gpt-5.6-sol / high / requested read-only
~~~

The consultant roles are read-only planning-or-verification lanes. A task packet sets
`MODE: planning` or `MODE: verification` explicitly. For verification, Sol consultant
use is additionally constrained by the break-glass gate above.

## Setup / upgrade in Codex Desktop

Repository:

~~~text
https://github.com/devera-av25/sol-advisor
~~~

Development branch before PR #1 is merged:

~~~text
agent/luna-terra-sol-routing
~~~

For an existing checkout:

~~~sh
cd /path/to/sol-advisor
git pull --ff-only
sh scripts/bootstrap-codex.sh --expected-branch agent/luna-terra-sol-routing
~~~

The bootstrap registers the local marketplace, installs the plugin, validates the
installed copy against the checkout, installs/migrates the native profiles, and validates
all exact role/model/effort pins.

After `BOOTSTRAP PASSED`, fully quit/restart Codex Desktop and start a **new** task with:

~~~text
GPT-5.6 Terra / Medium
~~~

Then invoke the orchestration skill directly, or let a repository `AGENTS.md` invoke it
automatically for implementation work.

The skill cannot silently switch the primary model itself.

## Example routes

Tiny utility:

~~~text
Terra / Medium plan -> Luna / Low -> Terra / Medium targeted verification -> done
~~~

Normal mobile feature:

~~~text
Terra / Medium plan -> Luna / Medium -> Terra / Medium verification -> done
~~~

Harder async/state work:

~~~text
Terra / Medium plan -> optional Terra / High planning consult
                    -> Terra / Medium implementation
                    -> Terra / High verification if warranted
                    -> done
~~~

Hard implementation that does not need Sol verification:

~~~text
Terra planning tier as needed
        -> Sol / High implementation
        -> Terra / High verification
        -> done
~~~

Break-glass verification example:

~~~text
Terra / High verification
        -> unresolved material high-consequence risk
        -> Sol / Low verification
        -> Sol / Medium or High only if still required
~~~

Architecture-sensitive planning where Terra is insufficient:

~~~text
Terra / Medium -> Terra / High planning consult
               -> Sol / Low planning consult
               -> Sol / Medium only if still needed
               -> appropriate implementation lane
               -> verification starts with Terra and normally stops by Terra / High
~~~

## Runtime verification

Native spawn/details metadata is the primary routing evidence. If Desktop omits model or
effort and a native thread ID is available:

~~~sh
plugin_dir="$(codex plugin list --json | jq -r '.installed[] | select(.pluginId == "sol-advisor@sol-advisor") | .source.path')"
sh "$plugin_dir/scripts/inspect-agent-runtime.sh" <native-subagent-thread-id>
~~~

There is no silent role/model/effort fallback.

Consultants and the Sol reviewer request read-only sandboxing, but hosts may expose
broader permissions. Report observed isolation and verify no mutation rather than
claiming requested isolation was enforced.

## Optional visible Luna task lane

A separate user-visible Luna app task/worktree remains available only when explicitly
requested. Its default worker is Luna / Medium. Planning uses the normal graduated
ladder; verification normally stops at Terra / High and uses Sol only through the strict
break-glass gate.

## Attribution

This repository is a fork of DannyMac180/sol-advisor and retains the original project's
license and authorship metadata while changing its routing policy for this fork.

## License

See [LICENSE](LICENSE).
