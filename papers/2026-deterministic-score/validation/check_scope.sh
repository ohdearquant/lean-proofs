#!/usr/bin/env bash
set -euo pipefail

file="${1:-main.tex}"

fail=0

check_forbidden() {
  local pattern="$1"
  local message="$2"
  if grep -niE "$pattern" "$file" >/tmp/check_scope_match.txt; then
    echo "[scope warning] $message"
    cat /tmp/check_scope_match.txt
    fail=1
  fi
}

# These are hard-overclaim patterns for this paper. They are allowed only if
# explicitly negated or scoped. The script is intentionally conservative and
# should be reviewed manually.
check_forbidden "verified Rust implementation" "Do not claim verified Rust implementation. Use tested/manual correspondence unless a mechanized Rust proof exists."
check_forbidden "state[- ]of[- ]the[- ]art|SOTA" "No SOTA retrieval-performance claim is supported in this paper."
check_forbidden "guarantee[s]? deterministic ranking" "The artifact proves deterministic score comparison, not record-level ranking."
check_forbidden "NaN sentinel" "MIN is a reserved sentinel, not a NaN sentinel. NaN maps to ZERO."
check_forbidden "IEEE-754 conversion correctness" "IEEE-754 conversion correctness is outside the Lean artifact."

if [[ "$fail" -eq 1 ]]; then
  echo "Scope audit found warnings. Review manually."
  exit 1
fi

echo "Scope audit passed."
