# Merge Context & Precautions: Health Sub-Tabs Database Seeding & RBAC Linkage

## 1. Overview of Changes
Added 6 sub-tabs under the parent **Health** tab in database `pms_uat_clean` (table `master.mst_tabs`) to enable hierarchical catalog mapping and permissions assignment on the **Roles & Permissions** page (`/settings-security-roles`) as defined in [`omkar_rbac.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/omkar_rbac.md).

### Entity Hierarchy:
- **Parent Module:** `master.mst_modules` (`Code = 'projects'`, `Id = 168b1296-de6a-4f9e-a3b9-617b83863736`)
- **Parent Submodule:** `master.mst_submodules` (`Code = 'project-detail'`, `Id = b8f7c125-0e5b-4e3d-98e3-542638fa0b21`)
- **Parent Tab:** `master.mst_tabs` (`Code = 'project-health'`, `Name = 'Health'`, `Id = c1a11111-0001-4000-8000-000000000005`, `SubModuleId = b8f7c125-0e5b-4e3d-98e3-542638fa0b21`)
- **Sub-Tabs Added / Verified Under Health (`TabId = c1a11111-0001-4000-8000-000000000005`):**
  1. `health-issues` ("Issues", SortOrder 10)
  2. `health-alerts` ("Alerts", SortOrder 20)
  3. `health-escalations` ("Escalations", SortOrder 30)
  4. `health-appreciation` ("Appreciation", SortOrder 40)
  5. `health-customer-engagement` ("Customer Engagement", SortOrder 50)
  6. `health-extension-request` ("Extension Request", SortOrder 60)

---

## 2. Reversible / Idempotent SQL Script for Fellow Developers
Run this script inside the PostgreSQL container on database `pms_uat_clean` (or target environment):

```sql
DO $$
DECLARE
    health_tab_id uuid;
BEGIN
    SELECT "Id" INTO health_tab_id FROM master.mst_tabs WHERE "Code" = 'project-health' LIMIT 1;
    
    IF health_tab_id IS NULL THEN
        RAISE EXCEPTION 'Parent tab project-health not found in master.mst_tabs';
    END IF;

    -- 1. Issues
    INSERT INTO master.mst_tabs ("Id", "Code", "Name", "SortOrder", "IsActive", "ModuleId", "SubModuleId", "TabId", "CreatedAtUtc")
    VALUES ('c1a11111-0002-4000-8000-000000000001', 'health-issues', 'Issues', 10, true, NULL, NULL, health_tab_id, NOW())
    ON CONFLICT ("Code") DO UPDATE 
    SET "Name" = EXCLUDED."Name",
        "SortOrder" = EXCLUDED."SortOrder",
        "IsActive" = true,
        "ModuleId" = NULL,
        "SubModuleId" = NULL,
        "TabId" = health_tab_id,
        "UpdatedAtUtc" = NOW();

    -- 2. Alerts
    INSERT INTO master.mst_tabs ("Id", "Code", "Name", "SortOrder", "IsActive", "ModuleId", "SubModuleId", "TabId", "CreatedAtUtc")
    VALUES ('c1a11111-0002-4000-8000-000000000002', 'health-alerts', 'Alerts', 20, true, NULL, NULL, health_tab_id, NOW())
    ON CONFLICT ("Code") DO UPDATE 
    SET "Name" = EXCLUDED."Name",
        "SortOrder" = EXCLUDED."SortOrder",
        "IsActive" = true,
        "ModuleId" = NULL,
        "SubModuleId" = NULL,
        "TabId" = health_tab_id,
        "UpdatedAtUtc" = NOW();

    -- 3. Escalations
    INSERT INTO master.mst_tabs ("Id", "Code", "Name", "SortOrder", "IsActive", "ModuleId", "SubModuleId", "TabId", "CreatedAtUtc")
    VALUES ('c1a11111-0002-4000-8000-000000000003', 'health-escalations', 'Escalations', 30, true, NULL, NULL, health_tab_id, NOW())
    ON CONFLICT ("Code") DO UPDATE 
    SET "Name" = EXCLUDED."Name",
        "SortOrder" = EXCLUDED."SortOrder",
        "IsActive" = true,
        "ModuleId" = NULL,
        "SubModuleId" = NULL,
        "TabId" = health_tab_id,
        "UpdatedAtUtc" = NOW();

    -- 4. Appreciation
    INSERT INTO master.mst_tabs ("Id", "Code", "Name", "SortOrder", "IsActive", "ModuleId", "SubModuleId", "TabId", "CreatedAtUtc")
    VALUES ('c1a11111-0002-4000-8000-000000000004', 'health-appreciation', 'Appreciation', 40, true, NULL, NULL, health_tab_id, NOW())
    ON CONFLICT ("Code") DO UPDATE 
    SET "Name" = EXCLUDED."Name",
        "SortOrder" = EXCLUDED."SortOrder",
        "IsActive" = true,
        "ModuleId" = NULL,
        "SubModuleId" = NULL,
        "TabId" = health_tab_id,
        "UpdatedAtUtc" = NOW();

    -- 5. Customer Engagement
    INSERT INTO master.mst_tabs ("Id", "Code", "Name", "SortOrder", "IsActive", "ModuleId", "SubModuleId", "TabId", "CreatedAtUtc")
    VALUES ('c1a11111-0002-4000-8000-000000000005', 'health-customer-engagement', 'Customer Engagement', 50, true, NULL, NULL, health_tab_id, NOW())
    ON CONFLICT ("Code") DO UPDATE 
    SET "Name" = EXCLUDED."Name",
        "SortOrder" = EXCLUDED."SortOrder",
        "IsActive" = true,
        "ModuleId" = NULL,
        "SubModuleId" = NULL,
        "TabId" = health_tab_id,
        "UpdatedAtUtc" = NOW();

    -- 6. Extension Request
    INSERT INTO master.mst_tabs ("Id", "Code", "Name", "SortOrder", "IsActive", "ModuleId", "SubModuleId", "TabId", "CreatedAtUtc")
    VALUES ('c1a11111-0002-4000-8000-000000000006', 'health-extension-request', 'Extension Request', 60, true, NULL, NULL, health_tab_id, NOW())
    ON CONFLICT ("Code") DO UPDATE 
    SET "Name" = EXCLUDED."Name",
        "SortOrder" = EXCLUDED."SortOrder",
        "IsActive" = true,
        "ModuleId" = NULL,
        "SubModuleId" = NULL,
        "TabId" = health_tab_id,
        "UpdatedAtUtc" = NOW();

    RAISE NOTICE 'Health sub-tabs upserted successfully.';
END $$;
```

---

## 3. Merge Precautions & Database Constraints

> [!IMPORTANT]
> **Check Constraint `CK_mst_tabs_OneParent`**:
> In `master.mst_tabs`, each row **must have exactly one parent**:
> - If `TabId` is populated (sub-tab), `ModuleId` **MUST BE NULL** and `SubModuleId` **MUST BE NULL**.
> - Attempting to set `ModuleId` or `SubModuleId` alongside `TabId` will violate `"CK_mst_tabs_OneParent"` and fail the transaction.

> [!WARNING]
> **Unique Index on `Code` (`IX_mst_tabs_Code`)**:
> `Code` is globally unique across `master.mst_tabs`. Do not reuse codes like `alerts` (which belongs to Action Center `5b828ae3-0b45-4a1c-a1cb-78b29e882cf3`). The Health sub-tab uses `health-alerts`.

> [!NOTE]
> **Clean Slate Architecture**:
> Permissions for these tabs are stored in `auth.tbl_role_permissions` using `ItemId = <TabId>` and `ItemType = 'tab'`. Do not reintroduce any legacy permission tables or JSON matrices.

---

## 4. Verification Query
To verify the linkages in your database:

```sql
SELECT 
    t."Id",
    t."Code",
    t."Name",
    t."SortOrder",
    t."IsActive",
    t."TabId" as "ParentTabId",
    p."Name" as "ParentName"
FROM master.mst_tabs t
LEFT JOIN master.mst_tabs p ON t."TabId" = p."Id"
WHERE t."TabId" = 'c1a11111-0001-4000-8000-000000000005'
ORDER BY t."SortOrder";
```
Expected output: 6 rows (Issues, Alerts, Escalations, Appreciation, Customer Engagement, Extension Request) with `ParentName = 'Health'`.
