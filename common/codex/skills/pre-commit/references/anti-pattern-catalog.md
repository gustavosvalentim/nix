# Anti-Pattern Catalog

Use this catalog during manual review of changed files. Classify each finding with severity using `references/severity-rubric.md`.

## Correctness and Consistency

- Missing input validation on new or changed entry points.
- Silent error swallowing (`catch`/`except` that hides failures).
- Inconsistent null/empty handling across similar code paths.
- Implicit behavior changes without docs/tests updates.
- Time, timezone, rounding, or precision logic changed without regression coverage.

Preferred fix pattern:

- Add explicit validation and deterministic error paths.
- Preserve existing project conventions unless intentionally changing them.
- Add or update tests for changed behavior.

## Security

- User-controlled input reaches shell execution, SQL, templates, eval-like APIs, or file-system operations.
- Weak crypto/hash usage for security-sensitive paths.
- Insecure defaults in auth/session/cookie/token handling.
- Missing authorization checks around privileged actions.
- Sensitive data logged, returned, or committed.

Preferred fix pattern:

- Validate and sanitize at boundaries.
- Parameterize queries and avoid dynamic command construction.
- Enforce least privilege checks.
- Remove secret exposure and rotate as needed.

## Design and Maintainability

- Tight coupling across modules for simple logic changes.
- Hidden global state or side effects.
- Duplicated business rules diverging across files.
- Large conditionals with unclear ownership of behavior.

Preferred fix pattern:

- Extract focused units with clear interfaces.
- Centralize shared business rules.
- Keep behavior-preserving refactors separate from feature changes when possible.

## Dependency Hygiene

- New dependency added without clear need or maintenance posture.
- Dependency version change with known vulnerability signals.
- Replacement of standard, battle-tested package with unvetted alternative.

Preferred fix pattern:

- Prefer existing dependencies and project-native patterns.
- Use project-native dependency audit commands when configured.
- If no audit command exists, report "dependency audit not configured" as a gap.

## False-Positive Checks

Before marking as critical, confirm:

- The path is reachable in real execution.
- Existing guards are not already enforcing safety.
- The change is not test-only or mock-only code.
