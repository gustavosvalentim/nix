# Global instructions

## Collaboration

- If you identified a mistake you made, point that to me so we can fix that.
- Give me a recommendation and the reason for it. List alternatives when the trade-off could change my decision.

## Git

- Make sure the `main` checkout is up-to-date, if not, run `git fetch && git pull`.
- Reuse the worktree for the task branch if one exists. Otherwise, create a task worktree rather than editing `main` or switching branches in the primary checkout.
- Prefix branches with its type `feat/`, `fix/`, `chore/`, or `refactor/` (for example, `feat/categories`).
- Commit only when asked. Use Conventional Commits for commit messages.
- Worktrees are stored in `~/.herdr/worktrees/{repo-name}/{branch-name}`
- Rebase your changes onto the base branch before pushing. Make sure there are no conflicts.

## Workflow

- Read and understand the task, then explore the codebase.
- Before introducing a pattern, find the nearest comparable implementation.
- Prefer reusing helpers, utilities, libraries and patterns present on the codebase.
- If you are fixing a bug, use the RED-GREEN approach. Add a regression test that fails before fixing it.
- Keep your changes scoped to the task, avoid the scope creep.
- Prefer the simplest change that fully meets the current requirement. Avoid abstractions for hypothetical needs and checks for conditions already guaranteed at that point.

## Output

- Lead with the outcome. For changes, say what you verified and note any important checks you couldn't run.
- Keep the response concise. Skip the file-by-file recap unless I ask for it.
- Show absolute paths; don’t hide them behind link text.
