import { useState, useEffect, useCallback } from "react";
import { toast } from "sonner";

export interface CatalogServiceItem {
  id: string;
  name: string;
  tool: string;
  unitPrice: number;
  days: number;
}

export const DEFAULT_CONTRACT_TYPES: string[] = [
  "Resource Based",
  "Scope Based",
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

export const DEFAULT_DEPT_SERVICES: Record<string, CatalogServiceItem[]> = {
  "Penetration Testing": [
    { id: "PT001", name: "External Network Penetration Testing", tool: "Nessus, Metasploit", unitPrice: 60000, days: 5 },
    { id: "PT002", name: "Internal Network Penetration Testing", tool: "Burp Suite, Cobalt Strike", unitPrice: 75000, days: 6 },
    { id: "PT003", name: "Web Application Penetration Testing", tool: "Burp Suite, OWASP ZAP", unitPrice: 50000, days: 5 },
    { id: "PT004", name: "Mobile Application Penetration Testing", tool: "Frida, Burp Suite Mobile", unitPrice: 55000, days: 5 },
    { id: "PT005", name: "API Penetration Testing", tool: "Postman, Burp Suite", unitPrice: 40000, days: 4 },
    { id: "PT006", name: "Thick Client Penetration Testing", tool: "Burp Suite, API Fuzzer", unitPrice: 45000, days: 4 },
  ],
  "Vulnerability Assessment": [
    { id: "VA001", name: "Network Vulnerability Assessment", tool: "Nessus, OpenVAS, Qualys", unitPrice: 35000, days: 3 },
    { id: "VA002", name: "Web Application Vulnerability Assessment", tool: "Acunetix, Qualys, Rapid7", unitPrice: 40000, days: 4 },
    { id: "VA003", name: "Cloud Infrastructure Vulnerability Assessment", tool: "Dome9, CloudSploit", unitPrice: 50000, days: 4 },
  ],
  "Red Team & Adversary Simulation": [
    { id: "RT001", name: "Full Spectrum Red Team Exercise", tool: "Cobalt Strike, Metasploit, Mimikatz", unitPrice: 120000, days: 10 },
    { id: "RT002", name: "Targeted Red Team Engagement", tool: "Custom Tools, Cobalt Strike", unitPrice: 80000, days: 7 },
  ],
  "Cloud Security": [
    { id: "CS001", name: "AWS Security Assessment", tool: "Scout2, CloudMapper, AWS Inspector", unitPrice: 55000, days: 5 },
    { id: "CS002", name: "Azure Security Assessment", tool: "Azucar, Microsoft Defender, Qualys", unitPrice: 55000, days: 5 },
    { id: "CS003", name: "Google Cloud Security Assessment", tool: "GCP Security Command Center", unitPrice: 50000, days: 5 },
  ],
  "Code & Application Security": [
    { id: "CODE001", name: "Source Code Security Review", tool: "SonarQube, Checkmarx, Fortify", unitPrice: 65000, days: 6 },
    { id: "CODE002", name: "Static Application Security Testing (SAST)", tool: "Checkmarx, Veracode, Fortify", unitPrice: 70000, days: 7 },
    { id: "CODE003", name: "Dynamic Application Security Testing (DAST)", tool: "Burp Suite, Acunetix, AppScan", unitPrice: 60000, days: 6 },
  ],
  "Compliance & Audit": [
    { id: "COMP001", name: "ISO 27001 Security Audit", tool: "AuditBoard, Drata, Vanta", unitPrice: 85000, days: 8 },
    { id: "COMP002", name: "GDPR Compliance Assessment", tool: "OneTrust, TrustArc, Compliance.ai", unitPrice: 75000, days: 7 },
    { id: "COMP003", name: "PCI-DSS Compliance Assessment", tool: "Qualys, Rapid7, Nessus", unitPrice: 80000, days: 7 },
    { id: "COMP004", name: "SOC 2 Type II Audit", tool: "AuditBoard, Drata", unitPrice: 95000, days: 10 },
  ],
  "Social Engineering & Awareness": [
    { id: "SE001", name: "Phishing Campaign & Assessment", tool: "KnowBe4, Gophish, Phish Alert", unitPrice: 30000, days: 2 },
    { id: "SE002", name: "Security Awareness Training Program", tool: "LinkedIn Learning, KnowBe4, SANS", unitPrice: 45000, days: 4 },
    { id: "SE003", name: "Vishing & Pretexting Assessment", tool: "Custom, KnowBe4", unitPrice: 35000, days: 3 },
  ],
  "Forensics & Incident Response": [
    { id: "FOR001", name: "Digital Forensics Investigation", tool: "EnCase, FTK, Volatility, X-Ways", unitPrice: 90000, days: 8 },
    { id: "FOR002", name: "Incident Response & Containment", tool: "Splunk, ELK, Rapid7 InsightIDR", unitPrice: 75000, days: 7 },
    { id: "FOR003", name: "Malware Analysis", tool: "IDA Pro, Ghidra, Wireshark, Cuckoo", unitPrice: 70000, days: 6 },
  ],
  "Network & Infrastructure": [
    { id: "NET001", name: "Network Architecture Security Review", tool: "Nmap, Wireshark, NETMON", unitPrice: 55000, days: 5 },
    { id: "NET002", name: "Firewall & IDS/IPS Configuration Audit", tool: "Nessus, OpenVAS, Custom Scripts", unitPrice: 65000, days: 6 },
    { id: "NET003", name: "Network Segmentation Assessment", tool: "Nmap, Shodan, Custom Tools", unitPrice: 60000, days: 5 },
  ],
  "Threat Intelligence & Modeling": [
    { id: "THREAT001", name: "Threat Modeling & Risk Assessment", tool: "Microsoft Threat Modeling Tool, IriusRisk", unitPrice: 50000, days: 4 },
    { id: "THREAT002", name: "Cyber Threat Intelligence Report", tool: "MISP, Mandiant, CrowdStrike", unitPrice: 40000, days: 3 },
    { id: "THREAT003", name: "Attack Surface Analysis", tool: "Shodan, Censys, Rapid7 Sonar", unitPrice: 45000, days: 4 },
  ],
};

const STORAGE_KEY_CONTRACT_TYPES = "trackerpro_contract_types_v2";
const STORAGE_KEY_DEPT_SERVICES = "trackerpro_dept_services_v2";
const STORAGE_KEY_DEPT_GROUPS = "trackerpro_dept_groups_v2";
const CATALOG_UPDATE_EVENT = "trackerpro:catalog_updated";

function loadStorage<T>(key: string, fallback: T): T {
  if (typeof window === "undefined") return fallback;
  try {
    const raw = localStorage.getItem(key);
    if (!raw) return fallback;
    return JSON.parse(raw);
  } catch {
    return fallback;
  }
}

function saveStorage<T>(key: string, val: T): void {
  if (typeof window === "undefined") return;
  try {
    localStorage.setItem(key, JSON.stringify(val));
    window.dispatchEvent(new CustomEvent(CATALOG_UPDATE_EVENT));
  } catch (e) {
    console.error(`Failed to save ${key}:`, e);
  }
}

export function getProjectCatalog() {
  const contractTypes = loadStorage<string[]>(STORAGE_KEY_CONTRACT_TYPES, DEFAULT_CONTRACT_TYPES);
  const deptServices = loadStorage<Record<string, CatalogServiceItem[]>>(STORAGE_KEY_DEPT_SERVICES, DEFAULT_DEPT_SERVICES);
  const deptGroups = loadStorage<Record<string, "Resource" | "Scope">>(STORAGE_KEY_DEPT_GROUPS, DEFAULT_DEPT_GROUPS);
  const departments = Object.keys(deptServices);
  const allServices = Object.values(deptServices)
    .flatMap((items) => items.map((i) => i.name))
    .filter((v, idx, arr) => arr.indexOf(v) === idx);

  return {
    contractTypes,
    departments,
    deptServices,
    deptGroups,
    allServices,
  };
}

export function useProjectCatalogStore() {
  const [contractTypes, setContractTypes] = useState<string[]>(() =>
    loadStorage<string[]>(STORAGE_KEY_CONTRACT_TYPES, DEFAULT_CONTRACT_TYPES),
  );

  const [deptServices, setDeptServices] = useState<Record<string, CatalogServiceItem[]>>(() =>
    loadStorage<Record<string, CatalogServiceItem[]>>(STORAGE_KEY_DEPT_SERVICES, DEFAULT_DEPT_SERVICES),
  );

  const [deptGroups, setDeptGroups] = useState<Record<string, "Resource" | "Scope">>(() =>
    loadStorage<Record<string, "Resource" | "Scope">>(STORAGE_KEY_DEPT_GROUPS, DEFAULT_DEPT_GROUPS),
  );

  // Sync listener across tabs / components
  useEffect(() => {
    const handleUpdate = () => {
      setContractTypes(loadStorage<string[]>(STORAGE_KEY_CONTRACT_TYPES, DEFAULT_CONTRACT_TYPES));
      setDeptServices(loadStorage<Record<string, CatalogServiceItem[]>>(STORAGE_KEY_DEPT_SERVICES, DEFAULT_DEPT_SERVICES));
      setDeptGroups(loadStorage<Record<string, "Resource" | "Scope">>(STORAGE_KEY_DEPT_GROUPS, DEFAULT_DEPT_GROUPS));
    };

    window.addEventListener(CATALOG_UPDATE_EVENT, handleUpdate);
    window.addEventListener("storage", handleUpdate);
    return () => {
      window.removeEventListener(CATALOG_UPDATE_EVENT, handleUpdate);
      window.removeEventListener("storage", handleUpdate);
    };
  }, []);

  const departments = Object.keys(deptServices);

  const allServices = Object.values(deptServices)
    .flatMap((items) => items.map((i) => i.name))
    .filter((v, idx, arr) => arr.indexOf(v) === idx);

  const getServicesForDepartment = useCallback(
    (dept: string): CatalogServiceItem[] => {
      return deptServices[dept] || [];
    },
    [deptServices],
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

      const nextServices = { ...deptServices, [trimmed]: [] };
      const nextGroups = { ...deptGroups, [trimmed]: group };

      setDeptServices(nextServices);
      setDeptGroups(nextGroups);
      saveStorage(STORAGE_KEY_DEPT_SERVICES, nextServices);
      saveStorage(STORAGE_KEY_DEPT_GROUPS, nextGroups);
      toast.success(`Department "${trimmed}" added`);
      return { success: true };
    },
    [deptServices, deptGroups],
  );

  const addService = useCallback(
    (
      dept: string,
      service: { name: string; tool?: string; unitPrice?: number; days?: number },
    ): { success: boolean; error?: string } => {
      const trimmedDept = dept.trim();
      const trimmedName = service.name.trim();

      if (!trimmedDept) {
        return { success: false, error: "Please select a Department first." };
      }
      if (!trimmedName) {
        return { success: false, error: "Service name is required." };
      }

      const existingDeptServices = deptServices[trimmedDept] || [];
      if (existingDeptServices.some((s) => s.name.toLowerCase() === trimmedName.toLowerCase())) {
        return { success: false, error: `Service "${trimmedName}" already exists in ${trimmedDept}.` };
      }

      const idPrefix = trimmedDept.replace(/[^A-Za-z0-9]/g, "").slice(0, 3).toUpperCase() || "SVC";
      const newServiceItem: CatalogServiceItem = {
        id: `${idPrefix}${String(existingDeptServices.length + 1).padStart(3, "0")}`,
        name: trimmedName,
        tool: service.tool?.trim() || "Standard Industry Tools",
        unitPrice: service.unitPrice && service.unitPrice > 0 ? service.unitPrice : 50000,
        days: service.days && service.days > 0 ? service.days : 5,
      };

      const nextServices = {
        ...deptServices,
        [trimmedDept]: [...existingDeptServices, newServiceItem],
      };

      // Ensure department is also tracked in groups if not existing
      let nextGroups = deptGroups;
      if (!nextGroups[trimmedDept]) {
        nextGroups = { ...deptGroups, [trimmedDept]: "Scope" };
        setDeptGroups(nextGroups);
        saveStorage(STORAGE_KEY_DEPT_GROUPS, nextGroups);
      }

      setDeptServices(nextServices);
      saveStorage(STORAGE_KEY_DEPT_SERVICES, nextServices);
      toast.success(`Service "${trimmedName}" added to ${trimmedDept}`);
      return { success: true };
    },
    [deptServices, deptGroups],
  );

  const resetCatalog = useCallback(() => {
    setContractTypes(DEFAULT_CONTRACT_TYPES);
    setDeptServices(DEFAULT_DEPT_SERVICES);
    setDeptGroups(DEFAULT_DEPT_GROUPS);
    saveStorage(STORAGE_KEY_CONTRACT_TYPES, DEFAULT_CONTRACT_TYPES);
    saveStorage(STORAGE_KEY_DEPT_SERVICES, DEFAULT_DEPT_SERVICES);
    saveStorage(STORAGE_KEY_DEPT_GROUPS, DEFAULT_DEPT_GROUPS);
    toast.info("Project catalog reset to defaults");
  }, []);

  return {
    contractTypes,
    departments,
    deptServices,
    deptGroups,
    allServices,
    getServicesForDepartment,
    addContractType,
    addDepartment,
    addService,
    resetCatalog,
  };
}
