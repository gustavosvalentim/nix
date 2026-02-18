---
name: commit
description: Create well-structured git commits following conventional commits format. Use when the user asks to commit changes or when finishing a piece of work.
metadata:
  short-description: Commit workflow
---

# Commit Workflow

Create clean, meaningful commits that tell a story following the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.

## Before Committing

### 1. Review Changes

```bash
# See what's changed
git status
git diff

# See staged changes
git diff --staged
```

Check for:
- Unintended changes
- Debug code or console.log statements
- Commented-out code
- Hardcoded values that should be configurable
- Sensitive data (secrets, credentials, PII)

### 2. Run Tests

Run tests related to your changes:
```bash
# Run all tests (or project-specific command)
npm test
pytest
go test ./...
```

Don't commit if tests are failing.

### 3. Stage Thoughtfully

Stage files intentionally, not blindly:

```bash
# Stage specific files
git add path/to/file.ts

# Stage portions of a file
git add -p path/to/file.ts

# Avoid staging everything blindly
# git add .  # Be careful with this
```

## Writing Commit Messages

Follow the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification.

### Format

```
type(scope): subject

body (optional)

footer (optional)
```

### Type

| Type | Use for |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change, no new feature or fix |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `chore` | Maintenance, dependencies |
| `ci` | CI/CD changes |
| `build` | Build system changes |

### Scope (Optional)
The component or area affected: `feat(auth)`, `fix(api)`, `docs(readme)`

### Subject
- Imperative mood: "add" not "added" or "adds"
- Lowercase, no period at end
- Under 50 characters
- Complete the sentence: "This commit will..."

### Body (Optional)
- Explain what and why, not how
- Wrap at 72 characters
- Blank line between subject and body

### Footer (Optional)
- Breaking changes: `BREAKING CHANGE: description`
- Issue references: `Fixes #123`, `Closes #456`

### Examples

**Simple feature:**
```
feat(auth): add password reset flow
```

**Bug fix with context:**
```
fix(api): handle null response from payment provider

The payment API sometimes returns null instead of an error object
when the service is degraded. This caused unhandled exceptions.

Fixes #234
```

**Breaking change:**
```
feat(api)!: change user endpoint response format

BREAKING CHANGE: The /users endpoint now returns an object with
a 'data' wrapper instead of a raw array. Update clients to
access response.data instead of response directly.
```

**Refactoring:**
```
refactor(database): extract connection pooling to separate module

No behavior change. Preparing for adding read replicas support.
```

## Commit Hygiene

### Atomic Commits
Each commit should be one logical change:
- All related changes together
- Unrelated changes in separate commits
- Should build and pass tests independently

### Commit Size
- Small enough to review easily
- Large enough to be a complete thought
- Split "and" commits: "add X and fix Y" → two commits

### What Not to Commit
- Secrets, credentials, API keys
- Generated files (unless intentional)
- Build artifacts
- IDE/editor settings (unless shared)
- Large binary files

## After Committing

### Verify the Commit
```bash
# Check the commit looks correct
git show

# Check the log
git log --oneline -5
```

### If You Made a Mistake

**Amend the last commit** (before pushing):
```bash
git add forgotten-file.ts
git commit --amend
```

**Fix commit message** (before pushing):
```bash
git commit --amend -m "correct message"
```

**Undo last commit** (keep changes):
```bash
git reset --soft HEAD~1
```

## Commit Checklist

Before running `git commit`:

- [ ] Changes reviewed (`git diff --staged`)
- [ ] Tests pass
- [ ] No debug code left
- [ ] No sensitive data
- [ ] Commit message follows format
- [ ] Commit is atomic (one logical change)

## References

- [Conventional Commits Specification v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
- `shared/guidelines/git-workflow.md` for full git workflow

## Reminders

- Don't commit broken code to shared branches
- Write messages for future readers (including future you)

