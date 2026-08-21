# TrackerPro Backend — Cursor Implementation Spec

> **Hand this file to Cursor and say: "Implement everything in this spec exactly as written."**
> Every file path, class name, property, and SQL mapping is final. Do not invent anything new.

---

## Project Context

- **Solution root**: `apps/backend/`
- **API project**: `apps/backend/TrackerPro.Api/`
- **Framework**: ASP.NET Core 10, EF Core 10, Npgsql, `UseSnakeCaseNamingConvention()`
- **Database**: PostgreSQL. Schema already exists via `apps/backend/db/01_schema.sql`. **Do NOT generate migrations.**
- **Naming convention**: EF is configured with `.UseSnakeCaseNamingConvention()` — all PascalCase C# names auto-map to snake_case DB columns. Only override with `HasColumnName()` when the auto-conversion would be wrong.

---

## What Already Exists — DO NOT TOUCH

Keep these files exactly as-is unless this spec says to replace them:

- `Program.cs` — already wires DbContext, CORS, OpenAPI
- `appsettings.json`, `appsettings.Development.json` — connection string is set
- `Controllers/HealthController.cs` — keep as-is
- `Controllers/RolesController.cs` — keep as-is
- `Controllers/UsersController.cs` — keep as-is

---

## Step 1 — REPLACE `Entities/DomainEntities.cs`

Replace the entire file with the content below. This file contains **all 32 entity classes** matching the PostgreSQL schema.

**File**: `apps/backend/TrackerPro.Api/Entities/DomainEntities.cs`

```csharp
namespace TrackerPro.Api.Entities;

// ── MASTER TABLES ─────────────────────────────────────────────────────────

public class MstLookup
{
    public Guid Id { get; set; }
    public string GroupCode { get; set; } = "";
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}

public class MstRole
{
    public Guid Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public string ProjectScope { get; set; } = "involved";
    public bool IsSystem { get; set; }
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public ICollection<MstRolePermission> RolePermissions { get; set; } = new List<MstRolePermission>();
    public ICollection<AppUser> Users { get; set; } = new List<AppUser>();
}

public class MstPermission
{
    public Guid Id { get; set; }
    public string Key { get; set; } = "";
    public string Module { get; set; } = "";
    public string Grp { get; set; } = "";
    public string Label { get; set; } = "";
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public ICollection<MstRolePermission> RolePermissions { get; set; } = new List<MstRolePermission>();
}

public class MstRolePermission
{
    public Guid RoleId { get; set; }
    public Guid PermissionId { get; set; }
    public DateTimeOffset GrantedAt { get; set; }
    public MstRole Role { get; set; } = null!;
    public MstPermission Permission { get; set; } = null!;
}

public class MstDepartment
{
    public Guid Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}

public class MstDesignation
{
    public Guid Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}

public class MstIndustry
{
    public Guid Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}

public class MstCurrency
{
    public Guid Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public string Symbol { get; set; } = "";
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}

public class MstServiceDepartment
{
    public Guid Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public string GroupType { get; set; } = "Scope";
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public ICollection<MstService> Services { get; set; } = new List<MstService>();
}

public class MstService
{
    public Guid Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public Guid ServiceDepartmentId { get; set; }
    public string? DefaultTools { get; set; }
    public decimal DefaultUnitPrice { get; set; }
    public int DefaultDays { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public MstServiceDepartment ServiceDepartment { get; set; } = null!;
}

public class MstSkill
{
    public Guid Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}

public class MstRepositoryCategory
{
    public Guid Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public string? Description { get; set; }
    public string? IconName { get; set; }
    public string? AccentColor { get; set; }
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}

public class MstBillingModel
{
    public Guid Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public string ProjectType { get; set; } = "";
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}

// ── IDENTITY ──────────────────────────────────────────────────────────────

public class Employee
{
    public Guid Id { get; set; }
    public string EmployeeCode { get; set; } = "";
    public string FirstName { get; set; } = "";
    public string LastName { get; set; } = "";
    public string Email { get; set; } = "";
    public string? PersonalEmail { get; set; }
    public string? Phone { get; set; }
    public string? Gender { get; set; }
    public DateOnly? DateOfBirth { get; set; }
    public Guid? DepartmentId { get; set; }
    public Guid? DesignationId { get; set; }
    public Guid? ReportingManagerId { get; set; }
    public string? WorkLocation { get; set; }
    public string? EmploymentCategory { get; set; }
    public DateOnly? JoiningDate { get; set; }
    public string Status { get; set; } = "Active";
    public string? ProjectSite { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public DateTimeOffset? DeletedAt { get; set; }
    public MstDepartment? Department { get; set; }
    public MstDesignation? Designation { get; set; }
    public Employee? ReportingManager { get; set; }
    public AppUser? User { get; set; }
    public ICollection<EmployeeSkill> EmployeeSkills { get; set; } = new List<EmployeeSkill>();
}

public class EmployeeSkill
{
    public Guid EmployeeId { get; set; }
    public Guid SkillId { get; set; }
    public Employee Employee { get; set; } = null!;
    public MstSkill Skill { get; set; } = null!;
}

public class AppUser
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid RoleId { get; set; }
    public string Email { get; set; } = "";
    public string DisplayName { get; set; } = "";
    public string? PasswordHash { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset? LastLoginAt { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Employee Employee { get; set; } = null!;
    public MstRole Role { get; set; } = null!;
}

// ── CUSTOMERS ─────────────────────────────────────────────────────────────

public class Customer
{
    public Guid Id { get; set; }
    public string CustomerCode { get; set; } = "";
    public string Name { get; set; } = "";
    public string? CompanyName { get; set; }
    public Guid? IndustryId { get; set; }
    public string? LogoInitials { get; set; }
    public string CustomerType { get; set; } = "NEW";
    public Guid? EngagementManagerId { get; set; }
    public string Status { get; set; } = "active";
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public DateTimeOffset? DeletedAt { get; set; }
    public MstIndustry? Industry { get; set; }
    public Employee? EngagementManager { get; set; }
    public ICollection<Project> Projects { get; set; } = new List<Project>();
    public ICollection<CustomerContact> Contacts { get; set; } = new List<CustomerContact>();
    public ICollection<CustomerSubVenture> SubVentures { get; set; } = new List<CustomerSubVenture>();
}

public class CustomerContact
{
    public Guid Id { get; set; }
    public Guid CustomerId { get; set; }
    public string Name { get; set; } = "";
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public string? Designation { get; set; }
    public string? ContactType { get; set; }
    public bool IsPrimary { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Customer Customer { get; set; } = null!;
}

public class CustomerSubVenture
{
    public Guid Id { get; set; }
    public Guid CustomerId { get; set; }
    public string Name { get; set; } = "";
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public Customer Customer { get; set; } = null!;
}

// ── PROJECTS ──────────────────────────────────────────────────────────────

public class Project
{
    public Guid Id { get; set; }
    public string ProjectCode { get; set; } = "";
    public string? WbsId { get; set; }
    public string Name { get; set; } = "";
    public Guid CustomerId { get; set; }
    public Guid? SubVentureId { get; set; }
    public string Status { get; set; } = "ongoing";
    public string Health { get; set; } = "green";
    public int Progress { get; set; }
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public decimal Budget { get; set; }
    public decimal Spent { get; set; }
    public Guid? CurrencyId { get; set; }
    public string? ContractType { get; set; }
    public string? ProjectType { get; set; }
    public Guid? BillingModelId { get; set; }
    public Guid? SalesPersonId { get; set; }
    public string? Description { get; set; }
    public decimal TaxPercent { get; set; } = 18;
    public string? WbsStatus { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public DateTimeOffset? DeletedAt { get; set; }
    public Customer Customer { get; set; } = null!;
    public MstCurrency? Currency { get; set; }
    public CustomerSubVenture? SubVenture { get; set; }
    public Employee? SalesPerson { get; set; }
    public ICollection<ProjectLeadership> Leadership { get; set; } = new List<ProjectLeadership>();
    public ICollection<ProjectTeamMember> TeamMembers { get; set; } = new List<ProjectTeamMember>();
    public ICollection<ProjectService> Services { get; set; } = new List<ProjectService>();
    public ICollection<ProjectStage> Stages { get; set; } = new List<ProjectStage>();
    public ICollection<ProjectPurchaseOrder> PurchaseOrders { get; set; } = new List<ProjectPurchaseOrder>();
    public ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();
    public ICollection<AppTask> Tasks { get; set; } = new List<AppTask>();
    public ICollection<Issue> Issues { get; set; } = new List<Issue>();
    public ICollection<Alert> Alerts { get; set; } = new List<Alert>();
    public ICollection<Appreciation> Appreciations { get; set; } = new List<Appreciation>();
    public ICollection<Interview> Interviews { get; set; } = new List<Interview>();
    public ICollection<AdditionalRequirement> AdditionalRequirements { get; set; } = new List<AdditionalRequirement>();
}

public class ProjectLeadership
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public string RoleCode { get; set; } = "";
    public Guid EmployeeId { get; set; }
    public bool IsPrimary { get; set; } = true;
    public DateTimeOffset AssignedAt { get; set; }
    public Project Project { get; set; } = null!;
    public Employee Employee { get; set; } = null!;
}

public class ProjectTeamMember
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public Guid EmployeeId { get; set; }
    public string TeamType { get; set; } = "primary";
    public string Billability { get; set; } = "Billable";
    public string ResourceType { get; set; } = "Fixed";
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public Project Project { get; set; } = null!;
    public Employee Employee { get; set; } = null!;
}

public class ProjectService
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public Guid ServiceId { get; set; }
    public int Qty { get; set; } = 1;
    public string? ResourceLevel { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public int? DurationDays { get; set; }
    public int? DurationHours { get; set; }
    public decimal? UnitPrice { get; set; }
    public decimal? LineTotal { get; set; }
    public string? BillingModel { get; set; }
    public string? DeliveryModel { get; set; }
    public int SortOrder { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Project Project { get; set; } = null!;
    public MstService Service { get; set; } = null!;
    public ProjectServicePrereq? Prereq { get; set; }
}

public class ProjectServicePrereq
{
    public Guid Id { get; set; }
    public Guid ProjectServiceId { get; set; }
    public string CollectionStatus { get; set; } = "Pending To Collect";
    public string ValidationStatus { get; set; } = "Pending To Validate";
    public string BillingStatus { get; set; } = "Advance Pending";
    public bool IsReady { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public ProjectService ProjectService { get; set; } = null!;
}

public class ProjectStage
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public string StageCode { get; set; } = "";
    public string CurrentStatus { get; set; } = "";
    public bool IsCompleted { get; set; }
    public bool IsActive { get; set; }
    public int SortOrder { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Project Project { get; set; } = null!;
}

public class ProjectPurchaseOrder
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public string? PoNumber { get; set; }
    public DateOnly? PoDate { get; set; }
    public string PoStatus { get; set; } = "PO Pending";
    public string? FileName { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Project Project { get; set; } = null!;
}

public class Invoice
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public Guid? ProjectServiceId { get; set; }
    public string Milestone { get; set; } = "";
    public DateOnly? InvoiceTargetDate { get; set; }
    public decimal? UnitPrice { get; set; }
    public int? Qty { get; set; }
    public decimal? Amount { get; set; }
    public string? InvoiceNumber { get; set; }
    public string InvoiceStatus { get; set; } = "Not Raised";
    public string PaymentStatus { get; set; } = "Not Received";
    public DateOnly? PaymentReceivedDate { get; set; }
    public string? ResourceLevel { get; set; }
    public Guid? RaisedById { get; set; }
    public DateTimeOffset? RaisedAt { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Project Project { get; set; } = null!;
    public Employee? RaisedBy { get; set; }
}

// ── DELIVERY ──────────────────────────────────────────────────────────────

// Named AppTask to avoid conflict with System.Threading.Tasks.Task
public class AppTask
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public Guid? ProjectServiceId { get; set; }
    public string Title { get; set; } = "";
    public string Status { get; set; } = "todo";
    public string? Stage { get; set; }
    public DateOnly? DueDate { get; set; }
    public int Progress { get; set; }
    public decimal? EstimatedHours { get; set; }
    public decimal? UtilizedHours { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Project Project { get; set; } = null!;
    public ICollection<TaskAssignee> Assignees { get; set; } = new List<TaskAssignee>();
    public ICollection<BucketTask> BucketTasks { get; set; } = new List<BucketTask>();
}

public class TaskAssignee
{
    public Guid TaskId { get; set; }
    public Guid EmployeeId { get; set; }
    public AppTask Task { get; set; } = null!;
    public Employee Employee { get; set; } = null!;
}

public class BucketTask
{
    public Guid Id { get; set; }
    public Guid TaskId { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid? AssignedById { get; set; }
    public string Status { get; set; } = "Not Started";
    public string Priority { get; set; } = "medium";
    public DateOnly? DueDate { get; set; }
    public int ElapsedSeconds { get; set; }
    public bool TimerRunning { get; set; }
    public DateTimeOffset? StartedAt { get; set; }
    public DateTimeOffset? CompletedAt { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public AppTask Task { get; set; } = null!;
    public Employee Employee { get; set; } = null!;
    public Employee? AssignedBy { get; set; }
}

public class Timesheet
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public DateOnly WeekStart { get; set; }
    public string Status { get; set; } = "draft";
    public decimal TotalHours { get; set; }
    public DateTimeOffset? SubmittedAt { get; set; }
    public string? RejectionReason { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Employee Employee { get; set; } = null!;
    public ICollection<TimesheetEntry> Entries { get; set; } = new List<TimesheetEntry>();
}

public class TimesheetEntry
{
    public Guid Id { get; set; }
    public Guid TimesheetId { get; set; }
    public Guid ProjectId { get; set; }
    public Guid? TaskId { get; set; }
    // numeric(5,2)[7] in Postgres — Npgsql maps decimal[] natively
    public decimal[] Hours { get; set; } = Array.Empty<decimal>();
    public string? Note { get; set; }
    public Timesheet Timesheet { get; set; } = null!;
    public Project Project { get; set; } = null!;
    public AppTask? Task { get; set; }
}

// ── HEALTH / GOVERNANCE ───────────────────────────────────────────────────

public class Issue
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public string Title { get; set; } = "";
    public string? Description { get; set; }
    public string? Category { get; set; }
    public string Priority { get; set; } = "Medium";
    public string Status { get; set; } = "Open";
    public Guid? RaisedById { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Project Project { get; set; } = null!;
    public Employee? RaisedBy { get; set; }
}

public class Alert
{
    public Guid Id { get; set; }
    public Guid? ProjectId { get; set; }
    public string Title { get; set; } = "";
    public string Kind { get; set; } = "";
    public string Priority { get; set; } = "Medium";
    public string Status { get; set; } = "Open";
    public Guid? RaisedById { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Project? Project { get; set; }
    public Employee? RaisedBy { get; set; }
}

public class Appreciation
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public Guid ToEmployeeId { get; set; }
    public Guid? FromEmployeeId { get; set; }
    public string Badge { get; set; } = "";
    public string? Note { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public Project Project { get; set; } = null!;
    public Employee ToEmployee { get; set; } = null!;
    public Employee? FromEmployee { get; set; }
}

public class Interview
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public Guid ResourceId { get; set; }
    public DateOnly InterviewDate { get; set; }
    public string? InterviewTime { get; set; }
    public string? InterviewRound { get; set; }
    public string? Interviewer { get; set; }
    public string Status { get; set; } = "Pending";
    public string? Notes { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Project Project { get; set; } = null!;
    public Employee Resource { get; set; } = null!;
}

public class AdditionalRequirement
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public string Title { get; set; } = "";
    public string? Description { get; set; }
    public string Priority { get; set; } = "Medium";
    public string Status { get; set; } = "Open";
    public string? RequestedBy { get; set; }
    public DateOnly? RequestedDate { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Project Project { get; set; } = null!;
}

public class Approval
{
    public Guid Id { get; set; }
    public Guid? ProjectId { get; set; }
    public string RequestType { get; set; } = "";
    public Guid? RequestedById { get; set; }
    public string Status { get; set; } = "Pending";
    public string? Description { get; set; }
    public DateTimeOffset? AcknowledgedAt { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public Project? Project { get; set; }
    public Employee? RequestedBy { get; set; }
}

public class Notification
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public string Title { get; set; } = "";
    public string? Body { get; set; }
    public string Status { get; set; } = "Pending";
    public string? RefType { get; set; }
    public Guid? RefId { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public Employee Employee { get; set; } = null!;
}

public class Comment
{
    public Guid Id { get; set; }
    public string EntityType { get; set; } = "";
    public Guid EntityId { get; set; }
    public Guid? AuthorId { get; set; }
    public string Body { get; set; } = "";
    public DateTimeOffset CreatedAt { get; set; }
    public Employee? Author { get; set; }
}

// ── REPOSITORY ────────────────────────────────────────────────────────────

public class RepositoryDocument
{
    public Guid Id { get; set; }
    public Guid CategoryId { get; set; }
    public string Name { get; set; } = "";
    public string FileType { get; set; } = "";
    public long SizeBytes { get; set; }
    public Guid? UploadedBy { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public DateTimeOffset? DeletedAt { get; set; }
    public MstRepositoryCategory Category { get; set; } = null!;
    public Employee? Uploader { get; set; }
}

// ── AUDIT ─────────────────────────────────────────────────────────────────

public class AuditLog
{
    public Guid Id { get; set; }
    public string EntityType { get; set; } = "";
    public Guid EntityId { get; set; }
    public Guid? ActorId { get; set; }
    public string Action { get; set; } = "";
    public string? Details { get; set; } // JSONB column
    public DateTimeOffset CreatedAt { get; set; }
    public Employee? Actor { get; set; }
}
```

---

## Step 2 — REPLACE `Data/TrackerProDbContext.cs`

Replace the entire file. Maps all 32 entities to their correct PostgreSQL tables.

**File**: `apps/backend/TrackerPro.Api/Data/TrackerProDbContext.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Entities;

namespace TrackerPro.Api.Data;

public class TrackerProDbContext(DbContextOptions<TrackerProDbContext> options) : DbContext(options)
{
    // Master
    public DbSet<MstLookup> Lookups => Set<MstLookup>();
    public DbSet<MstRole> Roles => Set<MstRole>();
    public DbSet<MstPermission> Permissions => Set<MstPermission>();
    public DbSet<MstRolePermission> RolePermissions => Set<MstRolePermission>();
    public DbSet<MstDepartment> Departments => Set<MstDepartment>();
    public DbSet<MstDesignation> Designations => Set<MstDesignation>();
    public DbSet<MstIndustry> Industries => Set<MstIndustry>();
    public DbSet<MstCurrency> Currencies => Set<MstCurrency>();
    public DbSet<MstServiceDepartment> ServiceDepartments => Set<MstServiceDepartment>();
    public DbSet<MstService> Services => Set<MstService>();
    public DbSet<MstSkill> Skills => Set<MstSkill>();
    public DbSet<MstRepositoryCategory> RepositoryCategories => Set<MstRepositoryCategory>();
    public DbSet<MstBillingModel> BillingModels => Set<MstBillingModel>();
    // Identity
    public DbSet<Employee> Employees => Set<Employee>();
    public DbSet<EmployeeSkill> EmployeeSkills => Set<EmployeeSkill>();
    public DbSet<AppUser> Users => Set<AppUser>();
    // Customers
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<CustomerContact> CustomerContacts => Set<CustomerContact>();
    public DbSet<CustomerSubVenture> CustomerSubVentures => Set<CustomerSubVenture>();
    // Projects
    public DbSet<Project> Projects => Set<Project>();
    public DbSet<ProjectLeadership> ProjectLeadership => Set<ProjectLeadership>();
    public DbSet<ProjectTeamMember> ProjectTeamMembers => Set<ProjectTeamMember>();
    public DbSet<ProjectService> ProjectServices => Set<ProjectService>();
    public DbSet<ProjectServicePrereq> ProjectServicePrereqs => Set<ProjectServicePrereq>();
    public DbSet<ProjectStage> ProjectStages => Set<ProjectStage>();
    public DbSet<ProjectPurchaseOrder> PurchaseOrders => Set<ProjectPurchaseOrder>();
    public DbSet<Invoice> Invoices => Set<Invoice>();
    // Delivery
    public DbSet<AppTask> Tasks => Set<AppTask>();
    public DbSet<TaskAssignee> TaskAssignees => Set<TaskAssignee>();
    public DbSet<BucketTask> BucketTasks => Set<BucketTask>();
    public DbSet<Timesheet> Timesheets => Set<Timesheet>();
    public DbSet<TimesheetEntry> TimesheetEntries => Set<TimesheetEntry>();
    // Health / Governance
    public DbSet<Issue> Issues => Set<Issue>();
    public DbSet<Alert> Alerts => Set<Alert>();
    public DbSet<Appreciation> Appreciations => Set<Appreciation>();
    public DbSet<Interview> Interviews => Set<Interview>();
    public DbSet<AdditionalRequirement> AdditionalRequirements => Set<AdditionalRequirement>();
    public DbSet<Approval> Approvals => Set<Approval>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<Comment> Comments => Set<Comment>();
    // Repository & Audit
    public DbSet<RepositoryDocument> RepositoryDocuments => Set<RepositoryDocument>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();

    protected override void OnModelCreating(ModelBuilder m)
    {
        // Master
        m.Entity<MstLookup>(e => { e.ToTable("mst_lookup"); e.HasIndex(x => new { x.GroupCode, x.Code }).IsUnique(); });
        m.Entity<MstRole>(e => { e.ToTable("mst_role"); e.HasIndex(x => x.Code).IsUnique(); });
        m.Entity<MstPermission>(e => { e.ToTable("mst_permission"); e.HasIndex(x => x.Key).IsUnique(); e.Property(x => x.Grp).HasColumnName("grp"); });
        m.Entity<MstRolePermission>(e => {
            e.ToTable("mst_role_permission");
            e.HasKey(x => new { x.RoleId, x.PermissionId });
            e.HasOne(x => x.Role).WithMany(r => r.RolePermissions).HasForeignKey(x => x.RoleId);
            e.HasOne(x => x.Permission).WithMany(p => p.RolePermissions).HasForeignKey(x => x.PermissionId);
        });
        m.Entity<MstDepartment>(e => e.ToTable("mst_department"));
        m.Entity<MstDesignation>(e => e.ToTable("mst_designation"));
        m.Entity<MstIndustry>(e => e.ToTable("mst_industry"));
        m.Entity<MstCurrency>(e => e.ToTable("mst_currency"));
        m.Entity<MstServiceDepartment>(e => e.ToTable("mst_service_department"));
        m.Entity<MstService>(e => {
            e.ToTable("mst_service");
            e.Property(x => x.DefaultUnitPrice).HasPrecision(12, 2);
            e.HasOne(x => x.ServiceDepartment).WithMany(sd => sd.Services).HasForeignKey(x => x.ServiceDepartmentId);
        });
        m.Entity<MstSkill>(e => e.ToTable("mst_skill"));
        m.Entity<MstRepositoryCategory>(e => e.ToTable("mst_repository_category"));
        m.Entity<MstBillingModel>(e => e.ToTable("mst_billing_model"));

        // Identity
        m.Entity<Employee>(e => {
            e.ToTable("employee");
            e.HasQueryFilter(x => x.DeletedAt == null);
            e.HasOne(x => x.Department).WithMany().HasForeignKey(x => x.DepartmentId);
            e.HasOne(x => x.Designation).WithMany().HasForeignKey(x => x.DesignationId);
            e.HasOne(x => x.ReportingManager).WithMany().HasForeignKey(x => x.ReportingManagerId);
            e.HasOne(x => x.User).WithOne(u => u.Employee).HasForeignKey<AppUser>(u => u.EmployeeId);
        });
        m.Entity<EmployeeSkill>(e => {
            e.ToTable("employee_skill");
            e.HasKey(x => new { x.EmployeeId, x.SkillId });
            e.HasOne(x => x.Employee).WithMany(emp => emp.EmployeeSkills).HasForeignKey(x => x.EmployeeId);
            e.HasOne(x => x.Skill).WithMany().HasForeignKey(x => x.SkillId);
        });
        m.Entity<AppUser>(e => {
            e.ToTable("app_user");
            e.HasOne(x => x.Role).WithMany(r => r.Users).HasForeignKey(x => x.RoleId);
        });

        // Customers
        m.Entity<Customer>(e => {
            e.ToTable("customer");
            e.HasQueryFilter(x => x.DeletedAt == null);
            e.HasOne(x => x.Industry).WithMany().HasForeignKey(x => x.IndustryId);
            e.HasOne(x => x.EngagementManager).WithMany().HasForeignKey(x => x.EngagementManagerId);
        });
        m.Entity<CustomerContact>(e => { e.ToTable("customer_contact"); e.HasOne(x => x.Customer).WithMany(c => c.Contacts).HasForeignKey(x => x.CustomerId); });
        m.Entity<CustomerSubVenture>(e => { e.ToTable("customer_sub_venture"); e.HasOne(x => x.Customer).WithMany(c => c.SubVentures).HasForeignKey(x => x.CustomerId); });

        // Projects
        m.Entity<Project>(e => {
            e.ToTable("project");
            e.HasQueryFilter(x => x.DeletedAt == null);
            e.Property(x => x.Budget).HasPrecision(14, 2);
            e.Property(x => x.Spent).HasPrecision(14, 2);
            e.Property(x => x.TaxPercent).HasPrecision(5, 2);
            e.HasOne(x => x.Customer).WithMany(c => c.Projects).HasForeignKey(x => x.CustomerId);
            e.HasOne(x => x.Currency).WithMany().HasForeignKey(x => x.CurrencyId);
            e.HasOne(x => x.SubVenture).WithMany().HasForeignKey(x => x.SubVentureId);
            e.HasOne(x => x.SalesPerson).WithMany().HasForeignKey(x => x.SalesPersonId);
        });
        m.Entity<ProjectLeadership>(e => {
            e.ToTable("project_leadership");
            e.HasIndex(x => new { x.ProjectId, x.RoleCode, x.EmployeeId }).IsUnique();
            e.HasOne(x => x.Project).WithMany(p => p.Leadership).HasForeignKey(x => x.ProjectId);
            e.HasOne(x => x.Employee).WithMany().HasForeignKey(x => x.EmployeeId);
        });
        m.Entity<ProjectTeamMember>(e => {
            e.ToTable("project_team_member");
            e.HasOne(x => x.Project).WithMany(p => p.TeamMembers).HasForeignKey(x => x.ProjectId);
            e.HasOne(x => x.Employee).WithMany().HasForeignKey(x => x.EmployeeId);
        });
        m.Entity<ProjectService>(e => {
            e.ToTable("project_service");
            e.Property(x => x.UnitPrice).HasPrecision(12, 2);
            e.Property(x => x.LineTotal).HasPrecision(14, 2);
            e.HasOne(x => x.Project).WithMany(p => p.Services).HasForeignKey(x => x.ProjectId);
            e.HasOne(x => x.Service).WithMany().HasForeignKey(x => x.ServiceId);
        });
        m.Entity<ProjectServicePrereq>(e => {
            e.ToTable("project_service_prereq");
            e.HasOne(x => x.ProjectService).WithOne(ps => ps.Prereq).HasForeignKey<ProjectServicePrereq>(x => x.ProjectServiceId);
        });
        m.Entity<ProjectStage>(e => {
            e.ToTable("project_stage");
            e.HasIndex(x => new { x.ProjectId, x.StageCode }).IsUnique();
            e.HasOne(x => x.Project).WithMany(p => p.Stages).HasForeignKey(x => x.ProjectId);
        });
        m.Entity<ProjectPurchaseOrder>(e => { e.ToTable("project_purchase_order"); e.HasOne(x => x.Project).WithMany(p => p.PurchaseOrders).HasForeignKey(x => x.ProjectId); });
        m.Entity<Invoice>(e => {
            e.ToTable("invoice");
            e.Property(x => x.UnitPrice).HasPrecision(12, 2);
            e.Property(x => x.Amount).HasPrecision(14, 2);
            e.HasOne(x => x.Project).WithMany(p => p.Invoices).HasForeignKey(x => x.ProjectId);
            e.HasOne(x => x.RaisedBy).WithMany().HasForeignKey(x => x.RaisedById);
        });

        // Delivery — AppTask maps to the "task" table
        m.Entity<AppTask>(e => {
            e.ToTable("task");
            e.Property(x => x.EstimatedHours).HasPrecision(8, 2);
            e.Property(x => x.UtilizedHours).HasPrecision(8, 2);
            e.HasOne(x => x.Project).WithMany(p => p.Tasks).HasForeignKey(x => x.ProjectId);
        });
        m.Entity<TaskAssignee>(e => {
            e.ToTable("task_assignee");
            e.HasKey(x => new { x.TaskId, x.EmployeeId });
            e.HasOne(x => x.Task).WithMany(t => t.Assignees).HasForeignKey(x => x.TaskId);
            e.HasOne(x => x.Employee).WithMany().HasForeignKey(x => x.EmployeeId);
        });
        m.Entity<BucketTask>(e => {
            e.ToTable("bucket_task");
            e.HasOne(x => x.Task).WithMany(t => t.BucketTasks).HasForeignKey(x => x.TaskId);
            e.HasOne(x => x.Employee).WithMany().HasForeignKey(x => x.EmployeeId);
            e.HasOne(x => x.AssignedBy).WithMany().HasForeignKey(x => x.AssignedById);
        });
        m.Entity<Timesheet>(e => {
            e.ToTable("timesheet");
            e.Property(x => x.TotalHours).HasPrecision(8, 2);
            e.HasIndex(x => new { x.EmployeeId, x.WeekStart }).IsUnique();
            e.HasOne(x => x.Employee).WithMany().HasForeignKey(x => x.EmployeeId);
        });
        m.Entity<TimesheetEntry>(e => {
            e.ToTable("timesheet_entry");
            e.Property(x => x.Hours).HasColumnType("numeric(5,2)[]");
            e.HasOne(x => x.Timesheet).WithMany(t => t.Entries).HasForeignKey(x => x.TimesheetId);
            e.HasOne(x => x.Project).WithMany().HasForeignKey(x => x.ProjectId);
            e.HasOne(x => x.Task).WithMany().HasForeignKey(x => x.TaskId);
        });

        // Health / Governance
        m.Entity<Issue>(e => { e.ToTable("issue"); e.HasOne(x => x.Project).WithMany(p => p.Issues).HasForeignKey(x => x.ProjectId); e.HasOne(x => x.RaisedBy).WithMany().HasForeignKey(x => x.RaisedById); });
        m.Entity<Alert>(e => { e.ToTable("alert"); e.HasOne(x => x.Project).WithMany(p => p.Alerts).HasForeignKey(x => x.ProjectId); e.HasOne(x => x.RaisedBy).WithMany().HasForeignKey(x => x.RaisedById); });
        m.Entity<Appreciation>(e => {
            e.ToTable("appreciation");
            e.HasOne(x => x.Project).WithMany(p => p.Appreciations).HasForeignKey(x => x.ProjectId);
            e.HasOne(x => x.ToEmployee).WithMany().HasForeignKey(x => x.ToEmployeeId);
            e.HasOne(x => x.FromEmployee).WithMany().HasForeignKey(x => x.FromEmployeeId);
        });
        m.Entity<Interview>(e => { e.ToTable("interview"); e.HasOne(x => x.Project).WithMany(p => p.Interviews).HasForeignKey(x => x.ProjectId); e.HasOne(x => x.Resource).WithMany().HasForeignKey(x => x.ResourceId); });
        m.Entity<AdditionalRequirement>(e => { e.ToTable("additional_requirement"); e.HasOne(x => x.Project).WithMany(p => p.AdditionalRequirements).HasForeignKey(x => x.ProjectId); });
        m.Entity<Approval>(e => { e.ToTable("approval"); e.HasOne(x => x.Project).WithMany().HasForeignKey(x => x.ProjectId); e.HasOne(x => x.RequestedBy).WithMany().HasForeignKey(x => x.RequestedById); });
        m.Entity<Notification>(e => { e.ToTable("notification"); e.HasOne(x => x.Employee).WithMany().HasForeignKey(x => x.EmployeeId); });
        m.Entity<Comment>(e => { e.ToTable("comment"); e.HasOne(x => x.Author).WithMany().HasForeignKey(x => x.AuthorId); });

        // Repository & Audit
        m.Entity<RepositoryDocument>(e => {
            e.ToTable("repository_document");
            e.HasQueryFilter(x => x.DeletedAt == null);
            e.HasOne(x => x.Category).WithMany().HasForeignKey(x => x.CategoryId);
            e.HasOne(x => x.Uploader).WithMany().HasForeignKey(x => x.UploadedBy);
        });
        m.Entity<AuditLog>(e => {
            e.ToTable("audit_log");
            e.Property(x => x.Details).HasColumnType("jsonb");
            e.HasOne(x => x.Actor).WithMany().HasForeignKey(x => x.ActorId);
        });
    }
}
```

---

## Step 3 — REPLACE `Dtos/ApiDtos.cs`

**File**: `apps/backend/TrackerPro.Api/Dtos/ApiDtos.cs`

```csharp
namespace TrackerPro.Api.Dtos;

public record HealthDto(bool DatabaseConnected, string Database, string Message);
public record LookupDto(string Code, string Name, string GroupCode, int SortOrder);

// Identity
public record PermissionDto(string Key, string Module, string Group, string Label);
public record RoleDto(Guid Id, string Code, string Name, string ProjectScope, int PermissionCount);
public record RoleDetailDto(Guid Id, string Code, string Name, string ProjectScope, IReadOnlyList<PermissionDto> Permissions);
public record DepartmentDto(Guid Id, string Code, string Name, int SortOrder);
public record EmployeeDto(Guid Id, string EmployeeCode, string FirstName, string LastName, string Email, string? Phone, string? Department, string? Designation, string Status, bool IsActive);
public record UserDto(Guid Id, string Email, string DisplayName, string EmployeeCode, string RoleCode, string RoleName, bool IsActive);

// Customers
public record CustomerDto(Guid Id, string CustomerCode, string Name, string? CompanyName, string? Industry, string CustomerType, string? EngagementManager, int ProjectCount);
public record ContactDto(Guid Id, string Name, string? Email, string? Phone, string? Designation, string? ContactType, bool IsPrimary);
public record SubVentureDto(Guid Id, string Name, bool IsActive);

// Projects
public record ProjectDto(Guid Id, string ProjectCode, string? WbsId, string Name, string CustomerCode, string CustomerName, string Status, string Health, int Progress, DateOnly StartDate, DateOnly EndDate, decimal Budget, decimal Spent, string? Currency);
public record ProjectDetailDto(Guid Id, string ProjectCode, string? WbsId, string Name, string CustomerCode, string CustomerName, string? SubVenture, string Status, string Health, int Progress, DateOnly StartDate, DateOnly EndDate, decimal Budget, decimal Spent, string? Currency, string? ContractType, string? ProjectType, string? Description, string? WbsStatus, decimal TaxPercent, string? SalesPerson);
public record LeadershipDto(Guid Id, string RoleCode, Guid EmployeeId, string EmployeeName, bool IsPrimary);
public record TeamMemberDto(Guid Id, Guid EmployeeId, string EmployeeName, string TeamType, string Billability, string ResourceType, DateOnly? StartDate, DateOnly? EndDate);
public record ProjectServiceDto(Guid Id, Guid ServiceId, string ServiceCode, string ServiceName, string? ServiceDepartment, int Qty, string? ResourceLevel, DateOnly? StartDate, DateOnly? EndDate, int? DurationDays, int? DurationHours, decimal? UnitPrice, decimal? LineTotal, string? BillingModel, string? DeliveryModel);
public record ServicePrereqDto(Guid ProjectServiceId, string ServiceName, string CollectionStatus, string ValidationStatus, string BillingStatus, bool IsReady);
public record ProjectStageDto(Guid Id, string StageCode, string CurrentStatus, bool IsCompleted, bool IsActive, int SortOrder);
public record PurchaseOrderDto(Guid Id, string? PoNumber, DateOnly? PoDate, string PoStatus, string? FileName);
public record InvoiceDto(Guid Id, string Milestone, DateOnly? InvoiceTargetDate, decimal? UnitPrice, int? Qty, decimal? Amount, string? InvoiceNumber, string InvoiceStatus, string PaymentStatus, DateOnly? PaymentReceivedDate, string? ResourceLevel, string? RaisedBy, DateTimeOffset? RaisedAt);

// Services (master)
public record ServiceDto(Guid Id, string Code, string Name, Guid ServiceDepartmentId, string ServiceDepartmentName, string? DefaultTools, decimal DefaultUnitPrice, int DefaultDays);
public record ServiceDepartmentDto(Guid Id, string Code, string Name, string GroupType);

// Tasks
public record TaskDto(Guid Id, string Title, string Status, string? Stage, DateOnly? DueDate, int Progress, decimal? EstimatedHours, decimal? UtilizedHours, IReadOnlyList<string> AssigneeNames);

// Timesheets
public record TimesheetDto(Guid Id, Guid EmployeeId, string EmployeeName, DateOnly WeekStart, string Status, decimal TotalHours, DateTimeOffset? SubmittedAt, string? RejectionReason);
public record TimesheetEntryDto(Guid Id, Guid ProjectId, string ProjectName, Guid? TaskId, decimal[] Hours, string? Note);

// Bucket Tasks
public record BucketTaskDto(Guid Id, Guid TaskId, string TaskTitle, Guid ProjectId, string ProjectName, string Priority, DateOnly? DueDate, Guid EmployeeId, string Status, int ElapsedSeconds, bool TimerRunning);

// Resources
public record PmBucketDto(Guid PmId, string PmName, int ProjectCount);

// Issues
public record IssueDto(Guid Id, Guid ProjectId, string? ProjectName, string Title, string? Description, string? Category, string Priority, string Status, string? RaisedBy, DateTimeOffset CreatedAt, DateTimeOffset UpdatedAt);

// Alerts
public record AlertDto(Guid Id, Guid? ProjectId, string Title, string Kind, string Priority, string Status, string? RaisedBy, DateTimeOffset CreatedAt);

// Interviews
public record InterviewDto(Guid Id, Guid ProjectId, string ProjectName, Guid ResourceId, string ResourceName, DateOnly InterviewDate, string? InterviewTime, string? InterviewRound, string? Interviewer, string Status, string? Notes);

// Additional Requirements
public record RequirementDto(Guid Id, Guid ProjectId, string Title, string? Description, string Priority, string Status, string? RequestedBy, DateOnly? RequestedDate, DateTimeOffset CreatedAt);

// Appreciations
public record AppreciationDto(Guid Id, Guid ProjectId, Guid ToEmployeeId, string ToName, string? FromName, string Badge, string? Note, DateTimeOffset CreatedAt);

// Approvals
public record ApprovalDto(Guid Id, Guid? ProjectId, string? ProjectName, string RequestType, string? RequestedBy, string Status, string? Description, DateTimeOffset? AcknowledgedAt, DateTimeOffset CreatedAt);

// Notifications
public record NotificationDto(Guid Id, Guid EmployeeId, string Title, string? Body, string Status, string? RefType, Guid? RefId, DateTimeOffset CreatedAt);

// Finance / Reports
public record DashboardKpiDto(int TotalProjects, int ActiveProjects, int OnHoldProjects, int CompletedProjects, int GreenCount, int AmberCount, int RedCount, decimal TotalBudget, decimal TotalSpent);
public record InvoiceSummaryDto(Guid Id, Guid ProjectId, string ProjectName, string Milestone, decimal? Amount, string InvoiceStatus, string PaymentStatus, DateOnly? PaymentReceivedDate);
```

---

## Step 4 — CREATE New Controllers

Create each file below inside `apps/backend/TrackerPro.Api/Controllers/`.

---

### `LookupsController.cs` — CREATE NEW
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/lookups")]
public class LookupsController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<LookupDto>>> List([FromQuery] string? group, CancellationToken ct)
    {
        var q = db.Lookups.AsNoTracking().Where(x => x.IsActive);
        if (!string.IsNullOrWhiteSpace(group))
            q = q.Where(x => x.GroupCode == group);
        var result = await q.OrderBy(x => x.GroupCode).ThenBy(x => x.SortOrder)
            .Select(x => new LookupDto(x.Code, x.Name, x.GroupCode, x.SortOrder))
            .ToListAsync(ct);
        return Ok(result);
    }
}
```

---

### `DepartmentsController.cs` — CREATE NEW
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/departments")]
public class DepartmentsController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<DepartmentDto>>> List(CancellationToken ct)
    {
        var result = await db.Departments.AsNoTracking().Where(x => x.IsActive)
            .OrderBy(x => x.SortOrder)
            .Select(x => new DepartmentDto(x.Id, x.Code, x.Name, x.SortOrder))
            .ToListAsync(ct);
        return Ok(result);
    }
}
```

---

### `EmployeesController.cs` — CREATE NEW
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/employees")]
public class EmployeesController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<EmployeeDto>>> List(CancellationToken ct)
    {
        var result = await db.Employees.AsNoTracking()
            .Include(e => e.Department).Include(e => e.Designation)
            .OrderBy(e => e.EmployeeCode)
            .Select(e => new EmployeeDto(e.Id, e.EmployeeCode, e.FirstName, e.LastName, e.Email, e.Phone,
                e.Department != null ? e.Department.Name : null,
                e.Designation != null ? e.Designation.Name : null,
                e.Status, e.IsActive))
            .ToListAsync(ct);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<EmployeeDto>> Get(Guid id, CancellationToken ct)
    {
        var emp = await db.Employees.AsNoTracking()
            .Include(e => e.Department).Include(e => e.Designation)
            .Where(e => e.Id == id)
            .Select(e => new EmployeeDto(e.Id, e.EmployeeCode, e.FirstName, e.LastName, e.Email, e.Phone,
                e.Department != null ? e.Department.Name : null,
                e.Designation != null ? e.Designation.Name : null,
                e.Status, e.IsActive))
            .FirstOrDefaultAsync(ct);
        return emp is null ? NotFound() : Ok(emp);
    }
}
```

---

### `ServicesController.cs` — CREATE NEW
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/services")]
public class ServicesController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<ServiceDto>>> List(CancellationToken ct)
    {
        var result = await db.Services.AsNoTracking()
            .Include(s => s.ServiceDepartment).Where(s => s.IsActive).OrderBy(s => s.Code)
            .Select(s => new ServiceDto(s.Id, s.Code, s.Name, s.ServiceDepartmentId,
                s.ServiceDepartment.Name, s.DefaultTools, s.DefaultUnitPrice, s.DefaultDays))
            .ToListAsync(ct);
        return Ok(result);
    }
}

[ApiController]
[Route("api/service-departments")]
public class ServiceDepartmentsController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<ServiceDepartmentDto>>> List(CancellationToken ct)
    {
        var result = await db.ServiceDepartments.AsNoTracking()
            .Where(sd => sd.IsActive).OrderBy(sd => sd.SortOrder)
            .Select(sd => new ServiceDepartmentDto(sd.Id, sd.Code, sd.Name, sd.GroupType))
            .ToListAsync(ct);
        return Ok(result);
    }
}
```

---

### `CustomersController.cs` — REPLACE EXISTING
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/customers")]
public class CustomersController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<CustomerDto>>> List(CancellationToken ct)
    {
        var result = await db.Customers.AsNoTracking()
            .Include(c => c.Industry).Include(c => c.EngagementManager)
            .OrderBy(c => c.CustomerCode)
            .Select(c => new CustomerDto(c.Id, c.CustomerCode, c.Name, c.CompanyName,
                c.Industry != null ? c.Industry.Name : null, c.CustomerType,
                c.EngagementManager != null ? c.EngagementManager.FirstName + " " + c.EngagementManager.LastName : null,
                c.Projects.Count))
            .ToListAsync(ct);
        return Ok(result);
    }

    [HttpGet("{id:guid}/contacts")]
    public async Task<ActionResult<IEnumerable<ContactDto>>> Contacts(Guid id, CancellationToken ct)
    {
        var result = await db.CustomerContacts.AsNoTracking().Where(x => x.CustomerId == id)
            .Select(x => new ContactDto(x.Id, x.Name, x.Email, x.Phone, x.Designation, x.ContactType, x.IsPrimary))
            .ToListAsync(ct);
        return Ok(result);
    }

    [HttpGet("{id:guid}/sub-ventures")]
    public async Task<ActionResult<IEnumerable<SubVentureDto>>> SubVentures(Guid id, CancellationToken ct)
    {
        var result = await db.CustomerSubVentures.AsNoTracking()
            .Where(x => x.CustomerId == id && x.IsActive)
            .Select(x => new SubVentureDto(x.Id, x.Name, x.IsActive))
            .ToListAsync(ct);
        return Ok(result);
    }

    [HttpGet("{id:guid}/projects")]
    public async Task<ActionResult<IEnumerable<ProjectDto>>> Projects(Guid id, CancellationToken ct)
    {
        var result = await db.Projects.AsNoTracking()
            .Include(p => p.Customer).Include(p => p.Currency)
            .Where(p => p.CustomerId == id).OrderBy(p => p.ProjectCode)
            .Select(p => new ProjectDto(p.Id, p.ProjectCode, p.WbsId, p.Name,
                p.Customer.CustomerCode, p.Customer.Name, p.Status, p.Health, p.Progress,
                p.StartDate, p.EndDate, p.Budget, p.Spent,
                p.Currency != null ? p.Currency.Code : null))
            .ToListAsync(ct);
        return Ok(result);
    }
}
```

---

### `ProjectsController.cs` — REPLACE EXISTING
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/projects")]
public class ProjectsController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProjectDto>>> List(
        [FromQuery] string? status, [FromQuery] string? health, [FromQuery] Guid? customerId, CancellationToken ct)
    {
        var q = db.Projects.AsNoTracking().Include(p => p.Customer).Include(p => p.Currency).AsQueryable();
        if (!string.IsNullOrWhiteSpace(status)) q = q.Where(p => p.Status == status);
        if (!string.IsNullOrWhiteSpace(health)) q = q.Where(p => p.Health == health);
        if (customerId.HasValue) q = q.Where(p => p.CustomerId == customerId.Value);
        return Ok(await q.OrderBy(p => p.ProjectCode)
            .Select(p => new ProjectDto(p.Id, p.ProjectCode, p.WbsId, p.Name,
                p.Customer.CustomerCode, p.Customer.Name, p.Status, p.Health, p.Progress,
                p.StartDate, p.EndDate, p.Budget, p.Spent,
                p.Currency != null ? p.Currency.Code : null))
            .ToListAsync(ct));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ProjectDetailDto>> Get(Guid id, CancellationToken ct)
    {
        var p = await db.Projects.AsNoTracking()
            .Include(p => p.Customer).Include(p => p.Currency)
            .Include(p => p.SubVenture).Include(p => p.SalesPerson)
            .Where(p => p.Id == id).FirstOrDefaultAsync(ct);
        if (p is null) return NotFound();
        return Ok(new ProjectDetailDto(p.Id, p.ProjectCode, p.WbsId, p.Name,
            p.Customer.CustomerCode, p.Customer.Name, p.SubVenture?.Name,
            p.Status, p.Health, p.Progress, p.StartDate, p.EndDate, p.Budget, p.Spent,
            p.Currency?.Code, p.ContractType, p.ProjectType, p.Description, p.WbsStatus, p.TaxPercent,
            p.SalesPerson != null ? p.SalesPerson.FirstName + " " + p.SalesPerson.LastName : null));
    }

    [HttpGet("{id:guid}/leadership")]
    public async Task<ActionResult<IEnumerable<LeadershipDto>>> Leadership(Guid id, CancellationToken ct) =>
        Ok(await db.ProjectLeadership.AsNoTracking().Include(l => l.Employee).Where(l => l.ProjectId == id)
            .Select(l => new LeadershipDto(l.Id, l.RoleCode, l.EmployeeId, l.Employee.FirstName + " " + l.Employee.LastName, l.IsPrimary))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/team")]
    public async Task<ActionResult<IEnumerable<TeamMemberDto>>> Team(Guid id, CancellationToken ct) =>
        Ok(await db.ProjectTeamMembers.AsNoTracking().Include(t => t.Employee).Where(t => t.ProjectId == id)
            .Select(t => new TeamMemberDto(t.Id, t.EmployeeId, t.Employee.FirstName + " " + t.Employee.LastName, t.TeamType, t.Billability, t.ResourceType, t.StartDate, t.EndDate))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/services")]
    public async Task<ActionResult<IEnumerable<ProjectServiceDto>>> Services(Guid id, CancellationToken ct) =>
        Ok(await db.ProjectServices.AsNoTracking()
            .Include(s => s.Service).ThenInclude(s => s.ServiceDepartment)
            .Where(s => s.ProjectId == id).OrderBy(s => s.SortOrder)
            .Select(s => new ProjectServiceDto(s.Id, s.ServiceId, s.Service.Code, s.Service.Name,
                s.Service.ServiceDepartment.Name, s.Qty, s.ResourceLevel,
                s.StartDate, s.EndDate, s.DurationDays, s.DurationHours,
                s.UnitPrice, s.LineTotal, s.BillingModel, s.DeliveryModel))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/prereqs")]
    public async Task<ActionResult<IEnumerable<ServicePrereqDto>>> Prereqs(Guid id, CancellationToken ct) =>
        Ok(await db.ProjectServicePrereqs.AsNoTracking()
            .Include(p => p.ProjectService).ThenInclude(ps => ps.Service)
            .Where(p => p.ProjectService.ProjectId == id)
            .Select(p => new ServicePrereqDto(p.ProjectServiceId, p.ProjectService.Service.Name,
                p.CollectionStatus, p.ValidationStatus, p.BillingStatus, p.IsReady))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/stages")]
    public async Task<ActionResult<IEnumerable<ProjectStageDto>>> Stages(Guid id, CancellationToken ct) =>
        Ok(await db.ProjectStages.AsNoTracking().Where(s => s.ProjectId == id).OrderBy(s => s.SortOrder)
            .Select(s => new ProjectStageDto(s.Id, s.StageCode, s.CurrentStatus, s.IsCompleted, s.IsActive, s.SortOrder))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/purchase-orders")]
    public async Task<ActionResult<IEnumerable<PurchaseOrderDto>>> PurchaseOrders(Guid id, CancellationToken ct) =>
        Ok(await db.PurchaseOrders.AsNoTracking().Where(po => po.ProjectId == id)
            .Select(po => new PurchaseOrderDto(po.Id, po.PoNumber, po.PoDate, po.PoStatus, po.FileName))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/invoices")]
    public async Task<ActionResult<IEnumerable<InvoiceDto>>> Invoices(Guid id, CancellationToken ct) =>
        Ok(await db.Invoices.AsNoTracking().Include(i => i.RaisedBy).Where(i => i.ProjectId == id)
            .Select(i => new InvoiceDto(i.Id, i.Milestone, i.InvoiceTargetDate, i.UnitPrice, i.Qty,
                i.Amount, i.InvoiceNumber, i.InvoiceStatus, i.PaymentStatus, i.PaymentReceivedDate,
                i.ResourceLevel, i.RaisedBy != null ? i.RaisedBy.FirstName + " " + i.RaisedBy.LastName : null, i.RaisedAt))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/tasks")]
    public async Task<ActionResult<IEnumerable<TaskDto>>> Tasks(Guid id, CancellationToken ct) =>
        Ok(await db.Tasks.AsNoTracking().Include(t => t.Assignees).ThenInclude(a => a.Employee)
            .Where(t => t.ProjectId == id)
            .Select(t => new TaskDto(t.Id, t.Title, t.Status, t.Stage, t.DueDate, t.Progress,
                t.EstimatedHours, t.UtilizedHours,
                t.Assignees.Select(a => a.Employee.FirstName + " " + a.Employee.LastName).ToList()))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/issues")]
    public async Task<ActionResult<IEnumerable<IssueDto>>> Issues(Guid id, CancellationToken ct) =>
        Ok(await db.Issues.AsNoTracking().Include(i => i.RaisedBy).Include(i => i.Project)
            .Where(i => i.ProjectId == id).OrderByDescending(i => i.CreatedAt)
            .Select(i => new IssueDto(i.Id, i.ProjectId, i.Project.Name, i.Title, i.Description,
                i.Category, i.Priority, i.Status,
                i.RaisedBy != null ? i.RaisedBy.FirstName + " " + i.RaisedBy.LastName : null,
                i.CreatedAt, i.UpdatedAt))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/alerts")]
    public async Task<ActionResult<IEnumerable<AlertDto>>> Alerts(Guid id, CancellationToken ct) =>
        Ok(await db.Alerts.AsNoTracking().Include(a => a.RaisedBy).Where(a => a.ProjectId == id)
            .OrderByDescending(a => a.CreatedAt)
            .Select(a => new AlertDto(a.Id, a.ProjectId, a.Title, a.Kind, a.Priority, a.Status,
                a.RaisedBy != null ? a.RaisedBy.FirstName + " " + a.RaisedBy.LastName : null, a.CreatedAt))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/interviews")]
    public async Task<ActionResult<IEnumerable<InterviewDto>>> Interviews(Guid id, CancellationToken ct) =>
        Ok(await db.Interviews.AsNoTracking().Include(i => i.Resource).Include(i => i.Project)
            .Where(i => i.ProjectId == id)
            .Select(i => new InterviewDto(i.Id, i.ProjectId, i.Project.Name, i.ResourceId,
                i.Resource.FirstName + " " + i.Resource.LastName,
                i.InterviewDate, i.InterviewTime, i.InterviewRound, i.Interviewer, i.Status, i.Notes))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/appreciations")]
    public async Task<ActionResult<IEnumerable<AppreciationDto>>> Appreciations(Guid id, CancellationToken ct) =>
        Ok(await db.Appreciations.AsNoTracking().Include(a => a.ToEmployee).Include(a => a.FromEmployee)
            .Where(a => a.ProjectId == id)
            .Select(a => new AppreciationDto(a.Id, a.ProjectId, a.ToEmployeeId,
                a.ToEmployee.FirstName + " " + a.ToEmployee.LastName,
                a.FromEmployee != null ? a.FromEmployee.FirstName + " " + a.FromEmployee.LastName : null,
                a.Badge, a.Note, a.CreatedAt))
            .ToListAsync(ct));

    [HttpGet("{id:guid}/requirements")]
    public async Task<ActionResult<IEnumerable<RequirementDto>>> Requirements(Guid id, CancellationToken ct) =>
        Ok(await db.AdditionalRequirements.AsNoTracking().Where(r => r.ProjectId == id)
            .Select(r => new RequirementDto(r.Id, r.ProjectId, r.Title, r.Description, r.Priority,
                r.Status, r.RequestedBy, r.RequestedDate, r.CreatedAt))
            .ToListAsync(ct));
}
```

---

### `TimesheetsController.cs` — CREATE NEW
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/timesheets")]
public class TimesheetsController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<TimesheetDto>>> List(
        [FromQuery] Guid? employeeId, [FromQuery] string? status, CancellationToken ct)
    {
        var q = db.Timesheets.AsNoTracking().Include(t => t.Employee).AsQueryable();
        if (employeeId.HasValue) q = q.Where(t => t.EmployeeId == employeeId.Value);
        if (!string.IsNullOrWhiteSpace(status)) q = q.Where(t => t.Status == status);
        return Ok(await q.OrderByDescending(t => t.WeekStart)
            .Select(t => new TimesheetDto(t.Id, t.EmployeeId,
                t.Employee.FirstName + " " + t.Employee.LastName,
                t.WeekStart, t.Status, t.TotalHours, t.SubmittedAt, t.RejectionReason))
            .ToListAsync(ct));
    }

    [HttpGet("{id:guid}/entries")]
    public async Task<ActionResult<IEnumerable<TimesheetEntryDto>>> Entries(Guid id, CancellationToken ct) =>
        Ok(await db.TimesheetEntries.AsNoTracking().Include(e => e.Project)
            .Where(e => e.TimesheetId == id)
            .Select(e => new TimesheetEntryDto(e.Id, e.ProjectId, e.Project.Name, e.TaskId, e.Hours, e.Note))
            .ToListAsync(ct));
}
```

---

### `BucketTasksController.cs` — CREATE NEW
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/bucket-tasks")]
public class BucketTasksController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<BucketTaskDto>>> List(
        [FromQuery] Guid? employeeId, CancellationToken ct)
    {
        var q = db.BucketTasks.AsNoTracking()
            .Include(b => b.Task).ThenInclude(t => t.Project).AsQueryable();
        if (employeeId.HasValue) q = q.Where(b => b.EmployeeId == employeeId.Value);
        return Ok(await q.Select(b => new BucketTaskDto(b.Id, b.TaskId, b.Task.Title,
                b.Task.ProjectId, b.Task.Project.Name, b.Priority, b.DueDate,
                b.EmployeeId, b.Status, b.ElapsedSeconds, b.TimerRunning))
            .ToListAsync(ct));
    }
}
```

---

### `IssuesController.cs` — CREATE NEW
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/issues")]
public class IssuesController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<IssueDto>>> List(
        [FromQuery] Guid? projectId, [FromQuery] string? status, CancellationToken ct)
    {
        var q = db.Issues.AsNoTracking().Include(i => i.RaisedBy).Include(i => i.Project).AsQueryable();
        if (projectId.HasValue) q = q.Where(i => i.ProjectId == projectId.Value);
        if (!string.IsNullOrWhiteSpace(status)) q = q.Where(i => i.Status == status);
        return Ok(await q.OrderByDescending(i => i.CreatedAt)
            .Select(i => new IssueDto(i.Id, i.ProjectId, i.Project.Name, i.Title, i.Description,
                i.Category, i.Priority, i.Status,
                i.RaisedBy != null ? i.RaisedBy.FirstName + " " + i.RaisedBy.LastName : null,
                i.CreatedAt, i.UpdatedAt))
            .ToListAsync(ct));
    }
}
```

---

### `AlertsController.cs` — CREATE NEW
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/alerts")]
public class AlertsController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<AlertDto>>> List(
        [FromQuery] Guid? projectId, CancellationToken ct)
    {
        var q = db.Alerts.AsNoTracking().Include(a => a.RaisedBy).AsQueryable();
        if (projectId.HasValue) q = q.Where(a => a.ProjectId == projectId.Value);
        return Ok(await q.OrderByDescending(a => a.CreatedAt)
            .Select(a => new AlertDto(a.Id, a.ProjectId, a.Title, a.Kind, a.Priority, a.Status,
                a.RaisedBy != null ? a.RaisedBy.FirstName + " " + a.RaisedBy.LastName : null, a.CreatedAt))
            .ToListAsync(ct));
    }
}
```

---

### `ApprovalsController.cs` — CREATE NEW
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/approvals")]
public class ApprovalsController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<ApprovalDto>>> List(
        [FromQuery] string? status, CancellationToken ct)
    {
        var q = db.Approvals.AsNoTracking().Include(a => a.Project).Include(a => a.RequestedBy).AsQueryable();
        if (!string.IsNullOrWhiteSpace(status)) q = q.Where(a => a.Status == status);
        return Ok(await q.OrderByDescending(a => a.CreatedAt)
            .Select(a => new ApprovalDto(a.Id, a.ProjectId,
                a.Project != null ? a.Project.Name : null, a.RequestType,
                a.RequestedBy != null ? a.RequestedBy.FirstName + " " + a.RequestedBy.LastName : null,
                a.Status, a.Description, a.AcknowledgedAt, a.CreatedAt))
            .ToListAsync(ct));
    }
}
```

---

### `NotificationsController.cs` — CREATE NEW
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/notifications")]
public class NotificationsController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<NotificationDto>>> List(
        [FromQuery] Guid? employeeId, [FromQuery] string? status, CancellationToken ct)
    {
        var q = db.Notifications.AsNoTracking().AsQueryable();
        if (employeeId.HasValue) q = q.Where(n => n.EmployeeId == employeeId.Value);
        if (!string.IsNullOrWhiteSpace(status)) q = q.Where(n => n.Status == status);
        return Ok(await q.OrderByDescending(n => n.CreatedAt)
            .Select(n => new NotificationDto(n.Id, n.EmployeeId, n.Title, n.Body, n.Status, n.RefType, n.RefId, n.CreatedAt))
            .ToListAsync(ct));
    }
}
```

---

### `ReportsController.cs` — CREATE NEW
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrackerPro.Api.Data;
using TrackerPro.Api.Dtos;

namespace TrackerPro.Api.Controllers;

[ApiController]
[Route("api/reports")]
public class ReportsController(TrackerProDbContext db) : ControllerBase
{
    [HttpGet("dashboard-kpis")]
    public async Task<ActionResult<DashboardKpiDto>> DashboardKpis(CancellationToken ct)
    {
        var projects = await db.Projects.AsNoTracking()
            .Select(p => new { p.Status, p.Health, p.Budget, p.Spent })
            .ToListAsync(ct);
        return Ok(new DashboardKpiDto(
            projects.Count,
            projects.Count(p => p.Status == "ongoing"),
            projects.Count(p => p.Status == "on_hold"),
            projects.Count(p => p.Status == "completed"),
            projects.Count(p => p.Health == "green"),
            projects.Count(p => p.Health == "amber"),
            projects.Count(p => p.Health == "red"),
            projects.Sum(p => p.Budget),
            projects.Sum(p => p.Spent)));
    }

    [HttpGet("invoices")]
    public async Task<ActionResult<IEnumerable<InvoiceSummaryDto>>> Invoices(
        [FromQuery] Guid? projectId, CancellationToken ct)
    {
        var q = db.Invoices.AsNoTracking().Include(i => i.Project).AsQueryable();
        if (projectId.HasValue) q = q.Where(i => i.ProjectId == projectId.Value);
        return Ok(await q.Select(i => new InvoiceSummaryDto(i.Id, i.ProjectId, i.Project.Name,
                i.Milestone, i.Amount, i.InvoiceStatus, i.PaymentStatus, i.PaymentReceivedDate))
            .ToListAsync(ct));
    }
}
```

---

## Step 5 — Verify

```bash
cd apps/backend/TrackerPro.Api
dotnet build
dotnet run
```

Test every group:
```bash
curl http://localhost:5000/health
curl "http://localhost:5000/api/lookups?group=project_status"
curl http://localhost:5000/api/departments
curl http://localhost:5000/api/employees
curl http://localhost:5000/api/customers
curl http://localhost:5000/api/projects
curl "http://localhost:5000/api/projects?status=ongoing"
curl http://localhost:5000/api/services
curl http://localhost:5000/api/service-departments
curl "http://localhost:5000/api/timesheets?status=submitted"
curl "http://localhost:5000/api/issues?projectId=<any-uuid>"
curl http://localhost:5000/api/approvals
curl http://localhost:5000/api/reports/dashboard-kpis
curl http://localhost:5000/api/reports/invoices
```

All must return HTTP 200 with JSON.

---

## Critical Notes

1. `AppTask` maps to the `task` table — the class is named `AppTask` to avoid conflict with `System.Threading.Tasks.Task`.
2. `TimesheetEntry.Hours` is `decimal[]` with `HasColumnType("numeric(5,2)[]")` — Npgsql handles arrays natively.
3. `AuditLog.Details` is `string?` with `HasColumnType("jsonb")`.
4. **Never run** `dotnet ef migrations add` — schema is managed by `db/01_schema.sql`.
5. Soft-delete query filters are applied on: `Employee`, `Customer`, `Project`, `RepositoryDocument`.
