---
name: why
description: "Use for 'why does X work this way', 'why we picked Y', design rationale, regressions, postmortems, or data-backed thresholds. Returns a cited read on decisions and tradeoffs. Use thinking:how for runtime behavior."
disable-model-invocation: true
---

# Why

Answer from the record, not the code: read the commits and PR discussions that introduced the target and each later change, and other sources if the trail is thin. Cite what the authors wrote, mark your own inferences as inferences, and say what the record does not answer.

Start with `git log --follow` and `git blame` on the target. When `gh` is available, read the PR descriptions and review threads linked from those commits.

Adapted from [pstack `why`](https://github.com/cursor/plugins/blob/93b916d4a1e806507e22f4716b352fa91f2b227e/pstack/skills/why/SKILL.md) by Lauren Tan (MIT).
