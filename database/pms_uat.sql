--
-- PostgreSQL database dump
--

\restrict wDw0bsBnYqClqUpxHNmeia1hRq0ZVL4VZS39sCWudtrgpDDsweopECLjqyTh9YU

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

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: customer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA customer;


--
-- Name: master; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA master;


--
-- Name: project; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA project;


--
-- Name: repository; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA repository;


--
-- Name: resource; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA resource;


--
-- Name: timesheet; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA timesheet;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: log_role_permission_audits; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.log_role_permission_audits (
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


--
-- Name: tbl_refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.tbl_refresh_tokens (
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


--
-- Name: tbl_role_permissions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.tbl_role_permissions (
    "Id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "RoleId" uuid NOT NULL,
    "ItemId" uuid NOT NULL,
    "ItemType" character varying(20) NOT NULL,
    "CanView" smallint DEFAULT 0 NOT NULL,
    "CanManage" smallint DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "CHK_role_perm_can_manage" CHECK (("CanManage" = ANY (ARRAY[0, 1]))),
    CONSTRAINT "CHK_role_perm_can_view" CHECK (("CanView" = ANY (ARRAY[0, 1]))),
    CONSTRAINT "CHK_role_perm_manage_requires_view" CHECK ((("CanManage" = 0) OR ("CanView" = 1)))
);


--
-- Name: tbl_roles; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.tbl_roles (
    "Id" uuid NOT NULL,
    "DisplayName" character varying(100) NOT NULL,
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


--
-- Name: tbl_users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.tbl_users (
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


--
-- Name: tbl_client_assignments; Type: TABLE; Schema: customer; Owner: -
--

CREATE TABLE customer.tbl_client_assignments (
    "ClientId" uuid NOT NULL,
    "UserId" uuid NOT NULL
);


--
-- Name: tbl_client_contacts; Type: TABLE; Schema: customer; Owner: -
--

CREATE TABLE customer.tbl_client_contacts (
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


--
-- Name: tbl_clients; Type: TABLE; Schema: customer; Owner: -
--

CREATE TABLE customer.tbl_clients (
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
    "GroupSpocContact" character varying(40),
    "ClientCode" character varying(20),
    "CreatedByName" character varying(150),
    "GroupSpocPhoneCode" character varying(16)
);


--
-- Name: tbl_sub_ventures; Type: TABLE; Schema: customer; Owner: -
--

CREATE TABLE customer.tbl_sub_ventures (
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
    "KycDocumentPath" character varying(500),
    "SubVentureCode" character varying(32) NOT NULL
);


--
-- Name: mst_address_cities; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_address_cities (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Line" character varying(80),
    "IsActive" boolean NOT NULL,
    "SortOrder" integer NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: mst_business_units; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_business_units (
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


--
-- Name: mst_certifications; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_certifications (
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


--
-- Name: mst_cities; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_cities (
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


--
-- Name: mst_contact_designations; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_contact_designations (
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


--
-- Name: mst_contact_types; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_contact_types (
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


--
-- Name: mst_countries; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_countries (
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


--
-- Name: mst_departments; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_departments (
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


--
-- Name: mst_designation_sub_departments; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_designation_sub_departments (
    "Id" uuid NOT NULL,
    "DesignationId" uuid NOT NULL,
    "SubDepartmentId" uuid NOT NULL
);


--
-- Name: mst_designations; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_designations (
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
    "SubDepartment" text,
    "DefaultRoleId" uuid
);


--
-- Name: mst_email_domains; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_email_domains (
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


--
-- Name: mst_employee_statuses; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_employee_statuses (
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


--
-- Name: mst_graduation_degrees; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_graduation_degrees (
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


--
-- Name: mst_industries; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_industries (
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


--
-- Name: mst_modules; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_modules (
    "Id" uuid NOT NULL,
    "Code" character varying(40) NOT NULL,
    "Name" character varying(80) NOT NULL,
    "Route" character varying(120),
    "IconKey" character varying(40) NOT NULL,
    "SortOrder" integer NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: mst_nationalities; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_nationalities (
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


--
-- Name: mst_offices; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_offices (
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


--
-- Name: mst_onfloorrole_sub_departments; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_onfloorrole_sub_departments (
    "Id" uuid NOT NULL,
    "OnFloorRoleId" uuid NOT NULL,
    "SubDepartmentId" uuid NOT NULL
);


--
-- Name: mst_org_role_map; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_org_role_map (
    "Id" uuid NOT NULL,
    "DepartmentId" uuid,
    "DesignationId" uuid NOT NULL,
    "RbacRoleId" uuid,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "SubDepartmentId" uuid,
    "SubDepartment" character varying(250)
);


--
-- Name: mst_org_role_sub_departments; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_org_role_sub_departments (
    "Id" uuid NOT NULL,
    "OrgRoleMapId" uuid NOT NULL,
    "SubDepartmentId" uuid NOT NULL
);


--
-- Name: mst_post_graduation_degrees; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_post_graduation_degrees (
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


--
-- Name: mst_rbac_baseline; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_rbac_baseline (
    "Version" character varying(40) NOT NULL,
    "AppliedAtUtc" timestamp with time zone NOT NULL
);


--
-- Name: mst_reporting_managers; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_reporting_managers (
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


--
-- Name: mst_salary_bands; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_salary_bands (
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


--
-- Name: mst_service_catalog; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_service_catalog (
    "Id" uuid NOT NULL,
    "Code" character varying(50) NOT NULL,
    "Name" character varying(255) NOT NULL,
    "SubDepartmentId" uuid NOT NULL,
    "DefaultTools" character varying(500),
    "DefaultUnitPrice" numeric(18,2),
    "DefaultDurationDays" integer,
    "Description" text,
    "IsActive" boolean DEFAULT true NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: mst_service_departments; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_service_departments (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "GroupId" uuid NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: mst_service_groups; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_service_groups (
    "Id" uuid NOT NULL,
    "Code" character varying(40) NOT NULL,
    "Name" character varying(100) NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: mst_service_sub_departments; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_service_sub_departments (
    "Id" uuid NOT NULL,
    "Code" character varying(120) NOT NULL,
    "Name" character varying(200) NOT NULL,
    "DepartmentId" uuid NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: mst_sub_departments; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_sub_departments (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(250) NOT NULL,
    "IsActive" boolean NOT NULL,
    "DepartmentId" uuid,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: mst_submodules; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_submodules (
    "Id" uuid NOT NULL,
    "Code" character varying(60) NOT NULL,
    "Name" character varying(80) NOT NULL,
    "Route" character varying(120),
    "SortOrder" integer NOT NULL,
    "IsActive" boolean NOT NULL,
    "ModuleId" uuid,
    "ParentId" uuid,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "CK_mst_submodules_OneParent" CHECK (((("ModuleId" IS NOT NULL) AND ("ParentId" IS NULL)) OR (("ModuleId" IS NULL) AND ("ParentId" IS NOT NULL))))
);


--
-- Name: mst_tabs; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_tabs (
    "Id" uuid NOT NULL,
    "Code" character varying(60) NOT NULL,
    "Name" character varying(120) NOT NULL,
    "SortOrder" integer NOT NULL,
    "IsActive" boolean NOT NULL,
    "ModuleId" uuid,
    "TabId" uuid,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "SubModuleId" uuid,
    CONSTRAINT "CK_mst_tabs_OneParent" CHECK (((("ModuleId" IS NOT NULL) AND ("SubModuleId" IS NULL) AND ("TabId" IS NULL)) OR (("ModuleId" IS NULL) AND ("SubModuleId" IS NOT NULL) AND ("TabId" IS NULL)) OR (("ModuleId" IS NULL) AND ("SubModuleId" IS NULL) AND ("TabId" IS NOT NULL))))
);


--
-- Name: mst_widgets; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_widgets (
    "Id" uuid NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(160) NOT NULL,
    "SortOrder" integer NOT NULL,
    "IsActive" boolean NOT NULL,
    "ParentId" uuid NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "ParentWidgetId" uuid
);


--
-- Name: mst_work_locations; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_work_locations (
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


--
-- Name: log_project_task_assignments; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.log_project_task_assignments (
    "Id" uuid NOT NULL,
    "TaskId" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "Action" character varying(20) NOT NULL,
    "ResourceName" character varying(200) NOT NULL,
    "TeamType" character varying(30) NOT NULL,
    "OccurredAtUtc" timestamp with time zone NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_documents; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_documents (
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
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_drafts; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_drafts (
    "Id" uuid NOT NULL,
    "ProjectName" character varying(255) NOT NULL,
    "ClientId" uuid,
    "ClientName" character varying(255),
    "SalesPerson" character varying(150),
    "FormSnapshotJson" jsonb NOT NULL,
    "CreatedByName" character varying(150) NOT NULL,
    "UpdatedByName" character varying(150),
    "Status" character varying(40) DEFAULT 'active'::character varying NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_extension_approvers; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_extension_approvers (
    "Id" uuid NOT NULL,
    "ExtensionRequestId" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "EmployeeName" character varying(200) NOT NULL,
    "Status" character varying(20) NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_extension_requests; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_extension_requests (
    "Id" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "CurrentEndDate" date NOT NULL,
    "RequestedEndDate" date NOT NULL,
    "ExtensionDays" integer NOT NULL,
    "Reason" text NOT NULL,
    "Status" character varying(20) NOT NULL,
    "RequestedByEmployeeId" uuid,
    "RequestedByName" character varying(200) NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_interviews; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_interviews (
    "Id" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "ResourceName" character varying(200) NOT NULL,
    "InterviewDate" date NOT NULL,
    "InterviewTime" time without time zone NOT NULL,
    "Result" character varying(20) NOT NULL,
    "Comments" text,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_invoices; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_invoices (
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
    "ServiceName" character varying(255),
    "Qty" integer,
    "UnitPrice" numeric(18,2),
    "Currency" character varying(10),
    "ResourceLevel" character varying(500),
    "PaymentStatus" character varying(40)
);


--
-- Name: tbl_project_service_escalation_stakeholders; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_service_escalation_stakeholders (
    "Id" uuid NOT NULL,
    "EscalationId" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "EmployeeName" character varying(200) NOT NULL,
    "SubDepartment" character varying(160) NOT NULL,
    "Status" character varying(20) NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_service_escalations; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_service_escalations (
    "Id" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "ProjectServiceId" uuid,
    "ProjectCode" character varying(40),
    "ProjectName" character varying(300) NOT NULL,
    "CustomerName" character varying(200),
    "ServiceName" character varying(200) NOT NULL,
    "EscalationType" character varying(80) NOT NULL,
    "Priority" character varying(20) NOT NULL,
    "Subject" character varying(300) NOT NULL,
    "Description" text NOT NULL,
    "ExpectedResolutionDate" date,
    "AttachmentFileName" character varying(260),
    "AttachmentPath" character varying(500),
    "AttachmentContentType" character varying(120),
    "AttachmentSizeBytes" bigint,
    "Status" character varying(20) NOT NULL,
    "RaisedByEmployeeId" uuid,
    "RaisedByName" character varying(200) NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_services; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_services (
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
    "BillingStatus" character varying(40) DEFAULT 'Advance Pending'::character varying NOT NULL,
    "CollectionStatus" character varying(40) DEFAULT 'Pending To Collect'::character varying NOT NULL,
    "IsReady" boolean DEFAULT false NOT NULL,
    "ValidationStatus" character varying(40) DEFAULT 'Pending To Validate'::character varying NOT NULL
);


--
-- Name: tbl_project_task_assignments; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_task_assignments (
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
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_tasks; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_tasks (
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
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_team_members; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_team_members (
    "Id" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "DepartmentId" uuid,
    "SubDepartment" character varying(200),
    "AllocationStartDate" date NOT NULL,
    "AllocationEndDate" date NOT NULL,
    "Billability" character varying(40) NOT NULL,
    "IsTeamLead" boolean NOT NULL,
    "ResourceType" character varying(40) NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "IsShadowTeam" boolean DEFAULT false NOT NULL,
    "MemberRole" character varying(40) DEFAULT 'ProjectTeam'::character varying NOT NULL
);


--
-- Name: tbl_projects; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_projects (
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
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


--
-- Name: log_repository_activity; Type: TABLE; Schema: repository; Owner: -
--

CREATE TABLE repository.log_repository_activity (
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


--
-- Name: tbl_repository_departments; Type: TABLE; Schema: repository; Owner: -
--

CREATE TABLE repository.tbl_repository_departments (
    "RepositoryItemId" uuid NOT NULL,
    "DepartmentId" uuid NOT NULL
);


--
-- Name: tbl_repository_items; Type: TABLE; Schema: repository; Owner: -
--

CREATE TABLE repository.tbl_repository_items (
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


--
-- Name: log_employee_activity; Type: TABLE; Schema: resource; Owner: -
--

CREATE TABLE resource.log_employee_activity (
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


--
-- Name: tbl_employees; Type: TABLE; Schema: resource; Owner: -
--

CREATE TABLE resource.tbl_employees (
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
    "ProjectSite" character varying(80),
    "EngagementManagerEmployeeId" uuid,
    "ProjectManagerId" uuid,
    "SubDepartmentId" uuid
);


--
-- Name: tbl_exited_employees; Type: TABLE; Schema: resource; Owner: -
--

CREATE TABLE resource.tbl_exited_employees (
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


--
-- Name: tbl_onfloorrole; Type: TABLE; Schema: resource; Owner: -
--

CREATE TABLE resource.tbl_onfloorrole (
    "Id" uuid NOT NULL,
    "Name" character varying(150) NOT NULL,
    "DepartmentId" uuid,
    "DesignationId" uuid NOT NULL,
    "SubDepartment" character varying(250),
    "RbacRoleId" uuid,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_onfloorrole_subdepartment; Type: VIEW; Schema: resource; Owner: -
--

CREATE VIEW resource.tbl_onfloorrole_subdepartment AS
 SELECT "Id",
    "OnFloorRoleId",
    "SubDepartmentId"
   FROM master.mst_onfloorrole_sub_departments;


--
-- Name: tbl_team_day_entries; Type: TABLE; Schema: timesheet; Owner: -
--

CREATE TABLE timesheet.tbl_team_day_entries (
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


--
-- Name: tbl_team_member_holidays; Type: TABLE; Schema: timesheet; Owner: -
--

CREATE TABLE timesheet.tbl_team_member_holidays (
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


--
-- Name: tbl_team_member_schedules; Type: TABLE; Schema: timesheet; Owner: -
--

CREATE TABLE timesheet.tbl_team_member_schedules (
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


--
-- Name: tbl_timesheet_entries; Type: TABLE; Schema: timesheet; Owner: -
--

CREATE TABLE timesheet.tbl_timesheet_entries (
    "Id" uuid NOT NULL,
    "TimesheetWeekId" uuid NOT NULL,
    "ProjectKey" character varying(64) NOT NULL,
    "TaskKey" character varying(64) NOT NULL,
    "ProjectName" character varying(200) NOT NULL,
    "TaskName" character varying(200) NOT NULL,
    "ReviewDecision" character varying(32),
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_timesheet_entry_days; Type: TABLE; Schema: timesheet; Owner: -
--

CREATE TABLE timesheet.tbl_timesheet_entry_days (
    "Id" uuid NOT NULL,
    "TimesheetEntryId" uuid NOT NULL,
    "DayIndex" smallint NOT NULL,
    "Hours" numeric(4,1) NOT NULL,
    "Comment" character varying(1000),
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_timesheets; Type: TABLE; Schema: timesheet; Owner: -
--

CREATE TABLE timesheet.tbl_timesheets (
    "Id" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "WeekStart" date NOT NULL,
    "Status" character varying(32) NOT NULL,
    "TotalHours" numeric(6,1) NOT NULL,
    "SubmittedAtUtc" timestamp with time zone,
    "ReviewedByEmployeeId" uuid,
    "ReviewedAtUtc" timestamp with time zone,
    "ReviewComment" character varying(200),
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Data for Name: log_role_permission_audits; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.log_role_permission_audits ("Id", "RoleId", "RoleName", "ModuleKey", "ModuleLabel", "SubmoduleKey", "SubmoduleLabel", "PermissionKey", "ActionLabel", "ChangeType", "PreviousValue", "NewValue", "ChangedById", "ChangedByName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
42e77664-6b61-460c-b6c7-a2e9f8a84932	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	action-center	Action Center	\N	\N	action-center.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 16:16:27.51142+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6fcb0cb4-f657-41b7-aa02-c7e5f6c961b3	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	\N	\N	projects:read	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 16:16:27.51142+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bb07b6db-6e82-4d0e-8bfe-fe780955635b	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	resources	Resources	\N	\N	resources:read	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 16:16:27.51142+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
05c49aad-1095-4818-add4-32fa84082dc1	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	task	Task	projects.task.update-status	Update Status	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:13:06.054728+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1733bf99-627c-417e-a57b-b13ffe29148d	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:13:06.054728+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2d033bf5-fdc2-42bb-9931-f86c5949529d	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	issues	Projects	\N	Health	issues:raise	Raise Issue	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:13:06.054728+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
51a3a178-8f8e-48e7-a845-524b3ff0fcae	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.edit	Edit	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:13:06.054728+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5ff7e23a-7b0d-4a8b-a4ae-0da0d835122b	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	health	Health	projects.health.raise-issue	Raise Issue	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:13:06.054728+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6e01c353-2fd4-4dff-8249-6e27e4c8afbd	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:13:06.054728+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
84f7ef35-1851-4c4a-80b1-6b777f8ecac3	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	assigned-projects	Assigned Projects	projects.assigned-projects.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:13:06.054728+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
91ae3d23-316a-43f1-bfb3-40957935cf4f	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	resources	Resources	\N	\N	resources.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:13:06.054728+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9dfe3162-1998-41cb-aafd-f111b277c0ea	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	task	Task	projects.task.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:13:06.054728+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d4757dcc-c031-46bf-8f0c-66bf5edddec8	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	dashboard	Team Dashboard	my-team.dashboard.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:13:06.054728+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fefd331b-34c2-4a84-8775-2d9b1e1e390d	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.submit	Submit	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:13:06.054728+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b0b4113b-9855-4d46-8377-a35b2c49bfca	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	dashboard	Dashboard	\N	\N	dashboard.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:14:42.879328+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
01eaa87e-b30f-435e-892a-8952f12f6386	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	task	Task	projects.task.update-status	Update Status	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0dcc58d3-5dd6-4a07-b0d9-2ad7d37711ee	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	issues	Projects	\N	Health	issues:raise	Raise Issue	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1271b0da-d674-4e10-9821-1e62ab0f3068	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1315f980-4ed5-4c43-83ec-5f6aa689c49b	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	health	Health	projects.health.raise-issue	Raise Issue	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
33ccba51-399d-4d62-b1e5-96cf30389e3d	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.edit	Edit	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
389067ad-a8cd-4a24-af41-f67a54109c94	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	dashboard	Dashboard	\N	\N	dashboard.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3ab34a77-cefe-4ed5-b954-bb38a7d90a8b	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	dashboard	Team Dashboard	my-team.dashboard.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4f34730e-2006-4d22-af0b-c55ae1ed64b3	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	resources	Resources	\N	\N	resources.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6e71be31-cb0e-4759-8be4-b20deb41a141	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	task	Task	projects.task.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
84feeb98-6ae5-4431-9aca-5a79b0fb7e40	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b16763e4-418a-4b89-aafe-a3f62fda10ac	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	assigned-projects	Assigned Projects	projects.assigned-projects.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fb1375b3-e030-4f6b-b72e-0ac57575c2f8	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.submit	Submit	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 11:39:30.642673+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9b9d1369-1be2-4d08-93e1-c74adfbbab60	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 08:20:52.546121+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
48699c8d-337f-40d7-978b-08f013292cfe	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 08:22:39.00777+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cce747af-d456-45f8-9fc1-5187730faee2	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 08:22:39.279174+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a3b26c22-430d-4ecd-948a-6fda3234daea	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 08:25:02.959476+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f2806c70-4cde-4ff9-be76-72b378741f0e	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 08:25:03.164922+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f4e3e67d-e5b7-4b0a-805a-6568229b7aea	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Reset to Default Baseline	RESET_BASELINE			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 08:25:03.38429+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
68cac5a9-e106-4d62-883a-98ead9bab0c2	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Reset to Default Baseline	RESET_BASELINE			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 08:37:47.625584+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
11d7e5bf-8ffb-40c0-9d16-fec649025984	a5023c9e-367f-41e1-ba02-bdb2929edc89	EngagementManager			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 08:52:43.198144+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cff40133-2e5e-4006-8691-83cb93433b17	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 10:27:17.641161+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
36d34a52-314b-40ef-947a-b6b626c408ae	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 11:02:48.273309+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
90cb5fa5-4161-4a48-b173-fdba8cc6670d	b552183f-2695-41f9-860e-16d5fe94c4aa	IT Admin			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 12:18:50.646463+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f50addee-19db-494b-a234-7fdb2413c8a4	bb568e26-548b-4ca5-9221-fefb9c9143b3	HR			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 12:23:03.010665+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: tbl_refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.tbl_refresh_tokens ("Id", "UserId", "TokenHash", "ExpiresAtUtc", "RevokedAtUtc", "ReplacedByTokenHash", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_role_permissions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.tbl_role_permissions ("Id", "RoleId", "ItemId", "ItemType", "CanView", "CanManage", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
531b14e6-e9e4-4478-9106-500c8dd16d31	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-10-24 16:50:27.272824+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
f009aa13-5eb1-4b71-a862-906a8f46d58a	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-10-24 16:50:27.272824+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
16c48db4-6db8-4932-b7d6-4dcf44bc119d	64c49f37-a38a-46a6-9622-7427f1501658	c04c546e-0f2c-448d-b634-5d517843d365	module	1	1	2026-10-25 20:35:55.763886+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
3f6dc1f9-cec6-4134-8652-27f760a593db	a5bfe265-981a-4723-b7bb-6ddc389db7f0	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-10-25 20:59:30.382444+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
5347f988-49e6-4543-b048-f52614a21e89	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c04c546e-0f2c-448d-b634-5d517843d365	module	1	1	2026-10-25 20:59:30.382444+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
993d8897-978c-4382-bb12-7fd7b1a02943	a5bfe265-981a-4723-b7bb-6ddc389db7f0	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-10-25 20:59:30.382444+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
1dade482-bfd0-4d48-a210-7a2c4bb6be8b	bb568e26-548b-4ca5-9221-fefb9c9143b3	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	1	2026-10-26 13:14:50.230654+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
3f12ec0c-b26a-4965-a13c-9eed59b3deb9	bb568e26-548b-4ca5-9221-fefb9c9143b3	c04c546e-0f2c-448d-b634-5d517843d365	module	1	1	2026-10-26 13:14:50.230654+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
50b6e7d9-6ccf-46b9-96b0-b45f88cc74e8	bb568e26-548b-4ca5-9221-fefb9c9143b3	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-10-26 13:14:50.230654+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
53b41c9c-7570-4d4d-b738-39585fcf87ba	bb568e26-548b-4ca5-9221-fefb9c9143b3	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	1	2026-10-26 13:14:50.230654+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
6e06e53a-8dad-4222-acfa-872193545544	bb568e26-548b-4ca5-9221-fefb9c9143b3	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-10-26 13:14:50.230654+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
86a6095c-763f-4eb9-b77a-e5695e902dc6	bb568e26-548b-4ca5-9221-fefb9c9143b3	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-10-26 13:14:50.230654+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: tbl_roles; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.tbl_roles ("Id", "DisplayName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") FROM stdin;
a0000000-0000-0000-0000-000000000001	Admin	2026-09-25 04:41:26.317908+00	2026-09-25 05:11:29.711189+00	\N	\N	\N	Admin	Super-admin — full access to every module, submodule and action.	t	t
914d8500-03b6-4a43-a250-244effca1cf1	Sales - Manager	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	Sales Manager	Customer onboarding, client management, proposal drafting, pipeline.	t	t
64e2ea37-cbd7-4127-b65b-3b003235981a	PM - Team Member	2026-10-21 09:37:57.51344+00	\N	\N	\N	\N	PM - Team Member	Project management team member.	t	t
92aa9169-28d9-4754-a570-553b067642ed	Testing - Team Member	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	Testing-Team Member	Test execution, defect logging, task status updates, own timesheets.	t	t
c787fe3b-4b33-40ee-8794-c1148202f81a	Testing - HOD	2026-09-24 12:13:06.784762+00	2026-10-21 11:34:24.175956+00	\N	\N	\N	Testing HOD	Complete oversight of Testing department, health escalations, approvals.	t	t
1a62b1f8-1810-464d-a67b-168d7e419827	SOC - Team Member	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	SOC-Team Member	SIEM monitoring, alert analysis, shift logs, own timesheets.	t	t
29ad5710-1621-4c24-ac75-dedfc168ba1a	Testing - Manager	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	Testing-Manager	QA project tasks, test deliverables, defect tracking, QA timesheets.	t	t
3d068c2f-d0a1-4045-bad9-0f3a43efec4f	SOC - HOD	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	SOC-HOD	Complete oversight of SOC/Operations, 24/7 monitoring governance.	t	t
64c49f37-a38a-46a6-9622-7427f1501658	Consulting - HOD	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	Consulting-HOD	Complete oversight of Consulting department, GRC engagements.	t	t
768a11f9-ded7-4f6f-ba86-073e279255d9	Consulting - Team member	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	Consulting-Team member	Audit checklists, evidence collection, task updates, own timesheets.	t	t
7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	Sales - Team Member	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	Sales team member	Proposal drafting, pipeline viewing, sales reports.	t	t
a3793f87-7f3c-41a1-a675-236fc1b710ab	Testing - Team Leader	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	Testing-Team Leader	Test run execution, defect triage, test task assignment, timesheet review.	t	t
aba61e5b-422a-4461-b9da-8dba8f6d3f85	SOC - Team Leader	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	SOC-Team Leader	Shift oversight, alert escalation, task assignments, timesheet review.	t	t
b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	SOC - Senior Manager	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	SOC-Senior Manager	Operations delivery oversight, client SLA tracking, incident reviews.	t	t
f29af015-7833-4f9a-ac57-6fbef5bf91ec	Intern	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Intern	Read-only training access to assigned tasks and document repository.	t	t
4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	Consulting - Senior Manager	2026-09-24 12:13:06.784762+00	2026-10-21 11:31:47.636663+00	\N	\N	\N	Consulting-Senior Manager	Delivery oversight across consulting & audit projects.	t	t
2acf8b94-0756-4db8-bb6f-8372ac04a2d1	PMO (Project Management Office)	2026-09-24 12:13:06.784762+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	PMO	Global governance, WBS allocation, timesheet monitoring, approvals.	t	t
62a927b7-9fd8-461a-b64e-1aa441eeba4d	CEO	2026-09-24 12:13:06.784762+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	CEO	Global executive visibility, business analytics, all approvals.	t	t
66e48815-4d4f-41d0-9c5f-26a7b7ba296c	CTO	2026-09-24 12:13:06.784762+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	CTO	Technical architecture, R&D governance, engineering oversight.	t	t
111cc3cd-6d35-43ce-be91-dde90d3d4015	SOC - Manager	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	SOC-Manager	Incident management, shift scheduling, operations timesheets.	t	t
a5023c9e-367f-41e1-ba02-bdb2929edc89	EM (Engagement Manager)	2026-08-07 07:49:59.669429+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	EngagementManager	Customer relationship, client project overview, health & escalations.	t	t
a5bfe265-981a-4723-b7bb-6ddc389db7f0	COO	2026-09-24 12:13:06.784762+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	COO	Operational oversight across all departments and projects.	t	t
b552183f-2695-41f9-860e-16d5fe94c4aa	IT Admin	2026-09-24 12:13:06.784762+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	IT Admin	IT infrastructure, corporate email domains, device & user setup.	t	t
bb568e26-548b-4ca5-9221-fefb9c9143b3	HR	2026-09-24 12:13:06.784762+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	HR	Employee directory, onboarding/offboarding, skills, KPI/rating tabs.	t	t
701aaa2c-a899-4def-bf5f-e17511874409	Consulting - Team Leader	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	Consulting-Team Leader	Senior audit execution, audit task assignment, timesheet review.	t	t
cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts	2026-08-07 07:49:59.669429+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Accounts	Invoicing schedule, milestone payments, PO tracking, financial reports.	t	t
e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	Consulting - Manager	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	Consulting-Manager	GRC audit projects, client deliverables, audit timesheet approvals.	t	t
efc1df20-ca04-44a6-87b2-7cae1ff50a88	Testing - Senior Manager	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	Testing Senior Manager	Delivery oversight across testing projects, QA resource management.	t	t
f5c742d1-e0cc-4bf8-b860-a673ac407393	R&D - Team member	2026-09-24 12:13:06.784762+00	2026-10-22 07:51:07.556154+00	\N	\N	\N	R&D - Team member	Python/Tool development, sprint tasks, code repository, own timesheets.	t	t
\.


--
-- Data for Name: tbl_users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.tbl_users ("Id", "Email", "PasswordHash", "Name", "EmployeeId", "Department", "SubDepartment", "Avatar", "Designation", "IsActive", "MustChangePassword", "RoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "FailedLoginAttempts", "LastLoginAtUtc", "LockedUntilUtc", "PasswordChangedAtUtc", "AuthProvider", "MicrosoftOid") FROM stdin;
8af256a2-4662-411e-b46a-f2ad8a27565b	admin@talakunchi.com	$2a$12$/zWdfjp1UDRtZnibgKunCu.UiXRuSFYEay7myO6kIALw0mq5hgjoK	Admin User	TK-0004	Functional - IT Administration	\N	\N	IT Admin	t	t	a0000000-0000-0000-0000-000000000001	2026-10-16 10:06:08.96608+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	0	\N	\N	\N	Local	\N
78470591-8a64-40a5-8bcd-f766cb7ae3ec	harsh.wardhan.tk-0016@talakunchi.com	$2a$12$Q1WXE.vXpkhmPqmIk.3xdOzAGJeWTy98V4E1H3n5KjTa7AFePazl.	Harsh Wardhan	TK-0016	Functional - IT Administration	\N	\N	Desktop Support Engineer - I	t	t	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-16 10:06:09.241746+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	0	\N	\N	\N	Local	\N
a0b10742-1874-4390-a73d-122dd9db2859	pallavi.sawant.tk-0017@talakunchi.com	$2a$12$ESBGepF4cgho35rHk6ymUeVvWmOkUHHwf/rGQr8fE2FogdmbaMuLy	Pallavi Sawant	TK-0017	Functional - IT Administration	\N	\N	Desktop Support Engineer - II	t	t	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-16 10:06:09.503287+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	0	\N	\N	\N	Local	\N
c9d183e1-5770-494a-a061-137a51001f53	harsh.pandey.tk-0018@talakunchi.com	$2a$12$WedigdLQFiPPL8dugTIwMed2zHP3gWMBQjnd1b6SEwmgi/ev2WgZe	Harsh Pandey	TK-0018	Functional - IT Administration	\N	\N	IT Admin	t	t	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-16 10:06:09.760432+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	0	\N	\N	\N	Local	\N
\.


--
-- Data for Name: tbl_client_assignments; Type: TABLE DATA; Schema: customer; Owner: -
--

COPY customer.tbl_client_assignments ("ClientId", "UserId") FROM stdin;
\.


--
-- Data for Name: tbl_client_contacts; Type: TABLE DATA; Schema: customer; Owner: -
--

COPY customer.tbl_client_contacts ("Id", "ClientId", "SubVentureId", "Name", "Email", "Phone", "Designation", "ContactType", "IsPrimary", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Country", "PhoneCode") FROM stdin;
8fd48693-946d-4794-9c47-17ac63c3a581	\N	c005cbc3-03a8-4dec-b3d0-c44868e18f28	Abhi Mistry	abhi@adityabirla.com	9874237847	Accounts Head	Accounts	f	2026-10-14 04:10:42.001025+00	2026-10-14 04:14:49.555943+00	00000000-0000-4000-8000-000000000004	00000000-0000-4000-8000-000000000004	2026-10-14 04:14:49.555943+00	India	+91
994f1b38-e2e1-4e84-a6a9-44707059954d	\N	c005cbc3-03a8-4dec-b3d0-c44868e18f28	Krshna	krsna@adityabirla.com	8723463284	CIO	Technical	f	2026-10-14 04:10:42.001025+00	2026-10-14 04:14:49.555943+00	00000000-0000-4000-8000-000000000004	00000000-0000-4000-8000-000000000004	2026-10-14 04:14:49.555943+00	India	+91
17552817-df66-49cb-843f-e4a269871e53	\N	c005cbc3-03a8-4dec-b3d0-c44868e18f28	Omakar	omkar@gmail.com	8723463284	CIO	Technical	f	2026-10-14 04:14:49.55821+00	\N	00000000-0000-4000-8000-000000000004	\N	\N	India	+91
3faf9dea-ce22-4338-80f0-46dc0a7838de	\N	c005cbc3-03a8-4dec-b3d0-c44868e18f28	Abhi Mistry	abhi@adityabirla.com	9874237847	Accounts Head	Accounts	f	2026-10-14 04:14:49.55821+00	\N	00000000-0000-4000-8000-000000000004	\N	\N	India	+91
cdd36d63-2277-4409-89c1-1b43236e0d0f	\N	a585a207-e23c-4694-9a6e-1dfea515c585	test	test@gg.com	5645467676	Desg Test	Test cnt	f	2026-10-18 10:28:17.271962+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	India	+91
3f4e7f21-22c2-40d8-9459-a99c68a15f25	\N	0737c566-0a0a-4cbc-93b2-a10e8d56c3cc	Vighnesh Pai	vighneshpai2003@gmail.com	9221117564	CISO	Technical	f	2026-10-26 11:48:41.529661+00	2026-10-26 11:50:49.368666+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-26 11:50:49.368666+00	India	+91
79775855-0aeb-4e5f-a6da-689fc88ba630	\N	0737c566-0a0a-4cbc-93b2-a10e8d56c3cc	Billu Singh	vighneshpai2003@gmail.com	9221117564	CISO	Technical	f	2026-10-26 11:50:49.370823+00	2026-10-26 11:53:47.719813+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-26 11:53:47.719813+00	India	+91
2897ebe9-fc7e-477e-826a-203915dd2a92	\N	0737c566-0a0a-4cbc-93b2-a10e8d56c3cc	Billu Singh	vighneshpai2003@gmail.com	9221117564	CISO	Technical	f	2026-10-26 11:53:47.721138+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	India	+91
35c4b9a9-5370-4fee-9f5f-0fffffb217bb	\N	6647545b-7062-49e3-b36b-2f3947885742	Waxerr	vighneshpai7803@gmail.com	9886250014	SPOC	Accounts	f	2026-10-26 11:53:47.721138+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	India	+91
\.


--
-- Data for Name: tbl_clients; Type: TABLE DATA; Schema: customer; Owner: -
--

COPY customer.tbl_clients ("Id", "Name", "Industry", "Logo", "ContactEmail", "ClientType", "Status", "EngagementManager", "ContactName", "ContactPhone", "ContactDesignation", "ContactType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BusinessType", "City", "Country", "KycDocumentName", "Notes", "EngagementManagerId", "IndustryId", "CityId", "CountryId", "CustomerSince", "SalesManager", "SalesManagerId", "KycDocumentPath", "BillingMedium", "GroupSpocName", "GroupSpocContact", "ClientCode", "CreatedByName", "GroupSpocPhoneCode") FROM stdin;
5a526476-8299-49a7-af85-4a322006bde9	test cust	INDUSTRY Test	TC	\N	New	Active	Atharv Reddy	test spoc	3233333333	\N	Group SPOC	2026-10-18 10:28:17.255787+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	\N	test city	India	TK_PMS_Tool_BRD_Module_V05.pdf	\N	033446c7-c133-4395-bdaa-69b5f227a7a8	8e0492bb-3e1c-47b8-890c-a2aa8cdd3a03	08a60e15-809d-4e3b-8add-82ddc53f77ed	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-10-18	Omkar Reddy	776f2cf7-c4cc-4299-b38f-afbcaff7703e	\N	Portal Based	test spoc	3233333333	C002	admin	\N
bf01f81e-b09c-47c1-811c-40a58a56db12	Aditya Birla	Logistics	AB	\N	New	Active	Karan Wardhan	Dhanshree	9348753534	\N	Group SPOC	2026-10-14 04:10:41.986238+00	2026-10-19 12:34:42.476388+00	00000000-0000-4000-8000-000000000004	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Navi Mumbai	India	Resume_Omkar_Gaikwad.pdf	\N	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	f175fde9-14f8-40e8-b564-47d8a29d84ff	ea72f142-d2b7-4d74-8877-4c5c64106d84	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-10-14	Sales User	\N	\N	Portal Based	Dhanshree	9348753534	C001	admin	+91
56d405f8-13d8-44de-a4fe-2a74167c7f6f	Paytm	Energy	P	\N	New	Active	Karan Wardhan	VMP	9221117564	\N	Group SPOC	2026-10-26 11:48:41.511895+00	2026-10-26 11:50:49.365031+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Mumbai	India	TK  PMS_Changes_OutScope.xlsx	\N	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	c7e82721-829b-4450-8393-022587178471	6ffbb80b-985d-4f00-9140-db22f39a625d	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-10-26	Omkar Reddy	776f2cf7-c4cc-4299-b38f-afbcaff7703e	\N	Manual Based	VMP	9221117564	C003	admin	+91
\.


--
-- Data for Name: tbl_sub_ventures; Type: TABLE DATA; Schema: customer; Owner: -
--

COPY customer.tbl_sub_ventures ("Id", "ClientId", "Name", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Notes", "KycDocumentName", "KycDocumentPath", "SubVentureCode") FROM stdin;
c005cbc3-03a8-4dec-b3d0-c44868e18f28	bf01f81e-b09c-47c1-811c-40a58a56db12	Aditya Birla_Finance	2026-10-14 04:10:41.986238+00	2026-10-14 04:10:42.078291+00	00000000-0000-4000-8000-000000000004	00000000-0000-4000-8000-000000000004	\N	Important client	Resume_Omkar_Gaikwad.pdf	KYC/20261014_041042_070_Aditya_Birla_Aditya_Birla_Finance_Resume_Omkar_Gaikwad.pdf	C001-01
a585a207-e23c-4694-9a6e-1dfea515c585	5a526476-8299-49a7-af85-4a322006bde9	sub test cust	2026-10-18 10:28:17.255787+00	2026-10-18 10:28:17.400741+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	TK_PMS_Tool_BRD_Module_V05.pdf	KYC/20261018_102817_392_test_cust_sub_test_cust_TK_PMS_Tool_BRD_Module_V05.pdf	C002-01
0737c566-0a0a-4cbc-93b2-a10e8d56c3cc	56d405f8-13d8-44de-a4fe-2a74167c7f6f	urbancompany	2026-10-26 11:48:41.511895+00	2026-10-26 11:48:41.782815+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	TK  PMS_Changes_OutScope.xlsx	KYC/20261026_114841_770_Paytm_urbancompany_TK__PMS_Changes_OutScope.xlsx	C003-01
6647545b-7062-49e3-b36b-2f3947885742	56d405f8-13d8-44de-a4fe-2a74167c7f6f	pinelabs	2026-10-26 11:53:47.71626+00	2026-10-26 11:53:47.80564+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	TK  PMS_Changes_OutScope.xlsx	KYC/20261026_115347_802_Paytm_pinelabs_TK__PMS_Changes_OutScope.xlsx	C003-02
\.


--
-- Data for Name: mst_address_cities; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_address_cities ("Id", "Code", "Name", "Line", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
c1b7b609-e972-46bf-af06-05ea01dd793a	churchgate_western_line	Churchgate (Western Line)	Western Line	t	1	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
816d2434-c6f3-4100-a803-c3d41446e48f	marine_lines_western_line	Marine Lines (Western Line)	Western Line	t	2	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
04d78d3c-d816-42e0-8c0b-9b6b6ec15cbc	charni_road_western_line	Charni Road (Western Line)	Western Line	t	3	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
b196c811-3eff-4bc2-8f6c-f56603422910	grant_road_western_line	Grant Road (Western Line)	Western Line	t	4	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
a56bedc6-b8df-4686-823f-338a61694114	mumbai_central_western_line	Mumbai Central (Western Line)	Western Line	t	5	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
9b11869d-489c-44b3-b7ea-e8e25e1bd18d	mahalaxmi_western_line	Mahalaxmi (Western Line)	Western Line	t	6	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
1946b3fd-9ed1-45d7-8533-f37b2d489ad9	lower_parel_western_line	Lower Parel (Western Line)	Western Line	t	7	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
7827ce15-f1d3-4ba4-ba15-e04590f7b3cb	prabhadevi_western_line	Prabhadevi (Western Line)	Western Line	t	8	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
061c6b2d-1862-4938-9783-c0dfe926b6f8	dadar_western_line	Dadar (Western Line)	Western Line	t	9	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
f55686d6-a384-4e19-a9ad-f45f66463607	matunga_road_western_line	Matunga Road (Western Line)	Western Line	t	10	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
106140c8-b74c-4014-9061-7ba531736359	mahim_western_line	Mahim (Western Line)	Western Line	t	11	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
faee47c0-ec5d-4ec4-a09d-65c464750bb2	bandra_western_line	Bandra (Western Line)	Western Line	t	12	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
4db9eaea-2ee7-45ef-9fc0-e70d68edec29	khar_road_western_line	Khar Road (Western Line)	Western Line	t	13	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
ea19c292-de26-4b38-8b50-6a25fae9dea9	santacruz_western_line	Santacruz (Western Line)	Western Line	t	14	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
31e8c5b0-d95c-4b0d-aa1a-0488f0c5a9bc	vile_parle_western_line	Vile Parle (Western Line)	Western Line	t	15	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
898a74ea-4eca-4f9e-bbd5-0ccb764f753d	andheri_western_line	Andheri (Western Line)	Western Line	t	16	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
144bbdd1-7203-4f8c-860c-42980f67a5b8	jogeshwari_western_line	Jogeshwari (Western Line)	Western Line	t	17	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
56b2b441-e2d7-4f0e-8557-739b24e953c5	ram_mandir_western_line	Ram Mandir (Western Line)	Western Line	t	18	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
c0a0945e-f689-4714-aa1c-2b08c91f3d2e	goregaon_western_line	Goregaon (Western Line)	Western Line	t	19	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
b7dbca39-832c-4db7-bca9-1ab73f62046d	malad_western_line	Malad (Western Line)	Western Line	t	20	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
731acfdf-10ac-46fc-a584-4bdce4474920	kandivali_western_line	Kandivali (Western Line)	Western Line	t	21	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
4bae1d84-893b-4b3a-9aa3-4c6fe0ac0106	borivali_western_line	Borivali (Western Line)	Western Line	t	22	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
20384898-808a-4dbb-b015-b15b73d94552	dahisar_western_line	Dahisar (Western Line)	Western Line	t	23	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
a43d47b6-9277-40e3-a158-724901c63c2c	mira_road_western_line	Mira Road (Western Line)	Western Line	t	24	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
e89a779a-9c79-4961-886f-c253db287e2b	bhayandar_western_line	Bhayandar (Western Line)	Western Line	t	25	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
5f291975-efdc-43a2-b939-ec9c0379fc82	naigaon_western_line	Naigaon (Western Line)	Western Line	t	26	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
3803b898-069d-4f35-a2df-05124a852a93	vasai_road_western_line	Vasai Road (Western Line)	Western Line	t	27	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
fb022e30-691a-4dc2-b9ae-6f8fe7cae3ac	nallasopara_western_line	Nallasopara (Western Line)	Western Line	t	28	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
a79124eb-b6f3-4410-9c4d-20993429f10e	virar_western_line	Virar (Western Line)	Western Line	t	29	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
a9ed2bd5-8add-4cf5-8ebb-7ca3a581b80d	vaitarna_western_line	Vaitarna (Western Line)	Western Line	t	30	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
959bbbc8-674c-4a35-988f-06b291ce32a7	saphale_western_line	Saphale (Western Line)	Western Line	t	31	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
b28f8d75-3132-4c81-8af2-9f19d2777027	kelve_road_western_line	Kelve Road (Western Line)	Western Line	t	32	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
7bbd8d32-4d50-4c99-b829-1638af8466c4	palghar_western_line	Palghar (Western Line)	Western Line	t	33	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
315920ab-c0fc-402c-a0bc-05d801b64238	umroli_western_line	Umroli (Western Line)	Western Line	t	34	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
755e0fe8-75be-4ae6-9280-55b51076f973	boisar_western_line	Boisar (Western Line)	Western Line	t	35	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
08bbc01f-e72f-4185-925e-fa4eec5d0955	vangaon_western_line	Vangaon (Western Line)	Western Line	t	36	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
076cc445-f523-456d-b93e-ff43b7df2874	dahanu_road_western_line	Dahanu Road (Western Line)	Western Line	t	37	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
486a014e-77a8-4278-956a-3ff9745b2946	csmt_central_line	CSMT (Central Line)	Central Line	t	38	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
504510c8-d338-42de-9fb1-a57bca7fc64a	masjid_central_line	Masjid (Central Line)	Central Line	t	39	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
de58996d-0833-4dfd-bf02-f4c2d20c38b0	sandhurst_road_central_line	Sandhurst Road (Central Line)	Central Line	t	40	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
2358b01d-cee9-48de-a7e1-95d52ccc0e39	byculla_central_line	Byculla (Central Line)	Central Line	t	41	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
b150dfe1-d758-4b4b-beed-6f4cf23840fd	chinchpokli_central_line	Chinchpokli (Central Line)	Central Line	t	42	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
5b312dea-f8f6-409f-9402-d9925bc556b1	currey_road_central_line	Currey Road (Central Line)	Central Line	t	43	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
9c216179-eb61-4b9d-b5a9-46ce6b0a02ea	parel_central_line	Parel (Central Line)	Central Line	t	44	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
dc7275e9-a686-4a17-8d29-db05d7bcdc66	dadar_central_line	Dadar (Central Line)	Central Line	t	45	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
a3f85e1b-fd8d-4945-ba90-3d688c1c1e82	matunga_central_line	Matunga (Central Line)	Central Line	t	46	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
3dd73e6b-9ef6-429c-876a-9aa88c4c26f0	sion_central_line	Sion (Central Line)	Central Line	t	47	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
c64cab5a-e26e-48b0-8746-16e0b3bb4a65	kurla_central_line	Kurla (Central Line)	Central Line	t	48	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
8e2da2b5-5371-44a8-9624-7d0588317bc1	vidyavihar_central_line	Vidyavihar (Central Line)	Central Line	t	49	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
8fc06773-6463-497f-82e3-23f8a4891e14	ghatkopar_central_line	Ghatkopar (Central Line)	Central Line	t	50	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
b465b7a2-57e4-453d-8ec6-528e8bdeb789	vikhroli_central_line	Vikhroli (Central Line)	Central Line	t	51	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
ca50eb41-e068-4866-875b-302c4866634e	kanjurmarg_central_line	Kanjurmarg (Central Line)	Central Line	t	52	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
403af888-0eb5-4bec-9632-9b5cb0786bda	bhandup_central_line	Bhandup (Central Line)	Central Line	t	53	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
49d9eb4e-327f-4428-bb05-b2af33ae65b8	nahur_central_line	Nahur (Central Line)	Central Line	t	54	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
808e3805-6b3a-4546-ab03-b00ed270f952	mulund_central_line	Mulund (Central Line)	Central Line	t	55	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
680258f0-3445-4aaf-880c-a2130b135474	thane_central_line	Thane (Central Line)	Central Line	t	56	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
5868d2dc-9191-41ed-a534-5e3d9ba294ca	kalwa_central_line	Kalwa (Central Line)	Central Line	t	57	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
a0d5cd46-ad11-4fad-8252-66b7a470c056	mumbra_central_line	Mumbra (Central Line)	Central Line	t	58	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
e7aa6a52-0d08-4456-a6a0-365f4ff5c62f	diva_central_line	Diva (Central Line)	Central Line	t	59	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
83cd2cf4-3300-48be-9cd4-2c648fb2e388	kopar_central_line	Kopar (Central Line)	Central Line	t	60	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
d94dd838-3138-4f58-b861-a09fa250ca12	dombivli_central_line	Dombivli (Central Line)	Central Line	t	61	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
9b753ac7-c6db-417c-bd5b-1f25a789627e	thakurli_central_line	Thakurli (Central Line)	Central Line	t	62	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
0b1c9cac-e84c-4a74-a2a1-baf3cf8b1bc5	kalyan_central_line	Kalyan (Central Line)	Central Line	t	63	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
819a89b1-ce2d-4cf6-abda-a62b3d1ffd04	shahad_central_line	Shahad (Central Line)	Central Line	t	64	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
9e511da8-d94d-499e-96ec-cd109522adfd	ambivli_central_line	Ambivli (Central Line)	Central Line	t	65	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
de1b6711-424d-4301-8401-7703e6c254b1	titwala_central_line	Titwala (Central Line)	Central Line	t	66	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
7d59f6ce-316f-4704-be36-830b086a5c48	khadavli_central_line	Khadavli (Central Line)	Central Line	t	67	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
a46e5fe4-6857-4da4-ac58-6b0bc0d8ae5a	vasind_central_line	Vasind (Central Line)	Central Line	t	68	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
d361e448-c43e-463c-867c-f8be15412f33	asangaon_central_line	Asangaon (Central Line)	Central Line	t	69	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
05e28de0-730b-444c-8fe4-5897beead6a5	atgaon_central_line	Atgaon (Central Line)	Central Line	t	70	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
22e14110-d0d3-4487-89c7-a4092c038439	thansit_central_line	Thansit (Central Line)	Central Line	t	71	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
d52ec5a7-4180-4468-af86-fc73faf839cf	khardi_central_line	Khardi (Central Line)	Central Line	t	72	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
93e8a4fe-7789-4306-9c84-ab893dfb575e	umbermali_central_line	Umbermali (Central Line)	Central Line	t	73	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
00fd0b4b-57b2-4fcb-a1cb-bc47887d7a9b	kasara_central_line	Kasara (Central Line)	Central Line	t	74	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
79df8693-3230-472b-99fa-cb70c7c4087d	vithalwadi_central_line	Vithalwadi (Central Line)	Central Line	t	75	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
f1f97138-2c62-4b54-98a6-72d0d308a9e5	ulhasnagar_central_line	Ulhasnagar (Central Line)	Central Line	t	76	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
405fc369-a8d5-4b28-bded-e8d0b02bc370	ambernath_central_line	Ambernath (Central Line)	Central Line	t	77	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
cc670b6b-887d-48b0-afae-52943342cbca	badlapur_central_line	Badlapur (Central Line)	Central Line	t	78	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
ab376b29-b3ae-4031-b8eb-a743b5ee99e3	vangani_central_line	Vangani (Central Line)	Central Line	t	79	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
4015d98e-567f-48b9-937a-30731fbb0443	shelu_central_line	Shelu (Central Line)	Central Line	t	80	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
1139c71c-b701-4bfc-b2a1-f48bf05b4928	neral_central_line	Neral (Central Line)	Central Line	t	81	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
595fb84f-5430-4758-98cc-726c0d506999	bhivpuri_road_central_line	Bhivpuri Road (Central Line)	Central Line	t	82	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
03699bbe-284e-4057-b4e3-a1c77319f509	karjat_central_line	Karjat (Central Line)	Central Line	t	83	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
5a678029-475c-479d-bff1-891ee39cc49d	palasdari_central_line	Palasdari (Central Line)	Central Line	t	84	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
87aad8ab-5bce-49a5-8c5a-08325794f46b	kelavli_central_line	Kelavli (Central Line)	Central Line	t	85	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
fac51eeb-5224-4429-a7f7-665851d73d33	dolavli_central_line	Dolavli (Central Line)	Central Line	t	86	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
0812d76f-b767-4b7c-8db7-621656706dfc	lowjee_central_line	Lowjee (Central Line)	Central Line	t	87	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
83344131-d160-4304-9ede-203f0967a051	khopoli_central_line	Khopoli (Central Line)	Central Line	t	88	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
1a3e64c7-d560-4912-b29b-eed1cfa12d19	csmt_harbour_line	CSMT (Harbour Line)	Harbour Line	t	89	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
17621f29-78a8-4ee4-88d1-91d64a3739eb	masjid_harbour_line	Masjid (Harbour Line)	Harbour Line	t	90	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
28c656db-dcb7-4976-a87b-aad833f4b531	sandhurst_road_harbour_line	Sandhurst Road (Harbour Line)	Harbour Line	t	91	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
a4edf344-c2cf-4cd5-863a-b66e0a975dba	dockyard_road_harbour_line	Dockyard Road (Harbour Line)	Harbour Line	t	92	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
15aa7d7e-ba10-48dc-b2de-0b1fdb584eef	reay_road_harbour_line	Reay Road (Harbour Line)	Harbour Line	t	93	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
fbfdc4b8-7968-4461-bb2d-ade3de2b6e2f	cotton_green_harbour_line	Cotton Green (Harbour Line)	Harbour Line	t	94	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
851f6cba-b238-4f80-9579-7aa499a669ec	sewri_harbour_line	Sewri (Harbour Line)	Harbour Line	t	95	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
d1db39ea-28b4-4563-88dc-022c36206a6c	vadala_road_harbour_line	Vadala Road (Harbour Line)	Harbour Line	t	96	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
e52f3ca4-df45-4546-a10b-97079fe9479e	kings_circle_harbour_line	Kings Circle (Harbour Line)	Harbour Line	t	97	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
8e4a8076-c104-4b30-872e-30e932338cd5	gtb_nagar_harbour_line	GTB Nagar (Harbour Line)	Harbour Line	t	98	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
d990cdd0-3acd-445d-aec8-cc4895b8b8a3	chunabhatti_harbour_line	Chunabhatti (Harbour Line)	Harbour Line	t	99	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
0cd82733-f2ab-4ff1-bb6e-c72d658d4868	kurla_harbour_line	Kurla (Harbour Line)	Harbour Line	t	100	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
4470aef4-6736-4156-86df-28e875ed5aad	tilak_nagar_harbour_line	Tilak Nagar (Harbour Line)	Harbour Line	t	101	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
2dfe1ea3-ab2f-402d-b5fe-362da4fa79f8	chembur_harbour_line	Chembur (Harbour Line)	Harbour Line	t	102	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
b5a9353a-059a-4e4d-ae0a-e50b8ae3d8bd	govandi_harbour_line	Govandi (Harbour Line)	Harbour Line	t	103	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
a22fde2f-af75-42b2-8e9a-a5f0ae329649	mankhurd_harbour_line	Mankhurd (Harbour Line)	Harbour Line	t	104	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
41ab877d-9bad-4639-9384-369c02dec896	vashi_harbour_line	Vashi (Harbour Line)	Harbour Line	t	105	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
6b7b2d3b-783b-4b5c-82ef-ce541414a3f4	sanpada_harbour_line	Sanpada (Harbour Line)	Harbour Line	t	106	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
0885c10a-d971-4102-a935-6355a2821ada	juinagar_harbour_line	Juinagar (Harbour Line)	Harbour Line	t	107	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
ba5e6a63-a4b2-47f9-a0cb-0e1b02fd272b	nerul_harbour_line	Nerul (Harbour Line)	Harbour Line	t	108	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
532d7dbb-234c-4ebe-9f8b-15b16e07036f	seawoods_darave_harbour_line	Seawoods-Darave (Harbour Line)	Harbour Line	t	109	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
011b0588-dd0d-4841-b691-3ee97c18dfb2	cbd_belapur_harbour_line	CBD Belapur (Harbour Line)	Harbour Line	t	110	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
19c379a9-7aed-4c02-95c8-12d2abee6b2c	kharghar_harbour_line	Kharghar (Harbour Line)	Harbour Line	t	111	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
32a442e6-f7f4-411e-bc98-806e3f3ea374	mansarovar_harbour_line	Mansarovar (Harbour Line)	Harbour Line	t	112	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
bc3c4ec2-cb9e-424f-a720-bfd108c09b2d	khandeshwar_harbour_line	Khandeshwar (Harbour Line)	Harbour Line	t	113	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
65d5d4c0-f88c-47a3-8c1a-150f3d198d61	panvel_harbour_line	Panvel (Harbour Line)	Harbour Line	t	114	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
12f9b271-e82a-4e54-a026-e2b24a688bc1	thane_trans_harbour_line	Thane (Trans-Harbour Line)	Trans-Harbour Line	t	115	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
ab1a6785-3a51-4eec-b944-52ffedfb2ecb	digha_gaon_trans_harbour_line	Digha Gaon (Trans-Harbour Line)	Trans-Harbour Line	t	116	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
bc3bfc34-01a3-4c66-bf96-fe203a007692	airoli_trans_harbour_line	Airoli (Trans-Harbour Line)	Trans-Harbour Line	t	117	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
2f58411c-ecfb-4d38-907d-2898675d913d	rabale_trans_harbour_line	Rabale (Trans-Harbour Line)	Trans-Harbour Line	t	118	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
8dc4e2f6-7cb0-4b06-8fee-ff451cfe3778	ghansoli_trans_harbour_line	Ghansoli (Trans-Harbour Line)	Trans-Harbour Line	t	119	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
fa93d47b-4401-49d0-ac56-9640fae57c62	kopar_khairane_trans_harbour_line	Kopar Khairane (Trans-Harbour Line)	Trans-Harbour Line	t	120	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
3266d4aa-82e3-4d59-9a5d-264aa288f2c2	turbhe_trans_harbour_line	Turbhe (Trans-Harbour Line)	Trans-Harbour Line	t	121	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
33a61ddb-66c8-4d74-bb77-850b58fc8d70	sanpada_trans_harbour_line	Sanpada (Trans-Harbour Line)	Trans-Harbour Line	t	122	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
1e0ab980-8f78-44da-a84f-6a0a670b2ab2	vashi_trans_harbour_line	Vashi (Trans-Harbour Line)	Trans-Harbour Line	t	123	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
6f53403d-431d-4fbc-a280-c3fcef5902d2	juinagar_trans_harbour_line	Juinagar (Trans-Harbour Line)	Trans-Harbour Line	t	124	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
2df2e31a-7d03-467b-9a6d-5bf2111b0066	nerul_trans_harbour_line	Nerul (Trans-Harbour Line)	Trans-Harbour Line	t	125	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
5e852901-34fc-427c-8078-b983bde00595	seawoods_darave_trans_harbour_line	Seawoods-Darave (Trans-Harbour Line)	Trans-Harbour Line	t	126	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
3f3d276a-317e-4ac4-962a-968cff8de665	cbd_belapur_trans_harbour_line	CBD Belapur (Trans-Harbour Line)	Trans-Harbour Line	t	127	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
196262d4-9a4e-4158-a3a6-60babccaf66b	panvel_trans_harbour_line	Panvel (Trans-Harbour Line)	Trans-Harbour Line	t	128	2026-10-10 06:56:25.008136+00	\N	\N	\N	\N
085f5e38-ecf0-4362-87e2-33b348b0a938	zz_probe_city	ZZ Probe City	Probe Line	f	129	2026-10-18 13:00:09.453122+00	2026-10-18 13:00:09.771013+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:00:09.771013+00
\.


--
-- Data for Name: mst_business_units; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_business_units ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
1ab2e67e-5e47-4f6d-8035-dd6a5c5f6b85	talakunchi_networks_private_limited	Talakunchi Networks Private Limited	t	1	2026-09-03 12:17:46.134222+00	\N	\N	\N	\N
8d074538-ddf6-4d28-894e-ef01ff8dbd9f	zz_probe_unit	ZZ Probe Unit	f	2	2026-10-18 13:00:09.292041+00	2026-10-18 13:00:09.693684+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:00:09.693684+00
9b7b8b3c-a2b7-4627-8489-adfe5f0059bd	zz_ui_probe_unit	ZZ UI Probe Unit Edited	f	3	2026-10-18 13:01:10.914455+00	2026-10-18 13:01:42.321832+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 13:01:42.321832+00
\.


--
-- Data for Name: mst_certifications; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
0705d913-f281-4559-a5a2-273dcdab4c4c	comptia_securityplus	CompTIA Security+	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
0ff050bb-aff0-48e2-b3f1-0db0b1e4ff0e	certified_in_risk_and_information_systems_control_	Certified in Risk and Information Systems Control (CRISC)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
1277ee68-900e-4989-bdab-ea6c79593dfe	blue_team_level_1_and_2	Blue Team Level 1 and 2	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
13a1fd79-fc90-4c4d-b392-197e2173c3f0	offensive_security_certified_expert_3_(osce3)	Offensive Security Certified Expert 3 (OSCE3)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
2dea8afa-5403-43c9-9a03-45156a3c4198	elearnsecurity_certified_threat_hunting_profession	eLearnSecurity Certified Threat Hunting Professional (eCTHP)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
45d2575e-48cc-4593-86f6-1d1884e56abe	iso_27001	ISO 27001	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
5817ff34-8c14-4679-b368-8d5323ccd31b	pnpt	PNPT	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
6d67283e-fb84-408e-a151-12ee7ef9b7dd	ecppt	eCPPT	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
7ab3d38a-323d-49d8-8e0e-83b96e520205	certified_cloud_security_professional_(ccsp)	Certified Cloud Security Professional (CCSP)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
7d8276b0-d415-4110-b7ab-2bb718b0396f	offensive_security_certified_professional_(oscp)	Offensive Security Certified Professional (OSCP)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
7e8c683c-5fb3-4bdb-8d94-e5fbfcdc2e11	certified_threat_intelligence_analyst_(ctia)	Certified Threat Intelligence Analyst (CTIA)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
86e2ff2b-d817-4c93-aa51-51742d727d1b	offensive_security_wireless_professional_(oswp)	Offensive Security Wireless Professional (OSWP)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
9b093776-b367-4581-b1a9-a141bf9adcbb	elearnsecurity_certified_incident_responder_(ecir)	eLearnSecurity Certified Incident Responder (eCIR)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
a6c8ffd7-3497-4f4c-a651-bd1e6230f945	licensed_penetration_tester_(lpt)	Licensed Penetration Tester (LPT)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
aaa594dd-b167-4034-b538-a8ed292825f6	offensive_security_experienced_penetration_tester_	Offensive Security Experienced Penetration Tester (OSEP)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
ab729e39-7b07-4da9-ba03-d155d93695db	certified_ethical_hacker_(ceh)	Certified Ethical Hacker (CEH)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
bef0b76e-c4cd-4c11-8bdc-82ba930c8e51	iso_22301	ISO 22301	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
c38bd75b-3213-4bcd-9ca1-64ff72f02178	crte	CRTE	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
c4323823-361f-4ff9-a699-a91b2400f59b	crt	CRT	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
c4f2e057-5906-4154-83e2-4f009d6af825	ec_council_certified_incident_handler_(ecih)	EC-Council Certified Incident Handler (ECIH)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
cc0b6618-17ef-48f6-9280-6e7fa9885b60	certified_information_systems_security_professiona	Certified Information Systems Security Professional (CISSP)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
cc7740c3-4189-40e2-86f6-797dacb789c0	offsec_foundational_security_operations_and_defens	OffSec Foundational Security Operations and Defensive Analysis (OSDA)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
cf42b7a7-dd8c-4395-880c-a27051408df5	certified_information_security_manager_(cism)	Certified Information Security Manager (CISM)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
d79a4f9d-8eb3-48ea-baeb-20de01ea05ce	elearnsecurity_certified_digital_forensics_profess	eLearnSecurity Certified Digital Forensics Professional (eCDFP)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
daab1e17-24aa-435f-89a5-8a9e8e5052bf	iso_iec_42001	ISO/IEC 42001	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
e5540bc7-50d2-4d70-a943-acd46aa882c5	cpts	cPTS	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
e5ca396a-d689-4010-a451-39b1b99a7bd2	offensive_security_web_expert_(oswe)	Offensive Security Web Expert (OSWE)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
ef4cd7da-14f7-4f0d-afd0-99ca3bb6ffe2	certified_information_systems_auditor_(cisa)	Certified Information Systems Auditor (CISA)	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
fc483ca5-d867-433f-a4d6-bac79879517f	crtp	CRTP	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
d20bc297-e08b-4694-aa66-2d2b9fb83c2c	zz_probe_cert	ZZ Probe Cert	f	2026-10-18 13:00:09.427314+00	2026-10-18 13:00:09.755834+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:00:09.755834+00
\.


--
-- Data for Name: mst_cities; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
24749751-d539-4881-b91d-32a9b4dbae45	89	Testing mumbai	t	1f7dfdc6-768e-4227-8536-4fd280141d03	2026-10-18 10:03:14.25146+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
08a60e15-809d-4e3b-8add-82ddc53f77ed	TESTCITY	test city	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-10-18 10:25:02.72587+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: mst_contact_designations; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_contact_designations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
301bc813-b2a8-487e-8645-6d613260a7e7	cio	CIO	t	3	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
36d0dd25-0888-4933-b7ec-1ffb839a50bd	cfo	CFO	t	4	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
4289316a-ac66-4577-93b2-b27a1f631bd7	ciso	CISO	t	2	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
634aee41-eb57-41e4-b296-af2a255a7e79	accounts_head	Accounts Head	t	5	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
8a02dfd7-d731-4231-8eba-29f36d2254c7	spoc	SPOC	t	1	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
933ad32d-02a3-4727-ac62-34f2c9ea0d0e	SPOC2	SPOC 2	f	6	2026-10-18 10:02:22.563596+00	2026-10-18 10:05:15.669759+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 10:05:15.669759+00
3039b17d-83f5-42c4-a26c-359a3d35502a	DESGTEST	Desg Test	t	7	2026-10-18 10:23:39.063418+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: mst_contact_types; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_contact_types ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
58db2f92-2db9-46a1-ae8a-f04a3c7cf54c	legal	Legal	t	4	2026-09-09 07:39:28.906477+00	\N	\N	\N	\N
670b9a05-6ee2-488e-962c-51cf3cdb86fa	procurement	Procurement	t	2	2026-09-09 07:39:28.906477+00	\N	\N	\N	\N
6ddcfdba-7311-4f61-b285-88e09a772497	accounts	Accounts	t	1	2026-09-09 07:39:28.906477+00	\N	\N	\N	\N
b28647ac-40d2-449e-b90c-b71cbae83f8d	technical	Technical	t	3	2026-09-09 07:39:28.906477+00	\N	\N	\N	\N
38ead690-dc4e-4ba1-b830-228c184bcd66	LEGAL2	Legal 2	f	5	2026-10-18 10:03:24.899562+00	2026-10-18 10:05:55.982374+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 10:05:55.982374+00
fce7509c-4c38-4afb-b889-8ad5a6474f39	TESTCNT	Test cnt	t	6	2026-10-18 10:24:42.875996+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: mst_countries; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") FROM stdin;
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
1f7dfdc6-768e-4227-8536-4fd280141d03	TESTI	Testing country	t	2026-10-18 10:02:47.856163+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	+91	10
f20c0081-5dae-4dcd-b1b0-b40f46f10c48	TESTC	test country	t	2026-10-18 10:25:24.74245+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	+91	10
\.


--
-- Data for Name: mst_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
36d04440-a8bb-47f1-a6d9-1f4d144b0bdb	x36d04440	retired 36d04440 ZZ Probe Department	f	2026-10-18 13:00:09.499474+00	2026-10-18 13:00:09.799922+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:00:09.799912+00
40fed4c8-89b7-4276-b4ef-47fe8cf1ea87	x40fed4c8	retired 40fed4c8 ZZ UI Department	f	2026-10-18 13:02:39.916388+00	2026-10-18 13:02:54.816575+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 13:02:54.816554+00
316c6b23-b976-4e7f-ae22-c8ea15c365cb	x316c6b23	retired 316c6b23 ZZ Sub Dept	f	2026-10-18 13:13:54.032822+00	2026-10-18 13:13:54.123387+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:13:54.123373+00
\.


--
-- Data for Name: mst_designation_sub_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_designation_sub_departments ("Id", "DesignationId", "SubDepartmentId") FROM stdin;
0194a023-7781-4285-96eb-e33b07320d66	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	682d36c0-4256-42ab-811e-054ab3a5b10f
03e3fef2-65b3-4347-99dc-563c65d7fad0	f8502c44-b289-49e4-8401-3dcad4d5bbe0	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
052be8e7-89f0-46bb-b49e-eec194bbe1ea	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	cfdb2071-d50e-4ea3-b732-19eb08f1e629
087f79bd-d1e9-46c0-8ca7-079e75191fb6	e2b10def-c91d-45da-94c5-f5530e743aa2	fa773eb9-162f-4ea8-9fc4-9c54a3068582
098cdde8-3e61-4f3e-964f-ccf7584d149a	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	fa773eb9-162f-4ea8-9fc4-9c54a3068582
09cfba0b-adea-4f56-97cc-317b8d02f8f4	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	cfdb2071-d50e-4ea3-b732-19eb08f1e629
0a4f87f0-0214-4a57-8ff9-046ac815fa81	e2b4be77-2b20-4064-974d-e6322e7240b4	88b29e0c-39b7-4169-ab5c-350075014a84
0aa2ba9c-f76b-4884-b2f7-04c18edc7cf0	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	682d36c0-4256-42ab-811e-054ab3a5b10f
0d809653-6031-4371-8469-6b9a4bcf683c	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	db0addff-605e-439f-917b-38016a398755
0d9de4dc-74f9-48b1-8d07-030aefadcdd5	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	e99b7773-5d71-4dca-ad36-b896dcfb71c4
10876ccd-f44a-4eef-b0a3-94847b551bb7	af8a1442-c5ee-409d-aa91-61c9dba852ee	cfdb2071-d50e-4ea3-b732-19eb08f1e629
11cdbac0-3629-47ef-ae5f-b84b1198e2c9	3e60b693-d3dd-4481-95c4-9f02da21625c	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
189250a4-41db-4937-9c80-d374285160a0	b3309eea-7374-4a8d-ac13-481b2a7fd492	fd84aa38-11ef-46af-ade7-241f2a2c08fd
19276e5f-4551-44bf-840a-757c99dd2998	444df30d-c195-42ad-b9a7-d80cdef69ccd	cfdb2071-d50e-4ea3-b732-19eb08f1e629
1a639685-1dff-4a25-8495-eaa30bd664cf	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	db0addff-605e-439f-917b-38016a398755
1b1213fb-5594-4d85-a2aa-4774a92d8d01	6e606c29-2ebf-4ab8-8006-aaedd5680009	5d962383-f175-4dd8-af63-8a566a0d2255
1ba7ff6e-d884-4511-af5f-ee14820e2207	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	db0addff-605e-439f-917b-38016a398755
209b0408-67d1-47cf-8871-d832e917410e	c2e248c8-e917-445f-9f7b-1e25d7bb5abe	c88d783b-b628-4f3a-a972-aa56aeed5e77
21b2afb2-e704-445c-91bb-f211148617cb	f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	7682acb3-561b-4951-801b-c1564adda131
24c78bd0-8f40-4165-ad7d-47201ecbaffb	e228c999-bf54-48b4-a373-d2bc9db88554	682d36c0-4256-42ab-811e-054ab3a5b10f
2535d14a-4f70-4958-a8f3-586db12693cc	4650d4e0-f73c-4688-ae5f-830a46348ff9	cfdb2071-d50e-4ea3-b732-19eb08f1e629
279097d7-9de4-4fa7-8fa9-f8be48081d3f	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	682d36c0-4256-42ab-811e-054ab3a5b10f
291829d9-c208-406f-bb35-7799b1a7f886	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	fd84aa38-11ef-46af-ade7-241f2a2c08fd
29450b7d-8107-4f6e-bdf1-9c8c9a9ef63d	163d8c87-8f90-4295-a926-2e912c625a1c	db0addff-605e-439f-917b-38016a398755
2e4557ed-04b0-494e-b2e9-1d71ae4e08fd	3b7ea453-324e-40a0-bb41-77a0795d5af5	682d36c0-4256-42ab-811e-054ab3a5b10f
30c638ba-c563-4eef-9be6-edb72683ead8	c0f974c3-f49c-449a-9276-aa64ce501344	cfdb2071-d50e-4ea3-b732-19eb08f1e629
3402abac-4307-405d-b5bc-4591b6bd7b97	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	e99b7773-5d71-4dca-ad36-b896dcfb71c4
3546bb04-d97b-4f81-b7bc-cf648c957714	9050e021-7d84-4401-820e-c0e768abb1ab	a73eb36c-7d62-4aa8-901d-1c70b3876b69
35f70c49-a751-4d17-9d0c-714dbd4353d0	8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	88b29e0c-39b7-4169-ab5c-350075014a84
3654ddbb-64c6-4398-800a-4a002066490d	d8a2b9e5-f54d-4344-a78d-c6c840467543	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
375362b7-32b3-42c6-966d-dd55f8492db6	4f972924-350a-47fb-a6b6-f2b34bb6b621	db0addff-605e-439f-917b-38016a398755
38117258-d1a2-49e2-a658-9252c20a6af5	48429bb5-c583-4684-b30a-7ed443b671ca	cfdb2071-d50e-4ea3-b732-19eb08f1e629
3955a4f6-2e7b-42bf-9473-46f6ccb13ab9	2a76927c-461a-48e4-8190-dea7361ef3db	fd84aa38-11ef-46af-ade7-241f2a2c08fd
42f6b211-d58d-4c79-97c5-29811d6cf9eb	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
43f65af3-0936-4957-8ff6-f8d123cd109d	485012d4-2c28-4bc4-92c7-3609e3e3749e	c88d783b-b628-4f3a-a972-aa56aeed5e77
452f1db8-51ff-45d4-9a1d-76f9f884a85b	4f972924-350a-47fb-a6b6-f2b34bb6b621	682d36c0-4256-42ab-811e-054ab3a5b10f
4889c759-9efc-4053-80da-e336acefc947	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
494e7238-32d0-424d-8f36-02af5481a427	0c1a5ef4-7fca-45dc-8253-87afa21a1df9	cfdb2071-d50e-4ea3-b732-19eb08f1e629
4c74a011-2f7f-4ded-9579-dea93284d75c	b2b687ef-fd62-4cb7-a826-b40a35da7b2c	fa773eb9-162f-4ea8-9fc4-9c54a3068582
53f1358a-abda-480a-8610-329b084f12cc	e36018c5-bf48-4f93-bef7-93e8864a0b51	cfdb2071-d50e-4ea3-b732-19eb08f1e629
57687863-5afd-4e95-b843-6f1f00c220dc	9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	7682acb3-561b-4951-801b-c1564adda131
59772d69-d691-4b3f-aa00-fe02c4002914	b5f39dd8-c305-489d-9f7d-9adfd010a134	cfdb2071-d50e-4ea3-b732-19eb08f1e629
5d27d1a2-9e69-4cce-ac98-be07a96020fd	168d11d7-ca26-4d61-b870-51779dc63023	e99b7773-5d71-4dca-ad36-b896dcfb71c4
5d7f28de-737e-41eb-ac3f-b895f5203642	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	682d36c0-4256-42ab-811e-054ab3a5b10f
5fb60c81-a207-49c6-8e5a-8488a53552e9	caa227a1-2dcf-4195-ab9c-8f76d1862daa	5d962383-f175-4dd8-af63-8a566a0d2255
6079bf4e-b833-4580-90ba-2275122b0399	a697a798-caaf-4248-8e4e-7e89096a9c30	682d36c0-4256-42ab-811e-054ab3a5b10f
64324af7-a681-4251-89cc-644adc5003cd	a697a798-caaf-4248-8e4e-7e89096a9c30	e99b7773-5d71-4dca-ad36-b896dcfb71c4
64485418-f541-4615-86d4-146ebb3e8aff	e4e20503-cd55-4393-83fd-6c7e7d7d0a49	c88d783b-b628-4f3a-a972-aa56aeed5e77
6d50fb30-41b3-47c9-a015-e99c120c0fbf	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	682d36c0-4256-42ab-811e-054ab3a5b10f
741bbbcf-ad35-4d75-8cef-9111e488eddb	7d542941-65b9-499b-81b3-239748d6da52	c88d783b-b628-4f3a-a972-aa56aeed5e77
79dcc0b9-ae28-426a-8af0-aaa82c312bd4	157d001c-b056-45b1-96a3-3c05bcd8d99c	fa773eb9-162f-4ea8-9fc4-9c54a3068582
7de7f430-6e14-42c2-a3f8-ca34c8ebf260	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	cfdb2071-d50e-4ea3-b732-19eb08f1e629
7f428af1-b182-47ab-b40d-fb913f967dbb	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	e99b7773-5d71-4dca-ad36-b896dcfb71c4
7f758ec8-0c9a-464c-9873-e830245fb468	35a6b1af-dc78-4632-a9f4-eedabdbdcb52	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
80f3b66c-9cd2-4735-81e6-47a6afd2b8a6	272973a6-c052-4aef-bf32-9e24f7eb6cc9	fa773eb9-162f-4ea8-9fc4-9c54a3068582
82c9105c-e1ab-46ac-9e34-c4711ae7a16e	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
857016f9-c17e-412c-8502-747fcee504fd	9858c224-f97f-4ff8-908d-f46bd5e2243c	682d36c0-4256-42ab-811e-054ab3a5b10f
86eaa390-e542-4493-bbf5-fb52c8202671	2b1558e3-158a-4a84-ae80-053129861a64	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
91d01c04-8a69-4322-af07-57219ba699a8	e228c999-bf54-48b4-a373-d2bc9db88554	db0addff-605e-439f-917b-38016a398755
92754fe0-6ee7-4748-8746-3591ec948d54	6d25ff6d-e13d-440f-b775-215547af7acb	cfdb2071-d50e-4ea3-b732-19eb08f1e629
93d4ddb4-6dc6-468e-8e05-093bb20dd390	c70b9832-841e-4864-9b85-eaba3c0a995f	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
95f5d7d1-ff1b-4f2e-a622-252af223370e	4f972924-350a-47fb-a6b6-f2b34bb6b621	e99b7773-5d71-4dca-ad36-b896dcfb71c4
972397b5-daf6-498a-8aca-c5eebb236f7a	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	e99b7773-5d71-4dca-ad36-b896dcfb71c4
98e8a8e7-6a42-44d2-83ee-67338c22f360	ea315f7d-d597-41b3-a999-4f3851bcd020	cfdb2071-d50e-4ea3-b732-19eb08f1e629
9bcf20e8-58f1-4979-815f-e8a28c9abcd2	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	cfdb2071-d50e-4ea3-b732-19eb08f1e629
9d78b85f-e7db-4dac-b67f-a958b2692fc9	195d6a81-8457-4b60-9382-6a3a0664f0e9	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
9fe600c1-7c51-4683-a19d-ef6c65cb09c9	778f1120-9633-4933-9160-ddaa46668838	a12ac80b-a665-4301-898e-e9ca3d44bb20
a0c48f6f-1a20-4e28-8cd5-56e83b9204dd	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	db0addff-605e-439f-917b-38016a398755
a267ff3d-d315-447b-8a0e-633a81f90eec	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	88b29e0c-39b7-4169-ab5c-350075014a84
a8dae975-1c04-4355-9f9e-27112c181083	168d11d7-ca26-4d61-b870-51779dc63023	682d36c0-4256-42ab-811e-054ab3a5b10f
a8f57657-c5c6-42e0-aced-5e2e50168228	168d11d7-ca26-4d61-b870-51779dc63023	db0addff-605e-439f-917b-38016a398755
aad67e32-3024-4b30-b56b-e0ad647ded5e	3b7ea453-324e-40a0-bb41-77a0795d5af5	db0addff-605e-439f-917b-38016a398755
abb82ef9-4121-46eb-a945-b5bf4639788a	f20a7445-0b01-4f20-85a5-853101d864ee	cfdb2071-d50e-4ea3-b732-19eb08f1e629
adf5d50b-3e91-4fd3-aa98-808259a4c563	85cc9fbe-98a4-464d-a638-05f40529c6de	b651aec8-5455-4329-8251-0ceb62cea798
ae11f141-c891-4164-9446-3a665bdc5221	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	e99b7773-5d71-4dca-ad36-b896dcfb71c4
ae9379ba-61ef-46d2-b9ad-6b4194bc8312	ffed7aa1-e88f-4281-919f-8d49fbabf5a5	45755b2a-741a-4990-ab78-8f65090f75b1
aeb33f57-6e2e-482e-9897-7b50f6659049	da990f6e-3379-4cc4-89b7-0ead29da472b	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
b06ff6fb-64e3-4102-9a1f-d8c686fe347b	138434a2-625f-4df5-836d-fcf0cfceef79	fd84aa38-11ef-46af-ade7-241f2a2c08fd
b099efe1-0da0-46cf-af93-1051c3fad1ea	3b7ea453-324e-40a0-bb41-77a0795d5af5	e99b7773-5d71-4dca-ad36-b896dcfb71c4
b2f3628e-638e-4a12-85f7-722a0dbe3a2b	155642eb-a633-4460-b658-aca9fde2d817	5d962383-f175-4dd8-af63-8a566a0d2255
b6162704-51b2-4b39-87a5-51ba2ebcb0ba	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	c88d783b-b628-4f3a-a972-aa56aeed5e77
b749e3ed-1b56-4964-8f8f-5c5981ef0844	c1fa4328-a970-48a1-bc08-d50fe36bf44c	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
b786261c-7a8c-47df-b1ff-99c196df7cce	7c2380da-3ee6-46ad-93d6-a79ce3027f29	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
b95ffd96-23d1-44d4-ae01-24a7bc9f3b72	8dc0d8fe-593d-422a-8b27-5b68fbe6d224	5d962383-f175-4dd8-af63-8a566a0d2255
bae10517-b522-4d65-b186-05b2b5c4767c	0525d830-ead9-44a0-871f-91b7845fec26	61bbeadf-3044-4123-929c-4b1e6e2e613e
bb33ded2-ee1b-474d-b9b1-f3f6565febbe	96efad7d-8b7f-4d7f-a862-c0a6bec3789f	5d962383-f175-4dd8-af63-8a566a0d2255
bf87ae52-2706-49df-af61-f6f745263c81	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	b651aec8-5455-4329-8251-0ceb62cea798
bfb26601-1026-452a-8292-2ecd410177c5	2076a9b1-e432-46a9-99b1-36e732159856	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
c2f37c63-0a5e-48a0-951a-8049eab22148	834c9e15-c70d-4a0b-bb12-5e55f23c181d	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
c9f35ea6-a84e-447b-aa8e-eaae8a15e04d	c0e1a001-0000-4000-8000-000000000001	63765624-d7d1-472d-abd4-627127646998
cafebcfa-99fc-4569-b8ce-c8a8ad982c92	767a00dd-6f09-4f64-a44e-8fbe901222af	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
cfc20bd6-d606-4acb-ab0f-a0c85b0c26ae	e228c999-bf54-48b4-a373-d2bc9db88554	e99b7773-5d71-4dca-ad36-b896dcfb71c4
d47263ea-e72b-4c26-9c6c-6cd274282cf9	e8c22eff-0daf-4690-a537-c8b0b6110a01	c88d783b-b628-4f3a-a972-aa56aeed5e77
d579e8cb-c89f-404b-85cb-e1b6ac3c24b7	1e7faab8-273d-40df-9f9a-485160186c5a	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
d744c257-62ac-48c5-bb65-953fb83f7516	bb7ccd5f-2f60-49fb-b984-f11fc47add22	7682acb3-561b-4951-801b-c1564adda131
d76bc444-ac50-476d-9112-c63df05a5538	73bd55bb-5d0e-4381-8ad2-2238377fca93	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
d9a2eab8-7a5f-4c33-bd83-ad20bce7f16b	8b57cfd5-5d4e-44a3-9646-b36873c111c2	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
da583b3c-941c-484b-b0d6-9488c8c05cca	ae255622-ddcc-45ea-a699-8ec416fe57ab	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
dbc5b403-ef9a-4930-8398-0d0d811e30d8	4b680e29-b4fb-4689-9afb-67a7f089f52b	b651aec8-5455-4329-8251-0ceb62cea798
e23b93fc-5dff-486a-8a50-404db4049031	e2c675a7-92dc-4477-be75-9a304cbe4def	fa773eb9-162f-4ea8-9fc4-9c54a3068582
e31e4e1e-0a7d-43e5-aacf-9bc252ad59a6	6193be76-40ad-4973-9ee7-246a4d8f4109	fa773eb9-162f-4ea8-9fc4-9c54a3068582
e3b85164-7618-4f5a-8145-038f23e4b2fa	a697a798-caaf-4248-8e4e-7e89096a9c30	db0addff-605e-439f-917b-38016a398755
e4d76b35-ca6a-44f9-b134-e3c13aef0a92	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	b651aec8-5455-4329-8251-0ceb62cea798
e4fe50cf-f77f-425a-a9ec-531f74fc7c11	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
ea6983a0-dd57-4c92-8514-078d3d44bc24	4ef1cb5b-9688-4ce2-95b3-6a0863200166	5d962383-f175-4dd8-af63-8a566a0d2255
eab3ffed-a1f2-4283-8fb7-e7ecee3a9874	911f6d7f-8d43-40f2-897a-2f416abf8cf9	cfdb2071-d50e-4ea3-b732-19eb08f1e629
f0a85b58-3659-4c1d-ae35-b20a045610ef	1f97b442-95c5-4b11-93a0-ea146534ae85	5d962383-f175-4dd8-af63-8a566a0d2255
f1047c67-473c-45a1-84f2-f928edc25bdc	163d8c87-8f90-4295-a926-2e912c625a1c	682d36c0-4256-42ab-811e-054ab3a5b10f
f3da8696-80d8-4812-99e8-d32893aea317	c6c6cd04-6df3-4593-b686-e4b9d362c96f	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
f437ad09-5879-42e0-b92f-0c441697c1e9	3356f353-1566-4df6-9958-fa01d67d13c7	7682acb3-561b-4951-801b-c1564adda131
f92637e1-5e4e-4fdd-9309-f0ffbd9b17e1	9858c224-f97f-4ff8-908d-f46bd5e2243c	e99b7773-5d71-4dca-ad36-b896dcfb71c4
ff12aad0-42b4-4e7c-86e3-e413ca9f8a65	9dc69952-eae6-4ec0-a327-67392315f089	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
ff23c591-98c6-4d05-81d5-d92f4d3e859e	9858c224-f97f-4ff8-908d-f46bd5e2243c	db0addff-605e-439f-917b-38016a398755
ff71fdde-53ac-4941-ba5d-e7025408a80d	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	db0addff-605e-439f-917b-38016a398755
ffdd46f4-6c9c-463a-b305-42cc9f8cc094	163d8c87-8f90-4295-a926-2e912c625a1c	e99b7773-5d71-4dca-ad36-b896dcfb71c4
\.


--
-- Data for Name: mst_designations; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "SubDepartment", "DefaultRoleId") FROM stdin;
0525d830-ead9-44a0-871f-91b7845fec26	core_director_and_chief_technology_officer	Director and Chief Technology Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 10:24:51.783926+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Leading Compliance & HR Department	66e48815-4d4f-41d0-9c5f-26a7b7ba296c
0b6ab354-1fcf-4a00-9be3-e58e99c425ed	services_testing_pentester_ii	PenTester - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.930296+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
0c1a5ef4-7fca-45dc-8253-87afa21a1df9	services_operations_soc_analyst_iv	SOC Analyst - IV	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.880491+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
138434a2-625f-4df5-836d-fcf0cfceef79	functional_project_m_senior_pmo_ii	Senior PMO - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.851761+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
41d1dc59-ea33-44eb-8958-dcf35ad051b0	zz_probe_department_zz_probe_designation	ZZ Probe Designation Edited	f	36d04440-a8bb-47f1-a6d9-1f4d144b0bdb	2026-10-18 13:00:09.499474+00	2026-10-18 13:00:09.78908+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:00:09.78908+00	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	services_operations_intern	Intern	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.904989+00	2026-10-21 09:37:57.796708+00	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
9050e021-7d84-4401-820e-c0e768abb1ab	functional_project_m_intern	Intern	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.861092+00	2026-10-21 09:37:57.796708+00	\N	\N	\N	Functional - Project Management	64e2ea37-cbd7-4127-b65b-3b003235981a
bb7ccd5f-2f60-49fb-b984-f11fc47add22	rd_research_and_deve_intern	Intern	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.870785+00	2026-10-21 09:37:57.796708+00	\N	\N	\N	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393
caa227a1-2dcf-4195-ab9c-8f76d1862daa	functional_accounts_intern	Intern	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.809802+00	2026-10-21 09:37:57.796708+00	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
711d4f25-dd76-46cc-accd-4e17e0d6f5cd	zz_ui_department_zz_ui_designation	ZZ UI Designation	f	40fed4c8-89b7-4276-b4ef-47fe8cf1ea87	2026-10-18 13:02:39.916388+00	2026-10-18 13:02:54.804242+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 13:02:54.804242+00	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
6105c483-1e32-49ff-848c-f193525e6297	zz_sub_dept_zz_sub_designation	ZZ Sub Designation	f	316c6b23-b976-4e7f-ae22-c8ea15c365cb	2026-10-18 13:13:54.032822+00	2026-10-18 13:13:54.103213+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:13:54.103213+00	ZZ Probe Sub-Department	cd2a32ed-32fc-47bc-88a9-e6fc48863869
2076a9b1-e432-46a9-99b1-36e732159856	services_consulting_intern	Intern	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.924658+00	2026-10-21 09:37:57.796708+00	\N	\N	\N	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9
47dbf38f-c022-47bc-8444-d0dfb35ff3fd	services_testing_intern	Intern	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:52.004312+00	2026-10-21 09:37:57.796708+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra, Services - Testing - DevSecOps, Services - Testing - Red Team, Services - Testing - Cloud & AI	92aa9169-28d9-4754-a570-553b067642ed
0a60fb48-99c4-44d0-8d97-ff687ccffc9f	services_testing_red_team_practitioner_ii	Red Team Practitioner - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.986648+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Testing - Red Team	92aa9169-28d9-4754-a570-553b067642ed
155642eb-a633-4460-b658-aca9fde2d817	functional_accounts_accountant_i	Accountant - I	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.797934+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
157d001c-b056-45b1-96a3-3c05bcd8d99c	functional_sales_customer_success_representative_ii	Customer Success Representative - II	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.830775+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Sales	914d8500-03b6-4a43-a250-244effca1cf1
163d8c87-8f90-4295-a926-2e912c625a1c	services_testing_pentester_iii	PenTester - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.932399+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
168d11d7-ca26-4d61-b870-51779dc63023	services_testing_associate_manager_ii	Associate Manager - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.955906+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab
195d6a81-8457-4b60-9382-6a3a0664f0e9	services_consulting_associate_manager_iii	Associate Manager - III	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.920769+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Consulting	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a
1e7faab8-273d-40df-9f9a-485160186c5a	services_consulting_grc_auditor_i	GRC Auditor - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.908929+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9
1f97b442-95c5-4b11-93a0-ea146534ae85	functional_accounts_senior_accountant_iii	Senior Accountant - III	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.807813+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
272973a6-c052-4aef-bf32-9e24f7eb6cc9	functional_sales_associate_customer_success_representative_i	Associate Customer Success Representative - I	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.837646+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
2a76927c-461a-48e4-8190-dea7361ef3db	functional_project_m_associate_pmo_ii	Associate PMO - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.847585+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
2b1558e3-158a-4a84-ae80-053129861a64	services_consulting_senior_vice_president_principal_consultant	Senior Vice President - Principal Consultant	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.922717+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Consulting	64c49f37-a38a-46a6-9622-7427f1501658
2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	services_consulting_grc_auditor_ii	GRC Auditor - II	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.910823+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9
3356f353-1566-4df6-9958-fa01d67d13c7	rd_research_and_deve_python_developer_ii	Python Developer - II	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.866732+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393
35a6b1af-dc78-4632-a9f4-eedabdbdcb52	services_testing_devsecops_practitioner_ii	DevSecOps Practitioner - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.97275+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed
3b7ea453-324e-40a0-bb41-77a0795d5af5	services_testing_associate_project_manager	Associate Project Manager	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.961716+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	29ad5710-1621-4c24-ac75-dedfc168ba1a
3e60b693-d3dd-4481-95c4-9f02da21625c	services_consulting_senior_grc_auditor_ii	Senior GRC Auditor - II	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.91882+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Consulting	701aaa2c-a899-4def-bf5f-e17511874409
444df30d-c195-42ad-b9a7-d80cdef69ccd	services_operations_soc_shift_lead_i	SOC Shift Lead - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.894767+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85
4650d4e0-f73c-4688-ae5f-830a46348ff9	services_operations_siem_admin_ii	SIEM Admin - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.884354+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
48429bb5-c583-4684-b30a-7ed443b671ca	services_operations_soc_analyst_ii	SOC Analyst - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.876768+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
485012d4-2c28-4bc4-92c7-3609e3e3749e	functional_hr_senior_hr_executive_i	Senior HR Executive - I	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.820547+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
4b680e29-b4fb-4689-9afb-67a7f089f52b	services_testing_red_team_specialist_ii	Red Team Specialist - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.994166+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Testing - Red Team	29ad5710-1621-4c24-ac75-dedfc168ba1a
4ef1cb5b-9688-4ce2-95b3-6a0863200166	functional_accounts_senior_accountant_i	Senior Accountant - I	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.803595+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
4f972924-350a-47fb-a6b6-f2b34bb6b621	services_testing_pentester_i	PenTester - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.928383+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
6193be76-40ad-4973-9ee7-246a4d8f4109	functional_sales_director_product_sales	Director - Product Sales	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.832885+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
632bf06c-f646-4edd-bf2d-e3cd2e034c7f	services_testing_senior_pentester_i	Senior Pentester - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.936785+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
6d25ff6d-e13d-440f-b775-215547af7acb	services_operations_soc_analyst_i	SOC Analyst - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.874793+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
6e606c29-2ebf-4ab8-8006-aaedd5680009	functional_accounts_accountant_iii	Accountant - III	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.801711+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	services_operations_soc_consultant_i	SOC Consultant - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.890218+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
73bd55bb-5d0e-4381-8ad2-2238377fca93	functional_it_admini_desktop_support_engineer_ii	Desktop Support Engineer - II	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.792134+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa
767a00dd-6f09-4f64-a44e-8fbe901222af	services_testing_devsecops_practitioner_iii	DevSecOps Practitioner - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.976579+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed
778f1120-9633-4933-9160-ddaa46668838	core_director_and_chief_executive_officer	Director and Chief Executive Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 10:24:51.776662+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Leading Sales & A/C Department	62a927b7-9fd8-461a-b64e-1aa441eeba4d
7c2380da-3ee6-46ad-93d6-a79ce3027f29	services_consulting_grc_auditor_iv	GRC Auditor - IV	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.915028+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9
7d542941-65b9-499b-81b3-239748d6da52	functional_hr_recruitment_coordinator_i	Recruitment Coordinator - I	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.8165+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
7e7d954f-34b5-4c23-8c3f-698ec920e9e4	functional_sales_associate_customer_success_representative_ii	Associate Customer Success Representative - II	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.839641+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
834c9e15-c70d-4a0b-bb12-5e55f23c181d	functional_project_m_delivery_account_manager_i	Delivery Account Manager - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.853646+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89
85cc9fbe-98a4-464d-a638-05f40529c6de	services_testing_red_team_practitioner_iii	Red Team Practitioner - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.991312+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Testing - Red Team	92aa9169-28d9-4754-a570-553b067642ed
8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	services_consulting_grc_auditor_iii	GRC Auditor - III	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.912801+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9
8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	services_testing_senior_cloud_security_consultant_i	Senior Cloud Security Consultant - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.997244+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Testing - Cloud & AI	29ad5710-1621-4c24-ac75-dedfc168ba1a
8b57cfd5-5d4e-44a3-9646-b36873c111c2	functional_project_m_senior_delivery_account_manager_i	Senior Delivery Account Manager - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.857373+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89
8dc0d8fe-593d-422a-8b27-5b68fbe6d224	functional_accounts_accountant_ii	Accountant - II	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.799807+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	functional_hr_hr_head	HR Head	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.814553+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
911f6d7f-8d43-40f2-897a-2f416abf8cf9	services_operations_soc_consultant_ii	SOC Consultant - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.892032+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
96efad7d-8b7f-4d7f-a862-c0a6bec3789f	functional_accounts_senior_accountant_ii	Senior Accountant - II	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.805714+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
9858c224-f97f-4ff8-908d-f46bd5e2243c	services_testing_pentester_iv	PenTester - IV	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.93473+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	rd_research_and_deve_python_developer_iii	Python Developer - III	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.868943+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393
9dc69952-eae6-4ec0-a327-67392315f089	functional_project_m_senior_delivery_account_manager_ii	Senior Delivery Account Manager - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.859188+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89
a697a798-caaf-4248-8e4e-7e89096a9c30	services_testing_manager_i	Manager - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.966138+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	efc1df20-ca04-44a6-87b2-7cae1ff50a88
aaf4ca75-5fa5-4de2-8353-a5e93beecb56	services_testing_associate_manager_iii	Associate Manager - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.957817+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab
ae255622-ddcc-45ea-a699-8ec416fe57ab	services_testing_devsecops_practitioner_i	DevSecOps Practitioner - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.969279+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed
af8a1442-c5ee-409d-aa91-61c9dba852ee	services_operations_siem_admin_iii	SIEM Admin - III	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.886248+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
b2b687ef-fd62-4cb7-a826-b40a35da7b2c	functional_sales_business_development_associate_i	Business Development Associate - I	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.828797+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Sales	914d8500-03b6-4a43-a250-244effca1cf1
b3309eea-7374-4a8d-ac13-481b2a7fd492	functional_project_m_associate_pmo_i	Associate PMO - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.845704+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
b5f39dd8-c305-489d-9f7d-9adfd010a134	services_operations_soc_lead_i	SOC Lead - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.899202+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	111cc3cd-6d35-43ce-be91-dde90d3d4015
c0e1a001-0000-4000-8000-000000000001	core_intern	Intern	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-10-13 17:54:19.140561+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Across all Sub Departments	f29af015-7833-4f9a-ac57-6fbef5bf91ec
c0f974c3-f49c-449a-9276-aa64ce501344	services_operations_soc_shift_lead_ii	SOC Shift Lead - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.896662+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85
c1fa4328-a970-48a1-bc08-d50fe36bf44c	services_testing_devsecops_specialist_ii	DevSecOps Specialist - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.983425+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Testing - DevSecOps	29ad5710-1621-4c24-ac75-dedfc168ba1a
c2e248c8-e917-445f-9f7b-1e25d7bb5abe	functional_hr_recruitment_coordinator_ii	Recruitment Coordinator - II	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.818555+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
c6c6cd04-6df3-4593-b686-e4b9d362c96f	services_testing_devsecops_associate	DevSecOps Associate	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.980181+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Testing - DevSecOps	a3793f87-7f3c-41a1-a675-236fc1b710ab
c70b9832-841e-4864-9b85-eaba3c0a995f	functional_it_admini_desktop_support_engineer_i	Desktop Support Engineer - I	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.78998+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa
c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	functional_project_m_senior_pmo_i	Senior PMO - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.849476+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
d8a2b9e5-f54d-4344-a78d-c6c840467543	functional_project_m_delivery_account_manager_ii	Delivery Account Manager - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.855524+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89
da990f6e-3379-4cc4-89b7-0ead29da472b	functional_it_admini_it_admin	IT Admin	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.787896+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa
dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	services_consulting_senior_grc_auditor_i	Senior GRC Auditor - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.916903+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Consulting	701aaa2c-a899-4def-bf5f-e17511874409
e228c999-bf54-48b4-a373-d2bc9db88554	services_testing_associate_manager_i	Associate Manager - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.953968+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab
e2b4be77-2b20-4064-974d-e6322e7240b4	services_testing_associate_ai_engineer_contractual	Associate AI Engineer - Contractual	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:52.001242+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Testing - Cloud & AI	92aa9169-28d9-4754-a570-553b067642ed
e2c675a7-92dc-4477-be75-9a304cbe4def	functional_sales_sales_associate	Sales Associate	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.83517+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
e36018c5-bf48-4f93-bef7-93e8864a0b51	services_operations_siem_admin_iv	SIEM Admin - IV	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.888229+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85
e4e20503-cd55-4393-83fd-6c7e7d7d0a49	functional_hr_senior_hr_executive_ii	Senior HR Executive - II	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.8227+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	services_testing_senior_pentester_ii	Senior Pentester - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.93907+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
ea315f7d-d597-41b3-a999-4f3851bcd020	services_operations_siem_admin_i	SIEM Admin - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.88251+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	services_operations_principal_manager_i	Principal Manager - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-10-10 07:26:56.213994+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	3d068c2f-d0a1-4045-bad9-0f3a43efec4f
eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	services_operations_soc_lead_ii	SOC Lead - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.901107+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7
f20a7445-0b01-4f20-85a5-853101d864ee	services_operations_soc_analyst_iii	SOC Analyst - III	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.878659+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	rd_research_and_deve_python_developer_i	Python Developer - I	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.864858+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393
ffed7aa1-e88f-4281-919f-8d49fbabf5a5	core_director_and_chief_operating_officer	Director and Chief Operating Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 10:24:51.781954+00	2026-10-18 07:48:56.513137+00	\N	\N	\N	Leading Delivery Department	a5bfe265-981a-4723-b7bb-6ddc389db7f0
e2b10def-c91d-45da-94c5-f5530e743aa2	functional_sales_intern	Intern	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.841726+00	2026-10-21 09:37:57.796708+00	\N	\N	\N	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
e8c22eff-0daf-4690-a537-c8b0b6110a01	functional_hr_intern	Intern	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.824863+00	2026-10-21 09:37:57.796708+00	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
f8502c44-b289-49e4-8401-3dcad4d5bbe0	functional_it_admini_intern	Intern	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.794108+00	2026-10-21 09:37:57.796708+00	\N	\N	\N	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa
\.


--
-- Data for Name: mst_email_domains; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_email_domains ("Id", "Code", "DomainName", "DisplayName", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
5112286a-225d-4b86-b16f-74211d9c5779	talakunchi_com	talakunchi.com	@talakunchi.com	t	1	2026-08-21 19:12:04.483485+00	\N	\N	\N	\N
a19f97e1-8bf5-4b14-823a-b653b62c2954	talakunchi_in	talakunchi.in	@talakunchi.in	t	2	2026-08-21 19:12:04.483485+00	\N	\N	\N	\N
fb66fff9-7911-47de-bde7-ab5fb5ab0757	squad1_io	squad1.io	@squad1.io	t	3	2026-08-21 19:12:04.483485+00	\N	\N	\N	\N
9f408de4-fcac-4b0f-b696-df83a2c0c248	zz_probe_example	zz-probe-edited.example	zz-probe-edited.example	f	4	2026-10-18 13:00:09.206787+00	2026-10-18 13:00:09.676327+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:00:09.676327+00
\.


--
-- Data for Name: mst_employee_statuses; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_employee_statuses ("Id", "Code", "Name", "IsActive", "AllowOnboarding", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
26e2b2e5-b1ab-40af-8f6d-2b80deb463a0	absconded	Absconded	t	f	3	2026-09-07 06:03:13.27055+00	\N	\N	\N	\N
a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	terminated	Terminated	t	f	2	2026-09-07 06:03:13.27055+00	\N	\N	\N	\N
beee234f-c734-4d09-a0bb-96a6cc523cc3	resignation_under_review	Resignation Under Review	t	f	5	2026-09-07 06:03:13.27055+00	\N	\N	\N	\N
ce28b4c5-a343-493b-9404-96c983768850	resigned	Resigned	t	f	4	2026-09-07 06:03:13.27055+00	\N	\N	\N	\N
e273e2ed-5fd3-4564-bb87-09a71cd4779a	active	Active	t	t	1	2026-09-07 06:03:13.27055+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_graduation_degrees; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
0712499d-fdc0-4a12-8fd7-7284f5531cb3	bs	BS	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
1dc7caa3-b89b-4246-8217-21c6dd59bf4b	bpharm	B.Pharm	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
511beb93-c358-41f3-b39b-463910bf94e6	bcom	B.Com	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
564c3ffb-209d-43bf-ab2f-2ba5d509357e	ba	B.A.	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
62c3218d-a51e-44ab-8fe0-c57d59270448	btech	B.Tech	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
82ce8912-9b37-4b6a-864e-a7327f8749cb	bba	BBA	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
a77f78ff-221e-400c-8b14-0c847b34bc92	bsc	B.Sc	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
ce12fc28-02e3-4f2c-bf7d-53607b188057	bca	BCA	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
e89b166b-ebc0-4132-8170-92ea1e78e9d0	be	BE	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
09e8e464-0642-466a-8ca4-37f3bc37d4d0	be	B.E.	t	2026-09-11 05:28:07.455053+00	\N	\N	\N	\N
6620d8cb-2725-465f-956e-6a7ba990bd6d	zz_probe_btech	ZZ Probe BTech	f	2026-10-18 13:00:09.3461+00	2026-10-18 13:00:09.725032+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:00:09.725032+00
\.


--
-- Data for Name: mst_industries; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
7f460c51-01ec-4da1-8f71-d6f360b56f91	healthcare	Healthcare	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
f175fde9-14f8-40e8-b564-47d8a29d84ff	logistics	Logistics	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
c7e82721-829b-4450-8393-022587178471	energy	Energy	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
4a80bfdb-a191-4ce1-ab51-2142eb366db7	banking	Banking	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
935db8d7-e2aa-417e-839e-b51d00ce951e	retail	Retail	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
e722474e-d845-42b8-978e-91a6ec78f080	manufacturing	Manufacturing	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
ff5e83cc-9c1c-4056-ab0b-42a70714ddd3	media	Media	t	2026-08-20 06:15:51.759149+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dcb2b955-8d33-4b9b-b04a-64208dce1520	telecom	Telecom	t	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
3660a2cd-772b-4686-a733-126d361946a5	ZZTI	ZZ Temp Industry Renamed	f	2026-10-18 09:56:57.884294+00	2026-10-18 09:56:58.15001+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	cc9bf92a-b923-8364-be83-4bb68db79cd2	2026-10-18 09:56:58.15001+00
7dcea719-4730-4150-aace-58a3b63aec79	BANKING2	Banking 2	f	2026-10-18 10:02:32.030552+00	2026-10-18 10:05:22.613792+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 10:05:22.613792+00
8e0492bb-3e1c-47b8-890c-a2aa8cdd3a03	INDUSTRYTEST	INDUSTRY Test	t	2026-10-18 10:24:11.848396+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: mst_modules; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_modules ("Id", "Code", "Name", "Route", "IconKey", "SortOrder", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
168b1296-de6a-4f9e-a3b9-617b83863736	projects	Projects	/projects	folder-kanban	30	t	2026-10-21 09:54:43.015818+00	\N	\N	\N	\N
471bc977-be2e-449d-91e7-5c11cb9c4ec0	dashboard	Dashboard	/	layout-dashboard	10	t	2026-10-21 09:54:43.015818+00	\N	\N	\N	\N
4e57fd71-b53e-43c0-862e-5698e09c0922	customers	Customer	/customers	building-2	50	t	2026-10-21 09:54:43.015818+00	\N	\N	\N	\N
5a049953-8170-4ef4-a59e-43dc19e12de5	action-centre	Action Center	/action-centre	list-checks	20	t	2026-10-21 09:54:43.015818+00	\N	\N	\N	\N
6055ce3c-b466-4354-ba9a-b4c309111e9d	my-team	My Team	\N	users	70	t	2026-10-21 09:54:43.015818+00	\N	\N	\N	\N
715f79ce-51ea-46d3-b95d-8318840f90a6	resources	Resources	/resources	users	40	t	2026-10-21 09:54:43.015818+00	\N	\N	\N	\N
c04c546e-0f2c-448d-b634-5d517843d365	repository	Repository	/repository	building	60	t	2026-10-21 09:54:43.015818+00	\N	\N	\N	\N
fcb69b3e-e5aa-49bb-921f-7793f0a8c90d	settings	Settings	\N	settings	80	t	2026-10-21 09:54:43.015818+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_nationalities; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
-- Data for Name: mst_offices; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_offices ("Id", "Code", "Name", "WorkLocationId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_onfloorrole_sub_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_onfloorrole_sub_departments ("Id", "OnFloorRoleId", "SubDepartmentId") FROM stdin;
002c16ad-5e52-46cc-a1cc-a719a067a437	c4d57da3-eff2-4cd1-834f-e0d77b39f299	db0addff-605e-439f-917b-38016a398755
007a15a7-2740-4161-8554-d544a917a74c	ae6e9e5b-7337-47a3-8fe5-bb02a9a7f374	fd84aa38-11ef-46af-ade7-241f2a2c08fd
01fdc2e5-c78d-4334-9e31-aa4265908bb9	67bdeca7-fe42-4b4e-b5b6-9e8e8d410413	cfdb2071-d50e-4ea3-b732-19eb08f1e629
020fcdbb-4006-4557-913a-21713f03df4e	734614d6-908f-4f24-8331-c515a6d70149	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
021c2d88-351c-40c8-a334-5b72f9f86391	c4ef6b03-baa6-47ac-8d06-c8819ddbdaa7	c88d783b-b628-4f3a-a972-aa56aeed5e77
08934036-8e43-4d8c-8d7c-9d4fa7cc277c	1abc8fed-e830-4103-a5ab-c3402b166116	63765624-d7d1-472d-abd4-627127646998
09762092-5081-4cb1-9b4e-b9314b5cf6c8	acf26b08-e6ae-4343-9bf9-529b070835a3	cfdb2071-d50e-4ea3-b732-19eb08f1e629
097bae40-1751-45f5-97af-b93cb43a9bc1	5814389a-4416-4e4d-96a7-58f4801e2757	e99b7773-5d71-4dca-ad36-b896dcfb71c4
0b2dd303-187c-4b5a-aafc-fc823af6d72a	21c47c58-0be4-41bb-8407-8df5fa4b8e9d	cfdb2071-d50e-4ea3-b732-19eb08f1e629
0b50c5a0-f701-4423-af2a-6c8f508a2cd0	b7425734-5262-4802-9a10-5e3141b11d6c	c88d783b-b628-4f3a-a972-aa56aeed5e77
0c41dca9-895a-469d-9131-e4c6f626d7b1	f39ba18d-6be5-4d23-a99f-f8d7a68c43dc	c88d783b-b628-4f3a-a972-aa56aeed5e77
0d6a05a9-705c-4bc7-b3ac-fc4a2c730cac	36339f27-5abf-4ffc-bca3-5a2333a94df2	db0addff-605e-439f-917b-38016a398755
108da61e-b9cf-44af-aed2-16d6a1ea87a2	d8d41d59-fe4b-4c54-80d3-751a7bbf714c	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
131a95be-ee22-4af7-a725-c05f1d0042ac	27d8ec30-01ad-45f2-a7d8-7a54c2d2c754	cfdb2071-d50e-4ea3-b732-19eb08f1e629
136676fe-a7b7-4b22-9b9e-8dbe5ba550e2	e061fae9-2430-4025-ad39-ff79717301a5	e99b7773-5d71-4dca-ad36-b896dcfb71c4
16d3a76d-9ced-41cf-909e-411b50ace311	8765d1b0-e4fc-4686-91ea-f5ad4e929818	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
18d7bfdb-b9cf-413a-bdf8-887ba558c3aa	fec21974-29e7-4dcf-8438-efb813045170	45755b2a-741a-4990-ab78-8f65090f75b1
1c7fc6e2-2365-4809-9a9f-6dd56ec1e0d9	b24b3d9d-7454-4657-bb24-3c4f0f40956e	7682acb3-561b-4951-801b-c1564adda131
1e03e086-8e70-40dc-a0de-c3c1096354cf	6eaffc67-3d6e-4bb6-9c90-0a604398090d	db0addff-605e-439f-917b-38016a398755
21ad6cc5-d496-4cdb-a9ff-d45f6b3fb754	9ad0a166-cde2-4817-9acd-363d217422d9	682d36c0-4256-42ab-811e-054ab3a5b10f
24fa37e7-6102-4ae3-89c2-f647ac1c18e7	8765d1b0-e4fc-4686-91ea-f5ad4e929818	b651aec8-5455-4329-8251-0ceb62cea798
25fec8a6-3f90-43e6-ad16-99d255b6bb96	59cf62d4-7c2d-4e4c-b075-0db51d40ea4e	7682acb3-561b-4951-801b-c1564adda131
27fc73be-8e56-4979-a204-901746df64aa	3d74762f-cfbc-4cb9-b172-c2aaffc64f30	fa773eb9-162f-4ea8-9fc4-9c54a3068582
28bc0c2c-ea96-4de2-af55-56b590f797b5	ccf1432a-d667-4fff-8071-efbc9f841976	5d962383-f175-4dd8-af63-8a566a0d2255
2d5dbffc-76de-4e35-b691-bf559a429371	4d8c99f7-b5c4-434a-ae7c-64419a5a1bcf	c88d783b-b628-4f3a-a972-aa56aeed5e77
2e6155f4-c25c-45a8-bab3-3fdcc4e9878a	475cc74e-698a-4547-966a-823be44cfd15	7682acb3-561b-4951-801b-c1564adda131
2f3a5daa-dec2-4f49-8f8a-82e733e852c4	eb9edaa3-2522-4d91-ab86-d786a7250f91	b651aec8-5455-4329-8251-0ceb62cea798
2f8368bf-d9a4-4d72-b588-2c09d06802eb	b9f75ed9-10c6-4b61-ad05-b27ec89a8b3b	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
3377c170-07e3-49ee-9d86-3aefb64cf4fe	03d492f0-4458-48e5-9ee8-06f09f660218	cfdb2071-d50e-4ea3-b732-19eb08f1e629
33d2a40d-5da0-4ac8-98cf-1ba0e862ec0e	70480603-7eae-41f7-b659-052b7500ca91	fa773eb9-162f-4ea8-9fc4-9c54a3068582
3ac11625-8658-45ba-b214-f08b4c778abc	22a8384f-6070-4554-89f1-ee327ae48f16	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
40452ce1-2aad-4a8d-bee7-a491cfeaef4d	6890c399-940e-4c2a-9aba-0dd90a50e063	cfdb2071-d50e-4ea3-b732-19eb08f1e629
47123bdc-425c-4248-bf0a-27f7e13a1bb6	7d2b7826-2f63-4796-9032-5ffa35cd5b37	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
477d8aa6-5e34-47a6-871b-cabdf9eebc59	8765d1b0-e4fc-4686-91ea-f5ad4e929818	db0addff-605e-439f-917b-38016a398755
5061c2f9-f58f-42b9-91bb-5028eb690254	01a26d31-4fcd-4ad3-b08e-1276a4620cb8	cfdb2071-d50e-4ea3-b732-19eb08f1e629
54948db2-d289-4c87-b7a2-86bcee60164e	9326acb0-20c1-4d05-89b6-d85ee3425469	cfdb2071-d50e-4ea3-b732-19eb08f1e629
56f434b4-6d44-4abb-8906-31e0be1a79fe	8211f0b1-d111-400b-94ab-fd663d50ec65	7682acb3-561b-4951-801b-c1564adda131
5727a2a0-cdca-4898-b2b4-e7cc5ed3e1da	6eaffc67-3d6e-4bb6-9c90-0a604398090d	682d36c0-4256-42ab-811e-054ab3a5b10f
58f42190-b0f9-4ae5-b0fe-ad00900a58a6	4766e158-b2c1-44dd-a36d-18583c490193	fd84aa38-11ef-46af-ade7-241f2a2c08fd
5afb2565-e8a4-4783-a6cd-70d3ce1b418c	e3c262a4-4108-4592-abb0-643085d6a305	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
5b826512-bb12-4b40-a28f-6fe2e8fb95a4	8765d1b0-e4fc-4686-91ea-f5ad4e929818	88b29e0c-39b7-4169-ab5c-350075014a84
5f06b15b-b7a5-4b4b-9752-ae3a4e961ee0	0837f524-0260-4283-a37f-6e1fb06d3dcd	b651aec8-5455-4329-8251-0ceb62cea798
61a53bfd-7db0-4648-b970-136c01576917	e061fae9-2430-4025-ad39-ff79717301a5	682d36c0-4256-42ab-811e-054ab3a5b10f
64355b5b-2c24-42a4-b1e0-61b597f7abc1	ce7509b0-415c-4d04-a2d8-43c3ee382a72	a73eb36c-7d62-4aa8-901d-1c70b3876b69
64ace56c-8467-47f4-a76c-e0a33c22f0e1	8765d1b0-e4fc-4686-91ea-f5ad4e929818	682d36c0-4256-42ab-811e-054ab3a5b10f
6671c22e-106d-42a1-a66d-d1b5e7f2f3a5	dfa4b2c2-7d48-4ff7-b5aa-9b65fbde04e1	e99b7773-5d71-4dca-ad36-b896dcfb71c4
686c9423-d935-4ce9-9f11-c352d822ffed	87ea604f-b245-49c0-9172-3956f1d6eb75	682d36c0-4256-42ab-811e-054ab3a5b10f
6be18b6e-c34f-40a0-bde9-f4f5097114ad	b4b2673b-fc1c-4484-8f2d-903a39dff2a9	fa773eb9-162f-4ea8-9fc4-9c54a3068582
703feb61-8109-4409-8a4d-a4f53540712a	dfa4b2c2-7d48-4ff7-b5aa-9b65fbde04e1	682d36c0-4256-42ab-811e-054ab3a5b10f
70982c9c-3d5d-40ea-a6be-99a318e3405d	39c52128-53f4-4e39-8102-4b9ccc9f5584	db0addff-605e-439f-917b-38016a398755
7610cd3c-03e0-403e-9211-548e0e28d7e1	87ea604f-b245-49c0-9172-3956f1d6eb75	db0addff-605e-439f-917b-38016a398755
77e0be58-6c83-47af-bffb-625d134bfa4e	f51841ca-ffbc-4619-98be-201d736e4f48	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
78b94bb3-dca2-4aa8-bd07-5adec4a1a8e5	a885d8fe-9ecc-4c4e-9b23-55c015ffd3e6	db0addff-605e-439f-917b-38016a398755
795a7f80-233a-485d-820d-ab81c1f4b16d	3101ee42-6788-4ae4-a80b-f7394720b740	fa773eb9-162f-4ea8-9fc4-9c54a3068582
7c580455-e7f3-48f1-af90-22d22d11d74a	a1826c58-197f-4c7e-9909-a8970491fe38	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
7ca06264-e988-4fbb-8c8b-cf589640c9af	d412d761-e42e-4ab2-8e58-1df17b290365	5d962383-f175-4dd8-af63-8a566a0d2255
7d8e449b-dae2-4f28-b7df-9a1d90b1ecaf	885809b5-843a-4ec9-bafe-da1472b73a03	cfdb2071-d50e-4ea3-b732-19eb08f1e629
7f92bd15-f15a-41fb-814b-c9308073e885	0c18f8ce-b9be-4ec0-a099-44b0fd29bdcd	682d36c0-4256-42ab-811e-054ab3a5b10f
81a896f9-c66d-4b1f-b071-99b181c5eb72	acbe4f0d-8058-4a88-9255-08104f0037b6	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
8883b68a-2fe2-470b-b9fe-535a77e38404	2d4e6116-3ec3-4c5d-9d75-35517814a964	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
8aac319e-5301-42dd-8fca-b66a7e4dd8a8	36339f27-5abf-4ffc-bca3-5a2333a94df2	e99b7773-5d71-4dca-ad36-b896dcfb71c4
90cdb9ea-59d1-4e23-ab9a-c0046041cf06	ec4a89e1-35a6-495a-83c9-b6a34ee00402	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
9187547c-cec3-4e31-8688-1c67281a39b8	e1f2260d-b878-4693-86db-2513390804aa	cfdb2071-d50e-4ea3-b732-19eb08f1e629
92ff3718-8008-41d4-bb3d-dd53d608aa83	da608430-bf9a-4a87-9881-1c07e7f2974a	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
93272d4a-88b7-49e3-a354-e00d114e1c24	9ed3ce2c-add0-4472-9da8-4cd5c0552867	5d962383-f175-4dd8-af63-8a566a0d2255
94ed5e9c-8822-4398-9764-455d8f5eb1c2	e60fe13f-6f3e-4410-80c9-dcfbb88f0301	a12ac80b-a665-4301-898e-e9ca3d44bb20
95f9d29d-4a15-403c-8400-fcf2d2fc02d3	0c18f8ce-b9be-4ec0-a099-44b0fd29bdcd	db0addff-605e-439f-917b-38016a398755
97ebe3fe-a109-4a1f-a5e9-47fc6201a70c	36339f27-5abf-4ffc-bca3-5a2333a94df2	682d36c0-4256-42ab-811e-054ab3a5b10f
a0945224-dd0e-4c33-a796-958979c841e3	b9232654-c160-4e84-bdc3-ad94a605dbe1	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
a105b0a3-e38d-4fc1-8bad-b4f8c7a05d76	9ad0a166-cde2-4817-9acd-363d217422d9	e99b7773-5d71-4dca-ad36-b896dcfb71c4
a2b3375a-1aa0-4f6f-90e4-a4f25c682070	5814389a-4416-4e4d-96a7-58f4801e2757	682d36c0-4256-42ab-811e-054ab3a5b10f
a4144dc6-b0a3-4558-af8f-881245f33e78	8765d1b0-e4fc-4686-91ea-f5ad4e929818	e99b7773-5d71-4dca-ad36-b896dcfb71c4
a41c1516-95fd-476d-8f69-70751892a586	56779122-3301-4a2c-bc35-085f96ee714b	c88d783b-b628-4f3a-a972-aa56aeed5e77
a69a9aba-992f-402a-8b8a-d31edccc7268	e3ede776-6573-4898-9195-fb2a398100b2	fa773eb9-162f-4ea8-9fc4-9c54a3068582
a7a54940-02b2-414f-81e0-ec03f6dc3fa0	7fe8d8b6-c0fc-4015-a3ff-5bb8e95ea0d5	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
a8761aff-1837-4d9f-ad25-7ebe9fa9c633	9635b694-a552-42c0-9df3-a6090c9b1923	61bbeadf-3044-4123-929c-4b1e6e2e613e
aef87f4b-9e90-40c3-bbfa-efcb04df11d6	c5ea1ba3-9974-4cca-9320-362527502c6e	5d962383-f175-4dd8-af63-8a566a0d2255
b2d577a2-5c08-4cde-a932-e9eb92301ed9	c637e1a2-5677-45fa-bbbf-f88fc60a9443	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
b45b10ac-d5b8-46b0-a4c1-49838b122b1b	5814389a-4416-4e4d-96a7-58f4801e2757	db0addff-605e-439f-917b-38016a398755
b95f1b2d-0544-459f-aa58-0d82987f42e8	4cc83d93-7b2f-4c97-a4a7-e9ec47735e4b	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
bb6f87f3-bf81-435e-9396-e38f515d87e7	3091c873-f1f0-4632-ac1e-62d1a451c39d	fa773eb9-162f-4ea8-9fc4-9c54a3068582
bbf9b18d-886c-4058-a895-454d7a90073e	f7a34722-94ab-4e14-ad50-5e5f0b44cca6	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
bd276bb2-e534-4729-85a2-1755184e955d	67084a5d-02d0-4a73-a15f-45aca43adb58	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
bf33887b-0b5d-435f-b517-1cf5f2ae7d9a	bce667dd-cae2-404d-8013-49194e0f48d9	5d962383-f175-4dd8-af63-8a566a0d2255
c1bbd4ca-cf0d-4632-b635-b997bbc9b9c9	e061fae9-2430-4025-ad39-ff79717301a5	db0addff-605e-439f-917b-38016a398755
c36510b3-ae49-4c43-91ec-db8c1ee547c4	dfa4b2c2-7d48-4ff7-b5aa-9b65fbde04e1	db0addff-605e-439f-917b-38016a398755
c88dc62b-b01f-4f31-a0b3-a16e0af8618f	0c18f8ce-b9be-4ec0-a099-44b0fd29bdcd	e99b7773-5d71-4dca-ad36-b896dcfb71c4
c8d4849a-996c-4f71-ad38-274058dedd0a	746752f8-decb-46a0-a7e1-d07a0a68dbc3	fd84aa38-11ef-46af-ade7-241f2a2c08fd
cd59e2ec-9c55-4fdc-a7e9-e5269928d396	39c52128-53f4-4e39-8102-4b9ccc9f5584	682d36c0-4256-42ab-811e-054ab3a5b10f
cead635d-a128-477b-93ca-59c1cb98d2bf	99039771-cd5a-4878-a7b9-9cdaa02f5be6	5d962383-f175-4dd8-af63-8a566a0d2255
cfe34ddc-36b0-4fec-a02d-7da67bdd2a87	f6560080-4b30-4b4b-b8ba-90d5b0ead2da	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
d3d88583-9813-4e3d-ba89-fc959dc5b287	39c52128-53f4-4e39-8102-4b9ccc9f5584	e99b7773-5d71-4dca-ad36-b896dcfb71c4
d53bd6e3-fa47-4c08-a71b-e6276ca72864	f4e2358e-5ec0-4292-8377-438dabb72fbe	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
d566d4a9-8007-4958-9eb7-5c6e73f6c8b1	ecc39c47-956d-49b9-8fbc-44a6433f3912	88b29e0c-39b7-4169-ab5c-350075014a84
d60e5f23-ac93-40f7-9474-ab6b1932f5b2	b5974e61-080c-4de2-a977-7f0bdee29949	cfdb2071-d50e-4ea3-b732-19eb08f1e629
d62bd972-61d0-4f54-9850-73eea4e07fac	5c9266d9-5a57-4b6c-aabc-18edce40ae96	cfdb2071-d50e-4ea3-b732-19eb08f1e629
d7d82b4a-8cd7-478f-a0ed-d23ce0816bdd	580f3fc7-ff2d-4881-a222-d91a7c00f491	c88d783b-b628-4f3a-a972-aa56aeed5e77
d7da356c-0c2a-4af0-936e-549a3b81c3dd	d862a290-2a0a-47f2-9c23-2baf830a37b9	fd84aa38-11ef-46af-ade7-241f2a2c08fd
d990d058-f691-4af2-97e2-ad364aea275b	9ad0a166-cde2-4817-9acd-363d217422d9	db0addff-605e-439f-917b-38016a398755
da8f3c22-3d44-4190-b260-8ed488478546	54123afd-2783-4a41-b18f-328d024e8a22	5d962383-f175-4dd8-af63-8a566a0d2255
dcce28c4-082b-474f-a6e9-48fcf2e8e531	c4d57da3-eff2-4cd1-834f-e0d77b39f299	682d36c0-4256-42ab-811e-054ab3a5b10f
dd267ad2-6a0a-4c17-9cd4-eea4f104fcb2	9ac666ca-eaa2-46a5-b489-66a8cc550b65	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
dd741c27-62b0-46cc-a8df-8aa59e3af788	a885d8fe-9ecc-4c4e-9b23-55c015ffd3e6	682d36c0-4256-42ab-811e-054ab3a5b10f
df0cf426-20c9-4b7c-bdde-dfb1911015b6	a885d8fe-9ecc-4c4e-9b23-55c015ffd3e6	e99b7773-5d71-4dca-ad36-b896dcfb71c4
e65e8f08-3303-488a-a606-eb0f7137269d	56ed9417-a9fd-40ff-a517-1e75bbf02d63	cfdb2071-d50e-4ea3-b732-19eb08f1e629
e9844d78-4cc1-47e0-8b5f-6fb5057b4be0	87ea604f-b245-49c0-9172-3956f1d6eb75	e99b7773-5d71-4dca-ad36-b896dcfb71c4
ea1c9c12-ae18-449c-bcfe-05b4d04d7af4	6eaffc67-3d6e-4bb6-9c90-0a604398090d	e99b7773-5d71-4dca-ad36-b896dcfb71c4
eb3d9224-21d7-46d7-aa4a-37238dc4930c	29119117-9aa3-4def-9db8-802f70f74e4b	cfdb2071-d50e-4ea3-b732-19eb08f1e629
ecb8a1cc-a8dc-4fd0-b62e-8861bc048cf7	d6002117-fdbb-437a-986f-dde6b5b5c162	88b29e0c-39b7-4169-ab5c-350075014a84
ed85e8f7-cca1-4052-862c-5d5ef967b940	67306ff5-e313-43da-99bc-56b6a6ca65ee	fa773eb9-162f-4ea8-9fc4-9c54a3068582
ee36944d-ac97-4c03-9ce8-64d0ca2d886a	23f52e10-894f-4e50-970b-202a3127a1d9	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
ef0324e6-b406-4e3f-a387-91c432e5cdf7	bb6f610b-b2f5-4b01-9ea4-fb9ad074b768	cfdb2071-d50e-4ea3-b732-19eb08f1e629
efe73d61-ffac-48a7-9d87-b99b01d552ff	b25515f1-974c-4b63-a8b6-ca6e7ab95393	cfdb2071-d50e-4ea3-b732-19eb08f1e629
f5c6d594-985e-4408-a930-215bad20f55c	c4d57da3-eff2-4cd1-834f-e0d77b39f299	e99b7773-5d71-4dca-ad36-b896dcfb71c4
f91fcc55-6261-4737-b786-1fe55a842a72	0acaaceb-a951-4492-bdba-69d5e916f8b4	b651aec8-5455-4329-8251-0ceb62cea798
\.


--
-- Data for Name: mst_org_role_map; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_org_role_map ("Id", "DepartmentId", "DesignationId", "RbacRoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "SubDepartmentId", "SubDepartment") FROM stdin;
0717101c-438d-4f69-b0ef-a56fcaf47a45	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
0a909d87-52c0-4ec8-b6f8-b8111cf7310e	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
159c2701-2318-4ba7-b809-fa07d078305e	0aed67b8-c454-439a-a07f-4f46d46d58af	e228c999-bf54-48b4-a373-d2bc9db88554	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
3514262c-d7ec-4d76-81c8-20995e4d22f8	bcbd68c8-c3f3-4396-abb0-0b0e13637958	8dc0d8fe-593d-422a-8b27-5b68fbe6d224	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
359026a0-80bd-4c27-99f3-f63fb1741c6d	310a2f16-15f6-4b82-95f6-ab18b5b429f5	c2e248c8-e917-445f-9f7b-1e25d7bb5abe	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Functional - HR
36243b2d-d487-49db-87d4-a46216df15ae	13c91c98-00ae-4211-acb8-d06e35953806	157d001c-b056-45b1-96a3-3c05bcd8d99c	914d8500-03b6-4a43-a250-244effca1cf1	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
36732dd0-7171-4b3e-a7a6-48427a14f504	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	911f6d7f-8d43-40f2-897a-2f416abf8cf9	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
378f0582-07ec-4a86-a0ff-56575cc28dd0	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	af8a1442-c5ee-409d-aa91-61c9dba852ee	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
37fe770e-4c51-4e31-bbb6-0ca302286b91	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	da990f6e-3379-4cc4-89b7-0ead29da472b	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	Functional - IT Administration
38bd29af-b288-4b62-ae24-679d6b2713ac	8e4e88f1-e294-4554-80cc-92ed6169caeb	834c9e15-c70d-4a0b-bb12-5e55f23c181d	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EM (Engagement Manager)
3bce413c-a323-4f80-a417-190414a3d56b	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	6d25ff6d-e13d-440f-b775-215547af7acb	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
3c8fda3c-c84a-4ef8-80ed-327dc87a3abc	13c91c98-00ae-4211-acb8-d06e35953806	6193be76-40ad-4973-9ee7-246a4d8f4109	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
3f714252-8945-41a7-8520-1c1c8925854e	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	444df30d-c195-42ad-b9a7-d80cdef69ccd	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
4192b456-ca31-4de0-a8ce-698c41732ec4	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	f8502c44-b289-49e4-8401-3dcad4d5bbe0	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	Across all Sub Departments
45469efe-b575-417d-adb7-5c9ee591cb05	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
4804833e-7bbf-4746-9e57-16542de6c3dc	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
49b9c24a-e70e-4cf8-a8c4-e81a49af294b	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
4f83891a-823a-406f-aa9f-5e23abeaba11	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	c0e1a001-0000-4000-8000-000000000001	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	63765624-d7d1-472d-abd4-627127646998	Across all Sub Departments
50581768-4796-4731-b6e2-fc50e877f192	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Across all Sub Departments
554562de-10b1-4365-9e6e-cf769630de75	be8e036d-ad13-4c79-89ec-294e490a6816	2076a9b1-e432-46a9-99b1-36e732159856	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Across all Sub Departments
5808fbe9-5fd4-4e3f-86b4-5a0ad69517bd	be8e036d-ad13-4c79-89ec-294e490a6816	7c2380da-3ee6-46ad-93d6-a79ce3027f29	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
5d79d51f-fcd5-40a1-96e8-8a8ae7c76c00	0aed67b8-c454-439a-a07f-4f46d46d58af	4b680e29-b4fb-4689-9afb-67a7f089f52b	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798	Services - Testing - Red Team
5e1badcc-b621-4c3b-b729-4f3ddf5877a0	8e4e88f1-e294-4554-80cc-92ed6169caeb	9dc69952-eae6-4ec0-a327-67392315f089	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EM (Engagement Manager)
5f392507-7f0b-4614-9679-fcc103e3dbc7	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	73bd55bb-5d0e-4381-8ad2-2238377fca93	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	Functional - IT Administration
651dc356-0c28-457e-bc56-69fdf6ea321f	898c36e9-1cb7-4c56-9148-a3b6893c0149	bb7ccd5f-2f60-49fb-b984-f11fc47add22	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	Across all Sub Departments
6c3fcc16-3602-4bf5-9dd2-7e51fe23d336	0aed67b8-c454-439a-a07f-4f46d46d58af	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798	Services - Testing - Red Team
6ccedaf4-671c-4375-8200-f860eb7d46d9	8e4e88f1-e294-4554-80cc-92ed6169caeb	138434a2-625f-4df5-836d-fcf0cfceef79	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO (Project Management Office)
6df1609a-13f1-469d-96a1-253b2bc66b4f	8e4e88f1-e294-4554-80cc-92ed6169caeb	9050e021-7d84-4401-820e-c0e768abb1ab	64e2ea37-cbd7-4127-b65b-3b003235981a	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	a73eb36c-7d62-4aa8-901d-1c70b3876b69	Across all Sub Departments
72fc796a-c5ba-4bf3-b93f-5b8f52491aed	be8e036d-ad13-4c79-89ec-294e490a6816	2b1558e3-158a-4a84-ae80-053129861a64	64c49f37-a38a-46a6-9622-7427f1501658	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
73687605-0927-471b-b8c2-ec61f4d5164e	0aed67b8-c454-439a-a07f-4f46d46d58af	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
7428ebde-4c77-4358-bc21-6acef30a85a4	13c91c98-00ae-4211-acb8-d06e35953806	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
759ce52f-d3bf-414e-bd79-c33c038dfdf6	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	efc1df20-ca04-44a6-87b2-7cae1ff50a88	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
766c6052-09ad-44e4-8746-ed4795e712f1	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
76ad509e-ba7a-412e-a0cb-be0b8eeb8305	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0c1a5ef4-7fca-45dc-8253-87afa21a1df9	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
003fd050-8939-4d05-ac2b-29876038cb76	be8e036d-ad13-4c79-89ec-294e490a6816	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
047399e0-7821-4f80-be7a-78057c4c2f5f	be8e036d-ad13-4c79-89ec-294e490a6816	195d6a81-8457-4b60-9382-6a3a0664f0e9	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
0a1dda59-5a52-496e-8d30-5f082dbe343e	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	e36018c5-bf48-4f93-bef7-93e8864a0b51	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
0f8dfe0e-d5d5-4a23-b9dc-cff6d71ae84f	8e4e88f1-e294-4554-80cc-92ed6169caeb	2a76927c-461a-48e4-8190-dea7361ef3db	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO (Project Management Office)
128f2bec-ea83-4f7e-8115-9899a302d677	bcbd68c8-c3f3-4396-abb0-0b0e13637958	155642eb-a633-4460-b658-aca9fde2d817	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
15e4938e-241c-4f53-b64e-56a4b2201981	310a2f16-15f6-4b82-95f6-ab18b5b429f5	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Functional - HR
1c213096-46a8-48e1-b353-fdf2d25074ab	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	c70b9832-841e-4864-9b85-eaba3c0a995f	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	Functional - IT Administration
79d8ed54-9a91-4486-a19f-e5485de7b490	0aed67b8-c454-439a-a07f-4f46d46d58af	e2b4be77-2b20-4064-974d-e6322e7240b4	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	88b29e0c-39b7-4169-ab5c-350075014a84	Services - Testing - Cloud & AI
7d7850cf-72da-411d-ba58-bd2d4a43ca28	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	c0f974c3-f49c-449a-9276-aa64ce501344	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
81a34a8f-1fb9-431f-bc96-1bb95dab3fdb	8e4e88f1-e294-4554-80cc-92ed6169caeb	8b57cfd5-5d4e-44a3-9646-b36873c111c2	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EM (Engagement Manager)
81e65582-e98d-4ded-b699-ea7fcb82f071	bcbd68c8-c3f3-4396-abb0-0b0e13637958	4ef1cb5b-9688-4ce2-95b3-6a0863200166	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
837d9855-e239-4046-83d9-ae224ecce6ef	13c91c98-00ae-4211-acb8-d06e35953806	272973a6-c052-4aef-bf32-9e24f7eb6cc9	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
85559f41-c8d4-44b1-8906-a5e1d064f78c	bcbd68c8-c3f3-4396-abb0-0b0e13637958	1f97b442-95c5-4b11-93a0-ea146534ae85	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
86237191-01ee-4aad-9a6b-e75600c375fc	0aed67b8-c454-439a-a07f-4f46d46d58af	c6c6cd04-6df3-4593-b686-e4b9d362c96f	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Services - Testing - DevSecOps
872930ee-4d00-4d37-a2cb-dc57167f6973	0aed67b8-c454-439a-a07f-4f46d46d58af	163d8c87-8f90-4295-a926-2e912c625a1c	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
8a351e0a-8631-4aca-9598-81b276dbc990	0aed67b8-c454-439a-a07f-4f46d46d58af	767a00dd-6f09-4f64-a44e-8fbe901222af	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Services - Testing - DevSecOps
8a92cbcd-7247-4f89-94a4-546013a78a29	13c91c98-00ae-4211-acb8-d06e35953806	e2b10def-c91d-45da-94c5-f5530e743aa2	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Across all Sub Departments
8fbc1e25-42da-426a-be89-975dde3326bc	be8e036d-ad13-4c79-89ec-294e490a6816	3e60b693-d3dd-4481-95c4-9f02da21625c	701aaa2c-a899-4def-bf5f-e17511874409	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
98b476d3-39f3-4af1-83df-00639379db5e	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	48429bb5-c583-4684-b30a-7ed443b671ca	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
999c4385-21ef-4a47-800f-1c08938edcee	be8e036d-ad13-4c79-89ec-294e490a6816	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	701aaa2c-a899-4def-bf5f-e17511874409	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
a0c6147f-a977-4215-840a-60f95d2bd729	898c36e9-1cb7-4c56-9148-a3b6893c0149	9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	R&D (Research & Development)
a2113157-8223-486e-a506-90ae7a3daa93	310a2f16-15f6-4b82-95f6-ab18b5b429f5	7d542941-65b9-499b-81b3-239748d6da52	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Functional - HR
a220a973-9f98-4654-8a57-ee6b44579be5	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	ffed7aa1-e88f-4281-919f-8d49fbabf5a5	a5bfe265-981a-4723-b7bb-6ddc389db7f0	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	45755b2a-741a-4990-ab78-8f65090f75b1	Leading Delivery Department
a3451572-fefd-4cec-aa55-b28d3d3cac92	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	778f1120-9633-4933-9160-ddaa46668838	62a927b7-9fd8-461a-b64e-1aa441eeba4d	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	a12ac80b-a665-4301-898e-e9ca3d44bb20	Leading Sales & A/C Department
a77285b6-5266-4959-8399-f34dfbfcb44e	be8e036d-ad13-4c79-89ec-294e490a6816	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
a7cb72a9-ec77-44e1-998a-a0638f8becc5	0aed67b8-c454-439a-a07f-4f46d46d58af	35a6b1af-dc78-4632-a9f4-eedabdbdcb52	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Services - Testing - DevSecOps
ab07d7c9-e503-4641-8db6-25ac3fc0993e	bcbd68c8-c3f3-4396-abb0-0b0e13637958	caa227a1-2dcf-4195-ab9c-8f76d1862daa	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Across all Sub Departments
af28c045-efab-45db-83dc-c487bab9019f	8e4e88f1-e294-4554-80cc-92ed6169caeb	d8a2b9e5-f54d-4344-a78d-c6c840467543	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EM (Engagement Manager)
b11be1e9-662a-4bc7-b06b-7f401c8b00b3	898c36e9-1cb7-4c56-9148-a3b6893c0149	f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	R&D (Research & Development)
b2819c45-99c7-4306-9ffb-1d585f0a29d0	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	f20a7445-0b01-4f20-85a5-853101d864ee	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
b3eb1bdf-188b-4292-9cfd-f72381c366f0	0aed67b8-c454-439a-a07f-4f46d46d58af	c1fa4328-a970-48a1-bc08-d50fe36bf44c	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Services - Testing - DevSecOps
e99606cb-d413-47ce-9373-9e6384c53f67	36d04440-a8bb-47f1-a6d9-1f4d144b0bdb	41d1dc59-ea33-44eb-8958-dcf35ad051b0	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 13:00:09.499474+00	2026-10-18 13:00:09.78908+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:00:09.78908+00	\N	\N
c461074d-4d3d-4573-9947-e6e8b0c1d921	40fed4c8-89b7-4276-b4ef-47fe8cf1ea87	711d4f25-dd76-46cc-accd-4e17e0d6f5cd	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 13:02:39.916388+00	2026-10-18 13:02:54.804242+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 13:02:54.804242+00	\N	\N
f3262a1f-1da9-4619-b644-0bfab7a16c27	316c6b23-b976-4e7f-ae22-c8ea15c365cb	6105c483-1e32-49ff-848c-f193525e6297	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 13:13:54.032822+00	2026-10-18 13:13:54.103213+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:13:54.103213+00	\N	\N
222358f3-3516-49b6-b7db-60f936d4a8c9	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	0525d830-ead9-44a0-871f-91b7845fec26	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	61bbeadf-3044-4123-929c-4b1e6e2e613e	Leading Compliance & HR Department
2a21a67d-6020-4c2c-b06c-9e394c101fab	be8e036d-ad13-4c79-89ec-294e490a6816	1e7faab8-273d-40df-9f9a-485160186c5a	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
2d9893c2-a2b8-4a26-a41d-85061c629ec2	310a2f16-15f6-4b82-95f6-ab18b5b429f5	e4e20503-cd55-4393-83fd-6c7e7d7d0a49	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Functional - HR
2faf5d1b-751e-4a11-9b34-33bf797eef82	13c91c98-00ae-4211-acb8-d06e35953806	e2c675a7-92dc-4477-be75-9a304cbe4def	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
305ab402-2d28-4607-ad44-7b1031dea076	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea315f7d-d597-41b3-a999-4f3851bcd020	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
325fcf79-60ee-46bc-931d-612002282ff3	0aed67b8-c454-439a-a07f-4f46d46d58af	8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	88b29e0c-39b7-4169-ab5c-350075014a84	Services - Testing - Cloud & AI
b79f5fee-71cf-4fe3-b61f-7e3811fedcea	310a2f16-15f6-4b82-95f6-ab18b5b429f5	485012d4-2c28-4bc4-92c7-3609e3e3749e	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Functional - HR
b823d89e-aab0-477f-8b85-7129d59dd202	898c36e9-1cb7-4c56-9148-a3b6893c0149	3356f353-1566-4df6-9958-fa01d67d13c7	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	R&D (Research & Development)
bf03ad3b-c399-4afa-a0e2-682f1d475fe8	8e4e88f1-e294-4554-80cc-92ed6169caeb	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO (Project Management Office)
c034e919-e8b3-4bcc-8ee2-72f4fe2ad36f	8e4e88f1-e294-4554-80cc-92ed6169caeb	b3309eea-7374-4a8d-ac13-481b2a7fd492	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO (Project Management Office)
c1010573-777c-45fa-8b66-c77e8e4cbc3f	310a2f16-15f6-4b82-95f6-ab18b5b429f5	e8c22eff-0daf-4690-a537-c8b0b6110a01	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Across all Sub Departments
c6edab11-cbcb-4e05-aab3-d7d0b493c4fe	0aed67b8-c454-439a-a07f-4f46d46d58af	9858c224-f97f-4ff8-908d-f46bd5e2243c	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
caa92f5c-1925-436c-9bf0-b270d5ddb38d	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b5f39dd8-c305-489d-9f7d-9adfd010a134	111cc3cd-6d35-43ce-be91-dde90d3d4015	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
ccff1a9e-10e0-43e8-9379-77811383a397	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	4650d4e0-f73c-4688-ae5f-830a46348ff9	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
cf705a0a-b654-4219-955c-a187d514a84f	0aed67b8-c454-439a-a07f-4f46d46d58af	ae255622-ddcc-45ea-a699-8ec416fe57ab	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Services - Testing - DevSecOps
da6c7063-b8d6-47d9-8ad6-e5654b1a6190	13c91c98-00ae-4211-acb8-d06e35953806	b2b687ef-fd62-4cb7-a826-b40a35da7b2c	914d8500-03b6-4a43-a250-244effca1cf1	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
e064b573-153e-4f5c-bca0-37d89be9564a	bcbd68c8-c3f3-4396-abb0-0b0e13637958	96efad7d-8b7f-4d7f-a862-c0a6bec3789f	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
e323d911-96c9-4d01-be14-6ff9f00b5f68	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
e91d743d-70da-4bbe-92ce-8e9bf436acd9	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Across all Sub Departments
ef3cba27-0a2a-4348-82e3-7d86feed3e31	bcbd68c8-c3f3-4396-abb0-0b0e13637958	6e606c29-2ebf-4ab8-8006-aaedd5680009	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
f0a049a7-2bcd-4cf1-a57c-2b2a22cdd6de	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
fcd178d9-a936-4f02-a42a-ea9bdcf646a2	0aed67b8-c454-439a-a07f-4f46d46d58af	85cc9fbe-98a4-464d-a638-05f40529c6de	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 09:38:17.830203+00	2026-10-22 06:51:47.145117+00	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798	Services - Testing - Red Team
\.


--
-- Data for Name: mst_org_role_sub_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_org_role_sub_departments ("Id", "OrgRoleMapId", "SubDepartmentId") FROM stdin;
0213ffe4-a3bb-40a9-8f04-a5520f8f9a0f	003fd050-8939-4d05-ac2b-29876038cb76	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
033bb3f2-0b5c-4460-adef-7b5539cbd464	0717101c-438d-4f69-b0ef-a56fcaf47a45	682d36c0-4256-42ab-811e-054ab3a5b10f
0439d088-1309-44a5-af50-3a3cc36b3875	15e4938e-241c-4f53-b64e-56a4b2201981	c88d783b-b628-4f3a-a972-aa56aeed5e77
04c08704-adad-4f42-9ac4-1b917f0e050c	b823d89e-aab0-477f-8b85-7129d59dd202	7682acb3-561b-4951-801b-c1564adda131
08d540f7-2b3a-40f7-bc55-fd7fbca65c3b	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	88b29e0c-39b7-4169-ab5c-350075014a84
09087e17-ce4d-4bc1-8a27-32c7763a1e2b	49b9c24a-e70e-4cf8-a8c4-e81a49af294b	db0addff-605e-439f-917b-38016a398755
0a69f0d5-c7d0-4f11-9cba-82d9207c4d37	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	e99b7773-5d71-4dca-ad36-b896dcfb71c4
0e96d8b9-734b-4a81-9fed-573a47cd09b8	fcd178d9-a936-4f02-a42a-ea9bdcf646a2	b651aec8-5455-4329-8251-0ceb62cea798
0ed850b8-6abf-44a2-a90b-1020a7a84160	a3451572-fefd-4cec-aa55-b28d3d3cac92	a12ac80b-a665-4301-898e-e9ca3d44bb20
0fe08aa5-03eb-4040-8207-f55a53edf114	45469efe-b575-417d-adb7-5c9ee591cb05	682d36c0-4256-42ab-811e-054ab3a5b10f
158450ec-97a2-41d9-b402-cb7d933f8caa	81e65582-e98d-4ded-b699-ea7fcb82f071	5d962383-f175-4dd8-af63-8a566a0d2255
1bbd570c-de73-4629-9009-019702cd3a88	79d8ed54-9a91-4486-a19f-e5485de7b490	88b29e0c-39b7-4169-ab5c-350075014a84
1be42c71-d1ff-497f-aa9d-cfa9704cc7e7	766c6052-09ad-44e4-8746-ed4795e712f1	cfdb2071-d50e-4ea3-b732-19eb08f1e629
1c3d006b-5360-446c-87f7-9521ae64fcca	8fbc1e25-42da-426a-be89-975dde3326bc	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
1ccf9a1d-7688-4375-9868-15108140dd45	872930ee-4d00-4d37-a2cb-dc57167f6973	682d36c0-4256-42ab-811e-054ab3a5b10f
1d465548-eb19-4b5f-a6e2-cdb84b30344a	50581768-4796-4731-b6e2-fc50e877f192	cfdb2071-d50e-4ea3-b732-19eb08f1e629
242a2d92-b71f-447a-a7a2-4686a11edfdc	2a21a67d-6020-4c2c-b06c-9e394c101fab	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
250fdce7-14b6-44f2-ba50-5c79c640ca51	c034e919-e8b3-4bcc-8ee2-72f4fe2ad36f	fd84aa38-11ef-46af-ade7-241f2a2c08fd
26b1e28a-0e66-4211-b727-dcfc94730968	73687605-0927-471b-b8c2-ec61f4d5164e	db0addff-605e-439f-917b-38016a398755
2781502c-6dc6-4aca-899d-e651f92d4ad8	0717101c-438d-4f69-b0ef-a56fcaf47a45	db0addff-605e-439f-917b-38016a398755
28af07a7-e2b6-4f46-bfe5-293df0c5f17f	759ce52f-d3bf-414e-bd79-c33c038dfdf6	e99b7773-5d71-4dca-ad36-b896dcfb71c4
2b251ca2-2309-499d-95fe-ed88f73c73ed	36243b2d-d487-49db-87d4-a46216df15ae	fa773eb9-162f-4ea8-9fc4-9c54a3068582
2ccaee3a-63f9-4a73-a656-e11d96779844	4804833e-7bbf-4746-9e57-16542de6c3dc	cfdb2071-d50e-4ea3-b732-19eb08f1e629
2cf316dc-967d-4ce7-9a1b-c06f8cb26c1f	cf705a0a-b654-4219-955c-a187d514a84f	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
2d5c443e-f25b-4926-895b-2d161a2142b3	ef3cba27-0a2a-4348-82e3-7d86feed3e31	5d962383-f175-4dd8-af63-8a566a0d2255
2dfe922a-3a1a-40c2-b3e2-8709889f2aed	85559f41-c8d4-44b1-8906-a5e1d064f78c	5d962383-f175-4dd8-af63-8a566a0d2255
30a3e55f-61ff-4073-97b4-d0fc613cbb0e	da6c7063-b8d6-47d9-8ad6-e5654b1a6190	fa773eb9-162f-4ea8-9fc4-9c54a3068582
33e68381-4e88-48db-bb7d-bdd1d24b67c3	81a34a8f-1fb9-431f-bc96-1bb95dab3fdb	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
37c5d332-6f05-4f62-b123-b8e9fe499660	325fcf79-60ee-46bc-931d-612002282ff3	88b29e0c-39b7-4169-ab5c-350075014a84
3bbc9b2a-b964-4987-880f-434b8f8a9b42	c6edab11-cbcb-4e05-aab3-d7d0b493c4fe	e99b7773-5d71-4dca-ad36-b896dcfb71c4
3ffd16d4-5504-4bb1-ace4-b8bfd3b1c3f5	e91d743d-70da-4bbe-92ce-8e9bf436acd9	cfdb2071-d50e-4ea3-b732-19eb08f1e629
42105ec8-8af6-465e-9131-8ae2e453f1d4	76ad509e-ba7a-412e-a0cb-be0b8eeb8305	cfdb2071-d50e-4ea3-b732-19eb08f1e629
4226013d-46e8-4338-9f80-c72c8c1972e5	b3eb1bdf-188b-4292-9cfd-f72381c366f0	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
44815c1f-a7a3-4eba-9e3e-581cf9a3db11	6ccedaf4-671c-4375-8200-f860eb7d46d9	fd84aa38-11ef-46af-ade7-241f2a2c08fd
45b1c313-9c19-4664-bae0-1d9962efca43	ccff1a9e-10e0-43e8-9379-77811383a397	cfdb2071-d50e-4ea3-b732-19eb08f1e629
47f08142-e5b4-4d76-af46-e16ef1dfe938	5d79d51f-fcd5-40a1-96e8-8a8ae7c76c00	b651aec8-5455-4329-8251-0ceb62cea798
4a74afd9-bbe2-47fc-a2fa-5468f8010dd8	5f392507-7f0b-4614-9679-fcc103e3dbc7	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
4b97d03f-cf4f-4170-b2e9-b06040338de5	128f2bec-ea83-4f7e-8115-9899a302d677	5d962383-f175-4dd8-af63-8a566a0d2255
4b9d187d-4a06-464c-86b1-e1be967d0793	0a909d87-52c0-4ec8-b6f8-b8111cf7310e	db0addff-605e-439f-917b-38016a398755
4f6eb7ee-0c33-4ad1-bc8d-7d99ee085781	ab07d7c9-e503-4641-8db6-25ac3fc0993e	5d962383-f175-4dd8-af63-8a566a0d2255
51b63fc2-b132-4da9-baeb-4c5432de9fba	b11be1e9-662a-4bc7-b06b-7f401c8b00b3	7682acb3-561b-4951-801b-c1564adda131
5759e905-0bca-4250-a30d-e9ad8a2b9e49	b79f5fee-71cf-4fe3-b61f-7e3811fedcea	c88d783b-b628-4f3a-a972-aa56aeed5e77
59ba4c98-14f1-4cfa-9672-38499757c47e	38bd29af-b288-4b62-ae24-679d6b2713ac	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
5a00b4cf-f04d-4f46-b1fc-f0338d042a64	872930ee-4d00-4d37-a2cb-dc57167f6973	db0addff-605e-439f-917b-38016a398755
5eb2aabd-3e5c-4b65-a4c4-bb14c3e2a16d	759ce52f-d3bf-414e-bd79-c33c038dfdf6	db0addff-605e-439f-917b-38016a398755
63d2418b-7bbc-4062-a1f0-9d431a4d50e2	8a92cbcd-7247-4f89-94a4-546013a78a29	fa773eb9-162f-4ea8-9fc4-9c54a3068582
6ad996bc-a537-44ea-90eb-a25edee0fcfd	c6edab11-cbcb-4e05-aab3-d7d0b493c4fe	682d36c0-4256-42ab-811e-054ab3a5b10f
6c455776-9821-4758-9abe-55efd204e34d	caa92f5c-1925-436c-9bf0-b270d5ddb38d	cfdb2071-d50e-4ea3-b732-19eb08f1e629
6f1745a2-f00b-4006-86b7-de8fa8b66a79	3bce413c-a323-4f80-a417-190414a3d56b	cfdb2071-d50e-4ea3-b732-19eb08f1e629
70d5ad33-57f8-4412-8659-e26ee3c936ff	7d7850cf-72da-411d-ba58-bd2d4a43ca28	cfdb2071-d50e-4ea3-b732-19eb08f1e629
71d8b921-13c4-4e93-b793-aa260d3f99a1	0f8dfe0e-d5d5-4a23-b9dc-cff6d71ae84f	fd84aa38-11ef-46af-ade7-241f2a2c08fd
72eb960d-84f9-48ea-b013-0ccaba3696c4	5e1badcc-b621-4c3b-b729-4f3ddf5877a0	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
755df442-33ca-4e15-9053-11a305ec66a7	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	682d36c0-4256-42ab-811e-054ab3a5b10f
77024dc5-3e52-4ab8-88d9-8a71855a9735	a220a973-9f98-4654-8a57-ee6b44579be5	45755b2a-741a-4990-ab78-8f65090f75b1
778f91e0-5c62-42fd-97b9-9c0525d4d96f	73687605-0927-471b-b8c2-ec61f4d5164e	682d36c0-4256-42ab-811e-054ab3a5b10f
78eb6251-d2d2-4902-87c7-518389cabfb3	047399e0-7821-4f80-be7a-78057c4c2f5f	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
7a082b16-6086-4bfd-addd-04025e4a5e21	222358f3-3516-49b6-b7db-60f936d4a8c9	61bbeadf-3044-4123-929c-4b1e6e2e613e
7d13d7fa-047e-421f-b54e-24e43e80b88b	b2819c45-99c7-4306-9ffb-1d585f0a29d0	cfdb2071-d50e-4ea3-b732-19eb08f1e629
80324be6-47be-4f0f-9c8b-b708927324f8	49b9c24a-e70e-4cf8-a8c4-e81a49af294b	e99b7773-5d71-4dca-ad36-b896dcfb71c4
80cb7fa6-34e6-4189-bbd2-e3580b7593b9	1c213096-46a8-48e1-b353-fdf2d25074ab	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
84026dbc-15db-4896-aee3-433a3227ce68	72fc796a-c5ba-4bf3-b93f-5b8f52491aed	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
841729e8-d217-46e7-812b-824e4b41d64f	159c2701-2318-4ba7-b809-fa07d078305e	e99b7773-5d71-4dca-ad36-b896dcfb71c4
86e8c35d-c49a-4012-9651-86e4357e2764	6c3fcc16-3602-4bf5-9dd2-7e51fe23d336	b651aec8-5455-4329-8251-0ceb62cea798
89ddd7a6-ff03-4175-aeb7-ab47dc6bfcb7	651dc356-0c28-457e-bc56-69fdf6ea321f	7682acb3-561b-4951-801b-c1564adda131
8c2904ff-bde1-43c3-a645-cac3978cc32e	305ab402-2d28-4607-ad44-7b1031dea076	cfdb2071-d50e-4ea3-b732-19eb08f1e629
8d584297-1f12-4ae9-bd04-7a6c36d4b0c2	5808fbe9-5fd4-4e3f-86b4-5a0ad69517bd	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
8d8d61e1-b32b-4094-b804-6715ac2d5974	359026a0-80bd-4c27-99f3-f63fb1741c6d	c88d783b-b628-4f3a-a972-aa56aeed5e77
8ddbe12a-42b9-478a-a716-acf8d617fa2e	98b476d3-39f3-4af1-83df-00639379db5e	cfdb2071-d50e-4ea3-b732-19eb08f1e629
8f413649-a5fd-40ca-b8e0-d9eefe9625dd	159c2701-2318-4ba7-b809-fa07d078305e	db0addff-605e-439f-917b-38016a398755
9118f2d7-4f7e-4d78-98a2-26338769e438	4f83891a-823a-406f-aa9f-5e23abeaba11	63765624-d7d1-472d-abd4-627127646998
933dc74f-a866-41ee-a84d-c4b59325d19a	999c4385-21ef-4a47-800f-1c08938edcee	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
984654d6-83bc-4145-88a8-792b746bf23c	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
9a9babfc-c7be-4cdc-9e0d-e466ad753f1b	a7cb72a9-ec77-44e1-998a-a0638f8becc5	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
9c460a99-a5d3-4902-9360-05368cf51990	7428ebde-4c77-4358-bc21-6acef30a85a4	fa773eb9-162f-4ea8-9fc4-9c54a3068582
9cc5920b-6982-4ab1-b2a1-d8b5d4ac4e8a	45469efe-b575-417d-adb7-5c9ee591cb05	db0addff-605e-439f-917b-38016a398755
a2d1dfab-8620-432c-aaa5-bb3e6711e36d	378f0582-07ec-4a86-a0ff-56575cc28dd0	cfdb2071-d50e-4ea3-b732-19eb08f1e629
a52ff8df-8879-4cad-ac7f-dbb4854c67eb	e323d911-96c9-4d01-be14-6ff9f00b5f68	db0addff-605e-439f-917b-38016a398755
a90b3d37-4dd7-4285-a55f-6dec0770a047	6df1609a-13f1-469d-96a1-253b2bc66b4f	a73eb36c-7d62-4aa8-901d-1c70b3876b69
aa6a0c7c-43cf-4e43-beef-7e965ddd922a	3c8fda3c-c84a-4ef8-80ed-327dc87a3abc	fa773eb9-162f-4ea8-9fc4-9c54a3068582
ac461a5a-56d4-48c9-9752-b7a93aab40c0	c6edab11-cbcb-4e05-aab3-d7d0b493c4fe	db0addff-605e-439f-917b-38016a398755
acd5063c-adc6-42ae-b6f7-bd77b6dbbd75	73687605-0927-471b-b8c2-ec61f4d5164e	e99b7773-5d71-4dca-ad36-b896dcfb71c4
add7b6ef-eb6c-4b26-83a8-6e66b614159f	f0a049a7-2bcd-4cf1-a57c-2b2a22cdd6de	db0addff-605e-439f-917b-38016a398755
b0461b18-1f0c-4f9b-a7bf-fbd14967783e	a2113157-8223-486e-a506-90ae7a3daa93	c88d783b-b628-4f3a-a972-aa56aeed5e77
b2989c48-19b4-42b6-91cc-e2e3a842d335	2faf5d1b-751e-4a11-9b34-33bf797eef82	fa773eb9-162f-4ea8-9fc4-9c54a3068582
b7cfde9e-2052-4863-a066-a95fd580960e	159c2701-2318-4ba7-b809-fa07d078305e	682d36c0-4256-42ab-811e-054ab3a5b10f
b90fa8e6-8d59-4690-8bb4-52d37acc1a8b	4192b456-ca31-4de0-a8ce-698c41732ec4	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
bbcd0f83-fb96-4b97-9837-2518bba532f5	c1010573-777c-45fa-8b66-c77e8e4cbc3f	c88d783b-b628-4f3a-a972-aa56aeed5e77
bd2d32c8-ca38-4d58-94ec-5d6cc3f6ca1e	45469efe-b575-417d-adb7-5c9ee591cb05	e99b7773-5d71-4dca-ad36-b896dcfb71c4
c1879e03-51d4-4175-924b-7edb6f6d65be	872930ee-4d00-4d37-a2cb-dc57167f6973	e99b7773-5d71-4dca-ad36-b896dcfb71c4
c21bee74-421a-45cc-8c2f-222fcc43a08a	bf03ad3b-c399-4afa-a0e2-682f1d475fe8	fd84aa38-11ef-46af-ade7-241f2a2c08fd
c4363552-a5e9-43d7-b76f-1c9d71da8306	37fe770e-4c51-4e31-bbb6-0ca302286b91	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
c60ec0eb-d39f-4107-be12-1adcfed7702a	49b9c24a-e70e-4cf8-a8c4-e81a49af294b	682d36c0-4256-42ab-811e-054ab3a5b10f
c8d2d5fe-983a-48e7-9737-3b43e20aa817	36732dd0-7171-4b3e-a7a6-48427a14f504	cfdb2071-d50e-4ea3-b732-19eb08f1e629
ca9fba99-347f-49c7-8ed6-cca8c558c04c	0a909d87-52c0-4ec8-b6f8-b8111cf7310e	e99b7773-5d71-4dca-ad36-b896dcfb71c4
cb3cc65f-fe66-4a9f-a8b4-c8f3eee5cbb9	86237191-01ee-4aad-9a6b-e75600c375fc	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
ccb2b992-d409-4508-a4ff-d04c10d700ae	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	b651aec8-5455-4329-8251-0ceb62cea798
cf56bb8a-26d6-491a-aebb-71217ea46ad5	3f714252-8945-41a7-8520-1c1c8925854e	cfdb2071-d50e-4ea3-b732-19eb08f1e629
d435b72f-e001-469b-abba-9e34d51ca2d7	e064b573-153e-4f5c-bca0-37d89be9564a	5d962383-f175-4dd8-af63-8a566a0d2255
d441d566-e867-4cd2-a84d-57e73d6f9faa	837d9855-e239-4046-83d9-ae224ecce6ef	fa773eb9-162f-4ea8-9fc4-9c54a3068582
d89afc58-0d81-4ee4-ae4e-d2f407a75db5	554562de-10b1-4365-9e6e-cf769630de75	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
db636adc-029a-4f81-9a8b-e0520b75259b	0717101c-438d-4f69-b0ef-a56fcaf47a45	e99b7773-5d71-4dca-ad36-b896dcfb71c4
dd5cce9f-932a-4031-8a44-afc449cbdba9	f0a049a7-2bcd-4cf1-a57c-2b2a22cdd6de	e99b7773-5d71-4dca-ad36-b896dcfb71c4
df05c113-7516-41a2-afbe-962e1d2fd9cd	3514262c-d7ec-4d76-81c8-20995e4d22f8	5d962383-f175-4dd8-af63-8a566a0d2255
dffd9698-ca9a-49bf-b261-128c721a8dfb	e323d911-96c9-4d01-be14-6ff9f00b5f68	682d36c0-4256-42ab-811e-054ab3a5b10f
e5bf8655-ba8a-4f87-8e74-a5ba6803006c	0a909d87-52c0-4ec8-b6f8-b8111cf7310e	682d36c0-4256-42ab-811e-054ab3a5b10f
e67e7c06-44b7-4829-abd3-df8fe6a32fa8	8a351e0a-8631-4aca-9598-81b276dbc990	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
e7df919e-5e44-4c64-9476-e6ed501d6b59	2d9893c2-a2b8-4a26-a41d-85061c629ec2	c88d783b-b628-4f3a-a972-aa56aeed5e77
e8548416-edfb-4268-9d90-477db155eca6	af28c045-efab-45db-83dc-c487bab9019f	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
edbd9646-9a16-47ca-9b74-6ff9a05435ff	f0a049a7-2bcd-4cf1-a57c-2b2a22cdd6de	682d36c0-4256-42ab-811e-054ab3a5b10f
f0d576f7-c061-4eca-89bb-d3651d7861a4	0a1dda59-5a52-496e-8d30-5f082dbe343e	cfdb2071-d50e-4ea3-b732-19eb08f1e629
f1e42593-1e9c-4c72-96da-b33ed6b872cb	e323d911-96c9-4d01-be14-6ff9f00b5f68	e99b7773-5d71-4dca-ad36-b896dcfb71c4
f806eaf0-f34e-431e-bbd5-980253f7082f	a0c6147f-a977-4215-840a-60f95d2bd729	7682acb3-561b-4951-801b-c1564adda131
fa1cbeed-34fd-49d7-8252-17694193c05e	a77285b6-5266-4959-8399-f34dfbfcb44e	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
fa80b2be-935f-4b03-b307-bd5800910194	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	db0addff-605e-439f-917b-38016a398755
facde679-8a64-473c-b5f8-b179a4201d73	759ce52f-d3bf-414e-bd79-c33c038dfdf6	682d36c0-4256-42ab-811e-054ab3a5b10f
\.


--
-- Data for Name: mst_post_graduation_degrees; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
02b11fcf-15dc-438e-857d-fe1df19f925b	me	ME	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
29c8b610-bca4-41b7-8199-960c4907c189	mba	MBA	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
42343c31-3dfa-44e6-a433-5d0c66dcfaf0	na	NA	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
93a0a0ed-91ed-41e3-91c1-09e94f248667	mtech	M.Tech	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
9ea82119-8356-4b91-87ea-aeeb679b9cf6	msc	M.Sc	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
c7bd4e1d-4826-421d-b473-3a926672050e	ma	M.A.	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
e0725237-7a46-48ee-9ff1-3969f2571d2a	mcom	M.Com	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
e2722a3d-0767-4299-afa9-04d89c28cd7c	mca	MCA	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
ec8299cf-acb1-4a26-aed5-a03db0ff8bfe	ms	MS	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
69a230fc-d84b-402c-85f7-25a048cc61fd	zz_probe_mba	ZZ Probe MBA	f	2026-10-18 13:00:09.404433+00	2026-10-18 13:00:09.74092+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:00:09.74092+00
\.


--
-- Data for Name: mst_rbac_baseline; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_rbac_baseline ("Version", "AppliedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_reporting_managers; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_reporting_managers ("Id", "Code", "Name", "Designation", "Email", "EmployeeId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_salary_bands; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_salary_bands ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
20ffbe9b-96ca-496e-ab2e-50ccf3c91246	l3	L3	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
37016f9a-2474-400d-99ae-18157aaad035	l1	L1	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	l4	L4	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
e5f5511b-dea6-421c-8c0e-b271e4ee5d43	l5	L5	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
ebed343e-301f-4984-b292-fa8d1cb1623c	l2	L2	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_service_catalog; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_service_catalog ("Id", "Code", "Name", "SubDepartmentId", "DefaultTools", "DefaultUnitPrice", "DefaultDurationDays", "Description", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
d0000001-0000-0000-0000-000000000001	PT001	External Network Penetration Testing	c0000001-0000-0000-0000-000000000001	Nessus, Metasploit	60000.00	5	\N	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000002-0000-0000-0000-000000000002	PT002	Internal Network Penetration Testing	c0000001-0000-0000-0000-000000000001	Burp Suite, Cobalt Strike	75000.00	6	\N	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000003-0000-0000-0000-000000000003	PT003	Web Application Penetration Testing	c0000002-0000-0000-0000-000000000002	Burp Suite, OWASP ZAP	50000.00	5	\N	t	3	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000004-0000-0000-0000-000000000004	PT004	Mobile Application Penetration Testing	c0000003-0000-0000-0000-000000000003	Frida, Burp Suite Mobile	55000.00	5	\N	t	4	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000005-0000-0000-0000-000000000005	PT005	API Penetration Testing	c0000004-0000-0000-0000-000000000004	Postman, Burp Suite	40000.00	4	\N	t	5	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000006-0000-0000-0000-000000000006	PT006	Thick Client Penetration Testing	c0000005-0000-0000-0000-000000000005	Burp Suite, API Fuzzer	45000.00	4	\N	t	6	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000007-0000-0000-0000-000000000007	VA001	Network Vulnerability Assessment	c0000006-0000-0000-0000-000000000006	Nessus, OpenVAS, Qualys	35000.00	3	\N	t	7	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000008-0000-0000-0000-000000000008	VA002	Web Application Vulnerability Assessment	c0000007-0000-0000-0000-000000000007	Acunetix, Qualys, Rapid7	40000.00	4	\N	t	8	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000009-0000-0000-0000-000000000009	VA003	Cloud Infrastructure Vulnerability Assessment	c0000008-0000-0000-0000-000000000008	Dome9, CloudSploit	50000.00	4	\N	t	9	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000000a-0000-0000-0000-00000000000a	RT001	Full Spectrum Red Team Exercise	c0000009-0000-0000-0000-000000000009	Cobalt Strike, Metasploit, Mimikatz	120000.00	10	\N	t	10	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000000d-0000-0000-0000-00000000000d	CS002	Azure Security Assessment	c000000b-0000-0000-0000-00000000000b	Azucar, Microsoft Defender, Qualys	55000.00	5	\N	t	13	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000000e-0000-0000-0000-00000000000e	CS003	Google Cloud Security Assessment	c000000c-0000-0000-0000-00000000000c	GCP Security Command Center	50000.00	5	\N	t	14	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000000f-0000-0000-0000-00000000000f	CODE001	Source Code Security Review	c000000d-0000-0000-0000-00000000000d	SonarQube, Checkmarx, Fortify	65000.00	6	\N	t	15	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000010-0000-0000-0000-000000000010	CODE002	Static Application Security Testing (SAST)	c000000e-0000-0000-0000-00000000000e	Checkmarx, Veracode, Fortify	70000.00	7	\N	t	16	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000011-0000-0000-0000-000000000011	CODE003	Dynamic Application Security Testing (DAST)	c000000f-0000-0000-0000-00000000000f	Burp Suite, Acunetix, AppScan	60000.00	6	\N	t	17	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000012-0000-0000-0000-000000000012	COMP001	ISO 27001 Security Audit	c0000010-0000-0000-0000-000000000010	AuditBoard, Drata, Vanta	85000.00	8	\N	t	18	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000013-0000-0000-0000-000000000013	COMP002	GDPR Compliance Assessment	c0000011-0000-0000-0000-000000000011	OneTrust, TrustArc, Compliance.ai	75000.00	7	\N	t	19	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000014-0000-0000-0000-000000000014	COMP003	PCI-DSS Compliance Assessment	c0000012-0000-0000-0000-000000000012	Qualys, Rapid7, Nessus	80000.00	7	\N	t	20	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000015-0000-0000-0000-000000000015	COMP004	SOC 2 Type II Audit	c0000013-0000-0000-0000-000000000013	AuditBoard, Drata	95000.00	10	\N	t	21	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000016-0000-0000-0000-000000000016	SE001	Phishing Campaign & Assessment	c0000014-0000-0000-0000-000000000014	KnowBe4, Gophish, Phish Alert	30000.00	2	\N	t	22	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000017-0000-0000-0000-000000000017	SE002	Security Awareness Training Program	c0000015-0000-0000-0000-000000000015	LinkedIn Learning, KnowBe4, SANS	45000.00	4	\N	t	23	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000018-0000-0000-0000-000000000018	SE003	Vishing & Pretexting Assessment	c0000016-0000-0000-0000-000000000016	Custom, KnowBe4	35000.00	3	\N	t	24	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000019-0000-0000-0000-000000000019	FOR001	Digital Forensics Investigation	c0000017-0000-0000-0000-000000000017	EnCase, FTK, Volatility, X-Ways	90000.00	8	\N	t	25	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000001a-0000-0000-0000-00000000001a	FOR002	Incident Response & Containment	c0000018-0000-0000-0000-000000000018	Splunk, ELK, Rapid7 InsightIDR	75000.00	7	\N	t	26	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000001b-0000-0000-0000-00000000001b	FOR003	Malware Analysis	c0000019-0000-0000-0000-000000000019	IDA Pro, Ghidra, Wireshark, Cuckoo	70000.00	6	\N	t	27	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000001c-0000-0000-0000-00000000001c	NET001	Network Architecture Security Review	c000001a-0000-0000-0000-00000000001a	Nmap, Wireshark, NETMON	55000.00	5	\N	t	28	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000001d-0000-0000-0000-00000000001d	NET002	Firewall & IDS/IPS Configuration Audit	c000001b-0000-0000-0000-00000000001b	Nessus, OpenVAS, Custom Scripts	65000.00	6	\N	t	29	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000001e-0000-0000-0000-00000000001e	NET003	Network Segmentation Assessment	c000001c-0000-0000-0000-00000000001c	Nmap, Shodan, Custom Tools	60000.00	5	\N	t	30	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000001f-0000-0000-0000-00000000001f	THREAT001	Threat Modeling & Risk Assessment	c000001d-0000-0000-0000-00000000001d	Microsoft Threat Modeling Tool, IriusRisk	50000.00	4	\N	t	31	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000020-0000-0000-0000-000000000020	THREAT002	Cyber Threat Intelligence Report	c000001e-0000-0000-0000-00000000001e	MISP, Mandiant, CrowdStrike	40000.00	3	\N	t	32	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d0000021-0000-0000-0000-000000000021	THREAT003	Attack Surface Analysis	c000001f-0000-0000-0000-00000000001f	Shodan, Censys, Rapid7 Sonar	45000.00	4	\N	t	33	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000000b-0000-0000-0000-00000000000b	RT002	Targeted Red Team Engagement	c0000009-0000-0000-0000-000000000009	Custom Tools, Cobalt Strike	80000.00	10	\N	t	11	2026-09-28 07:41:38.11983+00	2026-10-18 07:46:18.367678+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N
ff646bbe-4611-4d80-a733-2d6c8644ea84	FSF	fsf	d4fd66ae-afca-43c9-8eb9-dfb3d4797a76	\N	\N	\N	\N	t	1	2026-10-18 09:29:47.339903+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
d000000c-0000-0000-0000-00000000000c	CS001	AWS Security Assessment	c000000a-0000-0000-0000-00000000000a	Scout2, CloudMapper, AWS Inspector	550000000.00	10	\N	t	12	2026-09-28 07:41:38.11983+00	2026-10-18 09:31:43.961099+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N
7503a7df-4f04-4822-afee-877c328cb3ad	SOC	SOC	52e804e5-4974-44b2-ab7d-d5088795abc7	Burp	4500.00	15	\N	t	1	2026-10-18 09:35:31.941072+00	2026-10-18 09:35:55.047757+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N
7f7e8f5c-a5d3-411d-b052-8b1c6c674071	SERVICE1	service_1	f9c3e149-e860-4669-bb23-23e539f289ce	azure	20000.00	3	\N	t	1	2026-10-18 10:18:01.356158+00	2026-10-18 10:19:38.355681+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N
\.


--
-- Data for Name: mst_service_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_service_departments ("Id", "Code", "Name", "GroupId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
b0000001-0000-0000-0000-000000000001	PEN_TESTING	Penetration Testing	a2222222-2222-2222-2222-222222222222	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
b0000002-0000-0000-0000-000000000002	VULN_ASSESSMENT	Vulnerability Assessment	a2222222-2222-2222-2222-222222222222	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
b0000003-0000-0000-0000-000000000003	RED_TEAM	Red Team & Adversary Simulation	a1111111-1111-1111-1111-111111111111	t	3	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
b0000004-0000-0000-0000-000000000004	CLOUD_SECURITY	Cloud Security	a1111111-1111-1111-1111-111111111111	t	4	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
b0000005-0000-0000-0000-000000000005	CODE_APP_SECURITY	Code & Application Security	a2222222-2222-2222-2222-222222222222	t	5	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
b0000006-0000-0000-0000-000000000006	COMPLIANCE_AUDIT	Compliance & Audit	a1111111-1111-1111-1111-111111111111	t	6	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
b0000007-0000-0000-0000-000000000007	SOCIAL_ENGINEERING	Social Engineering & Awareness	a2222222-2222-2222-2222-222222222222	t	7	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
b0000008-0000-0000-0000-000000000008	FORENSICS_IR	Forensics & Incident Response	a1111111-1111-1111-1111-111111111111	t	8	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
b0000009-0000-0000-0000-000000000009	NETWORK_INFRA	Network & Infrastructure	a2222222-2222-2222-2222-222222222222	t	9	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
b000000a-0000-0000-0000-00000000000a	THREAT_INTEL	Threat Intelligence & Modeling	a1111111-1111-1111-1111-111111111111	t	10	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
989349e0-b566-4378-aa34-d5b6b046106f	TESTINGDEPT	testing_dept	a2222222-2222-2222-2222-222222222222	t	10	2026-10-18 08:05:30.193102+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
c45b7e7b-01f3-460d-95a6-d9d5c6013354	ZZEMPTYDEPTCHECK	ZZ Empty Dept Check	a1111111-1111-1111-1111-111111111111	f	11	2026-10-18 08:10:50.941178+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 08:11:49.404314+00
2875b963-449a-4c44-a6fc-ccb274ccd210	PENETRATIONTEST	penetration Test	a2222222-2222-2222-2222-222222222222	t	11	2026-10-18 09:25:27.729475+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a18c1408-67e9-4715-ab16-c71f5ac91347	TESTINGDEPT1	Testing dept	a1111111-1111-1111-1111-111111111111	t	12	2026-10-18 09:34:56.055383+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
9227f16e-6363-4fd3-8df0-73466793e314	DEPTTESTING	Dept testing	a1111111-1111-1111-1111-111111111111	t	13	2026-10-18 10:17:36.099103+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: mst_service_groups; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_service_groups ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
a1111111-1111-1111-1111-111111111111	RESOURCE	Resource	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
a2222222-2222-2222-2222-222222222222	SCOPE	Scope	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_service_sub_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_service_sub_departments ("Id", "Code", "Name", "DepartmentId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
c0000001-0000-0000-0000-000000000001	SUB_NET_PT	Network Penetration Testing	b0000001-0000-0000-0000-000000000001	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000002-0000-0000-0000-000000000002	SUB_WEB_PT	Web Application Penetration Testing	b0000001-0000-0000-0000-000000000001	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000003-0000-0000-0000-000000000003	SUB_MOB_PT	Mobile Application Penetration Testing	b0000001-0000-0000-0000-000000000001	t	3	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000004-0000-0000-0000-000000000004	SUB_API_PT	API Penetration Testing	b0000001-0000-0000-0000-000000000001	t	4	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000005-0000-0000-0000-000000000005	SUB_THICK_PT	Thick Client Penetration Testing	b0000001-0000-0000-0000-000000000001	t	5	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000006-0000-0000-0000-000000000006	SUB_NET_VA	Network Vulnerability Assessment	b0000002-0000-0000-0000-000000000002	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000007-0000-0000-0000-000000000007	SUB_WEB_VA	Web Application Vulnerability Assessment	b0000002-0000-0000-0000-000000000002	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000008-0000-0000-0000-000000000008	SUB_CLOUD_VA	Cloud Infrastructure Vulnerability Assessment	b0000002-0000-0000-0000-000000000002	t	3	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000009-0000-0000-0000-000000000009	SUB_ADV_SIM	Adversary Simulation	b0000003-0000-0000-0000-000000000003	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000000a-0000-0000-0000-00000000000a	SUB_AWS_SEC	AWS Security Assessment	b0000004-0000-0000-0000-000000000004	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000000b-0000-0000-0000-00000000000b	SUB_AZURE_SEC	Azure Security Assessment	b0000004-0000-0000-0000-000000000004	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000000c-0000-0000-0000-00000000000c	SUB_GCP_SEC	Google Cloud Security Assessment	b0000004-0000-0000-0000-000000000004	t	3	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000000d-0000-0000-0000-00000000000d	SUB_CODE_REV	Source Code Security Review	b0000005-0000-0000-0000-000000000005	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000000e-0000-0000-0000-00000000000e	SUB_SAST	Static Application Security Testing	b0000005-0000-0000-0000-000000000005	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000000f-0000-0000-0000-00000000000f	SUB_DAST	Dynamic Application Security Testing	b0000005-0000-0000-0000-000000000005	t	3	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000010-0000-0000-0000-000000000010	SUB_ISO27001	ISO 27001 Security Audit	b0000006-0000-0000-0000-000000000006	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000011-0000-0000-0000-000000000011	SUB_GDPR	GDPR Compliance Assessment	b0000006-0000-0000-0000-000000000006	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000012-0000-0000-0000-000000000012	SUB_PCIDSS	PCI-DSS Compliance Assessment	b0000006-0000-0000-0000-000000000006	t	3	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000013-0000-0000-0000-000000000013	SUB_SOC2	SOC 2 Type II Audit	b0000006-0000-0000-0000-000000000006	t	4	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000014-0000-0000-0000-000000000014	SUB_PHISHING	Phishing Campaign & Assessment	b0000007-0000-0000-0000-000000000007	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000015-0000-0000-0000-000000000015	SUB_AWARENESS	Security Awareness Training Program	b0000007-0000-0000-0000-000000000007	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000016-0000-0000-0000-000000000016	SUB_VISHING	Vishing & Pretexting Assessment	b0000007-0000-0000-0000-000000000007	t	3	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000017-0000-0000-0000-000000000017	SUB_FORENSICS	Digital Forensics Investigation	b0000008-0000-0000-0000-000000000008	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000018-0000-0000-0000-000000000018	SUB_IR	Incident Response & Containment	b0000008-0000-0000-0000-000000000008	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c0000019-0000-0000-0000-000000000019	SUB_MALWARE	Malware Analysis	b0000008-0000-0000-0000-000000000008	t	3	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000001a-0000-0000-0000-00000000001a	SUB_NET_ARCH	Network Architecture Security Review	b0000009-0000-0000-0000-000000000009	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000001b-0000-0000-0000-00000000001b	SUB_FIREWALL	Firewall & IDS/IPS Configuration Audit	b0000009-0000-0000-0000-000000000009	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000001c-0000-0000-0000-00000000001c	SUB_NET_SEG	Network Segmentation Assessment	b0000009-0000-0000-0000-000000000009	t	3	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000001d-0000-0000-0000-00000000001d	SUB_THREAT_MOD	Threat Modeling & Risk Assessment	b000000a-0000-0000-0000-00000000000a	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000001e-0000-0000-0000-00000000001e	SUB_THREAT_REP	Cyber Threat Intelligence Report	b000000a-0000-0000-0000-00000000000a	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c000001f-0000-0000-0000-00000000001f	SUB_ATTACK_SURF	Attack Surface Analysis	b000000a-0000-0000-0000-00000000000a	t	3	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
c552b8ee-ce22-4f27-8fb2-6ca8eb254073	ZZTEMPSUBDEPT	ZZ Temp Subdept	b0000004-0000-0000-0000-000000000004	f	4	2026-10-18 08:03:08.477637+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 08:04:37.610157+00
d4fd66ae-afca-43c9-8eb9-dfb3d4797a76	DW	dw	2875b963-449a-4c44-a6fc-ccb274ccd210	t	1	2026-10-18 09:29:35.777718+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
52e804e5-4974-44b2-ab7d-d5088795abc7	ITEM	-	a18c1408-67e9-4715-ab16-c71f5ac91347	t	1	2026-10-18 09:35:11.180665+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
f9c3e149-e860-4669-bb23-23e539f289ce	SUBDEPTTEST	Sub dept test	9227f16e-6363-4fd3-8df0-73466793e314	t	1	2026-10-18 10:17:51.018843+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: mst_sub_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_sub_departments ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
45755b2a-741a-4990-ab78-8f65090f75b1	leading_delivery_department	Leading Delivery Department	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
4dc4a56b-f458-4047-a1ca-345eaa08b5e3	functional_it_administration	Functional - IT Administration	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
5d962383-f175-4dd8-af63-8a566a0d2255	functional_accounts	Functional - Accounts	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
61bbeadf-3044-4123-929c-4b1e6e2e613e	leading_compliance_hr_department	Leading Compliance & HR Department	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
63bc0f54-4d35-4279-bb62-4daeff6ceeaa	em_engagement_manager	EM (Engagement Manager)	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
682d36c0-4256-42ab-811e-054ab3a5b10f	service_testing_appsec	Service - Testing - AppSec	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	services_consulting	Services - Consulting	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
7682acb3-561b-4951-801b-c1564adda131	r_d_research_development	R&D (Research & Development)	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
88b29e0c-39b7-4169-ab5c-350075014a84	services_testing_cloud_ai	Services - Testing - Cloud & AI	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	services_testing_devsecops	Services - Testing - DevSecOps	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
a12ac80b-a665-4301-898e-e9ca3d44bb20	leading_sales_a_c_department	Leading Sales & A/C Department	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
b651aec8-5455-4329-8251-0ceb62cea798	services_testing_red_team	Services - Testing - Red Team	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
c88d783b-b628-4f3a-a972-aa56aeed5e77	functional_hr	Functional - HR	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
cfdb2071-d50e-4ea3-b732-19eb08f1e629	services_operations	Services - Operations	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
db0addff-605e-439f-917b-38016a398755	service_testing_mobile	Service - Testing - Mobile	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
e99b7773-5d71-4dca-ad36-b896dcfb71c4	service_testing_infra	Service - Testing - Infra	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
fa773eb9-162f-4ea8-9fc4-9c54a3068582	functional_sales	Functional - Sales	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
fd84aa38-11ef-46af-ade7-241f2a2c08fd	pmo_project_management_office	PMO (Project Management Office)	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-10-20 18:31:50.075909+00	\N	\N	\N	\N
a73eb36c-7d62-4aa8-901d-1c70b3876b69	functional_project_management	Functional - Project Management	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-10-21 09:37:57.796708+00	\N	\N	\N	\N
63765624-d7d1-472d-abd4-627127646998	across_all_sub_departments	Across all Sub Departments	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-10-20 18:31:50.075909+00	2026-10-22 07:51:07.556154+00	\N	\N	\N
\.


--
-- Data for Name: mst_submodules; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_submodules ("Id", "Code", "Name", "Route", "SortOrder", "IsActive", "ModuleId", "ParentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
39dbd425-643b-47e9-9936-6bbae9ef5ef5	employee-directory	Employee Directory	/employee-directory	10	t	715f79ce-51ea-46d3-b95d-8318840f90a6	\N	2026-10-21 10:41:40.856126+00	\N	\N	\N	\N
526e2d0d-47d4-4814-9e5a-8f7c53af1432	exit-summary	Exit Summary	/exit-summary	20	t	715f79ce-51ea-46d3-b95d-8318840f90a6	\N	2026-10-21 10:41:40.856126+00	\N	\N	\N	\N
662d62ab-38b1-447e-876e-7f93bf2ba50e	master	Master	/settings-masters	20	t	fcb69b3e-e5aa-49bb-921f-7793f0a8c90d	\N	2026-10-21 10:41:40.856126+00	\N	\N	\N	\N
9854b7f3-8e7e-4ecb-864f-f2533ff295f9	team-dashboard	Team Dashboard	/my-team/	10	t	6055ce3c-b466-4354-ba9a-b4c309111e9d	\N	2026-10-21 10:41:40.856126+00	\N	\N	\N	\N
d67426d3-05df-4608-b8cf-c0ecfe698dc3	timesheets	Timesheets	/my-team/timesheets	20	t	6055ce3c-b466-4354-ba9a-b4c309111e9d	\N	2026-10-21 10:41:40.856126+00	\N	\N	\N	\N
e231d2d4-9ebb-4eb2-af48-fbe3b3b4ab90	roles-permissions	Roles & Permissions	/settings-security-roles	10	t	fcb69b3e-e5aa-49bb-921f-7793f0a8c90d	\N	2026-10-21 10:41:40.856126+00	\N	\N	\N	\N
a7e6b014-9f4a-4d2c-87d2-431527ef9a10	customer-detail	Customer Detail	/customers	10	t	4e57fd71-b53e-43c0-862e-5698e09c0922	\N	2026-10-26 12:13:10.411505+00	2026-10-26 12:37:50.679593+00	\N	\N	\N
b8f7c125-0e5b-4e3d-98e3-542638fa0b21	project-detail	Project Detail	/projects	10	t	168b1296-de6a-4f9e-a3b9-617b83863736	\N	2026-10-26 13:20:44.18797+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_tabs; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_tabs ("Id", "Code", "Name", "SortOrder", "IsActive", "ModuleId", "TabId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "SubModuleId") FROM stdin;
5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	alerts	Alerts	30	t	5a049953-8170-4ef4-a59e-43dc19e12de5	\N	2026-10-21 12:18:58.656708+00	\N	\N	\N	\N	\N
69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	notifications	Notifications	40	t	5a049953-8170-4ef4-a59e-43dc19e12de5	\N	2026-10-21 12:18:58.656708+00	\N	\N	\N	\N	\N
a7bd6c40-4e96-4abb-be93-4ed4e4211978	approvals	Approvals	20	t	5a049953-8170-4ef4-a59e-43dc19e12de5	\N	2026-10-21 12:18:58.656708+00	\N	\N	\N	\N	\N
db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	bucket-list	Bucket List	10	t	5a049953-8170-4ef4-a59e-43dc19e12de5	\N	2026-10-21 12:18:58.656708+00	\N	\N	\N	\N	\N
552f9f86-4eb0-473a-8e39-9863cfefcea4	all-employees	All Employees	20	t	\N	\N	2026-10-21 12:32:30.731666+00	\N	\N	\N	\N	9854b7f3-8e7e-4ecb-864f-f2533ff295f9
b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	my-reportees	My Reportees	10	t	\N	\N	2026-10-21 12:32:30.731666+00	\N	\N	\N	\N	9854b7f3-8e7e-4ecb-864f-f2533ff295f9
c1a11111-0001-4000-8000-000000000001	project-overview	Overview	10	t	\N	\N	2026-10-27 05:22:34.415461+00	\N	\N	\N	\N	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0001-4000-8000-000000000002	project-wbs	WBS	20	t	\N	\N	2026-10-27 05:22:34.415461+00	\N	\N	\N	\N	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0001-4000-8000-000000000003	project-team	Team	30	t	\N	\N	2026-10-27 05:22:34.415461+00	\N	\N	\N	\N	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0001-4000-8000-000000000004	project-tasks	Tasks	40	t	\N	\N	2026-10-27 05:22:34.415461+00	\N	\N	\N	\N	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0001-4000-8000-000000000005	project-health	Health	50	t	\N	\N	2026-10-27 05:22:34.415461+00	\N	\N	\N	\N	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0001-4000-8000-000000000006	project-invoices	Invoices	60	t	\N	\N	2026-10-27 05:22:34.415461+00	\N	\N	\N	\N	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0002-4000-8000-000000000001	health-issues	Issues	10	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 05:22:47.81342+00	\N	\N	\N	\N	\N
c1a11111-0002-4000-8000-000000000002	health-alerts	Alerts	20	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 05:22:47.81342+00	\N	\N	\N	\N	\N
c1a11111-0002-4000-8000-000000000003	health-escalations	Escalations	30	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 05:22:47.81342+00	\N	\N	\N	\N	\N
c1a11111-0002-4000-8000-000000000004	health-appreciation	Appreciation	40	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 05:22:47.81342+00	\N	\N	\N	\N	\N
c1a11111-0002-4000-8000-000000000005	health-customer-engagement	Customer Engagement	50	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 05:22:47.81342+00	\N	\N	\N	\N	\N
c1a11111-0002-4000-8000-000000000006	health-extension-request	Extension Request	60	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 05:22:47.81342+00	\N	\N	\N	\N	\N
\.


--
-- Data for Name: mst_widgets; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_widgets ("Id", "Code", "Name", "SortOrder", "IsActive", "ParentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "ParentWidgetId") FROM stdin;
0d274292-537d-4c41-8e23-3df901304d71	team-resignation-count	Team Resignation Count – Onsite/Offsite (Last 3 Months)	70	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 12:06:30.668801+00	\N	\N	\N	\N	\N
2b83bafc-1c64-449c-a644-e8e19e0c0a48	team-utilization-offsite	Team Utilization – Offsite	40	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 12:06:30.668801+00	\N	\N	\N	\N	\N
3c5780f7-e23d-48bd-b73e-51019dfbc2bd	team-allocation-onsite-offsite	Team Allocation Onsite/Offsite (Last 3 Months)	60	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 12:06:30.668801+00	\N	\N	\N	\N	\N
682f26ec-e31d-43a0-82de-e915bab54b59	total-team-size	Total Team Size	10	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 12:06:30.668801+00	\N	\N	\N	\N	\N
7e3f4519-8acd-489f-a70a-ac39092fbd40	team-utilization-onsite-projects	Team Utilization – Onsite: Project-wise Resource Count	50	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 12:06:30.668801+00	\N	\N	\N	\N	\N
896c2166-8f1f-4ab8-873c-755ab3d051fb	team-utilization-onsite	Team Utilization - Onsite (Last 3 Months)	30	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 12:06:30.668801+00	\N	\N	\N	\N	\N
9c916f1a-72e0-4d52-bec1-6d684e990c65	resource-boarding-details	Resource Boarding Details	20	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 12:06:30.668801+00	\N	\N	\N	\N	\N
d6dea306-2e8f-41a0-89c8-857cb96f5558	team-capacity-offsite	Team Capacity – Offsite (Last 3 Months)	80	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 12:06:30.668801+00	\N	\N	\N	\N	\N
\.


--
-- Data for Name: mst_work_locations; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_work_locations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
3bc10d7b-a705-4ec9-b7b5-71858572a8cc	suvidha_square_andheri	Suvidha Square, Andheri	t	2	2026-09-03 12:26:58.067087+00	2026-09-10 06:34:25.480503+00	\N	\N	\N
58e569dc-cb93-4832-bf22-2e8d4836dc65	onsite	Onsite	t	1	2026-09-03 12:26:58.067087+00	2026-09-10 06:34:25.480503+00	\N	\N	\N
8d0b23a2-9459-4fbe-a7bf-624abd410c40	navare_plaza_dombivli	Navare Plaza, Dombivli	t	3	2026-09-03 12:26:58.067087+00	2026-09-10 06:34:25.480503+00	\N	\N	\N
bb1fb7b0-c12c-4dd0-86b8-f4461feb6306	zz_probe_location	ZZ Probe Location	f	4	2026-10-18 13:00:09.320026+00	2026-10-18 13:00:09.708791+00	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 13:00:09.708791+00
\.


--
-- Data for Name: log_project_task_assignments; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.log_project_task_assignments ("Id", "TaskId", "EmployeeId", "Action", "ResourceName", "TeamType", "OccurredAtUtc", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
9367bd5d-911b-44a3-ad0f-20f6748b58fc	76163f06-d217-45a1-a127-30f59b86d5a1	ffcdc44f-996b-4ef6-90e6-db858823a4c4	Assign	Aditya Menon	Project Team	2026-10-17 13:21:33.01246+00	2026-10-17 13:21:33.028806+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
cfa880ff-4721-420c-859f-6a8787fa22a1	d97b4bad-ccd2-42c0-b1ff-e52787ef8f0c	cc295432-e771-4d6f-9cc3-079cc5d9b576	Assign	Alok Deshpande	Project Team	2026-10-17 13:21:37.65345+00	2026-10-17 13:21:37.653558+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
8bcd6cf7-f31a-4e72-990e-76813c6dc6c6	76163f06-d217-45a1-a127-30f59b86d5a1	ffcdc44f-996b-4ef6-90e6-db858823a4c4	Unassign	Aditya Menon	Project Team	2026-10-18 04:00:19.513513+00	2026-10-18 04:00:19.518318+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
b7b5575c-3dae-4ad9-ab15-785da82bd53b	3757f288-0451-44bc-b54c-e29a3a758d69	b9c0b8fc-4c96-42fb-8669-d68097cf5392	Assign	Aditi Roy	Project Team	2026-10-18 05:58:43.268394+00	2026-10-18 05:58:43.274124+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
fb081f38-4656-4416-9088-cfb9a87972bb	b2f0840e-dc0d-45a6-932f-5f892ab2cd9a	78b71d74-d255-4ac0-a75f-ead11a61427a	Assign	Aarav Desai	Project Team	2026-10-21 07:32:25.999311+00	2026-10-21 07:32:26.006286+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
8e6489b0-7098-4751-8934-bdd2026b441d	b2f0840e-dc0d-45a6-932f-5f892ab2cd9a	78b71d74-d255-4ac0-a75f-ead11a61427a	Unassign	Aarav Desai	Project Team	2026-10-22 10:16:08.519044+00	2026-10-22 10:16:08.536273+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: tbl_project_documents; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_documents ("Id", "ProjectId", "DocumentType", "FileName", "OriginalFileName", "FilePath", "ContentType", "SizeBytes", "Description", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
c95ad522-124d-46ea-bf8e-692d229d7ee8	89744e80-08e3-4f7c-a4ba-78ff0ce54634	PO	20261014_042140_885_Omkar_Gaikwad_Resume.pdf	Omkar_Gaikwad_Resume.pdf	PO/20261014_042140_885_Omkar_Gaikwad_Resume.pdf	application/pdf	131096	\N	2026-10-14 04:21:40.892904+00	\N	00000000-0000-4000-8000-000000000004	\N	\N
8181c91d-ce68-43c7-9fb8-d89ecfe88150	8e260568-b761-4795-ad27-12bddd698d9d	PO	20261014_070925_360_ai_ml_sahil_lad.pdf	ai_ml_sahil_lad.pdf	PO/20261014_070925_360_ai_ml_sahil_lad.pdf	application/pdf	112021	\N	2026-10-14 07:09:25.395943+00	\N	00000000-0000-4000-8000-000000000004	\N	\N
998d8328-c606-4880-bd7c-7de2bc787f09	96427433-d1b9-4089-bcee-e95f02d3154d	PO	20261019_102554_436_employee-bulk-upload-sample.xlsx	employee-bulk-upload-sample.xlsx	PO/20261019_102554_436_employee-bulk-upload-sample.xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	42350	\N	2026-10-19 10:25:54.43961+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: tbl_project_drafts; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_drafts ("Id", "ProjectName", "ClientId", "ClientName", "SalesPerson", "FormSnapshotJson", "CreatedByName", "UpdatedByName", "Status", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
d53cbbc1-d83c-437e-bf19-af4aca663b1c	Aditya Birla(Aditya Birla_Finance)_AWS Security Assessment_01	bf01f81e-b09c-47c1-811c-40a58a56db12	Aditya Birla	Sales User	{"poDate": "", "currency": "INR", "poNumber": "", "poStatus": "PO Received", "svSearch": "Aditya Birla_Finance", "isRenewal": false, "wbsSearch": "", "clientName": "Aditya Birla", "targetDate": "", "taxPercent": 18, "contactName": "", "invoiceRows": [{"qty": 1, "rowId": "CS001::Month 1", "amount": 9167, "currency": "INR", "milestone": "Month 1", "serviceId": "CS001", "unitPrice": 55000, "targetDate": "2026-10-14", "paymentDate": "", "serviceName": "AWS Security Assessment", "invoiceNumber": "", "invoiceStatus": "Not Raised", "paymentStatus": "Not Received"}, {"qty": 1, "rowId": "CS001::Month 2", "amount": 9167, "currency": "INR", "milestone": "Month 2", "serviceId": "CS001", "unitPrice": 55000, "targetDate": "2026-11-14", "paymentDate": "", "serviceName": "AWS Security Assessment", "invoiceNumber": "", "invoiceStatus": "Not Raised", "paymentStatus": "Not Received"}, {"qty": 1, "rowId": "CS001::Month 3", "amount": 9167, "currency": "INR", "milestone": "Month 3", "serviceId": "CS001", "unitPrice": 55000, "targetDate": "2026-11-14", "paymentDate": "", "serviceName": "AWS Security Assessment", "invoiceNumber": "", "invoiceStatus": "Not Raised", "paymentStatus": "Not Received"}, {"qty": 1, "rowId": "CS001::Month 4", "amount": 9167, "currency": "INR", "milestone": "Month 4", "serviceId": "CS001", "unitPrice": 55000, "targetDate": "2026-12-14", "paymentDate": "", "serviceName": "AWS Security Assessment", "invoiceNumber": "", "invoiceStatus": "Not Raised", "paymentStatus": "Not Received"}, {"qty": 1, "rowId": "CS001::Month 5", "amount": 9167, "currency": "INR", "milestone": "Month 5", "serviceId": "CS001", "unitPrice": 55000, "targetDate": "2026-12-14", "paymentDate": "", "serviceName": "AWS Security Assessment", "invoiceNumber": "", "invoiceStatus": "Not Raised", "paymentStatus": "Not Received"}, {"qty": 1, "rowId": "CS001::Month 6", "amount": 9167, "currency": "INR", "milestone": "Month 6", "serviceId": "CS001", "unitPrice": 55000, "targetDate": "2027-01-14", "paymentDate": "", "serviceName": "AWS Security Assessment", "invoiceNumber": "", "invoiceStatus": "Not Raised", "paymentStatus": "Not Received"}], "projectName": "Aditya Birla(Aditya Birla_Finance)_AWS Security Assessment_01", "projectType": "Long Term", "salesPerson": "Sales User", "serviceRows": [{"qty": 1, "dept": "Cloud Security", "name": "AWS Security Assessment", "rowId": "CS001", "tools": "Scout2, CloudMapper, AWS Inspector", "total": 55000, "taskId": "WBS-01", "endDate": "2027-04-14", "subDept": "AWS Security Assessment", "location": "Offsite", "totalHrs": 1048, "frequency": "Half yearly", "startDate": "2026-10-14", "totalDays": 131, "unitPrice": 55000, "description": "", "durationHrs": 1048, "billingModel": "", "durationDays": 131, "locationText": "", "resourceDist": {"L1": 1, "L2": 0, "Senior": 0}, "serviceModel": "NA", "deliveryModel": "Remote", "resourceLevel": "L1", "deliveryFormat": "PDF"}], "billingModel": "Monthly Advance", "clientSearch": "Aditya Birla", "contactEmail": "", "contractType": "Resource", "paymentTerms": "Start of Each Month", "contactNumber": "", "customPayments": [{"pct": 100, "label": "First Payment"}], "renewalProject": null, "renewalProjectId": null, "sectionAComments": "", "sectionBComments": "", "selectedClientId": "bf01f81e-b09c-47c1-811c-40a58a56db12", "engagementManager": "Pradeep Singh", "projectIssuedDate": "2026-10-14", "selectedSubVenture": "Aditya Birla_Finance"}	Dhanshree	Dhanshree	converted	2026-10-14 04:20:19.014768+00	2026-10-14 04:21:40.911878+00	00000000-0000-4000-8000-000000000004	00000000-0000-4000-8000-000000000004	\N
9e26200e-3e93-45c3-b185-d9678c6b69f1	Aditya Birla Draft	bf01f81e-b09c-47c1-811c-40a58a56db12	Aditya Birla	\N	{"poDate": "", "currency": "INR", "poNumber": "", "poStatus": "", "svSearch": "Aditya Birla_Finance", "isRenewal": false, "wbsSearch": "", "clientName": "Aditya Birla", "targetDate": "", "taxPercent": 18, "contactName": "", "invoiceRows": [], "projectName": "", "projectType": "", "salesPerson": "", "serviceRows": [], "billingModel": "", "clientSearch": "Aditya Birla", "contactEmail": "", "contractType": "", "paymentTerms": "", "contactNumber": "", "customPayments": [{"pct": 100, "label": "First Payment"}], "renewalProject": null, "renewalProjectId": null, "sectionAComments": "", "sectionBComments": "", "selectedClientId": "bf01f81e-b09c-47c1-811c-40a58a56db12", "engagementManager": "Karan Wardhan", "projectIssuedDate": "2026-10-21", "selectedSubVenture": "Aditya Birla_Finance"}	Admin User	Admin User	active	2026-10-21 06:57:30.170061+00	2026-10-21 09:57:19.170631+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-21 09:57:19.170631+00
\.


--
-- Data for Name: tbl_project_extension_approvers; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_extension_approvers ("Id", "ExtensionRequestId", "EmployeeId", "EmployeeName", "Status", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
347528c7-bca9-45f4-8fad-58b7c221301e	7e12df6f-c635-4fd0-b9c4-d396645f6c47	8e0616db-48af-4b73-807f-6e250dba2072	Anita Pandey	Pending	2026-10-22 07:55:31.380284+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
9c107482-d9cd-4186-8768-bc1f926ca4b7	7e12df6f-c635-4fd0-b9c4-d396645f6c47	696f99d7-2380-443c-b90d-0e065642e1d4	Priya Mishra	Pending	2026-10-22 07:55:31.380284+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
4b7186df-c9fd-4ecd-9921-a017f6d7ffe6	f790b06c-6959-49fe-90a1-47b1b70e05d3	be9f417e-d40a-4c66-91e6-e7fde84b46d5	Krishna Pandey	Pending	2026-10-22 08:05:09.241684+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: tbl_project_extension_requests; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_extension_requests ("Id", "ProjectId", "CurrentEndDate", "RequestedEndDate", "ExtensionDays", "Reason", "Status", "RequestedByEmployeeId", "RequestedByName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
7e12df6f-c635-4fd0-b9c4-d396645f6c47	89744e80-08e3-4f7c-a4ba-78ff0ce54634	2027-04-14	2027-05-14	30	Client asked to extend the assessment window.	Pending	049ac489-bbd3-4153-b933-aec7b7baec89	Admin User	2026-10-22 07:55:31.380284+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
f790b06c-6959-49fe-90a1-47b1b70e05d3	96427433-d1b9-4089-bcee-e95f02d3154d	2027-04-19	2027-04-20	1	developers delay	Pending	049ac489-bbd3-4153-b933-aec7b7baec89	Admin User	2026-10-22 08:05:09.241684+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: tbl_project_interviews; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_interviews ("Id", "ProjectId", "EmployeeId", "ResourceName", "InterviewDate", "InterviewTime", "Result", "Comments", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
df35b30e-a543-4f25-b28f-7045105efee0	89744e80-08e3-4f7c-a4ba-78ff0ce54634	3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	Harsh Gupta	2026-10-24	14:15:00	Pending	Moved after postponement.	2026-10-19 11:27:24.080268+00	2026-10-19 11:27:36.486322+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N
f95c0b35-3134-4314-83ed-2f5d1b8794a3	89744e80-08e3-4f7c-a4ba-78ff0ce54634	b9c0b8fc-4c96-42fb-8669-d68097cf5392	Aditi Roy	2026-11-02	15:45:00	Pending	Candidate requested a later slot.	2026-10-19 11:30:20.460154+00	2026-10-19 11:31:13.960902+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N
1bcc21d4-f76a-4d84-b36a-d8c6ab75b9e1	96427433-d1b9-4089-bcee-e95f02d3154d	78b71d74-d255-4ac0-a75f-ead11a61427a	Aarav Desai	2026-10-20	19:06:00	Selected	\N	2026-10-19 11:35:23.771997+00	2026-10-19 11:36:34.403176+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N
\.


--
-- Data for Name: tbl_project_invoices; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_invoices ("Id", "ProjectId", "MilestoneName", "Percentage", "Amount", "TaxAmount", "TotalAmount", "Status", "InvoiceNumber", "InvoiceDate", "DueDate", "PaymentDate", "Remarks", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "ServiceName", "Qty", "UnitPrice", "Currency", "ResourceLevel", "PaymentStatus") FROM stdin;
eade89db-0274-4797-9e29-ecac97e3258d	89744e80-08e3-4f7c-a4ba-78ff0ce54634	Month 2	\N	9167.00	1650.06	10817.06	Pending	\N	2026-11-14	2026-11-14	\N	\N	1	2026-10-14 04:21:40.824467+00	\N	00000000-0000-4000-8000-000000000004	\N	\N	\N	\N	\N	\N	\N	\N
830996d5-cd07-4f1b-8d09-94ff7237b3af	89744e80-08e3-4f7c-a4ba-78ff0ce54634	Month 3	\N	9167.00	1650.06	10817.06	Pending	\N	2026-11-14	2026-11-14	\N	\N	2	2026-10-14 04:21:40.83588+00	\N	00000000-0000-4000-8000-000000000004	\N	\N	\N	\N	\N	\N	\N	\N
739f1382-6ff6-4d5f-b48a-73e6f8432d96	89744e80-08e3-4f7c-a4ba-78ff0ce54634	Month 4	\N	9167.00	1650.06	10817.06	Pending	\N	2026-12-14	2026-12-14	\N	\N	3	2026-10-14 04:21:40.847109+00	\N	00000000-0000-4000-8000-000000000004	\N	\N	\N	\N	\N	\N	\N	\N
bb321de3-2a05-4bf9-bad0-2a87f14b179f	89744e80-08e3-4f7c-a4ba-78ff0ce54634	Month 5	\N	9167.00	1650.06	10817.06	Pending	\N	2026-12-14	2026-12-14	\N	\N	4	2026-10-14 04:21:40.857457+00	\N	00000000-0000-4000-8000-000000000004	\N	\N	\N	\N	\N	\N	\N	\N
fd1561d6-3da8-477c-adf7-9e30d7e3fc69	89744e80-08e3-4f7c-a4ba-78ff0ce54634	Month 6	\N	9167.00	1650.06	10817.06	Pending	\N	2027-01-14	2027-01-14	\N	\N	5	2026-10-14 04:21:40.867817+00	\N	00000000-0000-4000-8000-000000000004	\N	\N	\N	\N	\N	\N	\N	\N
6994cd4c-49d7-4efc-8c8c-5ddd15a93593	8e260568-b761-4795-ad27-12bddd698d9d	Month 1	\N	55000.00	9900.00	64900.00	Pending	\N	2026-10-27	2026-10-27	\N	\N	0	2026-10-14 07:09:24.895848+00	\N	00000000-0000-4000-8000-000000000004	\N	\N	\N	\N	\N	\N	\N	\N
e5f25f3e-86d7-4840-a987-86ad8b21fe52	8e260568-b761-4795-ad27-12bddd698d9d	Month 1	\N	85000.00	15300.00	100300.00	Pending	\N	2026-10-22	2026-10-22	\N	\N	1	2026-10-14 07:09:25.170342+00	\N	00000000-0000-4000-8000-000000000004	\N	\N	\N	\N	\N	\N	\N	\N
0bc23c87-ca5f-4e66-94d1-7dc7fc5a5821	8e260568-b761-4795-ad27-12bddd698d9d	Month 3 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	3	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
143cb821-3251-46d8-be50-e547f1ccd715	8e260568-b761-4795-ad27-12bddd698d9d	Month 11 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	11	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
2a57dd6d-3c37-4ea5-95ec-b3d206c08df1	8e260568-b761-4795-ad27-12bddd698d9d	Month 8 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	8	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
38ce2d31-4f63-4fe2-99fd-a6676c9554d7	8e260568-b761-4795-ad27-12bddd698d9d	Month 6 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	6	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
44a02d31-f966-44e6-b089-d332c89da064	8e260568-b761-4795-ad27-12bddd698d9d	Month 4 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	4	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
4ab73b49-f85e-4267-870e-557518689dd5	8e260568-b761-4795-ad27-12bddd698d9d	Month 2 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	2	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
4c9b5c02-9998-4723-a181-4a2e131fb4dd	8e260568-b761-4795-ad27-12bddd698d9d	Month 12 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	12	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
7f5715db-f93e-40d2-ae56-da4512e2bfc7	8e260568-b761-4795-ad27-12bddd698d9d	Month 1 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	1	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
c05c8bc6-9e5d-4d86-bf7f-7ee62dcd7220	8e260568-b761-4795-ad27-12bddd698d9d	Month 9 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	9	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
c131fda2-2b1a-4081-b336-22108194fa92	8e260568-b761-4795-ad27-12bddd698d9d	Month 10 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	10	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
f4fe0625-505a-47a7-b65d-59e0adeb6428	8e260568-b761-4795-ad27-12bddd698d9d	Month 7 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	7	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
f8a92be9-b337-412f-b259-986d1321ecb2	8e260568-b761-4795-ad27-12bddd698d9d	Month 5 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	5	2026-10-18 04:00:19.62913+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
0d371a89-04fd-43b6-a8b8-6f33b11908f9	8e260568-b761-4795-ad27-12bddd698d9d	Month 4 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	4	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
2b84f497-110e-47e0-b507-b49a0d93a450	8e260568-b761-4795-ad27-12bddd698d9d	Month 7 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	7	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
2e8dd96b-cf81-45a4-b959-578665ce00b2	8e260568-b761-4795-ad27-12bddd698d9d	Month 9 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	9	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
3d44a04e-188b-45ef-9d4e-9fc2c4192292	8e260568-b761-4795-ad27-12bddd698d9d	Month 6 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	6	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
3d4f613e-2117-4a52-bc51-ead77ae0b369	8e260568-b761-4795-ad27-12bddd698d9d	Month 10 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	10	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
3f44e460-137f-4674-8367-211e40e87592	8e260568-b761-4795-ad27-12bddd698d9d	Month 3 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	3	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
5fa22305-a691-41b7-aace-229ef483fe6d	8e260568-b761-4795-ad27-12bddd698d9d	Month 5 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	5	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
616e104f-8c17-474b-b4a3-20eea9066ad5	8e260568-b761-4795-ad27-12bddd698d9d	Month 2 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	2	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
a6a97984-af59-46bc-b3f9-f4b5f5c65f07	8e260568-b761-4795-ad27-12bddd698d9d	Month 8 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	8	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
ac367cb5-0603-4ca9-9801-7f7361afb82c	8e260568-b761-4795-ad27-12bddd698d9d	Month 11 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	11	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
b3b7e16d-9a9a-4bc1-a7bc-e4dfa6f3c368	8e260568-b761-4795-ad27-12bddd698d9d	Month 1 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	1	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
f4097cd9-138e-4c87-932c-ba646082b98c	8e260568-b761-4795-ad27-12bddd698d9d	Month 12 Retainer (8.33%)	8.33	11666.67	2100.00	13766.67	Pending	\N	\N	\N	\N	\N	12	2026-10-18 04:02:03.565713+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	\N
5ab05b9a-a2e9-4ba7-a49b-afc3a4c1a864	96427433-d1b9-4089-bcee-e95f02d3154d	Month 2	\N	14167.00	2550.06	16717.06	Paid	INV-27	2026-10-21	2026-10-21	2026-10-21	\N	2	2026-10-19 10:25:54.367094+00	2026-10-21 07:37:39.154296+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	ISO 27001 Security Audit	1	85000.00	INR	L2	Received
bcb08f48-d6bf-44cf-b68d-ec53fc62419b	89744e80-08e3-4f7c-a4ba-78ff0ce54634	Month 1	\N	9167.00	1650.06	10817.06	Pending	\N	2026-10-14	2026-10-14	\N	\N	0	2026-10-14 04:21:40.799722+00	2026-10-19 10:14:56.50391+00	00000000-0000-4000-8000-000000000004	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	\N	\N	\N	\N	\N
477d97da-a48b-4d2d-bff7-1a58a77ced27	96427433-d1b9-4089-bcee-e95f02d3154d	Month 1	\N	80000.00	14400.00	94400.00	Paid	23123	2026-10-15	2026-10-15	2026-10-16	\N	0	2026-10-19 10:25:54.341795+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Targeted Red Team Engagement	1	80000.00	INR	L1	Received
b3a31523-7791-477c-a75f-cbb52040332a	96427433-d1b9-4089-bcee-e95f02d3154d	Month 1	\N	14167.00	2550.06	16717.06	Raised	12321	2026-10-06	2026-10-06	\N	\N	1	2026-10-19 10:25:54.355775+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	ISO 27001 Security Audit	1	85000.00	INR	L2	Not Received
6409b633-931a-4c61-92e7-01000c5c8614	96427433-d1b9-4089-bcee-e95f02d3154d	Month 3	\N	14167.00	2550.06	16717.06	Pending	\N	2026-10-23	2026-10-23	\N	\N	3	2026-10-19 10:25:54.377581+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	ISO 27001 Security Audit	1	85000.00	INR	L2	Not Received
f2298411-736d-464a-bd60-06fd5b8054fa	96427433-d1b9-4089-bcee-e95f02d3154d	Month 4	\N	14167.00	2550.06	16717.06	Pending	\N	2026-10-09	2026-10-09	\N	\N	4	2026-10-19 10:25:54.388757+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	ISO 27001 Security Audit	1	85000.00	INR	L2	Not Received
bf1ec0e4-ce61-4bb3-9bbe-9dffb6881586	96427433-d1b9-4089-bcee-e95f02d3154d	Month 5	\N	14167.00	2550.06	16717.06	Pending	\N	2026-10-17	2026-10-17	\N	\N	5	2026-10-19 10:25:54.39893+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	ISO 27001 Security Audit	1	85000.00	INR	L2	Not Received
5ad70841-9142-490d-94e7-0e1a6e23d6b1	96427433-d1b9-4089-bcee-e95f02d3154d	Month 6	\N	14167.00	2550.06	16717.06	Pending	\N	2026-10-14	2026-10-14	\N	\N	6	2026-10-19 10:25:54.409328+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	ISO 27001 Security Audit	1	85000.00	INR	L2	Not Received
\.


--
-- Data for Name: tbl_project_service_escalation_stakeholders; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_service_escalation_stakeholders ("Id", "EscalationId", "EmployeeId", "EmployeeName", "SubDepartment", "Status", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
2e226361-4a7b-42bf-9079-1fc14c74613f	3417ee64-fae5-4588-9839-b75c607c03bb	8e0616db-48af-4b73-807f-6e250dba2072	Anita Pandey	PMO (Project Management Office)	Pending	2026-10-22 10:24:32.168414+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
b9f86f16-d2dc-4b00-8db2-19c20fea8cca	3417ee64-fae5-4588-9839-b75c607c03bb	9f646393-8fea-4b38-9f35-d88a6ab6787e	Aarav Rao	EM (Engagement Manager)	Pending	2026-10-22 10:24:32.168414+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
f7ae9dbb-0266-4a42-b5f0-1d8e26abf228	9846557c-a879-4f60-9191-0d05992b5402	8e0616db-48af-4b73-807f-6e250dba2072	Anita Pandey	PMO (Project Management Office)	Pending	2026-10-22 10:25:25.851886+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
9f9bc432-1e24-4e0c-a112-ab3f1ea9257f	516ae012-e68a-498b-a232-2bacba591745	696f99d7-2380-443c-b90d-0e065642e1d4	Priya Mishra	PMO (Project Management Office)	Pending	2026-10-22 10:27:11.969724+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
d70c91fb-d883-4653-ac29-90d82cfddc37	516ae012-e68a-498b-a232-2bacba591745	eba0b052-26bb-4216-ab6e-dff23c63bc57	Rahul Mishra	EM (Engagement Manager)	Pending	2026-10-22 10:27:11.969724+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: tbl_project_service_escalations; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_service_escalations ("Id", "ProjectId", "ProjectServiceId", "ProjectCode", "ProjectName", "CustomerName", "ServiceName", "EscalationType", "Priority", "Subject", "Description", "ExpectedResolutionDate", "AttachmentFileName", "AttachmentPath", "AttachmentContentType", "AttachmentSizeBytes", "Status", "RaisedByEmployeeId", "RaisedByName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
3417ee64-fae5-4588-9839-b75c607c03bb	8e260568-b761-4795-ad27-12bddd698d9d	1a7796a3-3296-4f53-a764-d1092171eb9d	P002	Aditya Birla(Aditya Birla_Finance)_Mixed_02	Aditya Birla	Azure Security Assessment	Prerequisite Pending	High	Customer access is still pending	Production access has not been shared.	2026-11-05	escalation-note.txt	Escalation/20261022_102432_123_P002_escalation-note.txt	text/plain	16	Open	049ac489-bbd3-4153-b933-aec7b7baec89	Admin User	2026-10-22 10:24:32.168414+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
9846557c-a879-4f60-9191-0d05992b5402	89744e80-08e3-4f7c-a4ba-78ff0ce54634	b91ca6a8-82ad-4bb8-8397-27b0a1c9938e	P001	Aditya Birla(Aditya Birla_Finance)_AWS Security Assessment_01	Aditya Birla	AWS Security Assessment	Prerequisite Pending	High	AWS access is still pending	The customer has not shared the AWS console access.	2026-11-10	\N	\N	\N	\N	Open	049ac489-bbd3-4153-b933-aec7b7baec89	Admin User	2026-10-22 10:25:25.851886+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
516ae012-e68a-498b-a232-2bacba591745	96427433-d1b9-4089-bcee-e95f02d3154d	32c68ca2-cb1b-43e9-96a9-d34dd2c89bfb	P003	Aditya Birla(Aditya Birla_Finance)_Mixed_02	Aditya Birla	Targeted Red Team Engagement	Technical Blocker	High	Test	Test	2026-10-31	\N	\N	\N	\N	Open	049ac489-bbd3-4153-b933-aec7b7baec89	Admin User	2026-10-22 10:27:11.969724+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: tbl_project_services; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_services ("Id", "ProjectId", "ServiceCatalogId", "TaskId", "Department", "SubDepartment", "ServiceName", "Qty", "Description", "ResourceLevel", "Frequency", "Location", "LocationText", "ServiceModel", "DeliveryModel", "FinalDeliveryFormat", "BillingModel", "Tools", "StartDate", "EndDate", "DurationDays", "DurationHours", "TotalDays", "TotalHours", "UnitPrice", "Total", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BillingStatus", "CollectionStatus", "IsReady", "ValidationStatus") FROM stdin;
b91ca6a8-82ad-4bb8-8397-27b0a1c9938e	89744e80-08e3-4f7c-a4ba-78ff0ce54634	\N	WBS-01	Cloud Security	AWS Security Assessment	AWS Security Assessment	1	\N	L1	Half yearly	Offsite	\N	NA	Remote	PDF	Monthly Advance	Scout2, CloudMapper, AWS Inspector	2026-10-14	2027-04-14	131	1048	131	1048	55000.00	55000.00	0	2026-10-14 04:21:40.760314+00	2026-10-14 04:29:11.987368+00	00000000-0000-4000-8000-000000000004	00000000-0000-4000-8000-000000000004	\N	Advance Received	Pending To Collect	t	Pending To Validate
1a7796a3-3296-4f53-a764-d1092171eb9d	8e260568-b761-4795-ad27-12bddd698d9d	\N	WBS-01	Cloud Security	Azure Security Assessment	Azure Security Assessment	1	\N	L1	Once	Onsite	Pune	NA	Remote	Excel	Monthly Arrears	Azucar, Microsoft Defender, Qualys	2026-10-14	2026-10-20	5	40	5	40	55000.00	55000.00	0	2026-10-14 07:09:24.254822+00	2026-10-14 07:09:59.689522+00	00000000-0000-4000-8000-000000000004	00000000-0000-4000-8000-000000000004	\N	Advance Received	Pending To Collect	t	Pending To Validate
e0494ab5-859c-442b-9998-66e5cfb3ecbe	8e260568-b761-4795-ad27-12bddd698d9d	\N	WBS-02	Compliance & Audit	ISO 27001 Security Audit	ISO 27001 Security Audit	1	\N	L2	Once	Onsite	Kolhapur	NA	Remote	PDF	Monthly Arrears	AuditBoard, Drata, Vanta	2026-10-14	2026-10-23	8	64	8	64	85000.00	85000.00	1	2026-10-14 07:09:24.548035+00	2026-10-14 07:10:00.899816+00	00000000-0000-4000-8000-000000000004	00000000-0000-4000-8000-000000000004	\N	Advance Received	Pending To Collect	t	Pending To Validate
5529002b-5340-4e4e-8d21-45adb2a23037	8e260568-b761-4795-ad27-12bddd698d9d	\N	\N	General	\N	Custom Service	1	\N	\N	Once	Offsite	\N	Fixed	Agile	\N	Monthly Arrears	\N	2026-10-14	2026-10-23	5	40	5	40	0.00	0.00	0	2026-10-18 04:00:19.370027+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	Advance Pending	Pending To Collect	f	Pending To Validate
a47ece44-9b09-4b4e-acbc-4e1a66ec8401	8e260568-b761-4795-ad27-12bddd698d9d	\N	\N	General	\N	Custom Service	1	\N	\N	Once	Offsite	\N	Fixed	Agile	\N	Monthly Arrears	\N	2026-10-14	2026-10-23	5	40	5	40	0.00	0.00	0	2026-10-18 04:02:03.448525+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	Advance Pending	Pending To Collect	f	Pending To Validate
6ace031a-2e4e-4517-83ac-bf1078882b71	96427433-d1b9-4089-bcee-e95f02d3154d	\N	WBS-02	Compliance & Audit	ISO 27001 Security Audit	ISO 27001 Security Audit	1	Service 2	L2	Half yearly	Offsite	\N	NA	Remote	Squad 1	Monthly Advance	AuditBoard, Drata, Vanta	2026-10-19	2027-04-19	131	1048	131	1048	85000.00	85000.00	1	2026-10-19 10:25:54.318218+00	2026-10-19 10:27:58.002258+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	Advance Received	Pending To Collect	t	Pending To Validate
32c68ca2-cb1b-43e9-96a9-d34dd2c89bfb	96427433-d1b9-4089-bcee-e95f02d3154d	\N	WBS-01	Red Team & Adversary Simulation	Adversary Simulation	Targeted Red Team Engagement	1	Service 1	L1	Once	Onsite	Pune	NA	Remote	Excel	Monthly Advance	Custom Tools, Cobalt Strike	2026-10-19	2026-10-30	10	80	10	80	80000.00	80000.00	0	2026-10-19 10:25:54.267805+00	2026-10-21 07:24:47.800302+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	Advance Received	Pending To Collect	t	Pending To Validate
\.


--
-- Data for Name: tbl_project_task_assignments; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_task_assignments ("Id", "TaskId", "EmployeeId", "Role", "AllocatedHours", "UtilizedHours", "TimerStartedAtUtc", "TimerAccumulatedSeconds", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
467636cf-419e-47ce-9443-0e20fd38bad4	d97b4bad-ccd2-42c0-b1ff-e52787ef8f0c	cc295432-e771-4d6f-9cc3-079cc5d9b576	Contributor	64.00	0.00	\N	0	t	2026-10-17 13:21:37.653558+00	2026-10-17 13:21:37.700534+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N
efc8ff42-50eb-4e68-9cbd-26746f236d0f	76163f06-d217-45a1-a127-30f59b86d5a1	ffcdc44f-996b-4ef6-90e6-db858823a4c4	Contributor	40.00	0.00	\N	0	t	2026-10-17 13:21:33.028806+00	2026-10-18 04:00:19.518318+00	049ac489-bbd3-4153-b933-aec7b7baec89	cc9bf92a-b923-8364-be83-4bb68db79cd2	2026-10-18 04:00:19.518318+00
e3ffdda6-7663-4d89-83b3-b6596a0089b6	3757f288-0451-44bc-b54c-e29a3a758d69	b9c0b8fc-4c96-42fb-8669-d68097cf5392	Contributor	524.00	0.00	\N	0	t	2026-10-18 05:58:43.274124+00	2026-10-18 05:58:43.292963+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N
1fc85a63-900c-441f-8211-394fd5031982	b2f0840e-dc0d-45a6-932f-5f892ab2cd9a	78b71d74-d255-4ac0-a75f-ead11a61427a	Contributor	80.00	0.00	\N	0	t	2026-10-21 07:32:26.006286+00	2026-10-22 10:16:08.536273+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-22 10:16:08.536273+00
\.


--
-- Data for Name: tbl_project_tasks; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_tasks ("Id", "ProjectId", "ProjectServiceId", "Title", "Description", "Period", "Phase", "Stage", "Priority", "PlannedStartDate", "PlannedEndDate", "ActualStartDate", "ActualEndDate", "EstimatedHours", "UtilizedHours", "Progress", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
08e951a4-6ec6-46c9-ba95-f0ed087d2b17	89744e80-08e3-4f7c-a4ba-78ff0ce54634	b91ca6a8-82ad-4bb8-8397-27b0a1c9938e	Task 01	NA	Quarter 2	AP1	Not Started	medium	2026-10-14	2027-04-14	\N	\N	524.00	0.00	0	20	2026-10-14 04:28:52.764637+00	\N	00000000-0000-4000-8000-000000000004	\N	\N
3757f288-0451-44bc-b54c-e29a3a758d69	89744e80-08e3-4f7c-a4ba-78ff0ce54634	b91ca6a8-82ad-4bb8-8397-27b0a1c9938e	Task 01	NA	Quarter 1	AP1	Not Started	medium	2026-10-14	2027-04-14	\N	\N	524.00	0.00	0	10	2026-10-14 04:28:52.764637+00	\N	00000000-0000-4000-8000-000000000004	\N	\N
d97b4bad-ccd2-42c0-b1ff-e52787ef8f0c	8e260568-b761-4795-ad27-12bddd698d9d	e0494ab5-859c-442b-9998-66e5cfb3ecbe	Task 01	NA		AP1	Not Started	medium	2026-10-14	2026-10-23	\N	\N	64.00	0.00	0	20	2026-10-14 07:10:26.068485+00	\N	00000000-0000-4000-8000-000000000004	\N	\N
76163f06-d217-45a1-a127-30f59b86d5a1	8e260568-b761-4795-ad27-12bddd698d9d	1a7796a3-3296-4f53-a764-d1092171eb9d	Task 01	NA		AP1	Ongoing	medium	2026-10-14	2026-10-20	2026-10-14	2026-10-21	40.00	0.00	0	10	2026-10-14 07:10:26.068485+00	2026-10-16 07:28:47.629625+00	00000000-0000-4000-8000-000000000004	00000000-0000-4000-8000-000000000004	\N
9077037b-28c1-459e-af55-dbf3faf79996	8e260568-b761-4795-ad27-12bddd698d9d	5529002b-5340-4e4e-8d21-45adb2a23037	Task 01	Initial Test		AP1	Not Started	medium	2026-10-14	2026-10-23	\N	\N	40.00	0.00	0	30	2026-10-18 04:00:19.48887+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
c5525158-23a3-4f31-a8f2-5026a880d3c9	8e260568-b761-4795-ad27-12bddd698d9d	a47ece44-9b09-4b4e-acbc-4e1a66ec8401	Task 01	Initial Test		AP1	Not Started	medium	2026-10-14	2026-10-23	\N	\N	40.00	0.00	0	40	2026-10-18 04:02:03.487494+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
07d22ba2-61f8-4c4b-965d-451a49e43518	96427433-d1b9-4089-bcee-e95f02d3154d	6ace031a-2e4e-4517-83ac-bf1078882b71	Task 01	NA	Quarter 2	AP1	Not Started	medium	2026-10-19	2027-04-19	\N	\N	524.00	0.00	0	30	2026-10-19 10:27:34.74909+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
b2f0840e-dc0d-45a6-932f-5f892ab2cd9a	96427433-d1b9-4089-bcee-e95f02d3154d	32c68ca2-cb1b-43e9-96a9-d34dd2c89bfb	Task 01	NA		AP1	Not Started	medium	2026-10-19	2026-10-30	\N	\N	80.00	0.00	0	10	2026-10-19 10:27:34.74909+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
c161aad1-c9fd-4a5b-bf2c-937918db53a6	96427433-d1b9-4089-bcee-e95f02d3154d	6ace031a-2e4e-4517-83ac-bf1078882b71	Task 01	NA	Quarter 1	AP1	Not Started	medium	2026-10-19	2027-04-19	\N	\N	524.00	0.00	0	20	2026-10-19 10:27:34.74909+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: tbl_project_team_members; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_team_members ("Id", "ProjectId", "EmployeeId", "DepartmentId", "SubDepartment", "AllocationStartDate", "AllocationEndDate", "Billability", "IsTeamLead", "ResourceType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "IsShadowTeam", "MemberRole") FROM stdin;
0f16fb71-20b3-4bc1-98f7-23168931ecf8	8e260568-b761-4795-ad27-12bddd698d9d	315ae0c9-ecdf-48ba-a662-f93c21ef31d2	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	Services - Operations	2026-10-14	2026-10-23	Billable	f	Dedicated	2026-10-17 09:01:15.247959+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	SeniorProjectManager
181a6069-51be-44c2-b1e1-3f71185e3e3a	8e260568-b761-4795-ad27-12bddd698d9d	cc295432-e771-4d6f-9cc3-079cc5d9b576	0aed67b8-c454-439a-a07f-4f46d46d58af	Service - Testing - AppSec	2026-10-18	2026-10-23	Billable	t	Dedicated	2026-10-17 09:18:24.296578+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	ProjectTeam
eddfd31c-e6ae-47a3-b819-e2d40b72dd07	8e260568-b761-4795-ad27-12bddd698d9d	ffcdc44f-996b-4ef6-90e6-db858823a4c4	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	Services - Operations	2026-10-17	2026-10-23	Billable	f	Dedicated	2026-10-17 09:01:34.594564+00	2026-10-18 04:16:01.777348+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	f	ProjectTeam
2f0413c0-c2e1-4857-88be-0fef3c8e8e0e	8e260568-b761-4795-ad27-12bddd698d9d	bbdc4c49-4262-4c1a-a270-1bfe3c550644	be8e036d-ad13-4c79-89ec-294e490a6816	Services - Consulting	2026-10-14	2026-10-23	Billable	f	Dedicated	2026-10-17 09:01:12.422578+00	2026-10-18 04:16:08.283471+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 04:16:08.283471+00	f	ProjectManager
b47f893c-7288-4be6-8907-49b75fc92545	8e260568-b761-4795-ad27-12bddd698d9d	8e139039-c490-436d-9af4-431d26334b34	0aed67b8-c454-439a-a07f-4f46d46d58af	\N	2026-10-18	2026-10-23	Non-Billable	f	Shared Resource	2026-10-18 04:17:18.554504+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	ShadowTeam
c12115a9-470b-488d-981c-79ba86ff018c	89744e80-08e3-4f7c-a4ba-78ff0ce54634	dd200677-337b-440b-afcb-3a661406f98b	0aed67b8-c454-439a-a07f-4f46d46d58af	Service - Testing - Infra	2026-10-14	2027-04-14	Billable	f	Dedicated	2026-10-18 05:54:25.87418+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	SeniorProjectManager
8dbbf52b-1033-4ee6-b8a7-95e3d965be47	89744e80-08e3-4f7c-a4ba-78ff0ce54634	204776c8-efeb-480f-980b-a3f70be97f91	0aed67b8-c454-439a-a07f-4f46d46d58af	Service - Testing - Infra	2026-10-14	2027-04-14	Billable	f	Dedicated	2026-10-18 05:54:52.485147+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	ProjectManager
d6e0db76-3d03-4405-bc0a-ee6703cafd46	89744e80-08e3-4f7c-a4ba-78ff0ce54634	b9c0b8fc-4c96-42fb-8669-d68097cf5392	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	Services - Operations	2026-10-18	2026-10-31	Billable	t	Dedicated	2026-10-18 05:56:49.03405+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	ProjectTeam
afc2002a-6a09-4ccd-93a0-d515cb5db41d	89744e80-08e3-4f7c-a4ba-78ff0ce54634	3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	0aed67b8-c454-439a-a07f-4f46d46d58af	Service - Testing - Infra	2026-10-18	2026-10-31	Billable	t	Dedicated	2026-10-18 05:56:22.079702+00	2026-10-18 05:57:14.723118+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	f	ProjectTeam
47324f1e-7d06-4e4a-bac1-1981ba84e930	8e260568-b761-4795-ad27-12bddd698d9d	8f3346d4-6f76-4575-af6d-a69527694680	0aed67b8-c454-439a-a07f-4f46d46d58af	Service - Testing - Mobile	2026-10-14	2026-10-23	Billable	f	Dedicated	2026-10-18 12:37:40.903362+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	SeniorProjectManager
53bb3c58-9818-4e43-85b0-cf096f332ca4	8e260568-b761-4795-ad27-12bddd698d9d	41708635-a60e-4fbd-a76b-91c0c23d18be	0aed67b8-c454-439a-a07f-4f46d46d58af	Service - Testing - Mobile	2026-10-14	2026-10-23	Billable	f	Dedicated	2026-10-18 04:16:11.997372+00	2026-10-19 10:19:28.595873+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-19 10:19:28.595873+00	f	ProjectManager
adcc9aed-8994-4d9d-a028-d9039769d197	8e260568-b761-4795-ad27-12bddd698d9d	033446c7-c133-4395-bdaa-69b5f227a7a8	8e4e88f1-e294-4554-80cc-92ed6169caeb	EM (Engagement Manager)	2026-10-14	2026-10-23	Billable	f	Dedicated	2026-10-18 04:16:08.283471+00	2026-10-19 10:19:28.595873+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-19 10:19:28.595873+00	f	ProjectManager
b728622a-17d0-4adb-97a6-ccc12307b941	8e260568-b761-4795-ad27-12bddd698d9d	776f2cf7-c4cc-4299-b38f-afbcaff7703e	13c91c98-00ae-4211-acb8-d06e35953806	Functional - Sales	2026-10-14	2026-10-23	Billable	f	Dedicated	2026-10-19 10:19:28.595873+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	ProjectManager
68c9f309-e9da-4355-9e5a-c2d99e11aa19	96427433-d1b9-4089-bcee-e95f02d3154d	ffcdc44f-996b-4ef6-90e6-db858823a4c4	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	Services - Operations	2026-10-19	2027-04-19	Billable	f	Dedicated	2026-10-19 10:26:58.131354+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	ProjectManager
1b820e41-e7ec-491c-b278-7594f11375b3	96427433-d1b9-4089-bcee-e95f02d3154d	bfb55863-c987-497b-9a1b-9a7bc56a9509	0aed67b8-c454-439a-a07f-4f46d46d58af	Service - Testing - AppSec	2026-10-19	2027-04-19	Billable	f	Dedicated	2026-10-19 10:27:02.691266+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	SeniorProjectManager
46f7bcb3-6477-4110-96c0-41e5be125651	89744e80-08e3-4f7c-a4ba-78ff0ce54634	78b71d74-d255-4ac0-a75f-ead11a61427a	898c36e9-1cb7-4c56-9148-a3b6893c0149	R&D (Research & Development)	2026-10-28	2026-10-31	Billable	f	Shared Resource	2026-10-19 11:18:36.432191+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	ProjectTeam
3698e333-1ca1-41f9-894c-5bf8560cad38	96427433-d1b9-4089-bcee-e95f02d3154d	78b71d74-d255-4ac0-a75f-ead11a61427a	898c36e9-1cb7-4c56-9148-a3b6893c0149	R&D (Research & Development)	2026-10-31	2026-11-19	Billable	t	Dedicated	2026-10-19 10:27:24.426167+00	2026-10-19 11:45:54.311607+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	f	ProjectTeam
\.


--
-- Data for Name: tbl_projects; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_projects ("Id", "ProjectCode", "WbsId", "Name", "Description", "ClientId", "SubVentureId", "Status", "Health", "Progress", "ContractType", "ProjectType", "Currency", "TaxPercent", "StartDate", "EndDate", "Budget", "Spent", "TotalHours", "TotalDays", "InvoiceValue", "ProjectManagerId", "TeamLeadId", "EngagementManager", "EngagementManagerId", "SalesPerson", "SalesPersonId", "ProjectIssuedDate", "SectionAComments", "SectionBComments", "WbsStatus", "WbsSubStatus", "RenewedFromProjectId", "PoStatus", "PoNumber", "PoDate", "BillingModel", "PaymentTerms", "TargetDate", "AccountContactName", "AccountContactPhone", "AccountContactEmail", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
89744e80-08e3-4f7c-a4ba-78ff0ce54634	P001	IN-2026-27/C001-01/P001	Aditya Birla(Aditya Birla_Finance)_AWS Security Assessment_01		bf01f81e-b09c-47c1-811c-40a58a56db12	c005cbc3-03a8-4dec-b3d0-c44868e18f28	ongoing	green	0	Resource	Long Term	INR	18.00	2026-10-14	2027-04-14	55000.00	0.00	1048.00	131.00	64902.36	204776c8-efeb-480f-980b-a3f70be97f91	3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	Pradeep Singh	\N	Sales User	\N	2026-10-14	\N	\N	assigned	WBS Assigned	\N	PO Received	\N	\N	Monthly Advance	Start of Each Month	\N	\N	\N	\N	2026-10-14 04:21:40.721491+00	2026-10-18 05:57:14.723118+00	00000000-0000-4000-8000-000000000004	049ac489-bbd3-4153-b933-aec7b7baec89	\N
8e260568-b761-4795-ad27-12bddd698d9d	P002	IN-2026-27/C001-01/P002	Aditya Birla(Aditya Birla_Finance)_Mixed_02	hellloooooooo	bf01f81e-b09c-47c1-811c-40a58a56db12	c005cbc3-03a8-4dec-b3d0-c44868e18f28	ongoing	green	0	Resource	Long Term	INR	18.00	2026-10-14	2026-10-23	140000.00	0.00	184.00	23.00	495600.08	776f2cf7-c4cc-4299-b38f-afbcaff7703e	cc295432-e771-4d6f-9cc3-079cc5d9b576	Pradeep Singh	\N	Sales User	\N	2026-10-14	\N	\N	assigned	WBS Assigned	\N	PO Received	\N	\N	Monthly Arrears	End of Each Month	\N	\N	\N	\N	2026-10-14 07:09:23.532367+00	2026-10-19 10:19:28.595873+00	00000000-0000-4000-8000-000000000004	049ac489-bbd3-4153-b933-aec7b7baec89	\N
96427433-d1b9-4089-bcee-e95f02d3154d	P003	IN-2026-27/C001-01/P003	Aditya Birla(Aditya Birla_Finance)_Mixed_02	This is the comment related to project	bf01f81e-b09c-47c1-811c-40a58a56db12	c005cbc3-03a8-4dec-b3d0-c44868e18f28	ongoing	green	0	Resource	Long Term	INR	18.00	2026-10-19	2027-04-19	165000.00	0.00	1128.00	141.00	194702.36	ffcdc44f-996b-4ef6-90e6-db858823a4c4	78b71d74-d255-4ac0-a75f-ead11a61427a	Pradeep Singh	\N	Omkar Reddy	\N	2026-10-19	\N	\N	assigned	WBS Assigned	8e260568-b761-4795-ad27-12bddd698d9d	PO Received	\N	\N	Monthly Advance	Start of Each Month	\N	\N	\N	\N	2026-10-19 10:25:54.182447+00	2026-10-22 07:56:34.022114+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: -
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
20260905140000_AddEmployeeEmploymentBondFields	10.0.4
20260908050000_AddCertificationsAndDegrees	10.0.4
20260908190000_AddClientBillingMedium	10.0.4
20260908193000_AddClientGroupSpocFields	10.0.4
20260909120000_AddClientContactCountry	10.0.4
20260909130000_AddContactDesignationMaster	10.0.4
20260909140000_AddContactTypeMaster	10.0.4
20260912193000_RemoveEmployeeProjectSite	10.0.4
20260921133000_AddExitedEmployeeClearanceAndRating	10.0.4
20260923120000_AddTeamSchedule	10.0.4
20260927183000_AddTimesheets	10.0.4
20260914182626_AddServiceCatalogMasterTables	10.0.4
20260914183236_AddProjectsTable	10.0.4
20260914184206_AddProjectServicesAndResourceLevels	10.0.4
20260914185552_AddProjectTasks	10.0.4
20260914190040_AddProjectTaskAssignments	10.0.4
20260914190333_AddProjectInvoices	10.0.4
20260914190754_AddProjectDocuments	10.0.4
20260923152157_AddProjectDraftsTable	10.0.4
20260923193605_AddProjectTeamMembersTable	10.0.4
20260923203958_AddProjectTeamMemberIsShadowTeam	10.0.4
20260924060647_AddProjectTaskLeafIdentity	10.0.4
20260927191151_AddProjectTaskAssignmentHistory	10.0.4
20260928051557_DropProjectServiceResourceLevels	10.0.4
20260929053844_AddProjectTeamMemberRole	10.0.4
20260929183000_AddProjectServicePrerequisite	10.0.4
20261002185412_MoveTablesIntoModuleSchemas	10.0.4
20261002195129_LimitTimesheetReviewComment	10.0.4
20261007162838_AddAddressCityMaster	10.0.12
20261012130236_AddSubVentureCode	10.0.12
20261013080530_AddClientEditFields	10.0.12
20261019103000_AddProjectInvoiceScheduleFields	10.0.4
20261019124500_AddProjectInterviews	10.0.4
20261020154155_RemoveRbacPermissionsAndOnFloorRoles	10.0.4
20261020160744_AddOnFloorRoleMap	10.0.4
20261020182948_AddSubDepartmentCatalog	10.0.4
20261021061522_MoveOnFloorSubDepartmentToMaster	10.0.4
20261021064641_AddOrgRoleMapSubDepartmentId	10.0.4
20261021093011_DropOrgRoleMapSubDepartmentName	10.0.4
20261021095157_AddSidebarModules	10.0.4
20261021104029_AddSidebarSubModules	10.0.4
20261021120356_AddDashboardWidgets	10.0.4
20261021121703_AddModuleTabs	10.0.4
20261021123146_AddTabSubModuleId	10.0.4
20261022120000_AddProjectExtensionRequests	10.0.4
20261022153000_AddProjectServiceEscalations	10.0.4
\.


--
-- Data for Name: log_repository_activity; Type: TABLE DATA; Schema: repository; Owner: -
--

COPY repository.log_repository_activity ("Id", "Action", "DocumentId", "FileName", "Category", "PerformedBy", "Details", "CreatedAtUtc", "DeletedAtUtc", "CreatedBy", "UpdatedBy", "UpdatedAtUtc") FROM stdin;
56417b82-e7f6-41ec-b367-fcbbe88e7893	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Admin User viewed Resource Allocation SOP.pdf	2026-10-18 04:00:05.609011+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
cfb6b1ba-23f1-48fd-98a1-eac9cc504902	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Admin User viewed Resource Allocation SOP.pdf	2026-10-22 06:56:24.940485+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
f6cc8a6a-8916-48e5-9245-8674626695cb	Viewed	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Admin User	Admin User viewed Code of Conduct 2026.pdf	2026-10-22 06:56:27.25754+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
6aca67ea-a283-4c9d-bbb5-7c9da9592567	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Admin User viewed Resource Allocation SOP.pdf	2026-10-24 16:21:03.489566+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
88b0aadb-94d6-46c5-b88f-0740b5c4cd66	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Aditya Roy	Aditya Roy viewed Resource Allocation SOP.pdf	2026-10-26 05:57:48.190969+00	\N	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	\N	\N
b980db78-d1df-4564-a97a-1ae5b1f9405d	Deleted	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Deleted Resource Allocation SOP.pdf from PMS	2026-08-25 09:40:58.873408+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f7845c8d-d6ac-4d69-8156-1de050ee0f9f	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Admin User viewed Resource Allocation SOP.pdf	2026-10-22 06:56:29.909824+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
2d7f3fd1-4b2c-44f8-82b0-2604e823443f	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Admin User viewed Resource Allocation SOP.pdf	2026-10-24 16:21:18.131132+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
d1c5d8ea-453a-4223-a958-99cdb7634c97	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Aditya Roy	Aditya Roy viewed Resource Allocation SOP.pdf	2026-10-26 06:25:08.212085+00	\N	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	\N	\N
7ce0515d-7388-40bd-8448-629506b4da69	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Admin User viewed Resource Allocation SOP.pdf	2026-08-25 09:32:49.583916+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
568d9221-2331-4e91-804f-ed096870c14b	Uploaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Ankit Verma	Ankit Verma uploaded Code of Conduct 2026.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
96e82a4e-2ecb-4026-9e80-594ffe1ce32a	Uploaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Pooja Menon	Pooja Menon uploaded Resource Allocation SOP.pdf	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
8b2808e5-53b8-4aef-beb8-512679d9c20d	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Sneha Iyer	Sneha Iyer downloaded Code of Conduct 2026.pdf	2026-08-23 09:41:48.449326+00	\N	\N	\N	\N
d10c04f1-d038-4dda-9231-c03ac2e46843	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Karthik Bose	Karthik Bose downloaded Code of Conduct 2026.pdf	2026-08-21 11:41:48.449326+00	\N	\N	\N	\N
2e680325-0b10-48f6-9d10-67875d929aca	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Sneha Iyer	Sneha Iyer downloaded Code of Conduct 2026.pdf	2026-08-21 16:41:48.449326+00	\N	\N	\N	\N
8ff68488-7f36-4304-9bc3-ed8b8ae53c56	Downloaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Karthik Bose	Karthik Bose downloaded Resource Allocation SOP.pdf	2026-08-23 02:41:48.449326+00	\N	\N	\N	\N
47d0a623-9a3c-444c-a84e-dd86e1d7e39b	Downloaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Ira Kapoor	Ira Kapoor downloaded Resource Allocation SOP.pdf	2026-08-23 12:41:48.449326+00	\N	\N	\N	\N
0b691530-b686-407e-863a-e7524e3a55b8	Downloaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Harsh Nair	Harsh Nair downloaded Resource Allocation SOP.pdf	2026-08-22 09:41:48.449326+00	\N	\N	\N	\N
7bbc408f-729a-4ec2-8838-5ab635073bb4	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	admin@acme.co	admin@acme.co viewed Resource Allocation SOP.pdf	2026-08-25 09:32:49.629901+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
861174aa-1f5d-4349-be18-db9e1ad9c3d8	Deleted	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Admin User	Deleted Code of Conduct 2026.pdf from IMP	2026-08-25 09:41:08.982288+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
01aab1ba-d7e5-481f-b27b-55273134fb9f	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Rohan Joshi	Rohan Joshi downloaded Code of Conduct 2026.pdf	2026-09-29 11:24:13.722163+00	\N	\N	\N	\N
07fa6556-557c-470d-b5aa-8729556fdc5f	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Rajat Singhal	Rajat Singhal downloaded Code of Conduct 2026.pdf	2026-09-29 11:24:13.722163+00	\N	\N	\N	\N
1c84c800-8d29-4a13-85fa-fc66c1e4c266	Uploaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Ankit Verma	Initial repository import for Code of Conduct 2026.pdf	2026-09-29 11:24:13.722163+00	\N	\N	\N	\N
2e2eb7f2-e795-4a85-b1b9-ddcb3612d8ff	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Nikhil Rao	Nikhil Rao downloaded Code of Conduct 2026.pdf	2026-09-29 11:24:13.722163+00	\N	\N	\N	\N
37afb9e0-e150-4835-893e-22f4763a23c6	Uploaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Pooja Menon	Initial repository import for Resource Allocation SOP.pdf	2026-09-29 11:24:13.722163+00	\N	\N	\N	\N
42e0b4b3-f4aa-4120-a46a-faa48994f592	Downloaded	303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	Sneha Iyer	Sneha Iyer downloaded Code of Conduct 2026.pdf	2026-09-29 11:24:13.722163+00	\N	\N	\N	\N
50e258ef-28a2-4f96-bbd4-88d39d58004a	Downloaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Gaurav Joshi	Gaurav Joshi downloaded Resource Allocation SOP.pdf	2026-09-29 11:24:13.722163+00	\N	\N	\N	\N
ac6a31b8-0921-418d-af7e-3813bfa144e9	Downloaded	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Vikrant Malhotra	Vikrant Malhotra downloaded Resource Allocation SOP.pdf	2026-09-29 11:24:13.722163+00	\N	\N	\N	\N
cb1e15eb-d3df-48b0-8012-14bd4ca6238a	Viewed	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Admin User viewed Resource Allocation SOP.pdf	2026-10-15 11:46:20.213017+00	\N	00000000-0000-4000-8000-000000000004	\N	\N
\.


--
-- Data for Name: tbl_repository_departments; Type: TABLE DATA; Schema: repository; Owner: -
--

COPY repository.tbl_repository_departments ("RepositoryItemId", "DepartmentId") FROM stdin;
\.


--
-- Data for Name: tbl_repository_items; Type: TABLE DATA; Schema: repository; Owner: -
--

COPY repository.tbl_repository_items ("Id", "FileName", "Category", "Size", "LastUpdated", "UploadedBy", "FilePath", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	1048576	2026-08-06 11:24:13.719964+00	Ankit Verma	repository/imp/Code_of_Conduct_2026.pdf	2026-09-29 11:24:13.722163+00	\N	\N	\N	\N
706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	655360	2026-08-12 11:24:13.718814+00	Pooja Menon	repository/pms/Resource_Allocation_SOP.pdf	2026-09-29 11:24:13.722163+00	\N	\N	\N	\N
\.


--
-- Data for Name: log_employee_activity; Type: TABLE DATA; Schema: resource; Owner: -
--

COPY resource.log_employee_activity ("Id", "EmployeeId", "Action", "PerformedByEmail", "PerformedByName", "Details", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
3bd6edd0-1894-4b3e-af8b-0e71a59f6c49	940ec7cd-058d-4f8f-912f-08ae55bac01c	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Terminated, Reason: Career growth — UAT sample exit, Last Working Day: 2026-10-02)	2026-10-16 09:54:37.284411+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
8d7263ae-45e4-42fd-995b-0c2cd9102106	87fd3345-a756-44df-a3e7-5f21fa6e50d3	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Terminated, Reason: Career growth — UAT sample exit, Last Working Day: 2026-10-02)	2026-10-16 09:54:37.309719+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
5e8e5ef8-bfaf-4974-a608-3089eeef28aa	23bf310d-b789-4dcc-bb7e-576b373e72cf	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Terminated, Reason: Career growth — UAT sample exit, Last Working Day: 2026-10-02)	2026-10-16 09:54:37.319639+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
3a2236e4-f5a9-4f3b-ade4-c3b22bb52237	089e3bae-d509-46db-906f-3085e0438c9c	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Terminated, Reason: Career growth — UAT sample exit, Last Working Day: 2026-10-02)	2026-10-16 09:54:37.329732+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
288ebe5a-3d01-4e04-bbf7-caf72c1f4a63	b20f343b-e7fa-4310-9c43-ef10ca51ff6c	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Terminated, Reason: Career growth — UAT sample exit, Last Working Day: 2026-10-02)	2026-10-16 09:54:37.338979+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
768bcfa3-8740-4005-8306-fbf026b6dba4	ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resignation Under Review, Reason: Serving notice — UAT sample, Last Working Day: 2026-11-15)	2026-10-16 09:54:37.34871+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
1e48ea47-5b08-432b-9893-30d7bdadc95a	d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resignation Under Review, Reason: Serving notice — UAT sample, Last Working Day: 2026-11-15)	2026-10-16 09:54:37.363101+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a3ccc36b-53da-41ce-8f36-82ccc3b58c95	f30d1ce8-8a1a-483d-ace2-419cd8672ecc	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resignation Under Review, Reason: Serving notice — UAT sample, Last Working Day: 2026-11-15)	2026-10-16 09:54:37.37219+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
e16a2c96-e576-49c8-b161-56987da1f467	3398777f-d384-48a2-8076-9c4fb06162bb	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resignation Under Review, Reason: Serving notice — UAT sample, Last Working Day: 2026-11-15)	2026-10-16 09:54:37.381116+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
d3665e39-d7a5-443d-8d52-a6fa5dcc18ba	cef36bf2-c4fb-4040-b3ab-d033190ad3b4	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resignation Under Review, Reason: Serving notice — UAT sample, Last Working Day: 2026-11-15)	2026-10-16 09:54:37.389691+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
77a05a19-21cd-407f-8f00-c3fe80a2cd2d	78b71d74-d255-4ac0-a75f-ead11a61427a	Updated	admin@talakunchi.com	admin	Updated: Role, Experience, Bond Status, Billable Status, Project Type, Prior Total Experience (+2 more)	2026-10-17 07:58:43.623594+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
9d31f6b7-4ac8-4c5d-b601-4d9cc6c9fdc0	78b71d74-d255-4ac0-a75f-ead11a61427a	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-17 07:58:43.623594+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
1ad2b1b8-5f8a-447e-b0b3-05cd0833e538	30913859-c8e8-4851-852f-28be97c74bb1	Updated	admin@talakunchi.com	admin	Updated: Work Location, Experience, Bond Status, Location (Onsite), Billable Status, Project Type (+3 more)	2026-10-17 09:17:09.920137+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
2791d20a-3edc-48ab-8826-bbfbd4dab1b9	30913859-c8e8-4851-852f-28be97c74bb1	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-17 09:17:09.920137+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
8cedb756-12c7-4bcc-8e33-442228e2c4a6	30913859-c8e8-4851-852f-28be97c74bb1	WorkLocationChanged	admin@talakunchi.com	admin	Suvidha Square, Andheri -> Onsite	2026-10-17 09:17:09.920137+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
06a97cb8-55da-470f-a956-768190e2d3fe	049ac489-bbd3-4153-b933-aec7b7baec89	Updated	admin@talakunchi.com	admin	Updated: Business Unit, Category, Probation Status, Experience, Billable Status, Project Type (+5 more)	2026-10-17 07:58:56.05381+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
fca286f3-ac92-4298-9d3e-d9af837869f9	049ac489-bbd3-4153-b933-aec7b7baec89	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-17 07:58:56.05381+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
1ed4d467-30c0-42a1-83a2-2d982b3133ac	ffcdc44f-996b-4ef6-90e6-db858823a4c4	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-17 12:23:08.321477+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
4e92da1c-38ff-44ee-abce-865b0570ea9c	ffcdc44f-996b-4ef6-90e6-db858823a4c4	Updated	admin@talakunchi.com	admin	Updated: Work Email, Role, Category, Experience, Bond Status, Billable Status (+5 more)	2026-10-17 12:23:08.321477+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
39b72415-1cb5-477f-8d06-25c769a7eeff	d2010072-d612-48ab-9a8a-f137b87e6034	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-17 08:01:24.915917+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a7a30ee6-c980-428d-a50d-30533855ffe4	d2010072-d612-48ab-9a8a-f137b87e6034	Updated	admin@talakunchi.com	admin	Updated: Address, Experience, Bond Status, Billable Status, Project Type, Prior Total Experience (+2 more)	2026-10-17 08:01:24.915917+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
43fe504d-9afd-4847-8035-38a83874fd09	d2010072-d612-48ab-9a8a-f137b87e6034	WorkLocationChanged	admin@talakunchi.com	admin	Suvidha Square, Andheri -> Onsite	2026-10-17 08:09:49.32432+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
53efad6d-c625-4820-8797-35171a08678b	d2010072-d612-48ab-9a8a-f137b87e6034	Updated	admin@talakunchi.com	admin	Updated: Work Location	2026-10-17 08:09:49.32432+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
71d59fa3-7480-4d12-9abc-02a9d84f6acc	049ac489-bbd3-4153-b933-aec7b7baec89	Created	admin@talakunchi.com	admin	Profile created for Admin User (TK-0004)	2026-10-16 09:25:32.5313+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d10262fc-0a6d-4cfc-be7e-9009c2479f30	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	Created	admin@talakunchi.com	admin	Profile created for Vihaan Pillai (TK-0001)	2026-10-16 09:25:32.638283+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
8450b7e8-65be-4d39-8abe-bb6f475f1c6c	d17be428-1602-4e09-a164-c3c2666fad73	Created	admin@talakunchi.com	admin	Profile created for Neha Pillai (TK-0002)	2026-10-16 09:25:32.653042+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
664fdca1-089c-4fdf-bc61-1928a633c7ae	f01f614a-af85-4225-a3b4-3c463fb97bdf	Created	admin@talakunchi.com	admin	Profile created for Dev Reddy (TK-0003)	2026-10-16 09:25:32.663899+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
fa2a4b2b-d938-4e77-86f2-90d981f55f5a	d502bbdd-5186-490e-8f0a-5489d2737c6f	Created	admin@talakunchi.com	admin	Profile created for Nikhil Malhotra (TKI-0001)	2026-10-16 09:25:32.674545+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
2f9c0071-ac1b-4523-a58e-d70b8111e52d	849d2fb1-a4e4-4eb2-947b-f97057e4954b	Created	admin@talakunchi.com	admin	Profile created for Dev Bose (TK-0005)	2026-10-16 09:25:32.685347+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
c651e2e4-e33f-44c1-8e82-57ce4aa15eed	d2010072-d612-48ab-9a8a-f137b87e6034	Created	admin@talakunchi.com	admin	Profile created for Amit Deshmukh (TK-0006)	2026-10-16 09:25:32.700183+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
c8ddf0de-f13a-4262-b8f3-0d2f8d385343	f39b20bb-8963-4917-aed5-0f1d86f0cbc3	Created	admin@talakunchi.com	admin	Profile created for Aarav Roy (TK-0007)	2026-10-16 09:25:32.711141+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
abeb50ed-53b0-4fd2-a426-cf7f3f9596b8	7e3f1c8d-340c-47d7-b63d-fb047a9106aa	Created	admin@talakunchi.com	admin	Profile created for Aarav Mathur (TKI-0002)	2026-10-16 09:25:32.725004+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d772aa4f-7780-4f26-8cd1-65f6f9227ec2	d94878fd-4650-46bc-b84c-753c841e7404	Created	admin@talakunchi.com	admin	Profile created for Nikhil Saxena (TK-0008)	2026-10-16 09:25:32.737106+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
9a858882-12f3-43e0-aedf-5b84512bc6d1	13428d48-c81e-4720-adba-f8490f27e535	Created	admin@talakunchi.com	admin	Profile created for Vihaan Saxena (TK-0009)	2026-10-16 09:25:32.749692+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
c530fb46-acfc-4328-b0f2-1a5f3e668f2d	30913859-c8e8-4851-852f-28be97c74bb1	Created	admin@talakunchi.com	admin	Profile created for Sana Pillai (TK-0010)	2026-10-16 09:25:32.761239+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
83008999-f485-473c-8197-f31df58c038c	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Created	admin@talakunchi.com	admin	Profile created for Aditya Roy (TK-0011)	2026-10-16 09:25:32.772002+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
a59dbdd6-ee2c-4200-b54d-b4aa0cb65205	62e81e6b-7247-4c3f-a8b8-db21e613d02a	Created	admin@talakunchi.com	admin	Profile created for Aarav Bose (TKI-0003)	2026-10-16 09:25:32.784368+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
cf68a0b3-9883-4879-b625-58ce51d63ca5	9d9bfa3a-8603-4de4-8eb7-76c3935e3014	Created	admin@talakunchi.com	admin	Profile created for Advait Singh (TK-0012)	2026-10-16 09:25:32.796331+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
bc6e7b61-0498-4f05-8e9d-9c6a35331daf	583e812b-e929-4e7c-9d76-33d3fc25cd7d	Created	admin@talakunchi.com	admin	Profile created for Tanvi Gaikwad (TK-0013)	2026-10-16 09:25:32.808053+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
9dc24284-8527-4571-b4a2-4ec9c335627c	70e01a7d-fd0b-4e2a-b086-d059423ca380	Created	admin@talakunchi.com	admin	Profile created for Vihaan Kadam (TK-0014)	2026-10-16 09:25:32.8185+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
63246349-fdf1-418c-9d51-9faaef3a7c4f	159fb3d0-937c-4f81-ad37-aa1b4f023264	Created	admin@talakunchi.com	admin	Profile created for Rajesh Sharma (TK-0015)	2026-10-16 09:25:32.829223+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
72e645a9-79ba-4b64-97a9-d93a82a4f8e1	42583b6b-008c-45f6-b258-b08495712c7c	Created	admin@talakunchi.com	admin	Profile created for Harsh Wardhan (TK-0016)	2026-10-16 09:25:32.839978+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
89946d2a-48ee-4649-9fc6-1df90ee61013	a73329ac-636f-475e-b566-321a5686fd66	Created	admin@talakunchi.com	admin	Profile created for Pallavi Sawant (TK-0017)	2026-10-16 09:25:32.850765+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
1ad01e82-0a72-4d5f-9c34-49b87870d9f9	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	Created	admin@talakunchi.com	admin	Profile created for Harsh Pandey (TK-0018)	2026-10-16 09:25:32.861622+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
72110b1d-4271-465f-81d1-10cd4084f5e8	2b245a46-a64c-440b-861d-24f712bd626e	Created	admin@talakunchi.com	admin	Profile created for Kavya Mathur (TKI-0004)	2026-10-16 09:25:32.872825+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
5141e69d-6938-4593-ac11-c9ecc02338ea	696f99d7-2380-443c-b90d-0e065642e1d4	Created	admin@talakunchi.com	admin	Profile created for Priya Mishra (TK-0019)	2026-10-16 09:25:32.883529+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
269b42f9-c5dd-412c-ab0c-a0da8b7f6bf1	8e0616db-48af-4b73-807f-6e250dba2072	Created	admin@talakunchi.com	admin	Profile created for Anita Pandey (TK-0020)	2026-10-16 09:25:32.893527+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d2660500-1fbb-470f-b466-47c9b8d3eeff	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Created	admin@talakunchi.com	admin	Profile created for Karan Wardhan (TK-0021)	2026-10-16 09:25:32.902977+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
775db417-e10b-4e44-93ff-22bf4ac8b5cc	eba0b052-26bb-4216-ab6e-dff23c63bc57	Created	admin@talakunchi.com	admin	Profile created for Rahul Mishra (TK-0022)	2026-10-16 09:25:32.913225+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
a7a118d2-bf8b-4a1d-b6ab-c7d15b8aa271	9312226e-c7f8-4187-887e-67e2124098cd	Created	admin@talakunchi.com	admin	Profile created for Kunal Rao (TKI-0005)	2026-10-16 09:25:32.923653+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
467beadf-663a-42a0-b194-c57c4ea2f7e4	9f646393-8fea-4b38-9f35-d88a6ab6787e	Created	admin@talakunchi.com	admin	Profile created for Aarav Rao (TK-0023)	2026-10-16 09:25:32.933058+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
dd3b0d89-5321-459b-8592-436dc1c4c8c1	033446c7-c133-4395-bdaa-69b5f227a7a8	Created	admin@talakunchi.com	admin	Profile created for Atharv Reddy (TK-0024)	2026-10-16 09:25:32.942887+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
3f75ea93-1610-413a-b5e9-b8a74cea54f9	2285ceea-ffbf-4bf4-bb2e-bd9e0427beeb	Created	admin@talakunchi.com	admin	Profile created for Vihaan Mathur (TK-0025)	2026-10-16 09:25:32.952363+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
82718bb2-e582-4b68-8df6-afc234672404	be9f417e-d40a-4c66-91e6-e7fde84b46d5	Created	admin@talakunchi.com	admin	Profile created for Krishna Pandey (TK-0026)	2026-10-16 09:25:32.961707+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
4b070b4c-e26b-43e8-9a6a-d5b731019ade	7d2b2c7a-254e-4605-9f79-3f42ac7f9735	Created	admin@talakunchi.com	admin	Profile created for Reyansh Chopra (TK-0027)	2026-10-16 09:25:32.97114+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
eb7f160e-48e5-43d8-868e-befccfbc8ebe	777390a6-91b9-4d9e-806c-16e046568501	Created	admin@talakunchi.com	admin	Profile created for Krishna Joshi (TK-0028)	2026-10-16 09:25:32.980525+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
6b448a66-f825-46e0-acaf-d0bde1861db4	13b14e34-f865-4c83-a6c0-3fdf7d196c1c	Created	admin@talakunchi.com	admin	Profile created for Reyansh Sawant (TK-0029)	2026-10-16 09:25:32.989627+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
2112569e-def2-4dad-bee1-394b796dd83a	776f2cf7-c4cc-4299-b38f-afbcaff7703e	Created	admin@talakunchi.com	admin	Profile created for Omkar Reddy (TK-0030)	2026-10-16 09:25:32.998861+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
2459cf05-d3fa-4aa9-82ba-83f309cec319	804c8187-6f28-411f-8fa5-cc9baceba3e7	Created	admin@talakunchi.com	admin	Profile created for Arjun Joshi (TK-0031)	2026-10-16 09:25:33.008037+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
2f0de41c-f8f7-4161-bac0-76652c707800	f19ea8a8-4d2f-48f9-832e-311f80e49f11	Created	admin@talakunchi.com	admin	Profile created for Ananya Joshi (TKI-0006)	2026-10-16 09:25:33.017849+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
fa675fdf-6f2c-47ab-8b1a-c07688be56f8	d9fd54d6-b11b-4969-a25d-8b8e3fcca417	Created	admin@talakunchi.com	admin	Profile created for Amit Sawant (TK-0032)	2026-10-16 09:25:33.029454+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
a7b9dd47-c386-42af-bac9-c97e74448f9b	405610b0-c3bd-4725-a409-5f6dbffeacb4	Created	admin@talakunchi.com	admin	Profile created for Arjun Wardhan (TKI-0007)	2026-10-16 09:25:33.039742+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
c1a25993-174d-4954-8c03-74eedba60ab3	9eb64ade-203d-4e4a-aaed-8eaab7d3017d	Created	admin@talakunchi.com	admin	Profile created for Yash Wardhan (TK-0033)	2026-10-16 09:25:33.049223+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
85d7c388-3051-4d86-9059-b24088f31da1	86862bf8-c075-44ef-9f3e-f65d2cc1bb56	Created	admin@talakunchi.com	admin	Profile created for Suresh Desai (TK-0034)	2026-10-16 09:25:33.058812+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
7e1b6cad-2e30-4b5f-88d5-582e158db855	78b71d74-d255-4ac0-a75f-ead11a61427a	Created	admin@talakunchi.com	admin	Profile created for Aarav Desai (TK-0035)	2026-10-16 09:25:33.067911+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
0d98aed4-5406-41d9-8c0a-04e8ca157fcb	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Created	admin@talakunchi.com	admin	Profile created for Amit Wardhan (TK-0036)	2026-10-16 09:25:33.077105+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
67a2a763-375c-42a1-a929-1e30becc3654	e131815f-331f-46d7-81f8-5d2bed793630	Created	admin@talakunchi.com	admin	Profile created for Ira Bose (TK-0037)	2026-10-16 09:25:33.086379+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
4e75b566-4565-4cf8-baec-ba1a506b89ff	51df4d23-9202-43b7-9e29-4a14a838a242	Created	admin@talakunchi.com	admin	Profile created for Vihaan Gaikwad (TK-0038)	2026-10-16 09:25:33.095908+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
69006480-bc43-4164-9edc-fd16e34306c9	02814af4-08b4-42cc-92e1-ad0bba687378	Created	admin@talakunchi.com	admin	Profile created for Pooja Bose (TK-0039)	2026-10-16 09:25:33.105674+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
ed58d865-af49-416d-aa73-1ba564e18cfc	0a213b8b-1836-4660-9116-536fc9436639	Created	admin@talakunchi.com	admin	Profile created for Krishna Saxena (TK-0040)	2026-10-16 09:25:33.115166+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
fc2319a9-158e-4c18-90e3-f6aee767cc4c	9ec115c7-5377-4f9d-b46a-2a3c97bea4de	Created	admin@talakunchi.com	admin	Profile created for Aarav Reddy (TKI-0008)	2026-10-16 09:25:33.125013+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d0bde471-6cc8-4d69-913f-65ddcde45a9f	c5e35b7a-af12-4fd6-96af-e62225e715c6	Created	admin@talakunchi.com	admin	Profile created for Karan Mehra (TK-0041)	2026-10-16 09:25:33.134445+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
50cfb01f-2422-42eb-baa1-24f83f3d1f2c	ee7b555a-4400-4c03-8fe5-60fd908c0e58	Created	admin@talakunchi.com	admin	Profile created for Arjun Mathur (TK-0042)	2026-10-16 09:25:33.143745+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
e12d78ef-85c6-4b93-b28e-d51b9fa56dfa	218f30c7-87bd-4410-99fc-4d10da3e8014	Created	admin@talakunchi.com	admin	Profile created for Yash Sharma (TK-0043)	2026-10-16 09:25:33.153135+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
8f3afdcc-4c6c-4dd3-914a-c7c0cf159f17	5bf6d5c7-4358-49f1-bb6b-9d0b1b38d4ad	Created	admin@talakunchi.com	admin	Profile created for Priya Mathur (TKI-0009)	2026-10-16 09:25:33.163695+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
63bb6287-fbe3-4b71-b95a-8eff6183442d	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Created	admin@talakunchi.com	admin	Profile created for Vihaan Bose (TK-0044)	2026-10-16 09:25:33.173185+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
4a3bef5a-3ae9-4a7d-8ae3-271328e994a6	d01c0ef5-731e-42de-b02a-7c996c545f15	Created	admin@talakunchi.com	admin	Profile created for Vivaan Mathur (TK-0045)	2026-10-16 09:25:33.182891+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
ca61d52f-b773-4562-837b-84d4284db346	d73eac4c-d537-4d31-8e35-b55f8aff3e87	Created	admin@talakunchi.com	admin	Profile created for Arjun Pillai (TK-0046)	2026-10-16 09:25:33.192404+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
e21a7c1a-870c-49c2-9c85-33c3cd564aa0	f90e007c-90d9-440e-8f0a-a85395e49abe	Created	admin@talakunchi.com	admin	Profile created for Vikram Roy (TK-0047)	2026-10-16 09:25:33.202053+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
75450e37-225b-4f8c-8e68-bfc8d6e631c4	b9c0b8fc-4c96-42fb-8669-d68097cf5392	Created	admin@talakunchi.com	admin	Profile created for Aditi Roy (TK-0048)	2026-10-16 09:25:33.212417+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
67eff9a1-95ce-4fde-b083-678eed5eb23e	238c3cb7-75cf-4478-a48e-fe47465d20b6	Created	admin@talakunchi.com	admin	Profile created for Ishita Patel (TK-0049)	2026-10-16 09:25:33.222214+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
cb74ec79-0b21-4cd9-965a-add3b0378225	3a209908-397f-4c90-abf6-9fe52ab98b34	Created	admin@talakunchi.com	admin	Profile created for Vihaan Wardhan (TK-0050)	2026-10-16 09:25:33.231853+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
249015ee-4db4-4fb1-8323-fe584ad4fa94	31057f6b-b1e5-46e3-a071-b6639b93a15c	Created	admin@talakunchi.com	admin	Profile created for Krishna Bose (TK-0051)	2026-10-16 09:25:33.241361+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
5a9a1b37-9d9d-4340-ac57-295e8fbe2add	d29c4919-9e2d-46c1-a78f-ffd2d4d32365	Created	admin@talakunchi.com	admin	Profile created for Anita Iyer (TK-0052)	2026-10-16 09:25:33.251595+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
8750ca64-8fab-4700-97d1-1a024e753d1c	f8b1a855-954d-4f8b-aad7-be5502a7413a	Created	admin@talakunchi.com	admin	Profile created for Sneha Choudhary (TK-0053)	2026-10-16 09:25:33.261331+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
220fee5d-4de0-4acb-9e74-ed9cc72fc9f1	9b7f4410-6577-4ab4-9363-e75b9d4208e9	Created	admin@talakunchi.com	admin	Profile created for Sana Rao (TK-0054)	2026-10-16 09:25:33.270926+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
8d3d2f47-7118-4a24-8bc5-42e63cc6c2d1	ffcdc44f-996b-4ef6-90e6-db858823a4c4	Created	admin@talakunchi.com	admin	Profile created for Aditya Menon (TK-0055)	2026-10-16 09:25:33.281124+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
5b38c4d1-cac2-4ac8-bac8-7623258dc6b8	315ae0c9-ecdf-48ba-a662-f93c21ef31d2	Created	admin@talakunchi.com	admin	Profile created for Varun Pandey (TK-0056)	2026-10-16 09:25:33.291131+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
dabe8b8f-6520-4ce8-b1ef-ae11c78d1df4	df8f375a-d0b0-40c0-8ada-264fc2275f4f	Created	admin@talakunchi.com	admin	Profile created for Advait Gupta (TK-0057)	2026-10-16 09:25:33.301008+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
6422be78-7ac5-4406-bf02-32f1451dabec	78c932da-077a-4104-919c-386de88ed062	Created	admin@talakunchi.com	admin	Profile created for Meera Joshi (TK-0058)	2026-10-16 09:25:33.311256+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
e13fb692-6366-45ba-b1cc-ad989b598628	74601727-6182-498f-ac57-4c02b9e56ca0	Created	admin@talakunchi.com	admin	Profile created for Kunal Iyer (TK-0059)	2026-10-16 09:25:33.321038+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
3649664c-98c4-4f1a-840b-cf5c27879b91	0a46bda6-6481-4bbe-8689-18fe959fa98a	Created	admin@talakunchi.com	admin	Profile created for Trisha Pillai (TK-0060)	2026-10-16 09:25:33.331681+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
83ecd17e-81c4-42d1-ba60-e78f72326b44	bbe8dd34-5945-4f0f-ab99-2cb2f7c99c95	Created	admin@talakunchi.com	admin	Profile created for Aditya Pillai (TK-0061)	2026-10-16 09:25:33.341802+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
9c55f9b5-c7d0-4a67-8fb1-c32b7078804f	46e3d71d-ea02-474f-b668-f836d91e059d	Created	admin@talakunchi.com	admin	Profile created for Siddharth Iyer (TK-0062)	2026-10-16 09:25:33.352233+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
ef48902c-fe27-4d1c-b484-3d2a127553f5	e93a25e9-5347-49e1-b901-88271fdbdcf5	Created	admin@talakunchi.com	admin	Profile created for Kavya Roy (TK-0063)	2026-10-16 09:25:33.362553+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
0d0b6377-601f-47f7-a3a3-86d54cb1c21a	4d8e2104-d723-45a0-856f-594f80efd0f6	Created	admin@talakunchi.com	admin	Profile created for Amit Pillai (TK-0064)	2026-10-16 09:25:33.372343+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
b8f4b70f-5f6d-4407-b9d3-3cf60ef09d60	fb184814-7151-428d-87c3-f83814676aa5	Created	admin@talakunchi.com	admin	Profile created for Reyansh Mathur (TK-0065)	2026-10-16 09:25:33.382965+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
f78b6714-e775-443b-bcb4-34f109619848	6a1ac61a-89d6-4951-8246-621d4e1b071f	Created	admin@talakunchi.com	admin	Profile created for Nikhil Joshi (TK-0066)	2026-10-16 09:25:33.393299+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
33f9ffe3-f23a-4918-b524-afe5bb4f254a	26fd3209-693a-49d1-9224-8f7e2f3a1c58	Created	admin@talakunchi.com	admin	Profile created for Ishaan Desai (TK-0067)	2026-10-16 09:25:33.40328+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
2e17563f-975e-422f-87dc-408e65d579fe	5f4b7ab9-bbfe-4196-9e6c-47f73efe7462	Created	admin@talakunchi.com	admin	Profile created for Atharv Malhotra (TK-0068)	2026-10-16 09:25:33.413757+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
7cdd4781-9c22-46e7-b6bb-e81ebc621ad0	900ed2a0-d8b3-439f-af86-7383cdebcd05	Created	admin@talakunchi.com	admin	Profile created for Ishaan Pansare (TK-0069)	2026-10-16 09:25:33.424304+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
8a1705bb-ef03-48f3-97d7-81bf87216bf1	204776c8-efeb-480f-980b-a3f70be97f91	Created	admin@talakunchi.com	admin	Profile created for Divya Deshmukh (TK-0070)	2026-10-16 09:25:33.434651+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
6f5c08d4-2039-4ef6-82a4-8841acff5317	41708635-a60e-4fbd-a76b-91c0c23d18be	Created	admin@talakunchi.com	admin	Profile created for Advait Gaikwad (TK-0071)	2026-10-16 09:25:33.44587+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
e5ec647d-30d2-4d14-80d1-7208d5e75783	e09daabd-8da2-4dc9-89b4-03f4b79583de	Created	admin@talakunchi.com	admin	Profile created for Amit Gaikwad (TK-0072)	2026-10-16 09:25:33.457403+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
95872fd3-de7e-4c1b-8a00-2d066d9e31b7	faa36d59-2e24-4a0e-851d-42900c200d3b	Created	admin@talakunchi.com	admin	Profile created for Rohan Deshpande (TK-0073)	2026-10-16 09:25:33.467492+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
308c9a16-9ec9-45fd-8d65-48e3ed7ffdd0	5e82125c-9ff8-4a97-a11b-65da79677d3c	Created	admin@talakunchi.com	admin	Profile created for Reyansh Wardhan (TK-0074)	2026-10-16 09:25:33.479017+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
85e937b3-66fb-4987-8c2a-cbf1afd24039	ca561f47-f73a-4401-8c6f-a1c776d88534	Created	admin@talakunchi.com	admin	Profile created for Vihaan Iyer (TK-0075)	2026-10-16 09:25:33.489088+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
5a4e295f-4a34-408f-9cba-2b228fb9f3aa	51015348-f872-4e18-b806-e44017e10e4b	Created	admin@talakunchi.com	admin	Profile created for Dev Roy (TK-0076)	2026-10-16 09:25:33.499936+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
09860acd-8529-4eae-9341-4888f9d0be63	8e139039-c490-436d-9af4-431d26334b34	Created	admin@talakunchi.com	admin	Profile created for Simran Deshmukh (TKI-0010)	2026-10-16 09:25:33.51122+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
f0178c62-d0ca-411d-9c1d-67a0ea3b2152	bfb55863-c987-497b-9a1b-9a7bc56a9509	Created	admin@talakunchi.com	admin	Profile created for Nidhi Bose (TK-0077)	2026-10-16 09:25:33.521274+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d7c74123-7e43-4730-926c-693ee3d93892	dd200677-337b-440b-afcb-3a661406f98b	Created	admin@talakunchi.com	admin	Profile created for Reyansh Patel (TK-0078)	2026-10-16 09:25:33.533678+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
3cf8c8a9-0d2f-4bfc-855e-d8ee9fcf92a5	8f3346d4-6f76-4575-af6d-a69527694680	Created	admin@talakunchi.com	admin	Profile created for Deepak Singh (TK-0079)	2026-10-16 09:25:33.544019+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
30a590c9-3548-4944-845f-93a036174156	33e9644b-a618-47ed-b272-c078e19b36ef	Created	admin@talakunchi.com	admin	Profile created for Varun Gaikwad (TK-0080)	2026-10-16 09:25:33.555664+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d2b2338c-ea02-4e8e-b3e1-044c8f0deb03	6b4e0847-6c40-471e-89ec-c5b63bb828f0	Created	admin@talakunchi.com	admin	Profile created for Arjun Menon (TK-0081)	2026-10-16 09:25:33.565857+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
f105ee48-a7c8-4480-bcb7-80ceeb9d5cc8	450f16b6-e35c-4564-969d-6bf6ceec7ff3	Created	admin@talakunchi.com	admin	Profile created for Kabir Sawant (TK-0082)	2026-10-16 09:25:33.577472+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
078f55cc-43a8-4be8-ac4e-467f5c22d194	31e49978-ac22-44bb-a535-11d20d8aeea3	Created	admin@talakunchi.com	admin	Profile created for Rahul Pillai (TK-0083)	2026-10-16 09:25:33.58765+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
9421dd29-eeb4-48df-96a4-6d71eed66da7	246e0bb0-8a3b-4524-9d7b-3ac6d4ca7d8d	Created	admin@talakunchi.com	admin	Profile created for Manish Malhotra (TK-0084)	2026-10-16 09:25:33.598591+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
a9f7e650-0af3-4054-be87-8585fecc098b	6d26e662-1e9f-4df8-a353-6be5ce9e5261	Created	admin@talakunchi.com	admin	Profile created for Lakshmi Kadam (TK-0085)	2026-10-16 09:25:33.609033+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
932081f3-f459-434d-84d4-ffe69c857528	6b1f9737-c1f7-4201-8cd2-9b5e6274ebc8	Created	admin@talakunchi.com	admin	Profile created for Vihaan Joshi (TK-0086)	2026-10-16 09:25:33.62058+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
242be7c5-be7f-4ce7-a9db-4994f5fd5e21	3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	Created	admin@talakunchi.com	admin	Profile created for Harsh Gupta (TK-0087)	2026-10-16 09:25:33.631268+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
109a4662-cc17-496f-a403-b3dadac6f358	1fa56f20-56ce-4461-ac66-c7d7b34f16d6	Created	admin@talakunchi.com	admin	Profile created for Siddharth Deshpande (TK-0088)	2026-10-16 09:25:33.641784+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
310f77d5-2cd9-4beb-827c-e813e2876448	cc295432-e771-4d6f-9cc3-079cc5d9b576	Created	admin@talakunchi.com	admin	Profile created for Alok Deshpande (TK-0089)	2026-10-16 09:25:33.653768+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
473be744-ead3-44f0-9a55-6db2f2da361b	5ff0346b-75b8-4c62-afc7-afeb35b17a8e	Created	admin@talakunchi.com	admin	Profile created for Siddharth Bose (TK-0090)	2026-10-16 09:25:33.664247+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
79805f6a-3db2-4cc5-ac3d-8316593b6884	9c4cf836-745e-4cf9-9a22-933d5e2638c3	Created	admin@talakunchi.com	admin	Profile created for Arjun Sawant (TK-0091)	2026-10-16 09:25:33.674919+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
f8887ba9-2369-4c39-a305-62f4d2703d78	ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	Created	admin@talakunchi.com	admin	Profile created for Harsh Joshi (TK-0092)	2026-10-16 09:25:33.685479+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
761940d8-97b4-4d4c-a506-c910b6ba07dc	d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	Created	admin@talakunchi.com	admin	Profile created for Aarav Patel (TK-0093)	2026-10-16 09:25:33.696298+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
9b6892c3-66a5-4aec-ac1e-561a91c802ae	f30d1ce8-8a1a-483d-ace2-419cd8672ecc	Created	admin@talakunchi.com	admin	Profile created for Manish Bose (TK-0094)	2026-10-16 09:25:33.707024+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
42f4385d-5cba-40a9-9b49-e9b5490a3056	3398777f-d384-48a2-8076-9c4fb06162bb	Created	admin@talakunchi.com	admin	Profile created for Karan Joshi (TK-0095)	2026-10-16 09:25:33.717492+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
1e319a15-6a3f-4235-b631-137e278c21b9	cef36bf2-c4fb-4040-b3ab-d033190ad3b4	Created	admin@talakunchi.com	admin	Profile created for Vikram Joshi (TK-0096)	2026-10-16 09:25:33.728372+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
33a70045-947b-443e-87ae-d9da7d45bd70	940ec7cd-058d-4f8f-912f-08ae55bac01c	Created	admin@talakunchi.com	admin	Profile created for Manish Mathur (TK-0097)	2026-10-16 09:25:33.739442+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
eccf94e4-8620-48fd-82b4-3fcac4fe0525	87fd3345-a756-44df-a3e7-5f21fa6e50d3	Created	admin@talakunchi.com	admin	Profile created for Aisha Mathur (TK-0098)	2026-10-16 09:25:33.749981+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
26eced82-0caf-4c17-a194-f98e51c31420	23bf310d-b789-4dcc-bb7e-576b373e72cf	Created	admin@talakunchi.com	admin	Profile created for Karan Mehta (TK-0099)	2026-10-16 09:25:33.772094+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
426120cc-0254-4ee1-85a7-693e59122508	089e3bae-d509-46db-906f-3085e0438c9c	Created	admin@talakunchi.com	admin	Profile created for Ira Reddy (TK-0100)	2026-10-16 09:25:33.801681+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
98c9e9ca-a8dd-4757-98dc-f3ea3c0c3e5d	b20f343b-e7fa-4310-9c43-ef10ca51ff6c	Created	admin@talakunchi.com	admin	Profile created for Neha Choudhary (TK-0101)	2026-10-16 09:25:33.813398+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
4b848f2c-d6ac-4af9-9aed-3913accaf591	d2010072-d612-48ab-9a8a-f137b87e6034	Updated	admin@talakunchi.com	admin	Updated: Location (Onsite)	2026-10-17 08:10:04.987833+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
10cc3172-94ab-45ea-adf6-667aee1508ee	f01f614a-af85-4225-a3b4-3c463fb97bdf	Updated	admin@talakunchi.com	admin	Updated: Emergency Contact Relation, Role, Experience, Bond Status, Sub Department, Billable Status (+4 more)	2026-10-17 20:45:12.944714+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
346863c7-8098-4c20-9d36-3127bc714a58	f01f614a-af85-4225-a3b4-3c463fb97bdf	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-17 20:45:12.944714+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
7192d3b3-36ed-458d-9409-19ca74c28e7f	049ac489-bbd3-4153-b933-aec7b7baec89	Updated	admin@talakunchi.com	admin	Profile details updated	2026-10-18 04:00:19.227531+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
ed93fa77-0969-4f96-ad43-1abeaf523c77	049ac489-bbd3-4153-b933-aec7b7baec89	Updated	admin@talakunchi.com	admin	Profile details updated	2026-10-18 04:02:03.390904+00	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
0e4a3463-aa2f-465d-b509-9b7d9d1ad8f8	13428d48-c81e-4720-adba-f8490f27e535	Updated	admin@talakunchi.com	admin	Updated: Experience, Bond Status, Billable Status, Project Type, Prior Total Experience, Prior Relevant Experience (+1 more)	2026-10-18 04:09:16.798473+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
685db74e-0574-493d-bf71-aa41cbf5b5a1	13428d48-c81e-4720-adba-f8490f27e535	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-18 04:09:16.798473+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
9a5a46f6-217e-4043-b81c-a4158732987a	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-18 05:21:26.379919+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a490d2a3-0ca2-4003-b551-cc2ff30b751d	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	Updated	admin@talakunchi.com	admin	Updated: Role, Joining Date, Experience, Sub Department, Billable Status, Project Type (+3 more)	2026-10-18 05:21:26.379919+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
1ad173fd-86c9-48c0-b973-ac1c2345a92d	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	Updated	admin@talakunchi.com	admin	Updated: Role, Joining Date, Bond Expiry Date	2026-10-18 05:22:07.272056+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
2873ae21-eafc-4e90-99e5-f09e6eee5b70	d94878fd-4650-46bc-b84c-753c841e7404	Updated	admin@talakunchi.com	admin	Updated: Department, Designation, Role, Experience, Bond Status, Sub Department (+5 more)	2026-10-18 10:37:32.945929+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
38b25f9e-fe0b-42db-85dc-35d9eb58b80f	d94878fd-4650-46bc-b84c-753c841e7404	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-18 10:37:32.945929+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
811e98a0-eef8-492b-a5f3-1dd5ae4741f0	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	Updated	admin@talakunchi.com	admin	Updated: Department, Designation, Role, Sub Department	2026-10-22 07:09:19.938399+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a28816a1-19ca-4eaa-91ad-84b42f545649	ffcdc44f-996b-4ef6-90e6-db858823a4c4	Updated	admin@talakunchi.com	admin	Updated: Work Location, Location (Onsite)	2026-10-22 07:41:45.969197+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
d19104e9-a1a4-4383-a1ce-de29e8ed5d42	ffcdc44f-996b-4ef6-90e6-db858823a4c4	WorkLocationChanged	admin@talakunchi.com	admin	Suvidha Square, Andheri -> Onsite	2026-10-22 07:41:45.969197+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: tbl_employees; Type: TABLE DATA; Schema: resource; Owner: -
--

COPY resource.tbl_employees ("Id", "EmployeeCode", "FirstName", "LastName", "WorkEmail", "PersonalEmail", "Phone", "AltPhone", "Gender", "DateOfBirth", "Address", "EmergencyContact", "MaritalStatus", "Nationality", "DepartmentId", "DesignationId", "Role", "ReportingManagerId", "BusinessUnit", "WorkLocation", "OfficeBranch", "Category", "Team", "JoiningDate", "Status", "ConfirmationStatus", "ProbationStatus", "Experience", "PreviousCompany", "EmploymentType", "ContractType", "BondStatus", "NoticePeriod", "AssetId", "ExitType", "ExitReason", "Education", "Skills", "Certifications", "Languages", "KpiScore", "QuarterlyKpi", "AnnualRating", "GoalCompletion", "Attendance", "ReportingEfficiency", "PromotionReadiness", "ManagerFeedback", "Pan", "BankAccount", "SalaryBand", "PfUan", "TaxRegime", "ComplianceStatus", "UserId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "NationalityId", "ProbationPeriod", "SalaryBandId", "Aadhaar", "EmergencyContactName", "EmployeeStatusId", "BondDelivered", "BondDurationMonths", "BondExpiryDate", "GradDegree", "GradYear", "PostGradDegree", "PostGradYear", "ExpType", "PriorTotalExp", "PriorRelevantExp", "EmergencyContactRelation", "PmoDepartment", "SubDepartment", "BillableStatus", "ClientLocation", "ProjectType", "ProjectAllocated", "ClientEngManagerMapping", "ProjectSite", "EngagementManagerEmployeeId", "ProjectManagerId", "SubDepartmentId") FROM stdin;
4aba0077-4d88-4e0c-8d18-9152eea3fbf9	TK-0001	Vihaan	Pillai	vihaan.pillai.tk-0001@talakunchi.com	\N	9820010001	\N	\N	\N	Andheri (Western Line)	9811000017	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	b3309eea-7374-4a8d-ac13-481b2a7fd492	PMO	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2026-10-16	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.636311+00	2026-10-22 07:09:19.878078+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	\N	\N	\N	Nikhil Saxena	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 Years	2 Years	Mother	\N	PMO (Project Management Office)	Billable	\N	Long Term	\N	\N	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd
940ec7cd-058d-4f8f-912f-08ae55bac01c	TK-0097	Manish	Mathur	manish.mathur.tk-0097@talakunchi.com	\N	9820010106	\N	\N	\N	Andheri (Western Line)	9811001802	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-04-09	Terminated	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	Yes	\N	Resign	Better opportunity	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.736486+00	2026-10-16 09:54:37.284411+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-16 09:54:37.284411+00	\N	\N	\N	\N	Advait Deshmukh	a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	\N
0a213b8b-1836-4660-9116-536fc9436639	TK-0040	Krishna	Saxena	krishna.saxena.tk-0040@talakunchi.com	\N	9820010046	\N	\N	\N	Andheri (Western Line)	9811000782	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	7c2380da-3ee6-46ad-93d6-a79ce3027f29	Consulting-Team member	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-09-06	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.113491+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
0a46bda6-6481-4bbe-8689-18fe959fa98a	TK-0060	Trisha	Pillai	trisha.pillai.tk-0060@talakunchi.com	\N	9820010068	\N	\N	\N	Andheri (Western Line)	9811001156	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e228c999-bf54-48b4-a373-d2bc9db88554	Testing-Team Leader	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-12-10	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.329721+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Atharv Malhotra	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f
13428d48-c81e-4720-adba-f8490f27e535	TK-0009	Vihaan	Saxena	vihaan.saxena.tk-0009@talakunchi.com	\N	9820010010	\N	\N	\N	Andheri (Western Line)	9811000170	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	96efad7d-8b7f-4d7f-a862-c0a6bec3789f	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-09-24	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	\N	\N	NA	NA	BE (2020)	[]	["Certified Ethical Hacker (CEH)"]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.747702+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Harsh Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2020-09-24	BE	2020	NA	NA	Experienced	2 Years	2 Years	Father	\N	Functional - Accounts	Billable	\N	Long Term	\N	\N	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255
159fb3d0-937c-4f81-ad37-aa1b4f023264	TK-0015	Rajesh	Sharma	rajesh.sharma.tk-0015@talakunchi.com	\N	9820010017	\N	\N	\N	Andheri (Western Line)	9811000289	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	e4e20503-cd55-4393-83fd-6c7e7d7d0a49	HR	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-02-09	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.827405+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Rahul Mishra	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77
1fa56f20-56ce-4461-ac66-c7d7b34f16d6	TK-0088	Siddharth	Deshpande	siddharth.deshpande.tk-0088@talakunchi.com	\N	9820010097	\N	\N	\N	Andheri (Western Line)	9811001649	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	163d8c87-8f90-4295-a926-2e912c625a1c	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-09-15	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.639521+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vikram Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755
204776c8-efeb-480f-980b-a3f70be97f91	TK-0070	Divya	Deshmukh	divya.deshmukh.tk-0070@talakunchi.com	\N	9820010078	\N	\N	\N	Andheri (Western Line)	9811001326	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	Testing-Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-07-28	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.43265+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Nidhi Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4
2285ceea-ffbf-4bf4-bb2e-bd9e0427beeb	TK-0025	Vihaan	Mathur	vihaan.mathur.tk-0025@talakunchi.com	\N	9820010029	\N	\N	\N	Andheri (Western Line)	9811000493	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	PMO	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-09-27	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.950815+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Amit Sawant	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	PMO (Project Management Office)	\N	\N	\N	\N	\N	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd
238c3cb7-75cf-4478-a48e-fe47465d20b6	TK-0049	Ishita	Patel	ishita.patel.tk-0049@talakunchi.com	\N	9820010057	\N	\N	\N	Andheri (Western Line)	9811000969	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	6d25ff6d-e13d-440f-b775-215547af7acb	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-04-01	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.220166+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Advait Gupta	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
246e0bb0-8a3b-4524-9d7b-3ac6d4ca7d8d	TK-0084	Manish	Malhotra	manish.malhotra.tk-0084@talakunchi.com	\N	9820010093	\N	\N	\N	Andheri (Western Line)	9811001581	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-06-15	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.596427+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Harsh Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4
26fd3209-693a-49d1-9224-8f7e2f3a1c58	TK-0067	Ishaan	Desai	ishaan.desai.tk-0067@talakunchi.com	\N	9820010075	\N	\N	\N	Andheri (Western Line)	9811001275	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-05-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.401399+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Iyer	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4
2b245a46-a64c-440b-861d-24f712bd626e	TKI-0004	Kavya	Mathur	kavya.mathur.tki-0004@talakunchi.com	\N	9820010021	\N	\N	\N	Andheri (Western Line)	9811000357	\N	\N	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	f8502c44-b289-49e4-8401-3dcad4d5bbe0	IT Admin	049ac489-bbd3-4153-b933-aec7b7baec89	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-10-10	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.870977+00	2026-10-21 09:53:00.683803+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Mother	\N	Functional - IT Administration	\N	\N	\N	\N	\N	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
30913859-c8e8-4851-852f-28be97c74bb1	TK-0010	Sana	Pillai	sana.pillai.tk-0010@talakunchi.com	\N	9820010011	\N	\N	\N	Andheri (Western Line)	9811000187	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	1f97b442-95c5-4b11-93a0-ea146534ae85	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Onsite	\N	Permanent - Bond	\N	2018-10-17	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.759044+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Pallavi Sawant	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2020-10-17	BE	2020	NA	NA	Experienced	2 Years	2 Years	Mother	\N	Functional - Accounts	Billable	\N	Long Term	\N	\N	BKC	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255
31057f6b-b1e5-46e3-a071-b6639b93a15c	TK-0051	Krishna	Bose	krishna.bose.tk-0051@talakunchi.com	\N	9820010059	\N	\N	\N	Andheri (Western Line)	9811001003	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	f20a7445-0b01-4f20-85a5-853101d864ee	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-05-17	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.239498+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Kunal Iyer	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
315ae0c9-ecdf-48ba-a662-f93c21ef31d2	TK-0056	Varun	Pandey	varun.pandey.tk-0056@talakunchi.com	\N	9820010064	\N	\N	\N	Andheri (Western Line)	9811001088	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	SOC-Senior Manager	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-09-09	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.289299+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Amit Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
31e49978-ac22-44bb-a535-11d20d8aeea3	TK-0083	Rahul	Pillai	rahul.pillai.tk-0083@talakunchi.com	\N	9820010092	\N	\N	\N	Andheri (Western Line)	9811001564	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-05-23	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.585583+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Sawant	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f
3398777f-d384-48a2-8076-9c4fb06162bb	TK-0095	Karan	Joshi	karan.joshi.tk-0095@talakunchi.com	\N	9820010104	\N	\N	\N	Andheri (Western Line)	9811001768	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	Testing-Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-02-23	Resignation Under Review	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	In progress	\N	Resign	Personal reasons	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.715255+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Shaurya Pandey	beee234f-c734-4d09-a0bb-96a6cc523cc3	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Testing - Cloud & AI	\N	\N	\N	\N	\N	\N	\N	\N	88b29e0c-39b7-4169-ab5c-350075014a84
33e9644b-a618-47ed-b272-c078e19b36ef	TK-0080	Varun	Gaikwad	varun.gaikwad.tk-0080@talakunchi.com	\N	9820010089	\N	\N	\N	Andheri (Western Line)	9811001513	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-03-15	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.553584+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Siddharth Deshpande	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f
13b14e34-f865-4c83-a6c0-3fdf7d196c1c	TK-0029	Reyansh	Sawant	reyansh.sawant.tk-0029@talakunchi.com	\N	9820010033	\N	\N	\N	Andheri (Western Line)	9811000561	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	b2b687ef-fd62-4cb7-a826-b40a35da7b2c	Sales Manager	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-12-28	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.988005+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aarav Desai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582
3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	TK-0087	Harsh	Gupta	harsh.gupta.tk-0087@talakunchi.com	\N	9820010096	\N	\N	\N	Andheri (Western Line)	9811001632	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	163d8c87-8f90-4295-a926-2e912c625a1c	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-08-23	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.628906+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Karan Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4
3a209908-397f-4c90-abf6-9fe52ab98b34	TK-0050	Vihaan	Wardhan	vihaan.wardhan.tk-0050@talakunchi.com	\N	9820010058	\N	\N	\N	Andheri (Western Line)	9811000986	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	48429bb5-c583-4684-b30a-7ed443b671ca	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-04-24	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.230016+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Meera Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
405610b0-c3bd-4725-a409-5f6dbffeacb4	TKI-0007	Arjun	Wardhan	arjun.wardhan.tki-0007@talakunchi.com	\N	9820010038	\N	\N	\N	Andheri (Western Line)	9811000646	\N	\N	898c36e9-1cb7-4c56-9148-a3b6893c0149	bb7ccd5f-2f60-49fb-b984-f11fc47add22	R&D - Team member	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-12-18	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.03788+00	2026-10-21 09:53:00.683803+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Krishna Saxena	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Sibling	\N	R&D (Research & Development)	\N	\N	\N	\N	\N	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131
41708635-a60e-4fbd-a76b-91c0c23d18be	TK-0071	Advait	Gaikwad	advait.gaikwad.tk-0071@talakunchi.com	\N	9820010079	\N	\N	\N	Andheri (Western Line)	9811001343	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	Testing-Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-08-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.443651+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Reyansh Patel	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755
42583b6b-008c-45f6-b258-b08495712c7c	TK-0016	Harsh	Wardhan	harsh.wardhan.tk-0016@talakunchi.com	\N	9820010018	\N	\N	\N	Andheri (Western Line)	9811000306	\N	\N	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	c70b9832-841e-4864-9b85-eaba3c0a995f	IT Admin	049ac489-bbd3-4153-b933-aec7b7baec89	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-03-04	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.838024+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Kunal Rao	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Functional - IT Administration	\N	\N	\N	\N	\N	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
450f16b6-e35c-4564-969d-6bf6ceec7ff3	TK-0082	Kabir	Sawant	kabir.sawant.tk-0082@talakunchi.com	\N	9820010091	\N	\N	\N	Andheri (Western Line)	9811001547	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-04-30	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.575322+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Siddharth Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755
46e3d71d-ea02-474f-b668-f836d91e059d	TK-0062	Siddharth	Iyer	siddharth.iyer.tk-0062@talakunchi.com	\N	9820010070	\N	\N	\N	Andheri (Western Line)	9811001190	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e228c999-bf54-48b4-a373-d2bc9db88554	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-01-25	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.350043+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Divya Deshmukh	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755
4d8e2104-d723-45a0-856f-594f80efd0f6	TK-0064	Amit	Pillai	amit.pillai.tk-0064@talakunchi.com	\N	9820010072	\N	\N	\N	Andheri (Western Line)	9811001224	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-03-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.370485+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Amit Gaikwad	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4
51015348-f872-4e18-b806-e44017e10e4b	TK-0076	Dev	Roy	dev.roy.tk-0076@talakunchi.com	\N	9820010084	\N	\N	\N	Andheri (Western Line)	9811001428	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	c1fa4328-a970-48a1-bc08-d50fe36bf44c	Testing-Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-12-13	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.497879+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Rahul Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Testing - DevSecOps	\N	\N	\N	\N	\N	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
51df4d23-9202-43b7-9e29-4a14a838a242	TK-0038	Vihaan	Gaikwad	vihaan.gaikwad.tk-0038@talakunchi.com	\N	9820010044	\N	\N	\N	Andheri (Western Line)	9811000748	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	Consulting-Team member	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-07-22	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.094147+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
583e812b-e929-4e7c-9d76-33d3fc25cd7d	TK-0013	Tanvi	Gaikwad	tanvi.gaikwad.tk-0013@talakunchi.com	\N	9820010015	\N	\N	\N	Andheri (Western Line)	9811000255	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	c2e248c8-e917-445f-9f7b-1e25d7bb5abe	HR	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-12-25	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.806235+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Anita Pandey	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77
218f30c7-87bd-4410-99fc-4d10da3e8014	TK-0043	Yash	Sharma	yash.sharma.tk-0043@talakunchi.com	\N	9820010050	\N	\N	\N	Andheri (Western Line)	9811000850	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	2b1558e3-158a-4a84-ae80-053129861a64	Consulting-HOD	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-11-14	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.151497+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
5e82125c-9ff8-4a97-a11b-65da79677d3c	TK-0074	Reyansh	Wardhan	reyansh.wardhan.tk-0074@talakunchi.com	\N	9820010082	\N	\N	\N	Andheri (Western Line)	9811001394	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	35a6b1af-dc78-4632-a9f4-eedabdbdcb52	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-10-28	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.476912+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Menon	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Testing - DevSecOps	\N	\N	\N	\N	\N	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
5bf6d5c7-4358-49f1-bb6b-9d0b1b38d4ad	TKI-0009	Priya	Mathur	priya.mathur.tki-0009@talakunchi.com	\N	9820010051	\N	\N	\N	Andheri (Western Line)	9811000867	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2025-02-02	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.161403+00	2026-10-21 09:53:00.683803+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Krishna Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Mother	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
5f4b7ab9-bbfe-4196-9e6c-47f73efe7462	TK-0068	Atharv	Malhotra	atharv.malhotra.tk-0068@talakunchi.com	\N	9820010076	\N	\N	\N	Andheri (Western Line)	9811001292	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-06-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.411718+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Dev Roy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755
5ff0346b-75b8-4c62-afc7-afeb35b17a8e	TK-0090	Siddharth	Bose	siddharth.bose.tk-0090@talakunchi.com	\N	9820010099	\N	\N	\N	Andheri (Western Line)	9811001683	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	9858c224-f97f-4ff8-908d-f46bd5e2243c	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-10-31	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.662063+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aisha Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4
696f99d7-2380-443c-b90d-0e065642e1d4	TK-0019	Priya	Mishra	priya.mishra.tk-0019@talakunchi.com	\N	9820010022	\N	\N	\N	Andheri (Western Line)	9811000374	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	b3309eea-7374-4a8d-ac13-481b2a7fd492	PMO	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-05-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.881525+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Krishna Pandey	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	PMO (Project Management Office)	\N	\N	\N	\N	\N	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd
6a1ac61a-89d6-4951-8246-621d4e1b071f	TK-0066	Nikhil	Joshi	nikhil.joshi.tk-0066@talakunchi.com	\N	9820010074	\N	\N	\N	Andheri (Western Line)	9811001258	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-04-27	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.39087+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Reyansh Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f
6b1f9737-c1f7-4201-8cd2-9b5e6274ebc8	TK-0086	Vihaan	Joshi	vihaan.joshi.tk-0086@talakunchi.com	\N	9820010095	\N	\N	\N	Andheri (Western Line)	9811001615	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	163d8c87-8f90-4295-a926-2e912c625a1c	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-07-31	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.617282+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Manish Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f
6b4e0847-6c40-471e-89ec-c5b63bb828f0	TK-0081	Arjun	Menon	arjun.menon.tk-0081@talakunchi.com	\N	9820010090	\N	\N	\N	Andheri (Western Line)	9811001530	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-04-07	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.563741+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Alok Deshpande	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4
6d26e662-1e9f-4df8-a353-6be5ce9e5261	TK-0085	Lakshmi	Kadam	lakshmi.kadam.tk-0085@talakunchi.com	\N	9820010094	\N	\N	\N	Andheri (Western Line)	9811001598	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-07-08	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.606837+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aarav Patel	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755
70e01a7d-fd0b-4e2a-b086-d059423ca380	TK-0014	Vihaan	Kadam	vihaan.kadam.tk-0014@talakunchi.com	\N	9820010016	\N	\N	\N	Andheri (Western Line)	9811000272	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	485012d4-2c28-4bc4-92c7-3609e3e3749e	HR	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-01-17	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.816829+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Karan Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77
62e81e6b-7247-4c3f-a8b8-db21e613d02a	TKI-0003	Aarav	Bose	aarav.bose.tki-0003@talakunchi.com	\N	9820010013	\N	\N	\N	Andheri (Western Line)	9811000221	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	e8c22eff-0daf-4690-a537-c8b0b6110a01	HR	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-09-17	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.782523+00	2026-10-21 09:53:00.683803+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Kavya Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Sibling	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77
74601727-6182-498f-ac57-4c02b9e56ca0	TK-0059	Kunal	Iyer	kunal.iyer.tk-0059@talakunchi.com	\N	9820010067	\N	\N	\N	Andheri (Western Line)	9811001139	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e2b4be77-2b20-4064-974d-e6322e7240b4	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-11-17	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.319145+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Ishaan Desai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Testing - Cloud & AI	\N	\N	\N	\N	\N	\N	\N	\N	88b29e0c-39b7-4169-ab5c-350075014a84
776f2cf7-c4cc-4299-b38f-afbcaff7703e	TK-0030	Omkar	Reddy	omkar.reddy.tk-0030@talakunchi.com	\N	9820010034	\N	\N	\N	Andheri (Western Line)	9811000578	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	157d001c-b056-45b1-96a3-3c05bcd8d99c	Sales Manager	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-01-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.99725+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Amit Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582
777390a6-91b9-4d9e-806c-16e046568501	TK-0028	Krishna	Joshi	krishna.joshi.tk-0028@talakunchi.com	\N	9820010032	\N	\N	\N	Andheri (Western Line)	9811000544	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	Sales team member	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-12-05	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.978927+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Suresh Desai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582
7e3f1c8d-340c-47d7-b63d-fb047a9106aa	TKI-0002	Aarav	Mathur	aarav.mathur.tki-0002@talakunchi.com	\N	9820010008	\N	\N	\N	Andheri (Western Line)	9811000136	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	caa227a1-2dcf-4195-ab9c-8f76d1862daa	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-08-25	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.722404+00	2026-10-21 09:53:00.683803+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Kadam	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Sibling	\N	Functional - Accounts	\N	\N	\N	\N	\N	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255
78b71d74-d255-4ac0-a75f-ead11a61427a	TK-0035	Aarav	Desai	aarav.desai.tk-0035@talakunchi.com	\N	9820010041	\N	\N	\N	Andheri (Western Line)	9811000697	\N	\N	898c36e9-1cb7-4c56-9148-a3b6893c0149	9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	R&D - Team member	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-05-14	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.066207+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2022-05-14	BE	2020	NA	NA	Experienced	2 Years	2 Years	Mother	\N	R&D (Research & Development)	Billable	\N	Long Term	\N	\N	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131
78c932da-077a-4104-919c-386de88ed062	TK-0058	Meera	Joshi	meera.joshi.tk-0058@talakunchi.com	\N	9820010066	\N	\N	\N	Andheri (Western Line)	9811001122	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	c0f974c3-f49c-449a-9276-aa64ce501344	SOC-Team Leader	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-10-25	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.309385+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Nikhil Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
7d2b2c7a-254e-4605-9f79-3f42ac7f9735	TK-0027	Reyansh	Chopra	reyansh.chopra.tk-0027@talakunchi.com	\N	9820010031	\N	\N	\N	Andheri (Western Line)	9811000527	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	272973a6-c052-4aef-bf32-9e24f7eb6cc9	Sales team member	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-11-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.969016+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Yash Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582
804c8187-6f28-411f-8fa5-cc9baceba3e7	TK-0031	Arjun	Joshi	arjun.joshi.tk-0031@talakunchi.com	\N	9820010035	\N	\N	\N	Andheri (Western Line)	9811000595	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	6193be76-40ad-4973-9ee7-246a4d8f4109	Sales team member	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-02-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.006223+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Ira Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582
818ae1ea-5842-4adb-b475-ac12dba9fd2a	TK-0044	Vihaan	Bose	vihaan.bose.tk-0044@talakunchi.com	\N	9820010052	\N	\N	\N	Andheri (Western Line)	9811000884	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	SOC-HOD	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-12-07	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.171436+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Anita Iyer	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
849d2fb1-a4e4-4eb2-947b-f97057e4954b	TK-0005	Dev	Bose	dev.bose.tk-0005@talakunchi.com	\N	9820010005	\N	\N	\N	Andheri (Western Line)	9811000085	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	155642eb-a633-4460-b658-aca9fde2d817	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-06-24	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.683541+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aarav Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Functional - Accounts	\N	\N	\N	\N	\N	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255
86862bf8-c075-44ef-9f3e-f65d2cc1bb56	TK-0034	Suresh	Desai	suresh.desai.tk-0034@talakunchi.com	\N	9820010040	\N	\N	\N	Andheri (Western Line)	9811000680	\N	\N	898c36e9-1cb7-4c56-9148-a3b6893c0149	3356f353-1566-4df6-9958-fa01d67d13c7	R&D - Team member	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-04-21	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.057075+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Karan Mehra	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	R&D (Research & Development)	\N	\N	\N	\N	\N	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131
8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	TK-0018	Harsh	Pandey	harsh.pandey.tk-0018@talakunchi.com	\N	9820010020	\N	\N	\N	Andheri (Western Line)	9811000340	\N	\N	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	da990f6e-3379-4cc4-89b7-0ead29da472b	IT Admin	049ac489-bbd3-4153-b933-aec7b7baec89	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-04-19	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.859733+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Atharv Reddy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Functional - IT Administration	\N	\N	\N	\N	\N	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
8e0616db-48af-4b73-807f-6e250dba2072	TK-0020	Anita	Pandey	anita.pandey.tk-0020@talakunchi.com	\N	9820010023	\N	\N	\N	Andheri (Western Line)	9811000391	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	2a76927c-461a-48e4-8190-dea7361ef3db	PMO	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-06-04	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.891741+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Reyansh Chopra	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	PMO (Project Management Office)	\N	\N	\N	\N	\N	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd
8f3346d4-6f76-4575-af6d-a69527694680	TK-0079	Deepak	Singh	deepak.singh.tk-0079@talakunchi.com	\N	9820010088	\N	\N	\N	Andheri (Western Line)	9811001496	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	Testing Senior Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-02-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.541706+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Harsh Gupta	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755
900ed2a0-d8b3-439f-af86-7383cdebcd05	TK-0069	Ishaan	Pansare	ishaan.pansare.tk-0069@talakunchi.com	\N	9820010077	\N	\N	\N	Andheri (Western Line)	9811001309	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	Testing-Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-07-05	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.421674+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Simran Deshmukh	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f
9b7f4410-6577-4ab4-9363-e75b9d4208e9	TK-0054	Sana	Rao	sana.rao.tk-0054@talakunchi.com	\N	9820010062	\N	\N	\N	Andheri (Western Line)	9811001054	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	911f6d7f-8d43-40f2-897a-2f416abf8cf9	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-07-25	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.26888+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Siddharth Iyer	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
9c4cf836-745e-4cf9-9a22-933d5e2638c3	TK-0091	Arjun	Sawant	arjun.sawant.tk-0091@talakunchi.com	\N	9820010100	\N	\N	\N	Andheri (Western Line)	9811001700	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	9858c224-f97f-4ff8-908d-f46bd5e2243c	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-11-23	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.672237+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Karan Mehta	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755
9d9bfa3a-8603-4de4-8eb7-76c3935e3014	TK-0012	Advait	Singh	advait.singh.tk-0012@talakunchi.com	\N	9820010014	\N	\N	\N	Andheri (Western Line)	9811000238	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	7d542941-65b9-499b-81b3-239748d6da52	HR	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-12-02	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.794393+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Priya Mishra	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77
9eb64ade-203d-4e4a-aaed-8eaab7d3017d	TK-0033	Yash	Wardhan	yash.wardhan.tk-0033@talakunchi.com	\N	9820010039	\N	\N	\N	Andheri (Western Line)	9811000663	\N	\N	898c36e9-1cb7-4c56-9148-a3b6893c0149	f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	R&D - Team member	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-03-29	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.047613+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aarav Reddy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	R&D (Research & Development)	\N	\N	\N	\N	\N	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131
9312226e-c7f8-4187-887e-67e2124098cd	TKI-0005	Kunal	Rao	kunal.rao.tki-0005@talakunchi.com	\N	9820010026	\N	\N	\N	Andheri (Western Line)	9811000442	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	9050e021-7d84-4401-820e-c0e768abb1ab	PM - Team Member	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-11-02	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.921408+00	2026-10-21 09:53:00.683803+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Omkar Reddy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Mother	\N	Functional - Project Management	\N	\N	\N	\N	\N	\N	\N	\N	a73eb36c-7d62-4aa8-901d-1c70b3876b69
9ec115c7-5377-4f9d-b46a-2a3c97bea4de	TKI-0008	Aarav	Reddy	aarav.reddy.tki-0008@talakunchi.com	\N	9820010047	\N	\N	\N	Andheri (Western Line)	9811000799	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	2076a9b1-e432-46a9-99b1-36e732159856	Consulting-Team member	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2025-01-10	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.123207+00	2026-10-21 09:53:00.683803+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vikram Roy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Spouse	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
9f646393-8fea-4b38-9f35-d88a6ab6787e	TK-0023	Aarav	Rao	aarav.rao.tk-0023@talakunchi.com	\N	9820010027	\N	\N	\N	Andheri (Western Line)	9811000459	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	8b57cfd5-5d4e-44a3-9646-b36873c111c2	EngagementManager	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-08-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.931379+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	EM (Engagement Manager)	\N	\N	\N	\N	\N	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
8e139039-c490-436d-9af4-431d26334b34	TKI-0010	Simran	Deshmukh	simran.deshmukh.tki-0010@talakunchi.com	\N	9820010085	\N	\N	\N	Andheri (Western Line)	9811001445	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2025-02-25	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.50859+00	2026-10-22 07:51:07.636567+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Manish Malhotra	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Father	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
a73329ac-636f-475e-b566-321a5686fd66	TK-0017	Pallavi	Sawant	pallavi.sawant.tk-0017@talakunchi.com	\N	9820010019	\N	\N	\N	Andheri (Western Line)	9811000323	\N	\N	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	73bd55bb-5d0e-4381-8ad2-2238377fca93	IT Admin	049ac489-bbd3-4153-b933-aec7b7baec89	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-03-27	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.848874+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aarav Rao	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Functional - IT Administration	\N	\N	\N	\N	\N	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
b9c0b8fc-4c96-42fb-8669-d68097cf5392	TK-0048	Aditi	Roy	aditi.roy.tk-0048@talakunchi.com	\N	9820010056	\N	\N	\N	Andheri (Western Line)	9811000952	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	e36018c5-bf48-4f93-bef7-93e8864a0b51	SOC-Team Leader	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-03-09	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.210593+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Varun Pandey	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
bbdc4c49-4262-4c1a-a270-1bfe3c550644	TK-0036	Amit	Wardhan	amit.wardhan.tk-0036@talakunchi.com	\N	9820010042	\N	\N	\N	Andheri (Western Line)	9811000714	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	195d6a81-8457-4b60-9382-6a3a0664f0e9	Consulting-Manager	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-06-06	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.075353+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Yash Sharma	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
bbe8dd34-5945-4f0f-ab99-2cb2f7c99c95	TK-0061	Aditya	Pillai	aditya.pillai.tk-0061@talakunchi.com	\N	9820010069	\N	\N	\N	Andheri (Western Line)	9811001173	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e228c999-bf54-48b4-a373-d2bc9db88554	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-01-02	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.339329+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Ishaan Pansare	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4
be9f417e-d40a-4c66-91e6-e7fde84b46d5	TK-0026	Krishna	Pandey	krishna.pandey.tk-0026@talakunchi.com	\N	9820010030	\N	\N	\N	Andheri (Western Line)	9811000510	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	138434a2-625f-4df5-836d-fcf0cfceef79	PMO	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-10-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.959922+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	PMO (Project Management Office)	\N	\N	\N	\N	\N	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd
bfb55863-c987-497b-9a1b-9a7bc56a9509	TK-0077	Nidhi	Bose	nidhi.bose.tk-0077@talakunchi.com	\N	9820010086	\N	\N	\N	Andheri (Western Line)	9811001462	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	Testing Senior Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-01-05	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.519257+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Lakshmi Kadam	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f
c5e35b7a-af12-4fd6-96af-e62225e715c6	TK-0041	Karan	Mehra	karan.mehra.tk-0041@talakunchi.com	\N	9820010048	\N	\N	\N	Andheri (Western Line)	9811000816	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	Consulting-Team Leader	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-09-29	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.132457+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aditi Roy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	TK-0092	Harsh	Joshi	harsh.joshi.tk-0092@talakunchi.com	\N	9820010101	\N	\N	\N	Andheri (Western Line)	9811001717	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-12-16	Resignation Under Review	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	In progress	\N	Resign	Personal reasons	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.683278+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Ira Reddy	beee234f-c734-4d09-a0bb-96a6cc523cc3	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Testing - Red Team	\N	\N	\N	\N	\N	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798
ca561f47-f73a-4401-8c6f-a1c776d88534	TK-0075	Vihaan	Iyer	vihaan.iyer.tk-0075@talakunchi.com	\N	9820010083	\N	\N	\N	Andheri (Western Line)	9811001411	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	767a00dd-6f09-4f64-a44e-8fbe901222af	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-11-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.48702+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Kabir Sawant	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Testing - DevSecOps	\N	\N	\N	\N	\N	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
cc295432-e771-4d6f-9cc3-079cc5d9b576	TK-0089	Alok	Deshpande	alok.deshpande.tk-0089@talakunchi.com	\N	9820010098	\N	\N	\N	Andheri (Western Line)	9811001666	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	9858c224-f97f-4ff8-908d-f46bd5e2243c	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-10-08	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.651136+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Manish Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f
cef36bf2-c4fb-4040-b3ab-d033190ad3b4	TK-0096	Vikram	Joshi	vikram.joshi.tk-0096@talakunchi.com	\N	9820010105	\N	\N	\N	Andheri (Western Line)	9811001785	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-03-17	Resignation Under Review	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	In progress	\N	Resign	Personal reasons	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.725971+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Rahul Sharma	beee234f-c734-4d09-a0bb-96a6cc523cc3	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f
d01c0ef5-731e-42de-b02a-7c996c545f15	TK-0045	Vivaan	Mathur	vivaan.mathur.tk-0045@talakunchi.com	\N	9820010053	\N	\N	\N	Andheri (Western Line)	9811000901	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea315f7d-d597-41b3-a999-4f3851bcd020	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-12-30	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.181143+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Sneha Choudhary	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
d17be428-1602-4e09-a164-c3c2666fad73	TK-0002	Neha	Pillai	neha.pillai.tk-0002@talakunchi.com	\N	9820010002	\N	\N	\N	Andheri (Western Line)	9811000034	\N	\N	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	ffed7aa1-e88f-4281-919f-8d49fbabf5a5	COO	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-04-16	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.651331+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Saxena	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Leading Delivery Department	\N	\N	\N	\N	\N	\N	\N	\N	45755b2a-741a-4990-ab78-8f65090f75b1
d2010072-d612-48ab-9a8a-f137b87e6034	TK-0006	Amit	Deshmukh	amit.deshmukh.tk-0006@talakunchi.com	\N	9820010006	\N	\N	\N	Marine Lines (Western Line)	9811000102	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	8dc0d8fe-593d-422a-8b27-5b68fbe6d224	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Onsite	\N	Permanent - Bond	\N	2018-07-17	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.698357+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Advait Singh	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2020-07-17	BE	2020	NA	NA	Experienced	2 Years	2 Years	Mother	\N	Functional - Accounts	Billable	\N	Long Term	\N	\N	Pune	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255
87fd3345-a756-44df-a3e7-5f21fa6e50d3	TK-0098	Aisha	Mathur	aisha.mathur.tk-0098@talakunchi.com	\N	9820010107	\N	\N	\N	Andheri (Western Line)	9811001819	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-05-02	Terminated	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	Yes	\N	Resign	Better opportunity	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.747534+00	2026-10-16 09:54:37.309719+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-16 09:54:37.309719+00	\N	\N	\N	\N	Divya Sawant	a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	\N
d502bbdd-5186-490e-8f0a-5489d2737c6f	TKI-0001	Nikhil	Malhotra	nikhil.malhotra.tki-0001@talakunchi.com	\N	9820010004	\N	\N	\N	Andheri (Western Line)	9811000068	\N	\N	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	c0e1a001-0000-4000-8000-000000000001	Intern	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-08-02	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.672816+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aditya Roy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Guardian	\N	Across all Sub Departments	\N	\N	\N	\N	\N	\N	\N	\N	63765624-d7d1-472d-abd4-627127646998
d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	TK-0093	Aarav	Patel	aarav.patel.tk-0093@talakunchi.com	\N	9820010102	\N	\N	\N	Andheri (Western Line)	9811001734	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	85cc9fbe-98a4-464d-a638-05f40529c6de	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-01-08	Resignation Under Review	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	In progress	\N	Resign	Personal reasons	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.693648+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Neha Choudhary	beee234f-c734-4d09-a0bb-96a6cc523cc3	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Testing - Red Team	\N	\N	\N	\N	\N	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798
d73eac4c-d537-4d31-8e35-b55f8aff3e87	TK-0046	Arjun	Pillai	arjun.pillai.tk-0046@talakunchi.com	\N	9820010054	\N	\N	\N	Andheri (Western Line)	9811000918	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	4650d4e0-f73c-4688-ae5f-830a46348ff9	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-01-22	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.190401+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Sana Rao	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
d94878fd-4650-46bc-b84c-753c841e7404	TK-0008	Nikhil	Saxena	nikhil.saxena.tk-0008@talakunchi.com	\N	9820010009	\N	\N	\N	Andheri (Western Line)	9811000153	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	SOC-Senior Manager	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-09-01	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.734742+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Rajesh Sharma	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2020-09-01	BE	2020	NA	NA	Experienced	2 Years	2 Years	Guardian	\N	Services - Operations	Billable	\N	Long Term	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	TK-0021	Karan	Wardhan	karan.wardhan.tk-0021@talakunchi.com	\N	9820010024	\N	\N	\N	Andheri (Western Line)	9811000408	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	834c9e15-c70d-4a0b-bb12-5e55f23c181d	EngagementManager	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-06-27	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.901338+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Krishna Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	EM (Engagement Manager)	\N	\N	\N	\N	\N	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
d9fd54d6-b11b-4969-a25d-8b8e3fcca417	TK-0032	Amit	Sawant	amit.sawant.tk-0032@talakunchi.com	\N	9820010037	\N	\N	\N	Andheri (Western Line)	9811000629	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	e2c675a7-92dc-4477-be75-9a304cbe4def	Sales team member	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-03-06	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.027123+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Pooja Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582
dd200677-337b-440b-afcb-3a661406f98b	TK-0078	Reyansh	Patel	reyansh.patel.tk-0078@talakunchi.com	\N	9820010087	\N	\N	\N	Andheri (Western Line)	9811001479	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	Testing Senior Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-01-28	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.531601+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4
df8f375a-d0b0-40c0-8ada-264fc2275f4f	TK-0057	Advait	Gupta	advait.gupta.tk-0057@talakunchi.com	\N	9820010065	\N	\N	\N	Andheri (Western Line)	9811001105	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	444df30d-c195-42ad-b9a7-d80cdef69ccd	SOC-Team Leader	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-10-02	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.299121+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Reyansh Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
e09daabd-8da2-4dc9-89b4-03f4b79583de	TK-0072	Amit	Gaikwad	amit.gaikwad.tk-0072@talakunchi.com	\N	9820010080	\N	\N	\N	Andheri (Western Line)	9811001360	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	c6c6cd04-6df3-4593-b686-e4b9d362c96f	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-09-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.453799+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Deepak Singh	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Testing - DevSecOps	\N	\N	\N	\N	\N	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
e131815f-331f-46d7-81f8-5d2bed793630	TK-0037	Ira	Bose	ira.bose.tk-0037@talakunchi.com	\N	9820010043	\N	\N	\N	Andheri (Western Line)	9811000731	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	1e7faab8-273d-40df-9f9a-485160186c5a	Consulting-Team member	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-06-29	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.084626+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Priya Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
02814af4-08b4-42cc-92e1-ad0bba687378	TK-0039	Pooja	Bose	pooja.bose.tk-0039@talakunchi.com	\N	9820010045	\N	\N	\N	Andheri (Western Line)	9811000765	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	Consulting-Team member	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-08-14	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.103381+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vivaan Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
033446c7-c133-4395-bdaa-69b5f227a7a8	TK-0024	Atharv	Reddy	atharv.reddy.tk-0024@talakunchi.com	\N	9820010028	\N	\N	\N	Andheri (Western Line)	9811000476	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	9dc69952-eae6-4ec0-a327-67392315f089	EngagementManager	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-09-04	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.940959+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Ananya Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	EM (Engagement Manager)	\N	\N	\N	\N	\N	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
23bf310d-b789-4dcc-bb7e-576b373e72cf	TK-0099	Karan	Mehta	karan.mehta.tk-0099@talakunchi.com	\N	9820010108	\N	\N	\N	Andheri (Western Line)	9811001836	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-05-25	Terminated	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	Yes	\N	Resign	Better opportunity	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.767705+00	2026-10-16 09:54:37.319639+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-16 09:54:37.319639+00	\N	\N	\N	\N	Kunal Desai	a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	\N
089e3bae-d509-46db-906f-3085e0438c9c	TK-0100	Ira	Reddy	ira.reddy.tk-0100@talakunchi.com	\N	9820010109	\N	\N	\N	Andheri (Western Line)	9811001853	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-06-17	Terminated	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	Yes	\N	Resign	Better opportunity	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.799186+00	2026-10-16 09:54:37.329732+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-16 09:54:37.329732+00	\N	\N	\N	\N	Vivaan Iyer	a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	\N
b20f343b-e7fa-4310-9c43-ef10ca51ff6c	TK-0101	Neha	Choudhary	neha.choudhary.tk-0101@talakunchi.com	\N	9820010110	\N	\N	\N	Andheri (Western Line)	9811001870	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-07-10	Terminated	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	Yes	\N	Resign	Better opportunity	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.811056+00	2026-10-16 09:54:37.338979+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-16 09:54:37.338979+00	\N	\N	\N	\N	Kavya Deshpande	a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	\N
049ac489-bbd3-4153-b933-aec7b7baec89	TK-0004	Admin	User	admin@talakunchi.com	\N	9820000004	\N	\N	\N	Andheri (Western Line)	\N	\N	\N	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	da990f6e-3379-4cc4-89b7-0ead29da472b	Admin	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	2018-06-01	Active	Active	Ongoing	0 (Relevant: 0)	\N	Permanent	\N	No bond	\N	\N	NA	NA	\N	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.5279+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	\N	\N	NA	NA	Experienced	0	0	\N	\N	Functional - IT Administration	Billable	\N	Long Term	\N	\N	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
d29c4919-9e2d-46c1-a78f-ffd2d4d32365	TK-0052	Anita	Iyer	anita.iyer.tk-0052@talakunchi.com	\N	9820010060	\N	\N	\N	Andheri (Western Line)	9811001020	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0c1a5ef4-7fca-45dc-8253-87afa21a1df9	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-06-09	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.249213+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Trisha Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
f19ea8a8-4d2f-48f9-832e-311f80e49f11	TKI-0006	Ananya	Joshi	ananya.joshi.tki-0006@talakunchi.com	\N	9820010036	\N	\N	\N	Andheri (Western Line)	9811000612	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	e2b10def-c91d-45da-94c5-f5530e743aa2	Sales team member	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-11-25	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.016241+00	2026-10-21 09:53:00.683803+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Gaikwad	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Mother	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582
e93a25e9-5347-49e1-b901-88271fdbdcf5	TK-0063	Kavya	Roy	kavya.roy.tk-0063@talakunchi.com	\N	9820010071	\N	\N	\N	Andheri (Western Line)	9811001207	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-02-17	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.359883+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Advait Gaikwad	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f
e96df572-92a2-4aa3-a3b4-6f52cfcb5293	TK-0011	Aditya	Roy	aditya.roy.tk-0011@talakunchi.com	\N	9820010012	\N	\N	\N	Andheri (Western Line)	9811000204	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	HR	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-11-09	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.770263+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Harsh Pandey	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77
eba0b052-26bb-4216-ab6e-dff23c63bc57	TK-0022	Rahul	Mishra	rahul.mishra.tk-0022@talakunchi.com	\N	9820010025	\N	\N	\N	Andheri (Western Line)	9811000425	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	d8a2b9e5-f54d-4344-a78d-c6c840467543	EngagementManager	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-07-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.910624+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Reyansh Sawant	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	EM (Engagement Manager)	\N	\N	\N	\N	\N	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
ee7b555a-4400-4c03-8fe5-60fd908c0e58	TK-0042	Arjun	Mathur	arjun.mathur.tk-0042@talakunchi.com	\N	9820010049	\N	\N	\N	Andheri (Western Line)	9811000833	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	3e60b693-d3dd-4481-95c4-9f02da21625c	Consulting-Team Leader	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-10-22	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.141853+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Ishita Patel	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
f01f614a-af85-4225-a3b4-3c463fb97bdf	TK-0003	Dev	Reddy	dev.reddy.tk-0003@talakunchi.com	\N	9820010003	\N	\N	\N	Andheri (Western Line)	9811000051	\N	\N	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	0525d830-ead9-44a0-871f-91b7845fec26	CTO	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-05-09	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.662231+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Sana Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2020-05-09	BE	2020	NA	NA	Experienced	2 Years	2 Years	Friend	\N	Leading Compliance & HR Department	Billable	\N	Long Term	\N	\N	\N	\N	\N	61bbeadf-3044-4123-929c-4b1e6e2e613e
f30d1ce8-8a1a-483d-ace2-419cd8672ecc	TK-0094	Manish	Bose	manish.bose.tk-0094@talakunchi.com	\N	9820010103	\N	\N	\N	Andheri (Western Line)	9811001751	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	4b680e29-b4fb-4689-9afb-67a7f089f52b	Testing-Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-01-31	Resignation Under Review	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	In progress	\N	Resign	Personal reasons	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.704355+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aarav Deshmukh	beee234f-c734-4d09-a0bb-96a6cc523cc3	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Testing - Red Team	\N	\N	\N	\N	\N	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798
f39b20bb-8963-4917-aed5-0f1d86f0cbc3	TK-0007	Aarav	Roy	aarav.roy.tk-0007@talakunchi.com	\N	9820010007	\N	\N	\N	Andheri (Western Line)	9811000119	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	6e606c29-2ebf-4ab8-8006-aaedd5680009	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-08-09	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:32.709153+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Tanvi Gaikwad	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Functional - Accounts	\N	\N	\N	\N	\N	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255
f8b1a855-954d-4f8b-aad7-be5502a7413a	TK-0053	Sneha	Choudhary	sneha.choudhary.tk-0053@talakunchi.com	\N	9820010061	\N	\N	\N	Andheri (Western Line)	9811001037	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-07-02	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.259434+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aditya Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
f90e007c-90d9-440e-8f0a-a85395e49abe	TK-0047	Vikram	Roy	vikram.roy.tk-0047@talakunchi.com	\N	9820010055	\N	\N	\N	Andheri (Western Line)	9811000935	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	af8a1442-c5ee-409d-aa91-61c9dba852ee	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-02-14	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.200068+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aditya Menon	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
faa36d59-2e24-4a0e-851d-42900c200d3b	TK-0073	Rohan	Deshpande	rohan.deshpande.tk-0073@talakunchi.com	\N	9820010081	\N	\N	\N	Andheri (Western Line)	9811001377	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	ae255622-ddcc-45ea-a699-8ec416fe57ab	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-10-05	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.465301+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Varun Gaikwad	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Testing - DevSecOps	\N	\N	\N	\N	\N	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
fb184814-7151-428d-87c3-f83814676aa5	TK-0065	Reyansh	Mathur	reyansh.mathur.tk-0065@talakunchi.com	\N	9820010073	\N	\N	\N	Andheri (Western Line)	9811001241	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-04-04	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.380982+00	2026-10-20 18:31:50.195919+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Rohan Deshpande	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755
ffcdc44f-996b-4ef6-90e6-db858823a4c4	TK-0055	Aditya	Menon	aditya.menon@talakunchi.com	\N	9820010063	\N	\N	\N	Andheri (Western Line)	9811001071	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b5f39dd8-c305-489d-9f7d-9adfd010a134	SOC-Manager	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Onsite	\N	Permanent - Without Bond	\N	2021-08-17	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 09:25:33.278641+00	2026-10-22 07:41:45.955014+00	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	\N	\N	\N	Kavya Roy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	2028-10-16	BE	2020	NA	NA	Experienced	2 Years	2 Years	Sibling	\N	Services - Operations	Billable	\N	Long Term	\N	\N	Thane	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629
\.


--
-- Data for Name: tbl_exited_employees; Type: TABLE DATA; Schema: resource; Owner: -
--

COPY resource.tbl_exited_employees ("Id", "OriginalEmployeeId", "EmployeeCode", "FullName", "DepartmentName", "DesignationName", "WorkEmail", "PersonalEmail", "Phone", "StatusAtExit", "ExitType", "ExitReason", "ResignationDate", "LastWorkingDay", "ReasonForLeaving", "NoticePeriodServed", "ExitChecklistJson", "AssetReturnJson", "FinalSettlementJson", "ExitedAtUtc", "ExitedBy", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "ClearanceCompleted", "ExitRating") FROM stdin;
8912cce4-7930-4e36-b37d-73cd3b67cf09	940ec7cd-058d-4f8f-912f-08ae55bac01c	TK-0097	Manish Mathur	Services - Testing	Senior Pentester - I	manish.mathur.tk-0097@talakunchi.com	\N	9820010106	Terminated	Resign	Better opportunity	2026-09-16	2026-10-02	Career growth — UAT sample exit	Yes	\N	\N	\N	2026-10-16 09:54:37.283402+00	\N	2026-10-16 09:54:37.284411+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	\N
592d8ea7-675f-46b6-ad6b-73c500810c95	87fd3345-a756-44df-a3e7-5f21fa6e50d3	TK-0098	Aisha Mathur	Services - Testing	Senior Pentester - I	aisha.mathur.tk-0098@talakunchi.com	\N	9820010107	Terminated	Resign	Better opportunity	2026-09-16	2026-10-02	Career growth — UAT sample exit	Yes	\N	\N	\N	2026-10-16 09:54:37.30937+00	\N	2026-10-16 09:54:37.309719+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	\N
1ec9d02c-2e3c-4088-8fe5-48f03852e262	23bf310d-b789-4dcc-bb7e-576b373e72cf	TK-0099	Karan Mehta	Services - Testing	Senior Pentester - II	karan.mehta.tk-0099@talakunchi.com	\N	9820010108	Terminated	Resign	Better opportunity	2026-09-16	2026-10-02	Career growth — UAT sample exit	Yes	\N	\N	\N	2026-10-16 09:54:37.319553+00	\N	2026-10-16 09:54:37.319639+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	\N
4bb21e7f-6233-401e-8295-82ad20f7f2fc	089e3bae-d509-46db-906f-3085e0438c9c	TK-0100	Ira Reddy	Services - Testing	Senior Pentester - II	ira.reddy.tk-0100@talakunchi.com	\N	9820010109	Terminated	Resign	Better opportunity	2026-09-16	2026-10-02	Career growth — UAT sample exit	Yes	\N	\N	\N	2026-10-16 09:54:37.329587+00	\N	2026-10-16 09:54:37.329732+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	\N
fc4934f9-b212-404a-8e6e-0864d7a32648	b20f343b-e7fa-4310-9c43-ef10ca51ff6c	TK-0101	Neha Choudhary	Services - Testing	Senior Pentester - II	neha.choudhary.tk-0101@talakunchi.com	\N	9820010110	Terminated	Resign	Better opportunity	2026-09-16	2026-10-02	Career growth — UAT sample exit	Yes	\N	\N	\N	2026-10-16 09:54:37.338883+00	\N	2026-10-16 09:54:37.338979+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	\N
349cce80-bb8b-4655-a5af-b5ab2e8602f1	ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	TK-0092	Harsh Joshi	Services - Testing	Red Team Practitioner - II	harsh.joshi.tk-0092@talakunchi.com	\N	9820010101	Resignation Under Review	Resign	Personal reasons	2026-10-16	2026-11-15	Serving notice — UAT sample	In progress	\N	\N	\N	2026-10-16 09:54:37.348639+00	\N	2026-10-16 09:54:37.34871+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	\N
b5c2dbaa-9148-4d57-adce-d4f56e47e696	d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	TK-0093	Aarav Patel	Services - Testing	Red Team Practitioner - III	aarav.patel.tk-0093@talakunchi.com	\N	9820010102	Resignation Under Review	Resign	Personal reasons	2026-10-16	2026-11-15	Serving notice — UAT sample	In progress	\N	\N	\N	2026-10-16 09:54:37.363037+00	\N	2026-10-16 09:54:37.363101+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	\N
f990999e-7294-4ae5-b0f9-e55b2b2be4ee	f30d1ce8-8a1a-483d-ace2-419cd8672ecc	TK-0094	Manish Bose	Services - Testing	Red Team Specialist - II	manish.bose.tk-0094@talakunchi.com	\N	9820010103	Resignation Under Review	Resign	Personal reasons	2026-10-16	2026-11-15	Serving notice — UAT sample	In progress	\N	\N	\N	2026-10-16 09:54:37.372123+00	\N	2026-10-16 09:54:37.37219+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	\N
4a23d7a5-bb64-4e6b-888a-7aa10a1b1c39	3398777f-d384-48a2-8076-9c4fb06162bb	TK-0095	Karan Joshi	Services - Testing	Senior Cloud Security Consultant - I	karan.joshi.tk-0095@talakunchi.com	\N	9820010104	Resignation Under Review	Resign	Personal reasons	2026-10-16	2026-11-15	Serving notice — UAT sample	In progress	\N	\N	\N	2026-10-16 09:54:37.381068+00	\N	2026-10-16 09:54:37.381116+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	\N
7e852d2b-b3b0-4242-b618-d00b39cc9928	cef36bf2-c4fb-4040-b3ab-d033190ad3b4	TK-0096	Vikram Joshi	Services - Testing	Senior Pentester - I	vikram.joshi.tk-0096@talakunchi.com	\N	9820010105	Resignation Under Review	Resign	Personal reasons	2026-10-16	2026-11-15	Serving notice — UAT sample	In progress	\N	\N	\N	2026-10-16 09:54:37.389577+00	\N	2026-10-16 09:54:37.389691+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	\N
\.


--
-- Data for Name: tbl_onfloorrole; Type: TABLE DATA; Schema: resource; Owner: -
--

COPY resource.tbl_onfloorrole ("Id", "Name", "DepartmentId", "DesignationId", "SubDepartment", "RbacRoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
01a26d31-4fcd-4ad3-b08e-1276a4620cb8	Team Leader	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	444df30d-c195-42ad-b9a7-d80cdef69ccd	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
03d492f0-4458-48e5-9ee8-06f09f660218	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	48429bb5-c583-4684-b30a-7ed443b671ca	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
0837f524-0260-4283-a37f-6e1fb06d3dcd	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	Services - Testing - Red Team	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
0acaaceb-a951-4492-bdba-69d5e916f8b4	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	85cc9fbe-98a4-464d-a638-05f40529c6de	Services - Testing - Red Team	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
0c18f8ce-b9be-4ec0-a099-44b0fd29bdcd	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
1abc8fed-e830-4103-a5ab-c3402b166116	Team Member	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	c0e1a001-0000-4000-8000-000000000001	Across all Sub Departments	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
21c47c58-0be4-41bb-8407-8df5fa4b8e9d	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	af8a1442-c5ee-409d-aa91-61c9dba852ee	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
23f52e10-894f-4e50-970b-202a3127a1d9	Team Member	8e4e88f1-e294-4554-80cc-92ed6169caeb	834c9e15-c70d-4a0b-bb12-5e55f23c181d	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
27d8ec30-01ad-45f2-a7d8-7a54c2d2c754	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	911f6d7f-8d43-40f2-897a-2f416abf8cf9	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
29119117-9aa3-4def-9db8-802f70f74e4b	Team Leader	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	c0f974c3-f49c-449a-9276-aa64ce501344	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
2d4e6116-3ec3-4c5d-9d75-35517814a964	Team Leader	be8e036d-ad13-4c79-89ec-294e490a6816	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	Services - Consulting	701aaa2c-a899-4def-bf5f-e17511874409	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
3091c873-f1f0-4632-ac1e-62d1a451c39d	Manager	13c91c98-00ae-4211-acb8-d06e35953806	157d001c-b056-45b1-96a3-3c05bcd8d99c	Functional - Sales	914d8500-03b6-4a43-a250-244effca1cf1	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
3101ee42-6788-4ae4-a80b-f7394720b740	Team Member	13c91c98-00ae-4211-acb8-d06e35953806	e2c675a7-92dc-4477-be75-9a304cbe4def	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
36339f27-5abf-4ffc-bca3-5a2333a94df2	Manager	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
39c52128-53f4-4e39-8102-4b9ccc9f5584	Team Leader	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
475cc74e-698a-4547-966a-823be44cfd15	Team Member	898c36e9-1cb7-4c56-9148-a3b6893c0149	3356f353-1566-4df6-9958-fa01d67d13c7	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
4766e158-b2c1-44dd-a36d-18583c490193	Team Member	8e4e88f1-e294-4554-80cc-92ed6169caeb	2a76927c-461a-48e4-8190-dea7361ef3db	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
4cc83d93-7b2f-4c97-a4a7-e9ec47735e4b	Team Member	be8e036d-ad13-4c79-89ec-294e490a6816	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
4d8c99f7-b5c4-434a-ae7c-64419a5a1bcf	HR	310a2f16-15f6-4b82-95f6-ab18b5b429f5	e4e20503-cd55-4393-83fd-6c7e7d7d0a49	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
54123afd-2783-4a41-b18f-328d024e8a22	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	4ef1cb5b-9688-4ce2-95b3-6a0863200166	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
56779122-3301-4a2c-bc35-085f96ee714b	HR	310a2f16-15f6-4b82-95f6-ab18b5b429f5	7d542941-65b9-499b-81b3-239748d6da52	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
56ed9417-a9fd-40ff-a517-1e75bbf02d63	Sr. Manager	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	Services - Operations	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
580f3fc7-ff2d-4881-a222-d91a7c00f491	HR	310a2f16-15f6-4b82-95f6-ab18b5b429f5	485012d4-2c28-4bc4-92c7-3609e3e3749e	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
5814389a-4416-4e4d-96a7-58f4801e2757	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	163d8c87-8f90-4295-a926-2e912c625a1c	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
5c9266d9-5a57-4b6c-aabc-18edce40ae96	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	f20a7445-0b01-4f20-85a5-853101d864ee	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
67084a5d-02d0-4a73-a15f-45aca43adb58	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	35a6b1af-dc78-4632-a9f4-eedabdbdcb52	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
67306ff5-e313-43da-99bc-56b6a6ca65ee	Team Member	13c91c98-00ae-4211-acb8-d06e35953806	272973a6-c052-4aef-bf32-9e24f7eb6cc9	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
67bdeca7-fe42-4b4e-b5b6-9e8e8d410413	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	4650d4e0-f73c-4688-ae5f-830a46348ff9	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
6890c399-940e-4c2a-9aba-0dd90a50e063	Head Of Department	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	Services - Operations	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
6eaffc67-3d6e-4bb6-9c90-0a604398090d	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
70480603-7eae-41f7-b659-052b7500ca91	Team Member	13c91c98-00ae-4211-acb8-d06e35953806	6193be76-40ad-4973-9ee7-246a4d8f4109	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
734614d6-908f-4f24-8331-c515a6d70149	Team Member	be8e036d-ad13-4c79-89ec-294e490a6816	1e7faab8-273d-40df-9f9a-485160186c5a	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
746752f8-decb-46a0-a7e1-d07a0a68dbc3	Team Member	8e4e88f1-e294-4554-80cc-92ed6169caeb	b3309eea-7374-4a8d-ac13-481b2a7fd492	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
7d2b7826-2f63-4796-9032-5ffa35cd5b37	Manager	be8e036d-ad13-4c79-89ec-294e490a6816	195d6a81-8457-4b60-9382-6a3a0664f0e9	Services - Consulting	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
7fe8d8b6-c0fc-4015-a3ff-5bb8e95ea0d5	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	ae255622-ddcc-45ea-a699-8ec416fe57ab	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
8211f0b1-d111-400b-94ab-fd663d50ec65	Team Member	898c36e9-1cb7-4c56-9148-a3b6893c0149	f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
87ea604f-b245-49c0-9172-3956f1d6eb75	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
885809b5-843a-4ec9-bafe-da1472b73a03	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0c1a5ef4-7fca-45dc-8253-87afa21a1df9	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
9326acb0-20c1-4d05-89b6-d85ee3425469	Project Manager	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b5f39dd8-c305-489d-9f7d-9adfd010a134	Services - Operations	111cc3cd-6d35-43ce-be91-dde90d3d4015	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
9635b694-a552-42c0-9df3-a6090c9b1923	Leader	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	0525d830-ead9-44a0-871f-91b7845fec26	Leading Compliance & HR Department	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
99039771-cd5a-4878-a7b9-9cdaa02f5be6	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	96efad7d-8b7f-4d7f-a862-c0a6bec3789f	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
9ac666ca-eaa2-46a5-b489-66a8cc550b65	Team Member	be8e036d-ad13-4c79-89ec-294e490a6816	7c2380da-3ee6-46ad-93d6-a79ce3027f29	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
9ad0a166-cde2-4817-9acd-363d217422d9	Team Leader	0aed67b8-c454-439a-a07f-4f46d46d58af	e228c999-bf54-48b4-a373-d2bc9db88554	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
9ed3ce2c-add0-4472-9da8-4cd5c0552867	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	1f97b442-95c5-4b11-93a0-ea146534ae85	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
a1826c58-197f-4c7e-9909-a8970491fe38	Team Leader	be8e036d-ad13-4c79-89ec-294e490a6816	3e60b693-d3dd-4481-95c4-9f02da21625c	Services - Consulting	701aaa2c-a899-4def-bf5f-e17511874409	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
a885d8fe-9ecc-4c4e-9b23-55c015ffd3e6	Sr. Manager	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	efc1df20-ca04-44a6-87b2-7cae1ff50a88	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
acbe4f0d-8058-4a88-9255-08104f0037b6	Team Member	8e4e88f1-e294-4554-80cc-92ed6169caeb	d8a2b9e5-f54d-4344-a78d-c6c840467543	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
acf26b08-e6ae-4343-9bf9-529b070835a3	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea315f7d-d597-41b3-a999-4f3851bcd020	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
ae6e9e5b-7337-47a3-8fe5-bb02a9a7f374	Manager	8e4e88f1-e294-4554-80cc-92ed6169caeb	138434a2-625f-4df5-836d-fcf0cfceef79	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
b24b3d9d-7454-4657-bb24-3c4f0f40956e	Team Member	898c36e9-1cb7-4c56-9148-a3b6893c0149	9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
b4b2673b-fc1c-4484-8f2d-903a39dff2a9	Manager	13c91c98-00ae-4211-acb8-d06e35953806	b2b687ef-fd62-4cb7-a826-b40a35da7b2c	Functional - Sales	914d8500-03b6-4a43-a250-244effca1cf1	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
b5974e61-080c-4de2-a977-7f0bdee29949	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	6d25ff6d-e13d-440f-b775-215547af7acb	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
b9232654-c160-4e84-bdc3-ad94a605dbe1	IT Admin	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	73bd55bb-5d0e-4381-8ad2-2238377fca93	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
b9f75ed9-10c6-4b61-ad05-b27ec89a8b3b	IT Admin	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	c70b9832-841e-4864-9b85-eaba3c0a995f	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
bb6f610b-b2f5-4b01-9ea4-fb9ad074b768	Team Leader	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	e36018c5-bf48-4f93-bef7-93e8864a0b51	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
c4d57da3-eff2-4cd1-834f-e0d77b39f299	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
c4ef6b03-baa6-47ac-8d06-c8819ddbdaa7	HR	310a2f16-15f6-4b82-95f6-ab18b5b429f5	c2e248c8-e917-445f-9f7b-1e25d7bb5abe	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
c5ea1ba3-9974-4cca-9320-362527502c6e	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	155642eb-a633-4460-b658-aca9fde2d817	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
c637e1a2-5677-45fa-bbbf-f88fc60a9443	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	767a00dd-6f09-4f64-a44e-8fbe901222af	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
ccf1432a-d667-4fff-8071-efbc9f841976	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	8dc0d8fe-593d-422a-8b27-5b68fbe6d224	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
d412d761-e42e-4ab2-8e58-1df17b290365	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	6e606c29-2ebf-4ab8-8006-aaedd5680009	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
d6002117-fdbb-437a-986f-dde6b5b5c162	Manager	0aed67b8-c454-439a-a07f-4f46d46d58af	8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	Services - Testing - Cloud & AI	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
d862a290-2a0a-47f2-9c23-2baf830a37b9	Team Leader	8e4e88f1-e294-4554-80cc-92ed6169caeb	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
d8d41d59-fe4b-4c54-80d3-751a7bbf714c	IT Admin	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	da990f6e-3379-4cc4-89b7-0ead29da472b	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
da608430-bf9a-4a87-9881-1c07e7f2974a	Head Of Department	be8e036d-ad13-4c79-89ec-294e490a6816	2b1558e3-158a-4a84-ae80-053129861a64	Services - Consulting	64c49f37-a38a-46a6-9622-7427f1501658	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
dfa4b2c2-7d48-4ff7-b5aa-9b65fbde04e1	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	9858c224-f97f-4ff8-908d-f46bd5e2243c	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
e061fae9-2430-4025-ad39-ff79717301a5	Team Leader	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
e1f2260d-b878-4693-86db-2513390804aa	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
e3c262a4-4108-4592-abb0-643085d6a305	Manager	0aed67b8-c454-439a-a07f-4f46d46d58af	c1fa4328-a970-48a1-bc08-d50fe36bf44c	Services - Testing - DevSecOps	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
e3ede776-6573-4898-9195-fb2a398100b2	Team Member	13c91c98-00ae-4211-acb8-d06e35953806	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
e60fe13f-6f3e-4410-80c9-dcfbb88f0301	Leader	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	778f1120-9633-4933-9160-ddaa46668838	Leading Sales & A/C Department	62a927b7-9fd8-461a-b64e-1aa441eeba4d	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
eb9edaa3-2522-4d91-ab86-d786a7250f91	Manager	0aed67b8-c454-439a-a07f-4f46d46d58af	4b680e29-b4fb-4689-9afb-67a7f089f52b	Services - Testing - Red Team	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
ecc39c47-956d-49b9-8fbc-44a6433f3912	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	e2b4be77-2b20-4064-974d-e6322e7240b4	Services - Testing - Cloud & AI	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
f39ba18d-6be5-4d23-a99f-f8d7a68c43dc	HR	310a2f16-15f6-4b82-95f6-ab18b5b429f5	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
f4e2358e-5ec0-4292-8377-438dabb72fbe	Team Leader	8e4e88f1-e294-4554-80cc-92ed6169caeb	8b57cfd5-5d4e-44a3-9646-b36873c111c2	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
f51841ca-ffbc-4619-98be-201d736e4f48	Team Member	be8e036d-ad13-4c79-89ec-294e490a6816	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
f6560080-4b30-4b4b-b8ba-90d5b0ead2da	Team Leader	0aed67b8-c454-439a-a07f-4f46d46d58af	c6c6cd04-6df3-4593-b686-e4b9d362c96f	Services - Testing - DevSecOps	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
f7a34722-94ab-4e14-ad50-5e5f0b44cca6	Manager	8e4e88f1-e294-4554-80cc-92ed6169caeb	9dc69952-eae6-4ec0-a327-67392315f089	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
fec21974-29e7-4dcf-8438-efb813045170	Leader	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	ffed7aa1-e88f-4281-919f-8d49fbabf5a5	Leading Delivery Department	a5bfe265-981a-4723-b7bb-6ddc389db7f0	2026-10-20 16:12:25.847811+00	\N	\N	\N	\N
22a8384f-6070-4554-89f1-ee327ae48f16	Team Member	be8e036d-ad13-4c79-89ec-294e490a6816	2076a9b1-e432-46a9-99b1-36e732159856	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-20 16:12:25.847811+00	2026-10-22 07:51:07.556154+00	\N	\N	\N
3d74762f-cfbc-4cb9-b172-c2aaffc64f30	Team Member	13c91c98-00ae-4211-acb8-d06e35953806	e2b10def-c91d-45da-94c5-f5530e743aa2	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-20 16:12:25.847811+00	2026-10-22 07:51:07.556154+00	\N	\N	\N
59cf62d4-7c2d-4e4c-b075-0db51d40ea4e	Team Member	898c36e9-1cb7-4c56-9148-a3b6893c0149	bb7ccd5f-2f60-49fb-b984-f11fc47add22	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-20 16:12:25.847811+00	2026-10-22 07:51:07.556154+00	\N	\N	\N
8765d1b0-e4fc-4686-91ea-f5ad4e929818	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra, Services - Testing - DevSecOps, Services - Testing - Red Team, Services - Testing - Cloud & AI	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 16:12:25.847811+00	2026-10-22 07:51:07.556154+00	\N	\N	\N
b25515f1-974c-4b63-a8b6-ca6e7ab95393	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 16:12:25.847811+00	2026-10-22 07:51:07.556154+00	\N	\N	\N
b7425734-5262-4802-9a10-5e3141b11d6c	Team Member	310a2f16-15f6-4b82-95f6-ab18b5b429f5	e8c22eff-0daf-4690-a537-c8b0b6110a01	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 16:12:25.847811+00	2026-10-22 07:51:07.556154+00	\N	\N	\N
bce667dd-cae2-404d-8013-49194e0f48d9	Team Member	bcbd68c8-c3f3-4396-abb0-0b0e13637958	caa227a1-2dcf-4195-ab9c-8f76d1862daa	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 16:12:25.847811+00	2026-10-22 07:51:07.556154+00	\N	\N	\N
ce7509b0-415c-4d04-a2d8-43c3ee382a72	Team Member	8e4e88f1-e294-4554-80cc-92ed6169caeb	9050e021-7d84-4401-820e-c0e768abb1ab	Functional - Project Management	64e2ea37-cbd7-4127-b65b-3b003235981a	2026-10-20 16:12:25.847811+00	2026-10-22 07:51:07.556154+00	\N	\N	\N
ec4a89e1-35a6-495a-83c9-b6a34ee00402	Team Member	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	f8502c44-b289-49e4-8401-3dcad4d5bbe0	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-20 16:12:25.847811+00	2026-10-22 07:51:07.556154+00	\N	\N	\N
\.


--
-- Data for Name: tbl_team_day_entries; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_team_day_entries ("Id", "EmployeeId", "WorkDate", "Attendance", "Shift", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
df4acf33-00d4-4066-802a-94f0d91b5d31	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	2026-10-18	onsite	General	2026-10-18 10:40:45.088531+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
476f8400-97d4-4d83-8550-1f86411b403a	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	2026-10-21	leave	\N	2026-10-21 06:09:53.844971+00	2026-10-21 06:10:24.349571+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-21 06:10:24.349571+00
\.


--
-- Data for Name: tbl_team_member_holidays; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_team_member_holidays ("Id", "EmployeeId", "HolidayDate", "Name", "Comment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_team_member_schedules; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_team_member_schedules ("Id", "EmployeeId", "WorkingDays", "Notes", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_timesheet_entries; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_timesheet_entries ("Id", "TimesheetWeekId", "ProjectKey", "TaskKey", "ProjectName", "TaskName", "ReviewDecision", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
848b75ec-655f-4918-8fe3-78b6b6a66253	10c038fe-200f-4509-8e0b-1f6ba694ea57	8e260568-b761-4795-ad27-12bddd698d9d	d97b4bad-ccd2-42c0-b1ff-e52787ef8f0c	Aditya Birla(Aditya Birla_Finance)_Mixed_02	Task 01 · ISO 27001 Security Audit	\N	2026-10-17 12:01:20.152448+00	2026-10-18 09:54:18.949044+00	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 09:54:18.949044+00
757cb740-41d6-4026-a025-51bde08cfc1c	e55eacc5-eabf-48d1-b49d-6c9898bb01fd	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
34227563-fa89-4903-9958-07dca021d715	c8d341ae-95db-48ac-bd23-c6956767f486	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
616464ab-df9b-46af-8617-1fb42cb2cf2e	1e593440-2205-49af-8445-142df83bb47d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
740249aa-f9f2-4f14-8da6-2550be43f3c6	904130d7-a483-48d6-8c46-414f7a43c776	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a133a81d-78bf-4f44-add1-0b16023eaed9	b5581485-4a17-4823-9a5f-23a811c3b5f1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
eb4ac256-589d-4b3e-8e02-a6dcdb4fe292	4ad2a0b6-60c7-4956-9f6a-7effa2a67f4c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
82efe96e-2627-4f69-b367-143f4e4efc42	c8dc1f8d-4af7-4c52-a944-90fa21db2057	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1d423a13-e963-4e1f-aece-53ae34c631b6	5353e0b2-41dc-43be-8a68-da89809c1787	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
37b0c1ed-5359-4518-9f34-cc146c70b874	f4499db7-a149-4e3c-8893-330136112036	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0550b807-6ee6-4fd1-9f78-416959225026	a6fe5d90-af22-4b6b-bc5d-84412041207c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8e6c3848-93ba-479c-b98c-2a02e21f1596	2ca1bcc4-6e4f-4477-b504-689d88372db2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
42bd9606-715b-4715-a7fd-fe81dabe324a	870b1656-05dd-4337-957c-9937a21c8a9b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b56d1636-9a19-4e1a-84ae-feac0fe9ee76	80802ce7-9985-4a5c-bdc0-867017dfcf86	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
12ac31dc-0080-42e0-8aee-259ded946244	123265fa-3ea4-4c58-a500-29384ad8990d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c81063d9-5398-40b8-8261-2d916be4f04a	9e6aef2b-6906-4c4a-aef6-305b8a903129	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
53024dca-d52b-4f13-8221-5ca92493c5e3	7671e64b-83f8-4537-89d7-454c3755effd	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
677b359d-02ba-4718-a0e6-639db36b96ca	e6c7316c-b38e-4b44-ba02-ad8ae39c05f6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a80ca2d4-2b8a-47b0-a154-829311dca9e7	b7aebe6d-8467-43af-b2dd-cb453df81a39	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a7c9dc41-94ef-4273-abb5-6c60efd7130a	e928c252-6c07-4b86-8733-d5db872105e2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
862078f9-7dbb-4ef4-b0c3-01ce8f161bf1	61857b62-05ed-41f2-b1a1-0e319d1cdfac	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
466fa441-f1cf-474c-8700-35848cf70f8e	0f632ef5-6769-4219-b434-478620881f9b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2fb7de78-8303-48e9-afb4-11e3b37df61c	6c368450-1f60-4745-b1c7-c0473ed5f6b2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
abd62060-26d1-4274-8971-bb1178bbdd12	11c00d99-f9cf-4a3c-8cf3-e5264005f5fc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b976672a-10ca-4b52-96ab-11b2264bd6b8	6bb0d8d4-9748-46e8-91b2-981a65f962ce	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e827db19-29ef-4004-8456-7d2616b59228	cc3459de-1db4-42a8-b7e1-3abd9663efcc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c17f1864-bcae-46ad-a1b2-870600a9a235	a9987944-51f3-402e-b947-0a581fbab9b9	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b64c744a-2106-4c8f-967e-6f2256896e47	0ba45cf3-b980-48f9-b097-736881cbc663	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3389f1f3-d769-4703-b05d-ca0c9b86d9ce	88f1ddd2-5116-422b-8237-ad06ebac97db	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a274b654-ceeb-4fb0-a799-e21065b9a525	1c189fff-60c4-40da-99bb-328e8dafb34f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cc8a24af-c75c-4bbd-aee8-ba62f0672376	d1918c54-80b6-41b7-b675-b55f2fda998e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9b11a2d7-7267-4694-ad09-d78728bad7bb	bdeed966-f0c7-409e-9afe-617ee21d8a0f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8548c271-4595-4445-b154-f372bb9f1338	cf7b343a-35b7-4d10-8048-685869933454	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
351a9129-5004-4dfb-898b-c3e3455b7c47	40ac5edb-662b-4155-ac2c-df8a907cd075	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
190bcfd8-3ed0-4e60-9553-1ea58f357d6b	9fb7a9d9-db65-4127-81e6-4631a12887ee	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fc4e8089-0928-40d8-be1d-6402fde79a3b	cdbb7849-232c-45f7-96a7-70f36b9fd219	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e0897866-a534-421b-9fcd-a7ae0a1694fb	06469fcc-a17c-46e6-9c60-11e0126ea176	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0c276263-b0bb-4526-8210-e66fb4489174	f0782e82-8faf-40ab-b481-338b0d883023	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
da03121f-5268-4ffd-b818-22f5a6f2aed5	daa2f4e7-fd04-46f8-8ce3-e15ad856a4f3	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
286c9170-9cf1-42b3-be5e-0839b941ab91	4faf9b14-ab00-415b-88f2-ee40f7596f4f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7a423e39-1b24-4abd-b17f-5216ab3b21ee	6f2d03c8-c3fd-48bb-a030-7ccaf001d10d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a3757d4a-3f5a-4bfd-8e90-c21f09bdf2b7	b8974968-e71e-493a-b089-e51c88d8ed74	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
627090ed-aab4-463e-a542-de207c75d4d0	d17a1da1-a4af-49d5-a2ee-c4c7147c6108	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7ea48f10-8b81-49b1-9eb8-09261d123c99	c2c5116b-a6d1-4cf2-ae8b-e0314a3690c1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9226008b-5420-42e3-92c1-2e02a8d4ad04	b96239c4-8a8e-49b3-a50f-d650dd94b163	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6f7f2a01-1cb7-4d84-b79e-84acaad3263b	7b02cf35-a9d1-41b2-ab3d-de97fa8452af	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3281f07d-1af0-40e5-9a87-94f541b055ff	04ef2c42-f5bd-4734-a8eb-e225e37ad502	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
64cd20e2-541a-40b1-8a07-9ebf2e8dafd5	05d6bcec-6ad1-4c18-ab11-a82866c2f18f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4577fa2c-5f15-4c9a-a549-1a6b98237a59	954f6b6d-86f5-407d-94df-3877d5640f86	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8be2649d-eb5f-4300-8681-ae37671e2e94	22e1b9a6-1f5c-4305-81e9-7cdcd4f188b8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a7cc7861-d636-4e14-b9e5-9e68b666a2c3	79c29990-79fa-4efe-bccd-d359ed18f422	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
db809fb0-958c-435a-9f45-b927e6c8f4a9	98d1b649-a084-47ba-a4e9-83ece1fc2944	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
13067dc4-9d35-4243-856d-c82ecbefde1c	fbdd138e-202a-43fc-b72b-386eeaa3edc7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
20a6755b-e941-40db-9fb2-b889a609a2eb	2eeded6d-ef7c-4449-92c8-72dd138a5f34	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b54c6386-c578-4bf2-aa5d-74c0584998f8	731225bd-7bca-4369-af27-9c82ae0cc575	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
24ccdfcf-c471-4e70-93f0-1743280fb76d	5880812a-80d6-4377-a0b4-0efb91f5d73d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4e76e0b0-49fa-4776-ae3e-6e63e185324f	9ad9ea2c-acac-476d-8d2b-dc07e310db02	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
750b525b-37f1-456d-92a9-9a0042e896bc	32ec6e1d-e945-40e2-882d-b2aeadf2ea2b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cdb0f946-0f24-4c12-b289-9c84aa234b33	afc1d6f1-4a02-4bff-a434-2aaa374df307	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
024723c6-4c67-43be-8537-7b1181babf9b	9f89e59f-20a5-40d0-bfc8-295a6a373abd	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
068cc6b0-d2e6-4b40-83a5-e9d34a849d25	4eba58c8-bc55-44f2-8aa2-5c6efaa44d8c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b10e2237-7ad6-4fec-af3f-29b15e611fb9	dda0c566-79b3-49dd-a161-ae3cd2e69d49	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
07dd417d-d872-42b2-86d9-c9ccb545c1d4	bff5e07b-44aa-44b7-9d60-49bb01a685e3	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1be7f127-29b7-45cd-88d6-df2ed68b376f	65777af6-c4f0-4399-bdd3-a346b489812f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dab0bfe5-3d36-4a40-b618-f776119083a2	18c371f4-62b9-4591-aa29-6193a3316a6b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1fa05291-8d71-4d7c-b2fd-0f9802510233	03231140-54b9-41a3-85d1-7a4cf48dc8f4	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d454791f-a54b-436e-9a8c-2af9b57e7f91	865fe8cd-23de-4221-8fd0-04d5cce8a89e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
55dbbc8f-f4d7-4b6e-b1e7-e26cd496f084	bc063845-b916-4d4f-ac7d-1b2106df0e8c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
737985cf-cca7-4dec-8911-9640dc774efa	a12261cc-0229-438d-bcd3-cbdcaaae576d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3effc5c9-f4a8-48d9-a615-ebc284ab0450	dee89888-cfe1-4559-ba75-19c6c03f78d7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aeb3a63b-3fa6-4215-aa0f-6c8ac014c14c	36582e0f-0d45-410c-a150-e1546b4c75da	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
54e3957e-6316-4561-a859-be9facb8b098	9bc437ec-2d8e-4371-930c-9bafcd3ecd07	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
39f1ec0d-b890-4124-a356-ba245873bda9	81fe180f-d7c2-4dd3-b56e-c2ff3220c45b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4a1a35fb-e0f0-4f57-9e1a-d7d055d95966	2ada4c75-6320-431a-b6b7-9cf6c6a57dc1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
658dbaaf-38cd-441e-a093-94ccb455523b	c43880f1-c570-4ccf-ad67-d805cc665a57	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a46283da-5150-40ef-8cf7-d26825dcb5cb	88c72628-1db4-4e67-8a05-f2d17775eb35	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bd897923-5e42-4e53-bd70-983c1d7466ed	1673c30a-9da3-49e9-b6be-df0975b31743	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5dc08f8e-42cc-4d1e-b92d-664860a5ea3a	65bd8f35-5709-453d-a36d-844536a5386a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8a558b6b-f381-48ef-98a9-df90ea327932	d701448b-594f-4ea1-8e55-254c89c202d1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6de552d8-0aea-4206-9fa0-0841efa1919e	7cf2325b-21c2-4334-89be-d6858005784d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
04942120-239d-4911-8a9e-c9ab0cf9713f	f74281a7-8a34-4355-9e18-d22a9ec25126	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
90b1c425-7792-459d-8f00-a10ad0d5ab09	f9a27130-d21f-4e27-a79e-d0c4eb73981d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5434cb96-68d9-4c6a-a51d-a5073c7324d0	60f8bf71-2d75-49d8-8225-ecbafa1c2d8c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b825ab32-356e-41a8-a6f7-4d4b21bb52d4	fd02ea05-8546-4019-b8fe-52345a224534	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
71e42543-3ae9-456e-8a6d-c4faa74f682b	4299ca2e-1c3e-4495-9441-09188be8f3a6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
766e554e-71a5-485e-a5cb-9a045db3f9fa	79bdfefa-9f1e-4dcc-9910-bcf631acac23	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
44a99453-a953-4183-8d20-c22a868e493f	654c4e12-3daa-4ab5-a5f7-cad447e0f2e4	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ae83f83f-ab0c-4d60-b220-821bc7cbe533	cbffad8d-49d1-4e1d-a2a5-0dc03c8ab226	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2414c4dc-2e5d-41c9-8586-c16274874aa4	3fc4205d-f099-4d51-99a9-ec0208da0c12	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
36c9aa18-5906-4e3f-919f-c10a4b2ba706	493a4bc4-8cf7-4b07-9fac-a63e7a7601bf	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
435640c2-69c1-4d26-b06c-10e250ff09e7	9c99286b-37b9-4ff7-9948-9c3d5ab28314	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
822a6a64-ec8c-42f2-9097-f3e9e01aa7dc	0d42d03f-4998-4aa9-8269-91f515add4fd	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
865d1f01-8e7b-4f2b-bd29-ff95c5f44cdb	55ffdafe-b010-43ba-b494-495eeee8375a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bfbd56c6-d4c8-488c-adab-297fe726056e	5521bbc8-d61d-4075-9a2a-febcbd9c2d6f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ced75b26-864a-45a8-9ad2-dac2324490fa	fb574a33-1483-408e-839c-abab1a9f2970	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b3f7a38d-8e12-44c5-ad76-b668fb0c27f7	fabe037e-1d17-4c9e-b3f5-fbc775fa71e1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
63ad31fe-28d0-4888-abdc-5f417acd40c5	cfa0efb1-c2e1-46e9-9460-3ed4af838fae	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5fb8ffaf-53db-4ba2-819f-48f2a67ae06b	7e2b8ec8-9b06-4dbb-9582-36ad2e97e993	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
64b4adec-31d8-4c8d-bda3-15787a68f726	58fdc6ae-829e-458d-b780-aaf7a14d1b3c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
23d1a9ac-d56b-43b6-a97a-4c1556730b07	2868de84-cb3d-4c4b-bd00-7d416fd7e87e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3dd16fda-2c71-493b-96cc-c371d891ff10	7da83908-3050-46d5-9fb8-d4b916140816	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
69e41d8d-d9af-49b1-a83e-09ec15511fc8	426a2575-09d3-45b5-9d1a-d28f166b77fc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1f5c553c-860a-434b-98f2-9659e895b3fa	d1bee652-2fab-46fd-80c3-951683c15b35	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7d1bdb2f-3944-41d4-8ff0-4993b1a0fb29	1e7d08bc-a2ab-4617-b53b-d4c799a5e172	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d4c85d6d-1178-4759-b3b4-7f9c7adbcacd	4e77c34f-e170-4535-9adf-cfb31aca4802	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fdc030f8-9097-4e45-b313-bedb82c35091	1a0ff201-ca72-4363-a694-02eeaaddb6b4	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2ddb66e2-e466-4d57-adec-3e5336eadd13	071bb657-be39-4eab-942d-18c01335f888	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0e3f9c06-61a9-4c95-9d60-f1d8309bc69a	3b403d8d-c9f7-4f2a-964f-49acf4db9175	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6d62ad49-be8a-49b6-84a4-edcda61b49d0	a095cc88-316a-43d6-93c4-01c3ba43ad75	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e51ae210-e515-4c9e-9d31-80981bf5be0a	55b920f1-fef9-4b9c-b0d0-848e73fcff30	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c7b653bd-9594-4004-96f1-af064c01c239	8f97eed7-672f-41f5-acce-e3b58867c285	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
14c9d57f-a02b-4515-8e5c-49d4f1dca780	201c79a5-605a-464a-baaa-ac85d1267832	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b7402c3d-09ad-48b0-b2dd-b24e834700e1	94b4aef0-bf71-4c9b-b356-dc9e53d36432	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f3b5ee45-e700-40f6-814c-549dd1f0cff7	ec8475cf-d1b2-402e-aa8f-8c437b0b8f41	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ac9feaf1-1256-4d9d-89a3-6cada13e6093	7177a28c-91ee-4fc2-97ff-02354466546b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c9fc86fa-8763-4675-961b-86a5856f9a7c	fa393a39-1a54-46cb-83d9-fa4c9524f8fb	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
136e2580-5455-4eff-bea7-ba1a7c493208	0695f858-7462-4c2f-9d58-3707a5229d9f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
24c8840d-4353-4564-9a26-274509423d4c	f57535f2-2f64-46fd-8f86-47b0d6c1a589	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e593fcff-a353-4123-bba0-1e93211114cd	d272ae33-052d-4d62-b6da-81248c246ec1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4019253c-e0e2-4f36-8378-1b6493b7743c	508fea76-a00a-4a77-8d51-0a4c69eb7b10	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e54f51d8-dd9a-4290-b15c-2cf9d9248818	a108dbe2-13b9-449c-963e-b41239635e02	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0fe5edad-4f14-4b26-91c1-094499b64bea	6b47b6ea-bc19-4f64-a9bb-afd103b26792	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
abca123c-d9f8-482d-a1fe-082177dea3c8	c1f69f84-7454-4431-89a8-9f78a70abd2b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5a13f1fa-61be-43bd-8e59-920b764fd7ee	3433cb7c-5635-4ed4-a880-5329d0ca8ac3	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4c4d18eb-6fb0-4e29-9b1e-4aeb46eeed13	4a25041a-b6a6-40c0-bacd-7037675fac58	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0edbbaac-714d-49fa-9007-d4aeba519de6	ed0a2a11-2bfd-408c-95b5-e50a13f185ad	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d4d97af8-6d68-4c72-9bc9-a51dde24c51e	6fafe1aa-9629-4d0d-9eda-2e1f3379fa90	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5e609a43-1324-4be4-8b26-19b6cafbbdfa	471c3856-0a01-445b-aa3d-c5b917d6708f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
949a40b3-fd74-4ca8-b48c-343a550309a7	5582e722-0853-4d56-8313-a503f7c7c794	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f8ce6342-9f6a-4695-afce-86afc97673d0	3588549f-a226-4796-bcdc-80d076722a99	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
11503b50-d1a4-458f-b8c1-b72a9b7738c3	365b0d72-8387-4ae7-af45-71a10e73ea64	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dcaee63c-3224-4f87-87bc-5c0a381313af	ec2957a7-1880-4f8e-b9c4-4ab3820c4a99	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
13b8f1c4-0a31-4984-a8fa-80565e315f99	cf5307cb-ffb1-423a-b15f-63997d978d50	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
36ac3ca6-73ca-469c-bc87-0cc58cf5d5fa	85213367-81f7-4ac6-bd39-5ce3715358ce	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
26f62d50-4af0-4cc1-91a9-dec36d4ec6f7	c353d35b-d98b-44a1-bbfa-29fbdb1105e4	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
38ecdea1-cdb9-4bcf-8c52-cc12b0963056	ee41b6dd-3e29-4373-8fdb-516da5392736	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
524fcde5-c1a9-475b-b5c5-c2990457a769	5720bfac-81dd-4e51-a399-7e417cf5c652	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f61f3b5a-7e7b-4dec-96c7-b3d67f17154f	696e0c14-ffb1-44f1-aafd-e0967f5b7b7c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
72fd6adb-ccbc-4339-b283-c3500b83a722	35c95ece-e577-430a-b63d-c4ab5ae195d2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
be6615c4-9c8d-487f-86cf-64dca82a3866	3ab479fa-10ed-4f81-a8f9-7fbea13c33e9	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
51a9246a-31ff-4011-80f5-4c55850450bf	c58940de-1476-49f5-99c6-c7679414e1c3	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2eddfe04-ee05-4b27-9f10-904b67651966	2c4c9d30-33c8-4353-bb6b-d7d9587f8081	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
91c4c38e-af51-4885-9e46-1852ad8a0164	b6ff9ff9-1513-40c2-9e16-8c22c818d5f2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cb4d4859-e6b6-499c-addf-c0aa5cb6b7ba	a1b27637-ce8d-4db6-9c59-0784749a79ed	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
37792710-05ac-42de-9b1b-908b916f4b35	2f965fe3-a696-4001-a793-ddf193feacbe	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
595b2dd0-b6ce-434c-8446-ca10e16012bd	46a20f9f-1516-4d8e-89cb-73c4e223e85a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f39d10cd-6314-4d73-9abe-a4505169115c	bdf4f026-0d55-4c09-9d02-0c4159ddaf79	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
043be691-df3e-40b6-a8cd-335312425487	05188c96-059e-4c33-b946-1aa709528c1c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e611408b-3717-430e-9617-f52a235f83ca	dfc9f8c5-384c-4f6e-9896-13bcd5a04b70	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4d83dd41-8ae8-4d0d-a238-73d873359ffe	06f8ff35-af90-4eab-80d2-286d3f071e32	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
81d05e03-4afd-444c-b3f5-f411d6c9fccd	e0c3810c-a67d-4507-bfbe-1737a5d78c7c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7d82f19d-2e11-4e97-b741-eb2041952cfc	4997bbee-cc7a-42b6-8276-e08ff481ba67	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3a2fef4e-66ee-46d3-af3d-6ddc6bc7e395	a5884eb9-5d7d-4964-a62e-07372f3f502c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e86b7a8e-b49c-4a53-b635-de1d68ec4b82	9aaa3757-ddc7-414d-969e-923b3b1690d3	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0fedc096-0433-4a7c-87a6-5f3460005c94	ad052a7e-a34c-4f59-89a1-b87e3b6f0936	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
732d0320-c065-4bf0-a5c7-8323807b9ccb	3d2e44fb-671b-4247-9b98-702321001a46	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d3881aad-d907-43fc-9a84-13560285d3d1	8683ecff-e970-48b5-ab61-42a0a3dd66b4	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9fd99fb3-c269-43ec-bb28-b88554c78ade	a3047eac-d70b-498f-8178-8c6a3c91b4f9	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
717f9536-5f01-4d40-9e95-7a19645007fb	50e6f9c9-1085-4ee7-81df-fd2790a8a0f9	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1df69106-0f98-4ee0-a004-fb6455d249ef	d782e2a1-b58a-4d8f-8af3-c1a17ea45c3a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6fa01520-54a8-4b80-b8bd-090a7169d992	cee36b44-c6e6-465c-a3d9-7e899ec585f1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c01eb865-c554-47ac-a058-38ff2057b023	d04f1ea3-411d-4b59-8378-702057c6c556	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7730492d-a7ff-4cb1-8300-5ddd5232ed44	0bf6e418-c552-4dfa-8870-83c6ac11b6bc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5667e395-5ddd-42c8-a078-47dd551a8b6e	a3fb1170-35fb-4061-91d9-0eaee55d8746	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
62d61404-40b0-4cba-b78b-62f3832510a5	a13c3a44-87a7-4e94-99ac-d5f6bc8206bd	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ba18ecd0-a61d-4f67-9c07-0bc0031e737e	f9e4cd0b-8507-49cf-8fc7-f5380680fabc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
24fc4473-5e3a-4211-b670-389ae1d49019	caa254e3-c5f4-41d4-8628-d0c650dac27d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
832f7ab8-d001-4e33-a38b-51939b79e838	767303e1-14f2-4707-9db7-48e0a1566707	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
356692e4-1e28-433c-a5f9-b28c943e96ee	ec5efdf8-b7fa-4dae-a6a0-d66bbd650030	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9c4875bb-a1c0-47aa-98cf-008864b6d1fb	fdeb5beb-554e-46c6-8d70-83ea9e2416e6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5a1605f0-3986-4954-8369-38cb11b599e5	7b922344-bfef-47c9-8ff7-756a7d3daec3	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8501a990-da3d-483a-858e-6c1bbee29718	81c67782-3f2d-489f-8302-c4aa14c6b11b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6e61001b-c45d-487d-947a-600c22d42854	7882cd9d-963c-4022-b2df-114e4bb09c05	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5e3cb4f0-0a20-4115-80ef-b3653c01b126	e7bee937-7244-43f3-8d61-20282818eef7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1e528066-722a-42d1-8893-fdc5547dac9b	cddb66c8-0795-4321-8b8f-50fc348c7b3e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
28759fdb-da41-4cfe-96f0-fffb73fa312f	905da889-399e-490b-9920-5c712a0538bb	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d7c425d5-89fe-4073-9483-f0cfd19a2544	a932015f-cd95-47bd-8f96-1d31389dc9a5	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3c83285a-3c43-4dda-b061-4fbc6df3f50b	5f21c5a9-e8b8-4851-88ef-87cc1afac45b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
43a23ee8-46d3-4fe8-b995-cebd67fea476	bd9153dc-1b3f-4cd1-88ca-299dca449e7e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1d4a7fac-998e-498e-ab29-9f8712f008ed	645196d6-dab2-4b2b-b9ef-ee45a8745a8d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
efb906c4-7a40-4a74-8764-bd68890e4049	8791659b-bd5a-4b67-a05c-4444734dc0c9	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
339c45d6-bdd6-4415-a28b-1b6b8c65ba97	766d0890-9fd8-47ca-bf2f-d7c523b26e1b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
52cf5518-dcbc-4dee-b89d-82f6129fc8c7	156942a5-7160-4298-a9b0-6fd986530382	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9a8b8dca-6cca-4d4b-9553-2e9f66adf6ce	07baa8b7-84ba-483b-9dc5-2d06436bcbb4	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
995d0351-e5a3-418c-b43f-4d6ae33b0290	c175734e-a012-4234-a43c-e24118bb3c3f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
40828885-c5ee-49f3-9f8b-5fefb11f5981	136c5069-02a0-4dd8-bf48-e141d058b3a3	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3fa221eb-445c-47f6-8395-abbe95523b7d	532e70c2-6560-44e0-b630-05dfe8072336	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
795fb08d-a679-440a-9db7-4bff38b394f4	be2e0e48-1f57-4062-8d4a-29fe6b547e3d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f963f38b-94e7-4a81-a844-06451eef6843	cce3117f-a230-4ef8-80a7-e05f10e9eb81	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
25cb222b-b088-4a5b-abf6-d32c2b66d3f9	20f465eb-f2e2-46a0-8513-44380ac8cf40	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
927f123d-bec5-485a-8c31-c432a6b0ddc1	4e01d4cb-c63c-4979-93f8-558245199e4f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3c523dee-e2a0-4abd-a0f7-3b18fa806fc1	e3f5183e-8f90-4c7d-a630-2b7614db6151	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
695a98bf-90c5-42f9-853e-7b7114255faf	61338963-c2ac-452f-a771-4a8bbf70654f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0a0b0e9c-7a60-4cfe-a210-37eec7a9c665	0f81e1eb-3d28-4382-8de2-eb4848e5b058	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0a9a4607-0ebd-439e-b422-c0cbaf41c974	c64a30b7-17bd-4a97-90c7-8cace7630372	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7f980fde-1e99-4a02-8421-8b8de650bcf8	3806ac94-e7e2-4c2b-b787-7671edf0bfca	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
097dc71d-ea99-479c-bfe0-0e835c2d36b6	39788b9c-ca63-41c9-a22c-1c8ed9e037b4	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
10742903-261b-46ad-b814-fefe81479bda	54e9052c-d9be-4333-b48b-57441f17a28a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b08d4ab5-d93c-401c-af71-663d95a5d4ee	c3927d4f-3a80-4a81-89c3-f6e622588a85	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
078e8927-390b-429a-a0eb-b48db0fae96b	16b646d8-e169-4893-a880-b4a23274dd04	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8d23a33d-6d14-41dc-a4e5-193efa8b12cf	2e3d97fe-d716-44e9-affd-7dc81d7ae3c2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
db233fb6-f8a9-4008-b771-4a561e7638cf	0926dcc3-69ec-4b0a-9060-6da7559a544d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2eebcc77-c4bd-427a-964b-33e0ad388b98	cf18cef9-6ccd-4d7a-83f3-4c6dbbe27c0a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2d227def-95f0-4408-8f2b-e9bcd5c2a99f	5efba3bc-ca23-478c-b7c1-7f80a9ec5333	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
90b5620f-f187-418f-9136-f4261b43155a	33f95908-375a-4f41-8c61-f2bb63839eb4	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
669824b9-5760-4eca-b62a-b72a140f64da	1af1bd2c-83fb-4737-941e-e2f9b26857c8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9d9a2d0e-838d-43c0-85b0-de303a1437ad	406672b9-70e7-4250-b329-aa8b7938dc17	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7e6ddb82-38ab-4157-a31f-45bef4689b70	e9203789-12e9-49e1-9930-2e28c83c8db3	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3e22569c-5007-4b63-946b-5daba5f8f153	76d8db68-d47d-4f78-b727-2ac43d43e641	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7e3fe322-7f3e-4b6b-a77c-a37839691d93	f7db94c0-3cbe-45c0-8745-383ec453a4fd	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6d38be45-6da9-4827-ab77-68eb367ad12a	d511c9cd-a0f8-4c37-8f15-e3a8dcb717c7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
82a03f15-3400-490a-853b-c211fea53da8	fc49a861-abc7-4514-925a-0cd6eeec4540	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
108d6794-3b30-4c57-8e6f-3070ad9b923f	eaa08a35-9b5e-47da-98e3-b417962ceb9d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
de9e559d-dc96-4dd6-8abf-8cfbcd60cfa8	aa82ab21-c2fa-4b8e-9ba2-1825a9d634dc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3a225eb1-2b66-49ce-85cb-48399a95fd49	0cd26b65-2c42-4de5-b9e3-098b89b635b5	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e67ac562-fc06-4b29-8a51-6c9099441197	0eb758c1-467b-4df6-9bd3-05fce3177049	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
610d1e31-e825-4989-80fa-bd74d0925d37	a7903d05-c1d9-4e20-a44b-c2ba5570a776	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e4ca91cf-57a6-4517-bf8c-6015064be2d1	8a816907-21b6-4f08-925f-39cf59acc9ce	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c9204d0a-b6b5-4189-acf6-f87033aa7809	f2fe6e39-a58d-47b1-956c-2324f63eafb8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
704bb2c1-18b8-4def-aecb-f7cbb1705e14	84d36901-a17d-495b-a48f-012eb48f5296	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cf94ba30-9f66-437d-b4cc-b82165cf1b1d	68011bb6-69ba-4a82-b392-d03aeaf55ac9	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e513a545-c69e-4e7b-b6e6-ecc29ecd3513	2319ab46-f86d-49b7-bbad-f534e43a965d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dfe38c75-69b1-4bb1-a7b3-cb4faf0fa9de	2abc6301-373e-48bd-8963-75efe3d1ce2e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e2e2c050-3bd1-4225-92ea-ced1c6456045	a8dfd60c-a1f7-401f-8e4e-bf081455c135	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d03e8320-d368-4d02-b336-8e47dabe92da	a75b9e90-2bbb-4fcd-a161-5e003524bcda	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
12a45543-3202-41f5-89e1-0c7b2b3cfe48	a89cf0e1-55c0-41db-9b55-3ba94196f036	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4e0116d8-8c05-4b4c-9fee-5e578cea0194	4f25a003-6751-4f26-822b-6e01257bab61	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fe7243d7-d665-484e-ac80-7b946f15ecf3	bf5acb67-920a-4bbc-a588-0c4b778e1bd2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
49cb95a5-2686-453b-ab99-17f6c6bdbefd	66c7ea36-3062-4fc4-bbbe-ef8f817b5b44	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7f0b2ce8-cc3b-405c-b05f-7f8a624c9de7	aad2f885-883c-43e0-a924-1d96b9b8b802	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5b71dcf6-8501-4c75-b5bb-05f67c6ddf7b	e6a89eb9-8efe-4d83-907b-9f407bc9a76d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8c6cf449-1b59-4e5c-ad01-8907e26037e2	e76b5d73-5802-4468-a34e-075be53315e1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cbc5f781-d729-4dae-85b6-fd8727d4934e	4f41a625-d443-4430-970b-279cdbaaf734	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9d01e63f-7f80-418f-85a5-1e65ec149b60	9405bb52-6694-497e-915d-93cdd893a9c7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1c84da64-7c04-4d3b-b27b-30da3f29ae75	54122528-8eb8-45a3-97d7-1728707d696e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a6f1632f-c1cd-486e-b99b-9e916f631464	e519589c-0f59-40d9-95bf-92da3d44c9a0	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7c3d7994-aac4-43d2-bd39-8056ef6caed4	b9830a11-42a3-4096-951f-22e4e0ab60cb	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
531a18a8-9888-4198-9584-cadb15277c25	b7fc18c0-5c61-4b63-980f-8b1963a0594c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
95e71917-290e-45c7-9d40-66700df681d4	58424e43-a5f1-4dd3-a418-2ec4dcb0ecf8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
220f5648-54f6-4c9e-8138-2d7d6d628f77	99ba1131-490c-4a13-9535-2ba373389f3d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f17c8d9c-ed11-462a-b495-aaa867b9b2e0	99a92bda-b3c9-4247-8c62-2998f72fc4b7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f86b40e8-842c-4271-9613-b1d187785cb3	f7ee752e-716f-476b-bae6-a928a72348cc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1ea6035b-0895-401c-8def-421b17bb1d0b	8a1d1b73-3c0a-468f-9521-9b2403337a7c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a35d5ae9-8eb7-4c67-bd41-ebb21a798f60	53d298f6-fac5-41f0-873c-0f9abd1163ac	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a9df35f2-9408-450f-8e72-39061923c0e6	0103c8a7-7e84-4d2f-9a60-425e0ad9f8df	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3de0d3c4-e32e-413e-a102-e8a29355a013	2abd6505-72e8-409a-9b1f-07bcb7d63a7a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
eb5f26ec-73a6-420f-9ab3-8974185db66b	5b2671e2-33a8-477e-8fa0-d15d4549293a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
804b4aa5-b5ca-49b5-bca3-c472e9fd9851	9b6ffff2-317a-42a8-b37b-d386c94a6d29	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
da306436-c013-47b1-9d05-c1d1c1be8201	82e8c691-deba-43dc-9325-a75104721b94	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ca0fca40-563d-4416-97fd-fc3c91d99f6d	4f5964a8-c0b6-42c5-a64c-f1aa3d12185e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a82627ac-8536-4013-b84c-ab787685a453	d589ee25-eee3-4d0b-9a75-aa2e99111bec	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cc242357-2f2a-4baa-b9cd-5b564c2d7575	b69a31ca-f356-4718-ac18-830f0c19d7ee	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b5094b08-26f8-4a63-a4b5-7ebc35f7ccf7	9aad5a2d-db75-4975-900a-4a6cecc07d3c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
43ab6d45-456d-4da6-bbdd-4a424459891b	f6a80156-7740-4d4e-bc22-b1748585ac69	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
db59b929-a805-4fbf-a590-998bc9e34a04	9edac68b-e711-4ae0-a94f-126c5f58ec5e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1319153f-f3d2-484e-bd8f-93f62a1a4758	51753f35-8325-4979-bbbf-1ba115d4a2e0	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e8280fe1-1861-4bd8-9d1d-53b0c310b2af	dc4c4541-c204-4702-8f71-3579748bb1ed	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
946dae4e-8549-45c3-9311-fac453d22412	2b933faf-de8c-4eb5-8bd1-af873dcb719e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d26e631e-1552-4f6e-a6ed-8c17049837ec	24af3c24-97c6-40b0-b389-b6cba6edd5ba	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
84a838b5-a832-4df6-8886-a13db65209f5	9ff048db-7505-413c-a7cf-0fb2094cb168	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
da515f57-0b19-4100-8eb5-9460c39f588c	72c8228f-d590-400e-ac80-cca21499d44e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6d59e935-e6fe-4af1-afca-bdeed0e5d28b	61a34c53-18d6-4921-88fa-805cb533f5f8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4eeefb7e-ef01-4571-bd28-f480f1a7ad99	8de6dbf7-e3e4-4d01-bb4d-b3a91ba39649	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6942acc4-b06d-4c05-a038-90372b1cc6b5	6ed61629-4b56-46f0-8f37-0ba584253638	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f49b5955-9697-4596-b71c-c9657fd123d2	4f50fc6e-cd66-40d9-8e0b-8a7fea41a474	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
954e0853-3552-495b-a722-1ed6d1d2b2cf	f04c0463-f944-406f-92bd-0bbe3e4137f6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a2787b36-f776-4b41-90cc-ae1d8d2343b2	44924c47-fc7e-4aab-90a1-4185c1414a0b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8230d118-9b23-4146-874c-2da5c9a93330	728d23d8-8fca-4c0e-a8a8-2b98405763be	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
402685e4-0018-4f56-a50d-23a7898f997c	bc223b40-269d-4e41-a475-1c6662205760	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
23892fae-b486-48e3-b5d6-17013bdfda2f	2a86a333-109a-4e2e-9ec1-fa53e05b7411	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f66d0012-ad6f-424c-83c0-8aecf9ccc0f5	66843f47-5ba9-464c-9001-9b6b9351c312	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
61f36935-6a0c-4ee1-a73c-f2d3e91be9a4	c79dca90-1715-4644-8209-20097c561c01	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
492ef8a9-d1df-4e12-9a83-3e7a68843db3	07eff1fb-8146-4783-8e94-258c62b864a1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
93aeeb8c-a2d3-41e6-a081-7105071eb74c	bad1e79d-7aab-460b-8fe4-30cf493c58b7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
af5d3436-6cb3-435b-b196-f1de1a008fdd	30a8b906-4252-4229-a29f-2701d4f2af19	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
84bfba78-ba41-48e4-bb04-96fe5425f949	349a4f71-5cfd-42ea-9f27-1df8914c92dc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0c04eacf-3934-42f2-859b-840c6a26e1cc	149030d9-f0a0-4d7c-ba09-10336ab95377	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b037fa33-d9c5-45ed-9733-b6a240ff5c7e	a1730346-3029-47dd-9991-7cf9c49e0150	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e3ce072c-32f4-4e7c-acec-a873a51481f3	6b619d35-f3b9-4bbe-b90d-32e39aa410e1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0eb29785-5af2-413d-be77-89bfd21ce82f	480a9077-4b48-46c1-ad64-fe8a588250ad	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a969341e-feeb-4634-8764-2415c2c82ac1	60a4d3c0-87ce-4707-98f0-91570ecb029b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2b45ed00-e159-4e44-ace6-224fbafc1aed	8fb2e6b5-2a3a-480e-9121-e7f98fbba6c3	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9824d754-e00a-443f-b636-6dbfa762b13e	c28fa629-f3dd-4765-8fb6-b28609d57e61	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
be99416b-2b54-4b28-8d14-0299a03497c8	7c145d58-67ad-4bbd-b5a4-c4cb9ae3567d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fdcc3782-c42b-4b2e-a1df-8d4731f3daf3	7b51d35e-8bc2-4178-8f65-352e1a0dcb49	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
34d0d6bb-4fde-4710-a4ef-a1c74f3d2685	bd2b1d3a-43ac-4b5b-b9fb-1b00ed09115d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e0f94f57-d32c-4497-8ac1-0c38647a86e3	93f90956-ca0e-4e62-838f-4509817ad6ad	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d5702a38-ff3b-448a-a78c-e1e680c85ebc	f0959dec-f1e8-4e96-ba34-0b7da71533f5	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8b22f170-ca9a-4e2a-881d-add96cfa14d3	d05828aa-bc9d-476e-8c53-aa4dbd864881	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
210e5325-4a69-42d0-ab43-4e20140fa2bb	1ea72c28-e4fd-4380-b80f-5162bf98a441	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c8b4cecc-c02f-4a53-aecf-58282f3ff909	ddfa029b-9db7-4f27-9eeb-1f35df0a95fc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c2d37696-1ddd-4563-a99d-68d3acae1068	68657543-e964-4469-b424-84ce653d4fda	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
87b56228-d156-4e7d-8b8a-779af36cbc23	9a924e59-d338-4461-8782-2b188d989e82	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
938c4b04-a9a2-456b-b04c-dd6f38b8db10	a011061e-5a88-4415-8807-859b23b2584d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
eceb2429-671e-4b06-a11e-3b649004a8b2	aeceaa1d-5dc8-4c67-8f3b-ee4e311c11f0	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1c9b7d63-e7ee-4cb7-8f64-80eb2861f74e	d5edd81c-2218-499c-a7b8-a960283eb9f6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d4bc7faf-c49b-48b2-8c6e-af149fba72c9	8978b44f-94df-4360-b631-74e6940d960d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
863b6ab2-e859-4ff8-8b73-15adee4ee275	6a2b7766-a588-4635-b4a9-e33b20fee843	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4bf0c272-a729-4abb-98c4-77cf254fd99d	ef6cfc1b-c980-4d90-bf1c-62ba8455d172	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
534e84f1-cf3c-464f-a0d8-e44df0773945	31f6b6b5-21c3-4a20-bf5c-0e6a5126779f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bcecc802-2eb7-4857-9ce8-7ac3c2e7a279	f097ebe3-5bbe-4f56-9dbd-2512037d26bc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
da5ddf47-14da-4bbd-81ce-35dcf1851444	2af97f44-85cd-4391-b0a4-a188a3b2f883	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5f7298cc-fbae-40ee-b039-b0d9f1699af4	5c65c72c-7c55-42b6-acd4-5bdc9a622c7d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
50410ec8-dcd4-4ce6-b3c9-18191461c546	efd37a89-9d4c-4778-8898-6809e859e537	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8fa4b4e8-0f45-4aa0-9e9a-4533a909ca5a	2c810cae-07e0-425a-995c-23d1d2a0fcdf	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d819eed1-777d-4695-9188-e357fd65db67	a760daee-87c9-488f-b428-db22b38de83a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d7d39293-1c8a-4fe4-905e-1423fc8837af	0c8d376b-f9fe-414b-9476-d826f249be8e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f803ebb1-3599-47df-b726-7583dd4320d2	e5e03d36-006d-4baf-870b-86b4f2d9cddd	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
00673b89-1bad-4a9f-9090-b07da2e58f31	beb48512-20d3-4b67-a375-1968753d864a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
24db3f2d-92c3-40a3-bbcb-4bbe938be53c	64703b23-f8dc-4b4d-993f-da7e5da542b4	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
620f48f0-e0bd-4064-8e3f-911c3eae3a42	59607403-d358-4bfc-8ceb-ff2e06801a58	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d8f986e2-fad1-41a3-abe7-70fa021cfa10	7ec1811a-bd0b-43f0-8ad2-772a27c56141	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1ae7ec9f-ef49-459b-8b3a-12d77f22beb5	3885101d-467e-4079-a586-9f36c0040c2d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
602e8e36-8eb1-47b6-8f9f-8708576e0187	2f1c7504-8342-4549-8e7c-41ecf65d890e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aaf85f6a-ae52-4b93-9b97-8fef57173a73	237fd517-7750-4e1d-b4e5-4fb0a22bec5f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a5bad36b-2924-4c10-9b76-f83b959795fb	bffee663-d980-4c57-925f-362cd69d6b5a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
412f8228-fbaf-4cda-9ecc-4c417c13471d	68b95cd1-ea28-4554-9243-10cabe75bae0	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ca0f3e41-b3ad-4aca-a6fe-d97f15665954	582e8ba4-9314-4fc7-8e62-17cb3d48f3cf	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f297a90a-24e0-4995-aece-42202861fc0c	0ad1a2cb-c6ab-46fb-ad1a-2ac2396be256	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
011a62ab-aa23-45c4-b52e-d852ce42e108	a304d38c-e508-4fcc-8e0b-dbaf3112a1f1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aad139aa-d557-470a-b51d-f6f0678b1657	63a55762-d041-442a-b50f-df03e317925e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
98f19d61-eb3e-44cd-b203-0c36d78e3949	aa13cca7-ffd8-4e94-b1e7-8576390b6c68	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a5158d3a-576c-4ac5-930a-3d3fe9ec94d3	6bab7232-09ad-4570-a534-2c12a2296b3e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8314107b-94e2-48e9-ac2a-a6931c1f24b6	774cc368-a1ac-470b-a5dc-83875d41b755	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cd9c6fe9-9cd4-4c4b-b1c5-cfd464e35af6	dc7aa965-ccdb-44a8-ae01-b6f8aba3680b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f25f511b-330a-4ca3-acea-5475decfb948	ce4975e2-4637-486d-8168-4cd263a5e566	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
56b254ea-f6ce-4fab-a017-2cf42a0d7edd	cf24c382-498e-4598-b90a-6cf34a7cbfd2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c063f12d-ecef-42f5-bec4-5f78a2bc20b9	9e64d24b-dfa7-43e9-87e8-7c37f81a1c55	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6046bcec-49bd-4d09-afd3-bbe7204f480c	2e444be9-7889-4048-b447-9d5e7c3c6e38	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d492a6b4-beae-4cdc-a8c0-626fc892dcf9	f13dcab9-4bc2-4783-a221-4646393850c4	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ab56b3ae-fa45-4686-bb98-3c6d7f7b6a8b	9f267402-5f9e-40ab-b625-92269f6ed265	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6cd02fd8-fe5a-4160-b6d5-d0ee3cdddf7d	55380174-0b1c-4119-8f60-6a68716143a7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
adf47935-1828-4383-951a-04669fe06e1b	0b6cddcd-20ac-4f19-b481-c746d9d85993	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e3259519-bc58-4590-9af9-da316791190c	7c225d66-a64d-4ba6-9ffa-a3ad825aeb4b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0455570e-f43c-4507-ac93-f92ed6c4e0cf	f75433f4-ab99-4793-a041-a2f4f81ef835	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
816819ff-69e9-494b-8495-416c739df9d5	9fd071fb-41c4-4b84-8dec-9d35a0cff342	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fab42d10-d976-4371-82dd-15896a25bca5	271e2ab7-97c7-4192-aae7-a056251d3cd8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
55a24e2c-d39e-4e95-aa9f-1e5c41861499	eb66890b-117f-4653-9a13-af84114e39ca	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
15435e98-1f3d-4080-91d7-833fb8dc6bfe	3866a1a9-7608-4452-bdbb-439f49718561	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ff2c819f-f975-4790-a8b1-59a736f20819	6c4adf02-d681-446d-bc6f-f91ff6ce0994	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
563515c9-32fb-44b6-a303-8427417cd9c8	ff731d54-84cc-4c10-83c5-8ebd29aabe88	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
81e929d9-85d1-4697-a43a-8559cf6d2cf0	6bb6e8ba-95f7-49ee-b8d6-fc7a0826557f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
49bc3522-75de-4f7a-b3f2-679285b578e2	65730d88-40bb-4148-b6f0-79b4fd701058	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a532e1e4-3eb0-4c7f-ba98-382afc4b9808	429929ae-6fd3-45ff-8864-cb860d5e8887	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
433539ad-d279-4ffd-b778-cce5ceded3a3	c2ed96f6-1b19-4611-9b4f-e4d8fa146e67	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b56975b6-7460-4183-8ed2-208c27b57e0f	4c20af85-1400-4cf2-ab32-c98a56f22e4d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6f8b3b80-26a6-414d-996a-fb9e3997ed02	6f2d4a19-76cd-4588-a723-18628f7ee13a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1c63a85e-1b85-44d6-a030-160f009c8658	511b5e73-6af8-4a51-af7b-6d8682eef3de	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
097e9c38-8ac8-4428-a3ec-468d9603d428	48f29c6a-73a8-4476-8d96-5f145f3cf530	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4b573fbf-955a-4b30-9f74-55d730fbb597	9ae80c20-c9c2-49c2-b4f4-2df1237738b8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fbc0e324-5352-4cca-8238-d266147c4772	02954b7a-debd-46fc-878b-0e473e8772bc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6a294467-1178-44b2-b3b4-556322a1b13e	1fb012b8-ed76-499e-87b2-f26f6aaf8da1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f81bfadf-6632-4baa-a539-19a2e3e6b3f7	5f40315c-e948-4f0c-9df7-81bffebdefc8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e6114cba-2503-46bd-a8a7-b7291c6635a6	12063df3-83f1-4bfd-a597-91609cf6a566	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a9511082-f98d-4c13-95ca-53cb6d7ecb62	170036f2-59cb-4ae2-9f35-71f5ca3aded6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e19d4f14-ee4a-466e-8f9f-c6429ec0fa35	78f18639-860e-4bd3-a755-78ca2f1f4c1e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b54ba154-8792-49e7-903d-ab4620147a9e	02806910-0c69-4bd4-be76-cc5d68773070	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
abc48705-c533-476f-8854-c9aeed6020f9	b1fa05ae-990b-415e-bfb6-c7b7581215e2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
65ccbe12-0607-41be-9ee0-7238f388775a	dfe2f714-f4dd-44ff-8881-66ff09f27d59	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
60ffce2b-d2c7-4eaf-8267-d2e979d17802	4c08c52f-403e-4ba3-a439-9af336feadb9	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0471f240-122c-4a12-91e0-d71c393fd2b0	47ff8fdb-2002-4ce0-adc2-f7a4eaeac61d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
250b466d-44a4-415d-9d80-437d1e348a61	4ceef052-4a77-42c0-bcaa-196605be5275	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fa0f371b-1e43-4848-9732-7b6d1b1368f6	67b38ca6-3e44-493f-a1e8-c0403620e7b1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1cc5f42d-9241-4a29-9aa7-42f756326d2e	b8f63046-1789-4cfb-899d-f5a59e547a11	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
35a08a68-3b0f-49b1-a10c-9c74cd7530e9	673c3714-64f7-4326-8861-2a14eec01f90	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
91d94cd7-02b8-4a9b-9749-288bc0e275a4	fe85fd1e-4616-4055-86ca-6ec25e0c1d5f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7d62dcf9-a0fb-4124-abf6-c0cdfdce2888	f8550bcb-3568-4189-b35a-578ae9f0ba90	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a31f4a9d-efd7-42f5-86a9-4989c461d66a	f60349df-2a56-4c44-a78e-2a9f99cacf8f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9341fbe7-bbd8-4055-972b-9a73a75e76ed	19f171e3-eb72-4e87-a0e2-3a048f2dba6d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
668eceae-4e91-4718-bc46-8d250470764d	c75826ce-460f-4fbe-9e69-5e5421c321e9	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
11f49b15-93f1-4eda-ad1a-d9135eb910b1	67930c50-abd5-4219-84b5-f8b8d2a585f7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9834d0f7-4e58-4f04-aed7-c81236e40126	8679bbaf-656a-46f8-a97b-d5576fe89552	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f6fd1bd5-2d95-49d9-98ac-36cdbcdec0ed	cb712e11-caf0-4902-ac85-e022817dc31c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ac8cddde-b618-42a5-bdae-fa9c3a7b08a2	4647afec-f1fa-469d-bf1c-ee5bf0629d75	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b0004f03-7905-44d5-814e-1764bb45ed0e	80201c59-2aaf-42b3-a5e4-2a6d82810c66	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a2cf0363-a14b-47f8-89aa-f681135637e9	0d9d191f-fe83-4f87-bfde-324b869bff73	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
172bb906-84da-4157-9e3e-72333fc3797d	48c6917b-27f1-44b8-80a7-fbc595b23e60	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
43e160c0-72c6-419e-8666-9e6c2c289e5f	43378f0d-4cbe-460a-8f14-be874269cd24	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e0b55e37-e7e6-4829-b13f-ab791c6f4065	e3c8835b-9d5c-4e5c-b723-c961592cb7cf	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
09a7a156-a53e-4c99-8438-7ca83f8407ac	9cadec4f-20a3-4c95-afc6-546573e76a1d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5294ebd1-b67f-4ce3-9618-410cdce6b88d	237cce96-2a25-44a6-9087-088c8cd9681f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
45609fc0-a7a3-418f-ba42-f2bfb44bdc99	cb75a35a-9173-4ddb-9b79-8b8ac682b055	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e125d08b-bbe4-46f0-ac81-34a19dc74b66	eb3102b2-3d1c-439a-bfa4-aab63d1a63a6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
47b4e4d9-d205-44ee-a377-4b75c9a45120	7e4e9a26-9c8c-490f-93db-ee3294b224e2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0e97d035-15e9-405c-800b-d843ace44d04	db95200f-9b6e-42dd-b667-6de669ac81df	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e72bdb1f-8b42-412f-b85b-9ccc899e670d	05746d44-a338-4c09-b7ec-e86404e873d6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b9bf20a0-6439-416b-a43c-79bdd6fe68b3	d049f6b7-b4d0-4dd1-93b0-547371f68cc1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bbbf75e1-21f1-41df-9fb8-5ec51344f3f2	6354704d-03d4-4701-b2db-af8b87537fec	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d1f11405-d23c-4135-abb5-f929a19084a7	3cb11040-f0d0-4b48-b0cb-d7a160501651	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
614c44bf-b66c-46b0-a034-860997aa05d5	a2f18333-8cc9-4a6b-8fb7-b5bccf33bd8c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
83fc86a9-e771-49b9-af5c-d8d93abbdce8	ff90f6ac-ef43-4191-9422-238780834d1e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
461f71f1-5db5-42cb-9546-6acbcbf3e1b6	8e82e03f-d2af-4d77-9208-712cfeb46a55	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
17e01557-a715-4369-9e06-07933a7fdef9	0e458a7c-16b1-4a24-91b4-d5a14d80531f	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
62bfa97c-2c1d-4d71-8dc7-b1ae213b3c19	911fbc88-8b11-43d0-a25d-ba4a6e864c52	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6b750374-f5e7-42cf-8233-12798b663694	dd6fc047-4171-418e-8196-963af8e669cf	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
69868468-4f9e-4f11-b787-eca4627643f5	b34a5dd4-0c65-4565-b70a-064bac701bd6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
da08147f-e561-4fd2-9b16-0dc598af342b	acf1bea6-8a44-4a6c-8267-73d526421fd1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5f2bb384-edf9-4b9d-89d9-e9652051a912	df57e0ce-5a84-466b-ac69-f7212f665baf	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
37db6546-12af-4f16-9eb4-882b2c212075	661008cf-01e0-4e94-8a69-0b055e5fc437	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
26ad8cb3-a76d-4d91-8c88-e4ea105565c0	68b4477c-062c-4405-bbd7-1c9360a6f02b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
20653ba2-705d-430e-96c4-f03f33c91a6f	829b354f-74a0-4e7d-9699-86bce6d73971	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9c527016-e333-4167-8cff-1d2c6b443d0a	d756e58e-9c8f-408f-ab6b-9cedac05677e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
86a2a85e-e85d-4b4a-a95c-f3ab858c00ae	0e2c3acd-83f8-49d9-b619-ad184cb79062	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a2c9e59e-c215-4d35-9408-079976f375fa	21b5e364-8c29-40d8-b0b4-e1c593fbd100	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7a5a80b4-96e8-4bad-ad3c-bf74dff200e6	3a5447bd-9328-40cb-8309-0b525fb6561c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bac5f677-e525-4084-b85a-d99813e5e68f	d401d21a-ffc3-4264-a3dc-5418885c28b5	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
87932290-c9b5-4c07-9b9e-192a3b814377	2a5ab4bc-301f-43ab-bab9-07261789f1d5	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a9fccdca-6007-4f57-b047-28b1c054b364	58335189-c317-4a94-b73d-0f9a279d5114	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9b143816-5cc6-4e1d-b2b5-db0ab94943d3	8bef6f81-a5ee-4167-871a-25743225e935	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0adfcb5c-2694-4686-827f-9bde61beb8f6	6dda9806-1e48-45e2-9d1b-b32aecdd0e5b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c5e32a98-e908-4a4c-8bdf-0dc63afe6f91	f4b0e40e-8ab3-4f6c-8225-635403b8697e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
457c3647-2c43-43f7-b9e4-1836a8accc1c	06a039ed-d687-446a-b976-4c6b4e4e6490	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c632ea9b-1e71-4da8-be6f-55b543e60df6	b09c3ebd-3d18-4f60-8fde-35c27aece9b2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6eaf5aac-5606-46ec-8e32-1d2ea53b6759	1e4b258d-4566-46b9-a75d-26b30c416f6d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0b13b166-ba35-418a-8073-f60fded38db4	4786e835-9531-4439-9178-be53a028bb8e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2e59e070-3abf-430a-83ad-c34e3eeed536	e534a6c1-4648-4d6d-8093-7d3ed9b755d1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
61e06565-0842-45a4-8749-60f73a89a30e	3fcd45c0-2ebf-4aec-9852-69354d528ef0	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e1984b60-b05d-43a4-be47-7e54a36286de	c31652a9-a4f1-49c8-bb20-7922ad4a5cf8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
580921c7-0c4a-4d6a-a164-033977348b56	0e42696d-7d9d-431f-9c8a-d35dd28ef28c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
08b51ad6-4b11-41ef-b44a-85f8c1a328f8	d2d88c04-8dcb-4563-9d91-df82739afad5	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2f418d8c-ea01-4e48-be76-26188728aad9	6354fa39-6abe-4110-ae8c-f7f1ace03464	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
594d476e-d3b8-4a1b-b947-f3c7dd2fb238	88fc8b2e-2826-403f-b59f-5aa04bdfd3f6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
830ba80f-ab68-4856-bf70-c8370e558a50	b30f799e-e0b8-4ffa-aad1-7367471f37ec	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
42ae2705-3650-41ad-8557-98530cc77957	c419ab2f-94ff-40fc-bc92-f6bb0dfa168b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fab8c1a1-b053-4d56-b5dd-e73feca13814	572644a2-8969-47d2-8668-2040d87e6810	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3eb4277a-7853-4f37-aaae-f6b42b88cb76	41189dd6-a33f-41eb-b1b1-63cce6686e78	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
98f159a8-e679-491c-ae7f-f161796f7e6f	7becd68a-d6ad-4ab2-a321-38585bba0861	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bdd891b7-c8f5-4f05-b93d-28b046c7ad6d	aada935b-6d51-45b9-b482-92aad4915f3e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0efc1b63-a226-4d5a-8034-ddd817d2fe44	fcf925b4-5462-4287-b7b9-6e531a697ac6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4eb64ce3-c1d3-4b18-9341-5d22c5be2945	e9a261b2-a2ce-49ad-8324-7167a6aaa2ea	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
30727ff6-7e2e-440d-a8fd-244553599891	8e4c0e42-5212-4511-8208-47ea0fb53c32	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ceacd105-cb2b-4901-a20b-48a764c07b88	5cb7d536-a165-4157-acfe-3458485cea16	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7f905890-72f4-4966-b297-9fd9356e41fe	e56f76de-2603-4576-92f7-a60a656ff476	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
97cf823e-cbee-486d-b8f1-ed770a7df88d	6fa30a81-4a64-4ca8-a465-9883df845f6a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3adf5083-f3d2-4251-a3d2-e5bd57de9f38	07b1a694-3efd-4578-b83a-801778a41ab3	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
82f260e1-3880-40bc-8271-bc652f32af64	3a508f9c-fe12-4915-a505-3cb90ff62574	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6a3d6445-fb04-4f19-97d7-c4299560e779	a9f7e848-d864-4379-8815-63001482e928	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2326e1d7-da72-42e7-91a4-48a412ade3c6	157a7fa4-c21b-41db-8c80-7948d60df2a7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1f47fc16-b31b-4605-b7ba-e57ed6a7dcae	3552b34f-39c7-481e-acc7-1cae13e118a8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ba314667-746a-4ad3-af5a-546aae166b49	8199b999-ffa4-4310-9c40-9cbe5e3f87fb	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ab251bf9-1cb0-4c1c-8abe-01511bc59ad8	66223147-6e64-4365-bc27-da34c56f2951	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3b011915-4c08-4d6f-b785-ba560c86e275	183da1c6-12e0-4518-b11a-d3cb6dadcc06	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e8eb401f-5eb9-4b76-a93d-b6bd91adee08	fef2a0bf-0792-4f6a-84cd-1692331e8bba	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
910f4403-e42a-4f61-8db9-daae2bb56bef	7711bc2e-06b3-4213-8101-e2b596948cc1	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b0aa29d6-a6c1-44c1-ab0e-69f43a91ac58	680b1a4f-f30e-4d21-8589-5f8bb6b5e440	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6df4c389-b930-4641-ac16-7ee3f4a53e73	02710e01-e36e-4de5-bb6c-4b82ba1827a4	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
629ecc62-b715-43eb-8d88-94182cbf4861	b1cfd1cd-12eb-45b5-84b8-ab62420766d5	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
759dc6b4-f67e-4d02-9ff9-de9c75640ad7	b37013b1-3320-49a0-9821-57bb4829569a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
861bc8fc-ace6-4cbc-977a-a99486df5d17	8367eab2-4d9d-460b-8d6c-900e8222b71c	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
60d2224c-760c-4686-baad-fad6edcfb976	0dd94a91-fd9b-4f2f-a9f9-59f3922621a0	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b7f50b1e-87cf-427c-a1bd-315716c37b1e	65fca388-3246-4836-8beb-a80948e5625e	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a43c9e77-2921-4adc-a80b-9dd5844392b0	14aec9c8-27e7-43be-9359-22893434f967	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f048cf95-fbd6-4794-85b5-b8022c9c5960	46378e14-1401-4106-bbd6-862e69a24372	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
22de9795-3a91-48c8-9dfc-91d3a76a129e	ad1c6542-3842-41e3-9b42-0c4949ba04c2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e1bdbef8-a3c5-421a-93b4-2b4e0b3fb42b	25a26696-278a-47ea-9a1f-e71a4f49c996	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b1dbf533-a7b0-4aa6-8ee8-46b6330bc60e	b9e809fc-f72b-4525-a495-955b66b93866	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2f462dfc-1d11-45bb-9a78-18eca84e773b	ff1548de-da7f-4967-953f-b94a9c1a91f6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ca0cbf4b-4981-44be-8682-058fb03b211d	bcc2a352-2b35-4715-8dec-4abe46710047	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f9aa6acf-bd44-4e77-a162-1d22de1a66eb	b3ad631e-30bd-40e5-afde-830ea19aa5cb	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
35ff4a6c-56c9-46bb-8e04-2e893bb3ddd5	f3aaf5de-830e-4844-acc0-41251b71ee80	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cd704f6f-bac6-4722-9807-4a07ac21b36c	7a116c6b-e0a9-4ab7-a393-dea196259615	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a682130a-f7c7-4a3e-8247-a180603a4251	8ce5fb5a-b906-432d-a445-c58489a043af	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fac6f0b3-67aa-487f-ae19-14eb21f90530	505b0ddc-6170-4daa-b308-14551188993d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f15558d0-171b-42f6-93b0-4f2c7853984b	4d05e2f2-e8f8-49bb-a936-60b37e425319	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dd4755a6-58e2-4163-9e28-531e2d529673	f231598d-1b94-4f7e-986b-20e2ddfbd7f8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5ae51704-3b39-40d7-879c-0970d6215982	c2a03428-3d2d-42d6-9889-db4d1d0e5f32	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5ec91873-aea6-4048-b804-41aab0543cf9	ee827e8d-2989-43c8-944d-deee56487123	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e6d1cae7-7c77-4291-a2ce-cc65ba5ab724	95635597-98e7-4e05-bfe8-83b300d201e6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2053184b-918d-4d54-9088-1f9f070ad23e	718e5531-4bb8-416c-afeb-920ff640a5e0	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fec3b4a6-7df3-41a4-bd00-a12711e582d2	42d9ded2-63ad-4d63-8734-20935207d4b3	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b101efdf-7cbb-4108-b991-46d63f5a8835	a5c29ead-95e2-42ba-ac86-c92f705b0286	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4675810d-1061-4fef-80ea-0a1e4d6da114	91026fe5-860c-4e96-a95f-78e62d61f5a5	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
284a08fd-1224-4719-b0e7-9f64eb674800	9764a374-e546-46b5-a3e0-e14f82763dc6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
591f9e75-758f-4b2d-be63-9e86e5a0e3b2	f65e9d64-a998-4b13-8595-2103140d78c2	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a69734cc-d3df-43ab-a9af-0330bece0d22	21d6454f-6946-4c87-b92c-fc08e651b01b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8d4c8cc3-4aed-49aa-9845-4cbf4be6bed2	7fee5271-f320-4514-a4e9-36658d4fa7b8	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
42364e13-5ea5-4727-afab-98a08ad12464	10d2e400-7a41-4c5c-8aca-77ee4be2e5eb	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4238c8a3-687d-43cb-a4d9-308260f318a8	cd4fa579-dd3b-466c-a534-07118221213b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4bff70c3-703d-4c01-b9e7-784fd88419c8	2dedd94b-a613-4206-b614-a3f778543092	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c980fd16-533e-4637-bdf3-93cf671ad659	23f6542a-0dcd-494c-b1d5-119d351b812d	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
41637f07-cbc0-49b1-bdb6-c3942fdab244	df1676ae-890f-4323-9b50-52245b9507d6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9730ebd8-b32c-4a68-b364-e2c3a330a11d	e47037d4-9273-4b7f-a20f-36d6eee73a5b	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3434cb53-ecce-4860-916f-f0ba6e5ccfd4	c37bc237-38d3-486f-b6c5-fd47dd7e10fc	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3a1a352a-4a5a-4fd2-b5a0-b033f367ceed	397990bf-418c-43d0-8db6-55b3f91ac10a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
94b64757-9e53-4503-8b27-100afdd95af1	9fc3454c-df0b-4266-9a82-c0d59d353bea	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4937d681-8070-41dd-9d5b-212842a213a2	6188661d-7503-4be3-832c-8126c56e81e6	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
72fc606b-ee87-4d2e-bbfc-721b7e6f1366	609397c2-5bef-4291-8185-b0fddb941eb7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
851c0ddb-bf03-4977-9bce-799af3bf3a0c	60d76a25-f62b-4d18-92c0-8d6768fcc277	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
df5bc377-9ae1-4803-9a09-e6b43e5dca56	b07409dc-d181-45fe-9ee3-9b1738684175	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a1d1a6e6-1e2d-4b83-83b1-d354be91d16e	6b98797a-d2f5-482f-99ab-425e3331b7b5	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a950f7a4-96ed-43e9-ab61-4c271d75fde3	e243d6f4-1c39-4fab-a80c-f917b8574856	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d5fa9638-27cb-45a2-a182-46d5bfa63c70	d6971a47-b2ba-4124-b2b9-aa8cfbc1fcf7	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f788b8e2-1221-41e3-9da6-c9b362dd4fce	1a4174d1-b732-4b2d-b7fc-535aff8831c0	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5f663c38-70fd-40fe-b298-6b86e3e5c49c	5c2489a4-207a-4d8d-bc06-417b68cdf635	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ebe295e2-0b42-4ebf-be7d-99d3ab6f976d	bacd9372-1fb3-4881-9a16-d5c35b37c53a	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bd663887-471b-4bda-8887-16ae560d0110	f84ff60b-768e-4144-ab70-0816ddd29830	SEED-SEP-2026	SEED-SEP-2026-TASK	September sample timesheet	Sample delivery	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8f9cf3c2-e683-4fd3-ad98-e780b10ddc4a	10c038fe-200f-4509-8e0b-1f6ba694ea57	89744e80-08e3-4f7c-a4ba-78ff0ce54634	08e951a4-6ec6-46c9-ba95-f0ed087d2b17	Aditya Birla(Aditya Birla_Finance)_AWS Security Assessment_01	Task 01 · AWS Security Assessment	\N	2026-10-18 09:54:18.991527+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
1b355d0e-947b-41ff-8e70-68808ab3a771	d8b33348-0501-4b4f-974a-b15535a9bd9f	89744e80-08e3-4f7c-a4ba-78ff0ce54634	08e951a4-6ec6-46c9-ba95-f0ed087d2b17	Aditya Birla(Aditya Birla_Finance)_AWS Security Assessment_01	Task 01 · AWS Security Assessment	\N	2026-10-20 08:55:19.480826+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
b041ac7a-d02e-4d16-a0b1-adcb63f328f4	b7d53977-e4c9-4db6-aee4-e6167fb95e32	89744e80-08e3-4f7c-a4ba-78ff0ce54634	08e951a4-6ec6-46c9-ba95-f0ed087d2b17	Aditya Birla(Aditya Birla_Finance)_AWS Security Assessment_01	Task 01 · AWS Security Assessment	\N	2026-10-20 08:55:26.948643+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: tbl_timesheet_entry_days; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_timesheet_entry_days ("Id", "TimesheetEntryId", "DayIndex", "Hours", "Comment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
04671555-d091-4d41-837b-97d705be6919	848b75ec-655f-4918-8fe3-78b6b6a66253	0	0.0	\N	2026-10-17 12:01:20.152448+00	2026-10-18 09:54:18.949044+00	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 09:54:18.949044+00
06515d7e-7cb4-44d2-a9cc-679d0ecbfee4	848b75ec-655f-4918-8fe3-78b6b6a66253	2	0.0	\N	2026-10-17 12:01:20.152448+00	2026-10-18 09:54:18.949044+00	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 09:54:18.949044+00
10c9fe42-9744-4979-9fad-e73270a8ef44	848b75ec-655f-4918-8fe3-78b6b6a66253	1	0.0	\N	2026-10-17 12:01:20.152448+00	2026-10-18 09:54:18.949044+00	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 09:54:18.949044+00
32984279-b472-4f45-9a47-d862440a2e7b	848b75ec-655f-4918-8fe3-78b6b6a66253	5	0.0	\N	2026-10-17 12:01:20.152448+00	2026-10-18 09:54:18.949044+00	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 09:54:18.949044+00
81a48e62-2e64-4329-8db6-963ee1e61395	848b75ec-655f-4918-8fe3-78b6b6a66253	4	0.0	\N	2026-10-17 12:01:20.152448+00	2026-10-18 09:54:18.949044+00	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 09:54:18.949044+00
c82cf650-d502-4a30-9e97-ef1a6ef5f1f6	848b75ec-655f-4918-8fe3-78b6b6a66253	3	0.0	\N	2026-10-17 12:01:20.152448+00	2026-10-18 09:54:18.949044+00	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 09:54:18.949044+00
d43dfd6d-4668-4cc3-8ee2-9bc169dcd3b0	848b75ec-655f-4918-8fe3-78b6b6a66253	6	0.0	\N	2026-10-17 12:01:20.152448+00	2026-10-18 09:54:18.949044+00	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 09:54:18.949044+00
09091543-0616-460a-875d-8ed4343bae83	8f9cf3c2-e683-4fd3-ad98-e780b10ddc4a	1	0.0	\N	2026-10-18 09:54:18.991527+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
1af561fb-560e-43e7-bb6b-65685695849b	8f9cf3c2-e683-4fd3-ad98-e780b10ddc4a	4	0.0	\N	2026-10-18 09:54:18.991527+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
4e242ec7-ccb2-4dad-9131-0aa8c2979ffd	8f9cf3c2-e683-4fd3-ad98-e780b10ddc4a	6	1.0	Done	2026-10-18 09:54:18.991527+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
67105252-81ae-44ad-9e2d-fc5f63bd8659	8f9cf3c2-e683-4fd3-ad98-e780b10ddc4a	2	0.0	\N	2026-10-18 09:54:18.991527+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
ad2b0bfa-e349-4f83-aad0-46fd465a03cf	8f9cf3c2-e683-4fd3-ad98-e780b10ddc4a	0	0.0	\N	2026-10-18 09:54:18.991527+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
b8953163-6227-4f99-b159-28f8a6f5298b	8f9cf3c2-e683-4fd3-ad98-e780b10ddc4a	3	0.0	\N	2026-10-18 09:54:18.991527+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
d9721616-56e4-4e4d-b54e-226e90006fb0	8f9cf3c2-e683-4fd3-ad98-e780b10ddc4a	5	0.0	\N	2026-10-18 09:54:18.991527+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
236d4016-23ef-45fa-8616-3a379c827148	1b355d0e-947b-41ff-8e70-68808ab3a771	5	0.0	\N	2026-10-20 08:55:19.480826+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
4a1005c7-5364-439f-a012-5a400d0778a5	1b355d0e-947b-41ff-8e70-68808ab3a771	1	0.0	\N	2026-10-20 08:55:19.480826+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
8f2a2113-6c62-44d6-9e54-cf800b3e835e	1b355d0e-947b-41ff-8e70-68808ab3a771	2	0.0	\N	2026-10-20 08:55:19.480826+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
b000ecc1-a474-42c5-9c50-4be6878adbbd	1b355d0e-947b-41ff-8e70-68808ab3a771	4	0.0	\N	2026-10-20 08:55:19.480826+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
b60c4aea-bacf-4966-b894-85b37dba836f	1b355d0e-947b-41ff-8e70-68808ab3a771	6	1.0	Done	2026-10-20 08:55:19.480826+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
b6b67a9e-853e-428c-a931-da4997547a0e	1b355d0e-947b-41ff-8e70-68808ab3a771	3	0.0	\N	2026-10-20 08:55:19.480826+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
da8f956e-9cba-4fdd-90be-7de1660bcc4c	1b355d0e-947b-41ff-8e70-68808ab3a771	0	0.0	\N	2026-10-20 08:55:19.480826+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
9d72b249-be05-4528-b29d-8f3d5bb2af91	ab251bf9-1cb0-4c1c-8abe-01511bc59ad8	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9cb80632-1a08-404a-9b16-70cc344e9b5d	da03121f-5268-4ffd-b818-22f5a6f2aed5	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
037379b8-0a5e-4d8a-929b-2e313b33f61b	3c83285a-3c43-4dda-b061-4fbc6df3f50b	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bc0aebfe-957d-4ff2-a409-01fbeec6363a	43e160c0-72c6-419e-8666-9e6c2c289e5f	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2364b970-8d70-4627-83c5-4b7f80734c91	8314107b-94e2-48e9-ac2a-a6931c1f24b6	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7ec2849f-b58b-4819-b515-445b7195a5e7	4bff70c3-703d-4c01-b9e7-784fd88419c8	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
17965c52-a59d-454d-ab74-cde67f7ec550	3adf5083-f3d2-4251-a3d2-e5bd57de9f38	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
15e45973-1694-4105-9aa7-ffb821173dad	a1d1a6e6-1e2d-4b83-83b1-d354be91d16e	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
819bfdcd-0ff4-416a-9649-71bdae59645b	54e3957e-6316-4561-a859-be9facb8b098	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
79769ac8-4b1e-4ab1-9d88-c814deb139b6	7ea48f10-8b81-49b1-9eb8-09261d123c99	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e19aafb2-14fd-4a39-9d7e-6aa7bd5dc3d9	461f71f1-5db5-42cb-9546-6acbcbf3e1b6	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
55e88641-9b80-413c-a18e-bd1500e21193	457c3647-2c43-43f7-b9e4-1836a8accc1c	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e770f938-41b3-4587-94a4-ee11580da1f8	2326e1d7-da72-42e7-91a4-48a412ade3c6	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ca6f01b3-3371-4a8d-b685-11c099438852	a2c9e59e-c215-4d35-9408-079976f375fa	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6b51ba6c-7c6a-438d-8b24-ddef9c199b43	3e22569c-5007-4b63-946b-5daba5f8f153	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d0a4d816-1b09-4786-81d4-23cd1022ec1b	cdb0f946-0f24-4c12-b289-9c84aa234b33	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
712840c8-42fb-4ae6-af3d-ee70a1896888	a9511082-f98d-4c13-95ca-53cb6d7ecb62	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c8acddae-a277-48e1-8f55-56cb0c7bac16	db59b929-a805-4fbf-a590-998bc9e34a04	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9ce13ca2-8717-47e6-b207-8bba2f0298d1	fec3b4a6-7df3-41a4-bd00-a12711e582d2	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
50148eff-9846-4c6e-9b24-82693c281033	49cb95a5-2686-453b-ab99-17f6c6bdbefd	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
966b9531-05d5-4c46-b77e-e90a8ac100e6	db233fb6-f8a9-4008-b771-4a561e7638cf	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6f0ec7c6-8daf-4c7f-a7dd-f8209af1b559	0a9a4607-0ebd-439e-b422-c0cbaf41c974	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1d4fa3c1-a90e-49b4-9653-68ad16a839da	3434cb53-ecce-4860-916f-f0ba6e5ccfd4	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e76fddeb-1850-4cab-b9e5-f4c649036520	dab0bfe5-3d36-4a40-b618-f776119083a2	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f9fcc5b2-57ef-4a2e-8974-61b6a8e37e12	b3f7a38d-8e12-44c5-ad76-b668fb0c27f7	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1dd634cd-9968-49e9-b996-aa463eba79a3	b5094b08-26f8-4a63-a4b5-7ebc35f7ccf7	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b7343823-0580-4efe-9b8c-4c180d3022cc	2053184b-918d-4d54-9088-1f9f070ad23e	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
eee0c053-28a2-4b67-b853-096f01dbc804	bdd891b7-c8f5-4f05-b93d-28b046c7ad6d	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
10418396-7376-48d2-a5dc-3a63cf3b39db	5e609a43-1324-4be4-8b26-19b6cafbbdfa	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3687975a-a1cd-408e-9918-066b9e49c8f5	15435e98-1f3d-4080-91d7-833fb8dc6bfe	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3dd628d5-fd6c-4db3-900b-00b7cc5efac8	bd663887-471b-4bda-8887-16ae560d0110	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
11bf4b45-cc69-42d8-8691-4ab141b3c6b4	7f905890-72f4-4966-b297-9fd9356e41fe	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fe84b6e9-5525-41fd-b4a6-acaa7bf688bb	9730ebd8-b32c-4a68-b364-e2c3a330a11d	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a0146e6a-fcd3-4194-aaa8-16a9ceff1e66	60d2224c-760c-4686-baad-fad6edcfb976	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7fbebbd4-a8e7-412b-ba11-a7cadaeea70b	38ecdea1-cdb9-4bcf-8c52-cc12b0963056	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d18d8e6f-4dce-4a9d-aa69-2bddb23cd877	cd9c6fe9-9cd4-4c4b-b1c5-cfd464e35af6	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
79ce402d-cb6e-43f4-9aeb-2836e8c4484c	5dc08f8e-42cc-4d1e-b92d-664860a5ea3a	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f2a633f6-0125-46a2-92c5-a90f93d34286	6de552d8-0aea-4206-9fa0-0841efa1919e	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
599a488e-e24e-4aa6-a430-95bbb1992435	f17c8d9c-ed11-462a-b495-aaa867b9b2e0	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4ce57a82-7b7f-42a8-86c0-fed623c21ce1	cc242357-2f2a-4baa-b9cd-5b564c2d7575	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fa04eb25-ff17-4564-b97d-d3021242f2fc	5a13f1fa-61be-43bd-8e59-920b764fd7ee	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5cec99f5-5e25-4cbf-9210-15dcef3962b2	a7cc7861-d636-4e14-b9e5-9e68b666a2c3	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cc4c7de8-a7c0-42e9-b6cd-aa7c08767450	6b750374-f5e7-42cf-8233-12798b663694	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
25d5cce8-d38f-44b2-93e7-1109798cc576	d4d97af8-6d68-4c72-9bc9-a51dde24c51e	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e3cbe702-f8de-4960-b1f7-7ef6242c6a80	23892fae-b486-48e3-b5d6-17013bdfda2f	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9c065e80-b8ab-4028-a630-26580f446328	d5fa9638-27cb-45a2-a182-46d5bfa63c70	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b9f8215f-fe95-463d-8b7a-7ced912f2f73	9b143816-5cc6-4e1d-b2b5-db0ab94943d3	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ebd98975-59d8-4b22-83de-d12cfee502b3	865d1f01-8e7b-4f2b-bd29-ff95c5f44cdb	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8084d3c4-f1d6-49e3-91a5-471644f3d044	ca0fca40-563d-4416-97fd-fc3c91d99f6d	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4cb88792-de34-442a-b9a0-bb27a3d163a5	927f123d-bec5-485a-8c31-c432a6b0ddc1	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3ed03a54-0530-48e6-a511-8869e29c4989	98f159a8-e679-491c-ae7f-f161796f7e6f	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4f3b5d7a-61e4-499e-a2a2-afb17252acef	11f49b15-93f1-4eda-ad1a-d9135eb910b1	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d771c274-1756-4159-a710-ec4c752aa437	40828885-c5ee-49f3-9f8b-5fefb11f5981	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3f026271-9222-475b-a72e-aa70c5ca0b68	24ccdfcf-c471-4e70-93f0-1743280fb76d	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fb424ba4-0246-4fd4-b30f-444c2b7e8bc9	732d0320-c065-4bf0-a5c7-8323807b9ccb	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f0a7819b-b0db-4f7f-a87f-1937414bfa3b	f9aa6acf-bd44-4e77-a162-1d22de1a66eb	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
99d47e11-6ba4-4800-b3d2-77037e108a6d	580921c7-0c4a-4d6a-a164-033977348b56	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e3aede1f-8851-4417-abab-f2ba96cd17ab	e67ac562-fc06-4b29-8a51-6c9099441197	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8851a9b2-dbda-4dea-b36d-73529429b690	42ae2705-3650-41ad-8557-98530cc77957	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
008f6f60-3608-4d37-96f2-49191ced4ade	610d1e31-e825-4989-80fa-bd74d0925d37	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
331013a9-56c6-438b-886e-2305043164a9	b041ac7a-d02e-4d16-a0b1-adcb63f328f4	5	0.0	\N	2026-10-20 08:55:26.948643+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
33e1b2bd-a5d2-4102-b9a6-e943513454a9	b041ac7a-d02e-4d16-a0b1-adcb63f328f4	3	0.0	\N	2026-10-20 08:55:26.948643+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
4d805c5c-2d56-4706-bb41-083df2078193	b041ac7a-d02e-4d16-a0b1-adcb63f328f4	6	0.0	\N	2026-10-20 08:55:26.948643+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
6b51a916-105a-4f83-8474-09e76da914d1	b041ac7a-d02e-4d16-a0b1-adcb63f328f4	4	0.0	\N	2026-10-20 08:55:26.948643+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
7c80a524-ad1f-4c4f-a9be-3b7b75ad0fb2	b041ac7a-d02e-4d16-a0b1-adcb63f328f4	2	0.0	\N	2026-10-20 08:55:26.948643+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a31974a6-41f3-4567-bad7-6cbc620edfb5	b041ac7a-d02e-4d16-a0b1-adcb63f328f4	0	0.0	\N	2026-10-20 08:55:26.948643+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
dabbfc9f-5b3c-4823-b28b-cc2f16f04ae0	b041ac7a-d02e-4d16-a0b1-adcb63f328f4	1	0.0	\N	2026-10-20 08:55:26.948643+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
61fa5ab9-68b9-4ff0-9632-b6f103cd4627	eb5f26ec-73a6-420f-9ab3-8974185db66b	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
725e63c9-82f3-4f5c-b626-0ea6bb7e932d	750b525b-37f1-456d-92a9-9a0042e896bc	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
76ad45c7-9c09-4f5b-b833-ab53a67320a2	84bfba78-ba41-48e4-bb04-96fe5425f949	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fa9839fa-391e-4ca2-99ad-dc2e9e92fa75	da03121f-5268-4ffd-b818-22f5a6f2aed5	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
848256dd-594b-4cbb-8b5b-41de7d721770	620f48f0-e0bd-4064-8e3f-911c3eae3a42	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b0190b42-f6aa-4345-94b5-b483b860b6b6	43e160c0-72c6-419e-8666-9e6c2c289e5f	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0750c2b5-46ee-4fa6-bc72-b13a216eb366	8314107b-94e2-48e9-ac2a-a6931c1f24b6	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
48cfca18-133c-4279-83f5-41a57808256c	4bff70c3-703d-4c01-b9e7-784fd88419c8	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
16d65a50-0c56-4b96-9504-74d97adf0ce5	3adf5083-f3d2-4251-a3d2-e5bd57de9f38	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4b1d0c38-25c7-4726-8808-5a83ece9d9e8	7ea48f10-8b81-49b1-9eb8-09261d123c99	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e6d5356f-2f1d-4b57-af5f-8b0773786a90	2eddfe04-ee05-4b27-9f10-904b67651966	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
22a88f2c-0d9a-4349-870a-585ff30f42e2	eb4ac256-589d-4b3e-8e02-a6dcdb4fe292	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
21a0bd0b-2120-434e-a17a-8fbb2d3b984b	3e22569c-5007-4b63-946b-5daba5f8f153	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
58e9a807-5128-4137-a6a0-c8b62b4d5329	cdb0f946-0f24-4c12-b289-9c84aa234b33	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
77a893a2-a364-4454-a25c-a97594b86de2	a9511082-f98d-4c13-95ca-53cb6d7ecb62	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dc1e7e14-49c4-4f47-b766-7c53143c9b22	eceb2429-671e-4b06-a11e-3b649004a8b2	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
75748f94-2eed-4056-87de-a8a8a82651ef	fec3b4a6-7df3-41a4-bd00-a12711e582d2	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
66b24f4d-b8b8-4bbf-a466-fd7b91915830	49cb95a5-2686-453b-ab99-17f6c6bdbefd	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
decd502c-9ea3-4373-9790-49c7dd38013a	0a9a4607-0ebd-439e-b422-c0cbaf41c974	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5182f07e-4cad-4a90-9132-59b45d33d6c8	946dae4e-8549-45c3-9311-fac453d22412	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
663b4cc4-2a00-47df-8aca-2d36e6265ee4	3434cb53-ecce-4860-916f-f0ba6e5ccfd4	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
555a6407-e16c-45cc-9bc1-ab9847803279	dab0bfe5-3d36-4a40-b618-f776119083a2	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cac81014-af4b-4a77-8b74-c8e5e672743a	b3f7a38d-8e12-44c5-ad76-b668fb0c27f7	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c781a950-33ca-4bfb-aef4-d34ebda288a4	9c4875bb-a1c0-47aa-98cf-008864b6d1fb	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1d88887a-85d9-4fe5-9fa8-a6d6e34028c0	b5094b08-26f8-4a63-a4b5-7ebc35f7ccf7	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fbb50b20-2556-4922-a752-0c9acd35deaa	2053184b-918d-4d54-9088-1f9f070ad23e	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a108d856-82d5-4f10-8563-c7d901c4fc2f	b7f50b1e-87cf-427c-a1bd-315716c37b1e	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
67fb3dc4-aa67-4029-8e2a-3943a8de9c29	5e609a43-1324-4be4-8b26-19b6cafbbdfa	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f6fb56bd-458a-4c10-b8d9-50c299a407be	15435e98-1f3d-4080-91d7-833fb8dc6bfe	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
064b228a-ccf7-4244-a57d-2817481eb1b1	62bfa97c-2c1d-4d71-8dc7-b1ae213b3c19	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aa729c5b-2288-4424-b9c8-169d8c3a536c	bbbf75e1-21f1-41df-9fb8-5ec51344f3f2	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b6931fe1-6e64-475d-8301-3e5ddfe8b62b	3281f07d-1af0-40e5-9a87-94f541b055ff	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
80415cb2-ae34-4355-993c-9ad0c2ff384a	5dc08f8e-42cc-4d1e-b92d-664860a5ea3a	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fdc449f8-06d9-4f02-9c86-e9e3352ff4bf	6de552d8-0aea-4206-9fa0-0841efa1919e	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9aa1f1e8-eb68-4b04-95fa-49490e894833	0471f240-122c-4a12-91e0-d71c393fd2b0	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
00b47122-9ab4-4908-ad48-f1a148d159ab	cc242357-2f2a-4baa-b9cd-5b564c2d7575	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
af2a7e50-3061-4439-a23f-d9d73cacc4f1	5a13f1fa-61be-43bd-8e59-920b764fd7ee	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2fdae836-4964-4c15-a88b-24a3e70aae84	23892fae-b486-48e3-b5d6-17013bdfda2f	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
56446bfb-25c5-4794-aa50-82ea44aeda9b	0455570e-f43c-4507-ac93-f92ed6c4e0cf	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ac40c486-0ed2-4933-b24d-ee7d3386e49f	865d1f01-8e7b-4f2b-bd29-ff95c5f44cdb	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
edf28180-ea93-436a-a5b2-d391a9997837	927f123d-bec5-485a-8c31-c432a6b0ddc1	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5fbbed9d-cae3-4582-8a38-b1cb3faf9268	61f36935-6a0c-4ee1-a73c-f2d3e91be9a4	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
12557c30-7885-48d3-a2f4-766ee193a6a9	98f159a8-e679-491c-ae7f-f161796f7e6f	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
12e4610e-28be-449c-94f4-75ea79e6870e	11f49b15-93f1-4eda-ad1a-d9135eb910b1	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b24feb40-2ba4-4aad-85e2-1fcc01289a43	40828885-c5ee-49f3-9f8b-5fefb11f5981	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
efc4a267-dad3-44eb-a7b5-48e023f75979	35ff4a6c-56c9-46bb-8e04-2e893bb3ddd5	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5c4a7c71-311a-4a41-824a-d5e8ca28c124	24ccdfcf-c471-4e70-93f0-1743280fb76d	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
97dae2f3-5738-4c1f-8b1e-418e7142d51c	5f663c38-70fd-40fe-b298-6b86e3e5c49c	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bf400274-ec5b-4c79-acfe-4594c36f4d2e	580921c7-0c4a-4d6a-a164-033977348b56	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
678dd517-5a63-4950-a981-e4fd25e08324	10742903-261b-46ad-b814-fefe81479bda	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3e7e83c3-ebc4-42bc-8c95-07e9aa3df7ea	3a225eb1-2b66-49ce-85cb-48399a95fd49	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3591ae8d-a638-4b04-94a2-41a453991c79	42ae2705-3650-41ad-8557-98530cc77957	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b7ac83b5-e9ae-43ad-bfe1-eab81412de68	df5bc377-9ae1-4803-9a09-e6b43e5dca56	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
67606f2d-3fb7-4dd1-bef0-70556088581e	610d1e31-e825-4989-80fa-bd74d0925d37	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0a54550f-0a34-4162-88e6-381c393d2ccc	750b525b-37f1-456d-92a9-9a0042e896bc	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
10b8c584-8efe-449b-9577-b17ab173298b	84bfba78-ba41-48e4-bb04-96fe5425f949	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e4cd97dc-2773-4426-ba94-01cde8426067	da03121f-5268-4ffd-b818-22f5a6f2aed5	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4862a695-79b6-4587-b6c2-e96ec2767ef1	620f48f0-e0bd-4064-8e3f-911c3eae3a42	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1095d858-2aee-4fe8-a336-04aebd6e16e3	4bff70c3-703d-4c01-b9e7-784fd88419c8	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4e737cfd-5ff1-4f05-99e3-5987ecb4e779	3adf5083-f3d2-4251-a3d2-e5bd57de9f38	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dbbc05e7-6667-4886-bf18-29a5843dabe1	a1d1a6e6-1e2d-4b83-83b1-d354be91d16e	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
954bd4a0-eda1-49f6-a375-08caa27d8fa3	54e3957e-6316-4561-a859-be9facb8b098	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3cccaf05-bfed-44b1-ac04-6efb76a9d833	7ea48f10-8b81-49b1-9eb8-09261d123c99	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8dc5a29c-1db1-4ccc-839a-1b220f46dbd2	461f71f1-5db5-42cb-9546-6acbcbf3e1b6	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
21d1aefb-6110-4963-a28e-859519b5f035	12a45543-3202-41f5-89e1-0c7b2b3cfe48	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
41387840-dc94-4d6a-a989-459af04d3aeb	f39d10cd-6314-4d73-9abe-a4505169115c	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7a276f9a-e43e-4c1b-948f-8fa07ed30b08	b976672a-10ca-4b52-96ab-11b2264bd6b8	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e5bf61dd-cfa1-4c71-8909-315af2b10f7a	2eddfe04-ee05-4b27-9f10-904b67651966	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d01ad6a8-8d26-40b0-96c0-b8b222f70c71	a2c9e59e-c215-4d35-9408-079976f375fa	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
604695ef-c154-4096-b6c4-9fdc8f884b78	339c45d6-bdd6-4415-a28b-1b6b8c65ba97	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e1e5dbd0-0d65-4f00-b055-25a7783ac6fa	cdb0f946-0f24-4c12-b289-9c84aa234b33	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
28357670-f302-4470-918b-c689263fbff6	eceb2429-671e-4b06-a11e-3b649004a8b2	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b930e1e6-9660-4aa0-b116-dd2b325e555d	db59b929-a805-4fbf-a590-998bc9e34a04	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fd426812-a2df-439c-b584-e020a89c86da	fec3b4a6-7df3-41a4-bd00-a12711e582d2	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
22e7c8db-5ae4-4458-9d2c-6fa75c520990	0a9a4607-0ebd-439e-b422-c0cbaf41c974	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7d9445b8-d699-4723-b188-9f5c5a60dc05	3434cb53-ecce-4860-916f-f0ba6e5ccfd4	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
19a3d222-4bda-4812-b869-b418046967de	b3f7a38d-8e12-44c5-ad76-b668fb0c27f7	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bc375492-e869-415b-a896-d6d18c7fa7ea	b5094b08-26f8-4a63-a4b5-7ebc35f7ccf7	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
14adf0c1-e8f6-4ccd-802a-28fd48aba03e	b7f50b1e-87cf-427c-a1bd-315716c37b1e	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5089de1c-84eb-4081-8da0-fa5e511abe09	5e609a43-1324-4be4-8b26-19b6cafbbdfa	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
157375d0-a0df-43c3-9b9e-ccfe1c238d67	15435e98-1f3d-4080-91d7-833fb8dc6bfe	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f8c8e819-926e-45e4-be02-03c74e5bc652	7f905890-72f4-4966-b297-9fd9356e41fe	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ed751bb4-eacd-4a94-a583-36e6a53df292	64b4adec-31d8-4c8d-bda3-15787a68f726	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dd2a9bd7-60d0-4b4c-adad-b56b09f68caf	9730ebd8-b32c-4a68-b364-e2c3a330a11d	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8c1bc571-4859-4ed8-8815-2386a5d1061c	60d2224c-760c-4686-baad-fad6edcfb976	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
70132d85-4354-4b6d-837e-8636a6bba32d	38ecdea1-cdb9-4bcf-8c52-cc12b0963056	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c940f7da-87a6-4847-a938-207bbc7a197c	5dc08f8e-42cc-4d1e-b92d-664860a5ea3a	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
be2c7aa4-cf2d-40e5-8a0c-d5b30f7cd749	6de552d8-0aea-4206-9fa0-0841efa1919e	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
73441705-267e-4a18-ba4d-1819005d3ef5	a7c9dc41-94ef-4273-abb5-6c60efd7130a	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
18fb2d66-bbf4-4809-99ee-d4a972be7125	0471f240-122c-4a12-91e0-d71c393fd2b0	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5d6d22bc-77bc-47a6-b2d3-df71839d7008	5a13f1fa-61be-43bd-8e59-920b764fd7ee	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ddcd6f73-171e-4809-9a45-aa967462ea6a	d4d97af8-6d68-4c72-9bc9-a51dde24c51e	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
919d0ad2-c936-472a-b45b-6858705233cf	23892fae-b486-48e3-b5d6-17013bdfda2f	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
44b78022-d0c9-4f72-92df-2d7befef6a65	9b143816-5cc6-4e1d-b2b5-db0ab94943d3	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e70bcc1c-ab0c-47ba-b55e-5990148a4ce2	61f36935-6a0c-4ee1-a73c-f2d3e91be9a4	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f181e264-8524-42fb-a372-5ebafae1f2c6	98f159a8-e679-491c-ae7f-f161796f7e6f	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d1bd182e-4760-4e84-bdcc-eb3d5109a91c	11f49b15-93f1-4eda-ad1a-d9135eb910b1	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
75e17d2f-35fe-4d54-bd80-1156a80f2aaa	40828885-c5ee-49f3-9f8b-5fefb11f5981	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
11f056c7-e64c-41bd-b7e8-bceb4a55cc58	0e97d035-15e9-405c-800b-d843ace44d04	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e4eb086d-a6b6-4589-8e52-ade4ad51d983	35ff4a6c-56c9-46bb-8e04-2e893bb3ddd5	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6d3350b5-b8cb-41ca-8d8b-dc5f974420ad	4e0116d8-8c05-4b4c-9fee-5e578cea0194	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b8c439d8-6591-4faf-a240-1c644714b771	24ccdfcf-c471-4e70-93f0-1743280fb76d	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c8e0036f-721c-488e-a86e-31b121fcbeea	732d0320-c065-4bf0-a5c7-8323807b9ccb	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fda9116c-e071-4766-8fd3-041ad2470c6f	5f663c38-70fd-40fe-b298-6b86e3e5c49c	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
83174c2b-3cbf-4a9d-afda-de86b66095d1	580921c7-0c4a-4d6a-a164-033977348b56	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c67435f9-2ee2-4961-9850-63f6a6cadc35	c2d37696-1ddd-4563-a99d-68d3acae1068	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2ecea254-9eef-40fb-9ce3-95c595a1a95d	42ae2705-3650-41ad-8557-98530cc77957	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b5ca7c92-2e57-4ae9-8f59-95de0724828c	d492a6b4-beae-4cdc-a8c0-626fc892dcf9	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
90b98f84-bd77-45d7-a002-a31d48ee42be	610d1e31-e825-4989-80fa-bd74d0925d37	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1cb3c94b-9c66-4f35-8937-bcac44aac11c	eb5f26ec-73a6-420f-9ab3-8974185db66b	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bf742e9e-ca84-45b5-bb2f-6fe1467aaac5	750b525b-37f1-456d-92a9-9a0042e896bc	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e36c617f-690c-4a8e-ad7e-7b7bbc4fbed8	da03121f-5268-4ffd-b818-22f5a6f2aed5	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fefb1b6b-260a-4018-b113-a78aac016082	822a6a64-ec8c-42f2-9097-f3e9e01aa7dc	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0660005b-df33-4eb4-aea5-1c2336c37f36	43e160c0-72c6-419e-8666-9e6c2c289e5f	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
62ccb3c3-d5cc-4d1c-8bd3-8428295c2679	8314107b-94e2-48e9-ac2a-a6931c1f24b6	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7e997e88-bc8a-4401-aa05-ad01e98fdb90	4bff70c3-703d-4c01-b9e7-784fd88419c8	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
34c44a55-7d6e-42f1-8b66-ea71796214b0	766e554e-71a5-485e-a5cb-9a045db3f9fa	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5e155aa4-b961-4885-b8f1-ecae7d221068	3adf5083-f3d2-4251-a3d2-e5bd57de9f38	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5c2da068-4092-443b-910a-a1a4415ace48	a1d1a6e6-1e2d-4b83-83b1-d354be91d16e	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a750fabd-becb-4c4c-916b-4c2814fff9e8	54e3957e-6316-4561-a859-be9facb8b098	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8c7275e4-aa15-4b8a-a76b-260f4b10399e	7ea48f10-8b81-49b1-9eb8-09261d123c99	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
12e08c7b-f000-4f3c-a94a-9ad9d85b6719	461f71f1-5db5-42cb-9546-6acbcbf3e1b6	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a7bfa83a-731f-4c4f-b352-71320c58377a	2eddfe04-ee05-4b27-9f10-904b67651966	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
293f887e-f3ed-4c5b-859c-4efbf9b70a45	bac5f677-e525-4084-b85a-d99813e5e68f	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0748c75f-669c-4fc4-8316-0cc4634aabf8	3e22569c-5007-4b63-946b-5daba5f8f153	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aad7f4e8-31a1-49ba-8147-9638c4b09193	cdb0f946-0f24-4c12-b289-9c84aa234b33	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c7da2f96-8db3-4326-a4a1-f644dc72dc15	a9511082-f98d-4c13-95ca-53cb6d7ecb62	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4323f3ae-598f-46b4-80d7-2d614265cd31	b825ab32-356e-41a8-a6f7-4d4b21bb52d4	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2585281c-a19d-43c5-908a-63e59057e9cf	db59b929-a805-4fbf-a590-998bc9e34a04	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7bf1bb7e-365b-4e3c-bb57-b4c2459da977	fec3b4a6-7df3-41a4-bd00-a12711e582d2	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
761794a1-5d00-4ca0-af5a-51e420177fe5	49cb95a5-2686-453b-ab99-17f6c6bdbefd	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
14cfcf8d-7f3d-4b03-bbda-91020aa5efc4	0a9a4607-0ebd-439e-b422-c0cbaf41c974	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6aac201d-0da2-4c9d-86f7-0aa90b6eb74c	3434cb53-ecce-4860-916f-f0ba6e5ccfd4	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e54b4022-1f96-43c2-b5b6-3a38b8c5d728	b3f7a38d-8e12-44c5-ad76-b668fb0c27f7	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4d74e697-5f8a-4a53-bd6e-576dbca0f055	b5094b08-26f8-4a63-a4b5-7ebc35f7ccf7	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
51935c73-22ce-4050-8251-bae644e0f652	bdd891b7-c8f5-4f05-b93d-28b046c7ad6d	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6fbf05d8-4417-4843-bfa7-d791d3d3559b	b7f50b1e-87cf-427c-a1bd-315716c37b1e	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b7ea4a98-01bc-43f0-b399-e69524a05851	5e609a43-1324-4be4-8b26-19b6cafbbdfa	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7f471a20-e78e-4d27-aede-f4c8170ffac1	15435e98-1f3d-4080-91d7-833fb8dc6bfe	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
337f21bd-a2a9-4f51-8e0a-ce67ca8fc89d	62bfa97c-2c1d-4d71-8dc7-b1ae213b3c19	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dc3129a1-7cec-4c96-af6a-4a77d8fbec62	bd663887-471b-4bda-8887-16ae560d0110	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c25225e1-a9c3-49b3-97ab-af5b02f2ed31	7f905890-72f4-4966-b297-9fd9356e41fe	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3490ce31-0117-4f8a-9ba8-1bb5e7e58e02	097dc71d-ea99-479c-bfe0-0e835c2d36b6	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7d746d88-858b-4261-9d82-8f1b4decb395	bbbf75e1-21f1-41df-9fb8-5ec51344f3f2	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f8764457-bc83-45ad-b5bd-7265836cc6c5	3281f07d-1af0-40e5-9a87-94f541b055ff	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3b53c48b-1fab-4ddf-b0ed-2ef9b7ece45b	64b4adec-31d8-4c8d-bda3-15787a68f726	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2a72462d-826c-4c13-8028-54ef97ea6972	38ecdea1-cdb9-4bcf-8c52-cc12b0963056	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
24ee4d0a-714c-4380-b700-8c886c6f4876	0fedc096-0433-4a7c-87a6-5f3460005c94	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ac074de5-664b-4b9f-bd0b-9f378f5e567b	cd9c6fe9-9cd4-4c4b-b1c5-cfd464e35af6	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a15759bf-bead-46e7-bd59-4cc1b9fbf534	5dc08f8e-42cc-4d1e-b92d-664860a5ea3a	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d0c16624-6549-442b-b1ae-b1e3cfd1318a	a7c9dc41-94ef-4273-abb5-6c60efd7130a	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cd0294e9-37a6-405d-b151-c3998b961042	0471f240-122c-4a12-91e0-d71c393fd2b0	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2715babc-4b16-47af-8238-7ce95817af9f	f17c8d9c-ed11-462a-b495-aaa867b9b2e0	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4a699090-0028-4b3a-8b6f-f3b8f0460c4a	cc242357-2f2a-4baa-b9cd-5b564c2d7575	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1d9e65a6-b3ce-4d67-8d07-4496bfca56aa	07dd417d-d872-42b2-86d9-c9ccb545c1d4	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bdda5a8b-43ee-4c74-85db-a561854588fe	7e3fe322-7f3e-4b6b-a77c-a37839691d93	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2fd4115b-f82a-4279-bf3c-de2f4a852f7f	9b143816-5cc6-4e1d-b2b5-db0ab94943d3	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7c2e3a1f-0c84-4a1d-8d8e-6c6523e1f706	61f36935-6a0c-4ee1-a73c-f2d3e91be9a4	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0e78777c-1f06-46fb-ba7a-25b86b92da15	98f159a8-e679-491c-ae7f-f161796f7e6f	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
71917fbe-599e-436e-83ca-7927d30cd936	11f49b15-93f1-4eda-ad1a-d9135eb910b1	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e2a7fae5-5d6e-4f6b-9351-d69a8974c5ff	40828885-c5ee-49f3-9f8b-5fefb11f5981	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b8b43505-b10d-4d5f-a4ea-6f4dd0f79c35	4e0116d8-8c05-4b4c-9fee-5e578cea0194	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
511aa304-df06-4b94-a2f9-6b7ae3aff5ef	732d0320-c065-4bf0-a5c7-8323807b9ccb	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
51da120c-ed83-45db-af5b-076047158b6c	580921c7-0c4a-4d6a-a164-033977348b56	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
316d061b-2960-4e7b-915e-d198329792f1	e67ac562-fc06-4b29-8a51-6c9099441197	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b9487970-e0c0-4695-9d15-0e54d7986900	10742903-261b-46ad-b814-fefe81479bda	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5301e96f-3d82-43d2-8d00-5e4c6a69e728	6f8b3b80-26a6-414d-996a-fb9e3997ed02	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a591b0fb-378c-470b-8c80-e8f4d91fb96b	610d1e31-e825-4989-80fa-bd74d0925d37	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4e24ce89-fdeb-4542-991b-7ae9645cba92	eb5f26ec-73a6-420f-9ab3-8974185db66b	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
53349db5-e757-4f86-b13c-1d2b3945e568	750b525b-37f1-456d-92a9-9a0042e896bc	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c469c4d2-d8d6-4727-9dc1-7f45a8c25934	7e6ddb82-38ab-4157-a31f-45bef4689b70	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
da568b1b-77a3-4b27-8513-dc105f43e30d	24c8840d-4353-4564-9a26-274509423d4c	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c32e546e-4b0f-42f2-93d4-44b42ab4d166	043be691-df3e-40b6-a8cd-335312425487	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
55429a7e-923b-4b3b-970e-2bbebeebd166	35a08a68-3b0f-49b1-a10c-9c74cd7530e9	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0011cc64-2195-4247-bc05-2aa4f19a65ad	a532e1e4-3eb0-4c7f-ba98-382afc4b9808	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
400849a5-b8ae-4770-a8e0-dc810a7f7f90	c17f1864-bcae-46ad-a1b2-870600a9a235	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c3d27742-1d29-4996-ae19-035da8533889	6a3d6445-fb04-4f19-97d7-c4299560e779	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4d051b1a-17bf-4729-a9ea-48270fca9d35	c7b653bd-9594-4004-96f1-af064c01c239	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5c2ecb99-6e83-403c-b1df-ea7735a5c8e8	83fc86a9-e771-49b9-af5c-d8d93abbdce8	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2c1244ad-2c68-4fab-bc2a-ead539c1f28f	3a1a352a-4a5a-4fd2-b5a0-b033f367ceed	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
946dacd5-1119-45c7-a508-67e7065b44b3	0550b807-6ee6-4fd1-9f78-416959225026	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aa2ee38a-bd9b-4d58-9eba-32749d2bcab9	a969341e-feeb-4634-8764-2415c2c82ac1	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
eca9eb04-136b-48cd-ad02-6b679f682f5e	6d62ad49-be8a-49b6-84a4-edcda61b49d0	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
91e41861-29b0-4a22-842a-5662ccb872cb	50410ec8-dcd4-4ce6-b3c9-18191461c546	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8cd72866-76c5-4ddf-a8f1-bb20f177bc48	011a62ab-aa23-45c4-b52e-d852ce42e108	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
89f7cc73-36c5-4205-b571-5cdee387f4b7	6d38be45-6da9-4827-ab77-68eb367ad12a	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3a79473a-7655-4c7c-a70e-420ce6f30d0d	5ae51704-3b39-40d7-879c-0970d6215982	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
227991ae-4d29-4b0e-b3d2-1d5088e98291	abca123c-d9f8-482d-a1fe-082177dea3c8	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
13ebd0d3-6511-4d35-905d-1a8f962c8f3a	52cf5518-dcbc-4dee-b89d-82f6129fc8c7	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e4f8f54e-bfcb-4da2-b822-fc31db729c5f	93aeeb8c-a2d3-41e6-a081-7105071eb74c	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1c24cecf-e257-4b50-87fb-cdb51f3b39fa	861bc8fc-ace6-4cbc-977a-a99486df5d17	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d3bf062d-93f0-4795-9f7c-30407035b95a	e125d08b-bbe4-46f0-ac81-34a19dc74b66	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8bf9add3-7a9a-4d81-9877-d2f15066aeeb	e513a545-c69e-4e7b-b6e6-ecc29ecd3513	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
611b51b9-1644-4929-bddd-2824fe4e038f	f61f3b5a-7e7b-4dec-96c7-b3d67f17154f	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
23ad97bc-8c6b-4fd5-b4f5-e8cbcc6bf7bc	220f5648-54f6-4c9e-8138-2d7d6d628f77	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7e07e85e-8a10-49e2-ac48-6642da0a305f	717f9536-5f01-4d40-9e95-7a19645007fb	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
09016c0a-d800-47c4-b558-2e005823f466	8fa4b4e8-0f45-4aa0-9e9a-4533a909ca5a	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6388aa5a-6554-4645-8fef-9f34837a54b5	43a23ee8-46d3-4fe8-b995-cebd67fea476	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
db9fe279-9ccb-4d4d-bce3-298788e2945d	26f62d50-4af0-4cc1-91a9-dec36d4ec6f7	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a42dcba8-30e2-404e-83e4-988377f56641	a46283da-5150-40ef-8cf7-d26825dcb5cb	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5e6a56f8-e559-4cb8-a14b-859041da2f46	a9fccdca-6007-4f57-b047-28b1c054b364	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
73483905-0a1d-4875-865d-8a2e0a63af6b	e51ae210-e515-4c9e-9d31-80981bf5be0a	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
caab033f-3261-4b42-8595-4c704776ef88	f803ebb1-3599-47df-b726-7583dd4320d2	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7665c506-0996-483e-b877-bc92fb3a47c0	be99416b-2b54-4b28-8d14-0299a03497c8	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6e87cf88-c6cf-48fa-b7e5-cddcd3e52d5d	0a0b0e9c-7a60-4cfe-a210-37eec7a9c665	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c3a0772f-7e50-47e5-ae1d-6832b9c7fe5f	0fe5edad-4f14-4b26-91c1-094499b64bea	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a40e4d5f-2fbe-48b6-845e-3dce5cc60d32	d454791f-a54b-436e-9a8c-2af9b57e7f91	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
84871a1a-cf89-44d6-b12f-6bac1f00d859	9c527016-e333-4167-8cff-1d2c6b443d0a	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
38dca02f-88ce-4490-a60b-fb50d9849844	e611408b-3717-430e-9617-f52a235f83ca	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c09c36ed-5612-4b3d-9e39-f6418a0e35ff	ced75b26-864a-45a8-9ad2-dac2324490fa	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ac966235-8641-4820-bd6f-d0d0a5e91bc6	41637f07-cbc0-49b1-bdb6-c3942fdab244	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ac71d7ee-1738-40bb-877a-4bb227e66143	53024dca-d52b-4f13-8221-5ca92493c5e3	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6257108c-6e74-4b0a-a4e4-9a765c71d03a	da5ddf47-14da-4bbd-81ce-35dcf1851444	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a0addb9e-fdad-4038-92e1-2e8ba82278e2	ab56b3ae-fa45-4686-bb98-3c6d7f7b6a8b	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ad5d608a-79f6-4baf-91e7-b41d8290d74e	3effc5c9-f4a8-48d9-a615-ebc284ab0450	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fe38fdcd-fc80-41f0-b952-5b7594e5f01b	795fb08d-a679-440a-9db7-4bff38b394f4	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c6b9e9c9-9497-43d6-9fb1-a5628f4bd263	b08d4ab5-d93c-401c-af71-663d95a5d4ee	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c3850a60-f5ba-4184-857b-efff55ae50f0	fa0f371b-1e43-4848-9732-7b6d1b1368f6	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4ee97ffe-fc2d-4083-9620-f4bccbe575d7	b7402c3d-09ad-48b0-b2dd-b24e834700e1	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
af2b3169-de85-4a89-bedc-14423ff4316f	ac9feaf1-1256-4d9d-89a3-6cada13e6093	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7979066e-171a-4ec6-bbb2-fce1558d0a71	737985cf-cca7-4dec-8911-9640dc774efa	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2e50dd92-84c9-4f7e-860b-769074ce8fae	830ba80f-ab68-4856-bf70-c8370e558a50	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1f97f7be-b4b9-4111-b8e2-fb8fcd4c0f0a	cd704f6f-bac6-4722-9807-4a07ac21b36c	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b7651a48-0799-4303-8698-b2d02d764ab6	172bb906-84da-4157-9e3e-72333fc3797d	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
07d00105-ee71-4199-850a-1f9e30ee359c	8c6cf449-1b59-4e5c-ad01-8907e26037e2	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aedcc5b8-2287-4e90-8ee1-a4798d802e8f	fdcc3782-c42b-4b2e-a1df-8d4731f3daf3	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4cba1896-b3cb-4b7f-a439-ad4d4cfb8c4d	190bcfd8-3ed0-4e60-9553-1ea58f357d6b	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2ffb14ce-dd3c-4cfa-a674-1305e3f9c2b4	616464ab-df9b-46af-8617-1fb42cb2cf2e	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c03b68a8-5d92-444a-bcbc-1fc126edc9f8	284a08fd-1224-4719-b0e7-9f64eb674800	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f5326139-2858-4c93-9d67-edf5c44dcc6c	8548c271-4595-4445-b154-f372bb9f1338	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4361f6ed-ab7b-4b63-b477-ac24e72d2924	9834d0f7-4e58-4f04-aed7-c81236e40126	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6921adb5-2b1d-401a-82f7-2bf8023268ad	22de9795-3a91-48c8-9dfc-91d3a76a129e	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
73b02e67-5b82-46fd-9dfa-f068a1fd941d	b1dbf533-a7b0-4aa6-8ee8-46b6330bc60e	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3d5bdbaf-d457-42be-b43c-c4a8e7f7d4cd	e2e2c050-3bd1-4225-92ea-ced1c6456045	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b79abeae-5e51-4c4b-bfe7-1ed0c8823a0a	5ec91873-aea6-4048-b804-41aab0543cf9	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
db5e191e-0ac4-48fe-8617-3bd52fae084c	ae83f83f-ab0c-4d60-b220-821bc7cbe533	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3ae4dde7-6ba0-4d6f-b5d5-fd892e916eff	6f7f2a01-1cb7-4d84-b79e-84acaad3263b	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cae83be3-0379-4da5-ad50-f78294af0bd5	7e6ddb82-38ab-4157-a31f-45bef4689b70	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4365d57a-9857-43e4-ae42-bfff4d5dcc11	24c8840d-4353-4564-9a26-274509423d4c	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
af152921-fd96-45e8-9ffd-93818a565072	043be691-df3e-40b6-a8cd-335312425487	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c59f71be-124f-49d5-a3e8-d78837dd86b7	a532e1e4-3eb0-4c7f-ba98-382afc4b9808	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6cc31a6a-f74f-46ba-be30-7dd2c3fb1718	9824d754-e00a-443f-b636-6dbfa762b13e	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4f2b3870-fe4e-472b-bb78-77efa216e4ed	6a3d6445-fb04-4f19-97d7-c4299560e779	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
631717f2-10c8-47f7-a6f8-f98f05c81960	2eebcc77-c4bd-427a-964b-33e0ad388b98	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4aefc4f2-b04d-4f4b-a648-342907544c1f	60ffce2b-d2c7-4eaf-8267-d2e979d17802	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
719770a3-f267-452e-a291-b3ec7498ad07	83fc86a9-e771-49b9-af5c-d8d93abbdce8	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e6b79850-c8f8-48d2-80e0-1634903da04b	3a1a352a-4a5a-4fd2-b5a0-b033f367ceed	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8277e111-2ab7-4145-a75f-c376c9c5abe1	0550b807-6ee6-4fd1-9f78-416959225026	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5c1f34fb-55a4-481e-aa1d-ec2b77af6526	a969341e-feeb-4634-8764-2415c2c82ac1	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
73edf687-9d48-4f3d-9138-12775c1b3b66	6d38be45-6da9-4827-ab77-68eb367ad12a	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2bd214ba-320b-4f0e-9d38-3da01c2bc0bd	5ae51704-3b39-40d7-879c-0970d6215982	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8af934c2-131a-4ac0-8f21-b0598f3749c3	52cf5518-dcbc-4dee-b89d-82f6129fc8c7	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dd7865fb-24e0-4bfa-a7bb-696d21c604ad	861bc8fc-ace6-4cbc-977a-a99486df5d17	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d92714da-a2c7-481c-b0bd-ad6f6c7866f2	e513a545-c69e-4e7b-b6e6-ecc29ecd3513	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cb36f667-e9a0-4050-943e-34ef6affd55b	63ad31fe-28d0-4888-abdc-5f417acd40c5	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d187c4a0-1610-480f-9aef-8408189f9637	24db3f2d-92c3-40a3-bbcb-4bbe938be53c	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
76811699-9dd7-4714-ae4f-21142089f8f5	8fa4b4e8-0f45-4aa0-9e9a-4533a909ca5a	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
318df86b-ab32-4bdb-a37c-c355fb6614f7	a133a81d-78bf-4f44-add1-0b16023eaed9	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d43aec32-d868-4a95-a4fa-4ff7c62480fa	43a23ee8-46d3-4fe8-b995-cebd67fea476	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4851151e-9666-454a-8e44-ec34e12c59ce	d4c85d6d-1178-4759-b3b4-7f9c7adbcacd	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8ed4488c-4f77-4d4d-b881-a00a0e7a7a82	a46283da-5150-40ef-8cf7-d26825dcb5cb	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5bd271c9-e2d4-40b1-b2d5-6cd9f537273c	a9fccdca-6007-4f57-b047-28b1c054b364	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
07e9ac39-0528-4dfe-9c97-8a09e741866a	e51ae210-e515-4c9e-9d31-80981bf5be0a	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6281576f-58fb-4700-9b7a-e5cc91cab0ab	0fe5edad-4f14-4b26-91c1-094499b64bea	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8100438e-099c-47a2-82ae-1068f31f9ff8	d454791f-a54b-436e-9a8c-2af9b57e7f91	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
612c9fe9-bfc6-4939-bb33-4850efccd725	1f5c553c-860a-434b-98f2-9659e895b3fa	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d5c9524d-1267-4ee9-ac25-91cf8b09215b	e611408b-3717-430e-9617-f52a235f83ca	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5e7fa248-bb76-4b09-91b6-6c9e6b5b0f70	ced75b26-864a-45a8-9ad2-dac2324490fa	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
78696c78-b9a9-44bd-8a2a-09ca2cc451c5	41637f07-cbc0-49b1-bdb6-c3942fdab244	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
36a623af-1755-4d50-bb2e-617b1611de29	c01eb865-c554-47ac-a058-38ff2057b023	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c47891f8-62a5-488a-9b21-409a45d3bcc2	ab56b3ae-fa45-4686-bb98-3c6d7f7b6a8b	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ce34fb97-1822-4e60-b6ce-b963428db84a	433539ad-d279-4ffd-b778-cce5ceded3a3	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d8ffa4de-182a-48fc-96e3-4514951e5e61	0adfcb5c-2694-4686-827f-9bde61beb8f6	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
54f17fdd-86d0-49da-a523-f47a93cbde78	b7402c3d-09ad-48b0-b2dd-b24e834700e1	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fcec7065-1359-4073-9594-d2eff3335043	55a24e2c-d39e-4e95-aa9f-1e5c41861499	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4d6aed26-ae97-43f5-9808-d071253458b5	ca0cbf4b-4981-44be-8682-058fb03b211d	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e4297d94-5fcb-4884-9e32-93a1f82d2e6d	737985cf-cca7-4dec-8911-9640dc774efa	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e27def46-b1f5-46ca-9f9a-90cc85f0da91	2f462dfc-1d11-45bb-9a78-18eca84e773b	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0abf000e-30f2-4466-8265-311f08e72d7c	172bb906-84da-4157-9e3e-72333fc3797d	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
183e0a85-8afe-4638-a960-01b2046dcf1b	8c6cf449-1b59-4e5c-ad01-8907e26037e2	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
78fdf432-fd41-451e-a162-782fe47789cd	fdcc3782-c42b-4b2e-a1df-8d4731f3daf3	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6dd56cbb-f946-42db-92cf-f2ca7e0e0b6c	e8eb401f-5eb9-4b76-a93d-b6bd91adee08	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3b8445f7-8918-406d-8ef4-d95e0782ebf9	190bcfd8-3ed0-4e60-9553-1ea58f357d6b	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6d0419ed-7e4f-45d1-8b74-ed3f30e4a8bf	284a08fd-1224-4719-b0e7-9f64eb674800	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b8a40136-f543-4eae-96c8-f261bc5d5afb	8548c271-4595-4445-b154-f372bb9f1338	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b6aa86a2-2397-4ad2-8e9b-7fefa62a2c8d	22de9795-3a91-48c8-9dfc-91d3a76a129e	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
50fe0f48-a9ea-4775-9b4f-df6fb0b73edc	0efc1b63-a226-4d5a-8034-ddd817d2fe44	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
deccc7bf-5384-4f60-8567-61c18706212c	ae83f83f-ab0c-4d60-b220-821bc7cbe533	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c43c180f-8119-475d-84a6-57a7a8cf7c0d	108d6794-3b30-4c57-8e6f-3070ad9b923f	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f3311734-4712-41eb-9930-2ad252deb246	6f7f2a01-1cb7-4d84-b79e-84acaad3263b	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4f3dc4f2-08bd-419a-9860-be3a01b1e59a	7e6ddb82-38ab-4157-a31f-45bef4689b70	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6186a4d4-4707-42fe-a940-b933e7bb3572	24c8840d-4353-4564-9a26-274509423d4c	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b873b686-d4c2-40c6-b68f-f0f1e56c352a	35a08a68-3b0f-49b1-a10c-9c74cd7530e9	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6ec69651-9ab7-4cb0-b2a8-280e49e5febb	a532e1e4-3eb0-4c7f-ba98-382afc4b9808	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
79379cca-e4b7-443a-8aea-6dd7e8556b41	9824d754-e00a-443f-b636-6dbfa762b13e	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1269542c-99ef-49d2-ae70-4e5a894cf05a	c17f1864-bcae-46ad-a1b2-870600a9a235	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b0558979-7d89-4f7e-9e90-e8c48f9926e1	fdc030f8-9097-4e45-b313-bedb82c35091	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bb8f933f-c699-48aa-8f52-c4ee0a6e5b5d	2eebcc77-c4bd-427a-964b-33e0ad388b98	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c5e1cab7-e0b3-4cca-9fca-5f7794c6ff3f	c7b653bd-9594-4004-96f1-af064c01c239	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cb163176-f1a7-4570-ba23-90fbaf41ba19	60ffce2b-d2c7-4eaf-8267-d2e979d17802	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8a38c05d-3568-465c-9658-58dc7d562897	c632ea9b-1e71-4da8-be6f-55b543e60df6	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
de7d056e-b7eb-48a3-8661-be7077a7ca50	83fc86a9-e771-49b9-af5c-d8d93abbdce8	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
238eca2f-ac8b-4a27-a78e-d4593f071b9f	3a1a352a-4a5a-4fd2-b5a0-b033f367ceed	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
168a00bf-4f2f-4b40-9443-661d6057799b	6d62ad49-be8a-49b6-84a4-edcda61b49d0	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7dd171a5-7423-4b25-8b0d-2a77dcd12245	50410ec8-dcd4-4ce6-b3c9-18191461c546	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
537e80b9-0c94-41ff-af32-809affa636ea	011a62ab-aa23-45c4-b52e-d852ce42e108	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0dfca9ea-92e9-4b3f-a649-b6c143929ec7	abca123c-d9f8-482d-a1fe-082177dea3c8	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6c9471f6-429e-40da-80ac-7d77799f3cdf	52cf5518-dcbc-4dee-b89d-82f6129fc8c7	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
11898070-bc21-44b1-977e-521708dbd8fd	93aeeb8c-a2d3-41e6-a081-7105071eb74c	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2d8bae7e-50b8-4726-a7d8-89b1768c8807	861bc8fc-ace6-4cbc-977a-a99486df5d17	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d34fe229-775b-4535-81ab-d9f02b2396df	e125d08b-bbe4-46f0-ac81-34a19dc74b66	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
31295d3d-1a89-4ba4-9cea-ec91c458e7b6	e513a545-c69e-4e7b-b6e6-ecc29ecd3513	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0144044d-d982-46c6-8323-1fed59547189	f61f3b5a-7e7b-4dec-96c7-b3d67f17154f	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d3c22a16-1742-4690-aa05-916baf11376f	220f5648-54f6-4c9e-8138-2d7d6d628f77	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
004f8700-0cda-4a84-b9ab-a0073a538e13	82efe96e-2627-4f69-b367-143f4e4efc42	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
845780a7-5439-4225-ac58-a5804f282d7c	24db3f2d-92c3-40a3-bbcb-4bbe938be53c	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4e62027d-0ab3-4122-8cac-9fa4a82d5a7a	717f9536-5f01-4d40-9e95-7a19645007fb	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ab9a674d-76c6-4200-a126-086da019b25a	a46283da-5150-40ef-8cf7-d26825dcb5cb	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f478aa48-5fd7-40f7-ae52-eed7dbd97a1a	adf47935-1828-4383-951a-04669fe06e1b	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0e90e72f-a71d-4df1-b152-2a1b936929f5	0a0b0e9c-7a60-4cfe-a210-37eec7a9c665	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9c78ec35-69dd-43db-8735-02021dfb9bd8	0fe5edad-4f14-4b26-91c1-094499b64bea	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9a3b98ad-0899-4ed7-bcfb-f5b8dc867830	d454791f-a54b-436e-9a8c-2af9b57e7f91	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2db3c7f6-b7af-4b90-951d-f1b816ca87d1	1f5c553c-860a-434b-98f2-9659e895b3fa	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fd28eb41-a25c-4cbd-9f3f-cd737d065b2e	e827db19-29ef-4004-8456-7d2616b59228	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1ed9d902-a091-4980-889b-7a9e8bd48bcf	ced75b26-864a-45a8-9ad2-dac2324490fa	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ccfce3dc-3921-45a9-bdc9-bba0d10dac4c	da5ddf47-14da-4bbd-81ce-35dcf1851444	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e09aac5d-42db-44d6-a7ec-1ff560130abd	c01eb865-c554-47ac-a058-38ff2057b023	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b88d30b8-5baa-4ca2-a3d5-80742715c5c2	3effc5c9-f4a8-48d9-a615-ebc284ab0450	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8da80c07-e76b-4e54-822c-696d209536f9	0adfcb5c-2694-4686-827f-9bde61beb8f6	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6eb1feed-f610-40d2-b381-3b7604138448	fa0f371b-1e43-4848-9732-7b6d1b1368f6	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ffa09df1-7bdf-4e39-a536-f6fa64b7371c	b7402c3d-09ad-48b0-b2dd-b24e834700e1	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
af98a059-923f-46c2-895a-c591a43582f1	55a24e2c-d39e-4e95-aa9f-1e5c41861499	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ad99a094-dd5d-4e5c-95d9-99eafdd8dc0a	ca0cbf4b-4981-44be-8682-058fb03b211d	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
07e8b624-64a5-4a54-ae2e-b4e87b9d30bd	737985cf-cca7-4dec-8911-9640dc774efa	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2e50c20d-be04-4cda-b63d-7d83946793b5	830ba80f-ab68-4856-bf70-c8370e558a50	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ee3d602c-3e73-4c38-a3a8-4aef0b196015	2f462dfc-1d11-45bb-9a78-18eca84e773b	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b0047c38-fe6c-4932-9b66-efb89dc70fca	cd704f6f-bac6-4722-9807-4a07ac21b36c	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b1d08926-7c3a-41bc-9270-847b96e49842	8c6cf449-1b59-4e5c-ad01-8907e26037e2	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8d6227aa-7a1a-4740-8fbc-5c093b1bef25	fdcc3782-c42b-4b2e-a1df-8d4731f3daf3	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
22deffba-138e-4405-bc4a-ee9c375a78e9	e8eb401f-5eb9-4b76-a93d-b6bd91adee08	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9edf5b7e-af10-4069-94a0-2b743f4ddd11	190bcfd8-3ed0-4e60-9553-1ea58f357d6b	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
891ea3ec-1dbb-4361-b330-fcd281166f44	284a08fd-1224-4719-b0e7-9f64eb674800	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d2907653-6451-44db-9a16-e071cfbdaebc	8548c271-4595-4445-b154-f372bb9f1338	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c9dfffa4-e58e-403c-b456-edbf3b6e89d4	9834d0f7-4e58-4f04-aed7-c81236e40126	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9daee747-0445-476c-b4f8-0138399f7190	22de9795-3a91-48c8-9dfc-91d3a76a129e	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d68dfd03-9834-4f99-b653-62c0204e3324	938c4b04-a9a2-456b-b04c-dd6f38b8db10	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d8d4bce7-4b9b-48db-ba02-bfc54e8bfa4b	e2e2c050-3bd1-4225-92ea-ced1c6456045	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
709eb6e7-ef20-44b8-9684-2617a4d7004e	ae83f83f-ab0c-4d60-b220-821bc7cbe533	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
663ec8d7-90e3-4511-8112-64e0e9c66ce1	6f7f2a01-1cb7-4d84-b79e-84acaad3263b	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9fb1d4e6-20a2-4782-849d-6cf91ecd9a9d	7e6ddb82-38ab-4157-a31f-45bef4689b70	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
69f76124-3991-4894-8454-2b5a8e99ca60	412f8228-fbaf-4cda-9ecc-4c417c13471d	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3d331a7a-921d-439b-b011-260ea63eb9bf	043be691-df3e-40b6-a8cd-335312425487	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b4562a1c-1437-4b33-a32d-9a2e4afff952	35a08a68-3b0f-49b1-a10c-9c74cd7530e9	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3a97a495-df2e-4254-9641-6c8a73920220	a532e1e4-3eb0-4c7f-ba98-382afc4b9808	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3c9ec64b-c392-47ca-873c-19ad1b9c4ef4	86a2a85e-e85d-4b4a-a95c-f3ab858c00ae	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5f0a7dce-6de7-497c-b21c-6c359cd5b842	c17f1864-bcae-46ad-a1b2-870600a9a235	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f4389ca8-ad27-4e6e-b0d7-320e27fdfaef	fdc030f8-9097-4e45-b313-bedb82c35091	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
42e57aaa-0695-48c7-9e26-a886370bfdb2	60ffce2b-d2c7-4eaf-8267-d2e979d17802	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7cc71177-5773-4d6e-a40f-819618d84e04	83fc86a9-e771-49b9-af5c-d8d93abbdce8	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
df119796-5302-435c-8124-1a1f6ab5cd76	0550b807-6ee6-4fd1-9f78-416959225026	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
67496711-ff4d-4a14-b05a-e436e02b07fe	cc8a24af-c75c-4bbd-aee8-ba62f0672376	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
77872d9e-c3f7-4251-844a-45e3fba05948	abca123c-d9f8-482d-a1fe-082177dea3c8	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
54d6e626-6d02-4244-ad36-6eeb633631bf	f66d0012-ad6f-424c-83c0-8aecf9ccc0f5	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
956f01a1-6e56-4c83-a932-5785c0c00609	861bc8fc-ace6-4cbc-977a-a99486df5d17	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cdcdfa7e-925a-48ee-9b31-5d9377b67fd8	e125d08b-bbe4-46f0-ac81-34a19dc74b66	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b2b7c06e-625f-4d6f-98fa-88fc821a6783	e513a545-c69e-4e7b-b6e6-ecc29ecd3513	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
89d41f63-a5aa-4f0a-94e2-61f4490b5277	f61f3b5a-7e7b-4dec-96c7-b3d67f17154f	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6cda13a6-0960-4add-bd17-e0076708565d	37b0c1ed-5359-4518-9f34-cc146c70b874	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4b8f02d6-f1fc-4979-9b03-5a797a9817df	220f5648-54f6-4c9e-8138-2d7d6d628f77	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9ad756f3-f04d-4930-bc0b-8662262d69ff	24db3f2d-92c3-40a3-bbcb-4bbe938be53c	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1bf52365-e49e-47d9-ac44-78855b1c4f68	717f9536-5f01-4d40-9e95-7a19645007fb	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
929d403f-b1ff-493d-a5d6-875dac24ac9e	8fa4b4e8-0f45-4aa0-9e9a-4533a909ca5a	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
412df37b-8d83-405a-9196-5714ab4665ce	a133a81d-78bf-4f44-add1-0b16023eaed9	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5c1496e6-3721-485a-9bfb-07cad84e8776	43a23ee8-46d3-4fe8-b995-cebd67fea476	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
eb59ea68-e546-4138-8d8b-5cfce29b2964	26f62d50-4af0-4cc1-91a9-dec36d4ec6f7	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
19adce1d-e1e7-4847-8351-b405ed7fc0ae	d1f11405-d23c-4135-abb5-f929a19084a7	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7d2de598-b50b-42ac-bd6e-49dd90291271	a46283da-5150-40ef-8cf7-d26825dcb5cb	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
38e1d661-1910-495e-8124-878fb04a3fff	adf47935-1828-4383-951a-04669fe06e1b	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fbe93346-67be-40d3-8e6a-811f93cb6d6c	a9fccdca-6007-4f57-b047-28b1c054b364	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
78dd30a9-1c2f-4621-b527-b958b93072f0	0fe5edad-4f14-4b26-91c1-094499b64bea	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f18bc24c-7bbe-481b-876d-c1feca38b19b	d454791f-a54b-436e-9a8c-2af9b57e7f91	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
99f4ece7-c7f0-4e4b-868b-1ec11d86a22d	e827db19-29ef-4004-8456-7d2616b59228	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dac68757-c3da-4d64-9247-3566a4cadfa2	e611408b-3717-430e-9617-f52a235f83ca	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
521e640d-e8e7-40c9-9f53-c62b1e6244e0	ced75b26-864a-45a8-9ad2-dac2324490fa	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d5415ccd-2d7b-4986-84f0-2e0a0be6e7dd	53024dca-d52b-4f13-8221-5ca92493c5e3	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
871e9353-b315-4834-b8f7-a9fabf2f9324	ab56b3ae-fa45-4686-bb98-3c6d7f7b6a8b	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
44624b53-9e3b-48a7-a29f-4eb966828e95	795fb08d-a679-440a-9db7-4bff38b394f4	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d2bd207f-78a8-4bfc-892e-a546d766fc2f	b08d4ab5-d93c-401c-af71-663d95a5d4ee	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b0b6408c-f2f1-4ec4-b686-82dd69003dc5	ca0cbf4b-4981-44be-8682-058fb03b211d	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e23bb273-7b58-40a1-8720-ad9dd1e6489e	830ba80f-ab68-4856-bf70-c8370e558a50	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d18c3d8a-dd1f-4dd5-a8a5-f09c834d9ce4	2f462dfc-1d11-45bb-9a78-18eca84e773b	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3c3e56d9-97d7-44c8-80aa-591974951f39	8c6cf449-1b59-4e5c-ad01-8907e26037e2	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
947a850b-f1d1-4f03-a551-1224a38b8106	594d476e-d3b8-4a1b-b947-f3c7dd2fb238	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2509362d-0c51-47a4-941a-4bbb48eed280	190bcfd8-3ed0-4e60-9553-1ea58f357d6b	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9e874365-b6f3-40ac-8142-ad0381cab760	c063f12d-ecef-42f5-bec4-5f78a2bc20b9	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e21f134b-0252-4988-9fa3-de19e5f419c4	284a08fd-1224-4719-b0e7-9f64eb674800	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8978d0f5-6f21-44f9-80fe-518245812049	8548c271-4595-4445-b154-f372bb9f1338	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c03e4b0e-3939-4f20-b86f-1e50539159ed	9834d0f7-4e58-4f04-aed7-c81236e40126	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d441a833-a4d1-420f-ae42-b25eeea64588	22de9795-3a91-48c8-9dfc-91d3a76a129e	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9d03e8e0-34cb-4bdc-b91f-989d1cd3ed78	938c4b04-a9a2-456b-b04c-dd6f38b8db10	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
24a834df-2b1c-425b-bf98-51ef064091e2	b1dbf533-a7b0-4aa6-8ee8-46b6330bc60e	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
679e50f7-9b1c-448b-be79-1776bed14903	6f7f2a01-1cb7-4d84-b79e-84acaad3263b	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
21660f85-7ad3-4d53-83f0-4eed12757bbe	61e06565-0842-45a4-8749-60f73a89a30e	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8ac84347-7753-484d-b811-7ae1e2c6fb45	412f8228-fbaf-4cda-9ecc-4c417c13471d	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3200ca36-1cc5-45cb-8e42-040d7577ff53	043be691-df3e-40b6-a8cd-335312425487	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5f9edace-ac75-4af2-8169-758caee023ec	35a08a68-3b0f-49b1-a10c-9c74cd7530e9	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9feeae40-24a4-4216-8f6b-cf557ef4b81e	a532e1e4-3eb0-4c7f-ba98-382afc4b9808	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
577e4862-c87b-4488-a3da-ea31781255d3	86a2a85e-e85d-4b4a-a95c-f3ab858c00ae	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fb57cff9-a3b5-47f8-99d7-522cdd11f3d6	9824d754-e00a-443f-b636-6dbfa762b13e	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
785244c3-172c-47a4-b287-8646cdb786b2	c17f1864-bcae-46ad-a1b2-870600a9a235	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
668fe02f-6b9e-4db4-9790-9287159732ad	60ffce2b-d2c7-4eaf-8267-d2e979d17802	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d20d3a2c-2e98-4330-9dc9-06c80fd2afae	83fc86a9-e771-49b9-af5c-d8d93abbdce8	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d906e44f-fcbf-4b4c-b7cf-7079c44175fa	a969341e-feeb-4634-8764-2415c2c82ac1	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ad1146c0-e56a-4cb9-95f4-44e01242457e	50410ec8-dcd4-4ce6-b3c9-18191461c546	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
15f21924-37c2-4b28-ac51-c48e1515cf9e	5ae51704-3b39-40d7-879c-0970d6215982	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
90b85067-ad72-4753-951e-e860e92a332a	cc8a24af-c75c-4bbd-aee8-ba62f0672376	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8eac4b7d-d3e8-470e-889f-e64196836b58	abca123c-d9f8-482d-a1fe-082177dea3c8	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1bfbadae-ef47-4ec2-ac74-8ffa532f2e2f	52cf5518-dcbc-4dee-b89d-82f6129fc8c7	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a987b719-71b8-449b-b852-e57fb46b5e50	93aeeb8c-a2d3-41e6-a081-7105071eb74c	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7053b375-3545-44fd-857c-cdf131736afc	f66d0012-ad6f-424c-83c0-8aecf9ccc0f5	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
999aa9ae-050f-4c92-95d9-6c944c5c66b1	f61f3b5a-7e7b-4dec-96c7-b3d67f17154f	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
57de10d1-ef40-4653-bd69-e1ed0a1884bc	63ad31fe-28d0-4888-abdc-5f417acd40c5	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1f7b9ecc-2729-455a-83c0-e9f252282843	24db3f2d-92c3-40a3-bbcb-4bbe938be53c	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e5212ff8-c212-4296-8d0f-fd527d62cd0b	a133a81d-78bf-4f44-add1-0b16023eaed9	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cc441e03-d3ee-460d-9f3f-cbf5d6e23139	d4c85d6d-1178-4759-b3b4-7f9c7adbcacd	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
91cffeb2-a1bb-4208-aa4f-27349b8e3b0a	26f62d50-4af0-4cc1-91a9-dec36d4ec6f7	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d706c96c-2393-497c-9cfd-d77c1666dbcc	a46283da-5150-40ef-8cf7-d26825dcb5cb	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c39528c2-40ad-4616-8e22-e61e843de38a	a9fccdca-6007-4f57-b047-28b1c054b364	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
30268ac6-75b9-46b5-b741-3b807aee9f28	e51ae210-e515-4c9e-9d31-80981bf5be0a	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
defbbfde-df93-4e87-8460-14f4fd318745	0a0b0e9c-7a60-4cfe-a210-37eec7a9c665	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7bbdff3a-6e48-421a-bf9e-5215d9a1ccb3	d454791f-a54b-436e-9a8c-2af9b57e7f91	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
89b0d483-e08c-4e16-af72-6baecedf737c	1f5c553c-860a-434b-98f2-9659e895b3fa	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a9f04845-f3de-4714-9b64-fc96973fc919	e827db19-29ef-4004-8456-7d2616b59228	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
71cff3e2-5820-4ee5-9315-48c3b6508927	e611408b-3717-430e-9617-f52a235f83ca	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e2fb3c27-9fb5-49d9-a6ef-ccf54f62019a	ced75b26-864a-45a8-9ad2-dac2324490fa	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
49d5e964-a0fc-4b2a-975b-bf682a04d5a4	53024dca-d52b-4f13-8221-5ca92493c5e3	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aba3501f-9545-4667-a18f-5b7feaa9b07d	ab56b3ae-fa45-4686-bb98-3c6d7f7b6a8b	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
73aa8573-f72f-4716-9956-16dccf200469	3effc5c9-f4a8-48d9-a615-ebc284ab0450	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fc6c1da4-f089-4e95-a782-3965f79478f5	795fb08d-a679-440a-9db7-4bff38b394f4	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
75abb0f9-a017-45d2-a7a5-fe12e2d7a91c	b08d4ab5-d93c-401c-af71-663d95a5d4ee	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7e618d5b-3d5f-40e9-a201-4569dab6b62c	0adfcb5c-2694-4686-827f-9bde61beb8f6	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
91c772ec-8e35-4fc7-9393-c12c9da9b7ba	fa0f371b-1e43-4848-9732-7b6d1b1368f6	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
137ece50-2422-47ed-8ef7-356ef28ac946	11503b50-d1a4-458f-b8c1-b72a9b7738c3	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4164946f-d146-4c8a-9f70-3858649b5cd8	b7402c3d-09ad-48b0-b2dd-b24e834700e1	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1607819f-fe80-4f32-9f5e-b21cff70592b	55a24e2c-d39e-4e95-aa9f-1e5c41861499	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b6b6c3ad-e6f6-4f07-a0f9-92565bd7a6ad	ac9feaf1-1256-4d9d-89a3-6cada13e6093	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e43ad8da-33b6-42f2-8210-44e63ea93823	ca0cbf4b-4981-44be-8682-058fb03b211d	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e4fe6351-2164-416f-a613-33a243472b30	830ba80f-ab68-4856-bf70-c8370e558a50	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dd6e0e6b-48e1-4d03-9248-83ffdeea4060	cd704f6f-bac6-4722-9807-4a07ac21b36c	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5bf61864-9045-4426-8865-22eaff57d673	fdcc3782-c42b-4b2e-a1df-8d4731f3daf3	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0837a4e1-4591-45ef-b5e6-65f75d189fd2	190bcfd8-3ed0-4e60-9553-1ea58f357d6b	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a660b525-65f4-401e-8f3d-035fe0f34042	284a08fd-1224-4719-b0e7-9f64eb674800	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e43d1c87-a855-4570-b7ba-d3989ba7864d	22de9795-3a91-48c8-9dfc-91d3a76a129e	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c5bbaf2b-708f-4135-bf84-3c0ab1c72781	938c4b04-a9a2-456b-b04c-dd6f38b8db10	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
01d2c61b-bafa-434f-8dfa-6794196ca79d	b1dbf533-a7b0-4aa6-8ee8-46b6330bc60e	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f81477f9-c7d2-4a6e-a432-7625e688ef2d	0efc1b63-a226-4d5a-8034-ddd817d2fe44	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2645c6d9-f10a-4787-84ce-ab649a0e65b1	44a99453-a953-4183-8d20-c22a868e493f	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ab291f00-415a-46d6-9e4e-7a78a2cd4b13	f86b40e8-842c-4271-9613-b1d187785cb3	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fb8d21c4-573a-4fd1-8979-b97526dd33ee	fbc0e324-5352-4cca-8238-d266147c4772	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
47ee6d27-c313-4abd-b86c-1c5ce20ca6ba	14c9d57f-a02b-4515-8e5c-49d4f1dca780	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
98c1ace6-6889-4512-997f-8635f0c0d3ab	f6fd1bd5-2d95-49d9-98ac-36cdbcdec0ed	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5a61d3ca-afa7-4941-9465-c05dc4165e51	466fa441-f1cf-474c-8700-35848cf70f8e	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
27e5ad9c-e714-43f7-b581-1b9b8dfaf6d1	2414c4dc-2e5d-41c9-8586-c16274874aa4	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e9993694-049e-42ff-a39c-a13c110ef943	668eceae-4e91-4718-bc46-8d250470764d	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
43063d14-5c3f-4544-909f-35c9b91c54cd	0e3f9c06-61a9-4c95-9d60-f1d8309bc69a	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a3674d4b-195a-4838-8695-d9184714ac75	2d227def-95f0-4408-8f2b-e9bcd5c2a99f	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
56d6e2a7-97f7-4676-820c-8838f8d06c08	b56d1636-9a19-4e1a-84ae-feac0fe9ee76	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e0505650-901e-4c37-bfec-0830211f7932	602e8e36-8eb1-47b6-8f9f-8708576e0187	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c74ccfae-0438-479c-9747-542b436d251f	3b011915-4c08-4d6f-b785-ba560c86e275	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
612a5e7f-5ba5-4367-afb6-8e1e13d2188f	a5bad36b-2924-4c10-9b76-f83b959795fb	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b02dd4e9-59fc-4cb9-8f11-0e7e41e97122	6e61001b-c45d-487d-947a-600c22d42854	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5a787a95-88fc-41a0-b8e2-25eabfdd3613	a2cf0363-a14b-47f8-89aa-f681135637e9	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
99a1eb43-d693-4b30-ad54-b31bda893198	d819eed1-777d-4695-9188-e357fd65db67	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f0f75480-cb8a-4e6b-8f76-9a9e315861a4	1ae7ec9f-ef49-459b-8b3a-12d77f22beb5	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e6acb62e-381f-4dd7-9854-e20b9e425b96	4019253c-e0e2-4f36-8378-1b6493b7743c	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d6040621-4286-40d9-b109-ce110e08e236	8d23a33d-6d14-41dc-a4e5-193efa8b12cf	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e5ffc766-014e-45b2-a172-121ee3e4ca4f	5a1605f0-3986-4954-8369-38cb11b599e5	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
44ffe42f-5709-4dbc-88cd-c0c46dbdf95d	7a423e39-1b24-4abd-b17f-5216ab3b21ee	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e62acc10-4853-4eab-8dde-e108454b5393	f3b5ee45-e700-40f6-814c-549dd1f0cff7	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a6df6a04-ccfa-4a28-af8d-4c7d7dd6a06e	bd897923-5e42-4e53-bd70-983c1d7466ed	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
05318251-4d84-469d-b9ba-cf489950315b	f81bfadf-6632-4baa-a539-19a2e3e6b3f7	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a918b903-051f-4c50-982b-5e422a3d6c6b	6fa01520-54a8-4b80-b8bd-090a7169d992	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
16ebd87d-d58d-440d-9517-af3165cbcde7	531a18a8-9888-4198-9584-cadb15277c25	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5b4060f6-3a4a-41f0-a213-f9e3a314bca4	8d4c8cc3-4aed-49aa-9845-4cbf4be6bed2	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c30156a8-b877-4b4a-a986-6497b59964fd	4675810d-1061-4fef-80ea-0a1e4d6da114	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
18d57399-e13c-49cb-9d3d-4d487bdc136b	e54f51d8-dd9a-4290-b15c-2cf9d9248818	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
20236ed6-3853-4ad2-9a55-8b731a929067	e6d1cae7-7c77-4291-a2ce-cc65ba5ab724	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
eff01f7c-f666-4c3c-9258-a829b2ac3516	595b2dd0-b6ce-434c-8446-ca10e16012bd	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
221c6386-2e8b-4450-a874-a9e57c3a6027	a274b654-ceeb-4fb0-a799-e21065b9a525	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
39e139fc-c7d7-4027-9520-4af96cbcbbdb	13067dc4-9d35-4243-856d-c82ecbefde1c	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3920747b-2688-4fe7-8045-b536f3cf0b06	e0f94f57-d32c-4497-8ac1-0c38647a86e3	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1dd2089e-6e48-485f-8a04-43cbc9f7c91b	d3881aad-d907-43fc-9a84-13560285d3d1	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
29a8f8a8-1b6c-4c33-a9df-1433daf615a4	995d0351-e5a3-418c-b43f-4d6ae33b0290	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
99a6018b-de5f-4b5b-a77a-0080526c6e1c	13b8f1c4-0a31-4984-a8fa-80565e315f99	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0dc48062-c6f3-4691-9e45-4fb140cb9886	1df69106-0f98-4ee0-a004-fb6455d249ef	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a4837b7e-155f-4cd5-a3fa-0d7f535fef73	04942120-239d-4911-8a9e-c9ab0cf9713f	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c74b4f1f-fa7e-4e90-9418-647eca18202d	627090ed-aab4-463e-a542-de207c75d4d0	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b9fd9402-882d-446d-8d5e-bf6de52a9f57	759dc6b4-f67e-4d02-9ff9-de9c75640ad7	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
92073707-f9f4-4416-9333-4dc599a5ff77	00673b89-1bad-4a9f-9090-b07da2e58f31	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f32a31d1-c336-43f5-9cc7-9960d32e2ca8	816819ff-69e9-494b-8495-416c739df9d5	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a51d629d-1c3d-4031-944d-79e6dbfffc00	cf94ba30-9f66-437d-b4cc-b82165cf1b1d	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f32f8bea-9eb9-4a58-b6a6-bc032b60623e	23d1a9ac-d56b-43b6-a97a-4c1556730b07	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
435bbcb1-fd4f-408b-bf1d-6e876370de5a	9b11a2d7-7267-4694-ad09-d78728bad7bb	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5b89bbf1-475c-4691-bd0d-dda1fb01400f	ba314667-746a-4ad3-af5a-546aae166b49	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7f0811fc-c41c-43fa-add0-b77ebb185eef	6a294467-1178-44b2-b3b4-556322a1b13e	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e287cb81-10db-433a-ac30-99e071eb5bd1	0c04eacf-3934-42f2-859b-840c6a26e1cc	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bc28ab02-c852-467a-a61c-55130e023528	abc48705-c533-476f-8854-c9aeed6020f9	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e0f8cd99-43ed-4864-b87a-f015588b25a5	4eb64ce3-c1d3-4b18-9341-5d22c5be2945	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bfe2cbbf-1bb0-48fc-8099-f3a7595612db	250b466d-44a4-415d-9d80-437d1e348a61	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9efc6c8a-f413-4ee6-9bca-c6025c63061c	09a7a156-a53e-4c99-8438-7ca83f8407ac	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
069598fb-73aa-4f6d-b3d5-30a3c193264f	740249aa-f9f2-4f14-8da6-2550be43f3c6	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2798fefa-6cf2-49d5-8214-d64d44e83fc3	f86b40e8-842c-4271-9613-b1d187785cb3	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fb0b9d04-b78e-490a-aae5-0b706fdc47ef	e1bdbef8-a3c5-421a-93b4-2b4e0b3fb42b	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
74ce779f-e606-41ed-a222-ca39200d0065	fbc0e324-5352-4cca-8238-d266147c4772	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c584abd9-2b26-4132-b340-a3166646d873	14c9d57f-a02b-4515-8e5c-49d4f1dca780	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6046dace-cd86-4f3a-89fd-ea3bb14b903d	2414c4dc-2e5d-41c9-8586-c16274874aa4	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f4f59b44-b5c7-4822-aed5-ebbf517f628f	b64c744a-2106-4c8f-967e-6f2256896e47	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4a637a2f-b868-45ac-9b3e-dc13a6e2f9ba	832f7ab8-d001-4e33-a38b-51939b79e838	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a818b053-99cd-4632-921a-a9f511c41a32	e0b55e37-e7e6-4829-b13f-ab791c6f4065	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8a226676-05ea-4d16-ad31-01860317fb79	b10e2237-7ad6-4fec-af3f-29b15e611fb9	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e6b8a692-e408-4379-a533-73f73ed91d93	7a5a80b4-96e8-4bad-ad3c-bf74dff200e6	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ea8acfba-feac-4d06-b637-5dcbde08a1eb	2d227def-95f0-4408-8f2b-e9bcd5c2a99f	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cb1c27f8-1ffc-42c1-886c-3279d6fd6960	b56d1636-9a19-4e1a-84ae-feac0fe9ee76	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
67880b1d-8edc-4f19-b3db-78ef0e71d8dd	3b011915-4c08-4d6f-b785-ba560c86e275	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f8f438c2-299e-4da0-a031-978105c808f0	a5bad36b-2924-4c10-9b76-f83b959795fb	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
305c5da6-8853-4e6d-9860-b23d18b816e2	6e61001b-c45d-487d-947a-600c22d42854	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3ef2b793-ed1a-4620-98ec-a336d0ac4d20	69868468-4f9e-4f11-b787-eca4627643f5	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
67569d13-6b87-474c-a067-26d8027345ac	a2cf0363-a14b-47f8-89aa-f681135637e9	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6423736f-567d-46af-a973-c17b89dd26c6	492ef8a9-d1df-4e12-9a83-3e7a68843db3	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d9bf2421-36bb-4d6b-bb53-d58e7814628e	1ae7ec9f-ef49-459b-8b3a-12d77f22beb5	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1c4d270f-2b56-4f2c-b7a0-b54b98ff66e5	4019253c-e0e2-4f36-8378-1b6493b7743c	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0a4ac9f0-0c34-4b53-abfe-5829a7a90f35	8d23a33d-6d14-41dc-a4e5-193efa8b12cf	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
76c80e99-e1c4-4be2-b949-e288267261aa	a6f1632f-c1cd-486e-b99b-9e916f631464	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c316cc0b-a57b-4685-950b-248f3c2082be	7a423e39-1b24-4abd-b17f-5216ab3b21ee	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3aa1d5ba-ebbe-4b2d-bb71-8b93e91ca5dd	bd897923-5e42-4e53-bd70-983c1d7466ed	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
afbf5cb4-2f15-43f3-98fe-d7080a14c69c	b54c6386-c578-4bf2-aa5d-74c0584998f8	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
824ef19d-d3e7-4e91-adb4-cd1350c0b875	f81bfadf-6632-4baa-a539-19a2e3e6b3f7	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
259b7b8a-2752-4503-82ce-6b5a87cfeed2	6fa01520-54a8-4b80-b8bd-090a7169d992	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aa0b99f4-7aab-4703-8255-bfb5b16520c0	531a18a8-9888-4198-9584-cadb15277c25	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
394a89c3-c5be-4d4c-9d67-d2359d72297e	4d83dd41-8ae8-4d0d-a238-73d873359ffe	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
92ec1ee3-366e-4cbb-a552-38ca428eea49	4675810d-1061-4fef-80ea-0a1e4d6da114	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bde5fa5d-3279-487e-9a8e-daaabc152d8d	e6d1cae7-7c77-4291-a2ce-cc65ba5ab724	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
495668fb-fb5b-4934-869a-49d47a19be13	ca0f3e41-b3ad-4aca-a6fe-d97f15665954	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0f5bf1b5-ba58-4f55-98a1-7fac3d3dfc3f	595b2dd0-b6ce-434c-8446-ca10e16012bd	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
db656d82-e20e-4b7a-8ac0-25b6330c46ad	c5e32a98-e908-4a4c-8bdf-0dc63afe6f91	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e90db1b2-7737-444e-a04e-9e8989857950	a274b654-ceeb-4fb0-a799-e21065b9a525	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
77c22196-58ca-42a9-96ca-a8ec4610f34a	13067dc4-9d35-4243-856d-c82ecbefde1c	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a15c0597-ff5b-4cef-8030-d9f9d2d4fe3f	36c9aa18-5906-4e3f-919f-c10a4b2ba706	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e2390860-4747-499d-9350-07cc54128c30	e0f94f57-d32c-4497-8ac1-0c38647a86e3	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
57baa850-64a8-4132-a5a7-5e1b074ac33d	591f9e75-758f-4b2d-be63-9e86e5a0e3b2	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
db19e2dd-ee24-4ac6-b529-33640ee988d3	04942120-239d-4911-8a9e-c9ab0cf9713f	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a6fb4098-13c9-4491-ad50-1fea2098d359	a69734cc-d3df-43ab-a9af-0330bece0d22	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
67dac8a8-abf4-4785-a95e-8178bb40c916	7d1bdb2f-3944-41d4-8ff0-4993b1a0fb29	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b6b1c37b-dad7-49fc-b018-210f4a147f03	23d1a9ac-d56b-43b6-a97a-4c1556730b07	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8c19d930-edd8-4ef7-96d9-1a4f21aaf261	9b11a2d7-7267-4694-ad09-d78728bad7bb	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3aa56a8b-b1d6-4b65-b9cd-78b144e47aad	6a294467-1178-44b2-b3b4-556322a1b13e	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f6d278a0-8332-444c-884a-fd9713cad1ee	0b13b166-ba35-418a-8073-f60fded38db4	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
677f64a6-fac8-4e7a-bc4a-6142c1ee5e04	abc48705-c533-476f-8854-c9aeed6020f9	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1e4ccb7e-48bb-4ed0-aaaa-ff71c7682c44	250b466d-44a4-415d-9d80-437d1e348a61	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2584730a-ef92-4140-9abc-e1fb4d22bb89	ac8cddde-b618-42a5-bdae-fa9c3a7b08a2	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
80610832-2926-4883-810e-73113c4377a7	08b51ad6-4b11-41ef-b44a-85f8c1a328f8	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
41de69ee-70b1-424f-84a9-75ce3930dadc	136e2580-5455-4eff-bea7-ba1a7c493208	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
24cd0a47-bbe9-4954-a862-618527e557ed	740249aa-f9f2-4f14-8da6-2550be43f3c6	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3df5275a-5d9a-4491-aa4f-fbea71efba40	72fc606b-ee87-4d2e-bbfc-721b7e6f1366	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1d293843-4e1c-4fd4-969c-27eb17304030	f25f511b-330a-4ca3-acea-5475decfb948	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a2ed38a4-5af9-41ee-b5d1-d8ee5c1a6f6a	e1bdbef8-a3c5-421a-93b4-2b4e0b3fb42b	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7e5f1af2-5c2b-4c13-a761-04531fb9e077	fbc0e324-5352-4cca-8238-d266147c4772	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9731cf27-d437-4c1b-a2bd-50afe702a175	20a6755b-e941-40db-9fb2-b889a609a2eb	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bd38f855-14bb-4583-ae58-5933531efbb2	14c9d57f-a02b-4515-8e5c-49d4f1dca780	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bb2b3c4e-4225-405e-87de-2a91db033165	f6fd1bd5-2d95-49d9-98ac-36cdbcdec0ed	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
734b1c18-3f73-4867-8f5c-c714279d9819	2414c4dc-2e5d-41c9-8586-c16274874aa4	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
31a91cc8-ee6e-45a5-868c-a882bed5f83b	0e3f9c06-61a9-4c95-9d60-f1d8309bc69a	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a1b7dbb1-0620-458a-a54f-8e96aa1b7879	7a5a80b4-96e8-4bad-ad3c-bf74dff200e6	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3e202206-d2bb-4160-8927-7d9be6064a72	a5bad36b-2924-4c10-9b76-f83b959795fb	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
29a7f7d2-1115-44b7-b280-e13217e53807	6e61001b-c45d-487d-947a-600c22d42854	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ed358f57-3da1-4dd1-a923-f77cbd79cc83	3fa221eb-445c-47f6-8395-abbe95523b7d	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1875f749-18e6-47f4-80f9-b124546d2c76	1ae7ec9f-ef49-459b-8b3a-12d77f22beb5	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3196fd1a-31d1-48b0-98da-2a6ba56dcaf9	8b22f170-ca9a-4e2a-881d-add96cfa14d3	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
16de84e1-6020-45ef-8a74-264ef4e27a20	7a423e39-1b24-4abd-b17f-5216ab3b21ee	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a21158f0-3820-44a6-825c-efa6a4fb2702	f3b5ee45-e700-40f6-814c-549dd1f0cff7	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0e63d796-2a13-4b00-9108-56296e8dc0ea	bd897923-5e42-4e53-bd70-983c1d7466ed	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
180896fa-6e3d-4a62-909e-c048c1ae3312	42364e13-5ea5-4727-afab-98a08ad12464	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
37c049a0-e4f4-46bf-aece-7619e5fa751c	d8f986e2-fad1-41a3-abe7-70fa021cfa10	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c4af3717-99b7-4fee-879b-2641258bd05b	9d01e63f-7f80-418f-85a5-1e65ec149b60	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
461297e0-8f7b-4ae5-a022-48ea2d383003	f81bfadf-6632-4baa-a539-19a2e3e6b3f7	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
81dd7bd0-4258-4e4a-8b73-ce31a62c5b29	8d4c8cc3-4aed-49aa-9845-4cbf4be6bed2	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d398086e-624c-46d7-b64a-89222f54c9e0	4675810d-1061-4fef-80ea-0a1e4d6da114	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c1d5be96-e9ed-43dd-b246-9da3c33f7e1e	e54f51d8-dd9a-4290-b15c-2cf9d9248818	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cc304569-78ef-4cb4-8a8f-89ffbdf3ca08	abd62060-26d1-4274-8971-bb1178bbdd12	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d13c7894-f46c-410a-b8a3-b8ea190b1d3e	e6d1cae7-7c77-4291-a2ce-cc65ba5ab724	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7166f2b1-ce55-49fb-af67-0b0e2628f94b	ca0f3e41-b3ad-4aca-a6fe-d97f15665954	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4b9359e1-0bc5-4ed0-9b42-4cf0a6b064d7	e19d4f14-ee4a-466e-8f9f-c6429ec0fa35	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2a5f344d-334e-416b-8647-bdf1e965798f	595b2dd0-b6ce-434c-8446-ca10e16012bd	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
771dfb76-53ba-4d78-947c-f973fd5b2106	13067dc4-9d35-4243-856d-c82ecbefde1c	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7a252c55-e8d3-4dda-ba0d-23593b531663	36c9aa18-5906-4e3f-919f-c10a4b2ba706	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ac4153fd-0ffa-448b-9dab-29a593ea0a78	e0f94f57-d32c-4497-8ac1-0c38647a86e3	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ec8fb5d7-496d-4776-b34f-bcc0cd39ec90	d3881aad-d907-43fc-9a84-13560285d3d1	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
76d226e5-1f62-47ee-8423-9f542cc899c3	56b254ea-f6ce-4fab-a017-2cf42a0d7edd	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1025d091-fac1-4555-96e4-1a42ade7e789	1df69106-0f98-4ee0-a004-fb6455d249ef	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aad6f4e2-50c1-41f9-8017-258ea1be19f0	591f9e75-758f-4b2d-be63-9e86e5a0e3b2	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
02ea2fc7-e3f1-43c9-a261-1764b92bf6bd	e3259519-bc58-4590-9af9-da316791190c	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0d446472-8a51-4574-9d88-21729b712a87	759dc6b4-f67e-4d02-9ff9-de9c75640ad7	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
262ea8bb-e9ef-48ef-b190-0b843906ba56	816819ff-69e9-494b-8495-416c739df9d5	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7ded36da-bc45-47ab-a197-2133ddcae73e	a69734cc-d3df-43ab-a9af-0330bece0d22	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f5fc2f62-0c2e-415d-ac86-6b427312ac33	7d1bdb2f-3944-41d4-8ff0-4993b1a0fb29	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0cf9e937-7660-4657-88f3-9dba1c4e9dec	c9204d0a-b6b5-4189-acf6-f87033aa7809	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
66a63cc9-f455-4e08-b116-0e5ced9246fe	9b11a2d7-7267-4694-ad09-d78728bad7bb	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
58feb250-93b1-4272-9c2c-cbd8b40572ad	ba314667-746a-4ad3-af5a-546aae166b49	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
de6a2925-ca2c-4e28-b67c-454ad824431b	6a294467-1178-44b2-b3b4-556322a1b13e	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
632e6076-e92d-4ff5-867e-f0b88bb8cae8	0b13b166-ba35-418a-8073-f60fded38db4	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2dfe27a8-4dd7-4890-b8d1-62917c181904	abc48705-c533-476f-8854-c9aeed6020f9	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c974800a-d692-4483-bb4c-4ffcf95649e6	4eb64ce3-c1d3-4b18-9341-5d22c5be2945	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
43965c61-5a6e-4ffd-a4eb-605e948efe34	210e5325-4a69-42d0-ab43-4e20140fa2bb	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3e64ee7e-37d0-48f3-a34a-a29a645f8aac	08b51ad6-4b11-41ef-b44a-85f8c1a328f8	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9cd22299-3d09-4ccf-b6b6-4fca7b051e2d	136e2580-5455-4eff-bea7-ba1a7c493208	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9362d2f9-6472-4cfd-89e5-beed9cc8a016	09a7a156-a53e-4c99-8438-7ca83f8407ac	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
336a7933-9209-4e5f-a487-8161ad5cf70b	740249aa-f9f2-4f14-8da6-2550be43f3c6	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a7cde7c6-9f8c-49b0-b222-45c93438a76b	72fc606b-ee87-4d2e-bbfc-721b7e6f1366	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
07c9c6f7-59f4-4654-ad93-03ba7badbf3c	44a99453-a953-4183-8d20-c22a868e493f	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8433f9aa-f785-4a46-addf-5c86a13da825	e1bdbef8-a3c5-421a-93b4-2b4e0b3fb42b	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
351c19a6-bcf9-4f2d-918c-6e4ec14e853b	fbc0e324-5352-4cca-8238-d266147c4772	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9ee6b063-4c29-4bf5-9f92-cfa686fa13bb	d7c425d5-89fe-4073-9483-f0cfd19a2544	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4f0a9c14-6c34-4f87-ae77-f0c41ab8cff2	a82627ac-8536-4013-b84c-ab787685a453	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1b350140-1e4c-48a6-a894-d6510c3e0c9e	466fa441-f1cf-474c-8700-35848cf70f8e	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0a065429-010d-433e-bacd-5c771696bb3e	2414c4dc-2e5d-41c9-8586-c16274874aa4	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
261a4808-0bb2-41d2-99be-4c29c8ff9cc7	b64c744a-2106-4c8f-967e-6f2256896e47	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ae97db5f-2bbf-4ee0-b7f6-c2f15808d67c	b10e2237-7ad6-4fec-af3f-29b15e611fb9	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4c480e48-ba3f-4440-9ac1-b005188e7638	8e6c3848-93ba-479c-b98c-2a02e21f1596	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e6394400-8107-458b-8969-ba55f0a36b3f	2d227def-95f0-4408-8f2b-e9bcd5c2a99f	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
277e3665-1c86-4b4d-850e-3bc64fc3562b	602e8e36-8eb1-47b6-8f9f-8708576e0187	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bccf0d1a-c837-4c41-81bb-1041b853246f	3b011915-4c08-4d6f-b785-ba560c86e275	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f75f5c4e-15e7-4dd1-ae9b-f5340b51d618	a5bad36b-2924-4c10-9b76-f83b959795fb	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c47f39a8-2498-4c76-9386-fbe78d80dc28	69868468-4f9e-4f11-b787-eca4627643f5	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ff72234b-8aa4-42d6-8924-9e160f62e454	a2cf0363-a14b-47f8-89aa-f681135637e9	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
51d4457b-36cb-4747-adeb-404fc390c92a	7f0b2ce8-cc3b-405c-b05f-7f8a624c9de7	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e18d0afc-ea8e-40b5-9c50-30816d325c82	d819eed1-777d-4695-9188-e357fd65db67	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e4453853-9da3-48e6-8851-8bb19c650ceb	3fa221eb-445c-47f6-8395-abbe95523b7d	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
800f819a-21b9-4eb0-9448-71012853414d	1ae7ec9f-ef49-459b-8b3a-12d77f22beb5	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
59575383-bb72-4949-a02e-2dc28e6b1e41	4019253c-e0e2-4f36-8378-1b6493b7743c	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b6b6f90c-f26b-4c3e-ac64-80d520f11d4e	5a1605f0-3986-4954-8369-38cb11b599e5	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7eda5d1a-a805-4759-a336-09953bb4f9cf	8b22f170-ca9a-4e2a-881d-add96cfa14d3	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7eec6a6c-fd1f-4684-95a8-597f704a0944	f3b5ee45-e700-40f6-814c-549dd1f0cff7	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2663518b-d8f1-4b64-92ac-f8c41662f4f5	bd897923-5e42-4e53-bd70-983c1d7466ed	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c0c846a1-4715-45a6-8312-81e1293c2846	d8f986e2-fad1-41a3-abe7-70fa021cfa10	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3e4168ef-0e45-486c-9a0a-44f4f7a46b91	9d01e63f-7f80-418f-85a5-1e65ec149b60	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7877736c-4a3c-4404-b689-13d518e619c5	28759fdb-da41-4cfe-96f0-fffb73fa312f	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0a7aa24e-a48f-4b9e-88c4-168610d6cd9a	f81bfadf-6632-4baa-a539-19a2e3e6b3f7	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5d1eb415-387a-4786-982f-5b3377aa2c35	6fa01520-54a8-4b80-b8bd-090a7169d992	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f6221411-aa35-44fc-a9b1-f43023327009	4d83dd41-8ae8-4d0d-a238-73d873359ffe	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fbc0b8ed-49c8-452a-93aa-19612d054966	e54f51d8-dd9a-4290-b15c-2cf9d9248818	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2d6a8eeb-79ee-4c97-9e4c-bc348160cf0d	e6d1cae7-7c77-4291-a2ce-cc65ba5ab724	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1b211e22-7741-4819-8367-467d3fdd4a16	ca0f3e41-b3ad-4aca-a6fe-d97f15665954	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
290ee229-4cd8-4c64-b9d8-57e010b8fa21	595b2dd0-b6ce-434c-8446-ca10e16012bd	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d5006b37-1c0d-4601-8c21-6608646e22cf	a274b654-ceeb-4fb0-a799-e21065b9a525	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b42adb5c-ed48-4a71-8a53-ad15bfd42f88	13067dc4-9d35-4243-856d-c82ecbefde1c	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7dff1af3-d24e-4426-8db4-d2bd37f11617	36c9aa18-5906-4e3f-919f-c10a4b2ba706	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
af0e3bde-f119-4fc8-a38e-6e8e7e1844d3	56b254ea-f6ce-4fab-a017-2cf42a0d7edd	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5823d464-daab-4eec-8a3a-4ce216f33ea2	1df69106-0f98-4ee0-a004-fb6455d249ef	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4f0a2352-7ffe-4eee-a6a2-8040c215df6d	04942120-239d-4911-8a9e-c9ab0cf9713f	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3e8372e2-e626-417f-a352-aabaa5fa065f	e3259519-bc58-4590-9af9-da316791190c	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7238108e-52d2-4b59-a3ed-c11c78bc5faa	00673b89-1bad-4a9f-9090-b07da2e58f31	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9cde6032-9d07-49fc-ae5a-8626f6454053	7d1bdb2f-3944-41d4-8ff0-4993b1a0fb29	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
10a053ed-b151-4f8a-b39e-137ed300bdaf	356692e4-1e28-433c-a5f9-b28c943e96ee	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
48e6db9e-a778-4058-b8be-278173e942b2	23d1a9ac-d56b-43b6-a97a-4c1556730b07	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2470fd37-55f3-4c17-a2b0-f227b47e551c	0b13b166-ba35-418a-8073-f60fded38db4	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a1d6a4ae-7707-4fc8-bb81-74249a9df277	0c04eacf-3934-42f2-859b-840c6a26e1cc	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
91e20930-9c5a-4c49-88d9-ced1c4d24569	4eb64ce3-c1d3-4b18-9341-5d22c5be2945	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
244bde9c-658b-47e4-976a-9cb29155a0d0	210e5325-4a69-42d0-ab43-4e20140fa2bb	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2f2a875c-f9ad-43af-a249-7ca7f02be9db	250b466d-44a4-415d-9d80-437d1e348a61	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
61dabde1-c6d9-4940-8c3f-d1d60c71b6a9	ac8cddde-b618-42a5-bdae-fa9c3a7b08a2	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
18b0bede-fe54-4a32-a61c-5fac52366752	08b51ad6-4b11-41ef-b44a-85f8c1a328f8	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bae92b33-935c-425c-9725-ddb0e142baf8	136e2580-5455-4eff-bea7-ba1a7c493208	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
46557d64-c681-4b3e-8f2d-82ce073dd08b	740249aa-f9f2-4f14-8da6-2550be43f3c6	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
605054f1-abca-44d1-b6e6-02d9d254bc00	f25f511b-330a-4ca3-acea-5475decfb948	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
12a54c1e-58bf-4911-84b0-554bea893b5c	f86b40e8-842c-4271-9613-b1d187785cb3	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
92c875ff-1ca9-4c5c-b17f-bd1c2c3eead5	e1bdbef8-a3c5-421a-93b4-2b4e0b3fb42b	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dd5b68a0-c2a5-4f21-ab8f-7b94e4b02d36	fbc0e324-5352-4cca-8238-d266147c4772	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8884b5b9-9ada-4e26-b34e-1ead0375c72e	20a6755b-e941-40db-9fb2-b889a609a2eb	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f80334e0-abca-4f0d-b432-61f107555700	a82627ac-8536-4013-b84c-ab787685a453	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
22ec6983-1597-45ac-8cd6-5cf107f1bc86	14c9d57f-a02b-4515-8e5c-49d4f1dca780	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b1e7364f-2a95-44e3-9b3b-2a96c59a1edd	f6fd1bd5-2d95-49d9-98ac-36cdbcdec0ed	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
43fa56be-eed3-49bf-98af-78f55784faf6	2414c4dc-2e5d-41c9-8586-c16274874aa4	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
40bb2818-73f7-4d92-8d2a-a9d8c725ec11	0e3f9c06-61a9-4c95-9d60-f1d8309bc69a	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
642df3f4-fb6d-404f-a9b6-acf24c55560d	8e6c3848-93ba-479c-b98c-2a02e21f1596	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0ef265fe-c8e1-48f6-81a9-6dce3c314d0c	97cf823e-cbee-486d-b8f1-ed770a7df88d	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7622d5c4-55b8-4ff5-9928-9bf4e845698f	2d227def-95f0-4408-8f2b-e9bcd5c2a99f	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
91ad121a-3fb0-4623-954c-69e484c803dd	b56d1636-9a19-4e1a-84ae-feac0fe9ee76	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
76cae98f-c01b-475e-bab8-6b35a48638ab	3b011915-4c08-4d6f-b785-ba560c86e275	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3edde2e9-4b5c-4a14-9527-6094e6f984b7	6e61001b-c45d-487d-947a-600c22d42854	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f57fd72c-3bf6-441c-a8f8-ce99808d3394	69868468-4f9e-4f11-b787-eca4627643f5	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d8d70330-135a-4cac-ad66-fa35315975d6	a2cf0363-a14b-47f8-89aa-f681135637e9	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e5b3548d-73e9-4bb6-9620-1b17e8dceac3	7f0b2ce8-cc3b-405c-b05f-7f8a624c9de7	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e6bbbc04-fcb1-4c2b-bfd4-a7751bc74468	492ef8a9-d1df-4e12-9a83-3e7a68843db3	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b1e0e551-ac19-4ade-a0fd-e2e68720089a	1ae7ec9f-ef49-459b-8b3a-12d77f22beb5	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6b8fbc75-05fb-4fd9-ad09-1e7c8a289687	db809fb0-958c-435a-9f45-b927e6c8f4a9	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dea567a7-6be5-4e11-b512-04108d6fcfe7	4019253c-e0e2-4f36-8378-1b6493b7743c	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ce82572f-a521-4db4-9ab5-eb47a6fbfd35	8d23a33d-6d14-41dc-a4e5-193efa8b12cf	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e5fbd82b-ebcc-4aab-bea1-5b90d0b598b6	51a9246a-31ff-4011-80f5-4c55850450bf	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2c34896c-2d7b-4fed-bb13-dafaee44f8ab	5a1605f0-3986-4954-8369-38cb11b599e5	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cdfa6b78-afc1-4fd2-9cc6-e49569f0de5c	a6f1632f-c1cd-486e-b99b-9e916f631464	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2d79e260-dd6f-4542-965b-88b199daf6a6	7a423e39-1b24-4abd-b17f-5216ab3b21ee	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
99d0c6b5-2e16-4593-abe9-31f5746d139a	f3b5ee45-e700-40f6-814c-549dd1f0cff7	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6671d0be-5885-4b3a-aa89-f71b3ab40720	bd897923-5e42-4e53-bd70-983c1d7466ed	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dd9b84c7-280a-4ae2-88aa-4ac4b7252f99	6cd02fd8-fe5a-4160-b6d5-d0ee3cdddf7d	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7ba89bf4-2dd6-4a79-bb03-1d6f95c985dc	42364e13-5ea5-4727-afab-98a08ad12464	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
81830404-dacc-4b01-86b5-1e2755b2e556	b54c6386-c578-4bf2-aa5d-74c0584998f8	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
443fa43e-7467-455f-9ba2-1e40c20905e0	9d01e63f-7f80-418f-85a5-1e65ec149b60	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
96dc2587-8ccc-4af0-9e55-5ae1be17ea8c	6fa01520-54a8-4b80-b8bd-090a7169d992	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a6d0df41-3e11-4cd9-941b-811f854d8727	531a18a8-9888-4198-9584-cadb15277c25	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e7f42658-0661-4355-b1c2-ee9166864298	4d83dd41-8ae8-4d0d-a238-73d873359ffe	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
04a7d490-aafe-421c-88a0-8d656af2ac77	4675810d-1061-4fef-80ea-0a1e4d6da114	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
70479919-a713-4214-82a0-f751463d0be3	abd62060-26d1-4274-8971-bb1178bbdd12	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
52de40a7-2340-4082-9e6b-fc3ca2b4c913	ca0f3e41-b3ad-4aca-a6fe-d97f15665954	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
469e88e4-a6ef-46bd-840d-11837b5cf11f	e19d4f14-ee4a-466e-8f9f-c6429ec0fa35	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
478e9e7f-7116-46b0-972e-973cd6b4bb50	595b2dd0-b6ce-434c-8446-ca10e16012bd	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fc1ae753-7c49-4617-a595-a3c09eced610	e0f94f57-d32c-4497-8ac1-0c38647a86e3	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f1649e35-9733-44c7-99ff-29d4bef3b7ff	d3881aad-d907-43fc-9a84-13560285d3d1	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b6b51625-791f-4a04-ac54-b74f5c952491	56b254ea-f6ce-4fab-a017-2cf42a0d7edd	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2625cbbe-7a6c-4ad1-98a3-eb1cb0c6803c	1fa05291-8d71-4d7c-b2fd-0f9802510233	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d63cd322-478f-4443-8e20-755bf37efa54	1df69106-0f98-4ee0-a004-fb6455d249ef	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b881dab0-ffb9-42ec-bdd2-3d314b836acd	04942120-239d-4911-8a9e-c9ab0cf9713f	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f3e4bce4-f139-47cc-99a6-1dbc91068259	627090ed-aab4-463e-a542-de207c75d4d0	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
14c2ad7f-9c54-4551-a84a-d306bf347804	759dc6b4-f67e-4d02-9ff9-de9c75640ad7	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
64894fa2-867b-48f0-91ed-9350315a38e9	00673b89-1bad-4a9f-9090-b07da2e58f31	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6bb74cb5-a0fd-4018-aa1b-0c52b6095f96	a69734cc-d3df-43ab-a9af-0330bece0d22	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f3573e81-7757-4af5-9d84-904ccfc829fd	c9204d0a-b6b5-4189-acf6-f87033aa7809	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7b3e377f-cc69-433e-8206-252847b6a1bb	23d1a9ac-d56b-43b6-a97a-4c1556730b07	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
704e1cad-6eba-41e7-aa37-5d721ae3ab56	ba314667-746a-4ad3-af5a-546aae166b49	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
92b0812c-0692-48cd-81c9-b1363ad49c13	6a294467-1178-44b2-b3b4-556322a1b13e	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
af82fc9a-e4f7-42e5-b02e-266e9992ab85	0b13b166-ba35-418a-8073-f60fded38db4	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7b7326ad-b728-4168-a8d1-156c1f055dea	0c04eacf-3934-42f2-859b-840c6a26e1cc	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ae1a8d1f-39d9-4007-93d8-f10b9c0fbe6f	8be2649d-eb5f-4300-8681-ae37671e2e94	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
85a175c9-dc66-4173-9bc4-fbce73387989	abc48705-c533-476f-8854-c9aeed6020f9	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0b8c1e0f-a55a-40e9-ae53-852dd1486149	4eb64ce3-c1d3-4b18-9341-5d22c5be2945	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b6214827-5574-4e82-bea3-59c56b94e8dd	250b466d-44a4-415d-9d80-437d1e348a61	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
25c0eaf8-8a37-44fc-a92b-a3a4da16bfab	ac8cddde-b618-42a5-bdae-fa9c3a7b08a2	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5edb8801-f476-4f2c-b007-9b8dfd626fa4	136e2580-5455-4eff-bea7-ba1a7c493208	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6633e6f2-8b67-48e6-b6ef-a4b48c8e5295	72fc606b-ee87-4d2e-bbfc-721b7e6f1366	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
55811038-6fac-42ad-8080-c9dc92ad82d5	863b6ab2-e859-4ff8-8b73-15adee4ee275	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ea2e76b7-237d-4b5f-8a64-7861159b585f	55dbbc8f-f4d7-4b6e-b1e7-e26cd496f084	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f0620ef9-e4f2-4f5b-9cf7-96b211c0790a	26ad8cb3-a76d-4d91-8c88-e4ea105565c0	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
09da7dd8-60c9-4e5a-a30b-350a81bf0351	862078f9-7dbb-4ef4-b0c3-01ce8f161bf1	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c86a6110-843b-49fb-8a30-391635f5bdfc	1be7f127-29b7-45cd-88d6-df2ed68b376f	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9c9c896e-9f86-4d33-9704-b6deb407a582	6046bcec-49bd-4d09-afd3-bbe7204f480c	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6b7ecb19-9224-4796-aaca-c089c2f92bd4	954e0853-3552-495b-a722-1ed6d1d2b2cf	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
72071116-6f06-4ff9-ae74-b2a7c448e963	629ecc62-b715-43eb-8d88-94182cbf4861	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6e07aba7-bc12-4e4a-a94c-f139756ce7b5	9d9a2d0e-838d-43c0-85b0-de303a1437ad	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bf508887-cc9d-48a6-8df6-38ad2956207f	8230d118-9b23-4146-874c-2da5c9a93330	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b1c4e39a-23ae-4625-8ab6-2eeca13fc01e	4b573fbf-955a-4b30-9f74-55d730fbb597	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
96f53786-47b1-4b1f-9ccd-d029c69174c7	2f418d8c-ea01-4e48-be76-26188728aad9	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b1af8c4e-4bfa-4a05-ade6-99fb0ae3e2c6	a31f4a9d-efd7-42f5-86a9-4989c461d66a	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f194d5e7-8d06-477e-b6b0-6e0de983a2be	d5702a38-ff3b-448a-a78c-e1e680c85ebc	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0282a0aa-fcbd-4139-95d3-6b86cd74bf22	b037fa33-d9c5-45ed-9733-b6a240ff5c7e	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cefcae7f-d291-4d0f-8a06-c34b20a15013	9341fbe7-bbd8-4055-972b-9a73a75e76ed	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
27060003-fa60-463a-b66b-14d9093ae29c	4577fa2c-5f15-4c9a-a549-1a6b98237a59	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
56273593-12aa-4400-94b9-8ef5c30f2f7e	4238c8a3-687d-43cb-a4d9-308260f318a8	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
18886a48-b455-4312-96d3-70395ca0740d	d4bc7faf-c49b-48b2-8c6e-af149fba72c9	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7ade59aa-543b-4988-a376-b93ad5f5fe60	f49b5955-9697-4596-b71c-c9657fd123d2	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e519f7f7-c254-43e1-b02b-da3cfbd2ece6	62d61404-40b0-4cba-b78b-62f3832510a5	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
65113a8f-ad56-402e-a8be-7653459d8325	1d423a13-e963-4e1f-aece-53ae34c631b6	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
99de601c-ffb0-4f45-b101-9bdcf981de0d	757cb740-41d6-4026-a025-51bde08cfc1c	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
efd4ba19-ec2b-409d-80ef-7124852dd505	47b4e4d9-d205-44ee-a377-4b75c9a45120	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ff989921-2023-4474-b2e7-d7bc17ef5625	e72bdb1f-8b42-412f-b85b-9ccc899e670d	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
edcf73c8-590a-469c-8b21-ac5294f3a1cf	bfbd56c6-d4c8-488c-adab-297fe726056e	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f8b57c83-bcab-484e-a38f-e1382840b1cf	c8b4cecc-c02f-4a53-aecf-58282f3ff909	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2a304bd0-b10c-40a8-974c-53628d9df391	95e71917-290e-45c7-9d40-66700df681d4	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
96f98c76-b98a-4f43-9db3-cb7cf075ccfd	43ab6d45-456d-4da6-bbdd-4a424459891b	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1003d99a-c3ea-4b2c-8e1d-34f433f2b653	695a98bf-90c5-42f9-853e-7b7114255faf	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0381453e-75f7-4b4e-93a9-e75366ecbcda	dfe38c75-69b1-4bb1-a7b3-cb4faf0fa9de	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
149b19f8-02d0-4b74-932d-f8168b88e016	e8280fe1-1861-4bd8-9d1d-53b0c310b2af	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6aafe52e-122f-464e-b21e-da0ef7dbb1ee	71e42543-3ae9-456e-8a6d-c4faa74f682b	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
10ad3580-5d15-4b7f-aadb-2164cbd27333	e1984b60-b05d-43a4-be47-7e54a36286de	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
95317b3e-f779-4feb-a2d3-7be04da3679d	534e84f1-cf3c-464f-a0d8-e44df0773945	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
090d5bfc-a12a-46ed-8f0b-0e1f215fab74	435640c2-69c1-4d26-b06c-10e250ff09e7	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3fdb73c1-940e-4417-ba7e-d27f2e0b04c2	20653ba2-705d-430e-96c4-f03f33c91a6f	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
01873ff4-6e33-4e71-80ef-502d532763a8	6942acc4-b06d-4c05-a038-90372b1cc6b5	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cde70331-1b18-4a9a-b754-5397dc649355	fac6f0b3-67aa-487f-ae19-14eb21f90530	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a4862590-b025-4cd9-b47f-5e0f314bf129	1d4a7fac-998e-498e-ab29-9f8712f008ed	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
974e92b3-8eaf-453c-bd08-6de55e66211e	d03e8320-d368-4d02-b336-8e47dabe92da	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ff8b3c0a-50ac-4bf3-ac17-cf5df32e594d	ceacd105-cb2b-4901-a20b-48a764c07b88	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
63b01211-5e9a-4ca4-a733-e58605f7a5bd	bcecc802-2eb7-4857-9ce8-7ac3c2e7a279	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
843f3225-3360-4ee6-b2a6-3f52ddc821bb	c81063d9-5398-40b8-8261-2d916be4f04a	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aae1cabb-e4ec-43e4-a130-c7fc51233d68	0c276263-b0bb-4526-8210-e66fb4489174	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
723767c2-ade0-44b4-a256-4a2e31c99849	b54ba154-8792-49e7-903d-ab4620147a9e	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bb089657-6ee2-4fa3-a043-f1af120ad87d	a5158d3a-576c-4ac5-930a-3d3fe9ec94d3	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6cfebf39-5b58-4088-b3b7-52284ee63867	7730492d-a7ff-4cb1-8300-5ddd5232ed44	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b40a0f12-ed2e-4ad9-b1d9-aaac0a625f67	3de0d3c4-e32e-413e-a102-e8a29355a013	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cafe9103-82e9-41e9-b835-c7f9c7ec5fc1	5434cb96-68d9-4c6a-a51d-a5073c7324d0	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d16515a2-96a9-4efc-be32-ad23c925d2f0	b56975b6-7460-4183-8ed2-208c27b57e0f	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
93605782-7e5c-4c38-9254-0d9902728b8b	e3ce072c-32f4-4e7c-acec-a873a51481f3	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d65f459c-55b8-480e-b3af-8d4ab1ecb890	e0897866-a534-421b-9fcd-a7ae0a1694fb	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
93d991ff-a717-4be0-bdf3-7f870e12e3f1	2b45ed00-e159-4e44-ace6-224fbafc1aed	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bdb79373-6296-469e-b6ca-19e65dcaebe0	b0004f03-7905-44d5-814e-1764bb45ed0e	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
71cd5f2e-0058-47be-bba9-f77b3a72380b	f15558d0-171b-42f6-93b0-4f2c7853984b	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7b411f4a-ea5a-4d64-bbf7-0ac565dcebea	fe7243d7-d665-484e-ac80-7b946f15ecf3	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
110b5c39-fbef-4bfd-b46a-6702acc0e085	3a2fef4e-66ee-46d3-af3d-6ddc6bc7e395	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bd47b263-ecb9-4a02-b535-02bb62c48a30	9226008b-5420-42e3-92c1-2e02a8d4ad04	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0e310c38-3ee8-4723-a9c6-f00cf7c8ff5f	1cc5f42d-9241-4a29-9aa7-42f756326d2e	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
40f6173e-badb-47b9-ac8b-9099f5fcd67a	37db6546-12af-4f16-9eb4-882b2c212075	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a679b02a-c97d-49e5-ba88-79152cf54e61	91c4c38e-af51-4885-9e46-1852ad8a0164	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d7d6f1e4-961b-4f0c-90c1-2e0f80528d08	efb906c4-7a40-4a74-8764-bd68890e4049	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a14792fc-c658-4ae0-b07d-3abdbd774057	55dbbc8f-f4d7-4b6e-b1e7-e26cd496f084	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6dc9d53d-6761-480a-9efb-c3f3902db30f	862078f9-7dbb-4ef4-b0c3-01ce8f161bf1	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
edf0af84-8f48-49be-ad70-661e99520ac4	8a558b6b-f381-48ef-98a9-df90ea327932	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
723f18c6-be81-4f6e-b190-f4ac2df4706d	6046bcec-49bd-4d09-afd3-bbe7204f480c	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
90b8874a-c93e-4f3d-946e-f273239f6ea6	a35d5ae9-8eb7-4c67-bd41-ebb21a798f60	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dcf70572-ed25-493e-bf72-b825b0f8a45c	629ecc62-b715-43eb-8d88-94182cbf4861	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
34aef9a6-0dc6-454a-a359-1c9ccba589ff	4b573fbf-955a-4b30-9f74-55d730fbb597	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4e4133eb-4d79-4419-9e65-ff7f480b14ed	7c3d7994-aac4-43d2-bd39-8056ef6caed4	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d9d0b14e-fcc1-4589-877f-d5464a41af74	49bc3522-75de-4f7a-b3f2-679285b578e2	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
92625a97-99d9-45f3-b92d-dc9676bc2c14	a950f7a4-96ed-43e9-ab61-4c271d75fde3	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9ab0f7fa-10c1-433f-bb9a-3c1460ef293a	614c44bf-b66c-46b0-a034-860997aa05d5	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
46c01dcf-36a5-41a3-9466-9503f41c3235	d5702a38-ff3b-448a-a78c-e1e680c85ebc	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
01dc54f9-fb81-4a23-bcdf-5e3a0e33ef6e	9341fbe7-bbd8-4055-972b-9a73a75e76ed	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
99570749-f6ff-4b83-995f-7126f2cf9222	4577fa2c-5f15-4c9a-a549-1a6b98237a59	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1843192e-09ac-426e-a1a0-e4bba5a4a9c5	4238c8a3-687d-43cb-a4d9-308260f318a8	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
92995fa5-3ea8-495a-979f-f2b5d4b4199c	d4bc7faf-c49b-48b2-8c6e-af149fba72c9	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
924e77d2-a129-414c-907a-e605e4703557	f49b5955-9697-4596-b71c-c9657fd123d2	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
476ad4ee-705a-44ea-9003-3a77f11b920a	64cd20e2-541a-40b1-8a07-9ebf2e8dafd5	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ccb33d0d-e041-48e5-b1bd-e5ca247f6293	0edbbaac-714d-49fa-9007-d4aeba519de6	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dc324e8f-82a9-4d55-bd16-296398803610	2ddb66e2-e466-4d57-adec-3e5336eadd13	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6e6de591-3816-4c7d-923e-374458022acf	17e01557-a715-4369-9e06-07933a7fdef9	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e2445429-20bd-45d2-a857-b05a78f8c644	e72bdb1f-8b42-412f-b85b-9ccc899e670d	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d924641b-75f3-4a44-b180-9012a972ea70	24fc4473-5e3a-4211-b670-389ae1d49019	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6b66f89d-57f2-4e6a-b97e-e87bfbf99b66	bfbd56c6-d4c8-488c-adab-297fe726056e	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0bad401d-6242-4dc6-a38f-731467078d17	43ab6d45-456d-4da6-bbdd-4a424459891b	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b0b86a41-1021-4f5d-8f93-32939ac40a1e	695a98bf-90c5-42f9-853e-7b7114255faf	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7856ab68-da21-440e-bc90-e865dfd7e8eb	1f47fc16-b31b-4605-b7ba-e57ed6a7dcae	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
41331e5f-74aa-4726-bbf1-44d8fba346df	71e42543-3ae9-456e-8a6d-c4faa74f682b	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9817a314-018e-40c6-9c51-ec09b07b1243	e1984b60-b05d-43a4-be47-7e54a36286de	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b74dcf08-f8c9-452a-924e-5c1602624d13	534e84f1-cf3c-464f-a0d8-e44df0773945	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
59b1cb3f-f40b-4219-a4a3-56d1c7875c68	da515f57-0b19-4100-8eb5-9460c39f588c	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7d32f723-1d49-4a6d-9316-bde963fd0786	42bd9606-715b-4715-a7fd-fe81dabe324a	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
17ee30ae-c8ca-4f73-9782-f66e269b384b	ba18ecd0-a61d-4f67-9c07-0bc0031e737e	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
95fc867d-ad71-4467-af72-06f5b172b854	37792710-05ac-42de-9b1b-908b916f4b35	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2da6aba7-e96f-43d7-a755-bc1d0b837e4f	1d4a7fac-998e-498e-ab29-9f8712f008ed	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
95793309-c760-4cb3-a025-7a641b30286f	82f260e1-3880-40bc-8271-bc652f32af64	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e7d47f16-7dc4-48b2-aa90-ae1f834b0495	d03e8320-d368-4d02-b336-8e47dabe92da	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
768f32c7-978f-446c-bd07-3b900bf4e051	ceacd105-cb2b-4901-a20b-48a764c07b88	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
832e5c25-99e9-41f4-8d51-256628cba797	bcecc802-2eb7-4857-9ce8-7ac3c2e7a279	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1e5a8de9-cf8d-42c3-8c46-a9518e80dafc	25cb222b-b088-4a5b-abf6-d32c2b66d3f9	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
81754e24-e05f-4426-919a-bce49fe03feb	c81063d9-5398-40b8-8261-2d916be4f04a	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5b602298-bdcf-45ab-a62a-db74f494af09	e4ca91cf-57a6-4517-bf8c-6015064be2d1	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ecc0e786-4ffe-4297-8db5-0053632cbb72	0c276263-b0bb-4526-8210-e66fb4489174	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bc44ad5a-996d-4d25-be9a-9ea00529c713	dd4755a6-58e2-4163-9e28-531e2d529673	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aa6b9498-96fc-41ff-a7e2-6e1b4810f098	98f19d61-eb3e-44cd-b203-0c36d78e3949	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
35b1ad03-20a3-4ea9-8ff0-4cacc17c7d6a	b54ba154-8792-49e7-903d-ab4620147a9e	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0b11b118-ef8f-491c-ad4f-757c547035fc	a5158d3a-576c-4ac5-930a-3d3fe9ec94d3	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d5e5794a-6af4-41ec-be18-c41e9577201e	7730492d-a7ff-4cb1-8300-5ddd5232ed44	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4a27e0ec-2709-4359-b376-1ec48aadb8df	5434cb96-68d9-4c6a-a51d-a5073c7324d0	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e4f42cda-3417-4736-836b-4c494412532d	b56975b6-7460-4183-8ed2-208c27b57e0f	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d6d8e112-1412-429f-ad16-768ade958534	e3ce072c-32f4-4e7c-acec-a873a51481f3	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
47b1d9a1-369f-4eb0-8b75-ea529ece0641	e0897866-a534-421b-9fcd-a7ae0a1694fb	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
51746d76-a689-43ad-84cc-7f96828aa619	84a838b5-a832-4df6-8886-a13db65209f5	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
816d5abf-9176-4fa8-b41f-8be659ed8c79	2b45ed00-e159-4e44-ace6-224fbafc1aed	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0c144622-16af-4166-b5f2-5cc011aa09d6	69e41d8d-d9af-49b1-a83e-09ec15511fc8	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
604dc503-0b56-4e44-a00a-dc612e671852	f15558d0-171b-42f6-93b0-4f2c7853984b	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e792062c-6048-4d53-bbed-ffa6f9d2232e	1cc5f42d-9241-4a29-9aa7-42f756326d2e	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e9b8d3ce-e819-426a-ae28-b94cc3280ced	37db6546-12af-4f16-9eb4-882b2c212075	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a86f987f-a43c-42ee-a81a-f69e930971e3	efb906c4-7a40-4a74-8764-bd68890e4049	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4f3c8248-814c-419f-9985-1d4458db5a5e	aeb3a63b-3fa6-4215-aa0f-6c8ac014c14c	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7f8c09e9-4ac3-467f-b50e-0aefedf08173	55dbbc8f-f4d7-4b6e-b1e7-e26cd496f084	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
458123c8-71e1-47ce-a534-a856bb232df2	26ad8cb3-a76d-4d91-8c88-e4ea105565c0	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6490ec36-d368-490a-b150-f607dda9554e	9a8b8dca-6cca-4d4b-9553-2e9f66adf6ce	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8e833ffb-47df-4213-8ad6-37d7bf724ca8	8a558b6b-f381-48ef-98a9-df90ea327932	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
be0f3944-d602-4e47-841c-391a34597139	1be7f127-29b7-45cd-88d6-df2ed68b376f	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ac63594f-0f77-4514-9103-409174f4ac56	954e0853-3552-495b-a722-1ed6d1d2b2cf	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d8c57c73-b1e6-4c3c-92b1-da1bcb3d89b1	a35d5ae9-8eb7-4c67-bd41-ebb21a798f60	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5be86847-24e3-4387-b10f-5a1bea9b30a9	629ecc62-b715-43eb-8d88-94182cbf4861	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9e354400-9ea3-48db-9067-36618435f754	286c9170-9cf1-42b3-be5e-0839b941ab91	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8a98aadb-c708-45dc-af94-7fa92002d740	4b573fbf-955a-4b30-9f74-55d730fbb597	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
18a5bd85-277d-4412-9646-e2b31764bcfb	49bc3522-75de-4f7a-b3f2-679285b578e2	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cb107c84-3f9a-409b-b293-b3c0c20ac84f	a950f7a4-96ed-43e9-ab61-4c271d75fde3	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a0b7025b-096b-4857-9f3b-a66f7d921beb	614c44bf-b66c-46b0-a034-860997aa05d5	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8be1f489-ed9f-4e50-bd49-ed1751eb0926	a31f4a9d-efd7-42f5-86a9-4989c461d66a	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dcef0921-d081-4d80-9e3f-473160cadbe3	b037fa33-d9c5-45ed-9733-b6a240ff5c7e	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1f21e374-cbb7-4314-944b-2c1064aba1d2	9341fbe7-bbd8-4055-972b-9a73a75e76ed	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f05c6a1e-cf7e-4cb0-b036-8367a08bd73e	4238c8a3-687d-43cb-a4d9-308260f318a8	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cc594f42-61ca-4677-b1dc-3cb4c40fd869	12ac31dc-0080-42e0-8aee-259ded946244	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8f6ce8c5-d188-4a9e-9351-b1a82b2a2c72	757cb740-41d6-4026-a025-51bde08cfc1c	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
79fa7505-574f-4ea8-bff1-6235ebd7f162	2fb7de78-8303-48e9-afb4-11e3b37df61c	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
86940524-51ec-4481-bd18-921eab8b46f0	a43c9e77-2921-4adc-a80b-9dd5844392b0	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
08a97b8f-2976-4981-9ca2-933afd35a2ec	47b4e4d9-d205-44ee-a377-4b75c9a45120	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e98b5ce0-6ea5-46ec-b562-938fc0ac5742	0edbbaac-714d-49fa-9007-d4aeba519de6	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bad47660-8613-4791-941e-1f0c0bd942bd	2ddb66e2-e466-4d57-adec-3e5336eadd13	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5260c9b2-f67c-4383-b211-92a993e6a78d	17e01557-a715-4369-9e06-07933a7fdef9	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5920f9cf-cc36-4de8-9259-e5dff64fdfa3	24fc4473-5e3a-4211-b670-389ae1d49019	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ba6759b1-c016-4c23-aa59-377fda1c8aa4	bfbd56c6-d4c8-488c-adab-297fe726056e	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
68f86195-b9cd-49a5-80a4-b1e7acde6f30	95e71917-290e-45c7-9d40-66700df681d4	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b0aafa26-0c03-4829-a843-71d99b4261dc	43ab6d45-456d-4da6-bbdd-4a424459891b	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
229009c0-7a5f-4064-8cd3-0ebf0ab66d92	1f47fc16-b31b-4605-b7ba-e57ed6a7dcae	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0f419f9b-09dd-4fe6-911a-bdf8a26e7208	dfe38c75-69b1-4bb1-a7b3-cb4faf0fa9de	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
133179c4-ad30-4d00-969e-a817591a90fb	7f980fde-1e99-4a02-8421-8b8de650bcf8	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c814adea-c7a9-4218-a48d-e2933f628407	e1984b60-b05d-43a4-be47-7e54a36286de	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
860c1439-468e-45a9-9434-54142cdf0f0a	435640c2-69c1-4d26-b06c-10e250ff09e7	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
21bad5e3-daca-472d-9448-4b6f3ce74aec	da515f57-0b19-4100-8eb5-9460c39f588c	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2684fbf0-758e-4634-8c7d-076e2f0e1936	42bd9606-715b-4715-a7fd-fe81dabe324a	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b96d0913-e2cb-4baf-9bbd-28c1f911f339	20653ba2-705d-430e-96c4-f03f33c91a6f	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c073077e-7fc6-41e2-8d0c-706af5644a70	ba18ecd0-a61d-4f67-9c07-0bc0031e737e	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
98aa0d66-1786-444e-b411-4b88679088d4	37792710-05ac-42de-9b1b-908b916f4b35	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dc49ff2a-4346-4556-b0d3-2e359865936e	fac6f0b3-67aa-487f-ae19-14eb21f90530	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
29dbb9a8-153d-4d43-ad42-c0602d6f3565	d03e8320-d368-4d02-b336-8e47dabe92da	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a58464a3-af4a-47f4-90c4-ffd266b3daf6	ceacd105-cb2b-4901-a20b-48a764c07b88	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
90a12cf5-1b66-4924-b0e2-352d3c61c3c2	402685e4-0018-4f56-a50d-23a7898f997c	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f5aaa6a8-6277-41ff-97b0-affe0014b884	bcecc802-2eb7-4857-9ce8-7ac3c2e7a279	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
600ef54c-b5e8-4498-bc29-a5bca36b2285	25cb222b-b088-4a5b-abf6-d32c2b66d3f9	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a451c76e-7de2-48fd-b45c-7858ab6a56c4	e4ca91cf-57a6-4517-bf8c-6015064be2d1	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d414ecd4-3055-4e75-b61a-f5491cada6b9	dd4755a6-58e2-4163-9e28-531e2d529673	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0be790ff-0893-4519-991a-8ba10741cf51	98f19d61-eb3e-44cd-b203-0c36d78e3949	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a369665a-fea9-4a8e-879c-246b18ebb2f8	b54ba154-8792-49e7-903d-ab4620147a9e	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fa59c9e2-4830-4310-b6b8-e547a0dbfd58	3de0d3c4-e32e-413e-a102-e8a29355a013	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
163e6357-58e8-4eb0-96d0-7925edb01803	5434cb96-68d9-4c6a-a51d-a5073c7324d0	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c7ba789d-60e7-4dcd-8126-d50c6e05c898	b56975b6-7460-4183-8ed2-208c27b57e0f	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5b351700-242c-419b-93f6-d9476ca81041	e3ce072c-32f4-4e7c-acec-a873a51481f3	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dbdac2ab-85ec-4a5f-9900-3506b60820a2	2b45ed00-e159-4e44-ace6-224fbafc1aed	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b4c0b2d1-5c97-41e8-9e33-1639a56c69ff	69e41d8d-d9af-49b1-a83e-09ec15511fc8	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fef9cb88-0c9b-47b5-94f6-64d9fb29b918	f15558d0-171b-42f6-93b0-4f2c7853984b	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2e17d1a2-1de5-48dd-a86b-0f47ed7d7337	3a2fef4e-66ee-46d3-af3d-6ddc6bc7e395	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
629fc2fe-05d9-441f-90f8-b8ccaa4a64ef	1cc5f42d-9241-4a29-9aa7-42f756326d2e	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8c6f1b10-7098-456c-b4fb-1929a5020a2a	aeb3a63b-3fa6-4215-aa0f-6c8ac014c14c	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
252cc83f-6d11-4b72-96d9-5382899fcf31	26ad8cb3-a76d-4d91-8c88-e4ea105565c0	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5ca43fc5-0eb2-4e3b-a377-259832c2f1e9	9a8b8dca-6cca-4d4b-9553-2e9f66adf6ce	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
010d932e-af20-4acb-9a21-19a1d8134d28	862078f9-7dbb-4ef4-b0c3-01ce8f161bf1	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
94bebf39-4573-4892-93be-a6259ec8cb5b	1be7f127-29b7-45cd-88d6-df2ed68b376f	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
78e7b9be-3733-4916-bedc-3a116dbc44f3	a35d5ae9-8eb7-4c67-bd41-ebb21a798f60	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3090ba26-f117-4b88-91a2-a2dd05d70aea	9d9a2d0e-838d-43c0-85b0-de303a1437ad	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f831c7f2-490e-46c6-9506-c262538d1710	8230d118-9b23-4146-874c-2da5c9a93330	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f0c6b7c9-65cb-428a-842a-9d0a8be29a2e	ff2c819f-f975-4790-a8b1-59a736f20819	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3e470278-ec9d-42da-a9b4-5d5d3822a9d9	7c3d7994-aac4-43d2-bd39-8056ef6caed4	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bc300bc5-1475-487e-b77d-2b1896bdeb8c	49bc3522-75de-4f7a-b3f2-679285b578e2	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3dc0a2b2-fc7e-45ed-8acb-57d14c6d6ddb	2f418d8c-ea01-4e48-be76-26188728aad9	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
44f1f0a4-625d-4f05-82d1-cea6cd9bb6ab	614c44bf-b66c-46b0-a034-860997aa05d5	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2526ad19-e494-4e59-96d7-94fa5c399332	a31f4a9d-efd7-42f5-86a9-4989c461d66a	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e933f746-cc10-4776-9671-568b1132c761	d5702a38-ff3b-448a-a78c-e1e680c85ebc	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0fb89c50-dca5-44e0-a45d-6bc41470dd39	b037fa33-d9c5-45ed-9733-b6a240ff5c7e	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
77ba652e-2ad7-4610-b533-c4066da4f25f	9341fbe7-bbd8-4055-972b-9a73a75e76ed	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0138894a-c399-43bf-9a1f-2ca67242f5d7	d4bc7faf-c49b-48b2-8c6e-af149fba72c9	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
570958a4-9f5e-4536-b099-7374c1909f74	f49b5955-9697-4596-b71c-c9657fd123d2	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9dc8fbd6-a9ec-4bfd-91ab-89f5766bc090	12ac31dc-0080-42e0-8aee-259ded946244	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2555aac9-778f-4e78-87b0-4b6d919a20b7	a43c9e77-2921-4adc-a80b-9dd5844392b0	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c8350ad5-f840-4eeb-829a-eab9a59beb2f	47b4e4d9-d205-44ee-a377-4b75c9a45120	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
12ce53c2-2d24-40a4-b98b-a4c36578e69f	64cd20e2-541a-40b1-8a07-9ebf2e8dafd5	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7771a34b-4546-4b8f-984d-b843f208beb1	2ddb66e2-e466-4d57-adec-3e5336eadd13	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a7c5f7ba-572c-479e-9a87-fe139cd2b9ff	17e01557-a715-4369-9e06-07933a7fdef9	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f13b71dc-7d35-4be4-b210-831765665888	e72bdb1f-8b42-412f-b85b-9ccc899e670d	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
29916f57-e05c-4e2d-9e10-0f56a58e8b7e	24fc4473-5e3a-4211-b670-389ae1d49019	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b5119dcc-7d22-4bb4-8f58-fe894a80464b	bfbd56c6-d4c8-488c-adab-297fe726056e	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7a12a284-844d-4758-8d1c-84fa9ddf78ee	1ea6035b-0895-401c-8def-421b17bb1d0b	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
be7ad0d1-b10d-4cee-acdb-1d3a8c110243	c8b4cecc-c02f-4a53-aecf-58282f3ff909	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f56c12e8-985f-4396-87be-62dfa901bbe2	95e71917-290e-45c7-9d40-66700df681d4	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a30f6d31-5438-49d7-a72f-fae342c79f4b	704bb2c1-18b8-4def-aecb-f7cbb1705e14	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ff145dbc-3810-4009-8a2b-a3131a6186d4	43ab6d45-456d-4da6-bbdd-4a424459891b	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e5a20511-9bea-48f0-9a1d-6a9248d66c59	695a98bf-90c5-42f9-853e-7b7114255faf	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4fb25fa0-9571-47ff-b363-708742105737	1f47fc16-b31b-4605-b7ba-e57ed6a7dcae	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
768763b4-b081-4928-873f-b632609ee4e8	71e42543-3ae9-456e-8a6d-c4faa74f682b	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
137c2423-6db7-4309-80f3-698fd286708d	7f980fde-1e99-4a02-8421-8b8de650bcf8	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cf4400f1-6933-4102-9c85-55d3de83675a	e1984b60-b05d-43a4-be47-7e54a36286de	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1c41ac47-80ee-483f-a0ea-1489b18ea2af	534e84f1-cf3c-464f-a0d8-e44df0773945	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
52af503c-5961-4d1b-9895-859699314a1b	435640c2-69c1-4d26-b06c-10e250ff09e7	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
23bc7262-3571-44ae-b269-40c9086e4a45	42bd9606-715b-4715-a7fd-fe81dabe324a	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a833335b-d107-4a75-b939-4fc8391cd523	3eb4277a-7853-4f37-aaae-f6b42b88cb76	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c3f34fc0-fc47-4715-b838-685c732342e0	20653ba2-705d-430e-96c4-f03f33c91a6f	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c84b683a-cd8e-4116-bc9a-eebc3ae79042	ba18ecd0-a61d-4f67-9c07-0bc0031e737e	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
923f9ee8-143a-492a-8eb9-77b9faf32cbf	fac6f0b3-67aa-487f-ae19-14eb21f90530	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3f652721-c833-4590-a938-81be5968e6dd	1d4a7fac-998e-498e-ab29-9f8712f008ed	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ebd95b38-5ecb-4f8e-b588-8291eca1ccf4	82f260e1-3880-40bc-8271-bc652f32af64	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8f86d571-3d9f-482e-b16c-c40855a8abe5	d03e8320-d368-4d02-b336-8e47dabe92da	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4eb3ac82-9e65-416f-b517-82257efc3a90	ceacd105-cb2b-4901-a20b-48a764c07b88	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f43ee05b-e56d-489b-936c-0dcd5b7117aa	e4ca91cf-57a6-4517-bf8c-6015064be2d1	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8816d249-69e6-4c90-83b5-2fe11509bb82	72fd6adb-ccbc-4339-b283-c3500b83a722	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6b2e9b78-24c8-401e-8859-bc209f3897bc	dd4755a6-58e2-4163-9e28-531e2d529673	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cf8a521a-63c5-4cdf-82e3-edea96ebb9bf	6df4c389-b930-4641-ac16-7ee3f4a53e73	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b42e1bcf-ceda-4245-885e-807c405739c1	b54ba154-8792-49e7-903d-ab4620147a9e	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bb69554d-3461-433c-ac8a-d2d27e0b8848	a5158d3a-576c-4ac5-930a-3d3fe9ec94d3	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aac0a644-6f60-41a1-b4d9-35122a4f3d57	7730492d-a7ff-4cb1-8300-5ddd5232ed44	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
684932d6-647f-4ee8-84fc-5ef6b36308a1	5434cb96-68d9-4c6a-a51d-a5073c7324d0	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
32622a07-9045-48b4-b198-492380b473bc	b56975b6-7460-4183-8ed2-208c27b57e0f	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b3fc3a02-a4e5-4cc9-9962-da9ba52ea037	e3ce072c-32f4-4e7c-acec-a873a51481f3	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
589c34ea-e914-4d07-9e7b-26acf2d49db5	e0897866-a534-421b-9fcd-a7ae0a1694fb	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
130b7859-e47a-47ac-a100-672792c2daec	84a838b5-a832-4df6-8886-a13db65209f5	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a534ffdc-3ba6-4885-9fe7-880afef33865	2b45ed00-e159-4e44-ace6-224fbafc1aed	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2857ff68-7a2b-4f98-bafe-9e076a703e3f	fe7243d7-d665-484e-ac80-7b946f15ecf3	3	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6c343de4-a3d4-4483-98ca-50372eb41a49	37db6546-12af-4f16-9eb4-882b2c212075	3	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ebd9dd0d-b6d0-41b2-b467-c3cc2062d8d9	91c4c38e-af51-4885-9e46-1852ad8a0164	3	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3c6235aa-8aff-4cac-91e3-5c3114bd9938	8501a990-da3d-483a-858e-6c1bbee29718	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e97a8168-fc39-485c-842c-41bc042222e4	851c0ddb-bf03-4977-9bce-799af3bf3a0c	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9b30bd34-dc24-4b33-9991-ef265c64d3fe	aeb3a63b-3fa6-4215-aa0f-6c8ac014c14c	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fd6f8df9-ac0e-46b1-8b25-142faf0944aa	26ad8cb3-a76d-4d91-8c88-e4ea105565c0	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5cda04b2-4050-4df8-999b-9b5e5fb45716	9a8b8dca-6cca-4d4b-9553-2e9f66adf6ce	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
186d9cc5-606a-48ca-b9ed-c3be960b49c3	8a558b6b-f381-48ef-98a9-df90ea327932	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f345d9b5-714f-4ace-95f9-575cf976e9e8	1be7f127-29b7-45cd-88d6-df2ed68b376f	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f09174d7-0f4b-4344-a0c9-840fd12955b4	a35d5ae9-8eb7-4c67-bd41-ebb21a798f60	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f40ac529-dc78-4221-b905-c86177d5d818	9d9a2d0e-838d-43c0-85b0-de303a1437ad	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b840bcf5-4149-4d38-906d-7a72027d4ab6	ff2c819f-f975-4790-a8b1-59a736f20819	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
29ff6c2b-e508-4f03-87fb-d34aa14019b2	286c9170-9cf1-42b3-be5e-0839b941ab91	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
175baac9-e9fa-4362-9a85-352486877bdf	4b573fbf-955a-4b30-9f74-55d730fbb597	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
214a2a62-b93f-4f83-a279-95ba0052185f	49bc3522-75de-4f7a-b3f2-679285b578e2	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3a24f4f2-a05a-48b9-aad5-3a68a55ef2ac	a950f7a4-96ed-43e9-ab61-4c271d75fde3	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b87d3545-f420-4ad4-81c4-00f66d08d058	a31f4a9d-efd7-42f5-86a9-4989c461d66a	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d8835aca-6988-4790-ae41-9e7fb5e65627	d5702a38-ff3b-448a-a78c-e1e680c85ebc	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2363741f-ee5f-4936-ab6c-bf554aa02c08	9341fbe7-bbd8-4055-972b-9a73a75e76ed	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4f6e9bbb-8522-4af5-9c7e-cdfd7f71b76d	4238c8a3-687d-43cb-a4d9-308260f318a8	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
147df8d2-c3bc-4da1-a35c-9976c0599f52	12ac31dc-0080-42e0-8aee-259ded946244	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
37f74760-1990-4913-97d6-4e03efa5e641	757cb740-41d6-4026-a025-51bde08cfc1c	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e8197b86-7397-4b9e-9568-282214bf3553	2fb7de78-8303-48e9-afb4-11e3b37df61c	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2cc3a33f-8ba5-431e-b7f6-fb415070e2b5	47b4e4d9-d205-44ee-a377-4b75c9a45120	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
22f426ec-e208-4de9-b0e1-b0db258d0ab6	64cd20e2-541a-40b1-8a07-9ebf2e8dafd5	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0f231b6f-9233-4ec3-b6d8-7b37077a41ae	2ddb66e2-e466-4d57-adec-3e5336eadd13	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e2248393-b973-4691-9f4c-9cd40a970499	e72bdb1f-8b42-412f-b85b-9ccc899e670d	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b15104b1-2124-4308-a203-d27da3d4ccd3	24fc4473-5e3a-4211-b670-389ae1d49019	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e87b96e4-c091-4c4e-91de-ddf9aab0498c	95e71917-290e-45c7-9d40-66700df681d4	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3f5204ad-3dc3-46f2-8bc1-fd967450eb94	704bb2c1-18b8-4def-aecb-f7cbb1705e14	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
45c53544-bdaa-48cc-be5f-7458b5ac27a1	695a98bf-90c5-42f9-853e-7b7114255faf	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a5d2d326-062f-404f-a615-1cda9ecdc0fa	1f47fc16-b31b-4605-b7ba-e57ed6a7dcae	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
07c27844-9d62-4da2-8a45-1405085d8f9f	dfe38c75-69b1-4bb1-a7b3-cb4faf0fa9de	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6e133550-9551-4f79-9094-69933dc5b847	71e42543-3ae9-456e-8a6d-c4faa74f682b	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d477d31d-7e80-4d5a-bae3-900033046d21	534e84f1-cf3c-464f-a0d8-e44df0773945	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
98599ee5-b05e-4c96-8cf2-62db2350c326	42bd9606-715b-4715-a7fd-fe81dabe324a	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e32297cd-0e46-4d42-9f9f-9ecd32a77491	3eb4277a-7853-4f37-aaae-f6b42b88cb76	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
605e03c1-044a-4ffd-948e-9dd7e09e1c05	ba18ecd0-a61d-4f67-9c07-0bc0031e737e	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
308fbd89-6789-4d57-af35-0099d4cca14d	1d4a7fac-998e-498e-ab29-9f8712f008ed	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
666d0746-4f26-4f63-86ab-0af530458ac6	b101efdf-7cbb-4108-b991-46d63f5a8835	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ddd54725-1d22-4b3c-b89f-f93b88b32258	82f260e1-3880-40bc-8271-bc652f32af64	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fa20ff6e-68b7-41a2-89d0-559c22267a8c	25cb222b-b088-4a5b-abf6-d32c2b66d3f9	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1de3d86c-1975-458c-aaf6-7be78c7112eb	0c276263-b0bb-4526-8210-e66fb4489174	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
44519949-b7e9-4cd2-a948-4cc8d98560d4	72fd6adb-ccbc-4339-b283-c3500b83a722	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ae37d230-90de-443d-b1a7-d9ed5ee2fc54	dd4755a6-58e2-4163-9e28-531e2d529673	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6f10d1d8-6cff-4a09-b5a9-755a54ce47f5	6df4c389-b930-4641-ac16-7ee3f4a53e73	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cd230507-58b3-45ba-ad91-053aa863c704	98f19d61-eb3e-44cd-b203-0c36d78e3949	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9a02682c-4ff5-449f-a99d-6dc932fc7cde	b54ba154-8792-49e7-903d-ab4620147a9e	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b9ea67ae-e90a-479e-9b55-627bfc45adec	5434cb96-68d9-4c6a-a51d-a5073c7324d0	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
87ad6109-dec9-4140-9fb0-d34fc8cdde75	b56975b6-7460-4183-8ed2-208c27b57e0f	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1323f32f-9fb3-41b9-bc72-719d54e5a394	f15558d0-171b-42f6-93b0-4f2c7853984b	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6e90467c-e321-42d0-a171-78e82ef8c503	fe7243d7-d665-484e-ac80-7b946f15ecf3	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bea0f73c-41a2-4073-a427-bdabd92c1518	3a2fef4e-66ee-46d3-af3d-6ddc6bc7e395	4	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c75c4a5e-32ec-45ac-a1c2-f1106a7c8c51	9226008b-5420-42e3-92c1-2e02a8d4ad04	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3bee974c-e623-4b69-b09c-51dfe8dc6417	1cc5f42d-9241-4a29-9aa7-42f756326d2e	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9a39a647-8cf9-46ff-b6fb-b8ea4be3b949	37db6546-12af-4f16-9eb4-882b2c212075	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
697b7ba0-f856-43e1-a847-b5c46991ac8a	91c4c38e-af51-4885-9e46-1852ad8a0164	4	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ab2642af-6772-4c53-89d9-0f3d94ddd10b	90b5620f-f187-418f-9136-f4261b43155a	4	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c0bcdac6-66a1-4561-81a9-ccad8138c9a6	078e8927-390b-429a-a0eb-b48db0fae96b	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3122d1ac-4bc9-4e53-bc2d-599dab612667	f297a90a-24e0-4995-aece-42202861fc0c	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a8864647-3724-4530-b1ff-fa34a0389127	45609fc0-a7a3-418f-ba42-f2bfb44bdc99	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f6fbf64e-85de-4efc-8ac7-5f1d4fa8e628	f048cf95-fbd6-4794-85b5-b8022c9c5960	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
00491378-2962-4138-aeb3-f4b96f7ad54d	4937d681-8070-41dd-9d5b-212842a213a2	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fdae8249-8c09-4327-aa2d-7aa2e8946315	4c4d18eb-6fb0-4e29-9b1e-4aeb46eeed13	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
779e6230-1117-4057-89a5-a876388d8272	81e929d9-85d1-4697-a43a-8559cf6d2cf0	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a0901049-1820-458d-9679-11478071e448	4e76e0b0-49fa-4776-ae3e-6e63e185324f	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
446c7b0e-b02c-406b-99d0-d6881f6b7a64	cbc5f781-d729-4dae-85b6-fd8727d4934e	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b9fe9b06-a773-4b8d-b1df-aec2c314583b	0eb29785-5af2-413d-be77-89bfd21ce82f	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dbcb0bde-111e-4b96-9810-69c06e4a6dce	669824b9-5760-4eca-b62a-b72a140f64da	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
19149be0-2ef7-4965-b36b-dd7abd6639ec	5f7298cc-fbae-40ee-b039-b0d9f1699af4	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0dfcaae9-43c4-4e33-bf66-b2728539f0db	4eeefb7e-ef01-4571-bd28-f480f1a7ad99	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c858a030-9b48-41c7-981e-795a9d2636f8	3389f1f3-d769-4703-b05d-ca0c9b86d9ce	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5ab78671-19c3-41ad-a6ab-14b1308eb301	81d05e03-4afd-444c-b3f5-f411d6c9fccd	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b2a4ef78-4ad2-4c5e-961b-edfe12855874	1c84da64-7c04-4d3b-b27b-30da3f29ae75	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aebe8f56-a454-42f5-acf1-6b8eb70d7854	34d0d6bb-4fde-4710-a4ef-a1c74f3d2685	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
079e8c38-7443-47a5-80ef-cc6429a4c8ea	b9bf20a0-6439-416b-a43c-79bdd6fe68b3	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
513173ad-5629-4ee8-ac62-ea123be7944a	f8ce6342-9f6a-4695-afce-86afc97673d0	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3cb138fb-683c-4163-9e9c-be32adf42716	6eaf5aac-5606-46ec-8e32-1d2ea53b6759	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
28f5b11d-44a6-4b74-81f0-45e673acaa89	351a9129-5004-4dfb-898b-c3e3455b7c47	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ce5cc9b7-cd03-46ad-88fb-18ceee8b09fa	e86b7a8e-b49c-4a53-b635-de1d68ec4b82	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
df3aed35-e63a-47af-8c77-61b60ce714df	da306436-c013-47b1-9d05-c1d1c1be8201	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3b2e3db0-e462-44a1-94f9-978804d88793	5e3cb4f0-0a20-4115-80ef-b3653c01b126	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ddcac11f-44ac-4e74-b697-ea0a58ad7feb	f788b8e2-1221-41e3-9da6-c9b362dd4fce	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3ad777b2-3c4a-4957-a93e-308a33fa4b9d	34227563-fa89-4903-9958-07dca021d715	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2e9ecb6a-78d8-4c0f-a589-4e99d2581e0f	fab42d10-d976-4371-82dd-15896a25bca5	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7efa14c8-5186-4850-8552-dc6c876f851e	6d59e935-e6fe-4af1-afca-bdeed0e5d28b	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a0e81f35-a70d-4874-9390-2d1f617cb1bd	fab8c1a1-b053-4d56-b5dd-e73feca13814	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bc1fddd7-11a3-4796-b585-c931a1278eb8	7d82f19d-2e11-4e97-b741-eb2041952cfc	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bc4f1215-2e47-4ff6-bd90-dfdedcc252c0	fc4e8089-0928-40d8-be1d-6402fde79a3b	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
16b78b04-d4cd-490d-93a8-e282eb6511d1	097e9c38-8ac8-4428-a3ec-468d9603d428	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
06800d0d-bd38-4ba1-b0a7-c729c2654926	cb4d4859-e6b6-499c-addf-c0aa5cb6b7ba	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5488b7b7-d1a4-4f43-b079-6fe813e1e12a	65ccbe12-0607-41be-9ee0-7238f388775a	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e835d6ae-226d-46f5-b329-89a0e12c7758	4bf0c272-a729-4abb-98c4-77cf254fd99d	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
42e1d78f-4747-4077-951a-a97feaf9dc02	804b4aa5-b5ca-49b5-bca3-c472e9fd9851	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6f871979-66be-4517-bea8-5178c80b737d	5f2bb384-edf9-4b9d-89d9-e9652051a912	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c0ec2e46-dbea-4da7-bf13-7484ca460211	677b359d-02ba-4718-a0e6-639db36b96ca	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
704a76ba-0abd-4510-be20-7a82ea9951bd	5294ebd1-b67f-4ce3-9618-410cdce6b88d	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ae66e556-286f-4b08-99de-269a6277819a	ebe295e2-0b42-4ebf-be7d-99d3ab6f976d	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9ba39cd9-dde4-4e95-b571-ae09396ca923	3c523dee-e2a0-4abd-a0f7-3b18fa806fc1	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
60daaf74-e567-4220-886f-85ce0ce39bf5	1e528066-722a-42d1-8893-fdc5547dac9b	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
56238b96-fe7f-432a-b28b-0cd66ce25b00	910f4403-e42a-4f61-8db9-daae2bb56bef	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
85759592-b642-4f0d-b629-76d3cc0ebee6	87932290-c9b5-4c07-9b9e-192a3b814377	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b5c5b706-28a6-42ea-870d-478a1e646998	f963f38b-94e7-4a81-a844-06451eef6843	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2d27b475-de06-48ad-ab7c-be4bb37670ec	068cc6b0-d2e6-4b40-83a5-e9d34a849d25	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
98925f80-3b62-444c-8616-4f8eb2e9439b	5667e395-5ddd-42c8-a078-47dd551a8b6e	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
64ca29e4-89f9-4b84-8243-032353043a4f	dcaee63c-3224-4f87-87bc-5c0a381313af	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4add28b9-09af-4eba-a3a7-92343e302343	de9e559d-dc96-4dd6-8abf-8cfbcd60cfa8	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b3c75430-3b26-4980-a178-3119818a375e	90b1c425-7792-459d-8f00-a10ad0d5ab09	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6346ef58-9d49-477c-ac37-b7d14c99c609	9fd99fb3-c269-43ec-bb28-b88554c78ade	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6f886d97-508b-4926-8a5a-3654f8380853	3dd16fda-2c71-493b-96cc-c371d891ff10	0	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8ca55d41-05eb-4f63-92d2-d12e0b2e603d	c9fc86fa-8763-4675-961b-86a5856f9a7c	0	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aecf084e-20b6-4ca3-a8e6-576e346a0d81	7d62dcf9-a0fb-4124-abf6-c0cdfdce2888	0	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1c1ed01f-68be-47b8-97ba-6fad8c945443	f297a90a-24e0-4995-aece-42202861fc0c	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a4395e22-09d4-41d2-a7b2-b34daf7daa2a	949a40b3-fd74-4ca8-b48c-343a550309a7	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
49b5532c-0c17-45b6-a350-c8835909222d	4c4d18eb-6fb0-4e29-9b1e-4aeb46eeed13	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6e1d5d93-e957-4a75-9697-f531bed26bac	81e929d9-85d1-4697-a43a-8559cf6d2cf0	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6f5dc225-20c4-494b-a493-b001b88aa95e	a80ca2d4-2b8a-47b0-a154-829311dca9e7	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6c4c726c-6a96-4e2b-9e0d-df6c635a92e4	4a1a35fb-e0f0-4f57-9e1a-d7d055d95966	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
024b5a0b-2df1-4fd5-8b62-a2b0b36342a9	4e76e0b0-49fa-4776-ae3e-6e63e185324f	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7838f5d3-1949-4fc0-b6fe-0d99f29344aa	cbc5f781-d729-4dae-85b6-fd8727d4934e	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2954394d-d3a2-474d-a7ed-509c22f95d68	a9df35f2-9408-450f-8e72-39061923c0e6	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a9191d34-ebfa-46fe-b0cd-7f9c7359d31d	aaf85f6a-ae52-4b93-9b97-8fef57173a73	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ae1d8dd2-2294-484d-bb6b-57aa8be673fc	36ac3ca6-73ca-469c-bc87-0cc58cf5d5fa	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a64558f2-93a9-41d6-b9a9-5c373e4366fa	669824b9-5760-4eca-b62a-b72a140f64da	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2a238368-c0b4-42ba-8bad-c9d655bb0aec	5f7298cc-fbae-40ee-b039-b0d9f1699af4	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8b1a5124-a4f4-4168-9ba6-91a0eada368c	da08147f-e561-4fd2-9b16-0dc598af342b	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
26a8b7ba-ed5b-44bc-b097-0cf013fa9448	c980fd16-533e-4637-bdf3-93cf671ad659	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fcf65597-bde6-474d-bc6e-91f0b0b16482	3389f1f3-d769-4703-b05d-ca0c9b86d9ce	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c7563c60-69ec-4f04-aba0-a09c407c2864	81d05e03-4afd-444c-b3f5-f411d6c9fccd	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aea8c405-d1eb-4fdc-84da-8f266ff4666d	1c84da64-7c04-4d3b-b27b-30da3f29ae75	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
546f0ec4-48d8-4d03-a8de-068c881c688e	b9bf20a0-6439-416b-a43c-79bdd6fe68b3	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1b259cb8-98d1-4dd7-8a37-1b86aac31878	5fb8ffaf-53db-4ba2-819f-48f2a67ae06b	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7b46839c-0f22-4601-b9c6-2b037893adbe	d7d39293-1c8a-4fe4-905e-1423fc8837af	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
78f9b416-cf5f-4417-9eea-727bb299a4ba	024723c6-4c67-43be-8537-7b1181babf9b	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
83d0425b-f437-40a1-8c0d-db42ab822197	1319153f-f3d2-484e-bd8f-93f62a1a4758	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c8cd051f-aad4-4409-bf61-1852dc3a1942	f8ce6342-9f6a-4695-afce-86afc97673d0	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8fb9bd8f-f0d5-4a30-84bc-18dc01ac5fe2	6eaf5aac-5606-46ec-8e32-1d2ea53b6759	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
efdc9e7c-95d9-4f9a-8235-f980d27e5cb1	a2787b36-f776-4b41-90cc-ae1d8d2343b2	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
52b552a3-a8d0-4b52-949d-0d8f0f4fbefa	2e59e070-3abf-430a-83ad-c34e3eeed536	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
27ba6e8c-3dbb-4545-a55a-59823a4dabc0	87b56228-d156-4e7d-8b8a-779af36cbc23	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c659cb74-b212-44e9-8036-eed5c3f19735	da306436-c013-47b1-9d05-c1d1c1be8201	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
29876a2f-17e2-4b65-bfd2-9904cadcca40	5e3cb4f0-0a20-4115-80ef-b3653c01b126	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
78a47ead-f45a-4804-8629-9846f0776b19	f788b8e2-1221-41e3-9da6-c9b362dd4fce	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e7125f3e-4757-435a-a20f-74772dc6718b	34227563-fa89-4903-9958-07dca021d715	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
672e3cb8-85bb-486b-b658-927ed13475fc	e593fcff-a353-4123-bba0-1e93211114cd	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4a8a88b9-6d40-4f20-8c44-fa11c981e812	6d59e935-e6fe-4af1-afca-bdeed0e5d28b	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0857d391-dbbb-40d9-b3c6-61632d8851e1	fab8c1a1-b053-4d56-b5dd-e73feca13814	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6d966d9f-6429-420d-9ac8-94edf449b2ed	fc4e8089-0928-40d8-be1d-6402fde79a3b	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
475448a9-f28a-4130-85c9-7d3e8a59c532	097e9c38-8ac8-4428-a3ec-468d9603d428	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f141d2f0-cddd-45f9-bd4e-447d90aa175e	d26e631e-1552-4f6e-a6ed-8c17049837ec	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
be315104-90a3-40b7-8e85-20b6b667decb	4bf0c272-a729-4abb-98c4-77cf254fd99d	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1eaa6260-9b43-48c4-8d51-88e7f12d037f	5f2bb384-edf9-4b9d-89d9-e9652051a912	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3442d055-cd87-4b00-8dff-e4bd7e748e3c	677b359d-02ba-4718-a0e6-639db36b96ca	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3b4d345d-ca89-454f-8ef7-f546921a0d83	524fcde5-c1a9-475b-b5c5-c2990457a769	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
87a81ac0-5a93-472d-be9f-bdfaf31e2e8f	1c63a85e-1b85-44d6-a030-160f009c8658	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3e7649f0-7436-45d5-a49a-39e44141d645	1c9b7d63-e7ee-4cb7-8f64-80eb2861f74e	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
05a9a605-1edd-43fd-b27e-bf4765299b7d	3c523dee-e2a0-4abd-a0f7-3b18fa806fc1	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
504d70e5-537b-45ef-80eb-5de9d45055c1	1e528066-722a-42d1-8893-fdc5547dac9b	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
01db760d-0929-43ea-bed4-a530b3c7d309	aad139aa-d557-470a-b51d-f6f0678b1657	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0a9faf64-17b5-455e-9729-1e0571162811	910f4403-e42a-4f61-8db9-daae2bb56bef	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
60492a16-c8a3-4d5a-b870-914ae013e94e	87932290-c9b5-4c07-9b9e-192a3b814377	1	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f0461c10-039c-419c-8d41-50d29db8e667	dcaee63c-3224-4f87-87bc-5c0a381313af	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4d5be9b6-d5a0-4b4d-9065-4f5bc1378661	563515c9-32fb-44b6-a303-8427417cd9c8	1	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1e9bd411-5c18-4f50-a140-4d76b29bf0fa	3dd16fda-2c71-493b-96cc-c371d891ff10	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a4e38e45-6e49-4db6-89b6-dcc8b3492f6f	82a03f15-3400-490a-853b-c211fea53da8	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bf1b72ec-3a5b-40cb-a1b5-367c673ab895	b0aa29d6-a6c1-44c1-ab0e-69f43a91ac58	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
041d8cce-3f68-4793-8b1b-f081ea92d6e3	af5d3436-6cb3-435b-b196-f1de1a008fdd	1	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f0233be5-f708-4e3c-ba3a-247b6e616c88	f297a90a-24e0-4995-aece-42202861fc0c	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8ec25bbf-1749-4dde-ba37-c167c5a91cf2	45609fc0-a7a3-418f-ba42-f2bfb44bdc99	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d80e8b12-f1aa-4901-97c3-01dc55277ff0	4937d681-8070-41dd-9d5b-212842a213a2	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
97435cef-7120-461b-b524-c0f2abaa2660	949a40b3-fd74-4ca8-b48c-343a550309a7	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cdac5df3-5e67-4543-ba62-6d2ba77cb5cb	4c4d18eb-6fb0-4e29-9b1e-4aeb46eeed13	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
11d436fb-90d3-464d-a212-7cd96a232dcc	a80ca2d4-2b8a-47b0-a154-829311dca9e7	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ad45c80c-7101-4481-9107-6600cb378e84	a682130a-f7c7-4a3e-8247-a180603a4251	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5524d6c6-596e-4263-b38a-b1a10f0b4631	4e76e0b0-49fa-4776-ae3e-6e63e185324f	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ba326521-83bf-46ff-8e73-7a796cb62eb5	cbc5f781-d729-4dae-85b6-fd8727d4934e	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
307c2da2-dd8e-4fec-8f4f-cb59beae42c4	0eb29785-5af2-413d-be77-89bfd21ce82f	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9a5c28a6-393b-4b95-b62d-04faec5f1231	a9df35f2-9408-450f-8e72-39061923c0e6	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
983da0cb-3e15-4beb-a6ab-f7ef589b8a25	aaf85f6a-ae52-4b93-9b97-8fef57173a73	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9c05082a-d711-445c-b234-78e971148747	669824b9-5760-4eca-b62a-b72a140f64da	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
558cfb9e-b462-458d-ae9b-7f49f4611e04	5f7298cc-fbae-40ee-b039-b0d9f1699af4	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ef47dbfc-013e-486e-ae53-4e0e90e98ff9	4eeefb7e-ef01-4571-bd28-f480f1a7ad99	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f6ee4678-a26e-4f64-b632-07e60fee9781	c980fd16-533e-4637-bdf3-93cf671ad659	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
967fc19c-5360-4281-8e27-48e9ae18c49d	3389f1f3-d769-4703-b05d-ca0c9b86d9ce	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
55f854e1-6b28-4753-b49f-dbe444fc0a30	39f1ec0d-b890-4124-a356-ba245873bda9	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ccab6bd4-fc26-44af-bcf5-7e56112bef5a	81d05e03-4afd-444c-b3f5-f411d6c9fccd	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3f34f425-10ba-4989-90c0-6df27f425e2c	1c84da64-7c04-4d3b-b27b-30da3f29ae75	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fa391447-3c1b-4fae-b247-074dd5e30670	34d0d6bb-4fde-4710-a4ef-a1c74f3d2685	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3f2a7bb1-70a5-45dc-bb51-87ae0362372d	658dbaaf-38cd-441e-a093-94ccb455523b	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
57e7337c-1871-417f-bbbe-fa754c86383b	b9bf20a0-6439-416b-a43c-79bdd6fe68b3	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
375afb6a-ba7f-4656-a84c-2dc141090e07	d7d39293-1c8a-4fe4-905e-1423fc8837af	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0f18dc40-414c-429f-93e3-ff9b9912b919	024723c6-4c67-43be-8537-7b1181babf9b	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
96638a8a-cfe6-40b6-a87a-319a9c28eb98	6eaf5aac-5606-46ec-8e32-1d2ea53b6759	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d494b9fa-3061-4130-b297-457bfb1085a3	a2787b36-f776-4b41-90cc-ae1d8d2343b2	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fea01bc2-be3d-4921-81f8-1463aa731ef5	351a9129-5004-4dfb-898b-c3e3455b7c47	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
20061c5b-3dbb-4fb3-839a-3fca4a904e90	2e59e070-3abf-430a-83ad-c34e3eeed536	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2de15e10-2ebd-49c7-a3d7-c092f5f37290	e86b7a8e-b49c-4a53-b635-de1d68ec4b82	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c539844f-7694-4e09-92aa-5a3619f86376	87b56228-d156-4e7d-8b8a-779af36cbc23	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bd5959ad-583b-4c38-821d-4534abcd05ad	da306436-c013-47b1-9d05-c1d1c1be8201	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cddb5674-2126-4729-b536-fbe3bc8fef0d	34227563-fa89-4903-9958-07dca021d715	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
51cef0b2-eaf8-48fc-b91b-52ac3171d51b	e593fcff-a353-4123-bba0-1e93211114cd	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5f25d22f-280b-4d32-aad1-2c3abcf2c953	fab42d10-d976-4371-82dd-15896a25bca5	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b3f18c1c-9839-4f1d-b8dd-b9112caf0231	6d59e935-e6fe-4af1-afca-bdeed0e5d28b	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
53397664-cf42-47ae-b4ad-bace0e632e8c	fab8c1a1-b053-4d56-b5dd-e73feca13814	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9b7bbea9-ec07-42fe-87ec-7aac2c9c6b27	94b64757-9e53-4503-8b27-100afdd95af1	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0c77cb1f-e61a-4865-a643-ae95c1daa0c7	7d82f19d-2e11-4e97-b741-eb2041952cfc	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
db99cf2f-b07b-48a9-bd6d-ca1cf190e60f	fc4e8089-0928-40d8-be1d-6402fde79a3b	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
259626cc-7d8f-4fde-b145-e665234f45f5	097e9c38-8ac8-4428-a3ec-468d9603d428	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b9bb6cb5-94a6-49b6-afdb-9fc0bb01c5fe	91d94cd7-02b8-4a9b-9749-288bc0e275a4	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
17818b5b-8cbe-4a0d-98e9-7ef246c5a406	d26e631e-1552-4f6e-a6ed-8c17049837ec	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
11d204de-cbab-4a95-b8f3-9dcff164340e	cb4d4859-e6b6-499c-addf-c0aa5cb6b7ba	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1d3bb00f-478b-46af-b57d-b2f047228e22	65ccbe12-0607-41be-9ee0-7238f388775a	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cc9363f2-b91e-4ec7-aed1-58c7a50fceff	804b4aa5-b5ca-49b5-bca3-c472e9fd9851	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
deac2b4e-3170-4015-a71a-a4746b032964	a3757d4a-3f5a-4bfd-8e90-c21f09bdf2b7	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5460b586-e6e8-4575-91eb-56657e39d8db	e6114cba-2503-46bd-a8a7-b7291c6635a6	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ccf7f7fc-e1ab-46ee-a630-20c66510b0f5	677b359d-02ba-4718-a0e6-639db36b96ca	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
67f9107a-0012-494d-a85b-96761f02c3f9	524fcde5-c1a9-475b-b5c5-c2990457a769	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
19153e16-a3b0-441b-b27f-4fd3bb50e71b	1c63a85e-1b85-44d6-a030-160f009c8658	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f31d7463-9b7c-439d-a7f6-f027827c56dd	1c9b7d63-e7ee-4cb7-8f64-80eb2861f74e	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ed96a2c5-fd31-4594-b007-1e71a9e554cc	30727ff6-7e2e-440d-a8fd-244553599891	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
94366140-6ae5-4a91-b63c-378de7d86560	5294ebd1-b67f-4ce3-9618-410cdce6b88d	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cdeb7c25-c4a7-463b-a5f9-174f083d42b5	ebe295e2-0b42-4ebf-be7d-99d3ab6f976d	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bebce0f5-1b7a-4265-bae1-02734a342f9d	3c523dee-e2a0-4abd-a0f7-3b18fa806fc1	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
af8bae7d-43e5-4c8d-b0ce-f1b6dbedc6ce	1e528066-722a-42d1-8893-fdc5547dac9b	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1be86cd5-4613-4158-a84a-7d442f899038	aad139aa-d557-470a-b51d-f6f0678b1657	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b7d4ff30-5c61-4f36-a02a-7763d4184a2c	910f4403-e42a-4f61-8db9-daae2bb56bef	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
24b17738-1a99-4888-95c0-49afe036a360	be6615c4-9c8d-487f-86cf-64dca82a3866	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ec760d92-e021-485d-b6fd-b678fb061663	87932290-c9b5-4c07-9b9e-192a3b814377	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f08d1c22-ef66-47ac-9e30-ebb850b81e1c	f963f38b-94e7-4a81-a844-06451eef6843	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2805c354-c53d-4ef5-8ca5-f873a4e681aa	068cc6b0-d2e6-4b40-83a5-e9d34a849d25	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
812fa238-5b5d-4146-83b7-a09a80d7d19e	5667e395-5ddd-42c8-a078-47dd551a8b6e	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
69442cb0-3e86-47b6-b739-6e08283cb26c	5b71dcf6-8501-4c75-b5bb-05f67c6ddf7b	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
41c554ea-0fe5-42b0-8bf7-0462929dadc0	9fd99fb3-c269-43ec-bb28-b88554c78ade	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b6d417ee-67bb-4d13-89b6-3f519131d8ca	3dd16fda-2c71-493b-96cc-c371d891ff10	2	4.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2dce7d21-54b2-4cb6-8f69-a89a3698546f	b0aa29d6-a6c1-44c1-ab0e-69f43a91ac58	2	6.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7ad056bd-ac9b-46a2-bec4-97c25aebc5c8	7d62dcf9-a0fb-4124-abf6-c0cdfdce2888	2	8.0	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
\.


--
-- Data for Name: tbl_timesheets; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_timesheets ("Id", "EmployeeId", "WeekStart", "Status", "TotalHours", "SubmittedAtUtc", "ReviewedByEmployeeId", "ReviewedAtUtc", "ReviewComment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
10c038fe-200f-4509-8e0b-1f6ba694ea57	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-05	submitted	1.0	2026-10-18 09:54:18.949044+00	\N	\N	\N	2026-10-16 09:29:04.753116+00	2026-10-18 09:54:18.991527+00	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N
e55eacc5-eabf-48d1-b49d-6c9898bb01fd	02814af4-08b4-42cc-92e1-ad0bba687378	2026-09-21	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c8d341ae-95db-48ac-bd23-c6956767f486	78c932da-077a-4104-919c-386de88ed062	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1e593440-2205-49af-8445-142df83bb47d	9312226e-c7f8-4187-887e-67e2124098cd	2026-09-07	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
904130d7-a483-48d6-8c46-414f7a43c776	ffcdc44f-996b-4ef6-90e6-db858823a4c4	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b5581485-4a17-4823-9a5f-23a811c3b5f1	3a209908-397f-4c90-abf6-9fe52ab98b34	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4ad2a0b6-60c7-4956-9f6a-7effa2a67f4c	be9f417e-d40a-4c66-91e6-e7fde84b46d5	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c8dc1f8d-4af7-4c52-a944-90fa21db2057	d01c0ef5-731e-42de-b02a-7c996c545f15	2026-09-07	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5353e0b2-41dc-43be-8a68-da89809c1787	51df4d23-9202-43b7-9e29-4a14a838a242	2026-09-21	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f4499db7-a149-4e3c-8893-330136112036	218f30c7-87bd-4410-99fc-4d10da3e8014	2026-09-07	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a6fe5d90-af22-4b6b-bc5d-84412041207c	2285ceea-ffbf-4bf4-bb2e-bd9e0427beeb	2026-09-07	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2ca1bcc4-6e4f-4477-b504-689d88372db2	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	2026-09-14	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
870b1656-05dd-4337-957c-9937a21c8a9b	6a1ac61a-89d6-4951-8246-621d4e1b071f	2026-09-21	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
80802ce7-9985-4a5c-bdc0-867017dfcf86	2285ceea-ffbf-4bf4-bb2e-bd9e0427beeb	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
123265fa-3ea4-4c58-a500-29384ad8990d	e131815f-331f-46d7-81f8-5d2bed793630	2026-09-21	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9e6aef2b-6906-4c4a-aef6-305b8a903129	6b4e0847-6c40-471e-89ec-c5b63bb828f0	2026-09-21	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7671e64b-83f8-4537-89d7-454c3755effd	e09daabd-8da2-4dc9-89b4-03f4b79583de	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e6c7316c-b38e-4b44-ba02-ad8ae39c05f6	bfb55863-c987-497b-9a1b-9a7bc56a9509	2026-09-28	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b7aebe6d-8467-43af-b2dd-cb453df81a39	9d9bfa3a-8603-4de4-8eb7-76c3935e3014	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e928c252-6c07-4b86-8733-d5db872105e2	fb184814-7151-428d-87c3-f83814676aa5	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
61857b62-05ed-41f2-b1a1-0e319d1cdfac	d94878fd-4650-46bc-b84c-753c841e7404	2026-09-21	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0f632ef5-6769-4219-b434-478620881f9b	583e812b-e929-4e7c-9d76-33d3fc25cd7d	2026-09-14	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6c368450-1f60-4745-b1c7-c0473ed5f6b2	0a213b8b-1836-4660-9116-536fc9436639	2026-09-21	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
11c00d99-f9cf-4a3c-8cf3-e5264005f5fc	46e3d71d-ea02-474f-b668-f836d91e059d	2026-09-14	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6bb0d8d4-9748-46e8-91b2-981a65f962ce	696f99d7-2380-443c-b90d-0e065642e1d4	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cc3459de-1db4-42a8-b7e1-3abd9663efcc	6a1ac61a-89d6-4951-8246-621d4e1b071f	2026-09-07	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a9987944-51f3-402e-b947-0a581fbab9b9	159fb3d0-937c-4f81-ad37-aa1b4f023264	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0ba45cf3-b980-48f9-b097-736881cbc663	159fb3d0-937c-4f81-ad37-aa1b4f023264	2026-09-14	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
88f1ddd2-5116-422b-8237-ad06ebac97db	d9fd54d6-b11b-4969-a25d-8b8e3fcca417	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1c189fff-60c4-40da-99bb-328e8dafb34f	5f4b7ab9-bbfe-4196-9e6c-47f73efe7462	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d1918c54-80b6-41b7-b675-b55f2fda998e	9eb64ade-203d-4e4a-aaed-8eaab7d3017d	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bdeed966-f0c7-409e-9afe-617ee21d8a0f	d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	2026-09-14	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cf7b343a-35b7-4d10-8048-685869933454	9ec115c7-5377-4f9d-b46a-2a3c97bea4de	2026-09-07	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
40ac5edb-662b-4155-ac2c-df8a907cd075	3a209908-397f-4c90-abf6-9fe52ab98b34	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9fb7a9d9-db65-4127-81e6-4631a12887ee	2b245a46-a64c-440b-861d-24f712bd626e	2026-09-07	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cdbb7849-232c-45f7-96a7-70f36b9fd219	6a1ac61a-89d6-4951-8246-621d4e1b071f	2026-09-28	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
06469fcc-a17c-46e6-9c60-11e0126ea176	7e3f1c8d-340c-47d7-b63d-fb047a9106aa	2026-09-21	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f0782e82-8faf-40ab-b481-338b0d883023	31e49978-ac22-44bb-a535-11d20d8aeea3	2026-09-21	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
daa2f4e7-fd04-46f8-8ce3-e15ad856a4f3	cef36bf2-c4fb-4040-b3ab-d033190ad3b4	2026-08-31	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4faf9b14-ab00-415b-88f2-ee40f7596f4f	696f99d7-2380-443c-b90d-0e065642e1d4	2026-09-21	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6f2d03c8-c3fd-48bb-a030-7ccaf001d10d	d01c0ef5-731e-42de-b02a-7c996c545f15	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b8974968-e71e-493a-b089-e51c88d8ed74	ca561f47-f73a-4401-8c6f-a1c776d88534	2026-09-28	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d17a1da1-a4af-49d5-a2ee-c4c7147c6108	33e9644b-a618-47ed-b272-c078e19b36ef	2026-09-14	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c2c5116b-a6d1-4cf2-ae8b-e0314a3690c1	70e01a7d-fd0b-4e2a-b086-d059423ca380	2026-08-31	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b96239c4-8a8e-49b3-a50f-d650dd94b163	8e139039-c490-436d-9af4-431d26334b34	2026-09-21	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7b02cf35-a9d1-41b2-ab3d-de97fa8452af	d17be428-1602-4e09-a164-c3c2666fad73	2026-09-07	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
04ef2c42-f5bd-4734-a8eb-e225e37ad502	315ae0c9-ecdf-48ba-a662-f93c21ef31d2	2026-08-31	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
05d6bcec-6ad1-4c18-ab11-a82866c2f18f	218f30c7-87bd-4410-99fc-4d10da3e8014	2026-09-21	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
954f6b6d-86f5-407d-94df-3877d5640f86	776f2cf7-c4cc-4299-b38f-afbcaff7703e	2026-09-21	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
22e1b9a6-1f5c-4305-81e9-7cdcd4f188b8	62e81e6b-7247-4c3f-a8b8-db21e613d02a	2026-09-14	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
79c29990-79fa-4efe-bccd-d359ed18f422	204776c8-efeb-480f-980b-a3f70be97f91	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
98d1b649-a084-47ba-a4e9-83ece1fc2944	51df4d23-9202-43b7-9e29-4a14a838a242	2026-09-14	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fbdd138e-202a-43fc-b72b-386eeaa3edc7	900ed2a0-d8b3-439f-af86-7383cdebcd05	2026-09-14	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2eeded6d-ef7c-4449-92c8-72dd138a5f34	d94878fd-4650-46bc-b84c-753c841e7404	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
731225bd-7bca-4369-af27-9c82ae0cc575	3a209908-397f-4c90-abf6-9fe52ab98b34	2026-09-14	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5880812a-80d6-4377-a0b4-0efb91f5d73d	ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	2026-08-31	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9ad9ea2c-acac-476d-8d2b-dc07e310db02	8e0616db-48af-4b73-807f-6e250dba2072	2026-09-28	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
32ec6e1d-e945-40e2-882d-b2aeadf2ea2b	6b1f9737-c1f7-4201-8cd2-9b5e6274ebc8	2026-08-31	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
afc1d6f1-4a02-4bff-a434-2aaa374df307	777390a6-91b9-4d9e-806c-16e046568501	2026-08-31	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9f89e59f-20a5-40d0-bfc8-295a6a373abd	818ae1ea-5842-4adb-b475-ac12dba9fd2a	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4eba58c8-bc55-44f2-8aa2-5c6efaa44d8c	d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	2026-09-28	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dda0c566-79b3-49dd-a161-ae3cd2e69d49	696f99d7-2380-443c-b90d-0e065642e1d4	2026-09-14	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bff5e07b-44aa-44b7-9d60-49bb01a685e3	e09daabd-8da2-4dc9-89b4-03f4b79583de	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
65777af6-c4f0-4399-bdd3-a346b489812f	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	2026-09-21	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
18c371f4-62b9-4591-aa29-6193a3316a6b	c5e35b7a-af12-4fd6-96af-e62225e715c6	2026-08-31	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
03231140-54b9-41a3-85d1-7a4cf48dc8f4	ca561f47-f73a-4401-8c6f-a1c776d88534	2026-09-14	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
865fe8cd-23de-4221-8fd0-04d5cce8a89e	4d8e2104-d723-45a0-856f-594f80efd0f6	2026-09-07	submitted	30.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bc063845-b916-4d4f-ac7d-1b2106df0e8c	f01f614a-af85-4225-a3b4-3c463fb97bdf	2026-09-21	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a12261cc-0229-438d-bcd3-cbdcaaae576d	5ff0346b-75b8-4c62-afc7-afeb35b17a8e	2026-09-07	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dee89888-cfe1-4559-ba75-19c6c03f78d7	51015348-f872-4e18-b806-e44017e10e4b	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
36582e0f-0d45-410c-a150-e1546b4c75da	d17be428-1602-4e09-a164-c3c2666fad73	2026-09-21	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9bc437ec-2d8e-4371-930c-9bafcd3ecd07	583e812b-e929-4e7c-9d76-33d3fc25cd7d	2026-08-31	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
81fe180f-d7c2-4dd3-b56e-c2ff3220c45b	9eb64ade-203d-4e4a-aaed-8eaab7d3017d	2026-09-28	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2ada4c75-6320-431a-b6b7-9cf6c6a57dc1	42583b6b-008c-45f6-b258-b08495712c7c	2026-09-28	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d8b33348-0501-4b4f-974a-b15535a9bd9f	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-12	draft	1.0	\N	\N	\N	\N	2026-10-20 08:55:19.480826+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
c43880f1-c570-4ccf-ad67-d805cc665a57	02814af4-08b4-42cc-92e1-ad0bba687378	2026-09-28	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
88c72628-1db4-4e67-8a05-f2d17775eb35	315ae0c9-ecdf-48ba-a662-f93c21ef31d2	2026-09-07	submitted	34.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1673c30a-9da3-49e9-b6be-df0975b31743	f90e007c-90d9-440e-8f0a-a85395e49abe	2026-09-14	submitted	36.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
65bd8f35-5709-453d-a36d-844536a5386a	e93a25e9-5347-49e1-b901-88271fdbdcf5	2026-08-31	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d701448b-594f-4ea1-8e55-254c89c202d1	13428d48-c81e-4720-adba-f8490f27e535	2026-09-21	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7cf2325b-21c2-4334-89be-d6858005784d	4d8e2104-d723-45a0-856f-594f80efd0f6	2026-08-31	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f74281a7-8a34-4355-9e18-d22a9ec25126	8f3346d4-6f76-4575-af6d-a69527694680	2026-09-14	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f9a27130-d21f-4e27-a79e-d0c4eb73981d	9312226e-c7f8-4187-887e-67e2124098cd	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
60f8bf71-2d75-49d8-8225-ecbafa1c2d8c	f30d1ce8-8a1a-483d-ace2-419cd8672ecc	2026-09-21	submitted	32.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fd02ea05-8546-4019-b8fe-52345a224534	776f2cf7-c4cc-4299-b38f-afbcaff7703e	2026-08-31	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4299ca2e-1c3e-4495-9441-09188be8f3a6	0a46bda6-6481-4bbe-8689-18fe959fa98a	2026-09-21	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
79bdfefa-9f1e-4dcc-9910-bcf631acac23	13428d48-c81e-4720-adba-f8490f27e535	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
654c4e12-3daa-4ab5-a5f7-cad447e0f2e4	cef36bf2-c4fb-4040-b3ab-d033190ad3b4	2026-09-14	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cbffad8d-49d1-4e1d-a2a5-0dc03c8ab226	cef36bf2-c4fb-4040-b3ab-d033190ad3b4	2026-09-07	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3fc4205d-f099-4d51-99a9-ec0208da0c12	70e01a7d-fd0b-4e2a-b086-d059423ca380	2026-09-14	submitted	38.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
493a4bc4-8cf7-4b07-9fac-a63e7a7601bf	204776c8-efeb-480f-980b-a3f70be97f91	2026-09-14	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9c99286b-37b9-4ff7-9948-9c3d5ab28314	4d8e2104-d723-45a0-856f-594f80efd0f6	2026-09-21	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0d42d03f-4998-4aa9-8269-91f515add4fd	f01f614a-af85-4225-a3b4-3c463fb97bdf	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
55ffdafe-b010-43ba-b494-495eeee8375a	8f3346d4-6f76-4575-af6d-a69527694680	2026-08-31	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5521bbc8-d61d-4075-9a2a-febcbd9c2d6f	238c3cb7-75cf-4478-a48e-fe47465d20b6	2026-09-21	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fb574a33-1483-408e-839c-abab1a9f2970	900ed2a0-d8b3-439f-af86-7383cdebcd05	2026-09-07	submitted	30.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fabe037e-1d17-4c9e-b3f5-fbc775fa71e1	ee7b555a-4400-4c03-8fe5-60fd908c0e58	2026-08-31	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cfa0efb1-c2e1-46e9-9460-3ed4af838fae	d73eac4c-d537-4d31-8e35-b55f8aff3e87	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7e2b8ec8-9b06-4dbb-9582-36ad2e97e993	c5e35b7a-af12-4fd6-96af-e62225e715c6	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
58fdc6ae-829e-458d-b780-aaf7a14d1b3c	df8f375a-d0b0-40c0-8ada-264fc2275f4f	2026-08-31	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2868de84-cb3d-4c4b-bd00-7d416fd7e87e	ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7da83908-3050-46d5-9fb8-d4b916140816	9ec115c7-5377-4f9d-b46a-2a3c97bea4de	2026-09-28	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
426a2575-09d3-45b5-9d1a-d28f166b77fc	f19ea8a8-4d2f-48f9-832e-311f80e49f11	2026-09-21	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d1bee652-2fab-46fd-80c3-951683c15b35	fb184814-7151-428d-87c3-f83814676aa5	2026-09-07	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1e7d08bc-a2ab-4617-b53b-d4c799a5e172	1fa56f20-56ce-4461-ac66-c7d7b34f16d6	2026-09-14	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4e77c34f-e170-4535-9adf-cfb31aca4802	d29c4919-9e2d-46c1-a78f-ffd2d4d32365	2026-09-07	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1a0ff201-ca72-4363-a694-02eeaaddb6b4	42583b6b-008c-45f6-b258-b08495712c7c	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
071bb657-be39-4eab-942d-18c01335f888	d01c0ef5-731e-42de-b02a-7c996c545f15	2026-09-21	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3b403d8d-c9f7-4f2a-964f-49acf4db9175	8e0616db-48af-4b73-807f-6e250dba2072	2026-09-14	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a095cc88-316a-43d6-93c4-01c3ba43ad75	777390a6-91b9-4d9e-806c-16e046568501	2026-09-07	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
55b920f1-fef9-4b9c-b0d0-848e73fcff30	74601727-6182-498f-ac57-4c02b9e56ca0	2026-09-07	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8f97eed7-672f-41f5-acce-e3b58867c285	696f99d7-2380-443c-b90d-0e065642e1d4	2026-09-07	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
201c79a5-605a-464a-baaa-ac85d1267832	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	2026-09-14	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
94b4aef0-bf71-4c9b-b356-dc9e53d36432	246e0bb0-8a3b-4524-9d7b-3ac6d4ca7d8d	2026-09-07	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ec8475cf-d1b2-402e-aa8f-8c437b0b8f41	d73eac4c-d537-4d31-8e35-b55f8aff3e87	2026-09-14	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7177a28c-91ee-4fc2-97ff-02354466546b	1fa56f20-56ce-4461-ac66-c7d7b34f16d6	2026-09-07	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fa393a39-1a54-46cb-83d9-fa4c9524f8fb	049ac489-bbd3-4153-b933-aec7b7baec89	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0695f858-7462-4c2f-9d58-3707a5229d9f	8e139039-c490-436d-9af4-431d26334b34	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f57535f2-2f64-46fd-8f86-47b0d6c1a589	f39b20bb-8963-4917-aed5-0f1d86f0cbc3	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d272ae33-052d-4d62-b6da-81248c246ec1	74601727-6182-498f-ac57-4c02b9e56ca0	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
508fea76-a00a-4a77-8d51-0a4c69eb7b10	02814af4-08b4-42cc-92e1-ad0bba687378	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a108dbe2-13b9-449c-963e-b41239635e02	bbe8dd34-5945-4f0f-ab99-2cb2f7c99c95	2026-09-14	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6b47b6ea-bc19-4f64-a9bb-afd103b26792	e93a25e9-5347-49e1-b901-88271fdbdcf5	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c1f69f84-7454-4431-89a8-9f78a70abd2b	86862bf8-c075-44ef-9f3e-f65d2cc1bb56	2026-09-07	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3433cb7c-5635-4ed4-a880-5329d0ca8ac3	900ed2a0-d8b3-439f-af86-7383cdebcd05	2026-08-31	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4a25041a-b6a6-40c0-bacd-7037675fac58	13428d48-c81e-4720-adba-f8490f27e535	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ed0a2a11-2bfd-408c-95b5-e50a13f185ad	818ae1ea-5842-4adb-b475-ac12dba9fd2a	2026-09-21	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6fafe1aa-9629-4d0d-9eda-2e1f3379fa90	faa36d59-2e24-4a0e-851d-42900c200d3b	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
471c3856-0a01-445b-aa3d-c5b917d6708f	b9c0b8fc-4c96-42fb-8669-d68097cf5392	2026-08-31	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5582e722-0853-4d56-8313-a503f7c7c794	d94878fd-4650-46bc-b84c-753c841e7404	2026-09-28	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3588549f-a226-4796-bcdc-80d076722a99	d73eac4c-d537-4d31-8e35-b55f8aff3e87	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
365b0d72-8387-4ae7-af45-71a10e73ea64	31e49978-ac22-44bb-a535-11d20d8aeea3	2026-09-07	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ec2957a7-1880-4f8e-b9c4-4ab3820c4a99	d502bbdd-5186-490e-8f0a-5489d2737c6f	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cf5307cb-ffb1-423a-b15f-63997d978d50	51015348-f872-4e18-b806-e44017e10e4b	2026-09-14	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
85213367-81f7-4ac6-bd39-5ce3715358ce	be9f417e-d40a-4c66-91e6-e7fde84b46d5	2026-09-28	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c353d35b-d98b-44a1-bbfa-29fbdb1105e4	f8b1a855-954d-4f8b-aad7-be5502a7413a	2026-09-07	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ee41b6dd-3e29-4373-8fdb-516da5392736	0a46bda6-6481-4bbe-8689-18fe959fa98a	2026-08-31	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5720bfac-81dd-4e51-a399-7e417cf5c652	dd200677-337b-440b-afcb-3a661406f98b	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
696e0c14-ffb1-44f1-aafd-e0967f5b7b7c	ee7b555a-4400-4c03-8fe5-60fd908c0e58	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
35c95ece-e577-430a-b63d-c4ab5ae195d2	246e0bb0-8a3b-4524-9d7b-3ac6d4ca7d8d	2026-09-21	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3ab479fa-10ed-4f81-a8f9-7fbea13c33e9	5ff0346b-75b8-4c62-afc7-afeb35b17a8e	2026-09-28	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c58940de-1476-49f5-99c6-c7679414e1c3	c5e35b7a-af12-4fd6-96af-e62225e715c6	2026-09-14	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2c4c9d30-33c8-4353-bb6b-d7d9587f8081	8e0616db-48af-4b73-807f-6e250dba2072	2026-08-31	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b6ff9ff9-1513-40c2-9e16-8c22c818d5f2	6b1f9737-c1f7-4201-8cd2-9b5e6274ebc8	2026-09-21	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a1b27637-ce8d-4db6-9c59-0784749a79ed	204776c8-efeb-480f-980b-a3f70be97f91	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2f965fe3-a696-4001-a793-ddf193feacbe	204776c8-efeb-480f-980b-a3f70be97f91	2026-09-21	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
46a20f9f-1516-4d8e-89cb-73c4e223e85a	6a1ac61a-89d6-4951-8246-621d4e1b071f	2026-09-14	submitted	34.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bdf4f026-0d55-4c09-9d02-0c4159ddaf79	a73329ac-636f-475e-b566-321a5686fd66	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
05188c96-059e-4c33-b946-1aa709528c1c	13428d48-c81e-4720-adba-f8490f27e535	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dfc9f8c5-384c-4f6e-9896-13bcd5a04b70	5f4b7ab9-bbfe-4196-9e6c-47f73efe7462	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
06f8ff35-af90-4eab-80d2-286d3f071e32	78c932da-077a-4104-919c-386de88ed062	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e0c3810c-a67d-4507-bfbe-1737a5d78c7c	86862bf8-c075-44ef-9f3e-f65d2cc1bb56	2026-09-28	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4997bbee-cc7a-42b6-8276-e08ff481ba67	fb184814-7151-428d-87c3-f83814676aa5	2026-09-28	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a5884eb9-5d7d-4964-a62e-07372f3f502c	5bf6d5c7-4358-49f1-bb6b-9d0b1b38d4ad	2026-09-21	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9aaa3757-ddc7-414d-969e-923b3b1690d3	d29c4919-9e2d-46c1-a78f-ffd2d4d32365	2026-09-28	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ad052a7e-a34c-4f59-89a1-b87e3b6f0936	bbe8dd34-5945-4f0f-ab99-2cb2f7c99c95	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3d2e44fb-671b-4247-9b98-702321001a46	d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	2026-08-31	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8683ecff-e970-48b5-ab61-42a0a3dd66b4	e09daabd-8da2-4dc9-89b4-03f4b79583de	2026-09-14	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a3047eac-d70b-498f-8178-8c6a3c91b4f9	405610b0-c3bd-4725-a409-5f6dbffeacb4	2026-09-28	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
50e6f9c9-1085-4ee7-81df-fd2790a8a0f9	b9c0b8fc-4c96-42fb-8669-d68097cf5392	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d782e2a1-b58a-4d8f-8af3-c1a17ea45c3a	bfb55863-c987-497b-9a1b-9a7bc56a9509	2026-09-14	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cee36b44-c6e6-465c-a3d9-7e899ec585f1	315ae0c9-ecdf-48ba-a662-f93c21ef31d2	2026-09-14	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d04f1ea3-411d-4b59-8378-702057c6c556	5e82125c-9ff8-4a97-a11b-65da79677d3c	2026-09-07	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0bf6e418-c552-4dfa-8870-83c6ac11b6bc	ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	2026-09-21	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a3fb1170-35fb-4061-91d9-0eaee55d8746	f30d1ce8-8a1a-483d-ace2-419cd8672ecc	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a13c3a44-87a7-4e94-99ac-d5f6bc8206bd	bbdc4c49-4262-4c1a-a270-1bfe3c550644	2026-09-21	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f9e4cd0b-8507-49cf-8fc7-f5380680fabc	900ed2a0-d8b3-439f-af86-7383cdebcd05	2026-09-21	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
caa254e3-c5f4-41d4-8628-d0c650dac27d	b9c0b8fc-4c96-42fb-8669-d68097cf5392	2026-09-21	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
767303e1-14f2-4707-9db7-48e0a1566707	a73329ac-636f-475e-b566-321a5686fd66	2026-09-14	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ec5efdf8-b7fa-4dae-a6a0-d66bbd650030	cc295432-e771-4d6f-9cc3-079cc5d9b576	2026-09-14	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fdeb5beb-554e-46c6-8d70-83ea9e2416e6	218f30c7-87bd-4410-99fc-4d10da3e8014	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7b922344-bfef-47c9-8ff7-756a7d3daec3	ee7b555a-4400-4c03-8fe5-60fd908c0e58	2026-09-14	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
81c67782-3f2d-489f-8302-c4aa14c6b11b	78b71d74-d255-4ac0-a75f-ead11a61427a	2026-09-21	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7882cd9d-963c-4022-b2df-114e4bb09c05	13b14e34-f865-4c83-a6c0-3fdf7d196c1c	2026-09-14	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e7bee937-7244-43f3-8d61-20282818eef7	315ae0c9-ecdf-48ba-a662-f93c21ef31d2	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cddb66c8-0795-4321-8b8f-50fc348c7b3e	6d26e662-1e9f-4df8-a353-6be5ce9e5261	2026-09-28	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
905da889-399e-490b-9920-5c712a0538bb	f8b1a855-954d-4f8b-aad7-be5502a7413a	2026-09-14	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a932015f-cd95-47bd-8f96-1d31389dc9a5	f39b20bb-8963-4917-aed5-0f1d86f0cbc3	2026-09-14	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5f21c5a9-e8b8-4851-88ef-87cc1afac45b	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	2026-08-31	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bd9153dc-1b3f-4cd1-88ca-299dca449e7e	31057f6b-b1e5-46e3-a071-b6639b93a15c	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
645196d6-dab2-4b2b-b9ef-ee45a8745a8d	faa36d59-2e24-4a0e-851d-42900c200d3b	2026-09-21	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8791659b-bd5a-4b67-a05c-4444734dc0c9	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	2026-09-21	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
766d0890-9fd8-47ca-bf2f-d7c523b26e1b	2285ceea-ffbf-4bf4-bb2e-bd9e0427beeb	2026-08-31	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
156942a5-7160-4298-a9b0-6fd986530382	bbdc4c49-4262-4c1a-a270-1bfe3c550644	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
07baa8b7-84ba-483b-9dc5-2d06436bcbb4	f39b20bb-8963-4917-aed5-0f1d86f0cbc3	2026-09-21	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c175734e-a012-4234-a43c-e24118bb3c3f	5e82125c-9ff8-4a97-a11b-65da79677d3c	2026-09-14	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
136c5069-02a0-4dd8-bf48-e141d058b3a3	6d26e662-1e9f-4df8-a353-6be5ce9e5261	2026-08-31	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
532e70c2-6560-44e0-b630-05dfe8072336	86862bf8-c075-44ef-9f3e-f65d2cc1bb56	2026-09-14	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
be2e0e48-1f57-4062-8d4a-29fe6b547e3d	bfb55863-c987-497b-9a1b-9a7bc56a9509	2026-09-07	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cce3117f-a230-4ef8-80a7-e05f10e9eb81	ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
20f465eb-f2e2-46a0-8513-44380ac8cf40	33e9644b-a618-47ed-b272-c078e19b36ef	2026-09-21	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4e01d4cb-c63c-4979-93f8-558245199e4f	6b4e0847-6c40-471e-89ec-c5b63bb828f0	2026-08-31	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e3f5183e-8f90-4c7d-a630-2b7614db6151	246e0bb0-8a3b-4524-9d7b-3ac6d4ca7d8d	2026-09-28	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
61338963-c2ac-452f-a771-4a8bbf70654f	315ae0c9-ecdf-48ba-a662-f93c21ef31d2	2026-09-21	submitted	30.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0f81e1eb-3d28-4382-8de2-eb4848e5b058	46e3d71d-ea02-474f-b668-f836d91e059d	2026-09-07	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c64a30b7-17bd-4a97-90c7-8cace7630372	e131815f-331f-46d7-81f8-5d2bed793630	2026-08-31	submitted	30.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3806ac94-e7e2-4c2b-b787-7671edf0bfca	bbe8dd34-5945-4f0f-ab99-2cb2f7c99c95	2026-09-21	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
39788b9c-ca63-41c9-a22c-1c8ed9e037b4	f8b1a855-954d-4f8b-aad7-be5502a7413a	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
54e9052c-d9be-4333-b48b-57441f17a28a	2b245a46-a64c-440b-861d-24f712bd626e	2026-08-31	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c3927d4f-3a80-4a81-89c3-f6e622588a85	dd200677-337b-440b-afcb-3a661406f98b	2026-09-07	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
16b646d8-e169-4893-a880-b4a23274dd04	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2e3d97fe-d716-44e9-affd-7dc81d7ae3c2	0a213b8b-1836-4660-9116-536fc9436639	2026-09-14	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0926dcc3-69ec-4b0a-9060-6da7559a544d	bbdc4c49-4262-4c1a-a270-1bfe3c550644	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cf18cef9-6ccd-4d7a-83f3-4c6dbbe27c0a	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5efba3bc-ca23-478c-b7c1-7f80a9ec5333	033446c7-c133-4395-bdaa-69b5f227a7a8	2026-09-14	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
33f95908-375a-4f41-8c61-f2bb63839eb4	3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	2026-09-21	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1af1bd2c-83fb-4737-941e-e2f9b26857c8	7d2b2c7a-254e-4605-9f79-3f42ac7f9735	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
406672b9-70e7-4250-b329-aa8b7938dc17	42583b6b-008c-45f6-b258-b08495712c7c	2026-09-21	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e9203789-12e9-49e1-9930-2e28c83c8db3	849d2fb1-a4e4-4eb2-947b-f97057e4954b	2026-09-07	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
76d8db68-d47d-4f78-b727-2ac43d43e641	7d2b2c7a-254e-4605-9f79-3f42ac7f9735	2026-08-31	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f7db94c0-3cbe-45c0-8745-383ec453a4fd	ca561f47-f73a-4401-8c6f-a1c776d88534	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d511c9cd-a0f8-4c37-8f15-e3a8dcb717c7	804c8187-6f28-411f-8fa5-cc9baceba3e7	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fc49a861-abc7-4514-925a-0cd6eeec4540	8e139039-c490-436d-9af4-431d26334b34	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
eaa08a35-9b5e-47da-98e3-b417962ceb9d	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	2026-09-07	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aa82ab21-c2fa-4b8e-9ba2-1825a9d634dc	7e3f1c8d-340c-47d7-b63d-fb047a9106aa	2026-09-28	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0cd26b65-2c42-4de5-b9e3-098b89b635b5	405610b0-c3bd-4725-a409-5f6dbffeacb4	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0eb758c1-467b-4df6-9bd3-05fce3177049	7e3f1c8d-340c-47d7-b63d-fb047a9106aa	2026-08-31	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a7903d05-c1d9-4e20-a44b-c2ba5570a776	049ac489-bbd3-4153-b933-aec7b7baec89	2026-08-31	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8a816907-21b6-4f08-925f-39cf59acc9ce	450f16b6-e35c-4564-969d-6bf6ceec7ff3	2026-09-21	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f2fe6e39-a58d-47b1-956c-2324f63eafb8	9c4cf836-745e-4cf9-9a22-933d5e2638c3	2026-09-14	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
84d36901-a17d-495b-a48f-012eb48f5296	f8b1a855-954d-4f8b-aad7-be5502a7413a	2026-09-21	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
68011bb6-69ba-4a82-b392-d03aeaf55ac9	5ff0346b-75b8-4c62-afc7-afeb35b17a8e	2026-09-14	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2319ab46-f86d-49b7-bbad-f534e43a965d	c5e35b7a-af12-4fd6-96af-e62225e715c6	2026-09-07	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2abc6301-373e-48bd-8963-75efe3d1ce2e	78c932da-077a-4104-919c-386de88ed062	2026-09-21	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a8dfd60c-a1f7-401f-8e4e-bf081455c135	6b1f9737-c1f7-4201-8cd2-9b5e6274ebc8	2026-09-07	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a75b9e90-2bbb-4fcd-a161-5e003524bcda	51015348-f872-4e18-b806-e44017e10e4b	2026-09-21	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a89cf0e1-55c0-41db-9b55-3ba94196f036	42583b6b-008c-45f6-b258-b08495712c7c	2026-08-31	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4f25a003-6751-4f26-822b-6e01257bab61	9c4cf836-745e-4cf9-9a22-933d5e2638c3	2026-08-31	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bf5acb67-920a-4bbc-a588-0c4b778e1bd2	9ec115c7-5377-4f9d-b46a-2a3c97bea4de	2026-09-21	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
66c7ea36-3062-4fc4-bbbe-ef8f817b5b44	86862bf8-c075-44ef-9f3e-f65d2cc1bb56	2026-08-31	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aad2f885-883c-43e0-a924-1d96b9b8b802	d9fd54d6-b11b-4969-a25d-8b8e3fcca417	2026-09-14	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e6a89eb9-8efe-4d83-907b-9f407bc9a76d	f19ea8a8-4d2f-48f9-832e-311f80e49f11	2026-09-28	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e76b5d73-5802-4468-a34e-075be53315e1	3398777f-d384-48a2-8076-9c4fb06162bb	2026-09-07	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4f41a625-d443-4430-970b-279cdbaaf734	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	2026-09-28	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9405bb52-6694-497e-915d-93cdd893a9c7	d29c4919-9e2d-46c1-a78f-ffd2d4d32365	2026-09-14	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
54122528-8eb8-45a3-97d7-1728707d696e	e131815f-331f-46d7-81f8-5d2bed793630	2026-09-28	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e519589c-0f59-40d9-95bf-92da3d44c9a0	218f30c7-87bd-4410-99fc-4d10da3e8014	2026-09-14	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b9830a11-42a3-4096-951f-22e4e0ab60cb	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	2026-09-21	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b7fc18c0-5c61-4b63-980f-8b1963a0594c	df8f375a-d0b0-40c0-8ada-264fc2275f4f	2026-09-14	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
58424e43-a5f1-4dd3-a418-2ec4dcb0ecf8	d29c4919-9e2d-46c1-a78f-ffd2d4d32365	2026-09-21	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
99ba1131-490c-4a13-9535-2ba373389f3d	818ae1ea-5842-4adb-b475-ac12dba9fd2a	2026-09-07	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
99a92bda-b3c9-4247-8c62-2998f72fc4b7	26fd3209-693a-49d1-9224-8f7e2f3a1c58	2026-08-31	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f7ee752e-716f-476b-bae6-a928a72348cc	d17be428-1602-4e09-a164-c3c2666fad73	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8a1d1b73-3c0a-468f-9521-9b2403337a7c	3a209908-397f-4c90-abf6-9fe52ab98b34	2026-09-21	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
53d298f6-fac5-41f0-873c-0f9abd1163ac	70e01a7d-fd0b-4e2a-b086-d059423ca380	2026-09-21	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0103c8a7-7e84-4d2f-9a60-425e0ad9f8df	033446c7-c133-4395-bdaa-69b5f227a7a8	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2abd6505-72e8-409a-9b1f-07bcb7d63a7a	d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	2026-09-21	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5b2671e2-33a8-477e-8fa0-d15d4549293a	ffcdc44f-996b-4ef6-90e6-db858823a4c4	2026-08-31	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9b6ffff2-317a-42a8-b37b-d386c94a6d29	faa36d59-2e24-4a0e-851d-42900c200d3b	2026-09-28	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
82e8c691-deba-43dc-9325-a75104721b94	9b7f4410-6577-4ab4-9363-e75b9d4208e9	2026-09-28	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4f5964a8-c0b6-42c5-a64c-f1aa3d12185e	33e9644b-a618-47ed-b272-c078e19b36ef	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d589ee25-eee3-4d0b-9a75-aa2e99111bec	13428d48-c81e-4720-adba-f8490f27e535	2026-09-14	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b69a31ca-f356-4718-ac18-830f0c19d7ee	5f4b7ab9-bbfe-4196-9e6c-47f73efe7462	2026-08-31	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9aad5a2d-db75-4975-900a-4a6cecc07d3c	818ae1ea-5842-4adb-b475-ac12dba9fd2a	2026-08-31	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f6a80156-7740-4d4e-bc22-b1748585ac69	9b7f4410-6577-4ab4-9363-e75b9d4208e9	2026-09-21	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9edac68b-e711-4ae0-a94f-126c5f58ec5e	d9fd54d6-b11b-4969-a25d-8b8e3fcca417	2026-08-31	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
51753f35-8325-4979-bbbf-1ba115d4a2e0	d01c0ef5-731e-42de-b02a-7c996c545f15	2026-09-28	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dc4c4541-c204-4702-8f71-3579748bb1ed	74601727-6182-498f-ac57-4c02b9e56ca0	2026-09-21	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2b933faf-de8c-4eb5-8bd1-af873dcb719e	51df4d23-9202-43b7-9e29-4a14a838a242	2026-08-31	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
24af3c24-97c6-40b0-b389-b6cba6edd5ba	900ed2a0-d8b3-439f-af86-7383cdebcd05	2026-09-28	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9ff048db-7505-413c-a7cf-0fb2094cb168	62e81e6b-7247-4c3f-a8b8-db21e613d02a	2026-09-21	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
72c8228f-d590-400e-ac80-cca21499d44e	fb184814-7151-428d-87c3-f83814676aa5	2026-09-21	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
61a34c53-18d6-4921-88fa-805cb533f5f8	46e3d71d-ea02-474f-b668-f836d91e059d	2026-09-28	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8de6dbf7-e3e4-4d01-bb4d-b3a91ba39649	13b14e34-f865-4c83-a6c0-3fdf7d196c1c	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6ed61629-4b56-46f0-8f37-0ba584253638	41708635-a60e-4fbd-a76b-91c0c23d18be	2026-09-21	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4f50fc6e-cd66-40d9-8e0b-8a7fea41a474	86862bf8-c075-44ef-9f3e-f65d2cc1bb56	2026-09-21	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f04c0463-f944-406f-92bd-0bbe3e4137f6	583e812b-e929-4e7c-9d76-33d3fc25cd7d	2026-09-21	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
44924c47-fc7e-4aab-90a1-4185c1414a0b	b9c0b8fc-4c96-42fb-8669-d68097cf5392	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
728d23d8-8fca-4c0e-a8a8-2b98405763be	a73329ac-636f-475e-b566-321a5686fd66	2026-09-21	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bc223b40-269d-4e41-a475-1c6662205760	dd200677-337b-440b-afcb-3a661406f98b	2026-09-21	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2a86a333-109a-4e2e-9ec1-fa53e05b7411	5e82125c-9ff8-4a97-a11b-65da79677d3c	2026-08-31	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
66843f47-5ba9-464c-9001-9b6b9351c312	51df4d23-9202-43b7-9e29-4a14a838a242	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c79dca90-1715-4644-8209-20097c561c01	450f16b6-e35c-4564-969d-6bf6ceec7ff3	2026-08-31	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
07eff1fb-8146-4783-8e94-258c62b864a1	bbdc4c49-4262-4c1a-a270-1bfe3c550644	2026-09-14	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bad1e79d-7aab-460b-8fe4-30cf493c58b7	e131815f-331f-46d7-81f8-5d2bed793630	2026-09-07	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
30a8b906-4252-4229-a29f-2701d4f2af19	6b1f9737-c1f7-4201-8cd2-9b5e6274ebc8	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
349a4f71-5cfd-42ea-9f27-1df8914c92dc	3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	2026-08-31	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
149030d9-f0a0-4d7c-ba09-10336ab95377	7e3f1c8d-340c-47d7-b63d-fb047a9106aa	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a1730346-3029-47dd-9991-7cf9c49e0150	777390a6-91b9-4d9e-806c-16e046568501	2026-09-21	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6b619d35-f3b9-4bbe-b90d-32e39aa410e1	d502bbdd-5186-490e-8f0a-5489d2737c6f	2026-09-21	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
480a9077-4b48-46c1-ad64-fe8a588250ad	9f646393-8fea-4b38-9f35-d88a6ab6787e	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
60a4d3c0-87ce-4707-98f0-91570ecb029b	7d2b2c7a-254e-4605-9f79-3f42ac7f9735	2026-09-07	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8fb2e6b5-2a3a-480e-9121-e7f98fbba6c3	2b245a46-a64c-440b-861d-24f712bd626e	2026-09-21	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c28fa629-f3dd-4765-8fb6-b28609d57e61	70e01a7d-fd0b-4e2a-b086-d059423ca380	2026-09-07	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7c145d58-67ad-4bbd-b5a4-c4cb9ae3567d	bbe8dd34-5945-4f0f-ab99-2cb2f7c99c95	2026-09-07	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7b51d35e-8bc2-4178-8f65-352e1a0dcb49	d502bbdd-5186-490e-8f0a-5489d2737c6f	2026-09-07	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bd2b1d3a-43ac-4b5b-b9fb-1b00ed09115d	51df4d23-9202-43b7-9e29-4a14a838a242	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
93f90956-ca0e-4e62-838f-4509817ad6ad	41708635-a60e-4fbd-a76b-91c0c23d18be	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f0959dec-f1e8-4e96-ba34-0b7da71533f5	7d2b2c7a-254e-4605-9f79-3f42ac7f9735	2026-09-21	submitted	30.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d05828aa-bc9d-476e-8c53-aa4dbd864881	818ae1ea-5842-4adb-b475-ac12dba9fd2a	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1ea72c28-e4fd-4380-b80f-5162bf98a441	f19ea8a8-4d2f-48f9-832e-311f80e49f11	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ddfa029b-9db7-4f27-9eeb-1f35df0a95fc	31057f6b-b1e5-46e3-a071-b6639b93a15c	2026-09-21	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
68657543-e964-4469-b424-84ce653d4fda	f19ea8a8-4d2f-48f9-832e-311f80e49f11	2026-08-31	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9a924e59-d338-4461-8782-2b188d989e82	f8b1a855-954d-4f8b-aad7-be5502a7413a	2026-09-28	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a011061e-5a88-4415-8807-859b23b2584d	049ac489-bbd3-4153-b933-aec7b7baec89	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aeceaa1d-5dc8-4c67-8f3b-ee4e311c11f0	804c8187-6f28-411f-8fa5-cc9baceba3e7	2026-08-31	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d5edd81c-2218-499c-a7b8-a960283eb9f6	33e9644b-a618-47ed-b272-c078e19b36ef	2026-09-28	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8978b44f-94df-4360-b631-74e6940d960d	9eb64ade-203d-4e4a-aaed-8eaab7d3017d	2026-09-21	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6a2b7766-a588-4635-b4a9-e33b20fee843	3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	2026-09-14	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ef6cfc1b-c980-4d90-bf1c-62ba8455d172	e09daabd-8da2-4dc9-89b4-03f4b79583de	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
31f6b6b5-21c3-4a20-bf5c-0e6a5126779f	e93a25e9-5347-49e1-b901-88271fdbdcf5	2026-09-21	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f097ebe3-5bbe-4f56-9dbd-2512037d26bc	8f3346d4-6f76-4575-af6d-a69527694680	2026-09-21	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2af97f44-85cd-4391-b0a4-a188a3b2f883	faa36d59-2e24-4a0e-851d-42900c200d3b	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5c65c72c-7c55-42b6-acd4-5bdc9a622c7d	777390a6-91b9-4d9e-806c-16e046568501	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
efd37a89-9d4c-4778-8898-6809e859e537	13b14e34-f865-4c83-a6c0-3fdf7d196c1c	2026-09-07	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2c810cae-07e0-425a-995c-23d1d2a0fcdf	238c3cb7-75cf-4478-a48e-fe47465d20b6	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a760daee-87c9-488f-b428-db22b38de83a	9eb64ade-203d-4e4a-aaed-8eaab7d3017d	2026-09-14	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0c8d376b-f9fe-414b-9476-d826f249be8e	ee7b555a-4400-4c03-8fe5-60fd908c0e58	2026-09-28	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e5e03d36-006d-4baf-870b-86b4f2d9cddd	0a46bda6-6481-4bbe-8689-18fe959fa98a	2026-09-07	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
beb48512-20d3-4b67-a375-1968753d864a	31e49978-ac22-44bb-a535-11d20d8aeea3	2026-09-14	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
64703b23-f8dc-4b4d-993f-da7e5da542b4	f90e007c-90d9-440e-8f0a-a85395e49abe	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
59607403-d358-4bfc-8ceb-ff2e06801a58	d17be428-1602-4e09-a164-c3c2666fad73	2026-08-31	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7ec1811a-bd0b-43f0-8ad2-772a27c56141	31057f6b-b1e5-46e3-a071-b6639b93a15c	2026-09-14	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3885101d-467e-4079-a586-9f36c0040c2d	e131815f-331f-46d7-81f8-5d2bed793630	2026-09-14	submitted	30.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2f1c7504-8342-4549-8e7c-41ecf65d890e	be9f417e-d40a-4c66-91e6-e7fde84b46d5	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
237fd517-7750-4e1d-b4e5-4fb0a22bec5f	2285ceea-ffbf-4bf4-bb2e-bd9e0427beeb	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bffee663-d980-4c57-925f-362cd69d6b5a	777390a6-91b9-4d9e-806c-16e046568501	2026-09-14	submitted	30.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
68b95cd1-ea28-4554-9243-10cabe75bae0	d94878fd-4650-46bc-b84c-753c841e7404	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
582e8ba4-9314-4fc7-8e62-17cb3d48f3cf	4d8e2104-d723-45a0-856f-594f80efd0f6	2026-09-14	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0ad1a2cb-c6ab-46fb-ad1a-2ac2396be256	d17be428-1602-4e09-a164-c3c2666fad73	2026-09-28	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a304d38c-e508-4fcc-8e0b-dbaf3112a1f1	776f2cf7-c4cc-4299-b38f-afbcaff7703e	2026-09-07	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
63a55762-d041-442a-b50f-df03e317925e	1fa56f20-56ce-4461-ac66-c7d7b34f16d6	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aa13cca7-ffd8-4e94-b1e7-8576390b6c68	cc295432-e771-4d6f-9cc3-079cc5d9b576	2026-09-21	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6bab7232-09ad-4570-a534-2c12a2296b3e	9c4cf836-745e-4cf9-9a22-933d5e2638c3	2026-09-21	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
774cc368-a1ac-470b-a5dc-83875d41b755	f39b20bb-8963-4917-aed5-0f1d86f0cbc3	2026-08-31	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dc7aa965-ccdb-44a8-ae01-b6f8aba3680b	46e3d71d-ea02-474f-b668-f836d91e059d	2026-08-31	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ce4975e2-4637-486d-8168-4cd263a5e566	78b71d74-d255-4ac0-a75f-ead11a61427a	2026-09-14	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cf24c382-498e-4598-b90a-6cf34a7cbfd2	faa36d59-2e24-4a0e-851d-42900c200d3b	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9e64d24b-dfa7-43e9-87e8-7c37f81a1c55	f19ea8a8-4d2f-48f9-832e-311f80e49f11	2026-09-07	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2e444be9-7889-4048-b447-9d5e7c3c6e38	9d9bfa3a-8603-4de4-8eb7-76c3935e3014	2026-09-21	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f13dcab9-4bc2-4783-a221-4646393850c4	8e139039-c490-436d-9af4-431d26334b34	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9f267402-5f9e-40ab-b625-92269f6ed265	ca561f47-f73a-4401-8c6f-a1c776d88534	2026-09-07	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
55380174-0b1c-4119-8f60-6a68716143a7	b9c0b8fc-4c96-42fb-8669-d68097cf5392	2026-09-14	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0b6cddcd-20ac-4f19-b481-c746d9d85993	df8f375a-d0b0-40c0-8ada-264fc2275f4f	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7c225d66-a64d-4ba6-9ffa-a3ad825aeb4b	6b4e0847-6c40-471e-89ec-c5b63bb828f0	2026-09-14	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f75433f4-ab99-4793-a041-a2f4f81ef835	dd200677-337b-440b-afcb-3a661406f98b	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9fd071fb-41c4-4b84-8dec-9d35a0cff342	246e0bb0-8a3b-4524-9d7b-3ac6d4ca7d8d	2026-09-14	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
271e2ab7-97c7-4192-aae7-a056251d3cd8	bbe8dd34-5945-4f0f-ab99-2cb2f7c99c95	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
eb66890b-117f-4653-9a13-af84114e39ca	6d26e662-1e9f-4df8-a353-6be5ce9e5261	2026-09-07	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3866a1a9-7608-4452-bdbb-439f49718561	238c3cb7-75cf-4478-a48e-fe47465d20b6	2026-08-31	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6c4adf02-d681-446d-bc6f-f91ff6ce0994	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	2026-09-21	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ff731d54-84cc-4c10-83c5-8ebd29aabe88	2b245a46-a64c-440b-861d-24f712bd626e	2026-09-28	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6bb6e8ba-95f7-49ee-b8d6-fc7a0826557f	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
65730d88-40bb-4148-b6f0-79b4fd701058	eba0b052-26bb-4216-ab6e-dff23c63bc57	2026-09-21	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
429929ae-6fd3-45ff-8864-cb860d5e8887	9d9bfa3a-8603-4de4-8eb7-76c3935e3014	2026-09-07	submitted	30.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c2ed96f6-1b19-4611-9b4f-e4d8fa146e67	8f3346d4-6f76-4575-af6d-a69527694680	2026-09-07	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4c20af85-1400-4cf2-ab32-c98a56f22e4d	3398777f-d384-48a2-8076-9c4fb06162bb	2026-09-21	submitted	32.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6f2d4a19-76cd-4588-a723-18628f7ee13a	9312226e-c7f8-4187-887e-67e2124098cd	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
511b5e73-6af8-4a51-af7b-6d8682eef3de	8f3346d4-6f76-4575-af6d-a69527694680	2026-09-28	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
48f29c6a-73a8-4476-8d96-5f145f3cf530	26fd3209-693a-49d1-9224-8f7e2f3a1c58	2026-09-28	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9ae80c20-c9c2-49c2-b4f4-2df1237738b8	8e0616db-48af-4b73-807f-6e250dba2072	2026-09-21	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
02954b7a-debd-46fc-878b-0e473e8772bc	849d2fb1-a4e4-4eb2-947b-f97057e4954b	2026-09-14	submitted	34.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1fb012b8-ed76-499e-87b2-f26f6aaf8da1	3398777f-d384-48a2-8076-9c4fb06162bb	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5f40315c-e948-4f0c-9df7-81bffebdefc8	9b7f4410-6577-4ab4-9363-e75b9d4208e9	2026-09-14	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
12063df3-83f1-4bfd-a597-91609cf6a566	51015348-f872-4e18-b806-e44017e10e4b	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
170036f2-59cb-4ae2-9f35-71f5ca3aded6	13b14e34-f865-4c83-a6c0-3fdf7d196c1c	2026-08-31	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
78f18639-860e-4bd3-a755-78ca2f1f4c1e	fb184814-7151-428d-87c3-f83814676aa5	2026-09-14	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
02806910-0c69-4bd4-be76-cc5d68773070	5ff0346b-75b8-4c62-afc7-afeb35b17a8e	2026-09-21	submitted	32.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b1fa05ae-990b-415e-bfb6-c7b7581215e2	2b245a46-a64c-440b-861d-24f712bd626e	2026-09-14	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dfe2f714-f4dd-44ff-8881-66ff09f27d59	41708635-a60e-4fbd-a76b-91c0c23d18be	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4c08c52f-403e-4ba3-a439-9af336feadb9	8e0616db-48af-4b73-807f-6e250dba2072	2026-09-07	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
47ff8fdb-2002-4ce0-adc2-f7a4eaeac61d	6a1ac61a-89d6-4951-8246-621d4e1b071f	2026-08-31	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4ceef052-4a77-42c0-bcaa-196605be5275	405610b0-c3bd-4725-a409-5f6dbffeacb4	2026-09-14	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
67b38ca6-3e44-493f-a1e8-c0403620e7b1	450f16b6-e35c-4564-969d-6bf6ceec7ff3	2026-09-07	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b8f63046-1789-4cfb-899d-f5a59e547a11	049ac489-bbd3-4153-b933-aec7b7baec89	2026-09-21	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
673c3714-64f7-4326-8861-2a14eec01f90	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	2026-09-07	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fe85fd1e-4616-4055-86ca-6ec25e0c1d5f	5f4b7ab9-bbfe-4196-9e6c-47f73efe7462	2026-09-28	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f8550bcb-3568-4189-b35a-578ae9f0ba90	3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	2026-09-28	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f60349df-2a56-4c44-a78e-2a9f99cacf8f	be9f417e-d40a-4c66-91e6-e7fde84b46d5	2026-09-21	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
19f171e3-eb72-4e87-a0e2-3a048f2dba6d	13b14e34-f865-4c83-a6c0-3fdf7d196c1c	2026-09-21	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c75826ce-460f-4fbe-9e69-5e5421c321e9	42583b6b-008c-45f6-b258-b08495712c7c	2026-09-14	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
67930c50-abd5-4219-84b5-f8b8d2a585f7	246e0bb0-8a3b-4524-9d7b-3ac6d4ca7d8d	2026-08-31	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8679bbaf-656a-46f8-a97b-d5576fe89552	5bf6d5c7-4358-49f1-bb6b-9d0b1b38d4ad	2026-09-07	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cb712e11-caf0-4902-ac85-e022817dc31c	9d9bfa3a-8603-4de4-8eb7-76c3935e3014	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4647afec-f1fa-469d-bf1c-ee5bf0629d75	9ec115c7-5377-4f9d-b46a-2a3c97bea4de	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
80201c59-2aaf-42b3-a5e4-2a6d82810c66	9312226e-c7f8-4187-887e-67e2124098cd	2026-09-21	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0d9d191f-fe83-4f87-bfde-324b869bff73	804c8187-6f28-411f-8fa5-cc9baceba3e7	2026-09-14	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
48c6917b-27f1-44b8-80a7-fbc595b23e60	f30d1ce8-8a1a-483d-ace2-419cd8672ecc	2026-09-07	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
43378f0d-4cbe-460a-8f14-be874269cd24	849d2fb1-a4e4-4eb2-947b-f97057e4954b	2026-08-31	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e3c8835b-9d5c-4e5c-b723-c961592cb7cf	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	2026-09-14	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9cadec4f-20a3-4c95-afc6-546573e76a1d	049ac489-bbd3-4153-b933-aec7b7baec89	2026-09-14	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
237cce96-2a25-44a6-9087-088c8cd9681f	450f16b6-e35c-4564-969d-6bf6ceec7ff3	2026-09-28	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cb75a35a-9173-4ddb-9b79-8b8ac682b055	f01f614a-af85-4225-a3b4-3c463fb97bdf	2026-09-28	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
eb3102b2-3d1c-439a-bfa4-aab63d1a63a6	0a213b8b-1836-4660-9116-536fc9436639	2026-09-07	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7e4e9a26-9c8c-490f-93db-ee3294b224e2	ee7b555a-4400-4c03-8fe5-60fd908c0e58	2026-09-21	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
db95200f-9b6e-42dd-b667-6de669ac81df	1fa56f20-56ce-4461-ac66-c7d7b34f16d6	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
05746d44-a338-4c09-b7ec-e86404e873d6	f90e007c-90d9-440e-8f0a-a85395e49abe	2026-09-21	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d049f6b7-b4d0-4dd1-93b0-547371f68cc1	0a213b8b-1836-4660-9116-536fc9436639	2026-09-28	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6354704d-03d4-4701-b2db-af8b87537fec	9b7f4410-6577-4ab4-9363-e75b9d4208e9	2026-08-31	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3cb11040-f0d0-4b48-b0cb-d7a160501651	9b7f4410-6577-4ab4-9363-e75b9d4208e9	2026-09-07	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a2f18333-8cc9-4a6b-8fb7-b5bccf33bd8c	2285ceea-ffbf-4bf4-bb2e-bd9e0427beeb	2026-09-21	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ff90f6ac-ef43-4191-9422-238780834d1e	9f646393-8fea-4b38-9f35-d88a6ab6787e	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8e82e03f-d2af-4d77-9208-712cfeb46a55	159fb3d0-937c-4f81-ad37-aa1b4f023264	2026-08-31	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0e458a7c-16b1-4a24-91b4-d5a14d80531f	d73eac4c-d537-4d31-8e35-b55f8aff3e87	2026-09-21	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
911fbc88-8b11-43d0-a25d-ba4a6e864c52	3a209908-397f-4c90-abf6-9fe52ab98b34	2026-08-31	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
dd6fc047-4171-418e-8196-963af8e669cf	41708635-a60e-4fbd-a76b-91c0c23d18be	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b34a5dd4-0c65-4565-b70a-064bac701bd6	776f2cf7-c4cc-4299-b38f-afbcaff7703e	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
acf1bea6-8a44-4a6c-8267-73d526421fd1	776f2cf7-c4cc-4299-b38f-afbcaff7703e	2026-09-28	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
df57e0ce-5a84-466b-ac69-f7212f665baf	5e82125c-9ff8-4a97-a11b-65da79677d3c	2026-09-28	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
661008cf-01e0-4e94-8a69-0b055e5fc437	ffcdc44f-996b-4ef6-90e6-db858823a4c4	2026-09-21	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
68b4477c-062c-4405-bbd7-1c9360a6f02b	849d2fb1-a4e4-4eb2-947b-f97057e4954b	2026-09-21	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
829b354f-74a0-4e7d-9699-86bce6d73971	5f4b7ab9-bbfe-4196-9e6c-47f73efe7462	2026-09-21	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d756e58e-9c8f-408f-ab6b-9cedac05677e	26fd3209-693a-49d1-9224-8f7e2f3a1c58	2026-09-07	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0e2c3acd-83f8-49d9-b619-ad184cb79062	583e812b-e929-4e7c-9d76-33d3fc25cd7d	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
21b5e364-8c29-40d8-b0b4-e1c593fbd100	033446c7-c133-4395-bdaa-69b5f227a7a8	2026-08-31	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3a5447bd-9328-40cb-8309-0b525fb6561c	9f646393-8fea-4b38-9f35-d88a6ab6787e	2026-09-14	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d401d21a-ffc3-4264-a3dc-5418885c28b5	9f646393-8fea-4b38-9f35-d88a6ab6787e	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2a5ab4bc-301f-43ab-bab9-07261789f1d5	9c4cf836-745e-4cf9-9a22-933d5e2638c3	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
58335189-c317-4a94-b73d-0f9a279d5114	78c932da-077a-4104-919c-386de88ed062	2026-09-07	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8bef6f81-a5ee-4167-871a-25743225e935	bfb55863-c987-497b-9a1b-9a7bc56a9509	2026-08-31	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6dda9806-1e48-45e2-9d1b-b32aecdd0e5b	6b4e0847-6c40-471e-89ec-c5b63bb828f0	2026-09-07	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f4b0e40e-8ab3-4f6c-8225-635403b8697e	26fd3209-693a-49d1-9224-8f7e2f3a1c58	2026-09-14	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
06a039ed-d687-446a-b976-4c6b4e4e6490	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b09c3ebd-3d18-4f60-8fde-35c27aece9b2	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	2026-09-07	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1e4b258d-4566-46b9-a75d-26b30c416f6d	f90e007c-90d9-440e-8f0a-a85395e49abe	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4786e835-9531-4439-9178-be53a028bb8e	d502bbdd-5186-490e-8f0a-5489d2737c6f	2026-09-14	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e534a6c1-4648-4d6d-8093-7d3ed9b755d1	31057f6b-b1e5-46e3-a071-b6639b93a15c	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3fcd45c0-2ebf-4aec-9852-69354d528ef0	f01f614a-af85-4225-a3b4-3c463fb97bdf	2026-09-07	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c31652a9-a4f1-49c8-bb20-7922ad4a5cf8	46e3d71d-ea02-474f-b668-f836d91e059d	2026-09-21	submitted	32.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0e42696d-7d9d-431f-9c8a-d35dd28ef28c	d502bbdd-5186-490e-8f0a-5489d2737c6f	2026-08-31	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d2d88c04-8dcb-4563-9d91-df82739afad5	5bf6d5c7-4358-49f1-bb6b-9d0b1b38d4ad	2026-09-14	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6354fa39-6abe-4110-ae8c-f7f1ace03464	9f646393-8fea-4b38-9f35-d88a6ab6787e	2026-09-21	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
88fc8b2e-2826-403f-b59f-5aa04bdfd3f6	62e81e6b-7247-4c3f-a8b8-db21e613d02a	2026-09-07	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b30f799e-e0b8-4ffa-aad1-7367471f37ec	9c4cf836-745e-4cf9-9a22-933d5e2638c3	2026-09-07	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c419ab2f-94ff-40fc-bc92-f6bb0dfa168b	9ec115c7-5377-4f9d-b46a-2a3c97bea4de	2026-08-31	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
572644a2-8969-47d2-8668-2040d87e6810	e93a25e9-5347-49e1-b901-88271fdbdcf5	2026-09-28	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
41189dd6-a33f-41eb-b1b1-63cce6686e78	26fd3209-693a-49d1-9224-8f7e2f3a1c58	2026-09-21	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7becd68a-d6ad-4ab2-a321-38585bba0861	31e49978-ac22-44bb-a535-11d20d8aeea3	2026-08-31	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
aada935b-6d51-45b9-b482-92aad4915f3e	d73eac4c-d537-4d31-8e35-b55f8aff3e87	2026-08-31	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fcf925b4-5462-4287-b7b9-6e531a697ac6	3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e9a261b2-a2ce-49ad-8324-7167a6aaa2ea	9312226e-c7f8-4187-887e-67e2124098cd	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8e4c0e42-5212-4511-8208-47ea0fb53c32	6b4e0847-6c40-471e-89ec-c5b63bb828f0	2026-09-28	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5cb7d536-a165-4157-acfe-3458485cea16	bfb55863-c987-497b-9a1b-9a7bc56a9509	2026-09-21	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e56f76de-2603-4576-92f7-a60a656ff476	d29c4919-9e2d-46c1-a78f-ffd2d4d32365	2026-08-31	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6fa30a81-4a64-4ca8-a465-9883df845f6a	eba0b052-26bb-4216-ab6e-dff23c63bc57	2026-09-14	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
07b1a694-3efd-4578-b83a-801778a41ab3	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	2026-08-31	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3a508f9c-fe12-4915-a505-3cb90ff62574	ca561f47-f73a-4401-8c6f-a1c776d88534	2026-09-21	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a9f7e848-d864-4379-8815-63001482e928	a73329ac-636f-475e-b566-321a5686fd66	2026-09-07	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
157a7fa4-c21b-41db-8c80-7948d60df2a7	eba0b052-26bb-4216-ab6e-dff23c63bc57	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
3552b34f-39c7-481e-acc7-1cae13e118a8	df8f375a-d0b0-40c0-8ada-264fc2275f4f	2026-09-21	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8199b999-ffa4-4310-9c40-9cbe5e3f87fb	f30d1ce8-8a1a-483d-ace2-419cd8672ecc	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
66223147-6e64-4365-bc27-da34c56f2951	78b71d74-d255-4ac0-a75f-ead11a61427a	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
183da1c6-12e0-4518-b11a-d3cb6dadcc06	7d2b2c7a-254e-4605-9f79-3f42ac7f9735	2026-09-14	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
fef2a0bf-0792-4f6a-84cd-1692331e8bba	7e3f1c8d-340c-47d7-b63d-fb047a9106aa	2026-09-07	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7711bc2e-06b3-4213-8101-e2b596948cc1	cc295432-e771-4d6f-9cc3-079cc5d9b576	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
680b1a4f-f30e-4d21-8589-5f8bb6b5e440	ffcdc44f-996b-4ef6-90e6-db858823a4c4	2026-09-28	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
02710e01-e36e-4de5-bb6c-4b82ba1827a4	1fa56f20-56ce-4461-ac66-c7d7b34f16d6	2026-09-21	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b1cfd1cd-12eb-45b5-84b8-ab62420766d5	159fb3d0-937c-4f81-ad37-aa1b4f023264	2026-09-21	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b37013b1-3320-49a0-9821-57bb4829569a	450f16b6-e35c-4564-969d-6bf6ceec7ff3	2026-09-14	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8367eab2-4d9d-460b-8d6c-900e8222b71c	02814af4-08b4-42cc-92e1-ad0bba687378	2026-09-07	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
0dd94a91-fd9b-4f2f-a9f9-59f3922621a0	74601727-6182-498f-ac57-4c02b9e56ca0	2026-08-31	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
65fca388-3246-4836-8beb-a80948e5625e	f90e007c-90d9-440e-8f0a-a85395e49abe	2026-08-31	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
14aec9c8-27e7-43be-9359-22893434f967	c5e35b7a-af12-4fd6-96af-e62225e715c6	2026-09-21	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
46378e14-1401-4106-bbd6-862e69a24372	849d2fb1-a4e4-4eb2-947b-f97057e4954b	2026-09-28	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ad1c6542-3842-41e3-9b42-0c4949ba04c2	8e139039-c490-436d-9af4-431d26334b34	2026-09-07	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
25a26696-278a-47ea-9a1f-e71a4f49c996	f01f614a-af85-4225-a3b4-3c463fb97bdf	2026-09-14	submitted	30.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b9e809fc-f72b-4525-a495-955b66b93866	ffcdc44f-996b-4ef6-90e6-db858823a4c4	2026-09-07	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ff1548de-da7f-4967-953f-b94a9c1a91f6	ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	2026-09-07	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bcc2a352-2b35-4715-8dec-4abe46710047	cc295432-e771-4d6f-9cc3-079cc5d9b576	2026-09-07	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b3ad631e-30bd-40e5-afde-830ea19aa5cb	3398777f-d384-48a2-8076-9c4fb06162bb	2026-08-31	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f3aaf5de-830e-4844-acc0-41251b71ee80	5ff0346b-75b8-4c62-afc7-afeb35b17a8e	2026-08-31	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7a116c6b-e0a9-4ab7-a393-dea196259615	d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	2026-09-07	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
8ce5fb5a-b906-432d-a445-c58489a043af	159fb3d0-937c-4f81-ad37-aa1b4f023264	2026-09-28	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
505b0ddc-6170-4daa-b308-14551188993d	e09daabd-8da2-4dc9-89b4-03f4b79583de	2026-09-21	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
4d05e2f2-e8f8-49bb-a936-60b37e425319	405610b0-c3bd-4725-a409-5f6dbffeacb4	2026-09-21	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f231598d-1b94-4f7e-986b-20e2ddfbd7f8	6d26e662-1e9f-4df8-a353-6be5ce9e5261	2026-09-21	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c2a03428-3d2d-42d6-9889-db4d1d0e5f32	d9fd54d6-b11b-4969-a25d-8b8e3fcca417	2026-09-07	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
ee827e8d-2989-43c8-944d-deee56487123	78b71d74-d255-4ac0-a75f-ead11a61427a	2026-09-07	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
95635597-98e7-4e05-bfe8-83b300d201e6	e93a25e9-5347-49e1-b901-88271fdbdcf5	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
718e5531-4bb8-416c-afeb-920ff640a5e0	d01c0ef5-731e-42de-b02a-7c996c545f15	2026-08-31	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
42d9ded2-63ad-4d63-8734-20935207d4b3	9eb64ade-203d-4e4a-aaed-8eaab7d3017d	2026-08-31	submitted	20.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
a5c29ead-95e2-42ba-ac86-c92f705b0286	5e82125c-9ff8-4a97-a11b-65da79677d3c	2026-09-21	submitted	8.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
91026fe5-860c-4e96-a95f-78e62d61f5a5	0a46bda6-6481-4bbe-8689-18fe959fa98a	2026-09-14	submitted	26.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9764a374-e546-46b5-a3e0-e14f82763dc6	405610b0-c3bd-4725-a409-5f6dbffeacb4	2026-09-07	submitted	28.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f65e9d64-a998-4b13-8595-2103140d78c2	dd200677-337b-440b-afcb-3a661406f98b	2026-09-14	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
21d6454f-6946-4c87-b92c-fc08e651b01b	6d26e662-1e9f-4df8-a353-6be5ce9e5261	2026-09-14	submitted	22.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
7fee5271-f320-4514-a4e9-36658d4fa7b8	74601727-6182-498f-ac57-4c02b9e56ca0	2026-09-14	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
10d2e400-7a41-4c5c-8aca-77ee4be2e5eb	238c3cb7-75cf-4478-a48e-fe47465d20b6	2026-09-14	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
cd4fa579-dd3b-466c-a534-07118221213b	804c8187-6f28-411f-8fa5-cc9baceba3e7	2026-09-21	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
2dedd94b-a613-4206-b614-a3f778543092	d94878fd-4650-46bc-b84c-753c841e7404	2026-08-31	submitted	24.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
23f6542a-0dcd-494c-b1d5-119d351b812d	804c8187-6f28-411f-8fa5-cc9baceba3e7	2026-09-28	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
df1676ae-890f-4323-9b50-52245b9507d6	204776c8-efeb-480f-980b-a3f70be97f91	2026-09-07	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e47037d4-9273-4b7f-a20f-36d6eee73a5b	78c932da-077a-4104-919c-386de88ed062	2026-08-31	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
c37bc237-38d3-486f-b6c5-fd47dd7e10fc	02814af4-08b4-42cc-92e1-ad0bba687378	2026-08-31	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
397990bf-418c-43d0-8db6-55b3f91ac10a	033446c7-c133-4395-bdaa-69b5f227a7a8	2026-09-07	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
9fc3454c-df0b-4266-9a82-c0d59d353bea	4d8e2104-d723-45a0-856f-594f80efd0f6	2026-09-28	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6188661d-7503-4be3-832c-8126c56e81e6	f39b20bb-8963-4917-aed5-0f1d86f0cbc3	2026-09-28	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
609397c2-5bef-4291-8185-b0fddb941eb7	6b1f9737-c1f7-4201-8cd2-9b5e6274ebc8	2026-09-14	submitted	18.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
60d76a25-f62b-4d18-92c0-8d6768fcc277	cef36bf2-c4fb-4040-b3ab-d033190ad3b4	2026-09-21	submitted	6.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b07409dc-d181-45fe-9ee3-9b1738684175	5bf6d5c7-4358-49f1-bb6b-9d0b1b38d4ad	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
6b98797a-d2f5-482f-99ab-425e3331b7b5	9d9bfa3a-8603-4de4-8eb7-76c3935e3014	2026-08-31	submitted	16.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
e243d6f4-1c39-4fab-a80c-f917b8574856	033446c7-c133-4395-bdaa-69b5f227a7a8	2026-09-21	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
d6971a47-b2ba-4124-b2b9-aa8cfbc1fcf7	51015348-f872-4e18-b806-e44017e10e4b	2026-08-31	submitted	4.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
1a4174d1-b732-4b2d-b7fc-535aff8831c0	df8f375a-d0b0-40c0-8ada-264fc2275f4f	2026-09-28	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
5c2489a4-207a-4d8d-bc06-417b68cdf635	f30d1ce8-8a1a-483d-ace2-419cd8672ecc	2026-08-31	submitted	10.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
bacd9372-1fb3-4881-9a16-d5c35b37c53a	31e49978-ac22-44bb-a535-11d20d8aeea3	2026-09-28	submitted	12.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
f84ff60b-768e-4144-ab70-0816ddd29830	31057f6b-b1e5-46e3-a071-b6639b93a15c	2026-08-31	submitted	14.0	2026-09-30 10:00:00+00	\N	\N	\N	2026-09-30 10:00:00+00	\N	\N	\N	\N
b7d53977-e4c9-4db6-aee4-e6167fb95e32	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-19	draft	0.0	\N	\N	\N	\N	2026-10-20 08:55:26.948643+00	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Name: log_role_permission_audits PK_log_role_permission_audits; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.log_role_permission_audits
    ADD CONSTRAINT "PK_log_role_permission_audits" PRIMARY KEY ("Id");


--
-- Name: tbl_refresh_tokens PK_tbl_refresh_tokens; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.tbl_refresh_tokens
    ADD CONSTRAINT "PK_tbl_refresh_tokens" PRIMARY KEY ("Id");


--
-- Name: tbl_roles PK_tbl_roles; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.tbl_roles
    ADD CONSTRAINT "PK_tbl_roles" PRIMARY KEY ("Id");


--
-- Name: tbl_users PK_tbl_users; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.tbl_users
    ADD CONSTRAINT "PK_tbl_users" PRIMARY KEY ("Id");


--
-- Name: tbl_role_permissions UQ_role_item_permissions; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.tbl_role_permissions
    ADD CONSTRAINT "UQ_role_item_permissions" UNIQUE ("RoleId", "ItemId");


--
-- Name: tbl_role_permissions tbl_role_permissions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.tbl_role_permissions
    ADD CONSTRAINT tbl_role_permissions_pkey PRIMARY KEY ("Id");


--
-- Name: tbl_client_assignments PK_tbl_client_assignments; Type: CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_client_assignments
    ADD CONSTRAINT "PK_tbl_client_assignments" PRIMARY KEY ("ClientId", "UserId");


--
-- Name: tbl_client_contacts PK_tbl_client_contacts; Type: CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_client_contacts
    ADD CONSTRAINT "PK_tbl_client_contacts" PRIMARY KEY ("Id");


--
-- Name: tbl_clients PK_tbl_clients; Type: CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_clients
    ADD CONSTRAINT "PK_tbl_clients" PRIMARY KEY ("Id");


--
-- Name: tbl_sub_ventures PK_tbl_sub_ventures; Type: CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_sub_ventures
    ADD CONSTRAINT "PK_tbl_sub_ventures" PRIMARY KEY ("Id");


--
-- Name: mst_address_cities PK_mst_address_cities; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_address_cities
    ADD CONSTRAINT "PK_mst_address_cities" PRIMARY KEY ("Id");


--
-- Name: mst_cities PK_mst_cities; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_cities
    ADD CONSTRAINT "PK_mst_cities" PRIMARY KEY ("Id");


--
-- Name: mst_contact_designations PK_mst_contact_designations; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_contact_designations
    ADD CONSTRAINT "PK_mst_contact_designations" PRIMARY KEY ("Id");


--
-- Name: mst_contact_types PK_mst_contact_types; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_contact_types
    ADD CONSTRAINT "PK_mst_contact_types" PRIMARY KEY ("Id");


--
-- Name: mst_countries PK_mst_countries; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_countries
    ADD CONSTRAINT "PK_mst_countries" PRIMARY KEY ("Id");


--
-- Name: mst_departments PK_mst_departments; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_departments
    ADD CONSTRAINT "PK_mst_departments" PRIMARY KEY ("Id");


--
-- Name: mst_designation_sub_departments PK_mst_designation_sub_departments; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_designation_sub_departments
    ADD CONSTRAINT "PK_mst_designation_sub_departments" PRIMARY KEY ("Id");


--
-- Name: mst_designations PK_mst_designations; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_designations
    ADD CONSTRAINT "PK_mst_designations" PRIMARY KEY ("Id");


--
-- Name: mst_industries PK_mst_industries; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_industries
    ADD CONSTRAINT "PK_mst_industries" PRIMARY KEY ("Id");


--
-- Name: mst_modules PK_mst_modules; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_modules
    ADD CONSTRAINT "PK_mst_modules" PRIMARY KEY ("Id");


--
-- Name: mst_nationalities PK_mst_nationalities; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_nationalities
    ADD CONSTRAINT "PK_mst_nationalities" PRIMARY KEY ("Id");


--
-- Name: mst_onfloorrole_sub_departments PK_mst_onfloorrole_sub_departments; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_onfloorrole_sub_departments
    ADD CONSTRAINT "PK_mst_onfloorrole_sub_departments" PRIMARY KEY ("Id");


--
-- Name: mst_org_role_map PK_mst_org_role_map; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_org_role_map
    ADD CONSTRAINT "PK_mst_org_role_map" PRIMARY KEY ("Id");


--
-- Name: mst_org_role_sub_departments PK_mst_org_role_sub_departments; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_org_role_sub_departments
    ADD CONSTRAINT "PK_mst_org_role_sub_departments" PRIMARY KEY ("Id");


--
-- Name: mst_salary_bands PK_mst_salary_bands; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_salary_bands
    ADD CONSTRAINT "PK_mst_salary_bands" PRIMARY KEY ("Id");


--
-- Name: mst_service_catalog PK_mst_service_catalog; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_service_catalog
    ADD CONSTRAINT "PK_mst_service_catalog" PRIMARY KEY ("Id");


--
-- Name: mst_service_departments PK_mst_service_departments; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_service_departments
    ADD CONSTRAINT "PK_mst_service_departments" PRIMARY KEY ("Id");


--
-- Name: mst_service_groups PK_mst_service_groups; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_service_groups
    ADD CONSTRAINT "PK_mst_service_groups" PRIMARY KEY ("Id");


--
-- Name: mst_service_sub_departments PK_mst_service_sub_departments; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_service_sub_departments
    ADD CONSTRAINT "PK_mst_service_sub_departments" PRIMARY KEY ("Id");


--
-- Name: mst_sub_departments PK_mst_sub_departments; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_sub_departments
    ADD CONSTRAINT "PK_mst_sub_departments" PRIMARY KEY ("Id");


--
-- Name: mst_submodules PK_mst_submodules; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_submodules
    ADD CONSTRAINT "PK_mst_submodules" PRIMARY KEY ("Id");


--
-- Name: mst_tabs PK_mst_tabs; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_tabs
    ADD CONSTRAINT "PK_mst_tabs" PRIMARY KEY ("Id");


--
-- Name: mst_widgets PK_mst_widgets; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_widgets
    ADD CONSTRAINT "PK_mst_widgets" PRIMARY KEY ("Id");


--
-- Name: mst_business_units mst_business_units_Code_key; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_business_units
    ADD CONSTRAINT "mst_business_units_Code_key" UNIQUE ("Code");


--
-- Name: mst_business_units mst_business_units_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_business_units
    ADD CONSTRAINT mst_business_units_pkey PRIMARY KEY ("Id");


--
-- Name: mst_certifications mst_certifications_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_certifications
    ADD CONSTRAINT mst_certifications_pkey PRIMARY KEY ("Id");


--
-- Name: mst_email_domains mst_email_domains_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_email_domains
    ADD CONSTRAINT mst_email_domains_pkey PRIMARY KEY ("Id");


--
-- Name: mst_employee_statuses mst_employee_statuses_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_employee_statuses
    ADD CONSTRAINT mst_employee_statuses_pkey PRIMARY KEY ("Id");


--
-- Name: mst_graduation_degrees mst_graduation_degrees_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_graduation_degrees
    ADD CONSTRAINT mst_graduation_degrees_pkey PRIMARY KEY ("Id");


--
-- Name: mst_offices mst_offices_Code_key; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_offices
    ADD CONSTRAINT "mst_offices_Code_key" UNIQUE ("Code");


--
-- Name: mst_offices mst_offices_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_offices
    ADD CONSTRAINT mst_offices_pkey PRIMARY KEY ("Id");


--
-- Name: mst_post_graduation_degrees mst_post_graduation_degrees_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_post_graduation_degrees
    ADD CONSTRAINT mst_post_graduation_degrees_pkey PRIMARY KEY ("Id");


--
-- Name: mst_rbac_baseline mst_rbac_baseline_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_rbac_baseline
    ADD CONSTRAINT mst_rbac_baseline_pkey PRIMARY KEY ("Version");


--
-- Name: mst_reporting_managers mst_reporting_managers_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_reporting_managers
    ADD CONSTRAINT mst_reporting_managers_pkey PRIMARY KEY ("Id");


--
-- Name: mst_work_locations mst_work_locations_Code_key; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_work_locations
    ADD CONSTRAINT "mst_work_locations_Code_key" UNIQUE ("Code");


--
-- Name: mst_work_locations mst_work_locations_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_work_locations
    ADD CONSTRAINT mst_work_locations_pkey PRIMARY KEY ("Id");


--
-- Name: log_project_task_assignments PK_log_project_task_assignments; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.log_project_task_assignments
    ADD CONSTRAINT "PK_log_project_task_assignments" PRIMARY KEY ("Id");


--
-- Name: tbl_project_documents PK_tbl_project_documents; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_documents
    ADD CONSTRAINT "PK_tbl_project_documents" PRIMARY KEY ("Id");


--
-- Name: tbl_project_drafts PK_tbl_project_drafts; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_drafts
    ADD CONSTRAINT "PK_tbl_project_drafts" PRIMARY KEY ("Id");


--
-- Name: tbl_project_extension_approvers PK_tbl_project_extension_approvers; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_extension_approvers
    ADD CONSTRAINT "PK_tbl_project_extension_approvers" PRIMARY KEY ("Id");


--
-- Name: tbl_project_extension_requests PK_tbl_project_extension_requests; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_extension_requests
    ADD CONSTRAINT "PK_tbl_project_extension_requests" PRIMARY KEY ("Id");


--
-- Name: tbl_project_interviews PK_tbl_project_interviews; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_interviews
    ADD CONSTRAINT "PK_tbl_project_interviews" PRIMARY KEY ("Id");


--
-- Name: tbl_project_invoices PK_tbl_project_invoices; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_invoices
    ADD CONSTRAINT "PK_tbl_project_invoices" PRIMARY KEY ("Id");


--
-- Name: tbl_project_service_escalation_stakeholders PK_tbl_project_service_escalation_stakeholders; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_service_escalation_stakeholders
    ADD CONSTRAINT "PK_tbl_project_service_escalation_stakeholders" PRIMARY KEY ("Id");


--
-- Name: tbl_project_service_escalations PK_tbl_project_service_escalations; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_service_escalations
    ADD CONSTRAINT "PK_tbl_project_service_escalations" PRIMARY KEY ("Id");


--
-- Name: tbl_project_services PK_tbl_project_services; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_services
    ADD CONSTRAINT "PK_tbl_project_services" PRIMARY KEY ("Id");


--
-- Name: tbl_project_task_assignments PK_tbl_project_task_assignments; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_task_assignments
    ADD CONSTRAINT "PK_tbl_project_task_assignments" PRIMARY KEY ("Id");


--
-- Name: tbl_project_tasks PK_tbl_project_tasks; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_tasks
    ADD CONSTRAINT "PK_tbl_project_tasks" PRIMARY KEY ("Id");


--
-- Name: tbl_project_team_members PK_tbl_project_team_members; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_team_members
    ADD CONSTRAINT "PK_tbl_project_team_members" PRIMARY KEY ("Id");


--
-- Name: tbl_projects PK_tbl_projects; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_projects
    ADD CONSTRAINT "PK_tbl_projects" PRIMARY KEY ("Id");


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: log_repository_activity PK_log_repository_activity; Type: CONSTRAINT; Schema: repository; Owner: -
--

ALTER TABLE ONLY repository.log_repository_activity
    ADD CONSTRAINT "PK_log_repository_activity" PRIMARY KEY ("Id");


--
-- Name: tbl_repository_departments PK_tbl_repository_departments; Type: CONSTRAINT; Schema: repository; Owner: -
--

ALTER TABLE ONLY repository.tbl_repository_departments
    ADD CONSTRAINT "PK_tbl_repository_departments" PRIMARY KEY ("RepositoryItemId", "DepartmentId");


--
-- Name: tbl_repository_items PK_tbl_repository_items; Type: CONSTRAINT; Schema: repository; Owner: -
--

ALTER TABLE ONLY repository.tbl_repository_items
    ADD CONSTRAINT "PK_tbl_repository_items" PRIMARY KEY ("Id");


--
-- Name: tbl_employees CK_employees_EmployeeCode_Format; Type: CHECK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE resource.tbl_employees
    ADD CONSTRAINT "CK_employees_EmployeeCode_Format" CHECK ((("EmployeeCode")::text ~ '^(TK|TKI)-[0-9]{4}$'::text)) NOT VALID;


--
-- Name: log_employee_activity PK_log_employee_activity; Type: CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.log_employee_activity
    ADD CONSTRAINT "PK_log_employee_activity" PRIMARY KEY ("Id");


--
-- Name: tbl_employees PK_tbl_employees; Type: CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_employees
    ADD CONSTRAINT "PK_tbl_employees" PRIMARY KEY ("Id");


--
-- Name: tbl_exited_employees PK_tbl_exited_employees; Type: CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_exited_employees
    ADD CONSTRAINT "PK_tbl_exited_employees" PRIMARY KEY ("Id");


--
-- Name: tbl_onfloorrole PK_tbl_onfloorrole; Type: CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_onfloorrole
    ADD CONSTRAINT "PK_tbl_onfloorrole" PRIMARY KEY ("Id");


--
-- Name: tbl_team_day_entries PK_tbl_team_day_entries; Type: CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_team_day_entries
    ADD CONSTRAINT "PK_tbl_team_day_entries" PRIMARY KEY ("Id");


--
-- Name: tbl_team_member_holidays PK_tbl_team_member_holidays; Type: CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_team_member_holidays
    ADD CONSTRAINT "PK_tbl_team_member_holidays" PRIMARY KEY ("Id");


--
-- Name: tbl_team_member_schedules PK_tbl_team_member_schedules; Type: CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_team_member_schedules
    ADD CONSTRAINT "PK_tbl_team_member_schedules" PRIMARY KEY ("Id");


--
-- Name: tbl_timesheet_entries PK_tbl_timesheet_entries; Type: CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_timesheet_entries
    ADD CONSTRAINT "PK_tbl_timesheet_entries" PRIMARY KEY ("Id");


--
-- Name: tbl_timesheet_entry_days PK_tbl_timesheet_entry_days; Type: CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_timesheet_entry_days
    ADD CONSTRAINT "PK_tbl_timesheet_entry_days" PRIMARY KEY ("Id");


--
-- Name: tbl_timesheets PK_tbl_timesheets; Type: CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_timesheets
    ADD CONSTRAINT "PK_tbl_timesheets" PRIMARY KEY ("Id");


--
-- Name: IX_log_role_permission_audits_CreatedAtUtc; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "IX_log_role_permission_audits_CreatedAtUtc" ON auth.log_role_permission_audits USING btree ("CreatedAtUtc");


--
-- Name: IX_log_role_permission_audits_RoleId; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "IX_log_role_permission_audits_RoleId" ON auth.log_role_permission_audits USING btree ("RoleId");


--
-- Name: IX_role_permissions_ItemId; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "IX_role_permissions_ItemId" ON auth.tbl_role_permissions USING btree ("ItemId");


--
-- Name: IX_role_permissions_RoleId; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "IX_role_permissions_RoleId" ON auth.tbl_role_permissions USING btree ("RoleId");


--
-- Name: IX_tbl_refresh_tokens_TokenHash; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_refresh_tokens_TokenHash" ON auth.tbl_refresh_tokens USING btree ("TokenHash");


--
-- Name: IX_tbl_refresh_tokens_UserId; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "IX_tbl_refresh_tokens_UserId" ON auth.tbl_refresh_tokens USING btree ("UserId");


--
-- Name: IX_tbl_roles_Name; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_roles_Name" ON auth.tbl_roles USING btree ("Name");


--
-- Name: IX_tbl_users_Email; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_users_Email" ON auth.tbl_users USING btree ("Email");


--
-- Name: IX_tbl_users_EmployeeId; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_users_EmployeeId" ON auth.tbl_users USING btree ("EmployeeId");


--
-- Name: IX_tbl_users_RoleId; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "IX_tbl_users_RoleId" ON auth.tbl_users USING btree ("RoleId");


--
-- Name: IX_users_MicrosoftOid; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "IX_users_MicrosoftOid" ON auth.tbl_users USING btree ("MicrosoftOid") WHERE ("MicrosoftOid" IS NOT NULL);


--
-- Name: IX_clients_ClientCode; Type: INDEX; Schema: customer; Owner: -
--

CREATE UNIQUE INDEX "IX_clients_ClientCode" ON customer.tbl_clients USING btree ("ClientCode") WHERE ("ClientCode" IS NOT NULL);


--
-- Name: IX_tbl_client_assignments_UserId; Type: INDEX; Schema: customer; Owner: -
--

CREATE INDEX "IX_tbl_client_assignments_UserId" ON customer.tbl_client_assignments USING btree ("UserId");


--
-- Name: IX_tbl_client_contacts_ClientId; Type: INDEX; Schema: customer; Owner: -
--

CREATE INDEX "IX_tbl_client_contacts_ClientId" ON customer.tbl_client_contacts USING btree ("ClientId");


--
-- Name: IX_tbl_client_contacts_SubVentureId; Type: INDEX; Schema: customer; Owner: -
--

CREATE INDEX "IX_tbl_client_contacts_SubVentureId" ON customer.tbl_client_contacts USING btree ("SubVentureId");


--
-- Name: IX_tbl_clients_CityId; Type: INDEX; Schema: customer; Owner: -
--

CREATE INDEX "IX_tbl_clients_CityId" ON customer.tbl_clients USING btree ("CityId");


--
-- Name: IX_tbl_clients_CountryId; Type: INDEX; Schema: customer; Owner: -
--

CREATE INDEX "IX_tbl_clients_CountryId" ON customer.tbl_clients USING btree ("CountryId");


--
-- Name: IX_tbl_clients_EngagementManagerId; Type: INDEX; Schema: customer; Owner: -
--

CREATE INDEX "IX_tbl_clients_EngagementManagerId" ON customer.tbl_clients USING btree ("EngagementManagerId");


--
-- Name: IX_tbl_clients_IndustryId; Type: INDEX; Schema: customer; Owner: -
--

CREATE INDEX "IX_tbl_clients_IndustryId" ON customer.tbl_clients USING btree ("IndustryId");


--
-- Name: IX_tbl_clients_Name; Type: INDEX; Schema: customer; Owner: -
--

CREATE INDEX "IX_tbl_clients_Name" ON customer.tbl_clients USING btree ("Name");


--
-- Name: IX_tbl_clients_SalesManagerId; Type: INDEX; Schema: customer; Owner: -
--

CREATE INDEX "IX_tbl_clients_SalesManagerId" ON customer.tbl_clients USING btree ("SalesManagerId");


--
-- Name: IX_tbl_sub_ventures_ClientId; Type: INDEX; Schema: customer; Owner: -
--

CREATE INDEX "IX_tbl_sub_ventures_ClientId" ON customer.tbl_sub_ventures USING btree ("ClientId");


--
-- Name: IX_tbl_sub_ventures_SubVentureCode; Type: INDEX; Schema: customer; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_sub_ventures_SubVentureCode" ON customer.tbl_sub_ventures USING btree ("SubVentureCode");


--
-- Name: IX_mst_address_cities_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_address_cities_Code" ON master.mst_address_cities USING btree ("Code");


--
-- Name: IX_mst_address_cities_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_address_cities_Name" ON master.mst_address_cities USING btree ("Name");


--
-- Name: IX_mst_business_units_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_business_units_Code" ON master.mst_business_units USING btree ("Code");


--
-- Name: IX_mst_cities_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_cities_Code" ON master.mst_cities USING btree ("Code");


--
-- Name: IX_mst_cities_CountryId_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_cities_CountryId_Name" ON master.mst_cities USING btree ("CountryId", "Name");


--
-- Name: IX_mst_contact_designations_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_contact_designations_Code" ON master.mst_contact_designations USING btree ("Code");


--
-- Name: IX_mst_contact_designations_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_contact_designations_Name" ON master.mst_contact_designations USING btree ("Name");


--
-- Name: IX_mst_contact_types_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_contact_types_Code" ON master.mst_contact_types USING btree ("Code");


--
-- Name: IX_mst_contact_types_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_contact_types_Name" ON master.mst_contact_types USING btree ("Name");


--
-- Name: IX_mst_countries_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_countries_Code" ON master.mst_countries USING btree ("Code");


--
-- Name: IX_mst_countries_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_countries_Name" ON master.mst_countries USING btree ("Name");


--
-- Name: IX_mst_departments_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_departments_Code" ON master.mst_departments USING btree ("Code");


--
-- Name: IX_mst_departments_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_departments_Name" ON master.mst_departments USING btree ("Name");


--
-- Name: IX_mst_designation_sub_departments_DesignationId_SubDepartment~; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_designation_sub_departments_DesignationId_SubDepartment~" ON master.mst_designation_sub_departments USING btree ("DesignationId", "SubDepartmentId");


--
-- Name: IX_mst_designation_sub_departments_SubDepartmentId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_designation_sub_departments_SubDepartmentId" ON master.mst_designation_sub_departments USING btree ("SubDepartmentId");


--
-- Name: IX_mst_designations_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_designations_Code" ON master.mst_designations USING btree ("Code");


--
-- Name: IX_mst_designations_DefaultRoleId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_designations_DefaultRoleId" ON master.mst_designations USING btree ("DefaultRoleId");


--
-- Name: IX_mst_designations_DepartmentId_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_designations_DepartmentId_Name" ON master.mst_designations USING btree ("DepartmentId", "Name");


--
-- Name: IX_mst_email_domains_DomainName; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_email_domains_DomainName" ON master.mst_email_domains USING btree ("DomainName");


--
-- Name: IX_mst_employee_statuses_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_employee_statuses_Code" ON master.mst_employee_statuses USING btree ("Code") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_mst_industries_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_industries_Code" ON master.mst_industries USING btree ("Code");


--
-- Name: IX_mst_industries_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_industries_Name" ON master.mst_industries USING btree ("Name");


--
-- Name: IX_mst_modules_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_modules_Code" ON master.mst_modules USING btree ("Code");


--
-- Name: IX_mst_nationalities_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_nationalities_Code" ON master.mst_nationalities USING btree ("Code");


--
-- Name: IX_mst_nationalities_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_nationalities_Name" ON master.mst_nationalities USING btree ("Name");


--
-- Name: IX_mst_offices_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_offices_Code" ON master.mst_offices USING btree ("Code");


--
-- Name: IX_mst_offices_WorkLocationId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_offices_WorkLocationId" ON master.mst_offices USING btree ("WorkLocationId");


--
-- Name: IX_mst_onfloorrole_sub_departments_OnFloorRoleId_SubDepartment~; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_onfloorrole_sub_departments_OnFloorRoleId_SubDepartment~" ON master.mst_onfloorrole_sub_departments USING btree ("OnFloorRoleId", "SubDepartmentId");


--
-- Name: IX_mst_onfloorrole_sub_departments_SubDepartmentId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_onfloorrole_sub_departments_SubDepartmentId" ON master.mst_onfloorrole_sub_departments USING btree ("SubDepartmentId");


--
-- Name: IX_mst_org_role_map_DepartmentId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_org_role_map_DepartmentId" ON master.mst_org_role_map USING btree ("DepartmentId");


--
-- Name: IX_mst_org_role_map_DesignationId; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_org_role_map_DesignationId" ON master.mst_org_role_map USING btree ("DesignationId");


--
-- Name: IX_mst_org_role_map_RbacRoleId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_org_role_map_RbacRoleId" ON master.mst_org_role_map USING btree ("RbacRoleId");


--
-- Name: IX_mst_org_role_map_SubDepartmentId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_org_role_map_SubDepartmentId" ON master.mst_org_role_map USING btree ("SubDepartmentId");


--
-- Name: IX_mst_org_role_sub_departments_OrgRoleMapId_SubDepartmentId; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_org_role_sub_departments_OrgRoleMapId_SubDepartmentId" ON master.mst_org_role_sub_departments USING btree ("OrgRoleMapId", "SubDepartmentId");


--
-- Name: IX_mst_org_role_sub_departments_SubDepartmentId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_org_role_sub_departments_SubDepartmentId" ON master.mst_org_role_sub_departments USING btree ("SubDepartmentId");


--
-- Name: IX_mst_reporting_managers_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_reporting_managers_Code" ON master.mst_reporting_managers USING btree ("Code");


--
-- Name: IX_mst_reporting_managers_EmployeeId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_reporting_managers_EmployeeId" ON master.mst_reporting_managers USING btree ("EmployeeId");


--
-- Name: IX_mst_salary_bands_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_salary_bands_Code" ON master.mst_salary_bands USING btree ("Code");


--
-- Name: IX_mst_salary_bands_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_salary_bands_Name" ON master.mst_salary_bands USING btree ("Name");


--
-- Name: IX_mst_service_catalog_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_catalog_Code" ON master.mst_service_catalog USING btree ("Code");


--
-- Name: IX_mst_service_catalog_SubDepartmentId_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_catalog_SubDepartmentId_Name" ON master.mst_service_catalog USING btree ("SubDepartmentId", "Name");


--
-- Name: IX_mst_service_departments_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_departments_Code" ON master.mst_service_departments USING btree ("Code");


--
-- Name: IX_mst_service_departments_GroupId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_service_departments_GroupId" ON master.mst_service_departments USING btree ("GroupId");


--
-- Name: IX_mst_service_departments_GroupId_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_departments_GroupId_Name" ON master.mst_service_departments USING btree ("GroupId", "Name");


--
-- Name: IX_mst_service_groups_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_groups_Code" ON master.mst_service_groups USING btree ("Code");


--
-- Name: IX_mst_service_groups_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_groups_Name" ON master.mst_service_groups USING btree ("Name");


--
-- Name: IX_mst_service_sub_departments_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_sub_departments_Code" ON master.mst_service_sub_departments USING btree ("Code");


--
-- Name: IX_mst_service_sub_departments_DepartmentId_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_sub_departments_DepartmentId_Name" ON master.mst_service_sub_departments USING btree ("DepartmentId", "Name");


--
-- Name: IX_mst_sub_departments_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_sub_departments_Code" ON master.mst_sub_departments USING btree ("Code");


--
-- Name: IX_mst_sub_departments_DepartmentId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_sub_departments_DepartmentId" ON master.mst_sub_departments USING btree ("DepartmentId");


--
-- Name: IX_mst_sub_departments_Name; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_sub_departments_Name" ON master.mst_sub_departments USING btree ("Name");


--
-- Name: IX_mst_submodules_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_submodules_Code" ON master.mst_submodules USING btree ("Code");


--
-- Name: IX_mst_submodules_ModuleId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_submodules_ModuleId" ON master.mst_submodules USING btree ("ModuleId");


--
-- Name: IX_mst_submodules_ParentId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_submodules_ParentId" ON master.mst_submodules USING btree ("ParentId");


--
-- Name: IX_mst_tabs_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_tabs_Code" ON master.mst_tabs USING btree ("Code");


--
-- Name: IX_mst_tabs_ModuleId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_tabs_ModuleId" ON master.mst_tabs USING btree ("ModuleId");


--
-- Name: IX_mst_tabs_SubModuleId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_tabs_SubModuleId" ON master.mst_tabs USING btree ("SubModuleId");


--
-- Name: IX_mst_tabs_TabId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_tabs_TabId" ON master.mst_tabs USING btree ("TabId");


--
-- Name: IX_mst_widgets_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_widgets_Code" ON master.mst_widgets USING btree ("Code");


--
-- Name: IX_mst_widgets_ParentId; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_widgets_ParentId" ON master.mst_widgets USING btree ("ParentId");


--
-- Name: IX_mst_work_locations_Code; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_work_locations_Code" ON master.mst_work_locations USING btree ("Code");


--
-- Name: IX_log_project_task_assignments_EmployeeId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_log_project_task_assignments_EmployeeId" ON project.log_project_task_assignments USING btree ("EmployeeId");


--
-- Name: IX_log_project_task_assignments_TaskId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_log_project_task_assignments_TaskId" ON project.log_project_task_assignments USING btree ("TaskId");


--
-- Name: IX_log_project_task_assignments_TaskId_OccurredAtUtc; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_log_project_task_assignments_TaskId_OccurredAtUtc" ON project.log_project_task_assignments USING btree ("TaskId", "OccurredAtUtc");


--
-- Name: IX_project_tasks_LeafIdentity; Type: INDEX; Schema: project; Owner: -
--

CREATE UNIQUE INDEX "IX_project_tasks_LeafIdentity" ON project.tbl_project_tasks USING btree ("ProjectId", "ProjectServiceId", "Period", "Phase", "Title") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_tbl_project_documents_DocumentType; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_documents_DocumentType" ON project.tbl_project_documents USING btree ("DocumentType");


--
-- Name: IX_tbl_project_documents_ProjectId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_documents_ProjectId" ON project.tbl_project_documents USING btree ("ProjectId");


--
-- Name: IX_tbl_project_drafts_ClientId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_drafts_ClientId" ON project.tbl_project_drafts USING btree ("ClientId");


--
-- Name: IX_tbl_project_drafts_Status; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_drafts_Status" ON project.tbl_project_drafts USING btree ("Status");


--
-- Name: IX_tbl_project_drafts_UpdatedAtUtc; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_drafts_UpdatedAtUtc" ON project.tbl_project_drafts USING btree ("UpdatedAtUtc");


--
-- Name: IX_tbl_project_extension_approvers_EmployeeId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_extension_approvers_EmployeeId" ON project.tbl_project_extension_approvers USING btree ("EmployeeId");


--
-- Name: IX_tbl_project_extension_approvers_ExtensionRequestId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_extension_approvers_ExtensionRequestId" ON project.tbl_project_extension_approvers USING btree ("ExtensionRequestId");


--
-- Name: IX_tbl_project_extension_requests_ProjectId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_extension_requests_ProjectId" ON project.tbl_project_extension_requests USING btree ("ProjectId");


--
-- Name: IX_tbl_project_interviews_EmployeeId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_interviews_EmployeeId" ON project.tbl_project_interviews USING btree ("EmployeeId");


--
-- Name: IX_tbl_project_interviews_ProjectId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_interviews_ProjectId" ON project.tbl_project_interviews USING btree ("ProjectId");


--
-- Name: IX_tbl_project_invoices_InvoiceNumber; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_invoices_InvoiceNumber" ON project.tbl_project_invoices USING btree ("InvoiceNumber");


--
-- Name: IX_tbl_project_invoices_ProjectId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_invoices_ProjectId" ON project.tbl_project_invoices USING btree ("ProjectId");


--
-- Name: IX_tbl_project_invoices_Status; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_invoices_Status" ON project.tbl_project_invoices USING btree ("Status");


--
-- Name: IX_tbl_project_service_escalations_ProjectId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_service_escalations_ProjectId" ON project.tbl_project_service_escalations USING btree ("ProjectId");


--
-- Name: IX_tbl_project_service_escalations_ProjectServiceId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_service_escalations_ProjectServiceId" ON project.tbl_project_service_escalations USING btree ("ProjectServiceId");


--
-- Name: IX_tbl_project_services_ProjectId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_services_ProjectId" ON project.tbl_project_services USING btree ("ProjectId");


--
-- Name: IX_tbl_project_services_ServiceCatalogId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_services_ServiceCatalogId" ON project.tbl_project_services USING btree ("ServiceCatalogId");


--
-- Name: IX_tbl_project_task_assignments_EmployeeId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_task_assignments_EmployeeId" ON project.tbl_project_task_assignments USING btree ("EmployeeId");


--
-- Name: IX_tbl_project_task_assignments_TaskId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_task_assignments_TaskId" ON project.tbl_project_task_assignments USING btree ("TaskId");


--
-- Name: IX_tbl_project_task_assignments_TaskId_EmployeeId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_task_assignments_TaskId_EmployeeId" ON project.tbl_project_task_assignments USING btree ("TaskId", "EmployeeId");


--
-- Name: IX_tbl_project_tasks_Priority; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_tasks_Priority" ON project.tbl_project_tasks USING btree ("Priority");


--
-- Name: IX_tbl_project_tasks_ProjectId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_tasks_ProjectId" ON project.tbl_project_tasks USING btree ("ProjectId");


--
-- Name: IX_tbl_project_tasks_ProjectServiceId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_tasks_ProjectServiceId" ON project.tbl_project_tasks USING btree ("ProjectServiceId");


--
-- Name: IX_tbl_project_tasks_Stage; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_tasks_Stage" ON project.tbl_project_tasks USING btree ("Stage");


--
-- Name: IX_tbl_project_team_members_DepartmentId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_team_members_DepartmentId" ON project.tbl_project_team_members USING btree ("DepartmentId");


--
-- Name: IX_tbl_project_team_members_EmployeeId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_team_members_EmployeeId" ON project.tbl_project_team_members USING btree ("EmployeeId");


--
-- Name: IX_tbl_project_team_members_ProjectId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_team_members_ProjectId" ON project.tbl_project_team_members USING btree ("ProjectId");


--
-- Name: IX_tbl_project_team_members_ProjectId_EmployeeId; Type: INDEX; Schema: project; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_project_team_members_ProjectId_EmployeeId" ON project.tbl_project_team_members USING btree ("ProjectId", "EmployeeId") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_tbl_projects_ClientId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_projects_ClientId" ON project.tbl_projects USING btree ("ClientId");


--
-- Name: IX_tbl_projects_EngagementManagerId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_projects_EngagementManagerId" ON project.tbl_projects USING btree ("EngagementManagerId");


--
-- Name: IX_tbl_projects_ProjectCode; Type: INDEX; Schema: project; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_projects_ProjectCode" ON project.tbl_projects USING btree ("ProjectCode");


--
-- Name: IX_tbl_projects_ProjectManagerId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_projects_ProjectManagerId" ON project.tbl_projects USING btree ("ProjectManagerId");


--
-- Name: IX_tbl_projects_RenewedFromProjectId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_projects_RenewedFromProjectId" ON project.tbl_projects USING btree ("RenewedFromProjectId");


--
-- Name: IX_tbl_projects_SalesPersonId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_projects_SalesPersonId" ON project.tbl_projects USING btree ("SalesPersonId");


--
-- Name: IX_tbl_projects_Status; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_projects_Status" ON project.tbl_projects USING btree ("Status");


--
-- Name: IX_tbl_projects_SubVentureId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_projects_SubVentureId" ON project.tbl_projects USING btree ("SubVentureId");


--
-- Name: IX_tbl_projects_TeamLeadId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_projects_TeamLeadId" ON project.tbl_projects USING btree ("TeamLeadId");


--
-- Name: IX_tbl_projects_WbsId; Type: INDEX; Schema: project; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_projects_WbsId" ON project.tbl_projects USING btree ("WbsId");


--
-- Name: IX_tbl_projects_WbsStatus; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_projects_WbsStatus" ON project.tbl_projects USING btree ("WbsStatus");


--
-- Name: IX_tbl_svc_escalation_stakeholders_EmployeeId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_svc_escalation_stakeholders_EmployeeId" ON project.tbl_project_service_escalation_stakeholders USING btree ("EmployeeId");


--
-- Name: IX_tbl_svc_escalation_stakeholders_EscalationId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_svc_escalation_stakeholders_EscalationId" ON project.tbl_project_service_escalation_stakeholders USING btree ("EscalationId");


--
-- Name: IX_log_repository_activity_CreatedAtUtc; Type: INDEX; Schema: repository; Owner: -
--

CREATE INDEX "IX_log_repository_activity_CreatedAtUtc" ON repository.log_repository_activity USING btree ("CreatedAtUtc");


--
-- Name: IX_log_repository_activity_DeletedAtUtc; Type: INDEX; Schema: repository; Owner: -
--

CREATE INDEX "IX_log_repository_activity_DeletedAtUtc" ON repository.log_repository_activity USING btree ("DeletedAtUtc");


--
-- Name: IX_tbl_repository_departments_DepartmentId; Type: INDEX; Schema: repository; Owner: -
--

CREATE INDEX "IX_tbl_repository_departments_DepartmentId" ON repository.tbl_repository_departments USING btree ("DepartmentId");


--
-- Name: IX_tbl_repository_items_Category; Type: INDEX; Schema: repository; Owner: -
--

CREATE INDEX "IX_tbl_repository_items_Category" ON repository.tbl_repository_items USING btree ("Category");


--
-- Name: IX_tbl_repository_items_DeletedAtUtc; Type: INDEX; Schema: repository; Owner: -
--

CREATE INDEX "IX_tbl_repository_items_DeletedAtUtc" ON repository.tbl_repository_items USING btree ("DeletedAtUtc");


--
-- Name: IX_log_employee_activity_CreatedAtUtc; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_log_employee_activity_CreatedAtUtc" ON resource.log_employee_activity USING btree ("CreatedAtUtc" DESC);


--
-- Name: IX_log_employee_activity_EmployeeId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_log_employee_activity_EmployeeId" ON resource.log_employee_activity USING btree ("EmployeeId");


--
-- Name: IX_tbl_employees_DepartmentId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_employees_DepartmentId" ON resource.tbl_employees USING btree ("DepartmentId");


--
-- Name: IX_tbl_employees_DesignationId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_employees_DesignationId" ON resource.tbl_employees USING btree ("DesignationId");


--
-- Name: IX_tbl_employees_EmployeeCode; Type: INDEX; Schema: resource; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_employees_EmployeeCode" ON resource.tbl_employees USING btree ("EmployeeCode");


--
-- Name: IX_tbl_employees_EmployeeStatusId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_employees_EmployeeStatusId" ON resource.tbl_employees USING btree ("EmployeeStatusId");


--
-- Name: IX_tbl_employees_EngagementManagerEmployeeId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_employees_EngagementManagerEmployeeId" ON resource.tbl_employees USING btree ("EngagementManagerEmployeeId");


--
-- Name: IX_tbl_employees_NationalityId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_employees_NationalityId" ON resource.tbl_employees USING btree ("NationalityId");


--
-- Name: IX_tbl_employees_ProjectManagerId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_employees_ProjectManagerId" ON resource.tbl_employees USING btree ("ProjectManagerId");


--
-- Name: IX_tbl_employees_ReportingManagerId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_employees_ReportingManagerId" ON resource.tbl_employees USING btree ("ReportingManagerId");


--
-- Name: IX_tbl_employees_SalaryBandId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_employees_SalaryBandId" ON resource.tbl_employees USING btree ("SalaryBandId");


--
-- Name: IX_tbl_employees_SubDepartmentId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_employees_SubDepartmentId" ON resource.tbl_employees USING btree ("SubDepartmentId");


--
-- Name: IX_tbl_employees_UserId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_employees_UserId" ON resource.tbl_employees USING btree ("UserId");


--
-- Name: IX_tbl_employees_WorkEmail; Type: INDEX; Schema: resource; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_employees_WorkEmail" ON resource.tbl_employees USING btree ("WorkEmail");


--
-- Name: IX_tbl_exited_employees_EmployeeCode; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_exited_employees_EmployeeCode" ON resource.tbl_exited_employees USING btree ("EmployeeCode");


--
-- Name: IX_tbl_exited_employees_OriginalEmployeeId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_exited_employees_OriginalEmployeeId" ON resource.tbl_exited_employees USING btree ("OriginalEmployeeId");


--
-- Name: IX_tbl_onfloorrole_DepartmentId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_onfloorrole_DepartmentId" ON resource.tbl_onfloorrole USING btree ("DepartmentId");


--
-- Name: IX_tbl_onfloorrole_DesignationId; Type: INDEX; Schema: resource; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_onfloorrole_DesignationId" ON resource.tbl_onfloorrole USING btree ("DesignationId");


--
-- Name: IX_tbl_onfloorrole_Name; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_onfloorrole_Name" ON resource.tbl_onfloorrole USING btree ("Name");


--
-- Name: IX_tbl_onfloorrole_RbacRoleId; Type: INDEX; Schema: resource; Owner: -
--

CREATE INDEX "IX_tbl_onfloorrole_RbacRoleId" ON resource.tbl_onfloorrole USING btree ("RbacRoleId");


--
-- Name: IX_tbl_team_day_entries_EmployeeId_WorkDate; Type: INDEX; Schema: timesheet; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_team_day_entries_EmployeeId_WorkDate" ON timesheet.tbl_team_day_entries USING btree ("EmployeeId", "WorkDate") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_tbl_team_member_holidays_EmployeeId_HolidayDate; Type: INDEX; Schema: timesheet; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_team_member_holidays_EmployeeId_HolidayDate" ON timesheet.tbl_team_member_holidays USING btree ("EmployeeId", "HolidayDate") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_tbl_team_member_schedules_EmployeeId; Type: INDEX; Schema: timesheet; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_team_member_schedules_EmployeeId" ON timesheet.tbl_team_member_schedules USING btree ("EmployeeId") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_tbl_timesheet_entries_TimesheetWeekId; Type: INDEX; Schema: timesheet; Owner: -
--

CREATE INDEX "IX_tbl_timesheet_entries_TimesheetWeekId" ON timesheet.tbl_timesheet_entries USING btree ("TimesheetWeekId");


--
-- Name: IX_tbl_timesheet_entry_days_TimesheetEntryId_DayIndex; Type: INDEX; Schema: timesheet; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_timesheet_entry_days_TimesheetEntryId_DayIndex" ON timesheet.tbl_timesheet_entry_days USING btree ("TimesheetEntryId", "DayIndex") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_tbl_timesheets_EmployeeId_WeekStart; Type: INDEX; Schema: timesheet; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_timesheets_EmployeeId_WeekStart" ON timesheet.tbl_timesheets USING btree ("EmployeeId", "WeekStart") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: log_role_permission_audits FK_log_role_permission_audits_tbl_roles_RoleId; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.log_role_permission_audits
    ADD CONSTRAINT "FK_log_role_permission_audits_tbl_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES auth.tbl_roles("Id") ON DELETE CASCADE;


--
-- Name: tbl_refresh_tokens FK_tbl_refresh_tokens_tbl_users_UserId; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.tbl_refresh_tokens
    ADD CONSTRAINT "FK_tbl_refresh_tokens_tbl_users_UserId" FOREIGN KEY ("UserId") REFERENCES auth.tbl_users("Id") ON DELETE CASCADE;


--
-- Name: tbl_users FK_tbl_users_tbl_roles_RoleId; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.tbl_users
    ADD CONSTRAINT "FK_tbl_users_tbl_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES auth.tbl_roles("Id") ON DELETE RESTRICT;


--
-- Name: tbl_role_permissions tbl_role_permissions_RoleId_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.tbl_role_permissions
    ADD CONSTRAINT "tbl_role_permissions_RoleId_fkey" FOREIGN KEY ("RoleId") REFERENCES auth.tbl_roles("Id") ON DELETE CASCADE;


--
-- Name: tbl_client_assignments FK_tbl_client_assignments_tbl_clients_ClientId; Type: FK CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_client_assignments
    ADD CONSTRAINT "FK_tbl_client_assignments_tbl_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES customer.tbl_clients("Id") ON DELETE CASCADE;


--
-- Name: tbl_client_assignments FK_tbl_client_assignments_tbl_users_UserId; Type: FK CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_client_assignments
    ADD CONSTRAINT "FK_tbl_client_assignments_tbl_users_UserId" FOREIGN KEY ("UserId") REFERENCES auth.tbl_users("Id") ON DELETE CASCADE;


--
-- Name: tbl_client_contacts FK_tbl_client_contacts_tbl_clients_ClientId; Type: FK CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_client_contacts
    ADD CONSTRAINT "FK_tbl_client_contacts_tbl_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES customer.tbl_clients("Id") ON DELETE CASCADE;


--
-- Name: tbl_client_contacts FK_tbl_client_contacts_tbl_sub_ventures_SubVentureId; Type: FK CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_client_contacts
    ADD CONSTRAINT "FK_tbl_client_contacts_tbl_sub_ventures_SubVentureId" FOREIGN KEY ("SubVentureId") REFERENCES customer.tbl_sub_ventures("Id") ON DELETE CASCADE;


--
-- Name: tbl_clients FK_tbl_clients_mst_cities_CityId; Type: FK CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_clients
    ADD CONSTRAINT "FK_tbl_clients_mst_cities_CityId" FOREIGN KEY ("CityId") REFERENCES master.mst_cities("Id") ON DELETE RESTRICT;


--
-- Name: tbl_clients FK_tbl_clients_mst_countries_CountryId; Type: FK CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_clients
    ADD CONSTRAINT "FK_tbl_clients_mst_countries_CountryId" FOREIGN KEY ("CountryId") REFERENCES master.mst_countries("Id") ON DELETE RESTRICT;


--
-- Name: tbl_clients FK_tbl_clients_mst_industries_IndustryId; Type: FK CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_clients
    ADD CONSTRAINT "FK_tbl_clients_mst_industries_IndustryId" FOREIGN KEY ("IndustryId") REFERENCES master.mst_industries("Id") ON DELETE RESTRICT;


--
-- Name: tbl_clients FK_tbl_clients_tbl_employees_EngagementManagerId; Type: FK CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_clients
    ADD CONSTRAINT "FK_tbl_clients_tbl_employees_EngagementManagerId" FOREIGN KEY ("EngagementManagerId") REFERENCES resource.tbl_employees("Id") ON DELETE SET NULL;


--
-- Name: tbl_clients FK_tbl_clients_tbl_employees_SalesManagerId; Type: FK CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_clients
    ADD CONSTRAINT "FK_tbl_clients_tbl_employees_SalesManagerId" FOREIGN KEY ("SalesManagerId") REFERENCES resource.tbl_employees("Id") ON DELETE SET NULL;


--
-- Name: tbl_sub_ventures FK_tbl_sub_ventures_tbl_clients_ClientId; Type: FK CONSTRAINT; Schema: customer; Owner: -
--

ALTER TABLE ONLY customer.tbl_sub_ventures
    ADD CONSTRAINT "FK_tbl_sub_ventures_tbl_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES customer.tbl_clients("Id") ON DELETE CASCADE;


--
-- Name: mst_cities FK_mst_cities_mst_countries_CountryId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_cities
    ADD CONSTRAINT "FK_mst_cities_mst_countries_CountryId" FOREIGN KEY ("CountryId") REFERENCES master.mst_countries("Id") ON DELETE RESTRICT;


--
-- Name: mst_designation_sub_departments FK_mst_designation_sub_departments_mst_designations_Designatio~; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_designation_sub_departments
    ADD CONSTRAINT "FK_mst_designation_sub_departments_mst_designations_Designatio~" FOREIGN KEY ("DesignationId") REFERENCES master.mst_designations("Id") ON DELETE CASCADE;


--
-- Name: mst_designation_sub_departments FK_mst_designation_sub_departments_mst_sub_departments_SubDepa~; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_designation_sub_departments
    ADD CONSTRAINT "FK_mst_designation_sub_departments_mst_sub_departments_SubDepa~" FOREIGN KEY ("SubDepartmentId") REFERENCES master.mst_sub_departments("Id") ON DELETE CASCADE;


--
-- Name: mst_designations FK_mst_designations_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_designations
    ADD CONSTRAINT "FK_mst_designations_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES master.mst_departments("Id") ON DELETE SET NULL;


--
-- Name: mst_designations FK_mst_designations_tbl_roles_DefaultRoleId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_designations
    ADD CONSTRAINT "FK_mst_designations_tbl_roles_DefaultRoleId" FOREIGN KEY ("DefaultRoleId") REFERENCES auth.tbl_roles("Id") ON DELETE SET NULL;


--
-- Name: mst_onfloorrole_sub_departments FK_mst_onfloorrole_sub_departments_mst_sub_departments_SubDepa~; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_onfloorrole_sub_departments
    ADD CONSTRAINT "FK_mst_onfloorrole_sub_departments_mst_sub_departments_SubDepa~" FOREIGN KEY ("SubDepartmentId") REFERENCES master.mst_sub_departments("Id") ON DELETE CASCADE;


--
-- Name: mst_onfloorrole_sub_departments FK_mst_onfloorrole_sub_departments_tbl_onfloorrole_OnFloorRole~; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_onfloorrole_sub_departments
    ADD CONSTRAINT "FK_mst_onfloorrole_sub_departments_tbl_onfloorrole_OnFloorRole~" FOREIGN KEY ("OnFloorRoleId") REFERENCES resource.tbl_onfloorrole("Id") ON DELETE CASCADE;


--
-- Name: mst_org_role_map FK_mst_org_role_map_DepartmentId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_org_role_map
    ADD CONSTRAINT "FK_mst_org_role_map_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES master.mst_departments("Id") ON DELETE SET NULL;


--
-- Name: mst_org_role_map FK_mst_org_role_map_DesignationId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_org_role_map
    ADD CONSTRAINT "FK_mst_org_role_map_DesignationId" FOREIGN KEY ("DesignationId") REFERENCES master.mst_designations("Id") ON DELETE CASCADE;


--
-- Name: mst_org_role_map FK_mst_org_role_map_RbacRoleId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_org_role_map
    ADD CONSTRAINT "FK_mst_org_role_map_RbacRoleId" FOREIGN KEY ("RbacRoleId") REFERENCES auth.tbl_roles("Id") ON DELETE SET NULL;


--
-- Name: mst_org_role_map FK_mst_org_role_map_mst_sub_departments_SubDepartmentId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_org_role_map
    ADD CONSTRAINT "FK_mst_org_role_map_mst_sub_departments_SubDepartmentId" FOREIGN KEY ("SubDepartmentId") REFERENCES master.mst_sub_departments("Id") ON DELETE SET NULL;


--
-- Name: mst_org_role_sub_departments FK_mst_org_role_sub_departments_mst_org_role_map_OrgRoleMapId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_org_role_sub_departments
    ADD CONSTRAINT "FK_mst_org_role_sub_departments_mst_org_role_map_OrgRoleMapId" FOREIGN KEY ("OrgRoleMapId") REFERENCES master.mst_org_role_map("Id") ON DELETE CASCADE;


--
-- Name: mst_org_role_sub_departments FK_mst_org_role_sub_departments_mst_sub_departments_SubDepartm~; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_org_role_sub_departments
    ADD CONSTRAINT "FK_mst_org_role_sub_departments_mst_sub_departments_SubDepartm~" FOREIGN KEY ("SubDepartmentId") REFERENCES master.mst_sub_departments("Id") ON DELETE CASCADE;


--
-- Name: mst_reporting_managers FK_mst_reporting_managers_tbl_employees_EmployeeId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_reporting_managers
    ADD CONSTRAINT "FK_mst_reporting_managers_tbl_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE SET NULL;


--
-- Name: mst_service_catalog FK_mst_service_catalog_mst_service_sub_departments_SubDepartmen; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_service_catalog
    ADD CONSTRAINT "FK_mst_service_catalog_mst_service_sub_departments_SubDepartmen" FOREIGN KEY ("SubDepartmentId") REFERENCES master.mst_service_sub_departments("Id") ON DELETE CASCADE;


--
-- Name: mst_service_departments FK_mst_service_departments_mst_service_groups_GroupId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_service_departments
    ADD CONSTRAINT "FK_mst_service_departments_mst_service_groups_GroupId" FOREIGN KEY ("GroupId") REFERENCES master.mst_service_groups("Id") ON DELETE RESTRICT;


--
-- Name: mst_service_sub_departments FK_mst_service_sub_departments_mst_service_departments_Departme; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_service_sub_departments
    ADD CONSTRAINT "FK_mst_service_sub_departments_mst_service_departments_Departme" FOREIGN KEY ("DepartmentId") REFERENCES master.mst_service_departments("Id") ON DELETE CASCADE;


--
-- Name: mst_sub_departments FK_mst_sub_departments_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_sub_departments
    ADD CONSTRAINT "FK_mst_sub_departments_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES master.mst_departments("Id") ON DELETE SET NULL;


--
-- Name: mst_submodules FK_mst_submodules_mst_modules_ModuleId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_submodules
    ADD CONSTRAINT "FK_mst_submodules_mst_modules_ModuleId" FOREIGN KEY ("ModuleId") REFERENCES master.mst_modules("Id") ON DELETE RESTRICT;


--
-- Name: mst_submodules FK_mst_submodules_mst_submodules_ParentId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_submodules
    ADD CONSTRAINT "FK_mst_submodules_mst_submodules_ParentId" FOREIGN KEY ("ParentId") REFERENCES master.mst_submodules("Id") ON DELETE RESTRICT;


--
-- Name: mst_tabs FK_mst_tabs_mst_modules_ModuleId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_tabs
    ADD CONSTRAINT "FK_mst_tabs_mst_modules_ModuleId" FOREIGN KEY ("ModuleId") REFERENCES master.mst_modules("Id") ON DELETE RESTRICT;


--
-- Name: mst_tabs FK_mst_tabs_mst_submodules_SubModuleId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_tabs
    ADD CONSTRAINT "FK_mst_tabs_mst_submodules_SubModuleId" FOREIGN KEY ("SubModuleId") REFERENCES master.mst_submodules("Id") ON DELETE RESTRICT;


--
-- Name: mst_tabs FK_mst_tabs_mst_tabs_TabId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_tabs
    ADD CONSTRAINT "FK_mst_tabs_mst_tabs_TabId" FOREIGN KEY ("TabId") REFERENCES master.mst_tabs("Id") ON DELETE RESTRICT;


--
-- Name: mst_widgets FK_mst_widgets_mst_modules_ParentId; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_widgets
    ADD CONSTRAINT "FK_mst_widgets_mst_modules_ParentId" FOREIGN KEY ("ParentId") REFERENCES master.mst_modules("Id") ON DELETE RESTRICT;


--
-- Name: mst_offices mst_offices_WorkLocationId_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_offices
    ADD CONSTRAINT "mst_offices_WorkLocationId_fkey" FOREIGN KEY ("WorkLocationId") REFERENCES master.mst_work_locations("Id") ON DELETE CASCADE;


--
-- Name: log_project_task_assignments FK_log_project_task_assignments_tbl_employees_EmployeeId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.log_project_task_assignments
    ADD CONSTRAINT "FK_log_project_task_assignments_tbl_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE RESTRICT;


--
-- Name: log_project_task_assignments FK_log_project_task_assignments_tbl_project_tasks_TaskId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.log_project_task_assignments
    ADD CONSTRAINT "FK_log_project_task_assignments_tbl_project_tasks_TaskId" FOREIGN KEY ("TaskId") REFERENCES project.tbl_project_tasks("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_documents FK_tbl_project_documents_tbl_projects_ProjectId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_documents
    ADD CONSTRAINT "FK_tbl_project_documents_tbl_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_extension_approvers FK_tbl_project_extension_approvers_tbl_project_extension_reques; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_extension_approvers
    ADD CONSTRAINT "FK_tbl_project_extension_approvers_tbl_project_extension_reques" FOREIGN KEY ("ExtensionRequestId") REFERENCES project.tbl_project_extension_requests("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_extension_requests FK_tbl_project_extension_requests_tbl_projects_ProjectId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_extension_requests
    ADD CONSTRAINT "FK_tbl_project_extension_requests_tbl_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_interviews FK_tbl_project_interviews_tbl_projects_ProjectId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_interviews
    ADD CONSTRAINT "FK_tbl_project_interviews_tbl_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_invoices FK_tbl_project_invoices_tbl_projects_ProjectId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_invoices
    ADD CONSTRAINT "FK_tbl_project_invoices_tbl_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_service_escalations FK_tbl_project_service_escalations_projects; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_service_escalations
    ADD CONSTRAINT "FK_tbl_project_service_escalations_projects" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_services FK_tbl_project_services_mst_service_catalog_ServiceCatalogId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_services
    ADD CONSTRAINT "FK_tbl_project_services_mst_service_catalog_ServiceCatalogId" FOREIGN KEY ("ServiceCatalogId") REFERENCES master.mst_service_catalog("Id") ON DELETE SET NULL;


--
-- Name: tbl_project_services FK_tbl_project_services_tbl_projects_ProjectId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_services
    ADD CONSTRAINT "FK_tbl_project_services_tbl_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_task_assignments FK_tbl_project_task_assignments_tbl_employees_EmployeeId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_task_assignments
    ADD CONSTRAINT "FK_tbl_project_task_assignments_tbl_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE RESTRICT;


--
-- Name: tbl_project_task_assignments FK_tbl_project_task_assignments_tbl_project_tasks_TaskId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_task_assignments
    ADD CONSTRAINT "FK_tbl_project_task_assignments_tbl_project_tasks_TaskId" FOREIGN KEY ("TaskId") REFERENCES project.tbl_project_tasks("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_tasks FK_tbl_project_tasks_tbl_project_services_ProjectServiceId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_tasks
    ADD CONSTRAINT "FK_tbl_project_tasks_tbl_project_services_ProjectServiceId" FOREIGN KEY ("ProjectServiceId") REFERENCES project.tbl_project_services("Id") ON DELETE SET NULL;


--
-- Name: tbl_project_tasks FK_tbl_project_tasks_tbl_projects_ProjectId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_tasks
    ADD CONSTRAINT "FK_tbl_project_tasks_tbl_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_team_members FK_tbl_project_team_members_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_team_members
    ADD CONSTRAINT "FK_tbl_project_team_members_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES master.mst_departments("Id") ON DELETE SET NULL;


--
-- Name: tbl_project_team_members FK_tbl_project_team_members_tbl_employees_EmployeeId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_team_members
    ADD CONSTRAINT "FK_tbl_project_team_members_tbl_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE RESTRICT;


--
-- Name: tbl_project_team_members FK_tbl_project_team_members_tbl_projects_ProjectId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_team_members
    ADD CONSTRAINT "FK_tbl_project_team_members_tbl_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_projects FK_tbl_projects_tbl_clients_ClientId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_projects
    ADD CONSTRAINT "FK_tbl_projects_tbl_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES customer.tbl_clients("Id") ON DELETE RESTRICT;


--
-- Name: tbl_projects FK_tbl_projects_tbl_employees_EngagementManagerId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_projects
    ADD CONSTRAINT "FK_tbl_projects_tbl_employees_EngagementManagerId" FOREIGN KEY ("EngagementManagerId") REFERENCES resource.tbl_employees("Id") ON DELETE SET NULL;


--
-- Name: tbl_projects FK_tbl_projects_tbl_employees_ProjectManagerId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_projects
    ADD CONSTRAINT "FK_tbl_projects_tbl_employees_ProjectManagerId" FOREIGN KEY ("ProjectManagerId") REFERENCES resource.tbl_employees("Id") ON DELETE SET NULL;


--
-- Name: tbl_projects FK_tbl_projects_tbl_employees_SalesPersonId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_projects
    ADD CONSTRAINT "FK_tbl_projects_tbl_employees_SalesPersonId" FOREIGN KEY ("SalesPersonId") REFERENCES resource.tbl_employees("Id") ON DELETE SET NULL;


--
-- Name: tbl_projects FK_tbl_projects_tbl_employees_TeamLeadId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_projects
    ADD CONSTRAINT "FK_tbl_projects_tbl_employees_TeamLeadId" FOREIGN KEY ("TeamLeadId") REFERENCES resource.tbl_employees("Id") ON DELETE SET NULL;


--
-- Name: tbl_projects FK_tbl_projects_tbl_projects_RenewedFromProjectId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_projects
    ADD CONSTRAINT "FK_tbl_projects_tbl_projects_RenewedFromProjectId" FOREIGN KEY ("RenewedFromProjectId") REFERENCES project.tbl_projects("Id") ON DELETE SET NULL;


--
-- Name: tbl_projects FK_tbl_projects_tbl_sub_ventures_SubVentureId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_projects
    ADD CONSTRAINT "FK_tbl_projects_tbl_sub_ventures_SubVentureId" FOREIGN KEY ("SubVentureId") REFERENCES customer.tbl_sub_ventures("Id") ON DELETE SET NULL;


--
-- Name: tbl_project_service_escalation_stakeholders FK_tbl_svc_escalation_stakeholders_escalation; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_service_escalation_stakeholders
    ADD CONSTRAINT "FK_tbl_svc_escalation_stakeholders_escalation" FOREIGN KEY ("EscalationId") REFERENCES project.tbl_project_service_escalations("Id") ON DELETE CASCADE;


--
-- Name: tbl_repository_departments FK_tbl_repository_departments_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: repository; Owner: -
--

ALTER TABLE ONLY repository.tbl_repository_departments
    ADD CONSTRAINT "FK_tbl_repository_departments_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES master.mst_departments("Id") ON DELETE CASCADE;


--
-- Name: tbl_repository_departments FK_tbl_repository_departments_tbl_repository_items_RepositoryI~; Type: FK CONSTRAINT; Schema: repository; Owner: -
--

ALTER TABLE ONLY repository.tbl_repository_departments
    ADD CONSTRAINT "FK_tbl_repository_departments_tbl_repository_items_RepositoryI~" FOREIGN KEY ("RepositoryItemId") REFERENCES repository.tbl_repository_items("Id") ON DELETE CASCADE;


--
-- Name: log_employee_activity FK_log_employee_activity_tbl_employees_EmployeeId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.log_employee_activity
    ADD CONSTRAINT "FK_log_employee_activity_tbl_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE CASCADE;


--
-- Name: tbl_employees FK_tbl_employees_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_employees
    ADD CONSTRAINT "FK_tbl_employees_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES master.mst_departments("Id") ON DELETE SET NULL;


--
-- Name: tbl_employees FK_tbl_employees_mst_designations_DesignationId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_employees
    ADD CONSTRAINT "FK_tbl_employees_mst_designations_DesignationId" FOREIGN KEY ("DesignationId") REFERENCES master.mst_designations("Id") ON DELETE SET NULL;


--
-- Name: tbl_employees FK_tbl_employees_mst_employee_statuses_EmployeeStatusId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_employees
    ADD CONSTRAINT "FK_tbl_employees_mst_employee_statuses_EmployeeStatusId" FOREIGN KEY ("EmployeeStatusId") REFERENCES master.mst_employee_statuses("Id") ON DELETE SET NULL;


--
-- Name: tbl_employees FK_tbl_employees_mst_nationalities_NationalityId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_employees
    ADD CONSTRAINT "FK_tbl_employees_mst_nationalities_NationalityId" FOREIGN KEY ("NationalityId") REFERENCES master.mst_nationalities("Id") ON DELETE RESTRICT;


--
-- Name: tbl_employees FK_tbl_employees_mst_salary_bands_SalaryBandId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_employees
    ADD CONSTRAINT "FK_tbl_employees_mst_salary_bands_SalaryBandId" FOREIGN KEY ("SalaryBandId") REFERENCES master.mst_salary_bands("Id") ON DELETE RESTRICT;


--
-- Name: tbl_employees FK_tbl_employees_mst_sub_departments_SubDepartmentId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_employees
    ADD CONSTRAINT "FK_tbl_employees_mst_sub_departments_SubDepartmentId" FOREIGN KEY ("SubDepartmentId") REFERENCES master.mst_sub_departments("Id") ON DELETE SET NULL;


--
-- Name: tbl_employees FK_tbl_employees_tbl_employees_EngagementManagerEmployeeId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_employees
    ADD CONSTRAINT "FK_tbl_employees_tbl_employees_EngagementManagerEmployeeId" FOREIGN KEY ("EngagementManagerEmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE RESTRICT;


--
-- Name: tbl_employees FK_tbl_employees_tbl_employees_ProjectManagerId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_employees
    ADD CONSTRAINT "FK_tbl_employees_tbl_employees_ProjectManagerId" FOREIGN KEY ("ProjectManagerId") REFERENCES resource.tbl_employees("Id") ON DELETE RESTRICT;


--
-- Name: tbl_employees FK_tbl_employees_tbl_employees_ReportingManagerId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_employees
    ADD CONSTRAINT "FK_tbl_employees_tbl_employees_ReportingManagerId" FOREIGN KEY ("ReportingManagerId") REFERENCES resource.tbl_employees("Id") ON DELETE SET NULL;


--
-- Name: tbl_employees FK_tbl_employees_tbl_users_UserId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_employees
    ADD CONSTRAINT "FK_tbl_employees_tbl_users_UserId" FOREIGN KEY ("UserId") REFERENCES auth.tbl_users("Id") ON DELETE SET NULL;


--
-- Name: tbl_onfloorrole FK_tbl_onfloorrole_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_onfloorrole
    ADD CONSTRAINT "FK_tbl_onfloorrole_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES master.mst_departments("Id") ON DELETE SET NULL;


--
-- Name: tbl_onfloorrole FK_tbl_onfloorrole_mst_designations_DesignationId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_onfloorrole
    ADD CONSTRAINT "FK_tbl_onfloorrole_mst_designations_DesignationId" FOREIGN KEY ("DesignationId") REFERENCES master.mst_designations("Id") ON DELETE CASCADE;


--
-- Name: tbl_onfloorrole FK_tbl_onfloorrole_tbl_roles_RbacRoleId; Type: FK CONSTRAINT; Schema: resource; Owner: -
--

ALTER TABLE ONLY resource.tbl_onfloorrole
    ADD CONSTRAINT "FK_tbl_onfloorrole_tbl_roles_RbacRoleId" FOREIGN KEY ("RbacRoleId") REFERENCES auth.tbl_roles("Id") ON DELETE SET NULL;


--
-- Name: tbl_team_day_entries FK_tbl_team_day_entries_tbl_employees_EmployeeId; Type: FK CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_team_day_entries
    ADD CONSTRAINT "FK_tbl_team_day_entries_tbl_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE RESTRICT;


--
-- Name: tbl_team_member_holidays FK_tbl_team_member_holidays_tbl_employees_EmployeeId; Type: FK CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_team_member_holidays
    ADD CONSTRAINT "FK_tbl_team_member_holidays_tbl_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE RESTRICT;


--
-- Name: tbl_team_member_schedules FK_tbl_team_member_schedules_tbl_employees_EmployeeId; Type: FK CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_team_member_schedules
    ADD CONSTRAINT "FK_tbl_team_member_schedules_tbl_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE RESTRICT;


--
-- Name: tbl_timesheet_entries FK_tbl_timesheet_entries_tbl_timesheets_TimesheetWeekId; Type: FK CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_timesheet_entries
    ADD CONSTRAINT "FK_tbl_timesheet_entries_tbl_timesheets_TimesheetWeekId" FOREIGN KEY ("TimesheetWeekId") REFERENCES timesheet.tbl_timesheets("Id") ON DELETE RESTRICT;


--
-- Name: tbl_timesheet_entry_days FK_tbl_timesheet_entry_days_tbl_timesheet_entries_TimesheetEnt~; Type: FK CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_timesheet_entry_days
    ADD CONSTRAINT "FK_tbl_timesheet_entry_days_tbl_timesheet_entries_TimesheetEnt~" FOREIGN KEY ("TimesheetEntryId") REFERENCES timesheet.tbl_timesheet_entries("Id") ON DELETE RESTRICT;


--
-- Name: tbl_timesheets FK_tbl_timesheets_tbl_employees_EmployeeId; Type: FK CONSTRAINT; Schema: timesheet; Owner: -
--

ALTER TABLE ONLY timesheet.tbl_timesheets
    ADD CONSTRAINT "FK_tbl_timesheets_tbl_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict wDw0bsBnYqClqUpxHNmeia1hRq0ZVL4VZS39sCWudtrgpDDsweopECLjqyTh9YU

