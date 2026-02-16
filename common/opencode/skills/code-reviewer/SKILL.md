---
name: code-reviewer
description: Structured code review of diffs, pull requests, or file sets with focus on correctness, security, performance, maintainability, tests, and risk. Use when asked to review a PR, audit changes, assess risks, or provide a thorough code review report.
---

# Code Reviewer

Provide rigorous, practical code reviews that identify risks, bugs, and quality issues with clear severity and test guidance.

## Workflow

1. Establish context
   - Identify intent from PR description, issue link, or commit messages.
   - If intent is unclear, infer from diff and state assumptions.
   - Note scope: files touched, entry points, user-visible changes.

2. Map the change surface
   - Trace data flow and control flow through new or modified code.
   - Identify risk hotspots (auth, data writes, concurrency, migrations, external APIs).

3. Review passes (use checklist as needed)
   - Correctness and edge cases
   - Error handling and observability
   - Security and privacy
   - Performance and resource use
   - API/contract and backward compatibility
   - Tests and coverage
   - Maintainability and readability

4. Produce findings with severity
   - Label findings with: Blocker, Major, Minor, Nit, Question.
   - Prefer a few high-signal findings over exhaustive nits.

5. Recommend tests and verification
   - Call out missing tests and propose specific cases.
   - Mention quick manual verification steps if relevant.

## Severity scale

- Blocker: correctness, security, data integrity, or breaking change issues that must be fixed before merge.
- Major: significant risk or likely bug; should be addressed before merge.
- Minor: improvement or small risk; fix if time permits.
- Nit: style or clarity suggestions; optional.
- Question: clarification needed to validate assumptions.

## Output format

Use the template in `references/review-template.md`.
If the review is small, keep sections concise but preserve the order.

## References

- Use `references/review-checklist.md` for detailed prompts.

## Guardrails

- Default to review-only. Do not modify code unless explicitly asked.
- Be direct and respectful; keep sarcasm minimal and dry.
- If context is missing but review can proceed, state assumptions and continue.
- If context blocks the review, ask one targeted question.
