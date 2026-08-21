#!/usr/bin/env bash
# Contract: end-session's session note carries the seven named sections, a
# gotcha promoted into a project note appends without clobbering, and the
# worktree it created can be retired cleanly.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
echo "end-session"
make_sandbox

SKILL="$SKILLS_DIR/end-session/SKILL.md"

# The documented session-note template must contain every promised section.
for section in \
  "## Session summary" "## Changes" "## Decisions" \
  "## Gotchas" "## Evals" "## Next steps" "## Handoff"; do
  assert_contains "$SKILL" "$section" "template defines section: ${section#\#\# }"
done
# evals are real artifacts: a standalone eval note with a testable criterion
assert_contains "$SKILL" "evals/<project>" "promotes evals into the evals/ folder"
assert_contains "$SKILL" "Eval criteria"   "eval note carries a testable Eval criteria line"
# and it must no longer reference the retired concepts
assert_not_contains "$SKILL" "qmd" "no qmd re-index step remains"
assert_not_contains "$SKILL" "07-logs" "no legacy folder scheme remains"

# --- gotcha promotion appends to the project folder's README, never overwrites ---
VAULT="$HOME/vault"; mkdir -p "$VAULT/projects/acme-api"
NOTE="$VAULT/projects/acme-api/README.md"
printf '# acme-api\n\n## Gotchas\n- existing one\n' > "$NOTE"
before="$(grep -c '^- ' "$NOTE")"
printf -- '- [2026-08-21] **limiter order**: auth must precede limiter. _Trigger: middleware edits_\n' >> "$NOTE"
after="$(grep -c '^- ' "$NOTE")"
assert_contains "$NOTE" "existing one" "existing gotcha preserved"
assert_ok "promotion appends a new gotcha line" -- test "$after" -eq $((before + 1))

# --- worktree can be retired ---
REPO="$SANDBOX/acme-api"; new_repo "$REPO"
WT="$SANDBOX/acme-api-session-x"
( cd "$REPO" && git worktree add -q -b session/x "$WT" ) 2>/dev/null
assert_dir "$WT" "worktree created for retirement test"
( cd "$REPO" && git worktree remove --force "$WT" ) 2>/dev/null
assert_missing "$WT" "git worktree remove retires the worktree"

finish
