---
name: review-handoff
description: "Generate a concise change summary for code review by another agent. Covers uncommitted and committed-ahead-of-base changes with decision rationale. Use when the user asks for a change summary, review prep, or wants to describe what changed, including 'summarize my changes' or 'what did I change'."
disable-model-invocation: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git branch:*)
  - Bash(git log:*)
  - Bash(git rev-parse:*)
  - Bash(git symbolic-ref:*)
  - Bash(git show-ref:*)
  - Bash(git ls-files:*)
---

# Change Summary Generator

Generate a self-contained change summary for an AI code reviewer. The reviewer will only receive this summary, not the raw diff. Include every changed file and enough context for the reviewer to locate, read, and evaluate each change.

## Gather Changes

Collect uncommitted changes, including untracked files, and commits ahead of the base branch.

```bash
# Repository root, current branch, and complete worktree status
git rev-parse --show-toplevel
git branch --show-current
git status --short

# Tracked changes, staged and unstaged
git diff HEAD --stat
git diff HEAD

# Untracked files, which git diff HEAD does not include
git ls-files --others --exclude-standard

# Detect the remote default branch
git symbolic-ref --short refs/remotes/origin/HEAD

# If origin/HEAD exists, use the returned ref, such as origin/main
git log <remote-default-ref>..HEAD --oneline
git diff <remote-default-ref>...HEAD --stat
git diff <remote-default-ref>...HEAD

# Otherwise, fall back to an existing local default branch
git show-ref --verify --quiet refs/heads/main
git show-ref --verify --quiet refs/heads/master
git log <local-default-branch>..HEAD --oneline
git diff <local-default-branch>...HEAD --stat
git diff <local-default-branch>...HEAD
```

Read each untracked file listed by `git ls-files --others --exclude-standard`, subject to normal safety and size limits. Include those files in the summary even though they do not appear in `git diff HEAD`.

Run only the base comparison that resolves successfully. Do not execute commands containing the placeholders above. If neither a remote nor local default branch exists, summarize the worktree changes and clearly state that no committed range could be determined.

Resolve every repository-relative file path against the root returned by `git rev-parse --show-toplevel` before writing the summary. If no tracked changes, untracked files, or commits ahead exist, tell the user there is nothing to summarize and stop.

## Analyze Before Writing

Read the complete change set and understand:

1. **What changed** - files added, modified, or deleted; new exports; changed signatures; and new dependencies.
2. **Why it changed** - infer intent from commit messages, variable names, comments, and the shape of the changes.
3. **Non-obvious decisions** - library choices, unusual patterns, workarounds, intentionally deferred work, or deviations from existing conventions.
4. **Risk areas** - edge cases, behavioral changes, and places where bugs may hide.

Pay particular attention to deleted code, new dependencies, changed interfaces or types, and whether tests cover behavior rather than merely accommodate the implementation.

## Write the Summary

Output one compact block of prose without Markdown headers. Structure it as:

1. Lead with what the change does and why, using user-facing or system-facing terms.
2. List every changed file by full path, grouping related implementation and test files. Explain what changed and why.
3. Include non-obvious decisions alongside the relevant file or group.
4. End with specific risk callouts naming the relevant files, functions, or line ranges.

Keep the summary under approximately 300 words. Scale it to the change rather than padding a small update.

## Quality Checks

Before presenting the summary, verify that:

- Every staged, unstaged, untracked, and committed-ahead file appears by full path.
- Non-obvious decisions include rationale, or explicitly say when the reason cannot be inferred.
- Risk callouts identify concrete risks rather than asking for generic review.
- The summary is understandable without access to the diff.
