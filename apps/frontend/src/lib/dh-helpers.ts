import { people, getPerson, type Person, type Project, type Task } from "@/lib/mock-data";

export function getProjectEMs(p: Project): Person[] {
  if (p.engagementManager) {
    const byName = people.find(
      (person) => person.name.toLowerCase() === p.engagementManager!.toLowerCase(),
    );
    if (byName) return [byName];
    return [
      {
        id: "em-" + p.id,
        name: p.engagementManager,
        role: "Engagement Manager",
        avatar: p.engagementManager.slice(0, 2).toUpperCase(),
        email: "",
      },
    ];
  }
  return [];
}

export function getProjectPMs(p: Project): Person[] {
  if (p.projectManagers?.length) {
    return p.projectManagers.map((m) => ({
      id: m.employeeId,
      name: m.name,
      role: "Project Manager",
      avatar: m.name.slice(0, 2).toUpperCase(),
      email: "",
    }));
  }
  if (p.pmId) return [getPerson(p.pmId)];
  return [];
}

export function getProjectTLs(p: Project): Person[] {
  if (p.teamLeads?.length) {
    return p.teamLeads.map((m) => ({
      id: m.employeeId,
      name: m.name,
      role: "Team Lead",
      avatar: m.name.slice(0, 2).toUpperCase(),
      email: "",
    }));
  }
  if (p.tlId) return [getPerson(p.tlId)];
  return [];
}

// ---------- Departments ----------
export type Dept = "Engineering" | "Design" | "Delivery" | "Operations" | "Leadership";
export type SubDept = string;

const DEPT_MAP: Record<string, { dept: Dept; sub: SubDept }> = {
  Engineer: { dept: "Engineering", sub: "Backend" },
  Designer: { dept: "Design", sub: "Product Design" },
  TL: { dept: "Engineering", sub: "Team Leadership" },
  PM: { dept: "Delivery", sub: "Project Management" },
  "Senior PM": { dept: "Delivery", sub: "Senior Management" },
  "Engagement Manager": { dept: "Delivery", sub: "Engagement" },
  PMO: { dept: "Operations", sub: "PMO" },
  HOD: { dept: "Leadership", sub: "Department Head" },
  "Business Owner": { dept: "Leadership", sub: "Executive" },
  Dhanshree: { dept: "Operations", sub: "Delivery Ops" },
};

export const getDept = (p: Person) => DEPT_MAP[p.role]?.dept ?? "Operations";
export const getSubDept = (p: Person) => DEPT_MAP[p.role]?.sub ?? "General";

// ---------- Extended Task fields ----------
export type DhTaskStatus =
  | "Ongoing"
  | "Completed"
  | "On Hold Internally"
  | "On Hold Customer"
  | "After Release";

export const DH_TASK_STATUSES: DhTaskStatus[] = [
  "Ongoing",
  "Completed",
  "On Hold Internally",
  "On Hold Customer",
  "After Release",
];

export const mapTaskStatus = (s: Task["status"]): DhTaskStatus =>
  s === "done" ? "Completed" : s === "todo" ? "On Hold Internally" : "Ongoing";

export interface DhTaskMeta {
  taskCode: string;
  startDate: string;
  estHours: number;
  actualHours: number;
  assigneeIds: string[];
}

export function getTaskMeta(p: Project, t: Task): DhTaskMeta {
  const idx = p.tasks.findIndex((x) => x.id === t.id);
  const start = new Date(p.startDate);
  start.setDate(start.getDate() + idx * 14);
  const est = 40 + (idx + 1) * 12;
  const actual = Math.round(est * (t.progress / 100));
  const extras = p.teamIds.filter((id) => id !== t.assigneeId).slice(0, idx % 2);
  return {
    taskCode: `${p.id.toUpperCase()}-TSK-${String(idx + 1).padStart(3, "0")}`,
    startDate: start.toISOString().slice(0, 10),
    estHours: est,
    actualHours: actual,
    assigneeIds: [t.assigneeId, ...extras],
  };
}

// ---------- Team allocation ----------
export type Billability = "Billable" | "Non-Billable";
export type ResourceType = "Fixed" | "Adhoc" | "Dedicated" | "Shared Resource";

export interface TeamAllocation {
  person: Person;
  duration: string;
  billability: Billability;
  resourceType: ResourceType;
}

export function getProjectTeam(p: Project): TeamAllocation[] {
  const ids = Array.from(new Set([p.pmId, p.tlId, ...p.teamIds].filter(Boolean)));
  return ids.map((id, idx) => {
    const person = getPerson(id);
    return {
      person,
      duration: `${new Date(p.startDate).toLocaleDateString()} → ${new Date(p.endDate).toLocaleDateString()}`,
      billability: idx % 3 === 2 ? "Non-Billable" : "Billable",
      resourceType: idx % 2 === 0 ? "Dedicated" : "Shared Resource",
    };
  });
}

export function formatPeopleSummary(list: Person[]): { primary: string; more: number } {
  if (list.length === 0) return { primary: "—", more: 0 };
  return { primary: list[0].name, more: list.length - 1 };
}

export { people };
