---
name: team-plan
description: Plan and implement production-ready repo work from a plain-language objective using multi-agent delegation, blocker-aware scheduling, business-rule test coverage, and branch-per-task delivery. Use for prompts like "$team-plan plan and implement feature X with requirements Y".
---

# Team Plan

Plan and deliver complex implementation with production discipline.

Core model:
- Main agent: architect + PM
- Subagents: explorer/worker/reviewer
- Delivery: one branch per task, commit + push required

## Quick Use

Use plain language. Structured overrides are optional.

Examples:
- `$team-plan plan and implement feature X with requirements Y`
- `$team-plan plan and implement OAuth login with refresh tokens and role checks`
- `$team-plan plan this migration and implement with full validation`

## Inputs

Required:
- user objective in natural language

Optional:
- `orchestration_plan` overrides

If overrides are omitted, use defaults.

## Defaults

- `mode: plan-and-execute`
- `max_parallel: 3`
- `scheduling: critical_path_then_unblock_count`
- `max_fix_attempts: 3`
- `validation.per_task_required: true`
- `validation.global_required: true`
- `validation.require_business_rule_coverage: true`
- `continue_on_escalation: true`
- `git.base_branch: auto`
- `git.branch_prefix: auto`
- `git.max_branch_name_length: 40`
- `git.remote: origin`
- `git.branch_per_task: true`
- `git.commit_per_task: true`
- `git.push_per_task: true`
- `git.commit_type_default: feat`
- `git.commit_scope_default: feature`

## Production Planning Standard

For non-trivial work, produce a detailed but concise plan before coding.

Required planning depth:
1. Scope, constraints, and explicit assumptions
2. Existing project patterns and architecture fit
3. At least two design options when multiple approaches are viable
4. Recommended design with rationale and tradeoffs
5. Data model/API/interface changes
6. Risk register with mitigations
7. Rollout and rollback approach

Use the same rigor as `$planning` (or invoke that workflow when available).

Clarification gate (mandatory):
- If required information is missing, ask concise clarifying questions before coding.
- If a user decision is needed (for example architecture choice, migration strategy, compatibility tradeoff), ask for that decision explicitly.
- Distinguish:
  - `blocking_questions`: must be answered before implementation
  - `non_blocking_questions`: can proceed with stated assumptions
- Do not guess on high-impact decisions silently.

## Docs And Research Standard

Always use up-to-date docs for implementation details.

Rules:
- Identify core libraries/frameworks touched by each task.
- Retrieve current API guidance using Context7 when available.
- Use web research for primary sources when needed (official docs/changelogs/release notes).
- Prefer official sources and cite them in output.
- If APIs are ambiguous, state uncertainty and chosen assumption.

Never rely solely on stale memory for changing APIs.

## Multi-Agent Execution Standard

This skill is multi-agent by default for plan-and-execute runs.

Required behavior:
- Use explorer subagent(s) for repo discovery and docs gathering.
- Use worker subagents for ready implementation tasks.
- Use reviewer subagent before final completion.
- Run workers in parallel up to `max_parallel` when dependencies allow.

Scheduling:
- Never run a blocked task.
- Prioritize by `critical_path_length`, then `unblock_count`.

If multi-agent capability is unavailable for non-trivial work:
- Return an explicit blocking escalation with configuration steps.
- Do not silently downgrade to single-agent execution.

## Git Delivery Policy

Every task must be delivered on a dedicated branch.

Branch rules:
- Branch name convention: `<type>/<slug>`.
- Max branch name length: `40` characters.
- Example branch names:
  - `feat/fingerprint-tracking`
  - `fix/forbidden-error-on-stats`
- Do not use git worktrees.
- Derive `type` from task commit type.
- Derive `slug` from commit summary (fallback to title).
- Branch from configured base branch.
- Do not mix unrelated tasks on one branch.

Commit rules:
- Format: `<type>(<scope>): <summary>`
- Scope must describe feature/component (for example `feature`, `auth`, `billing-alerts`), never a task ID.
- Allowed types:
  - `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`, `build`, `ci`, `revert`, `style`

Task completion requirements:
1. Task validation passes
2. Valid commit exists
3. Push succeeds
4. Delivery metadata recorded

Helper scripts location:
- `"${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/task_git_flow.py"`
- Never require helper scripts inside the project repository.

Preferred deterministic commands:
1. `python3 "${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/task_git_flow.py" derive --task-id <ID> --title "<TITLE>" --commit-scope "<SCOPE>" --max-branch-length 40`
2. `python3 "${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/task_git_flow.py" prepare-branch --task-id <ID> --title "<TITLE>" --base-branch auto --max-branch-length 40`
3. `python3 "${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/task_git_flow.py" finalize --task-id <ID> --title "<TITLE>" --commit-summary "<SUMMARY>" --commit-type <TYPE> --commit-scope "<SCOPE>" --max-branch-length 40 --remote origin`

`prepare-branch` dirty-worktree behavior:
- Default allows dirty state only when creating a new task branch from the current base branch (keeps in-progress changes on that new task branch).
- Fails for unsafe switches (for example dirty tree while switching to an existing task branch).
- Use `--require-clean` to enforce strict clean-tree policy.

Required fallback when helper scripts are unavailable:
1. Derive deterministic branch and commit message with the same rules:
   - `branch_name = "<type>/<slugified_summary_or_title>"` truncated to 40 chars total
   - `commit_message = "<type>(<scope>): <summary>"`
2. Run direct git flow (`checkout`, `add`, `commit`, `push`) and continue.

Script path issues alone are never a valid reason to skip commit+push.

## Testing Standard

All business rules must be covered by tests.

Required behavior:
- Extract explicit business rules from prompt, docs, and existing behavior.
- Maintain a business-rule matrix with rule ID, expected behavior, and test coverage.
- Add/adjust tests for each business rule (unit/integration/e2e as appropriate).
- Mark uncovered rules as blockers unless explicitly escalated with reason.

Validation gates:
- Task gate: scoped checks for changed area.
- Global gate: full repo checks before completion.

Prefer project-defined commands. If missing, infer formatter/lint/typecheck/full tests/build.

## Output Contract

Return concise structured output with implementation detail.

Required sections:
- `run_summary`: objective, mode, status
- `planning_report`: scope, constraints, assumptions, options considered, selected design, rationale, risk register
- `blocking_questions`: unanswered questions that stop implementation
- `decisions_required`: explicit user decisions requested and chosen option
- `implementation_report`: what was done, how it was done, why this approach, and per-task details
  - Per-task details must include: `task_id`, `branch_name`, `files_changed`, `key_changes`, `patterns_used`
- `test_report`: business-rule matrix, test names, and uncovered gaps
- `validation_report`: task and global gate results with command + exit code evidence
- `configuration_steps`: env/config/migration/rollout steps required
- `task_graph`, `execution_log`, `branch_deliveries`, `final_status`, `escalations`
- `sources`: links used for current implementation guidance

References:
- `references/schemas.md`
- `references/prompt-templates.md`
- `references/usage.md`

Local artifact validation:
- `python3 "${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/validate_run.py" <run-artifact.json>`

## Common Failure Modes

- Missing project validation commands: infer and mark assumptions.
- Cross-task file conflicts: serialize conflicting tasks.
- Push rejected/no remote: retry if fixable, else escalate.
- Commit format mismatch: regenerate deterministic commit message and recommit.
- Missing business-rule tests: create targeted tests before completion.
