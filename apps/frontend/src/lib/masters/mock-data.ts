import {
  DEFAULT_CONTRACT_TYPES,
  DEFAULT_DEPT_SERVICES,
  DEFAULT_DEPT_GROUPS,
} from "./project-catalog-store";

export const MASTER_CONTRACT_TYPES = DEFAULT_CONTRACT_TYPES;
export const MASTER_GROUPS = MASTER_CONTRACT_TYPES;

export const MASTER_DEPARTMENTS = Object.keys(DEFAULT_DEPT_SERVICES);

export const MASTER_SERVICES = Object.values(DEFAULT_DEPT_SERVICES)
  .flatMap((svcs) => svcs.map((s) => s.name))
  .filter((v, idx, arr) => arr.indexOf(v) === idx);

export const INITIAL_PROJECT_MASTERS: ProjectMasterItem[] = Object.entries(DEFAULT_DEPT_SERVICES).flatMap(
  ([dept, svcs], deptIdx) =>
    svcs.map((svc, svcIdx) => {
      const isResource = DEFAULT_DEPT_GROUPS[dept] === "Resource";
      const contractType = isResource ? "Resource Based" : "Scope Based";
      return {
        id: `pm-${svc.id.toLowerCase()}`,
        contractType,
        group: contractType,
        department: dept,
        service: svc.name,
        tools: svc.tool,
        duration: `${svc.days} Days`,
        unitPrice: svc.unitPrice,
        createdAt: new Date(2026, 0, 10 + ((deptIdx * 3 + svcIdx) % 30)).toISOString(),
      };
    }),
);

export const INITIAL_CUSTOMER_MASTERS: CustomerMastersState = {
  designations: [
    { id: "des-1", name: "Managing Director", createdAt: "2026-01-10T08:00:00.000Z" },
    { id: "des-2", name: "Chief Executive Officer (CEO)", createdAt: "2026-01-10T08:05:00.000Z" },
    { id: "des-3", name: "Chief Technology Officer (CTO)", createdAt: "2026-01-10T08:10:00.000Z" },
    { id: "des-4", name: "Vice President of Engineering", createdAt: "2026-01-10T08:15:00.000Z" },
    { id: "des-5", name: "Project Manager", createdAt: "2026-01-10T08:20:00.000Z" },
    { id: "des-6", name: "Delivery Lead", createdAt: "2026-01-10T08:25:00.000Z" },
    { id: "des-7", name: "Procurement Head", createdAt: "2026-01-10T08:30:00.000Z" },
    { id: "des-8", name: "Product Owner", createdAt: "2026-01-10T08:35:00.000Z" },
  ],
  industries: [
    { id: "ind-1", name: "Information Technology & Services", createdAt: "2026-01-10T08:00:00.000Z" },
    { id: "ind-2", name: "Banking & Financial Services (BFSI)", createdAt: "2026-01-10T08:05:00.000Z" },
    { id: "ind-3", name: "Healthcare & Life Sciences", createdAt: "2026-01-10T08:10:00.000Z" },
    { id: "ind-4", name: "Retail & E-Commerce", createdAt: "2026-01-10T08:15:00.000Z" },
    { id: "ind-5", name: "Manufacturing & Industrial", createdAt: "2026-01-10T08:20:00.000Z" },
    { id: "ind-6", name: "Telecommunications", createdAt: "2026-01-10T08:25:00.000Z" },
    { id: "ind-7", name: "Logistics & Supply Chain", createdAt: "2026-01-10T08:30:00.000Z" },
    { id: "ind-8", name: "Energy & Utilities", createdAt: "2026-01-10T08:35:00.000Z" },
  ],
  countries: [
    { id: "cnt-1", name: "India", code: "IN", createdAt: "2026-01-10T08:00:00.000Z" },
    { id: "cnt-2", name: "United States", code: "US", createdAt: "2026-01-10T08:05:00.000Z" },
    { id: "cnt-3", name: "United Kingdom", code: "GB", createdAt: "2026-01-10T08:10:00.000Z" },
    { id: "cnt-4", name: "Singapore", code: "SG", createdAt: "2026-01-10T08:15:00.000Z" },
    { id: "cnt-5", name: "United Arab Emirates", code: "AE", createdAt: "2026-01-10T08:20:00.000Z" },
    { id: "cnt-6", name: "Germany", code: "DE", createdAt: "2026-01-10T08:25:00.000Z" },
    { id: "cnt-7", name: "Australia", code: "AU", createdAt: "2026-01-10T08:30:00.000Z" },
    { id: "cnt-8", name: "Canada", code: "CA", createdAt: "2026-01-10T08:35:00.000Z" },
  ],
  cities: [
    { id: "cty-1", name: "Pune", code: "PUN", createdAt: "2026-01-10T08:00:00.000Z" },
    { id: "cty-2", name: "Mumbai", code: "BOM", createdAt: "2026-01-10T08:05:00.000Z" },
    { id: "cty-3", name: "Bengaluru", code: "BLR", createdAt: "2026-01-10T08:10:00.000Z" },
    { id: "cty-4", name: "Hyderabad", code: "HYD", createdAt: "2026-01-10T08:15:00.000Z" },
    { id: "cty-5", name: "New York", code: "NYC", createdAt: "2026-01-10T08:20:00.000Z" },
    { id: "cty-6", name: "London", code: "LDN", createdAt: "2026-01-10T08:25:00.000Z" },
    { id: "cty-7", name: "Singapore", code: "SIN", createdAt: "2026-01-10T08:30:00.000Z" },
    { id: "cty-8", name: "Dubai", code: "DXB", createdAt: "2026-01-10T08:35:00.000Z" },
  ],
  contactTypes: [
    { id: "ctp-1", name: "Primary Contact", description: "Main day-to-day point of contact", createdAt: "2026-01-10T08:00:00.000Z" },
    { id: "ctp-2", name: "Billing & Finance", description: "Invoicing and payment communications", createdAt: "2026-01-10T08:05:00.000Z" },
    { id: "ctp-3", name: "Technical Lead", description: "Technical queries and integrations", createdAt: "2026-01-10T08:10:00.000Z" },
    { id: "ctp-4", name: "Escalation Point", description: "High-priority issue resolution", createdAt: "2026-01-10T08:15:00.000Z" },
    { id: "ctp-5", name: "Executive Sponsor", description: "C-suite contract & strategic decisions", createdAt: "2026-01-10T08:20:00.000Z" },
    { id: "ctp-6", name: "Contract Signatory", description: "Authorized legal agreement signee", createdAt: "2026-01-10T08:25:00.000Z" },
  ],
};
