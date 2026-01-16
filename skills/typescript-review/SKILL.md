---
name: harshmaur-typescript-review
description: >
  Review TypeScript code against Harsh Maur's personal coding standards focused on extensibility, naming quality, and code clarity. Use when reviewing TypeScript/JavaScript code, providing code feedback, or when asked to check code quality. Enforces Harsh's opinions on: (1) Extensibility - enum-style modes over booleans, separate functions per variant, no ternaries for non-boolean conditions; (2) Naming - no spelling mistakes, abbreviations capitalized only when not first word (getUserAPI but xmlParser), userId exception for id, no meaningless/abstract names, no single-letter variables, consistent domain language, generic naming for multi-entity functions; (3) Comments - explain "why" not "what", always document anti-patterns; (4) Code Style - explicit type coercion, strict typing, NO UNUSED CODE added for future features (variables, functions, types, exports must be used immediately - add them when the feature is implemented, not before); (5) React Components - composition over props for behavior, enum props for visual variants, minimize props, check usage frequency before modifying shared components, always use default props for backwards compatibility, hooks must encapsulate related derived logic; (6) Project Structure - types folder contains only types, no runtime functions.
---

# Harsh Maur's TypeScript Code Review

Review TypeScript code against Harsh Maur's coding rules in `references/rules.md`.

## CRITICAL: Complete Coverage Required

**You MUST review ALL files and check ALL rules. Partial reviews are not acceptable.**

### File Coverage

1. **Determine scope first:**

   - If user specifies files → review those exact files
   - If user says "review my changes" → get ALL changed files via `git diff --name-only` or `git status`
   - If user points to a directory → review ALL `.ts`, `.tsx`, `.js`, `.jsx` files in it
   - If ambiguous → ASK the user which files to review

2. **List files before reviewing:** Always print the list of files you will review BEFORE starting. Example:

   ```
   ## Files to Review (4 files)
   - src/hooks/useBulkDeploy.ts
   - src/components/DeployTable.tsx
   - src/types/bulk-deploy.ts
   - src/pages/deploy/index.tsx
   ```

3. **Review each file completely** before moving to the next file.

### Rule Coverage

**For EACH file, systematically check ALL rule categories:**

1. **Extensibility (EXT-1 to EXT-4):** Boolean flags? Implicit fallbacks? Separate functions per variant?
2. **Type Safety (TYPE-1):** Any `any` types?
3. **Naming (NAME-1 to NAME-12):** Spelling? Abbreviation casing? Meaningless names? Abstract names? Single letters?
4. **Comments (COMMENT-1 to COMMENT-2):** "What" comments? Undocumented anti-patterns?
5. **Code Style (STYLE-1 to STYLE-2):** Implicit type coercion (`!!`, `+str`)? Unused code added for future features?
6. **React (REACT-1 to REACT-7):** Composition vs props? Enum props? Hook encapsulation? Display-ready values?
7. **Structure (STRUCT-1):** Functions in types folder?

**Do NOT skip categories.** If a category doesn't apply to a file (e.g., no React in a utility file), explicitly note "N/A" for that category.

## Review Process

1. Read `references/rules.md` (in this skill's folder) to load all coding rules
2. List all files in scope
3. For EACH file: check EVERY rule category systematically
4. Report violations with:
   - The rule violated
   - The problematic code snippet
   - A corrected example
5. Note what's done well

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

**Files Reviewed:** [N] files
**Review Date:** [date]

### Coverage Verification

| File | EXT | TYPE | NAME | COMMENT | STYLE | REACT | STRUCT |
|------|-----|------|------|---------|-------|-------|--------|
| `useBulkDeploy.ts` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | N/A |
| `DeployTable.tsx` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | N/A |
| `types/bulk-deploy.ts` | N/A | ✓ | ✓ | N/A | N/A | N/A | ✓ |

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

**Files Reviewed:** [N] files
**Review Date:** [date]

### Coverage Verification

| File | EXT | TYPE | NAME | COMMENT | STYLE | REACT | STRUCT |
|------|-----|------|------|---------|-------|-------|--------|
| `file1.ts` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | N/A |
| `file2.tsx` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | N/A |

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
