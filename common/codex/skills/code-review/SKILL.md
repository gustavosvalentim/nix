---
name: code-review
description: Run structured code reviews that surface security, correctness, reliability, and test-coverage risks with severity-rated findings and concrete fixes.
---

# Code Review

## Overview

Use this skill when the user asks for a review of a diff, pull request, commit range, or file set.
Prioritize high-risk defects first and return findings in a strict, actionable Markdown format.
Default to diff-based review, then expand one hop into neighboring code when behavior depends on unchanged call paths.

## When To Use

- The user asks for a code review, audit, or pre-merge risk check.
- The user wants severity-ranked findings and concrete remediation guidance.
- The user wants explicit coverage checks for business-logic tests.

## When Not To Use

- The user only wants style polishing or refactoring ideas without risk analysis.
- No code is provided and the user does not want a checklist-only preliminary review.

## Required Inputs

- Code under review (diff, PR, files, or commit range)
- Runtime/language context if non-obvious
- Security/compliance constraints, if applicable

If context is missing, state assumptions and continue with a best-effort review.

## Core Workflow

1. Scope the review:
- Inspect changed files and critical execution paths.
- Identify trust boundaries, external inputs, data stores, and privileged operations.
- Record assumptions when context is missing.

2. Security pass (highest priority):
- Check for OWASP/CWE-class weaknesses: injection, auth/authz flaws, secret leakage, unsafe crypto, insecure deserialization, path traversal, SSRF, and unsafe eval/command execution.
- Flag risky defaults and missing validation/sanitization.

3. Reliability pass:
- Find unhandled exceptions, swallowed errors, and missing failure-path handling.
- Verify cleanup/rollback behavior and safe timeout/retry usage where relevant.

4. Correctness pass:
- Detect incomplete logic branches, edge-case gaps, null/empty-state failures, race conditions, and undefined-behavior risks.

5. Maintainability pass:
- Flag bad practices and code smells that materially increase defect risk (dead code, duplication, hidden side effects, tightly coupled logic, over-complex functions).

6. Test adequacy pass:
- Map each changed business rule to test evidence.
- Report missing tests for business logic, error paths, and security-sensitive flows.
- Treat missing tests for high-risk logic as at least `high` severity unless there is strong justification.

7. Completeness checkpoint (mandatory before reporting):
- Explicitly cover each checklist area below and mark `ok`, `finding`, or `needs-investigation`:
- Input validation and sanitization
- Auth/authz and privilege checks
- Secrets and cryptography usage
- Error/exception handling and fail-safe behavior
- Data integrity and transaction safety
- Undefined or implementation-dependent behavior
- Resource handling (files, sockets, memory, concurrency)
- Business-logic branch completeness
- Test coverage for changed business rules

8. Report findings:
- Sort by severity (`critical`, `high`, `medium`, `low`).
- Include location, impact rationale, concrete fix suggestion, and confidence for each finding.
- If no defects are found, still report residual risk and testing gaps.
- If evidence is suggestive but not conclusive, include it under `Needs Investigation` instead of dropping it.

## Output Contract (Mandatory)

Return the review in this exact Markdown structure:

```md
### Summary
- Overall Risk: `critical|high|medium|low`
- Files Reviewed: `<number>`
- Findings Count: `<number>`
- Assumptions: `<key assumptions or none>`

### Coverage Checklist
- Input validation and sanitization: `ok|finding|needs-investigation`
- Auth/authz and privilege checks: `ok|finding|needs-investigation`
- Secrets and cryptography usage: `ok|finding|needs-investigation`
- Error/exception handling and fail-safe behavior: `ok|finding|needs-investigation`
- Data integrity and transaction safety: `ok|finding|needs-investigation`
- Undefined or implementation-dependent behavior: `ok|finding|needs-investigation`
- Resource handling (files/sockets/memory/concurrency): `ok|finding|needs-investigation`
- Business-logic branch completeness: `ok|finding|needs-investigation`
- Test coverage for changed business rules: `ok|finding|needs-investigation`

### Findings
For each finding:

#### [<severity>] <issue title>
- Where: `<file path + line or symbol (absolute path preferred)>`
- Why: `<why this is a problem and likely impact>`
- Suggestion: `<concrete fix or mitigation>`
- Confidence: `high|medium|low`

### Needs Investigation
- `<suspicious pattern requiring more context or runtime verification>`

### Test Coverage
- Business Logic Tests Present: `yes|partial|no`
- Missing Tests:
- `<specific missing case>`
- `<specific missing case>`
```

If there are no findings, write:

```md
### Findings
No findings.
```

If there are no findings, `Coverage Checklist` must still be fully populated.
Always include `Summary`, `Coverage Checklist`, and `Test Coverage`.

## Severity Guidance

- `critical`: exploitable security flaw, auth bypass, severe data loss/corruption, or outage risk.
- `high`: serious vulnerability or correctness bug likely to fail in realistic conditions.
- `medium`: moderate-risk defect or design weakness that should be fixed soon.
- `low`: low-impact issue or technical debt with limited near-term risk.

## Examples

- `$code-review review this PR for security issues, unhandled exceptions, and missing business-logic tests`
- `$code-review audit these changed files and rank findings by severity with fix suggestions`
- `$code-review do a pre-merge review focused on undefined behavior and incomplete logic`

## Common Mistakes To Avoid

- Reporting style nits while missing high-risk defects.
- Omitting exact finding locations.
- Providing vague fix advice that cannot be implemented.
- Claiming tests are adequate without naming specific test evidence.

## References

Apply `references/code-review-best-practices.md` as the source-backed checklist.
