---
name: commit
description: Generate a Conventional Commits message from the current Git changes using the included specification, then stage and commit the reviewed change set
argument-hint: "[optional summary or scope]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git branch:*)
  - Bash(git log:*)
  - Bash(git add:*)
  - Bash(git commit:*)
---

# Context

- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5`
- Git status: !`git status --porcelain=v1`
- Tracked diff against HEAD: !`git diff HEAD`

# Task

If `$ARGUMENTS` are provided, treat them as hints for the scope or short summary.

1. Review every path reported by `git status --porcelain=v1`, including untracked files. Read untracked files before staging them.
2. If `git status --porcelain=v1` is empty, report that there is nothing to commit and stop.
3. If the worktree contains unrelated logical changes, stop and ask the user how to split or scope the commit. Do not silently combine unrelated changes.
4. Generate a commit message following the specification below.
5. Stage the reviewed change set with `git add -A`.
6. Inspect `git diff --cached --stat` and `git diff --cached --check`. If staging includes an unexpected path or the check fails, stop before committing.
7. Commit with the generated message and report the result.

Never use the em dash "—"; use plain dash "-" instead. Never add an agent name as a co-author. Do not push.

## Commit Message Specification

### Format

    <type>(<scope>)!?: <imperative summary, 50 characters or fewer>

    [Body: what and why, wrapped at 72 characters]

    [Footer: issue metadata or BREAKING CHANGE]

- **Type**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`.
- **Scope**: optional kebab-case area such as `auth`, `api`, `ui`, `deps`, or `infra`.
- **Breaking marker**: optional `!` before the colon.

### Subject

- Use a lowercase imperative summary, such as `add`, `prevent`, or `update`.
- Keep the entire subject line at 50 characters or fewer.
- Do not end with a period.
- Add one blank line before a body.

### Body

- Wrap at 72 characters.
- Explain what changed and why, not the implementation mechanics.
- Mention user impact, meaningful trade-offs, and migration notes when applicable.
- Omit the body when the subject fully explains a small mechanical change.

### Breaking Changes

Use `!` in the subject, a `BREAKING CHANGE:` footer, or both. State what breaks and how to migrate.

### Semantic Versioning

- `feat` maps to a minor release.
- `fix` maps to a patch release.
- `feat!` or `BREAKING CHANGE:` maps to a major release.

### Examples

    feat(auth): add password reset endpoint

    Add POST /reset-password for email-based token resets.
    Invalidate each time-limited token after use.

    fix(ui): prevent sidebar overflow

    Use flex sizing that avoids text clipping on narrow viewports.

    docs(readme): add pnpm installation steps

    feat(api)!: require auth token for writes

    Validate JWTs for every write endpoint.

    BREAKING CHANGE: anonymous writes are no longer accepted.

## Message Selection

- Infer the type from the primary change. Use `test` for test-only changes, `perf` for measured performance improvements, and `build` or `chore(deps)` for dependency-only changes.
- Prefer a concrete scope when changes cluster in one package or area.
- Use a breaking marker only when the change actually breaks a supported contract.
- Include an issue footer only when an issue reference is present in the branch, commits, arguments, or changes.
- Prefer one coherent commit. When changes are unrelated, stop and ask the user to split them.

After committing, show the exact commit message and report whether staging checks and the commit succeeded.
