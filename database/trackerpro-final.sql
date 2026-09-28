--
-- PostgreSQL database dump
--

\restrict ghnNnMfKQIyKjbvMMUKzdd2c8jXVdA5UsEUa3jQlKeJeTXBWT1I3iwFgUJdqp2W

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
d5572af5-adde-4fd9-b14b-c857467d1c93	\N	37f0c3b1-16a1-4643-9f5a-f824204543c1	Sahil Lad	sahillad77@gmail.com	7854125698	ciso	Procurement	f	2026-08-19 06:43:26.584779+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
26358579-8daf-4027-81c9-c375e8628aa3	\N	6a40584b-3bde-4c7d-a6e6-3ef920cd43d0	Sahil 	sahillad2092003@gmail.com	8744541212	spoc	Technical	f	2026-08-20 11:00:13.771971+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
77e4a9a2-d473-4007-be16-f9eebfb39df8	90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	\N	Sahil	sahillad2092003@gmail.com	8744541212	spoc	Technical	f	2026-08-20 11:00:13.771971+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
03f15020-3812-47c9-97a4-3ed02203ca0a	\N	65c6925a-8948-4485-9d93-e596e1f4273e	karan pawar	karan.pawar@gmail.com	5374903789	ciso	Technical	f	2026-08-20 13:34:48.407968+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
251274f1-0037-4f3c-8d67-44d1e46981fa	\N	65c6925a-8948-4485-9d93-e596e1f4273e	roshan jadhav	roshan.jadhav@gmail.com	7389247892	spoc	Accounts	f	2026-08-20 13:34:48.407968+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
3865019e-696f-4b90-9347-8cd7ef76d999	\N	d3af0a54-b527-40ca-ac1e-9fb09fd81504	harshada	harshada@tk.com	4373947849	ciso	Technical	f	2026-08-20 13:34:48.407968+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
e6e01a67-c99e-4ed7-87a0-92e5a498d8ab	\N	d3af0a54-b527-40ca-ac1e-9fb09fd81504	muskan	muskan@tk.com	4356789038	spoc	Procurement	f	2026-08-20 13:34:48.407968+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
86650066-2b7a-4e3e-881f-d34464ffbfe4	89714d99-8107-4cd0-8095-6da7823cb767	\N	Harshada Tawde	harshada.tawde@gmail.com	7977953150	spoc	Accounts	f	2026-09-02 07:09:24.021663+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
ab3333bb-387c-4753-b5a7-8482870ac7b4	\N	4af18ff4-3a01-44e4-b050-9e209643182b	Harshada Tawde	harshada.tawde@gmail.com	7977953150	spoc	Accounts	f	2026-09-02 07:09:24.021663+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
07fc7aba-592c-4573-99a5-9b7c0298ab77	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
49207f1d-d605-4315-ba69-e3450e771172	\N	6cec1e8f-a65e-4c11-8fc3-265376ffe0cc	Sahil Lad	sahillad77@gmail.com	7854125698	spoc	Accounts	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
4e6eb452-29f7-4331-b8ec-2b8e84bd24b2	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
6dd8073f-86fb-4519-b19a-bbdea9480c9a	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
95681d26-9084-44f9-9d3b-c4be5e7fe351	\N	a69fe228-de12-44e5-9128-dc3898f67e5c	omkar	omkar@talakunchi.com	9877987899	SPOC	Accounts	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
9f43aded-feb0-48a7-918c-c29e9b567495	\N	a2e2e7fc-4e12-4bd6-85b4-baffcd70c1f3	sdsad	madhurigaikwad2310@gmail.com	7621423213	spoc	Technical	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
c00c4740-2af2-4fed-959f-23e9376d74b0	\N	3a681001-620a-4190-bd6c-1ee7131f2c3f	Sahil Lad	sahillad77@gmail.com	7821093801	spoc	Procurement	f	2026-09-02 11:47:36.680639+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
023e0aa7-e085-414b-bf60-4e718c79be7f	\N	be9fd5f1-6786-4caa-bf68-e9ee4ab4c5a2	Omakar	omkar@gmail.com	7865444994	spoc	Procurement	f	2026-09-09 07:02:12.789474+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
aeef5714-79f5-4088-9835-4979f1f61bdd	\N	6fbfe113-eb06-42ca-b34e-e3c75139678b	Vignesh	vig@gmail.com	778646421	spoc	Technical	f	2026-09-09 07:02:12.789474+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	Australia	+61
cd23c791-a572-4455-a9ab-ada7d93dc9ee	\N	6fbfe113-eb06-42ca-b34e-e3c75139678b	Sanket	sanket@gmail.com	7821548796	cisco	Accounts	f	2026-09-09 07:02:12.789474+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	India	+91
da906f79-0a12-4776-b06d-50ef0b151465	\N	be9fd5f1-6786-4caa-bf68-e9ee4ab4c5a2	Dhanashree	Dha@gmail.com	7854325667	spoc	Technical	f	2026-09-09 07:02:12.789474+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clients ("Id", "Name", "Industry", "Logo", "ContactEmail", "ClientType", "Status", "EngagementManager", "ContactName", "ContactPhone", "ContactDesignation", "ContactType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BusinessType", "City", "Country", "KycDocumentName", "Notes", "EngagementManagerId", "IndustryId", "CityId", "CountryId", "CustomerSince", "SalesManager", "SalesManagerId", "KycDocumentPath", "BillingMedium", "GroupSpocName", "GroupSpocContact") FROM stdin;
ccc4f266-8e68-4b62-9967-04ddacc9113c	SM Test Client	Technology	ST	smtest@example.com	New	Active	Riya Kapoor	Test	\N	\N	\N	2026-09-02 07:48:11.711029+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Mumbai	India	\N	\N	00000000-0000-4000-8000-000000000013	02012f0c-97b2-4aea-a6b4-954ee97d892d	6ffbb80b-985d-4f00-9140-db22f39a625d	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-09-02	John Smith	00000000-0000-4000-8000-000000000007	\N	\N	Test	\N
08f36c9b-9833-4008-9a58-9b69b5c491e3	Onboard SM Fix Test	Technology	OS	smfix@example.com	New	Active	Riya Kapoor	Test	\N	\N	\N	2026-09-02 07:54:30.517916+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Mumbai	India	\N	\N	00000000-0000-4000-8000-000000000013	02012f0c-97b2-4aea-a6b4-954ee97d892d	6ffbb80b-985d-4f00-9140-db22f39a625d	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-09-02	Priya Shah	00000000-0000-4000-8000-000000000007	\N	\N	Test	\N
06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Pharma	Healthcare	HP	it@helix.com	Old	Active	Pradeep Singh	Sanjay Sen	+91 98765 43211	Procurement Head	Procurement	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Sanjay Sen	+91 98765 43211
c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Systems	Automotive	AS	engineering@autodrive.com	Old	Active	Arjun Mehta	Kabir Sen	+91 98765 43219	Engineering SPOC	Technical SPOC	2026-08-07 07:49:59.669429+00	2026-09-02 10:24:57.074997+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	4bf54de4-0e85-4904-a89f-542301b65077	\N	\N	2026-08-07	Manohar Lad	00000000-0000-4000-8000-000000000007	\N	\N	Kabir Sen	+91 98765 43219
d35873d4-c12c-40c3-a66e-78d9f296ef2b	Testing	Energy	T	omkar@gmail.com	New	Active	Pradeep Singh	Sahil	6734543534	\N	Group SPOC	2026-09-08 13:55:06.603779+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Gurugram	India	IN-2026-27-C004-P003.xlsx	\N	00000000-0000-4000-8000-000000000013	c7e82721-829b-4450-8393-022587178471	95913438-968f-4e17-8324-a8e75b2242f4	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-09-08	Nikhil Khanna	00000000-0000-4000-8000-000000000007	\N	Portal Based	Sahil	6734543534
a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync AI	Technology	CA	contact@cloudsync.com	New	Active	Riya Kapoor	Neha Gupta	+91 98765 43215	IT Lead	Technical SPOC	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	02012f0c-97b2-4aea-a6b4-954ee97d892d	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Neha Gupta	+91 98765 43215
f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Retail	Retail	OR	tech@orbit.com	Old	Active	Riya Kapoor	Aditi Rao	+91 98765 43212	CFO	Accounts	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	935db8d7-e2aa-417e-839e-b51d00ce951e	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Aditi Rao	+91 98765 43212
f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Solutions	Environment	ES	projects@ecogreen.com	Old	Active	Riya Kapoor	Rohan Varma	+91 98765 43218	Legal Head	Legal	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	16ebeb23-b3d8-4fb7-a4f6-789510c28ad3	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Rohan Varma	+91 98765 43218
428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Logistics	Logistics	ZL	pm@zenith.com	New	Active	Rahul Sharma	Vikram Malhotra	+91 98765 43213	Legal Counsel	Legal	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000014	f175fde9-14f8-40e8-b564-47d8a29d84ff	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Vikram Malhotra	+91 98765 43213
9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Bank	Banking	NB	ops@northwind.com	Old	Active	Rahul Sharma	Rahul Sharma	+91 98765 43210	IT Manager	Technical SPOC	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000014	4a80bfdb-a191-4ce1-ab51-2142eb366db7	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Rahul Sharma	+91 98765 43210
89714d99-8107-4cd0-8095-6da7823cb767	cust test	Banking	CT	harshada.tawde@gmail.com	New	Active	riya kapoor	Harshada Tawde	7977953150	spoc	Accounts	2026-09-02 07:09:23.899459+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	Mumbai	India	Details for PMS.xlsx	\N	00000000-0000-4000-8000-000000000013	4a80bfdb-a191-4ce1-ab51-2142eb366db7	6ffbb80b-985d-4f00-9140-db22f39a625d	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-09-02	\N	00000000-0000-4000-8000-000000000007	\N	\N	Harshada Tawde	7977953150
a04ccf3a-81c8-4416-8af7-068717ddb22b	Morphle	Banking	M	roshan.jadhav@gmail.com	New	Active	Pradeep Singh	roshan jadhav	7389247892	spoc	Accounts	2026-08-20 13:31:53.288995+00	2026-08-21 12:28:26.459736+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	Kalyan-Dombivli	India	API Gateway Configuration Guide (1).txt	no comments	00000000-0000-4000-8000-000000000013	4a80bfdb-a191-4ce1-ab51-2142eb366db7	4d396fc0-ae55-4eeb-b2db-79bbb757d3cd	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20	\N	00000000-0000-4000-8000-000000000007	\N	\N	roshan jadhav	7389247892
a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Plus	Healthcare	MP	tech@medicareplus.com	New	Active	Pradeep Singh	Priyanka Joshi	+91 98765 43217	Procurement Mgr	Procurement	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Priyanka Joshi	+91 98765 43217
47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Energy	Energy	LE	digital@lumen.com	Old	Active	Pradeep Singh	Arjun Mehta	+91 98765 43214	Operations Manager	Technical SPOC	2026-08-07 07:49:59.669429+00	2026-08-21 12:28:40.3605+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000013	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Arjun Mehta	+91 98765 43214
90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	TATA	Energy	T	sahillad2092003@gmail.com	New	Active	Pradeep Singh	Sahil	8744541212	spoc	Technical	2026-08-20 11:00:13.739957+00	2026-08-21 09:02:02.864281+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	mumbai	India	exit-summary (1).csv	kldfslkdfsdlf	00000000-0000-4000-8000-000000000013	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-20	\N	00000000-0000-4000-8000-000000000007	\N	\N	Sahil	8744541212
fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Global	Finance	FG	dev@fintechglobal.com	Old	Active	Rahul Sharma	Siddharth Shah	+91 98765 43216	Finance VP	Accounts	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	00000000-0000-4000-8000-000000000014	cd116cba-a939-4cb7-bd0f-233019a005b0	\N	\N	2026-08-07	\N	00000000-0000-4000-8000-000000000007	\N	\N	Siddharth Shah	+91 98765 43216
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
00000000-0000-4000-8000-000000000013	TK-0013	Riya	Kapoor	riya@acme.co	\N	9820001013	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101013	Single	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	fdd34566-051a-487d-a985-540c2db8c37f	EngagementManager	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1013	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Project Management"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1247F	501234561013	L4	100112341013	New Regime	Compliant	e7554ba2-e546-93ce-1e88-a073badd78a2	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	57b9b89d-9123-4bd0-b8fd-a373e0648f43	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891013	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Project Management	Engagement Manager	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000014	TK-0014	Pradeep	Singh	pradeep.singh@acme.co	\N	9820001014	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101014	Single	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	fdd34566-051a-487d-a985-540c2db8c37f	EngagementManager	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1014	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Project Management"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1248F	501234561014	L4	100112341014	New Regime	Compliant	00000000-0000-4000-9000-000000000014	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	57b9b89d-9123-4bd0-b8fd-a373e0648f43	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891014	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Project Management	Engagement Manager	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000015	TK-0015	Kavya	Desai	kavya.desai@acme.co	\N	9820001015	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101015	Single	Indian	898c36e9-1cb7-4c56-9148-a3b6893c0149	3356f353-1566-4df6-9958-fa01d67d13c7	R&D - Team member	00000000-0000-4000-8000-000000000003	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1015	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "R&D (Research & Development)"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1249F	501234561015	L2	100112341015	New Regime	Compliant	00000000-0000-4000-9000-000000000015	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	401a442f-98c4-4b95-9e07-647853bf9122	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891015	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	R&D (Research & Development)	Python Developer - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000003
00000000-0000-4000-8000-000000000016	TK-0016	Rajesh	Kadam	rajesh.kadam@acme.co	\N	9820001016	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101016	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b3c75d81-80a1-4240-8b1e-010000000003	SOC-HOD	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1016	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1250F	501234561016	L5	100112341016	New Regime	Compliant	00000000-0000-4000-9000-000000000016	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	b3c75d81-80a1-4240-8b1e-020000000003	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891016	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC HOD	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000017	TK-0017	Deepak	Sawant	deepak.sawant@acme.co	\N	9820001017	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101017	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b3c75d81-80a1-4240-8b1e-010000000002	SOC-Senior Manager	00000000-0000-4000-8000-000000000016	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1017	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1251F	501234561017	L4	100112341017	New Regime	Compliant	00000000-0000-4000-9000-000000000017	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	b3c75d81-80a1-4240-8b1e-020000000002	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891017	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Senior Manager	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000016
00000000-0000-4000-8000-000000000018	TK-0018	Vikram	Shah	vikram@acme.co	\N	9820001018	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101018	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b3c75d81-80a1-4240-8b1e-010000000001	SOC-Manager	00000000-0000-4000-8000-000000000017	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1018	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1252F	501234561018	L4	100112341018	New Regime	Compliant	a37e30de-15f3-bf1e-fa9f-4a98da9033ab	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	b3c75d81-80a1-4240-8b1e-020000000001	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891018	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Manager	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000020	TK-0020	Nikhil	Rao	nikhil@acme.co	\N	9820001020	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101020	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	SOC-Team Leader	00000000-0000-4000-8000-000000000018	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1020	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1254F	501234561020	L3	100112341020	New Regime	Compliant	49c4e7da-23ec-aab1-9fdf-61dd23764d10	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	31ebb23e-f7d1-4c01-859b-67d24e96e2fb	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891020	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Lead - II	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000001	TK-0001	Vikrant	Malhotra	vikrant@acme.co	\N	9820001001	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101001	Single	Indian	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	778f1120-9633-4933-9160-ddaa46668838	CEO	\N	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1001	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Core"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1235F	501234561001	L5	100112341001	New Regime	Compliant	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	94fc014e-37ce-4eb4-8588-ff56a79be98e	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891001	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Core	Director and Chief Executive Officer	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	\N	\N
00000000-0000-4000-8000-000000000021	TK-0021	Amit	Pandey	amit.pandey@acme.co	\N	9820001021	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101021	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	444df30d-c195-42ad-b9a7-d80cdef69ccd	SOC-Team Leader	00000000-0000-4000-8000-000000000018	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1021	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1255F	501234561021	L3	100112341021	New Regime	Compliant	00000000-0000-4000-9000-000000000021	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	6032fef5-eb05-42bd-9f10-72f12e154243	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891021	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Shift Lead - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000022	TK-0022	Karthik	Bose	karthik.bose@acme.co	\N	9820001022	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101022	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	6d25ff6d-e13d-440f-b775-215547af7acb	SOC-Team Member	00000000-0000-4000-8000-000000000019	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1022	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1256F	501234561022	L2	100112341022	New Regime	Compliant	00000000-0000-4000-9000-000000000022	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	eaa98dba-df5b-4b1d-b2d5-20b159a0a070	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891022	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Analyst - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000023	TK-0023	Ankit	Verma	ankit.verma@acme.co	\N	9820001023	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101023	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	48429bb5-c583-4684-b30a-7ed443b671ca	SOC-Team Member	00000000-0000-4000-8000-000000000019	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1023	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1257F	501234561023	L2	100112341023	New Regime	Compliant	00000000-0000-4000-9000-000000000023	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	9c970783-5b89-4fd0-b3f3-1c1953a853ab	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891023	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Analyst - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000024	TK-0024	Aditya	Reddy	aditya.reddy@acme.co	\N	9820001024	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101024	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	4650d4e0-f73c-4688-ae5f-830a46348ff9	SOC-Team Member	00000000-0000-4000-8000-000000000020	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1024	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1258F	501234561024	L2	100112341024	New Regime	Compliant	00000000-0000-4000-9000-000000000024	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	0997a260-4ca3-4eb2-b87a-4bd6bf235677	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891024	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SIEM Admin - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000025	TK-0025	Manish	Tiwari	manish.tiwari@acme.co	\N	9820001025	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101025	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	SOC-Team Member	00000000-0000-4000-8000-000000000020	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1025	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1259F	501234561025	L2	100112341025	New Regime	Compliant	00000000-0000-4000-9000-000000000025	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	24ccdefb-8dd5-411e-8b2e-af8fb743a3cb	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891025	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Consultant - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000026	TK-0026	Pooja	Nair	pooja.nair@acme.co	\N	9820001026	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101026	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	f20a7445-0b01-4f20-85a5-853101d864ee	SOC-Team Member	00000000-0000-4000-8000-000000000021	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1026	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1260F	501234561026	L2	100112341026	New Regime	Compliant	00000000-0000-4000-9000-000000000026	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	3f413c39-a269-4d44-9f3c-9e7f6e3ecced	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891026	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Analyst - III	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000027	TK-0027	Anita	Desai	anita@acme.co	\N	9820001027	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101027	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	2b1558e3-158a-4a84-ae80-053129861a64	Consulting-HOD	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1027	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1261F	501234561027	L5	100112341027	New Regime	Compliant	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	6b840581-65b6-4e1d-916f-38b6018e07e0	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891027	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	Senior Vice President - Principal Consultant	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000029	TK-0029	Sana	Iyer	sana@acme.co	\N	9820001029	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101029	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	195d6a81-8457-4b60-9382-6a3a0664f0e9	Consulting-Manager	00000000-0000-4000-8000-000000000028	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1029	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1263F	501234561029	L4	100112341029	New Regime	Compliant	a3a20ac4-43a2-de64-52d3-bfafce7c7053	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	52ae8b5b-80b3-4d14-b8c5-0bc40e1f4bee	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891029	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	Associate Manager - III	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000030	TK-0030	Priya	Verma	priya@acme.co	\N	9820001030	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101030	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	Consulting-Team Leader	00000000-0000-4000-8000-000000000029	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1030	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1264F	501234561030	L3	100112341030	New Regime	Compliant	65e2ffa3-6073-780a-b849-4d9604c7251c	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	22215465-c056-4ba4-a867-23ed37658a09	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891030	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	Senior GRC Auditor - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000031	TK-0031	Siddharth	Roy	siddharth.roy@acme.co	\N	9820001031	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101031	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	3e60b693-d3dd-4481-95c4-9f02da21625c	Consulting-Team Leader	00000000-0000-4000-8000-000000000029	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1031	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1265F	501234561031	L3	100112341031	New Regime	Compliant	00000000-0000-4000-9000-000000000031	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	4e574ffd-c3a9-4a15-832a-5dabfb352dc3	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891031	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	Senior GRC Auditor - II	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000032	TK-0032	Ira	Kapoor	ira.kapoor@acme.co	\N	9820001032	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101032	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	1e7faab8-273d-40df-9f9a-485160186c5a	Consulting-Team member	00000000-0000-4000-8000-000000000030	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1032	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1266F	501234561032	L2	100112341032	New Regime	Compliant	00000000-0000-4000-9000-000000000032	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	074ea1a8-d519-4cda-87a4-978cd1eec45a	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891032	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	GRC Auditor - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000033	TK-0033	Meera	Nambiar	meera.nambiar@acme.co	\N	9820001033	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101033	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	Consulting-Team member	00000000-0000-4000-8000-000000000030	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1033	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1267F	501234561033	L2	100112341033	New Regime	Compliant	00000000-0000-4000-9000-000000000033	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	6886e92b-a2c5-4057-9330-47394a2aac65	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891033	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	GRC Auditor - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000034	TK-0034	Rajat	Singhal	rajat.singhal@acme.co	\N	9820001034	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101034	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	Consulting-Team member	00000000-0000-4000-8000-000000000031	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1034	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1268F	501234561034	L2	100112341034	New Regime	Compliant	00000000-0000-4000-9000-000000000034	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	40354601-9ac5-41e0-9ddb-6603e5614a86	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891034	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	GRC Auditor - III	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000035	TK-0035	Swati	Mishra	swati.mishra@acme.co	\N	9820001035	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101035	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	7c2380da-3ee6-46ad-93d6-a79ce3027f29	Consulting-Team member	00000000-0000-4000-8000-000000000031	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1035	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1269F	501234561035	L2	100112341035	New Regime	Compliant	00000000-0000-4000-9000-000000000035	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	3efb18e5-f8d5-4de9-8959-ab5401f64b74	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891035	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	GRC Auditor - IV	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000036	TK-0036	Varun	Saxena	varun.saxena@acme.co	\N	9820001036	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101036	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	1e7faab8-273d-40df-9f9a-485160186c5a	Consulting-Team member	00000000-0000-4000-8000-000000000031	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1036	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1270F	501234561036	L2	100112341036	New Regime	Compliant	00000000-0000-4000-9000-000000000036	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	074ea1a8-d519-4cda-87a4-978cd1eec45a	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891036	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	GRC Auditor - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000037	TK-0037	Girish	Shenoy	girish.shenoy@acme.co	\N	9820001037	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101037	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	b3c75d81-80a1-4240-8b1e-010000000004	Testing HOD	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1037	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1271F	501234561037	L5	100112341037	New Regime	Compliant	00000000-0000-4000-9000-000000000037	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	b3c75d81-80a1-4240-8b1e-020000000004	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891037	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Testing HOD	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000038	TK-0038	Suresh	Pillai	suresh.pillai@acme.co	\N	9820001038	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101038	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	Testing Senior Manager	00000000-0000-4000-8000-000000000037	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1038	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1272F	501234561038	L4	100112341038	New Regime	Compliant	00000000-0000-4000-9000-000000000038	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	a3986a0e-d20f-4f20-a648-adcc724bb622	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891038	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Manager - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000037
00000000-0000-4000-8000-000000000040	TK-0040	Divya	Rao	divya.rao@acme.co	\N	9820001040	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101040	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	Testing-Manager	00000000-0000-4000-8000-000000000038	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1040	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1274F	501234561040	L4	100112341040	New Regime	Compliant	00000000-0000-4000-9000-000000000040	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	caec3c96-23a0-4e88-845c-05f792d0dd0c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891040	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Associate Project Manager	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000040
00000000-0000-4000-8000-000000000041	TK-0041	Manoj	Bhatt	manoj.bhatt@acme.co	\N	9820001041	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101041	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	c1fa4328-a970-48a1-bc08-d50fe36bf44c	Testing-Manager	00000000-0000-4000-8000-000000000038	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1041	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1275F	501234561041	L4	100112341041	New Regime	Compliant	00000000-0000-4000-9000-000000000041	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	a583ec5f-f30a-4b03-9e35-6afc3f1aee8d	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891041	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	DevSecOps Specialist - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000041
00000000-0000-4000-8000-000000000042	TK-0042	Gaurav	Joshi	gaurav.joshi@acme.co	\N	9820001042	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101042	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	c6c6cd04-6df3-4593-b686-e4b9d362c96f	Testing-Team Leader	00000000-0000-4000-8000-000000000039	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1042	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1276F	501234561042	L3	100112341042	New Regime	Compliant	00000000-0000-4000-9000-000000000042	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	111000c1-ff0c-499c-a9cb-34febe2ac32d	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891042	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	DevSecOps Associate	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000039
00000000-0000-4000-8000-000000000043	TK-0043	Kiran	Mathur	kiran.mathur@acme.co	\N	9820001043	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101043	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	e228c999-bf54-48b4-a373-d2bc9db88554	Testing-Team Leader	00000000-0000-4000-8000-000000000040	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1043	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1277F	501234561043	L3	100112341043	New Regime	Compliant	00000000-0000-4000-9000-000000000043	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	da59e567-3ee0-4a98-9b1e-83f8e6c01e2c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891043	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Associate Manager - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000040
00000000-0000-4000-8000-000000000044	TK-0044	Ramesh	Nair	ramesh.nair@acme.co	\N	9820001044	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101044	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	Testing-Team Leader	00000000-0000-4000-8000-000000000041	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1044	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1278F	501234561044	L3	100112341044	New Regime	Compliant	00000000-0000-4000-9000-000000000044	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	20d077b9-894b-4bf3-b491-5df765e645f0	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891044	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Associate Manager - II	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000041
00000000-0000-4000-8000-000000000045	TK-0045	Priya	Sharma	priya.sharma@acme.co	\N	9820001045	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101045	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	Testing-Team Member	00000000-0000-4000-8000-000000000042	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1045	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1279F	501234561045	L2	100112341045	New Regime	Compliant	00000000-0000-4000-9000-000000000045	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	a955782d-de73-4939-94f8-5cbf9a2461c2	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891045	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	PenTester - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000039
00000000-0000-4000-8000-000000000046	TK-0046	Arjun	Singh	arjun@acme.co	\N	9820001046	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101046	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	Testing-Team Member	00000000-0000-4000-8000-000000000042	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1046	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1280F	501234561046	L2	100112341046	New Regime	Compliant	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	2cd464a5-b857-46fc-89ea-5dea92640964	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891046	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	PenTester - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000039
00000000-0000-4000-8000-000000000047	TK-0047	Meera	Joshi	meera@acme.co	\N	9820001047	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101047	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	ae255622-ddcc-45ea-a699-8ec416fe57ab	Testing-Team Member	00000000-0000-4000-8000-000000000043	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1047	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1281F	501234561047	L2	100112341047	New Regime	Compliant	111775f6-5d80-5333-478e-68e2fda584fa	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	4e547334-4964-4dbe-81a4-a316d9394d03	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891047	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	DevSecOps Practitioner - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000040
00000000-0000-4000-8000-000000000048	TK-0048	Dev	Patel	dev@acme.co	\N	9820001048	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101048	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	Testing-Team Member	00000000-0000-4000-8000-000000000043	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1048	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1282F	501234561048	L2	100112341048	New Regime	Compliant	9f6f34df-dc47-f198-f3f6-e577aab1cbca	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	5a206a6a-dabc-4dfe-b28f-00cc01bc11da	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891048	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Red Team Practitioner - II	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000040
00000000-0000-4000-8000-000000000049	TK-0049	Kavya	Nair	kavya@acme.co	\N	9820001049	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101049	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	Testing-Team Member	00000000-0000-4000-8000-000000000044	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1049	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1283F	501234561049	L2	100112341049	New Regime	Compliant	b1d3f51c-b209-d352-4b52-3f4008801ab3	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	736d1ddd-c56a-4c4f-b266-bc4f6be6ed9c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891049	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Senior Pentester - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000041
00000000-0000-4000-8000-000000000050	TKI-0001	Ananya	Verma	ananya.verma@acme.co	\N	9820001050	\N	\N	2002-05-15	101, Suvidha Square, Andheri	9811101050	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	Intern	00000000-0000-4000-8000-000000000042	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1050	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1284F	501234561050	L1	100112341050	New Regime	Compliant	00000000-0000-4000-9000-000000000050	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	32d7cead-40d2-4d94-89fb-3e48d4160b7c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891050	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Testing	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000039
00000000-0000-4000-8000-000000000051	TKI-0002	Rohan	Joshi	rohan.joshi@acme.co	\N	9820001051	\N	\N	2002-05-15	101, Navare Plaza, Dombivli	9811101051	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	Intern	00000000-0000-4000-8000-000000000043	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1051	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1285F	501234561051	L1	100112341051	New Regime	Compliant	00000000-0000-4000-9000-000000000051	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	32d7cead-40d2-4d94-89fb-3e48d4160b7c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891051	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Testing	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000040
00000000-0000-4000-8000-000000000052	TKI-0003	Tanvi	Deshmukh	tanvi.deshmukh@acme.co	\N	9820001052	\N	\N	2002-05-15	101, Suvidha Square, Andheri	9811101052	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	Intern	00000000-0000-4000-8000-000000000044	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1052	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1286F	501234561052	L1	100112341052	New Regime	Compliant	00000000-0000-4000-9000-000000000052	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	32d7cead-40d2-4d94-89fb-3e48d4160b7c	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891052	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Testing	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000041
00000000-0000-4000-8000-000000000053	TKI-0004	Ayush	Saxena	ayush.saxena@acme.co	\N	9820001053	\N	\N	2002-05-15	101, Navare Plaza, Dombivli	9811101053	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	Intern	00000000-0000-4000-8000-000000000019	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1053	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1287F	501234561053	L1	100112341053	New Regime	Compliant	00000000-0000-4000-9000-000000000053	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	1d19d6af-78b4-45ef-bcb3-db1b3896f153	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891053	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Operations	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000054	TKI-0005	Simran	Kaur	simran.kaur@acme.co	\N	9820001054	\N	\N	2002-05-15	101, Suvidha Square, Andheri	9811101054	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	Intern	00000000-0000-4000-8000-000000000020	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1054	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1288F	501234561054	L1	100112341054	New Regime	Compliant	00000000-0000-4000-9000-000000000054	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	1d19d6af-78b4-45ef-bcb3-db1b3896f153	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891054	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Operations	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000055	TKI-0006	Naveen	Choudhary	naveen.choudhary@acme.co	\N	9820001055	\N	\N	2002-05-15	101, Navare Plaza, Dombivli	9811101055	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	2076a9b1-e432-46a9-99b1-36e732159856	Intern	00000000-0000-4000-8000-000000000030	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1055	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1289F	501234561055	L1	100112341055	New Regime	Compliant	00000000-0000-4000-9000-000000000055	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	6c0bebbb-cc4d-4433-83e9-d65fb5291d75	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891055	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Consulting	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000056	TKI-0007	Bhavna	Patel	bhavna.patel@acme.co	\N	9820001056	\N	\N	2002-05-15	101, Suvidha Square, Andheri	9811101056	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	2076a9b1-e432-46a9-99b1-36e732159856	Intern	00000000-0000-4000-8000-000000000031	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1056	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1290F	501234561056	L1	100112341056	New Regime	Compliant	00000000-0000-4000-9000-000000000056	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	6c0bebbb-cc4d-4433-83e9-d65fb5291d75	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891056	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Services - Consulting	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000029
00000000-0000-4000-8000-000000000057	TKI-0008	Harsh	Wardhan	harsh.wardhan@acme.co	\N	9820001057	\N	\N	2002-05-15	101, Navare Plaza, Dombivli	9811101057	Single	Indian	898c36e9-1cb7-4c56-9148-a3b6893c0149	bb7ccd5f-2f60-49fb-b984-f11fc47add22	Intern	00000000-0000-4000-8000-000000000015	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1057	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "R&D (Research & Development)"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1291F	501234561057	L1	100112341057	New Regime	Compliant	00000000-0000-4000-9000-000000000057	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	859254f8-a1b4-4812-b1d0-aacf111f7235	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891057	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	R&D (Research & Development)	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000003
00000000-0000-4000-8000-000000000058	TKI-0009	Akash	Jain	akash.jain@acme.co	\N	9820001058	\N	\N	2002-05-15	101, Suvidha Square, Andheri	9811101058	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	e2b10def-c91d-45da-94c5-f5530e743aa2	Intern	00000000-0000-4000-8000-000000000007	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1058	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1292F	501234561058	L1	100112341058	New Regime	Compliant	00000000-0000-4000-9000-000000000058	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	0b340900-7bd0-4931-8978-832c678c7cbd	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891058	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Functional - Sales	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000007
00000000-0000-4000-8000-000000000028	TK-0028	Aarav	Mehta	aarav@acme.co	\N	9820001028	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101028	Single	Indian	be8e036d-ad13-4c79-89ec-294e490a6816	dadac355-1ddc-457c-935a-d297da3a883d	Consulting-Senior Manager	00000000-0000-4000-8000-000000000027	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1028	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Consulting"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1262F	501234561028	L4	100112341028	New Regime	Compliant	1a077a8c-4029-8ded-d563-19e9b4bdf301	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	61cc6cff-4f61-4a1d-90f5-9eb9f61c54f3	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891028	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Consulting	Principal Manager - I	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000014	00000000-0000-4000-8000-000000000027
00000000-0000-4000-8000-000000000019	TK-0019	Sneha	Iyer	sneha.iyer@acme.co	\N	9820001019	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101019	Single	Indian	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b5f39dd8-c305-489d-9f7d-9adfd010a134	SOC-Team Leader	00000000-0000-4000-8000-000000000018	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1019	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Operations"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1253F	501234561019	L3	100112341019	New Regime	Compliant	00000000-0000-4000-9000-000000000019	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	8366d816-724b-456b-9d0e-85399c2324b7	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891019	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Operations	SOC Lead - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000018
00000000-0000-4000-8000-000000000039	TK-0039	Alok	Kumar	alok.kumar@acme.co	\N	9820001039	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101039	Single	Indian	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	Testing-Manager	00000000-0000-4000-8000-000000000038	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1039	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Services - Testing"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1273F	501234561039	L4	100112341039	New Regime	Compliant	00000000-0000-4000-9000-000000000039	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	a3d0a1e1-b4a8-4ae5-8577-cd2019268494	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891039	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Services - Testing	Associate Manager - III	Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000039
00000000-0000-4000-8000-000000000003	TK-0003	Kunal	Deshmukh	kunal.deshmukh@acme.co	\N	9820001003	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101003	Single	Indian	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	0525d830-ead9-44a0-871f-91b7845fec26	CTO	00000000-0000-4000-8000-000000000001	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1003	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Core"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1237F	501234561003	L5	100112341003	New Regime	Compliant	00000000-0000-4000-9000-000000000003	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	0028e31d-d2ff-4a71-b5b2-5f0566961d46	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891003	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Core	Director and Chief Technology Officer	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	\N	\N
00000000-0000-4000-8000-000000000002	TK-0002	Dhanshree	Pansare	dhanshree@acme.co	\N	9820001002	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101002	Single	Indian	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	ffed7aa1-e88f-4281-919f-8d49fbabf5a5	COO	00000000-0000-4000-8000-000000000001	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1002	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Core"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1236F	501234561002	L5	100112341002	New Regime	Compliant	40517b71-5e62-182e-73b5-d4070e20a3c2	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	3dd672a7-e6a9-42c8-bdbf-4d1340efc1da	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43	234567891002	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Core	Director and Chief Operating Officer	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	\N	\N
00000000-0000-4000-8000-000000000004	TK-0004	Admin	User	admin@acme.co	\N	9820001004	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101004	Single	Indian	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	da990f6e-3379-4cc4-89b7-0ead29da472b	IT Admin	00000000-0000-4000-8000-000000000003	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1004	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - IT Administration"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1238F	501234561004	L3	100112341004	New Regime	Compliant	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	eda2ca5a-d2b1-45db-94cc-4575f0eda8dc	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	20ffbe9b-96ca-496e-ab2e-50ccf3c91246	234567891004	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - IT Administration	IT Admin	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000003
00000000-0000-4000-8000-000000000005	TK-0005	Accounts	User	accounts@acme.co	\N	9820001005	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101005	Single	Indian	bcbd68c8-c3f3-4396-abb0-0b0e13637958	4ef1cb5b-9688-4ce2-95b3-6a0863200166	Accounts	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1005	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Accounts"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1239F	501234561005	L4	100112341005	New Regime	Compliant	dc139a9d-b996-7354-6c27-72659ea2fd59	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	f37fa8d5-1c48-4038-95d5-cd7dfea12085	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891005	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Accounts	Senior Accountant - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000006	TK-0006	HR	User	hr@acme.co	\N	9820001006	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101006	Single	Indian	310a2f16-15f6-4b82-95f6-ab18b5b429f5	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	HR	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1006	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - HR"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1240F	501234561006	L4	100112341006	New Regime	Compliant	47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	c7d75b92-f6e2-4dd7-a726-ae662ee83c95	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891006	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - HR	HR Head	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000007	TK-0007	Sales	User	sales@acme.co	\N	9820001007	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101007	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	b3c75d81-80a1-4240-8b1e-010000000005	Sales Manager	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1007	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1241F	501234561007	L4	100112341007	New Regime	Compliant	730809c0-fc01-a664-03ca-28e0e32d0393	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	b3c75d81-80a1-4240-8b1e-020000000005	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891007	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Sales	Sales Manager	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000008	TK-0008	Nikhil	Khanna	nikhil.khanna@acme.co	\N	9820001008	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101008	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	e2c675a7-92dc-4477-be75-9a304cbe4def	Sales team member	00000000-0000-4000-8000-000000000007	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1008	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1242F	501234561008	L2	100112341008	New Regime	Compliant	00000000-0000-4000-9000-000000000008	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	d0b9d2a2-d79c-4097-ae63-4bff14436d0a	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891008	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Sales	Sales Associate	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000007
00000000-0000-4000-8000-000000000009	TK-0009	Pooja	Sharma	pooja.sharma@acme.co	\N	9820001009	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101009	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	e2c675a7-92dc-4477-be75-9a304cbe4def	Sales team member	00000000-0000-4000-8000-000000000007	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1009	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1243F	501234561009	L2	100112341009	New Regime	Compliant	00000000-0000-4000-9000-000000000009	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	d0b9d2a2-d79c-4097-ae63-4bff14436d0a	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891009	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Sales	Sales Associate	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000007
00000000-0000-4000-8000-000000000010	TK-0010	Rohit	Verma	rohit.verma@acme.co	\N	9820001010	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101010	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	272973a6-c052-4aef-bf32-9e24f7eb6cc9	Sales team member	00000000-0000-4000-8000-000000000007	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1010	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1244F	501234561010	L2	100112341010	New Regime	Compliant	00000000-0000-4000-9000-000000000010	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	3e28d4a4-7d87-41ed-b921-a39dd937df76	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891010	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Sales	Associate Customer Success Representative - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000007
00000000-0000-4000-8000-000000000011	TK-0011	Sneha	Reddy	sneha.reddy@acme.co	\N	9820001011	\N	\N	1992-06-20	101, Navare Plaza, Dombivli	9811101011	Single	Indian	13c91c98-00ae-4211-acb8-d06e35953806	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	Sales team member	00000000-0000-4000-8000-000000000007	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1011	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Sales"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1245F	501234561011	L2	100112341011	New Regime	Compliant	00000000-0000-4000-9000-000000000011	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	21eac166-3ba7-40c5-a780-bbc7b3e96ddb	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	ebed343e-301f-4984-b292-fa8d1cb1623c	234567891011	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Sales	Associate Customer Success Representative - II	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000007
00000000-0000-4000-8000-000000000012	TK-0012	Rahul	Gupta	rahul@acme.co	\N	9820001012	\N	\N	1992-06-20	101, Suvidha Square, Andheri	9811101012	Single	Indian	8e4e88f1-e294-4554-80cc-92ed6169caeb	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	PMO	00000000-0000-4000-8000-000000000002	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent	\N	2021-04-15	Active	Active	Completed	4.5 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1012	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - Project Management"]	["CEH", "ISO 27001"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1246F	501234561012	L4	100112341012	New Regime	Compliant	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	446498d0-e9e6-4dbb-8fbe-b87bb853a2af	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	234567891012	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Experienced	4.5	4.5	Family	Functional - Project Management	Senior PMO - I	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000002
00000000-0000-4000-8000-000000000059	TKI-0010	Kunal	Mehra	kunal.mehra@acme.co	\N	9820001059	\N	\N	2002-05-15	101, Navare Plaza, Dombivli	9811101059	Single	Indian	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	f8502c44-b289-49e4-8401-3dcad4d5bbe0	Intern	00000000-0000-4000-8000-000000000004	Talakunchi Networks Private Limited	Navare Plaza, Dombivli	\N	Permanent	\N	2026-01-10	Active	Active	Completed	0 years	\N	Full-time	Permanent	No	60 days	TK-ASSET-1059	\N	\N	B.Tech Computer Science	["Communication", "Technical Problem Solving", "Functional - IT Administration"]	["CompTIA Security+"]	["English", "Hindi"]	85.0	85.0	4.0	90.0	95.0	88.0	Ready Now	Key professional contributor.	ABCDE1293F	501234561059	L1	100112341059	New Regime	Compliant	00000000-0000-4000-9000-000000000059	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N	f43fddea-4dd9-4603-a79c-1710224115ae	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	37016f9a-2474-400d-99ae-18157aaad035	234567891059	Emergency Contact	e273e2ed-5fd3-4564-bb87-09a71cd4779a	\N	\N	\N	\N	\N	\N	\N	Fresher	0	0	Family	Functional - IT Administration	Intern	Non-Billable	Mumbai	Long Term	PMS TrackerPro Enterprise	Riya Kapoor	\N	00000000-0000-4000-8000-000000000013	00000000-0000-4000-8000-000000000004
\.


--
-- Data for Name: exited_employees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exited_employees ("Id", "OriginalEmployeeId", "EmployeeCode", "FullName", "DepartmentName", "DesignationName", "WorkEmail", "PersonalEmail", "Phone", "StatusAtExit", "ExitType", "ExitReason", "ResignationDate", "LastWorkingDay", "ReasonForLeaving", "NoticePeriodServed", "ExitChecklistJson", "AssetReturnJson", "FinalSettlementJson", "ExitedAtUtc", "ExitedBy", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "ClearanceCompleted", "ExitRating") FROM stdin;
d88f3e1e-3d11-481f-b074-d6c8250141e5	00000000-0000-4000-8000-000000000011	TK-0011	Harsh Nair	Functional - Project Management	Associate PMO - I	harsh.nair@talakunchi.com	harsh.nair11@gmail.com	9820000011	Active	Resign	Better opportunity	2026-09-10	2026-11-09	Better opportunity	60 days	\N	\N	\N	2026-09-10 05:27:29.201413+00	\N	2026-09-10 05:27:29.24202+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	f	4.5
482f25b2-2e12-4da2-9f10-9a44b487845c	00000000-0000-4000-8000-000000000003	TK-0003	Rohan Mehta	Services - Testing	DevSecOps Practitioner - II	rohan.mehta@talakunchi.com	rohan.mehta3@gmail.com	9820000003	Active	Resign	bo	2026-09-23	2026-11-22	bo	60 days	\N	\N	\N	2026-09-23 05:53:21.083025+00	\N	2026-09-23 05:53:21.199076+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	f	4.5
\.


--
-- Data for Name: mst_business_units; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_business_units ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
1ab2e67e-5e47-4f6d-8035-dd6a5c5f6b85	talakunchi_networks_private_limited	Talakunchi Networks Private Limited	t	1	2026-09-03 12:17:46.134222+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_certifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
\.


--
-- Data for Name: mst_cities; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: mst_contact_designations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_contact_designations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
301bc813-b2a8-487e-8645-6d613260a7e7	cio	CIO	t	3	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
36d0dd25-0888-4933-b7ec-1ffb839a50bd	cfo	CFO	t	4	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
4289316a-ac66-4577-93b2-b27a1f631bd7	ciso	CISO	t	2	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
634aee41-eb57-41e4-b296-af2a255a7e79	accounts_head	Accounts Head	t	5	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
8a02dfd7-d731-4231-8eba-29f36d2254c7	spoc	SPOC	t	1	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_contact_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_contact_types ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
58db2f92-2db9-46a1-ae8a-f04a3c7cf54c	legal	Legal	t	4	2026-09-09 07:39:28.906477+00	\N	\N	\N	\N
670b9a05-6ee2-488e-962c-51cf3cdb86fa	procurement	Procurement	t	2	2026-09-09 07:39:28.906477+00	\N	\N	\N	\N
6ddcfdba-7311-4f61-b285-88e09a772497	accounts	Accounts	t	1	2026-09-09 07:39:28.906477+00	\N	\N	\N	\N
b28647ac-40d2-449e-b90c-b71cbae83f8d	technical	Technical	t	3	2026-09-09 07:39:28.906477+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_countries; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: mst_departments; Type: TABLE DATA; Schema: public; Owner: -
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
\.


--
-- Data for Name: mst_designations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "SubDepartment", "DefaultRoleId") FROM stdin;
b3c75d81-80a1-4240-8b1e-010000000005	functional_sales_manager	Sales Manager	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	\N	914d8500-03b6-4a43-a250-244effca1cf1
fdd34566-051a-487d-a985-540c2db8c37f	functional_project_management_engagement_manager	Engagement Manager	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 11:51:34.862009+00	\N	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89
b3c75d81-80a1-4240-8b1e-010000000001	services_operations_soc_manager	SOC Manager	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	\N	111cc3cd-6d35-43ce-be91-dde90d3d4015
b3c75d81-80a1-4240-8b1e-010000000002	services_operations_soc_sr_manager	SOC Senior Manager	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	\N	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7
b3c75d81-80a1-4240-8b1e-010000000003	services_operations_soc_hod	SOC HOD	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	\N	3d068c2f-d0a1-4045-bad9-0f3a43efec4f
7c2380da-3ee6-46ad-93d6-a79ce3027f29	services_consulting_grc_auditor_iv	GRC Auditor - IV	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.915028+00	\N	\N	\N	\N	\N	768a11f9-ded7-4f6f-ba86-073e279255d9
dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	services_consulting_senior_grc_auditor_i	Senior GRC Auditor - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.916903+00	\N	\N	\N	\N	\N	701aaa2c-a899-4def-bf5f-e17511874409
3e60b693-d3dd-4481-95c4-9f02da21625c	services_consulting_senior_grc_auditor_ii	Senior GRC Auditor - II	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.91882+00	\N	\N	\N	\N	\N	701aaa2c-a899-4def-bf5f-e17511874409
195d6a81-8457-4b60-9382-6a3a0664f0e9	services_consulting_associate_manager_iii	Associate Manager - III	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.920769+00	\N	\N	\N	\N	\N	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a
2b1558e3-158a-4a84-ae80-053129861a64	services_consulting_senior_vice_president_principal_consultant	Senior Vice President - Principal Consultant	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.922717+00	\N	\N	\N	\N	\N	64c49f37-a38a-46a6-9622-7427f1501658
dadac355-1ddc-457c-935a-d297da3a883d	services_consulting_principal_manager_i	Principal Manager - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.903029+00	2026-09-03 07:11:32.975424+00	\N	\N	\N	\N	64c49f37-a38a-46a6-9622-7427f1501658
4f972924-350a-47fb-a6b6-f2b34bb6b621	services_testing_pentester_i	PenTester - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.928383+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
0b6ab354-1fcf-4a00-9be3-e58e99c425ed	services_testing_pentester_ii	PenTester - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.930296+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
163d8c87-8f90-4295-a926-2e912c625a1c	services_testing_pentester_iii	PenTester - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.932399+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
9858c224-f97f-4ff8-908d-f46bd5e2243c	services_testing_pentester_iv	PenTester - IV	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.93473+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
632bf06c-f646-4edd-bf2d-e3cd2e034c7f	services_testing_senior_pentester_i	Senior Pentester - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.936785+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	services_testing_senior_pentester_ii	Senior Pentester - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.93907+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
ae255622-ddcc-45ea-a699-8ec416fe57ab	services_testing_devsecops_practitioner_i	DevSecOps Practitioner - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.969279+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
35a6b1af-dc78-4632-a9f4-eedabdbdcb52	services_testing_devsecops_practitioner_ii	DevSecOps Practitioner - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.97275+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
767a00dd-6f09-4f64-a44e-8fbe901222af	services_testing_devsecops_practitioner_iii	DevSecOps Practitioner - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.976579+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
778f1120-9633-4933-9160-ddaa46668838	core_director_and_chief_executive_officer	Director and Chief Executive Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 10:24:51.776662+00	\N	\N	\N	\N	\N	62a927b7-9fd8-461a-b64e-1aa441eeba4d
ffed7aa1-e88f-4281-919f-8d49fbabf5a5	core_director_and_chief_operating_officer	Director and Chief Operating Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 10:24:51.781954+00	\N	\N	\N	\N	\N	a5bfe265-981a-4723-b7bb-6ddc389db7f0
0525d830-ead9-44a0-871f-91b7845fec26	core_director_and_chief_technology_officer	Director and Chief Technology Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 10:24:51.783926+00	\N	\N	\N	\N	\N	66e48815-4d4f-41d0-9c5f-26a7b7ba296c
da990f6e-3379-4cc4-89b7-0ead29da472b	functional_it_admini_it_admin	IT Admin	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.787896+00	\N	\N	\N	\N	\N	b552183f-2695-41f9-860e-16d5fe94c4aa
c70b9832-841e-4864-9b85-eaba3c0a995f	functional_it_admini_desktop_support_engineer_i	Desktop Support Engineer - I	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.78998+00	\N	\N	\N	\N	\N	b552183f-2695-41f9-860e-16d5fe94c4aa
73bd55bb-5d0e-4381-8ad2-2238377fca93	functional_it_admini_desktop_support_engineer_ii	Desktop Support Engineer - II	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.792134+00	\N	\N	\N	\N	\N	b552183f-2695-41f9-860e-16d5fe94c4aa
155642eb-a633-4460-b658-aca9fde2d817	functional_accounts_accountant_i	Accountant - I	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.797934+00	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
8dc0d8fe-593d-422a-8b27-5b68fbe6d224	functional_accounts_accountant_ii	Accountant - II	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.799807+00	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
6e606c29-2ebf-4ab8-8006-aaedd5680009	functional_accounts_accountant_iii	Accountant - III	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.801711+00	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
4ef1cb5b-9688-4ce2-95b3-6a0863200166	functional_accounts_senior_accountant_i	Senior Accountant - I	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.803595+00	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
96efad7d-8b7f-4d7f-a862-c0a6bec3789f	functional_accounts_senior_accountant_ii	Senior Accountant - II	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.805714+00	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
1f97b442-95c5-4b11-93a0-ea146534ae85	functional_accounts_senior_accountant_iii	Senior Accountant - III	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.807813+00	\N	\N	\N	\N	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	functional_hr_hr_head	HR Head	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.814553+00	\N	\N	\N	\N	\N	bb568e26-548b-4ca5-9221-fefb9c9143b3
7d542941-65b9-499b-81b3-239748d6da52	functional_hr_recruitment_coordinator_i	Recruitment Coordinator - I	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.8165+00	\N	\N	\N	\N	\N	bb568e26-548b-4ca5-9221-fefb9c9143b3
c2e248c8-e917-445f-9f7b-1e25d7bb5abe	functional_hr_recruitment_coordinator_ii	Recruitment Coordinator - II	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.818555+00	\N	\N	\N	\N	\N	bb568e26-548b-4ca5-9221-fefb9c9143b3
485012d4-2c28-4bc4-92c7-3609e3e3749e	functional_hr_senior_hr_executive_i	Senior HR Executive - I	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.820547+00	\N	\N	\N	\N	\N	bb568e26-548b-4ca5-9221-fefb9c9143b3
e4e20503-cd55-4393-83fd-6c7e7d7d0a49	functional_hr_senior_hr_executive_ii	Senior HR Executive - II	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.8227+00	\N	\N	\N	\N	\N	bb568e26-548b-4ca5-9221-fefb9c9143b3
b2b687ef-fd62-4cb7-a826-b40a35da7b2c	functional_sales_business_development_associate_i	Business Development Associate - I	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.828797+00	\N	\N	\N	\N	\N	914d8500-03b6-4a43-a250-244effca1cf1
157d001c-b056-45b1-96a3-3c05bcd8d99c	functional_sales_customer_success_representative_ii	Customer Success Representative - II	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.830775+00	\N	\N	\N	\N	\N	914d8500-03b6-4a43-a250-244effca1cf1
6193be76-40ad-4973-9ee7-246a4d8f4109	functional_sales_director_product_sales	Director - Product Sales	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.832885+00	\N	\N	\N	\N	\N	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
e2c675a7-92dc-4477-be75-9a304cbe4def	functional_sales_sales_associate	Sales Associate	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.83517+00	\N	\N	\N	\N	\N	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
272973a6-c052-4aef-bf32-9e24f7eb6cc9	functional_sales_associate_customer_success_representative_i	Associate Customer Success Representative - I	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.837646+00	\N	\N	\N	\N	\N	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
7e7d954f-34b5-4c23-8c3f-698ec920e9e4	functional_sales_associate_customer_success_representative_ii	Associate Customer Success Representative - II	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.839641+00	\N	\N	\N	\N	\N	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
b3309eea-7374-4a8d-ac13-481b2a7fd492	functional_project_m_associate_pmo_i	Associate PMO - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.845704+00	\N	\N	\N	\N	\N	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
2a76927c-461a-48e4-8190-dea7361ef3db	functional_project_m_associate_pmo_ii	Associate PMO - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.847585+00	\N	\N	\N	\N	\N	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	functional_project_m_senior_pmo_i	Senior PMO - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.849476+00	\N	\N	\N	\N	\N	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
138434a2-625f-4df5-836d-fcf0cfceef79	functional_project_m_senior_pmo_ii	Senior PMO - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.851761+00	\N	\N	\N	\N	\N	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
834c9e15-c70d-4a0b-bb12-5e55f23c181d	functional_project_m_delivery_account_manager_i	Delivery Account Manager - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.853646+00	\N	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89
d8a2b9e5-f54d-4344-a78d-c6c840467543	functional_project_m_delivery_account_manager_ii	Delivery Account Manager - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.855524+00	\N	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89
8b57cfd5-5d4e-44a3-9646-b36873c111c2	functional_project_m_senior_delivery_account_manager_i	Senior Delivery Account Manager - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.857373+00	\N	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89
9dc69952-eae6-4ec0-a327-67392315f089	functional_project_m_senior_delivery_account_manager_ii	Senior Delivery Account Manager - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.859188+00	\N	\N	\N	\N	\N	a5023c9e-367f-41e1-ba02-bdb2929edc89
f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	rd_research_and_deve_python_developer_i	Python Developer - I	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.864858+00	\N	\N	\N	\N	\N	f5c742d1-e0cc-4bf8-b860-a673ac407393
3356f353-1566-4df6-9958-fa01d67d13c7	rd_research_and_deve_python_developer_ii	Python Developer - II	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.866732+00	\N	\N	\N	\N	\N	f5c742d1-e0cc-4bf8-b860-a673ac407393
9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	rd_research_and_deve_python_developer_iii	Python Developer - III	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.868943+00	\N	\N	\N	\N	\N	f5c742d1-e0cc-4bf8-b860-a673ac407393
6d25ff6d-e13d-440f-b775-215547af7acb	services_operations_soc_analyst_i	SOC Analyst - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.874793+00	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
48429bb5-c583-4684-b30a-7ed443b671ca	services_operations_soc_analyst_ii	SOC Analyst - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.876768+00	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
f20a7445-0b01-4f20-85a5-853101d864ee	services_operations_soc_analyst_iii	SOC Analyst - III	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.878659+00	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
0c1a5ef4-7fca-45dc-8253-87afa21a1df9	services_operations_soc_analyst_iv	SOC Analyst - IV	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.880491+00	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
ea315f7d-d597-41b3-a999-4f3851bcd020	services_operations_siem_admin_i	SIEM Admin - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.88251+00	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
4650d4e0-f73c-4688-ae5f-830a46348ff9	services_operations_siem_admin_ii	SIEM Admin - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.884354+00	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
af8a1442-c5ee-409d-aa91-61c9dba852ee	services_operations_siem_admin_iii	SIEM Admin - III	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.886248+00	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	services_operations_soc_consultant_i	SOC Consultant - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.890218+00	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
911f6d7f-8d43-40f2-897a-2f416abf8cf9	services_operations_soc_consultant_ii	SOC Consultant - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.892032+00	\N	\N	\N	\N	\N	1a62b1f8-1810-464d-a67b-168d7e419827
e36018c5-bf48-4f93-bef7-93e8864a0b51	services_operations_siem_admin_iv	SIEM Admin - IV	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.888229+00	\N	\N	\N	\N	\N	aba61e5b-422a-4461-b9da-8dba8f6d3f85
444df30d-c195-42ad-b9a7-d80cdef69ccd	services_operations_soc_shift_lead_i	SOC Shift Lead - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.894767+00	\N	\N	\N	\N	\N	aba61e5b-422a-4461-b9da-8dba8f6d3f85
c0f974c3-f49c-449a-9276-aa64ce501344	services_operations_soc_shift_lead_ii	SOC Shift Lead - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.896662+00	\N	\N	\N	\N	\N	aba61e5b-422a-4461-b9da-8dba8f6d3f85
b5f39dd8-c305-489d-9f7d-9adfd010a134	services_operations_soc_lead_i	SOC Lead - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.899202+00	\N	\N	\N	\N	\N	111cc3cd-6d35-43ce-be91-dde90d3d4015
eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	services_operations_soc_lead_ii	SOC Lead - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.901107+00	\N	\N	\N	\N	\N	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7
1e7faab8-273d-40df-9f9a-485160186c5a	services_consulting_grc_auditor_i	GRC Auditor - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.908929+00	\N	\N	\N	\N	\N	768a11f9-ded7-4f6f-ba86-073e279255d9
2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	services_consulting_grc_auditor_ii	GRC Auditor - II	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.910823+00	\N	\N	\N	\N	\N	768a11f9-ded7-4f6f-ba86-073e279255d9
8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	services_consulting_grc_auditor_iii	GRC Auditor - III	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.912801+00	\N	\N	\N	\N	\N	768a11f9-ded7-4f6f-ba86-073e279255d9
0a60fb48-99c4-44d0-8d97-ff687ccffc9f	services_testing_red_team_practitioner_ii	Red Team Practitioner - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.986648+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
85cc9fbe-98a4-464d-a638-05f40529c6de	services_testing_red_team_practitioner_iii	Red Team Practitioner - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.991312+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
e2b4be77-2b20-4064-974d-e6322e7240b4	services_testing_associate_ai_engineer_contractual	Associate AI Engineer - Contractual	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:52.001242+00	\N	\N	\N	\N	\N	92aa9169-28d9-4754-a570-553b067642ed
e228c999-bf54-48b4-a373-d2bc9db88554	services_testing_associate_manager_i	Associate Manager - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.953968+00	\N	\N	\N	\N	\N	a3793f87-7f3c-41a1-a675-236fc1b710ab
168d11d7-ca26-4d61-b870-51779dc63023	services_testing_associate_manager_ii	Associate Manager - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.955906+00	\N	\N	\N	\N	\N	a3793f87-7f3c-41a1-a675-236fc1b710ab
aaf4ca75-5fa5-4de2-8353-a5e93beecb56	services_testing_associate_manager_iii	Associate Manager - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.957817+00	\N	\N	\N	\N	\N	a3793f87-7f3c-41a1-a675-236fc1b710ab
c6c6cd04-6df3-4593-b686-e4b9d362c96f	services_testing_devsecops_associate	DevSecOps Associate	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.980181+00	\N	\N	\N	\N	\N	a3793f87-7f3c-41a1-a675-236fc1b710ab
3b7ea453-324e-40a0-bb41-77a0795d5af5	services_testing_associate_project_manager	Associate Project Manager	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.961716+00	\N	\N	\N	\N	\N	29ad5710-1621-4c24-ac75-dedfc168ba1a
c1fa4328-a970-48a1-bc08-d50fe36bf44c	services_testing_devsecops_specialist_ii	DevSecOps Specialist - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.983425+00	\N	\N	\N	\N	\N	29ad5710-1621-4c24-ac75-dedfc168ba1a
4b680e29-b4fb-4689-9afb-67a7f089f52b	services_testing_red_team_specialist_ii	Red Team Specialist - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.994166+00	\N	\N	\N	\N	\N	29ad5710-1621-4c24-ac75-dedfc168ba1a
8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	services_testing_senior_cloud_security_consultant_i	Senior Cloud Security Consultant - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.997244+00	\N	\N	\N	\N	\N	29ad5710-1621-4c24-ac75-dedfc168ba1a
a697a798-caaf-4248-8e4e-7e89096a9c30	services_testing_manager_i	Manager - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:51.966138+00	\N	\N	\N	\N	\N	efc1df20-ca04-44a6-87b2-7cae1ff50a88
b3c75d81-80a1-4240-8b1e-010000000004	services_testing_hod	Testing HOD	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	\N	c787fe3b-4b33-40ee-8794-c1148202f81a
f8502c44-b289-49e4-8401-3dcad4d5bbe0	functional_it_admini_intern	Intern	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 10:24:51.794108+00	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
caa227a1-2dcf-4195-ab9c-8f76d1862daa	functional_accounts_intern	Intern	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 10:24:51.809802+00	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
e8c22eff-0daf-4690-a537-c8b0b6110a01	functional_hr_intern	Intern	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 10:24:51.824863+00	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
e2b10def-c91d-45da-94c5-f5530e743aa2	functional_sales_intern	Intern	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 10:24:51.841726+00	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
9050e021-7d84-4401-820e-c0e768abb1ab	functional_project_m_intern	Intern	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 10:24:51.861092+00	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
bb7ccd5f-2f60-49fb-b984-f11fc47add22	rd_research_and_deve_intern	Intern	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 10:24:51.870785+00	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	services_operations_intern	Intern	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 10:24:51.904989+00	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
2076a9b1-e432-46a9-99b1-36e732159856	services_consulting_intern	Intern	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 10:24:51.924658+00	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
47dbf38f-c022-47bc-8444-d0dfb35ff3fd	services_testing_intern	Intern	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 10:24:52.004312+00	\N	\N	\N	\N	\N	f29af015-7833-4f9a-ac57-6fbef5bf91ec
\.


--
-- Data for Name: mst_email_domains; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_email_domains ("Id", "Code", "DomainName", "DisplayName", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
5112286a-225d-4b86-b16f-74211d9c5779	talakunchi_com	talakunchi.com	@talakunchi.com	t	1	2026-08-21 19:12:04.483485+00	\N	\N	\N	\N
a19f97e1-8bf5-4b14-823a-b653b62c2954	talakunchi_in	talakunchi.in	@talakunchi.in	t	2	2026-08-21 19:12:04.483485+00	\N	\N	\N	\N
fb66fff9-7911-47de-bde7-ab5fb5ab0757	squad1_io	squad1.io	@squad1.io	t	3	2026-08-21 19:12:04.483485+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_employee_statuses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_employee_statuses ("Id", "Code", "Name", "IsActive", "AllowOnboarding", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
26e2b2e5-b1ab-40af-8f6d-2b80deb463a0	absconded	Absconded	t	f	3	2026-09-07 06:03:13.27055+00	\N	\N	\N	\N
a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	terminated	Terminated	t	f	2	2026-09-07 06:03:13.27055+00	\N	\N	\N	\N
beee234f-c734-4d09-a0bb-96a6cc523cc3	resignation_under_review	Resignation Under Review	t	f	5	2026-09-07 06:03:13.27055+00	\N	\N	\N	\N
ce28b4c5-a343-493b-9404-96c983768850	resigned	Resigned	t	f	4	2026-09-07 06:03:13.27055+00	\N	\N	\N	\N
e273e2ed-5fd3-4564-bb87-09a71cd4779a	active	Active	t	t	1	2026-09-07 06:03:13.27055+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_entra_roles; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: mst_graduation_degrees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
\.


--
-- Data for Name: mst_industries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
7f460c51-01ec-4da1-8f71-d6f360b56f91	healthcare	Healthcare	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
f175fde9-14f8-40e8-b564-47d8a29d84ff	logistics	Logistics	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
c7e82721-829b-4450-8393-022587178471	energy	Energy	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
4a80bfdb-a191-4ce1-ab51-2142eb366db7	banking	Banking	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
935db8d7-e2aa-417e-839e-b51d00ce951e	retail	Retail	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
e722474e-d845-42b8-978e-91a6ec78f080	manufacturing	Manufacturing	t	2026-08-18 07:55:36.166597+00	\N	\N	\N	\N
ff5e83cc-9c1c-4056-ab0b-42a70714ddd3	media	Media	t	2026-08-20 06:15:51.759149+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dcb2b955-8d33-4b9b-b04a-64208dce1520	telecom	Telecom	t	2026-09-09 07:16:02.332706+00	\N	\N	\N	\N
02012f0c-97b2-4aea-a6b4-954ee97d892d	technology	Technology	f	2026-08-18 07:55:36.166597+00	2026-09-09 07:25:18.453091+00	\N	\N	\N
16ebeb23-b3d8-4fb7-a4f6-789510c28ad3	environment	Environment	f	2026-08-18 07:55:36.166597+00	2026-09-09 07:25:18.453091+00	\N	\N	\N
3a8e57e7-2f6d-4c84-9428-d11de98078c9	quantum_computing	Quantum Computing	f	2026-08-19 06:32:47.466308+00	2026-09-09 07:25:18.453091+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4bf54de4-0e85-4904-a89f-542301b65077	automotive	Automotive	f	2026-08-18 07:55:36.166597+00	2026-09-09 07:25:18.453091+00	\N	\N	\N
cd116cba-a939-4cb7-bd0f-233019a005b0	finance	Finance	f	2026-08-18 07:55:36.166597+00	2026-09-09 07:25:18.453091+00	\N	\N	\N
\.


--
-- Data for Name: mst_nationalities; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: mst_offices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_offices ("Id", "Code", "Name", "WorkLocationId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_post_graduation_degrees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
02b11fcf-15dc-438e-857d-fe1df19f925b	me	ME	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
29c8b610-bca4-41b7-8199-960c4907c189	mba	MBA	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
42343c31-3dfa-44e6-a433-5d0c66dcfaf0	na	NA	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
93a0a0ed-91ed-41e3-91c1-09e94f248667	mtech	M.Tech	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
9ea82119-8356-4b91-87ea-aeeb679b9cf6	msc	M.Sc	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
c7bd4e1d-4826-421d-b473-3a926672050e	ma	M.A.	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
e0725237-7a46-48ee-9ff1-3969f2571d2a	mcom	M.Com	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
e2722a3d-0767-4299-afa9-04d89c28cd7c	mca	MCA	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
ec8299cf-acb1-4a26-aed5-a03db0ff8bfe	ms	MS	t	2026-09-08 04:59:44.231454+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_reporting_managers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_reporting_managers ("Id", "Code", "Name", "Designation", "Email", "EmployeeId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
03bff38b-8821-43f1-bb81-f35828f60d36	vikram_gupta	Vikram Gupta	Project Manager	vikram.gupta@acme.co	\N	t	11	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
2b340512-4fbe-4617-a382-b8b78d2b461b	akash_jain	Akash Jain	Intern	akash.jain@acme.co	00000000-0000-4000-8000-000000000058	t	2	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
4545c5d5-d7b2-422f-bc88-41df240f7df5	ankit_verma	Ankit Verma	SOC Analyst - II	ankit.verma@acme.co	00000000-0000-4000-8000-000000000023	t	4	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
6894730f-d48f-4358-9cb0-faaa2815c0a3	arjun_singh	Arjun Singh	PenTester - II	arjun@acme.co	00000000-0000-4000-8000-000000000046	t	5	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
6b8c33c8-de5a-4597-bd9d-10e6a95a733d	ayush_saxena	Ayush Saxena	Intern	ayush.saxena@acme.co	00000000-0000-4000-8000-000000000053	t	6	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
7e6d4426-74c1-406a-8ffd-b47871864b01	aditya_reddy	Aditya Reddy	SIEM Admin - II	aditya.reddy@acme.co	00000000-0000-4000-8000-000000000024	t	1	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
8771b8d4-89aa-4d73-bd2a-4d91b6404a34	harsh_nair	Harsh Nair	Business Analyst	harsh.nair@acme.co	\N	t	10	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
8b1f5eb8-065a-4478-bf63-4d3fbcccf70b	pooja_menon	Pooja Menon	HR Business Partner	pooja.menon@acme.co	\N	t	12	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
b4309d40-951c-4f5b-809e-6cdfb96b0ffe	neha_kulkarni	Neha Kulkarni	Technical Lead	neha.kulkarni@acme.co	\N	t	7	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
bcd78a5a-de09-4e6b-9f00-50a54e908730	aanya_joshi	Aanya Joshi	Sales Executive	aanya.joshi@acme.co	\N	t	9	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
e64c27f7-a329-4990-b997-d0041198cf59	arjun_mehta	Arjun Mehta	Engagement Manager	arjun.mehta@acme.co	\N	t	15	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
e78fc289-2042-4f04-a9d3-0bfc53aae714	ananya_verma	Ananya Verma	Intern	ananya.verma@acme.co	00000000-0000-4000-8000-000000000050	t	3	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
f91f1020-3ec7-4c16-9aee-9bee2124a465	rahul_sharma	Rahul Sharma	Engagement Manager	rahul.sharma@acme.co	\N	t	14	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
faf18318-d2a6-42a5-a143-e1ef7f9446f4	samar_patel	Samar Patel	HR Business Partner	samar.patel@acme.co	\N	t	8	2026-09-24 12:28:46.094618+00	\N	\N	\N	\N
4deb2755-7447-4514-b05a-bdd25d92f201	naveen_choudhary	Naveen Choudhary	Intern	naveen.choudhary@acme.co	00000000-0000-4000-8000-000000000055	t	5	2026-09-24 13:52:57.235573+00	\N	\N	\N	\N
769797b2-6d9a-415d-8924-0659deaf05c5	pooja_nair	Pooja Nair	SOC Analyst - III	pooja.nair@acme.co	00000000-0000-4000-8000-000000000026	t	6	2026-09-24 13:52:57.235573+00	\N	\N	\N	\N
8a5a0f48-7f36-493e-b1e0-4de9dcd5e51c	manish_tiwari	Manish Tiwari	SOC Consultant - I	manish.tiwari@acme.co	00000000-0000-4000-8000-000000000025	t	2	2026-09-24 13:52:57.235573+00	\N	\N	\N	\N
ad22b311-5f77-4f4f-a567-662dd7c63151	meera_nambiar	Meera Nambiar	GRC Auditor - II	meera.nambiar@acme.co	00000000-0000-4000-8000-000000000033	t	4	2026-09-24 13:52:57.235573+00	\N	\N	\N	\N
be305e61-b80d-4b93-b858-dd868d1bd835	meera_joshi	Meera Joshi	DevSecOps Practitioner - I	meera@acme.co	00000000-0000-4000-8000-000000000047	t	3	2026-09-24 13:52:57.235573+00	\N	\N	\N	\N
f5fc991e-50c0-4c7f-98f3-00c8066eee89	kunal_mehra	Kunal Mehra	Intern	kunal.mehra@acme.co	00000000-0000-4000-8000-000000000059	t	1	2026-09-24 13:52:57.235573+00	\N	\N	\N	\N
11a665b8-4f3c-4cd7-9c96-2ced933ab354	rajat_singhal	Rajat Singhal	GRC Auditor - III	rajat.singhal@acme.co	00000000-0000-4000-8000-000000000034	t	3	2026-09-25 04:27:46.284354+00	\N	\N	\N	\N
1e9153c0-a023-456d-b341-ac4e2d8d23a1	rohit_verma	Rohit Verma	Associate Customer Success Representative - I	rohit.verma@acme.co	00000000-0000-4000-8000-000000000010	t	5	2026-09-25 04:27:46.284354+00	\N	\N	\N	\N
289b6466-1e8d-4083-86b2-2731047b3ffc	pooja_sharma	Pooja Sharma	Sales Associate	pooja.sharma@acme.co	00000000-0000-4000-8000-000000000009	t	1	2026-09-25 04:27:46.284354+00	\N	\N	\N	\N
57925ef2-bc23-461d-a9d5-1ad4be938cd0	rohan_joshi	Rohan Joshi	Intern	rohan.joshi@acme.co	00000000-0000-4000-8000-000000000051	t	4	2026-09-25 04:27:46.284354+00	\N	\N	\N	\N
c5d6bcd4-445c-46aa-bb33-7497adbd6c46	priya_sharma	Priya Sharma	PenTester - I	priya.sharma@acme.co	00000000-0000-4000-8000-000000000045	t	2	2026-09-25 04:27:46.284354+00	\N	\N	\N	\N
e44a4f7f-1f76-4325-bc10-58812b22d865	simran_kaur	Simran Kaur	Intern	simran.kaur@acme.co	00000000-0000-4000-8000-000000000054	t	6	2026-09-25 04:27:46.284354+00	\N	\N	\N	\N
a07dfbd5-cdc1-4da9-b354-1229dec56728	nikhil_khanna	Nikhil Khanna	Sales Executive	nikhil.khanna@acme.co	00000000-0000-4000-8000-000000000008	t	13	2026-09-24 12:28:46.094618+00	2026-09-25 06:07:57.176135+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
00000000-0000-4000-8000-000000000101	vikrant_malhotra	Vikrant Malhotra	Director and Chief Executive Officer	vikrant@acme.co	00000000-0000-4000-8000-000000000001	t	1	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000102	dhanshree_pansare	Dhanshree Pansare	Director and Chief Operating Officer	dhanshree@acme.co	00000000-0000-4000-8000-000000000002	t	2	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000103	kunal_deshmukh	Kunal Deshmukh	Director and Chief Technology Officer	kunal.deshmukh@acme.co	00000000-0000-4000-8000-000000000003	t	3	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000104	admin_user	Admin User	IT Admin	admin@acme.co	00000000-0000-4000-8000-000000000004	t	4	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000105	accounts_user	Accounts User	Senior Accountant - I	accounts@acme.co	00000000-0000-4000-8000-000000000005	t	5	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000106	hr_user	HR User	HR Head	hr@acme.co	00000000-0000-4000-8000-000000000006	t	6	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000107	sales_user	Sales User	Sales Manager	sales@acme.co	00000000-0000-4000-8000-000000000007	t	7	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000112	rahul_gupta	Rahul Gupta	Senior PMO - I	rahul@acme.co	00000000-0000-4000-8000-000000000012	t	8	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000113	riya_kapoor	Riya Kapoor	Engagement Manager	riya@acme.co	00000000-0000-4000-8000-000000000013	t	9	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000114	pradeep_singh	Pradeep Singh	Engagement Manager	pradeep.singh@acme.co	00000000-0000-4000-8000-000000000014	t	10	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000115	kavya_desai	Kavya Desai	Python Developer - II	kavya.desai@acme.co	00000000-0000-4000-8000-000000000015	t	11	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000116	rajesh_kadam	Rajesh Kadam	SOC HOD	rajesh.kadam@acme.co	00000000-0000-4000-8000-000000000016	t	12	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000117	deepak_sawant	Deepak Sawant	SOC Senior Manager	deepak.sawant@acme.co	00000000-0000-4000-8000-000000000017	t	13	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000118	vikram_shah	Vikram Shah	SOC Manager	vikram@acme.co	00000000-0000-4000-8000-000000000018	t	14	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000119	sneha_iyer	Sneha Iyer	SOC Lead - I	sneha.iyer@acme.co	00000000-0000-4000-8000-000000000019	t	15	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000120	nikhil_rao	Nikhil Rao	SOC Lead - II	nikhil@acme.co	00000000-0000-4000-8000-000000000020	t	16	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000121	amit_pandey	Amit Pandey	SOC Shift Lead - I	amit.pandey@acme.co	00000000-0000-4000-8000-000000000021	t	17	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000127	anita_desai	Anita Desai	Senior Vice President - Principal Consultant	anita@acme.co	00000000-0000-4000-8000-000000000027	t	18	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000128	aarav_mehta	Aarav Mehta	Principal Manager - I	aarav@acme.co	00000000-0000-4000-8000-000000000028	t	19	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000129	sana_iyer	Sana Iyer	Associate Manager - III	sana@acme.co	00000000-0000-4000-8000-000000000029	t	20	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000130	priya_verma	Priya Verma	Senior GRC Auditor - I	priya@acme.co	00000000-0000-4000-8000-000000000030	t	21	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000131	siddharth_roy	Siddharth Roy	Senior GRC Auditor - II	siddharth.roy@acme.co	00000000-0000-4000-8000-000000000031	t	22	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000137	girish_shenoy	Girish Shenoy	Testing HOD	girish.shenoy@acme.co	00000000-0000-4000-8000-000000000037	t	23	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000138	suresh_pillai	Suresh Pillai	Manager - I	suresh.pillai@acme.co	00000000-0000-4000-8000-000000000038	t	24	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000139	alok_kumar	Alok Kumar	Associate Manager - III	alok.kumar@acme.co	00000000-0000-4000-8000-000000000039	t	25	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000140	divya_rao	Divya Rao	Associate Project Manager	divya.rao@acme.co	00000000-0000-4000-8000-000000000040	t	26	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000141	manoj_bhatt	Manoj Bhatt	DevSecOps Specialist - II	manoj.bhatt@acme.co	00000000-0000-4000-8000-000000000041	t	27	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000142	gaurav_joshi	Gaurav Joshi	DevSecOps Associate	gaurav.joshi@acme.co	00000000-0000-4000-8000-000000000042	t	28	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000143	kiran_mathur	Kiran Mathur	Associate Manager - I	kiran.mathur@acme.co	00000000-0000-4000-8000-000000000043	t	29	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
00000000-0000-4000-8000-000000000144	ramesh_nair	Ramesh Nair	Associate Manager - II	ramesh.nair@acme.co	00000000-0000-4000-8000-000000000044	t	30	2026-09-24 11:20:42.604481+00	\N	\N	\N	\N
06e8e00e-07d8-41b7-8394-251af95d23a8	kavya_nair	Kavya Nair	Senior Pentester - I	kavya@acme.co	00000000-0000-4000-8000-000000000049	t	6	2026-09-24 12:53:42.49824+00	\N	\N	\N	\N
0874c210-56b2-483b-a1f8-53e35862e086	ira_kapoor	Ira Kapoor	GRC Auditor - I	ira.kapoor@acme.co	00000000-0000-4000-8000-000000000032	t	4	2026-09-24 12:53:42.49824+00	\N	\N	\N	\N
1b29b7b1-5c2f-4b2b-9a72-a05cb3f063e6	karthik_bose	Karthik Bose	SOC Analyst - I	karthik.bose@acme.co	00000000-0000-4000-8000-000000000022	t	5	2026-09-24 12:53:42.49824+00	\N	\N	\N	\N
2d3bd4d9-52e5-4760-a0b1-4d786d4c75d2	bhavna_patel	Bhavna Patel	Intern	bhavna.patel@acme.co	00000000-0000-4000-8000-000000000056	t	1	2026-09-24 12:53:42.49824+00	\N	\N	\N	\N
aa054bdc-7cb5-4c0c-988d-96b595911c13	harsh_wardhan	Harsh Wardhan	Intern	harsh.wardhan@acme.co	00000000-0000-4000-8000-000000000057	t	3	2026-09-24 12:53:42.49824+00	\N	\N	\N	\N
b7220d2c-af72-4d9a-891c-0faca2cbda5f	dev_patel	Dev Patel	Red Team Practitioner - II	dev@acme.co	00000000-0000-4000-8000-000000000048	t	2	2026-09-24 12:53:42.49824+00	\N	\N	\N	\N
43df527c-54b2-4457-a305-383b2265ed8d	swati_mishra	Swati Mishra	GRC Auditor - IV	swati.mishra@acme.co	00000000-0000-4000-8000-000000000035	t	2	2026-09-25 05:11:30.739409+00	\N	\N	\N	\N
46a7dd69-d00b-49f1-9148-8295824d89dc	varun_saxena	Varun Saxena	GRC Auditor - I	varun.saxena@acme.co	00000000-0000-4000-8000-000000000036	t	4	2026-09-25 05:11:30.739409+00	\N	\N	\N	\N
9501738d-a3cd-444b-99af-266af1c5ad94	sneha_reddy	Sneha Reddy	Associate Customer Success Representative - II	sneha.reddy@acme.co	00000000-0000-4000-8000-000000000011	t	1	2026-09-25 05:11:30.739409+00	\N	\N	\N	\N
a205916c-a247-430e-b0d6-5b42abd908f6	tanvi_deshmukh	Tanvi Deshmukh	Intern	tanvi.deshmukh@acme.co	00000000-0000-4000-8000-000000000052	t	3	2026-09-25 05:11:30.739409+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_roles; Type: TABLE DATA; Schema: public; Owner: -
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
b3c75d81-80a1-4240-8b1e-020000000001	services_operations_soc_manager_manager_mng_	Manager (Mng.)	t	b3c75d81-80a1-4240-8b1e-010000000001	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N
b3c75d81-80a1-4240-8b1e-020000000002	services_operations_soc_sr_manager_sr_manager_sr_mng_	Sr. Manager (Sr.Mng.)	t	b3c75d81-80a1-4240-8b1e-010000000002	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N
b3c75d81-80a1-4240-8b1e-020000000003	services_operations_soc_hod_head_of_department_hod_	Head Of Department (HOD)	t	b3c75d81-80a1-4240-8b1e-010000000003	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N
b3c75d81-80a1-4240-8b1e-020000000004	services_testing_hod_head_of_department_hod_	Head Of Department (HOD)	t	b3c75d81-80a1-4240-8b1e-010000000004	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N
b3c75d81-80a1-4240-8b1e-020000000005	functional_sales_manager_manager_mng_	Manager (Mng.)	t	b3c75d81-80a1-4240-8b1e-010000000005	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_salary_bands; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_salary_bands ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
20ffbe9b-96ca-496e-ab2e-50ccf3c91246	l3	L3	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
37016f9a-2474-400d-99ae-18157aaad035	l1	L1	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	l4	L4	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
e5f5511b-dea6-421c-8c0e-b271e4ee5d43	l5	L5	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
ebed343e-301f-4984-b292-fa8d1cb1623c	l2	L2	t	2026-08-20 12:51:10.222702+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_service_catalog; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_catalog ("Id", "Code", "Name", "SubDepartmentId", "DefaultTools", "DefaultUnitPrice", "DefaultDurationDays", "Description", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
d000000b-0000-0000-0000-00000000000b	RT002	Targeted Red Team Engagement	c0000009-0000-0000-0000-000000000009	Custom Tools, Cobalt Strike	80000.00	7	\N	t	11	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
d000000c-0000-0000-0000-00000000000c	CS001	AWS Security Assessment	c000000a-0000-0000-0000-00000000000a	Scout2, CloudMapper, AWS Inspector	55000.00	5	\N	t	12	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
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
\.


--
-- Data for Name: mst_service_departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_departments ("Id", "Code", "Name", "GroupId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
\.


--
-- Data for Name: mst_service_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_groups ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
a1111111-1111-1111-1111-111111111111	RESOURCE	Resource	t	1	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
a2222222-2222-2222-2222-222222222222	SCOPE	Scope	t	2	2026-09-28 07:41:38.11983+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_service_sub_departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_sub_departments ("Id", "Code", "Name", "DepartmentId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
\.


--
-- Data for Name: mst_work_locations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_work_locations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
3bc10d7b-a705-4ec9-b7b5-71858572a8cc	suvidha_square_andheri	Suvidha Square, Andheri	t	2	2026-09-03 12:26:58.067087+00	2026-09-10 06:34:25.480503+00	\N	\N	\N
58e569dc-cb93-4832-bf22-2e8d4836dc65	onsite	Onsite	t	1	2026-09-03 12:26:58.067087+00	2026-09-10 06:34:25.480503+00	\N	\N	\N
8d0b23a2-9459-4fbe-a7bf-624abd410c40	navare_plaza_dombivli	Navare Plaza, Dombivli	t	3	2026-09-03 12:26:58.067087+00	2026-09-10 06:34:25.480503+00	\N	\N	\N
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
\.


--
-- Data for Name: project_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_services ("Id", "ProjectId", "ServiceCatalogId", "TaskId", "Department", "SubDepartment", "ServiceName", "Qty", "Description", "ResourceLevel", "Frequency", "Location", "LocationText", "ServiceModel", "DeliveryModel", "FinalDeliveryFormat", "BillingModel", "Tools", "StartDate", "EndDate", "DurationDays", "DurationHours", "TotalDays", "TotalHours", "UnitPrice", "Total", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
\.


--
-- Data for Name: project_tasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_tasks ("Id", "ProjectId", "ProjectServiceId", "Title", "Description", "Period", "Phase", "Stage", "Priority", "PlannedStartDate", "PlannedEndDate", "ActualStartDate", "ActualEndDate", "EstimatedHours", "UtilizedHours", "Progress", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refresh_tokens ("Id", "UserId", "TokenHash", "ExpiresAtUtc", "RevokedAtUtc", "ReplacedByTokenHash", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
5ffba308-d7d8-4eaf-a050-24ccfc6a2158	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3Y/Llii7BLjc+ylFJUlFUY2Ws0jsoLdF/vpbxyk7iMw=	2026-10-01 12:29:15.192705+00	2026-09-24 12:33:41.467732+00	\N	2026-09-24 12:29:15.192883+00	2026-09-24 12:33:41.467759+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7471874b-e746-41ec-aa76-f3cee2599f88	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	x8Pkrfe9G17wmKtDOWSIw2DgnatLxt57N8wUhhKTKNw=	2026-10-01 12:33:41.906451+00	2026-09-24 13:01:53.121863+00	\N	2026-09-24 12:33:41.906658+00	2026-09-24 13:01:53.149825+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6ac30ca6-ebd1-4d6c-af75-3687c0693ccd	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	eWug6YnmI2nCEl36fIjuYslBC4tOjc/TWf5sO0gAGOQ=	2026-10-01 13:01:53.146254+00	2026-09-24 13:49:25.954384+00	\N	2026-09-24 13:01:53.149825+00	2026-09-24 13:49:25.954537+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2ea474d1-5fbf-4981-93f9-a1245e221a06	00000000-0000-4000-9000-000000000015	ekICsM9ReuMTaqQztcoIxFRPmHglOEkd9f+ceLUwWe4=	2026-10-01 13:49:26.576981+00	2026-09-24 13:49:30.438631+00	\N	2026-09-24 13:49:26.577694+00	2026-09-24 13:49:30.438655+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d1ac74ff-463a-44df-9795-364dafd45da6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Nn4Eg/INL3SvFVHHk8NfLFbsDbylGkpkZObw1S6OXTc=	2026-10-01 11:21:42.288394+00	2026-09-24 11:24:45.014403+00	\N	2026-09-24 11:21:42.289111+00	2026-09-24 11:24:45.014412+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c466d4d8-0490-4d25-bd93-2bb37a0855f2	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	agF6t1cK+lBpRRSpjbl6WsFYrmoJfQzXygXuDEdSRjI=	2026-10-01 11:24:45.495672+00	2026-09-24 11:24:57.838645+00	\N	2026-09-24 11:24:45.49588+00	2026-09-24 11:24:57.838653+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1c4008b0-439f-4e7a-bc6d-00832d3c3eba	1a077a8c-4029-8ded-d563-19e9b4bdf301	pYpW6hEhLf3ybJ/z1c2+VnrYIdTTISqziJTQLybE+uE=	2026-10-01 11:24:58.408717+00	2026-09-24 11:25:17.934214+00	\N	2026-09-24 11:24:58.652955+00	2026-09-24 11:25:17.936411+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
86bab331-7a64-4991-85d7-4f729fd51b89	1a077a8c-4029-8ded-d563-19e9b4bdf301	LrzZ1YorxamYvgj1rNhfyti92NCgPpMXjV+VG8yRRIE=	2026-10-01 11:25:17.935681+00	2026-09-24 11:25:29.095757+00	\N	2026-09-24 11:25:17.936411+00	2026-09-24 11:25:29.095767+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7eacbbc4-eb37-4d82-b5b7-07a2af8fe7d4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9elbX6mCzyidEin69sjUEuu3Cc1fSPxluU3YQ4wCV0Y=	2026-10-01 11:25:29.56906+00	2026-09-24 12:07:36.94003+00	\N	2026-09-24 11:25:29.569357+00	2026-09-24 12:07:36.946064+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
979b68a7-a57c-481c-92aa-55eca343d613	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	7iRqpARpVfw4sTf0quI8LllVBQjNLXidTYyCeOURKj0=	2026-10-01 12:07:36.943818+00	2026-09-24 12:09:05.111374+00	\N	2026-09-24 12:07:36.946064+00	2026-09-24 12:09:05.111387+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
684216a5-b910-414b-9f4c-9ac5d7ec832a	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	5xx36LAmc44fvl8qZFHy3BZ/E+ntlqkU8l0WV8jTTb0=	2026-10-01 12:09:05.66179+00	2026-09-24 12:12:40.718966+00	\N	2026-09-24 12:09:05.663693+00	2026-09-24 12:12:40.722881+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
506786dc-428c-400b-b203-6cc6c16ca57e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TyHG/r14mmVUgN9VQTKcHdcrOVapMjVnhmXeTNjZGvk=	2026-10-01 12:12:40.721514+00	2026-09-24 12:12:46.190597+00	\N	2026-09-24 12:12:40.722881+00	2026-09-24 12:12:46.191776+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
64fe8645-d6fb-4593-b9fe-23cc729a1b01	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	LClQ+y6XZMw1YL0QJ9TxGJlZHktlJI+ik572HcIMO9c=	2026-10-01 12:12:46.191635+00	2026-09-24 12:24:55.42792+00	\N	2026-09-24 12:12:46.191776+00	2026-09-24 12:24:55.434881+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e6dcfa1a-9eed-41f2-991e-11ab8b51d7b9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	N0D1WABJQ664O1jAukRCrLKZ9AD47+0abCC+DqJ7Vws=	2026-10-01 12:24:55.43145+00	2026-09-24 12:29:10.248083+00	\N	2026-09-24 12:24:55.434881+00	2026-09-24 12:29:10.267829+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
8ec1f8e4-5da4-4e9a-9a4f-326e22ab96c5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	TbQB4i9k/30IuXjEb58owLJ98Laa4A8FM4zn9049QXI=	2026-10-01 12:29:10.264854+00	2026-09-24 12:29:14.569579+00	\N	2026-09-24 12:29:10.267829+00	2026-09-24 12:29:14.569607+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c7b1f317-54bb-41b5-b1f1-073cfe9e2a6e	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	iFdtQq0AlXt1jjczdscO1oXZ/9avZcq4KXxb1eVo0QE=	2026-10-01 13:49:30.969538+00	2026-09-24 13:50:02.181521+00	\N	2026-09-24 13:49:30.96978+00	2026-09-24 13:50:02.182219+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
af90baef-422b-428d-8017-819a930a8129	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	OL1lUx1Z4DxKJkYWYkfU4YEJwfjtS7+RScqDRNen26I=	2026-10-01 13:50:02.18198+00	2026-09-24 13:51:09.024264+00	\N	2026-09-24 13:50:02.182219+00	2026-09-24 13:51:09.026174+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
00f3b6f7-ac85-47db-a9ac-fcdde5f60c1d	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	PXc5JfIb8DvL7XZXNNp3ZP4a0q4Esg3/RugEA+C0HUc=	2026-10-01 13:51:09.025351+00	2026-09-24 13:51:17.784639+00	\N	2026-09-24 13:51:09.026174+00	2026-09-24 13:51:17.785142+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6b1d51f0-24da-451b-8052-62983870f70e	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	ZdHQ0pDn74i4lWMYZLY8C/IP9Da3EpS9sUdAH+yJ+TQ=	2026-10-01 13:51:17.785023+00	2026-09-24 13:51:53.065969+00	\N	2026-09-24 13:51:17.785142+00	2026-09-24 13:51:53.065988+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
4dbf446d-dba9-4aeb-83e6-facd303ee262	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	DRJBVLm91yfc1prrHTTCPhz2iDZDqKqN1/2dhmthCx4=	2026-10-01 13:51:54.588727+00	2026-09-24 13:52:01.66111+00	\N	2026-09-24 13:51:54.588944+00	2026-09-24 13:52:01.661134+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2840fa1a-2d99-4284-ba44-8117d301385d	dc139a9d-b996-7354-6c27-72659ea2fd59	x67HSiaUBOCW2MGh9nZfjVc/JRW5kjmPyg6IFEq4Wx4=	2026-10-01 13:52:02.199725+00	2026-09-24 13:52:05.286002+00	\N	2026-09-24 13:52:02.200019+00	2026-09-24 13:52:05.286016+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
37c927c0-1446-4b54-b129-a85ee6083ad8	b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	imrkQ2PcF21S9YcP5unCEcoTPh2pRpok1XVAnVScBjU=	2026-10-01 13:52:05.739828+00	2026-09-24 13:52:10.772368+00	\N	2026-09-24 13:52:05.740145+00	2026-09-24 13:52:10.772388+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e85e2a6d-c39b-4a85-a923-7707a07742aa	00000000-0000-4000-9000-000000000050	rQasgNBxfIwd+JGm/s3c3h3MEDqbqyErzzByIHmG9gI=	2026-10-01 13:52:11.877301+00	2026-09-24 13:52:30.221987+00	\N	2026-09-24 13:52:11.877448+00	2026-09-24 13:52:30.222008+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
30a4bb8f-c0cf-4041-bc81-a62de0819f1f	00000000-0000-4000-9000-000000000026	6WWCg50Qx6z9j7zb8CRvsUG7OXZHo+3mayJ3M2tQD9M=	2026-10-01 13:52:30.672783+00	2026-09-24 13:53:15.664067+00	\N	2026-09-24 13:52:30.672929+00	2026-09-24 13:53:15.685391+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
654cf7c6-5c05-4500-9654-0f7098d57116	f2f23eb1-efb6-f0a7-c57e-0ead09121a21	32POqdtfKhNpLcOtZ8jyFu+Ee5pnSewIus9q9NaGORg=	2026-10-01 13:53:51.745124+00	\N	\N	2026-09-24 13:53:51.745324+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cee7386d-7fa6-4601-ab32-c74cdc2a80de	00000000-0000-4000-9000-000000000026	70hxtt7IA4kB5tTUUQN0sMJr9mTA4gGwuKJuVheBXkM=	2026-10-01 13:53:15.681643+00	2026-09-24 13:53:55.507906+00	\N	2026-09-24 13:53:15.685391+00	2026-09-24 13:53:55.507926+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
00f6b01b-fc2d-4f79-8626-90826f49c101	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	5Y1J0JtZ6CL69793TNKuKSVrLrC7jGS5Z8jm+cXXlDQ=	2026-10-01 13:53:39.005679+00	2026-09-24 13:53:56.002569+00	\N	2026-09-24 13:53:39.00594+00	2026-09-24 13:53:56.003127+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2efd068c-6c5d-4a62-95cb-f34ddc3cb91e	730809c0-fc01-a664-03ca-28e0e32d0393	rDFSDOAbkqWWf0Vxm0gxOdzEhfaBCTpLapI2sSiX6/M=	2026-10-01 13:53:59.214927+00	\N	\N	2026-09-24 13:53:59.215215+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
58880be6-c35f-4b7f-bb31-e3ce9031ebb4	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	xn/NgVWB0gaHLIwZeRFWxyAyvz4oSLswhSJchrJ5u7c=	2026-10-01 13:53:56.002895+00	2026-09-24 13:56:04.382041+00	\N	2026-09-24 13:53:56.003127+00	2026-09-24 13:56:04.382063+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
7d7d1ad0-e931-48fd-9c59-b805abefbeb3	00000000-0000-4000-9000-000000000050	L3M7PkNMasCy/f86Nf0/fO9yZFao3zaQxxxhxUvAnTA=	2026-10-01 13:54:12.229806+00	2026-09-24 13:56:05.51828+00	\N	2026-09-24 13:54:12.230211+00	2026-09-24 13:56:05.518616+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
665400bd-3c44-46cd-8fbb-ccabd5dc0a4a	00000000-0000-4000-9000-000000000050	XTtMU7YRVrUy2h2/8MY2++uegDeVAh4MywiURi4RiIQ=	2026-10-01 13:56:05.51848+00	2026-09-24 13:56:09.251228+00	\N	2026-09-24 13:56:05.518616+00	2026-09-24 13:56:09.25124+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
70b99eaf-0cf0-4994-92fc-ab5a355bfe12	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	23l2ulkZNIUAbGrHD23dlyLUkJVzDyNdRmHxv0HPr2o=	2026-10-01 13:56:09.727969+00	2026-09-24 13:56:17.174904+00	\N	2026-09-24 13:56:09.728195+00	2026-09-24 13:56:17.174919+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5c059af7-29fb-45fe-a885-817f95f95d17	00000000-0000-4000-9000-000000000009	SsMMZh5w8DOi+UPRkNmy8Iw9GsGGuum1fyPAjumdPKM=	2026-10-01 13:56:17.602795+00	2026-09-24 13:56:20.551483+00	\N	2026-09-24 13:56:17.603075+00	2026-09-24 13:56:20.551497+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1155f9ef-7241-4aa8-94a8-6d03dbee5663	00000000-0000-4000-9000-000000000038	9MXw1B/VIjphxbrmPuHEB0TlLffFbK9UbWFBAzHxni0=	2026-10-01 13:56:21.00004+00	2026-09-24 13:56:32.188758+00	\N	2026-09-24 13:56:21.000202+00	2026-09-24 13:56:32.188775+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
010e9540-e667-4a29-8d55-89a008a38c10	1a077a8c-4029-8ded-d563-19e9b4bdf301	PhigakrGytgjrZkw5vveFke+7HhHIc5oAaibqBeySMw=	2026-10-01 13:56:32.628179+00	2026-09-24 13:56:43.886879+00	\N	2026-09-24 13:56:32.628338+00	2026-09-24 13:56:43.886896+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dc86c1c9-afd5-4f06-ac65-e484014eaf9e	00000000-0000-4000-9000-000000000017	Hgp5o9ib+FwwnxMmsERyJqZKLuigeQAG6WSjYiZfwPE=	2026-10-01 13:56:44.324022+00	2026-09-25 04:33:23.951697+00	\N	2026-09-24 13:56:44.324162+00	2026-09-25 04:33:23.977904+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1f352908-5cc1-4eae-b724-e6e509ce33a6	00000000-0000-4000-9000-000000000017	wGmXY815SzciZJi0k7LO1BPW5PNAEb/WiLrQbt7kbyw=	2026-10-02 04:33:23.974712+00	2026-09-25 04:34:17.636554+00	\N	2026-09-25 04:33:23.977904+00	2026-09-25 04:34:17.63762+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f42add20-30c6-45d8-97a2-e8454591fb17	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	WcSCZwQ8L8NNmP7oLOgVGvC9zlsTSYqhP4Ker2l70Z8=	2026-10-01 14:00:08.767616+00	2026-09-25 04:34:32.688091+00	\N	2026-09-24 14:00:08.767781+00	2026-09-25 04:34:32.688565+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
36932913-8197-495f-a3dc-c44a58b38431	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	poqcsqoB+juQMlX/3kGI+DyTQlQJ2Ufn1Haz42ewFKs=	2026-10-02 04:34:32.688445+00	2026-09-25 04:35:18.816119+00	\N	2026-09-25 04:34:32.688565+00	2026-09-25 04:35:18.81658+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d375dc18-99cd-4530-a7b5-043fdda29c16	00000000-0000-4000-9000-000000000017	74HdN7QavRavaxkC7CkU+OIeyqtB4ysZA/xdeEEe91o=	2026-10-02 04:34:17.637322+00	2026-09-25 05:11:50.859689+00	\N	2026-09-25 04:34:17.63762+00	2026-09-25 05:11:50.882421+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
573bc169-b02c-41e6-86a0-97fdfa11719b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	pfuIg+1z+6PKdtxAzg6Sa908gkbcp8NuhbGA41hjYe8=	2026-10-02 04:41:38.568739+00	2026-09-25 05:13:22.169019+00	\N	2026-09-25 04:41:38.568957+00	2026-09-25 05:13:22.169547+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a1c2600a-5029-4ba0-b403-80530ac4163b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	7qhAJn98lfqMA6nJBs2E8rJwOOiHN34DD3vzsOAgO98=	2026-10-02 05:13:22.169354+00	2026-09-25 05:13:35.579022+00	\N	2026-09-25 05:13:22.169547+00	2026-09-25 05:13:35.579426+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ab2fabe0-bf3b-4438-917a-3f422414ead3	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	xx3VCjknTd8one3LvzDIjCkw5TAZdLcZJYfrJBj4L60=	2026-10-02 04:35:18.816456+00	2026-09-28 05:33:42.765932+00	\N	2026-09-25 04:35:18.81658+00	2026-09-28 05:33:42.766259+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6761772f-9d71-4418-88aa-649e14e0874f	00000000-0000-4000-9000-000000000017	UNWLLYOtQrt4LishaM65zfruXMRjxnR3b79ahzmrdnc=	2026-10-02 05:11:50.877956+00	2026-09-25 05:15:03.303858+00	\N	2026-09-25 05:11:50.882421+00	2026-09-25 05:15:03.30388+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d98afed2-e8db-4602-866e-4671238189ae	dc139a9d-b996-7354-6c27-72659ea2fd59	8/jNTxlCM9smy4PC8ePFTuBs5li1p85qLyy0QMd/3zE=	2026-10-02 05:15:03.832903+00	2026-09-25 05:18:25.309866+00	\N	2026-09-25 05:15:03.833096+00	2026-09-25 05:18:25.30991+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bbc8c6ea-cbb5-440f-a4ae-36c0fafce6ea	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	wiFsp2oyOwRz6HbSrpgwKi4orsz9QAxuTBLEpCA6qZc=	2026-10-02 05:13:35.579294+00	2026-09-25 05:18:25.753967+00	\N	2026-09-25 05:13:35.579426+00	2026-09-25 05:18:25.754419+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9fc3f492-4081-4c76-b1ec-619f5400fc3b	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GG3Oratqh2UqHq1i2qDUAHJATgUy8c0KLqae/OAmgg8=	2026-10-02 05:18:25.754223+00	2026-09-25 05:21:31.427945+00	\N	2026-09-25 05:18:25.754419+00	2026-09-25 05:21:31.428404+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
79868f9f-72f4-4e31-89bd-6c099e0b5c03	a0000000-0000-0000-0000-000000000032	ETT/VTx1FbM7jr+QJ9jSURlN/9etgrLQ2DZ2k3Z0nu8=	2026-10-02 05:13:45.701595+00	2026-09-25 05:21:47.107724+00	\N	2026-09-25 05:13:45.701861+00	2026-09-25 05:21:47.108419+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3f8593e5-e8d8-4c87-9663-c8c74c632141	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	d4AylWzAgE+aZKNUR34Oh1vhyeo09f2Q0KaSi90NalI=	2026-10-02 05:21:31.428247+00	2026-09-25 05:22:08.360087+00	\N	2026-09-25 05:21:31.428404+00	2026-09-25 05:22:08.3601+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
2a45ce17-b282-4a0d-977f-a940307a3ed3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	ff16xInKHp+Qx2K/5vQPLolTUIe96QziFMKe1ZzloxY=	2026-10-02 05:22:08.761633+00	2026-09-25 05:24:16.926641+00	\N	2026-09-25 05:22:08.761885+00	2026-09-25 05:24:16.927531+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
bd29d872-d306-46bf-8eda-b953f0b631c6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	pVd+fqQDzowp+GnBzEXKuD4fLUagLhyPV+lKAinbkmg=	2026-10-02 05:24:16.927253+00	2026-09-25 05:24:19.215331+00	\N	2026-09-25 05:24:16.927531+00	2026-09-25 05:24:19.215344+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
af94833d-1d09-4b97-b90e-0403674c9718	a0000000-0000-0000-0000-000000000032	E1W6jhFerNgm/6VOEotEgN6ZXHVKnDC4Co2wLbD9cXo=	2026-10-02 05:21:47.108315+00	2026-09-25 05:24:19.65485+00	\N	2026-09-25 05:21:47.108419+00	2026-09-25 05:24:19.655276+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1b1951f3-0d8a-4249-9b6f-7bacce4fca33	a0000000-0000-0000-0000-000000000032	heOOJS/dlw2qWxMbgLXlLTCZlA7r7k5RIpavOWGte6Q=	2026-10-02 05:24:19.655149+00	2026-09-25 05:24:21.576393+00	\N	2026-09-25 05:24:19.655276+00	2026-09-25 05:24:21.576432+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
537bf39f-2c52-4935-85b9-dfa0f19f6ab6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	o2XcR7tb+mlF32Ean6YD5Sc7ruTy369IKn9SnMe1rxY=	2026-10-02 05:24:22.022405+00	2026-09-25 05:27:15.499473+00	\N	2026-09-25 05:24:22.022564+00	2026-09-25 05:27:15.499852+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
484404ab-1f15-4ab3-8813-ccbf3cc60d94	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9ehGOiqtLS2NRdrwVja6qY5BJi6bC3uO/aaiRZ7ItIA=	2026-10-02 05:27:15.499727+00	2026-09-25 05:28:22.317138+00	\N	2026-09-25 05:27:15.499852+00	2026-09-25 05:28:22.317513+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
832b6b7f-4723-4a2b-96e4-b12bc6fe7511	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3feLShHWvk19aQtfa13oaTXqDNBAdQCMtp+glu0C9Lo=	2026-10-02 05:28:22.317384+00	2026-09-25 05:45:27.4983+00	\N	2026-09-25 05:28:22.317513+00	2026-09-25 05:45:27.500037+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ba34e1c3-cbcb-40ac-92b8-281c794e54d1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	IxUeDiQUUvqNx0alZOAJHE4Vp+mPQCHNtD+Fg2TXPPY=	2026-10-02 05:45:27.499415+00	2026-09-25 06:05:09.944772+00	\N	2026-09-25 05:45:27.500037+00	2026-09-25 06:05:09.944856+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
b4198ae3-b761-49af-9730-b10a98bbb9b9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	fzcrxCV+NNxk8e8qeIYZg49LPZ5eCgOHnuYh3ZBJ6So=	2026-10-02 06:05:10.400189+00	2026-09-25 06:10:06.532961+00	\N	2026-09-25 06:05:10.400852+00	2026-09-25 06:10:06.533737+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
de1c4cf0-e3fb-4732-b71e-86109769d2a6	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	L18ZuP8leQ0YChTiy775dJ9cGZX8yZvcegDEJohNU/o=	2026-10-02 06:10:06.533552+00	2026-09-25 07:54:15.726857+00	\N	2026-09-25 06:10:06.533737+00	2026-09-25 07:54:15.727667+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
aa956101-9ffb-4789-9770-c99184efefd1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	HkdPgFJtsWUJDcFjic479D0eaZ2LejDH9SQzUszczDo=	2026-10-02 07:54:15.727302+00	2026-09-25 07:54:53.849229+00	\N	2026-09-25 07:54:15.727667+00	2026-09-25 07:54:53.849675+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
c2e79530-88eb-466e-8d5a-92149ba5778c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	tyuYEQJnH583gFpbmUCGuXlBd+MMsVqhEEiVBGU8TiM=	2026-10-02 07:54:53.849517+00	2026-09-25 08:02:35.644465+00	\N	2026-09-25 07:54:53.849675+00	2026-09-25 08:02:35.645275+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
1f90324c-3ab5-4866-8640-d99b4d349364	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3Rv1ED1jcbdhj6fch7m20kRfC7H7aikZfLrfKhMI5qU=	2026-10-02 08:02:35.644912+00	2026-09-25 08:15:18.541949+00	\N	2026-09-25 08:02:35.645275+00	2026-09-25 08:15:18.54364+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
6f79383e-3584-4e33-92bb-b46052149e05	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	WM7qBgyQDOUyVUC77NdmkwFGX5ZmI548Db/GFI6+tEM=	2026-10-02 08:15:18.542924+00	2026-09-28 05:33:43.537837+00	\N	2026-09-25 08:15:18.54364+00	2026-09-28 05:33:43.579475+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
fa04e2cf-45fa-43cf-9b3c-3b58a0a552eb	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	vywspvN1CAimjKUZ1UPI1fEZDMl5W+K/GTZZnHB+LjE=	2026-10-05 05:33:43.565289+00	2026-09-28 05:35:16.500547+00	\N	2026-09-28 05:33:43.579475+00	2026-09-28 05:35:16.50329+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
31610058-5dc2-459d-be24-7c91a5d319f2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bWnBfxXR9U76/xWMdIbQikNwCN2hq55KkhMBisimZJM=	2026-10-05 05:35:16.501475+00	2026-09-28 05:41:18.359369+00	\N	2026-09-28 05:35:16.50329+00	2026-09-28 05:41:18.394414+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
77bfd0f5-ba06-4c21-9d8c-5274df430496	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	zBI1/U6hAkC95SKRRikS16A1QqN3mCZPdPJUA2xW7Ug=	2026-10-05 05:41:18.379388+00	2026-09-28 05:43:51.867764+00	\N	2026-09-28 05:41:18.394414+00	2026-09-28 05:43:51.867917+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e4934baa-f412-4fc0-89ff-42fbef7aa29c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9zSShyssg7mJsM8fT7OcMXNMJKcoKtLtcBotA3RehYU=	2026-10-05 05:43:52.515677+00	2026-09-28 05:49:22.679586+00	\N	2026-09-28 05:43:52.517373+00	2026-09-28 05:49:22.679648+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
67f30da1-7331-4b93-9aa9-952ea0639560	00000000-0000-4000-9000-000000000039	3uW3H+UNOTw8NUWEhJxSHur8hyqjAn5UZW5ncrWyni4=	2026-10-05 05:49:23.175731+00	2026-09-28 05:50:23.442518+00	\N	2026-09-28 05:49:23.176008+00	2026-09-28 05:50:23.442541+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3ffe2f9c-4541-4fec-8c9b-5bf4efa106af	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	A6Fr7Cq1gR1S3PYvrFAf3+N/tEZ0H65IXTwL8G9E1K8=	2026-10-05 05:55:00.066164+00	2026-09-28 05:55:53.694698+00	\N	2026-09-28 05:55:00.066423+00	2026-09-28 05:55:53.69509+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5d16f24d-8fcf-40df-ac0d-7e5804c2f2c1	2bca17e7-5b71-8ac3-6c86-440cb3b75bab	U/gS7rEiloOy1Eqw45X1QqQcT/Gko+jIVmP7gLOziJk=	2026-10-05 05:55:53.694978+00	\N	\N	2026-09-28 05:55:53.69509+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c13b5c13-8bf7-4261-9f95-74325dca7ee2	00000000-0000-4000-9000-000000000042	O5BPm41NN09aRBc6+0d9fV+MU+m76h7H9mzS3i9NPoE=	2026-10-05 06:13:57.927456+00	2026-09-28 06:14:37.149157+00	\N	2026-09-28 06:13:57.92769+00	2026-09-28 06:14:37.149214+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f8bb85c1-27c4-4956-84f6-cf8235c40f71	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	EBeGN99DWIh4T/pYDG6ydfKaFD6+un0XjyMiuUgY1lc=	2026-10-05 05:56:12.548145+00	2026-09-28 06:06:11.185887+00	\N	2026-09-28 05:56:12.54834+00	2026-09-28 06:06:11.185931+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3923f63c-8063-47bd-a364-91a9e60fd9e5	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	1qB7syVGSVLMVllztS+6gaYt2xQbM8QYq9FJ9Pu7AJI=	2026-10-05 05:50:24.08177+00	2026-09-28 06:12:06.329722+00	\N	2026-09-28 05:50:24.081993+00	2026-09-28 06:12:06.329733+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
cbb7b3b6-6a91-484d-88d8-22eeda18d065	40517b71-5e62-182e-73b5-d4070e20a3c2	L69EOPoVzesYR1Su6yogW02Pcn5e3nYbEb50e6E5XHw=	2026-10-05 06:12:06.768882+00	2026-09-28 06:12:37.808829+00	\N	2026-09-28 06:12:06.76909+00	2026-09-28 06:12:37.80884+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
17dff275-e7ae-42de-ae67-216e7e429e7e	304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	N3S16AJGC9fw25R5FBkdn2v1zSuXhL12esiH2DVr/xw=	2026-10-05 06:12:38.240555+00	2026-09-28 06:13:07.627959+00	\N	2026-09-28 06:12:38.240717+00	2026-09-28 06:13:07.628002+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5ba48361-d1d9-4c1b-afe8-2fa60aa16d71	00000000-0000-4000-9000-000000000045	gA3Wm2uWx4hyegBrMdz9ujkP4CDZ//KfbH801hnjimg=	2026-10-05 06:13:08.063941+00	2026-09-28 06:13:57.494997+00	\N	2026-09-28 06:13:08.064089+00	2026-09-28 06:13:57.495009+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9e306c70-8e22-4a5b-b13a-9cfcd26fe376	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	PhtgpDV/2g6nqmM6Ay28vcvGfeMAe/qRShk6+O34XZc=	2026-10-05 06:06:11.664315+00	2026-09-28 07:10:28.289582+00	\N	2026-09-28 06:06:11.664649+00	2026-09-28 07:10:28.294951+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
43ad8163-ab4d-4daa-b3a9-79e490c800c7	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	teq6ny6Iuc7/QAin9n7mLIEtoNXF6GaGU9SChcptiOQ=	2026-10-05 07:10:28.292452+00	2026-09-28 07:15:50.668641+00	\N	2026-09-28 07:10:28.294951+00	2026-09-28 07:15:50.671424+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9168ff9d-3050-41f6-95f8-b6a77455fa35	00000000-0000-4000-9000-000000000045	4XBk83wJKSjujWgVn20yOrPY4PVl1MlbIUsrIusC6MA=	2026-10-05 06:14:37.498865+00	2026-09-28 07:29:24.282404+00	\N	2026-09-28 06:14:37.499084+00	2026-09-28 07:29:24.284302+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
321ccec5-82a8-4e8d-b73f-b3e72ca88b33	00000000-0000-4000-9000-000000000045	2EXbCFXpSeIXjZ7vuE3h3N5Q/UMGYT+si0uzZggnRaY=	2026-10-05 07:29:24.28353+00	2026-09-28 07:29:31.937799+00	\N	2026-09-28 07:29:24.284302+00	2026-09-28 07:29:31.93781+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
513b0e18-e99f-4e2b-b014-c7bab41087f1	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	bfFdCYPWg9YAT6+cg/0v/aBdL2IgirdHEe1iKbN/G90=	2026-10-05 07:15:50.670658+00	2026-09-28 07:29:32.578009+00	\N	2026-09-28 07:15:50.671424+00	2026-09-28 07:29:32.579365+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d5ac0388-ea15-45e8-90a7-b7274f221c83	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	0BggGZM4nT9rTSN7tmn3WuEDu8ci4jZFPRz0j7SYWHk=	2026-10-05 07:29:32.578823+00	2026-09-28 07:30:05.118802+00	\N	2026-09-28 07:29:32.579365+00	2026-09-28 07:30:05.119633+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a07ddfb7-3d54-4b89-83f5-9af8c2aa45d4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9ql0J/R4Tm8Rd6xf6EzJfIGf8C4bPEK8assKS4noEmI=	2026-10-05 07:30:05.119347+00	\N	\N	2026-09-28 07:30:05.119633+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: repository; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repository ("Id", "FileName", "Category", "Size", "LastUpdated", "UploadedBy", "FilePath", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
3df9fd80-f457-4424-afe9-7b73b92f8759	Pan Card.jpeg	IMP	144850	2026-09-02 10:20:17.729048+00	Admin User	IMP Templates/20260902_102017_725_Pan_Card.jpeg	2026-09-02 10:20:17.729382+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a63ceac9-a10b-4aca-8584-1953a0a550e8	Resume (3) (1).pdf	Tech	112021	2026-09-02 11:15:59.470845+00	Admin User	Tech. SOPs/20260902_111559_469_Resume__3___1.pdf	2026-09-02 11:15:59.471482+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
65e9ee07-d1ae-4c46-8d3a-02d40f65e050	Issues.xlsx	PMS	16490	2026-09-02 12:02:50.298683+00	Admin User	PMS. SOPs/20260902_120250_297_Issues.xlsx	2026-09-02 12:02:50.299125+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
718b816a-0cb3-48dc-9687-468f4814fb65	Abstract 5716 & 5720.docx	IMP	14866	2026-09-02 12:03:52.717045+00	Admin User	IMP Templates/20260902_120352_716_Abstract_5716___5720.docx	2026-09-02 12:03:52.717377+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
71b01b98-a936-4f80-a406-ccf5f0f060b0	airQualityAbstactBoth.pdf	Tech	69207	2026-09-03 07:05:00.559386+00	Admin User	Tech. SOPs/20260903_070500_558_airQualityAbstactBoth.pdf	2026-09-03 07:05:00.559812+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: repository_activity_logs; Type: TABLE DATA; Schema: public; Owner: -
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
42e77664-6b61-460c-b6c7-a2e9f8a84932	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	action-center	Action Center	\N	\N	action-center.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 16:16:27.51142+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6fcb0cb4-f657-41b7-aa02-c7e5f6c961b3	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	\N	\N	projects:read	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 16:16:27.51142+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bb07b6db-6e82-4d0e-8bfe-fe780955635b	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	resources	Resources	\N	\N	resources:read	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 16:16:27.51142+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") FROM stdin;
a0000000-0000-0000-0000-000000000001	Admin	["dashboard.view", "action-center.view", "projects.view", "projects:read", "projects.create", "projects:write", "projects.edit", "projects:write", "projects.delete", "projects:write", "projects.close", "projects:close", "projects.approve", "projects.assign", "projects.export", "projects.import", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "issues:raise", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health.manage", "issues:manage", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "projects.pmo.view", "projects.pmo.manage", "projects.prerequisite.view", "projects.prerequisite.manage", "projects.services-deliverables.view", "projects.services-deliverables.manage", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "invoices:raise", "invoices:payment", "projects.assigned-projects.view", "reports.view", "reports:read", "reports.export", "reports.finance.view", "resources.view", "resources:read", "resources.manage", "resources:manage", "resources.directory.view", "resources.kpi.view", "customers.view", "clients:read", "customers.create", "clients:write", "customers.edit", "clients:write", "customers.delete", "clients:write", "customers.approve", "clients:approve", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "timesheets:monitor", "my-team.timesheet-approval.approve", "timesheets:approve", "my-team.timesheet-approval.reject", "timesheets:approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit", "my-team.my-timesheet.edit", "wbs.view", "wbs:read", "wbs.allocate", "wbs:allocate", "approvals.view", "approvals:manage", "approvals.approve", "timesheets:approve", "approvals.reject", "timesheets:approve", "portfolio.view", "settings.view", "settings.roles.view", "settings.roles.manage", "roles:manage", "settings.permissions.view", "settings.permissions.manage", "users:manage", "settings.audit.view", "audit:read"]	2026-09-25 04:41:26.317908+00	2026-09-25 05:11:29.711189+00	\N	\N	\N	Admin	Super-admin — full access to every module, submodule and action.	t	t
cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	["dashboard.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "reports.view", "reports.export", "reports.finance.view", "reports.po-tracker", "reports.invoice-tracker", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "clients:read", "invoices:raise", "invoices:payment", "reports:read"]	2026-08-07 07:49:59.669429+00	2026-09-24 12:13:06.784762+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Accounts	Invoicing schedule, milestone payments, PO tracking, financial reports.	t	t
f5c742d1-e0cc-4bf8-b860-a673ac407393	R&D Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "repository.view", "repository.upload", "repository.download", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	R&D - Team member	Python/Tool development, sprint tasks, code repository, own timesheets.	t	t
62a927b7-9fd8-461a-b64e-1aa441eeba4d	Chief Executive Officer	["dashboard.view", "action-center.view", "projects.view", "projects:read", "projects.create", "projects:write", "projects.edit", "projects:write", "projects.delete", "projects:write", "projects.close", "projects:close", "projects.approve", "projects.assign", "projects.export", "projects.import", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "issues:raise", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health.manage", "issues:manage", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "projects.pmo.view", "projects.pmo.manage", "projects.prerequisite.view", "projects.prerequisite.manage", "projects.services-deliverables.view", "projects.services-deliverables.manage", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "invoices:raise", "invoices:payment", "projects.assigned-projects.view", "reports.view", "reports:read", "reports.export", "reports.finance.view", "resources.view", "resources:read", "resources.manage", "resources:manage", "resources.directory.view", "resources.kpi.view", "customers.view", "clients:read", "customers.create", "clients:write", "customers.edit", "clients:write", "customers.delete", "clients:write", "customers.approve", "clients:approve", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "timesheets:monitor", "my-team.timesheet-approval.approve", "timesheets:approve", "my-team.timesheet-approval.reject", "timesheets:approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit", "my-team.my-timesheet.edit", "wbs.view", "wbs:read", "wbs.allocate", "wbs:allocate", "approvals.view", "approvals:manage", "approvals.approve", "timesheets:approve", "approvals.reject", "timesheets:approve", "portfolio.view", "settings.view", "settings.roles.view", "settings.roles.manage", "roles:manage", "settings.permissions.view", "settings.permissions.manage", "users:manage", "settings.audit.view", "audit:read"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	CEO	Global executive visibility, business analytics, all approvals.	t	t
a5bfe265-981a-4723-b7bb-6ddc389db7f0	Chief Operating Officer	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.budget.view", "projects.health.view", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "reports.finance.view", "reports.sales", "reports.wbs-tracker", "reports.po-tracker", "reports.invoice-tracker", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.approve", "repository.view", "repository.download", "my-team.dashboard.view", "approvals.view", "approvals.approve", "approvals.reject", "wbs.view", "portfolio.view", "clients:read", "clients:approve", "projects:read", "projects:close", "issues:manage", "reports:read", "resources:read", "approvals:manage"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	COO	Operational oversight across all departments and projects.	t	t
66e48815-4d4f-41d0-9c5f-26a7b7ba296c	Chief Technology Officer	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "repository.view", "repository.upload", "repository.download", "my-team.dashboard.view", "portfolio.view", "projects:read", "reports:read", "resources:read"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	CTO	Technical architecture, R&D governance, engineering oversight.	t	t
b552183f-2695-41f9-860e-16d5fe94c4aa	IT Administrator	["dashboard.view", "resources.view", "resources.directory.view", "resources.manage", "settings.view", "settings.masters.manage", "repository.view", "repository.upload", "repository.download", "resources:read", "resources:manage"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	IT Admin	IT infrastructure, corporate email domains, device & user setup.	t	t
bb568e26-548b-4ca5-9221-fefb9c9143b3	Human Resources	["resources.view", "resources.directory.view", "resources.manage", "resources.kpi.view", "resources.profile.org", "resources.profile.employment", "resources.profile.skills", "resources.profile.finance", "repository.view", "repository.upload", "repository.download", "settings.view", "settings.masters.manage", "resources:read", "resources:manage"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	HR	Employee directory, onboarding/offboarding, skills, KPI/rating tabs.	t	t
914d8500-03b6-4a43-a250-244effca1cf1	Sales Manager	["dashboard.view", "projects.view", "projects.create", "projects.overview.view", "projects.overview.edit", "projects.health.view", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.create", "customers.edit", "customers.assign", "customers.approve", "reports.view", "reports.export", "reports.sales", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:read", "clients:write", "clients:approve", "projects:write", "wbs:read", "timesheets:submit"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Sales Manager	Customer onboarding, client management, proposal drafting, pipeline.	t	t
7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	Sales Team Member	["dashboard.view", "projects.view", "projects.overview.view", "customers.view", "customers.create", "customers.edit", "reports.view", "reports.sales", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:read", "clients:write", "timesheets:submit"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Sales team member	Proposal drafting, pipeline viewing, sales reports.	t	t
2acf8b94-0756-4db8-bb6f-8372ac04a2d1	Project Management Office	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.budget.view", "projects.pmo.view", "projects.pmo.manage", "projects.health.view", "projects.health.manage", "reports.view", "reports.export", "reports.wbs-tracker", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "approvals.view", "wbs.view", "wbs.allocate", "clients:read", "projects:read", "wbs:read", "wbs:allocate", "timesheets:monitor", "issues:manage", "resources:read", "reports:read", "approvals:manage"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	PMO	Global governance, WBS allocation, timesheet monitoring, approvals.	t	t
a5023c9e-367f-41e1-ba02-bdb2929edc89	Engagement Manager (EM)	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.edit", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-08-07 07:49:59.669429+00	2026-09-24 12:13:06.784762+00	\N	\N	\N	EngagementManager	Customer relationship, client project overview, health & escalations.	t	t
f29af015-7833-4f9a-ac57-6fbef5bf91ec	Intern	["projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "repository.view", "repository.download", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Intern	Read-only training access to assigned tasks and document repository.	t	t
c787fe3b-4b33-40ee-8794-c1148202f81a	Testing Head of Department	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Testing HOD	Complete oversight of Testing department, health escalations, approvals.	t	t
efc1df20-ca04-44a6-87b2-7cae1ff50a88	Testing Senior Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Testing Senior Manager	Delivery oversight across testing projects, QA resource management.	t	t
29ad5710-1621-4c24-ac75-dedfc168ba1a	Testing Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Testing-Manager	QA project tasks, test deliverables, defect tracking, QA timesheets.	t	t
a3793f87-7f3c-41a1-a675-236fc1b710ab	Testing Team Leader	["dashboard.view", "projects.view", "projects.overview.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Testing-Team Leader	Test run execution, defect triage, test task assignment, timesheet review.	t	t
92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "projects.health.raise-issue", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Testing-Team Member	Test execution, defect logging, task status updates, own timesheets.	t	t
64c49f37-a38a-46a6-9622-7427f1501658	Consulting Head of Dept	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Consulting-HOD	Complete oversight of Consulting department, GRC engagements.	t	t
4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	Consulting Senior Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Consulting-Senior Manager	Delivery oversight across consulting & audit projects.	t	t
e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	Consulting Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Consulting-Manager	GRC audit projects, client deliverables, audit timesheet approvals.	t	t
701aaa2c-a899-4def-bf5f-e17511874409	Consulting Team Leader	["dashboard.view", "projects.view", "projects.overview.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Consulting-Team Leader	Senior audit execution, audit task assignment, timesheet review.	t	t
768a11f9-ded7-4f6f-ba86-073e279255d9	Consulting Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "projects.health.raise-issue", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	Consulting-Team member	Audit checklists, evidence collection, task updates, own timesheets.	t	t
3d068c2f-d0a1-4045-bad9-0f3a43efec4f	SOC Head of Department	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	SOC-HOD	Complete oversight of SOC/Operations, 24/7 monitoring governance.	t	t
b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	SOC Senior Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	SOC-Senior Manager	Operations delivery oversight, client SLA tracking, incident reviews.	t	t
111cc3cd-6d35-43ce-be91-dde90d3d4015	SOC Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	SOC-Manager	Incident management, shift scheduling, operations timesheets.	t	t
aba61e5b-422a-4461-b9da-8dba8f6d3f85	SOC Shift / Team Leader	["dashboard.view", "projects.view", "projects.overview.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	SOC-Team Leader	Shift oversight, alert escalation, task assignments, timesheet review.	t	t
1a62b1f8-1810-464d-a67b-168d7e419827	SOC Team Member	["dashboard.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "projects.health.raise-issue", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "issues:raise", "timesheets:submit"]	2026-09-24 12:13:06.784762+00	\N	\N	\N	\N	SOC-Team Member	SIEM monitoring, alert analysis, shift logs, own timesheets.	t	t
\.


--
-- Data for Name: sub_ventures; Type: TABLE DATA; Schema: public; Owner: -
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
4af18ff4-3a01-44e4-b050-9e209643182b	89714d99-8107-4cd0-8095-6da7823cb767	sub cust 1	2026-09-02 07:09:23.899459+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	NA	\N	\N
829211dc-774e-4389-a6c8-b29372b3dde7	08f36c9b-9833-4008-9a58-9b69b5c491e3	SV1	2026-09-02 07:54:30.517916+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
3a681001-620a-4190-bd6c-1ee7131f2c3f	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	ABCDEFG	2026-09-02 10:24:57.074997+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	dfksfklsfkslmf	\N	\N
6cec1e8f-a65e-4c11-8fc3-265376ffe0cc	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	XXXXXXXXX	2026-09-02 11:47:36.563695+00	2026-09-02 11:47:36.954412+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	gkhkjhjk	Issues.xlsx	KYC/20260902_114736_876_AutoDrive_Systems_XXXXXXXXX_Issues.xlsx
be9fd5f1-6786-4caa-bf68-e9ee4ab4c5a2	d35873d4-c12c-40c3-a66e-78d9f296ef2b	Testing-sub	2026-09-08 13:55:06.603779+00	2026-09-08 13:55:06.914341+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Hello this is the note about the sub-venture	IN-2026-27-C004-P003.xlsx	KYC/20260908_135506_891_Testing_Testing-sub_IN-2026-27-C004-P003.xlsx
6fbfe113-eb06-42ca-b34e-e3c75139678b	d35873d4-c12c-40c3-a66e-78d9f296ef2b	Testing-sub2	2026-09-09 07:02:12.586676+00	2026-09-09 07:02:13.087415+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	This is the note of subventure	Sahil Sanjay Lad - Interns Offer Letter.pdf	KYC/20260909_070213_046_Testing_Testing-sub2_Sahil_Sanjay_Lad_-_Interns_Offer_Letter.pdf
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
fc1bcd4a-3941-4ed3-bd3d-e44fd66e0123	fc69ab55-e40d-497a-80da-fc1ac3280976	p1	p1-t1	Core Banking Modernization	External Network Penetration Testing	approved	2026-09-28 06:13:48.867216+00	2026-09-28 06:14:16.877611+00	00000000-0000-4000-9000-000000000045	00000000-0000-4000-9000-000000000042	\N
7cf79373-5a35-43fa-a852-f93c7c3d8e1c	821a978e-a7d1-4372-970b-38e6dae00953	p1	p1-t2	Core Banking Modernization	Web Application Penetration Testing	change_requested	2026-09-28 06:13:17.902008+00	2026-09-28 06:14:28.0263+00	00000000-0000-4000-9000-000000000045	00000000-0000-4000-9000-000000000042	\N
\.


--
-- Data for Name: timesheet_entry_days; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.timesheet_entry_days ("Id", "TimesheetEntryId", "DayIndex", "Hours", "Comment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
03444e4c-223a-4cb9-9e5b-8be56977b36f	7cf79373-5a35-43fa-a852-f93c7c3d8e1c	2	1.0	\N	2026-09-28 06:13:17.902008+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
223f6926-45a6-438b-b9c1-118d01fc1cd0	7cf79373-5a35-43fa-a852-f93c7c3d8e1c	1	2.0	\N	2026-09-28 06:13:17.902008+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
6a4aeeca-4374-405e-98a9-b1efa1388b30	7cf79373-5a35-43fa-a852-f93c7c3d8e1c	4	0.0	\N	2026-09-28 06:13:17.902008+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
8a0f721b-e436-437a-aa22-55eb6829d54d	7cf79373-5a35-43fa-a852-f93c7c3d8e1c	6	0.0	\N	2026-09-28 06:13:17.902008+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
d78fe189-6403-4a1c-b830-17f89288c20f	7cf79373-5a35-43fa-a852-f93c7c3d8e1c	3	0.0	\N	2026-09-28 06:13:17.902008+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
ece846f6-7e3d-4832-b5b4-2aba65d874e0	7cf79373-5a35-43fa-a852-f93c7c3d8e1c	5	0.0	\N	2026-09-28 06:13:17.902008+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
f1e200eb-2432-442d-b92b-42214adc8f88	7cf79373-5a35-43fa-a852-f93c7c3d8e1c	0	1.0	\N	2026-09-28 06:13:17.902008+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
203757cb-2886-4c14-9791-5c805d2f052f	fc1bcd4a-3941-4ed3-bd3d-e44fd66e0123	2	0.0	\N	2026-09-28 06:13:48.867216+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
41614a74-7820-4452-9e8c-3ff3d04c700f	fc1bcd4a-3941-4ed3-bd3d-e44fd66e0123	4	0.0	\N	2026-09-28 06:13:48.867216+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
6ce2e703-6eda-487b-975f-657bb1fc97c6	fc1bcd4a-3941-4ed3-bd3d-e44fd66e0123	0	0.0	\N	2026-09-28 06:13:48.867216+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
97f67d4d-3352-4179-abbd-43b2f2e7eb82	fc1bcd4a-3941-4ed3-bd3d-e44fd66e0123	3	2.0	done	2026-09-28 06:13:48.867216+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
de50cc45-1502-4e88-9216-ab39748ea6cb	fc1bcd4a-3941-4ed3-bd3d-e44fd66e0123	1	2.0	nice	2026-09-28 06:13:48.867216+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
e069a9d9-bc21-4779-9be8-8e8729bf17ac	fc1bcd4a-3941-4ed3-bd3d-e44fd66e0123	6	0.0	\N	2026-09-28 06:13:48.867216+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
f56ff140-f991-4cc9-9374-5dd8dd2e3700	fc1bcd4a-3941-4ed3-bd3d-e44fd66e0123	5	0.0	\N	2026-09-28 06:13:48.867216+00	\N	00000000-0000-4000-9000-000000000045	\N	\N
\.


--
-- Data for Name: timesheets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.timesheets ("Id", "EmployeeId", "WeekStart", "Status", "TotalHours", "SubmittedAtUtc", "ReviewedByEmployeeId", "ReviewedAtUtc", "ReviewComment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
fc69ab55-e40d-497a-80da-fc1ac3280976	00000000-0000-4000-8000-000000000045	2026-10-05	approved	4.0	2026-09-28 06:13:48.867009+00	00000000-0000-4000-8000-000000000042	2026-09-28 06:14:16.877604+00	ok	2026-09-28 06:13:48.867216+00	2026-09-28 06:14:16.877611+00	00000000-0000-4000-9000-000000000045	00000000-0000-4000-9000-000000000042	\N
821a978e-a7d1-4372-970b-38e6dae00953	00000000-0000-4000-8000-000000000045	2026-09-28	change_requested	4.0	2026-09-28 06:13:17.878157+00	00000000-0000-4000-8000-000000000042	2026-09-28 06:14:28.026294+00	not done properly	2026-09-28 06:13:17.902008+00	2026-09-28 06:14:28.0263+00	00000000-0000-4000-9000-000000000045	00000000-0000-4000-9000-000000000042	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users ("Id", "Email", "PasswordHash", "Name", "EmployeeId", "Department", "SubDepartment", "Avatar", "Designation", "IsActive", "MustChangePassword", "RoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "FailedLoginAttempts", "LastLoginAtUtc", "LockedUntilUtc", "PasswordChangedAtUtc", "AuthProvider", "MicrosoftOid") FROM stdin;
00000000-0000-4000-9000-000000000003	kunal.deshmukh@acme.co	$2a$12$exe4HxFANd4IHEQB/TG6kOuWi1LJf6C3qDao.dTwCz0uDLozBEr1K	Kunal Deshmukh	TK-0003	Core	\N	\N	Director and Chief Technology Officer	t	f	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000025	manish.tiwari@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Manish Tiwari	TK-0025	Services - Operations	\N	\N	SOC Consultant - I	t	f	1a62b1f8-1810-464d-a67b-168d7e419827	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000052	tanvi.deshmukh@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Tanvi Deshmukh	TKI-0003	Services - Testing	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000053	ayush.saxena@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Ayush Saxena	TKI-0004	Services - Operations	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	admin@acme.co	$2a$12$VHJZqG.yKOt0ID7Y3wEB3ONt5P74m6MtTwQsnhumP0.bG0wF6almW	Admin User	TK-0004	Functional - IT Administration	\N	AU	IT Admin	t	f	a0000000-0000-0000-0000-000000000001	2026-08-10 12:23:35.786937+00	2026-09-28 07:29:32.579365+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-28 07:29:32.576325+00	\N	\N	Local	\N
00000000-0000-4000-9000-000000000054	simran.kaur@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Simran Kaur	TKI-0005	Services - Operations	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000055	naveen.choudhary@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Naveen Choudhary	TKI-0006	Services - Consulting	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000056	bhavna.patel@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Bhavna Patel	TKI-0007	Services - Consulting	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000057	harsh.wardhan@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Harsh Wardhan	TKI-0008	R&D (Research & Development)	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000058	akash.jain@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Akash Jain	TKI-0009	Functional - Sales	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
2bca17e7-5b71-8ac3-6c86-440cb3b75bab	vikrant@acme.co	$2a$12$hiFFHZkA22q7gI50u73Ime0kiJVdl12.bUaQrGc9wOqZeY0fiiCtS	Vikrant Malhotra	TK-0001	Core	\N	VM	Director and Chief Executive Officer	t	f	62a927b7-9fd8-461a-b64e-1aa441eeba4d	2026-08-07 07:49:59.669429+00	2026-09-28 05:55:53.69509+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-28 05:55:53.69228+00	\N	2026-08-10 06:59:52.170405+00	Local	\N
00000000-0000-4000-9000-000000000008	nikhil.khanna@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Nikhil Khanna	TK-0008	Functional - Sales	\N	\N	Sales Associate	t	f	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000009	pooja.sharma@acme.co	$2a$12$.u2l4NL.DgPXJ65nOMb08uJpOoeGRuRJJOH5JIIJ8NQXfR5hCJXLm	Pooja Sharma	TK-0009	Functional - Sales	\N	\N	Sales Associate	t	f	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 13:56:17.601199+00	\N	\N	Local	\N
00000000-0000-4000-9000-000000000010	rohit.verma@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Rohit Verma	TK-0010	Functional - Sales	\N	\N	Associate Customer Success Representative - I	t	f	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000019	sneha.iyer@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Sneha Iyer	TK-0019	Services - Operations	\N	\N	SOC Lead - I	t	f	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-09-24 11:10:05.618689+00	2026-09-24 11:11:30.66576+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-24 11:11:30.663775+00	\N	\N	Local	\N
40517b71-5e62-182e-73b5-d4070e20a3c2	dhanshree@acme.co	$2a$12$NVdOF2oZSYANeoMh.3kkm.Vs53q1AClhuvj01zhY5SsfmugF.6zNu	Dhanshree Pansare	TK-0002	Core	\N	DS	Director and Chief Operating Officer	t	f	a5bfe265-981a-4723-b7bb-6ddc389db7f0	2026-08-07 07:49:59.669429+00	2026-09-28 06:12:06.76909+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-28 06:12:06.766446+00	\N	2026-08-10 07:02:04.244561+00	Local	\N
00000000-0000-4000-9000-000000000041	manoj.bhatt@acme.co	$2a$12$G7PeYhqrVD9lOne9f5fYceNYB8lWJWQMvmtbrj0SB4Y87AjirbMdG	Manoj Bhatt	TK-0041	Services - Testing	\N	\N	DevSecOps Specialist - II	t	f	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	\N	\N	\N	Local	\N
47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	hr@acme.co	$2a$12$Dwr2x9Cr0bJKNeBceNq2.uF/qT9ugV37R/AJzR2PSXv9ZF6vns/km	HR User	TK-0006	Functional - HR	\N	HU	HR Head	t	f	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-08-10 12:23:35.786937+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-11 07:42:37.919998+00	\N	\N	Local	\N
49c4e7da-23ec-aab1-9fdf-61dd23764d10	nikhil@acme.co	$2a$12$sME6TwvQ1FS5b04Bw.T7yukN08K7rTWYd8uit.cHMflByQFtu3R.2	Nikhil Rao	TK-0020	Services - Operations	\N	NR	SOC Lead - II	t	f	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-08-07 07:49:59.669429+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	\N	\N	\N	Local	\N
730809c0-fc01-a664-03ca-28e0e32d0393	sales@acme.co	$2a$12$7XLePs7kkbk1ncolmZngFumfZomtQaLgCIEJVmsOZWJWNCMx5luEi	Sales User	TK-0007	Functional - Sales	\N	SU	Sales Manager	t	f	914d8500-03b6-4a43-a250-244effca1cf1	2026-08-10 12:23:35.786937+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 13:53:59.212868+00	\N	\N	Local	\N
a0000000-0000-0000-0000-000000000032	itadmin@acme.co	$2a$12$Dxjtrvp5Np25swUwHzC1I.jsjz0I.dLEAxkv67Gmo0XB3g2yixt7i	IT Admin User	TK-0004-IT	\N	\N	IT	\N	t	f	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-09-25 04:41:26.328885+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-25 05:24:19.653729+00	\N	\N	Local	\N
a37e30de-15f3-bf1e-fa9f-4a98da9033ab	vikram@acme.co	$2a$12$OhOw4XNsMKYdcnbnhTKyFeYjaqlq.nWVw15.bRpqciYMSHTIeLEA.	Vikram Shah	TK-0018	Services - Operations	\N	VS	SOC Manager	t	f	111cc3cd-6d35-43ce-be91-dde90d3d4015	2026-08-07 07:49:59.669429+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 11:19:07.946068+00	\N	\N	Local	\N
00000000-0000-4000-9000-000000000035	swati.mishra@acme.co	$2a$12$M0VvoR02D2LuSuWEbNusROE07ZoSkvdP3I7OaBHl3/3.zm8xqd.fu	Swati Mishra	TK-0035	Services - Consulting	\N	\N	GRC Auditor - IV	t	f	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000037	girish.shenoy@acme.co	$2a$12$XmFZ/OKL7ZSg7zK7t6z4beo7Nri4xNOZQVETGBBGWiyad2AqRwnxm	Girish Shenoy	TK-0037	Services - Testing	\N	\N	Testing HOD	t	f	c787fe3b-4b33-40ee-8794-c1148202f81a	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000038	suresh.pillai@acme.co	$2a$12$e7lsF.6P7Pg/ElwebBHy0eR0QOakiAlZVgcrgGHEmBCGerOLslO0i	Suresh Pillai	TK-0038	Services - Testing	\N	\N	Manager - I	t	f	efc1df20-ca04-44a6-87b2-7cae1ff50a88	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 13:56:20.998402+00	\N	\N	Local	\N
00000000-0000-4000-9000-000000000022	karthik.bose@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Karthik Bose	TK-0022	Services - Operations	\N	\N	SOC Analyst - I	t	f	1a62b1f8-1810-464d-a67b-168d7e419827	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000023	ankit.verma@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Ankit Verma	TK-0023	Services - Operations	\N	\N	SOC Analyst - II	t	f	1a62b1f8-1810-464d-a67b-168d7e419827	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000024	aditya.reddy@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Aditya Reddy	TK-0024	Services - Operations	\N	\N	SIEM Admin - II	t	f	1a62b1f8-1810-464d-a67b-168d7e419827	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
1a077a8c-4029-8ded-d563-19e9b4bdf301	aarav@acme.co	$2a$12$tbBQlFF0/pPt1PQefDhF8e09ArbgZdew.stmBN9x1UgW9cXEumWJG	Aarav Mehta	TK-0028	Services - Consulting	\N	AM	Principal Manager - I	t	f	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	2026-08-07 07:49:59.669429+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 13:56:32.626607+00	\N	\N	Local	\N
e7554ba2-e546-93ce-1e88-a073badd78a2	riya@acme.co	$2a$12$qS633uEw1Xe7u6OUcMVaaeuttNh4NL2Lm/47L7Ge98ZshB6d94U3S	Riya Kapoor	TK-0013	Functional - Project Management	\N	RK	Engagement Manager	t	f	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-08-07 07:49:59.669429+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 11:11:24.128899+00	\N	2026-08-07 07:57:03.565302+00	Local	\N
00000000-0000-4000-9000-000000000039	alok.kumar@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Alok Kumar	TK-0039	Services - Testing	\N	\N	Associate Manager - III	t	f	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-09-24 11:10:05.618689+00	2026-09-28 05:49:23.176008+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-28 05:49:23.173271+00	\N	\N	Local	\N
00000000-0000-4000-9000-000000000016	rajesh.kadam@acme.co	$2a$12$v1FroLV/fpT8ZXe1KZ2IN.A9YzOu0jScQU078SXsNUAuNCLR/.Y/W	Rajesh Kadam	TK-0016	Services - Operations	\N	\N	SOC HOD	t	f	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000017	deepak.sawant@acme.co	$2a$12$k5o0a4d.U3nE8NtLPIhzoOmrKqkL74dUzuQCBuPZ/Bejs2UnhwfTq	Deepak Sawant	TK-0017	Services - Operations	\N	\N	SOC Senior Manager	t	f	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 13:56:44.322377+00	\N	\N	Local	\N
00000000-0000-4000-9000-000000000021	amit.pandey@acme.co	$2a$12$a.v.FCLNHLvU0jlrmVtIiOIm0dabkxa3OiiRr4i6LC7UBJf2HubbC	Amit Pandey	TK-0021	Services - Operations	\N	\N	SOC Shift Lead - I	t	f	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000036	varun.saxena@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Varun Saxena	TK-0036	Services - Consulting	\N	\N	GRC Auditor - I	t	f	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000026	pooja.nair@acme.co	$2a$12$TPEPtjCI/6kqcY8W4ZoLdeXhlCdqdaSFWU0PsAMpNXv/Z1G9MQdQq	Pooja Nair	TK-0026	Services - Operations	\N	\N	SOC Analyst - III	t	f	1a62b1f8-1810-464d-a67b-168d7e419827	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 13:52:30.671322+00	\N	\N	Local	\N
304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	anita@acme.co	$2a$12$Q4uu3cVEyHI8eIAcepdPjeuJzG9BAF6ed66rOq6w/pMJWxb4yuAyy	Anita Desai	TK-0027	Services - Consulting	\N	AD	Senior Vice President - Principal Consultant	t	f	64c49f37-a38a-46a6-9622-7427f1501658	2026-08-07 07:49:59.669429+00	2026-09-28 06:12:38.240717+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-28 06:12:38.239064+00	\N	\N	Local	\N
00000000-0000-4000-9000-000000000040	divya.rao@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Divya Rao	TK-0040	Services - Testing	\N	\N	Associate Project Manager	t	f	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000045	priya.sharma@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Priya Sharma	TK-0045	Services - Testing	\N	\N	PenTester - I	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-09-24 11:10:05.618689+00	2026-09-28 06:14:37.499084+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-28 06:14:37.497544+00	\N	\N	Local	\N
00000000-0000-4000-9000-000000000014	pradeep.singh@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Pradeep Singh	TK-0014	Functional - Project Management	\N	\N	Engagement Manager	t	f	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000044	ramesh.nair@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Ramesh Nair	TK-0044	Services - Testing	\N	\N	Associate Manager - II	t	f	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000051	rohan.joshi@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Rohan Joshi	TKI-0002	Services - Testing	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000043	kiran.mathur@acme.co	$2a$12$O0H0sXXl172w/4Qxrmx2R.aofFf5.owJufrXd5rjgj7LfuFNOa2Z.	Kiran Mathur	TK-0043	Services - Testing	\N	\N	Associate Manager - I	t	f	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000050	ananya.verma@acme.co	$2a$12$AIBLHyF8lCF45mNWQcv3zev94ABnJuKp.JSBjKTnx7x6jvKT2CsHu	Ananya Verma	TKI-0001	Services - Testing	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 13:56:05.516895+00	\N	\N	Local	\N
111775f6-5d80-5333-478e-68e2fda584fa	meera@acme.co	$2a$12$AUFbuTDheZIErLQp5iCJDenIQwC4Wg0tnQ39H37/C2o1eCdSxjLT6	Meera Joshi	TK-0047	Services - Testing	\N	MJ	DevSecOps Practitioner - I	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-08-07 07:49:59.669429+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-08-11 11:25:29.999149+00	\N	\N	Local	\N
9f6f34df-dc47-f198-f3f6-e577aab1cbca	dev@acme.co	$2a$12$llI5G4FEXaDxVtR6PuhRUuZ4FI1VbqoZJcTAus2lPDIHlDTBwcNc6	Dev Patel	TK-0048	Services - Testing	\N	DP	Red Team Practitioner - II	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-08-07 07:49:59.669429+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-08-11 06:20:37.412783+00	\N	2026-08-10 06:57:47.765224+00	Local	\N
00000000-0000-4000-9000-000000000042	gaurav.joshi@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Gaurav Joshi	TK-0042	Services - Testing	\N	\N	DevSecOps Associate	t	f	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-09-24 11:10:05.618689+00	2026-09-28 06:13:57.92769+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-09-28 06:13:57.926104+00	\N	\N	Local	\N
00000000-0000-4000-9000-000000000011	sneha.reddy@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Sneha Reddy	TK-0011	Functional - Sales	\N	\N	Associate Customer Success Representative - II	t	f	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000015	kavya.desai@acme.co	$2a$12$k23.pCppiU/T06F6xU.G.unVUSijcK53o1drfjFiWMpDVJdE/K5ES	Kavya Desai	TK-0015	R&D (Research & Development)	\N	\N	Python Developer - II	t	f	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-09-24 11:10:05.618689+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 13:49:26.567157+00	\N	\N	Local	\N
b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	rahul@acme.co	$2a$12$XCc4siLJ1l3Ta9hvZCZN7OtkVS.SVk0.Ru2z1zkxjXN1nFahKtIh2	Rahul Gupta	TK-0012	Functional - Project Management	\N	RG	Senior PMO - I	t	f	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-08-07 07:49:59.669429+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 13:52:05.738192+00	\N	\N	Local	\N
00000000-0000-4000-9000-000000000031	siddharth.roy@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Siddharth Roy	TK-0031	Services - Consulting	\N	\N	Senior GRC Auditor - II	t	f	701aaa2c-a899-4def-bf5f-e17511874409	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000032	ira.kapoor@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Ira Kapoor	TK-0032	Services - Consulting	\N	\N	GRC Auditor - I	t	f	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000033	meera.nambiar@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Meera Nambiar	TK-0033	Services - Consulting	\N	\N	GRC Auditor - II	t	f	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
00000000-0000-4000-9000-000000000034	rajat.singhal@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Rajat Singhal	TK-0034	Services - Consulting	\N	\N	GRC Auditor - III	t	f	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
f2f23eb1-efb6-f0a7-c57e-0ead09121a21	arjun@acme.co	$2a$12$UEtMAChe6w0I1FBaTgkGfeF7Lsh3fCKDrEC2870DG3YOOFosmwEcy	Arjun Singh	TK-0046	Services - Testing	\N	AS	PenTester - II	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-08-07 07:49:59.669429+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-24 13:53:51.741493+00	\N	\N	Local	\N
65e2ffa3-6073-780a-b849-4d9604c7251c	priya@acme.co	$2a$12$GXOGXGAng6RCRUYmPfLN7OF3BO7aG25FnJTZ5nfHEbziV0zLkDzU2	Priya Verma	TK-0030	Services - Consulting	\N	PV	Senior GRC Auditor - I	t	f	701aaa2c-a899-4def-bf5f-e17511874409	2026-08-07 07:49:59.669429+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-08-10 12:57:13.729958+00	\N	\N	Local	\N
a3a20ac4-43a2-de64-52d3-bfafce7c7053	sana@acme.co	$2a$12$Oz78LJLyJW9HVgJ5Zf2N3uJ829gDhD1KeoUYhr4E4o7RMv8Z0NM2y	Sana Iyer	TK-0029	Services - Consulting	\N	SI	Associate Manager - III	t	f	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	2026-08-07 07:49:59.669429+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-08-17 07:09:47.329355+00	\N	\N	Local	\N
b1d3f51c-b209-d352-4b52-3f4008801ab3	kavya@acme.co	$2a$12$6mnsze9i9dPXNiY1Pd6ym.qYW.eTEjTweXIuLCRBtuXsKiZiAZSQe	Kavya Nair	TK-0049	Services - Testing	\N	KN	Senior Pentester - I	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-08-07 07:49:59.669429+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-08-11 11:51:44.284921+00	\N	\N	Local	\N
dc139a9d-b996-7354-6c27-72659ea2fd59	accounts@acme.co	$2a$12$9w7hRAe1GQ3Lix6OXg0Eb.5lDrGRfW5ZRHfA5jDo6nr1gvYyDxjZG	Accounts User	TK-0005	Functional - Accounts	\N	AC	Senior Accountant - I	t	f	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-08-10 12:23:35.786937+00	2026-09-28 05:40:54.183084+00	\N	\N	\N	0	2026-09-25 05:15:03.83132+00	\N	\N	Local	\N
00000000-0000-4000-9000-000000000059	kunal.mehra@acme.co	$2a$12$8KZSaRUZmXQe9Eu8RuG.5ekKfMYaUKjDYmNFKp7KaryPJEb.mwe5y	Kunal Mehra	TKI-0010	Functional - IT Administration	\N	\N	Intern	t	f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-09-24 11:10:05.618689+00	\N	\N	\N	\N	0	\N	\N	\N	Local	\N
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
-- Name: IX_role_permission_audits_CreatedAtUtc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_role_permission_audits_CreatedAtUtc" ON public.role_permission_audits USING btree ("CreatedAtUtc");


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
-- Name: role_permission_audits FK_role_permission_audits_roles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission_audits
    ADD CONSTRAINT "FK_role_permission_audits_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public.roles("Id") ON DELETE CASCADE;


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

\unrestrict ghnNnMfKQIyKjbvMMUKzdd2c8jXVdA5UsEUa3jQlKeJeTXBWT1I3iwFgUJdqp2W

