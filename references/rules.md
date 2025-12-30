# Harsh Maur's TypeScript Coding Rules

## Extensibility & Future-Proofing

### EXT-1: Use Enum-Style Modes, Not Boolean Flags

Use a `mode` or `type` variable with explicit values instead of boolean flags like `isXMode`.

**Why:** Boolean flags assume only 2 states. Adding a third mode requires renaming variables and refactoring all conditions.

```typescript
// ❌ Bad: Boolean flag locks you into 2 modes
const isIOCMode = true;

if (isIOCMode) {
  // IOC logic
} else {
  // Rules logic (implicit)
}

// ✅ Good: Enum-style mode is extensible
type ProcessingMode = 'IOC' | 'RULES';
const mode: ProcessingMode = 'IOC';

if (mode === 'IOC') {
  // IOC logic
} else if (mode === 'RULES') {
  // Rules logic (explicit)
}

// Adding a third mode is trivial:
type ProcessingMode = 'IOC' | 'RULES' | 'HYBRID';
```

---

### EXT-2: Separate Functions Per Variant + Shared Helper

When logic differs significantly by mode/type, create separate functions per variant plus a shared helper for common logic. Avoid single functions with many if-else branches.

**Why:** Single functions with conditionals become bloated and hard to extend. Separate functions are easier to modify independently.

```typescript
// ❌ Bad: Single function with conditional branching
function processData(mode: ProcessingMode, data: Data) {
  if (mode === 'IOC') {
    // 50 lines of IOC-specific logic
    // common logic mixed in
  } else if (mode === 'RULES') {
    // 50 lines of Rules-specific logic
    // common logic duplicated
  }
}

// ✅ Good: Separate functions + shared helper
function processCommon(data: Data): ProcessedData {
  // shared logic here
}

function processIOC(data: Data): Result {
  const processed = processCommon(data);
  // IOC-specific logic
}

function processRules(data: Data): Result {
  const processed = processCommon(data);
  // Rules-specific logic
}
```

---

### EXT-3: Separate UI Pages Per Variant + Shared Components

When UI pages differ significantly by mode/type, create separate page components with shared sub-components. Avoid single pages with many conditional renders.

**Why:** Single pages with conditionals become unreadable. Separate pages allow independent evolution.

```typescript
// ❌ Bad: Single page with conditional rendering everywhere
function DataPage({ mode }: { mode: ProcessingMode }) {
  return (
    <div>
      {mode === 'IOC' ? <IOCHeader /> : <RulesHeader />}
      {mode === 'IOC' ? <IOCForm /> : <RulesForm />}
      {mode === 'IOC' ? <IOCTable /> : <RulesTable />}
    </div>
  );
}

// ✅ Good: Separate pages + shared components
// SharedComponents.tsx
export function DataTable({ data }: Props) { /* common table */ }
export function PageLayout({ children }: Props) { /* common layout */ }

// IOCPage.tsx
function IOCPage() {
  return (
    <PageLayout>
      <IOCHeader />
      <IOCForm />
      <DataTable data={iocData} />
    </PageLayout>
  );
}

// RulesPage.tsx
function RulesPage() {
  return (
    <PageLayout>
      <RulesHeader />
      <RulesForm />
      <DataTable data={rulesData} />
    </PageLayout>
  );
}
```

---

### EXT-4: Avoid Ternaries for Non-Boolean Conditions

Use ternaries only for true boolean conditions. For mode/type-based logic, use functions or if-else.

**Why:** Ternaries assume exactly 2 outcomes. They silently break when a third option is added.

```typescript
// ❌ Bad: Ternary assumes only 2 modes forever
const label = mode === 'IOC' ? 'IOC Label' : 'Rules Label';
// What happens when mode === 'HYBRID'? Silent bug: shows "Rules Label"

// ❌ Bad: Ternary in JSX
<span>{mode === 'IOC' ? 'Processing IOC...' : 'Processing Rules...'}</span>

// ✅ Good: Helper function handles all cases explicitly
function getModeLabel(mode: ProcessingMode): string {
  if (mode === 'IOC') return 'IOC Label';
  if (mode === 'RULES') return 'Rules Label';
  if (mode === 'HYBRID') return 'Hybrid Label';
  // TypeScript will error if a case is missing (with exhaustive checks)
  throw new Error(`Unknown mode: ${mode}`);
}

const label = getModeLabel(mode);
<span>{getModeLabel(mode)}</span>

// ✅ OK: Ternary for actual booleans
const statusText = isLoading ? 'Loading...' : 'Ready';
const icon = hasError ? <ErrorIcon /> : <SuccessIcon />;
```

---

## Type Safety

### TYPE-1: Never Use `any` Unless Absolutely Necessary

Avoid `any` type. Use `unknown`, generics, or proper types instead.

**Why:** `any` disables TypeScript's benefits and hides bugs.

```typescript
// ❌ Bad: any disables type checking
function processData(data: any) {
  return data.foo.bar; // No error even if foo doesn't exist
}

// ✅ Good: Use proper types
interface DataShape {
  foo: { bar: string };
}
function processData(data: DataShape) {
  return data.foo.bar; // Type-safe
}

// ✅ Good: Use unknown + type guards for truly unknown data
function processUnknown(data: unknown) {
  if (typeof data === 'object' && data !== null && 'foo' in data) {
    // narrow the type safely
  }
}

// ✅ Good: Use generics for flexible but type-safe functions
function processData<T extends { id: string }>(data: T): T {
  return data;
}
```

---

## Adding New Rules

To add a new rule:
1. Choose or create an appropriate category
2. Assign a rule ID (e.g., `EXT-5`, `TYPE-2`)
3. Include: rule name, rationale ("Why"), bad example, good example
