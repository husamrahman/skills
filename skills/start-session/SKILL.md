---
name: start-session
description: Start a fresh session in an isolated worktree, loading context from a markdown knowledge vault first - the project note, known gotchas, and the last handoff. Use when the user says start-session, /start-session, "start a session", or begins a new task.
---

# Start Session

Start a new Claude Code (or Codex) session in a fresh, up-to-date git worktree, with the context you already earned loaded first: the project's note, its known gotchas, and the last handoff.

## Setup

Point the skill at your notes. A vault is any folder of markdown files; an Obsidian vault works well. The paths below follow an Obsidian-style layout (`01-projects/`, `07-logs/sessions/`); adjust them to your own.

```bash
export VAULT="${VAULT:-$HOME/vault}"
```

Context loading uses `qmd` (hybrid keyword + semantic search with relevance scores) when installed, and falls back to `ripgrep`.

## Process

### 1. Create the worktree

Start from an up-to-date base branch and create an isolated worktree so commits here do not touch `main` until a PR is merged.

```bash
git fetch origin
git switch main 2>/dev/null || git switch master
git pull --ff-only

PROJECT="$(basename "$(git rev-parse --show-toplevel)")"
STAMP="$(date +%Y%m%d-%H%M%S)"
WORKTREE="../${PROJECT}-session-${STAMP}"
git worktree add -b "session/${STAMP}" "$WORKTREE"
```

Rename the branch to a descriptive `feature/`, `fix/`, or `chore/` name at commit time, based on what you actually did.

### 2. Change to the worktree

`cd` into `$WORKTREE`. Do all work here, not in the main checkout.

### 3. Load context

Keep startup context minimal. Your project's config (CLAUDE.md / AGENTS.md) already covers conventions and architecture, so do not re-read those.

```bash
PROJECT_DIR=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
```

#### Read the project note (the only required read)

```bash
find "$VAULT/01-projects/" -maxdepth 2 -name "*.md" ! -name "_*" ! -name "README*" 2>/dev/null | grep -i "$PROJECT_DIR" | head -1
```

Read the full note: status, active work, gotchas, architecture.

#### Quick vault check (2 queries max)

**a) Project gotchas (keyword, fast)**

```bash
qmd search "gotcha $PROJECT_DIR" --json 2>/dev/null
# fallback: rg -i -l "gotcha" "$VAULT" | grep -i "$PROJECT_DIR" | head -3
```

Read results scoring > 0.5. Skip the rest.

**b) Last handoff (only if continuing prior work)**

```bash
qmd query "$PROJECT_DIR handoff next steps" --json 2>/dev/null
```

Read the top result only if it scores > 0.4. Skip entirely for fresh tasks.

Rules: read the full doc (`qmd get`) for hits > 0.5, skip anything below, and read at most 3 docs at startup. Be selective.

#### During the session

Defer deeper searches to when you actually need them:

- Before implementing something complex: `qmd query "how does X work in $PROJECT_DIR"`
- On an unexpected error: `qmd search "gotcha [specific thing]"`
- When making an architecture decision: `qmd query "$PROJECT_DIR architecture decision X"`

### 4. Present a ready summary

```markdown
## Session started
- Project: <project>     Branch: <branch>     Worktree: <path>
- Previous context: <1-2 sentences from the last session log, or "fresh start">
- Project note: <loaded | not found>
- Gotchas: <count, or none found>
- Last handoff: <one line, or fresh start>
```

You are in an isolated worktree with the vault's context loaded. When done, commit and push, then run `end-session` to log the session and capture learnings.

## Notes

- No prompts. Create the session and get to work.
- Always work in the worktree, not the main repo.
- Pick the branch type at commit time from what the change turned out to be.
