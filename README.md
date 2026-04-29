# nvim-crepecommit

Thin wrapper. Reads your staged diff, writes your commit message.

<img width="1668" height="700" alt="image" src="https://github.com/user-attachments/assets/7b02aefb-9d07-4349-ac0d-9c34ff0a23be" />

## The Problem

You stage your changes. You open the commit buffer. You stare at it.
You know what you did. Writing it down in the right format is the boring part.

## How It Works

`git-commit-msg` pipes your staged diff into an AI CLI with a
[Conventional Commits](https://www.conventionalcommits.org) prompt. No session,
no tools, no round-trips — just the diff in, a message out.

```
git diff --cached  →  AI CLI  →  feat(auth): add token refresh on 401
```

The AI picks the type (`feat`, `fix`, `refactor`, etc.) and scope from
the files changed, writes the subject in imperative mood, and adds a body
only when the why isn't obvious from the diff alone.

`<leader>gC` opens a floating buffer with a spinner while it generates.
When it lands, the buffer is editable — fix anything before confirming.
`<CR>` inserts into your gitcommit buffer or yanks to clipboard if you're
not in one. `q` or `<Esc>` to bail.

## Supported AI Providers

This plugin works with two AI CLI tools:

| | [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | [opencode](https://opencode.ai) |
|---|---|---|
| **Script** | `git-commit-msg` | `opencode-git-commit-msg` |
| **Models** | Anthropic (Claude) | 75+ providers (GLM, Kimi, Qwen, DeepSeek, etc.) |
| **Setup** | Just works | Provider setup required |
| **nvim spec** | `nvim/git.lua` | `nvim/opencode-git.lua` |
| **Inline skill** | `claude-plugin/` | `opencode/skills/` |

## Installation

### 1. Install the script for your chosen AI CLI

**Claude Code** (Anthropic, no config needed):
```bash
cp git-commit-msg ~/.local/bin/git-commit-msg
chmod +x ~/.local/bin/git-commit-msg
```

**opencode** (any model, provider setup required):
```bash
cp opencode-git-commit-msg ~/.local/bin/opencode-git-commit-msg
cp opencode-setup-provider ~/.local/bin/opencode-setup-provider
chmod +x ~/.local/bin/opencode-git-commit-msg
chmod +x ~/.local/bin/opencode-setup-provider
```

### 2. Set up provider (opencode only)

```bash
# Show current config
opencode-setup-provider --show

# Choose a provider
opencode-setup-provider --provider opencode-go   # GLM-5.1, Kimi K2.6, Qwen 3.6, DeepSeek V4 ($5/mo)
opencode-setup-provider --provider anthropic     # Claude models
opencode-setup-provider --provider openai        # GPT models
opencode-setup-provider --provider ollama        # Local models
```

See all [opencode providers](https://opencode.ai/docs/providers).

**GLM-5.1**: Subscribe to [OpenCode Go](https://opencode.ai/go) ($5 first month, then $10/mo).

### 3. Add the nvim spec

```lua
-- For Claude Code
{ import = "plugins.git" }

-- For opencode
{ import = "plugins.opencode-git" }
```

The keymap is `<leader>gC`. No other setup required.

## Files

```
git-commit-msg              Claude Code script
opencode-git-commit-msg     opencode script (defaults to GLM-5.1 via opencode-go)
opencode-setup-provider     Provider configuration script
nvim/git.lua                lazy.nvim spec — Claude Code
nvim/opencode-git.lua       lazy.nvim spec — opencode
claude-plugin/              Claude Code /git-commit skill
opencode/skills/            opencode /git-commit skill
```

## Inline Skills

Both AI CLIs have `/git-commit` skill support:

- **Claude Code**: `claude-plugin/plugins/git-commit/SKILL.md`
- **opencode**: `opencode/skills/git-commit/SKILL.md`

Generate commit messages from within a session instead of triggering the nvim plugin.