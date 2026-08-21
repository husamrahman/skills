#!/usr/bin/env bash
# Isolation test runner. Runs the structural lint, then each *.test.sh in its
# own sandbox (fresh HOME + fresh git repo). Exits nonzero if anything fails.
#
#   bash tests/run.sh            # run everything
#   bash tests/run.sh setup      # run only tests whose name matches "setup"
set -u
cd "$(dirname "$0")"

filter="${1:-}"
suites=( lint.sh )
for f in *.test.sh; do
  [ -n "$filter" ] && [[ "$f" != *"$filter"* ]] && continue
  suites+=( "$f" )
done

failed=0
for suite in "${suites[@]}"; do
  [ -f "$suite" ] || continue
  if ! bash "$suite"; then failed=$((failed + 1)); fi
  echo
done

if [ "$failed" -eq 0 ]; then
  printf '\033[32mAll suites passed.\033[0m\n'
else
  printf '\033[31m%d suite(s) failed.\033[0m\n' "$failed"
fi
exit "$( [ "$failed" -eq 0 ] && echo 0 || echo 1 )"
