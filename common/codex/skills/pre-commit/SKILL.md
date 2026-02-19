---
name: pre-commit
description: Perform pre-commit validation without creating a commit by running local code review plus project-native checks to detect inconsistencies, anti-patterns, bad design patterns, insecure code, and insecure dependencies. Fix all critical findings, report non-critical findings by default, and output a structured findings and fixes summary. Use when the user asks to "run pre-commit checks", "validate changes before commit", "clean up before commit", "review code before commit", "find security issues before commit", or any request that combines verification + remediation without committing.
---

# Pre-commit

## Overview

Execute a full pre-commit workflow: review changes, run project checks, detect correctness/security/design issues, fix all critical findings, re-run checks until stable, and deliver a structured validation summary. Do not create a commit in this skill.

Use supporting resources from this skill:
- `references/severity-rubric.md` for severity classification and fix gates.
- `references/anti-pattern-catalog.md` for review categories and fix patterns.
- `scripts/precommit_review_checklist.sh` to generate a deterministic review checklist and report skeleton.

## Severity Policy

Classify each finding with one severity and one category.

- Critical:
  - exploitable or realistically abusable security issues (including high and medium security risk),
  - auth/authz flaws,
  - command/code injection paths,
  - unsafe deserialization, SSRF, RCE, or secret leakage,
  - data corruption/loss risks,
  - high-confidence insecure dependency findings from project-native audit commands.
- Non-critical:
  - maintainability smells,
  - low-risk anti-patterns,
  - style-only concerns,
  - speculative risks without strong evidence.

Mandatory action:
- Fix all critical findings in the same run.
- Report non-critical findings by default; do not auto-fix non-critical findings unless the user asks.
- If a critical finding cannot be safely fixed without product decisions, stop and escalate clearly.

## Workflow

1. Inspect current repository state.
- Run `git status --short`.
- Review changed files and staged vs unstaged state.
- Identify likely stack and tooling from files like `Makefile`, `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, and CI configs.
- Run `bash "${CODEX_HOME:-$HOME/.codex}/skills/pre-commit/scripts/precommit_review_checklist.sh"` to scaffold the review and output sections.

2. Perform a code review before automation.
- Read modified files and evaluate them against `references/anti-pattern-catalog.md`.
- Detect:
  - inconsistencies with existing project conventions/patterns,
  - anti-patterns and bad design patterns,
  - insecure code paths and weak validation,
  - risky package/dependency changes.
- Use `references/severity-rubric.md` to classify each finding.
- Prioritize correctness and behavior over style.
- Keep comments only on business logic that is hard to read or complex.
- For each meaningful code change, verify documentation is updated where needed (for example `README*`, `docs/**`, runbooks, ADRs, API docs, config guides, migration notes).
- If documentation is missing or stale for a behavior/config/API change, report it as a finding and propose the exact docs that should be updated.

3. Build the check plan from project-native commands.
- Prefer repository-defined commands first (`make`, npm/pnpm scripts, task runners, documented commands).
- Fallback to language defaults only when project commands are unavailable.
- For dependency security: use project-native audit commands only. If none exist, report the gap explicitly.

4. Run checks in this order.
- Tests.
- Linters/static analysis.
- Formatters.
- Build/compile checks if available.
- Project-native dependency audit checks, if configured.

5. Fix issues and iterate.
- Fix all critical findings from review and checks.
- Apply high-confidence, minimal-risk fixes only.
- Do not introduce new dependencies unless required for a critical fix and aligned with project conventions.
- Report non-critical findings without auto-fixing unless user asks.
- If there were changes since step 4, re-run affected checks immediately.
- If there were changes since step 4, re-run the full check chain before committing.
- If any critical issue remains unresolved, mark the run as blocked and explain why.

6. Prepare final validation summary.
- Summarize what was reviewed, what failed, what was fixed, and what remains.
- Include final status of test/lint/format/build/audit checks.
- Enumerate all meaningful file-level changes and behavior impacts.
- Include a documentation coverage section: map important code changes to corresponding docs updates, or explicitly state why no docs update is required.
- Include notes on issues, risks, assumptions, and code considerations (maintainability, edge cases, config hardcoding, security/privacy concerns, and test coverage gaps).
- If useful, include a suggested Conventional Commit message, but do not run `git commit`.

## Command Selection Heuristics

- Prefer explicit project instructions over guessed defaults.
- If multiple toolchains exist, follow the one used by CI/workflow files.
- If no test or lint command exists, report that clearly instead of inventing fake success.
- If no project-native dependency audit command exists, report "dependency audit not configured" instead of claiming dependency safety.
- Never claim checks passed unless they were actually run successfully.

## Safety Rules

- Do not use destructive git operations unless explicitly requested.
- Do not rewrite history unless explicitly requested.
- Do not hide uncertainty: when exploitability or behavior is unclear, document confidence and rationale.
- Stop and ask the user if blockers require product decisions (for example, conflicting intended behavior).

## Output Contract

Always provide:
- Findings from manual review (ordered by severity) with:
  - severity,
  - category,
  - file/path,
  - risk summary,
  - status (`fixed` or `unresolved`).
- Critical fixes applied (what changed and why it resolves the risk).
- Checks executed and their final status.
- Files changed by the fix pass.
- Detailed summary of all meaningful code changes and expected behavior impact.
- Documentation coverage result for changed code (updated docs, required docs follow-ups, or explicit "not required" rationale).
- Notes about issues or considerations (risk, follow-up work, potential regressions, test gaps).
- Residual risks and required follow-up actions for unresolved findings.
- Any remaining risks or follow-up work.
