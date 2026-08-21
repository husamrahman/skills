---
name: setup-vault
description: Create a knowledge vault - a plain folder of markdown files on your computer - that the start-session and end-session skills read from and write to, and record where it lives so those skills can find it on any OS. Use when the user says setup-vault, /setup-vault, "set up my knowledge vault", "create a vault", or is starting out and has no vault yet. No Obsidian required.
---

# Setup Knowledge Vault

Create the **knowledge vault** your session skills use as memory, and drop a small pointer so those skills can find it later on any machine. A knowledge vault is nothing fancy: just a folder of markdown (`.md`) text files. Open any of them in any editor. Obsidian is a nice free app for browsing and linking these notes, but it is optional and nothing here needs it.

Run this once, before your first `start-session`.

## First, know the operating system

The commands differ by OS, so determine which one you are on before running anything:

- **Windows** - use the PowerShell block. Many users are here; do not assume a POSIX shell.
- **macOS / Linux / WSL / Git Bash** - use the bash block, or the file-tool steps.

If unsure, check: PowerShell has `$PSVersionTable`; a POSIX shell has `$SHELL`.

## The layout

```text
<vault>/
  README.md
  projects/            one FOLDER per project (start-session reads these)
    _README.md
    _template/         copy this folder to start a new project
      README.md        the project note (status, build, gotchas, decisions)
  knowledge/           cross-project lessons and gotchas
    _README.md
  sessions/            one log per work session (end-session writes these)
    _README.md
    _template.md       the session-log template
  evals/               durable, cross-session learnings with a testable check
    _README.md
    _template.md       the eval-note template
```

Each project gets its **own folder** under `projects/`, named after the repo (a repo called `acme-api` -> `projects/acme-api/`). Its note is that folder's `README.md`; keep related per-project notes in the same folder. The `sessions/` and `evals/` templates live in the vault too, so they are easy to find and edit - that is where end-session's shapes come from.

## Option A: create it with your file tools (works on any OS)

Create the folders and files above with your own file tools. Only create files that do not already exist - never overwrite a note the user already has. Seed each with the content below, then write the pointer file (step at the end).

`<vault>/README.md`
```markdown
# My Knowledge Vault

A plain folder of markdown (.md) files my coding agent uses as long-term memory.
Nothing here is special - open any file in any text editor.

- projects/    one folder per project (status, how it works, gotchas)
- knowledge/   lessons that apply across every project
- sessions/    a dated log for each work session
- evals/       durable learnings, each with a testable check

start-session reads from these folders; end-session writes to them.
Optional: open this folder in Obsidian (https://obsidian.md). Not required.
```

`<vault>/projects/_README.md`
```markdown
# Projects

One FOLDER per project, named after the repo folder so start-session can find it
(for a repo called acme-api, use projects/acme-api/). The project note is that
folder's README.md. Copy the _template folder to start a new project.
```

`<vault>/projects/_template/README.md`
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

end-session writes one dated note here per work session, following _template.md:
a summary, what changed, decisions, gotchas, evals, next steps, and a handoff.
You do not write these by hand.
```

`<vault>/sessions/_template.md`
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
- <something that bit you and how to avoid it. Trigger: when this applies.>

## Evals
- <the learning in one line. Eval criteria: a binary, observable check.>

## Next steps
- [ ] <what comes next>

## Handoff
<anything the next session needs to know immediately>
```

`<vault>/evals/_README.md`
```markdown
# Evals

end-session promotes a note here for each durable, cross-session learning worth
resurfacing, following _template.md - each with a testable "Eval criteria" line.
start-session surfaces the relevant ones before a task. You do not write these
by hand.
```

`<vault>/evals/_template.md`
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

## Option B: one-shot setup (pick your shell)

Both blocks are safe to re-run and will not overwrite files you already have. They create the layout above and write the pointer file.

### macOS / Linux / WSL / Git Bash (bash)

```bash
set -e
VAULT="${VAULT:-$HOME/vault}"
mkdir -p "$VAULT/projects/_template" "$VAULT/knowledge" "$VAULT/sessions" "$VAULT/evals"
seed() { [ -e "$1" ] || cat > "$1"; }

seed "$VAULT/README.md" <<'EOF'
# My Knowledge Vault
A plain folder of markdown files my coding agent uses as long-term memory.
- projects/  one folder per project
- knowledge/ cross-project lessons and gotchas
- sessions/  a dated log per work session
- evals/     durable learnings, each with a testable check
EOF
seed "$VAULT/projects/_README.md" <<'EOF'
# Projects
One FOLDER per project, named after the repo (acme-api -> projects/acme-api/).
The project note is that folder's README.md. Copy _template/ to start a new one.
EOF
seed "$VAULT/projects/_template/README.md" <<'EOF'
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
end-session writes one dated note per session, following _template.md.
EOF
seed "$VAULT/sessions/_template.md" <<'EOF'
---
project: <project>
date: <YYYY-MM-DD>
type: <feature | fix | chore | research | planning>
outcome: <shipped | pr-created | ongoing | discarded>
---
# <project> - <one-line summary>
## Session summary
## Changes
## Decisions
## Gotchas
## Evals
## Next steps
## Handoff
EOF
seed "$VAULT/evals/_README.md" <<'EOF'
# Evals
Durable, cross-session learnings, each with a testable Eval criteria line.
Follow _template.md.
EOF
seed "$VAULT/evals/_template.md" <<'EOF'
---
project: <project>
date: <YYYY-MM-DD>
category: <gotcha | pattern | correction | tool-discovery | architecture>
severity: <low | medium | high>
---
# <short title>
## Scenario
## Expected
## Actual
## Eval criteria
## Applies to
EOF

printf '%s\n' "$VAULT" > "$HOME/.agent-vault"
echo "Knowledge vault ready at $VAULT (recorded in ~/.agent-vault)"
```

### Windows (PowerShell)

```powershell
$ErrorActionPreference = 'Stop'
$Vault = if ($env:VAULT) { $env:VAULT } else { Join-Path $HOME 'vault' }
foreach ($d in 'projects\_template','knowledge','sessions','evals') {
  New-Item -ItemType Directory -Force -Path (Join-Path $Vault $d) | Out-Null
}
function Seed($Path, $Text) {
  if (-not (Test-Path -LiteralPath $Path)) { Set-Content -LiteralPath $Path -Value $Text -Encoding utf8 }
}

Seed (Join-Path $Vault 'README.md') @'
# My Knowledge Vault
A plain folder of markdown files my coding agent uses as long-term memory.
- projects/  one folder per project
- knowledge/ cross-project lessons and gotchas
- sessions/  a dated log per work session
- evals/     durable learnings, each with a testable check
'@
Seed (Join-Path $Vault 'projects\_README.md') @'
# Projects
One FOLDER per project, named after the repo (acme-api -> projects\acme-api\).
The project note is that folder's README.md. Copy _template\ to start a new one.
'@
Seed (Join-Path $Vault 'projects\_template\README.md') @'
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
'@
Seed (Join-Path $Vault 'knowledge\_README.md') @'
# Knowledge
Cross-project lessons and gotchas. end-session writes global lessons here.
'@
Seed (Join-Path $Vault 'sessions\_README.md') @'
# Session logs
end-session writes one dated note per session, following _template.md.
'@
Seed (Join-Path $Vault 'sessions\_template.md') @'
---
project: <project>
date: <YYYY-MM-DD>
type: <feature | fix | chore | research | planning>
outcome: <shipped | pr-created | ongoing | discarded>
---
# <project> - <one-line summary>
## Session summary
## Changes
## Decisions
## Gotchas
## Evals
## Next steps
## Handoff
'@
Seed (Join-Path $Vault 'evals\_README.md') @'
# Evals
Durable, cross-session learnings, each with a testable Eval criteria line.
Follow _template.md.
'@
Seed (Join-Path $Vault 'evals\_template.md') @'
---
project: <project>
date: <YYYY-MM-DD>
category: <gotcha | pattern | correction | tool-discovery | architecture>
severity: <low | medium | high>
---
# <short title>
## Scenario
## Expected
## Actual
## Eval criteria
## Applies to
'@

Set-Content -LiteralPath (Join-Path $HOME '.agent-vault') -Value $Vault -Encoding utf8
Write-Host "Knowledge vault ready at $Vault (recorded in ~/.agent-vault)"
```

## Record where the vault lives (so the session skills can find it)

Both blocks above already do this: they write the vault's **absolute path** into a pointer file in the user's home directory named `.agent-vault` (one line, just the path). If you set the vault up by hand (Option A), write that file yourself.

```text
~/.agent-vault      ->  contents: /absolute/path/to/vault
```

This is how `start-session` and `end-session` locate the vault on the next run. A plain pointer file is used on purpose instead of an environment variable or a symlink, because it works the same on Windows, macOS, and Linux, needs no admin rights or shell-profile edits, and survives being copied between machines. (Power users can set a `VAULT` environment variable instead; the session skills check it first.)

## Confirm

Tell the user they are ready:

```markdown
## Knowledge vault ready
- Location: <vault>
- Recorded in: ~/.agent-vault
- Folders: projects (one per repo), knowledge, sessions, evals
- Templates: projects/_template/, sessions/_template.md, evals/_template.md
- Next: run start-session in a project, then end-session when you finish.
```

## Notes

- The leading underscore on `_README.md` and `_template*` keeps `start-session` from mistaking them for real project folders or notes.
- Keep the default `~/vault` unless you have a reason not to; it means zero configuration.
- Want the notes to sync or back up? Put the vault inside OneDrive, iCloud, Dropbox, or a private git repo, and point it there.
