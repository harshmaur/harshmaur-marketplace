---
name: harshmaur-typescript-review
description: Review TypeScript code against Harsh Maur's personal coding standards focused on extensibility, naming quality, and code clarity. Use when reviewing TypeScript/JavaScript code, providing code feedback, or when asked to check code quality. Enforces Harsh's opinions on: (1) Extensibility - enum-style modes over booleans, separate functions per variant, no ternaries for non-boolean conditions; (2) Naming - no spelling mistakes, abbreviations capitalized only when not first word (getUserAPI but xmlParser), userId exception for id, no meaningless/abstract names, no single-letter variables, consistent domain language; (3) Comments - explain "why" not "what", always document anti-patterns; (4) Code Style - explicit type coercion, strict typing; (5) React Components - composition over props for behavior, enum props for visual variants, minimize props, check usage frequency before modifying shared components, always use default props for backwards compatibility.
---

# Harsh Maur's TypeScript Code Review

Review TypeScript code against Harsh Maur's coding rules in `references/rules.md`.

## Review Process

1. Read `references/rules.md` (in this skill's folder) to load all coding rules
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

## Next Steps
If issues were found, suggest: "To explore solutions for these issues, consider using `/superpowers:brainstorming` to design the refactoring approach before implementing changes."
```
