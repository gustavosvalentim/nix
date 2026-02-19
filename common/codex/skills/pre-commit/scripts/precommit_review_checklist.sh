#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

echo "# Pre-commit Review Checklist"
echo

echo "## Repository State"
echo
git status --short || true
echo

echo "## Changed Files"
echo
git diff --name-only
git diff --cached --name-only
echo

echo "## Review Categories"
echo
cat <<'EOF'
- [ ] Correctness and consistency checks completed
- [ ] Security checks completed
- [ ] Design and maintainability checks completed
- [ ] Dependency hygiene checks completed
- [ ] Findings classified with severity rubric
EOF
echo

echo "## Project-native Command Discovery"
echo
cat <<'EOF'
- Tests: identify repo-defined test command(s)
- Lint: identify repo-defined lint/static analysis command(s)
- Format: identify repo-defined formatter command(s)
- Build: identify repo-defined build/compile command(s)
- Dependency audit: identify repo-defined dependency audit command(s)
EOF
echo

echo "## Structured Report Template"
echo
cat <<'EOF'
### Findings (Ordered by Severity)
| Severity | Category | Path | Risk Summary | Status |
|---|---|---|---|---|
| critical/non-critical | security/correctness/design/dependency/docs | path/to/file | concise risk statement | fixed/unresolved |

### Critical Fixes Applied
- path/to/file: what changed and why the risk is resolved

### Checks Executed and Status
- tests: pass/fail/not-run (reason)
- lint: pass/fail/not-run (reason)
- format: pass/fail/not-run (reason)
- build: pass/fail/not-run (reason)
- dependency audit: pass/fail/not-configured/not-run (reason)

### Files Changed by Fix Pass
- path/to/file

### Documentation Coverage
- docs updated / follow-up required / not required (with rationale)

### Residual Risks and Follow-ups
- unresolved finding and required next action
EOF
