# Settings Module Context

## 1. Overview
The Settings module contains administrative configuration:
- Module UUID: `fcb69b3e-e5aa-49bb-921f-7793f0a8c90d` (`settings`)
- Submodules:
  - Master: `662d62ab-38b1-447e-876e-7f93bf2ba50e` (`master`) -> `/settings-masters`
  - Roles & Permissions: `e231d2d4-9ebb-4eb2-af48-fbe3b3b4ab90` (`roles-permissions`) -> `/settings-security-roles`

## 2. Hardcoded Admin Restriction
Settings and its submodules are strictly reserved for users with active role `"admin"`. They are omitted from ordinary RBAC catalog evaluation so non-admin roles cannot gain access under any circumstances.

