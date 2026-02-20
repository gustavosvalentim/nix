---
name: pre-commit
description: Review changed code and run project-native pre-commit checks to detect and fix issues before commit, including tests, lint/static analysis, formatting, dead-code detection, build, and dependency audit (when configured). Never creates a commit. Use when the user asks to run pre-commit checks, validate changes before commit, clean up before commit, or review code before committing.
---

# Pre-commit

## Purpose

Run a concise, high-signal pre-commit workflow. Review changes for quality, architecture, testing, requirements, production readiness, and YAGNI. Then run project-native checks, fix all issues found, and repeat until no issues remain or user input is required.

## Required Review Topics

- Code Quality: separation of concerns; error handling; type safety; DRY; edge cases.
- Architecture: sound design; scalability; performance; security.
- Testing: tests hit real logic (not only mocks); edge cases; integration tests where needed; all tests passing.
- Requirements: plan requirements met; implementation matches spec; no scope creep; breaking changes documented.
- Production Readiness: migration strategy for schema changes; backward compatibility; docs complete; no obvious bugs.
- YAGNI: avoid speculative, unused, or premature functionality.
- Comments: only use comments on business rules that are hard to read or too complex.

## Workflow

1. Inspect repo state and changed files (`git status --short`).
2. Summarize change risk: blast radius, failure modes, rollback path, risk level.
3. Perform manual review against Required Review Topics and project conventions.
4. Build a check plan from repo-native commands (tests, lint/static analysis, build/compile, dead-code detection, dependency audit if configured).
5. Run checks in order: tests, lint/static, dead-code, format, build, audit.
6. Fix all issues found (manual review or checks). If a fix needs product input, stop and ask.
7. Re-run affected checks; repeat review + checks until no issues remain.
8. Produce final report.

## Rules

- Do not commit, rewrite history, or run destructive git operations.
- Prefer repo-defined commands over guessed defaults.
- If a required command is missing (tests, dead-code, audit), report it as an issue and ask for guidance.
- Never claim a check passed without running it and reporting evidence.
- Keep fixes minimal and aligned with existing conventions; avoid new dependencies unless required.

## Output Format

### Strengths
[What's well done? Be specific.]

### Issues

#### Critical (Must Fix)
[Bugs, security issues, data loss risks, broken functionality]

#### Important (Should Fix)
[Architecture problems, missing features, poor error handling, test gaps]

#### Minor (Nice to Have)
[Code style, optimization opportunities, documentation improvements]

**For each issue:**
- File:line reference
- What's wrong
- Why it matters
- How to fix (if not obvious)

### Recommendations
[Improvements for code quality, architecture, or process]

### Assessment

**Ready to merge?** [Yes/No/With fixes]

**Reasoning:** [Technical assessment in 1-2 sentences]

## Critical Rules

**DO:**
- Categorize by actual severity (not everything is Critical)
- Be specific (file:line, not vague)
- Explain WHY issues matter
- Acknowledge strengths
- Give clear verdict

**DON'T:**
- Say "looks good" without checking
- Mark nitpicks as Critical
- Give feedback on code you didn't review
- Be vague ("improve error handling")
- Avoid giving a clear verdict

## Example Output

```
### Strengths
- Clean database schema with proper migrations (db.ts:15-42)
- Comprehensive test coverage (18 tests, all edge cases)
- Good error handling with fallbacks (summarizer.ts:85-92)

### Issues

#### Important
1. **Missing help text in CLI wrapper**
   - File: index-conversations:1-31
   - Issue: No --help flag, users won't discover --concurrency
   - Fix: Add --help case with usage examples

2. **Date validation missing**
   - File: search.ts:25-27
   - Issue: Invalid dates silently return no results
   - Fix: Validate ISO format, throw error with example

#### Minor
1. **Progress indicators**
   - File: indexer.ts:130
   - Issue: No "X of Y" counter for long operations
   - Impact: Users don't know how long to wait

### Recommendations
- Add progress reporting for user experience
- Consider config file for excluded projects (portability)

### Assessment

**Ready to merge: With fixes**

**Reasoning:** Core implementation is solid with good architecture and tests. Important issues (help text, date validation) are easily fixed and don't affect core functionality.
```

