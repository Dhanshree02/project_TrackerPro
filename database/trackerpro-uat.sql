--
-- PostgreSQL database dump
--

\restrict WYJ0JBF7kjlYCATYNET8Z2jivbqKYZpZq9UaTYef8rvKc05qNItPTorZA5epi3Z

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
    "GroupSpocContact" character varying(40),
    "ClientCode" character varying(20)
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
-- Name: mst_modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mst_modules (
    "Id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "Icon" character varying(80),
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
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
-- Name: mst_submodules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mst_submodules (
    "Id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "ModuleId" uuid NOT NULL,
    "ParentSubmoduleId" uuid,
    "Code" character varying(80) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "RoutePrefix" character varying(150),
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: mst_widgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mst_widgets (
    "Id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "SubmoduleId" uuid,
    "ModuleId" uuid,
    "Code" character varying(100) NOT NULL,
    "Name" character varying(150) NOT NULL,
    "WidgetKey" character varying(200) NOT NULL,
    "WidgetType" character varying(40) DEFAULT 'widget'::character varying NOT NULL,
    "HasManageAction" boolean DEFAULT true NOT NULL,
    "Description" character varying(500),
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
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
    "DeletedAtUtc" timestamp with time zone,
    "BillingStatus" character varying(40) DEFAULT 'Advance Pending'::character varying NOT NULL,
    "CollectionStatus" character varying(40) DEFAULT 'Pending To Collect'::character varying NOT NULL,
    "IsReady" boolean DEFAULT false NOT NULL,
    "ValidationStatus" character varying(40) DEFAULT 'Pending To Validate'::character varying NOT NULL
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
    "IsShadowTeam" boolean DEFAULT false NOT NULL,
    "MemberRole" character varying(40) DEFAULT 'ProjectTeam'::character varying NOT NULL
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
-- Name: role_widget_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_widget_permissions (
    "Id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "RoleId" uuid NOT NULL,
    "WidgetId" uuid NOT NULL,
    "CanView" smallint DEFAULT 0 NOT NULL,
    "CanManage" smallint DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "CHK_role_widget_can_manage_binary" CHECK (("CanManage" = ANY (ARRAY[0, 1]))),
    CONSTRAINT "CHK_role_widget_can_view_binary" CHECK (("CanView" = ANY (ARRAY[0, 1]))),
    CONSTRAINT "CHK_role_widget_manage_requires_view" CHECK ((("CanManage" = 0) OR ("CanView" = 1)))
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
-- Name: vw_role_widget_matrix; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_role_widget_matrix AS
 SELECT r."Id" AS "RoleId",
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
    COALESCE((rwp."CanView")::integer, 0) AS "CanView",
    COALESCE((rwp."CanManage")::integer, 0) AS "CanManage"
   FROM ((((public.roles r
     CROSS JOIN public.mst_widgets w)
     LEFT JOIN public.mst_submodules sm ON ((w."SubmoduleId" = sm."Id")))
     LEFT JOIN public.mst_modules m ON (((sm."ModuleId" = m."Id") OR (w."ModuleId" = m."Id"))))
     LEFT JOIN public.role_widget_permissions rwp ON (((rwp."RoleId" = r."Id") AND (rwp."WidgetId" = w."Id"))))
  WHERE (w."DeletedAtUtc" IS NULL);


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
\.


--
-- Data for Name: client_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_assignments ("ClientId", "UserId") FROM stdin;
\.


--
-- Data for Name: client_contacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_contacts ("Id", "ClientId", "SubVentureId", "Name", "Email", "Phone", "Designation", "ContactType", "IsPrimary", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Country", "PhoneCode") FROM stdin;
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clients ("Id", "Name", "Industry", "Logo", "ContactEmail", "ClientType", "Status", "EngagementManager", "ContactName", "ContactPhone", "ContactDesignation", "ContactType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BusinessType", "City", "Country", "KycDocumentName", "Notes", "EngagementManagerId", "IndustryId", "CityId", "CountryId", "CustomerSince", "SalesManager", "SalesManagerId", "KycDocumentPath", "BillingMedium", "GroupSpocName", "GroupSpocContact", "ClientCode") FROM stdin;
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
\.


--
-- Data for Name: exited_employees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exited_employees ("Id", "OriginalEmployeeId", "EmployeeCode", "FullName", "DepartmentName", "DesignationName", "WorkEmail", "PersonalEmail", "Phone", "StatusAtExit", "ExitType", "ExitReason", "ResignationDate", "LastWorkingDay", "ReasonForLeaving", "NoticePeriodServed", "ExitChecklistJson", "AssetReturnJson", "FinalSettlementJson", "ExitedAtUtc", "ExitedBy", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "ClearanceCompleted", "ExitRating") FROM stdin;
\.


--
-- Data for Name: mst_business_units; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_business_units ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_certifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_cities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_contact_designations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_contact_designations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_contact_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_contact_types ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_countries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") FROM stdin;
\.


--
-- Data for Name: mst_departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_designations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "SubDepartment", "DefaultRoleId") FROM stdin;
\.


--
-- Data for Name: mst_email_domains; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_email_domains ("Id", "Code", "DomainName", "DisplayName", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_employee_statuses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_employee_statuses ("Id", "Code", "Name", "IsActive", "AllowOnboarding", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_entra_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_entra_roles ("Id", "Code", "EntraRoleValue", "PulseRoleName", "DisplayName", "Description", "IsActive", "Priority", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_graduation_degrees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_industries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_modules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_modules ("Id", "Code", "Name", "Icon", "SortOrder", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_nationalities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
\.


--
-- Data for Name: mst_reporting_managers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_reporting_managers ("Id", "Code", "Name", "Designation", "Email", "EmployeeId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_salary_bands; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_salary_bands ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_service_catalog; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_catalog ("Id", "Code", "Name", "SubDepartmentId", "DefaultTools", "DefaultUnitPrice", "DefaultDurationDays", "Description", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_service_departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_departments ("Id", "Code", "Name", "GroupId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_service_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_groups ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_service_sub_departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_service_sub_departments ("Id", "Code", "Name", "DepartmentId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_submodules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_submodules ("Id", "ModuleId", "ParentSubmoduleId", "Code", "Name", "RoutePrefix", "SortOrder", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_widgets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_widgets ("Id", "SubmoduleId", "ModuleId", "Code", "Name", "WidgetKey", "WidgetType", "HasManageAction", "Description", "SortOrder", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_work_locations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_work_locations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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

COPY public.project_services ("Id", "ProjectId", "ServiceCatalogId", "TaskId", "Department", "SubDepartment", "ServiceName", "Qty", "Description", "ResourceLevel", "Frequency", "Location", "LocationText", "ServiceModel", "DeliveryModel", "FinalDeliveryFormat", "BillingModel", "Tools", "StartDate", "EndDate", "DurationDays", "DurationHours", "TotalDays", "TotalHours", "UnitPrice", "Total", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BillingStatus", "CollectionStatus", "IsReady", "ValidationStatus") FROM stdin;
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

COPY public.project_team_members ("Id", "ProjectId", "EmployeeId", "DepartmentId", "SubDepartment", "AllocationStartDate", "AllocationEndDate", "Billability", "IsTeamLead", "ResourceType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "IsShadowTeam", "MemberRole") FROM stdin;
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
\.


--
-- Data for Name: repository; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repository ("Id", "FileName", "Category", "Size", "LastUpdated", "UploadedBy", "FilePath", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: repository_activity_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repository_activity_logs ("Id", "Action", "DocumentId", "FileName", "Category", "PerformedBy", "Details", "CreatedAtUtc", "DeletedAtUtc", "CreatedBy", "UpdatedBy", "UpdatedAtUtc") FROM stdin;
\.


--
-- Data for Name: repository_departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repository_departments ("RepositoryItemId", "DepartmentId") FROM stdin;
\.


--
-- Data for Name: role_permission_audits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permission_audits ("Id", "RoleId", "RoleName", "ModuleKey", "ModuleLabel", "SubmoduleKey", "SubmoduleLabel", "PermissionKey", "ActionLabel", "ChangeType", "PreviousValue", "NewValue", "ChangedById", "ChangedByName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: role_widget_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_widget_permissions ("Id", "RoleId", "WidgetId", "CanView", "CanManage", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") FROM stdin;
\.


--
-- Data for Name: sub_ventures; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sub_ventures ("Id", "ClientId", "Name", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Notes", "KycDocumentName", "KycDocumentPath") FROM stdin;
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
-- Name: role_widget_permissions UQ_role_widget_permissions; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_widget_permissions
    ADD CONSTRAINT "UQ_role_widget_permissions" UNIQUE ("RoleId", "WidgetId");


--
-- Name: mst_submodules UQ_submodule_module_parent_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_submodules
    ADD CONSTRAINT "UQ_submodule_module_parent_code" UNIQUE ("ModuleId", "ParentSubmoduleId", "Code");


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
-- Name: mst_modules mst_modules_Code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_modules
    ADD CONSTRAINT "mst_modules_Code_key" UNIQUE ("Code");


--
-- Name: mst_modules mst_modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_modules
    ADD CONSTRAINT mst_modules_pkey PRIMARY KEY ("Id");


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
-- Name: mst_submodules mst_submodules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_submodules
    ADD CONSTRAINT mst_submodules_pkey PRIMARY KEY ("Id");


--
-- Name: mst_widgets mst_widgets_WidgetKey_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_widgets
    ADD CONSTRAINT "mst_widgets_WidgetKey_key" UNIQUE ("WidgetKey");


--
-- Name: mst_widgets mst_widgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_widgets
    ADD CONSTRAINT mst_widgets_pkey PRIMARY KEY ("Id");


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
-- Name: role_widget_permissions role_widget_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_widget_permissions
    ADD CONSTRAINT role_widget_permissions_pkey PRIMARY KEY ("Id");


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
-- Name: IX_clients_ClientCode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_clients_ClientCode" ON public.clients USING btree ("ClientCode");


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
-- Name: IX_mst_modules_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_mst_modules_Code" ON public.mst_modules USING btree ("Code");


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
-- Name: IX_mst_submodules_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_mst_submodules_Code" ON public.mst_submodules USING btree ("Code");


--
-- Name: IX_mst_submodules_ModuleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_mst_submodules_ModuleId" ON public.mst_submodules USING btree ("ModuleId");


--
-- Name: IX_mst_submodules_ParentSubmoduleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_mst_submodules_ParentSubmoduleId" ON public.mst_submodules USING btree ("ParentSubmoduleId");


--
-- Name: IX_mst_widgets_SubmoduleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_mst_widgets_SubmoduleId" ON public.mst_widgets USING btree ("SubmoduleId");


--
-- Name: IX_mst_widgets_WidgetKey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_mst_widgets_WidgetKey" ON public.mst_widgets USING btree ("WidgetKey");


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
-- Name: IX_role_widget_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_role_widget_lookup" ON public.role_widget_permissions USING btree ("RoleId", "CanView", "CanManage");


--
-- Name: IX_role_widget_permissions_RoleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_role_widget_permissions_RoleId" ON public.role_widget_permissions USING btree ("RoleId");


--
-- Name: IX_role_widget_permissions_WidgetId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_role_widget_permissions_WidgetId" ON public.role_widget_permissions USING btree ("WidgetId");


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
-- Name: mst_submodules mst_submodules_ModuleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_submodules
    ADD CONSTRAINT "mst_submodules_ModuleId_fkey" FOREIGN KEY ("ModuleId") REFERENCES public.mst_modules("Id") ON DELETE CASCADE;


--
-- Name: mst_submodules mst_submodules_ParentSubmoduleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_submodules
    ADD CONSTRAINT "mst_submodules_ParentSubmoduleId_fkey" FOREIGN KEY ("ParentSubmoduleId") REFERENCES public.mst_submodules("Id") ON DELETE CASCADE;


--
-- Name: mst_widgets mst_widgets_ModuleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_widgets
    ADD CONSTRAINT "mst_widgets_ModuleId_fkey" FOREIGN KEY ("ModuleId") REFERENCES public.mst_modules("Id") ON DELETE CASCADE;


--
-- Name: mst_widgets mst_widgets_SubmoduleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_widgets
    ADD CONSTRAINT "mst_widgets_SubmoduleId_fkey" FOREIGN KEY ("SubmoduleId") REFERENCES public.mst_submodules("Id") ON DELETE CASCADE;


--
-- Name: role_widget_permissions role_widget_permissions_RoleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_widget_permissions
    ADD CONSTRAINT "role_widget_permissions_RoleId_fkey" FOREIGN KEY ("RoleId") REFERENCES public.roles("Id") ON DELETE CASCADE;


--
-- Name: role_widget_permissions role_widget_permissions_WidgetId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_widget_permissions
    ADD CONSTRAINT "role_widget_permissions_WidgetId_fkey" FOREIGN KEY ("WidgetId") REFERENCES public.mst_widgets("Id") ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict WYJ0JBF7kjlYCATYNET8Z2jivbqKYZpZq9UaTYef8rvKc05qNItPTorZA5epi3Z

