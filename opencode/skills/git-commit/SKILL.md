---
name: git-commit
description: >
  Generate a conventional commit message from staged git changes.
  Use when user says "generate commit", "commit message", "what should I commit",
  or invokes /git-commit. Reads staged diff with git diff --cached.
---

Generate conventional commit message from staged changes.

## Steps

1. Run `git diff --cached` to get staged diff
2. Run `git branch --show-current` for branch/scope context
3. Analyze and generate message

## Format

```
type(scope): description

[optional body — only if changes are complex]
```

- **Types**: feat, fix, docs, style, refactor, perf, test, chore, ci, build
- **scope**: optional, derived from changed modules/dirs/files
- **description**: imperative mood, lowercase, no trailing period, ≤72 chars
- **body**: blank line after subject; only when "why" isn't obvious from diff

## Rules

- Output ONLY the commit message — no explanation, no alternatives, no markdown fences
- If nothing staged: say "No staged changes"
- Scope from most-affected directory/module, not the branch name
- Breaking changes: append `!` after type/scope and add `BREAKING CHANGE:` footer