---
name: end-session
description: End a session - write a structured session log to your markdown vault (summary, changes, decisions, gotchas, evals, next steps, handoff), turn non-obvious learnings into evals with testable criteria, promote reusable gotchas, clean up processes, and ship the work as a PR. Use when the user says end-session, /end-session, "wrap up", "ship it", or is done with a task.
---

# End Session

End a session cleanly: log what happened to your vault in clear, named sections, turn what you learned into evals a future session can check itself against, clean up anything running, and ship the work as a pull request. The vault is a plain folder of markdown files - no database or index involved.

## Find the vault

Resolve the vault path in this order, stopping at the first that exists:

1. The `VAULT` environment variable, if set and non-empty.
2. The pointer file `~/.agent-vault` (written by `setup-vault`) - the absolute path is its first non-empty line.
3. The default `~/vault`.

Resolve `~`/home yourself so this works on Windows, macOS, and Linux. If none exist, tell the user to run `setup-vault` and still finish shipping the work.

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
pkill -f "$SESSION_DIR.*vite"      2>/dev/null || true
pkill -f "$SESSION_DIR.*next"      2>/dev/null || true
pkill -f "$SESSION_DIR.*tsx watch" 2>/dev/null || true
pkill -f "$SESSION_DIR.*nodemon"   2>/dev/null || true
# containers brought up from this dir
[ -f "$SESSION_DIR/docker-compose.yml" ] && (cd "$SESSION_DIR" && docker compose down 2>/dev/null || true)
```

### 4. Write the session log

Save to `<vault>/sessions/<project>-<YYYY-MM-DD>-<HHMMSS>.md`, following the template in `<vault>/sessions/_template.md` (shown below). Facts, not narrative. Only list files that matter. Fill in every section you have something for; drop a section entirely if it is genuinely empty rather than padding it.

```markdown
---
project: <project>
date: <YYYY-MM-DD>
type: <feature | fix | chore | research | planning>
outcome: <shipped | pr-created | ongoing | discarded>
---

# <project> - <one-line summary of what was done>

## Session summary
<2-3 sentences: the goal and what was accomplished>

## Changes
- `path/to/file` - <what changed and why>

## Decisions
- <choice made and why, not the alternative>

## Gotchas
- <something that bit you and how to avoid it next time. Trigger: when this applies.>

## Evals
- <the learning in one line. Eval criteria: a concrete, testable check that
  proves a future session has internalized it.>

## Next steps
- [ ] <what comes next>

## Handoff
<anything the next session needs to know immediately to pick this up>
```

Figure out the Gotchas and Evals yourself - do not ask the user. Review the session for problems that took several attempts, approaches that failed first, non-obvious behavior, patterns worth repeating, and corrections the user made. Only capture the non-obvious ones; if a routine session taught nothing new, leave those sections empty rather than forcing them.

Keep each eval atomic: one lesson, one criterion. If you are checking three things, that is three evals, not one. Write the "Eval criteria" as a binary, observable check - "given X, expect Y" - never a 1-5 scale or a vibe like "handles errors well". Binary is what makes it checkable later.

### 5. Promote only the durable evals to their own note

The `## Evals` section above is the full record - every eval for this session already lives there inline. Do not create a file for each one, or the `evals/` folder becomes noise. Promote to a standalone note only the few that are durable and cross-session: the ones you will almost certainly hit again on a later session. Most sessions promote zero or one, and that is correct. If an existing eval already covers it, update that file instead of adding a near-duplicate.

For each one you promote, write `<vault>/evals/<project>-<YYYY-MM-DD>-<HHMMSS>.md`, following `<vault>/evals/_template.md` (shown below). It is the durable artifact a future `start-session` surfaces before the same mistake can recur.

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

## Expected
<what should have happened / the correct approach>

## Actual
<what actually happened: the wrong approach, the error, the friction>

## Eval criteria
<a binary, observable check that proves a future session learned this>

## Applies to
<project-specific or global? when should a future session watch for this?>
```

Rules: keep each eval atomic (one lesson, one binary criterion). If nothing durable was learned, promote nothing - the inline section is enough.

### 6. Promote reusable gotchas

So a future `start-session` resurfaces them:

- **Project-specific** gotcha -> append to the project note at `<vault>/projects/<project>/README.md`. If that project folder does not exist yet, create it by copying `<vault>/projects/_template/`, then fill in the note:
  ```markdown
  ### Gotchas
  - [DATE] **<issue>**: <what happened and the fix>. _Trigger: <when this applies>_
  ```
- **Global** (tooling, workflow, cross-project) -> add it under `<vault>/knowledge/` instead.

### 7. Handle the worktree

The user should commit and push BEFORE this step to keep the work. Once the PR is up (or the work is pushed), retire the worktree:

```bash
git worktree remove "$(pwd)"   # run from, or pass, the worktree path; then cd back to the main repo
```

### 8. Confirm completion

```markdown
## Session ended
- Project: <name>
- Session log: <vault>/sessions/<filename>
- Evals written: <N> (<titles>) | None (routine session)
- Gotchas promoted: <N into project note or knowledge, or "none">
- Cleanup: done
- PR: <link, or "none">
```

## Shipping the work (when the user asks to commit and push)

```bash
git add -A
git commit -m "<type>: <description>"          # feat / fix / chore
git push -u origin HEAD
gh pr create --fill --base main
```

Give the PR a title and a body a reviewer can follow: a short summary, the notable changes, and how it was verified. Do not merge unless the user asks.
