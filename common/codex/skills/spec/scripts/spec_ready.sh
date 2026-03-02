#!/usr/bin/env bash
set -euo pipefail

SPEC_FILE="${1:-SPEC.md}"

if [ ! -f "$SPEC_FILE" ]; then
  echo "NOT_READY"
  echo "Missing spec file: $SPEC_FILE" >&2
  exit 2
fi

declare -a ISSUES=()

has_section() {
  local heading_regex="$1"
  awk -v re="$heading_regex" '
    function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
    /^[[:space:]]*#{1,6}[[:space:]]*/ {
      title = $0
      sub(/^[[:space:]]*#{1,6}[[:space:]]*/, "", title)
      title = tolower(trim(title))
      if (title ~ re) { found = 1; exit }
    }
    END { exit(found ? 0 : 1) }
  ' "$SPEC_FILE"
}

extract_section() {
  local heading_regex="$1"
  awk -v re="$heading_regex" '
    function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
    /^[[:space:]]*#{1,6}[[:space:]]*/ {
      title = $0
      sub(/^[[:space:]]*#{1,6}[[:space:]]*/, "", title)
      title = tolower(trim(title))
      if (in_section) { exit }
      if (title ~ re) { in_section = 1; next }
    }
    in_section { print }
  ' "$SPEC_FILE"
}

check_required_section() {
  local label="$1"
  local re="$2"

  if ! has_section "$re"; then
    ISSUES+=("Missing required section: $label")
    return
  fi

  local content
  content="$(extract_section "$re" | sed '/^[[:space:]]*$/d')"
  if [ -z "$content" ]; then
    ISSUES+=("Section is empty: $label")
    return
  fi

  local compact
  compact="$(printf '%s' "$content" | tr -d '[:space:]')"
  if [ "${#compact}" -lt 25 ]; then
    ISSUES+=("Section is not concrete enough: $label")
  fi

  if printf '%s' "$content" | grep -Eqi '(^|[^[:alnum:]_])(TBD|TODO|XXX|FIXME|PLACEHOLDER)([^[:alnum:]_]|$)'; then
    ISSUES+=("Section contains placeholder text: $label")
  fi
}

check_required_section "Problem" '^problem$'
check_required_section "Non-goals" '^non[- ]goals?$'
check_required_section "Acceptance Criteria" '^acceptance criteria$'
check_required_section "Edge cases" '^edge cases?$'
check_required_section "Constraints" '^constraints?$'
check_required_section "Definition of Done" '^definition of done$'
check_required_section "Test Plan" '^test plan$'

if ! has_section '^interfaces?(\/examples?)?$' && ! has_section '^examples?$'; then
  ISSUES+=("Missing required section: Interfaces/examples")
fi

if has_section '^interfaces?(\/examples?)?$'; then
  check_required_section "Interfaces/examples" '^interfaces?(\/examples?)?$'
fi
if has_section '^examples?$'; then
  check_required_section "Examples" '^examples?$'
fi

AC_CONTENT="$(extract_section '^acceptance criteria$')"
AC_UPPER="$(printf '%s' "$AC_CONTENT" | tr '[:lower:]' '[:upper:]')"
for keyword in MUST SHOULD MAY; do
  if ! printf '%s' "$AC_UPPER" | grep -Eq "(^|[^A-Z])${keyword}([^A-Z]|$)"; then
    ISSUES+=("Acceptance Criteria must include keyword: $keyword")
  fi
done

HAPPY_PATH_COUNT="$(grep -Eic 'happy[[:space:]-]*path' "$SPEC_FILE" || true)"
if [ "$HAPPY_PATH_COUNT" -lt 1 ]; then
  ISSUES+=("At least one happy-path example is required")
fi

EDGE_SECTION="$(extract_section '^edge cases?$')"
EDGE_LIST_COUNT="$(printf '%s\n' "$EDGE_SECTION" | grep -Ec '^[[:space:]]*([-*]|[0-9]+\.)[[:space:]]+' || true)"
EDGE_PHRASE_COUNT="$(grep -Eic 'edge[[:space:]-]*case' "$SPEC_FILE" || true)"
if [ "$EDGE_LIST_COUNT" -lt 2 ] && [ "$EDGE_PHRASE_COUNT" -lt 2 ]; then
  ISSUES+=("At least two edge cases are required")
fi

if [ "${#ISSUES[@]}" -gt 0 ]; then
  echo "NOT_READY"
  printf 'Readiness issues:\n' >&2
  for issue in "${ISSUES[@]}"; do
    printf ' - %s\n' "$issue" >&2
  done
  exit 2
fi

echo "READY"
