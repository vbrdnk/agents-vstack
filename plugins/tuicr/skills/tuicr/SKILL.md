---
name: tuicr
description: Use tuicr's review CLI to read or add comments in active TUI review sessions, and launch tuicr in Herdr, tmux, Zellij, or cmux when the user wants an interactive review pane.
---

# tuicr Review Workflow

Use `tuicr review` as the agent interface. The human reviews code in the TUI; the agent uses the CLI to discover sessions, read user feedback, and add agent-authored comments only with permission.

## Select the Workflow

Determine which workflow the user wants before acting:

1. **User-led review of agent-generated changes**
   - Open or locate the tuicr session, then read the user's comments when they say feedback is ready.
   - When explicitly asked to wait during the review, poll `tuicr review comments` and compare comment IDs.
   - Do not review your own patch preemptively, add agent comments, or impersonate the user.

2. **Agent review of an AI-generated patch**
   - Inspect the patch and propose findings.
   - Add findings to tuicr only after the user explicitly approves writing them. Always pass `--username` to identify the agent.

If the intent is ambiguous, ask which workflow the user wants.

## Attach to a Session

Determine the repository from the request, current directory, or recent file operations. Ask only when it is ambiguous.

List persisted sessions with the narrowest known selector:

```bash
tuicr review list --repo /path/to/repo
tuicr review list --repo owner/repo
tuicr review list --all
```

A checkout path includes local sessions and PR sessions associated with its `origin`. An `owner/repo` selector matches both local and PR sessions. Each result includes a `kind`, `slug`, and possibly the convenience signal `"active": true`.

- Attach automatically when exactly one relevant active session is clear.
- Ask for a slug when multiple sessions are plausible.
- Use a user-provided slug or session JSON path directly.
- A PR slug such as `gh:owner/repo/pr/N` is self-contained and does not need `--repo`.
- If an active slug fails to resolve, ask for the slug or repository used by the session.

Connecting to an existing session does not require the agent itself to run inside a multiplexer.

## Start a Session

When an interactive pane is needed and no active session exists, use the first matching environment in this exact preference order:

| Priority | Environment | Command |
| ---: | --- | --- |
| 1 | `$HERDR_ENV` is `1` | `<skill-directory>/tuicr-wrapper-herdr.sh /path/to/repo` |
| 2 | `$TMUX` is set | `<skill-directory>/tuicr-wrapper.sh /path/to/repo` |
| 3 | `$ZELLIJ` is set | `<skill-directory>/tuicr-wrapper-zellij.sh /path/to/repo` |
| 4 | `$CMUX_WORKSPACE_ID` is set | `<skill-directory>/tuicr-wrapper-cmux.sh /path/to/repo` |

If multiple markers are set, do not infer nesting: use the first matching row. If none are set, ask the user to start `tuicr` in the repository, then attach after they confirm it is ready.

The wrappers support Git and Jujutsu repositories. A Jujutsu workspace may not contain `.git`, so do not pre-check with `git rev-parse`; let the wrapper validate the repository.

- Herdr requires `jq` for pane IDs and completion results.
- The tmux, Zellij, and Herdr wrappers block until tuicr exits. Use a long tool timeout, such as 10 minutes, when supported.
- The cmux wrapper returns after launch and prints a surface reference between `=== TUICR SURFACE ===` markers. Capture it for `cmux close-surface --surface <ref>`.
- If a blocking wrapper prevents other commands, read comments after the user exits tuicr.

After launch, use `tuicr review list --repo /path/to/repo` to capture the session slug.

## Read User Comments

After the user says feedback is ready, or after the TUI exits, run:

```bash
tuicr review comments --repo /path/to/repo --session <slug>
```

The JSON includes the comment ID, target path and lines, diff side, type, lifecycle state, and content. Interpret types as follows:

- `issue`: blocking problem to address first.
- `suggestion`: consider implementing or explain why not.
- `note`: answer or acknowledge.
- `praise`: no action required.

When explicitly waiting, poll about every 30 seconds and compare IDs. Read immediately when the user says comments are ready. Stop when the review is done or polling would block other work.

If no comments are returned, confirm the session and whether comments were saved. Rerun the command before claiming completion if the review may have continued.

## Add Agent Comments

Require explicit approval before writing agent-authored findings into tuicr.

- Prefer a line comment when a file and line are known.
- Use a file comment for file-wide feedback and a review comment for the whole review.
- Default genuine problems to `--type issue`; use `suggestion`, `note`, or `praise` when more accurate.
- Always pass `--username` so the author is distinguishable.

```bash
tuicr review add --repo /path/to/repo --session <slug> \
  --target-file src/main.rs \
  --line 42 \
  --side new \
  --type issue \
  --username "Claude" \
  "Handle the empty case here."
```

Omit `--target-file` for review-level feedback. Omit `--line` for file-level feedback. Add `--end-line` for a range. Use `--side old` for removed lines and `--side new` for added or unchanged lines.

## Wrapper Output Fallback

The blocking wrappers may emit content between `=== TUICR INSTRUCTIONS ===` markers. Process it when present, but prefer `tuicr review comments` as the primary source of feedback. Ask the user to paste clipboard output only when CLI comments are unavailable.

## Failures

- If `tuicr` is missing, report that it must be installed rather than installing it without permission.
- If a wrapper rejects the repository, ask for the correct directory.
- If cmux produces no surface reference, run `cmux list-panes` or ask the user to start tuicr manually.

## When Not to Use

- The user only wants raw `git diff` output.
- The user explicitly requests a different review workflow.
- The task is a remote PR review with no tuicr PR session.
