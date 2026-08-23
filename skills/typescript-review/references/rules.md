# Harsh Maur's TypeScript Coding Rules

## Extensibility & Future-Proofing

### EXT-1: Use Enum-Style Modes, Not Boolean Flags

Use a `mode` or `type` variable with explicit values instead of boolean flags like `isXMode`.

**Why:** Boolean flags assume only 2 states. Adding a third mode requires renaming variables and refactoring all conditions.

**Scope:** Only flag booleans that represent a MODE or TYPE likely to grow a third variant - state machines, processing modes, entity kinds. Do NOT flag simple one-off or leaf config booleans (`disabled`, `isLoading`, `showBorder`); those are genuinely binary and forcing them into an enum is over-engineering.

```typescript
// ❌ Bad: Boolean flag locks you into 2 modes
const isIOCMode = true;

if (isIOCMode) {
  // IOC logic
} else {
  // Rules logic (implicit)
}

// ✅ Good: Enum-style mode is extensible
type ProcessingMode = "IOC" | "RULES";
const mode: ProcessingMode = "IOC";

if (mode === "IOC") {
  // IOC logic
} else if (mode === "RULES") {
  // Rules logic (explicit)
}

// Adding a third mode is trivial:
type ProcessingMode = "IOC" | "RULES" | "HYBRID";
```

---

### EXT-2: Separate Functions Per Variant + Shared Helper

When logic differs significantly by mode/type, create separate functions per variant plus a shared helper for common logic. Avoid single functions with many if-else branches.

**Why:** Single functions with conditionals become bloated and hard to extend. Separate functions are easier to modify independently.

```typescript
// ❌ Bad: Single function with conditional branching
function processData(mode: ProcessingMode, data: Data) {
  if (mode === "IOC") {
    // 50 lines of IOC-specific logic
    // common logic mixed in
  } else if (mode === "RULES") {
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
      {mode === "IOC" ? <IOCHeader /> : <RulesHeader />}
      {mode === "IOC" ? <IOCForm /> : <RulesForm />}
      {mode === "IOC" ? <IOCTable /> : <RulesTable />}
    </div>
  );
}

// ✅ Good: Separate pages + shared components
// SharedComponents.tsx
export function DataTable({ data }: Props) {
  /* common table */
}
export function PageLayout({ children }: Props) {
  /* common layout */
}

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

### EXT-4: Avoid Implicit Fallbacks for Non-Boolean Conditions

Never use implicit fallbacks (ternary else or if/else without explicit check) for enum-style types. Every possible value must be explicitly handled.

**Why:** Implicit fallbacks assume exactly 2 outcomes. When a third option is added, the fallback silently handles it incorrectly instead of failing loudly.

```typescript
// ❌ Bad: Ternary assumes only 2 modes forever
const label = mode === "IOC" ? "IOC Label" : "Rules Label";
// What happens when mode === 'HYBRID'? Silent bug: shows "Rules Label"

// ❌ Bad: Ternary in JSX
<span>{mode === "IOC" ? "Processing IOC..." : "Processing Rules..."}</span>;

// ❌ Bad: Implicit else assumes only 2 types forever
if (type === "iocs") {
  processIoc(data);
} else {
  processRule(data);  // What if type === "alerts"? Silent bug!
}

// ✅ Good: Helper function handles all cases explicitly
function getModeLabel(mode: ProcessingMode): string {
  if (mode === "IOC") return "IOC Label";
  if (mode === "RULES") return "Rules Label";
  if (mode === "HYBRID") return "Hybrid Label";
  throw new Error(`Unknown mode: ${mode}`);
}

// ✅ Good: Explicit check for each type + throw for unknown
if (type === "iocs") {
  processIoc(data);
} else if (type === "rules") {
  processRule(data);
} else {
  throw new Error(`Unknown type: ${type}`);
}

// ✅ OK: Ternary/implicit else for actual booleans
const statusText = isLoading ? "Loading..." : "Ready";
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
  if (typeof data === "object" && data !== null && "foo" in data) {
    // narrow the type safely
  }
}

// ✅ Good: Use generics for flexible but type-safe functions
function processData<T extends { id: string }>(data: T): T {
  return data;
}
```

---

### TYPE-2: Justify Type Escape Hatches

When you use a type escape hatch (`@ts-ignore`, `as unknown`, `as unknown as T`, or a catch-all intersection like `& Record<string, unknown>`), ALWAYS add a comment explaining why it's necessary. Flag any escape hatch used without one.

**Why:** These escapes silently bypass the type checker. Without a comment, the next reader can't tell whether the escape is a deliberate, understood trade-off or an accidental hole - and a later refactor can break the assumption it's papering over with no compile-time warning.

```typescript
// ❌ Bad: Escape hatch with no explanation
const payload = response as unknown as UserPayload;

// @ts-ignore
legacyWidget.render(container);

const config = rawInput as unknown; // Why is this needed?

// ✅ Good: Narrow properly instead of escaping
function isUserPayload(value: unknown): value is UserPayload {
  return typeof value === "object" && value !== null && "id" in value;
}
const payload = isUserPayload(response) ? response : null;

// ✅ Good: If the escape is genuinely unavoidable, explain why (see COMMENT-2)
// The upstream @legacy/widget types are wrong: render() accepts an Element
// but is typed as (id: string). Tracked in JIRA-4821.
// @ts-ignore
legacyWidget.render(container);
```

---

### TYPE-3: Don't Re-Check Types TypeScript Already Guarantees

Never add a runtime `typeof`/`instanceof` check for a value whose type is already narrowed or guaranteed by its TypeScript type.

**Why:** A runtime check for something the type system already promises is dead code - the "impossible" branch can never execute, so it just adds noise and a false sense of defensiveness. If the value can genuinely differ at runtime (an untyped API response, a `JSON.parse` result), the fix is to make the type honest (`string | undefined`, `unknown`), not to bolt a check onto an already-correct type.

```typescript
// ❌ Bad: label is already typed as string - this branch can never run
interface CardProps {
  label: string;
}
function Card({ label }: CardProps) {
  if (typeof label !== "string") return null;
  return <span>{label}</span>;
}

// ❌ Bad: rows is already typed as Row[] - the Array.isArray check is dead code
function renderRows(rows: Row[]) {
  if (!Array.isArray(rows)) return [];
  return rows.map(renderRow);
}

// ✅ Good: trust the type, use the value directly
function Card({ label }: CardProps) {
  return <span>{label}</span>;
}

// ✅ Good: if the value can genuinely be untyped at runtime, say so in the type
function renderRows(rows: unknown) {
  if (!Array.isArray(rows)) return [];
  return rows.map(renderRow);
}
```

---

## Naming & Structure

### NAME-1: No Spelling Mistakes in Names or Comments

Variable names, function names, and comments must be spelled correctly.

**Why:** Spelling mistakes cause confusion, make code harder to search, and look unprofessional. Typos in variable names can also cause bugs when someone searches for the correct spelling.

**Scope:** NAME-1 is strictly about misspelled words. A name that is spelled correctly but misleading - it doesn't match what the value actually does - is not a NAME-1 issue; flag that under NAME-13 (Names Must Match Behavior).

```typescript
// ❌ Bad: Spelling mistakes
const recieve = fetchData(); // "recieve" should be "receive"
const occured = true; // "occured" should be "occurred"
const seperate = items.split(","); // "seperate" should be "separate"
// This functon handles the responce
function procesData() {} // "functon", "responce", "proces"

// ✅ Good: Correct spelling
const receive = fetchData();
const occurred = true;
const separate = items.split(",");
// This function handles the response
function processData() {}
```

---

### NAME-2: Keep Abbreviations Capitalized in camelCase (When Not First)

When using abbreviations in camelCase identifiers, keep the abbreviation fully capitalized ONLY when it's not the first word. If the abbreviation starts the identifier, use standard camelCase (lowercase first letter) to distinguish variables from classes.

**Exception:** `id` can remain lowercase (`userId`) as it reads more naturally.

**Why:** Abbreviations in the middle or end should stay capitalized to be recognizable. But starting with all caps (`XMLParser`) looks like a class name, not a variable. Keeping `xmlParser` makes it clearly a variable.

```typescript
// ❌ Bad: Abbreviations lowercased when NOT first
const isIoc = true; // should be isIOC
const getUserApi = () => {}; // should be getUserAPI
const parseHtml = (str: string) => {}; // should be parseHTML
const fetchJsonData = async () => {}; // should be fetchJSONData

// ❌ Bad: Abbreviations capitalized when FIRST (looks like a class)
const XMLParser = new Parser(); // should be xmlParser
const HTTPRequest = new Request(); // should be httpRequest
const SQLQuery = "SELECT *"; // should be sqlQuery
const JSONData = {}; // should be jsonData

// ✅ Good: Abbreviations capitalized only when NOT first
const isIOC = true;
const getUserAPI = () => {};
const parseHTML = (str: string) => {};
const fetchJSONData = async () => {};
const xmlParser = new Parser(); // lowercase because XML is first
const httpRequest = new Request(); // lowercase because HTTP is first
const sqlQuery = "SELECT *"; // lowercase because SQL is first
const jsonData = {}; // lowercase because JSON is first

// ✅ Good: "id" exception - lowercase looks better
const userId = "123"; // not userID
const visitorId = "abc"; // not visitorID
const getOrderById = (id: string) => {}; // not getOrderByID

// Common abbreviations to watch for:
// API, IOC, URL, URI, HTML, CSS, JSON, XML, HTTP, HTTPS, SQL, UUID, AWS, GCP, SDK, CLI, GUI, DOM, REST, CRUD
```

---

### NAME-3: No Meaningless Names

Never use placeholder names like `foo`, `bar`, `baz`, `temp`, `tmp`, or similar meaningless identifiers.

**Why:** Meaningless names provide zero context about what the variable represents. They make code impossible to understand without reading surrounding context.

```typescript
// ❌ Bad: Meaningless names
const foo = getUsers();
const bar = foo.filter((x) => x.active);
const temp = calculateTotal(bar);
const tmp = formatCurrency(temp);

// ✅ Good: Descriptive names
const users = getUsers();
const activeUsers = users.filter((user) => user.active);
const totalRevenue = calculateTotal(activeUsers);
const formattedRevenue = formatCurrency(totalRevenue);
```

---

### NAME-4: No Abstract Names Like "data" or "object"

Avoid vague names like `data`, `object`, `thing`, `item`, `info`, `stuff`, `value`, `result` when a more specific name exists.

**Why:** These names are too abstract to convey meaning. Everything in code is data or an object - the name should tell you WHAT kind.

```typescript
// ❌ Bad: Abstract names
const data = fetchCustomers();
const object = { name: "John", age: 30 };
const info = getUserDetails();
const result = calculateMetrics();
const value = input.trim();
const item = cart.items[0];

// ✅ Good: Specific names
const customers = fetchCustomers();
const userProfile = { name: "John", age: 30 };
const userDetails = getUserDetails();
const salesMetrics = calculateMetrics();
const trimmedInput = input.trim();
const firstCartItem = cart.items[0];
```

---

### NAME-5: No Numeric Suffixes

Never use numeric suffixes like `user2`, `data_2`, `employee2` to differentiate variables.

**Why:** Numbers don't explain the difference between variables. The reader knows there are two but not WHY or HOW they differ.

```typescript
// ❌ Bad: Numeric suffixes
const user1 = getManager();
const user2 = getEmployee();
const date1 = order.createdAt;
const date2 = order.updatedAt;
const config1 = loadDevConfig();
const config2 = loadProdConfig();

// ✅ Good: Descriptive differentiation
const manager = getManager();
const employee = getEmployee();
const createdDate = order.createdAt;
const updatedDate = order.updatedAt;
const devConfig = loadDevConfig();
const prodConfig = loadProdConfig();
```

---

### NAME-6: No Ambiguous Abbreviations

Avoid abbreviations that could mean multiple things: `acc`, `pos`, `char`, `mod`, `auth`, `proc`, `temp`, `val`, `res`, `req`, `btn`, `msg`, `str`, `num`, `arr`, `obj`, `fn`, `cb`.

**Why:** `auth` could be authentication or authorization. `pos` could be position or point-of-sale. `char` could be character or characteristic. Write out the full word.

```typescript
// ❌ Bad: Ambiguous abbreviations
const auth = checkAuth(); // authentication? authorization?
const pos = getPos(); // position? point of sale?
const char = str.charAt(0); // character? characteristic?
const mod = getMod(); // module? modifier? modulus?
const val = input.val; // value? validation?
const res = await fetch(); // response? result? resource?
const btn = document.querySelector("button");
const cb = (err, data) => {}; // callback
const fn = () => {}; // function
const arr = [1, 2, 3];
const obj = { key: "value" };

// ✅ Good: Full words
const isAuthenticated = checkAuthentication();
const cursorPosition = getCursorPosition();
const firstCharacter = str.charAt(0);
const moduleName = getModuleName();
const inputValue = input.val;
const response = await fetch();
const submitButton = document.querySelector("button");
const onComplete = (error, data) => {};
const handleClick = () => {};
const numbers = [1, 2, 3];
const config = { key: "value" };
```

---

### NAME-7: No Single-Letter Variable Names

Avoid single-letter names like `a`, `b`, `x`, `y`, `i`, `j`, `k`, `n`, `e`, `t`, `s` even in loops or short functions.

**Why:** Single letters are the most ambiguous possible names. They force readers to trace back through code to understand what they represent.

```typescript
// ❌ Bad: Single-letter names
for (let i = 0; i < users.length; i++) {
  const u = users[i];
  if (u.a > 18) {
    console.log(u.n);
  }
}

const r = items.reduce((a, b) => a + b.price, 0);

array.map((x) => x * 2);

try {
  doSomething();
} catch (e) {
  console.error(e);
}

// ✅ Good: Descriptive names
for (let userIndex = 0; userIndex < users.length; userIndex++) {
  const user = users[userIndex];
  if (user.age > 18) {
    console.log(user.name);
  }
}

// Even better: use forEach or for-of
for (const user of users) {
  if (user.age > 18) {
    console.log(user.name);
  }
}

const totalPrice = items.reduce((sum, item) => sum + item.price, 0);

numbers.map((number) => number * 2);

try {
  doSomething();
} catch (error) {
  console.error(error);
}
```

---

### NAME-8: Avoid Vague Words Like "Manager" and Overused "get"

Avoid vague nouns like `Manager`, `Handler`, `Processor`, `Helper`, `Util`, `Service` (without context). Also avoid overusing `get` prefix when more specific verbs exist.

**Why:** "Manager" is vague - what does it manage? Use specific verbs: `calculate`, `fetch`, `build`, `create`, `parse`, `validate`, `format`, `find`, `filter`, `load`, `save`.

```typescript
// ❌ Bad: Vague words
class DataManager {}
class UserHandler {}
class OrderProcessor {}
function getScore() {} // calculated? fetched? estimated?
function getData() {} // from where? what kind?
function getUsers() {} // from API? database? cache?

// ✅ Good: Specific words
class UserRepository {} // stores/retrieves users
class OrderValidator {} // validates orders
class InvoiceGenerator {} // generates invoices
function calculateScore() {}
function estimateScore() {}
function fetchUsersFromAPI() {}
function loadUsersFromCache() {}
function queryUsersFromDatabase() {}
```

---

### NAME-9: Generic Naming for Multi-Entity Functions

When a single function handles multiple entity types (rules, IOCs, users, etc.), use generic variable names (`itemId`, `itemName`) instead of type-specific names (`ruleId`, `iocId`). Alternatively, create separate functions per entity type.

**Why:** Type-specific names in shared code become inconsistent when a third type is added. If you have `ruleId` and `iocId`, what do you name the third? Generic names scale cleanly, or separate functions avoid the problem entirely.

**This rule applies to:**

- Interface/type field names
- Variable names in shared functions
- Function/setter names exposed from hooks or utilities

```typescript
// ❌ Bad: Type-specific setters exposed from shared hook
const { setSelectedRules, setSelectedIOCs } = useBulkDeploy();
if (itemType === "iocs") {
  setSelectedIOCs(items);
} else {
  setSelectedRules(items);
}

// ✅ Good: Generic setter that encapsulates type dispatch
const { setSelectedItems } = useBulkDeploy();
setSelectedItems(items); // Hook handles type internally
```

```typescript
// ❌ Bad: Type-specific names in shared function
function processDeployment(payload: BulkDeployPayload) {
  const {
    jobId,
    type,
    ruleId,      // Only relevant when type === "rules"
    ruleName,    // Only relevant when type === "rules"
    iocId,       // Only relevant when type === "iocs"
    iocName,     // Only relevant when type === "iocs"
    // What happens when we add type === "alerts"? alertId? alertName?
  } = payload;

  // Now you have 6+ variables, most undefined depending on type
}

// ✅ Good Option 1: Generic names in shared function
function processDeployment(payload: BulkDeployPayload) {
  const {
    jobId,
    type,
    itemId,      // Works for any type
    itemName,    // Works for any type
  } = payload;

  // Clean, extensible - adding new types requires no variable changes
}

// ✅ Good Option 2: Separate functions per entity type
function processRuleDeployment(payload: RuleDeployPayload) {
  const { jobId, ruleId, ruleName } = payload;
  // Rule-specific logic
}

function processIOCDeployment(payload: IOCDeployPayload) {
  const { jobId, iocId, iocName } = payload;
  // IOC-specific logic
}

// Dispatcher
function processDeployment(payload: BulkDeployPayload) {
  if (payload.type === "rules") return processRuleDeployment(payload);
  if (payload.type === "iocs") return processIOCDeployment(payload);
  throw new Error(`Unknown type: ${payload.type}`);
}
```

---

### NAME-10: No Vestigial Hungarian Notation

Remove type prefixes like `is`, `has`, `str`, `num`, `arr`, `obj`, `date` when the type system already provides this information.

**Why:** In typed languages, the type is already known. `isActive: boolean` is redundant - just use `active: boolean`. Exception: `is`/`has` prefixes ARE appropriate for boolean function names that read as questions.

```typescript
// ❌ Bad: Redundant type prefixes on variables
const isVictory: boolean = true; // just "victory"
const dateCreated: Date = new Date(); // just "created" or "createdAt"
const strName: string = "John"; // just "name"
const numCount: number = 5; // just "count"
const arrItems: string[] = []; // just "items"

// ✅ Good: Let the type system do its job
const victory: boolean = true;
const createdAt: Date = new Date();
const name: string = "John";
const count: number = 5;
const items: string[] = [];

// ✅ OK: is/has prefix for boolean functions (reads as a question)
function isActive(user: User): boolean {}
function hasPermission(user: User, action: string): boolean {}
function canEdit(document: Document): boolean {}
```

---

### NAME-11: Use Domain Words Instead of Concatenation

When a single domain word exists, use it instead of concatenating multiple words.

**Why:** English has rich vocabulary. `appointmentList` should be `calendar`, `companyPerson` should be `employee`, `textCorrectionByEditor` should be `edit`.

```typescript
// ❌ Bad: Word concatenation when a domain word exists
const appointmentList = getAppointments(); // use "calendar" or "schedule"
const companyPerson = getWorker(); // use "employee"
const carList = getCars(); // use "fleet" or just "cars"
const bookCollection = getBooks(); // use "library" or just "books"
const moneyAmount = getTotal(); // use "total", "balance", "sum"
const timeSpan = getDuration(); // use "duration"
const wordList = getWords(); // use "vocabulary", "glossary", or just "words"

// ✅ Good: Domain-appropriate words
const calendar = getAppointments();
const employee = getWorker();
const fleet = getCars();
const library = getBooks();
const balance = getTotal();
const duration = getDuration();
const glossary = getWords();
```

---

### NAME-12: Consistent Domain Language

Use the same terminology throughout the codebase. If you use `getCustomers`, don't introduce `fetchClients` for the same concept.

**Why:** Inconsistent terminology creates confusion about whether `customers` and `clients` are the same or different things.

```typescript
// ❌ Bad: Inconsistent terminology for the same concept
function getCustomers() {}
function fetchClients() {} // Are clients different from customers?
function retrieveUsers() {} // Are users different?
function loadPatrons() {} // What's a patron?

function createOrder() {}
function makePurchase() {} // Is this different from an order?
function newTransaction() {} // Another term?

// ✅ Good: Consistent terminology
function getCustomers() {}
function getCustomerByID(id: string) {}
function searchCustomers(query: string) {}
function createCustomer(data: CustomerData) {}

function createOrder() {}
function getOrderByID(id: string) {}
function cancelOrder(id: string) {}
```

---

### NAME-13: Names Must Match Behavior

A parameter, prop, or variable name must describe what it actually controls or represents. Flag names that lie about their behavior. This is distinct from NAME-3/NAME-4 (generic/meaningless names) - here the name is specific, it's just wrong.

**Why:** A name that contradicts behavior is worse than a vague one. Readers trust the name, skip reading the implementation, and build on a false assumption. The bug hides until someone finally traces the code.

```typescript
// ❌ Bad: Name says one thing, code does another
// "disabled" actually enables the button
function SaveButton({ disabled }: { disabled: boolean }) {
  return <button disabled={!disabled}>Save</button>;
}

// "sortAscending" is passed straight into a descending sort
function sortRows(rows: Row[], sortAscending: boolean) {
  return rows.sort((first, second) => second.value - first.value);
}

// "maxRetries" is used as a delay in milliseconds
function scheduleJob(maxRetries: number) {
  setTimeout(runJob, maxRetries);
}

// ✅ Good: Name matches what it controls
function SaveButton({ disabled }: { disabled: boolean }) {
  return <button disabled={disabled}>Save</button>;
}

function sortRows(rows: Row[], sortAscending: boolean) {
  return rows.sort((first, second) =>
    sortAscending ? first.value - second.value : second.value - first.value
  );
}

function scheduleJob(delayMs: number) {
  setTimeout(runJob, delayMs);
}
```

---

## Comments

### COMMENT-1: Comment the "Why", Not the "What"

Don't write comments that explain what code does - that's visible from reading the code. Only comment to explain WHY something is done a certain way, especially for anti-patterns or non-obvious decisions.

**Why:** Comments explaining "what" become outdated and redundant. Comments explaining "why" preserve crucial context that isn't visible in the code itself.

**TypeScript types are self-documenting:** Don't add JSDoc comments that just describe the available options when the type definition already shows them. The type IS the documentation.

```typescript
// ❌ Bad: Comments explaining what the code does
// Loop through users
for (const user of users) {
  // Check if user is active
  if (user.active) {
    // Add user to active users array
    activeUsers.push(user);
  }
}

// Increment counter
counter++;

// Return the result
return result;

// ✅ Good: Comments explaining why
// Filter out inactive users before billing to avoid charging
// accounts that have been suspended - required by legal team
for (const user of users) {
  if (user.active) {
    activeUsers.push(user);
  }
}

// Counter must be incremented BEFORE the API call because
// the payment provider uses it as an idempotency key
counter++;

return result;

// ❌ Bad: JSDoc that just repeats what the type already shows
/**
 * Tooltip configuration using standard tooltip props.
 * - 'content': ReactNode - tooltip content (required)
 * - 'placement': 'top-start' | 'top-center' | 'bottom-end' etc. (default: 'top-center')
 * - 'variant': 'singleline' | 'multiline' (default: 'singleline')
 * - 'maxHeight': number | string - enables scrollable content when provided
 * - 'maxWidth': number | string (default: 236)
 * - 'disabled': boolean - disable tooltip
 */
tooltip?: StandardTooltipProps;

// The type StandardTooltipProps already defines all of this!
// Adding this comment on every file is useless - the Type already specifies
// what options are available.

// ✅ Good: Let the type be the documentation
tooltip?: StandardTooltipProps;

// ✅ OK: Comment only if there's a non-obvious "why"
// Tooltip disabled during drag operations to prevent z-index conflicts
tooltip?: StandardTooltipProps;
```

---

### COMMENT-2: Always Comment Anti-Patterns and Workarounds

When you intentionally use an anti-pattern, workaround, or unexpected approach, ALWAYS add a comment explaining why this was necessary.

**Why:** Without explanation, the next developer (or you in 6 months) will assume it's a mistake and "fix" it, potentially reintroducing the bug you worked around.

```typescript
// ❌ Bad: Anti-pattern without explanation
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const data = response as any;

setTimeout(() => {
  inputRef.current?.focus();
}, 0);

const users = JSON.parse(JSON.stringify(originalUsers));

// ✅ Good: Anti-pattern with explanation
// Using 'any' here because the third-party API returns inconsistent
// types depending on the endpoint version. Tracked in JIRA-1234.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const data = response as any;

// setTimeout(0) is needed because React's state update hasn't
// flushed to the DOM yet. The input doesn't exist until next tick.
// TODO: Refactor to useEffect when we upgrade to React 18
setTimeout(() => {
  inputRef.current?.focus();
}, 0);

// Deep clone required because Redux state is frozen in dev mode,
// and we need to mutate this for the legacy export function.
// See: https://github.com/our-repo/issues/456
const users = JSON.parse(JSON.stringify(originalUsers));
```

---

### COMMENT-3: No Stale TODOs

Flag TODO/FIXME comments that reference work that has already been completed, or a decision that has already been made. Delete them.

**Why:** A stale TODO lies about the state of the code. It makes readers think work is still outstanding, adds noise when grepping for real action items, and erodes trust in every other TODO in the codebase.

```typescript
// ❌ Bad: TODO for a migration that already shipped
// TODO: remove once the v2 API migration is done
const users = normalizeV1Response(raw);

// ❌ Bad: FIXME for a decision that's already been made
// FIXME: decide whether to use debounce or throttle here
const onSearch = useDebouncedCallback(runSearch, 300);

// ❌ Bad: TODO pointing at a closed ticket
// TODO(JIRA-1201): add pagination
const { rows } = usePaginatedRows({ pageSize: 25 });

// ✅ Good: Once the referenced work is done, the comment is gone
const users = normalizeResponse(raw);

const onSearch = useDebouncedCallback(runSearch, 300);

const { rows } = usePaginatedRows({ pageSize: 25 });
```

---

## Code Style

### STYLE-1: No Implicit Type Coercion

Use explicit type conversion functions instead of implicit coercion tricks.

**Why:** Implicit coercion is clever but hard to read. `!!foo` to convert to boolean, `+foo` to convert to number, and `'' + foo` to convert to string are not immediately obvious to all developers.

```typescript
// ❌ Bad: Implicit coercion tricks
const bool = !!value;
const bool2 = ~str.indexOf(".");
const num = +stringValue;
const num2 = 1 * stringValue;
const str = "" + numberValue;
const str2 = value + "";

// ✅ Good: Explicit conversion
const bool = Boolean(value);
const bool2 = str.indexOf(".") !== -1;
const num = Number(stringValue);
const num2 = parseInt(stringValue, 10); // or parseFloat()
const str = String(numberValue);
const str2 = numberValue.toString();
```

---

### STYLE-2: No Unused Code Added for Future Features

Never add variables, functions, types, interfaces, exports, or any other code that isn't immediately used. If something will be needed for a future feature, add it when that feature is implemented. Before adding any code, ask: "Is this being used anywhere right now?"

**Why:** Unused code creates confusion, increases maintenance burden, and often becomes stale or incorrect by the time it's actually needed. The future requirement may change, making the pre-written code wrong or unnecessary. Write code for what you need NOW, not what you MIGHT need later.

```typescript
// ❌ Bad: Adding unused code for "future" features
interface UserSettings {
  theme: "light" | "dark";
  language: string;
  // Added for future notification feature
  notificationPreferences?: NotificationPreferences;  // NOT USED YET
  // Added for future analytics feature
  analyticsConsent?: boolean;  // NOT USED YET
}

// Unused type waiting for future feature
type NotificationPreferences = {
  email: boolean;
  push: boolean;
  sms: boolean;
};

// Unused function "for later"
function formatNotificationMessage(message: string): string {
  // Will be used when we implement notifications
  return message.trim();
}

// Unused constant "we might need this"
const MAX_NOTIFICATION_RETRIES = 3;

// ✅ Good: Only code that is actually used
interface UserSettings {
  theme: "light" | "dark";
  language: string;
  // Only fields that are currently used
}

// When notification feature is implemented, THEN add:
// - NotificationPreferences type
// - notificationPreferences field
// - formatNotificationMessage function
// - MAX_NOTIFICATION_RETRIES constant
```

```typescript
// ❌ Bad: Unused function parameters "for future flexibility"
function processOrder(
  order: Order,
  options?: ProcessOptions,  // NOT USED - "might need options later"
  callback?: () => void      // NOT USED - "might need callback later"
) {
  // Only uses order, ignores options and callback
  return saveOrder(order);
}

// ❌ Bad: Unused exports "someone might need these"
export {
  processOrder,
  validateOrder,      // NOT USED anywhere
  formatOrderId,      // NOT USED anywhere
  ORDER_STATUS_MAP,   // NOT USED anywhere
};

// ✅ Good: Only export what's actually imported elsewhere
export { processOrder };

// ✅ Good: Only parameters that are used
function processOrder(order: Order) {
  return saveOrder(order);
}
```

---

### STYLE-3: Delete Unnecessary Type Aliases

Delete type aliases that simply re-export another type without adding value. If `type A = B` doesn't add constraints, narrowing, or documentation, just use `B` directly.

**Why:** Unnecessary type aliases add indirection without benefit. They create extra symbols to maintain, can cause confusion about which type to use, and clutter the codebase.

```typescript
// ❌ Bad: Type alias that adds nothing
export type BadgeTooltipProps = StandardTooltipProps;
export type ButtonTooltipProps = StandardTooltipProps;
export type CardTooltipProps = StandardTooltipProps;

// Now you have 4 types that all mean the same thing
const props: BadgeTooltipProps = { content: "hi" };
const props2: StandardTooltipProps = { content: "hi" }; // Same thing!

// ✅ Good: Just use the original type directly
import { StandardTooltipProps } from './tooltip';

// In Badge component:
interface BadgeProps {
  tooltip?: StandardTooltipProps;  // Use directly, no alias needed
}

// In Button component:
interface ButtonProps {
  tooltip?: StandardTooltipProps;  // Same type, no alias
}

// ✅ OK: Type alias that adds value (narrowing, extending, or documenting)
// Narrowing - restricts the original type
export type BadgePlacement = Extract<TooltipPlacement, 'top' | 'bottom'>;

// Extending - adds new properties
export type BadgeTooltipProps = StandardTooltipProps & {
  showOnBadgeHover?: boolean;
};

// Documenting domain concept - gives semantic meaning
export type UserId = string;  // OK if this represents a domain concept
```

---

### STYLE-4: Prefer Spread Operator for Prop Forwarding

When passing an object's properties through to another component or function, use the spread operator instead of manually listing each property.

**Why:** Spread operators are concise, automatically forward all properties, and don't require updates when the source object gains new properties. Manual listing is verbose, error-prone, and requires maintenance.

```typescript
// ❌ Bad: Manually listing properties
<Tooltip
  content={action.tooltip.content}
  placement={action.tooltip.placement}
  variant={action.tooltip.variant}
  maxWidth={action.tooltip.maxWidth}
/>

// What if tooltip gains a new property? You have to add it here too.

// ❌ Bad: Creating intermediate object with same properties
const tooltipProps = {
  content: tooltip.content,
  placement: tooltip.placement,
  variant: tooltip.variant,
};
<Tooltip {...tooltipProps} />

// ✅ Good: Spread operator
<Tooltip {...action.tooltip} />

// ✅ Good: Spread with overrides (override comes after spread)
<Tooltip {...action.tooltip} placement="top" />

// ✅ Good: Conditional spread
<Tooltip {...(showExtra && extraProps)} content={content} />
```

---

### STYLE-5: Optional Booleans Need a Default

Every optional boolean prop or parameter (`boolean?`) must have a default value. Flag any that don't.

**Why:** An optional boolean has three states - `true`, `false`, and `undefined` - but the code almost always wants two. Without a default, every consumer has to reason about the `undefined` case, and `if (flag)` and `if (flag === false)` quietly disagree about it. A default collapses the tri-state back into a clear boolean.

```typescript
// ❌ Bad: Optional boolean with no default - three states to reason about
interface ButtonProps {
  children: ReactNode;
  loading?: boolean;
}

function Button({ children, loading }: ButtonProps) {
  // loading is boolean | undefined - what does "not passed" mean here?
  return <button aria-busy={loading}>{children}</button>;
}

// ❌ Bad: Optional boolean parameter with no default
function fetchUsers(includeInactive?: boolean) {
  // includeInactive is undefined unless the caller passes it
  return query({ inactive: includeInactive });
}

// ✅ Good: Default value collapses the tri-state
interface ButtonProps {
  children: ReactNode;
  loading?: boolean;
}

function Button({ children, loading = false }: ButtonProps) {
  return <button aria-busy={loading}>{children}</button>;
}

// ✅ Good: Default parameter value
function fetchUsers(includeInactive = false) {
  return query({ inactive: includeInactive });
}
```

---

### STYLE-6: Justify New Conditions, Wrappers, and Abstractions

Before adding a new conditional branch, custom hook, wrapper prop, or middleware, confirm there's a concrete, current need that an existing primitive doesn't already solve.

**Why:** Every added branch, wrapper, or layer of indirection is a permanent cost - the next reader has to understand it, and the next change has to route around it. "It might be useful" or "it's more flexible" isn't a reason if nothing today exercises the flexibility; call the existing primitive directly, and add the wrapper when a second real use case actually needs it.

**Scope:** STYLE-6 is about resisting abstraction nobody needs yet. If the same logic has already been copy-pasted to a second call site, that's the opposite problem - see STYLE-7 (Extract Logic Duplicated Across Call Sites).

```typescript
// ❌ Bad: custom wrapper hook around a framework primitive, no added behavior
function useCanAccess(resource: string, action: string) {
  const { can } = useContext(AccessContext);
  return can(resource, action);
}
// ...
if (useCanAccess("rules", "delete")) {
  /* ... */
}

// ❌ Bad: a defensive condition for a case the type already rules out
function formatCount(count: number) {
  if (count === undefined) return "0"; // count is typed as number, never undefined
  return count.toString();
}

// ✅ Good: call the existing primitive directly until a real second use case appears
if (canAccess("rules", "delete")) {
  /* ... */
}

// ✅ Good: no defensive branch for a case the type already rules out
function formatCount(count: number) {
  return count.toString();
}
```

---

### STYLE-7: Extract Logic Duplicated Across Call Sites

When the same non-trivial logic - a conditional, a type-cast plus its narrowing check, a class-name string, a `data-testid` computation, a recursive traversal - appears verbatim in two or more places, extract it into a shared function, hook, or constant instead of leaving the copies to drift.

**Why:** Copy-pasted logic doubles (or triples) the surface area a bug fix has to cover, and duplicated `as X` casts or narrowing checks are exactly the kind of code a later refactor updates in one place and forgets in the other. This is the mirror image of STYLE-6 (over-engineering a wrapper nobody needs yet): STYLE-6 stops you from abstracting speculatively, STYLE-7 catches logic that's already been copy-pasted and needs consolidating now that a second instance proves the need.

```typescript
// ❌ Bad: the same cast + narrowing check copy-pasted at two call sites
function renderIOCRow(item: TreeItem) {
  const children = (item as IOCGroup).children as IOCItem[];
  return children.map(renderIOCItem);
}

function renderRuleRow(item: TreeItem) {
  const children = (item as RuleGroup).children as RuleItem[];
  return children.map(renderRuleItem);
}

// ❌ Bad: the same org-filter predicate duplicated across sibling views
// TemplateView.tsx
const filtered = rows.filter((row) => row.organizationId === activeOrgId);
// SummaryCard.tsx - identical predicate, copy-pasted
const visible = cards.filter((card) => card.organizationId === activeOrgId);

// ✅ Good: extract once, reuse everywhere
function getTreeItemChildren<T>(item: TreeItem): T[] {
  return (item as { children: T[] }).children;
}

function filterByOrganization<T extends { organizationId: string }>(
  rows: T[],
  organizationId: string
) {
  return rows.filter((row) => row.organizationId === organizationId);
}
```

---

### STYLE-8: Prefer an Existing Utility or Component Over Hand-Rolled Logic

Before writing a manual loop, string manipulation, debounce, or UI primitive, check whether a language built-in, an already-used library, or an existing shared component/hook already does it.

**Why:** Hand-rolled reimplementations of things that already exist cost more to write, are more likely to have edge-case bugs the existing solution already fixed, and add a second thing to maintain when the library or shared component gets updated. If the codebase already depends on lodash, has a shared `DateCell`, or uses a data-fetching library with a built-in feature (autoReset, cursor-based pagination), reuse it instead of rebuilding it.

```typescript
// ❌ Bad: manual loop to strip a prefix instead of using a string built-in
function stripPrefix(value: string, prefix: string) {
  return value.indexOf(prefix) === 0 ? value.slice(prefix.length) : value;
}

// ❌ Bad: hand-rolled debounce when lodash is already a dependency
function useDebouncedSearch(callback: (query: string) => void) {
  const timeoutRef = useRef<ReturnType<typeof setTimeout>>();
  return (query: string) => {
    clearTimeout(timeoutRef.current);
    timeoutRef.current = setTimeout(() => callback(query), 300);
  };
}

// ❌ Bad: a new table cell for a value the shared library already formats
function DateDisplayCell({ value }: { value: string }) {
  return <span>{new Date(value).toLocaleDateString()}</span>;
}

// ✅ Good: use the built-in / library / shared component
const stripped = value.replace(new RegExp(`^${prefix}`), "");

import { debounce } from "lodash";
const debouncedSearch = debounce(callback, 300);

import { DateCell } from "@/components/table/DateCell";
<DateCell value={row.createdAt} />;
```

**Before writing new logic, ask:** does a built-in method, a library we already depend on, or a shared component/hook in this codebase already do this?

---

## React Components

### REACT-1: Use Composition Over Props for Behavior Changes

When adding new behavior to a component (not visual changes), use composition instead of adding new props. Create a wrapper component or compose inline based on usage frequency.

**Why:** Adding behavior props (like `link`, `onClick`, `disabled`) bloats components over time. Each prop adds complexity and conditional logic. Composition keeps components simple and focused.

**Decision guide:**

- Used in **many places** → Create a composed component (`ButtonWithExternalLink`)
- Used **once** → Just wrap inline, don't modify the original component

```tsx
// ❌ Bad: Adding behavior prop to component
const Button = ({ link, children, ...props }) => {
  if (!link) return <button {...props}>{children}</button>;

  return (
    <a href={link} target="_blank" rel="noopener noreferrer">
      <button {...props}>{children}</button>
    </a>
  );
};

// ✅ Good: Composition - create new component (if used in many places)
const Button = ({ children, ...props }) => {
  return <button {...props}>{children}</button>;
};

const ButtonWithExternalLink = ({ link, children, ...props }) => {
  return (
    <a href={link} target="_blank" rel="noopener noreferrer">
      <Button {...props}>{children}</Button>
    </a>
  );
};

// ✅ Good: Inline composition (if used once)
const SomeComponent = () => {
  const link = "https://google.com";
  return (
    <a href={link} target="_blank" rel="noopener noreferrer">
      <Button>Go to google.com</Button>
    </a>
  );
};
```

---

### REACT-2: Use Enum Props Over Boolean Props for Visual Variants

When adding visual variants to a component, use enum-style props (`size: 'small' | 'medium'`) instead of boolean props (`smallSize: boolean`). Always provide default values for backwards compatibility.

**Why:** Boolean props assume only 2 states and require refactoring when a third variant is needed. Enum props are extensible - adding `'large'` requires no changes to existing usage.

**Decision guide:**

- Used in **many places** → Add an enum prop with default value
- Used **once** → Don't modify component, override className inline

```tsx
// ❌ Bad: Boolean prop for visual variant
type ButtonProps = { smallSize?: boolean; children: ReactNode };

const Button = ({ smallSize, children, ...props }: ButtonProps) => {
  const classNames = {
    medium: "text-blue-500 hover:text-blue-600",
    small: "text-blue-500 hover:text-blue-600 text-xs",
  };

  // What happens when we need 'large'? This breaks.
  return (
    <button
      className={smallSize ? classNames.small : classNames.medium}
      {...props}
    >
      {children}
    </button>
  );
};

// ✅ Good: Enum prop with default value (if used in many places)
type ButtonSize = "small" | "medium"; // easily add 'large' later
type ButtonProps = { size?: ButtonSize; children: ReactNode };

const Button = ({ size = "medium", children, ...props }: ButtonProps) => {
  const classNames: Record<ButtonSize, string> = {
    medium: "text-blue-500 hover:text-blue-600",
    small: "text-blue-500 hover:text-blue-600 text-xs",
    // Adding 'large' here requires no other code changes
  };

  return (
    <button className={classNames[size]} {...props}>
      {children}
    </button>
  );
};

// ✅ Good: Override className inline (if used once)
const SomeComponent = () => {
  return (
    <Button className="text-blue-500 hover:text-blue-600 text-xs">
      Submit
    </Button>
  );
};
```

---

### REACT-3: Be Intentional About Component Props

Think hard before adding any prop to a component. Each prop should provide meaningful functionality that will be used across many places.

**Why:** Components with too many one-off props become hard to use and maintain. But core/base components CAN have more props if each prop represents genuinely reusable functionality.

**Scope:** REACT-3 is about whether a prop should exist at all - prop necessity and design. It is NOT about a component's runtime behavior. Controlled-vs-uncontrolled input correctness (a `value` prop with no `onChange`, mixing `defaultValue` with `value`) is a correctness bug, not a prop-design issue - flag it under Logic & Correctness (LOGIC), not REACT-3.

**Before adding a prop, ask:**

1. Is this functionality going to be used in many places? (Not a one-off)
2. Is this a meaningful, reusable feature for this component?
3. If it's one-off, can I compose or override className instead?

**Key distinction:**

- ✅ OK: Core `Button` with `size`, `variant`, `disabled`, `loading` - these are meaningful, reused everywhere
- ❌ Bad: Adding `link` prop to `Button` for one specific use case

```tsx
// ❌ Bad: Props for one-off use cases
type ButtonProps = {
  size?: "small" | "medium" | "large";
  variant?: "primary" | "secondary";
  // These are one-off behaviors, not core button functionality:
  link?: string; // Only needed in 1 place? Use composition
  target?: "_blank" | "_self"; // Only needed with link
  iconPosition?: "left" | "right"; // Only 1 icon button in the app?
  fullWidth?: boolean; // Only 1 full-width button? Use className
  children: ReactNode;
};

// ✅ Good: Core component with meaningful, reusable props
type ButtonProps = {
  size?: "small" | "medium" | "large"; // Used everywhere
  variant?: "primary" | "secondary" | "ghost"; // Used everywhere
  disabled?: boolean; // Standard button functionality
  loading?: boolean; // Used in many forms/actions
  children: ReactNode;
};

const Button = ({
  size = "medium",
  variant = "primary",
  disabled,
  loading,
  children,
  ...props
}: ButtonProps) => {
  // Core component with genuinely reusable props
};

// One-off behaviors use composition instead
const LinkButton = ({ href, children, ...props }) => (
  <a href={href} target="_blank" rel="noopener noreferrer">
    <Button {...props}>{children}</Button>
  </a>
);

// One-off styling uses className override
const SomeComponent = () => (
  <Button className="w-full">Full Width Here Only</Button>
);
```

---

### REACT-4: Default Props for Backwards Compatibility

When adding new props to existing components, always provide default values so existing usages don't break.

**Why:** Components may be used in dozens of places. Adding a required prop or changing behavior without defaults breaks all existing usages.

```tsx
// ❌ Bad: Adding required prop breaks existing usages
// Before
const Button = ({ children }) => <button>{children}</button>;

// After - BREAKS all existing <Button> usages
const Button = ({
  children,
  size,
}: {
  children: ReactNode;
  size: "small" | "medium";
}) => {
  // size is now required!
};

// ✅ Good: Default value maintains backwards compatibility
// Before
const Button = ({ children }) => <button>{children}</button>;

// After - existing usages still work
const Button = ({
  children,
  size = "medium",
}: {
  children: ReactNode;
  size?: "small" | "medium";
}) => {
  // size defaults to 'medium', no breaking changes
};
```

---

### REACT-5: Check Usage Frequency Before Modifying Components

Before modifying any shared component, determine if the change will be used once or many times. Don't assume future usage - decide based on current, concrete needs.

**Why:** Premature abstraction adds complexity. One-time changes don't justify modifying shared components.

**Decision matrix:**

| Usage          | Behavior Change                    | Visual Change              |
| -------------- | ---------------------------------- | -------------------------- |
| **Once**       | Wrap inline, don't touch component | Override className inline  |
| **Many times** | Create composed component          | Add enum prop with default |

```tsx
// Scenario: Need a button that opens external link in ONE place

// ❌ Bad: Modifying shared Button component for one-time use
const Button = ({ link, children, ...props }) => {
  if (link) {
    return (
      <a href={link}>
        <button {...props}>{children}</button>
      </a>
    );
  }
  return <button {...props}>{children}</button>;
};

// ✅ Good: Just use it inline for one-time use
const Header = () => {
  return (
    <a
      href="https://docs.example.com"
      target="_blank"
      rel="noopener noreferrer"
    >
      <Button>Documentation</Button>
    </a>
  );
};

// Later, if you need it in 3+ places, THEN create ButtonWithExternalLink
```

---

### REACT-6: Hooks Encapsulate Related Derived Logic

When a hook provides data that requires transformation, lookup, or derived values, the hook should compute and return those values. Don't create separate utility files that consumers must import alongside the hook.

**Why:** If you always need `getItemConfig(itemType)` whenever you use `useBulkDeploy()`, the hook should return `itemConfig` directly. Separate utility files create scattered logic, require multiple imports, and make code harder to maintain.

```tsx
// ❌ Bad: Hook returns raw data, utility in separate file
// hooks/useBulkDeploy.ts
export function useBulkDeploy() {
  const { itemType, settings } = useContext(BulkDeployContext);
  return { itemType, settings };
}

// types/bulk-deploy.ts
export function getItemTypeConfig(type: BulkDeployItemType) {
  if (type === "iocs") return { label: "IOC", fields: IOC_FIELDS };
  if (type === "rules") return { label: "Rule", fields: RULE_FIELDS };
}

// Component.tsx - consumer must import both
import { useBulkDeploy } from "../hooks/useBulkDeploy";
import { getItemTypeConfig } from "@/types/bulk-deploy";

function DeploySettings() {
  const { itemType, settings } = useBulkDeploy();
  const config = getItemTypeConfig(itemType); // Always needed with the hook
  // ...
}

// ✅ Good: Hook encapsulates the derived logic
// hooks/useBulkDeploy.ts
function getItemTypeConfig(type: BulkDeployItemType) {
  if (type === "iocs") return { label: "IOC", fields: IOC_FIELDS };
  if (type === "rules") return { label: "Rule", fields: RULE_FIELDS };
  throw new Error(`Unknown type: ${type}`);
}

export function useBulkDeploy() {
  const { itemType, settings } = useContext(BulkDeployContext);
  const config = getItemTypeConfig(itemType);

  return {
    itemType,
    settings,
    itemLabel: config.label,
    updatableFields: config.fields,
  };
}

// Component.tsx - single import, all derived values included
import { useBulkDeploy } from "../hooks/useBulkDeploy";

function DeploySettings() {
  const { itemType, settings, itemLabel, updatableFields } = useBulkDeploy();
  // Everything needed is returned from the hook
}
```

---

### REACT-7: Data Hooks Return Display-Ready Values in Nested Object

When a hook fetches data that will be displayed in UI, the hook should return pre-formatted display values in a nested `formatted` object alongside the raw data. Don't duplicate formatting functions across multiple components.

**Why:** If every component that uses `useBulkDeployJobs()` needs to call `getJobStatusDisplay(job.status)` or `getTypeLabel(job.type)`, that formatting logic should be centralized in the hook. Duplicating formatting functions across components violates DRY, creates inconsistency risk, and scatters display logic. Using a nested `formatted` object keeps the original data structure intact.

**This applies to:**
- Enum-to-label mappings (status → "In Progress", type → "Rules")
- Badge kind/color mappings
- Date formatting
- Any transformation from raw data to display string

```tsx
// ❌ Bad: Formatting functions duplicated in every component
// hooks/useBulkDeployJobs.ts
export function useBulkDeployJobs() {
  const { data } = useQuery(...);
  return { jobs: data?.jobs || [] };
}

// page.tsx - has its own formatting functions
function getTypeLabel(type: BulkDeployItemType): string {
  if (type === "rules") return "Rules";
  if (type === "iocs") return "IOCs";
  throw new Error(`Unknown type: ${type}`);
}

// JobDetailsDrawer.tsx - SAME functions duplicated again
function getTypeLabel(type: BulkDeployItemType): string { ... }

// ✅ Good: Hook returns display-ready values in nested formatted object
// types/bulk-deploy.ts
export interface BulkDeployJobFormatted {
  typeLabel: string;
  statusLabel: string;
  statusBadgeKind: "blue" | "green";
  progressText: string;
  createdAt: string;
}

export interface BulkDeployJobWithFormatted extends BulkDeployJob {
  formatted: BulkDeployJobFormatted;
}

// hooks/useBulkDeployJobs.ts - single function returns all formatted values
function getJobFormatted(job: BulkDeployJob): BulkDeployJobFormatted {
  let typeLabel: string;
  if (job.type === "rules") {
    typeLabel = "Rules";
  } else if (job.type === "iocs") {
    typeLabel = "IOCs";
  } else {
    throw new Error(`Unknown item type: ${job.type}`);
  }

  let statusLabel: string;
  let statusBadgeKind: "blue" | "green";
  if (job.status === "in_progress") {
    statusLabel = "In Progress";
    statusBadgeKind = "blue";
  } else if (job.status === "completed") {
    statusLabel = "Completed";
    statusBadgeKind = "green";
  } else {
    throw new Error(`Unknown job status: ${job.status}`);
  }

  // ... other formatted fields

  return {
    typeLabel,
    statusLabel,
    statusBadgeKind,
    progressText,
    createdAt: new Date(job.createdAt).toLocaleString(),
  };
}

function formatJob(job: BulkDeployJob): BulkDeployJobWithFormatted {
  return {
    ...job,
    formatted: getJobFormatted(job),
  };
}

export function useBulkDeployJobs() {
  const { data } = useQuery(...);
  const jobs = (data?.jobs || []).map(formatJob);
  return { jobs };
}

// Components just use the pre-formatted values - no local formatting needed
<BadgeCell value={job.formatted.statusLabel} kind={BADGE_KIND_MAP[job.formatted.statusBadgeKind]} />
<span>{job.formatted.progressText}</span>
<SimpleTextCell value={job.formatted.createdAt} />
```

---

## Project Structure

### STRUCT-1: Types Folder Contains Only Types

The `types/` folder should only contain type definitions: interfaces, types, type aliases, and enums. Functions, classes with methods, and runtime logic belong elsewhere (utils/, helpers/, services/, or feature folders).

**Why:** Type files are for compile-time constructs that disappear after transpilation. Mixing runtime code with types breaks the mental model, makes imports confusing, and violates separation of concerns.

```typescript
// ❌ Bad: Function inside types folder
// src/types/bulk-deploy.ts
export type BulkDeployItemType = "iocs" | "rules";

export interface ItemTypeConfig {
  label: string;
  fields: string[];
}

// This function does NOT belong here - it's runtime logic
export function getItemTypeConfig(type: BulkDeployItemType): ItemTypeConfig {
  if (type === "iocs") return { label: "IOC", fields: IOC_FIELDS };
  if (type === "rules") return { label: "Rule", fields: RULE_FIELDS };
  throw new Error(`Unknown type: ${type}`);
}

// ✅ Good: Types folder has only types
// src/types/bulk-deploy.ts
export type BulkDeployItemType = "iocs" | "rules";

export interface ItemTypeConfig {
  label: string;
  fields: string[];
}

export interface BulkDeployPayload {
  type: BulkDeployItemType;
  itemId: string;
  itemName: string;
}

// src/utils/bulk-deploy.ts (or in the hook itself per REACT-6)
import { BulkDeployItemType, ItemTypeConfig } from "@/types/bulk-deploy";

export function getItemTypeConfig(type: BulkDeployItemType): ItemTypeConfig {
  if (type === "iocs") return { label: "IOC", fields: IOC_FIELDS };
  if (type === "rules") return { label: "Rule", fields: RULE_FIELDS };
  throw new Error(`Unknown type: ${type}`);
}
```

---

### REACT-9: No Redundant Props

Don't add two props that accomplish the same thing or overlap significantly. If you find yourself asking "why two props?", consolidate into one.

**Why:** Redundant props create confusion about which to use, increase API surface area unnecessarily, and often indicate unclear component design.

```tsx
// ❌ Bad: Two props for similar purposes
interface TooltipProps {
  content?: ReactNode;
  tooltipContent?: ReactNode;  // Why two props? Which one takes precedence?
}

// ❌ Bad: Overlapping functionality
interface ButtonProps {
  isDisabled?: boolean;
  disabled?: boolean;  // Same thing, different name
}

// ❌ Bad: Split configuration that should be unified
interface BadgeProps {
  tooltipText?: string;
  tooltipConfig?: TooltipConfig;  // Why not just accept both in one prop?
}

// ✅ Good: Single prop with clear purpose
interface TooltipProps {
  content: ReactNode;
}

// ✅ Good: One prop, flexible type (see REACT-8)
interface BadgeProps {
  tooltip?: string | TooltipConfig;  // One prop handles both cases
}
```

---

### REACT-10: No Unnecessary Customization

Don't add props for customization that isn't needed. If you find yourself asking "why custom? what's the need for this?", remove it.

**Why:** Every prop is API surface that must be maintained. Props should solve real, demonstrated needs - not hypothetical future flexibility. When in doubt, leave it out.

```tsx
// ❌ Bad: Props for hypothetical customization
interface TooltipProps {
  content: ReactNode;
  customClassName?: string;      // Is anyone using this?
  customStyle?: CSSProperties;   // What's the need for this?
  customPortalTarget?: Element;  // Why would someone need this?
  renderCustomArrow?: () => ReactNode;  // Over-engineering
}

// ❌ Bad: Exposing internal implementation details
interface ModalProps {
  animationDuration?: number;
  backdropOpacity?: number;
  zIndexOverride?: number;
}

// ✅ Good: Only props with demonstrated need
interface TooltipProps {
  content: ReactNode;
  placement?: TooltipPlacement;
  // Add more props WHEN someone actually needs them
}

// ✅ Good: Sensible defaults, minimal API
interface ModalProps {
  open: boolean;
  onClose: () => void;
  children: ReactNode;
}
```

**Before adding any prop, ask:**
1. Is someone actively asking for this?
2. Do we have a concrete use case right now?
3. If the answer is "might be useful someday" - don't add it.

---

### REACT-11: Props Must Be Self-Explanatory

Prop names should be clear enough that you never have to ask "what does this prop do?" If someone asks that question, the naming is wrong.

**Why:** Props are the public API of your component. If the name doesn't communicate purpose clearly, consumers will misuse it or avoid it. Good names eliminate the need for documentation.

```tsx
// ❌ Bad: Unclear prop names that prompt "what does this do?"
interface BadgeProps {
  mode?: string;           // Mode of what?
  config?: object;         // Config for what?
  options?: Options;       // What options?
  data?: any;              // What data?
  flag?: boolean;          // Flag for what?
  type?: string;           // Type of what?
  custom?: boolean;        // Custom what?
  handler?: () => void;    // Handles what?
}

// ✅ Good: Self-explanatory prop names
interface BadgeProps {
  variant?: 'solid' | 'subtle';           // Visual variant
  tooltip?: string | TooltipConfig;       // Tooltip configuration
  iconPosition?: 'left' | 'right';        // Where the icon appears
  onDismiss?: () => void;                 // Called when dismissed
  isInteractive?: boolean;                // Whether it responds to clicks
}

// ✅ Good: Names that read naturally
<Badge
  variant="subtle"
  tooltip="Click to view details"
  iconPosition="right"
  onDismiss={handleDismiss}
/>
// vs
<Badge
  mode="2"
  config={{ x: true }}
  handler={fn}
/>
```

**Test:** Read the prop name out loud. If you need to check the implementation to understand it, rename it.

---

### REACT-8: Accept Flexible Input Types, Normalize Internally

When a prop could reasonably be a simple value or a complex object, accept both and normalize internally. Don't force users to wrap simple cases in objects.

**Why:** Requiring objects for simple cases adds verbosity. If most uses are simple strings but some need configuration, accept `string | ConfigObject` and normalize inside the component. This provides convenience for simple cases while supporting complex ones.

```tsx
// ❌ Bad: Always requiring object, even for simple cases
// User must write: tooltip={{ content: "Hello" }} even for simple text
interface BadgeProps {
  tooltip?: {
    content: ReactNode;
    placement?: TooltipPlacement;
    variant?: TooltipVariant;
  };
}

// Usage is verbose for simple cases:
<Badge tooltip={{ content: "Simple tooltip" }} />

// ✅ Good: Accept both string and object
interface BadgeProps {
  tooltip?: string | TooltipConfig;
}

// Normalize internally
function Badge({ tooltip, ...props }: BadgeProps) {
  const normalizedTooltip = typeof tooltip === 'string'
    ? { content: tooltip }
    : tooltip;

  // Use normalizedTooltip which is always TooltipConfig | undefined
}

// Usage is clean for simple cases:
<Badge tooltip="Simple tooltip" />

// And still supports complex cases:
<Badge tooltip={{ content: "Complex", placement: "bottom", variant: "multiline" }} />
```

**Apply consistently:** If you accept `string | object` in one component, do it in ALL components that use that prop type. Don't have Badge accept string but Button require object.

---

## Logic & Correctness

### LOGIC-1: No Duplicate Conditional Branches

Flag `if`/`else` (or `switch` cases) whose bodies are identical.

**Why:** Identical branches mean one of two things: the condition is dead and should be removed, or an intended difference between branches was never written. Both are bugs waiting to be found - the reader assumes the branches differ because the code went to the trouble of branching.

```typescript
// ❌ Bad: Both branches do exactly the same thing
if (user.isAdmin) {
  return fetchAllRecords();
} else {
  return fetchAllRecords();
}

// ❌ Bad: Switch cases with identical bodies
switch (status) {
  case "pending":
    return "In Progress";
  case "processing":
    return "In Progress";
  case "done":
    return "Complete";
}

// ✅ Good: Collapse when there's genuinely no distinction
return fetchAllRecords();

// ✅ Good: If a difference was intended, write it
if (user.isAdmin) {
  return fetchAllRecords();
} else {
  return fetchRecordsForUser(user.id);
}

// ✅ Good: Group cases that legitimately share a body
switch (status) {
  case "pending":
  case "processing":
    return "In Progress";
  case "done":
    return "Complete";
  default:
    throw new Error(`Unknown status: ${status}`);
}
```

---

### LOGIC-2: Handle Edge Cases in Guards

Guard clauses must account for legitimate edge cases: an empty collection that is valid on first render, `null`/`undefined`, boundary values, and unhandled promise rejections. Flag guards that silently do the wrong thing at the edges.

**Why:** A guard is supposed to protect against invalid states, but a too-broad guard disables valid ones. `if (arr.length === 0) return` looks defensive, but if an empty array is legitimate on first render it permanently short-circuits the fetch. Missing `await` and unhandled rejections fail silently in exactly the cases that matter.

**Scope:** This is about states genuinely reachable by untrusted input or real runtime conditions - not deployment-time config values (env vars, operator-set constants like `retentionDays` or `trustedProxyHops`) that have no path from user input; don't demand a NaN/bounds guard on those unless a concrete untrusted-input path reaches them. And before flagging a property chain that feeds a user-facing message as unguarded, check the render site too - if the consuming component already applies its own fallback (e.g. `${name ?? ""}`), the guard may already exist downstream.

```typescript
// ❌ Bad: Empty collection is legitimate on first render, but this
// guard permanently disables the fetcher - it never runs when
// selectedIds starts empty
useEffect(() => {
  if (selectedIds.length === 0) return;
  fetchDetailsFor(selectedIds);
}, [selectedIds]);

// ❌ Bad: Unhandled null - crashes when user has no profile yet
function getInitials(user: User) {
  return user.profile.name.slice(0, 2);
}

// ❌ Bad: Missing await - the rejection is never caught, the error
// handler never runs, and the caller thinks it succeeded
async function saveDraft(draft: Draft) {
  try {
    persist(draft); // not awaited
  } catch (error) {
    reportError(error);
  }
}

// ✅ Good: Only skip the fetch for states that are truly invalid
useEffect(() => {
  fetchDetailsFor(selectedIds); // empty is a valid query on first render
}, [selectedIds]);

// ✅ Good: Handle the null/undefined boundary
function getInitials(user: User) {
  const name = user.profile?.name ?? "";
  return name.slice(0, 2);
}

// ✅ Good: Await so the rejection reaches the catch
async function saveDraft(draft: Draft) {
  try {
    await persist(draft);
  } catch (error) {
    reportError(error);
  }
}

// ✅ OK: retentionDays is an operator-set deployment config value with no
// untrusted-input path - a missing NaN/bounds guard here isn't a reachable bug
function computeExpiryDate(retentionDays: number) {
  return addDays(new Date(), retentionDays);
}
```

---

### LOGIC-3: Conditions and Messages Must Match Their Actual Case

A permission check, action handler, or status message must reference the case it's actually guarding - not a copy-pasted neighbor's.

**Why:** Copy-pasting a similar condition, permission check, or UI message and forgetting to update which action or state it refers to produces code that compiles, runs, and reads as intentional. The bug only surfaces when someone traces the referenced constant back to what it actually means - by then it may already be in production.

**Scope:** Don't flag a broader permission that legitimately subsumes a narrower action (e.g. a `manage` permission covering `show`) - that's expected coverage, not a mismatch; only flag when the permission checked is a genuinely different, unrelated capability. Similarly, a `DELETE` handler classifying itself by a literal string match, or skipping body-parsing entirely, is often an intentional simplification given `DELETE` requests carry no body - don't flag it as under-specific unless you can point to a request that's actually misrouted as a result.

```typescript
// ❌ Bad: delete is gated on the edit permission, not delete
function canDelete(user: User, resource: Resource) {
  return user.permissions.includes("edit"); // copied from canEdit, never updated
}

// ❌ Bad: dispatches a delete action but checks the edit permission first
function handleDeleteRule(rule: Rule, user: User) {
  if (!user.permissions.includes("edit")) return;
  dispatch(deleteRule(rule.id));
}

// ❌ Bad: the error branch shows the empty-state copy
if (isError) {
  return <EmptyState message="No Data Found" />; // copied from the empty branch
}

// ✅ Good: each branch checks and shows what it actually means
function canDelete(user: User, resource: Resource) {
  return user.permissions.includes("delete");
}

function handleDeleteRule(rule: Rule, user: User) {
  if (!user.permissions.includes("delete")) return;
  dispatch(deleteRule(rule.id));
}

if (isError) {
  return <ErrorState message="Something went wrong. Please try again." />;
}
```

---

### LOGIC-4: Keep Controlled Inputs and Effects Honest About Their Inputs

Controlled inputs must always pair a `value` with an `onChange`, and effects must react to every prop/state value they read - don't guard away a dependency that's legitimately present, and don't leave a loading flag stale across a refetch.

**Why:** These are the same class of bug wearing different clothes: the component or effect claims to track a piece of state, but a missing handler, a missing dependency, or a leftover flag means it silently doesn't. The UI looks right in the common case and only breaks for the input, navigation, or refetch pattern nobody tested.

```typescript
// ❌ Bad: value with no onChange - input renders but user input is ignored
<input value={draft.title} />

// ❌ Bad: mixing defaultValue and value fights React for control of the field
<input defaultValue={draft.title} value={draft.title} onChange={onChange} />

// ❌ Bad: effect reads location.state but doesn't depend on it - stale on
// back/forward navigation
useEffect(() => {
  setFormValues(location.state?.draft ?? initialValues);
}, []);

// ❌ Bad: loading flag never resets, so a second fetch shows stale "done" state
function useResults(query: string) {
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    fetchResults(query).then((data) => {
      setResults(data);
      setLoading(false);
    });
  }, [query]); // loading is never set back to true when query changes
}

// ✅ Good: controlled input has both value and onChange
<input
  value={draft.title}
  onChange={(e) => setDraft({ ...draft, title: e.target.value })}
/>

// ✅ Good: effect depends on everything it reads
useEffect(() => {
  setFormValues(location.state?.draft ?? initialValues);
}, [location.state]);

// ✅ Good: loading flag is reset at the start of every fetch
function useResults(query: string) {
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    setLoading(true);
    fetchResults(query).then((data) => {
      setResults(data);
      setLoading(false);
    });
  }, [query]);
}
```

---

### LOGIC-5: Don't Silently Drop Behavior During a Refactor

When refactoring, verify every prop, parameter, `eslint-disable` comment, CSS/layout class, and piece of persisted state or error handling that existed before the change still exists after it - or has an explicit, intentional replacement.

**Why:** A refactor that quietly drops a prop nobody re-wired, an `eslint-disable` that suppressed a real warning, a layout class that was load-bearing, or persisted state/error handling that never got reimplemented doesn't fail loudly - it ships, passes review because the diff "looks like a cleanup," and the regression surfaces later as a confusing bug report with no connection back to the refactor that caused it.

```typescript
// ❌ Bad: previewLength prop removed from the component, but call sites still pass it
function InlineExpandableCell({ value }: { value: string }) {
  return <span>{value}</span>;
}
<InlineExpandableCell value={row.summary} previewLength={80} />; // now a dead no-op prop

// ❌ Bad: eslint-disable dropped along with the "cleanup" - the underlying issue
// it suppressed is still there, it just fails lint now instead of being silenced on purpose
// (deleted during refactor: eslint-disable-next-line @typescript-eslint/no-explicit-any)
window.open(url as any);

// ❌ Bad: layout class dropped with nothing to replace it
// before: <div className="h-full flex flex-col">
<div>{children}</div>

// ✅ Good: prop removed from both the component AND every call site
function InlineExpandableCell({ value }: { value: string }) {
  return <span>{value}</span>;
}
<InlineExpandableCell value={row.summary} />;

// ✅ Good: intentional replacement, or the same protection kept
<div className="h-full flex flex-col">{children}</div>
```

**Before removing anything in a refactor, ask:** was this dropped on purpose, and if so, what replaced it?

---

## Error Handling

### ERR-1: Errors Must Reach the User or Preserve Their Origin

A `catch` block that suppresses a failure must still surface a message where the user can see it. A rethrow or wrapped error must preserve the original error (as `cause` or in the message) and land in a handler that's actually reachable - not become an unhandled rejection.

**Why:** These are the same bug in opposite directions: a catch that swallows an error leaves the user staring at a UI that looks like it worked when it didn't, and a rethrow that loses the original error or has no handler above it leaves the developer with no way to diagnose what actually failed. Both destroy the information a user or developer needs at the exact moment they need it most.

**Scope:** This is about *user-facing* failures and *genuinely uncaught* rethrows - not every degrade-to-null parsing helper (a best-effort parser like `decodeEntry` is allowed to fail closed with no message) and not internal status/enum fields that are deliberately a coarse simplification rather than a raw error passthrough. In a queue/pubsub consumer where the platform retries on an uncaught throw, prefer letting the error propagate over adding a catch that swallows it - that catch is the anti-pattern, not the missing one.

```typescript
// ❌ Bad: catch swallows the error with no user-facing message
async function saveSettings(settings: Settings) {
  try {
    await api.saveSettings(settings);
  } catch (error) {
    console.error(error); // user has no idea the save failed
  }
}

// ❌ Bad: rethrow drops the original error and its cause
async function publishSnapshot(snapshot: Snapshot) {
  try {
    await api.publish(snapshot);
  } catch (error) {
    throw new Error("Publish failed"); // original error/stack is gone
  }
}

// ❌ Bad: async call in an event handler with no catch anywhere above it
button.onclick = async () => {
  await publishSnapshot(snapshot); // rejection is unhandled
};

// ✅ Good: surface a real message to the user
async function saveSettings(settings: Settings) {
  try {
    await api.saveSettings(settings);
  } catch (error) {
    showToast({ variant: "error", message: "Couldn't save settings. Try again." });
  }
}

// ✅ Good: preserve the original error
async function publishSnapshot(snapshot: Snapshot) {
  try {
    await api.publish(snapshot);
  } catch (error) {
    throw new Error("Publish failed", { cause: error });
  }
}

// ✅ Good: the caller catches and handles the rejection
button.onclick = async () => {
  try {
    await publishSnapshot(snapshot);
  } catch (error) {
    showToast({ variant: "error", message: "Couldn't publish snapshot." });
  }
};
```

---

## Performance & Scale

### SCALE-1: Don't Filter Large Collections In Memory

Flag `.filter()`, `.map()`, `.find()`, and similar in-memory operations over collections that can grow large. Push the filtering to the data source (server-side query, database `WHERE`, indexed lookup) and paginate.

**Why:** In-memory scans cost time and memory linear in the size of the collection, and they require loading the entire collection first. This works fine in testing with a handful of rows and becomes a performance cliff in production once the data grows - long before anyone notices in review.

```typescript
// ❌ Bad: Load every user, then filter in memory
const allUsers = await db.users.findMany();
const activeUsers = allUsers.filter((user) => user.status === "active");

// ❌ Bad: Fetch everything to find one record
const orders = await fetchAllOrders();
const order = orders.find((candidate) => candidate.id === orderId);

// ✅ Good: Filter at the data source
const activeUsers = await db.users.findMany({
  where: { status: "active" },
});

// ✅ Good: Look up directly, and paginate lists
const order = await db.orders.findUnique({ where: { id: orderId } });
const firstPage = await db.orders.findMany({
  where: { status: "open" },
  take: 25,
  skip: 0,
});
```

---

### SCALE-2: Paginate Unbounded Queries

Flag hardcoded high limits (e.g. `limit: 10000`) and unbounded fetches that pull an entire table with no pagination or truncation handling.

**Why:** A "big enough" limit is a bomb with a delayed fuse - it works until the data crosses the threshold, then silently drops rows or times out. Unbounded queries have the same problem with no ceiling at all. Real pagination scales with the data instead of guessing at a maximum.

**Scope:** Don't flag a bare hardcoded limit with no amplification cited - pair the flag with concrete evidence (a named fan-out, an exact row/record count, or a plausible growth path) that the limit will actually be crossed. And don't flag an already-reviewed operational constant (e.g. a search bucket-size clamp or a `from`/`size` bound) as too tight or too loose absent that same concrete evidence - these are frequently intentional, previously-discussed limits, not oversights.

```typescript
// ❌ Bad: Hardcoded high limit - silently truncates past 10,000
const events = await db.events.findMany({ take: 10000 });

// ❌ Bad: Unbounded fetch - grows without limit
const allEvents = await db.events.findMany();
render(allEvents);

// ✅ Good: Page through results with a cursor
async function fetchAllEvents() {
  const events: Event[] = [];
  let cursor: string | undefined;

  do {
    const page = await db.events.findMany({
      take: 100,
      ...(cursor ? { skip: 1, cursor: { id: cursor } } : {}),
    });
    events.push(...page);
    cursor = page.length === 100 ? page[page.length - 1].id : undefined;
  } while (cursor);

  return events;
}

// ✅ Good: Or paginate at the UI and only fetch what's shown
const page = await db.events.findMany({ take: pageSize, skip: pageIndex * pageSize });
```

---

### SCALE-3: Isolate and Parallelize Independent Per-Item Async Work

When looping over independent items to perform async work (webhook calls, per-device notifications), guard each item so one failure doesn't abort the rest, and run genuinely independent async calls concurrently instead of `await`-ing them one at a time.

**Why:** A loop with one unguarded `await` per item means the first failure stops every item after it - one bad webhook target silently drops every notification queued behind it. And when calls don't depend on each other's results, awaiting them sequentially adds up their latencies for no reason; `Promise.all` (or `Promise.allSettled` when partial failure is expected) runs them in the time of the slowest one.

**Scope:** Doesn't apply to bulk-write APIs (e.g. a bulk index/update call) that already have their own partial-failure semantics - check whether the loop is really independent per-item work before flagging it.

```typescript
// ❌ Bad: one failing webhook aborts every notification after it
async function notifyDevices(devices: Device[], event: Event) {
  for (const device of devices) {
    await webhook.trigger(device, event); // throws -> remaining devices never notified
  }
}

// ❌ Bad: independent fetches awaited one at a time
async function loadDashboard(orgId: string) {
  const latestHits = await fetchLatestHits(orgId);
  const historyResult = await fetchHistory(orgId); // doesn't depend on latestHits
  const policies = await fetchPolicies(orgId); // doesn't depend on either
  return { latestHits, historyResult, policies };
}

// ✅ Good: guard each item so one failure doesn't stop the rest
async function notifyDevices(devices: Device[], event: Event) {
  await Promise.allSettled(
    devices.map((device) => webhook.trigger(device, event))
  );
}

// ✅ Good: independent fetches run concurrently
async function loadDashboard(orgId: string) {
  const [latestHits, historyResult, policies] = await Promise.all([
    fetchLatestHits(orgId),
    fetchHistory(orgId),
    fetchPolicies(orgId),
  ]);
  return { latestHits, historyResult, policies };
}
```

---

## Debug Artifacts

### DEBUG-1: No Stray Test Identifiers in Production

Flag auto-generated or placeholder test identifiers - random `data-testid`/`@test-id` values, `test-`/`tmp-` prefixed ids, and similar scaffolding - left in production code paths.

**Why:** Auto-generated test ids are noise in shipped code: they bloat the DOM, leak the fact that code was shipped mid-debugging, and read as random strings that the next developer can't tell are safe to remove. Intentional, stable test ids are fine; leftover generated ones are not.

```typescript
// ❌ Bad: Random test id left in from debugging
<button data-testid="test-btn-8f2a1c">Submit</button>

// ❌ Bad: Placeholder id that was never cleaned up
<div id="tmp-debug-container">{children}</div>

// ✅ Good: Remove it
<button>Submit</button>

// ✅ Good: Or, if a test hook is genuinely needed, use a stable,
// intentional name that describes the element
<button data-testid="checkout-submit">Submit</button>
```

---

### DEBUG-2: No Leftover Console Logging

Flag stray `console.log`/`console.debug` calls in shipped code.

**Why:** Debug logging left in production clutters the console, can leak sensitive data into logs, and hurts performance in hot paths. Use the project's real logger for intentional logging and remove the throwaway `console.log`s.

```typescript
// ❌ Bad: Debug logging left in
function checkout(cart: Cart) {
  console.log("cart", cart);
  const total = calculateTotal(cart);
  console.debug("total is", total);
  return submitOrder(cart, total);
}

// ✅ Good: Debug logs removed
function checkout(cart: Cart) {
  const total = calculateTotal(cart);
  return submitOrder(cart, total);
}

// ✅ Good: If logging is genuinely needed, use the real logger
function checkout(cart: Cart) {
  const total = calculateTotal(cart);
  logger.info("checkout.submitted", { cartId: cart.id, total });
  return submitOrder(cart, total);
}
```

---

## Security

### SEC-1: Enforce Object-Level Authorization

Never trust a client-supplied owner, tenant, or resource identifier to decide what data to return. Verify server-side that the authenticated caller is actually authorized for the requested resource. Flag any handler that reads an id from the request and queries by it without an ownership check.

**Why:** Trusting a client-supplied id lets an attacker swap in someone else's id and read or modify data that isn't theirs (an IDOR / cross-tenant access bug). The identity to trust is the authenticated session, not a value in the request body or query string.

**Scope:** This applies just as much when a resource is scoped by more than one key (e.g. partner + soc, tenant + workspace). Filtering by only one of the client-supplied keys and skipping the others is still a bypass - verify every scoping key the resource requires, not just the first one checked.

This requirement isn't limited to database queries. An in-memory or module-level cache keyed without the tenant/partner dimension leaks one tenant's cached response to another's request just as surely as an unscoped query does, and a secret or config key name needs the same per-environment/per-tenant scoping as a resource id. A scoping check written with optional chaining must fail closed when the left side is `undefined` - if an intermediate value can legitimately be missing, guard for that case explicitly and deny by default, don't let it silently pass. And before flagging a handler for missing scoping, check whether the service layer or an upstream middleware already enforces it outside the diff - many handlers are protected one layer down.

```typescript
// ❌ Bad: Trusts the tenantId sent by the client
async function getInvoices(req: Request) {
  const { tenantId } = req.query; // attacker can send any tenantId
  return db.invoices.findMany({ where: { tenantId } });
}

// ❌ Bad: Fetches by id with no ownership check
async function getDocument(req: Request) {
  const { documentId } = req.params;
  return db.documents.findUnique({ where: { id: documentId } });
  // Any authenticated user can read any document by guessing ids
}

// ✅ Good: Derive the tenant from the authenticated session, not the request
async function getInvoices(req: AuthedRequest) {
  const tenantId = req.session.tenantId; // trusted, set at auth time
  return db.invoices.findMany({ where: { tenantId } });
}

// ✅ Good: Verify the caller owns the resource before returning it
async function getDocument(req: AuthedRequest) {
  const { documentId } = req.params;
  const document = await db.documents.findUnique({ where: { id: documentId } });

  if (!document || document.ownerUserId !== req.session.userId) {
    throw new ForbiddenError("Not authorized for this document");
  }
  return document;
}

// ❌ Bad: filters by partnerId but never verifies it belongs to the caller's soc
async function getPartnerAlerts(req: AuthedRequest) {
  const { partnerId } = req.query; // client-supplied, not verified against the soc
  return db.alerts.findMany({ where: { partnerId } });
  // A user from one soc can pass another soc's partnerId and see its alerts
}

// ✅ Good: verify the partner belongs to the caller's soc before filtering by it
async function getPartnerAlerts(req: AuthedRequest) {
  const { partnerId } = req.query;
  const partner = await db.partners.findUnique({ where: { id: partnerId } });

  if (!partner || partner.socId !== req.session.socId) {
    throw new ForbiddenError("Not authorized for this partner");
  }
  return db.alerts.findMany({ where: { partnerId } });
}

// ❌ Bad: cache keyed without the tenant dimension - leaks across tenants
const customersCache = new Map<string, Customer[]>();
async function getCustomers(partnerId: string) {
  if (customersCache.has("customers")) return customersCache.get("customers");
  const customers = await fetchCustomers(partnerId);
  customersCache.set("customers", customers);
  return customers;
}

// ❌ Bad: optional chaining silently drops the scoping filter when orgId is undefined
async function getEvents(req: AuthedRequest) {
  const orgId = req.session.user?.organizationId;
  return db.events.findMany({
    where: orgId ? { organizationId: orgId } : {}, // undefined orgId -> no filter at all
  });
}

// ✅ Good: cache key includes the scoping dimension
async function getCustomers(partnerId: string) {
  if (customersCache.has(partnerId)) return customersCache.get(partnerId);
  const customers = await fetchCustomers(partnerId);
  customersCache.set(partnerId, customers);
  return customers;
}

// ✅ Good: missing orgId fails closed instead of silently returning everything
async function getEvents(req: AuthedRequest) {
  const orgId = req.session.user?.organizationId;
  if (!orgId) throw new ForbiddenError("No organization on session");
  return db.events.findMany({ where: { organizationId: orgId } });
}
```

---

## Test Coverage

### TEST-GAP-1: Cover Non-Trivial Pure Functions, Boundary Conditions, and Lifecycle Termination

A non-trivial pure function (geometry/positioning math, a date-range or classification predicate, a legacy-compat parsing path) needs a test - including its boundary cases, not just the obvious input. Async lifecycle code (polling, intervals, retries) needs a test proving it actually stops when it should. And a test whose name promises a specific case must actually exercise that case.

**Why:** These are the tests that catch real regressions - a boundary miscalculated by one day, a classification predicate that never matches its documented case, an interval that keeps firing after unmount. A test file with the right name but assertions that pass regardless of the input gives false confidence, which is worse than no test at all.

**Scope:** Reserve this for genuinely non-trivial logic - a geometry calculation, a date-range boundary, a matching/classification predicate, a legacy parsing branch, a polling termination condition, a cross-tenant isolation guarantee. Don't flag a missing test for a simple list render, a single obvious branch of a plain filter, or UI conditional-render branch coverage - those don't get fixed in practice and just add noise.

```typescript
// ❌ Bad: no test for the boundary of a date-range filter
function isWithinRange(date: Date, start: Date, end: Date) {
  return date >= start && date <= end;
}
// Nothing asserts what happens exactly at `start` or `end`.

// ❌ Bad: test name promises "latest" but never actually exercises that path
it("returns the latest snapshot", () => {
  const result = getSnapshot(snapshots);
  expect(result).toBeDefined(); // passes for any snapshot, not just the latest
});

// ❌ Bad: polling code with no test that it stops
function usePolling(jobId: string, onComplete: () => void) {
  useEffect(() => {
    const interval = setInterval(() => checkJobStatus(jobId, onComplete), 1000);
    return () => clearInterval(interval);
  }, [jobId]);
}
// No test proves the interval clears on unmount or stops once the job completes.

// ✅ Good: boundary cases explicitly asserted
it("includes the exact start and end instants", () => {
  expect(isWithinRange(start, start, end)).toBe(true);
  expect(isWithinRange(end, start, end)).toBe(true);
  expect(isWithinRange(new Date(end.getTime() + 1), start, end)).toBe(false);
});

// ✅ Good: the test actually exercises the case it's named for
it("returns the latest snapshot", () => {
  const result = getSnapshot([older, newer]);
  expect(result).toBe(newer);
});

// ✅ Good: polling termination is directly tested
it("stops polling once the job completes", () => {
  const { unmount } = renderHook(() => usePolling(jobId, onComplete));
  completeJob(jobId);
  jest.advanceTimersByTime(1000);
  expect(onComplete).toHaveBeenCalledTimes(1);
  jest.advanceTimersByTime(5000);
  expect(onComplete).toHaveBeenCalledTimes(1); // no further calls
});
```

---

## Adding New Rules

To add a new rule:

1. Choose or create an appropriate category
2. Assign a rule ID (e.g., `EXT-5`, `TYPE-2`, `NAME-12`, `REACT-6`)
3. Include: rule name, rationale ("Why"), bad example, good example
4. Update `README.md` with the new rule in the appropriate table
5. Increment minor version in `.claude-plugin/plugin.json` and in `.claude-plugin/marketplace.json` (if not already done in this session)
