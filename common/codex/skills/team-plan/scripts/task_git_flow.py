#!/usr/bin/env python3
"""Deterministic git helpers for team-plan.

Subcommands:
- derive: compute branch name and Conventional Commit message for a task
- prepare-branch: switch/create task branch from base branch
- finalize: commit and push task branch
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import List

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

DEFAULT_MAX_BRANCH_LENGTH = 40

DEFAULT_SCOPE_BY_TYPE = {
    "feat": "feature",
    "fix": "bugfix",
    "refactor": "refactor",
    "perf": "performance",
    "test": "tests",
    "docs": "docs",
    "chore": "chore",
    "build": "build",
    "ci": "ci",
    "revert": "revert",
    "style": "style",
}


class GitFlowError(Exception):
    pass


def run_git(workspace: Path, args: List[str], capture_stdout: bool = True) -> str:
    cmd = ["git", *args]
    result = subprocess.run(
        cmd,
        cwd=str(workspace),
        text=True,
        capture_output=capture_stdout,
        check=False,
    )
    if result.returncode != 0:
        stderr = (result.stderr or "").strip()
        stdout = (result.stdout or "").strip()
        detail = stderr if stderr else stdout
        raise GitFlowError(f"git {' '.join(args)} failed: {detail}")
    if capture_stdout:
        return (result.stdout or "").strip()
    return ""


def normalize_task_id(task_id: str) -> str:
    lowered = task_id.strip().lower()
    normalized = re.sub(r"[^a-z0-9]+", "-", lowered).strip("-")
    if not normalized:
        raise GitFlowError(f"Invalid task id: {task_id!r}")
    return normalized


def slugify_title(title: str) -> str:
    lowered = title.strip().lower()
    slug = re.sub(r"[^a-z0-9]+", "-", lowered).strip("-")
    if not slug:
        return "task"
    return slug


def normalize_commit_type(commit_type: str) -> str:
    normalized_type = commit_type.strip().lower()
    if normalized_type not in ALLOWED_COMMIT_TYPES:
        raise GitFlowError(
            f"Invalid commit type '{commit_type}'. Allowed: {', '.join(sorted(ALLOWED_COMMIT_TYPES))}"
        )
    return normalized_type


def normalize_commit_scope(commit_scope: str | None, commit_type: str) -> str:
    normalized_type = normalize_commit_type(commit_type)
    source = commit_scope.strip() if commit_scope else ""
    if not source or source.lower() == "auto":
        source = DEFAULT_SCOPE_BY_TYPE.get(normalized_type, "change")

    scope = slugify_title(source)
    if not scope:
        raise GitFlowError("commit scope must be non-empty")
    if scope.startswith("task-"):
        raise GitFlowError(
            "commit scope must describe a feature/component (for example 'feature' or 'auth'), "
            "not a task id"
        )
    return scope


def build_branch_name(
    title: str,
    commit_type: str,
    branch_prefix: str,
    commit_summary: str | None = None,
    max_branch_length: int = DEFAULT_MAX_BRANCH_LENGTH,
) -> str:
    if max_branch_length < 16:
        raise GitFlowError("max_branch_length must be at least 16")

    prefix = branch_prefix.strip().strip("/")
    if prefix.lower() == "auto":
        prefix = normalize_commit_type(commit_type)
    if not prefix:
        raise GitFlowError("branch_prefix must be non-empty")

    fixed_prefix = f"{prefix}/"
    remaining = max_branch_length - len(fixed_prefix)
    if remaining < 6:
        raise GitFlowError(
            f"branch_prefix '{prefix}' is too long for max_branch_length={max_branch_length}"
        )

    source = commit_summary.strip() if commit_summary else title
    slug = slugify_title(source)[:remaining]
    if not slug:
        slug = "task"
    return f"{fixed_prefix}{slug}"


def build_commit_message(summary: str, commit_type: str, commit_scope: str | None) -> str:
    normalized_type = normalize_commit_type(commit_type)
    normalized_scope = normalize_commit_scope(commit_scope, normalized_type)
    cleaned_summary = summary.strip()
    if not cleaned_summary:
        raise GitFlowError("commit summary must be non-empty")
    return f"{normalized_type}({normalized_scope}): {cleaned_summary}"


def worktree_is_dirty(workspace: Path) -> bool:
    status = run_git(workspace, ["status", "--porcelain"])
    return bool(status.strip())


def detect_base_branch(workspace: Path) -> str:
    try:
        head_ref = run_git(workspace, ["symbolic-ref", "--short", "refs/remotes/origin/HEAD"])
        if head_ref.startswith("origin/") and len(head_ref.split("/")) >= 2:
            return head_ref.split("/", 1)[1]
    except GitFlowError:
        pass

    for candidate in ["main", "master"]:
        try:
            run_git(workspace, ["rev-parse", "--verify", candidate])
            return candidate
        except GitFlowError:
            continue

    return run_git(workspace, ["rev-parse", "--abbrev-ref", "HEAD"])


def local_branch_exists(workspace: Path, branch_name: str) -> bool:
    result = subprocess.run(
        ["git", "show-ref", "--verify", f"refs/heads/{branch_name}"],
        cwd=str(workspace),
        text=True,
        capture_output=True,
        check=False,
    )
    return result.returncode == 0


def cmd_derive(args: argparse.Namespace) -> int:
    commit_summary = args.commit_summary if args.commit_summary else args.title
    branch_name = build_branch_name(
        args.title,
        args.commit_type,
        args.branch_prefix,
        commit_summary,
        args.max_branch_length,
    )
    commit_scope = normalize_commit_scope(args.commit_scope, args.commit_type)
    commit_message = build_commit_message(commit_summary, args.commit_type, commit_scope)

    print(
        json.dumps(
            {
                "task_id": args.task_id,
                "normalized_task_id": normalize_task_id(args.task_id),
                "branch_name": branch_name,
                "commit_type": args.commit_type,
                "commit_scope": commit_scope,
                "max_branch_length": args.max_branch_length,
                "commit_message": commit_message,
            },
            indent=2,
        )
    )
    return 0


def cmd_prepare_branch(args: argparse.Namespace) -> int:
    workspace = Path(args.workspace).resolve()
    commit_summary = args.commit_summary if args.commit_summary else args.title
    branch_name = build_branch_name(
        args.title,
        args.commit_type,
        args.branch_prefix,
        commit_summary,
        args.max_branch_length,
    )
    base_branch = args.base_branch
    if base_branch == "auto":
        base_branch = detect_base_branch(workspace)

    run_git(workspace, ["rev-parse", "--verify", base_branch])
    current_branch = run_git(workspace, ["rev-parse", "--abbrev-ref", "HEAD"])
    dirty = worktree_is_dirty(workspace)

    commands = []
    branch_exists = local_branch_exists(workspace, branch_name)

    if dirty and not args.allow_dirty:
        raise GitFlowError(
            "Working tree is not clean. Commit/stash existing changes before switching task branches."
        )

    if dirty and args.allow_dirty:
        if branch_exists and current_branch != branch_name:
            raise GitFlowError(
                f"Working tree is dirty on branch '{current_branch}'. "
                f"Cannot safely switch to existing branch '{branch_name}'. "
                "Commit/stash first, or switch to that branch and rerun."
            )
        if not branch_exists and current_branch != base_branch:
            raise GitFlowError(
                f"Working tree is dirty on branch '{current_branch}', and new branch "
                f"'{branch_name}' must be created from base '{base_branch}'. "
                "Commit/stash first, or start from the base branch."
            )

    if branch_exists:
        commands.append(["checkout", branch_name])
        run_git(workspace, ["checkout", branch_name], capture_stdout=False)
    else:
        if current_branch != base_branch:
            commands.append(["checkout", base_branch])
            run_git(workspace, ["checkout", base_branch], capture_stdout=False)
        commands.append(["checkout", "-b", branch_name, base_branch])
        run_git(workspace, ["checkout", "-b", branch_name, base_branch], capture_stdout=False)

    final_branch = run_git(workspace, ["rev-parse", "--abbrev-ref", "HEAD"])
    print(
        json.dumps(
            {
                "task_id": args.task_id,
                "base_branch": base_branch,
                "branch_name": branch_name,
                "current_branch": final_branch,
                "dirty_worktree": dirty,
                "allow_dirty": args.allow_dirty,
                "max_branch_length": args.max_branch_length,
                "commands": ["git " + " ".join(c) for c in commands],
            },
            indent=2,
        )
    )
    return 0


def cmd_finalize(args: argparse.Namespace) -> int:
    workspace = Path(args.workspace).resolve()
    commit_summary = args.commit_summary if args.commit_summary else args.title

    branch_name = (
        args.branch_name
        if args.branch_name
        else build_branch_name(
            args.title,
            args.commit_type,
            args.branch_prefix,
            commit_summary,
            args.max_branch_length,
        )
    )
    if len(branch_name) > args.max_branch_length:
        raise GitFlowError(
            f"branch_name '{branch_name}' exceeds max_branch_length={args.max_branch_length}"
        )
    current_branch = run_git(workspace, ["rev-parse", "--abbrev-ref", "HEAD"])
    if current_branch != branch_name:
        raise GitFlowError(
            f"Current branch is '{current_branch}', expected '{branch_name}'. "
            "Run prepare-branch first or switch branches explicitly."
        )

    commit_scope = normalize_commit_scope(args.commit_scope, args.commit_type)
    commit_message = build_commit_message(commit_summary, args.commit_type, commit_scope)

    run_git(workspace, ["add", "-A"], capture_stdout=False)

    diff_quiet = subprocess.run(
        ["git", "diff", "--cached", "--quiet"],
        cwd=str(workspace),
        text=True,
        capture_output=True,
        check=False,
    )

    if diff_quiet.returncode == 0 and not args.allow_empty:
        raise GitFlowError(
            "No staged changes for commit. Use --allow-empty if this is intentional."
        )

    commit_args = ["commit", "-m", commit_message]
    if args.allow_empty:
        commit_args.insert(1, "--allow-empty")
    run_git(workspace, commit_args, capture_stdout=False)

    commit_sha = run_git(workspace, ["rev-parse", "--short", "HEAD"])
    run_git(workspace, ["push", "-u", args.remote, branch_name], capture_stdout=False)

    print(
        json.dumps(
            {
                "task_id": args.task_id,
                "branch_name": branch_name,
                "commit_sha": commit_sha,
                "commit_scope": commit_scope,
                "commit_message": commit_message,
                "remote_branch": f"{args.remote}/{branch_name}",
                "push_status": "ok",
                "max_branch_length": args.max_branch_length,
            },
            indent=2,
        )
    )
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Deterministic task git flow helper")
    subparsers = parser.add_subparsers(dest="command", required=True)

    derive = subparsers.add_parser("derive", help="Derive branch and commit metadata")
    derive.add_argument("--task-id", required=True)
    derive.add_argument("--title", required=True)
    derive.add_argument("--commit-summary")
    derive.add_argument("--branch-prefix", default="auto")
    derive.add_argument("--max-branch-length", type=int, default=DEFAULT_MAX_BRANCH_LENGTH)
    derive.add_argument("--commit-type", default="feat")
    derive.add_argument("--commit-scope", default="feature")
    derive.set_defaults(func=cmd_derive)

    prepare = subparsers.add_parser(
        "prepare-branch", help="Create/switch deterministic task branch"
    )
    prepare.add_argument("--task-id", required=True)
    prepare.add_argument("--title", required=True)
    prepare.add_argument("--commit-summary")
    prepare.add_argument("--branch-prefix", default="auto")
    prepare.add_argument("--max-branch-length", type=int, default=DEFAULT_MAX_BRANCH_LENGTH)
    prepare.add_argument("--commit-type", default="feat")
    prepare.add_argument("--base-branch", default="auto")
    prepare.add_argument(
        "--allow-dirty",
        action="store_true",
        help="Allow dirty working tree only when creating branch from current base branch",
    )
    prepare.add_argument(
        "--require-clean",
        dest="allow_dirty",
        action="store_false",
        help="Require clean working tree before branch switching/creation",
    )
    prepare.add_argument("--workspace", default=".")
    prepare.set_defaults(func=cmd_prepare_branch, allow_dirty=True)

    finalize = subparsers.add_parser(
        "finalize", help="Commit and push current task branch"
    )
    finalize.add_argument("--task-id", required=True)
    finalize.add_argument("--title", required=True)
    finalize.add_argument("--commit-summary")
    finalize.add_argument("--branch-prefix", default="auto")
    finalize.add_argument("--max-branch-length", type=int, default=DEFAULT_MAX_BRANCH_LENGTH)
    finalize.add_argument("--branch-name")
    finalize.add_argument("--commit-type", default="feat")
    finalize.add_argument("--commit-scope", default="feature")
    finalize.add_argument("--remote", default="origin")
    finalize.add_argument("--workspace", default=".")
    finalize.add_argument("--allow-empty", action="store_true")
    finalize.set_defaults(func=cmd_finalize)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    try:
        return args.func(args)
    except GitFlowError as exc:
        print(f"ERROR: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
