#!/usr/bin/env bash
# Structural invariants every skill in this repo must satisfy. This is the
# reusable guard: add a new skill under skills/<name>/ and it is checked here
# automatically, so the whole library keeps behaving a certain way.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
echo "lint (all skills)"

shopt -s nullglob
found=0
for dir in "$SKILLS_DIR"/*/; do
  found=1
  name="$(basename "$dir")"
  skill="$dir/SKILL.md"
  adapter="$dir/agents/openai.yaml"

  assert_file "$skill"   "$name: has SKILL.md"
  assert_file "$adapter" "$name: has agents/openai.yaml adapter"
  [ -f "$skill" ] || continue

  # Frontmatter: must open with ---, and declare name: and description:.
  assert_ok "$name: SKILL.md opens with frontmatter" -- \
    bash -c "head -1 '$skill' | grep -qx -- '---'"
  assert_ok "$name: frontmatter declares name:" -- \
    bash -c "awk 'NR>1&&/^---/{exit} /^name:/{f=1} END{exit !f}' '$skill'"
  assert_ok "$name: frontmatter declares description:" -- \
    bash -c "awk 'NR>1&&/^---/{exit} /^description:/{f=1} END{exit !f}' '$skill'"
  assert_ok "$name: frontmatter name matches folder ($name)" -- \
    bash -c "grep -qx -- 'name: $name' '$skill'"

  # Release hygiene: no private paths, no leaked identities, no dropped tool.
  assert_not_contains "$skill" "qmd" "$name: no qmd dependency"
  assert_ok "$name: no absolute home paths leaked" -- \
    bash -c "! grep -nE '/(home|Users)/[a-z]' '$skill'"
done

assert_ok "found at least one skill to lint" -- test "$found" -eq 1
finish
