--
-- PostgreSQL database dump
--

\restrict chUxXfzGHMoS56A2MuPWjNgLSpYPNBjLKMo07C3aadZ7Q129HElvOaGUg5I9ZNP

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- Name: client_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client_assignments (
    "ClientId" uuid NOT NULL,
    "UserId" uuid NOT NULL
);


ALTER TABLE public.client_assignments OWNER TO postgres;

--
-- Name: client_contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client_contacts (
    "Id" uuid NOT NULL,
    "ClientId" uuid,
    "SubVentureId" uuid,
    "Name" character varying(150),
    "Email" character varying(255),
    "Phone" character varying(40),
    "Designation" character varying(120),
    "ContactType" character varying(40),
    "IsPrimary" boolean NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "Country" character varying(120),
    "PhoneCode" character varying(16),
    CONSTRAINT "CK_client_contacts_exactly_one_owner" CHECK (((("ClientId" IS NOT NULL) AND ("SubVentureId" IS NULL)) OR (("ClientId" IS NULL) AND ("SubVentureId" IS NOT NULL))))
);


ALTER TABLE public.client_contacts OWNER TO postgres;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients (
    "Id" uuid NOT NULL,
    "Name" character varying(255) NOT NULL,
    "Industry" character varying(100) NOT NULL,
    "Logo" character varying(10),
    "ContactEmail" character varying(255),
    "ClientType" character varying(10) NOT NULL,
    "Status" character varying(20) NOT NULL,
    "EngagementManager" character varying(120),
    "ContactName" character varying(150),
    "ContactPhone" character varying(40),
    "ContactDesignation" character varying(120),
    "ContactType" character varying(40),
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "BusinessType" character varying(40),
    "City" character varying(120),
    "Country" character varying(120),
    "KycDocumentName" character varying(255),
    "Notes" character varying(2000),
    "EngagementManagerId" uuid,
    "IndustryId" uuid,
    "CityId" uuid,
    "CountryId" uuid,
    "CustomerSince" date,
    "SalesManager" character varying(120),
    "SalesManagerId" uuid,
    "KycDocumentPath" character varying(500),
    "BillingMedium" character varying(40),
    "GroupSpocName" character varying(150),
    "GroupSpocContact" character varying(40)
);


ALTER TABLE public.clients OWNER TO postgres;

--
-- Name: employee_activity_logs; Type: TABLE; Schema: public; Owner: trackerpro
--

CREATE TABLE public.employee_activity_logs (
    "Id" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "Action" character varying(50) NOT NULL,
    "PerformedByEmail" character varying(255) NOT NULL,
    "PerformedByName" character varying(255),
    "Details" text,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.employee_activity_logs OWNER TO trackerpro;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    "Id" uuid NOT NULL,
    "EmployeeCode" character varying(20) NOT NULL,
    "FirstName" character varying(120) NOT NULL,
    "LastName" character varying(120) NOT NULL,
    "WorkEmail" character varying(255) NOT NULL,
    "PersonalEmail" character varying(255),
    "Phone" character varying(40),
    "AltPhone" character varying(40),
    "Gender" text,
    "DateOfBirth" date,
    "Address" text,
    "EmergencyContact" text,
    "MaritalStatus" text,
    "Nationality" text,
    "DepartmentId" uuid,
    "DesignationId" uuid,
    "Role" character varying(80),
    "ReportingManagerId" uuid,
    "BusinessUnit" character varying(120),
    "WorkLocation" character varying(120),
    "OfficeBranch" character varying(120),
    "Category" character varying(80),
    "Team" character varying(120),
    "ProjectSite" character varying(80),
    "JoiningDate" date,
    "Status" character varying(60),
    "ConfirmationStatus" character varying(80),
    "ProbationStatus" character varying(80),
    "Experience" character varying(80),
    "PreviousCompany" character varying(160),
    "EmploymentType" character varying(80),
    "ContractType" character varying(80),
    "BondStatus" character varying(80),
    "NoticePeriod" character varying(80),
    "AssetId" character varying(80),
    "ExitType" character varying(80),
    "ExitReason" character varying(500),
    "Education" character varying(255),
    "Skills" jsonb NOT NULL,
    "Certifications" jsonb NOT NULL,
    "Languages" jsonb NOT NULL,
    "KpiScore" numeric,
    "QuarterlyKpi" numeric,
    "AnnualRating" numeric,
    "GoalCompletion" numeric,
    "Attendance" numeric,
    "ReportingEfficiency" numeric,
    "PromotionReadiness" character varying(120),
    "ManagerFeedback" character varying(500),
    "Pan" character varying(40),
    "BankAccount" character varying(80),
    "SalaryBand" character varying(40),
    "PfUan" character varying(40),
    "TaxRegime" character varying(80),
    "ComplianceStatus" character varying(80),
    "UserId" uuid,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "JobRoleId" uuid,
    "NationalityId" uuid,
    "ProbationPeriod" character varying(40),
    "SalaryBandId" uuid,
    "Aadhaar" character varying(12),
    "EmergencyContactName" text,
    "EmployeeStatusId" uuid,
    "BondDelivered" character varying(10),
    "BondDurationMonths" integer,
    "BondExpiryDate" date,
    "GradDegree" text,
    "GradYear" text,
    "PostGradDegree" text,
    "PostGradYear" text,
    "ExpType" text,
    "PriorTotalExp" text,
    "PriorRelevantExp" text,
    "EmergencyContactRelation" text,
    "PmoDepartment" text,
    "SubDepartment" text,
    "BillableStatus" text,
    "ClientLocation" text,
    "ProjectType" text,
    "ProjectAllocated" text,
    "ClientEngManagerMapping" text,
    "EngagementManagerEmployeeId" uuid,
    "ProjectManagerId" uuid
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: exited_employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exited_employees (
    "Id" uuid NOT NULL,
    "OriginalEmployeeId" uuid NOT NULL,
    "EmployeeCode" character varying(20) NOT NULL,
    "FullName" character varying(255) NOT NULL,
    "DepartmentName" character varying(150),
    "DesignationName" character varying(150),
    "WorkEmail" character varying(255),
    "PersonalEmail" character varying(255),
    "Phone" character varying(40),
    "StatusAtExit" character varying(60),
    "ExitType" character varying(80),
    "ExitReason" character varying(500),
    "ResignationDate" date,
    "LastWorkingDay" date,
    "ReasonForLeaving" character varying(500),
    "NoticePeriodServed" character varying(80),
    "ExitChecklistJson" jsonb,
    "AssetReturnJson" jsonb,
    "FinalSettlementJson" jsonb,
    "ExitedAtUtc" timestamp with time zone NOT NULL,
    "ExitedBy" uuid,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "ClearanceCompleted" boolean DEFAULT false NOT NULL,
    "ExitRating" numeric(3,1)
);


ALTER TABLE public.exited_employees OWNER TO postgres;

--
-- Name: mst_business_units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_business_units (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_business_units OWNER TO postgres;

--
-- Name: mst_certifications; Type: TABLE; Schema: public; Owner: trackerpro
--

CREATE TABLE public.mst_certifications (
    "Id" uuid NOT NULL,
    "Code" character varying(100) NOT NULL,
    "Name" character varying(200) NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_certifications OWNER TO trackerpro;

--
-- Name: mst_cities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_cities (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(120) NOT NULL,
    "IsActive" boolean NOT NULL,
    "CountryId" uuid NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_cities OWNER TO postgres;

--
-- Name: mst_contact_designations; Type: TABLE; Schema: public; Owner: trackerpro
--

CREATE TABLE public.mst_contact_designations (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "IsActive" boolean NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_contact_designations OWNER TO trackerpro;

--
-- Name: mst_contact_types; Type: TABLE; Schema: public; Owner: trackerpro
--

CREATE TABLE public.mst_contact_types (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "IsActive" boolean NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_contact_types OWNER TO trackerpro;

--
-- Name: mst_countries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_countries (
    "Id" uuid NOT NULL,
    "Code" character varying(8) NOT NULL,
    "Name" character varying(120) NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "PhoneCode" character varying(8) DEFAULT '+91'::character varying NOT NULL,
    "PhoneDigits" integer DEFAULT 10 NOT NULL
);


ALTER TABLE public.mst_countries OWNER TO postgres;

--
-- Name: mst_departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_departments (
    "Id" uuid NOT NULL,
    "Code" character varying(50) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_departments OWNER TO postgres;

--
-- Name: mst_designations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_designations (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "IsActive" boolean NOT NULL,
    "DepartmentId" uuid,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "DefaultRoleId" uuid,
    "SubDepartment" text
);


ALTER TABLE public.mst_designations OWNER TO postgres;

--
-- Name: mst_email_domains; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_email_domains (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "DomainName" character varying(150) NOT NULL,
    "DisplayName" character varying(150) NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_email_domains OWNER TO postgres;

--
-- Name: mst_employee_statuses; Type: TABLE; Schema: public; Owner: trackerpro
--

CREATE TABLE public.mst_employee_statuses (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "AllowOnboarding" boolean DEFAULT false NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_employee_statuses OWNER TO trackerpro;

--
-- Name: mst_graduation_degrees; Type: TABLE; Schema: public; Owner: trackerpro
--

CREATE TABLE public.mst_graduation_degrees (
    "Id" uuid NOT NULL,
    "Code" character varying(100) NOT NULL,
    "Name" character varying(200) NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_graduation_degrees OWNER TO trackerpro;

--
-- Name: mst_industries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_industries (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_industries OWNER TO postgres;

--
-- Name: mst_nationalities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_nationalities (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(120) NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_nationalities OWNER TO postgres;

--
-- Name: mst_offices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_offices (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "WorkLocationId" uuid,
    "IsActive" boolean DEFAULT true NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_offices OWNER TO postgres;

--
-- Name: mst_post_graduation_degrees; Type: TABLE; Schema: public; Owner: trackerpro
--

CREATE TABLE public.mst_post_graduation_degrees (
    "Id" uuid NOT NULL,
    "Code" character varying(100) NOT NULL,
    "Name" character varying(200) NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_post_graduation_degrees OWNER TO trackerpro;

--
-- Name: mst_reporting_managers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_reporting_managers (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "Designation" character varying(150),
    "Email" character varying(255),
    "EmployeeId" uuid,
    "IsActive" boolean DEFAULT true NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_reporting_managers OWNER TO postgres;

--
-- Name: mst_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_roles (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "IsActive" boolean NOT NULL,
    "DesignationId" uuid NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_roles OWNER TO postgres;

--
-- Name: mst_salary_bands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_salary_bands (
    "Id" uuid NOT NULL,
    "Code" character varying(20) NOT NULL,
    "Name" character varying(20) NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_salary_bands OWNER TO postgres;

--
-- Name: mst_work_locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_work_locations (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_work_locations OWNER TO postgres;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_tokens (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "TokenHash" character varying(255) NOT NULL,
    "ExpiresAtUtc" timestamp with time zone NOT NULL,
    "RevokedAtUtc" timestamp with time zone,
    "ReplacedByTokenHash" text,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- Name: repository; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.repository (
    "Id" uuid NOT NULL,
    "FileName" character varying(255) NOT NULL,
    "Category" character varying(50) NOT NULL,
    "Size" bigint NOT NULL,
    "LastUpdated" timestamp with time zone NOT NULL,
    "UploadedBy" character varying(150) NOT NULL,
    "FilePath" character varying(1000) NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.repository OWNER TO postgres;

--
-- Name: repository_activity_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.repository_activity_logs (
    "Id" uuid NOT NULL,
    "Action" character varying(50) NOT NULL,
    "DocumentId" uuid,
    "FileName" character varying(255) NOT NULL,
    "Category" character varying(50) NOT NULL,
    "PerformedBy" character varying(150) NOT NULL,
    "Details" character varying(1000),
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "DeletedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "UpdatedAtUtc" timestamp with time zone
);


ALTER TABLE public.repository_activity_logs OWNER TO postgres;

--
-- Name: repository_departments; Type: TABLE; Schema: public; Owner: trackerpro
--

CREATE TABLE public.repository_departments (
    "RepositoryItemId" uuid NOT NULL,
    "DepartmentId" uuid NOT NULL
);


ALTER TABLE public.repository_departments OWNER TO trackerpro;

--
-- Name: role_permission_audits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permission_audits (
    "Id" uuid NOT NULL,
    "RoleId" uuid NOT NULL,
    "RoleName" character varying(100) NOT NULL,
    "ModuleKey" character varying(100) NOT NULL,
    "ModuleLabel" character varying(100) NOT NULL,
    "SubmoduleKey" character varying(100),
    "SubmoduleLabel" character varying(100),
    "PermissionKey" character varying(150) NOT NULL,
    "ActionLabel" character varying(100) NOT NULL,
    "ChangeType" character varying(20) NOT NULL,
    "PreviousValue" character varying(50) NOT NULL,
    "NewValue" character varying(50) NOT NULL,
    "ChangedById" uuid,
    "ChangedByName" character varying(255),
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.role_permission_audits OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    "Id" uuid NOT NULL,
    "DisplayName" character varying(100) NOT NULL,
    "Permissions" jsonb NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "Name" character varying(50) DEFAULT ''::character varying NOT NULL,
    "Description" character varying(500),
    "IsActive" boolean DEFAULT true NOT NULL,
    "IsSystemRole" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: sub_ventures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sub_ventures (
    "Id" uuid NOT NULL,
    "ClientId" uuid NOT NULL,
    "Name" character varying(255) NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "Notes" character varying(2000),
    "KycDocumentName" character varying(255),
    "KycDocumentPath" character varying(500)
);


ALTER TABLE public.sub_ventures OWNER TO postgres;

--
-- Name: team_day_entries; Type: TABLE; Schema: public; Owner: trackerpro
--

CREATE TABLE public.team_day_entries (
    "Id" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "WorkDate" date NOT NULL,
    "Attendance" character varying(20),
    "Shift" character varying(20),
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.team_day_entries OWNER TO trackerpro;

--
-- Name: team_member_holidays; Type: TABLE; Schema: public; Owner: trackerpro
--

CREATE TABLE public.team_member_holidays (
    "Id" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "HolidayDate" date NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Comment" character varying(500),
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.team_member_holidays OWNER TO trackerpro;

--
-- Name: team_member_schedules; Type: TABLE; Schema: public; Owner: trackerpro
--

CREATE TABLE public.team_member_schedules (
    "Id" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "WorkingDays" smallint[] DEFAULT '{1,2,3,4,5}'::smallint[] NOT NULL,
    "Notes" character varying(2000),
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.team_member_schedules OWNER TO trackerpro;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    "Id" uuid NOT NULL,
    "Email" character varying(255) NOT NULL,
    "PasswordHash" character varying(255),
    "Name" character varying(255) NOT NULL,
    "EmployeeId" character varying(20) NOT NULL,
    "Department" text,
    "SubDepartment" text,
    "Avatar" text,
    "Designation" text,
    "IsActive" boolean NOT NULL,
    "MustChangePassword" boolean NOT NULL,
    "RoleId" uuid,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "FailedLoginAttempts" integer DEFAULT 0 NOT NULL,
    "LastLoginAtUtc" timestamp with time zone,
    "LockedUntilUtc" timestamp with time zone,
    "PasswordChangedAtUtc" timestamp with time zone,
    "AuthProvider" character varying(50) DEFAULT 'Local'::character varying NOT NULL,
    "MicrosoftOid" character varying(100)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20260807073751_InitialIdentity	10.0.4
20260807075509_AddUserSecurity	10.0.4
20260807101120_AddClientFormDetails	10.0.4
20260807105244_SubVentureContactsAndLogo	10.0.4
20260807112338_SubVentureTableAndLogoRule	10.0.4
20260810121931_RbacRoleManagement	10.0.4
20260818075129_AddMasterCatalogs	10.0.4
20260820113531_AddGeoCatalogs	10.0.4
20260820122343_AddEmployeeCatalogs	10.0.4
20260820124931_AddSalaryBands	10.0.4
20260821085833_AddClientCustomerSince	10.0.4
20260821120228_AddSubVentureNotes	10.0.4
20260826185721_AddEmployeeAadhaarAndUniqueIdentity	10.0.4
20260822003800_AddMstEmailDomains	10.0.4
20260828104500_AddClientSalesManager	10.0.4
20260831133000_AddCountryPhoneFields	10.0.4
20260831150000_AddResourceCatalogTables	10.0.4
20260902100000_AddClientKycDocumentPath	10.0.4
20260902110000_AddSubVentureKycDocument	10.0.4
20260902180000_AddEmployeeCodeFormatCheck	10.0.4
20260903120000_AddRepositoryDepartments	10.0.4
20260905140000_AddEmployeeEmploymentBondFields	10.0.4
20260908050000_AddCertificationsAndDegrees	10.0.4
20260908190000_AddClientBillingMedium	10.0.4
20260908193000_AddClientGroupSpocFields	10.0.4
20260909120000_AddClientContactCountry	10.0.4
20260909130000_AddContactDesignationMaster	10.0.4
20260909140000_AddContactTypeMaster	10.0.4
20260921133000_AddExitedEmployeeClearanceAndRating	10.0.4
20260923120000_AddTeamSchedule	10.0.4
\.


--
-- Data for Name: client_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.client_assignments ("ClientId", "UserId") FROM stdin;
06cb7699-93b0-047f-0c59-b7f1baa24ec8	1a077a8c-4029-8ded-d563-19e9b4bdf301
9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	1a077a8c-4029-8ded-d563-19e9b4bdf301
a70cd580-74be-fff2-31b3-dcc06cc11f06	e7554ba2-e546-93ce-1e88-a073badd78a2
f61741ca-2c63-917f-ee7f-ae00cdbc08cb	e7554ba2-e546-93ce-1e88-a073badd78a2
\.


--
-- Data for Name: client_contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.client_contacts ("Id", "ClientId", "SubVentureId", "Name", "Email", "Phone", "Designation", "ContactType", "IsPrimary", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Country", "PhoneCode") FROM stdin;
d5572af5-adde-4fd9-b14b-c857467d1c93	\N	37f0c3b1-16a1-4643-9f5a-f824204543c1	Sahil Lad	sahillad77@gmail.com	7854125698	ciso	Procurement	f	2026-08-19 12:13:26.584779+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
8959a84a-a7cc-42be-ba71-c142d5dae1fa	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-08-19 12:39:05.853384+05:30	2026-08-20 15:51:44.183087+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 15:51:44.183087+05:30	\N	\N
26358579-8daf-4027-81c9-c375e8628aa3	\N	6a40584b-3bde-4c7d-a6e6-3ef920cd43d0	Sahil 	sahillad2092003@gmail.com	8744541212	spoc	Technical	f	2026-08-20 16:30:13.771971+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
77e4a9a2-d473-4007-be16-f9eebfb39df8	90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	\N	Sahil	sahillad2092003@gmail.com	8744541212	spoc	Technical	f	2026-08-20 16:30:13.771971+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
0529bbe6-d5da-4295-9af6-a5d1fc964dc4	a04ccf3a-81c8-4416-8af7-068717ddb22b	\N	roshan jadhav	roshan.jadhav@gmail.com	7389247892	spoc	Accounts	f	2026-08-20 19:01:53.354468+05:30	2026-08-20 19:04:48.401428+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 19:04:48.401428+05:30	\N	\N
146500d9-5e28-4612-8053-9b883e7bfa73	\N	65c6925a-8948-4485-9d93-e596e1f4273e	roshan jadhav	roshan.jadhav@gmail.com	7389247892	spoc	Accounts	f	2026-08-20 19:01:53.354468+05:30	2026-08-20 19:04:48.401428+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 19:04:48.401428+05:30	\N	\N
5a47d941-02d2-4a03-a9fd-29a55f39f273	\N	65c6925a-8948-4485-9d93-e596e1f4273e	karan pawar	karan.pawar@gmail.com	5374903789	ciso	Technical	f	2026-08-20 19:01:53.354468+05:30	2026-08-20 19:04:48.401428+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 19:04:48.401428+05:30	\N	\N
5e72a713-46c0-47c8-b777-f61ecf2a858e	a04ccf3a-81c8-4416-8af7-068717ddb22b	\N	karan pawar	karan.pawar@gmail.com	5374903789	ciso	Technical	f	2026-08-20 19:01:53.354468+05:30	2026-08-20 19:04:48.401428+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 19:04:48.401428+05:30	\N	\N
03f15020-3812-47c9-97a4-3ed02203ca0a	\N	65c6925a-8948-4485-9d93-e596e1f4273e	karan pawar	karan.pawar@gmail.com	5374903789	ciso	Technical	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
251274f1-0037-4f3c-8d67-44d1e46981fa	\N	65c6925a-8948-4485-9d93-e596e1f4273e	roshan jadhav	roshan.jadhav@gmail.com	7389247892	spoc	Accounts	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
3865019e-696f-4b90-9347-8cd7ef76d999	\N	d3af0a54-b527-40ca-ac1e-9fb09fd81504	harshada	harshada@tk.com	4373947849	ciso	Technical	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
e6e01a67-c99e-4ed7-87a0-92e5a498d8ab	\N	d3af0a54-b527-40ca-ac1e-9fb09fd81504	muskan	muskan@tk.com	4356789038	spoc	Procurement	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
855194e2-92d8-4bd8-a850-110fa9ce4776	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-08-20 15:51:44.192431+05:30	2026-08-21 15:35:12.70694+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-21 15:35:12.70694+05:30	\N	\N
873fac91-16b6-421c-bd45-3cd92e2dc931	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-08-20 15:51:44.192431+05:30	2026-08-21 15:35:12.70694+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-21 15:35:12.70694+05:30	\N	\N
e90e0928-dbe2-47eb-b92d-3835423c1163	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-08-20 15:51:44.192431+05:30	2026-08-21 15:35:12.70694+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-21 15:35:12.70694+05:30	\N	\N
00331436-e85a-4899-8929-daf84f77440f	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-08-21 15:35:12.720669+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
10f3620f-44d6-44a2-a90d-cbeb6ea0851a	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-08-21 15:35:12.720669+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
327f81c4-11e3-40bd-a73c-f5c9dfe06147	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-08-21 15:35:12.720669+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
d8e9f1ce-ac14-4a5a-899a-5d87963e99d2	\N	a69fe228-de12-44e5-9128-dc3898f67e5c	omkar	omkar@talakunchi.com	9877987899	SPOC	Accounts	f	2026-08-21 15:35:12.720669+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
5cc0fc46-9dc4-4a73-bced-d67c9d5db540	60e8ff87-c86e-4c71-a3ec-446d22b4ef5c	\N	Saif	kosec@gmail.com	8797476413	Manager GRC	Technical	f	2026-08-27 15:11:01.737034+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
d8e604d1-1187-4d77-b719-1baa1d098681	\N	157b058e-8688-4a99-b13b-f53a60ba19e4	Saif 	kosec@gmail.com	8797476413	Manager GRC	Technical	f	2026-08-27 15:11:01.737034+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
19b82994-82be-4c0f-b8f3-2af29064f9ec	fcdd3c82-1ca5-496b-b45c-7e433955aa46	\N	Rahul S	rahul.ksec@gmail.com	8764749544	manager Testing	Technical	f	2026-08-27 15:48:07.747362+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
7af939bf-5f18-408d-960a-4a20ef5d7845	\N	b6502a56-f47f-487b-b915-45f74cdebfdf	Rahul S	rahul.ksec@gmail.com	8764749544	manager Testing	Technical	f	2026-08-27 15:48:07.747362+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clients ("Id", "Name", "Industry", "Logo", "ContactEmail", "ClientType", "Status", "EngagementManager", "ContactName", "ContactPhone", "ContactDesignation", "ContactType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BusinessType", "City", "Country", "KycDocumentName", "Notes", "EngagementManagerId", "IndustryId", "CityId", "CountryId", "CustomerSince", "SalesManager", "SalesManagerId", "KycDocumentPath", "BillingMedium", "GroupSpocName", "GroupSpocContact") FROM stdin;
06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Pharma	Healthcare	HP	it@helix.com	Old	Active	Pradeep Singh	Sanjay Sen	+91 98765 43211	Procurement Head	Procurement	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07	\N	\N	\N	\N	Sanjay Sen	+91 98765 43211
a04ccf3a-81c8-4416-8af7-068717ddb22b	Morphle	Banking	M	roshan.jadhav@gmail.com	New	Active	Pradeep Singh	roshan jadhav	7389247892	spoc	Accounts	2026-08-20 19:01:53.288995+05:30	2026-08-21 17:58:26.459736+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	Kalyan-Dombivli	India	API Gateway Configuration Guide (1).txt	no comments	8a50b4b9-7091-423c-ac8c-af55bc6df348	4a80bfdb-a191-4ce1-ab51-2142eb366db7	4d396fc0-ae55-4eeb-b2db-79bbb757d3cd	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20	\N	\N	\N	\N	roshan jadhav	7389247892
a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync AI	Technology	CA	contact@cloudsync.com	New	Active	Riya Kapoor	Neha Gupta	+91 98765 43215	IT Lead	Technical SPOC	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	02012f0c-97b2-4aea-a6b4-954ee97d892d	\N	\N	2026-08-07	\N	\N	\N	\N	Neha Gupta	+91 98765 43215
a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Plus	Healthcare	MP	tech@medicareplus.com	New	Active	Pradeep Singh	Priyanka Joshi	+91 98765 43217	Procurement Mgr	Procurement	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07	\N	\N	\N	\N	Priyanka Joshi	+91 98765 43217
428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Logistics	Logistics	ZL	pm@zenith.com	New	Active	Rahul Sharma	Vikram Malhotra	+91 98765 43213	Legal Counsel	Legal	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f175fde9-14f8-40e8-b564-47d8a29d84ff	\N	\N	2026-08-07	\N	\N	\N	\N	Vikram Malhotra	+91 98765 43213
9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Bank	Banking	NB	ops@northwind.com	Old	Active	Rahul Sharma	Rahul Sharma	+91 98765 43210	IT Manager	Technical SPOC	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4a80bfdb-a191-4ce1-ab51-2142eb366db7	\N	\N	2026-08-07	\N	\N	\N	\N	Rahul Sharma	+91 98765 43210
c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Systems	Automotive	AS	engineering@autodrive.com	Old	Active	Rahul Sharma	Kabir Sen	+91 98765 43219	Engineering SPOC	Technical SPOC	2026-08-07 13:19:59.669429+05:30	2026-08-21 15:50:25.776021+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	9a15533f-f863-44a7-b61c-b978fa1f5174	4bf54de4-0e85-4904-a89f-542301b65077	\N	\N	2026-08-07	\N	\N	\N	\N	Kabir Sen	+91 98765 43219
47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Energy	Energy	LE	digital@lumen.com	Old	Active	Pradeep Singh	Arjun Mehta	+91 98765 43214	Operations Manager	Technical SPOC	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:58:40.3605+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	8a50b4b9-7091-423c-ac8c-af55bc6df348	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-07	\N	\N	\N	\N	Arjun Mehta	+91 98765 43214
fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Global	Finance	FG	dev@fintechglobal.com	Old	Active	Rahul Sharma	Siddharth Shah	+91 98765 43216	Finance VP	Accounts	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	cd116cba-a939-4cb7-bd0f-233019a005b0	\N	\N	2026-08-07	\N	\N	\N	\N	Siddharth Shah	+91 98765 43216
f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Retail	Retail	OR	tech@orbit.com	Old	Active	Riya Kapoor	Aditi Rao	+91 98765 43212	CFO	Accounts	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	935db8d7-e2aa-417e-839e-b51d00ce951e	\N	\N	2026-08-07	\N	\N	\N	\N	Aditi Rao	+91 98765 43212
f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Solutions	Environment	ES	projects@ecogreen.com	Old	Active	Riya Kapoor	Rohan Varma	+91 98765 43218	Legal Head	Legal	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16ebeb23-b3d8-4fb7-a4f6-789510c28ad3	\N	\N	2026-08-07	\N	\N	\N	\N	Rohan Varma	+91 98765 43218
90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	TATA	Energy	T	sahillad2092003@gmail.com	New	Active	Pradeep Singh	Sahil	8744541212	spoc	Technical	2026-08-20 16:30:13.739957+05:30	2026-08-21 14:32:02.864281+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	mumbai	India	exit-summary (1).csv	kldfslkdfsdlf	8a50b4b9-7091-423c-ac8c-af55bc6df348	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-20	\N	\N	\N	\N	Sahil	8744541212
60e8ff87-c86e-4c71-a3ec-446d22b4ef5c	Kotak Group	Banking	KG	kosec@gmail.com	New	Active	Saeed	Saif	8797476413	Manager GRC	Technical	2026-08-27 15:11:01.353316+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Mumbai	India	[Talakunchi] - L3 Project Manager- Siddesh Sapkal -   1.pdf	\N	\N	4a80bfdb-a191-4ce1-ab51-2142eb366db7	6ffbb80b-985d-4f00-9140-db22f39a625d	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-27	\N	\N	\N	\N	Saif	8797476413
fcdd3c82-1ca5-496b-b45c-7e433955aa46	abc	Banking	A	rahul.ksec@gmail.com	New	Active	saeed	Rahul S	8764749544	manager Testing	Technical	2026-08-27 15:48:07.721735+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Guwahati	India	[Talakunchi] - L3 Project Manager- Siddesh Sapkal -   1.pdf	\N	\N	4a80bfdb-a191-4ce1-ab51-2142eb366db7	fa492bc9-1015-4a17-9e5b-585b44740f64	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-27	\N	\N	\N	\N	Rahul S	8764749544
\.


--
-- Data for Name: employee_activity_logs; Type: TABLE DATA; Schema: public; Owner: trackerpro
--

COPY public.employee_activity_logs ("Id", "EmployeeId", "Action", "PerformedByEmail", "PerformedByName", "Details", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees ("Id", "EmployeeCode", "FirstName", "LastName", "WorkEmail", "PersonalEmail", "Phone", "AltPhone", "Gender", "DateOfBirth", "Address", "EmergencyContact", "MaritalStatus", "Nationality", "DepartmentId", "DesignationId", "Role", "ReportingManagerId", "BusinessUnit", "WorkLocation", "OfficeBranch", "Category", "Team", "ProjectSite", "JoiningDate", "Status", "ConfirmationStatus", "ProbationStatus", "Experience", "PreviousCompany", "EmploymentType", "ContractType", "BondStatus", "NoticePeriod", "AssetId", "ExitType", "ExitReason", "Education", "Skills", "Certifications", "Languages", "KpiScore", "QuarterlyKpi", "AnnualRating", "GoalCompletion", "Attendance", "ReportingEfficiency", "PromotionReadiness", "ManagerFeedback", "Pan", "BankAccount", "SalaryBand", "PfUan", "TaxRegime", "ComplianceStatus", "UserId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "JobRoleId", "NationalityId", "ProbationPeriod", "SalaryBandId", "Aadhaar", "EmergencyContactName", "EmployeeStatusId", "BondDelivered", "BondDurationMonths", "BondExpiryDate", "GradDegree", "GradYear", "PostGradDegree", "PostGradYear", "ExpType", "PriorTotalExp", "PriorRelevantExp", "EmergencyContactRelation", "PmoDepartment", "SubDepartment", "BillableStatus", "ClientLocation", "ProjectType", "ProjectAllocated", "ClientEngManagerMapping", "EngagementManagerEmployeeId", "ProjectManagerId") FROM stdin;
1a350645-f31a-4309-8441-d37f39e31fe5	TK-9729	Priya	Shah	priya.shah.0191472791bb4c5593e44681a270b32a@acme.co	\N	\N	\N	Female	1994-03-12	Andheri East, Mumbai	9876543210	Married	Indian	\N	56643cd3-35e5-429e-9b1c-385881443d8f	Developer	\N	Enterprise	Navare Plaza, Dombivli	\N	\N	\N	Offsite	\N	Active	\N	6 months	5 years	Acme	Full-time	Permanent	No	\N	TK-4029	NA	NA	B.Tech	["React", "Mentoring"]	["AWS"]	["English", "Hindi"]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	L2	\N	\N	\N	\N	2026-08-20 18:38:53.427831+05:30	2026-09-09 15:56:18.872666+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	81ef3e8a-db52-4670-a73e-5ba4d3b47c48	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	ebed343e-301f-4984-b292-fa8d1cb1623c	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8065ff15-64d6-4f36-a003-f0444a620bd8	TK-1020	Nikhil	Khanna	nikhil.khanna@acme.co	nikhil1020@gmail.com	9876501020	9866501020	Male	1993-08-20	140, Dombivali Office	9811101020	Single	Indian	d32a6c00-a02a-4586-90c2-4a503b6efc3a	593f83a4-8af6-4fe5-8e91-a465fa5055e9	Sales	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2020-08-10	Active	Active	Completed	11 years	TCS	Full-time	Permanent	No	90 days	TK-4020	NA	NA	MCA	["Communication", "Delivery", "Sales"]	["NA"]	["English", "Hindi"]	89	87	4	94	91	84	Ready in 1 year	Solid contributor on current assignments.	ABCDE1254F	501234567820	L4	100112345020	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890020	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
81c42f4c-b588-4037-a106-47f339a777f6	TK-1019	Pooja	Menon	pooja.menon@acme.co	pooja1019@gmail.com	9876501019	9866501019	Female	1992-07-19	139, Andheri Office	9811101019	Married	Indian	d0ab0dc3-606c-4d62-95ea-3d62749f9006	dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	Hr	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Onsite	2019-07-10	Active	Active	Completed	10 years	Infosys	Full-time	Permanent	No	60 days	TK-4019	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Human Resources"]	["NA"]	["English", "Hindi"]	88	86	3	93	90	83	Ready in 1 year	Solid contributor on current assignments.	ABCDE1253F	501234567819	L4	100112345019	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890019	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8a50b4b9-7091-423c-ac8c-af55bc6df348	TK-1023	Pradeep	Singh	pradeep.singh@acme.co	pradeep1023@gmail.com	9876501023	9866501023	Male	1996-11-23	143, Andheri Office	9811101023	Single	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2023-11-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4023	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	92	70	4	77	94	87	Ready in 1 year	Solid contributor on current assignments.	ABCDE1257F	501234567823	L4	100112345023	New Regime	Compliant	\N	2026-08-21 13:58:23.134157+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N	234567890023	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8e97c526-8c79-44c6-a23f-ece0d9b21df5	TK-1003	Sneha	Iyer	sneha.iyer@acme.co	sneha1003@gmail.com	9876501003	9866501003	Female	1992-03-03	123, Andheri Office	9811101003	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	72466f60-859b-4946-998c-b34eb2c40c0e	TeamLead	\N	Cloud Platform	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2021-03-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4003	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	72	70	5	77	92	82	Ready in 1 year	Solid contributor on current assignments.	ABCDE1237F	501234567803	L5	100112345003	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890003	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
929d4a75-9232-4ce7-a1a6-8f107ccca1e7	TK-1007	Neha	Kulkarni	neha.kulkarni@acme.co	neha1007@gmail.com	9876501007	9866501007	Female	1996-07-07	127, Andheri Office	9811101007	Married	Indian	e91e9aa5-1cbb-4d1e-99fe-d7aefedd9f87	13d33d9b-c70e-4f07-897f-c9aa2bf89277	Accounts	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Onsite	2019-07-10	Active	Active	Completed	8 years	Infosys	Full-time	Permanent	No	60 days	TK-4007	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Finance"]	["NA"]	["English", "Hindi"]	76	74	3	81	96	86	Ready in 1 year	Solid contributor on current assignments.	ABCDE1241F	501234567807	L4	100112345007	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890007	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9a15533f-f863-44a7-b61c-b978fa1f5174	TK-1022	Rahul	Sharma	rahul.sharma@acme.co	rahul1022@gmail.com	9876501022	9866501022	Male	1995-10-22	142, Dombivali Office	9811101022	Married	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Onsite	2022-10-10	Active	Active	Completed	3 years	TCS	Full-time	Permanent	No	90 days	TK-4022	NA	NA	MCA	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	91	69	3	76	93	86	Ready in 1 year	Solid contributor on current assignments.	ABCDE1256F	501234567822	L4	100112345022	Old Regime	Compliant	\N	2026-08-21 13:58:23.134157+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N	234567890022	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
080045f2-3ff3-49af-bced-4b10ea1dde6f	TK-7266	Integration	Resource	integration.resource.ce5bcae27dbc41978b56226b5bf1debf@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Integration test	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 18:21:17.146104+05:30	2026-09-23 18:06:44.413914+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-23 18:06:44.413914+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
a165f6aa-148a-4ad0-953a-f154ae0991c8	TK-5886	Integration	Resource	integration.resource.e531fb2cecab4c6caa485682aeaa36eb@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	\N	\N	\N	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Notice already ended	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 17:55:04.462343+05:30	2026-08-20 17:55:04.510288+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	2026-08-20 17:55:04.510288+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
649f4c6f-8719-4ff4-8969-7a55a16e43bd	TK-8163	Integration	Resource	integration.resource.55c6d73ab436476db67f6f1b9df80d8a@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	\N	\N	\N	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Notice already ended	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 18:21:19.436175+05:30	2026-08-20 18:21:19.547505+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	2026-08-20 18:21:19.547505+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9e1b1aa9-fcd3-47be-b264-53806520c9fc	TK-1018	Aditya	Reddy	aditya.reddy@acme.co	aditya1018@gmail.com	9876501018	9866501018	Male	1991-06-18	138, Dombivali Office	9811101018	Single	Indian	\N	616911db-9bc2-4b40-b50f-2972f2c2f9e6	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team F	Offsite	2024-06-10	Active	Active	Completed	9 years	TCS	Full-time	Permanent	No	90 days	TK-4018	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	87	85	5	92	98	82	Ready in 1 year	Solid contributor on current assignments.	ABCDE1252F	501234567818	L4	100112345018	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-20 11:40:09.305181+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 11:40:09.305181+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
c5d5234b-6151-4e42-abd3-0d91dd38754b	TK-1015	Meera	Nambiar	meera.nambiar@acme.co	meera1015@gmail.com	9876501015	9866501015	Female	1996-03-15	135, Andheri Office	9811101015	Single	Indian	\N	0cbff6d6-9622-4d55-a0db-2e7b192988f3	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Without Bond	Team C	Offsite	2021-03-10	Active	Active	Completed	6 years	Infosys	Full-time	Permanent	No	60 days	TK-4015	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Product"]	["NA"]	["English", "Hindi"]	84	82	5	89	95	94	Ready in 1 year	Solid contributor on current assignments.	ABCDE1249F	501234567815	L4	100112345015	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-20 12:05:44.26208+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 12:05:44.26208+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
96425efc-9b0e-4f2b-8fd6-ec3b77161547	TK-3456	Dhanshree	Pansare	dhanshree.pansare@gmail.com	dhanshree.pansare002@gmail.com	9326178048	7900141424	Female	2002-11-02	31,kranti society,bhandup east 400042	9324567803	Single	Indian	\N	eccddb98-13a9-4d79-82d6-3b97e710c83c	software devloer	498bb0ed-62ca-4e56-bcb3-4cbd356077be	Consumer Apps	Navare Plaza, Dombivli	\N	Permanent - Bond	\N	Onsite	2026-08-28	Notice Period	Active - Probation	On Probation (6 months)	7 years	tcs	Full-time	Permanent	Yes	90 days	TK-566	Resign	bo	Bachlore enginering	["python", "testing"]	["AWS", "Pen tester"]	["hindi", "engish"]	0	0	0	0	0	0	\N	\N	WASDE2324H	3246572827344	L4	973456234651	\N	Pending	\N	2026-08-20 19:13:06.225084+05:30	2026-09-09 15:56:18.872666+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	78123fe6-6d61-4ca5-b5e1-57d8b06f1787	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
a586e15e-0ad4-4d33-aa18-b1edcf241baf	TK-1005	Divya	Rao	divya.rao@acme.co	divya1005@gmail.com	9876501005	9866501005	Female	1994-05-05	125, Andheri Office	9811101005	Single	Indian	627cdb67-1e99-46ec-88ff-42b9c361fdc3	a307f07d-c56a-47c9-8106-792773adb304	ProjectManager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2023-05-10	Active	Active	Completed	6 years	Infosys	Full-time	Permanent	No	60 days	TK-4005	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Product"]	["NA"]	["English", "Hindi"]	74	72	4	79	94	84	Ready Now	Solid contributor on current assignments.	ABCDE1239F	501234567805	L4	100112345005	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890005	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
b78530f0-0687-4f26-a614-8318c62901f9	TK-3021	Pranjali	Shah	pranjali@talakunchi.io	pranjali@gmail.com	8894344343	9827327263	\N	\N	\N	\N	\N	India	\N	\N	Employee	2446deb8-f6cc-4ee1-b179-599d0a2e357a	\N	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2026-08-12	Active	Active	\N	\N	\N	\N	\N	\N	\N	\N	NA	NA	\N	[]	[]	[]	0	0	0	0	0	0	\N	\N	WASDE2324H	3246572827344	\N	973456234651	\N	Pending	\N	2026-08-20 16:09:23.376516+05:30	2026-09-09 15:56:18.872666+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
c15b2b43-0884-4999-bece-9289d1db561f	TK-1016	Vikram	Gupta	vikram.gupta@acme.co	vikram1016@gmail.com	9876501016	9866501016	Male	1997-04-16	136, Dombivali Office	9811101016	Married	Indian	2083db49-90d5-4f46-b4be-2d0a24edec35	3cc44614-05d3-4283-9b66-d95dd7ec5708	ProjectManager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Navare Plaza, Dombivli	\N	Permanent - Bond	\N	Onsite	2022-04-10	Active	Active	Completed	7 years	TCS	Full-time	Permanent	Yes — 2 years	90 days	TK-4016	NA	NA	MCA	["Communication", "Delivery", "Operations"]	["NA"]	["English", "Hindi"]	85	83	3	90	96	80	Ready in 1 year	Solid contributor on current assignments.	ABCDE1250F	501234567816	L4	100112345016	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890016	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
d24cafbe-bb30-4522-93b2-25588511f0e2	TK-1011	Ira	Kapoor	ira.kapoor@acme.co	ira1011@gmail.com	9876501011	9866501011	Female	1992-11-11	131, Andheri Office	9811101011	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	988d1399-4c1d-4969-b41f-b8c856ff93d5	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Suvidha Square, Andheri	\N	Permanent - Bond	\N	Offsite	2023-11-10	Active	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes — 2 years	60 days	TK-4011	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	80	78	4	85	91	90	Ready in 1 year	Solid contributor on current assignments.	ABCDE1245F	501234567811	L4	100112345011	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890011	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
dd7a3258-31be-425c-8771-cab8ba8b1b22	TK-1021	Riya	Kapoor	riya.kapoor@acme.co	riya1021@gmail.com	9876501021	9866501021	Female	1994-09-21	141, Andheri Office	9811101021	Single	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Suvidha Square, Andheri	\N	Permanent - Bond	\N	Offsite	2021-09-10	Active	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes — 2 years	60 days	TK-4021	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	90	68	5	75	92	85	Ready Now	Solid contributor on current assignments.	ABCDE1255F	501234567821	L4	100112345021	New Regime	Compliant	\N	2026-08-21 13:58:23.134157+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N	234567890021	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
df465de2-4aba-41d3-a2a3-1e81ca66e34a	TK-1004	Karthik	Bose	karthik.bose@acme.co	karthik1004@gmail.com	9876501004	9866501004	Male	1993-04-04	124, Dombivali Office	9811101004	Married	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	d15a2e6e-0d0b-4a54-a80b-21c8e580302b	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Onsite	2022-04-10	Notice Period	Active	Completed	5 years	TCS	Full-time	Permanent	No	60 days	TK-4004	Resign	Better Opportunity	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	73	71	3	78	93	83	Ready in 1 year	Solid contributor on current assignments.	ABCDE1238F	501234567804	L5	100112345004	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890004	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
a5059f7c-1dce-4123-b024-fea75814ac20	TKI-0001	Sample	Intern	sample.intern@acme.co	\N	9820000025	\N	\N	1990-01-25	145, Suvidha Square, Andheri	9811101025	Married	Indian	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	6a7adf32-084e-41e1-88fa-df012c8f4491	Intern	ed0e8e07-0b3b-4c43-862a-e7fedac0735f	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	\N	2019-01-10	Active	Active	Completed	6 years	Infosys	Full-time	Permanent	No	60 days	TK-4025	NA	NA	B.Tech (2018), M.Tech (2020)	["Communication", "Delivery", "Services - Testing"]	["CompTIA Security+"]	["English", "Hindi"]	94	72	3	79	96	89	Ready Now	Solid contributor on current assignments.	ABCDE1259F	501234567825	L4	100112345025	New Regime	Compliant	\N	2026-09-09 15:56:18.872666+05:30	2026-09-25 19:22:24.889161+05:30	\N	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N	234567890025	\N	\N	\N	\N	\N	B.Tech	2014	NA	NA	Fresher	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
18b83048-56d5-4365-8bc5-3ba65405467e	TK-1010	Harsh	Nair	harsh.nair@acme.co	harsh1010@gmail.com	9876501010	9866501010	Male	1991-10-10	130, Dombivali Office	9811101010	Married	Indian	2083db49-90d5-4f46-b4be-2d0a24edec35	0cbff6d6-9622-4d55-a0db-2e7b192988f3	Pmo	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Onsite	2022-10-10	Active	Active	Completed	11 years	TCS	Full-time	Permanent	No	90 days	TK-4010	NA	NA	MCA	["Communication", "Delivery", "Operations"]	["NA"]	["English", "Hindi"]	79	77	3	84	90	89	Ready in 1 year	Solid contributor on current assignments.	ABCDE1244F	501234567810	L4	100112345010	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890010	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
230058bf-ed8a-45da-8d77-4a2821a0a76a	TK-1024	Arjun	Mehta	arjun.mehta@acme.co	arjun1024@gmail.com	9876501024	9866501024	Male	1997-12-24	144, Dombivali Office	9811101024	Single	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2024-12-10	Active	Active	Completed	5 years	TCS	Full-time	Permanent	No	90 days	TK-4024	NA	NA	MCA	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	93	71	5	78	95	88	Ready in 1 year	Solid contributor on current assignments.	ABCDE1258F	501234567824	L4	100112345024	Old Regime	Compliant	\N	2026-08-21 13:58:23.134157+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N	234567890024	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3dcb0f17-b94a-470c-ba85-86ac0f1c65c8	TK-1013	Kavya	Desai	kavya.desai@acme.co	kavya1013@gmail.com	9876501013	9866501013	Female	1994-01-13	133, Andheri Office	9811101013	Married	Indian	92bfb4a4-87df-49ca-8f58-0b4add10f410	65bbcacb-ccc4-4502-87d4-eb142c6b406c	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Onsite	2019-01-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4013	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Marketing"]	["NA"]	["English", "Hindi"]	82	80	3	87	93	92	Ready Now	Solid contributor on current assignments.	ABCDE1247F	501234567813	L4	100112345013	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890013	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
eb10f37d-b64f-4b17-976b-b962645514f2	TK-8103	Priya	Shah	priya.shah.839199831f3541eda878b9f48a7f9743@acme.co	\N	\N	\N	Female	1994-03-12	Andheri East, Mumbai	9876543210	Married	Indian	\N	\N	Onboard Role f918b0f6	\N	Enterprise	Navare Plaza, Dombivli	\N	\N	\N	Offsite	\N	Active	\N	6 months	5 years	Acme	Full-time	Permanent	No	\N	TK-4029	NA	NA	B.Tech	["React", "Mentoring"]	["AWS"]	["English", "Hindi"]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	L2	\N	\N	\N	\N	2026-08-21 10:51:39.645179+05:30	2026-09-09 15:56:18.872666+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	ebed343e-301f-4984-b292-fa8d1cb1623c	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
e6a87065-9cc2-4a2d-bb25-720ec10771a2	TKI-0002	Rohan	Joshi	rohan.joshi@acme.co	\N	9820000027	\N	\N	1992-03-27	147, Suvidha Square, Andheri	9811101027	Single	Indian	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	6a7adf32-084e-41e1-88fa-df012c8f4491	Team Member (TM)	ed0e8e07-0b3b-4c43-862a-e7fedac0735f	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	\N	2021-03-10	Active	Active	Completed	8 years	Infosys	Full-time	Permanent	No	60 days	TK-4027	NA	NA	B.Tech (2018), M.Tech (2020)	["Communication", "Delivery", "Services - Testing"]	["CompTIA Security+"]	["English", "Hindi"]	71	74	5	81	98	91	Ready in 1 year	Solid contributor on current assignments.	ABCDE1261F	501234567827	L4	100112345027	New Regime	Compliant	\N	2026-09-25 19:22:24.889161+05:30	\N	\N	\N	\N	f327250c-cbf3-4d03-9bd5-d89532f9fcc2	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N	234567890027	Contact Rohan	\N	No	0	\N	B.Sc	2016	NA	NA	Fresher	0	0	Father	Internship Program	Across all Sub Departments	Non-Billable	Andheri	Long Term	CloudSync Multi-Region Sync	Rahul Sharma	\N	\N
eb50369d-e526-459c-bb6c-aa3a85b231db	TK-9301	Integration	Resource	integration.resource.c92dd5fc2d1c4c4fa7401c33cac1e6fe@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Integration test	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 17:55:03.82285+05:30	2026-09-23 18:06:44.413914+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-23 18:06:44.413914+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
ed0e8e07-0b3b-4c43-862a-e7fedac0735f	TK-0001	Dhanshree	Pansare	dhanshree.pansare@acme.co	\N	9820000001	\N	\N	1990-01-01	121, Suvidha Square, Andheri	9811101001	Married	Indian	5ac46d13-eee8-4d94-ad23-6654595594af	\N	Leader (L)	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	\N	2019-01-10	Active	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes — 2 years	60 days	TK-4001	NA	NA	B.Tech (2018), M.Tech (2020)	["Communication", "Delivery", "Core"]	["Certified Ethical Hacker (CEH)", "ISO 27001"]	["English", "Hindi"]	70	68	3	75	90	80	Ready Now	Solid contributor on current assignments.	ABCDE1235F	501234567801	L5	100112345001	New Regime	Compliant	\N	2026-09-25 19:22:24.889161+05:30	\N	\N	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N	234567890001	Contact Dhanshree	\N	Yes	24	2026-12-31	B.Tech	2014	M.Tech	2017	Experienced	2.5	1.5	Spouse	Core	Leading Delivery Dept.	Non-Billable	Andheri	Long Term	Helix Core EHR	Rahul Sharma	\N	\N
2446deb8-f6cc-4ee1-b179-599d0a2e357a	TK-1001	Priya	Sharma	priya.sharma@acme.co	priya1001@gmail.com	9876501001	9866501001	Female	1990-01-01	121, Andheri Office	9811101001	Married	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	56643cd3-35e5-429e-9b1c-385881443d8f	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri	Suvidha Square	Permanent - Bond	Team A	Onsite	2019-01-10	Notice Period	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes — 2 years	60 days	TK-4001	Resign	bo	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	70	68	3	75	90	80	Ready Now	Solid contributor on current assignments.	ABCDE1235F	501234567801	L5	100112345001	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-04 11:47:23.681031+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	2026-09-04 11:47:23.681031+05:30	\N	\N	\N	\N	234567890001	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
58198691-3595-4565-8ba6-d5f150240aa3	TK-1014	Arjun	Shah	arjun.shah@acme.co	arjun1014@gmail.com	9876501014	9866501014	Male	1995-02-14	134, Dombivali Office	9811101014	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2020-02-10	Active	Active	Completed	5 years	TCS	Full-time	Permanent	No	90 days	TK-4014	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	83	81	4	88	94	93	Ready in 1 year	Solid contributor on current assignments.	ABCDE1248F	501234567814	L4	100112345014	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890014	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
593b0378-d20a-40ee-b0a0-ae4acc0a78aa	TK-1009	Aanya	Joshi	aanya.joshi@acme.co	aanya1009@gmail.com	9876501009	9866501009	Female	1990-09-09	129, Andheri Office	9811101009	Single	Indian	d32a6c00-a02a-4586-90c2-4a503b6efc3a	593f83a4-8af6-4fe5-8e91-a465fa5055e9	Sales	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2021-09-10	Active	Active	Completed	10 years	Infosys	Full-time	Permanent	No	60 days	TK-4009	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Sales"]	["NA"]	["English", "Hindi"]	78	76	5	83	98	88	Ready Now	Solid contributor on current assignments.	ABCDE1243F	501234567809	L4	100112345009	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890009	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7c9168b9-8269-430b-89d8-a1ba0b8e99af	TK-1017	Ishita	Bansal	ishita.bansal@acme.co	ishita1017@gmail.com	9876501017	9866501017	Female	1990-05-17	137, Andheri Office	9811101017	Single	Indian	aad03f2b-8be9-45c8-a5d4-1082a639acc6	84f01f23-588a-4c7f-b8d8-826b8f210729	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2023-05-10	Active	Active	Completed	8 years	Infosys	Full-time	Permanent	No	60 days	TK-4017	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Design"]	["NA"]	["English", "Hindi"]	86	84	4	91	97	81	Ready Now	Solid contributor on current assignments.	ABCDE1251F	501234567817	L4	100112345017	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890017	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9513e2aa-7ee2-47fc-8b11-a0cf786fd9bc	TK-9999	Sample	Employee	sample.employee@talakunchi.com	sample.personal@gmail.com	9999911111	\N	Female	1995-06-15	Andheri East, Mumbai	9876543210	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	56643cd3-35e5-429e-9b1c-385881443d8f	Developer	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	\N	2026-08-27	Active	Active	\N	4 years	\N	Full-Time	\N	\N	\N	\N	NA	NA	\N	["C#", "React"]	[]	["English", "Hindi"]	\N	\N	\N	\N	\N	\N	\N	\N	AAAAA9999A	501234567890	L2	100987654321	\N	\N	\N	2026-08-27 10:53:49.710257+05:30	2026-09-09 15:56:18.872666+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	81ef3e8a-db52-4670-a73e-5ba4d3b47c48	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567890124	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
498bb0ed-62ca-4e56-bcb3-4cbd356077be	TK-1002	Rohan	Mehta	rohan.mehta@acme.co	rohan1002@gmail.com	9876501002	9866501002	Male	1991-02-02	122, Dombivali Office	9811101002	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	616911db-9bc2-4b40-b50f-2972f2c2f9e6	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Without Bond	Team B	Offsite	2020-02-10	Notice Period	Active	Completed	3 years	TCS	Full-time	Permanent	No	60 days	TK-4002	Resign	bo	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	71	69	4	76	91	81	Ready in 1 year	Solid contributor on current assignments.	ABCDE1236F	501234567802	L5	100112345002	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-06 14:31:48.389003+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-06 14:31:48.389003+05:30	\N	\N	\N	\N	234567890002	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
f7404cb8-5d1a-40bf-b690-22cf179320dd	TK-1008	Samar	Patel	samar.patel@acme.co	samar1008@gmail.com	9876501008	9866501008	Male	1997-08-08	128, Dombivali Office	9811101008	Single	Indian	d0ab0dc3-606c-4d62-95ea-3d62749f9006	dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	Hr	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2020-08-10	Active	Active	Completed	9 years	TCS	Full-time	Permanent	No	90 days	TK-4008	NA	NA	MCA	["Communication", "Delivery", "Human Resources"]	["NA"]	["English", "Hindi"]	77	75	4	82	97	87	Ready in 1 year	Solid contributor on current assignments.	ABCDE1242F	501234567808	L4	100112345008	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890008	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
f8258beb-f446-477d-bb7e-69666c5fe314	TK-1012	Yash	Malik	yash.malik@acme.co	yash1012@gmail.com	9876501012	9866501012	Male	1993-12-12	132, Dombivali Office	9811101012	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	56643cd3-35e5-429e-9b1c-385881443d8f	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2024-12-10	Active	Active	Completed	3 years	TCS	Full-time	Permanent	No	90 days	TK-4012	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	81	79	5	86	92	91	Ready in 1 year	Solid contributor on current assignments.	ABCDE1246F	501234567812	L4	100112345012	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890012	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
fc06e810-3e2d-4510-bfc1-669ccf579da2	TK-1006	Ankit	Verma	ankit.verma@acme.co	ankit1006@gmail.com	9876501006	9866501006	Male	1995-06-06	126, Dombivali Office	9811101006	Single	Indian	aad03f2b-8be9-45c8-a5d4-1082a639acc6	84f01f23-588a-4c7f-b8d8-826b8f210729	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Navare Plaza, Dombivli	\N	Permanent - Bond	\N	Offsite	2024-06-10	Active	Active	Completed	7 years	TCS	Full-time	Permanent	Yes — 2 years	90 days	TK-4006	NA	NA	MCA	["Communication", "Delivery", "Design"]	["NA"]	["English", "Hindi"]	75	73	5	80	95	85	Ready in 1 year	Solid contributor on current assignments.	ABCDE1240F	501234567806	L4	100112345006	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-09-09 15:56:18.872666+05:30	\N	\N	\N	\N	\N	\N	\N	234567890006	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: exited_employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exited_employees ("Id", "OriginalEmployeeId", "EmployeeCode", "FullName", "DepartmentName", "DesignationName", "WorkEmail", "PersonalEmail", "Phone", "StatusAtExit", "ExitType", "ExitReason", "ResignationDate", "LastWorkingDay", "ReasonForLeaving", "NoticePeriodServed", "ExitChecklistJson", "AssetReturnJson", "FinalSettlementJson", "ExitedAtUtc", "ExitedBy", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "ClearanceCompleted", "ExitRating") FROM stdin;
c86dbb9b-4d96-4e3a-b74a-a94fa9992605	96425efc-9b0e-4f2b-8fd6-ec3b77161547	EMP-3456	Dhanshree Pansare	Squad1	operation head	dhanshree.pansare@gmail.com	dhanshree.pansare002@gmail.com	9326178048	Probation	Resign	bo	2026-08-20	2026-11-18	bo	90 days	\N	\N	\N	2026-08-20 19:16:59.169476+05:30	\N	2026-08-20 19:16:59.255691+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	f	\N
2045661c-a8d6-4501-b7e1-c2ac306c397b	eb50369d-e526-459c-bb6c-aa3a85b231db	EMP-9301	Integration Resource	\N	\N	integration.resource.c92dd5fc2d1c4c4fa7401c33cac1e6fe@acme.co	\N	\N	Probation	Resign	Integration test	2026-08-20	2026-09-19	Integration test	30 days	{}	{}	{}	2026-08-20 17:55:04.296597+05:30	\N	2026-08-20 17:55:04.39085+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	t	\N
84e635a5-0601-4670-a6e5-68562cd9e623	a165f6aa-148a-4ad0-953a-f154ae0991c8	EMP-5886	Integration Resource	\N	\N	integration.resource.e531fb2cecab4c6caa485682aeaa36eb@acme.co	\N	\N	Active	Resign	Notice already ended	2026-08-10	2026-08-19	Notice already ended	30 days	{}	{}	{}	2026-08-20 17:55:04.505815+05:30	\N	2026-08-20 17:55:04.510288+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	t	\N
c96de1f8-bce4-46e6-8fc9-47d9cf00a613	080045f2-3ff3-49af-bced-4b10ea1dde6f	EMP-7266	Integration Resource	\N	\N	integration.resource.ce5bcae27dbc41978b56226b5bf1debf@acme.co	\N	\N	Probation	Resign	Integration test	2026-08-20	2026-09-19	Integration test	30 days	{}	{}	{}	2026-08-20 18:21:19.070579+05:30	\N	2026-08-20 18:21:19.272327+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	t	\N
d11639b8-0639-498f-b29c-8aa7154fd2aa	649f4c6f-8719-4ff4-8969-7a55a16e43bd	EMP-8163	Integration Resource	\N	\N	integration.resource.55c6d73ab436476db67f6f1b9df80d8a@acme.co	\N	\N	Active	Resign	Notice already ended	2026-08-10	2026-08-19	Notice already ended	30 days	{}	{}	{}	2026-08-20 18:21:19.537054+05:30	\N	2026-08-20 18:21:19.547505+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	t	\N
6b3e85ba-b66a-4ee2-a56c-763dadac0945	9e1b1aa9-fcd3-47be-b264-53806520c9fc	EMP-1018	Aditya Reddy	Engineering	Senior Software Engineer	aditya.reddy@acme.co	aditya1018@gmail.com	9876501018	Active	Resign	Better opp	2026-08-20	2026-09-23	Better opp	60 days	\N	\N	\N	2026-08-20 11:40:09.268914+05:30	\N	2026-08-20 11:40:09.305181+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	t	5.0
4b351675-a78a-493e-a0fb-464c1180e0d6	c5d5234b-6151-4e42-abd3-0d91dd38754b	EMP-1015	Meera Nambiar	Product	Business Analyst	meera.nambiar@acme.co	meera1015@gmail.com	9876501015	Active	Resign	better opp	2026-08-20	2026-08-31	better opp	60 days	\N	\N	\N	2026-08-20 12:05:44.250988+05:30	\N	2026-08-20 12:05:44.26208+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	t	5.0
4d7a33d1-9bb6-4174-933a-b67a5f1ee447	df465de2-4aba-41d3-a2a3-1e81ca66e34a	EMP-1004	Karthik Bose	Engineering	DevOps Engineer	karthik.bose@acme.co	karthik1004@gmail.com	9876501004	Active	Resign	Better Opportunity	2026-08-20	2026-10-19	Better Opportunity	60 days	\N	\N	\N	2026-08-20 16:12:11.75374+05:30	\N	2026-08-20 16:12:11.753917+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	f	3.0
30589db9-44d2-4cb5-b6dd-81d1cefbd915	2446deb8-f6cc-4ee1-b179-599d0a2e357a	EMP-1001	Priya Sharma	Engineering	Software Engineer	priya.sharma@acme.co	priya1001@gmail.com	9876501001	Active	Resign	better opp	2026-08-20	2026-08-31	better opp	60 days	\N	\N	\N	2026-08-20 15:10:15.112908+05:30	\N	2026-08-20 15:10:15.160793+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	t	3.0
3a576a72-02ca-4b83-94f4-735b0348c9b2	498bb0ed-62ca-4e56-bcb3-4cbd356077be	EMP-1002	Rohan Mehta	Engineering	Senior Software Engineer	rohan.mehta@acme.co	rohan1002@gmail.com	9876501002	Active	Resign	better opp	2026-08-20	2026-09-04	better opp	60 days	\N	\N	\N	2026-08-20 15:14:21.427364+05:30	\N	2026-08-20 15:14:21.428431+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	t	4.0
\.


--
-- Data for Name: mst_business_units; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_business_units ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
3ee30a59-078a-4469-9b07-540af53ae71e	enterprise	Enterprise	t	3	2026-08-22 01:27:33.556673+05:30	\N	\N	\N	\N
468da60b-5b73-4987-9444-ff16ea7c0b79	digital_solutions	Digital Solutions	t	4	2026-08-22 01:27:33.556673+05:30	\N	\N	\N	\N
9fe393e0-0489-43e0-b868-72217b02c00a	consumer_apps	Consumer Apps	t	2	2026-08-22 01:27:33.556673+05:30	\N	\N	\N	\N
cd3c05b0-fc85-49fe-adcc-e7d2dcde28df	cloud_platform	Cloud Platform	t	1	2026-08-22 01:27:33.556673+05:30	\N	\N	\N	\N
cb7ad9ef-25be-4e54-b7fe-29e3e3571ff2	talakunchi_networks_private_limited	Talakunchi Networks Private Limited	t	1	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_certifications; Type: TABLE DATA; Schema: public; Owner: trackerpro
--

COPY public.mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
044a000c-4987-4557-be49-0005d392cab9	crte	CRTE	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
081c54bf-f67d-47a2-af65-cb3defc904f2	certified_information_systems_security_professiona	Certified Information Systems Security Professional (CISSP)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
085d65e8-647f-47a4-861a-32884d542d8c	offsec_foundational_security_operations_and_defens	OffSec Foundational Security Operations and Defensive Analysis (OSDA)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
0b66b4e2-5e51-4692-95a0-074ece3805d2	elearnsecurity_certified_threat_hunting_profession	eLearnSecurity Certified Threat Hunting Professional (eCTHP)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
0c8807aa-5ec8-418a-91b1-5476ff342f35	offensive_security_experienced_penetration_tester_	Offensive Security Experienced Penetration Tester (OSEP)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
180be5e8-18d0-4170-b8bf-baef93db6699	pnpt	PNPT	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
32d8bcc8-8ada-4386-872f-f81af8bd93b9	blue_team_level_1_and_2	Blue Team Level 1 and 2	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
34546c64-0eb0-4ea1-9896-d1e54b15cd9b	iso_iec_42001	ISO/IEC 42001	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
3929b5f4-81dd-4c28-8b09-9b28bf0aaefd	comptia_securityplus	CompTIA Security+	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
3a994816-e2ff-4809-95dc-9767bec44f44	ecppt	eCPPT	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
3b516e9d-3845-48dc-976c-aba9f1cd057a	iso_22301	ISO 22301	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
43c1b79e-e11f-4747-bb80-c2052e8ab88c	certified_ethical_hacker_(ceh)	Certified Ethical Hacker (CEH)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
454002c9-480f-4802-8dc9-1a7c22408cd8	offensive_security_certified_expert_3_(osce3)	Offensive Security Certified Expert 3 (OSCE3)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
4d49e4bb-3ed7-49a1-804e-9ca207a5afe6	iso_27001	ISO 27001	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
4e9c7754-3dc4-4370-9d45-c9d15a0a80a5	crtp	CRTP	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
574f9792-59c6-4857-9185-c50cc58e22c7	elearnsecurity_certified_incident_responder_(ecir)	eLearnSecurity Certified Incident Responder (eCIR)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
5e56a2ed-8e7e-464d-80d0-c2438159d43b	licensed_penetration_tester_(lpt)	Licensed Penetration Tester (LPT)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
5edf0906-a841-4d70-9e70-537084aa5775	ec_council_certified_incident_handler_(ecih)	EC-Council Certified Incident Handler (ECIH)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
5eebca9a-40fe-4961-b8b7-edb8ced12b06	offensive_security_wireless_professional_(oswp)	Offensive Security Wireless Professional (OSWP)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
73ec95d3-f5e2-4a4e-b85a-b4ea95776090	certified_information_systems_auditor_(cisa)	Certified Information Systems Auditor (CISA)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
7ebe0f29-6883-4c63-ad0a-c363e21dcb99	offensive_security_certified_professional_(oscp)	Offensive Security Certified Professional (OSCP)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
916aeff0-2b4e-4274-a39d-5c3717054b3b	certified_information_security_manager_(cism)	Certified Information Security Manager (CISM)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
b5a20c84-45b3-42b9-a1b0-f6ab5592c042	certified_in_risk_and_information_systems_control_	Certified in Risk and Information Systems Control (CRISC)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
bd10e15d-9c9d-4966-ae0e-be1f0744b9bf	elearnsecurity_certified_digital_forensics_profess	eLearnSecurity Certified Digital Forensics Professional (eCDFP)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
be9df62b-09af-4313-8627-d5075afd2be5	cpts	cPTS	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
ce3fe600-a6d1-40b7-904d-c2f05e914273	crt	CRT	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
dc2cb8ac-9171-425f-8e11-c818422a74ab	offensive_security_web_expert_(oswe)	Offensive Security Web Expert (OSWE)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
dd539749-3d81-4894-bc92-361e3e837a87	certified_threat_intelligence_analyst_(ctia)	Certified Threat Intelligence Analyst (CTIA)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
e86935a2-b837-450c-b3f9-41d86c8f7fc0	certified_cloud_security_professional_(ccsp)	Certified Cloud Security Professional (CCSP)	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_cities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
07183c9f-8e55-4002-bc52-97b380967367	in_raipur	Raipur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
084d0e54-375e-4eb2-a348-577dd4ad73fa	us_boston	Boston	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
08b411f1-b35e-4989-a856-ae6f7596743a	mx_mexico_city	Mexico City	t	331cec37-bd6c-4a60-8ac5-b413d9677b8a	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
0b3b4341-9cd1-4d9c-a2ed-12309bce2340	gb_manchester	Manchester	t	1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
0cc0f358-f7aa-48de-a5da-815f3f06c252	us_los_angeles	Los Angeles	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
0dd2728e-6f8d-462e-906f-186f51ab2ba7	us_new_york	New York	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
0e740962-784f-4738-a401-cb10072107e8	in_delhi	Delhi	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
0fb20e80-ce14-4160-9102-dcec4ccdbecc	in_patna	Patna	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
11fe6de8-1cab-45d7-b88d-51151386c2e0	id_jakarta	Jakarta	t	e341a797-6da6-4427-9bc1-f3271b6882c1	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
14c601ac-1628-423f-95ef-c2189d3f1cd8	us_atlanta	Atlanta	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
19062584-e553-4778-96dd-be7031ae6521	in_jodhpur	Jodhpur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
19eb3378-5b1f-4b69-b712-37db29dcd4f3	ca_montreal	Montreal	t	ba695b57-0f82-4ad0-b14a-2785b26209ff	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
1a08451f-8c92-4edf-97da-f9bb41a840e1	in_udaipur	Udaipur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
1a18d297-caf0-4d13-9a25-4014e1e1c6bf	in_kolkata	Kolkata	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
1aae890c-96bd-4529-bcc3-fed9fd30c24d	kr_seoul	Seoul	t	c093b0e3-31a9-40b4-840c-539ca86bc578	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
1b61f09f-68d1-480d-bc08-96836413a8c6	gb_edinburgh	Edinburgh	t	1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
1e051a3a-34a5-4854-9e7b-9813fc76c34f	sa_jeddah	Jeddah	t	28d63d80-4982-4a6b-9400-ee91260b2604	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
1fff6b1e-f337-4f93-a98a-d952449aea7b	in_lucknow	Lucknow	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
213d37ca-46b2-4caa-8551-abbf2274ced7	in_jaipur	Jaipur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
21a5ff30-a774-4d3a-80d4-0eeb88e8b395	in_kochi	Kochi	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
223b9c33-57cc-460f-9433-dc4fb39a649f	gb_birmingham	Birmingham	t	1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
23d8be99-7dfc-48f1-95b1-8d764af0b16a	in_varanasi	Varanasi	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
2451c2e3-f142-48e4-96a3-3eb9eba2c892	sg_singapore	Singapore	t	f1d80739-30d7-4877-a1a7-ee414b074134	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
2764903d-c6c1-4049-84b2-0045296b6040	au_perth	Perth	t	eeb56a1f-9663-4d29-a984-30c4fc133de2	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
277cc369-b358-445d-add4-579a493cc3e7	pk_karachi	Karachi	t	0a836600-60d1-4d2e-bbd7-034b338574ba	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
29593af5-af1d-4a5b-9562-3c7bbdea45ef	fr_paris	Paris	t	a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
2961f98c-8524-49ca-89fb-c7f51a318d4a	pl_krakow	Krakow	t	af68020d-22f0-4f66-91f6-afe82d052ddd	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
301f6d9d-93cd-4eb6-bf32-8e4f09930007	au_melbourne	Melbourne	t	eeb56a1f-9663-4d29-a984-30c4fc133de2	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
30ff773f-5f99-43d2-a22e-6a0c471d5d2a	it_rome	Rome	t	c1764720-16fe-4d3f-bd82-9882632239cd	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
353adddb-265f-4326-9658-700c3558cee7	jp_yokohama	Yokohama	t	01005b87-3f98-4425-8eb9-6417f2d83b41	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
3cf94e25-007c-4f67-9ba2-a64fe7a4e9c5	us_austin	Austin	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
3fb0cb31-828a-4c49-8ffd-f65721b669f1	us_washington_dc	Washington DC	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
3fe72ba7-7db7-4e00-8e58-fa685afca0ce	my_kuala_lumpur	Kuala Lumpur	t	d725a52a-22a3-48d6-b035-001c1aa15eae	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
41e88e7d-b540-4f0b-9dc3-b8a6ed375eac	bd_chittagong	Chittagong	t	ecb5e362-682e-46d2-bee2-ef0b022ebb13	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
4351e7e2-fe6b-4062-b7e1-5a23b152a2fd	in_guntur	Guntur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
449b8fec-f1a0-4b96-ba76-b11fc95dc854	de_hamburg	Hamburg	t	3f86bc47-1e09-482f-9671-9f4b5b089ee4	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
44cff32a-4802-47a7-8590-cb61848bbf81	jp_tokyo	Tokyo	t	01005b87-3f98-4425-8eb9-6417f2d83b41	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
45e91295-3902-440f-85af-13e998ad000c	in_vadodara	Vadodara	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
45fc7e0b-fa8b-4e17-9df2-2b803f1692c2	nz_wellington	Wellington	t	58746abf-d5dc-4cc8-8a35-96a1747f7a1f	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
484378bd-7a89-4b55-9add-8a22bd71995a	in_ahmedabad	Ahmedabad	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
4860b8a2-acf1-47bc-aa0e-b9a88341e321	it_milan	Milan	t	c1764720-16fe-4d3f-bd82-9882632239cd	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
48a796c1-38e5-49f0-bbd5-6400ce30ee23	in_nagpur	Nagpur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
4a2b4e31-024b-4bae-9cec-afefe791e0ee	ae_sharjah	Sharjah	t	1d3750a9-fab1-43fb-ab7b-865dda283bf3	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
4a9692f8-9fc3-48f8-82bd-075a36f31ecf	za_cape_town	Cape Town	t	585fb67f-28ee-437c-aa84-fdc20a1a11d5	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
4c92b186-fb45-4ed0-b38d-cda7f143a993	de_frankfurt	Frankfurt	t	3f86bc47-1e09-482f-9671-9f4b5b089ee4	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
4d396fc0-ae55-4eeb-b2db-79bbb757d3cd	in_kalyan_dombivli	Kalyan-Dombivli	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
4fd00295-51a7-4bfe-81fa-97cdcce23451	cn_shenzhen	Shenzhen	t	8b34d450-add9-4da2-ab29-651c187ae702	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
55e401d4-a911-4f92-ba41-23e34513ef78	in_amritsar	Amritsar	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
57a45744-d93d-4ca7-9fee-8358914674b9	bd_dhaka	Dhaka	t	ecb5e362-682e-46d2-bee2-ef0b022ebb13	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
5965cf30-b981-47ca-a3ba-c875c33c1361	ae_dubai	Dubai	t	1d3750a9-fab1-43fb-ab7b-865dda283bf3	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
5a35da4d-0d93-45a9-bb97-aa470535f713	in_thiruvananthapuram	Thiruvananthapuram	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
5b3989d6-699e-47a3-8c8b-0c6fa6509727	de_munich	Munich	t	3f86bc47-1e09-482f-9671-9f4b5b089ee4	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
5cd424e6-ab9c-4498-a67e-027a9c3439ce	de_berlin	Berlin	t	3f86bc47-1e09-482f-9671-9f4b5b089ee4	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
626c62f3-eac8-492b-b570-ab1c6ac764a6	nl_amsterdam	Amsterdam	t	6f9bb48d-5314-461c-aab8-3b47b00b27a1	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
642f3232-b168-4934-b4e3-f10437500640	in_kanpur	Kanpur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
670404c6-c476-4d08-a374-3e4d6669f66c	in_chandigarh	Chandigarh	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
67f59fe5-a37c-49b9-b0cf-322a8b0b2d3b	no_oslo	Oslo	t	a890f8b0-d80f-4a14-994e-0ba88d6336a9	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
6a068925-de66-4927-979b-5ed42766c09b	au_brisbane	Brisbane	t	eeb56a1f-9663-4d29-a984-30c4fc133de2	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
6e520834-9523-42ad-8ad8-20e8b14dea83	es_barcelona	Barcelona	t	4da9200f-5486-4710-bf58-e73778e1d506	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
6ffbb80b-985d-4f00-9140-db22f39a625d	in_mumbai	Mumbai	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
716817f5-02f6-4f05-8daa-023f6cdffede	in_hubballi	Hubballi	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
740a6636-f7ab-498d-9f2b-588eaac5338a	th_bangkok	Bangkok	t	64ea0815-a39c-4ecb-b771-038dd74a9b7c	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
7621f953-b63b-4a95-b23f-3e0277109b92	se_stockholm	Stockholm	t	990888a7-50d0-45f0-b650-2686f87c4fd0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
79b5f114-216f-4ee1-973c-57e22110d450	za_johannesburg	Johannesburg	t	585fb67f-28ee-437c-aa84-fdc20a1a11d5	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
7a91b70b-e0ce-4613-9d2f-4ebd06b816eb	be_brussels	Brussels	t	6e5c5f7b-ab38-4926-9945-da9ac35a35b0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
7d25aaed-acb8-4b6d-a16a-1b90054e6996	vn_hanoi	Hanoi	t	a3228796-7e35-4710-9439-2aa36754dbbe	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
7dd04422-91e0-4671-965f-66658c3bf3a4	es_madrid	Madrid	t	4da9200f-5486-4710-bf58-e73778e1d506	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
8152a6d2-ce3d-48a9-aee8-2508c86199d1	nl_rotterdam	Rotterdam	t	6f9bb48d-5314-461c-aab8-3b47b00b27a1	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
81908f77-5500-4974-a57a-ba7cfccc7a9a	in_jamshedpur	Jamshedpur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
81a2bc40-e010-43f1-bcce-9a9198d4ab9d	au_sydney	Sydney	t	eeb56a1f-9663-4d29-a984-30c4fc133de2	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
8249edd0-daaf-4d91-8ede-59e00790d90e	in_madurai	Madurai	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
847e49f7-e605-434e-9abe-35b23cb5af90	ch_geneva	Geneva	t	d3791631-5e4b-4efa-a86a-59344c19e1a1	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
87da8284-74ad-4e12-ad68-23fd727a5e5b	ch_zurich	Zurich	t	d3791631-5e4b-4efa-a86a-59344c19e1a1	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
8a0d7587-098e-4c80-ab86-38aa76c56c2d	br_rio_de_janeiro	Rio de Janeiro	t	6044817c-ffa1-44b3-ac2a-05e52b97df4a	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
8c56329e-5d66-48aa-b242-a15150254bf4	cn_shanghai	Shanghai	t	8b34d450-add9-4da2-ab29-651c187ae702	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
8cd04b30-de06-4ba0-81e1-b120cb24045e	pl_warsaw	Warsaw	t	af68020d-22f0-4f66-91f6-afe82d052ddd	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
8de0928d-e308-4272-9dfb-efbd97b6b683	in_mysuru	Mysuru	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
8df31b20-7394-4727-af49-216c3302c4a2	ph_cebu	Cebu	t	1814186b-4a79-45ea-bfc9-bbdc4721e20b	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
92187184-87f9-42c6-84a2-30a1cdcd698f	ae_abu_dhabi	Abu Dhabi	t	1d3750a9-fab1-43fb-ab7b-865dda283bf3	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
95913438-968f-4e17-8324-a8e75b2242f4	in_gurugram	Gurugram	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
9600a90b-6463-48cd-887f-45997a11248d	in_chennai	Chennai	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
96070596-6a1e-44aa-b35b-83b7a6b7b8aa	sa_dammam	Dammam	t	28d63d80-4982-4a6b-9400-ee91260b2604	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
97ec307e-5801-49b4-86aa-75563e5e711b	in_bhubaneswar	Bhubaneswar	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
9891ebbe-9411-4a41-b472-67451441fc56	dk_copenhagen	Copenhagen	t	068fb26f-376a-4976-9127-b0dae76e7dcd	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
9ba22a3c-c3ca-4472-a50d-9bb1b5bd8d09	gb_bristol	Bristol	t	1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
9bc015d9-b447-4cad-b4bb-8d33507cbdaf	fr_lyon	Lyon	t	a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
9cde9f5d-4f0b-4672-a4be-9c1e3f307638	in_aurangabad	Aurangabad	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
a5a7e7fd-087e-464b-bd31-25f11f357f91	us_chicago	Chicago	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
ab7836eb-7cc7-439d-9dca-49161aa76292	in_indore	Indore	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
ab8ebe77-f842-4ae8-a84e-01e14a9fd702	us_seattle	Seattle	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
ad785e99-dacc-477f-8db6-e8046a39b215	pk_islamabad	Islamabad	t	0a836600-60d1-4d2e-bbd7-034b338574ba	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
b1120770-e683-4592-8024-47caf0f35746	in_ranchi	Ranchi	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
b3e264bf-fcc4-45a2-ac8f-04166724d05b	mx_monterrey	Monterrey	t	331cec37-bd6c-4a60-8ac5-b413d9677b8a	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
b5302d8c-0de7-433b-8c87-5cf75f75b5f1	in_dehradun	Dehradun	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
b76b4b18-8708-4ff8-8134-58d5a02e62e7	in_visakhapatnam	Visakhapatnam	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
b79f714f-b9e1-4556-be97-02de9d27568b	in_surat	Surat	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
b8f9023b-e2ec-4095-be6f-2249a95686b5	in_hyderabad	Hyderabad	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
b9e2a825-60b2-4839-865b-dc6b1874d89b	in_bhopal	Bhopal	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
bad14380-4cb5-45f5-b7bb-669181caee13	in_nashik	Nashik	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
bba31ffe-e8c3-4069-9b89-a707f3185cdf	nz_auckland	Auckland	t	58746abf-d5dc-4cc8-8a35-96a1747f7a1f	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
bd3bac50-1d10-44cb-b69b-9e09aa0f6a6b	in_rajkot	Rajkot	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
bd5bed6a-230c-4972-a94a-95457a5ebdaf	vn_ho_chi_minh_city	Ho Chi Minh City	t	a3228796-7e35-4710-9439-2aa36754dbbe	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
bdc2e3e8-bb40-4b50-af48-446cb848bfaf	ca_vancouver	Vancouver	t	ba695b57-0f82-4ad0-b14a-2785b26209ff	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
be3bc063-9c10-4614-94d5-7b847afaf6bd	in_thane	Thane	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
beb4a29c-e0c5-4509-8400-8f672a820183	in_prayagraj	Prayagraj	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
bf4289e3-e404-41e7-829d-8f0028a48965	in_coimbatore	Coimbatore	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
ca0b9269-d93e-4748-9280-939d97ed7ffd	us_dallas	Dallas	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
cd21e337-74ca-4531-920a-fd728182dd9d	in_noida	Noida	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
cd689e49-cf58-40db-aa97-cad0285a0be8	pt_lisbon	Lisbon	t	b8307417-a01f-4b81-8f46-b637c865dc76	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
d2700377-afed-4114-b7cd-fe5d63394dba	kr_busan	Busan	t	c093b0e3-31a9-40b4-840c-539ca86bc578	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
d76207a2-8c4c-4352-acb7-67f098fb08c4	in_bengaluru	Bengaluru	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
d768797a-cf38-4742-83c4-de675ed8d7b6	in_ludhiana	Ludhiana	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
d8136f7e-2533-4704-9c10-4cba8453f4cb	pk_lahore	Lahore	t	0a836600-60d1-4d2e-bbd7-034b338574ba	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
d9972aef-6b7e-48a1-abc0-6a5e043233d9	in_warangal	Warangal	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
dc141bc7-8039-4645-854e-1e2c898ce0dc	in_pune	Pune	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
e00fecb8-b28f-491a-bcb7-dc47445c7c5d	ph_manila	Manila	t	1814186b-4a79-45ea-bfc9-bbdc4721e20b	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
e051a3eb-67a4-48a1-bd0f-ba12879af889	jp_osaka	Osaka	t	01005b87-3f98-4425-8eb9-6417f2d83b41	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
e19e0057-cea0-429c-b5ac-4762d5107735	ie_dublin	Dublin	t	9bd3e0a8-de16-4a26-92aa-b43deae65bb7	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
e28e5c98-4103-43a2-b5a0-ad2ba96bf6d6	at_vienna	Vienna	t	25e6b9ec-058b-4778-9c17-1151079562f4	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
e2e4ac9d-6292-47c1-9424-7362ab4b024c	sa_riyadh	Riyadh	t	28d63d80-4982-4a6b-9400-ee91260b2604	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
e4cbe1c4-88f4-4fc3-b7e9-121f08aa3495	np_kathmandu	Kathmandu	t	c9bb9747-7e0f-424e-864b-182d7a8c4230	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
e69a29ec-e5fa-4786-a88a-13fbaaedddf0	fi_helsinki	Helsinki	t	9c93a091-0971-4080-b15f-ddebb9de6bb3	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
ea72f142-d2b7-4d74-8877-4c5c64106d84	in_navi_mumbai	Navi Mumbai	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
ea739f55-0951-498d-bebc-14f34c1aea51	br_sao_paulo	Sao Paulo	t	6044817c-ffa1-44b3-ac2a-05e52b97df4a	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
eb19cb49-5743-4f8e-b3de-1c97a8527c8a	us_san_francisco	San Francisco	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
ec893479-ffdd-4ec0-9f85-1fdee09c2e06	in_mangaluru	Mangaluru	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
ee152b57-cf4a-4d13-bfd7-7f19f506caa4	ca_toronto	Toronto	t	ba695b57-0f82-4ad0-b14a-2785b26209ff	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
ef0f0962-986c-4894-9ba4-0f0226a8c5ff	qa_doha	Doha	t	7c57576c-45b6-4cf0-b26d-d3e64730118b	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
ef6bd7b1-faf0-4813-8105-b9d7c240d79d	in_vijayawada	Vijayawada	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
f2aaa2da-20ad-4d42-9a32-c264a31d747e	lk_colombo	Colombo	t	7190bc9f-d9d5-4bb3-b889-af8a1d6ec53f	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
fa492bc9-1015-4a17-9e5b-585b44740f64	in_guwahati	Guwahati	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
fa7c197c-a692-443e-bdfa-82c591807262	id_surabaya	Surabaya	t	e341a797-6da6-4427-9bc1-f3271b6882c1	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
fb029a31-16c1-4b23-bc35-3d4ca08e6961	my_penang	Penang	t	d725a52a-22a3-48d6-b035-001c1aa15eae	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
fc8929c1-64ad-4185-bd6e-c706486b8a41	gb_london	London	t	1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
fcf5dd98-6fe2-4ae3-8084-9966e94eb443	cn_beijing	Beijing	t	8b34d450-add9-4da2-ab29-651c187ae702	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
fddb7350-b051-4870-bda3-17f51b79fd67	se_gothenburg	Gothenburg	t	990888a7-50d0-45f0-b650-2686f87c4fd0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
fe6526bc-a57b-4c6e-8094-be6327614409	in_tiruchirappalli	Tiruchirappalli	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 17:07:06.005856+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_contact_designations; Type: TABLE DATA; Schema: public; Owner: trackerpro
--

COPY public.mst_contact_designations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
2439a793-2f5d-47ec-b704-dff75f0b31ca	spoc	SPOC	t	1	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N
542ead97-3c66-4e9a-ac0c-19816c97319f	cio	CIO	t	3	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N
5458b9b8-4fa2-4080-82c0-98ad6c9d621e	ciso	CISO	t	2	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N
d042e54a-5d43-45ec-ab46-74d1ff96fd1a	accounts_head	Accounts Head	t	5	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N
f710431c-7797-4e75-8282-6c22107ef0ce	cfo	CFO	t	4	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_contact_types; Type: TABLE DATA; Schema: public; Owner: trackerpro
--

COPY public.mst_contact_types ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
73296fbf-8e0c-4e38-806c-4a3aa6eb1aa7	accounts	Accounts	t	1	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N
a7106d96-602b-4b0a-b814-4d54e1399ad3	legal	Legal	t	4	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N
bf8adaba-5197-4eb4-bfe7-1937654c19b5	procurement	Procurement	t	2	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N
d9e8b17a-913c-4eef-b749-ce17f315dc0f	technical	Technical	t	3	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_countries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") FROM stdin;
f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	IN	India	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+91	10
01005b87-3f98-4425-8eb9-6417f2d83b41	JP	Japan	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+81	10
068fb26f-376a-4976-9127-b0dae76e7dcd	DK	Denmark	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+45	8
0a836600-60d1-4d2e-bbd7-034b338574ba	PK	Pakistan	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+92	10
1814186b-4a79-45ea-bfc9-bbdc4721e20b	PH	Philippines	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+63	10
1d3750a9-fab1-43fb-ab7b-865dda283bf3	AE	United Arab Emirates	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+971	9
1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	GB	United Kingdom	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+44	10
25e6b9ec-058b-4778-9c17-1151079562f4	AT	Austria	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+43	10
28d63d80-4982-4a6b-9400-ee91260b2604	SA	Saudi Arabia	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+966	9
331cec37-bd6c-4a60-8ac5-b413d9677b8a	MX	Mexico	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+52	10
339b1d1f-d716-422e-9090-127430134420	US	United States	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+1	10
3f86bc47-1e09-482f-9671-9f4b5b089ee4	DE	Germany	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+49	11
4da9200f-5486-4710-bf58-e73778e1d506	ES	Spain	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+34	9
585fb67f-28ee-437c-aa84-fdc20a1a11d5	ZA	South Africa	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+27	9
58746abf-d5dc-4cc8-8a35-96a1747f7a1f	NZ	New Zealand	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+64	9
6044817c-ffa1-44b3-ac2a-05e52b97df4a	BR	Brazil	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+55	11
64ea0815-a39c-4ecb-b771-038dd74a9b7c	TH	Thailand	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+66	9
6e5c5f7b-ab38-4926-9945-da9ac35a35b0	BE	Belgium	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+32	9
6f9bb48d-5314-461c-aab8-3b47b00b27a1	NL	Netherlands	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+31	9
7190bc9f-d9d5-4bb3-b889-af8a1d6ec53f	LK	Sri Lanka	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+94	9
7c57576c-45b6-4cf0-b26d-d3e64730118b	QA	Qatar	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+974	8
8b34d450-add9-4da2-ab29-651c187ae702	CN	China	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+86	11
990888a7-50d0-45f0-b650-2686f87c4fd0	SE	Sweden	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+46	9
9bd3e0a8-de16-4a26-92aa-b43deae65bb7	IE	Ireland	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+353	9
9c93a091-0971-4080-b15f-ddebb9de6bb3	FI	Finland	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+358	9
a3228796-7e35-4710-9439-2aa36754dbbe	VN	Vietnam	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+84	9
a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb	FR	France	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+33	9
a890f8b0-d80f-4a14-994e-0ba88d6336a9	NO	Norway	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+47	8
af68020d-22f0-4f66-91f6-afe82d052ddd	PL	Poland	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+48	9
b8307417-a01f-4b81-8f46-b637c865dc76	PT	Portugal	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+351	9
ba695b57-0f82-4ad0-b14a-2785b26209ff	CA	Canada	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+1	10
c093b0e3-31a9-40b4-840c-539ca86bc578	KR	South Korea	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+82	10
c1764720-16fe-4d3f-bd82-9882632239cd	IT	Italy	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+39	10
c9bb9747-7e0f-424e-864b-182d7a8c4230	NP	Nepal	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+977	10
d3791631-5e4b-4efa-a86a-59344c19e1a1	CH	Switzerland	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+41	9
d725a52a-22a3-48d6-b035-001c1aa15eae	MY	Malaysia	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+60	9
e341a797-6da6-4427-9bc1-f3271b6882c1	ID	Indonesia	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+62	10
ecb5e362-682e-46d2-bee2-ef0b022ebb13	BD	Bangladesh	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+880	10
eeb56a1f-9663-4d29-a984-30c4fc133de2	AU	Australia	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+61	9
f1d80739-30d7-4877-a1a7-ee414b074134	SG	Singapore	t	2026-08-20 17:07:05.749911+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	+65	8
\.


--
-- Data for Name: mst_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
6a43386d-7119-47d6-b95d-84d03b0b29f2	accounts	Accounts	t	2026-08-21 14:47:43.930064+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2083db49-90d5-4f46-b4be-2d0a24edec35	operations	Operations	t	2026-08-21 11:01:26.963654+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	2026-09-09 15:56:17.740045+05:30
3764a485-1786-470f-b3cb-eba4329f07cb	leadership	Leadership	t	2026-08-21 11:01:26.963654+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	2026-09-09 15:56:17.740045+05:30
627cdb67-1e99-46ec-88ff-42b9c361fdc3	product	Product	t	2026-08-21 11:01:26.963654+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	2026-09-09 15:56:17.740045+05:30
7f81ec90-a5fd-4a3e-ac7b-8797e545c431	engineering	Engineering	t	2026-08-21 11:01:26.963654+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	2026-09-09 15:56:17.740045+05:30
92bfb4a4-87df-49ca-8f58-0b4add10f410	marketing	Marketing	t	2026-08-21 11:01:26.963654+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	2026-09-09 15:56:17.740045+05:30
aad03f2b-8be9-45c8-a5d4-1082a639acc6	design	Design	t	2026-08-21 11:01:26.963654+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	2026-09-09 15:56:17.740045+05:30
c21b43ad-98f5-43cb-9466-6f0b22ce7505	delivery	Delivery	t	2026-08-21 11:01:26.963654+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	2026-09-09 15:56:17.740045+05:30
d0ab0dc3-606c-4d62-95ea-3d62749f9006	human_resources	Human Resources	t	2026-08-21 11:01:26.963654+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	2026-09-09 15:56:17.740045+05:30
d32a6c00-a02a-4586-90c2-4a503b6efc3a	sales	Sales	t	2026-08-21 11:01:26.963654+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	2026-09-09 15:56:17.740045+05:30
e91e9aa5-1cbb-4d1e-99fe-d7aefedd9f87	finance	Finance	t	2026-08-21 11:01:26.963654+05:30	2026-09-09 15:56:17.740045+05:30	\N	\N	2026-09-09 15:56:17.740045+05:30
06f45cae-9d7a-4dd1-8475-89bbcd3b5219	services_testing	Services - Testing	t	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	\N
205ee14f-e09b-46eb-ae21-eb53dd0256f5	functional_sales	Functional - Sales	t	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	\N
33c9e9b1-81a5-484c-aa38-311ec21a2649	services_consulting	Services - Consulting	t	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	\N
5ac46d13-eee8-4d94-ad23-6654595594af	core	Core	t	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	\N
5f0ab671-ab48-499c-bddf-d422e35a57b9	services_operations	Services - Operations	t	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	\N
6192d925-174d-4828-aa44-b954aeca7c98	rd_research_and_development	R&D (Research & Development)	t	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	\N
7660ab54-dfc6-4946-8b51-1f3a6fa2fa68	functional_accounts	Functional - Accounts	t	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	\N
77a34a9f-b341-4fd1-bbe4-d50f51083fad	functional_it_administration	Functional - IT Administration	t	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	\N
a07e4649-5069-40fc-9fff-9717b17e8180	functional_project_management	Functional - Project Management	t	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	\N
cedc3855-55d8-463f-86b4-ed7fff0fea65	functional_hr	Functional - HR	t	2026-09-09 15:56:17.740045+05:30	\N	\N	\N	\N
b7f74f2f-55e4-47dc-8df4-3c99582761c3	internship_program	Internship Program	t	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_designations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "DefaultRoleId", "SubDepartment") FROM stdin;
8802cfae-1dcb-4a34-a8cf-cf3de393ee1d	delivery_test_delivery	test delivery	t	c21b43ad-98f5-43cb-9466-6f0b22ce7505	2026-08-21 14:39:45.280716+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
580e71ef-8c9f-44d7-b3bb-e191d8708884	accounts_ca	CA	t	6a43386d-7119-47d6-b95d-84d03b0b29f2	2026-08-21 14:48:00.270122+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
eccddb98-13a9-4d79-82d6-3b97e710c83c	squad1_operation_head	operation head	t	\N	2026-08-20 19:09:27.933257+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
0cbff6d6-9622-4d55-a0db-2e7b192988f3	business_analyst	Business Analyst	t	2083db49-90d5-4f46-b4be-2d0a24edec35	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
13d33d9b-c70e-4f07-897f-c9aa2bf89277	finance_analyst	Finance Analyst	t	e91e9aa5-1cbb-4d1e-99fe-d7aefedd9f87	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
28474f5e-661e-4e24-adfe-6dc0b41d340e	engineering_manager	Engineering Manager	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
38ab8071-cefe-47a1-a29a-793523aa82ae	marketing_lead	Marketing Lead	t	92bfb4a4-87df-49ca-8f58-0b4add10f410	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
3cc44614-05d3-4283-9b66-d95dd7ec5708	project_manager	Project Manager	t	2083db49-90d5-4f46-b4be-2d0a24edec35	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
56643cd3-35e5-429e-9b1c-385881443d8f	software_engineer	Software Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
593f83a4-8af6-4fe5-8e91-a465fa5055e9	sales_executive	Sales Executive	t	d32a6c00-a02a-4586-90c2-4a503b6efc3a	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
616911db-9bc2-4b40-b50f-2972f2c2f9e6	senior_software_engineer	Senior Software Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
65bbcacb-ccc4-4502-87d4-eb142c6b406c	content_strategist	Content Strategist	t	92bfb4a4-87df-49ca-8f58-0b4add10f410	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
6c5a2bdd-abe3-4b8c-85cc-3c01321f9690	senior_project_manager	Senior Project Manager	t	c21b43ad-98f5-43cb-9466-6f0b22ce7505	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
72466f60-859b-4946-998c-b34eb2c40c0e	tech_lead	Tech Lead	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
84f01f23-588a-4c7f-b8d8-826b8f210729	ux_designer	UX Designer	t	aad03f2b-8be9-45c8-a5d4-1082a639acc6	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
988d1399-4c1d-4969-b41f-b8c856ff93d5	qa_engineer	QA Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
a307f07d-c56a-47c9-8106-792773adb304	product_manager	Product Manager	t	627cdb67-1e99-46ec-88ff-42b9c361fdc3	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	data_analyst	Data Analyst	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
d15a2e6e-0d0b-4a54-a80b-21c8e580302b	devops_engineer	DevOps Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	hr_business_partner	HR Business Partner	t	d0ab0dc3-606c-4d62-95ea-3d62749f9006	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
e2d6a273-bb40-4b2e-a9b1-e4e5122ebab1	head_of_department	Head of Department	t	3764a485-1786-470f-b3cb-eba4329f07cb	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
f9aa2b6e-26a3-40db-bb37-9c88a1249304	engagement_manager	Engagement Manager	t	c21b43ad-98f5-43cb-9466-6f0b22ce7505	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N	\N
5e962bb1-7f9c-4dc5-8752-65cea3eaec1c	engineering_ds	ds	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-22 01:07:57.085326+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
0e849b2e-2e7a-4395-a2cc-42fc44367e3a	hr_head	HR Head	t	cedc3855-55d8-463f-86b4-ed7fff0fea65	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	911d3fd2-2e9a-4a85-a79a-49584031c854	\N
2cc85ed4-84f7-4335-b7f4-7af7a3853062	senior_hr_executive_i	Senior HR Executive - I	t	cedc3855-55d8-463f-86b4-ed7fff0fea65	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	911d3fd2-2e9a-4a85-a79a-49584031c854	\N
2f1541a6-e9ae-4257-a305-d42a332bad78	accountant_i	Accountant - I	t	7660ab54-dfc6-4946-8b51-1f3a6fa2fa68	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869	\N
37c55592-7583-453d-a53e-5512e4f0cd7b	senior_pmo_ii	Senior PMO - II	t	a07e4649-5069-40fc-9fff-9717b17e8180	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde	\N
47479397-c578-40e8-807e-a4bdef70cc00	senior_hr_executive_ii	Senior HR Executive - II	t	cedc3855-55d8-463f-86b4-ed7fff0fea65	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	911d3fd2-2e9a-4a85-a79a-49584031c854	\N
52330869-22cf-4298-9022-60ae3037011a	recruitment_coordinator_i	Recruitment Coordinator - I	t	cedc3855-55d8-463f-86b4-ed7fff0fea65	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	911d3fd2-2e9a-4a85-a79a-49584031c854	\N
5b9eaa82-5eaf-46fb-bdf7-0466b5652903	senior_accountant_iii	Senior Accountant - III	t	7660ab54-dfc6-4946-8b51-1f3a6fa2fa68	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869	\N
6cf90764-755d-49ec-85d4-d939681e90a7	recruitment_coordinator_ii	Recruitment Coordinator - II	t	cedc3855-55d8-463f-86b4-ed7fff0fea65	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	911d3fd2-2e9a-4a85-a79a-49584031c854	\N
6dca2f29-6a69-4e76-b481-4beabbc8374f	senior_accountant_ii	Senior Accountant - II	t	7660ab54-dfc6-4946-8b51-1f3a6fa2fa68	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869	\N
8f51e9d9-848d-40b4-a295-5cd32714bc5d	associate_pmo_i	Associate PMO - I	t	a07e4649-5069-40fc-9fff-9717b17e8180	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde	\N
9a1ce280-ba88-4ef6-b1d9-c0d0995f062b	senior_delivery_account_manager_ii	Senior Delivery Account Manager II	t	a07e4649-5069-40fc-9fff-9717b17e8180	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89	\N
9b37214d-7ff9-4315-89b6-b0236b42e829	delivery_account_manager_ii	Delivery Account Manager - II	t	a07e4649-5069-40fc-9fff-9717b17e8180	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89	\N
a2ca53bb-4310-46c0-b279-c347cfe7e8f4	delivery_account_manager_i	Delivery Account Manager - I	t	a07e4649-5069-40fc-9fff-9717b17e8180	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89	\N
a5a379cd-b304-4e39-a2a0-0509063fe401	accountant_ii	Accountant - II	t	7660ab54-dfc6-4946-8b51-1f3a6fa2fa68	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869	\N
ac4919b1-c571-4157-8143-dedbdc2180e5	accountant_iii	Accountant - III	t	7660ab54-dfc6-4946-8b51-1f3a6fa2fa68	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869	\N
d86060d5-1b9e-4de8-a684-e5734ce7a3fc	associate_pmo_ii	Associate PMO - II	t	a07e4649-5069-40fc-9fff-9717b17e8180	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde	\N
e758d38f-660b-45f4-84be-9216db607751	senior_accountant_i	Senior Accountant - I	t	7660ab54-dfc6-4946-8b51-1f3a6fa2fa68	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869	\N
ebdb5a53-d138-455c-97a6-7d22fcdb60ea	senior_pmo_i	Senior PMO - I	t	a07e4649-5069-40fc-9fff-9717b17e8180	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde	\N
fc2694be-4d7a-4c9f-9519-8b3593585215	senior_delivery_account_manager_i	Senior Delivery Account Manager I	t	a07e4649-5069-40fc-9fff-9717b17e8180	2026-09-23 16:37:51.861151+05:30	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89	\N
014b88f2-93d2-4230-b09d-386348371cc9	soc_analyst_ii	SOC Analyst - II	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	5c1d7a82-83ba-4fe0-8d66-c88dc7401f85	\N
068c6c3a-1685-4fd5-a6d8-d375c659b2b9	senior_cloud_security_consultant	Senior Cloud Security Consultant	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	e721fe39-f2b6-4242-89b1-7d625a52e7ef	\N
08b8dd55-78f4-4660-8c28-ffa59c986520	soc_analyst_iv	SOC Analyst - IV	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	5c1d7a82-83ba-4fe0-8d66-c88dc7401f85	\N
09b44de2-ac6c-4b11-93f4-750277c377d6	devsecops_specialist_ii	DevSecOps Specialist - II	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	e721fe39-f2b6-4242-89b1-7d625a52e7ef	\N
12c6b15d-cc6b-4caa-949e-60ebd312c699	siem_admin_iv	SIEM Admin - IV	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	c6644cac-35a6-4995-85c8-b282842ba6b7	\N
14558782-fd07-453b-9f20-26dce89f9ca8	associate_project_manager	Associate Project Manager	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	e721fe39-f2b6-4242-89b1-7d625a52e7ef	\N
17594a1e-2ac2-41a7-9049-eaa5b8b804c4	pentester_iii	PenTester - III	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
1f542192-c47d-47df-936f-49ed6eab99f0	siem_admin_ii	SIEM Admin - II	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	5c1d7a82-83ba-4fe0-8d66-c88dc7401f85	\N
225e8f8a-0ed0-450a-8c3a-f704c0ef2f33	desktop_support_engineer_ii	Desktop Support Engineer - II	t	77a34a9f-b341-4fd1-bbe4-d50f51083fad	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	f49b34ca-2dda-4e7f-a6be-13ae51398534	\N
25c0b37b-b795-442a-82d9-a529b24dbb26	pentester_ii	PenTester - II	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
261df70f-c3dc-439a-a45f-712d7e8c5e68	soc_analyst_iii	SOC Analyst - III	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	5c1d7a82-83ba-4fe0-8d66-c88dc7401f85	\N
2b0521f1-c76b-4032-b05a-57b588d5af26	desktop_support_engineer_i	Desktop Support Engineer - I	t	77a34a9f-b341-4fd1-bbe4-d50f51083fad	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	f49b34ca-2dda-4e7f-a6be-13ae51398534	\N
2bbedc7b-a261-47b7-8064-fd6d80c05546	python_developer_ii	Python Developer - II	t	6192d925-174d-4828-aa44-b954aeca7c98	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	1e15022e-e553-45a9-a98a-63776eea0894	\N
2ccf3608-470b-4eb2-8e56-a1a6e1bd0cbd	soc_lead_ii	SOC Lead - II	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	8dce3f09-e10d-40d2-b790-4002f92605e8	\N
3031e695-78f9-4c97-b0ea-5ee8bdefecc7	associate_customer_success_i	Associate Customer Success I	t	205ee14f-e09b-46eb-ae21-eb53dd0256f5	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	6871921d-355c-45a9-8c36-9dc6c84c93c1	\N
3079edc4-d338-4e9f-96ad-d5671f18e1c7	senior_pentester_ii	Senior Pentester - II	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
34e05dad-93b2-4e64-a82a-7a92255bc252	devsecops_practitioner_i	DevSecOps Practitioner - I	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
3a846f8d-ea42-4cbc-85c0-09936bc10f41	devsecops_associate	DevSecOps Associate	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	c4f13d59-4a2c-47e2-b49b-89acd8e560c7	\N
3b6a958a-88a4-45e7-bcdd-fed269609cd9	pentester_i	PenTester - I	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
3e3a8e0b-76d8-44fd-825a-86f3b9d127f2	python_developer_i	Python Developer - I	t	6192d925-174d-4828-aa44-b954aeca7c98	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	1e15022e-e553-45a9-a98a-63776eea0894	\N
40ca3bc5-f4fd-423a-b95f-bc2c29e85c1b	senior_grc_auditor_ii	Senior GRC Auditor - II	t	33c9e9b1-81a5-484c-aa38-311ec21a2649	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	9ec604bc-1626-4394-aa5e-ccb022a07d3b	\N
4446726e-ca79-4f3b-a73f-a8659eebbae5	soc_consultant_i	SOC Consultant - I	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	5c1d7a82-83ba-4fe0-8d66-c88dc7401f85	\N
4560f506-e605-4f0b-9b6a-6ac4e698b65f	sales_associate	Sales Associate	t	205ee14f-e09b-46eb-ae21-eb53dd0256f5	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	6871921d-355c-45a9-8c36-9dc6c84c93c1	\N
4a1ce711-d0c6-4f6d-9446-cd35c5e1c1b3	grc_auditor_iv	GRC Auditor - IV	t	33c9e9b1-81a5-484c-aa38-311ec21a2649	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	c09ddcb4-78db-474e-a20e-a322dfe68afa	\N
4beda40b-3ada-4766-b27d-45608205e290	director_and_chief_technology	Director and Chief Technology	t	5ac46d13-eee8-4d94-ad23-6654595594af	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	b88afa2f-417b-4cbe-a032-1855ef15c0d9	\N
57078518-4f46-433d-950e-3810b1187b7d	red_team_specialist_ii	Red Team Specialist - II	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	e721fe39-f2b6-4242-89b1-7d625a52e7ef	\N
58e26cfb-a084-442b-9dce-5bb07edcb80f	manager_i	Manager - I	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	a4d0ebe9-2fc5-4e5b-bde3-bb3001d1c27e	\N
61c245ce-f8ed-420c-bccd-db57429d5e11	grc_auditor_i	GRC Auditor - I	t	33c9e9b1-81a5-484c-aa38-311ec21a2649	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	c09ddcb4-78db-474e-a20e-a322dfe68afa	\N
632673dd-ccca-489d-81f7-3119e0936846	soc_shift_lead_i	SOC Shift Lead - I	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	c6644cac-35a6-4995-85c8-b282842ba6b7	\N
6a7adf32-084e-41e1-88fa-df012c8f4491	intern	Intern	t	b7f74f2f-55e4-47dc-8df4-3c99582761c3	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	775be3c0-980d-4ef5-a955-4022a79c77a1	\N
6d1b36cf-62be-4f37-839d-4064ed775ffe	it_admin	IT Admin	t	77a34a9f-b341-4fd1-bbe4-d50f51083fad	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	f49b34ca-2dda-4e7f-a6be-13ae51398534	\N
7e9fd108-dbb1-4bb7-b991-9834dac68810	senior_vice_president_principal	Senior Vice President - Principal	t	33c9e9b1-81a5-484c-aa38-311ec21a2649	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	f4502ad6-a4cb-4899-a562-eb5fa2cd1122	\N
81dc022e-3683-41c5-8d23-599ec1230ce4	director_and_chief_executive	Director and Chief Executive	t	5ac46d13-eee8-4d94-ad23-6654595594af	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	529b6df4-d182-4c06-9c26-99b1eff2a7e5	\N
82eebcc4-da6b-4930-97b3-650893c68e2c	devsecops_practitioner_ii	DevSecOps Practitioner - II	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
97474744-ce37-4633-b488-1c3ab5d67164	red_team_practitioner_ii	Red Team Practitioner - II	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
9b6e3fb5-df61-4d36-9bc1-89980ff7cb5f	soc_shift_lead_ii	SOC Shift Lead - II	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	c6644cac-35a6-4995-85c8-b282842ba6b7	\N
9bba1e5e-4185-4624-9862-76c7723ba3ac	red_team_practitioner_iii	Red Team Practitioner - III	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
9fe49a13-fd38-419d-8118-fbab537dc015	soc_consultant_ii	SOC Consultant - II	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	5c1d7a82-83ba-4fe0-8d66-c88dc7401f85	\N
a0bc2490-1076-4f8d-89f7-9a48bc4aaa24	associate_manager_i	Associate Manager - I	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	c4f13d59-4a2c-47e2-b49b-89acd8e560c7	\N
a6d3bf7c-0460-4729-8766-5e9bdc97c0ae	siem_admin_iii	SIEM Admin - III	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	5c1d7a82-83ba-4fe0-8d66-c88dc7401f85	\N
ad41e320-d899-4660-8266-a463a7df52c5	devsecops_practitioner_iii	DevSecOps Practitioner - III	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
c3ef71e1-b694-4a1e-a0d8-8fa744f327dd	senior_grc_auditor_i	Senior GRC Auditor - I	t	33c9e9b1-81a5-484c-aa38-311ec21a2649	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	9ec604bc-1626-4394-aa5e-ccb022a07d3b	\N
c3fdca36-0d13-49d2-811f-006b32e3410a	senior_pentester_i	Senior Pentester - I	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
c6e2566e-d9bb-4526-8b86-a0baadb6474d	director_and_chief_operating	Director and Chief Operating	t	5ac46d13-eee8-4d94-ad23-6654595594af	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	d5e52e74-de97-4a33-8a09-c35df51bffe3	\N
cbe2b00e-ad24-41a0-b6ee-7192d2bea68c	director_product_sales	Director - Product Sales	t	205ee14f-e09b-46eb-ae21-eb53dd0256f5	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	6871921d-355c-45a9-8c36-9dc6c84c93c1	\N
d335258d-5a92-4896-b7bb-b0943341f769	associate_manager_iii	Associate Manager - III	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	c4f13d59-4a2c-47e2-b49b-89acd8e560c7	\N
dbdaaf85-fb28-42dc-a2ee-f791a50993e2	siem_admin_i	SIEM Admin - I	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	5c1d7a82-83ba-4fe0-8d66-c88dc7401f85	\N
e046b004-6423-4c88-ab19-244f9941c4df	pentester_iv	PenTester - IV	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
e4c9cfa7-4613-4566-91cc-1957f52d86c0	associate_ai_engineer_contractor	Associate AI Engineer - Contractor	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	92879bb2-39b1-4dbd-82f7-cee142ca0863	\N
e7d748e4-333c-4640-b1b5-d74c4ffb049a	business_development_associate	Business Development Associate	t	205ee14f-e09b-46eb-ae21-eb53dd0256f5	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	214e9378-4adc-44ec-b2da-c183819b146d	\N
e95a0bfb-b1b7-4f4a-9d49-c11fe6933f5c	associate_customer_success_ii	Associate Customer Success II	t	205ee14f-e09b-46eb-ae21-eb53dd0256f5	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	6871921d-355c-45a9-8c36-9dc6c84c93c1	\N
ecd90581-383c-4907-a728-086006636808	customer_success_representative	Customer Success Representative	t	205ee14f-e09b-46eb-ae21-eb53dd0256f5	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	214e9378-4adc-44ec-b2da-c183819b146d	\N
eff9df5f-492b-41fa-9193-59a153611e44	soc_lead_i	SOC Lead - I	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	44608b3b-3100-471f-a303-fd8dc77ae8f4	\N
f583456c-c79c-4f5d-88c8-6dac66223c2b	senior_vice_president	Senior Vice President	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	5464ac47-f03e-4924-b36e-2f511980f6f0	\N
fb646f5f-09ff-4c22-9e8b-e9c1e64317db	grc_auditor_iii	GRC Auditor - III	t	33c9e9b1-81a5-484c-aa38-311ec21a2649	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	c09ddcb4-78db-474e-a20e-a322dfe68afa	\N
fbb5b559-99ca-45ed-9da0-90ae7bfa9ab8	associate_manager_ii	Associate Manager - II	t	06f45cae-9d7a-4dd1-8475-89bbcd3b5219	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	c4f13d59-4a2c-47e2-b49b-89acd8e560c7	\N
fce0c374-c221-4980-9fdd-3017a57165da	soc_analyst_i	SOC Analyst - I	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	5c1d7a82-83ba-4fe0-8d66-c88dc7401f85	\N
fdd7382e-55db-415e-9175-36ec4b9f15ae	principal_manager_i	Principal Manager - I	t	5f0ab671-ab48-499c-bddf-d422e35a57b9	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	eb9b4b0a-35f4-4aef-81b1-a747c2e00cfd	\N
fe31d8ee-99a8-4b4e-8d2a-f42c15d4a352	grc_auditor_ii	GRC Auditor - II	t	33c9e9b1-81a5-484c-aa38-311ec21a2649	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	c09ddcb4-78db-474e-a20e-a322dfe68afa	\N
fe980c86-8fbc-4e40-a56a-2a7189d3982e	python_developer_iii	Python Developer - III	t	6192d925-174d-4828-aa44-b954aeca7c98	2026-09-23 16:37:51.861151+05:30	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	1e15022e-e553-45a9-a98a-63776eea0894	\N
\.


--
-- Data for Name: mst_email_domains; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_email_domains ("Id", "Code", "DomainName", "DisplayName", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
5112286a-225d-4b86-b16f-74211d9c5779	talakunchi_com	talakunchi.com	@talakunchi.com	t	1	2026-08-22 00:42:04.483485+05:30	\N	\N	\N	\N
a19f97e1-8bf5-4b14-823a-b653b62c2954	talakunchi_in	talakunchi.in	@talakunchi.in	t	2	2026-08-22 00:42:04.483485+05:30	\N	\N	\N	\N
fb66fff9-7911-47de-bde7-ab5fb5ab0757	squad1_io	squad1.io	@squad1.io	t	3	2026-08-22 00:42:04.483485+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_employee_statuses; Type: TABLE DATA; Schema: public; Owner: trackerpro
--

COPY public.mst_employee_statuses ("Id", "Code", "Name", "IsActive", "AllowOnboarding", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
08137023-4c73-46d1-bc69-41949bd3b7f2	absconded	Absconded	t	f	3	2026-09-07 12:19:12.924119+05:30	\N	\N	\N	\N
8fd6b84d-730e-4e58-bce5-e7a318bbb7b6	terminated	Terminated	t	f	2	2026-09-07 12:19:12.924119+05:30	\N	\N	\N	\N
cb0e4832-a4eb-401b-88da-9647ed182088	resignation_under_review	Resignation Under Review	t	f	5	2026-09-07 12:19:12.924119+05:30	\N	\N	\N	\N
d2bedef7-50ea-45ea-94e8-1a601564b449	resigned	Resigned	t	f	4	2026-09-07 12:19:12.924119+05:30	\N	\N	\N	\N
f2d44ae7-4a70-42b5-9904-c06a4b464fab	active	Active	t	t	1	2026-09-07 12:19:12.924119+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_graduation_degrees; Type: TABLE DATA; Schema: public; Owner: trackerpro
--

COPY public.mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
087e1648-5e76-41de-b974-9232f90dce42	bba	BBA	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
0ae942c7-9e4f-4cf0-b339-b21d34dd1ae2	btech	B.Tech	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
2ce071ef-0c2a-4ab1-82bc-24cd74f2468e	bca	BCA	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
32a87216-9e54-4899-add0-fff704d371e4	bpharm	B.Pharm	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
68a2ef46-272e-49a9-a72f-565e25945317	bcom	B.Com	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
6c0a7cd3-939e-4c55-b6df-ccc3b4841bbe	ba	B.A.	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
738cc1f5-94ed-4799-9112-609c0517cf18	be	BE	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
80a3bfcb-a47e-4bc9-b189-30ace328d09a	be	B.E.	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
960637af-adaa-4bb2-94c9-54273b174f69	bsc	B.Sc	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
fc2cd932-b34c-4cd0-b1cd-3d13b669317c	bs	BS	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_industries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
7f460c51-01ec-4da1-8f71-d6f360b56f91	healthcare	Healthcare	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
f175fde9-14f8-40e8-b564-47d8a29d84ff	logistics	Logistics	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
c7e82721-829b-4450-8393-022587178471	energy	Energy	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
4a80bfdb-a191-4ce1-ab51-2142eb366db7	banking	Banking	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
935db8d7-e2aa-417e-839e-b51d00ce951e	retail	Retail	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
e722474e-d845-42b8-978e-91a6ec78f080	manufacturing	Manufacturing	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
ff5e83cc-9c1c-4056-ab0b-42a70714ddd3	media	Media	t	2026-08-20 11:45:51.759149+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
02012f0c-97b2-4aea-a6b4-954ee97d892d	technology	Technology	f	2026-08-18 13:25:36.166597+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N
16ebeb23-b3d8-4fb7-a4f6-789510c28ad3	environment	Environment	f	2026-08-18 13:25:36.166597+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N
3a8e57e7-2f6d-4c84-9428-d11de98078c9	quantum_computing	Quantum Computing	f	2026-08-19 12:02:47.466308+05:30	2026-09-25 19:22:24.221994+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4bf54de4-0e85-4904-a89f-542301b65077	automotive	Automotive	f	2026-08-18 13:25:36.166597+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N
cd116cba-a939-4cb7-bd0f-233019a005b0	finance	Finance	f	2026-08-18 13:25:36.166597+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N
b732ebbe-b093-48ed-b2e9-99c8489cfebd	telecom	Telecom	t	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_nationalities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
04b75a98-c6b8-4b0e-a7d4-42ecc057b6cc	austrian	Austrian	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
09129869-9da0-4b92-b902-bccf3b190924	german	German	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
09a35109-3ee6-47e7-9b0b-fa88c7d0ac99	new_zealander	New Zealander	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
09ed0b27-5cde-44d8-9261-3862def51411	bangladeshi	Bangladeshi	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
0cce8a7a-872b-4dcf-b93f-e970e7738b68	nepali	Nepali	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
0fa6ec80-f2ce-4e84-a033-5d1087fb0443	brazilian	Brazilian	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
167a88de-c2f2-4ade-a59f-f0fe528c8148	australian	Australian	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
1b534d63-f63c-40c4-a2aa-4a4ffb6dc84f	malaysian	Malaysian	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
24789f37-c453-4501-a58a-28d529548292	irish	Irish	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
2713bcd3-4be1-419d-9794-bfc156bb272c	finnish	Finnish	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
27649c51-f84b-4c41-98dd-088137056410	portuguese	Portuguese	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
2f45efbb-0fe4-4ff4-823a-115b4a4eebe7	thai	Thai	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
3360906d-ef37-472e-88c2-d683adeb1a3c	vietnamese	Vietnamese	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
3887a87a-8ddb-4b00-8602-b4b5924948e0	italian	Italian	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
391e969e-51f9-4f6e-84dc-999bd5388313	french	French	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
39dd28db-19c0-4825-93ab-cdf200b5293d	sri_lankan	Sri Lankan	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
3f7d49d0-78d5-4ea0-8dc8-8c2e1f38a608	qatari	Qatari	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
402a8883-1aec-4de9-9f11-5fe21f4616e4	norwegian	Norwegian	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
4573bb8a-3983-4b7e-bc35-66cdc453db63	filipino	Filipino	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
51e0b818-e56e-4620-a76d-fb0cf20276ad	singaporean	Singaporean	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
5c53c604-752e-483b-9a69-2a6e335fc95f	swiss	Swiss	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
6bbaf86c-61a5-43d4-8569-88972a5d287b	british	British	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
6c8a9602-77d6-4779-b2fd-0ad5099a8082	swedish	Swedish	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
6f17d00b-2ea6-4e76-88d6-59cdb9868042	american	American	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
72923a6d-50d4-4fee-932a-9285e3790596	japanese	Japanese	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
73179bf3-ae40-46a9-9d97-31ae9cba3ad5	mexican	Mexican	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
79686ca4-102c-456d-a08e-bdf9ac4c7a26	indian	Indian	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
7e7041fd-ea5f-4252-889f-c8397711707e	chinese	Chinese	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
8e6e00fb-5f3d-4218-a910-24781b714a15	canadian	Canadian	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
913f6079-fd2b-45cf-9be6-4097d1532c2b	south_african	South African	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
98426802-63bc-42a4-ba56-b22cc8f62d79	saudi	Saudi	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
a1e8bb9f-8857-4fa5-96ce-228d8167a680	polish	Polish	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
a62e9f44-9f08-4279-8dc9-e73b389474b9	pakistani	Pakistani	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
aa7c3e6d-be99-4998-ab70-b1efeea858b1	belgian	Belgian	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
b57f453f-4e79-401f-a410-a362cd109c7f	south_korean	South Korean	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
b7e05ed9-2278-4803-9eec-29022231e80f	danish	Danish	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
c0723df4-2f0a-4bdd-a6d8-faf6aee6d1ac	dutch	Dutch	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
edc14e22-d845-4e14-9786-259b50ebe78a	emirati	Emirati	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
f1d1979a-91bb-46cf-aec1-6dafb707fcb7	spanish	Spanish	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
fe29360e-bc38-4557-8653-98b749b34fe0	indonesian	Indonesian	t	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_offices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_offices ("Id", "Code", "Name", "WorkLocationId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
4ce8547a-da87-4ebc-a9b3-11055b29f85c	dombivli_navare_plaza	Navare Plaza	d8ad5202-097f-42e5-9afc-9fd1456590ad	t	1	2026-08-22 01:27:33.556673+05:30	\N	\N	\N	\N
70b9b373-1f98-4d24-9344-6c1825ea0d5c	andheri_suvidha_square	Suvidha Square	f8f6b305-478f-41fb-910d-67ef268fc529	t	1	2026-08-22 01:27:33.556673+05:30	\N	\N	\N	\N
375cc899-3e63-4b9c-aad3-368f9a6b50d9	bengaluru_tech_park_west	Tech Park West	0c534759-4e58-40f0-9015-78143792ac7c	f	2	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
3a43966e-cc7a-4f61-9a14-5b4a29918761	mumbai_bandra_kurla_complex	Bandra Kurla Complex	f93f660f-db88-4f46-8df8-ade0e93d3eaf	f	2	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
4ec817eb-b7bc-4cff-ad45-e3f33d9e92ef	remote_virtual_remote	Virtual / Remote	ddf66d66-c299-4a92-a3ca-8fcfa88a00d1	f	1	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
5cc2905f-945a-4fd1-a367-26fa63c93b94	bengaluru_tech_park_east	Tech Park East	0c534759-4e58-40f0-9015-78143792ac7c	f	1	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
6356473e-b6a5-41a7-b7e7-a8c601caf097	hyderabad_hitec_city_office	HITEC City Office	44e2e805-3659-41ed-b423-b12efa989f7d	f	1	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
9b1cd55f-af9a-42ea-89f0-beebd340751b	mumbai_hq_tower	HQ Tower	f93f660f-db88-4f46-8df8-ade0e93d3eaf	f	1	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
f26ab4c4-8824-480f-bbfe-1e08a855f21c	pune_cyber_city_tower	Cyber City Tower	14272979-6065-4afc-92e4-09f335253728	f	1	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
\.


--
-- Data for Name: mst_post_graduation_degrees; Type: TABLE DATA; Schema: public; Owner: trackerpro
--

COPY public.mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
18ea9f2e-6c4b-4cce-be14-37d648244414	ms	MS	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
38f8e989-4318-483a-b86c-5e1f17510d03	mba	MBA	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
5d7547d0-2632-4999-9fd0-3a36ee6adee9	na	NA	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
80bd1b5b-c06b-4cc2-a2c4-06cda6329d27	mca	MCA	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
8446e2d3-69df-4b4f-a04b-993567ccd240	me	ME	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
8aa7e9e3-fda2-4dca-972b-68d578418bdb	mtech	M.Tech	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
ccca84de-eb99-4239-97d5-2d69737c85f2	msc	M.Sc	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
d77b70da-7196-44b9-828d-9fca5ba9d95f	ma	M.A.	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
e0d3c7a5-36cb-40c3-aa73-c258e7724518	mcom	M.Com	t	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_reporting_managers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_reporting_managers ("Id", "Code", "Name", "Designation", "Email", "EmployeeId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
0bf170bc-2bfd-4133-9009-d3176627e14d	riya_kapoor	Riya Kapoor	Engagement Manager	riya.kapoor@acme.co	dd7a3258-31be-425c-8771-cab8ba8b1b22	t	9	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
11e7b9b1-ad41-4198-bd80-7d136992417f	neha_kulkarni	Neha Kulkarni	Technical Lead	neha.kulkarni@talakunchi.com	\N	t	15	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
1adf0cf4-260e-4518-b152-1f892eba2070	divya_rao	Divya Rao	Product Manager	divya.rao@acme.co	a586e15e-0ad4-4d33-aa18-b1edcf241baf	t	5	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
2606f49c-5ed6-4d3c-935a-0959d610ae47	arjun_shah	Arjun Shah	Data Analyst	arjun.shah@acme.co	58198691-3595-4565-8ba6-d5f150240aa3	t	4	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
5843c0cb-ad67-4377-bc53-4d9d1a5bc761	vikram_gupta	Vikram Gupta	Project Manager	vikram.gupta@acme.co	c15b2b43-0884-4999-bece-9289d1db561f	t	11	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
5ad3ffbf-606b-41f9-a34b-8b4cef837d60	rajesh_iyer	Rajesh Iyer	Delivery Manager	rajesh.iyer@talakunchi.com	\N	t	18	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
7f34be9a-66a0-48ee-922b-7994f2eb7cd0	harsh_nair	Harsh Nair	Business Analyst	harsh.nair@acme.co	18b83048-56d5-4365-8bc5-3ba65405467e	t	6	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
8b96778e-13d5-4ab1-ace6-31c6acc88bbb	ankit_verma	Ankit Verma	UX Designer	ankit.verma@acme.co	fc06e810-3e2d-4510-bfc1-669ccf579da2	t	2	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
91f99333-18be-400c-838d-0fe6c171f86e	arjun_mehta	Arjun Mehta	Engagement Manager	arjun.mehta@acme.co	230058bf-ed8a-45da-8d77-4a2821a0a76a	t	3	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
9ef6ec60-9d29-44c2-b0b4-773ba5ae99b1	vikram_deshmukh	Vikram Deshmukh	Director of Product	vikram.deshmukh@talakunchi.com	\N	t	13	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
b7c28347-fe03-4034-9d63-0348a05f85b1	aisha_rao	Aisha Rao	VP of Engineering	aisha.rao@talakunchi.com	\N	t	12	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
b838f751-d684-4c98-a20f-2d656fd09553	ananya_sharma	Ananya Sharma	Lead Architect	ananya.sharma@talakunchi.com	\N	t	17	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
bd239c0a-2dbe-4b43-831e-1607691606c9	pradeep_singh	Pradeep Singh	Engagement Manager	pradeep.singh@acme.co	8a50b4b9-7091-423c-ac8c-af55bc6df348	t	7	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
cbab65ee-e7b4-44e4-9641-3717342c9d88	aanya_joshi	Aanya Joshi	Sales Executive	aanya.joshi@acme.co	593b0378-d20a-40ee-b0a0-ae4acc0a78aa	t	1	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
e0043efa-276b-4b9b-9f1f-9e5349de06b1	sneha_iyer	Sneha Iyer	Tech Lead	sneha.iyer@acme.co	8e97c526-8c79-44c6-a23f-ece0d9b21df5	t	10	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
e206ba0c-38af-45c3-aa46-103dbf3cb45f	rahul_sharma	Rahul Sharma	Engagement Manager	rahul.sharma@acme.co	9a15533f-f863-44a7-b61c-b978fa1f5174	t	8	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
ef80f744-ce30-4db8-ae93-05cd00d748e0	rohan_verma	Rohan Verma	Engineering Manager	rohan.verma@talakunchi.com	\N	t	14	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
f0d6d5a1-bc56-4f3c-8ad5-027bb2f935c4	devansh_shah	Devansh Shah	Head of Design	devansh.shah@talakunchi.com	\N	t	16	2026-08-22 01:00:26.29718+05:30	\N	\N	\N	\N
141f0e6a-7f0b-4fdc-8e48-117012ef17d2	pranjali_shah	Pranjali Shah	Employee	pranjali@talakunchi.io	b78530f0-0687-4f26-a614-8318c62901f9	t	6	2026-08-22 01:27:33.765567+05:30	\N	\N	\N	\N
27ea58af-8649-413b-b68f-5ab8d7ae9e0b	nikhil_khanna	Nikhil Khanna	Sales Executive	nikhil.khanna@acme.co	8065ff15-64d6-4f36-a003-f0444a620bd8	t	4	2026-08-22 01:27:33.765567+05:30	\N	\N	\N	\N
332f42c5-cbe4-4616-bdef-f1c5ed4f525c	ishita_bansal	Ishita Bansal	UX Designer	ishita.bansal@acme.co	7c9168b9-8269-430b-89d8-a1ba0b8e99af	t	2	2026-08-22 01:27:33.765567+05:30	\N	\N	\N	\N
56290531-8a9f-4280-a611-7a056595cf04	pooja_menon	Pooja Menon	HR Business Partner	pooja.menon@acme.co	81c42f4c-b588-4037-a106-47f339a777f6	t	5	2026-08-22 01:27:33.765567+05:30	\N	\N	\N	\N
9e9286c4-8f25-47e2-8bf9-37620fbcb726	kavya_desai	Kavya Desai	Content Strategist	kavya.desai@acme.co	3dcb0f17-b94a-470c-ba85-86ac0f1c65c8	t	3	2026-08-22 01:27:33.765567+05:30	\N	\N	\N	\N
e2ea7517-353b-40d9-be27-0fbe07d6c963	ira_kapoor	Ira Kapoor	QA Engineer	ira.kapoor@acme.co	d24cafbe-bb30-4522-93b2-25588511f0e2	t	1	2026-08-22 01:27:33.765567+05:30	\N	\N	\N	\N
230610a9-f798-4d1d-bf8e-86471c438c9b	samar_patel	Samar Patel	HR Business Partner	samar.patel@acme.co	f7404cb8-5d1a-40bf-b690-22cf179320dd	t	2	2026-08-22 10:31:40.262867+05:30	\N	\N	\N	\N
602e1a4a-f54a-4b9d-bd55-4e5f86d530c9	yash_malik	Yash Malik	Software Engineer	yash.malik@acme.co	f8258beb-f446-477d-bb7e-69666c5fe314	t	3	2026-08-22 10:31:40.262867+05:30	\N	\N	\N	\N
a72d8337-b9ca-41b7-add3-33420d5fa811	priya_shah	Priya Shah	Onboard Role f918b0f6	priya.shah.839199831f3541eda878b9f48a7f9743@acme.co	eb10f37d-b64f-4b17-976b-b962645514f2	t	1	2026-08-22 10:31:40.262867+05:30	\N	\N	\N	\N
99cc2106-d23d-45f8-be08-51ca5b30d452	sample_employee	Sample Employee	Software Engineer	sample.employee@talakunchi.com	9513e2aa-7ee2-47fc-8b11-a0cf786fd9bc	t	1	2026-09-09 15:56:19.230047+05:30	\N	\N	\N	\N
bdd09c00-6c1d-4844-9d76-86300ba8cc46	sample_intern	Sample Intern	Intern	sample.intern@acme.co	a5059f7c-1dce-4123-b024-fea75814ac20	t	2	2026-09-09 15:56:19.230047+05:30	\N	\N	\N	\N
4208f4ef-dc6a-4a3f-afb3-5c06392aa494	dhanshree_pansare	Dhanshree Pansare	Leader (L)	dhanshree.pansare@acme.co	ed0e8e07-0b3b-4c43-862a-e7fedac0735f	t	1	2026-09-25 19:22:25.157374+05:30	\N	\N	\N	\N
f6a73162-5d91-4ba3-96d7-f11a2f4c1038	rohan_joshi	Rohan Joshi	Intern	rohan.joshi@acme.co	e6a87065-9cc2-4a2d-bb25-720ec10771a2	t	2	2026-09-25 19:22:25.157374+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
0102836c-e96f-4d2b-b007-00681e234c4f	product_manager_product_owner	Product Owner	t	a307f07d-c56a-47c9-8106-792773adb304	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
021470ef-63b7-4f33-a166-89ad6e4527dd	senior_software_engineer_senior_developer	Senior Developer	t	616911db-9bc2-4b40-b50f-2972f2c2f9e6	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
06076b20-e352-4d8b-af1b-fd08cf48d91f	business_analyst_analyst	Analyst	t	0cbff6d6-9622-4d55-a0db-2e7b192988f3	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
062bd587-ae2d-4778-a318-54267d377b3c	tech_lead_module_lead	Module Lead	t	72466f60-859b-4946-998c-b34eb2c40c0e	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
0a9604d1-d84f-4f5d-b07c-819ffdd51a36	senior_project_manager_senior_project_manager	Senior Project Manager	t	6c5a2bdd-abe3-4b8c-85cc-3c01321f9690	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
0caa1dc8-ddc8-48b8-89e0-5e8c7e6ec76c	tech_lead_technical_lead	Technical Lead	t	72466f60-859b-4946-998c-b34eb2c40c0e	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
0ea597c5-975c-4942-a9d0-5f782b070fcf	business_analyst_pmo	Pmo	t	0cbff6d6-9622-4d55-a0db-2e7b192988f3	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
0f6f6704-9029-40ae-a364-134064fd0510	senior_project_manager_program_manager	Program Manager	t	6c5a2bdd-abe3-4b8c-85cc-3c01321f9690	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
153fbd68-c0e3-4c0c-8457-09e59dd75203	engineering_manager_engineering_manager	Engineering Manager	t	28474f5e-661e-4e24-adfe-6dc0b41d340e	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
2c66abdd-5233-4a12-95fa-b8ccf3a0e9e1	content_strategist_strategist	Strategist	t	65bbcacb-ccc4-4502-87d4-eb142c6b406c	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
3b786232-e09c-474f-8b27-5368a15f08fa	data_analyst_employee	Employee	t	ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
3be580f9-60aa-4873-b7ad-efd71019d87d	product_manager_product_manager	Product Manager	t	a307f07d-c56a-47c9-8106-792773adb304	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
3e3ba514-020c-4ebd-8caf-4f769320a33d	data_analyst_data_specialist	Data Specialist	t	ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
4c337782-14a9-4f45-b5bc-7eb109232cee	sales_executive_sales	Sales	t	593f83a4-8af6-4fe5-8e91-a465fa5055e9	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
50010858-2dbb-498f-a66c-446e9bbf899a	hr_business_partner_business_partner	Business Partner	t	dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
58c23d88-f5f2-4b3d-8d6e-73c5db83dc47	engineering_manager_people_manager	People Manager	t	28474f5e-661e-4e24-adfe-6dc0b41d340e	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
5f862b6c-d1e5-4910-9e10-d724ed36f612	business_analyst_consultant	Consultant	t	0cbff6d6-9622-4d55-a0db-2e7b192988f3	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
6361a0db-a608-43df-9204-846067c19809	qa_engineer_employee	Employee	t	988d1399-4c1d-4969-b41f-b8c856ff93d5	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
6c42b4d6-5942-474b-a941-82f4ce149209	engagement_manager_engagement_manager	Engagement Manager	t	f9aa2b6e-26a3-40db-bb37-9c88a1249304	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
6f5a3584-346f-44e3-b622-c98887ed28c4	devops_engineer_employee	Employee	t	d15a2e6e-0d0b-4a54-a80b-21c8e580302b	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
71966fd1-29b2-4f57-8e31-0038d1e25c2f	product_manager_projectmanager	ProjectManager	t	a307f07d-c56a-47c9-8106-792773adb304	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
7d5c8430-198d-43b2-939c-c8265ad57910	ux_designer_ux_specialist	UX Specialist	t	84f01f23-588a-4c7f-b8d8-826b8f210729	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
81ef3e8a-db52-4670-a73e-5ba4d3b47c48	software_engineer_developer	Developer	t	56643cd3-35e5-429e-9b1c-385881443d8f	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
8662ae2e-ccd5-48ac-9fe1-28575f2bb48e	qa_engineer_test_engineer	Test Engineer	t	988d1399-4c1d-4969-b41f-b8c856ff93d5	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
8b717023-d9a6-4106-b648-aa91b2f4135f	marketing_lead_marketing_lead	Marketing Lead	t	38ab8071-cefe-47a1-a29a-793523aa82ae	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
8cd59f47-b5fe-498e-bb11-f9333f5459ee	project_manager_projectmanager	ProjectManager	t	3cc44614-05d3-4283-9b66-d95dd7ec5708	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
969eb4d7-e247-4e40-bc58-1b99e8741bf6	software_engineer_employee	Employee	t	56643cd3-35e5-429e-9b1c-385881443d8f	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
9d33858c-0213-4424-a7fe-4b1e5756f27f	tech_lead_teamlead	TeamLead	t	72466f60-859b-4946-998c-b34eb2c40c0e	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
a7fda134-b199-4e5c-868f-8fb089c61a2a	sales_executive_account_executive	Account Executive	t	593f83a4-8af6-4fe5-8e91-a465fa5055e9	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
aa2fedf9-0eff-419d-9140-5b260baa72b4	devops_engineer_devops_specialist	DevOps Specialist	t	d15a2e6e-0d0b-4a54-a80b-21c8e580302b	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
b2490e55-e251-4edb-8fab-e685f452c079	senior_software_engineer_specialist	Specialist	t	616911db-9bc2-4b40-b50f-2972f2c2f9e6	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
b4184ba7-e35a-4832-8ad5-fab4e2faca69	devops_engineer_sre	SRE	t	d15a2e6e-0d0b-4a54-a80b-21c8e580302b	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
b41dbb49-106e-4757-a2ee-606252785f0a	data_analyst_analyst	Analyst	t	ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
bd7f082e-e6ea-4db0-a933-00e99651fa2d	head_of_department_head_of_department	Head of Department	t	e2d6a273-bb40-4b2e-a9b1-e4e5122ebab1	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
c3ab97b0-3b39-4194-a115-9129ad5b5dac	senior_software_engineer_employee	Employee	t	616911db-9bc2-4b40-b50f-2972f2c2f9e6	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
c5147d88-6164-461c-b876-25b1bf5d0ebf	finance_analyst_analyst	Analyst	t	13d33d9b-c70e-4f07-897f-c9aa2bf89277	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
c629ba0f-f37b-4553-9b50-2e1bb748e0f4	engagement_manager_client_partner	Client Partner	t	f9aa2b6e-26a3-40db-bb37-9c88a1249304	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
caf57ec8-e846-4bff-aa3d-8503d6a1cdc3	content_strategist_employee	Employee	t	65bbcacb-ccc4-4502-87d4-eb142c6b406c	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
d40df5fc-8520-4344-96fa-f40372d1f305	finance_analyst_accounts	Accounts	t	13d33d9b-c70e-4f07-897f-c9aa2bf89277	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
d59ab529-3e86-426d-a344-0fa56db21e40	marketing_lead_campaign_lead	Campaign Lead	t	38ab8071-cefe-47a1-a29a-793523aa82ae	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
d5c1a530-bbc3-4701-8fbb-0e373e2219aa	software_engineer_associate_engineer	Associate Engineer	t	56643cd3-35e5-429e-9b1c-385881443d8f	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
dccdd5c3-0546-4a13-9f42-780b6bb0f694	qa_engineer_qa_analyst	QA Analyst	t	988d1399-4c1d-4969-b41f-b8c856ff93d5	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
dfd50b8d-63ea-46a7-871c-6ad164fd49a3	hr_business_partner_hr	Hr	t	dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
e1ff0a28-e113-48d4-aa18-505ea28357cd	head_of_department_director	Director	t	e2d6a273-bb40-4b2e-a9b1-e4e5122ebab1	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
e6e9131d-2328-494a-836a-d4863aa1fd8a	project_manager_delivery_manager	Delivery Manager	t	3cc44614-05d3-4283-9b66-d95dd7ec5708	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
f01e766b-6ff7-4c60-8591-91934f79ad0e	ux_designer_employee	Employee	t	84f01f23-588a-4c7f-b8d8-826b8f210729	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
fbd9d8c8-1fb6-4757-a095-a9f1ec77336b	ux_designer_designer	Designer	t	84f01f23-588a-4c7f-b8d8-826b8f210729	2026-08-20 17:55:01.232338+05:30	\N	\N	\N	\N
78123fe6-6d61-4ca5-b5e1-57d8b06f1787	squad1_operation_head_software_devloer	software devloer	t	eccddb98-13a9-4d79-82d6-3b97e710c83c	2026-08-20 19:09:45.101646+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3c19568f-7048-4ad1-a963-87d3d8b31f36	accounts_ca_jr_ca	Jr. CA	t	580e71ef-8c9f-44d7-b3bb-e191d8708884	2026-08-21 14:48:18.227322+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
04b43350-a92b-4fc4-a8d6-1579689e5521	sales_associate_team_member_tm	Team Member (TM)	t	4560f506-e605-4f0b-9b6a-6ac4e698b65f	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
075f0923-16d3-4ccd-90b2-095e822a9bbb	pentester_iii_team_member_tm	Team Member (TM)	t	17594a1e-2ac2-41a7-9049-eaa5b8b804c4	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
180e2e21-dbad-4bc8-8193-0e1abb38fec1	devsecops_associate_team_leader_tl	Team Leader (TL)	t	3a846f8d-ea42-4cbc-85c0-09936bc10f41	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
1b4d8805-e7a3-459d-8e4c-38b22a8530ac	soc_lead_ii_team_leader_tl	Team Leader (TL)	t	2ccf3608-470b-4eb2-8e56-a1a6e1bd0cbd	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
20af38be-b86a-46bf-9a6e-54b4317d81b9	director_product_sales_team_member_tm	Team Member (TM)	t	cbe2b00e-ad24-41a0-b6ee-7192d2bea68c	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
26213807-f57e-4629-bd25-517463382d1f	desktop_support_engineer_ii_team_member_tm	Team Member (TM)	t	225e8f8a-0ed0-450a-8c3a-f704c0ef2f33	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
2b856c89-fa55-4b73-8514-977764a88b7f	siem_admin_i_team_member_tm	Team Member (TM)	t	dbdaaf85-fb28-42dc-a2ee-f791a50993e2	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
2cb85845-5a1a-44b1-8dcd-b11fb30e31f7	devsecops_practitioner_iii_team_member_tm	Team Member (TM)	t	ad41e320-d899-4660-8266-a463a7df52c5	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
354a0bee-b0f6-429c-a1ed-a137f4c2a9b8	desktop_support_engineer_i_team_member_tm	Team Member (TM)	t	2b0521f1-c76b-4032-b05a-57b588d5af26	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
36da42ca-e14a-4464-9086-df16f2d0bb14	senior_grc_auditor_ii_team_leader_tl	Team Leader (TL)	t	40ca3bc5-f4fd-423a-b95f-bc2c29e85c1b	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
414fb7e9-1531-488b-8af2-7da60a16c4c1	associate_manager_iii_manager_mng	Manager (Mng.)	t	d335258d-5a92-4896-b7bb-b0943341f769	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
4bc48ebf-f617-4512-8a8d-eb969c9669c0	associate_pmo_i_team_member_tm	Team Member (TM)	t	8f51e9d9-848d-40b4-a295-5cd32714bc5d	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
4ccf9754-85f5-473c-a276-5db9b544b042	associate_project_manager_manager_mng	Manager (Mng.)	t	14558782-fd07-453b-9f20-26dce89f9ca8	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
4e0d8c81-1fee-461e-a2b0-490e9ca51f4c	red_team_specialist_ii_manager_mng	Manager (Mng.)	t	57078518-4f46-433d-950e-3810b1187b7d	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
4e267964-bd81-4dca-8324-e0b999929fc3	accountant_iii_manager_mng	Manager (Mng.)	t	ac4919b1-c571-4157-8143-dedbdc2180e5	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
517e9257-2615-4a17-9cd0-e36fbb7e6cfa	grc_auditor_i_team_member_tm	Team Member (TM)	t	61c245ce-f8ed-420c-bccd-db57429d5e11	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
57397344-a5b0-44b3-87d8-72085d09ed59	soc_consultant_i_team_member_tm	Team Member (TM)	t	4446726e-ca79-4f3b-a73f-a8659eebbae5	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
59e19b1c-1c3e-40cb-bcf7-df772a1752f3	soc_lead_i_team_leader_tl	Team Leader (TL)	t	eff9df5f-492b-41fa-9193-59a153611e44	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
5aafdfc2-91d7-4972-b32d-4467214e6d3a	devsecops_practitioner_i_team_member_tm	Team Member (TM)	t	34e05dad-93b2-4e64-a82a-7a92255bc252	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
5c6f1127-eabb-49c0-91a6-985753e9e5b2	python_developer_ii_team_member_tm	Team Member (TM)	t	2bbedc7b-a261-47b7-8064-fd6d80c05546	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
64d3149a-53f8-4c60-9fae-208f19fdf44e	associate_manager_i_team_leader_tl	Team Leader (TL)	t	a0bc2490-1076-4f8d-89f7-9a48bc4aaa24	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
695ed87b-b99d-4efb-a280-573b5f7eb8a3	soc_analyst_ii_team_member_tm	Team Member (TM)	t	014b88f2-93d2-4230-b09d-386348371cc9	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
6a53879b-f082-499f-a287-94dc6e41bcc8	grc_auditor_ii_team_member_tm	Team Member (TM)	t	fe31d8ee-99a8-4b4e-8d2a-f42c15d4a352	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
6ab3c661-db2a-4740-9752-cb185882dd2f	grc_auditor_iii_team_member_tm	Team Member (TM)	t	fb646f5f-09ff-4c22-9e8b-e9c1e64317db	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
6b947dff-8ec5-449a-8a19-5888586d3b5f	pentester_ii_team_member_tm	Team Member (TM)	t	25c0b37b-b795-442a-82d9-a529b24dbb26	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
70f40c23-9e2a-4bb9-a103-9c8d478eee20	siem_admin_iii_team_member_tm	Team Member (TM)	t	a6d3bf7c-0460-4729-8766-5e9bdc97c0ae	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
7964afe1-7d54-4da6-aaa0-0f99d9990cf7	devsecops_specialist_ii_manager_mng	Manager (Mng.)	t	09b44de2-ac6c-4b11-93f4-750277c377d6	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
866aed52-749a-41d4-9105-b3bc585477e6	senior_hr_executive_i_hr	HR	t	2cc85ed4-84f7-4335-b7f4-7af7a3853062	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
89943e85-d319-44a0-94f4-38af50717732	associate_pmo_ii_team_member_tm	Team Member (TM)	t	d86060d5-1b9e-4de8-a684-e5734ce7a3fc	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
8aff8eb6-a53e-46eb-8aaa-76cc13ebb412	it_admin_team_member_tm	Team Member (TM)	t	6d1b36cf-62be-4f37-839d-4064ed775ffe	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
8d8f1ea7-15c5-4d43-9df9-89e996e5e774	pentester_i_team_member_tm	Team Member (TM)	t	3b6a958a-88a4-45e7-bcdd-fed269609cd9	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
8dd8a3a1-e2a9-4bad-bd96-06eb4d8b8867	grc_auditor_iv_team_member_tm	Team Member (TM)	t	4a1ce711-d0c6-4f6d-9446-cd35c5e1c1b3	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
913b1ede-0183-4e8c-8dc3-4b829a594a74	senior_accountant_ii_manager_mng	Manager (Mng.)	t	6dca2f29-6a69-4e76-b481-4beabbc8374f	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
95f033d1-6d81-464e-8f56-31ac5bd998d1	soc_shift_lead_ii_team_leader_tl	Team Leader (TL)	t	9b6e3fb5-df61-4d36-9bc1-89980ff7cb5f	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
9c0ac69d-2771-48dc-ab37-7e987bf05f79	python_developer_iii_team_member_tm	Team Member (TM)	t	fe980c86-8fbc-4e40-a56a-2a7189d3982e	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
9cb82688-22f6-4da1-82fd-c0b6a8caf1d8	soc_consultant_ii_team_member_tm	Team Member (TM)	t	9fe49a13-fd38-419d-8118-fbab537dc015	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
9e5caadf-d0c0-4fc6-bcde-c98984aaf6fa	associate_manager_iii_team_leader_tl	Team Leader (TL)	t	d335258d-5a92-4896-b7bb-b0943341f769	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
a0535078-2372-4aac-8c3a-c3931c6fbfaa	associate_manager_ii_team_leader_tl	Team Leader (TL)	t	fbb5b559-99ca-45ed-9da0-90ae7bfa9ab8	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
a05e7b36-5719-40e8-913c-195767475a3b	hr_head_hr	HR	t	0e849b2e-2e7a-4395-a2cc-42fc44367e3a	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
a22f14ce-eced-4e68-98e9-4d26cd44981a	senior_pmo_ii_manager_mng	Manager (Mng.)	t	37c55592-7583-453d-a53e-5512e4f0cd7b	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
a243b34b-8cd7-4399-bfc3-0e4f9f082340	senior_accountant_iii_manager_mng	Manager (Mng.)	t	5b9eaa82-5eaf-46fb-bdf7-0466b5652903	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
a79ae605-f4b7-4c79-a570-03a4989d61c3	red_team_practitioner_ii_team_member_tm	Team Member (TM)	t	97474744-ce37-4633-b488-1c3ab5d67164	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
a87c713a-cf4e-476a-a11d-4281846a639c	delivery_account_manager_i_team_member_tm	Team Member (TM)	t	a2ca53bb-4310-46c0-b279-c347cfe7e8f4	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
b0552777-5fc9-4c0c-a333-ce35e83b6abb	red_team_practitioner_iii_team_member_tm	Team Member (TM)	t	9bba1e5e-4185-4624-9862-76c7723ba3ac	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
b1c2bce2-857a-4534-98bf-95faa1e2d824	soc_analyst_i_team_member_tm	Team Member (TM)	t	fce0c374-c221-4980-9fdd-3017a57165da	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
b36450b1-5964-4772-9b2c-f11b94400bee	senior_pmo_i_team_leader_tl	Team Leader (TL)	t	ebdb5a53-d138-455c-97a6-7d22fcdb60ea	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
b36e6a32-aaa1-48da-930f-f7915e068ebe	accountant_ii_manager_mng	Manager (Mng.)	t	a5a379cd-b304-4e39-a2a0-0509063fe401	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
b4d71c70-dd3d-4c79-ac60-612a47c0a1ab	recruitment_coordinator_i_hr	HR	t	52330869-22cf-4298-9022-60ae3037011a	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
c11699dd-4e7a-4ec6-a519-354d31a6f27f	pentester_iv_team_member_tm	Team Member (TM)	t	e046b004-6423-4c88-ab19-244f9941c4df	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
c46f829f-6e69-487a-a74a-bb0ba07d2691	senior_hr_executive_ii_hr	HR	t	47479397-c578-40e8-807e-a4bdef70cc00	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
cc26f0c6-d78f-4fcb-bc47-0bf989c41086	soc_analyst_iv_team_member_tm	Team Member (TM)	t	08b8dd55-78f4-4660-8c28-ffa59c986520	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
ccaf42d0-47c7-403e-8793-8d127652d71f	soc_shift_lead_i_team_leader_tl	Team Leader (TL)	t	632673dd-ccca-489d-81f7-3119e0936846	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
cfba6448-c0a3-42e2-bbe6-dc5bad0a624e	manager_i_sr_manager_sr_mng	Sr. Manager (Sr.Mng.)	t	58e26cfb-a084-442b-9dce-5bb07edcb80f	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
d2eedaa7-2725-4324-88c1-8307489a2cf3	principal_manager_i_sr_manager_sr_mng	Sr. Manager (Sr.Mng.)	t	fdd7382e-55db-415e-9175-36ec4b9f15ae	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
e05d1d3e-bfda-4ac9-a82b-4bce2a8f6376	delivery_account_manager_ii_team_member_tm	Team Member (TM)	t	9b37214d-7ff9-4315-89b6-b0236b42e829	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
e3436dcc-6385-4cca-aeb4-eb8f3dad5aa0	senior_accountant_i_manager_mng	Manager (Mng.)	t	e758d38f-660b-45f4-84be-9216db607751	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
e8dc243d-758a-41e5-9a93-b852e159a4e1	devsecops_practitioner_ii_team_member_tm	Team Member (TM)	t	82eebcc4-da6b-4930-97b3-650893c68e2c	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
e8ecabaf-f57f-40b9-8295-09377dd2cb98	recruitment_coordinator_ii_hr	HR	t	6cf90764-755d-49ec-85d4-d939681e90a7	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
ea6ee9f3-d681-4b57-8725-5dac5037ef94	senior_pentester_i_team_member_tm	Team Member (TM)	t	c3fdca36-0d13-49d2-811f-006b32e3410a	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
eae27f30-43a6-4d0a-9b93-3f757c27704c	senior_pentester_ii_team_member_tm	Team Member (TM)	t	3079edc4-d338-4e9f-96ad-d5671f18e1c7	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
ee051f05-0bf5-42c4-bfcc-c25c18080ac3	senior_grc_auditor_i_team_leader_tl	Team Leader (TL)	t	c3ef71e1-b694-4a1e-a0d8-8fa744f327dd	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
f059827c-47b1-4ba3-9e9e-9349356ba0fe	accountant_i_manager_mng	Manager (Mng.)	t	2f1541a6-e9ae-4257-a305-d42a332bad78	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
f2deea76-b6ca-4516-9a0f-168562382277	python_developer_i_team_member_tm	Team Member (TM)	t	3e3a8e0b-76d8-44fd-825a-86f3b9d127f2	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
f327250c-cbf3-4d03-9bd5-d89532f9fcc2	intern_team_member_tm	Team Member (TM)	t	6a7adf32-084e-41e1-88fa-df012c8f4491	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
f4b22180-b1d5-4117-9baf-ebd40bc6956b	siem_admin_ii_team_member_tm	Team Member (TM)	t	1f542192-c47d-47df-936f-49ed6eab99f0	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
f5e0cef8-99fe-4e74-aab3-2450f44c18b3	siem_admin_iv_team_member_tm	Team Member (TM)	t	12c6b15d-cc6b-4caa-949e-60ebd312c699	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
fefa7cc4-ffc6-4247-892d-0cc329bf7d9a	soc_analyst_iii_team_member_tm	Team Member (TM)	t	261df70f-c3dc-439a-a45f-712d7e8c5e68	2026-09-24 11:22:11.164378+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_salary_bands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_salary_bands ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
20ffbe9b-96ca-496e-ab2e-50ccf3c91246	l3	L3	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
37016f9a-2474-400d-99ae-18157aaad035	l1	L1	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	l4	L4	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
e5f5511b-dea6-421c-8c0e-b271e4ee5d43	l5	L5	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
ebed343e-301f-4984-b292-fa8d1cb1623c	l2	L2	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_work_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_work_locations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
0c534759-4e58-40f0-9015-78143792ac7c	bengaluru	Bengaluru	f	3	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
14272979-6065-4afc-92e4-09f335253728	pune	Pune	f	4	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
44e2e805-3659-41ed-b423-b12efa989f7d	hyderabad	Hyderabad	f	5	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
ddf66d66-c299-4a92-a3ca-8fcfa88a00d1	remote	Remote	f	7	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
f93f660f-db88-4f46-8df8-ade0e93d3eaf	mumbai	Mumbai	f	6	2026-08-22 01:27:33.556673+05:30	2026-08-22 10:57:05.36605+05:30	\N	\N	\N
d8ad5202-097f-42e5-9afc-9fd1456590ad	dombivli	Dombivli	f	2	2026-08-22 01:27:33.556673+05:30	2026-09-09 15:56:18.229435+05:30	\N	\N	\N
f8f6b305-478f-41fb-910d-67ef268fc529	andheri	Andheri	f	1	2026-08-22 01:27:33.556673+05:30	2026-09-09 15:56:18.229435+05:30	\N	\N	\N
437c7226-8829-4ea3-b304-031d44895b92	navare_plaza_dombivli	Navare Plaza, Dombivli	t	3	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
a111dabe-c3ac-414b-aa39-f36a880f6a97	onsite	Onsite	t	1	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
e21700a8-7701-457b-96f3-332a9a60aa9e	suvidha_square_andheri	Suvidha Square, Andheri	t	2	2026-09-09 15:56:18.229435+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_tokens ("Id", "UserId", "TokenHash", "ExpiresAtUtc", "RevokedAtUtc", "ReplacedByTokenHash", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
15d68cf7-8b84-47a1-8955-96d5644ef160	40517b71-5e62-182e-73b5-d4070e20a3c2	m2ID5SzqvM55MmSAx5jK2Osea/gqcMgZGlQ5SxiLiXY=	2026-08-14 13:20:13.983139+05:30	2026-08-07 13:25:35.251961+05:30	\N	2026-08-07 13:20:14.000986+05:30	2026-08-07 13:25:35.291997+05:30	\N	\N	\N
7d8336f1-caa0-4eab-b521-b6e37ecb2fe2	40517b71-5e62-182e-73b5-d4070e20a3c2	Lh721AXKdC8QTtH2bEoCjkEnfqEFclsMeMc2vNcEIDE=	2026-08-14 13:25:35.274591+05:30	2026-08-07 13:25:45.608051+05:30	\N	2026-08-07 13:25:35.291997+05:30	2026-08-07 13:25:45.608981+05:30	\N	\N	\N
a9b3cd3f-7d7a-4d92-a1d4-29869153ecde	40517b71-5e62-182e-73b5-d4070e20a3c2	uATHu5oTwYUU6HQcHouy14HKfbmM+q4WUJHD24EMbaQ=	2026-08-14 13:25:45.608283+05:30	2026-08-07 13:25:56.695427+05:30	\N	2026-08-07 13:25:45.608981+05:30	2026-08-07 13:25:56.69573+05:30	\N	\N	\N
e46e62bc-123e-4f1d-830e-38ad2d8f144e	40517b71-5e62-182e-73b5-d4070e20a3c2	bla5iEYpO+U/IPBo/oYud7T3Q1PRmxvPMmC/BLWFdxM=	2026-08-14 13:25:56.695595+05:30	2026-08-07 13:26:41.762854+05:30	\N	2026-08-07 13:25:56.69573+05:30	2026-08-07 13:26:41.763254+05:30	\N	\N	\N
82642a2f-5ed7-42b8-938a-1026a17f273d	40517b71-5e62-182e-73b5-d4070e20a3c2	wo1yPN8gZeM+oOqd23YmtJS70HsomIwjFAbsQTEQXJw=	2026-08-14 13:26:41.763061+05:30	2026-08-07 13:26:51.579036+05:30	\N	2026-08-07 13:26:41.763254+05:30	2026-08-07 13:26:51.579255+05:30	\N	\N	\N
68944323-a9a0-4aa2-a3b5-92acecbed48a	40517b71-5e62-182e-73b5-d4070e20a3c2	0qzfThbGiooWBYFneOyxIeqMyK8s+R5/uCA2HGXiUKs=	2026-08-14 13:26:51.579171+05:30	2026-08-07 13:27:01.950475+05:30	\N	2026-08-07 13:26:51.579255+05:30	2026-08-07 13:27:01.950745+05:30	\N	\N	\N
2f2117e8-deb5-454b-9041-9336b5b8be73	e7554ba2-e546-93ce-1e88-a073badd78a2	+GL/dmLCznwpTJje8asLaMIvbWpXSvU8wovOGdBV4s4=	2026-08-14 13:27:02.689669+05:30	2026-08-07 13:27:03.004561+05:30	\N	2026-08-07 13:27:02.689818+05:30	2026-08-07 13:27:03.004918+05:30	\N	\N	\N
767e68c4-d982-4694-ba7a-b75d34e2abb4	e7554ba2-e546-93ce-1e88-a073badd78a2	lTEYUjW8dATIBSMzYqsETRP42J8jfpwwHDHJ6Eui0Wk=	2026-08-14 13:27:03.004798+05:30	2026-08-07 13:27:03.56644+05:30	\N	2026-08-07 13:27:03.004918+05:30	2026-08-07 13:27:03.56645+05:30	\N	e7554ba2-e546-93ce-1e88-a073badd78a2	\N
2d587391-30e6-408d-9bdb-11f50daf0f9b	40517b71-5e62-182e-73b5-d4070e20a3c2	UiAJaRaM0NPSuOjPIpPTOj2pWaukHkvw5MuT+iBDssk=	2026-08-14 13:27:01.950681+05:30	2026-08-07 13:30:34.623822+05:30	\N	2026-08-07 13:27:01.950745+05:30	2026-08-07 13:30:34.624134+05:30	\N	\N	\N
13b2b9df-9c94-4564-a43e-c12542578167	40517b71-5e62-182e-73b5-d4070e20a3c2	PEqTPFJunMCrPOAhE3IMwcPy19/iMqe203gAQmLRwuA=	2026-08-14 13:30:34.62405+05:30	2026-08-07 13:32:24.241576+05:30	\N	2026-08-07 13:30:34.624134+05:30	2026-08-07 13:32:24.283795+05:30	\N	\N	\N
69e999b4-483c-478b-ba5b-aaea156f970f	40517b71-5e62-182e-73b5-d4070e20a3c2	dToRYveREuMVotYXI1ERt1BB+VtS256aOrI9jULWi3E=	2026-08-14 13:32:24.265028+05:30	2026-08-07 13:32:35.357275+05:30	\N	2026-08-07 13:32:24.283795+05:30	2026-08-07 13:32:35.35837+05:30	\N	\N	\N
22b17976-0af9-46b7-b990-61e1b56785e5	40517b71-5e62-182e-73b5-d4070e20a3c2	kRaOW0DQOi4eTX/KA6lSqY7Z/8C5AGy3JodWjtOqAhs=	2026-08-14 13:32:35.35753+05:30	2026-08-07 13:32:35.39388+05:30	\N	2026-08-07 13:32:35.35837+05:30	2026-08-07 13:32:35.39389+05:30	\N	\N	\N
42f0b6e4-9fa3-4892-b2e4-c17bab7c4a67	40517b71-5e62-182e-73b5-d4070e20a3c2	YbrKNAK0pMup2sl+mEvUkupRoG1rgXkS9BDVXuAj2Qg=	2026-08-14 13:33:35.911747+05:30	2026-08-07 13:33:40.251092+05:30	\N	2026-08-07 13:33:35.912044+05:30	2026-08-07 13:33:40.251281+05:30	\N	\N	\N
802a1b5d-266c-4d89-abf2-8261539873a0	40517b71-5e62-182e-73b5-d4070e20a3c2	d8Fga/ErauFZ/B3nvXyEmco2jkyck3lyFJHgsMoWGX4=	2026-08-14 13:33:40.251224+05:30	2026-08-07 13:33:56.848075+05:30	\N	2026-08-07 13:33:40.251281+05:30	2026-08-07 13:33:56.848397+05:30	\N	\N	\N
a763b4ac-5a9d-4269-bfae-1b08b949d11a	40517b71-5e62-182e-73b5-d4070e20a3c2	J2LmXebhsMx6Ys9jfMlLMV93ccgh/R8D8d2EGwB0y5s=	2026-08-14 13:33:56.848263+05:30	2026-08-07 13:34:47.632885+05:30	\N	2026-08-07 13:33:56.848397+05:30	2026-08-07 13:34:47.633213+05:30	\N	\N	\N
32137029-617c-4ab5-838e-fec6c08ad7ab	40517b71-5e62-182e-73b5-d4070e20a3c2	rXKZs/wY+9uxF+fpZ0PqvbNK/NJs5fl2Q9dQM3qcMmw=	2026-08-14 13:34:47.633103+05:30	2026-08-07 13:35:11.806001+05:30	\N	2026-08-07 13:34:47.633213+05:30	2026-08-07 13:35:11.80629+05:30	\N	\N	\N
c47fda73-3fd7-46d3-980d-0c0a3357fb3f	40517b71-5e62-182e-73b5-d4070e20a3c2	cSo7UpfUNYPZ1skoJ+jrs46w/A+XQMpUT9ICLzO/+Ac=	2026-08-14 13:35:11.806205+05:30	2026-08-07 13:35:22.394378+05:30	\N	2026-08-07 13:35:11.80629+05:30	2026-08-07 13:35:22.395443+05:30	\N	\N	\N
708517c8-0873-443a-8939-0454c329a719	40517b71-5e62-182e-73b5-d4070e20a3c2	V9bBoVFFBuuZf3W5UjzWCNGqJoey57+seERJm8aJ2tQ=	2026-08-14 13:35:22.395285+05:30	2026-08-07 13:37:36.190026+05:30	\N	2026-08-07 13:35:22.395443+05:30	2026-08-07 13:37:36.190325+05:30	\N	\N	\N
a835fda9-6814-4724-adc0-575dbb8c6786	40517b71-5e62-182e-73b5-d4070e20a3c2	BFvHWvWpf1EUPGP/sH2iWnFr343MlKZoPeJZYLh1qFg=	2026-08-14 13:37:36.190231+05:30	2026-08-07 13:37:36.662554+05:30	\N	2026-08-07 13:37:36.190325+05:30	2026-08-07 13:37:36.662564+05:30	\N	\N	\N
2876c68d-251f-49e5-becd-962facb58d63	40517b71-5e62-182e-73b5-d4070e20a3c2	HQO8otL1IzLkRgPdM1g8GPcO40idAxkumsYqTyxKsUU=	2026-08-14 13:39:55.58242+05:30	2026-08-07 13:40:38.78177+05:30	\N	2026-08-07 13:39:55.615759+05:30	2026-08-07 13:40:38.784087+05:30	\N	\N	\N
69b9c78e-abc4-488c-bd9c-0f983b4f4dcd	40517b71-5e62-182e-73b5-d4070e20a3c2	j1rw8A/wj6ZDEu4KFbfvkp8AJzsqU5hXsFPguug1U0s=	2026-08-14 13:40:38.782094+05:30	2026-08-07 13:40:48.110257+05:30	\N	2026-08-07 13:40:38.784087+05:30	2026-08-07 13:40:48.110282+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
0c987fc1-1e36-4dde-a690-6ef3517af286	40517b71-5e62-182e-73b5-d4070e20a3c2	FTH5JqY5Teucgy223pXiY4MP+EoYJYy27jIXXkUfqVs=	2026-08-14 13:41:01.35921+05:30	2026-08-07 13:41:08.038877+05:30	\N	2026-08-07 13:41:01.359515+05:30	2026-08-07 13:41:08.039278+05:30	\N	\N	\N
2b5fa439-3ea0-4ac1-a2e4-cc821316f7a7	40517b71-5e62-182e-73b5-d4070e20a3c2	RxoqM6qaBvFSmYHXPoF4yzJRxAPM2HLPOGTzoIaFKcE=	2026-08-14 13:41:08.039108+05:30	2026-08-07 13:41:08.500286+05:30	\N	2026-08-07 13:41:08.039278+05:30	2026-08-07 13:41:08.500301+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
0ed90fc0-6e12-4100-a298-9407cc40a260	40517b71-5e62-182e-73b5-d4070e20a3c2	qVOstGPV06ceKoaDzN1iKRfbp/MdEHSWmfXxHjAU4Po=	2026-08-14 13:41:08.777404+05:30	2026-08-07 13:41:36.177265+05:30	\N	2026-08-07 13:41:08.777543+05:30	2026-08-07 13:41:36.177596+05:30	\N	\N	\N
54927c1a-ec89-41da-8fa2-587f4dbf4759	40517b71-5e62-182e-73b5-d4070e20a3c2	ghJ9bl9fuz5ZUUtJ6tNrl6FnoC5JeJC5AdMVJQCzK4s=	2026-08-14 13:41:36.177469+05:30	2026-08-07 13:41:45.7917+05:30	\N	2026-08-07 13:41:36.177596+05:30	2026-08-07 13:41:45.791714+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
2d2793d7-bb31-4ec1-aab8-17a0cb360c58	40517b71-5e62-182e-73b5-d4070e20a3c2	xWBgCfQt8cNToEYVeeMqaB8aVAaOmQubpF3rL4otpG8=	2026-08-14 13:45:06.822808+05:30	2026-08-07 13:45:15.861241+05:30	\N	2026-08-07 13:45:06.858179+05:30	2026-08-07 13:45:15.862299+05:30	\N	\N	\N
ca7dcc10-a52b-4050-a1c2-0000689411f3	40517b71-5e62-182e-73b5-d4070e20a3c2	3uwY99c0nt3M2mRZFDjdc0t2cUuT2fwaEHXbMcjPuvs=	2026-08-14 13:45:15.861526+05:30	2026-08-07 13:45:23.503387+05:30	\N	2026-08-07 13:45:15.862299+05:30	2026-08-07 13:45:23.503702+05:30	\N	\N	\N
cecf1e51-c54c-4626-a990-dcf08f2516f7	40517b71-5e62-182e-73b5-d4070e20a3c2	YJ8rqIG13Mspul+Fwim+d23urR/RGMI6dSVAdjxV7dI=	2026-08-14 13:45:23.503578+05:30	2026-08-07 13:46:01.102574+05:30	\N	2026-08-07 13:45:23.503702+05:30	2026-08-07 13:46:01.102586+05:30	\N	\N	\N
120e5ad9-95be-4111-aa57-05ff0661ffe8	40517b71-5e62-182e-73b5-d4070e20a3c2	+FRTXZcv3j0Kh4f48hSF71ZAQleQO72906XGjX033Q8=	2026-08-14 14:57:37.677426+05:30	2026-08-07 15:10:31.841835+05:30	\N	2026-08-07 14:57:37.707591+05:30	2026-08-07 15:10:31.842584+05:30	\N	\N	\N
7cf388c7-55d2-43ff-921a-618d3473cbe3	40517b71-5e62-182e-73b5-d4070e20a3c2	PgqQxYeGLhO3OuUWq9ZX7EWDSHtNNrGBHfR+9F495Bs=	2026-08-14 15:10:31.842102+05:30	2026-08-07 15:22:03.042511+05:30	\N	2026-08-07 15:10:31.842584+05:30	2026-08-07 15:22:03.042783+05:30	\N	\N	\N
d7d8f253-a4f6-4f61-8169-60bbcc37eceb	40517b71-5e62-182e-73b5-d4070e20a3c2	cM7yWG3hj3nYqzOdwLPt8xkjywITFqG/NsEGdeznaV0=	2026-08-14 15:23:58.093184+05:30	2026-08-07 15:47:24.400633+05:30	\N	2026-08-07 15:23:58.113189+05:30	2026-08-07 15:47:24.435368+05:30	\N	\N	\N
9b184308-430d-4737-97d0-a7cac7ece64f	40517b71-5e62-182e-73b5-d4070e20a3c2	+8HihDvKGnli2ijCQUuYrzxeibwySBLe9touN3FB+Ww=	2026-08-14 15:47:24.42069+05:30	2026-08-07 16:39:41.335919+05:30	\N	2026-08-07 15:47:24.435368+05:30	2026-08-07 16:39:41.372108+05:30	\N	\N	\N
0710d7c0-6c85-45b8-97e0-1f868c5c65ce	40517b71-5e62-182e-73b5-d4070e20a3c2	d7ZhvNq1ZOFJYasRCbfid5UrIMWegmc78NoA48Ive1Q=	2026-08-14 16:39:41.356513+05:30	2026-08-10 11:57:06.508659+05:30	\N	2026-08-07 16:39:41.372108+05:30	2026-08-10 11:57:06.551566+05:30	\N	\N	\N
67583fff-3a9d-46a0-bc8b-4744915681fc	40517b71-5e62-182e-73b5-d4070e20a3c2	13ZogkURefIyvpGXe/Wj2JBrp5XjcA/pV7Kjqw5oYBY=	2026-08-17 11:57:06.534783+05:30	2026-08-10 11:57:31.606647+05:30	\N	2026-08-10 11:57:06.551566+05:30	2026-08-10 11:57:31.608365+05:30	\N	\N	\N
4da36a4e-8b7f-4a58-8715-76ffee5a18c3	40517b71-5e62-182e-73b5-d4070e20a3c2	KGFUfIOZes73qVuvInEFxhNWkmwXby2hFjCcGPp7uEk=	2026-08-17 11:57:31.607333+05:30	2026-08-10 12:07:48.361845+05:30	\N	2026-08-10 11:57:31.608365+05:30	2026-08-10 12:07:48.400651+05:30	\N	\N	\N
f658a865-ef25-4564-85fe-d6f27d6676a6	40517b71-5e62-182e-73b5-d4070e20a3c2	GFeYLcDFwLwJoRa4cNJDohcUPf3Fez1LZrfdDb05WiI=	2026-08-17 12:07:48.384118+05:30	2026-08-10 12:07:48.95742+05:30	\N	2026-08-10 12:07:48.400651+05:30	2026-08-10 12:07:48.958671+05:30	\N	\N	\N
768fff40-d289-4aa3-a001-7f6b740ba29c	40517b71-5e62-182e-73b5-d4070e20a3c2	GR+5AXoLKkoPIS1FCJyHTa32rosO/QZVu4tiEIKvLxg=	2026-08-17 12:07:48.957842+05:30	2026-08-10 12:07:59.648198+05:30	\N	2026-08-10 12:07:48.958671+05:30	2026-08-10 12:07:59.682976+05:30	\N	\N	\N
056cc67e-dea8-4407-a4f8-573d042f9a01	40517b71-5e62-182e-73b5-d4070e20a3c2	rlIcf7xdHbPnewemnCrcZmC4no+ZlfQPlIHxHkyePwo=	2026-08-17 12:07:59.666362+05:30	2026-08-10 12:08:16.327559+05:30	\N	2026-08-10 12:07:59.682976+05:30	2026-08-10 12:08:16.366529+05:30	\N	\N	\N
dcb24288-72d3-4f09-b9e5-507d5121a1d2	40517b71-5e62-182e-73b5-d4070e20a3c2	Wf7/NX1MEbpyvqLi3EF30auX8kcm+KcCIwHrrj+oQ/0=	2026-08-17 12:08:16.348652+05:30	2026-08-10 12:09:25.751516+05:30	\N	2026-08-10 12:08:16.366529+05:30	2026-08-10 12:09:25.786525+05:30	\N	\N	\N
e6b93d24-0f8e-43a9-b078-1f39eac57145	40517b71-5e62-182e-73b5-d4070e20a3c2	hf3UOrJo3EonXm5M+RehhTYB4X6n+vr1t6Disqau+2Q=	2026-08-17 12:09:25.76948+05:30	2026-08-10 12:09:26.362052+05:30	\N	2026-08-10 12:09:25.786525+05:30	2026-08-10 12:09:26.363799+05:30	\N	\N	\N
70992db8-abe6-4cd7-903d-686bfadfba87	40517b71-5e62-182e-73b5-d4070e20a3c2	hHogkoiCthztrcqltAnB/B1wo0VN1j1LO9JqMxq3KAc=	2026-08-17 12:09:26.362749+05:30	2026-08-10 12:09:56.465469+05:30	\N	2026-08-10 12:09:26.363799+05:30	2026-08-10 12:09:56.503057+05:30	\N	\N	\N
1c688ebf-7c90-45a3-a25c-5adf99ebfb9a	40517b71-5e62-182e-73b5-d4070e20a3c2	hOMB36WrMhKoYiPy1zUIOnzxg4JAjh47x6GfP+6tHv4=	2026-08-17 12:09:56.486143+05:30	2026-08-10 12:10:14.327631+05:30	\N	2026-08-10 12:09:56.503057+05:30	2026-08-10 12:10:14.362718+05:30	\N	\N	\N
3ce317a7-b672-4ca9-9a6c-20f6ce2ef026	40517b71-5e62-182e-73b5-d4070e20a3c2	DQrbCf1FUT2qOcANLSwXeiKBZM6avtsW01+dxZOEicg=	2026-08-17 12:10:14.346062+05:30	2026-08-10 12:10:14.919217+05:30	\N	2026-08-10 12:10:14.362718+05:30	2026-08-10 12:10:14.920934+05:30	\N	\N	\N
8bbd49a0-4ef5-4ed6-afc2-a53e87e5e583	40517b71-5e62-182e-73b5-d4070e20a3c2	BaRJgDcv2y9duS6NXK/k/JRNtG+cgDGVhLWK/wDdTQ0=	2026-08-17 12:10:14.919921+05:30	2026-08-10 12:23:44.19292+05:30	\N	2026-08-10 12:10:14.920934+05:30	2026-08-10 12:23:44.193225+05:30	\N	\N	\N
3a315a92-4e6e-477f-bdbf-135529e85782	b1d3f51c-b209-d352-4b52-3f4008801ab3	kLwEj/ufnpt7gxFdKluGVMyyEm1vMEYqraU1sox50z8=	2026-08-17 12:26:53.754315+05:30	2026-08-10 12:27:02.684675+05:30	\N	2026-08-10 12:26:53.764781+05:30	2026-08-10 12:27:02.685958+05:30	\N	\N	\N
af20811d-e7a9-47fb-9161-6274c30e5d7d	b1d3f51c-b209-d352-4b52-3f4008801ab3	ojH2uduMFLUOoL6l9Gu6s7rRCd8OQGq2wtqdjYCvc2Y=	2026-08-17 12:27:02.685022+05:30	2026-08-10 12:27:04.081703+05:30	\N	2026-08-10 12:27:02.685958+05:30	2026-08-10 12:27:04.081714+05:30	\N	\N	\N
4844a15e-fa53-4646-887f-a8b04db17f46	9f6f34df-dc47-f198-f3f6-e577aab1cbca	bh0FpJgzFpkmHHZnSHc+4GRk8f3deAQwst9m9yITYms=	2026-08-17 12:27:19.16574+05:30	2026-08-10 12:29:23.501154+05:30	\N	2026-08-10 12:27:19.165935+05:30	2026-08-10 12:29:23.501173+05:30	\N	9f6f34df-dc47-f198-f3f6-e577aab1cbca	\N
359bb0d8-e9d1-4d8d-9745-dd363893ccc1	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	rNKV6KBOvzARNrFe/91AFNM1wznxbwttoftZAhWSgCw=	2026-08-17 12:29:34.907971+05:30	2026-08-10 12:31:27.586695+05:30	\N	2026-08-10 12:29:34.908096+05:30	2026-08-10 12:31:27.586707+05:30	\N	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	\N
02735f4a-ebed-4fe6-bb4b-11b119d5d494	40517b71-5e62-182e-73b5-d4070e20a3c2	ai7WiZY+U3KPQ0HSymcTMvoiva0+1JfyOGXCJHG/fn0=	2026-08-17 12:31:55.794279+05:30	2026-08-10 12:32:04.247712+05:30	\N	2026-08-10 12:31:55.794379+05:30	2026-08-10 12:32:04.247728+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
8a5dbcf9-caf8-4df0-8627-639f6a2c2e03	40517b71-5e62-182e-73b5-d4070e20a3c2	kA7N3AhsshX8F2dYhX0m3aHo7USMorZkDcJjlFuiZTI=	2026-08-17 14:50:16.45192+05:30	2026-08-10 15:40:49.663847+05:30	\N	2026-08-10 14:50:16.486557+05:30	2026-08-10 15:40:49.664859+05:30	\N	\N	\N
aa84fc7b-9e7a-4550-82cb-f3bbe15e2c1b	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	Xb0tfgDqoDSAfTL/OTBQKB3QaL+3hWSjkEKbCwULHrc=	2026-08-14 13:25:46.463547+05:30	2026-08-10 17:56:18.897379+05:30	\N	2026-08-07 13:25:46.463705+05:30	2026-08-10 17:56:18.897894+05:30	\N	\N	\N
fea95f12-19b0-4156-86e2-a5e97a857bf8	40517b71-5e62-182e-73b5-d4070e20a3c2	cRV7QEsGNYoOLg09nA3N6aFtWcyt98L6aAoS8HaTQb4=	2026-08-17 15:40:49.664168+05:30	2026-08-10 16:22:07.080485+05:30	\N	2026-08-10 15:40:49.664859+05:30	2026-08-10 16:22:07.080694+05:30	\N	\N	\N
507790cb-68da-4c77-a195-ff68fb7614d6	40517b71-5e62-182e-73b5-d4070e20a3c2	zqg6xxQ/BtP0V6WbKlcWxJ8OkF5MKCnIsFBo0sAkFGc=	2026-08-17 16:22:07.080635+05:30	2026-08-10 16:23:24.422081+05:30	\N	2026-08-10 16:22:07.080694+05:30	2026-08-10 16:23:24.42247+05:30	\N	\N	\N
46497668-cd7a-4ba9-8656-dd12a2ddbf05	40517b71-5e62-182e-73b5-d4070e20a3c2	w3RwzLZ27rUrsxNW8tCdpRlvasrI7rZiKBU4RJeqOAg=	2026-08-17 16:23:24.422351+05:30	2026-08-10 16:28:19.491738+05:30	\N	2026-08-10 16:23:24.42247+05:30	2026-08-10 16:28:19.492034+05:30	\N	\N	\N
3c3ab08f-76bb-4f03-a36d-a983d55e33b3	40517b71-5e62-182e-73b5-d4070e20a3c2	IrM6RAGrrhet0tQqDqYo57a6+jeFMs4kjXaPBKcw/dg=	2026-08-17 16:28:19.491918+05:30	2026-08-10 16:28:47.002191+05:30	\N	2026-08-10 16:28:19.492034+05:30	2026-08-10 16:28:47.002539+05:30	\N	\N	\N
ec07c075-5e83-4ad9-a352-354c80aa6dc9	40517b71-5e62-182e-73b5-d4070e20a3c2	LPVEE1kvXwprAd4tTOlvex0ytJ53hPmuQEvKW1h9PHI=	2026-08-17 16:28:47.002464+05:30	2026-08-10 17:09:58.213898+05:30	\N	2026-08-10 16:28:47.002539+05:30	2026-08-10 17:09:58.214418+05:30	\N	\N	\N
bfc9eca1-568a-4a87-ac19-b232e7f61c0e	40517b71-5e62-182e-73b5-d4070e20a3c2	rWJgZffOX1T77ALIaNqLhmH5QgfiWBTKyMyNoRic/4U=	2026-08-17 17:09:58.214248+05:30	2026-08-10 17:29:08.388103+05:30	\N	2026-08-10 17:09:58.214418+05:30	2026-08-10 17:29:08.38811+05:30	\N	\N	\N
f7ca88c9-a73a-49e7-9197-4a3a03a013e7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	IOCuK6tbiBsJPtt/7+sBKfhxW90/iedwRlNkTAMxMmQ=	2026-08-17 17:55:59.548956+05:30	2026-08-10 17:56:09.50904+05:30	\N	2026-08-10 17:55:59.564856+05:30	2026-08-10 17:56:09.510721+05:30	\N	\N	\N
82d54e99-05ae-4fc9-95d0-1123053af68c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Buz0rwSXum1sVFiS9/hO7X3FUzZLfcs0ZGjs4tYDna8=	2026-08-17 17:56:09.510424+05:30	2026-08-10 17:56:33.784739+05:30	\N	2026-08-10 17:56:09.510721+05:30	2026-08-10 17:56:33.786047+05:30	\N	\N	\N
2f42eb84-1298-4d3e-89e7-f2f486c52a3e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YOg3AlTENv3uX62MzJpiwE72y2VQ8bdH2y58VT1Cc2Y=	2026-08-17 17:56:33.785638+05:30	2026-08-10 18:06:15.977761+05:30	\N	2026-08-10 17:56:33.786047+05:30	2026-08-10 18:06:15.978128+05:30	\N	\N	\N
95984435-9500-46af-8996-8d36929fcbd7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ykqsUxTFM5EJsiTli/P9sS+xruFD50G+DCc7d2V+W4M=	2026-08-17 18:06:15.978012+05:30	2026-08-10 18:06:28.515221+05:30	\N	2026-08-10 18:06:15.978128+05:30	2026-08-10 18:06:28.515713+05:30	\N	\N	\N
74549e44-8926-422c-9d70-564d73840ab7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	i5uxCFNp9YOUBMKVRBV2CeeFd2NzfAz3RuHoQGnP9PI=	2026-08-17 18:06:28.515543+05:30	2026-08-10 18:06:44.168341+05:30	\N	2026-08-10 18:06:28.515713+05:30	2026-08-10 18:06:44.168357+05:30	\N	\N	\N
55407794-2c87-408c-859b-a8362a831283	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yJCbXNuFhIlHOpP6mNH8hdcQA6VfgnQjZccus4bjzPU=	2026-08-17 18:07:40.918855+05:30	2026-08-10 18:10:13.599342+05:30	\N	2026-08-10 18:07:40.919058+05:30	2026-08-10 18:10:13.642921+05:30	\N	\N	\N
95b9c822-4044-452c-beff-95a109f3586b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Aifxpg+jxVTmWSRnGMOzUQzTi9LIRRw059OC9FYkFGc=	2026-08-17 18:07:18.377131+05:30	2026-08-10 18:10:39.046037+05:30	\N	2026-08-10 18:07:18.377329+05:30	2026-08-10 18:10:39.046061+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3e1b3105-a99a-4ec7-bc5a-c09d0cd28cb7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	l4EWf6mv9VSX3PbS+26lbxgx+W8Euq3ZjBUuiAji4Xs=	2026-08-17 18:10:13.627115+05:30	2026-08-10 18:10:51.417653+05:30	\N	2026-08-10 18:10:13.642921+05:30	2026-08-10 18:10:51.418091+05:30	\N	\N	\N
dcc22c6c-aa0c-47d6-a53c-1ad2265ac29e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OQ8Hmf5pjBsHjYnmjnV5dzMOcUHrgWtfm2pmWLGbYus=	2026-08-17 18:10:51.417952+05:30	2026-08-10 18:12:13.014327+05:30	\N	2026-08-10 18:10:51.418091+05:30	2026-08-10 18:12:13.014344+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3e01abcf-2eb8-4baf-8d75-b1712fc08532	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	1TZtiaPUP5w/rNC72tXTn/C615Vj30WyzPsddGn6+8E=	2026-08-17 17:56:18.897728+05:30	2026-08-10 18:12:22.867337+05:30	\N	2026-08-10 17:56:18.897894+05:30	2026-08-10 18:12:22.867619+05:30	\N	\N	\N
d426da8c-c314-4786-8474-e61e98a90c50	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	G41gT95TyAt0AFfMKySXN16b/mKF93whoLw39fBQF1w=	2026-08-17 18:12:22.867499+05:30	2026-08-10 18:13:45.869687+05:30	\N	2026-08-10 18:12:22.867619+05:30	2026-08-10 18:13:45.869986+05:30	\N	\N	\N
17950392-5d3d-42d6-a5b1-73dfadd8770d	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	L9VXSzIfbYouNr+gkdq+egIlnJz3jtJd/gKDIT1T9KY=	2026-08-17 18:13:45.869871+05:30	2026-08-10 18:14:06.503821+05:30	\N	2026-08-10 18:13:45.869986+05:30	2026-08-10 18:14:06.504074+05:30	\N	\N	\N
2bb5d9d4-7169-4e51-8e77-393245174c71	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	gZFXJ7CwJcZek+w5PJM6a/q3qRespzvRv4qOoZqQPiw=	2026-08-17 18:14:06.503981+05:30	2026-08-10 18:14:16.677465+05:30	\N	2026-08-10 18:14:06.504074+05:30	2026-08-10 18:14:16.677811+05:30	\N	\N	\N
538cc965-cbbb-437a-99aa-e6655e3deaf3	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	11JiAKsLOgW/iTdi+N+pN0cjfFzBKbXsEmbqBMg8xmw=	2026-08-17 18:14:16.677678+05:30	2026-08-10 18:14:27.547311+05:30	\N	2026-08-10 18:14:16.677811+05:30	2026-08-10 18:14:27.54768+05:30	\N	\N	\N
62c58661-8f3a-4b93-ac6f-6b1a84f4c204	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	2QSw0wue5g+dem7HoH1cdPIOUMgIbVzyhDLSYouYF0I=	2026-08-17 18:22:31.080366+05:30	2026-08-10 18:22:51.692282+05:30	\N	2026-08-10 18:22:31.080473+05:30	2026-08-10 18:22:51.692293+05:30	\N	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	\N
1f74a1a0-fdfe-4641-8f4c-9379e1082960	730809c0-fc01-a664-03ca-28e0e32d0393	R7mQqmO+q7A+48l6Xk37pevgp3BrQdrwoicF+KYGs0E=	2026-08-17 18:23:37.088122+05:30	2026-08-10 18:25:36.686186+05:30	\N	2026-08-10 18:23:37.088258+05:30	2026-08-10 18:25:36.686196+05:30	\N	730809c0-fc01-a664-03ca-28e0e32d0393	\N
deac0501-ccf1-4fdf-ac50-382c52c03b83	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	nvNFJuw+dV7y+zLO9aRbMVYpu8NgmV3qxCMPuR8SzWM=	2026-08-17 18:14:27.54749+05:30	2026-08-10 18:26:06.723663+05:30	\N	2026-08-10 18:14:27.54768+05:30	2026-08-10 18:26:06.723969+05:30	\N	\N	\N
8f326fea-3493-447f-a716-e2a7607347dc	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	snjmrBqzmOO5n+5WDjy5WOlI2zJo1oe2J1mKf+Ye07I=	2026-08-17 18:26:06.723838+05:30	2026-08-10 18:27:01.370485+05:30	\N	2026-08-10 18:26:06.723969+05:30	2026-08-10 18:27:01.370494+05:30	\N	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	\N
b096b852-8f35-4d16-8c1e-89156e6c0876	65e2ffa3-6073-780a-b849-4d9604c7251c	pA0YwxXyEFEG34nqpz1dq01gfdMmfVO4q8OOoZT8cHs=	2026-08-17 18:27:13.731204+05:30	2026-08-11 11:35:30.64142+05:30	\N	2026-08-10 18:27:13.731317+05:30	2026-08-11 11:35:30.721314+05:30	\N	\N	\N
fd4798e9-ed21-4e3f-8eb2-d99dc6200b27	65e2ffa3-6073-780a-b849-4d9604c7251c	0ugqpW6PNRWWoqywo99wWqUpgEKWAV14RpvNZRRXubU=	2026-08-18 11:35:30.704827+05:30	\N	\N	2026-08-11 11:35:30.721314+05:30	\N	\N	\N	\N
e3284e11-d8cc-4402-997b-2279345f8d17	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rMhCYG6wkXnakWlhhHZhVTVgz4iSsneSxTg61ejpcbU=	2026-08-18 11:35:50.572528+05:30	2026-08-11 11:41:04.569162+05:30	\N	2026-08-11 11:35:50.573481+05:30	2026-08-11 11:41:04.569176+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
147b6846-2d44-4692-b93a-598731a444f8	40517b71-5e62-182e-73b5-d4070e20a3c2	/JfWmgIwv2g/opVxoxUkmITLjxw8PLy9xDL9zVtFAh0=	2026-08-18 11:41:23.11593+05:30	2026-08-11 11:42:25.929146+05:30	\N	2026-08-11 11:41:23.116095+05:30	2026-08-11 11:42:25.929159+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
5e5603b9-2905-4ea2-bb3a-67dfc353360a	40517b71-5e62-182e-73b5-d4070e20a3c2	STzf/tzgx8XfYWdnlC/AcoD9GQOxYvPs6RkJ/ot/Gx0=	2026-08-18 11:42:39.656234+05:30	2026-08-11 11:50:18.918338+05:30	\N	2026-08-11 11:42:39.656315+05:30	2026-08-11 11:50:18.918351+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
f94c8d2c-97fb-4b22-adbc-f0a01c05dd9b	9f6f34df-dc47-f198-f3f6-e577aab1cbca	PUyL37m2dvLw8Znak16ke++qxLmRI+9xC9hAExrcda8=	2026-08-18 11:50:37.415519+05:30	\N	\N	2026-08-11 11:50:37.415637+05:30	\N	\N	\N	\N
f700bccb-1f29-4c98-a32a-ce86f48db7f6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+bPdl/qnoEBvAuMzd8fv83yIcMltPatd6trYBFpKqJo=	2026-08-18 12:31:05.57033+05:30	2026-08-11 13:44:25.01582+05:30	\N	2026-08-11 12:31:05.570476+05:30	2026-08-11 13:44:25.016092+05:30	\N	\N	\N
0c0841e5-7322-44ed-972f-eb3e79a733a5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	pMs2fU7tGnq1EX+KhF1Uy8l4sXG26+8P8RWzpamPOdM=	2026-08-18 13:44:25.016016+05:30	2026-08-11 15:00:23.191087+05:30	\N	2026-08-11 13:44:25.016092+05:30	2026-08-11 15:00:23.1911+05:30	\N	\N	\N
c9e08b83-0c49-41df-b890-6fb679853b3a	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	Ji4S34o7ozfQFr+pMGS0nYCOHAWC1jbMD8Y0xiu0F64=	2026-08-18 15:57:05.188485+05:30	2026-08-11 15:57:32.604724+05:30	\N	2026-08-11 15:57:05.188878+05:30	2026-08-11 15:57:32.614709+05:30	\N	\N	\N
3ea9046e-ba04-4e0d-8182-c91e7a3680f4	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	VEDg75Sgh40XSfbEWs4rXC73i0kgB27yOYWllxDtBxQ=	2026-08-18 15:57:32.614451+05:30	2026-08-11 15:57:44.435796+05:30	\N	2026-08-11 15:57:32.614709+05:30	2026-08-11 15:57:44.436212+05:30	\N	\N	\N
bd89f750-cfb5-40dc-ba9a-1ea96f0eafe9	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	3tQS29kvMe3IiY1quXs/ncbq4hd5XYeKjnLTLmAdTQE=	2026-08-18 15:57:44.436067+05:30	2026-08-11 16:00:32.96644+05:30	\N	2026-08-11 15:57:44.436212+05:30	2026-08-11 16:00:32.96645+05:30	\N	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	\N
99a1623f-1c63-4887-b389-bd519566895e	b1d3f51c-b209-d352-4b52-3f4008801ab3	dK9y+/y9ZbiYNOYZ4FFR3De9JRbfnGOuqRlvDhYjsxE=	2026-08-18 16:03:16.307727+05:30	2026-08-11 16:03:24.774577+05:30	\N	2026-08-11 16:03:16.307884+05:30	2026-08-11 16:03:24.77497+05:30	\N	\N	\N
572a39a1-abb0-4ddd-af9a-413b4a8e9eb7	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	oOOMXgxtTvgNwGjPnnCVChKpGlV2lYpEB1I/5bdCJaM=	2026-08-18 16:03:39.029844+05:30	2026-08-11 16:53:19.803613+05:30	\N	2026-08-11 16:03:39.029981+05:30	2026-08-11 16:53:19.804121+05:30	\N	\N	\N
8f006f48-7e26-427b-b714-747fb1695392	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	EsTA17ofd9yZOE4SBgrvT0ft7exxMgltuNyGW724zU0=	2026-08-18 16:00:51.397274+05:30	2026-08-11 17:11:38.971739+05:30	\N	2026-08-11 16:00:51.397514+05:30	2026-08-11 17:11:38.971959+05:30	\N	\N	\N
b02f44de-0d79-4bbf-91d2-4c31485afc3b	111775f6-5d80-5333-478e-68e2fda584fa	87o342U9a5LnZjp3poQAYlcd82jVPtF+LxvWJdpUjG0=	2026-08-18 16:55:30.012822+05:30	2026-08-11 17:11:39.087682+05:30	\N	2026-08-11 16:55:30.013181+05:30	2026-08-11 17:11:39.08791+05:30	\N	\N	\N
c787cb76-ae69-4d20-adc3-dfe5cecba19e	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	G+f3x+OK4xykD270KMKG9/b/1nZhBnnNywf9zEI8J4M=	2026-08-18 17:11:38.971892+05:30	2026-08-11 17:13:23.319332+05:30	\N	2026-08-11 17:11:38.971959+05:30	2026-08-11 17:13:23.319359+05:30	\N	\N	\N
9ce4ea6e-9e21-4e2f-a8af-1701afd087ec	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	6VLhML3Z36e3pSB8PJ4JEN1SviWY2uCYIu0b2D/kOlQ=	2026-08-18 16:53:19.80399+05:30	2026-08-11 17:13:34.664599+05:30	\N	2026-08-11 16:53:19.804121+05:30	2026-08-11 17:13:34.664914+05:30	\N	\N	\N
4bc2da8c-9093-4e63-8772-087232faa64d	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	ucvF22nXhqyhiWcYmTpEMBZV/zs5rOZFmc0qWBWySt8=	2026-08-18 17:13:34.66482+05:30	2026-08-11 17:14:59.722956+05:30	\N	2026-08-11 17:13:34.664914+05:30	2026-08-11 17:14:59.723122+05:30	\N	\N	\N
924cdece-0ed0-4470-ad32-46d1e82c9c52	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	lxsjb82zLKcs07f34Fagg0v/C3BKutRiGgLYcssD3ss=	2026-08-18 17:14:59.72307+05:30	2026-08-11 17:17:47.765396+05:30	\N	2026-08-11 17:14:59.723122+05:30	2026-08-11 17:17:47.765403+05:30	\N	\N	\N
9a6dcd0a-6171-4af4-a7c0-95a30c6a704c	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	Be2a2zUD3L+IvXmAqRcttxvba0+bv6b1vCPEG8E+NoM=	2026-08-18 17:17:59.424036+05:30	2026-08-11 17:18:05.564808+05:30	\N	2026-08-11 17:17:59.424221+05:30	2026-08-11 17:18:05.565069+05:30	\N	\N	\N
cf9e1d5d-4d24-40c0-82fd-5c1b74574001	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	wdcWNhc9Llqr+RYmvUMuBcUkIJ6hkBHsJOsajhmWWus=	2026-08-18 17:18:05.564905+05:30	2026-08-11 17:18:31.185805+05:30	\N	2026-08-11 17:18:05.565069+05:30	2026-08-11 17:18:31.186261+05:30	\N	\N	\N
165d8919-08ec-42d4-8a69-fb6f9d6e771c	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	3xtZO3MouS5BFAyzghthdQHodTkxOJA6m20DEzVdxy8=	2026-08-18 17:18:31.185997+05:30	2026-08-11 17:19:23.361718+05:30	\N	2026-08-11 17:18:31.186261+05:30	2026-08-11 17:19:23.361726+05:30	\N	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	\N
da7ab2a7-75f7-43c0-b903-6680f7bcd35d	111775f6-5d80-5333-478e-68e2fda584fa	GTYEc+oPSuYRA2n4f5DY5/gpfM7vdBbIuViRhh43Dzg=	2026-08-18 17:11:39.087825+05:30	2026-08-11 17:21:19.004087+05:30	\N	2026-08-11 17:11:39.08791+05:30	2026-08-11 17:21:19.004097+05:30	\N	\N	\N
d7de05e4-4f65-488f-a528-c6e1e9a6856c	b1d3f51c-b209-d352-4b52-3f4008801ab3	JxI70Gj5lNPG64S2FnWHYClekmyauC7GL5tIPxMTN9s=	2026-08-18 16:03:24.77486+05:30	2026-08-11 17:21:44.289708+05:30	\N	2026-08-11 16:03:24.77497+05:30	2026-08-11 17:21:44.289974+05:30	\N	\N	\N
c5e7cafc-0d87-4956-bac0-165a4e532cda	b1d3f51c-b209-d352-4b52-3f4008801ab3	FDmGv/9IyH68oin1NOyJadg7V75KJwDczTpoLx2J8mk=	2026-08-18 17:21:44.289908+05:30	\N	\N	2026-08-11 17:21:44.289974+05:30	\N	\N	\N	\N
96fd8acc-e2b0-40c1-a78d-7dcb1685ca1a	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	GqgoTZ1aXwgnfCYrIia0qEx07Y7ziGE60N+3a4mEz/c=	2026-08-18 18:01:49.389586+05:30	2026-08-11 18:04:26.894525+05:30	\N	2026-08-11 18:01:49.38968+05:30	2026-08-11 18:04:26.894531+05:30	\N	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	\N
983dd366-310c-4fdc-ab23-fcda702b3dad	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	xHegPS+3q3mQx3XvMgjiWxdNzarkhqzLh1LAnjtbtvI=	2026-08-18 17:19:34.53917+05:30	2026-08-11 18:04:37.941203+05:30	\N	2026-08-11 17:19:34.539306+05:30	2026-08-11 18:04:37.941421+05:30	\N	\N	\N
8d93c762-0e11-49a9-936f-7893882a4637	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	KuBjtcdeRNDCoGIqIBieaIIKDTlSBjpw6Ty5wpN6YKs=	2026-08-17 17:56:34.151451+05:30	2026-08-17 17:28:01.492975+05:30	\N	2026-08-10 17:56:34.151693+05:30	2026-08-17 17:28:01.493149+05:30	\N	\N	\N
eef0d74d-6908-4074-aba8-614c5a01dc62	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BEhsd2lyE+wFuMU0mF4h45Z9GEcguzSTvwVs5Kc/Vxw=	2026-08-18 18:15:48.772946+05:30	2026-08-11 18:18:29.349777+05:30	\N	2026-08-11 18:15:48.80745+05:30	2026-08-11 18:18:29.394396+05:30	\N	\N	\N
c046d295-c803-46e5-bbe5-b010f00ff428	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ahY1gGdMA5+0RpvbMasA0eMtVdRH0hd69FNy0wnBdKY=	2026-08-18 18:18:29.37719+05:30	2026-08-11 18:18:29.786914+05:30	\N	2026-08-11 18:18:29.394396+05:30	2026-08-11 18:18:29.788864+05:30	\N	\N	\N
d39cf8f5-c050-4e7e-964a-6a081928d8fd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yOQj3s5OTbNFJ2NYzpaCDNX8B7r7exhSuUYvzPo16+Y=	2026-08-18 18:18:29.787541+05:30	2026-08-11 18:18:30.03862+05:30	\N	2026-08-11 18:18:29.788864+05:30	2026-08-11 18:18:30.038642+05:30	\N	\N	\N
9aca32e6-53d0-477d-8819-7339b9e272e8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	I1wJhuDa8+dNSN+pnb/kSPcjSRDGZ7/9/KlFK4X92p4=	2026-08-18 18:18:38.912859+05:30	2026-08-11 18:20:52.900078+05:30	\N	2026-08-11 18:18:38.913082+05:30	2026-08-11 18:20:52.900393+05:30	\N	\N	\N
d65e42dd-3fe5-43d4-9500-7b1eee373fdb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	q00UBbqZHn+ZzKVkATx3eXeGDNdjyOw8KxuzkfmZSso=	2026-08-18 18:20:52.900281+05:30	2026-08-11 18:21:00.781172+05:30	\N	2026-08-11 18:20:52.900393+05:30	2026-08-11 18:21:00.781462+05:30	\N	\N	\N
e841a434-7bcc-446d-9f60-35b211aab97b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	p8tYRR9j8Bt/qTCIeqnhc4irSQqX59OVStsMxJGpMk4=	2026-08-18 18:21:00.781373+05:30	2026-08-11 18:21:21.157832+05:30	\N	2026-08-11 18:21:00.781462+05:30	2026-08-11 18:21:21.157845+05:30	\N	\N	\N
ee85465a-09e7-4a86-929f-e380d7d7f838	40517b71-5e62-182e-73b5-d4070e20a3c2	n6/adEcWbcKNw9BNfjRCVNfHWPxuIrIxgALCFtSE+Yk=	2026-08-18 18:22:22.274805+05:30	2026-08-11 18:22:28.757613+05:30	\N	2026-08-11 18:22:22.308252+05:30	2026-08-11 18:22:28.759431+05:30	\N	\N	\N
e65679b1-85e6-4dba-91d7-ad3e0556f019	40517b71-5e62-182e-73b5-d4070e20a3c2	yyqxge0HiUE8Lk+lpQfymCecWMWd20wK9Ezy2ZeNMSQ=	2026-08-18 18:22:28.758325+05:30	2026-08-11 18:22:35.0217+05:30	\N	2026-08-11 18:22:28.759431+05:30	2026-08-11 18:22:35.022058+05:30	\N	\N	\N
bf3819d2-6e5e-47fe-b1be-8f83a3517c18	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2tqet8uwI3ySmu/16faxp79ntGrOti8+tTSw6GEYLWo=	2026-08-18 18:23:59.584076+05:30	2026-08-11 18:23:59.989882+05:30	\N	2026-08-11 18:23:59.623672+05:30	2026-08-11 18:23:59.991661+05:30	\N	\N	\N
81a82895-939f-4ea2-af3b-6d25b7ab782e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	avZtPh8eRsIbnrtmLgu760NXOUukdY0mqs/rDLXwi7g=	2026-08-18 18:23:59.990509+05:30	2026-08-11 18:24:00.186211+05:30	\N	2026-08-11 18:23:59.991661+05:30	2026-08-11 18:24:00.186226+05:30	\N	\N	\N
5fbcd7dd-bd6f-4429-9a70-3a06c5c89616	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Xd+kk4fwEvvfCr6A7uie7lM7KVMFhlnbRNfDm2sK/NM=	2026-08-18 18:26:51.712617+05:30	2026-08-11 18:31:22.002398+05:30	\N	2026-08-11 18:26:51.712802+05:30	2026-08-11 18:31:22.002792+05:30	\N	\N	\N
b89078a4-af6f-4183-afec-da3315ce2365	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	FArabMT0Juf2QjQXelZ2aJRe7i3nTLV5l29ihA369Ms=	2026-08-18 18:04:37.941357+05:30	2026-08-13 12:12:59.884887+05:30	\N	2026-08-11 18:04:37.941421+05:30	2026-08-13 12:12:59.885103+05:30	\N	\N	\N
14f30aa6-6cbb-458e-a807-9837759e35c1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	JsEAOohf7rR5/wRTgw0WwlxvjsZmQ9DOQY93RhD84B4=	2026-08-18 18:32:05.371856+05:30	2026-08-11 18:32:13.633783+05:30	\N	2026-08-11 18:32:05.389302+05:30	2026-08-11 18:32:13.635198+05:30	\N	\N	\N
5a853bd3-d32f-4d45-b41b-b251fef0e530	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	py8vaoeTqlex1vcRH84vffhqSKCi7m9jGqDvO7tvypU=	2026-08-18 18:32:13.634129+05:30	2026-08-11 18:32:20.622174+05:30	\N	2026-08-11 18:32:13.635198+05:30	2026-08-11 18:32:20.622475+05:30	\N	\N	\N
d409bc1c-9c7b-47c8-a589-3348d0ae4b47	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	KWIBrI07Jvy+/CXkvgLGHsKixf6t7rGHtUxHztd2D84=	2026-08-18 18:32:30.241233+05:30	2026-08-11 18:32:36.427469+05:30	\N	2026-08-11 18:32:30.241418+05:30	2026-08-11 18:32:36.427699+05:30	\N	\N	\N
e07a47eb-2c9d-4e53-b16d-d20a1d7f8e79	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	wWFUQoItsPrUrFPdlgvwMjqjuKERJx98uf7caAIKGD0=	2026-08-18 18:32:36.427614+05:30	2026-08-11 18:33:47.634423+05:30	\N	2026-08-11 18:32:36.427699+05:30	2026-08-11 18:33:47.634743+05:30	\N	\N	\N
ec66f234-af67-44f6-a03e-1dd539e099bc	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	0WEnglKJsrTQDrdBbABcTdN3dH+EPlbG6hMdNHg6SRw=	2026-08-18 18:33:47.634616+05:30	2026-08-11 18:34:04.446295+05:30	\N	2026-08-11 18:33:47.634743+05:30	2026-08-11 18:34:04.446305+05:30	\N	\N	\N
0f3e9fc9-6076-44b7-ae92-e33f2982a89e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	u+qP6jvjBayZvpsJCpH2b1y+59qnc0yhat1/5FZBLrg=	2026-08-18 18:32:20.622379+05:30	2026-08-11 18:34:19.1411+05:30	\N	2026-08-11 18:32:20.622475+05:30	2026-08-11 18:34:19.141475+05:30	\N	\N	\N
45b021dd-3fef-4599-8f12-e79dc7fc6852	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8EDj0kFTNQJN86o1ML2pHENzuCX5wwLpgx88wTeuJfQ=	2026-08-18 18:31:22.002662+05:30	2026-08-11 18:35:01.301621+05:30	\N	2026-08-11 18:31:22.002792+05:30	2026-08-11 18:35:01.301634+05:30	\N	\N	\N
c1dff3f6-a6df-4065-96c4-79652100a0cd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	g3LgJ8AxsPOFjsXLsfJSYoEtJZHRpldUsNoQxEeavrI=	2026-08-18 18:34:19.141319+05:30	2026-08-11 18:41:10.081954+05:30	\N	2026-08-11 18:34:19.141475+05:30	2026-08-11 18:41:10.081963+05:30	\N	\N	\N
8150fbac-cf85-4b73-8c49-b5b47eb2379f	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	vVRCOOvGA0/XkC5a7xZ/BoKgrCf9fgnSlPbalkpcGHc=	2026-08-18 18:35:09.760774+05:30	2026-08-11 18:41:28.907897+05:30	\N	2026-08-11 18:35:09.76092+05:30	2026-08-11 18:41:28.908163+05:30	\N	\N	\N
df8b3588-6c8d-41a7-8d62-3b11b42cba24	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	8ZNcbnKDMvhOvt6QtopflUIgEP9nlUlxyW4G14FhFFA=	2026-08-18 18:41:28.908063+05:30	2026-08-11 18:41:58.230842+05:30	\N	2026-08-11 18:41:28.908163+05:30	2026-08-11 18:41:58.231223+05:30	\N	\N	\N
604388d6-9028-472b-bc44-2ffd9ac9cabc	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	Ggq3mUaELW0ps1AumLvSRley3oD3+cXXDmTEI9VVWIg=	2026-08-18 18:41:58.231041+05:30	2026-08-11 18:42:26.64585+05:30	\N	2026-08-11 18:41:58.231223+05:30	2026-08-11 18:42:26.646069+05:30	\N	\N	\N
21465494-1807-4e5f-aa48-5fe70f34cf09	40517b71-5e62-182e-73b5-d4070e20a3c2	GI9Nb9YDJuMCNhVpbRs40YtF+XwMA6Ltn6FEXBxnyos=	2026-08-18 18:22:35.02195+05:30	2026-08-13 12:12:53.627786+05:30	\N	2026-08-11 18:22:35.022058+05:30	2026-08-13 12:12:53.695888+05:30	\N	\N	\N
9fec49b1-0c6d-4d8a-abe2-e5da40002278	40517b71-5e62-182e-73b5-d4070e20a3c2	D1tWd9ZOVZyKSQaoY81j/MnD4jrJ5Q/Ae/bOKmFfpPs=	2026-08-20 12:12:53.681649+05:30	2026-08-13 12:12:59.444556+05:30	\N	2026-08-13 12:12:53.695888+05:30	2026-08-13 12:12:59.445702+05:30	\N	\N	\N
fa91c410-f4f1-4e79-b313-1ae932e4b699	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	3NQTJ3uMiPJf+ULwHx6jjQusi1Nnj4KUHILZq9ZsF10=	2026-08-18 18:42:26.645982+05:30	2026-08-13 12:19:34.874233+05:30	\N	2026-08-11 18:42:26.646069+05:30	2026-08-13 12:19:34.874481+05:30	\N	\N	\N
6e181863-d633-4654-9c64-f84c023dff26	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	eqXcLAVeLkQsqyv41ZMxiRZvdjrua3MGbxKJRzi+hCY=	2026-08-20 12:19:34.874355+05:30	2026-08-13 12:19:41.688683+05:30	\N	2026-08-13 12:19:34.874481+05:30	2026-08-13 12:19:41.688693+05:30	\N	\N	\N
19202353-d846-4108-be64-ffdd693df49a	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	PF/rev6wFh8IXuiWNclMugdh0RWqi3yod46wDzIpeTY=	2026-08-20 12:12:59.885036+05:30	2026-08-13 12:19:53.45002+05:30	\N	2026-08-13 12:12:59.885103+05:30	2026-08-13 12:19:53.450239+05:30	\N	\N	\N
bcbcfa50-89a0-49ed-807a-c73541137118	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	LGSMsMDwiG+kJ8Ph/u+Ul7mXhZhmw25V2vk/jAZ/iPE=	2026-08-20 12:19:53.45017+05:30	2026-08-13 12:20:33.019994+05:30	\N	2026-08-13 12:19:53.450239+05:30	2026-08-13 12:20:33.020416+05:30	\N	\N	\N
81e2cb3c-311d-48fd-80f2-f14b3b21ce73	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	T6fwkFYmhQWTuHGUZ82BN+MD6zLf9ey3wNykdn7mtxs=	2026-08-20 12:20:33.020169+05:30	2026-08-13 12:21:42.54799+05:30	\N	2026-08-13 12:20:33.020416+05:30	2026-08-13 12:21:42.548331+05:30	\N	\N	\N
5d399d1c-e5a4-4229-9073-1bf7907f8178	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	rOsa+YqZjV0c/R5tMOSQLiODDNxuJ7KfMAm1bVPHyIU=	2026-08-20 12:21:42.548173+05:30	2026-08-13 12:22:09.916507+05:30	\N	2026-08-13 12:21:42.548331+05:30	2026-08-13 12:22:09.917424+05:30	\N	\N	\N
b9402ef5-af3c-42a7-afaa-93ef94acddd9	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	gUhmUExyOJioQTEd/GKiie/Fe2KIsQfbW4aPVgWwJ9o=	2026-08-20 12:22:09.917263+05:30	2026-08-13 12:22:30.562368+05:30	\N	2026-08-13 12:22:09.917424+05:30	2026-08-13 12:22:30.562573+05:30	\N	\N	\N
1f32c01b-5e82-4cd9-a9e6-28f7762be99a	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	yGMpoAE03DLXFAIbpVW2MWdejL6evuOby7zLM8wc41k=	2026-08-20 12:22:30.562508+05:30	2026-08-13 12:24:16.621905+05:30	\N	2026-08-13 12:22:30.562573+05:30	2026-08-13 12:24:16.622149+05:30	\N	\N	\N
56567409-a9e9-4d27-bf98-158a384e10f1	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	LWD4fRWQQcneibFG5ZsiKyIB0px7lZCQb6a8Yor46Ow=	2026-08-20 12:24:16.622069+05:30	2026-08-13 12:24:49.248802+05:30	\N	2026-08-13 12:24:16.622149+05:30	2026-08-13 12:24:49.249024+05:30	\N	\N	\N
2845a521-ca8d-4ca5-a072-069e1c36fe21	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	GAB8oIgfAPPwU8EU94wLJGQbaMXP00VB01LhGKvg7cs=	2026-08-20 12:24:49.248943+05:30	2026-08-13 12:25:36.507829+05:30	\N	2026-08-13 12:24:49.249024+05:30	2026-08-13 12:25:36.508019+05:30	\N	\N	\N
cd654925-d826-489f-bb09-80553e418b84	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	ErvXJY/HnF3+EzNj9jE16IrtzcmSIa7NdQS/TqkgCvs=	2026-08-20 12:25:36.507939+05:30	2026-08-13 12:26:59.754057+05:30	\N	2026-08-13 12:25:36.508019+05:30	2026-08-13 12:26:59.754247+05:30	\N	\N	\N
90eba991-3edd-44da-99b1-73ce68d314f8	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	ng0OQXKhdb0C7q5sCwNnvMcOmBcPbd3YR+9K4t6eYM0=	2026-08-20 12:26:59.75417+05:30	2026-08-13 12:27:15.328442+05:30	\N	2026-08-13 12:26:59.754247+05:30	2026-08-13 12:27:15.328691+05:30	\N	\N	\N
d23f6968-562c-4054-953a-1e479cf31a7a	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	vIRJ2ztRyZ+Ef+2ZYvwlLkwcHGJ0OmLQ4EarnNnDQJc=	2026-08-20 12:27:15.328577+05:30	2026-08-13 12:27:33.228483+05:30	\N	2026-08-13 12:27:15.328691+05:30	2026-08-13 12:27:33.228676+05:30	\N	\N	\N
8ac736f6-6692-40e0-8b1a-6669fa03bff2	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	w9uTNvwLreyxRCkIuJ+m63VyYxV0g2OQ4CZM+zMaDQw=	2026-08-20 12:27:33.228603+05:30	2026-08-13 12:27:37.513071+05:30	\N	2026-08-13 12:27:33.228676+05:30	2026-08-13 12:27:37.513333+05:30	\N	\N	\N
3a5bfd69-9473-4cd2-81ac-9b29ef249580	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	b2MCbLIrv7Nna+FbeHmQlGr9t5tc4oZys17MV3Qp1I8=	2026-08-20 12:27:37.513183+05:30	2026-08-13 12:27:48.935006+05:30	\N	2026-08-13 12:27:37.513333+05:30	2026-08-13 12:27:48.935211+05:30	\N	\N	\N
68505096-c60a-43ed-bba6-29bad4481a90	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	nvovklJyKCxJdXEnQl2MEJnI8AMzCNAVsMUna8z/Hvc=	2026-08-20 12:27:48.935148+05:30	2026-08-13 12:28:19.071984+05:30	\N	2026-08-13 12:27:48.935211+05:30	2026-08-13 12:28:19.072146+05:30	\N	\N	\N
d7955ada-7a5a-4a3f-83df-3fcd7ec4b303	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	7xP5ZZqweUuRtSThkqmkMUkCKJpA7c3lbmLHHA1HjRw=	2026-08-20 12:28:19.072086+05:30	2026-08-13 12:29:42.060085+05:30	\N	2026-08-13 12:28:19.072146+05:30	2026-08-13 12:29:42.06039+05:30	\N	\N	\N
76efbc71-6851-4fae-a3cc-c06efd72e586	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	9dAU3egDkmgl90IOa1AxLba0xqsaqSlJvMsF89eC2Qw=	2026-08-20 12:29:42.060268+05:30	2026-08-13 12:30:35.94114+05:30	\N	2026-08-13 12:29:42.06039+05:30	2026-08-13 12:30:35.941293+05:30	\N	\N	\N
36d5b106-4d7b-415d-b782-0fce961ddde5	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	LXoMV2uPFYlPaq27xKcpIAqqgyUUg//mq4Dyy8jSXOk=	2026-08-20 12:30:35.941234+05:30	2026-08-13 17:59:53.428393+05:30	\N	2026-08-13 12:30:35.941293+05:30	2026-08-13 17:59:53.429536+05:30	\N	\N	\N
2f8ad056-72c5-4a39-94fb-a64d5cecd49c	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	C+3dNnQg/KWsu4sRjZoff4rP4JmArALPcUfZt1QVHHg=	2026-08-20 17:59:53.428835+05:30	2026-08-13 18:01:38.278223+05:30	\N	2026-08-13 17:59:53.429536+05:30	2026-08-13 18:01:38.27851+05:30	\N	\N	\N
6037eae2-7c98-4e3d-ae93-a1a76a776f51	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	NbocCcjLMJOh3H2rrcl6xRTKYZ8KYjblKfS82GVLw3A=	2026-08-20 18:01:38.278398+05:30	2026-08-13 18:03:09.061083+05:30	\N	2026-08-13 18:01:38.27851+05:30	2026-08-13 18:03:09.061095+05:30	\N	\N	\N
fc4240f8-8f6d-4dcd-9466-6f241ae47918	a3a20ac4-43a2-de64-52d3-bfafce7c7053	UTRokwKgx9sxU8b/Y+WoHYVXYmv/aSfJwZfooTFplaU=	2026-08-24 10:52:42.610608+05:30	2026-08-17 10:54:06.759829+05:30	\N	2026-08-17 10:52:42.637874+05:30	2026-08-17 10:54:06.759976+05:30	\N	\N	\N
e204cd7f-cc49-4c2f-9a50-eaee98a0e1aa	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UBtyrWkm/E4zseHiNBuVfFlJdLiWTEPYW/fvBk1OBNE=	2026-08-20 17:50:45.469098+05:30	2026-08-17 10:54:20.523136+05:30	\N	2026-08-13 17:50:45.495953+05:30	2026-08-17 10:54:20.524012+05:30	\N	\N	\N
6eecd095-a865-4a79-b81d-149245ed4125	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PImKEZT8dUjBUVMdFvns45RxZweE9Xa1VUFi8AKaKlQ=	2026-08-24 10:54:20.523346+05:30	2026-08-17 11:21:25.883728+05:30	\N	2026-08-17 10:54:20.524012+05:30	2026-08-17 11:21:25.884064+05:30	\N	\N	\N
54f43441-e0a3-496a-8871-409f17a30c5c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zqDRLXRu4yPMhW9wDR41AOp0hqkvDqPKPivBq4Dhae0=	2026-08-24 11:21:25.883961+05:30	2026-08-17 12:17:28.635743+05:30	\N	2026-08-17 11:21:25.884064+05:30	2026-08-17 12:17:28.636165+05:30	\N	\N	\N
1a3d99e3-0a37-4480-b116-53d3d26e04d8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yjaVLRPofiPtSEnAUcLsI5RjgR61QHTSK5xmPbI5e90=	2026-08-24 12:17:28.636007+05:30	2026-08-17 12:29:09.653545+05:30	\N	2026-08-17 12:17:28.636165+05:30	2026-08-17 12:29:09.653556+05:30	\N	\N	\N
63c7702e-922a-443d-981b-4a3a12c88cea	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	SudgUSxnXFkf9zSggUepummvXLYdyIQ+WS910nC7wBg=	2026-08-18 18:18:39.580998+05:30	2026-08-17 12:29:19.628582+05:30	\N	2026-08-11 18:18:39.581198+05:30	2026-08-17 12:29:19.628877+05:30	\N	\N	\N
de6290bb-ba37-46d5-bc89-4b9480130942	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	Rdai1JHCxNMvkPKKZBQ+6cN1wqde85J0gNGJ5M0jhO4=	2026-08-24 12:29:19.628763+05:30	2026-08-17 12:37:15.328802+05:30	\N	2026-08-17 12:29:19.628877+05:30	2026-08-17 12:37:15.328814+05:30	\N	\N	\N
921486ca-d276-4219-bb87-cb6d11b32efc	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	wzE1aKfgm90Hs/k9mOPD4o6yAUkAj0Wa4VJfYZ8rhf0=	2026-08-24 12:37:38.217353+05:30	2026-08-17 12:39:25.083891+05:30	\N	2026-08-17 12:37:38.217455+05:30	2026-08-17 12:39:25.083899+05:30	\N	\N	\N
b1a35eb0-7a61-49d8-94fe-36d0511a35ee	a3a20ac4-43a2-de64-52d3-bfafce7c7053	PvCfJMJdUQpxVdwx8zePx/pV9knnI75cUHJOFXNURLU=	2026-08-24 12:39:47.332047+05:30	2026-08-17 13:21:15.997439+05:30	\N	2026-08-17 12:39:47.332161+05:30	2026-08-17 13:21:15.998807+05:30	\N	\N	\N
02af14ab-a19a-4ee4-a27b-56fe9188e6b7	a3a20ac4-43a2-de64-52d3-bfafce7c7053	M0Ubqre77QBlDThVAVWeLOSsQL89p5v4QdmC9MlZ6+k=	2026-08-24 13:21:15.998539+05:30	2026-08-17 15:10:55.498481+05:30	\N	2026-08-17 13:21:15.998807+05:30	2026-08-17 15:10:55.498903+05:30	\N	\N	\N
60a9b1bb-3ff0-402f-bbe3-a549289f43a8	a3a20ac4-43a2-de64-52d3-bfafce7c7053	MabqnJ4XLw0zmX2Er66mlRYgSa7msl9NVx1LBZF2ebo=	2026-08-24 15:10:55.498766+05:30	2026-08-17 15:42:20.1334+05:30	\N	2026-08-17 15:10:55.498903+05:30	2026-08-17 15:42:20.133678+05:30	\N	\N	\N
52767a42-ef50-4364-984e-e01860676254	a3a20ac4-43a2-de64-52d3-bfafce7c7053	fPqUmuoCBvd3lUc4GpumUSF1iBZo1nrp9x2n/VAWbcI=	2026-08-24 15:42:20.133563+05:30	2026-08-17 15:50:35.376761+05:30	\N	2026-08-17 15:42:20.133678+05:30	2026-08-17 15:50:35.37677+05:30	\N	\N	\N
f44ff799-3ffb-4918-82d5-3e7242b11098	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	aOO7hi/LWNVwWok2I8QlwWrxANx5eImCO/obTBtnssA=	2026-08-24 15:50:58.948965+05:30	2026-08-17 16:02:11.513403+05:30	\N	2026-08-17 15:50:58.949083+05:30	2026-08-17 16:02:11.513525+05:30	\N	\N	\N
dd261d82-f27b-4303-8137-fb1713bc42b7	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	mB+IhTFMaYwCVNofjXxFvWhGYQJax02vBY2KRmZhVow=	2026-08-24 16:06:38.877053+05:30	2026-08-17 16:06:58.673084+05:30	\N	2026-08-17 16:06:38.877303+05:30	2026-08-17 16:06:58.673327+05:30	\N	\N	\N
6376cdfa-3bc2-4436-a60a-44aa3548d245	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	4eQMiSECbUK9dKRfrEzRnpZyQg/KTxQbyS8Bmv2imcM=	2026-08-24 16:06:58.67325+05:30	2026-08-17 16:07:08.617225+05:30	\N	2026-08-17 16:06:58.673327+05:30	2026-08-17 16:07:08.617438+05:30	\N	\N	\N
657f545c-b91b-4eac-ba45-dcd1c8ccad03	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	JudICHrXj5EZAp9DPnBI/upJBrR7g1pxEEOkprK0b64=	2026-08-24 16:07:08.617367+05:30	2026-08-17 16:10:02.718396+05:30	\N	2026-08-17 16:07:08.617438+05:30	2026-08-17 16:10:02.718609+05:30	\N	\N	\N
dea987eb-9288-42c6-a828-93e543fcf2e4	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	G4nML43+vYY7qxAq7AOSPGHUzXXyEjGT0xnb8BswowU=	2026-08-24 16:10:02.718533+05:30	2026-08-17 16:13:58.160294+05:30	\N	2026-08-17 16:10:02.718609+05:30	2026-08-17 16:13:58.160299+05:30	\N	\N	\N
037383f0-56ee-43ae-b2da-0873ec06bec1	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	YlL4YdrYlVsHDsCRyt//69eOr2ZWvNc0ESw/5fW5rso=	2026-08-24 16:13:58.426417+05:30	2026-08-17 16:14:35.249483+05:30	\N	2026-08-17 16:13:58.426521+05:30	2026-08-17 16:14:35.249488+05:30	\N	\N	\N
953536f9-a53c-41b2-a5f3-1c0999729d44	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	z8zjfqFJA2LXTADt8GuQgV12EXM44rLGxVPAFn6C34Q=	2026-08-24 16:14:35.519103+05:30	2026-08-17 16:14:41.865458+05:30	\N	2026-08-17 16:14:35.51919+05:30	2026-08-17 16:14:41.865464+05:30	\N	\N	\N
ce5bb2ce-2807-49ea-8661-212b4f7bfb81	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	w/rLaypYBJe0jJa8sB+4jqVfqTpvZQPBbCk1c0IKwb8=	2026-08-24 16:14:42.131366+05:30	2026-08-17 16:15:22.020328+05:30	\N	2026-08-17 16:14:42.131447+05:30	2026-08-17 16:15:22.020337+05:30	\N	\N	\N
2933b13b-4d23-4978-b7d2-4d3ce93d8043	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	0+1te1vnJYUOR+Cc/SjE6O1DTa4A9owaqIUNIUtiNaI=	2026-08-24 16:15:22.285011+05:30	2026-08-17 16:15:25.836309+05:30	\N	2026-08-17 16:15:22.285092+05:30	2026-08-17 16:15:25.836316+05:30	\N	\N	\N
ceb14726-d082-4d50-bebc-94ffb6e5ab1d	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	AzKSCSbcNCZDIxsqsgIJH4nZRVllWv21wnmUQIwh1ag=	2026-08-24 16:15:26.093568+05:30	2026-08-17 16:15:45.474665+05:30	\N	2026-08-17 16:15:26.093648+05:30	2026-08-17 16:15:45.47467+05:30	\N	\N	\N
270a48c1-f719-425b-a0fe-6ab4b24af149	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	hX2IfTK1XoMsZqEhO4vFgpzv183eNDTu9FAP1CPDW/w=	2026-08-24 16:15:45.738668+05:30	2026-08-17 16:16:56.0843+05:30	\N	2026-08-17 16:15:45.738749+05:30	2026-08-17 16:16:56.084305+05:30	\N	\N	\N
4385c9a5-f575-430a-b8fd-4262ff665eb6	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	iYKqoknlklm7bBDW+2hZxllX/3td4xDaaGukn1cfQGc=	2026-08-24 16:16:56.345214+05:30	2026-08-17 16:17:12.731553+05:30	\N	2026-08-17 16:16:56.345307+05:30	2026-08-17 16:17:12.731564+05:30	\N	\N	\N
6c2ee8ed-0bfd-4ad0-9e73-4ecd10827378	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	X+82mPLefzUjxOJy5KNsmoURTZpXnbbgUC5kg3jTeTk=	2026-08-24 16:17:12.993164+05:30	2026-08-17 16:17:16.6157+05:30	\N	2026-08-17 16:17:12.993239+05:30	2026-08-17 16:17:16.615708+05:30	\N	\N	\N
4365074e-38ef-433d-8a2a-f0e8be6ec2ca	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	CV13va5nZYXzdT13csA1gzVeEqLQ9erRiIa4nplXfX8=	2026-08-24 16:17:16.99847+05:30	2026-08-17 16:17:40.122478+05:30	\N	2026-08-17 16:17:16.998657+05:30	2026-08-17 16:17:40.122482+05:30	\N	\N	\N
6544a181-3f3a-4144-b056-379194a62c16	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	YbJGU2zFKIigooAUmT4FmscCc8Y+9jVSF6jxSjpP9cc=	2026-08-24 16:17:40.385244+05:30	2026-08-17 16:17:49.667816+05:30	\N	2026-08-17 16:17:40.386981+05:30	2026-08-17 16:17:49.667822+05:30	\N	\N	\N
19672997-467d-4eea-97eb-d151488dc172	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	obOWuTwqYJ+N77rOttpEpHOcwAOgpTvRU8ZyJVnQAxE=	2026-08-24 16:17:49.9316+05:30	2026-08-17 16:18:24.333861+05:30	\N	2026-08-17 16:17:49.931715+05:30	2026-08-17 16:18:24.333866+05:30	\N	\N	\N
541ca967-1936-4135-9a35-3be608b9ae69	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	q2KmFAK85c0/rN6nu4zkz/cd4qu4WQ+S5YogX6or+ww=	2026-08-24 16:18:24.59753+05:30	2026-08-17 16:18:41.263338+05:30	\N	2026-08-17 16:18:24.597752+05:30	2026-08-17 16:18:41.263344+05:30	\N	\N	\N
e326df90-628e-4116-b0c0-7080fcaa8600	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	xr1Sne+m16vH9x8Gp0wc2aEU0+FzFn9nr7a/agbZ3J4=	2026-08-24 16:18:41.557845+05:30	2026-08-17 16:20:13.037833+05:30	\N	2026-08-17 16:18:41.558007+05:30	2026-08-17 16:20:13.037838+05:30	\N	\N	\N
43ef2d5b-6c09-474f-bc30-da97e8fd918d	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	LYPcHQOAc9n3QOXe7neSoulka/Ow92yXZtzvBtZ12Ug=	2026-08-24 16:20:13.299617+05:30	2026-08-17 16:20:20.876595+05:30	\N	2026-08-17 16:20:13.299706+05:30	2026-08-17 16:20:20.876601+05:30	\N	\N	\N
0bc3e28b-84e1-43d6-8132-88c6bca7c9b1	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	M44mUgI8jhc5s0ZwYCuGScjDyusbEGVm66AsRSaU/ZQ=	2026-08-24 16:20:21.140025+05:30	2026-08-17 16:20:27.64179+05:30	\N	2026-08-17 16:20:21.140218+05:30	2026-08-17 16:20:27.641796+05:30	\N	\N	\N
f416f6e6-6d56-4b5e-aded-84a886efb76e	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	kz/mMj+npYsMPDl6vdeW88h7QpbHCOMlhkMUubEp4q8=	2026-08-24 16:20:27.903433+05:30	2026-08-17 16:23:53.276291+05:30	\N	2026-08-17 16:20:27.903527+05:30	2026-08-17 16:23:53.276675+05:30	\N	\N	\N
f0c0dbe2-26ad-412b-8fd4-efbdaf5f5049	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	QXvpTmPUzlpfZHTenK/cCB8ECqz74zoZ+qcCVmntsck=	2026-08-24 16:23:53.276475+05:30	2026-08-17 16:23:58.331222+05:30	\N	2026-08-17 16:23:53.276675+05:30	2026-08-17 16:23:58.33123+05:30	\N	\N	\N
9ac79ccb-6ecc-4c15-9809-3c7b3e27b855	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	/wR0iEd2XPqtKUl7r19/n/rTTmfhq1isi+m+NWo1o/8=	2026-08-24 16:23:58.598582+05:30	2026-08-17 16:24:16.392879+05:30	\N	2026-08-17 16:23:58.598656+05:30	2026-08-17 16:24:16.392886+05:30	\N	\N	\N
996ed647-7f80-47fd-a0b4-f83d44b7e768	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	sWdLC+bhYH12HZtz+n1ZbR+dOvw5TTLEYk+lrA1R8Z8=	2026-08-24 16:24:16.654392+05:30	2026-08-17 16:31:24.968089+05:30	\N	2026-08-17 16:24:16.654461+05:30	2026-08-17 16:31:24.968097+05:30	\N	\N	\N
0423fb6d-2a83-4d81-a3df-e5e2b6dcbcf8	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	w4gG5a9z1VqLsv425TFsoM2RltGR6ZwffxedixBWMx4=	2026-08-24 16:31:25.242308+05:30	2026-08-17 16:31:41.284327+05:30	\N	2026-08-17 16:31:25.242461+05:30	2026-08-17 16:31:41.284333+05:30	\N	\N	\N
7e38533f-dd2f-4fe4-bf29-e6187d9b13fe	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	gukOlFu0azfGFnYf8l5yAqp7Ifpyy57v5CEXBqS0O5Y=	2026-08-24 16:31:41.548449+05:30	2026-08-17 16:39:32.937037+05:30	\N	2026-08-17 16:31:41.548525+05:30	2026-08-17 16:39:32.937275+05:30	\N	\N	\N
99ee33e5-bff9-463f-9fa8-9d39f79c368a	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	LIghIk/fC+o7ntEwLtIH7e6FwZnfR3RU9/ojAaiBBJo=	2026-08-24 16:39:32.937167+05:30	2026-08-17 16:39:54.530607+05:30	\N	2026-08-17 16:39:32.937275+05:30	2026-08-17 16:39:54.530734+05:30	\N	\N	\N
356e8413-52ae-4e06-93cf-76e8d25cdea2	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	dyWgfntMI23FLx2INmRJpKTpWLQArmdEmGt5a4zM1HA=	2026-08-24 16:39:54.530689+05:30	2026-08-17 16:42:36.577252+05:30	\N	2026-08-17 16:39:54.530734+05:30	2026-08-17 16:42:36.57755+05:30	\N	\N	\N
b5b340e0-c6fd-41db-bbad-a3c917bc7ad0	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	X22WFXGZLaBDC3vZ4wb86BQuxKHhJMJpaCtDKFiBIIY=	2026-08-24 16:42:36.577473+05:30	2026-08-17 16:42:47.818417+05:30	\N	2026-08-17 16:42:36.57755+05:30	2026-08-17 16:42:47.818632+05:30	\N	\N	\N
f5d9057d-20f9-42d0-9a16-7f5739ad6528	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	w1QTd2jj6xg92smSFsDgxP/6bZBhh/WW39aLiyHq5w4=	2026-08-24 16:42:47.818543+05:30	2026-08-17 17:27:57.301662+05:30	\N	2026-08-17 16:42:47.818632+05:30	2026-08-17 17:27:57.301853+05:30	\N	\N	\N
45d529d1-7560-4ea9-bbcf-33dcf86bd316	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	iYOe4rauLCA9uhzDSPn7fXjlq1sjswl7BdxjxSG5zOM=	2026-08-24 17:27:57.301786+05:30	2026-08-17 17:28:01.233147+05:30	\N	2026-08-17 17:27:57.301853+05:30	2026-08-17 17:28:01.233153+05:30	\N	\N	\N
56f8022d-2eea-42ef-a4b1-8eaac79daf3a	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	w+1ZFejxPNm5sN/yNpv/rFDckomt1oGAkmnWTIW2azM=	2026-08-24 17:28:01.493103+05:30	2026-08-17 17:28:22.739138+05:30	\N	2026-08-17 17:28:01.493149+05:30	2026-08-17 17:28:22.739283+05:30	\N	\N	\N
84894395-e8b1-4e23-b646-d1f6bdefa8f7	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	8hOlS4EwUfx1WSFSd1n2ameFij+WyS4NYvP069xRfbs=	2026-08-24 17:28:22.739228+05:30	2026-08-17 17:28:56.769216+05:30	\N	2026-08-17 17:28:22.739283+05:30	2026-08-17 17:28:56.769221+05:30	\N	\N	\N
03a8d551-9d8f-4c57-9797-e8151c289481	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	YiNgOfLwPPYOybRDRyqJn6u6BU/lXnWkBCOtPXbuFeE=	2026-08-24 17:28:57.032888+05:30	2026-08-17 17:29:11.236353+05:30	\N	2026-08-17 17:28:57.032971+05:30	2026-08-17 17:29:11.236364+05:30	\N	\N	\N
e76879cd-819a-4c9b-8ba9-d8cd725fb410	1a077a8c-4029-8ded-d563-19e9b4bdf301	JWu33DcURBxZKZvUnQ9y45NGV53JGp5Bn5vUsl5ZuPI=	2026-08-24 17:29:11.502017+05:30	2026-08-17 17:29:20.424956+05:30	\N	2026-08-17 17:29:11.502093+05:30	2026-08-17 17:29:20.424962+05:30	\N	\N	\N
efd90bba-f5af-444b-bfd5-1242cdf26938	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	cMw6UtsbRIxFqYbje8SHl1amw+1qHYb/rRrKJkM3cnU=	2026-08-24 17:29:20.692077+05:30	2026-08-17 17:30:08.819642+05:30	\N	2026-08-17 17:29:20.692164+05:30	2026-08-17 17:30:08.819647+05:30	\N	\N	\N
4ada84c4-a2a6-4fe8-9deb-8055936c856a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	AV0nnowzbFdfkz1TRUg0cl34aIlABicVUvZL0H2v9z0=	2026-08-24 17:30:09.081062+05:30	2026-08-17 17:31:04.145933+05:30	\N	2026-08-17 17:30:09.081139+05:30	2026-08-17 17:31:04.145938+05:30	\N	\N	\N
dd292667-73be-460c-b02c-61f4ae0546db	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	cBPr0r1P95FvRxLPf+xTxKQg17tYPheiV6GOh5ijj3w=	2026-08-24 17:31:04.408471+05:30	2026-08-17 17:31:06.787854+05:30	\N	2026-08-17 17:31:04.408542+05:30	2026-08-17 17:31:06.787863+05:30	\N	\N	\N
9cc00de6-341f-485c-9c9c-da893cce4f20	1a077a8c-4029-8ded-d563-19e9b4bdf301	mpL/SZuExtOFIWYRx6iwcMdQv7QdtzLgidzQV8+T/0I=	2026-08-24 17:31:07.052642+05:30	2026-08-17 17:31:10.230649+05:30	\N	2026-08-17 17:31:07.052713+05:30	2026-08-17 17:31:10.230656+05:30	\N	\N	\N
9023b820-1fbe-4d16-9442-34d37ac84667	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	KeDrJ3IdXkZi2axBt2/AjoR1IHUGMJD6DJk+jYsdgEc=	2026-08-24 17:31:10.500611+05:30	2026-08-17 17:31:35.223805+05:30	\N	2026-08-17 17:31:10.500685+05:30	2026-08-17 17:31:35.223811+05:30	\N	\N	\N
9d56e385-c114-43f1-9b02-706e679836b8	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	klHXnr0Uf5TDJfp5CgvmLf5XjqoMY4x8tpBh75q5CLk=	2026-08-24 17:31:35.484363+05:30	2026-08-17 17:33:41.82769+05:30	\N	2026-08-17 17:31:35.484433+05:30	2026-08-17 17:33:41.827695+05:30	\N	\N	\N
1e26d3e9-48b5-4440-9f43-1b70a610934e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	oCMaYALIOjgQqakjGWSu2qP8oejmBSF9rppk+CT//oE=	2026-08-24 17:33:42.092473+05:30	2026-08-17 17:35:28.485642+05:30	\N	2026-08-17 17:33:42.092547+05:30	2026-08-17 17:35:28.48565+05:30	\N	\N	\N
d6449db7-bc10-4bc3-8eb6-347e23602f72	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	uZouvs+MGC0ulI6MQFlfW3zdpZ0vQcE2dXBioN8Oq+8=	2026-08-24 17:35:28.746379+05:30	2026-08-17 17:36:08.405843+05:30	\N	2026-08-17 17:35:28.746449+05:30	2026-08-17 17:36:08.405848+05:30	\N	\N	\N
4875465f-c85e-4ac8-a933-542c4813a7b6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NDJqCOFFqQvfeSODiUuZ1SvDnc5yWQGlUq064YBkAxA=	2026-08-24 17:36:08.670054+05:30	2026-08-17 17:37:03.008462+05:30	\N	2026-08-17 17:36:08.670129+05:30	2026-08-17 17:37:03.008634+05:30	\N	\N	\N
5ad1f0c7-fd9f-4418-ab01-827f0951294d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	djvl12nKc+1K7cdEygrLUv5o9/+WeOLs9ApO9SxZOqk=	2026-08-24 17:37:03.008561+05:30	2026-08-17 17:41:39.542794+05:30	\N	2026-08-17 17:37:03.008634+05:30	2026-08-17 17:41:39.542799+05:30	\N	\N	\N
81459026-5985-44c3-ae3c-22bc71a6aae9	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	0wiDfzkV0IfjiJEXF7WRqvTDeqNWnlWZvC3rwPmj3E8=	2026-08-24 17:41:39.810391+05:30	2026-08-17 17:43:29.169363+05:30	\N	2026-08-17 17:41:39.810512+05:30	2026-08-17 17:43:29.169369+05:30	\N	\N	\N
5561a6e3-d7da-4aa2-8b03-fdf02bea5472	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	CbM9QP2UVwAFEArs8a9eJVl7++ZWxFPsDCIwU1dgldQ=	2026-08-24 17:43:29.431843+05:30	2026-08-17 17:43:49.987614+05:30	\N	2026-08-17 17:43:29.432084+05:30	2026-08-17 17:43:49.987622+05:30	\N	\N	\N
dc7ee74d-47bd-47b8-93bd-c4bdc03dfe5b	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	+CaBJLFOqQEDd7JFTBEDPWqw5g+Q9gcOUA+5QgmoSt0=	2026-08-24 17:43:50.252252+05:30	2026-08-17 17:52:51.230058+05:30	\N	2026-08-17 17:43:50.252378+05:30	2026-08-17 17:52:51.230064+05:30	\N	\N	\N
a780dbd0-63fb-46f5-9d7a-6123c7f3204e	1a077a8c-4029-8ded-d563-19e9b4bdf301	uoBE430BtX5kiC+CkQKX0w3M1dby4FSygE05M7nnXeo=	2026-08-24 17:52:51.494942+05:30	2026-08-17 18:21:48.419883+05:30	\N	2026-08-17 17:52:51.495015+05:30	2026-08-17 18:21:48.420493+05:30	\N	\N	\N
c2d9b70d-72a2-49ed-ab90-23402302ca08	1a077a8c-4029-8ded-d563-19e9b4bdf301	/Eo9/2AOLIPdg3D7JI00pPYh4P7i2Xpa9fgBoxzEhUA=	2026-08-24 18:21:48.420147+05:30	2026-08-18 11:34:46.641879+05:30	\N	2026-08-17 18:21:48.420493+05:30	2026-08-18 11:34:46.709038+05:30	\N	\N	\N
9dab18c5-4910-494a-b916-3aec937e71dd	1a077a8c-4029-8ded-d563-19e9b4bdf301	LkZBd4w0HNdum6Lx3zjSCtTcvFuP81oLgR73qlN2/cs=	2026-08-25 11:34:46.694578+05:30	2026-08-18 11:45:37.201914+05:30	\N	2026-08-18 11:34:46.709038+05:30	2026-08-18 11:45:37.201951+05:30	\N	\N	\N
a59e4717-2357-4fd0-b2fd-5dd9ee769d5a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	hwPhi0LzFrSAfwtj8huu1g9S2O+aqf/X3x4jo6ax/PA=	2026-08-25 11:45:37.547392+05:30	2026-08-18 12:06:55.114218+05:30	\N	2026-08-18 11:45:37.548105+05:30	2026-08-18 12:06:55.114468+05:30	\N	\N	\N
6df01054-a8ad-4742-ad53-c19851281053	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CMP4L5BUxXJTDR4PpuUOwiRbiIePoHz6XWyFM4fekBg=	2026-08-25 12:06:55.114381+05:30	2026-08-18 12:13:46.723065+05:30	\N	2026-08-18 12:06:55.114468+05:30	2026-08-18 12:13:46.723515+05:30	\N	\N	\N
af696739-a803-4a43-8e3b-567844a027cd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	O743lYGzG6xw+Z+RBfTBRd/Cd2Czf72m1nhyWHwiL/4=	2026-08-25 12:13:46.723239+05:30	2026-08-18 12:13:58.968294+05:30	\N	2026-08-18 12:13:46.723515+05:30	2026-08-18 12:13:58.968586+05:30	\N	\N	\N
c267558c-3cb5-48b9-ac8e-2d07d1f48c63	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NnKGqdkaep4AfLfyYX0zIAHtGAsaworwHJfUtudrWbc=	2026-08-25 12:13:58.968511+05:30	2026-08-18 12:14:07.22374+05:30	\N	2026-08-18 12:13:58.968586+05:30	2026-08-18 12:14:07.224+05:30	\N	\N	\N
7a86fc1f-5fb9-411f-b7ad-e5520f2fe101	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yB3yXyWbKtKgBOitrgm8NZOeQuiGg8jfm6GXiJzQwNk=	2026-08-25 12:14:07.223879+05:30	2026-08-18 12:36:38.149149+05:30	\N	2026-08-18 12:14:07.224+05:30	2026-08-18 12:36:38.149505+05:30	\N	\N	\N
9f2b67b9-bd27-42bb-be70-4de4ddf15fd6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	D594vU8FtTydw0DmzLvHb+Y49dvrT7rikcNYMNd/eXY=	2026-08-25 12:36:38.149374+05:30	2026-08-18 12:39:18.859075+05:30	\N	2026-08-18 12:36:38.149505+05:30	2026-08-18 12:39:18.859085+05:30	\N	\N	\N
15a95332-3ea7-4ecc-b6d5-72db6234e7e3	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	Eh+/oUSPyqYCSqV4RiTZFnQrh7TX4igHqfeMH3HicUE=	2026-08-25 12:39:19.146082+05:30	2026-08-18 12:39:23.23619+05:30	\N	2026-08-18 12:39:19.146189+05:30	2026-08-18 12:39:23.236218+05:30	\N	\N	\N
278d92b2-25a3-47f9-a091-87ad855eddd9	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	+zNF2QWPzd8qCKWgWtxr5vMen5AEbGOtfHr+LOHz3/w=	2026-08-25 12:39:23.508183+05:30	2026-08-18 12:39:47.936992+05:30	\N	2026-08-18 12:39:23.508276+05:30	2026-08-18 12:39:47.937013+05:30	\N	\N	\N
dc7be323-2a20-47f9-8f76-77bb576160f7	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	1ftvK7RxlbL/ty1Pc1ksRXNTNlVyKFHFCegEWInMwm4=	2026-08-25 12:39:48.225427+05:30	2026-08-18 12:39:55.565042+05:30	\N	2026-08-18 12:39:48.225901+05:30	2026-08-18 12:39:55.565059+05:30	\N	\N	\N
23490e7f-54f2-4464-b431-fa870660070a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0UnYTsBzhYrbgfOg6/Sbn9omVrvPkr2yiEBjDaOfnMI=	2026-08-25 12:39:55.853521+05:30	2026-08-18 13:04:20.105403+05:30	\N	2026-08-18 12:39:55.853621+05:30	2026-08-18 13:04:20.10581+05:30	\N	\N	\N
59951542-5164-4aa0-abff-c3c170fa18d6	40517b71-5e62-182e-73b5-d4070e20a3c2	iGYBKSDZ1wWr2sJpdjmQZpg6Hr5CJWauaqKjC8Yyu1Q=	2026-08-20 12:12:59.444945+05:30	2026-08-18 13:25:49.935567+05:30	\N	2026-08-13 12:12:59.445702+05:30	2026-08-18 13:25:50.051097+05:30	\N	\N	\N
d463ab4a-3b16-489e-98f9-070648a1fab2	40517b71-5e62-182e-73b5-d4070e20a3c2	jk72bJ98xNWx8GFKdZHI3Q94GdGT1vZ1Y6D5O30zUGs=	2026-08-25 13:25:50.024753+05:30	2026-08-18 13:25:58.104331+05:30	\N	2026-08-18 13:25:50.051097+05:30	2026-08-18 13:25:58.105943+05:30	\N	\N	\N
85a43101-0d36-4bfb-a372-7790c5905f39	40517b71-5e62-182e-73b5-d4070e20a3c2	/KEzeFcJmB1rDk2muQ37bIOgW6QV41IWZBLP3mzBX6s=	2026-08-25 13:25:58.104735+05:30	2026-08-18 13:26:05.500545+05:30	\N	2026-08-18 13:25:58.105943+05:30	2026-08-18 13:26:05.501025+05:30	\N	\N	\N
2cc55021-2e6d-49c6-938a-89c56c54290c	40517b71-5e62-182e-73b5-d4070e20a3c2	i2px2FluP6HRfIpKZDH9cJnvWyFOQ6ovUUh0UiiMe94=	2026-08-25 13:26:05.500882+05:30	2026-08-18 13:26:16.328741+05:30	\N	2026-08-18 13:26:05.501025+05:30	2026-08-18 13:26:16.329137+05:30	\N	\N	\N
f9b4e8a7-dd18-449a-91a9-8f9e7bf5281f	40517b71-5e62-182e-73b5-d4070e20a3c2	6dw4wxVmeEjgVaXgZEHiClLNDjbKKcdY0V28yZ1LQ9c=	2026-08-25 13:26:16.329009+05:30	2026-08-18 13:41:05.416066+05:30	\N	2026-08-18 13:26:16.329137+05:30	2026-08-18 13:41:05.478112+05:30	\N	\N	\N
475f620e-63a6-4db0-91f2-48ab79ffab72	40517b71-5e62-182e-73b5-d4070e20a3c2	83h2UsYCG/aTufqUXjflt+02dVafPA+LNxFAb6A5hSE=	2026-08-25 13:41:05.452909+05:30	2026-08-18 13:41:15.150239+05:30	\N	2026-08-18 13:41:05.478112+05:30	2026-08-18 13:41:15.152167+05:30	\N	\N	\N
d4461809-271f-4f34-8858-374ae6b24c6c	40517b71-5e62-182e-73b5-d4070e20a3c2	d1W4+A3xQoQtf9iRb2xejMNYJdhdZvfq0+a89Kfwof0=	2026-08-25 13:41:15.150909+05:30	2026-08-18 13:41:22.76849+05:30	\N	2026-08-18 13:41:15.152167+05:30	2026-08-18 13:41:22.76884+05:30	\N	\N	\N
ce8f1ffd-ced8-43bc-8b20-ddeb9ad34bec	40517b71-5e62-182e-73b5-d4070e20a3c2	wmhvNz3wKtj8IzZJtCwB7wtjP2ILtmasDgnZnUEBEps=	2026-08-25 13:41:22.768708+05:30	2026-08-18 13:41:33.201462+05:30	\N	2026-08-18 13:41:22.76884+05:30	2026-08-18 13:41:33.202857+05:30	\N	\N	\N
63f5345f-be99-4590-8e62-0c321eb7ae8d	40517b71-5e62-182e-73b5-d4070e20a3c2	scmZITNm+ugBp5fc/OB8y8JZXTOWdYplAD5PftwNLnU=	2026-08-25 13:41:33.202436+05:30	2026-08-18 13:42:06.309241+05:30	\N	2026-08-18 13:41:33.202857+05:30	2026-08-18 13:42:06.356712+05:30	\N	\N	\N
da11478f-fadc-4b0e-8b87-aeb8926171c3	40517b71-5e62-182e-73b5-d4070e20a3c2	gst/FlRWp+DwSAtCoE8B2ZOBs7gzVlMaHVzo2ohEIXc=	2026-08-25 13:42:06.336376+05:30	2026-08-18 13:42:58.421849+05:30	\N	2026-08-18 13:42:06.356712+05:30	2026-08-18 13:42:58.481994+05:30	\N	\N	\N
46686659-7ebb-41a5-9e1d-7ae822bf9b6e	40517b71-5e62-182e-73b5-d4070e20a3c2	lKtzYNRnnZgSFvJranL0MbEIE99XDxp5SC503rUiBAA=	2026-08-25 13:42:58.455833+05:30	2026-08-18 13:53:38.029323+05:30	\N	2026-08-18 13:42:58.481994+05:30	2026-08-18 13:53:38.059042+05:30	\N	\N	\N
3fecdcc5-8f97-4527-ac12-ff40a0d8d200	40517b71-5e62-182e-73b5-d4070e20a3c2	o18OCX3UbPf4ItAVPKoNPIWINFk9bX0gGPuDaSNJCSo=	2026-08-25 13:53:38.053951+05:30	2026-08-18 13:53:48.144203+05:30	\N	2026-08-18 13:53:38.059042+05:30	2026-08-18 13:53:48.145189+05:30	\N	\N	\N
678be74e-813d-45d4-90dc-dd39d766c9d6	40517b71-5e62-182e-73b5-d4070e20a3c2	kYBP1RRZ7S0APr+B2aASjxrZZUcRJar2UaT+nYvFjsw=	2026-08-25 13:53:48.144976+05:30	2026-08-18 13:53:58.141131+05:30	\N	2026-08-18 13:53:48.145189+05:30	2026-08-18 13:53:58.141542+05:30	\N	\N	\N
c3fe1af9-835b-4456-8dc3-3acd4efae5fb	40517b71-5e62-182e-73b5-d4070e20a3c2	joORer50DRws+Cvck4xbOb5pqCti8KPiTCAm3lBuiXc=	2026-08-25 13:53:58.141461+05:30	2026-08-18 13:55:33.560391+05:30	\N	2026-08-18 13:53:58.141542+05:30	2026-08-18 13:55:33.644941+05:30	\N	\N	\N
407dad73-66f3-4103-a273-99f8029128fb	40517b71-5e62-182e-73b5-d4070e20a3c2	DrSphijeoqv9Yf9jZsjpguXpGBDwna9Rmn5/S5g2NSw=	2026-08-25 13:55:33.611333+05:30	2026-08-18 13:55:46.027363+05:30	\N	2026-08-18 13:55:33.644941+05:30	2026-08-18 13:55:46.03023+05:30	\N	\N	\N
f32eff42-0648-436e-bfd0-154eb7e0ca75	40517b71-5e62-182e-73b5-d4070e20a3c2	oFdVVA/qAogEbQjObwHaVWdDbTROKrjvzNuehWWjhCU=	2026-08-25 13:55:46.028154+05:30	2026-08-18 13:55:57.140625+05:30	\N	2026-08-18 13:55:46.03023+05:30	2026-08-18 13:55:57.141107+05:30	\N	\N	\N
2c6900bc-d6a2-4820-94b5-9ca3c39fd365	40517b71-5e62-182e-73b5-d4070e20a3c2	TNqnFSP3DHw2rwTtfsxpWDD6fxSo2hWbiqBbYi6u1+E=	2026-08-25 13:55:57.140943+05:30	2026-08-18 13:56:13.718938+05:30	\N	2026-08-18 13:55:57.141107+05:30	2026-08-18 13:56:13.719999+05:30	\N	\N	\N
4b833d4d-f763-48b0-9a75-f5e4dd645046	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zkXgsvEMMNZ54OU2KR1czFKwV2OQwvFF4YhNiGyi79M=	2026-08-25 13:04:20.105633+05:30	2026-08-18 14:43:33.051695+05:30	\N	2026-08-18 13:04:20.10581+05:30	2026-08-18 14:43:33.102443+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
58f453f4-9370-472d-adcc-0cc7840cdd09	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	wpZjUbmUcckhBOZ4Ab59yt5hXxeHG5XyaEbR3BxcDdc=	2026-08-25 14:43:33.099022+05:30	2026-08-18 14:43:39.930326+05:30	\N	2026-08-18 14:43:33.102443+05:30	2026-08-18 14:43:39.931264+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eebe5b3c-af28-4ebb-b5cb-7cd65cc047dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	lILkkaH3kDSxnMJRBcBcRETcf5q3drgs0uYsAY2AQB4=	2026-08-25 14:43:39.930731+05:30	2026-08-18 14:43:41.890343+05:30	\N	2026-08-18 14:43:39.931264+05:30	2026-08-18 14:43:41.890703+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6867b401-390a-4fe2-b4bf-230066a1c7f7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8qHkf+tasX4/V1qtPqnclNmESk2fLCf9ZBlb50SpcEo=	2026-08-25 14:43:41.890545+05:30	2026-08-18 14:51:07.670719+05:30	\N	2026-08-18 14:43:41.890703+05:30	2026-08-18 14:51:07.671009+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
61cf05ac-5626-4982-8196-80993c90b9f3	40517b71-5e62-182e-73b5-d4070e20a3c2	t1+AHGxH/i9ivoo1ZCEYQsqWXtE80pMxCJ5QMOVEObg=	2026-08-25 13:56:13.719699+05:30	2026-08-18 14:52:40.902063+05:30	\N	2026-08-18 13:56:13.719999+05:30	2026-08-18 14:52:40.956184+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
762af9f5-48c3-4ffd-baf6-155c21dee5f8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	wb57Z+ir1BMMf63ljsYC3xPOJ/wpBAnofsgXb1oQ9qs=	2026-08-25 14:51:07.670886+05:30	2026-08-18 14:53:15.039933+05:30	\N	2026-08-18 14:51:07.671009+05:30	2026-08-18 14:53:15.04024+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
31a99adb-4d6f-4b1a-9918-156b0059c18e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	MgGbD8gqfcZakK10M0E1r1brKmTumygjCiT4SAjO7cQ=	2026-08-25 14:53:15.040137+05:30	2026-08-18 14:53:44.965452+05:30	\N	2026-08-18 14:53:15.04024+05:30	2026-08-18 14:53:44.965697+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
47411ef7-c88e-4e44-bb21-85f642120434	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	69mavGk2yB/TA5eVNDfQJt2pXj3A+h+wFnJia4CYlA4=	2026-08-25 14:53:44.965607+05:30	2026-08-18 14:53:50.000873+05:30	\N	2026-08-18 14:53:44.965697+05:30	2026-08-18 14:53:50.000888+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d3fcede7-1dce-44fe-9631-b732543d777d	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	mgutPEB165Ppt6Q3ZmXBYAMY9HZMmM+XxCS0dl3Dkzs=	2026-08-25 14:53:50.291237+05:30	2026-08-18 14:53:53.62998+05:30	\N	2026-08-18 14:53:50.291394+05:30	2026-08-18 14:53:53.630002+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d6a9f7a0-d3ec-4cab-82b7-56fe1cb3e788	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Bp/jYuPnLXcSPyOUwy0PDMwLfvi/IXYvGpQf+YcAdkc=	2026-08-25 14:53:53.911165+05:30	2026-08-18 14:56:11.515594+05:30	\N	2026-08-18 14:53:53.911304+05:30	2026-08-18 14:56:11.515927+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
858bb977-76b8-4aaf-9a56-466891d9f279	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	k7QCQyx5RST9NO7VdXh7EW/8qC/c4aM60hD354M5HmQ=	2026-08-25 14:56:11.515808+05:30	2026-08-18 15:03:32.855972+05:30	\N	2026-08-18 14:56:11.515927+05:30	2026-08-18 15:03:32.856303+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d57d8f4b-68b5-46e9-a7ab-4fef218f255c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	txJRPyv/D1kliiXuP5WLDJu1hHvJMJba9/7E9E+1xOk=	2026-08-25 15:03:32.856156+05:30	2026-08-18 15:08:32.30151+05:30	\N	2026-08-18 15:03:32.856303+05:30	2026-08-18 15:08:32.325655+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
128efd61-eff0-4f9b-9d97-1333b3e98b47	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	H4+tqyrps9ABEEm+5l9JZpNYDTBIrXoTAr3e2FNRKrA=	2026-08-25 15:08:32.311122+05:30	2026-08-18 15:14:34.76033+05:30	\N	2026-08-18 15:08:32.325655+05:30	2026-08-18 15:14:34.760347+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2162b7fc-19e9-4129-97b6-deaf76a5a3d6	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	AnOqV8psR2qz4ZJpeI86Az2/AUL2Lzb3Qp/WmYJFzFA=	2026-08-25 15:14:35.061904+05:30	2026-08-18 15:15:17.67873+05:30	\N	2026-08-18 15:14:35.062646+05:30	2026-08-18 15:15:17.679028+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
48cc138e-42f0-4ae3-9946-f668e804d822	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	bi21YGJn6gsh84TqvNVYBz1L91Pt6pNCvPG7WqdhZLI=	2026-08-25 15:15:17.678897+05:30	2026-08-18 15:16:12.267054+05:30	\N	2026-08-18 15:15:17.679028+05:30	2026-08-18 15:16:12.267327+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8e6156e0-e938-4471-bd6c-be757425bfe7	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	gMZkcXFbbOhbIAlRX6zVkKr4p0vO25GkyoWCDMLfrb0=	2026-08-25 15:16:12.267226+05:30	2026-08-18 15:20:14.393206+05:30	\N	2026-08-18 15:16:12.267327+05:30	2026-08-18 15:20:14.393469+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d9827d93-2e19-45d9-99de-fd089e85f5f5	40517b71-5e62-182e-73b5-d4070e20a3c2	anxVVS6OJPaHXggO+2roxQFiT+7Ut1yD07NaFmvphXE=	2026-08-25 14:52:40.944076+05:30	2026-08-19 11:23:03.173649+05:30	\N	2026-08-18 14:52:40.956184+05:30	2026-08-19 11:23:03.210399+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9a2f42eb-3f6d-4cad-b713-0e5d6b72ab2a	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	gSR6mb2pPVQ/kaVfmnwBmdAX6gaq2eTkNwHfGLK8aqY=	2026-08-25 15:20:14.393361+05:30	2026-08-18 15:21:21.388712+05:30	\N	2026-08-18 15:20:14.393469+05:30	2026-08-18 15:21:21.388962+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ff010552-7d89-4ef3-9f68-30d1575ce743	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	SHZEZAS7gky+EFQOoQE6RUPvxxOFGblDF16x/tt+Wwg=	2026-08-25 15:21:21.388855+05:30	2026-08-18 15:21:33.421785+05:30	\N	2026-08-18 15:21:21.388962+05:30	2026-08-18 15:21:33.422492+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1f00b00d-e450-4bdf-afeb-4ff56431ad87	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	zS+Vcar9XluVVZ78hHe5jH9jpZPYMl8b8ANjS9hJYvw=	2026-08-25 15:21:33.422384+05:30	2026-08-18 15:21:39.222135+05:30	\N	2026-08-18 15:21:33.422492+05:30	2026-08-18 15:21:39.22215+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
46598717-4367-4d14-b5bc-70a651415671	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	1mBqXOeL8VRfG2EnzhZs8m1dk0Ss4lQf+hFCF1dqEas=	2026-08-25 15:21:39.5081+05:30	2026-08-18 15:21:45.122662+05:30	\N	2026-08-18 15:21:39.508212+05:30	2026-08-18 15:21:45.122882+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
56d4c702-7395-47a8-a862-b49904f5afba	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	8+Sdq/0F4hz5bvuDnBxHH1V8zsZvupQXpylp2TJPME8=	2026-08-25 15:21:45.122797+05:30	2026-08-18 15:22:40.854381+05:30	\N	2026-08-18 15:21:45.122882+05:30	2026-08-18 15:22:40.854627+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
62fb0d05-04c5-477d-b863-e2a8efe0d271	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	S17Dez/+wlm6KfI2CTrdcGz0pq0cjWUwkD3Y3+Q/u9c=	2026-08-25 15:22:40.854511+05:30	2026-08-18 15:24:18.504876+05:30	\N	2026-08-18 15:22:40.854627+05:30	2026-08-18 15:24:18.504888+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bfcffa72-1b52-4768-818b-9682909cb92e	730809c0-fc01-a664-03ca-28e0e32d0393	ejof79VsXW70mBHgEWoeWBa9wWL4j2fDhyNnZWesAhE=	2026-08-25 15:24:18.78921+05:30	2026-08-18 15:30:47.141784+05:30	\N	2026-08-18 15:24:18.789316+05:30	2026-08-18 15:30:47.141806+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3952a555-233b-497e-9b17-d83f6cb56be4	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	3fUqVQ+h6W9zoaOScgg7JWuluyF+ImX8CgKLwxObaAk=	2026-08-25 15:30:47.388612+05:30	2026-08-18 15:30:49.841561+05:30	\N	2026-08-18 15:30:47.388725+05:30	2026-08-18 15:30:49.841804+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cad3c0ab-bd1c-45e4-ab67-f55e17fe8959	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	kCUvGBxPcpSotWCSQyPAkiKVcvm/OBPMFgylEve1IMk=	2026-08-25 15:30:49.8417+05:30	2026-08-18 15:30:54.231529+05:30	\N	2026-08-18 15:30:49.841804+05:30	2026-08-18 15:30:54.23154+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
78e356fe-8f00-49f6-bf7e-f578eef12a7b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	50P9Ur6T1qrVUHTB7+BzdncOeLS7ln5xHu0LasKi9ak=	2026-08-25 15:30:54.5114+05:30	2026-08-18 15:35:48.762691+05:30	\N	2026-08-18 15:30:54.511499+05:30	2026-08-18 15:35:48.762718+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
96ff51ee-fe39-4217-94f7-565589af347d	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	vcuKj2pvsoUJ9DKvBUgQGREYAu7ISR930+54I3LGcfY=	2026-08-25 15:35:49.018162+05:30	2026-08-18 15:35:55.654132+05:30	\N	2026-08-18 15:35:49.018302+05:30	2026-08-18 15:35:55.654305+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fd605b55-f7b1-484e-85a1-a8629a64206d	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	xjIQGvFHe1CxGpE1kZX8kAHJ88RQjFXzfbBLYud35hI=	2026-08-25 15:35:55.654235+05:30	2026-08-18 15:36:07.538097+05:30	\N	2026-08-18 15:35:55.654305+05:30	2026-08-18 15:36:07.538327+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
92fa9224-2833-4e79-b583-48ea4a68531b	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	2xhd8coSZSodmTczDelfFLFii3h0FlMjrybcY5skyC0=	2026-08-25 15:36:07.53823+05:30	2026-08-18 15:36:10.536225+05:30	\N	2026-08-18 15:36:07.538327+05:30	2026-08-18 15:36:10.536233+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
779242cf-d0bb-4bf1-91b5-4d07ee3924d0	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	NzWIS/EIqDh+vdWDRU72sbR+NmACUPDXM5C4URPXZFE=	2026-08-25 15:36:10.818358+05:30	2026-08-18 15:36:19.410703+05:30	\N	2026-08-18 15:36:10.818455+05:30	2026-08-18 15:36:19.410982+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c0e0fd6e-b3f5-4176-862b-9740cfec8d42	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	56i7URAZuvuR38VSHDrV0HVXbDXM/lweufJABsLA5vU=	2026-08-25 15:36:19.410909+05:30	2026-08-18 15:37:14.036166+05:30	\N	2026-08-18 15:36:19.410982+05:30	2026-08-18 15:37:14.036174+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a7d0d6fd-a68b-438b-8ade-095e009ca984	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8T5E5KfBMeqOu0SbXPpRgQjc/JhqTmkcdemHzdT0IAc=	2026-08-25 15:37:14.337347+05:30	2026-08-18 15:38:30.377917+05:30	\N	2026-08-18 15:37:14.337431+05:30	2026-08-18 15:38:30.37816+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
17595729-94f0-4f7e-95e7-ca1868bcf2de	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4zhXNGSnB5gPNgq8hqfKmYuVraQIgKZF/rqRO+wIADo=	2026-08-25 15:38:30.37809+05:30	2026-08-18 15:49:00.987139+05:30	\N	2026-08-18 15:38:30.37816+05:30	2026-08-18 15:49:00.987502+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b9bcac2f-69c1-4805-9de9-1dd9f984bac8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UNqd4WtnrVth7warYSf29e59mL4+x6eruAPyIcDWKFU=	2026-08-25 15:49:00.987285+05:30	2026-08-18 15:52:00.688782+05:30	\N	2026-08-18 15:49:00.987502+05:30	2026-08-18 15:52:00.689086+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1607a9a4-433d-49f7-9ae6-18de2055ac2d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8uPUGwwJbL41wyHN7nNvpu4NstGwKDfUWFuqmNTX9Q4=	2026-08-25 15:52:00.688924+05:30	2026-08-18 16:11:49.022918+05:30	\N	2026-08-18 15:52:00.689086+05:30	2026-08-18 16:11:49.058965+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4c02a7ab-1b51-4fdc-aba4-b5d449900095	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	jOyYU56SgooK3WNnmdlpXn8+695iBfnlEO3b0GzLWf4=	2026-08-25 16:11:49.045336+05:30	2026-08-18 16:15:51.620293+05:30	\N	2026-08-18 16:11:49.058965+05:30	2026-08-18 16:15:51.620604+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6bd30d86-9c7c-44c9-8402-498d1c086f99	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	WS7OLZ0cEiddzsviRyCjTujZQRbtGeLj1nipjGw9ZDY=	2026-08-25 16:15:52.066793+05:30	2026-08-18 16:31:49.579342+05:30	\N	2026-08-18 16:15:52.076151+05:30	2026-08-18 16:31:49.579853+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b1486843-5360-47a4-8016-36f6c2e6a7d8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	oZ09Cg+CEB0j5hr+YzaLuqDGXRQOwO6lJVNzWrZp17U=	2026-08-25 16:31:49.579745+05:30	2026-08-18 16:32:00.820013+05:30	\N	2026-08-18 16:31:49.579853+05:30	2026-08-18 16:32:00.82029+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ff5d189d-4f8f-4400-991a-cb99202a7c72	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9IvcG9ngjwR7zeLlOqV7HN5vp01dI73prSsOI/0bgDk=	2026-08-25 16:32:00.820212+05:30	2026-08-18 16:32:23.652811+05:30	\N	2026-08-18 16:32:00.82029+05:30	2026-08-18 16:32:23.653208+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
77f4b2f9-f8f7-4dc4-b38f-c08569e0208a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ww6hP7OdVaksYjR0bcQWD5YtRK5dumffRWQaM5urlec=	2026-08-25 16:32:23.653005+05:30	2026-08-18 16:33:01.079041+05:30	\N	2026-08-18 16:32:23.653208+05:30	2026-08-18 16:33:01.07945+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ce42e50e-d5a9-4a06-926d-679ca3840caa	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	MiSxhAG60S49p1rYb4FzbLWo/Qo/xRP9ZVOAWfBYhTA=	2026-08-25 16:33:01.079333+05:30	2026-08-18 16:34:55.073713+05:30	\N	2026-08-18 16:33:01.07945+05:30	2026-08-18 16:34:55.074033+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7ece2484-4eb6-4e7b-9ef9-cdacd33e8f04	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yzB1AN62GOfmDW9xHjEasd+IWAad//hbz0M0g1vJItw=	2026-08-25 16:34:55.073936+05:30	2026-08-18 16:43:18.39907+05:30	\N	2026-08-18 16:34:55.074033+05:30	2026-08-18 16:43:18.399337+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
622f9d1f-8513-4fa0-bed3-91e123682a0b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vFVNTXYYIo27aGQXytA2noKb4QwL9vd3dZ4wWqyV/8Q=	2026-08-25 16:43:18.39925+05:30	2026-08-18 17:10:24.313892+05:30	\N	2026-08-18 16:43:18.399337+05:30	2026-08-18 17:10:24.313907+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
016aa96b-53c1-4150-90f4-514149507d16	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	B7sV/LZDkJRy29acea1ikXcnfeeCwYsTA+XG0ZCGLH0=	2026-08-25 17:10:24.632916+05:30	2026-08-18 17:50:57.853572+05:30	\N	2026-08-18 17:10:24.633039+05:30	2026-08-18 17:50:57.871677+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
362b346a-1ee0-4980-8dd3-808e9db0a79a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	LmNUw16EpsacwmZu5WoAScS4R8WkpQ6DMkgU1jmQttQ=	2026-08-25 17:50:57.864432+05:30	2026-08-18 17:57:07.948572+05:30	\N	2026-08-18 17:50:57.871677+05:30	2026-08-18 17:57:07.949054+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9f2f9456-2762-41dd-a1eb-d5c775ce0d1b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	avX3fPCfnNNjznMHUz0Yp4zZyXqcseLljFsRPVYaNfo=	2026-08-25 17:57:07.948923+05:30	2026-08-18 18:20:38.518359+05:30	\N	2026-08-18 17:57:07.949054+05:30	2026-08-18 18:20:38.558875+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3f0986e0-c3d7-41dc-b1ce-7f5f87f0b129	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5vzj25e/yGGmI1LRDb+Jho6l9AUffUh8X1sA8ccXj1o=	2026-08-25 18:20:38.544526+05:30	2026-08-18 18:20:42.518598+05:30	\N	2026-08-18 18:20:38.558875+05:30	2026-08-18 18:20:42.52006+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2b88e865-3e19-4b4b-a7b8-fade729f705e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DRvXOcwthR3ucK/cfIezk0w8r5yA+nlJuDqSmM2TTYI=	2026-08-25 18:20:42.519089+05:30	2026-08-18 18:22:10.026522+05:30	\N	2026-08-18 18:20:42.52006+05:30	2026-08-18 18:22:10.026982+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
54fd8666-ebdb-45a9-84f5-9563b8c09e1d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	EjXGzCPYoc+o+tgzNafopod3xRA2EmRW4SzX+ovqZKA=	2026-08-25 18:22:10.026829+05:30	2026-08-18 18:29:54.615056+05:30	\N	2026-08-18 18:22:10.026982+05:30	2026-08-18 18:29:54.628604+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fce13779-a0b8-4f81-954a-8a017bf25e62	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4CV3HTzAwZmWIAC5qvJ728H7++X20+SPSqIPX805cyU=	2026-08-25 18:29:54.624206+05:30	2026-08-18 18:43:02.067444+05:30	\N	2026-08-18 18:29:54.628604+05:30	2026-08-18 18:43:02.081607+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c3662cc4-309f-4fb1-9e87-35e7c70c1e47	40517b71-5e62-182e-73b5-d4070e20a3c2	jkQaW2VYrMdpcgMKHRtadaPOew8ypApmJDxXitL1Bb8=	2026-08-26 11:23:03.196938+05:30	2026-08-19 11:23:13.333435+05:30	\N	2026-08-19 11:23:03.210399+05:30	2026-08-19 11:23:13.333748+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0c1b08f0-50fa-4b45-8a4a-62aa254639c1	40517b71-5e62-182e-73b5-d4070e20a3c2	mxPJk7RtwX0H1SvzRMf38Q9vX8Ajo53tdmSSRv56eM0=	2026-08-26 11:23:13.333649+05:30	2026-08-19 11:23:18.001111+05:30	\N	2026-08-19 11:23:13.333748+05:30	2026-08-19 11:23:18.001404+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
629a739d-6dfd-41ce-8a78-bbbbb5c17a4e	40517b71-5e62-182e-73b5-d4070e20a3c2	vQTFc0X+a5tlgkE1z9z5qTecRgR/n8cS+/J3Wqjs5Ig=	2026-08-26 11:23:18.001299+05:30	2026-08-19 11:23:22.904552+05:30	\N	2026-08-19 11:23:18.001404+05:30	2026-08-19 11:23:22.904776+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cf0fa00b-6e75-46d8-bf16-6e1cb726d56e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0h+CXsZZ2pEQf2W36xZLlfBP71QSsYz7MF0XdxxBY9U=	2026-08-25 18:43:02.076612+05:30	2026-08-19 11:29:17.961018+05:30	\N	2026-08-18 18:43:02.081607+05:30	2026-08-19 11:29:18.00206+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e46a29d7-532e-4111-9784-e0e879f7bcbe	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xZankbuGhRs8zaxWkHl1kHlRzJnkbmHAjAh/GpU0Zjs=	2026-08-26 11:29:17.988493+05:30	2026-08-19 11:40:45.639798+05:30	\N	2026-08-19 11:29:18.00206+05:30	2026-08-19 11:40:45.640135+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e965a144-ec53-4ed7-8818-c53405b1d025	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Xm/7vKi3omDHs/WNio7vc1WCC38EexqtZeD52xH58Ls=	2026-08-26 11:40:45.640004+05:30	2026-08-19 12:05:35.767731+05:30	\N	2026-08-19 11:40:45.640135+05:30	2026-08-19 12:05:35.804034+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
425f440a-4cbc-4c5e-a4e4-ac3b4652ce4e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	i4ze+/WK64CCqOBJ1mLxlyafLcoaTdKZMfzW/X5mC1A=	2026-08-26 12:05:35.790371+05:30	2026-08-19 12:37:20.487244+05:30	\N	2026-08-19 12:05:35.804034+05:30	2026-08-19 12:37:20.487755+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
341d6b78-11cf-44ba-bf9a-868c9c0afc1b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	M+w+UBNTmFisc/lWSveL77zlo/IQy53xygDk9pfCPUo=	2026-08-26 12:37:20.487565+05:30	2026-08-19 12:37:28.283252+05:30	\N	2026-08-19 12:37:20.487755+05:30	2026-08-19 12:37:28.283888+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ab2531a4-ddb3-456d-a73d-2b2595d59d6b	40517b71-5e62-182e-73b5-d4070e20a3c2	0cOnEPa0VTwr255Ja9mOj5meF22Q16B6cvwM7dYTRVs=	2026-08-26 11:23:22.904713+05:30	2026-08-20 17:09:07.220747+05:30	\N	2026-08-19 11:23:22.904776+05:30	2026-08-20 17:09:07.290346+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
91d8849b-c19b-4d38-a541-894f3ba3de05	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	6MaPxYU4m6FIJDsbO5KF2JKzevvHNdji26HPWHWKW5c=	2026-08-26 12:37:28.283581+05:30	2026-08-19 13:46:05.718042+05:30	\N	2026-08-19 12:37:28.283888+05:30	2026-08-19 13:46:05.71903+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0d64fbaa-6c2c-4999-afb9-f58591acb7d2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	7e9ZKc2sSiQD9LgoI/BRoA+AYJaVwq2CciEx0Ho5Euc=	2026-08-26 13:46:05.71857+05:30	2026-08-19 13:49:45.842031+05:30	\N	2026-08-19 13:46:05.71903+05:30	2026-08-19 13:49:45.842043+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
459f14c6-905e-4c49-8478-5182110bd0f3	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	Xd5fougKqblrLegIzBlh0n0s+nYXKYd8A+AqrgDf3dU=	2026-08-26 13:49:46.152796+05:30	2026-08-19 13:49:54.634756+05:30	\N	2026-08-19 13:49:46.152897+05:30	2026-08-19 13:49:54.635023+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b3a3354b-f090-4366-b048-9a68c827b995	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	RfPKp/BZ6ps1XeXw4YmMi/pfqwyErL7iTmxnL/q1sfQ=	2026-08-26 13:49:54.63489+05:30	2026-08-19 13:50:02.539678+05:30	\N	2026-08-19 13:49:54.635023+05:30	2026-08-19 13:50:02.539693+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1ee1b738-0c4e-4a6a-97a2-7ae0b5e9d703	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fOFdKVKls9qr5kxoXAua6PMSE7LcVvTDNA5uyIBLSwY=	2026-08-26 13:50:02.844585+05:30	2026-08-19 14:10:37.619729+05:30	\N	2026-08-19 13:50:02.844715+05:30	2026-08-19 14:10:37.621029+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bba60a1a-097e-4af8-a0cd-5622ec01bd79	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NciDn0O37/isZXoAnI58/KGjuSdhlYkMiKhU/QcxWr4=	2026-08-26 14:10:37.620799+05:30	2026-08-19 14:39:54.737594+05:30	\N	2026-08-19 14:10:37.621029+05:30	2026-08-19 14:39:54.738048+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6968ba55-04b1-4bd5-ac96-6f3d560b1c76	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0SwuoUvhuni2Oa3PCiWxkhCiPY2HhNUn8xz6IoH0PHI=	2026-08-26 14:39:54.737873+05:30	2026-08-19 14:41:17.835781+05:30	\N	2026-08-19 14:39:54.738048+05:30	2026-08-19 14:41:17.836084+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a6deb5f2-7e78-4de2-bc72-1f56a5020268	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	S0Cd45ea6MKQIaCYkB75/rHHZzJ26tsDCM3Blk2sS2Q=	2026-08-26 14:41:17.835987+05:30	2026-08-19 15:25:30.115776+05:30	\N	2026-08-19 14:41:17.836084+05:30	2026-08-19 15:25:30.205188+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
19ba4979-f76f-45ca-b451-7406ad1b6bec	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	floYEtcBJKjRNBThsRZ5dYpacg2W6m839CPIPBDaALA=	2026-08-26 15:25:30.181735+05:30	2026-08-19 15:52:54.657196+05:30	\N	2026-08-19 15:25:30.205188+05:30	2026-08-19 15:52:54.658847+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c6e3510b-7f35-47ea-a29f-9ffc084ecedd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tUsbfuJyRzqPpaxCdX4Y4hfaUMSTq6CJ8Meba3u+qr0=	2026-08-26 15:52:54.657559+05:30	2026-08-19 18:30:25.937784+05:30	\N	2026-08-19 15:52:54.658847+05:30	2026-08-19 18:30:25.938973+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
07a76bad-157b-4bf9-9d70-2a0a26145d23	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	X9zeXfX6KqMmESDhgL1uSwvUwZx6m9qMR+uuwR5IoTU=	2026-08-27 10:24:50.419756+05:30	2026-08-20 10:46:31.20644+05:30	\N	2026-08-20 10:24:50.446547+05:30	2026-08-20 10:46:31.20774+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
49a4243f-61e8-4054-8611-f68cbfca0968	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	kCALGA218sOcBaydvQcqE/KgMDS1gEjPLQofVcMU1Lw=	2026-08-27 10:46:31.206878+05:30	2026-08-20 10:46:43.939064+05:30	\N	2026-08-20 10:46:31.20774+05:30	2026-08-20 10:46:43.939079+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
816b84c8-7608-4d5f-90f6-806d09575112	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CyLDNVnl9zrQzoprE4Y5NUZJ7FGci82RlsD+JVLC90o=	2026-08-26 18:30:25.938528+05:30	2026-08-20 10:46:44.236708+05:30	\N	2026-08-19 18:30:25.938973+05:30	2026-08-20 10:46:44.237101+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5d3eeb55-d3ed-43f9-8d83-6061a231fb13	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nRee/Zdqt/CDRpH3i7HBAFJzyJm6Hx+i7fnYb0+bNjg=	2026-08-27 10:46:44.236956+05:30	2026-08-20 10:52:22.429747+05:30	\N	2026-08-20 10:46:44.237101+05:30	2026-08-20 10:52:22.429777+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f65cd211-7aa1-4d81-b516-b3662d8056ff	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	6RDUCa2mc7jdGiFcIFNCYU4FPhVVK0sI97jRHjxjvoM=	2026-08-27 10:52:22.77919+05:30	2026-08-20 10:52:32.534279+05:30	\N	2026-08-20 10:52:22.779324+05:30	2026-08-20 10:52:32.534294+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
548c45c1-2d4e-4a98-aacf-6354970352fd	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	fb8ZP7CvjovY8FLybCjbjdCA9mWAwRDYeUYw+C6Lwzc=	2026-08-27 10:52:32.831805+05:30	2026-08-20 10:52:47.043776+05:30	\N	2026-08-20 10:52:32.831916+05:30	2026-08-20 10:52:47.043976+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
43dea5a3-d549-4ee1-890d-8c7ef918d995	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	1pziPIZn1jTCiuShYprgmDZlUzxvb1xj8ppkw6oyA88=	2026-08-27 10:52:47.043902+05:30	2026-08-20 10:52:49.93762+05:30	\N	2026-08-20 10:52:47.043976+05:30	2026-08-20 10:52:49.937814+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0c97b096-e11b-48c7-acd5-b99cca92fe9c	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	x2+qAQCxrSPBZBshZBm3xVaVBhsSZgeB9fBoxMPLGdA=	2026-08-27 10:52:49.93774+05:30	2026-08-20 10:52:56.99612+05:30	\N	2026-08-20 10:52:49.937814+05:30	2026-08-20 10:52:56.996133+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
18ccbd03-a7ed-4fdf-84a6-829c27ad4fb0	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	YZ5PDDvvf1tLDXhQC/M3+0VgXyg5N2JwBHl+VjVoHtA=	2026-08-27 10:52:57.272417+05:30	2026-08-20 10:53:12.872512+05:30	\N	2026-08-20 10:52:57.272522+05:30	2026-08-20 10:53:12.872525+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7f9e0c00-a810-4255-a162-1efb42c94db0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	pcDIApd6rpkaXgKIWo3Tx8uW2IIGWtMEDj9rSRTPPuE=	2026-08-27 10:53:13.154274+05:30	2026-08-20 10:59:32.052095+05:30	\N	2026-08-20 10:53:13.154383+05:30	2026-08-20 10:59:32.05236+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
befbe1be-9fc1-4751-86bd-3940b1e03556	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	e1F399DSd979chtNINeB7STeeFxaBayB/LReGlbiIYg=	2026-08-27 10:59:32.052281+05:30	2026-08-20 11:19:16.959187+05:30	\N	2026-08-20 10:59:32.05236+05:30	2026-08-20 11:19:16.95942+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f4dd0b9d-7b27-420c-ad9a-2c66efac9c8c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Zy3K8pmLcBkZUzs5FasA3LlenRicPhsm0RtIFICInwI=	2026-08-27 11:19:16.959314+05:30	2026-08-20 11:21:53.859285+05:30	\N	2026-08-20 11:19:16.95942+05:30	2026-08-20 11:21:53.859298+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5bcf54a8-fb74-4a25-b41b-8b0ed066a751	730809c0-fc01-a664-03ca-28e0e32d0393	b/cHDcDKUwOqLz9P9XKptjVpB/17laX9aN+/9lWEBEw=	2026-08-27 11:21:54.14091+05:30	2026-08-20 11:22:08.491146+05:30	\N	2026-08-20 11:21:54.14099+05:30	2026-08-20 11:22:08.491157+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f237fe9c-dc03-445a-83e9-878d66a02609	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4roANFH6n2L0jG6yX6NK2nfXaI5jaUrWYF8cEbZc/Og=	2026-08-27 11:22:08.770248+05:30	2026-08-20 11:24:15.783252+05:30	\N	2026-08-20 11:22:08.770332+05:30	2026-08-20 11:24:15.783569+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
befa7bf8-0288-43e3-b5d9-5b06a2e09936	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nibbgdgBUriZhnW8DU25yW+IGJS3vWA2vDQ/aMgVFeo=	2026-08-27 11:24:15.783486+05:30	2026-08-20 11:39:39.564277+05:30	\N	2026-08-20 11:24:15.783569+05:30	2026-08-20 11:39:39.614405+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
43625dca-2aa9-4dc8-8e48-bc4d6ca27a1a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sDe2OmS28yfI9+CoIdKM6Kpdvk3b9dZinSigssVSzhE=	2026-08-27 11:39:39.611417+05:30	2026-08-20 11:56:46.337242+05:30	\N	2026-08-20 11:39:39.614405+05:30	2026-08-20 11:56:46.338098+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c6dda07d-1152-4198-b0f8-43eeb6204405	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	D8KfQlClXTCpGtq0mQh67v4Mf5T1dDSjkPlDn3Zl+yU=	2026-08-27 11:56:46.337832+05:30	2026-08-20 11:56:47.648411+05:30	\N	2026-08-20 11:56:46.338098+05:30	2026-08-20 11:56:47.648632+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aa0b13f8-a7e3-412c-9151-ebbacc879f49	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SzZa+OtUjpzIACate58YoGFClP1A8IcKXyzRyzWrO68=	2026-08-27 11:56:47.648553+05:30	2026-08-20 11:57:11.032269+05:30	\N	2026-08-20 11:56:47.648632+05:30	2026-08-20 11:57:11.03265+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
13d77c65-eb9f-4950-919c-f458a0dfe69e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2poswNgw18KpevvBY2X+8UyBkzV1p1ZJ1u1ILWvVvTQ=	2026-08-27 11:57:11.032463+05:30	2026-08-20 11:57:29.054438+05:30	\N	2026-08-20 11:57:11.03265+05:30	2026-08-20 11:57:29.054765+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ffd2aef3-bb6a-4991-8611-451e294d7cc9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ySRJiIN40u3RvwTHW7zYGeoDGRuO72em0QQLTg/mx3U=	2026-08-27 11:57:29.054608+05:30	2026-08-20 12:01:20.343464+05:30	\N	2026-08-20 11:57:29.054765+05:30	2026-08-20 12:01:20.343478+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
df5dd2d2-ffbd-4a03-8d3f-2d8336a2c8b5	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	nK7bAecDhbhLHlPlKGhVn+YCxWNgQAdFQzBqJX3aOsU=	2026-08-27 12:01:20.652568+05:30	2026-08-20 12:01:44.723431+05:30	\N	2026-08-20 12:01:20.652716+05:30	2026-08-20 12:01:44.723443+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
91b2ef48-b343-4c11-8742-bfeb3507be83	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	bEcDrQAKYPK6M/WZZFa2qd+vvTi3HT7BJcbBwZ3n/78=	2026-08-27 12:01:45.025348+05:30	2026-08-20 12:01:56.630118+05:30	\N	2026-08-20 12:01:45.025533+05:30	2026-08-20 12:01:56.63081+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1a1c0192-b0ad-48c7-8a2a-21c2ca7fcafc	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	YBPOrfh5JE5Ml20zLpdimGvcg8SjV/Y4DAs+70+vBM8=	2026-08-27 12:01:56.630722+05:30	2026-08-20 12:02:06.680399+05:30	\N	2026-08-20 12:01:56.63081+05:30	2026-08-20 12:02:06.680411+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aa46604a-1ff2-488b-a47a-96bbe65fd3da	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3pJyJfdaeDivsuYUc/wAE3X8x3RLHSpImCX1AoF3KIc=	2026-08-27 12:02:06.996671+05:30	2026-08-20 12:06:21.900097+05:30	\N	2026-08-20 12:02:06.996802+05:30	2026-08-20 12:06:21.900397+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
355a20fe-b394-4c19-9edc-6654a9960e0f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1iFI0cIJwqn0RY87xtEqyFMfH/wBdphtpZqKCQPoGUs=	2026-08-27 12:06:21.900303+05:30	2026-08-20 13:14:33.005985+05:30	\N	2026-08-20 12:06:21.900397+05:30	2026-08-20 13:14:33.006879+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
05f4efd5-4b81-4695-a550-20f8d0f978c9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4m7B67RUb7W4iPHOv7LQ0NLOdomIPX+R/f/B/mDj1VQ=	2026-08-27 13:14:33.006504+05:30	2026-08-20 13:17:36.797128+05:30	\N	2026-08-20 13:14:33.006879+05:30	2026-08-20 13:17:36.797687+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1725fb2a-47e6-4a07-89ba-d80378e93728	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	lD1VjWhNEDVv/rWRDlH49bZzIJOreLMeWCx9/dR11RQ=	2026-08-27 13:17:36.7975+05:30	2026-08-20 13:43:35.343627+05:30	\N	2026-08-20 13:17:36.797687+05:30	2026-08-20 13:43:35.343894+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a9d98629-6dd1-4f9a-9d35-da07bd65e30b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	z6HgFecouAbQXlOR/TTGAJzWgknlDVmLgz/CB7oU85Y=	2026-08-27 13:43:35.343823+05:30	2026-08-20 13:43:39.333837+05:30	\N	2026-08-20 13:43:35.343894+05:30	2026-08-20 13:43:39.334048+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
21211769-dbc7-47b1-aade-13ca799d9266	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	cdPx9fOVQkyyJ2qjv2KSaf2zfhqoqLX5ybT7W3kvsiI=	2026-08-27 13:43:39.333961+05:30	2026-08-20 13:44:09.669258+05:30	\N	2026-08-20 13:43:39.334048+05:30	2026-08-20 13:44:09.730421+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1954f17a-fb2d-468c-b02b-49e13f0a810a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Oq45dXU0o9ToGgYtUPY0vogSVVDpqwgJMr4TQP39SUo=	2026-08-27 13:44:09.71612+05:30	2026-08-20 14:11:48.89982+05:30	\N	2026-08-20 13:44:09.730421+05:30	2026-08-20 14:11:48.901266+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3861efb9-7146-491d-b7fd-60aea1a98766	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5vHBZDd1X6TFLzzwVD55WkxopxqDmuPSPjPkrKMHbnc=	2026-08-27 14:11:48.90015+05:30	2026-08-20 14:26:47.69703+05:30	\N	2026-08-20 14:11:48.901266+05:30	2026-08-20 14:26:47.697366+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1c4f2c1c-3360-4b1c-abac-fbddf1ef6b98	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ePKuajRtz4lrIc/shP20J2n4x9ZvP+e+19VCgRVzK7g=	2026-08-27 14:26:47.6972+05:30	2026-08-20 14:37:30.295971+05:30	\N	2026-08-20 14:26:47.697366+05:30	2026-08-20 14:37:30.296263+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
66f3ba99-2a5f-45d1-8b4b-9b25916e97c2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sO39KYg5oPKsU2ohwr/MMenPCIHvSlbfgYNRDBMkYdY=	2026-08-27 14:37:30.296139+05:30	2026-08-20 15:07:12.275338+05:30	\N	2026-08-20 14:37:30.296263+05:30	2026-08-20 15:07:12.275955+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b7ee7933-9891-4599-9080-ee51e017d067	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eJadRJ4fwlZSFaSgpf4u6aSmlwgbZ6hT+1wB3wgDVtQ=	2026-08-27 15:07:12.275751+05:30	2026-08-20 15:08:10.427303+05:30	\N	2026-08-20 15:07:12.275955+05:30	2026-08-20 15:08:10.465762+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b89bae8e-1d68-42af-95f8-ace5ea08b5c9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	F1lw17pCGiJIR9sLXBJOYP231MP9/3B64i80k4UDOhA=	2026-08-27 15:08:10.451759+05:30	2026-08-20 15:16:12.356907+05:30	\N	2026-08-20 15:08:10.465762+05:30	2026-08-20 15:16:12.357373+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5c426124-e067-4aef-8dd5-13a1d85e2e49	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eXEkkinY5A4Js0c+Gvrln+b/uafy09So70YXZThQTi0=	2026-08-27 15:16:12.357209+05:30	2026-08-20 15:25:39.349092+05:30	\N	2026-08-20 15:16:12.357373+05:30	2026-08-20 15:25:39.349373+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b0858732-938f-444c-9735-1b38367cf593	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tQr44MAXQKd05ibgdff8u7KOGZ+W4+Euj1NpXqJRidw=	2026-08-27 15:25:39.349275+05:30	2026-08-20 15:26:26.692507+05:30	\N	2026-08-20 15:25:39.349373+05:30	2026-08-20 15:26:26.692783+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
70f41315-6892-4c19-93d6-411af374836c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	w9P4SGluG1oZCj9PdTsjhLBep8yiGJ8xMc3cHp/JX4A=	2026-08-27 15:26:26.692671+05:30	2026-08-20 15:28:43.072686+05:30	\N	2026-08-20 15:26:26.692783+05:30	2026-08-20 15:28:43.072984+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cecb327c-f457-4839-b2fa-b8aa6b036709	40517b71-5e62-182e-73b5-d4070e20a3c2	3zLy6TtOST2p1Ii/TMLuuThS/C2M0HTsYxXbFaiwqIY=	2026-08-27 17:09:07.274313+05:30	2026-08-20 17:09:16.328081+05:30	\N	2026-08-20 17:09:07.290346+05:30	2026-08-20 17:09:16.331243+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
986a7c9c-111c-4cf5-b546-f0bd9a8eb31b	40517b71-5e62-182e-73b5-d4070e20a3c2	dR2mWNCuzVOWfDS9eg1fJDg6taNFnnfyz3Pi3On7v1Q=	2026-08-27 17:09:16.329258+05:30	2026-08-20 17:09:29.456306+05:30	\N	2026-08-20 17:09:16.331243+05:30	2026-08-20 17:09:29.456812+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3d6d5f70-7625-4e59-a4b3-53465b39d6bc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	XY/vMiDNyDC8UXlgw3YhdqZWj2VqPz6rcSZcUKZ7N5Y=	2026-08-27 15:28:43.072878+05:30	2026-08-20 17:10:39.638772+05:30	\N	2026-08-20 15:28:43.072984+05:30	2026-08-20 17:10:39.700767+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
91ea98e1-78d0-4743-b555-d315222820fc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BvttgHYh9mhuK9hE82MHTCyqmMS5hlcXLT4DtYVQiww=	2026-08-27 17:10:39.675696+05:30	2026-08-20 17:38:38.581793+05:30	\N	2026-08-20 17:10:39.700767+05:30	2026-08-20 17:38:38.583693+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
465061a7-37a6-40da-859e-07251442ff95	40517b71-5e62-182e-73b5-d4070e20a3c2	9rYdGIaOrO0lGLLDRmF0Axcgjml0KcF//twrhpu50ow=	2026-08-27 17:09:29.456636+05:30	2026-08-20 17:55:03.347202+05:30	\N	2026-08-20 17:09:29.456812+05:30	2026-08-20 17:55:03.394673+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c4528faf-7b2a-444f-99a3-3bf8bdd3bd63	40517b71-5e62-182e-73b5-d4070e20a3c2	Ry7tuR8MtzsgW1j9R5fm47gYE1g4o0wQNcImnIxyd7k=	2026-08-27 17:55:03.387748+05:30	2026-08-20 17:55:14.362821+05:30	\N	2026-08-20 17:55:03.394673+05:30	2026-08-20 17:55:14.363486+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f3e68cd5-10ea-4f73-bc5c-10421b4f2317	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8XEVU3ozUwMt8u5bYfVjXZposfSBQO5E9T7OsTdhn/8=	2026-08-27 17:38:38.582232+05:30	2026-08-20 18:17:10.476276+05:30	\N	2026-08-20 17:38:38.583693+05:30	2026-08-20 18:17:10.512606+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a06f15c6-1feb-4563-a0a5-43a918187b5d	40517b71-5e62-182e-73b5-d4070e20a3c2	AEY0lqZEBfE7x8dS5kyMCUfdZSFvBU3x+LMD+Ug1rew=	2026-08-27 17:55:14.363184+05:30	2026-08-20 18:21:15.34747+05:30	\N	2026-08-20 17:55:14.363486+05:30	2026-08-20 18:21:15.518234+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a9116bba-91bb-4051-ae1e-5a43dc47462b	40517b71-5e62-182e-73b5-d4070e20a3c2	+te74zgZVM0hvUqx8jt9msUw/oiwl7ccOm2wtwpf2RY=	2026-08-27 18:21:15.488629+05:30	2026-08-20 18:21:33.265842+05:30	\N	2026-08-20 18:21:15.518234+05:30	2026-08-20 18:21:33.267916+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
075d5aa2-8751-474a-bd69-56c46a5deeba	40517b71-5e62-182e-73b5-d4070e20a3c2	3Sprvkju0t+Vs+uJNK+wLE9mbIX1XLbEFE6DeYVdc54=	2026-08-27 18:21:33.267005+05:30	2026-08-20 18:27:51.320449+05:30	\N	2026-08-20 18:21:33.267916+05:30	2026-08-20 18:27:51.375579+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0ed7fbeb-28ef-48d8-a511-f0698e02ee98	40517b71-5e62-182e-73b5-d4070e20a3c2	tOuytEfEcKTTLn0QvqCfmw5ox5pbT1rl7AN7kmw7Q6E=	2026-08-27 18:27:51.352159+05:30	2026-08-20 18:28:00.489331+05:30	\N	2026-08-20 18:27:51.375579+05:30	2026-08-20 18:28:00.492443+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
88fe9f44-f142-45a5-bbc0-12bffe612e8f	40517b71-5e62-182e-73b5-d4070e20a3c2	Z95EnrXvNGZ4M4XhaJDv5loW42l69HkjoOpu8jnwIhU=	2026-08-27 18:28:00.490288+05:30	2026-08-20 18:28:09.065827+05:30	\N	2026-08-20 18:28:00.492443+05:30	2026-08-20 18:28:09.066351+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f095ef3d-64bb-4add-b410-b22884eb7c50	40517b71-5e62-182e-73b5-d4070e20a3c2	aOhysexmjF56MHcqSgTxGDc4nMsdVyBdn7x1FfVvxd0=	2026-08-27 18:28:09.066191+05:30	2026-08-20 18:28:18.588921+05:30	\N	2026-08-20 18:28:09.066351+05:30	2026-08-20 18:28:18.589414+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cb6336a9-f358-404f-b025-336f3518b4d6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	LIvtgoQWzmwvGF7BJpR6SybzWZCNlCrQ/Y4RsVc6JsQ=	2026-08-27 18:17:10.499095+05:30	2026-08-20 18:29:49.686441+05:30	\N	2026-08-20 18:17:10.512606+05:30	2026-08-20 18:29:49.843329+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
027c5539-18c0-45f6-ae7d-3eef19d778eb	40517b71-5e62-182e-73b5-d4070e20a3c2	40WbjJ7ZVr13T6NlmcxW/Z1GGVmVGC2TsJpH39svk9o=	2026-08-27 18:28:18.589255+05:30	2026-08-20 18:38:52.512445+05:30	\N	2026-08-20 18:28:18.589414+05:30	2026-08-20 18:38:52.61241+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
916612ba-eea9-4777-84f4-a1f8f05ea675	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rF35vDwojlbHELc656O9k5PQrhdieL2EKSnPAu14Ho8=	2026-08-27 18:29:49.77799+05:30	2026-08-20 18:39:53.334192+05:30	\N	2026-08-20 18:29:49.843329+05:30	2026-08-20 18:39:53.49059+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b6569287-c5f6-4d88-9533-e6c89d7ac4e9	40517b71-5e62-182e-73b5-d4070e20a3c2	BzG7eGNQuhKbbwShL3aqTBkWaVaimOiMCYshBMEfUH0=	2026-08-27 18:38:52.568079+05:30	2026-08-20 18:48:11.608328+05:30	\N	2026-08-20 18:38:52.61241+05:30	2026-08-20 18:48:11.667575+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dca001d4-f0e9-449c-8182-55f946c36756	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+T72G5ikcOyvFVtgo/53ewQ/DcrxI/UA25ZQsCe5B/E=	2026-08-27 18:39:53.429091+05:30	2026-08-20 18:50:41.663288+05:30	\N	2026-08-20 18:39:53.49059+05:30	2026-08-20 18:50:41.75561+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
90bb4fe6-b24f-4466-b0b6-d1395d508715	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YxLGj8BKXWxM3IWmpeVQnIkda9cklhBwaeaE0ks2Q6M=	2026-08-27 18:50:41.726215+05:30	2026-08-20 19:54:37.369534+05:30	\N	2026-08-20 18:50:41.75561+05:30	2026-08-20 19:54:37.370064+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1e1dc715-b6b1-4358-93dd-afadd452f21d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	6dQHHltS9WkOKUcoXD7PGMTNqzCIE+S/xrhPqJxgwt8=	2026-08-27 19:54:37.369863+05:30	2026-08-21 10:41:11.936452+05:30	\N	2026-08-20 19:54:37.370064+05:30	2026-08-21 10:41:11.937611+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
77828064-53a5-4e5b-941b-94d8eef0ed91	40517b71-5e62-182e-73b5-d4070e20a3c2	r5kPYR2nTjzE9RyYh5Ddgz+opppRX5cFPqQuNzG1HrQ=	2026-08-27 18:48:11.644995+05:30	2026-08-21 10:51:39.09619+05:30	\N	2026-08-20 18:48:11.667575+05:30	2026-08-21 10:51:39.161314+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0599d66b-0640-404e-b305-c701b1ed5bd5	40517b71-5e62-182e-73b5-d4070e20a3c2	tqAnySY58YIJ6NPfI9Fuq3jWp80Ooi/mJpkjrfGIewc=	2026-08-28 10:51:39.146833+05:30	2026-08-21 10:51:44.762235+05:30	\N	2026-08-21 10:51:39.161314+05:30	2026-08-21 10:51:44.763575+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6c053081-0329-419c-ade5-1f810d8b954c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HjXdiAnZFcE3XF7kgeB6UOYp5PrsiCD/zX8qlSGmjw0=	2026-08-28 10:41:12.430875+05:30	2026-08-21 10:55:20.946787+05:30	\N	2026-08-21 10:41:12.44118+05:30	2026-08-21 10:55:20.987635+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
238868d0-2d58-4a15-b823-a38155048433	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	c+LMoI0qIs1s0y7UBVUIiiaTsS4Hh7gRsSwKxhjdSUU=	2026-08-28 10:55:20.972286+05:30	2026-08-21 10:58:15.646781+05:30	\N	2026-08-21 10:55:20.987635+05:30	2026-08-21 10:58:15.648214+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8306fea7-db4c-4720-91f7-6fb9766a1b49	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4TQuaPhBZWYe79Rxv9BpLq1gmOmp33AbDPRe5QdgN6I=	2026-08-28 10:58:15.647095+05:30	2026-08-21 11:25:43.885138+05:30	\N	2026-08-21 10:58:15.648214+05:30	2026-08-21 11:25:43.899675+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2278d2fe-6950-4c43-928a-1b06f1c0be4a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	VmrfmmqvMGzuufpo7esS2BAXBzgWp8MikKHD5EExaEM=	2026-08-28 11:25:43.895358+05:30	2026-08-21 11:26:04.663605+05:30	\N	2026-08-21 11:25:43.899675+05:30	2026-08-21 11:26:04.664106+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
19f02dd9-e5f9-4d2e-82d3-eb292aa2fbc5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	389YSNnwo1VeDHToBrsE2VAKJbeI68nxt9xCSnuK2DI=	2026-08-28 11:26:04.663966+05:30	2026-08-21 11:26:05.665341+05:30	\N	2026-08-21 11:26:04.664106+05:30	2026-08-21 11:26:05.665747+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
56538167-1be4-4ed7-ad96-e435cdc8f157	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xjG9q92aCIU6ghJymVon7mhsTLoJMK4fC9ho9dsjLek=	2026-08-28 11:26:05.665599+05:30	2026-08-21 11:27:05.386329+05:30	\N	2026-08-21 11:26:05.665747+05:30	2026-08-21 11:27:05.386625+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fa9e621b-138b-4a8a-8d7f-150c85a1ff4b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+rk5ZnwDAoMNBZd/lPnB3LoGl97RAm9IJXg0AYFXVH4=	2026-08-28 11:27:05.386514+05:30	2026-08-21 11:28:07.22071+05:30	\N	2026-08-21 11:27:05.386625+05:30	2026-08-21 11:28:07.220987+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1050e771-08cf-4c7b-9161-4f203e24c57d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4EEVpwMgbGzz5VxtukVr0nJTOF1TDGvLxxz8qtdSmpw=	2026-08-28 11:28:07.220907+05:30	2026-08-21 11:29:38.648888+05:30	\N	2026-08-21 11:28:07.220987+05:30	2026-08-21 11:29:38.649154+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e0df4f1d-4460-45a6-8ef5-e19c8d6a9ae5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	FzgXooh2Th+xn3oZlwK4W1Lg+F2tRxVqmls0A5mxOTY=	2026-08-28 11:29:38.649074+05:30	2026-08-21 11:31:16.953901+05:30	\N	2026-08-21 11:29:38.649154+05:30	2026-08-21 11:31:16.954725+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2c296133-3f36-4666-82ce-712a10d48aca	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BMRPlR0p33l3kdYj81JsrkJVUUsh9YYlm9woQQgf30c=	2026-08-28 11:31:16.954608+05:30	2026-08-21 11:38:08.292535+05:30	\N	2026-08-21 11:31:16.954725+05:30	2026-08-21 11:38:08.340073+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7dcdd696-db39-40f1-9dc8-8bb2bec80d25	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	RLs+MW4+aWJM7ERqQjwAQNG8sCWZTrXW3aXUz14Bfm4=	2026-08-28 11:38:08.320956+05:30	2026-08-21 11:38:21.483237+05:30	\N	2026-08-21 11:38:08.340073+05:30	2026-08-21 11:38:21.484295+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3dc5fb8c-b39b-4796-a2c0-6157847c3eab	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fRQMFfoembKwfGC2tNtvvsNYgpaplP82G/gspJB0kzo=	2026-08-28 11:38:21.483629+05:30	2026-08-21 11:38:22.485639+05:30	\N	2026-08-21 11:38:21.484295+05:30	2026-08-21 11:38:22.485864+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
11e91f68-3f8c-46c8-a511-9b0ef2039205	40517b71-5e62-182e-73b5-d4070e20a3c2	Xjp9Jp7IGSLyk81RMsa4IpH35QCJ0N5Pk4cTUbvrokA=	2026-08-28 10:51:44.762699+05:30	2026-08-21 11:51:18.975465+05:30	\N	2026-08-21 10:51:44.763575+05:30	2026-08-21 11:51:19.00936+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
873f2a5e-fed8-4a86-8d13-dad33de17b5c	40517b71-5e62-182e-73b5-d4070e20a3c2	jwOFEEmzZV1NRB5reYHbOmr7PvzTWDF98m5IveVtjf8=	2026-08-28 11:51:18.996436+05:30	2026-08-21 11:51:24.062247+05:30	\N	2026-08-21 11:51:19.00936+05:30	2026-08-21 11:51:24.063461+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
470f1775-74d0-4675-9876-d30c20bd33a4	40517b71-5e62-182e-73b5-d4070e20a3c2	HambJ7BGsdjaWe27pW4WTIBvCKr2Fmy1afMNw2OpMLA=	2026-08-28 11:51:24.06266+05:30	2026-08-21 11:51:28.781372+05:30	\N	2026-08-21 11:51:24.063461+05:30	2026-08-21 11:51:28.781771+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c6027f46-82ba-4bfe-9af8-9d8a4acee77e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	RYS4VHGJ1dP0AdaiMbXqHg8+AqVzLCZC9fy1HCMaNgs=	2026-08-28 11:38:22.485782+05:30	2026-08-21 11:56:04.448974+05:30	\N	2026-08-21 11:38:22.485864+05:30	2026-08-21 11:56:04.470537+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
be85a87f-1bb6-4475-85f9-cb1f281de97a	40517b71-5e62-182e-73b5-d4070e20a3c2	nvEe8R45FUYsrOuGp2tIIE6M3q+KA1RgMZiDiW3pMbE=	2026-08-28 11:51:28.781654+05:30	2026-08-21 11:51:33.376751+05:30	\N	2026-08-21 11:51:28.781771+05:30	2026-08-21 11:51:33.377009+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c1f7b1e2-a73b-4b6c-b294-530e218aee5c	40517b71-5e62-182e-73b5-d4070e20a3c2	cjr0kSWVJFlsDkHdCqa9S7bLV7TT2RgGPUTV5ctfAWg=	2026-08-28 11:51:33.37693+05:30	2026-08-21 11:51:37.975206+05:30	\N	2026-08-21 11:51:33.377009+05:30	2026-08-21 11:51:37.975497+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
987ee536-151d-47e7-be75-fd3ac5e472f5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	gTeh3cqMveF5yemDod73xB1ICWr4So0K0NDTJuMgAyo=	2026-08-28 11:56:04.457552+05:30	2026-08-21 11:56:10.677701+05:30	\N	2026-08-21 11:56:04.470537+05:30	2026-08-21 11:56:10.680216+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5abc56c2-ae85-4927-8363-d666f116a86d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Gq7kFqR/xBYj1N+P2Sp+urPCLLKoo+H5DXMIG+avrqU=	2026-08-28 11:56:10.678333+05:30	2026-08-21 12:01:19.339085+05:30	\N	2026-08-21 11:56:10.680216+05:30	2026-08-21 12:01:19.339407+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
756e0513-10b3-4324-b42a-880e4744f278	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qc2+ZoX9Q4AKfoMSCp8NVdVve4aG+muCJKVsMMA+R7A=	2026-08-28 12:01:19.339276+05:30	2026-08-21 12:01:22.102641+05:30	\N	2026-08-21 12:01:19.339407+05:30	2026-08-21 12:01:22.103419+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1bca2c27-11dd-4fb8-877a-ab32b2b14f7c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	VZyfNFzvXm1JT+YzP4/sV2XFcHvdpEGsKeY1+bZjE90=	2026-08-28 12:01:22.102926+05:30	2026-08-21 12:01:26.120079+05:30	\N	2026-08-21 12:01:22.103419+05:30	2026-08-21 12:01:26.120384+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d7d9292d-f491-4e7f-befe-7f73eb31b348	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	gge5pEtBRfv1LAjwxhjkFIQbuI/OMmSO8yQ8+b2DOrY=	2026-08-28 12:01:26.12029+05:30	2026-08-21 12:01:33.745793+05:30	\N	2026-08-21 12:01:26.120384+05:30	2026-08-21 12:01:33.746156+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
81cfc8f2-1662-441a-baf0-69574ef00e3b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Vyv7BgX3tU0HB7WgwQxBZ/dfTS5Odrt+HqcPzoFHbbE=	2026-08-28 12:01:33.746063+05:30	2026-08-21 12:01:43.017089+05:30	\N	2026-08-21 12:01:33.746156+05:30	2026-08-21 12:01:43.017914+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
64229a1a-56e8-44b0-accd-94d81b0efe18	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	j0Or/SV3CH8faKfR2j6Yrx6aMzw8PW/0X0qZU+ZiFMI=	2026-08-28 12:01:43.017785+05:30	2026-08-21 12:01:59.463423+05:30	\N	2026-08-21 12:01:43.017914+05:30	2026-08-21 12:01:59.463802+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8d5837f5-dbc1-4423-8ae2-97d4358aca89	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bx5OFf/RvVpsNVtNRHX0dZm7IAICmi+4PWRGy1c1ysU=	2026-08-28 12:01:59.463683+05:30	2026-08-21 12:06:09.423238+05:30	\N	2026-08-21 12:01:59.463802+05:30	2026-08-21 12:06:09.423736+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
279927ba-cbd0-40d0-9de5-6ae418424420	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	h9HVCJVWZp780TJ5BLnGNNFxZUaSIMeHRwtX7dR931E=	2026-08-28 12:06:09.423582+05:30	2026-08-21 12:06:14.75644+05:30	\N	2026-08-21 12:06:09.423736+05:30	2026-08-21 12:06:14.756689+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d4273aa9-23e1-4f31-aec4-d70ca5333673	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	k0eFwtrkyx5g2aCDvke8zQoOQnPLK+d1k0shynqPZ7I=	2026-08-28 12:06:14.756583+05:30	2026-08-21 12:06:31.720672+05:30	\N	2026-08-21 12:06:14.756689+05:30	2026-08-21 12:06:31.720901+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9d5093c7-2c83-4d41-a657-34f93211e474	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	g8KkCi8RYkhbpFuPfTUo4Ew9Ei/+/4XN0HKQ8T1IMn8=	2026-08-28 12:06:31.72081+05:30	2026-08-21 12:16:17.921822+05:30	\N	2026-08-21 12:06:31.720901+05:30	2026-08-21 12:16:17.922445+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
259a31c8-d9d9-4bc5-9def-c1137b74720d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4VDuFl24Zhk2QYlVfK+Wh10l3TYXFDXT7rOQZfRKfJA=	2026-08-28 12:16:17.922204+05:30	2026-08-21 12:17:06.36368+05:30	\N	2026-08-21 12:16:17.922445+05:30	2026-08-21 12:17:06.36397+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bd8fae92-3c26-42f3-90fe-b06c8fa15254	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	gyk6sU9BqAWgSfwjepNDfETfWWWGqONq9MSs/+crFjw=	2026-08-28 12:17:06.363827+05:30	2026-08-21 12:51:26.070233+05:30	\N	2026-08-21 12:17:06.36397+05:30	2026-08-21 12:51:26.169632+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
456acd1b-3737-4bc8-a0a2-a4cf6993add9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	QMCfWBATRFxu0tVLz8EllZ6dSFvAYKDe/zqWttk7PQ0=	2026-08-28 12:51:26.153677+05:30	2026-08-21 12:52:44.125443+05:30	\N	2026-08-21 12:51:26.169632+05:30	2026-08-21 12:52:44.12734+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6101e27f-5bf8-4026-98ec-6263b5be20cb	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	lGJ/egLqWvNYkrseSlUy1d3qhpiWJGvzQRvup6oVRtE=	2026-08-28 12:54:18.433794+05:30	2026-08-21 12:54:50.30453+05:30	\N	2026-08-21 12:54:18.433922+05:30	2026-08-21 12:54:50.304551+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fdd46d8f-4679-4d87-b5e6-ccea047114d4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	dq9aP/BsB3bUnnjfvIECblL6eZSRAcLX8nYKIlIO0bs=	2026-08-28 12:52:44.12589+05:30	2026-08-21 12:54:50.704002+05:30	\N	2026-08-21 12:52:44.12734+05:30	2026-08-21 12:54:50.704388+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
82098bf8-bff7-4907-957f-aba21abdc0f7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Ru4cnbeKJVkUBDYSaofUu45nsAbwmE5LpV+QbDskvPg=	2026-08-28 12:54:50.704227+05:30	2026-08-21 12:55:19.350804+05:30	\N	2026-08-21 12:54:50.704388+05:30	2026-08-21 12:55:19.3512+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c3ec8254-2af3-4dd3-9a4b-64f9ff9e4a85	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	N0XiiUVLG1sa0tsM2q6U8PRn8UksLfEBRgcWHiiDslI=	2026-08-28 12:55:19.351033+05:30	2026-08-21 12:56:43.860434+05:30	\N	2026-08-21 12:55:19.3512+05:30	2026-08-21 12:56:43.860453+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5d0c6621-7ea1-4b50-b74d-607b7336d7fd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	b/1qwao5G4Ho/urp46yo7UxXCiIZggs5q6rsKVBMhvc=	2026-08-28 12:56:44.127404+05:30	2026-08-21 13:04:39.905083+05:30	\N	2026-08-21 12:56:44.127508+05:30	2026-08-21 13:04:39.905346+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
09078517-fa6c-463a-9558-3a4675807194	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Dj5OwJrJSLRWIjgbNjtAxUF5p+5/BFHxK0iOlsqJxuk=	2026-08-28 13:04:39.905246+05:30	2026-08-21 13:08:22.344483+05:30	\N	2026-08-21 13:04:39.905346+05:30	2026-08-21 13:08:22.344506+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
981c0b8c-517c-48f5-9a74-f34acc945efe	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	D++ULv/dx/W/bTMU/OZVtw9PWmYmw+rEejiaeYCJksw=	2026-08-28 13:08:22.689183+05:30	2026-08-21 13:08:22.848084+05:30	\N	2026-08-21 13:08:22.689295+05:30	2026-08-21 13:08:22.848349+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d8f61d12-00f3-4bc3-88ac-8ba744c48593	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vdop+6qmU/k/ERPZQM1mLGYFkic6LLmQEqxPOe2jrHY=	2026-08-28 13:08:22.84827+05:30	2026-08-21 13:10:53.184238+05:30	\N	2026-08-21 13:08:22.848349+05:30	2026-08-21 13:10:53.184257+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b9abc560-3a7e-416c-9b22-02f032a8070f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	hZWmbYhJqy8BPzixyo1Wf01h98duLdJQZpjesDezH7s=	2026-08-28 13:10:53.538584+05:30	2026-08-21 13:10:53.569865+05:30	\N	2026-08-21 13:10:53.538729+05:30	2026-08-21 13:10:53.570113+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6b1073a4-baa2-4747-acaa-16054a78a832	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PtkLzxxm7Xu9b3yKVC8RR0Qi1m8Makn9CG+uLy0pXdo=	2026-08-28 13:10:53.57002+05:30	2026-08-21 13:10:55.389926+05:30	\N	2026-08-21 13:10:53.570113+05:30	2026-08-21 13:10:55.389944+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
47b45b61-f3ef-4ddd-bd77-27072b4d45a6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SOJGT5tGRn9JasLHm0hxw8B4Gj++8KFPX73DqQTaVfc=	2026-08-28 13:10:55.695417+05:30	2026-08-21 13:10:55.761053+05:30	\N	2026-08-21 13:10:55.695512+05:30	2026-08-21 13:10:55.761272+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cc3623d6-d71b-4386-a3cd-d2376bf6ad1e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uaeNVSpFUWL0Jxnky6yjHfTsaTkQXSoicmieiJuI460=	2026-08-28 13:10:55.761197+05:30	2026-08-21 13:15:22.736494+05:30	\N	2026-08-21 13:10:55.761272+05:30	2026-08-21 13:15:22.736515+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3a98deaa-010d-41d5-a663-77e082ad8063	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sEMhqRxYVGSKwx8uNMq0IQS0VYVYiF7oeUPm6Nk0VgE=	2026-08-28 13:15:23.082302+05:30	2026-08-21 13:15:47.91884+05:30	\N	2026-08-21 13:15:23.082388+05:30	2026-08-21 13:15:47.919146+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a2891299-dded-4132-a6c3-ae38c76d0818	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	THS/cJWb7O+PsdN4ZtHZrP8s8sP1Lt4sUfcY6E20bZo=	2026-08-28 13:15:47.919068+05:30	2026-08-21 13:17:29.784995+05:30	\N	2026-08-21 13:15:47.919146+05:30	2026-08-21 13:17:29.785281+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6cd9b195-26f1-4735-9258-803921acc4f8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	cz5XUUHMRViQSIr6iN0F3KMfSvmtgLdwygf2vz/BJ/E=	2026-08-28 13:17:29.785175+05:30	2026-08-21 13:34:40.89184+05:30	\N	2026-08-21 13:17:29.785281+05:30	2026-08-21 13:34:40.940327+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
33422ad5-5f96-434e-aa2c-af31049bc7b9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nh0TSpa8IMfTviy4yt57afbqzAWkCHgDj+j6+HtYLqY=	2026-08-28 13:34:40.919537+05:30	2026-08-21 13:36:19.914115+05:30	\N	2026-08-21 13:34:40.940327+05:30	2026-08-21 13:36:19.951673+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5c34f6b4-5cc6-4daf-9fda-5beeaad92303	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0XMWC0ZdvRamfFk2HBtqpVuRMAGgkgTxNAWORFSWrvw=	2026-08-28 13:36:19.937128+05:30	2026-08-21 14:00:49.986435+05:30	\N	2026-08-21 13:36:19.951673+05:30	2026-08-21 14:00:50.015844+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eeac3333-1087-46df-b584-e06073585df4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/zyKZMxg4FL2nubO6HVz9u60eY4go1SzIJ18U1NuBE4=	2026-08-28 14:00:50.010949+05:30	2026-08-21 14:01:01.573311+05:30	\N	2026-08-21 14:00:50.015844+05:30	2026-08-21 14:01:01.574035+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9fc23122-a225-4117-8519-046e9f6397c0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uluZJt6xIl3BwnQCzhZpPcI//AEvO0qSiU3EjquxtGs=	2026-08-28 14:01:01.573889+05:30	2026-08-21 14:22:16.644074+05:30	\N	2026-08-21 14:01:01.574035+05:30	2026-08-21 14:22:16.644088+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fbddbf59-402d-4553-addd-80063d0ca640	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	14aCBzgS+HpGVQRDKD2QUJazX8uE04TG80wFEHJo6dk=	2026-08-28 14:22:16.935474+05:30	2026-08-21 14:22:25.752409+05:30	\N	2026-08-21 14:22:16.935729+05:30	2026-08-21 14:22:25.752421+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e4498769-e805-48fb-9278-c6b2a14be681	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	oIFe4z5rzdGbSX1aNlIzA/9foesy6BsGGjSyBi2FUc8=	2026-08-28 14:22:26.04929+05:30	2026-08-21 14:27:05.669535+05:30	\N	2026-08-21 14:22:26.04942+05:30	2026-08-21 14:27:05.669573+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
53f09124-e876-4681-98c7-6078538336bd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tU0tytLgHYNwcV1kCyVyihGeNxXJxqJUSWSrFpLXPnc=	2026-08-28 14:27:06.025117+05:30	2026-08-21 14:27:06.333994+05:30	\N	2026-08-21 14:27:06.025257+05:30	2026-08-21 14:27:06.334353+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bbf7ccba-1069-4d13-89fe-33f7805e04a2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xR8dbkda93AUKtNLWp25cyIk828O7blLFxFkkT7GRVA=	2026-08-28 14:27:06.334228+05:30	2026-08-21 14:29:23.538867+05:30	\N	2026-08-21 14:27:06.334353+05:30	2026-08-21 14:29:23.573404+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a83a1e87-80a7-4503-8f58-2c97397a54e1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+TmJp3U+Bd7XAijBQ/BjUu9R11eEBsFnb9qVYTsv3qI=	2026-08-28 14:29:23.560229+05:30	2026-08-21 14:32:12.560757+05:30	\N	2026-08-21 14:29:23.573404+05:30	2026-08-21 14:32:12.560781+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a1ca6e83-19ab-47d9-ad69-60061d17827a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	i0xAWBQJwKxDD7G105nTy1B1nRsXcSwTfyQ99z1fiR4=	2026-08-28 14:32:12.834053+05:30	2026-08-21 15:05:06.144071+05:30	\N	2026-08-21 14:32:12.834751+05:30	2026-08-21 15:05:06.167438+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0a7ab51b-5976-49e0-b364-139333fe7e58	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vW5YoaN6rZD3BM0pVjSBhB3W1CoQz2nF3zilVb1vwes=	2026-08-28 15:05:06.154332+05:30	2026-08-21 15:05:14.813051+05:30	\N	2026-08-21 15:05:06.167438+05:30	2026-08-21 15:05:14.814048+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
95ebaf5d-69c0-4f01-8f7b-78956a9909d1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	XMtNzIvHj5xiO2Ysf5BdgP7NxUbn0gaGNBjkdH0hkCI=	2026-08-28 15:05:14.813254+05:30	2026-08-21 16:29:50.698892+05:30	\N	2026-08-21 15:05:14.814048+05:30	2026-08-21 16:29:50.699283+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a0aebe9e-471e-4516-ad8a-b4545ad9969f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SFJVwpDHOBVi8OAEMqEiOU/Hn/jL40HXksqM5ojIAKw=	2026-08-28 16:29:52.901861+05:30	2026-08-21 16:29:53.128556+05:30	\N	2026-08-21 16:29:52.902882+05:30	2026-08-21 16:29:53.128576+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
121f839e-b03f-4e04-80f8-ea8e83243f75	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4VGUSUvUZNO1+WtZrYFr8YWe2m0RR26zHBD0Qua5/5Y=	2026-08-28 16:29:54.289016+05:30	2026-08-21 16:58:44.956739+05:30	\N	2026-08-21 16:29:54.289291+05:30	2026-08-21 16:58:45.009172+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
696eaaf7-55f5-42c5-abba-09215fa7a77d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	VH5KM98YMgydYLnVF14EcD8+nE4OABzknaaXYdWCbL8=	2026-08-28 16:58:44.988141+05:30	2026-08-21 17:37:08.133091+05:30	\N	2026-08-21 16:58:45.009172+05:30	2026-08-21 17:37:08.201891+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bc55d6d5-9ac0-411f-9700-a10642154e80	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yr4LdREvX24a/eDSjlHXEF2vW3uslLcaKcdqgxofONo=	2026-08-28 17:37:08.173874+05:30	2026-08-21 17:50:45.21947+05:30	\N	2026-08-21 17:37:08.201891+05:30	2026-08-21 17:50:45.220722+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fd51c301-496a-49d0-b8d4-ce0f9ac7436c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uaTDuoA1EKZDjd6pLVcMTd8ym6KQzroRF3BUH8DpcVs=	2026-08-28 17:50:45.219749+05:30	2026-08-21 22:14:11.513173+05:30	\N	2026-08-21 17:50:45.220722+05:30	2026-08-21 22:14:11.513622+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
36f78caf-82bd-4622-93c0-e8b84c40c324	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	i1pSLRo3IomL1fIZCv5b+1Ado/VO/w8som9tjRJNjwo=	2026-08-28 22:14:07.063834+05:30	2026-08-21 22:14:11.265326+05:30	\N	2026-08-21 22:14:07.072163+05:30	2026-08-21 22:14:11.265427+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6361d004-adca-4415-b3ea-54adebcb45c0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YyxvWFS5f48TkO36BOOiGrxPUwylijfvKy6dtGqyMr8=	2026-08-28 22:14:11.513377+05:30	2026-08-21 22:15:24.64354+05:30	\N	2026-08-21 22:14:11.513622+05:30	2026-08-21 22:15:24.64357+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
73ad424b-313d-4f88-a383-732517001113	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	wRb9Fuq96HgCOLsh4ZBrHx/O2a1uLX4eSi/eLXCqrCY=	2026-08-28 22:15:24.912611+05:30	2026-08-21 22:15:41.944072+05:30	\N	2026-08-21 22:15:24.912703+05:30	2026-08-21 22:15:41.944099+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
12b3b983-fb1a-4894-9baf-0906e1045092	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	gqCUpWIoEJIc6NkItrLKSy7wGgcV0K7xoBvdKYTlTxs=	2026-08-28 22:15:42.22899+05:30	2026-08-21 22:26:25.768887+05:30	\N	2026-08-21 22:15:42.229084+05:30	2026-08-21 22:26:25.769324+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ffcdf4b6-544e-4a8a-b4ac-9c91f983ce49	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TUfHft3yPMeXwg8oy6TBAOBoyMRMyiYeZ+XLx1EC/Lo=	2026-08-28 22:26:25.769184+05:30	2026-08-21 22:28:41.84208+05:30	\N	2026-08-21 22:26:25.769324+05:30	2026-08-21 22:28:41.842378+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a922a8ad-5543-4880-9b89-4eaf47b91a2e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ZvMWRWFBFBOSyOKviBVRXkbkjI/CwLLGdFPAXzzYM2w=	2026-08-28 22:28:41.842274+05:30	2026-08-21 22:29:08.651372+05:30	\N	2026-08-21 22:28:41.842378+05:30	2026-08-21 22:29:08.652417+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
08f66602-d863-473a-afab-fbe72f53e7b4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eoGo2A4LDab8RkqLvkVeEpjgT6vXu7maybKL8lEvUxI=	2026-08-28 22:29:08.652119+05:30	2026-08-21 23:04:46.777543+05:30	\N	2026-08-21 22:29:08.652417+05:30	2026-08-21 23:04:46.779812+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
146be78d-1c05-4286-865f-7028c005a4a3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NCjQIwLQ9w6NPWh8aG2mO1ffaZxvOzCEhUfyQv0+SDk=	2026-08-28 23:04:46.779376+05:30	2026-08-21 23:53:23.965424+05:30	\N	2026-08-21 23:04:46.779812+05:30	2026-08-21 23:53:23.966722+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
794b4692-22e0-4eda-9290-858ba2538832	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eNYgNhQWcM59lYomI1ZAHX/YkGe6qq7QTurmDUrmLSc=	2026-08-28 23:53:23.966243+05:30	2026-08-21 23:59:52.319345+05:30	\N	2026-08-21 23:53:23.966722+05:30	2026-08-21 23:59:52.328113+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9be8b6ba-1f85-4027-89e0-89326a28117b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HjHJQghUlF4k5EEXIW7vD4fag6gSaHFLi4WWqiw+VfQ=	2026-08-29 11:25:47.515373+05:30	2026-08-22 11:58:17.860566+05:30	\N	2026-08-22 11:25:47.51565+05:30	2026-08-22 11:58:17.874674+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dc87d396-0874-4ff5-ae32-c8b2a4280fdc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	90ZQxe5bYSNLKEafIjIcaweUsBN0UtDU3aIozcRzhVc=	2026-08-28 23:59:52.323595+05:30	2026-08-22 00:07:39.862253+05:30	\N	2026-08-21 23:59:52.328113+05:30	2026-08-22 00:07:39.863271+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1e0ce1ac-6f9c-414a-8a77-dc1c4d1b3115	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qrSA7SjigRIJ2HtX4V2gYA1OP5ivczuvX7WXsKPZ04o=	2026-08-29 00:07:39.862529+05:30	2026-08-22 00:12:26.568489+05:30	\N	2026-08-22 00:07:39.863271+05:30	2026-08-22 00:12:26.569922+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3f36e699-4bf5-4e28-ba53-006c291cfcc3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xtZyGkidTG4pMY8LXdeYt0U03DK8XH+aGo/C+XKBYBI=	2026-08-29 00:12:26.56925+05:30	2026-08-22 00:12:26.591675+05:30	\N	2026-08-22 00:12:26.569922+05:30	2026-08-22 00:12:26.591848+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eed20a06-948c-48cc-b808-1a3dccb37d8c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	kDT1ViMUM/9YLThxw/NsNdii6g6vnoEdOBMnV5We+LM=	2026-08-29 00:12:26.591785+05:30	2026-08-22 00:34:39.361956+05:30	\N	2026-08-22 00:12:26.591848+05:30	2026-08-22 00:34:39.364511+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1fbccd59-468c-43cc-ac9d-672bda518373	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	F54pXs5SBEb0xqCwqIH+jIsNC39vj3GgKC39BdIC2R0=	2026-08-29 00:34:39.364037+05:30	2026-08-22 00:42:16.243304+05:30	\N	2026-08-22 00:34:39.364511+05:30	2026-08-22 00:42:16.259357+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d9c52b8b-8e58-4ea6-b2fd-2ca72f4dab15	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1Amn2ovPj652YrJMnKloLckITQ20ILT1kbd/ma2ou5o=	2026-08-29 00:42:16.256325+05:30	2026-08-22 00:52:51.395163+05:30	\N	2026-08-22 00:42:16.259357+05:30	2026-08-22 00:52:51.395779+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2ac137b4-e43b-429f-8615-7d78707c354f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TzQJtXzqydcylYR9n+UoQqE4ETn+hbLxL4YEwyEBkjY=	2026-08-29 00:52:51.395571+05:30	2026-08-22 10:34:10.080698+05:30	\N	2026-08-22 00:52:51.395779+05:30	2026-08-22 10:34:10.088856+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d04b71ab-577a-4429-a3c8-644a1b333495	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BusjdmdM3jgXDdYwKH9Jl8x/69c7BEm+KP3IBu+OBJE=	2026-08-29 10:34:10.087843+05:30	2026-08-22 10:57:40.421776+05:30	\N	2026-08-22 10:34:10.088856+05:30	2026-08-22 10:57:40.434407+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
761347ac-0c68-428a-bc31-beb56b573c42	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	XtCOt1XHh7DlZ0I68SdaNsw/Q3ZQCzehnzEqL3kOwgQ=	2026-08-29 10:57:40.430217+05:30	2026-08-22 11:04:40.710189+05:30	\N	2026-08-22 10:57:40.434407+05:30	2026-08-22 11:04:40.715259+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c0581efc-09e6-45fe-9e29-7b766c7df408	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	hzjdNIPFwXuWLfVcl9HBujxVIL1BsUvqhVbv80ukPvc=	2026-08-29 11:04:40.712979+05:30	2026-08-22 11:11:16.429178+05:30	\N	2026-08-22 11:04:40.715259+05:30	2026-08-22 11:11:16.430025+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6295fa3f-e6af-436f-8620-2afb7932e069	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rpjJVZNqABk+YGxFYWXuMcYZnq8I9Ei8t6seTKkO8E8=	2026-08-29 11:11:16.429649+05:30	2026-08-22 11:11:44.935047+05:30	\N	2026-08-22 11:11:16.430025+05:30	2026-08-22 11:11:44.935395+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
edc8a465-5c3b-47d8-acf2-676cdb0d3d83	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0izwIG3Ew3BhRpmmjq/XjcBXtkxV21ZGoZNY4C1Bi+o=	2026-08-29 11:11:44.935244+05:30	2026-08-22 11:25:47.514976+05:30	\N	2026-08-22 11:11:44.935395+05:30	2026-08-22 11:25:47.51565+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e3c3c71f-882e-4995-bd4e-4dd3c061dc3a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	mRtoJeEt7emELWtIsnwCDJPG7KQSgDWfw4Yad3tG+bQ=	2026-08-29 11:58:17.868176+05:30	2026-08-22 12:06:29.686572+05:30	\N	2026-08-22 11:58:17.874674+05:30	2026-08-22 12:06:29.687523+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9d19c141-d9c5-425d-bb7a-eed830231768	40517b71-5e62-182e-73b5-d4070e20a3c2	bqPpTT6VJ4epYUU6JDxsphMmYQXbCRreUGxKqPNDzzo=	2026-08-28 11:51:37.975412+05:30	2026-08-22 12:12:01.02779+05:30	\N	2026-08-21 11:51:37.975497+05:30	2026-08-22 12:12:01.027974+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cf455132-90dc-4f5f-940a-31ab1c84dd07	40517b71-5e62-182e-73b5-d4070e20a3c2	pr5XfDuAOFywVtdLXl9Smytu6+R1fnTmkh3qlKZA594=	2026-08-29 12:12:01.027914+05:30	2026-08-22 12:12:13.433484+05:30	\N	2026-08-22 12:12:01.027974+05:30	2026-08-22 12:12:13.433666+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b3c7cbaf-de43-4f28-b872-7056652f4ddd	40517b71-5e62-182e-73b5-d4070e20a3c2	xE1v9mZFEj4l6YLZ0twjZQBzYjjNcfZce8lepWhUwgY=	2026-08-29 12:12:13.433604+05:30	2026-08-22 12:12:24.316953+05:30	\N	2026-08-22 12:12:13.433666+05:30	2026-08-22 12:12:24.317172+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0e04a1ea-fa80-4695-8e5f-9df3afa7749f	40517b71-5e62-182e-73b5-d4070e20a3c2	Ng+NvjQd3Ats8Tg1lFdtiuNf2TGSJLwAnqVOx9c1944=	2026-08-29 12:12:24.317097+05:30	2026-08-22 12:12:50.703729+05:30	\N	2026-08-22 12:12:24.317172+05:30	2026-08-22 12:12:50.703952+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
180e657d-d97f-47e3-b45e-39744f0ada07	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	U15LKEO+WJbDufRQ51pnGj5nDIWVUb74QqiSlUwGn9c=	2026-08-29 12:06:29.686936+05:30	2026-08-22 12:18:25.697107+05:30	\N	2026-08-22 12:06:29.687523+05:30	2026-08-22 12:18:25.697307+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
16719cf4-c618-4a17-b892-e59a074bebbf	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	iNsRClCwDq4LcPLIHgrai5MlJFvEe4JoP9M9q3x08Xg=	2026-08-29 12:18:25.697226+05:30	2026-08-22 12:19:35.297474+05:30	\N	2026-08-22 12:18:25.697307+05:30	2026-08-22 12:19:35.299012+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
885f5917-e8dd-46c5-9c66-33992f64f733	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ax9B92tSK12r1XO5cQgJBSkLqti9YpBxSaPVlWEZso8=	2026-08-29 12:19:35.29872+05:30	2026-08-22 12:20:23.315016+05:30	\N	2026-08-22 12:19:35.299012+05:30	2026-08-22 12:20:23.315453+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c7cbad57-77ec-46c7-8a2e-a751eed4d045	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4/pRS0i/Ewg5MTVNgJIe4e3xPTQJzW3vk6qA6rlwu2Q=	2026-08-29 12:20:23.315252+05:30	2026-08-22 12:37:16.266622+05:30	\N	2026-08-22 12:20:23.315453+05:30	2026-08-22 12:37:16.268127+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6689e2d3-bd75-4047-8f41-ae3cba9f7b01	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zQSLo7GP7jf+FzCdymBmuyCtiOkD/QL9S85EwtfHZrM=	2026-08-29 12:37:16.26775+05:30	2026-08-22 13:01:33.882431+05:30	\N	2026-08-22 12:37:16.268127+05:30	2026-08-22 13:01:33.883447+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f669f630-9d3d-4db4-92c8-fc33dfa1ae17	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xOBXkr7ivNqIN6KVvB5ZYdJqJGwC2lNywuLTeuu0U4A=	2026-08-29 13:01:33.882933+05:30	2026-08-22 13:10:41.190725+05:30	\N	2026-08-22 13:01:33.883447+05:30	2026-08-22 13:10:41.191352+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fc718aae-2527-479e-b105-183386bf8495	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YG47BKlvEGwDMG0WseE0yCrgjagBu7uaLbrhYF48bGE=	2026-08-29 13:10:41.191035+05:30	2026-08-22 13:28:51.028852+05:30	\N	2026-08-22 13:10:41.191352+05:30	2026-08-22 13:28:51.030688+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a28aed47-94ca-452c-a316-5d1629c9eb00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3gVN2DweRtsn360ZYcqZaj/lm0HVhXPPgj3SRGnmFkU=	2026-08-29 13:28:51.029847+05:30	2026-08-22 15:22:27.266179+05:30	\N	2026-08-22 13:28:51.030688+05:30	2026-08-22 15:22:27.268678+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fe4aedaf-cdd9-4558-8b33-59037909a400	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	tih7Rkuz4yVXaJGsCa4oB5MVqRr7h8NjpantoVBqqWA=	2026-08-30 21:38:59.45658+05:30	2026-08-23 21:39:55.104814+05:30	\N	2026-08-23 21:38:59.555391+05:30	2026-08-23 21:39:55.105177+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
af55bf54-9809-4bd2-b88c-4308307bb333	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	n0Zq2zK3bws0mD9Im8OmptbMu/onU/LYTNdwsGbRLzI=	2026-08-29 15:22:27.267567+05:30	2026-08-23 21:39:55.683159+05:30	\N	2026-08-22 15:22:27.268678+05:30	2026-08-23 21:39:55.68636+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f3f0782f-585e-44db-bc53-63fc2475899b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	FOfN9VTBsBHvqKF41LCS5OZHqp3TWK2UkgPebU0n5tg=	2026-08-29 00:07:39.864765+05:30	2026-08-23 21:39:55.683158+05:30	\N	2026-08-22 00:07:39.86485+05:30	2026-08-23 21:39:55.68636+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7e5d627c-5368-4449-829d-5d278ea30026	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	aHOpJa3bZTYblUgtQ0gWRD27NURN3vqFPObAb6IZLMw=	2026-08-30 21:39:55.68371+05:30	2026-08-23 21:47:58.895813+05:30	\N	2026-08-23 21:39:55.68636+05:30	2026-08-23 21:47:58.895857+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
adae6dfb-3519-41a2-8a54-3d50b75675c5	dc139a9d-b996-7354-6c27-72659ea2fd59	xKIcraA8aZaWWzjGOEpZY4CAxN9rGhEUKwJX3DfQTQc=	2026-08-30 21:47:59.551065+05:30	2026-08-23 21:48:24.160084+05:30	\N	2026-08-23 21:47:59.551313+05:30	2026-08-23 21:48:24.160103+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6f4f7404-cc9c-4a74-82fc-5a821ceabede	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sWWnGkBE4k/WhGxUh76RGZSOkBmlFk4c3a4feo0W8RA=	2026-08-30 21:48:24.730547+05:30	2026-08-23 22:20:53.407358+05:30	\N	2026-08-23 21:48:24.730692+05:30	2026-08-23 22:20:53.431792+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1653d2c2-b666-4e23-aba7-155c11cb35a2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	lD7gyqz4aA6UDKdzbBrG1YiEoQ62/2Zy6xZpneu8Li0=	2026-08-30 22:20:53.423377+05:30	2026-08-23 22:58:05.498882+05:30	\N	2026-08-23 22:20:53.431792+05:30	2026-08-23 22:58:05.529424+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d65acbff-8844-4af8-9cdf-cf290b69437b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	g+QnURkep2lg3AG4BwefA8E4eyZ65iEaqun7fwbiq5w=	2026-08-30 22:58:05.516105+05:30	2026-08-23 23:27:34.001316+05:30	\N	2026-08-23 22:58:05.529424+05:30	2026-08-23 23:27:34.078007+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
efd24b5d-fcfc-432e-9682-84d404415c94	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	AK4JEqiXPmg24obEY2hvmFEmc7BnIoYIurm1ho80RUE=	2026-08-30 23:27:34.04365+05:30	2026-08-23 23:27:41.557754+05:30	\N	2026-08-23 23:27:34.078007+05:30	2026-08-23 23:27:41.577549+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
72843b55-7148-437c-bf9b-3c9768cec4e0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	MyHS6u7ACd0GRJv1ueXxRfcb42VDcFYkmhsLJUbKhTQ=	2026-08-30 23:27:41.573015+05:30	2026-08-23 23:37:53.59118+05:30	\N	2026-08-23 23:27:41.577549+05:30	2026-08-23 23:37:53.622258+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ecac5a33-5dbf-44c2-9f4e-4dd3218911ff	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ECHZNUXh8C0e4zk6b2E3LFKCfoTS0ncEV8IZpJV3GPg=	2026-08-30 23:37:53.605491+05:30	2026-08-23 23:41:19.943499+05:30	\N	2026-08-23 23:37:53.622258+05:30	2026-08-23 23:41:20.050493+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
66fd76b0-27e1-434f-b253-c89243c68ed5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fiGMGKpH04wBNvtiEI2T60ABqWR7+Fq6TNMNw2Y9TvA=	2026-08-30 23:41:20.038269+05:30	2026-08-23 23:48:52.470236+05:30	\N	2026-08-23 23:41:20.050493+05:30	2026-08-23 23:48:52.534533+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e10ad75a-a483-44e0-b993-9c25430f88fb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	U3f0pNHXJa3XfcnqKHPSphN5oDwl/c6/wDfne3MdUn8=	2026-08-30 23:48:52.52823+05:30	2026-08-23 23:59:47.311047+05:30	\N	2026-08-23 23:48:52.534533+05:30	2026-08-23 23:59:47.388531+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b57ffbbf-fede-4306-a844-19e1bbc2bc8b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OUQHKv66uDcDhWfhqt+S8lTa7cHyLcq2thXR1pjlmFc=	2026-08-30 23:59:47.355812+05:30	2026-08-24 00:00:18.847065+05:30	\N	2026-08-23 23:59:47.388531+05:30	2026-08-24 00:00:18.853783+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
442744a1-e13a-4d52-9fb5-5c5ee6ef4a94	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Soows9yOnelt2rmGKr4Yk+jWoUs8sFlk6ItwK4j0LQE=	2026-08-31 00:00:18.847873+05:30	2026-08-24 00:00:24.333389+05:30	\N	2026-08-24 00:00:18.853783+05:30	2026-08-24 00:00:24.334846+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ac938833-48c2-4eb1-8efa-fb901cd8eb22	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HOeAY3paeM7UixnPj2/z8q5NDSFHds0q7qReEkO+e0s=	2026-08-31 00:00:24.33446+05:30	2026-08-24 00:01:46.453152+05:30	\N	2026-08-24 00:00:24.334846+05:30	2026-08-24 00:01:46.454136+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
87a894b6-86f8-4e9b-8b97-f9a72728060a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	81gHe7O3OXq/BPZJoT4VzgkSUmPCTH4sD9mGpYwjZEs=	2026-08-31 00:01:46.453702+05:30	2026-08-24 00:14:40.157933+05:30	\N	2026-08-24 00:01:46.454136+05:30	2026-08-24 00:14:40.16586+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4da302f8-9119-496f-85b8-3bf02b830ccf	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UzJOEgBYXIVD5cqkZizbqJOMDm79ch561kPcCxE1Nso=	2026-08-31 00:14:40.159749+05:30	2026-08-24 00:19:09.821445+05:30	\N	2026-08-24 00:14:40.16586+05:30	2026-08-24 00:19:09.840698+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
45832294-4501-4770-b9ad-02783cc64e7a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HCOEKEKI+bWQEGSDwSjfCKBt/tdoxTJ+sInvNOwgWdk=	2026-08-31 00:19:09.837861+05:30	2026-08-24 00:22:51.123284+05:30	\N	2026-08-24 00:19:09.840698+05:30	2026-08-24 00:22:51.124642+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b0b7b496-1d56-4bae-92dc-88563c87374c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	dTvgiFVErbWwNksMFP53zikXCMGBQ6k6C4YO9KP2JIc=	2026-08-31 00:22:51.12403+05:30	2026-08-24 00:22:53.521034+05:30	\N	2026-08-24 00:22:51.124642+05:30	2026-08-24 00:22:53.522734+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7f39c75c-2bf2-44d2-b29e-f3ba10b23c57	40517b71-5e62-182e-73b5-d4070e20a3c2	vr04lBMNtlBNorpGOusIu1ewMzFwf60mEqxP1t+4yrE=	2026-08-29 12:12:50.70387+05:30	2026-09-04 11:45:40.600662+05:30	\N	2026-08-22 12:12:50.703952+05:30	2026-09-04 11:45:40.60362+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
30f466fc-6119-4fd5-bfef-b135b956ceed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NvtHt4Oc3kK0sam6WuB1Gac7GvVDR6LRl5RqL+vLKRw=	2026-08-31 00:22:53.522226+05:30	2026-08-24 00:27:26.960824+05:30	\N	2026-08-24 00:22:53.522734+05:30	2026-08-24 00:27:26.961524+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0ae780b3-1538-4d7c-a9ee-c28101512771	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8qp7ZLOV1kc9OkCEQl8cTozJ5cPyTtrLFc1Nqnd72ZI=	2026-08-31 00:27:26.961179+05:30	2026-08-24 00:35:36.41221+05:30	\N	2026-08-24 00:27:26.961524+05:30	2026-08-24 00:35:36.413014+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
af7eabe3-7601-4373-9539-4b6f6f4b370f	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	S7i14RXfPbgiZfkSeAhhwF+YS4zUel/b93aXcLjG+w8=	2026-08-31 00:34:57.71757+05:30	2026-08-24 00:36:58.914515+05:30	\N	2026-08-24 00:34:57.910054+05:30	2026-08-24 00:36:59.327348+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eae7fffc-c267-4ff9-80dc-84f7feb74cbb	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	KAh6XmH41jwep61lgoE0haM+lrmWQL3xxE2iKui+TgU=	2026-08-31 00:36:59.225314+05:30	2026-08-24 00:37:23.804955+05:30	\N	2026-08-24 00:36:59.327348+05:30	2026-08-24 00:37:23.805035+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0b1b048a-d4c8-4e4d-9b02-7f93452ee245	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	eX5sGAamq72JgP+muc6sAF0a1Voi1IgD9KwxSUYZP8A=	2026-08-31 00:37:26.072685+05:30	2026-08-24 00:38:05.18258+05:30	\N	2026-08-24 00:37:26.076124+05:30	2026-08-24 00:38:05.182736+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
058f2ac3-af1e-43a5-b132-a9a115cce749	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	eXkxy23WnQmxOz5RjZ/loiRsLcKGLexQmtBLsvfElXo=	2026-08-31 00:38:08.037171+05:30	2026-08-24 00:38:27.837912+05:30	\N	2026-08-24 00:38:08.050534+05:30	2026-08-24 00:38:27.837946+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
378303ce-6c57-4a7e-9a1d-d3962480f7fb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ampYsxKLHxfnACqnoaFyGf1Yi6Su7bUekwv0gs2iJ4w=	2026-08-31 00:35:36.412719+05:30	2026-08-24 00:38:30.981674+05:30	\N	2026-08-24 00:35:36.413014+05:30	2026-08-24 00:38:30.992134+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fea861d0-47d1-414f-ba9d-33f1ba40efd7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vwmtVWksGsZoMMX4znPPUJsgepiyTjUrCuctunS1Jgs=	2026-08-31 00:38:30.982714+05:30	2026-08-24 00:41:15.161028+05:30	\N	2026-08-24 00:38:30.992134+05:30	2026-08-24 00:41:15.177592+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f0901941-f404-4542-ac88-1d2555169cc7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Dn6Aj/kRV7/qRhBJzHgspv5JULaODvvY7mgXbJtIwNY=	2026-08-31 00:41:15.17156+05:30	2026-08-24 00:41:21.636677+05:30	\N	2026-08-24 00:41:15.177592+05:30	2026-08-24 00:41:21.640383+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eda1d94a-066d-4ba9-862a-bb344eb416c3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qrPAvv7HV/IidNmtgESzjzmIfKx4mSU1S+hburO68mM=	2026-08-31 00:41:21.639868+05:30	2026-08-24 00:49:42.193124+05:30	\N	2026-08-24 00:41:21.640383+05:30	2026-08-24 00:49:42.194124+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
321a7993-fb4e-468e-a1aa-504acc260114	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ILwhPYalP8rQiAfk4qh/gkzuqei1CbOOZTZIjK4MANY=	2026-08-31 00:49:43.014749+05:30	2026-08-24 10:28:30.252362+05:30	\N	2026-08-24 00:49:43.020634+05:30	2026-08-24 10:28:30.261043+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8bb478cb-edb8-4166-b550-cf91c4b6b8bb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5aDBd3S5ap3bgDzwG9e4LnQdk7hkZ7daUkjPVDfsJqk=	2026-08-31 10:28:31.426401+05:30	2026-08-24 10:30:12.795418+05:30	\N	2026-08-24 10:28:31.449129+05:30	2026-08-24 10:30:12.798316+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dbabe0e2-6bd3-4d1b-a18c-456f70c61f8f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	s0PODLxIHRJERRPVS6XuTtmk1PzX27PV86tpu2hwZ0I=	2026-08-31 10:30:12.796425+05:30	2026-08-24 10:33:22.585124+05:30	\N	2026-08-24 10:30:12.798316+05:30	2026-08-24 10:33:22.58649+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
00d6e713-04ed-4804-babf-899eced58937	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	mWFwUEVqS1s6Wngfw9fD51JpdxBySzPCIRjHtDOJT6A=	2026-08-31 10:33:22.585618+05:30	2026-08-24 10:33:59.595582+05:30	\N	2026-08-24 10:33:22.58649+05:30	2026-08-24 10:33:59.596089+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
076fbe5b-ed82-4e90-b673-7d192546dc10	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+uZqfwIto88O4XhQouxIJq3vr0QxHSnI54RpdMudvfw=	2026-08-31 10:33:59.595888+05:30	2026-08-24 10:34:31.265311+05:30	\N	2026-08-24 10:33:59.596089+05:30	2026-08-24 10:34:31.266146+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
61936eae-81f1-46a2-a504-3b4493d50646	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bgtPKBN5+nbejXLW9H/hxFRfFPfWZnV4VgYIIbsRrVU=	2026-08-31 10:34:31.265818+05:30	2026-08-24 10:37:54.091536+05:30	\N	2026-08-24 10:34:31.266146+05:30	2026-08-24 10:37:54.09454+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
17557c7a-d860-4f2f-9b03-09580dc9c943	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	B+gk0BTwJWyzPOYarAh/nBL5Pu+i3k9ycZO967VuLCg=	2026-08-31 10:37:54.09415+05:30	2026-08-24 10:55:44.019502+05:30	\N	2026-08-24 10:37:54.09454+05:30	2026-08-24 10:55:44.020188+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f1ae02ba-2301-4495-a9ed-a2b9cd267175	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Z1vWS6Lq/Qyq2Nw3Ucmo8o1g9ysYV7AyFYly9PRmi5E=	2026-08-31 10:55:44.019955+05:30	2026-08-24 10:55:45.040188+05:30	\N	2026-08-24 10:55:44.020188+05:30	2026-08-24 10:55:45.045033+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ace13860-9bb4-40d6-bcb8-ed601ec4d29a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	67xG+jjZqBCylOZQG3mnPku8RafStDngtXA5NGYEiGU=	2026-08-31 10:55:45.044759+05:30	2026-08-24 10:59:19.975581+05:30	\N	2026-08-24 10:55:45.045033+05:30	2026-08-24 10:59:19.976291+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e67a76ff-7666-457c-b064-16c757cb4cc6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vbKPCaWRfg9iIr10ZyFTTfDk/nBFd7uKl8nMf34Nl8U=	2026-08-31 10:59:19.975923+05:30	2026-08-25 11:33:11.853296+05:30	\N	2026-08-24 10:59:19.976291+05:30	2026-08-25 11:33:12.058601+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7d7d11a6-bfbc-4a3c-b15f-e0732905dea9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	EwockIwIkgHAeq+wmHD22c43qwxi+3T/GDwyznriO+U=	2026-09-01 11:33:12.014934+05:30	2026-08-25 12:06:52.102417+05:30	\N	2026-08-25 11:33:12.058601+05:30	2026-08-25 12:06:52.109027+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ddbf2904-bcce-4db2-ac70-8abcb85921c5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	chYV4ticDL5eNftOFmUMu23ljkigBbDBToCHduCbcss=	2026-09-01 12:06:52.10317+05:30	2026-08-25 12:31:03.249498+05:30	\N	2026-08-25 12:06:52.109027+05:30	2026-08-25 12:31:03.25+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dcd819a0-bb4c-4cd4-9bbd-c2423a602cff	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2quE5CA7jlTn2LE/pk3I2aG0vgv5s69P9ylp0zKAGA8=	2026-09-01 12:31:03.249787+05:30	2026-08-25 12:43:20.349114+05:30	\N	2026-08-25 12:31:03.25+05:30	2026-08-25 12:43:20.350439+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eb122ab2-04a9-4d7c-a9d7-acb866be1f1b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/BKcdQDS+CxVeYq6Ks+WACgPVnWaxunkeWoz5a69OhU=	2026-09-01 12:43:20.349612+05:30	2026-08-25 12:45:16.516529+05:30	\N	2026-08-25 12:43:20.350439+05:30	2026-08-25 12:45:16.641954+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
68d0a972-7ce0-4a6b-9adf-e22ade796128	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+zNSw1JzVv2koXp+m/mHeR8qMlynNkmZ7W8NXCGatIc=	2026-09-01 12:45:16.600571+05:30	2026-08-25 12:46:03.27494+05:30	\N	2026-08-25 12:45:16.641954+05:30	2026-08-25 12:46:03.280389+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eb36b54c-1908-4062-abf1-5f70f3eb0de4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/nYH6bMBu8KJotdBcB7O4TrMl1Cp4omHP+/yx/d3iR4=	2026-09-01 12:46:03.27719+05:30	2026-08-25 12:46:26.046492+05:30	\N	2026-08-25 12:46:03.280389+05:30	2026-08-25 12:46:26.047689+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
485ce7df-ba8f-4b09-9053-e85dc94a96dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GOGmZ4IMFx3yKfjnvFqkRh8cXGSdbWzENEsoLNPVChk=	2026-09-01 12:46:26.047191+05:30	2026-08-25 12:47:48.546365+05:30	\N	2026-08-25 12:46:26.047689+05:30	2026-08-25 12:47:48.546904+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
22586770-4bdc-49f5-8705-1b933a88252a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Dz0DPVf5xOkFcQ7jZ+DOcLcp4RhGz0ratK8HoTeO7ZU=	2026-09-01 12:47:48.546687+05:30	2026-08-25 12:48:18.245472+05:30	\N	2026-08-25 12:47:48.546904+05:30	2026-08-25 12:48:18.246198+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2174789d-4d9d-4c23-818d-0f53f3dd5642	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	IiF5xRh63xfndTYc9bATB8nuw+wGqZ9Wb4Ybb4GV13U=	2026-09-01 12:48:18.245936+05:30	2026-08-25 12:48:59.166466+05:30	\N	2026-08-25 12:48:18.246198+05:30	2026-08-25 12:48:59.167424+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
95c5fd06-4796-485e-8808-dcc6cb06b112	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PJrlkG7sAg+Ehk2RpI7s9VoK1rNJ7e6NZqkeeLN5/ZE=	2026-09-01 12:48:59.167058+05:30	2026-08-25 12:54:16.912023+05:30	\N	2026-08-25 12:48:59.167424+05:30	2026-08-25 12:54:17.052523+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0a2737a2-085b-47a6-929d-4bdf424252dd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CoFY3zoqvtHEdEqYBRiEpP+TtYPPK8YSAnL35QMsgr4=	2026-09-01 12:54:17.031632+05:30	2026-08-25 12:54:17.665322+05:30	\N	2026-08-25 12:54:17.052523+05:30	2026-08-25 12:54:17.666815+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bd8ff7b3-6289-4ae1-b159-d50053d7c902	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	JdJIo7H7PcSDfGg17gurE+2ZqUaFxNOjpdOcYKROS9I=	2026-09-01 12:54:17.666292+05:30	2026-08-25 12:56:18.014317+05:30	\N	2026-08-25 12:54:17.666815+05:30	2026-08-25 12:56:18.028326+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c2d3875f-824b-452c-8337-f84ab87d1e2f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9l9yxaXScZW+OfI5ale27BwdR5axG+ZgIT2+lE0z9zk=	2026-09-01 12:56:18.015809+05:30	2026-08-25 13:00:28.169656+05:30	\N	2026-08-25 12:56:18.028326+05:30	2026-08-25 13:00:28.169712+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
df930987-ad78-445d-afa2-497c1cefe42f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sjaNC8QCNAI8gGlwIZdgEQ0yjFLNxnuDwAOcmFuJPMc=	2026-09-01 13:00:28.783862+05:30	2026-08-25 14:59:09.359059+05:30	\N	2026-08-25 13:00:28.784141+05:30	2026-08-25 14:59:09.359201+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
921ee17c-d4e9-4ea4-b953-c595d10c065a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zQ6S0RGtadMcrloFkhE9n35Cfx5QxSYoms7C3dM21Sw=	2026-09-01 14:59:10.208817+05:30	2026-08-25 14:59:39.520468+05:30	\N	2026-08-25 14:59:10.215188+05:30	2026-08-25 14:59:39.521263+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b042ed0f-a3e3-4b12-8c06-104e414bbd53	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CAVp1tm5vhAYZqoiKdUhvSuFE3qwYS00qvB0c5gK6tU=	2026-09-01 14:59:39.52094+05:30	2026-08-25 15:00:02.826469+05:30	\N	2026-08-25 14:59:39.521263+05:30	2026-08-25 15:00:02.826957+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b1ede194-1361-4e1b-9e36-2b0df5d27793	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zmobMrTux/dODX6QGzLhCDxbKNWrFN5/CkNROgkW7uk=	2026-09-01 15:00:02.82681+05:30	2026-08-25 15:02:34.222612+05:30	\N	2026-08-25 15:00:02.826957+05:30	2026-08-25 15:02:34.223674+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fa0bed9f-8794-4a5d-92c3-be3b039f736c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	K3QSbq/pEzkqg8jqrVbUWiSEkzhxYSOW+DkEwS7sSuk=	2026-09-01 15:02:34.223398+05:30	2026-08-25 15:09:44.655259+05:30	\N	2026-08-25 15:02:34.223674+05:30	2026-08-25 15:09:44.681767+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6495faf7-f15d-4124-8679-319dd6489ad6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DlIgKhaoyqPW6V/ifuUEE5Tf06Tumhl3gczGghUxOc0=	2026-09-01 15:09:44.672192+05:30	2026-08-25 15:15:26.050963+05:30	\N	2026-08-25 15:09:44.681767+05:30	2026-08-25 15:15:26.052514+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
387e98e2-938a-432f-a57a-bb8a4d642481	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4ElPK0Qa/l8tEron0OFS357a999cvi9u+zfGUE6KXS4=	2026-09-01 15:15:26.051695+05:30	2026-08-25 15:49:16.152563+05:30	\N	2026-08-25 15:15:26.052514+05:30	2026-08-25 15:49:16.383231+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d1970e47-16e9-4c59-ad1c-ee915fc081e6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	hSgMB7Lv5itwOLC9Y4P1ddyE4vEMXyLVxLMFGg2jj20=	2026-09-01 15:49:16.349012+05:30	2026-08-25 16:02:54.419464+05:30	\N	2026-08-25 15:49:16.383231+05:30	2026-08-25 16:02:54.432286+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b4519eca-5f54-493d-87c6-ae0ee566dcf3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	o0lQ8Rznsw1fKmcCey3R7JCUaERkzvYg4Ym9AhguP3s=	2026-09-01 16:02:54.428388+05:30	2026-08-25 16:03:04.774008+05:30	\N	2026-08-25 16:02:54.432286+05:30	2026-08-25 16:03:04.777553+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c83292c8-a2c5-4e36-bdc6-436b5bd17912	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8w4g/sNN1ZysVFHTPDQ/CfoIgd4NyrgpyAIsxNNbnRE=	2026-09-01 16:03:04.777361+05:30	2026-08-25 16:56:17.168665+05:30	\N	2026-08-25 16:03:04.777553+05:30	2026-08-25 16:56:17.55126+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
32d30f4c-c163-46a3-8ea8-5b0bc227dac0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0NykrY/c+E0MnWwFOVy6nb74BRi3RUNwf6BkXk17zYg=	2026-09-01 16:56:17.488055+05:30	2026-08-26 11:07:00.813729+05:30	\N	2026-08-25 16:56:17.55126+05:30	2026-08-26 11:07:00.831686+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f528dfa4-3925-413c-8cda-a2688deb0292	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HO0/YTCDfjRZsbcw9eZ6b0tGmhd63+nuSUDzngkNiBA=	2026-09-02 11:07:00.827266+05:30	2026-08-26 11:07:31.088951+05:30	\N	2026-08-26 11:07:00.831686+05:30	2026-08-26 11:07:31.099391+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
faae4bd0-c6d3-435d-b6c4-3849a8266346	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PbaibS0EmZscPSVvzykvLXe2/vlY6LOCzR4DcHXI/LI=	2026-09-02 11:07:31.099182+05:30	2026-08-26 11:07:54.273081+05:30	\N	2026-08-26 11:07:31.099391+05:30	2026-08-26 11:07:54.273092+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
48b4025a-faff-4b23-b207-36507a21f7dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UFZGG1zvVzn/oLQ9JzVawvquv3zIv+jUNh4lKa0W4NA=	2026-09-02 11:07:54.9817+05:30	2026-08-26 11:22:01.942307+05:30	\N	2026-08-26 11:07:54.981849+05:30	2026-08-26 11:22:01.970635+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d4ca6c41-cc61-4277-b3f2-09f9d15d4e5d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YtCOfHi7hel46I6mEzmfs69xPWVxvxLJ/aqbEMeW8z4=	2026-09-02 11:22:01.962366+05:30	2026-08-26 11:22:07.196096+05:30	\N	2026-08-26 11:22:01.970635+05:30	2026-08-26 11:22:07.196892+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1f452c00-aa6d-4649-b406-db45d6459155	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	shjwnPQDegfCoNrsKhMk1OaWK9XrUwUaA9GS3JigBV8=	2026-09-02 15:12:48.872409+05:30	2026-08-26 16:43:06.885231+05:30	\N	2026-08-26 15:12:48.95975+05:30	2026-08-26 16:43:06.885552+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
326ea601-235a-45ca-a553-ce3346ada060	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	JNvKcmj1/AXS77UTVFOCqd42t2xtUs/9ybjbW5vtZfE=	2026-09-02 11:22:07.196689+05:30	2026-08-26 11:23:56.106669+05:30	\N	2026-08-26 11:22:07.196892+05:30	2026-08-26 11:23:56.141835+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
483c6c63-4514-4bf3-8cac-bf92461d777e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UfGhdBBEKhinx7SI5RQD3J+PJY3KuTR0kdf2+CtEMUs=	2026-09-02 11:23:56.136539+05:30	2026-08-26 11:23:58.542152+05:30	\N	2026-08-26 11:23:56.141835+05:30	2026-08-26 11:23:58.546497+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7896a328-85a1-4dd6-985b-b13156d41e40	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	85ltcFMtqY5Y1CCatF+8tRPtQZNIv8McKRs3jiCsANQ=	2026-09-02 11:23:58.54635+05:30	2026-08-26 11:32:22.993+05:30	\N	2026-08-26 11:23:58.546497+05:30	2026-08-26 11:32:23.002206+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
46ce1981-12bb-484f-add0-af0a47411ec3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2vbJLHTzJFt4rTVjv50BIzRYyC5oa176BoLwGkaix/4=	2026-09-02 11:32:23.0011+05:30	2026-08-26 11:32:32.54037+05:30	\N	2026-08-26 11:32:23.002206+05:30	2026-08-26 11:32:32.542883+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
85a37037-867f-4399-b05f-5d8be45c0306	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GEjgTCj7dXnpg0/Vg3tFgtDpd/WkVrf6sMDTvlOLcXg=	2026-09-02 11:32:32.542679+05:30	2026-08-26 12:02:52.138781+05:30	\N	2026-08-26 11:32:32.542883+05:30	2026-08-26 12:02:52.140006+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d9f1adc7-383c-420e-91fa-14abc43b428b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	EZBSKhx+/U3wZA+s/yi/N/03LbMbysRXcVqv4xEz5/4=	2026-09-02 12:02:54.60495+05:30	2026-08-26 12:31:06.435151+05:30	\N	2026-08-26 12:02:54.619937+05:30	2026-08-26 12:31:06.444742+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
81e52c44-a414-41a0-9ff1-27dd258cacf4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CL/SHhyBlArAJuYReNT05CJX+59SUOeFCEhOk9gvueY=	2026-09-02 12:31:07.290007+05:30	2026-08-26 12:42:23.57384+05:30	\N	2026-08-26 12:31:07.326124+05:30	2026-08-26 12:42:23.573884+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a27a0c11-838c-4f16-95b8-9b6ccc9917ae	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PJHv6sSKnmw8076w6BYG1YyjHJWQmXLJLc4R2XrppKA=	2026-09-02 12:42:24.181757+05:30	2026-08-26 13:04:20.994914+05:30	\N	2026-08-26 12:42:24.18252+05:30	2026-08-26 13:04:20.994943+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
11da5ba9-118d-477d-8185-eefda92466f4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	B4XUo0gvOF0csO/zQxEBhSSbQ4wAKcjHVjOMfi4Z5W0=	2026-09-02 13:04:22.203606+05:30	2026-08-26 13:04:35.084539+05:30	\N	2026-08-26 13:04:22.203981+05:30	2026-08-26 13:04:35.084561+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2f41c4a0-c5a2-4b94-8647-93f79cc318d5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	f/SFut0LpBz2Mlo6yzSFOWexFG5qo6GbtzARglAv6kI=	2026-09-02 13:04:36.012578+05:30	2026-08-26 13:47:25.87969+05:30	\N	2026-08-26 13:04:36.01329+05:30	2026-08-26 13:47:25.880383+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
01d337a6-9447-4648-a8ab-f2386989f444	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	D5c9cFPjV4ijgO34X0OqGv3KZkXpSjawSuwvwuItCtM=	2026-09-02 13:47:26.852153+05:30	2026-08-26 14:37:07.218669+05:30	\N	2026-08-26 13:47:26.858271+05:30	2026-08-26 14:37:07.266293+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
abee1dc5-650a-48b9-be6b-7e06ce91d10e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ULAKZoKjqc8S2bSRSbqa72Y5IhT+lSLjUU7cOxdJaCI=	2026-09-02 14:37:07.252864+05:30	2026-08-26 14:40:25.769225+05:30	\N	2026-08-26 14:37:07.266293+05:30	2026-08-26 14:40:25.777715+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d944b200-5081-46cd-8c27-55ee91fb3e89	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1F4GdYO3UBMZtQzm8htbmS+MntA/1QAUD/+8PqQOOEg=	2026-09-02 14:40:25.776491+05:30	2026-08-26 14:48:19.740975+05:30	\N	2026-08-26 14:40:25.777715+05:30	2026-08-26 14:48:19.742763+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a67626b1-8d34-4b94-8851-23afd36fd41b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+e3tZrtSSl8ZtZEimBD3GxGNFR8ZjO4bFIb3QzKONEQ=	2026-09-02 14:48:19.742467+05:30	2026-08-26 14:48:28.163248+05:30	\N	2026-08-26 14:48:19.742763+05:30	2026-08-26 14:48:28.164505+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6e1c0aa2-10b9-42b4-aa29-a03bca81fa3b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+IHia+PdQf4WbMoAXvANTRw3LmeBWPnUiUL16j6XJbM=	2026-09-02 14:48:28.164307+05:30	2026-08-26 14:58:32.8709+05:30	\N	2026-08-26 14:48:28.164505+05:30	2026-08-26 14:58:32.997311+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bce5898e-c4d4-48c1-9b6d-a2f0b2273091	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PSQ0JpDoZrj3RMJzxBtzqABQ9/RrXqreMxaUW8ycoNM=	2026-09-02 14:58:32.950124+05:30	2026-08-26 14:58:58.396819+05:30	\N	2026-08-26 14:58:32.997311+05:30	2026-08-26 14:58:58.397003+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cc10dbd5-82d8-4000-b20d-30c69011c233	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rLF40Vny8sy4PpBAyCXrIL8w/sL0vaQl5zARSC0MaRM=	2026-09-02 14:58:59.473689+05:30	2026-08-26 15:12:48.621474+05:30	\N	2026-08-26 14:58:59.477643+05:30	2026-08-26 15:12:48.95975+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d10342ad-316c-4e7b-88fd-d78c368c9ad6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	jX1jECv4/0bK9PI9ijWCHTLhopZY2/dCD8QQSZa0SDU=	2026-09-02 16:43:08.90643+05:30	2026-08-26 16:47:58.160609+05:30	\N	2026-08-26 16:43:08.911838+05:30	2026-08-26 16:47:58.246047+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6536c6e9-0e98-48fc-94f2-048da1abbedf	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	D31JcXFfpMSXlpZezzAv09TucFdGmat7MjdQmm6UBpw=	2026-09-02 16:47:58.211116+05:30	2026-08-26 16:58:25.297303+05:30	\N	2026-08-26 16:47:58.246047+05:30	2026-08-26 16:58:25.303542+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
af05b960-dadc-4525-8c48-91bbb1fe46c2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	olrF2O6prk9zIMukSUTY+KjTK3YzneG2nmMJ4O375Yo=	2026-09-02 16:58:26.859411+05:30	2026-08-26 16:58:26.971633+05:30	\N	2026-08-26 16:58:26.86426+05:30	2026-08-26 16:58:26.971665+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c1e07215-599e-4d76-a7fb-230f93d8368e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3FGcYiG3r96BvILfplhoanlXs+xTj63n//zOS3mslNE=	2026-09-02 16:58:28.272275+05:30	2026-08-26 18:47:50.750821+05:30	\N	2026-08-26 16:58:28.27306+05:30	2026-08-26 18:47:50.862579+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
89562afe-7ef4-4081-a329-a78796017bc1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SOJTBpTsHqfTxdTer3dGlvOUQA9MGIYFXdeoVC2FpAA=	2026-09-02 18:47:50.81666+05:30	2026-08-26 18:51:34.768801+05:30	\N	2026-08-26 18:47:50.862579+05:30	2026-08-26 18:51:34.866027+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
48fe75b1-9bc0-4095-b4fa-81a61dcce516	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	P3Oqo4H2jOKXRlMuYqqpwpVc/LxIO+8l+OfWG6Ebv9k=	2026-09-02 18:51:34.81224+05:30	2026-08-26 19:09:35.540141+05:30	\N	2026-08-26 18:51:34.866027+05:30	2026-08-26 19:09:35.631256+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
50506f97-c9e5-4240-8e3e-bba74d7c0fd2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9kCwH4Aarmlyd2NJ27/k/pt1dDtE9bFInEROWM1E4v4=	2026-09-02 19:09:35.592791+05:30	2026-08-26 19:29:10.383416+05:30	\N	2026-08-26 19:09:35.631256+05:30	2026-08-26 19:29:10.422217+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
389bc8c2-d00f-4765-8370-05373c455b40	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	QcYJt2x39JOlTy5Yt3hw6LlVIx3EH9n2PYRW08Gj72w=	2026-09-02 19:29:10.410446+05:30	2026-08-26 19:35:46.6509+05:30	\N	2026-08-26 19:29:10.422217+05:30	2026-08-26 19:35:46.737351+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fc79168e-da92-4ec6-8bcb-e7f25b023d42	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rAlxeYq5qsZ2W1PZOSzBX9Ku73stBd6e4zu1wntiC24=	2026-09-02 19:35:46.703525+05:30	2026-08-27 10:19:24.828827+05:30	\N	2026-08-26 19:35:46.737351+05:30	2026-08-27 10:19:24.835139+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2ffb97a9-3d5b-4a7e-a45f-1c5e05c03cbc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+pA4hhJhUknibzFujDhVaOStLak3dO8VoqDeegd8G8g=	2026-09-03 10:19:26.078562+05:30	2026-08-27 10:22:14.127115+05:30	\N	2026-08-27 10:19:26.10416+05:30	2026-08-27 10:22:14.226709+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5e04ed6c-0499-46eb-935e-a7a7a43ae27c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	oZ3q6RXLCAGTqJAVw8y3Q/xlFrgPUNQK6c2NKgBMzq4=	2026-09-03 10:22:14.194435+05:30	2026-08-27 12:04:07.759055+05:30	\N	2026-08-27 10:22:14.226709+05:30	2026-08-27 12:04:07.856651+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cd757aa0-fd5d-4917-9f4e-5d9647ece77d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	cKd81mKdbTi3fGtGiUY0Pq457Q2sMztPYLXliYW+IY8=	2026-09-03 12:04:07.813968+05:30	2026-08-27 12:13:41.414083+05:30	\N	2026-08-27 12:04:07.856651+05:30	2026-08-27 12:13:41.415378+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6b9aa748-628c-4983-91a2-71bddb590d30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	M2CGcZgAoVweIDXoG/KHmcEVbyeOE6lFhBb1EA4/ZEc=	2026-09-03 12:13:41.414683+05:30	2026-08-27 12:18:02.717916+05:30	\N	2026-08-27 12:13:41.415378+05:30	2026-08-27 12:18:02.718973+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7533ee2b-3840-41c1-8398-3462fd0367e5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0PjT6G49thuBIAfni6+n2HJ3deWOVa5NZQZSgtfXT6M=	2026-09-03 12:18:02.718774+05:30	2026-08-27 12:22:04.199407+05:30	\N	2026-08-27 12:18:02.718973+05:30	2026-08-27 12:22:04.200043+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
662118db-977f-4a86-83dc-2bd4869fd60e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HnavUODtgCGj5b7K6Zzv0sKSBhu2/vepgvmc0mIjGWM=	2026-09-03 12:22:04.199827+05:30	2026-08-27 12:32:55.027795+05:30	\N	2026-08-27 12:22:04.200043+05:30	2026-08-27 12:32:55.035581+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
56f7fce1-8f12-4de2-9091-b2babeb2fe2e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	X19f2Aq2EWUUvGC1Ivupk2neJlucHWTmaX+xcSCRadw=	2026-09-03 12:32:55.031206+05:30	2026-08-27 12:50:52.904813+05:30	\N	2026-08-27 12:32:55.035581+05:30	2026-08-27 12:50:53.003297+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
303f6f0c-6146-413d-a621-2ceac5c6376b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0cZ1jIyiZxdHskFOKJSR7v1s1pa/D7YL2xH/1wtIpl4=	2026-09-03 12:50:52.974279+05:30	2026-08-27 12:55:33.737796+05:30	\N	2026-08-27 12:50:53.003297+05:30	2026-08-27 12:55:33.756615+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8df67784-fe34-4baa-b2ba-6803bf9e726f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	6dyZBCNQ8CubcgUCpZrnolZwkIvGwcZpfS2gUL7WjSs=	2026-09-03 12:55:33.747085+05:30	2026-08-27 12:59:05.847146+05:30	\N	2026-08-27 12:55:33.756615+05:30	2026-08-27 12:59:05.865566+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2faa94ee-f47b-40c2-82de-d3df98abb88d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	y23/AEmcj2zjf4mdKFMDMCly2HGfhhBDXfKoIcbF6Q4=	2026-09-03 12:59:05.858806+05:30	2026-08-27 13:00:02.685659+05:30	\N	2026-08-27 12:59:05.865566+05:30	2026-08-27 13:00:02.691686+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9117d240-b16a-4885-9267-3280af26d5f3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	hsuxIDxRjpicAOBV09XxQEJIPJ3VYH7VEt3rpT56zQ8=	2026-09-03 13:00:02.691364+05:30	2026-08-27 13:00:05.090202+05:30	\N	2026-08-27 13:00:02.691686+05:30	2026-08-27 13:00:05.091715+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6677cee5-ff77-4f60-9e09-94de212517c9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	LH7yiBCF0neIdUQwwcSXSH4OyibUlahDQqnTwK9pIxY=	2026-09-03 13:00:05.091516+05:30	2026-08-27 13:00:06.470434+05:30	\N	2026-08-27 13:00:05.091715+05:30	2026-08-27 13:00:06.475922+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
27af4843-dbdb-4b39-9d69-ba3e5229cd83	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	MkthsKhe36fD0tN+l9I0HqZRk4lQuKSuXnyxR7ut62k=	2026-09-03 13:00:06.474432+05:30	2026-08-27 13:04:17.047406+05:30	\N	2026-08-27 13:00:06.475922+05:30	2026-08-27 13:04:17.049925+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b862925a-2347-497b-aab2-c4240d46791e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sibPIQ/TtvINkayvk3d2gnGsDfGYXEF4z3RrNUXMJTs=	2026-09-03 13:04:17.048733+05:30	2026-08-27 13:04:17.880969+05:30	\N	2026-08-27 13:04:17.049925+05:30	2026-08-27 13:04:17.886421+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b25c330d-792b-4292-8b64-d2f843b0ffec	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	p2SCsblmH5lAhbtW2PwY2Fc8ZM3nlpqnbfuPE9PzPTM=	2026-09-03 13:04:17.883733+05:30	2026-08-27 13:19:33.497138+05:30	\N	2026-08-27 13:04:17.886421+05:30	2026-08-27 13:19:33.550889+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5239f27a-0d97-4f14-8c53-7b26ec794c04	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	6ZdLGC5ufP0NAw2au+FxlAs0jrQwkpEw0JUB7tdX7gQ=	2026-09-03 13:19:33.528896+05:30	2026-08-27 13:19:34.14547+05:30	\N	2026-08-27 13:19:33.550889+05:30	2026-08-27 13:19:34.14778+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fa26088c-757d-4e37-93ff-ee7df34ee58d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	W8l6dyO+elIE2VhOphMMaWny61Eq3khEwEnrSkXYcy8=	2026-09-03 13:19:34.147511+05:30	2026-08-27 13:19:46.42103+05:30	\N	2026-08-27 13:19:34.14778+05:30	2026-08-27 13:19:46.43423+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bef9e722-ff41-4a12-882f-c8bc63e5966a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UEfGW6cZdfQOQ/hv+vwYFNv7tiRiRb3FQM6bq80IwKg=	2026-09-03 13:19:46.421669+05:30	2026-08-27 13:35:23.562346+05:30	\N	2026-08-27 13:19:46.43423+05:30	2026-08-27 13:35:23.564574+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9f0b4d64-bad2-4beb-9d8e-538107196656	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uG4QQY7L3qUf42aZvUxlN2P2WneEXIJRybbITsAJgmI=	2026-09-03 13:35:24.870782+05:30	2026-08-27 13:43:09.205075+05:30	\N	2026-08-27 13:35:24.882107+05:30	2026-08-27 13:43:09.233663+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5eb72b4b-8a7c-4404-911a-74e633304f17	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fVDu7o/uCp0e2ngC+jpWI2CrAXUq72d8aQVXh4wLnr8=	2026-09-03 13:43:09.207828+05:30	2026-08-27 13:43:30.895363+05:30	\N	2026-08-27 13:43:09.233663+05:30	2026-08-27 13:43:30.89972+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7850647d-4371-4138-b556-8c88a6bd344d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rhqXZJSMQZtuqqmbRlwf9W40KEemFHByZfadW99scvU=	2026-09-03 13:43:30.89946+05:30	2026-08-27 13:44:43.587341+05:30	\N	2026-08-27 13:43:30.89972+05:30	2026-08-27 13:44:43.58835+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1cd45564-0d00-405d-be09-b608a2a17faf	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	cy9Ol9xk+kA2ivelgMjx6o1qOkosn3kTvD9SovAzLWo=	2026-09-03 13:44:43.588083+05:30	2026-08-27 13:48:41.484258+05:30	\N	2026-08-27 13:44:43.58835+05:30	2026-08-27 13:48:41.495901+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
64cf86b2-df98-4f71-ae83-3c316fee3991	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	kjrpKG4TQLPhTmjbJQVPWf6uin5B/9gvYIr5eb7WJ0o=	2026-09-03 13:48:41.494407+05:30	2026-08-27 13:52:54.514562+05:30	\N	2026-08-27 13:48:41.495901+05:30	2026-08-27 13:52:54.520477+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e0337f0d-6ab0-4614-99ab-fa6ca5928cd8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	LeLm6qSGkX1SSJs+bEvnDV5UU72QGo7M2z5uHpZ4Obw=	2026-09-03 13:52:54.519813+05:30	2026-08-27 14:03:42.611842+05:30	\N	2026-08-27 13:52:54.520477+05:30	2026-08-27 14:03:42.619278+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
71a31ec8-6847-47c6-8ad7-bd17cdfd294b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DuWcsO/dAMy+eii1NGTGFHIw9Hx5GtQ3yKUMPnruMiU=	2026-09-03 14:03:42.616286+05:30	2026-08-27 14:16:16.474354+05:30	\N	2026-08-27 14:03:42.619278+05:30	2026-08-27 14:16:16.474378+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a54e5ec3-11f2-44f5-b39a-900bc9bb3e8f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	huWIFyt5dxqEHFRnB5wCvFZyNzg3Ga1S5svx1jZbOH0=	2026-09-03 14:16:18.027786+05:30	2026-08-27 14:24:30.46848+05:30	\N	2026-08-27 14:16:18.032612+05:30	2026-08-27 14:24:30.475513+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
45c25311-beb2-451b-a1c6-63df15b69692	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vkigVS42oV8h9p/x8x83EsUQXv+cSVfZ2I/GrshXZRM=	2026-09-03 14:24:30.475326+05:30	2026-08-27 14:41:19.689307+05:30	\N	2026-08-27 14:24:30.475513+05:30	2026-08-27 14:41:19.70594+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cfee90ce-5a17-447d-ab6f-82c4ac07a510	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	uRgr6XyuYtGh0DV3raXOTnj4/ynOU+0Ey+D0IFaAFU4=	2026-09-03 14:23:24.292402+05:30	2026-08-27 14:41:31.721805+05:30	\N	2026-08-27 14:23:24.298619+05:30	2026-08-27 14:41:31.726227+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
422f279b-4e96-483f-a667-54ab0b6839e7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fkQXbetvA3xfTjN9qXMQilMZ1n+lIaVwtHLJr2yHKjs=	2026-09-03 14:41:19.69817+05:30	2026-08-27 14:42:00.72155+05:30	\N	2026-08-27 14:41:19.70594+05:30	2026-08-27 14:42:00.74553+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8683ddce-b6f6-464a-81b2-5a584e2207f0	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	XC/SOWleCfKc+FdSxrMpD7FRIyxRhd9MGfiFw8oo7tY=	2026-09-03 14:41:31.724843+05:30	2026-08-27 14:42:06.175269+05:30	\N	2026-08-27 14:41:31.726227+05:30	2026-08-27 14:42:06.203016+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
604c851f-9ac9-4ce8-b666-1aafcdb6717a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	WCUgdLwiwl0mTcL6FwmtFQXt2bZZkXfnCU8ersmmIDc=	2026-09-03 14:42:00.744418+05:30	2026-08-27 14:42:11.948193+05:30	\N	2026-08-27 14:42:00.74553+05:30	2026-08-27 14:42:11.94853+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d68b4a4a-f2b9-44f7-b06e-94466cbf2e56	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NTfMwg+Ca+sHAo2w3y8qnPdcp8sauZ84+/gDaItVlqQ=	2026-09-03 14:42:11.948458+05:30	2026-08-27 14:57:35.194663+05:30	\N	2026-08-27 14:42:11.94853+05:30	2026-08-27 14:57:35.194751+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0427db6c-7a7d-4264-959d-8857bbfdb911	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	m7628yi8rTFVLgYCxsEd6n3YOXjUQM1t7AcfncJiIl4=	2026-09-03 14:57:35.976519+05:30	2026-08-27 14:59:25.963008+05:30	\N	2026-08-27 14:57:35.986781+05:30	2026-08-27 14:59:25.980441+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
716c4da6-ccd5-42e0-882f-0c59df30be56	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	heM0T0ZFIoVHptNzQ7zeUO+ekiZ5+m4gVLDdYW1T1hY=	2026-09-03 14:59:25.963292+05:30	2026-08-27 15:04:58.041006+05:30	\N	2026-08-27 14:59:25.980441+05:30	2026-08-27 15:04:58.042139+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c9c9f42f-c6ee-46be-8c54-f3acc8dd064a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BxAVZkwT3p7rVaF98elGJosrQJbezDX1Ebb1ZwvQvEg=	2026-09-03 15:04:59.077854+05:30	2026-08-27 15:07:49.946736+05:30	\N	2026-08-27 15:04:59.092829+05:30	2026-08-27 15:07:49.947169+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5a7dd72d-c762-4fd7-a038-8f02a40c6d17	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	n4s8/q78IyiiqsDKR1K+TvZUTQ/RKIwNoR8zPktU9vw=	2026-09-03 15:07:49.947058+05:30	2026-08-27 15:12:06.504061+05:30	\N	2026-08-27 15:07:49.947169+05:30	2026-08-27 15:12:06.50453+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6688545a-0eef-49a7-b417-d2a7341a05b3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	f4X64DkZh3874LdxG0zM7Py2ZagqhY98lVqex9y7kZc=	2026-09-03 15:12:06.504389+05:30	2026-08-27 15:14:43.813203+05:30	\N	2026-08-27 15:12:06.50453+05:30	2026-08-27 15:14:43.814094+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a67d245f-cc71-48b8-becc-218ffef07f3f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bRIAquM6HmirbWq12aiKjEwdJv1LPCKcJHcWl0FxEmg=	2026-09-03 15:14:43.813639+05:30	2026-08-27 15:39:37.329639+05:30	\N	2026-08-27 15:14:43.814094+05:30	2026-08-27 15:39:37.337292+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dd674867-9f67-4375-9189-c7674c1da755	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	XNi4r8pphbzJYnhz/+HWFqioC7U9moBWHTLKIuJF/X0=	2026-09-03 15:39:37.332039+05:30	2026-08-27 15:40:16.676171+05:30	\N	2026-08-27 15:39:37.337292+05:30	2026-08-27 15:40:16.676597+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b713eab5-05bd-4020-8416-0ec6362d0194	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OzkBbQuNs7x09L7zi0yZsBDr72+l1lpWuqy8vD0LuYI=	2026-09-03 15:40:16.676415+05:30	2026-08-27 15:45:40.978725+05:30	\N	2026-08-27 15:40:16.676597+05:30	2026-08-27 15:45:40.979194+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aa528fb9-4532-4e58-8ffe-18e3f9c112b9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OPAgnVbVBPWE1YkRvpgvFeorkd/kYrs710OIq2nOB4A=	2026-09-03 15:45:40.979035+05:30	2026-08-27 16:11:37.251586+05:30	\N	2026-08-27 15:45:40.979194+05:30	2026-08-27 16:11:37.253277+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3a709ca5-318e-417c-ab25-ebf358987bb1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	XNE0Ro57OISm8tp/cyKLIO2oQykT5Gv5mYO5UeiWU4E=	2026-09-03 16:11:38.161644+05:30	2026-08-27 16:22:27.872608+05:30	\N	2026-08-27 16:11:38.16695+05:30	2026-08-27 16:22:27.873122+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
33e86a34-1b1d-4fc3-af53-68f7a49fc756	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	6GOBG/4Am3RydE9q/q1wo2j0li0dsYfH3BqryY8+1Fc=	2026-09-03 16:22:18.979475+05:30	2026-08-27 16:27:26.906614+05:30	\N	2026-08-27 16:22:18.981006+05:30	2026-08-27 16:27:26.907131+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
97e68ea5-a3d0-4b7b-8d9a-ef1c3f0e1934	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8BVTos403JSE4PBD3TPWWq0QDGkpPuv2+Rs6Y8aJmWE=	2026-09-03 16:22:27.87287+05:30	2026-08-27 16:27:35.435844+05:30	\N	2026-08-27 16:22:27.873122+05:30	2026-08-27 16:27:35.43627+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e9b7e7b1-808d-4c4d-b7ef-36a55d48432a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	p74XCt31lIvhf7qBgoTSM2DNWODeuAG9C91grlMI1Do=	2026-09-03 16:27:35.43613+05:30	2026-08-27 16:34:37.016594+05:30	\N	2026-08-27 16:27:35.43627+05:30	2026-08-27 16:34:37.026528+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
89b20efd-61d0-4842-ad9a-102ba0d3141a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OmOfriprY48gjOBeuMrAknoo6nN3NhsflGs/ypB3mNE=	2026-09-03 16:34:37.020316+05:30	2026-08-27 17:28:23.507994+05:30	\N	2026-08-27 16:34:37.026528+05:30	2026-08-27 17:28:23.510459+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ee7a058a-29bf-476f-a90e-447b7727f17c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bpvZFg2os8NL4YYUd92iyJidi5mqBo83GN9ds7ZxqR8=	2026-09-03 17:28:25.97779+05:30	2026-08-27 17:36:59.013007+05:30	\N	2026-08-27 17:28:25.981064+05:30	2026-08-27 17:36:59.021175+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
38f29553-1abf-4b0b-8d51-0d2fae3708e6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	f2aRfxP/H69HwRDzoO0Rl0s3isaieddEhsIg130+cGc=	2026-09-03 17:36:59.01808+05:30	2026-08-27 17:37:25.989184+05:30	\N	2026-08-27 17:36:59.021175+05:30	2026-08-27 17:37:25.990926+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
75d7ef1b-5bd0-40e2-af24-a646cfc57670	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	IiSD0TWFzSDThXwM83VL93O6pAKgDYUvmzctjkJ1H3A=	2026-09-03 17:37:25.989419+05:30	2026-08-27 18:00:24.44111+05:30	\N	2026-08-27 17:37:25.990926+05:30	2026-08-27 18:00:24.50448+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2e5afba9-cebd-477e-b166-2707b90d7dfe	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	aT/6yTObez96Fe/iV5oi2d2y504rF+574AleCD/hvFo=	2026-09-03 18:00:24.453238+05:30	2026-08-27 18:40:06.178573+05:30	\N	2026-08-27 18:00:24.50448+05:30	2026-08-27 18:40:06.199865+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
923533c0-1c03-48e4-88b7-02c46385b138	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sQysdD6JgfBFDRyH7p23ZTosdatHMz8rKolQ6SZUqU4=	2026-09-03 18:40:06.193113+05:30	2026-08-27 18:44:09.30313+05:30	\N	2026-08-27 18:40:06.199865+05:30	2026-08-27 18:44:09.303147+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3a0ea6c6-f88b-46cb-9cca-e2f7f04757b3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	gBZr+5bEO59ADVIs/Cf0N4xmioL2CN4DRUrTFnbqRmA=	2026-09-11 11:28:50.150693+05:30	2026-09-04 11:29:49.881604+05:30	\N	2026-09-04 11:28:50.294407+05:30	2026-09-04 11:29:49.884524+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c19bbbe9-f02e-48db-ac01-025997acad35	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	lK9tiM/y3fyg+2n5xDNRtVY7j4tweJASHnfeVYdF3Tw=	2026-09-11 11:29:49.882348+05:30	2026-09-04 11:32:48.351423+05:30	\N	2026-09-04 11:29:49.884524+05:30	2026-09-04 11:32:48.352355+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3ae7ddbf-b4ae-4837-a9ee-604c65e9f0f0	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	GBfJPNwbs74OYbFCB/35wuWT6V8S2mtPzqHrvpARpLc=	2026-09-03 16:27:26.90695+05:30	2026-09-06 13:54:29.003568+05:30	\N	2026-08-27 16:27:26.907131+05:30	2026-09-06 13:54:29.00401+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eb66b1ec-9d7a-4245-8d38-5e73091f64a7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5Hh1s5TP839+C+Q3on9+GalyKd04BteiIf4CtFgayFo=	2026-09-11 11:32:48.352008+05:30	2026-09-04 11:36:21.550349+05:30	\N	2026-09-04 11:32:48.352355+05:30	2026-09-04 11:36:21.551871+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
937ce9b3-4f41-4cf5-8c4f-83df491e9188	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	n3299HHu/BIywCrKQFjF4nzYsRamcbLLHYleA3QoRo8=	2026-09-11 11:36:21.550821+05:30	2026-09-04 11:36:34.778946+05:30	\N	2026-09-04 11:36:21.551871+05:30	2026-09-04 11:36:34.780083+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d8943484-cfef-4791-a923-31b97be928bd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	EV2TvWCxp1t/knUWmdy+ONIVYA0nsalv+7xC9OcEh3w=	2026-09-11 11:36:34.779692+05:30	2026-09-04 11:41:32.747187+05:30	\N	2026-09-04 11:36:34.780083+05:30	2026-09-04 11:41:32.748291+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9a033b85-375d-402a-ab4c-b1bb1f973eff	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BB8dJtzVCrWgBUX+ojcOHmcrXHYGKZygux15rYvWunI=	2026-09-11 11:41:32.747554+05:30	2026-09-04 11:43:16.113819+05:30	\N	2026-09-04 11:41:32.748291+05:30	2026-09-04 11:43:16.128502+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2efd9edd-ffed-4cc7-98d6-72452da03e95	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Wqqorlww1GSOh4KRldyytXNzuGdTTJEON4tZs6SS97s=	2026-09-11 11:43:16.124041+05:30	2026-09-04 11:43:46.248753+05:30	\N	2026-09-04 11:43:16.128502+05:30	2026-09-04 11:43:46.297178+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
250d467a-7b4e-4d28-91db-8b1a2de620cb	40517b71-5e62-182e-73b5-d4070e20a3c2	ePUTrqqWdxurFvY39JvlyCnc8gydVY3zoh9YdcntbQM=	2026-09-11 11:45:40.601386+05:30	2026-09-04 11:47:23.623897+05:30	\N	2026-09-04 11:45:40.60362+05:30	2026-09-04 11:47:23.62547+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3b2c5c49-fb81-4763-9b09-9e5b1c771dbb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SKp9e6MUf+GJeLSrDbhSy4gxh9IHjP0RteGEHrFXcZ8=	2026-09-11 11:43:46.29659+05:30	2026-09-04 11:47:24.328497+05:30	\N	2026-09-04 11:43:46.297178+05:30	2026-09-04 11:47:24.328884+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e7592c43-0640-4313-b9d4-68304062b4ea	40517b71-5e62-182e-73b5-d4070e20a3c2	KTkEoDZGwodSPaRS21rcYN72+t3ny0GHXh+neo6xbmY=	2026-09-11 11:47:23.624443+05:30	2026-09-04 11:47:40.523558+05:30	\N	2026-09-04 11:47:23.62547+05:30	2026-09-04 11:47:40.524067+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
63177596-5c95-4613-b3d5-ef6a55d5efb7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qa67aAk0XWujO7ZbpWv3bsy6gLFJmIs1g9XkZbWBxm8=	2026-09-11 11:47:24.328727+05:30	2026-09-04 11:47:40.96347+05:30	\N	2026-09-04 11:47:24.328884+05:30	2026-09-04 11:47:40.964353+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a2a1a1ab-6466-4498-8214-a655740b084a	1a077a8c-4029-8ded-d563-19e9b4bdf301	Nk2nSs1KOnj/jT/yUhX2bMvzkrKuSOkj1d/n3LADbxM=	2026-09-11 11:47:24.762174+05:30	2026-09-04 11:47:41.379021+05:30	\N	2026-09-04 11:47:24.762352+05:30	2026-09-04 11:47:41.379256+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
57540e48-c2e1-48ec-bb9c-f5478fa1359f	e7554ba2-e546-93ce-1e88-a073badd78a2	ATm4KuIOOCVexxs5tnhPe9/pl4bvRJnYZpHHaHX8u+c=	2026-08-14 13:27:04.149816+05:30	2026-09-04 11:47:41.774896+05:30	\N	2026-08-07 13:27:04.149909+05:30	2026-09-04 11:47:41.775157+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
67fd7619-4f25-4f5d-8635-c6c9170ab06a	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	cA/+rX9SU63iiXW3CaM095m2KyoL/3Dkb/mur9YymE4=	2026-09-03 14:42:06.199196+05:30	2026-09-04 11:47:42.149636+05:30	\N	2026-08-27 14:42:06.203016+05:30	2026-09-04 11:47:42.149891+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ee4cf9e1-d894-4b3b-8f8e-edabf41ece8d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OEBQKJR/yVntG13e6ygVwlZV/IKYKeQvQEo/wRRLujE=	2026-09-11 11:47:40.963654+05:30	2026-09-04 11:48:21.25276+05:30	\N	2026-09-04 11:47:40.964353+05:30	2026-09-04 11:48:21.25295+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1b70506f-5cc0-46c5-b3f3-69b6b5e204e8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qMoNV0NEwdU2XfYzbXSlRkP+i0WGfHm51B6OfZm3juY=	2026-09-11 11:48:21.931522+05:30	2026-09-04 12:15:57.384694+05:30	\N	2026-09-04 11:48:21.931818+05:30	2026-09-04 12:15:57.422522+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b570a40d-a1a7-4da7-9b61-2c1e9037cdbc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xZRsehqjLMkMp+9MHHknD+04JfZFLDWDCB/3mm1juww=	2026-09-11 12:15:57.41091+05:30	2026-09-04 12:16:25.474326+05:30	\N	2026-09-04 12:15:57.422522+05:30	2026-09-04 12:16:25.480678+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1f5ee396-cd4f-475d-9b41-e204d9c0425b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uTFGnxSaDg9v6LsCJX8bjohjUZH/bXpmSC/z+N73AMA=	2026-09-11 12:16:25.480308+05:30	2026-09-04 12:16:37.551398+05:30	\N	2026-09-04 12:16:25.480678+05:30	2026-09-04 12:16:37.551968+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8782d5fc-bae6-4bc3-b42c-c02d855e816c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Rf05fTJLyDGZG82cHMqp4oC/I26tWbAHHrNgdw0yBPY=	2026-09-11 12:16:37.551789+05:30	2026-09-04 12:16:41.2208+05:30	\N	2026-09-04 12:16:37.551968+05:30	2026-09-04 12:16:41.22414+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4dccb74e-7d50-43eb-aebe-f4a4c3aac44c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Q3J2nbENRsGIEtKB+8cXESJGLqbm1kD+mySIRXuk64k=	2026-09-11 12:16:41.222841+05:30	2026-09-04 14:42:48.28265+05:30	\N	2026-09-04 12:16:41.22414+05:30	2026-09-04 14:42:48.327728+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3f932100-f5ed-430e-8062-e819421496ca	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8Ck6RSvEtj1ibmcEto8xLWlCPn0yqoctkZCtLFKT2co=	2026-09-11 14:42:48.319173+05:30	2026-09-04 16:06:44.826352+05:30	\N	2026-09-04 14:42:48.327728+05:30	2026-09-04 16:06:44.878546+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8c1a68fa-9960-4bf5-aaef-e444a91c08ec	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CCj+0YtFjcRszypH5hk12TiU657nx23KnUTSPlOip1M=	2026-09-11 16:06:44.859417+05:30	2026-09-04 16:35:13.933904+05:30	\N	2026-09-04 16:06:44.878546+05:30	2026-09-04 16:35:13.949277+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
737b917f-a20f-447d-8b56-1e6994a6664d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	VCcU0ui1SlZbNbBGz0vhCVadEP/njC62bhPtdL5ntZQ=	2026-09-11 16:35:13.947746+05:30	2026-09-05 18:16:21.898521+05:30	\N	2026-09-04 16:35:13.949277+05:30	2026-09-05 18:16:21.948531+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
61a9a02c-7df2-4c21-a270-37d01895a800	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1rsj4sdTQ55WiIQ8aws1hrg5aBx5sJ3j05RVuOvh8wI=	2026-09-12 18:16:21.933188+05:30	2026-09-05 19:15:38.583013+05:30	\N	2026-09-05 18:16:21.948531+05:30	2026-09-05 19:15:38.637786+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2eb0c41f-a9c6-486e-9a7d-6f335568a673	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	RCjarijGXXRO+6kn8dhnYVLifooF3c7CFN/tFUlgSAc=	2026-09-12 19:15:38.623052+05:30	2026-09-05 19:15:38.952007+05:30	\N	2026-09-05 19:15:38.637786+05:30	2026-09-05 19:15:38.9558+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1b4e6325-8d55-48ff-ac5e-dea7213affa3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5XEOh7fH4snK/aCWQGIpvQk7uA8uQmRWzf/SxSsbTSc=	2026-09-12 19:15:38.954419+05:30	2026-09-05 19:16:09.461083+05:30	\N	2026-09-05 19:15:38.9558+05:30	2026-09-05 19:16:09.467713+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4103908a-b993-4224-9b8d-c91a48041aed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ljpnTUU4lCfrmZhJzCS8PUHytdJB+JRxdYLaspiiQJ8=	2026-09-12 19:16:09.461594+05:30	2026-09-05 19:34:52.763118+05:30	\N	2026-09-05 19:16:09.467713+05:30	2026-09-05 19:34:52.838542+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7bbc1ae2-fe37-47bb-af76-16b8854eda20	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GbUg1WY1FECUCuKkrcYNigiDFgNDJ6gQKt8tnuHzF9s=	2026-09-12 21:41:26.158538+05:30	2026-09-06 12:34:58.586355+05:30	\N	2026-09-05 21:41:26.163258+05:30	2026-09-06 12:34:58.605037+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3e9283bc-c17b-443b-8799-b5702bb26e39	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rfxIkTEDYA9Gy8ReGijsa3cSb84jgkGo7aJxFJ8u/OU=	2026-09-12 19:34:52.793627+05:30	2026-09-05 20:57:03.396814+05:30	\N	2026-09-05 19:34:52.838542+05:30	2026-09-05 20:57:03.533946+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aec7cffa-148d-43d1-a7ef-95dc9043f3d4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1K3P6JLEkjEoW8IE8af91Ejdbd68MLhknhygrli5vVE=	2026-09-12 20:57:03.472193+05:30	2026-09-05 21:16:26.37527+05:30	\N	2026-09-05 20:57:03.533946+05:30	2026-09-05 21:16:26.450889+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6004b170-c3cf-4ec6-9995-db4318e178a7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	6UpjZEfQ+Wj5u8Luh9ZVifoq1Qm+fj6mLXZvzWYlB3s=	2026-09-12 21:16:26.439804+05:30	2026-09-05 21:41:26.148783+05:30	\N	2026-09-05 21:16:26.450893+05:30	2026-09-05 21:41:26.163258+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aaebc076-142d-4e3b-913e-f8c2b62c1721	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YpIBC4t7keI8zRWLTPFIo9JWECU1TCbU/PVtc6DYxYE=	2026-09-13 12:34:58.592818+05:30	2026-09-06 13:47:55.529832+05:30	\N	2026-09-06 12:34:58.605037+05:30	2026-09-06 13:47:55.549633+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
261a8740-118c-4ea4-ad00-3dbbcdf8b0d6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bQ4uBiuDdveVzwsa63U85u0SvxsHnsOx9LvZowzdYno=	2026-09-13 13:47:55.543377+05:30	2026-09-06 13:47:59.02516+05:30	\N	2026-09-06 13:47:55.549633+05:30	2026-09-06 13:47:59.025186+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
13d42276-bab5-4c71-ba25-84274fd75e1c	730809c0-fc01-a664-03ca-28e0e32d0393	tySGGx6opCh7+FQvSomkoYyFeZaD3j1NBW62LO1SqlY=	2026-09-13 13:48:00.221617+05:30	2026-09-06 13:54:27.993326+05:30	\N	2026-09-06 13:48:00.222002+05:30	2026-09-06 13:54:27.99334+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
beac46e6-993e-4ae1-a38e-649e91eea05f	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	n7fhSOWTeTEz0HcuwTpZ/GRLoXm40CfyV4Hto7cMwnw=	2026-09-13 13:54:29.003826+05:30	2026-09-06 14:00:37.272513+05:30	\N	2026-09-06 13:54:29.00401+05:30	2026-09-06 14:00:37.276476+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9d5b6be5-166b-470d-90f7-7bbaca11e71b	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	Dsled/9xtLyytatG/xf0yx0RO8aBgsdWb3TLAIW9M8Y=	2026-09-13 14:00:37.272788+05:30	2026-09-06 14:00:59.530665+05:30	\N	2026-09-06 14:00:37.276476+05:30	2026-09-06 14:00:59.533719+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f6d9f2f7-d549-46a1-ab0a-eec7316740cf	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	p6FkqjwS1ICk0FqKbBEWH/x2g9YI/8kfvP8hOzp8/oY=	2026-09-13 14:00:59.53326+05:30	2026-09-06 14:31:48.087037+05:30	\N	2026-09-06 14:00:59.533719+05:30	2026-09-06 14:31:48.098065+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7b0d27f6-c60e-4570-a3d6-b93ecc1984f8	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	xMpgpQlUR6uid5vqGgj1MQMmpmk/gmHj5qbKMFxJ9xI=	2026-09-13 14:31:48.09253+05:30	2026-09-07 12:20:31.89111+05:30	\N	2026-09-06 14:31:48.098065+05:30	2026-09-07 12:20:32.088898+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
89be054b-3009-4699-9929-d7747a198bc8	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	Dde/zVZ5GI7iVGY+d4sI478CY08GYrVMxyCm9uKLy/0=	2026-09-14 12:20:32.0363+05:30	2026-09-07 12:20:50.00424+05:30	\N	2026-09-07 12:20:32.088898+05:30	2026-09-07 12:20:50.004386+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c6c8138e-3d96-498c-ade7-d1f62ec76d3b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0rw/8PWZ5hZDoB8CISFyVTZ1N5IkpObBSjSViLW7orA=	2026-09-12 21:16:26.422085+05:30	2026-09-07 12:20:51.478923+05:30	\N	2026-09-05 21:16:26.450889+05:30	2026-09-07 12:20:51.481079+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e0df190b-f5e4-423a-b7e0-b2b93af63317	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Gva6qrva7LLXtfPFperAVdf6bEJqEDbYc2YUviQyphA=	2026-09-12 20:57:03.471233+05:30	2026-09-07 12:20:51.478921+05:30	\N	2026-09-05 20:57:03.534839+05:30	2026-09-07 12:20:51.481079+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
268d6f33-73c1-47b6-a534-3d6a80f06595	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	59y1cpMWOKZ0LXQRk7I8DOET8/2qKYkfnIfwvpbKy74=	2026-09-11 11:47:42.149786+05:30	2026-09-07 14:32:18.903719+05:30	\N	2026-09-04 11:47:42.149891+05:30	2026-09-07 14:32:18.904822+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8cccee70-290f-4f19-a324-fc3633e8cd40	e7554ba2-e546-93ce-1e88-a073badd78a2	8EtPH7QKJpK7F0QZmcZSkNXWigaJUOqAgBlDBDLSRDE=	2026-09-11 11:47:41.775053+05:30	2026-09-07 18:03:26.542305+05:30	\N	2026-09-04 11:47:41.775157+05:30	2026-09-07 18:03:26.543118+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4a06a223-ed7a-40f5-81d5-7684c11f62a5	1a077a8c-4029-8ded-d563-19e9b4bdf301	BGn2Gyqb40F/9r0BgUcz0ogLJ3ns2A6pGYvEVAu7jYk=	2026-09-11 11:47:41.379168+05:30	2026-09-07 18:06:38.001718+05:30	\N	2026-09-04 11:47:41.379256+05:30	2026-09-07 18:06:38.002272+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
22b24138-23ee-4716-826b-b765ef05f40c	40517b71-5e62-182e-73b5-d4070e20a3c2	xw8ZXTDQP9SQnCYkWu9pzSCZyHwbsmd+UY4AeCH6QpI=	2026-09-11 11:47:40.523812+05:30	2026-09-09 12:45:34.375275+05:30	\N	2026-09-04 11:47:40.524067+05:30	2026-09-09 12:45:34.375794+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8cb2248b-545b-489c-a80e-f4b3346b3f69	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fFb6vHgF9+QpfNXREPoqpHFKF6emyHHvaHFZtoANInY=	2026-09-14 12:20:51.480481+05:30	2026-09-07 12:29:07.91057+05:30	\N	2026-09-07 12:20:51.481079+05:30	2026-09-07 12:29:07.941206+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2f3d19a5-5b36-4b23-b62f-7f7c8b8bec7f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	AMpFn1oL15GWAcQsngH5KMirXiaKMw2YHUSpafV9It8=	2026-09-14 12:29:07.931253+05:30	2026-09-07 13:00:43.556816+05:30	\N	2026-09-07 12:29:07.941206+05:30	2026-09-07 13:00:43.65328+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c77bd041-782f-46dd-a9ef-8697c6a5d053	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1lY+o4v4ry1n5VSFSHuzSmD6Wrwuo12bypSv7Pjzb/Y=	2026-09-14 13:00:43.631698+05:30	2026-09-07 13:20:58.508527+05:30	\N	2026-09-07 13:00:43.65328+05:30	2026-09-07 13:20:58.658831+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0f0b9fdc-e6e0-4190-a294-beab555773a8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uPLj8d3/kcwzcYFjJes9S1zSdDUKTIdrycaGVYIz3vM=	2026-09-14 13:20:58.593444+05:30	2026-09-07 14:26:03.043282+05:30	\N	2026-09-07 13:20:58.658831+05:30	2026-09-07 14:26:03.091316+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
62416bc2-7c7f-45cc-aa41-86afd7537769	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	RBGeeWr7Fi3s929lV0Rp/Qryz4WxrJhhdEypA1uEPCE=	2026-09-14 14:26:03.075592+05:30	2026-09-07 14:26:38.861195+05:30	\N	2026-09-07 14:26:03.091316+05:30	2026-09-07 14:26:38.86123+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2f873085-03ca-4f60-b712-e5824741e37b	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	lmVFtpwf9fDCZMFF5zQFfA4viMmrJQlP22LyeqDNdfc=	2026-09-14 14:26:40.208744+05:30	2026-09-07 14:27:04.23834+05:30	\N	2026-09-07 14:26:40.209198+05:30	2026-09-07 14:27:04.239434+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e010c300-20c7-4cf1-8371-1170714cd153	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	35tytXjAI2uNSFnR1sqcD/BrzkxtvfP2mWmJHGbZbBY=	2026-09-14 14:27:04.992174+05:30	2026-09-07 14:29:05.551934+05:30	\N	2026-09-07 14:27:04.992593+05:30	2026-09-07 14:29:05.551961+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ac1de43b-22ad-4e84-a2f8-287809c94a9a	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	8SrO7JEWRiqQgGbCxwGyUj9c58tbdvIvH01dIrYb/lw=	2026-09-14 14:29:06.201582+05:30	2026-09-07 14:29:16.445131+05:30	\N	2026-09-07 14:29:06.202133+05:30	2026-09-07 14:29:16.445499+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cf4fdb13-070a-4596-8f81-3be258fcf4a9	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	tMQmpSfA1dT9Mkdv1FtGUxFvErPjTl2w63scehLeSZo=	2026-09-14 14:29:16.445344+05:30	2026-09-07 14:31:57.03222+05:30	\N	2026-09-07 14:29:16.445499+05:30	2026-09-07 14:31:57.032245+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
25311910-c0a6-4a4c-8302-fb04ba267916	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eDt1H4TlEFxwG3bulQp5JGXfFuzhhSqFo4gLlrNCfpE=	2026-09-14 14:31:57.839349+05:30	2026-09-07 14:32:18.175506+05:30	\N	2026-09-07 14:31:57.841308+05:30	2026-09-07 14:32:18.175532+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8877b265-c0a4-4457-a0a3-bfa743d6246e	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	aoE4Q7bGclbJ6kyadfPPaaGl1yv/tevLp3NtzndBWIA=	2026-09-14 14:32:18.904456+05:30	2026-09-07 14:39:58.77549+05:30	\N	2026-09-07 14:32:18.904822+05:30	2026-09-07 14:39:58.833317+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
90920da6-9cb3-4c99-8137-4a77c19ac4dd	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	iIKij76de8FXMxjrjP1IuWTBbifg5aw0cysjngJbKiA=	2026-09-14 14:39:58.812231+05:30	2026-09-07 14:40:02.793771+05:30	\N	2026-09-07 14:39:58.833317+05:30	2026-09-07 14:40:02.793797+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
35472c2c-5bab-48d1-a12a-ae43a0a6dc5e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/aGiTXWKzGQwRd4NfNu32ApeAoWSmFaTSU/lI0EyDRA=	2026-09-14 14:40:03.493179+05:30	2026-09-07 16:19:46.061705+05:30	\N	2026-09-07 14:40:03.493609+05:30	2026-09-07 16:19:46.111044+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dd059de3-d603-43fe-930a-e355ed86a0e2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CAfcoHTZZFg73r24ls4qRw6L8ivRise4yBIYFMeFxlw=	2026-09-14 16:19:46.089273+05:30	2026-09-07 16:54:51.095498+05:30	\N	2026-09-07 16:19:46.111044+05:30	2026-09-07 16:54:51.141756+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
06ee1347-1d9b-4d46-a7af-29e8a25b5e24	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OeAMUJinkrBvGnXN7RWcawPWNczhDV4vNlQtCJZm2uE=	2026-09-14 16:54:51.130205+05:30	2026-09-07 17:15:03.050281+05:30	\N	2026-09-07 16:54:51.141756+05:30	2026-09-07 17:15:03.317986+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a46c5b30-e91b-40cc-82dd-7e22a41cb8a1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BkA3gSgMAX4DC/A/0fUO7W16Xrpze2K3yuTM1CDZNZ4=	2026-09-14 17:15:03.222882+05:30	2026-09-07 17:15:10.061482+05:30	\N	2026-09-07 17:15:03.317986+05:30	2026-09-07 17:15:10.062363+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
63290dc2-72aa-43ad-a35c-fd59ad0ee0bc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1U3Qb0Xbe0MevmyzzDuNYZPDlldorxYwjg/8cPCFJ4o=	2026-09-14 17:15:11.562213+05:30	2026-09-07 17:18:30.476304+05:30	\N	2026-09-07 17:15:11.569374+05:30	2026-09-07 17:18:30.476352+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f63c7f5b-f249-4b92-b056-50e3b0cde19b	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	fLQw54ANIk1O3exXW9UAfjR5vj8p9wtxZvZCq+vCLUM=	2026-09-14 17:18:31.376533+05:30	2026-09-07 17:19:08.412158+05:30	\N	2026-09-07 17:18:31.377043+05:30	2026-09-07 17:19:08.4126+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
09be3454-cbec-49d8-8c21-1001a9ada026	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	gIBELIJf64SS6kIXlOjlIryyhinrHxb2Udz/hIxYySU=	2026-09-14 17:19:08.412428+05:30	2026-09-07 17:19:57.395188+05:30	\N	2026-09-07 17:19:08.4126+05:30	2026-09-07 17:19:57.395216+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8ca1f8a0-654a-448d-8e1c-9ab99cb41a70	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	LBpOZrv4k/SG2sM4inYG+Lm2X1HsBj2V7gFT6oN8swY=	2026-09-14 17:19:58.051996+05:30	2026-09-07 17:20:18.858776+05:30	\N	2026-09-07 17:19:58.052314+05:30	2026-09-07 17:20:18.858815+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
79b65f10-6be0-4dfc-b11e-2f8883daa97f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tCHOxkZsRxRCtXs4FVqFMjrRI4xeRRZ9gsfXQwrGVuw=	2026-09-14 17:20:19.55357+05:30	2026-09-07 17:22:09.335911+05:30	\N	2026-09-07 17:20:19.553892+05:30	2026-09-07 17:22:09.335963+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
85d424a6-b6b7-41da-a00a-380c70a69c5c	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	6L9lPM8dOKqyfdh5IenA3vfHL2dfmIDaHDM5p4Z/azU=	2026-09-14 17:22:09.946313+05:30	2026-09-07 17:22:25.128796+05:30	\N	2026-09-07 17:22:09.946889+05:30	2026-09-07 17:22:25.128818+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7e2561b5-0f91-45a8-9c3f-0311a93b5bdf	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Wv5i2TJ6LWoIsiCgMCJk5zJ/UB+0Q6SbYgFjLQsZ+B4=	2026-09-14 17:22:25.792158+05:30	2026-09-07 17:23:38.69829+05:30	\N	2026-09-07 17:22:25.792429+05:30	2026-09-07 17:23:38.698317+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
568bc165-452f-42bd-a426-0e9c2fc46cff	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	6JuenMAEpWf4IYAUyinoKiHTNeNuDCjkoGP1ppt7Lgg=	2026-09-14 17:23:39.3885+05:30	2026-09-07 17:24:16.175711+05:30	\N	2026-09-07 17:23:39.388842+05:30	2026-09-07 17:24:16.175728+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0ac341ff-f5d3-46e2-bd05-c78e9642d64c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	iegFa2c0n7SwpFL+IcqTMLj3yrzcaJ+DjYEO0s971x4=	2026-09-14 17:24:16.847242+05:30	2026-09-07 17:27:16.796728+05:30	\N	2026-09-07 17:24:16.847416+05:30	2026-09-07 17:27:16.796751+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e204184a-0026-4c93-8ab5-ccdb9fc6a4c9	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	ruF7qmHwAw6K8KxWQl898uvsoB1/V/2+CoEaneF1l+Q=	2026-09-14 17:27:17.555119+05:30	2026-09-07 17:27:29.583156+05:30	\N	2026-09-07 17:27:17.555391+05:30	2026-09-07 17:27:29.58318+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6e456aa9-8cc9-439a-93d5-c27dbedbf57d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NteUj9bYpuCqrQXXp+Zdgfg3lR7PrmTmEk1JQaona6w=	2026-09-14 17:27:30.289766+05:30	2026-09-07 17:28:49.733803+05:30	\N	2026-09-07 17:27:30.290008+05:30	2026-09-07 17:28:49.733829+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c3aba675-e6e3-4ac8-9d27-f3c2da063b5d	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	20BVtlVyh7AuHddi8hvcREt/N8TI+Vh2pr5eCHhVOMc=	2026-09-14 17:28:50.430902+05:30	2026-09-07 17:30:45.924726+05:30	\N	2026-09-07 17:28:50.431086+05:30	2026-09-07 17:30:45.92475+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
767ae24f-4d31-4be0-855d-95728a5cd3b1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Cpwq/8zZIhiELYXWV9chkmj/Lo+bvCxDZk0BFktDNKc=	2026-09-14 17:30:46.746191+05:30	2026-09-07 17:31:47.86931+05:30	\N	2026-09-07 17:30:46.74635+05:30	2026-09-07 17:31:47.869337+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5a411895-096c-4b52-938a-00ef15c9a248	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	lulzc/P8eqbVHmvjOvCBrSRCgkH5qfGptSa5Kz0NC88=	2026-09-14 17:31:48.610956+05:30	2026-09-07 17:32:30.56268+05:30	\N	2026-09-07 17:31:48.630433+05:30	2026-09-07 17:32:30.563116+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
babb99a9-25e8-4d15-895e-81ae537e0436	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	yq+hbXDSn3MC+t6mNSDLGT58p2Fkd9ysfB5c/z5niXc=	2026-09-14 17:32:30.562983+05:30	2026-09-07 17:34:11.464584+05:30	\N	2026-09-07 17:32:30.563116+05:30	2026-09-07 17:34:11.469096+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
572ae1bc-e724-423a-898c-7e44c931da0c	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	xpqdiP7AORiIlgUE14eVRWQOaMXX/rqB1YZRL4FL9Zk=	2026-09-14 17:34:11.468753+05:30	2026-09-07 17:58:33.445104+05:30	\N	2026-09-07 17:34:11.469096+05:30	2026-09-07 17:58:33.498538+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bb8ecde9-f3d5-4be1-9c9e-6faa7a6621b2	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	d35W1pgT7CQxoqFM1mamOQJnlOusWkWTJd4DP0qBgOQ=	2026-09-14 17:58:33.488557+05:30	2026-09-07 18:02:00.184986+05:30	\N	2026-09-07 17:58:33.498538+05:30	2026-09-07 18:02:00.18554+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0f13f79d-89cc-45d7-b608-9fd1b05e0176	e7554ba2-e546-93ce-1e88-a073badd78a2	11R33qXYRXcAReFumOnVydeKYqJ7TIjKbshriqJVSoU=	2026-09-14 18:03:26.542901+05:30	2026-09-07 18:04:01.162043+05:30	\N	2026-09-07 18:03:26.543118+05:30	2026-09-07 18:04:01.162068+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2c645286-7dc1-4e16-831f-81e2986cbc46	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	LinRsPl4h2EKw0D8DhjaNhpIjDx5dVqdUg/U+fn9Bug=	2026-09-14 18:02:01.459247+05:30	2026-09-07 18:02:08.04244+05:30	\N	2026-09-07 18:02:01.462883+05:30	2026-09-07 18:02:08.042463+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
26ff91a8-abc6-48fd-835f-1b13a61c5418	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nlx90cEdFPbqh20WzlzHKPh8NE4CEKvawYl9nUGbnHw=	2026-09-14 18:02:09.269671+05:30	2026-09-07 18:03:24.969016+05:30	\N	2026-09-07 18:02:09.269848+05:30	2026-09-07 18:03:24.969036+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
01eabe2e-16bf-4fc8-8f83-8c5cd6eded1e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ot3XmqLMjj3AOqAE99ph65xUtF2vxuj8eAGhxd1vzMc=	2026-09-14 18:04:02.469467+05:30	2026-09-07 18:06:31.845732+05:30	\N	2026-09-07 18:04:02.46975+05:30	2026-09-07 18:06:31.84772+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0487d7ba-d2e9-4c94-9df7-b891d8f1048a	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	iaNJefJciHg6v6z/ublpqo5HW8v4cRQprjepB2ulozg=	2026-09-14 18:06:33.245731+05:30	2026-09-07 18:06:36.118578+05:30	\N	2026-09-07 18:06:33.255101+05:30	2026-09-07 18:06:36.118637+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d2c632bf-588a-49e9-895c-fd20fb1e25b1	1a077a8c-4029-8ded-d563-19e9b4bdf301	on/nI1DQb54v7emiDp4AEiilUaFp4qT9vFSx7ngaepg=	2026-09-14 18:06:38.002096+05:30	2026-09-07 18:06:40.374392+05:30	\N	2026-09-07 18:06:38.002272+05:30	2026-09-07 18:06:40.379388+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aee2746f-6bcf-435b-98e6-37e58dacde75	730809c0-fc01-a664-03ca-28e0e32d0393	XUvDN+k9Ro5rcaHIUO7rkyhviUPv+n4gqXKpyMrobPY=	2026-09-14 18:06:41.516347+05:30	2026-09-07 18:10:54.156816+05:30	\N	2026-09-07 18:06:41.51656+05:30	2026-09-07 18:10:54.434706+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d8d16e28-b718-47a8-bb7b-4f5a13934924	730809c0-fc01-a664-03ca-28e0e32d0393	DWDknNkQPOqca/0GTO2oQpXNc0UAYghJjqs1JE8KYWA=	2026-09-14 18:10:54.258108+05:30	2026-09-07 18:11:37.290647+05:30	\N	2026-09-07 18:10:54.434706+05:30	2026-09-07 18:11:37.290797+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f9096064-91ca-4aad-89ca-81b8e708fa5b	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	GTK4eb758hAWEVE99+THQkAEbrZ9SHPyts3R4gEmiVA=	2026-09-14 18:02:09.109203+05:30	2026-09-07 18:16:19.424439+05:30	\N	2026-09-07 18:02:09.110681+05:30	2026-09-07 18:16:19.483592+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d02b32c9-ba40-45fd-8ba3-630f95133d4b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nQmSOjh+U+EChdLlME2EygNEXyAEO8AVSsbKqqJJ+N8=	2026-09-14 18:11:40.026029+05:30	2026-09-07 18:17:33.303599+05:30	\N	2026-09-07 18:11:40.035341+05:30	2026-09-07 18:17:33.305774+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f54e56ab-1d6a-4921-ac84-5d6acf3c75fb	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	zkUUZHnad2sndgx2RZfhkH4rTcNAEVBj60V9TPxxOhg=	2026-09-14 18:16:19.448865+05:30	2026-09-07 18:17:32.096791+05:30	\N	2026-09-07 18:16:19.483592+05:30	2026-09-07 18:17:32.096821+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b9c1d675-d39b-4e54-9ca1-6162e207665a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	EyI90iuR+TUEaYjb44Lfrr9yfsl1Zj3iV9cLp/z5Gpo=	2026-09-14 18:17:33.305198+05:30	2026-09-07 18:25:53.774177+05:30	\N	2026-09-07 18:17:33.305774+05:30	2026-09-07 18:25:53.781627+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1a4dbd34-230a-4e20-bfc2-9b91f90402dd	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	e5MXImPZiMC4Ys6HbM/XrlA2SZv5oKa4q2L50EpxBV0=	2026-09-14 18:25:55.246124+05:30	2026-09-07 18:25:56.879546+05:30	\N	2026-09-07 18:25:55.253305+05:30	2026-09-07 18:25:56.879584+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c9763e20-8361-4afc-8b83-57cd3b8166e2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Zp8dNKUy8pU+mp41R/+z8zjxYsS9IMoUno+AZTgmWng=	2026-09-14 18:25:58.140851+05:30	2026-09-07 18:28:46.369086+05:30	\N	2026-09-07 18:25:58.14306+05:30	2026-09-07 18:28:46.370029+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
83901a1d-d43b-4d3e-9877-894ffbf9dff6	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	J3L9roTHtIqGPl+nQP8kX7O0F8usXCOQ1ttqax6rGqY=	2026-09-14 18:28:47.651998+05:30	2026-09-07 18:30:20.64383+05:30	\N	2026-09-07 18:28:47.652881+05:30	2026-09-07 18:30:20.643886+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ab0add8a-bc00-471e-8830-39442b739bc2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	e7DGHdZFMnqI6xaqknWvFpipkUIAS5P98wJo1MOBvrg=	2026-09-14 18:30:24.459272+05:30	2026-09-07 18:30:57.600293+05:30	\N	2026-09-07 18:30:24.459771+05:30	2026-09-07 18:30:57.600327+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
32d539c4-935e-4c96-95d1-82b728f6d4a3	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	gIrkBvf4lcB7BA/O5z39YEZD/VDIhjDaHjL115V/P9E=	2026-09-14 18:30:58.752897+05:30	2026-09-07 18:31:11.283053+05:30	\N	2026-09-07 18:30:58.753281+05:30	2026-09-07 18:31:11.283079+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4d5b04f5-81cb-4cda-92f9-5c166c3cce07	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	wzbuxQPg5OZSNMWyPupqTCEz33quCQnPHsYf6VFolnQ=	2026-09-14 18:31:12.457687+05:30	2026-09-07 18:31:58.104763+05:30	\N	2026-09-07 18:31:12.459008+05:30	2026-09-07 18:31:58.104832+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
660fb62b-bba9-42c7-9543-5d0bb1c25075	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	ByoPycnAB6gnQidOyt2f4b3r+hYZEAqMKec5ZIJ17do=	2026-09-14 18:31:59.295617+05:30	2026-09-07 18:32:04.290663+05:30	\N	2026-09-07 18:31:59.29593+05:30	2026-09-07 18:32:04.291193+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a674c02b-4d10-4da0-aa51-0047df747b87	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	nDSmxQhpj83LzGUjB0x9/em7N+H5ZR0RGOS/WhoPHpU=	2026-09-14 18:32:04.291023+05:30	2026-09-07 18:32:18.543077+05:30	\N	2026-09-07 18:32:04.291193+05:30	2026-09-07 18:32:18.544431+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e0749fe2-f7af-449d-b23a-670a7a4f505e	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	B0dZixNdNsFKheAY5jIIH2K3/w30EO2Q8fIfzjgx7EQ=	2026-09-14 18:32:18.543979+05:30	2026-09-07 18:32:41.395792+05:30	\N	2026-09-07 18:32:18.544431+05:30	2026-09-07 18:32:41.397587+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4f8d8ffd-6cb1-444c-8b12-1367794b4aca	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	HcKxaWptrpp7CJUfvZEGy2EwnoiBR6sCTl5S8NRORbE=	2026-09-14 18:32:41.397248+05:30	2026-09-07 18:32:56.693798+05:30	\N	2026-09-07 18:32:41.397587+05:30	2026-09-07 18:32:56.693836+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0bc46f8f-6c68-4a5d-8d76-e3d84fa2e9fd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	lPJPx0F4eUdf+naT4H4mNu3xln6eY3nz9irbF5VNl5s=	2026-09-14 18:32:57.795121+05:30	2026-09-07 18:33:15.635136+05:30	\N	2026-09-07 18:32:57.795572+05:30	2026-09-07 18:33:15.635161+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
56db8735-eabb-43f5-a5c6-2e097bc8bdf2	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	mrMbshw1hsqYctuLVl6DY7394cPyFiqEaVcVBD07aiI=	2026-09-14 18:33:16.796633+05:30	2026-09-07 18:35:19.579924+05:30	\N	2026-09-07 18:33:16.797352+05:30	2026-09-07 18:35:19.580036+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d441e297-3dd8-4365-a008-633a5d8e3759	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BzzrhOaa4XnknzsJlar9sPO/GpTi39l539O3NIe6QXY=	2026-09-14 18:35:20.720934+05:30	2026-09-07 18:41:17.848873+05:30	\N	2026-09-07 18:35:20.721382+05:30	2026-09-07 18:41:17.848912+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
be65b558-3e98-4944-b02c-23b6ba5014b9	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	gFWMzF+LjVFh2L1WbZcfY6bzBVZs+0XhBFX9j9Dml6Q=	2026-09-14 18:41:19.111371+05:30	2026-09-07 18:41:38.170182+05:30	\N	2026-09-07 18:41:19.113218+05:30	2026-09-07 18:41:38.170207+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
67b10ce9-abe7-47c9-8523-0cbb48ffeec1	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	csV3ROs7Gw2fzPCSNisuGGlVnkFkNVT/SA4KbUkyrTk=	2026-09-14 19:12:12.877987+05:30	2026-09-07 19:12:21.125782+05:30	\N	2026-09-07 19:12:12.878117+05:30	2026-09-07 19:12:21.1258+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0d136016-e721-4016-8418-b750cfa8e751	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	QbrIu/kjoDJRQWeUaAchyDBcKVW9zpVBtqKhBMUMZ0I=	2026-09-14 18:41:39.439798+05:30	2026-09-07 19:08:19.985019+05:30	\N	2026-09-07 18:41:39.440098+05:30	2026-09-07 19:08:19.985106+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8af7550b-4af6-4a30-9d7f-9b7bbbd4746c	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	BPVKdnDaBBVD8pQpjp3ypTnpPrGVqwFnwST9rqlxMLk=	2026-09-14 19:08:20.817262+05:30	2026-09-07 19:09:04.4977+05:30	\N	2026-09-07 19:08:20.820338+05:30	2026-09-07 19:09:04.497781+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ef33cee3-31b9-48de-b8fc-1388bd218ac1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	W7slhM1SxKbCAC/YUrIYvRBQghKlykKhMsZzITvpF68=	2026-09-14 18:44:57.718924+05:30	2026-09-07 19:09:05.221106+05:30	\N	2026-09-07 18:44:57.719084+05:30	2026-09-07 19:09:05.221755+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9d4b35a5-df1a-4323-9d9e-ea4d75f78be9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CpRuyDVqJ+Af0z9P7ThhHnYzZzKhiLZEDGz3Uwz7sX4=	2026-09-14 19:09:05.221551+05:30	2026-09-07 19:10:02.863917+05:30	\N	2026-09-07 19:09:05.221755+05:30	2026-09-07 19:10:02.863945+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1a55c17a-8f05-4f84-b40e-b2388f3a532d	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	mhhZ2f80G9zRflt+gReaAJ9ULVEamrvUC1BY45v/Qxg=	2026-09-14 19:10:03.530819+05:30	2026-09-07 19:11:42.527966+05:30	\N	2026-09-07 19:10:03.531039+05:30	2026-09-07 19:11:42.527987+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0abd28a2-7c78-4b9c-8a5c-014153221fca	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SAWiaa174CsBCBLY80D9e3A2o7e6Y+TEBYgYZZqptIA=	2026-09-14 19:11:43.259419+05:30	2026-09-07 19:12:12.15675+05:30	\N	2026-09-07 19:11:43.260442+05:30	2026-09-07 19:12:12.156777+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1717b769-f2c5-492d-8ebd-9cc54c2a4829	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/H/Kjd/aULH5q2d/7h7or/NPjjyHbIbIYNsa9xVgB78=	2026-09-14 19:12:21.811969+05:30	2026-09-07 19:13:11.779158+05:30	\N	2026-09-07 19:12:21.81207+05:30	2026-09-07 19:13:11.779185+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f2c10522-86d0-4ed8-bc25-0c87f5c0906f	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	fmibl70JL9BTWzcojT5KhrBfZmxXSoS3Pvtse0w7I4s=	2026-09-14 19:13:12.415793+05:30	2026-09-07 19:13:23.765507+05:30	\N	2026-09-07 19:13:12.41591+05:30	2026-09-07 19:13:23.765523+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bacc8a99-bd9f-4852-93d1-f87e61a5a91e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	jnkCpQMtQ4cSMn3XufxrrKCPmz8osUB6reLTHplt5Us=	2026-09-14 19:13:24.535176+05:30	2026-09-07 19:14:21.379593+05:30	\N	2026-09-07 19:13:24.535292+05:30	2026-09-07 19:14:21.379612+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ef75d1cc-a7ef-4852-b611-486739ff9f94	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	XlmD0MKW6W6kvsSWqexFNP7IZvDdbsrGW14MAMgmtFo=	2026-09-14 19:14:22.018454+05:30	2026-09-07 19:14:35.679504+05:30	\N	2026-09-07 19:14:22.018582+05:30	2026-09-07 19:14:35.679525+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c70b8386-b681-4c47-987f-8d597b13d191	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DQQmsGYr1CV1VfO4urgN8aJo6kmlSVf6L74jJ3Dm264=	2026-09-14 19:14:36.36138+05:30	2026-09-07 19:15:07.893129+05:30	\N	2026-09-07 19:14:36.361558+05:30	2026-09-07 19:15:07.893145+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a4b4b77c-3b29-47fd-ad12-626f076e7ccd	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	VzimMjKSVGfgaypy9ElhKl4GbvNhVVa8C/oKN4PMT+s=	2026-09-14 19:15:08.603778+05:30	2026-09-07 19:15:31.63155+05:30	\N	2026-09-07 19:15:08.603881+05:30	2026-09-07 19:15:31.631565+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ec9a7f71-62b7-472a-90ce-03bc56f775be	dc139a9d-b996-7354-6c27-72659ea2fd59	jfOvKGR3efB1SeAHhZipOZvrxZDKd7+fT+9fFHAZyLQ=	2026-09-14 19:15:32.406398+05:30	2026-09-07 19:15:55.156589+05:30	\N	2026-09-07 19:15:32.406504+05:30	2026-09-07 19:15:55.156651+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
36045f52-2ea3-4231-808d-c26ccd009920	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	g/JJ5NBUt7JEG3Igpm1S2g9wVx48TkWIU7ZjH8ADVSo=	2026-09-14 19:15:55.893269+05:30	2026-09-07 19:16:12.220994+05:30	\N	2026-09-07 19:15:55.893412+05:30	2026-09-07 19:16:12.221008+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
92b10c5e-d8fd-4bcb-8516-991dbfc24b05	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	dgS8h6B1AVrWLH6GGP43pAWo+y0yLHAETRaRwBCFuJo=	2026-09-14 19:16:13.036678+05:30	2026-09-07 19:17:11.930091+05:30	\N	2026-09-07 19:16:13.037732+05:30	2026-09-07 19:17:11.930107+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
45b38ec4-50ce-42f4-965c-55d9f404878d	dc139a9d-b996-7354-6c27-72659ea2fd59	a4OvLOtsXbXdvIllIouKasOYXaWT4nOpY597FaMkGAA=	2026-09-14 19:17:12.719+05:30	2026-09-07 19:19:18.935427+05:30	\N	2026-09-07 19:17:12.719158+05:30	2026-09-07 19:19:18.935439+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
97fdf8fa-9e52-49d4-b54f-c20f455f46ed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Babfk4wrKzSo88IpIKcwi0ztPC0eFdWhR64pTCINAxQ=	2026-09-14 19:19:19.593174+05:30	2026-09-07 19:38:53.927134+05:30	\N	2026-09-07 19:19:19.593451+05:30	2026-09-07 19:38:53.943941+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bb52d59f-5504-430d-b3ce-0304b8749a41	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	54N1LUaznONvolj22+LLnxwBBj7S+N7DNAtGMKaia+o=	2026-09-14 19:38:53.938864+05:30	2026-09-08 12:13:20.230534+05:30	\N	2026-09-07 19:38:53.943941+05:30	2026-09-08 12:13:20.235917+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0ad5a0c1-6970-449e-940b-203ede115f82	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	kUpiF0EdeY8GPwo37bhAIxQb4i6cToP0Cf5WbEKr02I=	2026-09-15 12:13:23.463301+05:30	2026-09-08 12:22:52.30135+05:30	\N	2026-09-08 12:13:23.499367+05:30	2026-09-08 12:22:52.390706+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5c48a3f3-3d92-4a87-9dca-dac6a70b2d35	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2Nk8pYpMEluGjCL87oHuc8aS0+YJWg3Y9EoW/ub6bp4=	2026-09-15 12:22:52.343984+05:30	2026-09-08 12:24:19.762802+05:30	\N	2026-09-08 12:22:52.390706+05:30	2026-09-08 12:24:19.763841+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fbfc52f0-0a4f-48a1-a93a-a139deef6284	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8P9qi9mt9tn6TzeORyBOP3Tw5xmHnBiqkw4frM+8NCU=	2026-09-15 12:24:19.763361+05:30	2026-09-08 12:38:29.526662+05:30	\N	2026-09-08 12:24:19.763841+05:30	2026-09-08 12:38:29.527336+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cda17cf3-96d7-43db-bb2c-85fe7a53d46a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	mLOQ8wtcBK8byL4I0IOylH9K9o0eq9+6qR1qsNknyyY=	2026-09-15 12:38:29.527092+05:30	2026-09-08 12:40:01.874303+05:30	\N	2026-09-08 12:38:29.527336+05:30	2026-09-08 12:40:01.874335+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e9c928e2-bc7e-45ba-bd18-47b3394743fc	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	YpN5B6o8MVhocy1P1BAifaOSVQcPbXUtznhe47hb4h4=	2026-09-15 12:40:02.656856+05:30	2026-09-08 12:40:18.437954+05:30	\N	2026-09-08 12:40:02.65721+05:30	2026-09-08 12:40:18.437976+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b1d5bdf9-57d9-4018-a3c3-ab75898d504a	730809c0-fc01-a664-03ca-28e0e32d0393	e33qRfxZmtHxPuOG866sMv5CjzLjfYV92tUZVyVk8cQ=	2026-09-15 12:40:19.042373+05:30	2026-09-08 12:40:23.514953+05:30	\N	2026-09-08 12:40:19.042653+05:30	2026-09-08 12:40:23.514982+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e8f7abb9-fd9e-4fa9-b29e-97500ac6fbd7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0gdqbCK42tl6U1aZAMcH2CuUet9y5YQ2EZgEhm0ZtCc=	2026-09-15 12:40:24.033195+05:30	2026-09-08 13:05:18.997002+05:30	\N	2026-09-08 12:40:24.033421+05:30	2026-09-08 13:05:19.027036+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7c6cd214-098a-4884-9481-bc6e5aba8789	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Fc0KW4moXRpPzqzZxzFj/7w+1zJRV9yXULUzQmsCyZY=	2026-09-15 13:05:19.021908+05:30	2026-09-08 13:05:26.086886+05:30	\N	2026-09-08 13:05:19.027036+05:30	2026-09-08 13:05:26.089719+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
640c3440-5d9a-4143-85af-effedf0a03a6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	E8Werv6GolG4bL37Ttxp2i4annRlfJadE0B9RYlZkt0=	2026-09-15 13:05:26.08719+05:30	2026-09-08 13:06:15.942166+05:30	\N	2026-09-08 13:05:26.089719+05:30	2026-09-08 13:06:15.942631+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2ceefe32-c064-4d97-9775-fba00fc12c52	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OeM7IFWlSakUlEpHV1dqyH12Iee+87CSRJW+GstQw9Y=	2026-09-15 13:06:15.942479+05:30	2026-09-08 13:06:16.409898+05:30	\N	2026-09-08 13:06:15.942631+05:30	2026-09-08 13:06:16.410828+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8c4fe13c-0c86-4b20-b724-af1c2383f6fd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Ym2ecFApc3MdNI787Y+vdw+az8M9ARMnK1YjdjSRzn4=	2026-09-15 13:06:16.410657+05:30	2026-09-08 13:06:36.381823+05:30	\N	2026-09-08 13:06:16.410828+05:30	2026-09-08 13:06:36.382643+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
388de6e9-6279-4355-b99b-d06cbae22a5e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0ahMFApdV+ZCs7Wh2CrxEZtKVgRGucUQ9wX3DhH1v7M=	2026-09-15 13:06:36.382329+05:30	2026-09-08 13:06:37.105897+05:30	\N	2026-09-08 13:06:36.382643+05:30	2026-09-08 13:06:37.106337+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3a63edcd-99d4-4a8e-aed2-fa6dda1f03eb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1xzQekjcUcTXAKa7I6dkdIerv1JNAhSxkXIPJrG7lII=	2026-09-15 13:06:37.106123+05:30	2026-09-08 13:08:55.949034+05:30	\N	2026-09-08 13:06:37.106337+05:30	2026-09-08 13:08:56.002726+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a4e4392e-6cfa-4a86-a396-3106b1a5da75	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nApQ8P5uk/QewlZomqrkeFKzhiIzKEjeY4MdTrqFs+c=	2026-09-15 13:08:55.986453+05:30	2026-09-08 13:26:06.905638+05:30	\N	2026-09-08 13:08:56.002726+05:30	2026-09-08 13:26:06.909194+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dfaca8ff-2ae3-4392-9d93-9a98ee45be15	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PFtnxrfqFrkvBqRGV4oFUuxGpvYAAxJSErNYjGZh/J0=	2026-09-15 13:26:06.908609+05:30	2026-09-08 13:46:46.140046+05:30	\N	2026-09-08 13:26:06.909194+05:30	2026-09-08 13:46:46.16451+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
93ec121d-5f2b-4b10-9397-dc64de4d311f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	y3HyL/DXV54SuuDLJPbIF+3CQCh38nU5TBoAC4XIY0U=	2026-09-15 13:46:46.15642+05:30	2026-09-08 15:05:48.081253+05:30	\N	2026-09-08 13:46:46.16451+05:30	2026-09-08 15:05:48.10374+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7ac2740b-288a-4324-9945-1616eca19895	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	itGcVVXKI4EtqwunlV+kC//SwxCPzlACXclEAccfT8k=	2026-09-15 15:05:48.091195+05:30	2026-09-08 15:06:35.285615+05:30	\N	2026-09-08 15:05:48.10374+05:30	2026-09-08 15:06:35.28631+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
517c04be-f5b6-47cb-964b-8bc36f1dd4c9	730809c0-fc01-a664-03ca-28e0e32d0393	rM9R/FViEM/Q6W+nY6h4A1tajDt3ebVwKfeAqi+hH+Q=	2026-09-15 15:06:36.110807+05:30	2026-09-08 15:07:01.584465+05:30	\N	2026-09-08 15:06:36.111718+05:30	2026-09-08 15:07:01.584477+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0ea0e495-1fbe-4301-8587-6cdda18d44a0	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	OjxQq3yKy0MsMtJg2rn3FHhcIAjy+GPBei1J1MACaT4=	2026-09-15 15:07:02.119749+05:30	2026-09-08 15:07:15.087367+05:30	\N	2026-09-08 15:07:02.119879+05:30	2026-09-08 15:07:15.087384+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ac0abedc-1719-4923-8248-fd34e20fba66	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tGnQjdQ8DQmOLmQeT5VFJS7AMyMGvQjqrvZTmvBmyZY=	2026-09-15 15:07:15.738021+05:30	2026-09-08 15:19:02.901077+05:30	\N	2026-09-08 15:07:15.7382+05:30	2026-09-08 15:19:02.914569+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6878b6e8-1e77-4069-a015-2c2ce669f97b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vEp4idkTZIpcTmYurAGC22Y9eE5cKhqwOU/SiyAvLlw=	2026-09-15 15:19:02.912754+05:30	2026-09-08 15:19:06.470429+05:30	\N	2026-09-08 15:19:02.914569+05:30	2026-09-08 15:19:06.470929+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4f9ea995-01fe-4b6d-ac2f-ea2d8dab31ab	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/MGbfRqbjEXAba4/qe+19doycVW1CWVubfJA7NTla6Q=	2026-09-15 15:19:06.470808+05:30	2026-09-08 15:20:49.025993+05:30	\N	2026-09-08 15:19:06.470929+05:30	2026-09-08 15:20:49.028184+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7d133683-bb4e-46e7-a6c6-62b8889f573d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GgsvhMRE3H/y9LYczI0iaQ0JEx5Mkbw0VgLpHAvDZOU=	2026-09-15 15:20:49.027984+05:30	2026-09-08 15:20:51.915116+05:30	\N	2026-09-08 15:20:49.028184+05:30	2026-09-08 15:20:51.915455+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a0f79736-ba21-4822-8c04-7b831adac724	886afd00-b1c2-471b-89f7-93cedb799a77	L0uvRfjv6CT/OPP6LOW9qGCfujo4ZmOhMhO+XE4Bgh0=	2026-09-15 15:27:07.692979+05:30	2026-09-08 15:29:17.885606+05:30	\N	2026-09-08 15:27:07.694179+05:30	2026-09-08 15:29:17.887987+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
807a73a6-2161-4333-9316-3a756db18613	886afd00-b1c2-471b-89f7-93cedb799a77	zrO5+JfRcLVAw/gfRqtk57yF0zfSlLSb5bwOJj+t8ro=	2026-09-15 15:29:17.887307+05:30	2026-09-08 15:41:25.503883+05:30	\N	2026-09-08 15:29:17.887987+05:30	2026-09-08 15:41:25.504589+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c9f9a412-1ba8-4b47-9fc0-c5f0dffd75be	886afd00-b1c2-471b-89f7-93cedb799a77	OGBv7GEE7eY8RKVKsmYUp3vJowd3gLJv7T+rLGYvQcg=	2026-09-15 15:41:25.504349+05:30	2026-09-08 15:41:35.971895+05:30	\N	2026-09-08 15:41:25.504589+05:30	2026-09-08 15:41:35.973534+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d5bc165c-9d16-4ba1-b6d4-2b5c3e4c5362	886afd00-b1c2-471b-89f7-93cedb799a77	BP3c0vraxE9tiaE6r9Rzov2BKMX5TH7IpeGdm5HX65g=	2026-09-15 15:41:35.972659+05:30	2026-09-08 15:50:39.709455+05:30	\N	2026-09-08 15:41:35.973534+05:30	2026-09-08 15:50:39.712743+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bc6a830c-ed2f-473e-9862-4af0eb088e9c	886afd00-b1c2-471b-89f7-93cedb799a77	YUWiPjdSbbfqRcALTMCETew7hl8nmXlN82s54Y3BfEU=	2026-09-15 15:50:39.712557+05:30	2026-09-08 15:50:46.007977+05:30	\N	2026-09-08 15:50:39.712743+05:30	2026-09-08 15:50:46.008709+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b50b6c23-3c68-4cf4-bb42-2f51136a2d94	886afd00-b1c2-471b-89f7-93cedb799a77	rRiuHIioUzlkKPOvCC7ejAOnU74tV6EQCu5zOvIc2rI=	2026-09-15 18:16:00.222584+05:30	2026-09-08 18:45:02.062169+05:30	\N	2026-09-08 18:16:00.246747+05:30	2026-09-08 18:45:02.072682+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
92dc36f5-1013-4c71-bcb9-d6c5bcbff4b0	886afd00-b1c2-471b-89f7-93cedb799a77	e1+L+YPjNbVA8zNEOQ1Kc/tGD0RnD7vkuk5St9FHfDI=	2026-09-15 15:50:46.008475+05:30	2026-09-08 18:16:00.164698+05:30	\N	2026-09-08 15:50:46.008709+05:30	2026-09-08 18:16:00.245338+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
56afc6ee-fe92-41da-86b8-b6320ff6c69f	886afd00-b1c2-471b-89f7-93cedb799a77	HUoTc+j5gS9IlDHGPSQPCjPIh7/4h8qIbGzh5BDdC7U=	2026-09-15 18:45:02.071202+05:30	2026-09-08 18:45:17.304013+05:30	\N	2026-09-08 18:45:02.072682+05:30	2026-09-08 18:45:17.304523+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
efe13e3a-ba79-4f81-9310-995b4da70eb0	886afd00-b1c2-471b-89f7-93cedb799a77	QhHnh6oohIkniDGnT0HtF2bEqoMrySkqMcmKmouKBCc=	2026-09-15 18:45:17.304338+05:30	2026-09-08 19:17:16.224913+05:30	\N	2026-09-08 18:45:17.304523+05:30	2026-09-08 19:17:16.245667+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f9b6dbd4-4b6c-4260-9d23-973e1a5fa891	886afd00-b1c2-471b-89f7-93cedb799a77	N2Q+OVo3m/8YX6IWpi5TTvNj/k5+4vLIKUJenLdhF/U=	2026-09-15 19:17:16.23588+05:30	2026-09-08 19:17:18.2092+05:30	\N	2026-09-08 19:17:16.245667+05:30	2026-09-08 19:17:18.209586+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
36462d03-bb98-4260-8296-1811b3cc30c3	886afd00-b1c2-471b-89f7-93cedb799a77	Lv1xDnok0gV3AxvBpHSiBRI9IHI3xIHagOiSFd0pMYY=	2026-09-15 19:17:18.209426+05:30	2026-09-08 19:19:14.902098+05:30	\N	2026-09-08 19:17:18.209586+05:30	2026-09-08 19:19:14.904322+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3b8207cd-0bf5-494c-a862-7f21b89f0fdf	886afd00-b1c2-471b-89f7-93cedb799a77	Pc1UyaQmwIsvfF7W5/iYSbV2AfK13eFEV9vrWHYkLT4=	2026-09-15 19:19:14.902521+05:30	2026-09-08 19:19:23.562278+05:30	\N	2026-09-08 19:19:14.904322+05:30	2026-09-08 19:19:23.562491+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
db5444d2-7b0a-4d92-a702-c4b3bc60f48c	886afd00-b1c2-471b-89f7-93cedb799a77	X2OzXVuphdDMaQIBu7A8jZVheFox9bDQOGNU2vcp/FI=	2026-09-15 19:19:23.562396+05:30	2026-09-08 19:19:30.009042+05:30	\N	2026-09-08 19:19:23.562491+05:30	2026-09-08 19:19:30.009304+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6a7ab7b5-cca5-44f8-9204-d2576faa5eb4	886afd00-b1c2-471b-89f7-93cedb799a77	gEozsvvTcM6EqKOfxNH5aLRPf5YDgMy2knNtiVF+o2k=	2026-09-15 19:19:30.009196+05:30	2026-09-08 19:19:32.58252+05:30	\N	2026-09-08 19:19:30.009304+05:30	2026-09-08 19:19:32.582965+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
18e16a53-35b5-4a74-857b-671bfb79089e	886afd00-b1c2-471b-89f7-93cedb799a77	Kd4SmMbX3M/s0ENVnVX6Q6YKjcSzLOJ9PCtAViOlrsU=	2026-09-15 19:19:32.582836+05:30	2026-09-08 19:20:07.792746+05:30	\N	2026-09-08 19:19:32.582965+05:30	2026-09-08 19:20:07.79316+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4c8ae7c6-a379-4929-9953-d0afa8d455fc	886afd00-b1c2-471b-89f7-93cedb799a77	pjfrvtdduINkG6citeu9yw36a8rHkjMJFtbHpgyLWLg=	2026-09-15 19:20:07.792934+05:30	2026-09-08 19:21:08.843511+05:30	\N	2026-09-08 19:20:07.79316+05:30	2026-09-08 19:21:08.843994+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e2435195-4402-4885-bfb0-a375aaa8b758	886afd00-b1c2-471b-89f7-93cedb799a77	gBBY8PkSvbkJjQStK+jQpkoVCKf1sLIHZg8R/Sr0N9k=	2026-09-15 19:21:08.84371+05:30	2026-09-08 19:21:09.466882+05:30	\N	2026-09-08 19:21:08.843994+05:30	2026-09-08 19:21:09.46712+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6338e9b2-5079-401b-b7a8-0d30d026a897	886afd00-b1c2-471b-89f7-93cedb799a77	PfBflKL4yJSU7uKG2OXa845ZDZoxwYmjTKu6TXGxM8s=	2026-09-15 19:21:09.467014+05:30	2026-09-08 19:21:46.831122+05:30	\N	2026-09-08 19:21:09.46712+05:30	2026-09-08 19:21:46.831537+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6633c6eb-56f9-4929-88c2-2ebd08cd910c	886afd00-b1c2-471b-89f7-93cedb799a77	SF40xAdhQL8oduxv55kd01xhIFNZi4p8DEIKQCoLNgA=	2026-09-15 19:21:46.83135+05:30	2026-09-09 12:39:29.262582+05:30	\N	2026-09-08 19:21:46.831537+05:30	2026-09-09 12:39:29.278916+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
64be3c2f-b67a-4751-bcbe-04d2a2cd5cfd	886afd00-b1c2-471b-89f7-93cedb799a77	wwzVOnNgR1RwT2H3CKIXn5gBdgWqoACPVeW5o5o7sfE=	2026-09-16 12:39:29.272552+05:30	2026-09-09 12:39:34.096148+05:30	\N	2026-09-09 12:39:29.278916+05:30	2026-09-09 12:39:34.115984+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
493d73d9-5ea5-4f8f-adb7-3f4a089b1e4b	886afd00-b1c2-471b-89f7-93cedb799a77	MoAIBwPaUXu55NTC/ESauiLrlNRo/3Cue5sTo/CfZns=	2026-09-16 12:39:34.0963+05:30	2026-09-09 12:42:42.906774+05:30	\N	2026-09-09 12:39:34.115984+05:30	2026-09-09 12:42:42.926181+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
33e11256-147f-488b-ac3a-a43a53fb8ccb	886afd00-b1c2-471b-89f7-93cedb799a77	XRqdxSlpGm3IkT+gaE9nbVLBucYJIfnzu5fRphwOLh4=	2026-09-16 12:42:42.912186+05:30	2026-09-09 12:42:47.963374+05:30	\N	2026-09-09 12:42:42.926181+05:30	2026-09-09 12:42:47.963387+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
235f67a2-5536-4c66-8d3b-0b6d58bab2bd	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	CmbkRLxyWo1WW0FpKmvC/3yQqi+7HtRWEJcctddo0pI=	2026-09-16 12:43:06.357818+05:30	2026-09-09 12:43:08.874838+05:30	\N	2026-09-09 12:43:06.357939+05:30	2026-09-09 12:43:08.874853+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7877d40d-ff5e-42af-bfce-68d43d67d7ee	40517b71-5e62-182e-73b5-d4070e20a3c2	37SMLaP7I6BXHAJ3hEiZ5CjuY+FxewOPTuxdvO9jprI=	2026-09-16 12:45:34.375642+05:30	2026-09-09 12:46:03.360115+05:30	\N	2026-09-09 12:45:34.375794+05:30	2026-09-09 12:46:03.360129+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
501bb4a5-dc36-4b83-b8c9-e7751b15e3f7	886afd00-b1c2-471b-89f7-93cedb799a77	i8QvvbD2xKdTIb18MS5tBb941sl3ymm6iZTcJhFeoLA=	2026-09-15 18:16:00.230517+05:30	2026-09-09 12:55:30.682116+05:30	\N	2026-09-08 18:16:00.245338+05:30	2026-09-09 12:55:30.683761+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
699faa32-c0b3-422d-9af4-4eb860595c57	40517b71-5e62-182e-73b5-d4070e20a3c2	dG3hPOwYvJkcaofuCSPa1mY9e+b3BpZsBcXpnHc+Cdk=	2026-09-16 12:48:33.237851+05:30	2026-09-09 12:49:06.871338+05:30	\N	2026-09-09 12:48:33.250661+05:30	2026-09-09 12:49:06.87135+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d0b2e7c0-5deb-4ab4-92fd-615d0c015ba6	886afd00-b1c2-471b-89f7-93cedb799a77	Co0Fo6tMSHkCwgpVBBPsjXjvojY+NGgI0z2gT1U35xY=	2026-09-16 12:55:30.683468+05:30	2026-09-09 12:55:30.777575+05:30	\N	2026-09-09 12:55:30.683761+05:30	2026-09-09 12:55:30.777839+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d3878fa3-1289-4205-a46f-f41e490f3bd8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4yjuzfcTjl2ogoanh6gtCdp0MBn1fas0Zwkl/eB/jsQ=	2026-09-15 15:20:51.915338+05:30	2026-09-09 12:59:05.875972+05:30	\N	2026-09-08 15:20:51.915455+05:30	2026-09-09 12:59:05.896344+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a88014c3-fcde-439c-9097-0a637a90c90a	886afd00-b1c2-471b-89f7-93cedb799a77	vL9+4DGPOzNahfsyvrRMNQj290LbBrAsNKai30evpuY=	2026-09-16 12:55:30.777756+05:30	2026-09-09 12:56:28.834694+05:30	\N	2026-09-09 12:55:30.777839+05:30	2026-09-09 12:56:28.835158+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5f869774-5af5-4773-b1ac-302abdd528d4	886afd00-b1c2-471b-89f7-93cedb799a77	lRl4qjxswzsGSD6OLaxI6D1yGLBE0Xin1bVyD2+t7rM=	2026-09-16 12:56:28.834971+05:30	2026-09-09 12:57:10.592352+05:30	\N	2026-09-09 12:56:28.835158+05:30	2026-09-09 12:57:10.592367+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
72b05b52-be2a-491d-82b8-14bf625a6b24	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Ku5W3LlZGM7mxEiNW5zTE9GvllPRmi/vN/A620UmDek=	2026-09-16 17:54:31.67028+05:30	2026-09-09 18:05:09.881552+05:30	\N	2026-09-09 17:54:31.682731+05:30	2026-09-09 18:05:09.914287+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6cbed575-d4cd-4271-adf2-b9ad357c09b5	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	S1I99407iz5UA4DCNE05Z4oiiymmDu/fV26OmM1vO88=	2026-09-16 12:57:11.460454+05:30	2026-09-09 12:57:29.270148+05:30	\N	2026-09-09 12:57:11.460643+05:30	2026-09-09 12:57:29.270162+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
68877997-245f-441e-b5b0-d82ec8a9a0d9	886afd00-b1c2-471b-89f7-93cedb799a77	bkdCA5rOwqirgW8moxdXFkKCqfz4TZQYkudu7R0kboU=	2026-09-16 12:58:49.930632+05:30	2026-09-09 12:58:50.036527+05:30	\N	2026-09-09 12:58:49.930752+05:30	2026-09-09 12:58:50.039529+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b1748936-7047-4fd0-b110-1dbd72a2c719	886afd00-b1c2-471b-89f7-93cedb799a77	hBbYhJDFlQNMQS/dwMuoUu8thkS0gulQ5GlPXIk+2to=	2026-09-16 12:58:50.039371+05:30	2026-09-09 12:59:05.121784+05:30	\N	2026-09-09 12:58:50.039529+05:30	2026-09-09 12:59:05.121799+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
92613766-b92f-4eb1-8bd3-5ee5da7a9b92	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	KQ4CF54QmBRXta/OxKifQgz1heUaEnhMSyxjUepxtXc=	2026-09-16 12:59:05.895182+05:30	2026-09-09 13:10:11.143233+05:30	\N	2026-09-09 12:59:05.896344+05:30	2026-09-09 13:10:11.146943+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d6a566bc-2896-45c5-b8ad-0198d5948c73	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	XajqQ+sNo9Ct0rk5YcEnVW57/N+K9sE5sG/WIRMNRLY=	2026-09-16 13:10:11.14564+05:30	2026-09-09 13:10:20.950348+05:30	\N	2026-09-09 13:10:11.146943+05:30	2026-09-09 13:10:20.953447+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2f03af42-fd16-4514-a444-f1fd46b26d51	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	hCtp4TNPAbZKxPppkEEbnf4egpr4o2RzYPZlaKvTDhI=	2026-09-16 13:10:20.953212+05:30	2026-09-09 13:10:37.862013+05:30	\N	2026-09-09 13:10:20.953447+05:30	2026-09-09 13:10:37.870067+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ea093fe1-f7f6-4b57-9c91-d5cb0abedb0f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	cREsY/+SuLUcc6r3Z1mFmAUYApXC1f735nVB6zLe65M=	2026-09-16 13:10:37.869712+05:30	2026-09-09 13:10:54.846222+05:30	\N	2026-09-09 13:10:37.870067+05:30	2026-09-09 13:10:54.846233+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
29c6ce5f-a5b6-492a-aa36-8e7340b95e3d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DZACnD/gUSxd1jqmU51l6aVB80IixJEVVnWK/94JJPI=	2026-09-16 18:05:09.905754+05:30	2026-09-09 18:11:34.791296+05:30	\N	2026-09-09 18:05:09.914287+05:30	2026-09-09 18:11:34.803432+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cca190fb-4a74-4f74-b016-b0e1e1504a6d	40517b71-5e62-182e-73b5-d4070e20a3c2	Rv4hB4sn6d+ailUC43b4lUYLz35TVOateoeBqG/JwQg=	2026-09-16 13:14:48.560423+05:30	2026-09-09 13:15:26.084203+05:30	\N	2026-09-09 13:14:48.566306+05:30	2026-09-09 13:15:26.084238+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7c769c8c-f77e-4745-8c29-947ce7f1ac20	886afd00-b1c2-471b-89f7-93cedb799a77	vV4g8fSu1dil384eaHzoqdP3XUQ0iNJqIDg0F2P/vbM=	2026-09-16 13:16:12.739114+05:30	2026-09-09 13:16:12.858435+05:30	\N	2026-09-09 13:16:12.73926+05:30	2026-09-09 13:16:12.858617+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f5bffa96-d63d-4a5f-ab64-beedb1b30565	886afd00-b1c2-471b-89f7-93cedb799a77	VPYAqpfKt8t5CXXzbgFBRd2AJYbJoqWgnAmRmLWiXR0=	2026-09-16 13:16:12.858564+05:30	2026-09-09 13:16:50.106885+05:30	\N	2026-09-09 13:16:12.858617+05:30	2026-09-09 13:16:50.107535+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3df5351b-34fe-4aec-a402-bf60767958d4	886afd00-b1c2-471b-89f7-93cedb799a77	XUy0ZFlMA7+Wb0wa92j9EOWVhq9t4Xzw37HLXb9gH18=	2026-09-16 13:16:50.107053+05:30	2026-09-09 13:16:52.212756+05:30	\N	2026-09-09 13:16:50.107535+05:30	2026-09-09 13:16:52.213452+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a34ba6ec-cdf9-446d-92ab-c27cfbd0d484	886afd00-b1c2-471b-89f7-93cedb799a77	6uo9UaEtkeq7y+I35IajWXNLsmICFapK9OrzY+cWADM=	2026-09-16 13:16:52.213342+05:30	2026-09-09 13:16:53.909573+05:30	\N	2026-09-09 13:16:52.213452+05:30	2026-09-09 13:16:53.909808+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cac1efb7-07ec-4b9b-bb5d-0992e3b5a318	886afd00-b1c2-471b-89f7-93cedb799a77	LikKSMH63hnL5J4nyBGvRnZoxt6LxR+FsihAYXv4i8I=	2026-09-16 13:16:53.909727+05:30	2026-09-09 13:16:59.734151+05:30	\N	2026-09-09 13:16:53.909808+05:30	2026-09-09 13:16:59.734389+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0764b964-7f9e-488a-8de6-8d592ae47605	886afd00-b1c2-471b-89f7-93cedb799a77	sTgVLKhQGNnJ7qR7KgShxH6y4KmO3dCJGkQ5iVPJ2lM=	2026-09-16 13:16:59.734305+05:30	2026-09-09 15:58:13.950419+05:30	\N	2026-09-09 13:16:59.734389+05:30	2026-09-09 15:58:14.079855+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6718a9a4-abd3-4213-b2e7-6fbed57e4ca3	886afd00-b1c2-471b-89f7-93cedb799a77	ROrMgU3JjW2B8wnRJtAyLBy9+1S6HCu42nMJaY9B9f0=	2026-09-16 15:58:14.063364+05:30	2026-09-09 15:58:16.293879+05:30	\N	2026-09-09 15:58:14.079855+05:30	2026-09-09 15:58:16.293987+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e4a0c7d2-9439-47db-b726-2edc24d82bde	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	iEubxbw+G0tYqhPN/KUg3I7wEhJBBXgBVuTHYQ3hywk=	2026-09-16 15:58:17.09765+05:30	2026-09-09 16:18:17.637545+05:30	\N	2026-09-09 15:58:17.098018+05:30	2026-09-09 16:18:17.67056+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
96313e16-669a-4882-a28c-a7af2d78ed0c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vEzGPPirXtMnxmdM2upQuTECdlNqnsy761gMRrvdiM8=	2026-09-16 16:18:17.658394+05:30	2026-09-09 17:00:48.283043+05:30	\N	2026-09-09 16:18:17.67056+05:30	2026-09-09 17:00:48.324285+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4d49d727-f400-433c-ae34-1cb54e82c288	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	VBrGkv3TpGzUv6B2bbYRL1ipKylV7LBIidHr116zO2k=	2026-09-16 17:00:48.313024+05:30	2026-09-09 17:08:18.120153+05:30	\N	2026-09-09 17:00:48.324285+05:30	2026-09-09 17:08:18.153023+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
75126c88-715a-4600-a3c9-114f66162203	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	S6Z0cUjw1US7A3JrBQCrIfmD2AWtosiDgZZmpTklsuM=	2026-09-16 17:08:18.141133+05:30	2026-09-09 17:54:31.652104+05:30	\N	2026-09-09 17:08:18.153023+05:30	2026-09-09 17:54:31.682731+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
31d4eca4-dcd7-42c1-8c40-ca03dd19f4b1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NN5sY7omcw3YrfC9jcQKkyEP3YFtnQcFkjjYhjubYmc=	2026-09-24 12:48:48.210151+05:30	2026-09-17 16:34:46.245583+05:30	\N	2026-09-17 12:48:48.210433+05:30	2026-09-17 16:34:46.280774+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f585be28-ee63-4fc7-ab64-5f5e93a07481	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	QU4ddrOMYw6Haj8O8/2TXLwfuP72iJ/raoJOTrY3+Dg=	2026-09-16 18:11:34.80189+05:30	2026-09-09 18:20:22.079695+05:30	\N	2026-09-09 18:11:34.803432+05:30	2026-09-09 18:20:22.099224+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
139b5749-1907-4546-841f-763cdddbeb28	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	q8b86OT6Mgh2hyq5GqW/QSUufcWRo2xSArQpPTHoxNs=	2026-09-16 18:20:22.108159+05:30	2026-09-09 18:32:27.685251+05:30	\N	2026-09-09 18:20:22.109991+05:30	2026-09-09 18:32:27.726925+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1d9f6876-68de-4d00-84d6-cdbc141b4058	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	y7Rkhg0HP72a2kGwcrWSQqm67fu9dRAE4dpYne/yepc=	2026-09-16 18:32:27.715612+05:30	2026-09-17 12:08:09.687478+05:30	\N	2026-09-09 18:32:27.726925+05:30	2026-09-17 12:08:09.806056+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a8ef56ac-fd5b-48ba-ad0c-e091d4de3d0b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	hZG5PWDQvERCoANIeVpp00C71rH1xnvEt7aqK2QDP1E=	2026-09-16 18:20:22.090006+05:30	2026-09-17 12:08:09.687234+05:30	\N	2026-09-09 18:20:22.099224+05:30	2026-09-17 12:08:09.806056+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9190183d-adf0-44fb-829e-271d1dce92ca	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	7H3B1J72LZVOH6q33G2MBgo8yXEJavuH4h5xVgv0C8Y=	2026-09-24 12:08:09.773765+05:30	2026-09-17 12:08:28.615575+05:30	\N	2026-09-17 12:08:09.806056+05:30	2026-09-17 12:08:28.61936+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
20fc547d-a3df-4a61-b117-1755ca5fadb7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2ACuTGILm9PVe94nO/TbF8E40K9ImqFQMOsBRrveKRg=	2026-09-24 12:08:28.616291+05:30	2026-09-17 12:44:29.734845+05:30	\N	2026-09-17 12:08:28.61936+05:30	2026-09-17 12:44:29.851882+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5c457c54-4b6d-4682-ac25-36028420e146	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	I84vktFOnAkkxR2sSMVqIdjtWtg3Ma3+t7ApKx+/uRE=	2026-09-24 12:44:29.814851+05:30	2026-09-17 12:44:34.092833+05:30	\N	2026-09-17 12:44:29.851882+05:30	2026-09-17 12:44:34.094192+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a8bd345c-4e38-4da5-8083-dc0af3c883c5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	FRtlakRuASqxHTqGMFXAfv4a5Scf8Qiky6X6CrFNfjI=	2026-09-24 12:44:34.965659+05:30	2026-09-17 12:48:48.209805+05:30	\N	2026-09-17 12:44:34.96833+05:30	2026-09-17 12:48:48.210433+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a0ceafa1-667c-409a-9eda-07000e3b4d1f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	dChgwwb6U4MiSNiYWAkdU2Z5x+H9BeDyrGeBia1KcA4=	2026-09-24 16:34:46.268437+05:30	2026-09-17 17:12:04.402261+05:30	\N	2026-09-17 16:34:46.280774+05:30	2026-09-17 17:12:04.418624+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6d9e2a77-1875-4bc0-a0fa-f7cee0e5615d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	y9oX+TvZPC01tDkEfo8IHkPFp0lWD6ys08Q8crj55Og=	2026-09-24 17:12:04.415379+05:30	2026-09-17 17:12:52.69094+05:30	\N	2026-09-17 17:12:04.418624+05:30	2026-09-17 17:12:52.69287+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fb83e78f-ecab-4d36-b1b2-30e433922175	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	KvM9HiEUMkAjcrQ5tv/8xUwsk7RxZKwBX7OWKzBURHI=	2026-09-24 17:12:52.692131+05:30	2026-09-17 18:15:18.986562+05:30	\N	2026-09-17 17:12:52.69287+05:30	2026-09-17 18:15:19.027484+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9a19c547-2059-4522-9814-9dc699f7d8a7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	dd4LKyt9jMLd63PVX60gDuMr4EpfY9LsuY0kEkl8zFE=	2026-09-24 18:15:19.003591+05:30	2026-09-21 11:19:19.273641+05:30	\N	2026-09-17 18:15:19.027484+05:30	2026-09-21 11:19:19.278484+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b7ccd696-84aa-48c4-be85-02609d5cfc5c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vojlGWOWVXyuZ5WdpPYSJWccClhu5+zzh7hpccCUfjM=	2026-09-28 11:19:21.071641+05:30	2026-09-21 11:41:22.562983+05:30	\N	2026-09-21 11:19:21.096101+05:30	2026-09-21 11:41:22.686388+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e54d9ed8-7c17-4110-90aa-053dc58b6f0a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Lfm+kD1KGFDo6AxNFFEKATwxKoOb7aUZyTxpGCpyhH0=	2026-09-28 11:41:22.647439+05:30	2026-09-21 11:41:23.065486+05:30	\N	2026-09-21 11:41:22.686388+05:30	2026-09-21 11:41:23.069682+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
11fe95ee-8d39-4112-ba14-270de55e6c8a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	J4C2saB7c80VzH5omTI1yIUNs3oJ2ed05FcOafmIwbA=	2026-09-28 11:41:23.066686+05:30	2026-09-21 12:10:15.051198+05:30	\N	2026-09-21 11:41:23.069682+05:30	2026-09-21 12:10:15.052513+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c37447a7-1199-44a9-adcb-12ee1b4c753b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eI9Tl/BUwuOqoVLd2L8i9UG8G7vOFH1EU0pLjOSFD4M=	2026-09-28 12:10:15.052165+05:30	2026-09-21 12:22:53.206571+05:30	\N	2026-09-21 12:10:15.052513+05:30	2026-09-21 12:22:53.207812+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8e49fed3-b3f7-4eb3-b6fb-74bf2eb4ec81	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zql2ttZu3lhhVzKcP7+E/FPZLtG8YRotsRI0mVKFuwM=	2026-09-28 12:22:53.206986+05:30	2026-09-21 12:24:32.851876+05:30	\N	2026-09-21 12:22:53.207812+05:30	2026-09-21 12:24:32.852513+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6e74d2a7-56bd-4b2e-9c88-05eb223b6f23	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zGYsJbGvO9DwS5Tr4MXJFAAJ58wu5wmLJLs4eFgRJGg=	2026-09-28 12:24:32.852232+05:30	2026-09-21 12:47:26.767385+05:30	\N	2026-09-21 12:24:32.852513+05:30	2026-09-21 12:47:26.776705+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
defb4248-87b1-4a3f-a7c9-fa1e35ecadbb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	aJasujpJIZ4P76So0zirB2ME9prsvEiRskbWAi2D5EQ=	2026-09-28 12:47:26.774005+05:30	2026-09-21 13:09:02.695248+05:30	\N	2026-09-21 12:47:26.776705+05:30	2026-09-21 13:09:02.698988+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3d26c0f4-2a5e-46b9-9e53-e7e741a0937e	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	DzDVJRuAElX+cTBzcj5a9l9sIWa2jKSr0ouuVkk9uNM=	2026-09-28 13:09:04.473747+05:30	2026-09-21 13:09:32.343409+05:30	\N	2026-09-21 13:09:04.474013+05:30	2026-09-21 13:09:32.343434+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
90a2d421-d8cb-45fd-bdf1-a38bc9cc9276	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	a2JE1XscSgyHdX1ZBQoeBVJ6uSln3x8s2pJd8D0NdbQ=	2026-09-28 13:09:33.046685+05:30	2026-09-21 13:09:35.299306+05:30	\N	2026-09-21 13:09:33.048488+05:30	2026-09-21 13:09:35.299327+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b4b0c82a-d34b-47f7-a546-7c78e888381b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5Fttp6wTuxA+11t9Gal0EkKbDcxHjpX6/J81uOEi8qk=	2026-09-28 13:09:36.025668+05:30	2026-09-21 13:29:43.247669+05:30	\N	2026-09-21 13:09:36.025952+05:30	2026-09-21 13:29:43.261373+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
45f3ebf0-f207-4a2b-8a19-3969c55de7e8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HFWxB0p4AnbdokjbGNBYBdTRCS9AIdf6aFJWP/ICiKw=	2026-09-28 13:29:43.256266+05:30	2026-09-21 13:29:54.47566+05:30	\N	2026-09-21 13:29:43.261373+05:30	2026-09-21 13:29:54.475702+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a308507f-499b-43c2-ba63-8acdcc628fa4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0pjgnz52SW9PdrNcyIV6KOayuMnyKGhWldqA7gnJr2c=	2026-09-28 13:29:55.593136+05:30	2026-09-21 13:31:18.61116+05:30	\N	2026-09-21 13:29:55.593955+05:30	2026-09-21 13:31:18.611187+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3a26ed57-d4f6-48f2-9abc-ebe1c5b89ce1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2M5tTd3Fquzmmuit/YAq0qideSD3d2RWmlPS9nFws2U=	2026-09-28 13:31:19.51844+05:30	2026-09-21 13:32:21.691105+05:30	\N	2026-09-21 13:31:19.518671+05:30	2026-09-21 13:32:21.695602+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
54c47d09-d6cb-4021-a5fb-baee02a662ed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xYRrnUnZTWk68ytvn+7tZtMYRSQp0t/fvo0xyaeNN0w=	2026-09-28 13:32:21.691522+05:30	2026-09-21 13:33:05.464338+05:30	\N	2026-09-21 13:32:21.695602+05:30	2026-09-21 13:33:05.465049+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a850fb2e-e472-4f9a-9e4d-3e2cdae38511	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SRYrb9o9AWcX/CDNZriNOqbqToBTzU+x4Ua/F/FahqM=	2026-09-28 13:33:05.464805+05:30	2026-09-21 13:33:46.808929+05:30	\N	2026-09-21 13:33:05.465049+05:30	2026-09-21 13:33:46.810661+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
198993c7-7e41-4a85-a697-0051c54abaa0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	m6w1rE1ZsxbZth1rpX03h+ok3Gw3dnnBQwwHqpEfGuk=	2026-09-28 13:33:46.809433+05:30	2026-09-21 13:36:19.371509+05:30	\N	2026-09-21 13:33:46.810661+05:30	2026-09-21 13:36:19.371539+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7c4c9fa8-7588-452b-a5c7-d72953ac69fe	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ILWy+h5kP6aJHsNTsEGEvssD+dn+eCqmPWMJeCT1jc8=	2026-09-28 13:36:20.151303+05:30	2026-09-21 13:36:51.521281+05:30	\N	2026-09-21 13:36:20.151554+05:30	2026-09-21 13:36:51.521301+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5092f9e6-8afb-4c32-b900-121ff5bd8ae6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OfmSweI/F1tQF98Zf0cOOKSZ+QQQJ/m6WXuZrZhcrFc=	2026-09-28 13:36:54.78157+05:30	2026-09-21 13:37:09.119529+05:30	\N	2026-09-21 13:36:54.78192+05:30	2026-09-21 13:37:09.119552+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
526cebe4-b62d-411d-8a44-cc8ca620b4fd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2A1SAGqZuWYXBxxKVjOf+qfn01dPnSqTzKP+lLxZ3Vw=	2026-09-28 13:37:10.747399+05:30	2026-09-21 13:41:43.262793+05:30	\N	2026-09-21 13:37:10.747848+05:30	2026-09-21 13:41:43.262812+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c2eddea7-60a5-4b33-828a-e13fa9ccedde	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	KQMcQplB2CgAu0W1aIjRxzR9BrbqN1vwsRil7OegsSQ=	2026-09-28 13:41:44.317612+05:30	2026-09-21 13:43:01.1684+05:30	\N	2026-09-21 13:41:44.317921+05:30	2026-09-21 13:43:01.16897+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4c29eba3-894a-4a25-ae38-02e0d65e9dbe	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bRHjUgD62uYDuq3IftLQylHpJPVEVv94W2XddNwsIqE=	2026-09-28 13:43:01.168802+05:30	2026-09-21 14:52:56.846965+05:30	\N	2026-09-21 13:43:01.16897+05:30	2026-09-21 14:52:56.849774+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
03c75c91-58a9-4ec2-afa3-1fc0e6d218e0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1Zcmp8XQN21texBuHPC+/+iFsiCzaSLiafCp5+fD6Ok=	2026-09-28 14:52:57.512019+05:30	2026-09-21 15:32:11.977049+05:30	\N	2026-09-21 14:52:57.513518+05:30	2026-09-21 15:32:12.028049+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eb049776-14b0-4af3-9fdc-4f0d95e8bade	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xGgq+3j6Ibwz4MSNgwR6CxUYJBrNqiiFTPCoxLw5l1g=	2026-09-28 15:32:12.0076+05:30	2026-09-21 16:03:46.417967+05:30	\N	2026-09-21 15:32:12.028049+05:30	2026-09-21 16:03:46.43922+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6d24fcf9-cf06-4424-86fc-f028c325f3f8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tviVzfZk/2qcYuhNnPXIeXiSg6ey966pN629BmqKuUk=	2026-09-28 16:03:46.431127+05:30	2026-09-21 16:34:25.931817+05:30	\N	2026-09-21 16:03:46.43922+05:30	2026-09-21 16:34:25.971245+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
869a5a7f-33d6-487a-9b07-59dc3e45fff5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ar9E2adwY46eTMYBRC7wVrdYuK9nWI+ZHtpqtVhhjCg=	2026-09-28 16:34:25.957141+05:30	2026-09-21 17:08:13.179042+05:30	\N	2026-09-21 16:34:25.971245+05:30	2026-09-21 17:08:13.216375+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
db3f64ba-0494-4d52-b047-505278bf2f77	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	q7/sV33dA0uS2Xfnnb2zJ1YnonYTSte+S7XODn5RzKM=	2026-09-28 17:08:13.20277+05:30	2026-09-21 17:08:20.437233+05:30	\N	2026-09-21 17:08:13.216375+05:30	2026-09-21 17:08:20.43855+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bc8530ae-3b7b-426f-b033-84a3c7bb706a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	X0QMJ3phkw6J6k6OTKZmeoX9KxrvKPA5cKY8rc17GvM=	2026-09-28 17:08:20.437562+05:30	2026-09-21 17:28:09.973616+05:30	\N	2026-09-21 17:08:20.43855+05:30	2026-09-21 17:28:09.974081+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
60f0de4e-7bcd-464c-a729-733cc7b4b853	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	F1VKLJOfPkFJN/AxW5K4EhzSH1Y8g0i7hb+sDFZntVI=	2026-09-28 17:28:10.770596+05:30	2026-09-21 18:47:13.863339+05:30	\N	2026-09-21 17:28:10.774164+05:30	2026-09-21 18:47:13.911469+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c3c7a868-4431-439e-b5fe-72452a8e1375	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5Io4rbCBCDijxj/xCv8a4GJWiLMluiKPZX15ruFTHbI=	2026-09-28 18:47:13.893015+05:30	2026-09-21 19:00:30.323115+05:30	\N	2026-09-21 18:47:13.911469+05:30	2026-09-21 19:00:30.334031+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1af76322-d476-40bf-9da7-53790e0ece77	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	dRCQ9CnmvN2kLcap2rDmj1tCGS3Ip9GyEM+AXWlBPys=	2026-09-28 19:00:30.325399+05:30	2026-09-21 19:19:09.626397+05:30	\N	2026-09-21 19:00:30.334031+05:30	2026-09-21 19:19:09.653656+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a053768c-ede6-4a47-a22e-91e1a222eb65	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9EJ3BNfmaWdJNsYmJJL5v28LOuevNZdQ30o/+zZjEQ0=	2026-09-28 19:19:09.649222+05:30	2026-09-23 16:38:20.178131+05:30	\N	2026-09-21 19:19:09.653656+05:30	2026-09-23 16:38:20.200225+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b41003bd-b1ec-483e-af30-d151e2b838a4	1a077a8c-4029-8ded-d563-19e9b4bdf301	IwH2pTQDHMCv1GW4bLeNa9Jpo2wksEflveikwKpvSTc=	2026-09-30 16:38:22.580205+05:30	2026-09-23 16:38:38.532509+05:30	\N	2026-09-23 16:38:22.59475+05:30	2026-09-23 16:38:38.532553+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
52ee201f-01cb-4496-b159-98e663965bcb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	50OR9L+PQyrmFykGQxo9Mrfr07OPBH7Clztkz0073ok=	2026-09-30 16:38:39.560916+05:30	2026-09-23 16:42:35.003068+05:30	\N	2026-09-23 16:38:39.561547+05:30	2026-09-23 16:42:35.004143+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a2ebaf7f-50f3-4149-8a23-5d589d996aeb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	M/6hlKRODEUQxezxETYIWefHAt99pI6WOkP3Eg03ilQ=	2026-09-30 16:42:35.003727+05:30	2026-09-23 16:50:34.951518+05:30	\N	2026-09-23 16:42:35.004143+05:30	2026-09-23 16:50:34.952913+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
919e1047-1443-470e-b4ef-c89d5726364d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fV1Ba49zEH3diWJifi6CIL5ATghj3rBZQIxZq+RNch4=	2026-09-30 16:50:36.68291+05:30	2026-09-23 17:01:42.02214+05:30	\N	2026-09-23 16:50:36.689495+05:30	2026-09-23 17:01:42.022184+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e8ca3d4e-35e2-404a-b04b-9bf7ea262b54	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	V/I1HEgR5UE4q8oVaU35lRxoy6+CxMbqITfWG7Bg8UA=	2026-09-30 17:01:43.556962+05:30	2026-09-23 17:02:10.045156+05:30	\N	2026-09-23 17:01:43.557726+05:30	2026-09-23 17:02:10.045198+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e69ba079-6953-4fdb-b1d2-8f593f6e9b69	1a077a8c-4029-8ded-d563-19e9b4bdf301	fDLDV1u8cqvFpBO1AuzgcUJk9uhAZAlYVIZmel93fiU=	2026-09-30 17:02:11.359934+05:30	2026-09-23 17:14:54.896122+05:30	\N	2026-09-23 17:02:11.360823+05:30	2026-09-23 17:14:54.92009+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5faa7fad-0c7a-4950-a950-0f61575ff5d4	1a077a8c-4029-8ded-d563-19e9b4bdf301	PjW5iEy+rBFGfzDdHdqzs8Q/lFSLhE/pravhJB7X6uU=	2026-09-30 17:14:54.912677+05:30	2026-09-23 17:45:24.991797+05:30	\N	2026-09-23 17:14:54.92009+05:30	2026-09-23 17:45:24.991839+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ea83ca6a-8af6-4808-9285-de8698b5894f	730809c0-fc01-a664-03ca-28e0e32d0393	6YsAat5MYcmjEYgw7RNuSUCvEe8iUJOCQQQauGwU4SM=	2026-09-30 17:45:25.565601+05:30	2026-09-23 17:45:28.417305+05:30	\N	2026-09-23 17:45:25.566789+05:30	2026-09-23 17:45:28.421569+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c9c55610-d8d1-439f-b4dd-f6aee588537c	730809c0-fc01-a664-03ca-28e0e32d0393	LdPrKLrOWyGf02yPsNZED79sGFIL4obj0j71Hzsls7U=	2026-09-30 17:45:28.41787+05:30	2026-09-23 17:50:08.471055+05:30	\N	2026-09-23 17:45:28.421569+05:30	2026-09-23 17:50:08.472017+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
24d86b55-2b35-4e37-9b85-43357a1d8ead	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	cVyEKnweqNxhiYJ+HWRWkCvKYBAdY1RyMWyC3FpYtPE=	2026-09-30 17:50:09.174311+05:30	2026-09-23 17:52:03.686329+05:30	\N	2026-09-23 17:50:09.174532+05:30	2026-09-23 17:52:03.686352+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2ab4f91b-ef12-4578-b8ab-8394edae4788	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TWnxbY2plxLwrJivqHEDIiDTx+13TwYxA6QghnW2how=	2026-09-30 17:52:04.258292+05:30	2026-09-23 17:52:11.340826+05:30	\N	2026-09-23 17:52:04.258567+05:30	2026-09-23 17:52:11.340838+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5c8bd3d9-17eb-4a3a-b5ef-2a55b035042f	e7554ba2-e546-93ce-1e88-a073badd78a2	X3s+Mh5YxD6QtjmIJeLu7QtSdkvD+eJk7JjF4HIU+MQ=	2026-09-30 17:52:11.974943+05:30	2026-09-23 18:06:44.121767+05:30	\N	2026-09-23 17:52:11.975134+05:30	2026-09-23 18:06:44.125459+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fd3e5b77-69e9-4450-9430-7f667b52ac8a	e7554ba2-e546-93ce-1e88-a073badd78a2	6QFKMk597sAQHL2dXkkVMFVAA76kEWI5I7/Vd6ie9/w=	2026-09-30 18:06:44.12426+05:30	2026-09-23 18:09:29.076004+05:30	\N	2026-09-23 18:06:44.125459+05:30	2026-09-23 18:09:29.076018+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7a85a0d5-2dce-4bb7-83d1-5d54585b826a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qymy4vqbCfz/RViSVowZrtD9UbdFlAto6h5BkdAOghA=	2026-09-30 18:09:29.809501+05:30	2026-09-24 11:23:13.201447+05:30	\N	2026-09-23 18:09:29.809684+05:30	2026-09-24 11:23:13.253524+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1ba85538-96a3-49a3-9bda-edd617a6a618	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4LM3BuSxrMMTWkFRCg3nZUySkJyQPobR9AExABSZwHM=	2026-10-01 11:23:13.248417+05:30	2026-09-24 11:37:47.086911+05:30	\N	2026-09-24 11:23:13.253524+05:30	2026-09-24 11:37:47.08984+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
01f3f303-acf7-4dbd-acf5-7c8235151d93	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1eYudTc3GCqqqr30wM9waAdJDkMRRgeYEa6Eay7xa30=	2026-10-01 11:37:47.088807+05:30	2026-09-24 12:13:17.643417+05:30	\N	2026-09-24 11:37:47.08984+05:30	2026-09-24 12:13:17.661138+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dab73a6c-2381-4789-bf4e-fc784b7be9f5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nIMGQVycEglHzZpRQDZiDtPdtuRv/EeVfjZgMAxvo0k=	2026-10-01 12:13:17.655502+05:30	2026-09-24 12:14:37.266216+05:30	\N	2026-09-24 12:13:17.661138+05:30	2026-09-24 12:14:37.266239+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3ce1dd8b-d413-41d0-8cc3-4b9560624110	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	UqgqNkJDrLy/UKzatNsqVMf8CyzA7sJA4pZh8DUzEgw=	2026-10-01 12:14:38.968113+05:30	2026-09-24 12:40:59.397088+05:30	\N	2026-09-24 12:14:38.968302+05:30	2026-09-24 12:40:59.3972+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
27ca3a81-642a-4cce-8663-b995a7c68d6c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DNuZ9D2EVvVbXv6HwA+ILVrgCXXyLMWbHo3TBUKXgxk=	2026-10-01 12:41:01.503044+05:30	2026-09-24 12:45:12.963868+05:30	\N	2026-09-24 12:41:01.504325+05:30	2026-09-24 12:45:12.965252+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
05cda2bc-934d-4163-b215-60d470edce0e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/LGDIEXGiJwlUzaZ6n/vBWrl/nlNc3Q+LwA/XdYyKME=	2026-10-01 12:45:12.964973+05:30	2026-09-24 15:37:42.231064+05:30	\N	2026-09-24 12:45:12.965252+05:30	2026-09-24 15:37:42.248766+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
56cffdde-f28f-4987-92b7-73187ae1e3e1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UTOTyituByTGam8LYp4puVnKrjiWuRif6DZXcsmkuqU=	2026-10-01 15:37:42.244983+05:30	2026-09-24 15:38:27.079968+05:30	\N	2026-09-24 15:37:42.248766+05:30	2026-09-24 15:38:27.080002+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5b759fc3-913d-4a1e-84cb-afe82e7ab716	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a9PeliwoLbQa16pEm2fuBPoBaiiAEPWpThZZNCqPvBs=	2026-10-01 15:39:00.458462+05:30	2026-09-24 15:39:57.789161+05:30	\N	2026-09-24 15:39:00.458894+05:30	2026-09-24 15:39:57.789194+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b1c010bd-93a7-4c0c-9310-4f9655671ae5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zJYv/IxUcJzDFnkglFOi5KXAcW1gCyEbwCGjkF/aTiw=	2026-10-01 15:40:21.162454+05:30	2026-09-24 16:20:35.281514+05:30	\N	2026-09-24 15:40:21.162778+05:30	2026-09-24 16:20:35.307353+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
df2f86f5-5c8e-4f74-b824-447520ab76e9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CHIlt7aF3BwZqpAdIoYsmuChwdMYi5FQ39xBqAvK71g=	2026-10-01 16:20:35.295741+05:30	2026-09-24 16:33:32.548812+05:30	\N	2026-09-24 16:20:35.307353+05:30	2026-09-24 16:33:32.548833+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f8b55936-c334-4395-bd86-5ed88a04ee08	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	W4TDdhc0LBi4VFx/NFsc4MLbcIv/ySMKx7dvI+rN7ok=	2026-10-01 16:59:32.942627+05:30	2026-09-24 17:01:28.178047+05:30	\N	2026-09-24 16:59:32.957747+05:30	2026-09-24 17:01:28.178067+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4556337a-6fd7-47d6-8c8c-1b08a456c44d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	wqo2PG4EOgKH3MFc6jqlVuyegLEH4mG0+l1zlHZeITI=	2026-10-01 17:18:42.146567+05:30	2026-09-24 17:21:01.881161+05:30	\N	2026-09-24 17:18:42.15504+05:30	2026-09-24 17:21:01.883986+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2b5afff2-d688-45b0-97fe-4d772b19f925	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	7nVHpPf87e+knwkYCKXdwzINDqUZu96IAV7Q1gB0q6U=	2026-10-01 17:21:01.882792+05:30	2026-09-24 17:21:08.345257+05:30	\N	2026-09-24 17:21:01.883986+05:30	2026-09-24 17:21:08.345683+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
223d903d-6ba7-471c-87fd-d38e93cc02b2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	q3v+9Fq84Q+oy1lhQbUbS7TQp6raLTw0sTKVcFhlm4c=	2026-10-01 17:21:08.345506+05:30	2026-09-24 17:22:53.353293+05:30	\N	2026-09-24 17:21:08.345683+05:30	2026-09-24 17:22:53.359536+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a9bcc83a-3f92-4196-87ee-dd73587f93d3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8RPvwgpKdjdGNalf0TvZif/ypqorAffI5DJYQGxfbpU=	2026-10-01 17:22:53.35519+05:30	2026-09-24 17:25:38.672236+05:30	\N	2026-09-24 17:22:53.359536+05:30	2026-09-24 17:25:38.676405+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
49a896d3-f60b-4a4c-94e1-6866d5426f4d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TNvn/OAtvkRolZqSXvWoyTIrRsE0xnh2l7/dZfvM/UA=	2026-10-01 17:25:38.672867+05:30	2026-09-24 17:25:42.988314+05:30	\N	2026-09-24 17:25:38.676405+05:30	2026-09-24 17:25:42.98893+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bbb5c2cc-c2cf-400b-ae49-20489ed59000	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Wb8CeDIBG5Nnoh2fB2b82xO14zFasNolHCsZ3TAkqIk=	2026-10-01 17:25:42.988715+05:30	2026-09-24 17:25:44.790137+05:30	\N	2026-09-24 17:25:42.98893+05:30	2026-09-24 17:25:44.790667+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
706fd7a7-bbda-4832-9f6d-55342abc46b2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vXx1rGHKsQUJXw6Sb01ko5peOyljRhwDAi8pIybs4tE=	2026-10-01 17:25:44.790364+05:30	2026-09-24 17:29:55.534139+05:30	\N	2026-09-24 17:25:44.790667+05:30	2026-09-24 17:29:55.535303+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
548e8455-cec9-49e0-b362-9be5c6e122c8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	kNRr6tpv+wxBaDS1H6rSRRFA1cuHqpMzONSfD8jy63c=	2026-10-01 17:29:55.534494+05:30	2026-09-24 17:30:59.856286+05:30	\N	2026-09-24 17:29:55.535303+05:30	2026-09-24 17:30:59.860488+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b39658c4-689b-4ee1-b85d-c0a31ccd53dd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	z1qa8FDx3BZz2pyjt7ntOeZ2FuvD2g9SfmqOoa1cFyQ=	2026-10-01 17:30:59.856479+05:30	2026-09-24 17:31:01.430419+05:30	\N	2026-09-24 17:30:59.860488+05:30	2026-09-24 17:31:01.431638+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
78eb78ad-4fcb-4320-83c8-1ef4ab2ddd81	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SFQe53tbP4Ln3AuzfL68/+fC29ReA6NEGU3eDj40/Bc=	2026-10-01 17:31:01.430957+05:30	2026-09-24 17:31:02.498823+05:30	\N	2026-09-24 17:31:01.431638+05:30	2026-09-24 17:31:02.499323+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c0a090f6-bbb9-4b02-a500-eab5a464f727	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	d2GNNUV78ILosbn7JccHvPYvJoWAZ5wbZTs/9NJrpS8=	2026-10-01 17:31:02.499184+05:30	2026-09-24 17:31:08.452651+05:30	\N	2026-09-24 17:31:02.499323+05:30	2026-09-24 17:31:08.453165+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9038ddfe-04a6-40b3-b887-5b2463c2e979	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	aoLOX3bwr50wPQgDzdRoHz5BDck8hDqHFAQOLB3D9kU=	2026-10-01 17:31:08.453037+05:30	2026-09-24 17:31:09.417187+05:30	\N	2026-09-24 17:31:08.453165+05:30	2026-09-24 17:31:09.417875+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
052947d2-1a97-40be-8d6b-da3b29cdd74e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	L4ghvvdXBMilVESVAUKr/DCyG54F1YhbIDUqGBpWGlA=	2026-10-01 17:31:09.417694+05:30	2026-09-24 17:33:07.163075+05:30	\N	2026-09-24 17:31:09.417875+05:30	2026-09-24 17:33:07.163479+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b96c1761-d4fc-46aa-aafe-3b433bfa826c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fvwoU9+ZWkxAwFVYlNua8a6nWeX+IZPIQGC7eJ9SHXI=	2026-10-01 17:33:07.163302+05:30	2026-09-24 18:06:39.590474+05:30	\N	2026-09-24 17:33:07.163479+05:30	2026-09-24 18:06:39.621953+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
57549407-1c72-4315-9443-b230dbbd2f3d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ooz1iC7oDuk3gCM/8e3iDH5NuEhhfyya7Q7fDHBizqM=	2026-10-01 18:06:39.611896+05:30	2026-09-24 18:06:40.929307+05:30	\N	2026-09-24 18:06:39.621953+05:30	2026-09-24 18:06:40.930791+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2a9fd871-bddd-492b-98c3-d87f19d407df	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	q8i3s1rw8WhujzGfA737/FswEzbLCYqt/w2LayoksQw=	2026-10-02 09:44:34.486833+05:30	2026-09-25 09:44:45.031874+05:30	\N	2026-09-25 09:44:34.500935+05:30	2026-09-25 09:44:45.069993+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dd6d632a-c8f9-46fc-94d0-c09b3b5308cf	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GbuHLJR+qtxNwyV8dCEyZO67F9eI+MAl3dR/KWV3uAU=	2026-10-01 18:06:40.930617+05:30	2026-09-25 09:44:34.470737+05:30	\N	2026-09-24 18:06:40.930791+05:30	2026-09-25 09:44:34.500912+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
93ef43d5-721c-476f-ba99-2eaaf3876f3a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CUqhgp6iDOxBj2lbHYOlOYMgwnX2xwJMkBhsVosx/Nk=	2026-10-02 09:44:45.047995+05:30	2026-09-25 10:05:10.669598+05:30	\N	2026-09-25 09:44:45.069993+05:30	2026-09-25 10:05:10.740731+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
55269862-69c2-45dd-8c3e-5d3989b3f9db	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OQna3cmS59KD2Peq3ad4F0z6G3CiINytkn9Cbck8SA4=	2026-10-02 10:05:10.730542+05:30	2026-09-25 11:22:58.219951+05:30	\N	2026-09-25 10:05:10.740731+05:30	2026-09-25 11:22:58.25064+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
54e1a162-1d2e-4a86-8e34-8da0a9420085	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Ak7m9bVcOdYZRF0Atouhniq3C4A0LpZn9RAK3SpJruU=	2026-10-02 11:22:58.242248+05:30	2026-09-25 11:40:01.20735+05:30	\N	2026-09-25 11:22:58.25064+05:30	2026-09-25 11:40:01.210156+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bb1c2894-a70d-4cb5-8196-d74be432d66b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	kzUdIdxjLenhIYz9rBGp7trIUjLBACtQhhCK+aeB3+g=	2026-10-02 11:40:01.209586+05:30	2026-09-25 13:24:29.006305+05:30	\N	2026-09-25 11:40:01.210156+05:30	2026-09-25 13:24:29.007353+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4c627408-4b3b-4613-93e6-90bc3804cb2a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zWEeQFpqqYxlqXairZ9rfr8sZVj7yip1MRxkiLXY5a0=	2026-10-02 13:24:29.006899+05:30	2026-09-25 13:30:17.98505+05:30	\N	2026-09-25 13:24:29.007353+05:30	2026-09-25 13:30:17.985657+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2ee29876-625b-47bf-9bf3-3b9c19c88201	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	EYXaDBjdJ7P3VDjBwDk9HdrPo4hyBSNnQDkTBsWhXAY=	2026-10-02 13:30:17.985425+05:30	2026-09-25 13:32:09.889902+05:30	\N	2026-09-25 13:30:17.985657+05:30	2026-09-25 13:32:09.89403+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a7ea0770-e589-46ea-9955-983a8ce5160f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3cKZz4ejo4dw/3mHfRUkajFZZf3dUGeptaHdMeOffM4=	2026-10-02 13:32:09.89382+05:30	2026-09-25 13:44:07.802471+05:30	\N	2026-09-25 13:32:09.89403+05:30	2026-09-25 13:44:07.820548+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bdd5e3e3-494e-4035-814c-c1d0addc25b4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fLoc+rwoXZ+z5IkfqhllrAogclOWmZi/nQCTZALAHbM=	2026-10-02 13:44:07.812622+05:30	2026-09-25 19:23:13.56447+05:30	\N	2026-09-25 13:44:07.820548+05:30	2026-09-25 19:23:13.698628+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
24fa84a5-7328-453c-aaa9-1c05f3ecfc51	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8ApfHVkMSm978vmNG7Xmj7Q0+DYG0QyGzK+65eLQfio=	2026-10-02 19:23:13.67791+05:30	2026-09-25 19:29:24.621557+05:30	\N	2026-09-25 19:23:13.698628+05:30	2026-09-25 19:29:24.625315+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ed681eb3-3606-4c58-8448-ef8db0a4fb03	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	hHcM8dxa4+LPIJmsnoDbc35D7AuRdsCWXTawjkFMtJg=	2026-10-02 19:29:25.934158+05:30	2026-09-25 19:42:05.345515+05:30	\N	2026-09-25 19:29:25.94021+05:30	2026-09-25 19:42:05.345533+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
698b399a-53d3-4801-905a-6229f7431a98	70902d9d-f74f-670b-d4f5-7d593db9d5e8	7rXjCyJIb9aJT9JcBBS2WVMHecTmhvQk6YDT6+f7u7I=	2026-10-02 19:42:05.850722+05:30	2026-09-25 20:10:07.684679+05:30	\N	2026-09-25 19:42:05.851551+05:30	2026-09-25 20:10:07.688699+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b0391cd2-8fd3-4f07-a304-24f448f2be3b	70902d9d-f74f-670b-d4f5-7d593db9d5e8	wTfKO/OcmULD6vqhBYJVmCxw7EusG+POBm3ujlKRg+s=	2026-10-02 20:10:07.687641+05:30	2026-09-25 20:11:33.879144+05:30	\N	2026-09-25 20:10:07.688699+05:30	2026-09-25 20:11:33.879159+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
68f41185-9401-4742-8577-28122fd3a95e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	c2rOlW550oh4uLsU0f0Q5g/o3+Rn0L2uWG6XL2+TWaI=	2026-10-02 09:44:34.491428+05:30	2026-09-25 20:11:34.482975+05:30	\N	2026-09-25 09:44:34.500912+05:30	2026-09-25 20:11:34.483694+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b9f327ff-833f-4165-858b-5d161dfaad08	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	FQNi4n8yTR8VI/Xb6IYzv+qfFaAWUEz1938Xr7aK3K8=	2026-10-02 20:11:34.483533+05:30	\N	\N	2026-09-25 20:11:34.483694+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: repository; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repository ("Id", "FileName", "Category", "Size", "LastUpdated", "UploadedBy", "FilePath", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	25	2026-08-25 12:52:47.738454+05:30	Dhanshree Pansare	repository/pms/20260825_072247_718_financial_report.xlsx	2026-08-25 12:52:47.810202+05:30	2026-08-25 15:10:43.668112+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:10:43.668112+05:30
2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	17754568	2026-08-24 00:01:21.474426+05:30	Admin User	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/20260823_183121_383_document.pdf	2026-08-24 00:01:21.564645+05:30	2026-08-25 15:10:45.54175+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:10:45.54175+05:30
06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	27	2026-08-23 23:42:46.368514+05:30	Compliance Officer	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/imp/20260823_181246_366_Company_Compliance_Policy.pdf	2026-08-23 23:42:46.39232+05:30	2026-08-25 15:10:47.36039+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:10:47.36039+05:30
f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	16	2026-08-23 23:42:46.310679+05:30	PMS Manager	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/20260823_181246_304_PMS_Workflow_Spec.docx	2026-08-23 23:42:46.312803+05:30	2026-08-25 15:10:49.106488+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:10:49.106488+05:30
e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	33	2026-08-23 23:42:30.416433+05:30	Curl Tester	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/20260823_181230_394_Sample_Architecture_Guide.pdf	2026-08-23 23:42:30.4294+05:30	2026-08-25 15:10:52.374735+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:10:52.374735+05:30
b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	1572864	2026-08-17 23:40:16.325141+05:30	Rahul Gupta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/Security_Incident_Response_Plan.pdf	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:10:55.367843+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:10:55.367843+05:30
aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	614400	2026-08-15 23:40:16.325536+05:30	Vikrant Malhotra	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/imp/Remote_Work_Policy.pdf	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:10:57.192443+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:10:57.192443+05:30
706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	655360	2026-08-15 23:40:16.325375+05:30	Rahul Gupta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/Resource_Allocation_SOP.pdf	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:10:58.873408+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:10:58.873408+05:30
f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	819200	2026-08-07 23:40:16.325637+05:30	Anita Desai	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/imp/Leave_and_Attendance_Policy.pdf	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:11:00.896423+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:11:00.896423+05:30
f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	327680	2026-08-02 23:40:16.325432+05:30	Aarav Mehta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/Change_Request_Management_Process.docx	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:11:02.745863+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:11:02.745863+05:30
81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	524288	2026-07-26 23:40:16.32521+05:30	Riya Kapoor	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/Project_Onboarding_Checklist.pdf	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:11:04.865657+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:11:04.865657+05:30
303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	1048576	2026-07-07 23:40:16.325485+05:30	Vikrant Malhotra	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/imp/Code_of_Conduct_2026.pdf	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:11:08.982288+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:11:08.982288+05:30
40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	786432	2026-07-07 23:40:16.325269+05:30	Aarav Mehta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/WBS_Creation_Guidelines.docx	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:11:11.173993+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:11:11.173993+05:30
0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	1048576	2026-07-07 23:40:16.324056+05:30	Vikram Shah	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/CI_CD_Pipeline_Setup_Procedures.docx	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:11:13.552185+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:11:13.552185+05:30
b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	409600	2026-07-05 23:40:16.325322+05:30	Riya Kapoor	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/Timesheet_Submission_Process.pdf	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:11:15.5612+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:11:15.5612+05:30
c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	2457600	2026-07-02 23:40:16.247186+05:30	Rahul Gupta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/API_Gateway_Configuration_Guide.pdf	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:11:17.889839+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:11:17.889839+05:30
1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	2097152	2026-06-28 23:40:16.325588+05:30	Anita Desai	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/imp/Data_Privacy_and_GDPR_Guidelines.pdf	2026-08-23 23:40:16.325673+05:30	2026-08-25 15:11:20.130903+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:11:20.130903+05:30
f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	3145728	2026-07-27 23:40:16.325014+05:30	Aarav Mehta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/Database_Backup_and_Recovery_SOP.pdf	2026-08-23 23:40:16.325673+05:30	2026-08-25 13:11:58.113952+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 13:11:58.113952+05:30
ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	34	2026-08-25 14:58:11.650702+05:30	Dhanshree Pansare	repository/tech/20260825_092811_639_devops_guidelines.pdf	2026-08-25 14:58:11.712525+05:30	2026-08-25 15:10:38.242373+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:10:38.242373+05:30
3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	21506	2026-08-25 13:08:51.55257+05:30	Admin User	repository/imp/20260825_073851_528_TK_I_PMS_Tool_I_Timeline_I_V01__1.xlsx	2026-08-25 13:08:51.554397+05:30	2026-08-25 15:10:41.563467+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 15:10:41.563467+05:30
cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	13161	2026-08-25 15:11:56.891164+05:30	Admin User	repository/imp/20260825_094156_853_TK_I_PMS-Tool_I_Roles___Processes_1.xlsx	2026-08-25 15:11:56.894914+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	8176221	2026-08-25 15:14:59.377826+05:30	Admin User	repository/pms/20260825_094459_333_KEKA_-_PMS_Module_guide.pdf	2026-08-25 15:14:59.379004+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	16	2026-08-25 15:23:45.564045+05:30	Admin User	repository/tech/20260825_095345_527_PMS_Workflow_Spec.docx	2026-08-25 15:23:45.566515+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	458969	2026-08-25 16:57:29.149632+05:30	Admin User	repository/pms/20260825_112729_130_TK_Tender_Summary_template__071223.pptx	2026-08-25 16:57:29.151008+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	187688	2026-08-25 15:16:52.823561+05:30	Admin User	repository/tech/20260825_094652_817_RFP_2026_7206600_Report__2.pptx	2026-08-25 15:16:52.824368+05:30	2026-08-26 16:38:01.654587+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-26 16:38:01.654587+05:30
30a35f7e-125c-4f3c-8d1e-3bd8ecf171f9	ESIC_Info Sheet 1(Sheet1).xlsx	Tech	10582	2026-09-07 12:38:01.973455+05:30	Admin User	Tech. SOPs/20260907_070801_936_ESIC_Info_Sheet_1_Sheet1.xlsx	2026-09-07 12:38:02.238716+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1c049f2b-4d7f-45cc-a6d1-b5170594063c	Phase_1_Story_Table.xlsx	Tech	6306	2026-09-07 14:28:07.267592+05:30	Admin User	Tech. SOPs/20260907_085807_236_Phase_1_Story_Table.xlsx	2026-09-07 14:28:07.269976+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: repository_activity_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repository_activity_logs ("Id", "Action", "DocumentId", "FileName", "Category", "PerformedBy", "Details", "CreatedAtUtc", "DeletedAtUtc", "CreatedBy", "UpdatedBy", "UpdatedAtUtc") FROM stdin;
d607a02c-2ed9-488d-a606-d9fd47a439e9	Uploaded	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Dhanshree Pansare	Dhanshree Pansare uploaded financial_report.xlsx	2026-08-25 12:52:47.810202+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
281f8c04-8e17-4c42-b856-e67ce0b8a0af	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 12:53:00.745697+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
78b454bc-6152-47a6-8662-b9d95a57581d	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 12:53:24.952618+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6554b6e5-2bed-4ee7-b6d0-f7e459c5b582	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:01:11.043031+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d26a4058-4793-45f3-be4e-c987d05b9754	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 13:01:15.165521+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a28b7611-1533-4c98-8ee7-e4e8f421c855	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:02:28.926641+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e83225de-cf2a-43c6-89e5-f48d11036851	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:03:14.559786+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
10ef4d3b-c8e1-456b-b6a4-68df639d440b	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:30:41.238362+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
28faca31-dce1-4ea8-8c95-e50366d9cb18	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:31:19.114777+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4b9f4a36-4cd1-4a1f-8d85-df03842e45b8	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:31:24.103884+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
73eaf7b9-b2c1-40d3-b7b8-d447e9d584c7	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:49:06.78787+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
02f475ec-54fc-4fd4-b9f1-eadcbae842a1	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:51:04.064861+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
765e1131-5007-41d5-a0e9-d1388d35805b	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:52:48.385103+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3b51ab42-d7ea-4f29-925a-384eb4c455cc	Downloaded	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co downloaded devops_guidelines.pdf	2026-08-25 14:59:29.989454+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d7604a59-0aac-45de-89ff-a8a73d7fe619	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Admin User viewed devops_guidelines.pdf	2026-08-25 15:02:36.020934+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
12bde8dc-dd37-434f-8a33-de22b69388c6	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 15:02:36.039749+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8a504a55-9279-4cc9-bcf0-6eebb19e849a	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 15:02:39.499136+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ddb08c36-c3a4-4937-ae9a-3fda9262e589	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	admin@acme.co	admin@acme.co viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 15:02:39.513797+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4818b1e2-5560-4cc2-9393-50fecec70c73	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 15:03:49.744384+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c426f146-df7f-414a-b734-2735098bd633	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	admin@acme.co	admin@acme.co viewed Company_Compliance_Policy.pdf	2026-08-25 15:03:49.764944+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
68bb1487-dc9b-47de-b1bd-bfb55172e82f	Deleted	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Deleted devops_guidelines.pdf from Tech	2026-08-25 15:10:38.242373+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7ebf97ee-50be-4352-ae21-cf6a8853be1a	Deleted	3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	Admin User	Deleted TK I PMS Tool I Timeline I V01 (1).xlsx from IMP	2026-08-25 15:10:41.563467+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a10068e1-ef46-4818-9a1b-a664722b020d	Deleted	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Deleted financial_report.xlsx from PMS	2026-08-25 15:10:43.668112+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9af86e4f-24a3-489a-83b5-0cc59b9118d5	Deleted	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Deleted 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf from Tech	2026-08-25 15:10:45.54175+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
192d9d10-513f-42cf-8439-47c7bcfc0639	Deleted	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Deleted Company_Compliance_Policy.pdf from IMP	2026-08-25 15:10:47.36039+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
31dd3381-5245-4b77-aa91-56130b0b22af	Deleted	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Admin User	Deleted PMS_Workflow_Spec.docx from PMS	2026-08-25 15:10:49.106488+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
89ea88b5-2245-4e4e-9e91-ad2ae18f6651	Deleted	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Admin User	Deleted Sample_Architecture_Guide.pdf from Tech	2026-08-25 15:10:52.374735+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7a435d55-8a3e-4a7d-923e-ba77b07d79a6	Deleted	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Admin User	Deleted Security Incident Response Plan.pdf from Tech	2026-08-25 15:10:55.367843+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d9c640bb-3779-4e25-bcfc-4aa406a06390	Deleted	aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	Admin User	Deleted Remote Work Policy.pdf from IMP	2026-08-25 15:10:57.192443+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b980db78-d1df-4564-a97a-1ae5b1f9405d	Deleted	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Deleted Resource Allocation SOP.pdf from PMS	2026-08-25 15:10:58.873408+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
053cbb7e-50f7-445a-ac2c-bf05a715f166	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 12:58:24.734245+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
38187c14-5450-48e1-b655-04122a7513b7	Viewed	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 13:00:35.456428+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d6277cfd-f5b1-490b-a065-6a45d4c167c7	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 13:00:40.183188+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4dc4a04e-6c73-4b7c-bff7-6dc7331cf6da	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 13:00:50.005183+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c44a4ce2-826b-4292-af6b-e21a77a53cab	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:00:58.776721+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a4da1efe-8c23-4c36-9d98-bccc69b1771d	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:02:17.759537+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f576c7d9-d2ab-4467-a20a-1d2e4eb205c7	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 13:02:31.547912+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2f8fa037-364f-4d31-9f64-3cb73ed3fa66	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 13:04:15.428053+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b7180df7-87ce-47f8-b479-9f3a018acd11	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:04:23.975146+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a4704e1e-f1e5-429d-81ae-9ded78a0e033	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 13:04:26.701891+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8f70b43b-6596-4e7b-8585-6f9cdaf6962f	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:04:29.146682+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f78002ab-88dd-482a-bc40-170aaf61c61a	Downloaded	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co downloaded financial_report.xlsx	2026-08-25 13:04:29.220377+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
189f8e28-0ba8-4f05-a0d5-f11b0d3771d4	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 13:04:33.882275+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
01822590-be49-4714-8e58-486ed760f957	Uploaded	3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	Admin User	Admin User uploaded TK I PMS Tool I Timeline I V01 (1).xlsx	2026-08-25 13:08:51.554397+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cc4e9fb1-9d59-427a-a4a4-57142dae140f	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:31:17.704572+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2fb79b63-cbeb-4127-9d38-46d296fb6d1f	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:31:20.121812+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8990236f-a815-4c1f-b387-ffa218ccbaf9	Uploaded	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Dhanshree Pansare	Dhanshree Pansare uploaded devops_guidelines.pdf	2026-08-25 14:58:11.712525+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fcca003f-8bf1-4599-857d-9a545d955846	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 14:58:20.040809+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1b80144c-92d2-4b78-8b5a-91f701b911d1	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	admin@acme.co	admin@acme.co downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:58:34.337088+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
081ef346-a707-4de2-8fcd-94876f718c1f	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	admin@acme.co	admin@acme.co downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:58:34.413384+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ad51b550-0084-499d-832e-6bdb27f64e94	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	admin@acme.co	admin@acme.co downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:58:34.889886+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
56025732-9e30-4676-a82f-be1a205d674c	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	admin@acme.co	admin@acme.co viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:58:54.174345+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7ce0515d-7388-40bd-8448-629506b4da69	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Admin User viewed Resource Allocation SOP.pdf	2026-08-25 15:02:49.583916+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0cb574ba-87a9-408b-869e-0a3def818770	Uploaded	f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	Harsh Nair	Harsh Nair uploaded Leave and Attendance Policy.pdf	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
112e2d3c-91a6-4d6b-baf2-69a76eee25e4	Uploaded	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Nikhil Khanna	Nikhil Khanna uploaded Security Incident Response Plan.pdf	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
50fb80b0-9bd4-44b7-9c5f-d96d3afb5c25	Uploaded	b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	Kavya Desai	Kavya Desai uploaded Timesheet Submission Process.pdf	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
568d9221-2331-4e91-804f-ed096870c14b	Uploaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Ankit Verma	Ankit Verma uploaded Code of Conduct 2026.pdf	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
6abc0e6e-1207-4b06-a9bd-478138cd07c4	Uploaded	c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	Rahul Sharma	Rahul Sharma uploaded API Gateway Configuration Guide.pdf	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
786a9eef-61bd-492f-a368-b6e101d1c84f	Uploaded	0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	Sneha Iyer	Sneha Iyer uploaded CI CD Pipeline Setup Procedures.docx	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
918f5751-2823-4cc9-bcc9-9d5ad87466e4	Uploaded	aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	Arjun Shah	Arjun Shah uploaded Remote Work Policy.pdf	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
924ba339-74fc-4f29-a464-962c2ac302ef	Uploaded	40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	Rahul Sharma	Rahul Sharma uploaded WBS Creation Guidelines.docx	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
96e82a4e-2ecb-4026-9e80-594ffe1ce32a	Uploaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Pooja Menon	Pooja Menon uploaded Resource Allocation SOP.pdf	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
c22e951d-d3f4-4643-b2a7-974db176b428	Uploaded	f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	Vikram Gupta	Vikram Gupta uploaded Database Backup and Recovery SOP.pdf	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
d192afd2-0878-442f-86fc-0127dad4a153	Uploaded	1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	Rohan Mehta	Rohan Mehta uploaded Data Privacy and GDPR Guidelines.pdf	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
e4f2ec92-a167-4cf9-aee3-cc567c1319e0	Uploaded	81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	Pooja Menon	Pooja Menon uploaded Project Onboarding Checklist.pdf	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
e7fce91d-4624-4e18-ba5d-8b510117a3bb	Uploaded	f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	Ira Kapoor	Ira Kapoor uploaded Change Request Management Process.docx	2026-08-23 23:40:16.325673+05:30	\N	\N	\N	\N
94d3b552-8e1c-4393-9592-a20f8d326264	Uploaded	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Karthik Bose	Karthik Bose uploaded Sample_Architecture_Guide.pdf	2026-08-23 23:42:30.4294+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
82fa392e-de1b-4938-b218-26367672f93e	Uploaded	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Rohan Mehta	Rohan Mehta uploaded PMS_Workflow_Spec.docx	2026-08-23 23:42:46.312803+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
108da6bd-194b-4607-a35b-97bb4d293708	Uploaded	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Sneha Iyer	Sneha Iyer uploaded Company_Compliance_Policy.pdf	2026-08-23 23:42:46.39232+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fc0662da-358a-4eb6-9a77-919358b4cb06	Uploaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Samar Patel	Samar Patel uploaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-24 00:01:21.564645+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
14f1c2f2-42c4-4ef3-bb84-5357fbc9be22	Downloaded	0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	Rahul Sharma	Rahul Sharma downloaded CI CD Pipeline Setup Procedures.docx	2026-08-22 17:11:48.449326+05:30	\N	\N	\N	\N
c3fb58a8-01a8-4fe1-9a67-553739f4b2d2	Downloaded	0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	Priya Sharma	Priya Sharma downloaded CI CD Pipeline Setup Procedures.docx	2026-08-21 16:11:48.449326+05:30	\N	\N	\N	\N
5a4e602f-dbc4-463f-a1f6-29de06c8b6ce	Downloaded	0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	Neha Kulkarni	Neha Kulkarni downloaded CI CD Pipeline Setup Procedures.docx	2026-08-22 20:11:48.449326+05:30	\N	\N	\N	\N
204837d6-5ec2-450a-99ed-92293f421b87	Downloaded	1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	Ishita Bansal	Ishita Bansal downloaded Data Privacy and GDPR Guidelines.pdf	2026-08-21 02:11:48.449326+05:30	\N	\N	\N	\N
931015f2-0bed-43a5-b934-ca024860b3d2	Downloaded	1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	Divya Rao	Divya Rao downloaded Data Privacy and GDPR Guidelines.pdf	2026-08-22 14:11:48.449326+05:30	\N	\N	\N	\N
5e5d2408-91b4-4214-acac-7b9b1826e31a	Downloaded	1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	Arjun Mehta	Arjun Mehta downloaded Data Privacy and GDPR Guidelines.pdf	2026-08-22 12:11:48.449326+05:30	\N	\N	\N	\N
8b2808e5-53b8-4aef-beb8-512679d9c20d	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Sneha Iyer	Sneha Iyer downloaded Code of Conduct 2026.pdf	2026-08-23 15:11:48.449326+05:30	\N	\N	\N	\N
d10c04f1-d038-4dda-9231-c03ac2e46843	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Karthik Bose	Karthik Bose downloaded Code of Conduct 2026.pdf	2026-08-21 17:11:48.449326+05:30	\N	\N	\N	\N
2e680325-0b10-48f6-9d10-67875d929aca	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Sneha Iyer	Sneha Iyer downloaded Code of Conduct 2026.pdf	2026-08-21 22:11:48.449326+05:30	\N	\N	\N	\N
76cb1f18-aff6-4a29-afd8-c68c46bcbd9b	Downloaded	40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	Arjun Shah	Arjun Shah downloaded WBS Creation Guidelines.docx	2026-08-22 17:11:48.449326+05:30	\N	\N	\N	\N
8b7a084c-1b75-4117-a2f4-01ce5ef6edd8	Downloaded	40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	Vikram Gupta	Vikram Gupta downloaded WBS Creation Guidelines.docx	2026-08-21 07:11:48.449326+05:30	\N	\N	\N	\N
3e58d5a1-b5ff-4f5c-b22e-f9bda728a3db	Downloaded	40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	Neha Kulkarni	Neha Kulkarni downloaded WBS Creation Guidelines.docx	2026-08-21 20:11:48.449326+05:30	\N	\N	\N	\N
8ff68488-7f36-4304-9bc3-ed8b8ae53c56	Downloaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Karthik Bose	Karthik Bose downloaded Resource Allocation SOP.pdf	2026-08-23 08:11:48.449326+05:30	\N	\N	\N	\N
47d0a623-9a3c-444c-a84e-dd86e1d7e39b	Downloaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Ira Kapoor	Ira Kapoor downloaded Resource Allocation SOP.pdf	2026-08-23 18:11:48.449326+05:30	\N	\N	\N	\N
0b691530-b686-407e-863a-e7524e3a55b8	Downloaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Harsh Nair	Harsh Nair downloaded Resource Allocation SOP.pdf	2026-08-22 15:11:48.449326+05:30	\N	\N	\N	\N
9f162188-c142-49bb-a480-f9e705c6381f	Downloaded	81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	Divya Rao	Divya Rao downloaded Project Onboarding Checklist.pdf	2026-08-23 08:11:48.449326+05:30	\N	\N	\N	\N
e69045d6-8df3-4310-86a9-d2d6d9235252	Downloaded	81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	Pooja Menon	Pooja Menon downloaded Project Onboarding Checklist.pdf	2026-08-22 04:11:48.449326+05:30	\N	\N	\N	\N
4cf570a5-8da5-4120-95f9-dfcc84b79fe5	Downloaded	81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	Rahul Sharma	Rahul Sharma downloaded Project Onboarding Checklist.pdf	2026-08-22 17:11:48.449326+05:30	\N	\N	\N	\N
fde22c76-4ebb-4c2a-aa18-6bf857643c65	Downloaded	aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	Pradeep Singh	Pradeep Singh downloaded Remote Work Policy.pdf	2026-08-23 04:11:48.449326+05:30	\N	\N	\N	\N
b64886f3-6b93-4f46-9b7d-31d2c9da4f0f	Downloaded	aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	Neha Kulkarni	Neha Kulkarni downloaded Remote Work Policy.pdf	2026-08-23 07:11:48.449326+05:30	\N	\N	\N	\N
c214d841-a6a9-4cbc-9054-e9cb3bcd87d4	Downloaded	aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	Rohan Mehta	Rohan Mehta downloaded Remote Work Policy.pdf	2026-08-22 08:11:48.449326+05:30	\N	\N	\N	\N
00583c50-650f-44b0-a4ad-75986cd3929b	Downloaded	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Samar Patel	Samar Patel downloaded Security Incident Response Plan.pdf	2026-08-22 17:11:48.449326+05:30	\N	\N	\N	\N
7fb16b97-ed39-4216-a827-56bd931fcb09	Downloaded	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Ishita Bansal	Ishita Bansal downloaded Security Incident Response Plan.pdf	2026-08-21 20:11:48.449326+05:30	\N	\N	\N	\N
a97f6af6-1da1-48f7-a1e5-d962030d7a19	Downloaded	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Rohan Mehta	Rohan Mehta downloaded Security Incident Response Plan.pdf	2026-08-23 08:11:48.449326+05:30	\N	\N	\N	\N
9951c65b-1f9a-4b0f-be32-04c1e28d3c12	Downloaded	b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	Ishita Bansal	Ishita Bansal downloaded Timesheet Submission Process.pdf	2026-08-21 11:11:48.449326+05:30	\N	\N	\N	\N
9ff8c2cf-ba00-4cf4-a7f8-7bf710ecdb54	Downloaded	b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	Ankit Verma	Ankit Verma downloaded Timesheet Submission Process.pdf	2026-08-22 14:11:48.449326+05:30	\N	\N	\N	\N
a9cf4a0f-3de3-4262-b01b-9bb80e11963d	Downloaded	b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	Arjun Shah	Arjun Shah downloaded Timesheet Submission Process.pdf	2026-08-22 19:11:48.449326+05:30	\N	\N	\N	\N
58e524dc-3c76-4855-9f76-f7acab052fe7	Downloaded	c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	Ankit Verma	Ankit Verma downloaded API Gateway Configuration Guide.pdf	2026-08-22 05:11:48.449326+05:30	\N	\N	\N	\N
065f4cd9-a880-4433-9137-84ce5716de56	Downloaded	c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	Kavya Desai	Kavya Desai downloaded API Gateway Configuration Guide.pdf	2026-08-23 20:11:48.449326+05:30	\N	\N	\N	\N
538c7860-92f7-442a-bde7-0e531217b7d3	Downloaded	c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	Sneha Iyer	Sneha Iyer downloaded API Gateway Configuration Guide.pdf	2026-08-22 01:11:48.449326+05:30	\N	\N	\N	\N
f50e9eae-8198-4ed6-b645-93fec5aa6426	Downloaded	f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	Nikhil Khanna	Nikhil Khanna downloaded Database Backup and Recovery SOP.pdf	2026-08-21 19:11:48.449326+05:30	\N	\N	\N	\N
1b1700b3-2ee8-448d-8935-78a1f59ad7ac	Downloaded	f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	Arjun Shah	Arjun Shah downloaded Database Backup and Recovery SOP.pdf	2026-08-22 03:11:48.449326+05:30	\N	\N	\N	\N
25a35454-d9d7-4e75-86c9-12aaefec0e03	Downloaded	f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	Samar Patel	Samar Patel downloaded Database Backup and Recovery SOP.pdf	2026-08-23 12:11:48.449326+05:30	\N	\N	\N	\N
98a015b6-4a84-4d48-8365-6348fdcba34c	Downloaded	f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	Arjun Mehta	Arjun Mehta downloaded Leave and Attendance Policy.pdf	2026-08-22 16:11:48.449326+05:30	\N	\N	\N	\N
caa35459-c646-4738-a213-e29d6d0ff204	Downloaded	f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	Ishita Bansal	Ishita Bansal downloaded Leave and Attendance Policy.pdf	2026-08-22 22:11:48.449326+05:30	\N	\N	\N	\N
2c966bba-8921-4ca6-83dc-841e191162e1	Downloaded	f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	Aanya Joshi	Aanya Joshi downloaded Leave and Attendance Policy.pdf	2026-08-22 13:11:48.449326+05:30	\N	\N	\N	\N
97a5e3fc-b3c3-46d2-917e-0268fb734405	Downloaded	f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	Arjun Mehta	Arjun Mehta downloaded Change Request Management Process.docx	2026-08-21 12:11:48.449326+05:30	\N	\N	\N	\N
0e193cda-8b76-4b0c-aab1-76dd15b57ef0	Downloaded	f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	Dhanshree Pansare	Dhanshree Pansare downloaded Change Request Management Process.docx	2026-08-21 07:11:48.449326+05:30	\N	\N	\N	\N
0d6a12da-9d19-4f2f-acdf-eb36c780957d	Downloaded	f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	Kavya Desai	Kavya Desai downloaded Change Request Management Process.docx	2026-08-21 04:11:48.449326+05:30	\N	\N	\N	\N
0796c02f-863e-4720-99d0-08e1d22aca4b	Downloaded	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Ira Kapoor	Ira Kapoor downloaded Sample_Architecture_Guide.pdf	2026-08-23 19:11:48.449326+05:30	\N	\N	\N	\N
6705fed4-e7f1-4da3-a994-d1459c40b2d1	Downloaded	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Neha Kulkarni	Neha Kulkarni downloaded Sample_Architecture_Guide.pdf	2026-08-22 02:11:48.449326+05:30	\N	\N	\N	\N
1766f944-696d-49e9-b78b-dc1b2b2f8f38	Downloaded	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Pradeep Singh	Pradeep Singh downloaded Sample_Architecture_Guide.pdf	2026-08-22 05:11:48.449326+05:30	\N	\N	\N	\N
324a41e8-43f5-4a6d-8786-e97437465e21	Downloaded	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Dhanshree Pansare	Dhanshree Pansare downloaded PMS_Workflow_Spec.docx	2026-08-22 05:11:48.449326+05:30	\N	\N	\N	\N
9f4438a2-9b6a-4497-9af1-52ef09bb48b3	Downloaded	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Yash Malik	Yash Malik downloaded PMS_Workflow_Spec.docx	2026-08-23 09:11:48.449326+05:30	\N	\N	\N	\N
2307ba67-c2f2-4277-a088-ce40ae3e6548	Downloaded	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Riya Kapoor	Riya Kapoor downloaded PMS_Workflow_Spec.docx	2026-08-22 22:11:48.449326+05:30	\N	\N	\N	\N
7d1ddbc4-c10a-49c7-83e4-f7c584ecb7ec	Downloaded	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Kavya Desai	Kavya Desai downloaded Company_Compliance_Policy.pdf	2026-08-21 03:11:48.449326+05:30	\N	\N	\N	\N
4403c271-c17e-4e4f-846f-9059df1dd29c	Downloaded	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Priya Sharma	Priya Sharma downloaded Company_Compliance_Policy.pdf	2026-08-22 12:11:48.449326+05:30	\N	\N	\N	\N
92ec2d47-797d-4afc-ac63-ad550c376c19	Downloaded	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Aanya Joshi	Aanya Joshi downloaded Company_Compliance_Policy.pdf	2026-08-23 21:11:48.449326+05:30	\N	\N	\N	\N
acb77d89-1c0a-4a1a-9b79-f8ac8d8f556a	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Arjun Shah	Arjun Shah downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-22 16:11:48.449326+05:30	\N	\N	\N	\N
c3c9370c-6208-4109-9701-5d81e63f86f7	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Priya Sharma	Priya Sharma downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-22 13:11:48.449326+05:30	\N	\N	\N	\N
8ecc0a49-ff0e-47b1-b816-5d6152f9e186	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Divya Rao	Divya Rao downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-23 18:11:48.449326+05:30	\N	\N	\N	\N
e1976767-5cbf-4a2a-8eb7-12d9bf2171db	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 13:01:01.811418+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
79fdeb96-8e1f-4a2a-bf5b-7543a93fc3c5	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:01:23.916218+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8547e788-8e0b-454c-a4fa-f61638428977	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:02:25.133528+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
662a1376-a1d8-4009-a417-d6e81270c795	Viewed	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Admin User	Admin User viewed Security Incident Response Plan.pdf	2026-08-25 13:11:46.409617+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0ad0ac8e-d84a-4cbe-a569-c132efa6c789	Deleted	f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	Admin User	Deleted Database Backup and Recovery SOP.pdf from Tech	2026-08-25 13:11:58.113952+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
80237877-9098-4deb-82ab-a29626b523b1	Viewed	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Admin User	Admin User viewed Sample_Architecture_Guide.pdf	2026-08-25 14:48:26.48448+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0cd99fda-7446-4501-9a44-21b9e7c5345f	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-25 14:58:54.401342+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
afa1dda6-ee8d-4c89-bb5f-02d3374daef2	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 14:59:07.192633+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d1c9d3e5-ca61-440f-ac7d-9bedec688a9a	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	admin@acme.co	admin@acme.co viewed Company_Compliance_Policy.pdf	2026-08-25 14:59:07.398809+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
98679e92-935d-43bc-8176-f28b6f132455	Viewed	3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	Admin User	Admin User viewed TK I PMS Tool I Timeline I V01 (1).xlsx	2026-08-25 14:59:10.575624+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bbebca19-6a76-4e9d-a7ed-cdd4a88c3b6a	Viewed	3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	Admin User	Admin User viewed TK I PMS Tool I Timeline I V01 (1).xlsx	2026-08-25 14:59:22.595684+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ccfbcfa7-9f8e-488f-b4b7-e3210de0dc85	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Admin User viewed devops_guidelines.pdf	2026-08-25 14:59:29.914392+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
678b19a0-9623-453c-a810-36fdfff02608	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Admin User viewed devops_guidelines.pdf	2026-08-25 14:59:35.246396+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9f4bcdc2-099e-4850-8b3b-dbd4adf3d1f1	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 14:59:35.257521+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9a5a15a0-3736-4457-8ac3-3cfaa5a51470	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Admin User viewed devops_guidelines.pdf	2026-08-25 14:59:41.530449+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a5f9eb34-3383-4155-9a4d-c0fa468bfa81	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 14:59:41.537485+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
22afe7ad-e277-4f73-a191-e73f2aa64864	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Admin User viewed devops_guidelines.pdf	2026-08-25 15:02:29.417641+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
58f55140-5857-4b9a-9c34-a95b5f71c98b	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 15:02:29.533271+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7bbc408f-729a-4ec2-8838-5ab635073bb4	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	admin@acme.co	admin@acme.co viewed Resource Allocation SOP.pdf	2026-08-25 15:02:49.629901+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9c0ae3a9-9a60-401a-80d9-b663aec330c0	Deleted	f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	Admin User	Deleted Leave and Attendance Policy.pdf from IMP	2026-08-25 15:11:00.896423+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
77658d09-c027-4cd5-abd7-5ff05d566906	Deleted	81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	Admin User	Deleted Project Onboarding Checklist.pdf from PMS	2026-08-25 15:11:04.865657+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
85ab957e-bc29-4f7e-9c6a-4e0138a56e9a	Deleted	0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	Admin User	Deleted CI CD Pipeline Setup Procedures.docx from Tech	2026-08-25 15:11:13.552185+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
96cfd7fa-153e-4549-b6cd-ca19cd0d30be	Deleted	c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	Admin User	Deleted API Gateway Configuration Guide.pdf from Tech	2026-08-25 15:11:17.889839+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
baa936a5-71fd-4af7-a670-cba65d304036	Uploaded	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User uploaded TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:11:56.894914+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7d4ad808-e905-4826-a86b-53a100d137ff	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:12:32.014802+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
55f25191-957c-44cb-ba92-a88bd3c8a253	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:13:14.913729+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b62faa12-819e-4134-a29f-eadbb372a9d7	Deleted	f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	Admin User	Deleted Change Request Management Process.docx from PMS	2026-08-25 15:11:02.745863+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
861174aa-1f5d-4349-be18-db9e1ad9c3d8	Deleted	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Admin User	Deleted Code of Conduct 2026.pdf from IMP	2026-08-25 15:11:08.982288+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dfb05e96-62eb-45c5-ba1f-25ccffce0edd	Deleted	b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	Admin User	Deleted Timesheet Submission Process.pdf from PMS	2026-08-25 15:11:15.5612+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
55f66c36-3381-4464-bdf1-098a82f79422	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:12:05.265142+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0fefb687-e315-491a-b99a-dc5425975355	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:12:34.420151+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
40831c73-372b-4648-affc-eef432a3d821	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:13:26.424949+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c340d0c3-754f-4c4a-8a26-a19a85963036	Deleted	40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	Admin User	Deleted WBS Creation Guidelines.docx from PMS	2026-08-25 15:11:11.173993+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dc74bed8-ad2e-472e-b268-9104b89ff799	Deleted	1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	Admin User	Deleted Data Privacy and GDPR Guidelines.pdf from IMP	2026-08-25 15:11:20.130903+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
166d6a4c-7975-4fa1-9079-103667b96021	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:13:12.716785+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
63119738-3449-4669-986d-f7be4b14bfd6	Uploaded	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User uploaded KEKA - PMS Module guide.pdf	2026-08-25 15:14:59.379004+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2cddcb3c-bdaf-45db-a8e2-63623f4854b7	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 15:15:28.006251+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c1d22924-270f-4dfc-9914-d9923c46b8a4	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 15:15:28.019102+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ddd7a886-508a-4041-9e00-3e439b511d03	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 15:15:43.375295+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5a979174-3789-49bb-a7c5-8249a4cbb241	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 15:16:12.952363+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dd53f5be-e101-4866-937b-b7ae93d9e20a	Downloaded	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co downloaded KEKA - PMS Module guide.pdf	2026-08-25 15:16:13.026526+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
82260265-8670-4b53-bfb2-4d77fa52f463	Uploaded	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User uploaded RFP_2026_7206600_Report (2).pptx	2026-08-25 15:16:52.824368+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2593dcb5-39c6-4c73-806f-b9c545ebe3bf	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 15:16:55.305783+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e036b4f1-2e2c-4e56-9b29-f45eb2aba4e4	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 15:21:59.615623+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8f89d3c0-5e28-4661-bc05-c4b443247e19	Downloaded	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co downloaded RFP_2026_7206600_Report (2).pptx	2026-08-25 15:21:59.797282+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fb040c03-e9bb-461d-a22f-b8983302e65d	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 15:22:48.055362+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
eefbdc38-f6d4-4886-b593-fad8e56f3e7e	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 15:22:49.787115+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d7ea8ee8-4df9-4c0f-b298-7adf654b9112	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 15:22:59.733263+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e0ecc121-d960-4338-8571-8735cccb3cc3	Downloaded	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co downloaded KEKA - PMS Module guide.pdf	2026-08-25 15:22:59.802979+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1016be0f-7764-40e3-b9c8-f925ea570cc8	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:23:10.729817+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f5670105-e58b-4148-b77a-08ad0682f656	Downloaded	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co downloaded TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:23:10.789418+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
86e9eebd-9f43-4432-9104-6809f78717b3	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:23:14.523679+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4e9e9cdc-85b8-4d76-863d-dceac06aee4a	Uploaded	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User uploaded PMS_Workflow_Spec.docx	2026-08-25 15:23:45.566515+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
90d1f14a-00e7-4286-afa0-a6ffaaf770fc	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 15:23:49.375175+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d0454ed3-a0d3-4afe-bd17-d8c4c1454717	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 15:23:52.177791+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4f2b0996-6d0e-4044-843f-a45d93dba347	Downloaded	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co downloaded PMS_Workflow_Spec.docx	2026-08-25 15:23:52.246431+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
805e42dd-90cd-4ac5-a5dc-c867f25734bf	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 15:24:05.608742+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dd00f3d4-2684-4b69-8097-546c0a58654f	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 15:24:40.344188+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0c170afc-883b-41ff-853a-2ecf0ee512c4	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 15:24:43.574818+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e7cf6413-2452-4dba-89a6-6b10acac1be6	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 15:24:43.591183+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ead84d4e-9f2d-49b0-ad5d-4642492e8c88	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 15:24:46.240741+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cfc96161-41e1-4b0c-b2c4-ac1070b761c7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 15:38:04.052948+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cf5b4d22-a5fd-4c00-8527-7de4b30a05ae	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 15:38:08.823387+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fe8ad6e1-230a-4cbc-913d-db93531035cc	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 15:38:11.240409+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bce401c0-8bd2-4aae-9131-cdf62bcd8e3b	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 15:38:15.566642+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2e2a1851-cdfd-440a-99d8-486cadd650ea	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 15:38:15.707582+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ccebe2f6-f78e-487c-b8e9-a94d1a8ae6db	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:38:18.981614+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
243bf1ec-2729-405c-bfc6-0173fa1652c0	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 15:45:43.270085+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a8969dfc-18c9-495c-ba95-f764c598de46	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 15:45:58.53812+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c6fdd864-84ba-41ba-8941-d9443ed6775f	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:46:23.393287+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2baa02b8-0548-4563-99f4-3e4a46f3e216	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:46:31.895412+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ac59c5ff-5fa4-469a-a4d2-2111f8253657	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 15:47:02.747015+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
89944e55-6d09-45d9-a966-b19a142ab2ef	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 15:47:03.073767+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f712d046-7f9b-4ad7-89f7-6b5e14a85a65	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 15:47:42.151705+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fd1ea963-a12c-4ba5-9d7e-25d943fab0b9	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 15:49:25.434206+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f12b0758-c2fc-494c-854b-4811e6b654b7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 15:49:25.983006+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
121e452c-f266-41c2-8477-9b467729fdb7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 15:49:26.306866+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
07324d87-2331-4f4a-97c4-7fc7ffa07e0e	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:52:11.654033+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6323453a-909d-481b-b925-a31da395101a	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:52:12.052126+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
457d7006-60c0-4e22-9778-2de25e4ddf13	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 15:52:13.166877+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
73820f36-e896-489f-b1ca-277173fecbca	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 15:52:54.03256+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
185872e4-b944-48cb-8ee8-cb4a1cfbb996	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 15:52:54.092568+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6aaa74de-1486-4b02-bdaf-1b5ce4b44d96	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 15:52:54.47585+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
31135774-baf9-4a98-bce0-99a5e2dbb68f	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 16:03:07.517139+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7f73b402-0f99-46f7-9f17-c9c8769e0ac4	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 16:03:07.610611+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0857b4af-1891-4dcd-9734-83a4b573b9e7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 16:03:07.690007+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
43115495-48f2-489c-974c-c14c32f54578	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 16:03:14.407586+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
be2cbcae-c71d-42bf-97fc-f9e69d2d5c6a	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 16:03:14.426153+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b9725752-aa22-4e58-b387-2165aac776c8	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 16:03:14.51003+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
91e5a29b-0fd3-498e-b9b2-67dce3c306b4	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 16:03:18.973814+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dcccdba8-9d66-4a9b-934c-730aa12b15c8	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 16:03:29.150048+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aa4f13fa-9866-43b8-b608-d7101e2d8b6f	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 16:07:21.297157+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e35b0e28-2be0-4830-b314-b1331e73026d	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 16:07:21.403725+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f11d237c-4cd4-4496-856c-cec927d7cda7	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 16:07:36.442934+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
24a963b1-fa21-40fe-bacb-1af6d7b603f8	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 16:07:36.478415+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9615f70a-ac9c-4e1b-9015-49afe6d9f19f	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 16:07:38.958459+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
845473b6-f13f-4e6e-bbbd-24c309a273b6	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 16:07:56.200884+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cd236f92-58c3-417f-bc0b-4d1c0432400b	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 16:07:56.250204+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1b72ce86-4cfa-4566-b1fc-6f185bad536b	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 16:07:56.374437+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
46a27324-6cc6-4c51-af43-a9aabdd217ea	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 16:08:12.263691+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
78c588fe-f5a5-403c-9913-9baad2b95afa	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 16:08:12.34976+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
750dca96-db72-4486-9e91-1e755c5872c5	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 16:08:12.538335+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
02828fa0-6070-4e3d-8ab8-68f12cb1a1c7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 16:56:29.669986+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7e1b4796-beab-4b26-b5a1-56de3c94d7c4	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 16:56:29.762743+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3a643d69-a8c1-45d6-adaa-d84746b99ead	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 16:56:29.828306+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fef1f54f-fc74-422f-8d63-595d7f167bd9	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 16:56:36.78937+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4b8830a0-5002-4236-b16e-6263e47e3d6c	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 16:56:36.814021+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
647d4778-5c2c-4236-b4e1-e427f7b632c1	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 16:56:36.855745+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
deb24f3d-d15a-4389-922a-c78f41fb688b	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 16:56:51.123859+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0b7c5e96-7400-45ac-b12f-ce40568f78e4	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 16:56:51.155422+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0235a23c-6831-401c-b5f0-3f02e9652722	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 16:57:03.714348+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
24c04d56-fbe1-4bb1-b120-6e5f24d71f1d	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 16:57:03.761883+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
605cc084-58dd-475e-9589-4eb54cb3c975	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 16:57:03.803806+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9d853117-1071-49b0-a1b7-bc97b0aad13e	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-25 16:57:34.906326+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
54ccf973-994c-4338-9247-8df2ba703013	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-25 16:57:34.967357+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
74dccc36-5427-4d09-a301-792d75bbefc2	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-25 16:57:48.217366+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cb5e6e9e-5479-4907-be5c-a2e2297bca6d	Uploaded	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User uploaded TK_Tender Summary(template)_071223.pptx	2026-08-25 16:57:29.151008+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
47534ae8-037c-4879-9760-fbbaded81d40	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-25 16:57:34.913529+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
774a0f34-6568-4b28-99ac-15ac95fbc2a6	Downloaded	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co downloaded TK_Tender Summary(template)_071223.pptx	2026-08-25 16:57:48.292788+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
410cfb6e-69a7-44da-b2ef-5809ef258417	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:08:03.869477+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5f743625-51f4-46d1-bea8-315c87527fd6	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:08:03.946995+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
87c308c0-ec86-4416-abcd-b01784d2ed9f	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:08:03.975032+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ece54adc-cbc8-4ed4-a092-dd92deba0ca3	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:08:20.507985+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6ea5f9bb-36cd-4d7b-bc22-a23300f0e002	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:08:20.559969+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
88c9fd85-c12b-4667-8f0d-d6473e59cd53	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:08:20.581054+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8a972620-ffc4-430b-af56-04b275ebbc90	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 11:08:24.268304+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ed712d63-fa8e-4887-9088-99bde24b004b	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 11:08:24.278756+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bf5473b2-a0c1-4aed-87fc-d22961ad8e52	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 11:08:24.315774+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
088d7b9d-e3ab-40e0-8cde-1c0fe93098d3	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 11:08:30.908259+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c59d2698-1bf2-4c07-a18a-9bbaaa902e2e	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 11:08:30.948993+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f45a3fdf-995d-4810-a7f4-ff0ee607b12f	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 11:08:31.033289+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5a6d9e16-3c21-4aae-888f-378261c475e7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 11:10:23.817558+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d9e26b1f-af26-46b8-bb18-4eb962a2d163	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 11:10:23.962961+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
78c1ebe7-6f26-4f08-af3f-04a66fc7c68a	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 11:10:24.004388+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0ec62ecb-7997-4c11-849b-a537a7d07675	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:11:26.546864+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
47d4e402-16d4-4874-bb7e-23441b99d7c7	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:11:26.575294+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7bdc5e3e-60e8-420f-95d9-82874b9be348	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:11:26.608684+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
21f9f97a-3b92-459f-81a3-914d1c469c7a	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 11:25:02.256697+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8979f331-8fdb-48f6-8ae5-7b594b51851a	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 11:25:02.317883+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cbba69c4-5500-4099-97ac-c61be4c28834	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 11:25:02.367779+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ac044be6-0927-436f-aad1-55d96134a60a	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:25:20.453504+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
747e9cc1-9afb-4d8d-83fe-3dd1eadf4f9d	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:25:20.472359+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b2463079-dffe-4ffc-9cc2-62254466aae5	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:25:20.525795+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0cda26d4-f711-41a2-b168-fd35ef9287fd	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:25:27.198822+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
022ce174-82aa-40ad-9456-317eb7c5328b	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:25:33.949538+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2552c00c-ae7a-4598-8a9b-f850d7e5b798	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:25:33.961086+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9eedb6d1-ddbb-4f37-bde9-e512c64d9f53	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:25:34.007894+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aa7c3e3e-f57c-48c4-85fe-57e46a33c7a4	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:38:04.07947+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a5c7508d-e177-4af9-a724-5dcdbadb20a3	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:38:04.289378+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8930eb8d-5b4d-4237-9697-d04138bd5aeb	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:38:04.354599+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
99704101-7c16-4e36-9dc0-e92741e08d13	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 11:40:07.721884+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a27993b1-5d1b-4587-b112-b15e825eb07d	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 11:40:40.44335+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
192f273b-541b-4fe3-9726-f24134f9bae5	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 11:40:40.50201+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
08397ced-2238-4264-987e-d1b5b2a05081	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 11:40:40.586178+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bf4ebb3c-d21b-4d88-9117-44be7d6624dd	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 11:41:03.923606+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b9f67a26-1504-4cf7-a7db-f5bc59fa11ea	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 11:41:36.836605+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8925e46d-1a06-4098-abbb-36756ad93ecb	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 11:42:11.194744+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
66d8d6ff-b3a0-4b7c-af92-7490d6f5d768	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 11:42:55.071071+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
55e68b44-123a-49bf-a966-0813ace2e605	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 11:42:55.194389+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8f360a1d-3739-4b6c-a20c-6907c6556af0	Downloaded	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co downloaded PMS_Workflow_Spec.docx	2026-08-26 11:41:37.140386+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6a1d93e6-3f64-46cc-af9b-fecfe35d335b	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 11:42:09.97824+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1e216072-a1d2-44f3-8849-9e1b7c822f33	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 11:42:10.931598+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a91588ee-8ea2-47c0-b4cd-39b1fddeb83a	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 11:42:28.534994+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
68e1ce94-6ad6-43bd-915d-2e588840ea27	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 11:42:55.33586+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
52fd825e-ffed-495e-ac52-39c5cfa92d58	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 11:43:14.345015+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cf92f987-6f78-4ab2-8a6c-2915e9492d33	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 12:00:15.446747+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
142fab88-fdbf-403b-b949-1089ebebe9bf	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:00:15.446747+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1520051e-bc7e-4c5c-b0e8-69e3f228ec85	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 12:00:15.745874+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a06db79f-53a6-4aee-908f-07378efa4361	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 12:00:26.122159+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ff2b4d4d-1438-4f12-bb33-4732284af09d	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:01:58.277165+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3c602d6c-51b0-4cb0-88c2-c59156872786	Downloaded	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co downloaded PMS_Workflow_Spec.docx	2026-08-26 12:01:58.45281+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b1053847-e27b-4cdf-9182-18af83a040c0	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 12:02:40.844379+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6cbf768e-9bd0-4168-8615-906620bfae14	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 12:02:41.065567+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1ce5dbeb-5844-4cf6-b138-d4ddba93990a	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 12:02:41.182796+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
59d0090e-3831-4b15-ab2d-2d07ddf6f47c	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 12:03:05.385389+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a8c8dd9f-ace8-47b3-95b6-6b7fa2a13526	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 12:03:57.863265+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
af959843-363e-4dc1-81ba-003ca40ff8de	Downloaded	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co downloaded TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 12:03:58.661822+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e208611c-5491-4f82-b97a-acf47039d9e5	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:17:40.85102+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
34f8398a-09c3-4a92-ab58-6aeeafc4adc7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 12:17:40.884004+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c7597099-a9dd-4c48-a435-c4353f572a84	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 12:17:40.955719+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d1976852-c76a-49c5-92db-c1cc6bac8d89	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 12:17:44.42441+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a066da1f-befc-4952-84b7-03d04cbd5a7a	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 12:17:56.236311+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
57627851-785f-4e70-8e4f-346c7c0f63ce	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-26 12:17:56.278716+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aa9fa0af-d20f-4bb7-bb97-42f90118772b	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-26 12:18:00.022366+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
671c8ca7-8b0b-4b0b-bef0-e30a87438acb	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 12:18:07.351564+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d274ce57-8c3e-492d-8a1f-15fffdb94317	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:18:07.353482+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0b782a22-080a-44b1-8a50-0b01683def65	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 12:18:07.381911+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e19bd9f4-613a-4151-9356-cad0d83d208f	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 12:18:09.181425+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cd2935a6-f51b-47e7-aa9e-cfda165d086e	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:18:17.043903+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
70199401-bf22-4fc2-a692-d0f4e9365208	Downloaded	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co downloaded PMS_Workflow_Spec.docx	2026-08-26 12:18:17.101603+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4beccdc2-a3f2-46c4-a1c0-794c07b06873	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 12:18:35.106282+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f310e881-34be-40ce-a873-33bd209f04a7	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 12:18:46.160135+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d34da8b0-cca9-4fa7-9627-9d6c41a25f37	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 12:18:46.1597+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
da6735a3-15c6-4eca-ad72-a9e8cdf8c35e	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 12:18:46.197638+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8e5014ce-3f1d-4b96-9fb2-af7bf0985b83	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 12:18:50.122341+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e09d3bba-41f7-42e2-9875-65aa0f8114d3	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 12:21:03.171062+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5d90332b-07c5-44c4-9f57-3858c0d9a3c1	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 12:21:03.174398+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
04419bb8-0929-4029-80d2-a8d8969cd9d0	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 12:21:03.216259+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
17a3acf3-9aea-4923-b5fd-8b30d8a7828d	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 12:22:07.669494+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2e2266a5-a910-4236-bf3f-888c283c4301	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 12:22:07.672485+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
635ac707-54a3-4b3f-a037-aa21c119b183	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 12:22:07.722655+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6a567300-9a24-4dcb-a80b-41e0d2ecb5dd	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:23:05.309637+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a0cbcabc-1685-4575-93e8-7553e41443a2	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 12:23:05.339903+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
01efd667-d0b2-4321-b8b2-26b3dbe889f5	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 12:23:05.377538+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
eec7820a-d21a-4a26-b3ac-432d02c8ffb4	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 12:23:30.964212+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2671f831-a91c-448b-8f97-c9a02b751870	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 12:23:34.679863+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d46d4631-0d26-4e2f-970f-cbcbe29f7873	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 12:23:34.686517+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
99565cd1-6d12-4667-a38d-b2300ff1e1bf	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 12:23:34.732891+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
da74af41-ac9d-4622-a334-dae31d8570bd	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 12:31:08.67231+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a6125343-7dc9-48dc-b4a1-dbbee505d03d	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 12:31:42.42592+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
76dab2dd-3886-4b0e-a4ef-dababe8d812a	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 12:32:41.032275+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
332f1901-fb11-4028-b123-3cb858d0dadf	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:33:18.429198+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
de74766c-f174-4c47-a674-43cbf3d4ca63	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 12:35:19.158471+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
688a848c-3dbf-45e7-802c-b992c8fe2258	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 12:35:23.425039+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
59dc2d63-de4e-4e08-b4f8-613845c50952	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 12:36:18.096394+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aa83339d-a9ac-4762-bd89-23a66c5b2db5	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 12:36:22.001862+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2237747f-eac3-431d-88e7-0cd8342d9e4d	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:39:55.891849+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6ec6afda-d74b-42b9-8844-e5f930be7516	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:40:11.132866+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9971ded1-71cb-406c-981e-3758a3cee1ca	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:41:34.870294+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6ac0cb87-3a8c-421f-88c2-c41a70ee1215	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 12:41:39.663556+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a9ee9936-d9bb-411b-a57a-3024e5ed57f0	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 14:59:07.499675+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0b4459cb-e1af-4827-8d26-1a459ceb690c	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 14:59:13.278929+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2625dd74-e802-46bc-b0f4-332d56eb83e6	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 14:59:18.68614+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a6dcbcc8-1a3c-453c-b8d8-fc040a0fdde0	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 15:05:12.301941+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f9863915-8f0d-448d-a69a-b9ceb5a8a889	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 16:30:42.79739+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9ebf3b5b-e074-41e1-8d75-940ed537e301	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 16:36:48.785667+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9561ad46-22f3-403b-97a7-2cd38e4be559	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 16:37:00.520704+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1fc5a0ca-a7a2-4b1f-a04b-8635cefc1801	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 16:37:30.229256+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
367b5843-55a6-4852-b2ba-f15c35e1f9d3	Deleted	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Deleted RFP_2026_7206600_Report (2).pptx from Tech	2026-08-26 16:38:01.654587+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ad0bb296-eced-45c9-b5db-d29513d9a10c	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 16:43:17.709329+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
635865c7-d41b-493b-9cfa-30ccbfe57d40	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 16:43:21.766422+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1ec8477e-0c91-46a4-9731-1e45355caa10	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 16:44:07.9596+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
37fd81cb-3efb-429d-8568-31cfad0955e8	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 16:44:11.725842+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2cbf4e06-36d4-4af0-a49a-0188f63b46f7	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 16:44:15.206081+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
53fb74dd-8018-426a-8db8-63e7e021d59c	Downloaded	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co downloaded KEKA - PMS Module guide.pdf	2026-08-26 16:44:15.477624+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
732c81bd-93d3-4d88-8d9d-0a321cd38b28	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 16:58:30.588635+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
26c7ef20-b2c4-40ea-b1c1-097628119672	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 17:06:21.560722+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
27b406a9-c1f9-41a0-b080-ba6e2b6964a7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 17:06:27.316104+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5b14e8cf-3e46-4164-b52a-6a410290e4e5	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 17:06:30.669791+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8bc4007f-d8ce-4a95-a453-8b1cb3a9e586	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 17:06:34.936578+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7a2812c6-cc1b-4a05-8544-474fde0b6a64	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 17:06:39.18117+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4cd60660-2cce-40af-b103-7eca698d4720	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 17:07:06.958097+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
adc58b51-460e-4e16-8243-68ec61cf74b9	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 17:06:49.91149+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ad867ab6-5a24-4ee2-81a4-4408db204c92	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 17:07:14.217373+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
be952973-5e77-4574-9ce0-66c9dc3e40a3	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 18:48:08.96801+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6f3b243d-f1a2-4af7-b08a-d0d80aa1c60f	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 18:48:14.952949+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a5433f10-ff93-47c9-9ca2-c6caeeb1b07f	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 18:48:18.949393+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
026bc081-83ff-4b3e-82ba-150a92ecd4da	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 18:48:23.040643+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2fe990cb-e068-4433-987c-4269b01fdd92	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-09-04 11:43:20.914496+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6e384382-a53d-43d8-a624-bdfaae06e3f9	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-09-05 20:57:48.891654+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
56284612-0182-4e5a-bbaa-c37da7a7827e	Uploaded	30a35f7e-125c-4f3c-8d1e-3bd8ecf171f9	ESIC_Info Sheet 1(Sheet1).xlsx	Tech	Admin User	Admin User uploaded ESIC_Info Sheet 1(Sheet1).xlsx	2026-09-07 12:38:02.238716+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d41dc20f-0461-4d4a-8daa-300d013d9a75	Uploaded	1c049f2b-4d7f-45cc-a6d1-b5170594063c	Phase_1_Story_Table.xlsx	Tech	Admin User	Admin User uploaded Phase_1_Story_Table.xlsx	2026-09-07 14:28:07.269976+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
439a313d-cc6a-411a-922f-db89631fbd58	Viewed	1c049f2b-4d7f-45cc-a6d1-b5170594063c	Phase_1_Story_Table.xlsx	Tech	Admin User	Admin User viewed Phase_1_Story_Table.xlsx	2026-09-07 14:28:12.918481+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: repository_departments; Type: TABLE DATA; Schema: public; Owner: trackerpro
--

COPY public.repository_departments ("RepositoryItemId", "DepartmentId") FROM stdin;
30a35f7e-125c-4f3c-8d1e-3bd8ecf171f9	d32a6c00-a02a-4586-90c2-4a503b6efc3a
1c049f2b-4d7f-45cc-a6d1-b5170594063c	d0ab0dc3-606c-4d62-95ea-3d62749f9006
\.


--
-- Data for Name: role_permission_audits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permission_audits ("Id", "RoleId", "RoleName", "ModuleKey", "ModuleLabel", "SubmoduleKey", "SubmoduleLabel", "PermissionKey", "ActionLabel", "ChangeType", "PreviousValue", "NewValue", "ChangedById", "ChangedByName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
c7fbc590-b862-41ff-844e-404028893696	4e1cb2cf-a453-4b80-9ddc-2c6ee042290b	Admin	settings	Settings	\N	\N	settings.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 18:10:14.213209+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fbe29092-0025-4ed8-b371-a7df24815955	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	dashboard	Dashboard	\N	\N	dashboard.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-11 18:32:20.869905+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
42e77664-6b61-460c-b6c7-a2e9f8a84932	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	action-center	Action Center	\N	\N	action-center.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 21:46:27.51142+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6fcb0cb4-f657-41b7-aa02-c7e5f6c961b3	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	\N	\N	projects:read	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 21:46:27.51142+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bb07b6db-6e82-4d0e-8bfe-fe780955635b	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	resources	Resources	\N	\N	resources:read	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 21:46:27.51142+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0c8a731b-9559-41e4-92e1-fc0cde4e4b63	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	\N	\N	action-center.view	View Action Centre	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0fa7de2c-b2e5-4cfe-9173-dc9ebce029c0	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	dashboard	Dashboard	\N	\N	dashboard.view	View Dashboard	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
187cde6d-e54d-4993-b435-3fd7596b346a	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources.manage	Manage Resources	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
37a3a3c0-61f4-4ad8-a404-abed8212ba35	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.upload	Upload Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
587f0586-606a-460e-8846-698dc71b73e1	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.kpi	KPI & Performance Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
58fe099d-5b81-44fb-b2a4-4e6a8fd7e730	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	directory	Employee Directory	resources.directory.add-employee	Add / Onboard Employee	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5cd12c05-d934-4376-a4cf-e8514fa827da	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	notifications	Notifications Tab	action-center.notifications.view	View Notifications	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5e03f599-cdb4-467c-8df2-5ab51df3b64f	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.offboard	Offboard Employee	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7649ff3f-e3c1-4fd4-ae69-7ce0a356c960	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.finance	Financial & Compliance Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7ade227f-386d-475a-8c2a-2140a370a80f	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.report	Generate Employee Report	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7c8ae8bd-7960-40f6-a541-36b4f0d114a0	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.logs	View Repository Logs	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
85a2627b-90aa-4ae4-967f-baaa7292b3ae	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.view	View Bucket List	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8956c76d-7386-449b-98fd-621744660483	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.download	Download Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
927b518c-6f7f-4d4b-8180-fabcaa2c1be8	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.employment	Employment Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
94e7921a-a178-4190-a10b-c1c2985c5b18	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.delete	Delete Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9b689a62-d802-47fd-a71e-29236ad402f3	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.org	Organization Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a005606e-806e-484d-a37a-68282490347e	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.resolve	Acknowledge / Resolve Alerts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a26f71e4-046e-4431-adeb-009772bff5e1	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources:manage	Manage Resources	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a8149300-2382-4162-bd8c-ded4b9fb7fe6	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.timer	Start / Pause Task Timer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
baa3e3ef-b169-45eb-93ef-b53de8861b15	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.view	View Active Alerts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bc417c4a-c5d6-4b7d-81f7-7cf14b499f51	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.act	Approve / Reject Requests	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c41b440a-f522-4396-9968-c4622aa38af0	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.edit	Edit Employee Profile	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e57b60c5-81f2-4d91-b740-399eec63aed1	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.skills	Skills & Qualifications Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ea24bbb3-56d3-4b5f-b19a-05050f033aab	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.view	View Pending Approvals	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fb639879-8ab4-4cb1-8c9d-5f852b73b731	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	exit-summary	Exit Summary	resources.exit-summary.view	View Exit Directory	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:43.255018+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
004b53ae-cd69-48e5-9b3d-45e8aade2bb3	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.view	View Active Alerts	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
01aacbb4-4d0a-496f-9aca-5c1e27800b0c	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.offboard	Offboard Employee	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0dbb012d-29c3-4054-b09d-4b7ba25b37c7	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.logs	View Repository Logs	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1cf7e187-fa78-46bc-acb7-b32acee43f7e	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.timer	Start / Pause Task Timer	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
32c880a7-e773-43fb-955a-31065a7a3d60	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.org	Organization Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
356ff696-acdd-4998-85cd-76c2cfa7cdac	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.view	View Pending Approvals	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
37b0914b-b5fe-4f6d-b141-0a8dd0a89fa8	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	\N	\N	action-center.view	View Action Centre	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
438ed112-c5bb-4759-835c-fd81accfcd88	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.download	Download Documents	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
54893290-19bb-4a83-b4bc-c148f83f654a	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.employment	Employment Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6085ba2f-be7d-484f-8422-cd1ffdfbe5a4	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.kpi	KPI & Performance Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6ed7195d-932d-4a4d-b274-061537280ccc	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.finance	Financial & Compliance Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
82cb02cd-f266-459a-ac37-8d8e43ddd9ac	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	exit-summary	Exit Summary	resources.exit-summary.view	View Exit Directory	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8eb24ca1-4bc4-4c7e-9ea7-d40bb551a96c	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	directory	Employee Directory	resources.directory.add-employee	Add / Onboard Employee	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9f4b6c1d-e4d5-4f00-b490-a7a2ce2a4ae8	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources:manage	Manage Resources	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a10b9f0c-09fc-4f8a-8f97-d3fbf5da5a2e	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	dashboard	Dashboard	\N	\N	dashboard.view	View Dashboard	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aa101bb8-340b-4f0f-adff-fea1bd2f2e47	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.report	Generate Employee Report	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b566ca0d-89f7-435e-b9ad-8680e718eebc	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.act	Approve / Reject Requests	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c45c67e4-ab82-49a1-bc57-f8d33058fc70	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.skills	Skills & Qualifications Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ca141d5c-f765-4126-9133-6c4b30a4efec	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.resolve	Acknowledge / Resolve Alerts	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cd18406a-52e9-43d4-9a13-cf6ec246ecf9	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	notifications	Notifications Tab	action-center.notifications.view	View Notifications	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d8a2ffa0-f638-481b-9acc-cdb6d449da87	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.upload	Upload Documents	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e1564dc4-678a-4337-9860-f035a72cf7cd	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources.manage	Manage Resources	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f05040c8-24ef-45fa-9469-d4dc4f226e8b	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.edit	Edit Employee Profile	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f2a69a09-c940-4754-a181-e5ae01101890	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.delete	Delete Documents	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fe2f551c-2170-4eb5-b7aa-ea6a7d50fc17	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.view	View Bucket List	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:45.924588+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0acd25cf-ce01-49e0-841d-41a76343d5f3	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.act	Approve / Reject Requests	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2efc36e4-bf98-4e0f-b1a7-072941ef96ea	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.kpi	KPI & Performance Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
39cfe9e9-ee48-4dce-b0ca-e34cf2840b9b	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.delete	Delete Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3fbcbb61-123f-4532-be92-e7dd23acc542	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.edit	Edit Employee Profile	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
44f9de2d-2e26-4cb6-b5fe-eb13fb5869e8	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.employment	Employment Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
471f8cf3-93b8-4ef2-aa79-f37c46d45272	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.download	Download Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5543db07-1c96-454c-8a3e-2c6915c5dd03	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.finance	Financial & Compliance Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
622a6358-9c5a-4dc1-bb9a-11fc0a537ca3	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.timer	Start / Pause Task Timer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
69cee4d0-8cbb-47b2-ab02-8a32243200d3	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.view	View Active Alerts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
80fda05b-2f14-4d22-8680-7a6a1b262f0d	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.logs	View Repository Logs	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
84808533-887c-44ff-83af-2d5c036e0184	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	exit-summary	Exit Summary	resources.exit-summary.view	View Exit Directory	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8ccfb2f8-44c3-4df6-a41f-35855eb0f1d2	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.view	View Pending Approvals	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8f369d4f-95db-4b0e-ab32-f68e8ff823ab	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	notifications	Notifications Tab	action-center.notifications.view	View Notifications	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8f5a96a6-0f37-42b5-8d96-42e5915f7f84	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.resolve	Acknowledge / Resolve Alerts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
94cd3a83-9522-478f-b03f-50c6d3df1b2b	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources.manage	Manage Resources	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a007788e-3463-4f7c-9c0e-4f37511ddc7b	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources:manage	Manage Resources	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b3a0c81d-7f06-4c79-84b3-4fd877e54626	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.view	View Bucket List	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b599a545-40ca-4369-afc3-1fbfe38f96c6	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.offboard	Offboard Employee	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bdca4887-007a-4d11-b574-d9f16f8ddc5c	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	dashboard	Dashboard	\N	\N	dashboard.view	View Dashboard	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c00cd47a-01cb-4612-892c-6458358e3905	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.report	Generate Employee Report	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c794dd4b-e9c8-4bd5-8593-cd24a6213a64	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.upload	Upload Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d69347b5-d8b0-45b2-924e-3ac4a670f193	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	\N	\N	action-center.view	View Action Centre	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d8cf4cfa-2a18-4a01-89ec-e77551bdc228	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	directory	Employee Directory	resources.directory.add-employee	Add / Onboard Employee	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e0d51b86-b281-4a76-8777-0f01b95a6b49	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.skills	Skills & Qualifications Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e60f91ba-3e48-49d3-aef2-1e5cb0d731dd	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.org	Organization Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:21:54.177043+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1229903e-16c6-41fb-a816-9996f45c95a0	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.delete	Delete Customer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:27:03.081448+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
236c18d0-a798-48dd-82af-a37b41994857	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.edit	Edit Customer Info	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:27:03.081448+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3afcbe67-c7ff-48a8-ad1b-8097a92f32a4	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.approve	Approve Customer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:27:03.081448+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3d3ede79-7baa-4b8c-937e-44e27ef36c06	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.create	Add Customer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:27:03.081448+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
71163a97-8b9a-4d84-aab3-3b88b5cd2bf9	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.view	View Customers	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:27:03.081448+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c99c454d-5fba-4fa8-a011-a56367759308	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.assign	Assign Customer Accounts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:27:03.081448+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a4810bd0-6bef-44ca-8767-5cac0879efb7	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	my-team	My Team	timesheet-approval	Timesheet Approval	my-team.timesheet-approval.view	View Approval Queue	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:28:41.460423+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
0e44ab1f-3236-4728-85cf-2c28fa868d1e	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.edit	Edit Employee Profile	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
13b53c1d-d9db-4256-adbe-edea948e08b2	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	\N	\N	action-center.view	View Action Centre	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2f56d228-61ea-49fb-961e-0f2fbcd1b215	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.report	Generate Employee Report	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3163b87a-4783-4238-9045-d8bf13e1d719	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	dashboard	Dashboard	\N	\N	dashboard.view	View Dashboard	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
37483715-ef3c-49f2-9b1d-a34827f3d4f9	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.create	Add Customer	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
39c156ad-f634-47c4-939e-b2a9948aa715	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	exit-summary	Exit Summary	resources.exit-summary.view	View Exit Directory	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3bc6633c-fac8-4b73-9419-a283267d7dd8	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.resolve	Acknowledge / Resolve Alerts	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3bdfd065-e909-48c8-a193-f8bb2dd685e4	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.act	Approve / Reject Requests	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
46c381bf-241c-4aa8-81a6-885f6d39b89c	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.edit	Edit Customer Info	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5ccb1e20-beab-4b61-82ea-261fd174bf3d	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.logs	View Repository Logs	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6791bafb-fc9f-4e8c-8ec6-50f57b0f61e6	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.timer	Start / Pause Task Timer	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6eca1f79-d5fc-4e56-ad69-5e291a8b42b4	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.kpi	KPI & Performance Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8207f3ae-f31a-431c-8c83-5dd32ae1a427	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.view	View Customers	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8bc14248-638c-4683-abf7-9843ec91e776	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.finance	Financial & Compliance Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
949205ce-53a5-4041-b878-e57c20dba7b6	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	notifications	Notifications Tab	action-center.notifications.view	View Notifications	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9733f962-f815-4f66-b9c1-de33164e2f2e	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.view	View Active Alerts	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a7c818f1-a2b4-48d1-b4fc-101436b34f1d	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.org	Organization Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aa781050-2da9-4e20-b464-8af181a12434	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.view	View Bucket List	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b5dc252b-79a9-4fce-8e1b-3da843709f6a	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.assign	Assign Customer Accounts	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b8c15d16-9e4d-473a-8830-ee03b2fe2425	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.upload	Upload Documents	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c2913d60-f9b3-4c18-b16b-9a616d4f5a05	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.approve	Approve Customer	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c368f009-d8d6-4de3-9829-433d3131e0f2	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.view	View Pending Approvals	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c8da8add-2f56-49c7-b6e3-b6c4906070ce	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.employment	Employment Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c9d27ddd-1ac7-42a4-8a89-56f6ae941768	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources:manage	Manage Resources	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d6771145-9853-4dcc-b5d7-80a76455d513	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.download	Download Documents	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e45c6cb0-c19d-4ea0-8328-45dfbb42b633	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources.manage	Manage Resources	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e4ddbb99-9fa0-48c4-bec1-94a955392625	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.skills	Skills & Qualifications Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e7d7965c-4048-44db-849c-2acd8782c9a0	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	directory	Employee Directory	resources.directory.add-employee	Add / Onboard Employee	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f7c436e9-6deb-4617-aa84-51d6ae1523e3	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	customers	Customers	\N	\N	customers.delete	Delete Customer	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
faaaca8a-be22-4611-a4ef-e74916be4109	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.offboard	Offboard Employee	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fc81585b-50bc-4cc6-9b26-4eccfa818475	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.delete	Delete Documents	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:12.177089+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1226da4b-42bc-48fa-bd02-0137582e7be6	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.offboard	Offboard Employee	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1312efe6-96ea-41e3-a21d-d085918b2f6b	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.download	Download Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
25241a07-c035-44fa-88f7-2eb2071b70af	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.employment	Employment Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3580938d-837a-4f56-ad55-98835e71d9b4	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	exit-summary	Exit Summary	resources.exit-summary.view	View Exit Directory	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
408c2082-977e-4ea8-8e8f-a272fa0180b8	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.edit	Edit Employee Profile	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
442c81c9-afc0-477c-ab0d-d3de07ec75bf	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	directory	Employee Directory	resources.directory.add-employee	Add / Onboard Employee	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4821932c-e2fb-4e17-a3ef-b89824f784f4	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.org	Organization Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7d69482e-a1bd-410c-ab48-063630bc91dc	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.kpi	KPI & Performance Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7f6a5dea-3bad-45c3-847d-9154c0fbdec6	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	dashboard	Dashboard	\N	\N	dashboard.view	View Dashboard	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
87eae6c8-6060-4e24-a2ed-59bcb6a61f9c	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.finance	Financial & Compliance Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8b66e847-1fce-4a43-a798-1641e25fd1cd	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources.manage	Manage Resources	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
91260b5b-72ea-497d-a95f-28df95c7cd62	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.skills	Skills & Qualifications Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b6a35a78-672f-4142-8641-b10e42f2071a	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.report	Generate Employee Report	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e0ec73cb-1551-47ad-aa18-8e49b029d8e9	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources:manage	Manage Resources	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:31:41.62533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
13e6b221-3df7-4b5a-8baf-e96293e53a77	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.report	Generate Employee Report	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1ea24d60-e482-4850-9667-1dae8cb311cc	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	exit-summary	Exit Summary	resources.exit-summary.view	View Exit Directory	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2f4b4280-5287-4427-98ab-27cda7bd0253	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.employment	Employment Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
44d083c7-39f3-43d7-b55c-2d9863497154	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.org	Organization Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4543e23a-c383-484e-b7f4-4a8dc63c5539	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.finance	Financial & Compliance Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
45f42fe2-6497-4ed1-970e-32c9559d4702	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources.manage	Manage Resources	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a2ea8131-5f55-4847-8897-6b68165a3cbb	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.offboard	Offboard Employee	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a2f92215-c739-42bf-9831-37aba1790c0f	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources:read	View Resources Module	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bfa20ef3-b647-4269-9a4c-059bb6d277c7	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.kpi	KPI & Performance Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c25a2008-719a-4039-b1aa-d930880b9128	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	directory	Employee Directory	resources.directory.add-employee	Add / Onboard Employee	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c4d4fd2a-05e2-4282-a0fa-8b5801091a4d	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.download	Download Documents	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ca3ded79-df6e-47b7-a19d-261fff34656f	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.edit	Edit Employee Profile	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d5778dfa-caa8-4e5a-9d76-3ca38c0fe66d	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	dashboard	Dashboard	\N	\N	dashboard.view	View Dashboard	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d7c5b237-1b1f-454d-bb54-a471eede446d	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.skills	Skills & Qualifications Tab	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
eaf64a72-1807-49ff-b1c0-01792a20c5fc	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources:manage	Manage Resources	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:45.249224+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0a15ac75-8dcc-4e52-bb14-db95be4ac3cf	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	resources	Resources	\N	\N	resources:read	View Resources Module	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
14f4eead-e1f2-4cae-bdbc-960e639a6f3c	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	health	Health Tab	projects.health.view	View Project Health	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1926a4e7-9fec-4e77-9406-098bc9ab22bb	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	clients	Customers	\N	\N	clients:read	View Customers	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1a92ee78-9b2c-48b4-8c76-828731f31272	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	wbs	WBS Tab	projects.wbs.amount	View WBS Amounts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
300d72c0-a8d8-4655-99b5-5126ec3108b6	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	wbs	WBS Tab	projects.wbs.services	Services & Deliverables	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
39e76d0c-d7fb-45b8-b21f-6dfeb16a532f	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	invoices	Invoices Tab	projects.invoices.edit	Create & Edit Invoices	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4ad4efa5-62ae-4bb2-8cd9-10ff29817f6a	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	overview	Overview Tab	projects.overview.budget	View Budget & Financials	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5639e4d6-f830-4280-9a17-684547aa7330	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	reports	Reports	\N	\N	reports.export	Export Reports	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
60ab03a8-bd6f-4fb4-bb1f-7665d5531560	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	\N	\N	projects:read	View Projects	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
65522f9d-3fab-4510-8f01-2361ebc82d36	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	invoices	Projects	\N	Invoices Tab	invoices:raise	Create & Edit Invoices	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
805703fb-9271-4349-9d8b-093da1d185b2	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	reports	Reports	finance	Finance Reports	reports.finance.view	View Financial Analytics	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8156325f-ffc0-41a2-836c-e05c408ddde2	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	invoices	Invoices Tab	projects.invoices.amount	View Invoice Amounts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8c4730a5-829e-4ca0-aaba-efd9c4cd1519	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	repository	Repository	\N	\N	repository.download	Download Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
95dddd19-0233-4e6c-a6a1-c5108585694e	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	action-center	Action Centre	\N	\N	action-center.view	View Action Centre	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d08648ec-5d4d-4c8c-b5e6-d97be8193614	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	customers	Customers	\N	\N	customers.create	Add Customer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d50d4b00-abec-4a46-aa9a-251adbdeb8b6	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	dashboard	Dashboard	\N	\N	dashboard.stats	View Statistics Cards	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d7ee8a75-8106-42cd-858b-0cda30157ced	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	invoices	Invoices Tab	projects.invoices.view	View Invoices	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e7aa5367-0380-4f07-a51a-be3f90d93620	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	reports	Reports	\N	\N	reports:read	View Reports	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f529e522-fc0c-4e71-87fb-b81da65867f4	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	wbs	WBS Tab	projects.wbs.view	View WBS	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:17:03.691954+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
09104377-6dfb-4ac2-8422-cb8b5c7e70ae	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	directory	Employee Directory	resources.directory.add-employee	Add / Onboard Employee	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
216d895c-e862-4055-b1a4-c325800dec1d	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.download	Download Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2b318a74-320e-412d-adb7-9b614fc1254c	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.finance	Financial & Compliance Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2e148763-333a-443b-afa8-378e6ebc0153	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.edit	Edit Employee Profile	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
30ab82ca-890a-43c6-9165-931619a40426	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.delete	Delete Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
341c7f44-4c28-45fd-8d94-9b60190f7a86	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.logs	View Repository Logs	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
34a4b14f-c42e-49a4-b112-b4bf55047124	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.skills	Skills & Qualifications Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
363bb349-159c-4965-813d-e1c892393874	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources:read	View Resources Module	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
412473b0-e6d0-4d92-b64b-d12fcd1a11c2	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.employment	Employment Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5148c34f-362b-403f-8eb8-4322c0a1876a	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	exit-summary	Exit Summary	resources.exit-summary.view	View Exit Directory	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6bcb6597-e70f-4fc6-a7aa-915c284fed6a	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.org	Organization Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7d90cc2d-6a64-40d4-86f7-de6aae99a846	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources.manage	Manage Resources	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
81ea4e73-cd80-4436-a9e8-acb65d66eb99	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	repository	Repository	\N	\N	repository.upload	Upload Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8ae0c51f-ee38-4a40-a900-37d83e33a9e7	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	\N	\N	resources:manage	Manage Resources	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8b60da03-d084-4f03-af03-7590a4b55b5d	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.report	Generate Employee Report	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
97233d94-8bdb-4b2a-8430-133ed9a96a25	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	dashboard	Dashboard	\N	\N	dashboard.view	View Dashboard	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b0de3ee1-5729-49ad-8b1d-a1e606f821ee	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.offboard	Offboard Employee	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ce38ff0e-b660-4920-abc5-2d0ecf5bc8c8	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	resources	Resources	profile	Employee Profile	resources.profile.kpi	KPI & Performance Tab	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:48.203835+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
271a4fb3-f386-49ae-830b-bb332aa86083	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.timer	Start / Pause Task Timer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 12:39:55.249555+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2a891fd5-5a73-45ff-bad8-41c5ded0dfd8	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.view	View Bucket List	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 12:39:55.249555+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d2f02bd9-38ae-43dc-ad44-c38802cd7e24	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	action-center	Action Centre	\N	\N	action-center.view	View Action Centre	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 12:39:55.249555+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
05a24d1e-b436-4278-9007-c459d136a197	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.edit	Edit Customer Info	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:31:50.081345+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
0670eddb-f4c5-4dd1-8bf8-4ee3b4b1e882	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	clients	Customers	\N	\N	clients:read	View	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
08a08a93-338f-436d-89c2-95d91fd100d4	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	my-team	My Team	dashboard	Team Dashboard	my-team.dashboard.view	View Team Dashboard	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
09c6b7e6-3afa-4f62-80d7-c9c6765bf769	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	timesheets	My Team	\N	Timesheet Approval	timesheets:monitor	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
0a3e964f-f5c1-484b-a602-7177635b5f66	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	repository	Repository	\N	\N	repository.download	Download Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:42:00.621935+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
0da5da82-3835-41d1-8136-75d93db54412	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.create	Create	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
12bbe468-e96d-4cfd-97c8-36b1e4cbbcc9	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	my-team	My Team	timesheet-approval	Timesheet Approval	my-team.timesheet-approval.approve	Approve Timesheet	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
13279937-4f3b-4565-b483-7caef4ff5a03	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.view	View Pending Approvals	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:12:53.749715+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
181b5cef-a708-42d0-a0b0-3e5c4c59d37b	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	my-team	My Team	timesheet-approval	Timesheet Approval	my-team.timesheet-approval.reject	Reject Timesheet	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:28:41.460423+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
19ee29d9-8af2-4505-bf93-8d09beecf4c5	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	timesheets	My Team	\N	Timesheet Approval	timesheets:monitor	View	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
1a0619c8-a9b0-4959-bbeb-e65d5e346946	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.act	Approve / Reject Requests	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:12:53.749715+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
1a5aa4d5-c823-4c55-9f5a-8a271bbcc05f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	dashboard	Dashboard	\N	\N	dashboard.activity	View Recent Activity	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:50.766581+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
1a5dc4b8-2118-4975-9b1c-3f64057dc830	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	my-team	My Team	timesheet-approval	Timesheet Approval	my-team.timesheet-approval.view	View Approval Queue	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
1a9021e3-3347-4345-bde2-d50e73b8d8a2	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	dashboard	Dashboard	\N	\N	dashboard.stats	View Statistics Cards	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
1fc35918-9df3-4b11-9bde-e9d0ee59be03	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	issues	Projects	\N	Health Tab	issues:raise	Raise Issue	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
2124dc58-ce4b-489b-b28c-dacceb965b4f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	tasks	Tasks Tab	projects.tasks.edit	Edit Task Details	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
24ad65da-5cf2-4324-b638-eed35d605981	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.create	Add Customer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:31:50.081345+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
2657040c-caec-4f10-bc60-73189c3d872f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	issues	Projects	\N	Health Tab	issues:raise	Raise Issue	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:50.766581+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
265b512d-1abc-4e6d-a11c-6c7c515df7be	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	notifications	Notifications Tab	action-center.notifications.view	View Notifications	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
279557f2-4b4f-4bb2-bdad-cd501d4f8ccf	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.view	View Bucket List	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
28c3e358-293f-425f-a581-b021d0c1f48b	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.view	View Customers	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
2978e123-118b-49ab-b87e-2c38340fa95a	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	team	Team Tab	projects.team.view	View Team Members	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:53.45869+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
2bb34c82-0936-4a3a-972e-3d407d45da6d	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.view	View Bucket List	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:42:00.621935+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
2d138a6f-4765-44ff-abe1-22ab0d431828	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.assign	Assign Customer Accounts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:31:50.081345+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
2fd24294-5561-4acd-8aaf-7d7ef1467a04	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	\N	\N	projects.create	Create Project	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
301016e7-2a7d-4f4d-8693-95526615c950	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	overview	Overview Tab	projects.overview.view	View Project Overview	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
33cde800-09c7-4d91-b452-0a3e2aed7bcc	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	notifications	Notifications Tab	action-center.notifications.view	View Notifications	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:53.45869+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
35a8ea38-df51-4d56-b0d7-e5a37c423691	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	\N	\N	projects.export	Export Projects	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
3a19b049-3e32-416e-ab23-3fc4de4dfb99	3de8ba61-fd83-4953-9f9e-11e7450ebccd	Admin (Dhanshree)	settings	Settings	\N	\N	settings.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 18:10:14.57319+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
3a24c5dc-44a0-42ee-80a1-09e0a45bdb4d	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.view	View Pending Approvals	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:12:04.172072+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
3b86eb60-342c-451e-b690-b52096246d9a	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.edit	Edit	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
3f2a301a-2e36-4222-9178-2534b46a9406	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.view	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
3f402eed-2179-4c65-8989-844a831e64e2	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	health	Health Tab	projects.health.view	View Project Health	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:50.766581+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
3f5a405c-0fff-486f-a427-a3bfb3531b8f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.approve	Approve Customer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:31:50.081345+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
3fd40186-0f98-40b7-9473-196ef8a381c9	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	health	Health Tab	projects.health.edit-issue	Edit Issue Details	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
41aaa4a0-ace1-4479-b715-19e02a555c99	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	stage-tracker	Stage Tracker	projects.stage-tracker.view	View Stage Tracker	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
463aa8ba-b18b-4461-9e1c-3cfff3c2d6cb	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.resolve	Acknowledge / Resolve Alerts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:12:04.172072+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
4663dbbd-c4a7-4fa6-906d-56b4aad7cae6	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	dashboard	Dashboard	\N	\N	dashboard.activity	View Recent Activity	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
467adf8d-5259-411d-ab3f-f42d5746b5da	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	notifications	Notifications Tab	action-center.notifications.view	View Notifications	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:42:00.621935+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
46aa3cd0-e09f-4f23-a9a5-509b6be97818	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	dashboard	Dashboard	\N	\N	dashboard.stats	View Statistics Cards	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:50.766581+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
4816fa78-1b72-4346-a506-803c05bf3d07	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	projects	Projects	wbs	WBS Tab	projects.wbs.services	Services & Deliverables	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
4cfa5367-8142-4464-a3cd-2aac5532dc0d	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.reject	Reject	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
4da6f3ac-e961-4f27-8d11-7f924d3c4d26	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	repository	Repository	\N	\N	repository.download	Download Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:53.45869+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
4df957e5-5bca-45f3-905b-54ff4e17894d	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	stage-tracker	Stage Tracker	projects.stage-tracker.edit	Update Stage Progress	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
4f4de6f9-bc9e-4e43-9629-99d3a9df6940	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	wbs	WBS Tab	projects.wbs.view	View WBS	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
4fd56b70-bda2-4bf6-abd1-55499461212b	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	my-team	My Team	timesheet-approval	Timesheet Approval	my-team.timesheet-approval.reject	Reject Timesheet	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
555528ce-d6f0-4827-bb07-f19b0606fb38	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	health	Health Tab	projects.health.view	View Project Health	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
580dff71-b6a7-43e3-b500-4e7a97027171	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	health	Health Tab	projects.health.view	View Project Health	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
5849c5fe-4a36-45f1-a53f-6ee4bed0c9d4	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.view	View Customers	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
5b17273c-e475-4c78-b920-b02297fd9c34	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	projects	Projects	invoices	Invoices Tab	projects.invoices.amount	View Invoice Amounts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
5b48c92f-6740-4f88-bae5-f02a18fe0a66	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.view	View Active Alerts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:12:04.172072+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
5c5883ae-e1d8-4932-9339-7b181f7a61ec	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.view	View Active Alerts	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:12:53.749715+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
5df58eb9-c159-4eaf-a477-76a8b655b9d9	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.approve	Approve	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
5e0c1b98-03df-447a-bc13-426adf97fdc0	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	\N	\N	projects.close	Close Project	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
6079f5a6-516c-4237-b09d-a8c67e3a8052	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.view	View Bucket List	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:53.45869+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
62d47c2b-e309-43b0-93d3-410c03ad3039	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	team	Team Tab	projects.team.edit	Edit Team Allocation	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
639ce8bb-4f69-4f11-80f6-d58d1edb3819	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	my-team	My Team	timesheet-approval	Timesheet Approval	my-team.timesheet-approval.approve	Approve Timesheet	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:28:41.460423+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
63e54c16-7d48-4222-8a47-a6c0ffda52be	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	notifications	Notifications Tab	action-center.notifications.view	View Notifications	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:50.766581+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
64d2270d-3820-4c45-8160-1f4e33bd567d	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	invoices	Invoices Tab	projects.invoices.amount	View Invoice Amounts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
6b6f2e7c-d709-4280-af91-6902dccf26ba	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	projects	Projects	stage-tracker	Stage Tracker	projects.stage-tracker.view	View Stage Tracker	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
6c71ea1e-a3a4-4fb0-a13d-0c7839d70b11	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	invoices	Invoices Tab	projects.invoices.edit	Create & Edit Invoices	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
6d09a9c3-65eb-4a51-b206-2c1add7bb6e9	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.assign	Assign Customer Accounts	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
7177661c-0329-4844-a0b3-80e2e69ebb9d	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	invoices	Invoices Tab	projects.invoices.limited	Limited Columns (Amounts Hidden)	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
7349d427-c4e7-41d0-b228-2b0286454616	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 17:56:35.257637+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
7395e01b-cfa8-4f34-8757-c686b0714901	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	issues	Projects	\N	Health Tab	issues:raise	Raise Issue	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:53.45869+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
739efdf5-0ce7-44a3-9f13-8f8fda69b9bb	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	dashboard	Dashboard	\N	\N	dashboard.activity	View Recent Activity	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
782370ba-9e9c-417d-ba3a-8e02b53b4d76	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	tasks	Tasks Tab	projects.tasks.edit	Edit Task Details	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
784c9ed7-f065-4195-bdc2-7cd9c252209c	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.timer	Start / Pause Task Timer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:53.45869+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
786e2053-8fed-4d43-a8b6-afbd5edb6e27	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.delete	Delete	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
78ad8779-059f-40e4-b73c-30349849c038	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	projects	Projects	overview	Overview Tab	projects.overview.edit	Edit Overview Details	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
7a20e8fb-6094-4f15-bbb1-96bdd9a890b8	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.submit	Submit Weekly Timesheet	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
7cd0c50e-8471-4776-a0ef-abf82bc361ec	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	overview	Overview Tab	projects.overview.extension	Request Extension	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
7d1539f3-8d06-479a-aa12-dbb721677d07	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	action-center	Action Centre	\N	\N	action-center.view	View Action Centre	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
8186f0c7-71fa-46a2-9c56-a3a42fe1560b	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	team	Team Tab	projects.team.view	View Team Members	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:42:00.621935+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
82405a7c-a273-4537-aa53-a73b646ebb92	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.delete	Delete	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
829ce974-596c-4a80-9898-de9c14c9b7da	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	wbs	WBS Tab	projects.wbs.view	View WBS	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
83fb644a-31bf-4763-be1b-60d7f00c74b7	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	dashboard	Dashboard	\N	\N	dashboard.stats	View Statistics Cards	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:53.45869+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
84b1983a-0627-4fde-83fb-55449d80b384	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.edit	Edit Customer Info	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
84c45202-b521-42ed-b396-68d23c50ff6a	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	\N	\N	projects.close	Close Project	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
850f2c44-9e1e-45d4-aeef-ed01741f0d6a	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.timer	Start / Pause Task Timer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:42:00.621935+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
859df294-6a90-494c-afa4-cd436dd8ea15	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	health	Health Tab	projects.health.edit-issue	Edit Issue Details	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
85c1c89d-3918-4789-915e-07a446e250d9	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit Weekly Timesheet	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
87af9d5e-c50f-4728-9fd1-96a374369e8e	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	approvals	Approvals Tab	action-center.approvals.act	Approve / Reject Requests	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:12:04.172072+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
88652848-6a9c-4e41-b7c5-573dedb93646	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	action-center	Action Centre	notifications	Notifications Tab	action-center.notifications.view	View Notifications	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
88b29a05-b10f-4354-a876-149f136cc2e4	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 17:56:35.149611+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
8a1a5a7c-2c96-4769-80ce-7c64b2126225	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	team	Team Tab	projects.team.assign	Assign Team Members	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
8a71d91e-7ff4-43fb-a62e-6f5af298f99e	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	stage-tracker	Stage Tracker	projects.stage-tracker.view	View Stage Tracker	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
8aaad17e-1c75-4f80-9289-74d2501e45a6	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	health	Health Tab	projects.health.view	View Project Health	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:42:00.621935+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
8af82c93-67b2-46ea-a1cb-5e2374d4166c	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	repository	Repository	\N	\N	repository.download	Download Documents	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:50.766581+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
8b033138-9877-40de-b495-ba7e0055e7c9	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.view	View Bucket List	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:50.766581+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
8d25bdf6-57c5-47ff-ad81-4226efbe11a9	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	dashboard	Dashboard	\N	\N	dashboard.stats	View Statistics Cards	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:42:00.621935+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
942f6acc-9fb0-43c4-b08f-65579aa23c5b	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	\N	\N	projects.create	Create Project	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
95b76246-8761-498a-a5c0-5755be5cafa0	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit Weekly Timesheet	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:53.45869+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
9796fee4-3b06-4b33-8a50-6b205511a90d	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	customers	Customers	\N	\N	customers.assign	Assign Customer Accounts	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
97f4e5f6-cb75-4258-b9b9-da7069703e78	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	repository	Repository	\N	\N	repository.download	Download Documents	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
989019f3-740e-446f-b95d-6b376d88694d	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	health	Health Tab	projects.health.resolve-issue	Resolve Issue	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
9964a05e-5649-4f97-a879-04e6c186cbb9	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	stage-tracker	Stage Tracker	projects.stage-tracker.edit	Update Stage Progress	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
99f8e1ce-6c2c-4d0e-9d18-02eebd4c332e	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	health	Health Tab	projects.health.view	View Project Health	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:53.45869+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
9c253e81-4945-40ee-8ae1-b4f46afa5b5c	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	wbs	WBS Tab	projects.wbs.services	Services & Deliverables	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
9e48b326-9537-4a07-952a-b6ab703de0bc	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	wbs	WBS Tab	projects.wbs.services	Services & Deliverables	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
9ea474df-1754-4cad-81c9-36eefb37e08f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit Weekly Timesheet	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
a3086ffc-f6f8-469a-b5a7-afd5034a3a80	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	team	Team Tab	projects.team.view	View Team Members	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
a36678fb-b43b-4ca9-87bd-1c7d80350bb2	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	projects	Projects	\N	\N	projects:write	Create Project	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
a559a2b3-e027-49fa-bf9d-ec03a9ccbea1	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	clients	Customers	\N	\N	clients:read	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
a752957c-5c48-4b52-a260-23e607d1c8a7	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	my-team	My Team	dashboard	Team Dashboard	my-team.dashboard.view	View Team Dashboard	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:14:13.042033+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
a8cd3838-fb21-4042-8207-0bc9247916c8	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	health	Health Tab	projects.health.resolve-issue	Resolve Issue	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
a902bd13-b3a9-43ce-972b-26930c7121c7	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	projects	Projects	overview	Overview Tab	projects.overview.budget	View Budget & Financials	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
a920b5fd-0845-4ac9-8d3c-a20969d7fe23	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.edit	Edit	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
b10b7f10-62f8-4377-a524-1bcd768cae47	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	invoices	Invoices Tab	projects.invoices.view	View Invoices	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
b128d6da-6675-4438-a096-ff8a0fbbb635	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	health	Health Tab	projects.health.raise-issue	Raise Issue	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
b15df724-894f-4ca0-a9f6-dd8c9cd03d08	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	\N	\N	projects.drafts	View Draft Projects	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
b1adc6db-1177-41a1-a2ad-a208eaea2975	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.view	View Bucket List	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
b2f3e10a-81a4-4cb6-8394-834a05093092	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	projects	Projects	wbs	WBS Tab	projects.wbs.amount	View WBS Amounts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
b3a82ca9-59cf-4e84-ba52-5eca54c8b32a	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	team	Team Tab	projects.team.edit	Edit Team Allocation	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
b59ec5e6-4607-42dc-b159-606afb93e519	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	wbs	WBS Tab	projects.wbs.amount	View WBS Amounts	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
b5ea52da-46da-4468-a3aa-1c9dcf82746c	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.timer	Start / Pause Task Timer	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
b85725d8-0f11-4e5b-a807-7ffcde32db07	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	clients	Customers	\N	\N	clients:write	Add Customer	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
b8bbf04b-3a85-4dcb-a38c-fee35694da3a	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.view	View My Timesheet	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
b912125d-0916-457c-b0d4-d2c0126ad8ca	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	overview	Overview Tab	projects.overview.extension	Request Extension	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
b955e7bc-f9c3-4f98-95e4-543443f54b15	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	projects	Projects	\N	\N	projects.drafts	View Draft Projects	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
bca0f18e-1f4b-4a1a-b891-efc8b52414f3	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	projects	Projects	wbs	WBS Tab	projects.wbs.view	View WBS	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
beaaad92-8e2b-4a96-a767-1eec5fd8651e	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	invoices	Invoices Tab	projects.invoices.limited	Limited Columns (Amounts Hidden)	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
beeafa18-0d01-4f86-b606-a94ef69998ed	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	reports	Reports	\N	\N	reports.view	View Reports	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
c026f195-412c-45d2-b960-8b95e55230bc	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	overview	Overview Tab	projects.overview.edit	Edit Overview Details	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
c3098dec-83f6-42b0-bf07-83771fca518a	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	overview	Overview Tab	projects.overview.budget	View Budget & Financials	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
c323408a-6699-4819-bdb7-8d55525b623d	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	overview	Overview Tab	projects.overview.budget	View Budget & Financials	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
c35b8b3c-131c-4ab8-ab72-f7ee38bdd030	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.submit	Submit	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
c41227ea-81d7-4867-aa17-7796ef21446e	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	projects	Projects	invoices	Invoices Tab	projects.invoices.view	View Invoices	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
c4d82d2b-13e4-4700-af05-7831feae8837	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	resources	Resources	\N	\N	resources:read	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
c7519e24-2d97-41d5-a2a2-275663b7a60d	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	health	Health Tab	projects.health.raise-issue	Raise Issue	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
caf957bb-f605-494c-9e8a-da60fc52446e	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.create	Add Customer	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
cb03b19e-ca0e-42e2-9f31-4399f191de23	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.delete	Delete Customer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:31:50.081345+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
cb173319-9bc5-4be3-851a-7812bac29818	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.delete	Delete Customer	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
cde36bbf-87a4-4962-a05a-0517d21fa7c9	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit Weekly Timesheet	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
cfcf3cbc-4f77-4b6f-9aa9-99cfa66c35ec	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	dashboard	Dashboard	\N	\N	dashboard.activity	View Recent Activity	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:53.45869+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
d157430d-9b8c-4ada-b791-139015514bc6	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	resources	Resources	\N	\N	resources:read	View	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
d4296ee6-d46c-44aa-9079-62f7b72ac605	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	dashboard	Dashboard	\N	\N	dashboard.stats	View Statistics Cards	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
d442e2d9-1012-4ee6-a76e-f36c4dc1c76e	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	team	Team Tab	projects.team.view	View Team Members	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:50.766581+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
d490836a-53a8-4878-a274-7406d1f0276f	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.edit	Edit	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
d6b87c51-c167-4783-bf05-8f00b01b7d1a	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	wbs	Projects	\N	WBS Tab	wbs:read	View WBS	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
d8034b9b-9c0d-455d-9e2c-260d034dbc97	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.reject	Reject	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
d810cad6-61d3-4ab1-96cc-2363e8e3c73d	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	invoices	Invoices Tab	projects.invoices.edit	Create & Edit Invoices	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
d9234476-57cb-446b-a883-d0439120ebb5	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	invoices	Invoices Tab	projects.invoices.amount	View Invoice Amounts	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
dabb386b-ff3f-48d1-95e9-ad079dc123e3	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	customers	Customers	\N	\N	customers.approve	Approve Customer	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:41:48.912401+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
dbeb83dc-772f-4df2-833f-8154a02d3955	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.approve	Approve	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
dc094576-7edb-4bdd-a26d-235461c34a1b	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	dashboard	Dashboard	\N	\N	dashboard.view	View Dashboard	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
de085f07-fe8f-4879-ac7c-531eba227ae0	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.create	Create	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	2026-09-25 19:22:11.6817+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	2026-09-25 19:22:11.6817+05:30
e1974f85-e5c9-4b66-be3e-f81c6cca4389	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	notifications	Notifications Tab	action-center.notifications.view	View Notifications	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
e2f5468c-4e60-482c-8609-9571ff0b96d2	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit Weekly Timesheet	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:50.766581+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
e517712b-050d-4f9d-9ca8-c9a320c9fb62	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit Weekly Timesheet	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:42:00.621935+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
e518d90f-be8e-4a4b-a09a-ab21fb153cc5	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	repository	Repository	\N	\N	repository.download	Download Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
e5a2964d-8794-4b58-93b2-b9272046d7ec	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	repository	Repository	\N	\N	repository.download	Download Documents	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
e5bd1315-9af0-4357-a478-c4b471c79b60	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	projects	Projects	team	Team Tab	projects.team.view	View Team Members	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
e5d75e55-8573-480f-855b-84f4809d7e2f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	issues	Projects	\N	Health Tab	issues:raise	Raise Issue	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
e7739e98-12b8-4702-8f34-145178f3ccf0	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	\N	\N	projects.drafts	View Draft Projects	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
e91d9a46-84e2-49e4-bc69-2fdad922d762	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	wbs	WBS Tab	projects.wbs.amount	View WBS Amounts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
e93521d6-e3fc-4b92-9279-6aca83b3ecdb	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	team	Team Tab	projects.team.assign	Assign Team Members	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:23:31.212769+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
eb9222ac-4c7c-468d-9ed5-cb7fbc23a28c	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	\N	\N	projects.export	Export Projects	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
ef6532a6-67d8-47fd-8392-1c2ccae02a58	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	team	Team Tab	projects.team.view	View Team Members	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
f091eb8f-7fe5-449d-9dcf-bb81f0217f9f	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.view	View Active Alerts	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-08 15:06:25.223405+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
f2b889df-5590-4bbe-9fd5-2c39d278aec6	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	overview	Overview Tab	projects.overview.edit	Edit Overview Details	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
f2bf5ae0-8935-4a65-8195-e5d17a0db38a	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	alerts	Alerts Tab	action-center.alerts.resolve	Acknowledge / Resolve Alerts	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:12:53.749715+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
f681cf64-8512-4c5b-bb15-55685415653b	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	dashboard	Dashboard	\N	\N	dashboard.activity	View Recent Activity	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:42:00.621935+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
f7f10571-bda3-4208-962b-06bc684c075e	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.timer	Start / Pause Task Timer	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 19:09:50.766581+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
f8cccf9b-b2a7-428e-8a51-28254e280d7c	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	invoices	Invoices Tab	projects.invoices.view	View Invoices	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
fa360962-9c6e-401a-8acb-81f1dfd1ada1	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	projects	Projects	overview	Overview Tab	projects.overview.view	View Project Overview	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:28:37.964199+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
fb08f869-3d4e-4573-8963-a6e0570a76ff	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	issues	Projects	\N	Health Tab	issues:raise	Raise Issue	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 18:42:00.621935+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
fe4c357e-ee45-4d11-8b75-8d51ff19264f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	action-center	Action Centre	bucket-list	Bucket List	action-center.bucket-list.timer	Start / Pause Task Timer	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-07 17:18:20.086912+05:30	2026-09-25 19:22:11.6817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	2026-09-25 19:22:11.6817+05:30
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") FROM stdin;
a5023c9e-367f-41e1-ba02-bdb2929edc89	Engagement Manager (EM)	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	EngagementManager	Customer relationship, client project overview, health & escalations.	t	t
fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde	PMO	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.budget.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "approvals.view", "wbs.view", "wbs.allocate", "clients:read", "projects:read", "wbs:read", "wbs:allocate", "timesheets:monitor", "issues:manage", "resources:read", "reports:read", "approvals:manage"]	2026-08-07 13:19:59.669429+05:30	2026-08-10 17:53:35.786937+05:30	\N	\N	\N	Pmo	Governance, WBS allocation and timesheet monitoring (view-oriented).	t	t
4e1cb2cf-a453-4b80-9ddc-2c6ee042290b	Admin	["dashboard.view", "action-center.view", "projects.view", "projects:read", "projects.create", "projects:write", "projects.edit", "projects:write", "projects.delete", "projects:write", "projects.close", "projects:close", "projects.approve", "projects.assign", "projects.export", "projects.import", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "issues:raise", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health.manage", "issues:manage", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "projects.pmo.view", "projects.pmo.manage", "projects.prerequisite.view", "projects.prerequisite.manage", "projects.services-deliverables.view", "projects.services-deliverables.manage", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "invoices:raise", "invoices:payment", "projects.assigned-projects.view", "reports.view", "reports:read", "reports.export", "reports.finance.view", "resources.view", "resources:read", "resources.manage", "resources:manage", "resources.directory.view", "resources.kpi.view", "customers.view", "clients:read", "customers.create", "clients:write", "customers.edit", "clients:write", "customers.delete", "clients:write", "customers.approve", "clients:approve", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "timesheets:monitor", "my-team.timesheet-approval.approve", "timesheets:approve", "my-team.timesheet-approval.reject", "timesheets:approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit", "my-team.my-timesheet.edit", "wbs.view", "wbs:read", "wbs.allocate", "wbs:allocate", "approvals.view", "approvals:manage", "approvals.approve", "timesheets:approve", "approvals.reject", "timesheets:approve", "portfolio.view", "settings.view", "settings.roles.view", "settings.roles.manage", "roles:manage", "settings.permissions.view", "settings.permissions.manage", "users:manage", "settings.audit.view", "audit:read"]	2026-08-10 17:53:35.786937+05:30	2026-08-10 18:10:14.170813+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Admin	Super-admin — full access to every module, submodule and action.	t	t
1e15022e-e553-45a9-a98a-63776eea0894	R&D Team Member	["dashboard.view", "projects.view", "projects.task.view", "projects.task.update-status", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "repository.view"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	RdTeamMember	Research & development engineer creating internal tools.	t	t
cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	["customers.change_em", "customers.create", "customers.view", "dashboard.stats", "dashboard.view", "projects.budget.view", "projects.invoices.amount", "projects.invoices.edit", "projects.invoices.view", "projects.overview.budget", "projects.overview.view", "projects.overview.view_spm", "projects.tab.invoices", "projects.tab.overview", "projects.tab.wbs", "projects.view", "projects.wbs.amount", "projects.wbs.services", "projects.wbs.view", "reports.finance", "reports.invoice_tracker", "reports.po_tracker", "reports.view", "repository.download", "repository.view", "resources.directory.view", "resources.view"]	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	Accounts	Invoicing schedule, milestone payments, PO tracking, financial reports.	t	t
911d3fd2-2e9a-4a85-a79a-49584031c854	HR	["action-center.bucket-list.timer", "action-center.bucket-list.view", "action-center.view", "action.bucket_list", "action.bucket_timer", "dashboard.view", "repository.delete", "repository.download", "repository.logs", "repository.upload", "repository.view", "resources.add_employee", "resources.columns.full", "resources.directory.add-employee", "resources.directory.view", "resources.exit_summary", "resources.exit-summary.view", "resources.profile.edit", "resources.profile.employment", "resources.profile.finance", "resources.profile.kpi", "resources.profile.offboard", "resources.profile.org", "resources.profile.report", "resources.profile.skills", "resources.view"]	2026-08-07 13:19:59.669429+05:30	2026-09-08 12:39:55.153014+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Hr	HR resource/directory management only.	t	t
214e9378-4adc-44ec-b2da-c183819b146d	Sales Manager	["dashboard.view", "projects.view", "projects.create", "projects.overview.view", "projects.overview.edit", "reports.view", "reports.sales", "customers.view", "customers.create", "customers.edit", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:write", "projects:write"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	SalesManager	Manages sales pipeline and onboarding of new customers.	t	t
4273ae0f-1711-4f25-992c-bee48eb16904	Consulting Senior Manager	["dashboard.view", "projects.view", "projects.overview.view", "projects.health.view", "reports.view", "my-team.dashboard.view", "my-team.timesheet-approval.approve"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	ConsultingSeniorManager	Senior delivery management for Consulting engagements.	t	t
529b6df4-d182-4c06-9c26-99b1eff2a7e5	Chief Executive Officer	["dashboard.view", "action-center.view", "projects.view", "projects:read", "projects.create", "projects:write", "projects.edit", "projects:write", "projects.delete", "projects:write", "projects.close", "projects:close", "projects.approve", "projects.assign", "projects.export", "projects.import", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "issues:raise", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health.manage", "issues:manage", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "projects.pmo.view", "projects.pmo.manage", "projects.prerequisite.view", "projects.prerequisite.manage", "projects.services-deliverables.view", "projects.services-deliverables.manage", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "invoices:raise", "invoices:payment", "projects.assigned-projects.view", "reports.view", "reports:read", "reports.export", "reports.finance.view", "resources.view", "resources:read", "resources.manage", "resources:manage", "resources.directory.view", "resources.kpi.view", "customers.view", "clients:read", "customers.create", "clients:write", "customers.edit", "clients:write", "customers.delete", "clients:write", "customers.approve", "clients:approve", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "timesheets:monitor", "my-team.timesheet-approval.approve", "timesheets:approve", "my-team.timesheet-approval.reject", "timesheets:approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit", "my-team.my-timesheet.edit", "wbs.view", "wbs:read", "wbs.allocate", "wbs:allocate", "approvals.view", "approvals:manage", "approvals.approve", "timesheets:approve", "approvals.reject", "timesheets:approve", "portfolio.view", "settings.view", "settings.roles.view", "settings.roles.manage", "roles:manage", "settings.permissions.view", "settings.permissions.manage", "users:manage", "settings.audit.view", "audit:read"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	CEO	Global executive visibility, business analytics, all approvals.	t	t
775be3c0-980d-4ef5-a955-4022a79c77a1	Intern	["dashboard.view", "projects.view", "projects.task.view", "projects.task.update-status", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "repository.view"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	Intern	Read-only training access to assigned tasks and document repository.	t	t
b88afa2f-417b-4cbe-a032-1855ef15c0d9	Chief Technology Officer	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "repository.view", "portfolio.view", "projects:read", "reports:read"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	CTO	Technical architecture, R&D governance, engineering oversight.	t	t
d5e52e74-de97-4a33-8a09-c35df51bffe3	Chief Operating Officer	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.budget.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "approvals.view", "portfolio.view", "clients:read", "projects:read", "reports:read"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	COO	Operational oversight across all departments and projects.	t	t
1312980c-d7e6-4394-930e-477a5ae8ece8	Business Owner	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health-issues.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "portfolio.view", "clients:read", "projects:read", "reports:read"]	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	BusinessOwner	Executive oversight of the project portfolio.	t	t
34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	["action-center.alerts.view", "action-center.notifications.view", "action-center.view", "action.alerts", "action.notifications", "customers.create", "customers.edit", "customers.view", "projects.budget.view", "projects.create", "projects.drafts", "projects.health.alerts", "projects.health.appreciation", "projects.health.issues", "projects.health.view", "projects.invoices.amount", "projects.invoices.view", "projects.overview.budget", "projects.overview.view", "projects.overview.view_spm", "projects.stage_tracker", "projects.stage-tracker.view", "projects.tab.health", "projects.tab.invoices", "projects.tab.overview", "projects.tab.tasks", "projects.tab.team", "projects.tab.wbs", "projects.task.view", "projects.team.view", "projects.view", "projects.wbs.amount", "projects.wbs.pmo_intake", "projects.wbs.services", "projects.wbs.view", "reports.sales", "reports.view", "reports.wbs_tracker", "repository.download", "repository.view", "resources.directory.view", "resources.view"]	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	Sales	Sales & business development — new projects and customers.	t	t
3cdaf36a-c349-4239-8533-df54dbdbb770	Team Lead	["dashboard.view", "projects.view", "projects.task.view", "projects.task.update-status", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "issues:raise", "timesheets:submit"]	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	TeamLead	Leads a delivery team; submits timesheets and raises issues.	t	t
3de8ba61-fd83-4953-9f9e-11e7450ebccd	Admin (Dhanshree)	["action-center.view", "approvals:manage", "approvals.approve", "approvals.reject", "approvals.view", "audit:read", "clients:approve", "clients:read", "clients:write", "customers.approve", "customers.assign", "customers.create", "customers.delete", "customers.edit", "customers.view", "dashboard.view", "invoices:payment", "invoices:raise", "issues:manage", "issues:raise", "my-team.dashboard.view", "my-team.my-timesheet.edit", "my-team.my-timesheet.submit", "my-team.my-timesheet.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.timesheet-approval.view", "portfolio.view", "projects:close", "projects:read", "projects:write", "projects.alerts.create", "projects.alerts.resolve", "projects.alerts.view", "projects.approve", "projects.assign", "projects.assigned-projects.view", "projects.budget.view", "projects.close", "projects.communication.create", "projects.communication.view", "projects.create", "projects.delete", "projects.edit", "projects.escalation.create", "projects.escalation.resolve", "projects.escalation.view", "projects.export", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.health-issues.view", "projects.health.comment", "projects.health.edit-issue", "projects.health.manage", "projects.health.raise-issue", "projects.health.resolve-issue", "projects.health.view", "projects.import", "projects.invoice-schedule.manage", "projects.invoice-schedule.view", "projects.overview.edit", "projects.overview.view", "projects.pmo.manage", "projects.pmo.view", "projects.prerequisite.manage", "projects.prerequisite.view", "projects.services-deliverables.manage", "projects.services-deliverables.view", "projects.task.assign", "projects.task.create", "projects.task.edit", "projects.task.update-status", "projects.task.view", "projects.team.assign", "projects.team.view", "projects.view", "reports:read", "reports.export", "reports.finance.view", "reports.view", "repository.view", "resources:manage", "resources:read", "resources.directory.view", "resources.kpi.view", "resources.manage", "resources.view", "roles:manage", "settings.audit.view", "settings.permissions.manage", "settings.permissions.view", "settings.roles.manage", "settings.roles.view", "settings.view", "timesheets:approve", "timesheets:monitor", "timesheets:submit", "users:manage", "wbs:allocate", "wbs:read", "wbs.allocate", "wbs.view"]	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	Dhanshree	Super-admin (legacy account) — full access to every module.	t	t
44608b3b-3100-471f-a303-fd8dc77ae8f4	SOC Manager	["dashboard.view", "projects.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.health.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.timesheet-approval.approve", "repository.view"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	SocManager	Manager for SOC shifts and security incidents.	t	t
5464ac47-f03e-4924-b36e-2f511980f6f0	Testing HOD	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "reports.view", "reports.export", "resources.view", "resources.directory.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	TestingHod	Department head oversight for QA & Testing services.	t	t
5c1d7a82-83ba-4fe0-8d66-c88dc7401f85	SOC Team Member	["dashboard.view", "projects.view", "projects.task.view", "projects.task.update-status", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "repository.view"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	SocTeamMember	SOC analyst monitoring alerts and shift logs.	t	t
6871921d-355c-45a9-8c36-9dc6c84c93c1	Sales Team Member	["dashboard.view", "projects.view", "projects.create", "projects.overview.view", "reports.view", "reports.sales", "customers.view", "repository.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:read", "projects:read"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	SalesTeamMember	Drafts project proposals and tracks client opportunities.	t	t
8dce3f09-e10d-40d2-b790-4002f92605e8	SOC Senior Manager	["dashboard.view", "projects.view", "projects.overview.view", "projects.health.view", "reports.view", "my-team.timesheet-approval.approve"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	SocSeniorManager	Senior operations management for SOC services.	t	t
915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	ProjectManager	Runs assigned projects end-to-end; approves team timesheets.	t	t
92879bb2-39b1-4dbd-82f7-cee142ca0863	Testing Team Member	["dashboard.view", "projects.view", "projects.task.view", "projects.task.update-status", "projects.health.raise-issue", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "repository.view"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	TestingTeamMember	Pentester and test engineer executing testing tasks.	t	t
9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	["action-center.bucket-list.timer", "action-center.bucket-list.view", "action-center.notifications.view", "action-center.view", "action.bucket_list", "action.bucket_timer", "action.notifications", "dashboard.activity", "dashboard.stats", "dashboard.view", "my-team.my-timesheet.edit", "my-team.my-timesheet.submit", "my-team.my-timesheet.view", "projects.health.alerts", "projects.health.appreciation", "projects.health.issues", "projects.health.view", "projects.tab.health", "projects.tab.tasks", "projects.tab.team", "projects.task.update-status", "projects.task.view", "projects.team.view", "projects.view", "repository.download", "repository.view", "resources.directory.view", "resources.view", "timesheet.my"]	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	Employee	Executes assigned tasks; submits own timesheets.	t	t
9ec604bc-1626-4394-aa5e-ccb022a07d3b	Consulting Team Leader	["dashboard.view", "projects.view", "projects.task.view", "projects.task.edit", "projects.task.update-status", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "repository.view"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	ConsultingTeamLeader	Team leader for audit and consulting deliverables.	t	t
a4d0ebe9-2fc5-4e5b-bde3-bb3001d1c27e	Testing Senior Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "reports.view", "reports.export", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	TestingSeniorManager	Senior delivery management for Testing engagements.	t	t
b7271bbe-68a7-4165-996e-869c030c76d3	HOD	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.approve", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "clients:read", "clients:approve", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	Hod	Department oversight across projects, resources and approvals.	t	t
c09ddcb4-78db-474e-a20e-a322dfe68afa	Consulting Team Member	["dashboard.view", "projects.view", "projects.task.view", "projects.task.update-status", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "repository.view"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	ConsultingTeamMember	Auditor and consultant executing audit checklists.	t	t
c4f13d59-4a2c-47e2-b49b-89acd8e560c7	Testing Team Leader	["dashboard.view", "projects.view", "projects.task.view", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.timesheet-approval.view", "repository.view"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	TestingTeamLeader	Team leader for testing runs and defect management.	t	t
c6644cac-35a6-4995-85c8-b282842ba6b7	SOC Team Leader	["dashboard.view", "projects.view", "projects.task.view", "projects.task.edit", "projects.task.update-status", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "repository.view"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	SocTeamLeader	Shift lead for SIEM and SOC operations.	t	t
da95514a-1975-456d-ad0f-06fe33227e9b	Senior Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "projects:close", "issues:raise", "issues:manage", "timesheets:approve"]	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	SeniorPm	Owns delivery of assigned projects; approves PM timesheets.	t	t
e721fe39-f2b6-4242-89b1-7d625a52e7ef	Testing Project Manager	["dashboard.view", "projects.view", "projects.overview.view", "projects.team.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "repository.view"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	TestingManager	Project manager for Testing & QA deliverables.	t	t
eb9b4b0a-35f4-4aef-81b1-a747c2e00cfd	SOC HOD	["dashboard.view", "action-center.view", "projects.view", "projects.health.view", "projects.health.manage", "reports.view", "resources.view", "my-team.timesheet-approval.approve", "approvals.view", "approvals.approve"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	SocHod	Department head oversight for SOC and Security Operations.	t	t
ef7939e8-0275-46fd-9dec-772f58e8673a	Consulting Project Manager	["dashboard.view", "projects.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.health.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.timesheet-approval.approve", "repository.view"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	ConsultingManager	Project manager for GRC and audit engagements.	t	t
f4502ad6-a4cb-4899-a562-eb5fa2cd1122	Consulting HOD	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "reports.view", "resources.view", "my-team.timesheet-approval.approve", "approvals.view", "approvals.approve", "approvals.reject"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	ConsultingHod	Department head oversight for GRC Consulting.	t	t
f49b34ca-2dda-4e7f-a6be-13ae51398534	IT Administrator	["dashboard.view", "settings.view", "settings.masters.manage", "repository.view", "resources.view", "resources.directory.view", "audit:read"]	2026-09-23 16:37:51.861151+05:30	2026-09-25 19:22:11.6817+05:30	\N	\N	2026-09-25 19:22:11.6817+05:30	ItAdmin	IT administration and master configuration access.	t	t
0f2f5be6-312b-4782-99a4-e9ff2a1fa89c	Sales Manager	["dashboard.view", "projects.view", "projects.create", "projects.overview.view", "projects.overview.edit", "projects.health.view", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.create", "customers.edit", "customers.assign", "customers.approve", "reports.view", "reports.export", "reports.sales", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:read", "clients:write", "clients:approve", "projects:write", "wbs:read", "timesheets:submit"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Sales Manager	Customer onboarding, client management, proposal drafting, pipeline.	t	t
2b522ed1-4bbd-449f-92b1-9de7211d0351	SOC Senior Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	SOC-Senior Manager	Operations delivery oversight, client SLA tracking, incident reviews.	t	t
38eb3802-84bc-4f13-a55c-9e72acf9634d	Testing Team Leader	["dashboard.view", "projects.view", "projects.overview.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Testing-Team Leader	Test run execution, defect triage, test task assignment, timesheet review.	t	t
4093aa75-f904-4a81-9251-5937b1735ad0	IT Administrator	["dashboard.view", "resources.view", "resources.directory.view", "resources.manage", "settings.view", "settings.masters.manage", "repository.view", "repository.upload", "repository.download", "resources:read", "resources:manage"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	IT Admin	IT infrastructure, corporate email domains, device & user setup.	t	t
48b21b7c-b527-41e5-aa49-ef222f7a303b	Testing Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Testing-Manager	QA project tasks, test deliverables, defect tracking, QA timesheets.	t	t
4c275e12-c262-4542-9282-31006032cf5f	Consulting Team Leader	["dashboard.view", "projects.view", "projects.overview.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Consulting-Team Leader	Senior audit execution, audit task assignment, timesheet review.	t	t
57fd6151-2026-4a42-948e-f9c6608191bf	Consulting Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "projects.health.raise-issue", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Consulting-Team member	Audit checklists, evidence collection, task updates, own timesheets.	t	t
5aded8b4-daa0-4790-aa86-79bc7480828a	Testing Senior Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Testing Senior Manager	Delivery oversight across testing projects, QA resource management.	t	t
677140ff-ffbe-4030-ab6c-546a3c87cfe9	Human Resources	["resources.view", "resources.directory.view", "resources.manage", "resources.kpi.view", "repository.view", "resources:read", "resources:manage"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	HR	Employee directory, onboarding/offboarding, skills, KPI/rating tabs.	t	t
69ce8564-eaee-4aa7-8047-b502d64c491c	R&D Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "repository.view", "repository.upload", "repository.download", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	R&D - Team member	Python/Tool development, sprint tasks, code repository, own timesheets.	t	t
7bd14a17-44ba-435a-9419-37d4216830f0	Sales Team Member	["dashboard.view", "projects.view", "projects.overview.view", "customers.view", "customers.create", "customers.edit", "reports.view", "reports.sales", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:read", "clients:write", "timesheets:submit"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Sales team member	Proposal drafting, pipeline viewing, sales reports.	t	t
86d480d7-4aa5-4763-ba7d-77ec8e803255	Testing Head of Department	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Testing HOD	Complete oversight of Testing department, health escalations, approvals.	t	t
9bdd1d72-07cc-4c32-8b5b-543def1c2cad	Consulting Senior Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Consulting-Senior Manager	Delivery oversight across consulting & audit projects.	t	t
a68c3dc3-e12b-4689-adeb-b45a78ebb099	SOC Shift / Team Leader	["dashboard.view", "projects.view", "projects.overview.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	SOC-Team Leader	Shift oversight, alert escalation, task assignments, timesheet review.	t	t
afd3913f-cd04-453d-9990-92929dcadefa	Consulting Head of Dept	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Consulting-HOD	Complete oversight of Consulting department, GRC engagements.	t	t
c805e8c6-5b61-478c-a56d-88f2dc526107	Project Management Office	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.budget.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "approvals.view", "wbs.view", "wbs.allocate", "clients:read", "projects:read", "wbs:read", "wbs:allocate", "timesheets:monitor", "issues:manage", "resources:read", "reports:read", "approvals:manage"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	PMO	Global governance, WBS allocation, timesheet monitoring, approvals.	t	t
df987f8a-1233-41f3-a519-ccfb6e225952	Testing Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "projects.health.raise-issue", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Testing-Team Member	Test execution, defect logging, task status updates, own timesheets.	t	t
e6fd9368-d9d7-43a4-af78-445c2744c3d9	SOC Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	SOC-Manager	Incident management, shift scheduling, operations timesheets.	t	t
f6e6844d-874a-49f6-b704-0133785e4b56	SOC Head of Department	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	SOC-HOD	Complete oversight of SOC/Operations, 24/7 monitoring governance.	t	t
f7cdb414-a822-486e-8d65-6b71d6741bdd	SOC Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "projects.health.raise-issue", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	SOC-Team Member	SIEM monitoring, alert analysis, shift logs, own timesheets.	t	t
ff1f052d-a16a-4e5c-9f24-cebf9334d248	Consulting Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	Consulting-Manager	GRC audit projects, client deliverables, audit timesheet approvals.	t	t
\.


--
-- Data for Name: sub_ventures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sub_ventures ("Id", "ClientId", "Name", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Notes", "KycDocumentName", "KycDocumentPath") FROM stdin;
03e40de1-c4a7-425b-87ab-7d2b45ec364d	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Clinical Research	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
5fd7f539-0471-41ef-b4f9-f9c72071e117	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Biotech Division	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
fec11a61-59e0-4cfa-b03e-189789ceab63	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Manufacturing	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
15c89a23-7196-48e6-9c9c-0a10cc38cf80	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Global Healthcare	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
adc6d310-c567-4598-8bee-699791ca28cb	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Medical Devices	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
f8c2759e-1526-4499-93fe-4bf9383551a9	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Freight Services	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
b472f090-9382-4fcb-9a13-ad023a2b8edb	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Warehouse Operations	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
f701bcf7-0139-44fe-9188-1e2218afdb10	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith International Logistics	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
fb458d8a-fe51-4a06-a8cc-135b3784da0e	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Fleet Management	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
f453f787-9888-4058-8098-d99b9a89b9e1	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Express Delivery	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
58e5ee34-e198-47b6-9a9e-95903f56b20d	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Renewable Energy	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
d08681c8-6a5b-4c1e-af29-8997fa0e9de3	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Power Distribution	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
a34f1aad-ed5a-4eef-80e7-ffb186ac5a02	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Smart Grid	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
fbc527bd-d4b0-4a18-9ebb-b2ed0752da93	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Solar Division	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
eb5474ee-f271-4b23-b41e-dac2a1905a50	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Energy Consulting	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
8f8671f4-01e4-42d9-ba2e-afc03d0a37d0	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Retail Banking	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
e2868bff-2f6e-41e5-a1fa-6451ca5a7f0f	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Corporate Banking	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
b5f5586f-63f0-4fe2-b864-89937fb76a72	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Digital Payments	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
c973cd24-655e-4de7-98e2-f0627d34696c	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Treasury Services	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
3ea7fd34-bce6-4d9c-868b-380ef2658536	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Wealth Management	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
321598b3-aae4-4d07-a5b0-2e27cec16136	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync AI Platform	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
889e05ef-4311-474b-9d2e-23a7c5516aa2	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Cloud Infrastructure	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
8113f77c-878e-42bc-912b-5a7c388702a4	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Data Engineering	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
42304e00-59f2-4bed-b23b-87c4800caa16	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Machine Learning	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
bd25f3d8-a3a0-4135-a341-e13aeba728b5	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Enterprise Solutions	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
e1b95e8b-302d-4cf3-9ab1-c6f0bd75d394	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Hospital Systems	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
3540c693-d4be-438c-a795-b11c7edd1f84	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Telemedicine	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
8789ae47-e505-4fb3-adf2-04ade91e418c	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Diagnostics	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
ee71d5b9-7d64-4cef-83a8-1195ff484538	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Health Analytics	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
30613fc3-38d9-45c8-9333-72a178f1e2b7	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Patient Services	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
fa9d3ecf-bd5f-4ccb-a03e-b574d8370f11	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Connected Vehicles	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
80d85beb-5a07-40f2-b7ae-2f6168a6755e	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Autonomous Systems	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
bf470ada-eecb-4ed7-9dc0-0c11436d2eec	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive EV Solutions	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
a9afcff9-fadd-4d29-aeab-d83159813cde	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Manufacturing	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
a5ddbee0-90a3-425b-be8d-bcb2b8e1acda	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Smart Mobility	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
857a1e5d-ba2d-4499-9170-866e7f80596c	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Waste Management	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
7958d666-b744-4889-9c26-4d9152b5e23c	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Sustainability Consulting	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
c5b810e0-cf3c-46cf-91ca-615d583f7f9d	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Renewable Projects	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
c2c8966d-d634-45b1-b1e2-c231d2a91c16	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Water Management	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
6e5a495d-40be-4bb8-b40e-2480d3364bd3	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Carbon Solutions	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
116ef6af-75e2-4743-af52-db5f71093752	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit E-Commerce	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
c10b586c-3015-46a1-9ca4-c8a0758788ef	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Hypermarket	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
0d158329-c66c-4427-b5e8-073bfab60dba	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Fashion	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
79de3aae-5152-44f0-9c77-0c54c3fd701d	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Supply Chain	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
9e067c55-cc90-48a0-ab8b-ded41dace8cb	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Digital Commerce	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
ac923fa9-3ecb-4ccb-a755-5b21621eea43	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Digital Banking	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
ed26b19c-dd44-4dbd-931f-32302088e02d	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Payment Solutions	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
7ac571e1-5915-46fb-b36d-64323d485e8a	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Lending	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
4b278fdd-0c00-477a-ac9f-8c3013de4149	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Investment Services	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
cab77d0e-e88a-4056-8712-a5a39ff91cd9	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Risk & Compliance	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N
37f0c3b1-16a1-4643-9f5a-f824204543c1	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	subventure-northwindbank	2026-08-19 12:13:26.578788+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	sfsddf	2026-08-19 12:39:05.842701+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
6b55edc3-064f-468d-9084-54fbd72dc126	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	New Subventure	2026-08-20 15:51:44.125441+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
6a40584b-3bde-4c7d-a6e6-3ef920cd43d0	90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	TATA-subventure	2026-08-20 16:30:13.739957+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
65c6925a-8948-4485-9d93-e596e1f4273e	a04ccf3a-81c8-4416-8af7-068717ddb22b	Morphle Machine desgining	2026-08-20 19:01:53.288995+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
d3af0a54-b527-40ca-ac1e-9fb09fd81504	a04ccf3a-81c8-4416-8af7-068717ddb22b	morphle labs	2026-08-20 19:04:48.394235+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
a69fe228-de12-44e5-9128-dc3898f67e5c	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	IT	2026-08-21 15:35:12.642403+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
157b058e-8688-4a99-b13b-f53a60ba19e4	60e8ff87-c86e-4c71-a3ec-446d22b4ef5c	AutoDrive Autonomous Systems	2026-08-27 15:11:01.353316+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
b6502a56-f47f-487b-b915-45f74cdebfdf	fcdd3c82-1ca5-496b-b45c-7e433955aa46	xyz	2026-08-27 15:48:07.721735+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
\.


--
-- Data for Name: team_day_entries; Type: TABLE DATA; Schema: public; Owner: trackerpro
--

COPY public.team_day_entries ("Id", "EmployeeId", "WorkDate", "Attendance", "Shift", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: team_member_holidays; Type: TABLE DATA; Schema: public; Owner: trackerpro
--

COPY public.team_member_holidays ("Id", "EmployeeId", "HolidayDate", "Name", "Comment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: team_member_schedules; Type: TABLE DATA; Schema: public; Owner: trackerpro
--

COPY public.team_member_schedules ("Id", "EmployeeId", "WorkingDays", "Notes", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users ("Id", "Email", "PasswordHash", "Name", "EmployeeId", "Department", "SubDepartment", "Avatar", "Designation", "IsActive", "MustChangePassword", "RoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "FailedLoginAttempts", "LastLoginAtUtc", "LockedUntilUtc", "PasswordChangedAtUtc", "AuthProvider", "MicrosoftOid") FROM stdin;
cf106b1b-6a96-464f-aa63-ddcb77a737e0	new.pm@acme.co	$2a$12$p.MfI7wlBAX2LZkpEvPoEunU.q5UljNMmswtXsI80UcJj8X2CVWM.	New PM	u99	\N	\N	\N	PM	t	t	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	2026-08-07 13:25:45.951114+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	0	\N	\N	\N	Local	\N
30d629ff-3076-40f8-9c12-fb385b8c2600	admin2@acme.co	$2a$12$aqJIdIL9tzPW5DFE.zVFVurFkCUE0knMbU7.A0A1pBtjA7K4Qk7wS	Test Admin Two	A2	\N	\N	\N	\N	f	t	3de8ba61-fd83-4953-9f9e-11e7450ebccd	2026-08-07 13:45:16.235641+05:30	2026-08-07 13:45:23.702021+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	0	\N	\N	\N	Local	\N
a1878763-b174-41b0-88db-f2ebba76af83	sdsa@gmail.com	$2a$12$.bzyuW3FFq2Uau84IyFnYO1LXxDLXkbxtjVyvzVs71KECK6u2CONy	sadas	ads	sda	\N	\N	sda	t	t	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 15:00:46.654787+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	0	\N	\N	\N	Local	\N
a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	admin@acme.co	$2a$12$O8Mmew9D0Satl1a8IG15AeoCyJslqunOm.StYdEUsTJURLJ9w0yYW	Admin User	u15	\N	\N	AU	\N	t	f	4e1cb2cf-a453-4b80-9ddc-2c6ee042290b	2026-08-10 17:53:35.786937+05:30	2026-09-25 20:11:34.483694+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-25 20:11:34.474148+05:30	\N	\N	Local	\N
49c4e7da-23ec-aab1-9fdf-61dd23764d10	nikhil@acme.co	$2a$12$3Me9Egj1hx09TH9tvqK5fOYoJSaR.xelZmFTrb7aVjR3UDCx2Zit2	Nikhil Rao	u5	\N	\N	NR	\N	t	f	a68c3dc3-e12b-4689-adeb-b45a78ebb099	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	\N	\N	\N	Local	\N
65e2ffa3-6073-780a-b849-4d9604c7251c	priya@acme.co	$2a$12$835TWODe47VccYADR3FJYefpGkXbwpcyyHgXPbOgOQ2LhGMR5fYgy	Priya Verma	u6	\N	\N	PV	\N	t	f	4c275e12-c262-4542-9282-31006032cf5f	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-08-10 18:27:13.729958+05:30	\N	\N	Local	\N
730809c0-fc01-a664-03ca-28e0e32d0393	sales@acme.co	$2a$12$eUDd.KuBoCtEpt600G6keOeyAYibJ9yBUlnENEeM7QFomqmcPDFnO	Sales User	u18	\N	\N	SU	\N	t	f	0f2f5be6-312b-4782-99a4-e9ff2a1fa89c	2026-08-10 17:53:35.786937+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-09-23 17:45:25.554143+05:30	\N	\N	Local	\N
9f6f34df-dc47-f198-f3f6-e577aab1cbca	dev@acme.co	$2a$12$5Bkiult/bQil90.dkIxaP.FaYrIxnBoWP/YdWmHRl2fcQ3BYMChYG	Dev Patel	u9	\N	\N	DP	\N	t	f	df987f8a-1233-41f3-a519-ccfb6e225952	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-08-11 11:50:37.412783+05:30	\N	2026-08-10 12:27:47.765224+05:30	Local	\N
886afd00-b1c2-471b-89f7-93cedb799a77	dhanshree.pansare@squad1.io		Dhanshree Pansare	EMP-0022	\N	\N	\N	\N	t	f	3cdaf36a-c349-4239-8533-df54dbdbb770	2026-09-08 15:27:07.593469+05:30	2026-09-24 16:51:44.673046+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	1	2026-09-09 13:16:12.853017+05:30	\N	\N	Microsoft	Sjm3sQ3oqL_QkKeIaRJjNGooFHu2Ep6kZSfu3bDFWt4
a37e30de-15f3-bf1e-fa9f-4a98da9033ab	vikram@acme.co	$2a$12$rklGxZ360m0v2iK7y3eDTurkwTA217S0qWqM4Yomugl0U8FP5OlOm	Vikram Shah	u3	\N	\N	VS	\N	t	f	e6fd9368-d9d7-43a4-af78-445c2744c3d9	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-09-09 12:43:06.341062+05:30	\N	\N	Local	\N
a3a20ac4-43a2-de64-52d3-bfafce7c7053	sana@acme.co	$2a$12$Fal774Qb.H/58FDV82PcgeZmOPn.YDdoYyL5osSSMgYmvVsQCkBRW	Sana Iyer	u4	\N	\N	SI	\N	t	f	ff1f052d-a16a-4e5c-9f24-cebf9334d248	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-08-17 12:39:47.329355+05:30	\N	\N	Local	\N
2bca17e7-5b71-8ac3-6c86-440cb3b75bab	vikrant@acme.co	$2a$12$oirJjlIr4r1l2tJVZVFVyenUErUE.3oLGQYTgQId1kGj9Vg77wl/.	Vikrant Malhotra	u13	\N	\N	VM	\N	t	f	529b6df4-d182-4c06-9c26-99b1eff2a7e5	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-08-10 12:29:34.903769+05:30	\N	2026-08-10 12:29:52.170405+05:30	Local	\N
40517b71-5e62-182e-73b5-d4070e20a3c2	dhanshree@acme.co	$2a$12$9WKUhE4T2ZjPqF89MTlGq.oxQDheGNYJcm7ibM8jt/nNNkyZp5hea	Dhanshree	u14	\N	\N	DS	\N	t	f	d5e52e74-de97-4a33-8a09-c35df51bffe3	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-09-09 13:14:48.524668+05:30	\N	2026-08-10 12:32:04.244561+05:30	Local	\N
dc139a9d-b996-7354-6c27-72659ea2fd59	accounts@acme.co	$2a$12$0J6.3b22OmLpAzwctiQwkuJGur2Wgf2HmjrH8.aEvzn/gSq6mt286	Accounts User	u17	\N	\N	AC	\N	t	f	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-08-10 17:53:35.786937+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-09-07 19:17:12.716993+05:30	\N	\N	Local	\N
111775f6-5d80-5333-478e-68e2fda584fa	meera@acme.co	$2a$12$SFyR6AlQIGTX1TNyRL5Fl.gXXbmdkMYJ4FtH5meL5iodpCk9tyjR2	Meera Joshi	u8	\N	\N	MJ	\N	t	f	df987f8a-1233-41f3-a519-ccfb6e225952	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-08-11 16:55:29.999149+05:30	\N	\N	Local	\N
b1d3f51c-b209-d352-4b52-3f4008801ab3	kavya@acme.co	$2a$12$bCHytpaQmcwpqkeWXxs6r.MTi./iDTowYcKYRoAYnVi27Jr9/fpB6	Kavya Nair	u10	\N	\N	KN	\N	t	f	df987f8a-1233-41f3-a519-ccfb6e225952	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-08-11 17:21:44.284921+05:30	\N	\N	Local	\N
1a077a8c-4029-8ded-d563-19e9b4bdf301	aarav@acme.co	$2a$12$cno.wRoZouMi6rTCw3UPNeYiQbz5OkxjTmtEttvFeXWUxLoMmAB3a	Aarav Mehta	u1	\N	\N	AM	\N	t	f	9bdd1d72-07cc-4c32-8b5b-543def1c2cad	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-09-23 17:02:11.352221+05:30	\N	\N	Local	\N
304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	anita@acme.co	$2a$12$hJgRCw2I7rg8JWvuxJbNiO6ORUS3b61y5I1pUTeirafb9C3/kZQYa	Anita Desai	u12	\N	\N	AD	\N	t	f	afd3913f-cd04-453d-9990-92929dcadefa	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-08-21 22:15:24.911658+05:30	\N	\N	Local	\N
47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	hr@acme.co	$2a$12$w7vIpZmZ9zh4cgyae4fyH.fY5G225liNiipvucoO.lG8D0XSF6DT.	HR User	u16	\N	\N	HU	\N	t	f	677140ff-ffbe-4030-ab6c-546a3c87cfe9	2026-08-10 17:53:35.786937+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-09-24 12:14:38.947835+05:30	\N	\N	Local	\N
b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	rahul@acme.co	$2a$12$jUEtriOZxOvHzyasTMZOTe5DNFAO0HUzdnnJ4K/Wu8.mA4zlLAfie	Rahul Gupta	u11	\N	\N	RG	\N	t	f	c805e8c6-5b61-478c-a56d-88f2dc526107	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-09-07 18:06:33.201201+05:30	\N	\N	Local	\N
70902d9d-f74f-670b-d4f5-7d593db9d5e8	swati.mishra@acme.co	$2a$12$skzM5Ff3j.y4yG62KN0sSuu1HtG/WiOygNNvnrF5TPeKbKNrxozu6	Swati Mishra	u26	\N	\N	SM	\N	t	f	57fd6151-2026-4a42-948e-f9c6608191bf	2026-09-25 19:22:24.221994+05:30	2026-09-25 19:42:05.851551+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-25 19:42:05.848623+05:30	\N	\N	Local	\N
e7554ba2-e546-93ce-1e88-a073badd78a2	riya@acme.co	$2a$12$CzpTZNZ2y2nZ1JrYVhtswOupr71JQfhYhcmgFJ.feDNh6CflQvDMK	Riya Kapoor	u2	\N	\N	RK	\N	t	f	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	0	2026-09-23 17:52:11.961307+05:30	\N	2026-08-07 13:27:03.565302+05:30	Local	\N
4b13c92d-6946-1f03-f29d-eeab64dbb999	kunal.deshmukh@acme.co	$2a$12$cD0Z.n9VoDoafb8wt.3TAOrbuVYAKZvyBkpUKiKdwbnbGfIvXaxZK	Kunal Deshmukh	u19	\N	\N	KD	\N	t	f	b88afa2f-417b-4cbe-a032-1855ef15c0d9	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
90aea6e7-2f87-a6bc-29ba-5fa8468fbb88	ananya.verma@acme.co	$2a$12$Zfe4sFqWQVO.Tz/ELvjd2Om3b0OH7PHAud0LcvFGzdGfgMR6mBhTW	Ananya Verma	u21	\N	\N	AV	\N	t	f	775be3c0-980d-4ef5-a955-4022a79c77a1	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
005d03dd-e4a1-0ce9-afad-1bc8f1b4965a	manoj.bhatt@acme.co	$2a$12$pZkYp56hpUUV3sWyr55C9uveElAcmquUqbsFlCGzfpK4cp6IB7SyS	Manoj Bhatt	u24	\N	\N	MB	\N	t	f	48b21b7c-b527-41e5-aa49-ef222f7a303b	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
1c17fcc3-a90f-fd2f-3799-4726d271c71a	girish.shenoy@acme.co	$2a$12$gyXCFrHabzfqeBtx07lALe7Cs.GvFprlLD9fk8wBVFZXODtyA/FkW	Girish Shenoy	u22	\N	\N	GS	\N	t	f	86d480d7-4aa5-4763-ba7d-77ec8e803255	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
403ac3b7-2e02-8dad-5379-6fefff8ab5db	deepak.sawant@acme.co	$2a$12$bWKPD1kt20XXg3Erhog0meGRf6vcrn83dZ2oa9MOqiOL9Ca4qKdFi	Deepak Sawant	u28	\N	\N	DS	\N	t	f	2b522ed1-4bbd-449f-92b1-9de7211d0351	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
5350ce95-1e9e-76b2-94ac-50ba7ebcab83	suresh.pillai@acme.co	$2a$12$T0f4wWVcVQ30w4j.82QWDuxgEDSEKDHA/Zoz9XK96NzoubPKmw5bW	Suresh Pillai	u23	\N	\N	SP	\N	t	f	5aded8b4-daa0-4790-aa86-79bc7480828a	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
59c27763-7c95-9426-3a82-ea22927200fb	pooja.nair@acme.co	$2a$12$PSzuQ4ivxFcCzwbyNUyT2O7ytMxrTQZLrI/56gs4.t2peibBtdTm2	Pooja Nair	u30	\N	\N	PN	\N	t	f	f7cdb414-a822-486e-8d65-6b71d6741bdd	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
804bbfc4-50f9-7c92-76f1-1dfd6d8d5904	kavya.desai@acme.co	$2a$12$ZRiP58fMXeUJg5UcW7dTr.cDd/vPR2kFWHBGyrVqHZdkR2qdUtHNu	Kavya Desai	u31	\N	\N	KD	\N	t	f	69ce8564-eaee-4aa7-8047-b502d64c491c	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
9ae547bf-1e08-3404-abd7-3eb2191ef8c1	amit.pandey@acme.co	$2a$12$Ds.OkruuLykNEso08/OqsOk9nRpVDNn8Dd9py4v8ULqUfxl1QRrAa	Amit Pandey	u29	\N	\N	AP	\N	t	f	a68c3dc3-e12b-4689-adeb-b45a78ebb099	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
b1fcef91-6ec6-8670-10d1-3ac524cc02b9	itadmin@acme.co	$2a$12$0WXXkZbgAPY0Y2ouuIuP8eCZyUtBS87aBKBM4VwSiO5b2oQ7T/06C	IT Admin User	u32	\N	\N	IT	\N	t	f	4093aa75-f904-4a81-9251-5937b1735ad0	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
bb3a5272-6b92-44af-e618-433e4add85fa	kiran.mathur@acme.co	$2a$12$.JDwkqmpNCjusa95QfkDLO19Q9fX7v2lu/wgktPX9i9F52uH0cE4O	Kiran Mathur	u25	\N	\N	KM	\N	t	f	38eb3802-84bc-4f13-a55c-9e72acf9634d	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
c747bbae-8ba9-e8d2-4344-75b40ecdd2cc	rajesh.kadam@acme.co	$2a$12$OHVNYtBg9hhvlQ6EKfX/8uNnTY6gA3YIuDbR85v0R9g20Ft0LwRk.	Rajesh Kadam	u27	\N	\N	RK	\N	t	f	f6e6844d-874a-49f6-b704-0133785e4b56	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
d74e1e89-87c7-e51f-9234-051a3c0603b5	pooja.sharma@acme.co	$2a$12$i3ZnzT87tFqSeSKlIAJ2RuqDStwbk/Lpcau1pD22Td5HtbPF1yp26	Pooja Sharma	u20	\N	\N	PS	\N	t	f	7bd14a17-44ba-435a-9419-37d4216830f0	2026-09-25 19:22:24.221994+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
f2f23eb1-efb6-f0a7-c57e-0ead09121a21	arjun@acme.co	$2a$12$bPDdjO1jQecw9MHRrzfoJO.Zl5dBr02LjRU1y160oNgJ4dR96/cK2	Arjun Singh	u7	\N	\N	AS	\N	t	f	df987f8a-1233-41f3-a519-ccfb6e225952	2026-08-07 13:19:59.669429+05:30	2026-09-25 19:29:25.94021+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-25 19:29:25.877153+05:30	\N	\N	Local	\N
\.


--
-- Name: employees CK_employees_EmployeeCode_Format; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.employees
    ADD CONSTRAINT "CK_employees_EmployeeCode_Format" CHECK ((("EmployeeCode")::text ~ '^(TK|TKI)-[0-9]{4}$'::text)) NOT VALID;


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: client_assignments PK_client_assignments; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_assignments
    ADD CONSTRAINT "PK_client_assignments" PRIMARY KEY ("ClientId", "UserId");


--
-- Name: client_contacts PK_client_contacts; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_contacts
    ADD CONSTRAINT "PK_client_contacts" PRIMARY KEY ("Id");


--
-- Name: clients PK_clients; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "PK_clients" PRIMARY KEY ("Id");


--
-- Name: employees PK_employees; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "PK_employees" PRIMARY KEY ("Id");


--
-- Name: exited_employees PK_exited_employees; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exited_employees
    ADD CONSTRAINT "PK_exited_employees" PRIMARY KEY ("Id");


--
-- Name: mst_cities PK_mst_cities; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_cities
    ADD CONSTRAINT "PK_mst_cities" PRIMARY KEY ("Id");


--
-- Name: mst_contact_designations PK_mst_contact_designations; Type: CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.mst_contact_designations
    ADD CONSTRAINT "PK_mst_contact_designations" PRIMARY KEY ("Id");


--
-- Name: mst_contact_types PK_mst_contact_types; Type: CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.mst_contact_types
    ADD CONSTRAINT "PK_mst_contact_types" PRIMARY KEY ("Id");


--
-- Name: mst_countries PK_mst_countries; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_countries
    ADD CONSTRAINT "PK_mst_countries" PRIMARY KEY ("Id");


--
-- Name: mst_departments PK_mst_departments; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_departments
    ADD CONSTRAINT "PK_mst_departments" PRIMARY KEY ("Id");


--
-- Name: mst_designations PK_mst_designations; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_designations
    ADD CONSTRAINT "PK_mst_designations" PRIMARY KEY ("Id");


--
-- Name: mst_industries PK_mst_industries; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_industries
    ADD CONSTRAINT "PK_mst_industries" PRIMARY KEY ("Id");


--
-- Name: mst_nationalities PK_mst_nationalities; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_nationalities
    ADD CONSTRAINT "PK_mst_nationalities" PRIMARY KEY ("Id");


--
-- Name: mst_roles PK_mst_roles; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_roles
    ADD CONSTRAINT "PK_mst_roles" PRIMARY KEY ("Id");


--
-- Name: mst_salary_bands PK_mst_salary_bands; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_salary_bands
    ADD CONSTRAINT "PK_mst_salary_bands" PRIMARY KEY ("Id");


--
-- Name: refresh_tokens PK_refresh_tokens; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT "PK_refresh_tokens" PRIMARY KEY ("Id");


--
-- Name: repository_departments PK_repository_departments; Type: CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.repository_departments
    ADD CONSTRAINT "PK_repository_departments" PRIMARY KEY ("RepositoryItemId", "DepartmentId");


--
-- Name: role_permission_audits PK_role_permission_audits; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permission_audits
    ADD CONSTRAINT "PK_role_permission_audits" PRIMARY KEY ("Id");


--
-- Name: roles PK_roles; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT "PK_roles" PRIMARY KEY ("Id");


--
-- Name: sub_ventures PK_sub_ventures; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_ventures
    ADD CONSTRAINT "PK_sub_ventures" PRIMARY KEY ("Id");


--
-- Name: team_day_entries PK_team_day_entries; Type: CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.team_day_entries
    ADD CONSTRAINT "PK_team_day_entries" PRIMARY KEY ("Id");


--
-- Name: team_member_holidays PK_team_member_holidays; Type: CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.team_member_holidays
    ADD CONSTRAINT "PK_team_member_holidays" PRIMARY KEY ("Id");


--
-- Name: team_member_schedules PK_team_member_schedules; Type: CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.team_member_schedules
    ADD CONSTRAINT "PK_team_member_schedules" PRIMARY KEY ("Id");


--
-- Name: users PK_users; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_users" PRIMARY KEY ("Id");


--
-- Name: employee_activity_logs employee_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.employee_activity_logs
    ADD CONSTRAINT employee_activity_logs_pkey PRIMARY KEY ("Id");


--
-- Name: mst_business_units mst_business_units_Code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_business_units
    ADD CONSTRAINT "mst_business_units_Code_key" UNIQUE ("Code");


--
-- Name: mst_business_units mst_business_units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_business_units
    ADD CONSTRAINT mst_business_units_pkey PRIMARY KEY ("Id");


--
-- Name: mst_certifications mst_certifications_pkey; Type: CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.mst_certifications
    ADD CONSTRAINT mst_certifications_pkey PRIMARY KEY ("Id");


--
-- Name: mst_email_domains mst_email_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_email_domains
    ADD CONSTRAINT mst_email_domains_pkey PRIMARY KEY ("Id");


--
-- Name: mst_employee_statuses mst_employee_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.mst_employee_statuses
    ADD CONSTRAINT mst_employee_statuses_pkey PRIMARY KEY ("Id");


--
-- Name: mst_graduation_degrees mst_graduation_degrees_pkey; Type: CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.mst_graduation_degrees
    ADD CONSTRAINT mst_graduation_degrees_pkey PRIMARY KEY ("Id");


--
-- Name: mst_offices mst_offices_Code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_offices
    ADD CONSTRAINT "mst_offices_Code_key" UNIQUE ("Code");


--
-- Name: mst_offices mst_offices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_offices
    ADD CONSTRAINT mst_offices_pkey PRIMARY KEY ("Id");


--
-- Name: mst_post_graduation_degrees mst_post_graduation_degrees_pkey; Type: CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.mst_post_graduation_degrees
    ADD CONSTRAINT mst_post_graduation_degrees_pkey PRIMARY KEY ("Id");


--
-- Name: mst_reporting_managers mst_reporting_managers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_reporting_managers
    ADD CONSTRAINT mst_reporting_managers_pkey PRIMARY KEY ("Id");


--
-- Name: mst_work_locations mst_work_locations_Code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_work_locations
    ADD CONSTRAINT "mst_work_locations_Code_key" UNIQUE ("Code");


--
-- Name: mst_work_locations mst_work_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_work_locations
    ADD CONSTRAINT mst_work_locations_pkey PRIMARY KEY ("Id");


--
-- Name: repository_activity_logs repository_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repository_activity_logs
    ADD CONSTRAINT repository_activity_logs_pkey PRIMARY KEY ("Id");


--
-- Name: repository repository_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repository
    ADD CONSTRAINT repository_pkey PRIMARY KEY ("Id");


--
-- Name: IX_client_assignments_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_client_assignments_UserId" ON public.client_assignments USING btree ("UserId");


--
-- Name: IX_client_contacts_ClientId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_client_contacts_ClientId" ON public.client_contacts USING btree ("ClientId");


--
-- Name: IX_client_contacts_SubVentureId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_client_contacts_SubVentureId" ON public.client_contacts USING btree ("SubVentureId");


--
-- Name: IX_clients_CityId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_clients_CityId" ON public.clients USING btree ("CityId");


--
-- Name: IX_clients_CountryId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_clients_CountryId" ON public.clients USING btree ("CountryId");


--
-- Name: IX_clients_EngagementManagerId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_clients_EngagementManagerId" ON public.clients USING btree ("EngagementManagerId");


--
-- Name: IX_clients_IndustryId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_clients_IndustryId" ON public.clients USING btree ("IndustryId");


--
-- Name: IX_clients_Name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_clients_Name" ON public.clients USING btree ("Name");


--
-- Name: IX_clients_SalesManagerId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_clients_SalesManagerId" ON public.clients USING btree ("SalesManagerId");


--
-- Name: IX_employee_activity_logs_CreatedAtUtc; Type: INDEX; Schema: public; Owner: trackerpro
--

CREATE INDEX "IX_employee_activity_logs_CreatedAtUtc" ON public.employee_activity_logs USING btree ("CreatedAtUtc" DESC);


--
-- Name: IX_employee_activity_logs_EmployeeId; Type: INDEX; Schema: public; Owner: trackerpro
--

CREATE INDEX "IX_employee_activity_logs_EmployeeId" ON public.employee_activity_logs USING btree ("EmployeeId");


--
-- Name: IX_employees_DepartmentId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_employees_DepartmentId" ON public.employees USING btree ("DepartmentId");


--
-- Name: IX_employees_DesignationId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_employees_DesignationId" ON public.employees USING btree ("DesignationId");


--
-- Name: IX_employees_EmployeeCode; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_employees_EmployeeCode" ON public.employees USING btree ("EmployeeCode");


--
-- Name: IX_employees_EngagementManagerEmployeeId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_employees_EngagementManagerEmployeeId" ON public.employees USING btree ("EngagementManagerEmployeeId");


--
-- Name: IX_employees_JobRoleId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_employees_JobRoleId" ON public.employees USING btree ("JobRoleId");


--
-- Name: IX_employees_NationalityId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_employees_NationalityId" ON public.employees USING btree ("NationalityId");


--
-- Name: IX_employees_ProjectManagerId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_employees_ProjectManagerId" ON public.employees USING btree ("ProjectManagerId");


--
-- Name: IX_employees_ReportingManagerId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_employees_ReportingManagerId" ON public.employees USING btree ("ReportingManagerId");


--
-- Name: IX_employees_SalaryBandId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_employees_SalaryBandId" ON public.employees USING btree ("SalaryBandId");


--
-- Name: IX_employees_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_employees_UserId" ON public.employees USING btree ("UserId");


--
-- Name: IX_employees_WorkEmail; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_employees_WorkEmail" ON public.employees USING btree ("WorkEmail");


--
-- Name: IX_exited_employees_EmployeeCode; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_exited_employees_EmployeeCode" ON public.exited_employees USING btree ("EmployeeCode");


--
-- Name: IX_exited_employees_OriginalEmployeeId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_exited_employees_OriginalEmployeeId" ON public.exited_employees USING btree ("OriginalEmployeeId");


--
-- Name: IX_mst_business_units_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_business_units_Code" ON public.mst_business_units USING btree ("Code");


--
-- Name: IX_mst_cities_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_cities_Code" ON public.mst_cities USING btree ("Code");


--
-- Name: IX_mst_cities_CountryId_Name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_cities_CountryId_Name" ON public.mst_cities USING btree ("CountryId", "Name");


--
-- Name: IX_mst_contact_designations_Code; Type: INDEX; Schema: public; Owner: trackerpro
--

CREATE UNIQUE INDEX "IX_mst_contact_designations_Code" ON public.mst_contact_designations USING btree ("Code");


--
-- Name: IX_mst_contact_designations_Name; Type: INDEX; Schema: public; Owner: trackerpro
--

CREATE UNIQUE INDEX "IX_mst_contact_designations_Name" ON public.mst_contact_designations USING btree ("Name");


--
-- Name: IX_mst_contact_types_Code; Type: INDEX; Schema: public; Owner: trackerpro
--

CREATE UNIQUE INDEX "IX_mst_contact_types_Code" ON public.mst_contact_types USING btree ("Code");


--
-- Name: IX_mst_contact_types_Name; Type: INDEX; Schema: public; Owner: trackerpro
--

CREATE UNIQUE INDEX "IX_mst_contact_types_Name" ON public.mst_contact_types USING btree ("Name");


--
-- Name: IX_mst_countries_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_countries_Code" ON public.mst_countries USING btree ("Code");


--
-- Name: IX_mst_countries_Name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_countries_Name" ON public.mst_countries USING btree ("Name");


--
-- Name: IX_mst_departments_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_departments_Code" ON public.mst_departments USING btree ("Code");


--
-- Name: IX_mst_departments_Name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_departments_Name" ON public.mst_departments USING btree ("Name");


--
-- Name: IX_mst_designations_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_designations_Code" ON public.mst_designations USING btree ("Code");


--
-- Name: IX_mst_designations_DepartmentId_Name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_designations_DepartmentId_Name" ON public.mst_designations USING btree ("DepartmentId", "Name");


--
-- Name: IX_mst_email_domains_DomainName; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_email_domains_DomainName" ON public.mst_email_domains USING btree ("DomainName");


--
-- Name: IX_mst_employee_statuses_Code; Type: INDEX; Schema: public; Owner: trackerpro
--

CREATE UNIQUE INDEX "IX_mst_employee_statuses_Code" ON public.mst_employee_statuses USING btree ("Code") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_mst_industries_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_industries_Code" ON public.mst_industries USING btree ("Code");


--
-- Name: IX_mst_industries_Name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_industries_Name" ON public.mst_industries USING btree ("Name");


--
-- Name: IX_mst_nationalities_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_nationalities_Code" ON public.mst_nationalities USING btree ("Code");


--
-- Name: IX_mst_nationalities_Name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_nationalities_Name" ON public.mst_nationalities USING btree ("Name");


--
-- Name: IX_mst_offices_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_offices_Code" ON public.mst_offices USING btree ("Code");


--
-- Name: IX_mst_offices_WorkLocationId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_mst_offices_WorkLocationId" ON public.mst_offices USING btree ("WorkLocationId");


--
-- Name: IX_mst_reporting_managers_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_reporting_managers_Code" ON public.mst_reporting_managers USING btree ("Code");


--
-- Name: IX_mst_reporting_managers_EmployeeId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_mst_reporting_managers_EmployeeId" ON public.mst_reporting_managers USING btree ("EmployeeId");


--
-- Name: IX_mst_roles_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_roles_Code" ON public.mst_roles USING btree ("Code");


--
-- Name: IX_mst_roles_DesignationId_Name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_roles_DesignationId_Name" ON public.mst_roles USING btree ("DesignationId", "Name");


--
-- Name: IX_mst_salary_bands_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_salary_bands_Code" ON public.mst_salary_bands USING btree ("Code");


--
-- Name: IX_mst_salary_bands_Name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_salary_bands_Name" ON public.mst_salary_bands USING btree ("Name");


--
-- Name: IX_mst_work_locations_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_work_locations_Code" ON public.mst_work_locations USING btree ("Code");


--
-- Name: IX_refresh_tokens_TokenHash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_refresh_tokens_TokenHash" ON public.refresh_tokens USING btree ("TokenHash");


--
-- Name: IX_refresh_tokens_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_refresh_tokens_UserId" ON public.refresh_tokens USING btree ("UserId");


--
-- Name: IX_repository_Category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_repository_Category" ON public.repository USING btree ("Category");


--
-- Name: IX_repository_DeletedAtUtc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_repository_DeletedAtUtc" ON public.repository USING btree ("DeletedAtUtc");


--
-- Name: IX_repository_activity_logs_CreatedAtUtc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_repository_activity_logs_CreatedAtUtc" ON public.repository_activity_logs USING btree ("CreatedAtUtc");


--
-- Name: IX_repository_activity_logs_DeletedAtUtc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_repository_activity_logs_DeletedAtUtc" ON public.repository_activity_logs USING btree ("DeletedAtUtc");


--
-- Name: IX_repository_departments_DepartmentId; Type: INDEX; Schema: public; Owner: trackerpro
--

CREATE INDEX "IX_repository_departments_DepartmentId" ON public.repository_departments USING btree ("DepartmentId");


--
-- Name: IX_role_permission_audits_CreatedAtUtc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_role_permission_audits_CreatedAtUtc" ON public.role_permission_audits USING btree ("CreatedAtUtc");


--
-- Name: IX_role_permission_audits_RoleId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_role_permission_audits_RoleId" ON public.role_permission_audits USING btree ("RoleId");


--
-- Name: IX_roles_Name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_roles_Name" ON public.roles USING btree ("Name");


--
-- Name: IX_sub_ventures_ClientId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_sub_ventures_ClientId" ON public.sub_ventures USING btree ("ClientId");


--
-- Name: IX_team_day_entries_EmployeeId_WorkDate; Type: INDEX; Schema: public; Owner: trackerpro
--

CREATE UNIQUE INDEX "IX_team_day_entries_EmployeeId_WorkDate" ON public.team_day_entries USING btree ("EmployeeId", "WorkDate") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_team_member_holidays_EmployeeId_HolidayDate; Type: INDEX; Schema: public; Owner: trackerpro
--

CREATE UNIQUE INDEX "IX_team_member_holidays_EmployeeId_HolidayDate" ON public.team_member_holidays USING btree ("EmployeeId", "HolidayDate") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_team_member_schedules_EmployeeId; Type: INDEX; Schema: public; Owner: trackerpro
--

CREATE UNIQUE INDEX "IX_team_member_schedules_EmployeeId" ON public.team_member_schedules USING btree ("EmployeeId") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_users_Email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_users_Email" ON public.users USING btree ("Email");


--
-- Name: IX_users_EmployeeId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_users_EmployeeId" ON public.users USING btree ("EmployeeId");


--
-- Name: IX_users_MicrosoftOid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_users_MicrosoftOid" ON public.users USING btree ("MicrosoftOid") WHERE ("MicrosoftOid" IS NOT NULL);


--
-- Name: IX_users_RoleId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_users_RoleId" ON public.users USING btree ("RoleId");


--
-- Name: client_assignments FK_client_assignments_clients_ClientId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_assignments
    ADD CONSTRAINT "FK_client_assignments_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES public.clients("Id") ON DELETE CASCADE;


--
-- Name: client_assignments FK_client_assignments_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_assignments
    ADD CONSTRAINT "FK_client_assignments_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE CASCADE;


--
-- Name: client_contacts FK_client_contacts_clients_ClientId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_contacts
    ADD CONSTRAINT "FK_client_contacts_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES public.clients("Id") ON DELETE CASCADE;


--
-- Name: client_contacts FK_client_contacts_sub_ventures_SubVentureId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_contacts
    ADD CONSTRAINT "FK_client_contacts_sub_ventures_SubVentureId" FOREIGN KEY ("SubVentureId") REFERENCES public.sub_ventures("Id") ON DELETE CASCADE;


--
-- Name: clients FK_clients_employees_EngagementManagerId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "FK_clients_employees_EngagementManagerId" FOREIGN KEY ("EngagementManagerId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: clients FK_clients_employees_SalesManagerId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "FK_clients_employees_SalesManagerId" FOREIGN KEY ("SalesManagerId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: clients FK_clients_mst_cities_CityId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "FK_clients_mst_cities_CityId" FOREIGN KEY ("CityId") REFERENCES public.mst_cities("Id") ON DELETE RESTRICT;


--
-- Name: clients FK_clients_mst_countries_CountryId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "FK_clients_mst_countries_CountryId" FOREIGN KEY ("CountryId") REFERENCES public.mst_countries("Id") ON DELETE RESTRICT;


--
-- Name: clients FK_clients_mst_industries_IndustryId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "FK_clients_mst_industries_IndustryId" FOREIGN KEY ("IndustryId") REFERENCES public.mst_industries("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_employees_EngagementManagerEmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_employees_EngagementManagerEmployeeId" FOREIGN KEY ("EngagementManagerEmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_employees_ProjectManagerId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_employees_ProjectManagerId" FOREIGN KEY ("ProjectManagerId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_employees_ReportingManagerId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_employees_ReportingManagerId" FOREIGN KEY ("ReportingManagerId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: employees FK_employees_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES public.mst_departments("Id") ON DELETE SET NULL;


--
-- Name: employees FK_employees_mst_designations_DesignationId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_designations_DesignationId" FOREIGN KEY ("DesignationId") REFERENCES public.mst_designations("Id") ON DELETE SET NULL;


--
-- Name: employees FK_employees_mst_employee_statuses_EmployeeStatusId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_employee_statuses_EmployeeStatusId" FOREIGN KEY ("EmployeeStatusId") REFERENCES public.mst_employee_statuses("Id") ON DELETE SET NULL;


--
-- Name: employees FK_employees_mst_nationalities_NationalityId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_nationalities_NationalityId" FOREIGN KEY ("NationalityId") REFERENCES public.mst_nationalities("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_mst_roles_JobRoleId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_roles_JobRoleId" FOREIGN KEY ("JobRoleId") REFERENCES public.mst_roles("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_mst_salary_bands_SalaryBandId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_salary_bands_SalaryBandId" FOREIGN KEY ("SalaryBandId") REFERENCES public.mst_salary_bands("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE SET NULL;


--
-- Name: mst_cities FK_mst_cities_mst_countries_CountryId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_cities
    ADD CONSTRAINT "FK_mst_cities_mst_countries_CountryId" FOREIGN KEY ("CountryId") REFERENCES public.mst_countries("Id") ON DELETE RESTRICT;


--
-- Name: mst_designations FK_mst_designations_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_designations
    ADD CONSTRAINT "FK_mst_designations_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES public.mst_departments("Id") ON DELETE SET NULL;


--
-- Name: mst_reporting_managers FK_mst_reporting_managers_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_reporting_managers
    ADD CONSTRAINT "FK_mst_reporting_managers_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: mst_roles FK_mst_roles_mst_designations_DesignationId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_roles
    ADD CONSTRAINT "FK_mst_roles_mst_designations_DesignationId" FOREIGN KEY ("DesignationId") REFERENCES public.mst_designations("Id") ON DELETE RESTRICT;


--
-- Name: refresh_tokens FK_refresh_tokens_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT "FK_refresh_tokens_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE CASCADE;


--
-- Name: repository_departments FK_repository_departments_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.repository_departments
    ADD CONSTRAINT "FK_repository_departments_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES public.mst_departments("Id") ON DELETE CASCADE;


--
-- Name: repository_departments FK_repository_departments_repository_RepositoryItemId; Type: FK CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.repository_departments
    ADD CONSTRAINT "FK_repository_departments_repository_RepositoryItemId" FOREIGN KEY ("RepositoryItemId") REFERENCES public.repository("Id") ON DELETE CASCADE;


--
-- Name: role_permission_audits FK_role_permission_audits_roles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permission_audits
    ADD CONSTRAINT "FK_role_permission_audits_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public.roles("Id") ON DELETE CASCADE;


--
-- Name: sub_ventures FK_sub_ventures_clients_ClientId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_ventures
    ADD CONSTRAINT "FK_sub_ventures_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES public.clients("Id") ON DELETE CASCADE;


--
-- Name: team_day_entries FK_team_day_entries_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.team_day_entries
    ADD CONSTRAINT "FK_team_day_entries_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: team_member_holidays FK_team_member_holidays_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.team_member_holidays
    ADD CONSTRAINT "FK_team_member_holidays_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: team_member_schedules FK_team_member_schedules_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: trackerpro
--

ALTER TABLE ONLY public.team_member_schedules
    ADD CONSTRAINT "FK_team_member_schedules_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: users FK_users_roles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "FK_users_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public.roles("Id") ON DELETE RESTRICT;


--
-- Name: mst_designations mst_designations_DefaultRoleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_designations
    ADD CONSTRAINT "mst_designations_DefaultRoleId_fkey" FOREIGN KEY ("DefaultRoleId") REFERENCES public.roles("Id") ON DELETE SET NULL;


--
-- Name: mst_offices mst_offices_WorkLocationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_offices
    ADD CONSTRAINT "mst_offices_WorkLocationId_fkey" FOREIGN KEY ("WorkLocationId") REFERENCES public.mst_work_locations("Id") ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO trackerpro;


--
-- Name: TABLE "__EFMigrationsHistory"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."__EFMigrationsHistory" TO trackerpro;


--
-- Name: TABLE client_assignments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.client_assignments TO trackerpro;


--
-- Name: TABLE client_contacts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.client_contacts TO trackerpro;


--
-- Name: TABLE clients; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.clients TO trackerpro;


--
-- Name: TABLE employees; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.employees TO trackerpro;


--
-- Name: TABLE exited_employees; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.exited_employees TO trackerpro;


--
-- Name: TABLE mst_business_units; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_business_units TO trackerpro;


--
-- Name: TABLE mst_cities; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_cities TO trackerpro;


--
-- Name: TABLE mst_countries; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_countries TO trackerpro;


--
-- Name: TABLE mst_departments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_departments TO trackerpro;


--
-- Name: TABLE mst_designations; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_designations TO trackerpro;


--
-- Name: TABLE mst_email_domains; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_email_domains TO trackerpro;


--
-- Name: TABLE mst_industries; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_industries TO trackerpro;


--
-- Name: TABLE mst_nationalities; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_nationalities TO trackerpro;


--
-- Name: TABLE mst_offices; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_offices TO trackerpro;


--
-- Name: TABLE mst_reporting_managers; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_reporting_managers TO trackerpro;


--
-- Name: TABLE mst_roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_roles TO trackerpro;


--
-- Name: TABLE mst_salary_bands; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_salary_bands TO trackerpro;


--
-- Name: TABLE mst_work_locations; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mst_work_locations TO trackerpro;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.refresh_tokens TO trackerpro;


--
-- Name: TABLE repository; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.repository TO trackerpro;


--
-- Name: TABLE repository_activity_logs; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.repository_activity_logs TO trackerpro;


--
-- Name: TABLE role_permission_audits; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.role_permission_audits TO trackerpro;


--
-- Name: TABLE roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.roles TO trackerpro;


--
-- Name: TABLE sub_ventures; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.sub_ventures TO trackerpro;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.users TO trackerpro;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO trackerpro;


--
-- PostgreSQL database dump complete
--

\unrestrict chUxXfzGHMoS56A2MuPWjNgLSpYPNBjLKMo07C3aadZ7Q129HElvOaGUg5I9ZNP

