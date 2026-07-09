# AI Development Workflow

> **Purpose:** Mandatory rules for AI assistants making code changes  
> **Enforcement:** Every AI session must follow these rules  
> **Last Updated:** 2026-06-16

---

## Core Principle

> **Code changes are INCOMPLETE until the corresponding wiki updates are made.**

---

## Before Making Changes

1. **Read the recovery guide:** [[PROJECT_RECOVERY_GUIDE]]
2. **Check relevant wiki modules:** Read the module documentation for the area you're modifying
3. **Check open questions:** [[26_Open_Questions]] — some decisions may already be discussed
4. **Check known behavior:** [[29_Known_Frontend_Behavior]] — avoid re-discovering known quirks

---

## During Development

### Every Code Change Must Be Documented

For each code modification, create or update:

1. **Module wiki** (09-19 series) — if the change affects module behavior
2. **Architecture docs** (01, 06, 07) — if the change affects system architecture
3. **Data model reference** (27) — if new types/entities are added
4. **Known behavior** (29) — if you discover new quirks or behaviors
5. **Development progress log** — `development/frontend-progress/` or `development/backend-progress/`

### Decision Records

For non-trivial decisions, create an ADR:
```
development/decisions/ADR-NNN-title.md
```

Template:
```markdown
# ADR-NNN: Decision Title

## Status: Proposed | Accepted | Deprecated | Superseded

## Context
What is the issue that we're seeing that is motivating this decision?

## Decision
What is the change that we're making?

## Consequences
What becomes easier or harder because of this change?

## Alternatives Considered
What other options were evaluated?
```

---

## After Making Changes

1. **Update the task tracker** (if one exists for the current work)
2. **Update relevant wiki documents** with the new state
3. **Run the dev server** to verify changes work
4. **Create a handover note** if ending the session — [[AI_HANDOVER_TEMPLATE]]

---

## Code Conventions

### File Organization (rooted at `apps/frontend/`)
- Route components in `src/routes/`
- Shared components in `src/components/`
- Business logic in `src/lib/`
- Utility functions in `src/lib/utils.ts`

### Naming Conventions
- Route files: `kebab-case.tsx` (e.g., `wbs-allocation.tsx`)
- Components: `PascalCase` function names
- Types/interfaces: `PascalCase`
- Variables: `camelCase`
- CSS classes: Tailwind utilities

### Import Order
1. React/framework imports
2. Third-party library imports
3. Internal component imports
4. Internal lib/util imports
5. Type imports

---

## Related Documents
- [[KNOWLEDGE_SYNC_RULES]]
- [[AI_HANDOVER_TEMPLATE]]
- [[PROJECT_RECOVERY_GUIDE]]
