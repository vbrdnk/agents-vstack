# Personal Agent Plugins

A personal marketplace of reusable AI agent skills.

| Harness | How it loads the skills | Invoke a skill |
| --- | --- | --- |
| Claude Code | Plugin marketplace (`.claude-plugin/`) | `/git:commit` |
| Codex | Plugin marketplace (`.agents/plugins/marketplace.json`) | `$git:commit`, or pick from `/skills` |
| OpenCode 2.x | `skills` path in `opencode.json` pointing at a clone | `@commit` |

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

The Skills column uses Claude Code names. The `principles`, `practices`, `writing`, and `tuicr` skills can trigger on their own. The `git`, `thinking`, and `session` skills run only when you invoke them, in every harness: Claude Code and OpenCode read `disable-model-invocation: true`, and Codex reads `agents/openai.yaml` in each skill.

## Claude Code

### Install

Add the marketplace from GitHub:

```bash
claude plugin marketplace add vbrdnk/agents-vstack
```

Install any of the plugins:

```bash
claude plugin install git@agents-vstack
claude plugin install tuicr@agents-vstack
claude plugin install principles@agents-vstack
claude plugin install thinking@agents-vstack
claude plugin install practices@agents-vstack
claude plugin install writing@agents-vstack
claude plugin install session@agents-vstack
```

Run `/reload-plugins` after installation. Restart Claude Code only if the skills still do not appear.

### Update installed plugins

Plugin versions are pinned by each `plugin.json`. Bump the affected version before publishing an update, then run:

```bash
claude plugin marketplace update agents-vstack
claude plugin update git@agents-vstack
claude plugin update tuicr@agents-vstack
claude plugin update principles@agents-vstack
claude plugin update thinking@agents-vstack
claude plugin update practices@agents-vstack
claude plugin update writing@agents-vstack
claude plugin update session@agents-vstack
```

Only run the `plugin update` command for plugins whose versions changed.

#### Migrating from `vbrdnk-claude-plugins`

The marketplace was renamed from `vbrdnk-claude-plugins` to `agents-vstack`. Older installs also had separate `commit` and `review-handoff` plugins, which are now skills in the `git` plugin, and `/tuicr:tuicr` is now `/tuicr:review`. Uninstall each plugin you had from the old marketplace (`claude plugin list` shows them), remove the old marketplace, then add it again under the new name and install the plugins you want:

```bash
claude plugin uninstall tuicr@vbrdnk-claude-plugins   # repeat for each installed plugin
claude plugin marketplace remove vbrdnk-claude-plugins
claude plugin marketplace add vbrdnk/agents-vstack
claude plugin install git@agents-vstack
```

## Codex

### Install

Add the marketplace from GitHub, then install the plugins you want:

```bash
codex plugin marketplace add vbrdnk/agents-vstack
codex plugin add git@agents-vstack
codex plugin add tuicr@agents-vstack
codex plugin add principles@agents-vstack
codex plugin add thinking@agents-vstack
codex plugin add practices@agents-vstack
codex plugin add writing@agents-vstack
codex plugin add session@agents-vstack
```

Start a new Codex session to load the skills. Skills are named `plugin:skill`, the same as in Claude Code.

### Update

```bash
codex plugin marketplace upgrade agents-vstack
```

Codex caches each plugin by the `version` in its `plugin.json`, so bump the version before publishing an update.

## OpenCode

OpenCode 2.x reads skills from any folder listed in the `skills` array of its config. Clone this repository and point OpenCode at the `plugins` folder:

```bash
git clone https://github.com/vbrdnk/agents-vstack.git ~/git/agents-vstack
```

Add the path to `~/.config/opencode/opencode.json`:

```json
{
  "skills": ["~/git/agents-vstack/plugins"]
}
```

OpenCode finds every `SKILL.md` under that folder. To update, run `git pull` in the clone. Skills are named by their directory, without the plugin prefix, so `/git:commit` in Claude Code is `@commit` in OpenCode.

## Validate locally

From the repository root:

```bash
claude plugin validate . --strict
```

Codex has no validate command. Install the local marketplace into a throwaway Codex home and list what it sees:

```bash
(
  export CODEX_HOME="$(mktemp -d)"
  codex plugin marketplace add ./
  codex plugin list
)
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
