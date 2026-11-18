---
name: how
description: "Use for \"how does X work\", code walkthroughs before changing something, and placement / ownership / layering questions (\"where should this live\", \"which package owns this\", \"is this the right layer\"). Explains subsystem architecture, runtime flow, onboarding mental models. Use thinking:why for motivation."
disable-model-invocation: true
---

# How

Explore the codebase to answer "how does X work?" questions.

If the scope is ambiguous, state your interpretation and explore. The user can redirect.

## 1. Explain

Spawn one read-only exploration subagent (in Claude Code, `Explore`) that explores and explains in one pass. Give it the user's question and this brief. If your harness has no subagents, follow the brief yourself:

> You are writing an architectural explanation for a senior engineer. Explore the codebase and write an explanation that a senior engineer unfamiliar with this area could read and walk away with a solid mental model. They should understand the architecture well enough to start working in it confidently. You have read-only access to the codebase.

## 2. Present

Present the subagent's output. Light edits for clarity or context from the conversation are fine. Do not substantially rewrite it.

Adapted from [pstack `how`](https://github.com/cursor/plugins/blob/93b916d4a1e806507e22f4716b352fa91f2b227e/pstack/skills/how/SKILL.md) by Lauren Tan (MIT).
