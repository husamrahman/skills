---
name: start-session
description: Start a fresh session by loading context from a markdown knowledge vault first - the project note, known gotchas, and the last handoff. Optionally isolate code work in a git worktree. Use when the user says start-session, /start-session, "start a session", or begins a new task.
---

# Start Session

Start a new session with the context you already earned loaded first: the project's note, its known gotchas, and the last handoff. It reads a plain folder of markdown files - no database, no index, no extra tools required.

Loading that context is the whole point, and it works the same everywhere - a code repo, a folder of documents, the desktop app, or a chat. Isolating your work in a **git worktree is optional** and only for developers who want it: this skill never imposes git on you. If you are not working in a git repository - or you are on the desktop or web app, or working on documents rather than code - skip the worktree entirely and just start.

## Find the vault

Resolve the vault path in this order, and stop at the first that exists:

1. The `VAULT` environment variable, if set and non-empty.
2. The pointer file `~/.agent-vault` (written by `setup-vault`) - read the absolute path from its first non-empty line.
3. The default `~/vault`.

Resolve `~`/home yourself so this works on Windows, macOS, and Linux. If none of these resolve to a real folder, tell the user to run `setup-vault` first, then continue without vault context.

## Process

### 1. Load context

Keep startup context minimal. If the project has its own config (CLAUDE.md / AGENTS.md), it already covers conventions and architecture, so do not re-read those.

First, figure out what you are working on - the project name. In a git repo that is the repo folder name (`basename "$(git rev-parse --show-toplevel)"`); otherwise it is the name of the folder, document, or project the user is working in. You will use it to find the right notes.

#### Read the project note (the only required read)

Each project has its **own folder** under `projects/`, named after the project. Find the folder that matches and read its `README.md` in full - status, active work, gotchas, architecture. Skim any other notes in the folder if relevant.

```bash
# ripgrep/grep is handy but optional; your own file-search tools work just as well
ls "$VAULT/projects/" | grep -i "$PROJECT"          # a folder, e.g. acme-api/
# then read "$VAULT/projects/<match>/README.md"
```

If no folder matches, that is fine - it is a new project. Note it and move on (end-session will create `projects/<project>/` by copying `projects/_template/`).

#### Surface prior gotchas and the last handoff

Search the vault for anything relevant to this project and task, then read only what actually applies. Use ripgrep if it is installed; otherwise use your own built-in file search (grep/glob) over the vault folder - both work with no extra install, which matters on a fresh Windows machine.

A few quick searches are enough at startup:

- **Gotchas and evals for this project** - search `knowledge/`, `evals/`, and the project note for the project name plus "gotcha", and skim the "Eval criteria" lines of any matching evals.
  ```bash
  # if ripgrep is available:
  rg -l -i "gotcha|eval criteria" "$VAULT" | grep -i "$PROJECT" | head -3
  ```
- **Last handoff** - only if you are continuing prior work: find the most recent note mentioning this project and read its "Handoff" / "Next steps" sections. Session notes are named `<project>-<YYYY-MM-DD>-<HHMMSS>.md`, so the newest one sorts last by name - no need for time-based `ls` flags that differ across shells.
  ```bash
  ls "$VAULT/sessions/" | grep -i "$PROJECT" | sort | tail -1
  ```

Read at most ~3 notes at startup. Be selective: skim titles and summaries, open the full note only when it is clearly relevant.

#### During the session

Defer deeper searches to when you actually need them - search the vault the same way (ripgrep or your file tools):

- Before implementing something complex: look for how that area worked before.
- On an unexpected error: search for a matching gotcha.
- When making an architecture decision: search for the prior decision and its reasoning.

### 2. Optional: isolate code work in a git worktree

**Skip this unless all of these are true:** you are working in a git repository, on code, and you (or the user) want the changes on an isolated branch that ships via a pull request. If you are on the desktop or web app, not in a git repo, or working on documents, do not run any of this - just start work where you are. When in doubt, don't; you can always branch later at commit time.

When it does apply, start from an up-to-date base branch and create an isolated worktree so commits here do not touch `main` until a PR is merged:

```bash
git fetch origin
git switch main 2>/dev/null || git switch master
git pull --ff-only

PROJECT="$(basename "$(git rev-parse --show-toplevel)")"
STAMP="$(date +%Y%m%d-%H%M%S)"
WORKTREE="../${PROJECT}-session-${STAMP}"
git worktree add -b "session/${STAMP}" "$WORKTREE"
```

Then `cd` into the new worktree and do all work there, not in the main checkout. Rename the branch to a descriptive `feature/`, `fix/`, or `chore/` name at commit time, based on what you actually did.

### 3. Present a ready summary

```markdown
## Session started
- Project: <project>
- Previous context: <1-2 sentences from the last session log, or "fresh start">
- Project note: <loaded | not found>
- Gotchas / evals: <count, or none found>
- Last handoff: <one line, or fresh start>
```

If you opened a worktree, add one more line so the developer knows where they are:

```markdown
- Branch: <branch>     Worktree: <path>
```

You have the vault's context loaded and are ready to work. When you finish, run `end-session` to log the session and capture what you learned (and, if you are working in git, commit and push first).

## Notes

- No prompts for the context load - read the vault and get to work.
- No index to build or maintain - the vault is plain files, searched directly.
- The git worktree is opt-in, not the default. Most sessions - especially in the desktop or web app - never need one; only create one when you are in a git repo and isolation actually helps.
- If you do open a worktree, work in it and not the main repo, and pick the branch type at commit time from what the change turned out to be.
