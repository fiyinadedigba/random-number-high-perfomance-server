#!/usr/bin/env bash

set -euo pipefail

# Check for required argument
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <script_to_test>"
  exit 1
fi

SCRIPT="$1"

fail() {
  echo "❌ Test failed: $1"
  exit 1
}

pass() {
  echo "✅ $1"
}

# Run the script and capture output
output="$($SCRIPT)"

# Test 1: Output count is 10
count=$(echo "$output" | wc -l | tr -d ' ')

if [[ "$count" -ne 10 ]]; then
  fail "Expected 10 numbers, got $count"
else
  pass "Correct number of lines (10)"
fi

# Test 2: Numbers are within range 1–10
invalid=$(echo "$output" | awk '$1 < 1 || $1 > 10')

if [[ -n "$invalid" ]]; then
  fail "Found numbers outside range 1–10"
else
  pass "All numbers within range"
fi

# Test 3: No duplicates
duplicates=$(echo "$output" | sort | uniq -d)

if [[ -n "$duplicates" ]]; then
  fail "Duplicate numbers found"
else
  pass "No duplicates"
fi

# Test 4: Contains all numbers 1–10
missing=$(comm -23 <(seq 1 10 | sort) <(echo "$output" | sort))

if [[ -n "$missing" ]]; then
  fail "Missing numbers: $missing"
else
  pass "All numbers 1–10 present"
fi

echo "🎉 All tests passed!"
