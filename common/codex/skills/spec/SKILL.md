---
name: spec
description: Explicitly invoke with $spec to co-author a concrete SPEC.md through iterative questions until it is ready for development.
---

# Spec

## Overview

Use this skill only when the user explicitly invokes `$spec`.
Co-author a concrete `SPEC.md` with the user, asking focused questions as gaps appear, and stop once readiness is confirmed.

## When To Use

- The user explicitly asks for `$spec ...`.
- The user wants to collaboratively shape a feature spec before any coding.
- A repo needs structured readiness checks before development starts.

## When Not To Use

- The user did not explicitly invoke `$spec`.
- The request is only analysis, brainstorming, or documentation without readiness checks.
- The task is a quick one-off fix that does not require a full spec-readiness loop.

## Invocation

- Default: `$spec "Implement <feature>"`
- Optional spec path: `$spec --spec-path docs/SPEC.md "Implement <feature>"`

## Required Workflow

1. Create or update the spec file (`SPEC.md` by default, or the provided path).
2. Start a collaborative drafting loop immediately:
   - Ask only the most important missing questions.
   - Ask at most 7 questions per round.
   - Prefer concrete choices and tradeoff-focused prompts over open-ended prompts.
3. After each user response round:
   - Update the spec with decisions and assumptions.
   - Run `scripts/spec_ready.sh <spec-path>`.
4. If readiness is `NOT_READY`, ask the next batch of missing questions and repeat step 3.
5. Continue until one of these conditions is true:
   - The script returns `READY`.
   - The user explicitly says `spec is ready` or `ship it` (force override).
6. If force override is used, append a dated entry to `DECISIONS.md` that records:
   - The exact override phrase.
   - Outstanding gaps.
   - The user's explicit instruction to proceed.
7. Stop at spec handoff:
   - Provide a concise readiness summary.
   - List any unresolved risks or assumptions.
   - Do not start planning or implementation unless the user explicitly asks in a new instruction.

## Collaboration Rules

- Keep the user in the loop while the spec is being written; do not draft the full final spec silently first.
- Ask questions throughout spec construction, not only after a full draft is complete.
- Each question must map to a specific missing readiness item or decision point.
- If a reasonable default exists, propose it and ask for confirmation instead of asking broad questions.
- Do not ask "Can I start implementation?" as the default close; end at "spec ready for development" unless asked to continue.

## Readiness Rules

`scripts/spec_ready.sh` must enforce:

- Required sections exist and are concrete:
  - Problem
  - Non-goals
  - Acceptance Criteria (contains MUST/SHOULD/MAY)
  - Interfaces/examples (if applicable)
  - Edge cases
  - Constraints
  - Definition of Done
  - Test Plan
- At least 1 happy-path example and 2 edge cases are documented.
- Required sections do not contain placeholders such as `TBD`.

## Script Usage Contract

- Use `scripts/spec_ready.sh` for deterministic readiness status.
- Use `scripts/validate_skill.sh` when validating the skill itself.

Do not replace these scripted checks with improvised manual logic.
