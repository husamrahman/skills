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
  "## Gotchas" "## Lessons learned" "## Next steps" "## Handoff"; do
  assert_contains "$SKILL" "$section" "template defines section: ${section#\#\# }"
done
# and it must no longer reference the retired concepts
assert_not_contains "$SKILL" "qmd" "no qmd re-index step remains"
assert_not_contains "$SKILL" "07-logs" "no legacy folder scheme remains"

# --- gotcha promotion appends, never overwrites ---
VAULT="$HOME/vault"; mkdir -p "$VAULT/projects"
printf '# acme-api\n\n## Gotchas\n- existing one\n' > "$VAULT/projects/acme-api.md"
before="$(grep -c '^- ' "$VAULT/projects/acme-api.md")"
printf -- '- [2026-08-21] **limiter order**: auth must precede limiter. _Trigger: middleware edits_\n' \
  >> "$VAULT/projects/acme-api.md"
after="$(grep -c '^- ' "$VAULT/projects/acme-api.md")"
assert_contains "$VAULT/projects/acme-api.md" "existing one" "existing gotcha preserved"
assert_ok "promotion appends a new gotcha line" -- test "$after" -eq $((before + 1))

# --- worktree can be retired ---
REPO="$SANDBOX/acme-api"; new_repo "$REPO"
WT="$SANDBOX/acme-api-session-x"
( cd "$REPO" && git worktree add -q -b session/x "$WT" ) 2>/dev/null
assert_dir "$WT" "worktree created for retirement test"
( cd "$REPO" && git worktree remove --force "$WT" ) 2>/dev/null
assert_missing "$WT" "git worktree remove retires the worktree"

finish
