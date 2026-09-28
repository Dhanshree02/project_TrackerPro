# Database Changes — Projects Module

> **Author**: Sahil (branch `sahil-project-backend`)
> **Started**: 2026-09-14
> **Local DB**: `localhost:5432 / trackerpro` (PostgreSQL)
> **Target DB**: Docker shared DB at `10.50.30.189:5432 / trackerpro`
> **Status**: 🟡 Work in Progress

---

## Purpose

This file tracks **every database change** made on the local database while working from home on the **Projects module**. When the module is complete and the team is back on the shared Docker database, use this file to:

1. Review all schema changes at a glance.
2. Create the corresponding EF Core migration(s) for the shared DB.
3. Verify nothing was missed during the merge.

---

## Rules & Conventions (follow these while editing)

> [!IMPORTANT]
> **Every** table/column/index/constraint/seed-data change MUST be logged here before or immediately after you apply it locally.

| # | Rule | Why |
|---|------|-----|
| 1 | One entry per change — never batch unrelated changes | Makes code review and rollback trivial |
| 2 | Use the exact PostgreSQL table & column names (snake_case for tables, PascalCase quoted for columns) | Matches EF Core conventions used in this project |
| 3 | Include the full `CREATE TABLE` / `ALTER TABLE` SQL in the entry | So anyone can replay it manually or generate a migration |
| 4 | Mark every entry with a status: `📝 Planned`, `✅ Applied Locally`, `🚀 Merged to Docker` | Easy progress tracking |
| 5 | All tables must inherit `BaseEntity` columns (`Id` UUID PK, `CreatedAtUtc`, `UpdatedAtUtc`, `CreatedBy`, `UpdatedBy`, `DeletedAtUtc`) | Project-wide convention — see `Shared/Common/Models/BaseEntity.cs` |
| 6 | Add a `Down` (rollback) SQL for every `Up` SQL | Required by EF Core migration pattern |
| 7 | Reference the EF migration file name once it is created | Links this doc to the actual migration code |

---

## Change Log

<!-- ─────────────────────────────────────────────────────── -->
### Change #1 — Service Hierarchy Master Tables (`mst_service_groups`, `mst_service_departments`, `mst_service_sub_departments`, `mst_service_catalog`)

| Field | Value |
|-------|-------|
| **Date** | 2026-09-14 |
| **Status** | ✅ Applied Locally |
| **Migration file** | `20260914182626_AddServiceCatalogMasterTables.cs` |
| **Affects** | 4 New Master Tables + Seed Data |

#### Up SQL

```sql
CREATE TABLE IF NOT EXISTS mst_service_groups (
    "Id" uuid NOT NULL,
    "Code" character varying(40) NOT NULL,
    "Name" character varying(100) NOT NULL,
    "IsActive" boolean NOT NULL DEFAULT true,
    "SortOrder" integer NOT NULL DEFAULT 0,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_mst_service_groups" PRIMARY KEY ("Id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_groups_Code" ON mst_service_groups ("Code");
CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_groups_Name" ON mst_service_groups ("Name");

CREATE TABLE IF NOT EXISTS mst_service_departments (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "GroupId" uuid NOT NULL,
    "IsActive" boolean NOT NULL DEFAULT true,
    "SortOrder" integer NOT NULL DEFAULT 0,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_mst_service_departments" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_mst_service_departments_mst_service_groups_GroupId"
        FOREIGN KEY ("GroupId") REFERENCES mst_service_groups ("Id") ON DELETE RESTRICT
);
CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_departments_Code" ON mst_service_departments ("Code");
CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_departments_Name" ON mst_service_departments ("Name");
CREATE INDEX IF NOT EXISTS "IX_mst_service_departments_GroupId" ON mst_service_departments ("GroupId");

CREATE TABLE IF NOT EXISTS mst_service_sub_departments (
    "Id" uuid NOT NULL,
    "Code" character varying(120) NOT NULL,
    "Name" character varying(200) NOT NULL,
    "DepartmentId" uuid NOT NULL,
    "IsActive" boolean NOT NULL DEFAULT true,
    "SortOrder" integer NOT NULL DEFAULT 0,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_mst_service_sub_departments" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_mst_service_sub_departments_mst_service_departments_DepartmentId"
        FOREIGN KEY ("DepartmentId") REFERENCES mst_service_departments ("Id") ON DELETE CASCADE
);
CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_sub_departments_Code" ON mst_service_sub_departments ("Code");
CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_sub_departments_DepartmentId_Name" ON mst_service_sub_departments ("DepartmentId", "Name");

CREATE TABLE IF NOT EXISTS mst_service_catalog (
    "Id" uuid NOT NULL,
    "Code" character varying(50) NOT NULL,
    "Name" character varying(255) NOT NULL,
    "SubDepartmentId" uuid NOT NULL,
    "DefaultTools" character varying(500),
    "DefaultUnitPrice" numeric(18,2),
    "DefaultDurationDays" integer,
    "Description" text,
    "IsActive" boolean NOT NULL DEFAULT true,
    "SortOrder" integer NOT NULL DEFAULT 0,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_mst_service_catalog" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_mst_service_catalog_mst_service_sub_departments_SubDepartmentId"
        FOREIGN KEY ("SubDepartmentId") REFERENCES mst_service_sub_departments ("Id") ON DELETE CASCADE
);
CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_catalog_Code" ON mst_service_catalog ("Code");
CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_catalog_SubDepartmentId_Name" ON mst_service_catalog ("SubDepartmentId", "Name");
```

#### Down SQL

```sql
DROP TABLE IF EXISTS mst_service_catalog;
DROP TABLE IF EXISTS mst_service_sub_departments;
DROP TABLE IF EXISTS mst_service_departments;
DROP TABLE IF EXISTS mst_service_groups;
```

#### Notes

- Establishes the 4-tier service taxonomy: `Group (Resource/Scope)` → `Department (10 depts)` → `SubDepartment (31 sub-depts)` → `ServiceCatalog (33 services)`.
- Pre-seeded with exact values from frontend `DEPT_SERVICES` / `DEPT_GROUPS`.

---

<!-- ─────────────────────────────────────────────────────── -->
### Change #2 — `projects` table (core project record)

| Field | Value |
|-------|-------|
| **Date** | 2026-09-14 |
| **Status** | ✅ Applied Locally |
| **Migration file** | `20260914183236_AddProjectsTable.cs` |
| **Affects** | New Table (`projects`) |

#### Up SQL

```sql
CREATE TABLE IF NOT EXISTS projects (
    "Id" uuid NOT NULL,
    "ProjectCode" character varying(50) NOT NULL,
    "WbsId" character varying(80),
    "Name" character varying(255) NOT NULL,
    "Description" text,
    "ClientId" uuid NOT NULL,
    "SubVentureId" uuid,
    "Status" character varying(40) NOT NULL,
    "Health" character varying(20) NOT NULL,
    "Progress" integer NOT NULL,
    "ContractType" character varying(80),
    "ProjectType" character varying(80),
    "Currency" character varying(10) NOT NULL,
    "TaxPercent" numeric(5,2) NOT NULL,
    "StartDate" date,
    "EndDate" date,
    "Budget" numeric(18,2),
    "Spent" numeric(18,2) NOT NULL,
    "TotalHours" numeric(10,2),
    "TotalDays" numeric(10,2),
    "InvoiceValue" numeric(18,2),
    "ProjectManagerId" uuid,
    "TeamLeadId" uuid,
    "EngagementManager" character varying(150),
    "EngagementManagerId" uuid,
    "SalesPerson" character varying(150),
    "SalesPersonId" uuid,
    "ProjectIssuedDate" date,
    "SectionAComments" text,
    "SectionBComments" text,
    "WbsStatus" character varying(40) NOT NULL,
    "WbsSubStatus" character varying(80),
    "RenewedFromProjectId" uuid,
    "PoStatus" character varying(40),
    "PoNumber" character varying(80),
    "PoDate" date,
    "BillingModel" character varying(80),
    "PaymentTerms" character varying(120),
    "TargetDate" date,
    "AccountContactName" character varying(150),
    "AccountContactPhone" character varying(40),
    "AccountContactEmail" character varying(255),
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_projects" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_projects_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES clients ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_projects_sub_ventures_SubVentureId" FOREIGN KEY ("SubVentureId") REFERENCES sub_ventures ("Id") ON DELETE SET NULL,
    CONSTRAINT "FK_projects_employees_ProjectManagerId" FOREIGN KEY ("ProjectManagerId") REFERENCES employees ("Id") ON DELETE SET NULL,
    CONSTRAINT "FK_projects_employees_TeamLeadId" FOREIGN KEY ("TeamLeadId") REFERENCES employees ("Id") ON DELETE SET NULL,
    CONSTRAINT "FK_projects_employees_EngagementManagerId" FOREIGN KEY ("EngagementManagerId") REFERENCES employees ("Id") ON DELETE SET NULL,
    CONSTRAINT "FK_projects_employees_SalesPersonId" FOREIGN KEY ("SalesPersonId") REFERENCES employees ("Id") ON DELETE SET NULL,
    CONSTRAINT "FK_projects_projects_RenewedFromProjectId" FOREIGN KEY ("RenewedFromProjectId") REFERENCES projects ("Id") ON DELETE SET NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS "IX_projects_ProjectCode" ON projects ("ProjectCode");
CREATE UNIQUE INDEX IF NOT EXISTS "IX_projects_WbsId" ON projects ("WbsId");
CREATE INDEX IF NOT EXISTS "IX_projects_ClientId" ON projects ("ClientId");
CREATE INDEX IF NOT EXISTS "IX_projects_SubVentureId" ON projects ("SubVentureId");
CREATE INDEX IF NOT EXISTS "IX_projects_Status" ON projects ("Status");
CREATE INDEX IF NOT EXISTS "IX_projects_WbsStatus" ON projects ("WbsStatus");
CREATE INDEX IF NOT EXISTS "IX_projects_ProjectManagerId" ON projects ("ProjectManagerId");
CREATE INDEX IF NOT EXISTS "IX_projects_RenewedFromProjectId" ON projects ("RenewedFromProjectId");
```

#### Down SQL

```sql
DROP TABLE IF EXISTS projects;
```

---

<!-- ─────────────────────────────────────────────────────── -->
### Change #3 — `project_services` & `project_service_resource_levels`

| Field | Value |
|-------|-------|
| **Date** | 2026-09-14 |
| **Status** | ✅ Applied Locally |
| **Migration file** | `20260914184206_AddProjectServicesAndResourceLevels.cs` |
| **Affects** | 2 New Tables (`project_services`, `project_service_resource_levels`) |

#### Up SQL

```sql
CREATE TABLE IF NOT EXISTS project_services (
    "Id" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "ServiceCatalogId" uuid,
    "TaskId" character varying(50),
    "Department" character varying(150) NOT NULL,
    "SubDepartment" character varying(200),
    "ServiceName" character varying(255) NOT NULL,
    "Qty" integer NOT NULL,
    "Description" text,
    "ResourceLevel" character varying(80),
    "Frequency" character varying(40),
    "Location" character varying(40),
    "LocationText" character varying(200),
    "ServiceModel" character varying(40),
    "DeliveryModel" character varying(80),
    "FinalDeliveryFormat" character varying(120),
    "BillingModel" character varying(80),
    "Tools" character varying(500),
    "StartDate" date,
    "EndDate" date,
    "DurationDays" integer,
    "DurationHours" integer,
    "TotalDays" integer,
    "TotalHours" integer,
    "UnitPrice" numeric(18,2),
    "Total" numeric(18,2),
    "SortOrder" integer NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_project_services" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_project_services_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES projects ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_project_services_mst_service_catalog_ServiceCatalogId" FOREIGN KEY ("ServiceCatalogId") REFERENCES mst_service_catalog ("Id") ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS "IX_project_services_ProjectId" ON project_services ("ProjectId");
CREATE INDEX IF NOT EXISTS "IX_project_services_ServiceCatalogId" ON project_services ("ServiceCatalogId");

CREATE TABLE IF NOT EXISTS project_service_resource_levels (
    "Id" uuid NOT NULL,
    "ProjectServiceId" uuid NOT NULL,
    "Level" character varying(20) NOT NULL,
    "Count" integer NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_project_service_resource_levels" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_project_service_resource_levels_project_services_ProjectServiceId" FOREIGN KEY ("ProjectServiceId") REFERENCES project_services ("Id") ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS "IX_project_service_resource_levels_ProjectServiceId_Level" ON project_service_resource_levels ("ProjectServiceId", "Level");
```

#### Down SQL

```sql
DROP TABLE IF EXISTS project_service_resource_levels;
DROP TABLE IF EXISTS project_services;
```

---

<!-- ─────────────────────────────────────────────────────── -->
### Change #4 — `project_tasks`

| Field | Value |
|-------|-------|
| **Date** | 2026-09-14 |
| **Status** | ✅ Applied Locally |
| **Migration file** | `20260914185548_AddProjectTasks.cs` |
| **Affects** | New Table (`project_tasks`) |

#### Up SQL

```sql
CREATE TABLE IF NOT EXISTS project_tasks (
    "Id" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "ProjectServiceId" uuid,
    "Title" character varying(255) NOT NULL,
    "Description" text,
    "Period" character varying(40),
    "Phase" character varying(80),
    "Stage" character varying(60) NOT NULL,
    "Priority" character varying(20) NOT NULL,
    "PlannedStartDate" date,
    "PlannedEndDate" date,
    "ActualStartDate" date,
    "ActualEndDate" date,
    "EstimatedHours" numeric(10,2),
    "UtilizedHours" numeric(10,2) NOT NULL,
    "Progress" integer NOT NULL,
    "SortOrder" integer NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_project_tasks" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_project_tasks_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES projects ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_project_tasks_project_services_ProjectServiceId" FOREIGN KEY ("ProjectServiceId") REFERENCES project_services ("Id") ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS "IX_project_tasks_ProjectId" ON project_tasks ("ProjectId");
CREATE INDEX IF NOT EXISTS "IX_project_tasks_ProjectServiceId" ON project_tasks ("ProjectServiceId");
CREATE INDEX IF NOT EXISTS "IX_project_tasks_Stage" ON project_tasks ("Stage");
CREATE INDEX IF NOT EXISTS "IX_project_tasks_Priority" ON project_tasks ("Priority");
```

#### Down SQL

```sql
DROP TABLE IF EXISTS project_tasks;
```

---

<!-- ─────────────────────────────────────────────────────── -->
### Change #5 — `project_task_assignments`

| Field | Value |
|-------|-------|
| **Date** | 2026-09-14 |
| **Status** | ✅ Applied Locally |
| **Migration file** | `20260914190035_AddProjectTaskAssignments.cs` |
| **Affects** | New Table (`project_task_assignments`) |

#### Up SQL

```sql
CREATE TABLE IF NOT EXISTS project_task_assignments (
    "Id" uuid NOT NULL,
    "TaskId" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "Role" character varying(50) NOT NULL,
    "AllocatedHours" numeric(10,2),
    "UtilizedHours" numeric(10,2) NOT NULL,
    "TimerStartedAtUtc" timestamp with time zone,
    "TimerAccumulatedSeconds" bigint NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_project_task_assignments" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_project_task_assignments_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES employees ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_project_task_assignments_project_tasks_TaskId" FOREIGN KEY ("TaskId") REFERENCES project_tasks ("Id") ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS "IX_project_task_assignments_EmployeeId" ON project_task_assignments ("EmployeeId");
CREATE INDEX IF NOT EXISTS "IX_project_task_assignments_TaskId" ON project_task_assignments ("TaskId");
CREATE INDEX IF NOT EXISTS "IX_project_task_assignments_TaskId_EmployeeId" ON project_task_assignments ("TaskId", "EmployeeId");
```

#### Down SQL

```sql
DROP TABLE IF EXISTS project_task_assignments;
```

---

<!-- ─────────────────────────────────────────────────────── -->
### Change #6 — `project_invoices`

| Field | Value |
|-------|-------|
| **Date** | 2026-09-14 |
| **Status** | ✅ Applied Locally |
| **Migration file** | `20260914190330_AddProjectInvoices.cs` |
| **Affects** | New Table (`project_invoices`) |

#### Up SQL

```sql
CREATE TABLE IF NOT EXISTS project_invoices (
    "Id" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "MilestoneName" character varying(255) NOT NULL,
    "Percentage" numeric(5,2),
    "Amount" numeric(18,2) NOT NULL,
    "TaxAmount" numeric(18,2) NOT NULL,
    "TotalAmount" numeric(18,2) NOT NULL,
    "Status" character varying(40) NOT NULL,
    "InvoiceNumber" character varying(80),
    "InvoiceDate" date,
    "DueDate" date,
    "PaymentDate" date,
    "Remarks" text,
    "SortOrder" integer NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_project_invoices" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_project_invoices_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES projects ("Id") ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS "IX_project_invoices_InvoiceNumber" ON project_invoices ("InvoiceNumber");
CREATE INDEX IF NOT EXISTS "IX_project_invoices_ProjectId" ON project_invoices ("ProjectId");
CREATE INDEX IF NOT EXISTS "IX_project_invoices_Status" ON project_invoices ("Status");
```

#### Down SQL

```sql
DROP TABLE IF EXISTS project_invoices;
```

---

<!-- ─────────────────────────────────────────────────────── -->
### Change #7 — `project_documents`

| Field | Value |
|-------|-------|
| **Date** | 2026-09-14 |
| **Status** | ✅ Applied Locally |
| **Migration file** | `20260914190750_AddProjectDocuments.cs` |
| **Affects** | New Table (`project_documents`) |

#### Up SQL

```sql
CREATE TABLE IF NOT EXISTS project_documents (
    "Id" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "DocumentType" character varying(80) NOT NULL,
    "FileName" character varying(255) NOT NULL,
    "OriginalFileName" character varying(255) NOT NULL,
    "FilePath" character varying(500) NOT NULL,
    "ContentType" character varying(120) NOT NULL,
    "SizeBytes" bigint NOT NULL,
    "Description" text,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_project_documents" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_project_documents_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES projects ("Id") ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS "IX_project_documents_DocumentType" ON project_documents ("DocumentType");
CREATE INDEX IF NOT EXISTS "IX_project_documents_ProjectId" ON project_documents ("ProjectId");
```

#### Down SQL

```sql
DROP TABLE IF EXISTS project_documents;
```

---


## Merge Checklist (use when switching back to Docker DB)




- [ ] Review every `✅ Applied Locally` entry above
- [ ] Create EF Core migration(s) under `apps/backend/Migrations/`
  ```powershell
  dotnet ef migrations add <MigrationName> --project "apps/backend/PMS.API.csproj" --startup-project "apps/backend/PMS.API.csproj"
  ```
- [ ] Register new `DbSet<>` properties in [`AppDbContext.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Infrastructure/Persistence/AppDbContext.cs)
- [ ] Add entity configuration in `Infrastructure/Persistence/Configurations/`
- [ ] Update [`STRUCTURE.md`](file:///d:/Project%20Compass/project_TrackerPro/database/STRUCTURE.md) — move "projects" from Deferred to Implemented
- [ ] Switch `.env` connection string back to Docker host (`10.50.30.189`)
- [ ] Run `dotnet ef database update` against Docker DB
- [ ] Mark all entries above as `🚀 Merged to Docker`
- [ ] Notify the team in the group chat

---

## Reference

| Resource | Path |
|----------|------|
| EF Migrations | [`apps/backend/Migrations/`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Migrations) |
| DbContext | [`AppDbContext.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Infrastructure/Persistence/AppDbContext.cs) |
| Entity Configs | [`Infrastructure/Persistence/Configurations/`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Infrastructure/Persistence/Configurations) |
| Base Entity | [`BaseEntity.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Shared/Common/Models/BaseEntity.cs) |
| Schema Map | [`database/STRUCTURE.md`](file:///d:/Project%20Compass/project_TrackerPro/database/STRUCTURE.md) |
| Docker DB Guide | [`DOCKER_GUIDE.md`](file:///d:/Project%20Compass/project_TrackerPro/DOCKER_GUIDE.md) |
| Local `.env` | [`.env`](file:///d:/Project%20Compass/project_TrackerPro/.env) |
