#!/usr/bin/env python3
"""Validate team-plan run artifact JSON.

This checker enforces core contracts, including branch-per-task delivery and
commit+push requirements for completed tasks.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Set


REQUIRED_TOP_LEVEL_KEYS = {
    "run_summary",
    "planning_report",
    "blocking_questions",
    "decisions_required",
    "project_profile",
    "task_graph",
    "execution_log",
    "implementation_report",
    "test_report",
    "validation_report",
    "configuration_steps",
    "branch_deliveries",
    "sources",
    "final_status",
    "escalations",
}

REQUIRED_TASK_KEYS = {
    "id",
    "state",
    "depends_on",
    "branch_name",
}

REQUIRED_DELIVERY_KEYS = {
    "task_id",
    "branch_name",
    "commit_sha",
    "commit_message",
    "remote_branch",
}

ALLOWED_COMMIT_TYPES = {
    "feat",
    "fix",
    "refactor",
    "perf",
    "test",
    "docs",
    "chore",
    "build",
    "ci",
    "revert",
    "style",
}

MAX_BRANCH_NAME_LENGTH = 40

REQUIRED_RUN_SUMMARY_KEYS = {"objective", "mode", "status"}
REQUIRED_PLANNING_REPORT_KEYS = {
    "scope",
    "constraints",
    "assumptions",
    "options_considered",
    "selected_design",
    "rationale",
    "risks",
}
REQUIRED_IMPLEMENTATION_REPORT_KEYS = {
    "what_done",
    "how_done",
    "why_done_this_way",
    "task_details",
}
REQUIRED_TASK_DETAIL_KEYS = {
    "task_id",
    "branch_name",
    "files_changed",
    "key_changes",
    "patterns_used",
}
REQUIRED_TEST_REPORT_KEYS = {"business_rules", "gaps"}
REQUIRED_VALIDATION_REPORT_KEYS = {"task_gate", "global_gate"}
REQUIRED_SOURCE_KEYS = {"title", "url", "accessed_at"}

CONVENTIONAL_COMMIT_RE = re.compile(
    r"^(?P<type>feat|fix|refactor|perf|test|docs|chore|build|ci|revert|style)"
    r"\((?P<scope>[a-z0-9][a-z0-9-]*)\): (?P<summary>.+)$"
)
BRANCH_NAME_RE = re.compile(
    r"^(feat|fix|refactor|perf|test|docs|chore|build|ci|revert|style)/[a-z0-9][a-z0-9-]*$"
)


class ValidationError(Exception):
    pass


def load_json(path: Path) -> Dict[str, Any]:
    try:
        raw = path.read_text(encoding="utf-8")
    except OSError as exc:
        raise ValidationError(f"Unable to read file: {exc}") from exc

    try:
        data = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise ValidationError(f"Invalid JSON: {exc}") from exc

    if not isinstance(data, dict):
        raise ValidationError("Top-level JSON value must be an object")

    return data


def extract_tasks(task_graph: Any) -> List[Dict[str, Any]]:
    if isinstance(task_graph, list):
        tasks = task_graph
    elif isinstance(task_graph, dict):
        tasks = task_graph.get("tasks")
    else:
        tasks = None

    if not isinstance(tasks, list):
        raise ValidationError(
            "task_graph must be either a list or an object with a 'tasks' list"
        )

    out: List[Dict[str, Any]] = []
    for idx, item in enumerate(tasks):
        if not isinstance(item, dict):
            raise ValidationError(f"task_graph.tasks[{idx}] must be an object")
        out.append(item)
    return out


def validate_commit_message(message: str, task_id: str) -> str | None:
    match = CONVENTIONAL_COMMIT_RE.match(message)
    if not match:
        return (
            f"Task {task_id}: commit_message '{message}' does not match "
            "required format '<type>(<scope>): <summary>'"
        )

    commit_type = match.group("type")
    if commit_type not in ALLOWED_COMMIT_TYPES:
        return (
            f"Task {task_id}: commit type '{commit_type}' is not allowed "
            f"(allowed: {', '.join(sorted(ALLOWED_COMMIT_TYPES))})"
        )

    scope = match.group("scope")
    if scope.startswith("task-"):
        return (
            f"Task {task_id}: commit scope '{scope}' cannot be task-based; "
            "use a feature/component scope (for example 'feature' or 'auth')"
        )
    return None


def validate_artifact(
    data: Dict[str, Any], allow_escalations: bool
) -> tuple[List[str], Dict[str, int]]:
    errors: List[str] = []

    missing_top = sorted(REQUIRED_TOP_LEVEL_KEYS - set(data.keys()))
    for key in missing_top:
        errors.append(f"Missing top-level key: {key}")

    if missing_top:
        return errors, {"tasks": 0, "done_tasks": 0, "escalations": 0}

    run_summary = data["run_summary"]
    if not isinstance(run_summary, dict):
        errors.append("run_summary must be an object")
        run_summary = {}
    else:
        missing_run_summary = sorted(REQUIRED_RUN_SUMMARY_KEYS - set(run_summary.keys()))
        for key in missing_run_summary:
            errors.append(f"run_summary missing key: {key}")

    planning_report = data["planning_report"]
    if not isinstance(planning_report, dict):
        errors.append("planning_report must be an object")
        planning_report = {}
    else:
        missing_planning = sorted(
            REQUIRED_PLANNING_REPORT_KEYS - set(planning_report.keys())
        )
        for key in missing_planning:
            errors.append(f"planning_report missing key: {key}")
        for key in ("constraints", "assumptions", "options_considered", "risks"):
            value = planning_report.get(key)
            if not isinstance(value, list):
                errors.append(f"planning_report.{key} must be a list")

    blocking_questions = data["blocking_questions"]
    if not isinstance(blocking_questions, list):
        errors.append("blocking_questions must be a list")

    decisions_required = data["decisions_required"]
    if not isinstance(decisions_required, list):
        errors.append("decisions_required must be a list")

    implementation_report = data["implementation_report"]
    if not isinstance(implementation_report, dict):
        errors.append("implementation_report must be an object")
        implementation_report = {}
    else:
        missing_impl = sorted(
            REQUIRED_IMPLEMENTATION_REPORT_KEYS - set(implementation_report.keys())
        )
        for key in missing_impl:
            errors.append(f"implementation_report missing key: {key}")
        for key in ("what_done", "how_done", "why_done_this_way"):
            value = implementation_report.get(key)
            if not isinstance(value, list):
                errors.append(f"implementation_report.{key} must be a list")

    task_details_by_task_id: Dict[str, Dict[str, Any]] = {}
    task_details = implementation_report.get("task_details", [])
    if not isinstance(task_details, list):
        errors.append("implementation_report.task_details must be a list")
        task_details = []
    else:
        for idx, detail in enumerate(task_details):
            if not isinstance(detail, dict):
                errors.append(f"implementation_report.task_details[{idx}] must be an object")
                continue
            missing_detail = sorted(REQUIRED_TASK_DETAIL_KEYS - set(detail.keys()))
            for key in missing_detail:
                errors.append(
                    f"implementation_report.task_details[{idx}] missing key: {key}"
                )

            task_id = detail.get("task_id")
            if isinstance(task_id, str) and task_id.strip():
                if task_id in task_details_by_task_id:
                    errors.append(f"Duplicate implementation task_details entry for task {task_id}")
                else:
                    task_details_by_task_id[task_id] = detail

    test_report = data["test_report"]
    if not isinstance(test_report, dict):
        errors.append("test_report must be an object")
        test_report = {}
    else:
        missing_test = sorted(REQUIRED_TEST_REPORT_KEYS - set(test_report.keys()))
        for key in missing_test:
            errors.append(f"test_report missing key: {key}")
        business_rules = test_report.get("business_rules", [])
        if not isinstance(business_rules, list):
            errors.append("test_report.business_rules must be a list")
            business_rules = []
        for idx, rule in enumerate(business_rules):
            if not isinstance(rule, dict):
                errors.append(f"test_report.business_rules[{idx}] must be an object")
                continue
            for key in ("id", "rule", "tests", "status"):
                if key not in rule:
                    errors.append(f"test_report.business_rules[{idx}] missing key: {key}")
            tests = rule.get("tests")
            if not isinstance(tests, list):
                errors.append(
                    f"test_report.business_rules[{idx}].tests must be a list"
                )
        gaps = test_report.get("gaps", [])
        if not isinstance(gaps, list):
            errors.append("test_report.gaps must be a list")

    validation_report = data["validation_report"]
    if not isinstance(validation_report, dict):
        errors.append("validation_report must be an object")
        validation_report = {}
    else:
        missing_validation = sorted(
            REQUIRED_VALIDATION_REPORT_KEYS - set(validation_report.keys())
        )
        for key in missing_validation:
            errors.append(f"validation_report missing key: {key}")

    configuration_steps = data["configuration_steps"]
    if not isinstance(configuration_steps, list):
        errors.append("configuration_steps must be a list")

    sources = data["sources"]
    if not isinstance(sources, list):
        errors.append("sources must be a list")
        sources = []
    elif not sources:
        errors.append("sources must include at least one entry for implementation guidance")
    else:
        for idx, source in enumerate(sources):
            if not isinstance(source, dict):
                errors.append(f"sources[{idx}] must be an object")
                continue
            missing_source = sorted(REQUIRED_SOURCE_KEYS - set(source.keys()))
            for key in missing_source:
                errors.append(f"sources[{idx}] missing key: {key}")

    task_gate = validation_report.get("task_gate", [])
    if not isinstance(task_gate, list):
        errors.append("validation_report.task_gate must be a list")
    global_gate = validation_report.get("global_gate", [])
    if not isinstance(global_gate, list):
        errors.append("validation_report.global_gate must be a list")

    try:
        tasks = extract_tasks(data["task_graph"])
    except ValidationError as exc:
        errors.append(str(exc))
        return errors, {"tasks": 0, "done_tasks": 0, "escalations": 0}

    execution_log = data["execution_log"]
    if not isinstance(execution_log, list):
        errors.append("execution_log must be a list")
        execution_log = []

    deliveries = data["branch_deliveries"]
    if not isinstance(deliveries, list):
        errors.append("branch_deliveries must be a list")
        deliveries = []

    escalations = data["escalations"]
    if not isinstance(escalations, list):
        errors.append("escalations must be a list")
        escalations = []

    if not allow_escalations and escalations:
        errors.append("Escalations are present; rerun with --allow-escalations to permit")

    task_ids: Set[str] = set()
    done_task_ids: Set[str] = set()
    task_branch_by_id: Dict[str, str] = {}
    branch_to_task: Dict[str, str] = {}

    for task in tasks:
        missing = sorted(REQUIRED_TASK_KEYS - set(task.keys()))
        task_id = task.get("id", "<missing-id>")
        for key in missing:
            errors.append(f"Task {task_id}: missing key '{key}'")

        if not isinstance(task_id, str) or not task_id.strip():
            errors.append(f"Task has invalid id: {task_id!r}")
            continue

        if task_id in task_ids:
            errors.append(f"Duplicate task id: {task_id}")
        task_ids.add(task_id)

        depends_on = task.get("depends_on")
        if not isinstance(depends_on, list):
            errors.append(f"Task {task_id}: depends_on must be a list")
        else:
            for dep in depends_on:
                if not isinstance(dep, str) or not dep.strip():
                    errors.append(f"Task {task_id}: invalid dependency id {dep!r}")

        branch_name = task.get("branch_name")
        if not isinstance(branch_name, str) or not branch_name.strip():
            errors.append(f"Task {task_id}: branch_name must be a non-empty string")
        else:
            branch_name = branch_name.strip()
            if not BRANCH_NAME_RE.match(branch_name):
                errors.append(
                    f"Task {task_id}: branch_name '{branch_name}' must match '<type>/<slug>'"
                )
            if len(branch_name) > MAX_BRANCH_NAME_LENGTH:
                errors.append(
                    f"Task {task_id}: branch_name '{branch_name}' exceeds "
                    f"{MAX_BRANCH_NAME_LENGTH} characters"
                )
            task_branch_by_id[task_id] = branch_name
            existing_owner = branch_to_task.get(branch_name)
            if existing_owner and existing_owner != task_id:
                errors.append(
                    f"Task {task_id}: branch_name '{branch_name}' is reused by task {existing_owner}"
                )
            else:
                branch_to_task[branch_name] = task_id

        if task.get("state") == "done":
            done_task_ids.add(task_id)

    for task in tasks:
        task_id = task.get("id")
        if not isinstance(task_id, str):
            continue
        depends_on = task.get("depends_on")
        if isinstance(depends_on, list):
            for dep in depends_on:
                if isinstance(dep, str) and dep not in task_ids:
                    errors.append(f"Task {task_id}: unknown dependency '{dep}'")

    task_gate_entries_by_task: Dict[str, List[Dict[str, Any]]] = {}
    if isinstance(task_gate, list):
        for idx, gate_entry in enumerate(task_gate):
            if not isinstance(gate_entry, dict):
                errors.append(f"validation_report.task_gate[{idx}] must be an object")
                continue
            gate_task_id = gate_entry.get("task_id")
            cmd = gate_entry.get("cmd")
            exit_code = gate_entry.get("exit_code")
            if not isinstance(gate_task_id, str) or not gate_task_id.strip():
                errors.append(f"validation_report.task_gate[{idx}] missing/invalid task_id")
                continue
            if not isinstance(cmd, str) or not cmd.strip():
                errors.append(
                    f"validation_report.task_gate[{idx}] missing/invalid cmd for task {gate_task_id}"
                )
            if not isinstance(exit_code, int):
                errors.append(
                    f"validation_report.task_gate[{idx}] missing/invalid exit_code for task {gate_task_id}"
                )
            task_gate_entries_by_task.setdefault(gate_task_id, []).append(gate_entry)

    if isinstance(global_gate, list):
        for idx, gate_entry in enumerate(global_gate):
            if not isinstance(gate_entry, dict):
                errors.append(f"validation_report.global_gate[{idx}] must be an object")
                continue
            cmd = gate_entry.get("cmd")
            exit_code = gate_entry.get("exit_code")
            if not isinstance(cmd, str) or not cmd.strip():
                errors.append(f"validation_report.global_gate[{idx}] missing/invalid cmd")
            if not isinstance(exit_code, int):
                errors.append(
                    f"validation_report.global_gate[{idx}] missing/invalid exit_code"
                )
        if not global_gate:
            errors.append("validation_report.global_gate must contain at least one check")

    for task_id in sorted(done_task_ids):
        detail = task_details_by_task_id.get(task_id)
        if not detail:
            errors.append(
                f"Done task {task_id} is missing implementation_report.task_details entry"
            )
        else:
            expected_branch = task_branch_by_id.get(task_id)
            detail_branch = detail.get("branch_name")
            if (
                isinstance(expected_branch, str)
                and isinstance(detail_branch, str)
                and detail_branch != expected_branch
            ):
                errors.append(
                    f"Task {task_id}: task_details branch '{detail_branch}' "
                    f"does not match task branch '{expected_branch}'"
                )

        task_gate_entries = task_gate_entries_by_task.get(task_id, [])
        if not task_gate_entries:
            errors.append(f"Done task {task_id} has no validation_report.task_gate entries")
        else:
            if not any(
                isinstance(entry.get("exit_code"), int) and entry.get("exit_code") == 0
                for entry in task_gate_entries
            ):
                errors.append(
                    f"Done task {task_id} has no passing validation_report.task_gate entry"
                )

    delivery_by_task_id: Dict[str, Dict[str, Any]] = {}
    for idx, delivery in enumerate(deliveries):
        if not isinstance(delivery, dict):
            errors.append(f"branch_deliveries[{idx}] must be an object")
            continue

        missing = sorted(REQUIRED_DELIVERY_KEYS - set(delivery.keys()))
        delivery_id = delivery.get("task_id", f"<missing-task-id@{idx}>")
        for key in missing:
            errors.append(f"Delivery {delivery_id}: missing key '{key}'")

        task_id = delivery.get("task_id")
        if isinstance(task_id, str) and task_id.strip():
            if task_id in delivery_by_task_id:
                errors.append(f"Duplicate branch delivery for task {task_id}")
            else:
                delivery_by_task_id[task_id] = delivery

    for task_id in sorted(done_task_ids):
        delivery = delivery_by_task_id.get(task_id)
        if not delivery:
            errors.append(f"Done task {task_id} is missing branch delivery")
            continue

        expected_branch = task_branch_by_id.get(task_id)
        actual_branch = delivery.get("branch_name")
        if expected_branch and actual_branch != expected_branch:
            errors.append(
                f"Task {task_id}: delivery branch '{actual_branch}' does not match task branch '{expected_branch}'"
            )
        if isinstance(actual_branch, str) and actual_branch.strip():
            if not BRANCH_NAME_RE.match(actual_branch.strip()):
                errors.append(
                    f"Task {task_id}: delivery branch '{actual_branch}' must match '<type>/<slug>'"
                )
            if len(actual_branch.strip()) > MAX_BRANCH_NAME_LENGTH:
                errors.append(
                    f"Task {task_id}: delivery branch '{actual_branch}' exceeds "
                    f"{MAX_BRANCH_NAME_LENGTH} characters"
                )

        commit_message = delivery.get("commit_message")
        if not isinstance(commit_message, str) or not commit_message.strip():
            errors.append(f"Task {task_id}: delivery commit_message must be non-empty")
        else:
            commit_issue = validate_commit_message(commit_message.strip(), task_id)
            if commit_issue:
                errors.append(commit_issue)

    log_entries_by_task: Dict[str, List[Dict[str, Any]]] = {}
    for idx, entry in enumerate(execution_log):
        if not isinstance(entry, dict):
            errors.append(f"execution_log[{idx}] must be an object")
            continue
        task_id = entry.get("task_id")
        if isinstance(task_id, str) and task_id.strip():
            log_entries_by_task.setdefault(task_id, []).append(entry)

    for task_id in sorted(done_task_ids):
        entries = log_entries_by_task.get(task_id, [])
        if not entries:
            errors.append(f"Done task {task_id} has no execution_log entries")
            continue

        has_success_with_push = any(
            isinstance(e.get("status"), str)
            and e.get("status") in {"passed", "done"}
            and e.get("push_status") == "ok"
            for e in entries
        )
        if not has_success_with_push:
            errors.append(
                f"Done task {task_id} lacks a successful execution_log entry with push_status='ok'"
            )

        commit_messages = [
            e.get("commit_message")
            for e in entries
            if isinstance(e.get("commit_message"), str) and e.get("commit_message").strip()
        ]
        if commit_messages:
            for commit_message in commit_messages:
                commit_issue = validate_commit_message(commit_message.strip(), task_id)
                if commit_issue:
                    errors.append(commit_issue)

    stats = {
        "tasks": len(tasks),
        "done_tasks": len(done_task_ids),
        "escalations": len(escalations),
    }
    return errors, stats


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate team-plan run artifact JSON"
    )
    parser.add_argument("artifact", type=Path, help="Path to run artifact JSON")
    parser.add_argument(
        "--allow-escalations",
        action="store_true",
        help="Allow non-empty escalations",
    )
    args = parser.parse_args()

    try:
        data = load_json(args.artifact)
    except ValidationError as exc:
        print(f"ERROR: {exc}")
        return 1

    errors, stats = validate_artifact(data, args.allow_escalations)
    if errors:
        print("VALIDATION FAILED")
        for issue in errors:
            print(f"- {issue}")
        return 1

    print(
        "VALIDATION PASSED "
        f"(tasks={stats['tasks']}, done={stats['done_tasks']}, escalations={stats['escalations']})"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
