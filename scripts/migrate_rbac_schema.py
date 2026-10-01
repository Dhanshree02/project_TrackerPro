import psycopg2
import uuid

conn = psycopg2.connect(
    host="10.50.30.189", port=5432, dbname="trackerpro",
    user="postgres", password="clockit"
)
conn.autocommit = False
cur = conn.cursor()

try:
    print("1. Creating tables: mst_modules, mst_submodules, mst_widgets, role_widget_permissions...")

    cur.execute("""
    CREATE TABLE IF NOT EXISTS mst_modules (
        "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        "Code" VARCHAR(80) NOT NULL UNIQUE,
        "Name" VARCHAR(150) NOT NULL,
        "Icon" VARCHAR(80),
        "SortOrder" INT NOT NULL DEFAULT 0,
        "IsActive" BOOLEAN NOT NULL DEFAULT true,
        "CreatedAtUtc" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "UpdatedAtUtc" TIMESTAMPTZ,
        "CreatedBy" UUID,
        "UpdatedBy" UUID,
        "DeletedAtUtc" TIMESTAMPTZ
    );
    CREATE INDEX IF NOT EXISTS "IX_mst_modules_Code" ON mst_modules ("Code");
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS mst_submodules (
        "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        "ModuleId" UUID NOT NULL REFERENCES mst_modules("Id") ON DELETE CASCADE,
        "ParentSubmoduleId" UUID REFERENCES mst_submodules("Id") ON DELETE CASCADE,
        "Code" VARCHAR(80) NOT NULL,
        "Name" VARCHAR(150) NOT NULL,
        "RoutePrefix" VARCHAR(150),
        "SortOrder" INT NOT NULL DEFAULT 0,
        "IsActive" BOOLEAN NOT NULL DEFAULT true,
        "CreatedAtUtc" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "UpdatedAtUtc" TIMESTAMPTZ,
        "CreatedBy" UUID,
        "UpdatedBy" UUID,
        "DeletedAtUtc" TIMESTAMPTZ,
        CONSTRAINT "UQ_submodule_module_parent_code" UNIQUE ("ModuleId", "ParentSubmoduleId", "Code")
    );
    CREATE INDEX IF NOT EXISTS "IX_mst_submodules_ModuleId" ON mst_submodules ("ModuleId");
    CREATE INDEX IF NOT EXISTS "IX_mst_submodules_ParentSubmoduleId" ON mst_submodules ("ParentSubmoduleId");
    CREATE INDEX IF NOT EXISTS "IX_mst_submodules_Code" ON mst_submodules ("Code");
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS mst_widgets (
        "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        "SubmoduleId" UUID REFERENCES mst_submodules("Id") ON DELETE CASCADE,
        "ModuleId" UUID REFERENCES mst_modules("Id") ON DELETE CASCADE,
        "Code" VARCHAR(100) NOT NULL,
        "Name" VARCHAR(150) NOT NULL,
        "WidgetKey" VARCHAR(200) NOT NULL UNIQUE,
        "WidgetType" VARCHAR(40) NOT NULL DEFAULT 'widget',
        "HasManageAction" BOOLEAN NOT NULL DEFAULT true,
        "Description" VARCHAR(500),
        "SortOrder" INT NOT NULL DEFAULT 0,
        "IsActive" BOOLEAN NOT NULL DEFAULT true,
        "CreatedAtUtc" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "UpdatedAtUtc" TIMESTAMPTZ,
        "CreatedBy" UUID,
        "UpdatedBy" UUID,
        "DeletedAtUtc" TIMESTAMPTZ
    );
    CREATE INDEX IF NOT EXISTS "IX_mst_widgets_WidgetKey" ON mst_widgets ("WidgetKey");
    CREATE INDEX IF NOT EXISTS "IX_mst_widgets_SubmoduleId" ON mst_widgets ("SubmoduleId");
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS role_widget_permissions (
        "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        "RoleId" UUID NOT NULL REFERENCES roles("Id") ON DELETE CASCADE,
        "WidgetId" UUID NOT NULL REFERENCES mst_widgets("Id") ON DELETE CASCADE,
        "CanView" SMALLINT NOT NULL DEFAULT 0,
        "CanManage" SMALLINT NOT NULL DEFAULT 0,
        "CreatedAtUtc" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "UpdatedAtUtc" TIMESTAMPTZ,
        "CreatedBy" UUID,
        "UpdatedBy" UUID,
        "DeletedAtUtc" TIMESTAMPTZ,
        CONSTRAINT "UQ_role_widget_permissions" UNIQUE ("RoleId", "WidgetId"),
        CONSTRAINT "CHK_role_widget_can_view_binary" CHECK ("CanView" IN (0, 1)),
        CONSTRAINT "CHK_role_widget_can_manage_binary" CHECK ("CanManage" IN (0, 1)),
        CONSTRAINT "CHK_role_widget_manage_requires_view" CHECK ("CanManage" = 0 OR "CanView" = 1)
    );
    CREATE INDEX IF NOT EXISTS "IX_role_widget_permissions_RoleId" ON role_widget_permissions ("RoleId");
    CREATE INDEX IF NOT EXISTS "IX_role_widget_permissions_WidgetId" ON role_widget_permissions ("WidgetId");
    CREATE INDEX IF NOT EXISTS "IX_role_widget_lookup" ON role_widget_permissions ("RoleId", "CanView", "CanManage");
    """)

    cur.execute("""
    CREATE OR REPLACE VIEW vw_role_widget_matrix AS
    SELECT 
        r."Id" AS "RoleId",
        r."Name" AS "RoleName",
        m."Code" AS "ModuleCode",
        m."Name" AS "ModuleName",
        sm."Code" AS "SubmoduleCode",
        sm."Name" AS "SubmoduleName",
        w."Id" AS "WidgetId",
        w."WidgetKey",
        w."Name" AS "WidgetName",
        w."WidgetType",
        w."HasManageAction",
        COALESCE(rwp."CanView", 0) AS "CanView",
        COALESCE(rwp."CanManage", 0) AS "CanManage"
    FROM roles r
    CROSS JOIN mst_widgets w
    LEFT JOIN mst_submodules sm ON w."SubmoduleId" = sm."Id"
    LEFT JOIN mst_modules m ON (sm."ModuleId" = m."Id" OR w."ModuleId" = m."Id")
    LEFT JOIN role_widget_permissions rwp 
           ON rwp."RoleId" = r."Id" AND rwp."WidgetId" = w."Id"
    WHERE w."DeletedAtUtc" IS NULL;
    """)

    print("2. Seeding modules, submodules, and widgets from modules RBAC catalog...")

    # Modules structure definition
    modules_data = [
        ("dashboard", "Dashboard", "LayoutDashboard", 1),
        ("action_center", "Action Center", "ListChecks", 2),
        ("projects", "Projects", "FolderKanban", 3),
        ("reports", "Reports", "BarChart3", 4),
        ("resources", "Resource", "Users", 5),
        ("customers", "Customers", "Building2", 6),
        ("repository", "Repository", "Building", 7),
        ("my_team", "My Team", "Users", 8),
        ("settings", "Settings", "Settings", 9),
    ]

    mod_id_map = {}
    for code, name, icon, sort_order in modules_data:
        cur.execute("""
            INSERT INTO mst_modules ("Code", "Name", "Icon", "SortOrder")
            VALUES (%s, %s, %s, %s)
            ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "Icon" = EXCLUDED."Icon", "SortOrder" = EXCLUDED."SortOrder"
            RETURNING "Id";
        """, (code, name, icon, sort_order))
        mod_id_map[code] = cur.fetchone()[0]

    # Submodules definitions (code, name, module_code, parent_sub_code, route, sort_order)
    submodules_data = [
        # Action Center
        ("bucket_list", "Bucket List", "action_center", None, "/action-centre?tab=bucket", 1),
        ("approvals", "Approvals", "action_center", None, "/approvals", 2),
        ("alerts", "Alerts", "action_center", None, "/action-centre?tab=alerts", 3),
        ("notifications", "Notifications", "action_center", None, "/action-centre", 4),

        # Projects
        ("projects_cards", "Projects Cards", "projects", None, "/projects", 1),
        ("overview", "Overview", "projects", "projects_cards", "/projects/:id", 1),
        ("wbs", "WBS", "projects", "projects_cards", "/projects/:id/wbs", 2),
        ("team", "Team", "projects", "projects_cards", "/projects/:id/team", 3),
        ("task", "Task", "projects", "projects_cards", "/projects/:id/task", 4),
        ("health", "Health & Governance", "projects", "projects_cards", "/projects/:id/health", 5),
        ("invoice", "Invoice", "projects", "projects_cards", "/projects/:id/invoice", 6),

        # Reports
        ("sales_report", "Sales Report", "reports", None, "/reports/sales", 1),
        ("wbs_tracker", "WBS Tracker", "reports", None, "/reports/wbs", 2),
        ("po_tracker", "PO Tracker", "reports", None, "/reports/po", 3),
        ("invoice_tracker", "Invoice Tracker", "reports", None, "/reports/invoice", 4),

        # Resources
        ("resource_directory", "Resource Directory", "resources", None, "/dh-employee-directory", 1),
        ("resource_details", "Resource Details", "resources", "resource_directory", "/dh-employee-directory/:id", 1),
        ("resource_pool", "Resource Pool", "resources", None, "/dh-resource-pool", 2),
        ("exit_summary", "Exit Summary", "resources", None, "/dh-exit-summary", 3),

        # Customers
        ("customers_card", "Customers Card", "customers", None, "/customers", 1),
        ("customer_profile", "Customer Profile", "customers", "customers_card", "/customers/:id", 1),

        # My Team
        ("team_dashboard", "Team Dashboard", "my_team", None, "/my-team", 1),
        ("timesheets", "Timesheets", "my_team", None, "/my-team/timesheets", 2),
        ("my_timesheet", "My Timesheet", "my_team", "timesheets", "/timesheet", 1),
        ("timesheet_approval", "Timesheet Approval", "my_team", "timesheets", "/my-team/timesheets", 2),

        # Settings
        ("roles_permissions", "Roles & Permission", "settings", None, "/dh-settings-security-roles", 1),
        ("moduleswise_access", "Moduleswise Access", "settings", "roles_permissions", "/dh-settings-security-roles?tab=modules", 1),
        ("user_role_access", "User Role Access", "settings", "roles_permissions", "/dh-settings-security-roles?tab=users", 2),
        ("masters", "Masters", "settings", None, "/dh-settings-masters", 2),
        ("project_masters", "Project Masters", "settings", "masters", "/dh-settings-masters?tab=project", 1),
        ("customer_masters", "Customer Masters", "settings", "masters", "/dh-settings-masters?tab=customer", 2),
        ("resource_masters", "Resource Master", "settings", "masters", "/dh-settings-masters?tab=resource", 3),
    ]

    submod_id_map = {}
    for code, name, mod_code, parent_code, route, sort_order in submodules_data:
        mod_id = mod_id_map[mod_code]
        parent_id = submod_id_map.get(parent_code) if parent_code else None

        cur.execute("""
            SELECT "Id" FROM mst_submodules 
            WHERE "ModuleId" = %s AND "Code" = %s AND ("ParentSubmoduleId" = %s OR ("ParentSubmoduleId" IS NULL AND %s IS NULL))
        """, (mod_id, code, parent_id, parent_id))
        row = cur.fetchone()

        if row:
            submod_id = row[0]
            cur.execute("""
                UPDATE mst_submodules SET "Name" = %s, "RoutePrefix" = %s, "SortOrder" = %s
                WHERE "Id" = %s
            """, (name, route, sort_order, submod_id))
        else:
            cur.execute("""
                INSERT INTO mst_submodules ("ModuleId", "ParentSubmoduleId", "Code", "Name", "RoutePrefix", "SortOrder")
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING "Id";
            """, (mod_id, parent_id, code, name, route, sort_order))
            submod_id = cur.fetchone()[0]

        submod_id_map[code] = submod_id

    # 49 Widgets definitions
    # (widget_key, code, name, mod_code, submod_code, widget_type, has_manage, sort_order)
    widgets_data = [
        # 1. Dashboard
        ("dashboard.kpis", "kpis", "KPI'S", "dashboard", None, "kpi_card", False, 1),
        ("dashboard.assigned_projects", "assigned_projects", "Assigned Projects", "dashboard", None, "widget", False, 2),
        ("dashboard.pending_issues", "pending_issues", "Pending Issues", "dashboard", None, "widget", False, 3),
        ("dashboard.project_status", "project_status", "Project Status", "dashboard", None, "widget", False, 4),
        ("dashboard.pending_approvals", "pending_approvals", "Pending Approvals", "dashboard", None, "widget", False, 5),

        # 2. Action Center
        ("action_center.bucket_list.raise_issues", "raise_issues", "Raise Issues", "action_center", "bucket_list", "action", True, 1),
        ("action_center.bucket_list.start_timer", "start_timer", "Start Timer", "action_center", "bucket_list", "action", True, 2),
        ("action_center.approvals", "approvals", "Approvals Queue", "action_center", "approvals", "widget", True, 1),
        ("action_center.alerts", "alerts", "Alerts Feed", "action_center", "alerts", "widget", True, 1),
        ("action_center.notifications", "notifications", "Notification Feed", "action_center", "notifications", "widget", True, 1),

        # 3. Projects Overview
        ("projects.overview.budget", "budget", "Budget", "projects", "overview", "widget", True, 1),
        ("projects.overview.extension_request", "extension_request", "Extension Request", "projects", "overview", "widget", True, 2),
        ("projects.overview.assign_spm", "assign_spm", "Sr. Project Manager", "projects", "overview", "action", True, 3),
        ("projects.overview.assign_pm", "assign_pm", "Project Manager", "projects", "overview", "action", True, 4),
        ("projects.overview.assign_tl", "assign_tl", "Team Leads", "projects", "overview", "action", True, 5),

        # Projects WBS
        ("projects.wbs.billing_info", "billing_info", "Billing Information", "projects", "wbs", "widget", True, 1),
        ("projects.wbs.pmo_intake", "pmo_intake", "PMO Intake & Prerequisite Workflow", "projects", "wbs", "widget", True, 2),
        ("projects.wbs.invoice_schedule", "invoice_schedule", "Invoice Schedule", "projects", "wbs", "widget", True, 3),

        # Projects Team, Task
        ("projects.team.allocation", "team_allocation", "Team Allocation", "projects", "team", "widget", True, 1),
        ("projects.task.management", "task_management", "Task Breakdown", "projects", "task", "widget", True, 1),

        # Projects Health
        ("projects.health.issues", "issues", "Health Issues", "projects", "health", "widget", True, 1),
        ("projects.health.alerts", "alerts", "Health Alerts", "projects", "health", "widget", True, 2),
        ("projects.health.escalation", "escalation", "Escalation Matrix", "projects", "health", "widget", True, 3),
        ("projects.health.appreciation", "appreciation", "Appreciation", "projects", "health", "widget", True, 4),
        ("projects.health.engagement.interview", "engagement_interview", "Interview Scheduling", "projects", "health", "tab", True, 5),
        ("projects.health.engagement.requirements", "engagement_requirements", "Additional Customer Requirement", "projects", "health", "tab", True, 6),

        # Projects Invoice
        ("projects.invoice.management", "invoice_management", "Invoicing Grid", "projects", "invoice", "widget", True, 1),

        # 4. Reports
        ("reports.sales", "sales", "Sales Report", "reports", "sales_report", "widget", True, 1),
        ("reports.wbs_tracker", "wbs_tracker", "WBS Tracker", "reports", "wbs_tracker", "widget", True, 1),
        ("reports.po_tracker", "po_tracker", "PO Tracker", "reports", "po_tracker", "widget", True, 1),
        ("reports.invoice_tracker", "invoice_tracker", "Invoice Tracker", "reports", "invoice_tracker", "widget", True, 1),

        # 5. Resource Directory
        ("resources.directory.personal_info", "personal_info", "Personal Information", "resources", "resource_details", "tab", True, 1),
        ("resources.directory.org_details", "org_details", "Organization Details", "resources", "resource_details", "tab", True, 2),
        ("resources.directory.employment_bond", "employment_bond", "Employment & Bond", "resources", "resource_details", "tab", True, 3),
        ("resources.directory.education_exp", "education_exp", "Education & Experience", "resources", "resource_details", "tab", True, 4),
        ("resources.directory.pmo_info", "pmo_info", "PMO Information", "resources", "resource_details", "tab", True, 5),
        ("resources.directory.activity_logs", "activity_logs", "Activity Logs", "resources", "resource_details", "tab", False, 6),

        # Resource Pool & Exit Summary
        ("resources.resource_pool", "resource_pool", "Resource Pool Grid", "resources", "resource_pool", "widget", True, 1),
        ("resources.exit_summary", "exit_summary", "Exit Summary Logs", "resources", "exit_summary", "widget", True, 1),

        # 6. Customers
        ("customers.customer_profile", "customer_profile", "Customer Profiles", "customers", "customer_profile", "widget", True, 1),

        # 7. Repository
        ("repository.documents", "documents", "Document Repository", "repository", None, "widget", True, 1),

        # 8. My Team
        ("my_team.dashboard", "team_dashboard", "Team Dashboard", "my_team", "team_dashboard", "widget", True, 1),
        ("my_team.my_timesheet", "my_timesheet", "My Timesheet", "my_team", "my_timesheet", "widget", True, 1),
        ("my_team.timesheet_approval", "timesheet_approval", "Timesheet Approval", "my_team", "timesheet_approval", "widget", True, 1),

        # 9. Settings
        ("settings.roles.modules_access", "modules_access", "Moduleswise Access", "settings", "moduleswise_access", "widget", True, 1),
        ("settings.roles.user_access", "user_access", "User Role Access", "settings", "user_role_access", "widget", True, 2),
        ("settings.masters.project", "project_masters", "Project Masters Grid", "settings", "project_masters", "widget", True, 1),
        ("settings.masters.customer", "customer_masters", "Customer Masters Grid", "settings", "customer_masters", "widget", True, 2),
        ("settings.masters.resource", "resource_masters", "Resource Masters Grid", "settings", "resource_masters", "widget", True, 3),
    ]

    widget_id_map = {}
    for key, code, name, mod_code, submod_code, wtype, has_manage, sort_order in widgets_data:
        mod_id = mod_id_map[mod_code]
        submod_id = submod_id_map.get(submod_code) if submod_code else None

        cur.execute("""
            INSERT INTO mst_widgets ("WidgetKey", "Code", "Name", "ModuleId", "SubmoduleId", "WidgetType", "HasManageAction", "SortOrder")
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT ("WidgetKey") DO UPDATE SET
                "Name" = EXCLUDED."Name",
                "WidgetType" = EXCLUDED."WidgetType",
                "HasManageAction" = EXCLUDED."HasManageAction",
                "SortOrder" = EXCLUDED."SortOrder"
            RETURNING "Id";
        """, (key, code, name, mod_id, submod_id, wtype, has_manage, sort_order))
        widget_id_map[key] = (cur.fetchone()[0], has_manage)

    print(f"   Seeded {len(modules_data)} modules, {len(submodules_data)} submodules, {len(widgets_data)} widgets.")

    print("3. Seeding role_widget_permissions baseline for all roles...")

    # Fetch all roles
    cur.execute('SELECT "Id", "Name" FROM roles')
    roles = cur.fetchall()

    inserted_count = 0
    for role_id, role_name in roles:
        r_name = role_name.strip()
        is_super_admin = r_name in ["Admin", "CEO", "COO", "Dhanshree"]
        is_pmo = r_name in ["PMO"]
        is_pm_family = "Manager" in r_name or "Leader" in r_name or r_name in ["EngagementManager", "Testing-Manager", "Consulting-Manager", "SOC-Manager"]
        is_hr = r_name in ["HR"]
        is_it_admin = r_name in ["IT Admin"]
        is_accounts = r_name in ["Accounts"]
        is_sales = "Sales" in r_name

        for w_key, (w_id, has_manage) in widget_id_map.items():
            can_view = 0
            can_manage = 0

            if is_super_admin:
                can_view = 1
                can_manage = 1 if has_manage else 0
            elif is_pmo:
                can_view = 1
                can_manage = 1 if has_manage and ("pmo" in w_key or "wbs" in w_key or "approvals" in w_key or "timesheet_approval" in w_key) else 0
            elif is_hr:
                if w_key.startswith("resources.") or w_key == "dashboard.kpis" or w_key.startswith("action_center."):
                    can_view = 1
                    can_manage = 1 if has_manage and w_key.startswith("resources.") else 0
            elif is_accounts:
                if "invoice" in w_key or "budget" in w_key or "billing" in w_key or w_key.startswith("reports.") or w_key == "dashboard.kpis":
                    can_view = 1
                    can_manage = 1 if has_manage and ("invoice" in w_key or "billing" in w_key) else 0
            elif is_sales:
                if w_key.startswith("customers.") or "sales" in w_key or w_key == "dashboard.kpis":
                    can_view = 1
                    can_manage = 1 if has_manage and w_key.startswith("customers.") else 0
            elif is_it_admin:
                if w_key.startswith("settings.masters.") or w_key.startswith("resources.directory.") or w_key == "repository.documents":
                    can_view = 1
                    can_manage = 1 if has_manage else 0
            elif is_pm_family:
                if w_key.startswith("projects.") or w_key.startswith("action_center.") or w_key.startswith("my_team.") or w_key.startswith("dashboard."):
                    can_view = 1
                    can_manage = 1 if has_manage and not ("budget" in w_key and "Testing" in r_name) else 0
            else:
                # Team Member / Intern
                if w_key in ["my_team.my_timesheet", "dashboard.kpis", "dashboard.assigned_projects", "projects.task.management", "action_center.bucket_list.start_timer"]:
                    can_view = 1
                    can_manage = 1 if w_key in ["my_team.my_timesheet", "action_center.bucket_list.start_timer"] else 0
                elif w_key.startswith("projects.health."):
                    can_view = 1
                    can_manage = 1 if w_key == "projects.health.issues" and has_manage else 0

            cur.execute("""
                INSERT INTO role_widget_permissions ("RoleId", "WidgetId", "CanView", "CanManage")
                VALUES (%s, %s, %s, %s)
                ON CONFLICT ("RoleId", "WidgetId") DO UPDATE SET
                    "CanView" = EXCLUDED."CanView",
                    "CanManage" = EXCLUDED."CanManage";
            """, (role_id, w_id, can_view, can_manage))
            inserted_count += 1

    conn.commit()
    print(f"[SUCCESS] Successfully seeded {inserted_count} role_widget_permissions entries across {len(roles)} roles!")

except Exception as ex:
    conn.rollback()
    print("[ERROR] Error during migration:", str(ex))
    raise
finally:
    conn.close()
