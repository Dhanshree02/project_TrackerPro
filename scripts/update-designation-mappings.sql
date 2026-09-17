-- 1. Ensure SubDepartment column exists on mst_designations
ALTER TABLE mst_designations ADD COLUMN IF NOT EXISTS "SubDepartment" text;

-- 2. Upsert Departments
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc")
VALUES ('5fa16ecf-342c-52e5-8b13-47b2f65f3763', 'core', 'Core', true, NOW())
ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "IsActive" = true;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc")
VALUES ('5fb8f2e3-72ad-5599-8d05-11706c6a5df9', 'functional_it_administration', 'Functional - IT Administration', true, NOW())
ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "IsActive" = true;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc")
VALUES ('47e4f78d-401f-50c6-81b2-9267021aa357', 'functional_accounts', 'Functional - Accounts', true, NOW())
ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "IsActive" = true;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc")
VALUES ('21c031c0-be3d-5679-a21b-d3381c4bc682', 'functional_hr', 'Functional - HR', true, NOW())
ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "IsActive" = true;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc")
VALUES ('d59422ce-6059-5797-9266-6f0358f398c7', 'functional_sales', 'Functional - Sales', true, NOW())
ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "IsActive" = true;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc")
VALUES ('ad12dd1e-96dd-5876-84e7-e00c363923c8', 'functional_project_management', 'Functional - Project Management', true, NOW())
ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "IsActive" = true;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc")
VALUES ('3ea3b0e1-36d6-513a-980d-0af1aa804007', 'rd_research_and_development', 'R&D (Research & Development)', true, NOW())
ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "IsActive" = true;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc")
VALUES ('b299fef3-4a47-541d-9b9e-fbfa63d26e39', 'services_operations', 'Services - Operations', true, NOW())
ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "IsActive" = true;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc")
VALUES ('e37634df-e9a5-56f8-9f4c-67cfc53dfc50', 'services_consulting', 'Services - Consulting', true, NOW())
ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "IsActive" = true;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc")
VALUES ('0aeea7f2-d637-5ea3-a46d-9b7c88c71361', 'services_testing', 'Services - Testing', true, NOW())
ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "IsActive" = true;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc")
VALUES ('5385e39f-9bc4-5e4d-9926-d6d555cbdd3b', 'internship_program', 'Internship Program', true, NOW())
ON CONFLICT ("Code") DO UPDATE SET "Name" = EXCLUDED."Name", "IsActive" = true;

-- 3. Upsert Designations and link Roles
-- Director and Chief Executive Officer (Core)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'f00bacfa-347b-548d-810c-c1999813b987', 'core_director_and_chief_executive_officer', 'Director and Chief Executive Officer', true, d."Id", 'Leading Sales & A/C Dept.', NOW()
FROM mst_departments d WHERE d."Name" = 'Core'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '1b3c5571-9d4d-523e-a9c9-34327c4efc26', 'r_core_director_and_chief_executive_officer_leader_l', 'Leader (L)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Director and Chief Executive Officer' AND dept."Name" = 'Core'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Director and Chief Operating Officer (Core)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '4cd69f28-8a17-5f09-bd8f-4288e50903f6', 'core_director_and_chief_operating_officer', 'Director and Chief Operating Officer', true, d."Id", 'Leading Delivery Dept.', NOW()
FROM mst_departments d WHERE d."Name" = 'Core'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '65fc5ce4-d81d-5818-a13a-78f12d22efc7', 'r_core_director_and_chief_operating_officer_leader_l', 'Leader (L)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Director and Chief Operating Officer' AND dept."Name" = 'Core'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Director and Chief Technology Officer (Core)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'b64d56b5-f629-5fce-a41c-7cde896eced6', 'core_director_and_chief_technology_officer', 'Director and Chief Technology Officer', true, d."Id", 'Leading Compliance & HR Dept.', NOW()
FROM mst_departments d WHERE d."Name" = 'Core'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '1ccf28e2-bb70-5fe6-854c-0b4e9bdd143f', 'r_core_director_and_chief_technology_officer_leader_l', 'Leader (L)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Director and Chief Technology Officer' AND dept."Name" = 'Core'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- IT Admin (Functional - IT Administration)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'ee3b9dab-50dd-5ac9-aea3-afff3d0e48fb', 'functional_it_admini_it_admin', 'IT Admin', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - IT Administration'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'c3d65449-f8dd-5093-98d3-36843f463eae', 'r_functional_it_admini_it_admin_it_admin', 'IT Admin', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'IT Admin' AND dept."Name" = 'Functional - IT Administration'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Desktop Support Engineer - I (Functional - IT Administration)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'eaaecd56-6d3f-5b73-91d8-10fd03e011ae', 'functional_it_admini_desktop_support_engineer_i', 'Desktop Support Engineer - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - IT Administration'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'f2219a2b-284e-5daa-a66a-513c583e1e17', 'r_functional_it_admini_desktop_support_engineer_i_it_admin', 'IT Admin', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Desktop Support Engineer - I' AND dept."Name" = 'Functional - IT Administration'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Desktop Support Engineer - II (Functional - IT Administration)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '1ddce494-28e8-580d-83d4-8bc1ee1bafc4', 'functional_it_admini_desktop_support_engineer_ii', 'Desktop Support Engineer - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - IT Administration'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'b45c1f54-9fff-5604-9d02-215cbedc0ee9', 'r_functional_it_admini_desktop_support_engineer_ii_it_admin', 'IT Admin', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Desktop Support Engineer - II' AND dept."Name" = 'Functional - IT Administration'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Accountant - I (Functional - Accounts)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '1e1eb200-7ddf-546b-9135-bed43f23231b', 'functional_accounts_accountant_i', 'Accountant - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Accounts'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '8f8f9619-91ff-5733-bc69-f8a04af4c551', 'r_functional_accounts_accountant_i_accounts', 'Accounts', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Accountant - I' AND dept."Name" = 'Functional - Accounts'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Accountant - II (Functional - Accounts)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '0355d23c-cc7b-56e0-adeb-99cec952d4c7', 'functional_accounts_accountant_ii', 'Accountant - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Accounts'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'c495399a-1f21-5360-a1a3-81ed88516acb', 'r_functional_accounts_accountant_ii_accounts', 'Accounts', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Accountant - II' AND dept."Name" = 'Functional - Accounts'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Accountant - III (Functional - Accounts)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '1b9645c6-9e3c-54ec-8a60-05ba7a4dbab2', 'functional_accounts_accountant_iii', 'Accountant - III', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Accounts'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'dd7b8cbf-bf04-5c42-acef-404eb128b7a2', 'r_functional_accounts_accountant_iii_accounts', 'Accounts', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Accountant - III' AND dept."Name" = 'Functional - Accounts'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior Accountant - I (Functional - Accounts)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'd42602ce-25ff-553f-ac69-faf3b8a684f6', 'functional_accounts_senior_accountant_i', 'Senior Accountant - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Accounts'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '00081046-1765-57c9-a320-d31929adafbd', 'r_functional_accounts_senior_accountant_i_accounts', 'Accounts', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior Accountant - I' AND dept."Name" = 'Functional - Accounts'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior Accountant - II (Functional - Accounts)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'b638a9d9-25e3-5cb9-a9e3-52f157c508e7', 'functional_accounts_senior_accountant_ii', 'Senior Accountant - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Accounts'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'ecb68998-d948-5d9e-bd98-76084fc24f79', 'r_functional_accounts_senior_accountant_ii_accounts', 'Accounts', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior Accountant - II' AND dept."Name" = 'Functional - Accounts'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior Accountant - III (Functional - Accounts)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'f55e6bcd-5d3c-5ebe-bec0-94f6a068f697', 'functional_accounts_senior_accountant_iii', 'Senior Accountant - III', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Accounts'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'f04a3ab9-5075-515b-b640-7429e5aa82f3', 'r_functional_accounts_senior_accountant_iii_accounts', 'Accounts', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior Accountant - III' AND dept."Name" = 'Functional - Accounts'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- HR Head (Functional - HR)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '1953f154-013d-5139-8f89-ab80ae21696e', 'functional_hr_hr_head', 'HR Head', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - HR'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '6c18b0fb-063d-5693-8e45-f9f053c8e788', 'r_functional_hr_hr_head_hr', 'HR', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'HR Head' AND dept."Name" = 'Functional - HR'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Recruitment Coordinator - I (Functional - HR)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '6201f23b-d19e-596c-99e9-b5fd69594640', 'functional_hr_recruitment_coordinator_i', 'Recruitment Coordinator - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - HR'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '04e56153-6545-5a9a-91fc-fb59e2c4a4fe', 'r_functional_hr_recruitment_coordinator_i_hr', 'HR', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Recruitment Coordinator - I' AND dept."Name" = 'Functional - HR'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Recruitment Coordinator - II (Functional - HR)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '1a4cc70e-51cb-5752-9b8d-6449d665cf74', 'functional_hr_recruitment_coordinator_ii', 'Recruitment Coordinator - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - HR'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'cfcf8340-7942-57f9-bfa7-50a151df57a1', 'r_functional_hr_recruitment_coordinator_ii_hr', 'HR', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Recruitment Coordinator - II' AND dept."Name" = 'Functional - HR'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior HR Executive - I (Functional - HR)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'b3791933-82b8-5e41-a2c2-53a444cc00a8', 'functional_hr_senior_hr_executive_i', 'Senior HR Executive - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - HR'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '03e04116-1b0a-59cb-91c1-816abc14bf60', 'r_functional_hr_senior_hr_executive_i_hr', 'HR', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior HR Executive - I' AND dept."Name" = 'Functional - HR'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior HR Executive - II (Functional - HR)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'dea9a8f5-82fe-560b-9d59-ea74c175a219', 'functional_hr_senior_hr_executive_ii', 'Senior HR Executive - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - HR'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '484d8507-5c97-546a-aca0-dc31f4aea506', 'r_functional_hr_senior_hr_executive_ii_hr', 'HR', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior HR Executive - II' AND dept."Name" = 'Functional - HR'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Business Development Associate - I (Functional - Sales)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '45faa8d2-78c5-5a9b-ad83-90b53e0e647b', 'functional_sales_business_development_associate_i', 'Business Development Associate - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Sales'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '85971525-1397-5e04-8c14-1e7e4e89ecab', 'r_functional_sales_business_development_associate_i_sales_manger', 'Sales Manger', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Business Development Associate - I' AND dept."Name" = 'Functional - Sales'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Customer Success Representative - II (Functional - Sales)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '19593d72-0584-5321-9b4e-61a150c2df81', 'functional_sales_customer_success_representative_ii', 'Customer Success Representative - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Sales'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'e6c6b449-b21a-5b6e-99f6-e6c6d58412b0', 'r_functional_sales_customer_success_representative_ii_sales_manger', 'Sales Manger', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Customer Success Representative - II' AND dept."Name" = 'Functional - Sales'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Director - Product Sales (Functional - Sales)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '671a4ae3-de6a-5e39-839b-21e38d29f281', 'functional_sales_director_product_sales', 'Director - Product Sales', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Sales'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '5ac380d9-f40f-50e9-aee8-85e0f631e3e4', 'r_functional_sales_director_product_sales_sales_team_memb', 'Sales team member', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Director - Product Sales' AND dept."Name" = 'Functional - Sales'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Sales Associate (Functional - Sales)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'cca1dd34-9c20-53a3-8894-364aba246142', 'functional_sales_sales_associate', 'Sales Associate', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Sales'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '2ee5ea1e-189e-5c7a-8f9b-c9afd4af6d84', 'r_functional_sales_sales_associate_sales_team_memb', 'Sales team member', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Sales Associate' AND dept."Name" = 'Functional - Sales'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Associate Customer Success Representative - I (Functional - Sales)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '7b6c324b-9c82-5fdf-8a6b-c80fe508cdde', 'functional_sales_associate_customer_success_representative_i', 'Associate Customer Success Representative - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Sales'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '6c2ade52-7123-5043-b31d-be824508a140', 'r_functional_sales_associate_customer_success_representative_i_sales_team_memb', 'Sales team member', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Associate Customer Success Representative - I' AND dept."Name" = 'Functional - Sales'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Associate Customer Success Representative - II (Functional - Sales)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'c7a814c0-e55c-56fa-951d-9eab643bc550', 'functional_sales_associate_customer_success_representative_ii', 'Associate Customer Success Representative - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Sales'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '30fd7f90-b74f-5d6f-ab02-ad08521eaff4', 'r_functional_sales_associate_customer_success_representative_i_sales_team__1', 'Sales team member', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Associate Customer Success Representative - II' AND dept."Name" = 'Functional - Sales'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Associate PMO - I (Functional - Project Management)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '646bc94e-146f-54a5-8878-0064b6010124', 'functional_project_m_associate_pmo_i', 'Associate PMO - I', true, d."Id", 'PMO (Project Management Office)', NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Project Management'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'd576d8b7-1719-5d12-97cf-2b052f07977c', 'r_functional_project_m_associate_pmo_i_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Associate PMO - I' AND dept."Name" = 'Functional - Project Management'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Associate PMO - II (Functional - Project Management)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'b913bf38-cfcc-5cb5-9cff-6929610d6fc6', 'functional_project_m_associate_pmo_ii', 'Associate PMO - II', true, d."Id", 'PMO (Project Management Office)', NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Project Management'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '63166ffb-e72d-5f97-8b5e-45290de3c7b4', 'r_functional_project_m_associate_pmo_ii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Associate PMO - II' AND dept."Name" = 'Functional - Project Management'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior PMO - I (Functional - Project Management)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '7657434b-602f-56c8-9e0a-fd157fdac5c5', 'functional_project_m_senior_pmo_i', 'Senior PMO - I', true, d."Id", 'PMO (Project Management Office)', NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Project Management'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '0c9ac4b8-0e4f-548a-9c95-facc1613669c', 'r_functional_project_m_senior_pmo_i_team_leader_tl', 'Team Leader (TL)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior PMO - I' AND dept."Name" = 'Functional - Project Management'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior PMO - II (Functional - Project Management)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'bf4881b5-dcd5-5880-a001-067d17350441', 'functional_project_m_senior_pmo_ii', 'Senior PMO - II', true, d."Id", 'PMO (Project Management Office)', NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Project Management'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'ed6683ea-dd34-599f-b831-b36ff4ce6186', 'r_functional_project_m_senior_pmo_ii_manager_mng', 'Manager (Mng.)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior PMO - II' AND dept."Name" = 'Functional - Project Management'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Delivery Account Manager - I (Functional - Project Management)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '6a77159f-216c-5aa4-afee-75d369df66d7', 'functional_project_m_delivery_account_manager_i', 'Delivery Account Manager - I', true, d."Id", 'EM (Engagement Manager)', NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Project Management'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '3e19f87d-0997-530b-a07b-142f81d8f58e', 'r_functional_project_m_delivery_account_manager_i_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Delivery Account Manager - I' AND dept."Name" = 'Functional - Project Management'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Delivery Account Manager - II (Functional - Project Management)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '3fc8a34b-540d-5988-a966-ceb35632cb6c', 'functional_project_m_delivery_account_manager_ii', 'Delivery Account Manager - II', true, d."Id", 'EM (Engagement Manager)', NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Project Management'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '5f339123-b8f5-5a11-965a-83f9ee3cb67f', 'r_functional_project_m_delivery_account_manager_ii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Delivery Account Manager - II' AND dept."Name" = 'Functional - Project Management'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior Delivery Account Manager - I (Functional - Project Management)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '6e4fa67a-a1ee-55c4-9880-d5434dda4993', 'functional_project_m_senior_delivery_account_manager_i', 'Senior Delivery Account Manager - I', true, d."Id", 'EM (Engagement Manager)', NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Project Management'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '14f76de6-3cf8-5e5c-8b53-5ebecd5b5a56', 'r_functional_project_m_senior_delivery_account_manager_i_team_leader_tl', 'Team Leader (TL)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior Delivery Account Manager - I' AND dept."Name" = 'Functional - Project Management'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior Delivery Account Manager - II (Functional - Project Management)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'd991d416-b7c2-57f0-9447-0d174193f367', 'functional_project_m_senior_delivery_account_manager_ii', 'Senior Delivery Account Manager - II', true, d."Id", 'EM (Engagement Manager)', NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Project Management'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '72fad4b7-7294-529d-a166-c04192fb9b8b', 'r_functional_project_m_senior_delivery_account_manager_ii_manager_mng', 'Manager (Mng.)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior Delivery Account Manager - II' AND dept."Name" = 'Functional - Project Management'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Python Developer - I (R&D (Research & Development))
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '20fa7f21-1900-5fb2-8a86-1ddde40c19ea', 'r_d_research_develop_python_developer_i', 'Python Developer - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'R&D (Research & Development)'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '08f5aefe-1c23-5cb9-8f09-71ffe7d5f61b', 'r_r_d_research_develop_python_developer_i_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Python Developer - I' AND dept."Name" = 'R&D (Research & Development)'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Python Developer - II (R&D (Research & Development))
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '0af2155b-3b98-5c87-aeec-0bf38e8b110f', 'r_d_research_develop_python_developer_ii', 'Python Developer - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'R&D (Research & Development)'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '465e39ab-c119-5d9e-9fe2-f22d9ab34b8a', 'r_r_d_research_develop_python_developer_ii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Python Developer - II' AND dept."Name" = 'R&D (Research & Development)'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Python Developer - III (R&D (Research & Development))
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '3cb7d9e6-5689-5bb5-876e-22518eca6b4a', 'r_d_research_develop_python_developer_iii', 'Python Developer - III', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'R&D (Research & Development)'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '3e04099b-2a7f-5508-ad95-119609f87d6b', 'r_r_d_research_develop_python_developer_iii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Python Developer - III' AND dept."Name" = 'R&D (Research & Development)'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SOC Analyst - I (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '6cff2f3c-1038-52e3-99fb-b23ea1f4709a', 'services_operations_soc_analyst_i', 'SOC Analyst - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '7150e1a7-a0ac-5cdb-b1cf-87710275f91e', 'r_services_operations_soc_analyst_i_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SOC Analyst - I' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SOC Analyst - II (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '99d02910-af98-5c3b-9e22-a930f2d97952', 'services_operations_soc_analyst_ii', 'SOC Analyst - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'ceee480e-04df-52f2-a52c-dd43a3d11ee2', 'r_services_operations_soc_analyst_ii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SOC Analyst - II' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SOC Analyst - III (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '0dcfb975-e9a1-54ae-8140-02af43d257d9', 'services_operations_soc_analyst_iii', 'SOC Analyst - III', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'b1bf0c7f-6672-5315-926d-579d79a1d329', 'r_services_operations_soc_analyst_iii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SOC Analyst - III' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SOC Analyst - IV (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '12eb4921-f6ab-5009-9596-03f0061e4ea9', 'services_operations_soc_analyst_iv', 'SOC Analyst - IV', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '6e6b070e-0222-554f-9fa0-6ddcf1946824', 'r_services_operations_soc_analyst_iv_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SOC Analyst - IV' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SIEM Admin - I (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '078fb97c-e464-5df4-98be-04b733ce6444', 'services_operations_siem_admin_i', 'SIEM Admin - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '60eca61d-6443-5862-81d9-f8c257d199ae', 'r_services_operations_siem_admin_i_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SIEM Admin - I' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SIEM Admin - II (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'a4cc318a-546a-5780-8af1-205c80938a2b', 'services_operations_siem_admin_ii', 'SIEM Admin - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '31b27d19-6537-597f-85f6-e932cad90e06', 'r_services_operations_siem_admin_ii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SIEM Admin - II' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SIEM Admin - III (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'bb18099b-b9a7-5fd6-af43-be1b6594899f', 'services_operations_siem_admin_iii', 'SIEM Admin - III', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'e9937015-1bb3-5ac5-b3e0-9dc4ec82b3c8', 'r_services_operations_siem_admin_iii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SIEM Admin - III' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SIEM Admin - IV (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'ce37a14e-ddae-5723-b7f3-e9d91a0ee6a9', 'services_operations_siem_admin_iv', 'SIEM Admin - IV', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '907bfa12-c952-5ae3-a0c1-68d239642f92', 'r_services_operations_siem_admin_iv_team_leader_tl', 'Team Leader (TL)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SIEM Admin - IV' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SOC Consultant - I (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'b6bc402c-4ec1-596d-b161-806000fa7e80', 'services_operations_soc_consultant_i', 'SOC Consultant - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '3228805d-8ab4-5e91-bd08-db676d211fcb', 'r_services_operations_soc_consultant_i_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SOC Consultant - I' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SOC Consultant - II (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'a814a0c7-ead8-5cfb-a5d9-52734dd8f79d', 'services_operations_soc_consultant_ii', 'SOC Consultant - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '466440fd-b79e-505a-8b77-8b689b328a66', 'r_services_operations_soc_consultant_ii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SOC Consultant - II' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SOC Shift Lead - I (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '7ac86a75-6c78-520f-9715-a9ffbb6b67fc', 'services_operations_soc_shift_lead_i', 'SOC Shift Lead - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'c92f885e-8b1b-5e1f-9298-1c275f553e8f', 'r_services_operations_soc_shift_lead_i_team_leader_tl', 'Team Leader (TL)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SOC Shift Lead - I' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SOC Shift Lead - II (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '9fcd7288-c833-5c62-8f91-bebef7b69946', 'services_operations_soc_shift_lead_ii', 'SOC Shift Lead - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '6f1be6ae-8e0b-5b50-afc4-67a669338fb5', 'r_services_operations_soc_shift_lead_ii_team_leader_tl', 'Team Leader (TL)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SOC Shift Lead - II' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SOC Lead - I (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '655da8d6-d563-54dc-b2a0-d7fd53be7144', 'services_operations_soc_lead_i', 'SOC Lead - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '33258cff-d78f-5da9-9f7d-e7336fda2e63', 'r_services_operations_soc_lead_i_project_manager', 'Project Manager', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SOC Lead - I' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- SOC Lead - II (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'e1a164f6-2186-582c-b282-5b6423432d02', 'services_operations_soc_lead_ii', 'SOC Lead - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '082af918-a1a8-5b85-883f-91c0f6b50d16', 'r_services_operations_soc_lead_ii_sr_manager_sr_m', 'Sr. Manager (Sr.Mng.)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'SOC Lead - II' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Principal Manager - I (Services - Operations)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'd44c4cae-8b8b-5d55-b510-ae216e72bc26', 'services_operations_principal_manager_i', 'Principal Manager - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Operations'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'e8f39646-823f-5fbf-a9c1-83ba720ff103', 'r_services_operations_principal_manager_i_head_of_departm', 'Head Of Department (HOD)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Principal Manager - I' AND dept."Name" = 'Services - Operations'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- GRC Auditor - I (Services - Consulting)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'ae6f48bc-ce07-54f2-baee-d098004b05c8', 'services_consulting_grc_auditor_i', 'GRC Auditor - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Consulting'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '3ef42444-c6ff-58c0-a3fc-e4192dd90e8d', 'r_services_consulting_grc_auditor_i_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'GRC Auditor - I' AND dept."Name" = 'Services - Consulting'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- GRC Auditor - II (Services - Consulting)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'a1d0d4c4-f853-58f9-8237-322b7e5c57f5', 'services_consulting_grc_auditor_ii', 'GRC Auditor - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Consulting'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '96f73221-1dcd-5b2f-9d58-89dfa8d34592', 'r_services_consulting_grc_auditor_ii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'GRC Auditor - II' AND dept."Name" = 'Services - Consulting'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- GRC Auditor - III (Services - Consulting)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'a980966d-9531-53dc-92ea-37ddba43e4e8', 'services_consulting_grc_auditor_iii', 'GRC Auditor - III', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Consulting'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '0a086d55-93f8-584b-b758-40cdffcec87e', 'r_services_consulting_grc_auditor_iii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'GRC Auditor - III' AND dept."Name" = 'Services - Consulting'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- GRC Auditor - IV (Services - Consulting)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '5693a75e-9765-5966-8c43-f12244f03521', 'services_consulting_grc_auditor_iv', 'GRC Auditor - IV', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Consulting'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '2e1e7830-06e0-5a83-8a4f-e5e50869f1ed', 'r_services_consulting_grc_auditor_iv_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'GRC Auditor - IV' AND dept."Name" = 'Services - Consulting'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior GRC Auditor - I (Services - Consulting)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'b0a9ea51-7889-5152-9fd0-34d8e371a057', 'services_consulting_senior_grc_auditor_i', 'Senior GRC Auditor - I', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Consulting'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '03531b73-2375-5a75-bf8d-0983d3f09fed', 'r_services_consulting_senior_grc_auditor_i_team_leader_tl', 'Team Leader (TL)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior GRC Auditor - I' AND dept."Name" = 'Services - Consulting'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior GRC Auditor - II (Services - Consulting)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '5d7f6cd9-57e5-5bff-a2ea-8ff143d81aa2', 'services_consulting_senior_grc_auditor_ii', 'Senior GRC Auditor - II', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Consulting'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '28f79e27-f3f8-5615-9092-c226e052ae10', 'r_services_consulting_senior_grc_auditor_ii_team_leader_tl', 'Team Leader (TL)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior GRC Auditor - II' AND dept."Name" = 'Services - Consulting'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Associate Manager - III (Services - Consulting)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'dac3512e-1e9b-5413-9274-771336b70a17', 'services_consulting_associate_manager_iii', 'Associate Manager - III', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Consulting'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'e598697f-9348-5f78-a344-8e4a7c3c3e6c', 'r_services_consulting_associate_manager_iii_manager_mng', 'Manager (Mng.)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Associate Manager - III' AND dept."Name" = 'Services - Consulting'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior Vice President - Principal Consultant (Services - Consulting)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'bfe79800-3880-5b3f-a622-4703facac2e6', 'services_consulting_senior_vice_president_principal_consultant', 'Senior Vice President - Principal Consultant', true, d."Id", NULL, NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Consulting'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'b913dc33-c6e4-58b3-aa50-865cfe6e7e00', 'r_services_consulting_senior_vice_president_principal_consulta_head_of_departm', 'Head Of Department (HOD)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior Vice President - Principal Consultant' AND dept."Name" = 'Services - Consulting'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- PenTester - I (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '10e3198a-c099-51cf-ba51-e91a3c752651', 'services_testing_pentester_i', 'PenTester - I', true, d."Id", 'Service - Testing - AppSec,, Service - Testing - Mobile,, Service - Testing - Infra', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'fee5793c-896c-5975-ad83-a2dd8cc5c865', 'r_services_testing_pentester_i_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'PenTester - I' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- PenTester - II (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'd2815c4e-e045-50ca-8736-8cbd5418f19d', 'services_testing_pentester_ii', 'PenTester - II', true, d."Id", 'Service - Testing - AppSec,, Service - Testing - Mobile,, Service - Testing - Infra', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '18d8ff9d-2fa8-5744-8bc9-e98f03da676a', 'r_services_testing_pentester_ii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'PenTester - II' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- PenTester - III (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '02650639-9582-5cf9-bcc6-d72c7ca78198', 'services_testing_pentester_iii', 'PenTester - III', true, d."Id", 'Service - Testing - AppSec,, Service - Testing - Mobile,, Service - Testing - Infra', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'ef662994-8ebe-5cf7-8c8a-bb5792eb973c', 'r_services_testing_pentester_iii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'PenTester - III' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- PenTester - IV (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '3751b3ae-9206-5cfb-8a93-b68c6a33cdec', 'services_testing_pentester_iv', 'PenTester - IV', true, d."Id", 'Service - Testing - AppSec,, Service - Testing - Mobile,, Service - Testing - Infra', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '128ef222-24e6-549b-acab-1159e2fdafe6', 'r_services_testing_pentester_iv_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'PenTester - IV' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior Pentester - I (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '4b18ae92-55ff-5cde-a6ca-7d07e0f40da6', 'services_testing_senior_pentester_i', 'Senior Pentester - I', true, d."Id", 'Service - Testing - AppSec,, Service - Testing - Mobile,, Service - Testing - Infra', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'b48d8558-3c02-522e-bc90-0853a846b4f2', 'r_services_testing_senior_pentester_i_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior Pentester - I' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior Pentester - II (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'd6e0183e-fba6-532c-9241-a67456f8752a', 'services_testing_senior_pentester_ii', 'Senior Pentester - II', true, d."Id", 'Service - Testing - AppSec,, Service - Testing - Mobile,, Service - Testing - Infra', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'd25a8b8b-3d9f-58b7-b006-34f5dd0dc6ee', 'r_services_testing_senior_pentester_ii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior Pentester - II' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Associate Manager - I (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '3dec54e4-7ddf-56d3-aaa1-0c10c0dec531', 'services_testing_associate_manager_i', 'Associate Manager - I', true, d."Id", 'Service - Testing - AppSec,, Service - Testing - Mobile,, Service - Testing - Infra', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'e9a49f9d-a66b-5671-8b5f-d6acc31cd1b9', 'r_services_testing_associate_manager_i_team_leader_tl', 'Team Leader (TL)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Associate Manager - I' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Associate Manager - II (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '9fa4f03b-32f3-50af-8fa0-3bc3614ae50b', 'services_testing_associate_manager_ii', 'Associate Manager - II', true, d."Id", 'Service - Testing - AppSec,, Service - Testing - Mobile,, Service - Testing - Infra', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '6c01e1c4-9d4f-59ac-bb9f-4e4f6e10950a', 'r_services_testing_associate_manager_ii_team_leader_tl', 'Team Leader (TL)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Associate Manager - II' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Associate Manager - III (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '2802c585-06b0-5c18-b7ea-f6e83f1405cd', 'services_testing_associate_manager_iii', 'Associate Manager - III', true, d."Id", 'Service - Testing - AppSec,, Service - Testing - Mobile,, Service - Testing - Infra', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '89b315ea-303b-5066-92cc-4197b899d043', 'r_services_testing_associate_manager_iii_team_leader_tl', 'Team Leader (TL)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Associate Manager - III' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Associate Project Manager (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '80fdfc61-79c0-5fb0-a9c8-277ebdb24fa2', 'services_testing_associate_project_manager', 'Associate Project Manager', true, d."Id", 'Service - Testing - AppSec,, Service - Testing - Mobile,, Service - Testing - Infra', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'e95e37d1-6225-5789-9c0c-429709a6573c', 'r_services_testing_associate_project_manager_manager_mng', 'Manager (Mng.)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Associate Project Manager' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Manager - I (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '4040a063-451a-52af-8942-ad1853837639', 'services_testing_manager_i', 'Manager - I', true, d."Id", 'Service - Testing - AppSec,, Service - Testing - Mobile,, Service - Testing - Infra', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '1c6cf3be-f242-546c-9eb2-dfbd19e76426', 'r_services_testing_manager_i_sr_manager_sr_m', 'Sr. Manager (Sr.Mng.)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Manager - I' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- DevSecOps Practitioner - I (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '660c9a62-8c1c-504e-ada6-b3ff5c0787ba', 'services_testing_devsecops_practitioner_i', 'DevSecOps Practitioner - I', true, d."Id", 'Services - Testing - DevSecOps', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '16c3fdcb-4231-5643-9c63-60b1b7621f10', 'r_services_testing_devsecops_practitioner_i_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'DevSecOps Practitioner - I' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- DevSecOps Practitioner - II (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '90e3e144-b36d-5b53-98ec-4f21bfcfd4fd', 'services_testing_devsecops_practitioner_ii', 'DevSecOps Practitioner - II', true, d."Id", 'Services - Testing - DevSecOps', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'e8c94988-1ece-5906-87ec-8bf403a0f3ea', 'r_services_testing_devsecops_practitioner_ii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'DevSecOps Practitioner - II' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- DevSecOps Practitioner - III (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'd9559182-7062-5c10-ba0e-fe29c5ec301b', 'services_testing_devsecops_practitioner_iii', 'DevSecOps Practitioner - III', true, d."Id", 'Services - Testing - DevSecOps', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '9936ca2e-3b90-52cb-a6b3-e09ae363daf0', 'r_services_testing_devsecops_practitioner_iii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'DevSecOps Practitioner - III' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- DevSecOps Associate (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '1722b875-9952-565f-b1ba-eb9e27f4e83a', 'services_testing_devsecops_associate', 'DevSecOps Associate', true, d."Id", 'Services - Testing - DevSecOps', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '398d684e-b320-5a50-973e-ffd122a6c473', 'r_services_testing_devsecops_associate_team_leader_tl', 'Team Leader (TL)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'DevSecOps Associate' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- DevSecOps Specialist - II (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '6c6a533e-6cf9-5405-bf94-2e1329e908fa', 'services_testing_devsecops_specialist_ii', 'DevSecOps Specialist - II', true, d."Id", 'Services - Testing - DevSecOps', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'af82255e-5c41-5a04-940e-aacbd0553d0a', 'r_services_testing_devsecops_specialist_ii_manager_mng', 'Manager (Mng.)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'DevSecOps Specialist - II' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Red Team Practitioner - II (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'd4101460-1530-550f-bb9f-17201cdb5e3c', 'services_testing_red_team_practitioner_ii', 'Red Team Practitioner - II', true, d."Id", 'Services - Testing - Red Team', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '13a042e8-1158-56a5-9344-e46934968e49', 'r_services_testing_red_team_practitioner_ii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Red Team Practitioner - II' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Red Team Practitioner - III (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'f58260f9-5792-57a7-9156-acb4efd225ea', 'services_testing_red_team_practitioner_iii', 'Red Team Practitioner - III', true, d."Id", 'Services - Testing - Red Team', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '79644c1a-de9d-52a2-9d9b-00c2c08397ac', 'r_services_testing_red_team_practitioner_iii_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Red Team Practitioner - III' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Red Team Specialist - II (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'ae33a1a0-7a18-5d90-a71f-c9a132202a40', 'services_testing_red_team_specialist_ii', 'Red Team Specialist - II', true, d."Id", 'Services - Testing - Red Team', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '632b4073-e68d-503d-bb26-60d624fedea7', 'r_services_testing_red_team_specialist_ii_manager_mng', 'Manager (Mng.)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Red Team Specialist - II' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Senior Cloud Security Consultant - I (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '24eb764f-d62b-558f-a331-72f0659482e8', 'services_testing_senior_cloud_security_consultant_i', 'Senior Cloud Security Consultant - I', true, d."Id", 'Services - Testing - Cloud & AI', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'e615dd26-db92-5017-b5ac-5e0fe0738a42', 'r_services_testing_senior_cloud_security_consultant_i_manager_mng', 'Manager (Mng.)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Senior Cloud Security Consultant - I' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Associate AI Engineer - Contractual (Services - Testing)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT '65ef529d-59d8-5708-bf0e-d44dae117c76', 'services_testing_associate_ai_engineer_contractual', 'Associate AI Engineer - Contractual', true, d."Id", 'Services - Testing - Cloud & AI', NOW()
FROM mst_departments d WHERE d."Name" = 'Services - Testing'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT 'c8afd795-d35c-5abc-87f5-732c554b7145', 'r_services_testing_associate_ai_engineer_contractual_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Associate AI Engineer - Contractual' AND dept."Name" = 'Services - Testing'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Intern (Internship Program)
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'b0b7c9ec-0885-5092-aded-86055a7ad55c', 'internship_program_intern', 'Intern', true, d."Id", 'Across all Sub Departments', NOW()
FROM mst_departments d WHERE d."Name" = 'Internship Program'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET
  "SubDepartment" = EXCLUDED."SubDepartment",
  "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '18fd966d-a36e-5169-a72f-9f0489aaf33e', 'r_internship_program_intern_team_member_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des 
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Intern' AND dept."Name" = 'Internship Program'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- Ensure existing Engagement Manager designation has SubDepartment
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "SubDepartment", "CreatedAtUtc")
SELECT 'a969448b-1889-573f-89d5-746897c57dc1', 'func_pm_engagement_manager', 'Engagement Manager', true, d."Id", 'EM (Engagement Manager)', NOW()
FROM mst_departments d WHERE d."Name" = 'Functional - Project Management'
ON CONFLICT ("DepartmentId", "Name") DO UPDATE SET "SubDepartment" = 'EM (Engagement Manager)', "IsActive" = true;

INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc")
SELECT '6989d9c6-31fb-572a-ab25-33f095869d01', 'r_em_tm', 'Team Member (TM)', true, des."Id", NOW()
FROM mst_designations des
JOIN mst_departments dept ON des."DepartmentId" = dept."Id"
WHERE des."Name" = 'Engagement Manager' AND dept."Name" = 'Functional - Project Management'
ON CONFLICT ("DesignationId", "Name") DO UPDATE SET "IsActive" = true;

-- 4. Backfill SubDepartment for employees based on their Designation
UPDATE employees e
SET "SubDepartment" = d."SubDepartment"
FROM mst_designations d
WHERE e."DesignationId" = d."Id" AND d."SubDepartment" IS NOT NULL;
