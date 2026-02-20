---
name: write-skill
description: Create or update Agent Skills (SKILL.md plus optional resources) following the Agent Skills specification and writing-skills TDD workflow. Use when the user asks to create a skill, edit a skill, or validate a skill definition.
---

# Write Skill

## Overview

Create, update, and validate Agent Skills that are compliant with the Agent Skills specification and robust under real usage. Apply the writing-skills test-driven approach and Anthropic prompt best practices to keep skills clear, discoverable, and resistant to ambiguity.

## Required Inputs

If any are missing, ask the user before proceeding:

- Skill purpose and scope
- 2-3 concrete example prompts that should trigger the skill
- Expected outputs or success criteria
- Any required scripts, references, or assets
- Target location for the skill folder (default: $CODEX_HOME/skills)

## Workflow (TDD for Skills)

1. **RED (Baseline):** Run a pressure scenario without the skill. If subagents are available, use one to attempt the task and capture failures and rationalizations. If you cannot run this baseline, explicitly note the gap and ask whether to proceed.
2. **GREEN (Minimal Skill):** Write the smallest SKILL.md that addresses the observed failures. Do not add speculative content.
3. **REFACTOR (Close Loopholes):** Re-run the same scenario with the skill present, capture new rationalizations, and patch the documentation until compliance holds.

## Build the Skill

1. **Create the directory** using the initializer if available (preferred):
   - `scripts/init_skill.py <skill-name> --path <output-directory> [--resources scripts,references,assets]`
2. **Frontmatter (YAML)**
   - `name`: lowercase letters, numbers, hyphens only; 1-64 chars; must match folder name.
   - `description`: 1-1024 chars; describe both what the skill does and when to use it. Keep it short and trigger-focused; avoid summarizing the full workflow.
3. **Body (Markdown)**
   - Use imperative voice.
   - Keep SKILL.md concise; move large references to `references/`.
   - Include sections that make scanning easy and reduce ambiguity:
     - Overview (1-2 sentences)
     - When to Use / When Not to Use
     - Core Workflow or Decision Tree
     - Examples (realistic prompts and expected outcomes)
     - Edge Cases / Common Mistakes
4. **Resources**
   - Add `references/` for heavy docs or specs.
   - Add `scripts/` for reusable automation.
   - Add `assets/` for templates or static files.
5. **Validate**
   - Prefer: `skills-ref validate <skill-dir>`.
   - Fallback: `scripts/quick_validate.py <skill-dir>` if available.
6. **Update UI metadata**
   - `agents/openai.yaml` should include:
     - `display_name`
     - `short_description` (25-64 chars)
     - `default_prompt` that explicitly mentions `$write-skill` (or the new skill name)

## Anthropic Prompt Best Practices

Apply these when writing skill content:

- Be explicit about desired outputs and constraints.
- Provide context for why the rule or step matters.
- Use concrete examples and preferred formats.
- Allow uncertainty: instruct the agent to ask questions when requirements are unclear.

See `references/anthropic-best-practices.md` for the condensed guidance.

## Agent Skills Specification Notes

Follow the formal constraints and progressive disclosure guidance in `references/agent-skills-spec.md`.

## Output Contract

When delivering work, include:

- Files created or updated
- Frontmatter compliance notes
- Validation results (command + status)
- Any skipped tests and why
- Open questions for the user
