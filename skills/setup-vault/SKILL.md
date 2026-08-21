---
name: setup-vault
description: Create a knowledge vault - a plain folder of markdown files on your computer - that the start-session and end-session skills read from and write to, and record where it lives so those skills can find it on any OS. Use when the user says setup-vault, /setup-vault, "set up my knowledge vault", "create a vault", or is starting out and has no vault yet. No Obsidian required.
---

# Setup Knowledge Vault

Create the **knowledge vault** your session skills use as memory, and drop a small pointer so those skills can find it later on any machine. A knowledge vault is nothing fancy: just a folder of markdown (`.md`) text files. Open any of them in any editor. Obsidian is a nice free app for browsing and linking these notes, but it is optional and nothing here needs it.

Run this once, before your first `start-session`.

## How it works

This skill ships the starter files in its own **`templates/` folder** (right next to this file). Setting up the vault is simply: **copy that `templates/` folder into your vault** - skipping anything you already have - then write a pointer file so the session skills can find it. The `templates/` folder mirrors the vault exactly, so you can open it to review or edit the starting notes.

```text
templates/                     -> copied into <vault>/
  README.md
  projects/
    _README.md
    _template/                 one project = one folder; its note is README.md
      README.md
  knowledge/
    _README.md
    _template.md               the cross-project knowledge-note template
  sessions/
    _README.md
    _template.md               the session-log template (end-session fills this)
  evals/
    _README.md
    _template.md               the eval-note template (end-session fills this)
```

Each project gets its **own folder** under `projects/` (named after the repo); its note is that folder's `README.md`. The `sessions/` and `evals/` templates live in the vault too, so end-session copies from them and you can customize them per vault.

## First, know the operating system

The commands differ by OS, so pick the right block below:

- **Windows** - use the PowerShell block. Many users are here; do not assume a POSIX shell.
- **macOS / Linux / WSL / Git Bash** - use the bash block, or the file-tool steps.

## Pick the vault location

Default is `~/vault`. Keep it unless the user wants it elsewhere (OneDrive, iCloud, Dropbox, a git repo) so it syncs across machines. Resolve `~`/home yourself; do not rely on a shell variable being set.

## Option A: with your file tools (works on any OS)

Copy every file under this skill's `templates/` folder into `<vault>/`, keeping the same structure, and **skip any file that already exists** (never overwrite a note the user already has). Then write the pointer file (below).

## Option B: one-shot (pick your shell)

Both blocks are safe to re-run; `-n` / the existence check means they never overwrite files you already have. `SKILL_DIR` is this setup-vault skill's own folder (where `templates/` lives) - run the block from that folder, or set `SKILL_DIR` to it.

### macOS / Linux / WSL / Git Bash (bash)

```bash
set -e
SKILL_DIR="${SKILL_DIR:-$PWD}"                 # this setup-vault skill folder
VAULT="${VAULT:-$HOME/vault}"
mkdir -p "$VAULT"
cp -Rn "$SKILL_DIR/templates/." "$VAULT/"      # -n: never overwrite your notes
printf '%s\n' "$VAULT" > "$HOME/.agent-vault"
echo "Knowledge vault ready at $VAULT (recorded in ~/.agent-vault)"
```

### Windows (PowerShell)

```powershell
$ErrorActionPreference = 'Stop'
$SkillDir = if ($env:SKILL_DIR) { $env:SKILL_DIR } elseif ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$Vault = if ($env:VAULT) { $env:VAULT } else { Join-Path $HOME 'vault' }
$Src = Join-Path $SkillDir 'templates'
Get-ChildItem -LiteralPath $Src -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($Src.Length).TrimStart('\','/')
  $dst = Join-Path $Vault $rel
  if (-not (Test-Path -LiteralPath $dst)) {                       # never overwrite your notes
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
    Copy-Item -LiteralPath $_.FullName -Destination $dst
  }
}
Set-Content -LiteralPath (Join-Path $HOME '.agent-vault') -Value $Vault -Encoding utf8
Write-Host "Knowledge vault ready at $Vault (recorded in ~/.agent-vault)"
```

## Record where the vault lives (so the session skills can find it)

Both blocks already do this: they write the vault's **absolute path** into a pointer file in the user's home directory named `.agent-vault` (one line, just the path). If you set the vault up by hand (Option A), write that file yourself.

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
- Templates: copied from this skill's templates/ (projects/_template/, sessions/_template.md, evals/_template.md)
- Next: run start-session in a project, then end-session when you finish.
```

## Notes

- The starter files live in this skill's `templates/` folder - edit them there to change what new vaults (and new projects/sessions/evals) start with.
- The leading underscore on `_README.md` and `_template*` keeps `start-session` from mistaking them for real project folders or notes.
- Keep the default `~/vault` unless you have a reason not to; it means zero configuration.
- Want the notes to sync or back up? Put the vault inside OneDrive, iCloud, Dropbox, or a private git repo, and point it there.
