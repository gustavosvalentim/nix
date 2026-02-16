# Review Checklist

Use this as a prompt list, not a rigid form. Prioritize areas based on change risk.

## Intent and scope
- Does the change match the described intent?
- Is any unrelated functionality modified?
- Are there existing components that could be reused?

## Correctness and edge cases
- Does the logic behave as intended for normal and extreme inputs?
- Are boundary conditions covered (empty, null, zero, max, large input)?
- Are time, timezone, locale, and encoding handled correctly?
- Are idempotency and retries safe where needed?

## Error handling and observability
- Are failures handled and surfaced appropriately?
- Are error messages useful to users and operators?
- Is logging adequate without leaking sensitive data?
- Are metrics or traces needed for high-risk paths?

## Security and privacy
- Is authentication/authorization correct and enforced at the right layer?
- Is input validated, sanitized, and escaped?
- Are secrets avoided in code, logs, or errors?
- Is sensitive data stored and transmitted safely (encryption, redaction)?

## Performance and resource use
- Any obvious inefficiencies (N+1, unbounded loops, heavy allocations)?
- Does the change add unnecessary dependencies or increase startup cost?
- Are caches, batching, or streaming needed for large data?

## Data integrity and concurrency
- Are database writes atomic and consistent?
- Are transactions used where needed?
- Are race conditions or deadlocks possible?
- Are migrations backward compatible and safe to roll back?

## API/contract and compatibility
- Are API responses stable and documented?
- Are breaking changes flagged and versioned?
- Are schema or config changes compatible with existing clients?

## Tests and coverage
- Are new tests added for new behavior?
- Do tests cover regressions and edge cases?
- Are flaky or slow tests introduced?

## Maintainability and readability
- Is the code modular and at the right abstraction level?
- Can the design be simplified?
- Are names and file placement intuitive?
- Are comments accurate and necessary?

## UI/UX and accessibility (if applicable)
- Is the UI behavior intuitive and consistent?
- Are accessibility concerns addressed (contrast, keyboard, aria)?

## Sources
- https://github.com/mgreiler/code-review-checklist
- https://github.com/andela/code-review-guidelines
