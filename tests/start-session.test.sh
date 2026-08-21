#!/usr/bin/env bash
# Contract: start-session finds the vault, reads the project note, surfaces a
# gotcha and the latest handoff, and opens an isolated worktree on a new branch
# without touching main. All offline, in a sandbox.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
echo "start-session"
make_sandbox

# --- vault resolution precedence: env > pointer > default ---
printf '%s\n' "$HOME/vault" > "$HOME/.agent-vault"
mkdir -p "$HOME/vault"
assert_eq "$(resolve_vault)" "$HOME/vault" "pointer file resolves when no env"
VAULT="/tmp/override" assert_eq "$(VAULT=/tmp/override resolve_vault)" "/tmp/override" "VAULT env overrides the pointer"
rm "$HOME/.agent-vault"
assert_eq "$(resolve_vault)" "$HOME/vault" "falls back to ~/vault with no env and no pointer"
printf '%s\n' "$HOME/vault" > "$HOME/.agent-vault"

# --- seed a vault the way setup-vault + prior sessions would ---
VAULT="$(resolve_vault)"
mkdir -p "$VAULT/projects/acme-api" "$VAULT/knowledge" "$VAULT/sessions"
printf '# acme-api\n## Gotchas\n- auth before limiter\n' > "$VAULT/projects/acme-api/README.md"
printf 'acme-api gotcha: middleware order matters\n'       > "$VAULT/knowledge/mw.md"
printf '## Handoff\nOLD handoff\n'  > "$VAULT/sessions/acme-api-2026-08-10-090000.md"
printf '## Handoff\nNEW handoff\n'  > "$VAULT/sessions/acme-api-2026-08-20-090000.md"

PROJECT="acme-api"

# project note lookup: each project is its own folder; note is its README.md
proj_dir="$(printf '%s\n' "$VAULT"/projects/*/ | tr ' ' '\n' | grep -i "$PROJECT" | grep -v '/_' | head -1)"
assert_eq "$(basename "$proj_dir")" "acme-api" "locates the project folder by name"
assert_file "${proj_dir}README.md" "project note is the folder's README.md"

# gotcha search must work with plain grep (no ripgrep, no index)
hits="$(grep -rl -i "gotcha" "$VAULT" | grep -ci "$PROJECT")"
assert_ok "finds a project gotcha via plain grep" -- test "$hits" -ge 1

# latest handoff via name-sort on date-stamped filenames (portable, no ls -t)
latest="$(printf '%s\n' "$VAULT"/sessions/*"$PROJECT"*.md | tr ' ' '\n' | sort | tail -1)"
assert_contains "$latest" "NEW handoff" "name-sort selects the newest session note"

# --- worktree isolation ---
REPO="$SANDBOX/acme-api"
new_repo "$REPO"
STAMP="20260821-120000"
WT="$SANDBOX/acme-api-session-$STAMP"
( cd "$REPO" && git fetch -q origin && git worktree add -q -b "session/$STAMP" "$WT" ) 2>/dev/null
assert_dir "$WT" "worktree directory created"
assert_ok "worktree is on the new session branch" -- \
  bash -c "git -C '$WT' rev-parse --abbrev-ref HEAD | grep -qx 'session/$STAMP'"
assert_ok "main branch is untouched (still exists, not checked out here)" -- \
  bash -c "git -C '$REPO' rev-parse --abbrev-ref HEAD | grep -qx main"

finish
