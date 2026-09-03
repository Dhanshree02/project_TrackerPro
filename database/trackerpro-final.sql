--
-- PostgreSQL database dump
--

\restrict LfjcLBnssjF6328nS5LVttVdYEYlBbsjbRhdoW1eFtHvD5gvssTcfB66RtXhFjw

-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.mst_offices DROP CONSTRAINT IF EXISTS "mst_offices_WorkLocationId_fkey";
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS "FK_users_roles_RoleId";
ALTER TABLE IF EXISTS ONLY public.sub_ventures DROP CONSTRAINT IF EXISTS "FK_sub_ventures_clients_ClientId";
ALTER TABLE IF EXISTS ONLY public.role_permission_audits DROP CONSTRAINT IF EXISTS "FK_role_permission_audits_roles_RoleId";
ALTER TABLE IF EXISTS ONLY public.repository_departments DROP CONSTRAINT IF EXISTS "FK_repository_departments_repository_RepositoryItemId";
ALTER TABLE IF EXISTS ONLY public.repository_departments DROP CONSTRAINT IF EXISTS "FK_repository_departments_mst_departments_DepartmentId";
ALTER TABLE IF EXISTS ONLY public.refresh_tokens DROP CONSTRAINT IF EXISTS "FK_refresh_tokens_users_UserId";
ALTER TABLE IF EXISTS ONLY public.mst_roles DROP CONSTRAINT IF EXISTS "FK_mst_roles_mst_designations_DesignationId";
ALTER TABLE IF EXISTS ONLY public.mst_reporting_managers DROP CONSTRAINT IF EXISTS "FK_mst_reporting_managers_employees_EmployeeId";
ALTER TABLE IF EXISTS ONLY public.mst_designations DROP CONSTRAINT IF EXISTS "FK_mst_designations_mst_departments_DepartmentId";
ALTER TABLE IF EXISTS ONLY public.mst_cities DROP CONSTRAINT IF EXISTS "FK_mst_cities_mst_countries_CountryId";
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS "FK_employees_users_UserId";
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS "FK_employees_mst_salary_bands_SalaryBandId";
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS "FK_employees_mst_roles_JobRoleId";
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS "FK_employees_mst_nationalities_NationalityId";
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS "FK_employees_mst_designations_DesignationId";
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS "FK_employees_mst_departments_DepartmentId";
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS "FK_employees_employees_ReportingManagerId";
ALTER TABLE IF EXISTS ONLY public.clients DROP CONSTRAINT IF EXISTS "FK_clients_mst_industries_IndustryId";
ALTER TABLE IF EXISTS ONLY public.clients DROP CONSTRAINT IF EXISTS "FK_clients_mst_countries_CountryId";
ALTER TABLE IF EXISTS ONLY public.clients DROP CONSTRAINT IF EXISTS "FK_clients_mst_cities_CityId";
ALTER TABLE IF EXISTS ONLY public.clients DROP CONSTRAINT IF EXISTS "FK_clients_employees_SalesManagerId";
ALTER TABLE IF EXISTS ONLY public.clients DROP CONSTRAINT IF EXISTS "FK_clients_employees_EngagementManagerId";
ALTER TABLE IF EXISTS ONLY public.client_contacts DROP CONSTRAINT IF EXISTS "FK_client_contacts_sub_ventures_SubVentureId";
ALTER TABLE IF EXISTS ONLY public.client_contacts DROP CONSTRAINT IF EXISTS "FK_client_contacts_clients_ClientId";
ALTER TABLE IF EXISTS ONLY public.client_assignments DROP CONSTRAINT IF EXISTS "FK_client_assignments_users_UserId";
ALTER TABLE IF EXISTS ONLY public.client_assignments DROP CONSTRAINT IF EXISTS "FK_client_assignments_clients_ClientId";
DROP INDEX IF EXISTS public."IX_users_RoleId";
DROP INDEX IF EXISTS public."IX_users_MicrosoftOid";
DROP INDEX IF EXISTS public."IX_users_EmployeeId";
DROP INDEX IF EXISTS public."IX_users_Email";
DROP INDEX IF EXISTS public."IX_sub_ventures_ClientId";
DROP INDEX IF EXISTS public."IX_roles_Name";
DROP INDEX IF EXISTS public."IX_role_permission_audits_RoleId";
DROP INDEX IF EXISTS public."IX_role_permission_audits_CreatedAtUtc";
DROP INDEX IF EXISTS public."IX_repository_departments_DepartmentId";
DROP INDEX IF EXISTS public."IX_repository_activity_logs_DeletedAtUtc";
DROP INDEX IF EXISTS public."IX_repository_activity_logs_CreatedAtUtc";
DROP INDEX IF EXISTS public."IX_repository_DeletedAtUtc";
DROP INDEX IF EXISTS public."IX_repository_Category";
DROP INDEX IF EXISTS public."IX_refresh_tokens_UserId";
DROP INDEX IF EXISTS public."IX_refresh_tokens_TokenHash";
DROP INDEX IF EXISTS public."IX_mst_work_locations_Code";
DROP INDEX IF EXISTS public."IX_mst_salary_bands_Name";
DROP INDEX IF EXISTS public."IX_mst_salary_bands_Code";
DROP INDEX IF EXISTS public."IX_mst_roles_DesignationId_Name";
DROP INDEX IF EXISTS public."IX_mst_roles_Code";
DROP INDEX IF EXISTS public."IX_mst_reporting_managers_EmployeeId";
DROP INDEX IF EXISTS public."IX_mst_reporting_managers_Code";
DROP INDEX IF EXISTS public."IX_mst_offices_WorkLocationId";
DROP INDEX IF EXISTS public."IX_mst_offices_Code";
DROP INDEX IF EXISTS public."IX_mst_nationalities_Name";
DROP INDEX IF EXISTS public."IX_mst_nationalities_Code";
DROP INDEX IF EXISTS public."IX_mst_industries_Name";
DROP INDEX IF EXISTS public."IX_mst_industries_Code";
DROP INDEX IF EXISTS public."IX_mst_entra_roles_EntraRoleValue";
DROP INDEX IF EXISTS public."IX_mst_entra_roles_Code";
DROP INDEX IF EXISTS public."IX_mst_email_domains_DomainName";
DROP INDEX IF EXISTS public."IX_mst_designations_DepartmentId_Name";
DROP INDEX IF EXISTS public."IX_mst_designations_Code";
DROP INDEX IF EXISTS public."IX_mst_departments_Name";
DROP INDEX IF EXISTS public."IX_mst_departments_Code";
DROP INDEX IF EXISTS public."IX_mst_countries_Name";
DROP INDEX IF EXISTS public."IX_mst_countries_Code";
DROP INDEX IF EXISTS public."IX_mst_cities_CountryId_Name";
DROP INDEX IF EXISTS public."IX_mst_cities_Code";
DROP INDEX IF EXISTS public."IX_mst_business_units_Code";
DROP INDEX IF EXISTS public."IX_exited_employees_OriginalEmployeeId";
DROP INDEX IF EXISTS public."IX_exited_employees_EmployeeCode";
DROP INDEX IF EXISTS public."IX_employees_WorkEmail";
DROP INDEX IF EXISTS public."IX_employees_UserId";
DROP INDEX IF EXISTS public."IX_employees_SalaryBandId";
DROP INDEX IF EXISTS public."IX_employees_ReportingManagerId";
DROP INDEX IF EXISTS public."IX_employees_NationalityId";
DROP INDEX IF EXISTS public."IX_employees_JobRoleId";
DROP INDEX IF EXISTS public."IX_employees_EmployeeCode";
DROP INDEX IF EXISTS public."IX_employees_DesignationId";
DROP INDEX IF EXISTS public."IX_employees_DepartmentId";
DROP INDEX IF EXISTS public."IX_clients_SalesManagerId";
DROP INDEX IF EXISTS public."IX_clients_Name";
DROP INDEX IF EXISTS public."IX_clients_IndustryId";
DROP INDEX IF EXISTS public."IX_clients_EngagementManagerId";
DROP INDEX IF EXISTS public."IX_clients_CountryId";
DROP INDEX IF EXISTS public."IX_clients_CityId";
DROP INDEX IF EXISTS public."IX_client_contacts_SubVentureId";
DROP INDEX IF EXISTS public."IX_client_contacts_ClientId";
DROP INDEX IF EXISTS public."IX_client_assignments_UserId";
ALTER TABLE IF EXISTS ONLY public.repository DROP CONSTRAINT IF EXISTS repository_pkey;
ALTER TABLE IF EXISTS ONLY public.repository_activity_logs DROP CONSTRAINT IF EXISTS repository_activity_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.mst_work_locations DROP CONSTRAINT IF EXISTS mst_work_locations_pkey;
ALTER TABLE IF EXISTS ONLY public.mst_work_locations DROP CONSTRAINT IF EXISTS "mst_work_locations_Code_key";
ALTER TABLE IF EXISTS ONLY public.mst_reporting_managers DROP CONSTRAINT IF EXISTS mst_reporting_managers_pkey;
ALTER TABLE IF EXISTS ONLY public.mst_offices DROP CONSTRAINT IF EXISTS mst_offices_pkey;
ALTER TABLE IF EXISTS ONLY public.mst_offices DROP CONSTRAINT IF EXISTS "mst_offices_Code_key";
ALTER TABLE IF EXISTS ONLY public.mst_email_domains DROP CONSTRAINT IF EXISTS mst_email_domains_pkey;
ALTER TABLE IF EXISTS ONLY public.mst_business_units DROP CONSTRAINT IF EXISTS mst_business_units_pkey;
ALTER TABLE IF EXISTS ONLY public.mst_business_units DROP CONSTRAINT IF EXISTS "mst_business_units_Code_key";
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS "PK_users";
ALTER TABLE IF EXISTS ONLY public.sub_ventures DROP CONSTRAINT IF EXISTS "PK_sub_ventures";
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS "PK_roles";
ALTER TABLE IF EXISTS ONLY public.role_permission_audits DROP CONSTRAINT IF EXISTS "PK_role_permission_audits";
ALTER TABLE IF EXISTS ONLY public.repository_departments DROP CONSTRAINT IF EXISTS "PK_repository_departments";
ALTER TABLE IF EXISTS ONLY public.refresh_tokens DROP CONSTRAINT IF EXISTS "PK_refresh_tokens";
ALTER TABLE IF EXISTS ONLY public.mst_salary_bands DROP CONSTRAINT IF EXISTS "PK_mst_salary_bands";
ALTER TABLE IF EXISTS ONLY public.mst_roles DROP CONSTRAINT IF EXISTS "PK_mst_roles";
ALTER TABLE IF EXISTS ONLY public.mst_nationalities DROP CONSTRAINT IF EXISTS "PK_mst_nationalities";
ALTER TABLE IF EXISTS ONLY public.mst_industries DROP CONSTRAINT IF EXISTS "PK_mst_industries";
ALTER TABLE IF EXISTS ONLY public.mst_entra_roles DROP CONSTRAINT IF EXISTS "PK_mst_entra_roles";
ALTER TABLE IF EXISTS ONLY public.mst_designations DROP CONSTRAINT IF EXISTS "PK_mst_designations";
ALTER TABLE IF EXISTS ONLY public.mst_departments DROP CONSTRAINT IF EXISTS "PK_mst_departments";
ALTER TABLE IF EXISTS ONLY public.mst_countries DROP CONSTRAINT IF EXISTS "PK_mst_countries";
ALTER TABLE IF EXISTS ONLY public.mst_cities DROP CONSTRAINT IF EXISTS "PK_mst_cities";
ALTER TABLE IF EXISTS ONLY public.exited_employees DROP CONSTRAINT IF EXISTS "PK_exited_employees";
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS "PK_employees";
ALTER TABLE IF EXISTS ONLY public.clients DROP CONSTRAINT IF EXISTS "PK_clients";
ALTER TABLE IF EXISTS ONLY public.client_contacts DROP CONSTRAINT IF EXISTS "PK_client_contacts";
ALTER TABLE IF EXISTS ONLY public.client_assignments DROP CONSTRAINT IF EXISTS "PK_client_assignments";
ALTER TABLE IF EXISTS ONLY public."__EFMigrationsHistory" DROP CONSTRAINT IF EXISTS "PK___EFMigrationsHistory";
ALTER TABLE IF EXISTS public.employees DROP CONSTRAINT IF EXISTS "CK_employees_EmployeeCode_Format";
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.sub_ventures;
DROP TABLE IF EXISTS public.roles;
DROP TABLE IF EXISTS public.role_permission_audits;
DROP TABLE IF EXISTS public.repository_departments;
DROP TABLE IF EXISTS public.repository_activity_logs;
DROP TABLE IF EXISTS public.repository;
DROP TABLE IF EXISTS public.refresh_tokens;
DROP TABLE IF EXISTS public.mst_work_locations;
DROP TABLE IF EXISTS public.mst_salary_bands;
DROP TABLE IF EXISTS public.mst_roles;
DROP TABLE IF EXISTS public.mst_reporting_managers;
DROP TABLE IF EXISTS public.mst_offices;
DROP TABLE IF EXISTS public.mst_nationalities;
DROP TABLE IF EXISTS public.mst_industries;
DROP TABLE IF EXISTS public.mst_entra_roles;
DROP TABLE IF EXISTS public.mst_email_domains;
DROP TABLE IF EXISTS public.mst_designations;
DROP TABLE IF EXISTS public.mst_departments;
DROP TABLE IF EXISTS public.mst_countries;
DROP TABLE IF EXISTS public.mst_cities;
DROP TABLE IF EXISTS public.mst_business_units;
DROP TABLE IF EXISTS public.exited_employees;
DROP TABLE IF EXISTS public.employees;
DROP TABLE IF EXISTS public.clients;
DROP TABLE IF EXISTS public.client_contacts;
DROP TABLE IF EXISTS public.client_assignments;
DROP TABLE IF EXISTS public."__EFMigrationsHistory";
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
    "KycDocumentPath" character varying(500)
);


ALTER TABLE public.clients OWNER TO postgres;

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
    "EmergencyContactName" text
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
    "DeletedAtUtc" timestamp with time zone
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
    "PhoneCode" character varying(10) DEFAULT '+91'::character varying,
    "PhoneDigits" integer DEFAULT 10
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
    "DeletedAtUtc" timestamp with time zone
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
-- Name: mst_entra_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mst_entra_roles (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "EntraRoleValue" character varying(80) NOT NULL,
    "PulseRoleName" character varying(80) NOT NULL,
    "DisplayName" character varying(150) NOT NULL,
    "Description" character varying(500),
    "IsActive" boolean NOT NULL,
    "Priority" integer NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


ALTER TABLE public.mst_entra_roles OWNER TO postgres;

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
-- Name: repository_departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.repository_departments (
    "RepositoryItemId" uuid NOT NULL,
    "DepartmentId" uuid NOT NULL
);


ALTER TABLE public.repository_departments OWNER TO postgres;

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
20260831101559_AddCountryPhoneFields	10.0.4
20260831103000_AddMissingResourceCatalogAndRepository	10.0.4
20260831115855_AddMstEntraRoles	10.0.4
20260831133000_AddCountryPhoneFields	10.0.4
20260831150000_AddResourceCatalogTables	10.0.4
20260902100000_AddClientKycDocumentPath	10.0.4
20260902110000_AddSubVentureKycDocument	10.0.4
20260902180000_AddEmployeeCodeFormatCheck	10.0.4
20260903120000_AddRepositoryDepartments	10.0.4
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

COPY public.client_contacts ("Id", "ClientId", "SubVentureId", "Name", "Email", "Phone", "Designation", "ContactType", "IsPrimary", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
d5572af5-adde-4fd9-b14b-c857467d1c93	\N	37f0c3b1-16a1-4643-9f5a-f824204543c1	Sahil Lad	sahillad77@gmail.com	7854125698	ciso	Procurement	f	2026-08-19 06:43:26.584779+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8959a84a-a7cc-42be-ba71-c142d5dae1fa	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-08-19 07:09:05.853384+00	2026-08-20 10:21:44.183087+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 10:21:44.183087+00
26358579-8daf-4027-81c9-c375e8628aa3	\N	6a40584b-3bde-4c7d-a6e6-3ef920cd43d0	Sahil 	sahillad2092003@gmail.com	8744541212	spoc	Technical	f	2026-08-20 11:00:13.771971+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
77e4a9a2-d473-4007-be16-f9eebfb39df8	90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	\N	Sahil	sahillad2092003@gmail.com	8744541212	spoc	Technical	f	2026-08-20 11:00:13.771971+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0529bbe6-d5da-4295-9af6-a5d1fc964dc4	a04ccf3a-81c8-4416-8af7-068717ddb22b	\N	roshan jadhav	roshan.jadhav@gmail.com	7389247892	spoc	Accounts	f	2026-08-20 13:31:53.354468+00	2026-08-20 13:34:48.401428+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 13:34:48.401428+00
146500d9-5e28-4612-8053-9b883e7bfa73	\N	65c6925a-8948-4485-9d93-e596e1f4273e	roshan jadhav	roshan.jadhav@gmail.com	7389247892	spoc	Accounts	f	2026-08-20 13:31:53.354468+00	2026-08-20 13:34:48.401428+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 13:34:48.401428+00
5a47d941-02d2-4a03-a9fd-29a55f39f273	\N	65c6925a-8948-4485-9d93-e596e1f4273e	karan pawar	karan.pawar@gmail.com	5374903789	ciso	Technical	f	2026-08-20 13:31:53.354468+00	2026-08-20 13:34:48.401428+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 13:34:48.401428+00
5e72a713-46c0-47c8-b777-f61ecf2a858e	a04ccf3a-81c8-4416-8af7-068717ddb22b	\N	karan pawar	karan.pawar@gmail.com	5374903789	ciso	Technical	f	2026-08-20 13:31:53.354468+00	2026-08-20 13:34:48.401428+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 13:34:48.401428+00
03f15020-3812-47c9-97a4-3ed02203ca0a	\N	65c6925a-8948-4485-9d93-e596e1f4273e	karan pawar	karan.pawar@gmail.com	5374903789	ciso	Technical	f	2026-08-20 13:34:48.407968+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
251274f1-0037-4f3c-8d67-44d1e46981fa	\N	65c6925a-8948-4485-9d93-e596e1f4273e	roshan jadhav	roshan.jadhav@gmail.com	7389247892	spoc	Accounts	f	2026-08-20 13:34:48.407968+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3865019e-696f-4b90-9347-8cd7ef76d999	\N	d3af0a54-b527-40ca-ac1e-9fb09fd81504	harshada	harshada@tk.com	4373947849	ciso	Technical	f	2026-08-20 13:34:48.407968+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e6e01a67-c99e-4ed7-87a0-92e5a498d8ab	\N	d3af0a54-b527-40ca-ac1e-9fb09fd81504	muskan	muskan@tk.com	4356789038	spoc	Procurement	f	2026-08-20 13:34:48.407968+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
855194e2-92d8-4bd8-a850-110fa9ce4776	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-08-20 10:21:44.192431+00	2026-08-21 10:05:12.70694+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-21 10:05:12.70694+00
873fac91-16b6-421c-bd45-3cd92e2dc931	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-08-20 10:21:44.192431+00	2026-08-21 10:05:12.70694+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-21 10:05:12.70694+00
e90e0928-dbe2-47eb-b92d-3835423c1163	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-08-20 10:21:44.192431+00	2026-08-21 10:05:12.70694+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-21 10:05:12.70694+00
00331436-e85a-4899-8929-daf84f77440f	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-08-21 10:05:12.720669+00	2026-08-27 09:26:47.61284+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-27 09:26:47.61284+00
10f3620f-44d6-44a2-a90d-cbeb6ea0851a	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-08-21 10:05:12.720669+00	2026-08-27 09:26:47.61284+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-27 09:26:47.61284+00
327f81c4-11e3-40bd-a73c-f5c9dfe06147	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-08-21 10:05:12.720669+00	2026-08-27 09:26:47.61284+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-27 09:26:47.61284+00
d8e9f1ce-ac14-4a5a-899a-5d87963e99d2	\N	a69fe228-de12-44e5-9128-dc3898f67e5c	omkar	omkar@talakunchi.com	9877987899	SPOC	Accounts	f	2026-08-21 10:05:12.720669+00	2026-08-27 09:26:47.61284+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-27 09:26:47.61284+00
86650066-2b7a-4e3e-881f-d34464ffbfe4	89714d99-8107-4cd0-8095-6da7823cb767	\N	Harshada Tawde	harshada.tawde@gmail.com	7977953150	spoc	Accounts	f	2026-09-02 07:09:24.021663+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ab3333bb-387c-4753-b5a7-8482870ac7b4	\N	4af18ff4-3a01-44e4-b050-9e209643182b	Harshada Tawde	harshada.tawde@gmail.com	7977953150	spoc	Accounts	f	2026-09-02 07:09:24.021663+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
468e13c4-5890-4d09-9c7e-8d9f8e64fa6c	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-08-27 09:26:47.624022+00	2026-09-02 10:24:57.106056+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:24:57.106056+00
8cbfb851-12ca-4f1d-860e-7203c456f09b	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-08-27 09:26:47.624022+00	2026-09-02 10:24:57.106056+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:24:57.106056+00
93c4a9b8-9f1f-4a47-8008-d3fe3c62e4e8	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-08-27 09:26:47.624022+00	2026-09-02 10:24:57.106056+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:24:57.106056+00
9aab6b74-446e-4a4c-8be1-75cc41421933	\N	a2e2e7fc-4e12-4bd6-85b4-baffcd70c1f3	sdsad	madhurigaikwad2310@gmail.com	7621423213	spoc	Technical	f	2026-08-27 09:26:47.624022+00	2026-09-02 10:24:57.106056+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:24:57.106056+00
d1c44f67-bc98-400a-a7c5-be6e22460ec7	\N	a69fe228-de12-44e5-9128-dc3898f67e5c	omkar	omkar@talakunchi.com	9877987899	SPOC	Accounts	f	2026-08-27 09:26:47.624022+00	2026-09-02 10:24:57.106056+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:24:57.106056+00
51287b93-db6b-4ef3-8d7d-a8c76abb0a7a	\N	a2e2e7fc-4e12-4bd6-85b4-baffcd70c1f3	sdsad	madhurigaikwad2310@gmail.com	7621423213	spoc	Technical	f	2026-09-02 10:24:57.125156+00	2026-09-02 11:47:36.637907+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 11:47:36.637907+00
8c6336ae-2f73-470c-b467-d5fb3702823f	\N	a69fe228-de12-44e5-9128-dc3898f67e5c	omkar	omkar@talakunchi.com	9877987899	SPOC	Accounts	f	2026-09-02 10:24:57.125156+00	2026-09-02 11:47:36.637907+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 11:47:36.637907+00
9b41ef4d-51f8-458e-ad8b-b3cbe04425e4	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-09-02 10:24:57.125156+00	2026-09-02 11:47:36.637907+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 11:47:36.637907+00
e494d57c-f7c9-46e6-80bc-6d0739ce62a1	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-09-02 10:24:57.125156+00	2026-09-02 11:47:36.637907+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 11:47:36.637907+00
eae43466-9d9d-412a-803f-e781907279d1	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-09-02 10:24:57.125156+00	2026-09-02 11:47:36.637907+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 11:47:36.637907+00
f935ec18-20f7-4c73-9e2a-d2fb29df5848	\N	3a681001-620a-4190-bd6c-1ee7131f2c3f	Sahil Lad	sahillad77@gmail.com	7821093801	spoc	Procurement	f	2026-09-02 10:24:57.125156+00	2026-09-02 11:47:36.637907+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 11:47:36.637907+00
07fc7aba-592c-4573-99a5-9b7c0298ab77	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
49207f1d-d605-4315-ba69-e3450e771172	\N	6cec1e8f-a65e-4c11-8fc3-265376ffe0cc	Sahil Lad	sahillad77@gmail.com	7854125698	spoc	Accounts	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4e6eb452-29f7-4331-b8ec-2b8e84bd24b2	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6dd8073f-86fb-4519-b19a-bbdea9480c9a	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
95681d26-9084-44f9-9d3b-c4be5e7fe351	\N	a69fe228-de12-44e5-9128-dc3898f67e5c	omkar	omkar@talakunchi.com	9877987899	SPOC	Accounts	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9f43aded-feb0-48a7-918c-c29e9b567495	\N	a2e2e7fc-4e12-4bd6-85b4-baffcd70c1f3	sdsad	madhurigaikwad2310@gmail.com	7621423213	spoc	Technical	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c00c4740-2af2-4fed-959f-23e9376d74b0	\N	3a681001-620a-4190-bd6c-1ee7131f2c3f	Sahil Lad	sahillad77@gmail.com	7821093801	spoc	Procurement	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clients ("Id", "Name", "Industry", "Logo", "ContactEmail", "ClientType", "Status", "EngagementManager", "ContactName", "ContactPhone", "ContactDesignation", "ContactType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BusinessType", "City", "Country", "KycDocumentName", "Notes", "EngagementManagerId", "IndustryId", "CityId", "CountryId", "CustomerSince", "SalesManager", "SalesManagerId", "KycDocumentPath") FROM stdin;
06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Pharma	Healthcare	HP	it@helix.com	Old	Active	Pradeep Singh	Sanjay Sen	+91 98765 43211	Procurement Head	Procurement	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07	\N	\N	\N
a04ccf3a-81c8-4416-8af7-068717ddb22b	Morphle	Banking	M	roshan.jadhav@gmail.com	New	Active	Pradeep Singh	roshan jadhav	7389247892	spoc	Accounts	2026-08-20 13:31:53.288995+00	2026-08-21 12:28:26.459736+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	Kalyan-Dombivli	India	API Gateway Configuration Guide (1).txt	no comments	8a50b4b9-7091-423c-ac8c-af55bc6df348	4a80bfdb-a191-4ce1-ab51-2142eb366db7	4d396fc0-ae55-4eeb-b2db-79bbb757d3cd	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20	\N	\N	\N
a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync AI	Technology	CA	contact@cloudsync.com	New	Active	Riya Kapoor	Neha Gupta	+91 98765 43215	IT Lead	Technical SPOC	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	02012f0c-97b2-4aea-a6b4-954ee97d892d	\N	\N	2026-08-07	\N	\N	\N
a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Plus	Healthcare	MP	tech@medicareplus.com	New	Active	Pradeep Singh	Priyanka Joshi	+91 98765 43217	Procurement Mgr	Procurement	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07	\N	\N	\N
428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Logistics	Logistics	ZL	pm@zenith.com	New	Active	Rahul Sharma	Vikram Malhotra	+91 98765 43213	Legal Counsel	Legal	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f175fde9-14f8-40e8-b564-47d8a29d84ff	\N	\N	2026-08-07	\N	\N	\N
9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Bank	Banking	NB	ops@northwind.com	Old	Active	Rahul Sharma	Rahul Sharma	+91 98765 43210	IT Manager	Technical SPOC	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4a80bfdb-a191-4ce1-ab51-2142eb366db7	\N	\N	2026-08-07	\N	\N	\N
47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Energy	Energy	LE	digital@lumen.com	Old	Active	Pradeep Singh	Arjun Mehta	+91 98765 43214	Operations Manager	Technical SPOC	2026-08-07 07:49:59.669429+00	2026-08-21 12:28:40.3605+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	8a50b4b9-7091-423c-ac8c-af55bc6df348	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-07	\N	\N	\N
fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Global	Finance	FG	dev@fintechglobal.com	Old	Active	Rahul Sharma	Siddharth Shah	+91 98765 43216	Finance VP	Accounts	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	cd116cba-a939-4cb7-bd0f-233019a005b0	\N	\N	2026-08-07	\N	\N	\N
f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Retail	Retail	OR	tech@orbit.com	Old	Active	Riya Kapoor	Aditi Rao	+91 98765 43212	CFO	Accounts	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	935db8d7-e2aa-417e-839e-b51d00ce951e	\N	\N	2026-08-07	\N	\N	\N
f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Solutions	Environment	ES	projects@ecogreen.com	Old	Active	Riya Kapoor	Rohan Varma	+91 98765 43218	Legal Head	Legal	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16ebeb23-b3d8-4fb7-a4f6-789510c28ad3	\N	\N	2026-08-07	\N	\N	\N
90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	TATA	Energy	T	sahillad2092003@gmail.com	New	Active	Pradeep Singh	Sahil	8744541212	spoc	Technical	2026-08-20 11:00:13.739957+00	2026-08-21 09:02:02.864281+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	mumbai	India	exit-summary (1).csv	kldfslkdfsdlf	8a50b4b9-7091-423c-ac8c-af55bc6df348	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-20	\N	\N	\N
14db9d14-dec6-4488-a6ae-d9bab5b2ef48	Test Sales Customer	Technology	TS	\N	New	Active	Riya Kapoor	\N	\N	\N	\N	2026-08-28 05:20:20.174418+00	2026-08-28 05:20:30.886324+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-28 05:20:30.886324+00	\N	Bengaluru	India	\N	\N	dd7a3258-31be-425c-8771-cab8ba8b1b22	02012f0c-97b2-4aea-a6b4-954ee97d892d	d76207a2-8c4c-4352-acb7-67f098fb08c4	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-28	Vikram Sharma	\N	\N
89714d99-8107-4cd0-8095-6da7823cb767	cust test	Banking	CT	harshada.tawde@gmail.com	New	Active	riya kapoor	Harshada Tawde	7977953150	spoc	Accounts	2026-09-02 07:09:23.899459+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Mumbai	India	Details for PMS.xlsx	\N	dd7a3258-31be-425c-8771-cab8ba8b1b22	4a80bfdb-a191-4ce1-ab51-2142eb366db7	6ffbb80b-985d-4f00-9140-db22f39a625d	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-09-02	\N	\N	\N
ccc4f266-8e68-4b62-9967-04ddacc9113c	SM Test Client	Technology	ST	smtest@example.com	New	Active	Riya Kapoor	Test	\N	\N	\N	2026-09-02 07:48:11.711029+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Mumbai	India	\N	\N	dd7a3258-31be-425c-8771-cab8ba8b1b22	02012f0c-97b2-4aea-a6b4-954ee97d892d	6ffbb80b-985d-4f00-9140-db22f39a625d	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-09-02	John Smith	\N	\N
08f36c9b-9833-4008-9a58-9b69b5c491e3	Onboard SM Fix Test	Technology	OS	smfix@example.com	New	Active	Riya Kapoor	Test	\N	\N	\N	2026-09-02 07:54:30.517916+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Mumbai	India	\N	\N	dd7a3258-31be-425c-8771-cab8ba8b1b22	02012f0c-97b2-4aea-a6b4-954ee97d892d	6ffbb80b-985d-4f00-9140-db22f39a625d	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-09-02	Priya Shah	1a350645-f31a-4309-8441-d37f39e31fe5	\N
c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Systems	Automotive	AS	engineering@autodrive.com	Old	Active	Arjun Mehta	Kabir Sen	+91 98765 43219	Engineering SPOC	Technical SPOC	2026-08-07 07:49:59.669429+00	2026-09-02 10:24:57.074997+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	230058bf-ed8a-45da-8d77-4a2821a0a76a	4bf54de4-0e85-4904-a89f-542301b65077	\N	\N	2026-08-07	Manohar Lad	\N	\N
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees ("Id", "EmployeeCode", "FirstName", "LastName", "WorkEmail", "PersonalEmail", "Phone", "AltPhone", "Gender", "DateOfBirth", "Address", "EmergencyContact", "MaritalStatus", "Nationality", "DepartmentId", "DesignationId", "Role", "ReportingManagerId", "BusinessUnit", "WorkLocation", "OfficeBranch", "Category", "Team", "ProjectSite", "JoiningDate", "Status", "ConfirmationStatus", "ProbationStatus", "Experience", "PreviousCompany", "EmploymentType", "ContractType", "BondStatus", "NoticePeriod", "AssetId", "ExitType", "ExitReason", "Education", "Skills", "Certifications", "Languages", "KpiScore", "QuarterlyKpi", "AnnualRating", "GoalCompletion", "Attendance", "ReportingEfficiency", "PromotionReadiness", "ManagerFeedback", "Pan", "BankAccount", "SalaryBand", "PfUan", "TaxRegime", "ComplianceStatus", "UserId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "JobRoleId", "NationalityId", "ProbationPeriod", "SalaryBandId", "Aadhaar", "EmergencyContactName") FROM stdin;
c5d5234b-6151-4e42-abd3-0d91dd38754b	TK-0016	Meera	Nambiar	meera.nambiar@acme.co	meera1015@gmail.com	9876501015	9866501015	Female	1996-03-15	135, Andheri Office	9811101015	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	1e7faab8-273d-40df-9f9a-485160186c5a	GRC Auditor - I	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2021-03-10	Active	Active	Completed	6 years	Infosys	Full-time	Permanent	No	60 days	TK-4015	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Product"]	["NA"]	["English", "Hindi"]	84	82	5	89	95	94	Ready in 1 year	Solid contributor on current assignments.	ABCDE1249F	501234567815	L4	100112345015	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-20 06:35:44.26208+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 06:35:44.26208+00	\N	\N	\N	\N	\N	\N
eb10f37d-b64f-4b17-976b-b962645514f2	TK-0029	Priya	Shah	priya.shah.839199831f3541eda878b9f48a7f9743@acme.co	\N	\N	\N	Female	1994-03-12	Andheri East, Mumbai	9876543210	Married	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	Senior Pentester - I	\N	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	\N	\N	Offsite	\N	Active	\N	6 months	5 years	Acme	Full-time	Permanent	No	\N	TK-4029	NA	NA	B.Tech	["React", "Mentoring"]	["AWS"]	["English", "Hindi"]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	L2	\N	\N	\N	\N	2026-08-21 05:21:39.645179+00	2026-08-22 05:27:05.457481+00	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	ebed343e-301f-4984-b292-fa8d1cb1623c	\N	\N
3dcb0f17-b94a-470c-ba85-86ac0f1c65c8	TK-0014	Kavya	Desai	kavya.desai@acme.co	kavya1013@gmail.com	9876501013	9866501013	Female	1994-01-13	133, Andheri Office	9811101013	Married	Indian	898c36e9-1cb7-4c56-9148-a3b6893c0149	3356f353-1566-4df6-9958-fa01d67d13c7	Python Developer - II	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Onsite	2019-01-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4013	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Marketing"]	["NA"]	["English", "Hindi"]	82	80	3	87	93	92	Ready Now	Solid contributor on current assignments.	ABCDE1247F	501234567813	L4	100112345013	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890013	\N
eb50369d-e526-459c-bb6c-aa3a85b231db	TKI-0001	Integration	Resource	integration.resource.c92dd5fc2d1c4c4fa7401c33cac1e6fe@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	f8502c44-b289-49e4-8401-3dcad4d5bbe0	Intern	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	\N	2019-01-10	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Integration test	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 12:25:03.82285+00	2026-09-02 12:35:16.109916+00	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	\N	\N	\N	\N	234567890025	\N
498bb0ed-62ca-4e56-bcb3-4cbd356077be	TK-0003	Rohan	Mehta	rohan.mehta@acme.co	rohan1002@gmail.com	9876501002	9866501002	Male	1991-02-02	122, Dombivali Office	9811101002	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	35a6b1af-dc78-4632-a9f4-eedabdbdcb52	DevSecOps Practitioner - II	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2020-02-10	Notice Period	Active	Completed	3 years	TCS	Full-time	Permanent	No	60 days	TK-4002	Resign	bo	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	71	69	4	76	91	81	Ready in 1 year	Solid contributor on current assignments.	ABCDE1236F	501234567802	L5	100112345002	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890002	\N
58198691-3595-4565-8ba6-d5f150240aa3	TK-0015	Arjun	Shah	arjun.shah@acme.co	arjun1014@gmail.com	9876501014	9866501014	Male	1995-02-14	134, Dombivali Office	9811101014	Single	Indian	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	c70b9832-841e-4864-9b85-eaba3c0a995f	Desktop Support Engineer - I	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2020-02-10	Active	Active	Completed	5 years	TCS	Full-time	Permanent	No	90 days	TK-4014	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	83	81	4	88	94	93	Ready in 1 year	Solid contributor on current assignments.	ABCDE1248F	501234567814	L4	100112345014	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890014	\N
c15b2b43-0884-4999-bece-9289d1db561f	TK-0017	Vikram	Gupta	vikram.gupta@acme.co	vikram1016@gmail.com	9876501016	9866501016	Male	1997-04-16	136, Dombivali Office	9811101016	Married	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	Senior PMO - I	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Bond	\N	Onsite	2022-04-10	Active	Active	Completed	7 years	TCS	Full-time	Permanent	Yes ??? 2 years	90 days	TK-4016	NA	NA	MCA	["Communication", "Delivery", "Operations"]	["NA"]	["English", "Hindi"]	85	83	3	90	96	80	Ready in 1 year	Solid contributor on current assignments.	ABCDE1250F	501234567816	L4	100112345016	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890016	\N
9e1b1aa9-fcd3-47be-b264-53806520c9fc	TK-0019	Aditya	Reddy	aditya.reddy@acme.co	aditya1018@gmail.com	9876501018	9866501018	Male	1991-06-18	138, Dombivali Office	9811101018	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	6d25ff6d-e13d-440f-b775-215547af7acb	SOC Analyst - I	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2024-06-10	Active	Active	Completed	9 years	TCS	Full-time	Permanent	No	90 days	TK-4018	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	87	85	5	92	98	82	Ready in 1 year	Solid contributor on current assignments.	ABCDE1252F	501234567818	L4	100112345018	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-20 06:10:09.305181+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 06:10:09.305181+00	\N	\N	\N	\N	\N	\N
593b0378-d20a-40ee-b0a0-ae4acc0a78aa	TK-0010	Aanya	Joshi	aanya.joshi@acme.co	aanya1009@gmail.com	9876501009	9866501009	Female	1990-09-09	129, Andheri Office	9811101009	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	b2b687ef-fd62-4cb7-a826-b40a35da7b2c	Business Development Associate - I	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2021-09-10	Active	Active	Completed	10 years	Infosys	Full-time	Permanent	No	60 days	TK-4009	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Sales"]	["NA"]	["English", "Hindi"]	78	76	5	83	98	88	Ready Now	Solid contributor on current assignments.	ABCDE1243F	501234567809	L4	100112345009	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890009	\N
81c42f4c-b588-4037-a106-47f339a777f6	TK-0020	Pooja	Menon	pooja.menon@acme.co	pooja1019@gmail.com	9876501019	9866501019	Female	1992-07-19	139, Andheri Office	9811101019	Married	Indian	310a2f16-15f6-4b82-95f6-ab18b5b429f5	485012d4-2c28-4bc4-92c7-3609e3e3749e	Senior HR Executive - I	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Onsite	2019-07-10	Active	Active	Completed	10 years	Infosys	Full-time	Permanent	No	60 days	TK-4019	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Human Resources"]	["NA"]	["English", "Hindi"]	88	86	3	93	90	83	Ready in 1 year	Solid contributor on current assignments.	ABCDE1253F	501234567819	L4	100112345019	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890019	\N
a165f6aa-148a-4ad0-953a-f154ae0991c8	TK-0027	Integration	Resource	integration.resource.e531fb2cecab4c6caa485682aeaa36eb@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	ae255622-ddcc-45ea-a699-8ec416fe57ab	DevSecOps Practitioner - I	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	\N	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Notice already ended	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 12:25:04.462343+00	2026-08-20 12:25:04.510288+00	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	2026-08-20 12:25:04.510288+00	\N	\N	\N	\N	\N	\N
7c9168b9-8269-430b-89d8-a1ba0b8e99af	TK-0018	Ishita	Bansal	ishita.bansal@acme.co	ishita1017@gmail.com	9876501017	9866501017	Female	1990-05-17	137, Andheri Office	9811101017	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	PenTester - I	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2023-05-10	Active	Active	Completed	8 years	Infosys	Full-time	Permanent	No	60 days	TK-4017	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Design"]	["NA"]	["English", "Hindi"]	86	84	4	91	97	81	Ready Now	Solid contributor on current assignments.	ABCDE1251F	501234567817	L4	100112345017	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890017	\N
8065ff15-64d6-4f36-a003-f0444a620bd8	TK-0021	Nikhil	Khanna	nikhil.khanna@acme.co	nikhil1020@gmail.com	9876501020	9866501020	Male	1993-08-20	140, Dombivali Office	9811101020	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	e2c675a7-92dc-4477-be75-9a304cbe4def	Sales Associate	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2020-08-10	Active	Active	Completed	11 years	TCS	Full-time	Permanent	No	90 days	TK-4020	NA	NA	MCA	["Communication", "Delivery", "Sales"]	["NA"]	["English", "Hindi"]	89	87	4	94	91	84	Ready in 1 year	Solid contributor on current assignments.	ABCDE1254F	501234567820	L4	100112345020	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890020	\N
f7404cb8-5d1a-40bf-b690-22cf179320dd	TK-0009	Samar	Patel	samar.patel@acme.co	samar1008@gmail.com	9876501008	9866501008	Male	1997-08-08	128, Dombivali Office	9811101008	Single	Indian	310a2f16-15f6-4b82-95f6-ab18b5b429f5	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	HR Head	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2020-08-10	Active	Active	Completed	9 years	TCS	Full-time	Permanent	No	90 days	TK-4008	NA	NA	MCA	["Communication", "Delivery", "Human Resources"]	["NA"]	["English", "Hindi"]	77	75	4	82	97	87	Ready in 1 year	Solid contributor on current assignments.	ABCDE1242F	501234567808	L4	100112345008	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890008	\N
8e97c526-8c79-44c6-a23f-ece0d9b21df5	TK-0004	Sneha	Iyer	sneha.iyer@acme.co	sneha1003@gmail.com	9876501003	9866501003	Female	1992-03-03	123, Andheri Office	9811101003	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b5f39dd8-c305-489d-9f7d-9adfd010a134	SOC Lead - I	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2021-03-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4003	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	72	70	5	77	92	82	Ready in 1 year	Solid contributor on current assignments.	ABCDE1237F	501234567803	L5	100112345003	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890003	\N
fc06e810-3e2d-4510-bfc1-669ccf579da2	TK-0007	Ankit	Verma	ankit.verma@acme.co	ankit1006@gmail.com	9876501006	9866501006	Male	1995-06-06	126, Dombivali Office	9811101006	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	4650d4e0-f73c-4688-ae5f-830a46348ff9	SIEM Admin - II	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Bond	\N	Offsite	2024-06-10	Active	Active	Completed	7 years	TCS	Full-time	Permanent	Yes ??? 2 years	90 days	TK-4006	NA	NA	MCA	["Communication", "Delivery", "Design"]	["NA"]	["English", "Hindi"]	75	73	5	80	95	85	Ready in 1 year	Solid contributor on current assignments.	ABCDE1240F	501234567806	L4	100112345006	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890006	\N
18b83048-56d5-4365-8bc5-3ba65405467e	TK-0011	Harsh	Nair	harsh.nair@acme.co	harsh1010@gmail.com	9876501010	9866501010	Male	1991-10-10	130, Dombivali Office	9811101010	Married	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	b3309eea-7374-4a8d-ac13-481b2a7fd492	Associate PMO - I	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Onsite	2022-10-10	Active	Active	Completed	11 years	TCS	Full-time	Permanent	No	90 days	TK-4010	NA	NA	MCA	["Communication", "Delivery", "Operations"]	["NA"]	["English", "Hindi"]	79	77	3	84	90	89	Ready in 1 year	Solid contributor on current assignments.	ABCDE1244F	501234567810	L4	100112345010	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890010	\N
f8258beb-f446-477d-bb7e-69666c5fe314	TK-0013	Yash	Malik	yash.malik@acme.co	yash1012@gmail.com	9876501012	9866501012	Male	1993-12-12	132, Dombivali Office	9811101012	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	Red Team Practitioner - II	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2024-12-10	Active	Active	Completed	3 years	TCS	Full-time	Permanent	No	90 days	TK-4012	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	81	79	5	86	92	91	Ready in 1 year	Solid contributor on current assignments.	ABCDE1246F	501234567812	L4	100112345012	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890012	\N
080045f2-3ff3-49af-bced-4b10ea1dde6f	TK-0028	Integration	Resource	integration.resource.ce5bcae27dbc41978b56226b5bf1debf@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea315f7d-d597-41b3-a999-4f3851bcd020	SIEM Admin - I	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Integration test	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 12:51:17.146104+00	2026-08-22 05:27:05.457481+00	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	\N	\N	\N	\N	\N	\N
230058bf-ed8a-45da-8d77-4a2821a0a76a	TK-0025	Arjun	Mehta	arjun.mehta@acme.co	arjun1024@gmail.com	9876501024	9866501024	Male	1997-12-24	144, Dombivali Office	9811101024	Single	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	4ef3d669-21ca-43ab-a132-db6b00c6063f	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Offsite	2024-12-10	Active	Active	Completed	5 years	TCS	Full-time	Permanent	No	90 days	TK-4024	NA	NA	MCA	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	93	71	5	78	95	88	Ready in 1 year	Solid contributor on current assignments.	ABCDE1258F	501234567824	L4	100112345024	Old Regime	Compliant	\N	2026-08-21 08:28:23.134157+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N	234567890024	\N
dd7a3258-31be-425c-8771-cab8ba8b1b22	TK-0022	Riya	Kapoor	riya.kapoor@acme.co	riya1021@gmail.com	9876501021	9866501021	Female	1994-09-21	141, Andheri Office	9811101021	Single	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	4ef3d669-21ca-43ab-a132-db6b00c6063f	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	Offsite	2021-09-10	Active	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes ??? 2 years	60 days	TK-4021	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	90	68	5	75	92	85	Ready Now	Solid contributor on current assignments.	ABCDE1255F	501234567821	L4	100112345021	New Regime	Compliant	\N	2026-08-21 08:28:23.134157+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N	234567890021	\N
b78530f0-0687-4f26-a614-8318c62901f9	TK-0026	Pranjali	Shah	pranjali@talakunchi.io	pranjali@gmail.com	8894344343	9827327263	\N	\N	\N	\N	\N	India	898c36e9-1cb7-4c56-9148-a3b6893c0149	f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	Python Developer - I	2446deb8-f6cc-4ee1-b179-599d0a2e357a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2026-08-12	Active	Active	\N	\N	\N	\N	\N	\N	\N	\N	NA	NA	\N	[]	[]	[]	0	0	0	0	0	0	\N	\N	WASDE2324H	3246572827344	\N	973456234651	\N	Pending	\N	2026-08-20 10:39:23.376516+00	2026-08-22 05:27:05.457481+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	\N	\N
8a50b4b9-7091-423c-ac8c-af55bc6df348	TK-0024	Pradeep	Singh	pradeep.singh@acme.co	pradeep1023@gmail.com	9876501023	9866501023	Male	1996-11-23	143, Andheri Office	9811101023	Single	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	4ef3d669-21ca-43ab-a132-db6b00c6063f	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2023-11-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4023	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	92	70	4	77	94	87	Ready in 1 year	Solid contributor on current assignments.	ABCDE1257F	501234567823	L4	100112345023	New Regime	Compliant	\N	2026-08-21 08:28:23.134157+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N	234567890023	\N
2446deb8-f6cc-4ee1-b179-599d0a2e357a	TK-0002	Priya	Sharma	priya.sharma@acme.co	priya1001@gmail.com	9876501001	9866501001	Female	1990-01-01	121, Andheri Office	9811101001	Married	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	PenTester - II	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	Onsite	2019-01-10	Notice Period	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes ??? 2 years	60 days	TK-4001	Resign	bo	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	70	68	3	75	90	80	Ready Now	Solid contributor on current assignments.	ABCDE1235F	501234567801	L5	100112345001	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-01 05:48:06.052215+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-01 05:48:06.052215+00	\N	\N	\N	\N	234567890001	\N
a586e15e-0ad4-4d33-aa18-b1edcf241baf	TK-0006	Divya	Rao	divya.rao@acme.co	divya1005@gmail.com	9876501005	9866501005	Female	1994-05-05	125, Andheri Office	9811101005	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	Associate Project Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Offsite	2023-05-10	Active	Active	Completed	6 years	Infosys	Full-time	Permanent	No	60 days	TK-4005	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Product"]	["NA"]	["English", "Hindi"]	74	72	4	79	94	84	Ready Now	Solid contributor on current assignments.	ABCDE1239F	501234567805	L4	100112345005	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890005	\N
929d4a75-9232-4ce7-a1a6-8f107ccca1e7	TK-0008	Neha	Kulkarni	neha.kulkarni@acme.co	neha1007@gmail.com	9876501007	9866501007	Female	1996-07-07	127, Andheri Office	9811101007	Married	Indian	bcbd68c8-c3f3-4396-abb0-0b0e13637958	4ef1cb5b-9688-4ce2-95b3-6a0863200166	Senior Accountant - I	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	Onsite	2019-07-10	Active	Active	Completed	8 years	Infosys	Full-time	Permanent	No	60 days	TK-4007	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Finance"]	["NA"]	["English", "Hindi"]	76	74	3	81	96	86	Ready in 1 year	Solid contributor on current assignments.	ABCDE1241F	501234567807	L4	100112345007	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890007	\N
9a15533f-f863-44a7-b61c-b978fa1f5174	TK-0023	Rahul	Sharma	rahul.sharma@acme.co	rahul1022@gmail.com	9876501022	9866501022	Male	1995-10-22	142, Dombivali Office	9811101022	Married	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	4ef3d669-21ca-43ab-a132-db6b00c6063f	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Onsite	2022-10-10	Active	Active	Completed	3 years	TCS	Full-time	Permanent	No	90 days	TK-4022	NA	NA	MCA	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	91	69	3	76	93	86	Ready in 1 year	Solid contributor on current assignments.	ABCDE1256F	501234567822	L4	100112345022	Old Regime	Compliant	\N	2026-08-21 08:28:23.134157+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N	234567890022	\N
96425efc-9b0e-4f2b-8fd6-ec3b77161547	TK-0001	Dhanshree	Pansare	dhanshree.pansare@gmail.com	dhanshree.pansare002@gmail.com	9326178048	7900141424	Female	2002-11-02	31,kranti society,bhandup east 400042	9324567803	Single	Indian	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	778f1120-9633-4933-9160-ddaa46668838	Director and Chief Executive Officer	498bb0ed-62ca-4e56-bcb3-4cbd356077be	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Bond	\N	Onsite	2026-08-28	Notice Period	Active - Probation	On Probation (6 months)	7 years	tcs	Full-time	Permanent	Yes	90 days	TK-566	Resign	bo	Bachlore enginering	["python", "testing"]	["AWS", "Pen tester"]	["hindi", "engish"]	0	0	0	0	0	0	\N	\N	WASDE2324H	3246572827344	L4	973456234651	\N	Pending	\N	2026-08-20 13:43:06.225084+00	2026-08-22 05:27:05.457481+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	\N	\N
df465de2-4aba-41d3-a2a3-1e81ca66e34a	TK-0005	Karthik	Bose	karthik.bose@acme.co	karthik1004@gmail.com	9876501004	9866501004	Male	1993-04-04	124, Dombivali Office	9811101004	Married	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	48429bb5-c583-4684-b30a-7ed443b671ca	SOC Analyst - II	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent - Without Bond	\N	Onsite	2022-04-10	Notice Period	Active	Completed	5 years	TCS	Full-time	Permanent	No	60 days	TK-4004	Resign	Better Opportunity	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	73	71	3	78	93	83	Ready in 1 year	Solid contributor on current assignments.	ABCDE1238F	501234567804	L5	100112345004	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890004	\N
d24cafbe-bb30-4522-93b2-25588511f0e2	TK-0012	Ira	Kapoor	ira.kapoor@acme.co	ira1011@gmail.com	9876501011	9866501011	Female	1992-11-11	131, Andheri Office	9811101011	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	GRC Auditor - II	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	Offsite	2023-11-10	Active	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes ??? 2 years	60 days	TK-4011	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	80	78	4	85	91	90	Ready in 1 year	Solid contributor on current assignments.	ABCDE1245F	501234567811	L4	100112345011	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-09-02 10:31:01.756464+00	\N	\N	\N	\N	\N	\N	\N	234567890011	\N
d9903fec-2d9e-4544-ad6a-170173d41c17	TKI-0002	Sample	Employee	sample.employee@talakunchi.com	sample.personal@gmail.com	9999911111	\N	Female	1995-06-15	Andheri East, Mumbai	9876543210	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	Intern	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	\N	2026-08-27	Active	Active	\N	4 years	\N	Full-Time	\N	\N	\N	\N	NA	NA	\N	["C#", "React"]	[]	["English", "Hindi"]	\N	\N	\N	\N	\N	\N	\N	\N	AAAAA9999A	501234567890	L2	100987654321	\N	\N	\N	2026-08-28 08:20:17.296775+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567890124	\N
649f4c6f-8719-4ff4-8969-7a55a16e43bd	TK-0030	Integration	Resource	integration.resource.55c6d73ab436476db67f6f1b9df80d8a@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	8dc0d8fe-593d-422a-8b27-5b68fbe6d224	Accountant - II	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	\N	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Notice already ended	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 12:51:19.436175+00	2026-08-20 12:51:19.547505+00	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	2026-08-20 12:51:19.547505+00	\N	\N	\N	\N	\N	\N
1a350645-f31a-4309-8441-d37f39e31fe5	TK-0031	Priya	Shah	priya.shah.0191472791bb4c5593e44681a270b32a@acme.co	\N	\N	\N	Female	1994-03-12	Andheri East, Mumbai	9876543210	Married	Indian	898c36e9-1cb7-4c56-9148-a3b6893c0149	9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	Python Developer - III	\N	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	\N	\N	Offsite	\N	Active	\N	6 months	5 years	Acme	Full-time	Permanent	No	\N	TK-4029	NA	NA	B.Tech	["React", "Mentoring"]	["AWS"]	["English", "Hindi"]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	L2	\N	\N	\N	\N	2026-08-20 13:08:53.427831+00	2026-08-22 05:27:05.457481+00	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	ebed343e-301f-4984-b292-fa8d1cb1623c	\N	\N
\.


--
-- Data for Name: exited_employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exited_employees ("Id", "OriginalEmployeeId", "EmployeeCode", "FullName", "DepartmentName", "DesignationName", "WorkEmail", "PersonalEmail", "Phone", "StatusAtExit", "ExitType", "ExitReason", "ResignationDate", "LastWorkingDay", "ReasonForLeaving", "NoticePeriodServed", "ExitChecklistJson", "AssetReturnJson", "FinalSettlementJson", "ExitedAtUtc", "ExitedBy", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
6b3e85ba-b66a-4ee2-a56c-763dadac0945	9e1b1aa9-fcd3-47be-b264-53806520c9fc	EMP-1018	Aditya Reddy	Engineering	Senior Software Engineer	aditya.reddy@acme.co	aditya1018@gmail.com	9876501018	Active	Resign	Better opp	2026-08-20	2026-09-23	Better opp	60 days	\N	\N	\N	2026-08-20 06:10:09.268914+00	\N	2026-08-20 06:10:09.305181+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4b351675-a78a-493e-a0fb-464c1180e0d6	c5d5234b-6151-4e42-abd3-0d91dd38754b	EMP-1015	Meera Nambiar	Product	Business Analyst	meera.nambiar@acme.co	meera1015@gmail.com	9876501015	Active	Resign	better opp	2026-08-20	2026-08-31	better opp	60 days	\N	\N	\N	2026-08-20 06:35:44.250988+00	\N	2026-08-20 06:35:44.26208+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
30589db9-44d2-4cb5-b6dd-81d1cefbd915	2446deb8-f6cc-4ee1-b179-599d0a2e357a	EMP-1001	Priya Sharma	Engineering	Software Engineer	priya.sharma@acme.co	priya1001@gmail.com	9876501001	Active	Resign	better opp	2026-08-20	2026-08-31	better opp	60 days	\N	\N	\N	2026-08-20 09:40:15.112908+00	\N	2026-08-20 09:40:15.160793+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3a576a72-02ca-4b83-94f4-735b0348c9b2	498bb0ed-62ca-4e56-bcb3-4cbd356077be	EMP-1002	Rohan Mehta	Engineering	Senior Software Engineer	rohan.mehta@acme.co	rohan1002@gmail.com	9876501002	Active	Resign	better opp	2026-08-20	2026-09-04	better opp	60 days	\N	\N	\N	2026-08-20 09:44:21.427364+00	\N	2026-08-20 09:44:21.428431+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4d7a33d1-9bb6-4174-933a-b67a5f1ee447	df465de2-4aba-41d3-a2a3-1e81ca66e34a	EMP-1004	Karthik Bose	Engineering	DevOps Engineer	karthik.bose@acme.co	karthik1004@gmail.com	9876501004	Active	Resign	Better Opportunity	2026-08-20	2026-10-19	Better Opportunity	60 days	\N	\N	\N	2026-08-20 10:42:11.75374+00	\N	2026-08-20 10:42:11.753917+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2045661c-a8d6-4501-b7e1-c2ac306c397b	eb50369d-e526-459c-bb6c-aa3a85b231db	EMP-9301	Integration Resource	\N	\N	integration.resource.c92dd5fc2d1c4c4fa7401c33cac1e6fe@acme.co	\N	\N	Probation	Resign	Integration test	2026-08-20	2026-09-19	Integration test	30 days	{}	{}	{}	2026-08-20 12:25:04.296597+00	\N	2026-08-20 12:25:04.39085+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
84e635a5-0601-4670-a6e5-68562cd9e623	a165f6aa-148a-4ad0-953a-f154ae0991c8	EMP-5886	Integration Resource	\N	\N	integration.resource.e531fb2cecab4c6caa485682aeaa36eb@acme.co	\N	\N	Active	Resign	Notice already ended	2026-08-10	2026-08-19	Notice already ended	30 days	{}	{}	{}	2026-08-20 12:25:04.505815+00	\N	2026-08-20 12:25:04.510288+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
c96de1f8-bce4-46e6-8fc9-47d9cf00a613	080045f2-3ff3-49af-bced-4b10ea1dde6f	EMP-7266	Integration Resource	\N	\N	integration.resource.ce5bcae27dbc41978b56226b5bf1debf@acme.co	\N	\N	Probation	Resign	Integration test	2026-08-20	2026-09-19	Integration test	30 days	{}	{}	{}	2026-08-20 12:51:19.070579+00	\N	2026-08-20 12:51:19.272327+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
d11639b8-0639-498f-b29c-8aa7154fd2aa	649f4c6f-8719-4ff4-8969-7a55a16e43bd	EMP-8163	Integration Resource	\N	\N	integration.resource.55c6d73ab436476db67f6f1b9df80d8a@acme.co	\N	\N	Active	Resign	Notice already ended	2026-08-10	2026-08-19	Notice already ended	30 days	{}	{}	{}	2026-08-20 12:51:19.537054+00	\N	2026-08-20 12:51:19.547505+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
c86dbb9b-4d96-4e3a-b74a-a94fa9992605	96425efc-9b0e-4f2b-8fd6-ec3b77161547	EMP-3456	Dhanshree Pansare	Squad1	operation head	dhanshree.pansare@gmail.com	dhanshree.pansare002@gmail.com	9326178048	Probation	Resign	bo	2026-08-20	2026-11-18	bo	90 days	\N	\N	\N	2026-08-20 13:46:59.169476+00	\N	2026-08-20 13:46:59.255691+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: mst_business_units; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_business_units ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
1ab2e67e-5e47-4f6d-8035-dd6a5c5f6b85	talakunchi_networks_private_limited	Talakunchi Networks Private Limited	t	1	2026-09-03 12:17:46.134222+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_cities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
07183c9f-8e55-4002-bc52-97b380967367	in_raipur	Raipur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
084d0e54-375e-4eb2-a348-577dd4ad73fa	us_boston	Boston	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
08b411f1-b35e-4989-a856-ae6f7596743a	mx_mexico_city	Mexico City	t	331cec37-bd6c-4a60-8ac5-b413d9677b8a	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
0b3b4341-9cd1-4d9c-a2ed-12309bce2340	gb_manchester	Manchester	t	1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
0cc0f358-f7aa-48de-a5da-815f3f06c252	us_los_angeles	Los Angeles	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
0dd2728e-6f8d-462e-906f-186f51ab2ba7	us_new_york	New York	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
0e740962-784f-4738-a401-cb10072107e8	in_delhi	Delhi	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
0fb20e80-ce14-4160-9102-dcec4ccdbecc	in_patna	Patna	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
11fe6de8-1cab-45d7-b88d-51151386c2e0	id_jakarta	Jakarta	t	e341a797-6da6-4427-9bc1-f3271b6882c1	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
14c601ac-1628-423f-95ef-c2189d3f1cd8	us_atlanta	Atlanta	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
19062584-e553-4778-96dd-be7031ae6521	in_jodhpur	Jodhpur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
19eb3378-5b1f-4b69-b712-37db29dcd4f3	ca_montreal	Montreal	t	ba695b57-0f82-4ad0-b14a-2785b26209ff	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
1a08451f-8c92-4edf-97da-f9bb41a840e1	in_udaipur	Udaipur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
1a18d297-caf0-4d13-9a25-4014e1e1c6bf	in_kolkata	Kolkata	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
1aae890c-96bd-4529-bcc3-fed9fd30c24d	kr_seoul	Seoul	t	c093b0e3-31a9-40b4-840c-539ca86bc578	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
1b61f09f-68d1-480d-bc08-96836413a8c6	gb_edinburgh	Edinburgh	t	1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
1e051a3a-34a5-4854-9e7b-9813fc76c34f	sa_jeddah	Jeddah	t	28d63d80-4982-4a6b-9400-ee91260b2604	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
1fff6b1e-f337-4f93-a98a-d952449aea7b	in_lucknow	Lucknow	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
213d37ca-46b2-4caa-8551-abbf2274ced7	in_jaipur	Jaipur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
21a5ff30-a774-4d3a-80d4-0eeb88e8b395	in_kochi	Kochi	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
223b9c33-57cc-460f-9433-dc4fb39a649f	gb_birmingham	Birmingham	t	1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
23d8be99-7dfc-48f1-95b1-8d764af0b16a	in_varanasi	Varanasi	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
2451c2e3-f142-48e4-96a3-3eb9eba2c892	sg_singapore	Singapore	t	f1d80739-30d7-4877-a1a7-ee414b074134	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
2764903d-c6c1-4049-84b2-0045296b6040	au_perth	Perth	t	eeb56a1f-9663-4d29-a984-30c4fc133de2	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
277cc369-b358-445d-add4-579a493cc3e7	pk_karachi	Karachi	t	0a836600-60d1-4d2e-bbd7-034b338574ba	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
29593af5-af1d-4a5b-9562-3c7bbdea45ef	fr_paris	Paris	t	a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
2961f98c-8524-49ca-89fb-c7f51a318d4a	pl_krakow	Krakow	t	af68020d-22f0-4f66-91f6-afe82d052ddd	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
301f6d9d-93cd-4eb6-bf32-8e4f09930007	au_melbourne	Melbourne	t	eeb56a1f-9663-4d29-a984-30c4fc133de2	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
30ff773f-5f99-43d2-a22e-6a0c471d5d2a	it_rome	Rome	t	c1764720-16fe-4d3f-bd82-9882632239cd	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
353adddb-265f-4326-9658-700c3558cee7	jp_yokohama	Yokohama	t	01005b87-3f98-4425-8eb9-6417f2d83b41	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
3cf94e25-007c-4f67-9ba2-a64fe7a4e9c5	us_austin	Austin	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
3fb0cb31-828a-4c49-8ffd-f65721b669f1	us_washington_dc	Washington DC	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
3fe72ba7-7db7-4e00-8e58-fa685afca0ce	my_kuala_lumpur	Kuala Lumpur	t	d725a52a-22a3-48d6-b035-001c1aa15eae	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
41e88e7d-b540-4f0b-9dc3-b8a6ed375eac	bd_chittagong	Chittagong	t	ecb5e362-682e-46d2-bee2-ef0b022ebb13	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
4351e7e2-fe6b-4062-b7e1-5a23b152a2fd	in_guntur	Guntur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
449b8fec-f1a0-4b96-ba76-b11fc95dc854	de_hamburg	Hamburg	t	3f86bc47-1e09-482f-9671-9f4b5b089ee4	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
44cff32a-4802-47a7-8590-cb61848bbf81	jp_tokyo	Tokyo	t	01005b87-3f98-4425-8eb9-6417f2d83b41	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
45e91295-3902-440f-85af-13e998ad000c	in_vadodara	Vadodara	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
45fc7e0b-fa8b-4e17-9df2-2b803f1692c2	nz_wellington	Wellington	t	58746abf-d5dc-4cc8-8a35-96a1747f7a1f	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
484378bd-7a89-4b55-9add-8a22bd71995a	in_ahmedabad	Ahmedabad	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
4860b8a2-acf1-47bc-aa0e-b9a88341e321	it_milan	Milan	t	c1764720-16fe-4d3f-bd82-9882632239cd	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
48a796c1-38e5-49f0-bbd5-6400ce30ee23	in_nagpur	Nagpur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
4a2b4e31-024b-4bae-9cec-afefe791e0ee	ae_sharjah	Sharjah	t	1d3750a9-fab1-43fb-ab7b-865dda283bf3	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
4a9692f8-9fc3-48f8-82bd-075a36f31ecf	za_cape_town	Cape Town	t	585fb67f-28ee-437c-aa84-fdc20a1a11d5	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
4c92b186-fb45-4ed0-b38d-cda7f143a993	de_frankfurt	Frankfurt	t	3f86bc47-1e09-482f-9671-9f4b5b089ee4	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
4d396fc0-ae55-4eeb-b2db-79bbb757d3cd	in_kalyan_dombivli	Kalyan-Dombivli	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
4fd00295-51a7-4bfe-81fa-97cdcce23451	cn_shenzhen	Shenzhen	t	8b34d450-add9-4da2-ab29-651c187ae702	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
55e401d4-a911-4f92-ba41-23e34513ef78	in_amritsar	Amritsar	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
57a45744-d93d-4ca7-9fee-8358914674b9	bd_dhaka	Dhaka	t	ecb5e362-682e-46d2-bee2-ef0b022ebb13	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
5965cf30-b981-47ca-a3ba-c875c33c1361	ae_dubai	Dubai	t	1d3750a9-fab1-43fb-ab7b-865dda283bf3	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
5a35da4d-0d93-45a9-bb97-aa470535f713	in_thiruvananthapuram	Thiruvananthapuram	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
5b3989d6-699e-47a3-8c8b-0c6fa6509727	de_munich	Munich	t	3f86bc47-1e09-482f-9671-9f4b5b089ee4	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
5cd424e6-ab9c-4498-a67e-027a9c3439ce	de_berlin	Berlin	t	3f86bc47-1e09-482f-9671-9f4b5b089ee4	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
626c62f3-eac8-492b-b570-ab1c6ac764a6	nl_amsterdam	Amsterdam	t	6f9bb48d-5314-461c-aab8-3b47b00b27a1	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
642f3232-b168-4934-b4e3-f10437500640	in_kanpur	Kanpur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
670404c6-c476-4d08-a374-3e4d6669f66c	in_chandigarh	Chandigarh	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
67f59fe5-a37c-49b9-b0cf-322a8b0b2d3b	no_oslo	Oslo	t	a890f8b0-d80f-4a14-994e-0ba88d6336a9	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
6a068925-de66-4927-979b-5ed42766c09b	au_brisbane	Brisbane	t	eeb56a1f-9663-4d29-a984-30c4fc133de2	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
6e520834-9523-42ad-8ad8-20e8b14dea83	es_barcelona	Barcelona	t	4da9200f-5486-4710-bf58-e73778e1d506	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
6ffbb80b-985d-4f00-9140-db22f39a625d	in_mumbai	Mumbai	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
716817f5-02f6-4f05-8daa-023f6cdffede	in_hubballi	Hubballi	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
740a6636-f7ab-498d-9f2b-588eaac5338a	th_bangkok	Bangkok	t	64ea0815-a39c-4ecb-b771-038dd74a9b7c	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
7621f953-b63b-4a95-b23f-3e0277109b92	se_stockholm	Stockholm	t	990888a7-50d0-45f0-b650-2686f87c4fd0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
79b5f114-216f-4ee1-973c-57e22110d450	za_johannesburg	Johannesburg	t	585fb67f-28ee-437c-aa84-fdc20a1a11d5	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
7a91b70b-e0ce-4613-9d2f-4ebd06b816eb	be_brussels	Brussels	t	6e5c5f7b-ab38-4926-9945-da9ac35a35b0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
7d25aaed-acb8-4b6d-a16a-1b90054e6996	vn_hanoi	Hanoi	t	a3228796-7e35-4710-9439-2aa36754dbbe	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
7dd04422-91e0-4671-965f-66658c3bf3a4	es_madrid	Madrid	t	4da9200f-5486-4710-bf58-e73778e1d506	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
8152a6d2-ce3d-48a9-aee8-2508c86199d1	nl_rotterdam	Rotterdam	t	6f9bb48d-5314-461c-aab8-3b47b00b27a1	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
81908f77-5500-4974-a57a-ba7cfccc7a9a	in_jamshedpur	Jamshedpur	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
81a2bc40-e010-43f1-bcce-9a9198d4ab9d	au_sydney	Sydney	t	eeb56a1f-9663-4d29-a984-30c4fc133de2	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
8249edd0-daaf-4d91-8ede-59e00790d90e	in_madurai	Madurai	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
847e49f7-e605-434e-9abe-35b23cb5af90	ch_geneva	Geneva	t	d3791631-5e4b-4efa-a86a-59344c19e1a1	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
87da8284-74ad-4e12-ad68-23fd727a5e5b	ch_zurich	Zurich	t	d3791631-5e4b-4efa-a86a-59344c19e1a1	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
8a0d7587-098e-4c80-ab86-38aa76c56c2d	br_rio_de_janeiro	Rio de Janeiro	t	6044817c-ffa1-44b3-ac2a-05e52b97df4a	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
8c56329e-5d66-48aa-b242-a15150254bf4	cn_shanghai	Shanghai	t	8b34d450-add9-4da2-ab29-651c187ae702	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
8cd04b30-de06-4ba0-81e1-b120cb24045e	pl_warsaw	Warsaw	t	af68020d-22f0-4f66-91f6-afe82d052ddd	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
8de0928d-e308-4272-9dfb-efbd97b6b683	in_mysuru	Mysuru	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
8df31b20-7394-4727-af49-216c3302c4a2	ph_cebu	Cebu	t	1814186b-4a79-45ea-bfc9-bbdc4721e20b	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
92187184-87f9-42c6-84a2-30a1cdcd698f	ae_abu_dhabi	Abu Dhabi	t	1d3750a9-fab1-43fb-ab7b-865dda283bf3	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
95913438-968f-4e17-8324-a8e75b2242f4	in_gurugram	Gurugram	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
9600a90b-6463-48cd-887f-45997a11248d	in_chennai	Chennai	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
96070596-6a1e-44aa-b35b-83b7a6b7b8aa	sa_dammam	Dammam	t	28d63d80-4982-4a6b-9400-ee91260b2604	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
97ec307e-5801-49b4-86aa-75563e5e711b	in_bhubaneswar	Bhubaneswar	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
9891ebbe-9411-4a41-b472-67451441fc56	dk_copenhagen	Copenhagen	t	068fb26f-376a-4976-9127-b0dae76e7dcd	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
9ba22a3c-c3ca-4472-a50d-9bb1b5bd8d09	gb_bristol	Bristol	t	1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
9bc015d9-b447-4cad-b4bb-8d33507cbdaf	fr_lyon	Lyon	t	a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
9cde9f5d-4f0b-4672-a4be-9c1e3f307638	in_aurangabad	Aurangabad	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
a5a7e7fd-087e-464b-bd31-25f11f357f91	us_chicago	Chicago	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
ab7836eb-7cc7-439d-9dca-49161aa76292	in_indore	Indore	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
ab8ebe77-f842-4ae8-a84e-01e14a9fd702	us_seattle	Seattle	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
ad785e99-dacc-477f-8db6-e8046a39b215	pk_islamabad	Islamabad	t	0a836600-60d1-4d2e-bbd7-034b338574ba	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
b1120770-e683-4592-8024-47caf0f35746	in_ranchi	Ranchi	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
b3e264bf-fcc4-45a2-ac8f-04166724d05b	mx_monterrey	Monterrey	t	331cec37-bd6c-4a60-8ac5-b413d9677b8a	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
b5302d8c-0de7-433b-8c87-5cf75f75b5f1	in_dehradun	Dehradun	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
b76b4b18-8708-4ff8-8134-58d5a02e62e7	in_visakhapatnam	Visakhapatnam	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
b79f714f-b9e1-4556-be97-02de9d27568b	in_surat	Surat	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
b8f9023b-e2ec-4095-be6f-2249a95686b5	in_hyderabad	Hyderabad	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
b9e2a825-60b2-4839-865b-dc6b1874d89b	in_bhopal	Bhopal	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
bad14380-4cb5-45f5-b7bb-669181caee13	in_nashik	Nashik	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
bba31ffe-e8c3-4069-9b89-a707f3185cdf	nz_auckland	Auckland	t	58746abf-d5dc-4cc8-8a35-96a1747f7a1f	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
bd3bac50-1d10-44cb-b69b-9e09aa0f6a6b	in_rajkot	Rajkot	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
bd5bed6a-230c-4972-a94a-95457a5ebdaf	vn_ho_chi_minh_city	Ho Chi Minh City	t	a3228796-7e35-4710-9439-2aa36754dbbe	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
bdc2e3e8-bb40-4b50-af48-446cb848bfaf	ca_vancouver	Vancouver	t	ba695b57-0f82-4ad0-b14a-2785b26209ff	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
be3bc063-9c10-4614-94d5-7b847afaf6bd	in_thane	Thane	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
beb4a29c-e0c5-4509-8400-8f672a820183	in_prayagraj	Prayagraj	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
bf4289e3-e404-41e7-829d-8f0028a48965	in_coimbatore	Coimbatore	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
ca0b9269-d93e-4748-9280-939d97ed7ffd	us_dallas	Dallas	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
cd21e337-74ca-4531-920a-fd728182dd9d	in_noida	Noida	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
cd689e49-cf58-40db-aa97-cad0285a0be8	pt_lisbon	Lisbon	t	b8307417-a01f-4b81-8f46-b637c865dc76	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
d2700377-afed-4114-b7cd-fe5d63394dba	kr_busan	Busan	t	c093b0e3-31a9-40b4-840c-539ca86bc578	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
d76207a2-8c4c-4352-acb7-67f098fb08c4	in_bengaluru	Bengaluru	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
d768797a-cf38-4742-83c4-de675ed8d7b6	in_ludhiana	Ludhiana	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
d8136f7e-2533-4704-9c10-4cba8453f4cb	pk_lahore	Lahore	t	0a836600-60d1-4d2e-bbd7-034b338574ba	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
d9972aef-6b7e-48a1-abc0-6a5e043233d9	in_warangal	Warangal	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
dc141bc7-8039-4645-854e-1e2c898ce0dc	in_pune	Pune	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
e00fecb8-b28f-491a-bcb7-dc47445c7c5d	ph_manila	Manila	t	1814186b-4a79-45ea-bfc9-bbdc4721e20b	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
e051a3eb-67a4-48a1-bd0f-ba12879af889	jp_osaka	Osaka	t	01005b87-3f98-4425-8eb9-6417f2d83b41	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
e19e0057-cea0-429c-b5ac-4762d5107735	ie_dublin	Dublin	t	9bd3e0a8-de16-4a26-92aa-b43deae65bb7	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
e28e5c98-4103-43a2-b5a0-ad2ba96bf6d6	at_vienna	Vienna	t	25e6b9ec-058b-4778-9c17-1151079562f4	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
e2e4ac9d-6292-47c1-9424-7362ab4b024c	sa_riyadh	Riyadh	t	28d63d80-4982-4a6b-9400-ee91260b2604	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
e4cbe1c4-88f4-4fc3-b7e9-121f08aa3495	np_kathmandu	Kathmandu	t	c9bb9747-7e0f-424e-864b-182d7a8c4230	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
e69a29ec-e5fa-4786-a88a-13fbaaedddf0	fi_helsinki	Helsinki	t	9c93a091-0971-4080-b15f-ddebb9de6bb3	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
ea72f142-d2b7-4d74-8877-4c5c64106d84	in_navi_mumbai	Navi Mumbai	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
ea739f55-0951-498d-bebc-14f34c1aea51	br_sao_paulo	Sao Paulo	t	6044817c-ffa1-44b3-ac2a-05e52b97df4a	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
eb19cb49-5743-4f8e-b3de-1c97a8527c8a	us_san_francisco	San Francisco	t	339b1d1f-d716-422e-9090-127430134420	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
ec893479-ffdd-4ec0-9f85-1fdee09c2e06	in_mangaluru	Mangaluru	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
ee152b57-cf4a-4d13-bfd7-7f19f506caa4	ca_toronto	Toronto	t	ba695b57-0f82-4ad0-b14a-2785b26209ff	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
ef0f0962-986c-4894-9ba4-0f0226a8c5ff	qa_doha	Doha	t	7c57576c-45b6-4cf0-b26d-d3e64730118b	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
ef6bd7b1-faf0-4813-8105-b9d7c240d79d	in_vijayawada	Vijayawada	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
f2aaa2da-20ad-4d42-9a32-c264a31d747e	lk_colombo	Colombo	t	7190bc9f-d9d5-4bb3-b889-af8a1d6ec53f	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
fa492bc9-1015-4a17-9e5b-585b44740f64	in_guwahati	Guwahati	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
fa7c197c-a692-443e-bdfa-82c591807262	id_surabaya	Surabaya	t	e341a797-6da6-4427-9bc1-f3271b6882c1	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
fb029a31-16c1-4b23-bc35-3d4ca08e6961	my_penang	Penang	t	d725a52a-22a3-48d6-b035-001c1aa15eae	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
fc8929c1-64ad-4185-bd6e-c706486b8a41	gb_london	London	t	1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
fcf5dd98-6fe2-4ae3-8084-9966e94eb443	cn_beijing	Beijing	t	8b34d450-add9-4da2-ab29-651c187ae702	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
fddb7350-b051-4870-bda3-17f51b79fd67	se_gothenburg	Gothenburg	t	990888a7-50d0-45f0-b650-2686f87c4fd0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
fe6526bc-a57b-4c6e-8094-be6327614409	in_tiruchirappalli	Tiruchirappalli	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20 11:37:06.005856+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_countries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") FROM stdin;
f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	IN	India	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+91	10
339b1d1f-d716-422e-9090-127430134420	US	United States	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+1	10
1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	GB	United Kingdom	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+44	10
1d3750a9-fab1-43fb-ab7b-865dda283bf3	AE	United Arab Emirates	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+971	9
f1d80739-30d7-4877-a1a7-ee414b074134	SG	Singapore	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+65	8
eeb56a1f-9663-4d29-a984-30c4fc133de2	AU	Australia	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+61	9
3f86bc47-1e09-482f-9671-9f4b5b089ee4	DE	Germany	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+49	11
ba695b57-0f82-4ad0-b14a-2785b26209ff	CA	Canada	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+1	10
a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb	FR	France	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+33	9
01005b87-3f98-4425-8eb9-6417f2d83b41	JP	Japan	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+81	10
28d63d80-4982-4a6b-9400-ee91260b2604	SA	Saudi Arabia	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+966	9
7c57576c-45b6-4cf0-b26d-d3e64730118b	QA	Qatar	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+974	8
58746abf-d5dc-4cc8-8a35-96a1747f7a1f	NZ	New Zealand	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+64	9
585fb67f-28ee-437c-aa84-fdc20a1a11d5	ZA	South Africa	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+27	9
9bd3e0a8-de16-4a26-92aa-b43deae65bb7	IE	Ireland	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+353	9
6f9bb48d-5314-461c-aab8-3b47b00b27a1	NL	Netherlands	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+31	9
c1764720-16fe-4d3f-bd82-9882632239cd	IT	Italy	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+39	10
4da9200f-5486-4710-bf58-e73778e1d506	ES	Spain	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+34	9
d3791631-5e4b-4efa-a86a-59344c19e1a1	CH	Switzerland	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+41	9
c093b0e3-31a9-40b4-840c-539ca86bc578	KR	South Korea	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N	+82	10
068fb26f-376a-4976-9127-b0dae76e7dcd	DK	Denmark	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+45	8
0a836600-60d1-4d2e-bbd7-034b338574ba	PK	Pakistan	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+92	10
1814186b-4a79-45ea-bfc9-bbdc4721e20b	PH	Philippines	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+63	10
25e6b9ec-058b-4778-9c17-1151079562f4	AT	Austria	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+43	10
331cec37-bd6c-4a60-8ac5-b413d9677b8a	MX	Mexico	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+52	10
6044817c-ffa1-44b3-ac2a-05e52b97df4a	BR	Brazil	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+55	11
64ea0815-a39c-4ecb-b771-038dd74a9b7c	TH	Thailand	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+66	9
6e5c5f7b-ab38-4926-9945-da9ac35a35b0	BE	Belgium	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+32	9
7190bc9f-d9d5-4bb3-b889-af8a1d6ec53f	LK	Sri Lanka	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+94	9
8b34d450-add9-4da2-ab29-651c187ae702	CN	China	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+86	11
990888a7-50d0-45f0-b650-2686f87c4fd0	SE	Sweden	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+46	9
9c93a091-0971-4080-b15f-ddebb9de6bb3	FI	Finland	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+358	9
a3228796-7e35-4710-9439-2aa36754dbbe	VN	Vietnam	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+84	9
a890f8b0-d80f-4a14-994e-0ba88d6336a9	NO	Norway	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+47	8
af68020d-22f0-4f66-91f6-afe82d052ddd	PL	Poland	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+48	9
b8307417-a01f-4b81-8f46-b637c865dc76	PT	Portugal	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+351	9
c9bb9747-7e0f-424e-864b-182d7a8c4230	NP	Nepal	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+977	10
d725a52a-22a3-48d6-b035-001c1aa15eae	MY	Malaysia	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+60	9
e341a797-6da6-4427-9bc1-f3271b6882c1	ID	Indonesia	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+62	10
ecb5e362-682e-46d2-bee2-ef0b022ebb13	BD	Bangladesh	t	2026-08-20 11:37:05.749911+00	2026-09-02 05:13:48.939145+00	\N	\N	\N	+880	10
\.


--
-- Data for Name: mst_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	core	Core	t	2026-09-02 10:24:51.765975+00	\N	\N	\N	\N
f7e882f6-2fa8-45e1-9137-2bc4b70f016a	functional_it_administration	Functional - IT Administration	t	2026-09-02 10:24:51.785918+00	\N	\N	\N	\N
bcbd68c8-c3f3-4396-abb0-0b0e13637958	functional_accounts	Functional - Accounts	t	2026-09-02 10:24:51.795991+00	\N	\N	\N	\N
310a2f16-15f6-4b82-95f6-ab18b5b429f5	functional_hr	Functional - HR	t	2026-09-02 10:24:51.812471+00	\N	\N	\N	\N
13c91c98-00ae-4211-acb8-d06e35953806	functional_sales	Functional - Sales	t	2026-09-02 10:24:51.826882+00	\N	\N	\N	\N
8e4e88f1-e294-4554-80cc-92ed6169caeb	functional_project_management	Functional - Project Management	t	2026-09-02 10:24:51.843878+00	\N	\N	\N	\N
898c36e9-1cb7-4c56-9148-a3b6893c0149	rd_research_and_development	R&D (Research & Development)	t	2026-09-02 10:24:51.86295+00	\N	\N	\N	\N
3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	services_operations	Services - Operations	t	2026-09-02 10:24:51.872711+00	\N	\N	\N	\N
be8e036d-ad13-4c79-89ec-294e490a6816	services_consulting	Services - Consulting	t	2026-09-02 10:24:51.907068+00	\N	\N	\N	\N
0aed67b8-c454-439a-a07f-4f46d46d58af	services_testing	Services - Testing	t	2026-09-02 10:24:51.926627+00	\N	\N	\N	\N
08299899-214f-40f2-8aa7-e4738a0f3767	marketing	Marketing	t	2026-09-02 11:43:06.010157+00	2026-09-02 12:35:15.304602+00	\N	\N	2026-09-02 12:35:15.304602+00
0e751fd3-8710-4adf-baca-8862c0f9e1b0	product	Product	t	2026-09-02 11:43:06.010157+00	2026-09-02 12:35:15.304602+00	\N	\N	2026-09-02 12:35:15.304602+00
3270b7dc-9101-458c-99bc-23f14257d485	engineering	Engineering	t	2026-09-02 11:43:06.010157+00	2026-09-02 12:35:15.304602+00	\N	\N	2026-09-02 12:35:15.304602+00
585cc795-e9f4-4b40-a882-8e1695b53e31	finance	Finance	t	2026-09-02 11:43:06.010157+00	2026-09-02 12:35:15.304602+00	\N	\N	2026-09-02 12:35:15.304602+00
af9ae8e9-a932-41fe-a60f-6527c09347d2	human_resources	Human Resources	t	2026-09-02 11:43:06.010157+00	2026-09-02 12:35:15.304602+00	\N	\N	2026-09-02 12:35:15.304602+00
b98b3c15-03e0-4eab-997b-1142be053436	design	Design	t	2026-09-02 11:43:06.010157+00	2026-09-02 12:35:15.304602+00	\N	\N	2026-09-02 12:35:15.304602+00
ba33ee6e-aeb2-47ba-902a-b1b1992f77a4	leadership	Leadership	t	2026-09-02 11:43:06.010157+00	2026-09-02 12:35:15.304602+00	\N	\N	2026-09-02 12:35:15.304602+00
bd69f52b-cbc9-4868-aeb9-8ba6259c726f	sales	Sales	t	2026-09-02 11:43:06.010157+00	2026-09-02 12:35:15.304602+00	\N	\N	2026-09-02 12:35:15.304602+00
c9b2ceef-046a-4a4a-b32c-ba9ad2758fb6	delivery	Delivery	t	2026-09-02 11:43:06.010157+00	2026-09-02 12:35:15.304602+00	\N	\N	2026-09-02 12:35:15.304602+00
ee0abe28-a852-4eaf-ad64-e3375d67e9c3	operations	Operations	t	2026-09-02 11:43:06.010157+00	2026-09-02 12:35:15.304602+00	\N	\N	2026-09-02 12:35:15.304602+00
\.


--
-- Data for Name: mst_designations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
778f1120-9633-4933-9160-ddaa46668838	core_director_and_chief_executive_officer	Director and Chief Executive Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 10:24:51.776662+00	\N	\N	\N	\N
ffed7aa1-e88f-4281-919f-8d49fbabf5a5	core_director_and_chief_operating_officer	Director and Chief Operating Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 10:24:51.781954+00	\N	\N	\N	\N
0525d830-ead9-44a0-871f-91b7845fec26	core_director_and_chief_technology_officer	Director and Chief Technology Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 10:24:51.783926+00	\N	\N	\N	\N
da990f6e-3379-4cc4-89b7-0ead29da472b	functional_it_admini_it_admin	IT Admin	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.787896+00	\N	\N	\N	\N
c70b9832-841e-4864-9b85-eaba3c0a995f	functional_it_admini_desktop_support_engineer_i	Desktop Support Engineer - I	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.78998+00	\N	\N	\N	\N
73bd55bb-5d0e-4381-8ad2-2238377fca93	functional_it_admini_desktop_support_engineer_ii	Desktop Support Engineer - II	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.792134+00	\N	\N	\N	\N
f8502c44-b289-49e4-8401-3dcad4d5bbe0	functional_it_admini_intern	Intern	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.794108+00	\N	\N	\N	\N
155642eb-a633-4460-b658-aca9fde2d817	functional_accounts_accountant_i	Accountant - I	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.797934+00	\N	\N	\N	\N
8dc0d8fe-593d-422a-8b27-5b68fbe6d224	functional_accounts_accountant_ii	Accountant - II	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.799807+00	\N	\N	\N	\N
6e606c29-2ebf-4ab8-8006-aaedd5680009	functional_accounts_accountant_iii	Accountant - III	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.801711+00	\N	\N	\N	\N
4ef1cb5b-9688-4ce2-95b3-6a0863200166	functional_accounts_senior_accountant_i	Senior Accountant - I	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.803595+00	\N	\N	\N	\N
96efad7d-8b7f-4d7f-a862-c0a6bec3789f	functional_accounts_senior_accountant_ii	Senior Accountant - II	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.805714+00	\N	\N	\N	\N
1f97b442-95c5-4b11-93a0-ea146534ae85	functional_accounts_senior_accountant_iii	Senior Accountant - III	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.807813+00	\N	\N	\N	\N
caa227a1-2dcf-4195-ab9c-8f76d1862daa	functional_accounts_intern	Intern	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.809802+00	\N	\N	\N	\N
8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	functional_hr_hr_head	HR Head	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.814553+00	\N	\N	\N	\N
7d542941-65b9-499b-81b3-239748d6da52	functional_hr_recruitment_coordinator_i	Recruitment Coordinator - I	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.8165+00	\N	\N	\N	\N
c2e248c8-e917-445f-9f7b-1e25d7bb5abe	functional_hr_recruitment_coordinator_ii	Recruitment Coordinator - II	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.818555+00	\N	\N	\N	\N
485012d4-2c28-4bc4-92c7-3609e3e3749e	functional_hr_senior_hr_executive_i	Senior HR Executive - I	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.820547+00	\N	\N	\N	\N
e4e20503-cd55-4393-83fd-6c7e7d7d0a49	functional_hr_senior_hr_executive_ii	Senior HR Executive - II	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.8227+00	\N	\N	\N	\N
e8c22eff-0daf-4690-a537-c8b0b6110a01	functional_hr_intern	Intern	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.824863+00	\N	\N	\N	\N
b2b687ef-fd62-4cb7-a826-b40a35da7b2c	functional_sales_business_development_associate_i	Business Development Associate - I	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.828797+00	\N	\N	\N	\N
157d001c-b056-45b1-96a3-3c05bcd8d99c	functional_sales_customer_success_representative_ii	Customer Success Representative - II	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.830775+00	\N	\N	\N	\N
6193be76-40ad-4973-9ee7-246a4d8f4109	functional_sales_director_product_sales	Director - Product Sales	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.832885+00	\N	\N	\N	\N
e2c675a7-92dc-4477-be75-9a304cbe4def	functional_sales_sales_associate	Sales Associate	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.83517+00	\N	\N	\N	\N
272973a6-c052-4aef-bf32-9e24f7eb6cc9	functional_sales_associate_customer_success_representative_i	Associate Customer Success Representative - I	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.837646+00	\N	\N	\N	\N
7e7d954f-34b5-4c23-8c3f-698ec920e9e4	functional_sales_associate_customer_success_representative_ii	Associate Customer Success Representative - II	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.839641+00	\N	\N	\N	\N
e2b10def-c91d-45da-94c5-f5530e743aa2	functional_sales_intern	Intern	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.841726+00	\N	\N	\N	\N
b3309eea-7374-4a8d-ac13-481b2a7fd492	functional_project_m_associate_pmo_i	Associate PMO - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.845704+00	\N	\N	\N	\N
2a76927c-461a-48e4-8190-dea7361ef3db	functional_project_m_associate_pmo_ii	Associate PMO - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.847585+00	\N	\N	\N	\N
c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	functional_project_m_senior_pmo_i	Senior PMO - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.849476+00	\N	\N	\N	\N
138434a2-625f-4df5-836d-fcf0cfceef79	functional_project_m_senior_pmo_ii	Senior PMO - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.851761+00	\N	\N	\N	\N
834c9e15-c70d-4a0b-bb12-5e55f23c181d	functional_project_m_delivery_account_manager_i	Delivery Account Manager - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.853646+00	\N	\N	\N	\N
d8a2b9e5-f54d-4344-a78d-c6c840467543	functional_project_m_delivery_account_manager_ii	Delivery Account Manager - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.855524+00	\N	\N	\N	\N
8b57cfd5-5d4e-44a3-9646-b36873c111c2	functional_project_m_senior_delivery_account_manager_i	Senior Delivery Account Manager - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.857373+00	\N	\N	\N	\N
9dc69952-eae6-4ec0-a327-67392315f089	functional_project_m_senior_delivery_account_manager_ii	Senior Delivery Account Manager - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.859188+00	\N	\N	\N	\N
9050e021-7d84-4401-820e-c0e768abb1ab	functional_project_m_intern	Intern	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.861092+00	\N	\N	\N	\N
f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	rd_research_and_deve_python_developer_i	Python Developer - I	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.864858+00	\N	\N	\N	\N
3356f353-1566-4df6-9958-fa01d67d13c7	rd_research_and_deve_python_developer_ii	Python Developer - II	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.866732+00	\N	\N	\N	\N
9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	rd_research_and_deve_python_developer_iii	Python Developer - III	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.868943+00	\N	\N	\N	\N
bb7ccd5f-2f60-49fb-b984-f11fc47add22	rd_research_and_deve_intern	Intern	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.870785+00	\N	\N	\N	\N
6d25ff6d-e13d-440f-b775-215547af7acb	services_operations_soc_analyst_i	SOC Analyst - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.874793+00	\N	\N	\N	\N
48429bb5-c583-4684-b30a-7ed443b671ca	services_operations_soc_analyst_ii	SOC Analyst - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.876768+00	\N	\N	\N	\N
f20a7445-0b01-4f20-85a5-853101d864ee	services_operations_soc_analyst_iii	SOC Analyst - III	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.878659+00	\N	\N	\N	\N
0c1a5ef4-7fca-45dc-8253-87afa21a1df9	services_operations_soc_analyst_iv	SOC Analyst - IV	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.880491+00	\N	\N	\N	\N
ea315f7d-d597-41b3-a999-4f3851bcd020	services_operations_siem_admin_i	SIEM Admin - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.88251+00	\N	\N	\N	\N
4650d4e0-f73c-4688-ae5f-830a46348ff9	services_operations_siem_admin_ii	SIEM Admin - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.884354+00	\N	\N	\N	\N
af8a1442-c5ee-409d-aa91-61c9dba852ee	services_operations_siem_admin_iii	SIEM Admin - III	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.886248+00	\N	\N	\N	\N
e36018c5-bf48-4f93-bef7-93e8864a0b51	services_operations_siem_admin_iv	SIEM Admin - IV	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.888229+00	\N	\N	\N	\N
73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	services_operations_soc_consultant_i	SOC Consultant - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.890218+00	\N	\N	\N	\N
911f6d7f-8d43-40f2-897a-2f416abf8cf9	services_operations_soc_consultant_ii	SOC Consultant - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.892032+00	\N	\N	\N	\N
444df30d-c195-42ad-b9a7-d80cdef69ccd	services_operations_soc_shift_lead_i	SOC Shift Lead - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.894767+00	\N	\N	\N	\N
c0f974c3-f49c-449a-9276-aa64ce501344	services_operations_soc_shift_lead_ii	SOC Shift Lead - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.896662+00	\N	\N	\N	\N
b5f39dd8-c305-489d-9f7d-9adfd010a134	services_operations_soc_lead_i	SOC Lead - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.899202+00	\N	\N	\N	\N
eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	services_operations_soc_lead_ii	SOC Lead - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.901107+00	\N	\N	\N	\N
0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	services_operations_intern	Intern	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.904989+00	\N	\N	\N	\N
1e7faab8-273d-40df-9f9a-485160186c5a	services_consulting_grc_auditor_i	GRC Auditor - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.908929+00	\N	\N	\N	\N
2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	services_consulting_grc_auditor_ii	GRC Auditor - II	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.910823+00	\N	\N	\N	\N
8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	services_consulting_grc_auditor_iii	GRC Auditor - III	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.912801+00	\N	\N	\N	\N
7c2380da-3ee6-46ad-93d6-a79ce3027f29	services_consulting_grc_auditor_iv	GRC Auditor - IV	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.915028+00	\N	\N	\N	\N
dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	services_consulting_senior_grc_auditor_i	Senior GRC Auditor - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.916903+00	\N	\N	\N	\N
3e60b693-d3dd-4481-95c4-9f02da21625c	services_consulting_senior_grc_auditor_ii	Senior GRC Auditor - II	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.91882+00	\N	\N	\N	\N
195d6a81-8457-4b60-9382-6a3a0664f0e9	services_consulting_associate_manager_iii	Associate Manager - III	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.920769+00	\N	\N	\N	\N
2b1558e3-158a-4a84-ae80-053129861a64	services_consulting_senior_vice_president_principal_consultant	Senior Vice President - Principal Consultant	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.922717+00	\N	\N	\N	\N
2076a9b1-e432-46a9-99b1-36e732159856	services_consulting_intern	Intern	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.924658+00	\N	\N	\N	\N
4f972924-350a-47fb-a6b6-f2b34bb6b621	services_testing_pentester_i	PenTester - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.928383+00	\N	\N	\N	\N
0b6ab354-1fcf-4a00-9be3-e58e99c425ed	services_testing_pentester_ii	PenTester - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.930296+00	\N	\N	\N	\N
163d8c87-8f90-4295-a926-2e912c625a1c	services_testing_pentester_iii	PenTester - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.932399+00	\N	\N	\N	\N
9858c224-f97f-4ff8-908d-f46bd5e2243c	services_testing_pentester_iv	PenTester - IV	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.93473+00	\N	\N	\N	\N
632bf06c-f646-4edd-bf2d-e3cd2e034c7f	services_testing_senior_pentester_i	Senior Pentester - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.936785+00	\N	\N	\N	\N
e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	services_testing_senior_pentester_ii	Senior Pentester - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.93907+00	\N	\N	\N	\N
e228c999-bf54-48b4-a373-d2bc9db88554	services_testing_associate_manager_i	Associate Manager - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.953968+00	\N	\N	\N	\N
168d11d7-ca26-4d61-b870-51779dc63023	services_testing_associate_manager_ii	Associate Manager - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.955906+00	\N	\N	\N	\N
aaf4ca75-5fa5-4de2-8353-a5e93beecb56	services_testing_associate_manager_iii	Associate Manager - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.957817+00	\N	\N	\N	\N
3b7ea453-324e-40a0-bb41-77a0795d5af5	services_testing_associate_project_manager	Associate Project Manager	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.961716+00	\N	\N	\N	\N
a697a798-caaf-4248-8e4e-7e89096a9c30	services_testing_manager_i	Manager - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.966138+00	\N	\N	\N	\N
ae255622-ddcc-45ea-a699-8ec416fe57ab	services_testing_devsecops_practitioner_i	DevSecOps Practitioner - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.969279+00	\N	\N	\N	\N
35a6b1af-dc78-4632-a9f4-eedabdbdcb52	services_testing_devsecops_practitioner_ii	DevSecOps Practitioner - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.97275+00	\N	\N	\N	\N
767a00dd-6f09-4f64-a44e-8fbe901222af	services_testing_devsecops_practitioner_iii	DevSecOps Practitioner - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.976579+00	\N	\N	\N	\N
c6c6cd04-6df3-4593-b686-e4b9d362c96f	services_testing_devsecops_associate	DevSecOps Associate	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.980181+00	\N	\N	\N	\N
c1fa4328-a970-48a1-bc08-d50fe36bf44c	services_testing_devsecops_specialist_ii	DevSecOps Specialist - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.983425+00	\N	\N	\N	\N
0a60fb48-99c4-44d0-8d97-ff687ccffc9f	services_testing_red_team_practitioner_ii	Red Team Practitioner - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.986648+00	\N	\N	\N	\N
85cc9fbe-98a4-464d-a638-05f40529c6de	services_testing_red_team_practitioner_iii	Red Team Practitioner - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.991312+00	\N	\N	\N	\N
4b680e29-b4fb-4689-9afb-67a7f089f52b	services_testing_red_team_specialist_ii	Red Team Specialist - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.994166+00	\N	\N	\N	\N
8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	services_testing_senior_cloud_security_consultant_i	Senior Cloud Security Consultant - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.997244+00	\N	\N	\N	\N
e2b4be77-2b20-4064-974d-e6322e7240b4	services_testing_associate_ai_engineer_contractual	Associate AI Engineer - Contractual	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:52.001242+00	\N	\N	\N	\N
47dbf38f-c022-47bc-8444-d0dfb35ff3fd	services_testing_intern	Intern	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:52.004312+00	\N	\N	\N	\N
dadac355-1ddc-457c-935a-d297da3a883d	services_consulting_principal_manager_i	Principal Manager - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.903029+00	2026-09-03 07:11:32.975424+00	\N	\N	\N
05b0acef-feb2-42b7-8d4b-6aa0e6e7db05	project_manager	Project Manager	t	ee0abe28-a852-4eaf-ad64-e3375d67e9c3	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
086214cd-983a-42c5-8e3e-f6ced781d142	software_engineer	Software Engineer	t	3270b7dc-9101-458c-99bc-23f14257d485	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
0bc97b9b-89ee-436c-a649-d5d6826c3566	product_manager	Product Manager	t	0e751fd3-8710-4adf-baca-8862c0f9e1b0	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
12fae3b9-3ff8-470a-9e98-8857e1e7cd2b	marketing_lead	Marketing Lead	t	08299899-214f-40f2-8aa7-e4738a0f3767	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
1d97a91f-7a7f-4270-b427-5b746f3cdbce	ux_designer	UX Designer	t	b98b3c15-03e0-4eab-997b-1142be053436	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
1f90151f-a934-4388-ad0d-d6928de8c78e	finance_analyst	Finance Analyst	t	585cc795-e9f4-4b40-a882-8e1695b53e31	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
2f632e1b-f9f3-429d-8afb-accbed71b789	content_strategist	Content Strategist	t	08299899-214f-40f2-8aa7-e4738a0f3767	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
439f1691-f596-44a4-85cc-b4b7a4b4a678	business_analyst	Business Analyst	t	ee0abe28-a852-4eaf-ad64-e3375d67e9c3	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
4ef3d669-21ca-43ab-a132-db6b00c6063f	engagement_manager	Engagement Manager	t	c9b2ceef-046a-4a4a-b32c-ba9ad2758fb6	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
50cbd605-9143-4722-b70d-7067bd298398	senior_project_manager	Senior Project Manager	t	c9b2ceef-046a-4a4a-b32c-ba9ad2758fb6	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
50fe7edc-ec15-440a-b900-474670e84dc1	hr_business_partner	HR Business Partner	t	af9ae8e9-a932-41fe-a60f-6527c09347d2	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
576b74df-3a90-472f-ae1e-1b9586230e71	sales_executive	Sales Executive	t	bd69f52b-cbc9-4868-aeb9-8ba6259c726f	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
8a7f8ccc-e66a-40a4-aea8-bfa236e1140c	tech_lead	Tech Lead	t	3270b7dc-9101-458c-99bc-23f14257d485	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
8e1de081-edaf-43df-87d8-e610f35698d1	qa_engineer	QA Engineer	t	3270b7dc-9101-458c-99bc-23f14257d485	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
99f5f38f-d79f-431e-a741-26c0151afaac	devops_engineer	DevOps Engineer	t	3270b7dc-9101-458c-99bc-23f14257d485	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
a2b8cb7c-03ed-40d5-9265-2441a1378d55	data_analyst	Data Analyst	t	3270b7dc-9101-458c-99bc-23f14257d485	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
ef197994-ef2d-430d-b837-4c5d7247414f	head_of_department	Head of Department	t	ba33ee6e-aeb2-47ba-902a-b1b1992f77a4	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
f733dd74-a964-458e-94ac-1bb990ccbf23	senior_software_engineer	Senior Software Engineer	t	3270b7dc-9101-458c-99bc-23f14257d485	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
f93f0c5d-a691-48f1-ac6b-d3766ea23109	engineering_manager	Engineering Manager	t	3270b7dc-9101-458c-99bc-23f14257d485	2026-09-02 11:43:06.010157+00	\N	\N	\N	\N
fdd34566-051a-487d-a985-540c2db8c37f	functional_project_management_engagement_manager	Engagement Manager	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 11:51:34.862009+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_email_domains; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_email_domains ("Id", "Code", "DomainName", "DisplayName", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
5112286a-225d-4b86-b16f-74211d9c5779	talakunchi_com	talakunchi.com	@talakunchi.com	t	1	2026-08-21 19:12:04.483485+00	\N	\N	\N	\N
a19f97e1-8bf5-4b14-823a-b653b62c2954	talakunchi_in	talakunchi.in	@talakunchi.in	t	2	2026-08-21 19:12:04.483485+00	\N	\N	\N	\N
fb66fff9-7911-47de-bde7-ab5fb5ab0757	squad1_io	squad1.io	@squad1.io	t	3	2026-08-21 19:12:04.483485+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_entra_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_entra_roles ("Id", "Code", "EntraRoleValue", "PulseRoleName", "DisplayName", "Description", "IsActive", "Priority", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
74306caa-58bf-49de-8751-934a1cb86086	entra_sales	Sales	Sales	Pulse Sales	Customers & repository	t	8	2026-09-01 06:47:03.112068+00	2026-09-01 09:16:47.912937+00	\N	\N	\N
7de6038e-b19e-443a-959a-9205a73999c5	entra_admin	Admin	Dhanshree	Pulse Admin	Full admin access	t	1	2026-09-01 06:47:03.112068+00	2026-09-01 09:16:47.912937+00	\N	\N	\N
ae03e32f-220a-4ec7-98ad-6818a75762f1	entra_hr	Hr	Hr	Pulse HR	Resources & repository	t	7	2026-09-01 06:47:03.112068+00	2026-09-01 09:16:47.912937+00	\N	\N	\N
17f505e3-a99b-4911-9849-4838df7856c4	entra_top_mgmt	Top management	BusinessOwner	Top Management	Executive oversight	t	2	2026-09-01 09:16:47.912937+00	\N	\N	\N	\N
1d8a2fce-1693-4293-873d-fe623da70f53	entra_team_member	Team member	Employee	Team Member	Assigned tasks & timesheets	t	6	2026-09-01 09:16:47.912937+00	\N	\N	\N	\N
44d89694-653c-47fc-9904-f5eae0ddaab9	entra_senior_pm	Sr. Project manager	SeniorPm	Senior Project Manager	Portfolio delivery & WBS management	t	4	2026-09-01 09:16:47.912937+00	\N	\N	\N	\N
8b1843b3-ebd5-4c77-9a86-bbd538f319ad	entra_hod	Head of Department	Hod	Head of Department	Department-wide management	t	3	2026-09-01 09:16:47.912937+00	\N	\N	\N	\N
904d9336-2b0e-46bb-ae89-3df0bb146b8b	entra_pm	Project Manager	ProjectManager	Project Manager	Project execution & allocations	t	5	2026-09-01 09:16:47.912937+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_industries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
7f460c51-01ec-4da1-8f71-d6f360b56f91	healthcare	Healthcare	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
f175fde9-14f8-40e8-b564-47d8a29d84ff	logistics	Logistics	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
c7e82721-829b-4450-8393-022587178471	energy	Energy	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
4a80bfdb-a191-4ce1-ab51-2142eb366db7	banking	Banking	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
02012f0c-97b2-4aea-a6b4-954ee97d892d	technology	Technology	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
4bf54de4-0e85-4904-a89f-542301b65077	automotive	Automotive	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
16ebeb23-b3d8-4fb7-a4f6-789510c28ad3	environment	Environment	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
935db8d7-e2aa-417e-839e-b51d00ce951e	retail	Retail	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
cd116cba-a939-4cb7-bd0f-233019a005b0	finance	Finance	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
e722474e-d845-42b8-978e-91a6ec78f080	manufacturing	Manufacturing	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
3a8e57e7-2f6d-4c84-9428-d11de98078c9	quantum_computing	Quantum Computing	t	2026-08-19 06:32:47.466308+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ff5e83cc-9c1c-4056-ab0b-42a70714ddd3	media	Media	t	2026-08-20 06:15:51.759149+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: mst_nationalities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
04b75a98-c6b8-4b0e-a7d4-42ecc057b6cc	austrian	Austrian	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
09129869-9da0-4b92-b902-bccf3b190924	german	German	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
09a35109-3ee6-47e7-9b0b-fa88c7d0ac99	new_zealander	New Zealander	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
09ed0b27-5cde-44d8-9261-3862def51411	bangladeshi	Bangladeshi	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
0cce8a7a-872b-4dcf-b93f-e970e7738b68	nepali	Nepali	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
0fa6ec80-f2ce-4e84-a033-5d1087fb0443	brazilian	Brazilian	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
167a88de-c2f2-4ade-a59f-f0fe528c8148	australian	Australian	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
1b534d63-f63c-40c4-a2aa-4a4ffb6dc84f	malaysian	Malaysian	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
24789f37-c453-4501-a58a-28d529548292	irish	Irish	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
2713bcd3-4be1-419d-9794-bfc156bb272c	finnish	Finnish	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
27649c51-f84b-4c41-98dd-088137056410	portuguese	Portuguese	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
2f45efbb-0fe4-4ff4-823a-115b4a4eebe7	thai	Thai	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
3360906d-ef37-472e-88c2-d683adeb1a3c	vietnamese	Vietnamese	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
3887a87a-8ddb-4b00-8602-b4b5924948e0	italian	Italian	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
391e969e-51f9-4f6e-84dc-999bd5388313	french	French	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
39dd28db-19c0-4825-93ab-cdf200b5293d	sri_lankan	Sri Lankan	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
3f7d49d0-78d5-4ea0-8dc8-8c2e1f38a608	qatari	Qatari	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
402a8883-1aec-4de9-9f11-5fe21f4616e4	norwegian	Norwegian	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
4573bb8a-3983-4b7e-bc35-66cdc453db63	filipino	Filipino	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
51e0b818-e56e-4620-a76d-fb0cf20276ad	singaporean	Singaporean	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
5c53c604-752e-483b-9a69-2a6e335fc95f	swiss	Swiss	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
6bbaf86c-61a5-43d4-8569-88972a5d287b	british	British	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
6c8a9602-77d6-4779-b2fd-0ad5099a8082	swedish	Swedish	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
6f17d00b-2ea6-4e76-88d6-59cdb9868042	american	American	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
72923a6d-50d4-4fee-932a-9285e3790596	japanese	Japanese	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
73179bf3-ae40-46a9-9d97-31ae9cba3ad5	mexican	Mexican	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
79686ca4-102c-456d-a08e-bdf9ac4c7a26	indian	Indian	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
7e7041fd-ea5f-4252-889f-c8397711707e	chinese	Chinese	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
8e6e00fb-5f3d-4218-a910-24781b714a15	canadian	Canadian	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
913f6079-fd2b-45cf-9be6-4097d1532c2b	south_african	South African	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
98426802-63bc-42a4-ba56-b22cc8f62d79	saudi	Saudi	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
a1e8bb9f-8857-4fa5-96ce-228d8167a680	polish	Polish	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
a62e9f44-9f08-4279-8dc9-e73b389474b9	pakistani	Pakistani	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
aa7c3e6d-be99-4998-ab70-b1efeea858b1	belgian	Belgian	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
b57f453f-4e79-401f-a410-a362cd109c7f	south_korean	South Korean	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
b7e05ed9-2278-4803-9eec-29022231e80f	danish	Danish	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
c0723df4-2f0a-4bdd-a6d8-faf6aee6d1ac	dutch	Dutch	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
edc14e22-d845-4e14-9786-259b50ebe78a	emirati	Emirati	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
f1d1979a-91bb-46cf-aec1-6dafb707fcb7	spanish	Spanish	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
fe29360e-bc38-4557-8653-98b749b34fe0	indonesian	Indonesian	t	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_offices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_offices ("Id", "Code", "Name", "WorkLocationId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_reporting_managers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_reporting_managers ("Id", "Code", "Name", "Designation", "Email", "EmployeeId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
0bf170bc-2bfd-4133-9009-d3176627e14d	riya_kapoor	Riya Kapoor	Engagement Manager	riya.kapoor@acme.co	dd7a3258-31be-425c-8771-cab8ba8b1b22	t	9	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
11e7b9b1-ad41-4198-bd80-7d136992417f	neha_kulkarni	Neha Kulkarni	Technical Lead	neha.kulkarni@talakunchi.com	\N	t	15	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
1adf0cf4-260e-4518-b152-1f892eba2070	divya_rao	Divya Rao	Product Manager	divya.rao@acme.co	a586e15e-0ad4-4d33-aa18-b1edcf241baf	t	5	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
2606f49c-5ed6-4d3c-935a-0959d610ae47	arjun_shah	Arjun Shah	Data Analyst	arjun.shah@acme.co	58198691-3595-4565-8ba6-d5f150240aa3	t	4	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
5843c0cb-ad67-4377-bc53-4d9d1a5bc761	vikram_gupta	Vikram Gupta	Project Manager	vikram.gupta@acme.co	c15b2b43-0884-4999-bece-9289d1db561f	t	11	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
5ad3ffbf-606b-41f9-a34b-8b4cef837d60	rajesh_iyer	Rajesh Iyer	Delivery Manager	rajesh.iyer@talakunchi.com	\N	t	18	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
7f34be9a-66a0-48ee-922b-7994f2eb7cd0	harsh_nair	Harsh Nair	Business Analyst	harsh.nair@acme.co	18b83048-56d5-4365-8bc5-3ba65405467e	t	6	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
8b96778e-13d5-4ab1-ace6-31c6acc88bbb	ankit_verma	Ankit Verma	UX Designer	ankit.verma@acme.co	fc06e810-3e2d-4510-bfc1-669ccf579da2	t	2	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
91f99333-18be-400c-838d-0fe6c171f86e	arjun_mehta	Arjun Mehta	Engagement Manager	arjun.mehta@acme.co	230058bf-ed8a-45da-8d77-4a2821a0a76a	t	3	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
9ef6ec60-9d29-44c2-b0b4-773ba5ae99b1	vikram_deshmukh	Vikram Deshmukh	Director of Product	vikram.deshmukh@talakunchi.com	\N	t	13	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
b7c28347-fe03-4034-9d63-0348a05f85b1	aisha_rao	Aisha Rao	VP of Engineering	aisha.rao@talakunchi.com	\N	t	12	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
b838f751-d684-4c98-a20f-2d656fd09553	ananya_sharma	Ananya Sharma	Lead Architect	ananya.sharma@talakunchi.com	\N	t	17	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
bd239c0a-2dbe-4b43-831e-1607691606c9	pradeep_singh	Pradeep Singh	Engagement Manager	pradeep.singh@acme.co	8a50b4b9-7091-423c-ac8c-af55bc6df348	t	7	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
cbab65ee-e7b4-44e4-9641-3717342c9d88	aanya_joshi	Aanya Joshi	Sales Executive	aanya.joshi@acme.co	593b0378-d20a-40ee-b0a0-ae4acc0a78aa	t	1	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
e0043efa-276b-4b9b-9f1f-9e5349de06b1	sneha_iyer	Sneha Iyer	Tech Lead	sneha.iyer@acme.co	8e97c526-8c79-44c6-a23f-ece0d9b21df5	t	10	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
e206ba0c-38af-45c3-aa46-103dbf3cb45f	rahul_sharma	Rahul Sharma	Engagement Manager	rahul.sharma@acme.co	9a15533f-f863-44a7-b61c-b978fa1f5174	t	8	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
ef80f744-ce30-4db8-ae93-05cd00d748e0	rohan_verma	Rohan Verma	Engineering Manager	rohan.verma@talakunchi.com	\N	t	14	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
f0d6d5a1-bc56-4f3c-8ad5-027bb2f935c4	devansh_shah	Devansh Shah	Head of Design	devansh.shah@talakunchi.com	\N	t	16	2026-08-21 19:30:26.29718+00	\N	\N	\N	\N
141f0e6a-7f0b-4fdc-8e48-117012ef17d2	pranjali_shah	Pranjali Shah	Employee	pranjali@talakunchi.io	b78530f0-0687-4f26-a614-8318c62901f9	t	6	2026-08-21 19:57:33.765567+00	\N	\N	\N	\N
27ea58af-8649-413b-b68f-5ab8d7ae9e0b	nikhil_khanna	Nikhil Khanna	Sales Executive	nikhil.khanna@acme.co	8065ff15-64d6-4f36-a003-f0444a620bd8	t	4	2026-08-21 19:57:33.765567+00	\N	\N	\N	\N
332f42c5-cbe4-4616-bdef-f1c5ed4f525c	ishita_bansal	Ishita Bansal	UX Designer	ishita.bansal@acme.co	7c9168b9-8269-430b-89d8-a1ba0b8e99af	t	2	2026-08-21 19:57:33.765567+00	\N	\N	\N	\N
56290531-8a9f-4280-a611-7a056595cf04	pooja_menon	Pooja Menon	HR Business Partner	pooja.menon@acme.co	81c42f4c-b588-4037-a106-47f339a777f6	t	5	2026-08-21 19:57:33.765567+00	\N	\N	\N	\N
9e9286c4-8f25-47e2-8bf9-37620fbcb726	kavya_desai	Kavya Desai	Content Strategist	kavya.desai@acme.co	3dcb0f17-b94a-470c-ba85-86ac0f1c65c8	t	3	2026-08-21 19:57:33.765567+00	\N	\N	\N	\N
e2ea7517-353b-40d9-be27-0fbe07d6c963	ira_kapoor	Ira Kapoor	QA Engineer	ira.kapoor@acme.co	d24cafbe-bb30-4522-93b2-25588511f0e2	t	1	2026-08-21 19:57:33.765567+00	\N	\N	\N	\N
230610a9-f798-4d1d-bf8e-86471c438c9b	samar_patel	Samar Patel	HR Business Partner	samar.patel@acme.co	f7404cb8-5d1a-40bf-b690-22cf179320dd	t	2	2026-08-22 05:01:40.262867+00	\N	\N	\N	\N
602e1a4a-f54a-4b9d-bd55-4e5f86d530c9	yash_malik	Yash Malik	Software Engineer	yash.malik@acme.co	f8258beb-f446-477d-bb7e-69666c5fe314	t	3	2026-08-22 05:01:40.262867+00	\N	\N	\N	\N
a72d8337-b9ca-41b7-add3-33420d5fa811	priya_shah	Priya Shah	Onboard Role f918b0f6	priya.shah.839199831f3541eda878b9f48a7f9743@acme.co	eb10f37d-b64f-4b17-976b-b962645514f2	t	1	2026-08-22 05:01:40.262867+00	\N	\N	\N	\N
81c1b328-1aab-4495-93b1-d30ac84cfafe	sample_employee	Sample Employee	Software Engineer	sample.employee@talakunchi.com	d9903fec-2d9e-4544-ad6a-170173d41c17	t	1	2026-08-31 04:50:42.205291+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
6032fef5-eb05-42bd-9f10-72f12e154243	services_operations_soc_shift_lead_i_team_leader_tl_	Team Leader (TL)	t	444df30d-c195-42ad-b9a7-d80cdef69ccd	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
8366d816-724b-456b-9d0e-85399c2324b7	services_operations_soc_lead_i_team_leader_tl_	Team Leader (TL)	t	b5f39dd8-c305-489d-9f7d-9adfd010a134	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
412826f2-67b6-47c9-a62c-270fa9425ce4	functional_sales_director_product_sales_team_member_tm_	Team Member (TM)	t	6193be76-40ad-4973-9ee7-246a4d8f4109	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
d0b9d2a2-d79c-4097-ae63-4bff14436d0a	functional_sales_sales_associate_team_member_tm_	Team Member (TM)	t	e2c675a7-92dc-4477-be75-9a304cbe4def	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
1c1c9112-592b-4f23-92d5-213a5da0d78d	functional_it_admini_desktop_support_engineer_i_team_member_tm_	Team Member (TM)	t	c70b9832-841e-4864-9b85-eaba3c0a995f	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
16f2557a-02c9-4208-a570-55a909532abe	functional_accounts_senior_accountant_ii_manager_mng_	Manager (Mng.)	t	96efad7d-8b7f-4d7f-a862-c0a6bec3789f	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
3efb18e5-f8d5-4de9-8959-ab5401f64b74	services_consulting_grc_auditor_iv_team_member_tm_	Team Member (TM)	t	7c2380da-3ee6-46ad-93d6-a79ce3027f29	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
40354601-9ac5-41e0-9ddb-6603e5614a86	services_consulting_grc_auditor_iii_team_member_tm_	Team Member (TM)	t	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
6886e92b-a2c5-4057-9330-47394a2aac65	services_consulting_grc_auditor_ii_team_member_tm_	Team Member (TM)	t	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
cc4e4c23-fccc-44ba-8423-5e4e6ec35731	functional_hr_recruitment_coordinator_ii_hr	HR	t	c2e248c8-e917-445f-9f7b-1e25d7bb5abe	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
21eac166-3ba7-40c5-a780-bbc7b3e96ddb	functional_sales_associate_customer_success_representative_ii_team_member_tm_	Team Member (TM)	t	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
db77e167-7f67-43f6-9e2d-4ebaf6f9f802	functional_project_m_delivery_account_manager_ii_team_member_tm_	Team Member (TM)	t	d8a2b9e5-f54d-4344-a78d-c6c840467543	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
6c0bebbb-cc4d-4433-83e9-d65fb5291d75	services_consulting_intern_team_member_tm_	Team Member (TM)	t	2076a9b1-e432-46a9-99b1-36e732159856	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
913e691d-e3f9-4f9a-aab8-57eda52a8cd6	functional_it_admini_desktop_support_engineer_ii_team_member_tm_	Team Member (TM)	t	73bd55bb-5d0e-4381-8ad2-2238377fca93	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
1e17c9f0-a8ed-4d89-819d-738a84af4e48	functional_hr_senior_hr_executive_ii_hr	HR	t	e4e20503-cd55-4393-83fd-6c7e7d7d0a49	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
ea40e2b6-035a-4766-96bc-13ad013020c1	services_operations_soc_analyst_iv_team_member_tm_	Team Member (TM)	t	0c1a5ef4-7fca-45dc-8253-87afa21a1df9	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
401a442f-98c4-4b95-9e07-647853bf9122	rd_research_and_deve_python_developer_ii_team_member_tm_	Team Member (TM)	t	3356f353-1566-4df6-9958-fa01d67d13c7	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
52ae8b5b-80b3-4d14-b8c5-0bc40e1f4bee	services_consulting_associate_manager_iii_manager_mng_	Manager (Mng.)	t	195d6a81-8457-4b60-9382-6a3a0664f0e9	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
31ebb23e-f7d1-4c01-859b-67d24e96e2fb	services_operations_soc_lead_ii_team_leader_tl_	Team Leader (TL)	t	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
24ccdefb-8dd5-411e-8b2e-af8fb743a3cb	services_operations_soc_consultant_i_team_member_tm_	Team Member (TM)	t	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
8ea442c3-8ed7-4b6a-a3db-dd74706e9cce	services_testing_devsecops_practitioner_ii_team_member_tm_	Team Member (TM)	t	35a6b1af-dc78-4632-a9f4-eedabdbdcb52	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
218cd458-a6bc-43f8-8eda-02c89193fc35	services_operations_soc_shift_lead_ii_team_leader_tl_	Team Leader (TL)	t	c0f974c3-f49c-449a-9276-aa64ce501344	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
6c1b3c1d-4159-41b9-9171-1e4f2501cc32	functional_project_m_intern_team_member_tm_	Team Member (TM)	t	9050e021-7d84-4401-820e-c0e768abb1ab	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
da46be38-b216-44cc-8b6d-70cd4b0aea8e	services_operations_siem_admin_iv_team_member_tm_	Team Member (TM)	t	e36018c5-bf48-4f93-bef7-93e8864a0b51	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
33f2483b-b264-4ec4-857a-205426a8af0f	functional_accounts_accountant_i_manager_mng_	Manager (Mng.)	t	155642eb-a633-4460-b658-aca9fde2d817	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
48079f83-fbf9-4639-ae6b-263ca3fb752a	functional_project_m_associate_pmo_i_team_member_tm_	Team Member (TM)	t	b3309eea-7374-4a8d-ac13-481b2a7fd492	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
da59e567-3ee0-4a98-9b1e-83f8e6c01e2c	services_testing_associate_manager_i_team_leader_tl_	Team Leader (TL)	t	e228c999-bf54-48b4-a373-d2bc9db88554	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
1d19d6af-78b4-45ef-bcb3-db1b3896f153	services_operations_intern_team_member_tm_	Team Member (TM)	t	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
446498d0-e9e6-4dbb-8fbe-b87bb853a2af	functional_project_m_senior_pmo_i_team_leader_tl_	Team Leader (TL)	t	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
6b361aa9-a47a-4fed-9d1f-07a4e1dd5f30	functional_hr_recruitment_coordinator_i_hr	HR	t	7d542941-65b9-499b-81b3-239748d6da52	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
c7d75b92-f6e2-4dd7-a726-ae662ee83c95	functional_hr_hr_head_hr	HR	t	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
5378a1ad-7ab3-40e5-9048-5165efab2140	services_testing_senior_pentester_ii_team_member_tm_	Team Member (TM)	t	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
a3d0a1e1-b4a8-4ae5-8577-cd2019268494	services_testing_associate_manager_iii_manager_mng_	Manager (Mng.)	t	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
22215465-c056-4ba4-a867-23ed37658a09	services_consulting_senior_grc_auditor_i_team_leader_tl_	Team Leader (TL)	t	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
9c970783-5b89-4fd0-b3f3-1c1953a853ab	services_operations_soc_analyst_ii_team_member_tm_	Team Member (TM)	t	48429bb5-c583-4684-b30a-7ed443b671ca	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
4e547334-4964-4dbe-81a4-a316d9394d03	services_testing_devsecops_practitioner_i_team_member_tm_	Team Member (TM)	t	ae255622-ddcc-45ea-a699-8ec416fe57ab	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
57b9b89d-9123-4bd0-b8fd-a373e0648f43	functional_project_m_senior_delivery_account_manager_i_team_leader_tl_	Team Leader (TL)	t	8b57cfd5-5d4e-44a3-9646-b36873c111c2	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
8ab74d70-fc77-4767-87ce-13a6d3f911ce	services_testing_senior_cloud_security_consultant_i_manager_mng_	Manager (Mng.)	t	8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
859254f8-a1b4-4812-b1d0-aacf111f7235	rd_research_and_deve_intern_team_member_tm_	Team Member (TM)	t	bb7ccd5f-2f60-49fb-b984-f11fc47add22	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
70206c08-0203-4784-8b09-d04d0cff95af	services_testing_devsecops_practitioner_iii_team_member_tm_	Team Member (TM)	t	767a00dd-6f09-4f64-a44e-8fbe901222af	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
f37fa8d5-1c48-4038-95d5-cd7dfea12085	functional_accounts_senior_accountant_i_manager_mng_	Manager (Mng.)	t	4ef1cb5b-9688-4ce2-95b3-6a0863200166	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
3f413c39-a269-4d44-9f3c-9e7f6e3ecced	services_operations_soc_analyst_iii_team_member_tm_	Team Member (TM)	t	f20a7445-0b01-4f20-85a5-853101d864ee	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
178985be-3d47-4903-983b-3a581e788e61	services_operations_siem_admin_iii_team_member_tm_	Team Member (TM)	t	af8a1442-c5ee-409d-aa91-61c9dba852ee	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
c45f4397-0370-43f5-98c7-f419234fa6d8	services_testing_red_team_practitioner_iii_team_member_tm_	Team Member (TM)	t	85cc9fbe-98a4-464d-a638-05f40529c6de	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
ebdc343e-9f43-4715-8a37-4861594c4b0a	functional_hr_senior_hr_executive_i_hr	HR	t	485012d4-2c28-4bc4-92c7-3609e3e3749e	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
98e28e22-95e4-41ee-9178-2912de24f21a	functional_accounts_intern_team_member_tm_	Team Member (TM)	t	caa227a1-2dcf-4195-ab9c-8f76d1862daa	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
568997bf-75a1-46d9-9bdb-6fc05c3b2be1	services_testing_pentester_iii_team_member_tm_	Team Member (TM)	t	163d8c87-8f90-4295-a926-2e912c625a1c	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
20d077b9-894b-4bf3-b491-5df765e645f0	services_testing_associate_manager_ii_team_leader_tl_	Team Leader (TL)	t	168d11d7-ca26-4d61-b870-51779dc63023	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
5a206a6a-dabc-4dfe-b28f-00cc01bc11da	services_testing_red_team_practitioner_ii_team_member_tm_	Team Member (TM)	t	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
074ea1a8-d519-4cda-87a4-978cd1eec45a	services_consulting_grc_auditor_i_team_member_tm_	Team Member (TM)	t	1e7faab8-273d-40df-9f9a-485160186c5a	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
61cc6cff-4f61-4a1d-90f5-9eb9f61c54f3	services_consulting_principal_manager_i_sr_manager_sr_mng_	Sr. Manager (Sr.Mng.)	t	dadac355-1ddc-457c-935a-d297da3a883d	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
95337b72-6733-48f5-ba8c-cd2afbcbc1e4	functional_accounts_accountant_ii_manager_mng_	Manager (Mng.)	t	8dc0d8fe-593d-422a-8b27-5b68fbe6d224	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
3e28d4a4-7d87-41ed-b921-a39dd937df76	functional_sales_associate_customer_success_representative_i_team_member_tm_	Team Member (TM)	t	272973a6-c052-4aef-bf32-9e24f7eb6cc9	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
b4e88d70-1263-47af-96a9-203ee422e8b1	services_operations_soc_consultant_ii_team_member_tm_	Team Member (TM)	t	911f6d7f-8d43-40f2-897a-2f416abf8cf9	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
9fb9b5b5-bc14-4597-8953-7a1ea10dc0dd	functional_project_m_delivery_account_manager_i_team_member_tm_	Team Member (TM)	t	834c9e15-c70d-4a0b-bb12-5e55f23c181d	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
111000c1-ff0c-499c-a9cb-34febe2ac32d	services_testing_devsecops_associate_team_leader_tl_	Team Leader (TL)	t	c6c6cd04-6df3-4593-b686-e4b9d362c96f	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
ee402c9b-252b-4eec-8880-7a4a159eac92	rd_research_and_deve_python_developer_iii_team_member_tm_	Team Member (TM)	t	9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
f43fddea-4dd9-4603-a79c-1710224115ae	functional_it_admini_intern_team_member_tm_	Team Member (TM)	t	f8502c44-b289-49e4-8401-3dcad4d5bbe0	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
94fc014e-37ce-4eb4-8588-ff56a79be98e	core_director_and_chief_executive_officer_leader_l_	Leader (L)	t	778f1120-9633-4933-9160-ddaa46668838	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
3000065e-1037-4a6b-a87a-4c461a756531	services_operations_siem_admin_i_team_member_tm_	Team Member (TM)	t	ea315f7d-d597-41b3-a999-4f3851bcd020	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
1cf32162-d510-4a26-a017-e2035425dc93	functional_project_m_senior_pmo_ii_manager_mng_	Manager (Mng.)	t	138434a2-625f-4df5-836d-fcf0cfceef79	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
6b840581-65b6-4e1d-916f-38b6018e07e0	services_consulting_senior_vice_president_principal_consultant_head_of_departmen	Head Of Department (HOD)	t	2b1558e3-158a-4a84-ae80-053129861a64	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
0b340900-7bd0-4931-8978-832c678c7cbd	functional_sales_intern_team_member_tm_	Team Member (TM)	t	e2b10def-c91d-45da-94c5-f5530e743aa2	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
4e574ffd-c3a9-4a15-832a-5dabfb352dc3	services_consulting_senior_grc_auditor_ii_team_leader_tl_	Team Leader (TL)	t	3e60b693-d3dd-4481-95c4-9f02da21625c	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
8ec384d1-5b99-45c9-a95d-8f3325f56ea4	services_testing_associate_manager_iii_team_leader_tl_	Team Leader (TL)	t	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
a3986a0e-d20f-4f20-a648-adcc724bb622	services_testing_manager_i_sr_manager_sr_mng_	Sr. Manager (Sr.Mng.)	t	a697a798-caaf-4248-8e4e-7e89096a9c30	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
86a621fc-db0d-4e12-96c5-2af111964ef5	services_consulting_associate_manager_iii_team_leader_tl_	Team Leader (TL)	t	195d6a81-8457-4b60-9382-6a3a0664f0e9	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
fdf924c8-3a4a-40bb-9bf9-ea42d4946ecb	rd_research_and_deve_python_developer_i_team_member_tm_	Team Member (TM)	t	f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
fc382efa-48c8-4cc3-a724-2e54c1d6d6e0	services_testing_associate_ai_engineer_contractual_team_member_tm_	Team Member (TM)	t	e2b4be77-2b20-4064-974d-e6322e7240b4	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
9225698b-9ecd-4dfb-9008-fe08b395efc9	functional_accounts_senior_accountant_iii_manager_mng_	Manager (Mng.)	t	1f97b442-95c5-4b11-93a0-ea146534ae85	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
a583ec5f-f30a-4b03-9e35-6afc3f1aee8d	services_testing_devsecops_specialist_ii_manager_mng_	Manager (Mng.)	t	c1fa4328-a970-48a1-bc08-d50fe36bf44c	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
3dd672a7-e6a9-42c8-bdbf-4d1340efc1da	core_director_and_chief_operating_officer_leader_l_	Leader (L)	t	ffed7aa1-e88f-4281-919f-8d49fbabf5a5	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
736d1ddd-c56a-4c4f-b266-bc4f6be6ed9c	services_testing_senior_pentester_i_team_member_tm_	Team Member (TM)	t	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
b3a66833-fc6b-4bac-9438-959333107d3c	functional_project_m_senior_delivery_account_manager_ii_manager_mng_	Manager (Mng.)	t	9dc69952-eae6-4ec0-a327-67392315f089	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
c0cdbff8-5ed6-4e49-a562-549aecaacfd7	services_testing_red_team_specialist_ii_manager_mng_	Manager (Mng.)	t	4b680e29-b4fb-4689-9afb-67a7f089f52b	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
4ca2ade8-8da6-46d7-a7ec-1124e0229d9e	functional_accounts_accountant_iii_manager_mng_	Manager (Mng.)	t	6e606c29-2ebf-4ab8-8006-aaedd5680009	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
9de62ea5-b7da-4a55-8b54-056fdf6bc621	functional_sales_business_development_associate_i_manager_mng_	Manager (Mng.)	t	b2b687ef-fd62-4cb7-a826-b40a35da7b2c	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
eaa98dba-df5b-4b1d-b2d5-20b159a0a070	services_operations_soc_analyst_i_team_member_tm_	Team Member (TM)	t	6d25ff6d-e13d-440f-b775-215547af7acb	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
2cd464a5-b857-46fc-89ea-5dea92640964	services_testing_pentester_ii_team_member_tm_	Team Member (TM)	t	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
0997a260-4ca3-4eb2-b87a-4bd6bf235677	services_operations_siem_admin_ii_team_member_tm_	Team Member (TM)	t	4650d4e0-f73c-4688-ae5f-830a46348ff9	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
eda2ca5a-d2b1-45db-94cc-4575f0eda8dc	functional_it_admini_it_admin_team_member_tm_	Team Member (TM)	t	da990f6e-3379-4cc4-89b7-0ead29da472b	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
7b597cd0-0153-4ddb-a7b2-f553cbafc8a9	functional_sales_customer_success_representative_ii_manager_mng_	Manager (Mng.)	t	157d001c-b056-45b1-96a3-3c05bcd8d99c	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
caec3c96-23a0-4e88-845c-05f792d0dd0c	services_testing_associate_project_manager_manager_mng_	Manager (Mng.)	t	3b7ea453-324e-40a0-bb41-77a0795d5af5	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
a955782d-de73-4939-94f8-5cbf9a2461c2	services_testing_pentester_i_team_member_tm_	Team Member (TM)	t	4f972924-350a-47fb-a6b6-f2b34bb6b621	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
7bd6b8a7-be33-43ba-b4d7-4d290e71b91e	functional_hr_intern_team_member_tm_	Team Member (TM)	t	e8c22eff-0daf-4690-a537-c8b0b6110a01	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
0028e31d-d2ff-4a71-b5b2-5f0566961d46	core_director_and_chief_technology_officer_leader_l_	Leader (L)	t	0525d830-ead9-44a0-871f-91b7845fec26	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
32d7cead-40d2-4d94-89fb-3e48d4160b7c	services_testing_intern_team_member_tm_	Team Member (TM)	t	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
3db9d726-85c9-4714-8c95-b5c6ebd45fd4	services_testing_pentester_iv_team_member_tm_	Team Member (TM)	t	9858c224-f97f-4ff8-908d-f46bd5e2243c	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
f67d5930-703b-4497-a4ea-2add60f7fb58	functional_project_m_associate_pmo_ii_team_member_tm_	Team Member (TM)	t	2a76927c-461a-48e4-8190-dea7361ef3db	2026-09-03 11:55:46.803606+00	\N	\N	\N	\N
004a9abf-3c3d-4f95-8693-7bb4d7e0adb5	business_analyst_consultant	Consultant	t	439f1691-f596-44a4-85cc-b4b7a4b4a678	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
01dd4fea-967f-407b-9519-56fa8b803f10	finance_analyst_accounts	Accounts	t	1f90151f-a934-4388-ad0d-d6928de8c78e	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
0b80a829-1503-4bb7-85ca-e23a699c063e	devops_engineer_employee	Employee	t	99f5f38f-d79f-431e-a741-26c0151afaac	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
0f655c9d-c8a5-44fa-8180-64b63386ec3c	finance_analyst_analyst	Analyst	t	1f90151f-a934-4388-ad0d-d6928de8c78e	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
11f5418f-ba07-4879-8f1b-6fb35b1a91bd	data_analyst_employee	Employee	t	a2b8cb7c-03ed-40d5-9265-2441a1378d55	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
12f71b72-995d-43ac-9db7-c7c706e2091e	qa_engineer_qa_analyst	QA Analyst	t	8e1de081-edaf-43df-87d8-e610f35698d1	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
1452d78f-0e40-4514-820a-5e48948e367a	marketing_lead_campaign_lead	Campaign Lead	t	12fae3b9-3ff8-470a-9e98-8857e1e7cd2b	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
145b13d9-c9be-47ea-807c-66da1fea6b31	ux_designer_employee	Employee	t	1d97a91f-7a7f-4270-b427-5b746f3cdbce	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
1584e532-a884-4601-9893-fd152bf35485	qa_engineer_test_engineer	Test Engineer	t	8e1de081-edaf-43df-87d8-e610f35698d1	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
2bd6f610-e01c-4b29-bdab-7cf89163f2fa	project_manager_delivery_manager	Delivery Manager	t	05b0acef-feb2-42b7-8d4b-6aa0e6e7db05	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
379cb7a3-a3db-4aa4-a6f3-e35cb06e386c	senior_software_engineer_senior_developer	Senior Developer	t	f733dd74-a964-458e-94ac-1bb990ccbf23	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
39795efd-5af8-4881-807c-5ede9a2d0374	ux_designer_designer	Designer	t	1d97a91f-7a7f-4270-b427-5b746f3cdbce	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
403fe14b-17fc-4d50-82ae-1816beffecac	sales_executive_sales	Sales	t	576b74df-3a90-472f-ae1e-1b9586230e71	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
40b3b703-75e5-4a6f-bce9-942cb6b0eba3	business_analyst_analyst	Analyst	t	439f1691-f596-44a4-85cc-b4b7a4b4a678	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
42cbc170-3f3d-44e2-a0e6-f7e5d5a8575d	devops_engineer_devops_specialist	DevOps Specialist	t	99f5f38f-d79f-431e-a741-26c0151afaac	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
468f8a77-81f3-4338-b476-dd91a087eae0	hr_business_partner_hr	Hr	t	50fe7edc-ec15-440a-b900-474670e84dc1	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
4c0f347d-8be5-4747-9de7-b7ed19a4da93	senior_project_manager_program_manager	Program Manager	t	50cbd605-9143-4722-b70d-7067bd298398	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
59349349-c665-42f0-a4e4-b3f359d3c26f	qa_engineer_employee	Employee	t	8e1de081-edaf-43df-87d8-e610f35698d1	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
5be6e020-5fcd-444b-a0a1-f910f9d76c1e	senior_software_engineer_specialist	Specialist	t	f733dd74-a964-458e-94ac-1bb990ccbf23	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
5db49441-a720-42e4-bed9-669959db07f5	engagement_manager_engagement_manager	Engagement Manager	t	4ef3d669-21ca-43ab-a132-db6b00c6063f	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
5e04d504-3120-48d7-8231-8b2c55b2f005	sales_executive_account_executive	Account Executive	t	576b74df-3a90-472f-ae1e-1b9586230e71	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
62c49ea9-0c93-4421-9fb1-5de3ea246be7	product_manager_product_owner	Product Owner	t	0bc97b9b-89ee-436c-a649-d5d6826c3566	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
647ad99d-f96a-412e-acf5-3c1683f72a17	head_of_department_director	Director	t	ef197994-ef2d-430d-b837-4c5d7247414f	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
69243eef-93bc-4af0-9a41-7b7d9c32939a	marketing_lead_marketing_lead	Marketing Lead	t	12fae3b9-3ff8-470a-9e98-8857e1e7cd2b	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
6ba60a38-7d46-41c7-8902-105659da3184	product_manager_product_manager	Product Manager	t	0bc97b9b-89ee-436c-a649-d5d6826c3566	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
79d2294b-d981-4f9d-858d-b8144b892a73	tech_lead_technical_lead	Technical Lead	t	8a7f8ccc-e66a-40a4-aea8-bfa236e1140c	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
7ef8d1bc-3e0e-402d-abcf-d3250b6227ed	senior_project_manager_senior_project_manager	Senior Project Manager	t	50cbd605-9143-4722-b70d-7067bd298398	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
8dbe04c2-97d8-4a8d-8425-459d66e74170	product_manager_projectmanager	ProjectManager	t	0bc97b9b-89ee-436c-a649-d5d6826c3566	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
906e0e89-0912-448f-9d00-8114487ea77e	ux_designer_ux_specialist	UX Specialist	t	1d97a91f-7a7f-4270-b427-5b746f3cdbce	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
90d4d9f9-c5ee-41ad-b5ed-c24de07bf32a	software_engineer_developer	Developer	t	086214cd-983a-42c5-8e3e-f6ced781d142	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
929be827-5f8b-42e6-a44c-d1bd88d55e10	engineering_manager_people_manager	People Manager	t	f93f0c5d-a691-48f1-ac6b-d3766ea23109	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
95055735-a100-4919-be3b-aad28304b440	business_analyst_pmo	Pmo	t	439f1691-f596-44a4-85cc-b4b7a4b4a678	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
9832aa7e-e48f-4203-902b-cf4e1c53d9f6	software_engineer_associate_engineer	Associate Engineer	t	086214cd-983a-42c5-8e3e-f6ced781d142	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
af7ebefc-47b3-4b8b-8f60-825e55babdb0	senior_software_engineer_employee	Employee	t	f733dd74-a964-458e-94ac-1bb990ccbf23	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
b56affc2-cbf3-4dcd-bac3-5b7e01602e71	project_manager_projectmanager	ProjectManager	t	05b0acef-feb2-42b7-8d4b-6aa0e6e7db05	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
b833bb0f-e45c-4592-983e-4ad490b40ebc	software_engineer_employee	Employee	t	086214cd-983a-42c5-8e3e-f6ced781d142	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
bbd536fb-575e-42db-b10a-f21103345874	head_of_department_head_of_department	Head of Department	t	ef197994-ef2d-430d-b837-4c5d7247414f	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
be949732-a4fe-4b90-8f1e-0682a61befa0	tech_lead_teamlead	TeamLead	t	8a7f8ccc-e66a-40a4-aea8-bfa236e1140c	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
c16fd140-99f0-4f64-a17f-5d5d7fa80020	hr_business_partner_business_partner	Business Partner	t	50fe7edc-ec15-440a-b900-474670e84dc1	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
d472318a-e053-4718-923a-21b60d760d1c	data_analyst_data_specialist	Data Specialist	t	a2b8cb7c-03ed-40d5-9265-2441a1378d55	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
e17e9fca-15cc-4fd2-8fea-928858ef2108	data_analyst_analyst	Analyst	t	a2b8cb7c-03ed-40d5-9265-2441a1378d55	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
e4773d24-c7b3-437e-89a0-befba1923bae	tech_lead_module_lead	Module Lead	t	8a7f8ccc-e66a-40a4-aea8-bfa236e1140c	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
ec6c1244-69e1-4bdd-a402-c3ca901e479a	content_strategist_employee	Employee	t	2f632e1b-f9f3-429d-8afb-accbed71b789	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
f15bafb9-18df-4db1-8b3c-17dcb870f1bc	content_strategist_strategist	Strategist	t	2f632e1b-f9f3-429d-8afb-accbed71b789	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
f6fb10fa-3cea-4471-af96-22ff238fe8b0	engagement_manager_client_partner	Client Partner	t	4ef3d669-21ca-43ab-a132-db6b00c6063f	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
f73661f1-1621-47e5-ba0d-ab01a10df42e	engineering_manager_engineering_manager	Engineering Manager	t	f93f0c5d-a691-48f1-ac6b-d3766ea23109	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
fa96ceb6-819c-45c7-b8af-e97e794c967a	devops_engineer_sre	SRE	t	99f5f38f-d79f-431e-a741-26c0151afaac	2026-09-03 11:57:27.881775+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_salary_bands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_salary_bands ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
20ffbe9b-96ca-496e-ab2e-50ccf3c91246	l3	L3	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
37016f9a-2474-400d-99ae-18157aaad035	l1	L1	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	l4	L4	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
e5f5511b-dea6-421c-8c0e-b271e4ee5d43	l5	L5	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
ebed343e-301f-4984-b292-fa8d1cb1623c	l2	L2	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_work_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_work_locations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
58e569dc-cb93-4832-bf22-2e8d4836dc65	onsite	Onsite	t	1	2026-09-03 12:26:58.067087+00	\N	\N	\N	\N
3bc10d7b-a705-4ec9-b7b5-71858572a8cc	suvidha_square_andheri	Suvidha Square, Andheri	t	2	2026-09-03 12:26:58.067087+00	\N	\N	\N	\N
8d0b23a2-9459-4fbe-a7bf-624abd410c40	navare_plaza_dombivli	Navare Plaza, Dombivli	t	3	2026-09-03 12:26:58.067087+00	\N	\N	\N	\N
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_tokens ("Id", "UserId", "TokenHash", "ExpiresAtUtc", "RevokedAtUtc", "ReplacedByTokenHash", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
15d68cf7-8b84-47a1-8955-96d5644ef160	40517b71-5e62-182e-73b5-d4070e20a3c2	m2ID5SzqvM55MmSAx5jK2Osea/gqcMgZGlQ5SxiLiXY=	2026-08-14 07:50:13.983139+00	2026-08-07 07:55:35.251961+00	\N	2026-08-07 07:50:14.000986+00	2026-08-07 07:55:35.291997+00	\N	\N	\N
7d8336f1-caa0-4eab-b521-b6e37ecb2fe2	40517b71-5e62-182e-73b5-d4070e20a3c2	Lh721AXKdC8QTtH2bEoCjkEnfqEFclsMeMc2vNcEIDE=	2026-08-14 07:55:35.274591+00	2026-08-07 07:55:45.608051+00	\N	2026-08-07 07:55:35.291997+00	2026-08-07 07:55:45.608981+00	\N	\N	\N
a9b3cd3f-7d7a-4d92-a1d4-29869153ecde	40517b71-5e62-182e-73b5-d4070e20a3c2	uATHu5oTwYUU6HQcHouy14HKfbmM+q4WUJHD24EMbaQ=	2026-08-14 07:55:45.608283+00	2026-08-07 07:55:56.695427+00	\N	2026-08-07 07:55:45.608981+00	2026-08-07 07:55:56.69573+00	\N	\N	\N
e46e62bc-123e-4f1d-830e-38ad2d8f144e	40517b71-5e62-182e-73b5-d4070e20a3c2	bla5iEYpO+U/IPBo/oYud7T3Q1PRmxvPMmC/BLWFdxM=	2026-08-14 07:55:56.695595+00	2026-08-07 07:56:41.762854+00	\N	2026-08-07 07:55:56.69573+00	2026-08-07 07:56:41.763254+00	\N	\N	\N
82642a2f-5ed7-42b8-938a-1026a17f273d	40517b71-5e62-182e-73b5-d4070e20a3c2	wo1yPN8gZeM+oOqd23YmtJS70HsomIwjFAbsQTEQXJw=	2026-08-14 07:56:41.763061+00	2026-08-07 07:56:51.579036+00	\N	2026-08-07 07:56:41.763254+00	2026-08-07 07:56:51.579255+00	\N	\N	\N
68944323-a9a0-4aa2-a3b5-92acecbed48a	40517b71-5e62-182e-73b5-d4070e20a3c2	0qzfThbGiooWBYFneOyxIeqMyK8s+R5/uCA2HGXiUKs=	2026-08-14 07:56:51.579171+00	2026-08-07 07:57:01.950475+00	\N	2026-08-07 07:56:51.579255+00	2026-08-07 07:57:01.950745+00	\N	\N	\N
2f2117e8-deb5-454b-9041-9336b5b8be73	e7554ba2-e546-93ce-1e88-a073badd78a2	+GL/dmLCznwpTJje8asLaMIvbWpXSvU8wovOGdBV4s4=	2026-08-14 07:57:02.689669+00	2026-08-07 07:57:03.004561+00	\N	2026-08-07 07:57:02.689818+00	2026-08-07 07:57:03.004918+00	\N	\N	\N
767e68c4-d982-4694-ba7a-b75d34e2abb4	e7554ba2-e546-93ce-1e88-a073badd78a2	lTEYUjW8dATIBSMzYqsETRP42J8jfpwwHDHJ6Eui0Wk=	2026-08-14 07:57:03.004798+00	2026-08-07 07:57:03.56644+00	\N	2026-08-07 07:57:03.004918+00	2026-08-07 07:57:03.56645+00	\N	e7554ba2-e546-93ce-1e88-a073badd78a2	\N
57540e48-c2e1-48ec-bb9c-f5478fa1359f	e7554ba2-e546-93ce-1e88-a073badd78a2	ATm4KuIOOCVexxs5tnhPe9/pl4bvRJnYZpHHaHX8u+c=	2026-08-14 07:57:04.149816+00	\N	\N	2026-08-07 07:57:04.149909+00	\N	\N	\N	\N
2d587391-30e6-408d-9bdb-11f50daf0f9b	40517b71-5e62-182e-73b5-d4070e20a3c2	UiAJaRaM0NPSuOjPIpPTOj2pWaukHkvw5MuT+iBDssk=	2026-08-14 07:57:01.950681+00	2026-08-07 08:00:34.623822+00	\N	2026-08-07 07:57:01.950745+00	2026-08-07 08:00:34.624134+00	\N	\N	\N
13b2b9df-9c94-4564-a43e-c12542578167	40517b71-5e62-182e-73b5-d4070e20a3c2	PEqTPFJunMCrPOAhE3IMwcPy19/iMqe203gAQmLRwuA=	2026-08-14 08:00:34.62405+00	2026-08-07 08:02:24.241576+00	\N	2026-08-07 08:00:34.624134+00	2026-08-07 08:02:24.283795+00	\N	\N	\N
69e999b4-483c-478b-ba5b-aaea156f970f	40517b71-5e62-182e-73b5-d4070e20a3c2	dToRYveREuMVotYXI1ERt1BB+VtS256aOrI9jULWi3E=	2026-08-14 08:02:24.265028+00	2026-08-07 08:02:35.357275+00	\N	2026-08-07 08:02:24.283795+00	2026-08-07 08:02:35.35837+00	\N	\N	\N
22b17976-0af9-46b7-b990-61e1b56785e5	40517b71-5e62-182e-73b5-d4070e20a3c2	kRaOW0DQOi4eTX/KA6lSqY7Z/8C5AGy3JodWjtOqAhs=	2026-08-14 08:02:35.35753+00	2026-08-07 08:02:35.39388+00	\N	2026-08-07 08:02:35.35837+00	2026-08-07 08:02:35.39389+00	\N	\N	\N
42f0b6e4-9fa3-4892-b2e4-c17bab7c4a67	40517b71-5e62-182e-73b5-d4070e20a3c2	YbrKNAK0pMup2sl+mEvUkupRoG1rgXkS9BDVXuAj2Qg=	2026-08-14 08:03:35.911747+00	2026-08-07 08:03:40.251092+00	\N	2026-08-07 08:03:35.912044+00	2026-08-07 08:03:40.251281+00	\N	\N	\N
802a1b5d-266c-4d89-abf2-8261539873a0	40517b71-5e62-182e-73b5-d4070e20a3c2	d8Fga/ErauFZ/B3nvXyEmco2jkyck3lyFJHgsMoWGX4=	2026-08-14 08:03:40.251224+00	2026-08-07 08:03:56.848075+00	\N	2026-08-07 08:03:40.251281+00	2026-08-07 08:03:56.848397+00	\N	\N	\N
a763b4ac-5a9d-4269-bfae-1b08b949d11a	40517b71-5e62-182e-73b5-d4070e20a3c2	J2LmXebhsMx6Ys9jfMlLMV93ccgh/R8D8d2EGwB0y5s=	2026-08-14 08:03:56.848263+00	2026-08-07 08:04:47.632885+00	\N	2026-08-07 08:03:56.848397+00	2026-08-07 08:04:47.633213+00	\N	\N	\N
32137029-617c-4ab5-838e-fec6c08ad7ab	40517b71-5e62-182e-73b5-d4070e20a3c2	rXKZs/wY+9uxF+fpZ0PqvbNK/NJs5fl2Q9dQM3qcMmw=	2026-08-14 08:04:47.633103+00	2026-08-07 08:05:11.806001+00	\N	2026-08-07 08:04:47.633213+00	2026-08-07 08:05:11.80629+00	\N	\N	\N
c47fda73-3fd7-46d3-980d-0c0a3357fb3f	40517b71-5e62-182e-73b5-d4070e20a3c2	cSo7UpfUNYPZ1skoJ+jrs46w/A+XQMpUT9ICLzO/+Ac=	2026-08-14 08:05:11.806205+00	2026-08-07 08:05:22.394378+00	\N	2026-08-07 08:05:11.80629+00	2026-08-07 08:05:22.395443+00	\N	\N	\N
708517c8-0873-443a-8939-0454c329a719	40517b71-5e62-182e-73b5-d4070e20a3c2	V9bBoVFFBuuZf3W5UjzWCNGqJoey57+seERJm8aJ2tQ=	2026-08-14 08:05:22.395285+00	2026-08-07 08:07:36.190026+00	\N	2026-08-07 08:05:22.395443+00	2026-08-07 08:07:36.190325+00	\N	\N	\N
a835fda9-6814-4724-adc0-575dbb8c6786	40517b71-5e62-182e-73b5-d4070e20a3c2	BFvHWvWpf1EUPGP/sH2iWnFr343MlKZoPeJZYLh1qFg=	2026-08-14 08:07:36.190231+00	2026-08-07 08:07:36.662554+00	\N	2026-08-07 08:07:36.190325+00	2026-08-07 08:07:36.662564+00	\N	\N	\N
2876c68d-251f-49e5-becd-962facb58d63	40517b71-5e62-182e-73b5-d4070e20a3c2	HQO8otL1IzLkRgPdM1g8GPcO40idAxkumsYqTyxKsUU=	2026-08-14 08:09:55.58242+00	2026-08-07 08:10:38.78177+00	\N	2026-08-07 08:09:55.615759+00	2026-08-07 08:10:38.784087+00	\N	\N	\N
69b9c78e-abc4-488c-bd9c-0f983b4f4dcd	40517b71-5e62-182e-73b5-d4070e20a3c2	j1rw8A/wj6ZDEu4KFbfvkp8AJzsqU5hXsFPguug1U0s=	2026-08-14 08:10:38.782094+00	2026-08-07 08:10:48.110257+00	\N	2026-08-07 08:10:38.784087+00	2026-08-07 08:10:48.110282+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
0c987fc1-1e36-4dde-a690-6ef3517af286	40517b71-5e62-182e-73b5-d4070e20a3c2	FTH5JqY5Teucgy223pXiY4MP+EoYJYy27jIXXkUfqVs=	2026-08-14 08:11:01.35921+00	2026-08-07 08:11:08.038877+00	\N	2026-08-07 08:11:01.359515+00	2026-08-07 08:11:08.039278+00	\N	\N	\N
2b5fa439-3ea0-4ac1-a2e4-cc821316f7a7	40517b71-5e62-182e-73b5-d4070e20a3c2	RxoqM6qaBvFSmYHXPoF4yzJRxAPM2HLPOGTzoIaFKcE=	2026-08-14 08:11:08.039108+00	2026-08-07 08:11:08.500286+00	\N	2026-08-07 08:11:08.039278+00	2026-08-07 08:11:08.500301+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
0ed90fc0-6e12-4100-a298-9407cc40a260	40517b71-5e62-182e-73b5-d4070e20a3c2	qVOstGPV06ceKoaDzN1iKRfbp/MdEHSWmfXxHjAU4Po=	2026-08-14 08:11:08.777404+00	2026-08-07 08:11:36.177265+00	\N	2026-08-07 08:11:08.777543+00	2026-08-07 08:11:36.177596+00	\N	\N	\N
54927c1a-ec89-41da-8fa2-587f4dbf4759	40517b71-5e62-182e-73b5-d4070e20a3c2	ghJ9bl9fuz5ZUUtJ6tNrl6FnoC5JeJC5AdMVJQCzK4s=	2026-08-14 08:11:36.177469+00	2026-08-07 08:11:45.7917+00	\N	2026-08-07 08:11:36.177596+00	2026-08-07 08:11:45.791714+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
2d2793d7-bb31-4ec1-aab8-17a0cb360c58	40517b71-5e62-182e-73b5-d4070e20a3c2	xWBgCfQt8cNToEYVeeMqaB8aVAaOmQubpF3rL4otpG8=	2026-08-14 08:15:06.822808+00	2026-08-07 08:15:15.861241+00	\N	2026-08-07 08:15:06.858179+00	2026-08-07 08:15:15.862299+00	\N	\N	\N
ca7dcc10-a52b-4050-a1c2-0000689411f3	40517b71-5e62-182e-73b5-d4070e20a3c2	3uwY99c0nt3M2mRZFDjdc0t2cUuT2fwaEHXbMcjPuvs=	2026-08-14 08:15:15.861526+00	2026-08-07 08:15:23.503387+00	\N	2026-08-07 08:15:15.862299+00	2026-08-07 08:15:23.503702+00	\N	\N	\N
cecf1e51-c54c-4626-a990-dcf08f2516f7	40517b71-5e62-182e-73b5-d4070e20a3c2	YJ8rqIG13Mspul+Fwim+d23urR/RGMI6dSVAdjxV7dI=	2026-08-14 08:15:23.503578+00	2026-08-07 08:16:01.102574+00	\N	2026-08-07 08:15:23.503702+00	2026-08-07 08:16:01.102586+00	\N	\N	\N
120e5ad9-95be-4111-aa57-05ff0661ffe8	40517b71-5e62-182e-73b5-d4070e20a3c2	+FRTXZcv3j0Kh4f48hSF71ZAQleQO72906XGjX033Q8=	2026-08-14 09:27:37.677426+00	2026-08-07 09:40:31.841835+00	\N	2026-08-07 09:27:37.707591+00	2026-08-07 09:40:31.842584+00	\N	\N	\N
7cf388c7-55d2-43ff-921a-618d3473cbe3	40517b71-5e62-182e-73b5-d4070e20a3c2	PgqQxYeGLhO3OuUWq9ZX7EWDSHtNNrGBHfR+9F495Bs=	2026-08-14 09:40:31.842102+00	2026-08-07 09:52:03.042511+00	\N	2026-08-07 09:40:31.842584+00	2026-08-07 09:52:03.042783+00	\N	\N	\N
d7d8f253-a4f6-4f61-8169-60bbcc37eceb	40517b71-5e62-182e-73b5-d4070e20a3c2	cM7yWG3hj3nYqzOdwLPt8xkjywITFqG/NsEGdeznaV0=	2026-08-14 09:53:58.093184+00	2026-08-07 10:17:24.400633+00	\N	2026-08-07 09:53:58.113189+00	2026-08-07 10:17:24.435368+00	\N	\N	\N
9b184308-430d-4737-97d0-a7cac7ece64f	40517b71-5e62-182e-73b5-d4070e20a3c2	+8HihDvKGnli2ijCQUuYrzxeibwySBLe9touN3FB+Ww=	2026-08-14 10:17:24.42069+00	2026-08-07 11:09:41.335919+00	\N	2026-08-07 10:17:24.435368+00	2026-08-07 11:09:41.372108+00	\N	\N	\N
0710d7c0-6c85-45b8-97e0-1f868c5c65ce	40517b71-5e62-182e-73b5-d4070e20a3c2	d7ZhvNq1ZOFJYasRCbfid5UrIMWegmc78NoA48Ive1Q=	2026-08-14 11:09:41.356513+00	2026-08-10 06:27:06.508659+00	\N	2026-08-07 11:09:41.372108+00	2026-08-10 06:27:06.551566+00	\N	\N	\N
67583fff-3a9d-46a0-bc8b-4744915681fc	40517b71-5e62-182e-73b5-d4070e20a3c2	13ZogkURefIyvpGXe/Wj2JBrp5XjcA/pV7Kjqw5oYBY=	2026-08-17 06:27:06.534783+00	2026-08-10 06:27:31.606647+00	\N	2026-08-10 06:27:06.551566+00	2026-08-10 06:27:31.608365+00	\N	\N	\N
4da36a4e-8b7f-4a58-8715-76ffee5a18c3	40517b71-5e62-182e-73b5-d4070e20a3c2	KGFUfIOZes73qVuvInEFxhNWkmwXby2hFjCcGPp7uEk=	2026-08-17 06:27:31.607333+00	2026-08-10 06:37:48.361845+00	\N	2026-08-10 06:27:31.608365+00	2026-08-10 06:37:48.400651+00	\N	\N	\N
f658a865-ef25-4564-85fe-d6f27d6676a6	40517b71-5e62-182e-73b5-d4070e20a3c2	GFeYLcDFwLwJoRa4cNJDohcUPf3Fez1LZrfdDb05WiI=	2026-08-17 06:37:48.384118+00	2026-08-10 06:37:48.95742+00	\N	2026-08-10 06:37:48.400651+00	2026-08-10 06:37:48.958671+00	\N	\N	\N
768fff40-d289-4aa3-a001-7f6b740ba29c	40517b71-5e62-182e-73b5-d4070e20a3c2	GR+5AXoLKkoPIS1FCJyHTa32rosO/QZVu4tiEIKvLxg=	2026-08-17 06:37:48.957842+00	2026-08-10 06:37:59.648198+00	\N	2026-08-10 06:37:48.958671+00	2026-08-10 06:37:59.682976+00	\N	\N	\N
056cc67e-dea8-4407-a4f8-573d042f9a01	40517b71-5e62-182e-73b5-d4070e20a3c2	rlIcf7xdHbPnewemnCrcZmC4no+ZlfQPlIHxHkyePwo=	2026-08-17 06:37:59.666362+00	2026-08-10 06:38:16.327559+00	\N	2026-08-10 06:37:59.682976+00	2026-08-10 06:38:16.366529+00	\N	\N	\N
dcb24288-72d3-4f09-b9e5-507d5121a1d2	40517b71-5e62-182e-73b5-d4070e20a3c2	Wf7/NX1MEbpyvqLi3EF30auX8kcm+KcCIwHrrj+oQ/0=	2026-08-17 06:38:16.348652+00	2026-08-10 06:39:25.751516+00	\N	2026-08-10 06:38:16.366529+00	2026-08-10 06:39:25.786525+00	\N	\N	\N
e6b93d24-0f8e-43a9-b078-1f39eac57145	40517b71-5e62-182e-73b5-d4070e20a3c2	hf3UOrJo3EonXm5M+RehhTYB4X6n+vr1t6Disqau+2Q=	2026-08-17 06:39:25.76948+00	2026-08-10 06:39:26.362052+00	\N	2026-08-10 06:39:25.786525+00	2026-08-10 06:39:26.363799+00	\N	\N	\N
70992db8-abe6-4cd7-903d-686bfadfba87	40517b71-5e62-182e-73b5-d4070e20a3c2	hHogkoiCthztrcqltAnB/B1wo0VN1j1LO9JqMxq3KAc=	2026-08-17 06:39:26.362749+00	2026-08-10 06:39:56.465469+00	\N	2026-08-10 06:39:26.363799+00	2026-08-10 06:39:56.503057+00	\N	\N	\N
1c688ebf-7c90-45a3-a25c-5adf99ebfb9a	40517b71-5e62-182e-73b5-d4070e20a3c2	hOMB36WrMhKoYiPy1zUIOnzxg4JAjh47x6GfP+6tHv4=	2026-08-17 06:39:56.486143+00	2026-08-10 06:40:14.327631+00	\N	2026-08-10 06:39:56.503057+00	2026-08-10 06:40:14.362718+00	\N	\N	\N
3ce317a7-b672-4ca9-9a6c-20f6ce2ef026	40517b71-5e62-182e-73b5-d4070e20a3c2	DQrbCf1FUT2qOcANLSwXeiKBZM6avtsW01+dxZOEicg=	2026-08-17 06:40:14.346062+00	2026-08-10 06:40:14.919217+00	\N	2026-08-10 06:40:14.362718+00	2026-08-10 06:40:14.920934+00	\N	\N	\N
8bbd49a0-4ef5-4ed6-afc2-a53e87e5e583	40517b71-5e62-182e-73b5-d4070e20a3c2	BaRJgDcv2y9duS6NXK/k/JRNtG+cgDGVhLWK/wDdTQ0=	2026-08-17 06:40:14.919921+00	2026-08-10 06:53:44.19292+00	\N	2026-08-10 06:40:14.920934+00	2026-08-10 06:53:44.193225+00	\N	\N	\N
3a315a92-4e6e-477f-bdbf-135529e85782	b1d3f51c-b209-d352-4b52-3f4008801ab3	kLwEj/ufnpt7gxFdKluGVMyyEm1vMEYqraU1sox50z8=	2026-08-17 06:56:53.754315+00	2026-08-10 06:57:02.684675+00	\N	2026-08-10 06:56:53.764781+00	2026-08-10 06:57:02.685958+00	\N	\N	\N
af20811d-e7a9-47fb-9161-6274c30e5d7d	b1d3f51c-b209-d352-4b52-3f4008801ab3	ojH2uduMFLUOoL6l9Gu6s7rRCd8OQGq2wtqdjYCvc2Y=	2026-08-17 06:57:02.685022+00	2026-08-10 06:57:04.081703+00	\N	2026-08-10 06:57:02.685958+00	2026-08-10 06:57:04.081714+00	\N	\N	\N
4844a15e-fa53-4646-887f-a8b04db17f46	9f6f34df-dc47-f198-f3f6-e577aab1cbca	bh0FpJgzFpkmHHZnSHc+4GRk8f3deAQwst9m9yITYms=	2026-08-17 06:57:19.16574+00	2026-08-10 06:59:23.501154+00	\N	2026-08-10 06:57:19.165935+00	2026-08-10 06:59:23.501173+00	\N	9f6f34df-dc47-f198-f3f6-e577aab1cbca	\N
359bb0d8-e9d1-4d8d-9745-dd363893ccc1	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	rNKV6KBOvzARNrFe/91AFNM1wznxbwttoftZAhWSgCw=	2026-08-17 06:59:34.907971+00	2026-08-10 07:01:27.586695+00	\N	2026-08-10 06:59:34.908096+00	2026-08-10 07:01:27.586707+00	\N	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	\N
02735f4a-ebed-4fe6-bb4b-11b119d5d494	40517b71-5e62-182e-73b5-d4070e20a3c2	ai7WiZY+U3KPQ0HSymcTMvoiva0+1JfyOGXCJHG/fn0=	2026-08-17 07:01:55.794279+00	2026-08-10 07:02:04.247712+00	\N	2026-08-10 07:01:55.794379+00	2026-08-10 07:02:04.247728+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
8a5dbcf9-caf8-4df0-8627-639f6a2c2e03	40517b71-5e62-182e-73b5-d4070e20a3c2	kA7N3AhsshX8F2dYhX0m3aHo7USMorZkDcJjlFuiZTI=	2026-08-17 09:20:16.45192+00	2026-08-10 10:10:49.663847+00	\N	2026-08-10 09:20:16.486557+00	2026-08-10 10:10:49.664859+00	\N	\N	\N
aa84fc7b-9e7a-4550-82cb-f3bbe15e2c1b	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	Xb0tfgDqoDSAfTL/OTBQKB3QaL+3hWSjkEKbCwULHrc=	2026-08-14 07:55:46.463547+00	2026-08-10 12:26:18.897379+00	\N	2026-08-07 07:55:46.463705+00	2026-08-10 12:26:18.897894+00	\N	\N	\N
fea95f12-19b0-4156-86e2-a5e97a857bf8	40517b71-5e62-182e-73b5-d4070e20a3c2	cRV7QEsGNYoOLg09nA3N6aFtWcyt98L6aAoS8HaTQb4=	2026-08-17 10:10:49.664168+00	2026-08-10 10:52:07.080485+00	\N	2026-08-10 10:10:49.664859+00	2026-08-10 10:52:07.080694+00	\N	\N	\N
507790cb-68da-4c77-a195-ff68fb7614d6	40517b71-5e62-182e-73b5-d4070e20a3c2	zqg6xxQ/BtP0V6WbKlcWxJ8OkF5MKCnIsFBo0sAkFGc=	2026-08-17 10:52:07.080635+00	2026-08-10 10:53:24.422081+00	\N	2026-08-10 10:52:07.080694+00	2026-08-10 10:53:24.42247+00	\N	\N	\N
46497668-cd7a-4ba9-8656-dd12a2ddbf05	40517b71-5e62-182e-73b5-d4070e20a3c2	w3RwzLZ27rUrsxNW8tCdpRlvasrI7rZiKBU4RJeqOAg=	2026-08-17 10:53:24.422351+00	2026-08-10 10:58:19.491738+00	\N	2026-08-10 10:53:24.42247+00	2026-08-10 10:58:19.492034+00	\N	\N	\N
3c3ab08f-76bb-4f03-a36d-a983d55e33b3	40517b71-5e62-182e-73b5-d4070e20a3c2	IrM6RAGrrhet0tQqDqYo57a6+jeFMs4kjXaPBKcw/dg=	2026-08-17 10:58:19.491918+00	2026-08-10 10:58:47.002191+00	\N	2026-08-10 10:58:19.492034+00	2026-08-10 10:58:47.002539+00	\N	\N	\N
ec07c075-5e83-4ad9-a352-354c80aa6dc9	40517b71-5e62-182e-73b5-d4070e20a3c2	LPVEE1kvXwprAd4tTOlvex0ytJ53hPmuQEvKW1h9PHI=	2026-08-17 10:58:47.002464+00	2026-08-10 11:39:58.213898+00	\N	2026-08-10 10:58:47.002539+00	2026-08-10 11:39:58.214418+00	\N	\N	\N
bfc9eca1-568a-4a87-ac19-b232e7f61c0e	40517b71-5e62-182e-73b5-d4070e20a3c2	rWJgZffOX1T77ALIaNqLhmH5QgfiWBTKyMyNoRic/4U=	2026-08-17 11:39:58.214248+00	2026-08-10 11:59:08.388103+00	\N	2026-08-10 11:39:58.214418+00	2026-08-10 11:59:08.38811+00	\N	\N	\N
f7ca88c9-a73a-49e7-9197-4a3a03a013e7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	IOCuK6tbiBsJPtt/7+sBKfhxW90/iedwRlNkTAMxMmQ=	2026-08-17 12:25:59.548956+00	2026-08-10 12:26:09.50904+00	\N	2026-08-10 12:25:59.564856+00	2026-08-10 12:26:09.510721+00	\N	\N	\N
82d54e99-05ae-4fc9-95d0-1123053af68c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Buz0rwSXum1sVFiS9/hO7X3FUzZLfcs0ZGjs4tYDna8=	2026-08-17 12:26:09.510424+00	2026-08-10 12:26:33.784739+00	\N	2026-08-10 12:26:09.510721+00	2026-08-10 12:26:33.786047+00	\N	\N	\N
2f42eb84-1298-4d3e-89e7-f2f486c52a3e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YOg3AlTENv3uX62MzJpiwE72y2VQ8bdH2y58VT1Cc2Y=	2026-08-17 12:26:33.785638+00	2026-08-10 12:36:15.977761+00	\N	2026-08-10 12:26:33.786047+00	2026-08-10 12:36:15.978128+00	\N	\N	\N
95984435-9500-46af-8996-8d36929fcbd7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ykqsUxTFM5EJsiTli/P9sS+xruFD50G+DCc7d2V+W4M=	2026-08-17 12:36:15.978012+00	2026-08-10 12:36:28.515221+00	\N	2026-08-10 12:36:15.978128+00	2026-08-10 12:36:28.515713+00	\N	\N	\N
74549e44-8926-422c-9d70-564d73840ab7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	i5uxCFNp9YOUBMKVRBV2CeeFd2NzfAz3RuHoQGnP9PI=	2026-08-17 12:36:28.515543+00	2026-08-10 12:36:44.168341+00	\N	2026-08-10 12:36:28.515713+00	2026-08-10 12:36:44.168357+00	\N	\N	\N
55407794-2c87-408c-859b-a8362a831283	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yJCbXNuFhIlHOpP6mNH8hdcQA6VfgnQjZccus4bjzPU=	2026-08-17 12:37:40.918855+00	2026-08-10 12:40:13.599342+00	\N	2026-08-10 12:37:40.919058+00	2026-08-10 12:40:13.642921+00	\N	\N	\N
95b9c822-4044-452c-beff-95a109f3586b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Aifxpg+jxVTmWSRnGMOzUQzTi9LIRRw059OC9FYkFGc=	2026-08-17 12:37:18.377131+00	2026-08-10 12:40:39.046037+00	\N	2026-08-10 12:37:18.377329+00	2026-08-10 12:40:39.046061+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3e1b3105-a99a-4ec7-bc5a-c09d0cd28cb7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	l4EWf6mv9VSX3PbS+26lbxgx+W8Euq3ZjBUuiAji4Xs=	2026-08-17 12:40:13.627115+00	2026-08-10 12:40:51.417653+00	\N	2026-08-10 12:40:13.642921+00	2026-08-10 12:40:51.418091+00	\N	\N	\N
dcc22c6c-aa0c-47d6-a53c-1ad2265ac29e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OQ8Hmf5pjBsHjYnmjnV5dzMOcUHrgWtfm2pmWLGbYus=	2026-08-17 12:40:51.417952+00	2026-08-10 12:42:13.014327+00	\N	2026-08-10 12:40:51.418091+00	2026-08-10 12:42:13.014344+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3e01abcf-2eb8-4baf-8d75-b1712fc08532	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	1TZtiaPUP5w/rNC72tXTn/C615Vj30WyzPsddGn6+8E=	2026-08-17 12:26:18.897728+00	2026-08-10 12:42:22.867337+00	\N	2026-08-10 12:26:18.897894+00	2026-08-10 12:42:22.867619+00	\N	\N	\N
d426da8c-c314-4786-8474-e61e98a90c50	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	G41gT95TyAt0AFfMKySXN16b/mKF93whoLw39fBQF1w=	2026-08-17 12:42:22.867499+00	2026-08-10 12:43:45.869687+00	\N	2026-08-10 12:42:22.867619+00	2026-08-10 12:43:45.869986+00	\N	\N	\N
17950392-5d3d-42d6-a5b1-73dfadd8770d	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	L9VXSzIfbYouNr+gkdq+egIlnJz3jtJd/gKDIT1T9KY=	2026-08-17 12:43:45.869871+00	2026-08-10 12:44:06.503821+00	\N	2026-08-10 12:43:45.869986+00	2026-08-10 12:44:06.504074+00	\N	\N	\N
2bb5d9d4-7169-4e51-8e77-393245174c71	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	gZFXJ7CwJcZek+w5PJM6a/q3qRespzvRv4qOoZqQPiw=	2026-08-17 12:44:06.503981+00	2026-08-10 12:44:16.677465+00	\N	2026-08-10 12:44:06.504074+00	2026-08-10 12:44:16.677811+00	\N	\N	\N
538cc965-cbbb-437a-99aa-e6655e3deaf3	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	11JiAKsLOgW/iTdi+N+pN0cjfFzBKbXsEmbqBMg8xmw=	2026-08-17 12:44:16.677678+00	2026-08-10 12:44:27.547311+00	\N	2026-08-10 12:44:16.677811+00	2026-08-10 12:44:27.54768+00	\N	\N	\N
62c58661-8f3a-4b93-ac6f-6b1a84f4c204	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	2QSw0wue5g+dem7HoH1cdPIOUMgIbVzyhDLSYouYF0I=	2026-08-17 12:52:31.080366+00	2026-08-10 12:52:51.692282+00	\N	2026-08-10 12:52:31.080473+00	2026-08-10 12:52:51.692293+00	\N	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	\N
1f74a1a0-fdfe-4641-8f4c-9379e1082960	730809c0-fc01-a664-03ca-28e0e32d0393	R7mQqmO+q7A+48l6Xk37pevgp3BrQdrwoicF+KYGs0E=	2026-08-17 12:53:37.088122+00	2026-08-10 12:55:36.686186+00	\N	2026-08-10 12:53:37.088258+00	2026-08-10 12:55:36.686196+00	\N	730809c0-fc01-a664-03ca-28e0e32d0393	\N
deac0501-ccf1-4fdf-ac50-382c52c03b83	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	nvNFJuw+dV7y+zLO9aRbMVYpu8NgmV3qxCMPuR8SzWM=	2026-08-17 12:44:27.54749+00	2026-08-10 12:56:06.723663+00	\N	2026-08-10 12:44:27.54768+00	2026-08-10 12:56:06.723969+00	\N	\N	\N
8f326fea-3493-447f-a716-e2a7607347dc	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	snjmrBqzmOO5n+5WDjy5WOlI2zJo1oe2J1mKf+Ye07I=	2026-08-17 12:56:06.723838+00	2026-08-10 12:57:01.370485+00	\N	2026-08-10 12:56:06.723969+00	2026-08-10 12:57:01.370494+00	\N	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	\N
b096b852-8f35-4d16-8c1e-89156e6c0876	65e2ffa3-6073-780a-b849-4d9604c7251c	pA0YwxXyEFEG34nqpz1dq01gfdMmfVO4q8OOoZT8cHs=	2026-08-17 12:57:13.731204+00	2026-08-11 06:05:30.64142+00	\N	2026-08-10 12:57:13.731317+00	2026-08-11 06:05:30.721314+00	\N	\N	\N
fd4798e9-ed21-4e3f-8eb2-d99dc6200b27	65e2ffa3-6073-780a-b849-4d9604c7251c	0ugqpW6PNRWWoqywo99wWqUpgEKWAV14RpvNZRRXubU=	2026-08-18 06:05:30.704827+00	\N	\N	2026-08-11 06:05:30.721314+00	\N	\N	\N	\N
e3284e11-d8cc-4402-997b-2279345f8d17	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rMhCYG6wkXnakWlhhHZhVTVgz4iSsneSxTg61ejpcbU=	2026-08-18 06:05:50.572528+00	2026-08-11 06:11:04.569162+00	\N	2026-08-11 06:05:50.573481+00	2026-08-11 06:11:04.569176+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
147b6846-2d44-4692-b93a-598731a444f8	40517b71-5e62-182e-73b5-d4070e20a3c2	/JfWmgIwv2g/opVxoxUkmITLjxw8PLy9xDL9zVtFAh0=	2026-08-18 06:11:23.11593+00	2026-08-11 06:12:25.929146+00	\N	2026-08-11 06:11:23.116095+00	2026-08-11 06:12:25.929159+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
5e5603b9-2905-4ea2-bb3a-67dfc353360a	40517b71-5e62-182e-73b5-d4070e20a3c2	STzf/tzgx8XfYWdnlC/AcoD9GQOxYvPs6RkJ/ot/Gx0=	2026-08-18 06:12:39.656234+00	2026-08-11 06:20:18.918338+00	\N	2026-08-11 06:12:39.656315+00	2026-08-11 06:20:18.918351+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N
f94c8d2c-97fb-4b22-adbc-f0a01c05dd9b	9f6f34df-dc47-f198-f3f6-e577aab1cbca	PUyL37m2dvLw8Znak16ke++qxLmRI+9xC9hAExrcda8=	2026-08-18 06:20:37.415519+00	\N	\N	2026-08-11 06:20:37.415637+00	\N	\N	\N	\N
f700bccb-1f29-4c98-a32a-ce86f48db7f6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+bPdl/qnoEBvAuMzd8fv83yIcMltPatd6trYBFpKqJo=	2026-08-18 07:01:05.57033+00	2026-08-11 08:14:25.01582+00	\N	2026-08-11 07:01:05.570476+00	2026-08-11 08:14:25.016092+00	\N	\N	\N
0c0841e5-7322-44ed-972f-eb3e79a733a5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	pMs2fU7tGnq1EX+KhF1Uy8l4sXG26+8P8RWzpamPOdM=	2026-08-18 08:14:25.016016+00	2026-08-11 09:30:23.191087+00	\N	2026-08-11 08:14:25.016092+00	2026-08-11 09:30:23.1911+00	\N	\N	\N
c9e08b83-0c49-41df-b890-6fb679853b3a	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	Ji4S34o7ozfQFr+pMGS0nYCOHAWC1jbMD8Y0xiu0F64=	2026-08-18 10:27:05.188485+00	2026-08-11 10:27:32.604724+00	\N	2026-08-11 10:27:05.188878+00	2026-08-11 10:27:32.614709+00	\N	\N	\N
3ea9046e-ba04-4e0d-8182-c91e7a3680f4	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	VEDg75Sgh40XSfbEWs4rXC73i0kgB27yOYWllxDtBxQ=	2026-08-18 10:27:32.614451+00	2026-08-11 10:27:44.435796+00	\N	2026-08-11 10:27:32.614709+00	2026-08-11 10:27:44.436212+00	\N	\N	\N
bd89f750-cfb5-40dc-ba9a-1ea96f0eafe9	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	3tQS29kvMe3IiY1quXs/ncbq4hd5XYeKjnLTLmAdTQE=	2026-08-18 10:27:44.436067+00	2026-08-11 10:30:32.96644+00	\N	2026-08-11 10:27:44.436212+00	2026-08-11 10:30:32.96645+00	\N	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	\N
99a1623f-1c63-4887-b389-bd519566895e	b1d3f51c-b209-d352-4b52-3f4008801ab3	dK9y+/y9ZbiYNOYZ4FFR3De9JRbfnGOuqRlvDhYjsxE=	2026-08-18 10:33:16.307727+00	2026-08-11 10:33:24.774577+00	\N	2026-08-11 10:33:16.307884+00	2026-08-11 10:33:24.77497+00	\N	\N	\N
572a39a1-abb0-4ddd-af9a-413b4a8e9eb7	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	oOOMXgxtTvgNwGjPnnCVChKpGlV2lYpEB1I/5bdCJaM=	2026-08-18 10:33:39.029844+00	2026-08-11 11:23:19.803613+00	\N	2026-08-11 10:33:39.029981+00	2026-08-11 11:23:19.804121+00	\N	\N	\N
8f006f48-7e26-427b-b714-747fb1695392	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	EsTA17ofd9yZOE4SBgrvT0ft7exxMgltuNyGW724zU0=	2026-08-18 10:30:51.397274+00	2026-08-11 11:41:38.971739+00	\N	2026-08-11 10:30:51.397514+00	2026-08-11 11:41:38.971959+00	\N	\N	\N
b02f44de-0d79-4bbf-91d2-4c31485afc3b	111775f6-5d80-5333-478e-68e2fda584fa	87o342U9a5LnZjp3poQAYlcd82jVPtF+LxvWJdpUjG0=	2026-08-18 11:25:30.012822+00	2026-08-11 11:41:39.087682+00	\N	2026-08-11 11:25:30.013181+00	2026-08-11 11:41:39.08791+00	\N	\N	\N
c787cb76-ae69-4d20-adc3-dfe5cecba19e	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	G+f3x+OK4xykD270KMKG9/b/1nZhBnnNywf9zEI8J4M=	2026-08-18 11:41:38.971892+00	2026-08-11 11:43:23.319332+00	\N	2026-08-11 11:41:38.971959+00	2026-08-11 11:43:23.319359+00	\N	\N	\N
9ce4ea6e-9e21-4e2f-a8af-1701afd087ec	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	6VLhML3Z36e3pSB8PJ4JEN1SviWY2uCYIu0b2D/kOlQ=	2026-08-18 11:23:19.80399+00	2026-08-11 11:43:34.664599+00	\N	2026-08-11 11:23:19.804121+00	2026-08-11 11:43:34.664914+00	\N	\N	\N
4bc2da8c-9093-4e63-8772-087232faa64d	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	ucvF22nXhqyhiWcYmTpEMBZV/zs5rOZFmc0qWBWySt8=	2026-08-18 11:43:34.66482+00	2026-08-11 11:44:59.722956+00	\N	2026-08-11 11:43:34.664914+00	2026-08-11 11:44:59.723122+00	\N	\N	\N
924cdece-0ed0-4470-ad32-46d1e82c9c52	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	lxsjb82zLKcs07f34Fagg0v/C3BKutRiGgLYcssD3ss=	2026-08-18 11:44:59.72307+00	2026-08-11 11:47:47.765396+00	\N	2026-08-11 11:44:59.723122+00	2026-08-11 11:47:47.765403+00	\N	\N	\N
9a6dcd0a-6171-4af4-a7c0-95a30c6a704c	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	Be2a2zUD3L+IvXmAqRcttxvba0+bv6b1vCPEG8E+NoM=	2026-08-18 11:47:59.424036+00	2026-08-11 11:48:05.564808+00	\N	2026-08-11 11:47:59.424221+00	2026-08-11 11:48:05.565069+00	\N	\N	\N
cf9e1d5d-4d24-40c0-82fd-5c1b74574001	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	wdcWNhc9Llqr+RYmvUMuBcUkIJ6hkBHsJOsajhmWWus=	2026-08-18 11:48:05.564905+00	2026-08-11 11:48:31.185805+00	\N	2026-08-11 11:48:05.565069+00	2026-08-11 11:48:31.186261+00	\N	\N	\N
165d8919-08ec-42d4-8a69-fb6f9d6e771c	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	3xtZO3MouS5BFAyzghthdQHodTkxOJA6m20DEzVdxy8=	2026-08-18 11:48:31.185997+00	2026-08-11 11:49:23.361718+00	\N	2026-08-11 11:48:31.186261+00	2026-08-11 11:49:23.361726+00	\N	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	\N
da7ab2a7-75f7-43c0-b903-6680f7bcd35d	111775f6-5d80-5333-478e-68e2fda584fa	GTYEc+oPSuYRA2n4f5DY5/gpfM7vdBbIuViRhh43Dzg=	2026-08-18 11:41:39.087825+00	2026-08-11 11:51:19.004087+00	\N	2026-08-11 11:41:39.08791+00	2026-08-11 11:51:19.004097+00	\N	\N	\N
d7de05e4-4f65-488f-a528-c6e1e9a6856c	b1d3f51c-b209-d352-4b52-3f4008801ab3	JxI70Gj5lNPG64S2FnWHYClekmyauC7GL5tIPxMTN9s=	2026-08-18 10:33:24.77486+00	2026-08-11 11:51:44.289708+00	\N	2026-08-11 10:33:24.77497+00	2026-08-11 11:51:44.289974+00	\N	\N	\N
c5e7cafc-0d87-4956-bac0-165a4e532cda	b1d3f51c-b209-d352-4b52-3f4008801ab3	FDmGv/9IyH68oin1NOyJadg7V75KJwDczTpoLx2J8mk=	2026-08-18 11:51:44.289908+00	\N	\N	2026-08-11 11:51:44.289974+00	\N	\N	\N	\N
96fd8acc-e2b0-40c1-a78d-7dcb1685ca1a	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	GqgoTZ1aXwgnfCYrIia0qEx07Y7ziGE60N+3a4mEz/c=	2026-08-18 12:31:49.389586+00	2026-08-11 12:34:26.894525+00	\N	2026-08-11 12:31:49.38968+00	2026-08-11 12:34:26.894531+00	\N	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	\N
983dd366-310c-4fdc-ab23-fcda702b3dad	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	xHegPS+3q3mQx3XvMgjiWxdNzarkhqzLh1LAnjtbtvI=	2026-08-18 11:49:34.53917+00	2026-08-11 12:34:37.941203+00	\N	2026-08-11 11:49:34.539306+00	2026-08-11 12:34:37.941421+00	\N	\N	\N
8d93c762-0e11-49a9-936f-7893882a4637	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	KuBjtcdeRNDCoGIqIBieaIIKDTlSBjpw6Ty5wpN6YKs=	2026-08-17 12:26:34.151451+00	2026-08-17 11:58:01.492975+00	\N	2026-08-10 12:26:34.151693+00	2026-08-17 11:58:01.493149+00	\N	\N	\N
eef0d74d-6908-4074-aba8-614c5a01dc62	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BEhsd2lyE+wFuMU0mF4h45Z9GEcguzSTvwVs5Kc/Vxw=	2026-08-18 12:45:48.772946+00	2026-08-11 12:48:29.349777+00	\N	2026-08-11 12:45:48.80745+00	2026-08-11 12:48:29.394396+00	\N	\N	\N
c046d295-c803-46e5-bbe5-b010f00ff428	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ahY1gGdMA5+0RpvbMasA0eMtVdRH0hd69FNy0wnBdKY=	2026-08-18 12:48:29.37719+00	2026-08-11 12:48:29.786914+00	\N	2026-08-11 12:48:29.394396+00	2026-08-11 12:48:29.788864+00	\N	\N	\N
d39cf8f5-c050-4e7e-964a-6a081928d8fd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yOQj3s5OTbNFJ2NYzpaCDNX8B7r7exhSuUYvzPo16+Y=	2026-08-18 12:48:29.787541+00	2026-08-11 12:48:30.03862+00	\N	2026-08-11 12:48:29.788864+00	2026-08-11 12:48:30.038642+00	\N	\N	\N
9aca32e6-53d0-477d-8819-7339b9e272e8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	I1wJhuDa8+dNSN+pnb/kSPcjSRDGZ7/9/KlFK4X92p4=	2026-08-18 12:48:38.912859+00	2026-08-11 12:50:52.900078+00	\N	2026-08-11 12:48:38.913082+00	2026-08-11 12:50:52.900393+00	\N	\N	\N
d65e42dd-3fe5-43d4-9500-7b1eee373fdb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	q00UBbqZHn+ZzKVkATx3eXeGDNdjyOw8KxuzkfmZSso=	2026-08-18 12:50:52.900281+00	2026-08-11 12:51:00.781172+00	\N	2026-08-11 12:50:52.900393+00	2026-08-11 12:51:00.781462+00	\N	\N	\N
e841a434-7bcc-446d-9f60-35b211aab97b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	p8tYRR9j8Bt/qTCIeqnhc4irSQqX59OVStsMxJGpMk4=	2026-08-18 12:51:00.781373+00	2026-08-11 12:51:21.157832+00	\N	2026-08-11 12:51:00.781462+00	2026-08-11 12:51:21.157845+00	\N	\N	\N
ee85465a-09e7-4a86-929f-e380d7d7f838	40517b71-5e62-182e-73b5-d4070e20a3c2	n6/adEcWbcKNw9BNfjRCVNfHWPxuIrIxgALCFtSE+Yk=	2026-08-18 12:52:22.274805+00	2026-08-11 12:52:28.757613+00	\N	2026-08-11 12:52:22.308252+00	2026-08-11 12:52:28.759431+00	\N	\N	\N
e65679b1-85e6-4dba-91d7-ad3e0556f019	40517b71-5e62-182e-73b5-d4070e20a3c2	yyqxge0HiUE8Lk+lpQfymCecWMWd20wK9Ezy2ZeNMSQ=	2026-08-18 12:52:28.758325+00	2026-08-11 12:52:35.0217+00	\N	2026-08-11 12:52:28.759431+00	2026-08-11 12:52:35.022058+00	\N	\N	\N
bf3819d2-6e5e-47fe-b1be-8f83a3517c18	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2tqet8uwI3ySmu/16faxp79ntGrOti8+tTSw6GEYLWo=	2026-08-18 12:53:59.584076+00	2026-08-11 12:53:59.989882+00	\N	2026-08-11 12:53:59.623672+00	2026-08-11 12:53:59.991661+00	\N	\N	\N
81a82895-939f-4ea2-af3b-6d25b7ab782e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	avZtPh8eRsIbnrtmLgu760NXOUukdY0mqs/rDLXwi7g=	2026-08-18 12:53:59.990509+00	2026-08-11 12:54:00.186211+00	\N	2026-08-11 12:53:59.991661+00	2026-08-11 12:54:00.186226+00	\N	\N	\N
5fbcd7dd-bd6f-4429-9a70-3a06c5c89616	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Xd+kk4fwEvvfCr6A7uie7lM7KVMFhlnbRNfDm2sK/NM=	2026-08-18 12:56:51.712617+00	2026-08-11 13:01:22.002398+00	\N	2026-08-11 12:56:51.712802+00	2026-08-11 13:01:22.002792+00	\N	\N	\N
b89078a4-af6f-4183-afec-da3315ce2365	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	FArabMT0Juf2QjQXelZ2aJRe7i3nTLV5l29ihA369Ms=	2026-08-18 12:34:37.941357+00	2026-08-13 06:42:59.884887+00	\N	2026-08-11 12:34:37.941421+00	2026-08-13 06:42:59.885103+00	\N	\N	\N
14f30aa6-6cbb-458e-a807-9837759e35c1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	JsEAOohf7rR5/wRTgw0WwlxvjsZmQ9DOQY93RhD84B4=	2026-08-18 13:02:05.371856+00	2026-08-11 13:02:13.633783+00	\N	2026-08-11 13:02:05.389302+00	2026-08-11 13:02:13.635198+00	\N	\N	\N
5a853bd3-d32f-4d45-b41b-b251fef0e530	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	py8vaoeTqlex1vcRH84vffhqSKCi7m9jGqDvO7tvypU=	2026-08-18 13:02:13.634129+00	2026-08-11 13:02:20.622174+00	\N	2026-08-11 13:02:13.635198+00	2026-08-11 13:02:20.622475+00	\N	\N	\N
d409bc1c-9c7b-47c8-a589-3348d0ae4b47	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	KWIBrI07Jvy+/CXkvgLGHsKixf6t7rGHtUxHztd2D84=	2026-08-18 13:02:30.241233+00	2026-08-11 13:02:36.427469+00	\N	2026-08-11 13:02:30.241418+00	2026-08-11 13:02:36.427699+00	\N	\N	\N
e07a47eb-2c9d-4e53-b16d-d20a1d7f8e79	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	wWFUQoItsPrUrFPdlgvwMjqjuKERJx98uf7caAIKGD0=	2026-08-18 13:02:36.427614+00	2026-08-11 13:03:47.634423+00	\N	2026-08-11 13:02:36.427699+00	2026-08-11 13:03:47.634743+00	\N	\N	\N
ec66f234-af67-44f6-a03e-1dd539e099bc	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	0WEnglKJsrTQDrdBbABcTdN3dH+EPlbG6hMdNHg6SRw=	2026-08-18 13:03:47.634616+00	2026-08-11 13:04:04.446295+00	\N	2026-08-11 13:03:47.634743+00	2026-08-11 13:04:04.446305+00	\N	\N	\N
0f3e9fc9-6076-44b7-ae92-e33f2982a89e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	u+qP6jvjBayZvpsJCpH2b1y+59qnc0yhat1/5FZBLrg=	2026-08-18 13:02:20.622379+00	2026-08-11 13:04:19.1411+00	\N	2026-08-11 13:02:20.622475+00	2026-08-11 13:04:19.141475+00	\N	\N	\N
45b021dd-3fef-4599-8f12-e79dc7fc6852	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8EDj0kFTNQJN86o1ML2pHENzuCX5wwLpgx88wTeuJfQ=	2026-08-18 13:01:22.002662+00	2026-08-11 13:05:01.301621+00	\N	2026-08-11 13:01:22.002792+00	2026-08-11 13:05:01.301634+00	\N	\N	\N
c1dff3f6-a6df-4065-96c4-79652100a0cd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	g3LgJ8AxsPOFjsXLsfJSYoEtJZHRpldUsNoQxEeavrI=	2026-08-18 13:04:19.141319+00	2026-08-11 13:11:10.081954+00	\N	2026-08-11 13:04:19.141475+00	2026-08-11 13:11:10.081963+00	\N	\N	\N
8150fbac-cf85-4b73-8c49-b5b47eb2379f	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	vVRCOOvGA0/XkC5a7xZ/BoKgrCf9fgnSlPbalkpcGHc=	2026-08-18 13:05:09.760774+00	2026-08-11 13:11:28.907897+00	\N	2026-08-11 13:05:09.76092+00	2026-08-11 13:11:28.908163+00	\N	\N	\N
df8b3588-6c8d-41a7-8d62-3b11b42cba24	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	8ZNcbnKDMvhOvt6QtopflUIgEP9nlUlxyW4G14FhFFA=	2026-08-18 13:11:28.908063+00	2026-08-11 13:11:58.230842+00	\N	2026-08-11 13:11:28.908163+00	2026-08-11 13:11:58.231223+00	\N	\N	\N
604388d6-9028-472b-bc44-2ffd9ac9cabc	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	Ggq3mUaELW0ps1AumLvSRley3oD3+cXXDmTEI9VVWIg=	2026-08-18 13:11:58.231041+00	2026-08-11 13:12:26.64585+00	\N	2026-08-11 13:11:58.231223+00	2026-08-11 13:12:26.646069+00	\N	\N	\N
21465494-1807-4e5f-aa48-5fe70f34cf09	40517b71-5e62-182e-73b5-d4070e20a3c2	GI9Nb9YDJuMCNhVpbRs40YtF+XwMA6Ltn6FEXBxnyos=	2026-08-18 12:52:35.02195+00	2026-08-13 06:42:53.627786+00	\N	2026-08-11 12:52:35.022058+00	2026-08-13 06:42:53.695888+00	\N	\N	\N
9fec49b1-0c6d-4d8a-abe2-e5da40002278	40517b71-5e62-182e-73b5-d4070e20a3c2	D1tWd9ZOVZyKSQaoY81j/MnD4jrJ5Q/Ae/bOKmFfpPs=	2026-08-20 06:42:53.681649+00	2026-08-13 06:42:59.444556+00	\N	2026-08-13 06:42:53.695888+00	2026-08-13 06:42:59.445702+00	\N	\N	\N
fa91c410-f4f1-4e79-b313-1ae932e4b699	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	3NQTJ3uMiPJf+ULwHx6jjQusi1Nnj4KUHILZq9ZsF10=	2026-08-18 13:12:26.645982+00	2026-08-13 06:49:34.874233+00	\N	2026-08-11 13:12:26.646069+00	2026-08-13 06:49:34.874481+00	\N	\N	\N
6e181863-d633-4654-9c64-f84c023dff26	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	eqXcLAVeLkQsqyv41ZMxiRZvdjrua3MGbxKJRzi+hCY=	2026-08-20 06:49:34.874355+00	2026-08-13 06:49:41.688683+00	\N	2026-08-13 06:49:34.874481+00	2026-08-13 06:49:41.688693+00	\N	\N	\N
19202353-d846-4108-be64-ffdd693df49a	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	PF/rev6wFh8IXuiWNclMugdh0RWqi3yod46wDzIpeTY=	2026-08-20 06:42:59.885036+00	2026-08-13 06:49:53.45002+00	\N	2026-08-13 06:42:59.885103+00	2026-08-13 06:49:53.450239+00	\N	\N	\N
bcbcfa50-89a0-49ed-807a-c73541137118	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	LGSMsMDwiG+kJ8Ph/u+Ul7mXhZhmw25V2vk/jAZ/iPE=	2026-08-20 06:49:53.45017+00	2026-08-13 06:50:33.019994+00	\N	2026-08-13 06:49:53.450239+00	2026-08-13 06:50:33.020416+00	\N	\N	\N
81e2cb3c-311d-48fd-80f2-f14b3b21ce73	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	T6fwkFYmhQWTuHGUZ82BN+MD6zLf9ey3wNykdn7mtxs=	2026-08-20 06:50:33.020169+00	2026-08-13 06:51:42.54799+00	\N	2026-08-13 06:50:33.020416+00	2026-08-13 06:51:42.548331+00	\N	\N	\N
5d399d1c-e5a4-4229-9073-1bf7907f8178	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	rOsa+YqZjV0c/R5tMOSQLiODDNxuJ7KfMAm1bVPHyIU=	2026-08-20 06:51:42.548173+00	2026-08-13 06:52:09.916507+00	\N	2026-08-13 06:51:42.548331+00	2026-08-13 06:52:09.917424+00	\N	\N	\N
b9402ef5-af3c-42a7-afaa-93ef94acddd9	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	gUhmUExyOJioQTEd/GKiie/Fe2KIsQfbW4aPVgWwJ9o=	2026-08-20 06:52:09.917263+00	2026-08-13 06:52:30.562368+00	\N	2026-08-13 06:52:09.917424+00	2026-08-13 06:52:30.562573+00	\N	\N	\N
1f32c01b-5e82-4cd9-a9e6-28f7762be99a	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	yGMpoAE03DLXFAIbpVW2MWdejL6evuOby7zLM8wc41k=	2026-08-20 06:52:30.562508+00	2026-08-13 06:54:16.621905+00	\N	2026-08-13 06:52:30.562573+00	2026-08-13 06:54:16.622149+00	\N	\N	\N
56567409-a9e9-4d27-bf98-158a384e10f1	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	LWD4fRWQQcneibFG5ZsiKyIB0px7lZCQb6a8Yor46Ow=	2026-08-20 06:54:16.622069+00	2026-08-13 06:54:49.248802+00	\N	2026-08-13 06:54:16.622149+00	2026-08-13 06:54:49.249024+00	\N	\N	\N
2845a521-ca8d-4ca5-a072-069e1c36fe21	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	GAB8oIgfAPPwU8EU94wLJGQbaMXP00VB01LhGKvg7cs=	2026-08-20 06:54:49.248943+00	2026-08-13 06:55:36.507829+00	\N	2026-08-13 06:54:49.249024+00	2026-08-13 06:55:36.508019+00	\N	\N	\N
cd654925-d826-489f-bb09-80553e418b84	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	ErvXJY/HnF3+EzNj9jE16IrtzcmSIa7NdQS/TqkgCvs=	2026-08-20 06:55:36.507939+00	2026-08-13 06:56:59.754057+00	\N	2026-08-13 06:55:36.508019+00	2026-08-13 06:56:59.754247+00	\N	\N	\N
90eba991-3edd-44da-99b1-73ce68d314f8	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	ng0OQXKhdb0C7q5sCwNnvMcOmBcPbd3YR+9K4t6eYM0=	2026-08-20 06:56:59.75417+00	2026-08-13 06:57:15.328442+00	\N	2026-08-13 06:56:59.754247+00	2026-08-13 06:57:15.328691+00	\N	\N	\N
d23f6968-562c-4054-953a-1e479cf31a7a	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	vIRJ2ztRyZ+Ef+2ZYvwlLkwcHGJ0OmLQ4EarnNnDQJc=	2026-08-20 06:57:15.328577+00	2026-08-13 06:57:33.228483+00	\N	2026-08-13 06:57:15.328691+00	2026-08-13 06:57:33.228676+00	\N	\N	\N
8ac736f6-6692-40e0-8b1a-6669fa03bff2	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	w9uTNvwLreyxRCkIuJ+m63VyYxV0g2OQ4CZM+zMaDQw=	2026-08-20 06:57:33.228603+00	2026-08-13 06:57:37.513071+00	\N	2026-08-13 06:57:33.228676+00	2026-08-13 06:57:37.513333+00	\N	\N	\N
3a5bfd69-9473-4cd2-81ac-9b29ef249580	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	b2MCbLIrv7Nna+FbeHmQlGr9t5tc4oZys17MV3Qp1I8=	2026-08-20 06:57:37.513183+00	2026-08-13 06:57:48.935006+00	\N	2026-08-13 06:57:37.513333+00	2026-08-13 06:57:48.935211+00	\N	\N	\N
68505096-c60a-43ed-bba6-29bad4481a90	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	nvovklJyKCxJdXEnQl2MEJnI8AMzCNAVsMUna8z/Hvc=	2026-08-20 06:57:48.935148+00	2026-08-13 06:58:19.071984+00	\N	2026-08-13 06:57:48.935211+00	2026-08-13 06:58:19.072146+00	\N	\N	\N
d7955ada-7a5a-4a3f-83df-3fcd7ec4b303	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	7xP5ZZqweUuRtSThkqmkMUkCKJpA7c3lbmLHHA1HjRw=	2026-08-20 06:58:19.072086+00	2026-08-13 06:59:42.060085+00	\N	2026-08-13 06:58:19.072146+00	2026-08-13 06:59:42.06039+00	\N	\N	\N
76efbc71-6851-4fae-a3cc-c06efd72e586	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	9dAU3egDkmgl90IOa1AxLba0xqsaqSlJvMsF89eC2Qw=	2026-08-20 06:59:42.060268+00	2026-08-13 07:00:35.94114+00	\N	2026-08-13 06:59:42.06039+00	2026-08-13 07:00:35.941293+00	\N	\N	\N
36d5b106-4d7b-415d-b782-0fce961ddde5	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	LXoMV2uPFYlPaq27xKcpIAqqgyUUg//mq4Dyy8jSXOk=	2026-08-20 07:00:35.941234+00	2026-08-13 12:29:53.428393+00	\N	2026-08-13 07:00:35.941293+00	2026-08-13 12:29:53.429536+00	\N	\N	\N
2f8ad056-72c5-4a39-94fb-a64d5cecd49c	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	C+3dNnQg/KWsu4sRjZoff4rP4JmArALPcUfZt1QVHHg=	2026-08-20 12:29:53.428835+00	2026-08-13 12:31:38.278223+00	\N	2026-08-13 12:29:53.429536+00	2026-08-13 12:31:38.27851+00	\N	\N	\N
6037eae2-7c98-4e3d-ae93-a1a76a776f51	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	NbocCcjLMJOh3H2rrcl6xRTKYZ8KYjblKfS82GVLw3A=	2026-08-20 12:31:38.278398+00	2026-08-13 12:33:09.061083+00	\N	2026-08-13 12:31:38.27851+00	2026-08-13 12:33:09.061095+00	\N	\N	\N
fc4240f8-8f6d-4dcd-9466-6f241ae47918	a3a20ac4-43a2-de64-52d3-bfafce7c7053	UTRokwKgx9sxU8b/Y+WoHYVXYmv/aSfJwZfooTFplaU=	2026-08-24 05:22:42.610608+00	2026-08-17 05:24:06.759829+00	\N	2026-08-17 05:22:42.637874+00	2026-08-17 05:24:06.759976+00	\N	\N	\N
e204cd7f-cc49-4c2f-9a50-eaee98a0e1aa	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UBtyrWkm/E4zseHiNBuVfFlJdLiWTEPYW/fvBk1OBNE=	2026-08-20 12:20:45.469098+00	2026-08-17 05:24:20.523136+00	\N	2026-08-13 12:20:45.495953+00	2026-08-17 05:24:20.524012+00	\N	\N	\N
6eecd095-a865-4a79-b81d-149245ed4125	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PImKEZT8dUjBUVMdFvns45RxZweE9Xa1VUFi8AKaKlQ=	2026-08-24 05:24:20.523346+00	2026-08-17 05:51:25.883728+00	\N	2026-08-17 05:24:20.524012+00	2026-08-17 05:51:25.884064+00	\N	\N	\N
54f43441-e0a3-496a-8871-409f17a30c5c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zqDRLXRu4yPMhW9wDR41AOp0hqkvDqPKPivBq4Dhae0=	2026-08-24 05:51:25.883961+00	2026-08-17 06:47:28.635743+00	\N	2026-08-17 05:51:25.884064+00	2026-08-17 06:47:28.636165+00	\N	\N	\N
1a3d99e3-0a37-4480-b116-53d3d26e04d8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yjaVLRPofiPtSEnAUcLsI5RjgR61QHTSK5xmPbI5e90=	2026-08-24 06:47:28.636007+00	2026-08-17 06:59:09.653545+00	\N	2026-08-17 06:47:28.636165+00	2026-08-17 06:59:09.653556+00	\N	\N	\N
63c7702e-922a-443d-981b-4a3a12c88cea	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	SudgUSxnXFkf9zSggUepummvXLYdyIQ+WS910nC7wBg=	2026-08-18 12:48:39.580998+00	2026-08-17 06:59:19.628582+00	\N	2026-08-11 12:48:39.581198+00	2026-08-17 06:59:19.628877+00	\N	\N	\N
de6290bb-ba37-46d5-bc89-4b9480130942	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	Rdai1JHCxNMvkPKKZBQ+6cN1wqde85J0gNGJ5M0jhO4=	2026-08-24 06:59:19.628763+00	2026-08-17 07:07:15.328802+00	\N	2026-08-17 06:59:19.628877+00	2026-08-17 07:07:15.328814+00	\N	\N	\N
921486ca-d276-4219-bb87-cb6d11b32efc	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	wzE1aKfgm90Hs/k9mOPD4o6yAUkAj0Wa4VJfYZ8rhf0=	2026-08-24 07:07:38.217353+00	2026-08-17 07:09:25.083891+00	\N	2026-08-17 07:07:38.217455+00	2026-08-17 07:09:25.083899+00	\N	\N	\N
b1a35eb0-7a61-49d8-94fe-36d0511a35ee	a3a20ac4-43a2-de64-52d3-bfafce7c7053	PvCfJMJdUQpxVdwx8zePx/pV9knnI75cUHJOFXNURLU=	2026-08-24 07:09:47.332047+00	2026-08-17 07:51:15.997439+00	\N	2026-08-17 07:09:47.332161+00	2026-08-17 07:51:15.998807+00	\N	\N	\N
02af14ab-a19a-4ee4-a27b-56fe9188e6b7	a3a20ac4-43a2-de64-52d3-bfafce7c7053	M0Ubqre77QBlDThVAVWeLOSsQL89p5v4QdmC9MlZ6+k=	2026-08-24 07:51:15.998539+00	2026-08-17 09:40:55.498481+00	\N	2026-08-17 07:51:15.998807+00	2026-08-17 09:40:55.498903+00	\N	\N	\N
60a9b1bb-3ff0-402f-bbe3-a549289f43a8	a3a20ac4-43a2-de64-52d3-bfafce7c7053	MabqnJ4XLw0zmX2Er66mlRYgSa7msl9NVx1LBZF2ebo=	2026-08-24 09:40:55.498766+00	2026-08-17 10:12:20.1334+00	\N	2026-08-17 09:40:55.498903+00	2026-08-17 10:12:20.133678+00	\N	\N	\N
52767a42-ef50-4364-984e-e01860676254	a3a20ac4-43a2-de64-52d3-bfafce7c7053	fPqUmuoCBvd3lUc4GpumUSF1iBZo1nrp9x2n/VAWbcI=	2026-08-24 10:12:20.133563+00	2026-08-17 10:20:35.376761+00	\N	2026-08-17 10:12:20.133678+00	2026-08-17 10:20:35.37677+00	\N	\N	\N
f44ff799-3ffb-4918-82d5-3e7242b11098	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	aOO7hi/LWNVwWok2I8QlwWrxANx5eImCO/obTBtnssA=	2026-08-24 10:20:58.948965+00	2026-08-17 10:32:11.513403+00	\N	2026-08-17 10:20:58.949083+00	2026-08-17 10:32:11.513525+00	\N	\N	\N
dd261d82-f27b-4303-8137-fb1713bc42b7	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	mB+IhTFMaYwCVNofjXxFvWhGYQJax02vBY2KRmZhVow=	2026-08-24 10:36:38.877053+00	2026-08-17 10:36:58.673084+00	\N	2026-08-17 10:36:38.877303+00	2026-08-17 10:36:58.673327+00	\N	\N	\N
6376cdfa-3bc2-4436-a60a-44aa3548d245	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	4eQMiSECbUK9dKRfrEzRnpZyQg/KTxQbyS8Bmv2imcM=	2026-08-24 10:36:58.67325+00	2026-08-17 10:37:08.617225+00	\N	2026-08-17 10:36:58.673327+00	2026-08-17 10:37:08.617438+00	\N	\N	\N
657f545c-b91b-4eac-ba45-dcd1c8ccad03	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	JudICHrXj5EZAp9DPnBI/upJBrR7g1pxEEOkprK0b64=	2026-08-24 10:37:08.617367+00	2026-08-17 10:40:02.718396+00	\N	2026-08-17 10:37:08.617438+00	2026-08-17 10:40:02.718609+00	\N	\N	\N
dea987eb-9288-42c6-a828-93e543fcf2e4	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	G4nML43+vYY7qxAq7AOSPGHUzXXyEjGT0xnb8BswowU=	2026-08-24 10:40:02.718533+00	2026-08-17 10:43:58.160294+00	\N	2026-08-17 10:40:02.718609+00	2026-08-17 10:43:58.160299+00	\N	\N	\N
037383f0-56ee-43ae-b2da-0873ec06bec1	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	YlL4YdrYlVsHDsCRyt//69eOr2ZWvNc0ESw/5fW5rso=	2026-08-24 10:43:58.426417+00	2026-08-17 10:44:35.249483+00	\N	2026-08-17 10:43:58.426521+00	2026-08-17 10:44:35.249488+00	\N	\N	\N
953536f9-a53c-41b2-a5f3-1c0999729d44	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	z8zjfqFJA2LXTADt8GuQgV12EXM44rLGxVPAFn6C34Q=	2026-08-24 10:44:35.519103+00	2026-08-17 10:44:41.865458+00	\N	2026-08-17 10:44:35.51919+00	2026-08-17 10:44:41.865464+00	\N	\N	\N
ce5bb2ce-2807-49ea-8661-212b4f7bfb81	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	w/rLaypYBJe0jJa8sB+4jqVfqTpvZQPBbCk1c0IKwb8=	2026-08-24 10:44:42.131366+00	2026-08-17 10:45:22.020328+00	\N	2026-08-17 10:44:42.131447+00	2026-08-17 10:45:22.020337+00	\N	\N	\N
2933b13b-4d23-4978-b7d2-4d3ce93d8043	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	0+1te1vnJYUOR+Cc/SjE6O1DTa4A9owaqIUNIUtiNaI=	2026-08-24 10:45:22.285011+00	2026-08-17 10:45:25.836309+00	\N	2026-08-17 10:45:22.285092+00	2026-08-17 10:45:25.836316+00	\N	\N	\N
ceb14726-d082-4d50-bebc-94ffb6e5ab1d	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	AzKSCSbcNCZDIxsqsgIJH4nZRVllWv21wnmUQIwh1ag=	2026-08-24 10:45:26.093568+00	2026-08-17 10:45:45.474665+00	\N	2026-08-17 10:45:26.093648+00	2026-08-17 10:45:45.47467+00	\N	\N	\N
270a48c1-f719-425b-a0fe-6ab4b24af149	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	hX2IfTK1XoMsZqEhO4vFgpzv183eNDTu9FAP1CPDW/w=	2026-08-24 10:45:45.738668+00	2026-08-17 10:46:56.0843+00	\N	2026-08-17 10:45:45.738749+00	2026-08-17 10:46:56.084305+00	\N	\N	\N
4385c9a5-f575-430a-b8fd-4262ff665eb6	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	iYKqoknlklm7bBDW+2hZxllX/3td4xDaaGukn1cfQGc=	2026-08-24 10:46:56.345214+00	2026-08-17 10:47:12.731553+00	\N	2026-08-17 10:46:56.345307+00	2026-08-17 10:47:12.731564+00	\N	\N	\N
6c2ee8ed-0bfd-4ad0-9e73-4ecd10827378	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	X+82mPLefzUjxOJy5KNsmoURTZpXnbbgUC5kg3jTeTk=	2026-08-24 10:47:12.993164+00	2026-08-17 10:47:16.6157+00	\N	2026-08-17 10:47:12.993239+00	2026-08-17 10:47:16.615708+00	\N	\N	\N
4365074e-38ef-433d-8a2a-f0e8be6ec2ca	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	CV13va5nZYXzdT13csA1gzVeEqLQ9erRiIa4nplXfX8=	2026-08-24 10:47:16.99847+00	2026-08-17 10:47:40.122478+00	\N	2026-08-17 10:47:16.998657+00	2026-08-17 10:47:40.122482+00	\N	\N	\N
6544a181-3f3a-4144-b056-379194a62c16	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	YbJGU2zFKIigooAUmT4FmscCc8Y+9jVSF6jxSjpP9cc=	2026-08-24 10:47:40.385244+00	2026-08-17 10:47:49.667816+00	\N	2026-08-17 10:47:40.386981+00	2026-08-17 10:47:49.667822+00	\N	\N	\N
19672997-467d-4eea-97eb-d151488dc172	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	obOWuTwqYJ+N77rOttpEpHOcwAOgpTvRU8ZyJVnQAxE=	2026-08-24 10:47:49.9316+00	2026-08-17 10:48:24.333861+00	\N	2026-08-17 10:47:49.931715+00	2026-08-17 10:48:24.333866+00	\N	\N	\N
541ca967-1936-4135-9a35-3be608b9ae69	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	q2KmFAK85c0/rN6nu4zkz/cd4qu4WQ+S5YogX6or+ww=	2026-08-24 10:48:24.59753+00	2026-08-17 10:48:41.263338+00	\N	2026-08-17 10:48:24.597752+00	2026-08-17 10:48:41.263344+00	\N	\N	\N
e326df90-628e-4116-b0c0-7080fcaa8600	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	xr1Sne+m16vH9x8Gp0wc2aEU0+FzFn9nr7a/agbZ3J4=	2026-08-24 10:48:41.557845+00	2026-08-17 10:50:13.037833+00	\N	2026-08-17 10:48:41.558007+00	2026-08-17 10:50:13.037838+00	\N	\N	\N
43ef2d5b-6c09-474f-bc30-da97e8fd918d	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	LYPcHQOAc9n3QOXe7neSoulka/Ow92yXZtzvBtZ12Ug=	2026-08-24 10:50:13.299617+00	2026-08-17 10:50:20.876595+00	\N	2026-08-17 10:50:13.299706+00	2026-08-17 10:50:20.876601+00	\N	\N	\N
0bc3e28b-84e1-43d6-8132-88c6bca7c9b1	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	M44mUgI8jhc5s0ZwYCuGScjDyusbEGVm66AsRSaU/ZQ=	2026-08-24 10:50:21.140025+00	2026-08-17 10:50:27.64179+00	\N	2026-08-17 10:50:21.140218+00	2026-08-17 10:50:27.641796+00	\N	\N	\N
f416f6e6-6d56-4b5e-aded-84a886efb76e	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	kz/mMj+npYsMPDl6vdeW88h7QpbHCOMlhkMUubEp4q8=	2026-08-24 10:50:27.903433+00	2026-08-17 10:53:53.276291+00	\N	2026-08-17 10:50:27.903527+00	2026-08-17 10:53:53.276675+00	\N	\N	\N
f0c0dbe2-26ad-412b-8fd4-efbdaf5f5049	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	QXvpTmPUzlpfZHTenK/cCB8ECqz74zoZ+qcCVmntsck=	2026-08-24 10:53:53.276475+00	2026-08-17 10:53:58.331222+00	\N	2026-08-17 10:53:53.276675+00	2026-08-17 10:53:58.33123+00	\N	\N	\N
9ac79ccb-6ecc-4c15-9809-3c7b3e27b855	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	/wR0iEd2XPqtKUl7r19/n/rTTmfhq1isi+m+NWo1o/8=	2026-08-24 10:53:58.598582+00	2026-08-17 10:54:16.392879+00	\N	2026-08-17 10:53:58.598656+00	2026-08-17 10:54:16.392886+00	\N	\N	\N
996ed647-7f80-47fd-a0b4-f83d44b7e768	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	sWdLC+bhYH12HZtz+n1ZbR+dOvw5TTLEYk+lrA1R8Z8=	2026-08-24 10:54:16.654392+00	2026-08-17 11:01:24.968089+00	\N	2026-08-17 10:54:16.654461+00	2026-08-17 11:01:24.968097+00	\N	\N	\N
0423fb6d-2a83-4d81-a3df-e5e2b6dcbcf8	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	w4gG5a9z1VqLsv425TFsoM2RltGR6ZwffxedixBWMx4=	2026-08-24 11:01:25.242308+00	2026-08-17 11:01:41.284327+00	\N	2026-08-17 11:01:25.242461+00	2026-08-17 11:01:41.284333+00	\N	\N	\N
7e38533f-dd2f-4fe4-bf29-e6187d9b13fe	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	gukOlFu0azfGFnYf8l5yAqp7Ifpyy57v5CEXBqS0O5Y=	2026-08-24 11:01:41.548449+00	2026-08-17 11:09:32.937037+00	\N	2026-08-17 11:01:41.548525+00	2026-08-17 11:09:32.937275+00	\N	\N	\N
99ee33e5-bff9-463f-9fa8-9d39f79c368a	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	LIghIk/fC+o7ntEwLtIH7e6FwZnfR3RU9/ojAaiBBJo=	2026-08-24 11:09:32.937167+00	2026-08-17 11:09:54.530607+00	\N	2026-08-17 11:09:32.937275+00	2026-08-17 11:09:54.530734+00	\N	\N	\N
356e8413-52ae-4e06-93cf-76e8d25cdea2	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	dyWgfntMI23FLx2INmRJpKTpWLQArmdEmGt5a4zM1HA=	2026-08-24 11:09:54.530689+00	2026-08-17 11:12:36.577252+00	\N	2026-08-17 11:09:54.530734+00	2026-08-17 11:12:36.57755+00	\N	\N	\N
b5b340e0-c6fd-41db-bbad-a3c917bc7ad0	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	X22WFXGZLaBDC3vZ4wb86BQuxKHhJMJpaCtDKFiBIIY=	2026-08-24 11:12:36.577473+00	2026-08-17 11:12:47.818417+00	\N	2026-08-17 11:12:36.57755+00	2026-08-17 11:12:47.818632+00	\N	\N	\N
f5d9057d-20f9-42d0-9a16-7f5739ad6528	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	w1QTd2jj6xg92smSFsDgxP/6bZBhh/WW39aLiyHq5w4=	2026-08-24 11:12:47.818543+00	2026-08-17 11:57:57.301662+00	\N	2026-08-17 11:12:47.818632+00	2026-08-17 11:57:57.301853+00	\N	\N	\N
45d529d1-7560-4ea9-bbcf-33dcf86bd316	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	iYOe4rauLCA9uhzDSPn7fXjlq1sjswl7BdxjxSG5zOM=	2026-08-24 11:57:57.301786+00	2026-08-17 11:58:01.233147+00	\N	2026-08-17 11:57:57.301853+00	2026-08-17 11:58:01.233153+00	\N	\N	\N
56f8022d-2eea-42ef-a4b1-8eaac79daf3a	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	w+1ZFejxPNm5sN/yNpv/rFDckomt1oGAkmnWTIW2azM=	2026-08-24 11:58:01.493103+00	2026-08-17 11:58:22.739138+00	\N	2026-08-17 11:58:01.493149+00	2026-08-17 11:58:22.739283+00	\N	\N	\N
84894395-e8b1-4e23-b646-d1f6bdefa8f7	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	8hOlS4EwUfx1WSFSd1n2ameFij+WyS4NYvP069xRfbs=	2026-08-24 11:58:22.739228+00	2026-08-17 11:58:56.769216+00	\N	2026-08-17 11:58:22.739283+00	2026-08-17 11:58:56.769221+00	\N	\N	\N
03a8d551-9d8f-4c57-9797-e8151c289481	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	YiNgOfLwPPYOybRDRyqJn6u6BU/lXnWkBCOtPXbuFeE=	2026-08-24 11:58:57.032888+00	2026-08-17 11:59:11.236353+00	\N	2026-08-17 11:58:57.032971+00	2026-08-17 11:59:11.236364+00	\N	\N	\N
e76879cd-819a-4c9b-8ba9-d8cd725fb410	1a077a8c-4029-8ded-d563-19e9b4bdf301	JWu33DcURBxZKZvUnQ9y45NGV53JGp5Bn5vUsl5ZuPI=	2026-08-24 11:59:11.502017+00	2026-08-17 11:59:20.424956+00	\N	2026-08-17 11:59:11.502093+00	2026-08-17 11:59:20.424962+00	\N	\N	\N
efd90bba-f5af-444b-bfd5-1242cdf26938	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	cMw6UtsbRIxFqYbje8SHl1amw+1qHYb/rRrKJkM3cnU=	2026-08-24 11:59:20.692077+00	2026-08-17 12:00:08.819642+00	\N	2026-08-17 11:59:20.692164+00	2026-08-17 12:00:08.819647+00	\N	\N	\N
4ada84c4-a2a6-4fe8-9deb-8055936c856a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	AV0nnowzbFdfkz1TRUg0cl34aIlABicVUvZL0H2v9z0=	2026-08-24 12:00:09.081062+00	2026-08-17 12:01:04.145933+00	\N	2026-08-17 12:00:09.081139+00	2026-08-17 12:01:04.145938+00	\N	\N	\N
dd292667-73be-460c-b02c-61f4ae0546db	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	cBPr0r1P95FvRxLPf+xTxKQg17tYPheiV6GOh5ijj3w=	2026-08-24 12:01:04.408471+00	2026-08-17 12:01:06.787854+00	\N	2026-08-17 12:01:04.408542+00	2026-08-17 12:01:06.787863+00	\N	\N	\N
9cc00de6-341f-485c-9c9c-da893cce4f20	1a077a8c-4029-8ded-d563-19e9b4bdf301	mpL/SZuExtOFIWYRx6iwcMdQv7QdtzLgidzQV8+T/0I=	2026-08-24 12:01:07.052642+00	2026-08-17 12:01:10.230649+00	\N	2026-08-17 12:01:07.052713+00	2026-08-17 12:01:10.230656+00	\N	\N	\N
9023b820-1fbe-4d16-9442-34d37ac84667	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	KeDrJ3IdXkZi2axBt2/AjoR1IHUGMJD6DJk+jYsdgEc=	2026-08-24 12:01:10.500611+00	2026-08-17 12:01:35.223805+00	\N	2026-08-17 12:01:10.500685+00	2026-08-17 12:01:35.223811+00	\N	\N	\N
9d56e385-c114-43f1-9b02-706e679836b8	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	klHXnr0Uf5TDJfp5CgvmLf5XjqoMY4x8tpBh75q5CLk=	2026-08-24 12:01:35.484363+00	2026-08-17 12:03:41.82769+00	\N	2026-08-17 12:01:35.484433+00	2026-08-17 12:03:41.827695+00	\N	\N	\N
1e26d3e9-48b5-4440-9f43-1b70a610934e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	oCMaYALIOjgQqakjGWSu2qP8oejmBSF9rppk+CT//oE=	2026-08-24 12:03:42.092473+00	2026-08-17 12:05:28.485642+00	\N	2026-08-17 12:03:42.092547+00	2026-08-17 12:05:28.48565+00	\N	\N	\N
d6449db7-bc10-4bc3-8eb6-347e23602f72	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	uZouvs+MGC0ulI6MQFlfW3zdpZ0vQcE2dXBioN8Oq+8=	2026-08-24 12:05:28.746379+00	2026-08-17 12:06:08.405843+00	\N	2026-08-17 12:05:28.746449+00	2026-08-17 12:06:08.405848+00	\N	\N	\N
4875465f-c85e-4ac8-a933-542c4813a7b6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NDJqCOFFqQvfeSODiUuZ1SvDnc5yWQGlUq064YBkAxA=	2026-08-24 12:06:08.670054+00	2026-08-17 12:07:03.008462+00	\N	2026-08-17 12:06:08.670129+00	2026-08-17 12:07:03.008634+00	\N	\N	\N
5ad1f0c7-fd9f-4418-ab01-827f0951294d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	djvl12nKc+1K7cdEygrLUv5o9/+WeOLs9ApO9SxZOqk=	2026-08-24 12:07:03.008561+00	2026-08-17 12:11:39.542794+00	\N	2026-08-17 12:07:03.008634+00	2026-08-17 12:11:39.542799+00	\N	\N	\N
81459026-5985-44c3-ae3c-22bc71a6aae9	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	0wiDfzkV0IfjiJEXF7WRqvTDeqNWnlWZvC3rwPmj3E8=	2026-08-24 12:11:39.810391+00	2026-08-17 12:13:29.169363+00	\N	2026-08-17 12:11:39.810512+00	2026-08-17 12:13:29.169369+00	\N	\N	\N
5561a6e3-d7da-4aa2-8b03-fdf02bea5472	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	CbM9QP2UVwAFEArs8a9eJVl7++ZWxFPsDCIwU1dgldQ=	2026-08-24 12:13:29.431843+00	2026-08-17 12:13:49.987614+00	\N	2026-08-17 12:13:29.432084+00	2026-08-17 12:13:49.987622+00	\N	\N	\N
dc7ee74d-47bd-47b8-93bd-c4bdc03dfe5b	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	+CaBJLFOqQEDd7JFTBEDPWqw5g+Q9gcOUA+5QgmoSt0=	2026-08-24 12:13:50.252252+00	2026-08-17 12:22:51.230058+00	\N	2026-08-17 12:13:50.252378+00	2026-08-17 12:22:51.230064+00	\N	\N	\N
a780dbd0-63fb-46f5-9d7a-6123c7f3204e	1a077a8c-4029-8ded-d563-19e9b4bdf301	uoBE430BtX5kiC+CkQKX0w3M1dby4FSygE05M7nnXeo=	2026-08-24 12:22:51.494942+00	2026-08-17 12:51:48.419883+00	\N	2026-08-17 12:22:51.495015+00	2026-08-17 12:51:48.420493+00	\N	\N	\N
c2d9b70d-72a2-49ed-ab90-23402302ca08	1a077a8c-4029-8ded-d563-19e9b4bdf301	/Eo9/2AOLIPdg3D7JI00pPYh4P7i2Xpa9fgBoxzEhUA=	2026-08-24 12:51:48.420147+00	2026-08-18 06:04:46.641879+00	\N	2026-08-17 12:51:48.420493+00	2026-08-18 06:04:46.709038+00	\N	\N	\N
9dab18c5-4910-494a-b916-3aec937e71dd	1a077a8c-4029-8ded-d563-19e9b4bdf301	LkZBd4w0HNdum6Lx3zjSCtTcvFuP81oLgR73qlN2/cs=	2026-08-25 06:04:46.694578+00	2026-08-18 06:15:37.201914+00	\N	2026-08-18 06:04:46.709038+00	2026-08-18 06:15:37.201951+00	\N	\N	\N
a59e4717-2357-4fd0-b2fd-5dd9ee769d5a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	hwPhi0LzFrSAfwtj8huu1g9S2O+aqf/X3x4jo6ax/PA=	2026-08-25 06:15:37.547392+00	2026-08-18 06:36:55.114218+00	\N	2026-08-18 06:15:37.548105+00	2026-08-18 06:36:55.114468+00	\N	\N	\N
6df01054-a8ad-4742-ad53-c19851281053	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CMP4L5BUxXJTDR4PpuUOwiRbiIePoHz6XWyFM4fekBg=	2026-08-25 06:36:55.114381+00	2026-08-18 06:43:46.723065+00	\N	2026-08-18 06:36:55.114468+00	2026-08-18 06:43:46.723515+00	\N	\N	\N
af696739-a803-4a43-8e3b-567844a027cd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	O743lYGzG6xw+Z+RBfTBRd/Cd2Czf72m1nhyWHwiL/4=	2026-08-25 06:43:46.723239+00	2026-08-18 06:43:58.968294+00	\N	2026-08-18 06:43:46.723515+00	2026-08-18 06:43:58.968586+00	\N	\N	\N
c267558c-3cb5-48b9-ac8e-2d07d1f48c63	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NnKGqdkaep4AfLfyYX0zIAHtGAsaworwHJfUtudrWbc=	2026-08-25 06:43:58.968511+00	2026-08-18 06:44:07.22374+00	\N	2026-08-18 06:43:58.968586+00	2026-08-18 06:44:07.224+00	\N	\N	\N
7a86fc1f-5fb9-411f-b7ad-e5520f2fe101	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yB3yXyWbKtKgBOitrgm8NZOeQuiGg8jfm6GXiJzQwNk=	2026-08-25 06:44:07.223879+00	2026-08-18 07:06:38.149149+00	\N	2026-08-18 06:44:07.224+00	2026-08-18 07:06:38.149505+00	\N	\N	\N
9f2b67b9-bd27-42bb-be70-4de4ddf15fd6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	D594vU8FtTydw0DmzLvHb+Y49dvrT7rikcNYMNd/eXY=	2026-08-25 07:06:38.149374+00	2026-08-18 07:09:18.859075+00	\N	2026-08-18 07:06:38.149505+00	2026-08-18 07:09:18.859085+00	\N	\N	\N
15a95332-3ea7-4ecc-b6d5-72db6234e7e3	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	Eh+/oUSPyqYCSqV4RiTZFnQrh7TX4igHqfeMH3HicUE=	2026-08-25 07:09:19.146082+00	2026-08-18 07:09:23.23619+00	\N	2026-08-18 07:09:19.146189+00	2026-08-18 07:09:23.236218+00	\N	\N	\N
278d92b2-25a3-47f9-a091-87ad855eddd9	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	+zNF2QWPzd8qCKWgWtxr5vMen5AEbGOtfHr+LOHz3/w=	2026-08-25 07:09:23.508183+00	2026-08-18 07:09:47.936992+00	\N	2026-08-18 07:09:23.508276+00	2026-08-18 07:09:47.937013+00	\N	\N	\N
dc7be323-2a20-47f9-8f76-77bb576160f7	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	1ftvK7RxlbL/ty1Pc1ksRXNTNlVyKFHFCegEWInMwm4=	2026-08-25 07:09:48.225427+00	2026-08-18 07:09:55.565042+00	\N	2026-08-18 07:09:48.225901+00	2026-08-18 07:09:55.565059+00	\N	\N	\N
23490e7f-54f2-4464-b431-fa870660070a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0UnYTsBzhYrbgfOg6/Sbn9omVrvPkr2yiEBjDaOfnMI=	2026-08-25 07:09:55.853521+00	2026-08-18 07:34:20.105403+00	\N	2026-08-18 07:09:55.853621+00	2026-08-18 07:34:20.10581+00	\N	\N	\N
59951542-5164-4aa0-abff-c3c170fa18d6	40517b71-5e62-182e-73b5-d4070e20a3c2	iGYBKSDZ1wWr2sJpdjmQZpg6Hr5CJWauaqKjC8Yyu1Q=	2026-08-20 06:42:59.444945+00	2026-08-18 07:55:49.935567+00	\N	2026-08-13 06:42:59.445702+00	2026-08-18 07:55:50.051097+00	\N	\N	\N
d463ab4a-3b16-489e-98f9-070648a1fab2	40517b71-5e62-182e-73b5-d4070e20a3c2	jk72bJ98xNWx8GFKdZHI3Q94GdGT1vZ1Y6D5O30zUGs=	2026-08-25 07:55:50.024753+00	2026-08-18 07:55:58.104331+00	\N	2026-08-18 07:55:50.051097+00	2026-08-18 07:55:58.105943+00	\N	\N	\N
85a43101-0d36-4bfb-a372-7790c5905f39	40517b71-5e62-182e-73b5-d4070e20a3c2	/KEzeFcJmB1rDk2muQ37bIOgW6QV41IWZBLP3mzBX6s=	2026-08-25 07:55:58.104735+00	2026-08-18 07:56:05.500545+00	\N	2026-08-18 07:55:58.105943+00	2026-08-18 07:56:05.501025+00	\N	\N	\N
2cc55021-2e6d-49c6-938a-89c56c54290c	40517b71-5e62-182e-73b5-d4070e20a3c2	i2px2FluP6HRfIpKZDH9cJnvWyFOQ6ovUUh0UiiMe94=	2026-08-25 07:56:05.500882+00	2026-08-18 07:56:16.328741+00	\N	2026-08-18 07:56:05.501025+00	2026-08-18 07:56:16.329137+00	\N	\N	\N
f9b4e8a7-dd18-449a-91a9-8f9e7bf5281f	40517b71-5e62-182e-73b5-d4070e20a3c2	6dw4wxVmeEjgVaXgZEHiClLNDjbKKcdY0V28yZ1LQ9c=	2026-08-25 07:56:16.329009+00	2026-08-18 08:11:05.416066+00	\N	2026-08-18 07:56:16.329137+00	2026-08-18 08:11:05.478112+00	\N	\N	\N
475f620e-63a6-4db0-91f2-48ab79ffab72	40517b71-5e62-182e-73b5-d4070e20a3c2	83h2UsYCG/aTufqUXjflt+02dVafPA+LNxFAb6A5hSE=	2026-08-25 08:11:05.452909+00	2026-08-18 08:11:15.150239+00	\N	2026-08-18 08:11:05.478112+00	2026-08-18 08:11:15.152167+00	\N	\N	\N
d4461809-271f-4f34-8858-374ae6b24c6c	40517b71-5e62-182e-73b5-d4070e20a3c2	d1W4+A3xQoQtf9iRb2xejMNYJdhdZvfq0+a89Kfwof0=	2026-08-25 08:11:15.150909+00	2026-08-18 08:11:22.76849+00	\N	2026-08-18 08:11:15.152167+00	2026-08-18 08:11:22.76884+00	\N	\N	\N
ce8f1ffd-ced8-43bc-8b20-ddeb9ad34bec	40517b71-5e62-182e-73b5-d4070e20a3c2	wmhvNz3wKtj8IzZJtCwB7wtjP2ILtmasDgnZnUEBEps=	2026-08-25 08:11:22.768708+00	2026-08-18 08:11:33.201462+00	\N	2026-08-18 08:11:22.76884+00	2026-08-18 08:11:33.202857+00	\N	\N	\N
63f5345f-be99-4590-8e62-0c321eb7ae8d	40517b71-5e62-182e-73b5-d4070e20a3c2	scmZITNm+ugBp5fc/OB8y8JZXTOWdYplAD5PftwNLnU=	2026-08-25 08:11:33.202436+00	2026-08-18 08:12:06.309241+00	\N	2026-08-18 08:11:33.202857+00	2026-08-18 08:12:06.356712+00	\N	\N	\N
da11478f-fadc-4b0e-8b87-aeb8926171c3	40517b71-5e62-182e-73b5-d4070e20a3c2	gst/FlRWp+DwSAtCoE8B2ZOBs7gzVlMaHVzo2ohEIXc=	2026-08-25 08:12:06.336376+00	2026-08-18 08:12:58.421849+00	\N	2026-08-18 08:12:06.356712+00	2026-08-18 08:12:58.481994+00	\N	\N	\N
46686659-7ebb-41a5-9e1d-7ae822bf9b6e	40517b71-5e62-182e-73b5-d4070e20a3c2	lKtzYNRnnZgSFvJranL0MbEIE99XDxp5SC503rUiBAA=	2026-08-25 08:12:58.455833+00	2026-08-18 08:23:38.029323+00	\N	2026-08-18 08:12:58.481994+00	2026-08-18 08:23:38.059042+00	\N	\N	\N
3fecdcc5-8f97-4527-ac12-ff40a0d8d200	40517b71-5e62-182e-73b5-d4070e20a3c2	o18OCX3UbPf4ItAVPKoNPIWINFk9bX0gGPuDaSNJCSo=	2026-08-25 08:23:38.053951+00	2026-08-18 08:23:48.144203+00	\N	2026-08-18 08:23:38.059042+00	2026-08-18 08:23:48.145189+00	\N	\N	\N
678be74e-813d-45d4-90dc-dd39d766c9d6	40517b71-5e62-182e-73b5-d4070e20a3c2	kYBP1RRZ7S0APr+B2aASjxrZZUcRJar2UaT+nYvFjsw=	2026-08-25 08:23:48.144976+00	2026-08-18 08:23:58.141131+00	\N	2026-08-18 08:23:48.145189+00	2026-08-18 08:23:58.141542+00	\N	\N	\N
c3fe1af9-835b-4456-8dc3-3acd4efae5fb	40517b71-5e62-182e-73b5-d4070e20a3c2	joORer50DRws+Cvck4xbOb5pqCti8KPiTCAm3lBuiXc=	2026-08-25 08:23:58.141461+00	2026-08-18 08:25:33.560391+00	\N	2026-08-18 08:23:58.141542+00	2026-08-18 08:25:33.644941+00	\N	\N	\N
407dad73-66f3-4103-a273-99f8029128fb	40517b71-5e62-182e-73b5-d4070e20a3c2	DrSphijeoqv9Yf9jZsjpguXpGBDwna9Rmn5/S5g2NSw=	2026-08-25 08:25:33.611333+00	2026-08-18 08:25:46.027363+00	\N	2026-08-18 08:25:33.644941+00	2026-08-18 08:25:46.03023+00	\N	\N	\N
f32eff42-0648-436e-bfd0-154eb7e0ca75	40517b71-5e62-182e-73b5-d4070e20a3c2	oFdVVA/qAogEbQjObwHaVWdDbTROKrjvzNuehWWjhCU=	2026-08-25 08:25:46.028154+00	2026-08-18 08:25:57.140625+00	\N	2026-08-18 08:25:46.03023+00	2026-08-18 08:25:57.141107+00	\N	\N	\N
2c6900bc-d6a2-4820-94b5-9ca3c39fd365	40517b71-5e62-182e-73b5-d4070e20a3c2	TNqnFSP3DHw2rwTtfsxpWDD6fxSo2hWbiqBbYi6u1+E=	2026-08-25 08:25:57.140943+00	2026-08-18 08:26:13.718938+00	\N	2026-08-18 08:25:57.141107+00	2026-08-18 08:26:13.719999+00	\N	\N	\N
4b833d4d-f763-48b0-9a75-f5e4dd645046	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zkXgsvEMMNZ54OU2KR1czFKwV2OQwvFF4YhNiGyi79M=	2026-08-25 07:34:20.105633+00	2026-08-18 09:13:33.051695+00	\N	2026-08-18 07:34:20.10581+00	2026-08-18 09:13:33.102443+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
58f453f4-9370-472d-adcc-0cc7840cdd09	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	wpZjUbmUcckhBOZ4Ab59yt5hXxeHG5XyaEbR3BxcDdc=	2026-08-25 09:13:33.099022+00	2026-08-18 09:13:39.930326+00	\N	2026-08-18 09:13:33.102443+00	2026-08-18 09:13:39.931264+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eebe5b3c-af28-4ebb-b5cb-7cd65cc047dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	lILkkaH3kDSxnMJRBcBcRETcf5q3drgs0uYsAY2AQB4=	2026-08-25 09:13:39.930731+00	2026-08-18 09:13:41.890343+00	\N	2026-08-18 09:13:39.931264+00	2026-08-18 09:13:41.890703+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6867b401-390a-4fe2-b4bf-230066a1c7f7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8qHkf+tasX4/V1qtPqnclNmESk2fLCf9ZBlb50SpcEo=	2026-08-25 09:13:41.890545+00	2026-08-18 09:21:07.670719+00	\N	2026-08-18 09:13:41.890703+00	2026-08-18 09:21:07.671009+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
61cf05ac-5626-4982-8196-80993c90b9f3	40517b71-5e62-182e-73b5-d4070e20a3c2	t1+AHGxH/i9ivoo1ZCEYQsqWXtE80pMxCJ5QMOVEObg=	2026-08-25 08:26:13.719699+00	2026-08-18 09:22:40.902063+00	\N	2026-08-18 08:26:13.719999+00	2026-08-18 09:22:40.956184+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
762af9f5-48c3-4ffd-baf6-155c21dee5f8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	wb57Z+ir1BMMf63ljsYC3xPOJ/wpBAnofsgXb1oQ9qs=	2026-08-25 09:21:07.670886+00	2026-08-18 09:23:15.039933+00	\N	2026-08-18 09:21:07.671009+00	2026-08-18 09:23:15.04024+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
31a99adb-4d6f-4b1a-9918-156b0059c18e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	MgGbD8gqfcZakK10M0E1r1brKmTumygjCiT4SAjO7cQ=	2026-08-25 09:23:15.040137+00	2026-08-18 09:23:44.965452+00	\N	2026-08-18 09:23:15.04024+00	2026-08-18 09:23:44.965697+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
47411ef7-c88e-4e44-bb21-85f642120434	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	69mavGk2yB/TA5eVNDfQJt2pXj3A+h+wFnJia4CYlA4=	2026-08-25 09:23:44.965607+00	2026-08-18 09:23:50.000873+00	\N	2026-08-18 09:23:44.965697+00	2026-08-18 09:23:50.000888+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d3fcede7-1dce-44fe-9631-b732543d777d	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	mgutPEB165Ppt6Q3ZmXBYAMY9HZMmM+XxCS0dl3Dkzs=	2026-08-25 09:23:50.291237+00	2026-08-18 09:23:53.62998+00	\N	2026-08-18 09:23:50.291394+00	2026-08-18 09:23:53.630002+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d6a9f7a0-d3ec-4cab-82b7-56fe1cb3e788	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Bp/jYuPnLXcSPyOUwy0PDMwLfvi/IXYvGpQf+YcAdkc=	2026-08-25 09:23:53.911165+00	2026-08-18 09:26:11.515594+00	\N	2026-08-18 09:23:53.911304+00	2026-08-18 09:26:11.515927+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
858bb977-76b8-4aaf-9a56-466891d9f279	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	k7QCQyx5RST9NO7VdXh7EW/8qC/c4aM60hD354M5HmQ=	2026-08-25 09:26:11.515808+00	2026-08-18 09:33:32.855972+00	\N	2026-08-18 09:26:11.515927+00	2026-08-18 09:33:32.856303+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d57d8f4b-68b5-46e9-a7ab-4fef218f255c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	txJRPyv/D1kliiXuP5WLDJu1hHvJMJba9/7E9E+1xOk=	2026-08-25 09:33:32.856156+00	2026-08-18 09:38:32.30151+00	\N	2026-08-18 09:33:32.856303+00	2026-08-18 09:38:32.325655+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
128efd61-eff0-4f9b-9d97-1333b3e98b47	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	H4+tqyrps9ABEEm+5l9JZpNYDTBIrXoTAr3e2FNRKrA=	2026-08-25 09:38:32.311122+00	2026-08-18 09:44:34.76033+00	\N	2026-08-18 09:38:32.325655+00	2026-08-18 09:44:34.760347+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2162b7fc-19e9-4129-97b6-deaf76a5a3d6	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	AnOqV8psR2qz4ZJpeI86Az2/AUL2Lzb3Qp/WmYJFzFA=	2026-08-25 09:44:35.061904+00	2026-08-18 09:45:17.67873+00	\N	2026-08-18 09:44:35.062646+00	2026-08-18 09:45:17.679028+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
48cc138e-42f0-4ae3-9946-f668e804d822	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	bi21YGJn6gsh84TqvNVYBz1L91Pt6pNCvPG7WqdhZLI=	2026-08-25 09:45:17.678897+00	2026-08-18 09:46:12.267054+00	\N	2026-08-18 09:45:17.679028+00	2026-08-18 09:46:12.267327+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8e6156e0-e938-4471-bd6c-be757425bfe7	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	gMZkcXFbbOhbIAlRX6zVkKr4p0vO25GkyoWCDMLfrb0=	2026-08-25 09:46:12.267226+00	2026-08-18 09:50:14.393206+00	\N	2026-08-18 09:46:12.267327+00	2026-08-18 09:50:14.393469+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d9827d93-2e19-45d9-99de-fd089e85f5f5	40517b71-5e62-182e-73b5-d4070e20a3c2	anxVVS6OJPaHXggO+2roxQFiT+7Ut1yD07NaFmvphXE=	2026-08-25 09:22:40.944076+00	2026-08-19 05:53:03.173649+00	\N	2026-08-18 09:22:40.956184+00	2026-08-19 05:53:03.210399+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9a2f42eb-3f6d-4cad-b713-0e5d6b72ab2a	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	gSR6mb2pPVQ/kaVfmnwBmdAX6gaq2eTkNwHfGLK8aqY=	2026-08-25 09:50:14.393361+00	2026-08-18 09:51:21.388712+00	\N	2026-08-18 09:50:14.393469+00	2026-08-18 09:51:21.388962+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ff010552-7d89-4ef3-9f68-30d1575ce743	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	SHZEZAS7gky+EFQOoQE6RUPvxxOFGblDF16x/tt+Wwg=	2026-08-25 09:51:21.388855+00	2026-08-18 09:51:33.421785+00	\N	2026-08-18 09:51:21.388962+00	2026-08-18 09:51:33.422492+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1f00b00d-e450-4bdf-afeb-4ff56431ad87	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	zS+Vcar9XluVVZ78hHe5jH9jpZPYMl8b8ANjS9hJYvw=	2026-08-25 09:51:33.422384+00	2026-08-18 09:51:39.222135+00	\N	2026-08-18 09:51:33.422492+00	2026-08-18 09:51:39.22215+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
46598717-4367-4d14-b5bc-70a651415671	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	1mBqXOeL8VRfG2EnzhZs8m1dk0Ss4lQf+hFCF1dqEas=	2026-08-25 09:51:39.5081+00	2026-08-18 09:51:45.122662+00	\N	2026-08-18 09:51:39.508212+00	2026-08-18 09:51:45.122882+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
56d4c702-7395-47a8-a862-b49904f5afba	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	8+Sdq/0F4hz5bvuDnBxHH1V8zsZvupQXpylp2TJPME8=	2026-08-25 09:51:45.122797+00	2026-08-18 09:52:40.854381+00	\N	2026-08-18 09:51:45.122882+00	2026-08-18 09:52:40.854627+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
62fb0d05-04c5-477d-b863-e2a8efe0d271	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	S17Dez/+wlm6KfI2CTrdcGz0pq0cjWUwkD3Y3+Q/u9c=	2026-08-25 09:52:40.854511+00	2026-08-18 09:54:18.504876+00	\N	2026-08-18 09:52:40.854627+00	2026-08-18 09:54:18.504888+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bfcffa72-1b52-4768-818b-9682909cb92e	730809c0-fc01-a664-03ca-28e0e32d0393	ejof79VsXW70mBHgEWoeWBa9wWL4j2fDhyNnZWesAhE=	2026-08-25 09:54:18.78921+00	2026-08-18 10:00:47.141784+00	\N	2026-08-18 09:54:18.789316+00	2026-08-18 10:00:47.141806+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3952a555-233b-497e-9b17-d83f6cb56be4	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	3fUqVQ+h6W9zoaOScgg7JWuluyF+ImX8CgKLwxObaAk=	2026-08-25 10:00:47.388612+00	2026-08-18 10:00:49.841561+00	\N	2026-08-18 10:00:47.388725+00	2026-08-18 10:00:49.841804+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cad3c0ab-bd1c-45e4-ab67-f55e17fe8959	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	kCUvGBxPcpSotWCSQyPAkiKVcvm/OBPMFgylEve1IMk=	2026-08-25 10:00:49.8417+00	2026-08-18 10:00:54.231529+00	\N	2026-08-18 10:00:49.841804+00	2026-08-18 10:00:54.23154+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
78e356fe-8f00-49f6-bf7e-f578eef12a7b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	50P9Ur6T1qrVUHTB7+BzdncOeLS7ln5xHu0LasKi9ak=	2026-08-25 10:00:54.5114+00	2026-08-18 10:05:48.762691+00	\N	2026-08-18 10:00:54.511499+00	2026-08-18 10:05:48.762718+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
96ff51ee-fe39-4217-94f7-565589af347d	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	vcuKj2pvsoUJ9DKvBUgQGREYAu7ISR930+54I3LGcfY=	2026-08-25 10:05:49.018162+00	2026-08-18 10:05:55.654132+00	\N	2026-08-18 10:05:49.018302+00	2026-08-18 10:05:55.654305+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fd605b55-f7b1-484e-85a1-a8629a64206d	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	xjIQGvFHe1CxGpE1kZX8kAHJ88RQjFXzfbBLYud35hI=	2026-08-25 10:05:55.654235+00	2026-08-18 10:06:07.538097+00	\N	2026-08-18 10:05:55.654305+00	2026-08-18 10:06:07.538327+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
92fa9224-2833-4e79-b583-48ea4a68531b	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	2xhd8coSZSodmTczDelfFLFii3h0FlMjrybcY5skyC0=	2026-08-25 10:06:07.53823+00	2026-08-18 10:06:10.536225+00	\N	2026-08-18 10:06:07.538327+00	2026-08-18 10:06:10.536233+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
779242cf-d0bb-4bf1-91b5-4d07ee3924d0	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	NzWIS/EIqDh+vdWDRU72sbR+NmACUPDXM5C4URPXZFE=	2026-08-25 10:06:10.818358+00	2026-08-18 10:06:19.410703+00	\N	2026-08-18 10:06:10.818455+00	2026-08-18 10:06:19.410982+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c0e0fd6e-b3f5-4176-862b-9740cfec8d42	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	56i7URAZuvuR38VSHDrV0HVXbDXM/lweufJABsLA5vU=	2026-08-25 10:06:19.410909+00	2026-08-18 10:07:14.036166+00	\N	2026-08-18 10:06:19.410982+00	2026-08-18 10:07:14.036174+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a7d0d6fd-a68b-438b-8ade-095e009ca984	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8T5E5KfBMeqOu0SbXPpRgQjc/JhqTmkcdemHzdT0IAc=	2026-08-25 10:07:14.337347+00	2026-08-18 10:08:30.377917+00	\N	2026-08-18 10:07:14.337431+00	2026-08-18 10:08:30.37816+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
17595729-94f0-4f7e-95e7-ca1868bcf2de	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4zhXNGSnB5gPNgq8hqfKmYuVraQIgKZF/rqRO+wIADo=	2026-08-25 10:08:30.37809+00	2026-08-18 10:19:00.987139+00	\N	2026-08-18 10:08:30.37816+00	2026-08-18 10:19:00.987502+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b9bcac2f-69c1-4805-9de9-1dd9f984bac8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UNqd4WtnrVth7warYSf29e59mL4+x6eruAPyIcDWKFU=	2026-08-25 10:19:00.987285+00	2026-08-18 10:22:00.688782+00	\N	2026-08-18 10:19:00.987502+00	2026-08-18 10:22:00.689086+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1607a9a4-433d-49f7-9ae6-18de2055ac2d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8uPUGwwJbL41wyHN7nNvpu4NstGwKDfUWFuqmNTX9Q4=	2026-08-25 10:22:00.688924+00	2026-08-18 10:41:49.022918+00	\N	2026-08-18 10:22:00.689086+00	2026-08-18 10:41:49.058965+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4c02a7ab-1b51-4fdc-aba4-b5d449900095	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	jOyYU56SgooK3WNnmdlpXn8+695iBfnlEO3b0GzLWf4=	2026-08-25 10:41:49.045336+00	2026-08-18 10:45:51.620293+00	\N	2026-08-18 10:41:49.058965+00	2026-08-18 10:45:51.620604+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6bd30d86-9c7c-44c9-8402-498d1c086f99	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	WS7OLZ0cEiddzsviRyCjTujZQRbtGeLj1nipjGw9ZDY=	2026-08-25 10:45:52.066793+00	2026-08-18 11:01:49.579342+00	\N	2026-08-18 10:45:52.076151+00	2026-08-18 11:01:49.579853+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b1486843-5360-47a4-8016-36f6c2e6a7d8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	oZ09Cg+CEB0j5hr+YzaLuqDGXRQOwO6lJVNzWrZp17U=	2026-08-25 11:01:49.579745+00	2026-08-18 11:02:00.820013+00	\N	2026-08-18 11:01:49.579853+00	2026-08-18 11:02:00.82029+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ff5d189d-4f8f-4400-991a-cb99202a7c72	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9IvcG9ngjwR7zeLlOqV7HN5vp01dI73prSsOI/0bgDk=	2026-08-25 11:02:00.820212+00	2026-08-18 11:02:23.652811+00	\N	2026-08-18 11:02:00.82029+00	2026-08-18 11:02:23.653208+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
77f4b2f9-f8f7-4dc4-b38f-c08569e0208a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ww6hP7OdVaksYjR0bcQWD5YtRK5dumffRWQaM5urlec=	2026-08-25 11:02:23.653005+00	2026-08-18 11:03:01.079041+00	\N	2026-08-18 11:02:23.653208+00	2026-08-18 11:03:01.07945+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ce42e50e-d5a9-4a06-926d-679ca3840caa	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	MiSxhAG60S49p1rYb4FzbLWo/Qo/xRP9ZVOAWfBYhTA=	2026-08-25 11:03:01.079333+00	2026-08-18 11:04:55.073713+00	\N	2026-08-18 11:03:01.07945+00	2026-08-18 11:04:55.074033+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7ece2484-4eb6-4e7b-9ef9-cdacd33e8f04	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yzB1AN62GOfmDW9xHjEasd+IWAad//hbz0M0g1vJItw=	2026-08-25 11:04:55.073936+00	2026-08-18 11:13:18.39907+00	\N	2026-08-18 11:04:55.074033+00	2026-08-18 11:13:18.399337+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
622f9d1f-8513-4fa0-bed3-91e123682a0b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vFVNTXYYIo27aGQXytA2noKb4QwL9vd3dZ4wWqyV/8Q=	2026-08-25 11:13:18.39925+00	2026-08-18 11:40:24.313892+00	\N	2026-08-18 11:13:18.399337+00	2026-08-18 11:40:24.313907+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
016aa96b-53c1-4150-90f4-514149507d16	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	B7sV/LZDkJRy29acea1ikXcnfeeCwYsTA+XG0ZCGLH0=	2026-08-25 11:40:24.632916+00	2026-08-18 12:20:57.853572+00	\N	2026-08-18 11:40:24.633039+00	2026-08-18 12:20:57.871677+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
362b346a-1ee0-4980-8dd3-808e9db0a79a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	LmNUw16EpsacwmZu5WoAScS4R8WkpQ6DMkgU1jmQttQ=	2026-08-25 12:20:57.864432+00	2026-08-18 12:27:07.948572+00	\N	2026-08-18 12:20:57.871677+00	2026-08-18 12:27:07.949054+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9f2f9456-2762-41dd-a1eb-d5c775ce0d1b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	avX3fPCfnNNjznMHUz0Yp4zZyXqcseLljFsRPVYaNfo=	2026-08-25 12:27:07.948923+00	2026-08-18 12:50:38.518359+00	\N	2026-08-18 12:27:07.949054+00	2026-08-18 12:50:38.558875+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3f0986e0-c3d7-41dc-b1ce-7f5f87f0b129	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5vzj25e/yGGmI1LRDb+Jho6l9AUffUh8X1sA8ccXj1o=	2026-08-25 12:50:38.544526+00	2026-08-18 12:50:42.518598+00	\N	2026-08-18 12:50:38.558875+00	2026-08-18 12:50:42.52006+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2b88e865-3e19-4b4b-a7b8-fade729f705e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DRvXOcwthR3ucK/cfIezk0w8r5yA+nlJuDqSmM2TTYI=	2026-08-25 12:50:42.519089+00	2026-08-18 12:52:10.026522+00	\N	2026-08-18 12:50:42.52006+00	2026-08-18 12:52:10.026982+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
54fd8666-ebdb-45a9-84f5-9563b8c09e1d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	EjXGzCPYoc+o+tgzNafopod3xRA2EmRW4SzX+ovqZKA=	2026-08-25 12:52:10.026829+00	2026-08-18 12:59:54.615056+00	\N	2026-08-18 12:52:10.026982+00	2026-08-18 12:59:54.628604+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fce13779-a0b8-4f81-954a-8a017bf25e62	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4CV3HTzAwZmWIAC5qvJ728H7++X20+SPSqIPX805cyU=	2026-08-25 12:59:54.624206+00	2026-08-18 13:13:02.067444+00	\N	2026-08-18 12:59:54.628604+00	2026-08-18 13:13:02.081607+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c3662cc4-309f-4fb1-9e87-35e7c70c1e47	40517b71-5e62-182e-73b5-d4070e20a3c2	jkQaW2VYrMdpcgMKHRtadaPOew8ypApmJDxXitL1Bb8=	2026-08-26 05:53:03.196938+00	2026-08-19 05:53:13.333435+00	\N	2026-08-19 05:53:03.210399+00	2026-08-19 05:53:13.333748+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0c1b08f0-50fa-4b45-8a4a-62aa254639c1	40517b71-5e62-182e-73b5-d4070e20a3c2	mxPJk7RtwX0H1SvzRMf38Q9vX8Ajo53tdmSSRv56eM0=	2026-08-26 05:53:13.333649+00	2026-08-19 05:53:18.001111+00	\N	2026-08-19 05:53:13.333748+00	2026-08-19 05:53:18.001404+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
629a739d-6dfd-41ce-8a78-bbbbb5c17a4e	40517b71-5e62-182e-73b5-d4070e20a3c2	vQTFc0X+a5tlgkE1z9z5qTecRgR/n8cS+/J3Wqjs5Ig=	2026-08-26 05:53:18.001299+00	2026-08-19 05:53:22.904552+00	\N	2026-08-19 05:53:18.001404+00	2026-08-19 05:53:22.904776+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cf0fa00b-6e75-46d8-bf16-6e1cb726d56e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0h+CXsZZ2pEQf2W36xZLlfBP71QSsYz7MF0XdxxBY9U=	2026-08-25 13:13:02.076612+00	2026-08-19 05:59:17.961018+00	\N	2026-08-18 13:13:02.081607+00	2026-08-19 05:59:18.00206+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e46a29d7-532e-4111-9784-e0e879f7bcbe	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xZankbuGhRs8zaxWkHl1kHlRzJnkbmHAjAh/GpU0Zjs=	2026-08-26 05:59:17.988493+00	2026-08-19 06:10:45.639798+00	\N	2026-08-19 05:59:18.00206+00	2026-08-19 06:10:45.640135+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e965a144-ec53-4ed7-8818-c53405b1d025	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Xm/7vKi3omDHs/WNio7vc1WCC38EexqtZeD52xH58Ls=	2026-08-26 06:10:45.640004+00	2026-08-19 06:35:35.767731+00	\N	2026-08-19 06:10:45.640135+00	2026-08-19 06:35:35.804034+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
425f440a-4cbc-4c5e-a4e4-ac3b4652ce4e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	i4ze+/WK64CCqOBJ1mLxlyafLcoaTdKZMfzW/X5mC1A=	2026-08-26 06:35:35.790371+00	2026-08-19 07:07:20.487244+00	\N	2026-08-19 06:35:35.804034+00	2026-08-19 07:07:20.487755+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
341d6b78-11cf-44ba-bf9a-868c9c0afc1b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	M+w+UBNTmFisc/lWSveL77zlo/IQy53xygDk9pfCPUo=	2026-08-26 07:07:20.487565+00	2026-08-19 07:07:28.283252+00	\N	2026-08-19 07:07:20.487755+00	2026-08-19 07:07:28.283888+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ab2531a4-ddb3-456d-a73d-2b2595d59d6b	40517b71-5e62-182e-73b5-d4070e20a3c2	0cOnEPa0VTwr255Ja9mOj5meF22Q16B6cvwM7dYTRVs=	2026-08-26 05:53:22.904713+00	2026-08-20 11:39:07.220747+00	\N	2026-08-19 05:53:22.904776+00	2026-08-20 11:39:07.290346+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
91d8849b-c19b-4d38-a541-894f3ba3de05	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	6MaPxYU4m6FIJDsbO5KF2JKzevvHNdji26HPWHWKW5c=	2026-08-26 07:07:28.283581+00	2026-08-19 08:16:05.718042+00	\N	2026-08-19 07:07:28.283888+00	2026-08-19 08:16:05.71903+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0d64fbaa-6c2c-4999-afb9-f58591acb7d2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	7e9ZKc2sSiQD9LgoI/BRoA+AYJaVwq2CciEx0Ho5Euc=	2026-08-26 08:16:05.71857+00	2026-08-19 08:19:45.842031+00	\N	2026-08-19 08:16:05.71903+00	2026-08-19 08:19:45.842043+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
459f14c6-905e-4c49-8478-5182110bd0f3	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	Xd5fougKqblrLegIzBlh0n0s+nYXKYd8A+AqrgDf3dU=	2026-08-26 08:19:46.152796+00	2026-08-19 08:19:54.634756+00	\N	2026-08-19 08:19:46.152897+00	2026-08-19 08:19:54.635023+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b3a3354b-f090-4366-b048-9a68c827b995	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	RfPKp/BZ6ps1XeXw4YmMi/pfqwyErL7iTmxnL/q1sfQ=	2026-08-26 08:19:54.63489+00	2026-08-19 08:20:02.539678+00	\N	2026-08-19 08:19:54.635023+00	2026-08-19 08:20:02.539693+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1ee1b738-0c4e-4a6a-97a2-7ae0b5e9d703	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fOFdKVKls9qr5kxoXAua6PMSE7LcVvTDNA5uyIBLSwY=	2026-08-26 08:20:02.844585+00	2026-08-19 08:40:37.619729+00	\N	2026-08-19 08:20:02.844715+00	2026-08-19 08:40:37.621029+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bba60a1a-097e-4af8-a0cd-5622ec01bd79	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NciDn0O37/isZXoAnI58/KGjuSdhlYkMiKhU/QcxWr4=	2026-08-26 08:40:37.620799+00	2026-08-19 09:09:54.737594+00	\N	2026-08-19 08:40:37.621029+00	2026-08-19 09:09:54.738048+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6968ba55-04b1-4bd5-ac96-6f3d560b1c76	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0SwuoUvhuni2Oa3PCiWxkhCiPY2HhNUn8xz6IoH0PHI=	2026-08-26 09:09:54.737873+00	2026-08-19 09:11:17.835781+00	\N	2026-08-19 09:09:54.738048+00	2026-08-19 09:11:17.836084+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a6deb5f2-7e78-4de2-bc72-1f56a5020268	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	S0Cd45ea6MKQIaCYkB75/rHHZzJ26tsDCM3Blk2sS2Q=	2026-08-26 09:11:17.835987+00	2026-08-19 09:55:30.115776+00	\N	2026-08-19 09:11:17.836084+00	2026-08-19 09:55:30.205188+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
19ba4979-f76f-45ca-b451-7406ad1b6bec	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	floYEtcBJKjRNBThsRZ5dYpacg2W6m839CPIPBDaALA=	2026-08-26 09:55:30.181735+00	2026-08-19 10:22:54.657196+00	\N	2026-08-19 09:55:30.205188+00	2026-08-19 10:22:54.658847+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c6e3510b-7f35-47ea-a29f-9ffc084ecedd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tUsbfuJyRzqPpaxCdX4Y4hfaUMSTq6CJ8Meba3u+qr0=	2026-08-26 10:22:54.657559+00	2026-08-19 13:00:25.937784+00	\N	2026-08-19 10:22:54.658847+00	2026-08-19 13:00:25.938973+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
07a76bad-157b-4bf9-9d70-2a0a26145d23	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	X9zeXfX6KqMmESDhgL1uSwvUwZx6m9qMR+uuwR5IoTU=	2026-08-27 04:54:50.419756+00	2026-08-20 05:16:31.20644+00	\N	2026-08-20 04:54:50.446547+00	2026-08-20 05:16:31.20774+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
49a4243f-61e8-4054-8611-f68cbfca0968	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	kCALGA218sOcBaydvQcqE/KgMDS1gEjPLQofVcMU1Lw=	2026-08-27 05:16:31.206878+00	2026-08-20 05:16:43.939064+00	\N	2026-08-20 05:16:31.20774+00	2026-08-20 05:16:43.939079+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
816b84c8-7608-4d5f-90f6-806d09575112	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CyLDNVnl9zrQzoprE4Y5NUZJ7FGci82RlsD+JVLC90o=	2026-08-26 13:00:25.938528+00	2026-08-20 05:16:44.236708+00	\N	2026-08-19 13:00:25.938973+00	2026-08-20 05:16:44.237101+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5d3eeb55-d3ed-43f9-8d83-6061a231fb13	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nRee/Zdqt/CDRpH3i7HBAFJzyJm6Hx+i7fnYb0+bNjg=	2026-08-27 05:16:44.236956+00	2026-08-20 05:22:22.429747+00	\N	2026-08-20 05:16:44.237101+00	2026-08-20 05:22:22.429777+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f65cd211-7aa1-4d81-b516-b3662d8056ff	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	6RDUCa2mc7jdGiFcIFNCYU4FPhVVK0sI97jRHjxjvoM=	2026-08-27 05:22:22.77919+00	2026-08-20 05:22:32.534279+00	\N	2026-08-20 05:22:22.779324+00	2026-08-20 05:22:32.534294+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
548c45c1-2d4e-4a98-aacf-6354970352fd	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	fb8ZP7CvjovY8FLybCjbjdCA9mWAwRDYeUYw+C6Lwzc=	2026-08-27 05:22:32.831805+00	2026-08-20 05:22:47.043776+00	\N	2026-08-20 05:22:32.831916+00	2026-08-20 05:22:47.043976+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
43dea5a3-d549-4ee1-890d-8c7ef918d995	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	1pziPIZn1jTCiuShYprgmDZlUzxvb1xj8ppkw6oyA88=	2026-08-27 05:22:47.043902+00	2026-08-20 05:22:49.93762+00	\N	2026-08-20 05:22:47.043976+00	2026-08-20 05:22:49.937814+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0c97b096-e11b-48c7-acd5-b99cca92fe9c	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	x2+qAQCxrSPBZBshZBm3xVaVBhsSZgeB9fBoxMPLGdA=	2026-08-27 05:22:49.93774+00	2026-08-20 05:22:56.99612+00	\N	2026-08-20 05:22:49.937814+00	2026-08-20 05:22:56.996133+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
18ccbd03-a7ed-4fdf-84a6-829c27ad4fb0	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	YZ5PDDvvf1tLDXhQC/M3+0VgXyg5N2JwBHl+VjVoHtA=	2026-08-27 05:22:57.272417+00	2026-08-20 05:23:12.872512+00	\N	2026-08-20 05:22:57.272522+00	2026-08-20 05:23:12.872525+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7f9e0c00-a810-4255-a162-1efb42c94db0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	pcDIApd6rpkaXgKIWo3Tx8uW2IIGWtMEDj9rSRTPPuE=	2026-08-27 05:23:13.154274+00	2026-08-20 05:29:32.052095+00	\N	2026-08-20 05:23:13.154383+00	2026-08-20 05:29:32.05236+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
befbe1be-9fc1-4751-86bd-3940b1e03556	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	e1F399DSd979chtNINeB7STeeFxaBayB/LReGlbiIYg=	2026-08-27 05:29:32.052281+00	2026-08-20 05:49:16.959187+00	\N	2026-08-20 05:29:32.05236+00	2026-08-20 05:49:16.95942+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f4dd0b9d-7b27-420c-ad9a-2c66efac9c8c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Zy3K8pmLcBkZUzs5FasA3LlenRicPhsm0RtIFICInwI=	2026-08-27 05:49:16.959314+00	2026-08-20 05:51:53.859285+00	\N	2026-08-20 05:49:16.95942+00	2026-08-20 05:51:53.859298+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5bcf54a8-fb74-4a25-b41b-8b0ed066a751	730809c0-fc01-a664-03ca-28e0e32d0393	b/cHDcDKUwOqLz9P9XKptjVpB/17laX9aN+/9lWEBEw=	2026-08-27 05:51:54.14091+00	2026-08-20 05:52:08.491146+00	\N	2026-08-20 05:51:54.14099+00	2026-08-20 05:52:08.491157+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f237fe9c-dc03-445a-83e9-878d66a02609	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4roANFH6n2L0jG6yX6NK2nfXaI5jaUrWYF8cEbZc/Og=	2026-08-27 05:52:08.770248+00	2026-08-20 05:54:15.783252+00	\N	2026-08-20 05:52:08.770332+00	2026-08-20 05:54:15.783569+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
befa7bf8-0288-43e3-b5d9-5b06a2e09936	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nibbgdgBUriZhnW8DU25yW+IGJS3vWA2vDQ/aMgVFeo=	2026-08-27 05:54:15.783486+00	2026-08-20 06:09:39.564277+00	\N	2026-08-20 05:54:15.783569+00	2026-08-20 06:09:39.614405+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
43625dca-2aa9-4dc8-8e48-bc4d6ca27a1a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sDe2OmS28yfI9+CoIdKM6Kpdvk3b9dZinSigssVSzhE=	2026-08-27 06:09:39.611417+00	2026-08-20 06:26:46.337242+00	\N	2026-08-20 06:09:39.614405+00	2026-08-20 06:26:46.338098+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c6dda07d-1152-4198-b0f8-43eeb6204405	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	D8KfQlClXTCpGtq0mQh67v4Mf5T1dDSjkPlDn3Zl+yU=	2026-08-27 06:26:46.337832+00	2026-08-20 06:26:47.648411+00	\N	2026-08-20 06:26:46.338098+00	2026-08-20 06:26:47.648632+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aa0b13f8-a7e3-412c-9151-ebbacc879f49	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SzZa+OtUjpzIACate58YoGFClP1A8IcKXyzRyzWrO68=	2026-08-27 06:26:47.648553+00	2026-08-20 06:27:11.032269+00	\N	2026-08-20 06:26:47.648632+00	2026-08-20 06:27:11.03265+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
13d77c65-eb9f-4950-919c-f458a0dfe69e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2poswNgw18KpevvBY2X+8UyBkzV1p1ZJ1u1ILWvVvTQ=	2026-08-27 06:27:11.032463+00	2026-08-20 06:27:29.054438+00	\N	2026-08-20 06:27:11.03265+00	2026-08-20 06:27:29.054765+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ffd2aef3-bb6a-4991-8611-451e294d7cc9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ySRJiIN40u3RvwTHW7zYGeoDGRuO72em0QQLTg/mx3U=	2026-08-27 06:27:29.054608+00	2026-08-20 06:31:20.343464+00	\N	2026-08-20 06:27:29.054765+00	2026-08-20 06:31:20.343478+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
df5dd2d2-ffbd-4a03-8d3f-2d8336a2c8b5	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	nK7bAecDhbhLHlPlKGhVn+YCxWNgQAdFQzBqJX3aOsU=	2026-08-27 06:31:20.652568+00	2026-08-20 06:31:44.723431+00	\N	2026-08-20 06:31:20.652716+00	2026-08-20 06:31:44.723443+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
91b2ef48-b343-4c11-8742-bfeb3507be83	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	bEcDrQAKYPK6M/WZZFa2qd+vvTi3HT7BJcbBwZ3n/78=	2026-08-27 06:31:45.025348+00	2026-08-20 06:31:56.630118+00	\N	2026-08-20 06:31:45.025533+00	2026-08-20 06:31:56.63081+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1a1c0192-b0ad-48c7-8a2a-21c2ca7fcafc	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	YBPOrfh5JE5Ml20zLpdimGvcg8SjV/Y4DAs+70+vBM8=	2026-08-27 06:31:56.630722+00	2026-08-20 06:32:06.680399+00	\N	2026-08-20 06:31:56.63081+00	2026-08-20 06:32:06.680411+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aa46604a-1ff2-488b-a47a-96bbe65fd3da	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3pJyJfdaeDivsuYUc/wAE3X8x3RLHSpImCX1AoF3KIc=	2026-08-27 06:32:06.996671+00	2026-08-20 06:36:21.900097+00	\N	2026-08-20 06:32:06.996802+00	2026-08-20 06:36:21.900397+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
355a20fe-b394-4c19-9edc-6654a9960e0f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1iFI0cIJwqn0RY87xtEqyFMfH/wBdphtpZqKCQPoGUs=	2026-08-27 06:36:21.900303+00	2026-08-20 07:44:33.005985+00	\N	2026-08-20 06:36:21.900397+00	2026-08-20 07:44:33.006879+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
05f4efd5-4b81-4695-a550-20f8d0f978c9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4m7B67RUb7W4iPHOv7LQ0NLOdomIPX+R/f/B/mDj1VQ=	2026-08-27 07:44:33.006504+00	2026-08-20 07:47:36.797128+00	\N	2026-08-20 07:44:33.006879+00	2026-08-20 07:47:36.797687+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1725fb2a-47e6-4a07-89ba-d80378e93728	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	lD1VjWhNEDVv/rWRDlH49bZzIJOreLMeWCx9/dR11RQ=	2026-08-27 07:47:36.7975+00	2026-08-20 08:13:35.343627+00	\N	2026-08-20 07:47:36.797687+00	2026-08-20 08:13:35.343894+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a9d98629-6dd1-4f9a-9d35-da07bd65e30b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	z6HgFecouAbQXlOR/TTGAJzWgknlDVmLgz/CB7oU85Y=	2026-08-27 08:13:35.343823+00	2026-08-20 08:13:39.333837+00	\N	2026-08-20 08:13:35.343894+00	2026-08-20 08:13:39.334048+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
21211769-dbc7-47b1-aade-13ca799d9266	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	cdPx9fOVQkyyJ2qjv2KSaf2zfhqoqLX5ybT7W3kvsiI=	2026-08-27 08:13:39.333961+00	2026-08-20 08:14:09.669258+00	\N	2026-08-20 08:13:39.334048+00	2026-08-20 08:14:09.730421+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1954f17a-fb2d-468c-b02b-49e13f0a810a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Oq45dXU0o9ToGgYtUPY0vogSVVDpqwgJMr4TQP39SUo=	2026-08-27 08:14:09.71612+00	2026-08-20 08:41:48.89982+00	\N	2026-08-20 08:14:09.730421+00	2026-08-20 08:41:48.901266+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3861efb9-7146-491d-b7fd-60aea1a98766	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5vHBZDd1X6TFLzzwVD55WkxopxqDmuPSPjPkrKMHbnc=	2026-08-27 08:41:48.90015+00	2026-08-20 08:56:47.69703+00	\N	2026-08-20 08:41:48.901266+00	2026-08-20 08:56:47.697366+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1c4f2c1c-3360-4b1c-abac-fbddf1ef6b98	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ePKuajRtz4lrIc/shP20J2n4x9ZvP+e+19VCgRVzK7g=	2026-08-27 08:56:47.6972+00	2026-08-20 09:07:30.295971+00	\N	2026-08-20 08:56:47.697366+00	2026-08-20 09:07:30.296263+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
66f3ba99-2a5f-45d1-8b4b-9b25916e97c2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sO39KYg5oPKsU2ohwr/MMenPCIHvSlbfgYNRDBMkYdY=	2026-08-27 09:07:30.296139+00	2026-08-20 09:37:12.275338+00	\N	2026-08-20 09:07:30.296263+00	2026-08-20 09:37:12.275955+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b7ee7933-9891-4599-9080-ee51e017d067	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eJadRJ4fwlZSFaSgpf4u6aSmlwgbZ6hT+1wB3wgDVtQ=	2026-08-27 09:37:12.275751+00	2026-08-20 09:38:10.427303+00	\N	2026-08-20 09:37:12.275955+00	2026-08-20 09:38:10.465762+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b89bae8e-1d68-42af-95f8-ace5ea08b5c9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	F1lw17pCGiJIR9sLXBJOYP231MP9/3B64i80k4UDOhA=	2026-08-27 09:38:10.451759+00	2026-08-20 09:46:12.356907+00	\N	2026-08-20 09:38:10.465762+00	2026-08-20 09:46:12.357373+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5c426124-e067-4aef-8dd5-13a1d85e2e49	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eXEkkinY5A4Js0c+Gvrln+b/uafy09So70YXZThQTi0=	2026-08-27 09:46:12.357209+00	2026-08-20 09:55:39.349092+00	\N	2026-08-20 09:46:12.357373+00	2026-08-20 09:55:39.349373+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b0858732-938f-444c-9735-1b38367cf593	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tQr44MAXQKd05ibgdff8u7KOGZ+W4+Euj1NpXqJRidw=	2026-08-27 09:55:39.349275+00	2026-08-20 09:56:26.692507+00	\N	2026-08-20 09:55:39.349373+00	2026-08-20 09:56:26.692783+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
70f41315-6892-4c19-93d6-411af374836c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	w9P4SGluG1oZCj9PdTsjhLBep8yiGJ8xMc3cHp/JX4A=	2026-08-27 09:56:26.692671+00	2026-08-20 09:58:43.072686+00	\N	2026-08-20 09:56:26.692783+00	2026-08-20 09:58:43.072984+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cecb327c-f457-4839-b2fa-b8aa6b036709	40517b71-5e62-182e-73b5-d4070e20a3c2	3zLy6TtOST2p1Ii/TMLuuThS/C2M0HTsYxXbFaiwqIY=	2026-08-27 11:39:07.274313+00	2026-08-20 11:39:16.328081+00	\N	2026-08-20 11:39:07.290346+00	2026-08-20 11:39:16.331243+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
986a7c9c-111c-4cf5-b546-f0bd9a8eb31b	40517b71-5e62-182e-73b5-d4070e20a3c2	dR2mWNCuzVOWfDS9eg1fJDg6taNFnnfyz3Pi3On7v1Q=	2026-08-27 11:39:16.329258+00	2026-08-20 11:39:29.456306+00	\N	2026-08-20 11:39:16.331243+00	2026-08-20 11:39:29.456812+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3d6d5f70-7625-4e59-a4b3-53465b39d6bc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	XY/vMiDNyDC8UXlgw3YhdqZWj2VqPz6rcSZcUKZ7N5Y=	2026-08-27 09:58:43.072878+00	2026-08-20 11:40:39.638772+00	\N	2026-08-20 09:58:43.072984+00	2026-08-20 11:40:39.700767+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
91ea98e1-78d0-4743-b555-d315222820fc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BvttgHYh9mhuK9hE82MHTCyqmMS5hlcXLT4DtYVQiww=	2026-08-27 11:40:39.675696+00	2026-08-20 12:08:38.581793+00	\N	2026-08-20 11:40:39.700767+00	2026-08-20 12:08:38.583693+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
465061a7-37a6-40da-859e-07251442ff95	40517b71-5e62-182e-73b5-d4070e20a3c2	9rYdGIaOrO0lGLLDRmF0Axcgjml0KcF//twrhpu50ow=	2026-08-27 11:39:29.456636+00	2026-08-20 12:25:03.347202+00	\N	2026-08-20 11:39:29.456812+00	2026-08-20 12:25:03.394673+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c4528faf-7b2a-444f-99a3-3bf8bdd3bd63	40517b71-5e62-182e-73b5-d4070e20a3c2	Ry7tuR8MtzsgW1j9R5fm47gYE1g4o0wQNcImnIxyd7k=	2026-08-27 12:25:03.387748+00	2026-08-20 12:25:14.362821+00	\N	2026-08-20 12:25:03.394673+00	2026-08-20 12:25:14.363486+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f3e68cd5-10ea-4f73-bc5c-10421b4f2317	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8XEVU3ozUwMt8u5bYfVjXZposfSBQO5E9T7OsTdhn/8=	2026-08-27 12:08:38.582232+00	2026-08-20 12:47:10.476276+00	\N	2026-08-20 12:08:38.583693+00	2026-08-20 12:47:10.512606+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a06f15c6-1feb-4563-a0a5-43a918187b5d	40517b71-5e62-182e-73b5-d4070e20a3c2	AEY0lqZEBfE7x8dS5kyMCUfdZSFvBU3x+LMD+Ug1rew=	2026-08-27 12:25:14.363184+00	2026-08-20 12:51:15.34747+00	\N	2026-08-20 12:25:14.363486+00	2026-08-20 12:51:15.518234+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a9116bba-91bb-4051-ae1e-5a43dc47462b	40517b71-5e62-182e-73b5-d4070e20a3c2	+te74zgZVM0hvUqx8jt9msUw/oiwl7ccOm2wtwpf2RY=	2026-08-27 12:51:15.488629+00	2026-08-20 12:51:33.265842+00	\N	2026-08-20 12:51:15.518234+00	2026-08-20 12:51:33.267916+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
075d5aa2-8751-474a-bd69-56c46a5deeba	40517b71-5e62-182e-73b5-d4070e20a3c2	3Sprvkju0t+Vs+uJNK+wLE9mbIX1XLbEFE6DeYVdc54=	2026-08-27 12:51:33.267005+00	2026-08-20 12:57:51.320449+00	\N	2026-08-20 12:51:33.267916+00	2026-08-20 12:57:51.375579+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0ed7fbeb-28ef-48d8-a511-f0698e02ee98	40517b71-5e62-182e-73b5-d4070e20a3c2	tOuytEfEcKTTLn0QvqCfmw5ox5pbT1rl7AN7kmw7Q6E=	2026-08-27 12:57:51.352159+00	2026-08-20 12:58:00.489331+00	\N	2026-08-20 12:57:51.375579+00	2026-08-20 12:58:00.492443+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
88fe9f44-f142-45a5-bbc0-12bffe612e8f	40517b71-5e62-182e-73b5-d4070e20a3c2	Z95EnrXvNGZ4M4XhaJDv5loW42l69HkjoOpu8jnwIhU=	2026-08-27 12:58:00.490288+00	2026-08-20 12:58:09.065827+00	\N	2026-08-20 12:58:00.492443+00	2026-08-20 12:58:09.066351+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f095ef3d-64bb-4add-b410-b22884eb7c50	40517b71-5e62-182e-73b5-d4070e20a3c2	aOhysexmjF56MHcqSgTxGDc4nMsdVyBdn7x1FfVvxd0=	2026-08-27 12:58:09.066191+00	2026-08-20 12:58:18.588921+00	\N	2026-08-20 12:58:09.066351+00	2026-08-20 12:58:18.589414+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cb6336a9-f358-404f-b025-336f3518b4d6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	LIvtgoQWzmwvGF7BJpR6SybzWZCNlCrQ/Y4RsVc6JsQ=	2026-08-27 12:47:10.499095+00	2026-08-20 12:59:49.686441+00	\N	2026-08-20 12:47:10.512606+00	2026-08-20 12:59:49.843329+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
027c5539-18c0-45f6-ae7d-3eef19d778eb	40517b71-5e62-182e-73b5-d4070e20a3c2	40WbjJ7ZVr13T6NlmcxW/Z1GGVmVGC2TsJpH39svk9o=	2026-08-27 12:58:18.589255+00	2026-08-20 13:08:52.512445+00	\N	2026-08-20 12:58:18.589414+00	2026-08-20 13:08:52.61241+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
916612ba-eea9-4777-84f4-a1f8f05ea675	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rF35vDwojlbHELc656O9k5PQrhdieL2EKSnPAu14Ho8=	2026-08-27 12:59:49.77799+00	2026-08-20 13:09:53.334192+00	\N	2026-08-20 12:59:49.843329+00	2026-08-20 13:09:53.49059+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b6569287-c5f6-4d88-9533-e6c89d7ac4e9	40517b71-5e62-182e-73b5-d4070e20a3c2	BzG7eGNQuhKbbwShL3aqTBkWaVaimOiMCYshBMEfUH0=	2026-08-27 13:08:52.568079+00	2026-08-20 13:18:11.608328+00	\N	2026-08-20 13:08:52.61241+00	2026-08-20 13:18:11.667575+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dca001d4-f0e9-449c-8182-55f946c36756	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+T72G5ikcOyvFVtgo/53ewQ/DcrxI/UA25ZQsCe5B/E=	2026-08-27 13:09:53.429091+00	2026-08-20 13:20:41.663288+00	\N	2026-08-20 13:09:53.49059+00	2026-08-20 13:20:41.75561+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
90bb4fe6-b24f-4466-b0b6-d1395d508715	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YxLGj8BKXWxM3IWmpeVQnIkda9cklhBwaeaE0ks2Q6M=	2026-08-27 13:20:41.726215+00	2026-08-20 14:24:37.369534+00	\N	2026-08-20 13:20:41.75561+00	2026-08-20 14:24:37.370064+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1e1dc715-b6b1-4358-93dd-afadd452f21d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	6dQHHltS9WkOKUcoXD7PGMTNqzCIE+S/xrhPqJxgwt8=	2026-08-27 14:24:37.369863+00	2026-08-21 05:11:11.936452+00	\N	2026-08-20 14:24:37.370064+00	2026-08-21 05:11:11.937611+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
77828064-53a5-4e5b-941b-94d8eef0ed91	40517b71-5e62-182e-73b5-d4070e20a3c2	r5kPYR2nTjzE9RyYh5Ddgz+opppRX5cFPqQuNzG1HrQ=	2026-08-27 13:18:11.644995+00	2026-08-21 05:21:39.09619+00	\N	2026-08-20 13:18:11.667575+00	2026-08-21 05:21:39.161314+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0599d66b-0640-404e-b305-c701b1ed5bd5	40517b71-5e62-182e-73b5-d4070e20a3c2	tqAnySY58YIJ6NPfI9Fuq3jWp80Ooi/mJpkjrfGIewc=	2026-08-28 05:21:39.146833+00	2026-08-21 05:21:44.762235+00	\N	2026-08-21 05:21:39.161314+00	2026-08-21 05:21:44.763575+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6c053081-0329-419c-ade5-1f810d8b954c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HjXdiAnZFcE3XF7kgeB6UOYp5PrsiCD/zX8qlSGmjw0=	2026-08-28 05:11:12.430875+00	2026-08-21 05:25:20.946787+00	\N	2026-08-21 05:11:12.44118+00	2026-08-21 05:25:20.987635+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
238868d0-2d58-4a15-b823-a38155048433	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	c+LMoI0qIs1s0y7UBVUIiiaTsS4Hh7gRsSwKxhjdSUU=	2026-08-28 05:25:20.972286+00	2026-08-21 05:28:15.646781+00	\N	2026-08-21 05:25:20.987635+00	2026-08-21 05:28:15.648214+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8306fea7-db4c-4720-91f7-6fb9766a1b49	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4TQuaPhBZWYe79Rxv9BpLq1gmOmp33AbDPRe5QdgN6I=	2026-08-28 05:28:15.647095+00	2026-08-21 05:55:43.885138+00	\N	2026-08-21 05:28:15.648214+00	2026-08-21 05:55:43.899675+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2278d2fe-6950-4c43-928a-1b06f1c0be4a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	VmrfmmqvMGzuufpo7esS2BAXBzgWp8MikKHD5EExaEM=	2026-08-28 05:55:43.895358+00	2026-08-21 05:56:04.663605+00	\N	2026-08-21 05:55:43.899675+00	2026-08-21 05:56:04.664106+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
19f02dd9-e5f9-4d2e-82d3-eb292aa2fbc5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	389YSNnwo1VeDHToBrsE2VAKJbeI68nxt9xCSnuK2DI=	2026-08-28 05:56:04.663966+00	2026-08-21 05:56:05.665341+00	\N	2026-08-21 05:56:04.664106+00	2026-08-21 05:56:05.665747+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
56538167-1be4-4ed7-ad96-e435cdc8f157	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xjG9q92aCIU6ghJymVon7mhsTLoJMK4fC9ho9dsjLek=	2026-08-28 05:56:05.665599+00	2026-08-21 05:57:05.386329+00	\N	2026-08-21 05:56:05.665747+00	2026-08-21 05:57:05.386625+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fa9e621b-138b-4a8a-8d7f-150c85a1ff4b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+rk5ZnwDAoMNBZd/lPnB3LoGl97RAm9IJXg0AYFXVH4=	2026-08-28 05:57:05.386514+00	2026-08-21 05:58:07.22071+00	\N	2026-08-21 05:57:05.386625+00	2026-08-21 05:58:07.220987+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1050e771-08cf-4c7b-9161-4f203e24c57d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4EEVpwMgbGzz5VxtukVr0nJTOF1TDGvLxxz8qtdSmpw=	2026-08-28 05:58:07.220907+00	2026-08-21 05:59:38.648888+00	\N	2026-08-21 05:58:07.220987+00	2026-08-21 05:59:38.649154+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e0df4f1d-4460-45a6-8ef5-e19c8d6a9ae5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	FzgXooh2Th+xn3oZlwK4W1Lg+F2tRxVqmls0A5mxOTY=	2026-08-28 05:59:38.649074+00	2026-08-21 06:01:16.953901+00	\N	2026-08-21 05:59:38.649154+00	2026-08-21 06:01:16.954725+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2c296133-3f36-4666-82ce-712a10d48aca	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BMRPlR0p33l3kdYj81JsrkJVUUsh9YYlm9woQQgf30c=	2026-08-28 06:01:16.954608+00	2026-08-21 06:08:08.292535+00	\N	2026-08-21 06:01:16.954725+00	2026-08-21 06:08:08.340073+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7dcdd696-db39-40f1-9dc8-8bb2bec80d25	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	RLs+MW4+aWJM7ERqQjwAQNG8sCWZTrXW3aXUz14Bfm4=	2026-08-28 06:08:08.320956+00	2026-08-21 06:08:21.483237+00	\N	2026-08-21 06:08:08.340073+00	2026-08-21 06:08:21.484295+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3dc5fb8c-b39b-4796-a2c0-6157847c3eab	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fRQMFfoembKwfGC2tNtvvsNYgpaplP82G/gspJB0kzo=	2026-08-28 06:08:21.483629+00	2026-08-21 06:08:22.485639+00	\N	2026-08-21 06:08:21.484295+00	2026-08-21 06:08:22.485864+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
11e91f68-3f8c-46c8-a511-9b0ef2039205	40517b71-5e62-182e-73b5-d4070e20a3c2	Xjp9Jp7IGSLyk81RMsa4IpH35QCJ0N5Pk4cTUbvrokA=	2026-08-28 05:21:44.762699+00	2026-08-21 06:21:18.975465+00	\N	2026-08-21 05:21:44.763575+00	2026-08-21 06:21:19.00936+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
873f2a5e-fed8-4a86-8d13-dad33de17b5c	40517b71-5e62-182e-73b5-d4070e20a3c2	jwOFEEmzZV1NRB5reYHbOmr7PvzTWDF98m5IveVtjf8=	2026-08-28 06:21:18.996436+00	2026-08-21 06:21:24.062247+00	\N	2026-08-21 06:21:19.00936+00	2026-08-21 06:21:24.063461+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
470f1775-74d0-4675-9876-d30c20bd33a4	40517b71-5e62-182e-73b5-d4070e20a3c2	HambJ7BGsdjaWe27pW4WTIBvCKr2Fmy1afMNw2OpMLA=	2026-08-28 06:21:24.06266+00	2026-08-21 06:21:28.781372+00	\N	2026-08-21 06:21:24.063461+00	2026-08-21 06:21:28.781771+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c6027f46-82ba-4bfe-9af8-9d8a4acee77e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	RYS4VHGJ1dP0AdaiMbXqHg8+AqVzLCZC9fy1HCMaNgs=	2026-08-28 06:08:22.485782+00	2026-08-21 06:26:04.448974+00	\N	2026-08-21 06:08:22.485864+00	2026-08-21 06:26:04.470537+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
be85a87f-1bb6-4475-85f9-cb1f281de97a	40517b71-5e62-182e-73b5-d4070e20a3c2	nvEe8R45FUYsrOuGp2tIIE6M3q+KA1RgMZiDiW3pMbE=	2026-08-28 06:21:28.781654+00	2026-08-21 06:21:33.376751+00	\N	2026-08-21 06:21:28.781771+00	2026-08-21 06:21:33.377009+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c1f7b1e2-a73b-4b6c-b294-530e218aee5c	40517b71-5e62-182e-73b5-d4070e20a3c2	cjr0kSWVJFlsDkHdCqa9S7bLV7TT2RgGPUTV5ctfAWg=	2026-08-28 06:21:33.37693+00	2026-08-21 06:21:37.975206+00	\N	2026-08-21 06:21:33.377009+00	2026-08-21 06:21:37.975497+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
987ee536-151d-47e7-be75-fd3ac5e472f5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	gTeh3cqMveF5yemDod73xB1ICWr4So0K0NDTJuMgAyo=	2026-08-28 06:26:04.457552+00	2026-08-21 06:26:10.677701+00	\N	2026-08-21 06:26:04.470537+00	2026-08-21 06:26:10.680216+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5abc56c2-ae85-4927-8363-d666f116a86d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Gq7kFqR/xBYj1N+P2Sp+urPCLLKoo+H5DXMIG+avrqU=	2026-08-28 06:26:10.678333+00	2026-08-21 06:31:19.339085+00	\N	2026-08-21 06:26:10.680216+00	2026-08-21 06:31:19.339407+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
756e0513-10b3-4324-b42a-880e4744f278	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qc2+ZoX9Q4AKfoMSCp8NVdVve4aG+muCJKVsMMA+R7A=	2026-08-28 06:31:19.339276+00	2026-08-21 06:31:22.102641+00	\N	2026-08-21 06:31:19.339407+00	2026-08-21 06:31:22.103419+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1bca2c27-11dd-4fb8-877a-ab32b2b14f7c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	VZyfNFzvXm1JT+YzP4/sV2XFcHvdpEGsKeY1+bZjE90=	2026-08-28 06:31:22.102926+00	2026-08-21 06:31:26.120079+00	\N	2026-08-21 06:31:22.103419+00	2026-08-21 06:31:26.120384+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d7d9292d-f491-4e7f-befe-7f73eb31b348	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	gge5pEtBRfv1LAjwxhjkFIQbuI/OMmSO8yQ8+b2DOrY=	2026-08-28 06:31:26.12029+00	2026-08-21 06:31:33.745793+00	\N	2026-08-21 06:31:26.120384+00	2026-08-21 06:31:33.746156+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
81cfc8f2-1662-441a-baf0-69574ef00e3b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Vyv7BgX3tU0HB7WgwQxBZ/dfTS5Odrt+HqcPzoFHbbE=	2026-08-28 06:31:33.746063+00	2026-08-21 06:31:43.017089+00	\N	2026-08-21 06:31:33.746156+00	2026-08-21 06:31:43.017914+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
64229a1a-56e8-44b0-accd-94d81b0efe18	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	j0Or/SV3CH8faKfR2j6Yrx6aMzw8PW/0X0qZU+ZiFMI=	2026-08-28 06:31:43.017785+00	2026-08-21 06:31:59.463423+00	\N	2026-08-21 06:31:43.017914+00	2026-08-21 06:31:59.463802+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8d5837f5-dbc1-4423-8ae2-97d4358aca89	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bx5OFf/RvVpsNVtNRHX0dZm7IAICmi+4PWRGy1c1ysU=	2026-08-28 06:31:59.463683+00	2026-08-21 06:36:09.423238+00	\N	2026-08-21 06:31:59.463802+00	2026-08-21 06:36:09.423736+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
279927ba-cbd0-40d0-9de5-6ae418424420	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	h9HVCJVWZp780TJ5BLnGNNFxZUaSIMeHRwtX7dR931E=	2026-08-28 06:36:09.423582+00	2026-08-21 06:36:14.75644+00	\N	2026-08-21 06:36:09.423736+00	2026-08-21 06:36:14.756689+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d4273aa9-23e1-4f31-aec4-d70ca5333673	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	k0eFwtrkyx5g2aCDvke8zQoOQnPLK+d1k0shynqPZ7I=	2026-08-28 06:36:14.756583+00	2026-08-21 06:36:31.720672+00	\N	2026-08-21 06:36:14.756689+00	2026-08-21 06:36:31.720901+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9d5093c7-2c83-4d41-a657-34f93211e474	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	g8KkCi8RYkhbpFuPfTUo4Ew9Ei/+/4XN0HKQ8T1IMn8=	2026-08-28 06:36:31.72081+00	2026-08-21 06:46:17.921822+00	\N	2026-08-21 06:36:31.720901+00	2026-08-21 06:46:17.922445+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
259a31c8-d9d9-4bc5-9def-c1137b74720d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4VDuFl24Zhk2QYlVfK+Wh10l3TYXFDXT7rOQZfRKfJA=	2026-08-28 06:46:17.922204+00	2026-08-21 06:47:06.36368+00	\N	2026-08-21 06:46:17.922445+00	2026-08-21 06:47:06.36397+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bd8fae92-3c26-42f3-90fe-b06c8fa15254	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	gyk6sU9BqAWgSfwjepNDfETfWWWGqONq9MSs/+crFjw=	2026-08-28 06:47:06.363827+00	2026-08-21 07:21:26.070233+00	\N	2026-08-21 06:47:06.36397+00	2026-08-21 07:21:26.169632+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
456acd1b-3737-4bc8-a0a2-a4cf6993add9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	QMCfWBATRFxu0tVLz8EllZ6dSFvAYKDe/zqWttk7PQ0=	2026-08-28 07:21:26.153677+00	2026-08-21 07:22:44.125443+00	\N	2026-08-21 07:21:26.169632+00	2026-08-21 07:22:44.12734+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6101e27f-5bf8-4026-98ec-6263b5be20cb	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	lGJ/egLqWvNYkrseSlUy1d3qhpiWJGvzQRvup6oVRtE=	2026-08-28 07:24:18.433794+00	2026-08-21 07:24:50.30453+00	\N	2026-08-21 07:24:18.433922+00	2026-08-21 07:24:50.304551+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fdd46d8f-4679-4d87-b5e6-ccea047114d4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	dq9aP/BsB3bUnnjfvIECblL6eZSRAcLX8nYKIlIO0bs=	2026-08-28 07:22:44.12589+00	2026-08-21 07:24:50.704002+00	\N	2026-08-21 07:22:44.12734+00	2026-08-21 07:24:50.704388+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
82098bf8-bff7-4907-957f-aba21abdc0f7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Ru4cnbeKJVkUBDYSaofUu45nsAbwmE5LpV+QbDskvPg=	2026-08-28 07:24:50.704227+00	2026-08-21 07:25:19.350804+00	\N	2026-08-21 07:24:50.704388+00	2026-08-21 07:25:19.3512+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c3ec8254-2af3-4dd3-9a4b-64f9ff9e4a85	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	N0XiiUVLG1sa0tsM2q6U8PRn8UksLfEBRgcWHiiDslI=	2026-08-28 07:25:19.351033+00	2026-08-21 07:26:43.860434+00	\N	2026-08-21 07:25:19.3512+00	2026-08-21 07:26:43.860453+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5d0c6621-7ea1-4b50-b74d-607b7336d7fd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	b/1qwao5G4Ho/urp46yo7UxXCiIZggs5q6rsKVBMhvc=	2026-08-28 07:26:44.127404+00	2026-08-21 07:34:39.905083+00	\N	2026-08-21 07:26:44.127508+00	2026-08-21 07:34:39.905346+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
09078517-fa6c-463a-9558-3a4675807194	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Dj5OwJrJSLRWIjgbNjtAxUF5p+5/BFHxK0iOlsqJxuk=	2026-08-28 07:34:39.905246+00	2026-08-21 07:38:22.344483+00	\N	2026-08-21 07:34:39.905346+00	2026-08-21 07:38:22.344506+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
981c0b8c-517c-48f5-9a74-f34acc945efe	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	D++ULv/dx/W/bTMU/OZVtw9PWmYmw+rEejiaeYCJksw=	2026-08-28 07:38:22.689183+00	2026-08-21 07:38:22.848084+00	\N	2026-08-21 07:38:22.689295+00	2026-08-21 07:38:22.848349+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d8f61d12-00f3-4bc3-88ac-8ba744c48593	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vdop+6qmU/k/ERPZQM1mLGYFkic6LLmQEqxPOe2jrHY=	2026-08-28 07:38:22.84827+00	2026-08-21 07:40:53.184238+00	\N	2026-08-21 07:38:22.848349+00	2026-08-21 07:40:53.184257+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b9abc560-3a7e-416c-9b22-02f032a8070f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	hZWmbYhJqy8BPzixyo1Wf01h98duLdJQZpjesDezH7s=	2026-08-28 07:40:53.538584+00	2026-08-21 07:40:53.569865+00	\N	2026-08-21 07:40:53.538729+00	2026-08-21 07:40:53.570113+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6b1073a4-baa2-4747-acaa-16054a78a832	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PtkLzxxm7Xu9b3yKVC8RR0Qi1m8Makn9CG+uLy0pXdo=	2026-08-28 07:40:53.57002+00	2026-08-21 07:40:55.389926+00	\N	2026-08-21 07:40:53.570113+00	2026-08-21 07:40:55.389944+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
47b45b61-f3ef-4ddd-bd77-27072b4d45a6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SOJGT5tGRn9JasLHm0hxw8B4Gj++8KFPX73DqQTaVfc=	2026-08-28 07:40:55.695417+00	2026-08-21 07:40:55.761053+00	\N	2026-08-21 07:40:55.695512+00	2026-08-21 07:40:55.761272+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cc3623d6-d71b-4386-a3cd-d2376bf6ad1e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uaeNVSpFUWL0Jxnky6yjHfTsaTkQXSoicmieiJuI460=	2026-08-28 07:40:55.761197+00	2026-08-21 07:45:22.736494+00	\N	2026-08-21 07:40:55.761272+00	2026-08-21 07:45:22.736515+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3a98deaa-010d-41d5-a663-77e082ad8063	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sEMhqRxYVGSKwx8uNMq0IQS0VYVYiF7oeUPm6Nk0VgE=	2026-08-28 07:45:23.082302+00	2026-08-21 07:45:47.91884+00	\N	2026-08-21 07:45:23.082388+00	2026-08-21 07:45:47.919146+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a2891299-dded-4132-a6c3-ae38c76d0818	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	THS/cJWb7O+PsdN4ZtHZrP8s8sP1Lt4sUfcY6E20bZo=	2026-08-28 07:45:47.919068+00	2026-08-21 07:47:29.784995+00	\N	2026-08-21 07:45:47.919146+00	2026-08-21 07:47:29.785281+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6cd9b195-26f1-4735-9258-803921acc4f8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	cz5XUUHMRViQSIr6iN0F3KMfSvmtgLdwygf2vz/BJ/E=	2026-08-28 07:47:29.785175+00	2026-08-21 08:04:40.89184+00	\N	2026-08-21 07:47:29.785281+00	2026-08-21 08:04:40.940327+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
33422ad5-5f96-434e-aa2c-af31049bc7b9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nh0TSpa8IMfTviy4yt57afbqzAWkCHgDj+j6+HtYLqY=	2026-08-28 08:04:40.919537+00	2026-08-21 08:06:19.914115+00	\N	2026-08-21 08:04:40.940327+00	2026-08-21 08:06:19.951673+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5c34f6b4-5cc6-4daf-9fda-5beeaad92303	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0XMWC0ZdvRamfFk2HBtqpVuRMAGgkgTxNAWORFSWrvw=	2026-08-28 08:06:19.937128+00	2026-08-21 08:30:49.986435+00	\N	2026-08-21 08:06:19.951673+00	2026-08-21 08:30:50.015844+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eeac3333-1087-46df-b584-e06073585df4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/zyKZMxg4FL2nubO6HVz9u60eY4go1SzIJ18U1NuBE4=	2026-08-28 08:30:50.010949+00	2026-08-21 08:31:01.573311+00	\N	2026-08-21 08:30:50.015844+00	2026-08-21 08:31:01.574035+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9fc23122-a225-4117-8519-046e9f6397c0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uluZJt6xIl3BwnQCzhZpPcI//AEvO0qSiU3EjquxtGs=	2026-08-28 08:31:01.573889+00	2026-08-21 08:52:16.644074+00	\N	2026-08-21 08:31:01.574035+00	2026-08-21 08:52:16.644088+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fbddbf59-402d-4553-addd-80063d0ca640	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	14aCBzgS+HpGVQRDKD2QUJazX8uE04TG80wFEHJo6dk=	2026-08-28 08:52:16.935474+00	2026-08-21 08:52:25.752409+00	\N	2026-08-21 08:52:16.935729+00	2026-08-21 08:52:25.752421+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e4498769-e805-48fb-9278-c6b2a14be681	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	oIFe4z5rzdGbSX1aNlIzA/9foesy6BsGGjSyBi2FUc8=	2026-08-28 08:52:26.04929+00	2026-08-21 08:57:05.669535+00	\N	2026-08-21 08:52:26.04942+00	2026-08-21 08:57:05.669573+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
53f09124-e876-4681-98c7-6078538336bd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tU0tytLgHYNwcV1kCyVyihGeNxXJxqJUSWSrFpLXPnc=	2026-08-28 08:57:06.025117+00	2026-08-21 08:57:06.333994+00	\N	2026-08-21 08:57:06.025257+00	2026-08-21 08:57:06.334353+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bbf7ccba-1069-4d13-89fe-33f7805e04a2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xR8dbkda93AUKtNLWp25cyIk828O7blLFxFkkT7GRVA=	2026-08-28 08:57:06.334228+00	2026-08-21 08:59:23.538867+00	\N	2026-08-21 08:57:06.334353+00	2026-08-21 08:59:23.573404+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a83a1e87-80a7-4503-8f58-2c97397a54e1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+TmJp3U+Bd7XAijBQ/BjUu9R11eEBsFnb9qVYTsv3qI=	2026-08-28 08:59:23.560229+00	2026-08-21 09:02:12.560757+00	\N	2026-08-21 08:59:23.573404+00	2026-08-21 09:02:12.560781+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a1ca6e83-19ab-47d9-ad69-60061d17827a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	i0xAWBQJwKxDD7G105nTy1B1nRsXcSwTfyQ99z1fiR4=	2026-08-28 09:02:12.834053+00	2026-08-21 09:35:06.144071+00	\N	2026-08-21 09:02:12.834751+00	2026-08-21 09:35:06.167438+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0a7ab51b-5976-49e0-b364-139333fe7e58	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vW5YoaN6rZD3BM0pVjSBhB3W1CoQz2nF3zilVb1vwes=	2026-08-28 09:35:06.154332+00	2026-08-21 09:35:14.813051+00	\N	2026-08-21 09:35:06.167438+00	2026-08-21 09:35:14.814048+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
95ebaf5d-69c0-4f01-8f7b-78956a9909d1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	XMtNzIvHj5xiO2Ysf5BdgP7NxUbn0gaGNBjkdH0hkCI=	2026-08-28 09:35:14.813254+00	2026-08-21 10:59:50.698892+00	\N	2026-08-21 09:35:14.814048+00	2026-08-21 10:59:50.699283+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a0aebe9e-471e-4516-ad8a-b4545ad9969f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SFJVwpDHOBVi8OAEMqEiOU/Hn/jL40HXksqM5ojIAKw=	2026-08-28 10:59:52.901861+00	2026-08-21 10:59:53.128556+00	\N	2026-08-21 10:59:52.902882+00	2026-08-21 10:59:53.128576+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
121f839e-b03f-4e04-80f8-ea8e83243f75	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4VGUSUvUZNO1+WtZrYFr8YWe2m0RR26zHBD0Qua5/5Y=	2026-08-28 10:59:54.289016+00	2026-08-21 11:28:44.956739+00	\N	2026-08-21 10:59:54.289291+00	2026-08-21 11:28:45.009172+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
696eaaf7-55f5-42c5-abba-09215fa7a77d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	VH5KM98YMgydYLnVF14EcD8+nE4OABzknaaXYdWCbL8=	2026-08-28 11:28:44.988141+00	2026-08-21 12:07:08.133091+00	\N	2026-08-21 11:28:45.009172+00	2026-08-21 12:07:08.201891+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bc55d6d5-9ac0-411f-9700-a10642154e80	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yr4LdREvX24a/eDSjlHXEF2vW3uslLcaKcdqgxofONo=	2026-08-28 12:07:08.173874+00	2026-08-21 12:20:45.21947+00	\N	2026-08-21 12:07:08.201891+00	2026-08-21 12:20:45.220722+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fd51c301-496a-49d0-b8d4-ce0f9ac7436c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uaTDuoA1EKZDjd6pLVcMTd8ym6KQzroRF3BUH8DpcVs=	2026-08-28 12:20:45.219749+00	2026-08-21 16:44:11.513173+00	\N	2026-08-21 12:20:45.220722+00	2026-08-21 16:44:11.513622+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
36f78caf-82bd-4622-93c0-e8b84c40c324	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	i1pSLRo3IomL1fIZCv5b+1Ado/VO/w8som9tjRJNjwo=	2026-08-28 16:44:07.063834+00	2026-08-21 16:44:11.265326+00	\N	2026-08-21 16:44:07.072163+00	2026-08-21 16:44:11.265427+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6361d004-adca-4415-b3ea-54adebcb45c0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YyxvWFS5f48TkO36BOOiGrxPUwylijfvKy6dtGqyMr8=	2026-08-28 16:44:11.513377+00	2026-08-21 16:45:24.64354+00	\N	2026-08-21 16:44:11.513622+00	2026-08-21 16:45:24.64357+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
73ad424b-313d-4f88-a383-732517001113	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	wRb9Fuq96HgCOLsh4ZBrHx/O2a1uLX4eSi/eLXCqrCY=	2026-08-28 16:45:24.912611+00	2026-08-21 16:45:41.944072+00	\N	2026-08-21 16:45:24.912703+00	2026-08-21 16:45:41.944099+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
12b3b983-fb1a-4894-9baf-0906e1045092	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	gqCUpWIoEJIc6NkItrLKSy7wGgcV0K7xoBvdKYTlTxs=	2026-08-28 16:45:42.22899+00	2026-08-21 16:56:25.768887+00	\N	2026-08-21 16:45:42.229084+00	2026-08-21 16:56:25.769324+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ffcdf4b6-544e-4a8a-b4ac-9c91f983ce49	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TUfHft3yPMeXwg8oy6TBAOBoyMRMyiYeZ+XLx1EC/Lo=	2026-08-28 16:56:25.769184+00	2026-08-21 16:58:41.84208+00	\N	2026-08-21 16:56:25.769324+00	2026-08-21 16:58:41.842378+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a922a8ad-5543-4880-9b89-4eaf47b91a2e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ZvMWRWFBFBOSyOKviBVRXkbkjI/CwLLGdFPAXzzYM2w=	2026-08-28 16:58:41.842274+00	2026-08-21 16:59:08.651372+00	\N	2026-08-21 16:58:41.842378+00	2026-08-21 16:59:08.652417+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
08f66602-d863-473a-afab-fbe72f53e7b4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eoGo2A4LDab8RkqLvkVeEpjgT6vXu7maybKL8lEvUxI=	2026-08-28 16:59:08.652119+00	2026-08-21 17:34:46.777543+00	\N	2026-08-21 16:59:08.652417+00	2026-08-21 17:34:46.779812+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
146be78d-1c05-4286-865f-7028c005a4a3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NCjQIwLQ9w6NPWh8aG2mO1ffaZxvOzCEhUfyQv0+SDk=	2026-08-28 17:34:46.779376+00	2026-08-21 18:23:23.965424+00	\N	2026-08-21 17:34:46.779812+00	2026-08-21 18:23:23.966722+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
794b4692-22e0-4eda-9290-858ba2538832	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eNYgNhQWcM59lYomI1ZAHX/YkGe6qq7QTurmDUrmLSc=	2026-08-28 18:23:23.966243+00	2026-08-21 18:29:52.319345+00	\N	2026-08-21 18:23:23.966722+00	2026-08-21 18:29:52.328113+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9be8b6ba-1f85-4027-89e0-89326a28117b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HjHJQghUlF4k5EEXIW7vD4fag6gSaHFLi4WWqiw+VfQ=	2026-08-29 05:55:47.515373+00	2026-08-22 06:28:17.860566+00	\N	2026-08-22 05:55:47.51565+00	2026-08-22 06:28:17.874674+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dc87d396-0874-4ff5-ae32-c8b2a4280fdc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	90ZQxe5bYSNLKEafIjIcaweUsBN0UtDU3aIozcRzhVc=	2026-08-28 18:29:52.323595+00	2026-08-21 18:37:39.862253+00	\N	2026-08-21 18:29:52.328113+00	2026-08-21 18:37:39.863271+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1e0ce1ac-6f9c-414a-8a77-dc1c4d1b3115	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qrSA7SjigRIJ2HtX4V2gYA1OP5ivczuvX7WXsKPZ04o=	2026-08-28 18:37:39.862529+00	2026-08-21 18:42:26.568489+00	\N	2026-08-21 18:37:39.863271+00	2026-08-21 18:42:26.569922+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3f36e699-4bf5-4e28-ba53-006c291cfcc3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xtZyGkidTG4pMY8LXdeYt0U03DK8XH+aGo/C+XKBYBI=	2026-08-28 18:42:26.56925+00	2026-08-21 18:42:26.591675+00	\N	2026-08-21 18:42:26.569922+00	2026-08-21 18:42:26.591848+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eed20a06-948c-48cc-b808-1a3dccb37d8c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	kDT1ViMUM/9YLThxw/NsNdii6g6vnoEdOBMnV5We+LM=	2026-08-28 18:42:26.591785+00	2026-08-21 19:04:39.361956+00	\N	2026-08-21 18:42:26.591848+00	2026-08-21 19:04:39.364511+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1fbccd59-468c-43cc-ac9d-672bda518373	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	F54pXs5SBEb0xqCwqIH+jIsNC39vj3GgKC39BdIC2R0=	2026-08-28 19:04:39.364037+00	2026-08-21 19:12:16.243304+00	\N	2026-08-21 19:04:39.364511+00	2026-08-21 19:12:16.259357+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d9c52b8b-8e58-4ea6-b2fd-2ca72f4dab15	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1Amn2ovPj652YrJMnKloLckITQ20ILT1kbd/ma2ou5o=	2026-08-28 19:12:16.256325+00	2026-08-21 19:22:51.395163+00	\N	2026-08-21 19:12:16.259357+00	2026-08-21 19:22:51.395779+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2ac137b4-e43b-429f-8615-7d78707c354f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TzQJtXzqydcylYR9n+UoQqE4ETn+hbLxL4YEwyEBkjY=	2026-08-28 19:22:51.395571+00	2026-08-22 05:04:10.080698+00	\N	2026-08-21 19:22:51.395779+00	2026-08-22 05:04:10.088856+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d04b71ab-577a-4429-a3c8-644a1b333495	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BusjdmdM3jgXDdYwKH9Jl8x/69c7BEm+KP3IBu+OBJE=	2026-08-29 05:04:10.087843+00	2026-08-22 05:27:40.421776+00	\N	2026-08-22 05:04:10.088856+00	2026-08-22 05:27:40.434407+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
761347ac-0c68-428a-bc31-beb56b573c42	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	XtCOt1XHh7DlZ0I68SdaNsw/Q3ZQCzehnzEqL3kOwgQ=	2026-08-29 05:27:40.430217+00	2026-08-22 05:34:40.710189+00	\N	2026-08-22 05:27:40.434407+00	2026-08-22 05:34:40.715259+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c0581efc-09e6-45fe-9e29-7b766c7df408	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	hzjdNIPFwXuWLfVcl9HBujxVIL1BsUvqhVbv80ukPvc=	2026-08-29 05:34:40.712979+00	2026-08-22 05:41:16.429178+00	\N	2026-08-22 05:34:40.715259+00	2026-08-22 05:41:16.430025+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6295fa3f-e6af-436f-8620-2afb7932e069	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rpjJVZNqABk+YGxFYWXuMcYZnq8I9Ei8t6seTKkO8E8=	2026-08-29 05:41:16.429649+00	2026-08-22 05:41:44.935047+00	\N	2026-08-22 05:41:16.430025+00	2026-08-22 05:41:44.935395+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
edc8a465-5c3b-47d8-acf2-676cdb0d3d83	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0izwIG3Ew3BhRpmmjq/XjcBXtkxV21ZGoZNY4C1Bi+o=	2026-08-29 05:41:44.935244+00	2026-08-22 05:55:47.514976+00	\N	2026-08-22 05:41:44.935395+00	2026-08-22 05:55:47.51565+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e3c3c71f-882e-4995-bd4e-4dd3c061dc3a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	mRtoJeEt7emELWtIsnwCDJPG7KQSgDWfw4Yad3tG+bQ=	2026-08-29 06:28:17.868176+00	2026-08-22 06:36:29.686572+00	\N	2026-08-22 06:28:17.874674+00	2026-08-22 06:36:29.687523+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9d19c141-d9c5-425d-bb7a-eed830231768	40517b71-5e62-182e-73b5-d4070e20a3c2	bqPpTT6VJ4epYUU6JDxsphMmYQXbCRreUGxKqPNDzzo=	2026-08-28 06:21:37.975412+00	2026-08-22 06:42:01.02779+00	\N	2026-08-21 06:21:37.975497+00	2026-08-22 06:42:01.027974+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cf455132-90dc-4f5f-940a-31ab1c84dd07	40517b71-5e62-182e-73b5-d4070e20a3c2	pr5XfDuAOFywVtdLXl9Smytu6+R1fnTmkh3qlKZA594=	2026-08-29 06:42:01.027914+00	2026-08-22 06:42:13.433484+00	\N	2026-08-22 06:42:01.027974+00	2026-08-22 06:42:13.433666+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b3c7cbaf-de43-4f28-b872-7056652f4ddd	40517b71-5e62-182e-73b5-d4070e20a3c2	xE1v9mZFEj4l6YLZ0twjZQBzYjjNcfZce8lepWhUwgY=	2026-08-29 06:42:13.433604+00	2026-08-22 06:42:24.316953+00	\N	2026-08-22 06:42:13.433666+00	2026-08-22 06:42:24.317172+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0e04a1ea-fa80-4695-8e5f-9df3afa7749f	40517b71-5e62-182e-73b5-d4070e20a3c2	Ng+NvjQd3Ats8Tg1lFdtiuNf2TGSJLwAnqVOx9c1944=	2026-08-29 06:42:24.317097+00	2026-08-22 06:42:50.703729+00	\N	2026-08-22 06:42:24.317172+00	2026-08-22 06:42:50.703952+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
180e657d-d97f-47e3-b45e-39744f0ada07	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	U15LKEO+WJbDufRQ51pnGj5nDIWVUb74QqiSlUwGn9c=	2026-08-29 06:36:29.686936+00	2026-08-22 06:48:25.697107+00	\N	2026-08-22 06:36:29.687523+00	2026-08-22 06:48:25.697307+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
16719cf4-c618-4a17-b892-e59a074bebbf	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	iNsRClCwDq4LcPLIHgrai5MlJFvEe4JoP9M9q3x08Xg=	2026-08-29 06:48:25.697226+00	2026-08-22 06:49:35.297474+00	\N	2026-08-22 06:48:25.697307+00	2026-08-22 06:49:35.299012+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
885f5917-e8dd-46c5-9c66-33992f64f733	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ax9B92tSK12r1XO5cQgJBSkLqti9YpBxSaPVlWEZso8=	2026-08-29 06:49:35.29872+00	2026-08-22 06:50:23.315016+00	\N	2026-08-22 06:49:35.299012+00	2026-08-22 06:50:23.315453+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c7cbad57-77ec-46c7-8a2e-a751eed4d045	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4/pRS0i/Ewg5MTVNgJIe4e3xPTQJzW3vk6qA6rlwu2Q=	2026-08-29 06:50:23.315252+00	2026-08-22 07:07:16.266622+00	\N	2026-08-22 06:50:23.315453+00	2026-08-22 07:07:16.268127+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6689e2d3-bd75-4047-8f41-ae3cba9f7b01	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zQSLo7GP7jf+FzCdymBmuyCtiOkD/QL9S85EwtfHZrM=	2026-08-29 07:07:16.26775+00	2026-08-22 07:31:33.882431+00	\N	2026-08-22 07:07:16.268127+00	2026-08-22 07:31:33.883447+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f669f630-9d3d-4db4-92c8-fc33dfa1ae17	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xOBXkr7ivNqIN6KVvB5ZYdJqJGwC2lNywuLTeuu0U4A=	2026-08-29 07:31:33.882933+00	2026-08-22 07:40:41.190725+00	\N	2026-08-22 07:31:33.883447+00	2026-08-22 07:40:41.191352+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fc718aae-2527-479e-b105-183386bf8495	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YG47BKlvEGwDMG0WseE0yCrgjagBu7uaLbrhYF48bGE=	2026-08-29 07:40:41.191035+00	2026-08-22 07:58:51.028852+00	\N	2026-08-22 07:40:41.191352+00	2026-08-22 07:58:51.030688+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a28aed47-94ca-452c-a316-5d1629c9eb00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3gVN2DweRtsn360ZYcqZaj/lm0HVhXPPgj3SRGnmFkU=	2026-08-29 07:58:51.029847+00	2026-08-22 09:52:27.266179+00	\N	2026-08-22 07:58:51.030688+00	2026-08-22 09:52:27.268678+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fe4aedaf-cdd9-4558-8b33-59037909a400	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	tih7Rkuz4yVXaJGsCa4oB5MVqRr7h8NjpantoVBqqWA=	2026-08-30 16:08:59.45658+00	2026-08-23 16:09:55.104814+00	\N	2026-08-23 16:08:59.555391+00	2026-08-23 16:09:55.105177+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
af55bf54-9809-4bd2-b88c-4308307bb333	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	n0Zq2zK3bws0mD9Im8OmptbMu/onU/LYTNdwsGbRLzI=	2026-08-29 09:52:27.267567+00	2026-08-23 16:09:55.683159+00	\N	2026-08-22 09:52:27.268678+00	2026-08-23 16:09:55.68636+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f3f0782f-585e-44db-bc53-63fc2475899b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	FOfN9VTBsBHvqKF41LCS5OZHqp3TWK2UkgPebU0n5tg=	2026-08-28 18:37:39.864765+00	2026-08-23 16:09:55.683158+00	\N	2026-08-21 18:37:39.86485+00	2026-08-23 16:09:55.68636+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7e5d627c-5368-4449-829d-5d278ea30026	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	aHOpJa3bZTYblUgtQ0gWRD27NURN3vqFPObAb6IZLMw=	2026-08-30 16:09:55.68371+00	2026-08-23 16:17:58.895813+00	\N	2026-08-23 16:09:55.68636+00	2026-08-23 16:17:58.895857+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
adae6dfb-3519-41a2-8a54-3d50b75675c5	dc139a9d-b996-7354-6c27-72659ea2fd59	xKIcraA8aZaWWzjGOEpZY4CAxN9rGhEUKwJX3DfQTQc=	2026-08-30 16:17:59.551065+00	2026-08-23 16:18:24.160084+00	\N	2026-08-23 16:17:59.551313+00	2026-08-23 16:18:24.160103+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6f4f7404-cc9c-4a74-82fc-5a821ceabede	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sWWnGkBE4k/WhGxUh76RGZSOkBmlFk4c3a4feo0W8RA=	2026-08-30 16:18:24.730547+00	2026-08-23 16:50:53.407358+00	\N	2026-08-23 16:18:24.730692+00	2026-08-23 16:50:53.431792+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1653d2c2-b666-4e23-aba7-155c11cb35a2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	lD7gyqz4aA6UDKdzbBrG1YiEoQ62/2Zy6xZpneu8Li0=	2026-08-30 16:50:53.423377+00	2026-08-23 17:28:05.498882+00	\N	2026-08-23 16:50:53.431792+00	2026-08-23 17:28:05.529424+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d65acbff-8844-4af8-9cdf-cf290b69437b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	g+QnURkep2lg3AG4BwefA8E4eyZ65iEaqun7fwbiq5w=	2026-08-30 17:28:05.516105+00	2026-08-23 17:57:34.001316+00	\N	2026-08-23 17:28:05.529424+00	2026-08-23 17:57:34.078007+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
efd24b5d-fcfc-432e-9682-84d404415c94	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	AK4JEqiXPmg24obEY2hvmFEmc7BnIoYIurm1ho80RUE=	2026-08-30 17:57:34.04365+00	2026-08-23 17:57:41.557754+00	\N	2026-08-23 17:57:34.078007+00	2026-08-23 17:57:41.577549+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
72843b55-7148-437c-bf9b-3c9768cec4e0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	MyHS6u7ACd0GRJv1ueXxRfcb42VDcFYkmhsLJUbKhTQ=	2026-08-30 17:57:41.573015+00	2026-08-23 18:07:53.59118+00	\N	2026-08-23 17:57:41.577549+00	2026-08-23 18:07:53.622258+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ecac5a33-5dbf-44c2-9f4e-4dd3218911ff	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ECHZNUXh8C0e4zk6b2E3LFKCfoTS0ncEV8IZpJV3GPg=	2026-08-30 18:07:53.605491+00	2026-08-23 18:11:19.943499+00	\N	2026-08-23 18:07:53.622258+00	2026-08-23 18:11:20.050493+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
66fd76b0-27e1-434f-b253-c89243c68ed5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fiGMGKpH04wBNvtiEI2T60ABqWR7+Fq6TNMNw2Y9TvA=	2026-08-30 18:11:20.038269+00	2026-08-23 18:18:52.470236+00	\N	2026-08-23 18:11:20.050493+00	2026-08-23 18:18:52.534533+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e10ad75a-a483-44e0-b993-9c25430f88fb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	U3f0pNHXJa3XfcnqKHPSphN5oDwl/c6/wDfne3MdUn8=	2026-08-30 18:18:52.52823+00	2026-08-23 18:29:47.311047+00	\N	2026-08-23 18:18:52.534533+00	2026-08-23 18:29:47.388531+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b57ffbbf-fede-4306-a844-19e1bbc2bc8b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OUQHKv66uDcDhWfhqt+S8lTa7cHyLcq2thXR1pjlmFc=	2026-08-30 18:29:47.355812+00	2026-08-23 18:30:18.847065+00	\N	2026-08-23 18:29:47.388531+00	2026-08-23 18:30:18.853783+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
442744a1-e13a-4d52-9fb5-5c5ee6ef4a94	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Soows9yOnelt2rmGKr4Yk+jWoUs8sFlk6ItwK4j0LQE=	2026-08-30 18:30:18.847873+00	2026-08-23 18:30:24.333389+00	\N	2026-08-23 18:30:18.853783+00	2026-08-23 18:30:24.334846+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ac938833-48c2-4eb1-8efa-fb901cd8eb22	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HOeAY3paeM7UixnPj2/z8q5NDSFHds0q7qReEkO+e0s=	2026-08-30 18:30:24.33446+00	2026-08-23 18:31:46.453152+00	\N	2026-08-23 18:30:24.334846+00	2026-08-23 18:31:46.454136+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
87a894b6-86f8-4e9b-8b97-f9a72728060a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	81gHe7O3OXq/BPZJoT4VzgkSUmPCTH4sD9mGpYwjZEs=	2026-08-30 18:31:46.453702+00	2026-08-23 18:44:40.157933+00	\N	2026-08-23 18:31:46.454136+00	2026-08-23 18:44:40.16586+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4da302f8-9119-496f-85b8-3bf02b830ccf	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UzJOEgBYXIVD5cqkZizbqJOMDm79ch561kPcCxE1Nso=	2026-08-30 18:44:40.159749+00	2026-08-23 18:49:09.821445+00	\N	2026-08-23 18:44:40.16586+00	2026-08-23 18:49:09.840698+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
45832294-4501-4770-b9ad-02783cc64e7a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HCOEKEKI+bWQEGSDwSjfCKBt/tdoxTJ+sInvNOwgWdk=	2026-08-30 18:49:09.837861+00	2026-08-23 18:52:51.123284+00	\N	2026-08-23 18:49:09.840698+00	2026-08-23 18:52:51.124642+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b0b7b496-1d56-4bae-92dc-88563c87374c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	dTvgiFVErbWwNksMFP53zikXCMGBQ6k6C4YO9KP2JIc=	2026-08-30 18:52:51.12403+00	2026-08-23 18:52:53.521034+00	\N	2026-08-23 18:52:51.124642+00	2026-08-23 18:52:53.522734+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
30f466fc-6119-4fd5-bfef-b135b956ceed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NvtHt4Oc3kK0sam6WuB1Gac7GvVDR6LRl5RqL+vLKRw=	2026-08-30 18:52:53.522226+00	2026-08-23 18:57:26.960824+00	\N	2026-08-23 18:52:53.522734+00	2026-08-23 18:57:26.961524+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0ae780b3-1538-4d7c-a9ee-c28101512771	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8qp7ZLOV1kc9OkCEQl8cTozJ5cPyTtrLFc1Nqnd72ZI=	2026-08-30 18:57:26.961179+00	2026-08-23 19:05:36.41221+00	\N	2026-08-23 18:57:26.961524+00	2026-08-23 19:05:36.413014+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
af7eabe3-7601-4373-9539-4b6f6f4b370f	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	S7i14RXfPbgiZfkSeAhhwF+YS4zUel/b93aXcLjG+w8=	2026-08-30 19:04:57.71757+00	2026-08-23 19:06:58.914515+00	\N	2026-08-23 19:04:57.910054+00	2026-08-23 19:06:59.327348+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eae7fffc-c267-4ff9-80dc-84f7feb74cbb	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	KAh6XmH41jwep61lgoE0haM+lrmWQL3xxE2iKui+TgU=	2026-08-30 19:06:59.225314+00	2026-08-23 19:07:23.804955+00	\N	2026-08-23 19:06:59.327348+00	2026-08-23 19:07:23.805035+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0b1b048a-d4c8-4e4d-9b02-7f93452ee245	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	eX5sGAamq72JgP+muc6sAF0a1Voi1IgD9KwxSUYZP8A=	2026-08-30 19:07:26.072685+00	2026-08-23 19:08:05.18258+00	\N	2026-08-23 19:07:26.076124+00	2026-08-23 19:08:05.182736+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
058f2ac3-af1e-43a5-b132-a9a115cce749	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	eXkxy23WnQmxOz5RjZ/loiRsLcKGLexQmtBLsvfElXo=	2026-08-30 19:08:08.037171+00	2026-08-23 19:08:27.837912+00	\N	2026-08-23 19:08:08.050534+00	2026-08-23 19:08:27.837946+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
378303ce-6c57-4a7e-9a1d-d3962480f7fb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ampYsxKLHxfnACqnoaFyGf1Yi6Su7bUekwv0gs2iJ4w=	2026-08-30 19:05:36.412719+00	2026-08-23 19:08:30.981674+00	\N	2026-08-23 19:05:36.413014+00	2026-08-23 19:08:30.992134+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fea861d0-47d1-414f-ba9d-33f1ba40efd7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vwmtVWksGsZoMMX4znPPUJsgepiyTjUrCuctunS1Jgs=	2026-08-30 19:08:30.982714+00	2026-08-23 19:11:15.161028+00	\N	2026-08-23 19:08:30.992134+00	2026-08-23 19:11:15.177592+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f0901941-f404-4542-ac88-1d2555169cc7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Dn6Aj/kRV7/qRhBJzHgspv5JULaODvvY7mgXbJtIwNY=	2026-08-30 19:11:15.17156+00	2026-08-23 19:11:21.636677+00	\N	2026-08-23 19:11:15.177592+00	2026-08-23 19:11:21.640383+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eda1d94a-066d-4ba9-862a-bb344eb416c3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qrPAvv7HV/IidNmtgESzjzmIfKx4mSU1S+hburO68mM=	2026-08-30 19:11:21.639868+00	2026-08-23 19:19:42.193124+00	\N	2026-08-23 19:11:21.640383+00	2026-08-23 19:19:42.194124+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
321a7993-fb4e-468e-a1aa-504acc260114	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ILwhPYalP8rQiAfk4qh/gkzuqei1CbOOZTZIjK4MANY=	2026-08-30 19:19:43.014749+00	2026-08-24 04:58:30.252362+00	\N	2026-08-23 19:19:43.020634+00	2026-08-24 04:58:30.261043+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8bb478cb-edb8-4166-b550-cf91c4b6b8bb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5aDBd3S5ap3bgDzwG9e4LnQdk7hkZ7daUkjPVDfsJqk=	2026-08-31 04:58:31.426401+00	2026-08-24 05:00:12.795418+00	\N	2026-08-24 04:58:31.449129+00	2026-08-24 05:00:12.798316+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dbabe0e2-6bd3-4d1b-a18c-456f70c61f8f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	s0PODLxIHRJERRPVS6XuTtmk1PzX27PV86tpu2hwZ0I=	2026-08-31 05:00:12.796425+00	2026-08-24 05:03:22.585124+00	\N	2026-08-24 05:00:12.798316+00	2026-08-24 05:03:22.58649+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
00d6e713-04ed-4804-babf-899eced58937	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	mWFwUEVqS1s6Wngfw9fD51JpdxBySzPCIRjHtDOJT6A=	2026-08-31 05:03:22.585618+00	2026-08-24 05:03:59.595582+00	\N	2026-08-24 05:03:22.58649+00	2026-08-24 05:03:59.596089+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
076fbe5b-ed82-4e90-b673-7d192546dc10	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+uZqfwIto88O4XhQouxIJq3vr0QxHSnI54RpdMudvfw=	2026-08-31 05:03:59.595888+00	2026-08-24 05:04:31.265311+00	\N	2026-08-24 05:03:59.596089+00	2026-08-24 05:04:31.266146+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
61936eae-81f1-46a2-a504-3b4493d50646	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bgtPKBN5+nbejXLW9H/hxFRfFPfWZnV4VgYIIbsRrVU=	2026-08-31 05:04:31.265818+00	2026-08-24 05:07:54.091536+00	\N	2026-08-24 05:04:31.266146+00	2026-08-24 05:07:54.09454+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
17557c7a-d860-4f2f-9b03-09580dc9c943	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	B+gk0BTwJWyzPOYarAh/nBL5Pu+i3k9ycZO967VuLCg=	2026-08-31 05:07:54.09415+00	2026-08-24 05:25:44.019502+00	\N	2026-08-24 05:07:54.09454+00	2026-08-24 05:25:44.020188+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f1ae02ba-2301-4495-a9ed-a2b9cd267175	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Z1vWS6Lq/Qyq2Nw3Ucmo8o1g9ysYV7AyFYly9PRmi5E=	2026-08-31 05:25:44.019955+00	2026-08-24 05:25:45.040188+00	\N	2026-08-24 05:25:44.020188+00	2026-08-24 05:25:45.045033+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ace13860-9bb4-40d6-bcb8-ed601ec4d29a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	67xG+jjZqBCylOZQG3mnPku8RafStDngtXA5NGYEiGU=	2026-08-31 05:25:45.044759+00	2026-08-24 05:29:19.975581+00	\N	2026-08-24 05:25:45.045033+00	2026-08-24 05:29:19.976291+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e67a76ff-7666-457c-b064-16c757cb4cc6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vbKPCaWRfg9iIr10ZyFTTfDk/nBFd7uKl8nMf34Nl8U=	2026-08-31 05:29:19.975923+00	2026-08-25 06:03:11.853296+00	\N	2026-08-24 05:29:19.976291+00	2026-08-25 06:03:12.058601+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7d7d11a6-bfbc-4a3c-b15f-e0732905dea9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	EwockIwIkgHAeq+wmHD22c43qwxi+3T/GDwyznriO+U=	2026-09-01 06:03:12.014934+00	2026-08-25 06:36:52.102417+00	\N	2026-08-25 06:03:12.058601+00	2026-08-25 06:36:52.109027+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ddbf2904-bcce-4db2-ac70-8abcb85921c5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	chYV4ticDL5eNftOFmUMu23ljkigBbDBToCHduCbcss=	2026-09-01 06:36:52.10317+00	2026-08-25 07:01:03.249498+00	\N	2026-08-25 06:36:52.109027+00	2026-08-25 07:01:03.25+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dcd819a0-bb4c-4cd4-9bbd-c2423a602cff	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2quE5CA7jlTn2LE/pk3I2aG0vgv5s69P9ylp0zKAGA8=	2026-09-01 07:01:03.249787+00	2026-08-25 07:13:20.349114+00	\N	2026-08-25 07:01:03.25+00	2026-08-25 07:13:20.350439+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eb122ab2-04a9-4d7c-a9d7-acb866be1f1b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/BKcdQDS+CxVeYq6Ks+WACgPVnWaxunkeWoz5a69OhU=	2026-09-01 07:13:20.349612+00	2026-08-25 07:15:16.516529+00	\N	2026-08-25 07:13:20.350439+00	2026-08-25 07:15:16.641954+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
68d0a972-7ce0-4a6b-9adf-e22ade796128	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+zNSw1JzVv2koXp+m/mHeR8qMlynNkmZ7W8NXCGatIc=	2026-09-01 07:15:16.600571+00	2026-08-25 07:16:03.27494+00	\N	2026-08-25 07:15:16.641954+00	2026-08-25 07:16:03.280389+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
eb36b54c-1908-4062-abf1-5f70f3eb0de4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/nYH6bMBu8KJotdBcB7O4TrMl1Cp4omHP+/yx/d3iR4=	2026-09-01 07:16:03.27719+00	2026-08-25 07:16:26.046492+00	\N	2026-08-25 07:16:03.280389+00	2026-08-25 07:16:26.047689+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
485ce7df-ba8f-4b09-9053-e85dc94a96dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GOGmZ4IMFx3yKfjnvFqkRh8cXGSdbWzENEsoLNPVChk=	2026-09-01 07:16:26.047191+00	2026-08-25 07:17:48.546365+00	\N	2026-08-25 07:16:26.047689+00	2026-08-25 07:17:48.546904+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
22586770-4bdc-49f5-8705-1b933a88252a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Dz0DPVf5xOkFcQ7jZ+DOcLcp4RhGz0ratK8HoTeO7ZU=	2026-09-01 07:17:48.546687+00	2026-08-25 07:18:18.245472+00	\N	2026-08-25 07:17:48.546904+00	2026-08-25 07:18:18.246198+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2174789d-4d9d-4c23-818d-0f53f3dd5642	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	IiF5xRh63xfndTYc9bATB8nuw+wGqZ9Wb4Ybb4GV13U=	2026-09-01 07:18:18.245936+00	2026-08-25 07:18:59.166466+00	\N	2026-08-25 07:18:18.246198+00	2026-08-25 07:18:59.167424+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
95c5fd06-4796-485e-8808-dcc6cb06b112	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PJrlkG7sAg+Ehk2RpI7s9VoK1rNJ7e6NZqkeeLN5/ZE=	2026-09-01 07:18:59.167058+00	2026-08-25 07:24:16.912023+00	\N	2026-08-25 07:18:59.167424+00	2026-08-25 07:24:17.052523+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0a2737a2-085b-47a6-929d-4bdf424252dd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CoFY3zoqvtHEdEqYBRiEpP+TtYPPK8YSAnL35QMsgr4=	2026-09-01 07:24:17.031632+00	2026-08-25 07:24:17.665322+00	\N	2026-08-25 07:24:17.052523+00	2026-08-25 07:24:17.666815+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bd8ff7b3-6289-4ae1-b159-d50053d7c902	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	JdJIo7H7PcSDfGg17gurE+2ZqUaFxNOjpdOcYKROS9I=	2026-09-01 07:24:17.666292+00	2026-08-25 07:26:18.014317+00	\N	2026-08-25 07:24:17.666815+00	2026-08-25 07:26:18.028326+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c2d3875f-824b-452c-8337-f84ab87d1e2f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9l9yxaXScZW+OfI5ale27BwdR5axG+ZgIT2+lE0z9zk=	2026-09-01 07:26:18.015809+00	2026-08-25 07:30:28.169656+00	\N	2026-08-25 07:26:18.028326+00	2026-08-25 07:30:28.169712+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
df930987-ad78-445d-afa2-497c1cefe42f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sjaNC8QCNAI8gGlwIZdgEQ0yjFLNxnuDwAOcmFuJPMc=	2026-09-01 07:30:28.783862+00	2026-08-25 09:29:09.359059+00	\N	2026-08-25 07:30:28.784141+00	2026-08-25 09:29:09.359201+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
921ee17c-d4e9-4ea4-b953-c595d10c065a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zQ6S0RGtadMcrloFkhE9n35Cfx5QxSYoms7C3dM21Sw=	2026-09-01 09:29:10.208817+00	2026-08-25 09:29:39.520468+00	\N	2026-08-25 09:29:10.215188+00	2026-08-25 09:29:39.521263+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b042ed0f-a3e3-4b12-8c06-104e414bbd53	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CAVp1tm5vhAYZqoiKdUhvSuFE3qwYS00qvB0c5gK6tU=	2026-09-01 09:29:39.52094+00	2026-08-25 09:30:02.826469+00	\N	2026-08-25 09:29:39.521263+00	2026-08-25 09:30:02.826957+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b1ede194-1361-4e1b-9e36-2b0df5d27793	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zmobMrTux/dODX6QGzLhCDxbKNWrFN5/CkNROgkW7uk=	2026-09-01 09:30:02.82681+00	2026-08-25 09:32:34.222612+00	\N	2026-08-25 09:30:02.826957+00	2026-08-25 09:32:34.223674+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fa0bed9f-8794-4a5d-92c3-be3b039f736c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	K3QSbq/pEzkqg8jqrVbUWiSEkzhxYSOW+DkEwS7sSuk=	2026-09-01 09:32:34.223398+00	2026-08-25 09:39:44.655259+00	\N	2026-08-25 09:32:34.223674+00	2026-08-25 09:39:44.681767+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6495faf7-f15d-4124-8679-319dd6489ad6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DlIgKhaoyqPW6V/ifuUEE5Tf06Tumhl3gczGghUxOc0=	2026-09-01 09:39:44.672192+00	2026-08-25 09:45:26.050963+00	\N	2026-08-25 09:39:44.681767+00	2026-08-25 09:45:26.052514+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
387e98e2-938a-432f-a57a-bb8a4d642481	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4ElPK0Qa/l8tEron0OFS357a999cvi9u+zfGUE6KXS4=	2026-09-01 09:45:26.051695+00	2026-08-25 10:19:16.152563+00	\N	2026-08-25 09:45:26.052514+00	2026-08-25 10:19:16.383231+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d1970e47-16e9-4c59-ad1c-ee915fc081e6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	hSgMB7Lv5itwOLC9Y4P1ddyE4vEMXyLVxLMFGg2jj20=	2026-09-01 10:19:16.349012+00	2026-08-25 10:32:54.419464+00	\N	2026-08-25 10:19:16.383231+00	2026-08-25 10:32:54.432286+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b4519eca-5f54-493d-87c6-ae0ee566dcf3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	o0lQ8Rznsw1fKmcCey3R7JCUaERkzvYg4Ym9AhguP3s=	2026-09-01 10:32:54.428388+00	2026-08-25 10:33:04.774008+00	\N	2026-08-25 10:32:54.432286+00	2026-08-25 10:33:04.777553+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c83292c8-a2c5-4e36-bdc6-436b5bd17912	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8w4g/sNN1ZysVFHTPDQ/CfoIgd4NyrgpyAIsxNNbnRE=	2026-09-01 10:33:04.777361+00	2026-08-25 11:26:17.168665+00	\N	2026-08-25 10:33:04.777553+00	2026-08-25 11:26:17.55126+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
32d30f4c-c163-46a3-8ea8-5b0bc227dac0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0NykrY/c+E0MnWwFOVy6nb74BRi3RUNwf6BkXk17zYg=	2026-09-01 11:26:17.488055+00	2026-08-26 05:37:00.813729+00	\N	2026-08-25 11:26:17.55126+00	2026-08-26 05:37:00.831686+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f528dfa4-3925-413c-8cda-a2688deb0292	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HO0/YTCDfjRZsbcw9eZ6b0tGmhd63+nuSUDzngkNiBA=	2026-09-02 05:37:00.827266+00	2026-08-26 05:37:31.088951+00	\N	2026-08-26 05:37:00.831686+00	2026-08-26 05:37:31.099391+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
faae4bd0-c6d3-435d-b6c4-3849a8266346	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PbaibS0EmZscPSVvzykvLXe2/vlY6LOCzR4DcHXI/LI=	2026-09-02 05:37:31.099182+00	2026-08-26 05:37:54.273081+00	\N	2026-08-26 05:37:31.099391+00	2026-08-26 05:37:54.273092+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
48b4025a-faff-4b23-b207-36507a21f7dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UFZGG1zvVzn/oLQ9JzVawvquv3zIv+jUNh4lKa0W4NA=	2026-09-02 05:37:54.9817+00	2026-08-26 05:52:01.942307+00	\N	2026-08-26 05:37:54.981849+00	2026-08-26 05:52:01.970635+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d4ca6c41-cc61-4277-b3f2-09f9d15d4e5d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YtCOfHi7hel46I6mEzmfs69xPWVxvxLJ/aqbEMeW8z4=	2026-09-02 05:52:01.962366+00	2026-08-26 05:52:07.196096+00	\N	2026-08-26 05:52:01.970635+00	2026-08-26 05:52:07.196892+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
326ea601-235a-45ca-a553-ce3346ada060	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	JNvKcmj1/AXS77UTVFOCqd42t2xtUs/9ybjbW5vtZfE=	2026-09-02 05:52:07.196689+00	2026-08-26 05:53:56.106669+00	\N	2026-08-26 05:52:07.196892+00	2026-08-26 05:53:56.141835+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
483c6c63-4514-4bf3-8cac-bf92461d777e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UfGhdBBEKhinx7SI5RQD3J+PJY3KuTR0kdf2+CtEMUs=	2026-09-02 05:53:56.136539+00	2026-08-26 05:53:58.542152+00	\N	2026-08-26 05:53:56.141835+00	2026-08-26 05:53:58.546497+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7896a328-85a1-4dd6-985b-b13156d41e40	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	85ltcFMtqY5Y1CCatF+8tRPtQZNIv8McKRs3jiCsANQ=	2026-09-02 05:53:58.54635+00	2026-08-26 06:02:22.993+00	\N	2026-08-26 05:53:58.546497+00	2026-08-26 06:02:23.002206+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
46ce1981-12bb-484f-add0-af0a47411ec3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2vbJLHTzJFt4rTVjv50BIzRYyC5oa176BoLwGkaix/4=	2026-09-02 06:02:23.0011+00	2026-08-26 06:02:32.54037+00	\N	2026-08-26 06:02:23.002206+00	2026-08-26 06:02:32.542883+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
85a37037-867f-4399-b05f-5d8be45c0306	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GEjgTCj7dXnpg0/Vg3tFgtDpd/WkVrf6sMDTvlOLcXg=	2026-09-02 06:02:32.542679+00	2026-08-26 06:32:52.138781+00	\N	2026-08-26 06:02:32.542883+00	2026-08-26 06:32:52.140006+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d9f1adc7-383c-420e-91fa-14abc43b428b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	EZBSKhx+/U3wZA+s/yi/N/03LbMbysRXcVqv4xEz5/4=	2026-09-02 06:32:54.60495+00	2026-08-26 07:01:06.435151+00	\N	2026-08-26 06:32:54.619937+00	2026-08-26 07:01:06.444742+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
81e52c44-a414-41a0-9ff1-27dd258cacf4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CL/SHhyBlArAJuYReNT05CJX+59SUOeFCEhOk9gvueY=	2026-09-02 07:01:07.290007+00	2026-08-26 07:12:23.57384+00	\N	2026-08-26 07:01:07.326124+00	2026-08-26 07:12:23.573884+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a27a0c11-838c-4f16-95b8-9b6ccc9917ae	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PJHv6sSKnmw8076w6BYG1YyjHJWQmXLJLc4R2XrppKA=	2026-09-02 07:12:24.181757+00	2026-08-26 07:34:20.994914+00	\N	2026-08-26 07:12:24.18252+00	2026-08-26 07:34:20.994943+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
11da5ba9-118d-477d-8185-eefda92466f4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	B4XUo0gvOF0csO/zQxEBhSSbQ4wAKcjHVjOMfi4Z5W0=	2026-09-02 07:34:22.203606+00	2026-08-26 07:34:35.084539+00	\N	2026-08-26 07:34:22.203981+00	2026-08-26 07:34:35.084561+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2f41c4a0-c5a2-4b94-8647-93f79cc318d5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	f/SFut0LpBz2Mlo6yzSFOWexFG5qo6GbtzARglAv6kI=	2026-09-02 07:34:36.012578+00	2026-08-27 06:53:34.087827+00	\N	2026-08-26 07:34:36.01329+00	2026-08-27 06:53:34.088221+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a608588f-338f-4956-9c90-95c3c46158a6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	t3sA3AkerPrpL+7UFS9DTMKp+sJMLBjaEH1nLLFcTKU=	2026-09-03 06:53:34.088104+00	2026-08-27 06:54:41.206316+00	\N	2026-08-27 06:53:34.088221+00	2026-08-27 06:54:41.240669+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f610d46f-052e-42a6-949d-9af020debc03	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9Zjp0gtVTxsNI4Fr6ah3InHm5DVeyyYnzKrMJE9TvLs=	2026-09-03 08:07:18.320824+00	2026-08-27 08:38:37.618489+00	\N	2026-08-27 08:07:18.320998+00	2026-08-27 08:38:37.619074+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5d1a1dea-60f4-4fcd-bff4-540c3a7c642b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tlZXwZOQw9O9R7pstOd54z9wks8kc1hpRtVIgftgo+w=	2026-09-03 09:34:19.031995+00	2026-08-27 09:34:40.574118+00	\N	2026-08-27 09:34:19.032115+00	2026-08-27 09:34:40.574464+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ef937b45-6114-4e74-8e4d-fae0da79fafd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	YtkrxQog7yZoZyDsO4H5Rmly5zCYzix3NSIE9XJlc3w=	2026-09-03 12:25:07.78777+00	2026-08-27 12:26:32.236531+00	\N	2026-08-27 12:25:07.78848+00	2026-08-27 12:26:32.237248+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f9dc871f-456e-4853-8bc3-e8cb02af7956	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	S4UjvLG8UBziL2QghbnYe52VobFPyrePTYWifk0MbPc=	2026-09-03 12:30:11.572242+00	2026-08-27 12:30:46.889467+00	\N	2026-08-27 12:30:11.572358+00	2026-08-27 12:30:46.890361+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f90be0d8-9016-4fff-9634-5d9fc40a13e7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SXu/rVHbSaPi8EzmI8lbMME6Ge1zF4V1GbUXV+X29aI=	2026-09-03 12:30:46.890259+00	2026-08-28 04:47:55.405458+00	\N	2026-08-27 12:30:46.890361+00	2026-08-28 04:47:55.405626+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
437f819f-8373-49ce-ba47-66872355c1e5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qKPuGErdVA7DJkJE9mgSPmult6rg9oJmuwAjrJHyq9I=	2026-09-04 05:48:25.036242+00	2026-08-28 06:11:05.61678+00	\N	2026-08-28 05:48:25.03673+00	2026-08-28 06:11:05.641284+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
88553461-c0d4-4dec-89ad-6bdce9fcc489	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	LEKmoOvkO00mgnt5msgoa3XdTJLM7AJjxMIr19L6tlo=	2026-09-04 08:29:21.715759+00	2026-08-28 08:41:06.056417+00	\N	2026-08-28 08:29:21.716197+00	2026-08-28 08:41:06.057572+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
707f88ad-ea95-4f10-b36a-6c7ccd13760a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	MWs8Hw2zNlm60btKEnwaAaWSoalOjkrSjMMneTpra0o=	2026-09-07 09:30:55.329947+00	2026-08-31 09:32:28.772927+00	\N	2026-08-31 09:30:55.331741+00	2026-08-31 09:32:28.773344+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4dbfc378-2f6e-484c-9fe7-2f38a6aa6283	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	wh8g/LY3ZMc/vMP5xoxiVKgT95bNvJ59EOWpK3eWg4M=	2026-09-07 09:32:28.773256+00	2026-08-31 09:39:54.682002+00	\N	2026-08-31 09:32:28.773344+00	2026-08-31 09:39:54.682079+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
be068d64-548d-4470-b228-9ea08e1c5943	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CzeJkz63xcGeLXNETNy+BR3/Ozohx2OrwaaEMXSO3yA=	2026-09-09 07:01:19.348944+00	2026-09-02 07:22:42.574772+00	\N	2026-09-02 07:01:19.359519+00	2026-09-02 07:22:42.781084+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f9c7c347-6e67-4d3b-a92c-4e0aef0203e4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nPRHhRC/CV28ObMqRhCl8HSTiZq93lFGxc6rhkPRDNY=	2026-09-09 08:05:00.85736+00	2026-09-02 08:06:20.232738+00	\N	2026-09-02 08:05:00.861096+00	2026-09-02 08:06:20.233658+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ae737a3b-2def-4ad9-bf89-8cdd83a0f957	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	RzMbi/ao86QAF+iNODcfnseNv3COg6cNjyC3uUDxC38=	2026-09-07 09:32:24.607551+00	2026-09-02 08:59:30.716257+00	\N	2026-08-31 09:32:24.607651+00	2026-09-02 08:59:31.211234+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
619eb01a-5567-4320-a48e-c7f421236a53	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2eSGI9ceMXKeKu981LpyvyCs1V6eyPPuFZN2jNeXHSE=	2026-09-09 09:53:32.843144+00	2026-09-02 09:53:33.282508+00	\N	2026-09-02 09:53:32.904568+00	2026-09-02 09:53:33.283489+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9ddd1dcc-432e-4fef-8ec7-7052ecceb87e	40517b71-5e62-182e-73b5-d4070e20a3c2	solfDv8uZty+XSYLKIDER9nzJVTEKvjXE26euQHe1Js=	2026-09-09 09:55:59.461846+00	2026-09-02 10:01:37.917408+00	\N	2026-09-02 09:55:59.470512+00	2026-09-02 10:01:37.95922+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
88841ac6-1cdf-43b1-9970-c898937f6d36	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3BMnRrhgleDn6ZN8+PlV+Bha7Qa2lSdEeUELbIKoQk4=	2026-09-09 09:53:33.283236+00	2026-09-02 10:01:39.019577+00	\N	2026-09-02 09:53:33.283489+00	2026-09-02 10:01:39.020573+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
10ad92dd-7b06-46cb-af5b-a1bdbd2faddf	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Wmen5VZYgjFC3/1BjSYrFtru6qWNCjy/k0XM74R4sug=	2026-09-09 10:18:56.748099+00	2026-09-02 10:18:58.178121+00	\N	2026-09-02 10:18:56.749672+00	2026-09-02 10:18:58.179014+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f781a175-8f19-46dd-91cf-d426a752767e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	RhCciW+N0CZUrDNWAXv+GTG2kiGs1l+/5lwASNOEHFc=	2026-09-09 10:18:58.178815+00	2026-09-02 10:45:52.188651+00	\N	2026-09-02 10:18:58.179014+00	2026-09-02 10:45:52.191646+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3dd3e00a-b8d7-4f32-8fd1-55dc8532be11	40517b71-5e62-182e-73b5-d4070e20a3c2	Fz5wIq8l7m/wBzWDd9ZysNlt5fqfTYNqXe9U/AuCnW8=	2026-09-09 11:17:55.194899+00	2026-09-02 11:18:48.310319+00	\N	2026-09-02 11:17:55.214203+00	2026-09-02 11:18:48.310811+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f7209070-d42a-4d76-a024-c8a7b76f9542	40517b71-5e62-182e-73b5-d4070e20a3c2	FAcwqWuViyhI3gWtEmEWRnFvBiOlCcTGu9ei6Kv0m3c=	2026-09-09 11:18:48.310622+00	2026-09-02 11:29:02.282872+00	\N	2026-09-02 11:18:48.310811+00	2026-09-02 11:29:02.32411+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
23e0f09d-7707-40d6-8747-66bd6c4e015c	40517b71-5e62-182e-73b5-d4070e20a3c2	7AZQAUZgdWbjFCGyLzV7M08FKgC3hMJjgMDEg+ws2HM=	2026-09-09 12:00:31.835004+00	2026-09-02 12:00:34.021665+00	\N	2026-09-02 12:00:31.944697+00	2026-09-02 12:00:34.028751+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d2e41d67-98a8-4e36-b46f-fe3199687795	40517b71-5e62-182e-73b5-d4070e20a3c2	W7E6wMDf/4zauGTXDr43S2udT6yoYDxyX/RjSqZxBNY=	2026-09-09 12:00:34.023154+00	2026-09-02 12:00:40.09011+00	\N	2026-09-02 12:00:34.028751+00	2026-09-02 12:00:40.091286+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6b7ac5e9-2e55-4a3d-919c-1fe29fe5b9cf	40517b71-5e62-182e-73b5-d4070e20a3c2	pJ3G+ooKkUJodi00a2sHyoxtfzMTsVlhTZbRHH6+A74=	2026-09-09 12:00:40.090817+00	2026-09-02 12:00:43.957104+00	\N	2026-09-02 12:00:40.091286+00	2026-09-02 12:00:43.958027+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c2ec7458-7128-4115-9de0-c440331fdfed	40517b71-5e62-182e-73b5-d4070e20a3c2	J7elCBAxT3FVDlC2ayDhF+U/QlDzYgl7kF7Va7snT4Q=	2026-09-09 12:00:43.957644+00	2026-09-02 12:00:45.617076+00	\N	2026-09-02 12:00:43.958027+00	2026-09-02 12:00:45.618654+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6cbca43e-8fd5-4ae8-a12c-077a5ba87ddb	40517b71-5e62-182e-73b5-d4070e20a3c2	JfnuVUOKLc5ISYAt/QwdeN0gSVcZ7PNf0Ug+oMbmJmY=	2026-09-09 12:00:45.6183+00	2026-09-02 12:00:46.970718+00	\N	2026-09-02 12:00:45.618654+00	2026-09-02 12:00:46.972071+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
92fc54d2-fb88-41fe-bc03-ef9a09d23302	40517b71-5e62-182e-73b5-d4070e20a3c2	iIwJr+PaZUd0FnQWgzVdOy7XJcicluq3nErOUSImvYY=	2026-09-09 12:00:50.330629+00	2026-09-02 12:01:46.923122+00	\N	2026-09-02 12:00:50.330807+00	2026-09-02 12:01:46.925109+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a91aee72-ec3a-42b8-b6a7-e8a8d2898f32	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tF8QwIROgYdkHuz67kg/Hw+Wb91WP+3xPJAvC6VwVvY=	2026-09-09 13:06:30.008958+00	2026-09-02 13:06:33.314133+00	\N	2026-09-02 13:06:30.010509+00	2026-09-02 13:06:33.314602+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ae1c4be9-535d-47ce-868c-8ccc81226e76	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+pBq3IYG8LruqMJbIlhi7NMpKWmU5f8ATsave0faeLM=	2026-09-09 13:06:33.314464+00	2026-09-02 13:06:38.917853+00	\N	2026-09-02 13:06:33.314602+00	2026-09-02 13:06:38.918126+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ad597755-5402-4d1a-acc1-e5c690444a97	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0Jtw0TYyCFugJ/fmcMPf/RPJuPi4bWQyNF7pOZE+OLQ=	2026-09-09 13:06:38.917995+00	2026-09-02 13:06:44.141601+00	\N	2026-09-02 13:06:38.918126+00	2026-09-02 13:06:44.141957+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e3174e94-301a-4c48-bcdf-c2e158b8a333	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zUixj0PycuhqtYr3fWCt3CdMqCjMvEVtkAc+VjXOOe0=	2026-09-09 13:06:44.141841+00	2026-09-02 13:06:57.15374+00	\N	2026-09-02 13:06:44.141957+00	2026-09-02 13:06:57.154365+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b25c8fc8-b635-489f-8935-3991c7ef3cd3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ShZ8x+zF6O5OCI9oSqeMCjnw0+2pgML0l+UINukpEsA=	2026-09-09 13:06:57.154041+00	2026-09-02 13:07:10.100184+00	\N	2026-09-02 13:06:57.154365+00	2026-09-02 13:07:10.100467+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
042d32f6-4e77-4627-ad81-91310374938e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	AKrhE2NPtRQibmilQDKU66QguHlLV2YuajMNAyEDY3E=	2026-09-09 13:07:10.100363+00	2026-09-02 13:07:19.766237+00	\N	2026-09-02 13:07:10.100467+00	2026-09-02 13:07:19.76696+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d57382a7-8554-4942-a4d3-1297ef225cc2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	QgB/jeOYb8yNajv+P5FZvGTmB3/fAoGoivYLD5K5Djo=	2026-09-09 13:07:19.766864+00	2026-09-02 13:07:27.348991+00	\N	2026-09-02 13:07:19.76696+00	2026-09-02 13:07:27.349233+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
decf274a-6340-4ecd-b53d-7176d17c59ad	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9mB1BtCld98kWIj47ZwetKA4ZU8ktCVzSikW94ipm6g=	2026-09-09 13:46:24.863395+00	2026-09-02 13:47:55.763834+00	\N	2026-09-02 13:46:24.863513+00	2026-09-02 13:47:55.76413+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f15edf0d-d8f6-4913-9084-7daf306b9d34	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9GmUlBsnhZvJLb11FfVPQFIlvP9CxXET8bTmueQgFfA=	2026-09-09 13:47:55.764039+00	2026-09-03 06:18:30.80828+00	\N	2026-09-02 13:47:55.76413+00	2026-09-03 06:18:30.808499+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b5dd2bfa-6daa-4f14-8a61-79e7aec796b3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9TwZ0B9VQ0HUyqe+mZqglProPPTVmRa50YlHODP3DUU=	2026-09-10 06:44:36.514764+00	2026-09-03 07:00:27.70568+00	\N	2026-09-03 06:44:36.515377+00	2026-09-03 07:00:27.710545+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8313f637-7ea4-4185-ac80-df9e82649e86	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PZVnmf//JNMOB7JVRNa6loAQ1QcMCVUPlGJCecut1y0=	2026-09-10 08:40:10.621432+00	2026-09-03 08:43:58.624245+00	\N	2026-09-03 08:40:10.621909+00	2026-09-03 08:43:58.626306+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
122fbec1-a6a9-473a-96a6-4823687617cb	d1130837-5c69-40b6-a65f-913214e66693	4IlVSEz5T5nT/z++spsUkc+jTnpUPV6Vzn4eVOW6TMg=	2026-09-10 10:04:59.210917+00	2026-09-03 10:45:24.432718+00	\N	2026-09-03 10:04:59.211326+00	2026-09-03 10:45:24.499542+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
539015dc-f47c-4a68-aefa-e912a782540f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	y3W3r/U/P3cKaHG/ZTpPYnIsJ3gUs5AFcLNZjiU+g3M=	2026-09-10 12:41:40.660729+00	2026-09-03 12:47:27.363026+00	\N	2026-09-03 12:41:40.662869+00	2026-09-03 12:47:27.365678+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
27d3059e-dbeb-48ba-b504-f83226e6d5ca	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Xj5+QH/U9g7GkTYhx1RBx0ZggPWOLbmmz0a4b6eRLHo=	2026-09-03 06:54:41.226141+00	2026-08-27 06:54:52.252485+00	\N	2026-08-27 06:54:41.240669+00	2026-08-27 06:54:52.254307+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e56589cc-dc42-411d-a41b-f476d7fbe98c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ML3hkGCCrfC1aFqXpekw5spUL9ObvcfE7D0ZK1ZmISQ=	2026-09-03 06:54:52.253074+00	2026-08-27 07:14:19.748295+00	\N	2026-08-27 06:54:52.254307+00	2026-08-27 07:14:19.748795+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
39cb1a26-f466-498e-a566-8598a7bb6ebf	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	MbKMb1uh9ODOJMx8+AY6tMQao062TjQRbL4mepuJtzc=	2026-09-03 08:38:37.618865+00	2026-08-27 08:41:38.422409+00	\N	2026-08-27 08:38:37.619074+00	2026-08-27 08:41:38.422806+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6f0850f9-d920-4151-ad9f-688c4bad7166	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	mOeyFQkf3TRvjoDNfT4ZbHeSjndt2RE6nRNyhOFCSYw=	2026-09-03 08:41:38.422678+00	2026-08-27 08:49:41.140781+00	\N	2026-08-27 08:41:38.422806+00	2026-08-27 08:49:41.140794+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8a162705-bfa4-47ff-ac8e-7220257d5e98	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ph/Hp3SXIEYNoEYkL4ypDfnH//IFfhxy/k3DVWMQNO0=	2026-09-03 08:49:41.508074+00	2026-08-27 09:03:21.317149+00	\N	2026-08-27 08:49:41.508205+00	2026-08-27 09:03:21.319765+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a8c72431-976e-4f3e-aedf-dea4b7deb1e8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	7oCywI+zO72v+p/FPs5FC/hHUQDj5edcslAbZA9Lz/I=	2026-09-03 09:54:03.647618+00	2026-08-27 10:52:27.990323+00	\N	2026-08-27 09:54:03.647812+00	2026-08-27 10:52:27.990546+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
824f1183-bf9d-45cb-b93b-4435220606c4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eKDUd/ShM7QErLuNTRZ+uj5J2l9Ub64Wbf+f3RNDedE=	2026-09-03 12:26:32.237129+00	2026-08-27 12:30:11.571567+00	\N	2026-08-27 12:26:32.237248+00	2026-08-27 12:30:11.572358+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
59021ed9-c55a-42b5-928f-a8a37bfc6a30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GHt73SWKrOlBJMJiXv8J0PVQMf7DAUq7u8gWvuUCuFk=	2026-09-04 08:41:06.057437+00	2026-08-28 08:41:29.220502+00	\N	2026-08-28 08:41:06.057572+00	2026-08-28 08:41:29.221089+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ad3e09b0-33ab-4340-b1ed-4cc6545bfb84	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	d128sA0+22xY9SzyemwYbdsmBUuJmV9khF6HHth56pk=	2026-09-04 08:42:42.936867+00	2026-08-28 08:55:08.255801+00	\N	2026-08-28 08:42:42.937291+00	2026-08-28 08:55:08.256684+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
699656f3-310f-4fef-b06b-15034d73dc7e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qAgtoSK6rOIyRlz0JCSEtQt5EBWTZ2BRlVzT8RCwh1M=	2026-09-07 09:39:55.01231+00	2026-08-31 09:41:18.742859+00	\N	2026-08-31 09:39:55.012975+00	2026-08-31 09:41:18.745373+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
abc275b1-6f8e-451d-93e4-b90236c26bd2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3lSFWbuv27yq5XV4DA6ZJjwRyssBYCVgqlPuCoJ33jI=	2026-09-07 09:41:18.744656+00	2026-08-31 09:41:59.364665+00	\N	2026-08-31 09:41:18.745373+00	2026-08-31 09:41:59.365401+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a4fef8a4-f897-4c37-a1d4-26629926cf59	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	oYZRSrw4X+OdBeeIinTbud9U/47xkaYxDxw4QFMflxA=	2026-09-07 09:41:59.365114+00	2026-08-31 09:51:06.496297+00	\N	2026-08-31 09:41:59.365401+00	2026-08-31 09:51:06.49714+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3b5dd75a-3c1d-4cb2-8e64-e3b186c2905c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	iXXM54+7mf30NZDt3WJ6taRQ83pAVfW2++uz/72Tf0c=	2026-09-09 07:22:42.706851+00	2026-09-02 07:31:46.651431+00	\N	2026-09-02 07:22:42.781084+00	2026-09-02 07:31:46.71772+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0fe6369d-24d7-4b8b-8db0-379f8b4879c0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CByplYJnx1Lbw8Ghw1W6zKc+ysZN9xUsbJoR3a7lYW0=	2026-09-09 08:06:22.591565+00	2026-09-02 08:06:23.097276+00	\N	2026-09-02 08:06:22.60867+00	2026-09-02 08:06:23.10122+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6a088254-1999-4206-b954-69e714f6b52a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	x0OEM44m8537/8C9S44kGOeKnijFnC0yHmd+3+zz+/A=	2026-09-09 08:06:23.099752+00	2026-09-02 08:21:05.034492+00	\N	2026-09-02 08:06:23.10122+00	2026-09-02 08:21:05.034516+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7f39c75c-2bf2-44d2-b29e-f3ba10b23c57	40517b71-5e62-182e-73b5-d4070e20a3c2	vr04lBMNtlBNorpGOusIu1ewMzFwf60mEqxP1t+4yrE=	2026-08-29 06:42:50.70387+00	2026-09-02 09:55:54.844207+00	\N	2026-08-22 06:42:50.703952+00	2026-09-02 09:55:54.882553+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4451d114-61bb-4571-ae87-f9be0ae0c6fc	40517b71-5e62-182e-73b5-d4070e20a3c2	njG7QeICf2/qLPSxOq+lHiGI8B3O2OWZtJeTgyA3Tf8=	2026-09-09 09:55:54.867881+00	2026-09-02 09:55:59.458493+00	\N	2026-09-02 09:55:54.882553+00	2026-09-02 09:55:59.470512+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
706add68-7051-4265-8de9-23106c5f6967	40517b71-5e62-182e-73b5-d4070e20a3c2	EyyHQyi1joVT6StLL9BuNyXVZRofmzSMgVTQ2xII8Nc=	2026-09-09 10:30:43.430685+00	2026-09-02 10:30:49.801136+00	\N	2026-09-02 10:30:43.457442+00	2026-09-02 10:30:49.804009+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0333dd25-b754-4af3-a4c2-13517986760a	40517b71-5e62-182e-73b5-d4070e20a3c2	bEvmytjunuwKJGYNvRePYdjOI44cJCsoB8Mks36//gg=	2026-09-09 10:30:51.31079+00	2026-09-02 10:30:52.399226+00	\N	2026-09-02 10:30:51.384963+00	2026-09-02 10:30:52.4296+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
60b41b85-4f4b-4b85-8d9e-18bc573a3a5a	40517b71-5e62-182e-73b5-d4070e20a3c2	aGk6x3uRd3qav2Gq5AuhlSxKjtZm6BwISVGCzgPVtOg=	2026-09-09 11:29:02.306856+00	2026-09-02 11:39:45.646694+00	\N	2026-09-02 11:29:02.32411+00	2026-09-02 11:39:45.685206+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
01fe2fe4-c4be-4380-bcdc-22e77c98c34b	40517b71-5e62-182e-73b5-d4070e20a3c2	U6FFFp35ikileOM5kUhGfZMz0GND5wVmsie4Z4kU918=	2026-09-09 12:00:46.971705+00	2026-09-02 12:00:48.446355+00	\N	2026-09-02 12:00:46.972071+00	2026-09-02 12:00:48.447082+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5a2f0d96-8597-4702-80dd-65757cd051af	40517b71-5e62-182e-73b5-d4070e20a3c2	i5mCn9HskA+TYIOerVXSjKDtWo0jlH5rMmfC4BAAbz0=	2026-09-09 12:00:48.446862+00	2026-09-02 12:00:50.330224+00	\N	2026-09-02 12:00:48.447082+00	2026-09-02 12:00:50.330807+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c62722eb-a3f3-4abf-b050-27232739c4d4	40517b71-5e62-182e-73b5-d4070e20a3c2	RR9IeHWnkIborbfIx06DVLFPXlbyHOknNFA/3UyHwhU=	2026-09-09 12:02:46.032003+00	2026-09-02 12:02:46.368722+00	\N	2026-09-02 12:02:46.037985+00	2026-09-02 12:02:46.370259+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cc97619e-c05d-430e-b9f3-7c4442547ba2	40517b71-5e62-182e-73b5-d4070e20a3c2	RDD1EsHrugLQ8/GJ8SMzuAIe7vMqHmr7FFbjFrs9VVQ=	2026-09-09 12:04:40.883708+00	2026-09-02 12:10:19.476053+00	\N	2026-09-02 12:04:40.891138+00	2026-09-02 12:10:19.505092+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
65109cca-daae-406e-a98c-8c0e352f0d3a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	X3fdkDhZhci0htmiizMRH6D6SNuD5XshTB0js3JXQMo=	2026-09-09 13:07:27.349159+00	2026-09-02 13:07:35.41858+00	\N	2026-09-02 13:07:27.349233+00	2026-09-02 13:07:35.418809+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
982979a9-fe5c-4ec9-ad4e-04a6a281baff	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/EkoqNdXvoy2O8AvS9pu3cd2AgF8hjEkB5vrt+R1p2c=	2026-09-09 13:07:35.418733+00	2026-09-02 13:36:59.565101+00	\N	2026-09-02 13:07:35.418809+00	2026-09-02 13:36:59.565409+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bdc5b000-9704-4ddf-b733-3a5b6c95f1ca	833a28fc-a624-4cbe-8e71-56c51eb53ab2	Z0xqQqR06jQkAlhVG5KzpkBrrACOrw9j7zwJPKiGlwI=	2026-09-09 13:49:55.98515+00	\N	\N	2026-09-02 13:49:55.985636+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
86e3ad9e-d173-42f9-acd0-b8dacd18485c	cdee998d-48e3-4ee3-8d3a-8bb394592377	0VT7CZLPjt7V4mxmZx+1LbXHxC1WXyUTrA01rZKT+/4=	2026-09-09 13:49:56.391498+00	2026-09-02 13:49:56.508241+00	\N	2026-09-02 13:49:56.394362+00	2026-09-02 13:49:56.512247+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9a518111-e54a-4fe6-a47a-05d79131ce58	cdee998d-48e3-4ee3-8d3a-8bb394592377	eC4g/aci2tAd4t07RTuU3aWqgxw5ehjuYEMFyIENERs=	2026-09-09 13:49:56.508843+00	2026-09-02 13:57:08.262547+00	\N	2026-09-02 13:49:56.512247+00	2026-09-02 13:57:08.292543+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
623cfe6f-fec3-4570-94c8-bc5166763706	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	q7lMXhuo13iR+C428V0jDEATdcvdvp7q40vZojxiVrQ=	2026-09-10 07:00:27.708893+00	2026-09-03 07:06:35.765191+00	\N	2026-09-03 07:00:27.710545+00	2026-09-03 07:06:35.7654+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
433c889a-247b-47eb-a6d1-9994fa7b6bc5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	u6LhDziifIrLiJj1N0z64truZhij/1OHoHBBPLkBk0o=	2026-09-10 08:43:58.625673+00	2026-09-03 08:46:26.38396+00	\N	2026-09-03 08:43:58.626306+00	2026-09-03 08:46:26.388067+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e99f3a68-0d96-4f67-9bee-5e4512a37c39	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	768Bw+rz/Bda9gPLdwEdSR9IJTZwHoBAGia2Pjyl8jc=	2026-09-10 10:23:14.444696+00	2026-09-03 10:28:17.157522+00	\N	2026-09-03 10:23:14.467335+00	2026-09-03 10:28:17.158871+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8e49ff01-9e22-43ab-88f3-b6e09b99f9cf	d1130837-5c69-40b6-a65f-913214e66693	PcCfyLfeMzZH9j2WFpdf01JKCx02ZGIsN/uPPw+ACy0=	2026-09-10 12:47:17.66113+00	2026-09-03 12:47:26.327655+00	\N	2026-09-03 12:47:17.674368+00	2026-09-03 12:47:26.327693+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f3063f3e-23da-43ac-8d0e-6bc44b971a94	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	AlrB2Qor6/Hs+Imesrb7AkOsN8dwKw01BRFesl2Ks/Y=	2026-09-10 12:47:27.365278+00	2026-09-03 16:01:28.796477+00	\N	2026-09-03 12:47:27.365678+00	2026-09-03 16:01:28.833921+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2f166c91-56e3-4155-b6bd-f9303b210513	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	w9F0QJzxIetzIoFbJ1BiReap+UM7fIDc2uP+l9K3QyQ=	2026-09-03 07:14:16.765514+00	2026-08-27 07:22:24.629475+00	\N	2026-08-27 07:14:16.766452+00	2026-08-27 07:22:24.630092+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e94bbecf-06ab-4d0f-8080-f952cfae7888	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	S1FXnWy/hGap9xNHYXBIzVGbtGEZX6ZuJxm6UBsrbmE=	2026-09-03 07:14:19.748681+00	2026-08-27 07:35:41.619475+00	\N	2026-08-27 07:14:19.748795+00	2026-08-27 07:35:41.620052+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8b0fdc65-8fc6-4470-8ae7-28041d227ff1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9GH81oYK9cN9qth70fH1LPObC+jbqBJAYjFAubc2J/c=	2026-09-03 09:03:22.285169+00	2026-08-27 09:09:07.259305+00	\N	2026-08-27 09:03:22.303997+00	2026-08-27 09:09:07.259861+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e25d8a13-4088-45b5-8b9d-8c515be35f5a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	LyIsM2tE6yKqQc2pd9CsyZ+9lKjlPO1nn0DegHQZ2Eo=	2026-09-03 10:52:28.362678+00	2026-08-27 10:55:21.49537+00	\N	2026-08-27 10:52:28.364447+00	2026-08-27 10:55:21.496668+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
792ac4d8-4686-4336-921a-c18252333e9a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NvdtJEPcyktpoRVn0rqP7JXJTs01uryBuAlTFncSoDI=	2026-09-03 10:55:21.496183+00	2026-08-27 10:56:36.328087+00	\N	2026-08-27 10:55:21.496668+00	2026-08-27 10:56:36.352999+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5acf2bb9-e27d-4399-9d42-d883eb3985dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	JoysnOIThpdyC4CqA6Jg2CR4C+OMCeV6TP1P0kbgLgw=	2026-09-04 04:47:55.857468+00	2026-08-28 04:49:26.04112+00	\N	2026-08-28 04:47:55.869164+00	2026-08-28 04:49:26.042566+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
154014a0-b38b-4f03-be01-1375d6f501dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bFA2+QzsGHHGDx+sRYLqHWLzsFDNLEgm+uB2T6l8Fpo=	2026-09-04 04:49:26.041655+00	2026-08-28 05:22:28.27464+00	\N	2026-08-28 04:49:26.042566+00	2026-08-28 05:22:28.274757+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8bd2eeed-493e-4298-8739-93f761623412	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DfXASjnWtxFOVIeU50hgLk6jgNuBBb9Ch8kbbq0d+R4=	2026-09-04 06:11:05.630883+00	2026-08-28 06:50:09.073597+00	\N	2026-08-28 06:11:05.641284+00	2026-08-28 06:50:09.09975+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
73cabce6-5764-47dc-a004-576515c53cb4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	jP+s425nAdyXE0B9o06ZVVOtMRPriUCPrCJ4yh4qArs=	2026-09-04 06:50:09.089127+00	2026-08-28 06:51:57.318557+00	\N	2026-08-28 06:50:09.09975+00	2026-08-28 06:51:57.319956+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d032ed25-deab-4032-955a-f2240ccd6d70	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rDoZHYBGPVu+LX/Zgayt9TIdGpw4+CHIBgsgV5gNAdk=	2026-09-04 06:52:08.867563+00	2026-08-28 07:12:58.459145+00	\N	2026-08-28 06:52:08.867713+00	2026-08-28 07:12:58.478787+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8fad95eb-106b-4e7f-8c48-cfb23a5b71c9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zKh6Ylh4WabGPcqqEWjPyqik6tu1xNf2SLvCpwIS1MU=	2026-09-04 08:41:29.220948+00	2026-08-28 08:42:42.936191+00	\N	2026-08-28 08:41:29.221089+00	2026-08-28 08:42:42.937291+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6f60fc02-7d8f-4e82-812b-b258c5d033e9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	C3rNFwSZj3wVfsj1wnnKrWxuYYet9KIsJJdrFv/HiTQ=	2026-09-07 04:55:23.135993+00	2026-08-31 05:35:32.702081+00	\N	2026-08-31 04:55:23.139609+00	2026-08-31 05:35:32.702453+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
606ec91f-e4d9-4a7a-ace3-350955717620	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	cVqCzspfezUiopTyqY8ZFohY03EGH8yUaNXKseM6mZ8=	2026-09-07 09:51:06.496915+00	2026-08-31 10:01:06.541536+00	\N	2026-08-31 09:51:06.49714+00	2026-08-31 10:01:06.542859+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5de59c9d-cffa-4747-868b-620a8db6cbcf	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	aKBp0JaP/u4Al1vgfb7xendwrjafc8tCwcLwYOUY18g=	2026-09-08 05:45:23.78699+00	2026-09-01 05:47:54.84522+00	\N	2026-09-01 05:45:23.799067+00	2026-09-01 05:47:54.846157+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
92be09a3-5e79-47d6-a789-347e09ad7de5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	us6/yeenOYpFmzZn1cYOmipAVR26cpNxBBIxEqpSFk4=	2026-09-08 05:47:54.845485+00	2026-09-01 06:26:15.179611+00	\N	2026-09-01 05:47:54.846157+00	2026-09-01 06:26:15.179726+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3719b8b7-df7d-4795-8b9a-47b273d573b4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	JSULWKJRLzx7vDe4OtSDjr02UZKqxqMIE8YaurLMWUw=	2026-09-08 06:40:14.013652+00	2026-09-01 06:40:25.545642+00	\N	2026-09-01 06:40:14.039469+00	2026-09-01 06:40:25.546745+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
68f2f959-27f8-4980-9059-1cc252deb462	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ix7LXIeeYRH/IO7NOb5UBP+1HPgb7qZupTH36OKkigc=	2026-09-08 06:40:25.545901+00	2026-09-02 05:14:52.224193+00	\N	2026-09-01 06:40:25.546745+00	2026-09-02 05:14:52.332254+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
404ddcb7-af1f-4d75-8361-361de7568ede	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NrOBgLTDG/fR2PHVu8YEvHcp1H5StmD4i40fyeaKeJY=	2026-09-09 05:14:52.292756+00	2026-09-02 05:28:34.886156+00	\N	2026-09-02 05:14:52.332254+00	2026-09-02 05:28:34.984923+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1df6e6d3-26fc-4900-af78-a7c9179c3e3a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	kfhPJtoVMaLsv89GtwEDTZnECFHyDzpc7pzad3xMP1E=	2026-09-09 07:31:46.687753+00	2026-09-02 07:37:15.355797+00	\N	2026-09-02 07:31:46.71772+00	2026-09-02 07:37:15.468688+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
39df6da4-0401-484b-85b9-d2df9f5f622d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	FqGYjf8+RqFN0k+NQNhCg+WbDToVE7SksFYaz+bPV+g=	2026-09-09 08:21:05.596593+00	2026-09-02 08:21:57.193164+00	\N	2026-09-02 08:21:05.597355+00	2026-09-02 08:21:57.193232+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9761eca4-ff2e-4f79-aa22-80b34ada6e14	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	Q5R+JI2SLUa9KRiRr/kOyWPLTsKeU65k7Feax7JKYIY=	2026-09-09 09:56:23.040265+00	2026-09-02 09:56:36.704716+00	\N	2026-09-02 09:56:23.04815+00	2026-09-02 09:56:36.706345+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
11bb90fb-5c23-47c5-b817-72754aaeb6f5	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	vGLdrl+WZd9whSCwy7TLZcYollJ0N/J/jUpWgDyRW9M=	2026-09-09 09:56:36.705285+00	2026-09-02 09:57:34.377911+00	\N	2026-09-02 09:56:36.706345+00	2026-09-02 09:57:34.437298+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d45ca943-7ce3-41af-baf7-12109e5bd845	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	ymCvtRw8QQb5gumJNGk1IJr8+xFaRTIhKOd6KMQ2kuQ=	2026-09-09 09:57:34.430296+00	2026-09-02 10:14:55.62262+00	\N	2026-09-02 09:57:34.437298+00	2026-09-02 10:14:56.244659+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6ec11b70-7b1c-4503-a400-8b787b5c77b9	40517b71-5e62-182e-73b5-d4070e20a3c2	X0fBQZlqvS0ZMVDj4cjhBEk06KhGBPvG5gCIi8I7Fa4=	2026-09-09 10:30:49.801525+00	2026-09-02 10:30:51.301462+00	\N	2026-09-02 10:30:49.804009+00	2026-09-02 10:30:51.384963+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f5ec73b7-a17c-4555-88d8-a7f5bb4d13bd	40517b71-5e62-182e-73b5-d4070e20a3c2	yuXwLPZWpp/xRtjSIbjZePhEplbFqipjFwnCaq+PZUQ=	2026-09-09 12:01:46.924777+00	2026-09-02 12:02:46.023794+00	\N	2026-09-02 12:01:46.925109+00	2026-09-02 12:02:46.037985+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a2f37f46-7eaf-48c7-8ced-61f31ae830ad	40517b71-5e62-182e-73b5-d4070e20a3c2	EoLA/2dEjId1j4+atnqbE827B/+y0InTdrUWqi22AI0=	2026-09-09 12:02:46.369794+00	2026-09-02 12:04:40.870151+00	\N	2026-09-02 12:02:46.370259+00	2026-09-02 12:04:40.891138+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
543d0bed-0121-4ee4-8632-0abd78c3e8fe	40517b71-5e62-182e-73b5-d4070e20a3c2	mhrYWqOb4BkcMtfBF/0DsC+PaWG823YnexgiXe/Zigc=	2026-09-09 13:15:11.389055+00	2026-09-02 13:15:30.226675+00	\N	2026-09-02 13:15:11.394887+00	2026-09-02 13:15:30.227346+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c126c100-d19c-49d6-b711-ea3b42aa16db	40517b71-5e62-182e-73b5-d4070e20a3c2	ZIZ/pOT+7z4hMZTyWp1EsrjLzNb0FyosinGCi0P3xfQ=	2026-09-09 13:15:30.227111+00	2026-09-02 13:15:31.936772+00	\N	2026-09-02 13:15:30.227346+00	2026-09-02 13:15:31.938172+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b0598544-8222-4a06-addc-636c3c722a2d	40517b71-5e62-182e-73b5-d4070e20a3c2	TNRsu/jFgaK9CUsdLQJrvUm4S7TIuONlm6Mobgl7EoA=	2026-09-09 13:15:31.937821+00	2026-09-02 13:15:48.881346+00	\N	2026-09-02 13:15:31.938172+00	2026-09-02 13:15:48.889292+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bd704138-6502-4a93-a124-ff75230f7157	40517b71-5e62-182e-73b5-d4070e20a3c2	f+zbb6u1uWvDB4LnmORFsA3N6EFrVwU/gP9ysfV2k/E=	2026-09-09 13:15:48.888473+00	2026-09-02 13:23:25.169692+00	\N	2026-09-02 13:15:48.889292+00	2026-09-02 13:23:25.208369+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3081336c-b9d5-448a-80f6-205317544ee7	cdee998d-48e3-4ee3-8d3a-8bb394592377	Z5sx0v0GQVkbS5WRsdXPPGr5Pk8Vfo7s863AjBcTyFw=	2026-09-09 13:57:08.268866+00	2026-09-02 13:57:16.757041+00	\N	2026-09-02 13:57:08.292543+00	2026-09-02 13:57:16.765707+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c744ebe8-a6e5-4865-9408-a782673805bd	cdee998d-48e3-4ee3-8d3a-8bb394592377	66l1eKUDH1OOWw3Qr8FnskEac7fo/8yNS3dxhT3qpio=	2026-09-09 13:57:16.759242+00	2026-09-02 13:57:24.209066+00	\N	2026-09-02 13:57:16.765707+00	2026-09-02 13:57:24.21295+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0de37f01-ef09-48f9-bf1a-2f4ade758938	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	12YWN1FrZdH6GDnz77tg6r12HJCRiEUHVyJuN4PLa+8=	2026-09-10 06:18:31.339313+00	2026-09-03 06:20:14.80759+00	\N	2026-09-03 06:18:31.351126+00	2026-09-03 06:20:14.80837+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5798eeaa-bffc-42d1-b9e3-f0a29cb97ce7	730809c0-fc01-a664-03ca-28e0e32d0393	i1Wj6nWt3iIo72COvuOW+Ttxbm53u7w2RderznQVLRo=	2026-09-10 07:05:08.059561+00	2026-09-03 07:05:29.780038+00	\N	2026-09-03 07:05:08.060298+00	2026-09-03 07:05:29.78005+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
decdb328-c61e-453b-a651-858ca9a76870	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	db06CQgy20X/sXJDgf9I2HhccD7mkW4nBjUzCNNNIgA=	2026-09-09 11:36:14.900496+00	2026-09-03 07:05:49.268672+00	\N	2026-09-02 11:36:14.913464+00	2026-09-03 07:05:49.268954+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6487d603-14e5-4955-bb23-97985152f2b7	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	X6c0AlWrEjmCEpCJPZlgog6k5OYF9KcmIAgAqNFSldU=	2026-09-10 07:05:49.268824+00	2026-09-03 07:06:35.458118+00	\N	2026-09-03 07:05:49.268954+00	2026-09-03 07:06:35.458128+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9deadee4-35e2-4668-89f8-ae4b650de0c1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4IiVQU+PMITkMw4xph9oFkvxKEqcvcw3+DSW270WwJs=	2026-09-10 07:06:35.765337+00	2026-09-03 07:07:02.628411+00	\N	2026-09-03 07:06:35.7654+00	2026-09-03 07:07:02.62842+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
796b7098-ca68-46bb-ad50-254d1b563fe5	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	M1wEuSCxuDxET34rjHz1sI0kgWb4i68oQkffeRU0Q88=	2026-09-10 07:07:03.016611+00	2026-09-03 07:07:42.388008+00	\N	2026-09-03 07:07:03.016729+00	2026-09-03 07:07:42.388017+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
52d196a4-f2dc-435d-9d61-515988c443a5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DKF8TSYFCt1EAXE/0OT5gmTDwe52Ot3wZzUPddIVTXI=	2026-09-10 08:46:26.387411+00	2026-09-03 09:31:12.370204+00	\N	2026-09-03 08:46:26.388067+00	2026-09-03 09:31:12.370211+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cfb949f8-9907-4ead-91bf-cea1383fba7f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uMw1SzVNWjhNm91qk6sQ6ezn4dVRw4s15pEgxWBBnBI=	2026-09-10 09:31:12.665505+00	2026-09-03 09:33:06.155779+00	\N	2026-09-03 09:31:12.665633+00	2026-09-03 09:33:06.156146+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0927d222-8550-4deb-8ff0-6a310c4c15f7	cdee998d-48e3-4ee3-8d3a-8bb394592377	w2mdMT8CsPqXxe9x5T+8hMELeJn42VlTkBuGR9Q7AF0=	2026-09-09 13:57:24.212772+00	2026-09-03 09:44:29.41539+00	\N	2026-09-02 13:57:24.21295+00	2026-09-03 09:44:29.543595+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f6fcda68-26eb-4bf3-b5fd-495e6c0e5692	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	KxMzIQ4y79kvLWAurt8k+Ow+k/0wR5CRPLRp5ryCTaM=	2026-09-10 10:28:17.157841+00	2026-09-03 10:32:30.589557+00	\N	2026-09-03 10:28:17.158871+00	2026-09-03 10:32:30.591005+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
033cb4e3-c264-4cc2-bf43-dee39d7bac5f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qjWBkRT6wRsQW+4iQaWoW0OJMXX30hWYj8dkIuSJej4=	2026-09-10 10:32:30.590521+00	2026-09-03 12:21:24.0732+00	\N	2026-09-03 10:32:30.591005+00	2026-09-03 12:21:24.127734+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bb9f4570-2599-4a55-933b-f89813c97d6a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Sa8jgKLrGZno8O2GehGMUZPK+VR0Ki1qP1u/7ByZjEU=	2026-09-10 16:01:28.814055+00	\N	\N	2026-09-03 16:01:28.833921+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0bd7d133-2bd4-47e9-9e93-1fe4cd281431	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	Xlsx0FlZVdz9OBcRjxSKrIWScAxtwlsm2Ab82D2qQf8=	2026-09-03 07:22:24.629948+00	2026-08-27 07:27:38.414877+00	\N	2026-08-27 07:22:24.630092+00	2026-08-27 07:27:38.415356+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f5bea72c-b5f9-4576-9ead-eb24614c0eb7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	E0DCfm+yLPLT+ixS+VJPGPkRpBxcWoRIcP5D+dEFRdA=	2026-09-03 09:09:07.259612+00	2026-08-27 09:14:05.658587+00	\N	2026-08-27 09:09:07.259861+00	2026-08-27 09:14:05.663133+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
55339c8b-f2c1-4612-a43f-3074434536df	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ZPgHig8SWuuO8VaR6FsYsDU9U1EZvi8irZ1D6cNh070=	2026-09-03 10:56:36.351104+00	2026-08-27 10:57:12.306553+00	\N	2026-08-27 10:56:36.352999+00	2026-08-27 10:57:12.350807+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e8c7c8fe-3419-4e0a-9aef-acb1a595b919	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1tTPrHe7dkUzuWmaHdwNvxhv51Tz1cetjlbOvvX63zQ=	2026-09-04 05:22:28.619688+00	2026-08-28 05:30:19.64911+00	\N	2026-08-28 05:22:28.62054+00	2026-08-28 05:30:19.650362+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c48338e9-163d-4e0f-84bd-ee4c394cb3f2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	wg0Gf426uuHIjAbxtjb4OGtoMkvWIqMkT/VPqGjN2Qw=	2026-09-04 06:51:57.319014+00	2026-08-28 06:52:08.867231+00	\N	2026-08-28 06:51:57.319956+00	2026-08-28 06:52:08.867713+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d2571fb5-6ddc-4554-9234-a47c4ff3a798	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	44asUhAQhpHDo8Hjz44ymwsdXAAjN2r3Clwz6K+LiDc=	2026-09-04 08:55:08.256419+00	2026-08-28 09:38:50.977871+00	\N	2026-08-28 08:55:08.256684+00	2026-08-28 09:38:50.977888+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
322a7b52-1d24-4b34-9bd1-96af5788b9af	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	h6y2iYdCZwRDqYsd+qR3LVebBMYn7Q7IZdR8VBv/ZWk=	2026-09-07 05:35:32.702348+00	2026-08-31 06:05:40.211218+00	\N	2026-08-31 05:35:32.702453+00	2026-08-31 06:05:40.212014+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
966ffe59-dfbb-4e4e-bba8-9633162d8dfe	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	YJieiF5q1l6WmQ92fixEAMSPbf7bp5QrzMkppZQFBo0=	2026-09-07 05:35:21.289869+00	2026-08-31 09:32:24.60706+00	\N	2026-08-31 05:35:21.29072+00	2026-08-31 09:32:24.607651+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
885b6475-e464-43fb-b170-644f35e3fd21	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	6QExud3m92UkiX/veVVjK7Oo1Sk7/ZObI8cbzm8yyAc=	2026-09-07 10:01:06.542566+00	2026-08-31 10:29:00.393958+00	\N	2026-08-31 10:01:06.542859+00	2026-08-31 10:29:00.393968+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5fc20179-c786-47ed-b9ed-10c33de69b22	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	VtMtiScGPE7WSnFc6U7gTY6hM/YspX8sAamdgtmSxHU=	2026-09-09 05:28:34.916368+00	2026-09-02 05:35:22.71622+00	\N	2026-09-02 05:28:34.984923+00	2026-09-02 05:35:22.738233+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aca0fa8e-387a-4a25-a6ae-d359bc740a17	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DexdzaEHiEv8Yn80vQayR3usZQQKMiqW1IoteY5Xc00=	2026-09-09 07:37:15.447591+00	2026-09-02 07:40:46.319095+00	\N	2026-09-02 07:37:15.468688+00	2026-09-02 07:40:46.320723+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7a388c3f-2999-4e0e-bc8b-ec8fb87f0e4a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	l6z3z2pk71VsapcTYGHXjzADKofJ/vsE+v6wBoBBEZw=	2026-09-09 08:21:58.760039+00	2026-09-02 09:25:55.095599+00	\N	2026-09-02 08:21:58.77303+00	2026-09-02 09:25:55.095619+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
46086aff-1aad-404b-ab62-eb8709cec3a3	40517b71-5e62-182e-73b5-d4070e20a3c2	LNV4l4nbqbr7SjUL+LD1Hf53RXyVvOM2FvEFNa8Vmh4=	2026-09-09 10:01:37.943067+00	2026-09-02 10:01:38.120869+00	\N	2026-09-02 10:01:37.95922+00	2026-09-02 10:01:38.120889+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f1bf010e-819e-4d5f-be6c-19ee17b95b4e	40517b71-5e62-182e-73b5-d4070e20a3c2	CXQIMwgyGioOKEa91IzWyzjrz5iGqFqG1brGP++vAUA=	2026-09-09 10:02:20.001029+00	2026-09-02 10:07:54.358399+00	\N	2026-09-02 10:02:20.001244+00	2026-09-02 10:07:54.392892+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6c4a317a-99b3-44de-ac78-53b2f3d82025	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	UmW3IeaZRT5aa/Dit2nGsmpGDkw5Fo0l+6FUO74hvHk=	2026-09-09 10:01:39.020305+00	2026-09-02 10:14:52.929431+00	\N	2026-09-02 10:01:39.020573+00	2026-09-02 10:14:52.935734+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
22ccaf3c-35e7-4f03-bd19-c1ca1a559d7a	40517b71-5e62-182e-73b5-d4070e20a3c2	oxpPwiPgAApqFgZ9iRKXBaD56ihql7HAOuObJvZWBm8=	2026-09-09 10:30:52.420666+00	2026-09-02 10:30:53.282217+00	\N	2026-09-02 10:30:52.4296+00	2026-09-02 10:30:53.288642+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8b9e64e0-18af-46df-aad9-2be29227d887	40517b71-5e62-182e-73b5-d4070e20a3c2	Ot2cniKxfah71cyg5A5KM9kpM5pCn1PG6s9o5sYlUyo=	2026-09-09 10:30:53.287333+00	2026-09-02 10:30:54.210778+00	\N	2026-09-02 10:30:53.288642+00	2026-09-02 10:30:54.211183+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
46e28349-36c2-457c-8766-a5f2afb9490c	40517b71-5e62-182e-73b5-d4070e20a3c2	SqJAyCag2nSfUDBQOY7E+8kCum3FLX3JnDj4gA+MK/I=	2026-09-09 10:30:54.211023+00	2026-09-02 10:52:47.426214+00	\N	2026-09-02 10:30:54.211183+00	2026-09-02 10:52:47.529841+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3c59a617-da3f-4c36-aaa3-bf636ffda81b	40517b71-5e62-182e-73b5-d4070e20a3c2	IAshfp0phdKYAm2jUF5O0iwX1ZpGQixJyrBc61GZY8Q=	2026-09-09 11:39:45.669764+00	2026-09-02 12:00:31.646428+00	\N	2026-09-02 11:39:45.685206+00	2026-09-02 12:00:31.944697+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bcd58103-c8a1-417c-b8d2-b61cc3761ec3	40517b71-5e62-182e-73b5-d4070e20a3c2	/a4flpRoL+PgCi2JJJOww6SxKfrFwGtUtJI7CSI9tG0=	2026-09-09 12:10:19.498813+00	2026-09-02 12:13:41.436783+00	\N	2026-09-02 12:10:19.505092+00	2026-09-02 12:13:41.481125+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
52b39011-9da9-4402-b02c-2d6fdb54e41e	40517b71-5e62-182e-73b5-d4070e20a3c2	Eh2o/Ee+xuKRs7p2Uw0faq1+vWtHDL2HivJ/oVOYBa0=	2026-09-09 12:13:41.466406+00	2026-09-02 12:16:03.7896+00	\N	2026-09-02 12:13:41.481125+00	2026-09-02 12:16:03.793624+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1af12251-dd26-421a-8ddf-e52daa9b29b3	40517b71-5e62-182e-73b5-d4070e20a3c2	GGvwWo65eaCgXASvWzhO1C3QOk33xIwt1aZ9qSxtlDY=	2026-09-09 13:23:25.193333+00	2026-09-02 13:23:26.425622+00	\N	2026-09-02 13:23:25.208369+00	2026-09-02 13:23:26.429389+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b2618eea-4c55-4215-bedc-852f692cb8a5	40517b71-5e62-182e-73b5-d4070e20a3c2	J5KwLDKszjIgI0BN3Y8VdA/usV/YMJgh8pN0WnhOCeo=	2026-09-09 13:23:26.429037+00	2026-09-02 13:23:27.707703+00	\N	2026-09-02 13:23:26.429389+00	2026-09-02 13:23:27.735949+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
55ba1dee-40bb-4ee1-92e9-932dd63b8d67	40517b71-5e62-182e-73b5-d4070e20a3c2	DlL4j3oTKl7p36gQHSEm/dEdIDvr+UJAcrDmR38mu0M=	2026-09-09 13:23:27.735006+00	2026-09-02 13:23:46.185079+00	\N	2026-09-02 13:23:27.735949+00	2026-09-02 13:23:46.189011+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dbbced22-ef03-4bff-a323-f272bd7fdec7	40517b71-5e62-182e-73b5-d4070e20a3c2	W5lOKy4p6iovN0XCSW+ToxiPV9DEttQk/sgE7ejFrPw=	2026-09-09 13:23:46.186342+00	2026-09-02 13:24:57.332234+00	\N	2026-09-02 13:23:46.189011+00	2026-09-02 13:24:57.354314+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f31ca00e-1d46-4f39-b211-51061946a297	40517b71-5e62-182e-73b5-d4070e20a3c2	EVoCyklCCsVEw9pBEZgD0by5tgmo8E+97KVGe1whT4U=	2026-09-09 13:24:57.34488+00	2026-09-02 13:24:59.681396+00	\N	2026-09-02 13:24:57.354314+00	2026-09-02 13:24:59.68303+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
90d79c66-3312-4def-a99d-e5df868d930f	40517b71-5e62-182e-73b5-d4070e20a3c2	bFkGqcpWv8ngO7IFc+37RzJQq2aldPs901B9WQMB3K0=	2026-09-09 13:24:59.682362+00	2026-09-02 13:29:58.389457+00	\N	2026-09-02 13:24:59.68303+00	2026-09-02 13:29:58.416235+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0f7c01b3-2413-46d9-ab11-ea687bc73683	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ENnuDhNv/kH+gLMZJU0Uq9I7CzCbmXpFoPZ0gWMBdAM=	2026-09-10 06:20:14.808093+00	2026-09-03 06:21:09.544936+00	\N	2026-09-03 06:20:14.80837+00	2026-09-03 06:21:09.545512+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
31828d76-4451-4897-befd-fb444e4c3700	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	DGvpdgtA7iIMxxVnWd3EiZwpJPAInb9ML+LBIte2x0Q=	2026-09-10 07:05:30.064377+00	2026-09-03 07:05:48.858344+00	\N	2026-09-03 07:05:30.06462+00	2026-09-03 07:05:48.858354+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
84183030-e1c9-48d9-9201-32a9a5b14c49	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	AQcN/sHXaE62QWzMJmiD5WAQVcnNUMHmDjj6vY0emrA=	2026-09-10 09:35:27.473014+00	2026-09-03 09:48:55.409654+00	\N	2026-09-03 09:35:27.484094+00	2026-09-03 09:48:55.411529+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a80e38be-c376-4d4f-988c-21a4b804f427	d1130837-5c69-40b6-a65f-913214e66693	+8ddVI3RceWC2EPH1OaLV6gX6NEup87DccpSZxZNFRg=	2026-09-10 10:45:24.485067+00	2026-09-03 10:57:19.153557+00	\N	2026-09-03 10:45:24.499542+00	2026-09-03 10:57:19.165435+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6f3d3d09-2cab-4f28-8eab-afd0b71a435a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bGo7U5GJ7tlhOeQFZOzdXrQI+VkJuv1Y7QQIwKNZm3Y=	2026-09-03 09:14:06.816239+00	2026-08-27 09:19:30.286523+00	\N	2026-08-27 09:14:06.827533+00	2026-08-27 09:19:30.28731+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
78de3375-38f6-4f83-a8fc-5559873786ac	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	r2lbuu7ljIgjhZHztDrrTQkiE6NSek1ehTtCtIRq6SE=	2026-09-03 10:57:12.333517+00	2026-08-27 10:58:40.28358+00	\N	2026-08-27 10:57:12.350807+00	2026-08-27 10:58:40.284546+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5dc35640-cb4b-432c-bd42-9998c941faa6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	K/bi2+hMCmfYQQyrlZ0DSYtoib3hq5zy6UeBGhJLwx0=	2026-09-04 05:30:19.649604+00	2026-08-28 05:30:39.011568+00	\N	2026-08-28 05:30:19.650362+00	2026-08-28 05:30:39.012018+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e2c7326f-eec6-4a12-bbf2-d6451caaa445	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	W79nQb+vadZt9wRG6itypxfToMj59K6MhOm+DhjVPIg=	2026-09-04 07:12:58.467032+00	2026-08-28 07:43:19.026986+00	\N	2026-08-28 07:12:58.478787+00	2026-08-28 07:43:19.030445+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d68a15e8-7f6c-456d-a629-220c2df12b56	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Wvn9OCFRdXHnU8rb84HRDO6rsCeHrO+AUTlyvXudfJI=	2026-09-04 09:38:51.291988+00	2026-08-28 09:51:20.277387+00	\N	2026-08-28 09:38:51.292117+00	2026-08-28 09:51:20.278575+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b7ba6016-21a8-40dd-84e3-82bfc99e3c9c	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	UN7lO74zxbvnf+Sc0mf9Ki2sEZnk+Faj8YHutnbB1Qc=	2026-09-03 07:27:38.415134+00	2026-08-31 05:35:21.288861+00	\N	2026-08-27 07:27:38.415356+00	2026-08-31 05:35:21.29072+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9ae7901f-8349-47ce-8461-7c851ea7769b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	F4O4/xgAqlzMrXa6wGht/AewfYyfoAlvi5ZkIZZ5/w4=	2026-09-07 06:05:40.211723+00	2026-08-31 07:01:46.621113+00	\N	2026-08-31 06:05:40.212014+00	2026-08-31 07:01:46.62653+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e0d18736-0055-4e72-902f-e67703fdcd4c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	QGLVag8SjKqEV+BwymXT3hfUzskGIRWUk1QRD2vyTOs=	2026-09-07 10:29:00.712824+00	2026-08-31 10:29:04.795889+00	\N	2026-08-31 10:29:00.712976+00	2026-08-31 10:29:04.7959+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
75334c07-218e-4060-aeb2-1f8e7f7aaef9	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	fCGx728ccht7DLbkh/LsB3+DouWlpssgOfKBhPPnC+4=	2026-09-07 10:29:05.226701+00	2026-08-31 10:29:12.338522+00	\N	2026-08-31 10:29:05.226922+00	2026-08-31 10:29:12.338529+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
df73f7f1-25f3-4921-9120-9df141d1b825	730809c0-fc01-a664-03ca-28e0e32d0393	9YmrW2mtf79gMsW2ilZzvXqgrxWZ7y7m2FqzgF+T6Y4=	2026-09-07 10:29:12.647675+00	2026-08-31 10:29:16.050372+00	\N	2026-08-31 10:29:12.647889+00	2026-08-31 10:29:16.050382+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
533b25d4-999f-4d67-85e6-aef37275ca30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	iAeQFe3ZDKK5QOQ8AMp4UXWpgU2LUD1sLrLnFws8ZB0=	2026-09-09 05:35:22.731739+00	2026-09-02 05:35:56.54327+00	\N	2026-09-02 05:35:22.738233+00	2026-09-02 05:35:56.546663+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
077f15c2-ffb2-4acb-b1b5-c911d4198918	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NYUtC0sWBxXh/tPr2eTmfsqMRrbA6HzDgzJQX/NxfTs=	2026-09-09 07:40:46.319478+00	2026-09-02 07:43:00.540656+00	\N	2026-09-02 07:40:46.320723+00	2026-09-02 07:43:00.540694+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e93f7a69-590e-49af-a11b-992462158771	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	ZXuDqxiio4vPrJteBaX1AN71Q2L7VBrQ2xtkC7Vf6M0=	2026-09-09 08:59:31.137247+00	2026-09-02 09:44:34.063604+00	\N	2026-09-02 08:59:31.211234+00	2026-09-02 09:44:34.063924+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
51a82193-47d8-4553-a863-fad9a0c417f6	40517b71-5e62-182e-73b5-d4070e20a3c2	fPcjlBV8KhhKjtZkypIBAfy5EqAuV0YQm87cgKNnMnk=	2026-09-09 10:07:54.376474+00	2026-09-02 10:15:27.876398+00	\N	2026-09-02 10:07:54.392892+00	2026-09-02 10:15:27.938894+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1210565a-37f9-4aa6-b7c0-a75366ee0b72	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	SURt+AkNimxlxwX1l9X2PuSq04PbPH9T3fbCpQf5/Sk=	2026-09-09 10:45:47.396954+00	2026-09-02 10:45:51.034408+00	\N	2026-09-02 10:45:47.444337+00	2026-09-02 10:45:51.034464+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
39af460d-7230-4210-8dff-cd1c93fc7a46	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xDM302OVBuvpQOsTrx649oWuciwAQi57/1SrtfL96CU=	2026-09-09 11:45:19.938539+00	2026-09-02 11:49:31.746767+00	\N	2026-09-02 11:45:19.941321+00	2026-09-02 11:49:31.84696+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e5d4dfcc-11ed-4f4a-a0c6-de7b6f08f7bc	40517b71-5e62-182e-73b5-d4070e20a3c2	AlYKlpDrv/8PYeSSs6ME/GKpoHrue0itun3gBejOJu0=	2026-09-09 12:16:03.792682+00	2026-09-02 12:17:37.994179+00	\N	2026-09-02 12:16:03.793624+00	2026-09-02 12:17:37.998744+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fb59f8ee-3c20-40f5-9819-7a34753bb729	40517b71-5e62-182e-73b5-d4070e20a3c2	0SKMA0Bex4cRIMrV+DXn1JRJO4SUjTN/rA7pYfMgKQQ=	2026-09-09 12:17:37.995303+00	2026-09-02 12:20:21.854026+00	\N	2026-09-02 12:17:37.998744+00	2026-09-02 12:20:21.86872+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
acad381f-9b61-48f0-8910-7be58c46b25d	40517b71-5e62-182e-73b5-d4070e20a3c2	ZvjM9cVFV5xa1pttbBO5rNyrG/Mw0ADRx4CuTbVTdvA=	2026-09-09 12:20:21.85951+00	2026-09-02 12:20:29.156277+00	\N	2026-09-02 12:20:21.86872+00	2026-09-02 12:20:29.157083+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
17f8e457-8de3-43bf-861f-80d8fba8ff34	40517b71-5e62-182e-73b5-d4070e20a3c2	JTgpzyYylLMo5J1RM/VCrXD+CSSqun4xp/0RIWl1ICM=	2026-09-09 12:20:29.15685+00	2026-09-02 12:20:29.578512+00	\N	2026-09-02 12:20:29.157083+00	2026-09-02 12:20:29.579257+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5ec45c87-7ddb-455f-9a55-cf77cb6b736f	40517b71-5e62-182e-73b5-d4070e20a3c2	d++bzL3/hF7cipbxVwVCA7Nwf7nQWJ0ZBpb9KiS7T6M=	2026-09-09 12:20:29.57897+00	2026-09-02 12:20:49.747596+00	\N	2026-09-02 12:20:29.579257+00	2026-09-02 12:20:49.750209+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bc2113a8-9626-4696-9b58-e02e3d78b51c	40517b71-5e62-182e-73b5-d4070e20a3c2	5B3AsEq1u422HiXC/oNfp5NJtuvS1Soaz6KHGptotcg=	2026-09-09 12:20:49.747984+00	2026-09-02 12:42:43.47038+00	\N	2026-09-02 12:20:49.750209+00	2026-09-02 12:42:43.535134+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6c53f20a-1e1f-4f56-803a-955c719392e4	40517b71-5e62-182e-73b5-d4070e20a3c2	AHuiXAysM1EARa1SmCeaVetcGA+37Rlar4j63eyL+/A=	2026-09-09 13:29:58.412663+00	2026-09-02 13:30:00.748704+00	\N	2026-09-02 13:29:58.416235+00	2026-09-02 13:30:00.749379+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
149040b0-6a2b-4266-b9a7-9e407e6d3967	40517b71-5e62-182e-73b5-d4070e20a3c2	OL0SDynjoUoMjNlO1OEo0sMD9Ky8hzV4DwEJtXQ/saw=	2026-09-09 13:30:00.749227+00	2026-09-02 13:33:18.227545+00	\N	2026-09-02 13:30:00.749379+00	2026-09-02 13:33:18.302929+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bc7f4f74-eab5-4018-b36d-c67502e15070	40517b71-5e62-182e-73b5-d4070e20a3c2	2tX2NpjpQ6X5Xf2kOab3x79PwvnXQ5lCgGjJfvSW+kk=	2026-09-09 13:33:18.268875+00	2026-09-02 13:33:22.789757+00	\N	2026-09-02 13:33:18.302929+00	2026-09-02 13:33:22.791264+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0cb815d2-7f9f-496c-84a0-fa8c553e19d5	40517b71-5e62-182e-73b5-d4070e20a3c2	6PdMYnqiqDy9nxxMH0RlOpikh4k0DNhyCMbCHgvESY4=	2026-09-09 13:33:22.791012+00	2026-09-02 13:36:26.332245+00	\N	2026-09-02 13:33:22.791264+00	2026-09-02 13:36:26.357252+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
358b3629-a237-4000-a1df-c8f6f8131b79	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4v7yEgB/cK4VZHRmrVLAwC4pNE27S8CAztBmPU/0MhY=	2026-09-10 06:21:09.545341+00	2026-09-03 06:21:16.971437+00	\N	2026-09-03 06:21:09.545512+00	2026-09-03 06:21:16.971443+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
21a36107-a505-4e84-950e-ce094250d877	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	oAQGnqkNPiijD8gBNMQyufKfxfrLd453GsTUxpN0Pxg=	2026-09-10 07:07:42.666476+00	2026-09-03 08:20:38.016904+00	\N	2026-09-03 07:07:42.666646+00	2026-09-03 08:20:38.017994+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
16ed4637-f162-4154-a604-379e6dad2df7	cdee998d-48e3-4ee3-8d3a-8bb394592377	As6Z/viLSDkMuZ6JHs2N9LM+7M8QhrSbPyzWYRKsR6k=	2026-09-10 09:44:29.492441+00	2026-09-03 09:47:53.090619+00	\N	2026-09-03 09:44:29.543595+00	2026-09-03 09:47:53.094768+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0077aded-c60a-4cf0-acec-d807efc1e934	cdee998d-48e3-4ee3-8d3a-8bb394592377	4DMId3li7yTO1/+H+TGcKYYjil4c/BYXEIi9hyAWiMU=	2026-09-10 09:47:53.092551+00	\N	\N	2026-09-03 09:47:53.094768+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bc38b6ff-6f31-475a-a7e5-bd0da875bdb3	d1130837-5c69-40b6-a65f-913214e66693	dzOxp2waUkRQzVPYVOgOfrhEyf51A3HMZ1osL0REZRM=	2026-09-10 09:47:54.619559+00	2026-09-03 09:47:54.947257+00	\N	2026-09-03 09:47:54.620128+00	2026-09-03 09:47:54.94842+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4a7ecc86-96fb-4749-a904-c9efb634dff3	d1130837-5c69-40b6-a65f-913214e66693	0uIvEAHPYyN5v4dO93u8FkBlCIVqx10L8l4dWqQWZD8=	2026-09-10 09:47:54.947948+00	2026-09-03 09:48:21.26616+00	\N	2026-09-03 09:47:54.94842+00	2026-09-03 09:48:21.266914+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2552e9e1-1a47-4640-bd76-4caffc43f8aa	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	QbJJh3YNUbmLTTCe69Qkrn5+sWeW7IGwVAAqSxu3Ed0=	2026-09-10 09:48:23.156137+00	2026-09-03 09:48:25.952149+00	\N	2026-09-03 09:48:23.156603+00	2026-09-03 09:48:25.95227+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cb650607-8f31-4eda-a8e9-28fe88f00776	d1130837-5c69-40b6-a65f-913214e66693	G+jNQyvNICSYOAeVFlLeEw46FhSGLbiMdEEtxOMi91c=	2026-09-10 10:57:19.156759+00	2026-09-03 12:15:37.125891+00	\N	2026-09-03 10:57:19.165435+00	2026-09-03 12:15:37.160855+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8e9adeb5-d1ae-47ef-9f82-49b426e5e7ab	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	wqnk0bhajNGKkyHjP1cPIkBYrcEkEZu4FxvfqQ35B7g=	2026-09-03 07:35:41.619865+00	2026-08-27 07:43:11.902217+00	\N	2026-08-27 07:35:41.620052+00	2026-08-27 07:43:12.164255+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
94c8e12d-6302-4728-848f-52581805a1be	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ezw8vsP8akGCxJrcj6Qq1ioDqup5+6PZe5HWLkO9RRM=	2026-09-03 09:19:30.28712+00	2026-08-27 09:29:04.419737+00	\N	2026-08-27 09:19:30.28731+00	2026-08-27 09:29:04.426432+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
59e7ccdb-8be4-474b-8aa3-ca0c5c24f103	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	RmbE5m6IItB+QyHhv2oVriXq0xGyFrP0a0EYsQWQkZo=	2026-09-03 10:58:40.283851+00	2026-08-27 11:32:04.568694+00	\N	2026-08-27 10:58:40.284546+00	2026-08-27 11:32:04.570177+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
73a55ac3-3140-4bbb-b683-a6ae38524565	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ntQLi7Yj+LhkaoDUZRhHqtQvXGHEph4mM5AhgREIQno=	2026-09-04 05:30:39.011845+00	2026-08-28 05:33:20.283673+00	\N	2026-08-28 05:30:39.012018+00	2026-08-28 05:33:20.284096+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
99d2b41e-e2fa-4872-9b52-21545b9ea9f4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NUz0PK+i37yyAgOXDpl36MRytdIw16kaWiVMfF04nyE=	2026-09-04 05:35:47.729533+00	2026-08-28 05:47:14.51273+00	\N	2026-08-28 05:35:47.729841+00	2026-08-28 05:47:14.513321+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5ec779b9-3831-4727-8fc4-198db6e917f2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	szac1wtsWZzwRVTaugiLbuaQVb5PmhqYDA7BuKZ03Ps=	2026-09-04 07:43:19.028091+00	2026-08-28 08:18:40.927873+00	\N	2026-08-28 07:43:19.030445+00	2026-08-28 08:18:40.928494+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9f3a539e-2a8a-4c05-b1b7-8f2c8ffef8df	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	t1NcNIIp+IH4OlTq4R3jHwaNt8ZECnuClhvETgTK1nA=	2026-09-04 09:51:20.278294+00	2026-08-28 09:52:56.63126+00	\N	2026-08-28 09:51:20.278575+00	2026-08-28 09:52:56.631976+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
70da64f4-150c-4145-97a8-e2cc4d5398ad	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	p3j0QeMzbVdnqqlSTGGBbzZDGiT9W6JHE8ISMPYKi9c=	2026-09-07 07:01:46.624318+00	2026-08-31 07:27:15.834663+00	\N	2026-08-31 07:01:46.62653+00	2026-08-31 07:27:15.83482+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
47a013ba-de8c-4ccf-a966-3a5ebf1dcf8c	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	XILOCs5ujpCcizG7Hq89VRdFbger+bS39p0M9KzvhJU=	2026-09-07 10:29:16.375344+00	2026-08-31 10:29:19.094676+00	\N	2026-08-31 10:29:16.375508+00	2026-08-31 10:29:19.095044+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
11e957c8-8ced-44af-9f89-bbd3a3011368	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	1594kAB91tNVMAcYI5FGBWlm2wn6MlK6RLISttX7UqY=	2026-09-07 10:29:19.82074+00	2026-08-31 10:29:21.90698+00	\N	2026-08-31 10:29:19.820834+00	2026-08-31 10:29:21.907382+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
83f5c449-1b52-43f7-8972-fcfeb41e233d	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	kkv3KD0NWNncVBnKuhKGamYW1CFs9Xne9rp9zfxSoyg=	2026-09-07 10:29:22.538409+00	2026-08-31 10:29:32.738639+00	\N	2026-08-31 10:29:22.538495+00	2026-08-31 10:29:32.738648+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b6b91255-db4e-48cf-8438-389c1df0afe3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Dij0RD5OLQaa449RDR5bCXgmhaHbkMWYygEOs7OOhwU=	2026-09-09 05:35:56.545036+00	2026-09-02 06:10:32.852522+00	\N	2026-09-02 05:35:56.546663+00	2026-09-02 06:10:32.908769+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
41b14182-8c4b-42e4-af18-9a5dd4949f10	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	q6Jzro5GxZuxjv/GjhORE+xsblTq96Mfl8AMRQ8QZV8=	2026-09-09 07:43:01.763749+00	2026-09-02 07:46:36.197536+00	\N	2026-09-02 07:43:01.764431+00	2026-09-02 07:46:36.275279+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7c6be6b7-175d-4cc5-8122-536609a307c2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1nRcAbnOFB8Q58jIkMxa4QFgHq/8RxxwZqgnRkBVBtg=	2026-09-09 09:25:55.375472+00	2026-09-02 09:49:34.560778+00	\N	2026-09-02 09:25:55.37564+00	2026-09-02 09:49:34.561056+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a0a3b4c0-c181-4a99-aa08-3df38676a549	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	ebfHoygbl6Ng2PHKeq+vLDyHUV5IXe70KJ1bQiQ8mNk=	2026-09-09 10:14:55.970593+00	2026-09-02 10:45:47.300685+00	\N	2026-09-02 10:14:56.244659+00	2026-09-02 10:45:47.444337+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8d96c935-ae2a-494b-b3eb-2fb4c04d23e6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5XFFEqpwWqa3fp7+9poF2kB1aYsnOkCaKUYL3D+tZj8=	2026-09-09 10:45:52.191104+00	2026-09-02 11:15:37.564409+00	\N	2026-09-02 10:45:52.191646+00	2026-09-02 11:15:37.564517+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1c0fe046-b8b6-4fae-b88a-692a4109d294	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GfuUshaeGZXWgLkjo9L+KlzjXobBjAL9KQ8d3pDFcRI=	2026-09-09 11:49:31.835741+00	2026-09-02 11:56:02.501293+00	\N	2026-09-02 11:49:31.84696+00	2026-09-02 11:56:03.0456+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b2bde5cb-3ba4-465d-98f7-bd72c691d8b8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	oiIB5lARhyshNwUczHBp2eVQQ8aQupWENICsDAm9h44=	2026-09-09 12:35:46.769179+00	2026-09-02 13:06:29.651126+00	\N	2026-09-02 12:35:46.779707+00	2026-09-02 13:06:29.651271+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cfc12a3b-3793-4a7c-b693-b09bcab13189	40517b71-5e62-182e-73b5-d4070e20a3c2	RvqFiwFKx19DrQzrJ0fd8kL9GOZpz6TpboNy9fOhrjU=	2026-09-09 13:36:26.348709+00	2026-09-02 13:36:27.829078+00	\N	2026-09-02 13:36:26.357252+00	2026-09-02 13:36:27.856532+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a74f7c33-43f1-460e-b7ac-a2958c6109ad	40517b71-5e62-182e-73b5-d4070e20a3c2	r44kNcCh7UwHerUVdJRRUL91ISC9GsMMqnns6012VPI=	2026-09-09 13:36:27.82951+00	\N	\N	2026-09-02 13:36:27.856532+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5bd8302e-1f5d-4749-8830-518465b4fa33	6d1e9837-0276-46b5-a0f8-596f155139c8	Dd+PTER77lQufV0gGPN3q9jIcAYaMjWxWNSYv/M6CeE=	2026-09-09 13:36:35.909254+00	2026-09-02 13:36:36.009255+00	\N	2026-09-02 13:36:35.909423+00	2026-09-02 13:36:36.010691+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
72995fab-5268-49bb-ae57-c460584b38ae	6d1e9837-0276-46b5-a0f8-596f155139c8	ioNLZRMor0Bobsw3ccdghYlaPCs8uWdlilbkPVWg16w=	2026-09-09 13:36:36.010471+00	2026-09-02 13:36:45.286905+00	\N	2026-09-02 13:36:36.010691+00	2026-09-02 13:36:45.286946+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
57a43198-32d5-4e76-8880-33238bd52635	6d1e9837-0276-46b5-a0f8-596f155139c8	v7kpyw3vVN2zz1zVB/8mwiclRTl7ENM1ydzEAgtHtps=	2026-09-09 13:36:47.739173+00	2026-09-02 13:36:47.838739+00	\N	2026-09-02 13:36:47.739452+00	2026-09-02 13:36:47.839053+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0770a677-ada4-44a9-a652-437cc3f02109	6d1e9837-0276-46b5-a0f8-596f155139c8	XVxdqDAkPuwraHuCdgswGn+TrItVKEHF2Cx/GF9Kjj8=	2026-09-09 13:36:47.838909+00	2026-09-02 13:36:58.742162+00	\N	2026-09-02 13:36:47.839053+00	2026-09-02 13:36:58.742185+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
32be4e44-6388-4d62-9f4f-3413e4c07a27	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	gvR94wi8IJj6liXwo5D92b2k7fTLN2cWhqCoqCKLijQ=	2026-09-09 13:36:59.565276+00	2026-09-02 13:37:46.00509+00	\N	2026-09-02 13:36:59.565409+00	2026-09-02 13:37:46.006371+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e786f879-1a37-4750-a470-d4a3ea8c2a44	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NlY2zUPV72wqAXSO7KNpBYDRk7FlpfhncWZfW3XlbI8=	2026-09-10 06:21:17.277314+00	2026-09-03 07:05:07.695246+00	\N	2026-09-03 06:21:17.27749+00	2026-09-03 07:05:07.695394+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0aead5f4-4b79-47c1-a7c9-06695764d5ef	730809c0-fc01-a664-03ca-28e0e32d0393	c5bi3Nuh8T/Nh6BOwO0y5Q9DMZoZPdWjFhYlzNEjUIg=	2026-09-09 13:36:46.156799+00	2026-09-03 07:05:08.050328+00	\N	2026-09-02 13:36:46.157013+00	2026-09-03 07:05:08.060298+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a47f5139-18ab-4903-b875-61ed13968347	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	VLfDd51YwwbG6dfzBJ0vsxcTtme4MT4+E2n3e6uPcws=	2026-09-10 08:20:38.017815+00	2026-09-03 08:34:56.390434+00	\N	2026-09-03 08:20:38.017994+00	2026-09-03 08:34:56.39086+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dd7c0cb7-48c3-451d-bbfe-7615e8d39959	730809c0-fc01-a664-03ca-28e0e32d0393	hHg6pqt6V6lCyV+WJTnIZjQBIwe2myX191f3RAx5esI=	2026-09-10 09:48:26.860207+00	\N	\N	2026-09-03 09:48:26.860557+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
abf17936-f234-4970-8ae4-585158a497de	d1130837-5c69-40b6-a65f-913214e66693	W8O44KFQhFvdJDcIjH5H0LmC+PyQcJydoNpMVwhU/DY=	2026-09-10 09:50:09.76601+00	2026-09-03 10:04:59.210444+00	\N	2026-09-03 09:50:09.766267+00	2026-09-03 10:04:59.211326+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aa76c5d3-5b3d-4cbb-809b-812c0ca228d4	d1130837-5c69-40b6-a65f-913214e66693	+qcDNmo+XqyYf7d+8+gDxqLVgucv9KrNDpfgqHr7iNM=	2026-09-10 12:15:37.148674+00	2026-09-03 12:47:17.649041+00	\N	2026-09-03 12:15:37.160855+00	2026-09-03 12:47:17.674368+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
86aee622-7e5a-4e2f-ab96-746463037cdc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	WCgsBqnK2mdrjRTxQR4z5oHfHlxbo3o5bvQy6gu048U=	2026-09-03 07:43:12.086046+00	2026-08-27 07:44:53.607691+00	\N	2026-08-27 07:43:12.164255+00	2026-08-27 07:44:53.608841+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1956dcb2-18fc-4c8c-b2d0-a1323b3e4a43	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uDYIdIy8qoJSDmKxpBrnvz6TCEhUWTtHUZvdEye1gQg=	2026-09-03 09:29:08.377612+00	2026-08-27 09:31:52.830494+00	\N	2026-08-27 09:29:08.42017+00	2026-08-27 09:31:52.831093+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
38f26e6e-abe0-43b0-8905-9962469e8382	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	i8pfwxe6cnH8BW2bKQ5M0BWIW0KQTTnc/I/OAHb6YDA=	2026-09-03 11:32:04.569656+00	2026-08-27 11:34:41.710745+00	\N	2026-08-27 11:32:04.570177+00	2026-08-27 11:34:41.711187+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3cb9e2a3-85f9-47f5-a2aa-01b5fda53925	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Ny6HS4brIJ38Ppa2+KLIF7F/EMsz5ciFTdK0lP8wu4Y=	2026-09-04 05:33:20.284001+00	2026-08-28 05:35:47.728739+00	\N	2026-08-28 05:33:20.284096+00	2026-08-28 05:35:47.729841+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
823788d7-35bb-4773-91e4-6b3b58b7cde5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	l4V6gbU1uMtIEkqqh8FyvQfgeJvTKmK2UMm0hVkjjPI=	2026-09-04 08:18:41.293211+00	2026-08-28 08:19:31.952164+00	\N	2026-08-28 08:18:41.294352+00	2026-08-28 08:19:31.953896+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
50857345-7dfe-4af0-beb1-69c697fed818	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	gtnegXKgPo9IavUBiEg29wGAdzSf5WzCtmB3fSixnDY=	2026-09-04 08:19:31.953384+00	2026-08-28 08:23:57.818858+00	\N	2026-08-28 08:19:31.953896+00	2026-08-28 08:23:57.819456+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d1f1a1cc-8097-4230-8074-19a3db8065c1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GLseKG9lELvWCAL2GaBLbU0nbllfdPjY7FXbD2Ku660=	2026-09-04 09:52:56.631755+00	2026-08-31 04:55:23.101318+00	\N	2026-08-28 09:52:56.631976+00	2026-08-31 04:55:23.139609+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c140974e-cb81-4b2e-b18e-03ffc696b833	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	cTHi7t4W7oFoMekuMrrN+iPOEB9xXLcBdUkigYszz1E=	2026-09-07 07:27:16.156641+00	2026-08-31 07:42:00.577659+00	\N	2026-08-31 07:27:16.157291+00	2026-08-31 07:42:00.578276+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7689ac89-765c-432d-8e3a-6694aafb82d3	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	Qv5lBtwoU8coYETXRx7E12ctlT4pQReG5QNOFnmv9Jo=	2026-09-07 10:29:19.094942+00	2026-08-31 10:29:19.820284+00	\N	2026-08-31 10:29:19.095044+00	2026-08-31 10:29:19.820834+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
477012d5-01f4-4c58-88db-e2de2c452c42	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	SxNeCcfoHndUIOHyVYnrXHVFoxwV0oEKUTbWNBrrqXI=	2026-09-07 10:29:21.907296+00	2026-08-31 10:29:22.538145+00	\N	2026-08-31 10:29:21.907382+00	2026-08-31 10:29:22.538495+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e03f6247-7e30-4f51-8b5f-2ebd3aef3bf5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Ic26wVniszdmL3kLUkz+FRudjmes2GOyDmVSJKHkk4E=	2026-09-09 06:10:32.890397+00	2026-09-02 06:32:54.377212+00	\N	2026-09-02 06:10:32.908769+00	2026-09-02 06:32:54.428552+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1d671865-88c0-462d-a4a8-8fae027d763b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	6mNgwGmO75OI8EkpakuoYAqZLMJHeFB7xHhyyM5SwCo=	2026-09-09 07:46:36.236748+00	2026-09-02 07:46:50.029784+00	\N	2026-09-02 07:46:36.275279+00	2026-09-02 07:46:50.034704+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f4c49c41-f7cb-43f3-b5c2-d393ce09e45a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	IFFtldlhd2ccw/iBjdfe/o7hUjf9mrk7ODDkldnXMFs=	2026-09-09 07:46:50.033167+00	2026-09-02 07:47:49.06395+00	\N	2026-09-02 07:46:50.034704+00	2026-09-02 07:47:49.069297+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5bd20322-01fa-4bca-8e68-6e6ef0049ece	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	y7rwkAnMR8exMBTNM70pfkS6qgUMUms7GGWf5JurU5U=	2026-09-09 07:47:49.069042+00	2026-09-02 07:48:02.611006+00	\N	2026-09-02 07:47:49.069297+00	2026-09-02 07:48:02.61363+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
199ac41d-520c-48b0-b53c-76b29e51ec37	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sHZufZ3NQ7uVM9ISGVfoJhjLl4va9sQeIkGZZSVtNoU=	2026-09-09 07:48:02.612449+00	2026-09-02 07:50:08.888734+00	\N	2026-09-02 07:48:02.61363+00	2026-09-02 07:50:08.888815+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
34970c72-ff1a-4163-9bc2-8b126f66b9ce	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	BsRdDeT/EUhMptqgUy3+VV6qaV+d8b1T2YnBRatSRbo=	2026-09-09 09:44:34.063754+00	2026-09-02 09:49:32.682882+00	\N	2026-09-02 09:44:34.063924+00	2026-09-02 09:49:32.683272+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
78a52177-81ea-4341-84d0-24febfbc96d6	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	sC4rxwZucE+Z1AXF/IcjRRIdQFzDZkYncVC4I24WB6w=	2026-09-09 09:49:32.683089+00	2026-09-02 09:56:21.807007+00	\N	2026-09-02 09:49:32.683272+00	2026-09-02 09:56:21.810777+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a96c6ffc-9c37-4272-8183-746b96b1607b	40517b71-5e62-182e-73b5-d4070e20a3c2	3jSoXeY6kaTIFJqSPJs8oO04NTN3Cy/UAx6aWlObRxA=	2026-09-09 10:15:27.923077+00	2026-09-02 10:30:43.38121+00	\N	2026-09-02 10:15:27.938895+00	2026-09-02 10:30:43.457442+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8216693e-f3c1-4404-8361-ef6645e0e77f	40517b71-5e62-182e-73b5-d4070e20a3c2	VR4KHxgI0S6umlMo06ei4raBJN5EzK03gVALgi6RXhQ=	2026-09-09 10:52:47.495353+00	2026-09-02 10:52:48.384206+00	\N	2026-09-02 10:52:47.529841+00	2026-09-02 10:52:48.392196+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
177c339a-9779-409c-8b6a-50754826b9a4	40517b71-5e62-182e-73b5-d4070e20a3c2	PbviUJTSXChBRJQyo8xfkRcFaLTrrciyerMYY+u9MHk=	2026-09-09 10:52:48.388679+00	2026-09-02 11:17:55.172808+00	\N	2026-09-02 10:52:48.392196+00	2026-09-02 11:17:55.214203+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
58de73a0-2677-4247-9ea1-09caa53bc603	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	OT+zwsjUcFa1jqvZ1sWpj6bBURqZKJwOGedYUNCV7vg=	2026-09-09 11:56:02.956566+00	2026-09-02 11:56:24.142588+00	\N	2026-09-02 11:56:03.0456+00	2026-09-02 11:56:24.143514+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1e73417b-a28d-4459-819b-e38a26c2bb4f	40517b71-5e62-182e-73b5-d4070e20a3c2	QU4QnuEDaTx55R+Qsx5L1uA5UUQA8nt0s4uoJaoImxU=	2026-09-09 12:42:43.499277+00	2026-09-02 12:52:17.002807+00	\N	2026-09-02 12:42:43.535134+00	2026-09-02 12:52:17.027859+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
72922b75-7e0e-4041-94e7-37e6935853de	6d1e9837-0276-46b5-a0f8-596f155139c8	rKXDa8+xlfRTGfObL4eJv+VGa5oz9W0gCec9mnVdyhA=	2026-09-09 13:37:46.282015+00	2026-09-02 13:37:46.378927+00	\N	2026-09-02 13:37:46.282186+00	2026-09-02 13:37:46.379611+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d15ddd7f-5041-48b2-890f-19f5af06a727	6d1e9837-0276-46b5-a0f8-596f155139c8	IGa6RA06nMwvqyALc1wTNFNlinfestTyrKlG0Zk5GmM=	2026-09-09 13:37:46.379459+00	2026-09-02 13:38:46.324476+00	\N	2026-09-02 13:37:46.379611+00	2026-09-02 13:38:46.340399+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5a8539c9-7cc6-4985-9f64-53e2c99020b5	6d1e9837-0276-46b5-a0f8-596f155139c8	KZVhYVePVbKtx77UV2ZQ1aKmuUPAoyyCWm36TcCmiNs=	2026-09-09 13:38:46.336148+00	2026-09-02 13:41:59.941329+00	\N	2026-09-02 13:38:46.340399+00	2026-09-02 13:41:59.961629+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e89cbca0-0374-4233-9ca9-23ce1f31854a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	80hvtZBqRZSJQE6/dklWCdc8x8twuJUhoKQR6h4ip08=	2026-09-09 13:37:46.005782+00	2026-09-02 13:46:24.576329+00	\N	2026-09-02 13:37:46.006371+00	2026-09-02 13:46:24.576337+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
432ff8af-387d-4f4f-ab0e-52c249d62fea	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	B8zPhAgMnixc/8c39sELXd+/tbjwES6BeuCPgLx8FG0=	2026-09-10 06:26:07.572455+00	2026-09-03 06:44:36.513767+00	\N	2026-09-03 06:26:07.587158+00	2026-09-03 06:44:36.515377+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
50575b90-c7a8-4e71-9c2a-3fd27b40b03b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fLZqPmXgl2AVCbh00rB8tePQR+E962WC+p8F4MneGnk=	2026-09-10 08:34:56.874542+00	2026-09-03 08:35:53.535513+00	\N	2026-09-03 08:34:56.876716+00	2026-09-03 08:35:53.53684+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8979dab4-3d67-45b7-a2c2-47f37e1a6845	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	4GNPiLlY7Y6Zfos+2B2FUzt6QKhRIpTCRoRxMWdqIqY=	2026-09-10 09:48:55.410245+00	2026-09-03 10:23:14.416761+00	\N	2026-09-03 09:48:55.411529+00	2026-09-03 10:23:14.467335+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bac2542b-0273-41dc-8697-0fe9f6a62ff4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	48BehxUt2+lTnD+GG6HJ5r0x52W6/HOXMqhXfoubqn8=	2026-09-10 12:21:24.104905+00	2026-09-03 12:33:58.991444+00	\N	2026-09-03 12:21:24.127734+00	2026-09-03 12:33:59.044924+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
32571172-45d1-43e0-bec7-3ae52045f4c2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	aXxy5EC/fQsaoYV3vLqheVWEC+FLBUk0CUyuz6XmZ8I=	2026-09-03 07:44:53.60862+00	2026-08-27 08:07:17.966497+00	\N	2026-08-27 07:44:53.608841+00	2026-08-27 08:07:17.96654+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9624c1e4-5dc2-4d3a-a286-3d9c92d830c8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5a28IE0/ZQUt1hMSpw4W5TZDYA681RSqn0k//+a196I=	2026-09-03 09:31:52.830905+00	2026-08-27 09:34:18.706732+00	\N	2026-08-27 09:31:52.831093+00	2026-08-27 09:34:18.70674+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ad507b76-b36f-4c4a-ae97-c376300b6245	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	o6R4UU3y7xmWzB/Qgj2aWRoAzXhFZw+WHn4U9GSwLlk=	2026-09-03 09:34:40.574367+00	2026-08-27 09:34:52.039882+00	\N	2026-08-27 09:34:40.574464+00	2026-08-27 09:34:52.040153+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6cb803fa-2cf4-42d7-b7e5-8143db6c12fa	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SxGtEceUaEQw80CMsZ+dqVFKQa/M0/b5N9BvOhunhik=	2026-09-03 09:34:52.040069+00	2026-08-27 09:54:03.646777+00	\N	2026-08-27 09:34:52.040153+00	2026-08-27 09:54:03.647812+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a6a05f7d-f362-4e36-ae1d-e487294e7767	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9SJcepTY381AzHLhMMr34+4CmA1U9cZGmuomlbQLLA4=	2026-09-03 11:34:41.711071+00	2026-08-27 12:25:07.786954+00	\N	2026-08-27 11:34:41.711187+00	2026-08-27 12:25:07.78848+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
180e19a7-3ea1-4aa0-9579-33de98b1d5c0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	En00hMNy21Zj53F58BdUPif3Xc0ZRP9cm0DBhgoYFyU=	2026-09-04 05:47:14.513145+00	2026-08-28 05:48:25.035181+00	\N	2026-08-28 05:47:14.513321+00	2026-08-28 05:48:25.03673+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b06484c6-987c-437e-ba2a-3783c9d932fd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vfXRE96821tDbz4prsNe1GAjeCmWno1YS4vB7Zp9Ins=	2026-09-04 08:23:57.819257+00	2026-08-28 08:29:21.714989+00	\N	2026-08-28 08:23:57.819456+00	2026-08-28 08:29:21.716197+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aa5ee420-c150-4e66-bcfe-d6d8d25c0950	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	seQnOECgwZ5i6y7yD100Kb1RsbFgjeDcU7qyb8pppy4=	2026-09-07 07:42:00.578049+00	2026-08-31 09:30:54.996945+00	\N	2026-08-31 07:42:00.578276+00	2026-08-31 09:30:54.997156+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
daeaea6a-333b-41ee-aaed-815137891b46	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	nI3b1+F1Wwf6Y6LlnOLbF/B9HP3MvhxXTLQVxBj5ZL0=	2026-09-07 10:29:33.063822+00	2026-09-01 05:45:23.768481+00	\N	2026-08-31 10:29:33.063968+00	2026-09-01 05:45:23.799067+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
14ebf114-6948-404d-9c14-4393c6b043ed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	BBckG3Qy0CMnhTo2t+XdyONm8yobMGOmVdA+fhgpHJc=	2026-09-09 06:32:54.412294+00	2026-09-02 07:01:19.330416+00	\N	2026-09-02 06:32:54.428552+00	2026-09-02 07:01:19.359519+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
27bfcd70-08f8-4eaf-9d48-db3f7b01f210	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	46KTq030Q6vPqmlclYEjri/Az+UCopVVDrYA4zUVyKY=	2026-09-09 07:50:09.970945+00	2026-09-02 08:05:00.842748+00	\N	2026-09-02 07:50:09.97119+00	2026-09-02 08:05:00.861096+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b72dfed2-286a-4f7f-92c4-06cd484da157	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	dBh+7i07iODIRQFAHklDxMCVnO4qexUKQMaH6NiC9R0=	2026-09-09 09:49:34.560973+00	2026-09-02 09:53:31.890632+00	\N	2026-09-02 09:49:34.561056+00	2026-09-02 09:53:31.893986+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c1747cda-156c-4ab9-99a9-900c664c7e3b	40517b71-5e62-182e-73b5-d4070e20a3c2	PYw1XwkzN5Eop1e42di6HUxSyQ/kmrN6XmbaS+WZIJU=	2026-09-09 10:15:27.936914+00	\N	\N	2026-09-02 10:15:27.938894+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
330c7d48-3820-4677-9dc5-3d88d3395acb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	MMHhJICGsqxLhUlMgHY34QoYmJHlNTUSU7LQgxC/HeY=	2026-09-09 11:15:38.051813+00	2026-09-02 11:45:19.915275+00	\N	2026-09-02 11:15:38.053468+00	2026-09-02 11:45:19.941321+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0f671b69-f6c9-4ab6-8d1f-bc15bcc785c9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TbrNfUPxM2vVvgKy8tYl5aljpI5xagQWojWh5Y9X9Uk=	2026-09-09 11:56:24.143191+00	2026-09-02 12:35:46.196946+00	\N	2026-09-02 11:56:24.143514+00	2026-09-02 12:35:46.197129+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
930171c3-58ac-4077-88b2-7e5120b83c50	40517b71-5e62-182e-73b5-d4070e20a3c2	39cw1lO6X0JBofn5f4IShxB2skl0Y26oWrGK7tKER/A=	2026-09-09 12:52:17.018862+00	2026-09-02 12:52:28.621018+00	\N	2026-09-02 12:52:17.027859+00	2026-09-02 12:52:28.623473+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0a86b867-bf6d-4ed0-9024-938f1c9622d9	40517b71-5e62-182e-73b5-d4070e20a3c2	+v3ZjBbv3QHsPqK72NBeMYxzQGEweY4M6vDdwyVujWg=	2026-09-09 12:52:28.621849+00	2026-09-02 13:15:11.373133+00	\N	2026-09-02 12:52:28.623473+00	2026-09-02 13:15:11.394887+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d2c505c8-e1b9-4748-8bc0-14d95b478b84	6d1e9837-0276-46b5-a0f8-596f155139c8	c0ZszvQ6o9n4SGdR4KwhSdzomQzGKPQxIwdfKjzEu9Y=	2026-09-09 13:41:59.953498+00	\N	\N	2026-09-02 13:41:59.961629+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
474840b0-5990-4b1e-9392-ca4af08ae4a4	833a28fc-a624-4cbe-8e71-56c51eb53ab2	J+8fYMVS2J1OKYUhWec2bQZ39e/PSsBV2eI+s8oXbJw=	2026-09-09 13:42:00.446322+00	2026-09-02 13:42:00.569676+00	\N	2026-09-02 13:42:00.446575+00	2026-09-02 13:42:00.570368+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
20368093-2e70-4b9d-93ee-e0d3fa8d3322	833a28fc-a624-4cbe-8e71-56c51eb53ab2	lW4nwJISna/UqFYTy3AvthpyIcp7+e7Yh17Luy3tfNo=	2026-09-09 13:42:00.569973+00	2026-09-02 13:43:03.744165+00	\N	2026-09-02 13:42:00.570368+00	2026-09-02 13:43:03.746363+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
645534e9-8cdd-4755-9287-b9e665c88eb2	833a28fc-a624-4cbe-8e71-56c51eb53ab2	EAHVjbwrEOT+xc8e55V0/4vh1oKQwNUoSpTtXe+nYlo=	2026-09-09 13:43:03.746075+00	2026-09-02 13:43:09.993281+00	\N	2026-09-02 13:43:03.746363+00	2026-09-02 13:43:09.993637+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
079b0e56-aac9-484f-a8b1-e63fe9a95d13	833a28fc-a624-4cbe-8e71-56c51eb53ab2	zWtDeuOba2iGdr72J+Uu8rCWqciJZSe3cg5JhQauO38=	2026-09-09 13:43:09.993465+00	2026-09-02 13:49:55.978435+00	\N	2026-09-02 13:43:09.993637+00	2026-09-02 13:49:55.985636+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e9cf9cf0-2133-43dc-86d9-804c93768061	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	sG4YQcnuWdw0a+P0r2O4dgRf8hKYDzPuMYJHei5A42M=	2026-09-10 06:26:07.572464+00	2026-09-03 07:06:35.765192+00	\N	2026-09-03 06:26:07.587145+00	2026-09-03 07:06:35.7654+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c4f3c542-ce49-45d4-97bc-f982c6e314f5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	O9z8VDFK6GQxeqEm2eV2QWl6cI1xDSl+kqryS1r2I6I=	2026-09-10 08:35:53.536685+00	2026-09-03 08:40:10.620184+00	\N	2026-09-03 08:35:53.53684+00	2026-09-03 08:40:10.621909+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0ba3603e-3fe5-430c-8509-3763bbce3471	d1130837-5c69-40b6-a65f-913214e66693	o1xYZ4qjASAe1bfe/i/bwTJjrmU43lyTtRcjzZY1q9o=	2026-09-10 09:50:09.646883+00	2026-09-03 09:50:09.765678+00	\N	2026-09-03 09:50:09.64729+00	2026-09-03 09:50:09.766267+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ebd4d1fc-9c3d-40f0-8e68-b0a4b82a1d5e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	xiLJQbjQVGhmW6Zm0WkUHC5ix2kd6pFcWaooPDxqv3Y=	2026-09-10 12:33:59.021587+00	2026-09-03 12:41:40.660083+00	\N	2026-09-03 12:33:59.044924+00	2026-09-03 12:41:40.662869+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
\.


--
-- Data for Name: repository; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repository ("Id", "FileName", "Category", "Size", "LastUpdated", "UploadedBy", "FilePath", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	25	2026-08-25 07:22:47.738454+00	Dhanshree Pansare	repository/pms/20260825_072247_718_financial_report.xlsx	2026-08-25 07:22:47.810202+00	2026-08-25 09:40:43.668112+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:40:43.668112+00
2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	17754568	2026-08-23 18:31:21.474426+00	Admin User	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/20260823_183121_383_document.pdf	2026-08-23 18:31:21.564645+00	2026-08-25 09:40:45.54175+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:40:45.54175+00
06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	27	2026-08-23 18:12:46.368514+00	Compliance Officer	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/imp/20260823_181246_366_Company_Compliance_Policy.pdf	2026-08-23 18:12:46.39232+00	2026-08-25 09:40:47.36039+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:40:47.36039+00
f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	16	2026-08-23 18:12:46.310679+00	PMS Manager	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/20260823_181246_304_PMS_Workflow_Spec.docx	2026-08-23 18:12:46.312803+00	2026-08-25 09:40:49.106488+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:40:49.106488+00
e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	33	2026-08-23 18:12:30.416433+00	Curl Tester	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/20260823_181230_394_Sample_Architecture_Guide.pdf	2026-08-23 18:12:30.4294+00	2026-08-25 09:40:52.374735+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:40:52.374735+00
b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	1572864	2026-08-17 18:10:16.325141+00	Rahul Gupta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/Security_Incident_Response_Plan.pdf	2026-08-23 18:10:16.325673+00	2026-08-25 09:40:55.367843+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:40:55.367843+00
aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	614400	2026-08-15 18:10:16.325536+00	Vikrant Malhotra	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/imp/Remote_Work_Policy.pdf	2026-08-23 18:10:16.325673+00	2026-08-25 09:40:57.192443+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:40:57.192443+00
706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	655360	2026-08-15 18:10:16.325375+00	Rahul Gupta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/Resource_Allocation_SOP.pdf	2026-08-23 18:10:16.325673+00	2026-08-25 09:40:58.873408+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:40:58.873408+00
f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	819200	2026-08-07 18:10:16.325637+00	Anita Desai	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/imp/Leave_and_Attendance_Policy.pdf	2026-08-23 18:10:16.325673+00	2026-08-25 09:41:00.896423+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:41:00.896423+00
f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	327680	2026-08-02 18:10:16.325432+00	Aarav Mehta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/Change_Request_Management_Process.docx	2026-08-23 18:10:16.325673+00	2026-08-25 09:41:02.745863+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:41:02.745863+00
81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	524288	2026-07-26 18:10:16.32521+00	Riya Kapoor	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/Project_Onboarding_Checklist.pdf	2026-08-23 18:10:16.325673+00	2026-08-25 09:41:04.865657+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:41:04.865657+00
303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	1048576	2026-07-07 18:10:16.325485+00	Vikrant Malhotra	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/imp/Code_of_Conduct_2026.pdf	2026-08-23 18:10:16.325673+00	2026-08-25 09:41:08.982288+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:41:08.982288+00
40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	786432	2026-07-07 18:10:16.325269+00	Aarav Mehta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/WBS_Creation_Guidelines.docx	2026-08-23 18:10:16.325673+00	2026-08-25 09:41:11.173993+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:41:11.173993+00
0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	1048576	2026-07-07 18:10:16.324056+00	Vikram Shah	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/CI_CD_Pipeline_Setup_Procedures.docx	2026-08-23 18:10:16.325673+00	2026-08-25 09:41:13.552185+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:41:13.552185+00
b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	409600	2026-07-05 18:10:16.325322+00	Riya Kapoor	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/pms/Timesheet_Submission_Process.pdf	2026-08-23 18:10:16.325673+00	2026-08-25 09:41:15.5612+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:41:15.5612+00
c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	2457600	2026-07-02 18:10:16.247186+00	Rahul Gupta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/API_Gateway_Configuration_Guide.pdf	2026-08-23 18:10:16.325673+00	2026-08-25 09:41:17.889839+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:41:17.889839+00
1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	2097152	2026-06-28 18:10:16.325588+00	Anita Desai	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/imp/Data_Privacy_and_GDPR_Guidelines.pdf	2026-08-23 18:10:16.325673+00	2026-08-25 09:41:20.130903+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:41:20.130903+00
f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	3145728	2026-07-27 18:10:16.325014+00	Aarav Mehta	C:/Users/Pradnya Kamble/Downloads/Talakunchi/project_TrackerPro/storage/repository/tech/Database_Backup_and_Recovery_SOP.pdf	2026-08-23 18:10:16.325673+00	2026-08-25 07:41:58.113952+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 07:41:58.113952+00
ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	34	2026-08-25 09:28:11.650702+00	Dhanshree Pansare	repository/tech/20260825_092811_639_devops_guidelines.pdf	2026-08-25 09:28:11.712525+00	2026-08-25 09:40:38.242373+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:40:38.242373+00
3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	21506	2026-08-25 07:38:51.55257+00	Admin User	repository/imp/20260825_073851_528_TK_I_PMS_Tool_I_Timeline_I_V01__1.xlsx	2026-08-25 07:38:51.554397+00	2026-08-25 09:40:41.563467+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-25 09:40:41.563467+00
3c1b7fa3-a188-4402-8501-53bf39dd3080	_tmp_sop.txt	Tech	43	2026-09-02 10:15:55.544042+00	Admin User	Tech. SOPs/20260902_101555_535_tmp_sop.txt	2026-09-02 10:15:55.649353+00	2026-09-02 10:16:45.197166+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:16:45.197166+00
56991d48-cf5d-4e5f-9664-2fb0c39335cb	Pan Card.jpeg	Tech	144850	2026-09-02 09:38:14.249996+00	Admin User	repository/tech/20260902_093814_243_Pan_Card.jpeg	2026-09-02 09:38:14.250499+00	2026-09-02 10:19:41.757541+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:19:41.757541+00
7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	458969	2026-08-25 11:27:29.149632+00	Admin User	repository/pms/20260825_112729_130_TK_Tender_Summary_template__071223.pptx	2026-08-25 11:27:29.151008+00	2026-09-02 10:19:45.207848+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:19:45.207848+00
657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	16	2026-08-25 09:53:45.564045+00	Admin User	repository/tech/20260825_095345_527_PMS_Workflow_Spec.docx	2026-08-25 09:53:45.566515+00	2026-09-02 10:19:47.938387+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:19:47.938387+00
e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	187688	2026-08-25 09:46:52.823561+00	Admin User	repository/tech/20260825_094652_817_RFP_2026_7206600_Report__2.pptx	2026-08-25 09:46:52.824368+00	2026-09-02 10:19:50.849508+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:19:50.849508+00
93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	8176221	2026-08-25 09:44:59.377826+00	Admin User	repository/pms/20260825_094459_333_KEKA_-_PMS_Module_guide.pdf	2026-08-25 09:44:59.379004+00	2026-09-02 10:19:53.643105+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:19:53.643105+00
cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	13161	2026-08-25 09:41:56.891164+00	Admin User	repository/imp/20260825_094156_853_TK_I_PMS-Tool_I_Roles___Processes_1.xlsx	2026-08-25 09:41:56.894914+00	2026-09-02 10:19:56.310036+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:19:56.310036+00
3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	144850	2026-09-02 10:20:17.729048+00	Admin User	IMP Templates/20260902_102017_725_Pan_Card.jpeg	2026-09-02 10:20:17.729382+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3c4e24af-9c0d-4838-bd51-cc3c7eb4cbe0	_tmp_imp2.txt	IMP	22	2026-09-02 10:31:42.034339+00	Admin User	IMP Templates/20260902_103142_033_tmp_imp2.txt	2026-09-02 10:31:42.089893+00	2026-09-02 10:32:09.735989+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-02 10:32:09.735989+00
a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	112021	2026-09-02 11:15:59.470845+00	Admin User	Tech. SOPs/20260902_111559_469_Resume__3___1.pdf	2026-09-02 11:15:59.471482+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	16490	2026-09-02 12:02:50.298683+00	Admin User	PMS. SOPs/20260902_120250_297_Issues.xlsx	2026-09-02 12:02:50.299125+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	14866	2026-09-02 12:03:52.717045+00	Admin User	IMP Templates/20260902_120352_716_Abstract_5716___5720.docx	2026-09-02 12:03:52.717377+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5f35c6be-e98b-42b6-b664-e1940e593328	test_resume.pdf	IMP	75815	2026-09-03 07:03:58.739163+00	Admin User	IMP Templates/20260903_070358_731_test_resume.pdf	2026-09-03 07:03:58.794497+00	2026-09-03 07:04:20.309282+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-03 07:04:20.309282+00
71b01b98-a936-4f80-a406-ccf5f0f060b0	airQualityAbstactBoth.pdf	Tech	69207	2026-09-03 07:05:00.559386+00	Admin User	Tech. SOPs/20260903_070500_558_airQualityAbstactBoth.pdf	2026-09-03 07:05:00.559812+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: repository_activity_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repository_activity_logs ("Id", "Action", "DocumentId", "FileName", "Category", "PerformedBy", "Details", "CreatedAtUtc", "DeletedAtUtc", "CreatedBy", "UpdatedBy", "UpdatedAtUtc") FROM stdin;
d607a02c-2ed9-488d-a606-d9fd47a439e9	Uploaded	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Dhanshree Pansare	Dhanshree Pansare uploaded financial_report.xlsx	2026-08-25 07:22:47.810202+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
281f8c04-8e17-4c42-b856-e67ce0b8a0af	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 07:23:00.745697+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
78b454bc-6152-47a6-8662-b9d95a57581d	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 07:23:24.952618+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6554b6e5-2bed-4ee7-b6d0-f7e459c5b582	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 07:31:11.043031+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d26a4058-4793-45f3-be4e-c987d05b9754	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 07:31:15.165521+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a28b7611-1533-4c98-8ee7-e4e8f421c855	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 07:32:28.926641+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e83225de-cf2a-43c6-89e5-f48d11036851	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 07:33:14.559786+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
10ef4d3b-c8e1-456b-b6a4-68df639d440b	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:00:41.238362+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
28faca31-dce1-4ea8-8c95-e50366d9cb18	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:01:19.114777+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4b9f4a36-4cd1-4a1f-8d85-df03842e45b8	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:01:24.103884+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
73eaf7b9-b2c1-40d3-b7b8-d447e9d584c7	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:19:06.78787+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
02f475ec-54fc-4fd4-b9f1-eadcbae842a1	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:21:04.064861+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
765e1131-5007-41d5-a0e9-d1388d35805b	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:22:48.385103+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3b51ab42-d7ea-4f29-925a-384eb4c455cc	Downloaded	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co downloaded devops_guidelines.pdf	2026-08-25 09:29:29.989454+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d7604a59-0aac-45de-89ff-a8a73d7fe619	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Admin User viewed devops_guidelines.pdf	2026-08-25 09:32:36.020934+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
12bde8dc-dd37-434f-8a33-de22b69388c6	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 09:32:36.039749+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8a504a55-9279-4cc9-bcf0-6eebb19e849a	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:32:39.499136+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ddb08c36-c3a4-4937-ae9a-3fda9262e589	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	admin@acme.co	admin@acme.co viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:32:39.513797+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4818b1e2-5560-4cc2-9393-50fecec70c73	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 09:33:49.744384+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c426f146-df7f-414a-b734-2735098bd633	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	admin@acme.co	admin@acme.co viewed Company_Compliance_Policy.pdf	2026-08-25 09:33:49.764944+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
68bb1487-dc9b-47de-b1bd-bfb55172e82f	Deleted	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Deleted devops_guidelines.pdf from Tech	2026-08-25 09:40:38.242373+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7ebf97ee-50be-4352-ae21-cf6a8853be1a	Deleted	3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	Admin User	Deleted TK I PMS Tool I Timeline I V01 (1).xlsx from IMP	2026-08-25 09:40:41.563467+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a10068e1-ef46-4818-9a1b-a664722b020d	Deleted	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Deleted financial_report.xlsx from PMS	2026-08-25 09:40:43.668112+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9af86e4f-24a3-489a-83b5-0cc59b9118d5	Deleted	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Deleted ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf from Tech	2026-08-25 09:40:45.54175+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
192d9d10-513f-42cf-8439-47c7bcfc0639	Deleted	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Deleted Company_Compliance_Policy.pdf from IMP	2026-08-25 09:40:47.36039+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
31dd3381-5245-4b77-aa91-56130b0b22af	Deleted	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Admin User	Deleted PMS_Workflow_Spec.docx from PMS	2026-08-25 09:40:49.106488+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
89ea88b5-2245-4e4e-9e91-ad2ae18f6651	Deleted	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Admin User	Deleted Sample_Architecture_Guide.pdf from Tech	2026-08-25 09:40:52.374735+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7a435d55-8a3e-4a7d-923e-ba77b07d79a6	Deleted	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Admin User	Deleted Security Incident Response Plan.pdf from Tech	2026-08-25 09:40:55.367843+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d9c640bb-3779-4e25-bcfc-4aa406a06390	Deleted	aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	Admin User	Deleted Remote Work Policy.pdf from IMP	2026-08-25 09:40:57.192443+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b980db78-d1df-4564-a97a-1ae5b1f9405d	Deleted	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Deleted Resource Allocation SOP.pdf from PMS	2026-08-25 09:40:58.873408+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ae33ffca-29fd-4e44-badb-5516d1aaac88	Deleted	56991d48-cf5d-4e5f-9664-2fb0c39335cb	Pan Card.jpeg	Tech	Admin User	Deleted Pan Card.jpeg from Tech	2026-09-02 10:19:41.757541+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
053cbb7e-50f7-445a-ac2c-bf05a715f166	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 07:28:24.734245+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
38187c14-5450-48e1-b655-04122a7513b7	Viewed	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 07:30:35.456428+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d6277cfd-f5b1-490b-a065-6a45d4c167c7	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 07:30:40.183188+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4dc4a04e-6c73-4b7c-bff7-6dc7331cf6da	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 07:30:50.005183+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c44a4ce2-826b-4292-af6b-e21a77a53cab	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 07:30:58.776721+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a4da1efe-8c23-4c36-9d98-bccc69b1771d	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 07:32:17.759537+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f576c7d9-d2ab-4467-a20a-1d2e4eb205c7	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 07:32:31.547912+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2f8fa037-364f-4d31-9f64-3cb73ed3fa66	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 07:34:15.428053+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b7180df7-87ce-47f8-b479-9f3a018acd11	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 07:34:23.975146+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a4704e1e-f1e5-429d-81ae-9ded78a0e033	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 07:34:26.701891+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8f70b43b-6596-4e7b-8585-6f9cdaf6962f	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 07:34:29.146682+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f78002ab-88dd-482a-bc40-170aaf61c61a	Downloaded	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co downloaded financial_report.xlsx	2026-08-25 07:34:29.220377+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
189f8e28-0ba8-4f05-a0d5-f11b0d3771d4	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 07:34:33.882275+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
01822590-be49-4714-8e58-486ed760f957	Uploaded	3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	Admin User	Admin User uploaded TK I PMS Tool I Timeline I V01 (1).xlsx	2026-08-25 07:38:51.554397+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cc4e9fb1-9d59-427a-a4a4-57142dae140f	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:01:17.704572+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2fb79b63-cbeb-4127-9d38-46d296fb6d1f	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:01:20.121812+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8990236f-a815-4c1f-b387-ffa218ccbaf9	Uploaded	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Dhanshree Pansare	Dhanshree Pansare uploaded devops_guidelines.pdf	2026-08-25 09:28:11.712525+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fcca003f-8bf1-4599-857d-9a545d955846	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 09:28:20.040809+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1b80144c-92d2-4b78-8b5a-91f701b911d1	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	admin@acme.co	admin@acme.co downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:28:34.337088+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
081ef346-a707-4de2-8fcd-94876f718c1f	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	admin@acme.co	admin@acme.co downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:28:34.413384+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ad51b550-0084-499d-832e-6bdb27f64e94	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	admin@acme.co	admin@acme.co downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:28:34.889886+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
56025732-9e30-4676-a82f-be1a205d674c	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	admin@acme.co	admin@acme.co viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:28:54.174345+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7ce0515d-7388-40bd-8448-629506b4da69	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Admin User viewed Resource Allocation SOP.pdf	2026-08-25 09:32:49.583916+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0cb574ba-87a9-408b-869e-0a3def818770	Uploaded	f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	Harsh Nair	Harsh Nair uploaded Leave and Attendance Policy.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
112e2d3c-91a6-4d6b-baf2-69a76eee25e4	Uploaded	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Nikhil Khanna	Nikhil Khanna uploaded Security Incident Response Plan.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
50fb80b0-9bd4-44b7-9c5f-d96d3afb5c25	Uploaded	b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	Kavya Desai	Kavya Desai uploaded Timesheet Submission Process.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
568d9221-2331-4e91-804f-ed096870c14b	Uploaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Ankit Verma	Ankit Verma uploaded Code of Conduct 2026.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
6abc0e6e-1207-4b06-a9bd-478138cd07c4	Uploaded	c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	Rahul Sharma	Rahul Sharma uploaded API Gateway Configuration Guide.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
786a9eef-61bd-492f-a368-b6e101d1c84f	Uploaded	0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	Sneha Iyer	Sneha Iyer uploaded CI CD Pipeline Setup Procedures.docx	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
918f5751-2823-4cc9-bcc9-9d5ad87466e4	Uploaded	aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	Arjun Shah	Arjun Shah uploaded Remote Work Policy.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
924ba339-74fc-4f29-a464-962c2ac302ef	Uploaded	40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	Rahul Sharma	Rahul Sharma uploaded WBS Creation Guidelines.docx	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
96e82a4e-2ecb-4026-9e80-594ffe1ce32a	Uploaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Pooja Menon	Pooja Menon uploaded Resource Allocation SOP.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
c22e951d-d3f4-4643-b2a7-974db176b428	Uploaded	f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	Vikram Gupta	Vikram Gupta uploaded Database Backup and Recovery SOP.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
d192afd2-0878-442f-86fc-0127dad4a153	Uploaded	1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	Rohan Mehta	Rohan Mehta uploaded Data Privacy and GDPR Guidelines.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
e4f2ec92-a167-4cf9-aee3-cc567c1319e0	Uploaded	81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	Pooja Menon	Pooja Menon uploaded Project Onboarding Checklist.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
e7fce91d-4624-4e18-ba5d-8b510117a3bb	Uploaded	f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	Ira Kapoor	Ira Kapoor uploaded Change Request Management Process.docx	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
94d3b552-8e1c-4393-9592-a20f8d326264	Uploaded	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Karthik Bose	Karthik Bose uploaded Sample_Architecture_Guide.pdf	2026-08-23 18:12:30.4294+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
82fa392e-de1b-4938-b218-26367672f93e	Uploaded	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Rohan Mehta	Rohan Mehta uploaded PMS_Workflow_Spec.docx	2026-08-23 18:12:46.312803+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
108da6bd-194b-4607-a35b-97bb4d293708	Uploaded	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Sneha Iyer	Sneha Iyer uploaded Company_Compliance_Policy.pdf	2026-08-23 18:12:46.39232+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fc0662da-358a-4eb6-9a77-919358b4cb06	Uploaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Samar Patel	Samar Patel uploaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-23 18:31:21.564645+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
14f1c2f2-42c4-4ef3-bb84-5357fbc9be22	Downloaded	0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	Rahul Sharma	Rahul Sharma downloaded CI CD Pipeline Setup Procedures.docx	2026-08-22 11:41:48.449326+00	\N	\N	\N	\N
c3fb58a8-01a8-4fe1-9a67-553739f4b2d2	Downloaded	0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	Priya Sharma	Priya Sharma downloaded CI CD Pipeline Setup Procedures.docx	2026-08-21 10:41:48.449326+00	\N	\N	\N	\N
5a4e602f-dbc4-463f-a1f6-29de06c8b6ce	Downloaded	0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	Neha Kulkarni	Neha Kulkarni downloaded CI CD Pipeline Setup Procedures.docx	2026-08-22 14:41:48.449326+00	\N	\N	\N	\N
204837d6-5ec2-450a-99ed-92293f421b87	Downloaded	1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	Ishita Bansal	Ishita Bansal downloaded Data Privacy and GDPR Guidelines.pdf	2026-08-20 20:41:48.449326+00	\N	\N	\N	\N
931015f2-0bed-43a5-b934-ca024860b3d2	Downloaded	1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	Divya Rao	Divya Rao downloaded Data Privacy and GDPR Guidelines.pdf	2026-08-22 08:41:48.449326+00	\N	\N	\N	\N
5e5d2408-91b4-4214-acac-7b9b1826e31a	Downloaded	1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	Arjun Mehta	Arjun Mehta downloaded Data Privacy and GDPR Guidelines.pdf	2026-08-22 06:41:48.449326+00	\N	\N	\N	\N
8b2808e5-53b8-4aef-beb8-512679d9c20d	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Sneha Iyer	Sneha Iyer downloaded Code of Conduct 2026.pdf	2026-08-23 09:41:48.449326+00	\N	\N	\N	\N
d10c04f1-d038-4dda-9231-c03ac2e46843	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Karthik Bose	Karthik Bose downloaded Code of Conduct 2026.pdf	2026-08-21 11:41:48.449326+00	\N	\N	\N	\N
2e680325-0b10-48f6-9d10-67875d929aca	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Sneha Iyer	Sneha Iyer downloaded Code of Conduct 2026.pdf	2026-08-21 16:41:48.449326+00	\N	\N	\N	\N
76cb1f18-aff6-4a29-afd8-c68c46bcbd9b	Downloaded	40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	Arjun Shah	Arjun Shah downloaded WBS Creation Guidelines.docx	2026-08-22 11:41:48.449326+00	\N	\N	\N	\N
8b7a084c-1b75-4117-a2f4-01ce5ef6edd8	Downloaded	40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	Vikram Gupta	Vikram Gupta downloaded WBS Creation Guidelines.docx	2026-08-21 01:41:48.449326+00	\N	\N	\N	\N
3e58d5a1-b5ff-4f5c-b22e-f9bda728a3db	Downloaded	40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	Neha Kulkarni	Neha Kulkarni downloaded WBS Creation Guidelines.docx	2026-08-21 14:41:48.449326+00	\N	\N	\N	\N
8ff68488-7f36-4304-9bc3-ed8b8ae53c56	Downloaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Karthik Bose	Karthik Bose downloaded Resource Allocation SOP.pdf	2026-08-23 02:41:48.449326+00	\N	\N	\N	\N
47d0a623-9a3c-444c-a84e-dd86e1d7e39b	Downloaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Ira Kapoor	Ira Kapoor downloaded Resource Allocation SOP.pdf	2026-08-23 12:41:48.449326+00	\N	\N	\N	\N
0b691530-b686-407e-863a-e7524e3a55b8	Downloaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Harsh Nair	Harsh Nair downloaded Resource Allocation SOP.pdf	2026-08-22 09:41:48.449326+00	\N	\N	\N	\N
9f162188-c142-49bb-a480-f9e705c6381f	Downloaded	81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	Divya Rao	Divya Rao downloaded Project Onboarding Checklist.pdf	2026-08-23 02:41:48.449326+00	\N	\N	\N	\N
e69045d6-8df3-4310-86a9-d2d6d9235252	Downloaded	81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	Pooja Menon	Pooja Menon downloaded Project Onboarding Checklist.pdf	2026-08-21 22:41:48.449326+00	\N	\N	\N	\N
4cf570a5-8da5-4120-95f9-dfcc84b79fe5	Downloaded	81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	Rahul Sharma	Rahul Sharma downloaded Project Onboarding Checklist.pdf	2026-08-22 11:41:48.449326+00	\N	\N	\N	\N
fde22c76-4ebb-4c2a-aa18-6bf857643c65	Downloaded	aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	Pradeep Singh	Pradeep Singh downloaded Remote Work Policy.pdf	2026-08-22 22:41:48.449326+00	\N	\N	\N	\N
b64886f3-6b93-4f46-9b7d-31d2c9da4f0f	Downloaded	aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	Neha Kulkarni	Neha Kulkarni downloaded Remote Work Policy.pdf	2026-08-23 01:41:48.449326+00	\N	\N	\N	\N
c214d841-a6a9-4cbc-9054-e9cb3bcd87d4	Downloaded	aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	Rohan Mehta	Rohan Mehta downloaded Remote Work Policy.pdf	2026-08-22 02:41:48.449326+00	\N	\N	\N	\N
00583c50-650f-44b0-a4ad-75986cd3929b	Downloaded	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Samar Patel	Samar Patel downloaded Security Incident Response Plan.pdf	2026-08-22 11:41:48.449326+00	\N	\N	\N	\N
7fb16b97-ed39-4216-a827-56bd931fcb09	Downloaded	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Ishita Bansal	Ishita Bansal downloaded Security Incident Response Plan.pdf	2026-08-21 14:41:48.449326+00	\N	\N	\N	\N
a97f6af6-1da1-48f7-a1e5-d962030d7a19	Downloaded	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Rohan Mehta	Rohan Mehta downloaded Security Incident Response Plan.pdf	2026-08-23 02:41:48.449326+00	\N	\N	\N	\N
9951c65b-1f9a-4b0f-be32-04c1e28d3c12	Downloaded	b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	Ishita Bansal	Ishita Bansal downloaded Timesheet Submission Process.pdf	2026-08-21 05:41:48.449326+00	\N	\N	\N	\N
9ff8c2cf-ba00-4cf4-a7f8-7bf710ecdb54	Downloaded	b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	Ankit Verma	Ankit Verma downloaded Timesheet Submission Process.pdf	2026-08-22 08:41:48.449326+00	\N	\N	\N	\N
a9cf4a0f-3de3-4262-b01b-9bb80e11963d	Downloaded	b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	Arjun Shah	Arjun Shah downloaded Timesheet Submission Process.pdf	2026-08-22 13:41:48.449326+00	\N	\N	\N	\N
58e524dc-3c76-4855-9f76-f7acab052fe7	Downloaded	c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	Ankit Verma	Ankit Verma downloaded API Gateway Configuration Guide.pdf	2026-08-21 23:41:48.449326+00	\N	\N	\N	\N
065f4cd9-a880-4433-9137-84ce5716de56	Downloaded	c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	Kavya Desai	Kavya Desai downloaded API Gateway Configuration Guide.pdf	2026-08-23 14:41:48.449326+00	\N	\N	\N	\N
538c7860-92f7-442a-bde7-0e531217b7d3	Downloaded	c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	Sneha Iyer	Sneha Iyer downloaded API Gateway Configuration Guide.pdf	2026-08-21 19:41:48.449326+00	\N	\N	\N	\N
f50e9eae-8198-4ed6-b645-93fec5aa6426	Downloaded	f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	Nikhil Khanna	Nikhil Khanna downloaded Database Backup and Recovery SOP.pdf	2026-08-21 13:41:48.449326+00	\N	\N	\N	\N
1b1700b3-2ee8-448d-8935-78a1f59ad7ac	Downloaded	f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	Arjun Shah	Arjun Shah downloaded Database Backup and Recovery SOP.pdf	2026-08-21 21:41:48.449326+00	\N	\N	\N	\N
25a35454-d9d7-4e75-86c9-12aaefec0e03	Downloaded	f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	Samar Patel	Samar Patel downloaded Database Backup and Recovery SOP.pdf	2026-08-23 06:41:48.449326+00	\N	\N	\N	\N
98a015b6-4a84-4d48-8365-6348fdcba34c	Downloaded	f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	Arjun Mehta	Arjun Mehta downloaded Leave and Attendance Policy.pdf	2026-08-22 10:41:48.449326+00	\N	\N	\N	\N
caa35459-c646-4738-a213-e29d6d0ff204	Downloaded	f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	Ishita Bansal	Ishita Bansal downloaded Leave and Attendance Policy.pdf	2026-08-22 16:41:48.449326+00	\N	\N	\N	\N
2c966bba-8921-4ca6-83dc-841e191162e1	Downloaded	f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	Aanya Joshi	Aanya Joshi downloaded Leave and Attendance Policy.pdf	2026-08-22 07:41:48.449326+00	\N	\N	\N	\N
97a5e3fc-b3c3-46d2-917e-0268fb734405	Downloaded	f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	Arjun Mehta	Arjun Mehta downloaded Change Request Management Process.docx	2026-08-21 06:41:48.449326+00	\N	\N	\N	\N
0e193cda-8b76-4b0c-aab1-76dd15b57ef0	Downloaded	f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	Dhanshree Pansare	Dhanshree Pansare downloaded Change Request Management Process.docx	2026-08-21 01:41:48.449326+00	\N	\N	\N	\N
0d6a12da-9d19-4f2f-acdf-eb36c780957d	Downloaded	f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	Kavya Desai	Kavya Desai downloaded Change Request Management Process.docx	2026-08-20 22:41:48.449326+00	\N	\N	\N	\N
0796c02f-863e-4720-99d0-08e1d22aca4b	Downloaded	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Ira Kapoor	Ira Kapoor downloaded Sample_Architecture_Guide.pdf	2026-08-23 13:41:48.449326+00	\N	\N	\N	\N
6705fed4-e7f1-4da3-a994-d1459c40b2d1	Downloaded	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Neha Kulkarni	Neha Kulkarni downloaded Sample_Architecture_Guide.pdf	2026-08-21 20:41:48.449326+00	\N	\N	\N	\N
1766f944-696d-49e9-b78b-dc1b2b2f8f38	Downloaded	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Pradeep Singh	Pradeep Singh downloaded Sample_Architecture_Guide.pdf	2026-08-21 23:41:48.449326+00	\N	\N	\N	\N
324a41e8-43f5-4a6d-8786-e97437465e21	Downloaded	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Dhanshree Pansare	Dhanshree Pansare downloaded PMS_Workflow_Spec.docx	2026-08-21 23:41:48.449326+00	\N	\N	\N	\N
9f4438a2-9b6a-4497-9af1-52ef09bb48b3	Downloaded	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Yash Malik	Yash Malik downloaded PMS_Workflow_Spec.docx	2026-08-23 03:41:48.449326+00	\N	\N	\N	\N
2307ba67-c2f2-4277-a088-ce40ae3e6548	Downloaded	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Riya Kapoor	Riya Kapoor downloaded PMS_Workflow_Spec.docx	2026-08-22 16:41:48.449326+00	\N	\N	\N	\N
7d1ddbc4-c10a-49c7-83e4-f7c584ecb7ec	Downloaded	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Kavya Desai	Kavya Desai downloaded Company_Compliance_Policy.pdf	2026-08-20 21:41:48.449326+00	\N	\N	\N	\N
4403c271-c17e-4e4f-846f-9059df1dd29c	Downloaded	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Priya Sharma	Priya Sharma downloaded Company_Compliance_Policy.pdf	2026-08-22 06:41:48.449326+00	\N	\N	\N	\N
92ec2d47-797d-4afc-ac63-ad550c376c19	Downloaded	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Aanya Joshi	Aanya Joshi downloaded Company_Compliance_Policy.pdf	2026-08-23 15:41:48.449326+00	\N	\N	\N	\N
acb77d89-1c0a-4a1a-9b79-f8ac8d8f556a	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Arjun Shah	Arjun Shah downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-22 10:41:48.449326+00	\N	\N	\N	\N
c3c9370c-6208-4109-9701-5d81e63f86f7	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Priya Sharma	Priya Sharma downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-22 07:41:48.449326+00	\N	\N	\N	\N
8ecc0a49-ff0e-47b1-b816-5d6152f9e186	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Divya Rao	Divya Rao downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-23 12:41:48.449326+00	\N	\N	\N	\N
e1976767-5cbf-4a2a-8eb7-12d9bf2171db	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 07:31:01.811418+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
79fdeb96-8e1f-4a2a-bf5b-7543a93fc3c5	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 07:31:23.916218+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8547e788-8e0b-454c-a4fa-f61638428977	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 07:32:25.133528+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
662a1376-a1d8-4009-a417-d6e81270c795	Viewed	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Admin User	Admin User viewed Security Incident Response Plan.pdf	2026-08-25 07:41:46.409617+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0ad0ac8e-d84a-4cbe-a569-c132efa6c789	Deleted	f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	Admin User	Deleted Database Backup and Recovery SOP.pdf from Tech	2026-08-25 07:41:58.113952+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
80237877-9098-4deb-82ab-a29626b523b1	Viewed	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Admin User	Admin User viewed Sample_Architecture_Guide.pdf	2026-08-25 09:18:26.48448+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0cd99fda-7446-4501-9a44-21b9e7c5345f	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 09:28:54.401342+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
afa1dda6-ee8d-4c89-bb5f-02d3374daef2	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 09:29:07.192633+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d1c9d3e5-ca61-440f-ac7d-9bedec688a9a	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	admin@acme.co	admin@acme.co viewed Company_Compliance_Policy.pdf	2026-08-25 09:29:07.398809+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
98679e92-935d-43bc-8176-f28b6f132455	Viewed	3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	Admin User	Admin User viewed TK I PMS Tool I Timeline I V01 (1).xlsx	2026-08-25 09:29:10.575624+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bbebca19-6a76-4e9d-a7ed-cdd4a88c3b6a	Viewed	3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	Admin User	Admin User viewed TK I PMS Tool I Timeline I V01 (1).xlsx	2026-08-25 09:29:22.595684+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ccfbcfa7-9f8e-488f-b4b7-e3210de0dc85	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Admin User viewed devops_guidelines.pdf	2026-08-25 09:29:29.914392+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
678b19a0-9623-453c-a810-36fdfff02608	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Admin User viewed devops_guidelines.pdf	2026-08-25 09:29:35.246396+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9f4bcdc2-099e-4850-8b3b-dbd4adf3d1f1	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 09:29:35.257521+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9a5a15a0-3736-4457-8ac3-3cfaa5a51470	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Admin User viewed devops_guidelines.pdf	2026-08-25 09:29:41.530449+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a5f9eb34-3383-4155-9a4d-c0fa468bfa81	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 09:29:41.537485+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
22afe7ad-e277-4f73-a191-e73f2aa64864	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Admin User viewed devops_guidelines.pdf	2026-08-25 09:32:29.417641+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
58f55140-5857-4b9a-9c34-a95b5f71c98b	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 09:32:29.533271+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7bbc408f-729a-4ec2-8838-5ab635073bb4	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	admin@acme.co	admin@acme.co viewed Resource Allocation SOP.pdf	2026-08-25 09:32:49.629901+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9c0ae3a9-9a60-401a-80d9-b663aec330c0	Deleted	f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	Admin User	Deleted Leave and Attendance Policy.pdf from IMP	2026-08-25 09:41:00.896423+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
77658d09-c027-4cd5-abd7-5ff05d566906	Deleted	81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	Admin User	Deleted Project Onboarding Checklist.pdf from PMS	2026-08-25 09:41:04.865657+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
85ab957e-bc29-4f7e-9c6a-4e0138a56e9a	Deleted	0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	Admin User	Deleted CI CD Pipeline Setup Procedures.docx from Tech	2026-08-25 09:41:13.552185+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
96cfd7fa-153e-4549-b6cd-ca19cd0d30be	Deleted	c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	Admin User	Deleted API Gateway Configuration Guide.pdf from Tech	2026-08-25 09:41:17.889839+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
baa936a5-71fd-4af7-a670-cba65d304036	Uploaded	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User uploaded TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 09:41:56.894914+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7d4ad808-e905-4826-a86b-53a100d137ff	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 09:42:32.014802+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
55f25191-957c-44cb-ba92-a88bd3c8a253	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 09:43:14.913729+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b62faa12-819e-4134-a29f-eadbb372a9d7	Deleted	f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	Admin User	Deleted Change Request Management Process.docx from PMS	2026-08-25 09:41:02.745863+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
861174aa-1f5d-4349-be18-db9e1ad9c3d8	Deleted	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Admin User	Deleted Code of Conduct 2026.pdf from IMP	2026-08-25 09:41:08.982288+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dfb05e96-62eb-45c5-ba1f-25ccffce0edd	Deleted	b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	Admin User	Deleted Timesheet Submission Process.pdf from PMS	2026-08-25 09:41:15.5612+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
55f66c36-3381-4464-bdf1-098a82f79422	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 09:42:05.265142+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0fefb687-e315-491a-b99a-dc5425975355	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 09:42:34.420151+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
40831c73-372b-4648-affc-eef432a3d821	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 09:43:26.424949+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c340d0c3-754f-4c4a-8a26-a19a85963036	Deleted	40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	Admin User	Deleted WBS Creation Guidelines.docx from PMS	2026-08-25 09:41:11.173993+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dc74bed8-ad2e-472e-b268-9104b89ff799	Deleted	1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	Admin User	Deleted Data Privacy and GDPR Guidelines.pdf from IMP	2026-08-25 09:41:20.130903+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
166d6a4c-7975-4fa1-9079-103667b96021	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 09:43:12.716785+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
63119738-3449-4669-986d-f7be4b14bfd6	Uploaded	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User uploaded KEKA - PMS Module guide.pdf	2026-08-25 09:44:59.379004+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2cddcb3c-bdaf-45db-a8e2-63623f4854b7	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 09:45:28.006251+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c1d22924-270f-4dfc-9914-d9923c46b8a4	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 09:45:28.019102+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ddd7a886-508a-4041-9e00-3e439b511d03	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 09:45:43.375295+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5a979174-3789-49bb-a7c5-8249a4cbb241	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 09:46:12.952363+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dd53f5be-e101-4866-937b-b7ae93d9e20a	Downloaded	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co downloaded KEKA - PMS Module guide.pdf	2026-08-25 09:46:13.026526+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
82260265-8670-4b53-bfb2-4d77fa52f463	Uploaded	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User uploaded RFP_2026_7206600_Report (2).pptx	2026-08-25 09:46:52.824368+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2593dcb5-39c6-4c73-806f-b9c545ebe3bf	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 09:46:55.305783+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e036b4f1-2e2c-4e56-9b29-f45eb2aba4e4	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 09:51:59.615623+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8f89d3c0-5e28-4661-bc05-c4b443247e19	Downloaded	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co downloaded RFP_2026_7206600_Report (2).pptx	2026-08-25 09:51:59.797282+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fb040c03-e9bb-461d-a22f-b8983302e65d	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 09:52:48.055362+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
eefbdc38-f6d4-4886-b593-fad8e56f3e7e	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 09:52:49.787115+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d7ea8ee8-4df9-4c0f-b298-7adf654b9112	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 09:52:59.733263+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e0ecc121-d960-4338-8571-8735cccb3cc3	Downloaded	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co downloaded KEKA - PMS Module guide.pdf	2026-08-25 09:52:59.802979+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1016be0f-7764-40e3-b9c8-f925ea570cc8	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 09:53:10.729817+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f5670105-e58b-4148-b77a-08ad0682f656	Downloaded	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co downloaded TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 09:53:10.789418+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
86e9eebd-9f43-4432-9104-6809f78717b3	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 09:53:14.523679+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4e9e9cdc-85b8-4d76-863d-dceac06aee4a	Uploaded	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User uploaded PMS_Workflow_Spec.docx	2026-08-25 09:53:45.566515+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
90d1f14a-00e7-4286-afa0-a6ffaaf770fc	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 09:53:49.375175+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d0454ed3-a0d3-4afe-bd17-d8c4c1454717	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 09:53:52.177791+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4f2b0996-6d0e-4044-843f-a45d93dba347	Downloaded	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co downloaded PMS_Workflow_Spec.docx	2026-08-25 09:53:52.246431+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
805e42dd-90cd-4ac5-a5dc-c867f25734bf	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 09:54:05.608742+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dd00f3d4-2684-4b69-8097-546c0a58654f	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 09:54:40.344188+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0c170afc-883b-41ff-853a-2ecf0ee512c4	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 09:54:43.574818+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e7cf6413-2452-4dba-89a6-6b10acac1be6	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 09:54:43.591183+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ead84d4e-9f2d-49b0-ad5d-4642492e8c88	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 09:54:46.240741+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cfc96161-41e1-4b0c-b2c4-ac1070b761c7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 10:08:04.052948+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cf5b4d22-a5fd-4c00-8527-7de4b30a05ae	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 10:08:08.823387+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fe8ad6e1-230a-4cbc-913d-db93531035cc	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 10:08:11.240409+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bce401c0-8bd2-4aae-9131-cdf62bcd8e3b	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 10:08:15.566642+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2e2a1851-cdfd-440a-99d8-486cadd650ea	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 10:08:15.707582+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ccebe2f6-f78e-487c-b8e9-a94d1a8ae6db	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:08:18.981614+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
243bf1ec-2729-405c-bfc6-0173fa1652c0	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 10:15:43.270085+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a8969dfc-18c9-495c-ba95-f764c598de46	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 10:15:58.53812+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c6fdd864-84ba-41ba-8941-d9443ed6775f	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:16:23.393287+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2baa02b8-0548-4563-99f4-3e4a46f3e216	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:16:31.895412+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ac59c5ff-5fa4-469a-a4d2-2111f8253657	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 10:17:02.747015+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
89944e55-6d09-45d9-a966-b19a142ab2ef	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 10:17:03.073767+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f712d046-7f9b-4ad7-89f7-6b5e14a85a65	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 10:17:42.151705+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fd1ea963-a12c-4ba5-9d7e-25d943fab0b9	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 10:19:25.434206+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f12b0758-c2fc-494c-854b-4811e6b654b7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 10:19:25.983006+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
121e452c-f266-41c2-8477-9b467729fdb7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 10:19:26.306866+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
07324d87-2331-4f4a-97c4-7fc7ffa07e0e	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:22:11.654033+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6323453a-909d-481b-b925-a31da395101a	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:22:12.052126+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
457d7006-60c0-4e22-9778-2de25e4ddf13	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:22:13.166877+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
73820f36-e896-489f-b1ca-277173fecbca	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 10:22:54.03256+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
185872e4-b944-48cb-8ee8-cb4a1cfbb996	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 10:22:54.092568+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6aaa74de-1486-4b02-bdaf-1b5ce4b44d96	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 10:22:54.47585+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
31135774-baf9-4a98-bce0-99a5e2dbb68f	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 10:33:07.517139+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7f73b402-0f99-46f7-9f17-c9c8769e0ac4	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 10:33:07.610611+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0857b4af-1891-4dcd-9734-83a4b573b9e7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 10:33:07.690007+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
43115495-48f2-489c-974c-c14c32f54578	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:33:14.407586+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
be2cbcae-c71d-42bf-97fc-f9e69d2d5c6a	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:33:14.426153+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b9725752-aa22-4e58-b387-2165aac776c8	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:33:14.51003+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
91e5a29b-0fd3-498e-b9b2-67dce3c306b4	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:33:18.973814+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dcccdba8-9d66-4a9b-934c-730aa12b15c8	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:33:29.150048+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aa4f13fa-9866-43b8-b608-d7101e2d8b6f	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 10:37:21.297157+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e35b0e28-2be0-4830-b314-b1331e73026d	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 10:37:21.403725+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f11d237c-4cd4-4496-856c-cec927d7cda7	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 10:37:36.442934+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
24a963b1-fa21-40fe-bacb-1af6d7b603f8	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 10:37:36.478415+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9615f70a-ac9c-4e1b-9015-49afe6d9f19f	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 10:37:38.958459+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
845473b6-f13f-4e6e-bbbd-24c309a273b6	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:37:56.200884+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cd236f92-58c3-417f-bc0b-4d1c0432400b	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:37:56.250204+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1b72ce86-4cfa-4566-b1fc-6f185bad536b	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 10:37:56.374437+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
46a27324-6cc6-4c51-af43-a9aabdd217ea	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 10:38:12.263691+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
78c588fe-f5a5-403c-9913-9baad2b95afa	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 10:38:12.34976+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
750dca96-db72-4486-9e91-1e755c5872c5	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 10:38:12.538335+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
02828fa0-6070-4e3d-8ab8-68f12cb1a1c7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 11:26:29.669986+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7e1b4796-beab-4b26-b5a1-56de3c94d7c4	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 11:26:29.762743+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3a643d69-a8c1-45d6-adaa-d84746b99ead	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-25 11:26:29.828306+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fef1f54f-fc74-422f-8d63-595d7f167bd9	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 11:26:36.78937+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4b8830a0-5002-4236-b16e-6263e47e3d6c	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 11:26:36.814021+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
647d4778-5c2c-4236-b4e1-e427f7b632c1	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-25 11:26:36.855745+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
deb24f3d-d15a-4389-922a-c78f41fb688b	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-25 11:26:51.123859+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0b7c5e96-7400-45ac-b12f-ce40568f78e4	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-25 11:26:51.155422+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0235a23c-6831-401c-b5f0-3f02e9652722	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 11:27:03.714348+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
24c04d56-fbe1-4bb1-b120-6e5f24d71f1d	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 11:27:03.761883+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
605cc084-58dd-475e-9589-4eb54cb3c975	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-25 11:27:03.803806+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9d853117-1071-49b0-a1b7-bc97b0aad13e	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-25 11:27:34.906326+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
54ccf973-994c-4338-9247-8df2ba703013	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-25 11:27:34.967357+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
74dccc36-5427-4d09-a301-792d75bbefc2	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-25 11:27:48.217366+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cb5e6e9e-5479-4907-be5c-a2e2297bca6d	Uploaded	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User uploaded TK_Tender Summary(template)_071223.pptx	2026-08-25 11:27:29.151008+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
47534ae8-037c-4879-9760-fbbaded81d40	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-25 11:27:34.913529+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
774a0f34-6568-4b28-99ac-15ac95fbc2a6	Downloaded	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co downloaded TK_Tender Summary(template)_071223.pptx	2026-08-25 11:27:48.292788+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
410cfb6e-69a7-44da-b2ef-5809ef258417	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:38:03.869477+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5f743625-51f4-46d1-bea8-315c87527fd6	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:38:03.946995+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
87c308c0-ec86-4416-abcd-b01784d2ed9f	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:38:03.975032+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ece54adc-cbc8-4ed4-a092-dd92deba0ca3	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:38:20.507985+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6ea5f9bb-36cd-4d7b-bc22-a23300f0e002	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:38:20.559969+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
88c9fd85-c12b-4667-8f0d-d6473e59cd53	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:38:20.581054+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8a972620-ffc4-430b-af56-04b275ebbc90	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 05:38:24.268304+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ed712d63-fa8e-4887-9088-99bde24b004b	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 05:38:24.278756+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bf5473b2-a0c1-4aed-87fc-d22961ad8e52	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 05:38:24.315774+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
088d7b9d-e3ab-40e0-8cde-1c0fe93098d3	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 05:38:30.908259+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c59d2698-1bf2-4c07-a18a-9bbaaa902e2e	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 05:38:30.948993+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f45a3fdf-995d-4810-a7f4-ff0ee607b12f	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 05:38:31.033289+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5a6d9e16-3c21-4aae-888f-378261c475e7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 05:40:23.817558+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d9e26b1f-af26-46b8-bb18-4eb962a2d163	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 05:40:23.962961+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
78c1ebe7-6f26-4f08-af3f-04a66fc7c68a	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 05:40:24.004388+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0ec62ecb-7997-4c11-849b-a537a7d07675	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:41:26.546864+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
47d4e402-16d4-4874-bb7e-23441b99d7c7	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:41:26.575294+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7bdc5e3e-60e8-420f-95d9-82874b9be348	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:41:26.608684+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
21f9f97a-3b92-459f-81a3-914d1c469c7a	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 05:55:02.256697+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8979f331-8fdb-48f6-8ae5-7b594b51851a	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 05:55:02.317883+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cbba69c4-5500-4099-97ac-c61be4c28834	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 05:55:02.367779+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ac044be6-0927-436f-aad1-55d96134a60a	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:55:20.453504+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
747e9cc1-9afb-4d8d-83fe-3dd1eadf4f9d	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:55:20.472359+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b2463079-dffe-4ffc-9cc2-62254466aae5	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:55:20.525795+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0cda26d4-f711-41a2-b168-fd35ef9287fd	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:55:27.198822+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
022ce174-82aa-40ad-9456-317eb7c5328b	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:55:33.949538+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2552c00c-ae7a-4598-8a9b-f850d7e5b798	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:55:33.961086+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9eedb6d1-ddbb-4f37-bde9-e512c64d9f53	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 05:55:34.007894+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aa7c3e3e-f57c-48c4-85fe-57e46a33c7a4	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 06:08:04.07947+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a5c7508d-e177-4af9-a724-5dcdbadb20a3	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 06:08:04.289378+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8930eb8d-5b4d-4237-9697-d04138bd5aeb	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	admin@acme.co	admin@acme.co viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 06:08:04.354599+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
99704101-7c16-4e36-9dc0-e92741e08d13	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 06:10:07.721884+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a27993b1-5d1b-4587-b112-b15e825eb07d	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 06:10:40.44335+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
192f273b-541b-4fe3-9726-f24134f9bae5	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:10:40.50201+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
08397ced-2238-4264-987e-d1b5b2a05081	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:10:40.586178+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bf4ebb3c-d21b-4d88-9117-44be7d6624dd	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:11:03.923606+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b9f67a26-1504-4cf7-a7db-f5bc59fa11ea	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 06:11:36.836605+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8925e46d-1a06-4098-abbb-36756ad93ecb	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:12:11.194744+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
66d8d6ff-b3a0-4b7c-af92-7490d6f5d768	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:12:55.071071+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
55e68b44-123a-49bf-a966-0813ace2e605	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:12:55.194389+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8f360a1d-3739-4b6c-a20c-6907c6556af0	Downloaded	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co downloaded PMS_Workflow_Spec.docx	2026-08-26 06:11:37.140386+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6a1d93e6-3f64-46cc-af9b-fecfe35d335b	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:12:09.97824+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1e216072-a1d2-44f3-8849-9e1b7c822f33	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:12:10.931598+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a91588ee-8ea2-47c0-b4cd-39b1fddeb83a	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:12:28.534994+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
68e1ce94-6ad6-43bd-915d-2e588840ea27	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:12:55.33586+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
52fd825e-ffed-495e-ac52-39c5cfa92d58	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:13:14.345015+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cf92f987-6f78-4ab2-8a6c-2915e9492d33	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:30:15.446747+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
142fab88-fdbf-403b-b949-1089ebebe9bf	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 06:30:15.446747+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1520051e-bc7e-4c5c-b0e8-69e3f228ec85	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:30:15.745874+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a06db79f-53a6-4aee-908f-07378efa4361	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:30:26.122159+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ff2b4d4d-1438-4f12-bb33-4732284af09d	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 06:31:58.277165+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3c602d6c-51b0-4cb0-88c2-c59156872786	Downloaded	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co downloaded PMS_Workflow_Spec.docx	2026-08-26 06:31:58.45281+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b1053847-e27b-4cdf-9182-18af83a040c0	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:32:40.844379+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6cbf768e-9bd0-4168-8615-906620bfae14	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:32:41.065567+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1ce5dbeb-5844-4cf6-b138-d4ddba93990a	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:32:41.182796+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
59d0090e-3831-4b15-ab2d-2d07ddf6f47c	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:33:05.385389+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a8c8dd9f-ace8-47b3-95b6-6b7fa2a13526	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:33:57.863265+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
af959843-363e-4dc1-81ba-003ca40ff8de	Downloaded	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co downloaded TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:33:58.661822+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e208611c-5491-4f82-b97a-acf47039d9e5	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 06:47:40.85102+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
34f8398a-09c3-4a92-ab58-6aeeafc4adc7	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:47:40.884004+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c7597099-a9dd-4c48-a435-c4353f572a84	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:47:40.955719+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d1976852-c76a-49c5-92db-c1cc6bac8d89	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:47:44.42441+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a066da1f-befc-4952-84b7-03d04cbd5a7a	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 06:47:56.236311+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
57627851-785f-4e70-8e4f-346c7c0f63ce	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-26 06:47:56.278716+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aa9fa0af-d20f-4bb7-bb97-42f90118772b	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	admin@acme.co	admin@acme.co viewed KEKA - PMS Module guide.pdf	2026-08-26 06:48:00.022366+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
671c8ca7-8b0b-4b0b-bef0-e30a87438acb	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:48:07.351564+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d274ce57-8c3e-492d-8a1f-15fffdb94317	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 06:48:07.353482+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0b782a22-080a-44b1-8a50-0b01683def65	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:48:07.381911+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e19bd9f4-613a-4151-9356-cad0d83d208f	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:48:09.181425+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cd2935a6-f51b-47e7-aa9e-cfda165d086e	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 06:48:17.043903+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
70199401-bf22-4fc2-a692-d0f4e9365208	Downloaded	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co downloaded PMS_Workflow_Spec.docx	2026-08-26 06:48:17.101603+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4beccdc2-a3f2-46c4-a1c0-794c07b06873	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 06:48:35.106282+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f310e881-34be-40ce-a873-33bd209f04a7	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:48:46.160135+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d34da8b0-cca9-4fa7-9627-9d6c41a25f37	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:48:46.1597+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
da6735a3-15c6-4eca-ad72-a9e8cdf8c35e	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:48:46.197638+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8e5014ce-3f1d-4b96-9fb2-af7bf0985b83	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 06:48:50.122341+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e09d3bba-41f7-42e2-9875-65aa0f8114d3	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:51:03.171062+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5d90332b-07c5-44c4-9f57-3858c0d9a3c1	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:51:03.174398+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
04419bb8-0929-4029-80d2-a8d8969cd9d0	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	admin@acme.co	admin@acme.co viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 06:51:03.216259+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
17a3acf3-9aea-4923-b5fd-8b30d8a7828d	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:52:07.669494+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2e2266a5-a910-4236-bf3f-888c283c4301	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:52:07.672485+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
635ac707-54a3-4b3f-a037-aa21c119b183	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:52:07.722655+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6a567300-9a24-4dcb-a80b-41e0d2ecb5dd	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 06:53:05.309637+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a0cbcabc-1685-4575-93e8-7553e41443a2	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:53:05.339903+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
01efd667-d0b2-4321-b8b2-26b3dbe889f5	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	admin@acme.co	admin@acme.co viewed PMS_Workflow_Spec.docx	2026-08-26 06:53:05.377538+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
eec7820a-d21a-4a26-b3ac-432d02c8ffb4	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 06:53:30.964212+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2671f831-a91c-448b-8f97-c9a02b751870	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:53:34.679863+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d46d4631-0d26-4e2f-970f-cbcbe29f7873	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:53:34.686517+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
99565cd1-6d12-4667-a38d-b2300ff1e1bf	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	admin@acme.co	admin@acme.co viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 06:53:34.732891+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
da74af41-ac9d-4622-a334-dae31d8570bd	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 07:01:08.67231+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a6125343-7dc9-48dc-b4a1-dbbee505d03d	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 07:01:42.42592+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
76dab2dd-3886-4b0e-a4ef-dababe8d812a	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 07:02:41.032275+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
332f1901-fb11-4028-b123-3cb858d0dadf	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 07:03:18.429198+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
de74766c-f174-4c47-a674-43cbf3d4ca63	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-26 07:05:19.158471+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
688a848c-3dbf-45e7-802c-b992c8fe2258	Viewed	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Admin User viewed RFP_2026_7206600_Report (2).pptx	2026-08-26 07:05:23.425039+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
59dc2d63-de4e-4e08-b4f8-613845c50952	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-26 07:06:18.096394+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aa83339d-a9ac-4762-bd89-23a66c5b2db5	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 07:06:22.001862+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2237747f-eac3-431d-88e7-0cd8342d9e4d	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 07:09:55.891849+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f5ec77b3-b06e-4137-a157-b7c7aca420b3	Viewed	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	Admin User	Admin User viewed Issues.xlsx	2026-09-02 12:03:16.27053+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6ec6afda-d74b-42b9-8844-e5f930be7516	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 07:10:11.132866+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9971ded1-71cb-406c-981e-3758a3cee1ca	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 07:11:34.870294+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6ac0cb87-3a8c-421f-88c2-c41a70ee1215	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 07:11:39.663556+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
89654775-eb76-4709-a22c-b2ec2ead56ed	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-27 07:17:24.312173+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
36671b39-c539-412a-a5b3-973c8bfc929c	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-28 10:00:12.437064+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a4f7686e-68fa-4f37-8d77-8dfb290377c0	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-31 07:46:33.457198+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
07b4c964-0477-4ddd-adb3-b450f1e9d0e9	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-09-02 07:36:25.119119+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f213fcf2-a2b4-471a-adb5-67642a4fcae2	Deleted	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Deleted PMS_Workflow_Spec.docx from Tech	2026-09-02 10:19:47.938387+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b877d257-0e99-4310-a0bc-9ae7dc005a94	Deleted	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Deleted TK I PMS-Tool I Roles & Processes 1.xlsx from IMP	2026-09-02 10:19:56.310036+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
622ef33b-a7d0-4e46-8b13-7f6068867db4	Uploaded	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	Tech	Admin User	Admin User uploaded Pan Card.jpeg	2026-09-02 10:20:17.729382+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f8c9b464-13f0-4313-a6bf-ca9418ff65ab	Viewed	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	Tech	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 10:20:26.701641+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6c780373-110d-471c-99c3-1c96c5c6d877	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Dhanshree	Dhanshree viewed Resume (3) (1).pdf	2026-09-02 11:30:01.940898+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
40fb39f2-e150-497d-8d54-9a80c5902279	Viewed	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	Dhanshree	Dhanshree viewed Pan Card.jpeg	2026-09-02 11:30:13.871171+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
56a5c401-6d9c-4fd2-8162-a03ff4c94d23	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:03:56.760296+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4aff02fe-5c9d-4404-aea5-1500fda70c6f	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:04:04.133432+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5c1d08f2-624e-47dd-b5cc-46ef7fed5297	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:04:11.054296+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b55adfff-b225-4331-b656-f728dfac444b	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:04:20.653477+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
58d522db-dcad-42d0-b639-f4b2a96ba9cc	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:04:22.133385+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8642cf15-3741-4100-9a05-59737158a696	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:04:23.427277+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
222678fe-411d-4a68-bc48-7a2e6110d2f9	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:04:24.608357+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7712981d-d476-4ca1-a8b0-a7806a465d4b	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:04:27.267801+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e543fefd-5512-43ee-b502-147d06ecbe63	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:04:30.690539+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1f31a7a6-51c9-4ea3-8e20-79de151d7102	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:04:35.013755+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3ff521ed-512f-4ffd-9816-263839bb7c33	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:07:19.475162+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dea1e9bc-efaa-49b2-9dd8-0c581492d7ef	Downloaded	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	admin@acme.co	admin@acme.co downloaded Abstract 5716 & 5720.docx	2026-09-02 12:07:25.612181+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
33065a9f-f1f5-4136-a39b-4cf836f0c7a1	Viewed	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 12:07:31.417232+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ed506731-9412-4ab9-a7d4-c20225d9ad9d	Downloaded	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	admin@acme.co	admin@acme.co downloaded Resume (3) (1).pdf	2026-09-02 12:07:39.347766+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
858b1304-aab9-407c-85ef-41fd7bf525f7	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:54:49.984644+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
37d140ee-eadb-4fb6-a411-0574a7529b53	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:55:08.037305+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0133895c-d202-4056-9592-badad1ccdb74	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User viewed Resume (3) (1).pdf	2026-09-03 06:21:27.126654+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b5fa0c50-c1f6-4e68-8c09-1457b022ed33	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-27 07:17:34.287533+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ea5a3e49-60d9-41bf-bb55-cda349ef32ea	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-28 10:00:14.789907+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4bddbddb-3e9f-4ba9-abd7-a6de82c648d7	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-31 07:46:40.161063+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f136d571-4635-4f5f-a96d-1d34ef648d17	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-09-02 09:37:53.205434+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
906a0a58-f5fe-490a-bc5c-e030311efbe7	Uploaded	56991d48-cf5d-4e5f-9664-2fb0c39335cb	Pan Card.jpeg	Tech	Admin User	Admin User uploaded Pan Card.jpeg	2026-09-02 09:38:14.250499+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
385cbd16-a35b-4def-9a0c-a11153c72aac	Downloaded	56991d48-cf5d-4e5f-9664-2fb0c39335cb	Pan Card.jpeg	Tech	admin@acme.co	admin@acme.co downloaded Pan Card.jpeg	2026-09-02 09:38:26.35222+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
96acd7e5-0e2c-4c38-8d16-359c8c15798a	Deleted	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Deleted RFP_2026_7206600_Report (2).pptx from Tech	2026-09-02 10:19:50.849508+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
36bec722-5fbb-4c64-b192-9b11b553459d	Deleted	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Deleted KEKA - PMS Module guide.pdf from PMS	2026-09-02 10:19:53.643105+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
94d25da7-3eab-45fc-a072-0df18a4ff0a5	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User viewed Resume (3) (1).pdf	2026-09-02 11:53:25.981303+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
06bdb025-7277-49cf-9ecd-04a50df17e2c	Downloaded	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	admin@acme.co	admin@acme.co downloaded Abstract 5716 & 5720.docx	2026-09-02 12:04:35.079526+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7897667d-b449-4e18-8e54-ae0322ce2917	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:07:25.570063+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e7d7ec2e-aef5-405a-bcd3-d17aea130cc3	Downloaded	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	admin@acme.co	admin@acme.co downloaded Pan Card.jpeg	2026-09-02 12:07:31.454371+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
69c5862c-eeae-47f4-908e-32920ccda060	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User viewed Resume (3) (1).pdf	2026-09-02 12:07:39.307653+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f0102759-2318-4b24-acd9-a5aac5840d21	Downloaded	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	admin@acme.co	admin@acme.co downloaded Abstract 5716 & 5720.docx	2026-09-02 12:55:08.081256+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4ba60a5a-aa2b-41e0-94ba-3c9c06c82177	Uploaded	5f35c6be-e98b-42b6-b664-e1940e593328	test_resume.pdf	IMP	Admin User	Admin User uploaded test_resume.pdf	2026-09-03 07:03:58.794497+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3895e15e-3439-45a2-9fc8-aab95d6038ee	Deleted	5f35c6be-e98b-42b6-b664-e1940e593328	test_resume.pdf	IMP	Admin User	Deleted test_resume.pdf from IMP	2026-09-03 07:04:20.309282+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
623e48e5-2057-4782-ac69-769f81390b8d	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-27 07:19:19.848092+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7f1ccb69-7359-4d30-9391-7367eca0910f	Viewed	56991d48-cf5d-4e5f-9664-2fb0c39335cb	Pan Card.jpeg	Tech	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 09:38:18.221946+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
953eff37-03cb-4fc0-80c8-c53a194b3351	Viewed	56991d48-cf5d-4e5f-9664-2fb0c39335cb	Pan Card.jpeg	Tech	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 09:38:26.268906+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
30653852-d662-4a97-8c14-a00cc76e0939	Uploaded	ed2563f7-e191-4d1b-8f14-e485037f5da3	_tmp_imp.txt	IMP	Admin User	Admin User uploaded _tmp_imp.txt	2026-09-02 10:31:31.530595+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d2cb97b0-70b1-4546-8bf8-4455e9e91628	Uploaded	3c4e24af-9c0d-4838-bd51-cc3c7eb4cbe0	_tmp_imp2.txt	IMP	Admin User	Admin User uploaded _tmp_imp2.txt	2026-09-02 10:31:42.089893+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ec9decf4-5343-4910-9471-a185732d6b1b	Deleted	3c4e24af-9c0d-4838-bd51-cc3c7eb4cbe0	_tmp_imp2.txt	IMP	Admin	Deleted _tmp_imp2.txt from IMP	2026-09-02 10:32:09.735989+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
635d4b53-110e-4757-844a-93830b436ab5	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User viewed Resume (3) (1).pdf	2026-09-02 11:58:40.897431+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f6988643-72bf-4987-bcf0-c384f1a6cb1b	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 12:42:02.761226+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
811fd632-e5fb-4af0-bb89-85f022ca56dd	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User viewed Resume (3) (1).pdf	2026-09-02 12:43:10.659398+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a70707fb-b2a5-46a1-9633-886ea0aaf929	Viewed	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	Admin User	Admin User viewed Issues.xlsx	2026-09-02 12:43:22.325332+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5edb3589-5ea6-495f-8e51-6c12706fe9f3	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-03 06:20:11.102239+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
55aaf34f-553f-43d2-8078-6acf22aaf3bf	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-03 06:20:13.208094+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6cc3ab9c-c1d4-49b5-a837-bbeb3fc15645	Uploaded	71b01b98-a936-4f80-a406-ccf5f0f060b0	airQualityAbstactBoth.pdf	Tech	Admin User	Admin User uploaded airQualityAbstactBoth.pdf	2026-09-03 07:05:00.559812+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ac008be4-d584-4ffd-a24b-70f8811ac323	Uploaded	3c1b7fa3-a188-4402-8501-53bf39dd3080	_tmp_sop.txt	Tech	Admin User	Admin User uploaded _tmp_sop.txt	2026-09-02 10:15:55.649353+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
eb511e0f-80d3-4e06-974e-676b2fa0d9e1	Deleted	3c1b7fa3-a188-4402-8501-53bf39dd3080	_tmp_sop.txt	Tech	Admin	Deleted _tmp_sop.txt from Tech	2026-09-02 10:16:45.197166+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aeb41e82-8ac1-4a8f-aa7b-115e9557f341	Deleted	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Deleted TK_Tender Summary(template)_071223.pptx from PMS	2026-09-02 10:19:45.207848+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d5a27bd4-1218-4d11-a7af-c0bf704b6279	Uploaded	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User uploaded Resume (3) (1).pdf	2026-09-02 11:15:59.471482+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
71dd42a6-0a5a-4a64-b505-da24c2528e03	Viewed	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 11:58:44.525181+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8b4c054f-eeef-42e7-bbb4-33089c02be5e	Uploaded	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	Admin User	Admin User uploaded Issues.xlsx	2026-09-02 12:02:50.299125+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0e6210fb-0e1d-424b-9cbc-69a471c43690	Viewed	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	Admin User	Admin User viewed Issues.xlsx	2026-09-02 12:02:54.303738+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
52f81187-8eb6-4624-82cf-be8bd76deb9c	Downloaded	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	admin@acme.co	admin@acme.co downloaded Issues.xlsx	2026-09-02 12:03:16.349611+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
289d8407-b822-4c36-a5ec-55af6f0acf07	Uploaded	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User uploaded Abstract 5716 & 5720.docx	2026-09-02 12:03:52.717377+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5b975b30-dd66-4580-94b3-6c0cb50f3eb3	Viewed	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	Admin User	Admin User viewed Issues.xlsx	2026-09-02 12:42:30.414666+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
129846c5-f2e0-4c66-b963-8780137d2d7d	Viewed	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 12:43:06.442219+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d5706148-f057-404c-a1e7-be40c631505b	Downloaded	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	admin@acme.co	admin@acme.co downloaded Issues.xlsx	2026-09-02 12:43:22.400621+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b5fee407-f14a-47e0-9684-7d57db7e9493	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-03 06:21:23.264365+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: repository_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repository_departments ("RepositoryItemId", "DepartmentId") FROM stdin;
5f35c6be-e98b-42b6-b664-e1940e593328	310a2f16-15f6-4b82-95f6-ab18b5b429f5
71b01b98-a936-4f80-a406-ccf5f0f060b0	13c91c98-00ae-4211-acb8-d06e35953806
71b01b98-a936-4f80-a406-ccf5f0f060b0	310a2f16-15f6-4b82-95f6-ab18b5b429f5
71b01b98-a936-4f80-a406-ccf5f0f060b0	8e4e88f1-e294-4554-80cc-92ed6169caeb
71b01b98-a936-4f80-a406-ccf5f0f060b0	bcbd68c8-c3f3-4396-abb0-0b0e13637958
71b01b98-a936-4f80-a406-ccf5f0f060b0	f7e882f6-2fa8-45e1-9137-2bc4b70f016a
\.


--
-- Data for Name: role_permission_audits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permission_audits ("Id", "RoleId", "RoleName", "ModuleKey", "ModuleLabel", "SubmoduleKey", "SubmoduleLabel", "PermissionKey", "ActionLabel", "ChangeType", "PreviousValue", "NewValue", "ChangedById", "ChangedByName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
88b29a05-b10f-4354-a876-149f136cc2e4	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 12:26:35.149611+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7349d427-c4e7-41d0-b228-2b0286454616	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 12:26:35.257637+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c7fbc590-b862-41ff-844e-404028893696	4e1cb2cf-a453-4b80-9ddc-2c6ee042290b	Admin	settings	Settings	\N	\N	settings.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 12:40:14.213209+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3a19b049-3e32-416e-ab23-3fc4de4dfb99	3de8ba61-fd83-4953-9f9e-11e7450ebccd	Admin (Dhanshree)	settings	Settings	\N	\N	settings.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 12:40:14.57319+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
09c6b7e6-3afa-4f62-80d7-c9c6765bf769	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	timesheets	My Team	\N	Timesheet Approval	timesheets:monitor	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 06:17:13.872233+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
3b86eb60-342c-451e-b690-b52096246d9a	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.edit	Edit	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 06:17:13.872233+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
5df58eb9-c159-4eaf-a477-76a8b655b9d9	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.approve	Approve	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 06:17:13.872233+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
82405a7c-a273-4537-aa53-a73b646ebb92	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.delete	Delete	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 06:17:13.872233+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
a559a2b3-e027-49fa-bf9d-ec03a9ccbea1	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	clients	Customers	\N	\N	clients:read	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 06:17:13.872233+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
c35b8b3c-131c-4ab8-ab72-f7ee38bdd030	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.submit	Submit	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 06:17:13.872233+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
c4d82d2b-13e4-4700-af05-7831feae8837	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	resources	Resources	\N	\N	resources:read	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 06:17:13.872233+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
d8034b9b-9c0d-455d-9e2c-260d034dbc97	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.reject	Reject	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 06:17:13.872233+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
de085f07-fe8f-4879-ac7c-531eba227ae0	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.create	Create	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 06:17:13.872233+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
fbe29092-0025-4ed8-b371-a7df24815955	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	dashboard	Dashboard	\N	\N	dashboard.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-11 13:02:20.869905+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0670eddb-f4c5-4dd1-8bf8-4ee3b4b1e882	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	clients	Customers	\N	\N	clients:read	View	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 06:42:59.550831+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
0da5da82-3835-41d1-8136-75d93db54412	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.create	Create	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 06:42:59.550831+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
19ee29d9-8af2-4505-bf93-8d09beecf4c5	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	timesheets	My Team	\N	Timesheet Approval	timesheets:monitor	View	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 06:42:59.550831+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
3f2a301a-2e36-4222-9178-2534b46a9406	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.view	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 06:42:59.550831+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
4cfa5367-8142-4464-a3cd-2aac5532dc0d	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.reject	Reject	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 06:42:59.550831+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
786e2053-8fed-4d43-a8b6-afbd5edb6e27	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.delete	Delete	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 06:42:59.550831+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
a920b5fd-0845-4ac9-8d3c-a20969d7fe23	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.edit	Edit	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 06:42:59.550831+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
d157430d-9b8c-4ada-b791-139015514bc6	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	resources	Resources	\N	\N	resources:read	View	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 06:42:59.550831+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
d490836a-53a8-4878-a274-7406d1f0276f	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.edit	Edit	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 06:42:59.550831+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
dbeb83dc-772f-4df2-833f-8154a02d3955	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.approve	Approve	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 06:42:59.550831+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
42e77664-6b61-460c-b6c7-a2e9f8a84932	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	action-center	Action Center	\N	\N	action-center.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 16:16:27.51142+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6fcb0cb4-f657-41b7-aa02-c7e5f6c961b3	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	\N	\N	projects:read	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 16:16:27.51142+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bb07b6db-6e82-4d0e-8bfe-fe780955635b	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	resources	Resources	\N	\N	resources:read	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 16:16:27.51142+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") FROM stdin;
34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	["dashboard.view", "projects.view", "projects.create", "projects.overview.view", "projects.overview.edit", "projects.health.view", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.create", "customers.edit", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:write", "projects:write", "wbs:read", "timesheets:submit"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	Sales	Sales & business development ??? new projects and customers.	t	t
3cdaf36a-c349-4239-8533-df54dbdbb770	Team Lead	["dashboard.view", "projects.view", "projects.task.view", "projects.task.update-status", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "issues:raise", "timesheets:submit"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	TeamLead	Leads a delivery team; submits timesheets and raises issues.	t	t
915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-08-07 07:49:59.669429+00	2026-08-13 06:42:59.518317+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	ProjectManager	Runs assigned projects end-to-end; approves team timesheets.	t	t
3de8ba61-fd83-4953-9f9e-11e7450ebccd	Admin (Dhanshree)	["action-center.view", "approvals:manage", "approvals.approve", "approvals.reject", "approvals.view", "audit:read", "clients:approve", "clients:read", "clients:write", "customers.approve", "customers.assign", "customers.create", "customers.delete", "customers.edit", "customers.view", "dashboard.view", "invoices:payment", "invoices:raise", "issues:manage", "issues:raise", "my-team.dashboard.view", "my-team.my-timesheet.edit", "my-team.my-timesheet.submit", "my-team.my-timesheet.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.timesheet-approval.view", "portfolio.view", "projects:close", "projects:read", "projects:write", "projects.alerts.create", "projects.alerts.resolve", "projects.alerts.view", "projects.approve", "projects.assign", "projects.assigned-projects.view", "projects.budget.view", "projects.close", "projects.communication.create", "projects.communication.view", "projects.create", "projects.delete", "projects.edit", "projects.escalation.create", "projects.escalation.resolve", "projects.escalation.view", "projects.export", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.health-issues.view", "projects.health.comment", "projects.health.edit-issue", "projects.health.manage", "projects.health.raise-issue", "projects.health.resolve-issue", "projects.health.view", "projects.import", "projects.invoice-schedule.manage", "projects.invoice-schedule.view", "projects.overview.edit", "projects.overview.view", "projects.pmo.manage", "projects.pmo.view", "projects.prerequisite.manage", "projects.prerequisite.view", "projects.services-deliverables.manage", "projects.services-deliverables.view", "projects.task.assign", "projects.task.create", "projects.task.edit", "projects.task.update-status", "projects.task.view", "projects.team.assign", "projects.team.view", "projects.view", "reports:read", "reports.export", "reports.finance.view", "reports.view", "repository.view", "resources:manage", "resources:read", "resources.directory.view", "resources.kpi.view", "resources.manage", "resources.view", "roles:manage", "settings.audit.view", "settings.permissions.manage", "settings.permissions.view", "settings.roles.manage", "settings.roles.view", "settings.view", "timesheets:approve", "timesheets:monitor", "timesheets:submit", "users:manage", "wbs:allocate", "wbs:read", "wbs.allocate", "wbs.view"]	2026-08-07 07:49:59.669429+00	2026-08-11 06:12:16.314057+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	Dhanshree	Super-admin (legacy account) ??? full access to every module.	t	t
b7271bbe-68a7-4165-996e-869c030c76d3	HOD	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.approve", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "clients:read", "clients:approve", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	Hod	Department oversight across projects, resources and approvals.	t	t
911d3fd2-2e9a-4a85-a79a-49584031c854	HR	["resources.view", "resources.directory.view", "resources.manage", "repository.view", "resources:manage"]	2026-08-07 07:49:59.669429+00	2026-08-11 13:02:20.841494+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Hr	HR resource/directory management only.	t	t
9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	["dashboard.view", "action-center.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "timesheets:submit", "issues:raise"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:26:35.25597+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Employee	Executes assigned tasks; submits own timesheets.	t	t
1312980c-d7e6-4394-930e-477a5ae8ece8	Business Owner	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health-issues.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "portfolio.view", "clients:read", "projects:read", "reports:read"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	BusinessOwner	Executive oversight of the project portfolio.	t	t
a5023c9e-367f-41e1-ba02-bdb2929edc89	Engagement Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	EngagementManager	Owns customer relationship and delivery for assigned accounts.	t	t
da95514a-1975-456d-ad0f-06fe33227e9b	Senior Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "projects:close", "issues:raise", "issues:manage", "timesheets:approve"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	SeniorPm	Owns delivery of assigned projects; approves PM timesheets.	t	t
fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde	PMO	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.budget.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "approvals.view", "wbs.view", "wbs.allocate", "clients:read", "projects:read", "wbs:read", "wbs:allocate", "timesheets:monitor", "issues:manage", "resources:read", "reports:read", "approvals:manage"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	Pmo	Governance, WBS allocation and timesheet monitoring (view-oriented).	t	t
4e1cb2cf-a453-4b80-9ddc-2c6ee042290b	Admin	["dashboard.view", "action-center.view", "projects.view", "projects:read", "projects.create", "projects:write", "projects.edit", "projects:write", "projects.delete", "projects:write", "projects.close", "projects:close", "projects.approve", "projects.assign", "projects.export", "projects.import", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "issues:raise", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health.manage", "issues:manage", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "projects.pmo.view", "projects.pmo.manage", "projects.prerequisite.view", "projects.prerequisite.manage", "projects.services-deliverables.view", "projects.services-deliverables.manage", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "invoices:raise", "invoices:payment", "projects.assigned-projects.view", "reports.view", "reports:read", "reports.export", "reports.finance.view", "resources.view", "resources:read", "resources.manage", "resources:manage", "resources.directory.view", "resources.kpi.view", "customers.view", "clients:read", "customers.create", "clients:write", "customers.edit", "clients:write", "customers.delete", "clients:write", "customers.approve", "clients:approve", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "timesheets:monitor", "my-team.timesheet-approval.approve", "timesheets:approve", "my-team.timesheet-approval.reject", "timesheets:approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit", "my-team.my-timesheet.edit", "wbs.view", "wbs:read", "wbs.allocate", "wbs:allocate", "approvals.view", "approvals:manage", "approvals.approve", "timesheets:approve", "approvals.reject", "timesheets:approve", "portfolio.view", "settings.view", "settings.roles.view", "settings.roles.manage", "roles:manage", "settings.permissions.view", "settings.permissions.manage", "users:manage", "settings.audit.view", "audit:read"]	2026-08-10 12:23:35.786937+00	2026-08-10 12:40:14.170813+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Admin	Super-admin ??? full access to every module, submodule and action.	t	t
cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	["action-center.view", "clients:read", "customers.view", "dashboard.view", "invoices:payment", "invoices:raise", "projects:read", "projects.health.view", "projects.invoice-schedule.manage", "projects.invoice-schedule.view", "projects.overview.view", "projects.view", "reports:read", "reports.export", "reports.finance.view", "reports.view", "repository.view", "resources:read", "resources.directory.view", "resources.kpi.view", "resources.view"]	2026-08-07 07:49:59.669429+00	2026-08-23 16:16:27.401283+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Accounts	Finance ??? invoices, payments and finance reports.	t	t
\.


--
-- Data for Name: sub_ventures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sub_ventures ("Id", "ClientId", "Name", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Notes", "KycDocumentName", "KycDocumentPath") FROM stdin;
03e40de1-c4a7-425b-87ab-7d2b45ec364d	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Clinical Research	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
5fd7f539-0471-41ef-b4f9-f9c72071e117	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Biotech Division	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
fec11a61-59e0-4cfa-b03e-189789ceab63	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Manufacturing	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
15c89a23-7196-48e6-9c9c-0a10cc38cf80	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Global Healthcare	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
adc6d310-c567-4598-8bee-699791ca28cb	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Medical Devices	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
f8c2759e-1526-4499-93fe-4bf9383551a9	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Freight Services	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
b472f090-9382-4fcb-9a13-ad023a2b8edb	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Warehouse Operations	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
f701bcf7-0139-44fe-9188-1e2218afdb10	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith International Logistics	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
fb458d8a-fe51-4a06-a8cc-135b3784da0e	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Fleet Management	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
f453f787-9888-4058-8098-d99b9a89b9e1	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Express Delivery	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
58e5ee34-e198-47b6-9a9e-95903f56b20d	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Renewable Energy	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
d08681c8-6a5b-4c1e-af29-8997fa0e9de3	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Power Distribution	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
a34f1aad-ed5a-4eef-80e7-ffb186ac5a02	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Smart Grid	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
fbc527bd-d4b0-4a18-9ebb-b2ed0752da93	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Solar Division	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
eb5474ee-f271-4b23-b41e-dac2a1905a50	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Energy Consulting	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
8f8671f4-01e4-42d9-ba2e-afc03d0a37d0	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Retail Banking	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
e2868bff-2f6e-41e5-a1fa-6451ca5a7f0f	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Corporate Banking	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
b5f5586f-63f0-4fe2-b864-89937fb76a72	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Digital Payments	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
c973cd24-655e-4de7-98e2-f0627d34696c	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Treasury Services	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
3ea7fd34-bce6-4d9c-868b-380ef2658536	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Wealth Management	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
321598b3-aae4-4d07-a5b0-2e27cec16136	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync AI Platform	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
889e05ef-4311-474b-9d2e-23a7c5516aa2	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Cloud Infrastructure	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
8113f77c-878e-42bc-912b-5a7c388702a4	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Data Engineering	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
42304e00-59f2-4bed-b23b-87c4800caa16	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Machine Learning	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
bd25f3d8-a3a0-4135-a341-e13aeba728b5	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Enterprise Solutions	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
e1b95e8b-302d-4cf3-9ab1-c6f0bd75d394	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Hospital Systems	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
3540c693-d4be-438c-a795-b11c7edd1f84	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Telemedicine	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
8789ae47-e505-4fb3-adf2-04ade91e418c	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Diagnostics	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
ee71d5b9-7d64-4cef-83a8-1195ff484538	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Health Analytics	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
30613fc3-38d9-45c8-9333-72a178f1e2b7	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Patient Services	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
fa9d3ecf-bd5f-4ccb-a03e-b574d8370f11	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Connected Vehicles	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
80d85beb-5a07-40f2-b7ae-2f6168a6755e	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Autonomous Systems	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
bf470ada-eecb-4ed7-9dc0-0c11436d2eec	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive EV Solutions	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
a9afcff9-fadd-4d29-aeab-d83159813cde	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Manufacturing	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
a5ddbee0-90a3-425b-be8d-bcb2b8e1acda	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Smart Mobility	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
857a1e5d-ba2d-4499-9170-866e7f80596c	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Waste Management	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
7958d666-b744-4889-9c26-4d9152b5e23c	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Sustainability Consulting	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
c5b810e0-cf3c-46cf-91ca-615d583f7f9d	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Renewable Projects	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
c2c8966d-d634-45b1-b1e2-c231d2a91c16	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Water Management	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
6e5a495d-40be-4bb8-b40e-2480d3364bd3	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Carbon Solutions	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
116ef6af-75e2-4743-af52-db5f71093752	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit E-Commerce	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
c10b586c-3015-46a1-9ca4-c8a0758788ef	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Hypermarket	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
0d158329-c66c-4427-b5e8-073bfab60dba	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Fashion	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
79de3aae-5152-44f0-9c77-0c54c3fd701d	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Supply Chain	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
9e067c55-cc90-48a0-ab8b-ded41dace8cb	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Digital Commerce	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
ac923fa9-3ecb-4ccb-a755-5b21621eea43	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Digital Banking	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
ed26b19c-dd44-4dbd-931f-32302088e02d	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Payment Solutions	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
7ac571e1-5915-46fb-b36d-64323d485e8a	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Lending	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
4b278fdd-0c00-477a-ac9f-8c3013de4149	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Investment Services	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
cab77d0e-e88a-4056-8712-a5a39ff91cd9	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Risk & Compliance	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N
37f0c3b1-16a1-4643-9f5a-f824204543c1	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	subventure-northwindbank	2026-08-19 06:43:26.578788+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	sfsddf	2026-08-19 07:09:05.842701+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
6b55edc3-064f-468d-9084-54fbd72dc126	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	New Subventure	2026-08-20 10:21:44.125441+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
6a40584b-3bde-4c7d-a6e6-3ef920cd43d0	90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	TATA-subventure	2026-08-20 11:00:13.739957+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
65c6925a-8948-4485-9d93-e596e1f4273e	a04ccf3a-81c8-4416-8af7-068717ddb22b	Morphle Machine desgining	2026-08-20 13:31:53.288995+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
d3af0a54-b527-40ca-ac1e-9fb09fd81504	a04ccf3a-81c8-4416-8af7-068717ddb22b	morphle labs	2026-08-20 13:34:48.394235+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
a69fe228-de12-44e5-9128-dc3898f67e5c	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	IT	2026-08-21 10:05:12.642403+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
a2e2e7fc-4e12-4bd6-85b4-baffcd70c1f3	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	ABC	2026-08-27 09:26:47.572245+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
42bafa20-e45f-4f76-8e20-76bca06df882	14db9d14-dec6-4488-a6ae-d9bab5b2ef48	Test Division	2026-08-28 05:20:20.174418+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	Test division note	\N	\N
4af18ff4-3a01-44e4-b050-9e209643182b	89714d99-8107-4cd0-8095-6da7823cb767	sub cust 1	2026-09-02 07:09:23.899459+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	NA	\N	\N
829211dc-774e-4389-a6c8-b29372b3dde7	08f36c9b-9833-4008-9a58-9b69b5c491e3	SV1	2026-09-02 07:54:30.517916+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
3a681001-620a-4190-bd6c-1ee7131f2c3f	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	ABCDEFG	2026-09-02 10:24:57.074997+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	dfksfklsfkslmf	\N	\N
6cec1e8f-a65e-4c11-8fc3-265376ffe0cc	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	XXXXXXXXX	2026-09-02 11:47:36.563695+00	2026-09-02 11:47:36.954412+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	gkhkjhjk	Issues.xlsx	KYC/20260902_114736_876_AutoDrive_Systems_XXXXXXXXX_Issues.xlsx
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users ("Id", "Email", "PasswordHash", "Name", "EmployeeId", "Department", "SubDepartment", "Avatar", "Designation", "IsActive", "MustChangePassword", "RoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "FailedLoginAttempts", "LastLoginAtUtc", "LockedUntilUtc", "PasswordChangedAtUtc", "AuthProvider", "MicrosoftOid") FROM stdin;
cf106b1b-6a96-464f-aa63-ddcb77a737e0	new.pm@acme.co	$2a$12$p.MfI7wlBAX2LZkpEvPoEunU.q5UljNMmswtXsI80UcJj8X2CVWM.	New PM	u99	\N	\N	\N	PM	t	t	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	2026-08-07 07:55:45.951114+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	0	\N	\N	\N	Local	\N
30d629ff-3076-40f8-9c12-fb385b8c2600	admin2@acme.co	$2a$12$aqJIdIL9tzPW5DFE.zVFVurFkCUE0knMbU7.A0A1pBtjA7K4Qk7wS	Test Admin Two	A2	\N	\N	\N	\N	f	t	3de8ba61-fd83-4953-9f9e-11e7450ebccd	2026-08-07 08:15:16.235641+00	2026-08-07 08:15:23.702021+00	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	0	\N	\N	\N	Local	\N
a1878763-b174-41b0-88db-f2ebba76af83	sdsa@gmail.com	$2a$12$.bzyuW3FFq2Uau84IyFnYO1LXxDLXkbxtjVyvzVs71KECK6u2CONy	sadas	ads	sda	\N	\N	sda	t	t	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 09:30:46.654787+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	0	\N	\N	\N	Local	\N
111775f6-5d80-5333-478e-68e2fda584fa	meera@acme.co	$2a$12$iVxHp.TMFQT6CMyM1zPSW.R4j8DTQ0LjH/m5asAurbpNubsaI.9eO	Meera Joshi	u8	\N	\N	MJ	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-11 11:25:29.999149+00	\N	\N	Local	\N
1a077a8c-4029-8ded-d563-19e9b4bdf301	aarav@acme.co	$2a$12$7iiOuELOCODSQLtQlJBxvuRNKOAuAv99CS6LRj6V7mpeBfvPCtP9K	Aarav Mehta	u1	\N	\N	AM	\N	t	f	da95514a-1975-456d-ad0f-06fe33227e9b	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-17 12:22:51.492258+00	\N	\N	Local	\N
2bca17e7-5b71-8ac3-6c86-440cb3b75bab	vikrant@acme.co	$2a$12$4Pdt4eirX8wdFPf4fbsYS.K7I3v2XBwepME5K0FA0M7mZB6.ZFhfa	Vikrant Malhotra	u13	\N	\N	VM	\N	t	f	1312980c-d7e6-4394-930e-477a5ae8ece8	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-10 06:59:34.903769+00	\N	2026-08-10 06:59:52.170405+00	Local	\N
cdee998d-48e3-4ee3-8d3a-8bb394592377	muskan.khan@talakunchi.com		Muskan Khan	EMP-0024	\N	\N	\N	\N	t	f	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	2026-09-02 13:49:56.363865+00	2026-09-02 13:49:56.492659+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-02 13:49:56.492649+00	\N	\N	Microsoft	iChQlLTN3U6M_5TwAUzGCL3kvk-lL98qkKkolRLXz4Y
304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	anita@acme.co	$2a$12$M6yyh3w6edknpv4zZuS3C.nDRSBjDgeNxBjKPJO/jVKxfhsig0Qc2	Anita Desai	u12	\N	\N	AD	\N	t	f	b7271bbe-68a7-4165-996e-869c030c76d3	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-21 16:45:24.911658+00	\N	\N	Local	\N
6d1e9837-0276-46b5-a0f8-596f155139c8	dhanshree.pansare@squad1.io		Dhanshree Pansare	EMP-0022	\N	\N	\N	\N	t	f	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	2026-09-02 13:36:35.762744+00	2026-09-02 13:37:46.362463+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-02 13:37:46.362439+00	\N	\N	Microsoft	Sjm3sQ3oqL_QkKeIaRJjNGooFHu2Ep6kZSfu3bDFWt4
833a28fc-a624-4cbe-8e71-56c51eb53ab2	harshada.tawade@squad1.io		Harshada Tawde	EMP-0023	\N	\N	\N	\N	t	f	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	2026-09-02 13:42:00.385785+00	2026-09-02 13:42:00.544103+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-02 13:42:00.544091+00	\N	\N	Microsoft	lPJZXPdV3nVq1jRsadsvNIxkWQ9ErILNK93cDwyRfdQ
40517b71-5e62-182e-73b5-d4070e20a3c2	dhanshree@acme.co	$2a$12$rngMdlz3SCySjQMDzjXSQeyPJwvWXiDLKhQG6.nLH5mlVMUB1n7w.	Dhanshree	u14	\N	\N	DS	\N	t	f	3de8ba61-fd83-4953-9f9e-11e7450ebccd	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-09-02 10:02:19.979296+00	\N	2026-08-10 07:02:04.244561+00	Local	\N
47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	hr@acme.co	$2a$12$EihvijcYpRz.mWurt4NEUusPYpc.ou.OUWZwnl/RHYCjGtnBBHiDe	HR User	u16	\N	\N	HU	\N	t	f	911d3fd2-2e9a-4a85-a79a-49584031c854	2026-08-10 12:23:35.786937+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-09-03 09:48:23.138001+00	\N	\N	Local	\N
49c4e7da-23ec-aab1-9fdf-61dd23764d10	nikhil@acme.co	$2a$12$yKP7fWqV5xToJbKTdL.pE.fe9dbGRzrNf68TXtb4RFJ5I5M3I/LuW	Nikhil Rao	u5	\N	\N	NR	\N	t	f	3cdaf36a-c349-4239-8533-df54dbdbb770	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	\N	\N	\N	Local	\N
65e2ffa3-6073-780a-b849-4d9604c7251c	priya@acme.co	$2a$12$EdON1YwvyBPV3Zys7T6d9OQja15nmiOVLZqiy.7B1EHb6D6V0mfWO	Priya Verma	u6	\N	\N	PV	\N	t	f	3cdaf36a-c349-4239-8533-df54dbdbb770	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-10 12:57:13.729958+00	\N	\N	Local	\N
730809c0-fc01-a664-03ca-28e0e32d0393	sales@acme.co	$2a$12$rjsR0rYmES2R1yO0Txiele/JQDxKq5I3n41zgbPPws/qS0ZLmNZoq	Sales User	u18	\N	\N	SU	\N	t	f	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	2026-08-10 12:23:35.786937+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-09-03 09:48:26.843125+00	\N	\N	Local	\N
9f6f34df-dc47-f198-f3f6-e577aab1cbca	dev@acme.co	$2a$12$JE9tivlXL9DLJSFiwD0ajeclpMomizbb0CZDG9FZKlH/5JFo7OqMW	Dev Patel	u9	\N	\N	DP	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-11 06:20:37.412783+00	\N	2026-08-10 06:57:47.765224+00	Local	\N
a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	admin@acme.co	$2a$12$C1.RSFWKTSubiB0H5aZZHeeTO57u8GiTR26LpNU9aqS0h5j6tQ9eu	Admin User	u15	\N	\N	AU	\N	t	f	4e1cb2cf-a453-4b80-9ddc-2c6ee042290b	2026-08-10 12:23:35.786937+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-09-03 12:47:27.34062+00	\N	\N	Local	\N
a37e30de-15f3-bf1e-fa9f-4a98da9033ab	vikram@acme.co	$2a$12$XomfSslmBrT8Rgca9XCNbed6xplI2a0dioBFDTh5RU8uO3BVCIOAW	Vikram Shah	u3	\N	\N	VS	\N	t	f	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-20 05:22:57.26898+00	\N	\N	Local	\N
a3a20ac4-43a2-de64-52d3-bfafce7c7053	sana@acme.co	$2a$12$yG3JPQTM7WUih458LoZ6bOMAR5fzfHZGXyM.9/BatNecOIEUjMoyq	Sana Iyer	u4	\N	\N	SI	\N	t	f	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-17 07:09:47.329355+00	\N	\N	Local	\N
b1d3f51c-b209-d352-4b52-3f4008801ab3	kavya@acme.co	$2a$12$xnHEVMZ7WaAvtKmdLygrGelTHEillWCAA2VgJilA5FW3GMu0ItiH6	Kavya Nair	u10	\N	\N	KN	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-11 11:51:44.284921+00	\N	\N	Local	\N
d1130837-5c69-40b6-a65f-913214e66693	sahil.lad@talakunchi.in		Sahil Lad	EMP-0025	\N	\N	\N	\N	t	f	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	2026-09-03 09:47:54.557246+00	2026-09-03 09:50:09.746059+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-03 09:50:09.746032+00	\N	\N	Microsoft	fMKLFL3FPWkLLODUgmnxV0EWlxyoBVNVRa6NVcDMw8k
b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	rahul@acme.co	$2a$12$DY2Tynr0b90i2d0qA/0AoeuHTeqI6sUf.7H1bFvrI/WpWPsyn5z0.	Rahul Gupta	u11	\N	\N	RG	\N	t	f	fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-23 19:07:26.049628+00	\N	\N	Local	\N
dc139a9d-b996-7354-6c27-72659ea2fd59	accounts@acme.co	$2a$12$4L9XZ9YBvfa45wq3obmbj.D0Gww82IIi3aT3DeY0a5MujU8ToBHqO	Accounts User	u17	\N	\N	AC	\N	t	f	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-08-10 12:23:35.786937+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-23 16:17:59.549139+00	\N	\N	Local	\N
e7554ba2-e546-93ce-1e88-a073badd78a2	riya@acme.co	$2a$12$oNUP6O.3OFGUxT0QLM7D0em47CwJGLHiz3V5Febc.1zGj56A9uv1a	Riya Kapoor	u2	\N	\N	RK	\N	t	f	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-08-07 07:57:04.148765+00	\N	2026-08-07 07:57:03.565302+00	Local	\N
f2f23eb1-efb6-f0a7-c57e-0ead09121a21	arjun@acme.co	$2a$12$VgEHBLHQpb.Q72lBQk0b8.VPDAtXDcpCoFIHBYn8UlOxofhoJxaY2	Arjun Singh	u7	\N	\N	AS	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 07:49:59.669429+00	2026-09-03 12:57:25.654307+00	\N	\N	\N	0	2026-09-03 07:05:49.13962+00	\N	\N	Local	\N
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
-- Name: mst_entra_roles PK_mst_entra_roles; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_entra_roles
    ADD CONSTRAINT "PK_mst_entra_roles" PRIMARY KEY ("Id");


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
-- Name: repository_departments PK_repository_departments; Type: CONSTRAINT; Schema: public; Owner: postgres
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
-- Name: users PK_users; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_users" PRIMARY KEY ("Id");


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
-- Name: mst_email_domains mst_email_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_email_domains
    ADD CONSTRAINT mst_email_domains_pkey PRIMARY KEY ("Id");


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
-- Name: IX_employees_JobRoleId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_employees_JobRoleId" ON public.employees USING btree ("JobRoleId");


--
-- Name: IX_employees_NationalityId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_employees_NationalityId" ON public.employees USING btree ("NationalityId");


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
-- Name: IX_mst_entra_roles_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_entra_roles_Code" ON public.mst_entra_roles USING btree ("Code");


--
-- Name: IX_mst_entra_roles_EntraRoleValue; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_entra_roles_EntraRoleValue" ON public.mst_entra_roles USING btree ("EntraRoleValue");


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
-- Name: IX_repository_departments_DepartmentId; Type: INDEX; Schema: public; Owner: postgres
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
-- Name: repository_departments FK_repository_departments_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repository_departments
    ADD CONSTRAINT "FK_repository_departments_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES public.mst_departments("Id") ON DELETE CASCADE;


--
-- Name: repository_departments FK_repository_departments_repository_RepositoryItemId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
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
-- Name: users FK_users_roles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "FK_users_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public.roles("Id") ON DELETE RESTRICT;


--
-- Name: mst_offices mst_offices_WorkLocationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mst_offices
    ADD CONSTRAINT "mst_offices_WorkLocationId_fkey" FOREIGN KEY ("WorkLocationId") REFERENCES public.mst_work_locations("Id") ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict LfjcLBnssjF6328nS5LVttVdYEYlBbsjbRhdoW1eFtHvD5gvssTcfB66RtXhFjw

