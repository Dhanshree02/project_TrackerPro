# Merge Context & Precautions: Timesheet Sub-Tabs Database Seeding & RBAC Linkage

## 1. Overview of Changes
Added 3 sub-tabs under the parent **Timesheets** submodule in database `pms_uat_clean` (table `master.mst_tabs`) to enable hierarchical catalog mapping and permissions assignment on the **Roles & Permissions** page (`/settings-security-roles`) as specified in [`omkar_rbac.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/omkar_rbac.md).

### Entity Hierarchy:
- **Parent Module:** `master.mst_modules` (`Code = 'my-team'`, `Name = 'My Team'`, `Id = 6055ce3c-b466-4354-ba9a-b4c309111e9d`)
- **Parent Submodule:** `master.mst_submodules` (`Code = 'timesheets'`, `Name = 'Timesheets'`, `Id = d67426d3-05df-4608-b8cf-c0ecfe698dc3`, `Parent = My Team`)
- **Tabs Added Under Timesheets (`master.mst_tabs` where `SubModuleId = d67426d3-05df-4608-b8cf-c0ecfe698dc3`):**
  1. `my-timesheet` ("My Timesheet", SortOrder 10, ID `d67426d3-0001-4000-8000-000000000001`)
  2. `timesheet-history` ("Timesheet History", SortOrder 20, ID `d67426d3-0001-4000-8000-000000000002`)
  3. `timesheet-approval` ("Timesheet Approval", SortOrder 30, ID `d67426d3-0001-4000-8000-000000000003`)

---

## 2. Reversible / Idempotent SQL Script for Fellow Developers
Run this script inside the PostgreSQL container on database `pms_uat_clean` (or target environment):

```sql
DO $$
DECLARE
    timesheets_submodule_id uuid;
BEGIN
    SELECT "Id" INTO timesheets_submodule_id 
    FROM master.mst_submodules 
    WHERE "Code" = 'timesheets' 
    LIMIT 1;
    
    IF timesheets_submodule_id IS NULL THEN
        RAISE EXCEPTION 'Submodule timesheets not found in master.mst_submodules';
    END IF;

    -- 1. My Timesheet
    INSERT INTO master.mst_tabs ("Id", "Code", "Name", "SortOrder", "IsActive", "ModuleId", "SubModuleId", "TabId", "CreatedAtUtc")
    VALUES ('d67426d3-0001-4000-8000-000000000001', 'my-timesheet', 'My Timesheet', 10, true, NULL, timesheets_submodule_id, NULL, NOW())
    ON CONFLICT ("Code") DO UPDATE 
    SET "Name" = EXCLUDED."Name",
        "SortOrder" = EXCLUDED."SortOrder",
        "IsActive" = true,
        "ModuleId" = NULL,
        "SubModuleId" = timesheets_submodule_id,
        "TabId" = NULL,
        "UpdatedAtUtc" = NOW();

    -- 2. Timesheet History
    INSERT INTO master.mst_tabs ("Id", "Code", "Name", "SortOrder", "IsActive", "ModuleId", "SubModuleId", "TabId", "CreatedAtUtc")
    VALUES ('d67426d3-0001-4000-8000-000000000002', 'timesheet-history', 'Timesheet History', 20, true, NULL, timesheets_submodule_id, NULL, NOW())
    ON CONFLICT ("Code") DO UPDATE 
    SET "Name" = EXCLUDED."Name",
        "SortOrder" = EXCLUDED."SortOrder",
        "IsActive" = true,
        "ModuleId" = NULL,
        "SubModuleId" = timesheets_submodule_id,
        "TabId" = NULL,
        "UpdatedAtUtc" = NOW();

    -- 3. Timesheet Approval
    INSERT INTO master.mst_tabs ("Id", "Code", "Name", "SortOrder", "IsActive", "ModuleId", "SubModuleId", "TabId", "CreatedAtUtc")
    VALUES ('d67426d3-0001-4000-8000-000000000003', 'timesheet-approval', 'Timesheet Approval', 30, true, NULL, timesheets_submodule_id, NULL, NOW())
    ON CONFLICT ("Code") DO UPDATE 
    SET "Name" = EXCLUDED."Name",
        "SortOrder" = EXCLUDED."SortOrder",
        "IsActive" = true,
        "ModuleId" = NULL,
        "SubModuleId" = timesheets_submodule_id,
        "TabId" = NULL,
        "UpdatedAtUtc" = NOW();

    RAISE NOTICE 'Successfully upserted 3 Timesheet tabs under Timesheets submodule (Id: %)', timesheets_submodule_id;
END $$;
```

---

## 3. Merge Precautions & Database Constraints

> [!IMPORTANT]
> **Check Constraint `CK_mst_tabs_OneParent`**:
> In `master.mst_tabs`, each row **must have exactly one parent**:
> - These tabs attach directly to a submodule (`SubModuleId = d67426d3-05df-4608-b8cf-c0ecfe698dc3`).
> - Therefore, `ModuleId` **MUST BE NULL** and `TabId` **MUST BE NULL**.
> - Foreign key constraint `"FK_mst_tabs_mst_submodules_SubModuleId"` enforces reference integrity to `master.mst_submodules("Id")`.

> [!WARNING]
> **Unique Index on `Code` (`IX_mst_tabs_Code`)**:
> `Code` is globally unique across `master.mst_tabs`. The codes used are:
> - `my-timesheet`
> - `timesheet-history`
> - `timesheet-approval`

> [!NOTE]
> **Single Source of Truth**:
> Reference [`omkar_rbac.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/omkar_rbac.md) Section 4.F for hierarchy rules and permissions behavior.

---

## 4. Verification
### A. SQL Verification Query:
```sql
SELECT 
    t."Id",
    t."Code",
    t."Name",
    t."SortOrder",
    t."IsActive",
    t."SubModuleId",
    s."Name" as "SubModuleName"
FROM master.mst_tabs t
JOIN master.mst_submodules s ON t."SubModuleId" = s."Id"
WHERE t."SubModuleId" = 'd67426d3-05df-4608-b8cf-c0ecfe698dc3'
ORDER BY t."SortOrder";
```
Expected output: 3 rows (`My Timesheet`, `Timesheet History`, `Timesheet Approval`) under `SubModuleName = 'Timesheets'`.

### B. Backend API Verification:
```bash
curl -s http://localhost:52815/api/v1/catalogs/modules
```
Under `my-team` -> `subModules` (`timesheets`), `tabs` will contain the 3 items.

### C. Frontend Roles & Permissions Page:
Navigating to `/settings-security-roles`, expanding `My Team` and `Timesheets` displays all 3 tabs with Type `Tab` badge and view/manage radio toggles.
