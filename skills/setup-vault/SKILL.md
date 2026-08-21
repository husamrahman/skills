---
name: setup-vault
description: Create a knowledge vault - a plain folder of markdown files on your computer - that the start-session and end-session skills read from and write to, and record where it lives so those skills can find it on any OS. Use when the user says setup-vault, /setup-vault, "set up my vault", "create a vault", or is starting out and has no vault yet. No Obsidian required.
---

# Setup Vault

Create the folder your session skills use as memory, and drop a small pointer so those skills can find it later on any machine. A "vault" is nothing fancy: just a folder of markdown (`.md`) text files. Open any of them in any editor. Obsidian is a nice free app for browsing and linking these notes, but it is optional and nothing here needs it.

Run this once, before your first `start-session`.

## Process

Do these steps with your own file tools so this works identically on Windows, macOS, and Linux. A POSIX one-liner is offered at the end for shells that have it, but the file-tool path is the reliable one.

### 1. Pick the vault location

Default is a folder named `vault` in the user's home directory (`~/vault`). Keep the default unless the user wants it elsewhere (for example inside OneDrive, iCloud, or Dropbox so it syncs across machines). Resolve `~`/home yourself; do not rely on a shell variable being set.

### 2. Create the folders and seed files

Create this structure. Only create files that do not already exist — never overwrite a note the user already has.

```text
<vault>/
  README.md
  projects/          one note per project (start-session reads these)
    _README.md
    _template.md
  knowledge/         lessons and gotchas that apply across projects
    _README.md
  sessions/          one log per work session (end-session writes these)
    _README.md
```

Seed each file with this content:

`<vault>/README.md`
```markdown
# My Vault

A knowledge vault: a plain folder of markdown (.md) files my coding agent uses as
long-term memory. Nothing here is special - open any file in any text editor.

- projects/    one note per project (status, how it works, gotchas)
- knowledge/   lessons that apply across every project
- sessions/    a dated log for each work session

start-session reads from these folders; end-session writes to them.
Optional: open this folder in Obsidian (https://obsidian.md) to browse and link
notes visually. Not required.
```

`<vault>/projects/_README.md`
```markdown
# Projects

One note per project you work on. Name the file after the project's repo folder
so start-session can find it (for a repo called acme-api, use acme-api.md).
Copy _template.md to start a new one.
```

`<vault>/projects/_template.md`
```markdown
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
```

`<vault>/knowledge/_README.md`
```markdown
# Knowledge

Lessons and gotchas not tied to a single project: tooling, workflow, cross-project
patterns. end-session drops global lessons here; start-session can surface them
on any project.
```

`<vault>/sessions/_README.md`
```markdown
# Session logs

end-session writes one dated note here per work session: a summary, what changed,
decisions, gotchas, lessons learned, next steps, and a handoff. You do not write
these by hand.
```

### 3. Record where the vault lives (so the session skills can find it)

Write the vault's **absolute path** into a pointer file in the user's home directory named `.agent-vault`. One line, just the path, no quotes:

```text
~/.agent-vault      ->  contents: /absolute/path/to/vault
```

This is how `start-session` and `end-session` locate the vault on the next run. A plain pointer file is used on purpose instead of an environment variable or a symlink, because it works the same on Windows, macOS, and Linux, needs no admin rights or shell-profile edits, and survives being copied or zipped between machines.

If the user set a custom `VAULT` environment variable and prefers that, that is fine too - the session skills check `VAULT` first and fall back to this pointer file. But always write the pointer file so a plain machine with no env var still works.

### 4. Confirm

List the layout and tell the user they are ready:

```markdown
## Vault ready
- Location: <vault>
- Recorded in: ~/.agent-vault
- Folders: projects, knowledge, sessions
- Next: run start-session in a project, then end-session when you finish.
  The vault fills itself in from there.
```

## POSIX one-liner (optional convenience)

On macOS, Linux, WSL, or Git Bash you can do steps 2-3 in one shell block instead of the file tools above. It is safe to re-run and will not overwrite existing files.

```bash
set -e
VAULT="${VAULT:-$HOME/vault}"
mkdir -p "$VAULT/projects" "$VAULT/knowledge" "$VAULT/sessions"
seed() { [ -e "$1" ] || cat > "$1"; }

seed "$VAULT/README.md" <<'EOF'
# My Vault
A plain folder of markdown files my coding agent uses as long-term memory.
- projects/  one note per project
- knowledge/ cross-project lessons and gotchas
- sessions/  a dated log per work session
EOF
seed "$VAULT/projects/_README.md" <<'EOF'
# Projects
One note per project. Name it after the repo folder (acme-api -> acme-api.md).
Copy _template.md to start a new one.
EOF
seed "$VAULT/projects/_template.md" <<'EOF'
---
project: <repo-name>
status: active
---
# <Project>
## What it is
## How it is built
## Gotchas
## Decisions
## Active work / next
EOF
seed "$VAULT/knowledge/_README.md" <<'EOF'
# Knowledge
Cross-project lessons and gotchas. end-session writes global lessons here.
EOF
seed "$VAULT/sessions/_README.md" <<'EOF'
# Session logs
end-session writes one dated note per session. You do not write these by hand.
EOF

printf '%s\n' "$VAULT" > "$HOME/.agent-vault"
echo "Vault ready at $VAULT (recorded in ~/.agent-vault)"
```

## Notes

- The leading underscore on `_README.md` and `_template.md` keeps `start-session` from mistaking them for project notes.
- Keep the default `~/vault` unless you have a reason not to; it means zero configuration.
- Want the notes to sync or back up? Put the vault inside OneDrive, iCloud, Dropbox, or a private git repo, and point it there in step 1.
