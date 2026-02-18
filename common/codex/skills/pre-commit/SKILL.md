---
name: pre-commit
description: Perform pre-commit validation without creating a commit by running local code review, formatters, linters, tests, and build checks, then producing a detailed summary of all changes with issues, risks, and implementation considerations. Use when the user asks to "run pre-commit checks", "validate changes before commit", "clean up before commit", "review code before commit", or any request that combines verification + quality review without committing.
---

# Pre-commit

## Overview

Execute a full pre-commit workflow: review changes, run project checks, repair failures, re-run checks until passing, and deliver a detailed validation summary. Do not create a commit in this skill.

## Workflow

1. Inspect current repository state.
- Run `git status --short`.
- Review changed files and staged vs unstaged state.
- Identify likely stack and tooling from files like `Makefile`, `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, and CI configs.

2. Perform a code review before automation.
- Read modified files and look for obvious bugs, regressions, missing validation, or unsafe behavior.
- Prioritize correctness and behavior over style.
- Keep comments only on business logic that is hard to read or complex.
- For each meaningful code change, verify documentation is updated where needed (for example `README*`, `docs/**`, runbooks, ADRs, API docs, config guides, migration notes).
- If documentation is missing or stale for a behavior/config/API change, report it as a finding and propose the exact docs that should be updated.

3. Build the check plan from project-native commands.
- Prefer repository-defined commands first (`make`, npm/pnpm scripts, task runners, documented commands).
- Fallback to language defaults only when project commands are unavailable.

4. Run checks in this order.
- Tests.
- Linters/static analysis.
- Formatters.
- Build/compile checks if available.

5. Fix issues and iterate.
- Address all actionable failures.
- If there were changes since step 4, re-run affected checks immediately.
- If there were changes since step 4, re-run the full check chain before committing.

6. Prepare final validation summary.
- Summarize what was reviewed, what failed, and what was fixed.
- Include final status of format/lint/test/build checks.
- Enumerate all meaningful file-level changes and behavior impacts.
- Include a documentation coverage section: map important code changes to corresponding docs updates, or explicitly state why no docs update is required.
- Include notes on issues, risks, assumptions, and code considerations (maintainability, edge cases, config hardcoding, security/privacy concerns, and test coverage gaps).
- If useful, include a suggested Conventional Commit message, but do not run `git commit`.

## Command Selection Heuristics

- Prefer explicit project instructions over guessed defaults.
- If multiple toolchains exist, follow the one used by CI/workflow files.
- If no test or lint command exists, report that clearly instead of inventing fake success.
- Never claim checks passed unless they were actually run successfully.

## Safety Rules

- Do not use destructive git operations unless explicitly requested.
- Do not rewrite history unless explicitly requested.
- Stop and ask the user if blockers require product decisions (for example, conflicting intended behavior).

## Output Contract

Always provide:
- Findings from manual review (ordered by severity).
- Checks executed and their final status.
- Files changed by the fix pass.
- Detailed summary of all meaningful code changes and expected behavior impact.
- Documentation coverage result for changed code (updated docs, required docs follow-ups, or explicit "not required" rationale).
- Notes about issues or considerations (risk, follow-up work, potential regressions, test gaps).
- Any remaining risks or follow-up work.
