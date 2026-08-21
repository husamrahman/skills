# end-session

Wrap up a work session by writing back what it taught you. This skill captures the session as a structured note in your markdown vault, in clear named sections - summary, changes, decisions, gotchas, evals, next steps, handoff - turns each non-obvious learning into an eval with a testable criterion, then commits, pushes, and opens a PR.

It is the write half of a knowledge loop. [start-session](../start-session) is the read half: it surfaces these notes at the start of your next task.

## Setup

Nothing to configure if you ran [setup-vault](../setup-vault) - `end-session` writes to the vault recorded in `~/.agent-vault` (or a `VAULT` env var, or the `~/vault` default). Plain markdown files, no index to maintain.

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
2. Writes a structured session log to `<vault>/sessions/` with these sections: **Session summary, Changes, Decisions, Gotchas, Evals, Next steps, Handoff**.
3. Turns each non-obvious learning into an eval under `<vault>/evals/` with a testable **Eval criteria** line, so a future session can check itself, not just read prose.
4. Promotes reusable gotchas into the project note (`projects/`) or, if global, into `knowledge/`.
5. Commits, pushes, and opens a PR (never merges on its own), then retires the worktree.

## Example

```
you > /end-session

agent > Wrote sessions/acme-api-2026-08-16-142230.md
        Session summary: token-bucket rate limiter on the public API.
        Gotcha: limiter must sit AFTER auth middleware or anon traffic bypasses it.
          Trigger: any time you touch the middleware chain.
        Wrote evals/acme-api-2026-08-16-142230.md
        Eval: rate-limit tests need a no-auth request case.
          Eval criteria: a request with no auth header is limited, not exempted.
        Promoted the gotcha into the acme-api project note.
        Stopped the dev server. Opened PR #128.
```

The next `start-session` on this project will surface that gotcha before you touch the middleware again.
