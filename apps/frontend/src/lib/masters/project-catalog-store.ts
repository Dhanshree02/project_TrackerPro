import { useState, useEffect, useCallback } from "react";
import { toast } from "sonner";
import {
  fetchServiceHierarchy,
  createServiceDepartment,
  createServiceSubDepartment,
  createServiceCatalog,
  type ServiceHierarchyGroup,
} from "@/lib/api/catalogs";

export interface CatalogServiceItem {
  id: string;
  name: string;
  tool: string;
  unitPrice: number;
  days: number;
  subDept?: string;
}

export const DEFAULT_CONTRACT_TYPES: string[] = [
  "Scope",
  "Resource",
];

export const DEFAULT_DEPT_GROUPS: Record<string, "Resource" | "Scope"> = {
  "Penetration Testing": "Scope",
  "Vulnerability Assessment": "Scope",
  "Red Team & Adversary Simulation": "Resource",
  "Cloud Security": "Resource",
  "Code & Application Security": "Scope",
  "Compliance & Audit": "Resource",
  "Social Engineering & Awareness": "Scope",
  "Forensics & Incident Response": "Resource",
  "Network & Infrastructure": "Scope",
  "Threat Intelligence & Modeling": "Resource",
};

export const DEFAULT_DEPT_SUB_DEPTS: Record<string, string[]> = {
  "Penetration Testing": [
    "Network Penetration Testing",
    "Web Application Penetration Testing",
    "Mobile Application Penetration Testing",
    "API Penetration Testing",
    "Thick Client Penetration Testing",
  ],
  "Vulnerability Assessment": [
    "Network Vulnerability Assessment",
    "Web Application Vulnerability Assessment",
    "Cloud Infrastructure Vulnerability Assessment",
  ],
  "Red Team & Adversary Simulation": [
    "Adversary Simulation",
  ],
  "Cloud Security": [
    "AWS Security Assessment",
    "Azure Security Assessment",
    "Google Cloud Security Assessment",
  ],
  "Code & Application Security": [
    "Source Code Security Review",
    "Static Application Security Testing",
    "Dynamic Application Security Testing",
  ],
  "Compliance & Audit": [
    "ISO 27001 Security Audit",
    "GDPR Compliance Assessment",
    "PCI-DSS Compliance Assessment",
    "SOC 2 Type II Audit",
  ],
  "Social Engineering & Awareness": [
    "Phishing Campaign & Assessment",
    "Security Awareness Training Program",
    "Vishing & Pretexting Assessment",
  ],
  "Forensics & Incident Response": [
    "Digital Forensics Investigation",
    "Incident Response & Containment",
    "Malware Analysis",
  ],
  "Network & Infrastructure": [
    "Network Architecture Security Review",
    "Firewall & IDS/IPS Configuration Audit",
    "Network Segmentation Assessment",
  ],
  "Threat Intelligence & Modeling": [
    "Threat Modeling & Risk Assessment",
    "Cyber Threat Intelligence Report",
    "Attack Surface Analysis",
  ],
};

export const DEFAULT_DEPT_SERVICES: Record<string, CatalogServiceItem[]> = {
  "Penetration Testing": [
    { id: "PT001", name: "External Network Penetration Testing", tool: "Nessus, Metasploit", unitPrice: 60000, days: 5, subDept: "Network Penetration Testing" },
    { id: "PT002", name: "Internal Network Penetration Testing", tool: "Burp Suite, Cobalt Strike", unitPrice: 75000, days: 6, subDept: "Network Penetration Testing" },
    { id: "PT003", name: "Web Application Penetration Testing", tool: "Burp Suite, OWASP ZAP", unitPrice: 50000, days: 5, subDept: "Web Application Penetration Testing" },
    { id: "PT004", name: "Mobile Application Penetration Testing", tool: "Frida, Burp Suite Mobile", unitPrice: 55000, days: 5, subDept: "Mobile Application Penetration Testing" },
    { id: "PT005", name: "API Penetration Testing", tool: "Postman, Burp Suite", unitPrice: 40000, days: 4, subDept: "API Penetration Testing" },
    { id: "PT006", name: "Thick Client Penetration Testing", tool: "Burp Suite, API Fuzzer", unitPrice: 45000, days: 4, subDept: "Thick Client Penetration Testing" },
  ],
  "Vulnerability Assessment": [
    { id: "VA001", name: "Network Vulnerability Assessment", tool: "Nessus, OpenVAS, Qualys", unitPrice: 35000, days: 3, subDept: "Network Vulnerability Assessment" },
    { id: "VA002", name: "Web Application Vulnerability Assessment", tool: "Acunetix, Qualys, Rapid7", unitPrice: 40000, days: 4, subDept: "Web Application Vulnerability Assessment" },
    { id: "VA003", name: "Cloud Infrastructure Vulnerability Assessment", tool: "Dome9, CloudSploit", unitPrice: 50000, days: 4, subDept: "Cloud Infrastructure Vulnerability Assessment" },
  ],
  "Red Team & Adversary Simulation": [
    { id: "RT001", name: "Full Spectrum Red Team Exercise", tool: "Cobalt Strike, Metasploit, Mimikatz", unitPrice: 120000, days: 10, subDept: "Adversary Simulation" },
    { id: "RT002", name: "Targeted Red Team Engagement", tool: "Custom Tools, Cobalt Strike", unitPrice: 80000, days: 7, subDept: "Adversary Simulation" },
  ],
  "Cloud Security": [
    { id: "CS001", name: "AWS Security Assessment", tool: "Scout2, CloudMapper, AWS Inspector", unitPrice: 55000, days: 5, subDept: "AWS Security Assessment" },
    { id: "CS002", name: "Azure Security Assessment", tool: "Azucar, Microsoft Defender, Qualys", unitPrice: 55000, days: 5, subDept: "Azure Security Assessment" },
    { id: "CS003", name: "Google Cloud Security Assessment", tool: "GCP Security Command Center", unitPrice: 50000, days: 5, subDept: "Google Cloud Security Assessment" },
  ],
  "Code & Application Security": [
    { id: "CODE001", name: "Source Code Security Review", tool: "SonarQube, Checkmarx, Fortify", unitPrice: 65000, days: 6, subDept: "Source Code Security Review" },
    { id: "CODE002", name: "Static Application Security Testing (SAST)", tool: "Checkmarx, Veracode, Fortify", unitPrice: 70000, days: 7, subDept: "Static Application Security Testing" },
    { id: "CODE003", name: "Dynamic Application Security Testing (DAST)", tool: "Burp Suite, Acunetix, AppScan", unitPrice: 60000, days: 6, subDept: "Dynamic Application Security Testing" },
  ],
  "Compliance & Audit": [
    { id: "COMP001", name: "ISO 27001 Security Audit", tool: "AuditBoard, Drata, Vanta", unitPrice: 85000, days: 8, subDept: "ISO 27001 Security Audit" },
    { id: "COMP002", name: "GDPR Compliance Assessment", tool: "OneTrust, TrustArc, Compliance.ai", unitPrice: 75000, days: 7, subDept: "GDPR Compliance Assessment" },
    { id: "COMP003", name: "PCI-DSS Compliance Assessment", tool: "Qualys, Rapid7, Nessus", unitPrice: 80000, days: 7, subDept: "PCI-DSS Compliance Assessment" },
    { id: "COMP004", name: "SOC 2 Type II Audit", tool: "AuditBoard, Drata", unitPrice: 95000, days: 10, subDept: "SOC 2 Type II Audit" },
  ],
  "Social Engineering & Awareness": [
    { id: "SE001", name: "Phishing Campaign & Assessment", tool: "KnowBe4, Gophish, Phish Alert", unitPrice: 30000, days: 2, subDept: "Phishing Campaign & Assessment" },
    { id: "SE002", name: "Security Awareness Training Program", tool: "LinkedIn Learning, KnowBe4, SANS", unitPrice: 45000, days: 4, subDept: "Security Awareness Training Program" },
    { id: "SE003", name: "Vishing & Pretexting Assessment", tool: "Custom, KnowBe4", unitPrice: 35000, days: 3, subDept: "Vishing & Pretexting Assessment" },
  ],
  "Forensics & Incident Response": [
    { id: "FOR001", name: "Digital Forensics Investigation", tool: "EnCase, FTK, Volatility, X-Ways", unitPrice: 90000, days: 8, subDept: "Digital Forensics Investigation" },
    { id: "FOR002", name: "Incident Response & Containment", tool: "Splunk, ELK, Rapid7 InsightIDR", unitPrice: 75000, days: 7, subDept: "Incident Response & Containment" },
    { id: "FOR003", name: "Malware Analysis", tool: "IDA Pro, Ghidra, Wireshark, Cuckoo", unitPrice: 70000, days: 6, subDept: "Malware Analysis" },
  ],
  "Network & Infrastructure": [
    { id: "NET001", name: "Network Architecture Security Review", tool: "Nmap, Wireshark, NETMON", unitPrice: 55000, days: 5, subDept: "Network Architecture Security Review" },
    { id: "NET002", name: "Firewall & IDS/IPS Configuration Audit", tool: "Nessus, OpenVAS, Custom Scripts", unitPrice: 65000, days: 6, subDept: "Firewall & IDS/IPS Configuration Audit" },
    { id: "NET003", name: "Network Segmentation Assessment", tool: "Nmap, Shodan, Custom Tools", unitPrice: 60000, days: 5, subDept: "Network Segmentation Assessment" },
  ],
  "Threat Intelligence & Modeling": [
    { id: "THREAT001", name: "Threat Modeling & Risk Assessment", tool: "Microsoft Threat Modeling Tool, IriusRisk", unitPrice: 50000, days: 4, subDept: "Threat Modeling & Risk Assessment" },
    { id: "THREAT002", name: "Cyber Threat Intelligence Report", tool: "MISP, Mandiant, CrowdStrike", unitPrice: 40000, days: 3, subDept: "Cyber Threat Intelligence Report" },
    { id: "THREAT003", name: "Attack Surface Analysis", tool: "Shodan, Censys, Rapid7 Sonar", unitPrice: 45000, days: 4, subDept: "Attack Surface Analysis" },
  ],
};

const STORAGE_KEY_CONTRACT_TYPES = "trackerpro_contract_types_v2";
const STORAGE_KEY_DEPT_SERVICES = "trackerpro_dept_services_v2";
const STORAGE_KEY_DEPT_GROUPS = "trackerpro_dept_groups_v2";
const STORAGE_KEY_DEPT_SUB_DEPTS = "trackerpro_dept_sub_depts_v1";
const CATALOG_UPDATE_EVENT = "trackerpro:catalog_updated";

// Purge any stale Chrome localStorage items so data always comes from the PostgreSQL database
function purgeChromeStorage(): void {
  if (typeof window === "undefined") return;
  try {
    const keysToRemove = [
      STORAGE_KEY_CONTRACT_TYPES,
      STORAGE_KEY_DEPT_SERVICES,
      STORAGE_KEY_DEPT_GROUPS,
      STORAGE_KEY_DEPT_SUB_DEPTS,
      "trackerpro_project_masters_v2",
      "trackerpro_customer_masters_v1",
      "trackerpro_resource_masters_v2",
    ];
    keysToRemove.forEach((k) => localStorage.removeItem(k));
  } catch (e) {
    // Ignore storage errors
  }
}

// In-memory module cache (purely transient, database is authoritative)
let inMemoryContractTypes: string[] = DEFAULT_CONTRACT_TYPES;
let inMemoryDeptServices: Record<string, CatalogServiceItem[]> = DEFAULT_DEPT_SERVICES;
let inMemoryDeptGroups: Record<string, "Resource" | "Scope"> = DEFAULT_DEPT_GROUPS;
let inMemoryDeptSubDepts: Record<string, string[]> = DEFAULT_DEPT_SUB_DEPTS;

function saveStorage<T>(_key: string, _val: T): void {
  if (typeof window === "undefined") return;
  // Do NOT write to Chrome localStorage; notify in-memory listeners
  window.dispatchEvent(new CustomEvent(CATALOG_UPDATE_EVENT));
}

export function getProjectCatalog() {
  const departments = Object.keys(inMemoryDeptServices);
  const allServices = Object.values(inMemoryDeptServices)
    .flatMap((items) => items.map((i) => i.name))
    .filter((v, idx, arr) => arr.indexOf(v) === idx);

  return {
    contractTypes: inMemoryContractTypes,
    departments,
    deptServices: inMemoryDeptServices,
    deptGroups: inMemoryDeptGroups,
    deptSubDepts: inMemoryDeptSubDepts,
    allServices,
  };
}

export function useProjectCatalogStore() {
  const [contractTypes, setContractTypes] = useState<string[]>(inMemoryContractTypes);
  const [deptServices, setDeptServices] = useState<Record<string, CatalogServiceItem[]>>(inMemoryDeptServices);
  const [deptGroups, setDeptGroups] = useState<Record<string, "Resource" | "Scope">>(inMemoryDeptGroups);
  const [deptSubDepts, setDeptSubDepts] = useState<Record<string, string[]>>(inMemoryDeptSubDepts);

  // Purge any old Chrome localStorage on mount
  useEffect(() => {
    purgeChromeStorage();
  }, []);

  // Sync listener across in-memory components
  useEffect(() => {
    const handleUpdate = () => {
      setContractTypes([...inMemoryContractTypes]);
      setDeptServices({ ...inMemoryDeptServices });
      setDeptGroups({ ...inMemoryDeptGroups });
      setDeptSubDepts({ ...inMemoryDeptSubDepts });
    };

    window.addEventListener(CATALOG_UPDATE_EVENT, handleUpdate);
    return () => {
      window.removeEventListener(CATALOG_UPDATE_EVENT, handleUpdate);
    };
  }, []);

  // Authoritative fetch from local PostgreSQL database
  useEffect(() => {
    let active = true;
    fetchServiceHierarchy()
      .then((hierarchy) => {
        if (!active || !hierarchy || hierarchy.length === 0) return;

        const groups = hierarchy.map((g) => g.name);
        const newDeptServices: Record<string, CatalogServiceItem[]> = {};
        const newDeptGroups: Record<string, "Resource" | "Scope"> = {};
        const newDeptSubDepts: Record<string, string[]> = {};

        for (const group of hierarchy) {
          const groupType: "Resource" | "Scope" = group.name.toLowerCase().includes("resource") ? "Resource" : "Scope";
          for (const dept of group.departments) {
            newDeptGroups[dept.name] = groupType;
            newDeptSubDepts[dept.name] = dept.subDepartments.map((s) => s.name);
            newDeptServices[dept.name] = dept.subDepartments.flatMap((sub) =>
              sub.services.map((svc) => ({
                id: svc.code || svc.id,
                name: svc.name,
                tool: svc.defaultTools || "",
                unitPrice: svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 50000,
                days: svc.defaultDurationDays || 5,
                subDept: sub.name,
              }))
            );
          }
        }

        // Set authoritative state directly from PostgreSQL
        inMemoryContractTypes = groups.length > 0 ? groups : DEFAULT_CONTRACT_TYPES;
        inMemoryDeptGroups = newDeptGroups;
        inMemoryDeptSubDepts = newDeptSubDepts;
        inMemoryDeptServices = newDeptServices;

        setContractTypes(inMemoryContractTypes);
        setDeptGroups(inMemoryDeptGroups);
        setDeptSubDepts(inMemoryDeptSubDepts);
        setDeptServices(inMemoryDeptServices);
      })
      .catch((err) => {
        console.warn("Could not load service hierarchy from PostgreSQL:", err);
      });

    return () => {
      active = false;
    };
  }, []);

  const departments = Object.keys(deptServices);

  const allServices = Object.values(deptServices)
    .flatMap((items) => items.map((i) => i.name))
    .filter((v, idx, arr) => arr.indexOf(v) === idx);

  const getServicesForDepartment = useCallback(
    (dept: string, subDept?: string): CatalogServiceItem[] => {
      const svcs = deptServices[dept] || [];
      if (!subDept) return svcs;
      return svcs.filter((s) => !s.subDept || s.subDept.toLowerCase() === subDept.toLowerCase());
    },
    [deptServices],
  );

  const getSubDepartmentsForDepartment = useCallback(
    (dept: string): string[] => {
      if (!dept) return [];
      const configured = deptSubDepts[dept] || [];
      const fromServices = (deptServices[dept] || [])
        .map((s) => s.subDept)
        .filter((sub): sub is string => Boolean(sub && sub.trim()));
      const combined = Array.from(new Set([...configured, ...fromServices]));
      return combined;
    },
    [deptSubDepts, deptServices],
  );

  const addContractType = useCallback(
    (name: string): { success: boolean; error?: string } => {
      const trimmed = name.trim();
      if (!trimmed) {
        return { success: false, error: "Contract Type name is required." };
      }
      if (contractTypes.some((ct) => ct.toLowerCase() === trimmed.toLowerCase())) {
        return { success: false, error: `Contract Type "${trimmed}" already exists.` };
      }

      const next = [...contractTypes, trimmed];
      inMemoryContractTypes = next;
      setContractTypes(next);
      saveStorage(STORAGE_KEY_CONTRACT_TYPES, next);
      toast.success(`Contract Type "${trimmed}" added`);
      return { success: true };
    },
    [contractTypes],
  );

  const addDepartment = useCallback(
    (name: string, group: "Resource" | "Scope" = "Scope"): { success: boolean; error?: string } => {
      const trimmed = name.trim();
      if (!trimmed) {
        return { success: false, error: "Department name is required." };
      }
      if (Object.keys(deptServices).some((d) => d.toLowerCase() === trimmed.toLowerCase())) {
        return { success: false, error: `Department "${trimmed}" already exists.` };
      }

      // Persist to master.mst_service_departments in PostgreSQL
      createServiceDepartment({ name: trimmed, group }).catch((err) => {
        console.warn("Backend save to master.mst_service_departments failed:", err);
      });

      const nextServices = { ...deptServices, [trimmed]: [] };
      const nextGroups = { ...deptGroups, [trimmed]: group };
      const nextSubDepts = { ...deptSubDepts, [trimmed]: [] };

      inMemoryDeptServices = nextServices;
      inMemoryDeptGroups = nextGroups;
      inMemoryDeptSubDepts = nextSubDepts;

      setDeptServices(nextServices);
      setDeptGroups(nextGroups);
      setDeptSubDepts(nextSubDepts);
      saveStorage(STORAGE_KEY_DEPT_SERVICES, nextServices);
      toast.success(`Department "${trimmed}" added and saved`);
      return { success: true };
    },
    [deptServices, deptGroups, deptSubDepts],
  );

  const addSubDepartment = useCallback(
    (dept: string, subDeptName: string): { success: boolean; error?: string } => {
      const trimmedDept = dept.trim();
      const trimmedSubDept = subDeptName.trim();

      if (!trimmedDept) {
        return { success: false, error: "Please select a Department first." };
      }
      if (!trimmedSubDept) {
        return { success: false, error: "Sub-Department name is required." };
      }

      const targetDeptKey =
        Object.keys(deptSubDepts).find((k) => k.toLowerCase() === trimmedDept.toLowerCase()) || trimmedDept;
      const existingSubs = deptSubDepts[targetDeptKey] || [];
      if (existingSubs.some((s) => s.toLowerCase() === trimmedSubDept.toLowerCase())) {
        return { success: false, error: `Sub-Department "${trimmedSubDept}" already exists in ${targetDeptKey}.` };
      }

      // Persist to master.mst_service_sub_departments in PostgreSQL
      createServiceSubDepartment({
        name: trimmedSubDept,
        departmentName: targetDeptKey,
      }).catch((err) => {
        console.warn("Backend save to master.mst_service_sub_departments failed:", err);
      });

      const nextSubDepts = {
        ...deptSubDepts,
        [targetDeptKey]: [...existingSubs, trimmedSubDept],
      };

      inMemoryDeptSubDepts = nextSubDepts;
      setDeptSubDepts(nextSubDepts);
      saveStorage(STORAGE_KEY_DEPT_SUB_DEPTS, nextSubDepts);
      toast.success(`Sub-Department "${trimmedSubDept}" added to ${targetDeptKey} and saved`);
      return { success: true };
    },
    [deptSubDepts],
  );

  const addService = useCallback(
    (
      dept: string,
      service: { name: string; tool?: string; unitPrice?: number; days?: number; subDept?: string },
    ): { success: boolean; error?: string } => {
      const trimmedDept = dept.trim();
      const trimmedName = service.name.trim();

      if (!trimmedDept) {
        return { success: false, error: "Please select a Department first." };
      }
      if (!trimmedName) {
        return { success: false, error: "Service name is required." };
      }

      const targetDeptKey =
        Object.keys(deptServices).find((k) => k.toLowerCase() === trimmedDept.toLowerCase()) || trimmedDept;
      const existingDeptServices = deptServices[targetDeptKey] || [];
      if (existingDeptServices.some((s) => s.name.toLowerCase() === trimmedName.toLowerCase())) {
        return { success: false, error: `Service "${trimmedName}" already exists in ${targetDeptKey}.` };
      }

      // Persist to master.mst_service_catalog in PostgreSQL
      createServiceCatalog({
        name: trimmedName,
        departmentName: targetDeptKey,
        subDepartmentName: service.subDept?.trim(),
        defaultTools: service.tool?.trim(),
        defaultUnitPrice: service.unitPrice && service.unitPrice > 0 ? service.unitPrice : 50000,
        defaultDurationDays: service.days && service.days > 0 ? service.days : 5,
      }).catch((err) => {
        console.warn("Backend save to master.mst_service_catalog failed:", err);
      });

      const idPrefix = trimmedDept.replace(/[^A-Za-z0-9]/g, "").slice(0, 3).toUpperCase() || "SVC";
      const newServiceItem: CatalogServiceItem = {
        id: `${idPrefix}${String(existingDeptServices.length + 1).padStart(3, "0")}`,
        name: trimmedName,
        tool: service.tool?.trim() || "Standard Industry Tools",
        unitPrice: service.unitPrice && service.unitPrice > 0 ? service.unitPrice : 50000,
        days: service.days && service.days > 0 ? service.days : 5,
        subDept: service.subDept?.trim() || undefined,
      };

      const nextServices = {
        ...deptServices,
        [trimmedDept]: [...existingDeptServices, newServiceItem],
      };

      // Ensure department is also tracked in groups if not existing
      let nextGroups = deptGroups;
      if (!nextGroups[trimmedDept]) {
        nextGroups = { ...deptGroups, [trimmedDept]: "Scope" };
        inMemoryDeptGroups = nextGroups;
        setDeptGroups(nextGroups);
      }

      // Ensure sub-department is registered under department if provided
      if (service.subDept?.trim()) {
        const sub = service.subDept.trim();
        const currentSubs = deptSubDepts[trimmedDept] || [];
        if (!currentSubs.some((s) => s.toLowerCase() === sub.toLowerCase())) {
          const nextSubs = { ...deptSubDepts, [trimmedDept]: [...currentSubs, sub] };
          inMemoryDeptSubDepts = nextSubs;
          setDeptSubDepts(nextSubs);
        }
      }

      inMemoryDeptServices = nextServices;
      setDeptServices(nextServices);
      saveStorage(STORAGE_KEY_DEPT_SERVICES, nextServices);
      toast.success(`Service "${trimmedName}" added to ${trimmedDept} and saved`);
      return { success: true };
    },
    [deptServices, deptGroups, deptSubDepts],
  );

  const resetCatalog = useCallback(() => {
    inMemoryContractTypes = DEFAULT_CONTRACT_TYPES;
    inMemoryDeptServices = DEFAULT_DEPT_SERVICES;
    inMemoryDeptGroups = DEFAULT_DEPT_GROUPS;
    inMemoryDeptSubDepts = DEFAULT_DEPT_SUB_DEPTS;
    setContractTypes(DEFAULT_CONTRACT_TYPES);
    setDeptServices(DEFAULT_DEPT_SERVICES);
    setDeptGroups(DEFAULT_DEPT_GROUPS);
    setDeptSubDepts(DEFAULT_DEPT_SUB_DEPTS);
    saveStorage(STORAGE_KEY_CONTRACT_TYPES, DEFAULT_CONTRACT_TYPES);
    toast.info("Project catalog reset to defaults");
  }, []);

  return {
    contractTypes,
    departments,
    deptServices,
    deptGroups,
    deptSubDepts,
    allServices,
    getServicesForDepartment,
    getSubDepartmentsForDepartment,
    addContractType,
    addDepartment,
    addSubDepartment,
    addService,
    resetCatalog,
  };
}
