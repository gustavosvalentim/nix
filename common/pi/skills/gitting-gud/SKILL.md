---
name: gitting-gud
description: Instructions for how to commit and push code to a git repository. Use when commiting or pushing code, or creating a PR.
---

# Gitting Gud

This is a guide for how to commit and push code, or create a PR, to a git repository.

## Naming conventions

- Commits: Follow the [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.
- Branches: Use `kebab-case` for branch names. Prefix with `feat/`, `fix/`, `chore/`, `refactor/`, `docs/`. After prefix, if there is an issue related to the branch, use the issue number, e.g. `feat/test-123`.

## Commits

- Commit messages should be written in the imperative mood.
- Commit messages should be written in present tense.

## Push

- Use `git push -u origin <branch>` to push your changes to the remote repository.
- Always ask the user before using `git push --force-with-lease`.

## Pull requests

- Attach the relevant evidence to the PR description.
- If the repository has a PR template, use it.
