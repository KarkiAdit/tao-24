#!/usr/bin/env bash
# Asserts guard-bash.sh behaves. Run from the repo root: bash .claude/hooks/hooks-smoke-test.sh
#
# The critical assertion is the "allowed" set producing EMPTY output. A hook
# that answers "allow" for anything it doesn't recognise would silently switch
# off the permission prompt for every other command.

HOOK=".claude/hooks/guard-bash.sh"
pass=0
fail=0

check() { # check <expect: deny|silent> <description> <command>
  local expect="$1" desc="$2" cmd="$3" out
  out=$(python3 -c 'import json,sys; print(json.dumps({"tool_input":{"command":sys.argv[1]}}))' "$cmd" | bash "$HOOK")
  local got="silent"
  [ -n "$out" ] && got="deny"
  if [ "$got" = "$expect" ]; then
    pass=$((pass+1)); printf '  ok    %-46s -> %s\n' "$desc" "$got"
  else
    fail=$((fail+1)); printf '  FAIL  %-46s -> %s (expected %s)\n' "$desc" "$got" "$expect"
  fi
}

echo "must DENY:"
check deny "destroy root"              "$(printf 'rm -rf /')"
check deny "destroy root mid-command"  "$(printf 'cd /tmp && rm -rf /')"
check deny "destroy home"              "$(printf 'rm -rf ~')"
check deny "glob wipe"                 "$(printf 'rm -rf *')"
check deny "fork bomb"                 "$(printf ':(){ :|:& };:')"
check deny "force-push main"           "$(printf 'git push --force origin main')"
check deny "format disk"               "$(printf 'mkfs.ext4 /dev/sdb')"

echo "must stay SILENT (fall through to the normal permission prompt):"
check silent "build"                   "xcodebuild -scheme App build"
check silent "legit recursive delete"  "$(printf 'rm -rf /Users/me/proj/build')"
check silent "legit relative delete"   "$(printf 'rm -rf ./DerivedData')"
check silent "ordinary git push"       "git push origin feature/x"
check silent "listing"                 "ls -la"
check silent "empty command"           ""

echo
echo "passed: $pass   failed: $fail"
[ "$fail" -eq 0 ]
