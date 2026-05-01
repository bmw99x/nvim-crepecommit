# nvim-crepecommit-opencode

Thin wrapper using opencode CLI. Reads your staged diff, writes your commit message.

## ⇁ The Problem

You stage your changes. You open the commit buffer. You stare at it.
You know what you did. Writing it down in the right format is the boring part.

## ⇁ How It Works

`opencode-git-commit-msg` pipes your staged diff into `opencode` with a
[Conventional Commits](https://www.conventionalcommits.org) prompt. No session,
no tools, no round-trips — just the diff in, a message out.

```
git diff --cached  →  opencode  →  feat(auth): add token refresh on 401
```

Opencode picks the type (`feat`, `fix`, `refactor`, etc.) and scope from
the files changed, writes the subject in imperative mood, and adds a body
only when the why isn't obvious from the diff alone.

`<leader>gC` opens a floating buffer with a spinner while it generates.
When it lands, the buffer is editable — fix anything before confirming.
`<CR>` inserts into your gitcommit buffer or yanks to clipboard if you're
not in one. `q` or `<Esc>` to bail.

## ⇁ Requirements

- [opencode CLI](https://opencode.ai) — must be in `$PATH` as `opencode`
- Neovim 0.10+
- `opencode-git-commit-msg` script somewhere in `$PATH`

## ⇁ Provider Configuration

opencode supports multiple AI providers. Configure your preferred provider:

```bash
# Show current provider
opencode-setup-provider --show

# Set provider (anthropic, openai, ollama, custom)
opencode-setup-provider --provider anthropic
opencode-setup-provider --provider ollama

# Reset to default
opencode-setup-provider --reset
```

For custom providers, set via environment variables:

```bash
export OPENCODE_PROVIDER=custom
export OPENCODE_API_BASE=https://api.example.com/v1
export OPENCODE_MODEL=your-model
```

## ⇁ Installation

**1. Install the scripts**

```bash
cp opencode-git-commit-msg ~/.local/bin/opencode-git-commit-msg
cp opencode-setup-provider ~/.local/bin/opencode-setup-provider
chmod +x ~/.local/bin/opencode-git-commit-msg
chmod +x ~/.local/bin/opencode-setup-provider
```

**2. Add the nvim spec** to your lazy.nvim config (drop `nvim/opencode-git.lua` into
`lua/plugins/` or copy the relevant spec into your existing git plugin file):

```lua
-- lazy.nvim
{ import = "plugins.opencode-git" }
```

**3. Configure your provider**

```bash
opencode-setup-provider --provider anthropic  # or openai, ollama, etc.
```

The keymap is `<leader>gC`. No other setup required.

## ⇁ Files

```
opencode-git-commit-msg    shell script — the AI call lives here
opencode-setup-provider    script to configure default AI provider
opencode/skills/           opencode skill for inline commit generation
nvim/opencode-git.lua      lazy.nvim spec — floating UI + keymap
nvim/git.lua               original claude version (still included)
```

## ⇁ opencode Skill

If you use opencode, the `opencode/skills/git-commit/SKILL.md` provides the
`/git-commit` skill that does the same thing inline — reads staged changes
and generates the message for you to paste or commit directly.

To use the skill, ensure it's in your opencode skills directory (typically
`~/.config/opencode/skills/`).
