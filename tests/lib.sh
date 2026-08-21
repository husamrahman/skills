#!/usr/bin/env bash
# Shared helpers for the skill isolation tests. Source this at the top of a
# *.test.sh file. Everything runs in a throwaway sandbox: a fresh HOME and a
# fresh git repo, so a skill's real side effects can be asserted without
# touching your machine.

set -u

# Resolve the repo root (two levels up from tests/), regardless of CWD.
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TESTS_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

PASS_COUNT=0
FAIL_COUNT=0

_green() { printf '\033[32m%s\033[0m' "$1"; }
_red()   { printf '\033[31m%s\033[0m' "$1"; }

pass() { PASS_COUNT=$((PASS_COUNT + 1)); printf '  %s %s\n' "$(_green '✓')" "$1"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); printf '  %s %s\n' "$(_red '✗')" "$1"; }

assert_dir()  { [ -d "$1" ] && pass "${2:-dir exists: $1}" || fail "${2:-missing dir: $1}"; }
assert_file() { [ -f "$1" ] && pass "${2:-file exists: $1}" || fail "${2:-missing file: $1}"; }
assert_missing() { [ ! -e "$1" ] && pass "${2:-absent: $1}" || fail "${2:-should not exist: $1}"; }

assert_eq() {
  if [ "$1" = "$2" ]; then pass "${3:-equal}"; else fail "${3:-not equal}: '$1' != '$2'"; fi
}

assert_contains() {
  if [ -f "$1" ] && grep -q -- "$2" "$1"; then pass "${3:-'$2' present in $(basename "$1")}"
  else fail "${3:-'$2' missing from $1}"; fi
}

assert_not_contains() {
  if [ -f "$1" ] && grep -q -- "$2" "$1"; then fail "${3:-'$2' should be absent from $1}"
  else pass "${3:-'$2' absent from $(basename "$1")}"; fi
}

# assert_ok "desc" -- cmd args...   (passes if the command exits 0)
assert_ok() {
  local desc="$1"; shift; [ "$1" = "--" ] && shift
  if "$@" >/dev/null 2>&1; then pass "$desc"; else fail "$desc (command failed: $*)"; fi
}

# make_sandbox: creates an isolated HOME under a temp dir and exports it.
# Sets SANDBOX (root) and HOME. Everything a skill writes to ~ lands here.
make_sandbox() {
  SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/skilltest.XXXXXX")"
  export SANDBOX
  export HOME="$SANDBOX/home"
  mkdir -p "$HOME"
  unset VAULT 2>/dev/null || true
}

cleanup_sandbox() { [ -n "${SANDBOX:-}" ] && rm -rf "$SANDBOX"; }

# new_repo <path>: an isolated git repo with a local bare "origin" so that
# fetch/pull/worktree patterns run offline exactly as a real project would.
new_repo() {
  local root="$1" name; name="$(basename "$root")"
  git init -q --bare "$SANDBOX/${name}-origin.git"
  git init -q "$root"
  git -C "$root" config user.email test@example.com
  git -C "$root" config user.name  "Skill Test"
  git -C "$root" symbolic-ref HEAD refs/heads/main
  printf '# %s\n' "$name" > "$root/README.md"
  git -C "$root" add -A
  git -C "$root" commit -qm "init"
  git -C "$root" branch -M main
  git -C "$root" remote add origin "$SANDBOX/${name}-origin.git"
  git -C "$root" push -q -u origin main
}

# resolve_vault: the exact resolution order the session skills specify:
# $VAULT env -> ~/.agent-vault pointer file -> ~/vault default.
resolve_vault() {
  if [ -n "${VAULT:-}" ]; then printf '%s\n' "$VAULT"; return; fi
  if [ -f "$HOME/.agent-vault" ]; then head -n1 "$HOME/.agent-vault" | tr -d '\r'; return; fi
  printf '%s\n' "$HOME/vault"
}

# extract_bash_block <file> <heading-substring> [n]: print the Nth ```bash
# fenced block that appears after a line containing <heading-substring>.
# Lets a test run the *actual* code a SKILL.md ships, so they can't drift.
extract_bash_block() {
  awk -v marker="$2" -v want="${3:-1}" '
    index($0, marker) { seen=1; next }
    seen && /^```bash/ { c++; if (c==want) { cap=1; next } }
    cap && /^```/ { exit }
    cap { print }
  ' "$1"
}

# finish: print the per-file summary and exit nonzero if anything failed.
finish() {
  printf '  --- %d passed, %d failed ---\n' "$PASS_COUNT" "$FAIL_COUNT"
  cleanup_sandbox
  [ "$FAIL_COUNT" -eq 0 ]
}
