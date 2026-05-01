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
`<CR>` runs `git commit` with the message. A second spinner shows while it
commits. `q` or `<Esc>` to bail.

`<leader>gW` does the same but with `--no-verify` flag to bypass commit hooks.

## Supported AI Providers

This plugin works with two AI CLI tools:

|                 | [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | [opencode](https://opencode.ai)                 |
| --------------- | ------------------------------------------------------------- | ----------------------------------------------- |
| **Script**      | `git-commit-msg`                                              | `opencode-git-commit-msg`                       |
| **Models**      | Anthropic (Claude)                                            | 75+ providers (GLM, Kimi, Qwen, DeepSeek, etc.) |
| **nvim config** | `command = "git-commit-msg"`                                  | `command = "opencode-git-commit-msg"`           |

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

> **Note:** Ensure `~/.local/bin` is in your PATH. Add `export PATH="$HOME/.local/bin:$PATH"` to `~/.zshrc` if needed. Restart terminal or run `source ~/.zshrc` after installation.

### 2. Add the nvim spec

Drop `nvim/git.lua` into your lazy.nvim config:

```lua
-- lazy.nvim
{ import = "plugins.git" }
```

### 3. Configure (optional)

The plugin supports configuration:

```lua
-- In your nvim config, call setup() to configure:
require("plugins.git").setup({
  command = "opencode-git-commit-msg",  -- or "git-commit-msg"
  bypass_hooks = false,                  -- default: false
})
```

**Default:** `opencode-git-commit-msg` (DeepSeek V4 Flash via opencode-go)

**Keybinds:**

- `<leader>gC` — Generate commit message
- `<leader>gW` — Generate commit message with `--no-verify` (skip hooks)

### 4. Set up provider (opencode only)

```bash
# Show current config
opencode-setup-provider --show

# Choose a provider
opencode-setup-provider --provider opencode-go   # DeepSeek V4 Flash, Kimi K2.6, Qwen 3.6, GLM-5.1 ($5/mo)
opencode-setup-provider --provider anthropic     # Claude models
opencode-setup-provider --provider openai        # GPT models
opencode-setup-provider --provider ollama        # Local models
```

See all [opencode providers](https://opencode.ai/docs/providers).

**DeepSeek V4 Flash**: Subscribe to [OpenCode Go](https://opencode.ai/go) ($5 first month, then $10/mo).

The keymap is `<leader>gC`. No other setup required.

## Files

```
git-commit-msg              Claude Code script
opencode-git-commit-msg     opencode script (defaults to DeepSeek V4 Flash via opencode-go)
opencode-setup-provider     Provider configuration script
opencode.json               opencode config with all tools disabled
nvim/git.lua                lazy.nvim spec with configurable command
claude-plugin/              Claude Code /git-commit skill
opencode/skills/            opencode /git-commit skill
```

## Inline Skills

Both AI CLIs have `/git-commit` skill support:

- **Claude Code**: `claude-plugin/plugins/git-commit/SKILL.md`
- **opencode**: `opencode/skills/git-commit/SKILL.md`

Generate commit messages from within a session instead of triggering the nvim plugin.

## LazyGit Integration

Use the script directly from lazygit's commit panel to generate messages without
leaving the TUI.

**Requirements:** the script must be in `$PATH` (see Installation step 1).

Add this to your lazygit config (`~/.config/lazygit/config.yml` on Linux,
`~/Library/Application Support/lazygit/config.yml` on macOS):

```yaml
customCommands:
  - key: "<c-g>"
    context: "commitMessage"
    command: "opencode-git-commit-msg"
    loadingText: "AI generating commit message..."
    description: "AI generate commit message"
  - key: "<c-w>"
    context: "files"
    command: "opencode-git-commit-msg | git commit --no-verify -F -"
    loadingText: "AI generating commit message..."
    description: "AI commit (skip hooks)"
```

Then in lazygit: stage files, press `c` to open the commit panel, press
`Ctrl+G`. The generated message fills the commit buffer — edit before
confirming.
