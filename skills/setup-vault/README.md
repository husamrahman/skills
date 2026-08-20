# setup-vault

Create the vault your session skills use as memory. A vault is just a folder of markdown (`.md`) files on your computer. No Obsidian, no database, no account. Run this once before your first `start-session`.

## What it makes

```text
~/vault/
  README.md
  01-projects/        one note per project (start-session reads these)
    _README.md
    _template.md
  03-knowledge/       cross-project lessons and gotchas
    _README.md
  07-logs/
    sessions/         a log per work session (end-session writes these)
      _README.md
    evals/            one note per lesson, with a testable check
      _README.md
```

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

Or say "set up my vault."

## How it fits

`setup-vault` defaults to `~/vault`, which is exactly where `start-session` and `end-session` look by default. Keep the default and there is nothing else to configure. Want it elsewhere (iCloud, Dropbox, a git repo)? Point `VAULT` at that path and add `export VAULT=...` to your shell profile.

It is safe to re-run; it will not overwrite notes you already have.

## Do I need Obsidian?

No. These are plain text files you can open in any editor. Obsidian is a free app that makes browsing and linking them nicer, but everything works without it.
