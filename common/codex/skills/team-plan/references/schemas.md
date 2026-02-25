# Schemas

## Invocation

Minimal invocation:

```text
$team-plan plan and implement feature X with requirements Y
```

Optional override block:

```yaml
orchestration_plan:
  max_parallel: 2
  max_fix_attempts: 5
  git:
    base_branch: main
    commit_type_default: fix
    commit_scope_default: stats
```

## Orchestration Overrides (Optional)

```json
{
  "mode": "plan-and-execute",
  "max_parallel": 3,
  "max_fix_attempts": 3,
  "scheduling": "critical_path_then_unblock_count",
  "validation": {
    "per_task_required": true,
    "global_required": true,
    "require_business_rule_coverage": true,
    "global_overrides": []
  },
  "git": {
    "base_branch": "auto",
    "branch_prefix": "auto",
    "max_branch_name_length": 40,
    "remote": "origin",
    "branch_per_task": true,
    "commit_per_task": true,
    "push_per_task": true,
    "commit_type_default": "feat",
    "commit_scope_default": "feature"
  }
}
```

## Task Node

```json
{
  "id": "T3",
  "title": "Implement service layer",
  "objective": "Create service abstraction used by handlers",
  "depends_on": ["T1"],
  "critical_path_length": 3,
  "unblock_count": 4,
  "owner_role": "worker",
  "base_branch": "main",
  "branch_name": "feat/implement-service-layer",
  "commit_type": "feat",
  "commit_scope": "service",
  "commit_message": "feat(service): implement service layer",
  "files_in_scope": ["src/service/**"],
  "validation_cmds": ["npm test -- service", "npm run lint -- src/service"],
  "state": "ready"
}
```

Notes:
- `branch_name` must follow `<type>/<slug>` and be at most 40 characters.

## Final Artifact

```json
{
  "run_summary": {
    "objective": "<user prompt>",
    "mode": "plan-and-execute",
    "status": "completed"
  },
  "planning_report": {
    "scope": "...",
    "constraints": ["..."],
    "assumptions": ["..."],
    "blocking_questions": ["..."],
    "non_blocking_questions": ["..."],
    "decisions_required": [
      {"decision": "Choose rollout strategy", "options": ["big-bang", "phased"], "selected": "phased"}
    ],
    "options_considered": [
      {"name": "Option A", "pros": ["..."], "cons": ["..."]},
      {"name": "Option B", "pros": ["..."], "cons": ["..."]}
    ],
    "selected_design": "Option A",
    "rationale": "...",
    "risks": [{"risk": "...", "mitigation": "..."}]
  },
  "blocking_questions": [],
  "decisions_required": [
    {"decision": "Choose rollout strategy", "options": ["big-bang", "phased"], "selected": "phased"}
  ],
  "project_profile": {
    "languages": ["TypeScript"],
    "tooling": ["eslint", "vitest"],
    "validation_sources": ["docs", "ci", "official_docs"]
  },
  "task_graph": {"tasks": [{"id": "T3", "state": "done", "depends_on": ["T1"], "branch_name": "feat/implement-service-layer"}]},
  "execution_log": [{"task_id": "T3", "status": "passed", "push_status": "ok", "commit_message": "feat(service): implement service layer"}],
  "implementation_report": {
    "what_done": ["..."],
    "how_done": ["..."],
    "why_done_this_way": ["..."],
    "task_details": [
      {
        "task_id": "T3",
        "branch_name": "feat/implement-service-layer",
        "files_changed": ["src/service/index.ts", "src/service/index.test.ts"],
        "key_changes": ["Added service abstraction", "Injected service in handlers"],
        "patterns_used": ["ports-and-adapters", "dependency-injection"]
      }
    ]
  },
  "test_report": {
    "business_rules": [
      {"id": "BR-1", "rule": "...", "tests": ["test_name_1"], "status": "covered"}
    ],
    "gaps": []
  },
  "validation_report": {
    "task_gate": [{"task_id": "T3", "cmd": "npm test -- service", "exit_code": 0}],
    "global_gate": [{"cmd": "npm test", "exit_code": 0}]
  },
  "configuration_steps": ["..."],
  "branch_deliveries": [{"task_id": "T3", "branch_name": "feat/implement-service-layer", "commit_sha": "9f1d2ab", "commit_message": "feat(service): implement service layer", "remote_branch": "origin/feat/implement-service-layer"}],
  "sources": [{"title": "Official docs page", "url": "https://...", "accessed_at": "2026-02-25"}],
  "final_status": "completed",
  "escalations": []
}
```
