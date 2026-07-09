import { people, projects, getPerson, type Person, type Project, type Task } from "@/lib/mock-data";

// ---------- Multi-assignee helpers (Dhanshree views) ----------
// We derive supplementary EM / PM / TL lists from existing people; the
// original pmId/tlId on Project remain authoritative for other roles.

const EM_POOL = ["u2"]; // Engagement Managers
const SPM_POOL = ["u1"]; // Senior PMs
const PM_POOL = ["u3", "u4"]; // PMs
const TL_POOL = ["u5", "u6"]; // TLs

const seeded = (seed: string, max: number) =>
  Math.abs(seed.split("").reduce((a, c) => a + c.charCodeAt(0), 0)) % max;

export function getProjectEMs(p: Project): Person[] {
  // Always at least 1, sometimes 2
  const ids = [EM_POOL[0], "u1"]; // EM + Senior PM also acts as engagement
  const n = (seeded(p.id, 2) === 0 ? 1 : 2);
  return ids.slice(0, n).map(getPerson);
}

export function getProjectPMs(p: Project): Person[] {
  const ids = [p.pmId, ...PM_POOL.filter((id) => id !== p.pmId), ...SPM_POOL];
  const n = 1 + seeded(p.id + "pm", 2); // 1..2
  return Array.from(new Set(ids.slice(0, n))).map(getPerson);
}

export function getProjectTLs(p: Project): Person[] {
  const ids = [p.tlId, ...TL_POOL.filter((id) => id !== p.tlId)];
  const n = 1 + seeded(p.id + "tl", 2); // 1..2
  return Array.from(new Set(ids.slice(0, n))).map(getPerson);
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

// ---------- Extended Task fields (Dhanshree view) ----------
export type DhTaskStatus =
  | "Ongoing"
  | "Completed"
  | "On Hold Internally"
  | "On Hold Client"
  | "After Release";

export const DH_TASK_STATUSES: DhTaskStatus[] = [
  "Ongoing",
  "Completed",
  "On Hold Internally",
  "On Hold Client",
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
  const est = 40 + ((idx + 1) * 12);
  const actual = Math.round(est * (t.progress / 100));
  // Build secondary assignees from project team
  const extras = p.teamIds.filter((id) => id !== t.assigneeId).slice(0, idx % 2);
  return {
    taskCode: `${p.id.toUpperCase()}-TSK-${String(idx + 1).padStart(3, "0")}`,
    startDate: start.toISOString().slice(0, 10),
    estHours: est,
    actualHours: actual,
    assigneeIds: [t.assigneeId, ...extras],
  };
}

// ---------- Team allocation (Project Team submodule) ----------
export type Billability = "Billable" | "Non-Billable";
export type ResourceType = "Fixed" | "Adhoc" | "Dedicated" | "Shared Resource";

export interface TeamAllocation {
  person: Person;
  duration: string;
  billability: Billability;
  resourceType: ResourceType;
}

export function getProjectTeam(p: Project): TeamAllocation[] {
  const ids = Array.from(new Set([p.pmId, p.tlId, ...p.teamIds]));
  return ids.map((id, idx) => {
    const person = getPerson(id);
    return {
      person,
      duration: `${new Date(p.startDate).toLocaleDateString()} → ${new Date(p.endDate).toLocaleDateString()}`,
      billability: idx % 3 === 2 ? "Non-Billable" : "Billable",
      resourceType: idx % 2 === 0 ? "Fixed" : "Adhoc",
    };
  });
}

// Show "First name +N" for list of people
export function formatPeopleSummary(list: Person[]): { primary: string; more: number } {
  if (list.length === 0) return { primary: "—", more: 0 };
  return { primary: list[0].name, more: list.length - 1 };
}

export { people };
