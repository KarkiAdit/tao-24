#!/usr/bin/env bash
# PostToolUse hook for Edit/Write. Formats the file that was just touched.
#
# Prefers a swift-format on PATH (a project may pin its own version), then
# falls back to the one bundled with the active Xcode / Command Line Tools,
# which isn't symlinked onto PATH but is always toolchain-matched. No-ops
# silently if neither is present.

input=$(cat)
file_path=$(echo "$input" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input', {}).get('file_path', ''))" 2>/dev/null)

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

case "$file_path" in
  *.swift)
    if command -v swift-format >/dev/null 2>&1; then
      swift-format format -i "$file_path" >/dev/null 2>&1
    elif xcrun --find swift-format >/dev/null 2>&1; then
      xcrun swift-format format -i "$file_path" >/dev/null 2>&1
    fi
    ;;
esac

exit 0
