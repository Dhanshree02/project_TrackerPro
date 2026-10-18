import type { CustomerMastersState, ProjectMasterItem } from "./types";

export const MASTER_CONTRACT_TYPES: string[] = [];
export const MASTER_GROUPS: string[] = [];
export const MASTER_DEPARTMENTS: string[] = [];
export const MASTER_SERVICES: string[] = [];

export const INITIAL_PROJECT_MASTERS: ProjectMasterItem[] = [];

export const INITIAL_CUSTOMER_MASTERS: CustomerMastersState = {
  designations: [],
  industries: [],
  countries: [],
  cities: [],
  contactTypes: [],
};
