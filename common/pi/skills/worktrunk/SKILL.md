---
name: worktrunk
description: Instructions for how to use worktrunk, a tool for managing worktrees. Use when the user explicitly ask for you to create, remove or list worktrees.
disable-model-invocation: false
---

# Worktrunk

Before using `worktrunk`, learn how to use it by running `wt --help`.

## Create a worktree

```sh
wt switch <branch-name> # Branch already exists
wt switch -c <branch-name> # Create a new branch
```

## Remove a worktree

```sh
wt remove <branch-name>

# If the worktree is dirty (staged files, modified files, untracked files)
wt remove --force <branch-name>
```

## List worktrees

```sh
wt list
```
