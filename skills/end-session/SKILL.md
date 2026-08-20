---
name: end-session
description: End a session - write a structured session log to your markdown vault, extract non-obvious learnings as evals with testable criteria, promote reusable gotchas, clean up processes, and ship the work as a PR. Use when the user says end-session, /end-session, "wrap up", "ship it", or is done with a task.
---

# End Session

End a session cleanly: log what happened to your vault, extract learnings as evals a future session can check itself against, clean up anything running, and ship the work as a pull request.

## Setup

The paths below follow an Obsidian-style vault (`07-logs/sessions/`, `07-logs/evals/`, `01-projects/`, `03-knowledge/`); adjust to your own layout.

```bash
export VAULT="${VAULT:-$HOME/vault}"
```

## Process

### 1. Identify the session type

```bash
git worktree list | grep "$(pwd)" && echo "worktree" || echo "main"
```

### 2. Gather session context

- `git diff --stat` and `git log --oneline -10`
- Files modified this session
- The task list / todos from this conversation

### 3. Clean up processes and services

Stop dev servers, watchers, and containers you started from this worktree. Do not blanket-kill ports or touch processes you did not start.

```bash
SESSION_DIR="$(pwd)"
pkill -f "$SESSION_DIR.*vite"     2>/dev/null || true
pkill -f "$SESSION_DIR.*next"     2>/dev/null || true
pkill -f "$SESSION_DIR.*tsx watch" 2>/dev/null || true
pkill -f "$SESSION_DIR.*nodemon"  2>/dev/null || true
# containers brought up from this dir
[ -f "$SESSION_DIR/docker-compose.yml" ] && (cd "$SESSION_DIR" && docker compose down 2>/dev/null || true)
```

### 4. Write the session log

Save to `$VAULT/07-logs/sessions/<project>-<YYYY-MM-DD>-<HHMMSS>.md`. Facts, not narrative. Only list files that matter. Use `[[backlinks]]` to connect to the project note if your vault uses them.

```markdown
---
project: <project>
date: <YYYY-MM-DD>
type: <feature | fix | chore | research | planning>
outcome: <shipped | pr-created | ongoing | discarded>
---

# <project> - <one-line summary of what was done>

## What happened
<2-3 sentences: the goal and what was accomplished>

## Changes
- `path/to/file` - <what changed and why>

## Decisions
- <choice made and why, not the alternative>

## Next steps
- [ ] <what comes next>

## PR
<link if created, or "No PR">

## Handoff
<anything the next session needs to know immediately>
```

### 5. Extract learnings as evals

Figure out the learnings yourself; do not ask the user. Review the session for problems that took several attempts, approaches that failed first, non-obvious gotchas, patterns worth repeating, and corrections the user made.

For each one worth keeping, write an eval to `$VAULT/07-logs/evals/<project>-<YYYY-MM-DD>-<HHMMSS>.md`:

```markdown
---
project: <project>
date: <YYYY-MM-DD>
category: <gotcha | pattern | correction | tool-discovery | architecture>
severity: <low | medium | high>
---

# <short title of the learning>

## Scenario
<the task, and what was attempted>

## Expected behavior
<what should have happened / the correct approach>

## Actual behavior
<what actually happened: the wrong approach, the error, the friction>

## Resolution
<how it was fixed / what the right answer turned out to be>

## Eval criteria
<a concrete, testable check that a future session has learned this>

## Applies to
<project-specific or global? when should a future session watch for this?>
```

Rules: only write evals for non-obvious things. If nothing was learned, write nothing; do not force it. The "Eval criteria" line is the point, so make it a testable statement, not a vibe.

### 6. Update project knowledge

If a learning is project-specific, append it to the project note in `$VAULT/01-projects/`:

```markdown
### Gotchas
- [DATE] **<issue>**: <what happened and the fix>. _Trigger: <when this applies>_
```

If it is global (tooling, workflow, cross-project), add it under `$VAULT/03-knowledge/` instead.

### 7. Re-index (optional)

If your vault has a search index, refresh it so the new notes are findable next session.

```bash
qmd update && qmd embed 2>/dev/null || true   # incremental; skip if you do not use qmd
```

### 8. Handle the worktree

The user should commit and push BEFORE this step to keep the work. Once the PR is up (or the work is pushed), retire the worktree:

```bash
git worktree remove "$(pwd)"   # run from, or pass, the worktree path; then cd back to the main repo
```

### 9. Confirm completion

```markdown
## Session ended
- Project: <name>
- Session log: $VAULT/07-logs/sessions/<filename>
- Evals written: <N> (<titles>) | None (routine session)
- Cleanup: done
```

## Shipping the work (when the user asks to commit and push)

```bash
git add -A
git commit -m "<type>: <description>"          # feat / fix / chore
git push -u origin HEAD
gh pr create --fill --base main
```

Give the PR a title and a body a reviewer can follow: a short summary, the notable changes, and how it was verified. Do not merge unless the user asks.
