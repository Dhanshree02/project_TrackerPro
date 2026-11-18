--
-- PostgreSQL database dump
--


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
-- Name: action; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA action;


--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: customer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA customer;


--
-- Name: hangfire; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA hangfire;


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
-- Name: sla; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA sla;


--
-- Name: timesheet; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA timesheet;


--
-- Name: fn_protect_default_permissions(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.fn_protect_default_permissions() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."DefaultCanView" IS DISTINCT FROM OLD."DefaultCanView" OR
       NEW."DefaultCanManage" IS DISTINCT FROM OLD."DefaultCanManage" THEN

        -- Allow postgres superuser to change defaults (for UAT fixes / developer corrections)
        IF current_user = 'postgres' THEN
            RETURN NEW;
        END IF;

        RAISE EXCEPTION
            'DefaultCanView and DefaultCanManage are protected baselines. '
            'Only a developer with direct DB access (postgres) can modify them.';
    END IF;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tbl_bucket_tasks; Type: TABLE; Schema: action; Owner: -
--

CREATE TABLE action.tbl_bucket_tasks (
    "Id" uuid NOT NULL,
    "TaskId" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "ProjectServiceId" uuid,
    "AssignmentId" uuid,
    "EmployeeId" uuid NOT NULL,
    "AssignedById" uuid,
    "AssignedByName" character varying(200),
    "TaskTitle" character varying(255) NOT NULL,
    "ProjectName" character varying(255) NOT NULL,
    "Priority" character varying(50) DEFAULT 'Medium'::character varying NOT NULL,
    "DueDate" date,
    "Status" character varying(60) DEFAULT 'Not Started'::character varying NOT NULL,
    "ActualStartDate" date,
    "ActualEndDate" date,
    "TimerRunning" boolean DEFAULT false NOT NULL,
    "TimerStartedAtUtc" timestamp with time zone,
    "TimerAccumulatedSeconds" bigint DEFAULT 0 NOT NULL,
    "UtilizedHours" numeric(10,2) DEFAULT 0 NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_notifications_number_seq; Type: SEQUENCE; Schema: action; Owner: -
--

CREATE SEQUENCE action.tbl_notifications_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_notifications; Type: TABLE; Schema: action; Owner: -
--

CREATE TABLE action.tbl_notifications (
    "Id" uuid NOT NULL,
    "RecipientEmployeeId" uuid NOT NULL,
    "ProjectId" uuid,
    "ProjectCode" character varying(50),
    "ProjectName" character varying(255),
    "Title" character varying(255) NOT NULL,
    "Type" character varying(100) NOT NULL,
    "Priority" character varying(20) NOT NULL,
    "Status" character varying(50) DEFAULT 'Pending'::character varying NOT NULL,
    "Unread" boolean DEFAULT true NOT NULL,
    "RaisedByEmployeeId" uuid,
    "RaisedByName" character varying(255) DEFAULT 'System'::character varying NOT NULL,
    "RelatedTask" character varying(255),
    "IssueId" uuid,
    "HistoryJson" text DEFAULT '[]'::text NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "CommentsJson" text DEFAULT '[]'::text NOT NULL,
    "NotificationNumber" integer DEFAULT nextval('action.tbl_notifications_number_seq'::regclass),
    "ServiceEscalationId" uuid
);


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
    "DefaultCanView" smallint DEFAULT 0 NOT NULL,
    "DefaultCanManage" smallint DEFAULT 0 NOT NULL,
    CONSTRAINT "CHK_role_perm_can_manage" CHECK (("CanManage" = ANY (ARRAY[0, 1]))),
    CONSTRAINT "CHK_role_perm_can_view" CHECK (("CanView" = ANY (ARRAY[0, 1]))),
    CONSTRAINT "CHK_role_perm_default_can_manage" CHECK (("DefaultCanManage" = ANY (ARRAY[0, 1]))),
    CONSTRAINT "CHK_role_perm_default_can_view" CHECK (("DefaultCanView" = ANY (ARRAY[0, 1]))),
    CONSTRAINT "CHK_role_perm_default_manage_requires_view" CHECK ((("DefaultCanManage" = 0) OR ("DefaultCanView" = 1))),
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
-- Name: aggregatedcounter; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.aggregatedcounter (
    id bigint NOT NULL,
    key text NOT NULL,
    value bigint NOT NULL,
    expireat timestamp with time zone
);


--
-- Name: aggregatedcounter_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: -
--

CREATE SEQUENCE hangfire.aggregatedcounter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aggregatedcounter_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: -
--

ALTER SEQUENCE hangfire.aggregatedcounter_id_seq OWNED BY hangfire.aggregatedcounter.id;


--
-- Name: counter; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.counter (
    id bigint NOT NULL,
    key text NOT NULL,
    value bigint NOT NULL,
    expireat timestamp with time zone
);


--
-- Name: counter_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: -
--

CREATE SEQUENCE hangfire.counter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: counter_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: -
--

ALTER SEQUENCE hangfire.counter_id_seq OWNED BY hangfire.counter.id;


--
-- Name: hash; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.hash (
    id bigint NOT NULL,
    key text NOT NULL,
    field text NOT NULL,
    value text,
    expireat timestamp with time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


--
-- Name: hash_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: -
--

CREATE SEQUENCE hangfire.hash_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hash_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: -
--

ALTER SEQUENCE hangfire.hash_id_seq OWNED BY hangfire.hash.id;


--
-- Name: job; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.job (
    id bigint NOT NULL,
    stateid bigint,
    statename text,
    invocationdata jsonb NOT NULL,
    arguments jsonb NOT NULL,
    createdat timestamp with time zone NOT NULL,
    expireat timestamp with time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


--
-- Name: job_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: -
--

CREATE SEQUENCE hangfire.job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: -
--

ALTER SEQUENCE hangfire.job_id_seq OWNED BY hangfire.job.id;


--
-- Name: jobparameter; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.jobparameter (
    id bigint NOT NULL,
    jobid bigint NOT NULL,
    name text NOT NULL,
    value text,
    updatecount integer DEFAULT 0 NOT NULL
);


--
-- Name: jobparameter_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: -
--

CREATE SEQUENCE hangfire.jobparameter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobparameter_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: -
--

ALTER SEQUENCE hangfire.jobparameter_id_seq OWNED BY hangfire.jobparameter.id;


--
-- Name: jobqueue; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.jobqueue (
    id bigint NOT NULL,
    jobid bigint NOT NULL,
    queue text NOT NULL,
    fetchedat timestamp with time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


--
-- Name: jobqueue_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: -
--

CREATE SEQUENCE hangfire.jobqueue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobqueue_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: -
--

ALTER SEQUENCE hangfire.jobqueue_id_seq OWNED BY hangfire.jobqueue.id;


--
-- Name: list; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.list (
    id bigint NOT NULL,
    key text NOT NULL,
    value text,
    expireat timestamp with time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


--
-- Name: list_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: -
--

CREATE SEQUENCE hangfire.list_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: list_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: -
--

ALTER SEQUENCE hangfire.list_id_seq OWNED BY hangfire.list.id;


--
-- Name: lock; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.lock (
    resource text NOT NULL,
    updatecount integer DEFAULT 0 NOT NULL,
    acquired timestamp with time zone
);


--
-- Name: schema; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.schema (
    version integer NOT NULL
);


--
-- Name: server; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.server (
    id text NOT NULL,
    data jsonb,
    lastheartbeat timestamp with time zone NOT NULL,
    updatecount integer DEFAULT 0 NOT NULL
);


--
-- Name: set; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.set (
    id bigint NOT NULL,
    key text NOT NULL,
    score double precision NOT NULL,
    value text NOT NULL,
    expireat timestamp with time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


--
-- Name: set_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: -
--

CREATE SEQUENCE hangfire.set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: set_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: -
--

ALTER SEQUENCE hangfire.set_id_seq OWNED BY hangfire.set.id;


--
-- Name: state; Type: TABLE; Schema: hangfire; Owner: -
--

CREATE TABLE hangfire.state (
    id bigint NOT NULL,
    jobid bigint NOT NULL,
    name text NOT NULL,
    reason text,
    createdat timestamp with time zone NOT NULL,
    data jsonb,
    updatecount integer DEFAULT 0 NOT NULL
);


--
-- Name: state_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: -
--

CREATE SEQUENCE hangfire.state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: state_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: -
--

ALTER SEQUENCE hangfire.state_id_seq OWNED BY hangfire.state.id;


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
-- Name: mst_leave_calendar; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.mst_leave_calendar (
    "Id" uuid NOT NULL,
    "HolidayDate" date NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Year" integer NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "Tag" character varying(100) DEFAULT 'Public Holiday'::character varying NOT NULL,
    "Color" character varying(50) DEFAULT '#a6c63a'::character varying NOT NULL,
    "Description" character varying(500)
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
    "DeletedAtUtc" timestamp with time zone,
    "Abbreviation" character varying(50)
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
-- Name: tbl_project_additional_requirements; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_additional_requirements (
    "Id" uuid NOT NULL,
    "RequirementId" character varying(50) NOT NULL,
    "ProjectId" uuid NOT NULL,
    "ClientName" character varying(255),
    "ProjectName" character varying(255),
    "RequirementType" character varying(50) DEFAULT 'Add Service'::character varying NOT NULL,
    "Title" character varying(255) NOT NULL,
    "Description" text NOT NULL,
    "Priority" character varying(50) DEFAULT 'Medium'::character varying NOT NULL,
    "RequestedByEmployeeId" uuid,
    "RequestedByName" character varying(255) NOT NULL,
    "RequestedDate" date NOT NULL,
    "AttachmentFileName" character varying(255),
    "AttachmentPath" text,
    "ScopeCancellationService" character varying(255),
    "Status" character varying(50) DEFAULT 'Open'::character varying NOT NULL,
    "ApprovedAtUtc" timestamp with time zone,
    "ApprovedByEmployeeId" uuid,
    "ApprovedByName" character varying(255),
    "ApprovalComments" text,
    "CommentsJson" text DEFAULT '[]'::text NOT NULL,
    "HistoryJson" text DEFAULT '[]'::text NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_alerts; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_alerts (
    "Id" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "IssueId" uuid,
    "Title" character varying(300) NOT NULL,
    "Description" text,
    "AlertType" character varying(100) DEFAULT 'Issue'::character varying NOT NULL,
    "Priority" character varying(20) DEFAULT 'Medium'::character varying NOT NULL,
    "Status" character varying(30) DEFAULT 'Open'::character varying NOT NULL,
    "RaisedByEmployeeId" uuid,
    "RaisedByName" character varying(200) NOT NULL,
    "AudienceUserIds" text,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    "Owner" character varying(255),
    "ResolutionOwner" character varying(255),
    "EscalationOwner" character varying(255),
    "ResolutionDetails" text,
    "HistoryJson" text DEFAULT '[]'::text NOT NULL,
    "StatusChangedBy" character varying(255),
    "StatusChangedAtUtc" timestamp with time zone,
    "AttachmentFileName" character varying(255),
    "AttachmentPath" text,
    "ExpectedResolutionDate" character varying(50),
    "ServiceName" character varying(255),
    "EscalationType" character varying(100),
    "EscalatedTo" text,
    "ServiceEscalationId" uuid,
    "ChatJson" text
);


--
-- Name: tbl_project_appreciations; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_appreciations (
    "Id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "ProjectId" uuid NOT NULL,
    "RecipientEmployeeId" uuid NOT NULL,
    "RecipientName" character varying(200) NOT NULL,
    "RecipientEmail" character varying(200),
    "RecipientRole" character varying(100),
    "Badge" character varying(100) NOT NULL,
    "Message" text NOT NULL,
    "GivenByEmployeeId" uuid,
    "GivenByName" character varying(200) NOT NULL,
    "CreatedAtUtc" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "DeletedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid
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
    "DeletedAtUtc" timestamp with time zone,
    "CommentsJson" text,
    "HistoryJson" text
);


--
-- Name: tbl_project_feedbacks; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_feedbacks (
    "Id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "ProjectId" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "EmployeeName" character varying(200) NOT NULL,
    "EmployeeCode" character varying(50),
    "ReportingManagerId" uuid,
    "ReportingManagerName" character varying(200),
    "SubmittedByEmployeeId" uuid,
    "SubmittedByName" character varying(200) NOT NULL,
    "FeedbackType" character varying(50) DEFAULT 'DirectFeedback'::character varying NOT NULL,
    "Strengths" character varying(100),
    "AreasOfImprovement" character varying(100),
    "Comments" character varying(100),
    "Rating" integer,
    "RequestNote" text,
    "Status" character varying(50) DEFAULT 'Submitted'::character varying NOT NULL,
    "CommentsJson" text DEFAULT '[]'::text,
    "HistoryJson" text DEFAULT '[]'::text,
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "DeletedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid
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
    "PaymentStatus" character varying(40),
    "ProjectServiceId" uuid
);


--
-- Name: tbl_project_issues; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_issues (
    "Id" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "ProjectCode" character varying(50),
    "ProjectName" character varying(300) NOT NULL,
    "IssueType" character varying(100) NOT NULL,
    "Priority" character varying(20) NOT NULL,
    "Subject" character varying(300) NOT NULL,
    "Description" text NOT NULL,
    "Status" character varying(30) DEFAULT 'Open'::character varying NOT NULL,
    "RaisedByEmployeeId" uuid,
    "RaisedByName" character varying(200) NOT NULL,
    "RaisedByRole" character varying(100),
    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone
);


--
-- Name: tbl_project_service_escalation_stakeholders; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_project_service_escalation_stakeholders (
    "Id" uuid NOT NULL,
    "EscalationId" uuid CONSTRAINT "tbl_project_service_escalation_stakeholde_EscalationId_not_null" NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "EmployeeName" character varying(200) CONSTRAINT "tbl_project_service_escalation_stakeholde_EmployeeName_not_null" NOT NULL,
    "SubDepartment" character varying(160) CONSTRAINT "tbl_project_service_escalation_stakehold_SubDepartment_not_null" NOT NULL,
    "Status" character varying(20) NOT NULL,
    "CreatedAtUtc" timestamp with time zone CONSTRAINT "tbl_project_service_escalation_stakeholde_CreatedAtUtc_not_null" NOT NULL,
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
    "DeletedAtUtc" timestamp with time zone,
    "ChatJson" text
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
    "ValidationStatus" character varying(40) DEFAULT 'Pending To Validate'::character varying NOT NULL,
    "ChangeStatus" character varying(50) DEFAULT 'Active'::character varying NOT NULL,
    "OriginalQty" integer,
    "PendingQty" integer,
    "PendingResourceLevel" character varying(500),
    "PendingUnitPrice" numeric(18,2),
    "ModCollectionStatus" character varying(50),
    "ModValidationStatus" character varying(50),
    "ModBillingStatus" character varying(50),
    "ModIsReady" boolean,
    "ServiceAbbreviation" character varying(50)
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
    "DeletedAtUtc" timestamp with time zone,
    "TaskType" character varying(50)
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
-- Name: tbl_resource_allocation_requests; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.tbl_resource_allocation_requests (
    "Id" uuid NOT NULL,
    "ProjectId" uuid NOT NULL,
    "EmployeeId" uuid NOT NULL,
    "DepartmentId" uuid,
    "SubDepartment" character varying(200),
    "AllocationStartDate" date NOT NULL,
    "AllocationEndDate" date NOT NULL,
    "Billability" character varying(50) DEFAULT 'Billable'::character varying NOT NULL,
    "IsTeamLead" boolean DEFAULT false NOT NULL,
    "ResourceType" character varying(50) DEFAULT 'Dedicated'::character varying NOT NULL,
    "IsShadowTeam" boolean DEFAULT false NOT NULL,
    "Status" character varying(50) DEFAULT 'Pending'::character varying NOT NULL,
    "RequestedByEmployeeId" uuid,
    "RequestedByName" character varying(200),
    "ApproverEmployeeId" uuid,
    "ApproverName" character varying(200),
    "CommentsJson" text,
    "HistoryJson" text,
    "CreatedAtUtc" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
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
    "SubDepartmentId" uuid,
    "OriginalRole" character varying(80)
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
-- Name: tbl_sla_events; Type: TABLE; Schema: sla; Owner: -
--

CREATE TABLE sla.tbl_sla_events (
    id uuid NOT NULL,
    instanceid uuid NOT NULL,
    eventtype character varying(50) NOT NULL,
    scheduledatutc timestamp with time zone,
    executedatutc timestamp with time zone,
    hangfirejobid character varying(100),
    status character varying(50) DEFAULT 'Scheduled'::character varying NOT NULL,
    stageatexecution character varying(100) DEFAULT 'Default'::character varying NOT NULL,
    targetrolesjson text DEFAULT '[]'::text NOT NULL,
    targetrecipientidsjson text DEFAULT '[]'::text NOT NULL,
    executionlog text,
    retrycount integer DEFAULT 0 NOT NULL,
    createdatutc timestamp with time zone NOT NULL,
    updatedatutc timestamp with time zone,
    deletedatutc timestamp with time zone,
    createdby uuid,
    updatedby uuid,
    idempotencykey character varying(150)
);


--
-- Name: tbl_sla_instances; Type: TABLE; Schema: sla; Owner: -
--

CREATE TABLE sla.tbl_sla_instances (
    id uuid NOT NULL,
    policyid uuid NOT NULL,
    module character varying(100) NOT NULL,
    activitytype character varying(100) NOT NULL,
    entityid uuid NOT NULL,
    entityreference character varying(100),
    currentstage character varying(100) DEFAULT 'Default'::character varying NOT NULL,
    status character varying(50) DEFAULT 'Tracking'::character varying NOT NULL,
    priority character varying(50) DEFAULT 'Medium'::character varying NOT NULL,
    startedatutc timestamp with time zone NOT NULL,
    targetdeadlineutc timestamp with time zone NOT NULL,
    breachedatutc timestamp with time zone,
    completedatutc timestamp with time zone,
    cancelledatutc timestamp with time zone,
    pausedatutc timestamp with time zone,
    totalpausedseconds integer DEFAULT 0 NOT NULL,
    activehangfirejobid character varying(100),
    recipientemployeeid uuid,
    projectid uuid,
    custompayloadjson text DEFAULT '{}'::text NOT NULL,
    createdatutc timestamp with time zone NOT NULL,
    updatedatutc timestamp with time zone,
    deletedatutc timestamp with time zone,
    createdby uuid,
    updatedby uuid
);


--
-- Name: tbl_sla_policies; Type: TABLE; Schema: sla; Owner: -
--

CREATE TABLE sla.tbl_sla_policies (
    id uuid NOT NULL,
    module character varying(100) NOT NULL,
    activitytype character varying(100) NOT NULL,
    stage character varying(100) DEFAULT 'Default'::character varying NOT NULL,
    name character varying(200) NOT NULL,
    description character varying(500),
    tatdurationminutes integer NOT NULL,
    calculationmode character varying(50) DEFAULT 'WorkingHours'::character varying NOT NULL,
    workinghoursstart interval DEFAULT '09:00:00'::interval,
    workinghoursend interval DEFAULT '18:00:00'::interval,
    excludeweekends boolean DEFAULT true NOT NULL,
    excludeholidays boolean DEFAULT true NOT NULL,
    reminderintervalsminutesjson text DEFAULT '[]'::text NOT NULL,
    firstescalationafterminutes integer DEFAULT 60,
    secondescalationafterminutes integer DEFAULT 180,
    responsiblerolesjson text DEFAULT '[]'::text NOT NULL,
    firstescalationrolesjson text DEFAULT '[]'::text NOT NULL,
    secondescalationrolesjson text DEFAULT '[]'::text NOT NULL,
    isactive boolean DEFAULT true NOT NULL,
    metadatajson text DEFAULT '{}'::text NOT NULL,
    createdatutc timestamp with time zone NOT NULL,
    updatedatutc timestamp with time zone,
    deletedatutc timestamp with time zone,
    createdby uuid,
    updatedby uuid
);


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
-- Name: aggregatedcounter id; Type: DEFAULT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.aggregatedcounter ALTER COLUMN id SET DEFAULT nextval('hangfire.aggregatedcounter_id_seq'::regclass);


--
-- Name: counter id; Type: DEFAULT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.counter ALTER COLUMN id SET DEFAULT nextval('hangfire.counter_id_seq'::regclass);


--
-- Name: hash id; Type: DEFAULT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.hash ALTER COLUMN id SET DEFAULT nextval('hangfire.hash_id_seq'::regclass);


--
-- Name: job id; Type: DEFAULT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.job ALTER COLUMN id SET DEFAULT nextval('hangfire.job_id_seq'::regclass);


--
-- Name: jobparameter id; Type: DEFAULT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.jobparameter ALTER COLUMN id SET DEFAULT nextval('hangfire.jobparameter_id_seq'::regclass);


--
-- Name: jobqueue id; Type: DEFAULT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.jobqueue ALTER COLUMN id SET DEFAULT nextval('hangfire.jobqueue_id_seq'::regclass);


--
-- Name: list id; Type: DEFAULT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.list ALTER COLUMN id SET DEFAULT nextval('hangfire.list_id_seq'::regclass);


--
-- Name: set id; Type: DEFAULT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.set ALTER COLUMN id SET DEFAULT nextval('hangfire.set_id_seq'::regclass);


--
-- Name: state id; Type: DEFAULT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.state ALTER COLUMN id SET DEFAULT nextval('hangfire.state_id_seq'::regclass);


--
-- Data for Name: tbl_bucket_tasks; Type: TABLE DATA; Schema: action; Owner: -
--

COPY action.tbl_bucket_tasks ("Id", "TaskId", "ProjectId", "ProjectServiceId", "AssignmentId", "EmployeeId", "AssignedById", "AssignedByName", "TaskTitle", "ProjectName", "Priority", "DueDate", "Status", "ActualStartDate", "ActualEndDate", "TimerRunning", "TimerStartedAtUtc", "TimerAccumulatedSeconds", "UtilizedHours", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_notifications; Type: TABLE DATA; Schema: action; Owner: -
--

COPY action.tbl_notifications ("Id", "RecipientEmployeeId", "ProjectId", "ProjectCode", "ProjectName", "Title", "Type", "Priority", "Status", "Unread", "RaisedByEmployeeId", "RaisedByName", "RelatedTask", "IssueId", "HistoryJson", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "CommentsJson", "NotificationNumber", "ServiceEscalationId") FROM stdin;
\.


--
-- Data for Name: log_role_permission_audits; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.log_role_permission_audits ("Id", "RoleId", "RoleName", "ModuleKey", "ModuleLabel", "SubmoduleKey", "SubmoduleLabel", "PermissionKey", "ActionLabel", "ChangeType", "PreviousValue", "NewValue", "ChangedById", "ChangedByName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
42e77664-6b61-460c-b6c7-a2e9f8a84932	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	action-center	Action Center	\N	\N	action-center.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 21:46:27.51142+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6fcb0cb4-f657-41b7-aa02-c7e5f6c961b3	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	projects	Projects	\N	\N	projects:read	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 21:46:27.51142+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
bb07b6db-6e82-4d0e-8bfe-fe780955635b	cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts & Finance	resources	Resources	\N	\N	resources:read	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-08-23 21:46:27.51142+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
05c49aad-1095-4818-add4-32fa84082dc1	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	task	Task	projects.task.update-status	Update Status	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:43:06.054728+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1733bf99-627c-417e-a57b-b13ffe29148d	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:43:06.054728+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
2d033bf5-fdc2-42bb-9931-f86c5949529d	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	issues	Projects	\N	Health	issues:raise	Raise Issue	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:43:06.054728+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
51a3a178-8f8e-48e7-a845-524b3ff0fcae	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.edit	Edit	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:43:06.054728+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
5ff7e23a-7b0d-4a8b-a4ae-0da0d835122b	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	health	Health	projects.health.raise-issue	Raise Issue	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:43:06.054728+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6e01c353-2fd4-4dff-8249-6e27e4c8afbd	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:43:06.054728+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
84f7ef35-1851-4c4a-80b1-6b777f8ecac3	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	assigned-projects	Assigned Projects	projects.assigned-projects.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:43:06.054728+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
91ae3d23-316a-43f1-bfb3-40957935cf4f	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	resources	Resources	\N	\N	resources.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:43:06.054728+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9dfe3162-1998-41cb-aafd-f111b277c0ea	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	task	Task	projects.task.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:43:06.054728+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
d4757dcc-c031-46bf-8f0c-66bf5edddec8	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	dashboard	Team Dashboard	my-team.dashboard.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:43:06.054728+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fefd331b-34c2-4a84-8775-2d9b1e1e390d	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.submit	Submit	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:43:06.054728+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b0b4113b-9855-4d46-8377-a35b2c49bfca	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	dashboard	Dashboard	\N	\N	dashboard.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 16:44:42.879328+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
01eaa87e-b30f-435e-892a-8952f12f6386	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	task	Task	projects.task.update-status	Update Status	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
0dcc58d3-5dd6-4a07-b0d9-2ad7d37711ee	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	issues	Projects	\N	Health	issues:raise	Raise Issue	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1271b0da-d674-4e10-9821-1e62ab0f3068	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	timesheets	My Team	\N	My Timesheet	timesheets:submit	Submit	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
1315f980-4ed5-4c43-83ec-5f6aa689c49b	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	health	Health	projects.health.raise-issue	Raise Issue	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
33ccba51-399d-4d62-b1e5-96cf30389e3d	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.edit	Edit	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
389067ad-a8cd-4a24-af41-f67a54109c94	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	dashboard	Dashboard	\N	\N	dashboard.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
3ab34a77-cefe-4ed5-b954-bb38a7d90a8b	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	dashboard	Team Dashboard	my-team.dashboard.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
4f34730e-2006-4d22-af0b-c55ae1ed64b3	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	resources	Resources	\N	\N	resources.view	View	revoked	Allowed	Denied	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
6e71be31-cb0e-4759-8be4-b20deb41a141	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	task	Task	projects.task.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
84feeb98-6ae5-4431-9aca-5a79b0fb7e40	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
b16763e4-418a-4b89-aafe-a3f62fda10ac	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	projects	Projects	assigned-projects	Assigned Projects	projects.assigned-projects.view	View	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
fb1375b3-e030-4f6b-b72e-0ac57575c2f8	92aa9169-28d9-4754-a570-553b067642ed	Testing Team Member	my-team	My Team	my-timesheet	My Timesheet	my-team.my-timesheet.submit	Submit	granted	Denied	Allowed	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin User	2026-09-28 17:09:30.642673+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
9b9d1369-1be2-4d08-93e1-c74adfbbab60	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 13:50:52.546121+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
48699c8d-337f-40d7-978b-08f013292cfe	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 13:52:39.00777+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cce747af-d456-45f8-9fc1-5187730faee2	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 13:52:39.279174+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
a3b26c22-430d-4ecd-948a-6fda3234daea	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 13:55:02.959476+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f2806c70-4cde-4ff9-be76-72b378741f0e	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 13:55:03.164922+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f4e3e67d-e5b7-4b0a-805a-6568229b7aea	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Reset to Default Baseline	RESET_BASELINE			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 13:55:03.38429+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
68cac5a9-e106-4d62-883a-98ead9bab0c2	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Reset to Default Baseline	RESET_BASELINE			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 14:07:47.625584+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
11d7e5bf-8ffb-40c0-9d16-fec649025984	a5023c9e-367f-41e1-ba02-bdb2929edc89	EngagementManager			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 14:22:43.198144+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
cff40133-2e5e-4006-8691-83cb93433b17	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 15:57:17.641161+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
36d34a52-314b-40ef-947a-b6b626c408ae	92aa9169-28d9-4754-a570-553b067642ed	Testing-Team Member			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 16:32:48.273309+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
90cb5fa5-4161-4a48-b173-fdba8cc6670d	b552183f-2695-41f9-860e-16d5fe94c4aa	IT Admin			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 17:48:50.646463+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
f50addee-19db-494b-a234-7fdb2413c8a4	bb568e26-548b-4ca5-9221-fefb9c9143b3	HR			\N	\N		Updated Module & Widget Permissions	UPDATED_WIDGETS			a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	Admin	2026-09-30 17:53:03.010665+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
\.


--
-- Data for Name: tbl_refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.tbl_refresh_tokens ("Id", "UserId", "TokenHash", "ExpiresAtUtc", "RevokedAtUtc", "ReplacedByTokenHash", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_role_permissions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.tbl_role_permissions ("Id", "RoleId", "ItemId", "ItemType", "CanView", "CanManage", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "DefaultCanView", "DefaultCanManage") FROM stdin;
476c3fb2-7724-4426-8a1c-55bfc4752463	cd2a32ed-32fc-47bc-88a9-e6fc48863869	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
47f5c865-7654-4170-9ba6-d88fa1134da1	cd2a32ed-32fc-47bc-88a9-e6fc48863869	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
537c16a6-73fc-418f-bfa4-ddf9aa99e202	cd2a32ed-32fc-47bc-88a9-e6fc48863869	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
57ecbc80-8517-42dc-840e-0cf5941e3b72	cd2a32ed-32fc-47bc-88a9-e6fc48863869	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
597a2270-0880-46b3-9509-8df1fc64b803	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0002-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
5a7ec339-5bdc-4231-8156-72d2b4752156	cd2a32ed-32fc-47bc-88a9-e6fc48863869	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
5ba25297-68eb-45bf-81af-5df7fccc158c	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
1424ede2-ba56-4c9d-a26e-2ca29cd16bc8	cd2a32ed-32fc-47bc-88a9-e6fc48863869	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
16990fd6-afc0-49c4-8ad3-967911b002ba	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
19ddfca1-dc05-4fa6-9b82-2a4d1d653e86	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
205f8d37-0654-40d1-a950-2b9c98001ea2	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0002-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
25ed0860-694a-40c5-9cd1-324e7aec6a4a	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
2c28f97e-9640-4288-979f-fe8e7030d532	cd2a32ed-32fc-47bc-88a9-e6fc48863869	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
326bd5c1-74ba-4883-83ae-a8cbea3cfbac	cd2a32ed-32fc-47bc-88a9-e6fc48863869	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
32f162b5-6e60-4b28-882f-2adf3004df97	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c04c546e-0f2c-448d-b634-5d517843d365	module	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
34a5994a-e2e5-40a0-a0f9-d8e0e44f05c6	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
36e1dff8-9ff9-424d-919a-0c3703114291	cd2a32ed-32fc-47bc-88a9-e6fc48863869	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
3f0240e0-7999-48f1-9ae8-b43911434192	cd2a32ed-32fc-47bc-88a9-e6fc48863869	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
43cca477-8793-453c-8442-8b28f2162ce9	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0002-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
44142ab7-a19d-4745-9214-9bf2196824db	cd2a32ed-32fc-47bc-88a9-e6fc48863869	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
477cfacd-3ad4-40aa-9ab2-2b886789bb68	62a927b7-9fd8-461a-b64e-1aa441eeba4d	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
05c012f7-1385-47c2-8821-7e76d76501ff	62a927b7-9fd8-461a-b64e-1aa441eeba4d	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
14f7fee6-54af-48cb-b64b-879e7dc14324	62a927b7-9fd8-461a-b64e-1aa441eeba4d	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
371bcdc1-6264-413d-9956-a26a90486328	62a927b7-9fd8-461a-b64e-1aa441eeba4d	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d1a3245d-4ef6-4f15-903b-2730e6409bff	62a927b7-9fd8-461a-b64e-1aa441eeba4d	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
bcf2dad8-bb1a-4660-b3af-3aa3109dddc9	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
83a9e47b-136a-404d-a43a-5f0fc8da0ef3	62a927b7-9fd8-461a-b64e-1aa441eeba4d	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7aa8b8b4-7cbc-4d07-89bb-2bbad9d7bc27	62a927b7-9fd8-461a-b64e-1aa441eeba4d	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a982a528-9ebb-4900-9449-bed53b4a6212	62a927b7-9fd8-461a-b64e-1aa441eeba4d	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
effd282b-fa53-4b43-976c-30c539cd546a	62a927b7-9fd8-461a-b64e-1aa441eeba4d	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8ecc1e2d-97df-4262-b010-308e638a01bc	62a927b7-9fd8-461a-b64e-1aa441eeba4d	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e1edd6ca-68c9-43eb-8413-e93173adfdb1	62a927b7-9fd8-461a-b64e-1aa441eeba4d	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
97bd2b76-1c60-46d9-afbd-0058ee43b9d7	62a927b7-9fd8-461a-b64e-1aa441eeba4d	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
b471a5f6-d024-46a7-8ad7-67ae47d5b007	62a927b7-9fd8-461a-b64e-1aa441eeba4d	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
686de751-938a-4976-a324-6fccbf54de23	62a927b7-9fd8-461a-b64e-1aa441eeba4d	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
1afa6299-b443-4cb7-b25a-569ef8ae86b3	62a927b7-9fd8-461a-b64e-1aa441eeba4d	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ca938d69-5b18-4a28-bd84-e2424d06edc7	62a927b7-9fd8-461a-b64e-1aa441eeba4d	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
cffdb51b-19e4-4d89-8634-c7fbd13a7e7a	62a927b7-9fd8-461a-b64e-1aa441eeba4d	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
1ec71113-644d-490b-b34b-3ed45afee093	62a927b7-9fd8-461a-b64e-1aa441eeba4d	e1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e9fbfd73-a7f7-4c96-8f8b-951df1e97df0	62a927b7-9fd8-461a-b64e-1aa441eeba4d	e1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7a9e5587-fb5a-4cca-8b66-ad24788fa151	62a927b7-9fd8-461a-b64e-1aa441eeba4d	e1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d8417915-3152-4062-94eb-e0461bd7832d	62a927b7-9fd8-461a-b64e-1aa441eeba4d	e1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c965c106-cd44-4930-9e9f-c6bf07794bba	62a927b7-9fd8-461a-b64e-1aa441eeba4d	e1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
680d90db-e84c-427a-aa33-c5f087553924	62a927b7-9fd8-461a-b64e-1aa441eeba4d	e1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
15a0b907-4604-4724-8da1-d775f4318a50	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8621d9be-8ea3-4a6e-a303-a891990e40b0	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0002-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c93c030e-e4ea-4ae9-9f83-c5697d8dc939	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0002-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6ac2cde6-8414-4524-bebd-61e36190e35b	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
92fc73fc-bd83-454a-9036-0925c37ff0e3	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0002-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
fcda54c9-820b-4cd6-8bef-5809afa23816	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0002-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
85fdf381-0fd0-48b5-8b35-ea46efd045d6	62a927b7-9fd8-461a-b64e-1aa441eeba4d	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
cb0b070c-516c-46c7-95a2-ba56ea9ddb50	62a927b7-9fd8-461a-b64e-1aa441eeba4d	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
4d69accd-9d58-4cf9-b01b-125d70a23b62	62a927b7-9fd8-461a-b64e-1aa441eeba4d	d67426d3-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
497a4e3e-bba6-47ee-a1fe-193a2a14a17e	62a927b7-9fd8-461a-b64e-1aa441eeba4d	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8ffd2a10-baa5-4365-9a74-5528d306a295	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c3f988c3-44da-4936-a818-f628b0b2f77a	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
845573a3-14fb-4856-ac65-008abc610682	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
aead5661-a538-47df-9116-21f92f240676	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a4d85f43-a0e9-405c-83fb-59f107d9efa9	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0d99f846-18e3-4fda-9509-660be7c55c49	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e2701b52-f9f2-41ca-9e55-84cca36d3aaa	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a4c6ab2a-7de1-4774-9e0e-85a269da7a8a	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
62c4d11f-5c78-4ba4-bd23-1fdd5453966f	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3809cd74-af9b-4234-bd55-84ca021c94d1	62a927b7-9fd8-461a-b64e-1aa441eeba4d	c1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ba3a7b0c-2b71-4c77-a12d-743079114c2c	62a927b7-9fd8-461a-b64e-1aa441eeba4d	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
8221f7f9-1ab1-4819-9f20-ce5c975c0e63	62a927b7-9fd8-461a-b64e-1aa441eeba4d	d67426d3-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
02366a4f-97d3-406e-9e0e-d68eed291bbe	62a927b7-9fd8-461a-b64e-1aa441eeba4d	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d8f0a18d-4785-404a-9d76-f5d8bf50afab	62a927b7-9fd8-461a-b64e-1aa441eeba4d	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e495752f-6b71-4761-913b-c1ac97918bef	62a927b7-9fd8-461a-b64e-1aa441eeba4d	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d0fff66c-8933-459c-ab86-131ca21f2ecd	62a927b7-9fd8-461a-b64e-1aa441eeba4d	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c8529fc1-e03e-47c9-898c-e44c376a506c	62a927b7-9fd8-461a-b64e-1aa441eeba4d	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
49a17967-a724-4c79-a58e-8929f7f07d4e	62a927b7-9fd8-461a-b64e-1aa441eeba4d	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6bf32a9d-ec20-447d-8977-37630587ff59	62a927b7-9fd8-461a-b64e-1aa441eeba4d	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
1d91c4a9-0191-4e3b-b217-8852e8d6d8ff	62a927b7-9fd8-461a-b64e-1aa441eeba4d	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
60221457-26dd-4498-83d1-bf7b160c31b3	a5bfe265-981a-4723-b7bb-6ddc389db7f0	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5d8ca8a9-0d5c-48fe-9e76-e7bab77a7dc1	a5bfe265-981a-4723-b7bb-6ddc389db7f0	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-02 17:46:13.422706+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
9e4ce61f-48d4-436d-9fc9-2546d9c78d1c	a5bfe265-981a-4723-b7bb-6ddc389db7f0	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-02 17:46:13.422706+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
143f473e-5ff1-44e0-af04-0a6dd2ebdb89	a5bfe265-981a-4723-b7bb-6ddc389db7f0	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
98928a09-427e-4731-b65f-855dda3313bd	a5bfe265-981a-4723-b7bb-6ddc389db7f0	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6812aa95-9b43-4c57-8749-ff1dc456b1af	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-02 17:46:13.422706+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
661c4577-f0e1-41ef-8006-82e251885937	a5bfe265-981a-4723-b7bb-6ddc389db7f0	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-02 17:46:13.422706+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
efdc6e31-4475-4fda-86fb-fa1d656730ae	a5bfe265-981a-4723-b7bb-6ddc389db7f0	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-02 17:46:13.422706+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
596f2324-ff37-44e5-81fc-f5b206e9bf55	a5bfe265-981a-4723-b7bb-6ddc389db7f0	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	1	0	2026-11-02 17:46:13.422706+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
d0fa2f62-6a84-4b61-9039-424098f2f72c	a5bfe265-981a-4723-b7bb-6ddc389db7f0	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-02 17:46:13.422706+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
59e54254-7653-4f12-aca3-e2689b5e3954	a5bfe265-981a-4723-b7bb-6ddc389db7f0	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
112de4ce-4983-4d6f-87c0-00560c328b14	a5bfe265-981a-4723-b7bb-6ddc389db7f0	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7bee1498-5ecc-4a40-9fb2-fc2ea7296e3f	a5bfe265-981a-4723-b7bb-6ddc389db7f0	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6ab1831a-e135-49b1-98d8-dfebbccd2c12	a5bfe265-981a-4723-b7bb-6ddc389db7f0	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f01451fe-1a9c-43ac-8f37-54be5f7219ec	a5bfe265-981a-4723-b7bb-6ddc389db7f0	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3a02124d-1386-4f5d-997c-3fcac69f5255	a5bfe265-981a-4723-b7bb-6ddc389db7f0	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
99a1f0f1-fa95-4f0b-ac83-d808c12951e7	a5bfe265-981a-4723-b7bb-6ddc389db7f0	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1f3257ea-9784-4f4a-b93d-8be10d7788e2	a5bfe265-981a-4723-b7bb-6ddc389db7f0	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6770dd91-2a36-4cb7-9071-f59613b3c871	a5bfe265-981a-4723-b7bb-6ddc389db7f0	e1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ae81e1fb-556c-4718-847b-ad7aac20a78d	a5bfe265-981a-4723-b7bb-6ddc389db7f0	e1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c167c2c9-226e-471b-898a-65c4a02530a2	a5bfe265-981a-4723-b7bb-6ddc389db7f0	e1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-02 17:46:13.422706+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
0c3aaf7b-40d9-4479-9267-9a53d636a5dc	a5bfe265-981a-4723-b7bb-6ddc389db7f0	e1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-02 17:46:13.422706+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
69507d39-7919-48f3-8a33-5d16d66c461a	a5bfe265-981a-4723-b7bb-6ddc389db7f0	e1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
30425e95-bd55-4da3-80c3-0386634575eb	a5bfe265-981a-4723-b7bb-6ddc389db7f0	e1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
62af9e62-a582-4bfd-9657-3cd576b5b5c7	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8cf0c6d3-6f74-4f96-b906-25c9f62499de	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0002-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e78e0506-1eaf-47c0-8103-36cabcfdb88a	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0002-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d9cb7bfc-c569-4e9e-afb3-85281dd61227	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
9f648f78-3c02-4d2a-8347-10041905d8e7	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0002-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ca3b1179-ce0b-4028-bbe7-816e5c67077c	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0002-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d86160f4-2a27-4d4a-95d5-55d044f50a78	a5bfe265-981a-4723-b7bb-6ddc389db7f0	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5586d799-79ee-4ed9-8ce6-a75597a994bd	a5bfe265-981a-4723-b7bb-6ddc389db7f0	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
4ab4e518-2730-477c-91d7-8d81551648ea	a5bfe265-981a-4723-b7bb-6ddc389db7f0	d67426d3-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
09c25af8-fa93-4a10-90bb-fbb7108d6422	a5bfe265-981a-4723-b7bb-6ddc389db7f0	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
839f8d55-5f6f-4bbf-9fc3-7a1370bf1926	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
301b5a19-ef59-4995-b30d-2e101968e280	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5763e72d-d065-4029-a172-82c50b69f0b8	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
eb7f35e7-d4be-4d76-87d9-74b4971fcc52	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
87b04295-f7c8-4bcb-b3c6-08432d4dd5cb	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8eaa5b6d-4941-4204-9516-f47ae39d65c2	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
14dcf1e5-a6bd-4ac3-9e62-ed7f1d743c27	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
15659bdf-f88c-4721-98f5-86327bd5ddf0	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3394da15-b02c-4bf1-835b-19f630bdaece	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5c5d7c41-96ee-4762-8a34-18b6c68dfa9b	a5bfe265-981a-4723-b7bb-6ddc389db7f0	c1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a6a0b7f9-8a66-4a2c-b610-2693206f6e43	a5bfe265-981a-4723-b7bb-6ddc389db7f0	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
88237dd8-5876-454a-ae76-8eb50bcc5617	a5bfe265-981a-4723-b7bb-6ddc389db7f0	d67426d3-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3529e2dc-7960-4466-9db5-7e366a7280a2	a5bfe265-981a-4723-b7bb-6ddc389db7f0	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-02 17:46:13.422706+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
164a507f-d326-450d-a2c4-dc36949ebbd1	a5bfe265-981a-4723-b7bb-6ddc389db7f0	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
33ba7be1-cafe-415e-86fe-47708cde11fe	a5bfe265-981a-4723-b7bb-6ddc389db7f0	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
bb0da0f3-ea1c-4534-926a-f2dea697aad6	a5bfe265-981a-4723-b7bb-6ddc389db7f0	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
cff68470-d644-406a-9096-cec26496f869	a5bfe265-981a-4723-b7bb-6ddc389db7f0	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ec52f1cf-f53b-439a-a9d5-62abed151d16	a5bfe265-981a-4723-b7bb-6ddc389db7f0	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
b186a41e-64cb-47b3-9e7c-a31029c2c98a	a5bfe265-981a-4723-b7bb-6ddc389db7f0	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0ffa0a3a-9835-4e43-8ab3-ea994f8d1253	a5bfe265-981a-4723-b7bb-6ddc389db7f0	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
611f9c63-bc7d-4313-9c3b-b0bc7da2b475	cd2a32ed-32fc-47bc-88a9-e6fc48863869	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
6509af1f-d8bb-4850-bc2f-510a15229a56	cd2a32ed-32fc-47bc-88a9-e6fc48863869	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
67c17503-75fc-4693-88ae-b0718ea84703	cd2a32ed-32fc-47bc-88a9-e6fc48863869	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
6952d95d-c1da-46c1-9ea5-c97468808dd0	cd2a32ed-32fc-47bc-88a9-e6fc48863869	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
6de9a65a-d872-41da-9be7-2cebf9624ff0	cd2a32ed-32fc-47bc-88a9-e6fc48863869	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
7607c07f-7dec-4571-8982-defd1dc43bfe	cd2a32ed-32fc-47bc-88a9-e6fc48863869	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
77926a4b-69bf-4fbb-916e-4c7f8f4ddd60	cd2a32ed-32fc-47bc-88a9-e6fc48863869	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
7fb1969f-3281-4dca-9a33-ad6bb1676d58	cd2a32ed-32fc-47bc-88a9-e6fc48863869	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
87862cbc-8ddd-4bac-824a-3d59897160d7	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
928cfe6b-de1c-4903-a0b4-31757ab5ca37	cd2a32ed-32fc-47bc-88a9-e6fc48863869	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
0284e958-3b30-487f-9963-e3be2bdcb7b7	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
06be04f5-7f22-4fc0-bd1f-e9f65a255c15	64c49f37-a38a-46a6-9622-7427f1501658	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
11075f12-9bf9-4590-bd47-4717f5f5181a	64c49f37-a38a-46a6-9622-7427f1501658	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
16c48db4-6db8-4932-b7d6-4dcf44bc119d	64c49f37-a38a-46a6-9622-7427f1501658	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-10-26 02:05:55.763886+05:30	2026-11-12 15:39:31.349238+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
1f73e8a5-9863-403b-903d-f728fdafe839	64c49f37-a38a-46a6-9622-7427f1501658	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
2954dd4a-8201-4947-b8fe-ae38c1f84860	64c49f37-a38a-46a6-9622-7427f1501658	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
2ab953ab-8204-46a4-996e-dda33393d7fd	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0002-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
309a0d85-463b-42b9-a6f6-13a2ead53d4b	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
39b48807-fa4b-4218-9ced-ff5a5e7d49c6	64c49f37-a38a-46a6-9622-7427f1501658	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
41100b19-ccef-49e3-b07c-94bbae57b865	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
92afa0ad-278c-4779-8d85-03a776b37ed8	cd2a32ed-32fc-47bc-88a9-e6fc48863869	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
9983b37a-757a-4b25-af1c-8fa580b7bc68	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0001-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
9b1ec2c1-0540-4a20-803a-d2fe3f0098c5	cd2a32ed-32fc-47bc-88a9-e6fc48863869	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
a43d6284-7d2a-4ead-914a-aa4ac083e014	cd2a32ed-32fc-47bc-88a9-e6fc48863869	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
af0e6be6-7da4-4bf4-a465-b5b4cd1ba5cd	cd2a32ed-32fc-47bc-88a9-e6fc48863869	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
b8027275-7eec-46c3-85b6-d73cffc9d09f	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
b83354f2-cf06-4243-8fde-21cea4fd3874	cd2a32ed-32fc-47bc-88a9-e6fc48863869	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
b9b93b98-a1f1-4d35-8961-4cca127c3814	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0002-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
bc06e99c-bdc1-4da9-81f1-36611d7aad6b	cd2a32ed-32fc-47bc-88a9-e6fc48863869	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
beb1910f-fca3-4344-8f29-e2b51d2440f0	cd2a32ed-32fc-47bc-88a9-e6fc48863869	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
bf2f5e9c-ab4f-4cad-acbd-3fc1a16f7f85	cd2a32ed-32fc-47bc-88a9-e6fc48863869	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
c1bfd92d-5616-4b89-b8ee-f2b3cd3a3fb1	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
c5c5d8e0-d96d-4700-ac23-ab8bd09c8c34	cd2a32ed-32fc-47bc-88a9-e6fc48863869	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
c617ee61-fbce-4804-bda4-f09885de5e00	cd2a32ed-32fc-47bc-88a9-e6fc48863869	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
d94421a5-5de7-477a-ae3f-1ef99a6c522f	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
d9718afd-2327-4fc6-be5c-a58adad95199	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0002-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
d98117a7-24fc-4dce-83b2-c0ec02d7ab73	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0002-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
dc0ed415-9241-47de-831c-6f0c7dcac7ca	cd2a32ed-32fc-47bc-88a9-e6fc48863869	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
dfb0a2eb-f22b-4a4c-8c44-8e835755f2fe	cd2a32ed-32fc-47bc-88a9-e6fc48863869	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
e22fc9d7-4ba1-4444-828e-997e49bcb220	cd2a32ed-32fc-47bc-88a9-e6fc48863869	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
18c659d8-05b0-4025-a4ec-70645fe9f9f7	64c49f37-a38a-46a6-9622-7427f1501658	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
4ed9c8e8-fe27-4bdd-b0ef-fdeb146a7890	64c49f37-a38a-46a6-9622-7427f1501658	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
6a63e621-0049-4484-9c61-d15bdf4f4f61	64c49f37-a38a-46a6-9622-7427f1501658	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
7c4298fd-8ffd-41cf-bb80-30aff30a279c	64c49f37-a38a-46a6-9622-7427f1501658	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
ccb2d06a-43cd-4d51-864b-b4c1e8e70850	64c49f37-a38a-46a6-9622-7427f1501658	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
dce2c39e-acb3-45a1-b8f5-d8080e8d86c1	64c49f37-a38a-46a6-9622-7427f1501658	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
b0bda2ad-7ea2-47c3-8ac1-bb1111dbddb7	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9493d5f0-c85f-4b3f-82d7-0e3de9d123dd	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e71ef9c6-1e79-4232-acd4-0da968289b12	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
037aa214-acd6-4a73-a18a-0e18782bd624	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
489b2af6-8553-4e87-aa8d-15696931422c	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
a78607cb-d6f3-4fe2-87f5-d62c38c497d1	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
9e519659-c4af-4958-b798-9442b23be7d1	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a7fb590c-8c97-4383-ab63-bbfeb8dc2121	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3e20944e-48f1-4506-acc7-0cf5f61b5f3c	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3ad26e30-e7f9-4547-829b-1b109871b637	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
129f9854-c5fa-42e8-bc30-ce8cbc72b773	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
886c9b86-db0e-4382-bcb6-83c5611122e4	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
87d9626f-5812-4e74-8a40-3e99e0f22e2f	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
93360f7a-3f75-4566-831d-fa43f52e0064	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
b7432ff0-5eb3-4a9c-8b3f-18781804c1e6	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
2276f6ed-a027-4867-8ed6-83031865a3c6	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1de54418-b7bf-4a01-abaa-05ae3ad6c2f7	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
7cd3385f-210b-4af5-9175-15101e58cd56	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c3ffb5f2-8ff1-4f0d-b823-27bbbe420563	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
272dfad3-7f76-462e-be77-7551a87bb4ff	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
182d7281-f514-4fe0-a684-45b7db6b8309	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0eb906f6-81f2-460a-9518-2fb489d10a54	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a8c456d9-0312-4d88-9807-0b2373a7bb96	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c68b6490-4d0a-4c92-bff7-039f3d959a09	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9c59f4b1-2a74-4956-94cd-951d1c4383b5	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
06ac7edf-97bc-47b3-beef-585b3fe22eea	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0002-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
5db38c98-1591-42f4-b43e-38d1a43f9b8e	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
687a6ddc-cf44-43a1-a0c0-0cbe03aad176	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
9e62c360-21f6-4a0c-8710-3c295266874e	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
87e4bc8d-7e56-422a-84a6-ad7e13c2f4d0	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0002-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3ae388d6-f25d-473a-b56f-15db8f57891a	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
e81dbfff-0654-4748-a9a3-bf4a8724ec78	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0caa1908-0e9c-41d8-9305-a46af1d328df	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
e139698f-399c-4830-b1de-cdde2b1bc0f3	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
7d2f50b8-e897-41cd-8051-e4ba95a844d9	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
4c670d27-9540-4de1-8971-53bcf27e5cec	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
add9a0a3-58d0-4bf2-954d-927c89f1bfa6	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
9cf4cc7a-53cb-4330-ae1d-1582652f1901	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6947b43a-7c6b-4a27-b685-5505f14c1b21	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0001-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
4c78dadc-4ad8-4d76-94be-e0877e28a6e2	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
69cae0aa-99a9-4435-a6c0-936bf6e70515	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c12b37c9-681a-4739-a383-ae7331af816e	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
28097ab7-ffcb-4638-8d18-5134d7c54807	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
73fa9e19-1d93-4d5d-a330-b67664607ae2	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	c1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a3783a2d-bbd0-4c90-a2a0-00f06fc901df	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
1d540666-748c-47dc-b4b5-271737e7dd2c	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
54463c1f-3855-4af4-be7c-ff9d87f1ed61	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
96a35b7d-9081-4064-8c71-1814cd6eaecf	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c67ee3df-0d83-424d-8a90-610a42e36057	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
34cf52f7-ce98-492b-9898-1035f9ac8421	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
1f10808d-51bb-4d21-b8a5-7e1eb48813ff	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
fd92175b-4ae7-422f-9e77-c7537ca0ff36	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0dd4ccc5-f62f-4555-a338-54123a4847e6	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
bca6b5e4-f6e3-49fc-a043-1ca6b47260b9	4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f92f58fa-a3f4-4a55-a5f9-c64bf51f2bf1	701aaa2c-a899-4def-bf5f-e17511874409	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
f771cc8f-0420-4b59-96e8-1d1128e71273	701aaa2c-a899-4def-bf5f-e17511874409	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
93755895-bb3a-4753-886b-dc42f855c87b	701aaa2c-a899-4def-bf5f-e17511874409	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1bbdfbf3-7a87-464c-bc04-105ac635ffa0	701aaa2c-a899-4def-bf5f-e17511874409	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d79c4b94-f68a-45da-84bc-64fa95b19ffe	701aaa2c-a899-4def-bf5f-e17511874409	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
2ff82cff-79fa-4f2f-805c-309395cb5151	701aaa2c-a899-4def-bf5f-e17511874409	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
151f99a9-688c-4943-b9ee-aca4aac0662a	701aaa2c-a899-4def-bf5f-e17511874409	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3d36000d-b45d-4a15-9808-5493c75ec492	701aaa2c-a899-4def-bf5f-e17511874409	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
cb7b9f74-a69a-4e38-a353-368c0fbfcdcc	701aaa2c-a899-4def-bf5f-e17511874409	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a3912425-c68b-4870-931b-2ab6e4d53ef9	701aaa2c-a899-4def-bf5f-e17511874409	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
df8ddd3f-d5e5-49e1-a933-cf2b450c893b	701aaa2c-a899-4def-bf5f-e17511874409	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c958f68c-79c3-464d-a250-3c1f393229e0	701aaa2c-a899-4def-bf5f-e17511874409	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
46379fff-aa22-4f4e-b3f1-c3a591ccb77c	701aaa2c-a899-4def-bf5f-e17511874409	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
af2e867e-2047-4b10-bcb8-df095edcd1ac	701aaa2c-a899-4def-bf5f-e17511874409	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
72c2cbd9-783c-40b5-821a-a67d14ad12ed	701aaa2c-a899-4def-bf5f-e17511874409	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
89e062d1-b87e-40c0-a85d-3a2e5b992e10	701aaa2c-a899-4def-bf5f-e17511874409	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
43c156c6-83c6-403b-9fe4-7f4670711f7b	701aaa2c-a899-4def-bf5f-e17511874409	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ba50af1c-cf43-46c0-a16c-94708842a57e	701aaa2c-a899-4def-bf5f-e17511874409	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
db471b47-fbab-41cc-935b-8cfb74db0ac4	701aaa2c-a899-4def-bf5f-e17511874409	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ddb47901-3849-45d0-80a1-120481b4e3da	701aaa2c-a899-4def-bf5f-e17511874409	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f685ff03-11f2-4038-9045-414c09b2ad6a	701aaa2c-a899-4def-bf5f-e17511874409	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
8b7fd54b-f24d-4c0c-80a0-9f801c9dbd3a	701aaa2c-a899-4def-bf5f-e17511874409	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f031e196-5080-4f75-8011-1e97d78339d8	701aaa2c-a899-4def-bf5f-e17511874409	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
415dc95d-1e85-42ed-82bb-74e4212deeb5	701aaa2c-a899-4def-bf5f-e17511874409	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
2fe7951d-3cbb-44ed-89d6-e753329bda96	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7da06cbc-6231-4904-84e5-23d55656d3fe	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0002-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
25c8d7aa-f229-440c-aac3-4ee2a71f663d	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0002-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
44e99c8a-d6ec-406e-a861-dc3e480a3f64	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e3bc3534-b68a-4ea9-9e14-4bca16e20d3a	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0002-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a0ad9e34-87d1-4921-b1d3-13080ae2fcd2	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0002-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e787a93d-6ed9-433e-a952-e06fd3a9448f	701aaa2c-a899-4def-bf5f-e17511874409	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
4d226f1a-4ee1-425b-a80b-d08a0a80894a	701aaa2c-a899-4def-bf5f-e17511874409	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
9bdcebab-9611-4990-96be-2b4a30e417c1	701aaa2c-a899-4def-bf5f-e17511874409	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
a449b2f1-548a-47fa-a2c4-d1b3918c8034	701aaa2c-a899-4def-bf5f-e17511874409	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
bccc3740-5d32-45c2-8393-43d871730db8	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d2b4b3cf-b7cf-4dfe-a520-142a61d27cbe	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
19b92b58-56b0-4cb4-973e-d1035864a464	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
23581db7-52e0-496a-9681-c02232d1b935	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
bbf40c36-23bf-4e92-92e6-e965df644941	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
29fb032a-490e-4789-b5bc-424361616d33	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
52c6d167-a85d-4b73-ae53-f6fceff578f7	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3ecb4e32-fcec-4b4b-aa43-440231174f88	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0001-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
8898c833-234b-4fa2-9eee-70caa6a1809b	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
84313d42-bb0a-4d6c-8e34-1edbc9b48310	701aaa2c-a899-4def-bf5f-e17511874409	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
39e0d1aa-55b6-48fa-baf4-a063ba25ff63	701aaa2c-a899-4def-bf5f-e17511874409	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
0683aeb8-3308-4e88-a452-c52706d5573d	701aaa2c-a899-4def-bf5f-e17511874409	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9df74b8c-92cf-48e1-a5ee-06decd9ccd69	701aaa2c-a899-4def-bf5f-e17511874409	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
27ce5212-6e7e-477f-92b4-915a55cbb0c7	701aaa2c-a899-4def-bf5f-e17511874409	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
2e50fad4-538f-4087-9e7f-cff7f62188b6	701aaa2c-a899-4def-bf5f-e17511874409	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
68980cce-1cd0-44b2-8cd9-86bcce1f9ac6	701aaa2c-a899-4def-bf5f-e17511874409	0d274292-537d-4c41-8e23-3df901304d71	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
65116dae-5d55-413b-9d56-1fa26a4b36a4	701aaa2c-a899-4def-bf5f-e17511874409	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
5974f5e5-2312-4a81-b99a-5cf72f28dd9b	701aaa2c-a899-4def-bf5f-e17511874409	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ecd7b0e5-0c7e-4281-8019-7490c0182782	701aaa2c-a899-4def-bf5f-e17511874409	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f8f8e98f-c197-4a27-ac21-cdf637265911	701aaa2c-a899-4def-bf5f-e17511874409	682f26ec-e31d-43a0-82de-e915bab54b59	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
eccde071-8577-4f56-833e-f25c912e8f04	768a11f9-ded7-4f6f-ba86-073e279255d9	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
871ccb23-ce4d-4773-9cc8-4c4a5fc3cede	768a11f9-ded7-4f6f-ba86-073e279255d9	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
77f87687-13d4-4487-8161-f7288b7471ec	768a11f9-ded7-4f6f-ba86-073e279255d9	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f7022643-8371-4824-afcd-d6e2419d6007	768a11f9-ded7-4f6f-ba86-073e279255d9	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
7b46e44d-a0b4-4d9c-b380-599abfcb9ad1	768a11f9-ded7-4f6f-ba86-073e279255d9	168b1296-de6a-4f9e-a3b9-617b83863736	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ce2fa4a7-0726-4c4f-a11d-a31bc0dd5b87	768a11f9-ded7-4f6f-ba86-073e279255d9	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6b094d58-6821-4a6f-bbeb-1c530c94e513	768a11f9-ded7-4f6f-ba86-073e279255d9	715f79ce-51ea-46d3-b95d-8318840f90a6	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
82d4aa54-3661-4ebe-9faa-0f957868094b	768a11f9-ded7-4f6f-ba86-073e279255d9	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
4f2ff791-840c-4e5e-9cfd-820e4480964a	768a11f9-ded7-4f6f-ba86-073e279255d9	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1dc65c5b-89f3-4fc2-a0ea-099b0076e508	768a11f9-ded7-4f6f-ba86-073e279255d9	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
af381949-4d17-4511-9a2f-cd8e3cb02789	768a11f9-ded7-4f6f-ba86-073e279255d9	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e8b0968e-9f6f-4d7b-8540-b5ed8b48934f	768a11f9-ded7-4f6f-ba86-073e279255d9	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f501f217-ca81-44f0-bf50-82e4fd395259	768a11f9-ded7-4f6f-ba86-073e279255d9	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
595fd8ce-e0b7-413d-bdfd-a80403ec4a65	768a11f9-ded7-4f6f-ba86-073e279255d9	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9631b0ad-bbff-42a4-9195-9ba34a71af8a	768a11f9-ded7-4f6f-ba86-073e279255d9	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b13992e7-7abb-4f24-8aa4-8133e272eb4a	768a11f9-ded7-4f6f-ba86-073e279255d9	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
92e8a04e-1468-4294-b98a-d3393584b69b	768a11f9-ded7-4f6f-ba86-073e279255d9	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e09e3afd-61fb-4f39-b542-ec6faee4ccd5	768a11f9-ded7-4f6f-ba86-073e279255d9	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
69bc2666-daae-4711-b733-2adb27a41de0	768a11f9-ded7-4f6f-ba86-073e279255d9	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
796c6f5d-a9b4-4a84-84db-488393e13a23	768a11f9-ded7-4f6f-ba86-073e279255d9	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a4f13aa4-e85d-44bd-bc48-97dd100ea38b	768a11f9-ded7-4f6f-ba86-073e279255d9	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
7bb5aa28-f63f-45cf-b389-8d4861537e15	768a11f9-ded7-4f6f-ba86-073e279255d9	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
01f0df15-d111-4d3b-91f9-e3e9fae93e55	768a11f9-ded7-4f6f-ba86-073e279255d9	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3516cdfc-8454-4f3b-bb93-fb352ea0b442	768a11f9-ded7-4f6f-ba86-073e279255d9	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
092d82fe-b19e-4f43-a5fc-77d41587e7c9	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0002-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c6bd04da-f7ad-4a97-bd28-9f10d3fd9c58	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0002-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1c2ae9fd-fe29-4632-9215-1499a61ecd1a	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0002-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
15822f28-05f6-401a-83c3-aef7d94ad23e	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0002-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0190f368-6f41-41bd-b750-9056b673bb51	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0002-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
8f643236-1306-463e-bbd8-2f08461a9aac	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0002-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a199bb36-ac87-494e-a575-bec24af262a9	768a11f9-ded7-4f6f-ba86-073e279255d9	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9f17e0d7-faab-4ce2-baca-dedffe9785ab	768a11f9-ded7-4f6f-ba86-073e279255d9	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
235a53f9-3709-4523-9372-def631e556f7	768a11f9-ded7-4f6f-ba86-073e279255d9	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ae1e02fb-7314-46e1-8d88-da0e15d50668	768a11f9-ded7-4f6f-ba86-073e279255d9	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
848f54ec-15cd-4b7b-bffc-6ce1ccee444a	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0003-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0aae2b6b-5d9f-42af-addd-d79ed5529d59	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0003-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c50c7f3a-f57b-4131-83f4-cebbc6053997	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0003-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1fa1c679-9378-4eb0-91ac-ca2bc4373cc7	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0003-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
5905e242-a6fe-4737-a1cc-be9cac9c251d	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bd888b7d-5034-476f-b938-fedcb4279819	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
17a7181c-e169-4dc3-a3b4-293311d2e90d	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9c58dbd9-3407-4873-bd5d-1ec391e4cbd0	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a27df4a1-5a0d-47fe-8388-86efea69cfae	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bf1b2fee-a531-4ecb-9296-eed2a98af971	768a11f9-ded7-4f6f-ba86-073e279255d9	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ee95eef2-8e97-4130-93b5-5f6f153762a3	768a11f9-ded7-4f6f-ba86-073e279255d9	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
49cceea6-01a6-458d-a662-e7cf87f8a66c	768a11f9-ded7-4f6f-ba86-073e279255d9	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
5e936dc0-6f83-4a22-b96a-8c72efd3e767	768a11f9-ded7-4f6f-ba86-073e279255d9	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a989e407-1861-4ccc-b0d5-c4c3fe3461b1	768a11f9-ded7-4f6f-ba86-073e279255d9	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bf618405-d502-4fff-a3f5-e6a1cbfd31a6	768a11f9-ded7-4f6f-ba86-073e279255d9	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1f89efee-39a3-4e8b-8bef-9c4681836f34	768a11f9-ded7-4f6f-ba86-073e279255d9	0d274292-537d-4c41-8e23-3df901304d71	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3828430e-672b-46fa-8328-90527a5b4f53	768a11f9-ded7-4f6f-ba86-073e279255d9	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e78d6476-e469-4214-b5ef-d08990f8182e	768a11f9-ded7-4f6f-ba86-073e279255d9	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
33add5c2-6add-4e44-81c6-4068ce82959a	768a11f9-ded7-4f6f-ba86-073e279255d9	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d8d08e5c-c03e-48f6-8867-80008d77c180	768a11f9-ded7-4f6f-ba86-073e279255d9	682f26ec-e31d-43a0-82de-e915bab54b59	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
5461e093-04e4-43f0-a5a9-28a14e933b93	a5023c9e-367f-41e1-ba02-bdb2929edc89	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
abb06d52-5811-487f-8f61-173136323eef	a5023c9e-367f-41e1-ba02-bdb2929edc89	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
13501e42-2e30-4896-b96b-08896e8596c8	a5023c9e-367f-41e1-ba02-bdb2929edc89	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f6191c58-0038-4b4a-aa2b-0989f6d7e07a	a5023c9e-367f-41e1-ba02-bdb2929edc89	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
e38e7c7c-be59-4550-952d-578ea6aa564a	a5023c9e-367f-41e1-ba02-bdb2929edc89	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9a9bf795-735c-411f-bf15-a76547b25e02	a5023c9e-367f-41e1-ba02-bdb2929edc89	c04c546e-0f2c-448d-b634-5d517843d365	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
983c2bb4-b1f0-4bfb-aab4-afb39de93cbf	a5023c9e-367f-41e1-ba02-bdb2929edc89	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
19779dab-64b9-47ad-a930-a104a4dd76e5	a5023c9e-367f-41e1-ba02-bdb2929edc89	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ccf48498-183a-48a7-bf88-eed238979984	a5023c9e-367f-41e1-ba02-bdb2929edc89	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
58ffa1da-86d6-4a4a-a45e-f4dc3883effe	a5023c9e-367f-41e1-ba02-bdb2929edc89	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7df92d00-3ea7-45b9-93f4-180708e974f1	a5023c9e-367f-41e1-ba02-bdb2929edc89	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
85eee200-c31c-4f16-a406-9e696f559dfa	a5023c9e-367f-41e1-ba02-bdb2929edc89	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d0dd86af-3e75-4ff1-a729-60a0e41111bf	a5023c9e-367f-41e1-ba02-bdb2929edc89	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
25265f68-338e-46dc-82e0-68b21367f117	a5023c9e-367f-41e1-ba02-bdb2929edc89	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
768234ba-463a-47cb-b03a-cb8c976b4aaf	a5023c9e-367f-41e1-ba02-bdb2929edc89	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
5564f481-caf5-4a40-a5ac-46b5064bd2fc	a5023c9e-367f-41e1-ba02-bdb2929edc89	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d8f48db1-2037-4d82-a537-4deb2d5463c3	a5023c9e-367f-41e1-ba02-bdb2929edc89	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c65de3fc-b4e7-487c-960f-e968a7e8b1eb	a5023c9e-367f-41e1-ba02-bdb2929edc89	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ea1217b9-b77f-4b7a-8dd8-45346ba8e6a2	a5023c9e-367f-41e1-ba02-bdb2929edc89	e1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c4d593be-4c33-49f3-8e32-94d54554bd7f	a5023c9e-367f-41e1-ba02-bdb2929edc89	e1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7b6ac95c-489f-42f2-a0cc-0a519e45b9f5	a5023c9e-367f-41e1-ba02-bdb2929edc89	e1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c4723605-9163-4b1d-a681-43d22730482d	a5023c9e-367f-41e1-ba02-bdb2929edc89	e1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
fd5155b0-d24d-4fc7-826c-0d12e60c410f	a5023c9e-367f-41e1-ba02-bdb2929edc89	e1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
37a340af-ddad-43a3-8e16-25c9e9c8473a	a5023c9e-367f-41e1-ba02-bdb2929edc89	e1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
50211ce9-f772-4797-b45c-027a11f847a2	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
b1cf4719-ae81-4608-b364-1735f017347a	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0002-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
6bf6d76a-6173-4c81-a310-0535d5260632	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ac378e2f-1444-4d37-b3b4-72f5f7b93174	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0757ad7a-be0a-448f-9c49-eca9a6c74640	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c9ef23ee-fae6-4646-95ac-96bb1cb2151f	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0002-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
03015a70-26f7-4f5f-b2a9-f867609e960a	a5023c9e-367f-41e1-ba02-bdb2929edc89	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
869ef923-905e-4d99-9c51-1dc7b4302134	a5023c9e-367f-41e1-ba02-bdb2929edc89	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
92469bff-6e81-4d48-92a2-e82411c10349	a5023c9e-367f-41e1-ba02-bdb2929edc89	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c01ce59e-1756-4ce8-9d96-b4cb8df7908d	a5023c9e-367f-41e1-ba02-bdb2929edc89	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
1ea12748-34f7-4783-a942-d6948cf7f5f4	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0003-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
87b5f94e-ee07-4481-86f2-63cd99138a78	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0003-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
b6b55fbb-f5fe-418f-b1be-03d19dd08495	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0003-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
cb572539-6f9a-4e7f-ad0a-107dcb623296	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0003-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
96dfc6a1-a629-4122-951c-290bf20e1527	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0001-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
0376f218-b07a-48fd-9a35-cc8e34b99fd3	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0001-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
aa1ddecd-1853-432b-9e64-2519ab0afbac	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
00e18c04-e0a1-4d50-947d-c4e42977bdee	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0001-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
6f3e0422-1a02-4f20-bef9-9c35e7895b0a	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ba33d8bf-e466-469e-b892-cb558aa69098	a5023c9e-367f-41e1-ba02-bdb2929edc89	c1a11111-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c368f50a-a218-4cd1-91ca-90f18609f4b7	a5023c9e-367f-41e1-ba02-bdb2929edc89	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d62fff49-80dd-421d-b569-7eee3c890b19	a5023c9e-367f-41e1-ba02-bdb2929edc89	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
2ce45ae6-c2f9-4031-a548-53a9f1b8d88b	a5023c9e-367f-41e1-ba02-bdb2929edc89	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f1acfe97-0678-42c7-877a-4a06453522e0	a5023c9e-367f-41e1-ba02-bdb2929edc89	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c32b3332-377d-491b-9a8b-90c5ee858d68	a5023c9e-367f-41e1-ba02-bdb2929edc89	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a8b0496e-e19a-44cb-b86d-d7f474a195c3	a5023c9e-367f-41e1-ba02-bdb2929edc89	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
1339cb9e-fedc-4246-a558-0b1b5cf0d810	a5023c9e-367f-41e1-ba02-bdb2929edc89	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
315a39a3-703d-4d64-9c2a-e216754c9bf6	a5023c9e-367f-41e1-ba02-bdb2929edc89	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
32afe386-12ca-4eeb-8501-095b8f6ebe55	a5023c9e-367f-41e1-ba02-bdb2929edc89	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d174e785-47b7-46b6-bce7-d6dca3a0efc4	a5023c9e-367f-41e1-ba02-bdb2929edc89	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ad0f16a8-97d1-4f11-a65c-1a30f61af4d7	bb568e26-548b-4ca5-9221-fefb9c9143b3	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
eeca10cd-c639-4237-b112-37e627cc3ef1	bb568e26-548b-4ca5-9221-fefb9c9143b3	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-02 14:12:05.014219+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	0	0
45c9d69c-2e63-452d-90fe-c2b35d487e32	bb568e26-548b-4ca5-9221-fefb9c9143b3	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
4491c202-f5ed-452d-b571-7fa69e96c66b	bb568e26-548b-4ca5-9221-fefb9c9143b3	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ef9b989d-0cb0-4c44-8da5-64fc34627782	bb568e26-548b-4ca5-9221-fefb9c9143b3	168b1296-de6a-4f9e-a3b9-617b83863736	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9248f80f-1d38-4884-a25d-da6407a1748a	bb568e26-548b-4ca5-9221-fefb9c9143b3	c04c546e-0f2c-448d-b634-5d517843d365	module	1	1	2026-11-02 14:12:05.014219+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	1
d3340b73-b929-46a0-a471-47eddfa61e8e	bb568e26-548b-4ca5-9221-fefb9c9143b3	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	1	2026-11-02 14:12:05.014219+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	1
f178b94f-f546-4f6b-9a06-611e9a7d3ae0	bb568e26-548b-4ca5-9221-fefb9c9143b3	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
8dd63e1f-813e-43a8-b180-cd8c9899cff8	bb568e26-548b-4ca5-9221-fefb9c9143b3	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	1	1	2026-11-02 14:12:05.014219+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	1
6ea7bc8b-0753-45bf-aefb-14ce792bdf39	bb568e26-548b-4ca5-9221-fefb9c9143b3	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	1	2026-11-02 14:12:05.014219+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	1
9d196ac2-b9cc-4f2e-8bdf-df208cf2aa81	bb568e26-548b-4ca5-9221-fefb9c9143b3	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f6831337-efde-4106-b1bf-9fd217a2861e	bb568e26-548b-4ca5-9221-fefb9c9143b3	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
cc25dd6c-3c2b-4077-8e54-3c1ab03deed2	bb568e26-548b-4ca5-9221-fefb9c9143b3	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9825fcd4-8876-4327-967b-a79a87e61350	bb568e26-548b-4ca5-9221-fefb9c9143b3	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
85049d86-2722-428b-a5c5-86476558a0fb	bb568e26-548b-4ca5-9221-fefb9c9143b3	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
89ff6927-ea0a-4281-82cb-15672400403a	bb568e26-548b-4ca5-9221-fefb9c9143b3	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
304e1cae-9052-469a-92d9-17e2283f5870	bb568e26-548b-4ca5-9221-fefb9c9143b3	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d62c146b-9d37-41cc-a169-5ce5484294b6	bb568e26-548b-4ca5-9221-fefb9c9143b3	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
f15c3d9a-cdd6-47c2-88e5-88e7482b1c6f	bb568e26-548b-4ca5-9221-fefb9c9143b3	e1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-02 14:12:05.014219+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
07bdabe1-c326-457a-a45c-19ef19869dbd	bb568e26-548b-4ca5-9221-fefb9c9143b3	e1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-02 14:12:05.014219+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
3aadf87c-874a-4fbb-9276-550127d6e3c4	bb568e26-548b-4ca5-9221-fefb9c9143b3	e1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-02 14:12:05.014219+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
f1ca63aa-1714-4cc8-bcdc-359089f4cd1c	bb568e26-548b-4ca5-9221-fefb9c9143b3	e1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-02 14:12:05.014219+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
2931843e-d649-41ed-a8ed-04d98f2aaf93	bb568e26-548b-4ca5-9221-fefb9c9143b3	e1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-02 14:12:05.014219+05:30	2026-11-12 10:46:05.669876+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	1	0
944fd00d-32eb-4db4-b75b-d913acbff0f7	bb568e26-548b-4ca5-9221-fefb9c9143b3	e1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
dc6d8337-6731-4ec7-a288-a9898eec1e8f	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0002-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ca249536-bc44-4579-90ab-879581159a26	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0002-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
6ff828aa-e525-4f3c-bbea-868c7318ca65	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0002-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d60e1be0-4203-4618-9ffd-7a9048605e23	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0002-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
efbee88d-ff0b-47a5-aa38-3709a4eb9f9e	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0002-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
dc28ea4f-10ab-4bf3-abb6-b58eb735a836	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0002-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ca371487-fe87-4ec7-9f6b-85e39d3b6839	bb568e26-548b-4ca5-9221-fefb9c9143b3	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9c03fe56-c359-4874-a618-31800899e0e8	bb568e26-548b-4ca5-9221-fefb9c9143b3	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6164498b-dd05-4b55-a9a3-8bf656a2edb2	bb568e26-548b-4ca5-9221-fefb9c9143b3	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
512d61e7-eeb1-4682-8922-18dd0765dad4	bb568e26-548b-4ca5-9221-fefb9c9143b3	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
006a9323-35d1-462d-a5b3-fc8ea126c066	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0003-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3fad328a-2212-445f-abe7-b06a3685831f	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0003-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
25f3194d-42b9-46b5-a3c4-95f85405b56a	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0003-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
50459b3e-5600-46ea-8c36-4abe54036933	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0003-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e0ddb486-9072-47e2-b87c-cbec59465e00	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d3b28a67-5736-468e-a2e7-f36d1062f5f3	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
6ba4902d-a4a8-4c9c-bbb0-823c1d408c80	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
97f545da-9e5f-488f-b424-75d360e06499	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c5d983b0-4d29-4247-9cfa-8fb45eec81a3	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
6c5533b7-49b4-43d4-bcbf-1e79cb39f717	bb568e26-548b-4ca5-9221-fefb9c9143b3	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
67d2b0ee-fe81-4ab1-bca6-fd04b6793aea	bb568e26-548b-4ca5-9221-fefb9c9143b3	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
5f0da11d-bf76-49e1-a1e6-5f4d04f6a2e3	bb568e26-548b-4ca5-9221-fefb9c9143b3	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
39ffd921-4a4c-4398-94da-8552d3ee7f48	bb568e26-548b-4ca5-9221-fefb9c9143b3	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8f4344ec-6c33-4577-9062-032cfd0c2038	bb568e26-548b-4ca5-9221-fefb9c9143b3	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
53b5e7a4-630f-4f3a-a476-ef6c0be8c992	bb568e26-548b-4ca5-9221-fefb9c9143b3	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d334758a-eb72-4f23-afc0-2b17a6532c39	bb568e26-548b-4ca5-9221-fefb9c9143b3	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
eb356529-e50b-4f01-b247-7196ee890741	bb568e26-548b-4ca5-9221-fefb9c9143b3	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
966c2e8c-c70b-4820-89b3-12b06c30da8c	bb568e26-548b-4ca5-9221-fefb9c9143b3	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3c527f3c-5a8a-45e0-b3d0-00dd5d484a5d	bb568e26-548b-4ca5-9221-fefb9c9143b3	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
82bb05d1-a31c-48e2-842c-c0a3589faa91	bb568e26-548b-4ca5-9221-fefb9c9143b3	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d654b3f8-0651-4809-a096-e6b97eda29bf	b552183f-2695-41f9-860e-16d5fe94c4aa	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
2b7dcc07-7c2b-4b3b-8f9d-580d6807d852	b552183f-2695-41f9-860e-16d5fe94c4aa	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
2ca9ad4f-4ca4-416b-9117-383af50c1599	b552183f-2695-41f9-860e-16d5fe94c4aa	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6d963668-427a-4fe4-aafe-a7ad597dfcc0	b552183f-2695-41f9-860e-16d5fe94c4aa	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
0990497f-601d-4178-a921-a7af52b9acb4	b552183f-2695-41f9-860e-16d5fe94c4aa	168b1296-de6a-4f9e-a3b9-617b83863736	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1de4ff0f-458e-4844-98c5-f62d7d389428	b552183f-2695-41f9-860e-16d5fe94c4aa	c04c546e-0f2c-448d-b634-5d517843d365	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
cbc46ea2-3aa7-408d-ad76-7e0faa37d341	b552183f-2695-41f9-860e-16d5fe94c4aa	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
04c2736b-cb85-4a43-9726-3854138e7bc8	b552183f-2695-41f9-860e-16d5fe94c4aa	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
2da7656e-186a-4862-89da-50c2fc35a649	b552183f-2695-41f9-860e-16d5fe94c4aa	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bff76ce6-40bd-4327-bbfd-bd70b1c9a346	b552183f-2695-41f9-860e-16d5fe94c4aa	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
22f5068c-c043-4675-8719-b9c4e2488100	b552183f-2695-41f9-860e-16d5fe94c4aa	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
4e1260d7-1f35-4815-8224-c809ad510c30	b552183f-2695-41f9-860e-16d5fe94c4aa	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
04db4431-a0c0-403e-9749-ad3da099c7de	b552183f-2695-41f9-860e-16d5fe94c4aa	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0cbba3ba-f422-43c7-8e70-210ccfa063f7	b552183f-2695-41f9-860e-16d5fe94c4aa	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
a605f6f0-eedd-4f21-9cde-11905f6c0121	b552183f-2695-41f9-860e-16d5fe94c4aa	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
f08838ce-57c5-4e4b-a3f8-c03fd347ae9c	b552183f-2695-41f9-860e-16d5fe94c4aa	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b70c1e7e-80f7-4b68-81c9-5bd541cd14db	b552183f-2695-41f9-860e-16d5fe94c4aa	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b891a4f8-a598-45ca-abc0-c78688b72055	b552183f-2695-41f9-860e-16d5fe94c4aa	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
30807871-4918-423c-8ee2-d00220c07cfd	b552183f-2695-41f9-860e-16d5fe94c4aa	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
78ad4248-14bc-481b-af35-270ab0f9863e	b552183f-2695-41f9-860e-16d5fe94c4aa	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3dc3ca68-80ff-477a-969d-93ea0090ac8c	b552183f-2695-41f9-860e-16d5fe94c4aa	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
24a798b1-da18-4af5-995e-94c418849fff	b552183f-2695-41f9-860e-16d5fe94c4aa	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ddec2a3c-2e65-4b39-8516-0b4c6f08b8da	b552183f-2695-41f9-860e-16d5fe94c4aa	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b43146c2-7659-408c-b9d9-f6de54d7ba1f	b552183f-2695-41f9-860e-16d5fe94c4aa	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
097f9232-3a69-41ee-8ff9-1e6aac9852d2	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0002-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3325155e-e5c9-4ca5-841e-c7335fd50009	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0002-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
245e8877-c954-4c8e-9352-01ad73338728	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0002-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
016f6489-3446-4464-bea9-f5043ce75193	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0002-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
066319a5-3639-4b7c-81f6-22a323fa56d2	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0002-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
33992933-48c4-431f-8657-36edda653d83	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0002-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
81395be3-8955-4385-98fc-84028fd1cc8f	b552183f-2695-41f9-860e-16d5fe94c4aa	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b13fc714-cb42-4e12-8bb8-a9f9222a20cb	b552183f-2695-41f9-860e-16d5fe94c4aa	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
20785fc6-726e-4269-97eb-13525a843e50	b552183f-2695-41f9-860e-16d5fe94c4aa	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d57edb72-f3b1-4947-9493-286248ad3a97	b552183f-2695-41f9-860e-16d5fe94c4aa	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
da17110f-c24a-4a2a-ab7a-324890fd0add	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0003-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1f04ff41-56e1-47d4-ba2c-d2ccad12d9b8	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0003-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d07d2e78-b60c-44a6-9f3c-b1de03a92c99	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0003-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
6a12ee9b-65c0-4576-9e85-b052501fc976	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0003-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
976c96e0-0097-479f-9b47-cdb9be7607a7	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d5cf812e-9837-4fee-91e7-6f09de3e13ab	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bc5f44a4-f495-48dc-96d3-66f62fa096b5	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
56993f15-42f6-4164-8a4d-f5a4098b7704	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
81c0c692-fd01-46a7-aaef-919929098d1b	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
147b71d9-80b9-4b44-8f33-76f21b243c93	b552183f-2695-41f9-860e-16d5fe94c4aa	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
312a80db-f853-4726-92cb-6cc4b02c13c2	b552183f-2695-41f9-860e-16d5fe94c4aa	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
14efcc2f-30e4-4b2f-88e7-c178687024b2	b552183f-2695-41f9-860e-16d5fe94c4aa	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
b7cada6e-46d3-429a-840e-6a815f687e67	b552183f-2695-41f9-860e-16d5fe94c4aa	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e029f04f-49fc-449f-b22c-93a94cec4f31	b552183f-2695-41f9-860e-16d5fe94c4aa	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
de64f109-1e73-4472-9b9d-50973598b0f4	b552183f-2695-41f9-860e-16d5fe94c4aa	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
641f026c-809b-47e6-82f6-f65f88311023	b552183f-2695-41f9-860e-16d5fe94c4aa	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
bfae6a48-bc6a-4b95-bd4f-d5a41695f9a8	b552183f-2695-41f9-860e-16d5fe94c4aa	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
71aa7c6e-231c-43b7-8fdf-5a40e8f7dbdf	b552183f-2695-41f9-860e-16d5fe94c4aa	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
eb8d1fcb-5cf6-4472-8a31-7004420cd12e	b552183f-2695-41f9-860e-16d5fe94c4aa	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e5d7db1b-837d-40c5-8eee-b86f0f1a901f	b552183f-2695-41f9-860e-16d5fe94c4aa	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e57ee6d0-aa23-4e85-9baa-c3a224544c77	cd2a32ed-32fc-47bc-88a9-e6fc48863869	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
e95ef5c6-e8ac-41e8-964b-abcaa47536c9	cd2a32ed-32fc-47bc-88a9-e6fc48863869	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
eb9d0b62-98cc-4155-ad9e-0d44b91da791	cd2a32ed-32fc-47bc-88a9-e6fc48863869	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
f862a2ef-a729-4247-a9f8-a05287c957d5	cd2a32ed-32fc-47bc-88a9-e6fc48863869	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:23:58.17867+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
47c241e5-e9c9-4ddc-bf89-0a156933e426	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
48a58cbc-3e1a-4f12-9cbb-979c3d97bdc5	64c49f37-a38a-46a6-9622-7427f1501658	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
4d543e6a-fc96-430b-af2f-70811adeb2c8	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
2e6d9d2d-4156-408f-965c-8c974349e92a	64e2ea37-cbd7-4127-b65b-3b003235981a	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
80d21231-983b-45dc-a84e-373654f6e443	64e2ea37-cbd7-4127-b65b-3b003235981a	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
861d742a-7ef4-4df3-9966-77bce60b4876	64e2ea37-cbd7-4127-b65b-3b003235981a	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9316540e-7aab-431a-8918-b25419a2c042	64e2ea37-cbd7-4127-b65b-3b003235981a	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
6fc81a65-09f1-4044-a2a4-003d26708aae	64e2ea37-cbd7-4127-b65b-3b003235981a	168b1296-de6a-4f9e-a3b9-617b83863736	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
4043c71a-32c0-4130-9b64-c7a9d78df502	64e2ea37-cbd7-4127-b65b-3b003235981a	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c764b1d8-27f6-4b6f-9afd-734b433b65aa	64e2ea37-cbd7-4127-b65b-3b003235981a	715f79ce-51ea-46d3-b95d-8318840f90a6	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b8c8308e-244b-4ef8-abe4-00f1ba85662f	64e2ea37-cbd7-4127-b65b-3b003235981a	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b4e8a0c8-05ce-4b22-9cda-bbed51393c2e	64e2ea37-cbd7-4127-b65b-3b003235981a	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
fdbeff23-8d1b-4333-944b-a5fdc9eeef23	64e2ea37-cbd7-4127-b65b-3b003235981a	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d69b7b9a-cf7d-4857-81aa-9d32f63b5ec9	64e2ea37-cbd7-4127-b65b-3b003235981a	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
78b4d98c-6bb6-4bcb-8753-28714b6e0a1b	64e2ea37-cbd7-4127-b65b-3b003235981a	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
680da0af-15f6-4d7e-9886-c4492eefeaa5	64e2ea37-cbd7-4127-b65b-3b003235981a	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e362aa7a-225b-4d8a-803f-9cb430736e3b	64e2ea37-cbd7-4127-b65b-3b003235981a	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
8381c988-4dcc-4bbe-91de-38899cb0f1d4	64e2ea37-cbd7-4127-b65b-3b003235981a	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
fe95b127-29fc-41e5-b424-7dd63b8721fd	64e2ea37-cbd7-4127-b65b-3b003235981a	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b017259c-3371-4bb0-98c3-89f58e92be5b	64e2ea37-cbd7-4127-b65b-3b003235981a	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f8fa099a-fa62-4a44-822b-b2dc7502dd21	64e2ea37-cbd7-4127-b65b-3b003235981a	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
46e43dcc-11cc-4298-957b-ab303035ddcb	64e2ea37-cbd7-4127-b65b-3b003235981a	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
8b588920-713e-44df-affb-e99cf40b1b9b	64e2ea37-cbd7-4127-b65b-3b003235981a	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b648d018-82dd-47da-a85f-98a1a6e7f4b4	64e2ea37-cbd7-4127-b65b-3b003235981a	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
acaf3c54-82cb-459d-822c-0937a45a9522	64e2ea37-cbd7-4127-b65b-3b003235981a	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
8065d3f3-10d9-47fb-bd4e-3b88f4ea4b7b	64e2ea37-cbd7-4127-b65b-3b003235981a	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e2036b0a-e53e-4a24-8b43-2a17b328df33	64e2ea37-cbd7-4127-b65b-3b003235981a	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
cf64ba1f-ef86-452e-a0bb-50f8bbebfb79	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0002-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b1905f18-0493-4c43-8e1a-dd8e5a6d5cc6	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0002-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1a07bd00-8a1c-495b-8236-0673b97c488f	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0002-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
56aceac7-4aac-4203-95a2-e08e24ee1a80	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0002-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
5b5b88f0-04d2-448f-bcee-170094a7f9d6	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0002-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
7b06190c-8a57-4ee9-8de5-112e55813dee	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0002-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
fbecbf8f-41b1-429d-aa14-fc480ab7d5bc	64e2ea37-cbd7-4127-b65b-3b003235981a	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
10596804-2afa-4ca6-b36e-fe35f50e55bb	64e2ea37-cbd7-4127-b65b-3b003235981a	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e443b14e-af58-400b-98fc-b72b4d67c9d9	64e2ea37-cbd7-4127-b65b-3b003235981a	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
5e24a1ab-7636-49af-b5fe-5f818b97ae07	64e2ea37-cbd7-4127-b65b-3b003235981a	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
28fee9a7-3711-4510-bf9f-316a8fe7c398	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0003-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ce889b63-c369-46cb-a3a5-aa9716a8642c	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0003-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3a48f799-d229-4856-afb4-69298cd16c96	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0003-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
81f387a4-4e7d-47bf-beb3-29a4a3047f11	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0003-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
8836fa24-b304-4875-8d46-34d9e0fdb1fc	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9ff78dc9-af2e-44b4-a282-56cfd750ea1e	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bb1781ca-2563-4057-80b1-d58ad82056cb	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c24b3efe-8f0c-4719-8a8a-5403757bc595	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ffdf7711-5daf-4fa3-aaf0-ac21c3741266	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e47ad9fd-50cd-4c39-9e3f-d954142fdc7e	64e2ea37-cbd7-4127-b65b-3b003235981a	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
023a1f03-4e0a-4478-9ea3-5d263819ee4b	64e2ea37-cbd7-4127-b65b-3b003235981a	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
065b6382-4d98-4ef5-b194-74101dd490ad	64e2ea37-cbd7-4127-b65b-3b003235981a	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
bdf530c4-b7ab-469f-b591-7987324d87ee	64e2ea37-cbd7-4127-b65b-3b003235981a	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c5db2625-1c08-4867-93bb-3ef3ed14499c	64e2ea37-cbd7-4127-b65b-3b003235981a	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1f1361ef-5a70-4b4f-b74d-2b92d24d976f	64e2ea37-cbd7-4127-b65b-3b003235981a	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
23f3af4b-9046-4e6c-b941-2714b7cc9c36	64e2ea37-cbd7-4127-b65b-3b003235981a	0d274292-537d-4c41-8e23-3df901304d71	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
18bd53f5-70ab-4926-9f81-6f7e2ccea9c8	64e2ea37-cbd7-4127-b65b-3b003235981a	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3c5fee67-45c1-4c6d-a361-85bce7fb12e3	64e2ea37-cbd7-4127-b65b-3b003235981a	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a51e489f-2e9c-4ea6-a48b-997a9a398fa0	64e2ea37-cbd7-4127-b65b-3b003235981a	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9d5d1ea2-ce84-4602-8c62-6b6b1144d9bf	64e2ea37-cbd7-4127-b65b-3b003235981a	682f26ec-e31d-43a0-82de-e915bab54b59	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
40e7fb95-0b94-419b-9d01-e9d01964751b	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
db2ad3e2-cce9-4b83-b16f-89ecbffc14ce	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ef13e4dd-1756-4cc4-96bf-dacd5db6b6b1	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
9c976cfb-2f4d-4dac-952c-f4b9a47c1358	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
6c379f6e-9cd1-4ccf-9352-1e3d284000ac	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
5c625bdd-d3c9-4c36-807b-d662be9f1d4d	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c04c546e-0f2c-448d-b634-5d517843d365	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
891735ab-3dba-44c9-8511-bd667d07b196	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6cf9a462-64ad-4acc-8564-79c78b4927ea	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
faf54b8d-a59e-464a-9411-a38b4d65d2a6	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
04f82e3c-9fe3-44d9-b8a8-3b2de77cec44	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7115e047-32bb-46a9-ab21-de3e7e1d9f8b	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7dcf402a-ee24-414a-b038-206d3497a56e	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
df8cb23f-c4ca-4e90-8e32-e06004334da7	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9e6d9779-c68b-4734-b6c1-a4c7dfc9be56	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
0994ca95-47fe-4fea-86d4-db50785c1acb	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
4436a5a6-8002-4c80-9827-ae11890b0ecf	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
f6d68514-723d-4c96-8418-7c447b724d99	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
1cb058af-2ef3-44ff-9057-bf88bd4603a4	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
602c9cc3-565b-4d6e-8a45-60ae1ec8f834	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	e1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a722fd11-78d0-45be-be53-ad8c289f4059	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	e1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c52b8e00-7216-4879-b8af-cb766214747a	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	e1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
085c004b-ea97-44d1-8d0e-172f44ecd62f	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	e1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
976bb1bb-b29e-410e-a044-b099ce6ea01c	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	e1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0ec88cab-9296-4594-86d4-fd0870c21484	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	e1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
52883c6b-fca5-464e-9148-0d11cd2deda5	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
56c7e62d-5427-44ef-be9c-44c19836675d	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0002-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
63bbff64-5b34-4464-a778-e592d1c6b3e9	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ebb7cb2c-04f0-413f-8cd3-dffae41feb26	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f22d0117-7a9c-4dd0-8b57-e9cacda22e0e	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3f8d303a-fbd3-4a10-bbda-2f094f6068ff	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0002-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
fd482368-f902-407b-9cbe-ce578c4bd8f6	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
bb291a89-021e-49f8-96e4-1b8d507d85a7	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
bf813d70-79e0-4c6e-8acf-684c632e7b1b	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
a19e03f2-7852-47fb-ba38-6e521d1e9f1f	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ae76b28e-345f-4419-a98b-503a302875de	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0003-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
be4ce8c8-9615-48b1-8680-1e3805ee5990	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0003-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
a636fab5-7ed1-4b87-b07c-e7d69c6855b0	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0003-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ac737dd6-7d55-4681-a98f-a53a5bfaece9	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0003-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
da2fb8e4-e369-4b8d-8b11-9e3aaae89c0d	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0001-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
deaa68d4-25c7-472d-b278-ee642cd9d108	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0001-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
2171e616-8de0-4a9d-bc20-c67983205679	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
a8a17676-f69b-4154-81fc-5030eb7ae322	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0001-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3369cb83-839f-4007-b522-5e0e4a5cc651	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
7b7db8b9-218b-4873-a464-5a9ca695fb12	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	c1a11111-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ab66362c-0e33-4f9d-9ddf-2cc1eb9ac9ba	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
33b03641-a4b7-4bb9-814b-ea1e8aa7db75	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
fe877d88-746d-4848-97cb-20643966155d	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
506bf91e-9b47-4374-9fde-92c3d943458a	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
afd78c60-aadb-4686-8bad-ab4b7d1f8aad	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8e37cabe-ec11-4d93-bb32-3014e3e1ab20	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
598a2238-1eae-435b-8be7-9c406a99a7e0	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e4310135-6131-4f45-9b00-918a74a4b65e	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7f9b7dcb-716d-4863-97fd-c6af5d8227ce	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
594e4fcb-82af-4de6-a198-43e53f08fcd8	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
41ed9f83-ee99-407d-8e6c-1f16c7cf2c63	f5c742d1-e0cc-4bf8-b860-a673ac407393	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
338b5ea6-5415-4fb9-ba0d-57af724953f4	f5c742d1-e0cc-4bf8-b860-a673ac407393	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b2fde0bc-c73b-45ac-86eb-7808bde3f83e	f5c742d1-e0cc-4bf8-b860-a673ac407393	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d0faa39f-56a3-4931-90ed-be10b70a9297	f5c742d1-e0cc-4bf8-b860-a673ac407393	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9f71c5b5-ffc6-434a-979b-91cb1fd0cc84	f5c742d1-e0cc-4bf8-b860-a673ac407393	168b1296-de6a-4f9e-a3b9-617b83863736	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
6d9c3dde-94fb-49a9-9421-fce32b6e2419	f5c742d1-e0cc-4bf8-b860-a673ac407393	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
b95c41b6-1ebf-4797-9fce-4b2fd0128ac5	f5c742d1-e0cc-4bf8-b860-a673ac407393	715f79ce-51ea-46d3-b95d-8318840f90a6	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
7aa225d6-7938-4baf-bf1a-67cecff4d70b	f5c742d1-e0cc-4bf8-b860-a673ac407393	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
03e8464a-e819-448f-91a2-e53549a63fff	f5c742d1-e0cc-4bf8-b860-a673ac407393	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0ed98487-e356-4840-93f1-4d25e5be7cea	f5c742d1-e0cc-4bf8-b860-a673ac407393	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
68c0f2ef-78b3-44c3-85ab-e852951ca7d1	f5c742d1-e0cc-4bf8-b860-a673ac407393	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f021af59-147b-4ef8-b9e5-710ffe758617	f5c742d1-e0cc-4bf8-b860-a673ac407393	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
47b3401d-b35d-441c-b681-acacabe69925	f5c742d1-e0cc-4bf8-b860-a673ac407393	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
42d20d15-8977-43e3-91ff-30b54f30ca07	f5c742d1-e0cc-4bf8-b860-a673ac407393	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
58f239f8-a40e-44ef-9631-130cba194abd	f5c742d1-e0cc-4bf8-b860-a673ac407393	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d4cabfdc-c396-47f8-b880-e95e3f8f858d	f5c742d1-e0cc-4bf8-b860-a673ac407393	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
704691bf-ea5c-4126-906f-4a55ec1dafe8	f5c742d1-e0cc-4bf8-b860-a673ac407393	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f7de195e-46ae-4dd1-afed-d5875f2f7353	f5c742d1-e0cc-4bf8-b860-a673ac407393	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
22cca80a-98ee-4901-8a20-287c0f4d898f	f5c742d1-e0cc-4bf8-b860-a673ac407393	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
cd19b472-06b6-401d-a9a2-6b02b17c2637	f5c742d1-e0cc-4bf8-b860-a673ac407393	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
72908623-2363-40a4-8d4f-4406859856f3	f5c742d1-e0cc-4bf8-b860-a673ac407393	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
801a42d6-d613-4fd7-bc8c-0b31106668d2	f5c742d1-e0cc-4bf8-b860-a673ac407393	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
14630119-1566-421c-8939-4f1efa262f6b	f5c742d1-e0cc-4bf8-b860-a673ac407393	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
4d7a0e5b-885d-44a1-9a1f-1120fb3e454f	f5c742d1-e0cc-4bf8-b860-a673ac407393	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c87dba56-3dd1-436b-8019-bd04139af5af	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0002-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
569dfecc-9b01-4b95-b76f-dc19dc8b0557	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0002-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e6f986e9-934e-416b-852c-7479a5c4b6a2	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0002-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ac677184-9f98-46f1-9b94-8f30ae300d60	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0002-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f5ab2e79-eb88-406d-9d73-313565f7dbea	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0002-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
2c09b817-75c8-4544-a06d-c669216451ed	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0002-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
76ba251e-262b-4c3c-a860-3c0ca5fcf58b	f5c742d1-e0cc-4bf8-b860-a673ac407393	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
cac1cb10-a5ae-4371-8cc7-ceb82e1f8d12	f5c742d1-e0cc-4bf8-b860-a673ac407393	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
cd2f752c-f0b7-4944-9d69-3b4d47a8ced1	f5c742d1-e0cc-4bf8-b860-a673ac407393	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ec6f6616-03cb-4dcc-8b0f-5260e26c04a3	f5c742d1-e0cc-4bf8-b860-a673ac407393	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
74bd1122-7143-413f-8423-8fb7474df572	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0003-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
59d50bea-1d10-47fb-a60f-452a0210b1db	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0003-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0fa8459d-d495-4975-b513-9ce97f89c7ee	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0003-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a712ffd5-fadd-4460-8b91-1d302ef97aa4	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0003-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
79cd5062-6b09-4135-a58c-900820c2ac19	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
290fbaa6-51fc-4991-892d-e791616f547e	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
89066dd7-c456-402c-87a0-114b83dee0fd	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
2de5fc58-abfd-4d50-9eb9-16b239bf620d	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e903b993-0602-4306-8a2d-21d6a7b69cb0	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0afbe6e2-a062-4a20-bd26-026966d6be4f	f5c742d1-e0cc-4bf8-b860-a673ac407393	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
66c5a58d-8d83-4057-aa21-13b50aff7fdd	f5c742d1-e0cc-4bf8-b860-a673ac407393	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bd84ee64-58ce-4f2f-b0ac-ba6f685d60ca	f5c742d1-e0cc-4bf8-b860-a673ac407393	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d30dec90-3393-4e63-954a-45ffbfd2e8f8	f5c742d1-e0cc-4bf8-b860-a673ac407393	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
195da719-d359-4835-8821-082eb42ae9d0	f5c742d1-e0cc-4bf8-b860-a673ac407393	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e8a1a2fa-a380-4fef-9447-f405329459c2	f5c742d1-e0cc-4bf8-b860-a673ac407393	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e7e70bf3-c4d3-4dad-954a-bedd585d49d5	f5c742d1-e0cc-4bf8-b860-a673ac407393	0d274292-537d-4c41-8e23-3df901304d71	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
70fa536c-a82e-4d98-823b-e14726604943	f5c742d1-e0cc-4bf8-b860-a673ac407393	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
990c6b61-f017-432e-acfb-e1d9a00ed644	f5c742d1-e0cc-4bf8-b860-a673ac407393	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b24ac9e1-f989-4000-b931-2f017e451724	f5c742d1-e0cc-4bf8-b860-a673ac407393	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b3ff2d89-f363-4f65-944b-5e3b1a590bc9	f5c742d1-e0cc-4bf8-b860-a673ac407393	682f26ec-e31d-43a0-82de-e915bab54b59	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
63bdc368-ec79-4c90-85ea-0b8a3b71e985	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3fdeb339-049d-45f3-8525-979b42992b5d	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8b2710df-946d-4ce6-ad6c-ece4ba11795b	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7232d360-a195-4811-a196-cd4edd3233cc	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
53fa8299-616c-47c5-bc55-b496e53c3f32	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
f940459f-bf00-4330-9f5b-3c0e76e87a45	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6d49b0c0-4c63-48e9-a807-469ac7dcfc27	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c3327e25-9298-481b-b5ba-d92cff1cdbc1	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f2da656d-5af0-4b47-a5f6-be9e4edbfce4	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0df23ce0-f317-40c7-90e9-c86418cf6deb	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6c03a27c-000b-4e8b-bb82-8e62b6d8e6a9	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
7a4015f9-f5be-40e3-b050-3e79fd19b78b	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c50296c6-8236-432a-a9a3-829e8b609458	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
8d9a7ab2-2b8f-4bcb-8bf9-c11274b347f3	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
87e34ec7-d6f5-4747-81bf-8c5acc8d7cf9	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
73971e68-f013-4a2b-9281-120b395e67ba	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c8e55fdd-c883-4f7a-b25f-0ee17cef6313	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9b836d6e-4006-41ef-8684-a81fd7da5d79	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
eb4c683b-d90b-41c8-a7e0-4cd2ba13a548	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
2696553b-1e7f-47fb-90e3-aadfa654c534	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a13cf821-e394-4368-b1fc-d44603903634	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1076b39a-6d94-49c8-acc6-b88b2960fb38	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3b386f7f-7376-44a5-bb30-39a7977e6a37	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
639186d1-1db5-4274-970c-579ae27470dc	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
31ddd082-d3e6-47cf-9dba-174744a04115	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
98b18eea-c3fa-4fee-b896-aa77a82d54df	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0002-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
fbde84e4-cc47-4865-8b02-e85b14fa265a	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
4debae44-e53f-40f7-952d-ef5e83724b4f	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a932680f-f38a-45f4-b6a2-411b16f11ff6	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
72de7f0e-f9f1-48ee-806d-e4e8d1abbff2	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0002-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c1f7a4f9-0838-47ff-92e9-3ca783f8c674	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
a209a7ba-78c3-43c9-bc8b-daaad0c56ff2	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
339e4d62-691c-47e6-b032-8791a7ca50e7	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
b934678e-0ece-4830-a4fe-7e5e706e76cc	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
27491f03-6885-49c2-8f51-0b1d60dd83f3	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c85a2105-10c9-4fe8-a1f9-e3a61792b2f4	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
33ddecf2-0620-4a4c-ad60-5f1c1542dc7a	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e2212f4d-a5b3-457a-835a-e40ae170a47d	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
64b3190a-63e8-4f9d-bdb4-ed37b2779f48	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0001-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
32056f3e-503a-43f8-b67c-97cc6b52a2d4	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
950bfef2-8287-4f0d-aac2-d073485f56ec	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f8752d1f-2310-4d63-8d08-87e7c36dbb71	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
df2682e6-9f82-426d-aaaf-1bc50dfe4381	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
28a46c86-d566-43c2-854c-16b16c002ac1	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	c1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5acb7080-2dc4-4c48-b2f0-1790bacb1215	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c35149a7-a3e9-4c45-ab66-376f8ba58097	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
152b085e-0289-47a8-980c-ae56ace9162e	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8b487fc8-d724-43c3-acba-22b487886394	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d840de69-7fbf-41a9-9c2a-e5257f1a7b1d	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8a6a0df8-d7d2-47cd-9917-d807f7e0b6fd	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e4c7bf68-8ae7-45ab-80b7-81621fc24fb5	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
15a43ac3-eabe-4004-aee6-2cd1657b2fa2	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5956a5e3-6e94-4941-a98c-ec03177f3ec9	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0f92fb83-a761-4031-a8f3-5dc288edbdca	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
411c4fb1-39ab-462e-8fad-9c0189225b39	111cc3cd-6d35-43ce-be91-dde90d3d4015	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d73423f6-75f0-448e-86d0-c4513f78a5e1	111cc3cd-6d35-43ce-be91-dde90d3d4015	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
b3cf5231-beb0-4d5b-8126-976a0ac78811	111cc3cd-6d35-43ce-be91-dde90d3d4015	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
705d61d9-dadc-46fa-aaa4-6a79dd0dd352	111cc3cd-6d35-43ce-be91-dde90d3d4015	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
6ad95368-1006-4d1c-b563-37e08951840f	111cc3cd-6d35-43ce-be91-dde90d3d4015	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
181804fe-a8ab-4960-b0ac-942d03d54a80	111cc3cd-6d35-43ce-be91-dde90d3d4015	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
dddf1e56-79ec-4a05-a5ab-64ea48f086a0	111cc3cd-6d35-43ce-be91-dde90d3d4015	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
924dad0e-3ab6-4ed4-a0f7-d60b44c73492	111cc3cd-6d35-43ce-be91-dde90d3d4015	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5888351b-0cec-47b5-98de-6ec26bbaf990	111cc3cd-6d35-43ce-be91-dde90d3d4015	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d6953449-5f76-4594-b138-2ff2b4df3138	111cc3cd-6d35-43ce-be91-dde90d3d4015	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
b1525ac0-d44f-4a3e-9f46-4321a979c5dc	111cc3cd-6d35-43ce-be91-dde90d3d4015	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1613f819-a1e1-43ec-9a9b-7a68f2615f02	111cc3cd-6d35-43ce-be91-dde90d3d4015	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
1853f04e-32b4-4ded-8cb3-a54ab152f545	111cc3cd-6d35-43ce-be91-dde90d3d4015	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9379a1b6-8898-419e-aa4e-0889083539e7	111cc3cd-6d35-43ce-be91-dde90d3d4015	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d807f077-7022-4b05-b6df-25312c551dd8	111cc3cd-6d35-43ce-be91-dde90d3d4015	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
e5a81119-327a-444e-8e30-4cacac368435	111cc3cd-6d35-43ce-be91-dde90d3d4015	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1a4f276a-b5a0-4c8c-a177-3bee7c027572	111cc3cd-6d35-43ce-be91-dde90d3d4015	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
89d7d48f-9387-4c47-814f-114f561945f4	111cc3cd-6d35-43ce-be91-dde90d3d4015	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
7f254dec-4d0a-4c02-98cf-ee131b9ca8d1	111cc3cd-6d35-43ce-be91-dde90d3d4015	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3a2433a3-9e83-49d2-a419-dfd2d6b5a0e2	111cc3cd-6d35-43ce-be91-dde90d3d4015	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ef26a92c-45a1-4b32-974f-7888edbc687c	111cc3cd-6d35-43ce-be91-dde90d3d4015	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
102060bc-c53c-4d77-bbb2-aac8eb5cf87b	111cc3cd-6d35-43ce-be91-dde90d3d4015	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c89a1f31-3bdb-4a63-bddd-b9db1b4be655	111cc3cd-6d35-43ce-be91-dde90d3d4015	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
96a00593-a5ea-4ee0-9af4-a9e1e470f0bd	111cc3cd-6d35-43ce-be91-dde90d3d4015	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
93c524fb-a57a-4ce8-bffe-742d4be1c3bf	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
2da0faf6-3163-45ae-bcb4-2415dc6b69b8	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0002-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
131ed11c-f73d-43fa-b06c-f18b4aa1d8f6	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
1b3aba32-8ab7-48f2-aa9e-c23705863ba3	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
38c40b7a-535e-4281-af32-423a5cd4b685	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
0e3173c7-fea1-4825-8f4e-4035d185facd	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0002-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
294a20fe-ca8d-4b50-b3fe-e2cf2558d2a4	111cc3cd-6d35-43ce-be91-dde90d3d4015	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
0d9d3626-3888-447c-ad50-2a921df31640	111cc3cd-6d35-43ce-be91-dde90d3d4015	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7aebe5dc-5559-410b-9315-645c9fd05b1b	111cc3cd-6d35-43ce-be91-dde90d3d4015	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
8ddab045-14e7-4f84-b1f9-abbc2e646903	111cc3cd-6d35-43ce-be91-dde90d3d4015	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c6270dbd-a175-4a88-8aec-65c4ca15f5e0	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
101f7ddd-c2c5-46ed-a4b1-c5d2ed60546e	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7df4c0c9-1ab2-45a4-97d3-963d1985f18a	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ae71c15c-b8a7-417d-9833-6c34f8c3722b	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
003052ea-1b89-43f8-b26b-fe660a7ac48b	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0001-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
07c3f558-1d1d-4092-bd14-68cd9baa00b9	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
db6a8107-16a2-4f99-9d30-d024aebbd651	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
74089470-bef0-4b80-9ab1-f0be69b9ad9e	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0001-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
bc0d86b2-32d4-47c5-a3ed-d0afb79efc1b	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
b26110f4-61c7-4616-a3cd-5f9818909cc6	111cc3cd-6d35-43ce-be91-dde90d3d4015	c1a11111-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
128ab83e-39e8-43a6-9376-52e9ecd46788	111cc3cd-6d35-43ce-be91-dde90d3d4015	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
b0b8cb50-1f43-4181-9b23-61408a62196d	111cc3cd-6d35-43ce-be91-dde90d3d4015	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ea075faa-b956-42da-923d-f4fcc727a71f	111cc3cd-6d35-43ce-be91-dde90d3d4015	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5ac34f2c-3ac4-4f4d-a219-eee524498981	111cc3cd-6d35-43ce-be91-dde90d3d4015	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
fd815633-e232-43b7-9ebf-a2e6b84811fa	111cc3cd-6d35-43ce-be91-dde90d3d4015	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
736e2b2e-48c8-483d-9461-c698c560d4cd	111cc3cd-6d35-43ce-be91-dde90d3d4015	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
93402879-723b-47c6-8ffa-b5a841e7824b	111cc3cd-6d35-43ce-be91-dde90d3d4015	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
59f42700-d449-4e88-9cfc-b4f9dde729c0	111cc3cd-6d35-43ce-be91-dde90d3d4015	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
117d17aa-2bae-41e2-a5ff-73b560fe320b	111cc3cd-6d35-43ce-be91-dde90d3d4015	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3fb90378-7a4d-4548-bd2f-83fadd9be257	111cc3cd-6d35-43ce-be91-dde90d3d4015	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3968f945-0a56-45b0-a9d7-7929810740a9	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
e73a15e6-5303-4a73-a6e6-578022f23ecb	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
15be04cc-8dd1-4d54-8964-fce35a027b34	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
24c3cefa-e0e9-460b-aa27-deea8b6e2a4d	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
95e9dd76-13ef-4b51-bd61-80375f15c20d	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9244fd45-7dc0-4a6f-8aca-f8e4c8d3eb36	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5d5359f0-0655-415c-95bd-eb558561f42c	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
4c4b1c24-f720-4177-957e-e71fcae1e9c6	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
65c49d42-42e1-4953-b672-44f5fd69e661	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
06027bfe-41db-4b10-b83b-7889fdeb25a4	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
478bce12-2c95-4015-b114-f86e9309d287	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
07562831-0dba-4776-9fe9-db5434b6f35f	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
4d80a130-96b0-46af-a5be-af05bafc592c	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
01cd2910-7931-4946-a2af-c65ff3f63569	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9e9da882-135c-4fc2-a429-a4a638a8bfdf	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d74f950b-0951-485e-a5a2-d36d5ee9f4aa	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
84445e10-577b-4836-852d-8a591477c494	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ac6efbfa-a00a-4bc7-9689-c2cc2a61818a	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c576dfb0-454c-4854-afe1-e6ead01e2487	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f4967288-a9f4-4cc6-ae40-fbee2a896ea4	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
383e6b5c-311a-4500-ba2a-6b0a21654389	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0de56038-3864-4a65-8398-6831b982b87b	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
38cddfec-a531-4e3f-a522-c514ba45b6a6	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
717d7c9e-5a4d-4601-8974-6ce7abba0281	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
cb0c405d-a6cf-47d9-9877-ec5015b2715f	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
9a7f149a-1de3-4712-83f7-34e35b07743c	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0002-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
2b7b0801-c8c3-42b4-90d5-8fe8b030cb9b	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
b428d540-5d60-45d5-a6b9-69145bd82ff5	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f7c66500-d3fb-4de2-962e-78146aa17d6f	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
547e3db1-2431-4036-a0af-40812e277d68	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0002-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
02705bf9-3399-4051-9e29-bedb1a619eea	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
427d6b9b-0406-4d3c-9837-8437ceda14a0	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7872d8e6-a897-4b4c-bb45-ff6b77c5b7e4	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
63a822d9-f1c4-431e-910f-387c820dbc0b	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9e8ee295-85ac-455c-9d32-a7c064ae1861	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
48c177a8-0c75-442e-b87d-072c088bfa26	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3024baa4-a1c0-45cb-9556-b209684fe764	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
717ab603-65ef-4f19-9861-5e5673441d09	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e8180886-9274-4e01-baa5-82f17d6596bc	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0001-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
37d39268-d2cd-449c-98a0-42773d61bce2	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
1cd47619-d0a8-4294-9df6-7000530bd506	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ee4987cf-26f6-4f61-a9dd-0166940a8451	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e9c0e9ce-7a8a-45a7-b39c-67188c2fc2bc	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
90c00703-37c0-488a-b2fc-e40b4f732beb	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	c1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d6355ea3-3ba5-46f6-9976-98441c442035	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
30e77ba7-5f48-45f9-9987-0d3b14a3eba6	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
1294a9a3-bec5-4bdb-b70d-fd41378f6083	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
725cbaf2-6a7f-441f-8d7e-2410afb39a5b	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a6fbdbec-5fe2-4176-80d3-0968a744b67f	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f86f385f-052f-4fc4-b043-3b5612104be9	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
4495fc01-a47b-4558-957e-c838089b09d5	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a0ee26fb-c49b-4d51-b8bd-2dce8fa4a5ad	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7e58feca-d766-49e3-979b-67f2a36584c4	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
467fd0cb-efb1-40a3-9f19-1c9a1f61d745	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
27a3fc9f-1081-4735-82e3-5af09cf33fb7	aba61e5b-422a-4461-b9da-8dba8f6d3f85	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
eb281ac7-5bcb-4a2d-bb39-7d3dd79a747e	aba61e5b-422a-4461-b9da-8dba8f6d3f85	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bcd72a66-d4e4-4e8a-a6e8-67dc166fb23d	aba61e5b-422a-4461-b9da-8dba8f6d3f85	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
023bbf85-1862-47db-bddd-94623454febd	aba61e5b-422a-4461-b9da-8dba8f6d3f85	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
74c53844-a489-46b1-a894-0a4bc6a5b68c	aba61e5b-422a-4461-b9da-8dba8f6d3f85	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
50ed555d-c250-4f26-a5c2-8afc3dbcfff9	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
26e4c512-a4bc-4984-85e3-c14dc566a0ae	aba61e5b-422a-4461-b9da-8dba8f6d3f85	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
85cef21f-0796-4838-93b6-f4873fea205c	aba61e5b-422a-4461-b9da-8dba8f6d3f85	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
7f6efef2-429c-419e-a5ea-6813806c798f	aba61e5b-422a-4461-b9da-8dba8f6d3f85	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f4cb9452-2e94-4898-ad2b-4b77cb9804e2	aba61e5b-422a-4461-b9da-8dba8f6d3f85	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
abade0eb-d7f0-4d00-90b9-c5fa785b6339	aba61e5b-422a-4461-b9da-8dba8f6d3f85	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
5019f88d-6580-4568-91eb-497209323f30	aba61e5b-422a-4461-b9da-8dba8f6d3f85	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
24f5c3bb-9980-49e3-aaeb-b9e460b17928	aba61e5b-422a-4461-b9da-8dba8f6d3f85	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
4201fbfb-f3b5-43f9-bcf5-1d095de32278	aba61e5b-422a-4461-b9da-8dba8f6d3f85	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
680b6b77-4c27-4d0a-861a-a90baeea4bc2	aba61e5b-422a-4461-b9da-8dba8f6d3f85	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0060b2fd-df5e-4abe-8554-02203e8adcfc	aba61e5b-422a-4461-b9da-8dba8f6d3f85	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
72a593c2-4567-48cf-be79-ad215d288b65	aba61e5b-422a-4461-b9da-8dba8f6d3f85	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
62e266d7-e8fe-407c-a17b-8ed064dc7b23	aba61e5b-422a-4461-b9da-8dba8f6d3f85	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
60959a6d-c425-4ca8-907f-8d8e4806fcb4	aba61e5b-422a-4461-b9da-8dba8f6d3f85	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a432a740-474a-45da-af56-539c6fbd5549	aba61e5b-422a-4461-b9da-8dba8f6d3f85	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3fb25101-367f-4962-b74d-e36a530b74e3	aba61e5b-422a-4461-b9da-8dba8f6d3f85	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a6eab0d6-4e22-43bd-8400-13e6885f6702	aba61e5b-422a-4461-b9da-8dba8f6d3f85	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
61182db9-0084-4794-8c86-e17f6c436690	aba61e5b-422a-4461-b9da-8dba8f6d3f85	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d8f261c6-4e3a-41fe-805b-e95118f791d8	aba61e5b-422a-4461-b9da-8dba8f6d3f85	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9f6e62a6-eedd-469f-9fa7-28e3b90c9f8b	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
37f9bfe0-01ad-4e1e-8592-4fc8c8396e62	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0002-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
b09799bc-11d1-4773-a818-878072d738e3	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0002-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
655ef5c7-fe52-48f4-8ac3-175d983297d9	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
cb162b32-9a38-4a36-8ec8-b7a830953ef9	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0002-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5c7a5629-a0fe-43c8-8b8d-b8cea362a4d7	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0002-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a6cb714a-a908-46b1-b269-6b681e3764de	aba61e5b-422a-4461-b9da-8dba8f6d3f85	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
70cd5e4b-ef92-4c7a-83c1-b8b286d1e408	aba61e5b-422a-4461-b9da-8dba8f6d3f85	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
1889f0a7-2a12-4ae4-9bc9-6999a1095cb4	aba61e5b-422a-4461-b9da-8dba8f6d3f85	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
b742a0de-dcb3-4ede-b456-b9160127d8b4	aba61e5b-422a-4461-b9da-8dba8f6d3f85	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c77bc095-8323-4680-8540-e4c9194a7537	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e8cee21d-974a-41ed-9671-bda71caf946e	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
b9cf549b-6582-4582-9949-d8e067790212	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
61d803b5-f9ed-4dfa-ad7b-5c5421cf4827	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
cc1f6739-2358-46de-87ac-abecce685356	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
63f0b6c8-e5aa-49bd-b5df-287db021b508	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
55078c0d-da17-4b9d-b2f6-21edbfd949fc	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
bb442cc7-cd73-4b58-b2b1-93e6597ce4a3	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0001-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d036efe9-14a5-4729-a419-b9f7d925250a	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
2ed316a4-86c0-4121-855d-50a851ef39d8	aba61e5b-422a-4461-b9da-8dba8f6d3f85	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d8535e02-f13e-4442-a625-9e2aaebca31d	aba61e5b-422a-4461-b9da-8dba8f6d3f85	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
055965c3-7ce9-47a5-b0e3-05a7e3d1d1a5	aba61e5b-422a-4461-b9da-8dba8f6d3f85	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ec3aac0c-f8a2-4061-b26e-85e86b19c9a6	aba61e5b-422a-4461-b9da-8dba8f6d3f85	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bbf1c3d7-1a56-435e-a0e8-94b94bbd4842	aba61e5b-422a-4461-b9da-8dba8f6d3f85	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
597bd561-0548-4870-a0e5-f2b35bc0c7a9	aba61e5b-422a-4461-b9da-8dba8f6d3f85	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9c3a8670-0f93-4265-bcef-c87d883cba51	aba61e5b-422a-4461-b9da-8dba8f6d3f85	0d274292-537d-4c41-8e23-3df901304d71	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
8ccaebfc-f4d0-4ba8-a19e-2037b5db4ed3	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b043e6e1-8bb9-41fb-813e-dc5690b0711b	aba61e5b-422a-4461-b9da-8dba8f6d3f85	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
5af0d9dc-c480-4906-a533-7a95fd6d51d2	aba61e5b-422a-4461-b9da-8dba8f6d3f85	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
10cb5503-dee1-4b2b-9574-3fad2bbb9563	aba61e5b-422a-4461-b9da-8dba8f6d3f85	682f26ec-e31d-43a0-82de-e915bab54b59	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
afc37fa4-cc35-46b0-ad53-7ac941b6234f	1a62b1f8-1810-464d-a67b-168d7e419827	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
85a6e08a-d5f2-4951-96e0-ece9129637f9	1a62b1f8-1810-464d-a67b-168d7e419827	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e4d50e84-e073-4a95-9c4c-ad76318f1bc7	1a62b1f8-1810-464d-a67b-168d7e419827	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0446246c-3e45-4932-80ce-c3310558b066	1a62b1f8-1810-464d-a67b-168d7e419827	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
b5f38aab-36b5-45ee-91af-373beddcb4fd	1a62b1f8-1810-464d-a67b-168d7e419827	168b1296-de6a-4f9e-a3b9-617b83863736	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
4ac110ba-15c4-4b32-8f57-ced5226f541b	1a62b1f8-1810-464d-a67b-168d7e419827	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6711097b-b1cd-4476-89e9-564523d8d175	1a62b1f8-1810-464d-a67b-168d7e419827	715f79ce-51ea-46d3-b95d-8318840f90a6	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
07629b74-f498-45c2-af27-dc22ae4f6ee7	1a62b1f8-1810-464d-a67b-168d7e419827	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
2c1f564e-3df0-4ddb-b6ef-704087715f72	1a62b1f8-1810-464d-a67b-168d7e419827	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c7d96ee2-6f83-408d-b14e-a7a649da539a	1a62b1f8-1810-464d-a67b-168d7e419827	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
724519e3-8f2d-490b-868b-a80362b7111c	1a62b1f8-1810-464d-a67b-168d7e419827	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
345c5873-de0b-46ce-b43e-fce01797f1d2	1a62b1f8-1810-464d-a67b-168d7e419827	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c64f00d9-3adb-4fef-93e6-d51fa9306f2e	1a62b1f8-1810-464d-a67b-168d7e419827	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
64ef3474-9c6b-4c6c-b4bb-0b8443b3ad22	1a62b1f8-1810-464d-a67b-168d7e419827	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3549ab38-0b6f-47b7-82e7-a3bcfb2fb604	1a62b1f8-1810-464d-a67b-168d7e419827	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
beb049e6-b526-4da6-bc97-9b65ea66b51a	1a62b1f8-1810-464d-a67b-168d7e419827	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a78e206e-b295-4a58-8a31-d9fc7449c665	1a62b1f8-1810-464d-a67b-168d7e419827	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
8f6c5cc7-ee88-4ea2-83aa-93e8b134e967	1a62b1f8-1810-464d-a67b-168d7e419827	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
a83a6626-e524-40e5-9cef-9e799b561a97	1a62b1f8-1810-464d-a67b-168d7e419827	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
44e49471-0ecc-4ac0-aabf-cccb595641c8	1a62b1f8-1810-464d-a67b-168d7e419827	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9bb2037d-23db-4d04-a1ef-19f9b7eb15c3	1a62b1f8-1810-464d-a67b-168d7e419827	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
94ce9ebd-857a-4bcf-bf62-cc4fd4345aa8	1a62b1f8-1810-464d-a67b-168d7e419827	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c463ed4a-8586-4059-8be7-322059bf6ff0	1a62b1f8-1810-464d-a67b-168d7e419827	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
13e91775-310f-40d2-8d83-9b3a287112f3	1a62b1f8-1810-464d-a67b-168d7e419827	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
96933766-303f-48d8-8313-e1c9ceb73f97	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0002-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d92f052c-079c-4859-baf0-76cfb54ad4b2	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0002-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9d5350e9-1d16-412e-89d3-10b99ad188e4	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0002-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
7b81161a-68e3-49b9-a140-36c61562a0c7	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0002-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1f1b52d5-5a97-4c6b-b050-265f470e3d62	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0002-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
82646aaf-ab2b-4903-8222-c36cfe982f2d	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0002-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0b58eb2a-0078-43a9-9ced-383fb1d69d30	1a62b1f8-1810-464d-a67b-168d7e419827	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
f301b921-36e3-41ae-912b-f4f6606d2659	1a62b1f8-1810-464d-a67b-168d7e419827	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a9f7b109-90a1-4b7d-af89-8271a76d2f95	1a62b1f8-1810-464d-a67b-168d7e419827	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
404acafe-3d79-455e-b7de-168ba1b2e978	1a62b1f8-1810-464d-a67b-168d7e419827	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
97f1842c-4d3e-49e5-b35a-9813251a7f2a	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0003-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
fe3e9677-eaa1-4af8-976f-ee5ef163ba95	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0003-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b346a0c9-7c88-4c82-b64d-a8f91b7afb78	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0003-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b0e1d754-0c4f-47f0-bdf5-be8d3e5a87cc	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0003-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
4490c6cd-78ec-4710-b500-6b5ed2db16c4	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
7c704ba1-b9c0-474a-a482-bad2859ef0e9	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
6b589bfc-ba9c-43ef-ad37-822d7d1ed1ab	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
005b1d30-7e74-48cc-9c2e-db9e3332cdf0	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
80c30f13-6c2c-4bfe-9bb8-b5a01a3dcafb	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9d0ba3e7-a401-4ab7-9ce1-f15e91697ad1	1a62b1f8-1810-464d-a67b-168d7e419827	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1669836b-0347-4e96-9fd3-bb49d10645cb	1a62b1f8-1810-464d-a67b-168d7e419827	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e2722284-f11d-45d4-8b34-7724f85f1efd	1a62b1f8-1810-464d-a67b-168d7e419827	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d9709643-1004-4c07-b1da-b4a254992d42	1a62b1f8-1810-464d-a67b-168d7e419827	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
83249f2e-e3f6-4bd1-a020-46e539ab6286	1a62b1f8-1810-464d-a67b-168d7e419827	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a4a058d7-0c03-4f2e-bd9f-a07a9d0a31d4	1a62b1f8-1810-464d-a67b-168d7e419827	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1526c9cc-e52c-4725-b879-c8270984e378	1a62b1f8-1810-464d-a67b-168d7e419827	0d274292-537d-4c41-8e23-3df901304d71	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
eaad30d5-3254-4d0b-bbb1-435072109887	1a62b1f8-1810-464d-a67b-168d7e419827	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
65f21181-577b-4f04-8a34-e97b69283960	1a62b1f8-1810-464d-a67b-168d7e419827	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
73dbd3f9-80ab-4731-bc25-7c8eb4763863	1a62b1f8-1810-464d-a67b-168d7e419827	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
fd2e5f17-589c-44d3-8df3-c5d1a01f57a7	1a62b1f8-1810-464d-a67b-168d7e419827	682f26ec-e31d-43a0-82de-e915bab54b59	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d9f78b5e-5ec2-4829-bfa5-1080ea6c922c	914d8500-03b6-4a43-a250-244effca1cf1	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9845de98-f4bd-406a-a72d-380ddde91fd0	914d8500-03b6-4a43-a250-244effca1cf1	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
dbdcba5e-7ba7-4935-b347-2f59118ab5d4	914d8500-03b6-4a43-a250-244effca1cf1	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
01477519-7a01-447d-b6b8-e36442ca09cb	914d8500-03b6-4a43-a250-244effca1cf1	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
81ad163d-e7b3-44fe-b961-9f99ab6a6bf7	914d8500-03b6-4a43-a250-244effca1cf1	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d253392b-4863-4638-a1c5-817080a39bde	914d8500-03b6-4a43-a250-244effca1cf1	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
2512fd96-ee77-4391-9811-6d148652056d	914d8500-03b6-4a43-a250-244effca1cf1	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
4a40b820-861d-4c28-80b5-568451e4ea75	914d8500-03b6-4a43-a250-244effca1cf1	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
62b8473f-0251-4d74-841c-72e94563865d	914d8500-03b6-4a43-a250-244effca1cf1	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bed2f1bc-f3d1-40e0-81d7-e24bee3a337f	914d8500-03b6-4a43-a250-244effca1cf1	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3e91b346-f7dd-4141-baf0-69f1fcae4925	914d8500-03b6-4a43-a250-244effca1cf1	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1f3f4910-1cf0-4472-a7e2-49a6b2d105d7	914d8500-03b6-4a43-a250-244effca1cf1	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
2c2bd911-a1de-4e94-9568-c74be604d0a3	914d8500-03b6-4a43-a250-244effca1cf1	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3124fca6-92db-42dc-86fe-be5300ab7a4d	914d8500-03b6-4a43-a250-244effca1cf1	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
68f78b1c-9475-4653-9482-22260dbedc69	914d8500-03b6-4a43-a250-244effca1cf1	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
e7acec2d-8c13-472f-8218-6ab0494777fa	914d8500-03b6-4a43-a250-244effca1cf1	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
431c96cc-0032-45ca-ad45-c21e0e83b1fb	914d8500-03b6-4a43-a250-244effca1cf1	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
e6b95889-4d4d-4fa7-805a-5d17c9eb1e9f	914d8500-03b6-4a43-a250-244effca1cf1	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
839578cc-1cc7-4551-9624-a3ddc5cc9c0a	914d8500-03b6-4a43-a250-244effca1cf1	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bbfb872f-67cd-478f-bfd8-50ebc6762629	914d8500-03b6-4a43-a250-244effca1cf1	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
05ca55df-98d1-4e22-bdf5-baa6863e9644	914d8500-03b6-4a43-a250-244effca1cf1	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b51a9f4e-e918-40d2-a1fe-a9ddb7703614	914d8500-03b6-4a43-a250-244effca1cf1	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
29860196-4c2c-4f71-91ca-98942b21071a	914d8500-03b6-4a43-a250-244effca1cf1	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
26be7fe9-7208-473b-8c61-35797e90dabd	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
143a34eb-3123-42fa-ab39-bf46377977f2	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0002-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
983e5fcb-0730-4f9a-9d61-ed4bcc8a4da6	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
fa2634f6-60e5-469a-a278-2a4234c90480	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0002-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ee8acd60-be49-48aa-b36f-c1e9bbe6edef	914d8500-03b6-4a43-a250-244effca1cf1	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ebee58f0-6479-4994-a9f9-61307814fc23	914d8500-03b6-4a43-a250-244effca1cf1	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3811ef42-b957-4383-a2d6-8eaa0985337a	914d8500-03b6-4a43-a250-244effca1cf1	d67426d3-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c464b0f3-40c3-48d6-bc53-8b71e4a71634	914d8500-03b6-4a43-a250-244effca1cf1	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
8ed8a0af-1a42-40ce-84df-71a6bce96839	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
64716e3d-43b1-438e-8405-d18d0b535d40	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
eefdca51-1dbe-49bb-be74-d3a2a4120074	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
21da76ec-36ec-4f8b-90b2-b3d170c3fc49	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f3fd8ca2-8590-443f-a9c4-315a54831262	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ed4a7ce0-ae0e-446d-94bc-2301589fa3ba	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a43545e3-d6b6-4e67-8eb8-11767bbb5eeb	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
dfc516b8-2957-46eb-870c-9e2074ba1ed7	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8b35fe04-9689-475c-b8e5-64fffe2c471c	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e5a46afe-ab8a-48c5-a961-9ecdc35404c9	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
1c247e5e-61a9-45f5-a206-413d1a5c644d	914d8500-03b6-4a43-a250-244effca1cf1	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e10eb413-0711-4a71-a763-73628e49a73d	914d8500-03b6-4a43-a250-244effca1cf1	d67426d3-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
912c1e07-9c73-4f67-aa96-4073ab1a9286	914d8500-03b6-4a43-a250-244effca1cf1	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
4b85f72c-e306-47b1-9ee2-cf73a18a0be2	914d8500-03b6-4a43-a250-244effca1cf1	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c1d9cc78-555d-46b1-86f0-6b54b7af8be3	914d8500-03b6-4a43-a250-244effca1cf1	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
b961378e-80b3-413e-89c2-6a6d0727bbb3	914d8500-03b6-4a43-a250-244effca1cf1	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c95ebb61-7dfc-418b-8615-717a441ebb62	914d8500-03b6-4a43-a250-244effca1cf1	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8bfc20f4-44c7-43da-b168-0ac086b8fa0a	914d8500-03b6-4a43-a250-244effca1cf1	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5fb4c25e-53a3-4b74-90fa-d3fe0c831978	914d8500-03b6-4a43-a250-244effca1cf1	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8649be7d-794d-4ede-a039-b25b554754ab	914d8500-03b6-4a43-a250-244effca1cf1	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
df693ddb-3c33-4a88-9a2a-550e3c589909	c787fe3b-4b33-40ee-8794-c1148202f81a	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
1dd2d9e1-3458-4932-87f2-7cf7dbcb57f4	c787fe3b-4b33-40ee-8794-c1148202f81a	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
30245be6-ed30-4838-9f2b-4372e0f39237	c787fe3b-4b33-40ee-8794-c1148202f81a	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
28f26b02-18b4-46c1-9872-0a15d72cf301	c787fe3b-4b33-40ee-8794-c1148202f81a	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
166db884-4dc4-4152-b000-fb545255ddb0	c787fe3b-4b33-40ee-8794-c1148202f81a	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
fbae10ce-63f2-4d5f-bdf4-00ba953152d3	c787fe3b-4b33-40ee-8794-c1148202f81a	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
10fdba3a-e407-45ef-92c1-4a3927bf3d90	c787fe3b-4b33-40ee-8794-c1148202f81a	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
92dda366-4876-44bb-a7b5-5ee5d4f07879	c787fe3b-4b33-40ee-8794-c1148202f81a	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
285b5bc9-560a-456e-88b0-d622a415f41a	c787fe3b-4b33-40ee-8794-c1148202f81a	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
db899843-cf94-4a1b-ad83-ee66267c4af7	c787fe3b-4b33-40ee-8794-c1148202f81a	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
53d71a11-1a09-4637-a9d6-904863d8554c	c787fe3b-4b33-40ee-8794-c1148202f81a	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
8441c809-38f9-47f3-a26d-574eeb507b6c	c787fe3b-4b33-40ee-8794-c1148202f81a	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
6785bef7-9a5e-4ab7-ba28-146a87f61ad5	c787fe3b-4b33-40ee-8794-c1148202f81a	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
22a4dc29-f79d-4de4-9c0a-dbc53697af55	c787fe3b-4b33-40ee-8794-c1148202f81a	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
30db77f4-ddff-43b6-84f7-8bbb78bd87dc	c787fe3b-4b33-40ee-8794-c1148202f81a	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
a8808a42-4eca-466f-8014-ed83d2afedd8	c787fe3b-4b33-40ee-8794-c1148202f81a	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
639e22db-c986-4c51-b43f-5da17431992f	c787fe3b-4b33-40ee-8794-c1148202f81a	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
abf64a83-4cad-43c7-a0e7-0154201eea84	c787fe3b-4b33-40ee-8794-c1148202f81a	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
e933728c-3ea3-4e34-bef8-3c652628f4b2	c787fe3b-4b33-40ee-8794-c1148202f81a	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
cd6866f4-056c-4369-b046-fbda0059c497	c787fe3b-4b33-40ee-8794-c1148202f81a	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
5ad8a999-5c7e-4566-8cb2-f3c7ccf0362f	c787fe3b-4b33-40ee-8794-c1148202f81a	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c4945a29-bdd0-41ec-9fb5-3bd00bb68512	c787fe3b-4b33-40ee-8794-c1148202f81a	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
794ff84a-f1a4-43a8-b48a-975f02f3186a	c787fe3b-4b33-40ee-8794-c1148202f81a	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
7a045df9-9cd1-4978-a0e5-f8e453c67f58	c787fe3b-4b33-40ee-8794-c1148202f81a	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
bec0c581-4ad9-47af-bb9a-663fd98d59c7	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
60ca063a-7931-435c-b227-d87ac6fb4403	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0002-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ec139deb-5984-4764-89d5-b33c4e8b9cf1	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
6d497c56-77e5-4950-9c40-0b75eb2490a6	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
45391111-3cf8-4f2e-8247-1fa63aafff60	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
37549da0-5566-4ebe-8cad-a3ad0702d7d7	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0002-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
bce82d2b-7780-4a30-9639-f8717ffb601c	c787fe3b-4b33-40ee-8794-c1148202f81a	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
2dd39353-2245-4f82-9d00-9f9d34ebeb20	c787fe3b-4b33-40ee-8794-c1148202f81a	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3d00e60a-4c64-401f-a9bb-25e38d2f35ae	c787fe3b-4b33-40ee-8794-c1148202f81a	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
97f5e59e-be21-45a6-a0af-56851c27fb55	c787fe3b-4b33-40ee-8794-c1148202f81a	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
b9ae79c1-32e6-413f-99a3-0caa351c2a29	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6428a0ce-be1c-45cf-8a8c-cded6fd2d5dd	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
5e8dcf65-b8dd-4f81-af32-4b4203cc3380	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
9a24956d-72b6-4aa4-81a6-d1c6fca187fa	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e66f10f8-7070-4872-bf6a-f05301a84677	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0001-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
8b715248-5cf9-4075-b0c7-c8c1a3913b7a	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
2a503969-7845-47c0-9ce7-0a6f98247cb4	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8b9f3d64-0a25-418c-8548-02882409a437	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
58c8df07-662f-430d-b61c-7e47fff93caf	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f918715c-0c7f-4aca-b785-152b8206b8ff	c787fe3b-4b33-40ee-8794-c1148202f81a	c1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
b3fd1808-68b1-435b-b01d-8544ac2cb694	c787fe3b-4b33-40ee-8794-c1148202f81a	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c04e8881-dd0a-4de0-9af2-c38d068fb753	c787fe3b-4b33-40ee-8794-c1148202f81a	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
bff503ab-0754-4554-aa7e-c4d215972da8	c787fe3b-4b33-40ee-8794-c1148202f81a	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a62fce9e-c32b-44f1-89f1-b82407f05bf1	c787fe3b-4b33-40ee-8794-c1148202f81a	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a0ac620d-ef54-48ed-bf76-ee559381991e	c787fe3b-4b33-40ee-8794-c1148202f81a	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6fb66262-744e-4630-9e5b-6739aeaba253	c787fe3b-4b33-40ee-8794-c1148202f81a	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3ec26ab2-b270-4faa-9cfd-f4e58d0157c4	c787fe3b-4b33-40ee-8794-c1148202f81a	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6b084bd6-77da-4182-b495-d8b8c6900ba7	c787fe3b-4b33-40ee-8794-c1148202f81a	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3020d701-134f-4a92-8e0d-d18f4213d89b	c787fe3b-4b33-40ee-8794-c1148202f81a	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
077dbf89-8500-49e7-81c2-f9e8257ced9f	c787fe3b-4b33-40ee-8794-c1148202f81a	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f828a1a6-2deb-4e22-92b2-e9fe5db14d00	efc1df20-ca04-44a6-87b2-7cae1ff50a88	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3f8b5917-76b6-4462-9d1b-ab1c742de529	efc1df20-ca04-44a6-87b2-7cae1ff50a88	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
de6ba01c-9247-4f4e-bda1-bc4139724f8e	efc1df20-ca04-44a6-87b2-7cae1ff50a88	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
3cb78bce-d175-4ac9-bb2a-9ac6cac1f518	efc1df20-ca04-44a6-87b2-7cae1ff50a88	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
1015a127-4fd5-41b1-b1a7-90a62a29d75a	efc1df20-ca04-44a6-87b2-7cae1ff50a88	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
7e84fe40-8cef-4372-b806-69ec07debdfc	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
fc19b6cc-40e0-4a5f-ba90-57bfd21b3d04	efc1df20-ca04-44a6-87b2-7cae1ff50a88	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0ced4789-3541-471a-9a68-c04b0e6c0f41	efc1df20-ca04-44a6-87b2-7cae1ff50a88	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
58d6166d-6663-424a-825f-976eab96d41a	efc1df20-ca04-44a6-87b2-7cae1ff50a88	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
084e4e10-6a83-4a01-aa2d-58d996769ca7	efc1df20-ca04-44a6-87b2-7cae1ff50a88	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
e99025d6-e77d-498d-8bcf-c06ba2a143a3	efc1df20-ca04-44a6-87b2-7cae1ff50a88	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3e10888f-eab1-4afc-84d9-7188671d5557	efc1df20-ca04-44a6-87b2-7cae1ff50a88	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
d4da16aa-ae80-4e26-bb73-e089539cd370	efc1df20-ca04-44a6-87b2-7cae1ff50a88	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3f49b734-1422-486b-b529-d81b6d2bda62	efc1df20-ca04-44a6-87b2-7cae1ff50a88	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
2eac0337-9276-476f-9888-4e2bfd16c6c8	efc1df20-ca04-44a6-87b2-7cae1ff50a88	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ab5c919b-7c30-40b2-b2c4-1dcf3b537f41	efc1df20-ca04-44a6-87b2-7cae1ff50a88	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c40a3be4-9985-41ea-84dc-e8ba0a4ae911	efc1df20-ca04-44a6-87b2-7cae1ff50a88	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3840dd68-8d51-4c14-92b7-daacf2084149	efc1df20-ca04-44a6-87b2-7cae1ff50a88	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
6ba3515f-f8bc-4699-bce2-24d334a0eec6	efc1df20-ca04-44a6-87b2-7cae1ff50a88	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
289f617f-6c45-446e-bb76-c480948b831f	efc1df20-ca04-44a6-87b2-7cae1ff50a88	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3245f6ef-8968-4dde-99b2-26e39b3a2a1b	efc1df20-ca04-44a6-87b2-7cae1ff50a88	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
43be762f-694b-4cc1-bff2-756dac036378	efc1df20-ca04-44a6-87b2-7cae1ff50a88	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
fedd6adb-d01f-4191-abfb-2cd934ad0dca	efc1df20-ca04-44a6-87b2-7cae1ff50a88	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
19c082f3-0dd8-407b-b0f7-c0bd607e3a05	efc1df20-ca04-44a6-87b2-7cae1ff50a88	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ea14d132-8c24-43c8-9e72-2198a0dd5766	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0d9c0fe6-e15a-4630-b46f-6a58f38f6fb7	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0002-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3ef3b37c-cd46-426a-876a-938a667a9daf	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
491a6926-c154-4651-b648-37c0d3942a60	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
db66d75f-0a69-463e-aa05-3335bf6d6ead	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
4e26211d-eecb-4cf2-98e0-8a8b177c327f	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0002-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
55955b49-38f4-42b0-a06b-b841c73b9698	efc1df20-ca04-44a6-87b2-7cae1ff50a88	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
afedb779-ee4b-42d8-ba02-987a0d5eb406	efc1df20-ca04-44a6-87b2-7cae1ff50a88	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
a8b1a2f8-6faf-418f-9ecc-2792238752a7	efc1df20-ca04-44a6-87b2-7cae1ff50a88	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
5c146273-d54c-416f-b49c-95b576f75141	efc1df20-ca04-44a6-87b2-7cae1ff50a88	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
39878bc4-b311-4fc3-9ae2-a22d069f39f3	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
70803bfe-394c-4e35-a8f7-caf33628673a	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d0af724a-9444-4a33-b399-fb89baee5f31	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
650bfd37-bf62-448c-8ef8-f08f9c3b27e9	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
4321d909-fcdd-4bde-b713-1b35a6d40908	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0001-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
bcfe15f1-0aba-45fd-8014-77485e9fe2f9	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
b48e2c4b-0830-4b5d-ba39-d2fc60913231	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
818cc346-5734-41bb-a209-26d5cddc12c5	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
62bda38d-26b2-446e-b174-9f2745ef76a0	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
c4922c34-7440-47c4-991a-06132e087a51	efc1df20-ca04-44a6-87b2-7cae1ff50a88	c1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
8a46e776-abcd-445a-8f71-2cc754a64c53	efc1df20-ca04-44a6-87b2-7cae1ff50a88	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
50cb2fd0-cafb-43ce-9eb1-468ae979dc98	efc1df20-ca04-44a6-87b2-7cae1ff50a88	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
c769ee6c-5dbd-47bf-ac3f-b015d2020240	efc1df20-ca04-44a6-87b2-7cae1ff50a88	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6eb009ec-c347-423d-b310-5140326e7e52	efc1df20-ca04-44a6-87b2-7cae1ff50a88	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
1a59877c-ee6f-41b4-9a38-cbfe19b9eae6	efc1df20-ca04-44a6-87b2-7cae1ff50a88	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7bd5ae77-ed54-454c-8f2b-b6f3487512e0	efc1df20-ca04-44a6-87b2-7cae1ff50a88	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0a9aa7dd-d5bc-47cd-8a49-f18bf21eece0	efc1df20-ca04-44a6-87b2-7cae1ff50a88	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
aaf8b5f8-1dbd-4763-8d5c-d2e5c1ab23e9	efc1df20-ca04-44a6-87b2-7cae1ff50a88	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
1d62007e-d376-4949-8557-275b290e85e9	efc1df20-ca04-44a6-87b2-7cae1ff50a88	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7ec459b7-fc68-408d-bf63-f007c59ac9ce	efc1df20-ca04-44a6-87b2-7cae1ff50a88	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6ea6fa07-3298-4578-b4a2-9f3791c2baa8	a3793f87-7f3c-41a1-a675-236fc1b710ab	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
98fe38ef-3312-4376-a801-77a715cd9d09	a3793f87-7f3c-41a1-a675-236fc1b710ab	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
fc296597-f0ca-43f7-831a-8c9047d83e6b	a3793f87-7f3c-41a1-a675-236fc1b710ab	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ac1f1082-5b92-4149-8a5e-f1645eead0f9	a3793f87-7f3c-41a1-a675-236fc1b710ab	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
ed0347cc-454e-4f6d-9a87-c5c12b8f3c01	a3793f87-7f3c-41a1-a675-236fc1b710ab	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
cdeaa81f-3340-4216-ad7c-a747ebb38ac8	a3793f87-7f3c-41a1-a675-236fc1b710ab	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6cefe94d-6401-4f30-b6ce-056380faa9d2	a3793f87-7f3c-41a1-a675-236fc1b710ab	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
77c4c7e7-2ad2-4a98-8b1b-c73caa02c23d	a3793f87-7f3c-41a1-a675-236fc1b710ab	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0b8972f7-04f2-470c-9d93-2b1e2307b9b6	a3793f87-7f3c-41a1-a675-236fc1b710ab	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b7c24158-ced6-4b88-a69a-00d479f476b0	a3793f87-7f3c-41a1-a675-236fc1b710ab	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0055e9fa-c718-49de-975f-42084de4ecfc	a3793f87-7f3c-41a1-a675-236fc1b710ab	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
27c38c3d-ad87-4e49-a997-548ba65cf6b3	a3793f87-7f3c-41a1-a675-236fc1b710ab	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
4bd3f2e0-7646-4b08-89c8-adf95f4fcbc2	a3793f87-7f3c-41a1-a675-236fc1b710ab	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3f360a82-ad00-4d21-b002-fe5b72a48491	a3793f87-7f3c-41a1-a675-236fc1b710ab	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
4ddbfce5-5833-4c51-807b-0722aa94b2d9	a3793f87-7f3c-41a1-a675-236fc1b710ab	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
a0951196-e4c8-4e44-87ed-bcaa7f317166	a3793f87-7f3c-41a1-a675-236fc1b710ab	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1aafd887-2c5e-4512-848d-cf4ebc12b840	a3793f87-7f3c-41a1-a675-236fc1b710ab	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
35e91143-0964-4994-a011-089bc0c406f5	a3793f87-7f3c-41a1-a675-236fc1b710ab	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
b6b2ee87-36b0-4959-94ae-538019b7d775	a3793f87-7f3c-41a1-a675-236fc1b710ab	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
50578aaf-559c-43a4-8802-68e013741731	a3793f87-7f3c-41a1-a675-236fc1b710ab	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
02b58732-cbcd-4aeb-8205-b806bbbbac93	a3793f87-7f3c-41a1-a675-236fc1b710ab	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
61f43a66-69ed-4a13-ac83-804c260b17dd	a3793f87-7f3c-41a1-a675-236fc1b710ab	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1da72cd1-fc34-427f-9e1f-d2f4efa68d66	a3793f87-7f3c-41a1-a675-236fc1b710ab	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
966007e7-e3ef-47e6-93fa-e247abe53923	a3793f87-7f3c-41a1-a675-236fc1b710ab	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
631c2d7d-0c38-46fc-89a8-228dd7502cd9	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
18fa97aa-2ac9-4142-97ec-c717c6cb5527	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0002-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
ae6d5969-b355-46e1-9221-627d4376607e	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0002-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
93ec4a11-e8f7-4c14-a912-df18c8623edf	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
0cbba2b5-3815-4093-a74d-24209481a7ad	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0002-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
36969c98-fd0f-48a0-9bf1-89a0ae0f6cb6	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0002-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
7c820def-d34a-489d-b865-f5dfae742c1e	a3793f87-7f3c-41a1-a675-236fc1b710ab	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
f14eec4a-9f18-492a-bdbe-6c27d74b1345	a3793f87-7f3c-41a1-a675-236fc1b710ab	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
fb7dfc22-5891-4839-be48-b96b3737a756	a3793f87-7f3c-41a1-a675-236fc1b710ab	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
bdafe51f-82d8-40cc-913f-4beece72aae8	a3793f87-7f3c-41a1-a675-236fc1b710ab	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
3992ac32-7e24-4c43-a3b0-91b823521172	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
9158c2ab-530d-4fea-9602-0285b84846a6	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6c1af2ca-197c-4cf2-bd2d-74807e526926	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6408e9c9-30c9-450a-a29d-2ca0d32c95dd	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
bdd8216b-9227-43c5-97f7-24a0edcb3b0b	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
f6a9214a-89fe-4f34-a060-564c69e54780	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
b54a9e6f-7e87-49aa-8ff0-03acf1c25051	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
6933af9c-9327-4ec8-891b-9ec0366cd3a1	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0001-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
e1d62cd4-3693-4ae2-8ae2-cc2619b3bd32	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
cf4029cb-07c2-49f5-834c-ce3a34a630b0	a3793f87-7f3c-41a1-a675-236fc1b710ab	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
34dd50c4-d947-4384-8ac4-a56e3ea58f63	a3793f87-7f3c-41a1-a675-236fc1b710ab	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
63699b26-45d3-438b-919c-0cab11e0fe4e	a3793f87-7f3c-41a1-a675-236fc1b710ab	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
954cb156-fb52-4a5c-bab0-4f8b8742122d	a3793f87-7f3c-41a1-a675-236fc1b710ab	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
493ae143-881e-436a-9665-93ee0197be3d	a3793f87-7f3c-41a1-a675-236fc1b710ab	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
31dc5466-62d8-42a8-8d94-c354d0ce582c	a3793f87-7f3c-41a1-a675-236fc1b710ab	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
36c25cf1-c3f7-4147-b99f-5103ca87ec66	a3793f87-7f3c-41a1-a675-236fc1b710ab	0d274292-537d-4c41-8e23-3df901304d71	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e9d6f257-2412-4873-872f-73513cb1371d	a3793f87-7f3c-41a1-a675-236fc1b710ab	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3dad2f41-1cf4-426d-8244-858833bd2984	a3793f87-7f3c-41a1-a675-236fc1b710ab	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
486050e0-8a49-4cf5-beb2-5763981d118b	a3793f87-7f3c-41a1-a675-236fc1b710ab	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
cfd4261e-b684-4b4c-ade5-fce1f434a30b	a3793f87-7f3c-41a1-a675-236fc1b710ab	682f26ec-e31d-43a0-82de-e915bab54b59	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
904372df-e687-4b72-9ed3-77675641a303	92aa9169-28d9-4754-a570-553b067642ed	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
20e669de-2c24-4dc2-8930-8adc1dcfce22	92aa9169-28d9-4754-a570-553b067642ed	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
24c1ccea-5f82-4a41-8433-6957ef5dc6df	92aa9169-28d9-4754-a570-553b067642ed	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
cdff8041-43fb-4aa7-9375-ef2ca44bb8c8	92aa9169-28d9-4754-a570-553b067642ed	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
4dfdb316-5e57-477e-8b67-b75e15fb0421	92aa9169-28d9-4754-a570-553b067642ed	168b1296-de6a-4f9e-a3b9-617b83863736	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
729c035c-7a7b-4972-962d-e0fee4e67a02	92aa9169-28d9-4754-a570-553b067642ed	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
91ba3f48-30c9-40cf-8b1f-6010489c902b	92aa9169-28d9-4754-a570-553b067642ed	715f79ce-51ea-46d3-b95d-8318840f90a6	module	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9f262f3f-d575-4b8b-b15b-dbaa0e9f5893	92aa9169-28d9-4754-a570-553b067642ed	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
0c9693a1-2a5f-499f-80df-d182a48096e6	92aa9169-28d9-4754-a570-553b067642ed	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
6b814893-f7b7-4d72-b000-2bc7caaa77a5	92aa9169-28d9-4754-a570-553b067642ed	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
2b9dcaef-b68d-4504-bcf4-20fae28a00b6	92aa9169-28d9-4754-a570-553b067642ed	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e82df2e9-c22f-463a-9add-9205ab047bef	92aa9169-28d9-4754-a570-553b067642ed	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
097808be-bb3e-46c2-a149-1b38802ffc6e	92aa9169-28d9-4754-a570-553b067642ed	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
275ca64e-6e81-470e-8f08-d6246332aa9c	92aa9169-28d9-4754-a570-553b067642ed	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
f0956ac2-bfa1-485b-a3c0-70a7637910b6	92aa9169-28d9-4754-a570-553b067642ed	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
e48587a6-2e55-4c48-bdbf-7502b754459d	92aa9169-28d9-4754-a570-553b067642ed	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
badf4d92-04bd-4246-b0c0-00d2a083f119	92aa9169-28d9-4754-a570-553b067642ed	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
36c326e6-0a06-4a63-b1e4-803fcbd51c61	92aa9169-28d9-4754-a570-553b067642ed	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
282d3753-baf5-4863-a444-44dd95aecfa0	92aa9169-28d9-4754-a570-553b067642ed	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
365e5ba4-809d-4662-a260-a53b50b9d202	92aa9169-28d9-4754-a570-553b067642ed	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3783aabb-a503-44d8-8f27-b8247d6b08c4	92aa9169-28d9-4754-a570-553b067642ed	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
7fd0eefb-08f7-4cb5-92ab-ec2dfa22929d	92aa9169-28d9-4754-a570-553b067642ed	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c0bf1f3a-4b24-460e-bd09-200ce89fa1ec	92aa9169-28d9-4754-a570-553b067642ed	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
806de6ae-5c65-4d7f-a7fd-4ec90b497066	92aa9169-28d9-4754-a570-553b067642ed	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ea2289d3-380f-4a71-b496-63d66a5d1599	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0002-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
3a81c712-d7c3-4bfe-824f-0b2a040213ea	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0002-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
34e2322c-19a9-44a5-b1e3-e025cfc98849	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0002-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
12724e1a-7565-47a2-b16f-51bb74abc8f9	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0002-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
572e50cc-5fbb-4e61-b37f-036bbd4a3d7e	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0002-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ee15f9e6-1c2c-4b72-8a71-1499fa68c18e	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0002-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ba9f379a-1a50-4f7d-a70c-e187bb7de329	92aa9169-28d9-4754-a570-553b067642ed	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
4b560913-6e65-4202-b409-c2415a8436b6	92aa9169-28d9-4754-a570-553b067642ed	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	0
d54d1438-a8a5-47bf-9e9e-67c54883da15	92aa9169-28d9-4754-a570-553b067642ed	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
9c38eb34-e7c1-4dbb-a07c-911ce7a19910	92aa9169-28d9-4754-a570-553b067642ed	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
754fb2de-7718-4c49-8c53-71fd194265da	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0003-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
82558e62-f242-4509-a1f5-7350aad3cc2a	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0003-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1f546189-6d0a-46e1-9e98-63c0feddb428	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0003-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1e0f3f5b-0055-4caf-9faa-f945cb4cbd5b	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0003-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
d3c87864-368f-43ec-a675-5e69dfc9ed5b	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
61ab6d1c-fce8-4fac-904b-80794222de18	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
9bcf4214-f2ba-4b1a-808e-21d7ea439c78	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
dff92da6-a630-4ebe-8ff5-ed4dd7996529	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
eaa0b11e-477e-4bef-a855-e92b39dbc43e	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
ae898e4f-d87e-4f91-8fd2-f29e8cdd12c9	92aa9169-28d9-4754-a570-553b067642ed	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
7cb05477-c31f-4ceb-87d5-42c58d416b27	92aa9169-28d9-4754-a570-553b067642ed	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
4081ce02-6f97-4416-b5b6-2bbabb68428a	92aa9169-28d9-4754-a570-553b067642ed	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	1	1
8832bfed-12c5-4eb2-be18-77a24570c805	92aa9169-28d9-4754-a570-553b067642ed	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
5e7dc53f-3d0a-4da3-951e-2adb982934b9	92aa9169-28d9-4754-a570-553b067642ed	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
953b9fab-b457-4bd3-9fd9-70b871ebbf06	92aa9169-28d9-4754-a570-553b067642ed	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
8a9c4415-e84e-43ad-8d7a-97d52d8c9442	92aa9169-28d9-4754-a570-553b067642ed	0d274292-537d-4c41-8e23-3df901304d71	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
c264f7f6-653a-4cb7-8379-4dab0bed9a73	92aa9169-28d9-4754-a570-553b067642ed	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
1afa6cdd-a3c1-49aa-bd42-21b945d7cf3c	92aa9169-28d9-4754-a570-553b067642ed	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
5966d425-681a-4279-8a96-39021773735e	92aa9169-28d9-4754-a570-553b067642ed	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
6111e2d5-5c91-4387-98cb-e586229b9e39	92aa9169-28d9-4754-a570-553b067642ed	682f26ec-e31d-43a0-82de-e915bab54b59	widget	0	0	2026-11-12 10:46:05.669876+05:30	\N	\N	\N	\N	0	0
4ef701b1-3407-43f1-b605-2cc04ccedfc2	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
532039c9-7595-41d2-aa6c-57e3389623a8	64c49f37-a38a-46a6-9622-7427f1501658	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
58789b5d-2acc-46c1-9a83-199d0ec59fab	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
5d17f120-e936-4ce1-baeb-bc8b64adf7a2	64c49f37-a38a-46a6-9622-7427f1501658	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
5d679165-c9a6-4da9-bf40-b48232d466f7	64c49f37-a38a-46a6-9622-7427f1501658	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
61e35f6a-339c-488c-8de6-9e5da7f087c8	64c49f37-a38a-46a6-9622-7427f1501658	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
64f16cb2-d0de-4e2a-82be-79e946e4c8f5	64c49f37-a38a-46a6-9622-7427f1501658	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
6c9cdb34-79ce-4965-9563-85a5625e380a	64c49f37-a38a-46a6-9622-7427f1501658	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
7c349239-b881-4113-88d8-b21812169ad4	64c49f37-a38a-46a6-9622-7427f1501658	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
7d9255b4-c912-45ba-b457-72a2996caa1b	64c49f37-a38a-46a6-9622-7427f1501658	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
85833643-08f0-422c-a97c-7ceae95f8287	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0001-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
8676cfe9-23fe-4eb1-a95a-bfff07499446	64c49f37-a38a-46a6-9622-7427f1501658	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
9305e6ec-481c-47c2-8ad7-8267fa4c3ad8	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
93e56cf8-d7ed-498c-8cc7-a9cb8a50f3ef	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
968f881f-c65a-49cf-a07a-98cfd5ec11e6	64c49f37-a38a-46a6-9622-7427f1501658	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
9bd87998-f670-4fe6-b451-a7da7812e558	64c49f37-a38a-46a6-9622-7427f1501658	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
9e314aeb-f779-4019-94cb-c3b7d7bb334c	64c49f37-a38a-46a6-9622-7427f1501658	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
a3ac3dca-f648-4600-85ca-4c314534f049	64c49f37-a38a-46a6-9622-7427f1501658	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
a4058dce-3ac0-4156-a9a0-4f9913c3f683	64c49f37-a38a-46a6-9622-7427f1501658	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
a4687eff-6034-46cb-96ea-25556cf7a222	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0002-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
b9bab8a2-d2b3-46dd-97eb-aaac90169e84	64c49f37-a38a-46a6-9622-7427f1501658	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
ba508aeb-4337-4f43-af6d-1fd0d94c0acd	64c49f37-a38a-46a6-9622-7427f1501658	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
bfe20207-8f90-4d50-95d8-2858a9716cbb	64c49f37-a38a-46a6-9622-7427f1501658	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
c0ecd551-420b-4ebb-8a37-9ac9f3f82d1e	64c49f37-a38a-46a6-9622-7427f1501658	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
c392c07a-be4b-4859-861c-9768384035f1	64c49f37-a38a-46a6-9622-7427f1501658	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
c3d35241-a759-4177-bf83-35cb4f3b8454	64c49f37-a38a-46a6-9622-7427f1501658	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
ca1e693d-e72d-4cad-ae88-71e5deb9792b	64c49f37-a38a-46a6-9622-7427f1501658	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
dec69ea7-801e-404c-b577-d0b79c7917c9	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
e1395b5f-74c5-426d-8b0e-e21aef523b4d	64c49f37-a38a-46a6-9622-7427f1501658	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
0810a2f8-b978-4042-a7bc-a1c03b0395b5	f29af015-7833-4f9a-ac57-6fbef5bf91ec	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
0b80525a-014c-4457-a2d2-5af381bb91de	f29af015-7833-4f9a-ac57-6fbef5bf91ec	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
0f56cf5b-bf2b-4fb9-9bc7-4200d67787b5	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
1b7032a3-cb96-4856-b326-74b67772430a	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0002-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
1cc11f1f-15d4-4ff3-b12a-104c6e79bc59	f29af015-7833-4f9a-ac57-6fbef5bf91ec	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
23b0d52e-ad4f-43e5-a019-532e35c9bb13	f29af015-7833-4f9a-ac57-6fbef5bf91ec	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
25aaec28-af8b-48b8-bf8e-514e583c9d66	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0003-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
2a8b327d-db54-465d-be6c-721f15b1dbc5	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0003-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
2ae1e155-6ef0-46b4-97f3-8e185adb1b65	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
2bff91af-7831-4e01-aae3-0f1bfb5872d9	f29af015-7833-4f9a-ac57-6fbef5bf91ec	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
2c5bdd56-ed50-4068-a8a2-485436920bdc	f29af015-7833-4f9a-ac57-6fbef5bf91ec	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
349d3327-8191-40d8-91c4-d46d73350a6a	f29af015-7833-4f9a-ac57-6fbef5bf91ec	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
3f9cf603-8772-4180-b167-fdacd47cf33b	f29af015-7833-4f9a-ac57-6fbef5bf91ec	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	1	0
4313a118-9603-42b3-b6f6-a0fe83619c02	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0002-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
437f2ac6-74ec-4c20-9b16-21d94e9a37ed	f29af015-7833-4f9a-ac57-6fbef5bf91ec	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
456b8c2c-c3af-4aa2-9b23-1b4a2c79c9f7	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0002-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
4cb3aa33-acfd-4e17-acde-56c0dcb75607	f29af015-7833-4f9a-ac57-6fbef5bf91ec	0d274292-537d-4c41-8e23-3df901304d71	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
5055379a-bb16-4748-b46d-ed01a2fb2997	f29af015-7833-4f9a-ac57-6fbef5bf91ec	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	1	1
514a0ef8-604c-48b1-b727-a70762a34fa5	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0003-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
5a5fc894-cbc6-44e8-b3d5-3c8b836e226d	f29af015-7833-4f9a-ac57-6fbef5bf91ec	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
5b3fd1d4-f176-4d2e-b518-86237a2e7982	f29af015-7833-4f9a-ac57-6fbef5bf91ec	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	1	1
682b2959-5427-44e6-998c-528e53ba1bb7	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
6858fae1-fa5c-4e15-aacb-a24251f268a6	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
6cb541ae-20dc-4fc3-a03b-1173d6acb0c5	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
74e97238-4862-41e8-a84f-21034fd236e1	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
7b17d74b-b116-4ba9-8ab5-c84f202e93a1	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
7dad5ef9-e642-4302-92be-659e86acaf27	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
7f0f2af3-25b7-442c-be08-286fdebd74e5	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
8a65591f-8d87-45a5-90b2-f4c15b858e94	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
8c511a94-bf79-4e62-b9fe-bdfeba53ffe6	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
900cdbc0-6048-4991-8ad7-8f986ccb586e	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
90afb559-76a2-4229-a115-d355b9834208	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
9cd1488c-3769-4423-8f42-642eb4206862	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0001-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
a04cb3dc-347b-427d-946a-75a24b9a2300	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
a0688f4f-eb7f-4c32-8891-c7d94cd5e194	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
a8b61bb5-c949-4092-a65c-38b6671d69b1	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
aabae195-545c-4636-aec7-de4767d04294	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
b0ca39fb-39c8-4615-969f-16a7bca97086	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
ba6562c8-305c-495b-998b-4291e2b5e4c0	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
bb512700-6bd5-47e5-b474-b23735c2c719	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
bca511b8-bd8b-42a0-82e9-738cca92b771	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
c2567bed-df1a-4cf1-a79e-c9e5c8fa927a	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
c496527b-fa01-4263-b3e8-4595010fc6d3	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
cdec31ce-d701-4ca1-86df-56148f972b77	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
d0978ace-0b0c-4c37-aab3-81aa24ebebe5	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
e343707e-cd09-4ce2-888e-94a0fbc6850d	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0002-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
e7ecdb62-bb16-452b-bfc4-a2ec72919efe	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
ead261f7-0c6d-4dcb-bc6e-bf6435e9dd47	64c49f37-a38a-46a6-9622-7427f1501658	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
f1dba0f8-0d2f-4276-8c35-5dccb3bb6f6e	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
f23611aa-d803-4d6f-bcbf-0ba362b1065c	64c49f37-a38a-46a6-9622-7427f1501658	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
f34e8eeb-19ed-47d5-8db5-5ae3ac25b44d	64c49f37-a38a-46a6-9622-7427f1501658	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
f5c6e13a-db27-4df9-9937-b66fd2d27969	64c49f37-a38a-46a6-9622-7427f1501658	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:39:31.349238+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
5d58cb6e-299f-4e3f-8bb1-1cd48793982f	f29af015-7833-4f9a-ac57-6fbef5bf91ec	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
61280f76-cd7a-4450-8adf-7544a106f7c7	f29af015-7833-4f9a-ac57-6fbef5bf91ec	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
63205003-c2ad-4a46-bc26-8fb7f65f2ce1	f29af015-7833-4f9a-ac57-6fbef5bf91ec	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	1	1
6b4a4303-5477-4a1a-ab3e-2c667b3a6d96	f29af015-7833-4f9a-ac57-6fbef5bf91ec	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
74a8f8b3-a355-4e91-8035-9bcf6f5eac8c	f29af015-7833-4f9a-ac57-6fbef5bf91ec	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
77282a8b-fecb-4aad-a6d0-75deda62b386	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
7b50dee7-5a06-42ea-acca-a2943bba97d4	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0003-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
7f548f26-f62c-4c37-9bf0-38cfc773da69	f29af015-7833-4f9a-ac57-6fbef5bf91ec	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
80defea7-12b2-4767-a9e9-7d937c0cfbbb	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
89221f96-1806-41bc-85cf-c64bdd3049c6	f29af015-7833-4f9a-ac57-6fbef5bf91ec	168b1296-de6a-4f9e-a3b9-617b83863736	module	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
9363ec6f-fd0a-4159-bb81-d8021a59af2d	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	1	0
973fc762-238a-4afc-a768-2834e6870bf4	f29af015-7833-4f9a-ac57-6fbef5bf91ec	4e57fd71-b53e-43c0-862e-5698e09c0922	module	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
9dbe720a-4193-4254-90fe-f8c399e02748	f29af015-7833-4f9a-ac57-6fbef5bf91ec	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	1	1
9f1ff226-3a51-4041-9f9c-f99d93363c27	f29af015-7833-4f9a-ac57-6fbef5bf91ec	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
a159186c-8e95-43c8-958f-c832eae63779	f29af015-7833-4f9a-ac57-6fbef5bf91ec	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	1	0
a8e1d22d-7dd4-417b-acbe-dd74e44d9009	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0002-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
af27c416-74c8-45d7-998e-cc5759ca8fc5	f29af015-7833-4f9a-ac57-6fbef5bf91ec	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	1	1
be758370-c219-4f04-ac8d-cf3caad20475	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
c073dbde-f11f-4e19-b330-93e6a3740565	f29af015-7833-4f9a-ac57-6fbef5bf91ec	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
c0ba9c89-217b-4096-871a-fec5f3bbf8a0	f29af015-7833-4f9a-ac57-6fbef5bf91ec	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
c712d7e3-f15e-43d2-8feb-37ee1755c123	f29af015-7833-4f9a-ac57-6fbef5bf91ec	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
c7df4f06-9d8a-4165-a627-911a8c5ee5ed	f29af015-7833-4f9a-ac57-6fbef5bf91ec	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	1	1
d217e4e6-3888-4ee0-ab1c-ed1348aa9185	f29af015-7833-4f9a-ac57-6fbef5bf91ec	682f26ec-e31d-43a0-82de-e915bab54b59	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
d36e66b2-45a3-468b-b8f6-352991569fe7	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
e308dbb6-aa71-4ce7-9cc9-266fa1f59901	f29af015-7833-4f9a-ac57-6fbef5bf91ec	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
e3370211-eab7-4795-801c-1b6bc72976b4	f29af015-7833-4f9a-ac57-6fbef5bf91ec	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
e34e75fa-16b5-496a-8de5-ea63d93bb2e5	f29af015-7833-4f9a-ac57-6fbef5bf91ec	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	1	1
e49ca256-b74e-4b07-beab-c3adece20c65	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0002-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
ecf730a1-c650-47dc-8a7b-e354f928e195	f29af015-7833-4f9a-ac57-6fbef5bf91ec	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
f4be9d8b-bbdf-464b-9340-a6e2399b7804	f29af015-7833-4f9a-ac57-6fbef5bf91ec	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
f7d51aac-a5be-430b-9971-1aa8a80a02a9	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
f8be4592-f570-49d4-8f78-6925f9ae9506	f29af015-7833-4f9a-ac57-6fbef5bf91ec	c1a11111-0002-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
fc8e0025-3470-4210-a884-f80dfd810bae	f29af015-7833-4f9a-ac57-6fbef5bf91ec	715f79ce-51ea-46d3-b95d-8318840f90a6	module	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 10:50:47.243181+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	0
0257c9bf-ea59-4ed6-a6f0-e1314557b8dc	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	d67426d3-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
037412c4-364b-489a-9a37-8cf6e1cbead4	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	e1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
03f2b5c8-8278-400f-8995-7f4f0fa08c10	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
0535e6f4-a1f4-4caa-ba12-81e27653e9e9	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
074cc731-a7c1-4c89-bd9b-0ca44213c39e	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
15001003-ad5c-42df-a0af-4ee9c8c028a1	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
17012aa6-b337-4609-bdec-178a3561da6f	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
20c68b61-f9e8-48f7-a9d4-27e1c9b96dad	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
24f3835f-ad2f-4ca8-a8f6-e3d26879da15	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
29eab4d8-c5dd-49d2-8fdc-8bc6328ceb36	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
31dd1d70-9090-4434-81f6-51ad8d92ff82	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
3316af7a-d01d-4e54-a9ee-2e9bf81a61c5	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
4341eb89-290f-4103-b3a4-ff87a5b2d813	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
462f3634-ddf1-4268-bbac-7c14a4b678d5	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
49871218-2a5d-477f-a7e6-6e50afb35ceb	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
4b751d17-1ef2-47a9-9bde-3b4f29cd93b1	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
4bb26336-ee70-4b67-b5d7-830a93891380	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
4f1e9821-1643-4ff8-b8b2-25f714e78a47	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
50079061-86c9-411e-b9bc-5729020128cb	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
522c7f63-407c-4caf-bc18-02cf08f9a7ad	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
531b14e6-e9e4-4478-9106-500c8dd16d31	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-10-24 22:20:27.272824+05:30	2026-11-12 11:02:28.025217+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
547a79f6-677c-4b29-ab85-06813ede083c	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
68e89be2-f2eb-459e-a67b-668f50398c63	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	e1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
68faf1a5-bf56-46ca-bcfb-c635518aacca	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
7a9fd10c-e30c-4b70-9019-4d8d60f10e93	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
7c37cc4e-b175-4a79-91e8-13c268c409c5	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
7e5d21ab-f931-43ad-a317-524a21711e04	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
0190304f-6327-47a2-a97b-d056598780e3	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
07002c1d-df09-4f7c-8a93-aba1bacc5620	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
0ed82676-8ab3-4392-8fb0-1f1f44f8836a	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
8047e8e2-f6ca-42e1-9afb-a1380606df09	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	e1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
88d21d50-abc6-4702-ade9-43c0574478fb	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
8dab12a2-e62a-4692-95b6-5316d51cd7e7	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
91d3a606-1d0f-4edf-8aa8-658bac43a33b	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0002-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
95b7a656-e678-4f23-bd1c-5458978a8119	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
98f62549-6d15-4b08-9549-a33d5377c58c	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
9aaec5df-bac1-460a-98c5-c97ddf32f730	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	e1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
9c713099-f3ad-4905-bff5-1b9bfc30558f	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0002-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
a9b49649-e46e-48c4-a56e-978b298457c8	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
bad88ac2-565b-4033-8131-978144a366b2	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
c4330038-d8a8-4bc3-b7da-35e51a7dc3ea	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	d67426d3-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
c50718ad-1326-46e1-b6dc-44d17b6b481e	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
d015ba18-c7dd-4566-b221-84fc8fe5ba50	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
d1497a56-21e0-4912-bc3d-f000c3fb6529	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
d1a926ea-62d4-41f1-b856-ca78237d8f47	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0002-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
d9e01a42-959c-42ca-9b4b-8bbe00b89191	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
de51974d-b3b4-434e-9f5f-7bbd904e88e8	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
e2f02d40-ab38-4a86-a0f6-260376df9206	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	e1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
e3861076-507c-49d2-b4dd-3b9d2361e02d	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
e3f8fd48-c73b-41a5-b9c2-652f32ddb5ca	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	e1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
eb369d76-9387-44aa-9349-2fa2b90b7f45	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
f009aa13-5eb1-4b71-a862-906a8f46d58a	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-10-24 22:20:27.272824+05:30	2026-11-12 11:02:28.025217+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
f605e037-33d6-4f41-ba87-ae9a783855ce	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
f632bae1-674e-48d7-ac8a-abde2998d115	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
f6912c8d-d6e9-481d-81f2-cfccc66d2d0c	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
fb8eae55-8fc7-4e0d-bae2-8bbc0c61126d	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
ff2b10ad-0adb-4cfd-ac4a-1b0c5510f88e	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	c1a11111-0002-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 11:02:28.025217+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
1e4b7bd4-7c8d-419e-a01d-f850a3ba3d6f	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
2168d0e2-4d12-48c1-9c5f-2f1f529f3281	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0001-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
25c45f0c-983a-482e-842a-ff3194bbf9f8	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
2cfd082e-4c95-494e-befe-821440b40798	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
2d6b6df5-3fea-45d3-aca1-9571627d7e09	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
302af49e-43d4-4687-9493-fa59306a3519	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
3fa63c4f-6e73-4787-85d3-680fa96b06ee	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
476bdefe-5365-4568-a7c1-343b38ed6ba1	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
49f1db1e-d441-475b-98ac-be7f794ff837	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
4c499243-9d9c-4eeb-ab46-85377b7a2a21	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
50cdbad8-47a3-4581-a4bc-5eb1536785bf	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
573bfa8f-883a-4cf6-88d7-709329b364b2	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
623b9f58-25c7-4e59-b82e-c2a1a7ae811a	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
7342867c-fd82-4cda-bc3b-134ac5363f60	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
e3ad5cfe-2ace-443d-8109-844cb6077023	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
e77c0179-08bf-4cf3-91ff-304a36f57616	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
ea11623e-7db0-4003-b198-0eb2941cb9eb	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
f051d820-a990-4858-9ff0-9266cf00b303	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
f1198b11-3e31-4926-ad37-094a772c1ce8	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
f49b7886-acc4-4fb7-bd5c-2cdd8d193c51	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
f5e8dbe9-515c-47c1-8d08-f20cb08e9ee6	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
f6571a63-0fbc-45c8-85aa-a13a3e3a408e	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
f8bd2e0b-0fb7-474f-bb29-1b6291a2c917	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
ffdf38d2-47a4-40fc-9a04-78b3a39fb9b7	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0002-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
10ae9942-fca7-4b1b-8ab3-6064b8118713	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
185b713a-1ad7-4907-adc2-4e709c9758b8	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-12 15:12:00.842113+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
04606a09-e947-4dfb-99d8-014cd5b19f2b	29ad5710-1621-4c24-ac75-dedfc168ba1a	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
08c0ec4a-12f5-46a1-9a25-c61acb5248ed	29ad5710-1621-4c24-ac75-dedfc168ba1a	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
0c2a7cdb-2293-4a07-b2e9-276d14669c2d	29ad5710-1621-4c24-ac75-dedfc168ba1a	0d274292-537d-4c41-8e23-3df901304d71	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
12b8cce2-66b5-440b-b130-a496eed8603b	29ad5710-1621-4c24-ac75-dedfc168ba1a	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
1583f4f3-fb6a-4798-acc2-7d1cf58201c2	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
1691b36c-1c9e-4edc-9988-3abd7581032b	29ad5710-1621-4c24-ac75-dedfc168ba1a	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
215dd8dc-db44-41ca-96f6-579e63278ab6	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0002-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
2724ba4e-7851-492e-b023-b3ec213d1d58	29ad5710-1621-4c24-ac75-dedfc168ba1a	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
29088a1a-a345-41bd-bc7e-8f5ac396b0d2	29ad5710-1621-4c24-ac75-dedfc168ba1a	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
2c809ed2-540b-4e0b-9aaf-ed49fb270b2f	29ad5710-1621-4c24-ac75-dedfc168ba1a	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
302d3605-11bd-467e-a1af-54f69a135000	29ad5710-1621-4c24-ac75-dedfc168ba1a	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
322eca0c-1e99-441d-9f75-7a43e5f3a68c	29ad5710-1621-4c24-ac75-dedfc168ba1a	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
342f6f53-051e-4fda-97e2-1486224208d4	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
388cfd29-9b5f-40d4-9b14-783a6da2f300	29ad5710-1621-4c24-ac75-dedfc168ba1a	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
422d0ba5-ed0f-4ccf-9d06-1938185c9f8c	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0001-4000-8000-000000000004	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
44504cf8-88b7-4db9-a268-a55c8e076f73	29ad5710-1621-4c24-ac75-dedfc168ba1a	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
488c50d6-ba34-4563-a168-ff3bcb2e7ff6	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
49e957b5-93de-4f34-813a-efc8328688b2	29ad5710-1621-4c24-ac75-dedfc168ba1a	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
505344dd-e845-4321-a8e5-a919f7813fbc	29ad5710-1621-4c24-ac75-dedfc168ba1a	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
52c5c580-7231-4b8a-abbc-bf3ff443ad1c	29ad5710-1621-4c24-ac75-dedfc168ba1a	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
560cdcc1-76ab-479c-be57-66a12dde878f	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
59b560ea-1800-402c-8dd9-5ca5d5ede830	29ad5710-1621-4c24-ac75-dedfc168ba1a	d67426d3-0001-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
59c10b40-3a08-4c94-86ed-eead9bf040df	29ad5710-1621-4c24-ac75-dedfc168ba1a	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
5f2b39eb-c55b-43d9-836d-a03b96f109db	29ad5710-1621-4c24-ac75-dedfc168ba1a	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
652bfc6d-cd16-4d4d-9a77-b4014717dcad	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
6a5fac41-97f2-4636-a71c-68c8713a0cde	29ad5710-1621-4c24-ac75-dedfc168ba1a	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
6a9137f8-2c3a-47fe-b24e-bd3efd32141c	29ad5710-1621-4c24-ac75-dedfc168ba1a	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
6b377c90-5c7e-48ae-a3c0-ee1f82eb869a	29ad5710-1621-4c24-ac75-dedfc168ba1a	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
6bc0b540-d4d4-4127-99f6-11f70f710a13	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
6e237f49-6e25-4e3a-bf14-bb8d8163b770	29ad5710-1621-4c24-ac75-dedfc168ba1a	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
76ea7fa2-5acc-411a-9c74-3f41ad52e58e	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
79f3bb95-7714-467c-860f-e24bf06ad00e	29ad5710-1621-4c24-ac75-dedfc168ba1a	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
79f9ffb0-3f95-4f9a-8ab9-ae845685c760	29ad5710-1621-4c24-ac75-dedfc168ba1a	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
87f333dc-ace4-4275-86e4-6703d8daa0da	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
8a738527-fd54-4f27-9d47-c337c24ece34	29ad5710-1621-4c24-ac75-dedfc168ba1a	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
8e5a75b5-e915-4986-b95f-7d3882ec3e21	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
95a1daa4-36b2-495e-9e77-b648f8a31306	29ad5710-1621-4c24-ac75-dedfc168ba1a	682f26ec-e31d-43a0-82de-e915bab54b59	widget	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
9e12332c-9b85-47b7-91e4-b365b53bdcd5	29ad5710-1621-4c24-ac75-dedfc168ba1a	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
a0248766-c03f-4776-8bdc-022c8066b3b5	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0002-4000-8000-000000000001	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
a06554ee-ff75-4ace-a5c3-232dc6f45516	29ad5710-1621-4c24-ac75-dedfc168ba1a	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
a36ab201-0d1f-4edf-a6df-0a217f7b61e4	29ad5710-1621-4c24-ac75-dedfc168ba1a	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
a425fd92-59bd-40a9-970c-a7923e13231b	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
c8d83379-bc10-4ee5-8973-82695e0d0636	29ad5710-1621-4c24-ac75-dedfc168ba1a	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
cf1a44ea-9714-401e-9a53-861cb99dde01	29ad5710-1621-4c24-ac75-dedfc168ba1a	d67426d3-0001-4000-8000-000000000003	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
cfb92dc4-2630-4f0e-8bbd-2cf5e2c5ba41	29ad5710-1621-4c24-ac75-dedfc168ba1a	d67426d3-0001-4000-8000-000000000002	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
d86e2b11-aa8e-47da-838c-7a997c7cb5f1	29ad5710-1621-4c24-ac75-dedfc168ba1a	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
d8a17d49-2c98-4a84-b226-73f534b33cc3	29ad5710-1621-4c24-ac75-dedfc168ba1a	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
e6c50e60-0117-4a47-8e14-7df357c13b91	29ad5710-1621-4c24-ac75-dedfc168ba1a	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
e854148f-6dd5-4425-aff3-fc8577f7ff77	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
ec8cd9f7-a7fe-40df-80b9-9e6290771d36	29ad5710-1621-4c24-ac75-dedfc168ba1a	715f79ce-51ea-46d3-b95d-8318840f90a6	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
f0272422-f6eb-40de-b9fd-7a4244d20838	29ad5710-1621-4c24-ac75-dedfc168ba1a	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
f505ff93-ae61-4fe8-90e5-50a2ef69c3fd	29ad5710-1621-4c24-ac75-dedfc168ba1a	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
f7180f3d-d25d-4ba2-b7aa-6f4f3eee43d1	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0001-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
f9def489-2e6a-4b4e-94c8-0f13080ff669	29ad5710-1621-4c24-ac75-dedfc168ba1a	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-15 22:29:04.670257+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
225ca5de-a807-435c-ad5e-2020ad5180ef	914d8500-03b6-4a43-a250-244effca1cf1	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-16 20:48:04.027283+05:30	\N	\N	\N	0	0
4644cf06-ab12-4e47-9ba7-66ba69763d86	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0002-4000-8000-000000000005	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-16 20:48:04.027283+05:30	\N	\N	\N	1	0
c8aa4d60-d513-4f2e-afa0-2ed7f74386c8	914d8500-03b6-4a43-a250-244effca1cf1	c1a11111-0002-4000-8000-000000000006	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-16 20:48:04.027283+05:30	\N	\N	\N	1	0
066fb8cb-cb0c-4ee8-8718-09b1ed9e4ddb	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	d67426d3-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
07ee7c82-0cf3-4ee5-8545-24c22790dc32	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c04c546e-0f2c-448d-b634-5d517843d365	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
11139433-9338-4b5c-9f5e-838d2cb5dd80	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	e1a11111-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
1260c8be-fb8f-4f03-8e56-5cbdf163db21	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	4e57fd71-b53e-43c0-862e-5698e09c0922	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
17c59bae-2eea-405c-a0a1-4033a94a3987	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	a7bd6c40-4e96-4abb-be93-4ed4e4211978	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
18ac3ed3-b447-4fc9-bf16-a267e6b7a077	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0002-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
19b15501-fd64-4550-95ce-6a72076b5221	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	e1a11111-0001-4000-8000-000000000006	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
1b037efa-33e4-4ab0-a9f0-c72920f359c7	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	d67426d3-05df-4608-b8cf-c0ecfe698dc3	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
26a46363-ca7a-4516-b224-afed238d4e1b	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0002-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
27673c1f-de3a-4e75-be51-3e3735caffe5	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0003-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
278ac013-dadc-493c-905b-7ed3bfaa3b2b	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
2911c545-9675-499c-bfd0-e706f8670995	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	9854b7f3-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
2a56e40a-d48e-4b1e-937a-95ad972bb843	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	e1a11111-0001-4000-8000-000000000005	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
2fd24893-c8f7-4a7c-9e3a-7bc243f20bfe	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0002-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
34a3320e-f0d2-4120-8188-e9ecfabc735f	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0001-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
3e1af87e-3530-42d7-9d37-7b78cc25f0b2	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	9854b7f3-8e7e-4ecb-864f-f2533ff295f9	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
3e28dd7e-b80f-47a2-ac23-ed6e68dd4b17	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2b83bafc-1c64-449c-a644-e8e19e0c0a48	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
410383dc-337e-42f6-b277-3248f287fdf8	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0001-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
46e259fd-6d43-4f65-8237-208b4ffe1740	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0003-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
4a7e4fb3-bb24-4785-94b3-88c533b99d0c	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	e1a11111-0001-4000-8000-000000000004	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
52a56024-6bda-483d-8176-dc8de50bc656	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	682f26ec-e31d-43a0-82de-e915bab54b59	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
5384da95-ed87-4f7c-a121-844a07a73a46	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0002-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
53d3f28a-e02f-4e60-95ff-0b15def97e3f	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	552f9f86-4eb0-473a-8e39-9863cfefcea4	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
5d65572c-b7c8-43e0-a559-277dd65ed002	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	526e2d0d-47d4-4814-9e5a-8f7c53af1432	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
6c3769f3-bd64-40d0-b241-02a4fa245936	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0001-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
6d2f4308-c901-4d94-986b-a0f024a455ff	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0001-4000-8000-000000000003	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
70df90d0-4917-41b3-812d-dfd2ffff67f2	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	39dbd425-643b-47e9-9936-6bbae9ef5ef5	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
724a0948-3a0d-416a-bd19-85fa7c9dd265	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	6055ce3c-b466-4354-ba9a-b4c309111e9d	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
72f8c591-3c66-4de5-96dc-f9f33fe2f187	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	3c5780f7-e23d-48bd-b73e-51019dfbc2bd	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
7766d95c-6a0f-4485-aa62-737e527d84e1	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	e1a11111-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
8ab8ed82-0041-4783-bc4c-74e2677340c7	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0001-4000-8000-000000000005	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
8c5afbe7-7f9a-4bd5-9a45-011150726427	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	471bc977-be2e-449d-91e7-5c11cb9c4ec0	module	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
8e9ee8ae-cc0e-47bf-ad96-4d8acbe94c87	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	d67426d3-0001-4000-8000-000000000001	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
999fc433-3e98-4f1a-96a7-f2833e6e92cd	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	715f79ce-51ea-46d3-b95d-8318840f90a6	module	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
9db8c91b-0314-4604-b7df-e7ab3823a2ee	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	d6dea306-2e8f-41a0-89c8-857cb96f5558	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
a4887288-3ca0-4215-aec1-e5852948d6e8	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	0d274292-537d-4c41-8e23-3df901304d71	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
a8353326-832d-41d1-8844-bb958478298a	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0001-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
adb04a67-a271-457f-8e4d-1f12588de3dc	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
bd47f651-88a3-4743-9060-7ce820e090da	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	b8f7c125-0e5b-4e3d-98e3-542638fa0b21	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
bf93be62-3525-4a22-a226-683b58a9e524	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	e8f7c125-0e5b-4e3d-98e3-542638fa0b23	submodule	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
c5225892-0220-4d6e-bf9a-d1a780a15dac	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	d67426d3-0001-4000-8000-000000000003	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
d2c1e978-c232-4d22-b8d8-e46e84f1d112	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	896c2166-8f1f-4ab8-873c-755ab3d051fb	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
db42523a-16f4-40cd-9724-5661373860b6	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	e1a11111-0001-4000-8000-000000000002	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
dffe39d1-c5f6-469e-9280-81db3e943c82	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0003-4000-8000-000000000004	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
e2b6cc0f-6f32-4b92-b8b2-811df245c7da	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	5a049953-8170-4ef4-a59e-43dc19e12de5	module	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
e33ceec3-318d-4540-a671-9c94c1356fea	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	tab	1	1	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	1
e3ad8038-161f-4b12-8186-17604eaf7cb4	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	a7e6b014-9f4a-4d2c-87d2-431527ef9a10	submodule	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
e9e09ade-78a8-4b12-b854-0a6958f807bf	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	9c916f1a-72e0-4d52-bec1-6d684e990c65	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
ead1c4f7-cf0d-4d73-903a-7ff2779d107d	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	168b1296-de6a-4f9e-a3b9-617b83863736	module	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
f0442095-0a95-4d34-ad15-d856670c47eb	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	tab	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
f3a66530-cc52-403a-9e07-35e8ce9632aa	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0002-4000-8000-000000000002	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
fa2bc8b9-2e3f-4c12-95dc-c158a2aa16ce	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	7e3f4519-8acd-489f-a70a-ac39092fbd40	widget	0	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	0
fbba04d1-bacd-4d9e-ae65-76145a69f6bb	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0002-4000-8000-000000000006	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
ff36bec4-f324-4795-bf6b-f5e6ede7bfde	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	c1a11111-0003-4000-8000-000000000001	tab	1	0	2026-11-12 10:46:05.669876+05:30	2026-11-17 17:21:59.488695+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	1	0
\.


--
-- Data for Name: tbl_roles; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.tbl_roles ("Id", "DisplayName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") FROM stdin;
a0000000-0000-0000-0000-000000000001	Admin	2026-09-25 10:11:26.317908+05:30	2026-09-25 10:41:29.711189+05:30	\N	\N	\N	Admin	Super-admin — full access to every module, submodule and action.	t	t
914d8500-03b6-4a43-a250-244effca1cf1	Sales - Manager	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	Sales Manager	Customer onboarding, client management, proposal drafting, pipeline.	t	t
64e2ea37-cbd7-4127-b65b-3b003235981a	PM - Team Member	2026-10-21 15:07:57.51344+05:30	\N	\N	\N	\N	PM - Team Member	Project management team member.	t	t
92aa9169-28d9-4754-a570-553b067642ed	Testing - Team Member	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	Testing-Team Member	Test execution, defect logging, task status updates, own timesheets.	t	t
c787fe3b-4b33-40ee-8794-c1148202f81a	Testing - HOD	2026-09-24 17:43:06.784762+05:30	2026-10-21 17:04:24.175956+05:30	\N	\N	\N	Testing HOD	Complete oversight of Testing department, health escalations, approvals.	t	t
1a62b1f8-1810-464d-a67b-168d7e419827	SOC - Team Member	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	SOC-Team Member	SIEM monitoring, alert analysis, shift logs, own timesheets.	t	t
29ad5710-1621-4c24-ac75-dedfc168ba1a	Testing - Manager	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	Testing-Manager	QA project tasks, test deliverables, defect tracking, QA timesheets.	t	t
3d068c2f-d0a1-4045-bad9-0f3a43efec4f	SOC - HOD	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	SOC-HOD	Complete oversight of SOC/Operations, 24/7 monitoring governance.	t	t
64c49f37-a38a-46a6-9622-7427f1501658	Consulting - HOD	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	Consulting-HOD	Complete oversight of Consulting department, GRC engagements.	t	t
768a11f9-ded7-4f6f-ba86-073e279255d9	Consulting - Team member	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	Consulting-Team member	Audit checklists, evidence collection, task updates, own timesheets.	t	t
7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	Sales - Team Member	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	Sales team member	Proposal drafting, pipeline viewing, sales reports.	t	t
a3793f87-7f3c-41a1-a675-236fc1b710ab	Testing - Team Leader	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	Testing-Team Leader	Test run execution, defect triage, test task assignment, timesheet review.	t	t
aba61e5b-422a-4461-b9da-8dba8f6d3f85	SOC - Team Leader	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	SOC-Team Leader	Shift oversight, alert escalation, task assignments, timesheet review.	t	t
b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	SOC - Senior Manager	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	SOC-Senior Manager	Operations delivery oversight, client SLA tracking, incident reviews.	t	t
f29af015-7833-4f9a-ac57-6fbef5bf91ec	Intern	2026-09-24 17:43:06.784762+05:30	\N	\N	\N	\N	Intern	Read-only training access to assigned tasks and document repository.	t	t
4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089	Consulting - Senior Manager	2026-09-24 17:43:06.784762+05:30	2026-10-21 17:01:47.636663+05:30	\N	\N	\N	Consulting-Senior Manager	Delivery oversight across consulting & audit projects.	t	t
2acf8b94-0756-4db8-bb6f-8372ac04a2d1	PMO (Project Management Office)	2026-09-24 17:43:06.784762+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	PMO	Global governance, WBS allocation, timesheet monitoring, approvals.	t	t
62a927b7-9fd8-461a-b64e-1aa441eeba4d	CEO	2026-09-24 17:43:06.784762+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	CEO	Global executive visibility, business analytics, all approvals.	t	t
66e48815-4d4f-41d0-9c5f-26a7b7ba296c	CTO	2026-09-24 17:43:06.784762+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	CTO	Technical architecture, R&D governance, engineering oversight.	t	t
111cc3cd-6d35-43ce-be91-dde90d3d4015	SOC - Manager	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	SOC-Manager	Incident management, shift scheduling, operations timesheets.	t	t
a5023c9e-367f-41e1-ba02-bdb2929edc89	EM (Engagement Manager)	2026-08-07 13:19:59.669429+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	EngagementManager	Customer relationship, client project overview, health & escalations.	t	t
a5bfe265-981a-4723-b7bb-6ddc389db7f0	COO	2026-09-24 17:43:06.784762+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	COO	Operational oversight across all departments and projects.	t	t
b552183f-2695-41f9-860e-16d5fe94c4aa	IT Admin	2026-09-24 17:43:06.784762+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	IT Admin	IT infrastructure, corporate email domains, device & user setup.	t	t
bb568e26-548b-4ca5-9221-fefb9c9143b3	HR	2026-09-24 17:43:06.784762+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	HR	Employee directory, onboarding/offboarding, skills, KPI/rating tabs.	t	t
701aaa2c-a899-4def-bf5f-e17511874409	Consulting - Team Leader	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	Consulting-Team Leader	Senior audit execution, audit task assignment, timesheet review.	t	t
cd2a32ed-32fc-47bc-88a9-e6fc48863869	Accounts	2026-08-07 13:19:59.669429+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Accounts	Invoicing schedule, milestone payments, PO tracking, financial reports.	t	t
e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	Consulting - Manager	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	Consulting-Manager	GRC audit projects, client deliverables, audit timesheet approvals.	t	t
efc1df20-ca04-44a6-87b2-7cae1ff50a88	Testing - Senior Manager	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	Testing Senior Manager	Delivery oversight across testing projects, QA resource management.	t	t
f5c742d1-e0cc-4bf8-b860-a673ac407393	R&D - Team member	2026-09-24 17:43:06.784762+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N	R&D - Team member	Python/Tool development, sprint tasks, code repository, own timesheets.	t	t
\.


--
-- Data for Name: tbl_users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.tbl_users ("Id", "Email", "PasswordHash", "Name", "EmployeeId", "Department", "SubDepartment", "Avatar", "Designation", "IsActive", "MustChangePassword", "RoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "FailedLoginAttempts", "LastLoginAtUtc", "LockedUntilUtc", "PasswordChangedAtUtc", "AuthProvider", "MicrosoftOid") FROM stdin;
8af256a2-4662-411e-b46a-f2ad8a27565b	admin@talakunchi.com	$2a$12$/zWdfjp1UDRtZnibgKunCu.UiXRuSFYEay7myO6kIALw0mq5hgjoK	Admin User	TK-0004	Functional - IT Administration	\N	\N	IT Admin	t	t	a0000000-0000-0000-0000-000000000001	2026-10-16 15:36:08.96608+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	0	\N	\N	\N	Local	\N
78470591-8a64-40a5-8bcd-f766cb7ae3ec	harsh.wardhan.tk-0016@talakunchi.com	$2a$12$Q1WXE.vXpkhmPqmIk.3xdOzAGJeWTy98V4E1H3n5KjTa7AFePazl.	Harsh Wardhan	TK-0016	Functional - IT Administration	\N	\N	Desktop Support Engineer - I	t	t	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-16 15:36:09.241746+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	0	\N	\N	\N	Local	\N
a0b10742-1874-4390-a73d-122dd9db2859	pallavi.sawant.tk-0017@talakunchi.com	$2a$12$ESBGepF4cgho35rHk6ymUeVvWmOkUHHwf/rGQr8fE2FogdmbaMuLy	Pallavi Sawant	TK-0017	Functional - IT Administration	\N	\N	Desktop Support Engineer - II	t	t	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-16 15:36:09.503287+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	0	\N	\N	\N	Local	\N
c9d183e1-5770-494a-a061-137a51001f53	harsh.pandey.tk-0018@talakunchi.com	$2a$12$WedigdLQFiPPL8dugTIwMed2zHP3gWMBQjnd1b6SEwmgi/ev2WgZe	Harsh Pandey	TK-0018	Functional - IT Administration	\N	\N	IT Admin	t	t	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-16 15:36:09.760432+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	0	\N	\N	\N	Local	\N
08eecbb4-31fe-4ad4-8c0b-50e7d5bb0d4d	dev.reddy.tk-0003@talakunchi.com	\N	Dev Reddy	TK-0003	Core	\N	\N	Director and Chief Technology Officer	t	f	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	2026-11-12 12:56:12.327506+05:30	2026-11-12 12:56:21.251937+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	\N	\N	\N	Local	\N
45aee902-8221-4d8d-b6d9-7161658355c4	reyansh.chopra.tk-0027@talakunchi.com	\N	Reyansh Chopra	TK-0027	Functional - Sales	\N	\N	Associate Customer Success Representative - I	t	f	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-11-12 13:14:30.477835+05:30	2026-11-12 13:14:40.845792+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	\N	\N	\N	Local	\N
1b737ed6-2ea2-4583-aba8-cbba9f63f3a0	kunal.iyer.tk-0059@talakunchi.com	\N	Kunal Iyer	TK-0059	Services - Testing	\N	\N	Associate AI Engineer - Contractual	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-11-12 13:14:20.535575+05:30	2026-11-12 13:15:02.435464+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	0	\N	\N	\N	Local	\N
b5e95cda-2a98-4526-9b3c-b3075fb4ffe3	aarav.patel.tk-0093@talakunchi.com	\N	Aarav Patel	TK-0093	Services - Testing	\N	\N	Red Team Practitioner - III	t	f	92aa9169-28d9-4754-a570-553b067642ed	2026-11-12 15:14:23.199109+05:30	2026-11-12 15:14:29.319043+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	0	\N	\N	\N	Local	\N
92172235-83bb-41a1-a96e-60054a506818	vihaan.pillai.tk-0001@talakunchi.com	\N	Vihaan Pillai	TK-0001	Functional - Project Management	\N	\N	Associate PMO - I	t	f	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	2026-11-12 12:47:07.682368+05:30	2026-11-18 10:02:17.792303+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	0	\N	\N	\N	Local	\N
ede658f4-1925-4db4-a5ed-62aba574ed3c	krishna.saxena.tk-0040@talakunchi.com	\N	Krishna Saxena	TK-0040	Services - Consulting	\N	\N	GRC Auditor - IV	t	f	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	2026-11-12 12:56:32.491035+05:30	2026-11-18 10:02:17.792303+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	0	\N	\N	\N	Local	\N
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
\.


--
-- Data for Name: tbl_clients; Type: TABLE DATA; Schema: customer; Owner: -
--

COPY customer.tbl_clients ("Id", "Name", "Industry", "Logo", "ContactEmail", "ClientType", "Status", "EngagementManager", "ContactName", "ContactPhone", "ContactDesignation", "ContactType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BusinessType", "City", "Country", "KycDocumentName", "Notes", "EngagementManagerId", "IndustryId", "CityId", "CountryId", "CustomerSince", "SalesManager", "SalesManagerId", "KycDocumentPath", "BillingMedium", "GroupSpocName", "GroupSpocContact", "ClientCode", "CreatedByName", "GroupSpocPhoneCode") FROM stdin;
\.


--
-- Data for Name: tbl_sub_ventures; Type: TABLE DATA; Schema: customer; Owner: -
--

COPY customer.tbl_sub_ventures ("Id", "ClientId", "Name", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Notes", "KycDocumentName", "KycDocumentPath", "SubVentureCode") FROM stdin;
\.


--
-- Data for Name: aggregatedcounter; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.aggregatedcounter (id, key, value, expireat) FROM stdin;
3	stats:deleted:2026-11-12	3	2026-12-12 20:17:27.982132+05:30
11	stats:succeeded:2026-11-15	1	2026-12-16 02:21:01.736437+05:30
5	stats:deleted:2026-11-15	21	2026-12-16 03:52:56.730431+05:30
21	stats:succeeded:2026-11-16	85	2026-12-16 20:19:12.896464+05:30
24	stats:deleted:2026-11-16	635	2026-12-16 21:00:28.079826+05:30
362	stats:deleted:2026-11-17-05	26	2026-11-18 10:59:21.095046+05:30
375	stats:succeeded:2026-11-17-09	1	2026-11-18 15:15:06.45403+05:30
385	stats:deleted:2026-11-17-10	12	2026-11-18 15:58:19.334255+05:30
379	stats:succeeded:2026-11-17-10	4	2026-11-18 16:15:10.211347+05:30
395	stats:succeeded:2026-11-17-11	5	2026-11-18 17:15:12.304056+05:30
401	stats:deleted:2026-11-17-11	4	2026-11-18 17:28:06.142466+05:30
363	stats:deleted:2026-11-17	45	2026-12-17 17:33:40.338919+05:30
2	stats:deleted	703	\N
418	stats:deleted:2026-11-17-12	3	2026-11-18 17:33:41.338919+05:30
415	stats:succeeded:2026-11-17-12	2	2026-11-18 17:45:13.528431+05:30
361	stats:succeeded:2026-11-17	14	2026-12-17 17:45:12.528431+05:30
422	stats:succeeded:2026-11-18	8	2026-12-18 10:15:02.885661+05:30
423	stats:succeeded:2026-11-18-04	8	2026-11-19 10:15:03.885661+05:30
13	stats:succeeded	108	\N
\.


--
-- Data for Name: counter; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.counter (id, key, value, expireat) FROM stdin;
\.


--
-- Data for Name: hash; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.hash (id, key, field, value, expireat, updatecount) FROM stdin;
1	recurring-job:timesheet-submission-reminders	Queue	default	\N	0
2	recurring-job:timesheet-submission-reminders	Cron	30 3 * * *	\N	0
3	recurring-job:timesheet-submission-reminders	TimeZoneId	UTC	\N	0
4	recurring-job:timesheet-submission-reminders	Job	{"t":"PMS.API.Modules.Timesheets.Jobs.TimesheetReminderJob, PMS.API","m":"ExecuteAsync","p":["System.Threading.CancellationToken, mscorlib"],"a":[null]}	\N	0
5	recurring-job:timesheet-submission-reminders	CreatedAt	1794775818916	\N	0
7	recurring-job:timesheet-submission-reminders	V	2	\N	0
8	recurring-job:employee-offboarding-reminders	Queue	default	\N	0
9	recurring-job:employee-offboarding-reminders	Cron	30 3 * * *	\N	0
10	recurring-job:employee-offboarding-reminders	TimeZoneId	UTC	\N	0
11	recurring-job:employee-offboarding-reminders	Job	{"t":"PMS.API.Modules.Resources.Jobs.EmployeeOffboardingReminderJob, PMS.API","m":"ExecuteAsync","p":["System.Threading.CancellationToken, mscorlib"],"a":[null]}	\N	0
12	recurring-job:employee-offboarding-reminders	CreatedAt	1794775819079	\N	0
14	recurring-job:employee-offboarding-reminders	V	2	\N	0
19	recurring-job:bucket-task-auto-pause	Queue	default	\N	0
20	recurring-job:bucket-task-auto-pause	Cron	*/15 * * * *	\N	0
21	recurring-job:bucket-task-auto-pause	TimeZoneId	UTC	\N	0
22	recurring-job:bucket-task-auto-pause	Job	{"t":"PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API","m":"ExecuteAsync","p":["System.Threading.CancellationToken, mscorlib"],"a":[null]}	\N	0
23	recurring-job:bucket-task-auto-pause	CreatedAt	1794907876503	\N	0
25	recurring-job:bucket-task-auto-pause	V	2	\N	0
26	recurring-job:team-availability-2hour-reminders	Queue	default	\N	0
27	recurring-job:team-availability-2hour-reminders	Cron	30 3,5,7,9,11 * * 1-5	\N	0
28	recurring-job:team-availability-2hour-reminders	TimeZoneId	UTC	\N	0
29	recurring-job:team-availability-2hour-reminders	Job	{"t":"PMS.API.Modules.MyTeam.Jobs.TeamAvailabilityTwoHourReminderJob, PMS.API","m":"ExecuteAsync","p":["System.Threading.CancellationToken, mscorlib"],"a":[null]}	\N	0
30	recurring-job:team-availability-2hour-reminders	CreatedAt	1794907876526	\N	0
32	recurring-job:team-availability-2hour-reminders	V	2	\N	0
33	recurring-job:team-availability-leadership-11am	Queue	default	\N	0
34	recurring-job:team-availability-leadership-11am	Cron	30 5 * * 1-5	\N	0
35	recurring-job:team-availability-leadership-11am	TimeZoneId	UTC	\N	0
36	recurring-job:team-availability-leadership-11am	Job	{"t":"PMS.API.Modules.MyTeam.Jobs.TeamAvailabilityLeadershipAlertJob, PMS.API","m":"ExecuteAsync","p":["System.Int32","System.Threading.CancellationToken, mscorlib"],"a":["11",null]}	\N	0
37	recurring-job:team-availability-leadership-11am	CreatedAt	1794907876534	\N	0
38	recurring-job:team-availability-leadership-11am	NextExecution	1794979800000	\N	0
39	recurring-job:team-availability-leadership-11am	V	2	\N	0
40	recurring-job:team-availability-leadership-12pm	Queue	default	\N	0
41	recurring-job:team-availability-leadership-12pm	Cron	30 6 * * 1-5	\N	0
42	recurring-job:team-availability-leadership-12pm	TimeZoneId	UTC	\N	0
43	recurring-job:team-availability-leadership-12pm	Job	{"t":"PMS.API.Modules.MyTeam.Jobs.TeamAvailabilityLeadershipAlertJob, PMS.API","m":"ExecuteAsync","p":["System.Int32","System.Threading.CancellationToken, mscorlib"],"a":["12",null]}	\N	0
44	recurring-job:team-availability-leadership-12pm	CreatedAt	1794907876544	\N	0
45	recurring-job:team-availability-leadership-12pm	NextExecution	1794983400000	\N	0
46	recurring-job:team-availability-leadership-12pm	V	2	\N	0
47	recurring-job:team-availability-spm-1pm	Queue	default	\N	0
48	recurring-job:team-availability-spm-1pm	Cron	30 7 * * 1-5	\N	0
49	recurring-job:team-availability-spm-1pm	TimeZoneId	UTC	\N	0
50	recurring-job:team-availability-spm-1pm	Job	{"t":"PMS.API.Modules.MyTeam.Jobs.TeamAvailabilitySpmAlertJob, PMS.API","m":"ExecuteAsync","p":["System.Threading.CancellationToken, mscorlib"],"a":[null]}	\N	0
51	recurring-job:team-availability-spm-1pm	CreatedAt	1794907876552	\N	0
52	recurring-job:team-availability-spm-1pm	NextExecution	1794987000000	\N	0
53	recurring-job:team-availability-spm-1pm	V	2	\N	0
54	recurring-job:team-availability-hod-eod	Queue	default	\N	0
55	recurring-job:team-availability-hod-eod	Cron	30 12 * * 1-5	\N	0
56	recurring-job:team-availability-hod-eod	TimeZoneId	UTC	\N	0
57	recurring-job:team-availability-hod-eod	Job	{"t":"PMS.API.Modules.MyTeam.Jobs.TeamAvailabilityHodEscalationJob, PMS.API","m":"ExecuteAsync","p":["System.Threading.CancellationToken, mscorlib"],"a":[null]}	\N	0
58	recurring-job:team-availability-hod-eod	CreatedAt	1794907876559	\N	0
60	recurring-job:team-availability-hod-eod	V	2	\N	0
65	recurring-job:team-availability-hod-eod	LastExecution	1794976338290	\N	0
59	recurring-job:team-availability-hod-eod	NextExecution	1795005000000	\N	0
15	recurring-job:timesheet-submission-reminders	LastExecution	1794976338290	\N	0
6	recurring-job:timesheet-submission-reminders	NextExecution	1795059000000	\N	0
17	recurring-job:employee-offboarding-reminders	LastExecution	1794976338290	\N	0
13	recurring-job:employee-offboarding-reminders	NextExecution	1795059000000	\N	0
18	recurring-job:employee-offboarding-reminders	LastJobId	1412	\N	0
63	recurring-job:team-availability-2hour-reminders	LastExecution	1794976338290	\N	0
31	recurring-job:team-availability-2hour-reminders	NextExecution	1794979800000	\N	0
64	recurring-job:team-availability-2hour-reminders	LastJobId	1413	\N	0
61	recurring-job:bucket-task-auto-pause	LastExecution	1794977103856	\N	0
66	recurring-job:team-availability-hod-eod	LastJobId	1409	\N	0
16	recurring-job:timesheet-submission-reminders	LastJobId	1411	\N	0
24	recurring-job:bucket-task-auto-pause	NextExecution	1794978000000	\N	0
62	recurring-job:bucket-task-auto-pause	LastJobId	1417	\N	0
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.job (id, stateid, statename, invocationdata, arguments, createdat, expireat, updatecount) FROM stdin;
1384	2342	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteReminderAsync", "Arguments": "[\\"\\\\\\"ee8957a1-b831-4821-8b4f-a7402f2fd65b\\\\\\"\\",\\"\\\\\\"e9147c96-bb54-411e-90f7-23189148cdfd\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"ee8957a1-b831-4821-8b4f-a7402f2fd65b\\"", "\\"e9147c96-bb54-411e-90f7-23189148cdfd\\""]	2026-11-17 15:54:21.620499+05:30	2026-11-18 15:54:22.103313+05:30	0
1397	2375	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 17:15:12.180209+05:30	2026-11-18 17:15:12.304056+05:30	0
1369	2318	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 15:15:05.779378+05:30	2026-11-18 15:15:06.45403+05:30	0
1370	2366	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteReminderAsync", "Arguments": "[\\"\\\\\\"a3be0722-30c4-410c-8bb4-6036b387aa26\\\\\\"\\",\\"\\\\\\"80cbdda4-96ae-40ca-8bf6-ff0924632cfc\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"a3be0722-30c4-410c-8bb4-6036b387aa26\\"", "\\"80cbdda4-96ae-40ca-8bf6-ff0924632cfc\\""]	2026-11-17 15:15:06.344925+05:30	2026-11-18 16:55:51.653483+05:30	0
1372	2321	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 15:30:06.572929+05:30	2026-11-18 15:30:06.609691+05:30	0
1373	2327	Deleted	{"Type": "PMS.API.Modules.ActionCentre.Services.IActionNotificationService, PMS.API", "Method": "ExecuteProjectAllocationReminderJobAsync", "Arguments": "[\\"\\\\\\"bc644875-ea88-464a-ab72-0c0272ce3355\\\\\\"\\",\\"\\\\\\"Electrolab(AmPm)_Mixed_01\\\\\\"\\",\\"\\\\\\"IN-2026-27/C004-01/P008\\\\\\"\\",\\"1\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.String\\",\\"System.String\\",\\"System.Int32\\"]"}	["\\"bc644875-ea88-464a-ab72-0c0272ce3355\\"", "\\"Electrolab(AmPm)_Mixed_01\\"", "\\"IN-2026-27/C004-01/P008\\"", "1"]	2026-11-17 15:39:25.796381+05:30	2026-11-18 15:51:36.353941+05:30	0
1375	2326	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 15:45:07.34436+05:30	2026-11-18 15:45:07.442609+05:30	0
1374	2328	Deleted	{"Type": "PMS.API.Modules.ActionCentre.Services.IActionNotificationService, PMS.API", "Method": "ExecuteSameDayHodCheckJobAsync", "Arguments": "[\\"\\\\\\"bc644875-ea88-464a-ab72-0c0272ce3355\\\\\\"\\",\\"\\\\\\"Electrolab(AmPm)_Mixed_01\\\\\\"\\",\\"\\\\\\"IN-2026-27/C004-01/P008\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.String\\",\\"System.String\\"]"}	["\\"bc644875-ea88-464a-ab72-0c0272ce3355\\"", "\\"Electrolab(AmPm)_Mixed_01\\"", "\\"IN-2026-27/C004-01/P008\\""]	2026-11-17 15:39:25.811942+05:30	2026-11-18 15:51:36.371991+05:30	0
1376	2331	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteBreachCheckAsync", "Arguments": "[\\"\\\\\\"fd3688d4-9bad-4c2a-a9bd-4620f10f0979\\\\\\"\\",\\"\\\\\\"76346705-47f7-432b-a180-496a3a35b254\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"fd3688d4-9bad-4c2a-a9bd-4620f10f0979\\"", "\\"76346705-47f7-432b-a180-496a3a35b254\\""]	2026-11-17 15:52:07.512654+05:30	2026-11-18 15:52:44.00581+05:30	0
1377	2332	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteEscalationAsync", "Arguments": "[\\"\\\\\\"fd3688d4-9bad-4c2a-a9bd-4620f10f0979\\\\\\"\\",\\"\\\\\\"b7503f49-b729-45c1-9fc9-c59c8cc8201e\\\\\\"\\",\\"1\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\",\\"System.Int32\\"]"}	["\\"fd3688d4-9bad-4c2a-a9bd-4620f10f0979\\"", "\\"b7503f49-b729-45c1-9fc9-c59c8cc8201e\\"", "1"]	2026-11-17 15:52:07.546484+05:30	2026-11-18 15:52:44.017523+05:30	0
1378	2339	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteBreachCheckAsync", "Arguments": "[\\"\\\\\\"69ccb25e-e6a8-4382-8ec7-7865f06ea03f\\\\\\"\\",\\"\\\\\\"b71dde5c-ed20-4341-ac0d-1db3cb117aa8\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"69ccb25e-e6a8-4382-8ec7-7865f06ea03f\\"", "\\"b71dde5c-ed20-4341-ac0d-1db3cb117aa8\\""]	2026-11-17 15:53:37.473024+05:30	2026-11-18 15:54:12.666152+05:30	0
1379	2340	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteEscalationAsync", "Arguments": "[\\"\\\\\\"69ccb25e-e6a8-4382-8ec7-7865f06ea03f\\\\\\"\\",\\"\\\\\\"048f89bf-9d60-4866-880c-adb6d732125b\\\\\\"\\",\\"1\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\",\\"System.Int32\\"]"}	["\\"69ccb25e-e6a8-4382-8ec7-7865f06ea03f\\"", "\\"048f89bf-9d60-4866-880c-adb6d732125b\\"", "1"]	2026-11-17 15:53:37.507016+05:30	2026-11-18 15:54:12.68625+05:30	0
1385	2344	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteReminderAsync", "Arguments": "[\\"\\\\\\"0744ed5b-235e-46de-8e65-f1288337f82e\\\\\\"\\",\\"\\\\\\"469f70ae-32de-47c6-b247-0e4ed305f5f5\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"0744ed5b-235e-46de-8e65-f1288337f82e\\"", "\\"469f70ae-32de-47c6-b247-0e4ed305f5f5\\""]	2026-11-17 15:54:24.689272+05:30	2026-11-18 15:54:28.004474+05:30	0
1386	2346	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteReminderAsync", "Arguments": "[\\"\\\\\\"84e6b021-87d3-4a41-9cf0-c5b6c14e3cd5\\\\\\"\\",\\"\\\\\\"542a99a1-70c0-4764-b19f-576a4076d15f\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"84e6b021-87d3-4a41-9cf0-c5b6c14e3cd5\\"", "\\"542a99a1-70c0-4764-b19f-576a4076d15f\\""]	2026-11-17 15:54:35.716314+05:30	2026-11-18 15:54:39.782821+05:30	0
1387	2348	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteReminderAsync", "Arguments": "[\\"\\\\\\"ff6eaa15-770e-47b1-af8c-a837c2effa81\\\\\\"\\",\\"\\\\\\"ded461dc-f8ca-4eac-97ca-53af2b1cbb88\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"ff6eaa15-770e-47b1-af8c-a837c2effa81\\"", "\\"ded461dc-f8ca-4eac-97ca-53af2b1cbb88\\""]	2026-11-17 15:54:44.434422+05:30	2026-11-18 15:54:49.154615+05:30	0
1398	2379	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteReminderAsync", "Arguments": "[\\"\\\\\\"d071f030-acb8-48d4-bf87-119f6ce1565f\\\\\\"\\",\\"\\\\\\"8fabfc95-0fc4-4f11-8915-869f0c45ac87\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"d071f030-acb8-48d4-bf87-119f6ce1565f\\"", "\\"8fabfc95-0fc4-4f11-8915-869f0c45ac87\\""]	2026-11-17 17:26:05.922983+05:30	2026-11-18 17:28:06.111992+05:30	0
1399	2380	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteBreachCheckAsync", "Arguments": "[\\"\\\\\\"d071f030-acb8-48d4-bf87-119f6ce1565f\\\\\\"\\",\\"\\\\\\"1968e52c-c3c8-4db5-9af2-9faab215347c\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"d071f030-acb8-48d4-bf87-119f6ce1565f\\"", "\\"1968e52c-c3c8-4db5-9af2-9faab215347c\\""]	2026-11-17 17:26:06.271592+05:30	2026-11-18 17:28:06.129716+05:30	0
1388	2350	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteReminderAsync", "Arguments": "[\\"\\\\\\"10a555e9-4446-41eb-8c22-9d68e9d7ee45\\\\\\"\\",\\"\\\\\\"9328e45d-30a5-4272-a77d-987475feae9c\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"10a555e9-4446-41eb-8c22-9d68e9d7ee45\\"", "\\"9328e45d-30a5-4272-a77d-987475feae9c\\""]	2026-11-17 15:54:54.606462+05:30	2026-11-18 15:57:57.617932+05:30	0
1400	2381	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteEscalationAsync", "Arguments": "[\\"\\\\\\"d071f030-acb8-48d4-bf87-119f6ce1565f\\\\\\"\\",\\"\\\\\\"e69e7da9-2f78-42fc-b276-cd28d5d3cfa1\\\\\\"\\",\\"1\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\",\\"System.Int32\\"]"}	["\\"d071f030-acb8-48d4-bf87-119f6ce1565f\\"", "\\"e69e7da9-2f78-42fc-b276-cd28d5d3cfa1\\"", "1"]	2026-11-17 17:26:06.398138+05:30	2026-11-18 17:28:06.142466+05:30	0
1389	2352	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteReminderAsync", "Arguments": "[\\"\\\\\\"94a620ca-29b4-4677-9fb3-049fbed34a47\\\\\\"\\",\\"\\\\\\"229b0365-dc27-4edb-8252-6377f6dcffb9\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"94a620ca-29b4-4677-9fb3-049fbed34a47\\"", "\\"229b0365-dc27-4edb-8252-6377f6dcffb9\\""]	2026-11-17 15:58:04.483713+05:30	2026-11-18 15:58:19.334255+05:30	0
1401	2384	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 17:30:12.787721+05:30	2026-11-18 17:30:12.924992+05:30	0
1391	2356	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 16:00:08.271552+05:30	2026-11-18 16:00:08.653385+05:30	0
1392	2359	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 16:15:09.076825+05:30	2026-11-18 16:15:10.211347+05:30	0
1408	2396	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 17:45:13.3899+05:30	2026-11-18 17:45:13.528431+05:30	0
1393	2362	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 16:30:10.310039+05:30	2026-11-18 16:30:10.404228+05:30	0
1394	2365	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 16:45:10.94584+05:30	2026-11-18 16:45:11.041251+05:30	0
1396	2371	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 17:00:11.561284+05:30	2026-11-18 17:00:11.905426+05:30	0
1395	2372	Succeeded	{"Type": "PMS.API.Modules.MyTeam.Jobs.TeamAvailabilityTwoHourReminderJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-17 17:00:11.548989+05:30	2026-11-18 17:00:12.917464+05:30	0
1405	2391	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteReminderAsync", "Arguments": "[\\"\\\\\\"4c1d7766-9eab-4edc-81ef-916805a8483b\\\\\\"\\",\\"\\\\\\"04493249-3787-43b1-8236-7478a7809e29\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"4c1d7766-9eab-4edc-81ef-916805a8483b\\"", "\\"04493249-3787-43b1-8236-7478a7809e29\\""]	2026-11-17 17:32:58.887416+05:30	2026-11-18 17:33:41.311696+05:30	0
1406	2392	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteBreachCheckAsync", "Arguments": "[\\"\\\\\\"4c1d7766-9eab-4edc-81ef-916805a8483b\\\\\\"\\",\\"\\\\\\"1a1dfcaa-999f-41c9-b67a-969528b785f0\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"4c1d7766-9eab-4edc-81ef-916805a8483b\\"", "\\"1a1dfcaa-999f-41c9-b67a-969528b785f0\\""]	2026-11-17 17:32:58.899498+05:30	2026-11-18 17:33:41.325964+05:30	0
1407	2393	Deleted	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteEscalationAsync", "Arguments": "[\\"\\\\\\"4c1d7766-9eab-4edc-81ef-916805a8483b\\\\\\"\\",\\"\\\\\\"97febcb3-33a9-418c-85dc-782550885731\\\\\\"\\",\\"1\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\",\\"System.Int32\\"]"}	["\\"4c1d7766-9eab-4edc-81ef-916805a8483b\\"", "\\"97febcb3-33a9-418c-85dc-782550885731\\"", "1"]	2026-11-17 17:32:58.909712+05:30	2026-11-18 17:33:41.338919+05:30	0
1411	2410	Succeeded	{"Type": "PMS.API.Modules.Timesheets.Jobs.TimesheetReminderJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-18 10:02:18.359383+05:30	2026-11-19 10:02:19.090206+05:30	0
1390	2406	Succeeded	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteReminderAsync", "Arguments": "[\\"\\\\\\"fe42dc87-4afc-4fd3-a57b-605910874475\\\\\\"\\",\\"\\\\\\"f4e82bbd-1f63-4384-b4ec-6bda41178217\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"fe42dc87-4afc-4fd3-a57b-605910874475\\"", "\\"f4e82bbd-1f63-4384-b4ec-6bda41178217\\""]	2026-11-17 15:58:22.575339+05:30	2026-11-19 10:02:19.060854+05:30	0
1409	2407	Succeeded	{"Type": "PMS.API.Modules.MyTeam.Jobs.TeamAvailabilityHodEscalationJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-18 10:02:18.317346+05:30	2026-11-19 10:02:19.068536+05:30	0
1410	2416	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-18 10:02:18.349566+05:30	2026-11-19 10:02:19.96125+05:30	0
1412	2412	Succeeded	{"Type": "PMS.API.Modules.Resources.Jobs.EmployeeOffboardingReminderJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-18 10:02:18.368337+05:30	2026-11-19 10:02:19.480228+05:30	0
1413	2414	Succeeded	{"Type": "PMS.API.Modules.MyTeam.Jobs.TeamAvailabilityTwoHourReminderJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-18 10:02:18.378787+05:30	2026-11-19 10:02:19.686024+05:30	0
1371	2420	Succeeded	{"Type": "PMS.API.Modules.Sla.Jobs.SlaBackgroundJobWorker, PMS.API", "Method": "ExecuteReminderAsync", "Arguments": "[\\"\\\\\\"f0c3e00c-14c8-4acf-84b9-39968dd089fb\\\\\\"\\",\\"\\\\\\"69877731-3464-49dd-8092-a97e41d34bf8\\\\\\"\\"]", "ParameterTypes": "[\\"System.Guid, mscorlib\\",\\"System.Guid, mscorlib\\"]"}	["\\"f0c3e00c-14c8-4acf-84b9-39968dd089fb\\"", "\\"69877731-3464-49dd-8092-a97e41d34bf8\\""]	2026-11-17 15:15:06.427016+05:30	2026-11-19 10:07:09.362652+05:30	0
1417	2423	Succeeded	{"Type": "PMS.API.Modules.ActionCentre.Jobs.BucketTaskAutoPauseJob, PMS.API", "Method": "ExecuteAsync", "Arguments": "[null]", "ParameterTypes": "[\\"System.Threading.CancellationToken, mscorlib\\"]"}	[null]	2026-11-18 10:15:03.858419+05:30	2026-11-19 10:15:03.885661+05:30	0
\.


--
-- Data for Name: jobparameter; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.jobparameter (id, jobid, name, value, updatecount) FROM stdin;
2728	1369	RecurringJobId	"bucket-task-auto-pause"	0
2729	1369	Time	1794908705	0
2730	1369	CurrentCulture	"en-IN"	0
2731	1369	CurrentUICulture	"en-US"	0
2732	1370	CurrentCulture	"en-IN"	0
2733	1370	CurrentUICulture	"en-US"	0
2734	1371	CurrentCulture	"en-IN"	0
2735	1371	CurrentUICulture	"en-US"	0
2736	1372	RecurringJobId	"bucket-task-auto-pause"	0
2737	1372	Time	1794909606	0
2738	1372	CurrentCulture	"en-IN"	0
2739	1372	CurrentUICulture	"en-US"	0
2740	1373	CurrentCulture	"en-IN"	0
2741	1373	CurrentUICulture	"en-US"	0
2742	1374	CurrentCulture	"en-IN"	0
2743	1374	CurrentUICulture	"en-US"	0
2744	1375	RecurringJobId	"bucket-task-auto-pause"	0
2745	1375	Time	1794910507	0
2746	1375	CurrentCulture	"en-IN"	0
2747	1375	CurrentUICulture	"en-US"	0
2748	1376	CurrentCulture	"en-IN"	0
2749	1376	CurrentUICulture	"en-US"	0
2750	1377	CurrentCulture	"en-IN"	0
2751	1377	CurrentUICulture	"en-US"	0
2752	1378	CurrentCulture	"en-IN"	0
2753	1378	CurrentUICulture	"en-US"	0
2754	1379	CurrentCulture	"en-IN"	0
2755	1379	CurrentUICulture	"en-US"	0
2764	1384	CurrentCulture	"en-IN"	0
2765	1384	CurrentUICulture	"en-US"	0
2766	1385	CurrentCulture	"en-IN"	0
2767	1385	CurrentUICulture	"en-US"	0
2768	1386	CurrentCulture	"en-IN"	0
2769	1386	CurrentUICulture	"en-US"	0
2770	1387	CurrentCulture	"en-IN"	0
2771	1387	CurrentUICulture	"en-US"	0
2772	1388	CurrentCulture	"en-IN"	0
2773	1388	CurrentUICulture	"en-US"	0
2774	1389	CurrentCulture	"en-IN"	0
2775	1389	CurrentUICulture	"en-US"	0
2776	1390	CurrentCulture	"en-IN"	0
2777	1390	CurrentUICulture	"en-US"	0
2778	1391	RecurringJobId	"bucket-task-auto-pause"	0
2779	1391	Time	1794911408	0
2780	1391	CurrentCulture	"en-IN"	0
2781	1391	CurrentUICulture	"en-US"	0
2782	1392	RecurringJobId	"bucket-task-auto-pause"	0
2783	1392	Time	1794912309	0
2784	1392	CurrentCulture	"en-IN"	0
2785	1392	CurrentUICulture	"en-US"	0
2786	1393	RecurringJobId	"bucket-task-auto-pause"	0
2787	1393	Time	1794913210	0
2788	1393	CurrentCulture	"en-IN"	0
2789	1393	CurrentUICulture	"en-US"	0
2790	1394	RecurringJobId	"bucket-task-auto-pause"	0
2791	1394	Time	1794914110	0
2792	1394	CurrentCulture	"en-IN"	0
2793	1394	CurrentUICulture	"en-US"	0
2794	1395	RecurringJobId	"team-availability-2hour-reminders"	0
2795	1395	Time	1794915011	0
2796	1395	CurrentCulture	"en-IN"	0
2797	1395	CurrentUICulture	"en-US"	0
2798	1396	RecurringJobId	"bucket-task-auto-pause"	0
2799	1396	Time	1794915011	0
2800	1396	CurrentCulture	"en-IN"	0
2801	1396	CurrentUICulture	"en-US"	0
2802	1397	RecurringJobId	"bucket-task-auto-pause"	0
2803	1397	Time	1794915912	0
2804	1397	CurrentCulture	"en-IN"	0
2805	1397	CurrentUICulture	"en-US"	0
2806	1398	CurrentCulture	"en-IN"	0
2807	1398	CurrentUICulture	"en-US"	0
2808	1399	CurrentCulture	"en-IN"	0
2809	1399	CurrentUICulture	"en-US"	0
2810	1400	CurrentCulture	"en-IN"	0
2811	1400	CurrentUICulture	"en-US"	0
2812	1401	RecurringJobId	"bucket-task-auto-pause"	0
2813	1401	Time	1794916812	0
2814	1401	CurrentCulture	"en-IN"	0
2815	1401	CurrentUICulture	"en-US"	0
2822	1405	CurrentCulture	"en-IN"	0
2823	1405	CurrentUICulture	"en-US"	0
2824	1406	CurrentCulture	"en-IN"	0
2825	1406	CurrentUICulture	"en-US"	0
2826	1407	CurrentCulture	"en-IN"	0
2827	1407	CurrentUICulture	"en-US"	0
2828	1408	RecurringJobId	"bucket-task-auto-pause"	0
2829	1408	Time	1794917713	0
2830	1408	CurrentCulture	"en-IN"	0
2831	1408	CurrentUICulture	"en-US"	0
2832	1409	RecurringJobId	"team-availability-hod-eod"	0
2833	1409	Time	1794976338	0
2834	1409	CurrentCulture	"en-IN"	0
2835	1409	CurrentUICulture	"en-US"	0
2836	1410	RecurringJobId	"bucket-task-auto-pause"	0
2837	1410	Time	1794976338	0
2838	1410	CurrentCulture	"en-IN"	0
2839	1410	CurrentUICulture	"en-US"	0
2840	1411	RecurringJobId	"timesheet-submission-reminders"	0
2841	1411	Time	1794976338	0
2842	1411	CurrentCulture	"en-IN"	0
2843	1411	CurrentUICulture	"en-US"	0
2844	1412	RecurringJobId	"employee-offboarding-reminders"	0
2845	1412	Time	1794976338	0
2846	1412	CurrentCulture	"en-IN"	0
2847	1412	CurrentUICulture	"en-US"	0
2848	1413	RecurringJobId	"team-availability-2hour-reminders"	0
2849	1413	Time	1794976338	0
2850	1413	CurrentCulture	"en-IN"	0
2851	1413	CurrentUICulture	"en-US"	0
2858	1417	RecurringJobId	"bucket-task-auto-pause"	0
2859	1417	Time	1794977103	0
2860	1417	CurrentCulture	"en-IN"	0
2861	1417	CurrentUICulture	"en-US"	0
\.


--
-- Data for Name: jobqueue; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.jobqueue (id, jobid, queue, fetchedat, updatecount) FROM stdin;
\.


--
-- Data for Name: list; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.list (id, key, value, expireat, updatecount) FROM stdin;
\.


--
-- Data for Name: lock; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.lock (resource, updatecount, acquired) FROM stdin;
hangfire:locks:schedulepoller	0	2026-11-18 10:02:18.240037+05:30
hangfire:job:848:state-lock	0	2026-11-18 10:22:02.477396+05:30
\.


--
-- Data for Name: schema; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.schema (version) FROM stdin;
23
\.


--
-- Data for Name: server; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.server (id, data, lastheartbeat, updatecount) FROM stdin;
projectcompass-pms-desktop-ro7pilu:13096:cd34b37c-ae87-4fce-b394-67a2bbf4d76b	{"Queues": ["default", "default"], "StartedAt": "2026-11-18T04:32:18.2211207Z", "WorkerCount": 2}	2026-11-18 10:21:48.593209+05:30	0
\.


--
-- Data for Name: set; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.set (id, key, score, value, expireat, updatecount) FROM stdin;
702	schedule	1795005000	700	\N	0
1291	schedule	1795091400	1289	\N	0
1294	schedule	1795091400	1292	\N	0
724	schedule	1795005000	722	\N	0
1299	schedule	1795091400	1297	\N	0
1304	schedule	1795091400	1302	\N	0
1317	schedule	1795005000	1315	\N	0
1333	schedule	1795091400	1331	\N	0
1345	schedule	1795091400	1343	\N	0
739	schedule	1795005000	737	\N	0
1359	schedule	1795091400	1357	\N	0
754	schedule	1795005000	752	\N	0
767	schedule	1795005000	765	\N	0
422	schedule	1795005000	420	\N	0
797	schedule	1795005000	795	\N	0
807	schedule	1795005000	805	\N	0
814	schedule	1795005000	812	\N	0
823	schedule	1795005000	821	\N	0
450	schedule	1795005000	448	\N	0
454	schedule	1795005000	452	\N	0
462	schedule	1795005000	460	\N	0
463	schedule	1795005000	461	\N	0
466	schedule	1795005000	464	\N	0
474	schedule	1795005000	472	\N	0
475	schedule	1795005000	473	\N	0
1269	schedule	1795005000	1267	\N	0
1273	schedule	1795005000	1271	\N	0
479	schedule	1795005000	477	\N	0
480	schedule	1795005000	478	\N	0
482	schedule	1795005000	480	\N	0
483	schedule	1795005000	481	\N	0
485	schedule	1795005000	483	\N	0
486	schedule	1795005000	484	\N	0
487	schedule	1795005000	485	\N	0
488	schedule	1795005000	486	\N	0
494	schedule	1794961082	492	\N	0
495	schedule	1795005000	493	\N	0
496	schedule	1795091400	494	\N	0
497	schedule	1795091400	495	\N	0
1284	schedule	1795005000	1282	\N	0
1287	schedule	1795005000	1285	\N	0
1288	schedule	1795005000	1286	\N	0
501	schedule	1795003571	499	\N	0
502	schedule	1795089971	500	\N	0
503	schedule	1795176371	501	\N	0
504	schedule	1795176371	502	\N	0
508	schedule	1795005000	506	\N	0
514	schedule	1795005000	512	\N	0
515	schedule	1795005000	513	\N	0
517	schedule	1795005000	515	\N	0
518	schedule	1795005000	516	\N	0
523	schedule	1795005000	521	\N	0
524	schedule	1795005000	522	\N	0
528	schedule	1794961092	526	\N	0
529	schedule	1795005000	527	\N	0
530	schedule	1795091400	528	\N	0
531	schedule	1795091400	529	\N	0
537	schedule	1795005000	535	\N	0
538	schedule	1795005000	536	\N	0
541	schedule	1794961095	539	\N	0
542	schedule	1795005000	540	\N	0
543	schedule	1795091400	541	\N	0
544	schedule	1795091400	542	\N	0
547	schedule	1795005000	545	\N	0
548	schedule	1795005000	546	\N	0
550	schedule	1795005000	548	\N	0
551	schedule	1795005000	549	\N	0
1292	schedule	1795091400	1290	\N	0
1293	schedule	1795005000	1291	\N	0
703	schedule	1795005000	701	\N	0
1295	schedule	1795091400	1293	\N	0
1298	schedule	1795091400	1296	\N	0
725	schedule	1795005000	723	\N	0
1300	schedule	1795005000	1298	\N	0
740	schedule	1795005000	738	\N	0
750	schedule	1795005000	748	\N	0
764	schedule	1795005000	762	\N	0
768	schedule	1795005000	766	\N	0
1310	schedule	1795091400	1308	\N	0
1316	schedule	1795091400	1314	\N	0
788	schedule	1795005000	786	\N	0
1330	schedule	1795091400	1328	\N	0
1338	schedule	1795005000	1336	\N	0
18	recurring-jobs	1795059000	employee-offboarding-reminders	\N	0
1340	schedule	1795091400	1338	\N	0
1341	schedule	1795005000	1339	\N	0
1343	schedule	1795091400	1341	\N	0
824	schedule	1795005000	822	\N	0
826	schedule	1795005000	824	\N	0
835	schedule	1795005000	833	\N	0
1348	schedule	1795091400	1346	\N	0
843	schedule	1795005000	841	\N	0
845	schedule	1795005000	843	\N	0
851	schedule	1795005000	849	\N	0
852	schedule	1795005000	850	\N	0
1354	schedule	1795091400	1352	\N	0
859	schedule	1795005000	857	\N	0
1360	schedule	1795091400	1358	\N	0
1366	schedule	1795091400	1364	\N	0
1368	schedule	1795005000	1366	\N	0
891	schedule	1795005000	889	\N	0
910	schedule	1795005000	908	\N	0
913	schedule	1795005000	911	\N	0
1252	schedule	1795005000	1250	\N	0
934	schedule	1795005000	932	\N	0
936	schedule	1795005000	934	\N	0
940	schedule	1795005000	938	\N	0
941	schedule	1795005000	939	\N	0
947	schedule	1795005000	945	\N	0
1255	schedule	1795005000	1253	\N	0
972	schedule	1795005000	970	\N	0
974	schedule	1795008639	972	\N	0
976	schedule	1795181439	974	\N	0
983	schedule	1795005000	981	\N	0
988	schedule	1794963622	986	\N	0
991	schedule	1795091400	989	\N	0
995	schedule	1794920424	993	\N	0
1001	schedule	1794963625	999	\N	0
1004	schedule	1795091400	1002	\N	0
1261	schedule	1795005000	1259	\N	0
1013	schedule	1795005000	1011	\N	0
1264	schedule	1795005000	1262	\N	0
1018	schedule	1795005000	1016	\N	0
1270	schedule	1795005000	1268	\N	0
1029	schedule	1795005000	1027	\N	0
1272	schedule	1795005000	1270	\N	0
1045	schedule	1795005000	1043	\N	0
1058	schedule	1795005000	1056	\N	0
1276	schedule	1795005000	1274	\N	0
1070	schedule	1795005000	1068	\N	0
1281	schedule	1795005000	1279	\N	0
1088	schedule	1795005000	1086	\N	0
1108	schedule	1795005000	1106	\N	0
1122	schedule	1795005000	1120	\N	0
1128	schedule	1795005000	1126	\N	0
1131	schedule	1795005000	1129	\N	0
1132	schedule	1795005000	1130	\N	0
1146	schedule	1795005000	1144	\N	0
1149	schedule	1795005000	1147	\N	0
1153	schedule	1795005000	1151	\N	0
1156	schedule	1795096645	1154	\N	0
1157	schedule	1795183045	1155	\N	0
1158	schedule	1795183045	1156	\N	0
1164	schedule	1795005000	1162	\N	0
1176	schedule	1794921225	1174	\N	0
1185	schedule	1795091400	1183	\N	0
1311	schedule	1795091400	1309	\N	0
1319	schedule	1795091400	1317	\N	0
1321	schedule	1795005000	1319	\N	0
1322	schedule	1795091400	1320	\N	0
1323	schedule	1795091400	1321	\N	0
1332	schedule	1795005000	1330	\N	0
1334	schedule	1795091400	1332	\N	0
1344	schedule	1795005000	1342	\N	0
1346	schedule	1795091400	1344	\N	0
1352	schedule	1795005000	1350	\N	0
1361	schedule	1795005000	1359	\N	0
792	schedule	1795005000	790	\N	0
827	schedule	1795005000	825	\N	0
836	schedule	1795005000	834	\N	0
849	schedule	1795005000	847	\N	0
858	schedule	1795005000	856	\N	0
880	schedule	1795005000	878	\N	0
881	schedule	1795005000	879	\N	0
901	schedule	1795005000	899	\N	0
917	schedule	1795005000	915	\N	0
924	schedule	1795005000	922	\N	0
926	schedule	1795005000	924	\N	0
927	schedule	1795005000	925	\N	0
945	schedule	1794963617	943	\N	0
946	schedule	1795005000	944	\N	0
948	schedule	1795091400	946	\N	0
952	schedule	1795005000	950	\N	0
953	schedule	1795005000	951	\N	0
964	schedule	1795005000	962	\N	0
973	schedule	1795005000	971	\N	0
981	schedule	1794920421	979	\N	0
984	schedule	1795005000	982	\N	0
997	schedule	1795005000	995	\N	0
1002	schedule	1795005000	1000	\N	0
1003	schedule	1795091400	1001	\N	0
1008	schedule	1795005000	1006	\N	0
1024	schedule	1795005000	1022	\N	0
1034	schedule	1795005000	1032	\N	0
1040	schedule	1795005000	1038	\N	0
1062	schedule	1795005000	1060	\N	0
1071	schedule	1795005000	1069	\N	0
1076	schedule	1795005000	1074	\N	0
1087	schedule	1795005000	1085	\N	0
1102	schedule	1795005000	1100	\N	0
1105	schedule	1795005000	1103	\N	0
1106	schedule	1795005000	1104	\N	0
1109	schedule	1795005000	1107	\N	0
1111	schedule	1795005000	1109	\N	0
1116	schedule	1795005000	1114	\N	0
1120	schedule	1795005000	1118	\N	0
1135	schedule	1795005000	1133	\N	0
1137	schedule	1795005000	1135	\N	0
1142	schedule	1795005000	1140	\N	0
1147	schedule	1795091400	1145	\N	0
1148	schedule	1795091400	1146	\N	0
1154	schedule	1795005000	1152	\N	0
1165	schedule	1795005000	1163	\N	0
1169	schedule	1794964424	1167	\N	0
1171	schedule	1795091400	1169	\N	0
1178	schedule	1795005000	1176	\N	0
1183	schedule	1795005000	1181	\N	0
1312	schedule	1795005000	1310	\N	0
1313	schedule	1795091400	1311	\N	0
1347	schedule	1795005000	1345	\N	0
757	schedule	1795005000	755	\N	0
1356	schedule	1795005000	1354	\N	0
1358	schedule	1795091400	1356	\N	0
1362	schedule	1795091400	1360	\N	0
1367	schedule	1795091400	1365	\N	0
817	schedule	1795005000	815	\N	0
832	schedule	1795005000	830	\N	0
838	schedule	1795005000	836	\N	0
848	schedule	1795005000	846	\N	0
850	schedule	1794918600	848	\N	0
857	schedule	1795005000	855	\N	0
861	schedule	1794918600	859	\N	0
862	schedule	1795005000	860	\N	0
863	schedule	1795005000	861	\N	0
879	schedule	1794918600	877	\N	0
894	schedule	1795005000	892	\N	0
896	schedule	1794918600	894	\N	0
898	schedule	1794918600	896	\N	0
903	schedule	1794918600	901	\N	0
914	schedule	1795005000	912	\N	0
916	schedule	1795005000	914	\N	0
922	schedule	1794918600	920	\N	0
923	schedule	1795005000	921	\N	0
944	schedule	1795005000	942	\N	0
949	schedule	1795091400	947	\N	0
951	schedule	1794918600	949	\N	0
958	schedule	1794918600	956	\N	0
960	schedule	1795005000	958	\N	0
961	schedule	1795005000	959	\N	0
1253	schedule	1795005000	1251	\N	0
969	schedule	1795005000	967	\N	0
1260	schedule	1795005000	1258	\N	0
971	schedule	1794918600	969	\N	0
975	schedule	1795095039	973	\N	0
977	schedule	1795181439	975	\N	0
1263	schedule	1795005000	1261	\N	0
982	schedule	1794918600	980	\N	0
989	schedule	1795005000	987	\N	0
990	schedule	1795091400	988	\N	0
996	schedule	1794918600	994	\N	0
998	schedule	1795005000	996	\N	0
1007	schedule	1795005000	1005	\N	0
1271	schedule	1794918600	1269	\N	0
1014	schedule	1795005000	1012	\N	0
1019	schedule	1794918600	1017	\N	0
1020	schedule	1795005000	1018	\N	0
1275	schedule	1795005000	1273	\N	0
1023	schedule	1795005000	1021	\N	0
1277	schedule	1794918600	1275	\N	0
1030	schedule	1795005000	1028	\N	0
1032	schedule	1795005000	1030	\N	0
1278	schedule	1795005000	1276	\N	0
1035	schedule	1795005000	1033	\N	0
1036	schedule	1794918600	1034	\N	0
1039	schedule	1795005000	1037	\N	0
1046	schedule	1795005000	1044	\N	0
1048	schedule	1795005000	1046	\N	0
1051	schedule	1795005000	1049	\N	0
1052	schedule	1794918600	1050	\N	0
1054	schedule	1795005000	1052	\N	0
1057	schedule	1795005000	1055	\N	0
1073	schedule	1795005000	1071	\N	0
1082	schedule	1795005000	1080	\N	0
1089	schedule	1795005000	1087	\N	0
1090	schedule	1795005000	1088	\N	0
1117	schedule	1795005000	1115	\N	0
1129	schedule	1795005000	1127	\N	0
1134	schedule	1795005000	1132	\N	0
1145	schedule	1794964422	1143	\N	0
1152	schedule	1794918600	1150	\N	0
1155	schedule	1795010245	1153	\N	0
1159	schedule	1794918600	1157	\N	0
1162	schedule	1794921223	1160	\N	0
1167	schedule	1794918600	1165	\N	0
1168	schedule	1794918600	1166	\N	0
1170	schedule	1795005000	1168	\N	0
1172	schedule	1795091400	1170	\N	0
1179	schedule	1795005000	1177	\N	0
1182	schedule	1794964425	1180	\N	0
1184	schedule	1795091400	1182	\N	0
1303	schedule	1795005000	1301	\N	0
570	schedule	1794918600	568	\N	0
571	schedule	1795005000	569	\N	0
572	schedule	1795005000	570	\N	0
573	schedule	1794918600	571	\N	0
574	schedule	1795005000	572	\N	0
575	schedule	1795005000	573	\N	0
576	schedule	1794918600	574	\N	0
577	schedule	1794918600	575	\N	0
578	schedule	1795005000	576	\N	0
579	schedule	1795005000	577	\N	0
1305	schedule	1795091400	1303	\N	0
1324	schedule	1795005000	1322	\N	0
582	schedule	1795005000	580	\N	0
583	schedule	1794918600	581	\N	0
584	schedule	1794918600	582	\N	0
585	schedule	1795005000	583	\N	0
586	schedule	1795005000	584	\N	0
1325	schedule	1795091400	1323	\N	0
589	schedule	1795005000	587	\N	0
590	schedule	1794918600	588	\N	0
1329	schedule	1795005000	1327	\N	0
593	schedule	1795005000	591	\N	0
594	schedule	1794918600	592	\N	0
595	schedule	1794918600	593	\N	0
596	schedule	1795005000	594	\N	0
597	schedule	1795005000	595	\N	0
598	schedule	1794918600	596	\N	0
599	schedule	1795005000	597	\N	0
600	schedule	1795005000	598	\N	0
601	schedule	1794918600	599	\N	0
602	schedule	1795005000	600	\N	0
603	schedule	1795005000	601	\N	0
604	schedule	1794918600	602	\N	0
1331	schedule	1795091400	1329	\N	0
753	schedule	1795005000	751	\N	0
607	schedule	1795005000	605	\N	0
608	schedule	1794918600	606	\N	0
761	schedule	1795005000	759	\N	0
611	schedule	1795005000	609	\N	0
612	schedule	1794918600	610	\N	0
613	schedule	1794918600	611	\N	0
614	schedule	1795005000	612	\N	0
615	schedule	1795005000	613	\N	0
616	schedule	1794918600	614	\N	0
617	schedule	1795005000	615	\N	0
618	schedule	1795005000	616	\N	0
765	schedule	1795005000	763	\N	0
1339	schedule	1795091400	1337	\N	0
621	schedule	1795005000	619	\N	0
622	schedule	1794918600	620	\N	0
623	schedule	1794918600	621	\N	0
624	schedule	1795005000	622	\N	0
625	schedule	1795005000	623	\N	0
626	schedule	1794918600	624	\N	0
627	schedule	1795005000	625	\N	0
628	schedule	1795005000	626	\N	0
1342	schedule	1795091400	1340	\N	0
631	schedule	1795005000	629	\N	0
632	schedule	1794918600	630	\N	0
1351	schedule	1795091400	1349	\N	0
635	schedule	1795005000	633	\N	0
636	schedule	1794918600	634	\N	0
637	schedule	1794918600	635	\N	0
638	schedule	1795005000	636	\N	0
639	schedule	1795005000	637	\N	0
1357	schedule	1795091400	1355	\N	0
642	schedule	1795005000	640	\N	0
643	schedule	1794918600	641	\N	0
644	schedule	1794918600	642	\N	0
645	schedule	1795005000	643	\N	0
646	schedule	1795005000	644	\N	0
647	schedule	1794918600	645	\N	0
648	schedule	1795005000	646	\N	0
649	schedule	1795005000	647	\N	0
789	schedule	1795005000	787	\N	0
1363	schedule	1795091400	1361	\N	0
652	schedule	1795005000	650	\N	0
653	schedule	1794918600	651	\N	0
796	schedule	1795005000	794	\N	0
806	schedule	1795005000	804	\N	0
813	schedule	1795005000	811	\N	0
816	schedule	1795005000	814	\N	0
831	schedule	1794918600	829	\N	0
833	schedule	1795005000	831	\N	0
837	schedule	1794918600	835	\N	0
673	schedule	1795005000	671	\N	0
674	schedule	1795005000	672	\N	0
839	schedule	1795005000	837	\N	0
677	schedule	1795005000	675	\N	0
680	schedule	1795005000	678	\N	0
681	schedule	1795005000	679	\N	0
684	schedule	1795005000	682	\N	0
687	schedule	1795005000	685	\N	0
688	schedule	1795005000	686	\N	0
691	schedule	1795005000	689	\N	0
695	schedule	1795005000	693	\N	0
698	schedule	1795005000	696	\N	0
699	schedule	1795005000	697	\N	0
1373	recurring-jobs	1794979800	team-availability-leadership-11am	\N	0
1374	recurring-jobs	1794983400	team-availability-leadership-12pm	\N	0
1375	recurring-jobs	1794987000	team-availability-spm-1pm	\N	0
1388	schedule	1802734008	1380	\N	0
1389	schedule	1810470600	1381	\N	0
1390	schedule	1810557000	1382	\N	0
1391	schedule	1810557000	1383	\N	0
1410	schedule	1795005000	1402	\N	0
1411	schedule	1795091400	1403	\N	0
1412	schedule	1795091400	1404	\N	0
1376	recurring-jobs	1795005000	team-availability-hod-eod	\N	0
17	recurring-jobs	1795059000	timesheet-submission-reminders	\N	0
1372	recurring-jobs	1794979800	team-availability-2hour-reminders	\N	0
1422	schedule	1795005000	1414	\N	0
1423	schedule	1795005000	1415	\N	0
1424	schedule	1795005000	1416	\N	0
1371	recurring-jobs	1794978000	bucket-task-auto-pause	\N	0
\.


--
-- Data for Name: state; Type: TABLE DATA; Schema: hangfire; Owner: -
--

COPY hangfire.state (id, jobid, name, reason, createdat, data, updatecount) FROM stdin;
2314	1369	Enqueued	Triggered by recurring job scheduler	2026-11-17 15:15:05.807205+05:30	{"Queue": "default", "EnqueuedAt": "1794908705799"}	0
2315	1369	Processing	\N	2026-11-17 15:15:05.841896+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "67efc608-997d-4cba-a440-82301725b8f6", "StartedAt": "1794908705826"}	0
2316	1370	Scheduled	\N	2026-11-17 15:15:06.349291+05:30	{"EnqueueAt": "1794918600093", "ScheduledAt": "1794908706341"}	0
2317	1371	Scheduled	\N	2026-11-17 15:15:06.43067+05:30	{"EnqueueAt": "1794918600012", "ScheduledAt": "1794908706426"}	0
2318	1369	Succeeded	\N	2026-11-17 15:15:06.456931+05:30	{"Latency": "67", "SucceededAt": "1794908706443", "PerformanceDuration": "596"}	0
2319	1372	Enqueued	Triggered by recurring job scheduler	2026-11-17 15:30:06.576383+05:30	{"Queue": "default", "EnqueuedAt": "1794909606576"}	0
2320	1372	Processing	\N	2026-11-17 15:30:06.58678+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "67efc608-997d-4cba-a440-82301725b8f6", "StartedAt": "1794909606582"}	0
2321	1372	Succeeded	\N	2026-11-17 15:30:06.610971+05:30	{"Latency": "17", "SucceededAt": "1794909606604", "PerformanceDuration": "13"}	0
2322	1373	Scheduled	\N	2026-11-17 15:39:25.802621+05:30	{"EnqueueAt": "1794917365793", "ScheduledAt": "1794910165793"}	0
2323	1374	Scheduled	\N	2026-11-17 15:39:25.818768+05:30	{"EnqueueAt": "1794918600000", "ScheduledAt": "1794910165811"}	0
2324	1375	Enqueued	Triggered by recurring job scheduler	2026-11-17 15:45:07.347983+05:30	{"Queue": "default", "EnqueuedAt": "1794910507347"}	0
2325	1375	Processing	\N	2026-11-17 15:45:07.367469+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "01698863-b1b4-4db9-aaa6-c8777e50c5e0", "StartedAt": "1794910507361"}	0
2326	1375	Succeeded	\N	2026-11-17 15:45:07.445625+05:30	{"Latency": "31", "SucceededAt": "1794910507430", "PerformanceDuration": "54"}	0
2327	1373	Deleted	\N	2026-11-17 15:51:36.359269+05:30	{"DeletedAt": "1794910896336"}	0
2328	1374	Deleted	\N	2026-11-17 15:51:36.375236+05:30	{"DeletedAt": "1794910896365"}	0
2329	1376	Scheduled	\N	2026-11-17 15:52:07.518575+05:30	{"EnqueueAt": "1795091400019", "ScheduledAt": "1794910927509"}	0
2330	1377	Scheduled	\N	2026-11-17 15:52:07.553115+05:30	{"EnqueueAt": "1795091400053", "ScheduledAt": "1794910927544"}	0
2331	1376	Deleted	\N	2026-11-17 15:52:44.008435+05:30	{"DeletedAt": "1794910964000"}	0
2332	1377	Deleted	\N	2026-11-17 15:52:44.020284+05:30	{"DeletedAt": "1794910964013"}	0
2333	1378	Scheduled	\N	2026-11-17 15:53:37.483809+05:30	{"EnqueueAt": "1794918600083", "ScheduledAt": "1794911017472"}	0
2334	1379	Scheduled	\N	2026-11-17 15:53:37.514111+05:30	{"EnqueueAt": "1794918600118", "ScheduledAt": "1794911017506"}	0
2339	1378	Deleted	\N	2026-11-17 15:54:12.671178+05:30	{"DeletedAt": "1794911052658"}	0
2340	1379	Deleted	\N	2026-11-17 15:54:12.690024+05:30	{"DeletedAt": "1794911052678"}	0
2341	1384	Scheduled	\N	2026-11-17 15:54:21.629919+05:30	{"EnqueueAt": "1794918600167", "ScheduledAt": "1794911061620"}	0
2342	1384	Deleted	\N	2026-11-17 15:54:22.107363+05:30	{"DeletedAt": "1794911062092"}	0
2343	1385	Scheduled	\N	2026-11-17 15:54:24.69532+05:30	{"EnqueueAt": "1794918600020", "ScheduledAt": "1794911064689"}	0
2344	1385	Deleted	\N	2026-11-17 15:54:28.010221+05:30	{"DeletedAt": "1794911067994"}	0
2345	1386	Scheduled	\N	2026-11-17 15:54:35.722141+05:30	{"EnqueueAt": "1794918600205", "ScheduledAt": "1794911075716"}	0
2346	1386	Deleted	\N	2026-11-17 15:54:39.786796+05:30	{"DeletedAt": "1794911079776"}	0
2347	1387	Scheduled	\N	2026-11-17 15:54:44.439551+05:30	{"EnqueueAt": "1794918600073", "ScheduledAt": "1794911084434"}	0
2348	1387	Deleted	\N	2026-11-17 15:54:49.159702+05:30	{"DeletedAt": "1794911089145"}	0
2349	1388	Scheduled	\N	2026-11-17 15:54:54.612192+05:30	{"EnqueueAt": "1794918600019", "ScheduledAt": "1794911094606"}	0
2350	1388	Deleted	\N	2026-11-17 15:57:57.622268+05:30	{"DeletedAt": "1794911277606"}	0
2351	1389	Scheduled	\N	2026-11-17 15:58:04.488216+05:30	{"EnqueueAt": "1794918600015", "ScheduledAt": "1794911284483"}	0
2352	1389	Deleted	\N	2026-11-17 15:58:19.339703+05:30	{"DeletedAt": "1794911299317"}	0
2353	1390	Scheduled	\N	2026-11-17 15:58:22.582907+05:30	{"EnqueueAt": "1794918600022", "ScheduledAt": "1794911302575"}	0
2354	1391	Enqueued	Triggered by recurring job scheduler	2026-11-17 16:00:08.285072+05:30	{"Queue": "default", "EnqueuedAt": "1794911408284"}	0
2355	1391	Processing	\N	2026-11-17 16:00:08.341046+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "67efc608-997d-4cba-a440-82301725b8f6", "StartedAt": "1794911408332"}	0
2356	1391	Succeeded	\N	2026-11-17 16:00:08.658104+05:30	{"Latency": "76", "SucceededAt": "1794911408644", "PerformanceDuration": "296"}	0
2357	1392	Enqueued	Triggered by recurring job scheduler	2026-11-17 16:15:09.085271+05:30	{"Queue": "default", "EnqueuedAt": "1794912309085"}	0
2358	1392	Processing	\N	2026-11-17 16:15:09.10673+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "67efc608-997d-4cba-a440-82301725b8f6", "StartedAt": "1794912309099"}	0
2359	1392	Succeeded	\N	2026-11-17 16:15:10.214027+05:30	{"Latency": "35", "SucceededAt": "1794912310200", "PerformanceDuration": "1088"}	0
2360	1393	Enqueued	Triggered by recurring job scheduler	2026-11-17 16:30:10.313025+05:30	{"Queue": "default", "EnqueuedAt": "1794913210312"}	0
2361	1393	Processing	\N	2026-11-17 16:30:10.323725+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "67efc608-997d-4cba-a440-82301725b8f6", "StartedAt": "1794913210319"}	0
2362	1393	Succeeded	\N	2026-11-17 16:30:10.407576+05:30	{"Latency": "18", "SucceededAt": "1794913210397", "PerformanceDuration": "68"}	0
2363	1394	Enqueued	Triggered by recurring job scheduler	2026-11-17 16:45:10.949223+05:30	{"Queue": "default", "EnqueuedAt": "1794914110949"}	0
2364	1394	Processing	\N	2026-11-17 16:45:10.958848+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "01698863-b1b4-4db9-aaa6-c8777e50c5e0", "StartedAt": "1794914110955"}	0
2365	1394	Succeeded	\N	2026-11-17 16:45:11.04339+05:30	{"Latency": "16", "SucceededAt": "1794914111035", "PerformanceDuration": "72"}	0
2366	1370	Deleted	\N	2026-11-17 16:55:51.657831+05:30	{"DeletedAt": "1794914751645"}	0
2367	1395	Enqueued	Triggered by recurring job scheduler	2026-11-17 17:00:11.55185+05:30	{"Queue": "default", "EnqueuedAt": "1794915011551"}	0
2368	1395	Processing	\N	2026-11-17 17:00:11.562649+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "67efc608-997d-4cba-a440-82301725b8f6", "StartedAt": "1794915011559"}	0
2369	1396	Enqueued	Triggered by recurring job scheduler	2026-11-17 17:00:11.56368+05:30	{"Queue": "default", "EnqueuedAt": "1794915011563"}	0
2370	1396	Processing	\N	2026-11-17 17:00:11.57534+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "01698863-b1b4-4db9-aaa6-c8777e50c5e0", "StartedAt": "1794915011571"}	0
2371	1396	Succeeded	\N	2026-11-17 17:00:11.908488+05:30	{"Latency": "20", "SucceededAt": "1794915011895", "PerformanceDuration": "314"}	0
2372	1395	Succeeded	\N	2026-11-17 17:00:12.919046+05:30	{"Latency": "17", "SucceededAt": "1794915012913", "PerformanceDuration": "1347"}	0
2373	1397	Enqueued	Triggered by recurring job scheduler	2026-11-17 17:15:12.183738+05:30	{"Queue": "default", "EnqueuedAt": "1794915912183"}	0
2374	1397	Processing	\N	2026-11-17 17:15:12.199068+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "01698863-b1b4-4db9-aaa6-c8777e50c5e0", "StartedAt": "1794915912193"}	0
2375	1397	Succeeded	\N	2026-11-17 17:15:12.305975+05:30	{"Latency": "26", "SucceededAt": "1794915912298", "PerformanceDuration": "91"}	0
2376	1398	Scheduled	\N	2026-11-17 17:26:05.928619+05:30	{"EnqueueAt": "1795005000026", "ScheduledAt": "1794916565920"}	0
2377	1399	Scheduled	\N	2026-11-17 17:26:06.277284+05:30	{"EnqueueAt": "1795091400377", "ScheduledAt": "1794916566271"}	0
2378	1400	Scheduled	\N	2026-11-17 17:26:06.404788+05:30	{"EnqueueAt": "1795091400503", "ScheduledAt": "1794916566397"}	0
2379	1398	Deleted	\N	2026-11-17 17:28:06.116572+05:30	{"DeletedAt": "1794916686103"}	0
2380	1399	Deleted	\N	2026-11-17 17:28:06.132149+05:30	{"DeletedAt": "1794916686124"}	0
2381	1400	Deleted	\N	2026-11-17 17:28:06.145477+05:30	{"DeletedAt": "1794916686136"}	0
2382	1401	Enqueued	Triggered by recurring job scheduler	2026-11-17 17:30:12.790676+05:30	{"Queue": "default", "EnqueuedAt": "1794916812790"}	0
2383	1401	Processing	\N	2026-11-17 17:30:12.799465+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "67efc608-997d-4cba-a440-82301725b8f6", "StartedAt": "1794916812796"}	0
2384	1401	Succeeded	\N	2026-11-17 17:30:12.926914+05:30	{"Latency": "15", "SucceededAt": "1794916812919", "PerformanceDuration": "116"}	0
2388	1405	Scheduled	\N	2026-11-17 17:32:58.890722+05:30	{"EnqueueAt": "1795005000028", "ScheduledAt": "1794916978886"}	0
2389	1406	Scheduled	\N	2026-11-17 17:32:58.9023+05:30	{"EnqueueAt": "1795091400042", "ScheduledAt": "1794916978899"}	0
2390	1407	Scheduled	\N	2026-11-17 17:32:58.912882+05:30	{"EnqueueAt": "1795091400052", "ScheduledAt": "1794916978909"}	0
2391	1405	Deleted	\N	2026-11-17 17:33:41.315241+05:30	{"DeletedAt": "1794917021305"}	0
2392	1406	Deleted	\N	2026-11-17 17:33:41.328519+05:30	{"DeletedAt": "1794917021320"}	0
2393	1407	Deleted	\N	2026-11-17 17:33:41.34125+05:30	{"DeletedAt": "1794917021332"}	0
2394	1408	Enqueued	Triggered by recurring job scheduler	2026-11-17 17:45:13.393573+05:30	{"Queue": "default", "EnqueuedAt": "1794917713393"}	0
2395	1408	Processing	\N	2026-11-17 17:45:13.403811+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:14464:0da61ec9-31fe-4065-a5e7-bad8f51274f8", "WorkerId": "67efc608-997d-4cba-a440-82301725b8f6", "StartedAt": "1794917713400"}	0
2396	1408	Succeeded	\N	2026-11-17 17:45:13.530362+05:30	{"Latency": "18", "SucceededAt": "1794917713521", "PerformanceDuration": "113"}	0
2397	1390	Enqueued	Triggered by DelayedJobScheduler	2026-11-18 10:02:18.322476+05:30	{"Queue": "default", "EnqueuedAt": "1794976338255"}	0
2398	1409	Enqueued	Triggered by recurring job scheduler	2026-11-18 10:02:18.336161+05:30	{"Queue": "default", "EnqueuedAt": "1794976338334"}	0
2399	1390	Processing	\N	2026-11-18 10:02:18.342809+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:13096:cd34b37c-ae87-4fce-b394-67a2bbf4d76b", "WorkerId": "03e4acb5-d944-4cc6-910e-a7f6574c1b16", "StartedAt": "1794976338338"}	0
2400	1410	Enqueued	Triggered by recurring job scheduler	2026-11-18 10:02:18.351878+05:30	{"Queue": "default", "EnqueuedAt": "1794976338351"}	0
2401	1411	Enqueued	Triggered by recurring job scheduler	2026-11-18 10:02:18.360864+05:30	{"Queue": "default", "EnqueuedAt": "1794976338360"}	0
2402	1412	Enqueued	Triggered by recurring job scheduler	2026-11-18 10:02:18.37081+05:30	{"Queue": "default", "EnqueuedAt": "1794976338370"}	0
2403	1413	Enqueued	Triggered by recurring job scheduler	2026-11-18 10:02:18.380518+05:30	{"Queue": "default", "EnqueuedAt": "1794976338380"}	0
2404	1409	Processing	\N	2026-11-18 10:02:18.394988+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:13096:cd34b37c-ae87-4fce-b394-67a2bbf4d76b", "WorkerId": "381a4321-a8b1-48f8-8fa0-9aee846b8f84", "StartedAt": "1794976338392"}	0
2406	1390	Succeeded	\N	2026-11-18 10:02:19.062926+05:30	{"Latency": "65035771", "SucceededAt": "1794976339052", "PerformanceDuration": "688"}	0
2407	1409	Succeeded	\N	2026-11-18 10:02:19.069285+05:30	{"Latency": "79", "SucceededAt": "1794976339065", "PerformanceDuration": "668"}	0
2408	1410	Processing	\N	2026-11-18 10:02:19.073755+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:13096:cd34b37c-ae87-4fce-b394-67a2bbf4d76b", "WorkerId": "03e4acb5-d944-4cc6-910e-a7f6574c1b16", "StartedAt": "1794976339071"}	0
2409	1411	Processing	\N	2026-11-18 10:02:19.075519+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:13096:cd34b37c-ae87-4fce-b394-67a2bbf4d76b", "WorkerId": "381a4321-a8b1-48f8-8fa0-9aee846b8f84", "StartedAt": "1794976339073"}	0
2410	1411	Succeeded	\N	2026-11-18 10:02:19.090786+05:30	{"Latency": "717", "SucceededAt": "1794976339086", "PerformanceDuration": "9"}	0
2411	1412	Processing	\N	2026-11-18 10:02:19.098801+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:13096:cd34b37c-ae87-4fce-b394-67a2bbf4d76b", "WorkerId": "381a4321-a8b1-48f8-8fa0-9aee846b8f84", "StartedAt": "1794976339096"}	0
2412	1412	Succeeded	\N	2026-11-18 10:02:19.48185+05:30	{"Latency": "733", "SucceededAt": "1794976339474", "PerformanceDuration": "373"}	0
2413	1413	Processing	\N	2026-11-18 10:02:19.49243+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:13096:cd34b37c-ae87-4fce-b394-67a2bbf4d76b", "WorkerId": "381a4321-a8b1-48f8-8fa0-9aee846b8f84", "StartedAt": "1794976339489"}	0
2414	1413	Succeeded	\N	2026-11-18 10:02:19.6865+05:30	{"Latency": "1116", "SucceededAt": "1794976339681", "PerformanceDuration": "186"}	0
2416	1410	Succeeded	\N	2026-11-18 10:02:19.961756+05:30	{"Latency": "726", "SucceededAt": "1794976339957", "PerformanceDuration": "882"}	0
2418	1371	Processing	\N	2026-11-18 10:07:09.305802+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:13096:cd34b37c-ae87-4fce-b394-67a2bbf4d76b", "WorkerId": "381a4321-a8b1-48f8-8fa0-9aee846b8f84", "StartedAt": "1794976629303"}	0
2417	1371	Enqueued	Triggered by DelayedJobScheduler	2026-11-18 10:07:09.300289+05:30	{"Queue": "default", "EnqueuedAt": "1794976629297"}	0
2420	1371	Succeeded	\N	2026-11-18 10:07:09.363379+05:30	{"Latency": "67922880", "SucceededAt": "1794976629359", "PerformanceDuration": "51"}	0
2421	1417	Enqueued	Triggered by recurring job scheduler	2026-11-18 10:15:03.860356+05:30	{"Queue": "default", "EnqueuedAt": "1794977103860"}	0
2422	1417	Processing	\N	2026-11-18 10:15:03.867657+05:30	{"ServerId": "projectcompass-pms-desktop-ro7pilu:13096:cd34b37c-ae87-4fce-b394-67a2bbf4d76b", "WorkerId": "03e4acb5-d944-4cc6-910e-a7f6574c1b16", "StartedAt": "1794977103865"}	0
2423	1417	Succeeded	\N	2026-11-18 10:15:03.886405+05:30	{"Latency": "11", "SucceededAt": "1794977103882", "PerformanceDuration": "12"}	0
\.


--
-- Data for Name: mst_address_cities; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_address_cities ("Id", "Code", "Name", "Line", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
c1b7b609-e972-46bf-af06-05ea01dd793a	churchgate_western_line	Churchgate (Western Line)	Western Line	t	1	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
816d2434-c6f3-4100-a803-c3d41446e48f	marine_lines_western_line	Marine Lines (Western Line)	Western Line	t	2	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
04d78d3c-d816-42e0-8c0b-9b6b6ec15cbc	charni_road_western_line	Charni Road (Western Line)	Western Line	t	3	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
b196c811-3eff-4bc2-8f6c-f56603422910	grant_road_western_line	Grant Road (Western Line)	Western Line	t	4	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
a56bedc6-b8df-4686-823f-338a61694114	mumbai_central_western_line	Mumbai Central (Western Line)	Western Line	t	5	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
9b11869d-489c-44b3-b7ea-e8e25e1bd18d	mahalaxmi_western_line	Mahalaxmi (Western Line)	Western Line	t	6	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
1946b3fd-9ed1-45d7-8533-f37b2d489ad9	lower_parel_western_line	Lower Parel (Western Line)	Western Line	t	7	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
7827ce15-f1d3-4ba4-ba15-e04590f7b3cb	prabhadevi_western_line	Prabhadevi (Western Line)	Western Line	t	8	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
061c6b2d-1862-4938-9783-c0dfe926b6f8	dadar_western_line	Dadar (Western Line)	Western Line	t	9	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
f55686d6-a384-4e19-a9ad-f45f66463607	matunga_road_western_line	Matunga Road (Western Line)	Western Line	t	10	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
106140c8-b74c-4014-9061-7ba531736359	mahim_western_line	Mahim (Western Line)	Western Line	t	11	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
faee47c0-ec5d-4ec4-a09d-65c464750bb2	bandra_western_line	Bandra (Western Line)	Western Line	t	12	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
4db9eaea-2ee7-45ef-9fc0-e70d68edec29	khar_road_western_line	Khar Road (Western Line)	Western Line	t	13	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
ea19c292-de26-4b38-8b50-6a25fae9dea9	santacruz_western_line	Santacruz (Western Line)	Western Line	t	14	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
31e8c5b0-d95c-4b0d-aa1a-0488f0c5a9bc	vile_parle_western_line	Vile Parle (Western Line)	Western Line	t	15	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
898a74ea-4eca-4f9e-bbd5-0ccb764f753d	andheri_western_line	Andheri (Western Line)	Western Line	t	16	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
144bbdd1-7203-4f8c-860c-42980f67a5b8	jogeshwari_western_line	Jogeshwari (Western Line)	Western Line	t	17	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
56b2b441-e2d7-4f0e-8557-739b24e953c5	ram_mandir_western_line	Ram Mandir (Western Line)	Western Line	t	18	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
c0a0945e-f689-4714-aa1c-2b08c91f3d2e	goregaon_western_line	Goregaon (Western Line)	Western Line	t	19	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
b7dbca39-832c-4db7-bca9-1ab73f62046d	malad_western_line	Malad (Western Line)	Western Line	t	20	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
731acfdf-10ac-46fc-a584-4bdce4474920	kandivali_western_line	Kandivali (Western Line)	Western Line	t	21	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
4bae1d84-893b-4b3a-9aa3-4c6fe0ac0106	borivali_western_line	Borivali (Western Line)	Western Line	t	22	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
20384898-808a-4dbb-b015-b15b73d94552	dahisar_western_line	Dahisar (Western Line)	Western Line	t	23	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
a43d47b6-9277-40e3-a158-724901c63c2c	mira_road_western_line	Mira Road (Western Line)	Western Line	t	24	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
e89a779a-9c79-4961-886f-c253db287e2b	bhayandar_western_line	Bhayandar (Western Line)	Western Line	t	25	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
5f291975-efdc-43a2-b939-ec9c0379fc82	naigaon_western_line	Naigaon (Western Line)	Western Line	t	26	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
3803b898-069d-4f35-a2df-05124a852a93	vasai_road_western_line	Vasai Road (Western Line)	Western Line	t	27	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
fb022e30-691a-4dc2-b9ae-6f8fe7cae3ac	nallasopara_western_line	Nallasopara (Western Line)	Western Line	t	28	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
a79124eb-b6f3-4410-9c4d-20993429f10e	virar_western_line	Virar (Western Line)	Western Line	t	29	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
a9ed2bd5-8add-4cf5-8ebb-7ca3a581b80d	vaitarna_western_line	Vaitarna (Western Line)	Western Line	t	30	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
959bbbc8-674c-4a35-988f-06b291ce32a7	saphale_western_line	Saphale (Western Line)	Western Line	t	31	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
b28f8d75-3132-4c81-8af2-9f19d2777027	kelve_road_western_line	Kelve Road (Western Line)	Western Line	t	32	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
7bbd8d32-4d50-4c99-b829-1638af8466c4	palghar_western_line	Palghar (Western Line)	Western Line	t	33	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
315920ab-c0fc-402c-a0bc-05d801b64238	umroli_western_line	Umroli (Western Line)	Western Line	t	34	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
755e0fe8-75be-4ae6-9280-55b51076f973	boisar_western_line	Boisar (Western Line)	Western Line	t	35	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
08bbc01f-e72f-4185-925e-fa4eec5d0955	vangaon_western_line	Vangaon (Western Line)	Western Line	t	36	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
076cc445-f523-456d-b93e-ff43b7df2874	dahanu_road_western_line	Dahanu Road (Western Line)	Western Line	t	37	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
486a014e-77a8-4278-956a-3ff9745b2946	csmt_central_line	CSMT (Central Line)	Central Line	t	38	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
504510c8-d338-42de-9fb1-a57bca7fc64a	masjid_central_line	Masjid (Central Line)	Central Line	t	39	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
de58996d-0833-4dfd-bf02-f4c2d20c38b0	sandhurst_road_central_line	Sandhurst Road (Central Line)	Central Line	t	40	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
2358b01d-cee9-48de-a7e1-95d52ccc0e39	byculla_central_line	Byculla (Central Line)	Central Line	t	41	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
b150dfe1-d758-4b4b-beed-6f4cf23840fd	chinchpokli_central_line	Chinchpokli (Central Line)	Central Line	t	42	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
5b312dea-f8f6-409f-9402-d9925bc556b1	currey_road_central_line	Currey Road (Central Line)	Central Line	t	43	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
9c216179-eb61-4b9d-b5a9-46ce6b0a02ea	parel_central_line	Parel (Central Line)	Central Line	t	44	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
dc7275e9-a686-4a17-8d29-db05d7bcdc66	dadar_central_line	Dadar (Central Line)	Central Line	t	45	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
a3f85e1b-fd8d-4945-ba90-3d688c1c1e82	matunga_central_line	Matunga (Central Line)	Central Line	t	46	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
3dd73e6b-9ef6-429c-876a-9aa88c4c26f0	sion_central_line	Sion (Central Line)	Central Line	t	47	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
c64cab5a-e26e-48b0-8746-16e0b3bb4a65	kurla_central_line	Kurla (Central Line)	Central Line	t	48	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
8e2da2b5-5371-44a8-9624-7d0588317bc1	vidyavihar_central_line	Vidyavihar (Central Line)	Central Line	t	49	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
8fc06773-6463-497f-82e3-23f8a4891e14	ghatkopar_central_line	Ghatkopar (Central Line)	Central Line	t	50	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
b465b7a2-57e4-453d-8ec6-528e8bdeb789	vikhroli_central_line	Vikhroli (Central Line)	Central Line	t	51	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
ca50eb41-e068-4866-875b-302c4866634e	kanjurmarg_central_line	Kanjurmarg (Central Line)	Central Line	t	52	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
403af888-0eb5-4bec-9632-9b5cb0786bda	bhandup_central_line	Bhandup (Central Line)	Central Line	t	53	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
49d9eb4e-327f-4428-bb05-b2af33ae65b8	nahur_central_line	Nahur (Central Line)	Central Line	t	54	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
808e3805-6b3a-4546-ab03-b00ed270f952	mulund_central_line	Mulund (Central Line)	Central Line	t	55	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
680258f0-3445-4aaf-880c-a2130b135474	thane_central_line	Thane (Central Line)	Central Line	t	56	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
5868d2dc-9191-41ed-a534-5e3d9ba294ca	kalwa_central_line	Kalwa (Central Line)	Central Line	t	57	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
a0d5cd46-ad11-4fad-8252-66b7a470c056	mumbra_central_line	Mumbra (Central Line)	Central Line	t	58	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
e7aa6a52-0d08-4456-a6a0-365f4ff5c62f	diva_central_line	Diva (Central Line)	Central Line	t	59	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
83cd2cf4-3300-48be-9cd4-2c648fb2e388	kopar_central_line	Kopar (Central Line)	Central Line	t	60	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
d94dd838-3138-4f58-b861-a09fa250ca12	dombivli_central_line	Dombivli (Central Line)	Central Line	t	61	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
9b753ac7-c6db-417c-bd5b-1f25a789627e	thakurli_central_line	Thakurli (Central Line)	Central Line	t	62	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
0b1c9cac-e84c-4a74-a2a1-baf3cf8b1bc5	kalyan_central_line	Kalyan (Central Line)	Central Line	t	63	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
819a89b1-ce2d-4cf6-abda-a62b3d1ffd04	shahad_central_line	Shahad (Central Line)	Central Line	t	64	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
9e511da8-d94d-499e-96ec-cd109522adfd	ambivli_central_line	Ambivli (Central Line)	Central Line	t	65	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
de1b6711-424d-4301-8401-7703e6c254b1	titwala_central_line	Titwala (Central Line)	Central Line	t	66	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
7d59f6ce-316f-4704-be36-830b086a5c48	khadavli_central_line	Khadavli (Central Line)	Central Line	t	67	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
a46e5fe4-6857-4da4-ac58-6b0bc0d8ae5a	vasind_central_line	Vasind (Central Line)	Central Line	t	68	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
d361e448-c43e-463c-867c-f8be15412f33	asangaon_central_line	Asangaon (Central Line)	Central Line	t	69	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
05e28de0-730b-444c-8fe4-5897beead6a5	atgaon_central_line	Atgaon (Central Line)	Central Line	t	70	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
22e14110-d0d3-4487-89c7-a4092c038439	thansit_central_line	Thansit (Central Line)	Central Line	t	71	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
d52ec5a7-4180-4468-af86-fc73faf839cf	khardi_central_line	Khardi (Central Line)	Central Line	t	72	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
93e8a4fe-7789-4306-9c84-ab893dfb575e	umbermali_central_line	Umbermali (Central Line)	Central Line	t	73	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
00fd0b4b-57b2-4fcb-a1cb-bc47887d7a9b	kasara_central_line	Kasara (Central Line)	Central Line	t	74	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
79df8693-3230-472b-99fa-cb70c7c4087d	vithalwadi_central_line	Vithalwadi (Central Line)	Central Line	t	75	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
f1f97138-2c62-4b54-98a6-72d0d308a9e5	ulhasnagar_central_line	Ulhasnagar (Central Line)	Central Line	t	76	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
405fc369-a8d5-4b28-bded-e8d0b02bc370	ambernath_central_line	Ambernath (Central Line)	Central Line	t	77	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
cc670b6b-887d-48b0-afae-52943342cbca	badlapur_central_line	Badlapur (Central Line)	Central Line	t	78	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
ab376b29-b3ae-4031-b8eb-a743b5ee99e3	vangani_central_line	Vangani (Central Line)	Central Line	t	79	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
4015d98e-567f-48b9-937a-30731fbb0443	shelu_central_line	Shelu (Central Line)	Central Line	t	80	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
1139c71c-b701-4bfc-b2a1-f48bf05b4928	neral_central_line	Neral (Central Line)	Central Line	t	81	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
595fb84f-5430-4758-98cc-726c0d506999	bhivpuri_road_central_line	Bhivpuri Road (Central Line)	Central Line	t	82	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
03699bbe-284e-4057-b4e3-a1c77319f509	karjat_central_line	Karjat (Central Line)	Central Line	t	83	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
5a678029-475c-479d-bff1-891ee39cc49d	palasdari_central_line	Palasdari (Central Line)	Central Line	t	84	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
87aad8ab-5bce-49a5-8c5a-08325794f46b	kelavli_central_line	Kelavli (Central Line)	Central Line	t	85	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
fac51eeb-5224-4429-a7f7-665851d73d33	dolavli_central_line	Dolavli (Central Line)	Central Line	t	86	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
0812d76f-b767-4b7c-8db7-621656706dfc	lowjee_central_line	Lowjee (Central Line)	Central Line	t	87	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
83344131-d160-4304-9ede-203f0967a051	khopoli_central_line	Khopoli (Central Line)	Central Line	t	88	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
1a3e64c7-d560-4912-b29b-eed1cfa12d19	csmt_harbour_line	CSMT (Harbour Line)	Harbour Line	t	89	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
17621f29-78a8-4ee4-88d1-91d64a3739eb	masjid_harbour_line	Masjid (Harbour Line)	Harbour Line	t	90	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
28c656db-dcb7-4976-a87b-aad833f4b531	sandhurst_road_harbour_line	Sandhurst Road (Harbour Line)	Harbour Line	t	91	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
a4edf344-c2cf-4cd5-863a-b66e0a975dba	dockyard_road_harbour_line	Dockyard Road (Harbour Line)	Harbour Line	t	92	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
15aa7d7e-ba10-48dc-b2de-0b1fdb584eef	reay_road_harbour_line	Reay Road (Harbour Line)	Harbour Line	t	93	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
fbfdc4b8-7968-4461-bb2d-ade3de2b6e2f	cotton_green_harbour_line	Cotton Green (Harbour Line)	Harbour Line	t	94	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
851f6cba-b238-4f80-9579-7aa499a669ec	sewri_harbour_line	Sewri (Harbour Line)	Harbour Line	t	95	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
d1db39ea-28b4-4563-88dc-022c36206a6c	vadala_road_harbour_line	Vadala Road (Harbour Line)	Harbour Line	t	96	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
e52f3ca4-df45-4546-a10b-97079fe9479e	kings_circle_harbour_line	Kings Circle (Harbour Line)	Harbour Line	t	97	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
8e4a8076-c104-4b30-872e-30e932338cd5	gtb_nagar_harbour_line	GTB Nagar (Harbour Line)	Harbour Line	t	98	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
d990cdd0-3acd-445d-aec8-cc4895b8b8a3	chunabhatti_harbour_line	Chunabhatti (Harbour Line)	Harbour Line	t	99	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
0cd82733-f2ab-4ff1-bb6e-c72d658d4868	kurla_harbour_line	Kurla (Harbour Line)	Harbour Line	t	100	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
4470aef4-6736-4156-86df-28e875ed5aad	tilak_nagar_harbour_line	Tilak Nagar (Harbour Line)	Harbour Line	t	101	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
2dfe1ea3-ab2f-402d-b5fe-362da4fa79f8	chembur_harbour_line	Chembur (Harbour Line)	Harbour Line	t	102	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
b5a9353a-059a-4e4d-ae0a-e50b8ae3d8bd	govandi_harbour_line	Govandi (Harbour Line)	Harbour Line	t	103	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
a22fde2f-af75-42b2-8e9a-a5f0ae329649	mankhurd_harbour_line	Mankhurd (Harbour Line)	Harbour Line	t	104	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
41ab877d-9bad-4639-9384-369c02dec896	vashi_harbour_line	Vashi (Harbour Line)	Harbour Line	t	105	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
6b7b2d3b-783b-4b5c-82ef-ce541414a3f4	sanpada_harbour_line	Sanpada (Harbour Line)	Harbour Line	t	106	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
0885c10a-d971-4102-a935-6355a2821ada	juinagar_harbour_line	Juinagar (Harbour Line)	Harbour Line	t	107	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
ba5e6a63-a4b2-47f9-a0cb-0e1b02fd272b	nerul_harbour_line	Nerul (Harbour Line)	Harbour Line	t	108	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
532d7dbb-234c-4ebe-9f8b-15b16e07036f	seawoods_darave_harbour_line	Seawoods-Darave (Harbour Line)	Harbour Line	t	109	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
011b0588-dd0d-4841-b691-3ee97c18dfb2	cbd_belapur_harbour_line	CBD Belapur (Harbour Line)	Harbour Line	t	110	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
19c379a9-7aed-4c02-95c8-12d2abee6b2c	kharghar_harbour_line	Kharghar (Harbour Line)	Harbour Line	t	111	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
32a442e6-f7f4-411e-bc98-806e3f3ea374	mansarovar_harbour_line	Mansarovar (Harbour Line)	Harbour Line	t	112	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
bc3c4ec2-cb9e-424f-a720-bfd108c09b2d	khandeshwar_harbour_line	Khandeshwar (Harbour Line)	Harbour Line	t	113	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
65d5d4c0-f88c-47a3-8c1a-150f3d198d61	panvel_harbour_line	Panvel (Harbour Line)	Harbour Line	t	114	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
12f9b271-e82a-4e54-a026-e2b24a688bc1	thane_trans_harbour_line	Thane (Trans-Harbour Line)	Trans-Harbour Line	t	115	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
ab1a6785-3a51-4eec-b944-52ffedfb2ecb	digha_gaon_trans_harbour_line	Digha Gaon (Trans-Harbour Line)	Trans-Harbour Line	t	116	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
bc3bfc34-01a3-4c66-bf96-fe203a007692	airoli_trans_harbour_line	Airoli (Trans-Harbour Line)	Trans-Harbour Line	t	117	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
2f58411c-ecfb-4d38-907d-2898675d913d	rabale_trans_harbour_line	Rabale (Trans-Harbour Line)	Trans-Harbour Line	t	118	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
8dc4e2f6-7cb0-4b06-8fee-ff451cfe3778	ghansoli_trans_harbour_line	Ghansoli (Trans-Harbour Line)	Trans-Harbour Line	t	119	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
fa93d47b-4401-49d0-ac56-9640fae57c62	kopar_khairane_trans_harbour_line	Kopar Khairane (Trans-Harbour Line)	Trans-Harbour Line	t	120	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
3266d4aa-82e3-4d59-9a5d-264aa288f2c2	turbhe_trans_harbour_line	Turbhe (Trans-Harbour Line)	Trans-Harbour Line	t	121	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
33a61ddb-66c8-4d74-bb77-850b58fc8d70	sanpada_trans_harbour_line	Sanpada (Trans-Harbour Line)	Trans-Harbour Line	t	122	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
1e0ab980-8f78-44da-a84f-6a0a670b2ab2	vashi_trans_harbour_line	Vashi (Trans-Harbour Line)	Trans-Harbour Line	t	123	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
6f53403d-431d-4fbc-a280-c3fcef5902d2	juinagar_trans_harbour_line	Juinagar (Trans-Harbour Line)	Trans-Harbour Line	t	124	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
2df2e31a-7d03-467b-9a6d-5bf2111b0066	nerul_trans_harbour_line	Nerul (Trans-Harbour Line)	Trans-Harbour Line	t	125	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
5e852901-34fc-427c-8078-b983bde00595	seawoods_darave_trans_harbour_line	Seawoods-Darave (Trans-Harbour Line)	Trans-Harbour Line	t	126	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
3f3d276a-317e-4ac4-962a-968cff8de665	cbd_belapur_trans_harbour_line	CBD Belapur (Trans-Harbour Line)	Trans-Harbour Line	t	127	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
196262d4-9a4e-4158-a3a6-60babccaf66b	panvel_trans_harbour_line	Panvel (Trans-Harbour Line)	Trans-Harbour Line	t	128	2026-10-10 12:26:25.008136+05:30	\N	\N	\N	\N
085f5e38-ecf0-4362-87e2-33b348b0a938	zz_probe_city	ZZ Probe City	Probe Line	f	129	2026-10-18 18:30:09.453122+05:30	2026-10-18 18:30:09.771013+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:30:09.771013+05:30
\.


--
-- Data for Name: mst_business_units; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_business_units ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
1ab2e67e-5e47-4f6d-8035-dd6a5c5f6b85	talakunchi_networks_private_limited	Talakunchi Networks Private Limited	t	1	2026-09-03 17:47:46.134222+05:30	\N	\N	\N	\N
8d074538-ddf6-4d28-894e-ef01ff8dbd9f	zz_probe_unit	ZZ Probe Unit	f	2	2026-10-18 18:30:09.292041+05:30	2026-10-18 18:30:09.693684+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:30:09.693684+05:30
9b7b8b3c-a2b7-4627-8489-adfe5f0059bd	zz_ui_probe_unit	ZZ UI Probe Unit Edited	f	3	2026-10-18 18:31:10.914455+05:30	2026-10-18 18:31:42.321832+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 18:31:42.321832+05:30
\.


--
-- Data for Name: mst_certifications; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
d20bc297-e08b-4694-aa66-2d2b9fb83c2c	zz_probe_cert	ZZ Probe Cert	f	2026-10-18 18:30:09.427314+05:30	2026-10-18 18:30:09.755834+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:30:09.755834+05:30
\.


--
-- Data for Name: mst_cities; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
24749751-d539-4881-b91d-32a9b4dbae45	89	Testing mumbai	t	1f7dfdc6-768e-4227-8536-4fd280141d03	2026-10-18 15:33:14.25146+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
08a60e15-809d-4e3b-8add-82ddc53f77ed	TESTCITY	test city	t	f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0	2026-10-18 15:55:02.72587+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: mst_contact_designations; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_contact_designations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
301bc813-b2a8-487e-8645-6d613260a7e7	cio	CIO	t	3	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
36d0dd25-0888-4933-b7ec-1ffb839a50bd	cfo	CFO	t	4	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
4289316a-ac66-4577-93b2-b27a1f631bd7	ciso	CISO	t	2	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
634aee41-eb57-41e4-b296-af2a255a7e79	accounts_head	Accounts Head	t	5	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
8a02dfd7-d731-4231-8eba-29f36d2254c7	spoc	SPOC	t	1	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
933ad32d-02a3-4727-ac62-34f2c9ea0d0e	SPOC2	SPOC 2	f	6	2026-10-18 15:32:22.563596+05:30	2026-10-18 15:35:15.669759+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 15:35:15.669759+05:30
3039b17d-83f5-42c4-a26c-359a3d35502a	DESGTEST	Desg Test	t	7	2026-10-18 15:53:39.063418+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: mst_contact_types; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_contact_types ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
58db2f92-2db9-46a1-ae8a-f04a3c7cf54c	legal	Legal	t	4	2026-09-09 13:09:28.906477+05:30	\N	\N	\N	\N
670b9a05-6ee2-488e-962c-51cf3cdb86fa	procurement	Procurement	t	2	2026-09-09 13:09:28.906477+05:30	\N	\N	\N	\N
6ddcfdba-7311-4f61-b285-88e09a772497	accounts	Accounts	t	1	2026-09-09 13:09:28.906477+05:30	\N	\N	\N	\N
b28647ac-40d2-449e-b90c-b71cbae83f8d	technical	Technical	t	3	2026-09-09 13:09:28.906477+05:30	\N	\N	\N	\N
38ead690-dc4e-4ba1-b830-228c184bcd66	LEGAL2	Legal 2	f	5	2026-10-18 15:33:24.899562+05:30	2026-10-18 15:35:55.982374+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 15:35:55.982374+05:30
fce7509c-4c38-4afb-b889-8ad5a6474f39	TESTCNT	Test cnt	t	6	2026-10-18 15:54:42.875996+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: mst_countries; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") FROM stdin;
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
1f7dfdc6-768e-4227-8536-4fd280141d03	TESTI	Testing country	t	2026-10-18 15:32:47.856163+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	+91	10
f20c0081-5dae-4dcd-b1b0-b40f46f10c48	TESTC	test country	t	2026-10-18 15:55:24.74245+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	+91	10
\.


--
-- Data for Name: mst_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
36d04440-a8bb-47f1-a6d9-1f4d144b0bdb	x36d04440	retired 36d04440 ZZ Probe Department	f	2026-10-18 18:30:09.499474+05:30	2026-10-18 18:30:09.799922+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:30:09.799912+05:30
40fed4c8-89b7-4276-b4ef-47fe8cf1ea87	x40fed4c8	retired 40fed4c8 ZZ UI Department	f	2026-10-18 18:32:39.916388+05:30	2026-10-18 18:32:54.816575+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 18:32:54.816554+05:30
316c6b23-b976-4e7f-ae22-c8ea15c365cb	x316c6b23	retired 316c6b23 ZZ Sub Dept	f	2026-10-18 18:43:54.032822+05:30	2026-10-18 18:43:54.123387+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:43:54.123373+05:30
abe592cb-6742-45f7-889e-4d4ca0b5e648	D_5f63b760	Dept_5f63b760	t	2026-11-16 17:34:22.873924+05:30	2026-11-16 17:34:22.874001+05:30	\N	\N	\N
6b9e6023-1248-489f-836a-1e39ad098691	D_dbf8b5a6	Dept_dbf8b5a6	t	2026-11-16 17:34:23.716592+05:30	2026-11-16 17:34:23.716592+05:30	\N	\N	\N
831edc4d-cc80-437d-b103-0a9f2ffd25af	D_fc2ee217	Dept_fc2ee217	t	2026-11-16 17:34:23.881733+05:30	2026-11-16 17:34:23.881733+05:30	\N	\N	\N
12b2cae0-dc54-4fa7-8f83-132d7d0ce86b	D_7748c71a	Dept_7748c71a	t	2026-11-16 17:34:24.213464+05:30	2026-11-16 17:34:24.213464+05:30	\N	\N	\N
f3005225-a8e0-4d26-a3e8-0ef3911b30d2	D_b6febf29	Dept_b6febf29	t	2026-11-16 17:34:24.250354+05:30	2026-11-16 17:34:24.250354+05:30	\N	\N	\N
6bc123eb-1c25-4757-829c-bc2de2b7e7d6	D_715a83a2	Dept_715a83a2	t	2026-11-16 17:34:24.359461+05:30	2026-11-16 17:34:24.359461+05:30	\N	\N	\N
290118f3-e84e-42a2-ba41-36afbb9aab25	D_c3668e15	Dept_c3668e15	t	2026-11-16 17:34:24.617935+05:30	2026-11-16 17:34:24.617935+05:30	\N	\N	\N
374cee8b-d543-4a49-b846-aaea8c5e6406	D_c95beecf	Dept_c95beecf	t	2026-11-16 17:34:24.698107+05:30	2026-11-16 17:34:24.698108+05:30	\N	\N	\N
874bfd76-38b4-42cc-96a4-31b797582415	D_0f63c9dd	Dept_0f63c9dd	t	2026-11-16 17:34:24.764972+05:30	2026-11-16 17:34:24.764972+05:30	\N	\N	\N
f6a9b759-c7f8-40bf-a023-de85a937ba99	D_beaee48a	Dept_beaee48a	t	2026-11-16 17:34:24.817826+05:30	2026-11-16 17:34:24.817826+05:30	\N	\N	\N
e2f0b55b-5783-45bc-a339-ac04dc8a6098	D_676a789d	Dept_676a789d	t	2026-11-16 17:34:24.894052+05:30	2026-11-16 17:34:24.894052+05:30	\N	\N	\N
720e015d-20da-4626-b8f6-9c1d97511c20	D_cd232cc2	Dept_cd232cc2	t	2026-11-16 17:35:49.63483+05:30	2026-11-16 17:35:49.634831+05:30	\N	\N	\N
5e28f925-3640-4e16-b45c-c6a0a49ea098	D_4d1ed200	Dept_4d1ed200	t	2026-11-16 17:35:50.053669+05:30	2026-11-16 17:35:50.053669+05:30	\N	\N	\N
7411036b-fe99-498a-b82a-c6cc8390f36a	D_0e1c6462	Dept_0e1c6462	t	2026-11-16 17:35:50.189535+05:30	2026-11-16 17:35:50.189535+05:30	\N	\N	\N
01bc043c-05eb-4798-b19e-8bcacc1f36b3	D_c03ed08c	Dept_c03ed08c	t	2026-11-16 17:35:50.853396+05:30	2026-11-16 17:35:50.853396+05:30	\N	\N	\N
35bec427-7f74-48ba-abe9-fcb903d61f0c	D_3a934cb8	Dept_3a934cb8	t	2026-11-16 17:35:50.985893+05:30	2026-11-16 17:35:50.985894+05:30	\N	\N	\N
265e1f1a-fc38-45a4-83bd-af37560387b4	D_0349923a	Dept_0349923a	t	2026-11-16 17:35:51.327007+05:30	2026-11-16 17:35:51.327007+05:30	\N	\N	\N
c29f539b-083b-47d8-a2e1-8c3628c4d779	D_08ed1c42	Dept_08ed1c42	t	2026-11-16 17:35:52.127876+05:30	2026-11-16 17:35:52.127876+05:30	\N	\N	\N
903b8f99-b6a7-4464-930e-4a79dc51cd15	D_21b57dbf	Dept_21b57dbf	t	2026-11-16 17:35:52.36508+05:30	2026-11-16 17:35:52.36508+05:30	\N	\N	\N
75de5ed9-d940-4948-a8a2-f307552ad45b	D_0f25ec72	Dept_0f25ec72	t	2026-11-16 17:35:52.509816+05:30	2026-11-16 17:35:52.509817+05:30	\N	\N	\N
e3b2f30d-4062-4bf3-ba14-b0240b69526b	D_71a58b59	Dept_71a58b59	t	2026-11-16 17:35:52.62677+05:30	2026-11-16 17:35:52.62677+05:30	\N	\N	\N
9ec562c0-965c-477c-a01e-256c998a1c4b	D_ba09cf4b	Dept_ba09cf4b	t	2026-11-16 17:35:52.768398+05:30	2026-11-16 17:35:52.768398+05:30	\N	\N	\N
6531ab90-4e51-4509-b0f2-3a5ee17e7037	D_610d6375	Dept_610d6375	t	2026-11-16 17:41:29.912677+05:30	2026-11-16 17:41:29.912722+05:30	\N	\N	\N
5fbf7cd7-5bd9-4cdd-9baf-e6bfcee52eb6	D_f7ae69f2	Dept_f7ae69f2	t	2026-11-16 17:41:30.79537+05:30	2026-11-16 17:41:30.79537+05:30	\N	\N	\N
aef18c44-bf09-4a99-8873-889a442c64f1	D_18f05b15	Dept_18f05b15	t	2026-11-16 17:41:30.94708+05:30	2026-11-16 17:41:30.94708+05:30	\N	\N	\N
8ca3354b-b1be-419b-b47e-0a4a1a982f4e	D_7355011e	Dept_7355011e	t	2026-11-16 17:41:31.229505+05:30	2026-11-16 17:41:31.229505+05:30	\N	\N	\N
2dea6534-9167-4e16-8c93-eb723f28b664	D_d30708c3	Dept_d30708c3	t	2026-11-16 17:41:31.27179+05:30	2026-11-16 17:41:31.27179+05:30	\N	\N	\N
d8bfc9e0-2f7c-4c97-b65b-609c79ed1c5b	D_6aafe861	Dept_6aafe861	t	2026-11-16 17:41:31.394356+05:30	2026-11-16 17:41:31.394356+05:30	\N	\N	\N
6532964e-c117-4fdd-917f-7260fd8a9ad8	D_af50b386	Dept_af50b386	t	2026-11-16 17:41:31.677645+05:30	2026-11-16 17:41:31.677645+05:30	\N	\N	\N
794f910e-4e82-4861-9821-b6e3c6be5cb9	D_017672eb	Dept_017672eb	t	2026-11-16 17:41:31.764804+05:30	2026-11-16 17:41:31.764804+05:30	\N	\N	\N
89298bcc-999e-4144-942c-048886435ab0	D_8e3848b5	Dept_8e3848b5	t	2026-11-16 17:41:31.837553+05:30	2026-11-16 17:41:31.837553+05:30	\N	\N	\N
74f871a0-cb2f-4425-ac81-1b62d0c9e053	D_9f27378e	Dept_9f27378e	t	2026-11-16 17:41:31.894968+05:30	2026-11-16 17:41:31.894968+05:30	\N	\N	\N
33633a35-7e72-42e7-9a83-c1b393a0da18	D_eb971ede	Dept_eb971ede	t	2026-11-16 17:41:31.971013+05:30	2026-11-16 17:41:31.971013+05:30	\N	\N	\N
d8d1c1b8-6c1d-410e-8c50-8da3787b3daf	D_4ad97aab	Dept_4ad97aab	t	2026-11-16 17:47:43.949311+05:30	2026-11-16 17:47:43.949343+05:30	\N	\N	\N
bdf785dd-1890-456f-918b-e9bf23f6bd5d	D_e37f9f5b	Dept_e37f9f5b	t	2026-11-16 17:47:44.697024+05:30	2026-11-16 17:47:44.697024+05:30	\N	\N	\N
bb448431-e2e1-489d-a82c-67daf4a507d0	D_94fe0091	Dept_94fe0091	t	2026-11-16 17:47:44.843001+05:30	2026-11-16 17:47:44.843001+05:30	\N	\N	\N
22df3ab8-dfff-4dac-b473-4512e6c4e5f9	D_6afd200f	Dept_6afd200f	t	2026-11-16 17:47:45.087165+05:30	2026-11-16 17:47:45.087165+05:30	\N	\N	\N
27010cbf-8cfe-41e7-8738-c06864f2de7f	D_0a11f446	Dept_0a11f446	t	2026-11-16 17:47:45.126637+05:30	2026-11-16 17:47:45.126637+05:30	\N	\N	\N
1a529446-8714-4b5c-86cc-e407f114c8d7	D_f089a31b	Dept_f089a31b	t	2026-11-16 17:47:45.24877+05:30	2026-11-16 17:47:45.24877+05:30	\N	\N	\N
e3d0d9db-c52a-40cc-a4ce-0726040a3b1a	D_72d283fa	Dept_72d283fa	t	2026-11-16 17:47:45.502329+05:30	2026-11-16 17:47:45.502329+05:30	\N	\N	\N
b678a28c-bc45-4d06-8019-a21302b0ec9e	D_acd6cdf1	Dept_acd6cdf1	t	2026-11-16 17:47:45.578228+05:30	2026-11-16 17:47:45.578228+05:30	\N	\N	\N
1aaf98ae-a8a9-4483-a6bf-5c47666527e4	D_b9db340a	Dept_b9db340a	t	2026-11-16 17:47:45.640175+05:30	2026-11-16 17:47:45.640175+05:30	\N	\N	\N
229c8198-9138-4202-a046-c62a526187d7	D_1b90b043	Dept_1b90b043	t	2026-11-16 17:47:45.688669+05:30	2026-11-16 17:47:45.688669+05:30	\N	\N	\N
d79ba597-dee0-4084-88c8-5f2be439446f	D_d555667e	Dept_d555667e	t	2026-11-16 17:47:45.758734+05:30	2026-11-16 17:47:45.758734+05:30	\N	\N	\N
85086053-66aa-4362-be10-01a221ed181d	D_10401981	Dept_10401981	t	2026-11-16 18:09:30.112924+05:30	2026-11-16 18:09:30.112968+05:30	\N	\N	\N
6a84f6a7-a299-4de5-9704-973418f07662	D_1c9c1876	Dept_1c9c1876	t	2026-11-16 18:09:30.86133+05:30	2026-11-16 18:09:30.86133+05:30	\N	\N	\N
8eb1ce52-c09f-4301-a448-4b03e748ce00	D_537180dc	Dept_537180dc	t	2026-11-16 18:09:30.991086+05:30	2026-11-16 18:09:30.991086+05:30	\N	\N	\N
da3a6c05-a521-4a7e-8495-15b50fa4f3f8	D_ed55976c	Dept_ed55976c	t	2026-11-16 18:09:31.247377+05:30	2026-11-16 18:09:31.247377+05:30	\N	\N	\N
06860ea2-6a18-4e8e-82c6-5f4f7b635296	D_c70bc377	Dept_c70bc377	t	2026-11-16 18:09:31.281897+05:30	2026-11-16 18:09:31.281897+05:30	\N	\N	\N
23957b99-1418-4a58-b9f6-25305ead38b0	D_49a43d08	Dept_49a43d08	t	2026-11-16 18:09:31.38681+05:30	2026-11-16 18:09:31.38681+05:30	\N	\N	\N
85224703-01dc-45a7-a592-a1528696fdf1	D_0f9ab9d4	Dept_0f9ab9d4	t	2026-11-16 18:09:31.630077+05:30	2026-11-16 18:09:31.630077+05:30	\N	\N	\N
52ab67a9-3d17-42e6-9649-3abb4f586ef7	D_02742f21	Dept_02742f21	t	2026-11-16 18:09:31.707525+05:30	2026-11-16 18:09:31.707525+05:30	\N	\N	\N
3a913306-2b53-4173-abb6-d80d0034b8d5	D_f5a4d6a6	Dept_f5a4d6a6	t	2026-11-16 18:09:31.773788+05:30	2026-11-16 18:09:31.773788+05:30	\N	\N	\N
4f942518-07e0-4c26-8f49-0f804903126e	D_b5cdd1f8	Dept_b5cdd1f8	t	2026-11-16 18:09:31.825172+05:30	2026-11-16 18:09:31.825172+05:30	\N	\N	\N
a901acd6-85e2-47ff-acda-9ab48eb552d4	D_8ea6f2db	Dept_8ea6f2db	t	2026-11-16 18:09:31.894542+05:30	2026-11-16 18:09:31.894542+05:30	\N	\N	\N
a2b80f55-67fe-46b1-860c-3318d5a0bc07	D_cbce0ca0	Dept_cbce0ca0	t	2026-11-16 18:18:49.196957+05:30	2026-11-16 18:18:49.196958+05:30	\N	\N	\N
96c07cbf-f70c-414e-afcb-5857f03f0eb0	D_163a2050	Dept_163a2050	t	2026-11-16 18:18:49.288715+05:30	2026-11-16 18:18:49.288715+05:30	\N	\N	\N
6d0277e9-2779-443d-9892-166e4d308cd9	D_73c1240c	Dept_73c1240c	t	2026-11-16 18:18:49.328216+05:30	2026-11-16 18:18:49.328216+05:30	\N	\N	\N
739431ab-07d5-4c15-8ac1-710ce3281ac7	D_45104188	Dept_45104188	t	2026-11-16 18:18:49.457448+05:30	2026-11-16 18:18:49.457448+05:30	\N	\N	\N
08c4d08a-4ec5-46c7-924f-17a79fc31633	D_1d707bc8	Dept_1d707bc8	t	2026-11-16 18:18:49.478932+05:30	2026-11-16 18:18:49.478932+05:30	\N	\N	\N
a002408c-93a5-4d06-9d52-9fd88d8b6154	D_cfa49c50	Dept_cfa49c50	t	2026-11-16 18:18:49.549751+05:30	2026-11-16 18:18:49.549751+05:30	\N	\N	\N
25c207ee-081c-4ea0-9715-0181c9e20699	D_fa24d789	Dept_fa24d789	t	2026-11-16 18:18:49.729961+05:30	2026-11-16 18:18:49.729961+05:30	\N	\N	\N
2d7a7f5b-ba4b-4210-8b16-69f81df57b31	D_03984918	Dept_03984918	t	2026-11-16 18:18:49.786297+05:30	2026-11-16 18:18:49.786297+05:30	\N	\N	\N
811e7e02-34b7-44d2-aedf-f3f1341c8870	D_40861032	Dept_40861032	t	2026-11-16 18:18:49.832673+05:30	2026-11-16 18:18:49.832673+05:30	\N	\N	\N
7b975a68-1f64-4a99-9ec7-409511f77e22	D_52bc275f	Dept_52bc275f	t	2026-11-16 18:18:49.870218+05:30	2026-11-16 18:18:49.870218+05:30	\N	\N	\N
860f4838-adfc-4b25-8558-8b63f492aa52	D_bfca00b8	Dept_bfca00b8	t	2026-11-16 18:18:49.926501+05:30	2026-11-16 18:18:49.926501+05:30	\N	\N	\N
1e5a4682-283c-48f0-956e-665ff58de66e	D_a1a9a7ba	Dept_a1a9a7ba	t	2026-11-16 19:00:22.783905+05:30	2026-11-16 19:00:22.783905+05:30	\N	\N	\N
b5700263-646f-4207-b520-c102e51abc81	D_c8c893de	Dept_c8c893de	t	2026-11-16 19:00:23.227666+05:30	2026-11-16 19:00:23.227667+05:30	\N	\N	\N
df62a8da-0fa6-46bc-9705-fe2e3f329eed	D_09edf615	Dept_09edf615	t	2026-11-16 19:00:23.403488+05:30	2026-11-16 19:00:23.403488+05:30	\N	\N	\N
5652a6fb-8516-48db-aed0-b04d93d5df65	D_20d478b0	Dept_20d478b0	t	2026-11-16 19:00:23.986601+05:30	2026-11-16 19:00:23.986601+05:30	\N	\N	\N
5f82bfd3-7909-4677-9748-16634c6797bb	D_297bbff5	Dept_297bbff5	t	2026-11-16 19:00:24.065643+05:30	2026-11-16 19:00:24.065644+05:30	\N	\N	\N
4f22d730-76df-4e66-b474-a38f75ab628a	D_9a20e0b3	Dept_9a20e0b3	t	2026-11-16 19:00:24.435574+05:30	2026-11-16 19:00:24.435574+05:30	\N	\N	\N
5aebebe9-24d8-4e23-bbf5-cd4968668257	D_1990bb17	Dept_1990bb17	t	2026-11-16 19:00:25.247516+05:30	2026-11-16 19:00:25.247517+05:30	\N	\N	\N
bac823bc-25a0-43ec-bd4e-0a31040ea7a9	D_62cc5978	Dept_62cc5978	t	2026-11-16 19:00:25.670043+05:30	2026-11-16 19:00:25.670044+05:30	\N	\N	\N
c9de9c8a-0513-489e-b744-b6e69159d5a9	D_aeec4e1e	Dept_aeec4e1e	t	2026-11-16 19:00:26.00638+05:30	2026-11-16 19:00:26.006381+05:30	\N	\N	\N
61d2f8b1-301a-425b-ad47-8a045caf61d2	D_a9b80128	Dept_a9b80128	t	2026-11-16 19:00:26.238881+05:30	2026-11-16 19:00:26.238882+05:30	\N	\N	\N
2084052c-3bc4-460f-9260-f3c5a41f4216	D_c57b3e28	Dept_c57b3e28	t	2026-11-16 19:00:26.682658+05:30	2026-11-16 19:00:26.682658+05:30	\N	\N	\N
\.


--
-- Data for Name: mst_designation_sub_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_designation_sub_departments ("Id", "DesignationId", "SubDepartmentId") FROM stdin;
00131b75-5772-4034-8ddf-0a4c6fbe769f	163d8c87-8f90-4295-a926-2e912c625a1c	682d36c0-4256-42ab-811e-054ab3a5b10f
01375e5a-8fa0-48ed-bf93-3d893ecc38f1	b5f39dd8-c305-489d-9f7d-9adfd010a134	cfdb2071-d50e-4ea3-b732-19eb08f1e629
055ee530-8efc-4caa-af29-d255da8026d6	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	e99b7773-5d71-4dca-ad36-b896dcfb71c4
06512abf-0f54-4202-94dd-27f54d291810	1f97b442-95c5-4b11-93a0-ea146534ae85	5d962383-f175-4dd8-af63-8a566a0d2255
06b666ca-e2bc-48c4-95f1-a08f547e44f7	e4e20503-cd55-4393-83fd-6c7e7d7d0a49	c88d783b-b628-4f3a-a972-aa56aeed5e77
0723054b-5e90-47c4-881d-c67b2784308b	155642eb-a633-4460-b658-aca9fde2d817	5d962383-f175-4dd8-af63-8a566a0d2255
0766fd8d-7b5b-44e7-870f-3891f79e7a0e	9050e021-7d84-4401-820e-c0e768abb1ab	a73eb36c-7d62-4aa8-901d-1c70b3876b69
0d8499ee-422e-48e2-936a-b3adb8b5cf56	834c9e15-c70d-4a0b-bb12-5e55f23c181d	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
0e319323-1db3-4289-b604-f61ba8822621	bb7ccd5f-2f60-49fb-b984-f11fc47add22	7682acb3-561b-4951-801b-c1564adda131
0e9ee3df-3a89-4e7e-b358-316894998bc9	e8c22eff-0daf-4690-a537-c8b0b6110a01	c88d783b-b628-4f3a-a972-aa56aeed5e77
12983ebd-a851-416e-86e4-dd9d94dd3902	e2b10def-c91d-45da-94c5-f5530e743aa2	fa773eb9-162f-4ea8-9fc4-9c54a3068582
1859fa0e-d1d8-41fd-a0e5-e44539f243d0	168d11d7-ca26-4d61-b870-51779dc63023	682d36c0-4256-42ab-811e-054ab3a5b10f
1997703e-7b34-4e35-9157-9a34dfab4f61	9858c224-f97f-4ff8-908d-f46bd5e2243c	e99b7773-5d71-4dca-ad36-b896dcfb71c4
1a07c1b7-e647-4104-9d63-9dc003f7698c	4ef1cb5b-9688-4ce2-95b3-6a0863200166	5d962383-f175-4dd8-af63-8a566a0d2255
1cc80438-90e2-4473-a190-5ead5c99d8c1	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	682d36c0-4256-42ab-811e-054ab3a5b10f
1ee71282-f7cc-447f-902a-4162cf628cbb	48429bb5-c583-4684-b30a-7ed443b671ca	cfdb2071-d50e-4ea3-b732-19eb08f1e629
217320df-4aef-4855-902c-ea30a5a0cc62	e2b4be77-2b20-4064-974d-e6322e7240b4	88b29e0c-39b7-4169-ab5c-350075014a84
21f61930-25f5-4279-9614-2f02988b5d43	3b7ea453-324e-40a0-bb41-77a0795d5af5	e99b7773-5d71-4dca-ad36-b896dcfb71c4
22d6a0d4-2b20-4ea3-b2a9-9a802737a99c	444df30d-c195-42ad-b9a7-d80cdef69ccd	cfdb2071-d50e-4ea3-b732-19eb08f1e629
243ef579-4b23-405f-9c6f-9277c3481b4f	0c1a5ef4-7fca-45dc-8253-87afa21a1df9	cfdb2071-d50e-4ea3-b732-19eb08f1e629
281f0067-06ee-4c42-a35c-58ab77ab8768	b2b687ef-fd62-4cb7-a826-b40a35da7b2c	fa773eb9-162f-4ea8-9fc4-9c54a3068582
28da058a-2325-459d-97e5-ee1710cfee05	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	db0addff-605e-439f-917b-38016a398755
297dbde1-1bae-4276-9c20-3e97b8c121b2	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	e99b7773-5d71-4dca-ad36-b896dcfb71c4
29aa37fd-dac1-4344-9840-292a6d1a66df	c0f974c3-f49c-449a-9276-aa64ce501344	cfdb2071-d50e-4ea3-b732-19eb08f1e629
3347095d-622e-4e3d-9433-5e5c049b537e	f20a7445-0b01-4f20-85a5-853101d864ee	cfdb2071-d50e-4ea3-b732-19eb08f1e629
3463d68c-4d98-4bbb-931b-f0d0b3deb4c2	73bd55bb-5d0e-4381-8ad2-2238377fca93	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
36a63317-0b1b-441b-8b5e-92e07356a799	c0e1a001-0000-4000-8000-000000000001	63765624-d7d1-472d-abd4-627127646998
383d62b9-b188-4206-8e34-f966b18f1fe0	3b7ea453-324e-40a0-bb41-77a0795d5af5	db0addff-605e-439f-917b-38016a398755
3d82b7e3-ec86-45a4-bc69-47832b37fbaf	138434a2-625f-4df5-836d-fcf0cfceef79	fd84aa38-11ef-46af-ade7-241f2a2c08fd
3e5ebada-a521-49b6-bc95-689769eb7b95	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	b651aec8-5455-4329-8251-0ceb62cea798
3fc0e0de-ea28-4b17-b068-4db835e82958	157d001c-b056-45b1-96a3-3c05bcd8d99c	fa773eb9-162f-4ea8-9fc4-9c54a3068582
3fdd0a29-2ef1-4bd4-b3e9-195e339f5199	a697a798-caaf-4248-8e4e-7e89096a9c30	e99b7773-5d71-4dca-ad36-b896dcfb71c4
4033ab27-dae5-4c58-be6d-0d750f63a58e	e36018c5-bf48-4f93-bef7-93e8864a0b51	cfdb2071-d50e-4ea3-b732-19eb08f1e629
4932547b-65c5-4df9-af86-1541d5aa87b2	4b680e29-b4fb-4689-9afb-67a7f089f52b	b651aec8-5455-4329-8251-0ceb62cea798
495323bc-59e9-4b76-ab2b-4f8efc7d805a	c2e248c8-e917-445f-9f7b-1e25d7bb5abe	c88d783b-b628-4f3a-a972-aa56aeed5e77
49729a6d-adb5-42b6-a4f9-0d0f61b8b467	3e60b693-d3dd-4481-95c4-9f02da21625c	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
49c22a8e-d5b4-4107-b0f7-09333af23906	e228c999-bf54-48b4-a373-d2bc9db88554	db0addff-605e-439f-917b-38016a398755
49dcbf61-1a92-45ea-8910-0088bc2bf549	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	cfdb2071-d50e-4ea3-b732-19eb08f1e629
4e4af32c-edb8-4ebf-ae24-c3b0df0f35d8	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	e99b7773-5d71-4dca-ad36-b896dcfb71c4
4eb7b428-38d8-4a4e-8e4c-f53f48dc6be1	2a76927c-461a-48e4-8190-dea7361ef3db	fd84aa38-11ef-46af-ade7-241f2a2c08fd
4f09e444-0059-49a2-9fa3-7a6a98744f38	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	682d36c0-4256-42ab-811e-054ab3a5b10f
4f343ba3-d6b0-4e3e-bd5d-4ee063800292	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	cfdb2071-d50e-4ea3-b732-19eb08f1e629
4f727373-a518-4c0c-83a7-78ff796356c8	85cc9fbe-98a4-464d-a638-05f40529c6de	b651aec8-5455-4329-8251-0ceb62cea798
5197e1b0-6374-44c1-a71b-3ba5c549d110	163d8c87-8f90-4295-a926-2e912c625a1c	e99b7773-5d71-4dca-ad36-b896dcfb71c4
5604faa5-2b81-41a8-9b2a-3ddb08adddf9	a697a798-caaf-4248-8e4e-7e89096a9c30	db0addff-605e-439f-917b-38016a398755
56206379-ed7c-4301-89e8-a39c0edf2d53	9858c224-f97f-4ff8-908d-f46bd5e2243c	682d36c0-4256-42ab-811e-054ab3a5b10f
56fbf6bd-3f84-4a49-a30e-764ba862ea3f	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	e99b7773-5d71-4dca-ad36-b896dcfb71c4
59f5f15c-9435-4fa1-801f-2945f1a7c7a4	6d25ff6d-e13d-440f-b775-215547af7acb	cfdb2071-d50e-4ea3-b732-19eb08f1e629
5b6bf991-d024-4b80-92cd-695dba1e275c	da990f6e-3379-4cc4-89b7-0ead29da472b	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
5c609a23-857a-410b-9797-fc97e63a5e31	e228c999-bf54-48b4-a373-d2bc9db88554	e99b7773-5d71-4dca-ad36-b896dcfb71c4
5ddcd589-0d37-4a0d-b717-7a0d75cb5809	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	db0addff-605e-439f-917b-38016a398755
61d55fd3-8bb3-4a4b-b919-33c23edfd407	7c2380da-3ee6-46ad-93d6-a79ce3027f29	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
62f1dcc5-1d3b-4d8f-8047-1709752ccc4e	168d11d7-ca26-4d61-b870-51779dc63023	db0addff-605e-439f-917b-38016a398755
634b7d64-cecb-48cf-9e67-a8428498cdaa	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	c88d783b-b628-4f3a-a972-aa56aeed5e77
6442f0aa-ead9-4fb9-bd8c-339e3291b9d1	8dc0d8fe-593d-422a-8b27-5b68fbe6d224	5d962383-f175-4dd8-af63-8a566a0d2255
72e7ec02-88e3-4734-ba90-1f73005b535d	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	cfdb2071-d50e-4ea3-b732-19eb08f1e629
760730dd-a61e-42a6-a7a7-d43267613cc2	195d6a81-8457-4b60-9382-6a3a0664f0e9	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
780e2f51-b178-455b-8494-5bcbebe42654	272973a6-c052-4aef-bf32-9e24f7eb6cc9	fa773eb9-162f-4ea8-9fc4-9c54a3068582
7bf8d358-120a-4066-91bd-a29f8a0a6910	1e7faab8-273d-40df-9f9a-485160186c5a	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
7dd7b4da-35dc-4045-b706-aac9a4b93199	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
8694b50c-15af-40c5-81c6-2f61109f75e0	b3309eea-7374-4a8d-ac13-481b2a7fd492	fd84aa38-11ef-46af-ade7-241f2a2c08fd
8abaee27-425e-422c-a7e7-47691eb07a18	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	db0addff-605e-439f-917b-38016a398755
8ca155c9-c1a7-4c40-b498-b8299b2cd4fc	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
8d4ef231-53e4-464b-8af4-7040b0e8abdd	8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	88b29e0c-39b7-4169-ab5c-350075014a84
8f2cf090-186c-4ca7-b572-e410a1540e53	9dc69952-eae6-4ec0-a327-67392315f089	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
93e569e0-91e4-493d-8279-3e909801416d	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	fa773eb9-162f-4ea8-9fc4-9c54a3068582
9585c448-6302-423a-a6e5-70ef078d5a3f	c1fa4328-a970-48a1-bc08-d50fe36bf44c	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
9b3af057-151b-4f5c-baa9-1e781e0bf710	ffed7aa1-e88f-4281-919f-8d49fbabf5a5	45755b2a-741a-4990-ab78-8f65090f75b1
9beeaf7d-b3ee-491e-a0bd-c4ea0db37ee5	778f1120-9633-4933-9160-ddaa46668838	a12ac80b-a665-4301-898e-e9ca3d44bb20
9e219264-78c8-45f4-a10e-08a7119b9ebf	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	db0addff-605e-439f-917b-38016a398755
a211beda-c8af-4bc4-9381-f08b7b614bc8	485012d4-2c28-4bc4-92c7-3609e3e3749e	c88d783b-b628-4f3a-a972-aa56aeed5e77
a6935639-5d1b-4e21-8f59-23a0863a03da	2b1558e3-158a-4a84-ae80-053129861a64	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
a8d075b7-9975-44fa-bc38-6c04d5f219b4	af8a1442-c5ee-409d-aa91-61c9dba852ee	cfdb2071-d50e-4ea3-b732-19eb08f1e629
ace21210-bbe4-407d-9d26-16f38cd6aaaf	4f972924-350a-47fb-a6b6-f2b34bb6b621	db0addff-605e-439f-917b-38016a398755
ad26fff7-ba36-4cc7-b73f-a33045b6ea9c	4f972924-350a-47fb-a6b6-f2b34bb6b621	682d36c0-4256-42ab-811e-054ab3a5b10f
ad6590a4-7c3a-4f85-be00-16ebd9ccd44c	f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	7682acb3-561b-4951-801b-c1564adda131
adf620a0-b6cf-4757-a83b-a3d576c0c531	8b57cfd5-5d4e-44a3-9646-b36873c111c2	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
af5eacc3-50b1-4ec5-9e29-0bd2060e0848	0525d830-ead9-44a0-871f-91b7845fec26	61bbeadf-3044-4123-929c-4b1e6e2e613e
b13e1f7c-2a04-41b1-b676-0a2abc9a87ba	163d8c87-8f90-4295-a926-2e912c625a1c	db0addff-605e-439f-917b-38016a398755
b68d0462-45ad-46c8-8b3d-242b5fdfc84e	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	cfdb2071-d50e-4ea3-b732-19eb08f1e629
b869fa98-54df-4c65-a097-3efdb6227b41	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	b651aec8-5455-4329-8251-0ceb62cea798
bebb462a-3b8e-4b84-8764-09943e350427	3356f353-1566-4df6-9958-fa01d67d13c7	7682acb3-561b-4951-801b-c1564adda131
c0e0d81f-9706-449e-9568-9a04aae8141f	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	fd84aa38-11ef-46af-ade7-241f2a2c08fd
c1ada186-d814-49ea-9f7a-d193c2cd7f79	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	db0addff-605e-439f-917b-38016a398755
c28eb0d0-192a-4ab0-a818-58efaa65b177	96efad7d-8b7f-4d7f-a862-c0a6bec3789f	5d962383-f175-4dd8-af63-8a566a0d2255
c5bbaa78-34c1-43f6-9cf0-9aa81323a9eb	4f972924-350a-47fb-a6b6-f2b34bb6b621	e99b7773-5d71-4dca-ad36-b896dcfb71c4
c5c0a92b-eae6-483e-ba43-fb0336c8e9e2	3b7ea453-324e-40a0-bb41-77a0795d5af5	682d36c0-4256-42ab-811e-054ab3a5b10f
c778ec10-0795-4836-bbad-09ef4fa75032	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
ccfa60ca-766e-49d1-a5ae-7c1c4f90603a	911f6d7f-8d43-40f2-897a-2f416abf8cf9	cfdb2071-d50e-4ea3-b732-19eb08f1e629
cd0e8086-283c-495a-8fb4-7d1f02914ceb	168d11d7-ca26-4d61-b870-51779dc63023	e99b7773-5d71-4dca-ad36-b896dcfb71c4
cd398bf9-e5fe-4459-8ad7-54b3f4071803	c6c6cd04-6df3-4593-b686-e4b9d362c96f	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
cdac5c92-2879-410d-9a9f-046a91481094	caa227a1-2dcf-4195-ab9c-8f76d1862daa	5d962383-f175-4dd8-af63-8a566a0d2255
d0186077-e436-4482-95e0-0cd851b818cb	e2c675a7-92dc-4477-be75-9a304cbe4def	fa773eb9-162f-4ea8-9fc4-9c54a3068582
d0878fed-0822-4b58-840a-8cf21a380461	f8502c44-b289-49e4-8401-3dcad4d5bbe0	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
d1616d8b-c187-4457-8930-74b5123d7672	ae255622-ddcc-45ea-a699-8ec416fe57ab	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
d56eea20-8955-4a17-b7d7-24ab852c4bb8	6193be76-40ad-4973-9ee7-246a4d8f4109	fa773eb9-162f-4ea8-9fc4-9c54a3068582
db1e4725-e3fd-4925-8bd0-348bbfc6cf87	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	88b29e0c-39b7-4169-ab5c-350075014a84
dfe6288f-9c4b-48e8-85b1-940a812a0876	9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	7682acb3-561b-4951-801b-c1564adda131
e0e5fcc0-2647-4dbe-a34a-72d3f3af95e1	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	682d36c0-4256-42ab-811e-054ab3a5b10f
e1d05949-c00a-488d-8054-d08d095a6088	2076a9b1-e432-46a9-99b1-36e732159856	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
e4690476-a776-4da8-80f9-5efb39977573	767a00dd-6f09-4f64-a44e-8fbe901222af	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
e8ad0312-abae-42f8-af2d-0ff8e2a79260	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
eb0c213f-f762-4c6f-87b3-ec1a32d9e386	35a6b1af-dc78-4632-a9f4-eedabdbdcb52	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
eb541d16-7c6e-4f11-a794-79398013fe9c	d8a2b9e5-f54d-4344-a78d-c6c840467543	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
ec741267-673e-4359-b35b-a47a9cde9958	ea315f7d-d597-41b3-a999-4f3851bcd020	cfdb2071-d50e-4ea3-b732-19eb08f1e629
eccaca10-d81f-4ea4-90be-735bbd5a03bd	6e606c29-2ebf-4ab8-8006-aaedd5680009	5d962383-f175-4dd8-af63-8a566a0d2255
f46dd5b4-d00b-4485-a1c3-13dac62f1e80	7d542941-65b9-499b-81b3-239748d6da52	c88d783b-b628-4f3a-a972-aa56aeed5e77
f471283d-48da-447f-9d6b-14a40d30ad38	e228c999-bf54-48b4-a373-d2bc9db88554	682d36c0-4256-42ab-811e-054ab3a5b10f
f7c604d8-cf40-4730-9195-ba4ac18a7f9a	4650d4e0-f73c-4688-ae5f-830a46348ff9	cfdb2071-d50e-4ea3-b732-19eb08f1e629
f936d4c4-2f35-4a90-9f01-6447fe08908b	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	682d36c0-4256-42ab-811e-054ab3a5b10f
f989b143-0f9f-401e-a982-eff06159614f	c70b9832-841e-4864-9b85-eaba3c0a995f	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
faf75d8e-38fe-4f38-a49b-1c664e50cb94	9858c224-f97f-4ff8-908d-f46bd5e2243c	db0addff-605e-439f-917b-38016a398755
fb10f1dc-db6b-4ee3-b331-1430cdc773d1	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	e99b7773-5d71-4dca-ad36-b896dcfb71c4
fe6802ce-3fc2-4718-a8fe-fd1ebf4d13fe	a697a798-caaf-4248-8e4e-7e89096a9c30	682d36c0-4256-42ab-811e-054ab3a5b10f
fec9696a-868f-4a57-9925-233ee78d38e6	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	682d36c0-4256-42ab-811e-054ab3a5b10f
\.


--
-- Data for Name: mst_designations; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "SubDepartment", "DefaultRoleId") FROM stdin;
0525d830-ead9-44a0-871f-91b7845fec26	core_director_and_chief_technology_officer	Director and Chief Technology Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 15:54:51.783926+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Leading Compliance & HR Department	66e48815-4d4f-41d0-9c5f-26a7b7ba296c
0b6ab354-1fcf-4a00-9be3-e58e99c425ed	services_testing_pentester_ii	PenTester - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.930296+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
0c1a5ef4-7fca-45dc-8253-87afa21a1df9	services_operations_soc_analyst_iv	SOC Analyst - IV	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.880491+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
138434a2-625f-4df5-836d-fcf0cfceef79	functional_project_m_senior_pmo_ii	Senior PMO - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.851761+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
41d1dc59-ea33-44eb-8958-dcf35ad051b0	zz_probe_department_zz_probe_designation	ZZ Probe Designation Edited	f	36d04440-a8bb-47f1-a6d9-1f4d144b0bdb	2026-10-18 18:30:09.499474+05:30	2026-10-18 18:30:09.78908+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:30:09.78908+05:30	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	services_operations_intern	Intern	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.904989+05:30	2026-10-21 15:07:57.796708+05:30	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
9050e021-7d84-4401-820e-c0e768abb1ab	functional_project_m_intern	Intern	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.861092+05:30	2026-10-21 15:07:57.796708+05:30	\N	\N	\N	Functional - Project Management	64e2ea37-cbd7-4127-b65b-3b003235981a
bb7ccd5f-2f60-49fb-b984-f11fc47add22	rd_research_and_deve_intern	Intern	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 15:54:51.870785+05:30	2026-10-21 15:07:57.796708+05:30	\N	\N	\N	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393
caa227a1-2dcf-4195-ab9c-8f76d1862daa	functional_accounts_intern	Intern	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.809802+05:30	2026-10-21 15:07:57.796708+05:30	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
711d4f25-dd76-46cc-accd-4e17e0d6f5cd	zz_ui_department_zz_ui_designation	ZZ UI Designation	f	40fed4c8-89b7-4276-b4ef-47fe8cf1ea87	2026-10-18 18:32:39.916388+05:30	2026-10-18 18:32:54.804242+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 18:32:54.804242+05:30	\N	cd2a32ed-32fc-47bc-88a9-e6fc48863869
6105c483-1e32-49ff-848c-f193525e6297	zz_sub_dept_zz_sub_designation	ZZ Sub Designation	f	316c6b23-b976-4e7f-ae22-c8ea15c365cb	2026-10-18 18:43:54.032822+05:30	2026-10-18 18:43:54.103213+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:43:54.103213+05:30	ZZ Probe Sub-Department	cd2a32ed-32fc-47bc-88a9-e6fc48863869
2076a9b1-e432-46a9-99b1-36e732159856	services_consulting_intern	Intern	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.924658+05:30	2026-10-21 15:07:57.796708+05:30	\N	\N	\N	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9
47dbf38f-c022-47bc-8444-d0dfb35ff3fd	services_testing_intern	Intern	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:52.004312+05:30	2026-10-21 15:07:57.796708+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra, Services - Testing - DevSecOps, Services - Testing - Red Team, Services - Testing - Cloud & AI	92aa9169-28d9-4754-a570-553b067642ed
0a60fb48-99c4-44d0-8d97-ff687ccffc9f	services_testing_red_team_practitioner_ii	Red Team Practitioner - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.986648+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Testing - Red Team	92aa9169-28d9-4754-a570-553b067642ed
155642eb-a633-4460-b658-aca9fde2d817	functional_accounts_accountant_i	Accountant - I	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.797934+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
157d001c-b056-45b1-96a3-3c05bcd8d99c	functional_sales_customer_success_representative_ii	Customer Success Representative - II	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.830775+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Sales	914d8500-03b6-4a43-a250-244effca1cf1
163d8c87-8f90-4295-a926-2e912c625a1c	services_testing_pentester_iii	PenTester - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.932399+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
168d11d7-ca26-4d61-b870-51779dc63023	services_testing_associate_manager_ii	Associate Manager - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.955906+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab
195d6a81-8457-4b60-9382-6a3a0664f0e9	services_consulting_associate_manager_iii	Associate Manager - III	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.920769+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Consulting	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a
1e7faab8-273d-40df-9f9a-485160186c5a	services_consulting_grc_auditor_i	GRC Auditor - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.908929+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9
1f97b442-95c5-4b11-93a0-ea146534ae85	functional_accounts_senior_accountant_iii	Senior Accountant - III	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.807813+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
272973a6-c052-4aef-bf32-9e24f7eb6cc9	functional_sales_associate_customer_success_representative_i	Associate Customer Success Representative - I	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.837646+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
2a76927c-461a-48e4-8190-dea7361ef3db	functional_project_m_associate_pmo_ii	Associate PMO - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.847585+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
2b1558e3-158a-4a84-ae80-053129861a64	services_consulting_senior_vice_president_principal_consultant	Senior Vice President - Principal Consultant	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.922717+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Consulting	64c49f37-a38a-46a6-9622-7427f1501658
2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	services_consulting_grc_auditor_ii	GRC Auditor - II	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.910823+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9
3356f353-1566-4df6-9958-fa01d67d13c7	rd_research_and_deve_python_developer_ii	Python Developer - II	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 15:54:51.866732+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393
35a6b1af-dc78-4632-a9f4-eedabdbdcb52	services_testing_devsecops_practitioner_ii	DevSecOps Practitioner - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.97275+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed
3b7ea453-324e-40a0-bb41-77a0795d5af5	services_testing_associate_project_manager	Associate Project Manager	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.961716+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	29ad5710-1621-4c24-ac75-dedfc168ba1a
3e60b693-d3dd-4481-95c4-9f02da21625c	services_consulting_senior_grc_auditor_ii	Senior GRC Auditor - II	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.91882+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Consulting	701aaa2c-a899-4def-bf5f-e17511874409
444df30d-c195-42ad-b9a7-d80cdef69ccd	services_operations_soc_shift_lead_i	SOC Shift Lead - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.894767+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85
4650d4e0-f73c-4688-ae5f-830a46348ff9	services_operations_siem_admin_ii	SIEM Admin - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.884354+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
48429bb5-c583-4684-b30a-7ed443b671ca	services_operations_soc_analyst_ii	SOC Analyst - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.876768+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
485012d4-2c28-4bc4-92c7-3609e3e3749e	functional_hr_senior_hr_executive_i	Senior HR Executive - I	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.820547+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
4b680e29-b4fb-4689-9afb-67a7f089f52b	services_testing_red_team_specialist_ii	Red Team Specialist - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.994166+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Testing - Red Team	29ad5710-1621-4c24-ac75-dedfc168ba1a
4ef1cb5b-9688-4ce2-95b3-6a0863200166	functional_accounts_senior_accountant_i	Senior Accountant - I	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.803595+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
4f972924-350a-47fb-a6b6-f2b34bb6b621	services_testing_pentester_i	PenTester - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.928383+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
6193be76-40ad-4973-9ee7-246a4d8f4109	functional_sales_director_product_sales	Director - Product Sales	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.832885+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
632bf06c-f646-4edd-bf2d-e3cd2e034c7f	services_testing_senior_pentester_i	Senior Pentester - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.936785+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
6d25ff6d-e13d-440f-b775-215547af7acb	services_operations_soc_analyst_i	SOC Analyst - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.874793+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
6e606c29-2ebf-4ab8-8006-aaedd5680009	functional_accounts_accountant_iii	Accountant - III	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.801711+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	services_operations_soc_consultant_i	SOC Consultant - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.890218+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
73bd55bb-5d0e-4381-8ad2-2238377fca93	functional_it_admini_desktop_support_engineer_ii	Desktop Support Engineer - II	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 15:54:51.792134+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa
767a00dd-6f09-4f64-a44e-8fbe901222af	services_testing_devsecops_practitioner_iii	DevSecOps Practitioner - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.976579+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed
778f1120-9633-4933-9160-ddaa46668838	core_director_and_chief_executive_officer	Director and Chief Executive Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 15:54:51.776662+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Leading Sales & A/C Department	62a927b7-9fd8-461a-b64e-1aa441eeba4d
7c2380da-3ee6-46ad-93d6-a79ce3027f29	services_consulting_grc_auditor_iv	GRC Auditor - IV	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.915028+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9
7d542941-65b9-499b-81b3-239748d6da52	functional_hr_recruitment_coordinator_i	Recruitment Coordinator - I	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.8165+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
7e7d954f-34b5-4c23-8c3f-698ec920e9e4	functional_sales_associate_customer_success_representative_ii	Associate Customer Success Representative - II	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.839641+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
834c9e15-c70d-4a0b-bb12-5e55f23c181d	functional_project_m_delivery_account_manager_i	Delivery Account Manager - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.853646+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89
85cc9fbe-98a4-464d-a638-05f40529c6de	services_testing_red_team_practitioner_iii	Red Team Practitioner - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.991312+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Testing - Red Team	92aa9169-28d9-4754-a570-553b067642ed
8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	services_consulting_grc_auditor_iii	GRC Auditor - III	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.912801+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9
8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	services_testing_senior_cloud_security_consultant_i	Senior Cloud Security Consultant - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.997244+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Testing - Cloud & AI	29ad5710-1621-4c24-ac75-dedfc168ba1a
8b57cfd5-5d4e-44a3-9646-b36873c111c2	functional_project_m_senior_delivery_account_manager_i	Senior Delivery Account Manager - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.857373+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89
8dc0d8fe-593d-422a-8b27-5b68fbe6d224	functional_accounts_accountant_ii	Accountant - II	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.799807+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	functional_hr_hr_head	HR Head	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.814553+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
911f6d7f-8d43-40f2-897a-2f416abf8cf9	services_operations_soc_consultant_ii	SOC Consultant - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.892032+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
96efad7d-8b7f-4d7f-a862-c0a6bec3789f	functional_accounts_senior_accountant_ii	Senior Accountant - II	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-09-02 15:54:51.805714+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869
9858c224-f97f-4ff8-908d-f46bd5e2243c	services_testing_pentester_iv	PenTester - IV	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.93473+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	rd_research_and_deve_python_developer_iii	Python Developer - III	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 15:54:51.868943+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393
9dc69952-eae6-4ec0-a327-67392315f089	functional_project_m_senior_delivery_account_manager_ii	Senior Delivery Account Manager - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.859188+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89
a697a798-caaf-4248-8e4e-7e89096a9c30	services_testing_manager_i	Manager - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.966138+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	efc1df20-ca04-44a6-87b2-7cae1ff50a88
aaf4ca75-5fa5-4de2-8353-a5e93beecb56	services_testing_associate_manager_iii	Associate Manager - III	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.957817+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab
ae255622-ddcc-45ea-a699-8ec416fe57ab	services_testing_devsecops_practitioner_i	DevSecOps Practitioner - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.969279+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed
af8a1442-c5ee-409d-aa91-61c9dba852ee	services_operations_siem_admin_iii	SIEM Admin - III	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.886248+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
b2b687ef-fd62-4cb7-a826-b40a35da7b2c	functional_sales_business_development_associate_i	Business Development Associate - I	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.828797+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Sales	914d8500-03b6-4a43-a250-244effca1cf1
b3309eea-7374-4a8d-ac13-481b2a7fd492	functional_project_m_associate_pmo_i	Associate PMO - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.845704+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
b5f39dd8-c305-489d-9f7d-9adfd010a134	services_operations_soc_lead_i	SOC Lead - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.899202+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	111cc3cd-6d35-43ce-be91-dde90d3d4015
c0e1a001-0000-4000-8000-000000000001	core_intern	Intern	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-10-13 23:24:19.140561+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Across all Sub Departments	f29af015-7833-4f9a-ac57-6fbef5bf91ec
c0f974c3-f49c-449a-9276-aa64ce501344	services_operations_soc_shift_lead_ii	SOC Shift Lead - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.896662+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85
c1fa4328-a970-48a1-bc08-d50fe36bf44c	services_testing_devsecops_specialist_ii	DevSecOps Specialist - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.983425+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Testing - DevSecOps	29ad5710-1621-4c24-ac75-dedfc168ba1a
c2e248c8-e917-445f-9f7b-1e25d7bb5abe	functional_hr_recruitment_coordinator_ii	Recruitment Coordinator - II	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.818555+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
c6c6cd04-6df3-4593-b686-e4b9d362c96f	services_testing_devsecops_associate	DevSecOps Associate	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.980181+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Testing - DevSecOps	a3793f87-7f3c-41a1-a675-236fc1b710ab
c70b9832-841e-4864-9b85-eaba3c0a995f	functional_it_admini_desktop_support_engineer_i	Desktop Support Engineer - I	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 15:54:51.78998+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa
c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	functional_project_m_senior_pmo_i	Senior PMO - I	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.849476+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1
d8a2b9e5-f54d-4344-a78d-c6c840467543	functional_project_m_delivery_account_manager_ii	Delivery Account Manager - II	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-09-02 15:54:51.855524+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89
da990f6e-3379-4cc4-89b7-0ead29da472b	functional_it_admini_it_admin	IT Admin	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 15:54:51.787896+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa
dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	services_consulting_senior_grc_auditor_i	Senior GRC Auditor - I	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-09-02 15:54:51.916903+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Consulting	701aaa2c-a899-4def-bf5f-e17511874409
e228c999-bf54-48b4-a373-d2bc9db88554	services_testing_associate_manager_i	Associate Manager - I	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.953968+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab
e2b4be77-2b20-4064-974d-e6322e7240b4	services_testing_associate_ai_engineer_contractual	Associate AI Engineer - Contractual	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:52.001242+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Testing - Cloud & AI	92aa9169-28d9-4754-a570-553b067642ed
e2c675a7-92dc-4477-be75-9a304cbe4def	functional_sales_sales_associate	Sales Associate	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.83517+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
e36018c5-bf48-4f93-bef7-93e8864a0b51	services_operations_siem_admin_iv	SIEM Admin - IV	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.888229+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85
a68ad37b-7bd6-41e7-a8e5-8b97a43a876a	HOD_f5a4d6a6	Head of Department_f5a4d6a6	t	\N	2026-11-16 18:09:31.774209+05:30	2026-11-16 18:09:31.774209+05:30	\N	\N	\N	\N	\N
e4e20503-cd55-4393-83fd-6c7e7d7d0a49	functional_hr_senior_hr_executive_ii	Senior HR Executive - II	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.8227+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	services_testing_senior_pentester_ii	Senior Pentester - II	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-09-02 15:54:51.93907+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed
ea315f7d-d597-41b3-a999-4f3851bcd020	services_operations_siem_admin_i	SIEM Admin - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.88251+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	services_operations_principal_manager_i	Principal Manager - I	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-10-10 12:56:56.213994+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	3d068c2f-d0a1-4045-bad9-0f3a43efec4f
eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	services_operations_soc_lead_ii	SOC Lead - II	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.901107+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7
f20a7445-0b01-4f20-85a5-853101d864ee	services_operations_soc_analyst_iii	SOC Analyst - III	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-09-02 15:54:51.878659+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827
f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	rd_research_and_deve_python_developer_i	Python Developer - I	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-09-02 15:54:51.864858+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393
ffed7aa1-e88f-4281-919f-8d49fbabf5a5	core_director_and_chief_operating_officer	Director and Chief Operating Officer	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-09-02 15:54:51.781954+05:30	2026-10-18 13:18:56.513137+05:30	\N	\N	\N	Leading Delivery Department	a5bfe265-981a-4723-b7bb-6ddc389db7f0
e2b10def-c91d-45da-94c5-f5530e743aa2	functional_sales_intern	Intern	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-09-02 15:54:51.841726+05:30	2026-10-21 15:07:57.796708+05:30	\N	\N	\N	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325
e8c22eff-0daf-4690-a537-c8b0b6110a01	functional_hr_intern	Intern	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-09-02 15:54:51.824863+05:30	2026-10-21 15:07:57.796708+05:30	\N	\N	\N	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3
f8502c44-b289-49e4-8401-3dcad4d5bbe0	functional_it_admini_intern	Intern	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-09-02 15:54:51.794108+05:30	2026-10-21 15:07:57.796708+05:30	\N	\N	\N	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa
2e051c12-d958-474a-af63-5b0dd5439907	HOD_5f63b760	Head of Department_5f63b760	t	\N	2026-11-16 17:34:22.958936+05:30	2026-11-16 17:34:22.958936+05:30	\N	\N	\N	\N	\N
fbac2b9c-726d-4aa5-aea9-2c1e97504f86	HOD_dbf8b5a6	Head of Department_dbf8b5a6	t	\N	2026-11-16 17:34:23.717453+05:30	2026-11-16 17:34:23.717453+05:30	\N	\N	\N	\N	\N
29020fe6-73c6-44fb-9270-b9406c8ecded	HOD_fc2ee217	Head of Department_fc2ee217	t	\N	2026-11-16 17:34:23.882464+05:30	2026-11-16 17:34:23.882464+05:30	\N	\N	\N	\N	\N
1c745743-e827-41bb-be9b-64f92fd77e2b	HOD_7748c71a	Head of Department_7748c71a	t	\N	2026-11-16 17:34:24.214114+05:30	2026-11-16 17:34:24.214114+05:30	\N	\N	\N	\N	\N
4a64e2eb-fdb7-419e-9e56-25ab336aba60	HOD_b6febf29	Head of Department_b6febf29	t	\N	2026-11-16 17:34:24.250486+05:30	2026-11-16 17:34:24.250487+05:30	\N	\N	\N	\N	\N
2b2e1a21-7c26-41e6-8439-95d83e3c38ff	HOD_715a83a2	Head of Department_715a83a2	t	\N	2026-11-16 17:34:24.359905+05:30	2026-11-16 17:34:24.359905+05:30	\N	\N	\N	\N	\N
5ad7e3cc-6bbe-45b0-bb87-45b03b3d681b	HOD_c3668e15	Head of Department_c3668e15	t	\N	2026-11-16 17:34:24.618359+05:30	2026-11-16 17:34:24.618359+05:30	\N	\N	\N	\N	\N
21ae8be0-2820-43eb-9ec9-94f1f714c68c	HOD_c95beecf	Head of Department_c95beecf	t	\N	2026-11-16 17:34:24.698661+05:30	2026-11-16 17:34:24.698661+05:30	\N	\N	\N	\N	\N
703cb3ac-250c-44f4-9cd8-33a0f1ef828e	HOD_0f63c9dd	Head of Department_0f63c9dd	t	\N	2026-11-16 17:34:24.765394+05:30	2026-11-16 17:34:24.765394+05:30	\N	\N	\N	\N	\N
9ae2d7d1-480d-4362-a338-a68637f26362	HOD_beaee48a	Head of Department_beaee48a	t	\N	2026-11-16 17:34:24.818313+05:30	2026-11-16 17:34:24.818313+05:30	\N	\N	\N	\N	\N
bd00637b-438f-4fbe-9065-17d0b71c8a48	HOD_676a789d	Head of Department_676a789d	t	\N	2026-11-16 17:34:24.894507+05:30	2026-11-16 17:34:24.894507+05:30	\N	\N	\N	\N	\N
d00931a1-0c64-470f-830b-d9dc130cb5d4	HOD_cd232cc2	Head of Department_cd232cc2	t	\N	2026-11-16 17:35:49.638213+05:30	2026-11-16 17:35:49.638213+05:30	\N	\N	\N	\N	\N
61baae51-2636-4674-9e76-5299e2264a90	HOD_4d1ed200	Head of Department_4d1ed200	t	\N	2026-11-16 17:35:50.054222+05:30	2026-11-16 17:35:50.054222+05:30	\N	\N	\N	\N	\N
8a7fbfa9-6340-4abe-9c49-a34620a62759	HOD_0e1c6462	Head of Department_0e1c6462	t	\N	2026-11-16 17:35:50.190179+05:30	2026-11-16 17:35:50.19018+05:30	\N	\N	\N	\N	\N
da2a99f9-d21a-46de-9138-2cf3ff8cabf4	HOD_c03ed08c	Head of Department_c03ed08c	t	\N	2026-11-16 17:35:50.854181+05:30	2026-11-16 17:35:50.854181+05:30	\N	\N	\N	\N	\N
7d0a1a53-5bd8-4962-a4ae-0b99124d569c	HOD_3a934cb8	Head of Department_3a934cb8	t	\N	2026-11-16 17:35:50.986115+05:30	2026-11-16 17:35:50.986115+05:30	\N	\N	\N	\N	\N
54029bad-87c3-4ba1-83d3-cc106f7ca1d5	HOD_0349923a	Head of Department_0349923a	t	\N	2026-11-16 17:35:51.327902+05:30	2026-11-16 17:35:51.327902+05:30	\N	\N	\N	\N	\N
97ee2216-ca4f-4ba2-80c6-50d8c1a36263	HOD_08ed1c42	Head of Department_08ed1c42	t	\N	2026-11-16 17:35:52.128439+05:30	2026-11-16 17:35:52.12844+05:30	\N	\N	\N	\N	\N
393cec69-d85a-4eaa-a6e6-6d71a5fa846c	HOD_21b57dbf	Head of Department_21b57dbf	t	\N	2026-11-16 17:35:52.365553+05:30	2026-11-16 17:35:52.365554+05:30	\N	\N	\N	\N	\N
123d860b-6130-4f74-b28a-6e74636f4db6	HOD_0f25ec72	Head of Department_0f25ec72	t	\N	2026-11-16 17:35:52.510917+05:30	2026-11-16 17:35:52.510917+05:30	\N	\N	\N	\N	\N
ac2021ce-8742-42b1-96d7-f5d421419571	HOD_71a58b59	Head of Department_71a58b59	t	\N	2026-11-16 17:35:52.627471+05:30	2026-11-16 17:35:52.627472+05:30	\N	\N	\N	\N	\N
0c91b8de-446e-470d-a41c-874b45a81bac	HOD_ba09cf4b	Head of Department_ba09cf4b	t	\N	2026-11-16 17:35:52.769055+05:30	2026-11-16 17:35:52.769055+05:30	\N	\N	\N	\N	\N
67be9fbe-b89e-4166-8a35-0e33f206387a	HOD_610d6375	Head of Department_610d6375	t	\N	2026-11-16 17:41:29.991205+05:30	2026-11-16 17:41:29.991205+05:30	\N	\N	\N	\N	\N
9b37add7-14a8-4b16-ad67-757626f8345e	HOD_f7ae69f2	Head of Department_f7ae69f2	t	\N	2026-11-16 17:41:30.796066+05:30	2026-11-16 17:41:30.796066+05:30	\N	\N	\N	\N	\N
fa73055a-c057-4163-8bef-469d02876169	HOD_18f05b15	Head of Department_18f05b15	t	\N	2026-11-16 17:41:30.947786+05:30	2026-11-16 17:41:30.947786+05:30	\N	\N	\N	\N	\N
6d11f105-4f3b-4c18-8a9d-e2cf2be076a2	HOD_7355011e	Head of Department_7355011e	t	\N	2026-11-16 17:41:31.229987+05:30	2026-11-16 17:41:31.229987+05:30	\N	\N	\N	\N	\N
23764d61-69b6-44f1-87c7-e3ef78c9e9a9	HOD_d30708c3	Head of Department_d30708c3	t	\N	2026-11-16 17:41:31.271954+05:30	2026-11-16 17:41:31.271954+05:30	\N	\N	\N	\N	\N
2a49bf34-cd35-4267-b27e-f2b95a09edce	HOD_6aafe861	Head of Department_6aafe861	t	\N	2026-11-16 17:41:31.394893+05:30	2026-11-16 17:41:31.394893+05:30	\N	\N	\N	\N	\N
aad5bfac-2916-4071-bb8f-36162376de11	HOD_af50b386	Head of Department_af50b386	t	\N	2026-11-16 17:41:31.678132+05:30	2026-11-16 17:41:31.678132+05:30	\N	\N	\N	\N	\N
9ddb1f12-0096-4e91-ac6b-f68a74da1e04	HOD_017672eb	Head of Department_017672eb	t	\N	2026-11-16 17:41:31.765316+05:30	2026-11-16 17:41:31.765316+05:30	\N	\N	\N	\N	\N
288cc0ee-d895-4c0d-a4a3-76ee620b30b9	HOD_8e3848b5	Head of Department_8e3848b5	t	\N	2026-11-16 17:41:31.838023+05:30	2026-11-16 17:41:31.838023+05:30	\N	\N	\N	\N	\N
1fe8cfe2-8d11-41c9-af9a-be740c514502	HOD_9f27378e	Head of Department_9f27378e	t	\N	2026-11-16 17:41:31.895502+05:30	2026-11-16 17:41:31.895503+05:30	\N	\N	\N	\N	\N
68d1b494-e508-41d5-9f4a-ca7512948141	HOD_eb971ede	Head of Department_eb971ede	t	\N	2026-11-16 17:41:31.971493+05:30	2026-11-16 17:41:31.971493+05:30	\N	\N	\N	\N	\N
f8d9e2fe-f3d7-4013-b6ad-159e0c94ee66	HOD_4ad97aab	Head of Department_4ad97aab	t	\N	2026-11-16 17:47:44.028522+05:30	2026-11-16 17:47:44.028522+05:30	\N	\N	\N	\N	\N
a96e3f94-a593-47cd-80fb-c6d48d6d14ec	HOD_e37f9f5b	Head of Department_e37f9f5b	t	\N	2026-11-16 17:47:44.697608+05:30	2026-11-16 17:47:44.697608+05:30	\N	\N	\N	\N	\N
8c35ee7a-a036-4e73-baa6-7182767ce5f5	HOD_94fe0091	Head of Department_94fe0091	t	\N	2026-11-16 17:47:44.843486+05:30	2026-11-16 17:47:44.843486+05:30	\N	\N	\N	\N	\N
057f8100-165b-44fb-870a-fcbb5763dd61	HOD_6afd200f	Head of Department_6afd200f	t	\N	2026-11-16 17:47:45.08771+05:30	2026-11-16 17:47:45.08771+05:30	\N	\N	\N	\N	\N
004beba5-cb51-47fe-9aca-275ca77fd68f	HOD_0a11f446	Head of Department_0a11f446	t	\N	2026-11-16 17:47:45.126831+05:30	2026-11-16 17:47:45.126831+05:30	\N	\N	\N	\N	\N
42b662b9-ee4e-4b5f-b72f-9de8b983e768	HOD_f089a31b	Head of Department_f089a31b	t	\N	2026-11-16 17:47:45.24914+05:30	2026-11-16 17:47:45.24914+05:30	\N	\N	\N	\N	\N
140d3355-1ad3-4298-9672-325e17346b1e	HOD_72d283fa	Head of Department_72d283fa	t	\N	2026-11-16 17:47:45.502711+05:30	2026-11-16 17:47:45.502711+05:30	\N	\N	\N	\N	\N
0ba035c1-70ed-4af7-bac3-a40c4a364987	HOD_acd6cdf1	Head of Department_acd6cdf1	t	\N	2026-11-16 17:47:45.578604+05:30	2026-11-16 17:47:45.578604+05:30	\N	\N	\N	\N	\N
21dde614-d671-4e0b-ad84-8e100c4144de	HOD_b9db340a	Head of Department_b9db340a	t	\N	2026-11-16 17:47:45.640579+05:30	2026-11-16 17:47:45.640579+05:30	\N	\N	\N	\N	\N
18ee8b63-a783-4f50-a970-c96c31721127	HOD_1b90b043	Head of Department_1b90b043	t	\N	2026-11-16 17:47:45.689039+05:30	2026-11-16 17:47:45.689039+05:30	\N	\N	\N	\N	\N
f2351301-01c0-48c6-972e-7c70e00ec491	HOD_d555667e	Head of Department_d555667e	t	\N	2026-11-16 17:47:45.759133+05:30	2026-11-16 17:47:45.759133+05:30	\N	\N	\N	\N	\N
e8effed1-d09f-4980-820d-f486a48495ee	HOD_10401981	Head of Department_10401981	t	\N	2026-11-16 18:09:30.188166+05:30	2026-11-16 18:09:30.188167+05:30	\N	\N	\N	\N	\N
827c8cb2-78a1-4e1d-8e3a-dec4604eac7b	HOD_1c9c1876	Head of Department_1c9c1876	t	\N	2026-11-16 18:09:30.861847+05:30	2026-11-16 18:09:30.861847+05:30	\N	\N	\N	\N	\N
698bd542-e70a-49b2-9c32-8a4eae8616af	HOD_537180dc	Head of Department_537180dc	t	\N	2026-11-16 18:09:30.991575+05:30	2026-11-16 18:09:30.991575+05:30	\N	\N	\N	\N	\N
77d0e1c4-739f-40f8-8dd6-7574ec23ca19	HOD_ed55976c	Head of Department_ed55976c	t	\N	2026-11-16 18:09:31.247826+05:30	2026-11-16 18:09:31.247826+05:30	\N	\N	\N	\N	\N
eda6d175-af75-4502-856e-e890bbb18caf	HOD_c70bc377	Head of Department_c70bc377	t	\N	2026-11-16 18:09:31.28205+05:30	2026-11-16 18:09:31.28205+05:30	\N	\N	\N	\N	\N
c035d2de-1961-4553-b633-da4c266c3ac9	HOD_49a43d08	Head of Department_49a43d08	t	\N	2026-11-16 18:09:31.387268+05:30	2026-11-16 18:09:31.387268+05:30	\N	\N	\N	\N	\N
ab37eca4-aae6-4b97-ae7f-5ad76086e790	HOD_0f9ab9d4	Head of Department_0f9ab9d4	t	\N	2026-11-16 18:09:31.630515+05:30	2026-11-16 18:09:31.630515+05:30	\N	\N	\N	\N	\N
b12913da-c884-49eb-bf5b-d133c0c987a4	HOD_02742f21	Head of Department_02742f21	t	\N	2026-11-16 18:09:31.707956+05:30	2026-11-16 18:09:31.707956+05:30	\N	\N	\N	\N	\N
d8936264-8926-4419-8152-88468cc61af9	HOD_b5cdd1f8	Head of Department_b5cdd1f8	t	\N	2026-11-16 18:09:31.825606+05:30	2026-11-16 18:09:31.825606+05:30	\N	\N	\N	\N	\N
9f1a5621-02a3-4cb3-b4ee-d4663ee11cf3	HOD_8ea6f2db	Head of Department_8ea6f2db	t	\N	2026-11-16 18:09:31.894991+05:30	2026-11-16 18:09:31.894991+05:30	\N	\N	\N	\N	\N
0a8342f0-8d11-44e4-ab44-f486d7bc9abc	HOD_cbce0ca0	Head of Department_cbce0ca0	t	\N	2026-11-16 18:18:49.199044+05:30	2026-11-16 18:18:49.199044+05:30	\N	\N	\N	\N	\N
3e5accf9-cf05-4494-9c2e-d647cde0c9af	HOD_163a2050	Head of Department_163a2050	t	\N	2026-11-16 18:18:49.289124+05:30	2026-11-16 18:18:49.289124+05:30	\N	\N	\N	\N	\N
757c31b4-d48b-45df-9c2c-ec194c8e29c6	HOD_73c1240c	Head of Department_73c1240c	t	\N	2026-11-16 18:18:49.328636+05:30	2026-11-16 18:18:49.328636+05:30	\N	\N	\N	\N	\N
c8387aee-7fec-4fcb-945d-f01c23b1a456	HOD_45104188	Head of Department_45104188	t	\N	2026-11-16 18:18:49.457818+05:30	2026-11-16 18:18:49.457818+05:30	\N	\N	\N	\N	\N
6fd1d268-d5a3-4b51-98e7-6ed8f156eb03	HOD_1d707bc8	Head of Department_1d707bc8	t	\N	2026-11-16 18:18:49.479051+05:30	2026-11-16 18:18:49.479051+05:30	\N	\N	\N	\N	\N
e1aa305d-7479-4dc6-9705-00ef14029710	HOD_cfa49c50	Head of Department_cfa49c50	t	\N	2026-11-16 18:18:49.550112+05:30	2026-11-16 18:18:49.550112+05:30	\N	\N	\N	\N	\N
1414f4ba-2c51-40d7-a067-b922316c9f5f	HOD_fa24d789	Head of Department_fa24d789	t	\N	2026-11-16 18:18:49.730396+05:30	2026-11-16 18:18:49.730396+05:30	\N	\N	\N	\N	\N
c6a6912e-5252-4010-9959-5c17439c9b39	HOD_03984918	Head of Department_03984918	t	\N	2026-11-16 18:18:49.786689+05:30	2026-11-16 18:18:49.786689+05:30	\N	\N	\N	\N	\N
b1327618-a5c9-4be9-97df-82d624797280	HOD_40861032	Head of Department_40861032	t	\N	2026-11-16 18:18:49.833036+05:30	2026-11-16 18:18:49.833036+05:30	\N	\N	\N	\N	\N
93d1ffcc-ff80-488d-a575-f0afb8e056b9	HOD_52bc275f	Head of Department_52bc275f	t	\N	2026-11-16 18:18:49.870661+05:30	2026-11-16 18:18:49.870661+05:30	\N	\N	\N	\N	\N
84f406b5-0698-4a97-9c54-ff61a92c6c13	HOD_bfca00b8	Head of Department_bfca00b8	t	\N	2026-11-16 18:18:49.926883+05:30	2026-11-16 18:18:49.926883+05:30	\N	\N	\N	\N	\N
512c9cb6-182d-4cb3-8e18-d8eb0c897431	HOD_a1a9a7ba	Head of Department_a1a9a7ba	t	\N	2026-11-16 19:00:22.794819+05:30	2026-11-16 19:00:22.79482+05:30	\N	\N	\N	\N	\N
27304521-bacb-4b28-b30d-99ffdd25401d	HOD_c8c893de	Head of Department_c8c893de	t	\N	2026-11-16 19:00:23.228529+05:30	2026-11-16 19:00:23.228529+05:30	\N	\N	\N	\N	\N
39989e64-fd77-4053-93e3-9e3f19a6efb6	HOD_09edf615	Head of Department_09edf615	t	\N	2026-11-16 19:00:23.403993+05:30	2026-11-16 19:00:23.403993+05:30	\N	\N	\N	\N	\N
d436b8eb-b21a-46f3-b3d3-c90be69a2488	HOD_20d478b0	Head of Department_20d478b0	t	\N	2026-11-16 19:00:23.987037+05:30	2026-11-16 19:00:23.987037+05:30	\N	\N	\N	\N	\N
09879dd2-60e8-4af9-8325-27251ec37f74	HOD_297bbff5	Head of Department_297bbff5	t	\N	2026-11-16 19:00:24.065782+05:30	2026-11-16 19:00:24.065782+05:30	\N	\N	\N	\N	\N
bd2f975f-5138-4cfa-a395-6026466d4606	HOD_9a20e0b3	Head of Department_9a20e0b3	t	\N	2026-11-16 19:00:24.436261+05:30	2026-11-16 19:00:24.436261+05:30	\N	\N	\N	\N	\N
7652fbe4-3675-4941-a967-61f2a7e98a3e	HOD_1990bb17	Head of Department_1990bb17	t	\N	2026-11-16 19:00:25.24809+05:30	2026-11-16 19:00:25.24809+05:30	\N	\N	\N	\N	\N
31bc1d95-75bf-4e51-bf1e-4be15afd9bf5	HOD_62cc5978	Head of Department_62cc5978	t	\N	2026-11-16 19:00:25.670686+05:30	2026-11-16 19:00:25.670686+05:30	\N	\N	\N	\N	\N
e647d76f-ccd7-4495-85c1-bceb87f1300d	HOD_aeec4e1e	Head of Department_aeec4e1e	t	\N	2026-11-16 19:00:26.007049+05:30	2026-11-16 19:00:26.00705+05:30	\N	\N	\N	\N	\N
344c2fae-e89d-468d-a16c-a37d5a8f4d88	HOD_a9b80128	Head of Department_a9b80128	t	\N	2026-11-16 19:00:26.253905+05:30	2026-11-16 19:00:26.253905+05:30	\N	\N	\N	\N	\N
cbbb4785-006f-4f2a-af01-4d29c0d02005	HOD_c57b3e28	Head of Department_c57b3e28	t	\N	2026-11-16 19:00:26.683138+05:30	2026-11-16 19:00:26.683138+05:30	\N	\N	\N	\N	\N
\.


--
-- Data for Name: mst_email_domains; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_email_domains ("Id", "Code", "DomainName", "DisplayName", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
5112286a-225d-4b86-b16f-74211d9c5779	talakunchi_com	talakunchi.com	@talakunchi.com	t	1	2026-08-22 00:42:04.483485+05:30	\N	\N	\N	\N
a19f97e1-8bf5-4b14-823a-b653b62c2954	talakunchi_in	talakunchi.in	@talakunchi.in	t	2	2026-08-22 00:42:04.483485+05:30	\N	\N	\N	\N
fb66fff9-7911-47de-bde7-ab5fb5ab0757	squad1_io	squad1.io	@squad1.io	t	3	2026-08-22 00:42:04.483485+05:30	\N	\N	\N	\N
9f408de4-fcac-4b0f-b696-df83a2c0c248	zz_probe_example	zz-probe-edited.example	zz-probe-edited.example	f	4	2026-10-18 18:30:09.206787+05:30	2026-10-18 18:30:09.676327+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:30:09.676327+05:30
\.


--
-- Data for Name: mst_employee_statuses; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_employee_statuses ("Id", "Code", "Name", "IsActive", "AllowOnboarding", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
26e2b2e5-b1ab-40af-8f6d-2b80deb463a0	absconded	Absconded	t	f	3	2026-09-07 11:33:13.27055+05:30	\N	\N	\N	\N
a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	terminated	Terminated	t	f	2	2026-09-07 11:33:13.27055+05:30	\N	\N	\N	\N
beee234f-c734-4d09-a0bb-96a6cc523cc3	resignation_under_review	Resignation Under Review	t	f	5	2026-09-07 11:33:13.27055+05:30	\N	\N	\N	\N
ce28b4c5-a343-493b-9404-96c983768850	resigned	Resigned	t	f	4	2026-09-07 11:33:13.27055+05:30	\N	\N	\N	\N
e273e2ed-5fd3-4564-bb87-09a71cd4779a	active	Active	t	t	1	2026-09-07 11:33:13.27055+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_graduation_degrees; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
6620d8cb-2725-465f-956e-6a7ba990bd6d	zz_probe_btech	ZZ Probe BTech	f	2026-10-18 18:30:09.3461+05:30	2026-10-18 18:30:09.725032+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:30:09.725032+05:30
\.


--
-- Data for Name: mst_industries; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
7f460c51-01ec-4da1-8f71-d6f360b56f91	healthcare	Healthcare	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
f175fde9-14f8-40e8-b564-47d8a29d84ff	logistics	Logistics	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
c7e82721-829b-4450-8393-022587178471	energy	Energy	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
4a80bfdb-a191-4ce1-ab51-2142eb366db7	banking	Banking	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
935db8d7-e2aa-417e-839e-b51d00ce951e	retail	Retail	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
e722474e-d845-42b8-978e-91a6ec78f080	manufacturing	Manufacturing	t	2026-08-18 13:25:36.166597+05:30	\N	\N	\N	\N
ff5e83cc-9c1c-4056-ab0b-42a70714ddd3	media	Media	t	2026-08-20 11:45:51.759149+05:30	\N	a2ef1e7d-5d70-8e86-f48d-429ce5a745dc	\N	\N
dcb2b955-8d33-4b9b-b04a-64208dce1520	telecom	Telecom	t	2026-09-09 12:46:02.332706+05:30	\N	\N	\N	\N
3660a2cd-772b-4686-a733-126d361946a5	ZZTI	ZZ Temp Industry Renamed	f	2026-10-18 15:26:57.884294+05:30	2026-10-18 15:26:58.15001+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	cc9bf92a-b923-8364-be83-4bb68db79cd2	2026-10-18 15:26:58.15001+05:30
7dcea719-4730-4150-aace-58a3b63aec79	BANKING2	Banking 2	f	2026-10-18 15:32:32.030552+05:30	2026-10-18 15:35:22.613792+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 15:35:22.613792+05:30
8e0492bb-3e1c-47b8-890c-a2aa8cdd3a03	INDUSTRYTEST	INDUSTRY Test	t	2026-10-18 15:54:11.848396+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: mst_leave_calendar; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Year", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Tag", "Color", "Description") FROM stdin;
7a111111-0001-4000-8000-000000000001	2026-01-01	New Year's Day	2026	2026-11-11 13:25:17.378502+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Optional Holiday	#0ea5e9	First day of the new year
7a111111-0001-4000-8000-000000000002	2026-01-26	Republic Day	2026	2026-11-11 13:25:17.381389+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	National Holiday	#10b981	National holiday honoring the Constitution of India
7a111111-0001-4000-8000-000000000003	2026-03-03	Holi	2026	2026-11-11 13:25:17.381737+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Festival	#ec4899	Festival of Colours
7a111111-0001-4000-8000-000000000004	2026-03-20	Id-ul-Fitr (Ramzan Eid)	2026	2026-11-11 13:25:17.382123+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Festival	#8b5cf6	Islamic festival marking the end of Ramadan
7a111111-0001-4000-8000-000000000005	2026-04-03	Good Friday	2026	2026-11-11 13:25:17.382515+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Public Holiday	#3b82f6	Christian holiday commemorating the crucifixion of Jesus
7a111111-0001-4000-8000-000000000006	2026-04-14	Dr. Ambedkar Jayanti	2026	2026-11-11 13:25:17.383807+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Public Holiday	#6366f1	Birth anniversary of Dr. B. R. Ambedkar
7a111111-0001-4000-8000-000000000007	2026-05-01	Maharashtra Day / Labour Day	2026	2026-11-11 13:25:17.385555+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Regional Holiday	#f59e0b	State holiday commemorating Maharashtra formation and International Workers Day
7a111111-0001-4000-8000-000000000008	2026-05-27	Bakrid / Id-ul-Zuha	2026	2026-11-11 13:25:17.386194+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Festival	#8b5cf6	Feast of Sacrifice
7a111111-0001-4000-8000-000000000009	2026-08-15	Independence Day	2026	2026-11-11 13:25:17.386526+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	National Holiday	#10b981	Commemorating the nation independence
7a111111-0001-4000-8000-000000000010	2026-09-14	Ganesh Chaturthi	2026	2026-11-11 13:25:17.386858+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Festival	#f97316	Festival honoring Lord Ganesha
7a111111-0001-4000-8000-000000000011	2026-10-02	Mahatma Gandhi Jayanti	2026	2026-11-11 13:25:17.387207+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	National Holiday	#10b981	Birth anniversary of Mahatma Gandhi
7a111111-0001-4000-8000-000000000012	2026-10-20	Dussehra (Vijaya Dashami)	2026	2026-11-11 13:25:17.38753+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Festival	#ef4444	Celebration of victory of good over evil
7a111111-0001-4000-8000-000000000013	2026-11-08	Diwali (Laxmi Pujan)	2026	2026-11-11 13:25:17.387807+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Festival	#eab308	Festival of Lights - Laxmi Pujan
7a111111-0001-4000-8000-000000000014	2026-11-09	Diwali (Govardhan Puja / Balipratipada)	2026	2026-11-11 13:25:17.388414+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Festival	#f59e0b	Govardhan Puja and New Year celebration
7a111111-0001-4000-8000-000000000015	2026-12-25	Christmas	2026	2026-11-11 13:25:17.388778+05:30	2026-11-12 10:51:10.553055+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12 10:51:10.553024+05:30	Public Holiday	#10b981	Celebration of the birth of Jesus Christ
07b80815-ef90-4108-96c4-2c9c92a3886c	2026-12-25	Christmas	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
0c2938b2-9e63-447e-86d4-f8555a0e3970	2026-10-02	Mahatma Gandhi Jayanti	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
10f5a7da-71b3-451e-9064-e07d4b0f6bc0	2026-05-01	Maharashtra Day / May Day	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
15819797-748c-46cc-bc7a-89e4b347c6c6	2026-09-14	Ganesh Chaturthi	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
225f8156-5cc1-4b3f-97ba-59bd5ee5f7a2	2026-04-03	Good Friday	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
2545bd3b-62db-4d67-928a-1ddf8bbba557	2026-10-20	Dussehra (Vijaya Dashami)	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
2fc599e9-4109-4b3f-b431-1a7b103210ff	2026-04-14	Dr. Ambedkar Jayanti	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
3da45ec5-32c9-4fbb-990d-236e1d1edd71	2026-01-01	New Year's Day	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
440856b3-8a76-4345-9ba4-7a4bdd0b01c8	2026-11-09	Diwali (Balipratipada)	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
4819528a-1cf8-4fc7-8484-2fc96e04f521	2026-03-20	Id-ul-Fitr (Ramzan Eid)	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
8f7d548f-e2b1-4388-be13-eef2b86bc121	2026-08-15	Independence Day	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
93639e95-bc76-47ba-8a05-1e67158bf295	2026-01-26	Republic Day	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
9643e8cc-1938-4aa5-b0df-5c6f9a7ecec7	2026-07-05	Test	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
d56e8c9e-969f-4aaf-9f2a-666178cc9a1d	2026-03-03	Holi	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
f9705266-1325-42e8-8795-bb096e4105ab	2026-11-08	Diwali (Laxmi Pujan)	2026	2026-11-12 15:27:12.150042+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	Public Holiday	#a6c63a	\N
\.


--
-- Data for Name: mst_modules; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_modules ("Id", "Code", "Name", "Route", "IconKey", "SortOrder", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
168b1296-de6a-4f9e-a3b9-617b83863736	projects	Projects	/projects	folder-kanban	30	t	2026-10-21 15:24:43.015818+05:30	\N	\N	\N	\N
471bc977-be2e-449d-91e7-5c11cb9c4ec0	dashboard	Dashboard	/	layout-dashboard	10	t	2026-10-21 15:24:43.015818+05:30	\N	\N	\N	\N
4e57fd71-b53e-43c0-862e-5698e09c0922	customers	Customer	/customers	building-2	50	t	2026-10-21 15:24:43.015818+05:30	\N	\N	\N	\N
5a049953-8170-4ef4-a59e-43dc19e12de5	action-centre	Action Center	/action-centre	list-checks	20	t	2026-10-21 15:24:43.015818+05:30	\N	\N	\N	\N
6055ce3c-b466-4354-ba9a-b4c309111e9d	my-team	My Team	\N	users	70	t	2026-10-21 15:24:43.015818+05:30	\N	\N	\N	\N
715f79ce-51ea-46d3-b95d-8318840f90a6	resources	Resources	/resources	users	40	t	2026-10-21 15:24:43.015818+05:30	\N	\N	\N	\N
c04c546e-0f2c-448d-b634-5d517843d365	repository	Repository	/repository	building	60	t	2026-10-21 15:24:43.015818+05:30	\N	\N	\N	\N
fcb69b3e-e5aa-49bb-921f-7793f0a8c90d	settings	Settings	\N	settings	80	t	2026-10-21 15:24:43.015818+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_nationalities; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
-- Data for Name: mst_offices; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_offices ("Id", "Code", "Name", "WorkLocationId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: mst_onfloorrole_sub_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_onfloorrole_sub_departments ("Id", "OnFloorRoleId", "SubDepartmentId") FROM stdin;
00e5d9d3-7050-4362-8ff9-73ba1cad6455	0c18f8ce-b9be-4ec0-a099-44b0fd29bdcd	e99b7773-5d71-4dca-ad36-b896dcfb71c4
01da0a73-ead4-4b2c-9245-0d5f8e3f732f	e061fae9-2430-4025-ad39-ff79717301a5	e99b7773-5d71-4dca-ad36-b896dcfb71c4
02be8258-f3e7-4517-b520-cb36d61b714f	7d2b7826-2f63-4796-9032-5ffa35cd5b37	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
05fab86a-22c6-42c2-9664-61eebb187f3d	54123afd-2783-4a41-b18f-328d024e8a22	5d962383-f175-4dd8-af63-8a566a0d2255
06df9f5a-4c63-4b0b-8a22-b3fb05542ac9	580f3fc7-ff2d-4881-a222-d91a7c00f491	c88d783b-b628-4f3a-a972-aa56aeed5e77
06e97a7b-9858-43bc-9317-7827e3e57375	e061fae9-2430-4025-ad39-ff79717301a5	682d36c0-4256-42ab-811e-054ab3a5b10f
078c8972-85aa-4c78-a352-866355da27b9	da608430-bf9a-4a87-9881-1c07e7f2974a	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
0f8ac9f8-cec0-46de-98f0-5898a929630f	c4ef6b03-baa6-47ac-8d06-c8819ddbdaa7	c88d783b-b628-4f3a-a972-aa56aeed5e77
11c157f8-3700-4c99-8e0f-c51234b3e9a9	acf26b08-e6ae-4343-9bf9-529b070835a3	cfdb2071-d50e-4ea3-b732-19eb08f1e629
14f836d8-c9aa-4903-b1c6-269dd37c6d0c	6eaffc67-3d6e-4bb6-9c90-0a604398090d	e99b7773-5d71-4dca-ad36-b896dcfb71c4
162ef7f0-d143-4715-91c1-d4104dc5d176	bb6f610b-b2f5-4b01-9ea4-fb9ad074b768	cfdb2071-d50e-4ea3-b732-19eb08f1e629
17456261-54eb-4f26-856b-c69a36932780	9ad0a166-cde2-4817-9acd-363d217422d9	682d36c0-4256-42ab-811e-054ab3a5b10f
18a11394-102a-4035-86d0-4f695376f3f7	a885d8fe-9ecc-4c4e-9b23-55c015ffd3e6	e99b7773-5d71-4dca-ad36-b896dcfb71c4
1b34cda2-7b4d-4e68-b8ec-382b937bef49	4cc83d93-7b2f-4c97-a4a7-e9ec47735e4b	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
1c4565cc-cf8d-4f0a-86d2-9f29e6652466	9ac666ca-eaa2-46a5-b489-66a8cc550b65	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
23272624-f6a8-429e-a70a-65bc4408afd4	ec4a89e1-35a6-495a-83c9-b6a34ee00402	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
27907f32-c730-4f81-8807-bfb97f8c8822	f7a34722-94ab-4e14-ad50-5e5f0b44cca6	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
29110da8-accb-4555-89f1-cbc3862700ba	3091c873-f1f0-4632-ac1e-62d1a451c39d	fa773eb9-162f-4ea8-9fc4-9c54a3068582
2b70847f-2e67-46b6-8644-7b9dfd2c1314	36339f27-5abf-4ffc-bca3-5a2333a94df2	e99b7773-5d71-4dca-ad36-b896dcfb71c4
2dde7c1b-e094-41ca-ba5b-642ea06cd149	c4d57da3-eff2-4cd1-834f-e0d77b39f299	db0addff-605e-439f-917b-38016a398755
2fc4b108-dcf4-4485-8275-08962ad6dd33	b25515f1-974c-4b63-a8b6-ca6e7ab95393	cfdb2071-d50e-4ea3-b732-19eb08f1e629
3033d1e2-2bef-495a-b6e9-b46eafaa770e	87ea604f-b245-49c0-9172-3956f1d6eb75	e99b7773-5d71-4dca-ad36-b896dcfb71c4
31407002-3ef5-42e7-89d3-f76e808ad70c	fec21974-29e7-4dcf-8438-efb813045170	45755b2a-741a-4990-ab78-8f65090f75b1
338f09cb-234e-4c74-8f82-32ae50799f3b	b5974e61-080c-4de2-a977-7f0bdee29949	cfdb2071-d50e-4ea3-b732-19eb08f1e629
35f03f9c-d7b3-4bb0-9760-6a67dd286daf	746752f8-decb-46a0-a7e1-d07a0a68dbc3	fd84aa38-11ef-46af-ade7-241f2a2c08fd
363669af-7fe3-4641-b437-8cab3a82603d	dfa4b2c2-7d48-4ff7-b5aa-9b65fbde04e1	e99b7773-5d71-4dca-ad36-b896dcfb71c4
363e0192-1a37-40f7-972b-72c211539b98	8765d1b0-e4fc-4686-91ea-f5ad4e929818	682d36c0-4256-42ab-811e-054ab3a5b10f
36d29238-ab6c-4542-b329-ae3ba3e9c075	d6002117-fdbb-437a-986f-dde6b5b5c162	88b29e0c-39b7-4169-ab5c-350075014a84
3c5201ae-9a16-429c-9c42-9545e2ad142e	8765d1b0-e4fc-4686-91ea-f5ad4e929818	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
3cbb347f-0dc5-4ded-aed5-c527f9afbc90	21c47c58-0be4-41bb-8407-8df5fa4b8e9d	cfdb2071-d50e-4ea3-b732-19eb08f1e629
3eddd51c-1bda-4a8e-bcea-562c8fa0709c	6eaffc67-3d6e-4bb6-9c90-0a604398090d	db0addff-605e-439f-917b-38016a398755
43a9a7ff-4c60-4a69-95c6-fa0c6c417f09	bce667dd-cae2-404d-8013-49194e0f48d9	5d962383-f175-4dd8-af63-8a566a0d2255
46442bf0-368c-4471-a8a2-5877021e7417	9ad0a166-cde2-4817-9acd-363d217422d9	db0addff-605e-439f-917b-38016a398755
476823f6-a6cc-4650-8069-70909048a0d0	7fe8d8b6-c0fc-4015-a3ff-5bb8e95ea0d5	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
4d2a1b82-bdac-4bd9-a350-3035132df3e7	ecc39c47-956d-49b9-8fbc-44a6433f3912	88b29e0c-39b7-4169-ab5c-350075014a84
52e179fa-93d1-4e35-b0ba-891b19d20a57	4d8c99f7-b5c4-434a-ae7c-64419a5a1bcf	c88d783b-b628-4f3a-a972-aa56aeed5e77
54dabdbe-5719-478e-b2cb-52598fcb88e8	b7425734-5262-4802-9a10-5e3141b11d6c	c88d783b-b628-4f3a-a972-aa56aeed5e77
56bc4200-debf-4d78-8330-f05d44505c4e	36339f27-5abf-4ffc-bca3-5a2333a94df2	db0addff-605e-439f-917b-38016a398755
5d545b03-31a7-44ce-a0db-3fa287e0d455	f4e2358e-5ec0-4292-8377-438dabb72fbe	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
5ded9dd9-b842-479f-8202-729772b66c18	67084a5d-02d0-4a73-a15f-45aca43adb58	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
5e9075db-32d4-4e0e-80a2-f94584a78903	67bdeca7-fe42-4b4e-b5b6-9e8e8d410413	cfdb2071-d50e-4ea3-b732-19eb08f1e629
5fcc8cd9-23c3-4088-b029-f913da43a823	2d4e6116-3ec3-4c5d-9d75-35517814a964	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
65d2b852-b9c7-4e68-a345-2a1c3c7d6823	0c18f8ce-b9be-4ec0-a099-44b0fd29bdcd	db0addff-605e-439f-917b-38016a398755
670aa2e6-486e-4735-9017-d9a59ff580a6	e3c262a4-4108-4592-abb0-643085d6a305	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
684b761b-2931-4b76-9840-6a06cdcd4316	9ed3ce2c-add0-4472-9da8-4cd5c0552867	5d962383-f175-4dd8-af63-8a566a0d2255
774541bc-302e-4247-97e1-f9a3576506d0	dfa4b2c2-7d48-4ff7-b5aa-9b65fbde04e1	db0addff-605e-439f-917b-38016a398755
7966cdad-6d97-457c-8a10-4ccb6dd328da	0acaaceb-a951-4492-bdba-69d5e916f8b4	b651aec8-5455-4329-8251-0ceb62cea798
7cbc5aa5-ff9f-4102-9f3d-6dc7b768fec2	e1f2260d-b878-4693-86db-2513390804aa	cfdb2071-d50e-4ea3-b732-19eb08f1e629
7d8b20ff-fbbe-4ff6-921f-20abde8e4542	27d8ec30-01ad-45f2-a7d8-7a54c2d2c754	cfdb2071-d50e-4ea3-b732-19eb08f1e629
7f32caef-d58d-4e44-99ef-4573ff7e6ce5	59cf62d4-7c2d-4e4c-b075-0db51d40ea4e	7682acb3-561b-4951-801b-c1564adda131
824ce611-6bfc-4497-a650-2ac8aab06e9a	d862a290-2a0a-47f2-9c23-2baf830a37b9	fd84aa38-11ef-46af-ade7-241f2a2c08fd
854e93ed-ff7d-4845-8eb1-34992cb96e4e	39c52128-53f4-4e39-8102-4b9ccc9f5584	db0addff-605e-439f-917b-38016a398755
85d856c0-0132-4b24-933d-7b1a1bc824c6	c5ea1ba3-9974-4cca-9320-362527502c6e	5d962383-f175-4dd8-af63-8a566a0d2255
861eec31-86ac-4221-b2ad-eb00464b630b	c637e1a2-5677-45fa-bbbf-f88fc60a9443	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
8911daff-317a-4105-98eb-e75a424b5acd	56779122-3301-4a2c-bc35-085f96ee714b	c88d783b-b628-4f3a-a972-aa56aeed5e77
8e31d123-a52b-47fe-8157-b91b54e29ddc	f39ba18d-6be5-4d23-a99f-f8d7a68c43dc	c88d783b-b628-4f3a-a972-aa56aeed5e77
8f61f102-0778-4f1f-8adc-cdbffa74c21c	c4d57da3-eff2-4cd1-834f-e0d77b39f299	682d36c0-4256-42ab-811e-054ab3a5b10f
8fe64407-8ff5-4821-8d81-70657f418c17	b9f75ed9-10c6-4b61-ad05-b27ec89a8b3b	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
90339c25-400d-428d-915c-fb7812c41f99	ae6e9e5b-7337-47a3-8fe5-bb02a9a7f374	fd84aa38-11ef-46af-ade7-241f2a2c08fd
905eee09-34c8-4ffd-b792-0a0c545cd71f	87ea604f-b245-49c0-9172-3956f1d6eb75	682d36c0-4256-42ab-811e-054ab3a5b10f
924e02f5-83ad-42d2-8796-4ef187cc0298	c4d57da3-eff2-4cd1-834f-e0d77b39f299	e99b7773-5d71-4dca-ad36-b896dcfb71c4
92ffedab-58c2-41a7-bfd1-1c1dc3608bab	8765d1b0-e4fc-4686-91ea-f5ad4e929818	88b29e0c-39b7-4169-ab5c-350075014a84
96ef6f45-6d08-4538-9037-bc02d170c9ed	b4b2673b-fc1c-4484-8f2d-903a39dff2a9	fa773eb9-162f-4ea8-9fc4-9c54a3068582
984e4de5-be6f-457b-a6b7-ea914b1d39d9	39c52128-53f4-4e39-8102-4b9ccc9f5584	682d36c0-4256-42ab-811e-054ab3a5b10f
99060755-4d99-4f73-a9d4-9e1edf687094	475cc74e-698a-4547-966a-823be44cfd15	7682acb3-561b-4951-801b-c1564adda131
9b34b78e-b6ea-4be0-95f4-65fd63f2cf9d	5814389a-4416-4e4d-96a7-58f4801e2757	682d36c0-4256-42ab-811e-054ab3a5b10f
9c42a417-c42f-4480-aa80-32c744e9d56b	56ed9417-a9fd-40ff-a517-1e75bbf02d63	cfdb2071-d50e-4ea3-b732-19eb08f1e629
9dd4b795-9f7b-40f4-8aa6-c42b0c727aca	9326acb0-20c1-4d05-89b6-d85ee3425469	cfdb2071-d50e-4ea3-b732-19eb08f1e629
9ed5022e-1f5c-4be9-b71a-cbbf3cb585c3	f51841ca-ffbc-4619-98be-201d736e4f48	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
a47f6c88-de7a-4661-9ec0-7f27684bc0e5	99039771-cd5a-4878-a7b9-9cdaa02f5be6	5d962383-f175-4dd8-af63-8a566a0d2255
a5d0e381-b084-444d-a923-63cb023b7da3	e061fae9-2430-4025-ad39-ff79717301a5	db0addff-605e-439f-917b-38016a398755
a62895fe-73fd-4ddf-b8b8-d71274a57b86	f6560080-4b30-4b4b-b8ba-90d5b0ead2da	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
a6aaee84-3d8b-42c6-acdc-5bf1c6fecb00	b9232654-c160-4e84-bdc3-ad94a605dbe1	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
ad79897a-b277-477f-80e6-d9c48dd9d34a	8211f0b1-d111-400b-94ab-fd663d50ec65	7682acb3-561b-4951-801b-c1564adda131
ae64cdfa-a003-4ac7-9075-8b3c90d3db54	0c18f8ce-b9be-4ec0-a099-44b0fd29bdcd	682d36c0-4256-42ab-811e-054ab3a5b10f
afed87ac-d838-469c-9b6c-79c1bce47c2d	e60fe13f-6f3e-4410-80c9-dcfbb88f0301	a12ac80b-a665-4301-898e-e9ca3d44bb20
b3297f60-01f9-4a3c-b873-e9ceff74bf32	0837f524-0260-4283-a37f-6e1fb06d3dcd	b651aec8-5455-4329-8251-0ceb62cea798
b4e72ce8-752d-4c74-a518-6b26a75f0a3b	39c52128-53f4-4e39-8102-4b9ccc9f5584	e99b7773-5d71-4dca-ad36-b896dcfb71c4
b7cee4c3-8204-4c16-b45c-02f706c3ac66	36339f27-5abf-4ffc-bca3-5a2333a94df2	682d36c0-4256-42ab-811e-054ab3a5b10f
b7d96e24-3365-4907-a6a1-c292d926736e	a885d8fe-9ecc-4c4e-9b23-55c015ffd3e6	682d36c0-4256-42ab-811e-054ab3a5b10f
bb51948f-4fe7-4b9b-8e86-0bfc8eb28c11	70480603-7eae-41f7-b659-052b7500ca91	fa773eb9-162f-4ea8-9fc4-9c54a3068582
bcbacf48-50ee-4235-b0a9-2e3608d9006d	1abc8fed-e830-4103-a5ab-c3402b166116	63765624-d7d1-472d-abd4-627127646998
bf41c0a2-38ac-4a32-9e46-8b02ad31acad	e3ede776-6573-4898-9195-fb2a398100b2	fa773eb9-162f-4ea8-9fc4-9c54a3068582
bf6ba752-2c38-4960-9eec-2418a55cbcbe	5c9266d9-5a57-4b6c-aabc-18edce40ae96	cfdb2071-d50e-4ea3-b732-19eb08f1e629
bf6f8414-f507-43c1-8c82-e96a0ce0243a	dfa4b2c2-7d48-4ff7-b5aa-9b65fbde04e1	682d36c0-4256-42ab-811e-054ab3a5b10f
c19fd392-7848-46d8-9258-124cbae5271a	d8d41d59-fe4b-4c54-80d3-751a7bbf714c	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
c6f5af9c-81c6-4cbe-a3f3-35778fe98f36	8765d1b0-e4fc-4686-91ea-f5ad4e929818	db0addff-605e-439f-917b-38016a398755
c97c8ee1-80bf-4e9c-b932-458e95dfd49f	6eaffc67-3d6e-4bb6-9c90-0a604398090d	682d36c0-4256-42ab-811e-054ab3a5b10f
ca3eafef-7ebc-46b4-bae7-0b66f780a073	6890c399-940e-4c2a-9aba-0dd90a50e063	cfdb2071-d50e-4ea3-b732-19eb08f1e629
cd1b44d8-0244-497b-bc22-26745f3fa9b9	a885d8fe-9ecc-4c4e-9b23-55c015ffd3e6	db0addff-605e-439f-917b-38016a398755
cf382172-65a8-4f3b-b0df-356a5b430782	eb9edaa3-2522-4d91-ab86-d786a7250f91	b651aec8-5455-4329-8251-0ceb62cea798
d116cee3-5a07-4925-b841-2d40ce66dfaf	ccf1432a-d667-4fff-8071-efbc9f841976	5d962383-f175-4dd8-af63-8a566a0d2255
d15d6963-e381-45ae-aeea-4f8aeaa74e08	734614d6-908f-4f24-8331-c515a6d70149	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
d330007d-b00f-4452-9a3c-42c736246591	ce7509b0-415c-4d04-a2d8-43c3ee382a72	a73eb36c-7d62-4aa8-901d-1c70b3876b69
d3a1c4a1-a6fe-4fc9-96c3-e5c0cde9a242	4766e158-b2c1-44dd-a36d-18583c490193	fd84aa38-11ef-46af-ade7-241f2a2c08fd
d5b61766-b18a-42a3-9da1-3565f58b60b0	5814389a-4416-4e4d-96a7-58f4801e2757	db0addff-605e-439f-917b-38016a398755
db1d8d29-faa0-4c87-a6e0-805f8e256eb0	29119117-9aa3-4def-9db8-802f70f74e4b	cfdb2071-d50e-4ea3-b732-19eb08f1e629
dd287618-e9a5-4723-976c-770f530197cc	9635b694-a552-42c0-9df3-a6090c9b1923	61bbeadf-3044-4123-929c-4b1e6e2e613e
e364eb78-2d0c-4bf7-a2a1-b1e4978e6088	87ea604f-b245-49c0-9172-3956f1d6eb75	db0addff-605e-439f-917b-38016a398755
e42bd5f5-cbe0-4567-ba90-f7c4bdaf0ff5	a1826c58-197f-4c7e-9909-a8970491fe38	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
e5db5d2c-330a-4fc6-83a8-d30368feb644	9ad0a166-cde2-4817-9acd-363d217422d9	e99b7773-5d71-4dca-ad36-b896dcfb71c4
e91ce781-798b-40f8-ba6d-216b30e80164	b24b3d9d-7454-4657-bb24-3c4f0f40956e	7682acb3-561b-4951-801b-c1564adda131
eb168088-9b48-4ffa-a998-3d26802fd9f0	3101ee42-6788-4ae4-a80b-f7394720b740	fa773eb9-162f-4ea8-9fc4-9c54a3068582
ec17406e-af44-49b0-a0a0-c37605fa7f54	67306ff5-e313-43da-99bc-56b6a6ca65ee	fa773eb9-162f-4ea8-9fc4-9c54a3068582
ee99236d-64fb-4e0b-bcc8-b50c01483f30	3d74762f-cfbc-4cb9-b172-c2aaffc64f30	fa773eb9-162f-4ea8-9fc4-9c54a3068582
efa29819-1ead-44c6-81d0-57d0a7d74673	acbe4f0d-8058-4a88-9255-08104f0037b6	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
f1ca380d-7105-4a93-8af7-dbf9c11f273d	01a26d31-4fcd-4ad3-b08e-1276a4620cb8	cfdb2071-d50e-4ea3-b732-19eb08f1e629
f2cd98a4-ac11-4b73-9c2c-54da015d2fc2	8765d1b0-e4fc-4686-91ea-f5ad4e929818	e99b7773-5d71-4dca-ad36-b896dcfb71c4
f304b70a-6cf1-4bdb-a3d6-8474e90c4e67	22a8384f-6070-4554-89f1-ee327ae48f16	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
f3a82f80-b9cd-4681-ac20-4651b3cbf0c2	d412d761-e42e-4ab2-8e58-1df17b290365	5d962383-f175-4dd8-af63-8a566a0d2255
f434fdd9-a093-4320-8620-d427528a971e	8765d1b0-e4fc-4686-91ea-f5ad4e929818	b651aec8-5455-4329-8251-0ceb62cea798
f89ec4a8-8c77-44fd-a4db-7679bc3d1eab	5814389a-4416-4e4d-96a7-58f4801e2757	e99b7773-5d71-4dca-ad36-b896dcfb71c4
f990edfc-44be-4f3e-bec9-887848cf2328	23f52e10-894f-4e50-970b-202a3127a1d9	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
fac29c72-f1eb-4a0e-aa60-e4d490141636	03d492f0-4458-48e5-9ee8-06f09f660218	cfdb2071-d50e-4ea3-b732-19eb08f1e629
fe09960f-404d-4c7a-b675-cfcfd2fb735d	885809b5-843a-4ec9-bafe-da1472b73a03	cfdb2071-d50e-4ea3-b732-19eb08f1e629
\.


--
-- Data for Name: mst_org_role_map; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_org_role_map ("Id", "DepartmentId", "DesignationId", "RbacRoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "SubDepartmentId", "SubDepartment") FROM stdin;
0717101c-438d-4f69-b0ef-a56fcaf47a45	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
0a909d87-52c0-4ec8-b6f8-b8111cf7310e	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
159c2701-2318-4ba7-b809-fa07d078305e	0aed67b8-c454-439a-a07f-4f46d46d58af	e228c999-bf54-48b4-a373-d2bc9db88554	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
3514262c-d7ec-4d76-81c8-20995e4d22f8	bcbd68c8-c3f3-4396-abb0-0b0e13637958	8dc0d8fe-593d-422a-8b27-5b68fbe6d224	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
359026a0-80bd-4c27-99f3-f63fb1741c6d	310a2f16-15f6-4b82-95f6-ab18b5b429f5	c2e248c8-e917-445f-9f7b-1e25d7bb5abe	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Functional - HR
36243b2d-d487-49db-87d4-a46216df15ae	13c91c98-00ae-4211-acb8-d06e35953806	157d001c-b056-45b1-96a3-3c05bcd8d99c	914d8500-03b6-4a43-a250-244effca1cf1	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
36732dd0-7171-4b3e-a7a6-48427a14f504	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	911f6d7f-8d43-40f2-897a-2f416abf8cf9	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
378f0582-07ec-4a86-a0ff-56575cc28dd0	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	af8a1442-c5ee-409d-aa91-61c9dba852ee	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
37fe770e-4c51-4e31-bbb6-0ca302286b91	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	da990f6e-3379-4cc4-89b7-0ead29da472b	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	Functional - IT Administration
38bd29af-b288-4b62-ae24-679d6b2713ac	8e4e88f1-e294-4554-80cc-92ed6169caeb	834c9e15-c70d-4a0b-bb12-5e55f23c181d	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EM (Engagement Manager)
3bce413c-a323-4f80-a417-190414a3d56b	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	6d25ff6d-e13d-440f-b775-215547af7acb	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
3c8fda3c-c84a-4ef8-80ed-327dc87a3abc	13c91c98-00ae-4211-acb8-d06e35953806	6193be76-40ad-4973-9ee7-246a4d8f4109	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
3f714252-8945-41a7-8520-1c1c8925854e	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	444df30d-c195-42ad-b9a7-d80cdef69ccd	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
4192b456-ca31-4de0-a8ce-698c41732ec4	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	f8502c44-b289-49e4-8401-3dcad4d5bbe0	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	Across all Sub Departments
45469efe-b575-417d-adb7-5c9ee591cb05	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
4804833e-7bbf-4746-9e57-16542de6c3dc	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
49b9c24a-e70e-4cf8-a8c4-e81a49af294b	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
4f83891a-823a-406f-aa9f-5e23abeaba11	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	c0e1a001-0000-4000-8000-000000000001	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	63765624-d7d1-472d-abd4-627127646998	Across all Sub Departments
50581768-4796-4731-b6e2-fc50e877f192	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Across all Sub Departments
554562de-10b1-4365-9e6e-cf769630de75	be8e036d-ad13-4c79-89ec-294e490a6816	2076a9b1-e432-46a9-99b1-36e732159856	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Across all Sub Departments
5808fbe9-5fd4-4e3f-86b4-5a0ad69517bd	be8e036d-ad13-4c79-89ec-294e490a6816	7c2380da-3ee6-46ad-93d6-a79ce3027f29	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
5d79d51f-fcd5-40a1-96e8-8a8ae7c76c00	0aed67b8-c454-439a-a07f-4f46d46d58af	4b680e29-b4fb-4689-9afb-67a7f089f52b	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798	Services - Testing - Red Team
5e1badcc-b621-4c3b-b729-4f3ddf5877a0	8e4e88f1-e294-4554-80cc-92ed6169caeb	9dc69952-eae6-4ec0-a327-67392315f089	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EM (Engagement Manager)
5f392507-7f0b-4614-9679-fcc103e3dbc7	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	73bd55bb-5d0e-4381-8ad2-2238377fca93	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	Functional - IT Administration
651dc356-0c28-457e-bc56-69fdf6ea321f	898c36e9-1cb7-4c56-9148-a3b6893c0149	bb7ccd5f-2f60-49fb-b984-f11fc47add22	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	Across all Sub Departments
6c3fcc16-3602-4bf5-9dd2-7e51fe23d336	0aed67b8-c454-439a-a07f-4f46d46d58af	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798	Services - Testing - Red Team
6ccedaf4-671c-4375-8200-f860eb7d46d9	8e4e88f1-e294-4554-80cc-92ed6169caeb	138434a2-625f-4df5-836d-fcf0cfceef79	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO (Project Management Office)
6df1609a-13f1-469d-96a1-253b2bc66b4f	8e4e88f1-e294-4554-80cc-92ed6169caeb	9050e021-7d84-4401-820e-c0e768abb1ab	64e2ea37-cbd7-4127-b65b-3b003235981a	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	a73eb36c-7d62-4aa8-901d-1c70b3876b69	Across all Sub Departments
72fc796a-c5ba-4bf3-b93f-5b8f52491aed	be8e036d-ad13-4c79-89ec-294e490a6816	2b1558e3-158a-4a84-ae80-053129861a64	64c49f37-a38a-46a6-9622-7427f1501658	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
73687605-0927-471b-b8c2-ec61f4d5164e	0aed67b8-c454-439a-a07f-4f46d46d58af	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
7428ebde-4c77-4358-bc21-6acef30a85a4	13c91c98-00ae-4211-acb8-d06e35953806	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
759ce52f-d3bf-414e-bd79-c33c038dfdf6	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	efc1df20-ca04-44a6-87b2-7cae1ff50a88	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
766c6052-09ad-44e4-8746-ed4795e712f1	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
76ad509e-ba7a-412e-a0cb-be0b8eeb8305	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0c1a5ef4-7fca-45dc-8253-87afa21a1df9	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
003fd050-8939-4d05-ac2b-29876038cb76	be8e036d-ad13-4c79-89ec-294e490a6816	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
047399e0-7821-4f80-be7a-78057c4c2f5f	be8e036d-ad13-4c79-89ec-294e490a6816	195d6a81-8457-4b60-9382-6a3a0664f0e9	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
0a1dda59-5a52-496e-8d30-5f082dbe343e	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	e36018c5-bf48-4f93-bef7-93e8864a0b51	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
0f8dfe0e-d5d5-4a23-b9dc-cff6d71ae84f	8e4e88f1-e294-4554-80cc-92ed6169caeb	2a76927c-461a-48e4-8190-dea7361ef3db	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO (Project Management Office)
128f2bec-ea83-4f7e-8115-9899a302d677	bcbd68c8-c3f3-4396-abb0-0b0e13637958	155642eb-a633-4460-b658-aca9fde2d817	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
15e4938e-241c-4f53-b64e-56a4b2201981	310a2f16-15f6-4b82-95f6-ab18b5b429f5	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Functional - HR
1c213096-46a8-48e1-b353-fdf2d25074ab	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	c70b9832-841e-4864-9b85-eaba3c0a995f	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	Functional - IT Administration
79d8ed54-9a91-4486-a19f-e5485de7b490	0aed67b8-c454-439a-a07f-4f46d46d58af	e2b4be77-2b20-4064-974d-e6322e7240b4	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	88b29e0c-39b7-4169-ab5c-350075014a84	Services - Testing - Cloud & AI
7d7850cf-72da-411d-ba58-bd2d4a43ca28	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	c0f974c3-f49c-449a-9276-aa64ce501344	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
81a34a8f-1fb9-431f-bc96-1bb95dab3fdb	8e4e88f1-e294-4554-80cc-92ed6169caeb	8b57cfd5-5d4e-44a3-9646-b36873c111c2	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EM (Engagement Manager)
81e65582-e98d-4ded-b699-ea7fcb82f071	bcbd68c8-c3f3-4396-abb0-0b0e13637958	4ef1cb5b-9688-4ce2-95b3-6a0863200166	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
837d9855-e239-4046-83d9-ae224ecce6ef	13c91c98-00ae-4211-acb8-d06e35953806	272973a6-c052-4aef-bf32-9e24f7eb6cc9	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
85559f41-c8d4-44b1-8906-a5e1d064f78c	bcbd68c8-c3f3-4396-abb0-0b0e13637958	1f97b442-95c5-4b11-93a0-ea146534ae85	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
86237191-01ee-4aad-9a6b-e75600c375fc	0aed67b8-c454-439a-a07f-4f46d46d58af	c6c6cd04-6df3-4593-b686-e4b9d362c96f	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Services - Testing - DevSecOps
872930ee-4d00-4d37-a2cb-dc57167f6973	0aed67b8-c454-439a-a07f-4f46d46d58af	163d8c87-8f90-4295-a926-2e912c625a1c	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
8a351e0a-8631-4aca-9598-81b276dbc990	0aed67b8-c454-439a-a07f-4f46d46d58af	767a00dd-6f09-4f64-a44e-8fbe901222af	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Services - Testing - DevSecOps
8a92cbcd-7247-4f89-94a4-546013a78a29	13c91c98-00ae-4211-acb8-d06e35953806	e2b10def-c91d-45da-94c5-f5530e743aa2	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Across all Sub Departments
8fbc1e25-42da-426a-be89-975dde3326bc	be8e036d-ad13-4c79-89ec-294e490a6816	3e60b693-d3dd-4481-95c4-9f02da21625c	701aaa2c-a899-4def-bf5f-e17511874409	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
98b476d3-39f3-4af1-83df-00639379db5e	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	48429bb5-c583-4684-b30a-7ed443b671ca	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
999c4385-21ef-4a47-800f-1c08938edcee	be8e036d-ad13-4c79-89ec-294e490a6816	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	701aaa2c-a899-4def-bf5f-e17511874409	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
a0c6147f-a977-4215-840a-60f95d2bd729	898c36e9-1cb7-4c56-9148-a3b6893c0149	9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	R&D (Research & Development)
a2113157-8223-486e-a506-90ae7a3daa93	310a2f16-15f6-4b82-95f6-ab18b5b429f5	7d542941-65b9-499b-81b3-239748d6da52	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Functional - HR
a220a973-9f98-4654-8a57-ee6b44579be5	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	ffed7aa1-e88f-4281-919f-8d49fbabf5a5	a5bfe265-981a-4723-b7bb-6ddc389db7f0	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	45755b2a-741a-4990-ab78-8f65090f75b1	Leading Delivery Department
a3451572-fefd-4cec-aa55-b28d3d3cac92	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	778f1120-9633-4933-9160-ddaa46668838	62a927b7-9fd8-461a-b64e-1aa441eeba4d	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	a12ac80b-a665-4301-898e-e9ca3d44bb20	Leading Sales & A/C Department
a77285b6-5266-4959-8399-f34dfbfcb44e	be8e036d-ad13-4c79-89ec-294e490a6816	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
a7cb72a9-ec77-44e1-998a-a0638f8becc5	0aed67b8-c454-439a-a07f-4f46d46d58af	35a6b1af-dc78-4632-a9f4-eedabdbdcb52	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Services - Testing - DevSecOps
ab07d7c9-e503-4641-8db6-25ac3fc0993e	bcbd68c8-c3f3-4396-abb0-0b0e13637958	caa227a1-2dcf-4195-ab9c-8f76d1862daa	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Across all Sub Departments
af28c045-efab-45db-83dc-c487bab9019f	8e4e88f1-e294-4554-80cc-92ed6169caeb	d8a2b9e5-f54d-4344-a78d-c6c840467543	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EM (Engagement Manager)
b11be1e9-662a-4bc7-b06b-7f401c8b00b3	898c36e9-1cb7-4c56-9148-a3b6893c0149	f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	R&D (Research & Development)
b2819c45-99c7-4306-9ffb-1d585f0a29d0	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	f20a7445-0b01-4f20-85a5-853101d864ee	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
b3eb1bdf-188b-4292-9cfd-f72381c366f0	0aed67b8-c454-439a-a07f-4f46d46d58af	c1fa4328-a970-48a1-bc08-d50fe36bf44c	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Services - Testing - DevSecOps
e99606cb-d413-47ce-9373-9e6384c53f67	36d04440-a8bb-47f1-a6d9-1f4d144b0bdb	41d1dc59-ea33-44eb-8958-dcf35ad051b0	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 18:30:09.499474+05:30	2026-10-18 18:30:09.78908+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:30:09.78908+05:30	\N	\N
c461074d-4d3d-4573-9947-e6e8b0c1d921	40fed4c8-89b7-4276-b4ef-47fe8cf1ea87	711d4f25-dd76-46cc-accd-4e17e0d6f5cd	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 18:32:39.916388+05:30	2026-10-18 18:32:54.804242+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-18 18:32:54.804242+05:30	\N	\N
f3262a1f-1da9-4619-b644-0bfab7a16c27	316c6b23-b976-4e7f-ae22-c8ea15c365cb	6105c483-1e32-49ff-848c-f193525e6297	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 18:43:54.032822+05:30	2026-10-18 18:43:54.103213+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:43:54.103213+05:30	\N	\N
222358f3-3516-49b6-b7db-60f936d4a8c9	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	0525d830-ead9-44a0-871f-91b7845fec26	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	61bbeadf-3044-4123-929c-4b1e6e2e613e	Leading Compliance & HR Department
2a21a67d-6020-4c2c-b06c-9e394c101fab	be8e036d-ad13-4c79-89ec-294e490a6816	1e7faab8-273d-40df-9f9a-485160186c5a	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Services - Consulting
2d9893c2-a2b8-4a26-a41d-85061c629ec2	310a2f16-15f6-4b82-95f6-ab18b5b429f5	e4e20503-cd55-4393-83fd-6c7e7d7d0a49	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Functional - HR
2faf5d1b-751e-4a11-9b34-33bf797eef82	13c91c98-00ae-4211-acb8-d06e35953806	e2c675a7-92dc-4477-be75-9a304cbe4def	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
305ab402-2d28-4607-ad44-7b1031dea076	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea315f7d-d597-41b3-a999-4f3851bcd020	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
325fcf79-60ee-46bc-931d-612002282ff3	0aed67b8-c454-439a-a07f-4f46d46d58af	8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	88b29e0c-39b7-4169-ab5c-350075014a84	Services - Testing - Cloud & AI
b79f5fee-71cf-4fe3-b61f-7e3811fedcea	310a2f16-15f6-4b82-95f6-ab18b5b429f5	485012d4-2c28-4bc4-92c7-3609e3e3749e	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Functional - HR
b823d89e-aab0-477f-8b85-7129d59dd202	898c36e9-1cb7-4c56-9148-a3b6893c0149	3356f353-1566-4df6-9958-fa01d67d13c7	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	R&D (Research & Development)
bf03ad3b-c399-4afa-a0e2-682f1d475fe8	8e4e88f1-e294-4554-80cc-92ed6169caeb	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO (Project Management Office)
c034e919-e8b3-4bcc-8ee2-72f4fe2ad36f	8e4e88f1-e294-4554-80cc-92ed6169caeb	b3309eea-7374-4a8d-ac13-481b2a7fd492	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO (Project Management Office)
c1010573-777c-45fa-8b66-c77e8e4cbc3f	310a2f16-15f6-4b82-95f6-ab18b5b429f5	e8c22eff-0daf-4690-a537-c8b0b6110a01	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	Across all Sub Departments
c6edab11-cbcb-4e05-aab3-d7d0b493c4fe	0aed67b8-c454-439a-a07f-4f46d46d58af	9858c224-f97f-4ff8-908d-f46bd5e2243c	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
caa92f5c-1925-436c-9bf0-b270d5ddb38d	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b5f39dd8-c305-489d-9f7d-9adfd010a134	111cc3cd-6d35-43ce-be91-dde90d3d4015	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
ccff1a9e-10e0-43e8-9379-77811383a397	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	4650d4e0-f73c-4688-ae5f-830a46348ff9	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
cf705a0a-b654-4219-955c-a187d514a84f	0aed67b8-c454-439a-a07f-4f46d46d58af	ae255622-ddcc-45ea-a699-8ec416fe57ab	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Services - Testing - DevSecOps
da6c7063-b8d6-47d9-8ad6-e5654b1a6190	13c91c98-00ae-4211-acb8-d06e35953806	b2b687ef-fd62-4cb7-a826-b40a35da7b2c	914d8500-03b6-4a43-a250-244effca1cf1	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Functional - Sales
e064b573-153e-4f5c-bca0-37d89be9564a	bcbd68c8-c3f3-4396-abb0-0b0e13637958	96efad7d-8b7f-4d7f-a862-c0a6bec3789f	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
e323d911-96c9-4d01-be14-6ff9f00b5f68	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
e91d743d-70da-4bbe-92ce-8e9bf436acd9	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	Services - Operations
eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Across all Sub Departments
ef3cba27-0a2a-4348-82e3-7d86feed3e31	bcbd68c8-c3f3-4396-abb0-0b0e13637958	6e606c29-2ebf-4ab8-8006-aaedd5680009	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Functional - Accounts
f0a049a7-2bcd-4cf1-a57c-2b2a22cdd6de	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	\N	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra
fcd178d9-a936-4f02-a42a-ea9bdcf646a2	0aed67b8-c454-439a-a07f-4f46d46d58af	85cc9fbe-98a4-464d-a638-05f40529c6de	92aa9169-28d9-4754-a570-553b067642ed	2026-10-18 15:08:17.830203+05:30	2026-10-22 12:21:47.145117+05:30	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798	Services - Testing - Red Team
\.


--
-- Data for Name: mst_org_role_sub_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_org_role_sub_departments ("Id", "OrgRoleMapId", "SubDepartmentId") FROM stdin;
00efdd86-434d-40ca-b126-845855693970	79d8ed54-9a91-4486-a19f-e5485de7b490	88b29e0c-39b7-4169-ab5c-350075014a84
0363454a-3b75-4131-beba-ff8a400e99cb	73687605-0927-471b-b8c2-ec61f4d5164e	e99b7773-5d71-4dca-ad36-b896dcfb71c4
06593d38-8a63-48be-9b79-cc403b2c9874	b11be1e9-662a-4bc7-b06b-7f401c8b00b3	7682acb3-561b-4951-801b-c1564adda131
07fa8162-5568-4140-adfa-c2386e339c30	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	e99b7773-5d71-4dca-ad36-b896dcfb71c4
07fc155c-cdec-4e39-a0c7-1690ff14032a	159c2701-2318-4ba7-b809-fa07d078305e	682d36c0-4256-42ab-811e-054ab3a5b10f
08ed7ee3-ca60-4e00-8df0-1c49c0a35968	37fe770e-4c51-4e31-bbb6-0ca302286b91	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
0ba452ac-85aa-4fe3-b885-871d16526299	c034e919-e8b3-4bcc-8ee2-72f4fe2ad36f	fd84aa38-11ef-46af-ade7-241f2a2c08fd
0c648b5e-ef20-458a-a9fb-a3c2c0d886ca	4f83891a-823a-406f-aa9f-5e23abeaba11	63765624-d7d1-472d-abd4-627127646998
0dee5a69-667e-45a5-9649-4954f6c09ac3	999c4385-21ef-4a47-800f-1c08938edcee	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
0f0560e3-3ba2-451a-ba76-0e71ad57cb71	0a909d87-52c0-4ec8-b6f8-b8111cf7310e	e99b7773-5d71-4dca-ad36-b896dcfb71c4
106c5a92-249c-46a5-b394-0e8535ae88b0	4804833e-7bbf-4746-9e57-16542de6c3dc	cfdb2071-d50e-4ea3-b732-19eb08f1e629
117c234e-bc69-43e9-af10-175125407758	159c2701-2318-4ba7-b809-fa07d078305e	e99b7773-5d71-4dca-ad36-b896dcfb71c4
120f3f17-b474-489b-9cff-7d777166d0ab	5808fbe9-5fd4-4e3f-86b4-5a0ad69517bd	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
1227331f-40a9-4bb7-a1e6-28c18dd70877	766c6052-09ad-44e4-8746-ed4795e712f1	cfdb2071-d50e-4ea3-b732-19eb08f1e629
128b833a-88a7-4a1d-9bd6-7335d86eda89	5f392507-7f0b-4614-9679-fcc103e3dbc7	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
13a72fdb-d1a2-4dd3-a473-4e1ce0ac3cbf	5d79d51f-fcd5-40a1-96e8-8a8ae7c76c00	b651aec8-5455-4329-8251-0ceb62cea798
16fe9d7a-be4b-4901-8f86-96b0b58552e9	222358f3-3516-49b6-b7db-60f936d4a8c9	61bbeadf-3044-4123-929c-4b1e6e2e613e
19f0f9c3-3cd3-4c0c-ba7c-49307f5cc40e	a2113157-8223-486e-a506-90ae7a3daa93	c88d783b-b628-4f3a-a972-aa56aeed5e77
1b03145c-cb08-426f-87cf-0664171591b9	36732dd0-7171-4b3e-a7a6-48427a14f504	cfdb2071-d50e-4ea3-b732-19eb08f1e629
1b377251-905e-4673-a261-6511c26c0e8e	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	b651aec8-5455-4329-8251-0ceb62cea798
1b4c2a40-7bc5-4a01-821a-5e18f12e91c0	378f0582-07ec-4a86-a0ff-56575cc28dd0	cfdb2071-d50e-4ea3-b732-19eb08f1e629
1c9d0b45-ed7a-4ce6-927e-959ab1e8bed7	e323d911-96c9-4d01-be14-6ff9f00b5f68	db0addff-605e-439f-917b-38016a398755
214c9e1a-d6e8-4ade-8e6b-30382926aaa0	c1010573-777c-45fa-8b66-c77e8e4cbc3f	c88d783b-b628-4f3a-a972-aa56aeed5e77
24e28b40-3668-4624-aa59-5cf4b516c628	72fc796a-c5ba-4bf3-b93f-5b8f52491aed	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
293bd7d0-0804-458c-b5ca-c2621784180a	c6edab11-cbcb-4e05-aab3-d7d0b493c4fe	e99b7773-5d71-4dca-ad36-b896dcfb71c4
32371481-35eb-472c-9a90-ea38c00b4162	ab07d7c9-e503-4641-8db6-25ac3fc0993e	5d962383-f175-4dd8-af63-8a566a0d2255
365a25cb-6db9-49a6-bc65-dd1d30777421	359026a0-80bd-4c27-99f3-f63fb1741c6d	c88d783b-b628-4f3a-a972-aa56aeed5e77
36b1b04a-08f5-4190-a362-5c628518f010	047399e0-7821-4f80-be7a-78057c4c2f5f	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
370e7cf6-3bbc-4ed4-be2e-e95b7ceb3d8b	b3eb1bdf-188b-4292-9cfd-f72381c366f0	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
3d66d3bf-2b28-435b-a11f-9d3b54dc3351	f0a049a7-2bcd-4cf1-a57c-2b2a22cdd6de	682d36c0-4256-42ab-811e-054ab3a5b10f
3ffbc5e4-58a2-404d-8a16-f78c700c0aa3	e323d911-96c9-4d01-be14-6ff9f00b5f68	682d36c0-4256-42ab-811e-054ab3a5b10f
4014595d-315f-433c-9e3e-a6aa8e626c48	5e1badcc-b621-4c3b-b729-4f3ddf5877a0	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
41866094-25ee-4cc0-8ebd-8ebb44e68169	b2819c45-99c7-4306-9ffb-1d585f0a29d0	cfdb2071-d50e-4ea3-b732-19eb08f1e629
41e490e5-990f-4189-8cab-00791b36907b	fcd178d9-a936-4f02-a42a-ea9bdcf646a2	b651aec8-5455-4329-8251-0ceb62cea798
427cd07b-e8cd-463d-a7da-e3e6ae9ea0cf	da6c7063-b8d6-47d9-8ad6-e5654b1a6190	fa773eb9-162f-4ea8-9fc4-9c54a3068582
429e6d49-dd1f-4a3d-b769-8f4f019b1955	e064b573-153e-4f5c-bca0-37d89be9564a	5d962383-f175-4dd8-af63-8a566a0d2255
453d8ecc-6283-412b-b4a5-33e4f0710941	0a909d87-52c0-4ec8-b6f8-b8111cf7310e	db0addff-605e-439f-917b-38016a398755
47731408-827d-4a7e-9ba9-ddc0158d0293	b823d89e-aab0-477f-8b85-7129d59dd202	7682acb3-561b-4951-801b-c1564adda131
47e0061f-0fcc-43a3-bca1-ec6586216364	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	88b29e0c-39b7-4169-ab5c-350075014a84
48132aaa-ac22-4291-95ff-94b0bc72834a	159c2701-2318-4ba7-b809-fa07d078305e	db0addff-605e-439f-917b-38016a398755
4b15756d-50a5-488e-837d-48003e5af764	0717101c-438d-4f69-b0ef-a56fcaf47a45	db0addff-605e-439f-917b-38016a398755
4d3836b7-a84d-4b64-8de2-fbd9272b3a54	3f714252-8945-41a7-8520-1c1c8925854e	cfdb2071-d50e-4ea3-b732-19eb08f1e629
4d565753-bea1-4459-9060-1f07fa58b5cb	73687605-0927-471b-b8c2-ec61f4d5164e	db0addff-605e-439f-917b-38016a398755
5115d375-3290-4db4-8889-9d7546f1cb92	128f2bec-ea83-4f7e-8115-9899a302d677	5d962383-f175-4dd8-af63-8a566a0d2255
5a185c1c-f969-480f-a1bd-cf73f3d48a0a	3bce413c-a323-4f80-a417-190414a3d56b	cfdb2071-d50e-4ea3-b732-19eb08f1e629
5da5c4ef-eec7-40ad-84f8-d547567fa554	7428ebde-4c77-4358-bc21-6acef30a85a4	fa773eb9-162f-4ea8-9fc4-9c54a3068582
5de30269-c9e0-40aa-a16d-242e28b672b7	ef3cba27-0a2a-4348-82e3-7d86feed3e31	5d962383-f175-4dd8-af63-8a566a0d2255
60aaf9b5-b126-4e3a-83ed-269a83f75aaf	3514262c-d7ec-4d76-81c8-20995e4d22f8	5d962383-f175-4dd8-af63-8a566a0d2255
6104b52b-46c4-4fa0-9a40-d2444f74b548	c6edab11-cbcb-4e05-aab3-d7d0b493c4fe	682d36c0-4256-42ab-811e-054ab3a5b10f
643780fe-5525-49e6-90a7-941f346de02b	73687605-0927-471b-b8c2-ec61f4d5164e	682d36c0-4256-42ab-811e-054ab3a5b10f
64f521da-c93b-4c31-bb7d-8d18c2d13e97	bf03ad3b-c399-4afa-a0e2-682f1d475fe8	fd84aa38-11ef-46af-ade7-241f2a2c08fd
677d79db-3138-43bd-9c2b-13fc02f38b50	49b9c24a-e70e-4cf8-a8c4-e81a49af294b	db0addff-605e-439f-917b-38016a398755
6875be0c-19f2-411b-a118-e8da287d0b81	7d7850cf-72da-411d-ba58-bd2d4a43ca28	cfdb2071-d50e-4ea3-b732-19eb08f1e629
69532ccc-7125-4ebb-8c95-ab73efa5c49c	8fbc1e25-42da-426a-be89-975dde3326bc	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
6b3d3d34-f273-4a2c-bcae-11a4d9059c2e	8a92cbcd-7247-4f89-94a4-546013a78a29	fa773eb9-162f-4ea8-9fc4-9c54a3068582
6ed78cb8-1277-4f79-a966-4c4d36614fcb	45469efe-b575-417d-adb7-5c9ee591cb05	e99b7773-5d71-4dca-ad36-b896dcfb71c4
6f145732-59e3-4655-b98b-1addf9f00dd7	651dc356-0c28-457e-bc56-69fdf6ea321f	7682acb3-561b-4951-801b-c1564adda131
6f400760-5693-4cf1-b103-d5beedcc75a2	ccff1a9e-10e0-43e8-9379-77811383a397	cfdb2071-d50e-4ea3-b732-19eb08f1e629
7000cfad-1597-4331-80e9-f57e5317dae0	c6edab11-cbcb-4e05-aab3-d7d0b493c4fe	db0addff-605e-439f-917b-38016a398755
70ccda9a-826e-4ee4-b48a-b4995b595b3c	6df1609a-13f1-469d-96a1-253b2bc66b4f	a73eb36c-7d62-4aa8-901d-1c70b3876b69
7103ad6d-2158-407e-8f2b-a519003c4498	50581768-4796-4731-b6e2-fc50e877f192	cfdb2071-d50e-4ea3-b732-19eb08f1e629
74622506-9c24-41dc-8c92-3895e1a4eea9	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	682d36c0-4256-42ab-811e-054ab3a5b10f
76cd242d-6244-434a-a8a8-3faafce03043	86237191-01ee-4aad-9a6b-e75600c375fc	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
7cfe6500-ad75-49f8-a726-af7fa88525bd	305ab402-2d28-4607-ad44-7b1031dea076	cfdb2071-d50e-4ea3-b732-19eb08f1e629
7d325dfa-ba1c-43d6-ba6c-9a239756e549	a0c6147f-a977-4215-840a-60f95d2bd729	7682acb3-561b-4951-801b-c1564adda131
7f45de9d-024d-43fd-aead-0f40969f3fc7	45469efe-b575-417d-adb7-5c9ee591cb05	db0addff-605e-439f-917b-38016a398755
80485e4f-3c87-499e-90c5-ef44351507ff	872930ee-4d00-4d37-a2cb-dc57167f6973	682d36c0-4256-42ab-811e-054ab3a5b10f
821072a4-0f9e-4d49-b1a6-5c10e15f0eeb	a220a973-9f98-4654-8a57-ee6b44579be5	45755b2a-741a-4990-ab78-8f65090f75b1
828e00e2-c0cb-4b29-aa37-edec138a173c	003fd050-8939-4d05-ac2b-29876038cb76	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
83bae7e8-171f-4d6e-b9ed-3361e3aa7068	81a34a8f-1fb9-431f-bc96-1bb95dab3fdb	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
895acee8-f40f-44da-8626-5e4f63d91565	76ad509e-ba7a-412e-a0cb-be0b8eeb8305	cfdb2071-d50e-4ea3-b732-19eb08f1e629
8f8b1e8e-0727-4f7b-ace5-a9ea45314ae8	325fcf79-60ee-46bc-931d-612002282ff3	88b29e0c-39b7-4169-ab5c-350075014a84
91fc220c-9790-4cfc-a312-14212245783b	759ce52f-d3bf-414e-bd79-c33c038dfdf6	e99b7773-5d71-4dca-ad36-b896dcfb71c4
95ee9fa7-4619-4b0c-93b6-d96a03beb7a5	0a1dda59-5a52-496e-8d30-5f082dbe343e	cfdb2071-d50e-4ea3-b732-19eb08f1e629
98bd0e70-3ea4-4009-91dc-6cc76540bae5	3c8fda3c-c84a-4ef8-80ed-327dc87a3abc	fa773eb9-162f-4ea8-9fc4-9c54a3068582
98f8269c-972d-4f36-bacd-f1449245b1e7	36243b2d-d487-49db-87d4-a46216df15ae	fa773eb9-162f-4ea8-9fc4-9c54a3068582
99e1968b-d9d6-48ff-a857-312e396091b5	e91d743d-70da-4bbe-92ce-8e9bf436acd9	cfdb2071-d50e-4ea3-b732-19eb08f1e629
99f9637c-f332-4f0e-89a8-8683b8639ca0	1c213096-46a8-48e1-b353-fdf2d25074ab	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
9a5973e0-3802-4916-a403-9a92b55021fe	af28c045-efab-45db-83dc-c487bab9019f	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
9be76499-e98b-4425-ae1e-463653645370	872930ee-4d00-4d37-a2cb-dc57167f6973	db0addff-605e-439f-917b-38016a398755
9c8bb6c0-6e95-4cd2-b43c-d84b63aee02e	38bd29af-b288-4b62-ae24-679d6b2713ac	63bc0f54-4d35-4279-bb62-4daeff6ceeaa
9d19c8a7-e308-49d7-be24-75e5623d44d1	a7cb72a9-ec77-44e1-998a-a0638f8becc5	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
9d5a487a-6b41-4465-904a-68db349bc93d	2a21a67d-6020-4c2c-b06c-9e394c101fab	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
aeae94bc-1571-4e05-b29b-5dbffbce8c5a	a3451572-fefd-4cec-aa55-b28d3d3cac92	a12ac80b-a665-4301-898e-e9ca3d44bb20
af7bb99b-701d-44b0-a3d8-9d6208f4ee78	49b9c24a-e70e-4cf8-a8c4-e81a49af294b	682d36c0-4256-42ab-811e-054ab3a5b10f
b3bdce17-39d2-4ca0-931d-6d3491971f34	98b476d3-39f3-4af1-83df-00639379db5e	cfdb2071-d50e-4ea3-b732-19eb08f1e629
b4b5c8af-9c42-4fa2-bc37-325144095a65	4192b456-ca31-4de0-a8ce-698c41732ec4	4dc4a56b-f458-4047-a1ca-345eaa08b5e3
b6e1b235-929b-47c8-8b7c-0036b1b8c46b	872930ee-4d00-4d37-a2cb-dc57167f6973	e99b7773-5d71-4dca-ad36-b896dcfb71c4
b7f64928-814f-4844-94e3-fdaf3c0c89e9	caa92f5c-1925-436c-9bf0-b270d5ddb38d	cfdb2071-d50e-4ea3-b732-19eb08f1e629
b8d942a7-5170-4d21-809c-7fc98544d829	6c3fcc16-3602-4bf5-9dd2-7e51fe23d336	b651aec8-5455-4329-8251-0ceb62cea798
be0d2b58-b5d4-4830-a6c5-c6ad31ff7a66	0717101c-438d-4f69-b0ef-a56fcaf47a45	e99b7773-5d71-4dca-ad36-b896dcfb71c4
c168f1de-629a-493d-8f07-766e3b70610c	49b9c24a-e70e-4cf8-a8c4-e81a49af294b	e99b7773-5d71-4dca-ad36-b896dcfb71c4
c3c5443c-d10d-45a7-aec6-e4b0be16826f	85559f41-c8d4-44b1-8906-a5e1d064f78c	5d962383-f175-4dd8-af63-8a566a0d2255
c4ce9c1f-4981-483a-b5a1-c2d1aac42c72	8a351e0a-8631-4aca-9598-81b276dbc990	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
cd1f71ba-98f3-4c23-861a-56b723cc7257	0a909d87-52c0-4ec8-b6f8-b8111cf7310e	682d36c0-4256-42ab-811e-054ab3a5b10f
cd3ffd5f-6270-4e16-a5b4-4eafe39c748a	837d9855-e239-4046-83d9-ae224ecce6ef	fa773eb9-162f-4ea8-9fc4-9c54a3068582
d230c0f7-831a-481d-91c2-0661209016ee	759ce52f-d3bf-414e-bd79-c33c038dfdf6	db0addff-605e-439f-917b-38016a398755
d5281d48-efb6-418f-849b-fd26f3f3a6be	e323d911-96c9-4d01-be14-6ff9f00b5f68	e99b7773-5d71-4dca-ad36-b896dcfb71c4
d5cf2f16-ac00-438b-b568-ecc14b9553bb	0717101c-438d-4f69-b0ef-a56fcaf47a45	682d36c0-4256-42ab-811e-054ab3a5b10f
d607c559-f51f-44b6-8d3e-66d2bbbbfb4d	f0a049a7-2bcd-4cf1-a57c-2b2a22cdd6de	e99b7773-5d71-4dca-ad36-b896dcfb71c4
d694627d-1fee-4a2e-b6a6-40c19e08a356	15e4938e-241c-4f53-b64e-56a4b2201981	c88d783b-b628-4f3a-a972-aa56aeed5e77
dc3a579d-e769-4f99-aad5-7786a2ac028e	2faf5d1b-751e-4a11-9b34-33bf797eef82	fa773eb9-162f-4ea8-9fc4-9c54a3068582
de90bb42-7293-44ce-bfe5-174a9c58dc8d	759ce52f-d3bf-414e-bd79-c33c038dfdf6	682d36c0-4256-42ab-811e-054ab3a5b10f
e18169ea-f6bd-479f-8ef6-49b4a781c912	45469efe-b575-417d-adb7-5c9ee591cb05	682d36c0-4256-42ab-811e-054ab3a5b10f
e32346a7-72a5-49e0-b9e0-73218482dcd7	2d9893c2-a2b8-4a26-a41d-85061c629ec2	c88d783b-b628-4f3a-a972-aa56aeed5e77
e4fe4ba5-14fd-4c18-8b18-b2cab4e35ef9	554562de-10b1-4365-9e6e-cf769630de75	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
e9f466da-c19e-48b6-a108-f2b05affebe3	f0a049a7-2bcd-4cf1-a57c-2b2a22cdd6de	db0addff-605e-439f-917b-38016a398755
ef7794f3-b543-4205-b13d-97667c3c2086	cf705a0a-b654-4219-955c-a187d514a84f	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
f3e0a619-d828-4802-aea5-26b94f9b2f97	6ccedaf4-671c-4375-8200-f860eb7d46d9	fd84aa38-11ef-46af-ade7-241f2a2c08fd
f6c71875-cad1-4211-af58-e28368b15442	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9
f825d6f4-9587-47bb-9a1d-29872917d522	a77285b6-5266-4959-8399-f34dfbfcb44e	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c
f8cc3d37-a1a3-4c06-87d2-e842aae4da5f	0f8dfe0e-d5d5-4a23-b9dc-cff6d71ae84f	fd84aa38-11ef-46af-ade7-241f2a2c08fd
f9f65ca6-36e5-4b94-bf98-546e7150ac74	eceb2bfe-e8ed-48d4-910e-f1d4e42d1be5	db0addff-605e-439f-917b-38016a398755
fcc493d3-cd34-4a3c-96ea-c5edba3e81a8	b79f5fee-71cf-4fe3-b61f-7e3811fedcea	c88d783b-b628-4f3a-a972-aa56aeed5e77
ffdc0f71-e91d-4e0e-951f-9fcc3fd1487b	81e65582-e98d-4ded-b699-ea7fcb82f071	5d962383-f175-4dd8-af63-8a566a0d2255
\.


--
-- Data for Name: mst_post_graduation_degrees; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
02b11fcf-15dc-438e-857d-fe1df19f925b	me	ME	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
29c8b610-bca4-41b7-8199-960c4907c189	mba	MBA	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
42343c31-3dfa-44e6-a433-5d0c66dcfaf0	na	NA	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
93a0a0ed-91ed-41e3-91c1-09e94f248667	mtech	M.Tech	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
9ea82119-8356-4b91-87ea-aeeb679b9cf6	msc	M.Sc	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
c7bd4e1d-4826-421d-b473-3a926672050e	ma	M.A.	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
e0725237-7a46-48ee-9ff1-3969f2571d2a	mcom	M.Com	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
e2722a3d-0767-4299-afa9-04d89c28cd7c	mca	MCA	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
ec8299cf-acb1-4a26-aed5-a03db0ff8bfe	ms	MS	t	2026-09-08 10:29:44.231454+05:30	\N	\N	\N	\N
69a230fc-d84b-402c-85f7-25a048cc61fd	zz_probe_mba	ZZ Probe MBA	f	2026-10-18 18:30:09.404433+05:30	2026-10-18 18:30:09.74092+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:30:09.74092+05:30
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
20ffbe9b-96ca-496e-ab2e-50ccf3c91246	l3	L3	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
37016f9a-2474-400d-99ae-18157aaad035	l1	L1	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
822f92eb-c6fa-4c0f-a8ec-e4c2d16af583	l4	L4	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
e5f5511b-dea6-421c-8c0e-b271e4ee5d43	l5	L5	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
ebed343e-301f-4984-b292-fa8d1cb1623c	l2	L2	t	2026-08-20 18:21:10.222702+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_service_catalog; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_service_catalog ("Id", "Code", "Name", "SubDepartmentId", "DefaultTools", "DefaultUnitPrice", "DefaultDurationDays", "Description", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Abbreviation") FROM stdin;
d0000001-0000-0000-0000-000000000001	PT001	External Network Penetration Testing	c0000001-0000-0000-0000-000000000001	Nessus, Metasploit	89798.00	4	\N	t	1	2026-09-28 13:11:38.11983+05:30	2026-10-29 20:54:32.000339+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	ENPT
d0000012-0000-0000-0000-000000000012	COMP001	ISO 27001 Security Audit	c0000010-0000-0000-0000-000000000010	AuditBoard, Drata, Vanta	85000.00	8	\N	t	18	2026-09-28 13:11:38.11983+05:30	2026-10-29 19:07:17.349237+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	ISO
d000000c-0000-0000-0000-00000000000c	CS001	AWS Security Assessment	c000000a-0000-0000-0000-00000000000a	Scout2, CloudMapper, AWS Inspector	550000000.00	10	\N	t	12	2026-09-28 13:11:38.11983+05:30	2026-10-29 19:07:17.40003+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	AWS
d0000007-0000-0000-0000-000000000007	VA001	Network Vulnerability Assessment	c0000006-0000-0000-0000-000000000006	Nessus, OpenVAS, Qualys	10500.00	5	\N	t	7	2026-09-28 13:11:38.11983+05:30	2026-10-29 19:27:33.542299+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	NVA
d0000003-0000-0000-0000-000000000003	PT003	Web Application Penetration Testing	c0000002-0000-0000-0000-000000000002	Burp Suite, OWASP ZAP	50000.00	5	\N	t	3	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	WAPT
d000000a-0000-0000-0000-00000000000a	RT001	Full Spectrum Red Team Exercise	c0000009-0000-0000-0000-000000000009	Cobalt Strike, Metasploit, Mimikatz	3434323.00	5	\N	t	10	2026-09-28 13:11:38.11983+05:30	2026-10-29 20:43:32.157503+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	FSRE
d0000006-0000-0000-0000-000000000006	PT006	Thick Client Penetration Testing	c0000005-0000-0000-0000-000000000005	Burp Suite, API Fuzzer	1212545.00	5	\N	t	6	2026-09-28 13:11:38.11983+05:30	2026-10-29 20:51:06.061472+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	TKPT
d0000004-0000-0000-0000-000000000004	PT004	Mobile Application Penetration Testing	c0000003-0000-0000-0000-000000000003	Frida, Burp Suite Mobile	55000.00	5	\N	t	4	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	MAPT
d0000005-0000-0000-0000-000000000005	PT005	API Penetration Testing	c0000004-0000-0000-0000-000000000004	Postman, Burp Suite	40000.00	4	\N	t	5	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	APIPT
d0000008-0000-0000-0000-000000000008	VA002	Web Application Vulnerability Assessment	c0000007-0000-0000-0000-000000000007	Acunetix, Qualys, Rapid7	40000.00	4	\N	t	8	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	WAVA
d0000009-0000-0000-0000-000000000009	VA003	Cloud Infrastructure Vulnerability Assessment	c0000008-0000-0000-0000-000000000008	Dome9, CloudSploit	50000.00	4	\N	t	9	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	CIVA
d000000b-0000-0000-0000-00000000000b	RT002	Targeted Red Team Engagement	c0000009-0000-0000-0000-000000000009	Custom Tools, Cobalt Strike	80000.00	10	\N	t	11	2026-09-28 13:11:38.11983+05:30	2026-10-18 13:16:18.367678+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	TRTE
d000000d-0000-0000-0000-00000000000d	CS002	Azure Security Assessment	c000000b-0000-0000-0000-00000000000b	Azucar, Microsoft Defender, Qualys	55000.00	5	\N	t	13	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	AZURE
d000000e-0000-0000-0000-00000000000e	CS003	Google Cloud Security Assessment	c000000c-0000-0000-0000-00000000000c	GCP Security Command Center	50000.00	5	\N	t	14	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	GCP
d000000f-0000-0000-0000-00000000000f	CODE001	Source Code Security Review	c000000d-0000-0000-0000-00000000000d	SonarQube, Checkmarx, Fortify	65000.00	6	\N	t	15	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	SCSR
d0000010-0000-0000-0000-000000000010	CODE002	Static Application Security Testing (SAST)	c000000e-0000-0000-0000-00000000000e	Checkmarx, Veracode, Fortify	70000.00	7	\N	t	16	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	SAST
d0000011-0000-0000-0000-000000000011	CODE003	Dynamic Application Security Testing (DAST)	c000000f-0000-0000-0000-00000000000f	Burp Suite, Acunetix, AppScan	60000.00	6	\N	t	17	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	DAST
d0000013-0000-0000-0000-000000000013	COMP002	GDPR Compliance Assessment	c0000011-0000-0000-0000-000000000011	OneTrust, TrustArc, Compliance.ai	75000.00	7	\N	t	19	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	GDPR
d0000014-0000-0000-0000-000000000014	COMP003	PCI-DSS Compliance Assessment	c0000012-0000-0000-0000-000000000012	Qualys, Rapid7, Nessus	80000.00	7	\N	t	20	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	PCI
d0000015-0000-0000-0000-000000000015	COMP004	SOC 2 Type II Audit	c0000013-0000-0000-0000-000000000013	AuditBoard, Drata	95000.00	10	\N	t	21	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	SOC2
d0000016-0000-0000-0000-000000000016	SE001	Phishing Campaign & Assessment	c0000014-0000-0000-0000-000000000014	KnowBe4, Gophish, Phish Alert	30000.00	2	\N	t	22	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	PHISH
d0000017-0000-0000-0000-000000000017	SE002	Security Awareness Training Program	c0000015-0000-0000-0000-000000000015	LinkedIn Learning, KnowBe4, SANS	45000.00	4	\N	t	23	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	SATP
d0000018-0000-0000-0000-000000000018	SE003	Vishing & Pretexting Assessment	c0000016-0000-0000-0000-000000000016	Custom, KnowBe4	35000.00	3	\N	t	24	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	VPA
d0000019-0000-0000-0000-000000000019	FOR001	Digital Forensics Investigation	c0000017-0000-0000-0000-000000000017	EnCase, FTK, Volatility, X-Ways	90000.00	8	\N	t	25	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	DFI
d000001a-0000-0000-0000-00000000001a	FOR002	Incident Response & Containment	c0000018-0000-0000-0000-000000000018	Splunk, ELK, Rapid7 InsightIDR	75000.00	7	\N	t	26	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	IRC
d000001b-0000-0000-0000-00000000001b	FOR003	Malware Analysis	c0000019-0000-0000-0000-000000000019	IDA Pro, Ghidra, Wireshark, Cuckoo	70000.00	6	\N	t	27	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	MA
d000001c-0000-0000-0000-00000000001c	NET001	Network Architecture Security Review	c000001a-0000-0000-0000-00000000001a	Nmap, Wireshark, NETMON	55000.00	5	\N	t	28	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	NASR
d000001d-0000-0000-0000-00000000001d	NET002	Firewall & IDS/IPS Configuration Audit	c000001b-0000-0000-0000-00000000001b	Nessus, OpenVAS, Custom Scripts	65000.00	6	\N	t	29	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	FICA
d000001e-0000-0000-0000-00000000001e	NET003	Network Segmentation Assessment	c000001c-0000-0000-0000-00000000001c	Nmap, Shodan, Custom Tools	60000.00	5	\N	t	30	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	NSA
d000001f-0000-0000-0000-00000000001f	THREAT001	Threat Modeling & Risk Assessment	c000001d-0000-0000-0000-00000000001d	Microsoft Threat Modeling Tool, IriusRisk	50000.00	4	\N	t	31	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	TMRA
d0000020-0000-0000-0000-000000000020	THREAT002	Cyber Threat Intelligence Report	c000001e-0000-0000-0000-00000000001e	MISP, Mandiant, CrowdStrike	40000.00	3	\N	t	32	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	CTIR
d0000021-0000-0000-0000-000000000021	THREAT003	Attack Surface Analysis	c000001f-0000-0000-0000-00000000001f	Shodan, Censys, Rapid7 Sonar	45000.00	4	\N	t	33	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N	ASA
7503a7df-4f04-4822-afee-877c328cb3ad	SOC	SOC	52e804e5-4974-44b2-ab7d-d5088795abc7	Burp	4500.00	15	\N	t	1	2026-10-18 15:05:31.941072+05:30	2026-10-18 15:05:55.047757+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	SOC
7f7e8f5c-a5d3-411d-b052-8b1c6c674071	SERVICE1	service_1	f9c3e149-e860-4669-bb23-23e539f289ce	azure	20000.00	3	\N	t	1	2026-10-18 15:48:01.356158+05:30	2026-10-18 15:49:38.355681+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N	SRV1
d0000002-0000-0000-0000-000000000002	PT002	Internal Network Penetration Testing	c0000001-0000-0000-0000-000000000001	Burp Suite, Cobalt Strike	100000.00	5	\N	t	2	2026-09-28 13:11:38.11983+05:30	2026-10-29 20:48:23.710363+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	INPT
ff646bbe-4611-4d80-a733-2d6c8644ea84	FSF	fsf	d4fd66ae-afca-43c9-8eb9-dfb3d4797a76	TBD	50000.00	5	\N	t	1	2026-10-18 14:59:47.339903+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	FSF
\.


--
-- Data for Name: mst_service_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_service_departments ("Id", "Code", "Name", "GroupId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
b0000001-0000-0000-0000-000000000001	PEN_TESTING	Penetration Testing	a2222222-2222-2222-2222-222222222222	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
b0000002-0000-0000-0000-000000000002	VULN_ASSESSMENT	Vulnerability Assessment	a2222222-2222-2222-2222-222222222222	t	2	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
b0000003-0000-0000-0000-000000000003	RED_TEAM	Red Team & Adversary Simulation	a1111111-1111-1111-1111-111111111111	t	3	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
b0000004-0000-0000-0000-000000000004	CLOUD_SECURITY	Cloud Security	a1111111-1111-1111-1111-111111111111	t	4	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
b0000005-0000-0000-0000-000000000005	CODE_APP_SECURITY	Code & Application Security	a2222222-2222-2222-2222-222222222222	t	5	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
b0000006-0000-0000-0000-000000000006	COMPLIANCE_AUDIT	Compliance & Audit	a1111111-1111-1111-1111-111111111111	t	6	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
b0000007-0000-0000-0000-000000000007	SOCIAL_ENGINEERING	Social Engineering & Awareness	a2222222-2222-2222-2222-222222222222	t	7	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
b0000008-0000-0000-0000-000000000008	FORENSICS_IR	Forensics & Incident Response	a1111111-1111-1111-1111-111111111111	t	8	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
b0000009-0000-0000-0000-000000000009	NETWORK_INFRA	Network & Infrastructure	a2222222-2222-2222-2222-222222222222	t	9	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
b000000a-0000-0000-0000-00000000000a	THREAT_INTEL	Threat Intelligence & Modeling	a1111111-1111-1111-1111-111111111111	t	10	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
989349e0-b566-4378-aa34-d5b6b046106f	TESTINGDEPT	testing_dept	a2222222-2222-2222-2222-222222222222	t	10	2026-10-18 13:35:30.193102+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
c45b7e7b-01f3-460d-95a6-d9d5c6013354	ZZEMPTYDEPTCHECK	ZZ Empty Dept Check	a1111111-1111-1111-1111-111111111111	f	11	2026-10-18 13:40:50.941178+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 13:41:49.404314+05:30
2875b963-449a-4c44-a6fc-ccb274ccd210	PENETRATIONTEST	penetration Test	a2222222-2222-2222-2222-222222222222	t	11	2026-10-18 14:55:27.729475+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a18c1408-67e9-4715-ab16-c71f5ac91347	TESTINGDEPT1	Testing dept	a1111111-1111-1111-1111-111111111111	t	12	2026-10-18 15:04:56.055383+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
9227f16e-6363-4fd3-8df0-73466793e314	DEPTTESTING	Dept testing	a1111111-1111-1111-1111-111111111111	t	13	2026-10-18 15:47:36.099103+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
82781ba0-5c73-42ec-b465-85b5c288cea5	SCOPE_APPLICATION_SECURITY	Application Security	a2222222-2222-2222-2222-222222222222	t	12	2026-10-27 13:12:42.052349+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
\.


--
-- Data for Name: mst_service_groups; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_service_groups ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
a1111111-1111-1111-1111-111111111111	RESOURCE	Resource	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
a2222222-2222-2222-2222-222222222222	SCOPE	Scope	t	2	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_service_sub_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_service_sub_departments ("Id", "Code", "Name", "DepartmentId", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
c0000001-0000-0000-0000-000000000001	SUB_NET_PT	Network Penetration Testing	b0000001-0000-0000-0000-000000000001	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000002-0000-0000-0000-000000000002	SUB_WEB_PT	Web Application Penetration Testing	b0000001-0000-0000-0000-000000000001	t	2	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000003-0000-0000-0000-000000000003	SUB_MOB_PT	Mobile Application Penetration Testing	b0000001-0000-0000-0000-000000000001	t	3	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000004-0000-0000-0000-000000000004	SUB_API_PT	API Penetration Testing	b0000001-0000-0000-0000-000000000001	t	4	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000005-0000-0000-0000-000000000005	SUB_THICK_PT	Thick Client Penetration Testing	b0000001-0000-0000-0000-000000000001	t	5	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000006-0000-0000-0000-000000000006	SUB_NET_VA	Network Vulnerability Assessment	b0000002-0000-0000-0000-000000000002	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000007-0000-0000-0000-000000000007	SUB_WEB_VA	Web Application Vulnerability Assessment	b0000002-0000-0000-0000-000000000002	t	2	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000008-0000-0000-0000-000000000008	SUB_CLOUD_VA	Cloud Infrastructure Vulnerability Assessment	b0000002-0000-0000-0000-000000000002	t	3	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000009-0000-0000-0000-000000000009	SUB_ADV_SIM	Adversary Simulation	b0000003-0000-0000-0000-000000000003	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000000a-0000-0000-0000-00000000000a	SUB_AWS_SEC	AWS Security Assessment	b0000004-0000-0000-0000-000000000004	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000000b-0000-0000-0000-00000000000b	SUB_AZURE_SEC	Azure Security Assessment	b0000004-0000-0000-0000-000000000004	t	2	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000000c-0000-0000-0000-00000000000c	SUB_GCP_SEC	Google Cloud Security Assessment	b0000004-0000-0000-0000-000000000004	t	3	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000000d-0000-0000-0000-00000000000d	SUB_CODE_REV	Source Code Security Review	b0000005-0000-0000-0000-000000000005	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000000e-0000-0000-0000-00000000000e	SUB_SAST	Static Application Security Testing	b0000005-0000-0000-0000-000000000005	t	2	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000000f-0000-0000-0000-00000000000f	SUB_DAST	Dynamic Application Security Testing	b0000005-0000-0000-0000-000000000005	t	3	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000010-0000-0000-0000-000000000010	SUB_ISO27001	ISO 27001 Security Audit	b0000006-0000-0000-0000-000000000006	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000011-0000-0000-0000-000000000011	SUB_GDPR	GDPR Compliance Assessment	b0000006-0000-0000-0000-000000000006	t	2	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000012-0000-0000-0000-000000000012	SUB_PCIDSS	PCI-DSS Compliance Assessment	b0000006-0000-0000-0000-000000000006	t	3	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000013-0000-0000-0000-000000000013	SUB_SOC2	SOC 2 Type II Audit	b0000006-0000-0000-0000-000000000006	t	4	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000014-0000-0000-0000-000000000014	SUB_PHISHING	Phishing Campaign & Assessment	b0000007-0000-0000-0000-000000000007	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000015-0000-0000-0000-000000000015	SUB_AWARENESS	Security Awareness Training Program	b0000007-0000-0000-0000-000000000007	t	2	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000016-0000-0000-0000-000000000016	SUB_VISHING	Vishing & Pretexting Assessment	b0000007-0000-0000-0000-000000000007	t	3	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000017-0000-0000-0000-000000000017	SUB_FORENSICS	Digital Forensics Investigation	b0000008-0000-0000-0000-000000000008	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000018-0000-0000-0000-000000000018	SUB_IR	Incident Response & Containment	b0000008-0000-0000-0000-000000000008	t	2	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c0000019-0000-0000-0000-000000000019	SUB_MALWARE	Malware Analysis	b0000008-0000-0000-0000-000000000008	t	3	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000001a-0000-0000-0000-00000000001a	SUB_NET_ARCH	Network Architecture Security Review	b0000009-0000-0000-0000-000000000009	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000001b-0000-0000-0000-00000000001b	SUB_FIREWALL	Firewall & IDS/IPS Configuration Audit	b0000009-0000-0000-0000-000000000009	t	2	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000001c-0000-0000-0000-00000000001c	SUB_NET_SEG	Network Segmentation Assessment	b0000009-0000-0000-0000-000000000009	t	3	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000001d-0000-0000-0000-00000000001d	SUB_THREAT_MOD	Threat Modeling & Risk Assessment	b000000a-0000-0000-0000-00000000000a	t	1	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000001e-0000-0000-0000-00000000001e	SUB_THREAT_REP	Cyber Threat Intelligence Report	b000000a-0000-0000-0000-00000000000a	t	2	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c000001f-0000-0000-0000-00000000001f	SUB_ATTACK_SURF	Attack Surface Analysis	b000000a-0000-0000-0000-00000000000a	t	3	2026-09-28 13:11:38.11983+05:30	\N	\N	\N	\N
c552b8ee-ce22-4f27-8fb2-6ca8eb254073	ZZTEMPSUBDEPT	ZZ Temp Subdept	b0000004-0000-0000-0000-000000000004	f	4	2026-10-18 13:33:08.477637+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	2026-10-18 13:34:37.610157+05:30
d4fd66ae-afca-43c9-8eb9-dfb3d4797a76	DW	dw	2875b963-449a-4c44-a6fc-ccb274ccd210	t	1	2026-10-18 14:59:35.777718+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
52e804e5-4974-44b2-ab7d-d5088795abc7	ITEM	-	a18c1408-67e9-4715-ab16-c71f5ac91347	t	1	2026-10-18 15:05:11.180665+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
f9c3e149-e860-4669-bb23-23e539f289ce	SUBDEPTTEST	Sub dept test	9227f16e-6363-4fd3-8df0-73466793e314	t	1	2026-10-18 15:47:51.018843+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
90038230-ef9f-4cf8-bff6-33cf436f81d1	SCOPE_APPLICATION_SECURITY_API_SECURITY_ASSESSMENT	API Security Assessment	82781ba0-5c73-42ec-b465-85b5c288cea5	t	1	2026-10-27 13:12:42.086564+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
\.


--
-- Data for Name: mst_sub_departments; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_sub_departments ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
45755b2a-741a-4990-ab78-8f65090f75b1	leading_delivery_department	Leading Delivery Department	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
4dc4a56b-f458-4047-a1ca-345eaa08b5e3	functional_it_administration	Functional - IT Administration	t	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
5d962383-f175-4dd8-af63-8a566a0d2255	functional_accounts	Functional - Accounts	t	bcbd68c8-c3f3-4396-abb0-0b0e13637958	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
61bbeadf-3044-4123-929c-4b1e6e2e613e	leading_compliance_hr_department	Leading Compliance & HR Department	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
682d36c0-4256-42ab-811e-054ab3a5b10f	service_testing_appsec	Service - Testing - AppSec	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	services_consulting	Services - Consulting	t	be8e036d-ad13-4c79-89ec-294e490a6816	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
7682acb3-561b-4951-801b-c1564adda131	r_d_research_development	R&D (Research & Development)	t	898c36e9-1cb7-4c56-9148-a3b6893c0149	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
88b29e0c-39b7-4169-ab5c-350075014a84	services_testing_cloud_ai	Services - Testing - Cloud & AI	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	services_testing_devsecops	Services - Testing - DevSecOps	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
a12ac80b-a665-4301-898e-e9ca3d44bb20	leading_sales_a_c_department	Leading Sales & A/C Department	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
b651aec8-5455-4329-8251-0ceb62cea798	services_testing_red_team	Services - Testing - Red Team	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
c88d783b-b628-4f3a-a972-aa56aeed5e77	functional_hr	Functional - HR	t	310a2f16-15f6-4b82-95f6-ab18b5b429f5	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
cfdb2071-d50e-4ea3-b732-19eb08f1e629	services_operations	Services - Operations	t	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
db0addff-605e-439f-917b-38016a398755	service_testing_mobile	Service - Testing - Mobile	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
e99b7773-5d71-4dca-ad36-b896dcfb71c4	service_testing_infra	Service - Testing - Infra	t	0aed67b8-c454-439a-a07f-4f46d46d58af	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
fa773eb9-162f-4ea8-9fc4-9c54a3068582	functional_sales	Functional - Sales	t	13c91c98-00ae-4211-acb8-d06e35953806	2026-10-21 00:01:50.075909+05:30	\N	\N	\N	\N
a73eb36c-7d62-4aa8-901d-1c70b3876b69	functional_project_management	Functional - Project Management	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-10-21 15:07:57.796708+05:30	\N	\N	\N	\N
63765624-d7d1-472d-abd4-627127646998	across_all_sub_departments	Across all Sub Departments	t	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	2026-10-21 00:01:50.075909+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N
25d5ad1f-04c7-4f50-9465-95052b43149d	department_head	Department Head	t	\N	2026-11-16 15:51:45.713396+05:30	\N	\N	\N	\N
32541b0b-61be-408d-8dd0-c5a4ee47fcc5	engineering	Engineering	t	\N	2026-11-16 15:51:45.714017+05:30	\N	\N	\N	\N
ceaee55a-9424-45fb-813c-9b1ed5f521bf	senior_project_management	Senior Project Management	t	\N	2026-11-16 15:51:45.699459+05:30	\N	\N	\N	\N
250e1738-3eae-4447-aee6-3cee5341338e	engineering_d2dff167	Engineering_d2dff167	t	\N	2026-11-16 15:53:50.998599+05:30	\N	\N	\N	\N
5657d7db-6d81-4edd-a9a4-6ea1a64677f9	engineering_699f85ac	Engineering_699f85ac	t	\N	2026-11-16 15:53:51.012676+05:30	\N	\N	\N	\N
53728e56-6528-4028-b679-824ca98fb44f	engineering_900f04e3	Engineering_900f04e3	t	\N	2026-11-16 16:07:27.67988+05:30	\N	\N	\N	\N
691a0f5e-2877-4367-85c1-a966561ca205	engineering_03e3a75c	Engineering_03e3a75c	t	\N	2026-11-16 16:07:27.699071+05:30	\N	\N	\N	\N
fe3e6b78-fd71-4c88-b945-486f86ebeceb	engineering_487c8737	Engineering_487c8737	t	\N	2026-11-16 16:43:09.356709+05:30	\N	\N	\N	\N
4d220dc9-e416-42cd-9f46-07771125c120	engineering_f801ac27	Engineering_f801ac27	t	\N	2026-11-16 16:45:00.899429+05:30	\N	\N	\N	\N
1b95e125-ac1c-4d7a-a96c-6c157ce1650c	engineering_68cb7633	Engineering_68cb7633	t	\N	2026-11-16 16:47:40.078835+05:30	\N	\N	\N	\N
f7a8281f-64a0-4cb9-84bd-c0bfa0410bbe	engineering_4ccef19a	Engineering_4ccef19a	t	\N	2026-11-16 16:48:09.93486+05:30	\N	\N	\N	\N
47905f80-58eb-454b-80b7-5411af6837c5	engineering_08105fc5	Engineering_08105fc5	t	\N	2026-11-16 16:48:12.328087+05:30	\N	\N	\N	\N
23cc3c76-258d-43e5-acbf-12e642fce766	engineering_c48e9f63	Engineering_c48e9f63	t	\N	2026-11-16 16:48:29.759533+05:30	\N	\N	\N	\N
d77392f3-bb34-435b-bea7-8e9777f171e7	engineering_cff07136	Engineering_cff07136	t	\N	2026-11-16 17:05:16.896327+05:30	\N	\N	\N	\N
cc30df98-af3e-4a00-b2a7-ea817bc8b549	engineering_7e4c53c5	Engineering_7e4c53c5	t	\N	2026-11-16 17:06:28.39835+05:30	\N	\N	\N	\N
0c2bb2e2-c0b5-45d4-ad53-68245242da18	engineering_f8dd33ca	Engineering_f8dd33ca	t	\N	2026-11-16 17:07:41.296722+05:30	\N	\N	\N	\N
3921fc21-6df5-4961-8e75-586b5345ceb5	engineering_cd280db5	Engineering_cd280db5	t	\N	2026-11-16 17:07:41.297058+05:30	\N	\N	\N	\N
d39b28d8-b28e-4699-8426-2cfd2e868586	engineering_7921e584	Engineering_7921e584	t	\N	2026-11-16 17:07:41.297018+05:30	\N	\N	\N	\N
32a3e545-057d-4a86-aefe-59cb9e322ded	engineering_63c3d7f9	Engineering_63c3d7f9	t	\N	2026-11-16 17:44:46.109115+05:30	\N	\N	\N	\N
b0331e9c-e1f3-468c-9476-a8fd16bc4860	engineering_258f9dc4	Engineering_258f9dc4	t	\N	2026-11-16 17:44:46.108895+05:30	\N	\N	\N	\N
b42684ce-19c8-4fd7-aec0-b1695d2ef594	engineering_cfb4453a	Engineering_cfb4453a	t	\N	2026-11-16 17:44:48.75942+05:30	\N	\N	\N	\N
fd84aa38-11ef-46af-ade7-241f2a2c08fd	pmo_project_management_office	PMO (Project Management Office)	t	\N	2026-10-21 00:01:50.075909+05:30	2026-11-17 10:32:20.44494+05:30	\N	\N	\N
9b05093d-673d-4e1a-86f0-3e948b605ec6	engineering_3194c0a6	Engineering_3194c0a6	t	\N	2026-11-16 17:35:57.783507+05:30	\N	\N	\N	\N
96f7d50c-2ddd-4684-83e0-d107ac3edcb3	engineering_1f00580c	Engineering_1f00580c	t	\N	2026-11-16 17:36:14.816685+05:30	\N	\N	\N	\N
d664468a-8d4b-4d2d-8773-a05d30bda6a4	engineering_c1f725d4	Engineering_c1f725d4	t	\N	2026-11-16 17:36:15.761483+05:30	\N	\N	\N	\N
271a1dfb-7a6c-4973-b4b1-e308674954d5	engineering_85ff1cef	Engineering_85ff1cef	t	\N	2026-11-16 17:41:29.410093+05:30	\N	\N	\N	\N
47e4f070-cd31-4781-9b0f-944f7a372eb6	engineering_59cd5272	Engineering_59cd5272	t	\N	2026-11-16 17:41:29.397144+05:30	\N	\N	\N	\N
d055716f-974c-47ab-b17d-7922956ca71a	engineering_f7282730	Engineering_f7282730	t	\N	2026-11-16 17:41:51.39458+05:30	\N	\N	\N	\N
f6283dc0-8bfb-428a-b589-72f71d568f60	engineering_f6ad68cb	Engineering_f6ad68cb	t	\N	2026-11-16 17:41:51.394691+05:30	\N	\N	\N	\N
eb3da1cd-04ef-4f55-8e5a-53f83ea1ed87	engineering_7af38c6f	Engineering_7af38c6f	t	\N	2026-11-16 17:44:43.459779+05:30	\N	\N	\N	\N
ef509b3d-9492-499e-923f-987281e36d1f	engineering_e1e846b6	Engineering_e1e846b6	t	\N	2026-11-16 17:46:54.20948+05:30	\N	\N	\N	\N
bdef1268-8586-4848-bc52-c3c3560a909f	engineering_2206d2f6	Engineering_2206d2f6	t	\N	2026-11-16 17:47:43.414439+05:30	\N	\N	\N	\N
d33e1f00-4a0c-44d8-8165-f23774323c50	engineering_61d74cc4	Engineering_61d74cc4	t	\N	2026-11-16 17:47:43.401332+05:30	\N	\N	\N	\N
71c8aa27-815f-403d-8f40-cb14c931a936	engineering_45a5cf13	Engineering_45a5cf13	t	\N	2026-11-16 17:48:01.726109+05:30	\N	\N	\N	\N
afe41366-4dd3-4f8b-9964-d4ce1ca4332d	engineering_3c434e9b	Engineering_3c434e9b	t	\N	2026-11-16 17:48:01.725629+05:30	\N	\N	\N	\N
d073a4be-1d89-4c46-871f-3b63954948d5	engineering_4fd5e54f	Engineering_4fd5e54f	t	\N	2026-11-16 17:49:32.330911+05:30	\N	\N	\N	\N
ca95200f-38b8-4507-a661-5c1bbfe9deec	engineering_76ac35dc	Engineering_76ac35dc	t	\N	2026-11-16 18:18:48.893007+05:30	\N	\N	\N	\N
81c9580c-ad17-48eb-81c8-22641bcd1812	engineering_7af575df	Engineering_7af575df	t	\N	2026-11-16 18:20:08.56973+05:30	\N	\N	\N	\N
f18bd3a7-09f2-45e0-b791-4de9313a6566	engineering_7eedb23d	Engineering_7eedb23d	t	\N	2026-11-16 18:20:08.583362+05:30	\N	\N	\N	\N
d97b7420-7fdd-4c9a-b293-a8e78494132f	engineering_b1f1c92e	Engineering_b1f1c92e	t	\N	2026-11-16 19:00:16.367933+05:30	\N	\N	\N	\N
79b69331-a2cf-4430-a676-e0c40ba39711	engineering_ec057094	Engineering_ec057094	t	\N	2026-11-16 19:00:18.757088+05:30	\N	\N	\N	\N
ec2207e5-c4a4-4e4c-b0de-543e14357da1	engineering_1bddd63e	Engineering_1bddd63e	t	\N	2026-11-16 19:00:37.528939+05:30	\N	\N	\N	\N
09e15a6c-465d-4197-bf5c-f89a6ee40b1a	engineering_1a44a81e	Engineering_1a44a81e	t	\N	2026-11-16 19:27:22.901789+05:30	\N	\N	\N	\N
63bc0f54-4d35-4279-bb62-4daeff6ceeaa	em_engagement_manager	EM (Engagement Manager)	t	8e4e88f1-e294-4554-80cc-92ed6169caeb	2026-10-21 00:01:50.075909+05:30	2026-11-16 19:53:17.809578+05:30	\N	\N	\N
\.


--
-- Data for Name: mst_submodules; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_submodules ("Id", "Code", "Name", "Route", "SortOrder", "IsActive", "ModuleId", "ParentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
39dbd425-643b-47e9-9936-6bbae9ef5ef5	employee-directory	Employee Directory	/employee-directory	10	t	715f79ce-51ea-46d3-b95d-8318840f90a6	\N	2026-10-21 16:11:40.856126+05:30	\N	\N	\N	\N
526e2d0d-47d4-4814-9e5a-8f7c53af1432	exit-summary	Exit Summary	/exit-summary	20	t	715f79ce-51ea-46d3-b95d-8318840f90a6	\N	2026-10-21 16:11:40.856126+05:30	\N	\N	\N	\N
662d62ab-38b1-447e-876e-7f93bf2ba50e	master	Master	/settings-masters	20	t	fcb69b3e-e5aa-49bb-921f-7793f0a8c90d	\N	2026-10-21 16:11:40.856126+05:30	\N	\N	\N	\N
9854b7f3-8e7e-4ecb-864f-f2533ff295f9	team-dashboard	Team Dashboard	/my-team/	10	t	6055ce3c-b466-4354-ba9a-b4c309111e9d	\N	2026-10-21 16:11:40.856126+05:30	\N	\N	\N	\N
d67426d3-05df-4608-b8cf-c0ecfe698dc3	timesheets	Timesheets	/my-team/timesheets	20	t	6055ce3c-b466-4354-ba9a-b4c309111e9d	\N	2026-10-21 16:11:40.856126+05:30	\N	\N	\N	\N
e231d2d4-9ebb-4eb2-af48-fbe3b3b4ab90	roles-permissions	Roles & Permissions	/settings-security-roles	10	t	fcb69b3e-e5aa-49bb-921f-7793f0a8c90d	\N	2026-10-21 16:11:40.856126+05:30	\N	\N	\N	\N
a7e6b014-9f4a-4d2c-87d2-431527ef9a10	customer-detail	Customer Detail	/customers	10	t	4e57fd71-b53e-43c0-862e-5698e09c0922	\N	2026-10-26 17:43:10.411505+05:30	2026-10-26 18:07:50.679593+05:30	\N	\N	\N
b8f7c125-0e5b-4e3d-98e3-542638fa0b21	project-detail	Project Detail	/projects	10	t	168b1296-de6a-4f9e-a3b9-617b83863736	\N	2026-10-26 18:50:44.18797+05:30	\N	\N	\N	\N
e8f7c125-0e5b-4e3d-98e3-542638fa0b23	employee-detail	Employee Detail	/employee-directory	10	t	\N	39dbd425-643b-47e9-9936-6bbae9ef5ef5	2026-10-28 09:36:39.319232+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: mst_tabs; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_tabs ("Id", "Code", "Name", "SortOrder", "IsActive", "ModuleId", "TabId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "SubModuleId") FROM stdin;
5b828ae3-0b45-4a1c-a1cb-78b29e882cf3	alerts	Alerts	30	t	5a049953-8170-4ef4-a59e-43dc19e12de5	\N	2026-10-21 17:48:58.656708+05:30	\N	\N	\N	\N	\N
69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc	notifications	Notifications	40	t	5a049953-8170-4ef4-a59e-43dc19e12de5	\N	2026-10-21 17:48:58.656708+05:30	\N	\N	\N	\N	\N
a7bd6c40-4e96-4abb-be93-4ed4e4211978	approvals	Approvals	20	t	5a049953-8170-4ef4-a59e-43dc19e12de5	\N	2026-10-21 17:48:58.656708+05:30	\N	\N	\N	\N	\N
db9aa2d2-1876-4d81-9ff6-6b55be19fb7a	bucket-list	Bucket List	10	t	5a049953-8170-4ef4-a59e-43dc19e12de5	\N	2026-10-21 17:48:58.656708+05:30	\N	\N	\N	\N	\N
552f9f86-4eb0-473a-8e39-9863cfefcea4	all-employees	All Employees	20	t	\N	\N	2026-10-21 18:02:30.731666+05:30	\N	\N	\N	\N	9854b7f3-8e7e-4ecb-864f-f2533ff295f9
b1e81c2a-34de-4dd4-b1f3-47387b8ed52b	my-reportees	My Reportees	10	t	\N	\N	2026-10-21 18:02:30.731666+05:30	\N	\N	\N	\N	9854b7f3-8e7e-4ecb-864f-f2533ff295f9
c1a11111-0001-4000-8000-000000000001	project-overview	Overview	10	t	\N	\N	2026-10-27 10:52:34.415461+05:30	\N	\N	\N	\N	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0001-4000-8000-000000000002	project-wbs	WBS	20	t	\N	\N	2026-10-27 10:52:34.415461+05:30	\N	\N	\N	\N	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0001-4000-8000-000000000003	project-team	Team	30	t	\N	\N	2026-10-27 10:52:34.415461+05:30	\N	\N	\N	\N	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0001-4000-8000-000000000004	project-tasks	Tasks	40	t	\N	\N	2026-10-27 10:52:34.415461+05:30	\N	\N	\N	\N	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0001-4000-8000-000000000005	project-health	Health	50	t	\N	\N	2026-10-27 10:52:34.415461+05:30	\N	\N	\N	\N	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0003-4000-8000-000000000002	overview-senior-project-managers	Senior Project Managers	20	t	\N	c1a11111-0001-4000-8000-000000000001	2026-10-27 18:19:13.659663+05:30	\N	\N	\N	\N	\N
c1a11111-0003-4000-8000-000000000003	overview-project-managers	Project Managers	30	t	\N	c1a11111-0001-4000-8000-000000000001	2026-10-27 18:19:13.659663+05:30	\N	\N	\N	\N	\N
c1a11111-0003-4000-8000-000000000004	overview-team-leads	Team Leads	40	t	\N	c1a11111-0001-4000-8000-000000000001	2026-10-27 18:19:13.659663+05:30	\N	\N	\N	\N	\N
c1a11111-0001-4000-8000-000000000006	project-invoices	Invoices	60	f	\N	\N	2026-10-27 10:52:34.415461+05:30	2026-10-28 09:24:16.055849+05:30	\N	\N	2026-10-28 09:26:14.371529+05:30	b8f7c125-0e5b-4e3d-98e3-542638fa0b21
c1a11111-0003-4000-8000-000000000001	overview-budget	Budget	10	f	\N	c1a11111-0001-4000-8000-000000000001	2026-10-27 18:19:13.659663+05:30	2026-10-28 09:24:16.055849+05:30	\N	\N	2026-10-28 09:26:14.371529+05:30	\N
e1a11111-0001-4000-8000-000000000001	employee-personal-info	Personal Information	10	t	\N	\N	2026-10-28 09:37:13.866215+05:30	\N	\N	\N	\N	e8f7c125-0e5b-4e3d-98e3-542638fa0b23
e1a11111-0001-4000-8000-000000000002	employee-organization-details	Organization Details	20	t	\N	\N	2026-10-28 09:37:13.866215+05:30	\N	\N	\N	\N	e8f7c125-0e5b-4e3d-98e3-542638fa0b23
e1a11111-0001-4000-8000-000000000003	employee-employment-bond	Employment & Bond	30	t	\N	\N	2026-10-28 09:37:13.866215+05:30	\N	\N	\N	\N	e8f7c125-0e5b-4e3d-98e3-542638fa0b23
e1a11111-0001-4000-8000-000000000004	employee-education-experience	Education & Experience	40	t	\N	\N	2026-10-28 09:37:13.866215+05:30	\N	\N	\N	\N	e8f7c125-0e5b-4e3d-98e3-542638fa0b23
e1a11111-0001-4000-8000-000000000005	employee-pmo-em-information	PMO & EM Information	50	t	\N	\N	2026-10-28 09:37:13.866215+05:30	\N	\N	\N	\N	e8f7c125-0e5b-4e3d-98e3-542638fa0b23
e1a11111-0001-4000-8000-000000000006	employee-activity-logs	Activity Logs	60	t	\N	\N	2026-10-28 09:37:13.866215+05:30	\N	\N	\N	\N	e8f7c125-0e5b-4e3d-98e3-542638fa0b23
c1a11111-0002-4000-8000-000000000001	health-issues	Issues	10	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 10:52:47.81342+05:30	2026-10-28 15:46:21.765723+05:30	\N	\N	\N	\N
c1a11111-0002-4000-8000-000000000002	health-alerts	Alerts	20	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 10:52:47.81342+05:30	2026-10-28 15:46:21.765723+05:30	\N	\N	\N	\N
c1a11111-0002-4000-8000-000000000003	health-escalations	Escalations	30	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 10:52:47.81342+05:30	2026-10-28 15:46:21.765723+05:30	\N	\N	\N	\N
c1a11111-0002-4000-8000-000000000004	health-appreciation	Appreciation	40	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 10:52:47.81342+05:30	2026-10-28 15:46:21.765723+05:30	\N	\N	\N	\N
c1a11111-0002-4000-8000-000000000005	health-customer-engagement	Customer Engagement	50	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 10:52:47.81342+05:30	2026-10-28 15:46:21.765723+05:30	\N	\N	\N	\N
c1a11111-0002-4000-8000-000000000006	health-extension-request	Extension Request	60	t	\N	c1a11111-0001-4000-8000-000000000005	2026-10-27 10:52:47.81342+05:30	2026-10-28 15:46:21.765723+05:30	\N	\N	\N	\N
d67426d3-0001-4000-8000-000000000001	my-timesheet	My Timesheet	10	t	\N	\N	2026-10-28 16:50:16.166606+05:30	\N	\N	\N	\N	d67426d3-05df-4608-b8cf-c0ecfe698dc3
d67426d3-0001-4000-8000-000000000002	timesheet-history	Timesheet History	20	t	\N	\N	2026-10-28 16:50:16.166606+05:30	\N	\N	\N	\N	d67426d3-05df-4608-b8cf-c0ecfe698dc3
d67426d3-0001-4000-8000-000000000003	timesheet-approval	Timesheet Approval	30	t	\N	\N	2026-10-28 16:50:16.166606+05:30	\N	\N	\N	\N	d67426d3-05df-4608-b8cf-c0ecfe698dc3
9854b7f3-0001-4000-8000-000000000001	my-team	My Team	5	t	\N	\N	2026-11-12 00:18:35.649288+05:30	\N	\N	\N	\N	9854b7f3-8e7e-4ecb-864f-f2533ff295f9
\.


--
-- Data for Name: mst_widgets; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_widgets ("Id", "Code", "Name", "SortOrder", "IsActive", "ParentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "ParentWidgetId") FROM stdin;
0d274292-537d-4c41-8e23-3df901304d71	team-resignation-count	Team Resignation Count – Onsite/Offsite (Last 3 Months)	70	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 17:36:30.668801+05:30	\N	\N	\N	\N	\N
2b83bafc-1c64-449c-a644-e8e19e0c0a48	team-utilization-offsite	Team Utilization – Offsite	40	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 17:36:30.668801+05:30	\N	\N	\N	\N	\N
3c5780f7-e23d-48bd-b73e-51019dfbc2bd	team-allocation-onsite-offsite	Team Allocation Onsite/Offsite (Last 3 Months)	60	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 17:36:30.668801+05:30	\N	\N	\N	\N	\N
682f26ec-e31d-43a0-82de-e915bab54b59	total-team-size	Total Team Size	10	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 17:36:30.668801+05:30	\N	\N	\N	\N	\N
7e3f4519-8acd-489f-a70a-ac39092fbd40	team-utilization-onsite-projects	Team Utilization – Onsite: Project-wise Resource Count	50	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 17:36:30.668801+05:30	\N	\N	\N	\N	\N
896c2166-8f1f-4ab8-873c-755ab3d051fb	team-utilization-onsite	Team Utilization - Onsite (Last 3 Months)	30	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 17:36:30.668801+05:30	\N	\N	\N	\N	\N
9c916f1a-72e0-4d52-bec1-6d684e990c65	resource-boarding-details	Resource Boarding Details	20	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 17:36:30.668801+05:30	\N	\N	\N	\N	\N
d6dea306-2e8f-41a0-89c8-857cb96f5558	team-capacity-offsite	Team Capacity – Offsite (Last 3 Months)	80	t	471bc977-be2e-449d-91e7-5c11cb9c4ec0	2026-10-21 17:36:30.668801+05:30	\N	\N	\N	\N	\N
\.


--
-- Data for Name: mst_work_locations; Type: TABLE DATA; Schema: master; Owner: -
--

COPY master.mst_work_locations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
3bc10d7b-a705-4ec9-b7b5-71858572a8cc	suvidha_square_andheri	Suvidha Square, Andheri	t	2	2026-09-03 17:56:58.067087+05:30	2026-09-10 12:04:25.480503+05:30	\N	\N	\N
58e569dc-cb93-4832-bf22-2e8d4836dc65	onsite	Onsite	t	1	2026-09-03 17:56:58.067087+05:30	2026-09-10 12:04:25.480503+05:30	\N	\N	\N
8d0b23a2-9459-4fbe-a7bf-624abd410c40	navare_plaza_dombivli	Navare Plaza, Dombivli	t	3	2026-09-03 17:56:58.067087+05:30	2026-09-10 12:04:25.480503+05:30	\N	\N	\N
bb1fb7b0-c12c-4dd0-86b8-f4461feb6306	zz_probe_location	ZZ Probe Location	f	4	2026-10-18 18:30:09.320026+05:30	2026-10-18 18:30:09.708791+05:30	00000000-0000-0000-0000-000000000004	00000000-0000-0000-0000-000000000004	2026-10-18 18:30:09.708791+05:30
\.


--
-- Data for Name: log_project_task_assignments; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.log_project_task_assignments ("Id", "TaskId", "EmployeeId", "Action", "ResourceName", "TeamType", "OccurredAtUtc", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_project_additional_requirements; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_additional_requirements ("Id", "RequirementId", "ProjectId", "ClientName", "ProjectName", "RequirementType", "Title", "Description", "Priority", "RequestedByEmployeeId", "RequestedByName", "RequestedDate", "AttachmentFileName", "AttachmentPath", "ScopeCancellationService", "Status", "ApprovedAtUtc", "ApprovedByEmployeeId", "ApprovedByName", "ApprovalComments", "CommentsJson", "HistoryJson", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_project_alerts; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_alerts ("Id", "ProjectId", "IssueId", "Title", "Description", "AlertType", "Priority", "Status", "RaisedByEmployeeId", "RaisedByName", "AudienceUserIds", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Owner", "ResolutionOwner", "EscalationOwner", "ResolutionDetails", "HistoryJson", "StatusChangedBy", "StatusChangedAtUtc", "AttachmentFileName", "AttachmentPath", "ExpectedResolutionDate", "ServiceName", "EscalationType", "EscalatedTo", "ServiceEscalationId", "ChatJson") FROM stdin;
\.


--
-- Data for Name: tbl_project_appreciations; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_appreciations ("Id", "ProjectId", "RecipientEmployeeId", "RecipientName", "RecipientEmail", "RecipientRole", "Badge", "Message", "GivenByEmployeeId", "GivenByName", "CreatedAtUtc", "UpdatedAtUtc", "DeletedAtUtc", "CreatedBy", "UpdatedBy") FROM stdin;
\.


--
-- Data for Name: tbl_project_documents; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_documents ("Id", "ProjectId", "DocumentType", "FileName", "OriginalFileName", "FilePath", "ContentType", "SizeBytes", "Description", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_project_drafts; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_drafts ("Id", "ProjectName", "ClientId", "ClientName", "SalesPerson", "FormSnapshotJson", "CreatedByName", "UpdatedByName", "Status", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_project_extension_approvers; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_extension_approvers ("Id", "ExtensionRequestId", "EmployeeId", "EmployeeName", "Status", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_project_extension_requests; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_extension_requests ("Id", "ProjectId", "CurrentEndDate", "RequestedEndDate", "ExtensionDays", "Reason", "Status", "RequestedByEmployeeId", "RequestedByName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "CommentsJson", "HistoryJson") FROM stdin;
\.


--
-- Data for Name: tbl_project_feedbacks; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_feedbacks ("Id", "ProjectId", "EmployeeId", "EmployeeName", "EmployeeCode", "ReportingManagerId", "ReportingManagerName", "SubmittedByEmployeeId", "SubmittedByName", "FeedbackType", "Strengths", "AreasOfImprovement", "Comments", "Rating", "RequestNote", "Status", "CommentsJson", "HistoryJson", "CreatedAtUtc", "UpdatedAtUtc", "DeletedAtUtc", "CreatedBy", "UpdatedBy") FROM stdin;
\.


--
-- Data for Name: tbl_project_interviews; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_interviews ("Id", "ProjectId", "EmployeeId", "ResourceName", "InterviewDate", "InterviewTime", "Result", "Comments", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_project_invoices; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_invoices ("Id", "ProjectId", "MilestoneName", "Percentage", "Amount", "TaxAmount", "TotalAmount", "Status", "InvoiceNumber", "InvoiceDate", "DueDate", "PaymentDate", "Remarks", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "ServiceName", "Qty", "UnitPrice", "Currency", "ResourceLevel", "PaymentStatus", "ProjectServiceId") FROM stdin;
\.


--
-- Data for Name: tbl_project_issues; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_issues ("Id", "ProjectId", "ProjectCode", "ProjectName", "IssueType", "Priority", "Subject", "Description", "Status", "RaisedByEmployeeId", "RaisedByName", "RaisedByRole", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_project_service_escalation_stakeholders; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_service_escalation_stakeholders ("Id", "EscalationId", "EmployeeId", "EmployeeName", "SubDepartment", "Status", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_project_service_escalations; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_service_escalations ("Id", "ProjectId", "ProjectServiceId", "ProjectCode", "ProjectName", "CustomerName", "ServiceName", "EscalationType", "Priority", "Subject", "Description", "ExpectedResolutionDate", "AttachmentFileName", "AttachmentPath", "AttachmentContentType", "AttachmentSizeBytes", "Status", "RaisedByEmployeeId", "RaisedByName", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "ChatJson") FROM stdin;
\.


--
-- Data for Name: tbl_project_services; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_services ("Id", "ProjectId", "ServiceCatalogId", "TaskId", "Department", "SubDepartment", "ServiceName", "Qty", "Description", "ResourceLevel", "Frequency", "Location", "LocationText", "ServiceModel", "DeliveryModel", "FinalDeliveryFormat", "BillingModel", "Tools", "StartDate", "EndDate", "DurationDays", "DurationHours", "TotalDays", "TotalHours", "UnitPrice", "Total", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "BillingStatus", "CollectionStatus", "IsReady", "ValidationStatus", "ChangeStatus", "OriginalQty", "PendingQty", "PendingResourceLevel", "PendingUnitPrice", "ModCollectionStatus", "ModValidationStatus", "ModBillingStatus", "ModIsReady", "ServiceAbbreviation") FROM stdin;
\.


--
-- Data for Name: tbl_project_task_assignments; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_task_assignments ("Id", "TaskId", "EmployeeId", "Role", "AllocatedHours", "UtilizedHours", "TimerStartedAtUtc", "TimerAccumulatedSeconds", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_project_tasks; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_tasks ("Id", "ProjectId", "ProjectServiceId", "Title", "Description", "Period", "Phase", "Stage", "Priority", "PlannedStartDate", "PlannedEndDate", "ActualStartDate", "ActualEndDate", "EstimatedHours", "UtilizedHours", "Progress", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "TaskType") FROM stdin;
\.


--
-- Data for Name: tbl_project_team_members; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_project_team_members ("Id", "ProjectId", "EmployeeId", "DepartmentId", "SubDepartment", "AllocationStartDate", "AllocationEndDate", "Billability", "IsTeamLead", "ResourceType", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "IsShadowTeam", "MemberRole") FROM stdin;
\.


--
-- Data for Name: tbl_projects; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_projects ("Id", "ProjectCode", "WbsId", "Name", "Description", "ClientId", "SubVentureId", "Status", "Health", "Progress", "ContractType", "ProjectType", "Currency", "TaxPercent", "StartDate", "EndDate", "Budget", "Spent", "TotalHours", "TotalDays", "InvoiceValue", "ProjectManagerId", "TeamLeadId", "EngagementManager", "EngagementManagerId", "SalesPerson", "SalesPersonId", "ProjectIssuedDate", "SectionAComments", "SectionBComments", "WbsStatus", "WbsSubStatus", "RenewedFromProjectId", "PoStatus", "PoNumber", "PoDate", "BillingModel", "PaymentTerms", "TargetDate", "AccountContactName", "AccountContactPhone", "AccountContactEmail", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_resource_allocation_requests; Type: TABLE DATA; Schema: project; Owner: -
--

COPY project.tbl_resource_allocation_requests ("Id", "ProjectId", "EmployeeId", "DepartmentId", "SubDepartment", "AllocationStartDate", "AllocationEndDate", "Billability", "IsTeamLead", "ResourceType", "IsShadowTeam", "Status", "RequestedByEmployeeId", "RequestedByName", "ApproverEmployeeId", "ApproverName", "CommentsJson", "HistoryJson", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
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
20261029140000_AddProjectIssuesAndAlerts	8.0.0
20261029150000_AddActionNotifications	8.0.8
20261029190000_AddServiceCatalogAbbreviation	8.0.8
20261112090335_AddSlaTrackingSchemaAndIdempotencyKey	10.0.4
\.


--
-- Data for Name: log_repository_activity; Type: TABLE DATA; Schema: repository; Owner: -
--

COPY repository.log_repository_activity ("Id", "Action", "DocumentId", "FileName", "Category", "PerformedBy", "Details", "CreatedAtUtc", "DeletedAtUtc", "CreatedBy", "UpdatedBy", "UpdatedAtUtc") FROM stdin;
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
\.


--
-- Data for Name: log_employee_activity; Type: TABLE DATA; Schema: resource; Owner: -
--

COPY resource.log_employee_activity ("Id", "EmployeeId", "Action", "PerformedByEmail", "PerformedByName", "Details", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
3bd6edd0-1894-4b3e-af8b-0e71a59f6c49	940ec7cd-058d-4f8f-912f-08ae55bac01c	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Terminated, Reason: Career growth — UAT sample exit, Last Working Day: 2026-10-02)	2026-10-16 15:24:37.284411+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
8d7263ae-45e4-42fd-995b-0c2cd9102106	87fd3345-a756-44df-a3e7-5f21fa6e50d3	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Terminated, Reason: Career growth — UAT sample exit, Last Working Day: 2026-10-02)	2026-10-16 15:24:37.309719+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
5e8e5ef8-bfaf-4974-a608-3089eeef28aa	23bf310d-b789-4dcc-bb7e-576b373e72cf	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Terminated, Reason: Career growth — UAT sample exit, Last Working Day: 2026-10-02)	2026-10-16 15:24:37.319639+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
3a2236e4-f5a9-4f3b-ade4-c3b22bb52237	089e3bae-d509-46db-906f-3085e0438c9c	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Terminated, Reason: Career growth — UAT sample exit, Last Working Day: 2026-10-02)	2026-10-16 15:24:37.329732+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
768bcfa3-8740-4005-8306-fbf026b6dba4	ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resignation Under Review, Reason: Serving notice — UAT sample, Last Working Day: 2026-11-15)	2026-10-16 15:24:37.34871+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
1e48ea47-5b08-432b-9893-30d7bdadc95a	d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resignation Under Review, Reason: Serving notice — UAT sample, Last Working Day: 2026-11-15)	2026-10-16 15:24:37.363101+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a3ccc36b-53da-41ce-8f36-82ccc3b58c95	f30d1ce8-8a1a-483d-ace2-419cd8672ecc	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resignation Under Review, Reason: Serving notice — UAT sample, Last Working Day: 2026-11-15)	2026-10-16 15:24:37.37219+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
e16a2c96-e576-49c8-b161-56987da1f467	3398777f-d384-48a2-8076-9c4fb06162bb	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resignation Under Review, Reason: Serving notice — UAT sample, Last Working Day: 2026-11-15)	2026-10-16 15:24:37.381116+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
d3665e39-d7a5-443d-8d52-a6fa5dcc18ba	cef36bf2-c4fb-4040-b3ab-d033190ad3b4	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resignation Under Review, Reason: Serving notice — UAT sample, Last Working Day: 2026-11-15)	2026-10-16 15:24:37.389691+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
77a05a19-21cd-407f-8f00-c3fe80a2cd2d	78b71d74-d255-4ac0-a75f-ead11a61427a	Updated	admin@talakunchi.com	admin	Updated: Role, Experience, Bond Status, Billable Status, Project Type, Prior Total Experience (+2 more)	2026-10-17 13:28:43.623594+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
9d31f6b7-4ac8-4c5d-b601-4d9cc6c9fdc0	78b71d74-d255-4ac0-a75f-ead11a61427a	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-17 13:28:43.623594+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
1ad2b1b8-5f8a-447e-b0b3-05cd0833e538	30913859-c8e8-4851-852f-28be97c74bb1	Updated	admin@talakunchi.com	admin	Updated: Work Location, Experience, Bond Status, Location (Onsite), Billable Status, Project Type (+3 more)	2026-10-17 14:47:09.920137+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
2791d20a-3edc-48ab-8826-bbfbd4dab1b9	30913859-c8e8-4851-852f-28be97c74bb1	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-17 14:47:09.920137+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
8cedb756-12c7-4bcc-8e33-442228e2c4a6	30913859-c8e8-4851-852f-28be97c74bb1	WorkLocationChanged	admin@talakunchi.com	admin	Suvidha Square, Andheri -> Onsite	2026-10-17 14:47:09.920137+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
06a97cb8-55da-470f-a956-768190e2d3fe	049ac489-bbd3-4153-b933-aec7b7baec89	Updated	admin@talakunchi.com	admin	Updated: Business Unit, Category, Probation Status, Experience, Billable Status, Project Type (+5 more)	2026-10-17 13:28:56.05381+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
fca286f3-ac92-4298-9d3e-d9af837869f9	049ac489-bbd3-4153-b933-aec7b7baec89	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-17 13:28:56.05381+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
1ed4d467-30c0-42a1-83a2-2d982b3133ac	ffcdc44f-996b-4ef6-90e6-db858823a4c4	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-17 17:53:08.321477+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
4e92da1c-38ff-44ee-abce-865b0570ea9c	ffcdc44f-996b-4ef6-90e6-db858823a4c4	Updated	admin@talakunchi.com	admin	Updated: Work Email, Role, Category, Experience, Bond Status, Billable Status (+5 more)	2026-10-17 17:53:08.321477+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
39b72415-1cb5-477f-8d06-25c769a7eeff	d2010072-d612-48ab-9a8a-f137b87e6034	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-17 13:31:24.915917+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a7a30ee6-c980-428d-a50d-30533855ffe4	d2010072-d612-48ab-9a8a-f137b87e6034	Updated	admin@talakunchi.com	admin	Updated: Address, Experience, Bond Status, Billable Status, Project Type, Prior Total Experience (+2 more)	2026-10-17 13:31:24.915917+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
43fe504d-9afd-4847-8035-38a83874fd09	d2010072-d612-48ab-9a8a-f137b87e6034	WorkLocationChanged	admin@talakunchi.com	admin	Suvidha Square, Andheri -> Onsite	2026-10-17 13:39:49.32432+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
53efad6d-c625-4820-8797-35171a08678b	d2010072-d612-48ab-9a8a-f137b87e6034	Updated	admin@talakunchi.com	admin	Updated: Work Location	2026-10-17 13:39:49.32432+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
71d59fa3-7480-4d12-9abc-02a9d84f6acc	049ac489-bbd3-4153-b933-aec7b7baec89	Created	admin@talakunchi.com	admin	Profile created for Admin User (TK-0004)	2026-10-16 14:55:32.5313+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d10262fc-0a6d-4cfc-be7e-9009c2479f30	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	Created	admin@talakunchi.com	admin	Profile created for Vihaan Pillai (TK-0001)	2026-10-16 14:55:32.638283+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
8450b7e8-65be-4d39-8abe-bb6f475f1c6c	d17be428-1602-4e09-a164-c3c2666fad73	Created	admin@talakunchi.com	admin	Profile created for Neha Pillai (TK-0002)	2026-10-16 14:55:32.653042+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
664fdca1-089c-4fdf-bc61-1928a633c7ae	f01f614a-af85-4225-a3b4-3c463fb97bdf	Created	admin@talakunchi.com	admin	Profile created for Dev Reddy (TK-0003)	2026-10-16 14:55:32.663899+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
fa2a4b2b-d938-4e77-86f2-90d981f55f5a	d502bbdd-5186-490e-8f0a-5489d2737c6f	Created	admin@talakunchi.com	admin	Profile created for Nikhil Malhotra (TKI-0001)	2026-10-16 14:55:32.674545+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
2f9c0071-ac1b-4523-a58e-d70b8111e52d	849d2fb1-a4e4-4eb2-947b-f97057e4954b	Created	admin@talakunchi.com	admin	Profile created for Dev Bose (TK-0005)	2026-10-16 14:55:32.685347+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
c651e2e4-e33f-44c1-8e82-57ce4aa15eed	d2010072-d612-48ab-9a8a-f137b87e6034	Created	admin@talakunchi.com	admin	Profile created for Amit Deshmukh (TK-0006)	2026-10-16 14:55:32.700183+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
c8ddf0de-f13a-4262-b8f3-0d2f8d385343	f39b20bb-8963-4917-aed5-0f1d86f0cbc3	Created	admin@talakunchi.com	admin	Profile created for Aarav Roy (TK-0007)	2026-10-16 14:55:32.711141+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
abeb50ed-53b0-4fd2-a426-cf7f3f9596b8	7e3f1c8d-340c-47d7-b63d-fb047a9106aa	Created	admin@talakunchi.com	admin	Profile created for Aarav Mathur (TKI-0002)	2026-10-16 14:55:32.725004+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d772aa4f-7780-4f26-8cd1-65f6f9227ec2	d94878fd-4650-46bc-b84c-753c841e7404	Created	admin@talakunchi.com	admin	Profile created for Nikhil Saxena (TK-0008)	2026-10-16 14:55:32.737106+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
9a858882-12f3-43e0-aedf-5b84512bc6d1	13428d48-c81e-4720-adba-f8490f27e535	Created	admin@talakunchi.com	admin	Profile created for Vihaan Saxena (TK-0009)	2026-10-16 14:55:32.749692+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
c530fb46-acfc-4328-b0f2-1a5f3e668f2d	30913859-c8e8-4851-852f-28be97c74bb1	Created	admin@talakunchi.com	admin	Profile created for Sana Pillai (TK-0010)	2026-10-16 14:55:32.761239+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
83008999-f485-473c-8197-f31df58c038c	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Created	admin@talakunchi.com	admin	Profile created for Aditya Roy (TK-0011)	2026-10-16 14:55:32.772002+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
a59dbdd6-ee2c-4200-b54d-b4aa0cb65205	62e81e6b-7247-4c3f-a8b8-db21e613d02a	Created	admin@talakunchi.com	admin	Profile created for Aarav Bose (TKI-0003)	2026-10-16 14:55:32.784368+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
cf68a0b3-9883-4879-b625-58ce51d63ca5	9d9bfa3a-8603-4de4-8eb7-76c3935e3014	Created	admin@talakunchi.com	admin	Profile created for Advait Singh (TK-0012)	2026-10-16 14:55:32.796331+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
bc6e7b61-0498-4f05-8e9d-9c6a35331daf	583e812b-e929-4e7c-9d76-33d3fc25cd7d	Created	admin@talakunchi.com	admin	Profile created for Tanvi Gaikwad (TK-0013)	2026-10-16 14:55:32.808053+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
9dc24284-8527-4571-b4a2-4ec9c335627c	70e01a7d-fd0b-4e2a-b086-d059423ca380	Created	admin@talakunchi.com	admin	Profile created for Vihaan Kadam (TK-0014)	2026-10-16 14:55:32.8185+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
63246349-fdf1-418c-9d51-9faaef3a7c4f	159fb3d0-937c-4f81-ad37-aa1b4f023264	Created	admin@talakunchi.com	admin	Profile created for Rajesh Sharma (TK-0015)	2026-10-16 14:55:32.829223+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
72e645a9-79ba-4b64-97a9-d93a82a4f8e1	42583b6b-008c-45f6-b258-b08495712c7c	Created	admin@talakunchi.com	admin	Profile created for Harsh Wardhan (TK-0016)	2026-10-16 14:55:32.839978+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
89946d2a-48ee-4649-9fc6-1df90ee61013	a73329ac-636f-475e-b566-321a5686fd66	Created	admin@talakunchi.com	admin	Profile created for Pallavi Sawant (TK-0017)	2026-10-16 14:55:32.850765+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
1ad01e82-0a72-4d5f-9c34-49b87870d9f9	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	Created	admin@talakunchi.com	admin	Profile created for Harsh Pandey (TK-0018)	2026-10-16 14:55:32.861622+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
72110b1d-4271-465f-81d1-10cd4084f5e8	2b245a46-a64c-440b-861d-24f712bd626e	Created	admin@talakunchi.com	admin	Profile created for Kavya Mathur (TKI-0004)	2026-10-16 14:55:32.872825+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
5141e69d-6938-4593-ac11-c9ecc02338ea	696f99d7-2380-443c-b90d-0e065642e1d4	Created	admin@talakunchi.com	admin	Profile created for Priya Mishra (TK-0019)	2026-10-16 14:55:32.883529+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
269b42f9-c5dd-412c-ab0c-a0da8b7f6bf1	8e0616db-48af-4b73-807f-6e250dba2072	Created	admin@talakunchi.com	admin	Profile created for Anita Pandey (TK-0020)	2026-10-16 14:55:32.893527+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d2660500-1fbb-470f-b466-47c9b8d3eeff	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Created	admin@talakunchi.com	admin	Profile created for Karan Wardhan (TK-0021)	2026-10-16 14:55:32.902977+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
775db417-e10b-4e44-93ff-22bf4ac8b5cc	eba0b052-26bb-4216-ab6e-dff23c63bc57	Created	admin@talakunchi.com	admin	Profile created for Rahul Mishra (TK-0022)	2026-10-16 14:55:32.913225+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
a7a118d2-bf8b-4a1d-b6ab-c7d15b8aa271	9312226e-c7f8-4187-887e-67e2124098cd	Created	admin@talakunchi.com	admin	Profile created for Kunal Rao (TKI-0005)	2026-10-16 14:55:32.923653+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
467beadf-663a-42a0-b194-c57c4ea2f7e4	9f646393-8fea-4b38-9f35-d88a6ab6787e	Created	admin@talakunchi.com	admin	Profile created for Aarav Rao (TK-0023)	2026-10-16 14:55:32.933058+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
dd3b0d89-5321-459b-8592-436dc1c4c8c1	033446c7-c133-4395-bdaa-69b5f227a7a8	Created	admin@talakunchi.com	admin	Profile created for Atharv Reddy (TK-0024)	2026-10-16 14:55:32.942887+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
3f75ea93-1610-413a-b5e9-b8a74cea54f9	2285ceea-ffbf-4bf4-bb2e-bd9e0427beeb	Created	admin@talakunchi.com	admin	Profile created for Vihaan Mathur (TK-0025)	2026-10-16 14:55:32.952363+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
82718bb2-e582-4b68-8df6-afc234672404	be9f417e-d40a-4c66-91e6-e7fde84b46d5	Created	admin@talakunchi.com	admin	Profile created for Krishna Pandey (TK-0026)	2026-10-16 14:55:32.961707+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
4b070b4c-e26b-43e8-9a6a-d5b731019ade	7d2b2c7a-254e-4605-9f79-3f42ac7f9735	Created	admin@talakunchi.com	admin	Profile created for Reyansh Chopra (TK-0027)	2026-10-16 14:55:32.97114+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
eb7f160e-48e5-43d8-868e-befccfbc8ebe	777390a6-91b9-4d9e-806c-16e046568501	Created	admin@talakunchi.com	admin	Profile created for Krishna Joshi (TK-0028)	2026-10-16 14:55:32.980525+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
6b448a66-f825-46e0-acaf-d0bde1861db4	13b14e34-f865-4c83-a6c0-3fdf7d196c1c	Created	admin@talakunchi.com	admin	Profile created for Reyansh Sawant (TK-0029)	2026-10-16 14:55:32.989627+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
2112569e-def2-4dad-bee1-394b796dd83a	776f2cf7-c4cc-4299-b38f-afbcaff7703e	Created	admin@talakunchi.com	admin	Profile created for Omkar Reddy (TK-0030)	2026-10-16 14:55:32.998861+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
2459cf05-d3fa-4aa9-82ba-83f309cec319	804c8187-6f28-411f-8fa5-cc9baceba3e7	Created	admin@talakunchi.com	admin	Profile created for Arjun Joshi (TK-0031)	2026-10-16 14:55:33.008037+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
2f0de41c-f8f7-4161-bac0-76652c707800	f19ea8a8-4d2f-48f9-832e-311f80e49f11	Created	admin@talakunchi.com	admin	Profile created for Ananya Joshi (TKI-0006)	2026-10-16 14:55:33.017849+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
fa675fdf-6f2c-47ab-8b1a-c07688be56f8	d9fd54d6-b11b-4969-a25d-8b8e3fcca417	Created	admin@talakunchi.com	admin	Profile created for Amit Sawant (TK-0032)	2026-10-16 14:55:33.029454+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
a7b9dd47-c386-42af-bac9-c97e74448f9b	405610b0-c3bd-4725-a409-5f6dbffeacb4	Created	admin@talakunchi.com	admin	Profile created for Arjun Wardhan (TKI-0007)	2026-10-16 14:55:33.039742+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
c1a25993-174d-4954-8c03-74eedba60ab3	9eb64ade-203d-4e4a-aaed-8eaab7d3017d	Created	admin@talakunchi.com	admin	Profile created for Yash Wardhan (TK-0033)	2026-10-16 14:55:33.049223+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
85d7c388-3051-4d86-9059-b24088f31da1	86862bf8-c075-44ef-9f3e-f65d2cc1bb56	Created	admin@talakunchi.com	admin	Profile created for Suresh Desai (TK-0034)	2026-10-16 14:55:33.058812+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
7e1b6cad-2e30-4b5f-88d5-582e158db855	78b71d74-d255-4ac0-a75f-ead11a61427a	Created	admin@talakunchi.com	admin	Profile created for Aarav Desai (TK-0035)	2026-10-16 14:55:33.067911+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
0d98aed4-5406-41d9-8c0a-04e8ca157fcb	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Created	admin@talakunchi.com	admin	Profile created for Amit Wardhan (TK-0036)	2026-10-16 14:55:33.077105+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
67a2a763-375c-42a1-a929-1e30becc3654	e131815f-331f-46d7-81f8-5d2bed793630	Created	admin@talakunchi.com	admin	Profile created for Ira Bose (TK-0037)	2026-10-16 14:55:33.086379+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
4e75b566-4565-4cf8-baec-ba1a506b89ff	51df4d23-9202-43b7-9e29-4a14a838a242	Created	admin@talakunchi.com	admin	Profile created for Vihaan Gaikwad (TK-0038)	2026-10-16 14:55:33.095908+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
69006480-bc43-4164-9edc-fd16e34306c9	02814af4-08b4-42cc-92e1-ad0bba687378	Created	admin@talakunchi.com	admin	Profile created for Pooja Bose (TK-0039)	2026-10-16 14:55:33.105674+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
ed58d865-af49-416d-aa73-1ba564e18cfc	0a213b8b-1836-4660-9116-536fc9436639	Created	admin@talakunchi.com	admin	Profile created for Krishna Saxena (TK-0040)	2026-10-16 14:55:33.115166+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
fc2319a9-158e-4c18-90e3-f6aee767cc4c	9ec115c7-5377-4f9d-b46a-2a3c97bea4de	Created	admin@talakunchi.com	admin	Profile created for Aarav Reddy (TKI-0008)	2026-10-16 14:55:33.125013+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d0bde471-6cc8-4d69-913f-65ddcde45a9f	c5e35b7a-af12-4fd6-96af-e62225e715c6	Created	admin@talakunchi.com	admin	Profile created for Karan Mehra (TK-0041)	2026-10-16 14:55:33.134445+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
50cfb01f-2422-42eb-baa1-24f83f3d1f2c	ee7b555a-4400-4c03-8fe5-60fd908c0e58	Created	admin@talakunchi.com	admin	Profile created for Arjun Mathur (TK-0042)	2026-10-16 14:55:33.143745+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
e12d78ef-85c6-4b93-b28e-d51b9fa56dfa	218f30c7-87bd-4410-99fc-4d10da3e8014	Created	admin@talakunchi.com	admin	Profile created for Yash Sharma (TK-0043)	2026-10-16 14:55:33.153135+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
8f3afdcc-4c6c-4dd3-914a-c7c0cf159f17	5bf6d5c7-4358-49f1-bb6b-9d0b1b38d4ad	Created	admin@talakunchi.com	admin	Profile created for Priya Mathur (TKI-0009)	2026-10-16 14:55:33.163695+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
63bb6287-fbe3-4b71-b95a-8eff6183442d	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Created	admin@talakunchi.com	admin	Profile created for Vihaan Bose (TK-0044)	2026-10-16 14:55:33.173185+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
4a3bef5a-3ae9-4a7d-8ae3-271328e994a6	d01c0ef5-731e-42de-b02a-7c996c545f15	Created	admin@talakunchi.com	admin	Profile created for Vivaan Mathur (TK-0045)	2026-10-16 14:55:33.182891+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
ca61d52f-b773-4562-837b-84d4284db346	d73eac4c-d537-4d31-8e35-b55f8aff3e87	Created	admin@talakunchi.com	admin	Profile created for Arjun Pillai (TK-0046)	2026-10-16 14:55:33.192404+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
e21a7c1a-870c-49c2-9c85-33c3cd564aa0	f90e007c-90d9-440e-8f0a-a85395e49abe	Created	admin@talakunchi.com	admin	Profile created for Vikram Roy (TK-0047)	2026-10-16 14:55:33.202053+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
75450e37-225b-4f8c-8e68-bfc8d6e631c4	b9c0b8fc-4c96-42fb-8669-d68097cf5392	Created	admin@talakunchi.com	admin	Profile created for Aditi Roy (TK-0048)	2026-10-16 14:55:33.212417+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
67eff9a1-95ce-4fde-b083-678eed5eb23e	238c3cb7-75cf-4478-a48e-fe47465d20b6	Created	admin@talakunchi.com	admin	Profile created for Ishita Patel (TK-0049)	2026-10-16 14:55:33.222214+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
cb74ec79-0b21-4cd9-965a-add3b0378225	3a209908-397f-4c90-abf6-9fe52ab98b34	Created	admin@talakunchi.com	admin	Profile created for Vihaan Wardhan (TK-0050)	2026-10-16 14:55:33.231853+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
249015ee-4db4-4fb1-8323-fe584ad4fa94	31057f6b-b1e5-46e3-a071-b6639b93a15c	Created	admin@talakunchi.com	admin	Profile created for Krishna Bose (TK-0051)	2026-10-16 14:55:33.241361+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
5a9a1b37-9d9d-4340-ac57-295e8fbe2add	d29c4919-9e2d-46c1-a78f-ffd2d4d32365	Created	admin@talakunchi.com	admin	Profile created for Anita Iyer (TK-0052)	2026-10-16 14:55:33.251595+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
8750ca64-8fab-4700-97d1-1a024e753d1c	f8b1a855-954d-4f8b-aad7-be5502a7413a	Created	admin@talakunchi.com	admin	Profile created for Sneha Choudhary (TK-0053)	2026-10-16 14:55:33.261331+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
220fee5d-4de0-4acb-9e74-ed9cc72fc9f1	9b7f4410-6577-4ab4-9363-e75b9d4208e9	Created	admin@talakunchi.com	admin	Profile created for Sana Rao (TK-0054)	2026-10-16 14:55:33.270926+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
8d3d2f47-7118-4a24-8bc5-42e63cc6c2d1	ffcdc44f-996b-4ef6-90e6-db858823a4c4	Created	admin@talakunchi.com	admin	Profile created for Aditya Menon (TK-0055)	2026-10-16 14:55:33.281124+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
5b38c4d1-cac2-4ac8-bac8-7623258dc6b8	315ae0c9-ecdf-48ba-a662-f93c21ef31d2	Created	admin@talakunchi.com	admin	Profile created for Varun Pandey (TK-0056)	2026-10-16 14:55:33.291131+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
dabe8b8f-6520-4ce8-b1ef-ae11c78d1df4	df8f375a-d0b0-40c0-8ada-264fc2275f4f	Created	admin@talakunchi.com	admin	Profile created for Advait Gupta (TK-0057)	2026-10-16 14:55:33.301008+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
6422be78-7ac5-4406-bf02-32f1451dabec	78c932da-077a-4104-919c-386de88ed062	Created	admin@talakunchi.com	admin	Profile created for Meera Joshi (TK-0058)	2026-10-16 14:55:33.311256+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
e13fb692-6366-45ba-b1cc-ad989b598628	74601727-6182-498f-ac57-4c02b9e56ca0	Created	admin@talakunchi.com	admin	Profile created for Kunal Iyer (TK-0059)	2026-10-16 14:55:33.321038+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
3649664c-98c4-4f1a-840b-cf5c27879b91	0a46bda6-6481-4bbe-8689-18fe959fa98a	Created	admin@talakunchi.com	admin	Profile created for Trisha Pillai (TK-0060)	2026-10-16 14:55:33.331681+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
83ecd17e-81c4-42d1-ba60-e78f72326b44	bbe8dd34-5945-4f0f-ab99-2cb2f7c99c95	Created	admin@talakunchi.com	admin	Profile created for Aditya Pillai (TK-0061)	2026-10-16 14:55:33.341802+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
9c55f9b5-c7d0-4a67-8fb1-c32b7078804f	46e3d71d-ea02-474f-b668-f836d91e059d	Created	admin@talakunchi.com	admin	Profile created for Siddharth Iyer (TK-0062)	2026-10-16 14:55:33.352233+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
ef48902c-fe27-4d1c-b484-3d2a127553f5	e93a25e9-5347-49e1-b901-88271fdbdcf5	Created	admin@talakunchi.com	admin	Profile created for Kavya Roy (TK-0063)	2026-10-16 14:55:33.362553+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
0d0b6377-601f-47f7-a3a3-86d54cb1c21a	4d8e2104-d723-45a0-856f-594f80efd0f6	Created	admin@talakunchi.com	admin	Profile created for Amit Pillai (TK-0064)	2026-10-16 14:55:33.372343+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
b8f4b70f-5f6d-4407-b9d3-3cf60ef09d60	fb184814-7151-428d-87c3-f83814676aa5	Created	admin@talakunchi.com	admin	Profile created for Reyansh Mathur (TK-0065)	2026-10-16 14:55:33.382965+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
f78b6714-e775-443b-bcb4-34f109619848	6a1ac61a-89d6-4951-8246-621d4e1b071f	Created	admin@talakunchi.com	admin	Profile created for Nikhil Joshi (TK-0066)	2026-10-16 14:55:33.393299+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
33f9ffe3-f23a-4918-b524-afe5bb4f254a	26fd3209-693a-49d1-9224-8f7e2f3a1c58	Created	admin@talakunchi.com	admin	Profile created for Ishaan Desai (TK-0067)	2026-10-16 14:55:33.40328+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
2e17563f-975e-422f-87dc-408e65d579fe	5f4b7ab9-bbfe-4196-9e6c-47f73efe7462	Created	admin@talakunchi.com	admin	Profile created for Atharv Malhotra (TK-0068)	2026-10-16 14:55:33.413757+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
7cdd4781-9c22-46e7-b6bb-e81ebc621ad0	900ed2a0-d8b3-439f-af86-7383cdebcd05	Created	admin@talakunchi.com	admin	Profile created for Ishaan Pansare (TK-0069)	2026-10-16 14:55:33.424304+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
8a1705bb-ef03-48f3-97d7-81bf87216bf1	204776c8-efeb-480f-980b-a3f70be97f91	Created	admin@talakunchi.com	admin	Profile created for Divya Deshmukh (TK-0070)	2026-10-16 14:55:33.434651+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
6f5c08d4-2039-4ef6-82a4-8841acff5317	41708635-a60e-4fbd-a76b-91c0c23d18be	Created	admin@talakunchi.com	admin	Profile created for Advait Gaikwad (TK-0071)	2026-10-16 14:55:33.44587+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
e5ec647d-30d2-4d14-80d1-7208d5e75783	e09daabd-8da2-4dc9-89b4-03f4b79583de	Created	admin@talakunchi.com	admin	Profile created for Amit Gaikwad (TK-0072)	2026-10-16 14:55:33.457403+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
95872fd3-de7e-4c1b-8a00-2d066d9e31b7	faa36d59-2e24-4a0e-851d-42900c200d3b	Created	admin@talakunchi.com	admin	Profile created for Rohan Deshpande (TK-0073)	2026-10-16 14:55:33.467492+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
308c9a16-9ec9-45fd-8d65-48e3ed7ffdd0	5e82125c-9ff8-4a97-a11b-65da79677d3c	Created	admin@talakunchi.com	admin	Profile created for Reyansh Wardhan (TK-0074)	2026-10-16 14:55:33.479017+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
85e937b3-66fb-4987-8c2a-cbf1afd24039	ca561f47-f73a-4401-8c6f-a1c776d88534	Created	admin@talakunchi.com	admin	Profile created for Vihaan Iyer (TK-0075)	2026-10-16 14:55:33.489088+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
5a4e295f-4a34-408f-9cba-2b228fb9f3aa	51015348-f872-4e18-b806-e44017e10e4b	Created	admin@talakunchi.com	admin	Profile created for Dev Roy (TK-0076)	2026-10-16 14:55:33.499936+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
f0178c62-d0ca-411d-9c1d-67a0ea3b2152	bfb55863-c987-497b-9a1b-9a7bc56a9509	Created	admin@talakunchi.com	admin	Profile created for Nidhi Bose (TK-0077)	2026-10-16 14:55:33.521274+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d7c74123-7e43-4730-926c-693ee3d93892	dd200677-337b-440b-afcb-3a661406f98b	Created	admin@talakunchi.com	admin	Profile created for Reyansh Patel (TK-0078)	2026-10-16 14:55:33.533678+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
3cf8c8a9-0d2f-4bfc-855e-d8ee9fcf92a5	8f3346d4-6f76-4575-af6d-a69527694680	Created	admin@talakunchi.com	admin	Profile created for Deepak Singh (TK-0079)	2026-10-16 14:55:33.544019+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
30a590c9-3548-4944-845f-93a036174156	33e9644b-a618-47ed-b272-c078e19b36ef	Created	admin@talakunchi.com	admin	Profile created for Varun Gaikwad (TK-0080)	2026-10-16 14:55:33.555664+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
d2b2338c-ea02-4e8e-b3e1-044c8f0deb03	6b4e0847-6c40-471e-89ec-c5b63bb828f0	Created	admin@talakunchi.com	admin	Profile created for Arjun Menon (TK-0081)	2026-10-16 14:55:33.565857+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
f105ee48-a7c8-4480-bcb7-80ceeb9d5cc8	450f16b6-e35c-4564-969d-6bf6ceec7ff3	Created	admin@talakunchi.com	admin	Profile created for Kabir Sawant (TK-0082)	2026-10-16 14:55:33.577472+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
078f55cc-43a8-4be8-ac4e-467f5c22d194	31e49978-ac22-44bb-a535-11d20d8aeea3	Created	admin@talakunchi.com	admin	Profile created for Rahul Pillai (TK-0083)	2026-10-16 14:55:33.58765+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
9421dd29-eeb4-48df-96a4-6d71eed66da7	246e0bb0-8a3b-4524-9d7b-3ac6d4ca7d8d	Created	admin@talakunchi.com	admin	Profile created for Manish Malhotra (TK-0084)	2026-10-16 14:55:33.598591+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
a9f7e650-0af3-4054-be87-8585fecc098b	6d26e662-1e9f-4df8-a353-6be5ce9e5261	Created	admin@talakunchi.com	admin	Profile created for Lakshmi Kadam (TK-0085)	2026-10-16 14:55:33.609033+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
932081f3-f459-434d-84d4-ffe69c857528	6b1f9737-c1f7-4201-8cd2-9b5e6274ebc8	Created	admin@talakunchi.com	admin	Profile created for Vihaan Joshi (TK-0086)	2026-10-16 14:55:33.62058+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
242be7c5-be7f-4ce7-a9db-4994f5fd5e21	3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	Created	admin@talakunchi.com	admin	Profile created for Harsh Gupta (TK-0087)	2026-10-16 14:55:33.631268+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
109a4662-cc17-496f-a403-b3dadac6f358	1fa56f20-56ce-4461-ac66-c7d7b34f16d6	Created	admin@talakunchi.com	admin	Profile created for Siddharth Deshpande (TK-0088)	2026-10-16 14:55:33.641784+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
310f77d5-2cd9-4beb-827c-e813e2876448	cc295432-e771-4d6f-9cc3-079cc5d9b576	Created	admin@talakunchi.com	admin	Profile created for Alok Deshpande (TK-0089)	2026-10-16 14:55:33.653768+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
473be744-ead3-44f0-9a55-6db2f2da361b	5ff0346b-75b8-4c62-afc7-afeb35b17a8e	Created	admin@talakunchi.com	admin	Profile created for Siddharth Bose (TK-0090)	2026-10-16 14:55:33.664247+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
79805f6a-3db2-4cc5-ac3d-8316593b6884	9c4cf836-745e-4cf9-9a22-933d5e2638c3	Created	admin@talakunchi.com	admin	Profile created for Arjun Sawant (TK-0091)	2026-10-16 14:55:33.674919+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
f8887ba9-2369-4c39-a305-62f4d2703d78	ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	Created	admin@talakunchi.com	admin	Profile created for Harsh Joshi (TK-0092)	2026-10-16 14:55:33.685479+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
761940d8-97b4-4d4c-a506-c910b6ba07dc	d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	Created	admin@talakunchi.com	admin	Profile created for Aarav Patel (TK-0093)	2026-10-16 14:55:33.696298+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
9b6892c3-66a5-4aec-ac1e-561a91c802ae	f30d1ce8-8a1a-483d-ace2-419cd8672ecc	Created	admin@talakunchi.com	admin	Profile created for Manish Bose (TK-0094)	2026-10-16 14:55:33.707024+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
42f4385d-5cba-40a9-9b49-e9b5490a3056	3398777f-d384-48a2-8076-9c4fb06162bb	Created	admin@talakunchi.com	admin	Profile created for Karan Joshi (TK-0095)	2026-10-16 14:55:33.717492+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
1e319a15-6a3f-4235-b631-137e278c21b9	cef36bf2-c4fb-4040-b3ab-d033190ad3b4	Created	admin@talakunchi.com	admin	Profile created for Vikram Joshi (TK-0096)	2026-10-16 14:55:33.728372+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
33a70045-947b-443e-87ae-d9da7d45bd70	940ec7cd-058d-4f8f-912f-08ae55bac01c	Created	admin@talakunchi.com	admin	Profile created for Manish Mathur (TK-0097)	2026-10-16 14:55:33.739442+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
eccf94e4-8620-48fd-82b4-3fcac4fe0525	87fd3345-a756-44df-a3e7-5f21fa6e50d3	Created	admin@talakunchi.com	admin	Profile created for Aisha Mathur (TK-0098)	2026-10-16 14:55:33.749981+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
26eced82-0caf-4c17-a194-f98e51c31420	23bf310d-b789-4dcc-bb7e-576b373e72cf	Created	admin@talakunchi.com	admin	Profile created for Karan Mehta (TK-0099)	2026-10-16 14:55:33.772094+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
426120cc-0254-4ee1-85a7-693e59122508	089e3bae-d509-46db-906f-3085e0438c9c	Created	admin@talakunchi.com	admin	Profile created for Ira Reddy (TK-0100)	2026-10-16 14:55:33.801681+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
4b848f2c-d6ac-4af9-9aed-3913accaf591	d2010072-d612-48ab-9a8a-f137b87e6034	Updated	admin@talakunchi.com	admin	Updated: Location (Onsite)	2026-10-17 13:40:04.987833+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
10cc3172-94ab-45ea-adf6-667aee1508ee	f01f614a-af85-4225-a3b4-3c463fb97bdf	Updated	admin@talakunchi.com	admin	Updated: Emergency Contact Relation, Role, Experience, Bond Status, Sub Department, Billable Status (+4 more)	2026-10-18 02:15:12.944714+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
346863c7-8098-4c20-9d36-3127bc714a58	f01f614a-af85-4225-a3b4-3c463fb97bdf	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-18 02:15:12.944714+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
7192d3b3-36ed-458d-9409-19ca74c28e7f	049ac489-bbd3-4153-b933-aec7b7baec89	Updated	admin@talakunchi.com	admin	Profile details updated	2026-10-18 09:30:19.227531+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
ed93fa77-0969-4f96-ad43-1abeaf523c77	049ac489-bbd3-4153-b933-aec7b7baec89	Updated	admin@talakunchi.com	admin	Profile details updated	2026-10-18 09:32:03.390904+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
0e4a3463-aa2f-465d-b509-9b7d9d1ad8f8	13428d48-c81e-4720-adba-f8490f27e535	Updated	admin@talakunchi.com	admin	Updated: Experience, Bond Status, Billable Status, Project Type, Prior Total Experience, Prior Relevant Experience (+1 more)	2026-10-18 09:39:16.798473+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
685db74e-0574-493d-bf71-aa41cbf5b5a1	13428d48-c81e-4720-adba-f8490f27e535	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-18 09:39:16.798473+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
9a5a46f6-217e-4043-b81c-a4158732987a	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-18 10:51:26.379919+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a490d2a3-0ca2-4003-b551-cc2ff30b751d	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	Updated	admin@talakunchi.com	admin	Updated: Role, Joining Date, Experience, Sub Department, Billable Status, Project Type (+3 more)	2026-10-18 10:51:26.379919+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
1ad173fd-86c9-48c0-b973-ac1c2345a92d	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	Updated	admin@talakunchi.com	admin	Updated: Role, Joining Date, Bond Expiry Date	2026-10-18 10:52:07.272056+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
2873ae21-eafc-4e90-99e5-f09e6eee5b70	d94878fd-4650-46bc-b84c-753c841e7404	Updated	admin@talakunchi.com	admin	Updated: Department, Designation, Role, Experience, Bond Status, Sub Department (+5 more)	2026-10-18 16:07:32.945929+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
38b25f9e-fe0b-42db-85dc-35d9eb58b80f	d94878fd-4650-46bc-b84c-753c841e7404	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-18 16:07:32.945929+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
811e98a0-eef8-492b-a5f3-1dd5ae4741f0	4aba0077-4d88-4e0c-8d18-9152eea3fbf9	Updated	admin@talakunchi.com	admin	Updated: Department, Designation, Role, Sub Department	2026-10-22 12:39:19.938399+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a28816a1-19ca-4eaa-91ad-84b42f545649	ffcdc44f-996b-4ef6-90e6-db858823a4c4	Updated	admin@talakunchi.com	admin	Updated: Work Location, Location (Onsite)	2026-10-22 13:11:45.969197+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
d19104e9-a1a4-4383-a1ce-de29e8ed5d42	ffcdc44f-996b-4ef6-90e6-db858823a4c4	WorkLocationChanged	admin@talakunchi.com	admin	Suvidha Square, Andheri -> Onsite	2026-10-22 13:11:45.969197+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
1164d368-3f3d-4aec-8b25-4031a04237b2	f39b20bb-8963-4917-aed5-0f1d86f0cbc3	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-27 15:48:58.457418+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
236e3837-d3d5-4dd5-a830-0a9b204281af	f39b20bb-8963-4917-aed5-0f1d86f0cbc3	Updated	admin@talakunchi.com	admin	Updated: Employee Status, Status, Experience, Bond Status, Billable Status, Project Type (+3 more)	2026-10-27 15:48:58.457418+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
58f837a3-25ac-4da8-99ab-c436a8f341bc	d94878fd-4650-46bc-b84c-753c841e7404	Updated	admin@talakunchi.com	admin	Updated: Employee Status, Status	2026-10-27 15:53:40.436664+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
e5ba0941-c812-41a9-8132-33675db41b0d	d94878fd-4650-46bc-b84c-753c841e7404	Updated	admin@talakunchi.com	admin	Updated: Employee Status, Status	2026-10-27 15:54:15.103302+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
74a1a40d-cc97-4376-8d54-33b949ab9384	d94878fd-4650-46bc-b84c-753c841e7404	Updated	admin@talakunchi.com	admin	Updated: Employee Status, Status	2026-10-27 15:54:21.435691+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
0d896dfc-3fa2-4f77-9aa1-5cd9ade63466	d94878fd-4650-46bc-b84c-753c841e7404	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resigned, Reason: BO, Last Working Day: 2026-12-26)	2026-10-27 15:55:56.40164+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
82bb1f0c-a959-4449-80da-568139285bb7	d17be428-1602-4e09-a164-c3c2666fad73	Updated	admin@talakunchi.com	admin	Updated: Experience, Bond Status, Billable Status, Project Type, Prior Total Experience, Prior Relevant Experience (+1 more)	2026-10-28 09:21:10.040054+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
95dc41fe-49aa-4420-bdac-d88e6181eeb6	d17be428-1602-4e09-a164-c3c2666fad73	BillableStatusChanged	admin@talakunchi.com	admin	 -> Billable	2026-10-28 09:21:10.040054+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
f80aff3f-aa2b-40de-83db-d8fb77f31723	d94878fd-4650-46bc-b84c-753c841e7404	Updated	admin@talakunchi.com	admin	Profile details updated	2026-10-28 09:52:01.068284+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
6d013af4-b909-47ed-b1cc-49e0e7ff7dca	13428d48-c81e-4720-adba-f8490f27e535	Updated	admin@talakunchi.com	admin	Updated: Employee Status, Status	2026-10-28 10:13:23.157829+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
2ec8da23-c0f3-411b-9973-a0b8dffb7c5f	13428d48-c81e-4720-adba-f8490f27e535	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resigned, Reason: Personal, Last Working Day: 2026-10-29)	2026-10-28 10:13:42.416939+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
5fbbc0fd-98df-445b-8257-ec02d474ee4b	f39b20bb-8963-4917-aed5-0f1d86f0cbc3	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resigned, Reason: BO, Last Working Day: 2026-11-07)	2026-10-28 10:41:09.966696+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
995850b7-90da-486d-930d-654634fca3f9	849d2fb1-a4e4-4eb2-947b-f97057e4954b	Updated	admin@talakunchi.com	admin	Updated: Employee Status, Status	2026-10-28 10:47:14.576434+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
0365241c-4bbc-4b02-b522-a2b9e71002b4	849d2fb1-a4e4-4eb2-947b-f97057e4954b	Offboarded	admin@talakunchi.com	admin	Offboarded employee (Status: Resigned, Reason: Found better opportunity, Last Working Day: 2026-11-28)	2026-10-28 10:47:31.132301+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
55ac45b0-d38c-40fa-a79a-910a431850dd	849d2fb1-a4e4-4eb2-947b-f97057e4954b	Updated	admin@talakunchi.com	admin	Updated: Employee Status, Status, Exit Type, Exit Reason	2026-10-28 10:47:44.887215+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
3ba90147-c5cb-4c6f-a914-2eb8cdc8f7dc	583e812b-e929-4e7c-9d76-33d3fc25cd7d	Updated	admin@talakunchi.com	admin	Updated: Last Name	2026-11-17 17:09:40.895603+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
\.


--
-- Data for Name: tbl_employees; Type: TABLE DATA; Schema: resource; Owner: -
--

COPY resource.tbl_employees ("Id", "EmployeeCode", "FirstName", "LastName", "WorkEmail", "PersonalEmail", "Phone", "AltPhone", "Gender", "DateOfBirth", "Address", "EmergencyContact", "MaritalStatus", "Nationality", "DepartmentId", "DesignationId", "Role", "ReportingManagerId", "BusinessUnit", "WorkLocation", "OfficeBranch", "Category", "Team", "JoiningDate", "Status", "ConfirmationStatus", "ProbationStatus", "Experience", "PreviousCompany", "EmploymentType", "ContractType", "BondStatus", "NoticePeriod", "AssetId", "ExitType", "ExitReason", "Education", "Skills", "Certifications", "Languages", "KpiScore", "QuarterlyKpi", "AnnualRating", "GoalCompletion", "Attendance", "ReportingEfficiency", "PromotionReadiness", "ManagerFeedback", "Pan", "BankAccount", "SalaryBand", "PfUan", "TaxRegime", "ComplianceStatus", "UserId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "NationalityId", "ProbationPeriod", "SalaryBandId", "Aadhaar", "EmergencyContactName", "EmployeeStatusId", "BondDelivered", "BondDurationMonths", "BondExpiryDate", "GradDegree", "GradYear", "PostGradDegree", "PostGradYear", "ExpType", "PriorTotalExp", "PriorRelevantExp", "EmergencyContactRelation", "PmoDepartment", "SubDepartment", "BillableStatus", "ClientLocation", "ProjectType", "ProjectAllocated", "ClientEngManagerMapping", "ProjectSite", "EngagementManagerEmployeeId", "ProjectManagerId", "SubDepartmentId", "OriginalRole") FROM stdin;
26fd3209-693a-49d1-9224-8f7e2f3a1c58	TK-0067	Ishaan	Desai	ishaan.desai.tk-0067@talakunchi.com	\N	9820010075	\N	\N	\N	Andheri (Western Line)	9811001275	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-05-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.401399+05:30	2026-11-17 10:32:20.500269+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Iyer	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	PMO (Project Management Office)	\N	\N	\N	\N	\N	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	Testing-Team Leader
940ec7cd-058d-4f8f-912f-08ae55bac01c	TK-0097	Manish	Mathur	manish.mathur.tk-0097@talakunchi.com	\N	9820010106	\N	\N	\N	Andheri (Western Line)	9811001802	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-04-09	Terminated	Terminated	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	Yes	\N	Resign	Better opportunity	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.736486+05:30	2026-10-16 15:24:37.284411+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-16 15:24:37.284411+05:30	\N	\N	\N	\N	Advait Deshmukh	a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	\N	Testing-Team Member
2285ceea-ffbf-4bf4-bb2e-bd9e0427beeb	TK-0025	Vihaan	Mathur	vihaan.mathur.tk-0025@talakunchi.com	\N	9820010029	\N	\N	\N	Andheri (Western Line)	9811000493	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	PMO	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-09-27	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.950815+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Amit Sawant	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	PMO (Project Management Office)	\N	\N	\N	\N	\N	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO
238c3cb7-75cf-4478-a48e-fe47465d20b6	TK-0049	Ishita	Patel	ishita.patel.tk-0049@talakunchi.com	\N	9820010057	\N	\N	\N	Andheri (Western Line)	9811000969	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	6d25ff6d-e13d-440f-b775-215547af7acb	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-04-01	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.220166+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Advait Gupta	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Member
246e0bb0-8a3b-4524-9d7b-3ac6d4ca7d8d	TK-0084	Manish	Malhotra	manish.malhotra.tk-0084@talakunchi.com	\N	9820010093	\N	\N	\N	Andheri (Western Line)	9811001581	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-06-15	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.596427+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Harsh Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4	Testing-Team Member
2b245a46-a64c-440b-861d-24f712bd626e	TKI-0004	Kavya	Mathur	kavya.mathur.tki-0004@talakunchi.com	\N	9820010021	\N	\N	\N	Andheri (Western Line)	9811000357	\N	\N	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	f8502c44-b289-49e4-8401-3dcad4d5bbe0	IT Admin	049ac489-bbd3-4153-b933-aec7b7baec89	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-10-10	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.870977+05:30	2026-10-21 15:23:00.683803+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Mother	\N	Functional - IT Administration	\N	\N	\N	\N	\N	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	IT Admin
30913859-c8e8-4851-852f-28be97c74bb1	TK-0010	Sana	Pillai	sana.pillai.tk-0010@talakunchi.com	\N	9820010011	\N	\N	\N	Andheri (Western Line)	9811000187	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	1f97b442-95c5-4b11-93a0-ea146534ae85	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Onsite	\N	Permanent - Bond	\N	2018-10-17	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.759044+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Pallavi Sawant	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2020-10-17	BE	2020	NA	NA	Experienced	2 Years	2 Years	Mother	\N	Functional - Accounts	Billable	\N	Long Term	\N	\N	BKC	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Accounts
31057f6b-b1e5-46e3-a071-b6639b93a15c	TK-0051	Krishna	Bose	krishna.bose.tk-0051@talakunchi.com	\N	9820010059	\N	\N	\N	Andheri (Western Line)	9811001003	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	f20a7445-0b01-4f20-85a5-853101d864ee	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-05-17	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.239498+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Kunal Iyer	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Member
315ae0c9-ecdf-48ba-a662-f93c21ef31d2	TK-0056	Varun	Pandey	varun.pandey.tk-0056@talakunchi.com	\N	9820010064	\N	\N	\N	Andheri (Western Line)	9811001088	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	SOC-Senior Manager	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-09-09	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.289299+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Amit Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Senior Manager
31e49978-ac22-44bb-a535-11d20d8aeea3	TK-0083	Rahul	Pillai	rahul.pillai.tk-0083@talakunchi.com	\N	9820010092	\N	\N	\N	Andheri (Western Line)	9811001564	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-05-23	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.585583+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Sawant	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f	Testing-Team Member
33e9644b-a618-47ed-b272-c078e19b36ef	TK-0080	Varun	Gaikwad	varun.gaikwad.tk-0080@talakunchi.com	\N	9820010089	\N	\N	\N	Andheri (Western Line)	9811001513	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-03-15	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.553584+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Siddharth Deshpande	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f	Testing-Team Member
d94878fd-4650-46bc-b84c-753c841e7404	TK-0008	Nikhil	Saxena	nikhil.saxena.tk-0008@talakunchi.com	\N	9820010009	\N	\N	\N	Andheri (Western Line)	9811000153	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	SOC-Senior Manager	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-09-01	Resigned	Resigned	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	60 days	\N	Resigned	BO	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.734742+05:30	2026-10-28 09:52:01.064952+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	\N	\N	\N	Rajesh Sharma	ce28b4c5-a343-493b-9404-96c983768850	Yes	24	2020-09-01	BE	2020	NA	NA	Experienced	2 Years	2 Years	Guardian	\N	Services - Operations	Billable	\N	Long Term	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Senior Manager
13b14e34-f865-4c83-a6c0-3fdf7d196c1c	TK-0029	Reyansh	Sawant	reyansh.sawant.tk-0029@talakunchi.com	\N	9820010033	\N	\N	\N	Andheri (Western Line)	9811000561	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	b2b687ef-fd62-4cb7-a826-b40a35da7b2c	Sales Manager	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-12-28	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.988005+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aarav Desai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Sales Manager
3691f6bb-f0ca-4a5b-bdbb-a4c07624e803	TK-0087	Harsh	Gupta	harsh.gupta.tk-0087@talakunchi.com	\N	9820010096	\N	\N	\N	Andheri (Western Line)	9811001632	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	163d8c87-8f90-4295-a926-2e912c625a1c	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-08-23	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.628906+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Karan Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4	Testing-Team Member
3a209908-397f-4c90-abf6-9fe52ab98b34	TK-0050	Vihaan	Wardhan	vihaan.wardhan.tk-0050@talakunchi.com	\N	9820010058	\N	\N	\N	Andheri (Western Line)	9811000986	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	48429bb5-c583-4684-b30a-7ed443b671ca	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-04-24	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.230016+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Meera Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Member
405610b0-c3bd-4725-a409-5f6dbffeacb4	TKI-0007	Arjun	Wardhan	arjun.wardhan.tki-0007@talakunchi.com	\N	9820010038	\N	\N	\N	Andheri (Western Line)	9811000646	\N	\N	898c36e9-1cb7-4c56-9148-a3b6893c0149	bb7ccd5f-2f60-49fb-b984-f11fc47add22	R&D - Team member	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-12-18	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.03788+05:30	2026-10-21 15:23:00.683803+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Krishna Saxena	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Sibling	\N	R&D (Research & Development)	\N	\N	\N	\N	\N	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	R&D - Team member
41708635-a60e-4fbd-a76b-91c0c23d18be	TK-0071	Advait	Gaikwad	advait.gaikwad.tk-0071@talakunchi.com	\N	9820010079	\N	\N	\N	Andheri (Western Line)	9811001343	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	Testing-Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-08-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.443651+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Reyansh Patel	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755	Testing-Manager
42583b6b-008c-45f6-b258-b08495712c7c	TK-0016	Harsh	Wardhan	harsh.wardhan.tk-0016@talakunchi.com	\N	9820010018	\N	\N	\N	Andheri (Western Line)	9811000306	\N	\N	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	c70b9832-841e-4864-9b85-eaba3c0a995f	IT Admin	049ac489-bbd3-4153-b933-aec7b7baec89	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-03-04	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.838024+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Kunal Rao	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Functional - IT Administration	\N	\N	\N	\N	\N	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	IT Admin
450f16b6-e35c-4564-969d-6bf6ceec7ff3	TK-0082	Kabir	Sawant	kabir.sawant.tk-0082@talakunchi.com	\N	9820010091	\N	\N	\N	Andheri (Western Line)	9811001547	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-04-30	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.575322+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Siddharth Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755	Testing-Team Member
46e3d71d-ea02-474f-b668-f836d91e059d	TK-0062	Siddharth	Iyer	siddharth.iyer.tk-0062@talakunchi.com	\N	9820010070	\N	\N	\N	Andheri (Western Line)	9811001190	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e228c999-bf54-48b4-a373-d2bc9db88554	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-01-25	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.350043+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Divya Deshmukh	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755	Testing-Team Leader
4d8e2104-d723-45a0-856f-594f80efd0f6	TK-0064	Amit	Pillai	amit.pillai.tk-0064@talakunchi.com	\N	9820010072	\N	\N	\N	Andheri (Western Line)	9811001224	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-03-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.370485+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Amit Gaikwad	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4	Testing-Team Leader
51015348-f872-4e18-b806-e44017e10e4b	TK-0076	Dev	Roy	dev.roy.tk-0076@talakunchi.com	\N	9820010084	\N	\N	\N	Andheri (Western Line)	9811001428	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	c1fa4328-a970-48a1-bc08-d50fe36bf44c	Testing-Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-12-13	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.497879+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Rahul Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Testing - DevSecOps	\N	\N	\N	\N	\N	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Testing-Manager
51df4d23-9202-43b7-9e29-4a14a838a242	TK-0038	Vihaan	Gaikwad	vihaan.gaikwad.tk-0038@talakunchi.com	\N	9820010044	\N	\N	\N	Andheri (Western Line)	9811000748	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	Consulting-Team member	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-07-22	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.094147+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Consulting-Team member
218f30c7-87bd-4410-99fc-4d10da3e8014	TK-0043	Yash	Sharma	yash.sharma.tk-0043@talakunchi.com	\N	9820010050	\N	\N	\N	Andheri (Western Line)	9811000850	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	2b1558e3-158a-4a84-ae80-053129861a64	Consulting-HOD	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-11-14	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.151497+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Consulting-HOD
5e82125c-9ff8-4a97-a11b-65da79677d3c	TK-0074	Reyansh	Wardhan	reyansh.wardhan.tk-0074@talakunchi.com	\N	9820010082	\N	\N	\N	Andheri (Western Line)	9811001394	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	35a6b1af-dc78-4632-a9f4-eedabdbdcb52	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-10-28	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.476912+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Menon	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Testing - DevSecOps	\N	\N	\N	\N	\N	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Testing-Team Member
5bf6d5c7-4358-49f1-bb6b-9d0b1b38d4ad	TKI-0009	Priya	Mathur	priya.mathur.tki-0009@talakunchi.com	\N	9820010051	\N	\N	\N	Andheri (Western Line)	9811000867	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2025-02-02	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.161403+05:30	2026-10-21 15:23:00.683803+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Krishna Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Mother	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Member
5f4b7ab9-bbfe-4196-9e6c-47f73efe7462	TK-0068	Atharv	Malhotra	atharv.malhotra.tk-0068@talakunchi.com	\N	9820010076	\N	\N	\N	Andheri (Western Line)	9811001292	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-06-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.411718+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Dev Roy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755	Testing-Team Leader
5ff0346b-75b8-4c62-afc7-afeb35b17a8e	TK-0090	Siddharth	Bose	siddharth.bose.tk-0090@talakunchi.com	\N	9820010099	\N	\N	\N	Andheri (Western Line)	9811001683	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	9858c224-f97f-4ff8-908d-f46bd5e2243c	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-10-31	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.662063+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aisha Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4	Testing-Team Member
696f99d7-2380-443c-b90d-0e065642e1d4	TK-0019	Priya	Mishra	priya.mishra.tk-0019@talakunchi.com	\N	9820010022	\N	\N	\N	Andheri (Western Line)	9811000374	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	b3309eea-7374-4a8d-ac13-481b2a7fd492	PMO	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-05-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.881525+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Krishna Pandey	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	PMO (Project Management Office)	\N	\N	\N	\N	\N	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO
6a1ac61a-89d6-4951-8246-621d4e1b071f	TK-0066	Nikhil	Joshi	nikhil.joshi.tk-0066@talakunchi.com	\N	9820010074	\N	\N	\N	Andheri (Western Line)	9811001258	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-04-27	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.39087+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Reyansh Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f	Testing-Team Leader
6b1f9737-c1f7-4201-8cd2-9b5e6274ebc8	TK-0086	Vihaan	Joshi	vihaan.joshi.tk-0086@talakunchi.com	\N	9820010095	\N	\N	\N	Andheri (Western Line)	9811001615	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	163d8c87-8f90-4295-a926-2e912c625a1c	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-07-31	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.617282+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Manish Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f	Testing-Team Member
6b4e0847-6c40-471e-89ec-c5b63bb828f0	TK-0081	Arjun	Menon	arjun.menon.tk-0081@talakunchi.com	\N	9820010090	\N	\N	\N	Andheri (Western Line)	9811001530	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-04-07	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.563741+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Alok Deshpande	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4	Testing-Team Member
6d26e662-1e9f-4df8-a353-6be5ce9e5261	TK-0085	Lakshmi	Kadam	lakshmi.kadam.tk-0085@talakunchi.com	\N	9820010094	\N	\N	\N	Andheri (Western Line)	9811001598	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-07-08	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.606837+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aarav Patel	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755	Testing-Team Member
70e01a7d-fd0b-4e2a-b086-d059423ca380	TK-0014	Vihaan	Kadam	vihaan.kadam.tk-0014@talakunchi.com	\N	9820010016	\N	\N	\N	Andheri (Western Line)	9811000272	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	485012d4-2c28-4bc4-92c7-3609e3e3749e	HR	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-01-17	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.816829+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Karan Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	HR
62e81e6b-7247-4c3f-a8b8-db21e613d02a	TKI-0003	Aarav	Bose	aarav.bose.tki-0003@talakunchi.com	\N	9820010013	\N	\N	\N	Andheri (Western Line)	9811000221	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	e8c22eff-0daf-4690-a537-c8b0b6110a01	HR	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-09-17	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.782523+05:30	2026-10-21 15:23:00.683803+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Kavya Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Sibling	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	HR
74601727-6182-498f-ac57-4c02b9e56ca0	TK-0059	Kunal	Iyer	kunal.iyer.tk-0059@talakunchi.com	\N	9820010067	\N	\N	\N	Andheri (Western Line)	9811001139	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e2b4be77-2b20-4064-974d-e6322e7240b4	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-11-17	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.319145+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Ishaan Desai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Testing - Cloud & AI	\N	\N	\N	\N	\N	\N	\N	\N	88b29e0c-39b7-4169-ab5c-350075014a84	Testing-Team Member
776f2cf7-c4cc-4299-b38f-afbcaff7703e	TK-0030	Omkar	Reddy	omkar.reddy.tk-0030@talakunchi.com	\N	9820010034	\N	\N	\N	Andheri (Western Line)	9811000578	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	157d001c-b056-45b1-96a3-3c05bcd8d99c	Sales Manager	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-01-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.99725+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Amit Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Sales Manager
777390a6-91b9-4d9e-806c-16e046568501	TK-0028	Krishna	Joshi	krishna.joshi.tk-0028@talakunchi.com	\N	9820010032	\N	\N	\N	Andheri (Western Line)	9811000544	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	Sales team member	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-12-05	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.978927+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Suresh Desai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Sales team member
7e3f1c8d-340c-47d7-b63d-fb047a9106aa	TKI-0002	Aarav	Mathur	aarav.mathur.tki-0002@talakunchi.com	\N	9820010008	\N	\N	\N	Andheri (Western Line)	9811000136	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	caa227a1-2dcf-4195-ab9c-8f76d1862daa	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-08-25	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.722404+05:30	2026-10-21 15:23:00.683803+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Kadam	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Sibling	\N	Functional - Accounts	\N	\N	\N	\N	\N	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Accounts
78b71d74-d255-4ac0-a75f-ead11a61427a	TK-0035	Aarav	Desai	aarav.desai.tk-0035@talakunchi.com	\N	9820010041	\N	\N	\N	Andheri (Western Line)	9811000697	\N	\N	898c36e9-1cb7-4c56-9148-a3b6893c0149	9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	R&D - Team member	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-05-14	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.066207+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2022-05-14	BE	2020	NA	NA	Experienced	2 Years	2 Years	Mother	\N	R&D (Research & Development)	Billable	\N	Long Term	\N	\N	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	R&D - Team member
78c932da-077a-4104-919c-386de88ed062	TK-0058	Meera	Joshi	meera.joshi.tk-0058@talakunchi.com	\N	9820010066	\N	\N	\N	Andheri (Western Line)	9811001122	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	c0f974c3-f49c-449a-9276-aa64ce501344	SOC-Team Leader	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-10-25	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.309385+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Nikhil Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Leader
7d2b2c7a-254e-4605-9f79-3f42ac7f9735	TK-0027	Reyansh	Chopra	reyansh.chopra.tk-0027@talakunchi.com	\N	9820010031	\N	\N	\N	Andheri (Western Line)	9811000527	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	272973a6-c052-4aef-bf32-9e24f7eb6cc9	Sales team member	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-11-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.969016+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Yash Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Sales team member
804c8187-6f28-411f-8fa5-cc9baceba3e7	TK-0031	Arjun	Joshi	arjun.joshi.tk-0031@talakunchi.com	\N	9820010035	\N	\N	\N	Andheri (Western Line)	9811000595	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	6193be76-40ad-4973-9ee7-246a4d8f4109	Sales team member	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-02-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.006223+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Ira Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Sales team member
818ae1ea-5842-4adb-b475-ac12dba9fd2a	TK-0044	Vihaan	Bose	vihaan.bose.tk-0044@talakunchi.com	\N	9820010052	\N	\N	\N	Andheri (Western Line)	9811000884	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	SOC-HOD	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-12-07	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.171436+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Anita Iyer	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-HOD
86862bf8-c075-44ef-9f3e-f65d2cc1bb56	TK-0034	Suresh	Desai	suresh.desai.tk-0034@talakunchi.com	\N	9820010040	\N	\N	\N	Andheri (Western Line)	9811000680	\N	\N	898c36e9-1cb7-4c56-9148-a3b6893c0149	3356f353-1566-4df6-9958-fa01d67d13c7	R&D - Team member	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-04-21	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.057075+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Karan Mehra	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	R&D (Research & Development)	\N	\N	\N	\N	\N	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	R&D - Team member
8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	TK-0018	Harsh	Pandey	harsh.pandey.tk-0018@talakunchi.com	\N	9820010020	\N	\N	\N	Andheri (Western Line)	9811000340	\N	\N	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	da990f6e-3379-4cc4-89b7-0ead29da472b	IT Admin	049ac489-bbd3-4153-b933-aec7b7baec89	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-04-19	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.859733+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Atharv Reddy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Functional - IT Administration	\N	\N	\N	\N	\N	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	IT Admin
849d2fb1-a4e4-4eb2-947b-f97057e4954b	TK-0005	Dev	Bose	dev.bose.tk-0005@talakunchi.com	\N	9820010005	\N	\N	\N	Andheri (Western Line)	9811000085	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	155642eb-a633-4460-b658-aca9fde2d817	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-06-24	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	30 days	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.683541+05:30	2026-10-28 10:47:44.884439+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	Aarav Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Functional - Accounts	\N	\N	\N	\N	\N	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Accounts
8e0616db-48af-4b73-807f-6e250dba2072	TK-0020	Anita	Pandey	anita.pandey.tk-0020@talakunchi.com	\N	9820010023	\N	\N	\N	Andheri (Western Line)	9811000391	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	2a76927c-461a-48e4-8190-dea7361ef3db	PMO	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-06-04	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.891741+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Reyansh Chopra	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	PMO (Project Management Office)	\N	\N	\N	\N	\N	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO
8f3346d4-6f76-4575-af6d-a69527694680	TK-0079	Deepak	Singh	deepak.singh.tk-0079@talakunchi.com	\N	9820010088	\N	\N	\N	Andheri (Western Line)	9811001496	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	Testing Senior Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-02-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.541706+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Harsh Gupta	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755	Testing Senior Manager
900ed2a0-d8b3-439f-af86-7383cdebcd05	TK-0069	Ishaan	Pansare	ishaan.pansare.tk-0069@talakunchi.com	\N	9820010077	\N	\N	\N	Andheri (Western Line)	9811001309	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	Testing-Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-07-05	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.421674+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Simran Deshmukh	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f	Testing-Manager
9b7f4410-6577-4ab4-9363-e75b9d4208e9	TK-0054	Sana	Rao	sana.rao.tk-0054@talakunchi.com	\N	9820010062	\N	\N	\N	Andheri (Western Line)	9811001054	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	911f6d7f-8d43-40f2-897a-2f416abf8cf9	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-07-25	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.26888+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Siddharth Iyer	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Member
9c4cf836-745e-4cf9-9a22-933d5e2638c3	TK-0091	Arjun	Sawant	arjun.sawant.tk-0091@talakunchi.com	\N	9820010100	\N	\N	\N	Andheri (Western Line)	9811001700	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	9858c224-f97f-4ff8-908d-f46bd5e2243c	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-11-23	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.672237+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Karan Mehta	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755	Testing-Team Member
9d9bfa3a-8603-4de4-8eb7-76c3935e3014	TK-0012	Advait	Singh	advait.singh.tk-0012@talakunchi.com	\N	9820010014	\N	\N	\N	Andheri (Western Line)	9811000238	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	7d542941-65b9-499b-81b3-239748d6da52	HR	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-12-02	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.794393+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Priya Mishra	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	HR
9eb64ade-203d-4e4a-aaed-8eaab7d3017d	TK-0033	Yash	Wardhan	yash.wardhan.tk-0033@talakunchi.com	\N	9820010039	\N	\N	\N	Andheri (Western Line)	9811000663	\N	\N	898c36e9-1cb7-4c56-9148-a3b6893c0149	f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	R&D - Team member	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-03-29	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.047613+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aarav Reddy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	R&D (Research & Development)	\N	\N	\N	\N	\N	\N	\N	\N	7682acb3-561b-4951-801b-c1564adda131	R&D - Team member
9312226e-c7f8-4187-887e-67e2124098cd	TKI-0005	Kunal	Rao	kunal.rao.tki-0005@talakunchi.com	\N	9820010026	\N	\N	\N	Andheri (Western Line)	9811000442	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	9050e021-7d84-4401-820e-c0e768abb1ab	PM - Team Member	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-11-02	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.921408+05:30	2026-10-21 15:23:00.683803+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Omkar Reddy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Mother	\N	Functional - Project Management	\N	\N	\N	\N	\N	\N	\N	\N	a73eb36c-7d62-4aa8-901d-1c70b3876b69	PM - Team Member
9ec115c7-5377-4f9d-b46a-2a3c97bea4de	TKI-0008	Aarav	Reddy	aarav.reddy.tki-0008@talakunchi.com	\N	9820010047	\N	\N	\N	Andheri (Western Line)	9811000799	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	2076a9b1-e432-46a9-99b1-36e732159856	Consulting-Team member	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2025-01-10	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.123207+05:30	2026-10-21 15:23:00.683803+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vikram Roy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Spouse	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Consulting-Team member
9f646393-8fea-4b38-9f35-d88a6ab6787e	TK-0023	Aarav	Rao	aarav.rao.tk-0023@talakunchi.com	\N	9820010027	\N	\N	\N	Andheri (Western Line)	9811000459	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	8b57cfd5-5d4e-44a3-9646-b36873c111c2	EngagementManager	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-08-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.931379+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	EM (Engagement Manager)	\N	\N	\N	\N	\N	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EngagementManager
a73329ac-636f-475e-b566-321a5686fd66	TK-0017	Pallavi	Sawant	pallavi.sawant.tk-0017@talakunchi.com	\N	9820010019	\N	\N	\N	Andheri (Western Line)	9811000323	\N	\N	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	73bd55bb-5d0e-4381-8ad2-2238377fca93	IT Admin	049ac489-bbd3-4153-b933-aec7b7baec89	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-03-27	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.848874+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aarav Rao	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Functional - IT Administration	\N	\N	\N	\N	\N	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	IT Admin
b9c0b8fc-4c96-42fb-8669-d68097cf5392	TK-0048	Aditi	Roy	aditi.roy.tk-0048@talakunchi.com	\N	9820010056	\N	\N	\N	Andheri (Western Line)	9811000952	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	e36018c5-bf48-4f93-bef7-93e8864a0b51	SOC-Team Leader	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-03-09	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.210593+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Varun Pandey	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Leader
bbdc4c49-4262-4c1a-a270-1bfe3c550644	TK-0036	Amit	Wardhan	amit.wardhan.tk-0036@talakunchi.com	\N	9820010042	\N	\N	\N	Andheri (Western Line)	9811000714	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	195d6a81-8457-4b60-9382-6a3a0664f0e9	Consulting-Manager	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-06-06	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.075353+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Yash Sharma	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Consulting-Manager
bbe8dd34-5945-4f0f-ab99-2cb2f7c99c95	TK-0061	Aditya	Pillai	aditya.pillai.tk-0061@talakunchi.com	\N	9820010069	\N	\N	\N	Andheri (Western Line)	9811001173	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e228c999-bf54-48b4-a373-d2bc9db88554	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-01-02	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.339329+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Ishaan Pansare	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4	Testing-Team Leader
be9f417e-d40a-4c66-91e6-e7fde84b46d5	TK-0026	Krishna	Pandey	krishna.pandey.tk-0026@talakunchi.com	\N	9820010030	\N	\N	\N	Andheri (Western Line)	9811000510	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	138434a2-625f-4df5-836d-fcf0cfceef79	PMO	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-10-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.959922+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Wardhan	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	PMO (Project Management Office)	\N	\N	\N	\N	\N	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO
bfb55863-c987-497b-9a1b-9a7bc56a9509	TK-0077	Nidhi	Bose	nidhi.bose.tk-0077@talakunchi.com	\N	9820010086	\N	\N	\N	Andheri (Western Line)	9811001462	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	Testing Senior Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-01-05	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.519257+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Lakshmi Kadam	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f	Testing Senior Manager
c5e35b7a-af12-4fd6-96af-e62225e715c6	TK-0041	Karan	Mehra	karan.mehra.tk-0041@talakunchi.com	\N	9820010048	\N	\N	\N	Andheri (Western Line)	9811000816	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	Consulting-Team Leader	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-09-29	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.132457+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aditi Roy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Consulting-Team Leader
ca561f47-f73a-4401-8c6f-a1c776d88534	TK-0075	Vihaan	Iyer	vihaan.iyer.tk-0075@talakunchi.com	\N	9820010083	\N	\N	\N	Andheri (Western Line)	9811001411	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	767a00dd-6f09-4f64-a44e-8fbe901222af	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-11-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.48702+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Kabir Sawant	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Testing - DevSecOps	\N	\N	\N	\N	\N	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Testing-Team Member
cc295432-e771-4d6f-9cc3-079cc5d9b576	TK-0089	Alok	Deshpande	alok.deshpande.tk-0089@talakunchi.com	\N	9820010098	\N	\N	\N	Andheri (Western Line)	9811001666	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	9858c224-f97f-4ff8-908d-f46bd5e2243c	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-10-08	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.651136+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Manish Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f	Testing-Team Member
d01c0ef5-731e-42de-b02a-7c996c545f15	TK-0045	Vivaan	Mathur	vivaan.mathur.tk-0045@talakunchi.com	\N	9820010053	\N	\N	\N	Andheri (Western Line)	9811000901	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea315f7d-d597-41b3-a999-4f3851bcd020	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-12-30	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.181143+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Sneha Choudhary	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Member
d2010072-d612-48ab-9a8a-f137b87e6034	TK-0006	Amit	Deshmukh	amit.deshmukh.tk-0006@talakunchi.com	\N	9820010006	\N	\N	\N	Marine Lines (Western Line)	9811000102	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	8dc0d8fe-593d-422a-8b27-5b68fbe6d224	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Onsite	\N	Permanent - Bond	\N	2018-07-17	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.698357+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Advait Singh	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2020-07-17	BE	2020	NA	NA	Experienced	2 Years	2 Years	Mother	\N	Functional - Accounts	Billable	\N	Long Term	\N	\N	Pune	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Accounts
d502bbdd-5186-490e-8f0a-5489d2737c6f	TKI-0001	Nikhil	Malhotra	nikhil.malhotra.tki-0001@talakunchi.com	\N	9820010004	\N	\N	\N	Andheri (Western Line)	9811000068	\N	\N	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	c0e1a001-0000-4000-8000-000000000001	Intern	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-08-02	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.672816+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aditya Roy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Guardian	\N	Across all Sub Departments	\N	\N	\N	\N	\N	\N	\N	\N	63765624-d7d1-472d-abd4-627127646998	Intern
d73eac4c-d537-4d31-8e35-b55f8aff3e87	TK-0046	Arjun	Pillai	arjun.pillai.tk-0046@talakunchi.com	\N	9820010054	\N	\N	\N	Andheri (Western Line)	9811000918	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	4650d4e0-f73c-4688-ae5f-830a46348ff9	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-01-22	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.190401+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Sana Rao	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Member
d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	TK-0021	Karan	Wardhan	karan.wardhan.tk-0021@talakunchi.com	\N	9820010024	\N	\N	\N	Andheri (Western Line)	9811000408	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	834c9e15-c70d-4a0b-bb12-5e55f23c181d	EngagementManager	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-06-27	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.901338+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Krishna Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	EM (Engagement Manager)	\N	\N	\N	\N	\N	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EngagementManager
d9fd54d6-b11b-4969-a25d-8b8e3fcca417	TK-0032	Amit	Sawant	amit.sawant.tk-0032@talakunchi.com	\N	9820010037	\N	\N	\N	Andheri (Western Line)	9811000629	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	e2c675a7-92dc-4477-be75-9a304cbe4def	Sales team member	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-03-06	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.027123+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Pooja Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Sales team member
dd200677-337b-440b-afcb-3a661406f98b	TK-0078	Reyansh	Patel	reyansh.patel.tk-0078@talakunchi.com	\N	9820010087	\N	\N	\N	Andheri (Western Line)	9811001479	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	Testing Senior Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-01-28	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.531601+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4	Testing Senior Manager
df8f375a-d0b0-40c0-8ada-264fc2275f4f	TK-0057	Advait	Gupta	advait.gupta.tk-0057@talakunchi.com	\N	9820010065	\N	\N	\N	Andheri (Western Line)	9811001105	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	444df30d-c195-42ad-b9a7-d80cdef69ccd	SOC-Team Leader	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-10-02	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.299121+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Reyansh Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Leader
e09daabd-8da2-4dc9-89b4-03f4b79583de	TK-0072	Amit	Gaikwad	amit.gaikwad.tk-0072@talakunchi.com	\N	9820010080	\N	\N	\N	Andheri (Western Line)	9811001360	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	c6c6cd04-6df3-4593-b686-e4b9d362c96f	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-09-12	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.453799+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Deepak Singh	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Testing - DevSecOps	\N	\N	\N	\N	\N	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Testing-Team Leader
e131815f-331f-46d7-81f8-5d2bed793630	TK-0037	Ira	Bose	ira.bose.tk-0037@talakunchi.com	\N	9820010043	\N	\N	\N	Andheri (Western Line)	9811000731	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	1e7faab8-273d-40df-9f9a-485160186c5a	Consulting-Team member	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-06-29	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.084626+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Priya Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Consulting-Team member
87fd3345-a756-44df-a3e7-5f21fa6e50d3	TK-0098	Aisha	Mathur	aisha.mathur.tk-0098@talakunchi.com	\N	9820010107	\N	\N	\N	Andheri (Western Line)	9811001819	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-05-02	Terminated	Terminated	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	Yes	\N	Resign	Better opportunity	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.747534+05:30	2026-10-16 15:24:37.309719+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-16 15:24:37.309719+05:30	\N	\N	\N	\N	Divya Sawant	a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	\N	Testing-Team Member
02814af4-08b4-42cc-92e1-ad0bba687378	TK-0039	Pooja	Bose	pooja.bose.tk-0039@talakunchi.com	\N	9820010045	\N	\N	\N	Andheri (Western Line)	9811000765	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	Consulting-Team member	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-08-14	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.103381+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vivaan Mathur	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Consulting-Team member
033446c7-c133-4395-bdaa-69b5f227a7a8	TK-0024	Atharv	Reddy	atharv.reddy.tk-0024@talakunchi.com	\N	9820010028	\N	\N	\N	Andheri (Western Line)	9811000476	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	9dc69952-eae6-4ec0-a327-67392315f089	EngagementManager	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-09-04	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.940959+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Ananya Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	EM (Engagement Manager)	\N	\N	\N	\N	\N	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EngagementManager
049ac489-bbd3-4153-b933-aec7b7baec89	TK-0004	Admin	User	admin@talakunchi.com	\N	9820000004	\N	\N	\N	Andheri (Western Line)	\N	\N	\N	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	da990f6e-3379-4cc4-89b7-0ead29da472b	Admin	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Without Bond	\N	2018-06-01	Active	Active	Ongoing	0 (Relevant: 0)	\N	Permanent	\N	No bond	\N	\N	NA	NA	\N	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.5279+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	\N	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	\N	\N	NA	NA	Experienced	0	0	\N	\N	Functional - IT Administration	Billable	\N	Long Term	\N	\N	\N	\N	\N	4dc4a56b-f458-4047-a1ca-345eaa08b5e3	Admin
23bf310d-b789-4dcc-bb7e-576b373e72cf	TK-0099	Karan	Mehta	karan.mehta.tk-0099@talakunchi.com	\N	9820010108	\N	\N	\N	Andheri (Western Line)	9811001836	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-05-25	Terminated	Terminated	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	Yes	\N	Resign	Better opportunity	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.767705+05:30	2026-10-16 15:24:37.319639+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-16 15:24:37.319639+05:30	\N	\N	\N	\N	Kunal Desai	a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	\N	Testing-Team Member
089e3bae-d509-46db-906f-3085e0438c9c	TK-0100	Ira	Reddy	ira.reddy.tk-0100@talakunchi.com	\N	9820010109	\N	\N	\N	Andheri (Western Line)	9811001853	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-06-17	Terminated	Terminated	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	Yes	\N	Resign	Better opportunity	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.799186+05:30	2026-10-16 15:24:37.329732+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-16 15:24:37.329732+05:30	\N	\N	\N	\N	Vivaan Iyer	a0b5f4d8-fb43-4df7-a98d-0e2454a0907b	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	\N	Testing-Team Member
d29c4919-9e2d-46c1-a78f-ffd2d4d32365	TK-0052	Anita	Iyer	anita.iyer.tk-0052@talakunchi.com	\N	9820010060	\N	\N	\N	Andheri (Western Line)	9811001020	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0c1a5ef4-7fca-45dc-8253-87afa21a1df9	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-06-09	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.249213+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Trisha Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Member
f19ea8a8-4d2f-48f9-832e-311f80e49f11	TKI-0006	Ananya	Joshi	ananya.joshi.tki-0006@talakunchi.com	\N	9820010036	\N	\N	\N	Andheri (Western Line)	9811000612	\N	\N	13c91c98-00ae-4211-acb8-d06e35953806	e2b10def-c91d-45da-94c5-f5530e743aa2	Sales team member	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Intern - Paid	\N	2024-11-25	Active	Active	Completed	Fresher	\N	Intern	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.016241+05:30	2026-10-21 15:23:00.683803+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Gaikwad	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	\N	BE	2020	NA	NA	Fresher	0	0	Mother	\N	Functional - Sales	\N	\N	\N	\N	\N	\N	\N	\N	fa773eb9-162f-4ea8-9fc4-9c54a3068582	Sales team member
e93a25e9-5347-49e1-b901-88271fdbdcf5	TK-0063	Kavya	Roy	kavya.roy.tk-0063@talakunchi.com	\N	9820010071	\N	\N	\N	Andheri (Western Line)	9811001207	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-02-17	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.359883+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Advait Gaikwad	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f	Testing-Team Leader
e96df572-92a2-4aa3-a3b4-6f52cfcb5293	TK-0011	Aditya	Roy	aditya.roy.tk-0011@talakunchi.com	\N	9820010012	\N	\N	\N	Andheri (Western Line)	9811000204	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	HR	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-11-09	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.770263+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Harsh Pandey	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	HR
eba0b052-26bb-4216-ab6e-dff23c63bc57	TK-0022	Rahul	Mishra	rahul.mishra.tk-0022@talakunchi.com	\N	9820010025	\N	\N	\N	Andheri (Western Line)	9811000425	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	d8a2b9e5-f54d-4344-a78d-c6c840467543	EngagementManager	d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-07-20	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.910624+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Reyansh Sawant	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	EM (Engagement Manager)	\N	\N	\N	\N	\N	\N	\N	\N	63bc0f54-4d35-4279-bb62-4daeff6ceeaa	EngagementManager
ee7b555a-4400-4c03-8fe5-60fd908c0e58	TK-0042	Arjun	Mathur	arjun.mathur.tk-0042@talakunchi.com	\N	9820010049	\N	\N	\N	Andheri (Western Line)	9811000833	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	3e60b693-d3dd-4481-95c4-9f02da21625c	Consulting-Team Leader	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-10-22	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.141853+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Ishita Patel	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Consulting-Team Leader
f01f614a-af85-4225-a3b4-3c463fb97bdf	TK-0003	Dev	Reddy	dev.reddy.tk-0003@talakunchi.com	\N	9820010003	\N	\N	\N	Andheri (Western Line)	9811000051	\N	\N	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	0525d830-ead9-44a0-871f-91b7845fec26	CTO	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-05-09	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.662231+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Sana Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2020-05-09	BE	2020	NA	NA	Experienced	2 Years	2 Years	Friend	\N	Leading Compliance & HR Department	Billable	\N	Long Term	\N	\N	\N	\N	\N	61bbeadf-3044-4123-929c-4b1e6e2e613e	CTO
f8b1a855-954d-4f8b-aad7-be5502a7413a	TK-0053	Sneha	Choudhary	sneha.choudhary.tk-0053@talakunchi.com	\N	9820010061	\N	\N	\N	Andheri (Western Line)	9811001037	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-07-02	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.259434+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aditya Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Member
f90e007c-90d9-440e-8f0a-a85395e49abe	TK-0047	Vikram	Roy	vikram.roy.tk-0047@talakunchi.com	\N	9820010055	\N	\N	\N	Andheri (Western Line)	9811000935	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	af8a1442-c5ee-409d-aa91-61c9dba852ee	SOC-Team Member	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-02-14	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.200068+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Aditya Menon	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Services - Operations	\N	\N	\N	\N	\N	\N	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Team Member
faa36d59-2e24-4a0e-851d-42900c200d3b	TK-0073	Rohan	Deshpande	rohan.deshpande.tk-0073@talakunchi.com	\N	9820010081	\N	\N	\N	Andheri (Western Line)	9811001377	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	ae255622-ddcc-45ea-a699-8ec416fe57ab	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-10-05	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.465301+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Varun Gaikwad	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Testing - DevSecOps	\N	\N	\N	\N	\N	\N	\N	\N	8bfa4c2a-cb0e-4bd0-b184-43d105be44b9	Testing-Team Member
fb184814-7151-428d-87c3-f83814676aa5	TK-0065	Reyansh	Mathur	reyansh.mathur.tk-0065@talakunchi.com	\N	9820010073	\N	\N	\N	Andheri (Western Line)	9811001241	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	Testing-Team Leader	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-04-04	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.380982+05:30	2026-10-21 00:01:50.195919+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Rohan Deshpande	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755	Testing-Team Leader
ffcdc44f-996b-4ef6-90e6-db858823a4c4	TK-0055	Aditya	Menon	aditya.menon@talakunchi.com	\N	9820010063	\N	\N	\N	Andheri (Western Line)	9811001071	\N	\N	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b5f39dd8-c305-489d-9f7d-9adfd010a134	SOC-Manager	818ae1ea-5842-4adb-b475-ac12dba9fd2a	Talakunchi Networks Private Limited	Onsite	\N	Permanent - Without Bond	\N	2021-08-17	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	No bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.278641+05:30	2026-10-22 13:11:45.955014+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	\N	\N	\N	Kavya Roy	e273e2ed-5fd3-4564-bb87-09a71cd4779a	No	0	2028-10-16	BE	2020	NA	NA	Experienced	2 Years	2 Years	Sibling	\N	Services - Operations	Billable	\N	Long Term	\N	\N	Thane	\N	\N	cfdb2071-d50e-4ea3-b732-19eb08f1e629	SOC-Manager
13428d48-c81e-4720-adba-f8490f27e535	TK-0009	Vihaan	Saxena	vihaan.saxena.tk-0009@talakunchi.com	\N	9820010010	\N	\N	\N	Andheri (Western Line)	9811000170	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	96efad7d-8b7f-4d7f-a862-c0a6bec3789f	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-09-24	Resigned	Resigned	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	1 days	\N	Resigned	Personal	BE (2020)	[]	["Certified Ethical Hacker (CEH)"]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.747702+05:30	2026-10-30 10:38:24.621416+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	00000000-0000-4000-8000-000000000004	2026-10-30 10:38:24.621416+05:30	\N	\N	\N	\N	Harsh Wardhan	ce28b4c5-a343-493b-9404-96c983768850	Yes	24	2020-09-24	BE	2020	NA	NA	Experienced	2 Years	2 Years	Father	\N	Functional - Accounts	Billable	\N	Long Term	\N	\N	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Accounts
f39b20bb-8963-4917-aed5-0f1d86f0cbc3	TK-0007	Aarav	Roy	aarav.roy.tk-0007@talakunchi.com	\N	9820010007	\N	\N	\N	Andheri (Western Line)	9811000119	\N	\N	bcbd68c8-c3f3-4396-abb0-0b0e13637958	6e606c29-2ebf-4ab8-8006-aaedd5680009	Accounts	d17be428-1602-4e09-a164-c3c2666fad73	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-08-09	Resigned	Resigned	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	10 days	\N	Resigned	BO	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.709153+05:30	2026-11-10 03:48:02.522381+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	cc9bf92a-b923-8364-be83-4bb68db79cd2	2026-11-10 03:48:02.522381+05:30	\N	\N	\N	\N	Tanvi Gaikwad	ce28b4c5-a343-493b-9404-96c983768850	Yes	24	2020-08-09	BE	2020	NA	NA	Experienced	2 Years	2 Years	Spouse	\N	Functional - Accounts	Billable	\N	Long Term	\N	\N	\N	\N	\N	5d962383-f175-4dd8-af63-8a566a0d2255	Accounts
f30d1ce8-8a1a-483d-ace2-419cd8672ecc	TK-0094	Manish	Bose	manish.bose.tk-0094@talakunchi.com	\N	9820010103	\N	\N	\N	Andheri (Western Line)	9811001751	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	4b680e29-b4fb-4689-9afb-67a7f089f52b	Testing-Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-01-31	Resignation Under Review	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	In progress	\N	Resign	Personal reasons	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.704355+05:30	2026-11-16 00:05:25.670882+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	00000000-0000-4000-8000-000000000004	2026-11-16 00:05:25.670882+05:30	\N	\N	\N	\N	Aarav Deshmukh	beee234f-c734-4d09-a0bb-96a6cc523cc3	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Services - Testing - Red Team	\N	\N	\N	\N	\N	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798	Testing-Manager
3398777f-d384-48a2-8076-9c4fb06162bb	TK-0095	Karan	Joshi	karan.joshi.tk-0095@talakunchi.com	\N	9820010104	\N	\N	\N	Andheri (Western Line)	9811001768	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	Testing-Manager	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-02-23	Resignation Under Review	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	In progress	\N	Resign	Personal reasons	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.715255+05:30	2026-11-16 00:05:25.670882+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	00000000-0000-4000-8000-000000000004	2026-11-16 00:05:25.670882+05:30	\N	\N	\N	\N	Shaurya Pandey	beee234f-c734-4d09-a0bb-96a6cc523cc3	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Guardian	\N	Services - Testing - Cloud & AI	\N	\N	\N	\N	\N	\N	\N	\N	88b29e0c-39b7-4169-ab5c-350075014a84	Testing-Manager
ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	TK-0092	Harsh	Joshi	harsh.joshi.tk-0092@talakunchi.com	\N	9820010101	\N	\N	\N	Andheri (Western Line)	9811001717	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-12-16	Resignation Under Review	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	In progress	\N	Resign	Personal reasons	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.683278+05:30	2026-11-16 00:05:25.670882+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	00000000-0000-4000-8000-000000000004	2026-11-16 00:05:25.670882+05:30	\N	\N	\N	\N	Ira Reddy	beee234f-c734-4d09-a0bb-96a6cc523cc3	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Testing - Red Team	\N	\N	\N	\N	\N	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798	Testing-Team Member
cef36bf2-c4fb-4040-b3ab-d033190ad3b4	TK-0096	Vikram	Joshi	vikram.joshi.tk-0096@talakunchi.com	\N	9820010105	\N	\N	\N	Andheri (Western Line)	9811001785	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-03-17	Resignation Under Review	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	In progress	\N	Resign	Personal reasons	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.725971+05:30	2026-11-16 00:05:25.670882+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	00000000-0000-4000-8000-000000000004	2026-11-16 00:05:25.670882+05:30	\N	\N	\N	\N	Rahul Sharma	beee234f-c734-4d09-a0bb-96a6cc523cc3	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f	Testing-Team Member
d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	TK-0093	Aarav	Patel	aarav.patel.tk-0093@talakunchi.com	\N	9820010102	\N	\N	\N	Andheri (Western Line)	9811001734	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	85cc9fbe-98a4-464d-a638-05f40529c6de	Testing-Team Member	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2024-01-08	Resignation Under Review	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	In progress	\N	Resign	Personal reasons	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.693648+05:30	2026-11-16 00:05:25.670882+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	00000000-0000-4000-8000-000000000004	2026-11-16 00:05:25.670882+05:30	\N	\N	\N	\N	Neha Choudhary	beee234f-c734-4d09-a0bb-96a6cc523cc3	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Services - Testing - Red Team	\N	\N	\N	\N	\N	\N	\N	\N	b651aec8-5455-4329-8251-0ceb62cea798	Testing-Team Member
583e812b-e929-4e7c-9d76-33d3fc25cd7d	TK-0013	Tanvi	Gaikwadi	tanvi.gaikwad.tk-0013@talakunchi.com	\N	9820010015	\N	\N	\N	Andheri (Western Line)	9811000255	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	c2e248c8-e917-445f-9f7b-1e25d7bb5abe	HR	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-12-25	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.806235+05:30	2026-11-17 17:09:40.846707+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	\N	\N	\N	Anita Pandey	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Father	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	HR
159fb3d0-937c-4f81-ad37-aa1b4f023264	TK-0015	Rajesh	Sharma	rajesh.sharma.tk-0015@talakunchi.com	\N	9820010017	\N	\N	\N	Andheri (Western Line)	9811000289	\N	\N	310a2f16-15f6-4b82-95f6-ab18b5b429f5	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	SOC-HOD	e96df572-92a2-4aa3-a3b4-6f52cfcb5293	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2019-02-09	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.827405+05:30	2026-11-18 10:02:17.792303+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Rahul Mishra	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Functional - HR	\N	\N	\N	\N	\N	\N	\N	\N	c88d783b-b628-4f3a-a972-aa56aeed5e77	HR
1fa56f20-56ce-4461-ac66-c7d7b34f16d6	TK-0088	Siddharth	Deshpande	siddharth.deshpande.tk-0088@talakunchi.com	\N	9820010097	\N	\N	\N	Andheri (Western Line)	9811001649	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	SOC-HOD	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2023-09-15	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.639521+05:30	2026-11-18 10:02:17.792303+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vikram Joshi	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Spouse	\N	Service - Testing - Mobile	\N	\N	\N	\N	\N	\N	\N	\N	db0addff-605e-439f-917b-38016a398755	Testing-Team Member
204776c8-efeb-480f-980b-a3f70be97f91	TK-0070	Divya	Deshmukh	divya.deshmukh.tk-0070@talakunchi.com	\N	9820010078	\N	\N	\N	Andheri (Western Line)	9811001326	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	SOC-HOD	0a46bda6-6481-4bbe-8689-18fe959fa98a	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2022-07-28	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.43265+05:30	2026-11-18 10:02:17.792303+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Nidhi Bose	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - Infra	\N	\N	\N	\N	\N	\N	\N	\N	e99b7773-5d71-4dca-ad36-b896dcfb71c4	Testing-Manager
4aba0077-4d88-4e0c-8d18-9152eea3fbf9	TK-0001	Vihaan	Pillai	vihaan.pillai.tk-0001@talakunchi.com	\N	9820010001	\N	\N	\N	Andheri (Western Line)	9811000017	\N	\N	8e4e88f1-e294-4554-80cc-92ed6169caeb	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	SOC-HOD	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2026-10-16	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.636311+05:30	2026-11-18 10:02:17.792303+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Nikhil Saxena	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 Years	2 Years	Mother	\N	PMO (Project Management Office)	Billable	\N	Long Term	\N	\N	\N	\N	\N	fd84aa38-11ef-46af-ade7-241f2a2c08fd	PMO
d17be428-1602-4e09-a164-c3c2666fad73	TK-0002	Neha	Pillai	neha.pillai.tk-0002@talakunchi.com	\N	9820010002	\N	\N	\N	Andheri (Western Line)	9811000034	\N	\N	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	SOC-HOD	\N	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2018-04-16	Active	Active	Completed	2 Years (Relevant: 2 Years)	\N	Permanent	\N	Expired	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:32.651331+05:30	2026-11-18 10:02:17.792303+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Vihaan Saxena	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2020-04-16	BE	2020	NA	NA	Experienced	2 Years	2 Years	Spouse	\N	Leading Delivery Department	Billable	\N	Long Term	\N	\N	\N	\N	\N	45755b2a-741a-4990-ab78-8f65090f75b1	COO
0a213b8b-1836-4660-9116-536fc9436639	TK-0040	Krishna	Saxena	krishna.saxena.tk-0040@talakunchi.com	\N	9820010046	\N	\N	\N	Andheri (Western Line)	9811000782	\N	\N	be8e036d-ad13-4c79-89ec-294e490a6816	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	SOC-HOD	bbdc4c49-4262-4c1a-a270-1bfe3c550644	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2020-09-06	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.113491+05:30	2026-11-18 10:02:17.792303+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Arjun Pillai	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Mother	\N	Services - Consulting	\N	\N	\N	\N	\N	\N	\N	\N	748e93ce-e6cc-4a4f-bbc9-a769ce654c9c	Consulting-Team member
0a46bda6-6481-4bbe-8689-18fe959fa98a	TK-0060	Trisha	Pillai	trisha.pillai.tk-0060@talakunchi.com	\N	9820010068	\N	\N	\N	Andheri (Western Line)	9811001156	\N	\N	0aed67b8-c454-439a-a07f-4f46d46d58af	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	SOC-HOD	f01f614a-af85-4225-a3b4-3c463fb97bdf	Talakunchi Networks Private Limited	Suvidha Square, Andheri	\N	Permanent - Bond	\N	2021-12-10	Active	Active	Completed	2 yrs 0 mos (Relevant: 2 yrs 0 mos)	\N	Permanent	\N	In bond	\N	\N	NA	NA	BE (2020)	[]	[]	[]	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-16 14:55:33.329721+05:30	2026-11-18 10:02:17.792303+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N	\N	\N	\N	\N	Atharv Malhotra	e273e2ed-5fd3-4564-bb87-09a71cd4779a	Yes	24	2028-10-16	BE	2020	NA	NA	Experienced	2 yrs 0 mos	2 yrs 0 mos	Sibling	\N	Service - Testing - AppSec	\N	\N	\N	\N	\N	\N	\N	\N	682d36c0-4256-42ab-811e-054ab3a5b10f	Testing-Team Leader
\.


--
-- Data for Name: tbl_exited_employees; Type: TABLE DATA; Schema: resource; Owner: -
--

COPY resource.tbl_exited_employees ("Id", "OriginalEmployeeId", "EmployeeCode", "FullName", "DepartmentName", "DesignationName", "WorkEmail", "PersonalEmail", "Phone", "StatusAtExit", "ExitType", "ExitReason", "ResignationDate", "LastWorkingDay", "ReasonForLeaving", "NoticePeriodServed", "ExitChecklistJson", "AssetReturnJson", "FinalSettlementJson", "ExitedAtUtc", "ExitedBy", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "ClearanceCompleted", "ExitRating") FROM stdin;
8912cce4-7930-4e36-b37d-73cd3b67cf09	940ec7cd-058d-4f8f-912f-08ae55bac01c	TK-0097	Manish Mathur	Services - Testing	Senior Pentester - I	manish.mathur.tk-0097@talakunchi.com	\N	9820010106	Terminated	Resign	Better opportunity	2026-09-16	2026-10-02	Career growth — UAT sample exit	Yes	\N	\N	\N	2026-10-16 15:24:37.283402+05:30	\N	2026-10-16 15:24:37.284411+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	\N
592d8ea7-675f-46b6-ad6b-73c500810c95	87fd3345-a756-44df-a3e7-5f21fa6e50d3	TK-0098	Aisha Mathur	Services - Testing	Senior Pentester - I	aisha.mathur.tk-0098@talakunchi.com	\N	9820010107	Terminated	Resign	Better opportunity	2026-09-16	2026-10-02	Career growth — UAT sample exit	Yes	\N	\N	\N	2026-10-16 15:24:37.30937+05:30	\N	2026-10-16 15:24:37.309719+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	\N
1ec9d02c-2e3c-4088-8fe5-48f03852e262	23bf310d-b789-4dcc-bb7e-576b373e72cf	TK-0099	Karan Mehta	Services - Testing	Senior Pentester - II	karan.mehta.tk-0099@talakunchi.com	\N	9820010108	Terminated	Resign	Better opportunity	2026-09-16	2026-10-02	Career growth — UAT sample exit	Yes	\N	\N	\N	2026-10-16 15:24:37.319553+05:30	\N	2026-10-16 15:24:37.319639+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	\N
4bb21e7f-6233-401e-8295-82ad20f7f2fc	089e3bae-d509-46db-906f-3085e0438c9c	TK-0100	Ira Reddy	Services - Testing	Senior Pentester - II	ira.reddy.tk-0100@talakunchi.com	\N	9820010109	Terminated	Resign	Better opportunity	2026-09-16	2026-10-02	Career growth — UAT sample exit	Yes	\N	\N	\N	2026-10-16 15:24:37.329587+05:30	\N	2026-10-16 15:24:37.329732+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	\N
fc4934f9-b212-404a-8e6e-0864d7a32648	b20f343b-e7fa-4310-9c43-ef10ca51ff6c	TK-0101	Neha Choudhary	Services - Testing	Senior Pentester - II	neha.choudhary.tk-0101@talakunchi.com	\N	9820010110	Terminated	Resign	Better opportunity	2026-09-16	2026-10-02	Career growth — UAT sample exit	Yes	\N	\N	\N	2026-10-16 15:24:37.338883+05:30	\N	2026-10-16 15:24:37.338979+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	\N
b39b88c5-c1ca-4882-9a3d-5bd8b6c6729c	d94878fd-4650-46bc-b84c-753c841e7404	TK-0008	Nikhil Saxena	Services - Operations	SOC Lead - II	nikhil.saxena.tk-0008@talakunchi.com	\N	9820010009	Resigned	Resigned	BO	2026-10-27	2026-12-26	BO	60 days	\N	\N	\N	2026-10-27 15:55:56.401103+05:30	\N	2026-10-27 15:55:56.40164+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	f	\N
d8d01602-ae91-4204-a3d3-c7f29b1d786e	13428d48-c81e-4720-adba-f8490f27e535	TK-0009	Vihaan Saxena	Functional - Accounts	Senior Accountant - II	vihaan.saxena.tk-0009@talakunchi.com	\N	9820010010	Resigned	Resigned	Personal	2026-10-28	2026-10-29	Personal	1 days	\N	\N	\N	2026-10-28 10:13:42.416605+05:30	\N	2026-10-28 10:13:42.416939+05:30	2026-10-30 10:38:24.621416+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	00000000-0000-4000-8000-000000000004	\N	t	\N
c20c8e05-fb90-4d01-8e12-e22e582baae7	f39b20bb-8963-4917-aed5-0f1d86f0cbc3	TK-0007	Aarav Roy	Functional - Accounts	Accountant - III	aarav.roy.tk-0007@talakunchi.com	\N	9820010007	Resigned	Resigned	BO	2026-10-28	2026-11-07	BO	10 days	\N	\N	\N	2026-10-28 10:41:09.961867+05:30	\N	2026-10-28 10:41:09.966696+05:30	2026-11-10 03:48:02.522381+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	t	\N
349cce80-bb8b-4655-a5af-b5ab2e8602f1	ca209d5b-e1e0-42bf-9dbe-47cf5ed5530c	TK-0092	Harsh Joshi	Services - Testing	Red Team Practitioner - II	harsh.joshi.tk-0092@talakunchi.com	\N	9820010101	Resignation Under Review	Resign	Personal reasons	2026-10-16	2026-11-15	Serving notice — UAT sample	In progress	\N	\N	\N	2026-10-16 15:24:37.348639+05:30	\N	2026-10-16 15:24:37.34871+05:30	2026-11-16 00:05:25.670882+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	00000000-0000-4000-8000-000000000004	\N	t	\N
4a23d7a5-bb64-4e6b-888a-7aa10a1b1c39	3398777f-d384-48a2-8076-9c4fb06162bb	TK-0095	Karan Joshi	Services - Testing	Senior Cloud Security Consultant - I	karan.joshi.tk-0095@talakunchi.com	\N	9820010104	Resignation Under Review	Resign	Personal reasons	2026-10-16	2026-11-15	Serving notice — UAT sample	In progress	\N	\N	\N	2026-10-16 15:24:37.381068+05:30	\N	2026-10-16 15:24:37.381116+05:30	2026-11-16 00:05:25.670882+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	00000000-0000-4000-8000-000000000004	\N	t	\N
7e852d2b-b3b0-4242-b618-d00b39cc9928	cef36bf2-c4fb-4040-b3ab-d033190ad3b4	TK-0096	Vikram Joshi	Services - Testing	Senior Pentester - I	vikram.joshi.tk-0096@talakunchi.com	\N	9820010105	Resignation Under Review	Resign	Personal reasons	2026-10-16	2026-11-15	Serving notice — UAT sample	In progress	\N	\N	\N	2026-10-16 15:24:37.389577+05:30	\N	2026-10-16 15:24:37.389691+05:30	2026-11-16 00:05:25.670882+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	00000000-0000-4000-8000-000000000004	\N	t	\N
b5c2dbaa-9148-4d57-adce-d4f56e47e696	d6ea9f00-bf1b-4aa0-815f-89fe43b1c249	TK-0093	Aarav Patel	Services - Testing	Red Team Practitioner - III	aarav.patel.tk-0093@talakunchi.com	\N	9820010102	Resignation Under Review	Resign	Personal reasons	2026-10-16	2026-11-15	Serving notice — UAT sample	In progress	\N	\N	\N	2026-10-16 15:24:37.363037+05:30	\N	2026-10-16 15:24:37.363101+05:30	2026-11-16 00:05:25.670882+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	00000000-0000-4000-8000-000000000004	\N	t	\N
f990999e-7294-4ae5-b0f9-e55b2b2be4ee	f30d1ce8-8a1a-483d-ace2-419cd8672ecc	TK-0094	Manish Bose	Services - Testing	Red Team Specialist - II	manish.bose.tk-0094@talakunchi.com	\N	9820010103	Resignation Under Review	Resign	Personal reasons	2026-10-16	2026-11-15	Serving notice — UAT sample	In progress	\N	\N	\N	2026-10-16 15:24:37.372123+05:30	\N	2026-10-16 15:24:37.37219+05:30	2026-11-16 00:05:25.670882+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	00000000-0000-4000-8000-000000000004	\N	t	\N
5f93542c-372f-4dff-8645-dc29ad2543bb	ed84bba3-9466-4bd1-a18e-40d8b984fbb8	TK-2098	John Doe	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-15	2026-11-30	\N	\N	\N	\N	\N	2026-11-16 12:41:49.350062+05:30	\N	2026-11-16 12:41:49.35054+05:30	2026-11-16 12:41:49.350541+05:30	\N	\N	\N	f	\N
5bb39238-a741-457c-be62-7cac000d0286	9b5fec51-8d70-4860-a6a1-a08b147fe96e	TK-9431	Past Resource	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 12:41:50.172764+05:30	\N	2026-11-16 12:41:50.17277+05:30	2026-11-16 12:41:50.172771+05:30	\N	\N	\N	f	\N
28807b11-1971-4b13-b0a4-b10c475ed0b9	db14bb47-31b3-4f7f-8908-8b825e1e469a	TK-5464	Donna Paulsen	\N	\N	\N	\N	\N	Exited	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 12:41:53.217935+05:30	\N	2026-11-16 12:41:53.217951+05:30	2026-11-16 12:41:53.217952+05:30	\N	\N	\N	f	\N
89c57818-8dc3-4c1d-917d-9efae8504259	82a47e9d-40f9-45ec-b908-e20bc2d31fac	TK-8404	Vikram Rao	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-26	\N	\N	\N	\N	\N	2026-11-16 12:41:53.912888+05:30	\N	2026-11-16 12:41:53.912892+05:30	2026-11-16 12:41:53.917409+05:30	\N	\N	\N	f	\N
1fd16f54-6a4f-4442-8c93-38a35a7b9c3a	32d62c84-056a-46a1-9666-e5ed3233aea4	TK-9734	Multi Resource	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-15	2026-11-30	\N	\N	\N	\N	\N	2026-11-16 12:41:54.74615+05:30	\N	2026-11-16 12:41:54.746153+05:30	2026-11-16 12:41:54.746153+05:30	\N	\N	\N	f	\N
c3ffabe8-6e11-45e7-8707-a6a1999d262a	43dfb3c3-4a99-4e10-b229-93db2d647769	TK-6599	Active Retained	\N	\N	\N	\N	\N	Cancelled	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 12:41:55.328305+05:30	\N	2026-11-16 12:41:55.328308+05:30	2026-11-16 12:41:55.328308+05:30	\N	\N	\N	f	\N
c1740ee9-bec0-4e62-83fe-43eae86ec2b4	67032a4e-3e93-4305-b2ac-5f8bc0d3c67b	TK-7019	Elena Rostova	Core	\N	\N	\N	\N	Exited	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 12:41:56.101281+05:30	\N	2026-11-16 12:41:56.101434+05:30	2026-11-16 12:41:56.101434+05:30	\N	\N	\N	f	\N
fc21803a-7513-4ad6-ac12-649c00b070a3	8a4b7f3d-19b3-46e2-9690-c10bc820df5c	TK-3987	Idem Resource	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 12:41:57.217896+05:30	\N	2026-11-16 12:41:57.217901+05:30	2026-11-16 12:41:57.217901+05:30	\N	\N	\N	f	\N
ac7179b1-a3db-4a1a-9a7a-c974444168b0	40d24938-e6ba-4f7e-bf28-8aa13f6bf057	TK-6110	Api Offboardee	\N	\N	api.offboardee.51cb6e0d9bde4969b37790536c8f360f@talakunchi.com	\N	\N	Notice Period	Voluntary	Career Growth	2026-11-15	2026-11-30	Better Opportunity	Yes	\N	\N	\N	2026-11-16 12:41:58.253637+05:30	\N	2026-11-16 12:41:58.252527+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	4.5
dac9ca30-5325-4cd0-87d8-063d9f8cd74c	f8d37850-2216-4443-958b-189fdfbeccab	TK-6281	Karan Patel	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 12:41:58.889876+05:30	\N	2026-11-16 12:41:58.889881+05:30	2026-11-16 12:41:58.889881+05:30	\N	\N	\N	f	\N
d0240c05-46e4-4ec0-99d4-33618bfd1517	43efbf8c-fb10-4459-8f6d-cea3748f2940	TK-5321	Integration Resource	\N	\N	integration.resource.8bc996b16a88440fb85ad2225fd6541d@acme.co	\N	\N	Resigned	Resign	Integration test	2026-11-16	2026-12-16	Integration test	30 days	{}	{}	{}	2026-11-16 12:42:17.068508+05:30	\N	2026-11-16 12:42:17.068494+05:30	\N	25317e08-0a3c-6b31-1cd8-194a22313e21	\N	\N	f	\N
d533787c-41a4-477a-9ed1-734a9981cf2d	cc5ed270-1ebe-4030-8346-41d5f8b14dfc	TK-5724	Integration Resource	\N	\N	integration.resource.6fb2da86dec4441b9888423fca9e80f2@acme.co	\N	\N	Resigned	Resign	Notice already ended	2026-11-06	2026-11-15	Notice already ended	30 days	{}	{}	{}	2026-11-16 12:42:17.187332+05:30	\N	2026-11-16 12:42:17.187302+05:30	\N	25317e08-0a3c-6b31-1cd8-194a22313e21	\N	\N	t	\N
0800ab97-0dcc-46cf-904f-47f8dd0b826f	95fcbc2a-8772-44b6-b7e8-7e875801d112	TK-9637	John Doe	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-15	2026-11-30	\N	\N	\N	\N	\N	2026-11-16 17:35:56.28777+05:30	\N	2026-11-16 17:35:56.288385+05:30	2026-11-16 17:35:56.288385+05:30	\N	\N	\N	f	\N
fba7e2fe-3df8-4dfe-9001-a1539fe489f0	8c2edbc3-9997-4393-ad3a-b03fc1f04b5a	TK-6332	Past Resource	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 17:35:59.394957+05:30	\N	2026-11-16 17:35:59.394963+05:30	2026-11-16 17:35:59.394964+05:30	\N	\N	\N	f	\N
750f2ef4-756a-4dfb-bf7f-be7fdfae9892	193b143f-95b1-4642-be6c-086d81b853bb	TK-6905	Donna Paulsen	\N	\N	\N	\N	\N	Exited	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 17:36:02.140862+05:30	\N	2026-11-16 17:36:02.140865+05:30	2026-11-16 17:36:02.140865+05:30	\N	\N	\N	f	\N
a0fb5ff7-d2de-4da0-8768-f748f47c2961	553b356c-9643-4249-9914-ee0923cb62ac	TK-8593	Vikram Rao	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-26	\N	\N	\N	\N	\N	2026-11-16 17:36:04.015556+05:30	\N	2026-11-16 17:36:04.01556+05:30	2026-11-16 17:36:04.039367+05:30	\N	\N	\N	f	\N
4f8c4051-1936-4ebd-b207-3d570f7743db	1e2bc27b-1df2-42b0-9d40-16647d9c3ae2	TK-6403	Multi Resource	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-15	2026-11-30	\N	\N	\N	\N	\N	2026-11-16 17:36:06.458083+05:30	\N	2026-11-16 17:36:06.458091+05:30	2026-11-16 17:36:06.458091+05:30	\N	\N	\N	f	\N
abc69bba-d6d8-4985-8c94-3ba1e0fb8f6e	1c061393-64a9-4582-80e8-1e9d7eea9e62	TK-6225	Active Retained	\N	\N	\N	\N	\N	Cancelled	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 17:36:15.295082+05:30	\N	2026-11-16 17:36:15.295087+05:30	2026-11-16 17:36:15.295088+05:30	\N	\N	\N	f	\N
a587f3ef-da8f-4b96-8cad-dbd2adfdff12	2a2c5197-58d2-407f-bd2e-da05d8bee642	TK-8584	Elena Rostova	Core	\N	\N	\N	\N	Exited	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 17:36:16.611923+05:30	\N	2026-11-16 17:36:16.612219+05:30	2026-11-16 17:36:16.612219+05:30	\N	\N	\N	f	\N
6d455a71-6874-4241-b732-5e783154e4b8	8635fe99-aaf4-406a-bdf1-bb0f947c0df0	TK-7069	Idem Resource	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 17:36:24.136872+05:30	\N	2026-11-16 17:36:24.136879+05:30	2026-11-16 17:36:24.13688+05:30	\N	\N	\N	f	\N
f275c60e-5f5d-4418-9bb0-a938c29654aa	18aa2b5f-e966-41e1-862c-f41eccd0e22c	TK-4721	Api Offboardee	\N	\N	api.offboardee.7b5f2bf928fd4475a01a7716ac91bd93@talakunchi.com	\N	\N	Notice Period	Voluntary	Career Growth	2026-11-15	2026-11-30	Better Opportunity	Yes	\N	\N	\N	2026-11-16 17:36:27.231248+05:30	\N	2026-11-16 17:36:27.230328+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	4.5
00f72472-5d7f-4b17-a631-aaaad846bb67	55e2c129-6fea-44f9-a725-bad78fb59072	TK-2315	Karan Patel	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 17:36:29.278168+05:30	\N	2026-11-16 17:36:29.278173+05:30	2026-11-16 17:36:29.278173+05:30	\N	\N	\N	f	\N
29adf623-47e5-4afd-b4d3-eb473b23ad4d	9ddbc371-755f-4a60-9a22-e4ef8f779dd6	TK-5469	Integration Resource	\N	\N	integration.resource.cb3b9dc2f0e7426984758157bb275845@acme.co	\N	\N	Resigned	Resign	Integration test	2026-11-16	2026-12-16	Integration test	30 days	{}	{}	{}	2026-11-16 17:36:44.750336+05:30	\N	2026-11-16 17:36:44.750321+05:30	\N	25317e08-0a3c-6b31-1cd8-194a22313e21	\N	\N	f	\N
a7931d07-f2f8-45c7-a94e-c976667346cd	855151a6-e1f9-4c98-881b-4a33eea4e49d	TK-5295	Integration Resource	\N	\N	integration.resource.184898c08cdc4ad88bb176657522863b@acme.co	\N	\N	Resigned	Resign	Notice already ended	2026-11-06	2026-11-15	Notice already ended	30 days	{}	{}	{}	2026-11-16 17:36:44.951134+05:30	\N	2026-11-16 17:36:44.951104+05:30	\N	25317e08-0a3c-6b31-1cd8-194a22313e21	\N	\N	t	\N
f641c9f6-4aa3-439a-bb2b-d3f0f3980c1d	949b48b1-0510-41d3-ae3e-9231ba05b460	TK-9879	John Doe	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-15	2026-11-30	\N	\N	\N	\N	\N	2026-11-16 19:00:32.009709+05:30	\N	2026-11-16 19:00:32.010854+05:30	2026-11-16 19:00:32.010854+05:30	\N	\N	\N	f	\N
f587114a-65ad-44b7-a7b3-59c4e2abf4fb	22b8806b-fa50-46fa-98d1-8cc823211cb2	TK-1363	Past Resource	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 19:00:44.228822+05:30	\N	2026-11-16 19:00:44.228825+05:30	2026-11-16 19:00:44.228825+05:30	\N	\N	\N	f	\N
5f8f54c5-3fe1-4473-b237-4f60bae0978b	8ed4a510-1ac9-43e2-838a-2ff20dea2cfb	TK-7235	Donna Paulsen	\N	\N	\N	\N	\N	Exited	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 19:00:51.912064+05:30	\N	2026-11-16 19:00:51.912077+05:30	2026-11-16 19:00:51.912077+05:30	\N	\N	\N	f	\N
0b5d541f-0e66-471d-8523-1af1632f74a4	abe409c1-b6ea-40f8-ad43-6e57de581d2d	TK-5777	Vikram Rao	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-26	\N	\N	\N	\N	\N	2026-11-16 19:00:52.690468+05:30	\N	2026-11-16 19:00:52.690471+05:30	2026-11-16 19:00:52.69359+05:30	\N	\N	\N	f	\N
6828b628-e528-4720-b17a-bdb51b2d4b3b	275d90f2-4da5-459f-bfbd-c38188a2c92e	TK-2746	Multi Resource	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-15	2026-11-30	\N	\N	\N	\N	\N	2026-11-16 19:00:56.471013+05:30	\N	2026-11-16 19:00:56.471019+05:30	2026-11-16 19:00:56.471019+05:30	\N	\N	\N	f	\N
53f11feb-9c4a-452f-bafb-fa57cedac583	4c0b7fe3-9c93-4f22-b8a0-8cc82671905c	TK-4731	Active Retained	\N	\N	\N	\N	\N	Cancelled	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 19:00:57.467877+05:30	\N	2026-11-16 19:00:57.467884+05:30	2026-11-16 19:00:57.467884+05:30	\N	\N	\N	f	\N
c7e67f7b-7b94-4228-bad4-38f2d4af04ce	91553271-7b63-4cb6-abe2-ecb4a6c787f4	TK-6256	Idem Resource	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 19:00:59.34451+05:30	\N	2026-11-16 19:00:59.344515+05:30	2026-11-16 19:00:59.344515+05:30	\N	\N	\N	f	\N
2a51b709-14a2-49e4-aea6-6506cd9c5b5c	79d37e6e-bd75-4cf1-bb93-f052a2ac0001	TK-3534	Api Offboardee	\N	\N	api.offboardee.03465cf9bd7e4724a18b3cb5af8293ed@talakunchi.com	\N	\N	Notice Period	Voluntary	Career Growth	2026-11-15	2026-11-30	Better Opportunity	Yes	\N	\N	\N	2026-11-16 19:01:01.606361+05:30	\N	2026-11-16 19:01:01.60531+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N	t	4.5
98fd765f-2ccb-42d8-847c-9a4a4b641f1c	af2fc927-2b00-4f95-9818-854cf3efb1c1	TK-3571	Karan Patel	\N	\N	\N	\N	\N	Notice Period	\N	\N	2026-11-10	2026-11-20	\N	\N	\N	\N	\N	2026-11-16 19:01:02.616382+05:30	\N	2026-11-16 19:01:02.616389+05:30	2026-11-16 19:01:02.616389+05:30	\N	\N	\N	f	\N
f6d1c4a9-8eae-4466-ba1c-961a5950f99f	99e0daa0-94ef-41c4-97d5-fcdcda81607e	TK-7425	Integration Resource	\N	\N	integration.resource.c561800b74354520a394abe808134273@acme.co	\N	\N	Resigned	Resign	Integration test	2026-11-16	2026-12-16	Integration test	30 days	{}	{}	{}	2026-11-16 19:01:05.203826+05:30	\N	2026-11-16 19:01:05.203809+05:30	\N	25317e08-0a3c-6b31-1cd8-194a22313e21	\N	\N	f	\N
\.


--
-- Data for Name: tbl_onfloorrole; Type: TABLE DATA; Schema: resource; Owner: -
--

COPY resource.tbl_onfloorrole ("Id", "Name", "DepartmentId", "DesignationId", "SubDepartment", "RbacRoleId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
01a26d31-4fcd-4ad3-b08e-1276a4620cb8	Team Leader	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	444df30d-c195-42ad-b9a7-d80cdef69ccd	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
03d492f0-4458-48e5-9ee8-06f09f660218	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	48429bb5-c583-4684-b30a-7ed443b671ca	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
0837f524-0260-4283-a37f-6e1fb06d3dcd	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	0a60fb48-99c4-44d0-8d97-ff687ccffc9f	Services - Testing - Red Team	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
0acaaceb-a951-4492-bdba-69d5e916f8b4	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	85cc9fbe-98a4-464d-a638-05f40529c6de	Services - Testing - Red Team	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
0c18f8ce-b9be-4ec0-a099-44b0fd29bdcd	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	0b6ab354-1fcf-4a00-9be3-e58e99c425ed	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
1abc8fed-e830-4103-a5ab-c3402b166116	Team Member	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	c0e1a001-0000-4000-8000-000000000001	Across all Sub Departments	f29af015-7833-4f9a-ac57-6fbef5bf91ec	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
21c47c58-0be4-41bb-8407-8df5fa4b8e9d	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	af8a1442-c5ee-409d-aa91-61c9dba852ee	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
23f52e10-894f-4e50-970b-202a3127a1d9	Team Member	8e4e88f1-e294-4554-80cc-92ed6169caeb	834c9e15-c70d-4a0b-bb12-5e55f23c181d	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
27d8ec30-01ad-45f2-a7d8-7a54c2d2c754	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	911f6d7f-8d43-40f2-897a-2f416abf8cf9	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
29119117-9aa3-4def-9db8-802f70f74e4b	Team Leader	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	c0f974c3-f49c-449a-9276-aa64ce501344	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
2d4e6116-3ec3-4c5d-9d75-35517814a964	Team Leader	be8e036d-ad13-4c79-89ec-294e490a6816	dcabe0b2-ab10-4c1a-abf7-873e8b5486ca	Services - Consulting	701aaa2c-a899-4def-bf5f-e17511874409	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
3091c873-f1f0-4632-ac1e-62d1a451c39d	Manager	13c91c98-00ae-4211-acb8-d06e35953806	157d001c-b056-45b1-96a3-3c05bcd8d99c	Functional - Sales	914d8500-03b6-4a43-a250-244effca1cf1	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
3101ee42-6788-4ae4-a80b-f7394720b740	Team Member	13c91c98-00ae-4211-acb8-d06e35953806	e2c675a7-92dc-4477-be75-9a304cbe4def	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
36339f27-5abf-4ffc-bca3-5a2333a94df2	Manager	0aed67b8-c454-439a-a07f-4f46d46d58af	3b7ea453-324e-40a0-bb41-77a0795d5af5	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
39c52128-53f4-4e39-8102-4b9ccc9f5584	Team Leader	0aed67b8-c454-439a-a07f-4f46d46d58af	168d11d7-ca26-4d61-b870-51779dc63023	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
475cc74e-698a-4547-966a-823be44cfd15	Team Member	898c36e9-1cb7-4c56-9148-a3b6893c0149	3356f353-1566-4df6-9958-fa01d67d13c7	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
4766e158-b2c1-44dd-a36d-18583c490193	Team Member	8e4e88f1-e294-4554-80cc-92ed6169caeb	2a76927c-461a-48e4-8190-dea7361ef3db	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
4cc83d93-7b2f-4c97-a4a7-e9ec47735e4b	Team Member	be8e036d-ad13-4c79-89ec-294e490a6816	8a655ba7-f9db-4de7-8de9-9fec72a2ed1d	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
4d8c99f7-b5c4-434a-ae7c-64419a5a1bcf	HR	310a2f16-15f6-4b82-95f6-ab18b5b429f5	e4e20503-cd55-4393-83fd-6c7e7d7d0a49	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
54123afd-2783-4a41-b18f-328d024e8a22	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	4ef1cb5b-9688-4ce2-95b3-6a0863200166	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
56779122-3301-4a2c-bc35-085f96ee714b	HR	310a2f16-15f6-4b82-95f6-ab18b5b429f5	7d542941-65b9-499b-81b3-239748d6da52	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
56ed9417-a9fd-40ff-a517-1e75bbf02d63	Sr. Manager	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	eb1f4dba-0d12-42c1-9e97-317c2ae55f6f	Services - Operations	b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
580f3fc7-ff2d-4881-a222-d91a7c00f491	HR	310a2f16-15f6-4b82-95f6-ab18b5b429f5	485012d4-2c28-4bc4-92c7-3609e3e3749e	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
5814389a-4416-4e4d-96a7-58f4801e2757	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	163d8c87-8f90-4295-a926-2e912c625a1c	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
5c9266d9-5a57-4b6c-aabc-18edce40ae96	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	f20a7445-0b01-4f20-85a5-853101d864ee	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
67084a5d-02d0-4a73-a15f-45aca43adb58	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	35a6b1af-dc78-4632-a9f4-eedabdbdcb52	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
67306ff5-e313-43da-99bc-56b6a6ca65ee	Team Member	13c91c98-00ae-4211-acb8-d06e35953806	272973a6-c052-4aef-bf32-9e24f7eb6cc9	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
67bdeca7-fe42-4b4e-b5b6-9e8e8d410413	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	4650d4e0-f73c-4688-ae5f-830a46348ff9	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
6890c399-940e-4c2a-9aba-0dd90a50e063	Head Of Department	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea804d3a-dbe3-4fb2-b120-7f0ab18d2d19	Services - Operations	3d068c2f-d0a1-4045-bad9-0f3a43efec4f	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
6eaffc67-3d6e-4bb6-9c90-0a604398090d	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	4f972924-350a-47fb-a6b6-f2b34bb6b621	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
70480603-7eae-41f7-b659-052b7500ca91	Team Member	13c91c98-00ae-4211-acb8-d06e35953806	6193be76-40ad-4973-9ee7-246a4d8f4109	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
734614d6-908f-4f24-8331-c515a6d70149	Team Member	be8e036d-ad13-4c79-89ec-294e490a6816	1e7faab8-273d-40df-9f9a-485160186c5a	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
746752f8-decb-46a0-a7e1-d07a0a68dbc3	Team Member	8e4e88f1-e294-4554-80cc-92ed6169caeb	b3309eea-7374-4a8d-ac13-481b2a7fd492	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
7d2b7826-2f63-4796-9032-5ffa35cd5b37	Manager	be8e036d-ad13-4c79-89ec-294e490a6816	195d6a81-8457-4b60-9382-6a3a0664f0e9	Services - Consulting	e5d6f6ff-be59-4cc4-a8c6-65191d550d0a	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
7fe8d8b6-c0fc-4015-a3ff-5bb8e95ea0d5	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	ae255622-ddcc-45ea-a699-8ec416fe57ab	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
8211f0b1-d111-400b-94ab-fd663d50ec65	Team Member	898c36e9-1cb7-4c56-9148-a3b6893c0149	f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
87ea604f-b245-49c0-9172-3956f1d6eb75	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	632bf06c-f646-4edd-bf2d-e3cd2e034c7f	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
885809b5-843a-4ec9-bafe-da1472b73a03	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0c1a5ef4-7fca-45dc-8253-87afa21a1df9	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
9326acb0-20c1-4d05-89b6-d85ee3425469	Project Manager	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	b5f39dd8-c305-489d-9f7d-9adfd010a134	Services - Operations	111cc3cd-6d35-43ce-be91-dde90d3d4015	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
9635b694-a552-42c0-9df3-a6090c9b1923	Leader	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	0525d830-ead9-44a0-871f-91b7845fec26	Leading Compliance & HR Department	66e48815-4d4f-41d0-9c5f-26a7b7ba296c	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
99039771-cd5a-4878-a7b9-9cdaa02f5be6	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	96efad7d-8b7f-4d7f-a862-c0a6bec3789f	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
9ac666ca-eaa2-46a5-b489-66a8cc550b65	Team Member	be8e036d-ad13-4c79-89ec-294e490a6816	7c2380da-3ee6-46ad-93d6-a79ce3027f29	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
9ad0a166-cde2-4817-9acd-363d217422d9	Team Leader	0aed67b8-c454-439a-a07f-4f46d46d58af	e228c999-bf54-48b4-a373-d2bc9db88554	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
9ed3ce2c-add0-4472-9da8-4cd5c0552867	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	1f97b442-95c5-4b11-93a0-ea146534ae85	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
a1826c58-197f-4c7e-9909-a8970491fe38	Team Leader	be8e036d-ad13-4c79-89ec-294e490a6816	3e60b693-d3dd-4481-95c4-9f02da21625c	Services - Consulting	701aaa2c-a899-4def-bf5f-e17511874409	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
a885d8fe-9ecc-4c4e-9b23-55c015ffd3e6	Sr. Manager	0aed67b8-c454-439a-a07f-4f46d46d58af	a697a798-caaf-4248-8e4e-7e89096a9c30	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	efc1df20-ca04-44a6-87b2-7cae1ff50a88	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
acbe4f0d-8058-4a88-9255-08104f0037b6	Team Member	8e4e88f1-e294-4554-80cc-92ed6169caeb	d8a2b9e5-f54d-4344-a78d-c6c840467543	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
acf26b08-e6ae-4343-9bf9-529b070835a3	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	ea315f7d-d597-41b3-a999-4f3851bcd020	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
ae6e9e5b-7337-47a3-8fe5-bb02a9a7f374	Manager	8e4e88f1-e294-4554-80cc-92ed6169caeb	138434a2-625f-4df5-836d-fcf0cfceef79	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
b24b3d9d-7454-4657-bb24-3c4f0f40956e	Team Member	898c36e9-1cb7-4c56-9148-a3b6893c0149	9ba2a2f7-e946-4e55-ad1c-135c6fd77e85	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
b4b2673b-fc1c-4484-8f2d-903a39dff2a9	Manager	13c91c98-00ae-4211-acb8-d06e35953806	b2b687ef-fd62-4cb7-a826-b40a35da7b2c	Functional - Sales	914d8500-03b6-4a43-a250-244effca1cf1	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
b5974e61-080c-4de2-a977-7f0bdee29949	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	6d25ff6d-e13d-440f-b775-215547af7acb	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
b9232654-c160-4e84-bdc3-ad94a605dbe1	IT Admin	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	73bd55bb-5d0e-4381-8ad2-2238377fca93	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
b9f75ed9-10c6-4b61-ad05-b27ec89a8b3b	IT Admin	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	c70b9832-841e-4864-9b85-eaba3c0a995f	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
bb6f610b-b2f5-4b01-9ea4-fb9ad074b768	Team Leader	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	e36018c5-bf48-4f93-bef7-93e8864a0b51	Services - Operations	aba61e5b-422a-4461-b9da-8dba8f6d3f85	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
c4d57da3-eff2-4cd1-834f-e0d77b39f299	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
c4ef6b03-baa6-47ac-8d06-c8819ddbdaa7	HR	310a2f16-15f6-4b82-95f6-ab18b5b429f5	c2e248c8-e917-445f-9f7b-1e25d7bb5abe	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
c5ea1ba3-9974-4cca-9320-362527502c6e	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	155642eb-a633-4460-b658-aca9fde2d817	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
c637e1a2-5677-45fa-bbbf-f88fc60a9443	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	767a00dd-6f09-4f64-a44e-8fbe901222af	Services - Testing - DevSecOps	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
ccf1432a-d667-4fff-8071-efbc9f841976	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	8dc0d8fe-593d-422a-8b27-5b68fbe6d224	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
d412d761-e42e-4ab2-8e58-1df17b290365	Accounts	bcbd68c8-c3f3-4396-abb0-0b0e13637958	6e606c29-2ebf-4ab8-8006-aaedd5680009	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
d6002117-fdbb-437a-986f-dde6b5b5c162	Manager	0aed67b8-c454-439a-a07f-4f46d46d58af	8af28894-fd3e-4dea-a4f0-bcb62b0e4e13	Services - Testing - Cloud & AI	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
d862a290-2a0a-47f2-9c23-2baf830a37b9	Team Leader	8e4e88f1-e294-4554-80cc-92ed6169caeb	c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c	PMO (Project Management Office)	2acf8b94-0756-4db8-bb6f-8372ac04a2d1	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
d8d41d59-fe4b-4c54-80d3-751a7bbf714c	IT Admin	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	da990f6e-3379-4cc4-89b7-0ead29da472b	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
da608430-bf9a-4a87-9881-1c07e7f2974a	Head Of Department	be8e036d-ad13-4c79-89ec-294e490a6816	2b1558e3-158a-4a84-ae80-053129861a64	Services - Consulting	64c49f37-a38a-46a6-9622-7427f1501658	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
dfa4b2c2-7d48-4ff7-b5aa-9b65fbde04e1	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	9858c224-f97f-4ff8-908d-f46bd5e2243c	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
e061fae9-2430-4025-ad39-ff79717301a5	Team Leader	0aed67b8-c454-439a-a07f-4f46d46d58af	aaf4ca75-5fa5-4de2-8353-a5e93beecb56	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
e1f2260d-b878-4693-86db-2513390804aa	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
e3c262a4-4108-4592-abb0-643085d6a305	Manager	0aed67b8-c454-439a-a07f-4f46d46d58af	c1fa4328-a970-48a1-bc08-d50fe36bf44c	Services - Testing - DevSecOps	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
e3ede776-6573-4898-9195-fb2a398100b2	Team Member	13c91c98-00ae-4211-acb8-d06e35953806	7e7d954f-34b5-4c23-8c3f-698ec920e9e4	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
e60fe13f-6f3e-4410-80c9-dcfbb88f0301	Leader	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	778f1120-9633-4933-9160-ddaa46668838	Leading Sales & A/C Department	62a927b7-9fd8-461a-b64e-1aa441eeba4d	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
eb9edaa3-2522-4d91-ab86-d786a7250f91	Manager	0aed67b8-c454-439a-a07f-4f46d46d58af	4b680e29-b4fb-4689-9afb-67a7f089f52b	Services - Testing - Red Team	29ad5710-1621-4c24-ac75-dedfc168ba1a	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
ecc39c47-956d-49b9-8fbc-44a6433f3912	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	e2b4be77-2b20-4064-974d-e6322e7240b4	Services - Testing - Cloud & AI	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
f39ba18d-6be5-4d23-a99f-f8d7a68c43dc	HR	310a2f16-15f6-4b82-95f6-ab18b5b429f5	8fdfba5d-e947-47b6-aa25-23d9a6dc49ed	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
f4e2358e-5ec0-4292-8377-438dabb72fbe	Team Leader	8e4e88f1-e294-4554-80cc-92ed6169caeb	8b57cfd5-5d4e-44a3-9646-b36873c111c2	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
f51841ca-ffbc-4619-98be-201d736e4f48	Team Member	be8e036d-ad13-4c79-89ec-294e490a6816	2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
f6560080-4b30-4b4b-b8ba-90d5b0ead2da	Team Leader	0aed67b8-c454-439a-a07f-4f46d46d58af	c6c6cd04-6df3-4593-b686-e4b9d362c96f	Services - Testing - DevSecOps	a3793f87-7f3c-41a1-a675-236fc1b710ab	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
f7a34722-94ab-4e14-ad50-5e5f0b44cca6	Manager	8e4e88f1-e294-4554-80cc-92ed6169caeb	9dc69952-eae6-4ec0-a327-67392315f089	EM (Engagement Manager)	a5023c9e-367f-41e1-ba02-bdb2929edc89	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
fec21974-29e7-4dcf-8438-efb813045170	Leader	6a6bb234-1e03-41e8-a4e7-b0e77c8e442e	ffed7aa1-e88f-4281-919f-8d49fbabf5a5	Leading Delivery Department	a5bfe265-981a-4723-b7bb-6ddc389db7f0	2026-10-20 21:42:25.847811+05:30	\N	\N	\N	\N
22a8384f-6070-4554-89f1-ee327ae48f16	Team Member	be8e036d-ad13-4c79-89ec-294e490a6816	2076a9b1-e432-46a9-99b1-36e732159856	Services - Consulting	768a11f9-ded7-4f6f-ba86-073e279255d9	2026-10-20 21:42:25.847811+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N
3d74762f-cfbc-4cb9-b172-c2aaffc64f30	Team Member	13c91c98-00ae-4211-acb8-d06e35953806	e2b10def-c91d-45da-94c5-f5530e743aa2	Functional - Sales	7cc8753c-f3b0-4fc9-b63b-efd00e2c5325	2026-10-20 21:42:25.847811+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N
59cf62d4-7c2d-4e4c-b075-0db51d40ea4e	Team Member	898c36e9-1cb7-4c56-9148-a3b6893c0149	bb7ccd5f-2f60-49fb-b984-f11fc47add22	R&D (Research & Development)	f5c742d1-e0cc-4bf8-b860-a673ac407393	2026-10-20 21:42:25.847811+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N
8765d1b0-e4fc-4686-91ea-f5ad4e929818	Team Member	0aed67b8-c454-439a-a07f-4f46d46d58af	47dbf38f-c022-47bc-8444-d0dfb35ff3fd	Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra, Services - Testing - DevSecOps, Services - Testing - Red Team, Services - Testing - Cloud & AI	92aa9169-28d9-4754-a570-553b067642ed	2026-10-20 21:42:25.847811+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N
b25515f1-974c-4b63-a8b6-ca6e7ab95393	Team Member	3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60	0b8dfaba-3f3f-4f5f-8812-46144a90aeaf	Services - Operations	1a62b1f8-1810-464d-a67b-168d7e419827	2026-10-20 21:42:25.847811+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N
b7425734-5262-4802-9a10-5e3141b11d6c	Team Member	310a2f16-15f6-4b82-95f6-ab18b5b429f5	e8c22eff-0daf-4690-a537-c8b0b6110a01	Functional - HR	bb568e26-548b-4ca5-9221-fefb9c9143b3	2026-10-20 21:42:25.847811+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N
bce667dd-cae2-404d-8013-49194e0f48d9	Team Member	bcbd68c8-c3f3-4396-abb0-0b0e13637958	caa227a1-2dcf-4195-ab9c-8f76d1862daa	Functional - Accounts	cd2a32ed-32fc-47bc-88a9-e6fc48863869	2026-10-20 21:42:25.847811+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N
ce7509b0-415c-4d04-a2d8-43c3ee382a72	Team Member	8e4e88f1-e294-4554-80cc-92ed6169caeb	9050e021-7d84-4401-820e-c0e768abb1ab	Functional - Project Management	64e2ea37-cbd7-4127-b65b-3b003235981a	2026-10-20 21:42:25.847811+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N
ec4a89e1-35a6-495a-83c9-b6a34ee00402	Team Member	f7e882f6-2fa8-45e1-9137-2bc4b70f016a	f8502c44-b289-49e4-8401-3dcad4d5bbe0	Functional - IT Administration	b552183f-2695-41f9-860e-16d5fe94c4aa	2026-10-20 21:42:25.847811+05:30	2026-10-22 13:21:07.556154+05:30	\N	\N	\N
b53f25f2-2775-4879-ae83-669c04c897ba	Head of Department	abe592cb-6742-45f7-889e-4d4ca0b5e648	2e051c12-d958-474a-af63-5b0dd5439907	\N	\N	2026-11-16 17:34:22.960548+05:30	2026-11-16 17:34:22.960548+05:30	\N	\N	\N
a77d1bcf-da29-4c82-b8b5-014bdb39524c	Head of Department	6b9e6023-1248-489f-836a-1e39ad098691	fbac2b9c-726d-4aa5-aea9-2c1e97504f86	\N	\N	2026-11-16 17:34:23.717828+05:30	2026-11-16 17:34:23.717828+05:30	\N	\N	\N
03de8f9c-b3b4-46b6-8097-d83931fd2c2a	Head of Department	831edc4d-cc80-437d-b103-0a9f2ffd25af	29020fe6-73c6-44fb-9270-b9406c8ecded	\N	\N	2026-11-16 17:34:23.882528+05:30	2026-11-16 17:34:23.882528+05:30	\N	\N	\N
aaa6596a-15d4-4c20-9a3f-f756a8b16964	Head of Department	12b2cae0-dc54-4fa7-8f83-132d7d0ce86b	1c745743-e827-41bb-be9b-64f92fd77e2b	\N	\N	2026-11-16 17:34:24.214193+05:30	2026-11-16 17:34:24.214193+05:30	\N	\N	\N
c0b78f9e-be6c-496f-aa8c-4ddadd45168b	Head of Department	f3005225-a8e0-4d26-a3e8-0ef3911b30d2	4a64e2eb-fdb7-419e-9e56-25ab336aba60	\N	\N	2026-11-16 17:34:24.250536+05:30	2026-11-16 17:34:24.250536+05:30	\N	\N	\N
4473a94e-da00-475a-9d32-51be58f36e2a	Head of Department	6bc123eb-1c25-4757-829c-bc2de2b7e7d6	2b2e1a21-7c26-41e6-8439-95d83e3c38ff	\N	\N	2026-11-16 17:34:24.359962+05:30	2026-11-16 17:34:24.359962+05:30	\N	\N	\N
118e4eb2-fbe2-41a8-a85d-187a5464ebde	Head of Department	290118f3-e84e-42a2-ba41-36afbb9aab25	5ad7e3cc-6bbe-45b0-bb87-45b03b3d681b	\N	\N	2026-11-16 17:34:24.618409+05:30	2026-11-16 17:34:24.618409+05:30	\N	\N	\N
dc0984e7-277e-4b7d-93a7-e53f2f09d522	Head of Department	374cee8b-d543-4a49-b846-aaea8c5e6406	21ae8be0-2820-43eb-9ec9-94f1f714c68c	\N	\N	2026-11-16 17:34:24.698726+05:30	2026-11-16 17:34:24.698726+05:30	\N	\N	\N
b3a5642e-054f-4331-8c21-220a569c4798	Head of Department	874bfd76-38b4-42cc-96a4-31b797582415	703cb3ac-250c-44f4-9cd8-33a0f1ef828e	\N	\N	2026-11-16 17:34:24.765444+05:30	2026-11-16 17:34:24.765444+05:30	\N	\N	\N
24f1dde0-f7f5-4c91-a1b9-2fbaf7470fe0	Head of Department	f6a9b759-c7f8-40bf-a023-de85a937ba99	9ae2d7d1-480d-4362-a338-a68637f26362	\N	\N	2026-11-16 17:34:24.818402+05:30	2026-11-16 17:34:24.818402+05:30	\N	\N	\N
0d5b2555-05ad-4d75-be08-ab523074869a	Head of Department	e2f0b55b-5783-45bc-a339-ac04dc8a6098	bd00637b-438f-4fbe-9065-17d0b71c8a48	\N	\N	2026-11-16 17:34:24.894557+05:30	2026-11-16 17:34:24.894557+05:30	\N	\N	\N
b45017ee-4569-4983-8b89-9881481b13bf	Head of Department	720e015d-20da-4626-b8f6-9c1d97511c20	d00931a1-0c64-470f-830b-d9dc130cb5d4	\N	\N	2026-11-16 17:35:49.639151+05:30	2026-11-16 17:35:49.639151+05:30	\N	\N	\N
d7aba5db-7b72-4a47-a056-93402af2e1c8	Head of Department	5e28f925-3640-4e16-b45c-c6a0a49ea098	61baae51-2636-4674-9e76-5299e2264a90	\N	\N	2026-11-16 17:35:50.054293+05:30	2026-11-16 17:35:50.054293+05:30	\N	\N	\N
61941889-00c7-4962-8665-f8438624e643	Head of Department	7411036b-fe99-498a-b82a-c6cc8390f36a	8a7fbfa9-6340-4abe-9c49-a34620a62759	\N	\N	2026-11-16 17:35:50.190248+05:30	2026-11-16 17:35:50.190248+05:30	\N	\N	\N
58971e59-0312-47eb-8111-49f95153de21	Head of Department	01bc043c-05eb-4798-b19e-8bcacc1f36b3	da2a99f9-d21a-46de-9138-2cf3ff8cabf4	\N	\N	2026-11-16 17:35:50.854294+05:30	2026-11-16 17:35:50.854294+05:30	\N	\N	\N
2ecb13db-6fb6-43ad-8bf4-7415b7cc6125	Head of Department	35bec427-7f74-48ba-abe9-fcb903d61f0c	7d0a1a53-5bd8-4962-a4ae-0b99124d569c	\N	\N	2026-11-16 17:35:50.986239+05:30	2026-11-16 17:35:50.98624+05:30	\N	\N	\N
58c361e7-20f7-46e2-9788-aee38b54e79b	Head of Department	265e1f1a-fc38-45a4-83bd-af37560387b4	54029bad-87c3-4ba1-83d3-cc106f7ca1d5	\N	\N	2026-11-16 17:35:51.328024+05:30	2026-11-16 17:35:51.328025+05:30	\N	\N	\N
f142db85-ed40-4c5f-9dc0-fcb5ee0421fa	Head of Department	c29f539b-083b-47d8-a2e1-8c3628c4d779	97ee2216-ca4f-4ba2-80c6-50d8c1a36263	\N	\N	2026-11-16 17:35:52.128524+05:30	2026-11-16 17:35:52.128524+05:30	\N	\N	\N
675b498c-a0a2-4819-9abc-bb577854edd1	Head of Department	903b8f99-b6a7-4464-930e-4a79dc51cd15	393cec69-d85a-4eaa-a6e6-6d71a5fa846c	\N	\N	2026-11-16 17:35:52.365619+05:30	2026-11-16 17:35:52.365619+05:30	\N	\N	\N
e9b700ef-f602-4007-94a7-1ca2cf95b419	Head of Department	75de5ed9-d940-4948-a8a2-f307552ad45b	123d860b-6130-4f74-b28a-6e74636f4db6	\N	\N	2026-11-16 17:35:52.511074+05:30	2026-11-16 17:35:52.511074+05:30	\N	\N	\N
159de744-8ec5-436f-b60b-998d0e907819	Head of Department	e3b2f30d-4062-4bf3-ba14-b0240b69526b	ac2021ce-8742-42b1-96d7-f5d421419571	\N	\N	2026-11-16 17:35:52.627552+05:30	2026-11-16 17:35:52.627552+05:30	\N	\N	\N
79ee186a-7e62-4152-a7f2-014e5172fe5e	Head of Department	9ec562c0-965c-477c-a01e-256c998a1c4b	0c91b8de-446e-470d-a41c-874b45a81bac	\N	\N	2026-11-16 17:35:52.769187+05:30	2026-11-16 17:35:52.769188+05:30	\N	\N	\N
5a3c3c44-ac90-4ee5-a840-c11a3d068474	Head of Department	6531ab90-4e51-4509-b0f2-3a5ee17e7037	67be9fbe-b89e-4166-8a35-0e33f206387a	\N	\N	2026-11-16 17:41:29.991396+05:30	2026-11-16 17:41:29.991396+05:30	\N	\N	\N
5327e6d3-6f64-48a7-ae33-35c3ad640d7f	Head of Department	5fbf7cd7-5bd9-4cdd-9baf-e6bfcee52eb6	9b37add7-14a8-4b16-ad67-757626f8345e	\N	\N	2026-11-16 17:41:30.796149+05:30	2026-11-16 17:41:30.79615+05:30	\N	\N	\N
9eb4b4c2-5f98-42f6-88d4-4762e64583d4	Head of Department	aef18c44-bf09-4a99-8873-889a442c64f1	fa73055a-c057-4163-8bef-469d02876169	\N	\N	2026-11-16 17:41:30.947858+05:30	2026-11-16 17:41:30.947858+05:30	\N	\N	\N
ba46624d-bf08-401a-badf-ad41e8d81bdf	Head of Department	8ca3354b-b1be-419b-b47e-0a4a1a982f4e	6d11f105-4f3b-4c18-8a9d-e2cf2be076a2	\N	\N	2026-11-16 17:41:31.230048+05:30	2026-11-16 17:41:31.230048+05:30	\N	\N	\N
e9f50390-eebb-4ab3-a384-5528626f1566	Head of Department	2dea6534-9167-4e16-8c93-eb723f28b664	23764d61-69b6-44f1-87c7-e3ef78c9e9a9	\N	\N	2026-11-16 17:41:31.272014+05:30	2026-11-16 17:41:31.272014+05:30	\N	\N	\N
4df1611b-60f2-4bbd-9f9b-85543cffb1e5	Head of Department	d8bfc9e0-2f7c-4c97-b65b-609c79ed1c5b	2a49bf34-cd35-4267-b27e-f2b95a09edce	\N	\N	2026-11-16 17:41:31.394972+05:30	2026-11-16 17:41:31.394972+05:30	\N	\N	\N
6a1c36e5-cfdc-4d3d-81c4-4261244a9f50	Head of Department	6532964e-c117-4fdd-917f-7260fd8a9ad8	aad5bfac-2916-4071-bb8f-36162376de11	\N	\N	2026-11-16 17:41:31.678196+05:30	2026-11-16 17:41:31.678196+05:30	\N	\N	\N
ae79c639-f07d-49b7-842a-5afab730cd36	Head of Department	794f910e-4e82-4861-9821-b6e3c6be5cb9	9ddb1f12-0096-4e91-ac6b-f68a74da1e04	\N	\N	2026-11-16 17:41:31.765377+05:30	2026-11-16 17:41:31.765377+05:30	\N	\N	\N
70199f0f-21c2-460e-bc3a-33db20db1c78	Head of Department	89298bcc-999e-4144-942c-048886435ab0	288cc0ee-d895-4c0d-a4a3-76ee620b30b9	\N	\N	2026-11-16 17:41:31.838084+05:30	2026-11-16 17:41:31.838084+05:30	\N	\N	\N
06d7c139-3482-4bc5-a45e-510a765c9b77	Head of Department	74f871a0-cb2f-4425-ac81-1b62d0c9e053	1fe8cfe2-8d11-41c9-af9a-be740c514502	\N	\N	2026-11-16 17:41:31.895599+05:30	2026-11-16 17:41:31.895599+05:30	\N	\N	\N
d8fdbbf2-5d39-4063-a245-b84426a7d39d	Head of Department	33633a35-7e72-42e7-9a83-c1b393a0da18	68d1b494-e508-41d5-9f4a-ca7512948141	\N	\N	2026-11-16 17:41:31.971553+05:30	2026-11-16 17:41:31.971553+05:30	\N	\N	\N
c2295440-8696-451e-97e9-13f4a5361b19	Head of Department	d8d1c1b8-6c1d-410e-8c50-8da3787b3daf	f8d9e2fe-f3d7-4013-b6ad-159e0c94ee66	\N	\N	2026-11-16 17:47:44.029433+05:30	2026-11-16 17:47:44.029433+05:30	\N	\N	\N
63e03737-d4d2-4101-b577-bb7364c3f67d	Head of Department	bdf785dd-1890-456f-918b-e9bf23f6bd5d	a96e3f94-a593-47cd-80fb-c6d48d6d14ec	\N	\N	2026-11-16 17:47:44.697681+05:30	2026-11-16 17:47:44.697681+05:30	\N	\N	\N
d8e64bc7-ecab-49b6-8bbd-f390c7eeb729	Head of Department	bb448431-e2e1-489d-a82c-67daf4a507d0	8c35ee7a-a036-4e73-baa6-7182767ce5f5	\N	\N	2026-11-16 17:47:44.843537+05:30	2026-11-16 17:47:44.843537+05:30	\N	\N	\N
c37f8d1d-c4d9-4ad1-a14d-6ed50c25e7ac	Head of Department	22df3ab8-dfff-4dac-b473-4512e6c4e5f9	057f8100-165b-44fb-870a-fcbb5763dd61	\N	\N	2026-11-16 17:47:45.087841+05:30	2026-11-16 17:47:45.087841+05:30	\N	\N	\N
a2a2a7d8-4eb2-4a25-8b21-bfc47f4ca9ad	Head of Department	27010cbf-8cfe-41e7-8738-c06864f2de7f	004beba5-cb51-47fe-9aca-275ca77fd68f	\N	\N	2026-11-16 17:47:45.126923+05:30	2026-11-16 17:47:45.126924+05:30	\N	\N	\N
e195b810-c82c-422a-a04a-4f3bfebc0e19	Head of Department	1a529446-8714-4b5c-86cc-e407f114c8d7	42b662b9-ee4e-4b5f-b72f-9de8b983e768	\N	\N	2026-11-16 17:47:45.249187+05:30	2026-11-16 17:47:45.249187+05:30	\N	\N	\N
82796334-38e2-4d7c-9392-de5ace2bce32	Head of Department	e3d0d9db-c52a-40cc-a4ce-0726040a3b1a	140d3355-1ad3-4298-9672-325e17346b1e	\N	\N	2026-11-16 17:47:45.502757+05:30	2026-11-16 17:47:45.502757+05:30	\N	\N	\N
9a2845bc-c81a-43c5-90c9-c02aa8e83ed9	Head of Department	b678a28c-bc45-4d06-8019-a21302b0ec9e	0ba035c1-70ed-4af7-bac3-a40c4a364987	\N	\N	2026-11-16 17:47:45.578651+05:30	2026-11-16 17:47:45.578651+05:30	\N	\N	\N
ce605097-6b06-4f41-83fb-a1303376645b	Head of Department	1aaf98ae-a8a9-4483-a6bf-5c47666527e4	21dde614-d671-4e0b-ad84-8e100c4144de	\N	\N	2026-11-16 17:47:45.640626+05:30	2026-11-16 17:47:45.640626+05:30	\N	\N	\N
21113ea8-b82d-4da2-b359-a0eec2a762ce	Head of Department	229c8198-9138-4202-a046-c62a526187d7	18ee8b63-a783-4f50-a970-c96c31721127	\N	\N	2026-11-16 17:47:45.689118+05:30	2026-11-16 17:47:45.689118+05:30	\N	\N	\N
5045551b-0e25-4946-bba0-887343a1255f	Head of Department	d79ba597-dee0-4084-88c8-5f2be439446f	f2351301-01c0-48c6-972e-7c70e00ec491	\N	\N	2026-11-16 17:47:45.759179+05:30	2026-11-16 17:47:45.759179+05:30	\N	\N	\N
1ed327df-74ab-45c3-811d-9cbc523d0473	Head of Department	85086053-66aa-4362-be10-01a221ed181d	e8effed1-d09f-4980-820d-f486a48495ee	\N	\N	2026-11-16 18:09:30.190585+05:30	2026-11-16 18:09:30.190585+05:30	\N	\N	\N
63386e9e-d3c3-4704-a651-db8665e729a1	Head of Department	6a84f6a7-a299-4de5-9704-973418f07662	827c8cb2-78a1-4e1d-8e3a-dec4604eac7b	\N	\N	2026-11-16 18:09:30.861912+05:30	2026-11-16 18:09:30.861912+05:30	\N	\N	\N
73a39e84-b585-4dbf-8fff-c79546c49bed	Head of Department	8eb1ce52-c09f-4301-a448-4b03e748ce00	698bd542-e70a-49b2-9c32-8a4eae8616af	\N	\N	2026-11-16 18:09:30.99163+05:30	2026-11-16 18:09:30.99163+05:30	\N	\N	\N
9fb79a17-7c6e-4f93-888f-11afb0c68cce	Head of Department	da3a6c05-a521-4a7e-8495-15b50fa4f3f8	77d0e1c4-739f-40f8-8dd6-7574ec23ca19	\N	\N	2026-11-16 18:09:31.247882+05:30	2026-11-16 18:09:31.247882+05:30	\N	\N	\N
fd2bc368-bd12-472a-851f-5ef2bc48de36	Head of Department	06860ea2-6a18-4e8e-82c6-5f4f7b635296	eda6d175-af75-4502-856e-e890bbb18caf	\N	\N	2026-11-16 18:09:31.282106+05:30	2026-11-16 18:09:31.282106+05:30	\N	\N	\N
eab82dad-4abc-49fe-b8e8-877892167583	Head of Department	23957b99-1418-4a58-b9f6-25305ead38b0	c035d2de-1961-4553-b633-da4c266c3ac9	\N	\N	2026-11-16 18:09:31.387323+05:30	2026-11-16 18:09:31.387323+05:30	\N	\N	\N
a5e43210-b3e2-4153-8fd5-087034d0be06	Head of Department	85224703-01dc-45a7-a592-a1528696fdf1	ab37eca4-aae6-4b97-ae7f-5ad76086e790	\N	\N	2026-11-16 18:09:31.630568+05:30	2026-11-16 18:09:31.630568+05:30	\N	\N	\N
6a9c8a0b-3fa5-4e16-a415-dd9fde52f2e5	Head of Department	52ab67a9-3d17-42e6-9649-3abb4f586ef7	b12913da-c884-49eb-bf5b-d133c0c987a4	\N	\N	2026-11-16 18:09:31.708009+05:30	2026-11-16 18:09:31.708009+05:30	\N	\N	\N
886711e7-9a7e-4efb-8094-654a742f96b2	Head of Department	3a913306-2b53-4173-abb6-d80d0034b8d5	a68ad37b-7bd6-41e7-a8e5-8b97a43a876a	\N	\N	2026-11-16 18:09:31.774261+05:30	2026-11-16 18:09:31.774261+05:30	\N	\N	\N
38941885-85f0-47f3-8747-4e6ea57afd52	Head of Department	4f942518-07e0-4c26-8f49-0f804903126e	d8936264-8926-4419-8152-88468cc61af9	\N	\N	2026-11-16 18:09:31.825696+05:30	2026-11-16 18:09:31.825696+05:30	\N	\N	\N
8689c9f9-d35b-42a5-9298-5da78de49054	Head of Department	a901acd6-85e2-47ff-acda-9ab48eb552d4	9f1a5621-02a3-4cb3-b4ee-d4663ee11cf3	\N	\N	2026-11-16 18:09:31.895045+05:30	2026-11-16 18:09:31.895045+05:30	\N	\N	\N
6990a104-599e-4f48-9e8a-fb4e533362ad	Head of Department	a2b80f55-67fe-46b1-860c-3318d5a0bc07	0a8342f0-8d11-44e4-ab44-f486d7bc9abc	\N	\N	2026-11-16 18:18:49.199661+05:30	2026-11-16 18:18:49.199662+05:30	\N	\N	\N
9906a032-8718-4655-ab5d-cd325e9510b7	Head of Department	96c07cbf-f70c-414e-afcb-5857f03f0eb0	3e5accf9-cf05-4494-9c2e-d647cde0c9af	\N	\N	2026-11-16 18:18:49.289188+05:30	2026-11-16 18:18:49.289188+05:30	\N	\N	\N
f5043e4e-e2e0-41de-93ee-86925d4e5fa1	Head of Department	6d0277e9-2779-443d-9892-166e4d308cd9	757c31b4-d48b-45df-9c2c-ec194c8e29c6	\N	\N	2026-11-16 18:18:49.32869+05:30	2026-11-16 18:18:49.32869+05:30	\N	\N	\N
b898ed0c-b629-4cc6-af94-09e0611acde9	Head of Department	739431ab-07d5-4c15-8ac1-710ce3281ac7	c8387aee-7fec-4fcb-945d-f01c23b1a456	\N	\N	2026-11-16 18:18:49.457868+05:30	2026-11-16 18:18:49.457868+05:30	\N	\N	\N
014fc875-0251-4bd6-9d0f-046f8c24a98f	Head of Department	08c4d08a-4ec5-46c7-924f-17a79fc31633	6fd1d268-d5a3-4b51-98e7-6ed8f156eb03	\N	\N	2026-11-16 18:18:49.479098+05:30	2026-11-16 18:18:49.479098+05:30	\N	\N	\N
0b9e40bf-593d-40c4-adc3-699b9804e784	Head of Department	a002408c-93a5-4d06-9d52-9fd88d8b6154	e1aa305d-7479-4dc6-9705-00ef14029710	\N	\N	2026-11-16 18:18:49.550157+05:30	2026-11-16 18:18:49.550157+05:30	\N	\N	\N
5e3ff7fc-6a01-4511-a2d2-1e289ec6d400	Head of Department	25c207ee-081c-4ea0-9715-0181c9e20699	1414f4ba-2c51-40d7-a067-b922316c9f5f	\N	\N	2026-11-16 18:18:49.730445+05:30	2026-11-16 18:18:49.730445+05:30	\N	\N	\N
9677da11-05f1-4d42-ad65-6078a11bd48e	Head of Department	2d7a7f5b-ba4b-4210-8b16-69f81df57b31	c6a6912e-5252-4010-9959-5c17439c9b39	\N	\N	2026-11-16 18:18:49.786739+05:30	2026-11-16 18:18:49.786739+05:30	\N	\N	\N
0f37f448-784b-401b-9be1-2d4f38a605c4	Head of Department	811e7e02-34b7-44d2-aedf-f3f1341c8870	b1327618-a5c9-4be9-97df-82d624797280	\N	\N	2026-11-16 18:18:49.833082+05:30	2026-11-16 18:18:49.833082+05:30	\N	\N	\N
4efac777-c7c9-4615-9bed-f789dcd4719b	Head of Department	7b975a68-1f64-4a99-9ec7-409511f77e22	93d1ffcc-ff80-488d-a575-f0afb8e056b9	\N	\N	2026-11-16 18:18:49.87071+05:30	2026-11-16 18:18:49.87071+05:30	\N	\N	\N
5567426c-1c06-4e03-8be4-516d36728248	Head of Department	860f4838-adfc-4b25-8558-8b63f492aa52	84f406b5-0698-4a97-9c54-ff61a92c6c13	\N	\N	2026-11-16 18:18:49.926937+05:30	2026-11-16 18:18:49.926937+05:30	\N	\N	\N
b4b932fd-fb3f-4133-bf19-7962bdb9ac2d	Head of Department	1e5a4682-283c-48f0-956e-665ff58de66e	512c9cb6-182d-4cb3-8e18-d8eb0c897431	\N	\N	2026-11-16 19:00:22.795507+05:30	2026-11-16 19:00:22.795507+05:30	\N	\N	\N
fe732d1a-7c9e-42b3-97b1-05b3732cca9f	Head of Department	b5700263-646f-4207-b520-c102e51abc81	27304521-bacb-4b28-b30d-99ffdd25401d	\N	\N	2026-11-16 19:00:23.228649+05:30	2026-11-16 19:00:23.228649+05:30	\N	\N	\N
9a7719c1-bac2-4907-98ba-91ac7ef9444e	Head of Department	df62a8da-0fa6-46bc-9705-fe2e3f329eed	39989e64-fd77-4053-93e3-9e3f19a6efb6	\N	\N	2026-11-16 19:00:23.404041+05:30	2026-11-16 19:00:23.404041+05:30	\N	\N	\N
c07f7e73-dd50-41c3-a372-ad87f334ac57	Head of Department	5652a6fb-8516-48db-aed0-b04d93d5df65	d436b8eb-b21a-46f3-b3d3-c90be69a2488	\N	\N	2026-11-16 19:00:23.987077+05:30	2026-11-16 19:00:23.987077+05:30	\N	\N	\N
e5f44a19-1fa5-438b-9c7a-21c515e96881	Head of Department	5f82bfd3-7909-4677-9748-16634c6797bb	09879dd2-60e8-4af9-8325-27251ec37f74	\N	\N	2026-11-16 19:00:24.065851+05:30	2026-11-16 19:00:24.065851+05:30	\N	\N	\N
b991d8d9-2e6d-411c-a67e-fbf4fea0e64d	Head of Department	4f22d730-76df-4e66-b474-a38f75ab628a	bd2f975f-5138-4cfa-a395-6026466d4606	\N	\N	2026-11-16 19:00:24.436331+05:30	2026-11-16 19:00:24.436331+05:30	\N	\N	\N
1d6416d8-a583-4957-972b-2aa216b8cb02	Head of Department	5aebebe9-24d8-4e23-bbf5-cd4968668257	7652fbe4-3675-4941-a967-61f2a7e98a3e	\N	\N	2026-11-16 19:00:25.248151+05:30	2026-11-16 19:00:25.248152+05:30	\N	\N	\N
8b1e12b0-0af8-4cb4-9025-e986a47cb3e0	Head of Department	bac823bc-25a0-43ec-bd4e-0a31040ea7a9	31bc1d95-75bf-4e51-bf1e-4be15afd9bf5	\N	\N	2026-11-16 19:00:25.670784+05:30	2026-11-16 19:00:25.670784+05:30	\N	\N	\N
e9bdd07e-c3fb-4abb-a6f6-2bf4de623cd4	Head of Department	c9de9c8a-0513-489e-b744-b6e69159d5a9	e647d76f-ccd7-4495-85c1-bceb87f1300d	\N	\N	2026-11-16 19:00:26.007127+05:30	2026-11-16 19:00:26.007128+05:30	\N	\N	\N
a428b91e-4e3c-4677-a7cd-dbf56bbed8ed	Head of Department	61d2f8b1-301a-425b-ad47-8a045caf61d2	344c2fae-e89d-468d-a16c-a37d5a8f4d88	\N	\N	2026-11-16 19:00:26.254173+05:30	2026-11-16 19:00:26.254174+05:30	\N	\N	\N
2cd0f660-df60-45ee-9c66-0cb1bdd23908	Head of Department	2084052c-3bc4-460f-9260-f3c5a41f4216	cbbb4785-006f-4f2a-af01-4d29c0d02005	\N	\N	2026-11-16 19:00:26.683385+05:30	2026-11-16 19:00:26.683385+05:30	\N	\N	\N
\.


--
-- Data for Name: tbl_sla_events; Type: TABLE DATA; Schema: sla; Owner: -
--

COPY sla.tbl_sla_events (id, instanceid, eventtype, scheduledatutc, executedatutc, hangfirejobid, status, stageatexecution, targetrolesjson, targetrecipientidsjson, executionlog, retrycount, createdatutc, updatedatutc, deletedatutc, createdby, updatedby, idempotencykey) FROM stdin;
\.


--
-- Data for Name: tbl_sla_instances; Type: TABLE DATA; Schema: sla; Owner: -
--

COPY sla.tbl_sla_instances (id, policyid, module, activitytype, entityid, entityreference, currentstage, status, priority, startedatutc, targetdeadlineutc, breachedatutc, completedatutc, cancelledatutc, pausedatutc, totalpausedseconds, activehangfirejobid, recipientemployeeid, projectid, custompayloadjson, createdatutc, updatedatutc, deletedatutc, createdby, updatedby) FROM stdin;
\.


--
-- Data for Name: tbl_sla_policies; Type: TABLE DATA; Schema: sla; Owner: -
--

COPY sla.tbl_sla_policies (id, module, activitytype, stage, name, description, tatdurationminutes, calculationmode, workinghoursstart, workinghoursend, excludeweekends, excludeholidays, reminderintervalsminutesjson, firstescalationafterminutes, secondescalationafterminutes, responsiblerolesjson, firstescalationrolesjson, secondescalationrolesjson, isactive, metadatajson, createdatutc, updatedatutc, deletedatutc, createdby, updatedby) FROM stdin;
a1b2c3d4-e5f6-7890-abcd-ef1234567890	Projects	Resolution of Issues	Open	Project Health - Issue Resolution SLA Policy	Daily reminders for EM, PM, TL. SLA deadline: EOD of next 2 days with Sr. PM escalation. Second escalation: HOD by EOD of next 1 day.	1080	EndOfDay	09:00:00	18:00:00	t	t	[1440]	0	540	["EngagementManager", "ProjectManager", "TeamLead"]	["SeniorProjectManager", "Sr. PM"]	["HOD", "Head Of Department"]	t	{"CompletionCondition":"Resolved or Closed","Timezone":"Asia/Kolkata"}	2026-11-11 21:04:35.298256+05:30	\N	\N	\N	\N
95b15523-b424-4259-8b64-0941e96d04e5	ActionCentre	Task Start After Assigning	Assigned	Task Start After Assigning SLA Policy	\N	540	EndOfDay	09:00:00	18:00:00	t	t	[]	0	\N	["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"]	["Assigned Senior Project Manager"]	["Head of Department"]	t	{}	2026-11-12 17:27:18.507524+05:30	\N	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N
6c54db62-9be5-45af-96df-b8851c178b57	ActionCentre	Task Deadline	Not Started	Task Deadline SLA Policy	\N	1440	EndOfDay	09:00:00	18:00:00	t	t	[]	0	\N	["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"]	["Assigned Senior Project Manager"]	["Head of Department"]	t	{}	2026-11-12 17:27:18.832466+05:30	\N	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N
6344cb14-3b98-4da0-8394-24b34e2e398b	ActionCentre	Task Pause	Paused	Task Pause Daily Reminder Policy	\N	1440	EndOfDay	09:00:00	18:00:00	t	t	[]	\N	\N	["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"]	[]	[]	t	{}	2026-11-12 17:28:06.552209+05:30	\N	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N
cae84ae5-213c-4906-818b-cf4d5422205a	ActionCentre	Task Deadline	Ongoing	Task Deadline SLA Policy	\N	1440	EndOfDay	09:00:00	18:00:00	t	t	[]	0	\N	["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"]	["Assigned Senior Project Manager"]	["Head of Department"]	t	{}	2026-11-12 19:01:16.214445+05:30	\N	\N	\N	\N
4c55bba9-a2b7-4b03-9a66-229eaf45eeb5	Team	Resource Allocation Approval	Pending	Resource Allocation Approval SLA Policy	\N	1080	EndOfDay	09:00:00	18:00:00	t	t	[]	0	\N	["Reporting Manager"]	["Assigned Senior Project Manager"]	["Head of Department"]	t	{}	2026-11-16 03:44:45.800473+05:30	\N	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N
0da8f003-41bf-457f-98e3-73495cfa322c	Projects	WBS Escalation	Open	WBS Escalation SLA Policy	\N	1080	EndOfDay	09:00:00	18:00:00	t	t	[]	0	\N	["Select Stakeholders"]	["Assigned Senior Project Manager"]	["Head of Department"]	t	{}	2026-11-16 04:12:55.866281+05:30	\N	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N
8de89f65-a97f-4a30-ad3c-60a4b362d77e	Project	Extension Request	Pending	Project Extension Request SLA Policy	\N	1080	EndOfDay	09:00:00	18:00:00	t	t	[]	0	\N	["Select Stakeholders"]	["Assigned Senior Project Manager"]	["Head of Department"]	t	{}	2026-11-16 12:41:46.815887+05:30	\N	\N	\N	\N
30c8e2d1-639b-48f6-a2cf-56bdb64c7668	Project	Additional Customer Requirement	Pending	Additional Customer Requirement SLA Policy	\N	1080	EndOfDay	09:00:00	18:00:00	t	t	[]	0	\N	["Assigned Sales Manager", "Assigned Sales Person"]	["Assigned Senior Project Manager"]	["Head of Department"]	t	{}	2026-11-16 12:41:59.956904+05:30	\N	\N	\N	\N
f5415a3a-4469-4bf9-a92c-14ffdd9e101b	Project	Task Start After Assigning	PendingStart	Task Start After Assigning SLA Policy	\N	540	EndOfDay	09:00:00	18:00:00	t	t	[]	0	\N	["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"]	["Assigned Senior Project Manager"]	["Head of Department"]	t	{}	2026-11-16 12:58:30.396453+05:30	\N	\N	\N	\N
b9f32015-2891-4bfe-827e-dc68831cd346	Project	Task Deadline	InProgress	Task Deadline SLA Policy	\N	1440	EndOfDay	09:00:00	18:00:00	t	t	[]	0	\N	["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"]	["Assigned Senior Project Manager"]	["Head of Department"]	t	{}	2026-11-16 12:58:30.787314+05:30	\N	\N	\N	\N
\.


--
-- Data for Name: tbl_team_day_entries; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_team_day_entries ("Id", "EmployeeId", "WorkDate", "Attendance", "Shift", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
df4acf33-00d4-4066-802a-94f0d91b5d31	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	2026-10-18	onsite	General	2026-10-18 16:10:45.088531+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
476f8400-97d4-4d83-8550-1f86411b403a	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	2026-10-21	leave	\N	2026-10-21 11:39:53.844971+05:30	2026-10-21 11:40:24.349571+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-21 11:40:24.349571+05:30
85f52541-97a7-4ea8-b187-3fcce0828068	42583b6b-008c-45f6-b258-b08495712c7c	2026-10-27	\N	General	2026-10-27 15:25:12.892994+05:30	2026-10-27 15:25:20.55798+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	\N
fbfd798b-c81b-4e6e-9031-e91c761bb3e7	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	2026-10-27	leave	\N	2026-10-27 15:25:09.82702+05:30	2026-10-27 15:25:32.610468+05:30	049ac489-bbd3-4153-b933-aec7b7baec89	049ac489-bbd3-4153-b933-aec7b7baec89	2026-10-27 15:25:32.610468+05:30
e4c1028d-32f5-4ea7-8348-a241b4996d99	42583b6b-008c-45f6-b258-b08495712c7c	2026-11-18	\N	Afternoon	2026-11-11 19:52:09.300622+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
a2c3854f-e59a-4aff-8376-e079500ec339	42583b6b-008c-45f6-b258-b08495712c7c	2026-11-11	\N	Afternoon	2026-11-11 19:52:20.583534+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
6e0911fe-b67c-45de-a306-af9e57d54ec3	8bf95b5f-0a1b-4512-9fc4-0e0fd9a4503c	2026-11-11	\N	Night	2026-11-11 19:52:32.00686+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
eb58cfbc-e163-413b-b82c-39cf8427106d	049ac489-bbd3-4153-b933-aec7b7baec89	2026-11-12	\N	Morning	2026-11-12 11:44:41.861192+05:30	\N	049ac489-bbd3-4153-b933-aec7b7baec89	\N	\N
ee89f414-3e26-4b79-873f-47016bd9bae0	62e81e6b-7247-4c3f-a8b8-db21e613d02a	2026-11-01	onsite	General	2026-11-12 11:45:14.168958+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
f89160c6-0193-4e6c-83e9-ba494ec4b847	1fa56f20-56ce-4461-ac66-c7d7b34f16d6	2026-11-01	onsite	General	2026-11-12 11:46:05.180957+05:30	2026-11-12 11:46:56.264902+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	cc9bf92a-b923-8364-be83-4bb68db79cd2	2026-11-12 11:46:56.264902+05:30
b7fb0002-0eea-48c1-865e-2575b6a8fefb	1fa56f20-56ce-4461-ac66-c7d7b34f16d6	2026-11-25	onsite	General	2026-11-12 11:46:56.299194+05:30	\N	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N	\N
\.


--
-- Data for Name: tbl_team_member_holidays; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_team_member_holidays ("Id", "EmployeeId", "HolidayDate", "Name", "Comment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
45e00f05-4f2a-464e-9a38-0aa92fdc8beb	1fa56f20-56ce-4461-ac66-c7d7b34f16d6	2026-11-25	Special Holiday	Test	2026-11-12 11:46:56.264902+05:30	2026-11-12 11:46:56.313882+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	cc9bf92a-b923-8364-be83-4bb68db79cd2	2026-11-12 11:46:56.313882+05:30
\.


--
-- Data for Name: tbl_team_member_schedules; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_team_member_schedules ("Id", "EmployeeId", "WorkingDays", "Notes", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
a8ccc320-a79f-4ff3-9ebb-fb3e0d6b5c2e	1fa56f20-56ce-4461-ac66-c7d7b34f16d6	{1,2,3,4,5}	\N	2026-11-12 11:46:56.264902+05:30	2026-11-12 11:46:56.313882+05:30	cc9bf92a-b923-8364-be83-4bb68db79cd2	cc9bf92a-b923-8364-be83-4bb68db79cd2	\N
\.


--
-- Data for Name: tbl_timesheet_entries; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_timesheet_entries ("Id", "TimesheetWeekId", "ProjectKey", "TaskKey", "ProjectName", "TaskName", "ReviewDecision", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_timesheet_entry_days; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_timesheet_entry_days ("Id", "TimesheetEntryId", "DayIndex", "Hours", "Comment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Data for Name: tbl_timesheets; Type: TABLE DATA; Schema: timesheet; Owner: -
--

COPY timesheet.tbl_timesheets ("Id", "EmployeeId", "WeekStart", "Status", "TotalHours", "SubmittedAtUtc", "ReviewedByEmployeeId", "ReviewedAtUtc", "ReviewComment", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") FROM stdin;
\.


--
-- Name: tbl_notifications_number_seq; Type: SEQUENCE SET; Schema: action; Owner: -
--

SELECT pg_catalog.setval('action.tbl_notifications_number_seq', 26627, true);


--
-- Name: aggregatedcounter_id_seq; Type: SEQUENCE SET; Schema: hangfire; Owner: -
--

SELECT pg_catalog.setval('hangfire.aggregatedcounter_id_seq', 427, true);


--
-- Name: counter_id_seq; Type: SEQUENCE SET; Schema: hangfire; Owner: -
--

SELECT pg_catalog.setval('hangfire.counter_id_seq', 2445, true);


--
-- Name: hash_id_seq; Type: SEQUENCE SET; Schema: hangfire; Owner: -
--

SELECT pg_catalog.setval('hangfire.hash_id_seq', 66, true);


--
-- Name: job_id_seq; Type: SEQUENCE SET; Schema: hangfire; Owner: -
--

SELECT pg_catalog.setval('hangfire.job_id_seq', 1417, true);


--
-- Name: jobparameter_id_seq; Type: SEQUENCE SET; Schema: hangfire; Owner: -
--

SELECT pg_catalog.setval('hangfire.jobparameter_id_seq', 2861, true);


--
-- Name: jobqueue_id_seq; Type: SEQUENCE SET; Schema: hangfire; Owner: -
--

SELECT pg_catalog.setval('hangfire.jobqueue_id_seq', 108, true);


--
-- Name: list_id_seq; Type: SEQUENCE SET; Schema: hangfire; Owner: -
--

SELECT pg_catalog.setval('hangfire.list_id_seq', 1, false);


--
-- Name: set_id_seq; Type: SEQUENCE SET; Schema: hangfire; Owner: -
--

SELECT pg_catalog.setval('hangfire.set_id_seq', 1425, true);


--
-- Name: state_id_seq; Type: SEQUENCE SET; Schema: hangfire; Owner: -
--

SELECT pg_catalog.setval('hangfire.state_id_seq', 2423, true);


--
-- Name: tbl_bucket_tasks PK_tbl_bucket_tasks; Type: CONSTRAINT; Schema: action; Owner: -
--

ALTER TABLE ONLY action.tbl_bucket_tasks
    ADD CONSTRAINT "PK_tbl_bucket_tasks" PRIMARY KEY ("Id");


--
-- Name: tbl_notifications pk_tbl_notifications; Type: CONSTRAINT; Schema: action; Owner: -
--

ALTER TABLE ONLY action.tbl_notifications
    ADD CONSTRAINT pk_tbl_notifications PRIMARY KEY ("Id");


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
-- Name: aggregatedcounter aggregatedcounter_key_key; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.aggregatedcounter
    ADD CONSTRAINT aggregatedcounter_key_key UNIQUE (key);


--
-- Name: aggregatedcounter aggregatedcounter_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.aggregatedcounter
    ADD CONSTRAINT aggregatedcounter_pkey PRIMARY KEY (id);


--
-- Name: counter counter_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.counter
    ADD CONSTRAINT counter_pkey PRIMARY KEY (id);


--
-- Name: hash hash_key_field_key; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.hash
    ADD CONSTRAINT hash_key_field_key UNIQUE (key, field);


--
-- Name: hash hash_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.hash
    ADD CONSTRAINT hash_pkey PRIMARY KEY (id);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: jobparameter jobparameter_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.jobparameter
    ADD CONSTRAINT jobparameter_pkey PRIMARY KEY (id);


--
-- Name: jobqueue jobqueue_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.jobqueue
    ADD CONSTRAINT jobqueue_pkey PRIMARY KEY (id);


--
-- Name: list list_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.list
    ADD CONSTRAINT list_pkey PRIMARY KEY (id);


--
-- Name: lock lock_resource_key; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.lock
    ADD CONSTRAINT lock_resource_key UNIQUE (resource);

ALTER TABLE ONLY hangfire.lock REPLICA IDENTITY USING INDEX lock_resource_key;


--
-- Name: schema schema_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.schema
    ADD CONSTRAINT schema_pkey PRIMARY KEY (version);


--
-- Name: server server_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.server
    ADD CONSTRAINT server_pkey PRIMARY KEY (id);


--
-- Name: set set_key_value_key; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.set
    ADD CONSTRAINT set_key_value_key UNIQUE (key, value);


--
-- Name: set set_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.set
    ADD CONSTRAINT set_pkey PRIMARY KEY (id);


--
-- Name: state state_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.state
    ADD CONSTRAINT state_pkey PRIMARY KEY (id);


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
-- Name: mst_leave_calendar mst_leave_calendar_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.mst_leave_calendar
    ADD CONSTRAINT mst_leave_calendar_pkey PRIMARY KEY ("Id");


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
-- Name: tbl_project_alerts PK_tbl_project_alerts; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_alerts
    ADD CONSTRAINT "PK_tbl_project_alerts" PRIMARY KEY ("Id");


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
-- Name: tbl_project_issues PK_tbl_project_issues; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_issues
    ADD CONSTRAINT "PK_tbl_project_issues" PRIMARY KEY ("Id");


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
-- Name: tbl_project_feedbacks pk_tbl_project_feedbacks; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_feedbacks
    ADD CONSTRAINT pk_tbl_project_feedbacks PRIMARY KEY ("Id");


--
-- Name: tbl_project_additional_requirements tbl_project_additional_requirements_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_additional_requirements
    ADD CONSTRAINT tbl_project_additional_requirements_pkey PRIMARY KEY ("Id");


--
-- Name: tbl_project_appreciations tbl_project_appreciations_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_appreciations
    ADD CONSTRAINT tbl_project_appreciations_pkey PRIMARY KEY ("Id");


--
-- Name: tbl_resource_allocation_requests tbl_resource_allocation_requests_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_resource_allocation_requests
    ADD CONSTRAINT tbl_resource_allocation_requests_pkey PRIMARY KEY ("Id");


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
-- Name: tbl_sla_events tbl_sla_events_pkey; Type: CONSTRAINT; Schema: sla; Owner: -
--

ALTER TABLE ONLY sla.tbl_sla_events
    ADD CONSTRAINT tbl_sla_events_pkey PRIMARY KEY (id);


--
-- Name: tbl_sla_instances tbl_sla_instances_pkey; Type: CONSTRAINT; Schema: sla; Owner: -
--

ALTER TABLE ONLY sla.tbl_sla_instances
    ADD CONSTRAINT tbl_sla_instances_pkey PRIMARY KEY (id);


--
-- Name: tbl_sla_policies tbl_sla_policies_pkey; Type: CONSTRAINT; Schema: sla; Owner: -
--

ALTER TABLE ONLY sla.tbl_sla_policies
    ADD CONSTRAINT tbl_sla_policies_pkey PRIMARY KEY (id);


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
-- Name: IX_tbl_bucket_tasks_EmployeeId; Type: INDEX; Schema: action; Owner: -
--

CREATE INDEX "IX_tbl_bucket_tasks_EmployeeId" ON action.tbl_bucket_tasks USING btree ("EmployeeId");


--
-- Name: IX_tbl_bucket_tasks_Priority; Type: INDEX; Schema: action; Owner: -
--

CREATE INDEX "IX_tbl_bucket_tasks_Priority" ON action.tbl_bucket_tasks USING btree ("Priority");


--
-- Name: IX_tbl_bucket_tasks_ProjectId; Type: INDEX; Schema: action; Owner: -
--

CREATE INDEX "IX_tbl_bucket_tasks_ProjectId" ON action.tbl_bucket_tasks USING btree ("ProjectId");


--
-- Name: IX_tbl_bucket_tasks_Status; Type: INDEX; Schema: action; Owner: -
--

CREATE INDEX "IX_tbl_bucket_tasks_Status" ON action.tbl_bucket_tasks USING btree ("Status");


--
-- Name: IX_tbl_bucket_tasks_TaskId; Type: INDEX; Schema: action; Owner: -
--

CREATE INDEX "IX_tbl_bucket_tasks_TaskId" ON action.tbl_bucket_tasks USING btree ("TaskId");


--
-- Name: IX_tbl_bucket_tasks_TaskId_EmployeeId; Type: INDEX; Schema: action; Owner: -
--

CREATE UNIQUE INDEX "IX_tbl_bucket_tasks_TaskId_EmployeeId" ON action.tbl_bucket_tasks USING btree ("TaskId", "EmployeeId") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_tbl_notifications_ServiceEscalationId; Type: INDEX; Schema: action; Owner: -
--

CREATE INDEX "IX_tbl_notifications_ServiceEscalationId" ON action.tbl_notifications USING btree ("ServiceEscalationId") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: ix_tbl_notifications_project; Type: INDEX; Schema: action; Owner: -
--

CREATE INDEX ix_tbl_notifications_project ON action.tbl_notifications USING btree ("ProjectId", "DeletedAtUtc");


--
-- Name: ix_tbl_notifications_recipient_employee; Type: INDEX; Schema: action; Owner: -
--

CREATE INDEX ix_tbl_notifications_recipient_employee ON action.tbl_notifications USING btree ("RecipientEmployeeId", "DeletedAtUtc");


--
-- Name: ix_tbl_notifications_status; Type: INDEX; Schema: action; Owner: -
--

CREATE INDEX ix_tbl_notifications_status ON action.tbl_notifications USING btree ("Status");


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
-- Name: ix_hangfire_counter_expireat; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_counter_expireat ON hangfire.counter USING btree (expireat);


--
-- Name: ix_hangfire_counter_key; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_counter_key ON hangfire.counter USING btree (key);


--
-- Name: ix_hangfire_hash_expireat; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_hash_expireat ON hangfire.hash USING btree (expireat);


--
-- Name: ix_hangfire_job_expireat; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_job_expireat ON hangfire.job USING btree (expireat);


--
-- Name: ix_hangfire_job_statename; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_job_statename ON hangfire.job USING btree (statename);


--
-- Name: ix_hangfire_job_statename_is_not_null; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_job_statename_is_not_null ON hangfire.job USING btree (statename) INCLUDE (id) WHERE (statename IS NOT NULL);


--
-- Name: ix_hangfire_jobparameter_jobidandname; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_jobparameter_jobidandname ON hangfire.jobparameter USING btree (jobid, name);


--
-- Name: ix_hangfire_jobqueue_fetchedat_queue_jobid; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_jobqueue_fetchedat_queue_jobid ON hangfire.jobqueue USING btree (fetchedat NULLS FIRST, queue, jobid);


--
-- Name: ix_hangfire_jobqueue_jobidandqueue; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_jobqueue_jobidandqueue ON hangfire.jobqueue USING btree (jobid, queue);


--
-- Name: ix_hangfire_jobqueue_queueandfetchedat; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_jobqueue_queueandfetchedat ON hangfire.jobqueue USING btree (queue, fetchedat);


--
-- Name: ix_hangfire_list_expireat; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_list_expireat ON hangfire.list USING btree (expireat);


--
-- Name: ix_hangfire_set_expireat; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_set_expireat ON hangfire.set USING btree (expireat);


--
-- Name: ix_hangfire_set_key_score; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_set_key_score ON hangfire.set USING btree (key, score);


--
-- Name: ix_hangfire_state_jobid; Type: INDEX; Schema: hangfire; Owner: -
--

CREATE INDEX ix_hangfire_state_jobid ON hangfire.state USING btree (jobid);


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
-- Name: IX_mst_leave_calendar_HolidayDate; Type: INDEX; Schema: master; Owner: -
--

CREATE UNIQUE INDEX "IX_mst_leave_calendar_HolidayDate" ON master.mst_leave_calendar USING btree ("HolidayDate") WHERE ("DeletedAtUtc" IS NULL);


--
-- Name: IX_mst_leave_calendar_Year; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX "IX_mst_leave_calendar_Year" ON master.mst_leave_calendar USING btree ("Year") WHERE ("DeletedAtUtc" IS NULL);


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
-- Name: IX_tbl_project_alerts_IssueId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_alerts_IssueId" ON project.tbl_project_alerts USING btree ("IssueId");


--
-- Name: IX_tbl_project_alerts_ProjectId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_alerts_ProjectId" ON project.tbl_project_alerts USING btree ("ProjectId");


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
-- Name: IX_tbl_project_invoices_ProjectServiceId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_invoices_ProjectServiceId" ON project.tbl_project_invoices USING btree ("ProjectServiceId");


--
-- Name: IX_tbl_project_invoices_Status; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_invoices_Status" ON project.tbl_project_invoices USING btree ("Status");


--
-- Name: IX_tbl_project_issues_ProjectId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_issues_ProjectId" ON project.tbl_project_issues USING btree ("ProjectId");


--
-- Name: IX_tbl_project_issues_RaisedByEmployeeId; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX "IX_tbl_project_issues_RaisedByEmployeeId" ON project.tbl_project_issues USING btree ("RaisedByEmployeeId");


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
-- Name: ix_resource_alloc_req_approver; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX ix_resource_alloc_req_approver ON project.tbl_resource_allocation_requests USING btree ("ApproverEmployeeId");


--
-- Name: ix_resource_alloc_req_employee; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX ix_resource_alloc_req_employee ON project.tbl_resource_allocation_requests USING btree ("EmployeeId");


--
-- Name: ix_resource_alloc_req_project; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX ix_resource_alloc_req_project ON project.tbl_resource_allocation_requests USING btree ("ProjectId");


--
-- Name: ix_tbl_project_appreciations_project_id; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX ix_tbl_project_appreciations_project_id ON project.tbl_project_appreciations USING btree ("ProjectId");


--
-- Name: ix_tbl_project_appreciations_recipient_id; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX ix_tbl_project_appreciations_recipient_id ON project.tbl_project_appreciations USING btree ("RecipientEmployeeId");


--
-- Name: ix_tbl_project_feedbacks_employee_id; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX ix_tbl_project_feedbacks_employee_id ON project.tbl_project_feedbacks USING btree ("EmployeeId");


--
-- Name: ix_tbl_project_feedbacks_feedback_type; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX ix_tbl_project_feedbacks_feedback_type ON project.tbl_project_feedbacks USING btree ("FeedbackType");


--
-- Name: ix_tbl_project_feedbacks_project_id; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX ix_tbl_project_feedbacks_project_id ON project.tbl_project_feedbacks USING btree ("ProjectId");


--
-- Name: ix_tbl_project_feedbacks_reporting_manager_id; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX ix_tbl_project_feedbacks_reporting_manager_id ON project.tbl_project_feedbacks USING btree ("ReportingManagerId");


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
-- Name: ix_tbl_sla_events_hangfire_job_id; Type: INDEX; Schema: sla; Owner: -
--

CREATE INDEX ix_tbl_sla_events_hangfire_job_id ON sla.tbl_sla_events USING btree (hangfirejobid);


--
-- Name: ix_tbl_sla_events_instance_event_type; Type: INDEX; Schema: sla; Owner: -
--

CREATE INDEX ix_tbl_sla_events_instance_event_type ON sla.tbl_sla_events USING btree (instanceid, eventtype);


--
-- Name: ix_tbl_sla_events_scheduled_at; Type: INDEX; Schema: sla; Owner: -
--

CREATE INDEX ix_tbl_sla_events_scheduled_at ON sla.tbl_sla_events USING btree (scheduledatutc);


--
-- Name: ix_tbl_sla_events_status; Type: INDEX; Schema: sla; Owner: -
--

CREATE INDEX ix_tbl_sla_events_status ON sla.tbl_sla_events USING btree (status);


--
-- Name: ix_tbl_sla_instances_entity_activity_deleted; Type: INDEX; Schema: sla; Owner: -
--

CREATE INDEX ix_tbl_sla_instances_entity_activity_deleted ON sla.tbl_sla_instances USING btree (entityid, activitytype, deletedatutc);


--
-- Name: ix_tbl_sla_instances_project_id; Type: INDEX; Schema: sla; Owner: -
--

CREATE INDEX ix_tbl_sla_instances_project_id ON sla.tbl_sla_instances USING btree (projectid);


--
-- Name: ix_tbl_sla_instances_recipient_employee_id; Type: INDEX; Schema: sla; Owner: -
--

CREATE INDEX ix_tbl_sla_instances_recipient_employee_id ON sla.tbl_sla_instances USING btree (recipientemployeeid);


--
-- Name: ix_tbl_sla_instances_status; Type: INDEX; Schema: sla; Owner: -
--

CREATE INDEX ix_tbl_sla_instances_status ON sla.tbl_sla_instances USING btree (status);


--
-- Name: ix_tbl_sla_instances_target_deadline; Type: INDEX; Schema: sla; Owner: -
--

CREATE INDEX ix_tbl_sla_instances_target_deadline ON sla.tbl_sla_instances USING btree (targetdeadlineutc);


--
-- Name: ix_tbl_sla_policies_activity_type; Type: INDEX; Schema: sla; Owner: -
--

CREATE INDEX ix_tbl_sla_policies_activity_type ON sla.tbl_sla_policies USING btree (activitytype);


--
-- Name: ix_tbl_sla_policies_is_active; Type: INDEX; Schema: sla; Owner: -
--

CREATE INDEX ix_tbl_sla_policies_is_active ON sla.tbl_sla_policies USING btree (isactive);


--
-- Name: ix_tbl_sla_policies_module_activity_stage_deleted; Type: INDEX; Schema: sla; Owner: -
--

CREATE UNIQUE INDEX ix_tbl_sla_policies_module_activity_stage_deleted ON sla.tbl_sla_policies USING btree (module, activitytype, stage, deletedatutc);


--
-- Name: uq_sla_events_idempotency_key; Type: INDEX; Schema: sla; Owner: -
--

CREATE UNIQUE INDEX uq_sla_events_idempotency_key ON sla.tbl_sla_events USING btree (idempotencykey) WHERE ((idempotencykey IS NOT NULL) AND (deletedatutc IS NULL));


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
-- Name: tbl_role_permissions trg_protect_default_permissions; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER trg_protect_default_permissions BEFORE UPDATE ON auth.tbl_role_permissions FOR EACH ROW EXECUTE FUNCTION auth.fn_protect_default_permissions();


--
-- Name: tbl_bucket_tasks FK_tbl_bucket_tasks_tbl_employees_EmployeeId; Type: FK CONSTRAINT; Schema: action; Owner: -
--

ALTER TABLE ONLY action.tbl_bucket_tasks
    ADD CONSTRAINT "FK_tbl_bucket_tasks_tbl_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE RESTRICT;


--
-- Name: tbl_bucket_tasks FK_tbl_bucket_tasks_tbl_project_services_ProjectServiceId; Type: FK CONSTRAINT; Schema: action; Owner: -
--

ALTER TABLE ONLY action.tbl_bucket_tasks
    ADD CONSTRAINT "FK_tbl_bucket_tasks_tbl_project_services_ProjectServiceId" FOREIGN KEY ("ProjectServiceId") REFERENCES project.tbl_project_services("Id") ON DELETE SET NULL;


--
-- Name: tbl_bucket_tasks FK_tbl_bucket_tasks_tbl_project_task_assignments_AssignmentId; Type: FK CONSTRAINT; Schema: action; Owner: -
--

ALTER TABLE ONLY action.tbl_bucket_tasks
    ADD CONSTRAINT "FK_tbl_bucket_tasks_tbl_project_task_assignments_AssignmentId" FOREIGN KEY ("AssignmentId") REFERENCES project.tbl_project_task_assignments("Id") ON DELETE SET NULL;


--
-- Name: tbl_bucket_tasks FK_tbl_bucket_tasks_tbl_project_tasks_TaskId; Type: FK CONSTRAINT; Schema: action; Owner: -
--

ALTER TABLE ONLY action.tbl_bucket_tasks
    ADD CONSTRAINT "FK_tbl_bucket_tasks_tbl_project_tasks_TaskId" FOREIGN KEY ("TaskId") REFERENCES project.tbl_project_tasks("Id") ON DELETE CASCADE;


--
-- Name: tbl_bucket_tasks FK_tbl_bucket_tasks_tbl_projects_ProjectId; Type: FK CONSTRAINT; Schema: action; Owner: -
--

ALTER TABLE ONLY action.tbl_bucket_tasks
    ADD CONSTRAINT "FK_tbl_bucket_tasks_tbl_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_notifications FK_tbl_notifications_tbl_project_service_escalations; Type: FK CONSTRAINT; Schema: action; Owner: -
--

ALTER TABLE ONLY action.tbl_notifications
    ADD CONSTRAINT "FK_tbl_notifications_tbl_project_service_escalations" FOREIGN KEY ("ServiceEscalationId") REFERENCES project.tbl_project_service_escalations("Id") ON DELETE SET NULL;


--
-- Name: tbl_notifications fk_notifications_issue; Type: FK CONSTRAINT; Schema: action; Owner: -
--

ALTER TABLE ONLY action.tbl_notifications
    ADD CONSTRAINT fk_notifications_issue FOREIGN KEY ("IssueId") REFERENCES project.tbl_project_issues("Id") ON DELETE SET NULL;


--
-- Name: tbl_notifications fk_notifications_project; Type: FK CONSTRAINT; Schema: action; Owner: -
--

ALTER TABLE ONLY action.tbl_notifications
    ADD CONSTRAINT fk_notifications_project FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_notifications fk_notifications_recipient_employee; Type: FK CONSTRAINT; Schema: action; Owner: -
--

ALTER TABLE ONLY action.tbl_notifications
    ADD CONSTRAINT fk_notifications_recipient_employee FOREIGN KEY ("RecipientEmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE CASCADE;


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
-- Name: jobparameter jobparameter_jobid_fkey; Type: FK CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.jobparameter
    ADD CONSTRAINT jobparameter_jobid_fkey FOREIGN KEY (jobid) REFERENCES hangfire.job(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: state state_jobid_fkey; Type: FK CONSTRAINT; Schema: hangfire; Owner: -
--

ALTER TABLE ONLY hangfire.state
    ADD CONSTRAINT state_jobid_fkey FOREIGN KEY (jobid) REFERENCES hangfire.job(id) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: tbl_project_alerts FK_tbl_project_alerts_employees; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_alerts
    ADD CONSTRAINT "FK_tbl_project_alerts_employees" FOREIGN KEY ("RaisedByEmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE SET NULL;


--
-- Name: tbl_project_alerts FK_tbl_project_alerts_issues; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_alerts
    ADD CONSTRAINT "FK_tbl_project_alerts_issues" FOREIGN KEY ("IssueId") REFERENCES project.tbl_project_issues("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_alerts FK_tbl_project_alerts_projects; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_alerts
    ADD CONSTRAINT "FK_tbl_project_alerts_projects" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


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
-- Name: tbl_project_invoices FK_tbl_project_invoices_tbl_project_services_ProjectServiceId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_invoices
    ADD CONSTRAINT "FK_tbl_project_invoices_tbl_project_services_ProjectServiceId" FOREIGN KEY ("ProjectServiceId") REFERENCES project.tbl_project_services("Id") ON DELETE SET NULL;


--
-- Name: tbl_project_invoices FK_tbl_project_invoices_tbl_projects_ProjectId; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_invoices
    ADD CONSTRAINT "FK_tbl_project_invoices_tbl_projects_ProjectId" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_project_issues FK_tbl_project_issues_employees; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_issues
    ADD CONSTRAINT "FK_tbl_project_issues_employees" FOREIGN KEY ("RaisedByEmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE SET NULL;


--
-- Name: tbl_project_issues FK_tbl_project_issues_projects; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_issues
    ADD CONSTRAINT "FK_tbl_project_issues_projects" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


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
-- Name: tbl_project_additional_requirements tbl_project_additional_requirements_ProjectId_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_project_additional_requirements
    ADD CONSTRAINT "tbl_project_additional_requirements_ProjectId_fkey" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


--
-- Name: tbl_resource_allocation_requests tbl_resource_allocation_requests_DepartmentId_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_resource_allocation_requests
    ADD CONSTRAINT "tbl_resource_allocation_requests_DepartmentId_fkey" FOREIGN KEY ("DepartmentId") REFERENCES master.mst_departments("Id");


--
-- Name: tbl_resource_allocation_requests tbl_resource_allocation_requests_EmployeeId_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_resource_allocation_requests
    ADD CONSTRAINT "tbl_resource_allocation_requests_EmployeeId_fkey" FOREIGN KEY ("EmployeeId") REFERENCES resource.tbl_employees("Id") ON DELETE CASCADE;


--
-- Name: tbl_resource_allocation_requests tbl_resource_allocation_requests_ProjectId_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.tbl_resource_allocation_requests
    ADD CONSTRAINT "tbl_resource_allocation_requests_ProjectId_fkey" FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects("Id") ON DELETE CASCADE;


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
-- Name: tbl_sla_events tbl_sla_events_instanceid_fkey; Type: FK CONSTRAINT; Schema: sla; Owner: -
--

ALTER TABLE ONLY sla.tbl_sla_events
    ADD CONSTRAINT tbl_sla_events_instanceid_fkey FOREIGN KEY (instanceid) REFERENCES sla.tbl_sla_instances(id) ON DELETE CASCADE;


--
-- Name: tbl_sla_instances tbl_sla_instances_policyid_fkey; Type: FK CONSTRAINT; Schema: sla; Owner: -
--

ALTER TABLE ONLY sla.tbl_sla_instances
    ADD CONSTRAINT tbl_sla_instances_policyid_fkey FOREIGN KEY (policyid) REFERENCES sla.tbl_sla_policies(id) ON DELETE RESTRICT;


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


