<img width="1560" height="698" alt="image" src="https://github.com/user-attachments/assets/801bb3e6-05be-41fa-98b8-6383b24ec9f6" /># nvim-crepecommit

Thin wrapper. Reads your staged diff, writes your commit message.
<img width="1668" height="700" alt="image" src="https://github.com/user-attachments/assets/7b02aefb-9d07-4349-ac0d-9c34ff0a23be" />


## ⇁ The Problem

You stage your changes. You open the commit buffer. You stare at it.
You know what you did. Writing it down in the right format is the boring part.

## ⇁ How It Works

`git-commit-msg` pipes your staged diff into `claude -p` with a
[Conventional Commits](https://www.conventionalcommits.org) prompt. No session,
no tools, no round-trips — just the diff in, a message out.

```
git diff --cached  →  claude -p  →  feat(auth): add token refresh on 401
```

Claude picks the type (`feat`, `fix`, `refactor`, etc.) and scope from
the files changed, writes the subject in imperative mood, and adds a body
only when the why isn't obvious from the diff alone.

`<leader>gC` opens a floating buffer with a spinner while it generates.
When it lands, the buffer is editable — fix anything before confirming.
`<CR>` inserts into your gitcommit buffer or yanks to clipboard if you're
not in one. `q` or `<Esc>` to bail.

## ⇁ Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) — must be
  in `$PATH` as `claude`
- Neovim 0.10+
- `git-commit-msg` script somewhere in `$PATH`

## ⇁ Installation

**1. Install the script**

```bash
cp git-commit-msg ~/.local/bin/git-commit-msg
chmod +x ~/.local/bin/git-commit-msg
```

**2. Add the nvim spec** to your lazy.nvim config (drop `nvim/git.lua` into
`lua/plugins/` or copy the relevant spec into your existing git plugin file):

```lua
-- lazy.nvim
{ import = "plugins.git" }
```

The keymap is `<leader>gC`. No other setup required.

## ⇁ Files

```
git-commit-msg          shell script — the AI call lives here
nvim/git.lua            lazy.nvim spec — floating UI + keymap
claude-plugin/          Claude Code skill (/git-commit in Claude sessions)
```

## ⇁ Claude Code Skill

If you use Claude Code, the plugin registers a `/git-commit` skill that does
the same thing inline — reads staged changes and generates the message for you
to paste or commit directly.
