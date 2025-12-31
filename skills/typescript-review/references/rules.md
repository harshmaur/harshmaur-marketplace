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

### EXT-4: Avoid Ternaries for Non-Boolean Conditions

Use ternaries only for true boolean conditions. For mode/type-based logic, use functions or if-else.

**Why:** Ternaries assume exactly 2 outcomes. They silently break when a third option is added.

```typescript
// ❌ Bad: Ternary assumes only 2 modes forever
const label = mode === "IOC" ? "IOC Label" : "Rules Label";
// What happens when mode === 'HYBRID'? Silent bug: shows "Rules Label"

// ❌ Bad: Ternary in JSX
<span>{mode === "IOC" ? "Processing IOC..." : "Processing Rules..."}</span>;

// ✅ Good: Helper function handles all cases explicitly
function getModeLabel(mode: ProcessingMode): string {
  if (mode === "IOC") return "IOC Label";
  if (mode === "RULES") return "Rules Label";
  if (mode === "HYBRID") return "Hybrid Label";
  // TypeScript will error if a case is missing (with exhaustive checks)
  throw new Error(`Unknown mode: ${mode}`);
}

const label = getModeLabel(mode);
<span>{getModeLabel(mode)}</span>;

// ✅ OK: Ternary for actual booleans
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

## Naming & Structure

### NAME-1: No Spelling Mistakes in Names or Comments

Variable names, function names, and comments must be spelled correctly.

**Why:** Spelling mistakes cause confusion, make code harder to search, and look unprofessional. Typos in variable names can also cause bugs when someone searches for the correct spelling.

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

## Comments

### COMMENT-1: Comment the "Why", Not the "What"

Don't write comments that explain what code does - that's visible from reading the code. Only comment to explain WHY something is done a certain way, especially for anti-patterns or non-obvious decisions.

**Why:** Comments explaining "what" become outdated and redundant. Comments explaining "why" preserve crucial context that isn't visible in the code itself.

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

## Adding New Rules

To add a new rule:

1. Choose or create an appropriate category
2. Assign a rule ID (e.g., `EXT-5`, `TYPE-2`, `NAME-12`, `REACT-6`)
3. Include: rule name, rationale ("Why"), bad example, good example
4. Update `README.md` with the new rule in the appropriate table
5. Increment minor version in `.claude-plugin/plugin.json` and in `.claude-plugin/marketplace.json` (if not already done in this session)
