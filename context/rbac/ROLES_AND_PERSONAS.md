# Roles & Demo Personas

## 1. System Roles in `auth.tbl_roles`
The system defines 29 operational and governance roles:

| Role Name | Display Name | UUID | Default Nature |
|---|---|---|---|
| **Admin** | Admin | `a0000000-0000-0000-0000-000000000001` | Super Administrator (bypasses all checks) |
| **CEO** | CEO | `62a927b7-9fd8-461a-b64e-1aa441eeba4d` | Executive governance |
| **CTO** | CTO | `66e48815-4d4f-41d0-9c5f-26a7b7ba296c` | Technical executive |
| **COO** | COO | `a5bfe265-981a-4723-b7bb-6ddc389db7f0` | Operations executive |
| **PMO** | PMO (Project Management Office) | `2acf8b94-0756-4db8-bb6f-8372ac04a2d1` | Portfolio and resource management |
| **EngagementManager** | EM (Engagement Manager) | `a5023c9e-367f-41e1-ba02-bdb2929edc89` | Client account & project engagement |
| **HR** | HR | `bb568e26-548b-4ca5-9221-fefb9c9143b3` | Personnel, onboarding, directory |
| **IT Admin** | IT Admin | `b552183f-2695-41f9-860e-16d5fe94c4aa` | IT infrastructure & devices |
| **Accounts** | Accounts | `cd2a32ed-32fc-47bc-88a9-e6fc48863869` | Billing & financial invoices |
| **Sales Manager** | Sales - Manager | `914d8500-03b6-4a43-a250-244effca1cf1` | Sales pipeline & client acquisition |
| **Sales team member** | Sales - Team Member | `7cc8753c-f3b0-4fc9-b63b-efd00e2c5325` | Sales contributor |
| **PM - Team Member** | PM - Team Member | `64e2ea37-cbd7-4127-b65b-3b003235981a` | Project delivery contributor |
| **Testing HOD** | Testing - HOD | `c787fe3b-4b33-40ee-8794-c1148202f81a` | QA Head of Department |
| **Testing Senior Manager**| Testing - Senior Manager | `efc1df20-ca04-44a6-87b2-7cae1ff50a88` | Senior QA Manager |
| **Testing-Manager** | Testing - Manager | `29ad5710-1621-4c24-ac75-dedfc168ba1a` | QA Manager |
| **Testing-Team Leader** | Testing - Team Leader | `a3793f87-7f3c-41a1-a675-236fc1b710ab` | QA Lead |
| **Testing-Team Member** | Testing - Team Member | `92aa9169-28d9-4754-a570-553b067642ed` | QA Contributor |
| **SOC-HOD** | SOC - HOD | `3d068c2f-d0a1-4045-bad9-0f3a43efec4f` | Security Operations Head |
| **SOC-Senior Manager** | SOC - Senior Manager | `b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7` | Senior SOC Manager |
| **SOC-Manager** | SOC - Manager | `111cc3cd-6d35-43ce-be91-dde90d3d4015` | SOC Manager |
| **SOC-Team Leader** | SOC - Team Leader | `aba61e5b-422a-4461-b9da-8dba8f6d3f85` | SOC Lead |
| **SOC-Team Member** | SOC - Team Member | `1a62b1f8-1810-464d-a67b-168d7e419827` | SOC Contributor |
| **Consulting-HOD** | Consulting - HOD | `64c49f37-a38a-46a6-9622-7427f1501658` | Consulting Head |
| **Consulting-Senior Manager**| Consulting - Senior Manager| `4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089` | Senior Consulting Manager |
| **Consulting-Manager** | Consulting - Manager | `e5d6f6ff-be59-4cc4-a8c6-65191d550d0a` | Consulting Manager |
| **Consulting-Team Leader** | Consulting - Team Leader | `701aaa2c-a899-4def-bf5f-e17511874409` | Consulting Lead |
| **Consulting-Team member** | Consulting - Team member | `768a11f9-ded7-4f6f-ba86-073e279255d9` | Consulting Contributor |
| **R&D - Team member** | R&D - Team member | `f5c742d1-e0cc-4bf8-b860-a673ac407393` | Research & Development |
| **Intern** | Intern | `f29af015-7833-4f9a-ac57-6fbef5bf91ec` | Intern / Trainee |

---

## 2. Dev Mode User Switcher & Header Injection

During development and UAT mode, Microsoft 365 identity is simulated via `apps/frontend/src/lib/user-personas.ts` and `api-client.ts`.

When any request is sent from the frontend:
- `X-User-Role`: Injected with the selected persona's role name (e.g., `Admin`, `COO`, `Intern`).
- `X-User-Email`: Injected with the persona's email (e.g., `admin@talakunchi.com`).
- `X-User-Id`: Injected with the persona's employee UUID.

Backend `RbacAuthorizationService` reads `X-User-Role` from HTTP headers if user claims do not contain a role claim.

