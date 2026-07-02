# Harsh Maur's TypeScript Review Skill

A Claude skill that reviews TypeScript code against my personal coding standards focused on **extensibility, naming quality, and code clarity**.

## Philosophy

> "Design for N cases, not just 2. Be intentional about every name and every prop."

Code should be written to gracefully handle future requirements, with names that communicate clearly and components that compose elegantly.

## Rules Included (50 Rules)

### Extensibility & Future-Proofing

| ID    | Rule                        | Summary                                                        |
| ----- | --------------------------- | -------------------------------------------------------------- |
| EXT-1 | Enum-Style Modes            | Use `mode: 'IOC' \| 'RULES'` instead of `isIOCMode: boolean`   |
| EXT-2 | Separate Functions          | Split variant logic into separate functions + shared helper    |
| EXT-3 | Separate UI Pages           | Split variant UIs into separate pages + shared components      |
| EXT-4 | Avoid Implicit Fallbacks    | Explicit checks for all enum values; no implicit else for non-booleans |

### Type Safety

| ID     | Rule                        | Summary                                                              |
| ------ | --------------------------- | -------------------------------------------------------------------- |
| TYPE-1 | No `any`                    | Use proper types, `unknown`, or generics                             |
| TYPE-2 | Justify Type Escape Hatches | Comment why `@ts-ignore`/`as unknown`/catch-all casts are necessary  |
| TYPE-3 | No Redundant Type Checks    | Don't `typeof`/`instanceof` check a value TypeScript already guarantees |

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
| NAME-13 | Names Must Match Behavior  | A name must describe what it actually controls; flag names that lie                     |

### Comments

| ID        | Rule                      | Summary                                                  |
| --------- | ------------------------- | -------------------------------------------------------- |
| COMMENT-1 | Comment "Why", Not "What" | Only explain reasoning, not what the code does           |
| COMMENT-2 | Document Anti-Patterns    | Always explain workarounds and intentional anti-patterns |
| COMMENT-3 | No Stale TODOs            | Delete TODO/FIXME comments for work already done or decided |

### Code Style

| ID      | Rule                          | Summary                                                          |
| ------- | ----------------------------- | ---------------------------------------------------------------- |
| STYLE-1 | No Implicit Coercion          | `Boolean(x)` not `!!x`, `Number(x)` not `+x`                     |
| STYLE-2 | No Unused Code                | Don't add code for future features; add when actually needed     |
| STYLE-3 | Delete Unnecessary Type Aliases | If `type A = B` adds nothing, just use `B` directly            |
| STYLE-4 | Prefer Spread Operators       | `{...tooltip}` not manual property listing                       |
| STYLE-5 | Optional Booleans Need a Default | Give every `boolean?` prop/param a default to avoid the tri-state |
| STYLE-6 | Justify New Abstractions      | Confirm a concrete need before adding a condition, wrapper, hook, or middleware |

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

### Logic & Correctness

| ID      | Rule                          | Summary                                                            |
| ------- | ----------------------------- | ------------------------------------------------------------------ |
| LOGIC-1 | No Duplicate Conditional Branches | Collapse or fix `if`/`else`/`switch` branches with identical bodies |
| LOGIC-2 | Handle Edge Cases in Guards   | Empty collections, null, boundaries, missing `await` in guards     |
| LOGIC-3 | Conditions Must Match Their Case | Permission checks and status messages must reference the actual case, not a copy-pasted neighbor |
| LOGIC-4 | Controlled Inputs & Effects Must Be Honest | Pair `value` with `onChange`, depend on everything an effect reads, reset loading flags before refetch |

### Performance & Scale

| ID      | Rule                          | Summary                                                            |
| ------- | ----------------------------- | ------------------------------------------------------------------ |
| SCALE-1 | Don't Filter Large Collections In Memory | Push `filter`/`map`/`find` to the data source and paginate |
| SCALE-2 | Paginate Unbounded Queries    | No hardcoded high limits or unbounded fetches; paginate            |

### Debug Artifacts

| ID      | Rule                          | Summary                                                            |
| ------- | ----------------------------- | ------------------------------------------------------------------ |
| DEBUG-1 | No Stray Test Identifiers     | Remove auto-generated/placeholder test ids from production paths   |
| DEBUG-2 | No Leftover Console Logging   | No stray `console.log`/`console.debug` in shipped code             |

### Security

| ID      | Rule                          | Summary                                                            |
| ------- | ----------------------------- | ------------------------------------------------------------------ |
| SEC-1   | Enforce Object-Level Authorization | Verify caller owns the resource server-side; don't trust client IDs. Applies to every scoping key when a resource has more than one (e.g. partner + soc) |

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
