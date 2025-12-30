# Harsh Maur's TypeScript Review Skill

A Claude skill that reviews TypeScript code against my personal coding standards focused on **extensibility and future-proofing**.

## Philosophy

> "Design for N cases, not just 2"

Code should be written to gracefully handle future requirements, not just today's binary choices.

## Rules Included

| ID     | Rule                        | Summary                                                        |
| ------ | --------------------------- | -------------------------------------------------------------- |
| EXT-1  | Enum-Style Modes            | Use `mode: 'IOC' \| 'RULES'` instead of `isIOCMode: boolean`   |
| EXT-2  | Separate Functions          | Split variant logic into separate functions + shared helper    |
| EXT-3  | Separate UI Pages           | Split variant UIs into separate pages + shared components      |
| EXT-4  | Avoid Non-Boolean Ternaries | Use helper functions instead of ternaries for mode-based logic |
| TYPE-1 | No `any`                    | Use proper types, `unknown`, or generics                       |

## Installation

### Claude Code

```bash
/plugin marketplace add harshmaur/harshmaur-marketplace
/plugin install harshmaur-typescript-review
```

## Usage

Just paste your TypeScript code and ask for a review. Claude will automatically apply these rules.

## Contributing

Feel free to suggest new rules! Open an issue or PR.

## License

MIT
