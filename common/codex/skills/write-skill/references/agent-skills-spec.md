# Agent Skills Specification (Condensed)

Use this as a checklist when authoring or updating SKILL.md.

## Required Files

- `SKILL.md` is required in the skill root.
- Optional folders: `agents/`, `scripts/`, `references/`, `assets/`.

## Frontmatter

- Only `name` and `description` are required for triggering.
- `name`:
  - lowercase letters, numbers, and hyphens only
  - 1-64 characters
  - must match the skill folder name
- `description`:
  - 1-1024 characters
  - describe what the skill does and when to use it
  - include concrete triggers or examples
  - avoid long workflow summaries

## Body

- Keep SKILL.md concise and scan-friendly.
- Use progressive disclosure: keep heavy details in `references/`.
- Prefer imperative instructions and clear sectioning.

## Optional UI Metadata

- `agents/openai.yaml` can define UI display_name, short_description, and default_prompt.
- `default_prompt` should mention the skill explicitly as `$skill-name`.

## Validation

- Prefer `skills-ref validate <skill-dir>` if available.
- If not, use `scripts/quick_validate.py <skill-dir>` when present.
