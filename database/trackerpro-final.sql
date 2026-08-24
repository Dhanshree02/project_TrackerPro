--
-- PostgreSQL database dump
--

\restrict 2VEz0wOXcX2PY0KrH4cbGWAWg4V4vT522LwUBZNPeQSrISSi20C6mvhMeFoZMDI

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
    "CustomerSince" date
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
    "SalaryBandId" uuid
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
    "DeletedAtUtc" timestamp with time zone
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
    "Notes" character varying(2000)
);


ALTER TABLE public.sub_ventures OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    "Id" uuid NOT NULL,
    "Email" character varying(255) NOT NULL,
    "PasswordHash" character varying(255) NOT NULL,
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
    "PasswordChangedAtUtc" timestamp with time zone
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
00331436-e85a-4899-8929-daf84f77440f	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-08-21 10:05:12.720669+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
10f3620f-44d6-44a2-a90d-cbeb6ea0851a	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-08-21 10:05:12.720669+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
327f81c4-11e3-40bd-a73c-f5c9dfe06147	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-08-21 10:05:12.720669+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d8e9f1ce-ac14-4a5a-899a-5d87963e99d2	\N	a69fe228-de12-44e5-9128-dc3898f67e5c	omkar	omkar@talakunchi.com	9877987899	SPOC	Accounts	f	2026-08-21 10:05:12.720669+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clients ("Id", "Name", "Industry", "Logo", "ContactEmail", "ClientType", "Status", "EngagementManager", "ContactName", "ContactPhone", "ContactDesignation", "ContactType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BusinessType", "City", "Country", "KycDocumentName", "Notes", "EngagementManagerId", "IndustryId", "CityId", "CountryId", "CustomerSince") FROM stdin;
06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Pharma	Healthcare	HP	it@helix.com	Old	Active	Pradeep Singh	Sanjay Sen	+91 98765 43211	Procurement Head	Procurement	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07
a04ccf3a-81c8-4416-8af7-068717ddb22b	Morphle	Banking	M	roshan.jadhav@gmail.com	New	Active	Pradeep Singh	roshan jadhav	7389247892	spoc	Accounts	2026-08-20 13:31:53.288995+00	2026-08-21 12:28:26.459736+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	Kalyan-Dombivli	India	API Gateway Configuration Guide (1).txt	no comments	8a50b4b9-7091-423c-ac8c-af55bc6df348	4a80bfdb-a191-4ce1-ab51-2142eb366db7	4d396fc0-ae55-4eeb-b2db-79bbb757d3cd	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20
a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync AI	Technology	CA	contact@cloudsync.com	New	Active	Riya Kapoor	Neha Gupta	+91 98765 43215	IT Lead	Technical SPOC	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	02012f0c-97b2-4aea-a6b4-954ee97d892d	\N	\N	2026-08-07
a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Plus	Healthcare	MP	tech@medicareplus.com	New	Active	Pradeep Singh	Priyanka Joshi	+91 98765 43217	Procurement Mgr	Procurement	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07
428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Logistics	Logistics	ZL	pm@zenith.com	New	Active	Rahul Sharma	Vikram Malhotra	+91 98765 43213	Legal Counsel	Legal	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f175fde9-14f8-40e8-b564-47d8a29d84ff	\N	\N	2026-08-07
9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Bank	Banking	NB	ops@northwind.com	Old	Active	Rahul Sharma	Rahul Sharma	+91 98765 43210	IT Manager	Technical SPOC	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4a80bfdb-a191-4ce1-ab51-2142eb366db7	\N	\N	2026-08-07
c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Systems	Automotive	AS	engineering@autodrive.com	Old	Active	Rahul Sharma	Kabir Sen	+91 98765 43219	Engineering SPOC	Technical SPOC	2026-08-07 07:49:59.669429+00	2026-08-21 10:20:25.776021+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	9a15533f-f863-44a7-b61c-b978fa1f5174	4bf54de4-0e85-4904-a89f-542301b65077	\N	\N	2026-08-07
47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Energy	Energy	LE	digital@lumen.com	Old	Active	Pradeep Singh	Arjun Mehta	+91 98765 43214	Operations Manager	Technical SPOC	2026-08-07 07:49:59.669429+00	2026-08-21 12:28:40.3605+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	8a50b4b9-7091-423c-ac8c-af55bc6df348	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-07
fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Global	Finance	FG	dev@fintechglobal.com	Old	Active	Rahul Sharma	Siddharth Shah	+91 98765 43216	Finance VP	Accounts	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	cd116cba-a939-4cb7-bd0f-233019a005b0	\N	\N	2026-08-07
f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Retail	Retail	OR	tech@orbit.com	Old	Active	Riya Kapoor	Aditi Rao	+91 98765 43212	CFO	Accounts	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	935db8d7-e2aa-417e-839e-b51d00ce951e	\N	\N	2026-08-07
f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Solutions	Environment	ES	projects@ecogreen.com	Old	Active	Riya Kapoor	Rohan Varma	+91 98765 43218	Legal Head	Legal	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16ebeb23-b3d8-4fb7-a4f6-789510c28ad3	\N	\N	2026-08-07
90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	TATA	Energy	T	sahillad2092003@gmail.com	New	Active	Pradeep Singh	Sahil	8744541212	spoc	Technical	2026-08-20 11:00:13.739957+00	2026-08-21 09:02:02.864281+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	mumbai	India	exit-summary (1).csv	kldfslkdfsdlf	8a50b4b9-7091-423c-ac8c-af55bc6df348	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-20
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees ("Id", "EmployeeCode", "FirstName", "LastName", "WorkEmail", "PersonalEmail", "Phone", "AltPhone", "Gender", "DateOfBirth", "Address", "EmergencyContact", "MaritalStatus", "Nationality", "DepartmentId", "DesignationId", "Role", "ReportingManagerId", "BusinessUnit", "WorkLocation", "OfficeBranch", "Category", "Team", "ProjectSite", "JoiningDate", "Status", "ConfirmationStatus", "ProbationStatus", "Experience", "PreviousCompany", "EmploymentType", "ContractType", "BondStatus", "NoticePeriod", "AssetId", "ExitType", "ExitReason", "Education", "Skills", "Certifications", "Languages", "KpiScore", "QuarterlyKpi", "AnnualRating", "GoalCompletion", "Attendance", "ReportingEfficiency", "PromotionReadiness", "ManagerFeedback", "Pan", "BankAccount", "SalaryBand", "PfUan", "TaxRegime", "ComplianceStatus", "UserId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "JobRoleId", "NationalityId", "ProbationPeriod", "SalaryBandId") FROM stdin;
a165f6aa-148a-4ad0-953a-f154ae0991c8	EMP-5886	Integration	Resource	integration.resource.e531fb2cecab4c6caa485682aeaa36eb@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	\N	\N	\N	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Notice already ended	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 12:25:04.462343+00	2026-08-20 12:25:04.510288+00	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	2026-08-20 12:25:04.510288+00	\N	\N	\N	\N
649f4c6f-8719-4ff4-8969-7a55a16e43bd	EMP-8163	Integration	Resource	integration.resource.55c6d73ab436476db67f6f1b9df80d8a@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	\N	\N	\N	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Notice already ended	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 12:51:19.436175+00	2026-08-20 12:51:19.547505+00	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	2026-08-20 12:51:19.547505+00	\N	\N	\N	\N
9e1b1aa9-fcd3-47be-b264-53806520c9fc	EMP-1018	Aditya	Reddy	aditya.reddy@acme.co	aditya1018@gmail.com	9876501018	9866501018	Male	1991-06-18	138, Dombivali Office	9811101018	Single	Indian	\N	616911db-9bc2-4b40-b50f-2972f2c2f9e6	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team F	Offsite	2024-06-10	Active	Active	Completed	9 years	TCS	Full-time	Permanent	No	90 days	TK-4018	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	87	85	5	92	98	82	Ready in 1 year	Solid contributor on current assignments.	ABCDE1252F	501234567818	L4	100112345018	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-20 06:10:09.305181+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 06:10:09.305181+00	\N	\N	\N	\N
c5d5234b-6151-4e42-abd3-0d91dd38754b	EMP-1015	Meera	Nambiar	meera.nambiar@acme.co	meera1015@gmail.com	9876501015	9866501015	Female	1996-03-15	135, Andheri Office	9811101015	Single	Indian	\N	0cbff6d6-9622-4d55-a0db-2e7b192988f3	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Without Bond	Team C	Offsite	2021-03-10	Active	Active	Completed	6 years	Infosys	Full-time	Permanent	No	60 days	TK-4015	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Product"]	["NA"]	["English", "Hindi"]	84	82	5	89	95	94	Ready in 1 year	Solid contributor on current assignments.	ABCDE1249F	501234567815	L4	100112345015	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-20 06:35:44.26208+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 06:35:44.26208+00	\N	\N	\N	\N
080045f2-3ff3-49af-bced-4b10ea1dde6f	EMP-7266	Integration	Resource	integration.resource.ce5bcae27dbc41978b56226b5bf1debf@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	Andheri	Suvidha Square	Permanent - Without Bond	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Integration test	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 12:51:17.146104+00	2026-08-22 05:27:05.457481+00	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	\N	\N	\N	\N
18b83048-56d5-4365-8bc5-3ba65405467e	EMP-1010	Harsh	Nair	harsh.nair@acme.co	harsh1010@gmail.com	9876501010	9866501010	Male	1991-10-10	130, Dombivali Office	9811101010	Married	Indian	2083db49-90d5-4f46-b4be-2d0a24edec35	0cbff6d6-9622-4d55-a0db-2e7b192988f3	Pmo	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Without Bond	Team D	Onsite	2022-10-10	Active	Active	Completed	11 years	TCS	Full-time	Permanent	No	90 days	TK-4010	NA	NA	MCA	["Communication", "Delivery", "Operations"]	["NA"]	["English", "Hindi"]	79	77	3	84	90	89	Ready in 1 year	Solid contributor on current assignments.	ABCDE1244F	501234567810	L4	100112345010	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
1a350645-f31a-4309-8441-d37f39e31fe5	EMP-9729	Priya	Shah	priya.shah.0191472791bb4c5593e44681a270b32a@acme.co	\N	\N	\N	Female	1994-03-12	Andheri East, Mumbai	9876543210	Married	Indian	\N	56643cd3-35e5-429e-9b1c-385881443d8f	Developer	\N	Enterprise	Dombivli	Navare Plaza	\N	Platform	Offsite	\N	Active	\N	6 months	5 years	Acme	Full-time	Permanent	No	\N	TK-4029	NA	NA	B.Tech	["React", "Mentoring"]	["AWS"]	["English", "Hindi"]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	L2	\N	\N	\N	\N	2026-08-20 13:08:53.427831+00	2026-08-22 05:27:05.457481+00	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	81ef3e8a-db52-4670-a73e-5ba4d3b47c48	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	ebed343e-301f-4984-b292-fa8d1cb1623c
230058bf-ed8a-45da-8d77-4a2821a0a76a	EMP-1024	Arjun	Mehta	arjun.mehta@acme.co	arjun1024@gmail.com	9876501024	9866501024	Male	1997-12-24	144, Dombivali Office	9811101024	Single	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Without Bond	Team F	Offsite	2024-12-10	Active	Active	Completed	5 years	TCS	Full-time	Permanent	No	90 days	TK-4024	NA	NA	MCA	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	93	71	5	78	95	88	Ready in 1 year	Solid contributor on current assignments.	ABCDE1258F	501234567824	L4	100112345024	Old Regime	Compliant	\N	2026-08-21 08:28:23.134157+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N
3dcb0f17-b94a-470c-ba85-86ac0f1c65c8	EMP-1013	Kavya	Desai	kavya.desai@acme.co	kavya1013@gmail.com	9876501013	9866501013	Female	1994-01-13	133, Andheri Office	9811101013	Married	Indian	92bfb4a4-87df-49ca-8f58-0b4add10f410	65bbcacb-ccc4-4502-87d4-eb142c6b406c	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri	Suvidha Square	Permanent - Without Bond	Team A	Onsite	2019-01-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4013	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Marketing"]	["NA"]	["English", "Hindi"]	82	80	3	87	93	92	Ready Now	Solid contributor on current assignments.	ABCDE1247F	501234567813	L4	100112345013	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
498bb0ed-62ca-4e56-bcb3-4cbd356077be	EMP-1002	Rohan	Mehta	rohan.mehta@acme.co	rohan1002@gmail.com	9876501002	9866501002	Male	1991-02-02	122, Dombivali Office	9811101002	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	616911db-9bc2-4b40-b50f-2972f2c2f9e6	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Without Bond	Team B	Offsite	2020-02-10	Notice Period	Active	Completed	3 years	TCS	Full-time	Permanent	No	60 days	TK-4002	Resign	bo	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	71	69	4	76	91	81	Ready in 1 year	Solid contributor on current assignments.	ABCDE1236F	501234567802	L5	100112345002	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
58198691-3595-4565-8ba6-d5f150240aa3	EMP-1014	Arjun	Shah	arjun.shah@acme.co	arjun1014@gmail.com	9876501014	9866501014	Male	1995-02-14	134, Dombivali Office	9811101014	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Without Bond	Team B	Offsite	2020-02-10	Active	Active	Completed	5 years	TCS	Full-time	Permanent	No	90 days	TK-4014	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	83	81	4	88	94	93	Ready in 1 year	Solid contributor on current assignments.	ABCDE1248F	501234567814	L4	100112345014	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
593b0378-d20a-40ee-b0a0-ae4acc0a78aa	EMP-1009	Aanya	Joshi	aanya.joshi@acme.co	aanya1009@gmail.com	9876501009	9866501009	Female	1990-09-09	129, Andheri Office	9811101009	Single	Indian	d32a6c00-a02a-4586-90c2-4a503b6efc3a	593f83a4-8af6-4fe5-8e91-a465fa5055e9	Sales	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri	Suvidha Square	Permanent - Without Bond	Team C	Offsite	2021-09-10	Active	Active	Completed	10 years	Infosys	Full-time	Permanent	No	60 days	TK-4009	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Sales"]	["NA"]	["English", "Hindi"]	78	76	5	83	98	88	Ready Now	Solid contributor on current assignments.	ABCDE1243F	501234567809	L4	100112345009	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
7c9168b9-8269-430b-89d8-a1ba0b8e99af	EMP-1017	Ishita	Bansal	ishita.bansal@acme.co	ishita1017@gmail.com	9876501017	9866501017	Female	1990-05-17	137, Andheri Office	9811101017	Single	Indian	aad03f2b-8be9-45c8-a5d4-1082a639acc6	84f01f23-588a-4c7f-b8d8-826b8f210729	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri	Suvidha Square	Permanent - Without Bond	Team E	Offsite	2023-05-10	Active	Active	Completed	8 years	Infosys	Full-time	Permanent	No	60 days	TK-4017	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Design"]	["NA"]	["English", "Hindi"]	86	84	4	91	97	81	Ready Now	Solid contributor on current assignments.	ABCDE1251F	501234567817	L4	100112345017	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
8065ff15-64d6-4f36-a003-f0444a620bd8	EMP-1020	Nikhil	Khanna	nikhil.khanna@acme.co	nikhil1020@gmail.com	9876501020	9866501020	Male	1993-08-20	140, Dombivali Office	9811101020	Single	Indian	d32a6c00-a02a-4586-90c2-4a503b6efc3a	593f83a4-8af6-4fe5-8e91-a465fa5055e9	Sales	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Without Bond	Team B	Offsite	2020-08-10	Active	Active	Completed	11 years	TCS	Full-time	Permanent	No	90 days	TK-4020	NA	NA	MCA	["Communication", "Delivery", "Sales"]	["NA"]	["English", "Hindi"]	89	87	4	94	91	84	Ready in 1 year	Solid contributor on current assignments.	ABCDE1254F	501234567820	L4	100112345020	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
81c42f4c-b588-4037-a106-47f339a777f6	EMP-1019	Pooja	Menon	pooja.menon@acme.co	pooja1019@gmail.com	9876501019	9866501019	Female	1992-07-19	139, Andheri Office	9811101019	Married	Indian	d0ab0dc3-606c-4d62-95ea-3d62749f9006	dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	Hr	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri	Suvidha Square	Permanent - Without Bond	Team A	Onsite	2019-07-10	Active	Active	Completed	10 years	Infosys	Full-time	Permanent	No	60 days	TK-4019	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Human Resources"]	["NA"]	["English", "Hindi"]	88	86	3	93	90	83	Ready in 1 year	Solid contributor on current assignments.	ABCDE1253F	501234567819	L4	100112345019	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
8a50b4b9-7091-423c-ac8c-af55bc6df348	EMP-1023	Pradeep	Singh	pradeep.singh@acme.co	pradeep1023@gmail.com	9876501023	9866501023	Male	1996-11-23	143, Andheri Office	9811101023	Single	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri	Suvidha Square	Permanent - Without Bond	Team E	Offsite	2023-11-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4023	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	92	70	4	77	94	87	Ready in 1 year	Solid contributor on current assignments.	ABCDE1257F	501234567823	L4	100112345023	New Regime	Compliant	\N	2026-08-21 08:28:23.134157+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N
8e97c526-8c79-44c6-a23f-ece0d9b21df5	EMP-1003	Sneha	Iyer	sneha.iyer@acme.co	sneha1003@gmail.com	9876501003	9866501003	Female	1992-03-03	123, Andheri Office	9811101003	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	72466f60-859b-4946-998c-b34eb2c40c0e	TeamLead	\N	Cloud Platform	Andheri	Suvidha Square	Permanent - Without Bond	Team C	Offsite	2021-03-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4003	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	72	70	5	77	92	82	Ready in 1 year	Solid contributor on current assignments.	ABCDE1237F	501234567803	L5	100112345003	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
929d4a75-9232-4ce7-a1a6-8f107ccca1e7	EMP-1007	Neha	Kulkarni	neha.kulkarni@acme.co	neha1007@gmail.com	9876501007	9866501007	Female	1996-07-07	127, Andheri Office	9811101007	Married	Indian	e91e9aa5-1cbb-4d1e-99fe-d7aefedd9f87	13d33d9b-c70e-4f07-897f-c9aa2bf89277	Accounts	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri	Suvidha Square	Permanent - Without Bond	Team A	Onsite	2019-07-10	Active	Active	Completed	8 years	Infosys	Full-time	Permanent	No	60 days	TK-4007	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Finance"]	["NA"]	["English", "Hindi"]	76	74	3	81	96	86	Ready in 1 year	Solid contributor on current assignments.	ABCDE1241F	501234567807	L4	100112345007	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
96425efc-9b0e-4f2b-8fd6-ec3b77161547	EMP-3456	Dhanshree	Pansare	dhanshree.pansare@gmail.com	dhanshree.pansare002@gmail.com	9326178048	7900141424	Female	2002-11-02	31,kranti society,bhandup east 400042	9324567803	Single	Indian	\N	eccddb98-13a9-4d79-82d6-3b97e710c83c	software devloer	498bb0ed-62ca-4e56-bcb3-4cbd356077be	Consumer Apps	Dombivli	Navare Plaza	Permanent - Bond	Devloper	Onsite	2026-08-28	Notice Period	Active - Probation	On Probation (6 months)	7 years	tcs	Full-time	Permanent	Yes	90 days	TK-566	Resign	bo	Bachlore enginering	["python", "testing"]	["AWS", "Pen tester"]	["hindi", "engish"]	0	0	0	0	0	0	\N	\N	WASDE2324H	3246572827344	L4	973456234651	\N	Pending	\N	2026-08-20 13:43:06.225084+00	2026-08-22 05:27:05.457481+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	78123fe6-6d61-4ca5-b5e1-57d8b06f1787	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583
9a15533f-f863-44a7-b61c-b978fa1f5174	EMP-1022	Rahul	Sharma	rahul.sharma@acme.co	rahul1022@gmail.com	9876501022	9866501022	Male	1995-10-22	142, Dombivali Office	9811101022	Married	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Without Bond	Team D	Onsite	2022-10-10	Active	Active	Completed	3 years	TCS	Full-time	Permanent	No	90 days	TK-4022	NA	NA	MCA	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	91	69	3	76	93	86	Ready in 1 year	Solid contributor on current assignments.	ABCDE1256F	501234567822	L4	100112345022	Old Regime	Compliant	\N	2026-08-21 08:28:23.134157+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N
a586e15e-0ad4-4d33-aa18-b1edcf241baf	EMP-1005	Divya	Rao	divya.rao@acme.co	divya1005@gmail.com	9876501005	9866501005	Female	1994-05-05	125, Andheri Office	9811101005	Single	Indian	627cdb67-1e99-46ec-88ff-42b9c361fdc3	a307f07d-c56a-47c9-8106-792773adb304	ProjectManager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri	Suvidha Square	Permanent - Without Bond	Team E	Offsite	2023-05-10	Active	Active	Completed	6 years	Infosys	Full-time	Permanent	No	60 days	TK-4005	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Product"]	["NA"]	["English", "Hindi"]	74	72	4	79	94	84	Ready Now	Solid contributor on current assignments.	ABCDE1239F	501234567805	L4	100112345005	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
b78530f0-0687-4f26-a614-8318c62901f9	EMP-3021	Pranjali	Shah	pranjali@talakunchi.io	pranjali@gmail.com	8894344343	9827327263	\N	\N	\N	\N	\N	India	\N	\N	Employee	2446deb8-f6cc-4ee1-b179-599d0a2e357a	\N	Andheri	Suvidha Square	Permanent - Without Bond	\N	Offsite	2026-08-12	Active	Active	\N	\N	\N	\N	\N	\N	\N	\N	NA	NA	\N	[]	[]	[]	0	0	0	0	0	0	\N	\N	WASDE2324H	3246572827344	\N	973456234651	\N	Pending	\N	2026-08-20 10:39:23.376516+00	2026-08-22 05:27:05.457481+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N
c15b2b43-0884-4999-bece-9289d1db561f	EMP-1016	Vikram	Gupta	vikram.gupta@acme.co	vikram1016@gmail.com	9876501016	9866501016	Male	1997-04-16	136, Dombivali Office	9811101016	Married	Indian	2083db49-90d5-4f46-b4be-2d0a24edec35	3cc44614-05d3-4283-9b66-d95dd7ec5708	ProjectManager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Bond	Team D	Onsite	2022-04-10	Active	Active	Completed	7 years	TCS	Full-time	Permanent	Yes — 2 years	90 days	TK-4016	NA	NA	MCA	["Communication", "Delivery", "Operations"]	["NA"]	["English", "Hindi"]	85	83	3	90	96	80	Ready in 1 year	Solid contributor on current assignments.	ABCDE1250F	501234567816	L4	100112345016	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
d24cafbe-bb30-4522-93b2-25588511f0e2	EMP-1011	Ira	Kapoor	ira.kapoor@acme.co	ira1011@gmail.com	9876501011	9866501011	Female	1992-11-11	131, Andheri Office	9811101011	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	988d1399-4c1d-4969-b41f-b8c856ff93d5	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri	Suvidha Square	Permanent - Bond	Team E	Offsite	2023-11-10	Active	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes — 2 years	60 days	TK-4011	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	80	78	4	85	91	90	Ready in 1 year	Solid contributor on current assignments.	ABCDE1245F	501234567811	L4	100112345011	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
dd7a3258-31be-425c-8771-cab8ba8b1b22	EMP-1021	Riya	Kapoor	riya.kapoor@acme.co	riya1021@gmail.com	9876501021	9866501021	Female	1994-09-21	141, Andheri Office	9811101021	Single	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri	Suvidha Square	Permanent - Bond	Team C	Offsite	2021-09-10	Active	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes — 2 years	60 days	TK-4021	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	90	68	5	75	92	85	Ready Now	Solid contributor on current assignments.	ABCDE1255F	501234567821	L4	100112345021	New Regime	Compliant	\N	2026-08-21 08:28:23.134157+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N
df465de2-4aba-41d3-a2a3-1e81ca66e34a	EMP-1004	Karthik	Bose	karthik.bose@acme.co	karthik1004@gmail.com	9876501004	9866501004	Male	1993-04-04	124, Dombivali Office	9811101004	Married	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	d15a2e6e-0d0b-4a54-a80b-21c8e580302b	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Without Bond	Team D	Onsite	2022-04-10	Notice Period	Active	Completed	5 years	TCS	Full-time	Permanent	No	60 days	TK-4004	Resign	Better Opportunity	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	73	71	3	78	93	83	Ready in 1 year	Solid contributor on current assignments.	ABCDE1238F	501234567804	L5	100112345004	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
eb10f37d-b64f-4b17-976b-b962645514f2	EMP-8103	Priya	Shah	priya.shah.839199831f3541eda878b9f48a7f9743@acme.co	\N	\N	\N	Female	1994-03-12	Andheri East, Mumbai	9876543210	Married	Indian	\N	\N	Onboard Role f918b0f6	\N	Enterprise	Dombivli	Navare Plaza	\N	Platform	Offsite	\N	Active	\N	6 months	5 years	Acme	Full-time	Permanent	No	\N	TK-4029	NA	NA	B.Tech	["React", "Mentoring"]	["AWS"]	["English", "Hindi"]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	L2	\N	\N	\N	\N	2026-08-21 05:21:39.645179+00	2026-08-22 05:27:05.457481+00	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	ebed343e-301f-4984-b292-fa8d1cb1623c
eb50369d-e526-459c-bb6c-aa3a85b231db	EMP-9301	Integration	Resource	integration.resource.c92dd5fc2d1c4c4fa7401c33cac1e6fe@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	Andheri	Suvidha Square	Permanent - Without Bond	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Integration test	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 12:25:03.82285+00	2026-08-22 05:27:05.457481+00	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	\N	\N	\N	\N
f7404cb8-5d1a-40bf-b690-22cf179320dd	EMP-1008	Samar	Patel	samar.patel@acme.co	samar1008@gmail.com	9876501008	9866501008	Male	1997-08-08	128, Dombivali Office	9811101008	Single	Indian	d0ab0dc3-606c-4d62-95ea-3d62749f9006	dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	Hr	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Without Bond	Team B	Offsite	2020-08-10	Active	Active	Completed	9 years	TCS	Full-time	Permanent	No	90 days	TK-4008	NA	NA	MCA	["Communication", "Delivery", "Human Resources"]	["NA"]	["English", "Hindi"]	77	75	4	82	97	87	Ready in 1 year	Solid contributor on current assignments.	ABCDE1242F	501234567808	L4	100112345008	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
f8258beb-f446-477d-bb7e-69666c5fe314	EMP-1012	Yash	Malik	yash.malik@acme.co	yash1012@gmail.com	9876501012	9866501012	Male	1993-12-12	132, Dombivali Office	9811101012	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	56643cd3-35e5-429e-9b1c-385881443d8f	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Without Bond	Team F	Offsite	2024-12-10	Active	Active	Completed	3 years	TCS	Full-time	Permanent	No	90 days	TK-4012	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	81	79	5	86	92	91	Ready in 1 year	Solid contributor on current assignments.	ABCDE1246F	501234567812	L4	100112345012	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
fc06e810-3e2d-4510-bfc1-669ccf579da2	EMP-1006	Ankit	Verma	ankit.verma@acme.co	ankit1006@gmail.com	9876501006	9866501006	Male	1995-06-06	126, Dombivali Office	9811101006	Single	Indian	aad03f2b-8be9-45c8-a5d4-1082a639acc6	84f01f23-588a-4c7f-b8d8-826b8f210729	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivli	Navare Plaza	Permanent - Bond	Team F	Offsite	2024-06-10	Active	Active	Completed	7 years	TCS	Full-time	Permanent	Yes — 2 years	90 days	TK-4006	NA	NA	MCA	["Communication", "Delivery", "Design"]	["NA"]	["English", "Hindi"]	75	73	5	80	95	85	Ready in 1 year	Solid contributor on current assignments.	ABCDE1240F	501234567806	L4	100112345006	Old Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-22 05:27:05.457481+00	\N	\N	\N	\N	\N	\N	\N
2446deb8-f6cc-4ee1-b179-599d0a2e357a	EMP-1001	Priya	Sharma	priya.sharma@talakunchi.com	priya1001@gmail.com	9876501001	9866501001	Female	1990-01-01	121, Andheri Office	9811101001	Married	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	56643cd3-35e5-429e-9b1c-385881443d8f	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri	Suvidha Square	Permanent - Bond	Team A	Onsite	2019-01-10	Notice Period	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes — 2 years	60 days	TK-4001	Resign	bo	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	70	68	3	75	90	80	Ready Now	Solid contributor on current assignments.	ABCDE1235F	501234567801	L5	100112345001	New Regime	Compliant	\N	2026-08-20 06:09:32.142207+00	2026-08-24 07:11:46.612843+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	e5f5511b-dea6-421c-8c0e-b271e4ee5d43
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
3ee30a59-078a-4469-9b07-540af53ae71e	enterprise	Enterprise	t	3	2026-08-21 19:57:33.556673+00	\N	\N	\N	\N
468da60b-5b73-4987-9444-ff16ea7c0b79	digital_solutions	Digital Solutions	t	4	2026-08-21 19:57:33.556673+00	\N	\N	\N	\N
9fe393e0-0489-43e0-b868-72217b02c00a	consumer_apps	Consumer Apps	t	2	2026-08-21 19:57:33.556673+00	\N	\N	\N	\N
cd3c05b0-fc85-49fe-adcc-e7d2dcde28df	cloud_platform	Cloud Platform	t	1	2026-08-21 19:57:33.556673+00	\N	\N	\N	\N
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

COPY public.mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
01005b87-3f98-4425-8eb9-6417f2d83b41	JP	Japan	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
068fb26f-376a-4976-9127-b0dae76e7dcd	DK	Denmark	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
0a836600-60d1-4d2e-bbd7-034b338574ba	PK	Pakistan	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
1814186b-4a79-45ea-bfc9-bbdc4721e20b	PH	Philippines	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
1d3750a9-fab1-43fb-ab7b-865dda283bf3	AE	United Arab Emirates	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	GB	United Kingdom	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
25e6b9ec-058b-4778-9c17-1151079562f4	AT	Austria	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
28d63d80-4982-4a6b-9400-ee91260b2604	SA	Saudi Arabia	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
331cec37-bd6c-4a60-8ac5-b413d9677b8a	MX	Mexico	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
339b1d1f-d716-422e-9090-127430134420	US	United States	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
3f86bc47-1e09-482f-9671-9f4b5b089ee4	DE	Germany	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
4da9200f-5486-4710-bf58-e73778e1d506	ES	Spain	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
585fb67f-28ee-437c-aa84-fdc20a1a11d5	ZA	South Africa	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
58746abf-d5dc-4cc8-8a35-96a1747f7a1f	NZ	New Zealand	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
6044817c-ffa1-44b3-ac2a-05e52b97df4a	BR	Brazil	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
64ea0815-a39c-4ecb-b771-038dd74a9b7c	TH	Thailand	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
6e5c5f7b-ab38-4926-9945-da9ac35a35b0	BE	Belgium	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
6f9bb48d-5314-461c-aab8-3b47b00b27a1	NL	Netherlands	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
7190bc9f-d9d5-4bb3-b889-af8a1d6ec53f	LK	Sri Lanka	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
7c57576c-45b6-4cf0-b26d-d3e64730118b	QA	Qatar	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
8b34d450-add9-4da2-ab29-651c187ae702	CN	China	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
990888a7-50d0-45f0-b650-2686f87c4fd0	SE	Sweden	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
9bd3e0a8-de16-4a26-92aa-b43deae65bb7	IE	Ireland	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
9c93a091-0971-4080-b15f-ddebb9de6bb3	FI	Finland	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
a3228796-7e35-4710-9439-2aa36754dbbe	VN	Vietnam	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb	FR	France	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
a890f8b0-d80f-4a14-994e-0ba88d6336a9	NO	Norway	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
af68020d-22f0-4f66-91f6-afe82d052ddd	PL	Poland	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
b8307417-a01f-4b81-8f46-b637c865dc76	PT	Portugal	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
ba695b57-0f82-4ad0-b14a-2785b26209ff	CA	Canada	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
c093b0e3-31a9-40b4-840c-539ca86bc578	KR	South Korea	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
c1764720-16fe-4d3f-bd82-9882632239cd	IT	Italy	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
c9bb9747-7e0f-424e-864b-182d7a8c4230	NP	Nepal	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
d3791631-5e4b-4efa-a86a-59344c19e1a1	CH	Switzerland	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
d725a52a-22a3-48d6-b035-001c1aa15eae	MY	Malaysia	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
e341a797-6da6-4427-9bc1-f3271b6882c1	ID	Indonesia	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
ecb5e362-682e-46d2-bee2-ef0b022ebb13	BD	Bangladesh	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
eeb56a1f-9663-4d29-a984-30c4fc133de2	AU	Australia	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
f1d80739-30d7-4877-a1a7-ee414b074134	SG	Singapore	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	IN	India	t	2026-08-20 11:37:05.749911+00	\N	\N	\N	\N
\.


--
-- Data for Name: mst_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
2083db49-90d5-4f46-b4be-2d0a24edec35	operations	Operations	t	2026-08-21 05:31:26.963654+00	\N	\N	\N	\N
3764a485-1786-470f-b3cb-eba4329f07cb	leadership	Leadership	t	2026-08-21 05:31:26.963654+00	\N	\N	\N	\N
627cdb67-1e99-46ec-88ff-42b9c361fdc3	product	Product	t	2026-08-21 05:31:26.963654+00	\N	\N	\N	\N
7f81ec90-a5fd-4a3e-ac7b-8797e545c431	engineering	Engineering	t	2026-08-21 05:31:26.963654+00	\N	\N	\N	\N
92bfb4a4-87df-49ca-8f58-0b4add10f410	marketing	Marketing	t	2026-08-21 05:31:26.963654+00	\N	\N	\N	\N
aad03f2b-8be9-45c8-a5d4-1082a639acc6	design	Design	t	2026-08-21 05:31:26.963654+00	\N	\N	\N	\N
c21b43ad-98f5-43cb-9466-6f0b22ce7505	delivery	Delivery	t	2026-08-21 05:31:26.963654+00	\N	\N	\N	\N
d0ab0dc3-606c-4d62-95ea-3d62749f9006	human_resources	Human Resources	t	2026-08-21 05:31:26.963654+00	\N	\N	\N	\N
d32a6c00-a02a-4586-90c2-4a503b6efc3a	sales	Sales	t	2026-08-21 05:31:26.963654+00	\N	\N	\N	\N
e91e9aa5-1cbb-4d1e-99fe-d7aefedd9f87	finance	Finance	t	2026-08-21 05:31:26.963654+00	\N	\N	\N	\N
6a43386d-7119-47d6-b95d-84d03b0b29f2	accounts	Accounts	t	2026-08-21 09:17:43.930064+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: mst_designations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
8802cfae-1dcb-4a34-a8cf-cf3de393ee1d	delivery_test_delivery	test delivery	t	c21b43ad-98f5-43cb-9466-6f0b22ce7505	2026-08-21 09:09:45.280716+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
580e71ef-8c9f-44d7-b3bb-e191d8708884	accounts_ca	CA	t	6a43386d-7119-47d6-b95d-84d03b0b29f2	2026-08-21 09:18:00.270122+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
eccddb98-13a9-4d79-82d6-3b97e710c83c	squad1_operation_head	operation head	t	\N	2026-08-20 13:39:27.933257+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0cbff6d6-9622-4d55-a0db-2e7b192988f3	business_analyst	Business Analyst	t	2083db49-90d5-4f46-b4be-2d0a24edec35	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
13d33d9b-c70e-4f07-897f-c9aa2bf89277	finance_analyst	Finance Analyst	t	e91e9aa5-1cbb-4d1e-99fe-d7aefedd9f87	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
28474f5e-661e-4e24-adfe-6dc0b41d340e	engineering_manager	Engineering Manager	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
38ab8071-cefe-47a1-a29a-793523aa82ae	marketing_lead	Marketing Lead	t	92bfb4a4-87df-49ca-8f58-0b4add10f410	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
3cc44614-05d3-4283-9b66-d95dd7ec5708	project_manager	Project Manager	t	2083db49-90d5-4f46-b4be-2d0a24edec35	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
56643cd3-35e5-429e-9b1c-385881443d8f	software_engineer	Software Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
593f83a4-8af6-4fe5-8e91-a465fa5055e9	sales_executive	Sales Executive	t	d32a6c00-a02a-4586-90c2-4a503b6efc3a	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
616911db-9bc2-4b40-b50f-2972f2c2f9e6	senior_software_engineer	Senior Software Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
65bbcacb-ccc4-4502-87d4-eb142c6b406c	content_strategist	Content Strategist	t	92bfb4a4-87df-49ca-8f58-0b4add10f410	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
6c5a2bdd-abe3-4b8c-85cc-3c01321f9690	senior_project_manager	Senior Project Manager	t	c21b43ad-98f5-43cb-9466-6f0b22ce7505	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
72466f60-859b-4946-998c-b34eb2c40c0e	tech_lead	Tech Lead	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
84f01f23-588a-4c7f-b8d8-826b8f210729	ux_designer	UX Designer	t	aad03f2b-8be9-45c8-a5d4-1082a639acc6	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
988d1399-4c1d-4969-b41f-b8c856ff93d5	qa_engineer	QA Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
a307f07d-c56a-47c9-8106-792773adb304	product_manager	Product Manager	t	627cdb67-1e99-46ec-88ff-42b9c361fdc3	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	data_analyst	Data Analyst	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
d15a2e6e-0d0b-4a54-a80b-21c8e580302b	devops_engineer	DevOps Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	hr_business_partner	HR Business Partner	t	d0ab0dc3-606c-4d62-95ea-3d62749f9006	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
e2d6a273-bb40-4b2e-a9b1-e4e5122ebab1	head_of_department	Head of Department	t	3764a485-1786-470f-b3cb-eba4329f07cb	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
f9aa2b6e-26a3-40db-bb37-9c88a1249304	engagement_manager	Engagement Manager	t	c21b43ad-98f5-43cb-9466-6f0b22ce7505	2026-08-18 07:55:36.166597+00	2026-08-21 05:31:26.963654+00	\N	\N	\N
5e962bb1-7f9c-4dc5-8752-65cea3eaec1c	engineering_ds	ds	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-21 19:37:57.085326+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
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
4ce8547a-da87-4ebc-a9b3-11055b29f85c	dombivli_navare_plaza	Navare Plaza	d8ad5202-097f-42e5-9afc-9fd1456590ad	t	1	2026-08-21 19:57:33.556673+00	\N	\N	\N	\N
70b9b373-1f98-4d24-9344-6c1825ea0d5c	andheri_suvidha_square	Suvidha Square	f8f6b305-478f-41fb-910d-67ef268fc529	t	1	2026-08-21 19:57:33.556673+00	\N	\N	\N	\N
375cc899-3e63-4b9c-aad3-368f9a6b50d9	bengaluru_tech_park_west	Tech Park West	0c534759-4e58-40f0-9015-78143792ac7c	f	2	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
3a43966e-cc7a-4f61-9a14-5b4a29918761	mumbai_bandra_kurla_complex	Bandra Kurla Complex	f93f660f-db88-4f46-8df8-ade0e93d3eaf	f	2	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
4ec817eb-b7bc-4cff-ad45-e3f33d9e92ef	remote_virtual_remote	Virtual / Remote	ddf66d66-c299-4a92-a3ca-8fcfa88a00d1	f	1	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
5cc2905f-945a-4fd1-a367-26fa63c93b94	bengaluru_tech_park_east	Tech Park East	0c534759-4e58-40f0-9015-78143792ac7c	f	1	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
6356473e-b6a5-41a7-b7e7-a8c601caf097	hyderabad_hitec_city_office	HITEC City Office	44e2e805-3659-41ed-b423-b12efa989f7d	f	1	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
9b1cd55f-af9a-42ea-89f0-beebd340751b	mumbai_hq_tower	HQ Tower	f93f660f-db88-4f46-8df8-ade0e93d3eaf	f	1	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
f26ab4c4-8824-480f-bbfe-1e08a855f21c	pune_cyber_city_tower	Cyber City Tower	14272979-6065-4afc-92e4-09f335253728	f	1	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
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
\.


--
-- Data for Name: mst_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
0102836c-e96f-4d2b-b007-00681e234c4f	product_manager_product_owner	Product Owner	t	a307f07d-c56a-47c9-8106-792773adb304	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
021470ef-63b7-4f33-a166-89ad6e4527dd	senior_software_engineer_senior_developer	Senior Developer	t	616911db-9bc2-4b40-b50f-2972f2c2f9e6	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
06076b20-e352-4d8b-af1b-fd08cf48d91f	business_analyst_analyst	Analyst	t	0cbff6d6-9622-4d55-a0db-2e7b192988f3	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
062bd587-ae2d-4778-a318-54267d377b3c	tech_lead_module_lead	Module Lead	t	72466f60-859b-4946-998c-b34eb2c40c0e	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
0a9604d1-d84f-4f5d-b07c-819ffdd51a36	senior_project_manager_senior_project_manager	Senior Project Manager	t	6c5a2bdd-abe3-4b8c-85cc-3c01321f9690	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
0caa1dc8-ddc8-48b8-89e0-5e8c7e6ec76c	tech_lead_technical_lead	Technical Lead	t	72466f60-859b-4946-998c-b34eb2c40c0e	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
0ea597c5-975c-4942-a9d0-5f782b070fcf	business_analyst_pmo	Pmo	t	0cbff6d6-9622-4d55-a0db-2e7b192988f3	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
0f6f6704-9029-40ae-a364-134064fd0510	senior_project_manager_program_manager	Program Manager	t	6c5a2bdd-abe3-4b8c-85cc-3c01321f9690	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
153fbd68-c0e3-4c0c-8457-09e59dd75203	engineering_manager_engineering_manager	Engineering Manager	t	28474f5e-661e-4e24-adfe-6dc0b41d340e	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
2c66abdd-5233-4a12-95fa-b8ccf3a0e9e1	content_strategist_strategist	Strategist	t	65bbcacb-ccc4-4502-87d4-eb142c6b406c	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
3b786232-e09c-474f-8b27-5368a15f08fa	data_analyst_employee	Employee	t	ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
3be580f9-60aa-4873-b7ad-efd71019d87d	product_manager_product_manager	Product Manager	t	a307f07d-c56a-47c9-8106-792773adb304	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
3e3ba514-020c-4ebd-8caf-4f769320a33d	data_analyst_data_specialist	Data Specialist	t	ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
4c337782-14a9-4f45-b5bc-7eb109232cee	sales_executive_sales	Sales	t	593f83a4-8af6-4fe5-8e91-a465fa5055e9	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
50010858-2dbb-498f-a66c-446e9bbf899a	hr_business_partner_business_partner	Business Partner	t	dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
58c23d88-f5f2-4b3d-8d6e-73c5db83dc47	engineering_manager_people_manager	People Manager	t	28474f5e-661e-4e24-adfe-6dc0b41d340e	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
5f862b6c-d1e5-4910-9e10-d724ed36f612	business_analyst_consultant	Consultant	t	0cbff6d6-9622-4d55-a0db-2e7b192988f3	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
6361a0db-a608-43df-9204-846067c19809	qa_engineer_employee	Employee	t	988d1399-4c1d-4969-b41f-b8c856ff93d5	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
6c42b4d6-5942-474b-a941-82f4ce149209	engagement_manager_engagement_manager	Engagement Manager	t	f9aa2b6e-26a3-40db-bb37-9c88a1249304	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
6f5a3584-346f-44e3-b622-c98887ed28c4	devops_engineer_employee	Employee	t	d15a2e6e-0d0b-4a54-a80b-21c8e580302b	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
71966fd1-29b2-4f57-8e31-0038d1e25c2f	product_manager_projectmanager	ProjectManager	t	a307f07d-c56a-47c9-8106-792773adb304	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
7d5c8430-198d-43b2-939c-c8265ad57910	ux_designer_ux_specialist	UX Specialist	t	84f01f23-588a-4c7f-b8d8-826b8f210729	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
81ef3e8a-db52-4670-a73e-5ba4d3b47c48	software_engineer_developer	Developer	t	56643cd3-35e5-429e-9b1c-385881443d8f	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
8662ae2e-ccd5-48ac-9fe1-28575f2bb48e	qa_engineer_test_engineer	Test Engineer	t	988d1399-4c1d-4969-b41f-b8c856ff93d5	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
8b717023-d9a6-4106-b648-aa91b2f4135f	marketing_lead_marketing_lead	Marketing Lead	t	38ab8071-cefe-47a1-a29a-793523aa82ae	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
8cd59f47-b5fe-498e-bb11-f9333f5459ee	project_manager_projectmanager	ProjectManager	t	3cc44614-05d3-4283-9b66-d95dd7ec5708	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
969eb4d7-e247-4e40-bc58-1b99e8741bf6	software_engineer_employee	Employee	t	56643cd3-35e5-429e-9b1c-385881443d8f	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
9d33858c-0213-4424-a7fe-4b1e5756f27f	tech_lead_teamlead	TeamLead	t	72466f60-859b-4946-998c-b34eb2c40c0e	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
a7fda134-b199-4e5c-868f-8fb089c61a2a	sales_executive_account_executive	Account Executive	t	593f83a4-8af6-4fe5-8e91-a465fa5055e9	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
aa2fedf9-0eff-419d-9140-5b260baa72b4	devops_engineer_devops_specialist	DevOps Specialist	t	d15a2e6e-0d0b-4a54-a80b-21c8e580302b	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
b2490e55-e251-4edb-8fab-e685f452c079	senior_software_engineer_specialist	Specialist	t	616911db-9bc2-4b40-b50f-2972f2c2f9e6	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
b4184ba7-e35a-4832-8ad5-fab4e2faca69	devops_engineer_sre	SRE	t	d15a2e6e-0d0b-4a54-a80b-21c8e580302b	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
b41dbb49-106e-4757-a2ee-606252785f0a	data_analyst_analyst	Analyst	t	ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
bd7f082e-e6ea-4db0-a933-00e99651fa2d	head_of_department_head_of_department	Head of Department	t	e2d6a273-bb40-4b2e-a9b1-e4e5122ebab1	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
c3ab97b0-3b39-4194-a115-9129ad5b5dac	senior_software_engineer_employee	Employee	t	616911db-9bc2-4b40-b50f-2972f2c2f9e6	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
c5147d88-6164-461c-b876-25b1bf5d0ebf	finance_analyst_analyst	Analyst	t	13d33d9b-c70e-4f07-897f-c9aa2bf89277	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
c629ba0f-f37b-4553-9b50-2e1bb748e0f4	engagement_manager_client_partner	Client Partner	t	f9aa2b6e-26a3-40db-bb37-9c88a1249304	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
caf57ec8-e846-4bff-aa3d-8503d6a1cdc3	content_strategist_employee	Employee	t	65bbcacb-ccc4-4502-87d4-eb142c6b406c	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
d40df5fc-8520-4344-96fa-f40372d1f305	finance_analyst_accounts	Accounts	t	13d33d9b-c70e-4f07-897f-c9aa2bf89277	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
d59ab529-3e86-426d-a344-0fa56db21e40	marketing_lead_campaign_lead	Campaign Lead	t	38ab8071-cefe-47a1-a29a-793523aa82ae	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
d5c1a530-bbc3-4701-8fbb-0e373e2219aa	software_engineer_associate_engineer	Associate Engineer	t	56643cd3-35e5-429e-9b1c-385881443d8f	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
dccdd5c3-0546-4a13-9f42-780b6bb0f694	qa_engineer_qa_analyst	QA Analyst	t	988d1399-4c1d-4969-b41f-b8c856ff93d5	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
dfd50b8d-63ea-46a7-871c-6ad164fd49a3	hr_business_partner_hr	Hr	t	dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
e1ff0a28-e113-48d4-aa18-505ea28357cd	head_of_department_director	Director	t	e2d6a273-bb40-4b2e-a9b1-e4e5122ebab1	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
e6e9131d-2328-494a-836a-d4863aa1fd8a	project_manager_delivery_manager	Delivery Manager	t	3cc44614-05d3-4283-9b66-d95dd7ec5708	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
f01e766b-6ff7-4c60-8591-91934f79ad0e	ux_designer_employee	Employee	t	84f01f23-588a-4c7f-b8d8-826b8f210729	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
fbd9d8c8-1fb6-4757-a095-a9f1ec77336b	ux_designer_designer	Designer	t	84f01f23-588a-4c7f-b8d8-826b8f210729	2026-08-20 12:25:01.232338+00	\N	\N	\N	\N
78123fe6-6d61-4ca5-b5e1-57d8b06f1787	squad1_operation_head_software_devloer	software devloer	t	eccddb98-13a9-4d79-82d6-3b97e710c83c	2026-08-20 13:39:45.101646+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3c19568f-7048-4ad1-a963-87d3d8b31f36	accounts_ca_jr_ca	Jr. CA	t	580e71ef-8c9f-44d7-b3bb-e191d8708884	2026-08-21 09:18:18.227322+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
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
d8ad5202-097f-42e5-9afc-9fd1456590ad	dombivli	Dombivli	t	2	2026-08-21 19:57:33.556673+00	\N	\N	\N	\N
f8f6b305-478f-41fb-910d-67ef268fc529	andheri	Andheri	t	1	2026-08-21 19:57:33.556673+00	\N	\N	\N	\N
0c534759-4e58-40f0-9015-78143792ac7c	bengaluru	Bengaluru	f	3	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
14272979-6065-4afc-92e4-09f335253728	pune	Pune	f	4	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
44e2e805-3659-41ed-b423-b12efa989f7d	hyderabad	Hyderabad	f	5	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
ddf66d66-c299-4a92-a3ca-8fcfa88a00d1	remote	Remote	f	7	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
f93f660f-db88-4f46-8df8-ade0e93d3eaf	mumbai	Mumbai	f	6	2026-08-21 19:57:33.556673+00	2026-08-22 05:27:05.36605+00	\N	\N	\N
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
7f39c75c-2bf2-44d2-b29e-f3ba10b23c57	40517b71-5e62-182e-73b5-d4070e20a3c2	vr04lBMNtlBNorpGOusIu1ewMzFwf60mEqxP1t+4yrE=	2026-08-29 06:42:50.70387+00	\N	\N	2026-08-22 06:42:50.703952+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
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
eda1d94a-066d-4ba9-862a-bb344eb416c3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qrPAvv7HV/IidNmtgESzjzmIfKx4mSU1S+hburO68mM=	2026-08-30 19:11:21.639868+00	2026-08-23 19:23:22.971514+00	\N	2026-08-23 19:11:21.640383+00	2026-08-23 19:23:22.982+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ca9d57b5-fb71-4e3a-8c66-54fdc10c6af9	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	qkGzkHedCsH7pXXKxt4m+tgVnWPAk9BPE7qBGrLLW+I=	2026-08-30 19:23:22.978134+00	2026-08-23 19:30:11.077054+00	\N	2026-08-23 19:23:22.982+00	2026-08-23 19:30:11.078089+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ed285684-c8d2-4226-980c-2a494d866140	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	dhvBs9KGbAHvENLYTIHlPqBL5JjtVdq/yZS6cbrhW7A=	2026-08-30 19:30:11.077353+00	2026-08-24 05:52:35.303019+00	\N	2026-08-23 19:30:11.078089+00	2026-08-24 05:52:35.40042+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
5113bfdb-6afb-4da2-b24a-eed579836a71	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Jy60055yYbqvolUDS1tuuJTXtbzIiBjfokKIAv0I6vI=	2026-08-31 05:52:35.368213+00	2026-08-24 06:04:27.632462+00	\N	2026-08-24 05:52:35.40042+00	2026-08-24 06:04:27.662958+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
23265ce5-b97e-463a-a975-6c4b56dbe983	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	t6LpI4YWjtdZ0kgJ1XJQh9oQVfKTAKFgvPaHE7QAyVM=	2026-08-31 06:04:27.646907+00	2026-08-24 06:05:47.621738+00	\N	2026-08-24 06:04:27.662958+00	2026-08-24 06:05:47.656473+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
9318b073-698d-4e33-9356-08978d199c4f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	GPgKh2kUBzyvTSm3woeZw+vq1ClAaxeCeT2zTv3x8nU=	2026-08-31 06:05:47.655492+00	2026-08-24 06:13:27.409579+00	\N	2026-08-24 06:05:47.656473+00	2026-08-24 06:13:27.459905+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
f43420cc-a21f-4969-b384-3c6cbc8152c0	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	9LfWHaoS/hdK5KMmqkg0HA6QToCdovggxCDwOnJKnOI=	2026-08-31 06:13:27.449938+00	2026-08-24 06:18:51.848142+00	\N	2026-08-24 06:13:27.459905+00	2026-08-24 06:18:52.001129+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
60aae807-81b6-4043-9f3a-3c4fe6d6822e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	oNc3CF0ZXH3tBh0RdgY5jSUiouKjn6die4EEQZ9xoes=	2026-08-31 06:18:51.984093+00	2026-08-24 06:23:44.764735+00	\N	2026-08-24 06:18:52.001129+00	2026-08-24 06:23:44.813527+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
df66ef8e-4969-4fa0-8757-15c5665205a4	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	P78ISOnNrYTBTTcD1fvWNo2VYz22Ul46J7BB+eMKCMQ=	2026-08-31 06:23:44.795875+00	2026-08-24 06:45:15.176042+00	\N	2026-08-24 06:23:44.813527+00	2026-08-24 06:45:15.181289+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e5fbf89f-702c-41b2-8272-51b682fd498e	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	JTKd7L0SlBGifTx+ajNTdmSb7wMp0c6WAzj48kHKqQg=	2026-08-31 06:55:31.573342+00	2026-08-24 07:37:48.515876+00	\N	2026-08-24 06:55:31.593516+00	2026-08-24 07:37:50.583289+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
e1290e80-8d67-4e1c-aae0-8b7eb035ab72	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	QIOxI5x4+KRWWGpPNVSUEI2D55m2QftnK74PV+kfrYM=	2026-08-31 07:37:49.74945+00	2026-08-24 07:42:57.264872+00	\N	2026-08-24 07:37:50.583289+00	2026-08-24 07:42:57.61796+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
496db54f-0e26-42ff-bccf-f5e58ae5f969	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	3lqif5FaOPunH6Y2f2/xxx2jkWd/LgsHIaizg4+NNno=	2026-08-31 07:42:57.554206+00	2026-08-24 07:45:11.783228+00	\N	2026-08-24 07:42:57.61796+00	2026-08-24 07:45:13.027305+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
55116f15-1481-4750-83cd-3428133674d3	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	8owlTktQoCOm0RM8IEVeVDdl1TLJE/V0RchUzpiYEWQ=	2026-08-31 07:45:12.435663+00	2026-08-24 08:13:09.925168+00	\N	2026-08-24 07:45:13.027305+00	2026-08-24 08:13:10.183317+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3a4be64a-bae2-4550-941b-c0db83c8287d	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	XLR+gL0cGZ0fv420Rzmq1ZmYVk/lqaIesY86ZElA4JY=	2026-08-31 08:13:10.166883+00	2026-08-24 09:14:22.20411+00	\N	2026-08-24 08:13:10.183317+00	2026-08-24 09:14:22.204257+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
ecd4d2c3-d45d-463a-8805-30388c970b40	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	+JOZamFzolgtLV7+8kcVZukOytx8TFuKe5qosLlt9wQ=	2026-08-31 09:14:26.722086+00	2026-08-24 09:15:06.556443+00	\N	2026-08-24 09:14:26.723589+00	2026-08-24 09:15:06.567833+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
a0a0c261-3029-4a57-ae38-07c104ee77d2	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	g/NqwJFGh9DXB9h9DVcByLasHGFGyieVpMx9mIrCwos=	2026-08-31 09:15:06.566603+00	2026-08-24 09:18:19.013846+00	\N	2026-08-24 09:15:06.567833+00	2026-08-24 09:18:19.126153+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
60166852-5f5f-4654-8196-8ae8d85a3eff	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	JfIGAbFgp7j5KYTdQH8sdPATZFjTJTMiPAS3vnj8Uhg=	2026-08-31 09:18:19.10499+00	2026-08-24 09:25:58.346281+00	\N	2026-08-24 09:18:19.126153+00	2026-08-24 09:25:58.821768+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
d92b0d13-2a28-4f64-91ae-17e9d14a2d73	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	/fp4+3IyQwLtngNVjvqlYTN/RHcHpaOVfl1mThohp5A=	2026-08-31 09:25:58.721336+00	2026-08-24 10:02:05.924779+00	\N	2026-08-24 09:25:58.821768+00	2026-08-24 10:02:06.03486+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
3723e58e-b45e-4e15-bb63-f5e53d6af80f	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	wMYhAglZoHT0GKfxOu5KTGBEjjq/F4BPPUHuGw89Mr8=	2026-08-31 10:02:05.999774+00	2026-08-24 10:02:21.350766+00	\N	2026-08-24 10:02:06.03486+00	2026-08-24 10:02:21.357852+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N
dfc8600f-6686-42c0-9cd9-518446ea9853	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	jVqGubn/e4KAt11P0fHW6Htz/MA3n6cksANDf6kxVyU=	2026-08-31 10:02:21.354342+00	\N	\N	2026-08-24 10:02:21.357852+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: repository; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repository ("Id", "FileName", "Category", "Size", "LastUpdated", "UploadedBy", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
f17d9e84-8528-813e-e2e8-2b1f89b2c3bf	Leave and Attendance Policy.pdf	IMP	819200	2026-08-07 18:10:16.325637+00	Harsh Nair	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
b3e0cf16-f134-eaca-fb38-4717e89e9d0c	Security Incident Response Plan.pdf	Tech	1572864	2026-08-17 18:10:16.325141+00	Nikhil Khanna	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
b90b20d5-4a19-40be-123d-17d74762e2b7	Timesheet Submission Process.pdf	PMS	409600	2026-07-05 18:10:16.325322+00	Kavya Desai	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
303c6e5f-2413-0ae7-b7c6-85aaa53e19fe	Code of Conduct 2026.pdf	IMP	1048576	2026-07-07 18:10:16.325485+00	Ankit Verma	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
c16772d2-8353-a212-0e4d-7068fb9f4207	API Gateway Configuration Guide.pdf	Tech	2457600	2026-07-02 18:10:16.247186+00	Rahul Sharma	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
0373b2cd-af08-ffa7-1773-e781671f7500	CI CD Pipeline Setup Procedures.docx	Tech	1048576	2026-07-07 18:10:16.324056+00	Sneha Iyer	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
aef197d2-4160-5d34-8c7a-04c6f140f681	Remote Work Policy.pdf	IMP	614400	2026-08-15 18:10:16.325536+00	Arjun Shah	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
40df639a-df99-7f51-f512-3207d21c1cf8	WBS Creation Guidelines.docx	PMS	786432	2026-07-07 18:10:16.325269+00	Rahul Sharma	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
706ab2a8-2689-806b-7e25-e5c9752e8a0b	Resource Allocation SOP.pdf	PMS	655360	2026-08-15 18:10:16.325375+00	Pooja Menon	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
f0fa2ce3-cf22-534b-952f-d2333884d1d6	Database Backup and Recovery SOP.pdf	Tech	3145728	2026-07-27 18:10:16.325014+00	Vikram Gupta	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
1d8b2ea8-542c-0bc9-2983-529a7c2b4bd4	Data Privacy and GDPR Guidelines.pdf	IMP	2097152	2026-06-28 18:10:16.325588+00	Rohan Mehta	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
81637e14-47fd-16df-e1b0-a3f2678a8710	Project Onboarding Checklist.pdf	PMS	524288	2026-07-26 18:10:16.32521+00	Pooja Menon	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
f23f909a-edfa-3d7a-d553-59fdd0d8690b	Change Request Management Process.docx	PMS	327680	2026-08-02 18:10:16.325432+00	Ira Kapoor	2026-08-23 18:10:16.325673+00	\N	\N	\N	\N
e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	33	2026-08-23 18:12:30.416433+00	Karthik Bose	2026-08-23 18:12:30.4294+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	16	2026-08-23 18:12:46.310679+00	Rohan Mehta	2026-08-23 18:12:46.312803+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	27	2026-08-23 18:12:46.368514+00	Sneha Iyer	2026-08-23 18:12:46.39232+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	17754568	2026-08-23 18:31:21.474426+00	Samar Patel	2026-08-23 18:31:21.564645+00	2026-08-24 09:14:33.759131+00	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-24 09:14:33.759131+00
\.


--
-- Data for Name: repository_activity_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repository_activity_logs ("Id", "Action", "DocumentId", "FileName", "Category", "PerformedBy", "Details", "CreatedAtUtc", "DeletedAtUtc", "CreatedBy", "UpdatedBy", "UpdatedAtUtc") FROM stdin;
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
fc0662da-358a-4eb6-9a77-919358b4cb06	Uploaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Samar Patel	Samar Patel uploaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-23 18:31:21.564645+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
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
acb77d89-1c0a-4a1a-9b79-f8ac8d8f556a	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Arjun Shah	Arjun Shah downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-22 10:41:48.449326+00	\N	\N	\N	\N
c3c9370c-6208-4109-9701-5d81e63f86f7	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Priya Sharma	Priya Sharma downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-22 07:41:48.449326+00	\N	\N	\N	\N
8ecc0a49-ff0e-47b1-b816-5d6152f9e186	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Divya Rao	Divya Rao downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-23 12:41:48.449326+00	\N	\N	\N	\N
fbe276f9-c60c-46e3-839e-eaa6762fcb8c	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-24 06:13:54.809683+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f2dc49e9-f756-4a3b-8381-77db8ff8a8d1	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	admin@acme.co	admin@acme.co downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-24 06:13:55.366748+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c0e22746-228d-4efd-a135-062078ec82e2	Viewed	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	Admin User	Admin User viewed Company_Compliance_Policy.pdf	2026-08-24 06:14:11.448398+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
132208e5-ee8c-462d-b66e-9575ac03c847	Downloaded	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	admin@acme.co	admin@acme.co downloaded Company_Compliance_Policy.pdf	2026-08-24 06:14:11.603291+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f3d43ecf-14fc-4a79-94ca-69d1eb8ee192	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	admin@acme.co	admin@acme.co downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-24 08:11:26.788089+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3336b3e4-95ff-4c15-a929-365805ddc8d1	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	admin@acme.co	admin@acme.co downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-24 08:12:11.182758+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9a55edba-f506-49db-9fb0-1b5ac77bd5ae	Downloaded	06445854-5708-42c3-a25d-045c4cc88f6a	Company_Compliance_Policy.pdf	IMP	admin@acme.co	admin@acme.co downloaded Company_Compliance_Policy.pdf	2026-08-24 08:12:11.511771+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
34899d41-00c7-40ae-a086-53a80fd3a576	Downloaded	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	admin@acme.co	admin@acme.co downloaded PMS_Workflow_Spec.docx	2026-08-24 08:12:11.61827+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f445f29b-afee-440e-8103-a22c97482803	Downloaded	e0c1cb36-139a-4fe9-a0ed-d28cfbb7076a	Sample_Architecture_Guide.pdf	Tech	admin@acme.co	admin@acme.co downloaded Sample_Architecture_Guide.pdf	2026-08-24 08:12:11.812923+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dca910fe-01ad-4597-887f-269ca7bf1bc9	Viewed	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Admin User viewed 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-24 08:13:38.684472+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
84f38623-13a4-43d9-bfc8-ff8ea48b3ae7	Downloaded	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	admin@acme.co	admin@acme.co downloaded 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	2026-08-24 08:13:38.822791+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4cc47e2f-3a17-48f2-92c9-05bea9459fe8	Viewed	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	Admin User	Admin User viewed PMS_Workflow_Spec.docx	2026-08-24 09:14:25.723185+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
38b46d4d-50fb-4610-ab60-060b0acecd0a	Downloaded	f4ec5e5f-7885-42cf-b1fc-b76c6bdd1a22	PMS_Workflow_Spec.docx	PMS	admin@acme.co	admin@acme.co downloaded PMS_Workflow_Spec.docx	2026-08-24 09:14:25.98887+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
57e3c54f-d2bc-46bb-bbf3-ed9423f87940	Deleted	2738fefc-b486-4e4f-9d16-355283602733	𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf	Tech	Admin User	Deleted 𝙸𝚗𝚍𝚒𝚊𝚗_𝙿𝚘𝚕𝚒𝚝𝚢𝟖𝐭𝐡_𝐞𝐝𝐢𝐭𝐢𝐨𝐧𝚋𝚢_𝙼_𝙻𝚊𝚡𝚖𝚒𝚔𝚊𝚗𝚝𝚑.pdf from Tech	2026-08-24 09:14:33.759131+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
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
34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	["dashboard.view", "projects.view", "projects.create", "projects.overview.view", "projects.overview.edit", "projects.health.view", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.create", "customers.edit", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:write", "projects:write", "wbs:read", "timesheets:submit"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	Sales	Sales & business development — new projects and customers.	t	t
3cdaf36a-c349-4239-8533-df54dbdbb770	Team Lead	["dashboard.view", "projects.view", "projects.task.view", "projects.task.update-status", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "issues:raise", "timesheets:submit"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	TeamLead	Leads a delivery team; submits timesheets and raises issues.	t	t
915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-08-07 07:49:59.669429+00	2026-08-13 06:42:59.518317+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	ProjectManager	Runs assigned projects end-to-end; approves team timesheets.	t	t
3de8ba61-fd83-4953-9f9e-11e7450ebccd	Admin (Dhanshree)	["action-center.view", "approvals:manage", "approvals.approve", "approvals.reject", "approvals.view", "audit:read", "clients:approve", "clients:read", "clients:write", "customers.approve", "customers.assign", "customers.create", "customers.delete", "customers.edit", "customers.view", "dashboard.view", "invoices:payment", "invoices:raise", "issues:manage", "issues:raise", "my-team.dashboard.view", "my-team.my-timesheet.edit", "my-team.my-timesheet.submit", "my-team.my-timesheet.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.timesheet-approval.view", "portfolio.view", "projects:close", "projects:read", "projects:write", "projects.alerts.create", "projects.alerts.resolve", "projects.alerts.view", "projects.approve", "projects.assign", "projects.assigned-projects.view", "projects.budget.view", "projects.close", "projects.communication.create", "projects.communication.view", "projects.create", "projects.delete", "projects.edit", "projects.escalation.create", "projects.escalation.resolve", "projects.escalation.view", "projects.export", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.health-issues.view", "projects.health.comment", "projects.health.edit-issue", "projects.health.manage", "projects.health.raise-issue", "projects.health.resolve-issue", "projects.health.view", "projects.import", "projects.invoice-schedule.manage", "projects.invoice-schedule.view", "projects.overview.edit", "projects.overview.view", "projects.pmo.manage", "projects.pmo.view", "projects.prerequisite.manage", "projects.prerequisite.view", "projects.services-deliverables.manage", "projects.services-deliverables.view", "projects.task.assign", "projects.task.create", "projects.task.edit", "projects.task.update-status", "projects.task.view", "projects.team.assign", "projects.team.view", "projects.view", "reports:read", "reports.export", "reports.finance.view", "reports.view", "repository.view", "resources:manage", "resources:read", "resources.directory.view", "resources.kpi.view", "resources.manage", "resources.view", "roles:manage", "settings.audit.view", "settings.permissions.manage", "settings.permissions.view", "settings.roles.manage", "settings.roles.view", "settings.view", "timesheets:approve", "timesheets:monitor", "timesheets:submit", "users:manage", "wbs:allocate", "wbs:read", "wbs.allocate", "wbs.view"]	2026-08-07 07:49:59.669429+00	2026-08-11 06:12:16.314057+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	Dhanshree	Super-admin (legacy account) — full access to every module.	t	t
b7271bbe-68a7-4165-996e-869c030c76d3	HOD	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.approve", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "clients:read", "clients:approve", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	Hod	Department oversight across projects, resources and approvals.	t	t
911d3fd2-2e9a-4a85-a79a-49584031c854	HR	["resources.view", "resources.directory.view", "resources.manage", "repository.view", "resources:manage"]	2026-08-07 07:49:59.669429+00	2026-08-11 13:02:20.841494+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Hr	HR resource/directory management only.	t	t
9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	["dashboard.view", "action-center.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "timesheets:submit", "issues:raise"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:26:35.25597+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Employee	Executes assigned tasks; submits own timesheets.	t	t
1312980c-d7e6-4394-930e-477a5ae8ece8	Business Owner	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health-issues.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "portfolio.view", "clients:read", "projects:read", "reports:read"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	BusinessOwner	Executive oversight of the project portfolio.	t	t
a5023c9e-367f-41e1-ba02-bdb2929edc89	Engagement Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	EngagementManager	Owns customer relationship and delivery for assigned accounts.	t	t
da95514a-1975-456d-ad0f-06fe33227e9b	Senior Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "projects:close", "issues:raise", "issues:manage", "timesheets:approve"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	SeniorPm	Owns delivery of assigned projects; approves PM timesheets.	t	t
fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde	PMO	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.budget.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "approvals.view", "wbs.view", "wbs.allocate", "clients:read", "projects:read", "wbs:read", "wbs:allocate", "timesheets:monitor", "issues:manage", "resources:read", "reports:read", "approvals:manage"]	2026-08-07 07:49:59.669429+00	2026-08-10 12:23:35.786937+00	\N	\N	\N	Pmo	Governance, WBS allocation and timesheet monitoring (view-oriented).	t	t
4e1cb2cf-a453-4b80-9ddc-2c6ee042290b	Admin	["dashboard.view", "action-center.view", "projects.view", "projects:read", "projects.create", "projects:write", "projects.edit", "projects:write", "projects.delete", "projects:write", "projects.close", "projects:close", "projects.approve", "projects.assign", "projects.export", "projects.import", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "issues:raise", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health.manage", "issues:manage", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "projects.pmo.view", "projects.pmo.manage", "projects.prerequisite.view", "projects.prerequisite.manage", "projects.services-deliverables.view", "projects.services-deliverables.manage", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "invoices:raise", "invoices:payment", "projects.assigned-projects.view", "reports.view", "reports:read", "reports.export", "reports.finance.view", "resources.view", "resources:read", "resources.manage", "resources:manage", "resources.directory.view", "resources.kpi.view", "customers.view", "clients:read", "customers.create", "clients:write", "customers.edit", "clients:write", "customers.delete", "clients:write", "customers.approve", "clients:approve", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "timesheets:monitor", "my-team.timesheet-approval.approve", "timesheets:approve", "my-team.timesheet-approval.reject", "timesheets:approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit", "my-team.my-timesheet.edit", "wbs.view", "wbs:read", "wbs.allocate", "wbs:allocate", "approvals.view", "approvals:manage", "approvals.approve", "timesheets:approve", "approvals.reject", "timesheets:approve", "portfolio.view", "settings.view", "settings.roles.view", "settings.roles.manage", "roles:manage", "settings.permissions.view", "settings.permissions.manage", "users:manage", "settings.audit.view", "audit:read"]	2026-08-10 12:23:35.786937+00	2026-08-10 12:40:14.170813+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Admin	Super-admin — full access to every module, submodule and action.	t	t
cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	["action-center.view", "clients:read", "customers.view", "dashboard.view", "invoices:payment", "invoices:raise", "projects:read", "projects.health.view", "projects.invoice-schedule.manage", "projects.invoice-schedule.view", "projects.overview.view", "projects.view", "reports:read", "reports.export", "reports.finance.view", "reports.view", "repository.view", "resources:read", "resources.directory.view", "resources.kpi.view", "resources.view"]	2026-08-07 07:49:59.669429+00	2026-08-23 16:16:27.401283+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Accounts	Finance — invoices, payments and finance reports.	t	t
\.


--
-- Data for Name: sub_ventures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sub_ventures ("Id", "ClientId", "Name", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Notes") FROM stdin;
03e40de1-c4a7-425b-87ab-7d2b45ec364d	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Clinical Research	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
5fd7f539-0471-41ef-b4f9-f9c72071e117	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Biotech Division	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
fec11a61-59e0-4cfa-b03e-189789ceab63	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Manufacturing	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
15c89a23-7196-48e6-9c9c-0a10cc38cf80	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Global Healthcare	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
adc6d310-c567-4598-8bee-699791ca28cb	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Medical Devices	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
f8c2759e-1526-4499-93fe-4bf9383551a9	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Freight Services	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
b472f090-9382-4fcb-9a13-ad023a2b8edb	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Warehouse Operations	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
f701bcf7-0139-44fe-9188-1e2218afdb10	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith International Logistics	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
fb458d8a-fe51-4a06-a8cc-135b3784da0e	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Fleet Management	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
f453f787-9888-4058-8098-d99b9a89b9e1	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Express Delivery	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
58e5ee34-e198-47b6-9a9e-95903f56b20d	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Renewable Energy	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
d08681c8-6a5b-4c1e-af29-8997fa0e9de3	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Power Distribution	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
a34f1aad-ed5a-4eef-80e7-ffb186ac5a02	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Smart Grid	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
fbc527bd-d4b0-4a18-9ebb-b2ed0752da93	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Solar Division	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
eb5474ee-f271-4b23-b41e-dac2a1905a50	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Energy Consulting	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
8f8671f4-01e4-42d9-ba2e-afc03d0a37d0	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Retail Banking	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
e2868bff-2f6e-41e5-a1fa-6451ca5a7f0f	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Corporate Banking	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
b5f5586f-63f0-4fe2-b864-89937fb76a72	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Digital Payments	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
c973cd24-655e-4de7-98e2-f0627d34696c	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Treasury Services	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
3ea7fd34-bce6-4d9c-868b-380ef2658536	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Wealth Management	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
321598b3-aae4-4d07-a5b0-2e27cec16136	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync AI Platform	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
889e05ef-4311-474b-9d2e-23a7c5516aa2	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Cloud Infrastructure	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
8113f77c-878e-42bc-912b-5a7c388702a4	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Data Engineering	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
42304e00-59f2-4bed-b23b-87c4800caa16	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Machine Learning	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
bd25f3d8-a3a0-4135-a341-e13aeba728b5	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Enterprise Solutions	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
e1b95e8b-302d-4cf3-9ab1-c6f0bd75d394	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Hospital Systems	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
3540c693-d4be-438c-a795-b11c7edd1f84	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Telemedicine	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
8789ae47-e505-4fb3-adf2-04ade91e418c	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Diagnostics	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
ee71d5b9-7d64-4cef-83a8-1195ff484538	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Health Analytics	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
30613fc3-38d9-45c8-9333-72a178f1e2b7	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Patient Services	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
fa9d3ecf-bd5f-4ccb-a03e-b574d8370f11	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Connected Vehicles	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
80d85beb-5a07-40f2-b7ae-2f6168a6755e	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Autonomous Systems	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
bf470ada-eecb-4ed7-9dc0-0c11436d2eec	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive EV Solutions	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
a9afcff9-fadd-4d29-aeab-d83159813cde	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Manufacturing	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
a5ddbee0-90a3-425b-be8d-bcb2b8e1acda	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Smart Mobility	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
857a1e5d-ba2d-4499-9170-866e7f80596c	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Waste Management	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
7958d666-b744-4889-9c26-4d9152b5e23c	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Sustainability Consulting	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
c5b810e0-cf3c-46cf-91ca-615d583f7f9d	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Renewable Projects	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
c2c8966d-d634-45b1-b1e2-c231d2a91c16	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Water Management	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
6e5a495d-40be-4bb8-b40e-2480d3364bd3	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Carbon Solutions	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
116ef6af-75e2-4743-af52-db5f71093752	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit E-Commerce	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
c10b586c-3015-46a1-9ca4-c8a0758788ef	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Hypermarket	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
0d158329-c66c-4427-b5e8-073bfab60dba	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Fashion	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
79de3aae-5152-44f0-9c77-0c54c3fd701d	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Supply Chain	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
9e067c55-cc90-48a0-ab8b-ded41dace8cb	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Digital Commerce	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
ac923fa9-3ecb-4ccb-a755-5b21621eea43	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Digital Banking	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
ed26b19c-dd44-4dbd-931f-32302088e02d	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Payment Solutions	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
7ac571e1-5915-46fb-b36d-64323d485e8a	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Lending	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
4b278fdd-0c00-477a-ac9f-8c3013de4149	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Investment Services	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
cab77d0e-e88a-4056-8712-a5a39ff91cd9	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Risk & Compliance	2026-08-07 07:49:59.669429+00	\N	\N	\N	\N	\N
37f0c3b1-16a1-4643-9f5a-f824204543c1	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	subventure-northwindbank	2026-08-19 06:43:26.578788+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	sfsddf	2026-08-19 07:09:05.842701+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
6b55edc3-064f-468d-9084-54fbd72dc126	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	New Subventure	2026-08-20 10:21:44.125441+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
6a40584b-3bde-4c7d-a6e6-3ef920cd43d0	90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	TATA-subventure	2026-08-20 11:00:13.739957+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
65c6925a-8948-4485-9d93-e596e1f4273e	a04ccf3a-81c8-4416-8af7-068717ddb22b	Morphle Machine desgining	2026-08-20 13:31:53.288995+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
d3af0a54-b527-40ca-ac1e-9fb09fd81504	a04ccf3a-81c8-4416-8af7-068717ddb22b	morphle labs	2026-08-20 13:34:48.394235+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
a69fe228-de12-44e5-9128-dc3898f67e5c	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	IT	2026-08-21 10:05:12.642403+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users ("Id", "Email", "PasswordHash", "Name", "EmployeeId", "Department", "SubDepartment", "Avatar", "Designation", "IsActive", "MustChangePassword", "RoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "FailedLoginAttempts", "LastLoginAtUtc", "LockedUntilUtc", "PasswordChangedAtUtc") FROM stdin;
cf106b1b-6a96-464f-aa63-ddcb77a737e0	new.pm@acme.co	$2a$12$p.MfI7wlBAX2LZkpEvPoEunU.q5UljNMmswtXsI80UcJj8X2CVWM.	New PM	u99	\N	\N	\N	PM	t	t	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	2026-08-07 07:55:45.951114+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	0	\N	\N	\N
30d629ff-3076-40f8-9c12-fb385b8c2600	admin2@acme.co	$2a$12$aqJIdIL9tzPW5DFE.zVFVurFkCUE0knMbU7.A0A1pBtjA7K4Qk7wS	Test Admin Two	A2	\N	\N	\N	\N	f	t	3de8ba61-fd83-4953-9f9e-11e7450ebccd	2026-08-07 08:15:16.235641+00	2026-08-07 08:15:23.702021+00	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	0	\N	\N	\N
a1878763-b174-41b0-88db-f2ebba76af83	sdsa@gmail.com	$2a$12$.bzyuW3FFq2Uau84IyFnYO1LXxDLXkbxtjVyvzVs71KECK6u2CONy	sadas	ads	sda	\N	\N	sda	t	t	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 09:30:46.654787+00	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	0	\N	\N	\N
a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	admin@acme.co	$2a$12$4U.yEYd2LEcXwnQzZbWhWuA/C9CWusjwICaFSAwvOGI8QqndjRXBS	Admin User	u15	\N	\N	AU	\N	t	f	4e1cb2cf-a453-4b80-9ddc-2c6ee042290b	2026-08-10 12:23:35.786937+00	2026-08-24 09:14:26.723589+00	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	0	2026-08-24 09:14:26.626456+00	\N	\N
b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	rahul@acme.co	$2a$12$6AcnSr6gsE9/ydhpmibjNefkceRSx2k/v/7qv0UjZcMxmUN/yP42u	Rahul Gupta	u11	\N	\N	RG	\N	t	f	fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-23 19:07:26.049628+00	\N	\N
dc139a9d-b996-7354-6c27-72659ea2fd59	accounts@acme.co	$2a$12$MJ8SpIjsKqCaVyDHKiVYeuW8NhE.Y7vCELe3HYN3s1ecfmIo40eY6	Accounts User	u17	\N	\N	AC	\N	t	f	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-08-10 12:23:35.786937+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-23 16:17:59.549139+00	\N	\N
111775f6-5d80-5333-478e-68e2fda584fa	meera@acme.co	$2a$12$trMe4oSKDSKA3cmBC7VSK.5MuxsTdnnkH.wBACj8Nd0v.67g1Caf2	Meera Joshi	u8	\N	\N	MJ	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-11 11:25:29.999149+00	\N	\N
1a077a8c-4029-8ded-d563-19e9b4bdf301	aarav@acme.co	$2a$12$n.jGVqhJlmggiTFthVCt9OD05umCF58TvmlazNvbrhSOBeATW2lXm	Aarav Mehta	u1	\N	\N	AM	\N	t	f	da95514a-1975-456d-ad0f-06fe33227e9b	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-17 12:22:51.492258+00	\N	\N
2bca17e7-5b71-8ac3-6c86-440cb3b75bab	vikrant@acme.co	$2a$12$CwmDjaUzio98qx82oerB5eSSRFgFxe7WYP4YW4EzC7TwIjeOpHTZC	Vikrant Malhotra	u13	\N	\N	VM	\N	t	f	1312980c-d7e6-4394-930e-477a5ae8ece8	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-10 06:59:34.903769+00	\N	2026-08-10 06:59:52.170405+00
304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	anita@acme.co	$2a$12$HE6buM20QYxo9qKvZJYjZenfoLDAnb8VP2wLWPfmhop1DQpblWlX.	Anita Desai	u12	\N	\N	AD	\N	t	f	b7271bbe-68a7-4165-996e-869c030c76d3	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-21 16:45:24.911658+00	\N	\N
40517b71-5e62-182e-73b5-d4070e20a3c2	dhanshree@acme.co	$2a$12$7rIK8qCj4.YqlTjtc80GIeIFcXniuQvZwSsCj/E.iUlgXuhg4MKXy	Dhanshree	u14	\N	\N	DS	\N	t	f	3de8ba61-fd83-4953-9f9e-11e7450ebccd	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-22 06:42:50.7026+00	\N	2026-08-10 07:02:04.244561+00
47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	hr@acme.co	$2a$12$7XADuPaWn/oJIkAyDDgW1uj/546KwQT8CjjrKkkI4j9DMMAvI0E0u	HR User	u16	\N	\N	HU	\N	t	f	911d3fd2-2e9a-4a85-a79a-49584031c854	2026-08-10 12:23:35.786937+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-23 19:08:08.012239+00	\N	\N
49c4e7da-23ec-aab1-9fdf-61dd23764d10	nikhil@acme.co	$2a$12$rIdZ/.dh0Un40.QKMPetS.GqTG9xQdRRw3DuN4sJXHJH0HoMZPoJq	Nikhil Rao	u5	\N	\N	NR	\N	t	f	3cdaf36a-c349-4239-8533-df54dbdbb770	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	\N	\N	\N
65e2ffa3-6073-780a-b849-4d9604c7251c	priya@acme.co	$2a$12$GhIWEtud9AypsWP2kxaGx.kVk7uPUAuTpLZ1Dj5FSmbl3ICicLB8q	Priya Verma	u6	\N	\N	PV	\N	t	f	3cdaf36a-c349-4239-8533-df54dbdbb770	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-10 12:57:13.729958+00	\N	\N
730809c0-fc01-a664-03ca-28e0e32d0393	sales@acme.co	$2a$12$kVFbGsKOI2W1lfRxE7.JVeRhG6xcfwiIGj7m9S4SWjRm/ZpkRYCFa	Sales User	u18	\N	\N	SU	\N	t	f	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	2026-08-10 12:23:35.786937+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-20 05:51:54.138041+00	\N	\N
9f6f34df-dc47-f198-f3f6-e577aab1cbca	dev@acme.co	$2a$12$egvr/VddursYYYdOy7DnZenYIQnzbE3wGA5.yN/Fy4Sgt4p1IhvgG	Dev Patel	u9	\N	\N	DP	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-11 06:20:37.412783+00	\N	2026-08-10 06:57:47.765224+00
a37e30de-15f3-bf1e-fa9f-4a98da9033ab	vikram@acme.co	$2a$12$kNtv2M39EttCtYCPBi3e3Oi3VJlmg3K6Nx4JR.zSvlTbqVIFlmccu	Vikram Shah	u3	\N	\N	VS	\N	t	f	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-20 05:22:57.26898+00	\N	\N
a3a20ac4-43a2-de64-52d3-bfafce7c7053	sana@acme.co	$2a$12$MTyjvYURR3Ba7QEoeeyYIO4aUvyMBXWNhB9KuKj.5ppThMVBYK4e2	Sana Iyer	u4	\N	\N	SI	\N	t	f	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-17 07:09:47.329355+00	\N	\N
b1d3f51c-b209-d352-4b52-3f4008801ab3	kavya@acme.co	$2a$12$Z65jdfq7k9a300NPCsWU.uXCzlZcH7Y3.6mmrGj/YagC8Se83lg5S	Kavya Nair	u10	\N	\N	KN	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-11 11:51:44.284921+00	\N	\N
e7554ba2-e546-93ce-1e88-a073badd78a2	riya@acme.co	$2a$12$D5ISwYvTEBLy6lHSmXOCu.2ZYvUJ6x7eMoDCRIFiIUeS9gVN56hCS	Riya Kapoor	u2	\N	\N	RK	\N	t	f	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-07 07:57:04.148765+00	\N	2026-08-07 07:57:03.565302+00
f2f23eb1-efb6-f0a7-c57e-0ead09121a21	arjun@acme.co	$2a$12$vYedpRwRsft6COeOwPVxBOdKTMfcFenfsOyQcd6e64MnY54LF3Ina	Arjun Singh	u7	\N	\N	AS	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 07:49:59.669429+00	2026-08-24 08:09:03.100849+00	\N	\N	\N	0	2026-08-23 19:04:56.651229+00	\N	\N
\.


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
-- Name: IX_mst_reporting_managers_Code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_mst_reporting_managers_Code" ON public.mst_reporting_managers USING btree ("Code");


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

\unrestrict 2VEz0wOXcX2PY0KrH4cbGWAWg4V4vT522LwUBZNPeQSrISSi20C6mvhMeFoZMDI

