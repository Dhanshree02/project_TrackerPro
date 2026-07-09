import { createContext, useContext, useState, type ReactNode } from "react";
import type { Role } from "@/lib/mock-data";
import { assignments, clients, getPerson, projects, issues, timesheets } from "@/lib/mock-data";

interface RoleContextValue {
  role: Role;
  setRole: (r: Role) => void;
  user: ReturnType<typeof getPerson>;
  isPMO: boolean;
  isHOD: boolean;
  isBO: boolean;
  isDhanshree: boolean;
  assignedClientIds: string[];
  assignedClients: typeof clients;
  assignedProjects: typeof projects;
  assignedIssues: typeof issues;
  pendingTimesheets: typeof timesheets;
}

const RoleContext = createContext<RoleContextValue | null>(null);

const userByRole: Record<Role, string> = {
  senior_pm: "u1",
  engagement_manager: "u2",
  pmo: "u11",
  hod: "u12",
  business_owner: "u13",
  dhanshree: "u14",
};

export function RoleProvider({ children }: { children: ReactNode }) {
  const [role, setRole] = useState<Role>("dhanshree");
  const user = getPerson(userByRole[role]);
  const isPMO = role === "pmo";
  const isHOD = role === "hod";
  const isBO = role === "business_owner";
  const isDhanshree = role === "dhanshree";
  const assignedClientIds = assignments[role];
  const assignedClients = clients.filter((c) => assignedClientIds.includes(c.id));
  const assignedProjects = projects.filter((p) => assignedClientIds.includes(p.clientId));
  const projectIds = new Set(assignedProjects.map((p) => p.id));
  const assignedIssues = issues.filter((i) => projectIds.has(i.projectId));
  const pendingTimesheets = timesheets.filter((t) => {
    if (t.status !== "submitted") return isPMO ? true : false;
    if (isPMO) return true; // monitoring all
    if (isHOD) return t.userRole === "Senior PM" || t.userRole === "EM";
    if (isBO) return false; // BO does not approve timesheets
    if (isDhanshree) return t.userRole === "PM" || t.userRole === "TL" || t.userRole === "Employee";
    return t.userRole === "PM";
  });

  return (
    <RoleContext.Provider
      value={{ role, setRole, user, isPMO, isHOD, isBO, isDhanshree, assignedClientIds, assignedClients, assignedProjects, assignedIssues, pendingTimesheets }}
    >
      {children}
    </RoleContext.Provider>
  );
}

export function useRoleContext() {
  const ctx = useContext(RoleContext);
  if (!ctx) throw new Error("useRoleContext must be used inside RoleProvider");
  return ctx;
}

export const roleLabels: Record<Role, string> = {
  senior_pm: "Senior Project Manager",
  engagement_manager: "Engagement Manager",
  pmo: "PMO",
  hod: "Head of Department",
  business_owner: "Business Owner",
  dhanshree: "Admin",
};
