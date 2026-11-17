# Personal Claude Code Plugins

A personal Claude Code marketplace containing reusable Git workflow, coding, and writing skills.

## Plugins

| Plugin | Skills | Purpose |
| --- | --- | --- |
| `git` | `/git:commit` | Review the working tree, generate a Conventional Commit message, stage the reviewed changes, and commit |
| | `/git:review-handoff` | Summarize uncommitted and committed-ahead changes for another code reviewer |
| `tuicr` | `/tuicr:review` | Use active tuicr review sessions or launch a review pane with Herdr, tmux, Zellij, cmux, or Rex |
| `principles` | `/principles:type-system` | Apply language-agnostic type design principles |
| `practices` | `/practices:typescript` | Ground the principles in TypeScript when reading or editing `.ts`/`.tsx` files |
| `writing` | `/writing:unslop` | Cut AI writing patterns from text and add a human voice |

`practices` skills build on `principles`, so install both.

## Install

Add the marketplace from GitHub:

```bash
claude plugin marketplace add vbrdnk/claude-setup
```

Install any of the plugins:

```bash
claude plugin install git@vbrdnk-claude-plugins
claude plugin install tuicr@vbrdnk-claude-plugins
claude plugin install principles@vbrdnk-claude-plugins
claude plugin install practices@vbrdnk-claude-plugins
claude plugin install writing@vbrdnk-claude-plugins
```

Run `/reload-plugins` after installation. Restart Claude Code only if the skills still do not appear.

## Update installed plugins

Plugin versions are pinned by each `plugin.json`. Bump the affected version before publishing an update, then run:

```bash
claude plugin marketplace update vbrdnk-claude-plugins
claude plugin update git@vbrdnk-claude-plugins
claude plugin update tuicr@vbrdnk-claude-plugins
claude plugin update principles@vbrdnk-claude-plugins
claude plugin update practices@vbrdnk-claude-plugins
claude plugin update writing@vbrdnk-claude-plugins
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
claude --plugin-dir ./plugins/practices
claude --plugin-dir ./plugins/writing
```

## tuicr requirements and attribution

The `tuicr` plugin requires the `tuicr` executable. Launching a new pane also requires one supported multiplexer; the preference is Herdr, tmux, Zellij, cmux, then Rex. The Herdr wrapper additionally requires `jq`.

This plugin adapts the upstream [`tuicr` skill](https://github.com/agavra/tuicr/tree/main/skills/tuicr) and includes its wrapper scripts under the upstream MIT license.
