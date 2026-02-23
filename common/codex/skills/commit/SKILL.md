---
name: commit
description: Review changed code, run project-native checks, fix issues, and then create a conventional commit. Use when the user asks to validate changes before commit, clean up before commit, review code before committing, or make the commit.
metadata:
  short-description: Pre-commit remediation plus conventional commits
---

# Commit Workflow

## Purpose

Run a high-signal pre-commit workflow that finds and fixes issues, then creates a clean conventional commit. Do not push.

## Required Review Topics

- Code Quality: separation of concerns; error handling; type safety; DRY; edge cases.
- Architecture: design soundness; scalability; performance; security.
- Testing: coverage of real logic and edge cases; integration tests where needed.
- Requirements: implementation matches spec; no unintended scope creep; breaking changes documented.
- Production Readiness: migration safety; backward compatibility; docs completeness.
- YAGNI: avoid speculative or unused functionality.

## Acceptance Criteria (Mandatory)

- All discovered verification commands complete successfully (`pass`): tests, lint/static analysis, typecheck, format checks, build, and security/audit checks when defined by the repo.
- Changed behavior in the diff is fully covered by automated tests; every non-trivial behavior change maps to at least one test case.
- If existing tests do not adequately cover the diff, new or updated tests are added in the repository's native test framework before committing.
- No check may be reported as passed without execution evidence.
- Commit is blocked until all required checks and test-coverage expectations above are satisfied, unless the user explicitly approves proceeding with documented blockers.

## Workflow

1. Inspect repo state and changed files (`git status --short`, `git diff`, `git diff --staged`).
2. Summarize risk: blast radius, failure modes, rollback path, risk level.
3. Manually review against Required Review Topics and project conventions.
4. Build the check plan by discovering exact repo-native verification commands from project files.
5. Run every discovered verification command in order: tests, lint/static, typecheck, dead-code, format check, build, audit.
6. If no verification commands can be discovered, explicitly report that and ask the user whether to continue without verification.
7. Evaluate test adequacy for the diff by mapping each changed behavior to existing automated tests.
8. If coverage is insufficient for any changed behavior, add or update tests to close the gap before committing.
9. Fix all issues found. If a fix needs product input, stop and ask.
10. Re-run affected checks and repeat until no issues remain.
11. Confirm all Acceptance Criteria are satisfied.
12. Stage intentionally (`git add <file>`, `git add -p`) and verify staged diff.
13. Create a Conventional Commit message and run `git commit` without additional confirmation. Do not push.
14. Verify commit with `git show` and `git log --oneline -5`.

## Verification Command Discovery (Mandatory)

- Prefer explicit commands defined by the repository, in this priority:
- `package.json` scripts (for example `test`, `lint`, `typecheck`, `check`, `build`, `format:check`, `format`).
- `Makefile`/`Taskfile` verify targets (for example `test`, `lint`, `check`, `build`, `verify`).
- Tool configs and project docs that define canonical commands.
- Only use language-default commands (for example `go test ./...`, `pytest`) when project conventions clearly indicate them.
- Do not claim verification is complete if command discovery was skipped.

## Verification Evidence (Mandatory)

- For each verification command, record:
- Exact command executed.
- Status (`pass` or `fail`).
- Evidence (exit code and a key output line).
- If a command cannot run because of environment constraints, report it as a blocker with exact error text.

## Conventional Commit Rules

- Format: `type(scope): subject`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`.
- Subject: imperative mood, lowercase, no trailing period, ideally under 50 chars.
- Body: explain what and why (not how); wrap near 72 chars.
- Footer: use for `BREAKING CHANGE:` and issue references like `Fixes #123`.

## Rules

- Always fix issues found by review and checks before reporting ready.
- Treat inadequate test coverage for changed behavior as a blocking issue that must be fixed by adding/updating tests.
- Do not claim a check passed unless it was run and evidenced.
- Prefer repo-defined commands over guessed defaults.
- Keep fixes minimal and aligned to existing conventions.
- Do not rewrite history or run destructive git operations unless explicitly requested.
- Do not push commits.

## Output Format

### Strengths
[Specific positives observed in reviewed code]

### Issues Fixed
[Issue list with file:line, why it mattered, and what was changed]

### Remaining Issues
[Only items blocked on product decisions or external constraints]

### Checks Run
[Command-by-command status and key evidence]

### Commit
[If created: commit hash and message; otherwise: "Not requested"]

### Assessment

**Ready to merge?** [Yes/No/With caveats]

**Reasoning:** [1-2 sentences]
