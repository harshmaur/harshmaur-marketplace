---
name: harsh-maur-typescript-review
description: Review TypeScript code against Harsh Maur's personal coding standards focused on extensibility and future-proofing. Use when reviewing TypeScript/JavaScript code, providing code feedback, or when asked to check code quality. Enforces Harsh's opinions on avoiding boolean flags, preferring enum-style modes, separating variant-specific logic, avoiding ternaries for non-boolean conditions, and strict typing.
---

# Harsh Maur's TypeScript Code Review

Review TypeScript code against Harsh Maur's coding rules in `references/rules.md`.

## Review Process

1. Read `references/rules.md` to load all coding rules
2. Analyze the provided code against each applicable rule
3. Report violations with:
   - The rule violated
   - The problematic code snippet
   - A corrected example
4. Praise code that follows the rules well

## Output Format

Structure feedback as:

```
## Issues Found

### [Rule Name]
**Problem:** [Brief description]
**Location:** [File/line if available]
**Current code:**
[snippet]
**Suggested fix:**
[corrected snippet]

## What's Good
[Positive observations about code that follows the rules]
```
