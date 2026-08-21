# Isolation tests

A dependency-free harness that verifies each skill **behaves a certain way**, in isolation. No Node, no Python, no packages - just `bash` and `git`. Every suite runs in a throwaway sandbox (a fresh `HOME` and a fresh git repo with a local `origin`), so a skill's real side effects are exercised and asserted without touching your machine.

## Run

```bash
bash tests/run.sh            # lint + every skill suite
bash tests/run.sh setup      # only suites whose filename matches "setup"
```

Exit code is `0` only if everything passes, so it drops straight into CI (see `.github/workflows/test.yml`).

## What gets checked

- **`lint.sh`** - structural invariants over *every* skill under `skills/`: a `SKILL.md` with `name:`/`description:` frontmatter whose `name` matches the folder, an `agents/openai.yaml` adapter, no `qmd` dependency, and no leaked absolute home paths. Add a new skill and it is linted automatically.
- **`<skill>.test.sh`** - one suite per skill, asserting that skill's *contract* (its observable guarantees). For example `setup-vault` runs the actual POSIX block shipped in its `SKILL.md` and checks the vault, the `~/.agent-vault` pointer, and idempotency; `start-session` checks vault resolution, note lookup, and worktree isolation.

## The idea: test the contract, not the prose

A skill is instructions an agent reads, not a program - so pin down the **observable outcome** you promise and assert on that: files created, the pointer written, the worktree branched off cleanly, a section present in the template. Where the skill ships a real command block, run that block (`extract_bash_block`) instead of copying it, so the test can't drift from what ships.

## Add a test for a new skill

1. Drop your skill in `skills/<name>/` (`SKILL.md` + `agents/openai.yaml`). The lint now covers it - no wiring needed.
2. Create `tests/<name>.test.sh`:

   ```bash
   #!/usr/bin/env bash
   source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
   echo "<name>"
   make_sandbox                      # fresh HOME + isolation

   # ... run the skill's real mechanics against the sandbox ...

   assert_file   "$HOME/expected/thing"     "creates the thing"
   assert_contains "$SOME_FILE" "needle"    "writes what it promises"
   assert_ok "command succeeds" -- some-command --flag

   finish                            # prints summary, sets exit code
   ```

3. `bash tests/run.sh` picks it up automatically (any `tests/*.test.sh`).

### Helpers in `lib.sh`

| Helper | Does |
|--------|------|
| `make_sandbox` | fresh `HOME` under a temp dir; unsets `VAULT` |
| `new_repo <path>` | isolated git repo with a local bare `origin` (offline fetch/pull/worktree) |
| `resolve_vault` | the skills' resolution order: `$VAULT` → `~/.agent-vault` → `~/vault` |
| `extract_bash_block <file> <heading> [n]` | print the Nth ```` ```bash ```` block after a heading, to run real shipped code |
| `assert_file` / `assert_dir` / `assert_missing` | filesystem assertions |
| `assert_contains` / `assert_not_contains` | content assertions |
| `assert_eq` / `assert_ok "desc" -- cmd` | value and command-success assertions |
| `finish` | per-suite summary + exit code; cleans up the sandbox |
