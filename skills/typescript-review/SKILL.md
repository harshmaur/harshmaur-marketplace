---
name: harshmaur-typescript-review
description: Review TypeScript code against Harsh Maur's personal coding standards focused on extensibility, naming quality, and code clarity. Use when reviewing TypeScript/JavaScript code, providing code feedback, or when asked to check code quality. Enforces Harsh's opinions on: (1) Extensibility - enum-style modes over booleans, separate functions per variant, no ternaries for non-boolean conditions; (2) Naming - no spelling mistakes, abbreviations capitalized only when not first word (getUserAPI but xmlParser), userId exception for id, no meaningless/abstract names, no single-letter variables, consistent domain language, generic naming for multi-entity functions; (3) Comments - explain "why" not "what", always document anti-patterns; (4) Code Style - explicit type coercion, strict typing; (5) React Components - composition over props for behavior, enum props for visual variants, minimize props, check usage frequency before modifying shared components, always use default props for backwards compatibility, hooks must encapsulate related derived logic; (6) Project Structure - types folder contains only types, no runtime functions.
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

Structure feedback in two parts: detailed findings during review, then a **Summary Report** at the end.

### During Review

For each issue found:
```
### [Rule ID]: [Rule Name]
**Location:** `file.ts:line`
**Problem:** [Brief description]
**Current:**
[code snippet]
**Fix:**
[corrected snippet]
```

### Summary Report (Always Print at End)

Always end with this copy-paste friendly summary:

```
---

## Code Review Summary

**Files Reviewed:** [list files]
**Review Date:** [date]

### Results by Category

| Category | Status | Issues |
|----------|--------|--------|
| Extensibility | :white_check_mark: Pass | 0 |
| Naming | :x: Fail | 2 |
| Comments | :white_check_mark: Pass | 0 |
| Code Style | :white_check_mark: Pass | 0 |
| React Components | :x: Fail | 1 |
| Project Structure | :white_check_mark: Pass | 0 |

### Issues Found (3)

| # | Rule | Location | Summary |
|---|------|----------|---------|
| 1 | NAME-9 | `route.ts:45` | Use generic `itemId` instead of `ruleId`/`iocId` |
| 2 | NAME-4 | `utils.ts:12` | Rename `data` to specific name |
| 3 | REACT-6 | `DeploySettings.tsx:8` | Move `getItemTypeConfig` into hook |

### What's Good

- [Positive observation 1]
- [Positive observation 2]

### Overall: :x: NEEDS CHANGES (3 issues) / :white_check_mark: ALL CLEAR

---
```

When all checks pass:
```
---

## Code Review Summary

**Files Reviewed:** [list files]
**Review Date:** [date]

### Results by Category

| Category | Status | Issues |
|----------|--------|--------|
| Extensibility | :white_check_mark: Pass | 0 |
| Naming | :white_check_mark: Pass | 0 |
| Comments | :white_check_mark: Pass | 0 |
| Code Style | :white_check_mark: Pass | 0 |
| React Components | :white_check_mark: Pass | 0 |
| Project Structure | :white_check_mark: Pass | 0 |

### What's Good

- [Specific positive observations]

### Overall: :white_check_mark: ALL CLEAR - Code follows all standards!

---
```
