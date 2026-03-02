#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DETECT_SCRIPT="$SCRIPT_DIR/detect_tooling.sh"
INPUT_SOURCE="${1:-}"

if [ ! -x "$DETECT_SCRIPT" ]; then
  echo "ERROR: detect script is missing or not executable: $DETECT_SCRIPT" >&2
  exit 1
fi

TMP_DETECTIONS="$(mktemp)"
trap 'rm -f "$TMP_DETECTIONS"' EXIT

if [ -z "$INPUT_SOURCE" ]; then
  "$DETECT_SCRIPT" > "$TMP_DETECTIONS"
elif [ "$INPUT_SOURCE" = "-" ]; then
  cat > "$TMP_DETECTIONS"
else
  if [ ! -f "$INPUT_SOURCE" ]; then
    echo "ERROR: detection file does not exist: $INPUT_SOURCE" >&2
    exit 1
  fi
  cp "$INPUT_SOURCE" "$TMP_DETECTIONS"
fi

if [ ! -s "$TMP_DETECTIONS" ]; then
  echo "ERROR: no tooling detected; nothing to run." >&2
  exit 1
fi

HAS_TEST=0
while IFS='|' read -r tool check_type command; do
  if [ -z "${tool:-}" ] || [ -z "${check_type:-}" ] || [ -z "${command:-}" ]; then
    echo "ERROR: invalid detection line (expected tool|type|command)." >&2
    exit 1
  fi

  executable="${command%% *}"
  if ! command -v "$executable" >/dev/null 2>&1; then
    echo "ERROR: detected command is unavailable: $command" >&2
    exit 1
  fi

  if [ "$check_type" = "test" ]; then
    HAS_TEST=1
  fi
done < "$TMP_DETECTIONS"

if [ "$HAS_TEST" -ne 1 ]; then
  echo "ERROR: no test command detected. Aborting." >&2
  exit 1
fi

for phase in test lint; do
  while IFS='|' read -r tool check_type command; do
    [ "$check_type" = "$phase" ] || continue
    echo "[$tool:$check_type] $command"
    if ! eval "$command"; then
      echo "ERROR: command failed for $tool:$check_type -> $command" >&2
      exit 1
    fi
  done < "$TMP_DETECTIONS"
done

echo "All detected checks passed."
