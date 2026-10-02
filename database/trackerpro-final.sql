--
-- PostgreSQL database dump
--

\restrict tC98VJTuXWom4ykfH2bVBjJjDrxGKjSh7RVSMSlhsWmhCMBQHw9kOSCdbOjnvmH

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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


--
-- Name: client_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_assignments (
    "ClientId" uuid NOT NULL,
    "UserId" uuid NOT NULL
);


--
-- Name: client_contacts; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: employee_activity_logs; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: employees; Type: TABLE; Schema: public; Owner: -
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
    "ProjectSite" character varying(80),
    "EngagementManagerEmployeeId" uuid,
    "ProjectManagerId" uuid
);


--
-- Name: exited_employees; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_business_units; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_certifications; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_cities; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_contact_designations; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_contact_types; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_countries; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_departments; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_designations; Type: TABLE; Schema: public; Owner: -
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
    "SubDepartment" text,
    "DefaultRoleId" uuid
);


--
-- Name: mst_email_domains; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_employee_statuses; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_entra_roles; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_graduation_degrees; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_industries; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_nationalities; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_offices; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_post_graduation_degrees; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_reporting_managers; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_roles; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_salary_bands; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: mst_service_catalog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mst_service_catalog (
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
-- Name: mst_service_departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mst_service_departments (
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
-- Name: mst_service_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mst_service_groups (
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
-- Name: mst_service_sub_departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mst_service_sub_departments (
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
-- Name: mst_work_locations; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: project_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_documents (
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
-- Name: project_drafts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_drafts (
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
-- Name: project_invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_invoices (
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
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: project_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_services (
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
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: project_task_assignment_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_task_assignment_history (
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
-- Name: project_task_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_task_assignments (
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
-- Name: project_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_tasks (
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
-- Name: project_team_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_team_members (
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
    "IsShadowTeam" boolean DEFAULT false NOT NULL
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
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
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: repository; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: repository_activity_logs; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: repository_departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repository_departments (
    "RepositoryItemId" uuid NOT NULL,
    "DepartmentId" uuid NOT NULL
);


--
-- Name: role_permission_audits; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: sub_ventures; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: team_day_entries; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: team_member_holidays; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: team_member_schedules; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: timesheet_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timesheet_entries (
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
-- Name: timesheet_entry_days; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timesheet_entry_days (
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
-- Name: timesheets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timesheets (
    "Id" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "WeekStart" date NOT NULL,
    "Status" character varying(32) NOT NULL,
    "TotalHours" numeric(6,1) NOT NULL,
    "SubmittedAtUtc" timestamp with time zone,
    "ReviewedByEmployeeId" uuid,
    "ReviewedAtUtc" timestamp with time zone,
    "ReviewComment" character varying(2000),
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
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
20260927183000_AddTimesheets	10.0.4
20260927191151_AddProjectTaskAssignmentHistory	10.0.4
20260928051557_DropProjectServiceResourceLevels	10.0.4
\.


--
-- Data for Name: client_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_assignments ("ClientId", "UserId") FROM stdin;
06cb7699-93b0-047f-0c59-b7f1baa24ec8	1a077a8c-4029-8ded-d563-19e9b4bdf301
9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	1a077a8c-4029-8ded-d563-19e9b4bdf301
a70cd580-74be-fff2-31b3-dcc06cc11f06	e7554ba2-e546-93ce-1e88-a073badd78a2
f61741ca-2c63-917f-ee7f-ae00cdbc08cb	e7554ba2-e546-93ce-1e88-a073badd78a2
\.


--
-- Data for Name: client_contacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_contacts ("Id", "ClientId", "SubVentureId", "Name", "Email", "Phone", "Designation", "ContactType", "IsPrimary", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Country", "PhoneCode") FROM stdin;
d5572af5-adde-4fd9-b14b-c857467d1c93	\N	37f0c3b1-16a1-4643-9f5a-f824204543c1	Sahil Lad	sahillad77@gmail.com	7854125698	ciso	Procurement	f	2026-08-19 12:13:26.584779+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
26358579-8daf-4027-81c9-c375e8628aa3	\N	6a40584b-3bde-4c7d-a6e6-3ef920cd43d0	Sahil 	sahillad2092003@gmail.com	8744541212	spoc	Technical	f	2026-08-20 16:30:13.771971+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
77e4a9a2-d473-4007-be16-f9eebfb39df8	90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	\N	Sahil	sahillad2092003@gmail.com	8744541212	spoc	Technical	f	2026-08-20 16:30:13.771971+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
03f15020-3812-47c9-97a4-3ed02203ca0a	\N	65c6925a-8948-4485-9d93-e596e1f4273e	karan pawar	karan.pawar@gmail.com	5374903789	ciso	Technical	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
251274f1-0037-4f3c-8d67-44d1e46981fa	\N	65c6925a-8948-4485-9d93-e596e1f4273e	roshan jadhav	roshan.jadhav@gmail.com	7389247892	spoc	Accounts	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
3865019e-696f-4b90-9347-8cd7ef76d999	\N	d3af0a54-b527-40ca-ac1e-9fb09fd81504	harshada	harshada@tk.com	4373947849	ciso	Technical	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
e6e01a67-c99e-4ed7-87a0-92e5a498d8ab	\N	d3af0a54-b527-40ca-ac1e-9fb09fd81504	muskan	muskan@tk.com	4356789038	spoc	Procurement	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
86650066-2b7a-4e3e-881f-d34464ffbfe4	89714d99-8107-4cd0-8095-6da7823cb767	\N	Harshada Tawde	harshada.tawde@gmail.com	7977953150	spoc	Accounts	f	2026-09-02 12:39:24.021663+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
ab3333bb-387c-4753-b5a7-8482870ac7b4	\N	4af18ff4-3a01-44e4-b050-9e209643182b	Harshada Tawde	harshada.tawde@gmail.com	7977953150	spoc	Accounts	f	2026-09-02 12:39:24.021663+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
07fc7aba-592c-4573-99a5-9b7c0298ab77	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-09-02 17:17:36.680639+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
49207f1d-d605-4315-ba69-e3450e771172	\N	6cec1e8f-a65e-4c11-8fc3-265376ffe0cc	Sahil Lad	sahillad77@gmail.com	7854125698	spoc	Accounts	f	2026-09-02 17:17:36.680639+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
4e6eb452-29f7-4331-b8ec-2b8e84bd24b2	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-09-02 17:17:36.680639+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
6dd8073f-86fb-4519-b19a-bbdea9480c9a	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-09-02 17:17:36.680639+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
95681d26-9084-44f9-9d3b-c4be5e7fe351	\N	a69fe228-de12-44e5-9128-dc3898f67e5c	omkar	omkar@talakunchi.com	9877987899	SPOC	Accounts	f	2026-09-02 17:17:36.680639+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
9f43aded-feb0-48a7-918c-c29e9b567495	\N	a2e2e7fc-4e12-4bd6-85b4-baffcd70c1f3	sdsad	madhurigaikwad2310@gmail.com	7621423213	spoc	Technical	f	2026-09-02 17:17:36.680639+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
c00c4740-2af2-4fed-959f-23e9376d74b0	\N	3a681001-620a-4190-bd6c-1ee7131f2c3f	Sahil Lad	sahillad77@gmail.com	7821093801	spoc	Procurement	f	2026-09-02 17:17:36.680639+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
023e0aa7-e085-414b-bf60-4e718c79be7f	\N	be9fd5f1-6786-4caa-bf68-e9ee4ab4c5a2	Omakar	omkar@gmail.com	7865444994	spoc	Procurement	f	2026-09-09 12:32:12.789474+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
aeef5714-79f5-4088-9835-4979f1f61bdd	\N	6fbfe113-eb06-42ca-b34e-e3c75139678b	Vignesh	vig@gmail.com	778646421	spoc	Technical	f	2026-09-09 12:32:12.789474+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	Australia	+61
cd23c791-a572-4455-a9ab-ada7d93dc9ee	\N	6fbfe113-eb06-42ca-b34e-e3c75139678b	Sanket	sanket@gmail.com	7821548796	cisco	Accounts	f	2026-09-09 12:32:12.789474+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	India	+91
da906f79-0a12-4776-b06d-50ef0b151465	\N	be9fd5f1-6786-4caa-bf68-e9ee4ab4c5a2	Dhanashree	Dha@gmail.com	7854325667	spoc	Technical	f	2026-09-09 12:32:12.789474+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clients ("Id", "Name", "Industry", "Logo", "ContactEmail", "ClientType", "Status", "EngagementManager", "ContactName", "ContactPhone", "ContactDesignation", "ContactType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BusinessType", "City", "Country", "KycDocumentName", "Notes", "EngagementManagerId", "IndustryId", "CityId", "CountryId", "CustomerSince", "SalesManager", "SalesManagerId", "KycDocumentPath", "BillingMedium", "GroupSpocName", "GroupSpocContact") FROM stdin;
ccc4f266-8e68-4b62-9967-04ddacc9113c	SM Test Client	Technology	ST	smtest@example.com	New	Active	Riya Kapoor	Test	\N	\N	\N	2026-09-02 13:18:11.711029+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Mumbai	India	\N	\N	00000000-0000-4000-8000-000000000013	02012f0c-97b2-4aea-a6b4-954ee97d892d	6ffbb80b-985d-4f00-9140-db22f39a625d	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-09-02	John Smith	00000000-0000-4000-8000-000000000007	\N	\N	Test	\N
08f36c9b-9833-4008-9a58-9b69b5c491e3	Onboard SM Fix Test	Technology	OS	smfix@example.com	New	Active	Riya Kapoor	Test	\N	\N	\N	2026-09-02 13:24:30.517916+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Mumbai	India	\N	\N	00000000-0000-4000-8000-000000000013	02012f0c-97b2-4aea-a6b4-954ee97d892d	6ffbb80b-985d-4f00-9140-db22f39a625d	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-09-02	Priya Shah	00000000-0000-4000-8000-000000000007	\N	\N	Test	\N
06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Pharma	Healthcare	HP	it@helix.com	Old	Active	Pradeep Singh	Sanjay Sen	+91 98765 43211	Procurement Head	Procurement	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Sanjay Sen	+91 98765 43211
c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Systems	Automotive	AS	engineering@autodrive.com	Old	Active	Arjun Mehta	Kabir Sen	+91 98765 43219	Engineering SPOC	Technical SPOC	2026-08-07 13:19:59.669429+05:30	2026-09-02 15:54:57.074997+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	4bf54de4-0e85-4904-a89f-542301b65077	\N	\N	2026-08-07	Manohar Lad	00000000-0000-4000-8000-000000000007	\N	\N	Kabir Sen	+91 98765 43219
d35873d4-c12c-40c3-a66e-78d9f296ef2b	Testing	Energy	T	omkar@gmail.com	New	Active	Pradeep Singh	Sahil	6734543534	\N	Group SPOC	2026-09-08 19:25:06.603779+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Gurugram	India	IN-2026-27-C004-P003.xlsx	\N	00000000-0000-4000-8000-000000000013	c7e82721-829b-4450-8393-022587178471	95913438-968f-4e17-8324-a8e75b2242f4	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-09-08	Nikhil Khanna	00000000-0000-4000-8000-000000000007	\N	Portal Based	Sahil	6734543534
a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync AI	Technology	CA	contact@cloudsync.com	New	Active	Riya Kapoor	Neha Gupta	+91 98765 43215	IT Lead	Technical SPOC	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	02012f0c-97b2-4aea-a6b4-954ee97d892d	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Neha Gupta	+91 98765 43215
f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Retail	Retail	OR	tech@orbit.com	Old	Active	Riya Kapoor	Aditi Rao	+91 98765 43212	CFO	Accounts	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	935db8d7-e2aa-417e-839e-b51d00ce951e	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Aditi Rao	+91 98765 43212
f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Solutions	Environment	ES	projects@ecogreen.com	Old	Active	Riya Kapoor	Rohan Varma	+91 98765 43218	Legal Head	Legal	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	16ebeb23-b3d8-4fb7-a4f6-789510c28ad3	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Rohan Varma	+91 98765 43218
428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Logistics	Logistics	ZL	pm@zenith.com	New	Active	Rahul Sharma	Vikram Malhotra	+91 98765 43213	Legal Counsel	Legal	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000014	f175fde9-14f8-40e8-b564-47d8a29d84ff	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Vikram Malhotra	+91 98765 43213
9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Bank	Banking	NB	ops@northwind.com	Old	Active	Rahul Sharma	Rahul Sharma	+91 98765 43210	IT Manager	Technical SPOC	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000014	4a80bfdb-a191-4ce1-ab51-2142eb366db7	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Rahul Sharma	+91 98765 43210
89714d99-8107-4cd0-8095-6da7823cb767	cust test	Banking	CT	harshada.tawde@gmail.com	New	Active	riya kapoor	Harshada Tawde	7977953150	spoc	Accounts	2026-09-02 12:39:23.899459+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Mumbai	India	Details for PMS.xlsx	\N	00000000-0000-4000-8000-000000000013	4a80bfdb-a191-4ce1-ab51-2142eb366db7	6ffbb80b-985d-4f00-9140-db22f39a625d	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-09-02	\N	00000000-0000-4000-8000-000000000007	\N	\N	Harshada Tawde	7977953150
a04ccf3a-81c8-4416-8af7-068717ddb22b	Morphle	Banking	M	roshan.jadhav@gmail.com	New	Active	Pradeep Singh	roshan jadhav	7389247892	spoc	Accounts	2026-08-20 19:01:53.288995+05:30	2026-08-21 17:58:26.459736+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	Kalyan-Dombivli	India	API Gateway Configuration Guide (1).txt	no comments	00000000-0000-4000-8000-000000000013	4a80bfdb-a191-4ce1-ab51-2142eb366db7	4d396fc0-ae55-4eeb-b2db-79bbb757d3cd	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20	\N	00000000-0000-4000-8000-000000000007	\N	\N	roshan jadhav	7389247892
a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Plus	Healthcare	MP	tech@medicareplus.com	New	Active	Pradeep Singh	Priyanka Joshi	+91 98765 43217	Procurement Mgr	Procurement	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Priyanka Joshi	+91 98765 43217
47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Energy	Energy	LE	digital@lumen.com	Old	Active	Pradeep Singh	Arjun Mehta	+91 98765 43214	Operations Manager	Technical SPOC	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:58:40.3605+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Arjun Mehta	+91 98765 43214
90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	TATA	Energy	T	sahillad2092003@gmail.com	New	Active	Pradeep Singh	Sahil	8744541212	spoc	Technical	2026-08-20 16:30:13.739957+05:30	2026-08-21 14:32:02.864281+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	mumbai	India	exit-summary (1).csv	kldfslkdfsdlf	00000000-0000-4000-8000-000000000013	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-20	\N	00000000-0000-4000-8000-000000000007	\N	\N	Sahil	8744541212
fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Global	Finance	FG	dev@fintechglobal.com	Old	Active	Rahul Sharma	Siddharth Shah	+91 98765 43216	Finance VP	Accounts	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000014	cd116cba-a939-4cb7-bd0f-233019a005b0	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Siddharth Shah	+91 98765 43216
\.


--
-- Data for Name: employee_activity_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employee_activity_logs ("Id", "EmployeeId", "Action", "PerformedByEmail", "PerformedByName", "Details", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employees ("Id", "EmployeeCode", "FirstName", "LastName", "WorkEmail", "PersonalEmail", "Phone", "AltPhone", "Gender", "DateOfBirth", "Address", "EmergencyContact", "MaritalStatus", "Nationality", "DepartmentId", "DesignationId", "Role", "ReportingManagerId", "BusinessUnit", "WorkLocation", "OfficeBranch", "Category", "Team", "JoiningDate", "Status", "ConfirmationStatus", "ProbationStatus", "Experience", "PreviousCompany", "EmploymentType", "ContractType", "BondStatus", "NoticePeriod", "AssetId", "ExitType", "ExitReason", "Education", "Skills", "Certifications", "Languages", "KpiScore", "QuarterlyKpi", "AnnualRating", "GoalCompletion", "Attendance", "ReportingEfficiency", "PromotionReadiness", "ManagerFeedback", "Pan", "BankAccount", "SalaryBand", "PfUan", "TaxRegime", "ComplianceStatus", "UserId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "JobRoleId", "NationalityId", "ProbationPeriod", "SalaryBandId", "Aadhaar", "EmergencyContactName", "EmployeeStatusId", "BondDelivered", "BondDurationMonths", "BondExpiryDate", "GradDegree", "GradYear", "PostGradDegree", "PostGradYear", "ExpType", "PriorTotalExp", "PriorRelevantExp", "EmergencyContactRelation", "PmoDepartment", "SubDepartment", "BillableStatus", "ClientLocation", "ProjectType", "ProjectAllocated", "ClientEngManagerMapping", "ProjectSite", "EngagementManagerEmployeeId", "ProjectManagerId") FROM stdin;
00000000-0000-4000-8000-000000000013	TK-0013	Riya	Kapoor	riya@acme.co	\N	9820001013	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101013	Single	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	fdd34566-051a-487d-a985-540c2db8c37f	EngagementManager	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1013	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Project Management"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1247F	501234561013	L4	100112341013	New Regime	Compliant	e7554ba2-e546-93ce-1e88-a073badd78a2	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	57b9b89d-9123-4bd0-b8fd-a373e0648f43	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891013	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Project Management	Engagement Manager	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000014	TK-0014	Pradeep	Singh	pradeep.singh@acme.co	\N	9820001014	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101014	Single	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	fdd34566-051a-487d-a985-540c2db8c37f	EngagementManager	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1014	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Project Management"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1248F	501234561014	L4	100112341014	New Regime	Compliant	00000000-0000-4000-9000-000000000014	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	57b9b89d-9123-4bd0-b8fd-a373e0648f43	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891014	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Project Management	Engagement Manager	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000015	TK-0015	Kavya	Desai	kavya.desai@acme.co	\N	9820001015	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101015	Single	Indian	898c36e9-1cb7-4c56-9148-a3b6893c0149	3356f353-1566-4df6-9958-fa01d67d13c7	R&D - Team member	00000000-0000-4000-8000-000000000003	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1015	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "R&D (Research & Development)"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1249F	501234561015	L2	100112341015	New Regime	Compliant	00000000-0000-4000-9000-000000000015	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	401a442f-98c4-4b95-9e07-647853bf9122	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891015	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	R&D (Research & Development)	Python Developer - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000003
00000000-0000-4000-8000-000000000016	TK-0016	Rajesh	Kadam	rajesh.kadam@acme.co	\N	9820001016	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101016	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b3c75d81-80a1-4240-8b1e-010000000003	SOC-HOD	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1016	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1250F	501234561016	L5	100112341016	New Regime	Compliant	00000000-0000-4000-9000-000000000016	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	b3c75d81-80a1-4240-8b1e-020000000003	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891016	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC HOD	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000017	TK-0017	Deepak	Sawant	deepak.sawant@acme.co	\N	9820001017	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101017	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b3c75d81-80a1-4240-8b1e-010000000002	SOC-Senior Manager	00000000-0000-4000-8000-000000000016	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1017	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1251F	501234561017	L4	100112341017	New Regime	Compliant	00000000-0000-4000-9000-000000000017	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	b3c75d81-80a1-4240-8b1e-020000000002	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891017	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Senior Manager	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000016
00000000-0000-4000-8000-000000000018	TK-0018	Vikram	Shah	vikram@acme.co	\N	9820001018	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101018	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b3c75d81-80a1-4240-8b1e-010000000001	SOC-Manager	00000000-0000-4000-8000-000000000017	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1018	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1252F	501234561018	L4	100112341018	New Regime	Compliant	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	b3c75d81-80a1-4240-8b1e-020000000001	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891018	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Manager	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000020	TK-0020	Nikhil	Rao	nikhil@acme.co	\N	9820001020	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101020	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	SOC-Team Leader	00000000-0000-4000-8000-000000000018	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1020	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1254F	501234561020	L3	100112341020	New Regime	Compliant	49c4e7da-23ec-aab1-9fdf-61dd23764d10	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	31ebb23e-f7d1-4c01-859b-67d24e96e2fb	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891020	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Lead - II	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000001	TK-0001	Vikrant	Malhotra	vikrant@acme.co	\N	9820001001	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101001	Single	Indian	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	778f1120-9633-4933-9160-ddaa46668838	CEO	\N	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1001	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Core"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1235F	501234561001	L5	100112341001	New Regime	Compliant	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	94fc014e-37ce-4eb4-8588-ff56a79be98e	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891001	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Core	Director and Chief Executive Officer	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	\N	\N
00000000-0000-4000-8000-000000000021	TK-0021	Amit	Pandey	amit.pandey@acme.co	\N	9820001021	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101021	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	444df30d-c195-42ad-b9a7-d80cdef69ccd	SOC-Team Leader	00000000-0000-4000-8000-000000000018	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1021	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1255F	501234561021	L3	100112341021	New Regime	Compliant	00000000-0000-4000-9000-000000000021	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	6032fef5-eb05-42bd-9f10-72f12e154243	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891021	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Shift Lead - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000022	TK-0022	Karthik	Bose	karthik.bose@acme.co	\N	9820001022	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101022	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	6d25ff6d-e13d-440f-b775-215547af7acb	SOC-Team Member	00000000-0000-4000-8000-000000000019	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1022	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1256F	501234561022	L2	100112341022	New Regime	Compliant	00000000-0000-4000-9000-000000000022	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	eaa98dba-df5b-4b1d-b2d5-20b159a0a070	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891022	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Analyst - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000023	TK-0023	Ankit	Verma	ankit.verma@acme.co	\N	9820001023	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101023	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	48429bb5-c583-4684-b30a-7ed443b671ca	SOC-Team Member	00000000-0000-4000-8000-000000000019	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1023	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1257F	501234561023	L2	100112341023	New Regime	Compliant	00000000-0000-4000-9000-000000000023	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	9c970783-5b89-4fd0-b3f3-1c1953a853ab	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891023	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Analyst - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000024	TK-0024	Aditya	Reddy	aditya.reddy@acme.co	\N	9820001024	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101024	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	4650d4e0-f73c-4688-ae5f-830a46348ff9	SOC-Team Member	00000000-0000-4000-8000-000000000020	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1024	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1258F	501234561024	L2	100112341024	New Regime	Compliant	00000000-0000-4000-9000-000000000024	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	0997a260-4ca3-4eb2-b87a-4bd6bf235677	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891024	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SIEM Admin - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000025	TK-0025	Manish	Tiwari	manish.tiwari@acme.co	\N	9820001025	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101025	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	SOC-Team Member	00000000-0000-4000-8000-000000000020	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1025	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1259F	501234561025	L2	100112341025	New Regime	Compliant	00000000-0000-4000-9000-000000000025	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	24ccdefb-8dd5-411e-8b2e-af8fb743a3cb	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891025	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Consultant - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000026	TK-0026	Pooja	Nair	pooja.nair@acme.co	\N	9820001026	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101026	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	f20a7445-0b01-4f20-85a5-853101d864ee	SOC-Team Member	00000000-0000-4000-8000-000000000021	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1026	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1260F	501234561026	L2	100112341026	New Regime	Compliant	00000000-0000-4000-9000-000000000026	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	3f413c39-a269-4d44-9f3c-9e7f6e3ecced	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891026	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Analyst - III	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000027	TK-0027	Anita	Desai	anita@acme.co	\N	9820001027	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101027	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	2b1558e3-158a-4a84-ae80-053129861a64	Consulting-HOD	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1027	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1261F	501234561027	L5	100112341027	New Regime	Compliant	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	6b840581-65b6-4e1d-916f-38b6018e07e0	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891027	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	Senior Vice President - Principal Consultant	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000029	TK-0029	Sana	Iyer	sana@acme.co	\N	9820001029	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101029	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	195d6a81-8457-4b60-9382-6a3a0664f0e9	Consulting-Manager	00000000-0000-4000-8000-000000000028	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1029	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1263F	501234561029	L4	100112341029	New Regime	Compliant	a3a20ac4-43a2-de64-52d3-bfafce7c7053	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	52ae8b5b-80b3-4d14-b8c5-0bc40e1f4bee	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891029	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	Associate Manager - III	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000030	TK-0030	Priya	Verma	priya@acme.co	\N	9820001030	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101030	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	Consulting-Team Leader	00000000-0000-4000-8000-000000000029	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1030	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1264F	501234561030	L3	100112341030	New Regime	Compliant	65e2ffa3-6073-780a-b849-4d9604c7251c	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	22215465-c056-4ba4-a867-23ed37658a09	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891030	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	Senior GRC Auditor - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000031	TK-0031	Siddharth	Roy	siddharth.roy@acme.co	\N	9820001031	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101031	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	3e60b693-d3dd-4481-95c4-9f02da21625c	Consulting-Team Leader	00000000-0000-4000-8000-000000000029	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1031	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1265F	501234561031	L3	100112341031	New Regime	Compliant	00000000-0000-4000-9000-000000000031	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	4e574ffd-c3a9-4a15-832a-5dabfb352dc3	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891031	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	Senior GRC Auditor - II	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000032	TK-0032	Ira	Kapoor	ira.kapoor@acme.co	\N	9820001032	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101032	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	1e7faab8-273d-40df-9f9a-485160186c5a	Consulting-Team member	00000000-0000-4000-8000-000000000030	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1032	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1266F	501234561032	L2	100112341032	New Regime	Compliant	00000000-0000-4000-9000-000000000032	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	074ea1a8-d519-4cda-87a4-978cd1eec45a	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891032	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	GRC Auditor - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000033	TK-0033	Meera	Nambiar	meera.nambiar@acme.co	\N	9820001033	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101033	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	Consulting-Team member	00000000-0000-4000-8000-000000000030	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1033	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1267F	501234561033	L2	100112341033	New Regime	Compliant	00000000-0000-4000-9000-000000000033	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	6886e92b-a2c5-4057-9330-47394a2aac65	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891033	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	GRC Auditor - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000034	TK-0034	Rajat	Singhal	rajat.singhal@acme.co	\N	9820001034	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101034	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	Consulting-Team member	00000000-0000-4000-8000-000000000031	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1034	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1268F	501234561034	L2	100112341034	New Regime	Compliant	00000000-0000-4000-9000-000000000034	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	40354601-9ac5-41e0-9ddb-6603e5614a86	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891034	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	GRC Auditor - III	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000035	TK-0035	Swati	Mishra	swati.mishra@acme.co	\N	9820001035	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101035	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	7c2380da-3ee6-46ad-93d6-a79ce3027f29	Consulting-Team member	00000000-0000-4000-8000-000000000031	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1035	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1269F	501234561035	L2	100112341035	New Regime	Compliant	00000000-0000-4000-9000-000000000035	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	3efb18e5-f8d5-4de9-8959-ab5401f64b74	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891035	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	GRC Auditor - IV	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000036	TK-0036	Varun	Saxena	varun.saxena@acme.co	\N	9820001036	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101036	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	1e7faab8-273d-40df-9f9a-485160186c5a	Consulting-Team member	00000000-0000-4000-8000-000000000031	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1036	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1270F	501234561036	L2	100112341036	New Regime	Compliant	00000000-0000-4000-9000-000000000036	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	074ea1a8-d519-4cda-87a4-978cd1eec45a	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891036	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	GRC Auditor - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000037	TK-0037	Girish	Shenoy	girish.shenoy@acme.co	\N	9820001037	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101037	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	b3c75d81-80a1-4240-8b1e-010000000004	Testing HOD	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1037	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1271F	501234561037	L5	100112341037	New Regime	Compliant	00000000-0000-4000-9000-000000000037	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	b3c75d81-80a1-4240-8b1e-020000000004	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891037	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Testing HOD	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000038	TK-0038	Suresh	Pillai	suresh.pillai@acme.co	\N	9820001038	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101038	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	Testing Senior Manager	00000000-0000-4000-8000-000000000037	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1038	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1272F	501234561038	L4	100112341038	New Regime	Compliant	00000000-0000-4000-9000-000000000038	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	a3986a0e-d20f-4f20-a648-adcc724bb622	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891038	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Manager - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000037
00000000-0000-4000-8000-000000000040	TK-0040	Divya	Rao	divya.rao@acme.co	\N	9820001040	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101040	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	Testing-Manager	00000000-0000-4000-8000-000000000038	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1040	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1274F	501234561040	L4	100112341040	New Regime	Compliant	00000000-0000-4000-9000-000000000040	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	caec3c96-23a0-4e88-845c-05f792d0dd0c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891040	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Associate Project Manager	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000040
00000000-0000-4000-8000-000000000041	TK-0041	Manoj	Bhatt	manoj.bhatt@acme.co	\N	9820001041	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101041	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	c1fa4328-a970-48a1-bc08-d50fe36bf44c	Testing-Manager	00000000-0000-4000-8000-000000000038	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1041	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1275F	501234561041	L4	100112341041	New Regime	Compliant	00000000-0000-4000-9000-000000000041	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	a583ec5f-f30a-4b03-9e35-6afc3f1aee8d	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891041	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	DevSecOps Specialist - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000041
00000000-0000-4000-8000-000000000042	TK-0042	Gaurav	Joshi	gaurav.joshi@acme.co	\N	9820001042	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101042	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	c6c6cd04-6df3-4593-b686-e4b9d362c96f	Testing-Team Leader	00000000-0000-4000-8000-000000000039	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1042	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1276F	501234561042	L3	100112341042	New Regime	Compliant	00000000-0000-4000-9000-000000000042	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	111000c1-ff0c-499c-a9cb-34febe2ac32d	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891042	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	DevSecOps Associate	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000039
00000000-0000-4000-8000-000000000043	TK-0043	Kiran	Mathur	kiran.mathur@acme.co	\N	9820001043	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101043	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	e228c999-bf54-48b4-a373-d2bc9db88554	Testing-Team Leader	00000000-0000-4000-8000-000000000040	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1043	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1277F	501234561043	L3	100112341043	New Regime	Compliant	00000000-0000-4000-9000-000000000043	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	da59e567-3ee0-4a98-9b1e-83f8e6c01e2c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891043	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Associate Manager - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000040
00000000-0000-4000-8000-000000000044	TK-0044	Ramesh	Nair	ramesh.nair@acme.co	\N	9820001044	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101044	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	Testing-Team Leader	00000000-0000-4000-8000-000000000041	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1044	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1278F	501234561044	L3	100112341044	New Regime	Compliant	00000000-0000-4000-9000-000000000044	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	20d077b9-894b-4bf3-b491-5df765e645f0	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891044	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Associate Manager - II	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000041
00000000-0000-4000-8000-000000000045	TK-0045	Priya	Sharma	priya.sharma@acme.co	\N	9820001045	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101045	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	Testing-Team Member	00000000-0000-4000-8000-000000000042	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1045	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1279F	501234561045	L2	100112341045	New Regime	Compliant	00000000-0000-4000-9000-000000000045	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	a955782d-de73-4939-94f8-5cbf9a2461c2	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891045	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	PenTester - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000039
00000000-0000-4000-8000-000000000046	TK-0046	Arjun	Singh	arjun@acme.co	\N	9820001046	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101046	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	Testing-Team Member	00000000-0000-4000-8000-000000000042	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1046	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1280F	501234561046	L2	100112341046	New Regime	Compliant	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	2cd464a5-b857-46fc-89ea-5dea92640964	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891046	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	PenTester - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000039
00000000-0000-4000-8000-000000000047	TK-0047	Meera	Joshi	meera@acme.co	\N	9820001047	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101047	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	ae255622-ddcc-45ea-a699-8ec416fe57ab	Testing-Team Member	00000000-0000-4000-8000-000000000043	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1047	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1281F	501234561047	L2	100112341047	New Regime	Compliant	111775f6-5d80-5333-478e-68e2fda584fa	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	4e547334-4964-4dbe-81a4-a316d9394d03	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891047	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	DevSecOps Practitioner - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000040
00000000-0000-4000-8000-000000000048	TK-0048	Dev	Patel	dev@acme.co	\N	9820001048	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101048	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	Testing-Team Member	00000000-0000-4000-8000-000000000043	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1048	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1282F	501234561048	L2	100112341048	New Regime	Compliant	9f6f34df-dc47-f198-f3f6-e577aab1cbca	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	5a206a6a-dabc-4dfe-b28f-00cc01bc11da	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891048	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Red Team Practitioner - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000040
00000000-0000-4000-8000-000000000049	TK-0049	Kavya	Nair	kavya@acme.co	\N	9820001049	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101049	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	Testing-Team Member	00000000-0000-4000-8000-000000000044	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1049	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1283F	501234561049	L2	100112341049	New Regime	Compliant	b1d3f51c-b209-d352-4b52-3f4008801ab3	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	736d1ddd-c56a-4c4f-b266-bc4f6be6ed9c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891049	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Senior Pentester - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000041
00000000-0000-4000-8000-000000000050	TKI-0001	Ananya	Verma	ananya.verma@acme.co	\N	9820001050	\N	\N	2002-05-15	101, Suvidha Square, Andheri	9811101050	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	Intern	00000000-0000-4000-8000-000000000042	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1050	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1284F	501234561050	L1	100112341050	New Regime	Compliant	00000000-0000-4000-9000-000000000050	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	32d7cead-40d2-4d94-89fb-3e48d4160b7c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891050	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Testing	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000039
00000000-0000-4000-8000-000000000051	TKI-0002	Rohan	Joshi	rohan.joshi@acme.co	\N	9820001051	\N	\N	2002-05-15	101, Navare Plaza, Dombivli	9811101051	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	Intern	00000000-0000-4000-8000-000000000043	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1051	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1285F	501234561051	L1	100112341051	New Regime	Compliant	00000000-0000-4000-9000-000000000051	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	32d7cead-40d2-4d94-89fb-3e48d4160b7c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891051	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Testing	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000040
00000000-0000-4000-8000-000000000052	TKI-0003	Tanvi	Deshmukh	tanvi.deshmukh@acme.co	\N	9820001052	\N	\N	2002-05-15	101, Suvidha Square, Andheri	9811101052	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	Intern	00000000-0000-4000-8000-000000000044	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1052	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1286F	501234561052	L1	100112341052	New Regime	Compliant	00000000-0000-4000-9000-000000000052	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	32d7cead-40d2-4d94-89fb-3e48d4160b7c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891052	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Testing	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000041
00000000-0000-4000-8000-000000000053	TKI-0004	Ayush	Saxena	ayush.saxena@acme.co	\N	9820001053	\N	\N	2002-05-15	101, Navare Plaza, Dombivli	9811101053	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	Intern	00000000-0000-4000-8000-000000000019	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1053	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1287F	501234561053	L1	100112341053	New Regime	Compliant	00000000-0000-4000-9000-000000000053	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	1d19d6af-78b4-45ef-bcb3-db1b3896f153	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891053	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Operations	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000054	TKI-0005	Simran	Kaur	simran.kaur@acme.co	\N	9820001054	\N	\N	2002-05-15	101, Suvidha Square, Andheri	9811101054	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	Intern	00000000-0000-4000-8000-000000000020	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1054	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1288F	501234561054	L1	100112341054	New Regime	Compliant	00000000-0000-4000-9000-000000000054	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	1d19d6af-78b4-45ef-bcb3-db1b3896f153	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891054	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Operations	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000055	TKI-0006	Naveen	Choudhary	naveen.choudhary@acme.co	\N	9820001055	\N	\N	2002-05-15	101, Navare Plaza, Dombivli	9811101055	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	2076a9b1-e432-46a9-99b1-36e732159856	Intern	00000000-0000-4000-8000-000000000030	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1055	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1289F	501234561055	L1	100112341055	New Regime	Compliant	00000000-0000-4000-9000-000000000055	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	6c0bebbb-cc4d-4433-83e9-d65fb5291d75	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891055	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Consulting	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000056	TKI-0007	Bhavna	Patel	bhavna.patel@acme.co	\N	9820001056	\N	\N	2002-05-15	101, Suvidha Square, Andheri	9811101056	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	2076a9b1-e432-46a9-99b1-36e732159856	Intern	00000000-0000-4000-8000-000000000031	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1056	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1290F	501234561056	L1	100112341056	New Regime	Compliant	00000000-0000-4000-9000-000000000056	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	6c0bebbb-cc4d-4433-83e9-d65fb5291d75	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891056	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Consulting	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000057	TKI-0008	Harsh	Wardhan	harsh.wardhan@acme.co	\N	9820001057	\N	\N	2002-05-15	101, Navare Plaza, Dombivli	9811101057	Single	Indian	898c36e9-1cb7-4c56-9148-a3b6893c0149	bb7ccd5f-2f60-49fb-b984-f11fc47add22	Intern	00000000-0000-4000-8000-000000000015	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1057	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "R&D (Research & Development)"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1291F	501234561057	L1	100112341057	New Regime	Compliant	00000000-0000-4000-9000-000000000057	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	859254f8-a1b4-4812-b1d0-aacf111f7235	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891057	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	R&D (Research & Development)	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000003
00000000-0000-4000-8000-000000000058	TKI-0009	Akash	Jain	akash.jain@acme.co	\N	9820001058	\N	\N	2002-05-15	101, Suvidha Square, Andheri	9811101058	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	e2b10def-c91d-45da-94c5-f5530e743aa2	Intern	00000000-0000-4000-8000-000000000007	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1058	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1292F	501234561058	L1	100112341058	New Regime	Compliant	00000000-0000-4000-9000-000000000058	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	0b340900-7bd0-4931-8978-832c678c7cbd	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891058	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Functional - Sales	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000007
00000000-0000-4000-8000-000000000028	TK-0028	Aarav	Mehta	aarav@acme.co	\N	9820001028	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101028	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	dadac355-1ddc-457c-935a-d297da3a883d	Consulting-Senior Manager	00000000-0000-4000-8000-000000000027	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1028	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1262F	501234561028	L4	100112341028	New Regime	Compliant	1a077a8c-4029-8ded-d563-19e9b4bdf301	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	61cc6cff-4f61-4a1d-90f5-9eb9f61c54f3	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891028	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	Principal Manager - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000027
00000000-0000-4000-8000-000000000019	TK-0019	Sneha	Iyer	sneha.iyer@acme.co	\N	9820001019	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101019	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b5f39dd8-c305-489d-9f7d-9adfd010a134	SOC-Team Leader	00000000-0000-4000-8000-000000000018	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1019	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1253F	501234561019	L3	100112341019	New Regime	Compliant	00000000-0000-4000-9000-000000000019	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	8366d816-724b-456b-9d0e-85399c2324b7	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891019	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Lead - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000039	TK-0039	Alok	Kumar	alok.kumar@acme.co	\N	9820001039	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101039	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	Testing-Manager	00000000-0000-4000-8000-000000000038	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1039	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1273F	501234561039	L4	100112341039	New Regime	Compliant	00000000-0000-4000-9000-000000000039	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	a3d0a1e1-b4a8-4ae5-8577-cd2019268494	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891039	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Associate Manager - III	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000039
00000000-0000-4000-8000-000000000003	TK-0003	Kunal	Deshmukh	kunal.deshmukh@acme.co	\N	9820001003	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101003	Single	Indian	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	0525d830-ead9-44a0-871f-91b7845fec26	CTO	00000000-0000-4000-8000-000000000001	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1003	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Core"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1237F	501234561003	L5	100112341003	New Regime	Compliant	00000000-0000-4000-9000-000000000003	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	0028e31d-d2ff-4a71-b5b2-5f0566961d46	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891003	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Core	Director and Chief Technology Officer	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	\N	\N
00000000-0000-4000-8000-000000000002	TK-0002	Dhanshree	Pansare	dhanshree@acme.co	\N	9820001002	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101002	Single	Indian	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	ffed7aa1-e88f-4281-919f-8d49fbabf5a5	COO	00000000-0000-4000-8000-000000000001	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1002	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Core"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1236F	501234561002	L5	100112341002	New Regime	Compliant	40517b71-5e62-182e-73b5-d4070e20a3c2	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	3dd672a7-e6a9-42c8-bdbf-4d1340efc1da	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891002	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Core	Director and Chief Operating Officer	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	\N	\N
00000000-0000-4000-8000-000000000004	TK-0004	Admin	User	admin@acme.co	\N	9820001004	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101004	Single	Indian	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	da990f6e-3379-4cc4-89b7-0ead29da472b	IT Admin	00000000-0000-4000-8000-000000000003	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1004	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - IT Administration"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1238F	501234561004	L3	100112341004	New Regime	Compliant	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	eda2ca5a-d2b1-45db-94cc-4575f0eda8dc	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891004	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - IT Administration	IT Admin	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000003
00000000-0000-4000-8000-000000000005	TK-0005	Accounts	User	accounts@acme.co	\N	9820001005	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101005	Single	Indian	bcbd68c8-c3f3-4396-abb0-0b0e13637958	4ef1cb5b-9688-4ce2-95b3-6a0863200166	Accounts	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1005	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Accounts"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1239F	501234561005	L4	100112341005	New Regime	Compliant	dc139a9d-b996-7354-6c27-72659ea2fd59	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	f37fa8d5-1c48-4038-95d5-cd7dfea12085	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891005	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Accounts	Senior Accountant - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000006	TK-0006	HR	User	hr@acme.co	\N	9820001006	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101006	Single	Indian	310a2f16-15f6-4b82-95f6-ab18b5b429f5	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	HR	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1006	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - HR"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1240F	501234561006	L4	100112341006	New Regime	Compliant	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	c7d75b92-f6e2-4dd7-a726-ae662ee83c95	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891006	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - HR	HR Head	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000007	TK-0007	Sales	User	sales@acme.co	\N	9820001007	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101007	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	b3c75d81-80a1-4240-8b1e-010000000005	Sales Manager	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1007	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1241F	501234561007	L4	100112341007	New Regime	Compliant	730809c0-fc01-a664-03ca-28e0e32d0393	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	b3c75d81-80a1-4240-8b1e-020000000005	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891007	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Sales	Sales Manager	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000008	TK-0008	Nikhil	Khanna	nikhil.khanna@acme.co	\N	9820001008	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101008	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	e2c675a7-92dc-4477-be75-9a304cbe4def	Sales team member	00000000-0000-4000-8000-000000000007	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1008	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1242F	501234561008	L2	100112341008	New Regime	Compliant	00000000-0000-4000-9000-000000000008	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	d0b9d2a2-d79c-4097-ae63-4bff14436d0a	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891008	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Sales	Sales Associate	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000007
00000000-0000-4000-8000-000000000009	TK-0009	Pooja	Sharma	pooja.sharma@acme.co	\N	9820001009	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101009	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	e2c675a7-92dc-4477-be75-9a304cbe4def	Sales team member	00000000-0000-4000-8000-000000000007	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1009	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1243F	501234561009	L2	100112341009	New Regime	Compliant	00000000-0000-4000-9000-000000000009	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	d0b9d2a2-d79c-4097-ae63-4bff14436d0a	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891009	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Sales	Sales Associate	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000007
00000000-0000-4000-8000-000000000010	TK-0010	Rohit	Verma	rohit.verma@acme.co	\N	9820001010	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101010	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	272973a6-c052-4aef-bf32-9e24f7eb6cc9	Sales team member	00000000-0000-4000-8000-000000000007	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1010	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1244F	501234561010	L2	100112341010	New Regime	Compliant	00000000-0000-4000-9000-000000000010	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	3e28d4a4-7d87-41ed-b921-a39dd937df76	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891010	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Sales	Associate Customer Success Representative - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000007
00000000-0000-4000-8000-000000000011	TK-0011	Sneha	Reddy	sneha.reddy@acme.co	\N	9820001011	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101011	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	Sales team member	00000000-0000-4000-8000-000000000007	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1011	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1245F	501234561011	L2	100112341011	New Regime	Compliant	00000000-0000-4000-9000-000000000011	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	21eac166-3ba7-40c5-a780-bbc7b3e96ddb	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891011	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Sales	Associate Customer Success Representative - II	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000007
00000000-0000-4000-8000-000000000012	TK-0012	Rahul	Gupta	rahul@acme.co	\N	9820001012	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101012	Single	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	PMO	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1012	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Project Management"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1246F	501234561012	L4	100112341012	New Regime	Compliant	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	446498d0-e9e6-4dbb-8fbe-b87bb853a2af	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891012	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Project Management	Senior PMO - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000059	TKI-0010	Kunal	Mehra	kunal.mehra@acme.co	\N	9820001059	\N	\N	2002-05-15	101, Navare Plaza, Dombivli	9811101059	Single	Indian	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	f8502c44-b289-49e4-8401-3dcad4d5bbe0	Intern	00000000-0000-4000-8000-000000000004	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1059	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - IT Administration"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1293F	501234561059	L1	100112341059	New Regime	Compliant	00000000-0000-4000-9000-000000000059	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N	f43fddea-4dd9-4603-a79c-1710224115ae	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891059	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Functional - IT Administration	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000004
\.


--
-- Data for Name: exited_employees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exited_employees ("Id", "OriginalEmployeeId", "EmployeeCode", "FullName", "DepartmentName", "DesignationName", "WorkEmail", "PersonalEmail", "Phone", "StatusAtExit", "ExitType", "ExitReason", "ResignationDate", "LastWorkingDay", "ReasonForLeaving", "NoticePeriodServed", "ExitChecklistJson", "AssetReturnJson", "FinalSettlementJson", "ExitedAtUtc", "ExitedBy", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "ClearanceCompleted", "ExitRating") FROM stdin;
d88f3e1e-3d11-481f-b074-d6c8250141e5	00000000-0000-4000-8000-000000000011	TK-0011	Harsh Nair	Functional - Project Management	Associate PMO - I	harsh.nair@talakunchi.com	harsh.nair11@gmail.com	9820000011	Active	Resign	Better opportunity	2026-09-10	2026-11-09	Better opportunity	60 days	\N	\N	\N	2026-09-10 10:57:29.201413+05:30	\N	2026-09-10 10:57:29.24202+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	f	4.5
482f25b2-2e12-4da2-9f10-9a44b487845c	00000000-0000-4000-8000-000000000003	TK-0003	Rohan Mehta	Services - Testing	DevSecOps Practitioner - II	rohan.mehta@talakunchi.com	rohan.mehta3@gmail.com	9820000003	Active	Resign	bo	2026-09-23	2026-11-22	bo	60 days	\N	\N	\N	2026-09-23 11:23:21.083025+05:30	\N	2026-09-23 11:23:21.199076+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	f	4.5
\.


--
-- Data for Name: mst_business_units; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_business_units ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
1ab2e67e-5e47-4f6d-8035-dd6a5c5f6b85	talakunchi_networks_private_limited	Talakunchi Networks Private Limited	t	1	2026-09-03 17:47:46.134222+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_certifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
0705d913-f281-4559-a5a2-273dcdab4c4c	comptia_securityplus	CompTIA Security+	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
0ff050bb-aff0-48e2-b3f1-0db0b1e4ff0e	certified_in_risk_and_information_systems_control_	Certified in Risk and Information Systems Control (CRISC)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
1277ee68-900e-4989-bdab-ea6c79593dfe	blue_team_level_1_and_2	Blue Team Level 1 and 2	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
13a1fd79-fc90-4c4d-b392-197e2173c3f0	offensive_security_certified_expert_3_(osce3)	Offensive Security Certified Expert 3 (OSCE3)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
2dea8afa-5403-43c9-9a03-45156a3c4198	elearnsecurity_certified_threat_hunting_profession	eLearnSecurity Certified Threat Hunting Professional (eCTHP)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
45d2575e-48cc-4593-86f6-1d1884e56abe	iso_27001	ISO 27001	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
5817ff34-8c14-4679-b368-8d5323ccd31b	pnpt	PNPT	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
6d67283e-fb84-408e-a151-12ee7ef9b7dd	ecppt	eCPPT	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
7ab3d38a-323d-49d8-8e0e-83b96e520205	certified_cloud_security_professional_(ccsp)	Certified Cloud Security Professional (CCSP)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
7d8276b0-d415-4110-b7ab-2bb718b0396f	offensive_security_certified_professional_(oscp)	Offensive Security Certified Professional (OSCP)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
7e8c683c-5fb3-4bdb-8d94-e5fbfcdc2e11	certified_threat_intelligence_analyst_(ctia)	Certified Threat Intelligence Analyst (CTIA)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
86e2ff2b-d817-4c93-aa51-51742d727d1b	offensive_security_wireless_professional_(oswp)	Offensive Security Wireless Professional (OSWP)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
9b093776-b367-4581-b1a9-a141bf9adcbb	elearnsecurity_certified_incident_responder_(ecir)	eLearnSecurity Certified Incident Responder (eCIR)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
a6c8ffd7-3497-4f4c-a651-bd1e6230f945	licensed_penetration_tester_(lpt)	Licensed Penetration Tester (LPT)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
aaa594dd-b167-4034-b538-a8ed292825f6	offensive_security_experienced_penetration_tester_	Offensive Security Experienced Penetration Tester (OSEP)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
ab729e39-7b07-4da9-ba03-d155d93695db	certified_ethical_hacker_(ceh)	Certified Ethical Hacker (CEH)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
bef0b76e-c4cd-4c11-8bdc-82ba930c8e51	iso_22301	ISO 22301	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
c38bd75b-3213-4bcd-9ca1-64ff72f02178	crte	CRTE	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
c4323823-361f-4ff9-a699-a91b2400f59b	crt	CRT	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
c4f2e057-5906-4154-83e2-4f009d6af825	ec_council_certified_incident_handler_(ecih)	EC-Council Certified Incident Handler (ECIH)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
cc0b6618-17ef-48f6-9280-6e7fa9885b60	certified_information_systems_security_professiona	Certified Information Systems Security Professional (CISSP)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
cc7740c3-4189-40e2-86f6-797dacb789c0	offsec_foundational_security_operations_and_defens	OffSec Foundational Security Operations and Defensive Analysis (OSDA)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
cf42b7a7-dd8c-4395-880c-a27051408df5	certified_information_security_manager_(cism)	Certified Information Security Manager (CISM)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
d79a4f9d-8eb3-48ea-baeb-20de01ea05ce	elearnsecurity_certified_digital_forensics_profess	eLearnSecurity Certified Digital Forensics Professional (eCDFP)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
daab1e17-24aa-435f-89a5-8a9e8e5052bf	iso_iec_42001	ISO/IEC 42001	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
e5540bc7-50d2-4d70-a943-acd46aa882c5	cpts	cPTS	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
e5ca396a-d689-4010-a451-39b1b99a7bd2	offensive_security_web_expert_(oswe)	Offensive Security Web Expert (OSWE)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
ef4cd7da-14f7-4f0d-afd0-99ca3bb6ffe2	certified_information_systems_auditor_(cisa)	Certified Information Systems Auditor (CISA)	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
fc483ca5-d867-433f-a4d6-bac79879517f	crtp	CRTP	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_cities; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: mst_contact_designations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_contact_designations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
301bc813-b2a8-487e-8645-6d613260a7e7	cio	CIO	t	3	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
36d0dd25-0888-4933-b7ec-1ffb839a50bd	cfo	CFO	t	4	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
4289316a-ac66-4577-93b2-b27a1f631bd7	ciso	CISO	t	2	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
634aee41-eb57-41e4-b296-af2a255a7e79	accounts_head	Accounts Head	t	5	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
8a02dfd7-d731-4231-8eba-29f36d2254c7	spoc	SPOC	t	1	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_contact_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_contact_types ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
58db2f92-2db9-46a1-ae8a-f04a3c7cf54c	legal	Legal	t	4	2026-09-09 13:09:28.906477+05:30	\N	\N	\N	\N
670b9a05-6ee2-488e-962c-51cf3cdb86fa	procurement	Procurement	t	2	2026-09-09 13:09:28.906477+05:30	\N	\N	\N	\N
6ddcfdba-7311-4f61-b285-88e09a772497	accounts	Accounts	t	1	2026-09-09 13:09:28.906477+05:30	\N	\N	\N	\N
b28647ac-40d2-449e-b90c-b71cbae83f8d	technical	Technical	t	3	2026-09-09 13:09:28.906477+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_countries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") FROM stdin;
f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	IN	India	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+91	10
339b1d1f-d716-422e-9090-127430134420	US	United States	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+1	10
1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	GB	United Kingdom	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+44	10
1d3750a9-fab1-43fb-ab7b-865dda283bf3	AE	United Arab Emirates	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+971	9
f1d80739-30d7-4877-a1a7-ee414b074134	SG	Singapore	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+65	8
eeb56a1f-9663-4d29-a984-30c4fc133de2	AU	Australia	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+61	9
3f86bc47-1e09-482f-9671-9f4b5b089ee4	DE	Germany	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+49	11
ba695b57-0f82-4ad0-b14a-2785b26209ff	CA	Canada	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+1	10
a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb	FR	France	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+33	9
01005b87-3f98-4425-8eb9-6417f2d83b41	JP	Japan	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+81	10
28d63d80-4982-4a6b-9400-ee91260b2604	SA	Saudi Arabia	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+966	9
7c57576c-45b6-4cf0-b26d-d3e64730118b	QA	Qatar	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+974	8
58746abf-d5dc-4cc8-8a35-96a1747f7a1f	NZ	New Zealand	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+64	9
585fb67f-28ee-437c-aa84-fdc20a1a11d5	ZA	South Africa	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+27	9
9bd3e0a8-de16-4a26-92aa-b43deae65bb7	IE	Ireland	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+353	9
6f9bb48d-5314-461c-aab8-3b47b00b27a1	NL	Netherlands	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+31	9
c1764720-16fe-4d3f-bd82-9882632239cd	IT	Italy	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+39	10
4da9200f-5486-4710-bf58-e73778e1d506	ES	Spain	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+34	9
d3791631-5e4b-4efa-a86a-59344c19e1a1	CH	Switzerland	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+41	9
c093b0e3-31a9-40b4-840c-539ca86bc578	KR	South Korea	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N	+82	10
068fb26f-376a-4976-9127-b0dae76e7dcd	DK	Denmark	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+45	8
0a836600-60d1-4d2e-bbd7-034b338574ba	PK	Pakistan	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+92	10
1814186b-4a79-45ea-bfc9-bbdc4721e20b	PH	Philippines	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+63	10
25e6b9ec-058b-4778-9c17-1151079562f4	AT	Austria	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+43	10
331cec37-bd6c-4a60-8ac5-b413d9677b8a	MX	Mexico	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+52	10
6044817c-ffa1-44b3-ac2a-05e52b97df4a	BR	Brazil	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+55	11
64ea0815-a39c-4ecb-b771-038dd74a9b7c	TH	Thailand	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+66	9
6e5c5f7b-ab38-4926-9945-da9ac35a35b0	BE	Belgium	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+32	9
7190bc9f-d9d5-4bb3-b889-af8a1d6ec53f	LK	Sri Lanka	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+94	9
8b34d450-add9-4da2-ab29-651c187ae702	CN	China	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+86	11
990888a7-50d0-45f0-b650-2686f87c4fd0	SE	Sweden	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+46	9
9c93a091-0971-4080-b15f-ddebb9de6bb3	FI	Finland	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+358	9
a3228796-7e35-4710-9439-2aa36754dbbe	VN	Vietnam	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+84	9
a890f8b0-d80f-4a14-994e-0ba88d6336a9	NO	Norway	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+47	8
af68020d-22f0-4f66-91f6-afe82d052ddd	PL	Poland	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+48	9
b8307417-a01f-4b81-8f46-b637c865dc76	PT	Portugal	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+351	9
c9bb9747-7e0f-424e-864b-182d7a8c4230	NP	Nepal	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+977	10
d725a52a-22a3-48d6-b035-001c1aa15eae	MY	Malaysia	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+60	9
e341a797-6da6-4427-9bc1-f3271b6882c1	ID	Indonesia	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+62	10
ecb5e362-682e-46d2-bee2-ef0b022ebb13	BD	Bangladesh	t	2026-08-20 17:07:05.749911+05:30	2026-09-02 10:43:48.939145+05:30	\N	\N	\N	+880	10
\.


--
-- Data for Name: mst_departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	core	Core	t	2026-09-02 15:54:51.765975+05:30	\N	\N	\N	\N
f7e882f6-2fa8-45e1-9137-2bc4b70f016a	functional_it_administration	Functional - IT Administration	t	2026-09-02 15:54:51.785918+05:30	\N	\N	\N	\N
bcbd68c8-c3f3-4396-abb0-0b0e13637958	functional_accounts	Functional - Accounts	t	2026-09-02 15:54:51.795991+05:30	\N	\N	\N	\N
310a2f16-15f6-4b82-95f6-ab18b5b429f5	functional_hr	Functional - HR	t	2026-09-02 15:54:51.812471+05:30	\N	\N	\N	\N
13c91c98-00ae-4211-acb8-d06e35953806	functional_sales	Functional - Sales	t	2026-09-02 15:54:51.826882+05:30	\N	\N	\N	\N
8e4e88f1-e294-4554-80cc-92ed6169caeb	functional_project_management	Functional - Project Management	t	2026-09-02 15:54:51.843878+05:30	\N	\N	\N	\N
898c36e9-1cb7-4c56-9148-a3b6893c0149	rd_research_and_development	R&D (Research & Development)	t	2026-09-02 15:54:51.86295+05:30	\N	\N	\N	\N
3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	services_operations	Services - Operations	t	2026-09-02 15:54:51.872711+05:30	\N	\N	\N	\N
be8e036d-ad13-4c79-89ec-294e490a6816	services_consulting	Services - Consulting	t	2026-09-02 15:54:51.907068+05:30	\N	\N	\N	\N
0aed67b8-c454-439a-a07f-4f46d46d58af	services_testing	Services - Testing	t	2026-09-02 15:54:51.926627+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_designations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "SubDepartment", "DefaultRoleId") FROM stdin;
b3c75d81-80a1-4240-8b1e-010000000005	functional_sales_manager	Sales Manager	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	\N	914d8500-03b6-4a43-a250-244effca1cf1
fdd34566-051a-487d-a985-540c2db8c37f	functional_project_management_engagement_manager	Engagement Manager	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 17:21:34.862009+05:30	\N	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89
b3c75d81-80a1-4240-8b1e-010000000001	services_operations_soc_manager	SOC Manager	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	\N	111cc3cd-6d35-43ce-be91-dde90d3d4015
b3c75d81-80a1-4240-8b1e-010000000002	services_operations_soc_sr_manager	SOC Senior Manager	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	\N	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7
b3c75d81-80a1-4240-8b1e-010000000003	services_operations_soc_hod	SOC HOD	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	\N	3d068c2f-d0a1-4045-bad9-0f3a43efec4f
7c2380da-3ee6-46ad-93d6-a79ce3027f29	services_consulting_grc_auditor_iv	GRC Auditor - IV	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.915028+05:30	\N	\N	\N	\N	\N	768a11f9-ded7-4f6f-ba86-073e279255d9
dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	services_consulting_senior_grc_auditor_i	Senior GRC Auditor - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.916903+05:30	\N	\N	\N	\N	\N	701aaa2c-a899-4def-bf5f-e17511874409
3e60b693-d3dd-4481-95c4-9f02da21625c	services_consulting_senior_grc_auditor_ii	Senior GRC Auditor - II	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.91882+05:30	\N	\N	\N	\N	\N	701aaa2c-a899-4def-bf5f-e17511874409
195d6a81-8457-4b60-9382-6a3a0664f0e9	services_consulting_associate_manager_iii	Associate Manager - III	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.920769+05:30	\N	\N	\N	\N	\N	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a
2b1558e3-158a-4a84-ae80-053129861a64	services_consulting_senior_vice_president_principal_consultant	Senior Vice President - Principal Consultant	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.922717+05:30	\N	\N	\N	\N	\N	64c49f37-a38a-46a6-9622-7427f1501658
dadac355-1ddc-457c-935a-d297da3a883d	services_consulting_principal_manager_i	Principal Manager - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.903029+05:30	2026-09-03 12:41:32.975424+05:30	\N	\N	\N	\N	64c49f37-a38a-46a6-9622-7427f1501658
4f972924-350a-47fb-a6b6-f2b34bb6b621	services_testing_pentester_i	PenTester - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.928383+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
0b6ab354-1fcf-4a00-9be3-e58e99c425ed	services_testing_pentester_ii	PenTester - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.930296+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
163d8c87-8f90-4295-a926-2e912c625a1c	services_testing_pentester_iii	PenTester - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.932399+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
9858c224-f97f-4ff8-908d-f46bd5e2243c	services_testing_pentester_iv	PenTester - IV	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.93473+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
632bf06c-f646-4edd-bf2d-e3cd2e034c7f	services_testing_senior_pentester_i	Senior Pentester - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.936785+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	services_testing_senior_pentester_ii	Senior Pentester - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.93907+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
ae255622-ddcc-45ea-a699-8ec416fe57ab	services_testing_devsecops_practitioner_i	DevSecOps Practitioner - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.969279+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
35a6b1af-dc78-4632-a9f4-eedabdbdcb52	services_testing_devsecops_practitioner_ii	DevSecOps Practitioner - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.97275+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
767a00dd-6f09-4f64-a44e-8fbe901222af	services_testing_devsecops_practitioner_iii	DevSecOps Practitioner - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.976579+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
778f1120-9633-4933-9160-ddaa46668838	core_director_and_chief_executive_officer	Director and Chief Executive Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 15:54:51.776662+05:30	\N	\N	\N	\N	\N	62a927b7-9fd8-461a-b64e-1aa441eeba4d
ffed7aa1-e88f-4281-919f-8d49fbabf5a5	core_director_and_chief_operating_officer	Director and Chief Operating Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 15:54:51.781954+05:30	\N	\N	\N	\N	\N	a5bfe265-981a-4723-b7bb-6ddc389db7f0
0525d830-ead9-44a0-871f-91b7845fec26	core_director_and_chief_technology_officer	Director and Chief Technology Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 15:54:51.783926+05:30	\N	\N	\N	\N	\N	66e48815-4d4f-41d0-9c5f-26a7b7ba296c
da990f6e-3379-4cc4-89b7-0ead29da472b	functional_it_admini_it_admin	IT Admin	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 15:54:51.787896+05:30	\N	\N	\N	\N	\N	b552183f-2695-41f9-860e-16d5fe94c4aa
c70b9832-841e-4864-9b85-eaba3c0a995f	functional_it_admini_desktop_support_engineer_i	Desktop Support Engineer - I	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 15:54:51.78998+05:30	\N	\N	\N	\N	\N	b552183f-2695-41f9-860e-16d5fe94c4aa
73bd55bb-5d0e-4381-8ad2-2238377fca93	functional_it_admini_desktop_support_engineer_ii	Desktop Support Engineer - II	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 15:54:51.792134+05:30	\N	\N	\N	\N	\N	b552183f-2695-41f9-860e-16d5fe94c4aa
155642eb-a633-4460-b658-aca9fde2d817	functional_accounts_accountant_i	Accountant - I	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.797934+05:30	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
8dc0d8fe-593d-422a-8b27-5b68fbe6d224	functional_accounts_accountant_ii	Accountant - II	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.799807+05:30	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
6e606c29-2ebf-4ab8-8006-aaedd5680009	functional_accounts_accountant_iii	Accountant - III	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.801711+05:30	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
4ef1cb5b-9688-4ce2-95b3-6a0863200166	functional_accounts_senior_accountant_i	Senior Accountant - I	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.803595+05:30	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
96efad7d-8b7f-4d7f-a862-c0a6bec3789f	functional_accounts_senior_accountant_ii	Senior Accountant - II	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.805714+05:30	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
1f97b442-95c5-4b11-93a0-ea146534ae85	functional_accounts_senior_accountant_iii	Senior Accountant - III	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.807813+05:30	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	functional_hr_hr_head	HR Head	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.814553+05:30	\N	\N	\N	\N	\N	bb568e26-548b-4ca5-9221-fefb9c9143b3
7d542941-65b9-499b-81b3-239748d6da52	functional_hr_recruitment_coordinator_i	Recruitment Coordinator - I	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.8165+05:30	\N	\N	\N	\N	\N	bb568e26-548b-4ca5-9221-fefb9c9143b3
c2e248c8-e917-445f-9f7b-1e25d7bb5abe	functional_hr_recruitment_coordinator_ii	Recruitment Coordinator - II	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.818555+05:30	\N	\N	\N	\N	\N	bb568e26-548b-4ca5-9221-fefb9c9143b3
485012d4-2c28-4bc4-92c7-3609e3e3749e	functional_hr_senior_hr_executive_i	Senior HR Executive - I	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.820547+05:30	\N	\N	\N	\N	\N	bb568e26-548b-4ca5-9221-fefb9c9143b3
e4e20503-cd55-4393-83fd-6c7e7d7d0a49	functional_hr_senior_hr_executive_ii	Senior HR Executive - II	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.8227+05:30	\N	\N	\N	\N	\N	bb568e26-548b-4ca5-9221-fefb9c9143b3
b2b687ef-fd62-4cb7-a826-b40a35da7b2c	functional_sales_business_development_associate_i	Business Development Associate - I	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.828797+05:30	\N	\N	\N	\N	\N	914d8500-03b6-4a43-a250-244effca1cf1
157d001c-b056-45b1-96a3-3c05bcd8d99c	functional_sales_customer_success_representative_ii	Customer Success Representative - II	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.830775+05:30	\N	\N	\N	\N	\N	914d8500-03b6-4a43-a250-244effca1cf1
6193be76-40ad-4973-9ee7-246a4d8f4109	functional_sales_director_product_sales	Director - Product Sales	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.832885+05:30	\N	\N	\N	\N	\N	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
e2c675a7-92dc-4477-be75-9a304cbe4def	functional_sales_sales_associate	Sales Associate	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.83517+05:30	\N	\N	\N	\N	\N	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
272973a6-c052-4aef-bf32-9e24f7eb6cc9	functional_sales_associate_customer_success_representative_i	Associate Customer Success Representative - I	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.837646+05:30	\N	\N	\N	\N	\N	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
7e7d954f-34b5-4c23-8c3f-698ec920e9e4	functional_sales_associate_customer_success_representative_ii	Associate Customer Success Representative - II	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.839641+05:30	\N	\N	\N	\N	\N	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
b3309eea-7374-4a8d-ac13-481b2a7fd492	functional_project_m_associate_pmo_i	Associate PMO - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.845704+05:30	\N	\N	\N	\N	\N	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
2a76927c-461a-48e4-8190-dea7361ef3db	functional_project_m_associate_pmo_ii	Associate PMO - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.847585+05:30	\N	\N	\N	\N	\N	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	functional_project_m_senior_pmo_i	Senior PMO - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.849476+05:30	\N	\N	\N	\N	\N	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
138434a2-625f-4df5-836d-fcf0cfceef79	functional_project_m_senior_pmo_ii	Senior PMO - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.851761+05:30	\N	\N	\N	\N	\N	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
834c9e15-c70d-4a0b-bb12-5e55f23c181d	functional_project_m_delivery_account_manager_i	Delivery Account Manager - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.853646+05:30	\N	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89
d8a2b9e5-f54d-4344-a78d-c6c840467543	functional_project_m_delivery_account_manager_ii	Delivery Account Manager - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.855524+05:30	\N	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89
8b57cfd5-5d4e-44a3-9646-b36873c111c2	functional_project_m_senior_delivery_account_manager_i	Senior Delivery Account Manager - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.857373+05:30	\N	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89
9dc69952-eae6-4ec0-a327-67392315f089	functional_project_m_senior_delivery_account_manager_ii	Senior Delivery Account Manager - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.859188+05:30	\N	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89
f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	rd_research_and_deve_python_developer_i	Python Developer - I	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 15:54:51.864858+05:30	\N	\N	\N	\N	\N	f5c742d1-e0cc-4bf8-b860-a673ac407393
3356f353-1566-4df6-9958-fa01d67d13c7	rd_research_and_deve_python_developer_ii	Python Developer - II	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 15:54:51.866732+05:30	\N	\N	\N	\N	\N	f5c742d1-e0cc-4bf8-b860-a673ac407393
9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	rd_research_and_deve_python_developer_iii	Python Developer - III	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 15:54:51.868943+05:30	\N	\N	\N	\N	\N	f5c742d1-e0cc-4bf8-b860-a673ac407393
6d25ff6d-e13d-440f-b775-215547af7acb	services_operations_soc_analyst_i	SOC Analyst - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.874793+05:30	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
48429bb5-c583-4684-b30a-7ed443b671ca	services_operations_soc_analyst_ii	SOC Analyst - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.876768+05:30	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
f20a7445-0b01-4f20-85a5-853101d864ee	services_operations_soc_analyst_iii	SOC Analyst - III	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.878659+05:30	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
0c1a5ef4-7fca-45dc-8253-87afa21a1df9	services_operations_soc_analyst_iv	SOC Analyst - IV	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.880491+05:30	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
ea315f7d-d597-41b3-a999-4f3851bcd020	services_operations_siem_admin_i	SIEM Admin - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.88251+05:30	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
4650d4e0-f73c-4688-ae5f-830a46348ff9	services_operations_siem_admin_ii	SIEM Admin - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.884354+05:30	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
af8a1442-c5ee-409d-aa91-61c9dba852ee	services_operations_siem_admin_iii	SIEM Admin - III	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.886248+05:30	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	services_operations_soc_consultant_i	SOC Consultant - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.890218+05:30	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
911f6d7f-8d43-40f2-897a-2f416abf8cf9	services_operations_soc_consultant_ii	SOC Consultant - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.892032+05:30	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
e36018c5-bf48-4f93-bef7-93e8864a0b51	services_operations_siem_admin_iv	SIEM Admin - IV	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.888229+05:30	\N	\N	\N	\N	\N	aba61e5b-422a-4461-b9da-8dba8f6d3f85
444df30d-c195-42ad-b9a7-d80cdef69ccd	services_operations_soc_shift_lead_i	SOC Shift Lead - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.894767+05:30	\N	\N	\N	\N	\N	aba61e5b-422a-4461-b9da-8dba8f6d3f85
c0f974c3-f49c-449a-9276-aa64ce501344	services_operations_soc_shift_lead_ii	SOC Shift Lead - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.896662+05:30	\N	\N	\N	\N	\N	aba61e5b-422a-4461-b9da-8dba8f6d3f85
b5f39dd8-c305-489d-9f7d-9adfd010a134	services_operations_soc_lead_i	SOC Lead - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.899202+05:30	\N	\N	\N	\N	\N	111cc3cd-6d35-43ce-be91-dde90d3d4015
eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	services_operations_soc_lead_ii	SOC Lead - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.901107+05:30	\N	\N	\N	\N	\N	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7
1e7faab8-273d-40df-9f9a-485160186c5a	services_consulting_grc_auditor_i	GRC Auditor - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.908929+05:30	\N	\N	\N	\N	\N	768a11f9-ded7-4f6f-ba86-073e279255d9
2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	services_consulting_grc_auditor_ii	GRC Auditor - II	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.910823+05:30	\N	\N	\N	\N	\N	768a11f9-ded7-4f6f-ba86-073e279255d9
8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	services_consulting_grc_auditor_iii	GRC Auditor - III	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.912801+05:30	\N	\N	\N	\N	\N	768a11f9-ded7-4f6f-ba86-073e279255d9
0a60fb48-99c4-44d0-8d97-ff687ccffc9f	services_testing_red_team_practitioner_ii	Red Team Practitioner - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.986648+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
85cc9fbe-98a4-464d-a638-05f40529c6de	services_testing_red_team_practitioner_iii	Red Team Practitioner - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.991312+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
e2b4be77-2b20-4064-974d-e6322e7240b4	services_testing_associate_ai_engineer_contractual	Associate AI Engineer - Contractual	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:52.001242+05:30	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
e228c999-bf54-48b4-a373-d2bc9db88554	services_testing_associate_manager_i	Associate Manager - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.953968+05:30	\N	\N	\N	\N	\N	a3793f87-7f3c-41a1-a675-236fc1b710ab
168d11d7-ca26-4d61-b870-51779dc63023	services_testing_associate_manager_ii	Associate Manager - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.955906+05:30	\N	\N	\N	\N	\N	a3793f87-7f3c-41a1-a675-236fc1b710ab
aaf4ca75-5fa5-4de2-8353-a5e93beecb56	services_testing_associate_manager_iii	Associate Manager - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.957817+05:30	\N	\N	\N	\N	\N	a3793f87-7f3c-41a1-a675-236fc1b710ab
c6c6cd04-6df3-4593-b686-e4b9d362c96f	services_testing_devsecops_associate	DevSecOps Associate	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.980181+05:30	\N	\N	\N	\N	\N	a3793f87-7f3c-41a1-a675-236fc1b710ab
3b7ea453-324e-40a0-bb41-77a0795d5af5	services_testing_associate_project_manager	Associate Project Manager	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.961716+05:30	\N	\N	\N	\N	\N	29ad5710-1621-4c24-ac75-dedfc168ba1a
c1fa4328-a970-48a1-bc08-d50fe36bf44c	services_testing_devsecops_specialist_ii	DevSecOps Specialist - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.983425+05:30	\N	\N	\N	\N	\N	29ad5710-1621-4c24-ac75-dedfc168ba1a
4b680e29-b4fb-4689-9afb-67a7f089f52b	services_testing_red_team_specialist_ii	Red Team Specialist - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.994166+05:30	\N	\N	\N	\N	\N	29ad5710-1621-4c24-ac75-dedfc168ba1a
8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	services_testing_senior_cloud_security_consultant_i	Senior Cloud Security Consultant - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.997244+05:30	\N	\N	\N	\N	\N	29ad5710-1621-4c24-ac75-dedfc168ba1a
a697a798-caaf-4248-8e4e-7e89096a9c30	services_testing_manager_i	Manager - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.966138+05:30	\N	\N	\N	\N	\N	efc1df20-ca04-44a6-87b2-7cae1ff50a88
b3c75d81-80a1-4240-8b1e-010000000004	services_testing_hod	Testing HOD	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	\N	c787fe3b-4b33-40ee-8794-c1148202f81a
f8502c44-b289-49e4-8401-3dcad4d5bbe0	functional_it_admini_intern	Intern	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 15:54:51.794108+05:30	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
caa227a1-2dcf-4195-ab9c-8f76d1862daa	functional_accounts_intern	Intern	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.809802+05:30	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
e8c22eff-0daf-4690-a537-c8b0b6110a01	functional_hr_intern	Intern	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.824863+05:30	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
e2b10def-c91d-45da-94c5-f5530e743aa2	functional_sales_intern	Intern	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.841726+05:30	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
9050e021-7d84-4401-820e-c0e768abb1ab	functional_project_m_intern	Intern	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.861092+05:30	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
bb7ccd5f-2f60-49fb-b984-f11fc47add22	rd_research_and_deve_intern	Intern	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 15:54:51.870785+05:30	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	services_operations_intern	Intern	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.904989+05:30	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
2076a9b1-e432-46a9-99b1-36e732159856	services_consulting_intern	Intern	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.924658+05:30	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
47dbf38f-c022-47bc-8444-d0dfb35ff3fd	services_testing_intern	Intern	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:52.004312+05:30	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
\.


--
-- Data for Name: mst_email_domains; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_email_domains ("Id", "Code", "DomainName", "DisplayName", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
5112286a-225d-4b86-b16f-74211d9c5779	talakunchi_com	talakunchi.com	@talakunchi.com	t	1	2026-08-22 00:42:04.483485+05:30	\N	\N	\N	\N
a19f97e1-8bf5-4b14-823a-b653b62c2954	talakunchi_in	talakunchi.in	@talakunchi.in	t	2	2026-08-22 00:42:04.483485+05:30	\N	\N	\N	\N
fb66fff9-7911-47de-bde7-ab5fb5ab0757	squad1_io	squad1.io	@squad1.io	t	3	2026-08-22 00:42:04.483485+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_employee_statuses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_employee_statuses ("Id", "Code", "Name", "IsActive", "AllowOnboarding", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
26e2b2e5-b1ab-40af-8f6d-2b80deb463a0	absconded	Absconded	t	f	3	2026-09-07 11:33:13.27055+05:30	\N	\N	\N	\N
a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	terminated	Terminated	t	f	2	2026-09-07 11:33:13.27055+05:30	\N	\N	\N	\N
beee234f-c734-4d09-a0bb-96a6cc523cc3	resignation_under_review	Resignation Under Review	t	f	5	2026-09-07 11:33:13.27055+05:30	\N	\N	\N	\N
ce28b4c5-a343-493b-9404-96c983768850	resigned	Resigned	t	f	4	2026-09-07 11:33:13.27055+05:30	\N	\N	\N	\N
e273e2ed-5fd3-4564-bb87-09a71cd4779a	active	Active	t	t	1	2026-09-07 11:33:13.27055+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_entra_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_entra_roles ("Id", "Code", "EntraRoleValue", "PulseRoleName", "DisplayName", "Description", "IsActive", "Priority", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
74306caa-58bf-49de-8751-934a1cb86086	entra_sales	Sales	Sales	Pulse Sales	Customers & repository	t	8	2026-09-01 12:17:03.112068+05:30	2026-09-01 14:46:47.912937+05:30	\N	\N	\N
7de6038e-b19e-443a-959a-9205a73999c5	entra_admin	Admin	Dhanshree	Pulse Admin	Full admin access	t	1	2026-09-01 12:17:03.112068+05:30	2026-09-01 14:46:47.912937+05:30	\N	\N	\N
ae03e32f-220a-4ec7-98ad-6818a75762f1	entra_hr	Hr	Hr	Pulse HR	Resources & repository	t	7	2026-09-01 12:17:03.112068+05:30	2026-09-01 14:46:47.912937+05:30	\N	\N	\N
17f505e3-a99b-4911-9849-4838df7856c4	entra_top_mgmt	Top management	BusinessOwner	Top Management	Executive oversight	t	2	2026-09-01 14:46:47.912937+05:30	\N	\N	\N	\N
1d8a2fce-1693-4293-873d-fe623da70f53	entra_team_member	Team member	Employee	Team Member	Assigned tasks & timesheets	t	6	2026-09-01 14:46:47.912937+05:30	\N	\N	\N	\N
44d89694-653c-47fc-9904-f5eae0ddaab9	entra_senior_pm	Sr. Project manager	SeniorPm	Senior Project Manager	Portfolio delivery & WBS management	t	4	2026-09-01 14:46:47.912937+05:30	\N	\N	\N	\N
8b1843b3-ebd5-4c77-9a86-bbd538f319ad	entra_hod	Head of Department	Hod	Head of Department	Department-wide management	t	3	2026-09-01 14:46:47.912937+05:30	\N	\N	\N	\N
904d9336-2b0e-46bb-ae89-3df0bb146b8b	entra_pm	Project Manager	ProjectManager	Project Manager	Project execution & allocations	t	5	2026-09-01 14:46:47.912937+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_graduation_degrees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
0712499d-fdc0-4a12-8fd7-7284f5531cb3	bs	BS	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
1dc7caa3-b89b-4246-8217-21c6dd59bf4b	bpharm	B.Pharm	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
511beb93-c358-41f3-b39b-463910bf94e6	bcom	B.Com	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
564c3ffb-209d-43bf-ab2f-2ba5d509357e	ba	B.A.	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
62c3218d-a51e-44ab-8fe0-c57d59270448	btech	B.Tech	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
82ce8912-9b37-4b6a-864e-a7327f8749cb	bba	BBA	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
a77f78ff-221e-400c-8b14-0c847b34bc92	bsc	B.Sc	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
ce12fc28-02e3-4f2c-bf7d-53607b188057	bca	BCA	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
e89b166b-ebc0-4132-8170-92ea1e78e9d0	be	BE	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
09e8e464-0642-466a-8ca4-37f3bc37d4d0	be	B.E.	t	2026-09-11 10:58:07.455053+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_industries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
7f460c51-01ec-4da1-8f71-d6f360b56f91	healthcare	Healthcare	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
f175fde9-14f8-40e8-b564-47d8a29d84ff	logistics	Logistics	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
c7e82721-829b-4450-8393-022587178471	energy	Energy	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
4a80bfdb-a191-4ce1-ab51-2142eb366db7	banking	Banking	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
935db8d7-e2aa-417e-839e-b51d00ce951e	retail	Retail	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
e722474e-d845-42b8-978e-91a6ec78f080	manufacturing	Manufacturing	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
ff5e83cc-9c1c-4056-ab0b-42a70714ddd3	media	Media	t	2026-08-20 11:45:51.759149+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dcb2b955-8d33-4b9b-b04a-64208dce1520	telecom	Telecom	t	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
02012f0c-97b2-4aea-a6b4-954ee97d892d	technology	Technology	f	2026-08-18 13:25:36.166597+05:30	2026-09-09 12:55:18.453091+05:30	\N	\N	\N
16ebeb23-b3d8-4fb7-a4f6-789510c28ad3	environment	Environment	f	2026-08-18 13:25:36.166597+05:30	2026-09-09 12:55:18.453091+05:30	\N	\N	\N
3a8e57e7-2f6d-4c84-9428-d11de98078c9	quantum_computing	Quantum Computing	f	2026-08-19 12:02:47.466308+05:30	2026-09-09 12:55:18.453091+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4bf54de4-0e85-4904-a89f-542301b65077	automotive	Automotive	f	2026-08-18 13:25:36.166597+05:30	2026-09-09 12:55:18.453091+05:30	\N	\N	\N
cd116cba-a939-4cb7-bd0f-233019a005b0	finance	Finance	f	2026-08-18 13:25:36.166597+05:30	2026-09-09 12:55:18.453091+05:30	\N	\N	\N
\.


--
-- Data for Name: mst_nationalities; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: mst_offices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_offices ("Id", "Code", "Name", "WorkLocationId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_post_graduation_degrees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
02b11fcf-15dc-438e-857d-fe1df19f925b	me	ME	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
29c8b610-bca4-41b7-8199-960c4907c189	mba	MBA	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
42343c31-3dfa-44e6-a433-5d0c66dcfaf0	na	NA	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
93a0a0ed-91ed-41e3-91c1-09e94f248667	mtech	M.Tech	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
9ea82119-8356-4b91-87ea-aeeb679b9cf6	msc	M.Sc	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
c7bd4e1d-4826-421d-b473-3a926672050e	ma	M.A.	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
e0725237-7a46-48ee-9ff1-3969f2571d2a	mcom	M.Com	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
e2722a3d-0767-4299-afa9-04d89c28cd7c	mca	MCA	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
ec8299cf-acb1-4a26-aed5-a03db0ff8bfe	ms	MS	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_reporting_managers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_reporting_managers ("Id", "Code", "Name", "Designation", "Email", "EmployeeId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
03bff38b-8821-43f1-bb81-f35828f60d36	vikram_gupta	Vikram Gupta	Project Manager	vikram.gupta@acme.co	\N	t	11	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
2b340512-4fbe-4617-a382-b8b78d2b461b	akash_jain	Akash Jain	Intern	akash.jain@acme.co	00000000-0000-4000-8000-000000000058	t	2	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
4545c5d5-d7b2-422f-bc88-41df240f7df5	ankit_verma	Ankit Verma	SOC Analyst - II	ankit.verma@acme.co	00000000-0000-4000-8000-000000000023	t	4	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
6894730f-d48f-4358-9cb0-faaa2815c0a3	arjun_singh	Arjun Singh	PenTester - II	arjun@acme.co	00000000-0000-4000-8000-000000000046	t	5	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
6b8c33c8-de5a-4597-bd9d-10e6a95a733d	ayush_saxena	Ayush Saxena	Intern	ayush.saxena@acme.co	00000000-0000-4000-8000-000000000053	t	6	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
7e6d4426-74c1-406a-8ffd-b47871864b01	aditya_reddy	Aditya Reddy	SIEM Admin - II	aditya.reddy@acme.co	00000000-0000-4000-8000-000000000024	t	1	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
8771b8d4-89aa-4d73-bd2a-4d91b6404a34	harsh_nair	Harsh Nair	Business Analyst	harsh.nair@acme.co	\N	t	10	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
8b1f5eb8-065a-4478-bf63-4d3fbcccf70b	pooja_menon	Pooja Menon	HR Business Partner	pooja.menon@acme.co	\N	t	12	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
b4309d40-951c-4f5b-809e-6cdfb96b0ffe	neha_kulkarni	Neha Kulkarni	Technical Lead	neha.kulkarni@acme.co	\N	t	7	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
bcd78a5a-de09-4e6b-9f00-50a54e908730	aanya_joshi	Aanya Joshi	Sales Executive	aanya.joshi@acme.co	\N	t	9	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
e64c27f7-a329-4990-b997-d0041198cf59	arjun_mehta	Arjun Mehta	Engagement Manager	arjun.mehta@acme.co	\N	t	15	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
e78fc289-2042-4f04-a9d3-0bfc53aae714	ananya_verma	Ananya Verma	Intern	ananya.verma@acme.co	00000000-0000-4000-8000-000000000050	t	3	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
f91f1020-3ec7-4c16-9aee-9bee2124a465	rahul_sharma	Rahul Sharma	Engagement Manager	rahul.sharma@acme.co	\N	t	14	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
faf18318-d2a6-42a5-a143-e1ef7f9446f4	samar_patel	Samar Patel	HR Business Partner	samar.patel@acme.co	\N	t	8	2026-09-24 17:58:46.094618+05:30	\N	\N	\N	\N
4deb2755-7447-4514-b05a-bdd25d92f201	naveen_choudhary	Naveen Choudhary	Intern	naveen.choudhary@acme.co	00000000-0000-4000-8000-000000000055	t	5	2026-09-24 19:22:57.235573+05:30	\N	\N	\N	\N
769797b2-6d9a-415d-8924-0659deaf05c5	pooja_nair	Pooja Nair	SOC Analyst - III	pooja.nair@acme.co	00000000-0000-4000-8000-000000000026	t	6	2026-09-24 19:22:57.235573+05:30	\N	\N	\N	\N
8a5a0f48-7f36-493e-b1e0-4de9dcd5e51c	manish_tiwari	Manish Tiwari	SOC Consultant - I	manish.tiwari@acme.co	00000000-0000-4000-8000-000000000025	t	2	2026-09-24 19:22:57.235573+05:30	\N	\N	\N	\N
ad22b311-5f77-4f4f-a567-662dd7c63151	meera_nambiar	Meera Nambiar	GRC Auditor - II	meera.nambiar@acme.co	00000000-0000-4000-8000-000000000033	t	4	2026-09-24 19:22:57.235573+05:30	\N	\N	\N	\N
be305e61-b80d-4b93-b858-dd868d1bd835	meera_joshi	Meera Joshi	DevSecOps Practitioner - I	meera@acme.co	00000000-0000-4000-8000-000000000047	t	3	2026-09-24 19:22:57.235573+05:30	\N	\N	\N	\N
f5fc991e-50c0-4c7f-98f3-00c8066eee89	kunal_mehra	Kunal Mehra	Intern	kunal.mehra@acme.co	00000000-0000-4000-8000-000000000059	t	1	2026-09-24 19:22:57.235573+05:30	\N	\N	\N	\N
11a665b8-4f3c-4cd7-9c96-2ced933ab354	rajat_singhal	Rajat Singhal	GRC Auditor - III	rajat.singhal@acme.co	00000000-0000-4000-8000-000000000034	t	3	2026-09-25 09:57:46.284354+05:30	\N	\N	\N	\N
1e9153c0-a023-456d-b341-ac4e2d8d23a1	rohit_verma	Rohit Verma	Associate Customer Success Representative - I	rohit.verma@acme.co	00000000-0000-4000-8000-000000000010	t	5	2026-09-25 09:57:46.284354+05:30	\N	\N	\N	\N
289b6466-1e8d-4083-86b2-2731047b3ffc	pooja_sharma	Pooja Sharma	Sales Associate	pooja.sharma@acme.co	00000000-0000-4000-8000-000000000009	t	1	2026-09-25 09:57:46.284354+05:30	\N	\N	\N	\N
57925ef2-bc23-461d-a9d5-1ad4be938cd0	rohan_joshi	Rohan Joshi	Intern	rohan.joshi@acme.co	00000000-0000-4000-8000-000000000051	t	4	2026-09-25 09:57:46.284354+05:30	\N	\N	\N	\N
c5d6bcd4-445c-46aa-bb33-7497adbd6c46	priya_sharma	Priya Sharma	PenTester - I	priya.sharma@acme.co	00000000-0000-4000-8000-000000000045	t	2	2026-09-25 09:57:46.284354+05:30	\N	\N	\N	\N
e44a4f7f-1f76-4325-bc10-58812b22d865	simran_kaur	Simran Kaur	Intern	simran.kaur@acme.co	00000000-0000-4000-8000-000000000054	t	6	2026-09-25 09:57:46.284354+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000101	vikrant_malhotra	Vikrant Malhotra	Director and Chief Executive Officer	vikrant@acme.co	00000000-0000-4000-8000-000000000001	t	1	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000102	dhanshree_pansare	Dhanshree Pansare	Director and Chief Operating Officer	dhanshree@acme.co	00000000-0000-4000-8000-000000000002	t	2	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000103	kunal_deshmukh	Kunal Deshmukh	Director and Chief Technology Officer	kunal.deshmukh@acme.co	00000000-0000-4000-8000-000000000003	t	3	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000104	admin_user	Admin User	IT Admin	admin@acme.co	00000000-0000-4000-8000-000000000004	t	4	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000105	accounts_user	Accounts User	Senior Accountant - I	accounts@acme.co	00000000-0000-4000-8000-000000000005	t	5	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000106	hr_user	HR User	HR Head	hr@acme.co	00000000-0000-4000-8000-000000000006	t	6	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000107	sales_user	Sales User	Sales Manager	sales@acme.co	00000000-0000-4000-8000-000000000007	t	7	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000112	rahul_gupta	Rahul Gupta	Senior PMO - I	rahul@acme.co	00000000-0000-4000-8000-000000000012	t	8	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000113	riya_kapoor	Riya Kapoor	Engagement Manager	riya@acme.co	00000000-0000-4000-8000-000000000013	t	9	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000114	pradeep_singh	Pradeep Singh	Engagement Manager	pradeep.singh@acme.co	00000000-0000-4000-8000-000000000014	t	10	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000115	kavya_desai	Kavya Desai	Python Developer - II	kavya.desai@acme.co	00000000-0000-4000-8000-000000000015	t	11	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000116	rajesh_kadam	Rajesh Kadam	SOC HOD	rajesh.kadam@acme.co	00000000-0000-4000-8000-000000000016	t	12	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000117	deepak_sawant	Deepak Sawant	SOC Senior Manager	deepak.sawant@acme.co	00000000-0000-4000-8000-000000000017	t	13	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000118	vikram_shah	Vikram Shah	SOC Manager	vikram@acme.co	00000000-0000-4000-8000-000000000018	t	14	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000119	sneha_iyer	Sneha Iyer	SOC Lead - I	sneha.iyer@acme.co	00000000-0000-4000-8000-000000000019	t	15	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000120	nikhil_rao	Nikhil Rao	SOC Lead - II	nikhil@acme.co	00000000-0000-4000-8000-000000000020	t	16	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000121	amit_pandey	Amit Pandey	SOC Shift Lead - I	amit.pandey@acme.co	00000000-0000-4000-8000-000000000021	t	17	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000127	anita_desai	Anita Desai	Senior Vice President - Principal Consultant	anita@acme.co	00000000-0000-4000-8000-000000000027	t	18	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000128	aarav_mehta	Aarav Mehta	Principal Manager - I	aarav@acme.co	00000000-0000-4000-8000-000000000028	t	19	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000129	sana_iyer	Sana Iyer	Associate Manager - III	sana@acme.co	00000000-0000-4000-8000-000000000029	t	20	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000130	priya_verma	Priya Verma	Senior GRC Auditor - I	priya@acme.co	00000000-0000-4000-8000-000000000030	t	21	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000131	siddharth_roy	Siddharth Roy	Senior GRC Auditor - II	siddharth.roy@acme.co	00000000-0000-4000-8000-000000000031	t	22	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000137	girish_shenoy	Girish Shenoy	Testing HOD	girish.shenoy@acme.co	00000000-0000-4000-8000-000000000037	t	23	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000138	suresh_pillai	Suresh Pillai	Manager - I	suresh.pillai@acme.co	00000000-0000-4000-8000-000000000038	t	24	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000139	alok_kumar	Alok Kumar	Associate Manager - III	alok.kumar@acme.co	00000000-0000-4000-8000-000000000039	t	25	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000140	divya_rao	Divya Rao	Associate Project Manager	divya.rao@acme.co	00000000-0000-4000-8000-000000000040	t	26	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000141	manoj_bhatt	Manoj Bhatt	DevSecOps Specialist - II	manoj.bhatt@acme.co	00000000-0000-4000-8000-000000000041	t	27	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000142	gaurav_joshi	Gaurav Joshi	DevSecOps Associate	gaurav.joshi@acme.co	00000000-0000-4000-8000-000000000042	t	28	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000143	kiran_mathur	Kiran Mathur	Associate Manager - I	kiran.mathur@acme.co	00000000-0000-4000-8000-000000000043	t	29	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
00000000-0000-4000-8000-000000000144	ramesh_nair	Ramesh Nair	Associate Manager - II	ramesh.nair@acme.co	00000000-0000-4000-8000-000000000044	t	30	2026-09-24 16:50:42.604481+05:30	\N	\N	\N	\N
06e8e00e-07d8-41b7-8394-251af95d23a8	kavya_nair	Kavya Nair	Senior Pentester - I	kavya@acme.co	00000000-0000-4000-8000-000000000049	t	6	2026-09-24 18:23:42.49824+05:30	\N	\N	\N	\N
0874c210-56b2-483b-a1f8-53e35862e086	ira_kapoor	Ira Kapoor	GRC Auditor - I	ira.kapoor@acme.co	00000000-0000-4000-8000-000000000032	t	4	2026-09-24 18:23:42.49824+05:30	\N	\N	\N	\N
1b29b7b1-5c2f-4b2b-9a72-a05cb3f063e6	karthik_bose	Karthik Bose	SOC Analyst - I	karthik.bose@acme.co	00000000-0000-4000-8000-000000000022	t	5	2026-09-24 18:23:42.49824+05:30	\N	\N	\N	\N
2d3bd4d9-52e5-4760-a0b1-4d786d4c75d2	bhavna_patel	Bhavna Patel	Intern	bhavna.patel@acme.co	00000000-0000-4000-8000-000000000056	t	1	2026-09-24 18:23:42.49824+05:30	\N	\N	\N	\N
aa054bdc-7cb5-4c0c-988d-96b595911c13	harsh_wardhan	Harsh Wardhan	Intern	harsh.wardhan@acme.co	00000000-0000-4000-8000-000000000057	t	3	2026-09-24 18:23:42.49824+05:30	\N	\N	\N	\N
b7220d2c-af72-4d9a-891c-0faca2cbda5f	dev_patel	Dev Patel	Red Team Practitioner - II	dev@acme.co	00000000-0000-4000-8000-000000000048	t	2	2026-09-24 18:23:42.49824+05:30	\N	\N	\N	\N
11906d76-178a-41d4-b4e8-bbb7bba3fb44	sneha_reddy	Sneha Reddy	Associate Customer Success Representative - II	sneha.reddy@acme.co	00000000-0000-4000-8000-000000000011	t	1	2026-09-25 20:33:39.729846+05:30	\N	\N	\N	\N
40f0a119-fb06-4845-8869-c633c952e4c8	tanvi_deshmukh	Tanvi Deshmukh	Intern	tanvi.deshmukh@acme.co	00000000-0000-4000-8000-000000000052	t	3	2026-09-25 20:33:39.729846+05:30	\N	\N	\N	\N
7a1c3f03-4f4d-4613-8fb7-b72e4fd8ff8d	varun_saxena	Varun Saxena	GRC Auditor - I	varun.saxena@acme.co	00000000-0000-4000-8000-000000000036	t	4	2026-09-25 20:33:39.729846+05:30	\N	\N	\N	\N
f34456d6-038f-4283-9916-8f0e2de7f3fa	swati_mishra	Swati Mishra	GRC Auditor - IV	swati.mishra@acme.co	00000000-0000-4000-8000-000000000035	t	2	2026-09-25 20:33:39.729846+05:30	\N	\N	\N	\N
a07dfbd5-cdc1-4da9-b354-1229dec56728	nikhil_khanna	Nikhil Khanna	Sales Executive	nikhil.khanna@acme.co	00000000-0000-4000-8000-000000000008	t	13	2026-09-24 17:58:46.094618+05:30	2026-09-27 14:45:08.812603+05:30	\N	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	\N
\.


--
-- Data for Name: mst_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
6032fef5-eb05-42bd-9f10-72f12e154243	services_operations_soc_shift_lead_i_team_leader_tl_	Team Leader (TL)	t	444df30d-c195-42ad-b9a7-d80cdef69ccd	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
8366d816-724b-456b-9d0e-85399c2324b7	services_operations_soc_lead_i_team_leader_tl_	Team Leader (TL)	t	b5f39dd8-c305-489d-9f7d-9adfd010a134	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
412826f2-67b6-47c9-a62c-270fa9425ce4	functional_sales_director_product_sales_team_member_tm_	Team Member (TM)	t	6193be76-40ad-4973-9ee7-246a4d8f4109	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
d0b9d2a2-d79c-4097-ae63-4bff14436d0a	functional_sales_sales_associate_team_member_tm_	Team Member (TM)	t	e2c675a7-92dc-4477-be75-9a304cbe4def	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
1c1c9112-592b-4f23-92d5-213a5da0d78d	functional_it_admini_desktop_support_engineer_i_team_member_tm_	Team Member (TM)	t	c70b9832-841e-4864-9b85-eaba3c0a995f	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
16f2557a-02c9-4208-a570-55a909532abe	functional_accounts_senior_accountant_ii_manager_mng_	Manager (Mng.)	t	96efad7d-8b7f-4d7f-a862-c0a6bec3789f	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
3efb18e5-f8d5-4de9-8959-ab5401f64b74	services_consulting_grc_auditor_iv_team_member_tm_	Team Member (TM)	t	7c2380da-3ee6-46ad-93d6-a79ce3027f29	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
40354601-9ac5-41e0-9ddb-6603e5614a86	services_consulting_grc_auditor_iii_team_member_tm_	Team Member (TM)	t	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
6886e92b-a2c5-4057-9330-47394a2aac65	services_consulting_grc_auditor_ii_team_member_tm_	Team Member (TM)	t	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
cc4e4c23-fccc-44ba-8423-5e4e6ec35731	functional_hr_recruitment_coordinator_ii_hr	HR	t	c2e248c8-e917-445f-9f7b-1e25d7bb5abe	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
21eac166-3ba7-40c5-a780-bbc7b3e96ddb	functional_sales_associate_customer_success_representative_ii_team_member_tm_	Team Member (TM)	t	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
db77e167-7f67-43f6-9e2d-4ebaf6f9f802	functional_project_m_delivery_account_manager_ii_team_member_tm_	Team Member (TM)	t	d8a2b9e5-f54d-4344-a78d-c6c840467543	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
6c0bebbb-cc4d-4433-83e9-d65fb5291d75	services_consulting_intern_team_member_tm_	Team Member (TM)	t	2076a9b1-e432-46a9-99b1-36e732159856	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
913e691d-e3f9-4f9a-aab8-57eda52a8cd6	functional_it_admini_desktop_support_engineer_ii_team_member_tm_	Team Member (TM)	t	73bd55bb-5d0e-4381-8ad2-2238377fca93	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
1e17c9f0-a8ed-4d89-819d-738a84af4e48	functional_hr_senior_hr_executive_ii_hr	HR	t	e4e20503-cd55-4393-83fd-6c7e7d7d0a49	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
ea40e2b6-035a-4766-96bc-13ad013020c1	services_operations_soc_analyst_iv_team_member_tm_	Team Member (TM)	t	0c1a5ef4-7fca-45dc-8253-87afa21a1df9	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
401a442f-98c4-4b95-9e07-647853bf9122	rd_research_and_deve_python_developer_ii_team_member_tm_	Team Member (TM)	t	3356f353-1566-4df6-9958-fa01d67d13c7	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
52ae8b5b-80b3-4d14-b8c5-0bc40e1f4bee	services_consulting_associate_manager_iii_manager_mng_	Manager (Mng.)	t	195d6a81-8457-4b60-9382-6a3a0664f0e9	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
31ebb23e-f7d1-4c01-859b-67d24e96e2fb	services_operations_soc_lead_ii_team_leader_tl_	Team Leader (TL)	t	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
24ccdefb-8dd5-411e-8b2e-af8fb743a3cb	services_operations_soc_consultant_i_team_member_tm_	Team Member (TM)	t	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
8ea442c3-8ed7-4b6a-a3db-dd74706e9cce	services_testing_devsecops_practitioner_ii_team_member_tm_	Team Member (TM)	t	35a6b1af-dc78-4632-a9f4-eedabdbdcb52	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
218cd458-a6bc-43f8-8eda-02c89193fc35	services_operations_soc_shift_lead_ii_team_leader_tl_	Team Leader (TL)	t	c0f974c3-f49c-449a-9276-aa64ce501344	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
6c1b3c1d-4159-41b9-9171-1e4f2501cc32	functional_project_m_intern_team_member_tm_	Team Member (TM)	t	9050e021-7d84-4401-820e-c0e768abb1ab	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
da46be38-b216-44cc-8b6d-70cd4b0aea8e	services_operations_siem_admin_iv_team_member_tm_	Team Member (TM)	t	e36018c5-bf48-4f93-bef7-93e8864a0b51	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
33f2483b-b264-4ec4-857a-205426a8af0f	functional_accounts_accountant_i_manager_mng_	Manager (Mng.)	t	155642eb-a633-4460-b658-aca9fde2d817	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
48079f83-fbf9-4639-ae6b-263ca3fb752a	functional_project_m_associate_pmo_i_team_member_tm_	Team Member (TM)	t	b3309eea-7374-4a8d-ac13-481b2a7fd492	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
da59e567-3ee0-4a98-9b1e-83f8e6c01e2c	services_testing_associate_manager_i_team_leader_tl_	Team Leader (TL)	t	e228c999-bf54-48b4-a373-d2bc9db88554	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
1d19d6af-78b4-45ef-bcb3-db1b3896f153	services_operations_intern_team_member_tm_	Team Member (TM)	t	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
446498d0-e9e6-4dbb-8fbe-b87bb853a2af	functional_project_m_senior_pmo_i_team_leader_tl_	Team Leader (TL)	t	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
6b361aa9-a47a-4fed-9d1f-07a4e1dd5f30	functional_hr_recruitment_coordinator_i_hr	HR	t	7d542941-65b9-499b-81b3-239748d6da52	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
c7d75b92-f6e2-4dd7-a726-ae662ee83c95	functional_hr_hr_head_hr	HR	t	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
5378a1ad-7ab3-40e5-9048-5165efab2140	services_testing_senior_pentester_ii_team_member_tm_	Team Member (TM)	t	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
a3d0a1e1-b4a8-4ae5-8577-cd2019268494	services_testing_associate_manager_iii_manager_mng_	Manager (Mng.)	t	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
22215465-c056-4ba4-a867-23ed37658a09	services_consulting_senior_grc_auditor_i_team_leader_tl_	Team Leader (TL)	t	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
9c970783-5b89-4fd0-b3f3-1c1953a853ab	services_operations_soc_analyst_ii_team_member_tm_	Team Member (TM)	t	48429bb5-c583-4684-b30a-7ed443b671ca	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
4e547334-4964-4dbe-81a4-a316d9394d03	services_testing_devsecops_practitioner_i_team_member_tm_	Team Member (TM)	t	ae255622-ddcc-45ea-a699-8ec416fe57ab	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
57b9b89d-9123-4bd0-b8fd-a373e0648f43	functional_project_m_senior_delivery_account_manager_i_team_leader_tl_	Team Leader (TL)	t	8b57cfd5-5d4e-44a3-9646-b36873c111c2	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
8ab74d70-fc77-4767-87ce-13a6d3f911ce	services_testing_senior_cloud_security_consultant_i_manager_mng_	Manager (Mng.)	t	8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
859254f8-a1b4-4812-b1d0-aacf111f7235	rd_research_and_deve_intern_team_member_tm_	Team Member (TM)	t	bb7ccd5f-2f60-49fb-b984-f11fc47add22	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
70206c08-0203-4784-8b09-d04d0cff95af	services_testing_devsecops_practitioner_iii_team_member_tm_	Team Member (TM)	t	767a00dd-6f09-4f64-a44e-8fbe901222af	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
f37fa8d5-1c48-4038-95d5-cd7dfea12085	functional_accounts_senior_accountant_i_manager_mng_	Manager (Mng.)	t	4ef1cb5b-9688-4ce2-95b3-6a0863200166	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
3f413c39-a269-4d44-9f3c-9e7f6e3ecced	services_operations_soc_analyst_iii_team_member_tm_	Team Member (TM)	t	f20a7445-0b01-4f20-85a5-853101d864ee	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
178985be-3d47-4903-983b-3a581e788e61	services_operations_siem_admin_iii_team_member_tm_	Team Member (TM)	t	af8a1442-c5ee-409d-aa91-61c9dba852ee	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
c45f4397-0370-43f5-98c7-f419234fa6d8	services_testing_red_team_practitioner_iii_team_member_tm_	Team Member (TM)	t	85cc9fbe-98a4-464d-a638-05f40529c6de	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
ebdc343e-9f43-4715-8a37-4861594c4b0a	functional_hr_senior_hr_executive_i_hr	HR	t	485012d4-2c28-4bc4-92c7-3609e3e3749e	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
98e28e22-95e4-41ee-9178-2912de24f21a	functional_accounts_intern_team_member_tm_	Team Member (TM)	t	caa227a1-2dcf-4195-ab9c-8f76d1862daa	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
568997bf-75a1-46d9-9bdb-6fc05c3b2be1	services_testing_pentester_iii_team_member_tm_	Team Member (TM)	t	163d8c87-8f90-4295-a926-2e912c625a1c	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
20d077b9-894b-4bf3-b491-5df765e645f0	services_testing_associate_manager_ii_team_leader_tl_	Team Leader (TL)	t	168d11d7-ca26-4d61-b870-51779dc63023	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
5a206a6a-dabc-4dfe-b28f-00cc01bc11da	services_testing_red_team_practitioner_ii_team_member_tm_	Team Member (TM)	t	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
074ea1a8-d519-4cda-87a4-978cd1eec45a	services_consulting_grc_auditor_i_team_member_tm_	Team Member (TM)	t	1e7faab8-273d-40df-9f9a-485160186c5a	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
61cc6cff-4f61-4a1d-90f5-9eb9f61c54f3	services_consulting_principal_manager_i_sr_manager_sr_mng_	Sr. Manager (Sr.Mng.)	t	dadac355-1ddc-457c-935a-d297da3a883d	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
95337b72-6733-48f5-ba8c-cd2afbcbc1e4	functional_accounts_accountant_ii_manager_mng_	Manager (Mng.)	t	8dc0d8fe-593d-422a-8b27-5b68fbe6d224	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
3e28d4a4-7d87-41ed-b921-a39dd937df76	functional_sales_associate_customer_success_representative_i_team_member_tm_	Team Member (TM)	t	272973a6-c052-4aef-bf32-9e24f7eb6cc9	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
b4e88d70-1263-47af-96a9-203ee422e8b1	services_operations_soc_consultant_ii_team_member_tm_	Team Member (TM)	t	911f6d7f-8d43-40f2-897a-2f416abf8cf9	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
9fb9b5b5-bc14-4597-8953-7a1ea10dc0dd	functional_project_m_delivery_account_manager_i_team_member_tm_	Team Member (TM)	t	834c9e15-c70d-4a0b-bb12-5e55f23c181d	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
111000c1-ff0c-499c-a9cb-34febe2ac32d	services_testing_devsecops_associate_team_leader_tl_	Team Leader (TL)	t	c6c6cd04-6df3-4593-b686-e4b9d362c96f	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
ee402c9b-252b-4eec-8880-7a4a159eac92	rd_research_and_deve_python_developer_iii_team_member_tm_	Team Member (TM)	t	9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
f43fddea-4dd9-4603-a79c-1710224115ae	functional_it_admini_intern_team_member_tm_	Team Member (TM)	t	f8502c44-b289-49e4-8401-3dcad4d5bbe0	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
94fc014e-37ce-4eb4-8588-ff56a79be98e	core_director_and_chief_executive_officer_leader_l_	Leader (L)	t	778f1120-9633-4933-9160-ddaa46668838	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
3000065e-1037-4a6b-a87a-4c461a756531	services_operations_siem_admin_i_team_member_tm_	Team Member (TM)	t	ea315f7d-d597-41b3-a999-4f3851bcd020	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
1cf32162-d510-4a26-a017-e2035425dc93	functional_project_m_senior_pmo_ii_manager_mng_	Manager (Mng.)	t	138434a2-625f-4df5-836d-fcf0cfceef79	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
6b840581-65b6-4e1d-916f-38b6018e07e0	services_consulting_senior_vice_president_principal_consultant_head_of_departmen	Head Of Department (HOD)	t	2b1558e3-158a-4a84-ae80-053129861a64	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
0b340900-7bd0-4931-8978-832c678c7cbd	functional_sales_intern_team_member_tm_	Team Member (TM)	t	e2b10def-c91d-45da-94c5-f5530e743aa2	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
4e574ffd-c3a9-4a15-832a-5dabfb352dc3	services_consulting_senior_grc_auditor_ii_team_leader_tl_	Team Leader (TL)	t	3e60b693-d3dd-4481-95c4-9f02da21625c	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
8ec384d1-5b99-45c9-a95d-8f3325f56ea4	services_testing_associate_manager_iii_team_leader_tl_	Team Leader (TL)	t	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
a3986a0e-d20f-4f20-a648-adcc724bb622	services_testing_manager_i_sr_manager_sr_mng_	Sr. Manager (Sr.Mng.)	t	a697a798-caaf-4248-8e4e-7e89096a9c30	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
86a621fc-db0d-4e12-96c5-2af111964ef5	services_consulting_associate_manager_iii_team_leader_tl_	Team Leader (TL)	t	195d6a81-8457-4b60-9382-6a3a0664f0e9	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
fdf924c8-3a4a-40bb-9bf9-ea42d4946ecb	rd_research_and_deve_python_developer_i_team_member_tm_	Team Member (TM)	t	f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
fc382efa-48c8-4cc3-a724-2e54c1d6d6e0	services_testing_associate_ai_engineer_contractual_team_member_tm_	Team Member (TM)	t	e2b4be77-2b20-4064-974d-e6322e7240b4	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
9225698b-9ecd-4dfb-9008-fe08b395efc9	functional_accounts_senior_accountant_iii_manager_mng_	Manager (Mng.)	t	1f97b442-95c5-4b11-93a0-ea146534ae85	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
a583ec5f-f30a-4b03-9e35-6afc3f1aee8d	services_testing_devsecops_specialist_ii_manager_mng_	Manager (Mng.)	t	c1fa4328-a970-48a1-bc08-d50fe36bf44c	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
3dd672a7-e6a9-42c8-bdbf-4d1340efc1da	core_director_and_chief_operating_officer_leader_l_	Leader (L)	t	ffed7aa1-e88f-4281-919f-8d49fbabf5a5	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
736d1ddd-c56a-4c4f-b266-bc4f6be6ed9c	services_testing_senior_pentester_i_team_member_tm_	Team Member (TM)	t	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
b3a66833-fc6b-4bac-9438-959333107d3c	functional_project_m_senior_delivery_account_manager_ii_manager_mng_	Manager (Mng.)	t	9dc69952-eae6-4ec0-a327-67392315f089	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
c0cdbff8-5ed6-4e49-a562-549aecaacfd7	services_testing_red_team_specialist_ii_manager_mng_	Manager (Mng.)	t	4b680e29-b4fb-4689-9afb-67a7f089f52b	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
4ca2ade8-8da6-46d7-a7ec-1124e0229d9e	functional_accounts_accountant_iii_manager_mng_	Manager (Mng.)	t	6e606c29-2ebf-4ab8-8006-aaedd5680009	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
9de62ea5-b7da-4a55-8b54-056fdf6bc621	functional_sales_business_development_associate_i_manager_mng_	Manager (Mng.)	t	b2b687ef-fd62-4cb7-a826-b40a35da7b2c	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
eaa98dba-df5b-4b1d-b2d5-20b159a0a070	services_operations_soc_analyst_i_team_member_tm_	Team Member (TM)	t	6d25ff6d-e13d-440f-b775-215547af7acb	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
2cd464a5-b857-46fc-89ea-5dea92640964	services_testing_pentester_ii_team_member_tm_	Team Member (TM)	t	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
0997a260-4ca3-4eb2-b87a-4bd6bf235677	services_operations_siem_admin_ii_team_member_tm_	Team Member (TM)	t	4650d4e0-f73c-4688-ae5f-830a46348ff9	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
eda2ca5a-d2b1-45db-94cc-4575f0eda8dc	functional_it_admini_it_admin_team_member_tm_	Team Member (TM)	t	da990f6e-3379-4cc4-89b7-0ead29da472b	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
7b597cd0-0153-4ddb-a7b2-f553cbafc8a9	functional_sales_customer_success_representative_ii_manager_mng_	Manager (Mng.)	t	157d001c-b056-45b1-96a3-3c05bcd8d99c	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
caec3c96-23a0-4e88-845c-05f792d0dd0c	services_testing_associate_project_manager_manager_mng_	Manager (Mng.)	t	3b7ea453-324e-40a0-bb41-77a0795d5af5	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
a955782d-de73-4939-94f8-5cbf9a2461c2	services_testing_pentester_i_team_member_tm_	Team Member (TM)	t	4f972924-350a-47fb-a6b6-f2b34bb6b621	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
7bd6b8a7-be33-43ba-b4d7-4d290e71b91e	functional_hr_intern_team_member_tm_	Team Member (TM)	t	e8c22eff-0daf-4690-a537-c8b0b6110a01	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
0028e31d-d2ff-4a71-b5b2-5f0566961d46	core_director_and_chief_technology_officer_leader_l_	Leader (L)	t	0525d830-ead9-44a0-871f-91b7845fec26	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
32d7cead-40d2-4d94-89fb-3e48d4160b7c	services_testing_intern_team_member_tm_	Team Member (TM)	t	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
3db9d726-85c9-4714-8c95-b5c6ebd45fd4	services_testing_pentester_iv_team_member_tm_	Team Member (TM)	t	9858c224-f97f-4ff8-908d-f46bd5e2243c	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
f67d5930-703b-4497-a4ea-2add60f7fb58	functional_project_m_associate_pmo_ii_team_member_tm_	Team Member (TM)	t	2a76927c-461a-48e4-8190-dea7361ef3db	2026-09-03 17:25:46.803606+05:30	\N	\N	\N	\N
b3c75d81-80a1-4240-8b1e-020000000001	services_operations_soc_manager_manager_mng_	Manager (Mng.)	t	b3c75d81-80a1-4240-8b1e-010000000001	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N
b3c75d81-80a1-4240-8b1e-020000000002	services_operations_soc_sr_manager_sr_manager_sr_mng_	Sr. Manager (Sr.Mng.)	t	b3c75d81-80a1-4240-8b1e-010000000002	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N
b3c75d81-80a1-4240-8b1e-020000000003	services_operations_soc_hod_head_of_department_hod_	Head Of Department (HOD)	t	b3c75d81-80a1-4240-8b1e-010000000003	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N
b3c75d81-80a1-4240-8b1e-020000000004	services_testing_hod_head_of_department_hod_	Head Of Department (HOD)	t	b3c75d81-80a1-4240-8b1e-010000000004	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N
b3c75d81-80a1-4240-8b1e-020000000005	functional_sales_manager_manager_mng_	Manager (Mng.)	t	b3c75d81-80a1-4240-8b1e-010000000005	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_salary_bands; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_salary_bands ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
20ffbe9b-96ca-496e-ab2e-50ccf3c91246	l3	L3	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
37016f9a-2474-400d-99ae-18157aaad035	l1	L1	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	l4	L4	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
e5f5511b-dea6-421c-8c0e-b271e4ee5d43	l5	L5	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
ebed343e-301f-4984-b292-fa8d1cb1623c	l2	L2	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_service_catalog; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_catalog ("Id", "Code", "Name", "SubDepartmentId", "DefaultTools", "DefaultUnitPrice", "DefaultDurationDays", "Description", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
d0000001-0000-0000-0000-000000000001	PT001	External Network Penetration Testing	c0000001-0000-0000-0000-000000000001	Nessus, Metasploit	60000.00	5	\N	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000002-0000-0000-0000-000000000002	PT002	Internal Network Penetration Testing	c0000001-0000-0000-0000-000000000001	Burp Suite, Cobalt Strike	75000.00	6	\N	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000003-0000-0000-0000-000000000003	PT003	Web Application Penetration Testing	c0000002-0000-0000-0000-000000000002	Burp Suite, OWASP ZAP	50000.00	5	\N	t	3	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000004-0000-0000-0000-000000000004	PT004	Mobile Application Penetration Testing	c0000003-0000-0000-0000-000000000003	Frida, Burp Suite Mobile	55000.00	5	\N	t	4	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000005-0000-0000-0000-000000000005	PT005	API Penetration Testing	c0000004-0000-0000-0000-000000000004	Postman, Burp Suite	40000.00	4	\N	t	5	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000006-0000-0000-0000-000000000006	PT006	Thick Client Penetration Testing	c0000005-0000-0000-0000-000000000005	Burp Suite, API Fuzzer	45000.00	4	\N	t	6	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000007-0000-0000-0000-000000000007	VA001	Network Vulnerability Assessment	c0000006-0000-0000-0000-000000000006	Nessus, OpenVAS, Qualys	35000.00	3	\N	t	7	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000008-0000-0000-0000-000000000008	VA002	Web Application Vulnerability Assessment	c0000007-0000-0000-0000-000000000007	Acunetix, Qualys, Rapid7	40000.00	4	\N	t	8	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000009-0000-0000-0000-000000000009	VA003	Cloud Infrastructure Vulnerability Assessment	c0000008-0000-0000-0000-000000000008	Dome9, CloudSploit	50000.00	4	\N	t	9	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000000a-0000-0000-0000-00000000000a	RT001	Full Spectrum Red Team Exercise	c0000009-0000-0000-0000-000000000009	Cobalt Strike, Metasploit, Mimikatz	120000.00	10	\N	t	10	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000000b-0000-0000-0000-00000000000b	RT002	Targeted Red Team Engagement	c0000009-0000-0000-0000-000000000009	Custom Tools, Cobalt Strike	80000.00	7	\N	t	11	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000000c-0000-0000-0000-00000000000c	CS001	AWS Security Assessment	c000000a-0000-0000-0000-00000000000a	Scout2, CloudMapper, AWS Inspector	55000.00	5	\N	t	12	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000000d-0000-0000-0000-00000000000d	CS002	Azure Security Assessment	c000000b-0000-0000-0000-00000000000b	Azucar, Microsoft Defender, Qualys	55000.00	5	\N	t	13	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000000e-0000-0000-0000-00000000000e	CS003	Google Cloud Security Assessment	c000000c-0000-0000-0000-00000000000c	GCP Security Command Center	50000.00	5	\N	t	14	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000000f-0000-0000-0000-00000000000f	CODE001	Source Code Security Review	c000000d-0000-0000-0000-00000000000d	SonarQube, Checkmarx, Fortify	65000.00	6	\N	t	15	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000010-0000-0000-0000-000000000010	CODE002	Static Application Security Testing (SAST)	c000000e-0000-0000-0000-00000000000e	Checkmarx, Veracode, Fortify	70000.00	7	\N	t	16	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000011-0000-0000-0000-000000000011	CODE003	Dynamic Application Security Testing (DAST)	c000000f-0000-0000-0000-00000000000f	Burp Suite, Acunetix, AppScan	60000.00	6	\N	t	17	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000012-0000-0000-0000-000000000012	COMP001	ISO 27001 Security Audit	c0000010-0000-0000-0000-000000000010	AuditBoard, Drata, Vanta	85000.00	8	\N	t	18	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000013-0000-0000-0000-000000000013	COMP002	GDPR Compliance Assessment	c0000011-0000-0000-0000-000000000011	OneTrust, TrustArc, Compliance.ai	75000.00	7	\N	t	19	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000014-0000-0000-0000-000000000014	COMP003	PCI-DSS Compliance Assessment	c0000012-0000-0000-0000-000000000012	Qualys, Rapid7, Nessus	80000.00	7	\N	t	20	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000015-0000-0000-0000-000000000015	COMP004	SOC 2 Type II Audit	c0000013-0000-0000-0000-000000000013	AuditBoard, Drata	95000.00	10	\N	t	21	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000016-0000-0000-0000-000000000016	SE001	Phishing Campaign & Assessment	c0000014-0000-0000-0000-000000000014	KnowBe4, Gophish, Phish Alert	30000.00	2	\N	t	22	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000017-0000-0000-0000-000000000017	SE002	Security Awareness Training Program	c0000015-0000-0000-0000-000000000015	LinkedIn Learning, KnowBe4, SANS	45000.00	4	\N	t	23	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000018-0000-0000-0000-000000000018	SE003	Vishing & Pretexting Assessment	c0000016-0000-0000-0000-000000000016	Custom, KnowBe4	35000.00	3	\N	t	24	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000019-0000-0000-0000-000000000019	FOR001	Digital Forensics Investigation	c0000017-0000-0000-0000-000000000017	EnCase, FTK, Volatility, X-Ways	90000.00	8	\N	t	25	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000001a-0000-0000-0000-00000000001a	FOR002	Incident Response & Containment	c0000018-0000-0000-0000-000000000018	Splunk, ELK, Rapid7 InsightIDR	75000.00	7	\N	t	26	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000001b-0000-0000-0000-00000000001b	FOR003	Malware Analysis	c0000019-0000-0000-0000-000000000019	IDA Pro, Ghidra, Wireshark, Cuckoo	70000.00	6	\N	t	27	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000001c-0000-0000-0000-00000000001c	NET001	Network Architecture Security Review	c000001a-0000-0000-0000-00000000001a	Nmap, Wireshark, NETMON	55000.00	5	\N	t	28	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000001d-0000-0000-0000-00000000001d	NET002	Firewall & IDS/IPS Configuration Audit	c000001b-0000-0000-0000-00000000001b	Nessus, OpenVAS, Custom Scripts	65000.00	6	\N	t	29	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000001e-0000-0000-0000-00000000001e	NET003	Network Segmentation Assessment	c000001c-0000-0000-0000-00000000001c	Nmap, Shodan, Custom Tools	60000.00	5	\N	t	30	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d000001f-0000-0000-0000-00000000001f	THREAT001	Threat Modeling & Risk Assessment	c000001d-0000-0000-0000-00000000001d	Microsoft Threat Modeling Tool, IriusRisk	50000.00	4	\N	t	31	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000020-0000-0000-0000-000000000020	THREAT002	Cyber Threat Intelligence Report	c000001e-0000-0000-0000-00000000001e	MISP, Mandiant, CrowdStrike	40000.00	3	\N	t	32	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
d0000021-0000-0000-0000-000000000021	THREAT003	Attack Surface Analysis	c000001f-0000-0000-0000-00000000001f	Shodan, Censys, Rapid7 Sonar	45000.00	4	\N	t	33	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_service_departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_departments ("Id", "Code", "Name", "GroupId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
b0000001-0000-0000-0000-000000000001	PEN_TESTING	Penetration Testing	a2222222-2222-2222-2222-222222222222	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
b0000002-0000-0000-0000-000000000002	VULN_ASSESSMENT	Vulnerability Assessment	a2222222-2222-2222-2222-222222222222	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
b0000003-0000-0000-0000-000000000003	RED_TEAM	Red Team & Adversary Simulation	a1111111-1111-1111-1111-111111111111	t	3	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
b0000004-0000-0000-0000-000000000004	CLOUD_SECURITY	Cloud Security	a1111111-1111-1111-1111-111111111111	t	4	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
b0000005-0000-0000-0000-000000000005	CODE_APP_SECURITY	Code & Application Security	a2222222-2222-2222-2222-222222222222	t	5	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
b0000006-0000-0000-0000-000000000006	COMPLIANCE_AUDIT	Compliance & Audit	a1111111-1111-1111-1111-111111111111	t	6	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
b0000007-0000-0000-0000-000000000007	SOCIAL_ENGINEERING	Social Engineering & Awareness	a2222222-2222-2222-2222-222222222222	t	7	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
b0000008-0000-0000-0000-000000000008	FORENSICS_IR	Forensics & Incident Response	a1111111-1111-1111-1111-111111111111	t	8	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
b0000009-0000-0000-0000-000000000009	NETWORK_INFRA	Network & Infrastructure	a2222222-2222-2222-2222-222222222222	t	9	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
b000000a-0000-0000-0000-00000000000a	THREAT_INTEL	Threat Intelligence & Modeling	a1111111-1111-1111-1111-111111111111	t	10	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_service_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_groups ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
a1111111-1111-1111-1111-111111111111	RESOURCE	Resource	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
a2222222-2222-2222-2222-222222222222	SCOPE	Scope	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_service_sub_departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_sub_departments ("Id", "Code", "Name", "DepartmentId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
c0000001-0000-0000-0000-000000000001	SUB_NET_PT	Network Penetration Testing	b0000001-0000-0000-0000-000000000001	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000002-0000-0000-0000-000000000002	SUB_WEB_PT	Web Application Penetration Testing	b0000001-0000-0000-0000-000000000001	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000003-0000-0000-0000-000000000003	SUB_MOB_PT	Mobile Application Penetration Testing	b0000001-0000-0000-0000-000000000001	t	3	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000004-0000-0000-0000-000000000004	SUB_API_PT	API Penetration Testing	b0000001-0000-0000-0000-000000000001	t	4	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000005-0000-0000-0000-000000000005	SUB_THICK_PT	Thick Client Penetration Testing	b0000001-0000-0000-0000-000000000001	t	5	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000006-0000-0000-0000-000000000006	SUB_NET_VA	Network Vulnerability Assessment	b0000002-0000-0000-0000-000000000002	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000007-0000-0000-0000-000000000007	SUB_WEB_VA	Web Application Vulnerability Assessment	b0000002-0000-0000-0000-000000000002	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000008-0000-0000-0000-000000000008	SUB_CLOUD_VA	Cloud Infrastructure Vulnerability Assessment	b0000002-0000-0000-0000-000000000002	t	3	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000009-0000-0000-0000-000000000009	SUB_ADV_SIM	Adversary Simulation	b0000003-0000-0000-0000-000000000003	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000000a-0000-0000-0000-00000000000a	SUB_AWS_SEC	AWS Security Assessment	b0000004-0000-0000-0000-000000000004	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000000b-0000-0000-0000-00000000000b	SUB_AZURE_SEC	Azure Security Assessment	b0000004-0000-0000-0000-000000000004	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000000c-0000-0000-0000-00000000000c	SUB_GCP_SEC	Google Cloud Security Assessment	b0000004-0000-0000-0000-000000000004	t	3	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000000d-0000-0000-0000-00000000000d	SUB_CODE_REV	Source Code Security Review	b0000005-0000-0000-0000-000000000005	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000000e-0000-0000-0000-00000000000e	SUB_SAST	Static Application Security Testing	b0000005-0000-0000-0000-000000000005	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000000f-0000-0000-0000-00000000000f	SUB_DAST	Dynamic Application Security Testing	b0000005-0000-0000-0000-000000000005	t	3	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000010-0000-0000-0000-000000000010	SUB_ISO27001	ISO 27001 Security Audit	b0000006-0000-0000-0000-000000000006	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000011-0000-0000-0000-000000000011	SUB_GDPR	GDPR Compliance Assessment	b0000006-0000-0000-0000-000000000006	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000012-0000-0000-0000-000000000012	SUB_PCIDSS	PCI-DSS Compliance Assessment	b0000006-0000-0000-0000-000000000006	t	3	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000013-0000-0000-0000-000000000013	SUB_SOC2	SOC 2 Type II Audit	b0000006-0000-0000-0000-000000000006	t	4	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000014-0000-0000-0000-000000000014	SUB_PHISHING	Phishing Campaign & Assessment	b0000007-0000-0000-0000-000000000007	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000015-0000-0000-0000-000000000015	SUB_AWARENESS	Security Awareness Training Program	b0000007-0000-0000-0000-000000000007	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000016-0000-0000-0000-000000000016	SUB_VISHING	Vishing & Pretexting Assessment	b0000007-0000-0000-0000-000000000007	t	3	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000017-0000-0000-0000-000000000017	SUB_FORENSICS	Digital Forensics Investigation	b0000008-0000-0000-0000-000000000008	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000018-0000-0000-0000-000000000018	SUB_IR	Incident Response & Containment	b0000008-0000-0000-0000-000000000008	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c0000019-0000-0000-0000-000000000019	SUB_MALWARE	Malware Analysis	b0000008-0000-0000-0000-000000000008	t	3	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000001a-0000-0000-0000-00000000001a	SUB_NET_ARCH	Network Architecture Security Review	b0000009-0000-0000-0000-000000000009	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000001b-0000-0000-0000-00000000001b	SUB_FIREWALL	Firewall & IDS/IPS Configuration Audit	b0000009-0000-0000-0000-000000000009	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000001c-0000-0000-0000-00000000001c	SUB_NET_SEG	Network Segmentation Assessment	b0000009-0000-0000-0000-000000000009	t	3	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000001d-0000-0000-0000-00000000001d	SUB_THREAT_MOD	Threat Modeling & Risk Assessment	b000000a-0000-0000-0000-00000000000a	t	1	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000001e-0000-0000-0000-00000000001e	SUB_THREAT_REP	Cyber Threat Intelligence Report	b000000a-0000-0000-0000-00000000000a	t	2	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
c000001f-0000-0000-0000-00000000001f	SUB_ATTACK_SURF	Attack Surface Analysis	b000000a-0000-0000-0000-00000000000a	t	3	2026-09-29 06:57:13.885652+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_work_locations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_work_locations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
3bc10d7b-a705-4ec9-b7b5-71858572a8cc	suvidha_square_andheri	Suvidha Square, Andheri	t	2	2026-09-03 17:56:58.067087+05:30	2026-09-10 12:04:25.480503+05:30	\N	\N	\N
58e569dc-cb93-4832-bf22-2e8d4836dc65	onsite	Onsite	t	1	2026-09-03 17:56:58.067087+05:30	2026-09-10 12:04:25.480503+05:30	\N	\N	\N
8d0b23a2-9459-4fbe-a7bf-624abd410c40	navare_plaza_dombivli	Navare Plaza, Dombivli	t	3	2026-09-03 17:56:58.067087+05:30	2026-09-10 12:04:25.480503+05:30	\N	\N	\N
\.


--
-- Data for Name: project_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_documents ("Id", "ProjectId", "DocumentType", "FileName", "OriginalFileName", "FilePath", "ContentType", "SizeBytes", "Description", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: project_drafts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_drafts ("Id", "ProjectName", "ClientId", "ClientName", "SalesPerson", "FormSnapshotJson", "CreatedByName", "UpdatedByName", "Status", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: project_invoices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_invoices ("Id", "ProjectId", "MilestoneName", "Percentage", "Amount", "TaxAmount", "TotalAmount", "Status", "InvoiceNumber", "InvoiceDate", "DueDate", "PaymentDate", "Remarks", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
0b0d6880-68ba-ec22-3904-1e2e3d34488c	6aaca83f-9e2d-72bf-2873-cc7f244f91a5	Initial Milestone (50% Advance)	50.00	160000.00	28800.00	188800.00	Raised	INV-P34-01	2023-03-01	2023-03-31	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0b2e8e40-f5a2-2d27-9201-b0fad1e6ef22	c6600f41-5fbd-cbb0-983b-ccbbcbf9636f	Final Milestone (50% on Sign-off)	50.00	285000.00	51300.00	336300.00	Paid	INV-P25-02	2024-11-30	2024-12-30	2024-12-20	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0cf0bebb-3cfc-6bdc-a4c1-b17a958b2dd6	2b6e8fc3-44f8-a096-04cb-40f258f06eb4	Final Milestone (50% on Sign-off)	50.00	600000.00	108000.00	708000.00	Pending	INV-P14-02	2026-10-31	2026-11-30	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1085016f-c3c2-203b-6697-33d24dd4b488	6d888c0c-7071-ce2c-a642-2aa1ccff8ce0	Final Milestone (50% on Sign-off)	50.00	140000.00	25200.00	165200.00	Pending	INV-P20-02	2026-12-05	2027-01-04	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1b3d6521-a79b-6c92-76bf-abb28f3b876a	e3d8204f-df7e-d5f0-79cf-7578c1385684	Final Milestone (50% on Sign-off)	50.00	305000.00	54900.00	359900.00	Paid	INV-P19-02	2024-09-05	2024-10-05	2024-09-25	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1baa2115-5375-a91d-57ac-0cf6846f3910	d9c31d7b-328e-11be-73d1-c8c578219b98	Initial Milestone (50% Advance)	50.00	340000.00	61200.00	401200.00	Paid	INV-P16-01	2024-02-01	2024-03-02	2024-02-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1bd2ab21-56ed-9c69-1400-3fca9e821ea6	078de404-e464-38fe-bc5a-1eecc50c5cdb	Initial Milestone (50% Advance)	50.00	180000.00	32400.00	212400.00	Raised	INV-P39-01	2026-06-18	2026-07-18	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1d0acc91-87e0-5f79-145c-df392cca4784	42c28ff9-518b-917f-58fb-322aa28ffc9f	Final Milestone (50% on Sign-off)	50.00	320000.00	57600.00	377600.00	Raised	INV-P13-02	2026-07-16	2026-08-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1d534555-d2f7-bd29-3c5d-333c56eeba3b	4bdd9b6e-dc7e-83df-0e4a-588b718a46de	Final Milestone (50% on Sign-off)	50.00	245000.00	44100.00	289100.00	Pending	INV-P30-02	2026-11-15	2026-12-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1ffc762a-fb82-7fa0-f240-e18314de536f	8674f685-9512-d7a4-1399-e58a4b88fe5b	Initial Milestone (50% Advance)	50.00	460000.00	82800.00	542800.00	Raised	INV-P32-01	2026-06-12	2026-07-12	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2324aafd-b7ac-9b9a-380d-b78954c6e00c	0005c8ca-9a64-17b8-256b-4ee73b53e81e	Initial Milestone (50% Advance)	50.00	215000.00	38700.00	253700.00	Raised	INV-P43-01	2023-08-01	2023-08-31	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
245f4c4f-47ea-6f8b-0b5d-674d57c9233b	db951439-0ec5-b321-9266-611d80ea0ffa	Final Milestone (50% on Sign-off)	50.00	375000.00	67500.00	442500.00	Raised	INV-P10-02	2026-08-15	2026-09-14	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2619ace8-8708-a2a9-1c71-eb64e60c6dd0	9df44408-e0f7-1c11-d144-08e51e02851f	Final Milestone (50% on Sign-off)	50.00	230000.00	41400.00	271400.00	Paid	INV-P27-02	2024-10-16	2024-11-15	2024-11-05	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
26322981-ea8a-e640-6988-a19d196a3c15	9e038dae-c384-1ce5-0dc2-493dd9c9720e	Final Milestone (50% on Sign-off)	50.00	525000.00	94500.00	619500.00	Raised	INV-P9-02	2026-09-25	2026-10-25	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
284ba788-0dc8-cdcf-a31b-18185b64d7c6	dd709b37-3794-40c0-13ae-e35ec70100a2	Initial Milestone (50% Advance)	50.00	140000.00	25200.00	165200.00	Paid	INV-P6-01	2025-09-01	2025-10-01	2025-09-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2c717c9a-be07-da18-5611-0960eda3bcbb	e1dd4c6b-527b-5243-9f98-cb106d526ed9	Final Milestone (50% on Sign-off)	50.00	445000.00	80100.00	525100.00	Raised	INV-P8-02	2026-06-30	2026-07-30	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2ceb65c0-f1f7-9d51-7deb-5900a7e15293	058887ff-6249-66e3-e9b6-6d54d5bedf62	Initial Milestone (50% Advance)	50.00	460000.00	82800.00	542800.00	Raised	INV-P12-01	2026-02-10	2026-03-12	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2d5bcec8-db64-3869-9c57-2149602bc664	37f0631e-ff18-137e-2790-48bf2a3aed53	Initial Milestone (50% Advance)	50.00	110000.00	19800.00	129800.00	Raised	INV-P26-01	2026-06-15	2026-07-15	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
309defb0-c1d2-6f13-0907-c45a18f0e0df	6d888c0c-7071-ce2c-a642-2aa1ccff8ce0	Initial Milestone (50% Advance)	50.00	140000.00	25200.00	165200.00	Raised	INV-P20-01	2026-06-10	2026-07-10	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3303051b-f169-5e0d-d9e8-7b5bde10c5e9	96771845-a6f8-9c00-10b1-7f6e20cb26f2	Initial Milestone (50% Advance)	50.00	600000.00	108000.00	708000.00	Paid	INV-P1-01	2026-02-01	2026-03-03	2026-02-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3480cbc2-a622-f6c0-a879-eec5ba9eb139	42c28ff9-518b-917f-58fb-322aa28ffc9f	Initial Milestone (50% Advance)	50.00	320000.00	57600.00	377600.00	Paid	INV-P13-01	2026-01-20	2026-02-19	2026-02-04	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3b76cd0f-0b0e-8d58-21f9-eed79662981e	143d6851-c81c-f1db-df43-09e721081b95	Initial Milestone (50% Advance)	50.00	195000.00	35100.00	230100.00	Raised	INV-P17-01	2026-06-01	2026-07-01	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4370287f-5fc8-14bd-bcc7-07194a516d31	569eb2b4-dce7-5d4f-5e8c-6321a995cf38	Final Milestone (50% on Sign-off)	50.00	225000.00	40500.00	265500.00	Raised	INV-P18-02	2024-04-15	2024-05-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
44e9a8d2-810a-2abb-9a11-6749873e5091	569eb2b4-dce7-5d4f-5e8c-6321a995cf38	Initial Milestone (50% Advance)	50.00	225000.00	40500.00	265500.00	Paid	INV-P18-01	2023-09-01	2023-10-01	2023-09-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
474036d4-2c7f-ffff-ae6d-09c44d4eb812	633de7eb-3b6c-dd5b-49e3-e6218fbb857d	Final Milestone (50% on Sign-off)	50.00	155000.00	27900.00	182900.00	Pending	INV-P28-02	2026-11-30	2026-12-30	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
490b124f-3166-b79d-416e-225d668d5c16	48e0163b-4dfa-3376-dac6-ee5de57f0f99	Initial Milestone (50% Advance)	50.00	160000.00	28800.00	188800.00	Raised	INV-P4-01	2026-02-10	2026-03-12	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4ac0ba02-08fd-61db-1a48-6f7e9eb0b391	db951439-0ec5-b321-9266-611d80ea0ffa	Initial Milestone (50% Advance)	50.00	375000.00	67500.00	442500.00	Paid	INV-P10-01	2026-03-01	2026-03-31	2026-03-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4aefb858-a35d-127e-e480-3ce3451ee49a	140eef6e-917f-4d05-d414-eaaa470f8665	Final Milestone (50% on Sign-off)	50.00	270000.00	48600.00	318600.00	Paid	INV-P33-02	2024-08-16	2024-09-15	2024-09-05	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4afa35c5-4aff-7263-20a9-ac8268f7ece6	dd709b37-3794-40c0-13ae-e35ec70100a2	Final Milestone (50% on Sign-off)	50.00	140000.00	25200.00	165200.00	Raised	INV-P6-02	2026-03-15	2026-04-14	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4cef178b-c443-b9ab-f602-e40b7bd03115	53265692-ac5b-a712-54c9-eeb3f10efef2	Initial Milestone (50% Advance)	50.00	190000.00	34200.00	224200.00	Raised	INV-P36-01	2026-06-20	2026-07-20	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4cff50e7-bff8-fd96-5f0c-8fe14f7c2a0a	3de4e5fa-92ba-df0d-06f0-ee3caacf1ffd	Final Milestone (50% on Sign-off)	50.00	380000.00	68400.00	448400.00	Raised	INV-P5-02	2026-07-26	2026-08-25	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4d4b6984-1a19-e81b-ca25-fc656b9dd480	b71355b0-ed52-fd33-d6f7-87bb249aacce	Final Milestone (50% on Sign-off)	50.00	290000.00	52200.00	342200.00	Raised	INV-P11-02	2026-06-05	2026-07-05	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4d57c171-5494-d685-2d34-eb28ae077eb2	48e0163b-4dfa-3376-dac6-ee5de57f0f99	Final Milestone (50% on Sign-off)	50.00	160000.00	28800.00	188800.00	Pending	INV-P4-02	2026-07-05	2026-08-04	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5115e75b-0316-ec78-2985-ae6f76b66998	fbb030f3-e849-5b81-6934-cf7a89075db1	Final Milestone (50% on Sign-off)	50.00	170000.00	30600.00	200600.00	Paid	INV-P22-02	2024-11-15	2024-12-15	2024-12-05	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
51f0565a-8a3b-fe3e-2908-6d5bf6f3ac8d	0110e115-3f2e-645f-fa51-3f844cd6227e	Initial Milestone (50% Advance)	50.00	550000.00	99000.00	649000.00	Raised	INV-P42-01	2026-06-25	2026-07-25	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
57e2f85e-2cd0-3ffd-07c6-7e9d559b1014	143d6851-c81c-f1db-df43-09e721081b95	Final Milestone (50% on Sign-off)	50.00	195000.00	35100.00	230100.00	Pending	INV-P17-02	2026-12-16	2027-01-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5a404d2b-f66b-f1c6-01ca-76eef82bdafc	bbdd9713-b12d-1026-241e-f23f2881fbd6	Final Milestone (50% on Sign-off)	50.00	245000.00	44100.00	289100.00	Raised	INV-P24-02	2023-09-15	2023-10-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5c51690b-843c-9e8e-c9c8-8e00890061a3	0ce49262-f49c-2000-fe94-e93c5bdfb327	Initial Milestone (50% Advance)	50.00	335000.00	60300.00	395300.00	Paid	INV-P35-01	2024-05-01	2024-05-31	2024-05-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5d2989a6-e5b0-7c11-cf7e-d990db00b912	27198d8b-d6cf-276d-f1a7-a66b0abf819a	Final Milestone (50% on Sign-off)	50.00	210000.00	37800.00	247800.00	Paid	INV-P38-02	2024-10-15	2024-11-14	2024-11-04	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5f420763-de4b-948e-474a-b4200564b47c	e665c8c1-23cb-3bc0-bb8a-2ac17e4d8a37	Initial Milestone (50% Advance)	50.00	260000.00	46800.00	306800.00	Paid	INV-P15-01	2024-06-01	2024-07-01	2024-06-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6128b3d3-99c9-2173-7008-ebe15c24214b	8674f685-9512-d7a4-1399-e58a4b88fe5b	Final Milestone (50% on Sign-off)	50.00	460000.00	82800.00	542800.00	Pending	INV-P32-02	2027-01-16	2027-02-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6231ae72-b2e8-2ebf-8913-a1caa0f4b27f	058887ff-6249-66e3-e9b6-6d54d5bedf62	Final Milestone (50% on Sign-off)	50.00	460000.00	82800.00	542800.00	Pending	INV-P12-02	2026-09-10	2026-10-10	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6bbda0c1-e804-f7d9-b27a-14f89facbdaf	fbb030f3-e849-5b81-6934-cf7a89075db1	Initial Milestone (50% Advance)	50.00	170000.00	30600.00	200600.00	Paid	INV-P22-01	2024-03-01	2024-03-31	2024-03-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6bd91059-58c0-7f50-0e06-7b54c05b9118	45f61698-e7ca-9049-dce4-2678530df87e	Initial Milestone (50% Advance)	50.00	365000.00	65700.00	430700.00	Paid	INV-P21-01	2023-05-01	2023-05-31	2023-05-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
706f3776-b68e-e13c-8040-21dd3b01d055	804038cb-1b0f-af18-247c-514d7edf2757	Initial Milestone (50% Advance)	50.00	155000.00	27900.00	182900.00	Raised	INV-P40-01	2023-04-01	2023-05-01	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7345a2eb-c864-7d72-2928-ab8f11247b28	3de4e5fa-92ba-df0d-06f0-ee3caacf1ffd	Initial Milestone (50% Advance)	50.00	380000.00	68400.00	448400.00	Paid	INV-P5-01	2026-01-20	2026-02-19	2026-02-04	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
74c5fc5f-0f1f-a827-ebf7-cdbb45b9e45b	f70f1cb0-fd2b-e991-19c1-97058bf88682	Final Milestone (50% on Sign-off)	50.00	490000.00	88200.00	578200.00	Paid	INV-P41-02	2024-11-15	2024-12-15	2024-12-05	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
79f4014b-7c39-2f7b-d40f-0700f7c03b2f	0ce49262-f49c-2000-fe94-e93c5bdfb327	Final Milestone (50% on Sign-off)	50.00	335000.00	60300.00	395300.00	Paid	INV-P35-02	2024-12-31	2025-01-30	2025-01-20	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7f2bf4e0-2c4e-b38b-c96d-709991dfb9cd	4b05d47c-011a-ca3b-0c37-a70112d30fe7	Final Milestone (50% on Sign-off)	50.00	240000.00	43200.00	283200.00	Raised	INV-P2-02	2026-06-15	2026-07-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
82762e02-84ce-b583-176c-56d9ccf8beef	b71355b0-ed52-fd33-d6f7-87bb249aacce	Initial Milestone (50% Advance)	50.00	290000.00	52200.00	342200.00	Paid	INV-P11-01	2026-01-15	2026-02-14	2026-01-30	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
845cef97-564c-8a1a-bd0b-7f5202d2eb53	078de404-e464-38fe-bc5a-1eecc50c5cdb	Final Milestone (50% on Sign-off)	50.00	180000.00	32400.00	212400.00	Pending	INV-P39-02	2026-12-05	2027-01-04	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8783f55d-5136-6599-5971-0a57afbc83ee	bbdd9713-b12d-1026-241e-f23f2881fbd6	Initial Milestone (50% Advance)	50.00	245000.00	44100.00	289100.00	Paid	INV-P24-01	2023-01-15	2023-02-14	2023-01-30	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8826302b-fe38-12ea-b525-b13049b0ad27	140eef6e-917f-4d05-d414-eaaa470f8665	Initial Milestone (50% Advance)	50.00	270000.00	48600.00	318600.00	Paid	INV-P33-01	2024-01-01	2024-01-31	2024-01-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8884314c-a3e7-ef38-a3b5-5990d38029c0	b094ee94-07db-74de-1151-8dbf3fdc5feb	Final Milestone (50% on Sign-off)	50.00	145000.00	26100.00	171100.00	Raised	INV-P37-02	2024-03-16	2024-04-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8fa69d8d-cc9e-eb81-6ea5-929fb17fab65	589f13e8-777d-9e78-0179-6955019400a4	Initial Milestone (50% Advance)	50.00	475000.00	85500.00	560500.00	Raised	INV-P3-01	2026-03-01	2026-03-31	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9142314d-6b34-8962-4ccd-fc02524ef312	da23da7f-348b-c5d8-c21c-6f5321338b69	Final Milestone (50% on Sign-off)	50.00	270000.00	48600.00	318600.00	Pending	INV-P7-02	2026-08-17	2026-09-16	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
985c5471-db28-2291-d0b4-be15be8e946e	b094ee94-07db-74de-1151-8dbf3fdc5feb	Initial Milestone (50% Advance)	50.00	145000.00	26100.00	171100.00	Paid	INV-P37-01	2023-07-01	2023-07-31	2023-07-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
99a0ef61-727f-51f3-0c8b-7b3355c38ce7	df04abe8-20bf-ba46-4e51-73dfb2469b6b	Initial Milestone (50% Advance)	50.00	210000.00	37800.00	247800.00	Raised	INV-P23-01	2026-06-05	2026-07-05	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9d43ab97-ed03-d02a-c894-8023fa1cacda	4bdd9b6e-dc7e-83df-0e4a-588b718a46de	Initial Milestone (50% Advance)	50.00	245000.00	44100.00	289100.00	Raised	INV-P30-01	2026-06-01	2026-07-01	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9e27c6f5-52ad-a0ce-d106-09964da7bc64	e1dd4c6b-527b-5243-9f98-cb106d526ed9	Initial Milestone (50% Advance)	50.00	445000.00	80100.00	525100.00	Paid	INV-P8-01	2026-01-05	2026-02-04	2026-01-20	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a148f8be-fb38-5460-272f-d6ac06510e8a	0005c8ca-9a64-17b8-256b-4ee73b53e81e	Final Milestone (50% on Sign-off)	50.00	215000.00	38700.00	253700.00	Pending	INV-P43-02	2024-04-15	2024-05-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
aa473b7b-ebb9-4835-60a4-f2a22dd2287f	4b05d47c-011a-ca3b-0c37-a70112d30fe7	Initial Milestone (50% Advance)	50.00	240000.00	43200.00	283200.00	Paid	INV-P2-01	2026-01-15	2026-02-14	2026-01-30	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
aca8187e-3e2f-9cef-d025-8802fe0df9c9	37f0631e-ff18-137e-2790-48bf2a3aed53	Final Milestone (50% on Sign-off)	50.00	110000.00	19800.00	129800.00	Pending	INV-P26-02	2026-11-05	2026-12-05	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ae278601-499d-d186-652e-dc50df08df70	633de7eb-3b6c-dd5b-49e3-e6218fbb857d	Initial Milestone (50% Advance)	50.00	155000.00	27900.00	182900.00	Raised	INV-P28-01	2026-06-08	2026-07-08	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ae2d1b46-5820-96ce-a3ae-807759c13c83	d9c31d7b-328e-11be-73d1-c8c578219b98	Final Milestone (50% on Sign-off)	50.00	340000.00	61200.00	401200.00	Paid	INV-P16-02	2024-10-15	2024-11-14	2024-11-04	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ae954cf7-71ac-1c3c-2423-37f7d4081101	9df44408-e0f7-1c11-d144-08e51e02851f	Initial Milestone (50% Advance)	50.00	230000.00	41400.00	271400.00	Paid	INV-P27-01	2024-02-01	2024-03-02	2024-02-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b888ce1f-bfdc-3460-4fc9-c4ccf5035a7a	da23da7f-348b-c5d8-c21c-6f5321338b69	Initial Milestone (50% Advance)	50.00	270000.00	48600.00	318600.00	Raised	INV-P7-01	2026-02-15	2026-03-17	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
baf85f4e-eecd-73e4-f80c-dbbcccc74bd1	f70f1cb0-fd2b-e991-19c1-97058bf88682	Initial Milestone (50% Advance)	50.00	490000.00	88200.00	578200.00	Paid	INV-P41-01	2024-01-20	2024-02-19	2024-02-04	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c2ad67bf-2a70-3bbd-2a4b-30291501013f	b31447f7-a279-235e-1c13-5e1332ac6f71	Initial Milestone (50% Advance)	50.00	190000.00	34200.00	224200.00	Paid	INV-P31-01	2024-03-15	2024-04-14	2024-03-30	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c65b00d4-7cc4-fa8d-e379-b0cf734cc965	2b6e8fc3-44f8-a096-04cb-40f258f06eb4	Initial Milestone (50% Advance)	50.00	600000.00	108000.00	708000.00	Raised	INV-P14-01	2026-03-10	2026-04-09	\N	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cc5b9cfc-d153-44c3-3e16-72fc1d8432e4	e665c8c1-23cb-3bc0-bb8a-2ac17e4d8a37	Final Milestone (50% on Sign-off)	50.00	260000.00	46800.00	306800.00	Paid	INV-P15-02	2024-12-31	2025-01-30	2025-01-20	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d382c723-928f-1b55-bb41-fca7724f578a	e4d9ede1-e653-6c3b-1081-c54a2be3f6e0	Initial Milestone (50% Advance)	50.00	435000.00	78300.00	513300.00	Paid	INV-P29-01	2023-06-01	2023-07-01	2023-06-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d51dbafd-f5f1-6abe-d5d4-c35e6c3bfdaa	e3d8204f-df7e-d5f0-79cf-7578c1385684	Initial Milestone (50% Advance)	50.00	305000.00	54900.00	359900.00	Paid	INV-P19-01	2024-01-10	2024-02-09	2024-01-25	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d5b75471-5858-a43c-0169-98a639b389e6	b31447f7-a279-235e-1c13-5e1332ac6f71	Final Milestone (50% on Sign-off)	50.00	190000.00	34200.00	224200.00	Paid	INV-P31-02	2024-11-15	2024-12-15	2024-12-05	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d8429b2d-2ac5-c1d4-e5e0-7df28d6fbca5	0110e115-3f2e-645f-fa51-3f844cd6227e	Final Milestone (50% on Sign-off)	50.00	550000.00	99000.00	649000.00	Pending	INV-P42-02	2027-02-13	2027-03-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e41d1aba-68fa-810e-1757-feb37b454c2f	45f61698-e7ca-9049-dce4-2678530df87e	Final Milestone (50% on Sign-off)	50.00	365000.00	65700.00	430700.00	Raised	INV-P21-02	2024-01-16	2024-02-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e6cfcd8c-dcdd-6604-2717-a903b938496f	c6600f41-5fbd-cbb0-983b-ccbbcbf9636f	Initial Milestone (50% Advance)	50.00	285000.00	51300.00	336300.00	Paid	INV-P25-01	2024-04-01	2024-05-01	2024-04-16	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e753e22e-e715-7559-4ed7-6d00a3e73ff9	df04abe8-20bf-ba46-4e51-73dfb2469b6b	Final Milestone (50% on Sign-off)	50.00	210000.00	37800.00	247800.00	Pending	INV-P23-02	2026-11-15	2026-12-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ea35988b-9fbb-9b77-b7a1-a2338b9e3971	589f13e8-777d-9e78-0179-6955019400a4	Final Milestone (50% on Sign-off)	50.00	475000.00	85500.00	560500.00	Pending	INV-P3-02	2026-08-31	2026-09-30	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ecbd3b91-e4a6-ad63-8f19-88fb2c81b600	e4d9ede1-e653-6c3b-1081-c54a2be3f6e0	Final Milestone (50% on Sign-off)	50.00	435000.00	78300.00	513300.00	Raised	INV-P29-02	2024-03-16	2024-04-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f0668437-f916-658a-1e55-8379f3e2e4b8	6aaca83f-9e2d-72bf-2873-cc7f244f91a5	Final Milestone (50% on Sign-off)	50.00	160000.00	28800.00	188800.00	Pending	INV-P34-02	2023-09-30	2023-10-30	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f226006f-fb26-696c-9b66-b27a77f66674	96771845-a6f8-9c00-10b1-7f6e20cb26f2	Final Milestone (50% on Sign-off)	50.00	600000.00	108000.00	708000.00	Raised	INV-P1-02	2026-08-15	2026-09-14	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f6d83ba1-706d-e63c-2ec5-17944f912ff5	53265692-ac5b-a712-54c9-eeb3f10efef2	Final Milestone (50% on Sign-off)	50.00	190000.00	34200.00	224200.00	Pending	INV-P36-02	2026-12-16	2027-01-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f6e10710-0262-9943-7692-e92e54a7aa1e	9e038dae-c384-1ce5-0dc2-493dd9c9720e	Initial Milestone (50% Advance)	50.00	525000.00	94500.00	619500.00	Paid	INV-P9-01	2026-02-20	2026-03-22	2026-03-07	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f75104d5-bd08-ad9b-26d6-3795bcba197d	27198d8b-d6cf-276d-f1a7-a66b0abf819a	Initial Milestone (50% Advance)	50.00	210000.00	37800.00	247800.00	Paid	INV-P38-01	2024-02-15	2024-03-16	2024-03-01	\N	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fe449bf5-161a-4920-96c8-13dce316e700	804038cb-1b0f-af18-247c-514d7edf2757	Final Milestone (50% on Sign-off)	50.00	155000.00	27900.00	182900.00	Pending	INV-P40-02	2023-11-15	2023-12-15	\N	\N	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: project_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_services ("Id", "ProjectId", "ServiceCatalogId", "TaskId", "Department", "SubDepartment", "ServiceName", "Qty", "Description", "ResourceLevel", "Frequency", "Location", "LocationText", "ServiceModel", "DeliveryModel", "FinalDeliveryFormat", "BillingModel", "Tools", "StartDate", "EndDate", "DurationDays", "DurationHours", "TotalDays", "TotalHours", "UnitPrice", "Total", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
05bac44a-67a8-dea6-95d3-36e7c82a5a70	db951439-0ec5-b321-9266-611d80ea0ffa	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	450000.00	450000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
087e4b44-d201-7054-1e13-406aff3754c4	078de404-e464-38fe-bc5a-1eecc50c5cdb	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	216000.00	216000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0b16929b-f648-0774-3d3a-04ee872062d9	6d888c0c-7071-ce2c-a642-2aa1ccff8ce0	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	168000.00	168000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0c256a9f-e032-9c16-b370-382f769ba40d	42c28ff9-518b-917f-58fb-322aa28ffc9f	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	384000.00	384000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0dc6d4be-ed14-8849-53b4-dedea1887e8f	da23da7f-348b-c5d8-c21c-6f5321338b69	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	324000.00	324000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0ffc285b-63f3-eb43-95dc-ec01d54e7671	4b05d47c-011a-ca3b-0c37-a70112d30fe7	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	288000.00	288000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1054551a-5919-4157-25f3-f277178825bd	143d6851-c81c-f1db-df43-09e721081b95	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	234000.00	234000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
10670d63-9013-e4a3-fff4-2bee3401de6e	9df44408-e0f7-1c11-d144-08e51e02851f	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	184000.00	184000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
12cc8282-faf3-2c4e-73cf-0174d98d5cfd	db951439-0ec5-b321-9266-611d80ea0ffa	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	300000.00	300000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
15b0f2d9-54fd-59a8-59fd-3a530cf4b72f	42c28ff9-518b-917f-58fb-322aa28ffc9f	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	256000.00	256000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
176462fe-5af9-51eb-df27-127232d7625d	589f13e8-777d-9e78-0179-6955019400a4	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	380000.00	380000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1ab48c0e-5bcd-9c9d-16b5-ae4328a52479	4bdd9b6e-dc7e-83df-0e4a-588b718a46de	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	196000.00	196000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1afd49cd-ab49-2739-da1a-1fa6dcee5078	e1dd4c6b-527b-5243-9f98-cb106d526ed9	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	356000.00	356000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1e35a5bc-4e01-b9d6-a46e-53bf40227634	d9c31d7b-328e-11be-73d1-c8c578219b98	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	408000.00	408000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2381f179-c713-3662-a15a-941357c74808	96771845-a6f8-9c00-10b1-7f6e20cb26f2	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	480000.00	480000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
290f5384-fa2d-9c09-2ba6-5136299b13c6	d9c31d7b-328e-11be-73d1-c8c578219b98	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	272000.00	272000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2a603970-bdf9-5ed1-4f85-dbdc47f8f7b9	f70f1cb0-fd2b-e991-19c1-97058bf88682	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	588000.00	588000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2bf6eb9a-efae-81ab-2269-3090bd9d5d58	4b05d47c-011a-ca3b-0c37-a70112d30fe7	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	192000.00	192000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2d764f0b-9442-6d98-9684-fc71d242e8db	569eb2b4-dce7-5d4f-5e8c-6321a995cf38	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	180000.00	180000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2df0e698-e269-9722-1baf-1ef46b658d8d	bbdd9713-b12d-1026-241e-f23f2881fbd6	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	196000.00	196000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2fc2dee5-f447-d953-9b34-7168fd912855	633de7eb-3b6c-dd5b-49e3-e6218fbb857d	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	186000.00	186000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
31073bb0-6430-4113-7806-da6542c7ef70	b31447f7-a279-235e-1c13-5e1332ac6f71	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	152000.00	152000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
35ab8110-a847-5e90-c961-f4ed123a134c	078de404-e464-38fe-bc5a-1eecc50c5cdb	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	144000.00	144000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
35c728c6-8c05-6c76-d801-88762d76500d	9df44408-e0f7-1c11-d144-08e51e02851f	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	276000.00	276000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
363b3132-f311-8115-0a6a-4833b3d8032a	37f0631e-ff18-137e-2790-48bf2a3aed53	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	132000.00	132000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3676c60b-0bdd-5476-2391-778b0e93daf9	2b6e8fc3-44f8-a096-04cb-40f258f06eb4	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	480000.00	480000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3bcefdb5-d53a-c4c7-e086-1d8c187936f3	0005c8ca-9a64-17b8-256b-4ee73b53e81e	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	258000.00	258000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3ce7a798-fe69-7f2e-f86b-646973d476cb	e1dd4c6b-527b-5243-9f98-cb106d526ed9	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	534000.00	534000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3e5533e3-d1c3-3c16-1160-b8eb29172655	3de4e5fa-92ba-df0d-06f0-ee3caacf1ffd	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	304000.00	304000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
410e3e7a-d656-735f-e216-9adf10ef7703	48e0163b-4dfa-3376-dac6-ee5de57f0f99	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	128000.00	128000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
432e2d21-bf0d-c6b9-b055-37cfaab5c694	df04abe8-20bf-ba46-4e51-73dfb2469b6b	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	168000.00	168000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
46666780-3545-52dc-2ce0-7b8e53511045	37f0631e-ff18-137e-2790-48bf2a3aed53	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	88000.00	88000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
49421cfd-1bd3-b93a-27cd-301b7407c754	2b6e8fc3-44f8-a096-04cb-40f258f06eb4	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	720000.00	720000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4b752a38-4211-7934-a715-2b5b05578797	fbb030f3-e849-5b81-6934-cf7a89075db1	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	204000.00	204000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
508bc02a-7f4d-cd33-1037-15ea3915806c	27198d8b-d6cf-276d-f1a7-a66b0abf819a	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	168000.00	168000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
51c72dd7-b22d-2483-e76e-ea3b64e6ecae	8674f685-9512-d7a4-1399-e58a4b88fe5b	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	368000.00	368000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
524898de-b5f7-1fca-dcc5-a7de591c672f	0ce49262-f49c-2000-fe94-e93c5bdfb327	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	402000.00	402000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5d17cfaa-2414-8912-f685-90e74b7dabb5	dd709b37-3794-40c0-13ae-e35ec70100a2	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	168000.00	168000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5fd5d5f2-6564-cb5c-e88a-74ca15afde28	96771845-a6f8-9c00-10b1-7f6e20cb26f2	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	720000.00	720000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
61ee7a2d-9ea7-253e-2b90-80fe738f69e5	e4d9ede1-e653-6c3b-1081-c54a2be3f6e0	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	348000.00	348000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6650596e-77bb-9270-ef6a-bd48c3cf470e	8674f685-9512-d7a4-1399-e58a4b88fe5b	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	552000.00	552000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6770ea6e-b27f-c489-264d-8837151b0833	6d888c0c-7071-ce2c-a642-2aa1ccff8ce0	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	112000.00	112000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6b4f7f9e-d6b3-f178-6b34-76169bc32763	da23da7f-348b-c5d8-c21c-6f5321338b69	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	216000.00	216000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6cd5d5d0-3b08-2bec-45cd-a5b847830ade	53265692-ac5b-a712-54c9-eeb3f10efef2	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	228000.00	228000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6d7da59a-e68e-3852-6e06-1caa42acc509	45f61698-e7ca-9049-dce4-2678530df87e	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	292000.00	292000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7506ff05-9ce4-10f9-b6ab-cb812638a200	4bdd9b6e-dc7e-83df-0e4a-588b718a46de	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	294000.00	294000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
756926a6-d053-4adc-4345-9808c00cef68	804038cb-1b0f-af18-247c-514d7edf2757	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	186000.00	186000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7b6a309b-6e0f-9c7f-5bd0-ff4f96ace4a5	0110e115-3f2e-645f-fa51-3f844cd6227e	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	660000.00	660000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7d6e6bdb-5c0b-00ea-a1f2-fdf1754f994d	589f13e8-777d-9e78-0179-6955019400a4	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	570000.00	570000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7eb667b3-3f3f-ad65-a874-8eb4e5ce0c06	e3d8204f-df7e-d5f0-79cf-7578c1385684	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	244000.00	244000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8548d90d-ef14-4d23-a819-ed401afac78f	569eb2b4-dce7-5d4f-5e8c-6321a995cf38	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	270000.00	270000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
89a93f8f-a20a-9468-5381-de195e92438b	3de4e5fa-92ba-df0d-06f0-ee3caacf1ffd	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	456000.00	456000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8db53daf-2a87-4f81-6d4b-57740dd0b1f6	6aaca83f-9e2d-72bf-2873-cc7f244f91a5	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	192000.00	192000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8ed27ef1-635a-a926-f5c3-e43ebbe5461c	bbdd9713-b12d-1026-241e-f23f2881fbd6	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	294000.00	294000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8ee83ad7-ea23-7f24-7a8c-e4d4f148b1a8	c6600f41-5fbd-cbb0-983b-ccbbcbf9636f	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	342000.00	342000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9279e70e-9cff-a540-aaa0-a69a28e40861	dd709b37-3794-40c0-13ae-e35ec70100a2	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	112000.00	112000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9342f7e0-dcf7-04d0-161b-a0dee2dffc6a	058887ff-6249-66e3-e9b6-6d54d5bedf62	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	552000.00	552000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
93df6167-e309-f86c-dd0e-b74192db38de	45f61698-e7ca-9049-dce4-2678530df87e	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	438000.00	438000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9863f9d0-1640-009c-1811-6d083d585ff9	140eef6e-917f-4d05-d414-eaaa470f8665	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	216000.00	216000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
996f2546-6740-af77-8960-72e4a7391ca4	0005c8ca-9a64-17b8-256b-4ee73b53e81e	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	172000.00	172000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a32944fe-5c3f-7da3-71da-b1c5d67516e6	9e038dae-c384-1ce5-0dc2-493dd9c9720e	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	630000.00	630000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ab011c73-dd7f-2a45-79d6-972cc0101c1b	b71355b0-ed52-fd33-d6f7-87bb249aacce	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	348000.00	348000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
adfa2cfb-6855-06f9-6831-f1d8989a20c8	140eef6e-917f-4d05-d414-eaaa470f8665	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	324000.00	324000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b4f2e875-9fa4-0897-f4ed-4cd0e4534ed9	b71355b0-ed52-fd33-d6f7-87bb249aacce	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	232000.00	232000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b5ecadf8-885e-c8e3-3415-ffc86e5f1ff7	0ce49262-f49c-2000-fe94-e93c5bdfb327	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	268000.00	268000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b623c0cf-5b8b-dde1-39fe-74e26adcdde0	e4d9ede1-e653-6c3b-1081-c54a2be3f6e0	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	522000.00	522000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b869ff8b-af76-d0a4-5a0c-1618e76ea079	27198d8b-d6cf-276d-f1a7-a66b0abf819a	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	252000.00	252000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b95d4d6f-04a8-34b3-8078-8418577a24a1	804038cb-1b0f-af18-247c-514d7edf2757	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	124000.00	124000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
be756cb9-406f-1c8b-176e-c05db328a779	b31447f7-a279-235e-1c13-5e1332ac6f71	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	228000.00	228000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c3b79a4d-14cd-8b0c-643a-1e51d917236f	6aaca83f-9e2d-72bf-2873-cc7f244f91a5	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	128000.00	128000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c4254748-163c-c056-2806-836fd70067ee	0110e115-3f2e-645f-fa51-3f844cd6227e	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	440000.00	440000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c594bea9-c6c3-df5e-3c43-67be9a76374e	9e038dae-c384-1ce5-0dc2-493dd9c9720e	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	420000.00	420000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c5b87c76-1516-4268-4dfe-030ffdab04d2	53265692-ac5b-a712-54c9-eeb3f10efef2	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	152000.00	152000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c810d02a-dc97-f0a3-dd2a-35c1baf84095	143d6851-c81c-f1db-df43-09e721081b95	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	156000.00	156000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c8812907-3f2e-288b-ce2a-f51edc210dfa	058887ff-6249-66e3-e9b6-6d54d5bedf62	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	368000.00	368000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c8c95c8d-a6ca-2f0c-2901-491214dc43ff	48e0163b-4dfa-3376-dac6-ee5de57f0f99	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	192000.00	192000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d2bc3749-98a4-c0af-d1a2-653a602c2684	c6600f41-5fbd-cbb0-983b-ccbbcbf9636f	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	228000.00	228000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d9b9c7d9-25ee-8548-d06d-52f14f813b22	633de7eb-3b6c-dd5b-49e3-e6218fbb857d	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	124000.00	124000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dbfad812-ac74-d649-c9c4-0f88164f3fe2	df04abe8-20bf-ba46-4e51-73dfb2469b6b	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	252000.00	252000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dfeff0cc-88c1-b4d2-6287-c514bd92c3d4	b094ee94-07db-74de-1151-8dbf3fdc5feb	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	116000.00	116000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e56c85df-82db-df7d-bda2-13f9bdbe2ae4	e665c8c1-23cb-3bc0-bb8a-2ac17e4d8a37	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	312000.00	312000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e6edca5e-cb3e-7cbc-f4c3-23dc932d1b4c	e3d8204f-df7e-d5f0-79cf-7578c1385684	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	366000.00	366000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ef74f6e3-b8d7-d02c-c4c7-1b9a35b0039b	e665c8c1-23cb-3bc0-bb8a-2ac17e4d8a37	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	208000.00	208000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f58be831-e861-9cbe-2870-5e883a046cf7	f70f1cb0-fd2b-e991-19c1-97058bf88682	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	392000.00	392000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f955ef69-6ee0-a918-1394-b96652a8b8ca	fbb030f3-e849-5b81-6934-cf7a89075db1	\N	\N	Vulnerability Assessment	Web Application Vulnerability Assessment	Web Application Vulnerability Assessment	1	\N	Mid	One Time	Remote	\N	Grey Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	136000.00	136000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f986a116-8632-0eaa-227f-c64e9796a59d	b094ee94-07db-74de-1151-8dbf3fdc5feb	\N	\N	Penetration Testing	Network Penetration Testing	External Network Penetration Testing	1	\N	Senior	One Time	Remote	\N	Black Box	Fixed Scope	PDF Report	50-50	\N	\N	\N	15	120	15	120	174000.00	174000.00	0	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: project_task_assignment_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_task_assignment_history ("Id", "TaskId", "EmployeeId", "Action", "ResourceName", "TeamType", "OccurredAtUtc", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: project_task_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_task_assignments ("Id", "TaskId", "EmployeeId", "Role", "AllocatedHours", "UtilizedHours", "TimerStartedAtUtc", "TimerAccumulatedSeconds", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
00dd6693-d2ca-478d-4389-da344c368f77	99586973-768e-349c-8e28-1cfeb637e8e6	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
01292759-81f0-f8d0-2c87-9ee09133ec2a	2422c31b-916e-4fe5-033b-31022aaa1167	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
031cbd1e-b031-d094-0343-105f919757af	d17868f6-0814-13dd-634e-b6b2d4ecc86c	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
039b4d31-3642-5e0d-eebd-ae64a9d167f7	dcb251ad-2672-8a4e-fdb3-ec8491fa22b8	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
050dacda-9888-5514-93ed-73c3c6938e30	382f0b16-e461-a7c5-863c-e9bc60616d43	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
06117af8-1b47-acea-fc42-69315e94e8ad	a4bf11a2-7a15-ff90-457e-260f7f92cfd0	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
07076369-aa82-2da0-343c-35790b3adaa9	7e893b45-db62-a6c7-5c0c-046cf11c69d5	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0719f109-ae8d-6d5a-d589-416e1ef9baa8	e1ff7eaf-6368-d610-cc38-cc7f03c20ff5	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0727f391-8287-4afc-aa9b-c72979c01662	96a53852-bb1d-6b97-cd06-17df8a316227	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
073b3fa5-89d7-15b6-515e-ed0d560430da	72275e9c-6b17-5c3d-522d-b40fe4f89641	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
09edcebd-55e7-541c-6f99-8f49a24ae528	c739729c-832e-440e-850b-cfcb5aa3c4e3	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0aa24faf-7fdf-d39e-0d29-1803fc712c36	73828a7e-0fdf-4efe-fe2f-f677348cddbf	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0bcf98a8-c148-3d66-91e5-b64a95af3292	8838d1d7-b1d6-acbc-1629-8e9f5b55a88c	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0bfd0b7f-1d25-9162-ed74-b64da86e2587	4119855a-3d39-d495-324d-aaac5f41253a	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0dcec7fa-b183-3ba7-18f7-22e9ca0af719	0e323c5f-e8f2-9e1d-2c78-0cc1c1fe25c5	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
103a53b4-75bd-82be-2c7d-fe306cd6e08b	2411f60f-9c2b-f29a-8b6b-8d4f2f67a44c	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
11128b7e-f5e3-e20c-83ec-298d9a6f58f0	6dc4603d-e669-0212-2f96-eabbfd1cbe1b	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
11c215f4-ded6-e7ed-3dfd-e4b15082c66d	b01c70e4-435e-d729-3399-b495d7a11dff	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1278a0cc-9322-f2ce-1d32-b54bebdf9f96	4776779e-6171-04dc-1c86-96d37dfbf32b	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1465c88b-2c91-0539-8f3f-84aa54c7067b	8529f4d8-a55b-6de4-01b6-2088e48e5f26	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
16003997-7ec0-db52-47ca-a3e7940d7a87	abbd98b2-4bb1-f91e-0d87-3618d922937c	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1640553c-1810-eb99-9908-a5deff91c9b0	910cac0b-4e0b-abf1-e256-44f3b960bd1b	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
178f640a-8e1d-5347-12b6-def4273cbef8	55628dfc-0ea6-14f1-4889-dc1f51059a5c	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1a2f9140-224f-f595-12fd-a8897e90cfe3	3b797fa9-948f-9e34-d8b2-cc59cdf3db7f	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1c97cfe7-2e6e-261b-c6f1-3c3e9d18868f	d8d3f1bb-dd5b-3b50-eaba-1165bc47c92a	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1d7a2d58-ebcc-d72f-7c01-a986bdf8b321	2d5cb7f4-83e8-f859-58e6-370b7a9c0fbb	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1f7cec91-c32f-c08b-de05-ff7279e55fe7	790b56c9-52f6-e808-cd2d-936964ddafbb	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1ffd76f3-1dc4-ea99-7fcf-1fa1c3f9a3b8	cc00640a-ce59-f319-97d1-6239f6005410	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
216d161a-1e39-db2a-7cf4-24e53e301a18	f7fa4f52-7923-0c2f-c55e-72e4d3e072a5	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
218b56c1-ff34-5e22-3427-9032cab5dd20	5a4b0709-5665-ba6f-8d00-958a2470e1e9	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
21eb4982-1ae7-eae6-0ab8-08fe0ba6575e	af7a8885-7bc0-babe-250e-f48c12b98882	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
24b49384-96ad-1fdf-ea5b-c3f5fd878633	f2e96fee-693d-abfd-c4bb-82dcb512c375	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
251ae5cb-3f10-6676-960b-dd1ca3163795	a440a173-3e1c-0e1b-c2f9-3fa1c0660f46	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
26377427-74de-1b87-a01a-abd2987a59cf	5396bee6-9298-349a-7ba8-845622969fa6	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2650ad9d-21f2-1f77-5f40-54cefa410135	2aa2f1b5-dade-4e94-0ab6-0fc9a61fdaf8	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
26aacd19-bdf8-1ba4-6a69-d08078a5c6f9	f578d359-1532-182f-4682-f060e766b81f	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
27b85df3-2553-450f-1c21-d9e9f8ec6349	e4442fa1-5fd0-b0c2-b127-57b35e498b6a	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2cab3882-d4cc-a31a-9265-a946bb92d8f3	af40db3e-50dd-a2a9-a6f7-fa828330216c	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2d958790-b4c4-ee03-a897-f6de0039f880	69eb4433-5a14-4fd7-2758-b3dbf02c41a2	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2de849e9-9b35-16da-5b51-f04310cfa42e	230a9869-6de5-2ffe-1a12-de8c09d8fd04	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2eb883c6-ae7f-4c16-e8b1-e8d144bcb377	6afc7e64-e94c-740c-b28f-36d9f59fe93f	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2fa43ccd-f171-a45a-8ccd-2d0b81e5e29c	1ff3686c-0ec8-b3ef-ee27-1ad2b696176a	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3012570d-cf0e-a6ca-b989-2cba1b4fe7b5	f7971552-23bf-2a5b-fabb-32d666057425	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
302f309b-52f5-7979-c81d-2a17976b8b01	cf86816b-4733-b768-2d3c-48c57036443c	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
30501e77-b492-4e8d-8617-6dbc4b328a45	b1c836d4-d646-5408-a297-be35c86f4bee	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
30a2edb6-b370-e349-e56b-9037d3bcef49	a216d3fd-00c6-963e-ccfa-089f7ab624a7	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
310bf57d-14ae-e928-c5b8-2bebb45012fa	1cf87071-09b2-3fd5-563d-0353ea6f505f	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3238f5a1-f5fa-7fa6-793b-0ca6e0470ecd	d4337f62-79ec-fcc5-4347-6df7dcad1bb6	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
33266f1e-49a5-5e05-5f52-daa7833fa63f	fcbfb541-20d2-c804-0023-f5d2eedea5a1	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
33d960aa-cb4d-d93a-50f6-cc237677746c	3197d414-38f3-2a82-e5e4-116033e0b38b	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
343e237c-49f3-24b6-c784-d358b218c9a6	58d26661-dcf5-bd30-10c5-b4485294a5ee	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
352d2acc-fe6e-a6f4-d6e9-751d4e6370ce	9d2ef0f8-cd72-9757-9a75-4c446aa29a6c	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
36d51229-8587-af5d-7e60-382ef9019aa0	4611b5cd-06f7-57e5-30af-7b0664fac152	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
392a69ba-d733-24e6-4567-8b1ea4e421cf	6239a324-448a-e5c4-a3ec-fbf11190c9cb	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
395f361b-a41f-7984-97f2-6b00af8c34d8	34d84bb0-d26b-1c18-4156-270c72b5e632	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3abe99e6-88fa-d360-bf3a-af14c4af266b	e5eeeebe-bbd5-ba03-8700-9bdeda1b75c7	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3ad85666-d0f6-5862-ff0e-94ecb212f5a7	9838722f-1996-7ce1-222f-611c065e3913	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3b20099b-88be-8e45-9c36-1a58b572fbf4	39e4a61d-b50b-e023-acfb-6aa83d742f68	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3b7560f3-164a-4b02-21e7-a549096b39da	0b483d9a-d993-01f1-409c-0fac753dc584	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3be24e15-27a2-706d-5c2d-208cd0d17eea	6972b680-db67-de70-35cc-c15495c1d04f	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3c2bfb53-fd69-a2b7-a9ac-b384ee3efef2	dbb2f747-7f0a-ea79-ceb0-cd14558f3f2f	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3f64bf40-5f20-979e-1e83-3b6ca3260487	ec2af058-dbc8-b4a9-2bde-119937e22e78	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3f83b307-6201-29b5-13f1-0cda9c134d70	d0f092cf-33d0-1683-1d22-14ce5112d0cb	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
41b22417-ffce-c936-f4a5-20adc3c2cea5	983965a1-99b7-cbc9-87c8-1d54b60239de	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4343e174-6f86-cb62-a78a-6196e20307ec	0ed75c6d-4352-50bc-e0c9-1c54e3e79e7c	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
43d82936-81e8-d884-af43-d137496f76cf	4dccb0a0-202c-2e88-6de1-85cce0e7cd1e	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
43ed02e9-e87f-b23d-fb5e-1c847edd006b	33131b4d-3eb1-0ab4-4331-9c51dda28375	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
44e6c2fb-4c68-2d89-7a5e-101a4fa4b94c	361b3bc8-850a-e54c-401d-13b05da75756	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
45908fd1-9259-f596-cf44-fdd8085fe159	e681b3e4-cd6b-2817-fc4b-7cf9c5c4f4f2	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
47d1f8d1-e5f3-d6a1-102d-06f2d13ab68a	5f47ca19-8b79-e8c4-36d7-ccc26b714f72	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4954454a-e878-c474-50a9-7f296eee91c1	0cd28bad-baf6-4933-f2cc-ee2edb31ca19	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
49be1764-2219-de6f-cf65-2f993b217239	1b9b4480-bc53-fbc8-081b-6abafbd415ee	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4b15f8ce-7f1c-9f53-c38b-c55732a7d2ff	d8900408-71ef-0382-21c6-4df03868d18b	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4b40300e-6fc4-29a5-9243-def648d7e122	4c4079b1-d9c4-a8da-3d28-ab7551cee151	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4df13757-8d9e-bcd8-3422-4c26ab5e371e	8b52c2dc-15ed-81bb-8f05-da9f73fbb417	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4f0ea420-5013-e0da-3ca7-7d836f1f3091	dd034b21-aa88-5356-06dc-c058ef94af22	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4f17b38a-6e19-4d66-93b5-ea671ac14dd6	f4e3d28a-c28f-ecf9-0d2f-dd8de6bb2454	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
50dc9ef2-d683-bf23-476e-ab2b6b6d16ee	82b4e6f3-d141-0ab4-3ae7-f26d85843c83	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5262418d-17eb-81c6-dc72-08f1e79f08c5	9c321121-c86c-f29f-6e44-91bcc2084d62	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
533d9d24-33fa-d767-bc63-0b63e6ec4ec5	e71d2102-3c7a-5f71-c21b-6de509fb4009	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5374fad7-6d73-f4e7-2317-13cfc760eea6	ff976402-477e-b14f-7ce5-5a196df836e0	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
558a43d1-5e44-98e0-a683-39575e6b097e	bbfbd5df-0d45-c6e9-7d9d-b6b63dbdbedc	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
579f2532-7204-b965-dc66-ea968057f2b8	3fa60284-733f-ebbd-596b-1f8499371692	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
581a2dc0-f46a-2897-7e3f-9dff50b820b0	8c0e29ad-5bca-61ca-187f-702d077dd36f	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
58d1a663-c66e-701f-6842-312959b57aab	24307fd4-43a4-943a-c113-9cd38c5533a4	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5c1da006-b8f3-eef1-2a59-be0eefec8504	d2cbb131-7e28-aba5-1179-2bec009206d2	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5e018de4-9b3d-93a6-032e-9d3d18281e84	3cd31527-61ff-2ff6-eba4-b528d08d925f	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5e6f02bd-0ae2-bca3-3adf-ae9835cd256c	98940c94-6f58-718e-828f-bd088451b6ce	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5f0040f5-2506-d43b-1063-433b3edb109a	bb0ebf29-a997-7387-3409-8b4b832c4019	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
603a0c6f-8fab-c011-8332-10def9faf152	aea2a4c6-01b0-8b09-606c-e41d27b1ae31	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6176aca2-5c04-1b2e-015b-e8ff8a08e48b	65ae60c2-42a7-bcc9-aaca-a5027b42d181	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6244a055-e0dc-3372-3b7b-df93c5faed57	f074255b-fdfd-fe32-16f1-748d957f9cb6	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6247d6bc-85d0-2e25-d719-30b412bea0f7	91604be1-7037-221b-c136-41154bac2ae0	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
631e028f-91b5-0ea1-70d6-79e1fef458a2	4f460cdf-1446-eea9-126c-39ca8e27be11	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
63577ec0-6c85-9a44-14c7-84acf8c796f1	1adbb3d2-cc85-5003-f96c-dd050e343e63	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
63f61cc4-4370-8320-5c7a-cc50746f3660	b2fb8f18-3e69-dcb5-7543-99387ce00804	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6451abdc-9f67-7eb8-86e3-ed144720a06e	a85d79f7-a765-c18a-50ce-cf8368fd1fc1	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
649e23c7-5521-472f-6c6c-b6c4b7f2589b	c1d16d67-98de-7069-d998-a18d972a530f	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
64ebffb0-c321-2c78-2613-a9dcdac13b9e	a68f739b-e9d8-a3d5-06ce-f8987318645a	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
65cf3ef2-16e8-0e5c-f268-123fe2e7cb6c	efe06203-402a-b105-c7e4-1bd109cc122e	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
67d8458b-ee55-0790-78bc-84d0f0aad965	e54110b0-c635-aad9-e595-0ef37937110e	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
68c207ce-7cbd-9f63-3c64-b7041ef36024	91473b85-6142-3aba-6334-eda6f21edcf0	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
68eb6f8a-9582-a6e8-f9dc-4d2938acfb12	420b48b5-ab1a-c796-3361-8b245aed665e	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6940c009-f1c9-b1fe-7dea-cc41d9227d4d	c0eab036-0413-1ade-b218-e23170d02f48	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6b13c095-ddeb-14b2-5d5f-3db1dad7c124	c12f1e10-96ec-fba6-0aab-bb20aabb6b05	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6f2eea0a-6454-7ddf-c547-d30aa58d8edf	84885283-e2c8-a75c-67a9-084b86db4413	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6f75fb93-3015-f768-0509-55050cb5aef6	e12c2448-1370-0deb-5f39-046586305eac	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
707739bd-c2a7-ce51-8ed2-6387bd2ebe3c	a5d0451f-a889-2d22-4b2a-296752ae81ca	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7086c49f-aebf-493c-f1cb-00c01f89d754	5c8ae252-84e0-ad22-cd65-e044dbd49cec	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
71135434-63ef-caf7-cef5-d08be800161d	1a7c2e45-71ad-d21c-a0f6-b6a85a19d5fd	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
719619ca-5808-88d2-4e95-4af39bc0303a	587846c3-1bbd-ef7c-e9b4-9fa55c4f49ae	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
72486a8f-37c0-7116-7ab1-59113eec4440	103d412b-ecc3-f82d-6fc2-f6940796454d	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
730de29a-e068-bccf-c4ee-20a67cdefc12	f193c79f-cdb7-0d1c-811c-7cf6ae352556	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
73749aa5-ee73-7b13-04db-86f70ddd1c5c	48697479-ce33-9ac0-cb62-15d8131f0a57	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
75173f5f-cd14-78d2-08e9-98b3e0316b3b	1e4a74a6-aa18-b982-654e-ff89f88a496b	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
763b3c91-e281-9e1d-ceb0-77834fbea1b5	cddfefcd-685a-b98b-2884-4b38cb444bf5	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
76912b98-b390-4609-5e95-dcee8950e7aa	d14e32b1-bab8-0409-ba0d-b262a827ed84	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
796e8b18-e0e4-8a53-a710-be885dfa0608	1dc40c25-28e2-7f35-3e4e-4a8900d6ab6e	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7c77a20d-81a5-4220-30d1-b516f7d5ead8	db655801-98d5-c450-e902-a39a24259eac	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7dadd5c0-8fcb-09e3-ee97-e991a6da8bfd	4b3e0b49-7682-7172-5709-85abaffe8330	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7f9ae05c-0563-a591-9b1e-90feb7405512	244508af-5276-9697-546b-6dc137f77ed8	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8033ffb2-6b3c-6992-f7c9-b959f05b1ca2	fc4dd0bb-fc0a-8682-cb63-c726db3e020f	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
834c5736-902a-dfcd-e3e2-ae0c2adaf778	8a8a62f4-dda2-5ec2-2126-0301eec21f89	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
842e02c7-f2cd-c644-d897-1f30fa035c7d	3d51d780-f92d-36fd-a23d-aee80d9c3961	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
84332270-9daa-66c9-5b42-14c737b4f9fd	a39c565a-31d5-362c-3513-218682dbf3b9	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8580b208-7340-bb1d-725c-91720bde013f	21675222-b1ea-7887-07a8-a42df661d60c	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
89f199c8-64e2-ea65-f992-395e069bf1c3	3d4c7351-b685-da5b-6b15-f91c6f5d139e	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8aee9a15-4354-b284-df20-af81131a4eeb	6126dc78-fc3d-55f5-ada4-28aaf31d0ecd	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8bd2961c-d776-59e4-0cc3-fc421161a29a	96961eb7-e14c-b11f-b4b3-258116d42596	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8c5b3856-876a-e267-d86b-00618161f3ed	e83333da-0880-c9f7-e4c5-8bcef9020e5c	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8cb6b92e-638d-f397-2113-e538226572ff	43a0daad-a66e-05de-e7db-6d40787f2800	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8eb4ffbf-d0fd-021e-6528-945aeaae4ef1	4cc03d0d-b1a6-e574-15cf-b083085b0377	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8ee88a6a-65d5-459c-3a5f-9c4bf16cadb9	ffb6e068-bd34-17ff-ef5e-fc57e10131ae	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8f28d162-6b4c-0e08-6957-c76fbebd781f	2b200ee2-2e20-0f5a-e244-6f4c3a842ec1	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8f5a190a-7b4c-7a11-0f45-21f719384fa4	5b35467c-5965-9eac-ac40-6c74f8ac8729	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
900d5a6d-34c1-41aa-c3cc-14c63c0f931b	7f5dbdfb-c409-f8c9-e877-f1414930c378	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
901e2e5f-6eba-9bda-ce54-0ebff1aac1d0	bed411ca-d643-d4f9-c9e1-4b595ae87cab	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9059ba97-7f1f-95f6-b075-88f71c27f163	ef6a1c37-7e3e-91b9-05c0-4bd43269bedf	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
910f949a-7345-94e5-1679-e46f53bd438e	3ef3a0ac-2b97-92b2-2159-7e6278dd6cd4	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
91348b7a-0b96-d1ed-06f5-c59f5526ae62	11b381a6-c913-67e7-85e1-efa06478bfc1	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
92f42a3b-fbe1-a728-81e1-49b3cc960693	ff7e8c76-5f53-21b7-9f04-1bd31d850123	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
93653e1b-8955-3886-7bdc-454fcfcc7b4e	b22e847e-ae88-7d68-a79a-e2ae21d04087	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
93efac02-e3f0-4573-9c7e-ee0cfdeacf1a	520538c9-f041-7879-b9e7-d073882b570c	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
94ec41f2-ae94-0bc7-a46d-1a8722ed5dcc	0c08aae6-c07b-1db9-eb43-16369cd98137	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
94f1c675-ebb5-1d9a-042f-4a4e84bc76fe	98e777a8-05ce-655c-974a-a99b9a856884	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
955397c7-a976-f7a3-b24d-7571e5004340	d1041d56-4ea0-070f-9544-1fa278231716	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
988e45a1-25ea-5b2f-eb01-7485501a5889	9ddd4515-15e0-e979-9b9c-42e50ac9137a	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
98c33619-2804-9aaa-2d91-0be9237f20b9	cc3613e0-a517-69c5-b437-5cb9000a181f	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9939f42c-60d5-fd81-8824-085fcf7ee193	67db144e-9198-bbb5-6389-e00a661742f6	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9969fc52-dada-3f26-9ff2-41d7560a9b77	9add59f1-e99d-cfbc-07fc-8d19eecd6a9c	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9ebbf2d7-6ca1-2b82-8ae2-2650c8f21f5d	e000db1a-7be1-6fe6-20aa-cf82fa09eff3	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9ed92107-2c56-2e5c-fc95-bb9f381ffaa7	e6ea9701-0407-d96d-55d7-b544ccb9271e	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a28544ed-2759-6bcb-db7e-7171aec5aa56	56ac3bb0-cd27-17f8-3578-d5ce68fe56f0	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a29eacfb-dc82-ab3c-aea2-e715ec29a40a	e8fbed49-7cc6-ec60-f1f1-daa3f3dd7048	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a5136f4e-21ae-8ab9-4406-97178f9c2a2e	a49e7ee9-bdaa-a617-98a2-ffa0fdbdfd4b	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a57faa4e-6b5d-b36d-6254-bc1c08ff2e2d	3e00b03b-2546-68d9-0856-4c1f2f553267	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a61247ff-a276-0b61-118a-bfcae9c1e537	2f8f4f74-be0c-3993-a732-fd1c5d8689a7	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a804b9aa-d157-9a88-2dc5-0b088bb1ab33	527d07b4-cdd9-5df5-2d7f-13eb2db3c538	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a881ac35-0e68-95b8-0802-b544c7c48595	16ade31b-6082-b0a8-7326-6cb05a34d034	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a8cc2eee-479f-a869-93ef-b9c6b8670184	a7016f4e-0bc1-5ef0-9c2f-8632db0a86c2	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a90756ba-5432-1c67-30af-38ed6fd13d51	b2d2aa6a-cf44-6b75-a370-d50ebcef9f16	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
aa9f6f99-3cd0-f96f-5d7b-b8b7b47145f3	b602675b-ac8c-f036-f1d0-692b1cd5f64b	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ab5fcc8b-9f11-02f2-2e90-610f5a1812ba	fff67130-68d6-8cd4-0e02-50f08346e9d3	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
abb90b0d-46a1-a6e4-b174-d00ac5d5c235	3e94c690-88de-9f48-077e-3ea9ce812364	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
abbdc717-7df9-1c4b-da59-561612c59d78	3857050b-376e-8c9e-268c-bc01f0a7893b	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ae2170e3-800d-94f9-31b9-34a6005a9ccb	cf8ad680-2962-fe82-4254-88065bacda94	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
af599bda-6d9c-8af5-fa3e-1e5c5a47a33a	0d0f3b7e-bcd4-487f-a2d1-1eba086df1a3	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b046eff5-5418-3ddb-2c58-1a2320024774	e65a9998-da91-3ffd-46cd-b7aafc7b0f16	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b0812407-fc6b-81de-e929-6a2a85f74f06	78a402ec-4886-ed4b-19fe-1d8d235eeeb1	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b21a2dd8-be20-982a-b17d-47ee3dcddff6	b1b856bf-b081-b5b7-01ac-d40d2162eeed	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b3350f5d-1d1e-7f08-91f7-18f2f317662d	50f148dd-5a2a-dd56-61cd-4ca5ae84d6bd	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b3c5f471-00a9-67a8-3388-e243be35b132	d7e86046-ce08-269d-b58b-d6967b1dcf06	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b44aa947-b4d9-3f94-abe8-d223985693fe	8292a3d2-6853-ec8d-c8e8-9734d4b744db	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b4a2bd8f-6ae7-a096-35ac-68f07f012e52	0b2ff424-da29-0310-dd39-7b6acc5c42ae	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b674c8fa-29a5-c4bd-a878-6bc946d60703	718bd32f-1d88-6917-2925-9d4a1bcd399c	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b846f33d-3923-7ee2-1a4a-1bb9086383a7	b659f820-702c-0f3a-08ab-e39a0b314d00	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b946d9c6-9947-bc30-c148-389b99ad7199	3746e898-c9c7-5fb5-1a29-bcb24522864a	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ba0569d0-eaab-07e5-b373-314a125f0c8c	5c6fc2f6-c0cf-023b-23fc-cd63406bf32c	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
bd5967bc-4779-3a5d-cb2b-9fe0718e1bee	69743625-8ebb-55ed-ab42-9047a50a8361	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
be45bcd2-bc8d-8358-1fd4-ef169a87bbfd	60f67279-83bd-8934-0813-3b938c2cb0fb	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
be8ef01c-4d5b-51e7-6b6c-a14c3a52f63c	402eaea5-bfc9-65ee-b5b5-e84add0e2ced	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c15b5181-0147-fca5-91ea-cdf065deeb1c	adcc98b6-203a-0659-2ed2-c8ac38dd3280	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c20bc474-53b8-c6b6-ce75-f5c666e193cd	d45a621b-edb8-d5b5-f8e6-5d129d05ac13	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c426a5e8-faf9-690e-218d-cac7b4e5982f	29adbd62-77f6-c5a3-1d90-7972e9d17f6f	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c689ecae-ff7a-006d-fb42-cb5f60d53ab4	031c00b9-d781-efea-c692-0251a955f889	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c6eabc8c-60b4-6cb0-cdd0-17dd0ba518a2	8a5be865-4d06-26aa-0c6f-c327eb11dd90	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c706bc86-ff9c-b881-e23f-b3f04ceb6fee	2c609f37-b756-b098-d634-ce27d20634d1	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c8b1d30b-8aef-e606-daf7-533bcdd65944	b99a1ee2-595e-2504-4920-8c9a3ad71c57	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c8cdd342-37b0-4f4a-e3d0-2efb3dacfb68	cfc4184e-44af-d17f-fecb-8a1803fd0f45	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c8e3d95d-77a2-cd62-3d15-431e58d5c66f	9d944bb9-db8a-30ec-867f-7465a8f9b92b	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ca2da1a0-80b8-58e1-5328-33aebb6e5f72	eaf1fe5a-8e06-ccc7-c914-7b76aa086b7e	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ca72e5fe-43a6-fcee-bfd0-e89c3c070624	a5d66fd7-0846-6507-e1c2-97595ebe1548	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cb04242a-0ac7-2811-244a-c2e196216173	71cc02e2-4b4e-9c30-6742-7488b401b969	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cb189a8b-ffbf-c8b2-42f8-108e0c245905	23fb5673-8752-ae41-564e-1df390bc21fd	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cc415a7b-6602-a26e-11c8-e96c5f325ca6	ec60027c-cf83-0f05-3628-d56e2eb391d4	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cd20b41c-64ae-349d-eaf0-4463d3381d20	117b7429-39ad-5338-1478-e6cdbe67d984	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cd4aeef1-7bbf-1020-c482-9344b99d2393	eee249e9-74fc-a7c8-7322-6f7383e10ead	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cdd494b0-d60b-44c3-8471-6f98fc90fa14	ae241fa2-eea6-06e3-9fdc-363bc81099b3	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cef3dc30-b88c-4718-3905-9126e4fd0e2b	1d8f2a7d-465b-bf9b-80c7-6cb05fd988af	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cf470432-f3cd-6102-74a1-60929a83646c	0328b882-4d06-9504-0e38-02381c81b5b4	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d30d9514-0a81-a16e-4c4f-3342632ee62b	4150b878-114a-af07-f5fd-cc60d1060754	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d4759503-79ab-56fd-eca6-492964ea8c61	fdbe136d-21af-6772-a525-7bbcc5dd7e6b	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d49077b7-24f0-61bc-cbfe-9e54175805d5	3828443b-c3ff-a127-2027-ab7b22ebdfc4	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d4fb90d5-2ec1-2be1-82e9-214c45c3b992	8068a18f-7587-7b0b-86d3-f74682d82cd4	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d57458b8-3f3b-e90d-a9f1-6e0279ff8fda	9dd1f925-93fd-8b85-b5c6-40a4f237aa69	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d62e7a93-0447-e4a0-47b4-45a3d6d1c1e2	026f99b0-baaa-7d90-6cc7-62d3037632c0	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d64219ce-15ba-dcc1-63d0-57cee31ddd90	f98bb151-5eaf-4b17-d3c9-31fd3bb8f636	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d81ab897-a158-85c8-fa26-a7bae5250c74	c7276b8a-e27d-2911-a649-10e8c9056ba1	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d8faeb1e-e4ae-ed02-067b-2938640ecc04	7af06f00-5bb6-80a6-125f-c26d2b302244	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d957abf3-ec50-d3f1-a6ae-c6c499c7d9e9	c2194423-12b7-71d9-f320-904e7a1980a7	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d98783f3-edca-7be7-0596-42ccaffa0e32	2ef62c9b-2a2e-886f-8963-d79799009886	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
da06612f-18b4-349f-fc49-b222349bcb46	55be1ace-39f0-cc5b-ff33-3f1d8c92bc2b	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dba7385d-bbe4-37e7-028d-2b73dc582af2	29b85339-bf14-cfe6-46c3-f06f016fa801	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dbcbbf37-cef7-e465-bd99-dabb3cb9f2cc	dda50b82-3745-032b-b44c-2be50a27308f	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dc62c930-0730-9186-4f1f-f44f92b7ede5	d753706b-46eb-e347-de80-399f0413c1ce	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dc844045-70eb-052a-4720-74bbd1befba8	915eff31-28b2-c653-75c8-2c2852693a97	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dc9402b3-2693-a18a-6709-588c04c33ff0	859bae89-1fc5-ec39-7fb2-76ce478408c7	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
deef866a-31d6-b44a-06e9-3803517e80d5	66c855c4-e577-ae74-848d-fd828d6eff60	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
def69a9d-86e3-5305-0136-e88c6a920705	5f7794ac-a6b1-db92-1eca-e0583c6cd2cb	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
df4579ab-8a54-2040-f8da-06699e31543c	e308609c-03a2-66b4-c570-c19b5025a5d3	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e1f6dc47-a206-93d9-09ee-94ba2bc9f17a	8de4c2df-3a09-d551-7535-ae022540291a	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e3245f13-2b47-18c3-9e8f-68c979f6f22e	114ef051-9007-4e6d-ac01-27f3b568389b	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e3c256ce-a788-0347-a50f-e6719fa64be8	688c607e-4630-77ad-0039-85858f6803ef	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e52bcb1c-f0e4-d37f-33bd-9dba7b22d0f9	652565e7-164d-ce39-2413-bb5ac6b75158	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e58b5326-4254-a97f-783a-057992355da7	f14f142f-bd8f-6551-d6ed-feac1575b74c	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e89953f6-3f8b-7522-70ad-e648d2ab2b05	c8630013-52ce-6ce6-c8d6-c95ff742673a	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e8b66002-ed20-c899-a7ff-ed353cc5df1c	fb284a71-d4f3-7e10-7318-8dbb98d80a94	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e9c021ae-5c92-b5f9-6020-8d4103401e07	6ab65ddb-b504-1e5e-fd97-1e5fce546987	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e9d3d849-30eb-a1ab-c134-4f23198a84ba	2544e570-7b91-230e-f55f-86cfd26d281d	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ea1b9b53-02c0-1209-85df-447e1e267981	01ec0d0a-a2d6-827b-67cd-a14b804c33f4	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ea51d917-c27a-f04b-fad0-9404eaa9c281	d85ff7f2-80db-ba81-933d-7b9bcdfc95f4	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
eb93e2e1-3e57-71c7-5c68-a8afa42da0e0	141762da-443b-2d5a-2662-3ca05f36c727	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ed77bc48-1695-5dd3-9a6f-21bd428d3282	0d04064b-d626-c1f9-ca22-731fccb78b1e	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ee40140c-7bcf-7d54-69bf-61bbe7c9affb	938a7ae0-d8a9-96fe-21fb-6ac9567691cf	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
eea150de-efc9-5ea1-817b-f016b1e405e1	f69ecebb-c60e-2792-1e6a-ea076f6638e3	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
eeb057d3-0964-7e8c-c983-3896a7a24c0c	32d7cb84-235f-ce31-a255-89bb35d521b1	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f10d6252-735a-4e28-c5a1-b53c81b96783	2cb18817-8da3-91fa-c6c0-de918c834032	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f1276878-d558-e501-65f5-4a2ec45ba0b2	0389f8c7-40b2-b85f-1ecc-81ade5adf12e	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f13abe66-5f30-02c0-aff5-eec212c29e3f	07739df7-095d-494d-977c-dd454e6a9861	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f13f36b4-5386-edef-c8fe-9d4e2e33f7cb	71c5a54b-e5d3-bc80-427c-9aabaf7d288c	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f1f04fcf-6123-1da1-3252-cc014005073d	0e39cb31-00f4-1daf-a9a1-d1c7e65a8b44	00000000-0000-4000-8000-000000000013	Lead	32.00	32.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f205176b-0666-584b-f2c3-c23927315105	cda4d176-543f-63e5-1375-f0a216ed4c51	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f224e991-7225-e141-cfec-2c5b57e252e0	10b2e7a9-b001-4200-8d83-411fe3ac4988	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f361792b-a281-f89a-47a9-300847d050ac	c8958105-c067-10fd-3e08-cc83a4280f51	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f4357894-b446-23e3-1acf-176992c31352	a9e37760-8183-7b3c-02d0-3db6f01b9567	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f455c9e0-e81a-a00e-b3c7-c4254b00be00	7db94100-8bd1-8ed4-fc53-a10b97e069fb	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f600ac57-4e28-672b-7cd5-805cb4908c0a	04ef88b7-eac4-67c6-dee5-e6fd021704e7	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f74d4217-55ce-d086-fdec-03d71a8fa90c	18e189de-a764-afdd-bff6-c455a6b8cc56	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f7670530-557b-781a-8129-67b9ab23d03e	697a017a-f9d5-9dd8-63f4-3436752a0699	00000000-0000-4000-8000-000000000013	Lead	40.00	26.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f7dc95ad-10c8-3495-908c-f65d70bea0e1	6221e983-7d8a-0da0-df09-33b5a344de96	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f8513404-e6be-c09d-3542-613634500eac	28ac7ef7-6326-2279-5019-08f2d3852a08	00000000-0000-4000-8000-000000000013	Lead	48.00	19.20	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f935b02d-54c9-d61a-626b-d89a71d6c067	5ace156c-54b2-eab5-5a13-1265d39f007e	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fa53cd00-1778-a8aa-2484-b9d8c459301c	985091d7-4ccb-68f0-299e-e8aa0b27dd55	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fa657795-b0bd-aab2-f651-3b55053b6438	67bd18b3-79a3-e175-271a-fd1766df2609	00000000-0000-4000-8000-000000000013	Lead	64.00	12.80	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fb929a23-c762-04b5-2abc-21e51aa098b0	f5cf63ab-012d-39f2-7290-bb4136fbffa8	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fc12e47a-e9b8-9975-9d03-95affcc74330	de7cd3eb-c921-019c-6129-984d336cdb75	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fcd25898-6c3c-bd26-7a02-a05f6461f53a	3a05ddfe-7418-be54-0f6f-e0197fa05548	00000000-0000-4000-8000-000000000013	Lead	40.00	40.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fd3a1ea1-4269-6313-24ac-3b0d73b07a8c	2391a014-e1cb-8bc0-a7ee-2486533e51cd	00000000-0000-4000-8000-000000000013	Lead	16.00	0.00	\N	0	t	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: project_tasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_tasks ("Id", "ProjectId", "ProjectServiceId", "Title", "Description", "Period", "Phase", "Stage", "Priority", "PlannedStartDate", "PlannedEndDate", "ActualStartDate", "ActualEndDate", "EstimatedHours", "UtilizedHours", "Progress", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
01ec0d0a-a2d6-827b-67cd-a14b804c33f4	6aaca83f-9e2d-72bf-2873-cc7f244f91a5	8db53daf-2a87-4f81-6d4b-57740dd0b1f6	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2023-03-06	2023-03-13	2023-03-06	2023-03-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
026f99b0-baaa-7d90-6cc7-62d3037632c0	569eb2b4-dce7-5d4f-5e8c-6321a995cf38	2d764f0b-9442-6d98-9684-fc71d242e8db	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2023-10-01	2023-10-08	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
031c00b9-d781-efea-c692-0251a955f889	9e038dae-c384-1ce5-0dc2-493dd9c9720e	c594bea9-c6c3-df5e-3c43-67be9a76374e	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-03-17	2026-03-24	2026-03-17	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0328b882-4d06-9504-0e38-02381c81b5b4	27198d8b-d6cf-276d-f1a7-a66b0abf819a	b869ff8b-af76-d0a4-5a0c-1618e76ea079	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2024-02-20	2024-02-27	2024-02-20	2024-02-27	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0389f8c7-40b2-b85f-1ecc-81ade5adf12e	dd709b37-3794-40c0-13ae-e35ec70100a2	5d17cfaa-2414-8912-f685-90e74b7dabb5	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2025-09-06	2025-09-13	2025-09-06	2025-09-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
04ef88b7-eac4-67c6-dee5-e6fd021704e7	df04abe8-20bf-ba46-4e51-73dfb2469b6b	432e2d21-bf0d-c6b9-b055-37cfaab5c694	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-06-25	2026-07-02	2026-06-25	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
07739df7-095d-494d-977c-dd454e6a9861	058887ff-6249-66e3-e9b6-6d54d5bedf62	9342f7e0-dcf7-04d0-161b-a0dee2dffc6a	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-02-15	2026-02-22	2026-02-15	2026-02-22	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0b2ff424-da29-0310-dd39-7b6acc5c42ae	4b05d47c-011a-ca3b-0c37-a70112d30fe7	0ffc285b-63f3-eb43-95dc-ec01d54e7671	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-01-25	2026-02-01	2026-01-25	2026-02-01	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0b483d9a-d993-01f1-409c-0fac753dc584	8674f685-9512-d7a4-1399-e58a4b88fe5b	6650596e-77bb-9270-ef6a-bd48c3cf470e	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-06-27	2026-07-04	2026-06-27	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0c08aae6-c07b-1db9-eb43-16369cd98137	3de4e5fa-92ba-df0d-06f0-ee3caacf1ffd	3e5533e3-d1c3-3c16-1160-b8eb29172655	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-02-09	2026-02-16	2026-02-09	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0cd28bad-baf6-4933-f2cc-ee2edb31ca19	0005c8ca-9a64-17b8-256b-4ee73b53e81e	996f2546-6740-af77-8960-72e4a7391ca4	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2023-08-26	2023-09-02	2023-08-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0d04064b-d626-c1f9-ca22-731fccb78b1e	569eb2b4-dce7-5d4f-5e8c-6321a995cf38	8548d90d-ef14-4d23-a819-ed401afac78f	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2023-09-11	2023-09-18	2023-09-11	2023-09-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0d0f3b7e-bcd4-487f-a2d1-1eba086df1a3	3de4e5fa-92ba-df0d-06f0-ee3caacf1ffd	3e5533e3-d1c3-3c16-1160-b8eb29172655	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-02-19	2026-02-26	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0e323c5f-e8f2-9e1d-2c78-0cc1c1fe25c5	37f0631e-ff18-137e-2790-48bf2a3aed53	46666780-3545-52dc-2ce0-7b8e53511045	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-07-10	2026-07-17	2026-07-10	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0e39cb31-00f4-1daf-a9a1-d1c7e65a8b44	0005c8ca-9a64-17b8-256b-4ee73b53e81e	3bcefdb5-d53a-c4c7-e086-1d8c187936f3	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2023-08-11	2023-08-18	2023-08-11	2023-08-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0ed75c6d-4352-50bc-e0c9-1c54e3e79e7c	d9c31d7b-328e-11be-73d1-c8c578219b98	290f5384-fa2d-9c09-2ba6-5136299b13c6	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2024-02-26	2024-03-04	2024-02-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
103d412b-ecc3-f82d-6fc2-f6940796454d	6d888c0c-7071-ce2c-a642-2aa1ccff8ce0	6770ea6e-b27f-c489-264d-8837151b0833	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-07-10	2026-07-17	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
10b2e7a9-b001-4200-8d83-411fe3ac4988	8674f685-9512-d7a4-1399-e58a4b88fe5b	51c72dd7-b22d-2483-e76e-ea3b64e6ecae	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-07-07	2026-07-14	2026-07-07	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
114ef051-9007-4e6d-ac01-27f3b568389b	da23da7f-348b-c5d8-c21c-6f5321338b69	6b4f7f9e-d6b3-f178-6b34-76169bc32763	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-03-12	2026-03-19	2026-03-12	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
117b7429-39ad-5338-1478-e6cdbe67d984	e3d8204f-df7e-d5f0-79cf-7578c1385684	e6edca5e-cb3e-7cbc-f4c3-23dc932d1b4c	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2024-01-25	2024-02-01	2024-01-25	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
11b381a6-c913-67e7-85e1-efa06478bfc1	078de404-e464-38fe-bc5a-1eecc50c5cdb	35ab8110-a847-5e90-c961-f4ed123a134c	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-07-13	2026-07-20	2026-07-13	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
141762da-443b-2d5a-2662-3ca05f36c727	9e038dae-c384-1ce5-0dc2-493dd9c9720e	a32944fe-5c3f-7da3-71da-b1c5d67516e6	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-03-07	2026-03-14	2026-03-07	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
16ade31b-6082-b0a8-7326-6cb05a34d034	e1dd4c6b-527b-5243-9f98-cb106d526ed9	3ce7a798-fe69-7f2e-f86b-646973d476cb	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-01-10	2026-01-17	2026-01-10	2026-01-17	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
18e189de-a764-afdd-bff6-c455a6b8cc56	e1dd4c6b-527b-5243-9f98-cb106d526ed9	1afd49cd-ab49-2739-da1a-1fa6dcee5078	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-01-30	2026-02-06	2026-01-30	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1a7c2e45-71ad-d21c-a0f6-b6a85a19d5fd	c6600f41-5fbd-cbb0-983b-ccbbcbf9636f	8ee83ad7-ea23-7f24-7a8c-e4d4f148b1a8	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2024-04-11	2024-04-18	2024-04-11	2024-04-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1adbb3d2-cc85-5003-f96c-dd050e343e63	0ce49262-f49c-2000-fe94-e93c5bdfb327	524898de-b5f7-1fca-dcc5-a7de591c672f	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2024-05-06	2024-05-13	2024-05-06	2024-05-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1b9b4480-bc53-fbc8-081b-6abafbd415ee	b31447f7-a279-235e-1c13-5e1332ac6f71	be756cb9-406f-1c8b-176e-c05db328a779	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2024-03-20	2024-03-27	2024-03-20	2024-03-27	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1cf87071-09b2-3fd5-563d-0353ea6f505f	143d6851-c81c-f1db-df43-09e721081b95	c810d02a-dc97-f0a3-dd2a-35c1baf84095	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-07-01	2026-07-08	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1d8f2a7d-465b-bf9b-80c7-6cb05fd988af	0005c8ca-9a64-17b8-256b-4ee73b53e81e	3bcefdb5-d53a-c4c7-e086-1d8c187936f3	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2023-08-06	2023-08-13	2023-08-06	2023-08-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1dc40c25-28e2-7f35-3e4e-4a8900d6ab6e	078de404-e464-38fe-bc5a-1eecc50c5cdb	087e4b44-d201-7054-1e13-406aff3754c4	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-07-03	2026-07-10	2026-07-03	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1e4a74a6-aa18-b982-654e-ff89f88a496b	dd709b37-3794-40c0-13ae-e35ec70100a2	9279e70e-9cff-a540-aaa0-a69a28e40861	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2025-09-21	2025-09-28	2025-09-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
1ff3686c-0ec8-b3ef-ee27-1ad2b696176a	e4d9ede1-e653-6c3b-1081-c54a2be3f6e0	b623c0cf-5b8b-dde1-39fe-74e26adcdde0	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2023-06-11	2023-06-18	2023-06-11	2023-06-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
21675222-b1ea-7887-07a8-a42df661d60c	da23da7f-348b-c5d8-c21c-6f5321338b69	0dc6d4be-ed14-8849-53b4-dedea1887e8f	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-02-25	2026-03-04	2026-02-25	2026-03-04	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
230a9869-6de5-2ffe-1a12-de8c09d8fd04	b094ee94-07db-74de-1151-8dbf3fdc5feb	f986a116-8632-0eaa-227f-c64e9796a59d	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2023-07-16	2023-07-23	2023-07-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2391a014-e1cb-8bc0-a7ee-2486533e51cd	53265692-ac5b-a712-54c9-eeb3f10efef2	c5b87c76-1516-4268-4dfe-030ffdab04d2	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-07-20	2026-07-27	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
23fb5673-8752-ae41-564e-1df390bc21fd	9df44408-e0f7-1c11-d144-08e51e02851f	35c728c6-8c05-6c76-d801-88762d76500d	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2024-02-11	2024-02-18	2024-02-11	2024-02-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2411f60f-9c2b-f29a-8b6b-8d4f2f67a44c	dd709b37-3794-40c0-13ae-e35ec70100a2	5d17cfaa-2414-8912-f685-90e74b7dabb5	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2025-09-11	2025-09-18	2025-09-11	2025-09-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2422c31b-916e-4fe5-033b-31022aaa1167	4bdd9b6e-dc7e-83df-0e4a-588b718a46de	7506ff05-9ce4-10f9-b6ab-cb812638a200	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-06-11	2026-06-18	2026-06-11	2026-06-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
24307fd4-43a4-943a-c113-9cd38c5533a4	140eef6e-917f-4d05-d414-eaaa470f8665	adfa2cfb-6855-06f9-6831-f1d8989a20c8	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2024-01-11	2024-01-18	2024-01-11	2024-01-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
244508af-5276-9697-546b-6dc137f77ed8	96771845-a6f8-9c00-10b1-7f6e20cb26f2	5fd5d5f2-6564-cb5c-e88a-74ca15afde28	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-02-16	2026-02-23	2026-02-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2544e570-7b91-230e-f55f-86cfd26d281d	589f13e8-777d-9e78-0179-6955019400a4	176462fe-5af9-51eb-df27-127232d7625d	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-03-26	2026-04-02	2026-03-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
28ac7ef7-6326-2279-5019-08f2d3852a08	633de7eb-3b6c-dd5b-49e3-e6218fbb857d	d9b9c7d9-25ee-8548-d06d-52f14f813b22	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-06-28	2026-07-05	2026-06-28	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
29adbd62-77f6-c5a3-1d90-7972e9d17f6f	fbb030f3-e849-5b81-6934-cf7a89075db1	f955ef69-6ee0-a918-1394-b96652a8b8ca	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2024-03-26	2024-04-02	2024-03-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
29b85339-bf14-cfe6-46c3-f06f016fa801	058887ff-6249-66e3-e9b6-6d54d5bedf62	9342f7e0-dcf7-04d0-161b-a0dee2dffc6a	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-02-25	2026-03-04	2026-02-25	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2aa2f1b5-dade-4e94-0ab6-0fc9a61fdaf8	b31447f7-a279-235e-1c13-5e1332ac6f71	be756cb9-406f-1c8b-176e-c05db328a779	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2024-03-30	2024-04-06	2024-03-30	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2b200ee2-2e20-0f5a-e244-6f4c3a842ec1	fbb030f3-e849-5b81-6934-cf7a89075db1	f955ef69-6ee0-a918-1394-b96652a8b8ca	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2024-03-21	2024-03-28	2024-03-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2c609f37-b756-b098-d634-ce27d20634d1	6d888c0c-7071-ce2c-a642-2aa1ccff8ce0	0b16929b-f648-0774-3d3a-04ee872062d9	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-06-25	2026-07-02	2026-06-25	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2cb18817-8da3-91fa-c6c0-de918c834032	27198d8b-d6cf-276d-f1a7-a66b0abf819a	508bc02a-7f4d-cd33-1037-15ea3915806c	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2024-03-06	2024-03-13	2024-03-06	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2d5cb7f4-83e8-f859-58e6-370b7a9c0fbb	6aaca83f-9e2d-72bf-2873-cc7f244f91a5	c3b79a4d-14cd-8b0c-643a-1e51d917236f	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2023-03-26	2023-04-02	2023-03-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2ef62c9b-2a2e-886f-8963-d79799009886	df04abe8-20bf-ba46-4e51-73dfb2469b6b	dbfad812-ac74-d649-c9c4-0f88164f3fe2	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-06-20	2026-06-27	2026-06-20	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2f8f4f74-be0c-3993-a732-fd1c5d8689a7	48e0163b-4dfa-3376-dac6-ee5de57f0f99	410e3e7a-d656-735f-e216-9adf10ef7703	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-03-02	2026-03-09	2026-03-02	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3197d414-38f3-2a82-e5e4-116033e0b38b	45f61698-e7ca-9049-dce4-2678530df87e	93df6167-e309-f86c-dd0e-b74192db38de	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2023-05-11	2023-05-18	2023-05-11	2023-05-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
32d7cb84-235f-ce31-a255-89bb35d521b1	0110e115-3f2e-645f-fa51-3f844cd6227e	c4254748-163c-c056-2806-836fd70067ee	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-07-20	2026-07-27	2026-07-20	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
33131b4d-3eb1-0ab4-4331-9c51dda28375	48e0163b-4dfa-3376-dac6-ee5de57f0f99	c8c95c8d-a6ca-2f0c-2901-491214dc43ff	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-02-20	2026-02-27	2026-02-20	2026-02-27	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
34d84bb0-d26b-1c18-4156-270c72b5e632	4bdd9b6e-dc7e-83df-0e4a-588b718a46de	7506ff05-9ce4-10f9-b6ab-cb812638a200	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-06-06	2026-06-13	2026-06-06	2026-06-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
361b3bc8-850a-e54c-401d-13b05da75756	e3d8204f-df7e-d5f0-79cf-7578c1385684	7eb667b3-3f3f-ad65-a874-8eb4e5ce0c06	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2024-01-30	2024-02-06	2024-01-30	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3746e898-c9c7-5fb5-1a29-bcb24522864a	bbdd9713-b12d-1026-241e-f23f2881fbd6	8ed27ef1-635a-a926-f5c3-e43ebbe5461c	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2023-01-25	2023-02-01	2023-01-25	2023-02-01	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3828443b-c3ff-a127-2027-ab7b22ebdfc4	b71355b0-ed52-fd33-d6f7-87bb249aacce	b4f2e875-9fa4-0897-f4ed-4cd0e4534ed9	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-02-14	2026-02-21	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
382f0b16-e461-a7c5-863c-e9bc60616d43	42c28ff9-518b-917f-58fb-322aa28ffc9f	0c256a9f-e032-9c16-b370-382f769ba40d	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-02-04	2026-02-11	2026-02-04	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3857050b-376e-8c9e-268c-bc01f0a7893b	b31447f7-a279-235e-1c13-5e1332ac6f71	31073bb0-6430-4113-7806-da6542c7ef70	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2024-04-04	2024-04-11	2024-04-04	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
39e4a61d-b50b-e023-acfb-6aa83d742f68	0110e115-3f2e-645f-fa51-3f844cd6227e	7b6a309b-6e0f-9c7f-5bd0-ff4f96ace4a5	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-07-05	2026-07-12	2026-07-05	2026-07-12	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3a05ddfe-7418-be54-0f6f-e0197fa05548	e665c8c1-23cb-3bc0-bb8a-2ac17e4d8a37	e56c85df-82db-df7d-bda2-13f9bdbe2ae4	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2024-06-06	2024-06-13	2024-06-06	2024-06-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3b797fa9-948f-9e34-d8b2-cc59cdf3db7f	6aaca83f-9e2d-72bf-2873-cc7f244f91a5	8db53daf-2a87-4f81-6d4b-57740dd0b1f6	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2023-03-16	2023-03-23	2023-03-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3cd31527-61ff-2ff6-eba4-b528d08d925f	fbb030f3-e849-5b81-6934-cf7a89075db1	f955ef69-6ee0-a918-1394-b96652a8b8ca	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2024-03-31	2024-04-07	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3d4c7351-b685-da5b-6b15-f91c6f5d139e	589f13e8-777d-9e78-0179-6955019400a4	7d6e6bdb-5c0b-00ea-a1f2-fdf1754f994d	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-03-06	2026-03-13	2026-03-06	2026-03-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3d51d780-f92d-36fd-a23d-aee80d9c3961	569eb2b4-dce7-5d4f-5e8c-6321a995cf38	8548d90d-ef14-4d23-a819-ed401afac78f	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2023-09-16	2023-09-23	2023-09-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3e00b03b-2546-68d9-0856-4c1f2f553267	45f61698-e7ca-9049-dce4-2678530df87e	93df6167-e309-f86c-dd0e-b74192db38de	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2023-05-06	2023-05-13	2023-05-06	2023-05-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3e94c690-88de-9f48-077e-3ea9ce812364	9e038dae-c384-1ce5-0dc2-493dd9c9720e	c594bea9-c6c3-df5e-3c43-67be9a76374e	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-03-22	2026-03-29	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3ef3a0ac-2b97-92b2-2159-7e6278dd6cd4	b094ee94-07db-74de-1151-8dbf3fdc5feb	f986a116-8632-0eaa-227f-c64e9796a59d	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2023-07-06	2023-07-13	2023-07-06	2023-07-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3fa60284-733f-ebbd-596b-1f8499371692	2b6e8fc3-44f8-a096-04cb-40f258f06eb4	3676c60b-0bdd-5476-2391-778b0e93daf9	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-03-30	2026-04-06	2026-03-30	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
402eaea5-bfc9-65ee-b5b5-e84add0e2ced	6d888c0c-7071-ce2c-a642-2aa1ccff8ce0	0b16929b-f648-0774-3d3a-04ee872062d9	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-06-20	2026-06-27	2026-06-20	2026-06-27	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4119855a-3d39-d495-324d-aaac5f41253a	e1dd4c6b-527b-5243-9f98-cb106d526ed9	3ce7a798-fe69-7f2e-f86b-646973d476cb	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-01-20	2026-01-27	2026-01-20	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4150b878-114a-af07-f5fd-cc60d1060754	8674f685-9512-d7a4-1399-e58a4b88fe5b	51c72dd7-b22d-2483-e76e-ea3b64e6ecae	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-07-02	2026-07-09	2026-07-02	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
420b48b5-ab1a-c796-3361-8b245aed665e	f70f1cb0-fd2b-e991-19c1-97058bf88682	2a603970-bdf9-5ed1-4f85-dbdc47f8f7b9	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2024-01-30	2024-02-06	2024-01-30	2024-02-06	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
43a0daad-a66e-05de-e7db-6d40787f2800	569eb2b4-dce7-5d4f-5e8c-6321a995cf38	2d764f0b-9442-6d98-9684-fc71d242e8db	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2023-09-26	2023-10-03	2023-09-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4611b5cd-06f7-57e5-30af-7b0664fac152	0ce49262-f49c-2000-fe94-e93c5bdfb327	b5ecadf8-885e-c8e3-3415-ffc86e5f1ff7	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2024-05-21	2024-05-28	2024-05-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4776779e-6171-04dc-1c86-96d37dfbf32b	9df44408-e0f7-1c11-d144-08e51e02851f	10670d63-9013-e4a3-fff4-2bee3401de6e	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2024-02-21	2024-02-28	2024-02-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
48697479-ce33-9ac0-cb62-15d8131f0a57	058887ff-6249-66e3-e9b6-6d54d5bedf62	c8812907-3f2e-288b-ce2a-f51edc210dfa	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-03-07	2026-03-14	2026-03-07	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4b3e0b49-7682-7172-5709-85abaffe8330	569eb2b4-dce7-5d4f-5e8c-6321a995cf38	8548d90d-ef14-4d23-a819-ed401afac78f	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2023-09-06	2023-09-13	2023-09-06	2023-09-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4c4079b1-d9c4-a8da-3d28-ab7551cee151	e4d9ede1-e653-6c3b-1081-c54a2be3f6e0	61ee7a2d-9ea7-253e-2b90-80fe738f69e5	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2023-06-21	2023-06-28	2023-06-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4cc03d0d-b1a6-e574-15cf-b083085b0377	e665c8c1-23cb-3bc0-bb8a-2ac17e4d8a37	ef74f6e3-b8d7-d02c-c4c7-1b9a35b0039b	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2024-06-21	2024-06-28	2024-06-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4dccb0a0-202c-2e88-6de1-85cce0e7cd1e	db951439-0ec5-b321-9266-611d80ea0ffa	05bac44a-67a8-dea6-95d3-36e7c82a5a70	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-03-16	2026-03-23	2026-03-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4f460cdf-1446-eea9-126c-39ca8e27be11	804038cb-1b0f-af18-247c-514d7edf2757	756926a6-d053-4adc-4345-9808c00cef68	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2023-04-11	2023-04-18	2023-04-11	2023-04-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
50f148dd-5a2a-dd56-61cd-4ca5ae84d6bd	e4d9ede1-e653-6c3b-1081-c54a2be3f6e0	61ee7a2d-9ea7-253e-2b90-80fe738f69e5	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2023-06-26	2023-07-03	2023-06-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
520538c9-f041-7879-b9e7-d073882b570c	140eef6e-917f-4d05-d414-eaaa470f8665	adfa2cfb-6855-06f9-6831-f1d8989a20c8	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2024-01-16	2024-01-23	2024-01-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
527d07b4-cdd9-5df5-2d7f-13eb2db3c538	3de4e5fa-92ba-df0d-06f0-ee3caacf1ffd	3e5533e3-d1c3-3c16-1160-b8eb29172655	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-02-14	2026-02-21	2026-02-14	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5396bee6-9298-349a-7ba8-845622969fa6	da23da7f-348b-c5d8-c21c-6f5321338b69	0dc6d4be-ed14-8849-53b4-dedea1887e8f	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-02-20	2026-02-27	2026-02-20	2026-02-27	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
55628dfc-0ea6-14f1-4889-dc1f51059a5c	d9c31d7b-328e-11be-73d1-c8c578219b98	290f5384-fa2d-9c09-2ba6-5136299b13c6	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2024-02-21	2024-02-28	2024-02-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
55be1ace-39f0-cc5b-ff33-3f1d8c92bc2b	db951439-0ec5-b321-9266-611d80ea0ffa	05bac44a-67a8-dea6-95d3-36e7c82a5a70	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-03-11	2026-03-18	2026-03-11	2026-03-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
56ac3bb0-cd27-17f8-3578-d5ce68fe56f0	9df44408-e0f7-1c11-d144-08e51e02851f	10670d63-9013-e4a3-fff4-2bee3401de6e	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2024-02-26	2024-03-04	2024-02-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
587846c3-1bbd-ef7c-e9b4-9fa55c4f49ae	d9c31d7b-328e-11be-73d1-c8c578219b98	1e35a5bc-4e01-b9d6-a46e-53bf40227634	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2024-02-11	2024-02-18	2024-02-11	2024-02-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
58d26661-dcf5-bd30-10c5-b4485294a5ee	bbdd9713-b12d-1026-241e-f23f2881fbd6	2df0e698-e269-9722-1baf-1ef46b658d8d	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2023-02-14	2023-02-21	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5a4b0709-5665-ba6f-8d00-958a2470e1e9	df04abe8-20bf-ba46-4e51-73dfb2469b6b	dbfad812-ac74-d649-c9c4-0f88164f3fe2	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-06-15	2026-06-22	2026-06-15	2026-06-22	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5ace156c-54b2-eab5-5a13-1265d39f007e	9e038dae-c384-1ce5-0dc2-493dd9c9720e	a32944fe-5c3f-7da3-71da-b1c5d67516e6	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-02-25	2026-03-04	2026-02-25	2026-03-04	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5b35467c-5965-9eac-ac40-6c74f8ac8729	db951439-0ec5-b321-9266-611d80ea0ffa	12cc8282-faf3-2c4e-73cf-0174d98d5cfd	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-03-31	2026-04-07	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5c6fc2f6-c0cf-023b-23fc-cd63406bf32c	96771845-a6f8-9c00-10b1-7f6e20cb26f2	5fd5d5f2-6564-cb5c-e88a-74ca15afde28	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-02-11	2026-02-18	2026-02-11	2026-02-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5c8ae252-84e0-ad22-cd65-e044dbd49cec	f70f1cb0-fd2b-e991-19c1-97058bf88682	f58be831-e861-9cbe-2870-5e883a046cf7	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2024-02-09	2024-02-16	2024-02-09	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5f47ca19-8b79-e8c4-36d7-ccc26b714f72	804038cb-1b0f-af18-247c-514d7edf2757	b95d4d6f-04a8-34b3-8078-8418577a24a1	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2023-04-26	2023-05-03	2023-04-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
5f7794ac-a6b1-db92-1eca-e0583c6cd2cb	b094ee94-07db-74de-1151-8dbf3fdc5feb	dfeff0cc-88c1-b4d2-6287-c514bd92c3d4	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2023-07-31	2023-08-07	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
60f67279-83bd-8934-0813-3b938c2cb0fb	9e038dae-c384-1ce5-0dc2-493dd9c9720e	a32944fe-5c3f-7da3-71da-b1c5d67516e6	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-03-02	2026-03-09	2026-03-02	2026-03-09	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6126dc78-fc3d-55f5-ada4-28aaf31d0ecd	0110e115-3f2e-645f-fa51-3f844cd6227e	7b6a309b-6e0f-9c7f-5bd0-ff4f96ace4a5	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-06-30	2026-07-07	2026-06-30	2026-07-07	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6221e983-7d8a-0da0-df09-33b5a344de96	b094ee94-07db-74de-1151-8dbf3fdc5feb	dfeff0cc-88c1-b4d2-6287-c514bd92c3d4	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2023-07-26	2023-08-02	2023-07-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6239a324-448a-e5c4-a3ec-fbf11190c9cb	804038cb-1b0f-af18-247c-514d7edf2757	756926a6-d053-4adc-4345-9808c00cef68	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2023-04-16	2023-04-23	2023-04-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
652565e7-164d-ce39-2413-bb5ac6b75158	b71355b0-ed52-fd33-d6f7-87bb249aacce	ab011c73-dd7f-2a45-79d6-972cc0101c1b	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-01-25	2026-02-01	2026-01-25	2026-02-01	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
65ae60c2-42a7-bcc9-aaca-a5027b42d181	4b05d47c-011a-ca3b-0c37-a70112d30fe7	0ffc285b-63f3-eb43-95dc-ec01d54e7671	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-01-20	2026-01-27	2026-01-20	2026-01-27	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
66c855c4-e577-ae74-848d-fd828d6eff60	37f0631e-ff18-137e-2790-48bf2a3aed53	363b3132-f311-8115-0a6a-4833b3d8032a	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-06-30	2026-07-07	2026-06-30	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
67bd18b3-79a3-e175-271a-fd1766df2609	140eef6e-917f-4d05-d414-eaaa470f8665	9863f9d0-1640-009c-1811-6d083d585ff9	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2024-01-26	2024-02-02	2024-01-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
67db144e-9198-bbb5-6389-e00a661742f6	48e0163b-4dfa-3376-dac6-ee5de57f0f99	c8c95c8d-a6ca-2f0c-2901-491214dc43ff	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-02-15	2026-02-22	2026-02-15	2026-02-22	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
688c607e-4630-77ad-0039-85858f6803ef	140eef6e-917f-4d05-d414-eaaa470f8665	9863f9d0-1640-009c-1811-6d083d585ff9	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2024-01-21	2024-01-28	2024-01-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6972b680-db67-de70-35cc-c15495c1d04f	4b05d47c-011a-ca3b-0c37-a70112d30fe7	2bf6eb9a-efae-81ab-2269-3090bd9d5d58	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-02-09	2026-02-16	2026-02-09	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
69743625-8ebb-55ed-ab42-9047a50a8361	4bdd9b6e-dc7e-83df-0e4a-588b718a46de	7506ff05-9ce4-10f9-b6ab-cb812638a200	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-06-16	2026-06-23	2026-06-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
697a017a-f9d5-9dd8-63f4-3436752a0699	589f13e8-777d-9e78-0179-6955019400a4	7d6e6bdb-5c0b-00ea-a1f2-fdf1754f994d	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-03-16	2026-03-23	2026-03-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
69eb4433-5a14-4fd7-2758-b3dbf02c41a2	0110e115-3f2e-645f-fa51-3f844cd6227e	c4254748-163c-c056-2806-836fd70067ee	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-07-25	2026-08-01	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6ab65ddb-b504-1e5e-fd97-1e5fce546987	078de404-e464-38fe-bc5a-1eecc50c5cdb	087e4b44-d201-7054-1e13-406aff3754c4	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-06-28	2026-07-05	2026-06-28	2026-07-05	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6afc7e64-e94c-740c-b28f-36d9f59fe93f	0ce49262-f49c-2000-fe94-e93c5bdfb327	b5ecadf8-885e-c8e3-3415-ffc86e5f1ff7	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2024-05-26	2024-06-02	2024-05-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6dc4603d-e669-0212-2f96-eabbfd1cbe1b	589f13e8-777d-9e78-0179-6955019400a4	176462fe-5af9-51eb-df27-127232d7625d	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-03-21	2026-03-28	2026-03-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
718bd32f-1d88-6917-2925-9d4a1bcd399c	27198d8b-d6cf-276d-f1a7-a66b0abf819a	508bc02a-7f4d-cd33-1037-15ea3915806c	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2024-03-16	2024-03-23	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
71c5a54b-e5d3-bc80-427c-9aabaf7d288c	0110e115-3f2e-645f-fa51-3f844cd6227e	7b6a309b-6e0f-9c7f-5bd0-ff4f96ace4a5	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-07-10	2026-07-17	2026-07-10	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
71cc02e2-4b4e-9c30-6742-7488b401b969	e3d8204f-df7e-d5f0-79cf-7578c1385684	e6edca5e-cb3e-7cbc-f4c3-23dc932d1b4c	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2024-01-20	2024-01-27	2024-01-20	2024-01-27	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
72275e9c-6b17-5c3d-522d-b40fe4f89641	53265692-ac5b-a712-54c9-eeb3f10efef2	6cd5d5d0-3b08-2bec-45cd-a5b847830ade	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-06-25	2026-07-02	2026-06-25	2026-07-02	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
73828a7e-0fdf-4efe-fe2f-f677348cddbf	e4d9ede1-e653-6c3b-1081-c54a2be3f6e0	b623c0cf-5b8b-dde1-39fe-74e26adcdde0	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2023-06-06	2023-06-13	2023-06-06	2023-06-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
78a402ec-4886-ed4b-19fe-1d8d235eeeb1	e665c8c1-23cb-3bc0-bb8a-2ac17e4d8a37	ef74f6e3-b8d7-d02c-c4c7-1b9a35b0039b	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2024-07-01	2024-07-08	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
790b56c9-52f6-e808-cd2d-936964ddafbb	bbdd9713-b12d-1026-241e-f23f2881fbd6	8ed27ef1-635a-a926-f5c3-e43ebbe5461c	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2023-01-30	2023-02-06	2023-01-30	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7af06f00-5bb6-80a6-125f-c26d2b302244	c6600f41-5fbd-cbb0-983b-ccbbcbf9636f	d2bc3749-98a4-c0af-d1a2-653a602c2684	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2024-04-26	2024-05-03	2024-04-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7db94100-8bd1-8ed4-fc53-a10b97e069fb	48e0163b-4dfa-3376-dac6-ee5de57f0f99	c8c95c8d-a6ca-2f0c-2901-491214dc43ff	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-02-25	2026-03-04	2026-02-25	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7e893b45-db62-a6c7-5c0c-046cf11c69d5	f70f1cb0-fd2b-e991-19c1-97058bf88682	2a603970-bdf9-5ed1-4f85-dbdc47f8f7b9	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2024-01-25	2024-02-01	2024-01-25	2024-02-01	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
7f5dbdfb-c409-f8c9-e877-f1414930c378	058887ff-6249-66e3-e9b6-6d54d5bedf62	c8812907-3f2e-288b-ce2a-f51edc210dfa	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-03-02	2026-03-09	2026-03-02	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8068a18f-7587-7b0b-86d3-f74682d82cd4	6aaca83f-9e2d-72bf-2873-cc7f244f91a5	8db53daf-2a87-4f81-6d4b-57740dd0b1f6	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2023-03-11	2023-03-18	2023-03-11	2023-03-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8292a3d2-6853-ec8d-c8e8-9734d4b744db	dd709b37-3794-40c0-13ae-e35ec70100a2	9279e70e-9cff-a540-aaa0-a69a28e40861	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2025-09-26	2025-10-03	2025-09-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
82b4e6f3-d141-0ab4-3ae7-f26d85843c83	dd709b37-3794-40c0-13ae-e35ec70100a2	5d17cfaa-2414-8912-f685-90e74b7dabb5	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2025-09-16	2025-09-23	2025-09-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
84885283-e2c8-a75c-67a9-084b86db4413	da23da7f-348b-c5d8-c21c-6f5321338b69	0dc6d4be-ed14-8849-53b4-dedea1887e8f	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-03-02	2026-03-09	2026-03-02	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8529f4d8-a55b-6de4-01b6-2088e48e5f26	8674f685-9512-d7a4-1399-e58a4b88fe5b	6650596e-77bb-9270-ef6a-bd48c3cf470e	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-06-17	2026-06-24	2026-06-17	2026-06-24	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
859bae89-1fc5-ec39-7fb2-76ce478408c7	6aaca83f-9e2d-72bf-2873-cc7f244f91a5	c3b79a4d-14cd-8b0c-643a-1e51d917236f	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2023-03-21	2023-03-28	2023-03-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8838d1d7-b1d6-acbc-1629-8e9f5b55a88c	27198d8b-d6cf-276d-f1a7-a66b0abf819a	b869ff8b-af76-d0a4-5a0c-1618e76ea079	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2024-03-01	2024-03-08	2024-03-01	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8a5be865-4d06-26aa-0c6f-c327eb11dd90	589f13e8-777d-9e78-0179-6955019400a4	176462fe-5af9-51eb-df27-127232d7625d	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-03-31	2026-04-07	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8a8a62f4-dda2-5ec2-2126-0301eec21f89	42c28ff9-518b-917f-58fb-322aa28ffc9f	15b0f2d9-54fd-59a8-59fd-3a530cf4b72f	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-02-14	2026-02-21	2026-02-14	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8b52c2dc-15ed-81bb-8f05-da9f73fbb417	143d6851-c81c-f1db-df43-09e721081b95	1054551a-5919-4157-25f3-f277178825bd	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-06-11	2026-06-18	2026-06-11	2026-06-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8c0e29ad-5bca-61ca-187f-702d077dd36f	e1dd4c6b-527b-5243-9f98-cb106d526ed9	3ce7a798-fe69-7f2e-f86b-646973d476cb	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-01-15	2026-01-22	2026-01-15	2026-01-22	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8de4c2df-3a09-d551-7535-ae022540291a	143d6851-c81c-f1db-df43-09e721081b95	c810d02a-dc97-f0a3-dd2a-35c1baf84095	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-06-21	2026-06-28	2026-06-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
910cac0b-4e0b-abf1-e256-44f3b960bd1b	c6600f41-5fbd-cbb0-983b-ccbbcbf9636f	d2bc3749-98a4-c0af-d1a2-653a602c2684	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2024-04-21	2024-04-28	2024-04-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
91473b85-6142-3aba-6334-eda6f21edcf0	e1dd4c6b-527b-5243-9f98-cb106d526ed9	1afd49cd-ab49-2739-da1a-1fa6dcee5078	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-02-04	2026-02-11	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
915eff31-28b2-c653-75c8-2c2852693a97	e3d8204f-df7e-d5f0-79cf-7578c1385684	e6edca5e-cb3e-7cbc-f4c3-23dc932d1b4c	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2024-01-15	2024-01-22	2024-01-15	2024-01-22	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
91604be1-7037-221b-c136-41154bac2ae0	4b05d47c-011a-ca3b-0c37-a70112d30fe7	0ffc285b-63f3-eb43-95dc-ec01d54e7671	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-01-30	2026-02-06	2026-01-30	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
938a7ae0-d8a9-96fe-21fb-6ac9567691cf	42c28ff9-518b-917f-58fb-322aa28ffc9f	15b0f2d9-54fd-59a8-59fd-3a530cf4b72f	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-02-19	2026-02-26	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
96961eb7-e14c-b11f-b4b3-258116d42596	d9c31d7b-328e-11be-73d1-c8c578219b98	1e35a5bc-4e01-b9d6-a46e-53bf40227634	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2024-02-06	2024-02-13	2024-02-06	2024-02-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
96a53852-bb1d-6b97-cd06-17df8a316227	140eef6e-917f-4d05-d414-eaaa470f8665	9863f9d0-1640-009c-1811-6d083d585ff9	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2024-01-31	2024-02-07	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9838722f-1996-7ce1-222f-611c065e3913	e665c8c1-23cb-3bc0-bb8a-2ac17e4d8a37	e56c85df-82db-df7d-bda2-13f9bdbe2ae4	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2024-06-16	2024-06-23	2024-06-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
983965a1-99b7-cbc9-87c8-1d54b60239de	45f61698-e7ca-9049-dce4-2678530df87e	6d7da59a-e68e-3852-6e06-1caa42acc509	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2023-05-21	2023-05-28	2023-05-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
985091d7-4ccb-68f0-299e-e8aa0b27dd55	37f0631e-ff18-137e-2790-48bf2a3aed53	363b3132-f311-8115-0a6a-4833b3d8032a	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-06-20	2026-06-27	2026-06-20	2026-06-27	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
98940c94-6f58-718e-828f-bd088451b6ce	b31447f7-a279-235e-1c13-5e1332ac6f71	31073bb0-6430-4113-7806-da6542c7ef70	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2024-04-14	2024-04-21	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
98e777a8-05ce-655c-974a-a99b9a856884	804038cb-1b0f-af18-247c-514d7edf2757	756926a6-d053-4adc-4345-9808c00cef68	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2023-04-06	2023-04-13	2023-04-06	2023-04-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
99586973-768e-349c-8e28-1cfeb637e8e6	9df44408-e0f7-1c11-d144-08e51e02851f	35c728c6-8c05-6c76-d801-88762d76500d	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2024-02-16	2024-02-23	2024-02-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9add59f1-e99d-cfbc-07fc-8d19eecd6a9c	2b6e8fc3-44f8-a096-04cb-40f258f06eb4	49421cfd-1bd3-b93a-27cd-301b7407c754	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-03-20	2026-03-27	2026-03-20	2026-03-27	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9c321121-c86c-f29f-6e44-91bcc2084d62	0ce49262-f49c-2000-fe94-e93c5bdfb327	b5ecadf8-885e-c8e3-3415-ffc86e5f1ff7	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2024-05-31	2024-06-07	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9d2ef0f8-cd72-9757-9a75-4c446aa29a6c	fbb030f3-e849-5b81-6934-cf7a89075db1	4b752a38-4211-7934-a715-2b5b05578797	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2024-03-11	2024-03-18	2024-03-11	2024-03-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9d944bb9-db8a-30ec-867f-7465a8f9b92b	0005c8ca-9a64-17b8-256b-4ee73b53e81e	3bcefdb5-d53a-c4c7-e086-1d8c187936f3	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2023-08-16	2023-08-23	2023-08-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9dd1f925-93fd-8b85-b5c6-40a4f237aa69	e3d8204f-df7e-d5f0-79cf-7578c1385684	7eb667b3-3f3f-ad65-a874-8eb4e5ce0c06	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2024-02-04	2024-02-11	2024-02-04	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9ddd4515-15e0-e979-9b9c-42e50ac9137a	0005c8ca-9a64-17b8-256b-4ee73b53e81e	996f2546-6740-af77-8960-72e4a7391ca4	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2023-08-31	2023-09-07	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a216d3fd-00c6-963e-ccfa-089f7ab624a7	3de4e5fa-92ba-df0d-06f0-ee3caacf1ffd	89a93f8f-a20a-9468-5381-de195e92438b	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-01-30	2026-02-06	2026-01-30	2026-02-06	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a39c565a-31d5-362c-3513-218682dbf3b9	4b05d47c-011a-ca3b-0c37-a70112d30fe7	2bf6eb9a-efae-81ab-2269-3090bd9d5d58	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-02-04	2026-02-11	2026-02-04	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a440a173-3e1c-0e1b-c2f9-3fa1c0660f46	633de7eb-3b6c-dd5b-49e3-e6218fbb857d	2fc2dee5-f447-d953-9b34-7168fd912855	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-06-13	2026-06-20	2026-06-13	2026-06-20	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a49e7ee9-bdaa-a617-98a2-ffa0fdbdfd4b	8674f685-9512-d7a4-1399-e58a4b88fe5b	6650596e-77bb-9270-ef6a-bd48c3cf470e	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-06-22	2026-06-29	2026-06-22	2026-06-29	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a4bf11a2-7a15-ff90-457e-260f7f92cfd0	d9c31d7b-328e-11be-73d1-c8c578219b98	290f5384-fa2d-9c09-2ba6-5136299b13c6	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2024-03-02	2024-03-09	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a5d0451f-a889-2d22-4b2a-296752ae81ca	e3d8204f-df7e-d5f0-79cf-7578c1385684	7eb667b3-3f3f-ad65-a874-8eb4e5ce0c06	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2024-02-09	2024-02-16	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a5d66fd7-0846-6507-e1c2-97595ebe1548	27198d8b-d6cf-276d-f1a7-a66b0abf819a	b869ff8b-af76-d0a4-5a0c-1618e76ea079	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2024-02-25	2024-03-03	2024-02-25	2024-03-03	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a68f739b-e9d8-a3d5-06ce-f8987318645a	3de4e5fa-92ba-df0d-06f0-ee3caacf1ffd	89a93f8f-a20a-9468-5381-de195e92438b	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-01-25	2026-02-01	2026-01-25	2026-02-01	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a7016f4e-0bc1-5ef0-9c2f-8632db0a86c2	96771845-a6f8-9c00-10b1-7f6e20cb26f2	2381f179-c713-3662-a15a-941357c74808	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-03-03	2026-03-10	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a85d79f7-a765-c18a-50ce-cf8368fd1fc1	0005c8ca-9a64-17b8-256b-4ee73b53e81e	996f2546-6740-af77-8960-72e4a7391ca4	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2023-08-21	2023-08-28	2023-08-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
a9e37760-8183-7b3c-02d0-3db6f01b9567	6d888c0c-7071-ce2c-a642-2aa1ccff8ce0	6770ea6e-b27f-c489-264d-8837151b0833	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-07-05	2026-07-12	2026-07-05	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
abbd98b2-4bb1-f91e-0d87-3618d922937c	4bdd9b6e-dc7e-83df-0e4a-588b718a46de	1ab48c0e-5bcd-9c9d-16b5-ae4328a52479	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-07-01	2026-07-08	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
adcc98b6-203a-0659-2ed2-c8ac38dd3280	6d888c0c-7071-ce2c-a642-2aa1ccff8ce0	0b16929b-f648-0774-3d3a-04ee872062d9	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-06-15	2026-06-22	2026-06-15	2026-06-22	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ae241fa2-eea6-06e3-9fdc-363bc81099b3	bbdd9713-b12d-1026-241e-f23f2881fbd6	2df0e698-e269-9722-1baf-1ef46b658d8d	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2023-02-04	2023-02-11	2023-02-04	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
aea2a4c6-01b0-8b09-606c-e41d27b1ae31	45f61698-e7ca-9049-dce4-2678530df87e	93df6167-e309-f86c-dd0e-b74192db38de	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2023-05-16	2023-05-23	2023-05-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
af40db3e-50dd-a2a9-a6f7-fa828330216c	b71355b0-ed52-fd33-d6f7-87bb249aacce	ab011c73-dd7f-2a45-79d6-972cc0101c1b	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-01-30	2026-02-06	2026-01-30	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
af7a8885-7bc0-babe-250e-f48c12b98882	143d6851-c81c-f1db-df43-09e721081b95	1054551a-5919-4157-25f3-f277178825bd	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-06-16	2026-06-23	2026-06-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b01c70e4-435e-d729-3399-b495d7a11dff	db951439-0ec5-b321-9266-611d80ea0ffa	05bac44a-67a8-dea6-95d3-36e7c82a5a70	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-03-06	2026-03-13	2026-03-06	2026-03-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b1b856bf-b081-b5b7-01ac-d40d2162eeed	2b6e8fc3-44f8-a096-04cb-40f258f06eb4	49421cfd-1bd3-b93a-27cd-301b7407c754	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-03-15	2026-03-22	2026-03-15	2026-03-22	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b1c836d4-d646-5408-a297-be35c86f4bee	633de7eb-3b6c-dd5b-49e3-e6218fbb857d	2fc2dee5-f447-d953-9b34-7168fd912855	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-06-23	2026-06-30	2026-06-23	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b22e847e-ae88-7d68-a79a-e2ae21d04087	b71355b0-ed52-fd33-d6f7-87bb249aacce	b4f2e875-9fa4-0897-f4ed-4cd0e4534ed9	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-02-09	2026-02-16	2026-02-09	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b2d2aa6a-cf44-6b75-a370-d50ebcef9f16	0ce49262-f49c-2000-fe94-e93c5bdfb327	524898de-b5f7-1fca-dcc5-a7de591c672f	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2024-05-11	2024-05-18	2024-05-11	2024-05-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b2fb8f18-3e69-dcb5-7543-99387ce00804	f70f1cb0-fd2b-e991-19c1-97058bf88682	f58be831-e861-9cbe-2870-5e883a046cf7	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2024-02-14	2024-02-21	2024-02-14	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b602675b-ac8c-f036-f1d0-692b1cd5f64b	e1dd4c6b-527b-5243-9f98-cb106d526ed9	1afd49cd-ab49-2739-da1a-1fa6dcee5078	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-01-25	2026-02-01	2026-01-25	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b659f820-702c-0f3a-08ab-e39a0b314d00	b094ee94-07db-74de-1151-8dbf3fdc5feb	dfeff0cc-88c1-b4d2-6287-c514bd92c3d4	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2023-07-21	2023-07-28	2023-07-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b99a1ee2-595e-2504-4920-8c9a3ad71c57	4bdd9b6e-dc7e-83df-0e4a-588b718a46de	1ab48c0e-5bcd-9c9d-16b5-ae4328a52479	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-06-21	2026-06-28	2026-06-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
bb0ebf29-a997-7387-3409-8b4b832c4019	058887ff-6249-66e3-e9b6-6d54d5bedf62	c8812907-3f2e-288b-ce2a-f51edc210dfa	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-03-12	2026-03-19	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
bbfbd5df-0d45-c6e9-7d9d-b6b63dbdbedc	bbdd9713-b12d-1026-241e-f23f2881fbd6	8ed27ef1-635a-a926-f5c3-e43ebbe5461c	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2023-01-20	2023-01-27	2023-01-20	2023-01-27	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
bed411ca-d643-d4f9-c9e1-4b595ae87cab	96771845-a6f8-9c00-10b1-7f6e20cb26f2	2381f179-c713-3662-a15a-941357c74808	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-02-21	2026-02-28	2026-02-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c0eab036-0413-1ade-b218-e23170d02f48	df04abe8-20bf-ba46-4e51-73dfb2469b6b	432e2d21-bf0d-c6b9-b055-37cfaab5c694	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-07-05	2026-07-12	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c12f1e10-96ec-fba6-0aab-bb20aabb6b05	45f61698-e7ca-9049-dce4-2678530df87e	6d7da59a-e68e-3852-6e06-1caa42acc509	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2023-05-26	2023-06-02	2023-05-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c1d16d67-98de-7069-d998-a18d972a530f	058887ff-6249-66e3-e9b6-6d54d5bedf62	9342f7e0-dcf7-04d0-161b-a0dee2dffc6a	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-02-20	2026-02-27	2026-02-20	2026-02-27	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c2194423-12b7-71d9-f320-904e7a1980a7	143d6851-c81c-f1db-df43-09e721081b95	1054551a-5919-4157-25f3-f277178825bd	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-06-06	2026-06-13	2026-06-06	2026-06-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c7276b8a-e27d-2911-a649-10e8c9056ba1	143d6851-c81c-f1db-df43-09e721081b95	c810d02a-dc97-f0a3-dd2a-35c1baf84095	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-06-26	2026-07-03	2026-06-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c739729c-832e-440e-850b-cfcb5aa3c4e3	140eef6e-917f-4d05-d414-eaaa470f8665	adfa2cfb-6855-06f9-6831-f1d8989a20c8	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2024-01-06	2024-01-13	2024-01-06	2024-01-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c8630013-52ce-6ce6-c8d6-c95ff742673a	da23da7f-348b-c5d8-c21c-6f5321338b69	6b4f7f9e-d6b3-f178-6b34-76169bc32763	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-03-07	2026-03-14	2026-03-07	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c8958105-c067-10fd-3e08-cc83a4280f51	078de404-e464-38fe-bc5a-1eecc50c5cdb	35ab8110-a847-5e90-c961-f4ed123a134c	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-07-08	2026-07-15	2026-07-08	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cc00640a-ce59-f319-97d1-6239f6005410	4bdd9b6e-dc7e-83df-0e4a-588b718a46de	1ab48c0e-5bcd-9c9d-16b5-ae4328a52479	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-06-26	2026-07-03	2026-06-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cc3613e0-a517-69c5-b437-5cb9000a181f	53265692-ac5b-a712-54c9-eeb3f10efef2	c5b87c76-1516-4268-4dfe-030ffdab04d2	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-07-15	2026-07-22	2026-07-15	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cda4d176-543f-63e5-1375-f0a216ed4c51	48e0163b-4dfa-3376-dac6-ee5de57f0f99	410e3e7a-d656-735f-e216-9adf10ef7703	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-03-12	2026-03-19	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cddfefcd-685a-b98b-2884-4b38cb444bf5	9df44408-e0f7-1c11-d144-08e51e02851f	10670d63-9013-e4a3-fff4-2bee3401de6e	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2024-03-02	2024-03-09	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cf86816b-4733-b768-2d3c-48c57036443c	e4d9ede1-e653-6c3b-1081-c54a2be3f6e0	61ee7a2d-9ea7-253e-2b90-80fe738f69e5	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2023-07-01	2023-07-08	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cf8ad680-2962-fe82-4254-88065bacda94	37f0631e-ff18-137e-2790-48bf2a3aed53	46666780-3545-52dc-2ce0-7b8e53511045	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-07-15	2026-07-22	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
cfc4184e-44af-d17f-fecb-8a1803fd0f45	df04abe8-20bf-ba46-4e51-73dfb2469b6b	dbfad812-ac74-d649-c9c4-0f88164f3fe2	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-06-10	2026-06-17	2026-06-10	2026-06-17	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d0f092cf-33d0-1683-1d22-14ce5112d0cb	b31447f7-a279-235e-1c13-5e1332ac6f71	31073bb0-6430-4113-7806-da6542c7ef70	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2024-04-09	2024-04-16	2024-04-09	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d1041d56-4ea0-070f-9544-1fa278231716	da23da7f-348b-c5d8-c21c-6f5321338b69	6b4f7f9e-d6b3-f178-6b34-76169bc32763	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-03-17	2026-03-24	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d14e32b1-bab8-0409-ba0d-b262a827ed84	589f13e8-777d-9e78-0179-6955019400a4	7d6e6bdb-5c0b-00ea-a1f2-fdf1754f994d	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-03-11	2026-03-18	2026-03-11	2026-03-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d17868f6-0814-13dd-634e-b6b2d4ecc86c	8674f685-9512-d7a4-1399-e58a4b88fe5b	51c72dd7-b22d-2483-e76e-ea3b64e6ecae	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-07-12	2026-07-19	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d2cbb131-7e28-aba5-1179-2bec009206d2	37f0631e-ff18-137e-2790-48bf2a3aed53	46666780-3545-52dc-2ce0-7b8e53511045	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-07-05	2026-07-12	2026-07-05	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d4337f62-79ec-fcc5-4347-6df7dcad1bb6	f70f1cb0-fd2b-e991-19c1-97058bf88682	2a603970-bdf9-5ed1-4f85-dbdc47f8f7b9	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2024-02-04	2024-02-11	2024-02-04	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d45a621b-edb8-d5b5-f8e6-5d129d05ac13	dd709b37-3794-40c0-13ae-e35ec70100a2	9279e70e-9cff-a540-aaa0-a69a28e40861	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2025-10-01	2025-10-08	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d753706b-46eb-e347-de80-399f0413c1ce	37f0631e-ff18-137e-2790-48bf2a3aed53	363b3132-f311-8115-0a6a-4833b3d8032a	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-06-25	2026-07-02	2026-06-25	2026-07-02	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d7e86046-ce08-269d-b58b-d6967b1dcf06	db951439-0ec5-b321-9266-611d80ea0ffa	12cc8282-faf3-2c4e-73cf-0174d98d5cfd	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-03-21	2026-03-28	2026-03-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d85ff7f2-80db-ba81-933d-7b9bcdfc95f4	633de7eb-3b6c-dd5b-49e3-e6218fbb857d	d9b9c7d9-25ee-8548-d06d-52f14f813b22	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-07-03	2026-07-10	2026-07-03	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d8900408-71ef-0382-21c6-4df03868d18b	c6600f41-5fbd-cbb0-983b-ccbbcbf9636f	8ee83ad7-ea23-7f24-7a8c-e4d4f148b1a8	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2024-04-16	2024-04-23	2024-04-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d8d3f1bb-dd5b-3b50-eaba-1165bc47c92a	c6600f41-5fbd-cbb0-983b-ccbbcbf9636f	8ee83ad7-ea23-7f24-7a8c-e4d4f148b1a8	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2024-04-06	2024-04-13	2024-04-06	2024-04-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
db655801-98d5-c450-e902-a39a24259eac	633de7eb-3b6c-dd5b-49e3-e6218fbb857d	d9b9c7d9-25ee-8548-d06d-52f14f813b22	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-07-08	2026-07-15	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dbb2f747-7f0a-ea79-ceb0-cd14558f3f2f	fbb030f3-e849-5b81-6934-cf7a89075db1	4b752a38-4211-7934-a715-2b5b05578797	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2024-03-16	2024-03-23	2024-03-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dcb251ad-2672-8a4e-fdb3-ec8491fa22b8	42c28ff9-518b-917f-58fb-322aa28ffc9f	15b0f2d9-54fd-59a8-59fd-3a530cf4b72f	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-02-09	2026-02-16	2026-02-09	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dd034b21-aa88-5356-06dc-c058ef94af22	96771845-a6f8-9c00-10b1-7f6e20cb26f2	2381f179-c713-3662-a15a-941357c74808	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-02-26	2026-03-05	2026-02-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dda50b82-3745-032b-b44c-2be50a27308f	42c28ff9-518b-917f-58fb-322aa28ffc9f	0c256a9f-e032-9c16-b370-382f769ba40d	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-01-30	2026-02-06	2026-01-30	2026-02-06	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
de7cd3eb-c921-019c-6129-984d336cdb75	b71355b0-ed52-fd33-d6f7-87bb249aacce	ab011c73-dd7f-2a45-79d6-972cc0101c1b	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-01-20	2026-01-27	2026-01-20	2026-01-27	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e000db1a-7be1-6fe6-20aa-cf82fa09eff3	e4d9ede1-e653-6c3b-1081-c54a2be3f6e0	b623c0cf-5b8b-dde1-39fe-74e26adcdde0	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2023-06-16	2023-06-23	2023-06-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e12c2448-1370-0deb-5f39-046586305eac	078de404-e464-38fe-bc5a-1eecc50c5cdb	35ab8110-a847-5e90-c961-f4ed123a134c	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-07-18	2026-07-25	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e1ff7eaf-6368-d610-cc38-cc7f03c20ff5	df04abe8-20bf-ba46-4e51-73dfb2469b6b	432e2d21-bf0d-c6b9-b055-37cfaab5c694	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-06-30	2026-07-07	2026-06-30	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e308609c-03a2-66b4-c570-c19b5025a5d3	45f61698-e7ca-9049-dce4-2678530df87e	6d7da59a-e68e-3852-6e06-1caa42acc509	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2023-05-31	2023-06-07	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e4442fa1-5fd0-b0c2-b127-57b35e498b6a	804038cb-1b0f-af18-247c-514d7edf2757	b95d4d6f-04a8-34b3-8078-8418577a24a1	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2023-05-01	2023-05-08	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e54110b0-c635-aad9-e595-0ef37937110e	53265692-ac5b-a712-54c9-eeb3f10efef2	6cd5d5d0-3b08-2bec-45cd-a5b847830ade	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-07-05	2026-07-12	2026-07-05	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e5eeeebe-bbd5-ba03-8700-9bdeda1b75c7	6aaca83f-9e2d-72bf-2873-cc7f244f91a5	c3b79a4d-14cd-8b0c-643a-1e51d917236f	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2023-03-31	2023-04-07	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e65a9998-da91-3ffd-46cd-b7aafc7b0f16	0110e115-3f2e-645f-fa51-3f844cd6227e	c4254748-163c-c056-2806-836fd70067ee	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-07-15	2026-07-22	2026-07-15	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e681b3e4-cd6b-2817-fc4b-7cf9c5c4f4f2	d9c31d7b-328e-11be-73d1-c8c578219b98	1e35a5bc-4e01-b9d6-a46e-53bf40227634	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2024-02-16	2024-02-23	2024-02-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e6ea9701-0407-d96d-55d7-b544ccb9271e	fbb030f3-e849-5b81-6934-cf7a89075db1	4b752a38-4211-7934-a715-2b5b05578797	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2024-03-06	2024-03-13	2024-03-06	2024-03-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e71d2102-3c7a-5f71-c21b-6de509fb4009	2b6e8fc3-44f8-a096-04cb-40f258f06eb4	3676c60b-0bdd-5476-2391-778b0e93daf9	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-04-04	2026-04-11	2026-04-04	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e83333da-0880-c9f7-e4c5-8bcef9020e5c	3de4e5fa-92ba-df0d-06f0-ee3caacf1ffd	89a93f8f-a20a-9468-5381-de195e92438b	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-02-04	2026-02-11	2026-02-04	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e8fbed49-7cc6-ec60-f1f1-daa3f3dd7048	2b6e8fc3-44f8-a096-04cb-40f258f06eb4	49421cfd-1bd3-b93a-27cd-301b7407c754	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2026-03-25	2026-04-01	2026-03-25	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
eaf1fe5a-8e06-ccc7-c914-7b76aa086b7e	e665c8c1-23cb-3bc0-bb8a-2ac17e4d8a37	ef74f6e3-b8d7-d02c-c4c7-1b9a35b0039b	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2024-06-26	2024-07-03	2024-06-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ec2af058-dbc8-b4a9-2bde-119937e22e78	4b05d47c-011a-ca3b-0c37-a70112d30fe7	2bf6eb9a-efae-81ab-2269-3090bd9d5d58	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-02-14	2026-02-21	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ec60027c-cf83-0f05-3628-d56e2eb391d4	53265692-ac5b-a712-54c9-eeb3f10efef2	6cd5d5d0-3b08-2bec-45cd-a5b847830ade	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-06-30	2026-07-07	2026-06-30	2026-07-07	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
eee249e9-74fc-a7c8-7322-6f7383e10ead	2b6e8fc3-44f8-a096-04cb-40f258f06eb4	3676c60b-0bdd-5476-2391-778b0e93daf9	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2026-04-09	2026-04-16	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ef6a1c37-7e3e-91b9-05c0-4bd43269bedf	b71355b0-ed52-fd33-d6f7-87bb249aacce	b4f2e875-9fa4-0897-f4ed-4cd0e4534ed9	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-02-04	2026-02-11	2026-02-04	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
efe06203-402a-b105-c7e4-1bd109cc122e	e665c8c1-23cb-3bc0-bb8a-2ac17e4d8a37	e56c85df-82db-df7d-bda2-13f9bdbe2ae4	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2024-06-11	2024-06-18	2024-06-11	2024-06-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f074255b-fdfd-fe32-16f1-748d957f9cb6	53265692-ac5b-a712-54c9-eeb3f10efef2	c5b87c76-1516-4268-4dfe-030ffdab04d2	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-07-10	2026-07-17	2026-07-10	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f14f142f-bd8f-6551-d6ed-feac1575b74c	9df44408-e0f7-1c11-d144-08e51e02851f	35c728c6-8c05-6c76-d801-88762d76500d	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2024-02-06	2024-02-13	2024-02-06	2024-02-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f193c79f-cdb7-0d1c-811c-7cf6ae352556	db951439-0ec5-b321-9266-611d80ea0ffa	12cc8282-faf3-2c4e-73cf-0174d98d5cfd	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-03-26	2026-04-02	2026-03-26	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f2e96fee-693d-abfd-c4bb-82dcb512c375	b094ee94-07db-74de-1151-8dbf3fdc5feb	f986a116-8632-0eaa-227f-c64e9796a59d	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2023-07-11	2023-07-18	2023-07-11	2023-07-18	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f4e3d28a-c28f-ecf9-0d2f-dd8de6bb2454	804038cb-1b0f-af18-247c-514d7edf2757	b95d4d6f-04a8-34b3-8078-8418577a24a1	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2023-04-21	2023-04-28	2023-04-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f578d359-1532-182f-4682-f060e766b81f	96771845-a6f8-9c00-10b1-7f6e20cb26f2	5fd5d5f2-6564-cb5c-e88a-74ca15afde28	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-02-06	2026-02-13	2026-02-06	2026-02-13	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f5cf63ab-012d-39f2-7290-bb4136fbffa8	c6600f41-5fbd-cbb0-983b-ccbbcbf9636f	d2bc3749-98a4-c0af-d1a2-653a602c2684	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2024-05-01	2024-05-08	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f69ecebb-c60e-2792-1e6a-ea076f6638e3	078de404-e464-38fe-bc5a-1eecc50c5cdb	087e4b44-d201-7054-1e13-406aff3754c4	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-06-23	2026-06-30	2026-06-23	2026-06-30	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f7971552-23bf-2a5b-fabb-32d666057425	f70f1cb0-fd2b-e991-19c1-97058bf88682	f58be831-e861-9cbe-2870-5e883a046cf7	Phishing Campaign & Assessment	Phishing Campaign & Assessment execution phase	Q1	AP6	Ready to Start	high	2024-02-19	2024-02-26	\N	\N	16.00	0.00	0	6	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f7fa4f52-7923-0c2f-c55e-72e4d3e072a5	48e0163b-4dfa-3376-dac6-ee5de57f0f99	410e3e7a-d656-735f-e216-9adf10ef7703	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2026-03-07	2026-03-14	2026-03-07	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f98bb151-5eaf-4b17-d3c9-31fd3bb8f636	42c28ff9-518b-917f-58fb-322aa28ffc9f	0c256a9f-e032-9c16-b370-382f769ba40d	External Network Penetration Testing	External Network Penetration Testing execution phase	Q1	AP1	Completed	medium	2026-01-25	2026-02-01	2026-01-25	2026-02-01	40.00	40.00	100	1	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fb284a71-d4f3-7e10-7318-8dbb98d80a94	9e038dae-c384-1ce5-0dc2-493dd9c9720e	c594bea9-c6c3-df5e-3c43-67be9a76374e	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-03-12	2026-03-19	2026-03-12	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fc4dd0bb-fc0a-8682-cb63-c726db3e020f	0ce49262-f49c-2000-fe94-e93c5bdfb327	524898de-b5f7-1fca-dcc5-a7de591c672f	Cloud Infrastructure Assessment	Cloud Infrastructure Assessment execution phase	Q1	AP3	Ongoing	medium	2024-05-16	2024-05-23	2024-05-16	\N	40.00	26.00	65	3	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fcbfb541-20d2-c804-0023-f5d2eedea5a1	6d888c0c-7071-ce2c-a642-2aa1ccff8ce0	6770ea6e-b27f-c489-264d-8837151b0833	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2026-06-30	2026-07-07	2026-06-30	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fdbe136d-21af-6772-a525-7bbcc5dd7e6b	633de7eb-3b6c-dd5b-49e3-e6218fbb857d	2fc2dee5-f447-d953-9b34-7168fd912855	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2026-06-18	2026-06-25	2026-06-18	2026-06-25	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ff7e8c76-5f53-21b7-9f04-1bd31d850123	569eb2b4-dce7-5d4f-5e8c-6321a995cf38	2d764f0b-9442-6d98-9684-fc71d242e8db	Source Code Security Review	Source Code Security Review execution phase	Q1	AP4	Ready to Start	high	2023-09-21	2023-09-28	2023-09-21	\N	48.00	19.20	40	4	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ff976402-477e-b14f-7ce5-5a196df836e0	27198d8b-d6cf-276d-f1a7-a66b0abf819a	508bc02a-7f4d-cd33-1037-15ea3915806c	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2024-03-11	2024-03-18	2024-03-11	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
ffb6e068-bd34-17ff-ef5e-fc57e10131ae	b31447f7-a279-235e-1c13-5e1332ac6f71	be756cb9-406f-1c8b-176e-c05db328a779	Web Application Penetration Testing	Web Application Penetration Testing execution phase	Q1	AP2	Completed	high	2024-03-25	2024-04-01	2024-03-25	2024-04-01	32.00	32.00	100	2	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fff67130-68d6-8cd4-0e02-50f08346e9d3	bbdd9713-b12d-1026-241e-f23f2881fbd6	2df0e698-e269-9722-1baf-1ef46b658d8d	ISO 27001 Security Audit	ISO 27001 Security Audit execution phase	Q1	AP5	On Hold (Internal)	medium	2023-02-09	2023-02-16	2023-02-09	\N	64.00	12.80	20	5	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: project_team_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_team_members ("Id", "ProjectId", "EmployeeId", "DepartmentId", "SubDepartment", "AllocationStartDate", "AllocationEndDate", "Billability", "IsTeamLead", "ResourceType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "IsShadowTeam") FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.projects ("Id", "ProjectCode", "WbsId", "Name", "Description", "ClientId", "SubVentureId", "Status", "Health", "Progress", "ContractType", "ProjectType", "Currency", "TaxPercent", "StartDate", "EndDate", "Budget", "Spent", "TotalHours", "TotalDays", "InvoiceValue", "ProjectManagerId", "TeamLeadId", "EngagementManager", "EngagementManagerId", "SalesPerson", "SalesPersonId", "ProjectIssuedDate", "SectionAComments", "SectionBComments", "WbsStatus", "WbsSubStatus", "RenewedFromProjectId", "PoStatus", "PoNumber", "PoDate", "BillingModel", "PaymentTerms", "TargetDate", "AccountContactName", "AccountContactPhone", "AccountContactEmail", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
0005c8ca-9a64-17b8-256b-4ee73b53e81e	P043	IN-2023-24-C010-P002	OBD Diagnostics Cloud	Cloud-based OBD-II diagnostics aggregation for fleet health monitoring.	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	a9afcff9-fadd-4d29-aeab-d83159813cde	archived	amber	38	Fixed Price	Short term (Ad-hoc)	USD	18.00	2023-08-01	2024-04-30	430000.00	400000.00	240.00	30.00	430000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Archived	Archived	\N	Uploaded	PO-P002	2023-07-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0110e115-3f2e-645f-fa51-3f844cd6227e	P042	IN-2026-27-C010-P001	V2X Communication Platform	Vehicle-to-everything communication layer for smart city integration.	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	bf470ada-eecb-4ed7-9dc0-0c11436d2eec	ongoing	amber	0	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-06-25	2027-02-28	1100000.00	0.00	240.00	30.00	1100000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P001	2026-06-20	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
058887ff-6249-66e3-e9b6-6d54d5bedf62	P012	IN-2025-26-C008-P007	Hospital Management System	Comprehensive EHR and patient management system for 50+ hospitals.	a8403352-05bc-3658-d6c2-55ac4d6bea24	e1b95e8b-302d-4cf3-9ab1-c6f0bd75d394	ongoing	amber	48	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-02-10	2026-09-25	920000.00	441600.00	240.00	30.00	920000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P007	2026-02-05	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
078de404-e464-38fe-bc5a-1eecc50c5cdb	P039	IN-2026-27-C009-P001	Waste Management IoT	Smart bin monitoring network with route optimization for waste collectors.	f38ca416-9ecc-1214-1c54-42ecf337d858	c5b810e0-cf3c-46cf-91ca-615d583f7f9d	ongoing	green	0	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-06-18	2026-12-20	360000.00	0.00	240.00	30.00	360000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P001	2026-06-13	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
0ce49262-f49c-2000-fe94-e93c5bdfb327	P035	IN-2024-25-C008-P004	Telemedicine Platform	HIPAA-compliant video consultation and remote monitoring platform.	a8403352-05bc-3658-d6c2-55ac4d6bea24	3540c693-d4be-438c-a795-b11c7edd1f84	completed	green	100	Fixed Price	Short term (Ad-hoc)	USD	18.00	2024-05-01	2025-01-15	670000.00	650000.00	240.00	30.00	670000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Approved	Completed	\N	Uploaded	PO-P004	2024-04-26	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
140eef6e-917f-4d05-d414-eaaa470f8665	P033	IN-2024-25-C007-P002	KYC Automation	AI-driven KYC document verification reducing manual review by 80%.	fb5d93e7-e434-c041-30e9-707384e99cf1	cab77d0e-e88a-4056-8712-a5a39ff91cd9	completed	green	100	Fixed Price	Short term (Ad-hoc)	USD	18.00	2024-01-01	2024-08-31	540000.00	525000.00	240.00	30.00	540000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Approved	Completed	\N	Uploaded	PO-P002	2023-12-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
143d6851-c81c-f1db-df43-09e721081b95	P017	IN-2026-27-C001-P001	API Gateway Revamp	Rebuild API gateway with rate limiting, OAuth 2.0 and developer portal.	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	3ea7fd34-bce6-4d9c-868b-380ef2658536	ongoing	green	0	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-06-01	2026-12-31	390000.00	0.00	240.00	30.00	390000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P001	2026-05-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
27198d8b-d6cf-276d-f1a7-a66b0abf819a	P038	IN-2024-25-C009-P002	ESG Reporting Engine	Automated ESG data aggregation and reporting aligned to GRI and TCFD standards.	f38ca416-9ecc-1214-1c54-42ecf337d858	857a1e5d-ba2d-4499-9170-866e7f80596c	completed	green	100	Fixed Price	Short term (Ad-hoc)	USD	18.00	2024-02-15	2024-10-30	420000.00	405000.00	240.00	30.00	420000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Approved	Completed	\N	Uploaded	PO-P002	2024-02-10	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
2b6e8fc3-44f8-a096-04cb-40f258f06eb4	P014	IN-2025-26-C010-P013	Autonomous Vehicle Control	Advanced control system for autonomous vehicle fleet management.	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	80d85beb-5a07-40f2-b7ae-2f6168a6755e	ongoing	red	38	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-03-10	2026-11-15	1200000.00	456000.00	240.00	30.00	1200000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P013	2026-03-05	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
37f0631e-ff18-137e-2790-48bf2a3aed53	P026	IN-2026-27-C004-P002	Driver Mobile App	Driver-facing mobile app for route optimization and POD collection.	428f81d7-182b-baf5-a71e-7b2216c94a1d	fb458d8a-fe51-4a06-a8cc-135b3784da0e	ongoing	green	0	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-06-15	2026-11-20	220000.00	0.00	240.00	30.00	220000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P002	2026-06-10	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
3de4e5fa-92ba-df0d-06f0-ee3caacf1ffd	P005	IN-2025-26-C003-P004	Omnichannel Commerce	Unified storefront across web, mobile and in-store kiosks.	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	116ef6af-75e2-4743-af52-db5f71093752	ongoing	green	58	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-01-20	2026-08-10	760000.00	420000.00	240.00	30.00	760000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P004	2026-01-15	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
42c28ff9-518b-917f-58fb-322aa28ffc9f	P013	IN-2025-26-C009-P005	Carbon Tracking Platform	Enterprise platform for monitoring and reducing carbon footprint.	f38ca416-9ecc-1214-1c54-42ecf337d858	7958d666-b744-4889-9c26-4d9152b5e23c	ongoing	green	71	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-01-20	2026-07-31	640000.00	454400.00	240.00	30.00	640000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P005	2026-01-15	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
45f61698-e7ca-9049-dce4-2678530df87e	P021	IN-2023-24-C002-P002	Drug Trial Management	Phase II/III clinical trial participant management and data collection.	06cb7699-93b0-047f-0c59-b7f1baa24ec8	adc6d310-c567-4598-8bee-699791ca28cb	archived	amber	68	Fixed Price	Short term (Ad-hoc)	USD	18.00	2023-05-01	2024-01-31	730000.00	690000.00	240.00	30.00	730000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Archived	Archived	\N	Uploaded	PO-P002	2023-04-26	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
48e0163b-4dfa-3376-dac6-ee5de57f0f99	P004	IN-2025-26-C002-P008	Pharma Sales Dashboard	Sales analytics dashboard with territory performance views.	06cb7699-93b0-047f-0c59-b7f1baa24ec8	5fd7f539-0471-41ef-b4f9-f9c72071e117	on_hold	amber	45	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-02-10	2026-07-20	320000.00	180000.00	240.00	30.00	320000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P008	2026-02-05	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4b05d47c-011a-ca3b-0c37-a70112d30fe7	P002	IN-2025-26-C001-P002	Mobile Banking App v3	Next-gen mobile app with biometric auth and real-time payments.	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	b5f5586f-63f0-4fe2-b864-89937fb76a72	ongoing	green	78	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-01-15	2026-06-30	480000.00	360000.00	240.00	30.00	480000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P002	2026-01-10	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
4bdd9b6e-dc7e-83df-0e4a-588b718a46de	P030	IN-2026-27-C006-P001	Data Lakehouse Migration	Migrate 3PB data warehouse to modern lakehouse architecture on Snowflake.	a70cd580-74be-fff2-31b3-dcc06cc11f06	8113f77c-878e-42bc-912b-5a7c388702a4	ongoing	green	0	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-06-01	2026-11-30	490000.00	0.00	240.00	30.00	490000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P001	2026-05-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
53265692-ac5b-a712-54c9-eeb3f10efef2	P036	IN-2026-27-C008-P001	Insurance Claims Automation	AI-powered claims processing reducing settlement time from 30 to 3 days.	a8403352-05bc-3658-d6c2-55ac4d6bea24	8789ae47-e505-4fb3-adf2-04ade91e418c	ongoing	green	0	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-06-20	2026-12-31	380000.00	0.00	240.00	30.00	380000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P001	2026-06-15	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
569eb2b4-dce7-5d4f-5e8c-6321a995cf38	P018	IN-2023-24-C001-P005	Loan Origination System	End-to-end digital loan origination and approval workflow system.	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	\N	archived	amber	72	Fixed Price	Short term (Ad-hoc)	USD	18.00	2023-09-01	2024-04-30	450000.00	420000.00	240.00	30.00	450000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Archived	Archived	\N	Uploaded	PO-P005	2023-08-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
589f13e8-777d-9e78-0179-6955019400a4	P003	IN-2025-26-C002-P011	Clinical Data Platform	Unified clinical trials data platform with HIPAA compliance.	06cb7699-93b0-047f-0c59-b7f1baa24ec8	03e40de1-c4a7-425b-87ab-7d2b45ec364d	ongoing	red	35	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-03-01	2026-09-15	950000.00	410000.00	240.00	30.00	950000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P011	2026-02-24	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
633de7eb-3b6c-dd5b-49e3-e6218fbb857d	P028	IN-2026-27-C005-P001	Customer Energy Portal	Self-service portal for residential customers to track usage and billing.	47e27c95-3686-6752-359c-e6a9e5f22e07	d08681c8-6a5b-4c1e-af29-8997fa0e9de3	ongoing	green	0	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-06-08	2026-12-15	310000.00	0.00	240.00	30.00	310000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P001	2026-06-03	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6aaca83f-9e2d-72bf-2873-cc7f244f91a5	P034	IN-2023-24-C007-P001	Open Banking API Suite	PSD2-compliant open banking API suite for third-party integrators.	fb5d93e7-e434-c041-30e9-707384e99cf1	7ac571e1-5915-46fb-b36d-64323d485e8a	archived	amber	44	Fixed Price	Short term (Ad-hoc)	USD	18.00	2023-03-01	2023-10-15	320000.00	300000.00	240.00	30.00	320000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Archived	Archived	\N	Uploaded	PO-P001	2023-02-24	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
6d888c0c-7071-ce2c-a642-2aa1ccff8ce0	P020	IN-2026-27-C002-P002	Regulatory Compliance Portal	Centralized portal for managing FDA/EMA regulatory submissions.	06cb7699-93b0-047f-0c59-b7f1baa24ec8	15c89a23-7196-48e6-9c9c-0a10cc38cf80	ongoing	green	0	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-06-10	2026-12-20	280000.00	0.00	240.00	30.00	280000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P002	2026-06-05	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
804038cb-1b0f-af18-247c-514d7edf2757	P040	IN-2023-24-C009-P004	Water Quality Platform	IoT sensor network for real-time water quality monitoring across 200 sites.	f38ca416-9ecc-1214-1c54-42ecf337d858	c2c8966d-d634-45b1-b1e2-c231d2a91c16	archived	amber	48	Fixed Price	Short term (Ad-hoc)	USD	18.00	2023-04-01	2023-11-30	310000.00	290000.00	240.00	30.00	310000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Archived	Archived	\N	Uploaded	PO-P004	2023-03-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
8674f685-9512-d7a4-1399-e58a4b88fe5b	P032	IN-2026-27-C007-P001	Cross-Border Payments	SWIFT-compliant cross-border payment rails for 40+ countries.	fb5d93e7-e434-c041-30e9-707384e99cf1	ed26b19c-dd44-4dbd-931f-32302088e02d	ongoing	amber	0	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-06-12	2027-01-31	920000.00	0.00	240.00	30.00	920000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P001	2026-06-07	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
96771845-a6f8-9c00-10b1-7f6e20cb26f2	P001	IN-2025-26-C001-P006	Core Banking Modernization	Modernize legacy core banking platform to a cloud-native microservices stack.	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	8f8671f4-01e4-42d9-ba2e-afc03d0a37d0	ongoing	amber	62	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-02-01	2026-08-30	1200000.00	740000.00	240.00	30.00	1200000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P006	2026-01-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9df44408-e0f7-1c11-d144-08e51e02851f	P027	IN-2024-25-C005-P003	Renewable Energy Dashboard	Executive dashboard for real-time monitoring of solar and wind assets.	47e27c95-3686-6752-359c-e6a9e5f22e07	58e5ee34-e198-47b6-9a9e-95903f56b20d	archived	green	100	Fixed Price	Short term (Ad-hoc)	USD	18.00	2024-02-01	2024-10-31	460000.00	445000.00	240.00	30.00	460000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Archived	Archived	\N	Uploaded	PO-P003	2024-01-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
9e038dae-c384-1ce5-0dc2-493dd9c9720e	P009	IN-2025-26-C005-P010	Smart Grid Analytics	Predictive load balancing and outage detection across the grid.	47e27c95-3686-6752-359c-e6a9e5f22e07	a34f1aad-ed5a-4eef-80e7-ffb186ac5a02	ongoing	amber	55	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-02-20	2026-10-10	1050000.00	510000.00	240.00	30.00	1050000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P010	2026-02-15	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b094ee94-07db-74de-1151-8dbf3fdc5feb	P037	IN-2023-24-C008-P003	Patient Engagement App	Patient-facing app for appointment booking, reminders and health records.	a8403352-05bc-3658-d6c2-55ac4d6bea24	30613fc3-38d9-45c8-9333-72a178f1e2b7	archived	amber	52	Fixed Price	Short term (Ad-hoc)	USD	18.00	2023-07-01	2024-03-31	290000.00	270000.00	240.00	30.00	290000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Archived	Archived	\N	Uploaded	PO-P003	2023-06-26	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b31447f7-a279-235e-1c13-5e1332ac6f71	P031	IN-2024-25-C006-P002	MLOps Framework	Production ML model lifecycle management with drift detection and retraining.	a70cd580-74be-fff2-31b3-dcc06cc11f06	42304e00-59f2-4bed-b23b-87c4800caa16	archived	green	100	Fixed Price	Short term (Ad-hoc)	USD	18.00	2024-03-15	2024-11-30	380000.00	365000.00	240.00	30.00	380000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Archived	Archived	\N	Uploaded	PO-P002	2024-03-10	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
b71355b0-ed52-fd33-d6f7-87bb249aacce	P011	IN-2025-26-C007-P003	Digital Wallet MVP	Mobile-first digital payment wallet with blockchain security.	fb5d93e7-e434-c041-30e9-707384e99cf1	ac923fa9-3ecb-4ccb-a755-5b21621eea43	ongoing	green	65	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-01-15	2026-06-20	580000.00	377000.00	240.00	30.00	580000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P003	2026-01-10	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
bbdd9713-b12d-1026-241e-f23f2881fbd6	P024	IN-2023-24-C003-P005	Customer Data Platform	Unified customer data platform integrating 12 data sources.	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	9e067c55-cc90-48a0-ab8b-ded41dace8cb	archived	amber	55	Fixed Price	Short term (Ad-hoc)	USD	18.00	2023-01-15	2023-09-30	490000.00	460000.00	240.00	30.00	490000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Archived	Archived	\N	Uploaded	PO-P005	2023-01-10	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
c6600f41-5fbd-cbb0-983b-ccbbcbf9636f	P025	IN-2024-25-C004-P005	Supply Chain Visibility	End-to-end supply chain visibility platform with IoT sensor integration.	428f81d7-182b-baf5-a71e-7b2216c94a1d	f701bcf7-0139-44fe-9188-1e2218afdb10	completed	green	100	Fixed Price	Short term (Ad-hoc)	USD	18.00	2024-04-01	2024-12-15	570000.00	555000.00	240.00	30.00	570000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Approved	Completed	\N	Uploaded	PO-P005	2024-03-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
d9c31d7b-328e-11be-73d1-c8c578219b98	P016	IN-2023-24-C001-P006	Fraud Detection ML Model	Machine learning pipeline for real-time transaction fraud detection.	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	c973cd24-655e-4de7-98e2-f0627d34696c	completed	green	100	Fixed Price	Short term (Ad-hoc)	USD	18.00	2024-02-01	2024-10-30	680000.00	665000.00	240.00	30.00	680000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Approved	Completed	\N	Uploaded	PO-P006	2024-01-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
da23da7f-348b-c5d8-c21c-6f5321338b69	P007	IN-2025-26-C004-P009	Fleet Tracking System	Real-time GPS tracking and route optimization for 5,000 vehicles.	428f81d7-182b-baf5-a71e-7b2216c94a1d	f8c2759e-1526-4499-93fe-4bf9383551a9	ongoing	amber	48	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-02-15	2026-09-01	540000.00	280000.00	240.00	30.00	540000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P009	2026-02-10	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
db951439-0ec5-b321-9266-611d80ea0ffa	P010	IN-2025-26-C006-P012	AI-Powered Analytics Platform	Machine learning pipeline for real-time data analytics and insights.	a70cd580-74be-fff2-31b3-dcc06cc11f06	321598b3-aae4-4d07-a5b0-2e27cec16136	ongoing	green	82	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-03-01	2026-08-30	750000.00	615000.00	240.00	30.00	750000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P012	2026-02-24	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
dd709b37-3794-40c0-13ae-e35ec70100a2	P006	IN-2024-25-C003-P002	POS Migration	Migrated 1,200 POS terminals to new cloud-managed platform.	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	c10b586c-3015-46a1-9ca4-c8a0758788ef	ongoing	green	65	Fixed Price	Short term (Ad-hoc)	USD	18.00	2025-09-01	2026-03-30	280000.00	265000.00	240.00	30.00	280000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P002	2025-08-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
df04abe8-20bf-ba46-4e51-73dfb2469b6b	P023	IN-2026-27-C003-P001	Inventory AI Forecasting	AI-driven demand forecasting and automated replenishment system.	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	79de3aae-5152-44f0-9c77-0c54c3fd701d	ongoing	green	0	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-06-05	2026-11-30	420000.00	0.00	240.00	30.00	420000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P001	2026-05-31	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e1dd4c6b-527b-5243-9f98-cb106d526ed9	P008	IN-2025-26-C004-P001	Warehouse Automation	Robotics + WMS integration across 4 distribution centers.	428f81d7-182b-baf5-a71e-7b2216c94a1d	b472f090-9382-4fcb-9a13-ad023a2b8edb	ongoing	green	70	Fixed Price	Short term (Ad-hoc)	USD	18.00	2026-01-05	2026-07-15	890000.00	600000.00	240.00	30.00	890000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Published	Active	\N	Uploaded	PO-P001	2025-12-31	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e3d8204f-df7e-d5f0-79cf-7578c1385684	P019	IN-2023-24-C002-P007	Lab Information System	Digital laboratory information system for sample tracking and reporting.	06cb7699-93b0-047f-0c59-b7f1baa24ec8	fec11a61-59e0-4cfa-b03e-189789ceab63	completed	green	100	Fixed Price	Short term (Ad-hoc)	USD	18.00	2024-01-10	2024-09-20	610000.00	590000.00	240.00	30.00	610000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Approved	Completed	\N	Uploaded	PO-P007	2024-01-05	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e4d9ede1-e653-6c3b-1081-c54a2be3f6e0	P029	IN-2023-24-C005-P004	Grid Modernization Program	Phase 1 smart meter rollout across 3 states.	47e27c95-3686-6752-359c-e6a9e5f22e07	fbc527bd-d4b0-4a18-9ebb-b2ed0752da93	completed	amber	61	Fixed Price	Short term (Ad-hoc)	USD	18.00	2023-06-01	2024-03-31	870000.00	840000.00	240.00	30.00	870000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Approved	Completed	\N	Uploaded	PO-P004	2023-05-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
e665c8c1-23cb-3bc0-bb8a-2ac17e4d8a37	P015	IN-2024-25-C001-P003	Internet Banking Portal	Full-featured internet banking portal with 2FA and real-time notifications.	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	e2868bff-2f6e-41e5-a1fa-6451ca5a7f0f	archived	green	100	Fixed Price	Short term (Ad-hoc)	USD	18.00	2024-06-01	2025-01-15	520000.00	510000.00	240.00	30.00	520000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Archived	Archived	\N	Uploaded	PO-P003	2024-05-27	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
f70f1cb0-fd2b-e991-19c1-97058bf88682	P041	IN-2024-25-C010-P003	ADAS Integration Suite	Advanced driver-assistance system integration for 3 OEM partners.	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	fa9d3ecf-bd5f-4ccb-a03e-b574d8370f11	completed	green	100	Fixed Price	Short term (Ad-hoc)	USD	18.00	2024-01-20	2024-11-30	980000.00	960000.00	240.00	30.00	980000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Approved	Completed	\N	Uploaded	PO-P003	2024-01-15	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
fbb030f3-e849-5b81-6934-cf7a89075db1	P022	IN-2023-24-C003-P008	Loyalty Rewards Platform	Points-based loyalty engine with gamification for 5M+ customers.	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	0d158329-c66c-4427-b5e8-073bfab60dba	completed	green	100	Fixed Price	Short term (Ad-hoc)	USD	18.00	2024-03-01	2024-11-30	340000.00	330000.00	240.00	30.00	340000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	Approved	Completed	\N	Uploaded	PO-P008	2024-02-25	50-50	Net 30 Days	\N	\N	\N	\N	2026-09-29 12:27:28.962548+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refresh_tokens ("Id", "UserId", "TokenHash", "ExpiresAtUtc", "RevokedAtUtc", "ReplacedByTokenHash", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
5ffba308-d7d8-4eaf-a050-24ccfc6a2158	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3Y/Llii7BLjc+ylFJUlFUY2Ws0jsoLdF/vpbxyk7iMw=	2026-10-01 17:59:15.192705+05:30	2026-09-24 18:03:41.467732+05:30	\N	2026-09-24 17:59:15.192883+05:30	2026-09-24 18:03:41.467759+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7471874b-e746-41ec-aa76-f3cee2599f88	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	x8Pkrfe9G17wmKtDOWSIw2DgnatLxt57N8wUhhKTKNw=	2026-10-01 18:03:41.906451+05:30	2026-09-24 18:31:53.121863+05:30	\N	2026-09-24 18:03:41.906658+05:30	2026-09-24 18:31:53.149825+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6ac30ca6-ebd1-4d6c-af75-3687c0693ccd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eWug6YnmI2nCEl36fIjuYslBC4tOjc/TWf5sO0gAGOQ=	2026-10-01 18:31:53.146254+05:30	2026-09-24 19:19:25.954384+05:30	\N	2026-09-24 18:31:53.149825+05:30	2026-09-24 19:19:25.954537+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2ea474d1-5fbf-4981-93f9-a1245e221a06	00000000-0000-4000-9000-000000000015	ekICsM9ReuMTaqQztcoIxFRPmHglOEkd9f+ceLUwWe4=	2026-10-01 19:19:26.576981+05:30	2026-09-24 19:19:30.438631+05:30	\N	2026-09-24 19:19:26.577694+05:30	2026-09-24 19:19:30.438655+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d1ac74ff-463a-44df-9795-364dafd45da6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Nn4Eg/INL3SvFVHHk8NfLFbsDbylGkpkZObw1S6OXTc=	2026-10-01 16:51:42.288394+05:30	2026-09-24 16:54:45.014403+05:30	\N	2026-09-24 16:51:42.289111+05:30	2026-09-24 16:54:45.014412+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c466d4d8-0490-4d25-bd93-2bb37a0855f2	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	agF6t1cK+lBpRRSpjbl6WsFYrmoJfQzXygXuDEdSRjI=	2026-10-01 16:54:45.495672+05:30	2026-09-24 16:54:57.838645+05:30	\N	2026-09-24 16:54:45.49588+05:30	2026-09-24 16:54:57.838653+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1c4008b0-439f-4e7a-bc6d-00832d3c3eba	1a077a8c-4029-8ded-d563-19e9b4bdf301	pYpW6hEhLf3ybJ/z1c2+VnrYIdTTISqziJTQLybE+uE=	2026-10-01 16:54:58.408717+05:30	2026-09-24 16:55:17.934214+05:30	\N	2026-09-24 16:54:58.652955+05:30	2026-09-24 16:55:17.936411+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
86bab331-7a64-4991-85d7-4f729fd51b89	1a077a8c-4029-8ded-d563-19e9b4bdf301	LrzZ1YorxamYvgj1rNhfyti92NCgPpMXjV+VG8yRRIE=	2026-10-01 16:55:17.935681+05:30	2026-09-24 16:55:29.095757+05:30	\N	2026-09-24 16:55:17.936411+05:30	2026-09-24 16:55:29.095767+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7eacbbc4-eb37-4d82-b5b7-07a2af8fe7d4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9elbX6mCzyidEin69sjUEuu3Cc1fSPxluU3YQ4wCV0Y=	2026-10-01 16:55:29.56906+05:30	2026-09-24 17:37:36.94003+05:30	\N	2026-09-24 16:55:29.569357+05:30	2026-09-24 17:37:36.946064+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
979b68a7-a57c-481c-92aa-55eca343d613	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	7iRqpARpVfw4sTf0quI8LllVBQjNLXidTYyCeOURKj0=	2026-10-01 17:37:36.943818+05:30	2026-09-24 17:39:05.111374+05:30	\N	2026-09-24 17:37:36.946064+05:30	2026-09-24 17:39:05.111387+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
684216a5-b910-414b-9f4c-9ac5d7ec832a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5xx36LAmc44fvl8qZFHy3BZ/E+ntlqkU8l0WV8jTTb0=	2026-10-01 17:39:05.66179+05:30	2026-09-24 17:42:40.718966+05:30	\N	2026-09-24 17:39:05.663693+05:30	2026-09-24 17:42:40.722881+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
506786dc-428c-400b-b203-6cc6c16ca57e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TyHG/r14mmVUgN9VQTKcHdcrOVapMjVnhmXeTNjZGvk=	2026-10-01 17:42:40.721514+05:30	2026-09-24 17:42:46.190597+05:30	\N	2026-09-24 17:42:40.722881+05:30	2026-09-24 17:42:46.191776+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
64fe8645-d6fb-4593-b9fe-23cc729a1b01	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	LClQ+y6XZMw1YL0QJ9TxGJlZHktlJI+ik572HcIMO9c=	2026-10-01 17:42:46.191635+05:30	2026-09-24 17:54:55.42792+05:30	\N	2026-09-24 17:42:46.191776+05:30	2026-09-24 17:54:55.434881+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e6dcfa1a-9eed-41f2-991e-11ab8b51d7b9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	N0D1WABJQ664O1jAukRCrLKZ9AD47+0abCC+DqJ7Vws=	2026-10-01 17:54:55.43145+05:30	2026-09-24 17:59:10.248083+05:30	\N	2026-09-24 17:54:55.434881+05:30	2026-09-24 17:59:10.267829+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8ec1f8e4-5da4-4e9a-9a4f-326e22ab96c5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TbQB4i9k/30IuXjEb58owLJ98Laa4A8FM4zn9049QXI=	2026-10-01 17:59:10.264854+05:30	2026-09-24 17:59:14.569579+05:30	\N	2026-09-24 17:59:10.267829+05:30	2026-09-24 17:59:14.569607+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c7b1f317-54bb-41b5-b1f1-073cfe9e2a6e	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	iFdtQq0AlXt1jjczdscO1oXZ/9avZcq4KXxb1eVo0QE=	2026-10-01 19:19:30.969538+05:30	2026-09-24 19:20:02.181521+05:30	\N	2026-09-24 19:19:30.96978+05:30	2026-09-24 19:20:02.182219+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
af90baef-422b-428d-8017-819a930a8129	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	OL1lUx1Z4DxKJkYWYkfU4YEJwfjtS7+RScqDRNen26I=	2026-10-01 19:20:02.18198+05:30	2026-09-24 19:21:09.024264+05:30	\N	2026-09-24 19:20:02.182219+05:30	2026-09-24 19:21:09.026174+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
00f3b6f7-ac85-47db-a9ac-fcdde5f60c1d	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	PXc5JfIb8DvL7XZXNNp3ZP4a0q4Esg3/RugEA+C0HUc=	2026-10-01 19:21:09.025351+05:30	2026-09-24 19:21:17.784639+05:30	\N	2026-09-24 19:21:09.026174+05:30	2026-09-24 19:21:17.785142+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6b1d51f0-24da-451b-8052-62983870f70e	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	ZdHQ0pDn74i4lWMYZLY8C/IP9Da3EpS9sUdAH+yJ+TQ=	2026-10-01 19:21:17.785023+05:30	2026-09-24 19:21:53.065969+05:30	\N	2026-09-24 19:21:17.785142+05:30	2026-09-24 19:21:53.065988+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4dbf446d-dba9-4aeb-83e6-facd303ee262	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DRJBVLm91yfc1prrHTTCPhz2iDZDqKqN1/2dhmthCx4=	2026-10-01 19:21:54.588727+05:30	2026-09-24 19:22:01.66111+05:30	\N	2026-09-24 19:21:54.588944+05:30	2026-09-24 19:22:01.661134+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2840fa1a-2d99-4284-ba44-8117d301385d	dc139a9d-b996-7354-6c27-72659ea2fd59	x67HSiaUBOCW2MGh9nZfjVc/JRW5kjmPyg6IFEq4Wx4=	2026-10-01 19:22:02.199725+05:30	2026-09-24 19:22:05.286002+05:30	\N	2026-09-24 19:22:02.200019+05:30	2026-09-24 19:22:05.286016+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
37c927c0-1446-4b54-b129-a85ee6083ad8	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	imrkQ2PcF21S9YcP5unCEcoTPh2pRpok1XVAnVScBjU=	2026-10-01 19:22:05.739828+05:30	2026-09-24 19:22:10.772368+05:30	\N	2026-09-24 19:22:05.740145+05:30	2026-09-24 19:22:10.772388+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e85e2a6d-c39b-4a85-a923-7707a07742aa	00000000-0000-4000-9000-000000000050	rQasgNBxfIwd+JGm/s3c3h3MEDqbqyErzzByIHmG9gI=	2026-10-01 19:22:11.877301+05:30	2026-09-24 19:22:30.221987+05:30	\N	2026-09-24 19:22:11.877448+05:30	2026-09-24 19:22:30.222008+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
30a4bb8f-c0cf-4041-bc81-a62de0819f1f	00000000-0000-4000-9000-000000000026	6WWCg50Qx6z9j7zb8CRvsUG7OXZHo+3mayJ3M2tQD9M=	2026-10-01 19:22:30.672783+05:30	2026-09-24 19:23:15.664067+05:30	\N	2026-09-24 19:22:30.672929+05:30	2026-09-24 19:23:15.685391+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cee7386d-7fa6-4601-ab32-c74cdc2a80de	00000000-0000-4000-9000-000000000026	70hxtt7IA4kB5tTUUQN0sMJr9mTA4gGwuKJuVheBXkM=	2026-10-01 19:23:15.681643+05:30	2026-09-24 19:23:55.507906+05:30	\N	2026-09-24 19:23:15.685391+05:30	2026-09-24 19:23:55.507926+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
00f6b01b-fc2d-4f79-8626-90826f49c101	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	5Y1J0JtZ6CL69793TNKuKSVrLrC7jGS5Z8jm+cXXlDQ=	2026-10-01 19:23:39.005679+05:30	2026-09-24 19:23:56.002569+05:30	\N	2026-09-24 19:23:39.00594+05:30	2026-09-24 19:23:56.003127+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
58880be6-c35f-4b7f-bb31-e3ce9031ebb4	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	xn/NgVWB0gaHLIwZeRFWxyAyvz4oSLswhSJchrJ5u7c=	2026-10-01 19:23:56.002895+05:30	2026-09-24 19:26:04.382041+05:30	\N	2026-09-24 19:23:56.003127+05:30	2026-09-24 19:26:04.382063+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7d7d1ad0-e931-48fd-9c59-b805abefbeb3	00000000-0000-4000-9000-000000000050	L3M7PkNMasCy/f86Nf0/fO9yZFao3zaQxxxhxUvAnTA=	2026-10-01 19:24:12.229806+05:30	2026-09-24 19:26:05.51828+05:30	\N	2026-09-24 19:24:12.230211+05:30	2026-09-24 19:26:05.518616+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
665400bd-3c44-46cd-8fbb-ccabd5dc0a4a	00000000-0000-4000-9000-000000000050	XTtMU7YRVrUy2h2/8MY2++uegDeVAh4MywiURi4RiIQ=	2026-10-01 19:26:05.51848+05:30	2026-09-24 19:26:09.251228+05:30	\N	2026-09-24 19:26:05.518616+05:30	2026-09-24 19:26:09.25124+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
70b99eaf-0cf0-4994-92fc-ab5a355bfe12	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	23l2ulkZNIUAbGrHD23dlyLUkJVzDyNdRmHxv0HPr2o=	2026-10-01 19:26:09.727969+05:30	2026-09-24 19:26:17.174904+05:30	\N	2026-09-24 19:26:09.728195+05:30	2026-09-24 19:26:17.174919+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5c059af7-29fb-45fe-a885-817f95f95d17	00000000-0000-4000-9000-000000000009	SsMMZh5w8DOi+UPRkNmy8Iw9GsGGuum1fyPAjumdPKM=	2026-10-01 19:26:17.602795+05:30	2026-09-24 19:26:20.551483+05:30	\N	2026-09-24 19:26:17.603075+05:30	2026-09-24 19:26:20.551497+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1155f9ef-7241-4aa8-94a8-6d03dbee5663	00000000-0000-4000-9000-000000000038	9MXw1B/VIjphxbrmPuHEB0TlLffFbK9UbWFBAzHxni0=	2026-10-01 19:26:21.00004+05:30	2026-09-24 19:26:32.188758+05:30	\N	2026-09-24 19:26:21.000202+05:30	2026-09-24 19:26:32.188775+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
010e9540-e667-4a29-8d55-89a008a38c10	1a077a8c-4029-8ded-d563-19e9b4bdf301	PhigakrGytgjrZkw5vveFke+7HhHIc5oAaibqBeySMw=	2026-10-01 19:26:32.628179+05:30	2026-09-24 19:26:43.886879+05:30	\N	2026-09-24 19:26:32.628338+05:30	2026-09-24 19:26:43.886896+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dc86c1c9-afd5-4f06-ac65-e484014eaf9e	00000000-0000-4000-9000-000000000017	Hgp5o9ib+FwwnxMmsERyJqZKLuigeQAG6WSjYiZfwPE=	2026-10-01 19:26:44.324022+05:30	2026-09-25 10:03:23.951697+05:30	\N	2026-09-24 19:26:44.324162+05:30	2026-09-25 10:03:23.977904+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1f352908-5cc1-4eae-b724-e6e509ce33a6	00000000-0000-4000-9000-000000000017	wGmXY815SzciZJi0k7LO1BPW5PNAEb/WiLrQbt7kbyw=	2026-10-02 10:03:23.974712+05:30	2026-09-25 10:04:17.636554+05:30	\N	2026-09-25 10:03:23.977904+05:30	2026-09-25 10:04:17.63762+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f42add20-30c6-45d8-97a2-e8454591fb17	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	WcSCZwQ8L8NNmP7oLOgVGvC9zlsTSYqhP4Ker2l70Z8=	2026-10-01 19:30:08.767616+05:30	2026-09-25 10:04:32.688091+05:30	\N	2026-09-24 19:30:08.767781+05:30	2026-09-25 10:04:32.688565+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
36932913-8197-495f-a3dc-c44a58b38431	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	poqcsqoB+juQMlX/3kGI+DyTQlQJ2Ufn1Haz42ewFKs=	2026-10-02 10:04:32.688445+05:30	2026-09-25 10:05:18.816119+05:30	\N	2026-09-25 10:04:32.688565+05:30	2026-09-25 10:05:18.81658+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
573bc169-b02c-41e6-86a0-97fdfa11719b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	pfuIg+1z+6PKdtxAzg6Sa908gkbcp8NuhbGA41hjYe8=	2026-10-02 10:11:38.568739+05:30	2026-09-25 20:34:55.846317+05:30	\N	2026-09-25 10:11:38.568957+05:30	2026-09-25 20:34:55.942267+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e5ecad4c-6dbc-4f1e-b675-c71a4bd12652	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zbWyee6CUKFNcweb7sRvNhsANKJX0kZFaDjPxWBrTY0=	2026-10-02 20:34:55.931484+05:30	2026-09-25 20:35:27.412659+05:30	\N	2026-09-25 20:34:55.942267+05:30	2026-09-25 20:35:27.412814+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ab2fabe0-bf3b-4438-917a-3f422414ead3	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	xx3VCjknTd8one3LvzDIjCkw5TAZdLcZJYfrJBj4L60=	2026-10-02 10:05:18.816456+05:30	2026-09-25 20:35:28.229825+05:30	\N	2026-09-25 10:05:18.81658+05:30	2026-09-25 20:35:28.230848+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c00f9244-cf7d-42bf-91d7-d20166616335	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	lPMn9xd8E9dSV4snCLUVZ8Fw0rj7o1YmmDToXkXk6cI=	2026-10-02 20:35:28.230601+05:30	2026-09-25 20:35:36.945857+05:30	\N	2026-09-25 20:35:28.230848+05:30	2026-09-25 20:35:36.945893+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bf78f1ae-1100-41c9-b339-838675d4ddca	40517b71-5e62-182e-73b5-d4070e20a3c2	j69r32sdByAMlvkAhQDa6dBp43T+Ucnjxg3md2JqI/c=	2026-10-02 20:35:37.547992+05:30	2026-09-25 20:35:41.344473+05:30	\N	2026-09-25 20:35:37.548428+05:30	2026-09-25 20:35:41.344507+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d375dc18-99cd-4530-a7b5-043fdda29c16	00000000-0000-4000-9000-000000000017	74HdN7QavRavaxkC7CkU+OIeyqtB4ysZA/xdeEEe91o=	2026-10-02 10:04:17.637322+05:30	2026-09-25 21:29:21.992799+05:30	\N	2026-09-25 10:04:17.63762+05:30	2026-09-25 21:29:22.000854+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
654cf7c6-5c05-4500-9654-0f7098d57116	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	32POqdtfKhNpLcOtZ8jyFu+Ee5pnSewIus9q9NaGORg=	2026-10-01 19:23:51.745124+05:30	2026-09-25 21:32:07.106749+05:30	\N	2026-09-24 19:23:51.745324+05:30	2026-09-25 21:32:07.106944+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bd678a41-4743-43e5-8756-c5eddddbcda2	00000000-0000-4000-9000-000000000003	ZFJjtCjeEtJNhKX754xJflND15qKu89GBVuQdTJcQk0=	2026-10-02 20:35:41.94278+05:30	2026-09-25 20:35:47.886462+05:30	\N	2026-09-25 20:35:41.943071+05:30	2026-09-25 20:35:47.88649+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c92f649c-cd42-40eb-97b1-5ca93272676b	40517b71-5e62-182e-73b5-d4070e20a3c2	HUoPRJ6MJQ3/WqgBVrVL43deKSqgxwzzaexWkFjjg38=	2026-10-02 20:35:48.484898+05:30	2026-09-25 20:35:51.456859+05:30	\N	2026-09-25 20:35:48.485121+05:30	2026-09-25 20:35:51.456889+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6c06fe78-cde6-4e67-9a4c-51ea20d70eb0	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	JOMEHDXvJYhY9e0YDirtMusxvRyloSr2h95hvSzRdIk=	2026-10-02 20:35:52.041455+05:30	2026-09-25 20:36:29.906068+05:30	\N	2026-09-25 20:35:52.041772+05:30	2026-09-25 20:36:29.906252+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
faee56b5-8f46-4f7a-a98c-a7b6ec510bcc	40517b71-5e62-182e-73b5-d4070e20a3c2	feYd9f4FXprAldgf3JcV7SqVUOAgdz9+Xd5GlDEPxzk=	2026-10-02 20:36:30.497727+05:30	2026-09-25 20:37:05.580882+05:30	\N	2026-09-25 20:36:30.497926+05:30	2026-09-25 20:37:05.580916+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
df5c020c-f20c-459e-8629-a52010286873	00000000-0000-4000-9000-000000000003	xRYi7Z+EXAp1tDnMAfQZjIo6td0kcwfgdhCxRYu9xxE=	2026-10-02 20:37:06.176819+05:30	2026-09-25 20:37:19.36463+05:30	\N	2026-09-25 20:37:06.177578+05:30	2026-09-25 20:37:19.364653+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aebd9854-6c2c-43c4-987d-125f8484e686	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Yap+l+FDbNG+Fu8Pk69vwmZLdh1NS6BZxGBpYrGQias=	2026-10-02 20:37:20.133833+05:30	2026-09-25 20:38:04.822797+05:30	\N	2026-09-25 20:37:20.134183+05:30	2026-09-25 20:38:04.822844+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e6b03034-4f26-498d-aba0-5eacd1be7ec0	40517b71-5e62-182e-73b5-d4070e20a3c2	S5JNJtrCN2btpAgP5k30r+JmQ33ZutC5RAmWaGc8ik8=	2026-10-02 20:38:05.405793+05:30	2026-09-25 20:38:09.377971+05:30	\N	2026-09-25 20:38:05.406183+05:30	2026-09-25 20:38:09.377994+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c30dd5fa-e5f2-4e77-ac3f-0bc0b3458c8a	00000000-0000-4000-9000-000000000003	tqvPO3Pv9df3oX9xLs89DGstBH2q/ANKA2q0Iz2Uscs=	2026-10-02 20:38:09.955768+05:30	2026-09-25 20:38:31.314869+05:30	\N	2026-09-25 20:38:09.955932+05:30	2026-09-25 20:38:31.314911+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
62c4f854-048d-43b6-9f47-de26e821c4ce	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3hNYJKFdPOULLZqxN1lb8bwuBnL03/mXDIC+gHCTkdI=	2026-10-02 20:38:31.998166+05:30	2026-09-25 20:38:47.445494+05:30	\N	2026-09-25 20:38:31.99855+05:30	2026-09-25 20:38:47.445516+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7cc666d8-6907-4f8a-a191-a2a05187defd	00000000-0000-4000-9000-000000000003	X6Zx0sZP1zpWvaloG7fFjtnRBL7puIuyKQK7bNjXxgE=	2026-10-02 20:38:48.003225+05:30	2026-09-25 20:39:15.433005+05:30	\N	2026-09-25 20:38:48.003376+05:30	2026-09-25 20:39:15.433024+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f0d465ac-da7f-4bef-954c-ee33108c3e99	a0000000-0000-0000-0000-000000000032	SwST4Q/BxP0mJzuOqPFbAOXIvqcpoU24GGl4ksSnNAc=	2026-10-02 20:39:16.016933+05:30	2026-09-25 20:39:57.585393+05:30	\N	2026-09-25 20:39:16.017081+05:30	2026-09-25 20:39:57.585412+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c6edc530-a862-41cb-9a9a-3e44e57b1822	dc139a9d-b996-7354-6c27-72659ea2fd59	wSTftpbkT5N72psE+Enspis2AzYk+qjzz0x9Ia2w6Is=	2026-10-02 20:39:58.228034+05:30	2026-09-25 20:42:43.96484+05:30	\N	2026-09-25 20:39:58.228213+05:30	2026-09-25 20:42:43.964892+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b4ecb818-d443-4d0d-8ac4-ba0b0fe54b09	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	OS0UrZR/0FywhPDq36mKydTsBVZyVqO8//eKxHkcSgg=	2026-10-02 20:42:44.5287+05:30	2026-09-25 20:43:14.48033+05:30	\N	2026-09-25 20:42:44.528882+05:30	2026-09-25 20:43:14.480363+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2efd068c-6c5d-4a62-95cb-f34ddc3cb91e	730809c0-fc01-a664-03ca-28e0e32d0393	rDFSDOAbkqWWf0Vxm0gxOdzEhfaBCTpLapI2sSiX6/M=	2026-10-01 19:23:59.214927+05:30	2026-09-25 20:43:15.229387+05:30	\N	2026-09-24 19:23:59.215215+05:30	2026-09-25 20:43:15.229714+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d89f7646-dcc8-438c-af8f-e1eb97c17f79	730809c0-fc01-a664-03ca-28e0e32d0393	5DR03hR51kCQQScz8MtT4gCDoWlavy3xbev5Ux0vA3w=	2026-10-02 20:43:15.229594+05:30	2026-09-25 21:04:58.225128+05:30	\N	2026-09-25 20:43:15.229714+05:30	2026-09-25 21:04:58.226614+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7b7b6bd2-9311-42ea-82f0-9d7783c56bb3	00000000-0000-4000-9000-000000000009	QJlnvhzi669NvLHlD7f06bv+h+Vt0tTkH5Zv4ZSVZWw=	2026-10-02 21:04:58.888228+05:30	2026-09-25 21:06:12.443505+05:30	\N	2026-09-25 21:04:58.91109+05:30	2026-09-25 21:06:12.443525+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
63315811-c7b0-414a-ac5f-86838a4f5a57	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	z1vs3o2zJhQ7dJIUakLXEAt5jIQ7Gi6gY9lL+RIGl9w=	2026-10-02 21:06:13.03307+05:30	2026-09-25 21:06:47.889829+05:30	\N	2026-09-25 21:06:13.039394+05:30	2026-09-25 21:06:47.889846+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6e76a9dc-d7d2-432e-82fd-6693b86f8180	e7554ba2-e546-93ce-1e88-a073badd78a2	JzisM3akhJeQh8F1E85sfGZAc6lhNjSntIeDM46mk2M=	2026-10-02 21:06:48.516346+05:30	2026-09-25 21:07:30.759716+05:30	\N	2026-09-25 21:06:48.517508+05:30	2026-09-25 21:07:30.759738+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3eca175f-b3ca-416f-817c-179bf4c844de	00000000-0000-4000-9000-000000000037	NUdizIHPY5C0oSSHM1QyKbST1mcTMg5t8cPn0LAvVXU=	2026-10-02 21:07:31.392348+05:30	2026-09-25 21:07:41.01936+05:30	\N	2026-09-25 21:07:31.392525+05:30	2026-09-25 21:07:41.019378+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
df56bae6-6928-4b3c-a639-b2f49de348f9	00000000-0000-4000-9000-000000000016	C+PiaY2OEauC7r7rG+ToU4x5SfB7BP7VLNwhuzQwrDU=	2026-10-02 21:07:41.580549+05:30	2026-09-25 21:07:50.353088+05:30	\N	2026-09-25 21:07:41.58069+05:30	2026-09-25 21:07:50.3531+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c56a59ca-c6c9-4bb2-82fd-a88fac65775c	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	W1xlqiCoZpIERmG11hsjQSR0CjRpyJr328Rc/iSgQJs=	2026-10-02 21:07:50.959575+05:30	2026-09-25 21:09:48.71056+05:30	\N	2026-09-25 21:07:50.959713+05:30	2026-09-25 21:09:48.710572+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7133fa76-715e-4e0b-87aa-675d5d2554b0	00000000-0000-4000-9000-000000000037	cmhzLJ0iYTGF2W91i2RwRHHR0lg0czS62UhQ/kSo40M=	2026-10-02 21:09:49.334353+05:30	2026-09-25 21:10:20.096139+05:30	\N	2026-09-25 21:09:49.340496+05:30	2026-09-25 21:10:20.096153+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
64d5b517-8ab7-44b1-9e2d-58db3b41751b	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	+cE7icbOJzupsL83dc0des+EmRsOu4rHtOFM17/3QAI=	2026-10-02 21:10:20.603986+05:30	2026-09-25 21:10:29.753733+05:30	\N	2026-09-25 21:10:20.604374+05:30	2026-09-25 21:10:29.753752+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d6106c3e-8367-4804-a7ce-c4da476c2d90	00000000-0000-4000-9000-000000000038	A+FBd5HdVyZ+7gHG92GJ9XaT0J8mYwY24SNfmt9c7Vg=	2026-10-02 21:10:30.370504+05:30	2026-09-25 21:29:07.543565+05:30	\N	2026-09-25 21:10:30.370837+05:30	2026-09-25 21:29:07.543579+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7b21ea0b-626a-489c-9ca7-31091c5b6af1	1a077a8c-4029-8ded-d563-19e9b4bdf301	HK+T16LWL/3N/4vIy7yb68Gz7vlcobjjvdhFKANgqLs=	2026-10-02 21:29:08.051651+05:30	2026-09-25 21:29:21.413649+05:30	\N	2026-09-25 21:29:08.051772+05:30	2026-09-25 21:29:21.41367+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e07ca6ff-1b43-4a6e-8dad-b624af2c4400	00000000-0000-4000-9000-000000000017	R1FxGuwj8tMMnKXq1BnB+i60Zs+I0IORfRsTlQyoeRo=	2026-10-02 21:29:22.000621+05:30	2026-09-25 21:29:32.826667+05:30	\N	2026-09-25 21:29:22.000854+05:30	2026-09-25 21:29:32.826686+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
787df144-1303-43c8-adbb-b961ef459a6f	00000000-0000-4000-9000-000000000041	T2EZiq+H4jn+8xOphIZijiKRw7ipx+5nN8Sf5H1ck+w=	2026-10-02 21:29:33.415682+05:30	2026-09-25 21:30:56.099406+05:30	\N	2026-09-25 21:29:33.415799+05:30	2026-09-25 21:30:56.099432+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4a261fff-547e-4c85-828f-17456bf6740d	a3a20ac4-43a2-de64-52d3-bfafce7c7053	Wx9fPZFCmdLRr2wjbchBluMC5Z0/7OwEpbykxqAT6e4=	2026-10-02 21:30:56.723117+05:30	2026-09-25 21:31:06.456545+05:30	\N	2026-09-25 21:30:56.723248+05:30	2026-09-25 21:31:06.456565+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d2455d07-3a78-45c2-afa6-5b12887fd0e8	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	WDMY67wIO84Znb2ld0TYKLl2JmIlAXqJaBn+Lpx7HFc=	2026-10-02 21:31:07.078654+05:30	2026-09-25 21:31:12.402224+05:30	\N	2026-09-25 21:31:07.078828+05:30	2026-09-25 21:31:12.40224+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2e7750a8-b794-4953-ac84-759b97d2f46c	00000000-0000-4000-9000-000000000043	lu1uQwjTrfMjxtHtWDVSMtdxUZEmPgG9y1O+BejyKPw=	2026-10-02 21:31:12.994662+05:30	2026-09-25 21:31:45.159954+05:30	\N	2026-09-25 21:31:12.994868+05:30	2026-09-25 21:31:45.159966+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e254710b-2249-4f3b-84f0-0fc57146471a	65e2ffa3-6073-780a-b849-4d9604c7251c	6Ge9djuQYaV7CteoVN5fJua1mr4P4DA8mMlEDKva+8o=	2026-10-02 21:31:45.730804+05:30	2026-09-25 21:31:54.009196+05:30	\N	2026-09-25 21:31:45.730916+05:30	2026-09-25 21:31:54.009206+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b6466435-863b-47a8-9ffe-9dba53150df9	00000000-0000-4000-9000-000000000021	BVAYUOFzQhLbGepgmIpEChPCk/kLkvp/Dg5Oaua8to0=	2026-10-02 21:31:54.636163+05:30	2026-09-25 21:32:06.55719+05:30	\N	2026-09-25 21:31:54.636352+05:30	2026-09-25 21:32:06.557199+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fa64c5f9-372e-47a6-b274-2e84e0d95f2f	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	JGW7u2Rlcr6ztRi90sdWC34xvPgRiZ6dtbuKpHrHZxM=	2026-10-02 21:32:07.106865+05:30	2026-09-26 20:01:21.550172+05:30	\N	2026-09-25 21:32:07.106944+05:30	2026-09-26 20:01:21.55134+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c029a228-e4ee-4c63-accc-a17ecae61d9d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	kGFdz5s5zBRZBgf60X78+jXDgNf3PzRuHP81wLskb/4=	2026-10-03 20:01:22.480563+05:30	2026-09-26 20:18:25.647174+05:30	\N	2026-09-26 20:01:22.487258+05:30	2026-09-26 20:18:25.647186+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
af5af8a4-b550-4af3-bf0e-ce50e552c008	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	unvSjc2pXqf1rh9261u9m9MefdrOeprck0Qhjf118+w=	2026-10-03 20:18:26.162323+05:30	2026-09-27 12:56:43.374826+05:30	\N	2026-09-26 20:18:26.162477+05:30	2026-09-27 12:56:43.491265+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d4cfc8a4-101a-493e-b12e-c0c2d45624dc	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	H10NgH3jDnnTybyICvu2DOrywsQy3nbv5zGzvF3/FeE=	2026-10-04 12:56:43.454285+05:30	2026-09-27 12:57:28.18259+05:30	\N	2026-09-27 12:56:43.491265+05:30	2026-09-27 12:57:28.183046+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
76000c24-aaec-4f06-b174-e1e95a153414	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	3iGT/ve7AcrSz3q32UrmdXZNyWD59pkBNrsf7jZ+Yrg=	2026-10-04 12:57:28.88837+05:30	2026-09-27 12:57:39.626679+05:30	\N	2026-09-27 12:57:28.890663+05:30	2026-09-27 12:57:39.626701+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b4e1cb6d-6b26-478f-b764-86a9c56b06ca	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	X6MiU2jn9lCEVxM+ts6xck3W0eOQ3sSF+sXLSgxYlAs=	2026-10-04 12:57:40.232572+05:30	2026-09-27 13:09:23.275088+05:30	\N	2026-09-27 12:57:40.233685+05:30	2026-09-27 13:09:23.275204+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2f0e3d22-0ead-4f04-915a-15da2c35baf6	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	SgL39jR9j8Da3lEctXPBBAqHQ2Z2p2CeZF6uIjE6eww=	2026-10-04 13:09:23.818664+05:30	2026-09-27 13:28:57.796187+05:30	\N	2026-09-27 13:09:23.819122+05:30	2026-09-27 13:28:57.814265+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d0a8b04c-c792-42f5-997c-64d3d965670e	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	tJZ5BF0nWxE6QI5dNrAfw0YN90Dy5gRrtI3N1NWxUbU=	2026-10-04 13:28:57.805906+05:30	2026-09-27 13:53:02.051112+05:30	\N	2026-09-27 13:28:57.814265+05:30	2026-09-27 13:53:02.053334+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9dbdf6d3-bce9-42ee-8bf5-ae4e053af167	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	gqlMqpuKv2qC7/ktxxLGUxsiukJaNN6lYSBInrXOOA0=	2026-10-04 13:53:02.051944+05:30	2026-09-27 14:44:26.561817+05:30	\N	2026-09-27 13:53:02.053334+05:30	2026-09-27 14:44:26.562833+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
22b7aeff-d095-4651-9882-72455b5180eb	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	xC6eiuaLgFsbbTTMHYgeKPcr4FkNsEzqhzF3YC1dt/A=	2026-10-04 14:44:26.562466+05:30	2026-09-27 14:59:24.614427+05:30	\N	2026-09-27 14:44:26.562833+05:30	2026-09-27 14:59:24.6166+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
94957281-41b5-4dd8-935a-4cc08aa6ecd4	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	2VSTGuFVkrK5vcc3EGBhZRTUVQFEruhv5Ma1Mlbk+wk=	2026-10-04 14:59:24.616353+05:30	2026-09-27 15:09:32.150531+05:30	\N	2026-09-27 14:59:24.6166+05:30	2026-09-27 15:09:32.150621+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3d0e3d12-3a41-4f13-baef-3317cda5d968	40517b71-5e62-182e-73b5-d4070e20a3c2	mWK2jktEmpfsTuPgyMci7bw1zzkCgvMvxvLcFGHJkYk=	2026-10-04 15:09:32.986649+05:30	2026-09-27 15:10:00.701878+05:30	\N	2026-09-27 15:09:32.987461+05:30	2026-09-27 15:10:00.701907+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fe76ab68-4727-478d-b0bf-ee48bf4bdbe3	00000000-0000-4000-9000-000000000003	OTlaz9Ux5NhaWLtLw7BeW2NxH/+HDVPlZZd5W7TSPzA=	2026-10-04 15:10:01.33063+05:30	2026-09-27 15:10:08.858724+05:30	\N	2026-09-27 15:10:01.330807+05:30	2026-09-27 15:10:08.858749+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4747bdea-6948-4f87-a251-9b0b27556948	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	H5LrS139aE7LaqV3kiosLMrgnK1oWCbltP3iQBv07rw=	2026-10-04 15:10:09.457845+05:30	2026-09-27 15:10:13.587893+05:30	\N	2026-09-27 15:10:09.458163+05:30	2026-09-27 15:10:13.587908+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1d086a74-e376-4987-a579-715cd422d2c1	40517b71-5e62-182e-73b5-d4070e20a3c2	Av6ahgahUumAh/7kmM6pAvalP5MCcieU7kYPjx/OtUE=	2026-10-04 15:10:14.163888+05:30	2026-09-27 15:10:16.908711+05:30	\N	2026-09-27 15:10:14.164117+05:30	2026-09-27 15:10:16.908732+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cc43771f-5ece-49b3-beba-ac3c3ce27552	00000000-0000-4000-9000-000000000003	5ZBjgg62R0WdDqXg4CxwYyLPCM+TGNXJbINi87Ny0AQ=	2026-10-04 15:10:17.524452+05:30	2026-09-27 15:18:48.061161+05:30	\N	2026-09-27 15:10:17.524637+05:30	2026-09-27 15:18:48.061184+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3d9c1e7b-5af1-4868-b1d2-73564adfe890	a0000000-0000-0000-0000-000000000032	mSYD1SN9gs35nyV5gvhlZr73HQk6lLE4KcIXQRL058U=	2026-10-04 15:18:48.645544+05:30	2026-09-27 15:29:21.005595+05:30	\N	2026-09-27 15:18:48.645766+05:30	2026-09-27 15:29:21.007717+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f160dbc8-28ea-4678-a42e-36719310e19a	a0000000-0000-0000-0000-000000000032	WgaFj0sVRs2a5d8XSx3wdd7H66JXxFSl8HQw36Oj0zE=	2026-10-04 15:29:21.007558+05:30	2026-09-27 15:34:20.929002+05:30	\N	2026-09-27 15:29:21.007717+05:30	2026-09-27 15:34:20.929025+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
284a0664-7a01-4c9c-afaf-f7b0f9feb66b	dc139a9d-b996-7354-6c27-72659ea2fd59	BufWkABAXqDIvALTHSDZGDTf7JJC0tirG1AF4Dszxv8=	2026-10-04 15:34:21.583827+05:30	2026-09-27 19:06:03.558336+05:30	\N	2026-09-27 15:34:21.584471+05:30	2026-09-27 19:06:03.616828+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
13553c18-b0aa-4ea4-ad91-9e696319c6be	dc139a9d-b996-7354-6c27-72659ea2fd59	UXO87YaA/D83oRQM/qWCHsiKbZuF1e526vC4s7gURuY=	2026-10-04 19:06:03.591773+05:30	2026-09-27 19:08:28.637789+05:30	\N	2026-09-27 19:06:03.616828+05:30	2026-09-27 19:08:28.637831+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
09808254-730d-41ba-9a4d-5d20a71f0f93	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	iibl2eI7FTTcNs5uLpGjkp1tnYXE6y5Zi6dCZ2OpW5o=	2026-10-04 19:08:29.41344+05:30	2026-09-27 19:09:38.456234+05:30	\N	2026-09-27 19:08:29.413614+05:30	2026-09-27 19:09:38.456251+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fd836048-e4c0-4671-8310-cc3d5a24de39	dc139a9d-b996-7354-6c27-72659ea2fd59	WVwW4bzh9gBDhpbxkdSWrvGYRu9zenIxdR/LopEVP18=	2026-10-04 19:09:39.763182+05:30	2026-09-27 19:20:36.308293+05:30	\N	2026-09-27 19:09:39.763353+05:30	2026-09-27 19:20:36.308317+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ac9de1d9-9cf5-4c45-b9b7-fedbf1f390a5	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	JRIc+Vw2vB2Pkz9AhAaqBrBxbsifTmgkCVjBqIxahAs=	2026-10-04 19:20:37.011172+05:30	2026-09-27 19:23:04.217948+05:30	\N	2026-09-27 19:20:37.011408+05:30	2026-09-27 19:23:04.21797+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3bbe194f-226f-4f9f-aa72-9412995a8cf7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rYUwN9foRjuCrSl89j1hn/SxeyHYIUE88PXf3na3ueQ=	2026-10-04 19:23:04.937868+05:30	2026-09-27 19:23:20.138582+05:30	\N	2026-09-27 19:23:04.938115+05:30	2026-09-27 19:23:20.138599+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a4d882dd-1f04-43a0-8f8d-8cb451c36c7b	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	ogk3DJE/EMaOD5zM/Oq7vaWCRBaooSAhTHWRUVm+Aso=	2026-10-04 19:23:20.776466+05:30	2026-09-27 19:49:07.970519+05:30	\N	2026-09-27 19:23:20.777109+05:30	2026-09-27 19:49:08.023268+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ec06a60f-d744-43b2-afd2-f7084d747bdf	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	WjofGzRYjYADsEvZm/DpzUow7P9w8FGx8n0tLAlo2GU=	2026-10-04 19:49:08.005743+05:30	2026-09-27 19:49:10.398821+05:30	\N	2026-09-27 19:49:08.023268+05:30	2026-09-27 19:49:10.398842+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7fcc6931-8c9e-402c-9635-f75364ed4f4c	730809c0-fc01-a664-03ca-28e0e32d0393	O5RCzTfqX6Uy+JJkkenbrTneTEAIxu6RPY86+35bmPM=	2026-10-04 19:49:11.219574+05:30	2026-09-27 20:05:16.16196+05:30	\N	2026-09-27 19:49:11.219714+05:30	2026-09-27 20:05:16.172181+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c766cb65-eac9-4a5d-bf04-59bcf0439dff	730809c0-fc01-a664-03ca-28e0e32d0393	0vKJ/t4qu5DjmUOO5yHF+PgUgUv9nVICrP75T+S9YJM=	2026-10-04 20:05:16.170209+05:30	2026-09-27 20:13:04.005105+05:30	\N	2026-09-27 20:05:16.172181+05:30	2026-09-27 20:13:04.005517+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3bc5293c-f8ad-4bbc-8ad2-7d77559e68c1	730809c0-fc01-a664-03ca-28e0e32d0393	2hMlAszusBSBMRbrgVJIXkbcDIEZBc6IIDPM1e1dH5s=	2026-10-04 20:13:04.005355+05:30	2026-09-27 20:13:13.495721+05:30	\N	2026-09-27 20:13:04.005517+05:30	2026-09-27 20:13:13.502717+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
95f107e4-1c61-4de6-9bb0-cb751fb23313	730809c0-fc01-a664-03ca-28e0e32d0393	SNNUQZMlzKl1Xp0e/ohGdK41Pt1tZRH373RA03N2SWQ=	2026-10-04 20:13:13.495929+05:30	2026-09-27 20:14:59.386735+05:30	\N	2026-09-27 20:13:13.502717+05:30	2026-09-27 20:14:59.405248+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e85fbe8e-e495-4150-979f-7cdeebe28184	730809c0-fc01-a664-03ca-28e0e32d0393	E6puMeAgEogPjuOm8/n3AQIR9awW9mv7v91XKY0pnAo=	2026-10-04 20:14:59.39077+05:30	2026-09-27 20:15:13.799473+05:30	\N	2026-09-27 20:14:59.405248+05:30	2026-09-27 20:15:13.799864+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8414cb39-de26-4660-b5ab-dc48b693b87b	730809c0-fc01-a664-03ca-28e0e32d0393	sD3/PboUg2UJkLQdY1MHtOy0LZn8yOLGLVR8KSrWAc4=	2026-10-04 20:15:13.799746+05:30	2026-09-27 20:19:46.133097+05:30	\N	2026-09-27 20:15:13.799864+05:30	2026-09-27 20:19:46.136224+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a56501eb-078c-4a10-9005-d55244a621ed	730809c0-fc01-a664-03ca-28e0e32d0393	Coa7RQK/kz3kh5Lv5kMWM5NP8rUshXxKpRkOkqnyFy0=	2026-10-04 20:19:46.13401+05:30	2026-09-27 20:28:09.103631+05:30	\N	2026-09-27 20:19:46.136224+05:30	2026-09-27 20:28:09.103648+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ec2b7097-e977-4108-b5fc-1e21b78dc54d	00000000-0000-4000-9000-000000000009	nlGNpplq4Ef1utJqCtObrTQEJKiYrArAVXj+RE/sFQk=	2026-10-04 20:28:09.807137+05:30	2026-09-27 20:28:14.211721+05:30	\N	2026-09-27 20:28:09.812408+05:30	2026-09-27 20:28:14.211738+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
153e7820-b389-4006-90e0-cbe6e36d7f58	730809c0-fc01-a664-03ca-28e0e32d0393	5mc5Z1936WBPiD5lq3zaPalsW1KY4QdYtBxtY6ALYRg=	2026-10-04 20:28:14.8199+05:30	2026-09-27 20:28:19.269082+05:30	\N	2026-09-27 20:28:14.820921+05:30	2026-09-27 20:28:19.269103+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8703da20-c6ec-449e-92dc-b2a1f5974cf7	00000000-0000-4000-9000-000000000009	IBy2TAS1uCB/64wanUCjtB2Ux4eCODbwND53eio6TmY=	2026-10-04 20:28:19.901573+05:30	2026-09-27 20:29:06.716176+05:30	\N	2026-09-27 20:28:19.901786+05:30	2026-09-27 20:29:06.716192+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6ad25bd5-a790-42bb-af74-145a8a6d2420	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	kW7rZkpXes4aGwm6UbpLMHElyd1+LCWTelOtNd8LYkw=	2026-10-04 20:29:07.342862+05:30	2026-09-27 20:49:29.123514+05:30	\N	2026-09-27 20:29:07.343204+05:30	2026-09-27 20:49:29.123952+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
56a43df0-7138-45a7-b73e-0916064c43ac	00000000-0000-4000-9000-000000000009	m0OvctIwP++ENm1MQOiIMYsr2RaYY7d3za1eRHMKxZM=	2026-10-04 20:49:29.804368+05:30	2026-09-27 20:49:35.447446+05:30	\N	2026-09-27 20:49:29.808758+05:30	2026-09-27 20:49:35.44746+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7cf63016-b7ca-4012-ae3b-b9bf39683eff	730809c0-fc01-a664-03ca-28e0e32d0393	kvjwIoSfuYXLm2B059V58IQWWHTtnJvL/oEE7l3Qk90=	2026-10-04 20:49:36.048278+05:30	2026-09-27 20:49:41.276461+05:30	\N	2026-09-27 20:49:36.04852+05:30	2026-09-27 20:49:41.276833+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1a09cd84-70c9-4218-ba30-5e11e85a7238	730809c0-fc01-a664-03ca-28e0e32d0393	Lga/iXlUuB//3C032XlHCeTQvIQpVrJZx5qwn5u98H8=	2026-10-04 20:49:41.276733+05:30	2026-09-27 20:52:33.413574+05:30	\N	2026-09-27 20:49:41.276833+05:30	2026-09-27 20:52:33.413589+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6ebd6963-2f93-47fa-9bf2-4257fa78d093	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	BXAGA+VWgL12ateRLY655/D1eJ2hblHtlKYHLwvHMdE=	2026-10-04 20:52:34.025424+05:30	2026-09-27 21:20:59.734097+05:30	\N	2026-09-27 20:52:34.025566+05:30	2026-09-27 21:20:59.734114+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7417ed7e-1147-41d7-b81f-77c434d07293	e7554ba2-e546-93ce-1e88-a073badd78a2	Rynle9fLVw7KHxtWgS//vu0fjJgGX0klfl2WWtIWk1E=	2026-10-04 21:21:00.452583+05:30	2026-09-27 21:45:06.033473+05:30	\N	2026-09-27 21:21:00.457937+05:30	2026-09-27 21:45:06.034353+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cc9a73a9-7906-476b-a688-62462c24ced8	e7554ba2-e546-93ce-1e88-a073badd78a2	e3HbmK60ByCNQVA9qoM8hyRyQWf3X8Y2P3/scgKzRh0=	2026-10-04 21:45:06.033955+05:30	2026-09-27 21:45:18.27779+05:30	\N	2026-09-27 21:45:06.034353+05:30	2026-09-27 21:45:18.277804+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6e582e82-88f8-41e4-9925-a015dec52bca	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	V0lozF5EfofSN8Vgn+B+Laf8uR5tn1k49Dqqls7GGfA=	2026-10-04 21:45:19.046776+05:30	2026-09-27 21:48:51.630194+05:30	\N	2026-09-27 21:45:19.046963+05:30	2026-09-27 21:48:51.630615+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
687f5f35-537a-4839-b8b3-885fb2d743c4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	CYNl9dEHGNQ03eb0/8usrzT5smHBqTLRg7dtf/NHOa0=	2026-10-04 21:48:51.630466+05:30	2026-09-27 23:52:45.453347+05:30	\N	2026-09-27 21:48:51.630615+05:30	2026-09-27 23:52:45.511787+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3ed50a06-de6b-4c52-8181-2ad2faab1c96	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	KcUvgyflzWYuYGAXH4WJIUzLZIdI3SZ1+D94TFCkdYA=	2026-10-04 23:52:45.494487+05:30	2026-09-27 23:53:02.139939+05:30	\N	2026-09-27 23:52:45.511787+05:30	2026-09-27 23:53:02.139958+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5afb9120-7b29-477a-bb9e-034662b44aef	e7554ba2-e546-93ce-1e88-a073badd78a2	5hoaUWqBk3cDQiiGHw6+iC0Xtb53Irdk5sxh0WEvexg=	2026-10-04 23:53:02.841801+05:30	2026-09-28 00:02:24.988807+05:30	\N	2026-09-27 23:53:02.841932+05:30	2026-09-28 00:02:24.988817+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c783a84f-5198-4d7d-be07-c7e996171038	00000000-0000-4000-9000-000000000015	l/f11KwxIWqU+CLjLzqrw1YBQZ/0XvDjX+sLZ+GOPZU=	2026-10-05 00:02:25.687459+05:30	2026-09-28 00:06:01.829165+05:30	\N	2026-09-28 00:02:25.687637+05:30	2026-09-28 00:06:01.829587+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
89e2f506-507a-4ccd-81f7-63e10d117e19	00000000-0000-4000-9000-000000000015	dF1EQ4uwi8Fbf1E+Y/l7DCBzuh9ISfhu9LVNhcyJJyk=	2026-10-05 00:06:01.829453+05:30	2026-09-28 00:13:56.603918+05:30	\N	2026-09-28 00:06:01.829587+05:30	2026-09-28 00:13:56.610939+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5c52e3c3-7b4e-4f2a-8434-f951423b0960	00000000-0000-4000-9000-000000000015	3JghX4MAfadyCJAxiXTnlqyHvPC7binpMgb05YPQrXQ=	2026-10-05 00:13:56.604134+05:30	2026-09-28 00:14:02.976584+05:30	\N	2026-09-28 00:13:56.610939+05:30	2026-09-28 00:14:02.9766+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c3d2c4f8-c678-4358-9e44-ede53c68526b	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	M4oF4aPCnXcpe29oGoYz9lzOd7vxTUYTR0z4f9zhjFw=	2026-10-05 00:14:03.726519+05:30	2026-09-28 00:15:37.4252+05:30	\N	2026-09-28 00:14:03.7267+05:30	2026-09-28 00:15:37.425214+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b23ed3d4-7899-4f0a-b603-19e1a1395f31	00000000-0000-4000-9000-000000000015	Cjtrwsw8hiefm/L2VODEZoU3akqwFWmJw6q1zWHysrg=	2026-10-05 00:15:38.04721+05:30	2026-09-28 00:16:09.527064+05:30	\N	2026-09-28 00:15:38.047451+05:30	2026-09-28 00:16:09.527075+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
86c17e98-dd00-4d22-aa65-9465183ed950	00000000-0000-4000-9000-000000000035	aekkU8uf6B6YzfSZkZYmr0NvAQBOzMx2tyHUqaa4p0c=	2026-10-05 00:16:10.14815+05:30	2026-09-28 00:16:57.565005+05:30	\N	2026-09-28 00:16:10.153393+05:30	2026-09-28 00:16:57.565021+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7f7685b0-d8bf-4887-8b4b-9c07b3ad4417	00000000-0000-4000-9000-000000000026	NlyZgJOlnEarxMg281PymBB7KEYtdA99rxYl1MFNCG8=	2026-10-05 00:16:58.195738+05:30	2026-09-28 00:18:22.72267+05:30	\N	2026-09-28 00:16:58.195906+05:30	2026-09-28 00:18:22.722681+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
11f0c2d9-7142-4525-a385-7410d7314687	00000000-0000-4000-9000-000000000043	B72xIHhZ4dWwxImyo6UQphjsmbI7aLOwz9pWuf8/EBM=	2026-10-05 00:18:23.358706+05:30	2026-09-28 00:23:03.690728+05:30	\N	2026-09-28 00:18:23.358902+05:30	2026-09-28 00:23:03.690999+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
713d445c-7ab2-44ba-9227-8ced5245a959	00000000-0000-4000-9000-000000000043	dwmgBbswJm3CJlFFE21HFIdFKSzwtnQ7KWI8If4R9lY=	2026-10-05 00:23:03.690877+05:30	2026-09-28 00:36:19.366164+05:30	\N	2026-09-28 00:23:03.690999+05:30	2026-09-28 00:36:19.366634+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
0ee16edb-a43c-4bff-8fbe-468602a4b84e	00000000-0000-4000-9000-000000000043	K6yNf7d0KGPBcyPNsKwarJVxpqSCfgxDht/iS0tGswk=	2026-10-05 00:36:19.366462+05:30	2026-09-28 00:43:53.170052+05:30	\N	2026-09-28 00:36:19.366634+05:30	2026-09-28 00:43:53.17041+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9eac7c21-6683-452f-b9c5-c356ede8ed04	00000000-0000-4000-9000-000000000043	5ajQ933It3rZsKhda7L12Dk8ukweawNarKYo0KvYVVU=	2026-10-05 00:43:53.170258+05:30	2026-09-28 10:26:52.949317+05:30	\N	2026-09-28 00:43:53.17041+05:30	2026-09-28 10:26:53.016383+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bd13a8e4-84e0-4c53-8676-91583e4fde99	00000000-0000-4000-9000-000000000043	YDWBM5U22UUE5JWjaPv1v6FUwNM9pzD/0GmlUkCzDCM=	2026-10-05 10:26:52.972035+05:30	2026-09-28 10:30:43.130541+05:30	\N	2026-09-28 10:26:53.016383+05:30	2026-09-28 10:30:43.134462+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2a272e63-2eaf-46a0-be7e-2a4580ae5705	00000000-0000-4000-9000-000000000043	Kmj1BP9REZEI1F+GJ6dc2vpbGfaD6MWcK2S3qF6NZUo=	2026-10-05 10:30:43.130694+05:30	2026-09-28 10:36:42.250333+05:30	\N	2026-09-28 10:30:43.134462+05:30	2026-09-28 10:36:42.250915+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f0d0b3e7-d50b-4f26-80d0-89a1b3d263d3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	P3IDuQ9EApwJbETGIraYGhPixBlg7JFkB/AK6qKRdBU=	2026-10-05 10:36:42.924165+05:30	2026-09-28 10:37:16.465452+05:30	\N	2026-09-28 10:36:42.929487+05:30	2026-09-28 10:37:16.465466+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bf14b8d7-3dc2-4487-8236-331f6fe22943	00000000-0000-4000-9000-000000000043	wnRNHo/5wpQIN/ZBJlA/fLE0rf3auocJzQCX0usyoBs=	2026-10-05 10:37:17.014243+05:30	2026-09-28 10:37:37.224715+05:30	\N	2026-09-28 10:37:17.028407+05:30	2026-09-28 10:37:37.224728+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ee882868-52f9-4c2f-a2c2-4c660a4ed260	00000000-0000-4000-9000-000000000026	To3jZ4RDjqKyBfw/ZtlcWMIBAfvGZsdB2V5F81yr0xo=	2026-10-05 10:37:37.800842+05:30	2026-09-28 10:42:47.73029+05:30	\N	2026-09-28 10:37:37.802529+05:30	2026-09-28 10:42:47.730299+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
33101a02-5147-4737-a249-538ca491fbce	65e2ffa3-6073-780a-b849-4d9604c7251c	2wBPAXWN3LSkeJ9wqu8WfgfwxIf6LrjIK9+NfjlA3B8=	2026-10-05 10:42:48.303045+05:30	2026-09-28 10:48:03.549412+05:30	\N	2026-09-28 10:42:48.312872+05:30	2026-09-28 10:48:03.549422+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9b9e73e7-9f98-4f1f-bbc4-136730840166	00000000-0000-4000-9000-000000000041	qSDOjVklu4v3DYukevNsRJv9ELdmRcTvP6tH7d3na+k=	2026-10-05 10:48:04.229074+05:30	2026-09-28 10:52:38.312451+05:30	\N	2026-09-28 10:48:04.236296+05:30	2026-09-28 10:52:38.317858+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4aa46ec1-f0e3-41f2-8ac3-d42ed04535f7	00000000-0000-4000-9000-000000000041	z5vEXb3JTDxnK2SqYEdAzLSZzAlehyzK6/peSSA30jY=	2026-10-05 10:52:38.312602+05:30	2026-09-28 11:02:01.700444+05:30	\N	2026-09-28 10:52:38.317858+05:30	2026-09-28 11:02:01.700675+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
23aa141a-bd14-4179-9a72-cb961b562eb0	00000000-0000-4000-9000-000000000041	vl+8wtAsoj8/31QnS2uIJp4flmuUweZryUCBihkyKpE=	2026-10-05 11:02:01.700605+05:30	2026-09-28 11:31:59.333504+05:30	\N	2026-09-28 11:02:01.700675+05:30	2026-09-28 11:31:59.333611+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9ac71b0b-5687-4a0f-a714-2fe31a3d0b6c	a3a20ac4-43a2-de64-52d3-bfafce7c7053	wZDvIapL1fMpDHhP20Taou+y8U3a9zXE/WLXsfGCLyQ=	2026-10-05 11:31:59.980187+05:30	2026-09-28 11:32:34.188738+05:30	\N	2026-09-28 11:31:59.981615+05:30	2026-09-28 11:32:34.188752+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4d96ab1d-fc9b-4983-ba27-1df5d539553b	00000000-0000-4000-9000-000000000041	YYAgM+hL3Ukg08fxlrZU4NLL5nzGq3MyMxt72VFLJfU=	2026-10-05 11:32:34.816837+05:30	2026-09-28 11:32:39.41513+05:30	\N	2026-09-28 11:32:34.816931+05:30	2026-09-28 11:32:39.415143+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
24e24090-c87d-476f-9ec5-21cebb137028	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	4G4nW5xxQXo6oBmoVoj9Kpx5OgVdsg+Z75fLBIgpbfQ=	2026-10-05 11:32:40.147844+05:30	2026-09-28 11:32:59.619594+05:30	\N	2026-09-28 11:32:40.147946+05:30	2026-09-28 11:32:59.619604+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
602973f1-af64-4116-a7eb-f5f6093af2a3	00000000-0000-4000-9000-000000000038	C0NnCFJD+qgS3nDHWliZZIL0ko1KEM4NhIkyh1DEY4A=	2026-10-05 11:33:00.257028+05:30	2026-09-28 11:56:42.886655+05:30	\N	2026-09-28 11:33:00.257156+05:30	2026-09-28 11:56:42.886668+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6042bb2a-d699-4505-8cc7-da2020a435a1	00000000-0000-4000-9000-000000000037	uqgrPEtndGSJBZmWX5JtoqSHvRtA1FRr8oxgzCm4TAs=	2026-10-05 11:56:43.589062+05:30	2026-09-28 12:35:57.195804+05:30	\N	2026-09-28 11:56:43.589554+05:30	2026-09-28 12:35:57.197349+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
504cc1f3-5d0e-4357-a79f-877b12cc4654	00000000-0000-4000-9000-000000000037	FPCJG4WMth2n2Mf64Cx5Gy7lZh+cwUmPBZZoR3uPVnI=	2026-10-05 12:35:57.196262+05:30	2026-09-28 12:35:59.761159+05:30	\N	2026-09-28 12:35:57.197349+05:30	2026-09-28 12:35:59.761175+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aeefff88-c50a-4614-98a3-cb014a3bcbc8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	NXa+c5XWFFtPRlNtZF2fAiInHggxbtUxVtbkXjNK2cE=	2026-10-05 12:36:00.592779+05:30	2026-09-28 12:54:11.679627+05:30	\N	2026-09-28 12:36:00.592928+05:30	2026-09-28 12:54:11.688477+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4fd0f128-dbec-4120-88d1-ee8eab48c664	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	95FpEbSmtaJMt4q0GDz2sF+yVDLTb06gIWWrdc9m/Ts=	2026-10-05 12:54:11.687885+05:30	2026-09-28 13:01:11.378976+05:30	\N	2026-09-28 12:54:11.688477+05:30	2026-09-28 13:01:11.380285+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
03d58c6d-515d-48f2-9bd6-f257e230effc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	pnK3VTUYWc7FjrudoQ8xTngzUxY6nIBL1iz+2JkdCbs=	2026-10-05 13:01:11.380113+05:30	2026-09-28 13:26:35.835193+05:30	\N	2026-09-28 13:01:11.380285+05:30	2026-09-28 13:26:35.836314+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
614271c0-4305-486f-871b-11218046c88b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	rZ867HQTST1G+yNph6hDx9X2DAi42hw/7yLJZV60FRI=	2026-10-05 13:26:35.835396+05:30	2026-09-28 14:33:21.72712+05:30	\N	2026-09-28 13:26:35.836314+05:30	2026-09-28 14:33:21.74093+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
80bc9721-0033-434a-bae7-c80b3c208567	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TEQrOiIe3oUYeLpVBCaKlf4u+DjT8n+gS0i9a74k8oc=	2026-10-05 14:33:21.734025+05:30	2026-09-28 14:34:16.706207+05:30	\N	2026-09-28 14:33:21.74093+05:30	2026-09-28 14:34:16.707089+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3c1e6ca1-5ff7-4f36-940b-00ae29a92fec	00000000-0000-4000-9000-000000000003	+eNNtywDSL7Yh4czcGfKDLx4QmmrtLmMqQcUUdFJRtk=	2026-10-06 12:33:43.820818+05:30	2026-09-29 12:33:53.784583+05:30	\N	2026-09-29 12:33:43.854319+05:30	2026-09-29 12:33:53.785092+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fad23c47-229e-46a9-b629-bdc5aec79dbc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1xhJQtiXaH3eXkSxa8eePAzZSBSMtG3Rg4P2Oc5TGQk=	2026-10-05 14:34:16.706624+05:30	2026-09-29 12:33:54.477443+05:30	\N	2026-09-28 14:34:16.707089+05:30	2026-09-29 12:33:54.479672+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7f69b373-bfa0-4855-80b5-290e3d671fd4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HSudmb4SImEsy0xYEnrzFMi41YcQumEN39sVQ8guHAs=	2026-10-06 12:33:54.479485+05:30	2026-09-29 13:34:44.433544+05:30	\N	2026-09-29 12:33:54.479672+05:30	2026-09-29 13:34:44.471732+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b5459167-d0c8-4523-8118-178fed7d6150	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	lprVeh/eezx62EHjx5RYBBsGJOfLKL3spsl6da3ag+A=	2026-10-06 13:34:44.45086+05:30	2026-09-29 13:34:46.355662+05:30	\N	2026-09-29 13:34:44.471732+05:30	2026-09-29 13:34:46.356722+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
09242b8b-c033-40b4-9155-fa66fa6ad2d4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	75F/jnrLAIS6c2ueEHTC/N9Tv8IQWWIwXBJfmZqYYWc=	2026-10-06 13:34:46.356378+05:30	2026-09-29 14:35:46.408028+05:30	\N	2026-09-29 13:34:46.356722+05:30	2026-09-29 14:35:46.429025+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ff9eba7d-f6e3-42e2-b325-22f18f27b373	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	yFGDF80K8Q77LBrKi6GJJss5gQfsxkg5eK9nJD5uGvQ=	2026-10-06 14:35:46.419589+05:30	2026-09-29 18:32:08.26317+05:30	\N	2026-09-29 14:35:46.429025+05:30	2026-09-29 18:32:08.325155+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e3b2fe76-e902-4330-a44a-6e5e9ec112c8	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	jllyI6aLn8HliwW7E+9Cw5fdCQ1/vYBUxSxVBGk/wv0=	2026-10-06 18:32:08.299931+05:30	2026-09-29 20:28:37.77458+05:30	\N	2026-09-29 18:32:08.325155+05:30	2026-09-29 20:28:37.799262+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ab63ad63-d7ce-4706-840c-ac0dfe826cd5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eiYFaY67HYBa2fL4MDWL2h/+lvYht7XIhtkej6hLJU0=	2026-10-06 20:28:37.793728+05:30	2026-10-02 11:14:00.661559+05:30	\N	2026-09-29 20:28:37.799262+05:30	2026-10-02 11:14:01.137634+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2a4f1434-614b-487a-aa64-efbb8142e541	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	R0mkSU5dqt3dWP2Q2r/uwBAHAAdlHOOXv8YfkjbW4uc=	2026-10-09 11:14:00.993424+05:30	2026-10-02 11:52:40.957302+05:30	\N	2026-10-02 11:14:01.137634+05:30	2026-10-02 11:52:41.078125+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2a939a21-36d2-4957-b8d8-33bbcc47998f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uIkx5UoSp5y1NO4bSuSL28yCnWJDds/bpDNXQ3w2Kb4=	2026-10-09 11:52:41.03559+05:30	2026-10-02 11:52:44.089848+05:30	\N	2026-10-02 11:52:41.078125+05:30	2026-10-02 11:52:44.106076+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
41eb1200-6fee-49df-87db-861ddf535948	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	AbBPpIw1PxH37JcyMK5S1zyK5QxFJuMAYihNPwAEusw=	2026-10-09 11:52:44.103531+05:30	2026-10-02 12:40:46.382084+05:30	\N	2026-10-02 11:52:44.106076+05:30	2026-10-02 12:40:46.440954+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f706ae5c-0b33-45c9-a696-6a2d72dd57fa	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SGGmQnukcP3JT6qnbNH5jTmcdZyg5x/ggNldd/OBURk=	2026-10-09 12:40:46.430015+05:30	2026-10-02 12:42:41.683409+05:30	\N	2026-10-02 12:40:46.440954+05:30	2026-10-02 12:42:41.881914+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3a68f837-3292-4c68-9eeb-5c9dae26cb56	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	SMZhdKLvi36R75rt3S1TC8Swu8fg6wDnXfA3l0xXFw8=	2026-10-09 12:42:41.838369+05:30	2026-10-02 12:42:46.631222+05:30	\N	2026-10-02 12:42:41.881914+05:30	2026-10-02 12:42:46.636868+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4b1f1043-abe8-4d32-b618-3e704c60c9a4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9DQycA2gp49HQe5LShSlORSq+5agBqffj1VFrcbwkes=	2026-10-09 12:42:46.636578+05:30	2026-10-02 12:49:10.423722+05:30	\N	2026-10-02 12:42:46.636868+05:30	2026-10-02 12:49:10.504123+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
76991323-195f-451f-afd1-eba5efedec09	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	cyuc1xFybMQImbTb5gehgjYJtYLOxHud7HZ7SlKWHIY=	2026-10-09 12:49:10.48454+05:30	\N	\N	2026-10-02 12:49:10.504123+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: repository; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repository ("Id", "FileName", "Category", "Size", "LastUpdated", "UploadedBy", "FilePath", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	144850	2026-09-02 15:50:17.729048+05:30	Admin User	IMP Templates/20260902_102017_725_Pan_Card.jpeg	2026-09-02 15:50:17.729382+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	112021	2026-09-02 16:45:59.470845+05:30	Admin User	Tech. SOPs/20260902_111559_469_Resume__3___1.pdf	2026-09-02 16:45:59.471482+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	16490	2026-09-02 17:32:50.298683+05:30	Admin User	PMS. SOPs/20260902_120250_297_Issues.xlsx	2026-09-02 17:32:50.299125+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	14866	2026-09-02 17:33:52.717045+05:30	Admin User	IMP Templates/20260902_120352_716_Abstract_5716___5720.docx	2026-09-02 17:33:52.717377+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
71b01b98-a936-4f80-a406-ccf5f0f060b0	airQualityAbstactBoth.pdf	Tech	69207	2026-09-03 12:35:00.559386+05:30	Admin User	Tech. SOPs/20260903_070500_558_airQualityAbstactBoth.pdf	2026-09-03 12:35:00.559812+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: repository_activity_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repository_activity_logs ("Id", "Action", "DocumentId", "FileName", "Category", "PerformedBy", "Details", "CreatedAtUtc", "DeletedAtUtc", "CreatedBy", "UpdatedBy", "UpdatedAtUtc") FROM stdin;
d607a02c-2ed9-488d-a606-d9fd47a439e9	Uploaded	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Dhanshree Pansare	Dhanshree Pansare uploaded financial_report.xlsx	2026-08-25 12:52:47.810202+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
281f8c04-8e17-4c42-b856-e67ce0b8a0af	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 12:53:00.745697+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
78b454bc-6152-47a6-8662-b9d95a57581d	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 12:53:24.952618+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6554b6e5-2bed-4ee7-b6d0-f7e459c5b582	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:01:11.043031+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d26a4058-4793-45f3-be4e-c987d05b9754	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 13:01:15.165521+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a28b7611-1533-4c98-8ee7-e4e8f421c855	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:02:28.926641+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e83225de-cf2a-43c6-89e5-f48d11036851	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:03:14.559786+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
10ef4d3b-c8e1-456b-b6a4-68df639d440b	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:30:41.238362+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
28faca31-dce1-4ea8-8c95-e50366d9cb18	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:31:19.114777+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4b9f4a36-4cd1-4a1f-8d85-df03842e45b8	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:31:24.103884+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
73eaf7b9-b2c1-40d3-b7b8-d447e9d584c7	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:49:06.78787+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
02f475ec-54fc-4fd4-b9f1-eadcbae842a1	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:51:04.064861+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
765e1131-5007-41d5-a0e9-d1388d35805b	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:52:48.385103+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3b51ab42-d7ea-4f29-925a-384eb4c455cc	Downloaded	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co downloaded devops_guidelines.pdf	2026-08-25 14:59:29.989454+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d7604a59-0aac-45de-89ff-a8a73d7fe619	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Admin User viewed devops_guidelines.pdf	2026-08-25 15:02:36.020934+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
12bde8dc-dd37-434f-8a33-de22b69388c6	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 15:02:36.039749+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8a504a55-9279-4cc9-bcf0-6eebb19e849a	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 15:02:39.499136+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ddb08c36-c3a4-4937-ae9a-3fda9262e589	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	admin@acme.co	admin@acme.co viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 15:02:39.513797+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4818b1e2-5560-4cc2-9393-50fecec70c73	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 15:03:49.744384+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c426f146-df7f-414a-b734-2735098bd633	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	admin@acme.co	admin@acme.co viewed Company_Compliance_Policy.pdf	2026-08-25 15:03:49.764944+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
68bb1487-dc9b-47de-b1bd-bfb55172e82f	Deleted	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Admin User	Deleted devops_guidelines.pdf from Tech	2026-08-25 15:10:38.242373+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7ebf97ee-50be-4352-ae21-cf6a8853be1a	Deleted	3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	Admin User	Deleted TK I PMS Tool I Timeline I V01 (1).xlsx from IMP	2026-08-25 15:10:41.563467+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a10068e1-ef46-4818-9a1b-a664722b020d	Deleted	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Deleted financial_report.xlsx from PMS	2026-08-25 15:10:43.668112+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9af86e4f-24a3-489a-83b5-0cc59b9118d5	Deleted	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Deleted ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf from Tech	2026-08-25 15:10:45.54175+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
192d9d10-513f-42cf-8439-47c7bcfc0639	Deleted	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Deleted Company_Compliance_Policy.pdf from IMP	2026-08-25 15:10:47.36039+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
31dd3381-5245-4b77-aa91-56130b0b22af	Deleted	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Admin User	Deleted PMS_Workflow_Spec.docx from PMS	2026-08-25 15:10:49.106488+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
89ea88b5-2245-4e4e-9e91-ad2ae18f6651	Deleted	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Admin User	Deleted Sample_Architecture_Guide.pdf from Tech	2026-08-25 15:10:52.374735+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7a435d55-8a3e-4a7d-923e-ba77b07d79a6	Deleted	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Admin User	Deleted Security Incident Response Plan.pdf from Tech	2026-08-25 15:10:55.367843+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d9c640bb-3779-4e25-bcfc-4aa406a06390	Deleted	aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	Admin User	Deleted Remote Work Policy.pdf from IMP	2026-08-25 15:10:57.192443+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b980db78-d1df-4564-a97a-1ae5b1f9405d	Deleted	706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	Admin User	Deleted Resource Allocation SOP.pdf from PMS	2026-08-25 15:10:58.873408+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ae33ffca-29fd-4e44-badb-5516d1aaac88	Deleted	56991d48-cf5d-4e5f-9664-2fb0c39335cb	Pan Card.jpeg	Tech	Admin User	Deleted Pan Card.jpeg from Tech	2026-09-02 15:49:41.757541+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
053cbb7e-50f7-445a-ac2c-bf05a715f166	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 12:58:24.734245+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
38187c14-5450-48e1-b655-04122a7513b7	Viewed	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-25 13:00:35.456428+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d6277cfd-f5b1-490b-a065-6a45d4c167c7	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 13:00:40.183188+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4dc4a04e-6c73-4b7c-bff7-6dc7331cf6da	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-25 13:00:50.005183+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c44a4ce2-826b-4292-af6b-e21a77a53cab	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:00:58.776721+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a4da1efe-8c23-4c36-9d98-bccc69b1771d	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:02:17.759537+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f576c7d9-d2ab-4467-a20a-1d2e4eb205c7	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 13:02:31.547912+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2f8fa037-364f-4d31-9f64-3cb73ed3fa66	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 13:04:15.428053+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b7180df7-87ce-47f8-b479-9f3a018acd11	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:04:23.975146+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a4704e1e-f1e5-429d-81ae-9ded78a0e033	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 13:04:26.701891+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8f70b43b-6596-4e7b-8585-6f9cdaf6962f	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:04:29.146682+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f78002ab-88dd-482a-bc40-170aaf61c61a	Downloaded	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co downloaded financial_report.xlsx	2026-08-25 13:04:29.220377+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
189f8e28-0ba8-4f05-a0d5-f11b0d3771d4	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 13:04:33.882275+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
01822590-be49-4714-8e58-486ed760f957	Uploaded	3c3d760e-c9b1-4aef-9ddf-d18b7374065f	TK I PMS Tool I Timeline I V01 (1).xlsx	IMP	Admin User	Admin User uploaded TK I PMS Tool I Timeline I V01 (1).xlsx	2026-08-25 13:08:51.554397+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cc4e9fb1-9d59-427a-a4a4-57142dae140f	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:31:17.704572+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2fb79b63-cbeb-4127-9d38-46d296fb6d1f	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:31:20.121812+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8990236f-a815-4c1f-b387-ffa218ccbaf9	Uploaded	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	Dhanshree Pansare	Dhanshree Pansare uploaded devops_guidelines.pdf	2026-08-25 14:58:11.712525+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fcca003f-8bf1-4599-857d-9a545d955846	Viewed	ed476e20-1ec6-4d89-9020-8fc8666884ef	devops_guidelines.pdf	Tech	admin@acme.co	admin@acme.co viewed devops_guidelines.pdf	2026-08-25 14:58:20.040809+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1b80144c-92d2-4b78-8b5a-91f701b911d1	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	admin@acme.co	admin@acme.co downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:58:34.337088+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
081ef346-a707-4de2-8fcd-94876f718c1f	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	admin@acme.co	admin@acme.co downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:58:34.413384+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ad51b550-0084-499d-832e-6bdb27f64e94	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	admin@acme.co	admin@acme.co downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:58:34.889886+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
56025732-9e30-4676-a82f-be1a205d674c	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	admin@acme.co	admin@acme.co viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:58:54.174345+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
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
fc0662da-358a-4eb6-9a77-919358b4cb06	Uploaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Samar Patel	Samar Patel uploaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-24 00:01:21.564645+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
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
acb77d89-1c0a-4a1a-9b79-f8ac8d8f556a	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Arjun Shah	Arjun Shah downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-22 16:11:48.449326+05:30	\N	\N	\N	\N
c3c9370c-6208-4109-9701-5d81e63f86f7	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Priya Sharma	Priya Sharma downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-22 13:11:48.449326+05:30	\N	\N	\N	\N
8ecc0a49-ff0e-47b1-b816-5d6152f9e186	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Divya Rao	Divya Rao downloaded ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-23 18:11:48.449326+05:30	\N	\N	\N	\N
e1976767-5cbf-4a2a-8eb7-12d9bf2171db	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	admin@acme.co	admin@acme.co viewed financial_report.xlsx	2026-08-25 13:01:01.811418+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
79fdeb96-8e1f-4a2a-bf5b-7543a93fc3c5	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:01:23.916218+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8547e788-8e0b-454c-a4fa-f61638428977	Viewed	bd31b2d4-98e1-43ab-aeeb-3a19daa58060	financial_report.xlsx	PMS	Admin User	Admin User viewed financial_report.xlsx	2026-08-25 13:02:25.133528+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
662a1376-a1d8-4009-a417-d6e81270c795	Viewed	b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	Admin User	Admin User viewed Security Incident Response Plan.pdf	2026-08-25 13:11:46.409617+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0ad0ac8e-d84a-4cbe-a569-c132efa6c789	Deleted	f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	Admin User	Deleted Database Backup and Recovery SOP.pdf from Tech	2026-08-25 13:11:58.113952+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
80237877-9098-4deb-82ab-a29626b523b1	Viewed	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	Admin User	Admin User viewed Sample_Architecture_Guide.pdf	2026-08-25 14:48:26.48448+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0cd99fda-7446-4501-9a44-21b9e7c5345f	Viewed	2738fefc-b486-4e4f-9d16-355283602733	????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	Tech	Admin User	Admin User viewed ????????????????????????_????????????????????????????????????_????????????????????????????????????_????_????????????????????????????????????????.pdf	2026-08-25 14:58:54.401342+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
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
f5ec77b3-b06e-4137-a157-b7c7aca420b3	Viewed	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	Admin User	Admin User viewed Issues.xlsx	2026-09-02 17:33:16.27053+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6ec6afda-d74b-42b9-8844-e5f930be7516	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:40:11.132866+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9971ded1-71cb-406c-981e-3758a3cee1ca	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-26 12:41:34.870294+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6ac0cb87-3a8c-421f-88c2-c41a70ee1215	Viewed	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Admin User viewed KEKA - PMS Module guide.pdf	2026-08-26 12:41:39.663556+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
89654775-eb76-4709-a22c-b2ec2ead56ed	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-27 12:47:24.312173+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
36671b39-c539-412a-a5b3-973c8bfc929c	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-28 15:30:12.437064+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a4f7686e-68fa-4f37-8d77-8dfb290377c0	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-31 13:16:33.457198+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
07b4c964-0477-4ddd-adb3-b450f1e9d0e9	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-09-02 13:06:25.119119+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f213fcf2-a2b4-471a-adb5-67642a4fcae2	Deleted	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Deleted PMS_Workflow_Spec.docx from Tech	2026-09-02 15:49:47.938387+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b877d257-0e99-4310-a0bc-9ae7dc005a94	Deleted	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Deleted TK I PMS-Tool I Roles & Processes 1.xlsx from IMP	2026-09-02 15:49:56.310036+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
622ef33b-a7d0-4e46-8b13-7f6068867db4	Uploaded	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	Tech	Admin User	Admin User uploaded Pan Card.jpeg	2026-09-02 15:50:17.729382+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f8c9b464-13f0-4313-a6bf-ca9418ff65ab	Viewed	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	Tech	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 15:50:26.701641+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6c780373-110d-471c-99c3-1c96c5c6d877	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Dhanshree	Dhanshree viewed Resume (3) (1).pdf	2026-09-02 17:00:01.940898+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
40fb39f2-e150-497d-8d54-9a80c5902279	Viewed	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	Dhanshree	Dhanshree viewed Pan Card.jpeg	2026-09-02 17:00:13.871171+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
56a5c401-6d9c-4fd2-8162-a03ff4c94d23	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:33:56.760296+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4aff02fe-5c9d-4404-aea5-1500fda70c6f	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:34:04.133432+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5c1d08f2-624e-47dd-b5cc-46ef7fed5297	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:34:11.054296+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b55adfff-b225-4331-b656-f728dfac444b	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:34:20.653477+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
58d522db-dcad-42d0-b639-f4b2a96ba9cc	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:34:22.133385+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8642cf15-3741-4100-9a05-59737158a696	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:34:23.427277+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
222678fe-411d-4a68-bc48-7a2e6110d2f9	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:34:24.608357+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7712981d-d476-4ca1-a8b0-a7806a465d4b	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:34:27.267801+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e543fefd-5512-43ee-b502-147d06ecbe63	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:34:30.690539+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1f31a7a6-51c9-4ea3-8e20-79de151d7102	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:34:35.013755+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3ff521ed-512f-4ffd-9816-263839bb7c33	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:37:19.475162+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dea1e9bc-efaa-49b2-9dd8-0c581492d7ef	Downloaded	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	admin@acme.co	admin@acme.co downloaded Abstract 5716 & 5720.docx	2026-09-02 17:37:25.612181+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
33065a9f-f1f5-4136-a39b-4cf836f0c7a1	Viewed	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 17:37:31.417232+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ed506731-9412-4ab9-a7d4-c20225d9ad9d	Downloaded	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	admin@acme.co	admin@acme.co downloaded Resume (3) (1).pdf	2026-09-02 17:37:39.347766+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
858b1304-aab9-407c-85ef-41fd7bf525f7	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 18:24:49.984644+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
37d140ee-eadb-4fb6-a411-0574a7529b53	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 18:25:08.037305+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0133895c-d202-4056-9592-badad1ccdb74	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User viewed Resume (3) (1).pdf	2026-09-03 11:51:27.126654+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b5fa0c50-c1f6-4e68-8c09-1457b022ed33	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-27 12:47:34.287533+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ea5a3e49-60d9-41bf-bb55-cda349ef32ea	Viewed	657d6a93-a755-4592-9878-bd42f7a5411f	PMS_Workflow_Spec.docx	Tech	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-28 15:30:14.789907+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4bddbddb-3e9f-4ba9-abd7-a6de82c648d7	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-08-31 13:16:40.161063+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f136d571-4635-4f5f-a96d-1d34ef648d17	Viewed	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Admin User viewed TK_Tender Summary(template)_071223.pptx	2026-09-02 15:07:53.205434+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
906a0a58-f5fe-490a-bc5c-e030311efbe7	Uploaded	56991d48-cf5d-4e5f-9664-2fb0c39335cb	Pan Card.jpeg	Tech	Admin User	Admin User uploaded Pan Card.jpeg	2026-09-02 15:08:14.250499+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
385cbd16-a35b-4def-9a0c-a11153c72aac	Downloaded	56991d48-cf5d-4e5f-9664-2fb0c39335cb	Pan Card.jpeg	Tech	admin@acme.co	admin@acme.co downloaded Pan Card.jpeg	2026-09-02 15:08:26.35222+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
96acd7e5-0e2c-4c38-8d16-359c8c15798a	Deleted	e727d6eb-22ac-4fc7-82e1-d642cc5e98f9	RFP_2026_7206600_Report (2).pptx	Tech	Admin User	Deleted RFP_2026_7206600_Report (2).pptx from Tech	2026-09-02 15:49:50.849508+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
36bec722-5fbb-4c64-b192-9b11b553459d	Deleted	93541430-e7ad-4149-8632-2fad8758943c	KEKA - PMS Module guide.pdf	PMS	Admin User	Deleted KEKA - PMS Module guide.pdf from PMS	2026-09-02 15:49:53.643105+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
94d25da7-3eab-45fc-a072-0df18a4ff0a5	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User viewed Resume (3) (1).pdf	2026-09-02 17:23:25.981303+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
06bdb025-7277-49cf-9ecd-04a50df17e2c	Downloaded	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	admin@acme.co	admin@acme.co downloaded Abstract 5716 & 5720.docx	2026-09-02 17:34:35.079526+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7897667d-b449-4e18-8e54-ae0322ce2917	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 17:37:25.570063+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e7d7ec2e-aef5-405a-bcd3-d17aea130cc3	Downloaded	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	admin@acme.co	admin@acme.co downloaded Pan Card.jpeg	2026-09-02 17:37:31.454371+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
69c5862c-eeae-47f4-908e-32920ccda060	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User viewed Resume (3) (1).pdf	2026-09-02 17:37:39.307653+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f0102759-2318-4b24-acd9-a5aac5840d21	Downloaded	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	admin@acme.co	admin@acme.co downloaded Abstract 5716 & 5720.docx	2026-09-02 18:25:08.081256+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4ba60a5a-aa2b-41e0-94ba-3c9c06c82177	Uploaded	5f35c6be-e98b-42b6-b664-e1940e593328	test_resume.pdf	IMP	Admin User	Admin User uploaded test_resume.pdf	2026-09-03 12:33:58.794497+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3895e15e-3439-45a2-9fc8-aab95d6038ee	Deleted	5f35c6be-e98b-42b6-b664-e1940e593328	test_resume.pdf	IMP	Admin User	Deleted test_resume.pdf from IMP	2026-09-03 12:34:20.309282+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
623e48e5-2057-4782-ac69-769f81390b8d	Viewed	cf2e75c2-0390-495b-9fbb-dfe4f3b3c0c5	TK I PMS-Tool I Roles & Processes 1.xlsx	IMP	Admin User	Admin User viewed TK I PMS-Tool I Roles & Processes 1.xlsx	2026-08-27 12:49:19.848092+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7f1ccb69-7359-4d30-9391-7367eca0910f	Viewed	56991d48-cf5d-4e5f-9664-2fb0c39335cb	Pan Card.jpeg	Tech	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 15:08:18.221946+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
953eff37-03cb-4fc0-80c8-c53a194b3351	Viewed	56991d48-cf5d-4e5f-9664-2fb0c39335cb	Pan Card.jpeg	Tech	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 15:08:26.268906+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
30653852-d662-4a97-8c14-a00cc76e0939	Uploaded	ed2563f7-e191-4d1b-8f14-e485037f5da3	_tmp_imp.txt	IMP	Admin User	Admin User uploaded _tmp_imp.txt	2026-09-02 16:01:31.530595+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d2cb97b0-70b1-4546-8bf8-4455e9e91628	Uploaded	3c4e24af-9c0d-4838-bd51-cc3c7eb4cbe0	_tmp_imp2.txt	IMP	Admin User	Admin User uploaded _tmp_imp2.txt	2026-09-02 16:01:42.089893+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ec9decf4-5343-4910-9471-a185732d6b1b	Deleted	3c4e24af-9c0d-4838-bd51-cc3c7eb4cbe0	_tmp_imp2.txt	IMP	Admin	Deleted _tmp_imp2.txt from IMP	2026-09-02 16:02:09.735989+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
635d4b53-110e-4757-844a-93830b436ab5	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User viewed Resume (3) (1).pdf	2026-09-02 17:28:40.897431+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f6988643-72bf-4987-bcf0-c384f1a6cb1b	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-02 18:12:02.761226+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
811fd632-e5fb-4af0-bb89-85f022ca56dd	Viewed	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User viewed Resume (3) (1).pdf	2026-09-02 18:13:10.659398+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a70707fb-b2a5-46a1-9633-886ea0aaf929	Viewed	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	Admin User	Admin User viewed Issues.xlsx	2026-09-02 18:13:22.325332+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5edb3589-5ea6-495f-8e51-6c12706fe9f3	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-03 11:50:11.102239+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
55aaf34f-553f-43d2-8078-6acf22aaf3bf	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-03 11:50:13.208094+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6cc3ab9c-c1d4-49b5-a837-bbeb3fc15645	Uploaded	71b01b98-a936-4f80-a406-ccf5f0f060b0	airQualityAbstactBoth.pdf	Tech	Admin User	Admin User uploaded airQualityAbstactBoth.pdf	2026-09-03 12:35:00.559812+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ac008be4-d584-4ffd-a24b-70f8811ac323	Uploaded	3c1b7fa3-a188-4402-8501-53bf39dd3080	_tmp_sop.txt	Tech	Admin User	Admin User uploaded _tmp_sop.txt	2026-09-02 15:45:55.649353+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
eb511e0f-80d3-4e06-974e-676b2fa0d9e1	Deleted	3c1b7fa3-a188-4402-8501-53bf39dd3080	_tmp_sop.txt	Tech	Admin	Deleted _tmp_sop.txt from Tech	2026-09-02 15:46:45.197166+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
aeb41e82-8ac1-4a8f-aa7b-115e9557f341	Deleted	7f3a2b6c-a28e-40b1-823f-933cadce5134	TK_Tender Summary(template)_071223.pptx	PMS	Admin User	Deleted TK_Tender Summary(template)_071223.pptx from PMS	2026-09-02 15:49:45.207848+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d5a27bd4-1218-4d11-a7af-c0bf704b6279	Uploaded	a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	Admin User	Admin User uploaded Resume (3) (1).pdf	2026-09-02 16:45:59.471482+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
71dd42a6-0a5a-4a64-b505-da24c2528e03	Viewed	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 17:28:44.525181+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8b4c054f-eeef-42e7-bbb4-33089c02be5e	Uploaded	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	Admin User	Admin User uploaded Issues.xlsx	2026-09-02 17:32:50.299125+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0e6210fb-0e1d-424b-9cbc-69a471c43690	Viewed	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	Admin User	Admin User viewed Issues.xlsx	2026-09-02 17:32:54.303738+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
52f81187-8eb6-4624-82cf-be8bd76deb9c	Downloaded	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	admin@acme.co	admin@acme.co downloaded Issues.xlsx	2026-09-02 17:33:16.349611+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
289d8407-b822-4c36-a5ec-55af6f0acf07	Uploaded	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User uploaded Abstract 5716 & 5720.docx	2026-09-02 17:33:52.717377+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5b975b30-dd66-4580-94b3-6c0cb50f3eb3	Viewed	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	Admin User	Admin User viewed Issues.xlsx	2026-09-02 18:12:30.414666+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
129846c5-f2e0-4c66-b963-8780137d2d7d	Viewed	3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	Admin User	Admin User viewed Pan Card.jpeg	2026-09-02 18:13:06.442219+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d5706148-f057-404c-a1e7-be40c631505b	Downloaded	65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	admin@acme.co	admin@acme.co downloaded Issues.xlsx	2026-09-02 18:13:22.400621+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b5fee407-f14a-47e0-9684-7d57db7e9493	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Admin User	Admin User viewed Abstract 5716 & 5720.docx	2026-09-03 11:51:23.264365+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d1c26620-ad7b-4dce-ab1d-723b2d22b8b3	Viewed	71b01b98-a936-4f80-a406-ccf5f0f060b0	airQualityAbstactBoth.pdf	Tech	Vikrant Malhotra	Vikrant Malhotra viewed airQualityAbstactBoth.pdf	2026-09-27 15:05:24.733567+05:30	\N	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	\N	\N
c512059d-db12-4158-bcc4-e65887bee56b	Viewed	718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	Kavya Desai	Kavya Desai viewed Abstract 5716 & 5720.docx	2026-09-28 00:06:10.230237+05:30	\N	00000000-0000-4000-9000-000000000015	\N	\N
\.


--
-- Data for Name: repository_departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repository_departments ("RepositoryItemId", "DepartmentId") FROM stdin;
71b01b98-a936-4f80-a406-ccf5f0f060b0	13c91c98-00ae-4211-acb8-d06e35953806
71b01b98-a936-4f80-a406-ccf5f0f060b0	310a2f16-15f6-4b82-95f6-ab18b5b429f5
71b01b98-a936-4f80-a406-ccf5f0f060b0	8e4e88f1-e294-4554-80cc-92ed6169caeb
71b01b98-a936-4f80-a406-ccf5f0f060b0	bcbd68c8-c3f3-4396-abb0-0b0e13637958
71b01b98-a936-4f80-a406-ccf5f0f060b0	f7e882f6-2fa8-45e1-9137-2bc4b70f016a
\.


--
-- Data for Name: role_permission_audits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permission_audits ("Id", "RoleId", "RoleName", "ModuleKey", "ModuleLabel", "SubmoduleKey", "SubmoduleLabel", "PermissionKey", "ActionLabel", "ChangeType", "PreviousValue", "NewValue", "ChangedById", "ChangedByName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") FROM stdin;
cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	["dashboard.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "reports.view", "reports.export", "reports.finance.view", "reports.po-tracker", "reports.invoice-tracker", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "clients:read", "invoices:raise", "invoices:payment", "reports:read"]	2026-08-07 13:19:59.669429+05:30	2026-09-24 17:43:06.784762+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Accounts	Invoicing schedule, milestone payments, PO tracking, financial reports.	t	t
f5c742d1-e0cc-4bf8-b860-a673ac407393	R&D Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "repository.view", "repository.upload", "repository.download", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	R&D - Team member	Python/Tool development, sprint tasks, code repository, own timesheets.	t	t
62a927b7-9fd8-461a-b64e-1aa441eeba4d	Chief Executive Officer	["dashboard.view", "action-center.view", "projects.view", "projects:read", "projects.create", "projects:write", "projects.edit", "projects:write", "projects.delete", "projects:write", "projects.close", "projects:close", "projects.approve", "projects.assign", "projects.export", "projects.import", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "issues:raise", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health.manage", "issues:manage", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "projects.pmo.view", "projects.pmo.manage", "projects.prerequisite.view", "projects.prerequisite.manage", "projects.services-deliverables.view", "projects.services-deliverables.manage", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "invoices:raise", "invoices:payment", "projects.assigned-projects.view", "reports.view", "reports:read", "reports.export", "reports.finance.view", "resources.view", "resources:read", "resources.manage", "resources:manage", "resources.directory.view", "resources.kpi.view", "customers.view", "clients:read", "customers.create", "clients:write", "customers.edit", "clients:write", "customers.delete", "clients:write", "customers.approve", "clients:approve", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "timesheets:monitor", "my-team.timesheet-approval.approve", "timesheets:approve", "my-team.timesheet-approval.reject", "timesheets:approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit", "my-team.my-timesheet.edit", "wbs.view", "wbs:read", "wbs.allocate", "wbs:allocate", "approvals.view", "approvals:manage", "approvals.approve", "timesheets:approve", "approvals.reject", "timesheets:approve", "portfolio.view", "settings.view", "settings.roles.view", "settings.roles.manage", "roles:manage", "settings.permissions.view", "settings.permissions.manage", "users:manage", "settings.audit.view", "audit:read"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	CEO	Global executive visibility, business analytics, all approvals.	t	t
a5bfe265-981a-4723-b7bb-6ddc389db7f0	Chief Operating Officer	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.budget.view", "projects.health.view", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "reports.finance.view", "reports.sales", "reports.wbs-tracker", "reports.po-tracker", "reports.invoice-tracker", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.approve", "repository.view", "repository.download", "my-team.dashboard.view", "approvals.view", "approvals.approve", "approvals.reject", "wbs.view", "portfolio.view", "clients:read", "clients:approve", "projects:read", "projects:close", "issues:manage", "reports:read", "resources:read", "approvals:manage"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	COO	Operational oversight across all departments and projects.	t	t
b552183f-2695-41f9-860e-16d5fe94c4aa	IT Administrator	["dashboard.view", "resources.view", "resources.directory.view", "resources.manage", "settings.view", "settings.masters.manage", "repository.view", "repository.upload", "repository.download", "resources:read", "resources:manage"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	IT Admin	IT infrastructure, corporate email domains, device & user setup.	t	t
bb568e26-548b-4ca5-9221-fefb9c9143b3	Human Resources	["resources.view", "resources.directory.view", "resources.manage", "resources.kpi.view", "resources.profile.org", "resources.profile.employment", "resources.profile.skills", "resources.profile.finance", "repository.view", "repository.upload", "repository.download", "settings.view", "settings.masters.manage", "resources:read", "resources:manage"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	HR	Employee directory, onboarding/offboarding, skills, KPI/rating tabs.	t	t
914d8500-03b6-4a43-a250-244effca1cf1	Sales Manager	["dashboard.view", "projects.view", "projects.create", "projects.overview.view", "projects.overview.edit", "projects.health.view", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.create", "customers.edit", "customers.assign", "customers.approve", "reports.view", "reports.export", "reports.sales", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:read", "clients:write", "clients:approve", "projects:write", "wbs:read", "timesheets:submit"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Sales Manager	Customer onboarding, client management, proposal drafting, pipeline.	t	t
7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	Sales Team Member	["dashboard.view", "projects.view", "projects.overview.view", "customers.view", "customers.create", "customers.edit", "reports.view", "reports.sales", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:read", "clients:write", "timesheets:submit"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Sales team member	Proposal drafting, pipeline viewing, sales reports.	t	t
2acf8b94-0756-4db8-bb6f-8372ac04a2d1	Project Management Office	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.budget.view", "projects.pmo.view", "projects.pmo.manage", "projects.health.view", "projects.health.manage", "reports.view", "reports.export", "reports.wbs-tracker", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "approvals.view", "wbs.view", "wbs.allocate", "clients:read", "projects:read", "wbs:read", "wbs:allocate", "timesheets:monitor", "issues:manage", "resources:read", "reports:read", "approvals:manage"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	PMO	Global governance, WBS allocation, timesheet monitoring, approvals.	t	t
66e48815-4d4f-41d0-9c5f-26a7b7ba296c	Chief Technology Officer	["action.alerts", "action.notifications", "dashboard.view", "my_team.dashboard", "projects.stage_tracker", "projects.tab.health", "projects.tab.overview", "projects.tab.tasks", "projects.tab.team", "projects.view", "reports.invoice_tracker", "reports.po_tracker", "reports.sales", "reports.wbs_tracker", "repository.download", "repository.upload", "repository.view", "resources.columns.full", "resources.pool", "resources.profile.employment", "resources.profile.finance", "resources.profile.kpi", "resources.profile.org", "resources.profile.skills", "resources.view"]	2026-09-24 17:43:06.784762+05:30	2026-09-25 20:37:58.127684+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	CTO	Technical architecture, R&D governance, engineering oversight.	t	t
a5023c9e-367f-41e1-ba02-bdb2929edc89	Engagement Manager (EM)	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.edit", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-08-07 13:19:59.669429+05:30	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	EngagementManager	Customer relationship, client project overview, health & escalations.	t	t
f29af015-7833-4f9a-ac57-6fbef5bf91ec	Intern	["projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "repository.view", "repository.download", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Intern	Read-only training access to assigned tasks and document repository.	t	t
c787fe3b-4b33-40ee-8794-c1148202f81a	Testing Head of Department	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Testing HOD	Complete oversight of Testing department, health escalations, approvals.	t	t
efc1df20-ca04-44a6-87b2-7cae1ff50a88	Testing Senior Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Testing Senior Manager	Delivery oversight across testing projects, QA resource management.	t	t
29ad5710-1621-4c24-ac75-dedfc168ba1a	Testing Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Testing-Manager	QA project tasks, test deliverables, defect tracking, QA timesheets.	t	t
a3793f87-7f3c-41a1-a675-236fc1b710ab	Testing Team Leader	["dashboard.view", "projects.view", "projects.overview.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Testing-Team Leader	Test run execution, defect triage, test task assignment, timesheet review.	t	t
92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "projects.health.raise-issue", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Testing-Team Member	Test execution, defect logging, task status updates, own timesheets.	t	t
64c49f37-a38a-46a6-9622-7427f1501658	Consulting Head of Dept	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Consulting-HOD	Complete oversight of Consulting department, GRC engagements.	t	t
4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	Consulting Senior Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Consulting-Senior Manager	Delivery oversight across consulting & audit projects.	t	t
e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	Consulting Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Consulting-Manager	GRC audit projects, client deliverables, audit timesheet approvals.	t	t
701aaa2c-a899-4def-bf5f-e17511874409	Consulting Team Leader	["dashboard.view", "projects.view", "projects.overview.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Consulting-Team Leader	Senior audit execution, audit task assignment, timesheet review.	t	t
768a11f9-ded7-4f6f-ba86-073e279255d9	Consulting Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "projects.health.raise-issue", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Consulting-Team member	Audit checklists, evidence collection, task updates, own timesheets.	t	t
3d068c2f-d0a1-4045-bad9-0f3a43efec4f	SOC Head of Department	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	SOC-HOD	Complete oversight of SOC/Operations, 24/7 monitoring governance.	t	t
b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	SOC Senior Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	SOC-Senior Manager	Operations delivery oversight, client SLA tracking, incident reviews.	t	t
111cc3cd-6d35-43ce-be91-dde90d3d4015	SOC Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	SOC-Manager	Incident management, shift scheduling, operations timesheets.	t	t
aba61e5b-422a-4461-b9da-8dba8f6d3f85	SOC Shift / Team Leader	["dashboard.view", "projects.view", "projects.overview.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	SOC-Team Leader	Shift oversight, alert escalation, task assignments, timesheet review.	t	t
1a62b1f8-1810-464d-a67b-168d7e419827	SOC Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "projects.health.raise-issue", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	SOC-Team Member	SIEM monitoring, alert analysis, shift logs, own timesheets.	t	t
a0000000-0000-0000-0000-000000000001	Admin	["dashboard.view", "action-center.view", "projects.view", "projects:read", "projects.create", "projects:write", "projects.edit", "projects:write", "projects.delete", "projects:write", "projects.close", "projects:close", "projects.approve", "projects.assign", "projects.export", "projects.import", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "issues:raise", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health.manage", "issues:manage", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "projects.pmo.view", "projects.pmo.manage", "projects.prerequisite.view", "projects.prerequisite.manage", "projects.services-deliverables.view", "projects.services-deliverables.manage", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "invoices:raise", "invoices:payment", "projects.assigned-projects.view", "reports.view", "reports:read", "reports.export", "reports.finance.view", "resources.view", "resources:read", "resources.manage", "resources:manage", "resources.directory.view", "resources.kpi.view", "customers.view", "clients:read", "customers.create", "clients:write", "customers.edit", "clients:write", "customers.delete", "clients:write", "customers.approve", "clients:approve", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "timesheets:monitor", "my-team.timesheet-approval.approve", "timesheets:approve", "my-team.timesheet-approval.reject", "timesheets:approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit", "my-team.my-timesheet.edit", "wbs.view", "wbs:read", "wbs.allocate", "wbs:allocate", "approvals.view", "approvals:manage", "approvals.approve", "timesheets:approve", "approvals.reject", "timesheets:approve", "portfolio.view", "settings.view", "settings.roles.view", "settings.roles.manage", "roles:manage", "settings.permissions.view", "settings.permissions.manage", "users:manage", "settings.audit.view", "audit:read"]	2026-09-25 10:11:26.317908+05:30	2026-09-25 20:33:38.839376+05:30	\N	\N	\N	Admin	Super-admin — full access to every module, submodule and action.	t	t
\.


--
-- Data for Name: sub_ventures; Type: TABLE DATA; Schema: public; Owner: -
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
a2e2e7fc-4e12-4bd6-85b4-baffcd70c1f3	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	ABC	2026-08-27 14:56:47.572245+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
4af18ff4-3a01-44e4-b050-9e209643182b	89714d99-8107-4cd0-8095-6da7823cb767	sub cust 1	2026-09-02 12:39:23.899459+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	NA	\N	\N
829211dc-774e-4389-a6c8-b29372b3dde7	08f36c9b-9833-4008-9a58-9b69b5c491e3	SV1	2026-09-02 13:24:30.517916+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
3a681001-620a-4190-bd6c-1ee7131f2c3f	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	ABCDEFG	2026-09-02 15:54:57.074997+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	dfksfklsfkslmf	\N	\N
6cec1e8f-a65e-4c11-8fc3-265376ffe0cc	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	XXXXXXXXX	2026-09-02 17:17:36.563695+05:30	2026-09-02 17:17:36.954412+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	gkhkjhjk	Issues.xlsx	KYC/20260902_114736_876_AutoDrive_Systems_XXXXXXXXX_Issues.xlsx
be9fd5f1-6786-4caa-bf68-e9ee4ab4c5a2	d35873d4-c12c-40c3-a66e-78d9f296ef2b	Testing-sub	2026-09-08 19:25:06.603779+05:30	2026-09-08 19:25:06.914341+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Hello this is the note about the sub-venture	IN-2026-27-C004-P003.xlsx	KYC/20260908_135506_891_Testing_Testing-sub_IN-2026-27-C004-P003.xlsx
6fbfe113-eb06-42ca-b34e-e3c75139678b	d35873d4-c12c-40c3-a66e-78d9f296ef2b	Testing-sub2	2026-09-09 12:32:12.586676+05:30	2026-09-09 12:32:13.087415+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	This is the note of subventure	Sahil Sanjay Lad - Interns Offer Letter.pdf	KYC/20260909_070213_046_Testing_Testing-sub2_Sahil_Sanjay_Lad_-_Interns_Offer_Letter.pdf
\.


--
-- Data for Name: team_day_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.team_day_entries ("Id", "EmployeeId", "WorkDate", "Attendance", "Shift", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: team_member_holidays; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.team_member_holidays ("Id", "EmployeeId", "HolidayDate", "Name", "Comment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: team_member_schedules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.team_member_schedules ("Id", "EmployeeId", "WorkingDays", "Notes", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: timesheet_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.timesheet_entries ("Id", "TimesheetWeekId", "ProjectKey", "TaskKey", "ProjectName", "TaskName", "ReviewDecision", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: timesheet_entry_days; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.timesheet_entry_days ("Id", "TimesheetEntryId", "DayIndex", "Hours", "Comment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: timesheets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.timesheets ("Id", "EmployeeId", "WeekStart", "Status", "TotalHours", "SubmittedAtUtc", "ReviewedByEmployeeId", "ReviewedAtUtc", "ReviewComment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users ("Id", "Email", "PasswordHash", "Name", "EmployeeId", "Department", "SubDepartment", "Avatar", "Designation", "IsActive", "MustChangePassword", "RoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "FailedLoginAttempts", "LastLoginAtUtc", "LockedUntilUtc", "PasswordChangedAtUtc", "AuthProvider", "MicrosoftOid") FROM stdin;
1a077a8c-4029-8ded-d563-19e9b4bdf301	aarav@acme.co	$2a$12$6QsyW1vh07HMg4TcNOWdBuOMUz8aHGLgdYC2D4PHxzMoAMQ/2hpUi	Aarav Mehta	TK-0028	Services - Consulting	\N	AM	Principal Manager - I	t	f	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-25 21:29:08.049777+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000025	manish.tiwari@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Manish Tiwari	TK-0025	Services - Operations	\N	\N	SOC Consultant - I	t	f	1a62b1f8-1810-464d-a67b-168d7e419827	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000052	tanvi.deshmukh@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Tanvi Deshmukh	TKI-0003	Services - Testing	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000053	ayush.saxena@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Ayush Saxena	TKI-0004	Services - Operations	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
2bca17e7-5b71-8ac3-6c86-440cb3b75bab	vikrant@acme.co	$2a$12$/Cn5kSRtq1qzexqzHa3LAuvyFmNwtrTDcfP.RDeymFWf4kTJOFSiG	Vikrant Malhotra	TK-0001	Core	\N	VM	Director and Chief Executive Officer	t	f	62a927b7-9fd8-461a-b64e-1aa441eeba4d	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-27 15:10:09.455945+05:30	\N	2026-08-10 12:29:52.170405+05:30	Local	\N
00000000-0000-4000-9000-000000000054	simran.kaur@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Simran Kaur	TKI-0005	Services - Operations	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000055	naveen.choudhary@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Naveen Choudhary	TKI-0006	Services - Consulting	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000056	bhavna.patel@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Bhavna Patel	TKI-0007	Services - Consulting	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000057	harsh.wardhan@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Harsh Wardhan	TKI-0008	R&D (Research & Development)	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000058	akash.jain@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Akash Jain	TKI-0009	Functional - Sales	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	anita@acme.co	$2a$12$5UzWFUzfZw4hQ5yUvp9rD.jxI38lSX9ceqPTIWlLssfqO4Te.UFSe	Anita Desai	TK-0027	Services - Consulting	\N	AD	Senior Vice President - Principal Consultant	t	f	64c49f37-a38a-46a6-9622-7427f1501658	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-25 21:10:20.602156+05:30	\N	\N	Local	\N
40517b71-5e62-182e-73b5-d4070e20a3c2	dhanshree@acme.co	$2a$12$T7Z5VJjO7c727llbZfwJTeNGxB96t1vKjsClwsJ4Ley6U7HUZw4yK	Dhanshree Pansare	TK-0002	Core	\N	DS	Director and Chief Operating Officer	t	f	a5bfe265-981a-4723-b7bb-6ddc389db7f0	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-27 15:10:14.162122+05:30	\N	2026-08-10 12:32:04.244561+05:30	Local	\N
49c4e7da-23ec-aab1-9fdf-61dd23764d10	nikhil@acme.co	$2a$12$sO2I8dtlv0QCPl2iU7jeT.KW9FUKYAQvdHodtabLNzqQzrMU6R2lG	Nikhil Rao	TK-0020	Services - Operations	\N	NR	SOC Lead - II	t	f	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000008	nikhil.khanna@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Nikhil Khanna	TK-0008	Functional - Sales	\N	\N	Sales Associate	t	f	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000010	rohit.verma@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Rohit Verma	TK-0010	Functional - Sales	\N	\N	Associate Customer Success Representative - I	t	f	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000019	sneha.iyer@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Sneha Iyer	TK-0019	Services - Operations	\N	\N	SOC Lead - I	t	f	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-09-24 16:40:05.618689+05:30	2026-09-24 16:41:30.66576+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-24 16:41:30.663775+05:30	\N	\N	Local	\N
65e2ffa3-6073-780a-b849-4d9604c7251c	priya@acme.co	$2a$12$cQKob2cAcppf2zVPejkyNe5TaAyI52av6Ig48EkeyoM8CEM1dLbge	Priya Verma	TK-0030	Services - Consulting	\N	PV	Senior GRC Auditor - I	t	f	701aaa2c-a899-4def-bf5f-e17511874409	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-28 10:42:48.294039+05:30	\N	\N	Local	\N
730809c0-fc01-a664-03ca-28e0e32d0393	sales@acme.co	$2a$12$UXWFE4DTo82OumVj52GkpO5nk.dlGY2xJSs6wn6R9RATjmtOWo/3S	Sales User	TK-0007	Functional - Sales	\N	SU	Sales Manager	t	f	914d8500-03b6-4a43-a250-244effca1cf1	2026-08-10 17:53:35.786937+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-27 20:49:36.045712+05:30	\N	\N	Local	\N
9f6f34df-dc47-f198-f3f6-e577aab1cbca	dev@acme.co	$2a$12$2L6hrndbKrnO53iN5fWxhOhN5tQVKrNdr5n86SgPuFxrl.s6oZGpi	Dev Patel	TK-0048	Services - Testing	\N	DP	Red Team Practitioner - II	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-08-11 11:50:37.412783+05:30	\N	2026-08-10 12:27:47.765224+05:30	Local	\N
a0000000-0000-0000-0000-000000000032	itadmin@acme.co	$2a$12$gsZGFJHz.B4Yt9PMQEen3OBAVvPZAMm3t8xvEpZ0ec19sQkJUjLwi	IT Admin User	TK-0004-IT	\N	\N	IT	\N	t	f	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-09-25 10:11:26.328885+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-27 15:18:48.643491+05:30	\N	\N	Local	\N
a37e30de-15f3-bf1e-fa9f-4a98da9033ab	vikram@acme.co	$2a$12$bZtpXA2c8LFuzz2AOV5zpOkTjqEXETWQvW/aSeLhXWUVPkWOs3t2u	Vikram Shah	TK-0018	Services - Operations	\N	VS	SOC Manager	t	f	111cc3cd-6d35-43ce-be91-dde90d3d4015	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-28 11:32:40.138184+05:30	\N	\N	Local	\N
a3a20ac4-43a2-de64-52d3-bfafce7c7053	sana@acme.co	$2a$12$NJSEEr.rzPNgoZjo/Pr9iey1hfGL/WOXt.792KEmyyKZsNtMHbB8a	Sana Iyer	TK-0029	Services - Consulting	\N	SI	Associate Manager - III	t	f	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-28 11:31:59.969603+05:30	\N	\N	Local	\N
b1d3f51c-b209-d352-4b52-3f4008801ab3	kavya@acme.co	$2a$12$uk/QhyAlJVg.i.DRe272keJLJWCqkI1ux4mZVC7jrYgOscYe6.65y	Kavya Nair	TK-0049	Services - Testing	\N	KN	Senior Pentester - I	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-08-11 17:21:44.284921+05:30	\N	\N	Local	\N
b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	rahul@acme.co	$2a$12$x2M2/aJmqsqQWC2d0Jlj0u4my/fbdAeTbGd3BOl2vxqN3/EAHKH02	Rahul Gupta	TK-0012	Functional - Project Management	\N	RG	Senior PMO - I	t	f	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-27 20:52:34.020182+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000039	alok.kumar@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Alok Kumar	TK-0039	Services - Testing	\N	\N	Associate Manager - III	t	f	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000022	karthik.bose@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Karthik Bose	TK-0022	Services - Operations	\N	\N	SOC Analyst - I	t	f	1a62b1f8-1810-464d-a67b-168d7e419827	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000023	ankit.verma@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Ankit Verma	TK-0023	Services - Operations	\N	\N	SOC Analyst - II	t	f	1a62b1f8-1810-464d-a67b-168d7e419827	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000024	aditya.reddy@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Aditya Reddy	TK-0024	Services - Operations	\N	\N	SIEM Admin - II	t	f	1a62b1f8-1810-464d-a67b-168d7e419827	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
dc139a9d-b996-7354-6c27-72659ea2fd59	accounts@acme.co	$2a$12$hXz9OmJfpM2wj7vlUM2Z5uIOKZ90Z6gC4rUKCScmAYzPcQ/a3y4Le	Accounts User	TK-0005	Functional - Accounts	\N	AC	Senior Accountant - I	t	f	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-08-10 17:53:35.786937+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-27 19:09:39.760955+05:30	\N	\N	Local	\N
e7554ba2-e546-93ce-1e88-a073badd78a2	riya@acme.co	$2a$12$l35y54biHGI4CYOod05Ub.4MPdRL6plxYeGwVluTGBTSpFL4cWlme	Riya Kapoor	TK-0013	Functional - Project Management	\N	RK	Engagement Manager	t	f	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-27 23:53:02.838237+05:30	\N	2026-08-07 13:27:03.565302+05:30	Local	\N
f2f23eb1-efb6-f0a7-c57e-0ead09121a21	arjun@acme.co	$2a$12$FFc4eQN/UgyRh7Oq7/5XCeHWtw1ZcIAGXNeSsyzyAiWsadgck5qVu	Arjun Singh	TK-0046	Services - Testing	\N	AS	PenTester - II	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-28 00:14:03.723134+05:30	\N	\N	Local	\N
a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	admin@acme.co	$2a$12$.S/YN23JAJRdBU6J66TP7e//mvDrhYbTSA5yLGh6jILkVjFjFLftu	Admin User	TK-0004	Functional - IT Administration	\N	AU	IT Admin	t	f	a0000000-0000-0000-0000-000000000001	2026-08-10 17:53:35.786937+05:30	2026-10-02 11:14:01.137634+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-10-02 11:14:00.455742+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000017	deepak.sawant@acme.co	$2a$12$gGljqynOujycapqnVY7fIOf.Phi36.6NDre.pmLCZ5Phqh1X4vwqq	Deepak Sawant	TK-0017	Services - Operations	\N	\N	SOC Senior Manager	t	f	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-25 21:29:21.990914+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000036	varun.saxena@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Varun Saxena	TK-0036	Services - Consulting	\N	\N	GRC Auditor - I	t	f	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000003	kunal.deshmukh@acme.co	$2a$12$mNJ9xnRS4epg1kRwteEJy.7tsoA/EaK1rghywEq5SAaqU.dTLxHNy	Kunal Deshmukh	TK-0003	Core	\N	\N	Director and Chief Technology Officer	t	f	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:33:43.854319+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-29 12:33:43.677854+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000040	divya.rao@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Divya Rao	TK-0040	Services - Testing	\N	\N	Associate Project Manager	t	f	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000014	pradeep.singh@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Pradeep Singh	TK-0014	Functional - Project Management	\N	\N	Engagement Manager	t	f	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000042	gaurav.joshi@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Gaurav Joshi	TK-0042	Services - Testing	\N	\N	DevSecOps Associate	t	f	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000044	ramesh.nair@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Ramesh Nair	TK-0044	Services - Testing	\N	\N	Associate Manager - II	t	f	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000045	priya.sharma@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Priya Sharma	TK-0045	Services - Testing	\N	\N	PenTester - I	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000051	rohan.joshi@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Rohan Joshi	TKI-0002	Services - Testing	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000011	sneha.reddy@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Sneha Reddy	TK-0011	Functional - Sales	\N	\N	Associate Customer Success Representative - II	t	f	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000031	siddharth.roy@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Siddharth Roy	TK-0031	Services - Consulting	\N	\N	Senior GRC Auditor - II	t	f	701aaa2c-a899-4def-bf5f-e17511874409	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000032	ira.kapoor@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Ira Kapoor	TK-0032	Services - Consulting	\N	\N	GRC Auditor - I	t	f	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000033	meera.nambiar@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Meera Nambiar	TK-0033	Services - Consulting	\N	\N	GRC Auditor - II	t	f	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000034	rajat.singhal@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Rajat Singhal	TK-0034	Services - Consulting	\N	\N	GRC Auditor - III	t	f	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000009	pooja.sharma@acme.co	$2a$12$.uynaj2Cc0BWjQ8T30BJ8uzTKeDUwiEon.XF0A/tAE10ve0IS02Nm	Pooja Sharma	TK-0009	Functional - Sales	\N	\N	Sales Associate	t	f	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-27 20:49:29.785654+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000015	kavya.desai@acme.co	$2a$12$NyUJgNriABWGfSvgHHXujusvsBTEZREBYW9txEIGHQGKjYdfFK8WG	Kavya Desai	TK-0015	R&D (Research & Development)	\N	\N	Python Developer - II	t	f	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-28 00:15:38.045365+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000016	rajesh.kadam@acme.co	$2a$12$avXojWQdALVcyVAbNsF0uugCN0PZKoTcL9QBjd6y27nPJliHlZ5gy	Rajesh Kadam	TK-0016	Services - Operations	\N	\N	SOC HOD	t	f	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-25 21:07:41.57807+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000059	kunal.mehra@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Kunal Mehra	TKI-0010	Functional - IT Administration	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 16:40:05.618689+05:30	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000021	amit.pandey@acme.co	$2a$12$RbLfT25y2xOd3pP1D0qZieddh11UPtJn5TiZ1oqbn3OpEt6c.HjVm	Amit Pandey	TK-0021	Services - Operations	\N	\N	SOC Shift Lead - I	t	f	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-25 21:31:54.633568+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000026	pooja.nair@acme.co	$2a$12$p90DqrIUvYgGBuB16EDt8.KWmVIdA4kYhBk3Y.Q.8s72929URDQMq	Pooja Nair	TK-0026	Services - Operations	\N	\N	SOC Analyst - III	t	f	1a62b1f8-1810-464d-a67b-168d7e419827	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-28 10:37:37.798953+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000035	swati.mishra@acme.co	$2a$12$VCVSD67TLFKUOj.ZbAJacOF9cjamdjG5QMoDo6sBzGQr1mQs8pTki	Swati Mishra	TK-0035	Services - Consulting	\N	\N	GRC Auditor - IV	t	f	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-28 00:16:10.146297+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000037	girish.shenoy@acme.co	$2a$12$BueqLrb99/kZYi5mTnDZiuXSth4Fn4rfnMICEX6sBIbPnnr5QorTq	Girish Shenoy	TK-0037	Services - Testing	\N	\N	Testing HOD	t	f	c787fe3b-4b33-40ee-8794-c1148202f81a	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-28 11:56:43.586865+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000038	suresh.pillai@acme.co	$2a$12$hJZ8AO2Xg.Elp0A9GMZGrOmmNBK91zDP.JlHvTIqrG19coJR1HBaS	Suresh Pillai	TK-0038	Services - Testing	\N	\N	Manager - I	t	f	efc1df20-ca04-44a6-87b2-7cae1ff50a88	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-28 11:33:00.255691+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000041	manoj.bhatt@acme.co	$2a$12$uTeoPDOg601yHeX8zz7mm.gKVIDTnXoY2LK2ZrIPJ0QA8WMwTBWIq	Manoj Bhatt	TK-0041	Services - Testing	\N	\N	DevSecOps Specialist - II	t	f	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-28 11:32:34.815212+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000043	kiran.mathur@acme.co	$2a$12$y7OFqrCLi3ub1ZuFRcLD0.hl13jFxF1HsVRTb3YZ1R/jROW7aihbO	Kiran Mathur	TK-0043	Services - Testing	\N	\N	Associate Manager - I	t	f	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-28 10:37:17.011252+05:30	\N	\N	Local	\N
00000000-0000-4000-9000-000000000050	ananya.verma@acme.co	$2a$12$Yyl.qapc1tf7GqD/nufnxeVuGM06eGMz1U7uZKQ57zDHYqqJufmFy	Ananya Verma	TKI-0001	Services - Testing	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 16:40:05.618689+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-24 19:26:05.516895+05:30	\N	\N	Local	\N
111775f6-5d80-5333-478e-68e2fda584fa	meera@acme.co	$2a$12$Cu8hIO4K4RHmEvnl3hQXTeWZNAoUH4azVxXWkvcgbZd.A.XBP8SEq	Meera Joshi	TK-0047	Services - Testing	\N	MJ	DevSecOps Practitioner - I	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-08-07 13:19:59.669429+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-08-11 16:55:29.999149+05:30	\N	\N	Local	\N
47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	hr@acme.co	$2a$12$YU2m5dpNX6TEtlEUL7gKfenF4ROUaZQKXf8zVibfYvunnLdHVvkym	HR User	TK-0006	Functional - HR	\N	HU	HR Head	t	f	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-08-10 17:53:35.786937+05:30	2026-09-29 12:27:27.496898+05:30	\N	\N	\N	0	2026-09-27 19:23:20.773292+05:30	\N	\N	Local	\N
\.


--
-- Name: employees CK_employees_EmployeeCode_Format; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.employees
    ADD CONSTRAINT "CK_employees_EmployeeCode_Format" CHECK ((("EmployeeCode")::text ~ '^(TK|TKI)-[0-9]{4}$'::text)) NOT VALID;


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: client_assignments PK_client_assignments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_assignments
    ADD CONSTRAINT "PK_client_assignments" PRIMARY KEY ("ClientId", "UserId");


--
-- Name: client_contacts PK_client_contacts; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_contacts
    ADD CONSTRAINT "PK_client_contacts" PRIMARY KEY ("Id");


--
-- Name: clients PK_clients; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "PK_clients" PRIMARY KEY ("Id");


--
-- Name: employees PK_employees; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "PK_employees" PRIMARY KEY ("Id");


--
-- Name: exited_employees PK_exited_employees; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exited_employees
    ADD CONSTRAINT "PK_exited_employees" PRIMARY KEY ("Id");


--
-- Name: mst_cities PK_mst_cities; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_cities
    ADD CONSTRAINT "PK_mst_cities" PRIMARY KEY ("Id");


--
-- Name: mst_contact_designations PK_mst_contact_designations; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_contact_designations
    ADD CONSTRAINT "PK_mst_contact_designations" PRIMARY KEY ("Id");


--
-- Name: mst_contact_types PK_mst_contact_types; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_contact_types
    ADD CONSTRAINT "PK_mst_contact_types" PRIMARY KEY ("Id");


--
-- Name: mst_countries PK_mst_countries; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_countries
    ADD CONSTRAINT "PK_mst_countries" PRIMARY KEY ("Id");


--
-- Name: mst_departments PK_mst_departments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_departments
    ADD CONSTRAINT "PK_mst_departments" PRIMARY KEY ("Id");


--
-- Name: mst_designations PK_mst_designations; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_designations
    ADD CONSTRAINT "PK_mst_designations" PRIMARY KEY ("Id");


--
-- Name: mst_entra_roles PK_mst_entra_roles; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_entra_roles
    ADD CONSTRAINT "PK_mst_entra_roles" PRIMARY KEY ("Id");


--
-- Name: mst_industries PK_mst_industries; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_industries
    ADD CONSTRAINT "PK_mst_industries" PRIMARY KEY ("Id");


--
-- Name: mst_nationalities PK_mst_nationalities; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_nationalities
    ADD CONSTRAINT "PK_mst_nationalities" PRIMARY KEY ("Id");


--
-- Name: mst_roles PK_mst_roles; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_roles
    ADD CONSTRAINT "PK_mst_roles" PRIMARY KEY ("Id");


--
-- Name: mst_salary_bands PK_mst_salary_bands; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_salary_bands
    ADD CONSTRAINT "PK_mst_salary_bands" PRIMARY KEY ("Id");


--
-- Name: mst_service_catalog PK_mst_service_catalog; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_service_catalog
    ADD CONSTRAINT "PK_mst_service_catalog" PRIMARY KEY ("Id");


--
-- Name: mst_service_departments PK_mst_service_departments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_service_departments
    ADD CONSTRAINT "PK_mst_service_departments" PRIMARY KEY ("Id");


--
-- Name: mst_service_groups PK_mst_service_groups; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_service_groups
    ADD CONSTRAINT "PK_mst_service_groups" PRIMARY KEY ("Id");


--
-- Name: mst_service_sub_departments PK_mst_service_sub_departments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_service_sub_departments
    ADD CONSTRAINT "PK_mst_service_sub_departments" PRIMARY KEY ("Id");


--
-- Name: project_documents PK_project_documents; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_documents
    ADD CONSTRAINT "PK_project_documents" PRIMARY KEY ("Id");


--
-- Name: project_drafts PK_project_drafts; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_drafts
    ADD CONSTRAINT "PK_project_drafts" PRIMARY KEY ("Id");


--
-- Name: project_invoices PK_project_invoices; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_invoices
    ADD CONSTRAINT "PK_project_invoices" PRIMARY KEY ("Id");


--
-- Name: project_services PK_project_services; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_services
    ADD CONSTRAINT "PK_project_services" PRIMARY KEY ("Id");


--
-- Name: project_task_assignment_history PK_project_task_assignment_history; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_task_assignment_history
    ADD CONSTRAINT "PK_project_task_assignment_history" PRIMARY KEY ("Id");


--
-- Name: project_task_assignments PK_project_task_assignments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_task_assignments
    ADD CONSTRAINT "PK_project_task_assignments" PRIMARY KEY ("Id");


--
-- Name: project_tasks PK_project_tasks; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_tasks
    ADD CONSTRAINT "PK_project_tasks" PRIMARY KEY ("Id");


--
-- Name: project_team_members PK_project_team_members; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_team_members
    ADD CONSTRAINT "PK_project_team_members" PRIMARY KEY ("Id");


--
-- Name: projects PK_projects; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "PK_projects" PRIMARY KEY ("Id");


--
-- Name: refresh_tokens PK_refresh_tokens; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT "PK_refresh_tokens" PRIMARY KEY ("Id");


--
-- Name: repository_departments PK_repository_departments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_departments
    ADD CONSTRAINT "PK_repository_departments" PRIMARY KEY ("RepositoryItemId", "DepartmentId");


--
-- Name: role_permission_audits PK_role_permission_audits; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission_audits
    ADD CONSTRAINT "PK_role_permission_audits" PRIMARY KEY ("Id");


--
-- Name: roles PK_roles; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT "PK_roles" PRIMARY KEY ("Id");


--
-- Name: sub_ventures PK_sub_ventures; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_ventures
    ADD CONSTRAINT "PK_sub_ventures" PRIMARY KEY ("Id");


--
-- Name: team_day_entries PK_team_day_entries; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_day_entries
    ADD CONSTRAINT "PK_team_day_entries" PRIMARY KEY ("Id");


--
-- Name: team_member_holidays PK_team_member_holidays; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member_holidays
    ADD CONSTRAINT "PK_team_member_holidays" PRIMARY KEY ("Id");


--
-- Name: team_member_schedules PK_team_member_schedules; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member_schedules
    ADD CONSTRAINT "PK_team_member_schedules" PRIMARY KEY ("Id");


--
-- Name: timesheet_entries PK_timesheet_entries; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timesheet_entries
    ADD CONSTRAINT "PK_timesheet_entries" PRIMARY KEY ("Id");


--
-- Name: timesheet_entry_days PK_timesheet_entry_days; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timesheet_entry_days
    ADD CONSTRAINT "PK_timesheet_entry_days" PRIMARY KEY ("Id");


--
-- Name: timesheets PK_timesheets; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timesheets
    ADD CONSTRAINT "PK_timesheets" PRIMARY KEY ("Id");


--
-- Name: users PK_users; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_users" PRIMARY KEY ("Id");


--
-- Name: employee_activity_logs employee_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_activity_logs
    ADD CONSTRAINT employee_activity_logs_pkey PRIMARY KEY ("Id");


--
-- Name: mst_business_units mst_business_units_Code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_business_units
    ADD CONSTRAINT "mst_business_units_Code_key" UNIQUE ("Code");


--
-- Name: mst_business_units mst_business_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_business_units
    ADD CONSTRAINT mst_business_units_pkey PRIMARY KEY ("Id");


--
-- Name: mst_certifications mst_certifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_certifications
    ADD CONSTRAINT mst_certifications_pkey PRIMARY KEY ("Id");


--
-- Name: mst_email_domains mst_email_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_email_domains
    ADD CONSTRAINT mst_email_domains_pkey PRIMARY KEY ("Id");


--
-- Name: mst_employee_statuses mst_employee_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_employee_statuses
    ADD CONSTRAINT mst_employee_statuses_pkey PRIMARY KEY ("Id");


--
-- Name: mst_graduation_degrees mst_graduation_degrees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_graduation_degrees
    ADD CONSTRAINT mst_graduation_degrees_pkey PRIMARY KEY ("Id");


--
-- Name: mst_offices mst_offices_Code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_offices
    ADD CONSTRAINT "mst_offices_Code_key" UNIQUE ("Code");


--
-- Name: mst_offices mst_offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_offices
    ADD CONSTRAINT mst_offices_pkey PRIMARY KEY ("Id");


--
-- Name: mst_post_graduation_degrees mst_post_graduation_degrees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_post_graduation_degrees
    ADD CONSTRAINT mst_post_graduation_degrees_pkey PRIMARY KEY ("Id");


--
-- Name: mst_reporting_managers mst_reporting_managers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_reporting_managers
    ADD CONSTRAINT mst_reporting_managers_pkey PRIMARY KEY ("Id");


--
-- Name: mst_work_locations mst_work_locations_Code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_work_locations
    ADD CONSTRAINT "mst_work_locations_Code_key" UNIQUE ("Code");


--
-- Name: mst_work_locations mst_work_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_work_locations
    ADD CONSTRAINT mst_work_locations_pkey PRIMARY KEY ("Id");


--
-- Name: repository_activity_logs repository_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_activity_logs
    ADD CONSTRAINT repository_activity_logs_pkey PRIMARY KEY ("Id");


--
-- Name: repository repository_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository
    ADD CONSTRAINT repository_pkey PRIMARY KEY ("Id");


--
-- Name: IX_client_assignments_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_client_assignments_UserId" ON public.client_assignments USING btree ("UserId");


--
-- Name: IX_client_contacts_ClientId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_client_contacts_ClientId" ON public.client_contacts USING btree ("ClientId");


--
-- Name: IX_client_contacts_SubVentureId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_client_contacts_SubVentureId" ON public.client_contacts USING btree ("SubVentureId");


--
-- Name: IX_clients_CityId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_clients_CityId" ON public.clients USING btree ("CityId");


--
-- Name: IX_clients_CountryId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_clients_CountryId" ON public.clients USING btree ("CountryId");


--
-- Name: IX_clients_EngagementManagerId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_clients_EngagementManagerId" ON public.clients USING btree ("EngagementManagerId");


--
-- Name: IX_clients_IndustryId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_clients_IndustryId" ON public.clients USING btree ("IndustryId");


--
-- Name: IX_clients_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_clients_Name" ON public.clients USING btree ("Name");


--
-- Name: IX_clients_SalesManagerId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_clients_SalesManagerId" ON public.clients USING btree ("SalesManagerId");


--
-- Name: IX_employee_activity_logs_CreatedAtUtc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employee_activity_logs_CreatedAtUtc" ON public.employee_activity_logs USING btree ("CreatedAtUtc" DESC);


--
-- Name: IX_employee_activity_logs_EmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employee_activity_logs_EmployeeId" ON public.employee_activity_logs USING btree ("EmployeeId");


--
-- Name: IX_employees_DepartmentId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employees_DepartmentId" ON public.employees USING btree ("DepartmentId");


--
-- Name: IX_employees_DesignationId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employees_DesignationId" ON public.employees USING btree ("DesignationId");


--
-- Name: IX_employees_EmployeeCode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_employees_EmployeeCode" ON public.employees USING btree ("EmployeeCode");


--
-- Name: IX_employees_EngagementManagerEmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employees_EngagementManagerEmployeeId" ON public.employees USING btree ("EngagementManagerEmployeeId");


--
-- Name: IX_employees_JobRoleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employees_JobRoleId" ON public.employees USING btree ("JobRoleId");


--
-- Name: IX_employees_NationalityId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employees_NationalityId" ON public.employees USING btree ("NationalityId");


--
-- Name: IX_employees_ProjectManagerId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employees_ProjectManagerId" ON public.employees USING btree ("ProjectManagerId");


--
-- Name: IX_employees_ReportingManagerId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employees_ReportingManagerId" ON public.employees USING btree ("ReportingManagerId");


--
-- Name: IX_employees_SalaryBandId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employees_SalaryBandId" ON public.employees USING btree ("SalaryBandId");


--
-- Name: IX_employees_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employees_UserId" ON public.employees USING btree ("UserId");


--
-- Name: IX_employees_WorkEmail; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_employees_WorkEmail" ON public.employees USING btree ("WorkEmail");


--
-- Name: IX_exited_employees_EmployeeCode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_exited_employees_EmployeeCode" ON public.exited_employees USING btree ("EmployeeCode");


--
-- Name: IX_exited_employees_OriginalEmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_exited_employees_OriginalEmployeeId" ON public.exited_employees USING btree ("OriginalEmployeeId");


--
-- Name: IX_mst_business_units_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_business_units_Code" ON public.mst_business_units USING btree ("Code");


--
-- Name: IX_mst_cities_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_cities_Code" ON public.mst_cities USING btree ("Code");


--
-- Name: IX_mst_cities_CountryId_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_cities_CountryId_Name" ON public.mst_cities USING btree ("CountryId", "Name");


--
-- Name: IX_mst_contact_designations_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_contact_designations_Code" ON public.mst_contact_designations USING btree ("Code");


--
-- Name: IX_mst_contact_designations_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_contact_designations_Name" ON public.mst_contact_designations USING btree ("Name");


--
-- Name: IX_mst_contact_types_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_contact_types_Code" ON public.mst_contact_types USING btree ("Code");


--
-- Name: IX_mst_contact_types_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_contact_types_Name" ON public.mst_contact_types USING btree ("Name");


--
-- Name: IX_mst_countries_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_countries_Code" ON public.mst_countries USING btree ("Code");


--
-- Name: IX_mst_countries_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_countries_Name" ON public.mst_countries USING btree ("Name");


--
-- Name: IX_mst_departments_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_departments_Code" ON public.mst_departments USING btree ("Code");


--
-- Name: IX_mst_departments_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_departments_Name" ON public.mst_departments USING btree ("Name");


--
-- Name: IX_mst_designations_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_designations_Code" ON public.mst_designations USING btree ("Code");


--
-- Name: IX_mst_designations_DefaultRoleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_mst_designations_DefaultRoleId" ON public.mst_designations USING btree ("DefaultRoleId");


--
-- Name: IX_mst_designations_DepartmentId_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_designations_DepartmentId_Name" ON public.mst_designations USING btree ("DepartmentId", "Name");


--
-- Name: IX_mst_email_domains_DomainName; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_email_domains_DomainName" ON public.mst_email_domains USING btree ("DomainName");


--
-- Name: IX_mst_employee_statuses_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_employee_statuses_Code" ON public.mst_employee_statuses USING btree ("Code") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_mst_entra_roles_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_entra_roles_Code" ON public.mst_entra_roles USING btree ("Code");


--
-- Name: IX_mst_entra_roles_EntraRoleValue; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_entra_roles_EntraRoleValue" ON public.mst_entra_roles USING btree ("EntraRoleValue");


--
-- Name: IX_mst_industries_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_industries_Code" ON public.mst_industries USING btree ("Code");


--
-- Name: IX_mst_industries_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_industries_Name" ON public.mst_industries USING btree ("Name");


--
-- Name: IX_mst_nationalities_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_nationalities_Code" ON public.mst_nationalities USING btree ("Code");


--
-- Name: IX_mst_nationalities_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_nationalities_Name" ON public.mst_nationalities USING btree ("Name");


--
-- Name: IX_mst_offices_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_offices_Code" ON public.mst_offices USING btree ("Code");


--
-- Name: IX_mst_offices_WorkLocationId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_mst_offices_WorkLocationId" ON public.mst_offices USING btree ("WorkLocationId");


--
-- Name: IX_mst_reporting_managers_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_reporting_managers_Code" ON public.mst_reporting_managers USING btree ("Code");


--
-- Name: IX_mst_reporting_managers_EmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_mst_reporting_managers_EmployeeId" ON public.mst_reporting_managers USING btree ("EmployeeId");


--
-- Name: IX_mst_roles_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_roles_Code" ON public.mst_roles USING btree ("Code");


--
-- Name: IX_mst_roles_DesignationId_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_roles_DesignationId_Name" ON public.mst_roles USING btree ("DesignationId", "Name");


--
-- Name: IX_mst_salary_bands_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_salary_bands_Code" ON public.mst_salary_bands USING btree ("Code");


--
-- Name: IX_mst_salary_bands_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_salary_bands_Name" ON public.mst_salary_bands USING btree ("Name");


--
-- Name: IX_mst_service_catalog_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_catalog_Code" ON public.mst_service_catalog USING btree ("Code");


--
-- Name: IX_mst_service_catalog_SubDepartmentId_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_catalog_SubDepartmentId_Name" ON public.mst_service_catalog USING btree ("SubDepartmentId", "Name");


--
-- Name: IX_mst_service_departments_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_departments_Code" ON public.mst_service_departments USING btree ("Code");


--
-- Name: IX_mst_service_departments_GroupId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_mst_service_departments_GroupId" ON public.mst_service_departments USING btree ("GroupId");


--
-- Name: IX_mst_service_departments_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_departments_Name" ON public.mst_service_departments USING btree ("Name");


--
-- Name: IX_mst_service_groups_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_groups_Code" ON public.mst_service_groups USING btree ("Code");


--
-- Name: IX_mst_service_groups_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_groups_Name" ON public.mst_service_groups USING btree ("Name");


--
-- Name: IX_mst_service_sub_departments_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_sub_departments_Code" ON public.mst_service_sub_departments USING btree ("Code");


--
-- Name: IX_mst_service_sub_departments_DepartmentId_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_service_sub_departments_DepartmentId_Name" ON public.mst_service_sub_departments USING btree ("DepartmentId", "Name");


--
-- Name: IX_mst_work_locations_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_work_locations_Code" ON public.mst_work_locations USING btree ("Code");


--
-- Name: IX_project_documents_DocumentType; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_documents_DocumentType" ON public.project_documents USING btree ("DocumentType");


--
-- Name: IX_project_documents_ProjectId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_documents_ProjectId" ON public.project_documents USING btree ("ProjectId");


--
-- Name: IX_project_drafts_ClientId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_drafts_ClientId" ON public.project_drafts USING btree ("ClientId");


--
-- Name: IX_project_drafts_Status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_drafts_Status" ON public.project_drafts USING btree ("Status");


--
-- Name: IX_project_drafts_UpdatedAtUtc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_drafts_UpdatedAtUtc" ON public.project_drafts USING btree ("UpdatedAtUtc");


--
-- Name: IX_project_invoices_InvoiceNumber; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_invoices_InvoiceNumber" ON public.project_invoices USING btree ("InvoiceNumber");


--
-- Name: IX_project_invoices_ProjectId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_invoices_ProjectId" ON public.project_invoices USING btree ("ProjectId");


--
-- Name: IX_project_invoices_Status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_invoices_Status" ON public.project_invoices USING btree ("Status");


--
-- Name: IX_project_services_ProjectId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_services_ProjectId" ON public.project_services USING btree ("ProjectId");


--
-- Name: IX_project_services_ServiceCatalogId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_services_ServiceCatalogId" ON public.project_services USING btree ("ServiceCatalogId");


--
-- Name: IX_project_task_assignment_history_EmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_task_assignment_history_EmployeeId" ON public.project_task_assignment_history USING btree ("EmployeeId");


--
-- Name: IX_project_task_assignment_history_TaskId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_task_assignment_history_TaskId" ON public.project_task_assignment_history USING btree ("TaskId");


--
-- Name: IX_project_task_assignment_history_TaskId_OccurredAtUtc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_task_assignment_history_TaskId_OccurredAtUtc" ON public.project_task_assignment_history USING btree ("TaskId", "OccurredAtUtc");


--
-- Name: IX_project_task_assignments_EmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_task_assignments_EmployeeId" ON public.project_task_assignments USING btree ("EmployeeId");


--
-- Name: IX_project_task_assignments_TaskId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_task_assignments_TaskId" ON public.project_task_assignments USING btree ("TaskId");


--
-- Name: IX_project_task_assignments_TaskId_EmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_task_assignments_TaskId_EmployeeId" ON public.project_task_assignments USING btree ("TaskId", "EmployeeId");


--
-- Name: IX_project_tasks_LeafIdentity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_project_tasks_LeafIdentity" ON public.project_tasks USING btree ("ProjectId", "ProjectServiceId", "Period", "Phase", "Title") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_project_tasks_Priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_tasks_Priority" ON public.project_tasks USING btree ("Priority");


--
-- Name: IX_project_tasks_ProjectId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_tasks_ProjectId" ON public.project_tasks USING btree ("ProjectId");


--
-- Name: IX_project_tasks_ProjectServiceId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_tasks_ProjectServiceId" ON public.project_tasks USING btree ("ProjectServiceId");


--
-- Name: IX_project_tasks_Stage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_tasks_Stage" ON public.project_tasks USING btree ("Stage");


--
-- Name: IX_project_team_members_DepartmentId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_team_members_DepartmentId" ON public.project_team_members USING btree ("DepartmentId");


--
-- Name: IX_project_team_members_EmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_team_members_EmployeeId" ON public.project_team_members USING btree ("EmployeeId");


--
-- Name: IX_project_team_members_ProjectId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_project_team_members_ProjectId" ON public.project_team_members USING btree ("ProjectId");


--
-- Name: IX_project_team_members_ProjectId_EmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_project_team_members_ProjectId_EmployeeId" ON public.project_team_members USING btree ("ProjectId", "EmployeeId") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_projects_ClientId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_projects_ClientId" ON public.projects USING btree ("ClientId");


--
-- Name: IX_projects_EngagementManagerId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_projects_EngagementManagerId" ON public.projects USING btree ("EngagementManagerId");


--
-- Name: IX_projects_ProjectCode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_projects_ProjectCode" ON public.projects USING btree ("ProjectCode");


--
-- Name: IX_projects_ProjectManagerId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_projects_ProjectManagerId" ON public.projects USING btree ("ProjectManagerId");


--
-- Name: IX_projects_RenewedFromProjectId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_projects_RenewedFromProjectId" ON public.projects USING btree ("RenewedFromProjectId");


--
-- Name: IX_projects_SalesPersonId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_projects_SalesPersonId" ON public.projects USING btree ("SalesPersonId");


--
-- Name: IX_projects_Status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_projects_Status" ON public.projects USING btree ("Status");


--
-- Name: IX_projects_SubVentureId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_projects_SubVentureId" ON public.projects USING btree ("SubVentureId");


--
-- Name: IX_projects_TeamLeadId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_projects_TeamLeadId" ON public.projects USING btree ("TeamLeadId");


--
-- Name: IX_projects_WbsId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_projects_WbsId" ON public.projects USING btree ("WbsId");


--
-- Name: IX_projects_WbsStatus; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_projects_WbsStatus" ON public.projects USING btree ("WbsStatus");


--
-- Name: IX_refresh_tokens_TokenHash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_refresh_tokens_TokenHash" ON public.refresh_tokens USING btree ("TokenHash");


--
-- Name: IX_refresh_tokens_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_refresh_tokens_UserId" ON public.refresh_tokens USING btree ("UserId");


--
-- Name: IX_repository_Category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_repository_Category" ON public.repository USING btree ("Category");


--
-- Name: IX_repository_DeletedAtUtc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_repository_DeletedAtUtc" ON public.repository USING btree ("DeletedAtUtc");


--
-- Name: IX_repository_activity_logs_CreatedAtUtc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_repository_activity_logs_CreatedAtUtc" ON public.repository_activity_logs USING btree ("CreatedAtUtc");


--
-- Name: IX_repository_activity_logs_DeletedAtUtc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_repository_activity_logs_DeletedAtUtc" ON public.repository_activity_logs USING btree ("DeletedAtUtc");


--
-- Name: IX_repository_departments_DepartmentId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_repository_departments_DepartmentId" ON public.repository_departments USING btree ("DepartmentId");


--
-- Name: IX_role_permission_audits_RoleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_role_permission_audits_RoleId" ON public.role_permission_audits USING btree ("RoleId");


--
-- Name: IX_roles_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_roles_Name" ON public.roles USING btree ("Name");


--
-- Name: IX_sub_ventures_ClientId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_sub_ventures_ClientId" ON public.sub_ventures USING btree ("ClientId");


--
-- Name: IX_team_day_entries_EmployeeId_WorkDate; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_team_day_entries_EmployeeId_WorkDate" ON public.team_day_entries USING btree ("EmployeeId", "WorkDate") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_team_member_holidays_EmployeeId_HolidayDate; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_team_member_holidays_EmployeeId_HolidayDate" ON public.team_member_holidays USING btree ("EmployeeId", "HolidayDate") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_team_member_schedules_EmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_team_member_schedules_EmployeeId" ON public.team_member_schedules USING btree ("EmployeeId") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_timesheet_entries_TimesheetWeekId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_timesheet_entries_TimesheetWeekId" ON public.timesheet_entries USING btree ("TimesheetWeekId");


--
-- Name: IX_timesheet_entry_days_TimesheetEntryId_DayIndex; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_timesheet_entry_days_TimesheetEntryId_DayIndex" ON public.timesheet_entry_days USING btree ("TimesheetEntryId", "DayIndex") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_timesheets_EmployeeId_WeekStart; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_timesheets_EmployeeId_WeekStart" ON public.timesheets USING btree ("EmployeeId", "WeekStart") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_users_Email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_users_Email" ON public.users USING btree ("Email");


--
-- Name: IX_users_EmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_users_EmployeeId" ON public.users USING btree ("EmployeeId");


--
-- Name: IX_users_MicrosoftOid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_users_MicrosoftOid" ON public.users USING btree ("MicrosoftOid") WHERE ("MicrosoftOid" IS NOT NULL);


--
-- Name: IX_users_RoleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_users_RoleId" ON public.users USING btree ("RoleId");


--
-- Name: client_assignments FK_client_assignments_clients_ClientId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_assignments
    ADD CONSTRAINT "FK_client_assignments_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES public.clients("Id") ON DELETE CASCADE;


--
-- Name: client_assignments FK_client_assignments_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_assignments
    ADD CONSTRAINT "FK_client_assignments_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE CASCADE;


--
-- Name: client_contacts FK_client_contacts_clients_ClientId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_contacts
    ADD CONSTRAINT "FK_client_contacts_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES public.clients("Id") ON DELETE CASCADE;


--
-- Name: client_contacts FK_client_contacts_sub_ventures_SubVentureId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_contacts
    ADD CONSTRAINT "FK_client_contacts_sub_ventures_SubVentureId" FOREIGN KEY ("SubVentureId") REFERENCES public.sub_ventures("Id") ON DELETE CASCADE;


--
-- Name: clients FK_clients_employees_EngagementManagerId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "FK_clients_employees_EngagementManagerId" FOREIGN KEY ("EngagementManagerId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: clients FK_clients_employees_SalesManagerId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "FK_clients_employees_SalesManagerId" FOREIGN KEY ("SalesManagerId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: clients FK_clients_mst_cities_CityId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "FK_clients_mst_cities_CityId" FOREIGN KEY ("CityId") REFERENCES public.mst_cities("Id") ON DELETE RESTRICT;


--
-- Name: clients FK_clients_mst_countries_CountryId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "FK_clients_mst_countries_CountryId" FOREIGN KEY ("CountryId") REFERENCES public.mst_countries("Id") ON DELETE RESTRICT;


--
-- Name: clients FK_clients_mst_industries_IndustryId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "FK_clients_mst_industries_IndustryId" FOREIGN KEY ("IndustryId") REFERENCES public.mst_industries("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_employees_EngagementManagerEmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_employees_EngagementManagerEmployeeId" FOREIGN KEY ("EngagementManagerEmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_employees_ProjectManagerId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_employees_ProjectManagerId" FOREIGN KEY ("ProjectManagerId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_employees_ReportingManagerId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_employees_ReportingManagerId" FOREIGN KEY ("ReportingManagerId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: employees FK_employees_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES public.mst_departments("Id") ON DELETE SET NULL;


--
-- Name: employees FK_employees_mst_designations_DesignationId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_designations_DesignationId" FOREIGN KEY ("DesignationId") REFERENCES public.mst_designations("Id") ON DELETE SET NULL;


--
-- Name: employees FK_employees_mst_employee_statuses_EmployeeStatusId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_employee_statuses_EmployeeStatusId" FOREIGN KEY ("EmployeeStatusId") REFERENCES public.mst_employee_statuses("Id") ON DELETE SET NULL;


--
-- Name: employees FK_employees_mst_nationalities_NationalityId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_nationalities_NationalityId" FOREIGN KEY ("NationalityId") REFERENCES public.mst_nationalities("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_mst_roles_JobRoleId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_roles_JobRoleId" FOREIGN KEY ("JobRoleId") REFERENCES public.mst_roles("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_mst_salary_bands_SalaryBandId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_mst_salary_bands_SalaryBandId" FOREIGN KEY ("SalaryBandId") REFERENCES public.mst_salary_bands("Id") ON DELETE RESTRICT;


--
-- Name: employees FK_employees_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_employees_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE SET NULL;


--
-- Name: mst_cities FK_mst_cities_mst_countries_CountryId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_cities
    ADD CONSTRAINT "FK_mst_cities_mst_countries_CountryId" FOREIGN KEY ("CountryId") REFERENCES public.mst_countries("Id") ON DELETE RESTRICT;


--
-- Name: mst_designations FK_mst_designations_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_designations
    ADD CONSTRAINT "FK_mst_designations_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES public.mst_departments("Id") ON DELETE SET NULL;


--
-- Name: mst_reporting_managers FK_mst_reporting_managers_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_reporting_managers
    ADD CONSTRAINT "FK_mst_reporting_managers_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: mst_roles FK_mst_roles_mst_designations_DesignationId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_roles
    ADD CONSTRAINT "FK_mst_roles_mst_designations_DesignationId" FOREIGN KEY ("DesignationId") REFERENCES public.mst_designations("Id") ON DELETE RESTRICT;


--
-- Name: mst_service_catalog FK_mst_service_catalog_mst_service_sub_departments_SubDepartmen; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_service_catalog
    ADD CONSTRAINT "FK_mst_service_catalog_mst_service_sub_departments_SubDepartmen" FOREIGN KEY ("SubDepartmentId") REFERENCES public.mst_service_sub_departments("Id") ON DELETE CASCADE;


--
-- Name: mst_service_departments FK_mst_service_departments_mst_service_groups_GroupId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_service_departments
    ADD CONSTRAINT "FK_mst_service_departments_mst_service_groups_GroupId" FOREIGN KEY ("GroupId") REFERENCES public.mst_service_groups("Id") ON DELETE RESTRICT;


--
-- Name: mst_service_sub_departments FK_mst_service_sub_departments_mst_service_departments_Departme; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_service_sub_departments
    ADD CONSTRAINT "FK_mst_service_sub_departments_mst_service_departments_Departme" FOREIGN KEY ("DepartmentId") REFERENCES public.mst_service_departments("Id") ON DELETE CASCADE;


--
-- Name: project_documents FK_project_documents_projects_ProjectId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_documents
    ADD CONSTRAINT "FK_project_documents_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES public.projects("Id") ON DELETE CASCADE;


--
-- Name: project_invoices FK_project_invoices_projects_ProjectId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_invoices
    ADD CONSTRAINT "FK_project_invoices_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES public.projects("Id") ON DELETE CASCADE;


--
-- Name: project_services FK_project_services_mst_service_catalog_ServiceCatalogId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_services
    ADD CONSTRAINT "FK_project_services_mst_service_catalog_ServiceCatalogId" FOREIGN KEY ("ServiceCatalogId") REFERENCES public.mst_service_catalog("Id") ON DELETE SET NULL;


--
-- Name: project_services FK_project_services_projects_ProjectId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_services
    ADD CONSTRAINT "FK_project_services_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES public.projects("Id") ON DELETE CASCADE;


--
-- Name: project_task_assignment_history FK_project_task_assignment_history_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_task_assignment_history
    ADD CONSTRAINT "FK_project_task_assignment_history_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: project_task_assignment_history FK_project_task_assignment_history_project_tasks_TaskId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_task_assignment_history
    ADD CONSTRAINT "FK_project_task_assignment_history_project_tasks_TaskId" FOREIGN KEY ("TaskId") REFERENCES public.project_tasks("Id") ON DELETE CASCADE;


--
-- Name: project_task_assignments FK_project_task_assignments_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_task_assignments
    ADD CONSTRAINT "FK_project_task_assignments_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: project_task_assignments FK_project_task_assignments_project_tasks_TaskId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_task_assignments
    ADD CONSTRAINT "FK_project_task_assignments_project_tasks_TaskId" FOREIGN KEY ("TaskId") REFERENCES public.project_tasks("Id") ON DELETE CASCADE;


--
-- Name: project_tasks FK_project_tasks_project_services_ProjectServiceId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_tasks
    ADD CONSTRAINT "FK_project_tasks_project_services_ProjectServiceId" FOREIGN KEY ("ProjectServiceId") REFERENCES public.project_services("Id") ON DELETE SET NULL;


--
-- Name: project_tasks FK_project_tasks_projects_ProjectId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_tasks
    ADD CONSTRAINT "FK_project_tasks_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES public.projects("Id") ON DELETE CASCADE;


--
-- Name: project_team_members FK_project_team_members_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_team_members
    ADD CONSTRAINT "FK_project_team_members_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: project_team_members FK_project_team_members_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_team_members
    ADD CONSTRAINT "FK_project_team_members_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES public.mst_departments("Id") ON DELETE SET NULL;


--
-- Name: project_team_members FK_project_team_members_projects_ProjectId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_team_members
    ADD CONSTRAINT "FK_project_team_members_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES public.projects("Id") ON DELETE CASCADE;


--
-- Name: projects FK_projects_clients_ClientId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "FK_projects_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES public.clients("Id") ON DELETE RESTRICT;


--
-- Name: projects FK_projects_employees_EngagementManagerId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "FK_projects_employees_EngagementManagerId" FOREIGN KEY ("EngagementManagerId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: projects FK_projects_employees_ProjectManagerId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "FK_projects_employees_ProjectManagerId" FOREIGN KEY ("ProjectManagerId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: projects FK_projects_employees_SalesPersonId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "FK_projects_employees_SalesPersonId" FOREIGN KEY ("SalesPersonId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: projects FK_projects_employees_TeamLeadId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "FK_projects_employees_TeamLeadId" FOREIGN KEY ("TeamLeadId") REFERENCES public.employees("Id") ON DELETE SET NULL;


--
-- Name: projects FK_projects_projects_RenewedFromProjectId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "FK_projects_projects_RenewedFromProjectId" FOREIGN KEY ("RenewedFromProjectId") REFERENCES public.projects("Id") ON DELETE SET NULL;


--
-- Name: projects FK_projects_sub_ventures_SubVentureId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "FK_projects_sub_ventures_SubVentureId" FOREIGN KEY ("SubVentureId") REFERENCES public.sub_ventures("Id") ON DELETE SET NULL;


--
-- Name: refresh_tokens FK_refresh_tokens_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT "FK_refresh_tokens_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE CASCADE;


--
-- Name: repository_departments FK_repository_departments_mst_departments_DepartmentId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_departments
    ADD CONSTRAINT "FK_repository_departments_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES public.mst_departments("Id") ON DELETE CASCADE;


--
-- Name: repository_departments FK_repository_departments_repository_RepositoryItemId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_departments
    ADD CONSTRAINT "FK_repository_departments_repository_RepositoryItemId" FOREIGN KEY ("RepositoryItemId") REFERENCES public.repository("Id") ON DELETE CASCADE;


--
-- Name: sub_ventures FK_sub_ventures_clients_ClientId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_ventures
    ADD CONSTRAINT "FK_sub_ventures_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES public.clients("Id") ON DELETE CASCADE;


--
-- Name: team_day_entries FK_team_day_entries_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_day_entries
    ADD CONSTRAINT "FK_team_day_entries_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: team_member_holidays FK_team_member_holidays_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member_holidays
    ADD CONSTRAINT "FK_team_member_holidays_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: team_member_schedules FK_team_member_schedules_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member_schedules
    ADD CONSTRAINT "FK_team_member_schedules_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: timesheet_entries FK_timesheet_entries_timesheets_TimesheetWeekId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timesheet_entries
    ADD CONSTRAINT "FK_timesheet_entries_timesheets_TimesheetWeekId" FOREIGN KEY ("TimesheetWeekId") REFERENCES public.timesheets("Id") ON DELETE RESTRICT;


--
-- Name: timesheet_entry_days FK_timesheet_entry_days_timesheet_entries_TimesheetEntryId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timesheet_entry_days
    ADD CONSTRAINT "FK_timesheet_entry_days_timesheet_entries_TimesheetEntryId" FOREIGN KEY ("TimesheetEntryId") REFERENCES public.timesheet_entries("Id") ON DELETE RESTRICT;


--
-- Name: timesheets FK_timesheets_employees_EmployeeId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timesheets
    ADD CONSTRAINT "FK_timesheets_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES public.employees("Id") ON DELETE RESTRICT;


--
-- Name: users FK_users_roles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "FK_users_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public.roles("Id") ON DELETE RESTRICT;


--
-- Name: mst_designations mst_designations_DefaultRoleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_designations
    ADD CONSTRAINT "mst_designations_DefaultRoleId_fkey" FOREIGN KEY ("DefaultRoleId") REFERENCES public.roles("Id") ON DELETE SET NULL;


--
-- Name: mst_offices mst_offices_WorkLocationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_offices
    ADD CONSTRAINT "mst_offices_WorkLocationId_fkey" FOREIGN KEY ("WorkLocationId") REFERENCES public.mst_work_locations("Id") ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict tC98VJTuXWom4ykfH2bVBjJjDrxGKjSh7RVSMSlhsWmhCMBQHw9kOSCdbOjnvmH

