# setup-vault

Create the **knowledge vault** your session skills use as memory, and record where it lives so those skills can find it on any machine. A knowledge vault is just a folder of markdown (`.md`) files on your computer. No Obsidian, no database, no account. Run this once before your first `start-session`.

Works on **Windows (PowerShell)** as well as macOS/Linux/WSL/Git Bash - the skill picks commands for your OS.

## What it makes

```text
~/vault/
  README.md
  projects/           one FOLDER per project (start-session reads these)
    _README.md
    _template/         copy this folder to start a new project
      README.md        the project note
  knowledge/          cross-project lessons and gotchas
    _README.md
  sessions/           a log per work session (end-session writes these)
    _README.md
    _template.md       the session-log template
  evals/              durable learnings, each with a testable check
    _README.md
    _template.md       the eval-note template
```

Each project gets its **own folder** (named after the repo); its note is that folder's `README.md`. The `sessions/` and `evals/` templates live in the vault so they are easy to find and edit.

It also writes a one-line pointer file, `~/.agent-vault`, containing the vault's absolute path. That is how `start-session` and `end-session` find the vault later - so it just works on Windows, macOS, and Linux with no environment variables to set and no symlinks to create.

## Install

Claude Code:

```bash
cp -r setup-vault ~/.claude/skills/     # user-scoped (every project)
```

Codex:

```bash
cp -r setup-vault ~/.codex/skills/
```

## Use

```
/setup-vault
```

Or say "set up my knowledge vault."

## How it fits

`setup-vault` defaults the vault to `~/vault` and records its path in `~/.agent-vault`. `start-session` and `end-session` read that pointer file, so keep the default and there is nothing else to configure.

Want the vault somewhere else - OneDrive, iCloud, Dropbox, or a git repo - so it syncs across machines? Tell `setup-vault` that path when you run it; it stores the location in the pointer file either way. (Power users can also set a `VAULT` environment variable, which the session skills check first.)

It is safe to re-run; it will not overwrite notes you already have.

## Do I need Obsidian?

No. These are plain text files you can open in any editor. Obsidian is a free app that makes browsing and linking them nicer, but everything works without it.
