---
name: planning
description: Build implementation plans grounded in current documentation and project context. Use when the user asks for a technical plan, architecture proposal, migration strategy, feature design, refactor approach, or tradeoff analysis. Require Context7 documentation lookup for relevant libraries/frameworks, align recommendations with current project patterns, and present multiple design options with clear pros/cons when more than one valid approach exists.
---

# Planning

Create high-quality implementation plans before coding. Ground decisions in up-to-date docs, project conventions, and explicit tradeoffs.

## Workflow

1. Clarify scope and constraints.
2. Inspect current project patterns.
3. Fetch current documentation with Context7.
4. Generate architecture options when multiple designs are viable.
5. Recommend one approach with rationale.
6. Produce a concrete execution plan.

## 1) Clarify Scope and Constraints

Capture:

- Goal and expected outcome
- Functional and non-functional requirements
- Constraints (timeline, compatibility, performance, security, team preferences)
- Unknowns and assumptions

If key constraints are missing, ask focused follow-up questions.

## 2) Inspect Existing Project Patterns

Read relevant files before proposing architecture:

- Build and dependency files (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`)
- Existing modules for similar features
- Lint/format/test config and CI workflows
- Project structure and naming conventions

Prefer plans that extend existing patterns over introducing new frameworks or paradigms without justification.

## 3) Use Context7 for Current Documentation (Required)

For each important dependency/framework in the plan:

1. Resolve library ID with `mcp__context7__resolve-library-id`.
2. Query docs with `mcp__context7__query-docs` using focused questions.
3. Base recommendations on documented, current APIs and best practices.

Do not rely on memory when library behavior or APIs may have changed.
If documentation is ambiguous, state the uncertainty explicitly in the plan.

## 4) Provide Design Options When Multiple Approaches Exist

When there are materially different designs, present at least 2 options.
For each option, include:

- Architecture summary
- Pros
- Cons
- Complexity and delivery risk
- Fit with current project patterns
- Migration/rollback considerations (if applicable)

Avoid fake options. If one approach is clearly dominant, still mention alternatives briefly and explain why they were rejected.

## 5) Recommend an Approach

Select the best option and justify it using:

- Idiomatic patterns for the stack
- Team/project consistency
- Maintainability and extensibility
- Operational risk and testing strategy

## 6) Output Plan Format

Always provide:

- Scope summary
- Assumptions and open questions
- Architecture decision and alternatives
- Step-by-step implementation plan
- Data model/API/interface changes (if any)
- Test strategy (unit/integration/e2e as relevant)
- Rollout and rollback strategy (when relevant)
- Risks and mitigations

Keep plans actionable and implementation-ready.
