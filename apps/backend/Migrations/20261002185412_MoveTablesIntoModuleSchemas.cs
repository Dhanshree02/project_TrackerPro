using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class MoveTablesIntoModuleSchemas : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                DO $$
                BEGIN
                    IF to_regclass('public.role_widget_permissions') IS NOT NULL THEN
                        ALTER TABLE public.role_widget_permissions
                            DROP CONSTRAINT IF EXISTS "role_widget_permissions_RoleId_fkey";
                    END IF;
                END $$;
                """);

            migrationBuilder.DropForeignKey(
                name: "FK_client_assignments_clients_ClientId",
                table: "client_assignments");

            migrationBuilder.DropForeignKey(
                name: "FK_client_assignments_users_UserId",
                table: "client_assignments");

            migrationBuilder.DropForeignKey(
                name: "FK_client_contacts_clients_ClientId",
                table: "client_contacts");

            migrationBuilder.DropForeignKey(
                name: "FK_client_contacts_sub_ventures_SubVentureId",
                table: "client_contacts");

            migrationBuilder.DropForeignKey(
                name: "FK_clients_employees_EngagementManagerId",
                table: "clients");

            migrationBuilder.DropForeignKey(
                name: "FK_clients_employees_SalesManagerId",
                table: "clients");

            migrationBuilder.DropForeignKey(
                name: "FK_clients_mst_cities_CityId",
                table: "clients");

            migrationBuilder.DropForeignKey(
                name: "FK_clients_mst_countries_CountryId",
                table: "clients");

            migrationBuilder.DropForeignKey(
                name: "FK_clients_mst_industries_IndustryId",
                table: "clients");

            migrationBuilder.DropForeignKey(
                name: "FK_employee_activity_logs_employees_EmployeeId",
                table: "employee_activity_logs");

            migrationBuilder.DropForeignKey(
                name: "FK_employees_employees_EngagementManagerEmployeeId",
                table: "employees");

            migrationBuilder.DropForeignKey(
                name: "FK_employees_employees_ProjectManagerId",
                table: "employees");

            migrationBuilder.DropForeignKey(
                name: "FK_employees_employees_ReportingManagerId",
                table: "employees");

            migrationBuilder.DropForeignKey(
                name: "FK_employees_mst_departments_DepartmentId",
                table: "employees");

            migrationBuilder.DropForeignKey(
                name: "FK_employees_mst_designations_DesignationId",
                table: "employees");

            migrationBuilder.DropForeignKey(
                name: "FK_employees_mst_employee_statuses_EmployeeStatusId",
                table: "employees");

            migrationBuilder.DropForeignKey(
                name: "FK_employees_mst_nationalities_NationalityId",
                table: "employees");

            migrationBuilder.DropForeignKey(
                name: "FK_employees_mst_roles_JobRoleId",
                table: "employees");

            migrationBuilder.DropForeignKey(
                name: "FK_employees_mst_salary_bands_SalaryBandId",
                table: "employees");

            migrationBuilder.DropForeignKey(
                name: "FK_employees_users_UserId",
                table: "employees");

            migrationBuilder.DropForeignKey(
                name: "FK_mst_designations_roles_DefaultRoleId",
                table: "mst_designations");

            migrationBuilder.DropForeignKey(
                name: "FK_mst_reporting_managers_employees_EmployeeId",
                table: "mst_reporting_managers");

            migrationBuilder.DropForeignKey(
                name: "FK_project_documents_projects_ProjectId",
                table: "project_documents");

            migrationBuilder.DropForeignKey(
                name: "FK_project_invoices_projects_ProjectId",
                table: "project_invoices");

            migrationBuilder.DropForeignKey(
                name: "FK_project_services_mst_service_catalog_ServiceCatalogId",
                table: "project_services");

            migrationBuilder.DropForeignKey(
                name: "FK_project_services_projects_ProjectId",
                table: "project_services");

            migrationBuilder.DropForeignKey(
                name: "FK_project_task_assignment_history_employees_EmployeeId",
                table: "project_task_assignment_history");

            migrationBuilder.DropForeignKey(
                name: "FK_project_task_assignment_history_project_tasks_TaskId",
                table: "project_task_assignment_history");

            migrationBuilder.DropForeignKey(
                name: "FK_project_task_assignments_employees_EmployeeId",
                table: "project_task_assignments");

            migrationBuilder.DropForeignKey(
                name: "FK_project_task_assignments_project_tasks_TaskId",
                table: "project_task_assignments");

            migrationBuilder.DropForeignKey(
                name: "FK_project_tasks_project_services_ProjectServiceId",
                table: "project_tasks");

            migrationBuilder.DropForeignKey(
                name: "FK_project_tasks_projects_ProjectId",
                table: "project_tasks");

            migrationBuilder.DropForeignKey(
                name: "FK_project_team_members_employees_EmployeeId",
                table: "project_team_members");

            migrationBuilder.DropForeignKey(
                name: "FK_project_team_members_mst_departments_DepartmentId",
                table: "project_team_members");

            migrationBuilder.DropForeignKey(
                name: "FK_project_team_members_projects_ProjectId",
                table: "project_team_members");

            migrationBuilder.DropForeignKey(
                name: "FK_projects_clients_ClientId",
                table: "projects");

            migrationBuilder.DropForeignKey(
                name: "FK_projects_employees_EngagementManagerId",
                table: "projects");

            migrationBuilder.DropForeignKey(
                name: "FK_projects_employees_ProjectManagerId",
                table: "projects");

            migrationBuilder.DropForeignKey(
                name: "FK_projects_employees_SalesPersonId",
                table: "projects");

            migrationBuilder.DropForeignKey(
                name: "FK_projects_employees_TeamLeadId",
                table: "projects");

            migrationBuilder.DropForeignKey(
                name: "FK_projects_projects_RenewedFromProjectId",
                table: "projects");

            migrationBuilder.DropForeignKey(
                name: "FK_projects_sub_ventures_SubVentureId",
                table: "projects");

            migrationBuilder.DropForeignKey(
                name: "FK_repository_departments_mst_departments_DepartmentId",
                table: "repository_departments");

            migrationBuilder.DropForeignKey(
                name: "FK_repository_departments_repository_RepositoryItemId",
                table: "repository_departments");

            migrationBuilder.DropForeignKey(
                name: "FK_role_permission_audits_roles_RoleId",
                table: "role_permission_audits");

            migrationBuilder.DropForeignKey(
                name: "FK_sub_ventures_clients_ClientId",
                table: "sub_ventures");

            migrationBuilder.DropForeignKey(
                name: "FK_team_day_entries_employees_EmployeeId",
                table: "team_day_entries");

            migrationBuilder.DropForeignKey(
                name: "FK_team_member_holidays_employees_EmployeeId",
                table: "team_member_holidays");

            migrationBuilder.DropForeignKey(
                name: "FK_team_member_schedules_employees_EmployeeId",
                table: "team_member_schedules");

            migrationBuilder.DropForeignKey(
                name: "FK_timesheet_entries_timesheets_TimesheetWeekId",
                table: "timesheet_entries");

            migrationBuilder.DropForeignKey(
                name: "FK_timesheet_entry_days_timesheet_entries_TimesheetEntryId",
                table: "timesheet_entry_days");

            migrationBuilder.DropForeignKey(
                name: "FK_timesheets_employees_EmployeeId",
                table: "timesheets");

            migrationBuilder.DropForeignKey(
                name: "FK_users_roles_RoleId",
                table: "users");

            migrationBuilder.DropForeignKey(
                name: "FK_refresh_tokens_users_UserId",
                table: "refresh_tokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_refresh_tokens",
                table: "refresh_tokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_users",
                table: "users");

            migrationBuilder.DropPrimaryKey(
                name: "PK_timesheets",
                table: "timesheets");

            migrationBuilder.DropPrimaryKey(
                name: "PK_timesheet_entry_days",
                table: "timesheet_entry_days");

            migrationBuilder.DropPrimaryKey(
                name: "PK_timesheet_entries",
                table: "timesheet_entries");

            migrationBuilder.DropPrimaryKey(
                name: "PK_team_member_schedules",
                table: "team_member_schedules");

            migrationBuilder.DropPrimaryKey(
                name: "PK_team_member_holidays",
                table: "team_member_holidays");

            migrationBuilder.DropPrimaryKey(
                name: "PK_team_day_entries",
                table: "team_day_entries");

            migrationBuilder.DropPrimaryKey(
                name: "PK_sub_ventures",
                table: "sub_ventures");

            migrationBuilder.DropPrimaryKey(
                name: "PK_roles",
                table: "roles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_role_permission_audits",
                table: "role_permission_audits");

            migrationBuilder.DropPrimaryKey(
                name: "PK_repository_departments",
                table: "repository_departments");

            migrationBuilder.DropPrimaryKey(
                name: "PK_repository_activity_logs",
                table: "repository_activity_logs");

            migrationBuilder.DropPrimaryKey(
                name: "PK_repository",
                table: "repository");

            migrationBuilder.DropPrimaryKey(
                name: "PK_projects",
                table: "projects");

            migrationBuilder.DropPrimaryKey(
                name: "PK_project_team_members",
                table: "project_team_members");

            migrationBuilder.DropPrimaryKey(
                name: "PK_project_tasks",
                table: "project_tasks");

            migrationBuilder.DropPrimaryKey(
                name: "PK_project_task_assignments",
                table: "project_task_assignments");

            migrationBuilder.DropPrimaryKey(
                name: "PK_project_task_assignment_history",
                table: "project_task_assignment_history");

            migrationBuilder.DropPrimaryKey(
                name: "PK_project_services",
                table: "project_services");

            migrationBuilder.DropPrimaryKey(
                name: "PK_project_invoices",
                table: "project_invoices");

            migrationBuilder.DropPrimaryKey(
                name: "PK_project_drafts",
                table: "project_drafts");

            migrationBuilder.DropPrimaryKey(
                name: "PK_project_documents",
                table: "project_documents");

            migrationBuilder.DropPrimaryKey(
                name: "PK_exited_employees",
                table: "exited_employees");

            migrationBuilder.DropPrimaryKey(
                name: "PK_employees",
                table: "employees");

            migrationBuilder.DropPrimaryKey(
                name: "PK_employee_activity_logs",
                table: "employee_activity_logs");

            migrationBuilder.DropPrimaryKey(
                name: "PK_clients",
                table: "clients");

            migrationBuilder.DropPrimaryKey(
                name: "PK_client_contacts",
                table: "client_contacts");

            migrationBuilder.DropPrimaryKey(
                name: "PK_client_assignments",
                table: "client_assignments");

            migrationBuilder.EnsureSchema(
                name: "resource");

            migrationBuilder.EnsureSchema(
                name: "project");

            migrationBuilder.EnsureSchema(
                name: "repository");

            migrationBuilder.EnsureSchema(
                name: "auth");

            migrationBuilder.EnsureSchema(
                name: "master");

            migrationBuilder.EnsureSchema(
                name: "customer");

            migrationBuilder.EnsureSchema(
                name: "timesheet");

            migrationBuilder.RenameTable(
                name: "mst_work_locations",
                newName: "mst_work_locations",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_service_sub_departments",
                newName: "mst_service_sub_departments",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_service_groups",
                newName: "mst_service_groups",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_service_departments",
                newName: "mst_service_departments",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_service_catalog",
                newName: "mst_service_catalog",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_salary_bands",
                newName: "mst_salary_bands",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_roles",
                newName: "mst_roles",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_reporting_managers",
                newName: "mst_reporting_managers",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_post_graduation_degrees",
                newName: "mst_post_graduation_degrees",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_offices",
                newName: "mst_offices",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_nationalities",
                newName: "mst_nationalities",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_industries",
                newName: "mst_industries",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_graduation_degrees",
                newName: "mst_graduation_degrees",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_employee_statuses",
                newName: "mst_employee_statuses",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_email_domains",
                newName: "mst_email_domains",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_designations",
                newName: "mst_designations",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_departments",
                newName: "mst_departments",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_countries",
                newName: "mst_countries",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_contact_types",
                newName: "mst_contact_types",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_contact_designations",
                newName: "mst_contact_designations",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_cities",
                newName: "mst_cities",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_certifications",
                newName: "mst_certifications",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "mst_business_units",
                newName: "mst_business_units",
                newSchema: "master");

            migrationBuilder.RenameTable(
                name: "users",
                newName: "tbl_users",
                newSchema: "auth");

            migrationBuilder.RenameTable(
                name: "timesheets",
                newName: "tbl_timesheets",
                newSchema: "timesheet");

            migrationBuilder.RenameTable(
                name: "timesheet_entry_days",
                newName: "tbl_timesheet_entry_days",
                newSchema: "timesheet");

            migrationBuilder.RenameTable(
                name: "timesheet_entries",
                newName: "tbl_timesheet_entries",
                newSchema: "timesheet");

            migrationBuilder.RenameTable(
                name: "team_member_schedules",
                newName: "tbl_team_member_schedules",
                newSchema: "timesheet");

            migrationBuilder.RenameTable(
                name: "team_member_holidays",
                newName: "tbl_team_member_holidays",
                newSchema: "timesheet");

            migrationBuilder.RenameTable(
                name: "team_day_entries",
                newName: "tbl_team_day_entries",
                newSchema: "timesheet");

            migrationBuilder.RenameTable(
                name: "sub_ventures",
                newName: "tbl_sub_ventures",
                newSchema: "customer");

            migrationBuilder.RenameTable(
                name: "roles",
                newName: "tbl_roles",
                newSchema: "auth");

            migrationBuilder.RenameTable(
                name: "role_permission_audits",
                newName: "log_role_permission_audits",
                newSchema: "auth");

            migrationBuilder.RenameTable(
                name: "repository_departments",
                newName: "tbl_repository_departments",
                newSchema: "repository");

            migrationBuilder.RenameTable(
                name: "repository_activity_logs",
                newName: "log_repository_activity",
                newSchema: "repository");

            migrationBuilder.RenameTable(
                name: "repository",
                newName: "tbl_repository_items",
                newSchema: "repository");

            migrationBuilder.RenameTable(
                name: "projects",
                newName: "tbl_projects",
                newSchema: "project");

            migrationBuilder.RenameTable(
                name: "project_team_members",
                newName: "tbl_project_team_members",
                newSchema: "project");

            migrationBuilder.RenameTable(
                name: "project_tasks",
                newName: "tbl_project_tasks",
                newSchema: "project");

            migrationBuilder.RenameTable(
                name: "project_task_assignments",
                newName: "tbl_project_task_assignments",
                newSchema: "project");

            migrationBuilder.RenameTable(
                name: "project_task_assignment_history",
                newName: "log_project_task_assignments",
                newSchema: "project");

            migrationBuilder.RenameTable(
                name: "project_services",
                newName: "tbl_project_services",
                newSchema: "project");

            migrationBuilder.RenameTable(
                name: "project_invoices",
                newName: "tbl_project_invoices",
                newSchema: "project");

            migrationBuilder.RenameTable(
                name: "project_drafts",
                newName: "tbl_project_drafts",
                newSchema: "project");

            migrationBuilder.RenameTable(
                name: "project_documents",
                newName: "tbl_project_documents",
                newSchema: "project");

            migrationBuilder.RenameTable(
                name: "exited_employees",
                newName: "tbl_exited_employees",
                newSchema: "resource");

            migrationBuilder.RenameTable(
                name: "employees",
                newName: "tbl_employees",
                newSchema: "resource");

            migrationBuilder.RenameTable(
                name: "employee_activity_logs",
                newName: "log_employee_activity",
                newSchema: "resource");

            migrationBuilder.RenameTable(
                name: "clients",
                newName: "tbl_clients",
                newSchema: "customer");

            migrationBuilder.RenameTable(
                name: "client_contacts",
                newName: "tbl_client_contacts",
                newSchema: "customer");

            migrationBuilder.RenameTable(
                name: "client_assignments",
                newName: "tbl_client_assignments",
                newSchema: "customer");

            migrationBuilder.RenameTable(
                name: "refresh_tokens",
                newName: "tbl_refresh_tokens",
                newSchema: "auth");

            migrationBuilder.RenameIndex(
                name: "IX_users_RoleId",
                schema: "auth",
                table: "tbl_users",
                newName: "IX_tbl_users_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_users_EmployeeId",
                schema: "auth",
                table: "tbl_users",
                newName: "IX_tbl_users_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_users_Email",
                schema: "auth",
                table: "tbl_users",
                newName: "IX_tbl_users_Email");

            migrationBuilder.RenameIndex(
                name: "IX_timesheets_EmployeeId_WeekStart",
                schema: "timesheet",
                table: "tbl_timesheets",
                newName: "IX_tbl_timesheets_EmployeeId_WeekStart");

            migrationBuilder.RenameIndex(
                name: "IX_timesheet_entry_days_TimesheetEntryId_DayIndex",
                schema: "timesheet",
                table: "tbl_timesheet_entry_days",
                newName: "IX_tbl_timesheet_entry_days_TimesheetEntryId_DayIndex");

            migrationBuilder.RenameIndex(
                name: "IX_timesheet_entries_TimesheetWeekId",
                schema: "timesheet",
                table: "tbl_timesheet_entries",
                newName: "IX_tbl_timesheet_entries_TimesheetWeekId");

            migrationBuilder.RenameIndex(
                name: "IX_team_member_schedules_EmployeeId",
                schema: "timesheet",
                table: "tbl_team_member_schedules",
                newName: "IX_tbl_team_member_schedules_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_team_member_holidays_EmployeeId_HolidayDate",
                schema: "timesheet",
                table: "tbl_team_member_holidays",
                newName: "IX_tbl_team_member_holidays_EmployeeId_HolidayDate");

            migrationBuilder.RenameIndex(
                name: "IX_team_day_entries_EmployeeId_WorkDate",
                schema: "timesheet",
                table: "tbl_team_day_entries",
                newName: "IX_tbl_team_day_entries_EmployeeId_WorkDate");

            migrationBuilder.RenameIndex(
                name: "IX_sub_ventures_ClientId",
                schema: "customer",
                table: "tbl_sub_ventures",
                newName: "IX_tbl_sub_ventures_ClientId");

            migrationBuilder.RenameIndex(
                name: "IX_roles_Name",
                schema: "auth",
                table: "tbl_roles",
                newName: "IX_tbl_roles_Name");

            migrationBuilder.RenameIndex(
                name: "IX_role_permission_audits_RoleId",
                schema: "auth",
                table: "log_role_permission_audits",
                newName: "IX_log_role_permission_audits_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_role_permission_audits_CreatedAtUtc",
                schema: "auth",
                table: "log_role_permission_audits",
                newName: "IX_log_role_permission_audits_CreatedAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_repository_departments_DepartmentId",
                schema: "repository",
                table: "tbl_repository_departments",
                newName: "IX_tbl_repository_departments_DepartmentId");

            migrationBuilder.RenameIndex(
                name: "IX_repository_activity_logs_DeletedAtUtc",
                schema: "repository",
                table: "log_repository_activity",
                newName: "IX_log_repository_activity_DeletedAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_repository_activity_logs_CreatedAtUtc",
                schema: "repository",
                table: "log_repository_activity",
                newName: "IX_log_repository_activity_CreatedAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_repository_DeletedAtUtc",
                schema: "repository",
                table: "tbl_repository_items",
                newName: "IX_tbl_repository_items_DeletedAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_repository_Category",
                schema: "repository",
                table: "tbl_repository_items",
                newName: "IX_tbl_repository_items_Category");

            migrationBuilder.RenameIndex(
                name: "IX_projects_WbsStatus",
                schema: "project",
                table: "tbl_projects",
                newName: "IX_tbl_projects_WbsStatus");

            migrationBuilder.RenameIndex(
                name: "IX_projects_WbsId",
                schema: "project",
                table: "tbl_projects",
                newName: "IX_tbl_projects_WbsId");

            migrationBuilder.RenameIndex(
                name: "IX_projects_TeamLeadId",
                schema: "project",
                table: "tbl_projects",
                newName: "IX_tbl_projects_TeamLeadId");

            migrationBuilder.RenameIndex(
                name: "IX_projects_SubVentureId",
                schema: "project",
                table: "tbl_projects",
                newName: "IX_tbl_projects_SubVentureId");

            migrationBuilder.RenameIndex(
                name: "IX_projects_Status",
                schema: "project",
                table: "tbl_projects",
                newName: "IX_tbl_projects_Status");

            migrationBuilder.RenameIndex(
                name: "IX_projects_SalesPersonId",
                schema: "project",
                table: "tbl_projects",
                newName: "IX_tbl_projects_SalesPersonId");

            migrationBuilder.RenameIndex(
                name: "IX_projects_RenewedFromProjectId",
                schema: "project",
                table: "tbl_projects",
                newName: "IX_tbl_projects_RenewedFromProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_projects_ProjectManagerId",
                schema: "project",
                table: "tbl_projects",
                newName: "IX_tbl_projects_ProjectManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_projects_ProjectCode",
                schema: "project",
                table: "tbl_projects",
                newName: "IX_tbl_projects_ProjectCode");

            migrationBuilder.RenameIndex(
                name: "IX_projects_EngagementManagerId",
                schema: "project",
                table: "tbl_projects",
                newName: "IX_tbl_projects_EngagementManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_projects_ClientId",
                schema: "project",
                table: "tbl_projects",
                newName: "IX_tbl_projects_ClientId");

            migrationBuilder.RenameIndex(
                name: "IX_project_team_members_ProjectId_EmployeeId",
                schema: "project",
                table: "tbl_project_team_members",
                newName: "IX_tbl_project_team_members_ProjectId_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_project_team_members_ProjectId",
                schema: "project",
                table: "tbl_project_team_members",
                newName: "IX_tbl_project_team_members_ProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_project_team_members_EmployeeId",
                schema: "project",
                table: "tbl_project_team_members",
                newName: "IX_tbl_project_team_members_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_project_team_members_DepartmentId",
                schema: "project",
                table: "tbl_project_team_members",
                newName: "IX_tbl_project_team_members_DepartmentId");

            migrationBuilder.RenameIndex(
                name: "IX_project_tasks_Stage",
                schema: "project",
                table: "tbl_project_tasks",
                newName: "IX_tbl_project_tasks_Stage");

            migrationBuilder.RenameIndex(
                name: "IX_project_tasks_ProjectServiceId",
                schema: "project",
                table: "tbl_project_tasks",
                newName: "IX_tbl_project_tasks_ProjectServiceId");

            migrationBuilder.RenameIndex(
                name: "IX_project_tasks_ProjectId",
                schema: "project",
                table: "tbl_project_tasks",
                newName: "IX_tbl_project_tasks_ProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_project_tasks_Priority",
                schema: "project",
                table: "tbl_project_tasks",
                newName: "IX_tbl_project_tasks_Priority");

            migrationBuilder.RenameIndex(
                name: "IX_project_task_assignments_TaskId_EmployeeId",
                schema: "project",
                table: "tbl_project_task_assignments",
                newName: "IX_tbl_project_task_assignments_TaskId_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_project_task_assignments_TaskId",
                schema: "project",
                table: "tbl_project_task_assignments",
                newName: "IX_tbl_project_task_assignments_TaskId");

            migrationBuilder.RenameIndex(
                name: "IX_project_task_assignments_EmployeeId",
                schema: "project",
                table: "tbl_project_task_assignments",
                newName: "IX_tbl_project_task_assignments_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_project_task_assignment_history_TaskId_OccurredAtUtc",
                schema: "project",
                table: "log_project_task_assignments",
                newName: "IX_log_project_task_assignments_TaskId_OccurredAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_project_task_assignment_history_TaskId",
                schema: "project",
                table: "log_project_task_assignments",
                newName: "IX_log_project_task_assignments_TaskId");

            migrationBuilder.RenameIndex(
                name: "IX_project_task_assignment_history_EmployeeId",
                schema: "project",
                table: "log_project_task_assignments",
                newName: "IX_log_project_task_assignments_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_project_services_ServiceCatalogId",
                schema: "project",
                table: "tbl_project_services",
                newName: "IX_tbl_project_services_ServiceCatalogId");

            migrationBuilder.RenameIndex(
                name: "IX_project_services_ProjectId",
                schema: "project",
                table: "tbl_project_services",
                newName: "IX_tbl_project_services_ProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_project_invoices_Status",
                schema: "project",
                table: "tbl_project_invoices",
                newName: "IX_tbl_project_invoices_Status");

            migrationBuilder.RenameIndex(
                name: "IX_project_invoices_ProjectId",
                schema: "project",
                table: "tbl_project_invoices",
                newName: "IX_tbl_project_invoices_ProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_project_invoices_InvoiceNumber",
                schema: "project",
                table: "tbl_project_invoices",
                newName: "IX_tbl_project_invoices_InvoiceNumber");

            migrationBuilder.RenameIndex(
                name: "IX_project_drafts_UpdatedAtUtc",
                schema: "project",
                table: "tbl_project_drafts",
                newName: "IX_tbl_project_drafts_UpdatedAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_project_drafts_Status",
                schema: "project",
                table: "tbl_project_drafts",
                newName: "IX_tbl_project_drafts_Status");

            migrationBuilder.RenameIndex(
                name: "IX_project_drafts_ClientId",
                schema: "project",
                table: "tbl_project_drafts",
                newName: "IX_tbl_project_drafts_ClientId");

            migrationBuilder.RenameIndex(
                name: "IX_project_documents_ProjectId",
                schema: "project",
                table: "tbl_project_documents",
                newName: "IX_tbl_project_documents_ProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_project_documents_DocumentType",
                schema: "project",
                table: "tbl_project_documents",
                newName: "IX_tbl_project_documents_DocumentType");

            migrationBuilder.RenameIndex(
                name: "IX_exited_employees_OriginalEmployeeId",
                schema: "resource",
                table: "tbl_exited_employees",
                newName: "IX_tbl_exited_employees_OriginalEmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_exited_employees_EmployeeCode",
                schema: "resource",
                table: "tbl_exited_employees",
                newName: "IX_tbl_exited_employees_EmployeeCode");

            migrationBuilder.RenameIndex(
                name: "IX_employees_WorkEmail",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_WorkEmail");

            migrationBuilder.RenameIndex(
                name: "IX_employees_UserId",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_employees_SalaryBandId",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_SalaryBandId");

            migrationBuilder.RenameIndex(
                name: "IX_employees_ReportingManagerId",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_ReportingManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_employees_ProjectManagerId",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_ProjectManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_employees_NationalityId",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_NationalityId");

            migrationBuilder.RenameIndex(
                name: "IX_employees_JobRoleId",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_JobRoleId");

            migrationBuilder.RenameIndex(
                name: "IX_employees_EngagementManagerEmployeeId",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_EngagementManagerEmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_employees_EmployeeStatusId",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_EmployeeStatusId");

            migrationBuilder.RenameIndex(
                name: "IX_employees_EmployeeCode",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_EmployeeCode");

            migrationBuilder.RenameIndex(
                name: "IX_employees_DesignationId",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_DesignationId");

            migrationBuilder.RenameIndex(
                name: "IX_employees_DepartmentId",
                schema: "resource",
                table: "tbl_employees",
                newName: "IX_tbl_employees_DepartmentId");

            migrationBuilder.RenameIndex(
                name: "IX_employee_activity_logs_EmployeeId",
                schema: "resource",
                table: "log_employee_activity",
                newName: "IX_log_employee_activity_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_employee_activity_logs_CreatedAtUtc",
                schema: "resource",
                table: "log_employee_activity",
                newName: "IX_log_employee_activity_CreatedAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_clients_SalesManagerId",
                schema: "customer",
                table: "tbl_clients",
                newName: "IX_tbl_clients_SalesManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_clients_Name",
                schema: "customer",
                table: "tbl_clients",
                newName: "IX_tbl_clients_Name");

            migrationBuilder.RenameIndex(
                name: "IX_clients_IndustryId",
                schema: "customer",
                table: "tbl_clients",
                newName: "IX_tbl_clients_IndustryId");

            migrationBuilder.RenameIndex(
                name: "IX_clients_EngagementManagerId",
                schema: "customer",
                table: "tbl_clients",
                newName: "IX_tbl_clients_EngagementManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_clients_CountryId",
                schema: "customer",
                table: "tbl_clients",
                newName: "IX_tbl_clients_CountryId");

            migrationBuilder.RenameIndex(
                name: "IX_clients_CityId",
                schema: "customer",
                table: "tbl_clients",
                newName: "IX_tbl_clients_CityId");

            migrationBuilder.RenameIndex(
                name: "IX_client_contacts_SubVentureId",
                schema: "customer",
                table: "tbl_client_contacts",
                newName: "IX_tbl_client_contacts_SubVentureId");

            migrationBuilder.RenameIndex(
                name: "IX_client_contacts_ClientId",
                schema: "customer",
                table: "tbl_client_contacts",
                newName: "IX_tbl_client_contacts_ClientId");

            migrationBuilder.RenameIndex(
                name: "IX_client_assignments_UserId",
                schema: "customer",
                table: "tbl_client_assignments",
                newName: "IX_tbl_client_assignments_UserId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_users",
                schema: "auth",
                table: "tbl_users",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_timesheets",
                schema: "timesheet",
                table: "tbl_timesheets",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_timesheet_entry_days",
                schema: "timesheet",
                table: "tbl_timesheet_entry_days",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_timesheet_entries",
                schema: "timesheet",
                table: "tbl_timesheet_entries",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_team_member_schedules",
                schema: "timesheet",
                table: "tbl_team_member_schedules",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_team_member_holidays",
                schema: "timesheet",
                table: "tbl_team_member_holidays",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_team_day_entries",
                schema: "timesheet",
                table: "tbl_team_day_entries",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_sub_ventures",
                schema: "customer",
                table: "tbl_sub_ventures",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_roles",
                schema: "auth",
                table: "tbl_roles",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_log_role_permission_audits",
                schema: "auth",
                table: "log_role_permission_audits",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_repository_departments",
                schema: "repository",
                table: "tbl_repository_departments",
                columns: new[] { "RepositoryItemId", "DepartmentId" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_log_repository_activity",
                schema: "repository",
                table: "log_repository_activity",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_repository_items",
                schema: "repository",
                table: "tbl_repository_items",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_projects",
                schema: "project",
                table: "tbl_projects",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_project_team_members",
                schema: "project",
                table: "tbl_project_team_members",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_project_tasks",
                schema: "project",
                table: "tbl_project_tasks",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_project_task_assignments",
                schema: "project",
                table: "tbl_project_task_assignments",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_log_project_task_assignments",
                schema: "project",
                table: "log_project_task_assignments",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_project_services",
                schema: "project",
                table: "tbl_project_services",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_project_invoices",
                schema: "project",
                table: "tbl_project_invoices",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_project_drafts",
                schema: "project",
                table: "tbl_project_drafts",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_project_documents",
                schema: "project",
                table: "tbl_project_documents",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_exited_employees",
                schema: "resource",
                table: "tbl_exited_employees",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_employees",
                schema: "resource",
                table: "tbl_employees",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_log_employee_activity",
                schema: "resource",
                table: "log_employee_activity",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_clients",
                schema: "customer",
                table: "tbl_clients",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_client_contacts",
                schema: "customer",
                table: "tbl_client_contacts",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_client_assignments",
                schema: "customer",
                table: "tbl_client_assignments",
                columns: new[] { "ClientId", "UserId" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_refresh_tokens",
                schema: "auth",
                table: "tbl_refresh_tokens",
                column: "Id");

            migrationBuilder.RenameIndex(
                name: "IX_refresh_tokens_TokenHash",
                schema: "auth",
                table: "tbl_refresh_tokens",
                newName: "IX_tbl_refresh_tokens_TokenHash");

            migrationBuilder.RenameIndex(
                name: "IX_refresh_tokens_UserId",
                schema: "auth",
                table: "tbl_refresh_tokens",
                newName: "IX_tbl_refresh_tokens_UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_refresh_tokens_tbl_users_UserId",
                schema: "auth",
                table: "tbl_refresh_tokens",
                column: "UserId",
                principalSchema: "auth",
                principalTable: "tbl_users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_log_employee_activity_tbl_employees_EmployeeId",
                schema: "resource",
                table: "log_employee_activity",
                column: "EmployeeId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_log_project_task_assignments_tbl_employees_EmployeeId",
                schema: "project",
                table: "log_project_task_assignments",
                column: "EmployeeId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_log_project_task_assignments_tbl_project_tasks_TaskId",
                schema: "project",
                table: "log_project_task_assignments",
                column: "TaskId",
                principalSchema: "project",
                principalTable: "tbl_project_tasks",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_log_role_permission_audits_tbl_roles_RoleId",
                schema: "auth",
                table: "log_role_permission_audits",
                column: "RoleId",
                principalSchema: "auth",
                principalTable: "tbl_roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_mst_designations_tbl_roles_DefaultRoleId",
                schema: "master",
                table: "mst_designations",
                column: "DefaultRoleId",
                principalSchema: "auth",
                principalTable: "tbl_roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_mst_reporting_managers_tbl_employees_EmployeeId",
                schema: "master",
                table: "mst_reporting_managers",
                column: "EmployeeId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_client_assignments_tbl_clients_ClientId",
                schema: "customer",
                table: "tbl_client_assignments",
                column: "ClientId",
                principalSchema: "customer",
                principalTable: "tbl_clients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_client_assignments_tbl_users_UserId",
                schema: "customer",
                table: "tbl_client_assignments",
                column: "UserId",
                principalSchema: "auth",
                principalTable: "tbl_users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_client_contacts_tbl_clients_ClientId",
                schema: "customer",
                table: "tbl_client_contacts",
                column: "ClientId",
                principalSchema: "customer",
                principalTable: "tbl_clients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_client_contacts_tbl_sub_ventures_SubVentureId",
                schema: "customer",
                table: "tbl_client_contacts",
                column: "SubVentureId",
                principalSchema: "customer",
                principalTable: "tbl_sub_ventures",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_clients_mst_cities_CityId",
                schema: "customer",
                table: "tbl_clients",
                column: "CityId",
                principalSchema: "master",
                principalTable: "mst_cities",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_clients_mst_countries_CountryId",
                schema: "customer",
                table: "tbl_clients",
                column: "CountryId",
                principalSchema: "master",
                principalTable: "mst_countries",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_clients_mst_industries_IndustryId",
                schema: "customer",
                table: "tbl_clients",
                column: "IndustryId",
                principalSchema: "master",
                principalTable: "mst_industries",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_clients_tbl_employees_EngagementManagerId",
                schema: "customer",
                table: "tbl_clients",
                column: "EngagementManagerId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_clients_tbl_employees_SalesManagerId",
                schema: "customer",
                table: "tbl_clients",
                column: "SalesManagerId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_mst_departments_DepartmentId",
                schema: "resource",
                table: "tbl_employees",
                column: "DepartmentId",
                principalSchema: "master",
                principalTable: "mst_departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_mst_designations_DesignationId",
                schema: "resource",
                table: "tbl_employees",
                column: "DesignationId",
                principalSchema: "master",
                principalTable: "mst_designations",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_mst_employee_statuses_EmployeeStatusId",
                schema: "resource",
                table: "tbl_employees",
                column: "EmployeeStatusId",
                principalSchema: "master",
                principalTable: "mst_employee_statuses",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_mst_nationalities_NationalityId",
                schema: "resource",
                table: "tbl_employees",
                column: "NationalityId",
                principalSchema: "master",
                principalTable: "mst_nationalities",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_mst_roles_JobRoleId",
                schema: "resource",
                table: "tbl_employees",
                column: "JobRoleId",
                principalSchema: "master",
                principalTable: "mst_roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_mst_salary_bands_SalaryBandId",
                schema: "resource",
                table: "tbl_employees",
                column: "SalaryBandId",
                principalSchema: "master",
                principalTable: "mst_salary_bands",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_tbl_employees_EngagementManagerEmployeeId",
                schema: "resource",
                table: "tbl_employees",
                column: "EngagementManagerEmployeeId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_tbl_employees_ProjectManagerId",
                schema: "resource",
                table: "tbl_employees",
                column: "ProjectManagerId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_tbl_employees_ReportingManagerId",
                schema: "resource",
                table: "tbl_employees",
                column: "ReportingManagerId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_tbl_users_UserId",
                schema: "resource",
                table: "tbl_employees",
                column: "UserId",
                principalSchema: "auth",
                principalTable: "tbl_users",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_documents_tbl_projects_ProjectId",
                schema: "project",
                table: "tbl_project_documents",
                column: "ProjectId",
                principalSchema: "project",
                principalTable: "tbl_projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_invoices_tbl_projects_ProjectId",
                schema: "project",
                table: "tbl_project_invoices",
                column: "ProjectId",
                principalSchema: "project",
                principalTable: "tbl_projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_services_mst_service_catalog_ServiceCatalogId",
                schema: "project",
                table: "tbl_project_services",
                column: "ServiceCatalogId",
                principalSchema: "master",
                principalTable: "mst_service_catalog",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_services_tbl_projects_ProjectId",
                schema: "project",
                table: "tbl_project_services",
                column: "ProjectId",
                principalSchema: "project",
                principalTable: "tbl_projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_task_assignments_tbl_employees_EmployeeId",
                schema: "project",
                table: "tbl_project_task_assignments",
                column: "EmployeeId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_task_assignments_tbl_project_tasks_TaskId",
                schema: "project",
                table: "tbl_project_task_assignments",
                column: "TaskId",
                principalSchema: "project",
                principalTable: "tbl_project_tasks",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_tasks_tbl_project_services_ProjectServiceId",
                schema: "project",
                table: "tbl_project_tasks",
                column: "ProjectServiceId",
                principalSchema: "project",
                principalTable: "tbl_project_services",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_tasks_tbl_projects_ProjectId",
                schema: "project",
                table: "tbl_project_tasks",
                column: "ProjectId",
                principalSchema: "project",
                principalTable: "tbl_projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_team_members_mst_departments_DepartmentId",
                schema: "project",
                table: "tbl_project_team_members",
                column: "DepartmentId",
                principalSchema: "master",
                principalTable: "mst_departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_team_members_tbl_employees_EmployeeId",
                schema: "project",
                table: "tbl_project_team_members",
                column: "EmployeeId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_team_members_tbl_projects_ProjectId",
                schema: "project",
                table: "tbl_project_team_members",
                column: "ProjectId",
                principalSchema: "project",
                principalTable: "tbl_projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_projects_tbl_clients_ClientId",
                schema: "project",
                table: "tbl_projects",
                column: "ClientId",
                principalSchema: "customer",
                principalTable: "tbl_clients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_projects_tbl_employees_EngagementManagerId",
                schema: "project",
                table: "tbl_projects",
                column: "EngagementManagerId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_projects_tbl_employees_ProjectManagerId",
                schema: "project",
                table: "tbl_projects",
                column: "ProjectManagerId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_projects_tbl_employees_SalesPersonId",
                schema: "project",
                table: "tbl_projects",
                column: "SalesPersonId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_projects_tbl_employees_TeamLeadId",
                schema: "project",
                table: "tbl_projects",
                column: "TeamLeadId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_projects_tbl_projects_RenewedFromProjectId",
                schema: "project",
                table: "tbl_projects",
                column: "RenewedFromProjectId",
                principalSchema: "project",
                principalTable: "tbl_projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_projects_tbl_sub_ventures_SubVentureId",
                schema: "project",
                table: "tbl_projects",
                column: "SubVentureId",
                principalSchema: "customer",
                principalTable: "tbl_sub_ventures",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_repository_departments_mst_departments_DepartmentId",
                schema: "repository",
                table: "tbl_repository_departments",
                column: "DepartmentId",
                principalSchema: "master",
                principalTable: "mst_departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_repository_departments_tbl_repository_items_RepositoryI~",
                schema: "repository",
                table: "tbl_repository_departments",
                column: "RepositoryItemId",
                principalSchema: "repository",
                principalTable: "tbl_repository_items",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_sub_ventures_tbl_clients_ClientId",
                schema: "customer",
                table: "tbl_sub_ventures",
                column: "ClientId",
                principalSchema: "customer",
                principalTable: "tbl_clients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_team_day_entries_tbl_employees_EmployeeId",
                schema: "timesheet",
                table: "tbl_team_day_entries",
                column: "EmployeeId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_team_member_holidays_tbl_employees_EmployeeId",
                schema: "timesheet",
                table: "tbl_team_member_holidays",
                column: "EmployeeId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_team_member_schedules_tbl_employees_EmployeeId",
                schema: "timesheet",
                table: "tbl_team_member_schedules",
                column: "EmployeeId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_timesheet_entries_tbl_timesheets_TimesheetWeekId",
                schema: "timesheet",
                table: "tbl_timesheet_entries",
                column: "TimesheetWeekId",
                principalSchema: "timesheet",
                principalTable: "tbl_timesheets",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_timesheet_entry_days_tbl_timesheet_entries_TimesheetEnt~",
                schema: "timesheet",
                table: "tbl_timesheet_entry_days",
                column: "TimesheetEntryId",
                principalSchema: "timesheet",
                principalTable: "tbl_timesheet_entries",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_timesheets_tbl_employees_EmployeeId",
                schema: "timesheet",
                table: "tbl_timesheets",
                column: "EmployeeId",
                principalSchema: "resource",
                principalTable: "tbl_employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_users_tbl_roles_RoleId",
                schema: "auth",
                table: "tbl_users",
                column: "RoleId",
                principalSchema: "auth",
                principalTable: "tbl_roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.Sql(
                """
                DO $$
                BEGIN
                    IF to_regclass('public.mst_entra_roles') IS NOT NULL THEN
                        ALTER TABLE public.mst_entra_roles SET SCHEMA master;
                    END IF;
                    IF to_regclass('public.mst_modules') IS NOT NULL THEN
                        ALTER TABLE public.mst_modules SET SCHEMA master;
                    END IF;
                    IF to_regclass('public.mst_submodules') IS NOT NULL THEN
                        ALTER TABLE public.mst_submodules SET SCHEMA master;
                    END IF;
                    IF to_regclass('public.mst_widgets') IS NOT NULL THEN
                        ALTER TABLE public.mst_widgets SET SCHEMA master;
                    END IF;
                    IF to_regclass('public.role_widget_permissions') IS NOT NULL THEN
                        ALTER TABLE public.role_widget_permissions SET SCHEMA auth;
                        ALTER TABLE auth.role_widget_permissions RENAME TO tbl_role_widget_permissions;
                    END IF;
                    IF to_regclass('public.vw_role_widget_matrix') IS NOT NULL THEN
                        ALTER VIEW public.vw_role_widget_matrix SET SCHEMA auth;
                    END IF;
                    IF to_regclass('auth.tbl_role_widget_permissions') IS NOT NULL
                       AND NOT EXISTS (
                            SELECT 1 FROM pg_constraint WHERE conname = 'role_widget_permissions_RoleId_fkey'
                       ) THEN
                        ALTER TABLE auth.tbl_role_widget_permissions
                            ADD CONSTRAINT "role_widget_permissions_RoleId_fkey"
                            FOREIGN KEY ("RoleId") REFERENCES auth.tbl_roles ("Id") ON DELETE CASCADE;
                    END IF;
                END $$;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                DO $$
                BEGIN
                    IF to_regclass('auth.tbl_role_widget_permissions') IS NOT NULL THEN
                        ALTER TABLE auth.tbl_role_widget_permissions
                            DROP CONSTRAINT IF EXISTS "role_widget_permissions_RoleId_fkey";
                    END IF;
                END $$;
                """);
            migrationBuilder.DropForeignKey(
                name: "FK_log_employee_activity_tbl_employees_EmployeeId",
                schema: "resource",
                table: "log_employee_activity");

            migrationBuilder.DropForeignKey(
                name: "FK_log_project_task_assignments_tbl_employees_EmployeeId",
                schema: "project",
                table: "log_project_task_assignments");

            migrationBuilder.DropForeignKey(
                name: "FK_log_project_task_assignments_tbl_project_tasks_TaskId",
                schema: "project",
                table: "log_project_task_assignments");

            migrationBuilder.DropForeignKey(
                name: "FK_log_role_permission_audits_tbl_roles_RoleId",
                schema: "auth",
                table: "log_role_permission_audits");

            migrationBuilder.DropForeignKey(
                name: "FK_mst_designations_tbl_roles_DefaultRoleId",
                schema: "master",
                table: "mst_designations");

            migrationBuilder.DropForeignKey(
                name: "FK_mst_reporting_managers_tbl_employees_EmployeeId",
                schema: "master",
                table: "mst_reporting_managers");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_client_assignments_tbl_clients_ClientId",
                schema: "customer",
                table: "tbl_client_assignments");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_client_assignments_tbl_users_UserId",
                schema: "customer",
                table: "tbl_client_assignments");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_client_contacts_tbl_clients_ClientId",
                schema: "customer",
                table: "tbl_client_contacts");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_client_contacts_tbl_sub_ventures_SubVentureId",
                schema: "customer",
                table: "tbl_client_contacts");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_clients_mst_cities_CityId",
                schema: "customer",
                table: "tbl_clients");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_clients_mst_countries_CountryId",
                schema: "customer",
                table: "tbl_clients");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_clients_mst_industries_IndustryId",
                schema: "customer",
                table: "tbl_clients");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_clients_tbl_employees_EngagementManagerId",
                schema: "customer",
                table: "tbl_clients");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_clients_tbl_employees_SalesManagerId",
                schema: "customer",
                table: "tbl_clients");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_mst_departments_DepartmentId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_mst_designations_DesignationId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_mst_employee_statuses_EmployeeStatusId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_mst_nationalities_NationalityId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_mst_roles_JobRoleId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_mst_salary_bands_SalaryBandId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_tbl_employees_EngagementManagerEmployeeId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_tbl_employees_ProjectManagerId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_tbl_employees_ReportingManagerId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_tbl_users_UserId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_documents_tbl_projects_ProjectId",
                schema: "project",
                table: "tbl_project_documents");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_invoices_tbl_projects_ProjectId",
                schema: "project",
                table: "tbl_project_invoices");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_services_mst_service_catalog_ServiceCatalogId",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_services_tbl_projects_ProjectId",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_task_assignments_tbl_employees_EmployeeId",
                schema: "project",
                table: "tbl_project_task_assignments");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_task_assignments_tbl_project_tasks_TaskId",
                schema: "project",
                table: "tbl_project_task_assignments");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_tasks_tbl_project_services_ProjectServiceId",
                schema: "project",
                table: "tbl_project_tasks");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_tasks_tbl_projects_ProjectId",
                schema: "project",
                table: "tbl_project_tasks");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_team_members_mst_departments_DepartmentId",
                schema: "project",
                table: "tbl_project_team_members");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_team_members_tbl_employees_EmployeeId",
                schema: "project",
                table: "tbl_project_team_members");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_team_members_tbl_projects_ProjectId",
                schema: "project",
                table: "tbl_project_team_members");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_projects_tbl_clients_ClientId",
                schema: "project",
                table: "tbl_projects");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_projects_tbl_employees_EngagementManagerId",
                schema: "project",
                table: "tbl_projects");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_projects_tbl_employees_ProjectManagerId",
                schema: "project",
                table: "tbl_projects");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_projects_tbl_employees_SalesPersonId",
                schema: "project",
                table: "tbl_projects");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_projects_tbl_employees_TeamLeadId",
                schema: "project",
                table: "tbl_projects");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_projects_tbl_projects_RenewedFromProjectId",
                schema: "project",
                table: "tbl_projects");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_projects_tbl_sub_ventures_SubVentureId",
                schema: "project",
                table: "tbl_projects");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_repository_departments_mst_departments_DepartmentId",
                schema: "repository",
                table: "tbl_repository_departments");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_repository_departments_tbl_repository_items_RepositoryI~",
                schema: "repository",
                table: "tbl_repository_departments");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_sub_ventures_tbl_clients_ClientId",
                schema: "customer",
                table: "tbl_sub_ventures");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_team_day_entries_tbl_employees_EmployeeId",
                schema: "timesheet",
                table: "tbl_team_day_entries");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_team_member_holidays_tbl_employees_EmployeeId",
                schema: "timesheet",
                table: "tbl_team_member_holidays");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_team_member_schedules_tbl_employees_EmployeeId",
                schema: "timesheet",
                table: "tbl_team_member_schedules");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_timesheet_entries_tbl_timesheets_TimesheetWeekId",
                schema: "timesheet",
                table: "tbl_timesheet_entries");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_timesheet_entry_days_tbl_timesheet_entries_TimesheetEnt~",
                schema: "timesheet",
                table: "tbl_timesheet_entry_days");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_timesheets_tbl_employees_EmployeeId",
                schema: "timesheet",
                table: "tbl_timesheets");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_users_tbl_roles_RoleId",
                schema: "auth",
                table: "tbl_users");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_refresh_tokens_tbl_users_UserId",
                schema: "auth",
                table: "tbl_refresh_tokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_refresh_tokens",
                schema: "auth",
                table: "tbl_refresh_tokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_users",
                schema: "auth",
                table: "tbl_users");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_timesheets",
                schema: "timesheet",
                table: "tbl_timesheets");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_timesheet_entry_days",
                schema: "timesheet",
                table: "tbl_timesheet_entry_days");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_timesheet_entries",
                schema: "timesheet",
                table: "tbl_timesheet_entries");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_team_member_schedules",
                schema: "timesheet",
                table: "tbl_team_member_schedules");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_team_member_holidays",
                schema: "timesheet",
                table: "tbl_team_member_holidays");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_team_day_entries",
                schema: "timesheet",
                table: "tbl_team_day_entries");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_sub_ventures",
                schema: "customer",
                table: "tbl_sub_ventures");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_roles",
                schema: "auth",
                table: "tbl_roles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_repository_items",
                schema: "repository",
                table: "tbl_repository_items");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_repository_departments",
                schema: "repository",
                table: "tbl_repository_departments");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_projects",
                schema: "project",
                table: "tbl_projects");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_project_team_members",
                schema: "project",
                table: "tbl_project_team_members");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_project_tasks",
                schema: "project",
                table: "tbl_project_tasks");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_project_task_assignments",
                schema: "project",
                table: "tbl_project_task_assignments");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_project_services",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_project_invoices",
                schema: "project",
                table: "tbl_project_invoices");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_project_drafts",
                schema: "project",
                table: "tbl_project_drafts");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_project_documents",
                schema: "project",
                table: "tbl_project_documents");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_exited_employees",
                schema: "resource",
                table: "tbl_exited_employees");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_employees",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_clients",
                schema: "customer",
                table: "tbl_clients");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_client_contacts",
                schema: "customer",
                table: "tbl_client_contacts");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_client_assignments",
                schema: "customer",
                table: "tbl_client_assignments");

            migrationBuilder.DropPrimaryKey(
                name: "PK_log_role_permission_audits",
                schema: "auth",
                table: "log_role_permission_audits");

            migrationBuilder.DropPrimaryKey(
                name: "PK_log_repository_activity",
                schema: "repository",
                table: "log_repository_activity");

            migrationBuilder.DropPrimaryKey(
                name: "PK_log_project_task_assignments",
                schema: "project",
                table: "log_project_task_assignments");

            migrationBuilder.DropPrimaryKey(
                name: "PK_log_employee_activity",
                schema: "resource",
                table: "log_employee_activity");

            migrationBuilder.RenameTable(
                name: "mst_work_locations",
                schema: "master",
                newName: "mst_work_locations");

            migrationBuilder.RenameTable(
                name: "mst_service_sub_departments",
                schema: "master",
                newName: "mst_service_sub_departments");

            migrationBuilder.RenameTable(
                name: "mst_service_groups",
                schema: "master",
                newName: "mst_service_groups");

            migrationBuilder.RenameTable(
                name: "mst_service_departments",
                schema: "master",
                newName: "mst_service_departments");

            migrationBuilder.RenameTable(
                name: "mst_service_catalog",
                schema: "master",
                newName: "mst_service_catalog");

            migrationBuilder.RenameTable(
                name: "mst_salary_bands",
                schema: "master",
                newName: "mst_salary_bands");

            migrationBuilder.RenameTable(
                name: "mst_roles",
                schema: "master",
                newName: "mst_roles");

            migrationBuilder.RenameTable(
                name: "mst_reporting_managers",
                schema: "master",
                newName: "mst_reporting_managers");

            migrationBuilder.RenameTable(
                name: "mst_post_graduation_degrees",
                schema: "master",
                newName: "mst_post_graduation_degrees");

            migrationBuilder.RenameTable(
                name: "mst_offices",
                schema: "master",
                newName: "mst_offices");

            migrationBuilder.RenameTable(
                name: "mst_nationalities",
                schema: "master",
                newName: "mst_nationalities");

            migrationBuilder.RenameTable(
                name: "mst_industries",
                schema: "master",
                newName: "mst_industries");

            migrationBuilder.RenameTable(
                name: "mst_graduation_degrees",
                schema: "master",
                newName: "mst_graduation_degrees");

            migrationBuilder.RenameTable(
                name: "mst_employee_statuses",
                schema: "master",
                newName: "mst_employee_statuses");

            migrationBuilder.RenameTable(
                name: "mst_email_domains",
                schema: "master",
                newName: "mst_email_domains");

            migrationBuilder.RenameTable(
                name: "mst_designations",
                schema: "master",
                newName: "mst_designations");

            migrationBuilder.RenameTable(
                name: "mst_departments",
                schema: "master",
                newName: "mst_departments");

            migrationBuilder.RenameTable(
                name: "mst_countries",
                schema: "master",
                newName: "mst_countries");

            migrationBuilder.RenameTable(
                name: "mst_contact_types",
                schema: "master",
                newName: "mst_contact_types");

            migrationBuilder.RenameTable(
                name: "mst_contact_designations",
                schema: "master",
                newName: "mst_contact_designations");

            migrationBuilder.RenameTable(
                name: "mst_cities",
                schema: "master",
                newName: "mst_cities");

            migrationBuilder.RenameTable(
                name: "mst_certifications",
                schema: "master",
                newName: "mst_certifications");

            migrationBuilder.RenameTable(
                name: "mst_business_units",
                schema: "master",
                newName: "mst_business_units");

            migrationBuilder.RenameTable(
                name: "tbl_users",
                schema: "auth",
                newName: "users");

            migrationBuilder.RenameTable(
                name: "tbl_timesheets",
                schema: "timesheet",
                newName: "timesheets");

            migrationBuilder.RenameTable(
                name: "tbl_timesheet_entry_days",
                schema: "timesheet",
                newName: "timesheet_entry_days");

            migrationBuilder.RenameTable(
                name: "tbl_timesheet_entries",
                schema: "timesheet",
                newName: "timesheet_entries");

            migrationBuilder.RenameTable(
                name: "tbl_team_member_schedules",
                schema: "timesheet",
                newName: "team_member_schedules");

            migrationBuilder.RenameTable(
                name: "tbl_team_member_holidays",
                schema: "timesheet",
                newName: "team_member_holidays");

            migrationBuilder.RenameTable(
                name: "tbl_team_day_entries",
                schema: "timesheet",
                newName: "team_day_entries");

            migrationBuilder.RenameTable(
                name: "tbl_sub_ventures",
                schema: "customer",
                newName: "sub_ventures");

            migrationBuilder.RenameTable(
                name: "tbl_roles",
                schema: "auth",
                newName: "roles");

            migrationBuilder.RenameTable(
                name: "tbl_repository_items",
                schema: "repository",
                newName: "repository");

            migrationBuilder.RenameTable(
                name: "tbl_repository_departments",
                schema: "repository",
                newName: "repository_departments");

            migrationBuilder.RenameTable(
                name: "tbl_projects",
                schema: "project",
                newName: "projects");

            migrationBuilder.RenameTable(
                name: "tbl_project_team_members",
                schema: "project",
                newName: "project_team_members");

            migrationBuilder.RenameTable(
                name: "tbl_project_tasks",
                schema: "project",
                newName: "project_tasks");

            migrationBuilder.RenameTable(
                name: "tbl_project_task_assignments",
                schema: "project",
                newName: "project_task_assignments");

            migrationBuilder.RenameTable(
                name: "tbl_project_services",
                schema: "project",
                newName: "project_services");

            migrationBuilder.RenameTable(
                name: "tbl_project_invoices",
                schema: "project",
                newName: "project_invoices");

            migrationBuilder.RenameTable(
                name: "tbl_project_drafts",
                schema: "project",
                newName: "project_drafts");

            migrationBuilder.RenameTable(
                name: "tbl_project_documents",
                schema: "project",
                newName: "project_documents");

            migrationBuilder.RenameTable(
                name: "tbl_exited_employees",
                schema: "resource",
                newName: "exited_employees");

            migrationBuilder.RenameTable(
                name: "tbl_employees",
                schema: "resource",
                newName: "employees");

            migrationBuilder.RenameTable(
                name: "tbl_clients",
                schema: "customer",
                newName: "clients");

            migrationBuilder.RenameTable(
                name: "tbl_client_contacts",
                schema: "customer",
                newName: "client_contacts");

            migrationBuilder.RenameTable(
                name: "tbl_client_assignments",
                schema: "customer",
                newName: "client_assignments");

            migrationBuilder.RenameTable(
                name: "log_role_permission_audits",
                schema: "auth",
                newName: "role_permission_audits");

            migrationBuilder.RenameTable(
                name: "log_repository_activity",
                schema: "repository",
                newName: "repository_activity_logs");

            migrationBuilder.RenameTable(
                name: "log_project_task_assignments",
                schema: "project",
                newName: "project_task_assignment_history");

            migrationBuilder.RenameTable(
                name: "log_employee_activity",
                schema: "resource",
                newName: "employee_activity_logs");

            migrationBuilder.RenameTable(
                name: "tbl_refresh_tokens",
                schema: "auth",
                newName: "refresh_tokens");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_refresh_tokens_TokenHash",
                table: "refresh_tokens",
                newName: "IX_refresh_tokens_TokenHash");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_refresh_tokens_UserId",
                table: "refresh_tokens",
                newName: "IX_refresh_tokens_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_users_RoleId",
                table: "users",
                newName: "IX_users_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_users_EmployeeId",
                table: "users",
                newName: "IX_users_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_users_Email",
                table: "users",
                newName: "IX_users_Email");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_timesheets_EmployeeId_WeekStart",
                table: "timesheets",
                newName: "IX_timesheets_EmployeeId_WeekStart");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_timesheet_entry_days_TimesheetEntryId_DayIndex",
                table: "timesheet_entry_days",
                newName: "IX_timesheet_entry_days_TimesheetEntryId_DayIndex");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_timesheet_entries_TimesheetWeekId",
                table: "timesheet_entries",
                newName: "IX_timesheet_entries_TimesheetWeekId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_team_member_schedules_EmployeeId",
                table: "team_member_schedules",
                newName: "IX_team_member_schedules_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_team_member_holidays_EmployeeId_HolidayDate",
                table: "team_member_holidays",
                newName: "IX_team_member_holidays_EmployeeId_HolidayDate");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_team_day_entries_EmployeeId_WorkDate",
                table: "team_day_entries",
                newName: "IX_team_day_entries_EmployeeId_WorkDate");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_sub_ventures_ClientId",
                table: "sub_ventures",
                newName: "IX_sub_ventures_ClientId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_roles_Name",
                table: "roles",
                newName: "IX_roles_Name");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_repository_items_DeletedAtUtc",
                table: "repository",
                newName: "IX_repository_DeletedAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_repository_items_Category",
                table: "repository",
                newName: "IX_repository_Category");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_repository_departments_DepartmentId",
                table: "repository_departments",
                newName: "IX_repository_departments_DepartmentId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_projects_WbsStatus",
                table: "projects",
                newName: "IX_projects_WbsStatus");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_projects_WbsId",
                table: "projects",
                newName: "IX_projects_WbsId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_projects_TeamLeadId",
                table: "projects",
                newName: "IX_projects_TeamLeadId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_projects_SubVentureId",
                table: "projects",
                newName: "IX_projects_SubVentureId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_projects_Status",
                table: "projects",
                newName: "IX_projects_Status");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_projects_SalesPersonId",
                table: "projects",
                newName: "IX_projects_SalesPersonId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_projects_RenewedFromProjectId",
                table: "projects",
                newName: "IX_projects_RenewedFromProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_projects_ProjectManagerId",
                table: "projects",
                newName: "IX_projects_ProjectManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_projects_ProjectCode",
                table: "projects",
                newName: "IX_projects_ProjectCode");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_projects_EngagementManagerId",
                table: "projects",
                newName: "IX_projects_EngagementManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_projects_ClientId",
                table: "projects",
                newName: "IX_projects_ClientId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_team_members_ProjectId_EmployeeId",
                table: "project_team_members",
                newName: "IX_project_team_members_ProjectId_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_team_members_ProjectId",
                table: "project_team_members",
                newName: "IX_project_team_members_ProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_team_members_EmployeeId",
                table: "project_team_members",
                newName: "IX_project_team_members_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_team_members_DepartmentId",
                table: "project_team_members",
                newName: "IX_project_team_members_DepartmentId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_tasks_Stage",
                table: "project_tasks",
                newName: "IX_project_tasks_Stage");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_tasks_ProjectServiceId",
                table: "project_tasks",
                newName: "IX_project_tasks_ProjectServiceId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_tasks_ProjectId",
                table: "project_tasks",
                newName: "IX_project_tasks_ProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_tasks_Priority",
                table: "project_tasks",
                newName: "IX_project_tasks_Priority");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_task_assignments_TaskId_EmployeeId",
                table: "project_task_assignments",
                newName: "IX_project_task_assignments_TaskId_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_task_assignments_TaskId",
                table: "project_task_assignments",
                newName: "IX_project_task_assignments_TaskId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_task_assignments_EmployeeId",
                table: "project_task_assignments",
                newName: "IX_project_task_assignments_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_services_ServiceCatalogId",
                table: "project_services",
                newName: "IX_project_services_ServiceCatalogId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_services_ProjectId",
                table: "project_services",
                newName: "IX_project_services_ProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_invoices_Status",
                table: "project_invoices",
                newName: "IX_project_invoices_Status");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_invoices_ProjectId",
                table: "project_invoices",
                newName: "IX_project_invoices_ProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_invoices_InvoiceNumber",
                table: "project_invoices",
                newName: "IX_project_invoices_InvoiceNumber");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_drafts_UpdatedAtUtc",
                table: "project_drafts",
                newName: "IX_project_drafts_UpdatedAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_drafts_Status",
                table: "project_drafts",
                newName: "IX_project_drafts_Status");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_drafts_ClientId",
                table: "project_drafts",
                newName: "IX_project_drafts_ClientId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_documents_ProjectId",
                table: "project_documents",
                newName: "IX_project_documents_ProjectId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_project_documents_DocumentType",
                table: "project_documents",
                newName: "IX_project_documents_DocumentType");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_exited_employees_OriginalEmployeeId",
                table: "exited_employees",
                newName: "IX_exited_employees_OriginalEmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_exited_employees_EmployeeCode",
                table: "exited_employees",
                newName: "IX_exited_employees_EmployeeCode");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_WorkEmail",
                table: "employees",
                newName: "IX_employees_WorkEmail");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_UserId",
                table: "employees",
                newName: "IX_employees_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_SalaryBandId",
                table: "employees",
                newName: "IX_employees_SalaryBandId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_ReportingManagerId",
                table: "employees",
                newName: "IX_employees_ReportingManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_ProjectManagerId",
                table: "employees",
                newName: "IX_employees_ProjectManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_NationalityId",
                table: "employees",
                newName: "IX_employees_NationalityId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_JobRoleId",
                table: "employees",
                newName: "IX_employees_JobRoleId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_EngagementManagerEmployeeId",
                table: "employees",
                newName: "IX_employees_EngagementManagerEmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_EmployeeStatusId",
                table: "employees",
                newName: "IX_employees_EmployeeStatusId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_EmployeeCode",
                table: "employees",
                newName: "IX_employees_EmployeeCode");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_DesignationId",
                table: "employees",
                newName: "IX_employees_DesignationId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_employees_DepartmentId",
                table: "employees",
                newName: "IX_employees_DepartmentId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_clients_SalesManagerId",
                table: "clients",
                newName: "IX_clients_SalesManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_clients_Name",
                table: "clients",
                newName: "IX_clients_Name");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_clients_IndustryId",
                table: "clients",
                newName: "IX_clients_IndustryId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_clients_EngagementManagerId",
                table: "clients",
                newName: "IX_clients_EngagementManagerId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_clients_CountryId",
                table: "clients",
                newName: "IX_clients_CountryId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_clients_CityId",
                table: "clients",
                newName: "IX_clients_CityId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_client_contacts_SubVentureId",
                table: "client_contacts",
                newName: "IX_client_contacts_SubVentureId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_client_contacts_ClientId",
                table: "client_contacts",
                newName: "IX_client_contacts_ClientId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_client_assignments_UserId",
                table: "client_assignments",
                newName: "IX_client_assignments_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_log_role_permission_audits_RoleId",
                table: "role_permission_audits",
                newName: "IX_role_permission_audits_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_log_role_permission_audits_CreatedAtUtc",
                table: "role_permission_audits",
                newName: "IX_role_permission_audits_CreatedAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_log_repository_activity_DeletedAtUtc",
                table: "repository_activity_logs",
                newName: "IX_repository_activity_logs_DeletedAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_log_repository_activity_CreatedAtUtc",
                table: "repository_activity_logs",
                newName: "IX_repository_activity_logs_CreatedAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_log_project_task_assignments_TaskId_OccurredAtUtc",
                table: "project_task_assignment_history",
                newName: "IX_project_task_assignment_history_TaskId_OccurredAtUtc");

            migrationBuilder.RenameIndex(
                name: "IX_log_project_task_assignments_TaskId",
                table: "project_task_assignment_history",
                newName: "IX_project_task_assignment_history_TaskId");

            migrationBuilder.RenameIndex(
                name: "IX_log_project_task_assignments_EmployeeId",
                table: "project_task_assignment_history",
                newName: "IX_project_task_assignment_history_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_log_employee_activity_EmployeeId",
                table: "employee_activity_logs",
                newName: "IX_employee_activity_logs_EmployeeId");

            migrationBuilder.RenameIndex(
                name: "IX_log_employee_activity_CreatedAtUtc",
                table: "employee_activity_logs",
                newName: "IX_employee_activity_logs_CreatedAtUtc");

            migrationBuilder.AddPrimaryKey(
                name: "PK_users",
                table: "users",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_timesheets",
                table: "timesheets",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_timesheet_entry_days",
                table: "timesheet_entry_days",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_timesheet_entries",
                table: "timesheet_entries",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_team_member_schedules",
                table: "team_member_schedules",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_team_member_holidays",
                table: "team_member_holidays",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_team_day_entries",
                table: "team_day_entries",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_sub_ventures",
                table: "sub_ventures",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_roles",
                table: "roles",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_repository",
                table: "repository",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_repository_departments",
                table: "repository_departments",
                columns: new[] { "RepositoryItemId", "DepartmentId" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_projects",
                table: "projects",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_project_team_members",
                table: "project_team_members",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_project_tasks",
                table: "project_tasks",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_project_task_assignments",
                table: "project_task_assignments",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_project_services",
                table: "project_services",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_project_invoices",
                table: "project_invoices",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_project_drafts",
                table: "project_drafts",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_project_documents",
                table: "project_documents",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_exited_employees",
                table: "exited_employees",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_employees",
                table: "employees",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_clients",
                table: "clients",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_client_contacts",
                table: "client_contacts",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_client_assignments",
                table: "client_assignments",
                columns: new[] { "ClientId", "UserId" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_role_permission_audits",
                table: "role_permission_audits",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_repository_activity_logs",
                table: "repository_activity_logs",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_project_task_assignment_history",
                table: "project_task_assignment_history",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_employee_activity_logs",
                table: "employee_activity_logs",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_refresh_tokens",
                table: "refresh_tokens",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_refresh_tokens_users_UserId",
                table: "refresh_tokens",
                column: "UserId",
                principalTable: "users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_client_assignments_clients_ClientId",
                table: "client_assignments",
                column: "ClientId",
                principalTable: "clients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_client_assignments_users_UserId",
                table: "client_assignments",
                column: "UserId",
                principalTable: "users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_client_contacts_clients_ClientId",
                table: "client_contacts",
                column: "ClientId",
                principalTable: "clients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_client_contacts_sub_ventures_SubVentureId",
                table: "client_contacts",
                column: "SubVentureId",
                principalTable: "sub_ventures",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_clients_employees_EngagementManagerId",
                table: "clients",
                column: "EngagementManagerId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_clients_employees_SalesManagerId",
                table: "clients",
                column: "SalesManagerId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_clients_mst_cities_CityId",
                table: "clients",
                column: "CityId",
                principalTable: "mst_cities",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_clients_mst_countries_CountryId",
                table: "clients",
                column: "CountryId",
                principalTable: "mst_countries",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_clients_mst_industries_IndustryId",
                table: "clients",
                column: "IndustryId",
                principalTable: "mst_industries",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_employee_activity_logs_employees_EmployeeId",
                table: "employee_activity_logs",
                column: "EmployeeId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_employees_EngagementManagerEmployeeId",
                table: "employees",
                column: "EngagementManagerEmployeeId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_employees_ProjectManagerId",
                table: "employees",
                column: "ProjectManagerId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_employees_ReportingManagerId",
                table: "employees",
                column: "ReportingManagerId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_mst_departments_DepartmentId",
                table: "employees",
                column: "DepartmentId",
                principalTable: "mst_departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_mst_designations_DesignationId",
                table: "employees",
                column: "DesignationId",
                principalTable: "mst_designations",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_mst_employee_statuses_EmployeeStatusId",
                table: "employees",
                column: "EmployeeStatusId",
                principalTable: "mst_employee_statuses",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_mst_nationalities_NationalityId",
                table: "employees",
                column: "NationalityId",
                principalTable: "mst_nationalities",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_mst_roles_JobRoleId",
                table: "employees",
                column: "JobRoleId",
                principalTable: "mst_roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_mst_salary_bands_SalaryBandId",
                table: "employees",
                column: "SalaryBandId",
                principalTable: "mst_salary_bands",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_users_UserId",
                table: "employees",
                column: "UserId",
                principalTable: "users",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_mst_designations_roles_DefaultRoleId",
                table: "mst_designations",
                column: "DefaultRoleId",
                principalTable: "roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_mst_reporting_managers_employees_EmployeeId",
                table: "mst_reporting_managers",
                column: "EmployeeId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_project_documents_projects_ProjectId",
                table: "project_documents",
                column: "ProjectId",
                principalTable: "projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_project_invoices_projects_ProjectId",
                table: "project_invoices",
                column: "ProjectId",
                principalTable: "projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_project_services_mst_service_catalog_ServiceCatalogId",
                table: "project_services",
                column: "ServiceCatalogId",
                principalTable: "mst_service_catalog",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_project_services_projects_ProjectId",
                table: "project_services",
                column: "ProjectId",
                principalTable: "projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_project_task_assignment_history_employees_EmployeeId",
                table: "project_task_assignment_history",
                column: "EmployeeId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_project_task_assignment_history_project_tasks_TaskId",
                table: "project_task_assignment_history",
                column: "TaskId",
                principalTable: "project_tasks",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_project_task_assignments_employees_EmployeeId",
                table: "project_task_assignments",
                column: "EmployeeId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_project_task_assignments_project_tasks_TaskId",
                table: "project_task_assignments",
                column: "TaskId",
                principalTable: "project_tasks",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_project_tasks_project_services_ProjectServiceId",
                table: "project_tasks",
                column: "ProjectServiceId",
                principalTable: "project_services",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_project_tasks_projects_ProjectId",
                table: "project_tasks",
                column: "ProjectId",
                principalTable: "projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_project_team_members_employees_EmployeeId",
                table: "project_team_members",
                column: "EmployeeId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_project_team_members_mst_departments_DepartmentId",
                table: "project_team_members",
                column: "DepartmentId",
                principalTable: "mst_departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_project_team_members_projects_ProjectId",
                table: "project_team_members",
                column: "ProjectId",
                principalTable: "projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_projects_clients_ClientId",
                table: "projects",
                column: "ClientId",
                principalTable: "clients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_projects_employees_EngagementManagerId",
                table: "projects",
                column: "EngagementManagerId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_projects_employees_ProjectManagerId",
                table: "projects",
                column: "ProjectManagerId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_projects_employees_SalesPersonId",
                table: "projects",
                column: "SalesPersonId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_projects_employees_TeamLeadId",
                table: "projects",
                column: "TeamLeadId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_projects_projects_RenewedFromProjectId",
                table: "projects",
                column: "RenewedFromProjectId",
                principalTable: "projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_projects_sub_ventures_SubVentureId",
                table: "projects",
                column: "SubVentureId",
                principalTable: "sub_ventures",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_repository_departments_mst_departments_DepartmentId",
                table: "repository_departments",
                column: "DepartmentId",
                principalTable: "mst_departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_repository_departments_repository_RepositoryItemId",
                table: "repository_departments",
                column: "RepositoryItemId",
                principalTable: "repository",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_role_permission_audits_roles_RoleId",
                table: "role_permission_audits",
                column: "RoleId",
                principalTable: "roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_sub_ventures_clients_ClientId",
                table: "sub_ventures",
                column: "ClientId",
                principalTable: "clients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_team_day_entries_employees_EmployeeId",
                table: "team_day_entries",
                column: "EmployeeId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_team_member_holidays_employees_EmployeeId",
                table: "team_member_holidays",
                column: "EmployeeId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_team_member_schedules_employees_EmployeeId",
                table: "team_member_schedules",
                column: "EmployeeId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_timesheet_entries_timesheets_TimesheetWeekId",
                table: "timesheet_entries",
                column: "TimesheetWeekId",
                principalTable: "timesheets",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_timesheet_entry_days_timesheet_entries_TimesheetEntryId",
                table: "timesheet_entry_days",
                column: "TimesheetEntryId",
                principalTable: "timesheet_entries",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_timesheets_employees_EmployeeId",
                table: "timesheets",
                column: "EmployeeId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_users_roles_RoleId",
                table: "users",
                column: "RoleId",
                principalTable: "roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.Sql(
                """
                DO $$
                BEGIN
                    IF to_regclass('master.mst_entra_roles') IS NOT NULL THEN
                        ALTER TABLE master.mst_entra_roles SET SCHEMA public;
                    END IF;
                    IF to_regclass('master.mst_modules') IS NOT NULL THEN
                        ALTER TABLE master.mst_modules SET SCHEMA public;
                    END IF;
                    IF to_regclass('master.mst_submodules') IS NOT NULL THEN
                        ALTER TABLE master.mst_submodules SET SCHEMA public;
                    END IF;
                    IF to_regclass('master.mst_widgets') IS NOT NULL THEN
                        ALTER TABLE master.mst_widgets SET SCHEMA public;
                    END IF;
                    IF to_regclass('auth.tbl_role_widget_permissions') IS NOT NULL THEN
                        ALTER TABLE auth.tbl_role_widget_permissions RENAME TO role_widget_permissions;
                        ALTER TABLE auth.role_widget_permissions SET SCHEMA public;
                    END IF;
                    IF to_regclass('auth.vw_role_widget_matrix') IS NOT NULL THEN
                        ALTER VIEW auth.vw_role_widget_matrix SET SCHEMA public;
                    END IF;
                    IF to_regclass('public.role_widget_permissions') IS NOT NULL
                       AND NOT EXISTS (
                            SELECT 1 FROM pg_constraint WHERE conname = 'role_widget_permissions_RoleId_fkey'
                       ) THEN
                        ALTER TABLE public.role_widget_permissions
                            ADD CONSTRAINT "role_widget_permissions_RoleId_fkey"
                            FOREIGN KEY ("RoleId") REFERENCES public.roles ("Id") ON DELETE CASCADE;
                    END IF;
                END $$;
                """);
        }
    }
}
