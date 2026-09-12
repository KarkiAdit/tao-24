#!/usr/bin/env bash
# PreToolUse hook for the Bash tool. Coarse safety net, not a sandbox.
#
# Layering: settings.json `permissions.deny` uses prefix globs, so it only
# catches a destructive command at the very start of the string. This hook
# matches anywhere in the command, catching cases like `cd /tmp && <destroy>`
# that sail past a glob. Keep both — they cover different shapes, and neither
# is sufficient alone.
#
# Contract: emit a deny decision on match, otherwise exit silently so the
# normal permission flow still runs. Never emit "allow" here — that would
# auto-approve every command this list happens not to mention.

input=$(cat)
command=$(echo "$input" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input', {}).get('command', ''))" 2>/dev/null)

[ -z "$command" ] && exit 0

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Blocked by guard-bash.sh: matches denylisted pattern %s"}}\n' "$1"
  exit 0
}

# Literal substrings (grep -F). Metacharacter-heavy payloads belong here:
# under -E the fork bomb is invalid syntax and silently never matches.
literal_patterns=(
  ':(){ :|:& };:'
  '> /dev/sda'
  'mkfs.'
  'git push --force origin main'
  'git push --force origin master'
)

# Regex patterns (grep -E), anchored on the argument so destroying root is
# denied while a legitimate recursive delete inside the project still runs.
regex_patterns=(
  'rm[[:space:]]+-[a-zA-Z]*[rf][a-zA-Z]*[[:space:]]+/([[:space:]]|$)'
  'rm[[:space:]]+-[a-zA-Z]*[rf][a-zA-Z]*[[:space:]]+~/?([[:space:]]|$)'
  'rm[[:space:]]+-[a-zA-Z]*[rf][a-zA-Z]*[[:space:]]+\*'
)

for pattern in "${literal_patterns[@]}"; do
  echo "$command" | grep -qF -- "$pattern" && deny "$pattern"
done

for pattern in "${regex_patterns[@]}"; do
  echo "$command" | grep -qE -- "$pattern" && deny "$pattern"
done

exit 0
