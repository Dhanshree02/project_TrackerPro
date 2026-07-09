# Knowledge Sync Rules

> **Purpose:** Ensure wiki, code, and documentation are always in sync  
> **Enforcement:** MANDATORY for all developers and AI assistants  
> **Last Updated:** 2026-06-16

---

## The Golden Rule

> **A code change without a wiki update is an INCOMPLETE change.**  
> **Documentation that conflicts with code MUST be corrected immediately.**

---

## Repository Ownership Rules

Whoever modifies code is responsible for maintaining documentation consistency. For EVERY code change, you MUST determine:

1. **Which modules changed** → Update module docs (09-19 series)
2. **Which APIs changed** → Update `21_API_Design_Draft.md`
3. **Which workflows changed** → Update `05_Business_Workflows.md`
4. **Which database entities changed** → Update `20_Database_Design_Draft.md`
5. **Which architecture decisions changed** → Create ADR in `development/decisions/`
6. **Which roles/permissions changed** → Update `04_Roles_and_Permissions.md`

---

## Sync Matrix

| Code Change | Wiki Documents to Update |
|------------|--------------------------|
| New route file | `Repository_Analysis`, `Frontend_Architecture`, `06_UI_Architecture`, `08_Module_Analysis` |
| New component | `06_UI_Architecture` (component library) |
| New data type / entity | `27_Data_Model_Reference`, `02_Business_Domain` |
| New business rule | Relevant module doc (09-19), `05_Business_Workflows` |
| New API endpoint | `21_API_Design_Draft`, relevant module doc |
| Database schema change | `20_Database_Design_Draft`, `27_Data_Model_Reference` |
| Role permission change | `04_Roles_and_Permissions`, `23_Security_and_RBAC` |
| Workflow change | `05_Business_Workflows`, relevant module doc |
| Configuration change | `RUNNING_THE_PROJECT`, `Repository_Analysis` |
| Dependency added/removed | `Repository_Analysis` (technology stack section) |
| Bug fix | `29_Known_Frontend_Behavior` or `development/daily-notes/` |
| Architecture decision | `development/decisions/ADR-NNN-title.md` |
| File restructuring | `Repository_Analysis`, `Repository_Improvement_Plan` |
| Backend changes | `Backend_Master_Plan`, `BACKEND_DEVELOPMENT_PHASES` |

---

## How to Update

1. **Identify affected documents** using the sync matrix above
2. **Update the specific section** — don't rewrite entire documents
3. **Update the `Last Updated` date** at the top of modified wiki files
4. **Create a daily note** in `development/daily-notes/YYYY-MM-DD.md`
5. **Update the progress log** in `development/frontend-progress/` or `development/backend-progress/`

---

## Conflict Resolution

If documentation conflicts with code:

1. **Code is the source of truth for behavior** — update docs to match code
2. **Wiki is the source of truth for intent** — if code deviates from documented design, that's a bug
3. **When in doubt, add a note** to `26_Open_Questions.md`

---

## What NOT to Do

- ❌ Don't create duplicate documentation
- ❌ Don't skip wiki updates "because it's a small change"
- ❌ Don't modify wiki structure without updating [[PROJECT_RECOVERY_GUIDE]] navigation
- ❌ Don't delete wiki content without marking it as deprecated first
- ❌ Don't make backend changes without updating `BACKEND_DEVELOPMENT_PHASES.md` status
- ❌ Don't add new routes without updating the route map in `Frontend_Architecture.md`

---

## Session Tracking Requirement

For every coding session, create:
```
wiki/development/daily-notes/YYYY-MM-DD.md
```

Include:
- Goals for the session
- Completed work
- Files added/modified
- Architecture changes
- Database changes (if any)
- API changes (if any)
- Known issues discovered
- Next steps

---

## Related Documents
- [[AI_DEVELOPMENT_WORKFLOW]]
- [[PROJECT_RECOVERY_GUIDE]]
- [[AI_HANDOVER_TEMPLATE]]
