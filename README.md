# Personal Claude Code Plugins

A personal Claude Code marketplace containing reusable Git workflow, coding, and writing skills.

## Plugins

| Plugin | Skill | Purpose |
| --- | --- | --- |
| `commit` | `/commit:commit` | Review the working tree, generate a Conventional Commit message, stage the reviewed changes, and commit |
| `review-handoff` | `/review-handoff:review-handoff` | Summarize uncommitted and committed-ahead changes for another code reviewer |
| `tuicr` | `/tuicr:tuicr` | Use active tuicr review sessions or launch a review pane with Herdr, tmux, Zellij, cmux, or Rex |
| `principle-type-system-discipline` | `/principle-type-system-discipline:principle-type-system-discipline` | Apply language-agnostic type design principles; grounded per language by skills like `typescript-best-practices` |
| `typescript-best-practices` | `/typescript-best-practices:typescript-best-practices` | Apply strict TypeScript type-system practices when reading or editing `.ts`/`.tsx` files |
| `unslop` | `/unslop:unslop` | Cut AI writing patterns from text and add a human voice |

## Install

Add the marketplace from GitHub:

```bash
claude plugin marketplace add vbrdnk/claude-setup
```

Install any of the plugins:

```bash
claude plugin install commit@vbrdnk-claude-plugins
claude plugin install review-handoff@vbrdnk-claude-plugins
claude plugin install tuicr@vbrdnk-claude-plugins
claude plugin install principle-type-system-discipline@vbrdnk-claude-plugins
claude plugin install typescript-best-practices@vbrdnk-claude-plugins
claude plugin install unslop@vbrdnk-claude-plugins
```

Run `/reload-plugins` after installation. Restart Claude Code only if the skills still do not appear.

## Update installed plugins

Plugin versions are pinned by each `plugin.json`. Bump the affected version before publishing an update, then run:

```bash
claude plugin marketplace update vbrdnk-claude-plugins
claude plugin update commit@vbrdnk-claude-plugins
claude plugin update review-handoff@vbrdnk-claude-plugins
claude plugin update tuicr@vbrdnk-claude-plugins
claude plugin update principle-type-system-discipline@vbrdnk-claude-plugins
claude plugin update typescript-best-practices@vbrdnk-claude-plugins
claude plugin update unslop@vbrdnk-claude-plugins
```

Only run the `plugin update` command for plugins whose versions changed.

## Validate locally

From the repository root:

```bash
claude plugin validate . --strict
```

You can also load one plugin directly during development:

```bash
claude --plugin-dir ./plugins/commit
claude --plugin-dir ./plugins/review-handoff
claude --plugin-dir ./plugins/tuicr
claude --plugin-dir ./plugins/principle-type-system-discipline
claude --plugin-dir ./plugins/typescript-best-practices
claude --plugin-dir ./plugins/unslop
```

## tuicr requirements and attribution

The `tuicr` plugin requires the `tuicr` executable. Launching a new pane also requires one supported multiplexer; the preference is Herdr, tmux, Zellij, cmux, then Rex. The Herdr wrapper additionally requires `jq`.

This plugin adapts the upstream [`tuicr` skill](https://github.com/agavra/tuicr/tree/main/skills/tuicr) and includes its wrapper scripts under the upstream MIT license.
