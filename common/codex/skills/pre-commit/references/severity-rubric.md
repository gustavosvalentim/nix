# Severity Rubric

Use this rubric to classify findings consistently before deciding whether to fix.

## Critical

Treat as critical when any of the following are true:

- Security risk is high or medium with realistic abuse potential.
- Authorization/authentication controls are bypassable or missing.
- Input can reach shell/SQL/template/deserialization sinks without robust controls.
- Secrets, credentials, tokens, or sensitive identifiers are exposed.
- Data can be corrupted, deleted, or irreversibly miscomputed.
- Dependency audit (project-native) reports a high-confidence exploitable issue.

Required action:

- Fix in the same run.
- Re-run affected checks.
- If safe fix is unclear, block and escalate with rationale.

## Non-critical

Treat as non-critical when:

- Issue is maintainability/design quality without immediate security/correctness impact.
- Issue is low-risk anti-pattern with no realistic abuse path.
- Issue is style or readability only.
- Risk is speculative and confidence is low.

Required action:

- Report with rationale and suggested fix.
- Do not auto-fix unless user explicitly requests non-critical fixes.

## Confidence Gates

Apply fixes only when confidence is high:

- Root cause is identified.
- Fix scope is narrow and testable.
- Behavior change is intentional and validated.

Escalate instead of guessing when:

- Product intent is ambiguous.
- Security impact is plausible but uncertain.
- Fix requires architectural changes beyond the current scope.
