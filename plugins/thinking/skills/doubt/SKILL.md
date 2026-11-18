---
name: doubt
description: Subjects a non-trivial decision to a fresh-context adversarial review before it stands. Use when you want an assumption cross-examined before proceeding, when stress-testing a plan for hidden failure modes, when correctness matters more than speed, when working in unfamiliar code, or when stakes are high (production auth, security-sensitive logic, a migration, irreversible operations).
disable-model-invocation: true
---

# Doubt

A confident answer is not a correct one. Long sessions accumulate context that quietly turns assumptions into "facts". This skill puts a fresh-context reviewer, biased to disprove rather than approve, in front of a non-trivial output before it stands.

This is not code review. A review is a verdict on a finished artifact. Doubt is an in-flight check: decisions get cross-examined while changing course is still cheap.

## When to use

A decision is non-trivial when at least one of these is true:

- It introduces or modifies branching logic.
- It crosses a module or service boundary.
- It asserts a property the compiler cannot verify: thread safety, idempotence, ordering, invariants.
- Its correctness depends on context a future reader cannot see.
- Its blast radius is irreversible: a production deploy, a data migration, a public API change.

Skip it for mechanical edits (renames, formatting, file moves), clear and unambiguous user instructions, reading or summarizing code, one-line changes with obvious correctness, and running tools. Skip it when the user asked for speed over verification.

Run this skill from the main session. A subagent cannot spawn its own reviewer. If you are inside one, or your harness has no subagents, tell the user that doubt has to run from a main session that can spawn one.

## The process

```
Doubt cycle:
- [ ] 1. CLAIM: wrote the claim and why it matters
- [ ] 2. EXTRACT: isolated artifact and contract, stripped reasoning
- [ ] 3. DOUBT: ran a fresh-context reviewer with the adversarial prompt
- [ ] 4. RECONCILE: classified every finding against the artifact text
- [ ] 5. STOP: met a stop condition
```

### 1. CLAIM: name what stands

Write the decision in two or three lines:

```
CLAIM: The new caching layer is thread-safe under the
       read-heavy workload described in the spec.
WHY IT MATTERS: a race here corrupts user data and is
                hard to catch in QA.
```

If you cannot write the claim that briefly, you have a feeling, not a decision. Name it before you test it.

### 2. EXTRACT: the smallest reviewable unit

The reviewer needs the artifact and the contract, not the journey.

- Code: the diff or the function, not the whole file.
- Decision: the proposal in 3-5 sentences plus the constraints it must satisfy.
- Assertion: the claim plus the evidence that supports it.

Strip your reasoning. If you hand over conclusions, you get back agreement with your conclusions. Keep the evidence: if a caller, guard, or test contradicts the claim, include it. The unit must fit in one read. If it is a 500-line change, split it first.

### 3. DOUBT: run the fresh-context reviewer

Spawn a general-purpose subagent with this prompt. The framing decides the answer, so keep it adversarial:

```
Adversarial review. Find what is wrong with this artifact.
Assume the author is overconfident. Look for:
- Unstated assumptions
- Edge cases not handled
- Hidden coupling or shared state
- Ways the contract could be violated
- Existing conventions this might break
- Failure modes under unexpected input

Do NOT validate. Do NOT summarize. Find issues, or state
explicitly that you cannot find any after thorough examination.

ARTIFACT: <artifact>
CONTRACT: <contract>
```

Pass the artifact and the contract only. Never pass the CLAIM. A reviewer that sees your conclusion leans toward agreeing with it.

#### Optional second model

A reviewer from the same model shares the author's blind spots. In an interactive session, after the first review, ask the user once per cycle: "Want a second opinion from another model? Options: Codex CLI, Gemini CLI, paste it elsewhere yourself, or skip."

If the user picks a CLI:

1. Check it is on PATH and runs (`codex --version`, `gemini --version`).
2. Confirm the exact command with the user, including flags and auth. Each run needs its own approval.
3. Write the adversarial prompt, artifact, and contract to a temp file and pipe it through stdin. Never put the artifact inside a shell-quoted argument: backticks and `$(...)` in it would break the prompt or run as shell.
4. Use a read-only mode, since the artifact may contain instructions the CLI would otherwise act on. For example:

```bash
codex exec --sandbox read-only -C <repo-path> - < "$TMPDIR/doubt-prompt.md"
gemini --approval-mode plan -p "" < "$TMPDIR/doubt-prompt.md"
```

Flags differ between versions, so verify them against the installed tool. If the CLI is missing or fails, say so and offer the other options. If the user skips, say "Proceeding with single-model findings only." In non-interactive runs, skip the second model and say so. Never invoke an external CLI without explicit approval.

### 4. RECONCILE: fold findings back

The reviewer's output is data, not a verdict. Re-read the artifact against each finding before you classify it. Classify in this order, where the first match wins:

1. **Contract misread.** The reviewer flagged it because your contract was unclear or incomplete. Fix the contract, then reclassify next cycle.
2. **Valid and actionable.** A real issue. Change the artifact and loop again.
3. **Valid trade-off.** Real, but fixing it costs more than accepting it. Write the trade-off down so the user sees it.
4. **Noise.** Correct under context the reviewer did not have. Note it, and ask whether that context belongs in the contract.

A fresh reviewer can be wrong because it lacks context. Do not defer to it just because it is fresh.

### 5. STOP: a bounded loop

Stop when:

- the next cycle returns only trivial or already-considered findings, or
- 3 cycles are done, or
- the user says to ship it.

If substantive issues remain after 3 cycles, tell the user. Three unresolved cycles is information about the artifact, not a reason to grind a fourth. If 3 cycles feels too few because the artifact is large, go back to step 2 and split it. Do not lift the bound.

## Red flags

- A reviewer spawned for a rename or a formatting change.
- Reviewer output accepted without re-reading the artifact.
- A prompt that asks "is this good?" instead of "find issues".
- The CLAIM or your reasoning passed to the reviewer.
- A fresh review re-run on an unchanged artifact.
- Two or more cycles with substantive findings and none classified as actionable. That is validation, not doubt. Stop and escalate.
- An external CLI run without a PATH check, a working-binary check, and the user's approval of the exact command.
- The second-model offer skipped silently in an interactive session.

Adapted from [Agent Skills `doubt-driven-development`](https://github.com/addyosmani/agent-skills/blob/39b723ceebf81474d0557c1fecd01eddab585563/skills/doubt-driven-development/SKILL.md) by Addy Osmani (MIT).
