--
-- PostgreSQL database dump
--

\restrict rFHC1zE1RNcnN78Y0yCCt14bqsRvGzRE3L6H3fWptuPc10dvhkHW8skdBh0VEgL

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
    "CustomerSince" date
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
    "DeletedAtUtc" timestamp with time zone
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
    "Notes" character varying(2000)
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
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

COPY public.client_contacts ("Id", "ClientId", "SubVentureId", "Name", "Email", "Phone", "Designation", "ContactType", "IsPrimary", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
d5572af5-adde-4fd9-b14b-c857467d1c93	\N	37f0c3b1-16a1-4643-9f5a-f824204543c1	Sahil Lad	sahillad77@gmail.com	7854125698	ciso	Procurement	f	2026-08-19 12:13:26.584779+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
8959a84a-a7cc-42be-ba71-c142d5dae1fa	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-08-19 12:39:05.853384+05:30	2026-08-20 15:51:44.183087+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 15:51:44.183087+05:30
26358579-8daf-4027-81c9-c375e8628aa3	\N	6a40584b-3bde-4c7d-a6e6-3ef920cd43d0	Sahil 	sahillad2092003@gmail.com	8744541212	spoc	Technical	f	2026-08-20 16:30:13.771971+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
77e4a9a2-d473-4007-be16-f9eebfb39df8	90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	\N	Sahil	sahillad2092003@gmail.com	8744541212	spoc	Technical	f	2026-08-20 16:30:13.771971+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0529bbe6-d5da-4295-9af6-a5d1fc964dc4	a04ccf3a-81c8-4416-8af7-068717ddb22b	\N	roshan jadhav	roshan.jadhav@gmail.com	7389247892	spoc	Accounts	f	2026-08-20 19:01:53.354468+05:30	2026-08-20 19:04:48.401428+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 19:04:48.401428+05:30
146500d9-5e28-4612-8053-9b883e7bfa73	\N	65c6925a-8948-4485-9d93-e596e1f4273e	roshan jadhav	roshan.jadhav@gmail.com	7389247892	spoc	Accounts	f	2026-08-20 19:01:53.354468+05:30	2026-08-20 19:04:48.401428+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 19:04:48.401428+05:30
5a47d941-02d2-4a03-a9fd-29a55f39f273	\N	65c6925a-8948-4485-9d93-e596e1f4273e	karan pawar	karan.pawar@gmail.com	5374903789	ciso	Technical	f	2026-08-20 19:01:53.354468+05:30	2026-08-20 19:04:48.401428+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 19:04:48.401428+05:30
5e72a713-46c0-47c8-b777-f61ecf2a858e	a04ccf3a-81c8-4416-8af7-068717ddb22b	\N	karan pawar	karan.pawar@gmail.com	5374903789	ciso	Technical	f	2026-08-20 19:01:53.354468+05:30	2026-08-20 19:04:48.401428+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 19:04:48.401428+05:30
03f15020-3812-47c9-97a4-3ed02203ca0a	\N	65c6925a-8948-4485-9d93-e596e1f4273e	karan pawar	karan.pawar@gmail.com	5374903789	ciso	Technical	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
251274f1-0037-4f3c-8d67-44d1e46981fa	\N	65c6925a-8948-4485-9d93-e596e1f4273e	roshan jadhav	roshan.jadhav@gmail.com	7389247892	spoc	Accounts	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3865019e-696f-4b90-9347-8cd7ef76d999	\N	d3af0a54-b527-40ca-ac1e-9fb09fd81504	harshada	harshada@tk.com	4373947849	ciso	Technical	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
e6e01a67-c99e-4ed7-87a0-92e5a498d8ab	\N	d3af0a54-b527-40ca-ac1e-9fb09fd81504	muskan	muskan@tk.com	4356789038	spoc	Procurement	f	2026-08-20 19:04:48.407968+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
855194e2-92d8-4bd8-a850-110fa9ce4776	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-08-20 15:51:44.192431+05:30	2026-08-21 15:35:12.70694+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-21 15:35:12.70694+05:30
873fac91-16b6-421c-bd45-3cd92e2dc931	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-08-20 15:51:44.192431+05:30	2026-08-21 15:35:12.70694+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-21 15:35:12.70694+05:30
e90e0928-dbe2-47eb-b92d-3835423c1163	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-08-20 15:51:44.192431+05:30	2026-08-21 15:35:12.70694+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-21 15:35:12.70694+05:30
00331436-e85a-4899-8929-daf84f77440f	\N	f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	Sahil Lad	sahillad77@gmail.com	454353453453	spoc	Technical	f	2026-08-21 15:35:12.720669+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
10f3620f-44d6-44a2-a90d-cbeb6ea0851a	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Dhanashree	Dhanashree@gmail.com	8373292442	SPOC	Procurement	f	2026-08-21 15:35:12.720669+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
327f81c4-11e3-40bd-a73c-f5c9dfe06147	\N	6b55edc3-064f-468d-9084-54fbd72dc126	Sahil	sahil@gmail.com	9353213421	Spoc	Technical	f	2026-08-21 15:35:12.720669+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d8e9f1ce-ac14-4a5a-899a-5d87963e99d2	\N	a69fe228-de12-44e5-9128-dc3898f67e5c	omkar	omkar@talakunchi.com	9877987899	SPOC	Accounts	f	2026-08-21 15:35:12.720669+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clients ("Id", "Name", "Industry", "Logo", "ContactEmail", "ClientType", "Status", "EngagementManager", "ContactName", "ContactPhone", "ContactDesignation", "ContactType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BusinessType", "City", "Country", "KycDocumentName", "Notes", "EngagementManagerId", "IndustryId", "CityId", "CountryId", "CustomerSince") FROM stdin;
06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Pharma	Healthcare	HP	it@helix.com	Old	Active	Pradeep Singh	Sanjay Sen	+91 98765 43211	Procurement Head	Procurement	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07
a04ccf3a-81c8-4416-8af7-068717ddb22b	Morphle	Banking	M	roshan.jadhav@gmail.com	New	Active	Pradeep Singh	roshan jadhav	7389247892	spoc	Accounts	2026-08-20 19:01:53.288995+05:30	2026-08-21 17:58:26.459736+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	Kalyan-Dombivli	India	API Gateway Configuration Guide (1).txt	no comments	8a50b4b9-7091-423c-ac8c-af55bc6df348	4a80bfdb-a191-4ce1-ab51-2142eb366db7	4d396fc0-ae55-4eeb-b2db-79bbb757d3cd	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-08-20
a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync AI	Technology	CA	contact@cloudsync.com	New	Active	Riya Kapoor	Neha Gupta	+91 98765 43215	IT Lead	Technical SPOC	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	02012f0c-97b2-4aea-a6b4-954ee97d892d	\N	\N	2026-08-07
a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Plus	Healthcare	MP	tech@medicareplus.com	New	Active	Pradeep Singh	Priyanka Joshi	+91 98765 43217	Procurement Mgr	Procurement	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7f460c51-01ec-4da1-8f71-d6f360b56f91	\N	\N	2026-08-07
428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Logistics	Logistics	ZL	pm@zenith.com	New	Active	Rahul Sharma	Vikram Malhotra	+91 98765 43213	Legal Counsel	Legal	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f175fde9-14f8-40e8-b564-47d8a29d84ff	\N	\N	2026-08-07
9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Bank	Banking	NB	ops@northwind.com	Old	Active	Rahul Sharma	Rahul Sharma	+91 98765 43210	IT Manager	Technical SPOC	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4a80bfdb-a191-4ce1-ab51-2142eb366db7	\N	\N	2026-08-07
c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Systems	Automotive	AS	engineering@autodrive.com	Old	Active	Rahul Sharma	Kabir Sen	+91 98765 43219	Engineering SPOC	Technical SPOC	2026-08-07 13:19:59.669429+05:30	2026-08-21 15:50:25.776021+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	9a15533f-f863-44a7-b61c-b978fa1f5174	4bf54de4-0e85-4904-a89f-542301b65077	\N	\N	2026-08-07
47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Energy	Energy	LE	digital@lumen.com	Old	Active	Pradeep Singh	Arjun Mehta	+91 98765 43214	Operations Manager	Technical SPOC	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:58:40.3605+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N	\N	8a50b4b9-7091-423c-ac8c-af55bc6df348	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-07
fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Global	Finance	FG	dev@fintechglobal.com	Old	Active	Rahul Sharma	Siddharth Shah	+91 98765 43216	Finance VP	Accounts	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	cd116cba-a939-4cb7-bd0f-233019a005b0	\N	\N	2026-08-07
f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Retail	Retail	OR	tech@orbit.com	Old	Active	Riya Kapoor	Aditi Rao	+91 98765 43212	CFO	Accounts	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	935db8d7-e2aa-417e-839e-b51d00ce951e	\N	\N	2026-08-07
f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Solutions	Environment	ES	projects@ecogreen.com	Old	Active	Riya Kapoor	Rohan Varma	+91 98765 43218	Legal Head	Legal	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16ebeb23-b3d8-4fb7-a4f6-789510c28ad3	\N	\N	2026-08-07
90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	TATA	Energy	T	sahillad2092003@gmail.com	New	Active	Pradeep Singh	Sahil	8744541212	spoc	Technical	2026-08-20 16:30:13.739957+05:30	2026-08-21 14:32:02.864281+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	mumbai	India	exit-summary (1).csv	kldfslkdfsdlf	8a50b4b9-7091-423c-ac8c-af55bc6df348	c7e82721-829b-4450-8393-022587178471	\N	\N	2026-08-20
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employees ("Id", "EmployeeCode", "FirstName", "LastName", "WorkEmail", "PersonalEmail", "Phone", "AltPhone", "Gender", "DateOfBirth", "Address", "EmergencyContact", "MaritalStatus", "Nationality", "DepartmentId", "DesignationId", "Role", "ReportingManagerId", "BusinessUnit", "WorkLocation", "OfficeBranch", "Category", "Team", "ProjectSite", "JoiningDate", "Status", "ConfirmationStatus", "ProbationStatus", "Experience", "PreviousCompany", "EmploymentType", "ContractType", "BondStatus", "NoticePeriod", "AssetId", "ExitType", "ExitReason", "Education", "Skills", "Certifications", "Languages", "KpiScore", "QuarterlyKpi", "AnnualRating", "GoalCompletion", "Attendance", "ReportingEfficiency", "PromotionReadiness", "ManagerFeedback", "Pan", "BankAccount", "SalaryBand", "PfUan", "TaxRegime", "ComplianceStatus", "UserId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "JobRoleId", "NationalityId", "ProbationPeriod", "SalaryBandId") FROM stdin;
18b83048-56d5-4365-8bc5-3ba65405467e	EMP-1010	Harsh	Nair	harsh.nair@acme.co	harsh1010@gmail.com	9876501010	9866501010	Male	1991-10-10	130, Dombivali Office	9811101010	Married	Indian	2083db49-90d5-4f46-b4be-2d0a24edec35	0cbff6d6-9622-4d55-a0db-2e7b192988f3	Pmo	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team D	Onsite	2022-10-10	Active	Active	Completed	11 years	TCS	Full-time	Permanent	No	90 days	TK-4010	NA	NA	MCA	["Communication", "Delivery", "Operations"]	["NA"]	["English", "Hindi"]	79	77	3	84	90	89	Ready in 1 year	Solid contributor on current assignments.	ABCDE1244F	501234567810	L4	100112345010	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
8e97c526-8c79-44c6-a23f-ece0d9b21df5	EMP-1003	Sneha	Iyer	sneha.iyer@acme.co	sneha1003@gmail.com	9876501003	9866501003	Female	1992-03-03	123, Andheri Office	9811101003	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	72466f60-859b-4946-998c-b34eb2c40c0e	TeamLead	\N	Cloud Platform	Andheri Office	HQ Tower	Permanent - Without Bond	Team C	Offsite	2021-03-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4003	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	72	70	5	77	92	82	Ready in 1 year	Solid contributor on current assignments.	ABCDE1237F	501234567803	L5	100112345003	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
b78530f0-0687-4f26-a614-8318c62901f9	EMP-3021	Pranjali	Shah	pranjali@talakunchi.io	pranjali@gmail.com	8894344343	9827327263	\N	\N	\N	\N	\N	India	\N	\N	Employee	2446deb8-f6cc-4ee1-b179-599d0a2e357a	\N	\N	\N	Permanent - Without Bond	\N	Offsite	2026-08-12	Active	Active	\N	\N	\N	\N	\N	\N	\N	\N	NA	NA	\N	[]	[]	[]	0	0	0	0	0	0	\N	\N	WASDE2324H	3246572827344	\N	973456234651	\N	Pending	\N	2026-08-20 16:09:23.376516+05:30	2026-08-20 16:10:58.921794+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N	\N	\N
eb50369d-e526-459c-bb6c-aa3a85b231db	EMP-9301	Integration	Resource	integration.resource.c92dd5fc2d1c4c4fa7401c33cac1e6fe@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	\N	\N	Permanent - Without Bond	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Integration test	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 17:55:03.82285+05:30	2026-08-20 17:55:04.39085+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	\N	\N	\N
a165f6aa-148a-4ad0-953a-f154ae0991c8	EMP-5886	Integration	Resource	integration.resource.e531fb2cecab4c6caa485682aeaa36eb@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	\N	\N	\N	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Notice already ended	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 17:55:04.462343+05:30	2026-08-20 17:55:04.510288+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	2026-08-20 17:55:04.510288+05:30	\N	\N	\N	\N
080045f2-3ff3-49af-bced-4b10ea1dde6f	EMP-7266	Integration	Resource	integration.resource.ce5bcae27dbc41978b56226b5bf1debf@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	\N	\N	Permanent - Without Bond	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Integration test	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 18:21:17.146104+05:30	2026-08-20 18:21:19.272327+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	\N	\N	\N
649f4c6f-8719-4ff4-8969-7a55a16e43bd	EMP-8163	Integration	Resource	integration.resource.55c6d73ab436476db67f6f1b9df80d8a@acme.co	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Employee	\N	\N	\N	\N	\N	\N	\N	\N	Notice Period	\N	\N	\N	\N	\N	\N	\N	30 days	\N	Resign	Notice already ended	\N	["C#"]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20 18:21:19.436175+05:30	2026-08-20 18:21:19.547505+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	2026-08-20 18:21:19.547505+05:30	\N	\N	\N	\N
1a350645-f31a-4309-8441-d37f39e31fe5	EMP-9729	Priya	Shah	priya.shah.0191472791bb4c5593e44681a270b32a@acme.co	\N	\N	\N	Female	1994-03-12	Andheri East, Mumbai	9876543210	Married	Indian	\N	56643cd3-35e5-429e-9b1c-385881443d8f	Developer	\N	Enterprise	Mumbai	HQ Tower	\N	Platform	Offsite	\N	Active	\N	6 months	5 years	Acme	Full-time	Permanent	No	\N	TK-4029	NA	NA	B.Tech	["React", "Mentoring"]	["AWS"]	["English", "Hindi"]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	L2	\N	\N	\N	\N	2026-08-20 18:38:53.427831+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	81ef3e8a-db52-4670-a73e-5ba4d3b47c48	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	ebed343e-301f-4984-b292-fa8d1cb1623c
58198691-3595-4565-8ba6-d5f150240aa3	EMP-1014	Arjun	Shah	arjun.shah@acme.co	arjun1014@gmail.com	9876501014	9866501014	Male	1995-02-14	134, Dombivali Office	9811101014	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team B	Offsite	2020-02-10	Active	Active	Completed	5 years	TCS	Full-time	Permanent	No	90 days	TK-4014	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	83	81	4	88	94	93	Ready in 1 year	Solid contributor on current assignments.	ABCDE1248F	501234567814	L4	100112345014	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
96425efc-9b0e-4f2b-8fd6-ec3b77161547	EMP-3456	Dhanshree	Pansare	dhanshree.pansare@gmail.com	dhanshree.pansare002@gmail.com	9326178048	7900141424	Female	2002-11-02	31,kranti society,bhandup east 400042	9324567803	Single	Indian	\N	eccddb98-13a9-4d79-82d6-3b97e710c83c	software devloer	498bb0ed-62ca-4e56-bcb3-4cbd356077be	Consumer Apps	Mumbai	HQ Tower	Permanent - Bond	Devloper	Onsite	2026-08-28	Notice Period	Active - Probation	On Probation (6 months)	7 years	tcs	Full-time	Permanent	Yes	90 days	TK-566	Resign	bo	Bachlore enginering	["python", "testing"]	["AWS", "Pen tester"]	["hindi", "engish"]	0	0	0	0	0	0	\N	\N	WASDE2324H	3246572827344	L4	973456234651	\N	Pending	\N	2026-08-20 19:13:06.225084+05:30	2026-08-20 19:16:59.255691+05:30	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	78123fe6-6d61-4ca5-b5e1-57d8b06f1787	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	822f92eb-c6fa-4c0f-a8ec-e4c2d16af583
3dcb0f17-b94a-470c-ba85-86ac0f1c65c8	EMP-1013	Kavya	Desai	kavya.desai@acme.co	kavya1013@gmail.com	9876501013	9866501013	Female	1994-01-13	133, Andheri Office	9811101013	Married	Indian	92bfb4a4-87df-49ca-8f58-0b4add10f410	65bbcacb-ccc4-4502-87d4-eb142c6b406c	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Without Bond	Team A	Onsite	2019-01-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4013	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Marketing"]	["NA"]	["English", "Hindi"]	82	80	3	87	93	92	Ready Now	Solid contributor on current assignments.	ABCDE1247F	501234567813	L4	100112345013	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
593b0378-d20a-40ee-b0a0-ae4acc0a78aa	EMP-1009	Aanya	Joshi	aanya.joshi@acme.co	aanya1009@gmail.com	9876501009	9866501009	Female	1990-09-09	129, Andheri Office	9811101009	Single	Indian	d32a6c00-a02a-4586-90c2-4a503b6efc3a	593f83a4-8af6-4fe5-8e91-a465fa5055e9	Sales	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Without Bond	Team C	Offsite	2021-09-10	Active	Active	Completed	10 years	Infosys	Full-time	Permanent	No	60 days	TK-4009	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Sales"]	["NA"]	["English", "Hindi"]	78	76	5	83	98	88	Ready Now	Solid contributor on current assignments.	ABCDE1243F	501234567809	L4	100112345009	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
9e1b1aa9-fcd3-47be-b264-53806520c9fc	EMP-1018	Aditya	Reddy	aditya.reddy@acme.co	aditya1018@gmail.com	9876501018	9866501018	Male	1991-06-18	138, Dombivali Office	9811101018	Single	Indian	\N	616911db-9bc2-4b40-b50f-2972f2c2f9e6	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team F	Offsite	2024-06-10	Active	Active	Completed	9 years	TCS	Full-time	Permanent	No	90 days	TK-4018	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	87	85	5	92	98	82	Ready in 1 year	Solid contributor on current assignments.	ABCDE1252F	501234567818	L4	100112345018	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-20 11:40:09.305181+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 11:40:09.305181+05:30	\N	\N	\N	\N
c5d5234b-6151-4e42-abd3-0d91dd38754b	EMP-1015	Meera	Nambiar	meera.nambiar@acme.co	meera1015@gmail.com	9876501015	9866501015	Female	1996-03-15	135, Andheri Office	9811101015	Single	Indian	\N	0cbff6d6-9622-4d55-a0db-2e7b192988f3	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Without Bond	Team C	Offsite	2021-03-10	Active	Active	Completed	6 years	Infosys	Full-time	Permanent	No	60 days	TK-4015	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Product"]	["NA"]	["English", "Hindi"]	84	82	5	89	95	94	Ready in 1 year	Solid contributor on current assignments.	ABCDE1249F	501234567815	L4	100112345015	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-20 12:05:44.26208+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	2026-08-20 12:05:44.26208+05:30	\N	\N	\N	\N
eb10f37d-b64f-4b17-976b-b962645514f2	EMP-8103	Priya	Shah	priya.shah.839199831f3541eda878b9f48a7f9743@acme.co	\N	\N	\N	Female	1994-03-12	Andheri East, Mumbai	9876543210	Married	Indian	\N	\N	Onboard Role f918b0f6	\N	Enterprise	Mumbai	HQ Tower	\N	Platform	Offsite	\N	Active	\N	6 months	5 years	Acme	Full-time	Permanent	No	\N	TK-4029	NA	NA	B.Tech	["React", "Mentoring"]	["AWS"]	["English", "Hindi"]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	L2	\N	\N	\N	\N	2026-08-21 10:51:39.645179+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	\N	79686ca4-102c-456d-a08e-bdf9ac4c7a26	6 months	ebed343e-301f-4984-b292-fa8d1cb1623c
2446deb8-f6cc-4ee1-b179-599d0a2e357a	EMP-1001	Priya	Sharma	priya.sharma@acme.co	priya1001@gmail.com	9876501001	9866501001	Female	1990-01-01	121, Andheri Office	9811101001	Married	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	56643cd3-35e5-429e-9b1c-385881443d8f	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Bond	Team A	Onsite	2019-01-10	Notice Period	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes — 2 years	60 days	TK-4001	Resign	bo	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	70	68	3	75	90	80	Ready Now	Solid contributor on current assignments.	ABCDE1235F	501234567801	L5	100112345001	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
498bb0ed-62ca-4e56-bcb3-4cbd356077be	EMP-1002	Rohan	Mehta	rohan.mehta@acme.co	rohan1002@gmail.com	9876501002	9866501002	Male	1991-02-02	122, Dombivali Office	9811101002	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	616911db-9bc2-4b40-b50f-2972f2c2f9e6	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team B	Offsite	2020-02-10	Notice Period	Active	Completed	3 years	TCS	Full-time	Permanent	No	60 days	TK-4002	Resign	bo	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	71	69	4	76	91	81	Ready in 1 year	Solid contributor on current assignments.	ABCDE1236F	501234567802	L5	100112345002	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
7c9168b9-8269-430b-89d8-a1ba0b8e99af	EMP-1017	Ishita	Bansal	ishita.bansal@acme.co	ishita1017@gmail.com	9876501017	9866501017	Female	1990-05-17	137, Andheri Office	9811101017	Single	Indian	aad03f2b-8be9-45c8-a5d4-1082a639acc6	84f01f23-588a-4c7f-b8d8-826b8f210729	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Without Bond	Team E	Offsite	2023-05-10	Active	Active	Completed	8 years	Infosys	Full-time	Permanent	No	60 days	TK-4017	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Design"]	["NA"]	["English", "Hindi"]	86	84	4	91	97	81	Ready Now	Solid contributor on current assignments.	ABCDE1251F	501234567817	L4	100112345017	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
8065ff15-64d6-4f36-a003-f0444a620bd8	EMP-1020	Nikhil	Khanna	nikhil.khanna@acme.co	nikhil1020@gmail.com	9876501020	9866501020	Male	1993-08-20	140, Dombivali Office	9811101020	Single	Indian	d32a6c00-a02a-4586-90c2-4a503b6efc3a	593f83a4-8af6-4fe5-8e91-a465fa5055e9	Sales	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team B	Offsite	2020-08-10	Active	Active	Completed	11 years	TCS	Full-time	Permanent	No	90 days	TK-4020	NA	NA	MCA	["Communication", "Delivery", "Sales"]	["NA"]	["English", "Hindi"]	89	87	4	94	91	84	Ready in 1 year	Solid contributor on current assignments.	ABCDE1254F	501234567820	L4	100112345020	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
81c42f4c-b588-4037-a106-47f339a777f6	EMP-1019	Pooja	Menon	pooja.menon@acme.co	pooja1019@gmail.com	9876501019	9866501019	Female	1992-07-19	139, Andheri Office	9811101019	Married	Indian	d0ab0dc3-606c-4d62-95ea-3d62749f9006	dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	Hr	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Without Bond	Team A	Onsite	2019-07-10	Active	Active	Completed	10 years	Infosys	Full-time	Permanent	No	60 days	TK-4019	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Human Resources"]	["NA"]	["English", "Hindi"]	88	86	3	93	90	83	Ready in 1 year	Solid contributor on current assignments.	ABCDE1253F	501234567819	L4	100112345019	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
929d4a75-9232-4ce7-a1a6-8f107ccca1e7	EMP-1007	Neha	Kulkarni	neha.kulkarni@acme.co	neha1007@gmail.com	9876501007	9866501007	Female	1996-07-07	127, Andheri Office	9811101007	Married	Indian	e91e9aa5-1cbb-4d1e-99fe-d7aefedd9f87	13d33d9b-c70e-4f07-897f-c9aa2bf89277	Accounts	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Without Bond	Team A	Onsite	2019-07-10	Active	Active	Completed	8 years	Infosys	Full-time	Permanent	No	60 days	TK-4007	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Finance"]	["NA"]	["English", "Hindi"]	76	74	3	81	96	86	Ready in 1 year	Solid contributor on current assignments.	ABCDE1241F	501234567807	L4	100112345007	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
a586e15e-0ad4-4d33-aa18-b1edcf241baf	EMP-1005	Divya	Rao	divya.rao@acme.co	divya1005@gmail.com	9876501005	9866501005	Female	1994-05-05	125, Andheri Office	9811101005	Single	Indian	627cdb67-1e99-46ec-88ff-42b9c361fdc3	a307f07d-c56a-47c9-8106-792773adb304	ProjectManager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Without Bond	Team E	Offsite	2023-05-10	Active	Active	Completed	6 years	Infosys	Full-time	Permanent	No	60 days	TK-4005	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Product"]	["NA"]	["English", "Hindi"]	74	72	4	79	94	84	Ready Now	Solid contributor on current assignments.	ABCDE1239F	501234567805	L4	100112345005	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
c15b2b43-0884-4999-bece-9289d1db561f	EMP-1016	Vikram	Gupta	vikram.gupta@acme.co	vikram1016@gmail.com	9876501016	9866501016	Male	1997-04-16	136, Dombivali Office	9811101016	Married	Indian	2083db49-90d5-4f46-b4be-2d0a24edec35	3cc44614-05d3-4283-9b66-d95dd7ec5708	ProjectManager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Bond	Team D	Onsite	2022-04-10	Active	Active	Completed	7 years	TCS	Full-time	Permanent	Yes — 2 years	90 days	TK-4016	NA	NA	MCA	["Communication", "Delivery", "Operations"]	["NA"]	["English", "Hindi"]	85	83	3	90	96	80	Ready in 1 year	Solid contributor on current assignments.	ABCDE1250F	501234567816	L4	100112345016	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
d24cafbe-bb30-4522-93b2-25588511f0e2	EMP-1011	Ira	Kapoor	ira.kapoor@acme.co	ira1011@gmail.com	9876501011	9866501011	Female	1992-11-11	131, Andheri Office	9811101011	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	988d1399-4c1d-4969-b41f-b8c856ff93d5	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Bond	Team E	Offsite	2023-11-10	Active	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes — 2 years	60 days	TK-4011	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	80	78	4	85	91	90	Ready in 1 year	Solid contributor on current assignments.	ABCDE1245F	501234567811	L4	100112345011	New Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
df465de2-4aba-41d3-a2a3-1e81ca66e34a	EMP-1004	Karthik	Bose	karthik.bose@acme.co	karthik1004@gmail.com	9876501004	9866501004	Male	1993-04-04	124, Dombivali Office	9811101004	Married	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	d15a2e6e-0d0b-4a54-a80b-21c8e580302b	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team D	Onsite	2022-04-10	Notice Period	Active	Completed	5 years	TCS	Full-time	Permanent	No	60 days	TK-4004	Resign	Better Opportunity	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	73	71	3	78	93	83	Ready in 1 year	Solid contributor on current assignments.	ABCDE1238F	501234567804	L5	100112345004	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
f7404cb8-5d1a-40bf-b690-22cf179320dd	EMP-1008	Samar	Patel	samar.patel@acme.co	samar1008@gmail.com	9876501008	9866501008	Male	1997-08-08	128, Dombivali Office	9811101008	Single	Indian	d0ab0dc3-606c-4d62-95ea-3d62749f9006	dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	Hr	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team B	Offsite	2020-08-10	Active	Active	Completed	9 years	TCS	Full-time	Permanent	No	90 days	TK-4008	NA	NA	MCA	["Communication", "Delivery", "Human Resources"]	["NA"]	["English", "Hindi"]	77	75	4	82	97	87	Ready in 1 year	Solid contributor on current assignments.	ABCDE1242F	501234567808	L4	100112345008	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
f8258beb-f446-477d-bb7e-69666c5fe314	EMP-1012	Yash	Malik	yash.malik@acme.co	yash1012@gmail.com	9876501012	9866501012	Male	1993-12-12	132, Dombivali Office	9811101012	Single	Indian	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	56643cd3-35e5-429e-9b1c-385881443d8f	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team F	Offsite	2024-12-10	Active	Active	Completed	3 years	TCS	Full-time	Permanent	No	90 days	TK-4012	NA	NA	MCA	["Communication", "Delivery", "Engineering"]	["NA"]	["English", "Hindi"]	81	79	5	86	92	91	Ready in 1 year	Solid contributor on current assignments.	ABCDE1246F	501234567812	L4	100112345012	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
fc06e810-3e2d-4510-bfc1-669ccf579da2	EMP-1006	Ankit	Verma	ankit.verma@acme.co	ankit1006@gmail.com	9876501006	9866501006	Male	1995-06-06	126, Dombivali Office	9811101006	Single	Indian	aad03f2b-8be9-45c8-a5d4-1082a639acc6	84f01f23-588a-4c7f-b8d8-826b8f210729	Employee	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Bond	Team F	Offsite	2024-06-10	Active	Active	Completed	7 years	TCS	Full-time	Permanent	Yes — 2 years	90 days	TK-4006	NA	NA	MCA	["Communication", "Delivery", "Design"]	["NA"]	["English", "Hindi"]	75	73	5	80	95	85	Ready in 1 year	Solid contributor on current assignments.	ABCDE1240F	501234567806	L4	100112345006	Old Regime	Compliant	\N	2026-08-20 11:39:32.142207+05:30	2026-08-21 11:01:27.404812+05:30	\N	\N	\N	\N	\N	\N	\N
230058bf-ed8a-45da-8d77-4a2821a0a76a	EMP-1024	Arjun	Mehta	arjun.mehta@acme.co	arjun1024@gmail.com	9876501024	9866501024	Male	1997-12-24	144, Dombivali Office	9811101024	Single	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team F	Offsite	2024-12-10	Active	Active	Completed	5 years	TCS	Full-time	Permanent	No	90 days	TK-4024	NA	NA	MCA	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	93	71	5	78	95	88	Ready in 1 year	Solid contributor on current assignments.	ABCDE1258F	501234567824	L4	100112345024	Old Regime	Compliant	\N	2026-08-21 13:58:23.134157+05:30	\N	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N
8a50b4b9-7091-423c-ac8c-af55bc6df348	EMP-1023	Pradeep	Singh	pradeep.singh@acme.co	pradeep1023@gmail.com	9876501023	9866501023	Male	1996-11-23	143, Andheri Office	9811101023	Single	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Without Bond	Team E	Offsite	2023-11-10	Active	Active	Completed	4 years	Infosys	Full-time	Permanent	No	60 days	TK-4023	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	92	70	4	77	94	87	Ready in 1 year	Solid contributor on current assignments.	ABCDE1257F	501234567823	L4	100112345023	New Regime	Compliant	\N	2026-08-21 13:58:23.134157+05:30	\N	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N
9a15533f-f863-44a7-b61c-b978fa1f5174	EMP-1022	Rahul	Sharma	rahul.sharma@acme.co	rahul1022@gmail.com	9876501022	9866501022	Male	1995-10-22	142, Dombivali Office	9811101022	Married	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Enterprise	Dombivali Office	Tech Park East	Permanent - Without Bond	Team D	Onsite	2022-10-10	Active	Active	Completed	3 years	TCS	Full-time	Permanent	No	90 days	TK-4022	NA	NA	MCA	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	91	69	3	76	93	86	Ready in 1 year	Solid contributor on current assignments.	ABCDE1256F	501234567822	L4	100112345022	Old Regime	Compliant	\N	2026-08-21 13:58:23.134157+05:30	\N	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N
dd7a3258-31be-425c-8771-cab8ba8b1b22	EMP-1021	Riya	Kapoor	riya.kapoor@acme.co	riya1021@gmail.com	9876501021	9866501021	Female	1994-09-21	141, Andheri Office	9811101021	Single	Indian	c21b43ad-98f5-43cb-9466-6f0b22ce7505	f9aa2b6e-26a3-40db-bb37-9c88a1249304	Engagement Manager	8e97c526-8c79-44c6-a23f-ece0d9b21df5	Cloud Platform	Andheri Office	HQ Tower	Permanent - Bond	Team C	Offsite	2021-09-10	Active	Active	Completed	2 years	Infosys	Full-time	Permanent	Yes — 2 years	60 days	TK-4021	NA	NA	B.Tech Computer Science	["Communication", "Delivery", "Delivery"]	["NA"]	["English", "Hindi"]	90	68	5	75	92	85	Ready Now	Solid contributor on current assignments.	ABCDE1255F	501234567821	L4	100112345021	New Regime	Compliant	\N	2026-08-21 13:58:23.134157+05:30	\N	\N	\N	\N	6c42b4d6-5942-474b-a941-82f4ce149209	79686ca4-102c-456d-a08e-bdf9ac4c7a26	\N	\N
\.


--
-- Data for Name: exited_employees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exited_employees ("Id", "OriginalEmployeeId", "EmployeeCode", "FullName", "DepartmentName", "DesignationName", "WorkEmail", "PersonalEmail", "Phone", "StatusAtExit", "ExitType", "ExitReason", "ResignationDate", "LastWorkingDay", "ReasonForLeaving", "NoticePeriodServed", "ExitChecklistJson", "AssetReturnJson", "FinalSettlementJson", "ExitedAtUtc", "ExitedBy", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
6b3e85ba-b66a-4ee2-a56c-763dadac0945	9e1b1aa9-fcd3-47be-b264-53806520c9fc	EMP-1018	Aditya Reddy	Engineering	Senior Software Engineer	aditya.reddy@acme.co	aditya1018@gmail.com	9876501018	Active	Resign	Better opp	2026-08-20	2026-09-23	Better opp	60 days	\N	\N	\N	2026-08-20 11:40:09.268914+05:30	\N	2026-08-20 11:40:09.305181+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4b351675-a78a-493e-a0fb-464c1180e0d6	c5d5234b-6151-4e42-abd3-0d91dd38754b	EMP-1015	Meera Nambiar	Product	Business Analyst	meera.nambiar@acme.co	meera1015@gmail.com	9876501015	Active	Resign	better opp	2026-08-20	2026-08-31	better opp	60 days	\N	\N	\N	2026-08-20 12:05:44.250988+05:30	\N	2026-08-20 12:05:44.26208+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
30589db9-44d2-4cb5-b6dd-81d1cefbd915	2446deb8-f6cc-4ee1-b179-599d0a2e357a	EMP-1001	Priya Sharma	Engineering	Software Engineer	priya.sharma@acme.co	priya1001@gmail.com	9876501001	Active	Resign	better opp	2026-08-20	2026-08-31	better opp	60 days	\N	\N	\N	2026-08-20 15:10:15.112908+05:30	\N	2026-08-20 15:10:15.160793+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3a576a72-02ca-4b83-94f4-735b0348c9b2	498bb0ed-62ca-4e56-bcb3-4cbd356077be	EMP-1002	Rohan Mehta	Engineering	Senior Software Engineer	rohan.mehta@acme.co	rohan1002@gmail.com	9876501002	Active	Resign	better opp	2026-08-20	2026-09-04	better opp	60 days	\N	\N	\N	2026-08-20 15:14:21.427364+05:30	\N	2026-08-20 15:14:21.428431+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4d7a33d1-9bb6-4174-933a-b67a5f1ee447	df465de2-4aba-41d3-a2a3-1e81ca66e34a	EMP-1004	Karthik Bose	Engineering	DevOps Engineer	karthik.bose@acme.co	karthik1004@gmail.com	9876501004	Active	Resign	Better Opportunity	2026-08-20	2026-10-19	Better Opportunity	60 days	\N	\N	\N	2026-08-20 16:12:11.75374+05:30	\N	2026-08-20 16:12:11.753917+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2045661c-a8d6-4501-b7e1-c2ac306c397b	eb50369d-e526-459c-bb6c-aa3a85b231db	EMP-9301	Integration Resource	\N	\N	integration.resource.c92dd5fc2d1c4c4fa7401c33cac1e6fe@acme.co	\N	\N	Probation	Resign	Integration test	2026-08-20	2026-09-19	Integration test	30 days	{}	{}	{}	2026-08-20 17:55:04.296597+05:30	\N	2026-08-20 17:55:04.39085+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
84e635a5-0601-4670-a6e5-68562cd9e623	a165f6aa-148a-4ad0-953a-f154ae0991c8	EMP-5886	Integration Resource	\N	\N	integration.resource.e531fb2cecab4c6caa485682aeaa36eb@acme.co	\N	\N	Active	Resign	Notice already ended	2026-08-10	2026-08-19	Notice already ended	30 days	{}	{}	{}	2026-08-20 17:55:04.505815+05:30	\N	2026-08-20 17:55:04.510288+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
c96de1f8-bce4-46e6-8fc9-47d9cf00a613	080045f2-3ff3-49af-bced-4b10ea1dde6f	EMP-7266	Integration Resource	\N	\N	integration.resource.ce5bcae27dbc41978b56226b5bf1debf@acme.co	\N	\N	Probation	Resign	Integration test	2026-08-20	2026-09-19	Integration test	30 days	{}	{}	{}	2026-08-20 18:21:19.070579+05:30	\N	2026-08-20 18:21:19.272327+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
d11639b8-0639-498f-b29c-8aa7154fd2aa	649f4c6f-8719-4ff4-8969-7a55a16e43bd	EMP-8163	Integration Resource	\N	\N	integration.resource.55c6d73ab436476db67f6f1b9df80d8a@acme.co	\N	\N	Active	Resign	Notice already ended	2026-08-10	2026-08-19	Notice already ended	30 days	{}	{}	{}	2026-08-20 18:21:19.537054+05:30	\N	2026-08-20 18:21:19.547505+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
c86dbb9b-4d96-4e3a-b74a-a94fa9992605	96425efc-9b0e-4f2b-8fd6-ec3b77161547	EMP-3456	Dhanshree Pansare	Squad1	operation head	dhanshree.pansare@gmail.com	dhanshree.pansare002@gmail.com	9326178048	Probation	Resign	bo	2026-08-20	2026-11-18	bo	90 days	\N	\N	\N	2026-08-20 19:16:59.169476+05:30	\N	2026-08-20 19:16:59.255691+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
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
-- Data for Name: mst_countries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
01005b87-3f98-4425-8eb9-6417f2d83b41	JP	Japan	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
068fb26f-376a-4976-9127-b0dae76e7dcd	DK	Denmark	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
0a836600-60d1-4d2e-bbd7-034b338574ba	PK	Pakistan	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
1814186b-4a79-45ea-bfc9-bbdc4721e20b	PH	Philippines	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
1d3750a9-fab1-43fb-ab7b-865dda283bf3	AE	United Arab Emirates	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
1da1becb-cf4e-4eb4-a6d6-8615ce6100fb	GB	United Kingdom	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
25e6b9ec-058b-4778-9c17-1151079562f4	AT	Austria	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
28d63d80-4982-4a6b-9400-ee91260b2604	SA	Saudi Arabia	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
331cec37-bd6c-4a60-8ac5-b413d9677b8a	MX	Mexico	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
339b1d1f-d716-422e-9090-127430134420	US	United States	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
3f86bc47-1e09-482f-9671-9f4b5b089ee4	DE	Germany	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
4da9200f-5486-4710-bf58-e73778e1d506	ES	Spain	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
585fb67f-28ee-437c-aa84-fdc20a1a11d5	ZA	South Africa	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
58746abf-d5dc-4cc8-8a35-96a1747f7a1f	NZ	New Zealand	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
6044817c-ffa1-44b3-ac2a-05e52b97df4a	BR	Brazil	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
64ea0815-a39c-4ecb-b771-038dd74a9b7c	TH	Thailand	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
6e5c5f7b-ab38-4926-9945-da9ac35a35b0	BE	Belgium	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
6f9bb48d-5314-461c-aab8-3b47b00b27a1	NL	Netherlands	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
7190bc9f-d9d5-4bb3-b889-af8a1d6ec53f	LK	Sri Lanka	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
7c57576c-45b6-4cf0-b26d-d3e64730118b	QA	Qatar	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
8b34d450-add9-4da2-ab29-651c187ae702	CN	China	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
990888a7-50d0-45f0-b650-2686f87c4fd0	SE	Sweden	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
9bd3e0a8-de16-4a26-92aa-b43deae65bb7	IE	Ireland	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
9c93a091-0971-4080-b15f-ddebb9de6bb3	FI	Finland	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
a3228796-7e35-4710-9439-2aa36754dbbe	VN	Vietnam	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb	FR	France	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
a890f8b0-d80f-4a14-994e-0ba88d6336a9	NO	Norway	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
af68020d-22f0-4f66-91f6-afe82d052ddd	PL	Poland	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
b8307417-a01f-4b81-8f46-b637c865dc76	PT	Portugal	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
ba695b57-0f82-4ad0-b14a-2785b26209ff	CA	Canada	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
c093b0e3-31a9-40b4-840c-539ca86bc578	KR	South Korea	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
c1764720-16fe-4d3f-bd82-9882632239cd	IT	Italy	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
c9bb9747-7e0f-424e-864b-182d7a8c4230	NP	Nepal	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
d3791631-5e4b-4efa-a86a-59344c19e1a1	CH	Switzerland	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
d725a52a-22a3-48d6-b035-001c1aa15eae	MY	Malaysia	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
e341a797-6da6-4427-9bc1-f3271b6882c1	ID	Indonesia	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
ecb5e362-682e-46d2-bee2-ef0b022ebb13	BD	Bangladesh	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
eeb56a1f-9663-4d29-a984-30c4fc133de2	AU	Australia	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
f1d80739-30d7-4877-a1a7-ee414b074134	SG	Singapore	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	IN	India	t	2026-08-20 17:07:05.749911+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
2083db49-90d5-4f46-b4be-2d0a24edec35	operations	Operations	t	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N
3764a485-1786-470f-b3cb-eba4329f07cb	leadership	Leadership	t	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N
627cdb67-1e99-46ec-88ff-42b9c361fdc3	product	Product	t	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N
7f81ec90-a5fd-4a3e-ac7b-8797e545c431	engineering	Engineering	t	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N
92bfb4a4-87df-49ca-8f58-0b4add10f410	marketing	Marketing	t	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N
aad03f2b-8be9-45c8-a5d4-1082a639acc6	design	Design	t	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N
c21b43ad-98f5-43cb-9466-6f0b22ce7505	delivery	Delivery	t	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N
d0ab0dc3-606c-4d62-95ea-3d62749f9006	human_resources	Human Resources	t	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N
d32a6c00-a02a-4586-90c2-4a503b6efc3a	sales	Sales	t	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N
e91e9aa5-1cbb-4d1e-99fe-d7aefedd9f87	finance	Finance	t	2026-08-21 11:01:26.963654+05:30	\N	\N	\N	\N
6a43386d-7119-47d6-b95d-84d03b0b29f2	accounts	Accounts	t	2026-08-21 14:47:43.930064+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: mst_designations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
8802cfae-1dcb-4a34-a8cf-cf3de393ee1d	delivery_test_delivery	test delivery	t	c21b43ad-98f5-43cb-9466-6f0b22ce7505	2026-08-21 14:39:45.280716+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
580e71ef-8c9f-44d7-b3bb-e191d8708884	accounts_ca	CA	t	6a43386d-7119-47d6-b95d-84d03b0b29f2	2026-08-21 14:48:00.270122+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
eccddb98-13a9-4d79-82d6-3b97e710c83c	squad1_operation_head	operation head	t	\N	2026-08-20 19:09:27.933257+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0cbff6d6-9622-4d55-a0db-2e7b192988f3	business_analyst	Business Analyst	t	2083db49-90d5-4f46-b4be-2d0a24edec35	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
13d33d9b-c70e-4f07-897f-c9aa2bf89277	finance_analyst	Finance Analyst	t	e91e9aa5-1cbb-4d1e-99fe-d7aefedd9f87	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
28474f5e-661e-4e24-adfe-6dc0b41d340e	engineering_manager	Engineering Manager	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
38ab8071-cefe-47a1-a29a-793523aa82ae	marketing_lead	Marketing Lead	t	92bfb4a4-87df-49ca-8f58-0b4add10f410	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
3cc44614-05d3-4283-9b66-d95dd7ec5708	project_manager	Project Manager	t	2083db49-90d5-4f46-b4be-2d0a24edec35	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
56643cd3-35e5-429e-9b1c-385881443d8f	software_engineer	Software Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
593f83a4-8af6-4fe5-8e91-a465fa5055e9	sales_executive	Sales Executive	t	d32a6c00-a02a-4586-90c2-4a503b6efc3a	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
616911db-9bc2-4b40-b50f-2972f2c2f9e6	senior_software_engineer	Senior Software Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
65bbcacb-ccc4-4502-87d4-eb142c6b406c	content_strategist	Content Strategist	t	92bfb4a4-87df-49ca-8f58-0b4add10f410	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
6c5a2bdd-abe3-4b8c-85cc-3c01321f9690	senior_project_manager	Senior Project Manager	t	c21b43ad-98f5-43cb-9466-6f0b22ce7505	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
72466f60-859b-4946-998c-b34eb2c40c0e	tech_lead	Tech Lead	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
84f01f23-588a-4c7f-b8d8-826b8f210729	ux_designer	UX Designer	t	aad03f2b-8be9-45c8-a5d4-1082a639acc6	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
988d1399-4c1d-4969-b41f-b8c856ff93d5	qa_engineer	QA Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
a307f07d-c56a-47c9-8106-792773adb304	product_manager	Product Manager	t	627cdb67-1e99-46ec-88ff-42b9c361fdc3	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
ae14ab4e-70bf-4e3f-b201-5a7a50bb6b73	data_analyst	Data Analyst	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
d15a2e6e-0d0b-4a54-a80b-21c8e580302b	devops_engineer	DevOps Engineer	t	7f81ec90-a5fd-4a3e-ac7b-8797e545c431	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
dca2305b-b3c1-405b-a2ed-4eb6ffc3575f	hr_business_partner	HR Business Partner	t	d0ab0dc3-606c-4d62-95ea-3d62749f9006	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
e2d6a273-bb40-4b2e-a9b1-e4e5122ebab1	head_of_department	Head of Department	t	3764a485-1786-470f-b3cb-eba4329f07cb	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
f9aa2b6e-26a3-40db-bb37-9c88a1249304	engagement_manager	Engagement Manager	t	c21b43ad-98f5-43cb-9466-6f0b22ce7505	2026-08-18 13:25:36.166597+05:30	2026-08-21 11:01:26.963654+05:30	\N	\N	\N
\.


--
-- Data for Name: mst_industries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
7f460c51-01ec-4da1-8f71-d6f360b56f91	healthcare	Healthcare	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
f175fde9-14f8-40e8-b564-47d8a29d84ff	logistics	Logistics	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
c7e82721-829b-4450-8393-022587178471	energy	Energy	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
4a80bfdb-a191-4ce1-ab51-2142eb366db7	banking	Banking	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
02012f0c-97b2-4aea-a6b4-954ee97d892d	technology	Technology	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
4bf54de4-0e85-4904-a89f-542301b65077	automotive	Automotive	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
16ebeb23-b3d8-4fb7-a4f6-789510c28ad3	environment	Environment	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
935db8d7-e2aa-417e-839e-b51d00ce951e	retail	Retail	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
cd116cba-a939-4cb7-bd0f-233019a005b0	finance	Finance	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
e722474e-d845-42b8-978e-91a6ec78f080	manufacturing	Manufacturing	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
3a8e57e7-2f6d-4c84-9428-d11de98078c9	quantum_computing	Quantum Computing	t	2026-08-19 12:02:47.466308+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
ff5e83cc-9c1c-4056-ab0b-42a70714ddd3	media	Media	t	2026-08-20 11:45:51.759149+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
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
-- Data for Name: mst_roles; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
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
57540e48-c2e1-48ec-bb9c-f5478fa1359f	e7554ba2-e546-93ce-1e88-a073badd78a2	ATm4KuIOOCVexxs5tnhPe9/pl4bvRJnYZpHHaHX8u+c=	2026-08-14 13:27:04.149816+05:30	\N	\N	2026-08-07 13:27:04.149909+05:30	\N	\N	\N	\N
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
9d19c141-d9c5-425d-bb7a-eed830231768	40517b71-5e62-182e-73b5-d4070e20a3c2	bqPpTT6VJ4epYUU6JDxsphMmYQXbCRreUGxKqPNDzzo=	2026-08-28 11:51:37.975412+05:30	\N	\N	2026-08-21 11:51:37.975497+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
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
fd51c301-496a-49d0-b8d4-ce0f9ac7436c	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	uaTDuoA1EKZDjd6pLVcMTd8ym6KQzroRF3BUH8DpcVs=	2026-08-28 17:50:45.219749+05:30	\N	\N	2026-08-21 17:50:45.220722+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: role_permission_audits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permission_audits ("Id", "RoleId", "RoleName", "ModuleKey", "ModuleLabel", "SubmoduleKey", "SubmoduleLabel", "PermissionKey", "ActionLabel", "ChangeType", "PreviousValue", "NewValue", "ChangedById", "ChangedByName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
88b29a05-b10f-4354-a876-149f136cc2e4	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 17:56:35.149611+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
7349d427-c4e7-41d0-b228-2b0286454616	9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 17:56:35.257637+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
c7fbc590-b862-41ff-844e-404028893696	4e1cb2cf-a453-4b80-9ddc-2c6ee042290b	Admin	settings	Settings	\N	\N	settings.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 18:10:14.213209+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3a19b049-3e32-416e-ab23-3fc4de4dfb99	3de8ba61-fd83-4953-9f9e-11e7450ebccd	Admin (Dhanshree)	settings	Settings	\N	\N	settings.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-10 18:10:14.57319+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
09c6b7e6-3afa-4f62-80d7-c9c6765bf769	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	timesheets	My Team	\N	Timesheet Approval	timesheets:monitor	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
3b86eb60-342c-451e-b690-b52096246d9a	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.edit	Edit	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
5df58eb9-c159-4eaf-a477-76a8b655b9d9	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.approve	Approve	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
82405a7c-a273-4537-aa53-a73b646ebb92	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.delete	Delete	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
a559a2b3-e027-49fa-bf9d-ec03a9ccbea1	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	clients	Customers	\N	\N	clients:read	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
c35b8b3c-131c-4ab8-ab72-f7ee38bdd030	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.submit	Submit	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
c4d82d2b-13e4-4700-af05-7831feae8837	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	resources	Resources	\N	\N	resources:read	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
d8034b9b-9c0d-455d-9e2c-260d034dbc97	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.reject	Reject	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
de085f07-fe8f-4879-ac7c-531eba227ae0	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.create	Create	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-11 11:47:13.872233+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
fbe29092-0025-4ed8-b371-a7df24815955	911d3fd2-2e9a-4a85-a79a-49584031c854	HR	dashboard	Dashboard	\N	\N	dashboard.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-11 18:32:20.869905+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0670eddb-f4c5-4dd1-8bf8-4ee3b4b1e882	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	clients	Customers	\N	\N	clients:read	View	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
0da5da82-3835-41d1-8136-75d93db54412	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.create	Create	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
19ee29d9-8af2-4505-bf93-8d09beecf4c5	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	timesheets	My Team	\N	Timesheet Approval	timesheets:monitor	View	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
3f2a301a-2e36-4222-9178-2534b46a9406	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.view	View	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
4cfa5367-8142-4464-a3cd-2aac5532dc0d	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.reject	Reject	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
786e2053-8fed-4d43-a8b6-afbd5edb6e27	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.delete	Delete	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
a920b5fd-0845-4ac9-8d3c-a20969d7fe23	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.edit	Edit	granted	Denied	Allowed	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
d157430d-9b8c-4ada-b791-139015514bc6	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	resources	Resources	\N	\N	resources:read	View	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
d490836a-53a8-4878-a274-7406d1f0276f	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	projects	Projects	\N	\N	projects.edit	Edit	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
dbeb83dc-772f-4df2-833f-8154a02d3955	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	approvals	Approvals	\N	\N	approvals.approve	Approve	revoked	Allowed	Denied	40517b71-5e62-182e-73b5-d4070e20a3c2	Dhanshree	2026-08-13 12:12:59.550831+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") FROM stdin;
34331f88-e6f2-4e48-b6e7-7f6baef11ef9	Sales & Business Development	["dashboard.view", "projects.view", "projects.create", "projects.overview.view", "projects.overview.edit", "projects.health.view", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.create", "customers.edit", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:write", "projects:write", "wbs:read", "timesheets:submit"]	2026-08-07 13:19:59.669429+05:30	2026-08-10 17:53:35.786937+05:30	\N	\N	\N	Sales	Sales & business development — new projects and customers.	t	t
3cdaf36a-c349-4239-8533-df54dbdbb770	Team Lead	["dashboard.view", "projects.view", "projects.task.view", "projects.task.update-status", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "issues:raise", "timesheets:submit"]	2026-08-07 13:19:59.669429+05:30	2026-08-10 17:53:35.786937+05:30	\N	\N	\N	TeamLead	Leads a delivery team; submits timesheets and raises issues.	t	t
915f6e40-9ad3-49f9-bbf5-18375e5b49d5	Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]	2026-08-07 13:19:59.669429+05:30	2026-08-13 12:12:59.518317+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	ProjectManager	Runs assigned projects end-to-end; approves team timesheets.	t	t
3de8ba61-fd83-4953-9f9e-11e7450ebccd	Admin (Dhanshree)	["action-center.view", "approvals:manage", "approvals.approve", "approvals.reject", "approvals.view", "audit:read", "clients:approve", "clients:read", "clients:write", "customers.approve", "customers.assign", "customers.create", "customers.delete", "customers.edit", "customers.view", "dashboard.view", "invoices:payment", "invoices:raise", "issues:manage", "issues:raise", "my-team.dashboard.view", "my-team.my-timesheet.edit", "my-team.my-timesheet.submit", "my-team.my-timesheet.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.timesheet-approval.view", "portfolio.view", "projects:close", "projects:read", "projects:write", "projects.alerts.create", "projects.alerts.resolve", "projects.alerts.view", "projects.approve", "projects.assign", "projects.assigned-projects.view", "projects.budget.view", "projects.close", "projects.communication.create", "projects.communication.view", "projects.create", "projects.delete", "projects.edit", "projects.escalation.create", "projects.escalation.resolve", "projects.escalation.view", "projects.export", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.health-issues.view", "projects.health.comment", "projects.health.edit-issue", "projects.health.manage", "projects.health.raise-issue", "projects.health.resolve-issue", "projects.health.view", "projects.import", "projects.invoice-schedule.manage", "projects.invoice-schedule.view", "projects.overview.edit", "projects.overview.view", "projects.pmo.manage", "projects.pmo.view", "projects.prerequisite.manage", "projects.prerequisite.view", "projects.services-deliverables.manage", "projects.services-deliverables.view", "projects.task.assign", "projects.task.create", "projects.task.edit", "projects.task.update-status", "projects.task.view", "projects.team.assign", "projects.team.view", "projects.view", "reports:read", "reports.export", "reports.finance.view", "reports.view", "repository.view", "resources:manage", "resources:read", "resources.directory.view", "resources.kpi.view", "resources.manage", "resources.view", "roles:manage", "settings.audit.view", "settings.permissions.manage", "settings.permissions.view", "settings.roles.manage", "settings.roles.view", "settings.view", "timesheets:approve", "timesheets:monitor", "timesheets:submit", "users:manage", "wbs:allocate", "wbs:read", "wbs.allocate", "wbs.view"]	2026-08-07 13:19:59.669429+05:30	2026-08-11 11:42:16.314057+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	Dhanshree	Super-admin (legacy account) — full access to every module.	t	t
b7271bbe-68a7-4165-996e-869c030c76d3	HOD	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.approve", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "clients:read", "clients:approve", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]	2026-08-07 13:19:59.669429+05:30	2026-08-10 17:53:35.786937+05:30	\N	\N	\N	Hod	Department oversight across projects, resources and approvals.	t	t
911d3fd2-2e9a-4a85-a79a-49584031c854	HR	["resources.view", "resources.directory.view", "resources.manage", "repository.view", "resources:manage"]	2026-08-07 13:19:59.669429+05:30	2026-08-11 18:32:20.841494+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Hr	HR resource/directory management only.	t	t
9a4276e4-ddbf-438c-af7a-b4e123ae8271	Employee	["dashboard.view", "action-center.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "timesheets:submit", "issues:raise"]	2026-08-07 13:19:59.669429+05:30	2026-08-10 17:56:35.25597+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Employee	Executes assigned tasks; submits own timesheets.	t	t
1312980c-d7e6-4394-930e-477a5ae8ece8	Business Owner	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health-issues.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "portfolio.view", "clients:read", "projects:read", "reports:read"]	2026-08-07 13:19:59.669429+05:30	2026-08-10 17:53:35.786937+05:30	\N	\N	\N	BusinessOwner	Executive oversight of the project portfolio.	t	t
a5023c9e-367f-41e1-ba02-bdb2929edc89	Engagement Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]	2026-08-07 13:19:59.669429+05:30	2026-08-10 17:53:35.786937+05:30	\N	\N	\N	EngagementManager	Owns customer relationship and delivery for assigned accounts.	t	t
da95514a-1975-456d-ad0f-06fe33227e9b	Senior Project Manager	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "projects:close", "issues:raise", "issues:manage", "timesheets:approve"]	2026-08-07 13:19:59.669429+05:30	2026-08-10 17:53:35.786937+05:30	\N	\N	\N	SeniorPm	Owns delivery of assigned projects; approves PM timesheets.	t	t
fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde	PMO	["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.budget.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "approvals.view", "wbs.view", "wbs.allocate", "clients:read", "projects:read", "wbs:read", "wbs:allocate", "timesheets:monitor", "issues:manage", "resources:read", "reports:read", "approvals:manage"]	2026-08-07 13:19:59.669429+05:30	2026-08-10 17:53:35.786937+05:30	\N	\N	\N	Pmo	Governance, WBS allocation and timesheet monitoring (view-oriented).	t	t
4e1cb2cf-a453-4b80-9ddc-2c6ee042290b	Admin	["dashboard.view", "action-center.view", "projects.view", "projects:read", "projects.create", "projects:write", "projects.edit", "projects:write", "projects.delete", "projects:write", "projects.close", "projects:close", "projects.approve", "projects.assign", "projects.export", "projects.import", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "issues:raise", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health.manage", "issues:manage", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "projects.pmo.view", "projects.pmo.manage", "projects.prerequisite.view", "projects.prerequisite.manage", "projects.services-deliverables.view", "projects.services-deliverables.manage", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "invoices:raise", "invoices:payment", "projects.assigned-projects.view", "reports.view", "reports:read", "reports.export", "reports.finance.view", "resources.view", "resources:read", "resources.manage", "resources:manage", "resources.directory.view", "resources.kpi.view", "customers.view", "clients:read", "customers.create", "clients:write", "customers.edit", "clients:write", "customers.delete", "clients:write", "customers.approve", "clients:approve", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "timesheets:monitor", "my-team.timesheet-approval.approve", "timesheets:approve", "my-team.timesheet-approval.reject", "timesheets:approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit", "my-team.my-timesheet.edit", "wbs.view", "wbs:read", "wbs.allocate", "wbs:allocate", "approvals.view", "approvals:manage", "approvals.approve", "timesheets:approve", "approvals.reject", "timesheets:approve", "portfolio.view", "settings.view", "settings.roles.view", "settings.roles.manage", "roles:manage", "settings.permissions.view", "settings.permissions.manage", "users:manage", "settings.audit.view", "audit:read"]	2026-08-10 17:53:35.786937+05:30	2026-08-10 18:10:14.170813+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Admin	Super-admin — full access to every module, submodule and action.	t	t
cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	["dashboard.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "reports.view", "reports.export", "reports.finance.view", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "clients:read", "invoices:raise", "invoices:payment", "reports:read"]	2026-08-07 13:19:59.669429+05:30	2026-08-11 18:32:05.847002+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	Accounts	Finance — invoices, payments and finance reports.	t	t
\.


--
-- Data for Name: sub_ventures; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sub_ventures ("Id", "ClientId", "Name", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Notes") FROM stdin;
03e40de1-c4a7-425b-87ab-7d2b45ec364d	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Clinical Research	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
5fd7f539-0471-41ef-b4f9-f9c72071e117	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Biotech Division	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
fec11a61-59e0-4cfa-b03e-189789ceab63	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Manufacturing	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
15c89a23-7196-48e6-9c9c-0a10cc38cf80	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Global Healthcare	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
adc6d310-c567-4598-8bee-699791ca28cb	06cb7699-93b0-047f-0c59-b7f1baa24ec8	Helix Medical Devices	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
f8c2759e-1526-4499-93fe-4bf9383551a9	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Freight Services	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
b472f090-9382-4fcb-9a13-ad023a2b8edb	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Warehouse Operations	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
f701bcf7-0139-44fe-9188-1e2218afdb10	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith International Logistics	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
fb458d8a-fe51-4a06-a8cc-135b3784da0e	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Fleet Management	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
f453f787-9888-4058-8098-d99b9a89b9e1	428f81d7-182b-baf5-a71e-7b2216c94a1d	Zenith Express Delivery	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
58e5ee34-e198-47b6-9a9e-95903f56b20d	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Renewable Energy	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
d08681c8-6a5b-4c1e-af29-8997fa0e9de3	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Power Distribution	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
a34f1aad-ed5a-4eef-80e7-ffb186ac5a02	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Smart Grid	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
fbc527bd-d4b0-4a18-9ebb-b2ed0752da93	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Solar Division	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
eb5474ee-f271-4b23-b41e-dac2a1905a50	47e27c95-3686-6752-359c-e6a9e5f22e07	Lumen Energy Consulting	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
8f8671f4-01e4-42d9-ba2e-afc03d0a37d0	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Retail Banking	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
e2868bff-2f6e-41e5-a1fa-6451ca5a7f0f	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Corporate Banking	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
b5f5586f-63f0-4fe2-b864-89937fb76a72	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Digital Payments	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
c973cd24-655e-4de7-98e2-f0627d34696c	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Treasury Services	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
3ea7fd34-bce6-4d9c-868b-380ef2658536	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	Northwind Wealth Management	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
321598b3-aae4-4d07-a5b0-2e27cec16136	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync AI Platform	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
889e05ef-4311-474b-9d2e-23a7c5516aa2	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Cloud Infrastructure	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
8113f77c-878e-42bc-912b-5a7c388702a4	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Data Engineering	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
42304e00-59f2-4bed-b23b-87c4800caa16	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Machine Learning	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
bd25f3d8-a3a0-4135-a341-e13aeba728b5	a70cd580-74be-fff2-31b3-dcc06cc11f06	CloudSync Enterprise Solutions	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
e1b95e8b-302d-4cf3-9ab1-c6f0bd75d394	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Hospital Systems	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
3540c693-d4be-438c-a795-b11c7edd1f84	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Telemedicine	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
8789ae47-e505-4fb3-adf2-04ade91e418c	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Diagnostics	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
ee71d5b9-7d64-4cef-83a8-1195ff484538	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Health Analytics	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
30613fc3-38d9-45c8-9333-72a178f1e2b7	a8403352-05bc-3658-d6c2-55ac4d6bea24	MediCare Patient Services	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
fa9d3ecf-bd5f-4ccb-a03e-b574d8370f11	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Connected Vehicles	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
80d85beb-5a07-40f2-b7ae-2f6168a6755e	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Autonomous Systems	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
bf470ada-eecb-4ed7-9dc0-0c11436d2eec	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive EV Solutions	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
a9afcff9-fadd-4d29-aeab-d83159813cde	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Manufacturing	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
a5ddbee0-90a3-425b-be8d-bcb2b8e1acda	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	AutoDrive Smart Mobility	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
857a1e5d-ba2d-4499-9170-866e7f80596c	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Waste Management	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
7958d666-b744-4889-9c26-4d9152b5e23c	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Sustainability Consulting	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
c5b810e0-cf3c-46cf-91ca-615d583f7f9d	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Renewable Projects	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
c2c8966d-d634-45b1-b1e2-c231d2a91c16	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Water Management	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
6e5a495d-40be-4bb8-b40e-2480d3364bd3	f38ca416-9ecc-1214-1c54-42ecf337d858	EcoGreen Carbon Solutions	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
116ef6af-75e2-4743-af52-db5f71093752	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit E-Commerce	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
c10b586c-3015-46a1-9ca4-c8a0758788ef	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Hypermarket	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
0d158329-c66c-4427-b5e8-073bfab60dba	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Fashion	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
79de3aae-5152-44f0-9c77-0c54c3fd701d	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Supply Chain	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
9e067c55-cc90-48a0-ab8b-ded41dace8cb	f61741ca-2c63-917f-ee7f-ae00cdbc08cb	Orbit Digital Commerce	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
ac923fa9-3ecb-4ccb-a755-5b21621eea43	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Digital Banking	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
ed26b19c-dd44-4dbd-931f-32302088e02d	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Payment Solutions	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
7ac571e1-5915-46fb-b36d-64323d485e8a	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Lending	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
4b278fdd-0c00-477a-ac9f-8c3013de4149	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Investment Services	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
cab77d0e-e88a-4056-8712-a5a39ff91cd9	fb5d93e7-e434-c041-30e9-707384e99cf1	FinTech Risk & Compliance	2026-08-07 13:19:59.669429+05:30	\N	\N	\N	\N	\N
37f0c3b1-16a1-4643-9f5a-f824204543c1	9512ff00-e1ad-e1f7-537b-5d7103c7b0f0	subventure-northwindbank	2026-08-19 12:13:26.578788+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
f037ae82-e17c-4ffd-9ad3-f5e10a0e8817	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	sfsddf	2026-08-19 12:39:05.842701+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
6b55edc3-064f-468d-9084-54fbd72dc126	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	New Subventure	2026-08-20 15:51:44.125441+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
6a40584b-3bde-4c7d-a6e6-3ef920cd43d0	90fc8bcd-f45d-4bd4-88e7-a5543a0a9046	TATA-subventure	2026-08-20 16:30:13.739957+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
65c6925a-8948-4485-9d93-e596e1f4273e	a04ccf3a-81c8-4416-8af7-068717ddb22b	Morphle Machine desgining	2026-08-20 19:01:53.288995+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
d3af0a54-b527-40ca-ac1e-9fb09fd81504	a04ccf3a-81c8-4416-8af7-068717ddb22b	morphle labs	2026-08-20 19:04:48.394235+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
a69fe228-de12-44e5-9128-dc3898f67e5c	c8e5ec6b-a151-07b1-ec38-5c7e733dd013	IT	2026-08-21 15:35:12.642403+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users ("Id", "Email", "PasswordHash", "Name", "EmployeeId", "Department", "SubDepartment", "Avatar", "Designation", "IsActive", "MustChangePassword", "RoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "FailedLoginAttempts", "LastLoginAtUtc", "LockedUntilUtc", "PasswordChangedAtUtc") FROM stdin;
9f6f34df-dc47-f198-f3f6-e577aab1cbca	dev@acme.co	$2a$12$Ks2m13K9zMo3gcvv.oQSyukOXF3Y4q8phI.mQjBiokPHNSyVp7dSa	Dev Patel	u9	\N	\N	DP	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-11 11:50:37.412783+05:30	\N	2026-08-10 12:27:47.765224+05:30
cf106b1b-6a96-464f-aa63-ddcb77a737e0	new.pm@acme.co	$2a$12$p.MfI7wlBAX2LZkpEvPoEunU.q5UljNMmswtXsI80UcJj8X2CVWM.	New PM	u99	\N	\N	\N	PM	t	t	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	2026-08-07 13:25:45.951114+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	0	\N	\N	\N
a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	admin@acme.co	$2a$12$b2JtQGvsufasVJcscUVaf.UqUtMwf9/vKEcWdmmOoOLkczd0mUdrW	Admin User	u15	\N	\N	AU	\N	t	f	4e1cb2cf-a453-4b80-9ddc-2c6ee042290b	2026-08-10 17:53:35.786937+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-21 16:29:54.285259+05:30	\N	\N
a37e30de-15f3-bf1e-fa9f-4a98da9033ab	vikram@acme.co	$2a$12$FBiOs3uj4C/jeMJs4bJYI.srSoNYxHArv8hF3Yu4ioH1u9SixM3hW	Vikram Shah	u3	\N	\N	VS	\N	t	f	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-20 10:52:57.26898+05:30	\N	\N
a3a20ac4-43a2-de64-52d3-bfafce7c7053	sana@acme.co	$2a$12$4wMeuwyVuQwNnnEMOETf9.KDeAHOEaxSdl7H5DCdjZ6OwCa7/8Ppi	Sana Iyer	u4	\N	\N	SI	\N	t	f	915f6e40-9ad3-49f9-bbf5-18375e5b49d5	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-17 12:39:47.329355+05:30	\N	\N
b1d3f51c-b209-d352-4b52-3f4008801ab3	kavya@acme.co	$2a$12$tvy6i6cIwMPxznzWYZnWvOAo3EQbgcismc.iBPMREU7kdQLcPW8ZG	Kavya Nair	u10	\N	\N	KN	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-11 17:21:44.284921+05:30	\N	\N
1a077a8c-4029-8ded-d563-19e9b4bdf301	aarav@acme.co	$2a$12$Z8NFnaolFNK3Q6VDZ1Cow.u3q1I/edVZC/jhDnEBj4ZpuxTJHmT.i	Aarav Mehta	u1	\N	\N	AM	\N	t	f	da95514a-1975-456d-ad0f-06fe33227e9b	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-17 17:52:51.492258+05:30	\N	\N
30d629ff-3076-40f8-9c12-fb385b8c2600	admin2@acme.co	$2a$12$aqJIdIL9tzPW5DFE.zVFVurFkCUE0knMbU7.A0A1pBtjA7K4Qk7wS	Test Admin Two	A2	\N	\N	\N	\N	f	t	3de8ba61-fd83-4953-9f9e-11e7450ebccd	2026-08-07 13:45:16.235641+05:30	2026-08-07 13:45:23.702021+05:30	40517b71-5e62-182e-73b5-d4070e20a3c2	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	0	\N	\N	\N
2bca17e7-5b71-8ac3-6c86-440cb3b75bab	vikrant@acme.co	$2a$12$S6xJaiLDIWWkO6v/Wg.xlefjHqovXP9IaO5vFYdL7Ho//iH8ROZjS	Vikrant Malhotra	u13	\N	\N	VM	\N	t	f	1312980c-d7e6-4394-930e-477a5ae8ece8	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-10 12:29:34.903769+05:30	\N	2026-08-10 12:29:52.170405+05:30
a1878763-b174-41b0-88db-f2ebba76af83	sdsa@gmail.com	$2a$12$.bzyuW3FFq2Uau84IyFnYO1LXxDLXkbxtjVyvzVs71KECK6u2CONy	sadas	ads	sda	\N	\N	sda	t	t	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 15:00:46.654787+05:30	\N	40517b71-5e62-182e-73b5-d4070e20a3c2	\N	\N	0	\N	\N	\N
304a42eb-2921-d04b-1bb8-e77b9bf6eb5a	anita@acme.co	$2a$12$1IsDiKmr8gDoVCIKvlYPzOtr.ABeZepjWoisxVeK2bFczErcmHjwO	Anita Desai	u12	\N	\N	AD	\N	t	f	b7271bbe-68a7-4165-996e-869c030c76d3	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-19 13:49:46.145648+05:30	\N	\N
40517b71-5e62-182e-73b5-d4070e20a3c2	dhanshree@acme.co	$2a$12$lZaaacMFr3quKIhayJtpc.jwf5oaoDzTuOv10sDg8yDsV2igOwaGm	Dhanshree	u14	\N	\N	DS	\N	t	f	3de8ba61-fd83-4953-9f9e-11e7450ebccd	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-21 11:51:37.97411+05:30	\N	2026-08-10 12:32:04.244561+05:30
47dcdad8-eaf3-989d-8f94-a6ba5b2e8aac	hr@acme.co	$2a$12$Q5NGoB8ldfMCsjqEB6jGcuwFyAToUDKHwI7fzSGgR5yYMteNmeZ.2	HR User	u16	\N	\N	HU	\N	t	f	911d3fd2-2e9a-4a85-a79a-49584031c854	2026-08-10 17:53:35.786937+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-20 12:01:20.644786+05:30	\N	\N
49c4e7da-23ec-aab1-9fdf-61dd23764d10	nikhil@acme.co	$2a$12$GHUMHN3rwHVArXhcNuaGu.h425xy4r6HtJrSrQX5g2vAOqHt8V2ES	Nikhil Rao	u5	\N	\N	NR	\N	t	f	3cdaf36a-c349-4239-8533-df54dbdbb770	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	\N	\N	\N
65e2ffa3-6073-780a-b849-4d9604c7251c	priya@acme.co	$2a$12$JwML0SIKXSWlRgptP92MnO.Ukd4jFZiMDiiNjIyLZ.ZZ1Q/ptCrGa	Priya Verma	u6	\N	\N	PV	\N	t	f	3cdaf36a-c349-4239-8533-df54dbdbb770	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-10 18:27:13.729958+05:30	\N	\N
730809c0-fc01-a664-03ca-28e0e32d0393	sales@acme.co	$2a$12$FFAmqyNMtRQ5naLD8gGlC.wju/apsFk17Z7XRz15t6gOT8Zb3WNgm	Sales User	u18	\N	\N	SU	\N	t	f	34331f88-e6f2-4e48-b6e7-7f6baef11ef9	2026-08-10 17:53:35.786937+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-20 11:21:54.138041+05:30	\N	\N
e7554ba2-e546-93ce-1e88-a073badd78a2	riya@acme.co	$2a$12$nLcb.DFHf.wuYZ1d10nizezQb52Pd/xNGus1i36PaWklDWRP1kmYa	Riya Kapoor	u2	\N	\N	RK	\N	t	f	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-07 13:27:04.148765+05:30	\N	2026-08-07 13:27:03.565302+05:30
f2f23eb1-efb6-f0a7-c57e-0ead09121a21	arjun@acme.co	$2a$12$28Cu5PgexUJgvbXBsUXdF.UH5FIW57bAZuoyn/uAw0vw1NQHD.mze	Arjun Singh	u7	\N	\N	AS	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-21 12:54:18.426443+05:30	\N	\N
111775f6-5d80-5333-478e-68e2fda584fa	meera@acme.co	$2a$12$FF6xY8Ph1PmSonf06f/uM.xhSiaPfxGbTayQFzwDrfOKkoDRE/nGC	Meera Joshi	u8	\N	\N	MJ	\N	t	f	9a4276e4-ddbf-438c-af7a-b4e123ae8271	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-11 16:55:29.999149+05:30	\N	\N
b2a4f2d1-37d8-8e80-1f1c-6673ea41ffb9	rahul@acme.co	$2a$12$A6QBZLzFtmbFt25iwcWhwekWRvUMqt0ZvOaRSV5Mqwf2KDECdBzHC	Rahul Gupta	u11	\N	\N	RG	\N	t	f	fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde	2026-08-07 13:19:59.669429+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	2026-08-18 12:39:23.505267+05:30	\N	\N
dc139a9d-b996-7354-6c27-72659ea2fd59	accounts@acme.co	$2a$12$hUK0NiNvbiFEjFbwgtafd.ri6Ib3hGpEEO9VnMHNIxxFJ8iKTscUu	Accounts User	u17	\N	\N	AC	\N	t	f	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-08-10 17:53:35.786937+05:30	2026-08-21 17:36:31.568108+05:30	\N	\N	\N	0	\N	\N	\N
\.


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
-- Name: refresh_tokens PK_refresh_tokens; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT "PK_refresh_tokens" PRIMARY KEY ("Id");


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
-- Name: users PK_users; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_users" PRIMARY KEY ("Id");


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
-- Name: IX_employees_JobRoleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employees_JobRoleId" ON public.employees USING btree ("JobRoleId");


--
-- Name: IX_employees_NationalityId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_employees_NationalityId" ON public.employees USING btree ("NationalityId");


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
-- Name: IX_mst_cities_Code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_cities_Code" ON public.mst_cities USING btree ("Code");


--
-- Name: IX_mst_cities_CountryId_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_cities_CountryId_Name" ON public.mst_cities USING btree ("CountryId", "Name");


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
-- Name: IX_mst_designations_DepartmentId_Name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_designations_DepartmentId_Name" ON public.mst_designations USING btree ("DepartmentId", "Name");


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
-- Name: IX_refresh_tokens_TokenHash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_refresh_tokens_TokenHash" ON public.refresh_tokens USING btree ("TokenHash");


--
-- Name: IX_refresh_tokens_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_refresh_tokens_UserId" ON public.refresh_tokens USING btree ("UserId");


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
-- Name: IX_users_Email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_users_Email" ON public.users USING btree ("Email");


--
-- Name: IX_users_EmployeeId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_users_EmployeeId" ON public.users USING btree ("EmployeeId");


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
-- Name: mst_roles FK_mst_roles_mst_designations_DesignationId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mst_roles
    ADD CONSTRAINT "FK_mst_roles_mst_designations_DesignationId" FOREIGN KEY ("DesignationId") REFERENCES public.mst_designations("Id") ON DELETE RESTRICT;


--
-- Name: refresh_tokens FK_refresh_tokens_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT "FK_refresh_tokens_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE CASCADE;


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
-- Name: users FK_users_roles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "FK_users_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public.roles("Id") ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict rFHC1zE1RNcnN78Y0yCCt14bqsRvGzRE3L6H3fWptuPc10dvhkHW8skdBh0VEgL

