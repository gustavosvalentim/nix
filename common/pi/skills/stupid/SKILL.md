---
name: stupid
description: A guide on how to build simple, maintainable, and correct code. Use when the user asks you to implement a task, change the code, fix a bug, or refactor code.
---

# Stupid

Implement the simplest complete, maintainable change. Optimize for clarity and necessity, not the fewest lines.

## The workflow

1. Understand the task. If the requirements are unclear, ask before continuing.
2. Read the repository instructions, guidelines and documentation.
3. Choose the smallest but correct approach. Don't sacrifice correctness over clarity.
4. Validate your changes with tests, linters, formatters, and other quality checks.

## Heuristics for choosing a solution

1. Already in the codebase? A helper, util, type, or pattern that already lives here → reuse it. Look before you write; re-implementing what's a few files over is the most common slop.
2. Stdlib does it? Use it.
3. Native platform feature covers it? <input type="date"> over a picker lib, CSS over JS, DB constraint over app code.
4. Already-installed dependency solves it? Use it. Never add a new one for what a few lines can do.
5. Can it be one line? One line.
6. Only then: the minimum code that works.

The heuristics only works after you've understood the task, existing code, and tests, not before. Read the task, trace the real flow end to end, then use the heuristics as your starting point.

When fixing a bug, identify the root cause, don't fix the symptom. The user will report a symptom. Before fixing, understand the root cause use the RED-GREEN approach from TDD. Build a failing test, then fix it. The simplest fix is the root cause fix.

## Rules

- Research before choosing a solution. If you need to, go after documentation about a framework, library, or platform feature.
- Fewest files possible. Shortest working diff wins — but only once you understand the problem. The smallest change in the wrong place isn't lazy, it's a second bug.
- Complex request? Ship the lazy version and question it in the same response, "Did X; Y covers it. Need full X? Say so." Never stall on an answer you can default.
- Two stdlib options, same size? Take the one that's correct on edge cases. Lazy means writing less code, not picking the flimsier algorithm.
- Boring over clever. Prioritize the simplest correct solution, not the fewest lines.

## When not to follow the rules

Never simplify away: input validation at trust boundaries, error handling that prevents data loss, security measures, accessibility basics, anything explicitly requested. User insists on the full version → build it, no re-arguing.

## Output

Code first. Then at most three short lines: what was skipped, when to add it. No essays, no feature tours, no design notes. If the explanation is longer than the code, delete the explanation, every paragraph defending a simplification is complexity smuggled back in as prose. Explanation the user explicitly asked for (a report, a walkthrough, per-phase notes) is not debt, give it in full, the rule is only against unrequested prose.
