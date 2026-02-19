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
- [ ] Dead-code checks completed
- [ ] Runtime safety checks completed
- [ ] Data/privacy checks completed
- [ ] Dependency hygiene checks completed
- [ ] Findings classified with severity rubric
- [ ] Change-risk gate completed
EOF
echo

echo "## Project-native Command Discovery"
echo
cat <<'EOF'
- Tests: identify repo-defined test command(s)
- Lint: identify repo-defined lint/static analysis command(s)
- Dead code: identify dead-code-capable command(s) and mark "not configured" if unavailable
- Format: identify repo-defined formatter command(s)
- Build: identify repo-defined build/compile command(s)
- Dependency audit: identify repo-defined dependency audit command(s)
EOF
echo

echo "## Structured Report Template"
echo
cat <<'EOF'
### Change-Risk Assessment
- changed surface(s):
- blast radius:
- failure modes:
- rollback path:
- risk level: low/medium/high (with rationale)

### Findings (Ordered by Severity)
| Severity | Category | Path | Scope | Risk Summary | Status |
|---|---|---|---|---|---|
| critical/non-critical | security/correctness/design/dependency/docs | path/to/file | changed/pre-existing | concise risk statement | fixed/unresolved |

### Critical Fixes Applied
- path/to/file: what changed and why the risk is resolved

### Checks Executed and Status
- tests: pass/fail/not-run (reason) | command: ... | exit: ... | key signal: ...
- lint: pass/fail/not-run (reason) | command: ... | exit: ... | key signal: ...
- dead code: pass/fail/not-configured/not-run (reason) | command: ... | exit: ... | key signal: ...
- format: pass/fail/not-run (reason) | command: ... | exit: ... | key signal: ...
- build: pass/fail/not-run (reason) | command: ... | exit: ... | key signal: ...
- dependency audit: pass/fail/not-configured/not-run (reason) | command: ... | exit: ... | key signal: ...

### Files Changed by Fix Pass
- path/to/file

### Documentation Coverage
- docs updated / follow-up required / not required (with rationale)

### Residual Risks and Follow-ups
- unresolved finding, owner, and required next action

### Release Readiness Verdict
- ready / ready-with-risks / blocked (with rationale)
EOF
