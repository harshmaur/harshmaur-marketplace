---
name: typescript-review
description: Review TypeScript code against Harsh Maur's coding standards
triggers:
  - /typescript-review
  - /review-ts
  - /harsh-review
---

# TypeScript Code Review

Review TypeScript/JavaScript code against Harsh Maur's personal coding standards.

## Instructions

1. **Load the rules** from `.windsurf/rules/typescript-review.md`

2. **Analyze the code** against each applicable rule category:
   - Extensibility & Future-Proofing (EXT-*)
   - Type Safety (TYPE-*)
   - Naming & Structure (NAME-*)
   - Comments (COMMENT-*)
   - Code Style (STYLE-*)
   - React Components (REACT-*)
   - Project Structure (STRUCT-*)

3. **Report each violation** with:
   ```
   ### [Rule ID]: [Rule Name]
   **Location:** `file.ts:line`
   **Problem:** [Brief description]
   **Current:**
   [code snippet]
   **Fix:**
   [corrected snippet]
   ```

4. **Note what's done well** - praise code that follows the rules

5. **End with a summary table:**

```markdown
---

## Code Review Summary

**Files Reviewed:** [list files]
**Review Date:** [date]

### Results by Category

| Category | Status | Issues |
|----------|--------|--------|
| Extensibility | ✅ Pass | 0 |
| Naming | ❌ Fail | 2 |
| Comments | ✅ Pass | 0 |
| Code Style | ✅ Pass | 0 |
| React Components | ❌ Fail | 1 |
| Project Structure | ✅ Pass | 0 |

### Issues Found

| # | Rule | Location | Summary |
|---|------|----------|---------|
| 1 | NAME-4 | `utils.ts:12` | Rename `data` to specific name |

### What's Good

- [Positive observations]

### Overall: ❌ NEEDS CHANGES (N issues) / ✅ ALL CLEAR

---
```
