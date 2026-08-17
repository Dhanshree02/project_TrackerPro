import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import type { Role } from "@/lib/mock-data";
import {
  assignments,
  clients,
  getPerson,
  people,
  projects,
  issues,
  timesheets,
} from "@/lib/mock-data";
import { useAuth } from "@/lib/auth-context";

interface RoleContextValue {
  role: Role;
  setRole: (r: Role) => void;
  user: ReturnType<typeof getPerson>;
  isPMO: boolean;
  isHOD: boolean;
  isBO: boolean;
  isDhanshree: boolean;
  /** True when the signed-in user holds the backend Employee role. */
  isEmployee: boolean;
  /** True when the signed-in user holds the backend HR role. */
  isHr: boolean;
  /** True when the signed-in user holds the backend Project Manager role. */
  isProjectManager: boolean;
  /** Mock-directory person matching the signed-in user (by email), if any. */
  employeePersonId: string | null;
  /** Mock-directory person id of the signed-in Project Manager (by email), if any. */
  pmPersonId: string | null;
  /**
   * Projects the Employee is involved in (PM / TL / team / shadow team).
   * Null for every non-Employee role.
   */
  employeeProjectIds: Set<string> | null;
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

/**
 * Maps a backend role key to the 6 frontend mock-data roles. The mapping only
 * controls which demo data the pages scope to — the real RBAC enforcement is
 * permission-based (JWT claims + backend guards + the permission provider).
 */
const roleFromBackend: Record<string, Role> = {
  SeniorPm: "senior_pm",
  EngagementManager: "engagement_manager",
  Pmo: "pmo",
  Hod: "hod",
  BusinessOwner: "business_owner",
  Dhanshree: "dhanshree",
  Admin: "dhanshree", // super-admin sees the full workspace
  Sales: "business_owner",
  Accounts: "business_owner",
  Hr: "business_owner",
  ProjectManager: "senior_pm",
  TeamLead: "senior_pm",
  Employee: "senior_pm",
};

const fallbackRole: Role = "senior_pm";

function mapBackendRole(role?: string | null): Role {
  return (role && roleFromBackend[role]) || fallbackRole;
}

/**
 * Human-readable labels for the backend role keys (mirrors the seeded
 * DisplayName values). Used in the topbar so the real role is shown, not the
 * mock-data scope role.
 */
export const backendRoleLabels: Record<string, string> = {
  Admin: "Admin",
  Dhanshree: "Admin (Dhanshree)",
  SeniorPm: "Senior Project Manager",
  EngagementManager: "Engagement Manager",
  Pmo: "PMO",
  Hod: "HOD",
  BusinessOwner: "Business Owner",
  ProjectManager: "Project Manager",
  TeamLead: "Team Lead",
  Employee: "Employee",
  Hr: "HR",
  Accounts: "Accounts & Finance",
  Sales: "Sales & Business Development",
};

const initialsOf = (name: string) =>
  name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w[0]?.toUpperCase())
    .join("") || "?";

export function RoleProvider({ children }: { children: ReactNode }) {
  const { user: authUser, status } = useAuth();
  const [role, setRole] = useState<Role>(() => mapBackendRole(authUser?.role));

  // Sync the role whenever the authenticated user changes (login/logout).
  useEffect(() => {
    setRole(mapBackendRole(authUser?.role));
  }, [authUser?.role]);

  const user =
    authUser && status === "authed"
      ? {
          id: authUser.id,
          name: authUser.name,
          role: authUser.role ?? "",
          avatar: authUser.name ? initialsOf(authUser.name) : "?",
          email: authUser.email,
        }
      : getPerson(userByRole[role]);
  const isPMO = role === "pmo";
  const isHOD = role === "hod";
  const isBO = role === "business_owner";
  const isDhanshree = role === "dhanshree";

  // ── Employee scoping: only projects the signed-in Employee is on ──────────
  // The Employee never sees projects they are not involved in (dashboard,
  // project list, issues, timesheet approvals). Involvement is matched by
  // email against the mock directory, mirroring the seeded test accounts.
  const isEmployee = !!authUser && status === "authed" && authUser.role === "Employee";
  const isHr = !!authUser && status === "authed" && authUser.role === "Hr";
  const isProjectManager = !!authUser && status === "authed" && authUser.role === "ProjectManager";
  const employeePersonId = isEmployee
    ? (people.find((p) => p.email.toLowerCase() === (authUser?.email ?? "").toLowerCase())?.id ??
      null)
    : null;
  const pmPersonId = isProjectManager
    ? (people.find((p) => p.email.toLowerCase() === (authUser?.email ?? "").toLowerCase())?.id ??
      null)
    : null;
  const employeeProjectIds = useMemo(() => {
    if (!isEmployee || !employeePersonId) return null;
    const ids = new Set<string>();
    projects.forEach((p) => {
      if (
        p.pmId === employeePersonId ||
        p.tlId === employeePersonId ||
        p.teamIds.includes(employeePersonId) ||
        (p.shadowTeamIds ?? []).includes(employeePersonId)
      ) {
        ids.add(p.id);
      }
    });
    return ids;
  }, [isEmployee, employeePersonId]);

  const assignedClientIds = assignments[role];
  const assignedClients =
    isEmployee && employeeProjectIds
      ? (() => {
          const clientIds = new Set(
            projects.filter((p) => employeeProjectIds.has(p.id)).map((p) => p.clientId),
          );
          return clients.filter((c) => clientIds.has(c.id));
        })()
      : isProjectManager
        ? clients // PM sees the full customer directory (cannot add new ones)
        : clients.filter((c) => assignedClientIds.includes(c.id));
  const assignedProjects =
    isEmployee && employeeProjectIds
      ? projects.filter((p) => employeeProjectIds.has(p.id))
      : isProjectManager && pmPersonId
        ? projects.filter((p) => p.pmId === pmPersonId) // dashboard shows only the PM's own projects
        : projects.filter((p) => assignedClientIds.includes(p.clientId));
  const projectIds = new Set(assignedProjects.map((p) => p.id));
  const assignedIssues = issues.filter((i) => projectIds.has(i.projectId));
  const pendingTimesheets = isEmployee
    ? []
    : timesheets.filter((t) => {
        if (t.status !== "submitted") return isPMO ? true : false;
        if (isPMO) return true; // monitoring all
        if (isHOD) return t.userRole === "Senior PM" || t.userRole === "EM";
        if (isBO) return false; // BO does not approve timesheets
        if (isDhanshree)
          return t.userRole === "PM" || t.userRole === "TL" || t.userRole === "Employee";
        return t.userRole === "PM";
      });

  return (
    <RoleContext.Provider
      value={{
        role,
        setRole,
        user,
        isPMO,
        isHOD,
        isBO,
        isDhanshree,
        isEmployee,
        isHr,
        isProjectManager,
        employeePersonId,
        pmPersonId,
        employeeProjectIds,
        assignedClientIds,
        assignedClients,
        assignedProjects,
        assignedIssues,
        pendingTimesheets,
      }}
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
