# Harsh Maur's TypeScript Review Skill

A Claude skill that reviews TypeScript code against my personal coding standards focused on **extensibility, naming quality, and code clarity**.

## Philosophy

> "Design for N cases, not just 2. Be intentional about every name and every prop."

Code should be written to gracefully handle future requirements, with names that communicate clearly and components that compose elegantly.

## Rules Included (35 Rules)

### Extensibility & Future-Proofing

| ID    | Rule                        | Summary                                                        |
| ----- | --------------------------- | -------------------------------------------------------------- |
| EXT-1 | Enum-Style Modes            | Use `mode: 'IOC' \| 'RULES'` instead of `isIOCMode: boolean`   |
| EXT-2 | Separate Functions          | Split variant logic into separate functions + shared helper    |
| EXT-3 | Separate UI Pages           | Split variant UIs into separate pages + shared components      |
| EXT-4 | Avoid Implicit Fallbacks    | Explicit checks for all enum values; no implicit else for non-booleans |

### Type Safety

| ID     | Rule     | Summary                                  |
| ------ | -------- | ---------------------------------------- |
| TYPE-1 | No `any` | Use proper types, `unknown`, or generics |

### Naming & Structure

| ID      | Rule                       | Summary                                                                                 |
| ------- | -------------------------- | --------------------------------------------------------------------------------------- |
| NAME-1  | No Spelling Mistakes       | Variable names and comments must be spelled correctly                                   |
| NAME-2  | Abbreviation Casing        | Caps only when not first word (`getUserAPI` but `xmlParser`), `id` exception (`userId`) |
| NAME-3  | No Meaningless Names       | No `foo`, `bar`, `temp`, `tmp`                                                          |
| NAME-4  | No Abstract Names          | No `data`, `object`, `thing`, `item`, `info`, `value`, `result`                         |
| NAME-5  | No Numeric Suffixes        | No `user2`, `data_2` - use descriptive names                                            |
| NAME-6  | No Ambiguous Abbreviations | No `acc`, `pos`, `auth`, `val`, `res`, `btn`, `cb`, `fn`                                |
| NAME-7  | No Single-Letter Names     | No `i`, `j`, `k`, `e`, `x` - even in loops                                              |
| NAME-8  | No Vague Words             | Avoid `Manager`, `Handler`, `Helper`; use specific verbs over `get`                     |
| NAME-9  | Generic Naming             | Use `itemId` instead of `ruleId`/`iocId` in multi-entity functions                      |
| NAME-10 | No Hungarian Notation      | No `isVictory`, `strName`, `numCount` - let types do the work                           |
| NAME-11 | Use Domain Words           | `calendar` not `appointmentList`, `employee` not `companyPerson`                        |
| NAME-12 | Consistent Domain Language | Same concept = same terminology throughout codebase                                     |

### Comments

| ID        | Rule                      | Summary                                                  |
| --------- | ------------------------- | -------------------------------------------------------- |
| COMMENT-1 | Comment "Why", Not "What" | Only explain reasoning, not what the code does           |
| COMMENT-2 | Document Anti-Patterns    | Always explain workarounds and intentional anti-patterns |

### Code Style

| ID      | Rule                          | Summary                                                          |
| ------- | ----------------------------- | ---------------------------------------------------------------- |
| STYLE-1 | No Implicit Coercion          | `Boolean(x)` not `!!x`, `Number(x)` not `+x`                     |
| STYLE-2 | No Unused Code                | Don't add code for future features; add when actually needed     |
| STYLE-3 | Delete Unnecessary Type Aliases | If `type A = B` adds nothing, just use `B` directly            |
| STYLE-4 | Prefer Spread Operators       | `{...tooltip}` not manual property listing                       |

### React Components

| ID      | Rule                       | Summary                                                            |
| ------- | -------------------------- | ------------------------------------------------------------------ |
| REACT-1 | Composition Over Props     | Use composition for behavior changes, not new props                |
| REACT-2 | Enum Props for Variants    | `size: 'small' \| 'medium'` not `smallSize: boolean`               |
| REACT-3 | Be Intentional About Props | Props are fine if meaningful and reused; avoid one-off props       |
| REACT-4 | Default Props              | Always provide defaults for backwards compatibility                |
| REACT-5 | Check Usage Frequency      | One-off? Don't modify component. Many places? Compose or add prop. |
| REACT-6 | Hooks Encapsulate Logic    | Hooks return derived values; don't create separate utility files   |
| REACT-7 | Display-Ready Values       | Data hooks return pre-formatted values in nested `formatted` object |
| REACT-8 | Flexible Input Types       | Accept `string \| object`, normalize internally for convenience     |
| REACT-9 | No Redundant Props         | Don't add two props that accomplish the same thing                  |
| REACT-10| No Unnecessary Customization | Remove props for hypothetical customization that isn't needed     |
| REACT-11| Self-Explanatory Props     | Prop names should be clear without needing documentation            |

### Project Structure

| ID      | Rule                       | Summary                                                            |
| ------- | -------------------------- | ------------------------------------------------------------------ |
| STRUCT-1| Types Folder Contains Only Types | No runtime functions in `types/` folder; only type definitions |

## Installation

### Claude Code

```bash
claude plugin add harshmaur/harshmaur-marketplace
claude plugin install harshmaur-typescript-review@harshmaur-marketplace
```

### Windsurf

Run this in your project directory:

```bash
curl -fsSL https://raw.githubusercontent.com/harshmaur/harshmaur-marketplace/main/install-windsurf.sh | bash
```

To **update** to the latest rules, run the same command again.

## Usage

### Claude Code

Say "review my code using harshmaur-typescript-review" or use the skill directly.

### Windsurf

Use any of these slash commands:
- `/typescript-review`
- `/review-ts`
- `/harsh-review`

Or ask Cascade: "Review this code against Harsh's TypeScript standards"

## Contributing

Feel free to suggest new rules! Open an issue or PR.

## License

MIT
