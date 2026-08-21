#!/usr/bin/env bash
# Contract: setup-vault copies its own templates/ folder into a vault, writes a
# ~/.agent-vault pointer, and re-running never clobbers the user's own notes.
# This test runs the *actual* bash block shipped in the skill, so the test and
# the documented code can't drift apart.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
echo "setup-vault"
make_sandbox

BLOCK="$SANDBOX/setup-vault-block.sh"
extract_bash_block "$SKILLS_DIR/setup-vault/SKILL.md" "one-shot" 1 > "$BLOCK"
assert_ok "SKILL.md ships a runnable bash block" -- test -s "$BLOCK"

# The templates the skill copies from must exist in the repo as real files -
# this is what the user reviews, and what start/end-session refer to.
TPL="$SKILLS_DIR/setup-vault/templates"
assert_dir  "$TPL"                              "skill ships a templates/ folder"
assert_file "$TPL/projects/_template/README.md" "project-note template exists in repo"
assert_file "$TPL/knowledge/_template.md"       "knowledge-note template exists in repo"
assert_file "$TPL/sessions/_template.md"        "session template exists in repo"
assert_file "$TPL/evals/_template.md"           "eval template exists in repo"
# the richer templates carry their signature sections
assert_contains "$TPL/projects/_template/README.md" "## Learning log"    "project template has a Learning log"
assert_contains "$TPL/knowledge/_template.md"        "## Anti-patterns"  "knowledge template has Anti-patterns"
assert_contains "$TPL/evals/_template.md"            "## Eval criteria"  "eval template has Eval criteria"

# Run it exactly as a user on a bare machine would; SKILL_DIR points at the skill.
( cd "$HOME" && SKILL_DIR="$SKILLS_DIR/setup-vault" bash "$BLOCK" ) >/dev/null 2>&1

VAULT="$(resolve_vault)"
assert_eq "$VAULT" "$HOME/vault" "vault resolves to the default ~/vault"
assert_dir  "$VAULT/projects"                    "projects/ created"
assert_dir  "$VAULT/knowledge"                   "knowledge/ created"
assert_dir  "$VAULT/sessions"                    "sessions/ created"
assert_dir  "$VAULT/evals"                       "evals/ created"
# each project is a folder: the template is a folder with a README note
assert_dir  "$VAULT/projects/_template"          "project template is a FOLDER"
assert_file "$VAULT/projects/_template/README.md" "project template note seeded"
# session + eval templates live in the vault, discoverable
assert_file "$VAULT/sessions/_template.md"       "session template seeded"
assert_file "$VAULT/evals/_template.md"          "eval template seeded"
assert_file "$HOME/.agent-vault"                 "pointer file written"
assert_eq "$(cat "$HOME/.agent-vault")" "$VAULT" "pointer points at the vault"

# Idempotency: a real note must survive a re-run.
mkdir -p "$VAULT/projects/acme-api"
printf 'DO NOT CLOBBER\n' > "$VAULT/projects/acme-api/README.md"
printf '# custom readme\n' > "$VAULT/README.md"
( cd "$HOME" && SKILL_DIR="$SKILLS_DIR/setup-vault" bash "$BLOCK" ) >/dev/null 2>&1
assert_contains "$VAULT/projects/acme-api/README.md" "DO NOT CLOBBER" "re-run preserves user's project note"
assert_contains "$VAULT/README.md" "custom readme" "re-run preserves an edited README"

finish
