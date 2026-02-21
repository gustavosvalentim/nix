---
name: commit
description: Review changed code, run project-native checks, fix issues, and then create a conventional commit when requested. Use when the user asks to validate changes before commit, clean up before commit, review code before committing, or make the commit.
metadata:
  short-description: Pre-commit remediation plus conventional commits
---

# Commit Workflow

## Purpose

Run a high-signal pre-commit workflow that finds and fixes issues, then creates a clean conventional commit when requested.

## Required Review Topics

- Code Quality: separation of concerns; error handling; type safety; DRY; edge cases.
- Architecture: design soundness; scalability; performance; security.
- Testing: coverage of real logic and edge cases; integration tests where needed.
- Requirements: implementation matches spec; no unintended scope creep; breaking changes documented.
- Production Readiness: migration safety; backward compatibility; docs completeness.
- YAGNI: avoid speculative or unused functionality.

## Workflow

1. Inspect repo state and changed files (`git status --short`, `git diff`, `git diff --staged`).
2. Summarize risk: blast radius, failure modes, rollback path, risk level.
3. Manually review against Required Review Topics and project conventions.
4. Build the check plan by discovering exact repo-native verification commands from project files.
5. Run every discovered verification command in order: tests, lint/static, typecheck, dead-code, format check, build, audit.
6. If no verification commands can be discovered, explicitly report that and ask the user whether to continue without verification.
7. Fix all issues found. If a fix needs product input, stop and ask.
8. Re-run affected checks and repeat until no issues remain.
9. Stage intentionally (`git add <file>`, `git add -p`) and verify staged diff.
10. If the user asked for a commit (or asks to finish with a commit), create a Conventional Commit message and run `git commit`.
11. Verify commit with `git show` and `git log --oneline -5`.

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
- Do not claim a check passed unless it was run and evidenced.
- Prefer repo-defined commands over guessed defaults.
- Keep fixes minimal and aligned to existing conventions.
- Do not rewrite history or run destructive git operations unless explicitly requested.
- If the user asked only for pre-commit validation, stop before committing.

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
