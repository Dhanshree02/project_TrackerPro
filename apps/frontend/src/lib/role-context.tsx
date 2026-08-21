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
import { getDept } from "@/lib/dh-helpers";
import { useAuth } from "@/lib/auth-context";

interface RoleContextValue {
  role: Role;
  setRole: (r: Role) => void;
  user: ReturnType<typeof getPerson>;
  isPMO: boolean;
  isHOD: boolean;
  isBO: boolean;
  isDhanshree: boolean;
  isEmployee: boolean;
  isHr: boolean;
  isProjectManager: boolean;
  isSeniorPm: boolean;
  isEngagementManager: boolean;
  isAccounts: boolean;
  isSales: boolean;
  /** PM, Senior PM, or Engagement Manager — share the PM workspace. */
  isPmFamily: boolean;
  /** PMO, Business Owner, or HOD. */
  isPmoFamily: boolean;
  /** Everywhere-view-only (Business Owner). HOD is view-only except approvals. */
  isViewOnly: boolean;
  hideBudget: boolean;
  employeePersonId: string | null;
  pmPersonId: string | null;
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

const roleFromBackend: Record<string, Role> = {
  SeniorPm: "senior_pm",
  EngagementManager: "engagement_manager",
  Pmo: "pmo",
  Hod: "hod",
  BusinessOwner: "business_owner",
  Dhanshree: "dhanshree",
  Admin: "dhanshree",
  Sales: "business_owner",
  Accounts: "pmo",
  Hr: "business_owner",
  ProjectManager: "senior_pm",
  TeamLead: "senior_pm",
  Employee: "senior_pm",
};

const fallbackRole: Role = "senior_pm";

function mapBackendRole(role?: string | null): Role {
  return (role && roleFromBackend[role]) || fallbackRole;
}

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

  useEffect(() => {
    setRole(mapBackendRole(authUser?.role));
  }, [authUser?.role]);

  const backendRole = authUser?.role ?? "";
  const user =
    authUser && status === "authed"
      ? {
          id: authUser.id,
          name: authUser.name,
          role: backendRole,
          avatar: authUser.name ? initialsOf(authUser.name) : "?",
          email: authUser.email,
        }
      : getPerson(userByRole[role]);

  const isDhanshree =
    !!authUser && status === "authed" && (backendRole === "Dhanshree" || backendRole === "Admin");
  const isEmployee = !!authUser && status === "authed" && backendRole === "Employee";
  const isHr = !!authUser && status === "authed" && backendRole === "Hr";
  const isProjectManager = !!authUser && status === "authed" && backendRole === "ProjectManager";
  const isSeniorPm = !!authUser && status === "authed" && backendRole === "SeniorPm";
  const isEngagementManager =
    !!authUser && status === "authed" && backendRole === "EngagementManager";
  const isPMO = !!authUser && status === "authed" && backendRole === "Pmo";
  const isHOD = !!authUser && status === "authed" && backendRole === "Hod";
  const isBO = !!authUser && status === "authed" && backendRole === "BusinessOwner";
  const isAccounts = !!authUser && status === "authed" && backendRole === "Accounts";
  const isSales = !!authUser && status === "authed" && backendRole === "Sales";
  const isPmFamily = isProjectManager || isSeniorPm || isEngagementManager;
  const isPmoFamily = isPMO || isBO || isHOD;
  /** Business Owner is view-only everywhere; HOD is view-only except approvals / acknowledge. */
  const isViewOnly = isBO || isHOD;
  const hideBudget = isPmoFamily;

  const directoryPersonId = people.find(
    (p) => p.email.toLowerCase() === (authUser?.email ?? "").toLowerCase(),
  )?.id ?? null;
  const employeePersonId = isEmployee ? directoryPersonId : null;
  const pmPersonId = isProjectManager ? directoryPersonId : null;

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

  const hodProjectIds = useMemo(() => {
    if (!isHOD || !directoryPersonId) return null;
    const hodPerson = getPerson(directoryPersonId);
    const hodDept = getDept(hodPerson);
    const ids = new Set<string>();
    projects.forEach((p) => {
      const involved = [p.pmId, p.tlId, ...p.teamIds].map(getPerson);
      const match =
        involved.some((person) => getDept(person) === hodDept) ||
        involved.some((person) => ["Delivery", "Engineering"].includes(getDept(person)));
      if (match) ids.add(p.id);
    });
    return ids;
  }, [isHOD, directoryPersonId]);

  const assignedClientIds = assignments[role];
  const assignedProjects = useMemo(() => {
    if (isEmployee && employeeProjectIds) {
      return projects.filter((p) => employeeProjectIds.has(p.id));
    }
    if (isProjectManager && pmPersonId) {
      return projects.filter((p) => p.pmId === pmPersonId);
    }
    if (isSeniorPm && directoryPersonId) {
      return projects.filter((p) => p.pmId === directoryPersonId);
    }
    if (isEngagementManager && directoryPersonId) {
      const em = getPerson(directoryPersonId);
      return projects.filter(
        (p) =>
          (p.engagementManager ?? "").toLowerCase() === em.name.toLowerCase() ||
          p.pmId === directoryPersonId,
      );
    }
    if (isHOD && hodProjectIds) {
      return projects.filter((p) => hodProjectIds.has(p.id));
    }
    if (isPMO || isBO || isAccounts || isSales || isDhanshree) {
      return projects;
    }
    return projects.filter((p) => assignedClientIds.includes(p.clientId));
  }, [
    isEmployee,
    employeeProjectIds,
    isProjectManager,
    pmPersonId,
    isSeniorPm,
    isEngagementManager,
    directoryPersonId,
    isHOD,
    hodProjectIds,
    isPMO,
    isBO,
    isAccounts,
    isSales,
    isDhanshree,
    assignedClientIds,
  ]);

  const assignedClients = useMemo(() => {
    if (isEmployee && employeeProjectIds) {
      const clientIds = new Set(
        projects.filter((p) => employeeProjectIds.has(p.id)).map((p) => p.clientId),
      );
      return clients.filter((c) => clientIds.has(c.id));
    }
    if (isPmFamily || isPmoFamily || isAccounts || isSales || isDhanshree) {
      if (isHOD && hodProjectIds) {
        const clientIds = new Set(
          projects.filter((p) => hodProjectIds.has(p.id)).map((p) => p.clientId),
        );
        return clients.filter((c) => clientIds.has(c.id));
      }
      return clients;
    }
    return clients.filter((c) => assignedClientIds.includes(c.id));
  }, [
    isEmployee,
    employeeProjectIds,
    isPmFamily,
    isPmoFamily,
    isAccounts,
    isSales,
    isDhanshree,
    isHOD,
    hodProjectIds,
    assignedClientIds,
  ]);

  const projectIds = new Set(assignedProjects.map((p) => p.id));
  const assignedIssues = issues.filter((i) => projectIds.has(i.projectId));
  const pendingTimesheets = isEmployee
    ? timesheets.filter((t) => t.userId === employeePersonId && t.status === "submitted")
    : timesheets.filter((t) => {
        if (t.status !== "submitted") return isPMO ? true : false;
        if (isPMO) return true;
        if (isHOD) return t.userRole === "Senior PM" || t.userRole === "EM";
        if (isBO) return false;
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
        isSeniorPm,
        isEngagementManager,
        isAccounts,
        isSales,
        isPmFamily,
        isPmoFamily,
        isViewOnly,
        hideBudget,
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
