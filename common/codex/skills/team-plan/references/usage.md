# Usage Guide

## Fastest Way

Use one line. No orchestration block is required.

```text
$team-plan plan and implement feature X with requirements Y
```

## Recommended Prompt Style

Be explicit about business rules and non-functional requirements.

```text
$team-plan plan and implement audit logging for billing changes.
Requirements:
- log actor, timestamp, before/after values
- redact sensitive fields
- enforce append-only behavior
- add tests for all business rules
```

## Optional Overrides

Use `orchestration_plan` only for deviations from defaults.

```text
$team-plan plan and implement feature X with requirements Y
orchestration_plan:
  max_parallel: 2
  max_fix_attempts: 5
  git:
    base_branch: main
    commit_type_default: fix
    commit_scope_default: billing
    max_branch_name_length: 40
```

## Multi-Agent Expectation

For non-trivial work, runs should use multi-agent behavior:
- explorer subagent for repo discovery/docs
- worker subagents for ready tasks
- reviewer subagent before completion
- execute the whole task graph in one run without asking to continue after each task unless blocked

If multi-agent is unavailable, the run should return a blocking escalation with setup guidance.

## Clarification Behavior

Planning phase should ask questions when needed.

Rules:
- Ask questions when required information is missing.
- Ask for a user decision when tradeoffs are material.
- Keep questions concise and actionable.

Example:

```text
$team-plan plan and implement billing alerts with escalation policies.
If any policy thresholds are unclear, ask me before implementation.
```

## Deterministic Git Delivery

Every completed task must have:
- dedicated branch
- valid Conventional Commit with feature/component scope
- successful push

Branch convention:
- `<type>/<slug>`
- max 40 characters total
- Examples:
  - `feat/fingerprint-tracking`
  - `fix/forbidden-error-on-stats`

Commit format:

```text
<type>(<scope>): <summary>
```

Scope rules:
- scope describes feature/component (for example `feature`, `auth`, `stats-api`)
- scope cannot be task-based (for example `task-1`)
- do not use git worktrees; use one branch per task in the main repo workspace

Helper script path:
- `"${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/task_git_flow.py"`

Commands:

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/task_git_flow.py" derive --task-id T3 --title "Implement service layer" --commit-scope service --max-branch-length 40
python3 "${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/task_git_flow.py" prepare-branch --task-id T3 --title "Implement service layer" --base-branch auto --max-branch-length 40
python3 "${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/task_git_flow.py" finalize --task-id T3 --title "Implement service layer" --commit-summary "implement service layer" --commit-type feat --commit-scope service --max-branch-length 40 --remote origin
# Bug-fix branch style example:
python3 "${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/task_git_flow.py" derive --task-id T8 --title "Forbidden error on stats" --commit-summary "forbidden error on stats" --commit-type fix --commit-scope stats --max-branch-length 40
```

Dirty worktree behavior for `prepare-branch`:
- default allows dirty state only when creating a new task branch from current base branch
- unsafe branch switches with dirty state are blocked
- add `--require-clean` to require a fully clean tree

If script execution is unavailable, run equivalent deterministic git commands directly.

## Production Output Requirements

Expected output should include:
- detailed plan and architecture decision rationale
- what was implemented (with per-task detail)
- how it was implemented
- why this approach was chosen
- business-rule test coverage and evidence
- task/global validation outcomes
- required configuration/migration steps
- source links for current implementation guidance

Per-task implementation detail should include:
- `task_id`
- `branch_name`
- `files_changed`
- `key_changes`
- `patterns_used`

## Validate Run Artifact

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/validate_run.py" run-artifact.json
```

Allow escalations when expected:

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/team-plan/scripts/validate_run.py" run-artifact.json --allow-escalations
```

## Troubleshooting

- Commit format rejected:
  - regenerate message and recommit.
- Push rejected:
  - verify remote auth and branch protection.
- Dirty tree blocked on branch switch:
  - commit/stash and rerun, or run from base branch when creating a new task branch.
- Missing validation commands:
  - ensure docs/CI are accessible from repo root.
- Missing business-rule tests:
  - treat as incomplete and add tests before completion.
