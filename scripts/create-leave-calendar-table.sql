-- Leave Calendar Master table in master schema
-- Allows admin to enter full year holidays with name tag and color

CREATE TABLE IF NOT EXISTS master.mst_leave_calendar (
    "Id" uuid NOT NULL,
    "HolidayDate" date NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Tag" character varying(100) NOT NULL DEFAULT 'Public Holiday',
    "Color" character varying(50) NOT NULL DEFAULT '#a6c63a',
    "Description" character varying(500),
    "Year" integer NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL DEFAULT now(),
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_mst_leave_calendar" PRIMARY KEY ("Id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_leave_calendar_HolidayDate"
    ON master.mst_leave_calendar ("HolidayDate")
    WHERE ("DeletedAtUtc" IS NULL);

CREATE INDEX IF NOT EXISTS "IX_mst_leave_calendar_Year"
    ON master.mst_leave_calendar ("Year")
    WHERE ("DeletedAtUtc" IS NULL);

-- Seed standard 2026 holidays if none exist
INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000001', '2026-01-01', 'New Year''s Day', 'Optional Holiday', '#0ea5e9', 'First day of the new year', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-01-01' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000002', '2026-01-26', 'Republic Day', 'National Holiday', '#10b981', 'National holiday honoring the Constitution of India', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-01-26' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000003', '2026-03-03', 'Holi', 'Festival', '#ec4899', 'Festival of Colours', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-03-03' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000004', '2026-03-20', 'Id-ul-Fitr (Ramzan Eid)', 'Festival', '#8b5cf6', 'Islamic festival marking the end of Ramadan', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-03-20' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000005', '2026-04-03', 'Good Friday', 'Public Holiday', '#3b82f6', 'Christian holiday commemorating the crucifixion of Jesus', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-04-03' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000006', '2026-04-14', 'Dr. Ambedkar Jayanti', 'Public Holiday', '#6366f1', 'Birth anniversary of Dr. B. R. Ambedkar', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-04-14' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000007', '2026-05-01', 'Maharashtra Day / Labour Day', 'Regional Holiday', '#f59e0b', 'State holiday commemorating Maharashtra formation and International Workers Day', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-05-01' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000008', '2026-05-27', 'Bakrid / Id-ul-Zuha', 'Festival', '#8b5cf6', 'Feast of Sacrifice', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-05-27' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000009', '2026-08-15', 'Independence Day', 'National Holiday', '#10b981', 'Commemorating the nation independence', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-08-15' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000010', '2026-09-14', 'Ganesh Chaturthi', 'Festival', '#f97316', 'Festival honoring Lord Ganesha', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-09-14' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000011', '2026-10-02', 'Mahatma Gandhi Jayanti', 'National Holiday', '#10b981', 'Birth anniversary of Mahatma Gandhi', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-10-02' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000012', '2026-10-20', 'Dussehra (Vijaya Dashami)', 'Festival', '#ef4444', 'Celebration of victory of good over evil', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-10-20' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000013', '2026-11-08', 'Diwali (Laxmi Pujan)', 'Festival', '#eab308', 'Festival of Lights - Laxmi Pujan', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-11-08' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000014', '2026-11-09', 'Diwali (Govardhan Puja / Balipratipada)', 'Festival', '#f59e0b', 'Govardhan Puja and New Year celebration', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-11-09' AND "DeletedAtUtc" IS NULL);

INSERT INTO master.mst_leave_calendar ("Id", "HolidayDate", "Name", "Tag", "Color", "Description", "Year", "CreatedAtUtc")
SELECT '7a111111-0001-4000-8000-000000000015', '2026-12-25', 'Christmas', 'Public Holiday', '#10b981', 'Celebration of the birth of Jesus Christ', 2026, now()
WHERE NOT EXISTS (SELECT 1 FROM master.mst_leave_calendar WHERE "HolidayDate" = '2026-12-25' AND "DeletedAtUtc" IS NULL);

