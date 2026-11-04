#!/usr/bin/env bash
# Checks each conformance example against the standard: the conforming one must
# pass tl check, each broken one must fail for its reason.
set -u
cd "$(dirname "$0")"
fail=0

expect_pass() {  # example
  if out=$(tl -C "$1" check 2>&1); then
    echo "ok    $1 passes"
  else
    echo "FAIL  $1 should pass"; echo "$out"; fail=1
  fi
}

expect_fail() {  # example, text the failure must contain
  if out=$(tl -C "$1" check 2>&1); then
    echo "FAIL  $1 should fail with: $2"; echo "$out"; fail=1
  elif grep -qF -- "$2" <<<"$out"; then
    echo "ok    $1 fails: $2"
  else
    echo "FAIL  $1 failed, but not with: $2"; echo "$out"; fail=1
  fi
}

expect_pass full-site
expect_fail no-label       "label is required when ELM.kind in"
expect_fail link-nowhere   "has 0 navigates_to link(s) to PAGE"
expect_fail exit-nowhere   "url is required when ELM.kind == external-link"
expect_fail two-homes      "has 2 starts_at link(s) to PAGE"
expect_fail no-effect      "effect is required when ELM.kind == button"
expect_fail opens-nothing  "has 0 opens link(s) to CMP"
expect_fail needed-by-text "has 1 needed_by link(s) to ELM"
expect_fail choices-on-text "choices must be absent when ELM.kind not in"
expect_fail prefilled-text  "prefilled must be absent when ELM.kind not in"
expect_fail two-templates   "has 2 like link(s) to CMP"
exit $fail
