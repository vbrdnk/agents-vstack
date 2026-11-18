# Personal Claude Code Plugins

A personal Claude Code marketplace containing reusable Git workflow, coding, thinking, writing, and session skills.

## Plugins

| Plugin | Skills | Purpose |
| --- | --- | --- |
| `git` | `/git:commit` | Review the working tree, generate a Conventional Commit message, stage the reviewed changes, and commit |
| | `/git:review-handoff` | Summarize uncommitted and committed-ahead changes for another code reviewer |
| `tuicr` | `/tuicr:review` | Use active tuicr review sessions or launch a review pane with Herdr, tmux, Zellij, cmux, or Rex |
| `principles` | `/principles:type-system` | Apply language-agnostic type design principles |
| | `/principles:test-behavior` | Assert observable behavior so tests fail when behavior breaks and survive refactors |
| `thinking` | `/thinking:how` | Explain how a subsystem works through a read-only subagent |
| | `/thinking:why` | Explain why code is the way it is, cited from commits and PR discussions |
| | `/thinking:architect` | Sketch two shapes for types, signatures, and modules before writing code |
| | `/thinking:doubt` | Cross-examine a non-trivial decision with a fresh-context adversarial reviewer |
| `practices` | `/practices:typescript` | Ground the principles in TypeScript when reading or editing `.ts`/`.tsx` files |
| `writing` | `/writing:unslop` | Cut AI writing patterns from text and add a human voice |
| | `/writing:technical-writing` | Apply a layered technical-writing standard to docs, RFCs, PR descriptions, and commit messages |
| `session` | `/session:catchup` | Summarize what changed since your last message and list the calls waiting on you |
| | `/session:reflect` | Turn durable learnings from the session into proposed skill edits |

`practices` skills build on `principles`, so install both.

`principles:test-behavior`, `writing:technical-writing`, and the existing `principles`, `practices`, and `writing` skills can trigger on their own. The `thinking` and `session` skills run only when you invoke them.

## Install

Add the marketplace from GitHub:

```bash
claude plugin marketplace add vbrdnk/agents-vstack
```

Install any of the plugins:

```bash
claude plugin install git@vbrdnk-claude-plugins
claude plugin install tuicr@vbrdnk-claude-plugins
claude plugin install principles@vbrdnk-claude-plugins
claude plugin install thinking@vbrdnk-claude-plugins
claude plugin install practices@vbrdnk-claude-plugins
claude plugin install writing@vbrdnk-claude-plugins
claude plugin install session@vbrdnk-claude-plugins
```

Run `/reload-plugins` after installation. Restart Claude Code only if the skills still do not appear.

## Update installed plugins

Plugin versions are pinned by each `plugin.json`. Bump the affected version before publishing an update, then run:

```bash
claude plugin marketplace update vbrdnk-claude-plugins
claude plugin update git@vbrdnk-claude-plugins
claude plugin update tuicr@vbrdnk-claude-plugins
claude plugin update principles@vbrdnk-claude-plugins
claude plugin update thinking@vbrdnk-claude-plugins
claude plugin update practices@vbrdnk-claude-plugins
claude plugin update writing@vbrdnk-claude-plugins
claude plugin update session@vbrdnk-claude-plugins
```

Only run the `plugin update` command for plugins whose versions changed.

### Migrating from the 1.x layout

The `commit` and `review-handoff` plugins are now skills in the `git` plugin, and `/tuicr:tuicr` is now `/tuicr:review`. The marketplace maps the old plugin names to `git`; if an old install lingers, remove it and install the new plugin:

```bash
claude plugin uninstall commit@vbrdnk-claude-plugins
claude plugin uninstall review-handoff@vbrdnk-claude-plugins
claude plugin install git@vbrdnk-claude-plugins
claude plugin update tuicr@vbrdnk-claude-plugins
```

## Validate locally

From the repository root:

```bash
claude plugin validate . --strict
```

You can also load one plugin directly during development:

```bash
claude --plugin-dir ./plugins/git
claude --plugin-dir ./plugins/tuicr
claude --plugin-dir ./plugins/principles
claude --plugin-dir ./plugins/thinking
claude --plugin-dir ./plugins/practices
claude --plugin-dir ./plugins/writing
claude --plugin-dir ./plugins/session
```

## tuicr requirements and attribution

The `tuicr` plugin requires the `tuicr` executable. Launching a new pane also requires one supported multiplexer; the preference is Herdr, tmux, Zellij, cmux, then Rex. The Herdr wrapper additionally requires `jq`.

This plugin adapts the upstream [`tuicr` skill](https://github.com/agavra/tuicr/tree/main/skills/tuicr) and includes its wrapper scripts under the upstream MIT license.

## Third-party attribution

Several skills are adapted from MIT-licensed projects. Each adapted `SKILL.md` ends with a line that links to the exact upstream file. Each plugin ships the upstream license next to its skills.

| Plugin | Skills | Upstream | License file |
| --- | --- | --- | --- |
| `principles` | `type-system`, `test-behavior` | [cursor/plugins `pstack`](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan | `plugins/principles/LICENSE` |
| `practices` | `typescript` | [cursor/plugins `pstack`](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan | `plugins/practices/LICENSE` |
| `writing` | `unslop`, `technical-writing` | [cursor/plugins `pstack`](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan | `plugins/writing/LICENSE` |
| `thinking` | `how`, `why`, `architect` | [cursor/plugins `pstack`](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan | `plugins/thinking/THIRD_PARTY_NOTICES.md` |
| `thinking` | `doubt` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) by Addy Osmani | `plugins/thinking/THIRD_PARTY_NOTICES.md` |
| `session` | `catchup`, `reflect` | [cursor/plugins `pstack`](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan | `plugins/session/LICENSE` |
| `tuicr` | `review` | [agavra/tuicr](https://github.com/agavra/tuicr) | `plugins/tuicr/LICENSE` |

"Adapted from" marks a skill kept close to upstream. "Based on, with changes" marks a skill that was substantially rewritten.
