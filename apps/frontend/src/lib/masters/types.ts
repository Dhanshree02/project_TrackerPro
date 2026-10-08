export interface ProjectMasterItem {
  id: string;
  contractType: string;
  group?: string;
  department: string;
  subDepartment?: string;
  service: string;
  tools: string;
  duration: string;
  unitPrice: number;
  createdAt: string;
}

export type CustomerMasterCategory =
  | "designations"
  | "industries"
  | "countries"
  | "cities"
  | "contactTypes";

export interface SimpleMasterItem {
  id: string;
  name: string;
  code?: string;
  description?: string;
  country?: string;
  countryId?: string;
  countryName?: string;
  phoneCode?: string;
  phoneDigits?: number;
  createdAt: string;
}

export interface CustomerMastersState {
  designations: SimpleMasterItem[];
  industries: SimpleMasterItem[];
  countries: SimpleMasterItem[];
  cities: SimpleMasterItem[];
  contactTypes: SimpleMasterItem[];
}

export interface MasterCategoryMeta {
  id: string;
  name: string;
  description: string;
  icon?: string;
  count?: number;
}

// ── Resource Master Types ──────────────────────────────────────────────────
export type ResourceMasterCategory =
  | "hierarchy"
  | "emailDomains"
  | "businessUnits"
  | "workLocations"
  | "graduationDegrees"
  | "postGraduationDegrees"
  | "certifications";

export interface DepartmentHierarchyItem {
  id: string;
  departmentId?: string;
  departmentName: string;
  designationId?: string;
  designationName: string;
  onFloorRoleId?: string;
  onFloorRoleName: string;
  assignedRbacRoleId?: string;
  assignedRbacRoleName: string;
  assignedRbacRoleCode?: string;
  isActive?: boolean;
  createdAt: string;
}

export interface EmailDomainItem {
  id: string;
  domainName: string; // e.g. talakunchi.in
  displayName: string; // e.g. @talakunchi.in
  code?: string;
  isActive: boolean;
  createdAt: string;
}

export interface CityMasterItem {
  id: string;
  name: string; // Station / Locality e.g. "Andheri", "Churchgate"
  line: string; // "Western Line" | "Central Line" | "Harbour Line" | "Trans-Harbour Line" | string
  subLabel?: string; // "Western Line"
  value: string; // "Andheri (Western Line)"
  code?: string;
  stationName?: string;
  isActive?: boolean;
  createdAt: string;
}

export interface TkIdFormatItem {
  id: string;
  prefix: string; // "TK", "TKI", "TKC", etc.
  name: string; // e.g. "Full-Time Staff ID", "Intern ID"
  targetCategory: string; // "Full-Time Employee", "Intern", "Consultant / Contractor"
  delimiter: string; // "-", "/", or ""
  digits: number; // 4
  sampleFormat: string; // "TK-0001", "TKI-0001"
  currentSequence: number; // 65, 12, etc.
  isActive: boolean;
  description?: string;
  createdAt: string;
}

export interface TkIdMasterItem {
  id: string;
  code: string; // e.g. TK-0001, TKI-0001
  prefix?: string; // e.g. TK, TKI
  assignedTo?: string; // Employee Name or blank if available
  status: "Assigned" | "Available" | "Reserved";
  createdAt: string;
}

export interface SimpleResourceMasterItem {
  id: string;
  name: string;
  code?: string;
  description?: string;
  isActive?: boolean;
  createdAt: string;
}

export interface ResourceMastersState {
  departmentHierarchy: DepartmentHierarchyItem[];
  emailDomains: EmailDomainItem[];
  cities: CityMasterItem[];
  tkIdFormats: TkIdFormatItem[];
  tkIds: TkIdMasterItem[];
  businessUnits: SimpleResourceMasterItem[];
  workLocations: SimpleResourceMasterItem[];
  graduationDegrees: SimpleResourceMasterItem[];
  postGraduationDegrees: SimpleResourceMasterItem[];
  certifications: SimpleResourceMasterItem[];
}
