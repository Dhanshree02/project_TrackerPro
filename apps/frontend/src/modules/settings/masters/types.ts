export interface ProjectMasterItem {
  id: string;
  contractType: string;
  group?: string;
  department: string;
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
