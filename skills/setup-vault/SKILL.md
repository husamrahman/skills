---
name: setup-vault
description: Create a knowledge vault - a plain folder of markdown files on your computer - that the start-session and end-session skills read from and write to. Use when the user says setup-vault, /setup-vault, "set up my vault", "create a vault", or is starting out and has no vault yet. No Obsidian required.
---

# Setup Vault

Create the folder your session skills use as memory. A "vault" is nothing fancy: just a folder of markdown (`.md`) text files on your computer. You can open any of them in any editor. Obsidian is a nice free app for browsing and linking these notes, but it is optional and nothing here needs it.

Run this once, before your first `start-session`.

## Process

### 1. Pick a location

The default is `~/vault`. If the user keeps the default, nothing else needs configuring, because the session skills already look there.

```bash
export VAULT="${VAULT:-$HOME/vault}"
```

If the user wants it elsewhere (for example inside iCloud or Dropbox so it syncs across machines), set `VAULT` to that path instead before running the next step.

### 2. Create the vault

Run this one block. It makes the folders and seeds a short `_README.md` in each so the structure explains itself. It is safe to re-run; it will not overwrite files that already exist.

```bash
set -e
export VAULT="${VAULT:-$HOME/vault}"
mkdir -p "$VAULT/01-projects" "$VAULT/03-knowledge" "$VAULT/07-logs/sessions" "$VAULT/07-logs/evals"

# helper: write a file only if it does not already exist
seed() { [ -e "$1" ] || cat > "$1"; }

seed "$VAULT/README.md" <<'EOF'
# My Vault

A knowledge vault: a plain folder of markdown (.md) files my coding agent uses as
long-term memory. Nothing here is special. Open any file in any text editor.

- 01-projects/   one note per project (status, how it works, gotchas)
- 03-knowledge/  lessons that apply across projects
- 07-logs/
    sessions/    a log for each work session
    evals/       one note per lesson learned, with a testable check

The start-session and end-session skills read from and write to these folders.
Optional: open this folder in Obsidian (https://obsidian.md) to browse and link
notes visually. Not required.
EOF

seed "$VAULT/01-projects/_README.md" <<'EOF'
# Projects

One note per project you work on. Name the file after the project's repo folder
so start-session can find it (for a repo called acme-api, use acme-api.md).
Copy _template.md to start a new one.
EOF

seed "$VAULT/01-projects/_template.md" <<'EOF'
---
project: <repo-name>
status: active
---

# <Project>

## What it is
<one or two lines>

## How it is built
<stack, key folders, entry points>

## Gotchas
- <things that have bitten you, and how to avoid them>

## Decisions
- <choices made and why>

## Active work / next
- <what is in flight>
EOF

seed "$VAULT/03-knowledge/_README.md" <<'EOF'
# Knowledge

Lessons and gotchas not tied to a single project: tooling, workflow, cross-project
patterns. end-session drops global learnings here; start-session can surface them
on any project.
EOF

seed "$VAULT/07-logs/sessions/_README.md" <<'EOF'
# Session logs

end-session writes one dated note here per work session: what happened, what
changed, decisions, next steps, and a handoff for the next session. You do not
write these by hand.
EOF

seed "$VAULT/07-logs/evals/_README.md" <<'EOF'
# Evals

end-session writes one note here per non-obvious lesson, each with a testable
"Eval criteria" line. start-session surfaces the relevant ones before you start a
task, so the same mistake does not happen twice.
EOF

echo "Vault ready at $VAULT"
```

### 3. Make VAULT stick (only if you changed the default)

If you used the default `~/vault`, skip this. Otherwise add the export to your shell profile so every future session finds it:

```bash
echo 'export VAULT="/your/custom/path"' >> ~/.zshrc   # or ~/.bashrc
```

### 4. Confirm

Show the layout and tell the user they are ready:

```bash
find "$VAULT" -maxdepth 2 | sort
```

```markdown
## Vault ready
- Location: <VAULT>
- Folders: 01-projects, 03-knowledge, 07-logs/sessions, 07-logs/evals
- Next: run start-session in a project, then end-session when you finish.
  The vault fills itself in from there.
```

## Notes

- The leading underscore on `_README.md` and `_template.md` keeps `start-session` from mistaking them for project notes.
- Keep the default `~/vault` unless you have a reason not to; it means zero configuration.
- Want the notes to sync or back up? Point `VAULT` at a folder inside iCloud, Dropbox, or a private git repo.
