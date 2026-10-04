import type { ResourceMastersState } from "./types";

export const MASTER_DEPARTMENTS_LIST = [
  "Core",
  "Functional - Accounts",
  "Functional - HR",
  "Functional - IT Administration",
  "Functional - Project Management",
  "Functional - Sales",
  "R&D (Research & Development)",
  "Services - Consulting",
  "Services - Operations",
  "Services - Testing"
];

export const MASTER_ON_FLOOR_ROLES_LIST = [
  "Leader (L)",
  "Manager (Mng.)",
  "Senior Manager",
  "Team Leader (TL)",
  "Team Member (TM)",
  "Intern",
  "Specialist"
];

export const MASTER_ALL_RBAC_ROLES = [
  {
    "id": "cd2a32ed-32fc-47bc-88a9-e6fc48863869",
    "name": "Accounts",
    "displayName": "Accounts & Finance"
  },
  {
    "id": "a0000000-0000-0000-0000-000000000001",
    "name": "Admin",
    "displayName": "Admin"
  },
  {
    "id": "62a927b7-9fd8-461a-b64e-1aa441eeba4d",
    "name": "CEO",
    "displayName": "Chief Executive Officer"
  },
  {
    "id": "a5bfe265-981a-4723-b7bb-6ddc389db7f0",
    "name": "COO",
    "displayName": "Chief Operating Officer"
  },
  {
    "id": "66e48815-4d4f-41d0-9c5f-26a7b7ba296c",
    "name": "CTO",
    "displayName": "Chief Technology Officer"
  },
  {
    "id": "64c49f37-a38a-46a6-9622-7427f1501658",
    "name": "Consulting-HOD",
    "displayName": "Consulting Head of Dept"
  },
  {
    "id": "e5d6f6ff-be59-4cc4-a8c6-65191d550d0a",
    "name": "Consulting-Manager",
    "displayName": "Consulting Project Manager"
  },
  {
    "id": "4abcc3c7-63ba-4ea6-baa5-c55d5f4f1089",
    "name": "Consulting-Senior Manager",
    "displayName": "Consulting Senior Manager"
  },
  {
    "id": "701aaa2c-a899-4def-bf5f-e17511874409",
    "name": "Consulting-Team Leader",
    "displayName": "Consulting Team Leader"
  },
  {
    "id": "768a11f9-ded7-4f6f-ba86-073e279255d9",
    "name": "Consulting-Team member",
    "displayName": "Consulting Team Member"
  },
  {
    "id": "a5023c9e-367f-41e1-ba02-bdb2929edc89",
    "name": "EngagementManager",
    "displayName": "Engagement Manager (EM)"
  },
  {
    "id": "bb568e26-548b-4ca5-9221-fefb9c9143b3",
    "name": "HR",
    "displayName": "Human Resources"
  },
  {
    "id": "f29af015-7833-4f9a-ac57-6fbef5bf91ec",
    "name": "Intern",
    "displayName": "Intern"
  },
  {
    "id": "b552183f-2695-41f9-860e-16d5fe94c4aa",
    "name": "IT Admin",
    "displayName": "IT Administrator"
  },
  {
    "id": "2acf8b94-0756-4db8-bb6f-8372ac04a2d1",
    "name": "PMO",
    "displayName": "Project Management Office"
  },
  {
    "id": "f5c742d1-e0cc-4bf8-b860-a673ac407393",
    "name": "R&D - Team member",
    "displayName": "R&D Team Member"
  },
  {
    "id": "914d8500-03b6-4a43-a250-244effca1cf1",
    "name": "Sales Manager",
    "displayName": "Sales Manager"
  },
  {
    "id": "7cc8753c-f3b0-4fc9-b63b-efd00e2c5325",
    "name": "Sales team member",
    "displayName": "Sales Team Member"
  },
  {
    "id": "3d068c2f-d0a1-4045-bad9-0f3a43efec4f",
    "name": "SOC-HOD",
    "displayName": "SOC Head of Department"
  },
  {
    "id": "111cc3cd-6d35-43ce-be91-dde90d3d4015",
    "name": "SOC-Manager",
    "displayName": "SOC Manager"
  },
  {
    "id": "b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7",
    "name": "SOC-Senior Manager",
    "displayName": "SOC Senior Manager"
  },
  {
    "id": "aba61e5b-422a-4461-b9da-8dba8f6d3f85",
    "name": "SOC-Team Leader",
    "displayName": "SOC Shift / Team Leader"
  },
  {
    "id": "1a62b1f8-1810-464d-a67b-168d7e419827",
    "name": "SOC-Team Member",
    "displayName": "SOC Team Member"
  },
  {
    "id": "c787fe3b-4b33-40ee-8794-c1148202f81a",
    "name": "Testing HOD",
    "displayName": "Testing Head of Department"
  },
  {
    "id": "29ad5710-1621-4c24-ac75-dedfc168ba1a",
    "name": "Testing-Manager",
    "displayName": "Testing Project Manager"
  },
  {
    "id": "efc1df20-ca04-44a6-87b2-7cae1ff50a88",
    "name": "Testing Senior Manager",
    "displayName": "Testing Senior Manager"
  },
  {
    "id": "a3793f87-7f3c-41a1-a675-236fc1b710ab",
    "name": "Testing-Team Leader",
    "displayName": "Testing Team Leader"
  },
  {
    "id": "92aa9169-28d9-4754-a570-553b067642ed",
    "name": "Testing-Team Member",
    "displayName": "Testing Team Member"
  }
];

export const MASTER_RAILWAY_LINES_LIST = [
  "Western Line",
  "Central Line",
  "Harbour Line",
  "Trans-Harbour Line",
  "Metro Line",
  "Outstation / Other"
];

export const INITIAL_RESOURCE_MASTERS: ResourceMastersState = {
  departmentHierarchy: [
  {
    "id": "dh-1",
    "departmentId": "6a6bb234-1e03-41e8-a4e7-b0e77c8e442e",
    "departmentName": "Core",
    "designationId": "778f1120-9633-4933-9160-ddaa46668838",
    "designationName": "Director and Chief Executive Officer",
    "onFloorRoleId": "94fc014e-37ce-4eb4-8588-ff56a79be98e",
    "onFloorRoleName": "Leader (L)",
    "assignedRbacRoleId": "62a927b7-9fd8-461a-b64e-1aa441eeba4d",
    "assignedRbacRoleName": "Chief Executive Officer",
    "assignedRbacRoleCode": "CEO",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-2",
    "departmentId": "6a6bb234-1e03-41e8-a4e7-b0e77c8e442e",
    "departmentName": "Core",
    "designationId": "ffed7aa1-e88f-4281-919f-8d49fbabf5a5",
    "designationName": "Director and Chief Operating Officer",
    "onFloorRoleId": "3dd672a7-e6a9-42c8-bdbf-4d1340efc1da",
    "onFloorRoleName": "Leader (L)",
    "assignedRbacRoleId": "a5bfe265-981a-4723-b7bb-6ddc389db7f0",
    "assignedRbacRoleName": "Chief Operating Officer",
    "assignedRbacRoleCode": "COO",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-3",
    "departmentId": "6a6bb234-1e03-41e8-a4e7-b0e77c8e442e",
    "departmentName": "Core",
    "designationId": "0525d830-ead9-44a0-871f-91b7845fec26",
    "designationName": "Director and Chief Technology Officer",
    "onFloorRoleId": "0028e31d-d2ff-4a71-b5b2-5f0566961d46",
    "onFloorRoleName": "Leader (L)",
    "assignedRbacRoleId": "66e48815-4d4f-41d0-9c5f-26a7b7ba296c",
    "assignedRbacRoleName": "Chief Technology Officer",
    "assignedRbacRoleCode": "CTO",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-4",
    "departmentId": "bcbd68c8-c3f3-4396-abb0-0b0e13637958",
    "departmentName": "Functional - Accounts",
    "designationId": "155642eb-a633-4460-b658-aca9fde2d817",
    "designationName": "Accountant - I",
    "onFloorRoleId": "33f2483b-b264-4ec4-857a-205426a8af0f",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "cd2a32ed-32fc-47bc-88a9-e6fc48863869",
    "assignedRbacRoleName": "Accounts & Finance",
    "assignedRbacRoleCode": "Accounts",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-5",
    "departmentId": "bcbd68c8-c3f3-4396-abb0-0b0e13637958",
    "departmentName": "Functional - Accounts",
    "designationId": "8dc0d8fe-593d-422a-8b27-5b68fbe6d224",
    "designationName": "Accountant - II",
    "onFloorRoleId": "95337b72-6733-48f5-ba8c-cd2afbcbc1e4",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "cd2a32ed-32fc-47bc-88a9-e6fc48863869",
    "assignedRbacRoleName": "Accounts & Finance",
    "assignedRbacRoleCode": "Accounts",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-6",
    "departmentId": "bcbd68c8-c3f3-4396-abb0-0b0e13637958",
    "departmentName": "Functional - Accounts",
    "designationId": "6e606c29-2ebf-4ab8-8006-aaedd5680009",
    "designationName": "Accountant - III",
    "onFloorRoleId": "4ca2ade8-8da6-46d7-a7ec-1124e0229d9e",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "cd2a32ed-32fc-47bc-88a9-e6fc48863869",
    "assignedRbacRoleName": "Accounts & Finance",
    "assignedRbacRoleCode": "Accounts",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-7",
    "departmentId": "bcbd68c8-c3f3-4396-abb0-0b0e13637958",
    "departmentName": "Functional - Accounts",
    "designationId": "caa227a1-2dcf-4195-ab9c-8f76d1862daa",
    "designationName": "Intern",
    "onFloorRoleId": "98e28e22-95e4-41ee-9178-2912de24f21a",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f29af015-7833-4f9a-ac57-6fbef5bf91ec",
    "assignedRbacRoleName": "Intern",
    "assignedRbacRoleCode": "Intern",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-8",
    "departmentId": "bcbd68c8-c3f3-4396-abb0-0b0e13637958",
    "departmentName": "Functional - Accounts",
    "designationId": "4ef1cb5b-9688-4ce2-95b3-6a0863200166",
    "designationName": "Senior Accountant - I",
    "onFloorRoleId": "f37fa8d5-1c48-4038-95d5-cd7dfea12085",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "cd2a32ed-32fc-47bc-88a9-e6fc48863869",
    "assignedRbacRoleName": "Accounts & Finance",
    "assignedRbacRoleCode": "Accounts",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-9",
    "departmentId": "bcbd68c8-c3f3-4396-abb0-0b0e13637958",
    "departmentName": "Functional - Accounts",
    "designationId": "96efad7d-8b7f-4d7f-a862-c0a6bec3789f",
    "designationName": "Senior Accountant - II",
    "onFloorRoleId": "16f2557a-02c9-4208-a570-55a909532abe",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "cd2a32ed-32fc-47bc-88a9-e6fc48863869",
    "assignedRbacRoleName": "Accounts & Finance",
    "assignedRbacRoleCode": "Accounts",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-10",
    "departmentId": "bcbd68c8-c3f3-4396-abb0-0b0e13637958",
    "departmentName": "Functional - Accounts",
    "designationId": "1f97b442-95c5-4b11-93a0-ea146534ae85",
    "designationName": "Senior Accountant - III",
    "onFloorRoleId": "9225698b-9ecd-4dfb-9008-fe08b395efc9",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "cd2a32ed-32fc-47bc-88a9-e6fc48863869",
    "assignedRbacRoleName": "Accounts & Finance",
    "assignedRbacRoleCode": "Accounts",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-11",
    "departmentId": "310a2f16-15f6-4b82-95f6-ab18b5b429f5",
    "departmentName": "Functional - HR",
    "designationId": "8fdfba5d-e947-47b6-aa25-23d9a6dc49ed",
    "designationName": "HR Head",
    "onFloorRoleId": "c7d75b92-f6e2-4dd7-a726-ae662ee83c95",
    "onFloorRoleName": "HR",
    "assignedRbacRoleId": "bb568e26-548b-4ca5-9221-fefb9c9143b3",
    "assignedRbacRoleName": "Human Resources",
    "assignedRbacRoleCode": "HR",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-12",
    "departmentId": "310a2f16-15f6-4b82-95f6-ab18b5b429f5",
    "departmentName": "Functional - HR",
    "designationId": "e8c22eff-0daf-4690-a537-c8b0b6110a01",
    "designationName": "Intern",
    "onFloorRoleId": "7bd6b8a7-be33-43ba-b4d7-4d290e71b91e",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f29af015-7833-4f9a-ac57-6fbef5bf91ec",
    "assignedRbacRoleName": "Intern",
    "assignedRbacRoleCode": "Intern",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-13",
    "departmentId": "310a2f16-15f6-4b82-95f6-ab18b5b429f5",
    "departmentName": "Functional - HR",
    "designationId": "7d542941-65b9-499b-81b3-239748d6da52",
    "designationName": "Recruitment Coordinator - I",
    "onFloorRoleId": "6b361aa9-a47a-4fed-9d1f-07a4e1dd5f30",
    "onFloorRoleName": "HR",
    "assignedRbacRoleId": "bb568e26-548b-4ca5-9221-fefb9c9143b3",
    "assignedRbacRoleName": "Human Resources",
    "assignedRbacRoleCode": "HR",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-14",
    "departmentId": "310a2f16-15f6-4b82-95f6-ab18b5b429f5",
    "departmentName": "Functional - HR",
    "designationId": "c2e248c8-e917-445f-9f7b-1e25d7bb5abe",
    "designationName": "Recruitment Coordinator - II",
    "onFloorRoleId": "cc4e4c23-fccc-44ba-8423-5e4e6ec35731",
    "onFloorRoleName": "HR",
    "assignedRbacRoleId": "bb568e26-548b-4ca5-9221-fefb9c9143b3",
    "assignedRbacRoleName": "Human Resources",
    "assignedRbacRoleCode": "HR",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-15",
    "departmentId": "310a2f16-15f6-4b82-95f6-ab18b5b429f5",
    "departmentName": "Functional - HR",
    "designationId": "485012d4-2c28-4bc4-92c7-3609e3e3749e",
    "designationName": "Senior HR Executive - I",
    "onFloorRoleId": "ebdc343e-9f43-4715-8a37-4861594c4b0a",
    "onFloorRoleName": "HR",
    "assignedRbacRoleId": "bb568e26-548b-4ca5-9221-fefb9c9143b3",
    "assignedRbacRoleName": "Human Resources",
    "assignedRbacRoleCode": "HR",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-16",
    "departmentId": "310a2f16-15f6-4b82-95f6-ab18b5b429f5",
    "departmentName": "Functional - HR",
    "designationId": "e4e20503-cd55-4393-83fd-6c7e7d7d0a49",
    "designationName": "Senior HR Executive - II",
    "onFloorRoleId": "1e17c9f0-a8ed-4d89-819d-738a84af4e48",
    "onFloorRoleName": "HR",
    "assignedRbacRoleId": "bb568e26-548b-4ca5-9221-fefb9c9143b3",
    "assignedRbacRoleName": "Human Resources",
    "assignedRbacRoleCode": "HR",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-17",
    "departmentId": "f7e882f6-2fa8-45e1-9137-2bc4b70f016a",
    "departmentName": "Functional - IT Administration",
    "designationId": "c70b9832-841e-4864-9b85-eaba3c0a995f",
    "designationName": "Desktop Support Engineer - I",
    "onFloorRoleId": "1c1c9112-592b-4f23-92d5-213a5da0d78d",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "b552183f-2695-41f9-860e-16d5fe94c4aa",
    "assignedRbacRoleName": "IT Administrator",
    "assignedRbacRoleCode": "IT Admin",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-18",
    "departmentId": "f7e882f6-2fa8-45e1-9137-2bc4b70f016a",
    "departmentName": "Functional - IT Administration",
    "designationId": "73bd55bb-5d0e-4381-8ad2-2238377fca93",
    "designationName": "Desktop Support Engineer - II",
    "onFloorRoleId": "913e691d-e3f9-4f9a-aab8-57eda52a8cd6",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "b552183f-2695-41f9-860e-16d5fe94c4aa",
    "assignedRbacRoleName": "IT Administrator",
    "assignedRbacRoleCode": "IT Admin",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-19",
    "departmentId": "f7e882f6-2fa8-45e1-9137-2bc4b70f016a",
    "departmentName": "Functional - IT Administration",
    "designationId": "f8502c44-b289-49e4-8401-3dcad4d5bbe0",
    "designationName": "Intern",
    "onFloorRoleId": "f43fddea-4dd9-4603-a79c-1710224115ae",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f29af015-7833-4f9a-ac57-6fbef5bf91ec",
    "assignedRbacRoleName": "Intern",
    "assignedRbacRoleCode": "Intern",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-20",
    "departmentId": "f7e882f6-2fa8-45e1-9137-2bc4b70f016a",
    "departmentName": "Functional - IT Administration",
    "designationId": "da990f6e-3379-4cc4-89b7-0ead29da472b",
    "designationName": "IT Admin",
    "onFloorRoleId": "eda2ca5a-d2b1-45db-94cc-4575f0eda8dc",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "b552183f-2695-41f9-860e-16d5fe94c4aa",
    "assignedRbacRoleName": "IT Administrator",
    "assignedRbacRoleCode": "IT Admin",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-21",
    "departmentId": "8e4e88f1-e294-4554-80cc-92ed6169caeb",
    "departmentName": "Functional - Project Management",
    "designationId": "b3309eea-7374-4a8d-ac13-481b2a7fd492",
    "designationName": "Associate PMO - I",
    "onFloorRoleId": "48079f83-fbf9-4639-ae6b-263ca3fb752a",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "2acf8b94-0756-4db8-bb6f-8372ac04a2d1",
    "assignedRbacRoleName": "Project Management Office",
    "assignedRbacRoleCode": "PMO",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-22",
    "departmentId": "8e4e88f1-e294-4554-80cc-92ed6169caeb",
    "departmentName": "Functional - Project Management",
    "designationId": "2a76927c-461a-48e4-8190-dea7361ef3db",
    "designationName": "Associate PMO - II",
    "onFloorRoleId": "f67d5930-703b-4497-a4ea-2add60f7fb58",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "2acf8b94-0756-4db8-bb6f-8372ac04a2d1",
    "assignedRbacRoleName": "Project Management Office",
    "assignedRbacRoleCode": "PMO",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-23",
    "departmentId": "8e4e88f1-e294-4554-80cc-92ed6169caeb",
    "departmentName": "Functional - Project Management",
    "designationId": "834c9e15-c70d-4a0b-bb12-5e55f23c181d",
    "designationName": "Delivery Account Manager - I",
    "onFloorRoleId": "9fb9b5b5-bc14-4597-8953-7a1ea10dc0dd",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "a5023c9e-367f-41e1-ba02-bdb2929edc89",
    "assignedRbacRoleName": "Engagement Manager (EM)",
    "assignedRbacRoleCode": "EngagementManager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-24",
    "departmentId": "8e4e88f1-e294-4554-80cc-92ed6169caeb",
    "departmentName": "Functional - Project Management",
    "designationId": "d8a2b9e5-f54d-4344-a78d-c6c840467543",
    "designationName": "Delivery Account Manager - II",
    "onFloorRoleId": "db77e167-7f67-43f6-9e2d-4ebaf6f9f802",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "a5023c9e-367f-41e1-ba02-bdb2929edc89",
    "assignedRbacRoleName": "Engagement Manager (EM)",
    "assignedRbacRoleCode": "EngagementManager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-25",
    "departmentId": "8e4e88f1-e294-4554-80cc-92ed6169caeb",
    "departmentName": "Functional - Project Management",
    "designationId": "fdd34566-051a-487d-a985-540c2db8c37f",
    "designationName": "Engagement Manager",
    "onFloorRoleId": "fr-25",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "a5023c9e-367f-41e1-ba02-bdb2929edc89",
    "assignedRbacRoleName": "Engagement Manager (EM)",
    "assignedRbacRoleCode": "EngagementManager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-26",
    "departmentId": "8e4e88f1-e294-4554-80cc-92ed6169caeb",
    "departmentName": "Functional - Project Management",
    "designationId": "9050e021-7d84-4401-820e-c0e768abb1ab",
    "designationName": "Intern",
    "onFloorRoleId": "6c1b3c1d-4159-41b9-9171-1e4f2501cc32",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f29af015-7833-4f9a-ac57-6fbef5bf91ec",
    "assignedRbacRoleName": "Intern",
    "assignedRbacRoleCode": "Intern",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-27",
    "departmentId": "8e4e88f1-e294-4554-80cc-92ed6169caeb",
    "departmentName": "Functional - Project Management",
    "designationId": "8b57cfd5-5d4e-44a3-9646-b36873c111c2",
    "designationName": "Senior Delivery Account Manager - I",
    "onFloorRoleId": "57b9b89d-9123-4bd0-b8fd-a373e0648f43",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "a5023c9e-367f-41e1-ba02-bdb2929edc89",
    "assignedRbacRoleName": "Engagement Manager (EM)",
    "assignedRbacRoleCode": "EngagementManager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-28",
    "departmentId": "8e4e88f1-e294-4554-80cc-92ed6169caeb",
    "departmentName": "Functional - Project Management",
    "designationId": "9dc69952-eae6-4ec0-a327-67392315f089",
    "designationName": "Senior Delivery Account Manager - II",
    "onFloorRoleId": "b3a66833-fc6b-4bac-9438-959333107d3c",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "a5023c9e-367f-41e1-ba02-bdb2929edc89",
    "assignedRbacRoleName": "Engagement Manager (EM)",
    "assignedRbacRoleCode": "EngagementManager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-29",
    "departmentId": "8e4e88f1-e294-4554-80cc-92ed6169caeb",
    "departmentName": "Functional - Project Management",
    "designationId": "c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c",
    "designationName": "Senior PMO - I",
    "onFloorRoleId": "446498d0-e9e6-4dbb-8fbe-b87bb853a2af",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "2acf8b94-0756-4db8-bb6f-8372ac04a2d1",
    "assignedRbacRoleName": "Project Management Office",
    "assignedRbacRoleCode": "PMO",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-30",
    "departmentId": "8e4e88f1-e294-4554-80cc-92ed6169caeb",
    "departmentName": "Functional - Project Management",
    "designationId": "138434a2-625f-4df5-836d-fcf0cfceef79",
    "designationName": "Senior PMO - II",
    "onFloorRoleId": "1cf32162-d510-4a26-a017-e2035425dc93",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "2acf8b94-0756-4db8-bb6f-8372ac04a2d1",
    "assignedRbacRoleName": "Project Management Office",
    "assignedRbacRoleCode": "PMO",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-31",
    "departmentId": "13c91c98-00ae-4211-acb8-d06e35953806",
    "departmentName": "Functional - Sales",
    "designationId": "272973a6-c052-4aef-bf32-9e24f7eb6cc9",
    "designationName": "Associate Customer Success Representative - I",
    "onFloorRoleId": "3e28d4a4-7d87-41ed-b921-a39dd937df76",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "7cc8753c-f3b0-4fc9-b63b-efd00e2c5325",
    "assignedRbacRoleName": "Sales Team Member",
    "assignedRbacRoleCode": "Sales team member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-32",
    "departmentId": "13c91c98-00ae-4211-acb8-d06e35953806",
    "departmentName": "Functional - Sales",
    "designationId": "7e7d954f-34b5-4c23-8c3f-698ec920e9e4",
    "designationName": "Associate Customer Success Representative - II",
    "onFloorRoleId": "21eac166-3ba7-40c5-a780-bbc7b3e96ddb",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "7cc8753c-f3b0-4fc9-b63b-efd00e2c5325",
    "assignedRbacRoleName": "Sales Team Member",
    "assignedRbacRoleCode": "Sales team member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-33",
    "departmentId": "13c91c98-00ae-4211-acb8-d06e35953806",
    "departmentName": "Functional - Sales",
    "designationId": "b2b687ef-fd62-4cb7-a826-b40a35da7b2c",
    "designationName": "Business Development Associate - I",
    "onFloorRoleId": "9de62ea5-b7da-4a55-8b54-056fdf6bc621",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "914d8500-03b6-4a43-a250-244effca1cf1",
    "assignedRbacRoleName": "Sales Manager",
    "assignedRbacRoleCode": "Sales Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-34",
    "departmentId": "13c91c98-00ae-4211-acb8-d06e35953806",
    "departmentName": "Functional - Sales",
    "designationId": "157d001c-b056-45b1-96a3-3c05bcd8d99c",
    "designationName": "Customer Success Representative - II",
    "onFloorRoleId": "7b597cd0-0153-4ddb-a7b2-f553cbafc8a9",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "914d8500-03b6-4a43-a250-244effca1cf1",
    "assignedRbacRoleName": "Sales Manager",
    "assignedRbacRoleCode": "Sales Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-35",
    "departmentId": "13c91c98-00ae-4211-acb8-d06e35953806",
    "departmentName": "Functional - Sales",
    "designationId": "6193be76-40ad-4973-9ee7-246a4d8f4109",
    "designationName": "Director - Product Sales",
    "onFloorRoleId": "412826f2-67b6-47c9-a62c-270fa9425ce4",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "7cc8753c-f3b0-4fc9-b63b-efd00e2c5325",
    "assignedRbacRoleName": "Sales Team Member",
    "assignedRbacRoleCode": "Sales team member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-36",
    "departmentId": "13c91c98-00ae-4211-acb8-d06e35953806",
    "departmentName": "Functional - Sales",
    "designationId": "e2b10def-c91d-45da-94c5-f5530e743aa2",
    "designationName": "Intern",
    "onFloorRoleId": "0b340900-7bd0-4931-8978-832c678c7cbd",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f29af015-7833-4f9a-ac57-6fbef5bf91ec",
    "assignedRbacRoleName": "Intern",
    "assignedRbacRoleCode": "Intern",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-37",
    "departmentId": "13c91c98-00ae-4211-acb8-d06e35953806",
    "departmentName": "Functional - Sales",
    "designationId": "e2c675a7-92dc-4477-be75-9a304cbe4def",
    "designationName": "Sales Associate",
    "onFloorRoleId": "d0b9d2a2-d79c-4097-ae63-4bff14436d0a",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "7cc8753c-f3b0-4fc9-b63b-efd00e2c5325",
    "assignedRbacRoleName": "Sales Team Member",
    "assignedRbacRoleCode": "Sales team member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-38",
    "departmentId": "13c91c98-00ae-4211-acb8-d06e35953806",
    "departmentName": "Functional - Sales",
    "designationId": "b3c75d81-80a1-4240-8b1e-010000000005",
    "designationName": "Sales Manager",
    "onFloorRoleId": "b3c75d81-80a1-4240-8b1e-020000000005",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "914d8500-03b6-4a43-a250-244effca1cf1",
    "assignedRbacRoleName": "Sales Manager",
    "assignedRbacRoleCode": "Sales Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-39",
    "departmentId": "898c36e9-1cb7-4c56-9148-a3b6893c0149",
    "departmentName": "R&D (Research & Development)",
    "designationId": "bb7ccd5f-2f60-49fb-b984-f11fc47add22",
    "designationName": "Intern",
    "onFloorRoleId": "859254f8-a1b4-4812-b1d0-aacf111f7235",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f29af015-7833-4f9a-ac57-6fbef5bf91ec",
    "assignedRbacRoleName": "Intern",
    "assignedRbacRoleCode": "Intern",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-40",
    "departmentId": "898c36e9-1cb7-4c56-9148-a3b6893c0149",
    "departmentName": "R&D (Research & Development)",
    "designationId": "f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29",
    "designationName": "Python Developer - I",
    "onFloorRoleId": "fdf924c8-3a4a-40bb-9bf9-ea42d4946ecb",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f5c742d1-e0cc-4bf8-b860-a673ac407393",
    "assignedRbacRoleName": "R&D Team Member",
    "assignedRbacRoleCode": "R&D - Team member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-41",
    "departmentId": "898c36e9-1cb7-4c56-9148-a3b6893c0149",
    "departmentName": "R&D (Research & Development)",
    "designationId": "3356f353-1566-4df6-9958-fa01d67d13c7",
    "designationName": "Python Developer - II",
    "onFloorRoleId": "401a442f-98c4-4b95-9e07-647853bf9122",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f5c742d1-e0cc-4bf8-b860-a673ac407393",
    "assignedRbacRoleName": "R&D Team Member",
    "assignedRbacRoleCode": "R&D - Team member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-42",
    "departmentId": "898c36e9-1cb7-4c56-9148-a3b6893c0149",
    "departmentName": "R&D (Research & Development)",
    "designationId": "9ba2a2f7-e946-4e55-ad1c-135c6fd77e85",
    "designationName": "Python Developer - III",
    "onFloorRoleId": "ee402c9b-252b-4eec-8880-7a4a159eac92",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f5c742d1-e0cc-4bf8-b860-a673ac407393",
    "assignedRbacRoleName": "R&D Team Member",
    "assignedRbacRoleCode": "R&D - Team member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-43",
    "departmentId": "be8e036d-ad13-4c79-89ec-294e490a6816",
    "departmentName": "Services - Consulting",
    "designationId": "195d6a81-8457-4b60-9382-6a3a0664f0e9",
    "designationName": "Associate Manager - III",
    "onFloorRoleId": "86a621fc-db0d-4e12-96c5-2af111964ef5",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "e5d6f6ff-be59-4cc4-a8c6-65191d550d0a",
    "assignedRbacRoleName": "Consulting Project Manager",
    "assignedRbacRoleCode": "Consulting-Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-44",
    "departmentId": "be8e036d-ad13-4c79-89ec-294e490a6816",
    "departmentName": "Services - Consulting",
    "designationId": "195d6a81-8457-4b60-9382-6a3a0664f0e9",
    "designationName": "Associate Manager - III",
    "onFloorRoleId": "52ae8b5b-80b3-4d14-b8c5-0bc40e1f4bee",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "e5d6f6ff-be59-4cc4-a8c6-65191d550d0a",
    "assignedRbacRoleName": "Consulting Project Manager",
    "assignedRbacRoleCode": "Consulting-Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-45",
    "departmentId": "be8e036d-ad13-4c79-89ec-294e490a6816",
    "departmentName": "Services - Consulting",
    "designationId": "1e7faab8-273d-40df-9f9a-485160186c5a",
    "designationName": "GRC Auditor - I",
    "onFloorRoleId": "074ea1a8-d519-4cda-87a4-978cd1eec45a",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "768a11f9-ded7-4f6f-ba86-073e279255d9",
    "assignedRbacRoleName": "Consulting Team Member",
    "assignedRbacRoleCode": "Consulting-Team member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-46",
    "departmentId": "be8e036d-ad13-4c79-89ec-294e490a6816",
    "departmentName": "Services - Consulting",
    "designationId": "2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b",
    "designationName": "GRC Auditor - II",
    "onFloorRoleId": "6886e92b-a2c5-4057-9330-47394a2aac65",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "768a11f9-ded7-4f6f-ba86-073e279255d9",
    "assignedRbacRoleName": "Consulting Team Member",
    "assignedRbacRoleCode": "Consulting-Team member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-47",
    "departmentId": "be8e036d-ad13-4c79-89ec-294e490a6816",
    "departmentName": "Services - Consulting",
    "designationId": "8a655ba7-f9db-4de7-8de9-9fec72a2ed1d",
    "designationName": "GRC Auditor - III",
    "onFloorRoleId": "40354601-9ac5-41e0-9ddb-6603e5614a86",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "768a11f9-ded7-4f6f-ba86-073e279255d9",
    "assignedRbacRoleName": "Consulting Team Member",
    "assignedRbacRoleCode": "Consulting-Team member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-48",
    "departmentId": "be8e036d-ad13-4c79-89ec-294e490a6816",
    "departmentName": "Services - Consulting",
    "designationId": "7c2380da-3ee6-46ad-93d6-a79ce3027f29",
    "designationName": "GRC Auditor - IV",
    "onFloorRoleId": "3efb18e5-f8d5-4de9-8959-ab5401f64b74",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "768a11f9-ded7-4f6f-ba86-073e279255d9",
    "assignedRbacRoleName": "Consulting Team Member",
    "assignedRbacRoleCode": "Consulting-Team member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-49",
    "departmentId": "be8e036d-ad13-4c79-89ec-294e490a6816",
    "departmentName": "Services - Consulting",
    "designationId": "2076a9b1-e432-46a9-99b1-36e732159856",
    "designationName": "Intern",
    "onFloorRoleId": "6c0bebbb-cc4d-4433-83e9-d65fb5291d75",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f29af015-7833-4f9a-ac57-6fbef5bf91ec",
    "assignedRbacRoleName": "Intern",
    "assignedRbacRoleCode": "Intern",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-50",
    "departmentId": "be8e036d-ad13-4c79-89ec-294e490a6816",
    "departmentName": "Services - Consulting",
    "designationId": "dadac355-1ddc-457c-935a-d297da3a883d",
    "designationName": "Principal Manager - I",
    "onFloorRoleId": "61cc6cff-4f61-4a1d-90f5-9eb9f61c54f3",
    "onFloorRoleName": "Sr. Manager (Sr.Mng.)",
    "assignedRbacRoleId": "64c49f37-a38a-46a6-9622-7427f1501658",
    "assignedRbacRoleName": "Consulting Head of Dept",
    "assignedRbacRoleCode": "Consulting-HOD",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-51",
    "departmentId": "be8e036d-ad13-4c79-89ec-294e490a6816",
    "departmentName": "Services - Consulting",
    "designationId": "dcabe0b2-ab10-4c1a-abf7-873e8b5486ca",
    "designationName": "Senior GRC Auditor - I",
    "onFloorRoleId": "22215465-c056-4ba4-a867-23ed37658a09",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "701aaa2c-a899-4def-bf5f-e17511874409",
    "assignedRbacRoleName": "Consulting Team Leader",
    "assignedRbacRoleCode": "Consulting-Team Leader",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-52",
    "departmentId": "be8e036d-ad13-4c79-89ec-294e490a6816",
    "departmentName": "Services - Consulting",
    "designationId": "3e60b693-d3dd-4481-95c4-9f02da21625c",
    "designationName": "Senior GRC Auditor - II",
    "onFloorRoleId": "4e574ffd-c3a9-4a15-832a-5dabfb352dc3",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "701aaa2c-a899-4def-bf5f-e17511874409",
    "assignedRbacRoleName": "Consulting Team Leader",
    "assignedRbacRoleCode": "Consulting-Team Leader",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-53",
    "departmentId": "be8e036d-ad13-4c79-89ec-294e490a6816",
    "departmentName": "Services - Consulting",
    "designationId": "2b1558e3-158a-4a84-ae80-053129861a64",
    "designationName": "Senior Vice President - Principal Consultant",
    "onFloorRoleId": "6b840581-65b6-4e1d-916f-38b6018e07e0",
    "onFloorRoleName": "Head Of Department (HOD)",
    "assignedRbacRoleId": "64c49f37-a38a-46a6-9622-7427f1501658",
    "assignedRbacRoleName": "Consulting Head of Dept",
    "assignedRbacRoleCode": "Consulting-HOD",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-54",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "0b8dfaba-3f3f-4f5f-8812-46144a90aeaf",
    "designationName": "Intern",
    "onFloorRoleId": "1d19d6af-78b4-45ef-bcb3-db1b3896f153",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f29af015-7833-4f9a-ac57-6fbef5bf91ec",
    "assignedRbacRoleName": "Intern",
    "assignedRbacRoleCode": "Intern",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-55",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "ea315f7d-d597-41b3-a999-4f3851bcd020",
    "designationName": "SIEM Admin - I",
    "onFloorRoleId": "3000065e-1037-4a6b-a87a-4c461a756531",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "1a62b1f8-1810-464d-a67b-168d7e419827",
    "assignedRbacRoleName": "SOC Team Member",
    "assignedRbacRoleCode": "SOC-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-56",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "4650d4e0-f73c-4688-ae5f-830a46348ff9",
    "designationName": "SIEM Admin - II",
    "onFloorRoleId": "0997a260-4ca3-4eb2-b87a-4bd6bf235677",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "1a62b1f8-1810-464d-a67b-168d7e419827",
    "assignedRbacRoleName": "SOC Team Member",
    "assignedRbacRoleCode": "SOC-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-57",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "af8a1442-c5ee-409d-aa91-61c9dba852ee",
    "designationName": "SIEM Admin - III",
    "onFloorRoleId": "178985be-3d47-4903-983b-3a581e788e61",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "1a62b1f8-1810-464d-a67b-168d7e419827",
    "assignedRbacRoleName": "SOC Team Member",
    "assignedRbacRoleCode": "SOC-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-58",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "e36018c5-bf48-4f93-bef7-93e8864a0b51",
    "designationName": "SIEM Admin - IV",
    "onFloorRoleId": "da46be38-b216-44cc-8b6d-70cd4b0aea8e",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "aba61e5b-422a-4461-b9da-8dba8f6d3f85",
    "assignedRbacRoleName": "SOC Shift / Team Leader",
    "assignedRbacRoleCode": "SOC-Team Leader",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-59",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "6d25ff6d-e13d-440f-b775-215547af7acb",
    "designationName": "SOC Analyst - I",
    "onFloorRoleId": "eaa98dba-df5b-4b1d-b2d5-20b159a0a070",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "1a62b1f8-1810-464d-a67b-168d7e419827",
    "assignedRbacRoleName": "SOC Team Member",
    "assignedRbacRoleCode": "SOC-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-60",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "48429bb5-c583-4684-b30a-7ed443b671ca",
    "designationName": "SOC Analyst - II",
    "onFloorRoleId": "9c970783-5b89-4fd0-b3f3-1c1953a853ab",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "1a62b1f8-1810-464d-a67b-168d7e419827",
    "assignedRbacRoleName": "SOC Team Member",
    "assignedRbacRoleCode": "SOC-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-61",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "f20a7445-0b01-4f20-85a5-853101d864ee",
    "designationName": "SOC Analyst - III",
    "onFloorRoleId": "3f413c39-a269-4d44-9f3c-9e7f6e3ecced",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "1a62b1f8-1810-464d-a67b-168d7e419827",
    "assignedRbacRoleName": "SOC Team Member",
    "assignedRbacRoleCode": "SOC-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-62",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "0c1a5ef4-7fca-45dc-8253-87afa21a1df9",
    "designationName": "SOC Analyst - IV",
    "onFloorRoleId": "ea40e2b6-035a-4766-96bc-13ad013020c1",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "1a62b1f8-1810-464d-a67b-168d7e419827",
    "assignedRbacRoleName": "SOC Team Member",
    "assignedRbacRoleCode": "SOC-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-63",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09",
    "designationName": "SOC Consultant - I",
    "onFloorRoleId": "24ccdefb-8dd5-411e-8b2e-af8fb743a3cb",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "1a62b1f8-1810-464d-a67b-168d7e419827",
    "assignedRbacRoleName": "SOC Team Member",
    "assignedRbacRoleCode": "SOC-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-64",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "911f6d7f-8d43-40f2-897a-2f416abf8cf9",
    "designationName": "SOC Consultant - II",
    "onFloorRoleId": "b4e88d70-1263-47af-96a9-203ee422e8b1",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "1a62b1f8-1810-464d-a67b-168d7e419827",
    "assignedRbacRoleName": "SOC Team Member",
    "assignedRbacRoleCode": "SOC-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-65",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "b3c75d81-80a1-4240-8b1e-010000000003",
    "designationName": "SOC HOD",
    "onFloorRoleId": "b3c75d81-80a1-4240-8b1e-020000000003",
    "onFloorRoleName": "Head Of Department (HOD)",
    "assignedRbacRoleId": "3d068c2f-d0a1-4045-bad9-0f3a43efec4f",
    "assignedRbacRoleName": "SOC Head of Department",
    "assignedRbacRoleCode": "SOC-HOD",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-66",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "b5f39dd8-c305-489d-9f7d-9adfd010a134",
    "designationName": "SOC Lead - I",
    "onFloorRoleId": "8366d816-724b-456b-9d0e-85399c2324b7",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "111cc3cd-6d35-43ce-be91-dde90d3d4015",
    "assignedRbacRoleName": "SOC Manager",
    "assignedRbacRoleCode": "SOC-Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-67",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "eb1f4dba-0d12-42c1-9e97-317c2ae55f6f",
    "designationName": "SOC Lead - II",
    "onFloorRoleId": "31ebb23e-f7d1-4c01-859b-67d24e96e2fb",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7",
    "assignedRbacRoleName": "SOC Senior Manager",
    "assignedRbacRoleCode": "SOC-Senior Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-68",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "b3c75d81-80a1-4240-8b1e-010000000001",
    "designationName": "SOC Manager",
    "onFloorRoleId": "b3c75d81-80a1-4240-8b1e-020000000001",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "111cc3cd-6d35-43ce-be91-dde90d3d4015",
    "assignedRbacRoleName": "SOC Manager",
    "assignedRbacRoleCode": "SOC-Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-69",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "b3c75d81-80a1-4240-8b1e-010000000002",
    "designationName": "SOC Senior Manager",
    "onFloorRoleId": "b3c75d81-80a1-4240-8b1e-020000000002",
    "onFloorRoleName": "Sr. Manager (Sr.Mng.)",
    "assignedRbacRoleId": "b2b2eb75-64bf-46cc-b24e-c2d34a9cc5c7",
    "assignedRbacRoleName": "SOC Senior Manager",
    "assignedRbacRoleCode": "SOC-Senior Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-70",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "444df30d-c195-42ad-b9a7-d80cdef69ccd",
    "designationName": "SOC Shift Lead - I",
    "onFloorRoleId": "6032fef5-eb05-42bd-9f10-72f12e154243",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "aba61e5b-422a-4461-b9da-8dba8f6d3f85",
    "assignedRbacRoleName": "SOC Shift / Team Leader",
    "assignedRbacRoleCode": "SOC-Team Leader",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-71",
    "departmentId": "3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60",
    "departmentName": "Services - Operations",
    "designationId": "c0f974c3-f49c-449a-9276-aa64ce501344",
    "designationName": "SOC Shift Lead - II",
    "onFloorRoleId": "218cd458-a6bc-43f8-8eda-02c89193fc35",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "aba61e5b-422a-4461-b9da-8dba8f6d3f85",
    "assignedRbacRoleName": "SOC Shift / Team Leader",
    "assignedRbacRoleCode": "SOC-Team Leader",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-72",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "e2b4be77-2b20-4064-974d-e6322e7240b4",
    "designationName": "Associate AI Engineer - Contractual",
    "onFloorRoleId": "fc382efa-48c8-4cc3-a724-2e54c1d6d6e0",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-73",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "e228c999-bf54-48b4-a373-d2bc9db88554",
    "designationName": "Associate Manager - I",
    "onFloorRoleId": "da59e567-3ee0-4a98-9b1e-83f8e6c01e2c",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "a3793f87-7f3c-41a1-a675-236fc1b710ab",
    "assignedRbacRoleName": "Testing Team Leader",
    "assignedRbacRoleCode": "Testing-Team Leader",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-74",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "168d11d7-ca26-4d61-b870-51779dc63023",
    "designationName": "Associate Manager - II",
    "onFloorRoleId": "20d077b9-894b-4bf3-b491-5df765e645f0",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "a3793f87-7f3c-41a1-a675-236fc1b710ab",
    "assignedRbacRoleName": "Testing Team Leader",
    "assignedRbacRoleCode": "Testing-Team Leader",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-75",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "aaf4ca75-5fa5-4de2-8353-a5e93beecb56",
    "designationName": "Associate Manager - III",
    "onFloorRoleId": "a3d0a1e1-b4a8-4ae5-8577-cd2019268494",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "a3793f87-7f3c-41a1-a675-236fc1b710ab",
    "assignedRbacRoleName": "Testing Team Leader",
    "assignedRbacRoleCode": "Testing-Team Leader",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-76",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "aaf4ca75-5fa5-4de2-8353-a5e93beecb56",
    "designationName": "Associate Manager - III",
    "onFloorRoleId": "8ec384d1-5b99-45c9-a95d-8f3325f56ea4",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "a3793f87-7f3c-41a1-a675-236fc1b710ab",
    "assignedRbacRoleName": "Testing Team Leader",
    "assignedRbacRoleCode": "Testing-Team Leader",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-77",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "3b7ea453-324e-40a0-bb41-77a0795d5af5",
    "designationName": "Associate Project Manager",
    "onFloorRoleId": "caec3c96-23a0-4e88-845c-05f792d0dd0c",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "29ad5710-1621-4c24-ac75-dedfc168ba1a",
    "assignedRbacRoleName": "Testing Project Manager",
    "assignedRbacRoleCode": "Testing-Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-78",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "c6c6cd04-6df3-4593-b686-e4b9d362c96f",
    "designationName": "DevSecOps Associate",
    "onFloorRoleId": "111000c1-ff0c-499c-a9cb-34febe2ac32d",
    "onFloorRoleName": "Team Leader (TL)",
    "assignedRbacRoleId": "a3793f87-7f3c-41a1-a675-236fc1b710ab",
    "assignedRbacRoleName": "Testing Team Leader",
    "assignedRbacRoleCode": "Testing-Team Leader",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-79",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "ae255622-ddcc-45ea-a699-8ec416fe57ab",
    "designationName": "DevSecOps Practitioner - I",
    "onFloorRoleId": "4e547334-4964-4dbe-81a4-a316d9394d03",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-80",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "35a6b1af-dc78-4632-a9f4-eedabdbdcb52",
    "designationName": "DevSecOps Practitioner - II",
    "onFloorRoleId": "8ea442c3-8ed7-4b6a-a3db-dd74706e9cce",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-81",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "767a00dd-6f09-4f64-a44e-8fbe901222af",
    "designationName": "DevSecOps Practitioner - III",
    "onFloorRoleId": "70206c08-0203-4784-8b09-d04d0cff95af",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-82",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "c1fa4328-a970-48a1-bc08-d50fe36bf44c",
    "designationName": "DevSecOps Specialist - II",
    "onFloorRoleId": "a583ec5f-f30a-4b03-9e35-6afc3f1aee8d",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "29ad5710-1621-4c24-ac75-dedfc168ba1a",
    "assignedRbacRoleName": "Testing Project Manager",
    "assignedRbacRoleCode": "Testing-Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-83",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "47dbf38f-c022-47bc-8444-d0dfb35ff3fd",
    "designationName": "Intern",
    "onFloorRoleId": "32d7cead-40d2-4d94-89fb-3e48d4160b7c",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "f29af015-7833-4f9a-ac57-6fbef5bf91ec",
    "assignedRbacRoleName": "Intern",
    "assignedRbacRoleCode": "Intern",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-84",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "a697a798-caaf-4248-8e4e-7e89096a9c30",
    "designationName": "Manager - I",
    "onFloorRoleId": "a3986a0e-d20f-4f20-a648-adcc724bb622",
    "onFloorRoleName": "Sr. Manager (Sr.Mng.)",
    "assignedRbacRoleId": "efc1df20-ca04-44a6-87b2-7cae1ff50a88",
    "assignedRbacRoleName": "Testing Senior Manager",
    "assignedRbacRoleCode": "Testing Senior Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-85",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "4f972924-350a-47fb-a6b6-f2b34bb6b621",
    "designationName": "PenTester - I",
    "onFloorRoleId": "a955782d-de73-4939-94f8-5cbf9a2461c2",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-86",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "0b6ab354-1fcf-4a00-9be3-e58e99c425ed",
    "designationName": "PenTester - II",
    "onFloorRoleId": "2cd464a5-b857-46fc-89ea-5dea92640964",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-87",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "163d8c87-8f90-4295-a926-2e912c625a1c",
    "designationName": "PenTester - III",
    "onFloorRoleId": "568997bf-75a1-46d9-9bdb-6fc05c3b2be1",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-88",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "9858c224-f97f-4ff8-908d-f46bd5e2243c",
    "designationName": "PenTester - IV",
    "onFloorRoleId": "3db9d726-85c9-4714-8c95-b5c6ebd45fd4",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-89",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "0a60fb48-99c4-44d0-8d97-ff687ccffc9f",
    "designationName": "Red Team Practitioner - II",
    "onFloorRoleId": "5a206a6a-dabc-4dfe-b28f-00cc01bc11da",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-90",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "85cc9fbe-98a4-464d-a638-05f40529c6de",
    "designationName": "Red Team Practitioner - III",
    "onFloorRoleId": "c45f4397-0370-43f5-98c7-f419234fa6d8",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-91",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "4b680e29-b4fb-4689-9afb-67a7f089f52b",
    "designationName": "Red Team Specialist - II",
    "onFloorRoleId": "c0cdbff8-5ed6-4e49-a562-549aecaacfd7",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "29ad5710-1621-4c24-ac75-dedfc168ba1a",
    "assignedRbacRoleName": "Testing Project Manager",
    "assignedRbacRoleCode": "Testing-Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-92",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "8af28894-fd3e-4dea-a4f0-bcb62b0e4e13",
    "designationName": "Senior Cloud Security Consultant - I",
    "onFloorRoleId": "8ab74d70-fc77-4767-87ce-13a6d3f911ce",
    "onFloorRoleName": "Manager (Mng.)",
    "assignedRbacRoleId": "29ad5710-1621-4c24-ac75-dedfc168ba1a",
    "assignedRbacRoleName": "Testing Project Manager",
    "assignedRbacRoleCode": "Testing-Manager",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-93",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "632bf06c-f646-4edd-bf2d-e3cd2e034c7f",
    "designationName": "Senior Pentester - I",
    "onFloorRoleId": "736d1ddd-c56a-4c4f-b266-bc4f6be6ed9c",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-94",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85",
    "designationName": "Senior Pentester - II",
    "onFloorRoleId": "5378a1ad-7ab3-40e5-9048-5165efab2140",
    "onFloorRoleName": "Team Member (TM)",
    "assignedRbacRoleId": "92aa9169-28d9-4754-a570-553b067642ed",
    "assignedRbacRoleName": "Testing Team Member",
    "assignedRbacRoleCode": "Testing-Team Member",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "dh-95",
    "departmentId": "0aed67b8-c454-439a-a07f-4f46d46d58af",
    "departmentName": "Services - Testing",
    "designationId": "b3c75d81-80a1-4240-8b1e-010000000004",
    "designationName": "Testing HOD",
    "onFloorRoleId": "b3c75d81-80a1-4240-8b1e-020000000004",
    "onFloorRoleName": "Head Of Department (HOD)",
    "assignedRbacRoleId": "c787fe3b-4b33-40ee-8794-c1148202f81a",
    "assignedRbacRoleName": "Testing Head of Department",
    "assignedRbacRoleCode": "Testing HOD",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  }
],
  emailDomains: [
  {
    "id": "edm-1",
    "domainName": "talakunchi.com",
    "displayName": "@talakunchi.com",
    "code": "talakunchi_com",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "edm-2",
    "domainName": "talakunchi.in",
    "displayName": "@talakunchi.in",
    "code": "talakunchi_in",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "edm-3",
    "domainName": "squad1.io",
    "displayName": "@squad1.io",
    "code": "squad1_io",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  }
],
  cities: [
  {
    "id": "stn-1",
    "name": "Churchgate",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Churchgate (Western Line)",
    "stationName": "Churchgate",
    "code": "churchgate",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-2",
    "name": "Marine Lines",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Marine Lines (Western Line)",
    "stationName": "Marine Lines",
    "code": "marine_lines",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-3",
    "name": "Charni Road",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Charni Road (Western Line)",
    "stationName": "Charni Road",
    "code": "charni_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-4",
    "name": "Grant Road",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Grant Road (Western Line)",
    "stationName": "Grant Road",
    "code": "grant_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-5",
    "name": "Mumbai Central",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Mumbai Central (Western Line)",
    "stationName": "Mumbai Central",
    "code": "mumbai_central",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-6",
    "name": "Mahalaxmi",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Mahalaxmi (Western Line)",
    "stationName": "Mahalaxmi",
    "code": "mahalaxmi",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-7",
    "name": "Lower Parel",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Lower Parel (Western Line)",
    "stationName": "Lower Parel",
    "code": "lower_parel",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-8",
    "name": "Prabhadevi",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Prabhadevi (Western Line)",
    "stationName": "Prabhadevi",
    "code": "prabhadevi",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-9",
    "name": "Dadar",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Dadar (Western Line)",
    "stationName": "Dadar",
    "code": "dadar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-10",
    "name": "Matunga Road",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Matunga Road (Western Line)",
    "stationName": "Matunga Road",
    "code": "matunga_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-11",
    "name": "Mahim",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Mahim (Western Line)",
    "stationName": "Mahim",
    "code": "mahim",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-12",
    "name": "Bandra",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Bandra (Western Line)",
    "stationName": "Bandra",
    "code": "bandra",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-13",
    "name": "Khar Road",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Khar Road (Western Line)",
    "stationName": "Khar Road",
    "code": "khar_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-14",
    "name": "Santacruz",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Santacruz (Western Line)",
    "stationName": "Santacruz",
    "code": "santacruz",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-15",
    "name": "Vile Parle",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Vile Parle (Western Line)",
    "stationName": "Vile Parle",
    "code": "vile_parle",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-16",
    "name": "Andheri",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Andheri (Western Line)",
    "stationName": "Andheri",
    "code": "andheri",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-17",
    "name": "Jogeshwari",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Jogeshwari (Western Line)",
    "stationName": "Jogeshwari",
    "code": "jogeshwari",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-18",
    "name": "Ram Mandir",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Ram Mandir (Western Line)",
    "stationName": "Ram Mandir",
    "code": "ram_mandir",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-19",
    "name": "Goregaon",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Goregaon (Western Line)",
    "stationName": "Goregaon",
    "code": "goregaon",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-20",
    "name": "Malad",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Malad (Western Line)",
    "stationName": "Malad",
    "code": "malad",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-21",
    "name": "Kandivali",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Kandivali (Western Line)",
    "stationName": "Kandivali",
    "code": "kandivali",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-22",
    "name": "Borivali",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Borivali (Western Line)",
    "stationName": "Borivali",
    "code": "borivali",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-23",
    "name": "Dahisar",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Dahisar (Western Line)",
    "stationName": "Dahisar",
    "code": "dahisar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-24",
    "name": "Mira Road",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Mira Road (Western Line)",
    "stationName": "Mira Road",
    "code": "mira_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-25",
    "name": "Bhayandar",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Bhayandar (Western Line)",
    "stationName": "Bhayandar",
    "code": "bhayandar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-26",
    "name": "Naigaon",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Naigaon (Western Line)",
    "stationName": "Naigaon",
    "code": "naigaon",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-27",
    "name": "Vasai Road",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Vasai Road (Western Line)",
    "stationName": "Vasai Road",
    "code": "vasai_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-28",
    "name": "Nallasopara",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Nallasopara (Western Line)",
    "stationName": "Nallasopara",
    "code": "nallasopara",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-29",
    "name": "Virar",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Virar (Western Line)",
    "stationName": "Virar",
    "code": "virar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-30",
    "name": "Vaitarna",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Vaitarna (Western Line)",
    "stationName": "Vaitarna",
    "code": "vaitarna",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-31",
    "name": "Saphale",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Saphale (Western Line)",
    "stationName": "Saphale",
    "code": "saphale",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-32",
    "name": "Kelve Road",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Kelve Road (Western Line)",
    "stationName": "Kelve Road",
    "code": "kelve_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-33",
    "name": "Palghar",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Palghar (Western Line)",
    "stationName": "Palghar",
    "code": "palghar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-34",
    "name": "Umroli",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Umroli (Western Line)",
    "stationName": "Umroli",
    "code": "umroli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-35",
    "name": "Boisar",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Boisar (Western Line)",
    "stationName": "Boisar",
    "code": "boisar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-36",
    "name": "Vangaon",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Vangaon (Western Line)",
    "stationName": "Vangaon",
    "code": "vangaon",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-37",
    "name": "Dahanu Road",
    "line": "Western Line",
    "subLabel": "Western Line",
    "value": "Dahanu Road (Western Line)",
    "stationName": "Dahanu Road",
    "code": "dahanu_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-38",
    "name": "CSMT (Chhatrapati Shivaji Maharaj Terminus)",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "CSMT (Central Line)",
    "stationName": "CSMT (Chhatrapati Shivaji Maharaj Terminus)",
    "code": "csmt_chhatrapati_shivaji_maharaj_terminus",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-39",
    "name": "Masjid",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Masjid (Central Line)",
    "stationName": "Masjid",
    "code": "masjid",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-40",
    "name": "Sandhurst Road",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Sandhurst Road (Central Line)",
    "stationName": "Sandhurst Road",
    "code": "sandhurst_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-41",
    "name": "Byculla",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Byculla (Central Line)",
    "stationName": "Byculla",
    "code": "byculla",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-42",
    "name": "Chinchpokli",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Chinchpokli (Central Line)",
    "stationName": "Chinchpokli",
    "code": "chinchpokli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-43",
    "name": "Currey Road",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Currey Road (Central Line)",
    "stationName": "Currey Road",
    "code": "currey_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-44",
    "name": "Parel",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Parel (Central Line)",
    "stationName": "Parel",
    "code": "parel",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-45",
    "name": "Dadar",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Dadar (Central Line)",
    "stationName": "Dadar",
    "code": "dadar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-46",
    "name": "Matunga",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Matunga (Central Line)",
    "stationName": "Matunga",
    "code": "matunga",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-47",
    "name": "Sion",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Sion (Central Line)",
    "stationName": "Sion",
    "code": "sion",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-48",
    "name": "Kurla",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Kurla (Central Line)",
    "stationName": "Kurla",
    "code": "kurla",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-49",
    "name": "Vidyavihar",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Vidyavihar (Central Line)",
    "stationName": "Vidyavihar",
    "code": "vidyavihar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-50",
    "name": "Ghatkopar",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Ghatkopar (Central Line)",
    "stationName": "Ghatkopar",
    "code": "ghatkopar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-51",
    "name": "Vikhroli",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Vikhroli (Central Line)",
    "stationName": "Vikhroli",
    "code": "vikhroli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-52",
    "name": "Kanjurmarg",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Kanjurmarg (Central Line)",
    "stationName": "Kanjurmarg",
    "code": "kanjurmarg",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-53",
    "name": "Bhandup",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Bhandup (Central Line)",
    "stationName": "Bhandup",
    "code": "bhandup",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-54",
    "name": "Nahur",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Nahur (Central Line)",
    "stationName": "Nahur",
    "code": "nahur",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-55",
    "name": "Mulund",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Mulund (Central Line)",
    "stationName": "Mulund",
    "code": "mulund",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-56",
    "name": "Thane",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Thane (Central Line)",
    "stationName": "Thane",
    "code": "thane",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-57",
    "name": "Kalwa",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Kalwa (Central Line)",
    "stationName": "Kalwa",
    "code": "kalwa",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-58",
    "name": "Mumbra",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Mumbra (Central Line)",
    "stationName": "Mumbra",
    "code": "mumbra",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-59",
    "name": "Diva",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Diva (Central Line)",
    "stationName": "Diva",
    "code": "diva",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-60",
    "name": "Kopar",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Kopar (Central Line)",
    "stationName": "Kopar",
    "code": "kopar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-61",
    "name": "Dombivli",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Dombivli (Central Line)",
    "stationName": "Dombivli",
    "code": "dombivli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-62",
    "name": "Thakurli",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Thakurli (Central Line)",
    "stationName": "Thakurli",
    "code": "thakurli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-63",
    "name": "Kalyan",
    "line": "Central Line",
    "subLabel": "Central Line",
    "value": "Kalyan (Central Line)",
    "stationName": "Kalyan",
    "code": "kalyan",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-64",
    "name": "Shahad",
    "line": "Central Line",
    "subLabel": "Central Line (Kasara Branch)",
    "value": "Shahad (Central Line)",
    "stationName": "Shahad",
    "code": "shahad",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-65",
    "name": "Ambivli",
    "line": "Central Line",
    "subLabel": "Central Line (Kasara Branch)",
    "value": "Ambivli (Central Line)",
    "stationName": "Ambivli",
    "code": "ambivli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-66",
    "name": "Titwala",
    "line": "Central Line",
    "subLabel": "Central Line (Kasara Branch)",
    "value": "Titwala (Central Line)",
    "stationName": "Titwala",
    "code": "titwala",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-67",
    "name": "Khadavli",
    "line": "Central Line",
    "subLabel": "Central Line (Kasara Branch)",
    "value": "Khadavli (Central Line)",
    "stationName": "Khadavli",
    "code": "khadavli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-68",
    "name": "Vasind",
    "line": "Central Line",
    "subLabel": "Central Line (Kasara Branch)",
    "value": "Vasind (Central Line)",
    "stationName": "Vasind",
    "code": "vasind",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-69",
    "name": "Asangaon",
    "line": "Central Line",
    "subLabel": "Central Line (Kasara Branch)",
    "value": "Asangaon (Central Line)",
    "stationName": "Asangaon",
    "code": "asangaon",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-70",
    "name": "Atgaon",
    "line": "Central Line",
    "subLabel": "Central Line (Kasara Branch)",
    "value": "Atgaon (Central Line)",
    "stationName": "Atgaon",
    "code": "atgaon",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-71",
    "name": "Thansit",
    "line": "Central Line",
    "subLabel": "Central Line (Kasara Branch)",
    "value": "Thansit (Central Line)",
    "stationName": "Thansit",
    "code": "thansit",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-72",
    "name": "Khardi",
    "line": "Central Line",
    "subLabel": "Central Line (Kasara Branch)",
    "value": "Khardi (Central Line)",
    "stationName": "Khardi",
    "code": "khardi",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-73",
    "name": "Umbermali",
    "line": "Central Line",
    "subLabel": "Central Line (Kasara Branch)",
    "value": "Umbermali (Central Line)",
    "stationName": "Umbermali",
    "code": "umbermali",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-74",
    "name": "Kasara",
    "line": "Central Line",
    "subLabel": "Central Line (Kasara Branch)",
    "value": "Kasara (Central Line)",
    "stationName": "Kasara",
    "code": "kasara",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-75",
    "name": "Vithalwadi",
    "line": "Central Line",
    "subLabel": "Central Line (Karjat Branch)",
    "value": "Vithalwadi (Central Line)",
    "stationName": "Vithalwadi",
    "code": "vithalwadi",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-76",
    "name": "Ulhasnagar",
    "line": "Central Line",
    "subLabel": "Central Line (Karjat Branch)",
    "value": "Ulhasnagar (Central Line)",
    "stationName": "Ulhasnagar",
    "code": "ulhasnagar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-77",
    "name": "Ambernath",
    "line": "Central Line",
    "subLabel": "Central Line (Karjat Branch)",
    "value": "Ambernath (Central Line)",
    "stationName": "Ambernath",
    "code": "ambernath",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-78",
    "name": "Badlapur",
    "line": "Central Line",
    "subLabel": "Central Line (Karjat Branch)",
    "value": "Badlapur (Central Line)",
    "stationName": "Badlapur",
    "code": "badlapur",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-79",
    "name": "Vangani",
    "line": "Central Line",
    "subLabel": "Central Line (Karjat Branch)",
    "value": "Vangani (Central Line)",
    "stationName": "Vangani",
    "code": "vangani",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-80",
    "name": "Shelu",
    "line": "Central Line",
    "subLabel": "Central Line (Karjat Branch)",
    "value": "Shelu (Central Line)",
    "stationName": "Shelu",
    "code": "shelu",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-81",
    "name": "Neral",
    "line": "Central Line",
    "subLabel": "Central Line (Karjat Branch)",
    "value": "Neral (Central Line)",
    "stationName": "Neral",
    "code": "neral",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-82",
    "name": "Bhivpuri Road",
    "line": "Central Line",
    "subLabel": "Central Line (Karjat Branch)",
    "value": "Bhivpuri Road (Central Line)",
    "stationName": "Bhivpuri Road",
    "code": "bhivpuri_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-83",
    "name": "Karjat",
    "line": "Central Line",
    "subLabel": "Central Line (Karjat Branch)",
    "value": "Karjat (Central Line)",
    "stationName": "Karjat",
    "code": "karjat",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-84",
    "name": "Palasdari",
    "line": "Central Line",
    "subLabel": "Central Line (Khopoli Branch)",
    "value": "Palasdari (Central Line)",
    "stationName": "Palasdari",
    "code": "palasdari",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-85",
    "name": "Kelavli",
    "line": "Central Line",
    "subLabel": "Central Line (Khopoli Branch)",
    "value": "Kelavli (Central Line)",
    "stationName": "Kelavli",
    "code": "kelavli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-86",
    "name": "Dolavli",
    "line": "Central Line",
    "subLabel": "Central Line (Khopoli Branch)",
    "value": "Dolavli (Central Line)",
    "stationName": "Dolavli",
    "code": "dolavli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-87",
    "name": "Lowjee",
    "line": "Central Line",
    "subLabel": "Central Line (Khopoli Branch)",
    "value": "Lowjee (Central Line)",
    "stationName": "Lowjee",
    "code": "lowjee",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-88",
    "name": "Khopoli",
    "line": "Central Line",
    "subLabel": "Central Line (Khopoli Branch)",
    "value": "Khopoli (Central Line)",
    "stationName": "Khopoli",
    "code": "khopoli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-89",
    "name": "CSMT (Chhatrapati Shivaji Maharaj Terminus)",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "CSMT (Harbour Line)",
    "stationName": "CSMT (Chhatrapati Shivaji Maharaj Terminus)",
    "code": "csmt_chhatrapati_shivaji_maharaj_terminus",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-90",
    "name": "Masjid",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Masjid (Harbour Line)",
    "stationName": "Masjid",
    "code": "masjid",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-91",
    "name": "Sandhurst Road",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Sandhurst Road (Harbour Line)",
    "stationName": "Sandhurst Road",
    "code": "sandhurst_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-92",
    "name": "Dockyard Road",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Dockyard Road (Harbour Line)",
    "stationName": "Dockyard Road",
    "code": "dockyard_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-93",
    "name": "Reay Road",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Reay Road (Harbour Line)",
    "stationName": "Reay Road",
    "code": "reay_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-94",
    "name": "Cotton Green",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Cotton Green (Harbour Line)",
    "stationName": "Cotton Green",
    "code": "cotton_green",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-95",
    "name": "Sewri",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Sewri (Harbour Line)",
    "stationName": "Sewri",
    "code": "sewri",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-96",
    "name": "Vadala Road",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Vadala Road (Harbour Line)",
    "stationName": "Vadala Road",
    "code": "vadala_road",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-97",
    "name": "Kings Circle",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Kings Circle (Harbour Line)",
    "stationName": "Kings Circle",
    "code": "kings_circle",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-98",
    "name": "GTB Nagar (Guru Tegh Bahadur Nagar)",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "GTB Nagar (Harbour Line)",
    "stationName": "GTB Nagar (Guru Tegh Bahadur Nagar)",
    "code": "gtb_nagar_guru_tegh_bahadur_nagar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-99",
    "name": "Chunabhatti",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Chunabhatti (Harbour Line)",
    "stationName": "Chunabhatti",
    "code": "chunabhatti",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-100",
    "name": "Kurla",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Kurla (Harbour Line)",
    "stationName": "Kurla",
    "code": "kurla",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-101",
    "name": "Tilak Nagar",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Tilak Nagar (Harbour Line)",
    "stationName": "Tilak Nagar",
    "code": "tilak_nagar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-102",
    "name": "Chembur",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Chembur (Harbour Line)",
    "stationName": "Chembur",
    "code": "chembur",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-103",
    "name": "Govandi",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Govandi (Harbour Line)",
    "stationName": "Govandi",
    "code": "govandi",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-104",
    "name": "Mankhurd",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Mankhurd (Harbour Line)",
    "stationName": "Mankhurd",
    "code": "mankhurd",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-105",
    "name": "Vashi",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Vashi (Harbour Line)",
    "stationName": "Vashi",
    "code": "vashi",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-106",
    "name": "Sanpada",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Sanpada (Harbour Line)",
    "stationName": "Sanpada",
    "code": "sanpada",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-107",
    "name": "Juinagar",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Juinagar (Harbour Line)",
    "stationName": "Juinagar",
    "code": "juinagar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-108",
    "name": "Nerul",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Nerul (Harbour Line)",
    "stationName": "Nerul",
    "code": "nerul",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-109",
    "name": "Seawoods-Darave",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Seawoods-Darave (Harbour Line)",
    "stationName": "Seawoods-Darave",
    "code": "seawoods-darave",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-110",
    "name": "CBD Belapur",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "CBD Belapur (Harbour Line)",
    "stationName": "CBD Belapur",
    "code": "cbd_belapur",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-111",
    "name": "Kharghar",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Kharghar (Harbour Line)",
    "stationName": "Kharghar",
    "code": "kharghar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-112",
    "name": "Mansarovar",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Mansarovar (Harbour Line)",
    "stationName": "Mansarovar",
    "code": "mansarovar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-113",
    "name": "Khandeshwar",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Khandeshwar (Harbour Line)",
    "stationName": "Khandeshwar",
    "code": "khandeshwar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-114",
    "name": "Panvel",
    "line": "Harbour Line",
    "subLabel": "Harbour Line",
    "value": "Panvel (Harbour Line)",
    "stationName": "Panvel",
    "code": "panvel",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-115",
    "name": "Thane",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Thane (Trans-Harbour Line)",
    "stationName": "Thane",
    "code": "thane",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-116",
    "name": "Digha Gaon",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Digha Gaon (Trans-Harbour Line)",
    "stationName": "Digha Gaon",
    "code": "digha_gaon",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-117",
    "name": "Airoli",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Airoli (Trans-Harbour Line)",
    "stationName": "Airoli",
    "code": "airoli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-118",
    "name": "Rabale",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Rabale (Trans-Harbour Line)",
    "stationName": "Rabale",
    "code": "rabale",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-119",
    "name": "Ghansoli",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Ghansoli (Trans-Harbour Line)",
    "stationName": "Ghansoli",
    "code": "ghansoli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-120",
    "name": "Kopar Khairane",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Kopar Khairane (Trans-Harbour Line)",
    "stationName": "Kopar Khairane",
    "code": "kopar_khairane",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-121",
    "name": "Turbhe",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Turbhe (Trans-Harbour Line)",
    "stationName": "Turbhe",
    "code": "turbhe",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-122",
    "name": "Sanpada",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Sanpada (Trans-Harbour Line)",
    "stationName": "Sanpada",
    "code": "sanpada",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-123",
    "name": "Vashi",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Vashi (Trans-Harbour Line)",
    "stationName": "Vashi",
    "code": "vashi",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-124",
    "name": "Juinagar",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Juinagar (Trans-Harbour Line)",
    "stationName": "Juinagar",
    "code": "juinagar",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-125",
    "name": "Nerul",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Nerul (Trans-Harbour Line)",
    "stationName": "Nerul",
    "code": "nerul",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-126",
    "name": "Seawoods-Darave",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Seawoods-Darave (Trans-Harbour Line)",
    "stationName": "Seawoods-Darave",
    "code": "seawoods-darave",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-127",
    "name": "CBD Belapur",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "CBD Belapur (Trans-Harbour Line)",
    "stationName": "CBD Belapur",
    "code": "cbd_belapur",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "stn-128",
    "name": "Panvel",
    "line": "Trans-Harbour Line",
    "subLabel": "Trans-Harbour Line",
    "value": "Panvel (Trans-Harbour Line)",
    "stationName": "Panvel",
    "code": "panvel",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  }
],
  tkIdFormats: [
  {
    "id": "tkf-1",
    "prefix": "TK",
    "name": "Full-Time Employee ID",
    "targetCategory": "Full-Time Employee",
    "delimiter": "-",
    "digits": 4,
    "sampleFormat": "TK-0001",
    "currentSequence": 65,
    "isActive": true,
    "description": "Standard employee identifier for permanent full-time personnel across all departments.",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tkf-2",
    "prefix": "TKI",
    "name": "Intern / Trainee ID",
    "targetCategory": "Intern",
    "delimiter": "-",
    "digits": 4,
    "sampleFormat": "TKI-0001",
    "currentSequence": 14,
    "isActive": true,
    "description": "Specialized employee identification prefix for student interns, apprentices, and technical trainees.",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tkf-3",
    "prefix": "TKC",
    "name": "Contractor / Consultant ID",
    "targetCategory": "Consultant / Contractor",
    "delimiter": "-",
    "digits": 4,
    "sampleFormat": "TKC-0001",
    "currentSequence": 6,
    "isActive": true,
    "description": "Dedicated identification prefix for external contractors, advisors, and delivery specialists.",
    "createdAt": "2026-01-10T08:00:00.000Z"
  }
],
  tkIds: [
  {
    "id": "tk-1",
    "code": "TK-0001",
    "prefix": "TK",
    "assignedTo": "Vikrant Malhotra",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-2",
    "code": "TK-0002",
    "prefix": "TK",
    "assignedTo": "Dhanshree Pansare",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-3",
    "code": "TK-0003",
    "prefix": "TK",
    "assignedTo": "Kunal Deshmukh",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-4",
    "code": "TK-0004",
    "prefix": "TK",
    "assignedTo": "Admin User",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-5",
    "code": "TK-0005",
    "prefix": "TK",
    "assignedTo": "Accounts User",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-6",
    "code": "TK-0006",
    "prefix": "TK",
    "assignedTo": "HR User",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-7",
    "code": "TK-0007",
    "prefix": "TK",
    "assignedTo": "Sales User",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-8",
    "code": "TK-0008",
    "prefix": "TK",
    "assignedTo": "Nikhil Khanna",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-9",
    "code": "TK-0009",
    "prefix": "TK",
    "assignedTo": "Pooja Sharma",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-10",
    "code": "TK-0010",
    "prefix": "TK",
    "assignedTo": "Rohit Verma",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-11",
    "code": "TK-0011",
    "prefix": "TK",
    "assignedTo": "Sneha Reddy",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-12",
    "code": "TK-0012",
    "prefix": "TK",
    "assignedTo": "Rahul Gupta",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-13",
    "code": "TK-0013",
    "prefix": "TK",
    "assignedTo": "Riya Kapoor",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-14",
    "code": "TK-0014",
    "prefix": "TK",
    "assignedTo": "Pradeep Singh",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-15",
    "code": "TK-0015",
    "prefix": "TK",
    "assignedTo": "Kavya Desai",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-16",
    "code": "TK-0016",
    "prefix": "TK",
    "assignedTo": "Rajesh Kadam",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-17",
    "code": "TK-0017",
    "prefix": "TK",
    "assignedTo": "Deepak Sawant",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-18",
    "code": "TK-0018",
    "prefix": "TK",
    "assignedTo": "Vikram Shah",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-19",
    "code": "TK-0019",
    "prefix": "TK",
    "assignedTo": "Sneha Iyer",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-20",
    "code": "TK-0020",
    "prefix": "TK",
    "assignedTo": "Nikhil Rao",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-21",
    "code": "TK-0021",
    "prefix": "TK",
    "assignedTo": "Amit Pandey",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-22",
    "code": "TK-0022",
    "prefix": "TK",
    "assignedTo": "Karthik Bose",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-23",
    "code": "TK-0023",
    "prefix": "TK",
    "assignedTo": "Ankit Verma",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-24",
    "code": "TK-0024",
    "prefix": "TK",
    "assignedTo": "Aditya Reddy",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-25",
    "code": "TK-0025",
    "prefix": "TK",
    "assignedTo": "Manish Tiwari",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-26",
    "code": "TK-0026",
    "prefix": "TK",
    "assignedTo": "Pooja Nair",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-27",
    "code": "TK-0027",
    "prefix": "TK",
    "assignedTo": "Anita Desai",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-28",
    "code": "TK-0028",
    "prefix": "TK",
    "assignedTo": "Aarav Mehta",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-29",
    "code": "TK-0029",
    "prefix": "TK",
    "assignedTo": "Sana Iyer",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-30",
    "code": "TK-0030",
    "prefix": "TK",
    "assignedTo": "Priya Verma",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-31",
    "code": "TK-0031",
    "prefix": "TK",
    "assignedTo": "Siddharth Roy",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-32",
    "code": "TK-0032",
    "prefix": "TK",
    "assignedTo": "Ira Kapoor",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-33",
    "code": "TK-0033",
    "prefix": "TK",
    "assignedTo": "Meera Nambiar",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-34",
    "code": "TK-0034",
    "prefix": "TK",
    "assignedTo": "Rajat Singhal",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-35",
    "code": "TK-0035",
    "prefix": "TK",
    "assignedTo": "Swati Mishra",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-36",
    "code": "TK-0036",
    "prefix": "TK",
    "assignedTo": "Varun Saxena",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-37",
    "code": "TK-0037",
    "prefix": "TK",
    "assignedTo": "Girish Shenoy",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-38",
    "code": "TK-0038",
    "prefix": "TK",
    "assignedTo": "Suresh Pillai",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-39",
    "code": "TK-0039",
    "prefix": "TK",
    "assignedTo": "Alok Kumar",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-40",
    "code": "TK-0040",
    "prefix": "TK",
    "assignedTo": "Divya Rao",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-41",
    "code": "TK-0041",
    "prefix": "TK",
    "assignedTo": "Manoj Bhatt",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-42",
    "code": "TK-0042",
    "prefix": "TK",
    "assignedTo": "Gaurav Joshi",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-43",
    "code": "TK-0043",
    "prefix": "TK",
    "assignedTo": "Kiran Mathur",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-44",
    "code": "TK-0044",
    "prefix": "TK",
    "assignedTo": "Ramesh Nair",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-45",
    "code": "TK-0045",
    "prefix": "TK",
    "assignedTo": "Priya Sharma",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-46",
    "code": "TK-0046",
    "prefix": "TK",
    "assignedTo": "Arjun Singh",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-47",
    "code": "TK-0047",
    "prefix": "TK",
    "assignedTo": "Meera Joshi",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-48",
    "code": "TK-0048",
    "prefix": "TK",
    "assignedTo": "Dev Patel",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-49",
    "code": "TK-0049",
    "prefix": "TK",
    "assignedTo": "Kavya Nair",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-50",
    "code": "TK-0654",
    "prefix": "TK",
    "assignedTo": "Vikram Pansare",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-51",
    "code": "TK-0669",
    "prefix": "TK",
    "assignedTo": "Sachin Shinde",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-52",
    "code": "TK-0670",
    "prefix": "TK",
    "assignedTo": "Prashant Kadam",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-53",
    "code": "TK-0676",
    "prefix": "TK",
    "assignedTo": "Usman Idrisi",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-54",
    "code": "TK-0677",
    "prefix": "TK",
    "assignedTo": "Rishabh Singh",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-55",
    "code": "TK-1234",
    "prefix": "TK",
    "assignedTo": "Omkar Gaikwad",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-56",
    "code": "TKI-0001",
    "prefix": "TK",
    "assignedTo": "Ananya Verma",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-57",
    "code": "TKI-0002",
    "prefix": "TK",
    "assignedTo": "Rohan Joshi",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-58",
    "code": "TKI-0003",
    "prefix": "TK",
    "assignedTo": "Tanvi Deshmukh",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-59",
    "code": "TKI-0004",
    "prefix": "TK",
    "assignedTo": "Ayush Saxena",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-60",
    "code": "TKI-0005",
    "prefix": "TK",
    "assignedTo": "Simran Kaur",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-61",
    "code": "TKI-0006",
    "prefix": "TKI",
    "assignedTo": "Naveen Choudhary",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-62",
    "code": "TKI-0007",
    "prefix": "TKI",
    "assignedTo": "Bhavna Patel",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-63",
    "code": "TKI-0008",
    "prefix": "TKI",
    "assignedTo": "Harsh Wardhan",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-64",
    "code": "TKI-0009",
    "prefix": "TKI",
    "assignedTo": "Akash Jain",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-65",
    "code": "TKI-0010",
    "prefix": "TKI",
    "assignedTo": "Kunal Mehra",
    "status": "Assigned",
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "tk-66",
    "code": "TK-0066",
    "prefix": "TK",
    "assignedTo": "",
    "status": "Available",
    "createdAt": "2026-01-15T08:00:00.000Z"
  },
  {
    "id": "tk-67",
    "code": "TK-0067",
    "prefix": "TK",
    "assignedTo": "",
    "status": "Available",
    "createdAt": "2026-01-15T08:00:00.000Z"
  },
  {
    "id": "tk-68",
    "code": "TK-0068",
    "prefix": "TK",
    "assignedTo": "",
    "status": "Available",
    "createdAt": "2026-01-15T08:00:00.000Z"
  },
  {
    "id": "tk-69",
    "code": "TK-0069",
    "prefix": "TK",
    "assignedTo": "",
    "status": "Available",
    "createdAt": "2026-01-15T08:00:00.000Z"
  },
  {
    "id": "tk-70",
    "code": "TK-0070",
    "prefix": "TK",
    "assignedTo": "",
    "status": "Available",
    "createdAt": "2026-01-15T08:00:00.000Z"
  },
  {
    "id": "tk-71",
    "code": "TKI-0071",
    "prefix": "TKI",
    "assignedTo": "",
    "status": "Available",
    "createdAt": "2026-01-15T08:00:00.000Z"
  },
  {
    "id": "tk-72",
    "code": "TKI-0072",
    "prefix": "TKI",
    "assignedTo": "",
    "status": "Reserved",
    "createdAt": "2026-01-15T08:00:00.000Z"
  },
  {
    "id": "tk-73",
    "code": "TKI-0073",
    "prefix": "TKI",
    "assignedTo": "",
    "status": "Reserved",
    "createdAt": "2026-01-15T08:00:00.000Z"
  },
  {
    "id": "tk-74",
    "code": "TKI-0074",
    "prefix": "TKI",
    "assignedTo": "",
    "status": "Reserved",
    "createdAt": "2026-01-15T08:00:00.000Z"
  }
],
  businessUnits: [
  {
    "id": "bu-1",
    "name": "Talakunchi Networks Private Limited",
    "code": "talakunchi_networks_private_limited",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  }
],
  workLocations: [
  {
    "id": "wl-1",
    "name": "Navare Plaza, Dombivli",
    "code": "navare_plaza_dombivli",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "wl-2",
    "name": "Onsite",
    "code": "onsite",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "wl-3",
    "name": "Suvidha Square, Andheri",
    "code": "suvidha_square_andheri",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  }
],
  graduationDegrees: [
  {
    "id": "gd-1",
    "name": "B.A.",
    "code": "ba",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "gd-2",
    "name": "B.Com",
    "code": "bcom",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "gd-3",
    "name": "B.E.",
    "code": "be",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "gd-4",
    "name": "B.Pharm",
    "code": "bpharm",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "gd-5",
    "name": "B.Sc",
    "code": "bsc",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "gd-6",
    "name": "B.Tech",
    "code": "btech",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "gd-7",
    "name": "BBA",
    "code": "bba",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "gd-8",
    "name": "BCA",
    "code": "bca",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "gd-9",
    "name": "BE",
    "code": "be",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "gd-10",
    "name": "BS",
    "code": "bs",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  }
],
  postGraduationDegrees: [
  {
    "id": "pgd-1",
    "name": "M.A.",
    "code": "ma",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "pgd-2",
    "name": "M.Com",
    "code": "mcom",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "pgd-3",
    "name": "M.Sc",
    "code": "msc",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "pgd-4",
    "name": "M.Tech",
    "code": "mtech",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "pgd-5",
    "name": "MBA",
    "code": "mba",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "pgd-6",
    "name": "MCA",
    "code": "mca",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "pgd-7",
    "name": "ME",
    "code": "me",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "pgd-8",
    "name": "MS",
    "code": "ms",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "pgd-9",
    "name": "NA",
    "code": "na",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  }
],
  certifications: [
  {
    "id": "cert-1",
    "name": "Blue Team Level 1 and 2",
    "code": "blue_team_level_1_and_2",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-2",
    "name": "Certified Cloud Security Professional (CCSP)",
    "code": "certified_cloud_security_professional_(ccsp)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-3",
    "name": "Certified Ethical Hacker (CEH)",
    "code": "certified_ethical_hacker_(ceh)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-4",
    "name": "Certified in Risk and Information Systems Control (CRISC)",
    "code": "certified_in_risk_and_information_systems_control_",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-5",
    "name": "Certified Information Security Manager (CISM)",
    "code": "certified_information_security_manager_(cism)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-6",
    "name": "Certified Information Systems Auditor (CISA)",
    "code": "certified_information_systems_auditor_(cisa)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-7",
    "name": "Certified Information Systems Security Professional (CISSP)",
    "code": "certified_information_systems_security_professiona",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-8",
    "name": "Certified Threat Intelligence Analyst (CTIA)",
    "code": "certified_threat_intelligence_analyst_(ctia)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-9",
    "name": "CompTIA Security+",
    "code": "comptia_securityplus",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-10",
    "name": "cPTS",
    "code": "cpts",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-11",
    "name": "CRT",
    "code": "crt",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-12",
    "name": "CRTE",
    "code": "crte",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-13",
    "name": "CRTP",
    "code": "crtp",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-14",
    "name": "EC-Council Certified Incident Handler (ECIH)",
    "code": "ec_council_certified_incident_handler_(ecih)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-15",
    "name": "eCPPT",
    "code": "ecppt",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-16",
    "name": "eLearnSecurity Certified Digital Forensics Professional (eCDFP)",
    "code": "elearnsecurity_certified_digital_forensics_profess",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-17",
    "name": "eLearnSecurity Certified Incident Responder (eCIR)",
    "code": "elearnsecurity_certified_incident_responder_(ecir)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-18",
    "name": "eLearnSecurity Certified Threat Hunting Professional (eCTHP)",
    "code": "elearnsecurity_certified_threat_hunting_profession",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-19",
    "name": "ISO 22301",
    "code": "iso_22301",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-20",
    "name": "ISO 27001",
    "code": "iso_27001",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-21",
    "name": "ISO/IEC 42001",
    "code": "iso_iec_42001",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-22",
    "name": "Licensed Penetration Tester (LPT)",
    "code": "licensed_penetration_tester_(lpt)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-23",
    "name": "Offensive Security Certified Expert 3 (OSCE3)",
    "code": "offensive_security_certified_expert_3_(osce3)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-24",
    "name": "Offensive Security Certified Professional (OSCP)",
    "code": "offensive_security_certified_professional_(oscp)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-25",
    "name": "Offensive Security Experienced Penetration Tester (OSEP)",
    "code": "offensive_security_experienced_penetration_tester_",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-26",
    "name": "Offensive Security Web Expert (OSWE)",
    "code": "offensive_security_web_expert_(oswe)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-27",
    "name": "Offensive Security Wireless Professional (OSWP)",
    "code": "offensive_security_wireless_professional_(oswp)",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-28",
    "name": "OffSec Foundational Security Operations and Defensive Analysis (OSDA)",
    "code": "offsec_foundational_security_operations_and_defens",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  },
  {
    "id": "cert-29",
    "name": "PNPT",
    "code": "pnpt",
    "isActive": true,
    "createdAt": "2026-01-10T08:00:00.000Z"
  }
],
};
