---
name: spec
description: Explicitly invoke with $spec to run a spec-readiness loop before planning, implementation, and verification for a feature workflow.
---

# Spec

## Overview

Use this skill only when the user explicitly invokes `$spec`.
Drive work from a concrete `SPEC.md`, block coding until readiness is confirmed, then plan, implement, and verify against the approved spec.

## When To Use

- The user explicitly asks for `$spec ...`.
- The user wants a feature delivered through a spec-first workflow.
- A repo needs structured readiness checks before implementation.

## When Not To Use

- The user did not explicitly invoke `$spec`.
- The request is only analysis, brainstorming, or documentation without implementation.
- The task is a quick one-off fix that does not require a full spec-readiness loop.

## Invocation

- Default: `$spec "Implement <feature>"`
- Optional spec path: `$spec --spec-path docs/SPEC.md "Implement <feature>"`

## Required Workflow

1. Create or update the spec file (`SPEC.md` by default, or the provided path).
2. Run `scripts/spec_ready.sh <spec-path>`.
3. If readiness is `NOT_READY`:
   - Ask only missing questions.
   - Ask at most 7 questions per round.
   - Update the spec and re-run `scripts/spec_ready.sh`.
4. Repeat step 3 until one of these conditions is true:
   - The script returns `READY`.
   - The user explicitly says `spec is ready` or `ship it` (force override).
5. If force override is used, append a dated entry to `DECISIONS.md` that records:
   - The exact override phrase.
   - Outstanding gaps.
   - The user's explicit instruction to proceed.
6. Generate `PLAN.md` from the final spec with implementation steps and checkpoints.
7. Implement strictly according to `SPEC.md` and `PLAN.md`.
8. Run checks using scripts, not ad-hoc guessing:
   - `scripts/detect_tooling.sh`
   - `scripts/run_checks.sh`
9. Deliver a PR-style summary including:
   - What changed.
   - Why it changed.
   - Which checks ran and their results.
   - Full list of touched files.

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
- Use `scripts/detect_tooling.sh` to detect available tooling and recommended commands.
- Use `scripts/run_checks.sh` to execute only detected commands.
- Use `scripts/validate_skill.sh` when validating the skill itself.

Do not replace these scripted checks with improvised manual logic.
