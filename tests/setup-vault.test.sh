#!/usr/bin/env bash
# Contract: after setup-vault runs, there is a vault with projects/ knowledge/
# sessions/, a ~/.agent-vault pointer to it, and re-running never clobbers the
# user's own notes. This test runs the *actual* POSIX block shipped in the
# skill, so the test and the documented code can't drift apart.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
echo "setup-vault"
make_sandbox

BLOCK="$SANDBOX/setup-vault-block.sh"
extract_bash_block "$SKILLS_DIR/setup-vault/SKILL.md" "POSIX one-liner" 1 > "$BLOCK"
assert_ok "SKILL.md ships a runnable POSIX block" -- test -s "$BLOCK"

# Run it exactly as a user on a bare machine would.
( cd "$HOME" && bash "$BLOCK" ) >/dev/null 2>&1

VAULT="$(resolve_vault)"
assert_eq "$VAULT" "$HOME/vault" "vault resolves to the default ~/vault"
assert_dir  "$VAULT/projects"           "projects/ created"
assert_dir  "$VAULT/knowledge"          "knowledge/ created"
assert_dir  "$VAULT/sessions"           "sessions/ created"
assert_dir  "$VAULT/evals"              "evals/ created"
assert_file "$VAULT/projects/_template.md" "project template seeded"
assert_file "$HOME/.agent-vault"        "pointer file written"
assert_eq "$(cat "$HOME/.agent-vault")" "$VAULT" "pointer points at the vault"

# Idempotency: a real note must survive a re-run.
printf 'DO NOT CLOBBER\n' > "$VAULT/projects/acme-api.md"
printf '# custom readme\n' > "$VAULT/README.md"
( cd "$HOME" && bash "$BLOCK" ) >/dev/null 2>&1
assert_contains "$VAULT/projects/acme-api.md" "DO NOT CLOBBER" "re-run preserves user's project note"
assert_contains "$VAULT/README.md" "custom readme" "re-run preserves an edited README"

finish
