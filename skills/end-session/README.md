# end-session

Wrap up a work session by writing back what it taught you. This skill captures the session as a structured note in your markdown vault (what got done, lessons learned, gotchas, decisions), then commits, pushes, and opens a PR.

It is the write half of a knowledge loop. [start-session](../start-session) is the read half: it surfaces these notes at the start of your next task.

## Setup

```bash
export VAULT="${VAULT:-$HOME/vault}"
```

## Install

Claude Code:

```bash
cp -r end-session ~/.claude/skills/     # user-scoped (every project)
# or
cp -r end-session .claude/skills/       # this project only
```

Codex:

```bash
cp -r end-session ~/.codex/skills/
```

## Use

```
/end-session
```

Or say "wrap up and capture what we learned."

## What happens

1. Identifies the session type, reviews the diff, and stops anything the session started.
2. Writes a structured session log to `$VAULT/07-logs/sessions/` (What happened, Changes, Decisions, Next steps, Handoff).
3. Extracts each non-obvious learning as an eval under `$VAULT/07-logs/evals/` with a testable "Eval criteria" line, so a future session can check itself, not just read prose.
4. Promotes reusable gotchas into the project note (`01-projects/`) or, if global, into `03-knowledge/`.
5. Commits, pushes, and opens a PR (never merges on its own), then retires the worktree.

## Example

```
you > /end-session

agent > Wrote 07-logs/sessions/acme-api-2026-08-16-142230.md:
        Done: token-bucket rate limiter on the public API.
        Wrote 07-logs/evals/acme-api-2026-08-16-142230.md:
        Gotcha: limiter must sit AFTER auth middleware or anon traffic bypasses it.
        Eval criteria: a request with no auth header is rate-limited, not exempted.
        Appended the gotcha to the acme-api project note.
        Stopped the dev server. Opened PR #128.
```

The next `start-session` on this project will surface that gotcha before you touch the middleware again.
