# start-session

Start a work session already knowing what you learned last time. Before any code, this skill searches your markdown knowledge vault for prior gotchas, patterns, and decisions tied to the project and task, and surfaces them. If you are a developer working in git and want to, it can also open an isolated worktree - but that step is optional, so it works just as well in the desktop app, in a chat, or on a folder of documents.

It is the read half of a knowledge loop. [end-session](../end-session) is the write half.

## Setup

Nothing to configure if you ran [setup-vault](../setup-vault) first - `start-session` finds your vault through the `~/.agent-vault` pointer file it wrote. Haven't run it yet? Do that once.

The vault is just a folder of markdown files. `start-session` searches it directly - no index, no database, and no extra tools to install. It uses ripgrep if you happen to have it, and otherwise falls back to the agent's own built-in file search, so it works on a bare machine (including a fresh Windows box).

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

1. Finds your vault (via `~/.agent-vault`, a `VAULT` env var, or the `~/vault` default) and figures out the project and task.
2. Reads the project's note in full (status, active work, known gotchas, architecture).
3. Runs a couple of quick vault searches (gotchas + evals, last handoff) and reads only the high-relevance hits, capping at about three notes.
4. Surfaces the handful that actually apply, in a few bullets, then defers deeper searches to when you hit them.
5. Prints a short ready summary. If you are in a git repo and want isolation, it can open a branch and worktree so the work ships via a PR - optional, and skipped otherwise.

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
