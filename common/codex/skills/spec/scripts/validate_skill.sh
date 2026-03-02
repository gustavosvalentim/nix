#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_MD="$SKILL_DIR/SKILL.md"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

[ -f "$SKILL_MD" ] || fail "SKILL.md is missing at $SKILL_MD"

FIRST_LINE="$(sed -n '1p' "$SKILL_MD")"
[ "$FIRST_LINE" = "---" ] || fail "SKILL.md must start with YAML frontmatter (---)"

FRONTMATTER="$(awk '
  NR == 1 && $0 == "---" { in_frontmatter = 1; next }
  in_frontmatter && $0 == "---" { exit }
  in_frontmatter { print }
' "$SKILL_MD")"

[ -n "$FRONTMATTER" ] || fail "Frontmatter block is empty or missing closing ---"

if ! printf '%s\n' "$FRONTMATTER" | awk '
  /^[[:space:]]*name:[[:space:]]*[^[:space:]].*$/ { found = 1 }
  END { exit(found ? 0 : 1) }
'; then
  fail "Frontmatter must include non-empty name"
fi

if ! printf '%s\n' "$FRONTMATTER" | awk '
  /^[[:space:]]*description:[[:space:]]*[^[:space:]].*$/ { found = 1 }
  END { exit(found ? 0 : 1) }
'; then
  fail "Frontmatter must include non-empty description"
fi

if ! printf '%s\n' "$FRONTMATTER" | awk '
  /^[[:space:]]*$/ { next }
  /^[[:space:]]*#/ { next }
  /^[[:space:]]*[A-Za-z0-9_-]+:[[:space:]]*.*$/ { next }
  { bad = 1 }
  END { exit(bad ? 1 : 0) }
'; then
  fail "Frontmatter is not parseable as simple YAML key/value lines"
fi

if ! printf '%s\n' "$FRONTMATTER" | awk '
  /^[[:space:]]*name:[[:space:]]*spec[[:space:]]*$/ { ok = 1 }
  END { exit(ok ? 0 : 1) }
'; then
  fail "Frontmatter name must be: spec"
fi

REQUIRED_SCRIPTS=(
  "spec_ready.sh"
  "detect_tooling.sh"
  "run_checks.sh"
  "validate_skill.sh"
)

for script_name in "${REQUIRED_SCRIPTS[@]}"; do
  script_path="$SCRIPT_DIR/$script_name"
  [ -f "$script_path" ] || fail "Missing required script: $script_name"
  [ -x "$script_path" ] || fail "Script is not executable: $script_name"
done

echo "VALID"
echo "skill_dir=$SKILL_DIR"
echo "skill_md=$SKILL_MD"
echo "scripts_ok=${#REQUIRED_SCRIPTS[@]}"
