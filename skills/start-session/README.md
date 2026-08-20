# start-session

Start a work session already knowing what you learned last time. Before any code, this skill searches your markdown knowledge vault for prior gotchas, patterns, and decisions tied to the project and task, surfaces them, then opens an isolated git worktree to work in.

It is the read half of a knowledge loop. [end-session](../end-session) is the write half.

## Setup

Point it at your notes (any folder of markdown, an Obsidian vault is ideal):

```bash
export VAULT="${VAULT:-$HOME/vault}"
```

Optional: install a search tool over the vault. The skill uses `qmd` (hybrid keyword + semantic) when present and falls back to `ripgrep`.

## Install

Claude Code:

```bash
cp -r start-session ~/.claude/skills/     # user-scoped (every project)
# or
cp -r start-session .claude/skills/       # this project only
```

Codex:

```bash
cp -r start-session ~/.codex/skills/
```

## Use

```
/start-session
```

Or say "start a session on the checkout bug."

## What happens

1. Figures out the project and task.
2. Reads the project's note in full (status, active work, known gotchas, architecture).
3. Runs up to two scored vault searches (gotchas, last handoff) and reads only the high-relevance hits, capping at about three docs.
4. Surfaces the handful that actually apply, in a few bullets, then defers deeper searches to when you hit them.
5. Opens a branch and worktree so the work ships via PR, and prints a short ready summary.

## Example

```
you > /start-session   (working on acme-api, adding rate limiting)

agent > From your vault:
        - gotcha: acme-api's middleware order matters; auth must run before limiter.
        - decision (2026-05): chose token-bucket over fixed-window for burst traffic.
        - last session on this area left a TODO to add per-key limits.
        Opened branch feature/rate-limiting, worktree ../acme-api-rate-limiting.
        Starting there with that context in mind.
```

When you finish, run [end-session](../end-session) to write this session's learnings back into the vault.
