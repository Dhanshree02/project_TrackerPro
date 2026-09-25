import { createContext, useContext, useEffect, useMemo, useState, useCallback, type ReactNode } from "react";
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
import { usePermissions } from "@/lib/permissions";
import { RBAC_STORAGE_KEY, permissionsForRole, type PermissionKey } from "@/lib/rbac";

interface RoleContextValue {
  role: Role;
  setRole: (r: Role) => void;
  user: ReturnType<typeof getPerson>;
  can: (permission: string) => boolean;
  getPermissionsFor: (role: Role) => PermissionKey[];
  setRolePermissions: (role: Role, perms: PermissionKey[]) => void;
  resetRolePermissions: (role: Role) => void;
  isAdmin: boolean;
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
  Admin: "u15",
  CEO: "u13",
  COO: "u14",
  CTO: "u19",
  "IT Admin": "u32",
  Accounts: "u17",
  HR: "u16",
  "Sales Manager": "u18",
  "Sales team member": "u20",
  PMO: "u11",
  EngagementManager: "u2",
  Intern: "u21",
  "Testing HOD": "u22",
  "Testing Senior Manager": "u23",
  "Testing-Manager": "u24",
  "Testing-Team Leader": "u25",
  "Testing-Team Member": "u7",
  "Consulting-HOD": "u12",
  "Consulting-Senior Manager": "u1",
  "Consulting-Manager": "u4",
  "Consulting-Team Leader": "u6",
  "Consulting-Team member": "u26",
  "SOC-HOD": "u27",
  "SOC-Senior Manager": "u28",
  "SOC-Manager": "u3",
  "SOC-Team Leader": "u29",
  "SOC-Team Member": "u30",
  "R&D - Team member": "u31",
  // Legacy keys
  senior_pm: "u1",
  engagement_manager: "u2",
  pmo: "u11",
  hod: "u12",
  business_owner: "u13",
  dhanshree: "u14",
  pm: "u3",
  employee: "u7",
  hr: "u16",
  accounts_finance: "u17",
  sales_bd: "u18",
};

const roleFromBackend: Record<string, Role> = {
  Admin: "Admin",
  CEO: "CEO",
  COO: "COO",
  CTO: "CTO",
  "IT Admin": "IT Admin",
  Accounts: "Accounts",
  HR: "HR",
  "Sales Manager": "Sales Manager",
  "Sales team member": "Sales team member",
  PMO: "PMO",
  EngagementManager: "EngagementManager",
  Intern: "Intern",
  "Testing HOD": "Testing HOD",
  "Testing Senior Manager": "Testing Senior Manager",
  "Testing-Manager": "Testing-Manager",
  "Testing-Team Leader": "Testing-Team Leader",
  "Testing-Team Member": "Testing-Team Member",
  "Consulting-HOD": "Consulting-HOD",
  "Consulting-Senior Manager": "Consulting-Senior Manager",
  "Consulting-Manager": "Consulting-Manager",
  "Consulting-Team Leader": "Consulting-Team Leader",
  "Consulting-Team member": "Consulting-Team member",
  "SOC-HOD": "SOC-HOD",
  "SOC-Senior Manager": "SOC-Senior Manager",
  "SOC-Manager": "SOC-Manager",
  "SOC-Team Leader": "SOC-Team Leader",
  "SOC-Team Member": "SOC-Team Member",
  "R&D - Team member": "R&D - Team member",
  // Legacy aliases
  SeniorPm: "Consulting-Senior Manager",
  ProjectManager: "Testing-Manager",
  TeamLead: "Testing-Team Leader",
  Employee: "Testing-Team Member",
  BusinessOwner: "CEO",
  Dhanshree: "COO",
  Pmo: "PMO",
  Hod: "Testing HOD",
  Hr: "HR",
  Sales: "Sales Manager",
};

const fallbackRole: Role = "CEO";

function mapBackendRole(role?: string | null): Role {
  return (role && roleFromBackend[role]) || fallbackRole;
}

export const backendRoleLabels: Record<string, string> = {
  CEO: "Chief Executive Officer",
  COO: "Chief Operating Officer",
  CTO: "Chief Technology Officer",
  "IT Admin": "IT Administrator",
  Accounts: "Accounts & Finance",
  HR: "Human Resources",
  "Sales Manager": "Sales Manager",
  "Sales team member": "Sales Team Member",
  PMO: "Project Management Office",
  EngagementManager: "Engagement Manager",
  Intern: "Intern",
  "Testing HOD": "Testing Head of Department",
  "Testing Senior Manager": "Testing Senior Manager",
  "Testing-Manager": "Testing Project Manager",
  "Testing-Team Leader": "Testing Team Leader",
  "Testing-Team Member": "Testing Team Member",
  "Consulting-HOD": "Consulting Head of Department",
  "Consulting-Senior Manager": "Consulting Senior Manager",
  "Consulting-Manager": "Consulting Project Manager",
  "Consulting-Team Leader": "Consulting Team Leader",
  "Consulting-Team member": "Consulting Team Member",
  "SOC-HOD": "SOC Head of Department",
  "SOC-Senior Manager": "SOC Senior Manager",
  "SOC-Manager": "SOC Manager",
  "SOC-Team Leader": "SOC Team Leader",
  "SOC-Team Member": "SOC Team Member",
  "R&D - Team member": "R&D Team Member",
  Admin: "Admin",
  Dhanshree: "Admin (Dhanshree)",
  SeniorPm: "Senior Project Manager",
  ProjectManager: "Project Manager",
  TeamLead: "Team Lead",
  Employee: "Employee",
  BusinessOwner: "Business Owner",
  Hod: "Head of Department",
  Pmo: "PMO",
  Hr: "HR",
  Sales: "Sales & BD",
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
    !!authUser &&
    status === "authed" &&
    (backendRole === "CEO" ||
      backendRole === "COO" ||
      backendRole === "Admin" ||
      backendRole === "Dhanshree");

  const isAdmin =
    role === "Admin" ||
    role === "dhanshree" ||
    authUser?.role?.toLowerCase() === "admin" ||
    authUser?.role?.toLowerCase() === "dhanshree" ||
    backendRole?.toLowerCase() === "admin" ||
    backendRole?.toLowerCase() === "dhanshree";

  const isBO =
    !!authUser &&
    status === "authed" &&
    (backendRole === "CEO" || backendRole === "COO" || backendRole === "BusinessOwner");

  const isHOD =
    !!authUser &&
    status === "authed" &&
    (backendRole === "Testing HOD" ||
      backendRole === "Consulting-HOD" ||
      backendRole === "SOC-HOD" ||
      backendRole === "Hod");

  const isSeniorPm =
    !!authUser &&
    status === "authed" &&
    (backendRole === "Testing Senior Manager" ||
      backendRole === "Consulting-Senior Manager" ||
      backendRole === "SOC-Senior Manager" ||
      backendRole === "SeniorPm");

  const isProjectManager =
    !!authUser &&
    status === "authed" &&
    (backendRole === "Testing-Manager" ||
      backendRole === "Consulting-Manager" ||
      backendRole === "SOC-Manager" ||
      backendRole === "ProjectManager");

  const isTeamLead =
    !!authUser &&
    status === "authed" &&
    (backendRole === "Testing-Team Leader" ||
      backendRole === "Consulting-Team Leader" ||
      backendRole === "SOC-Team Leader" ||
      backendRole === "TeamLead");

  const isEmployee =
    !!authUser &&
    status === "authed" &&
    (backendRole === "Testing-Team Member" ||
      backendRole === "Consulting-Team member" ||
      backendRole === "SOC-Team Member" ||
      backendRole === "R&D - Team member" ||
      backendRole === "Intern" ||
      backendRole === "Sales team member" ||
      backendRole === "Employee");

  const isHr =
    !!authUser && status === "authed" && (backendRole === "HR" || backendRole === "Hr");

  const isEngagementManager =
    !!authUser && status === "authed" && backendRole === "EngagementManager";

  const isPMO =
    !!authUser && status === "authed" && (backendRole === "PMO" || backendRole === "Pmo");

  const isAccounts =
    !!authUser && status === "authed" && backendRole === "Accounts";

  const isSales =
    !!authUser &&
    status === "authed" &&
    (backendRole === "Sales Manager" ||
      backendRole === "Sales team member" ||
      backendRole === "Sales");

  const isPmFamily = isProjectManager || isSeniorPm || isEngagementManager || isTeamLead;
  const isPmoFamily = isPMO || isBO || isHOD;
  /** Business Owner is view-only everywhere; HOD is view-only except approvals / acknowledge. */
  const isViewOnly = isBO || isHOD || backendRole === "Intern";
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
    if (isAdmin || isPMO || isBO || isAccounts || isSales || isDhanshree) {
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
    if (isAdmin || isPmFamily || isPmoFamily || isAccounts || isSales || isDhanshree) {
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

  const { hasPermission } = usePermissions();
  const [roleOverrides, setRoleOverrides] = useState<Partial<Record<Role, PermissionKey[]>>>(() => {
    if (typeof window !== "undefined") {
      try {
        const raw = localStorage.getItem(RBAC_STORAGE_KEY);
        if (raw) return JSON.parse(raw);
      } catch {
        /* ignore */
      }
    }
    return {};
  });

  const getPermissionsFor = useCallback(
    (targetRole: Role): PermissionKey[] => {
      return permissionsForRole(targetRole, roleOverrides);
    },
    [roleOverrides],
  );

  const setRolePermissions = useCallback((targetRole: Role, perms: PermissionKey[]) => {
    setRoleOverrides((prev) => {
      const next = { ...prev, [targetRole]: perms };
      if (typeof window !== "undefined") {
        try {
          localStorage.setItem(RBAC_STORAGE_KEY, JSON.stringify(next));
        } catch {
          /* ignore */
        }
      }
      return next;
    });
  }, []);

  const resetRolePermissions = useCallback((targetRole: Role) => {
    setRoleOverrides((prev) => {
      const next = { ...prev };
      delete next[targetRole];
      if (typeof window !== "undefined") {
        try {
          localStorage.setItem(RBAC_STORAGE_KEY, JSON.stringify(next));
        } catch {
          /* ignore */
        }
      }
      return next;
    });
  }, []);

  const can = useCallback(
    (perm: string): boolean => {
      if (isAdmin || isDhanshree) return true;
      if (hasPermission(perm)) return true;
      const currentRolePerms = getPermissionsFor(role);
      return currentRolePerms.includes(perm as PermissionKey);
    },
    [isAdmin, isDhanshree, hasPermission, getPermissionsFor, role],
  );

  return (
    <RoleContext.Provider
      value={{
        role,
        setRole,
        user,
        can,
        getPermissionsFor,
        setRolePermissions,
        resetRolePermissions,
        isAdmin,
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
  Admin: "Admin",
  CEO: "CEO",
  COO: "COO",
  CTO: "CTO",
  "IT Admin": "IT Admin",
  Accounts: "Accounts & Finance",
  HR: "Human Resources",
  "Sales Manager": "Sales Manager",
  "Sales team member": "Sales Team Member",
  PMO: "PMO",
  EngagementManager: "Engagement Manager",
  Intern: "Intern",
  "Testing HOD": "Testing HOD",
  "Testing Senior Manager": "Testing Senior Manager",
  "Testing-Manager": "Testing Project Manager",
  "Testing-Team Leader": "Testing Team Leader",
  "Testing-Team Member": "Testing Team Member",
  "Consulting-HOD": "Consulting HOD",
  "Consulting-Senior Manager": "Consulting Senior Manager",
  "Consulting-Manager": "Consulting Project Manager",
  "Consulting-Team Leader": "Consulting Team Leader",
  "Consulting-Team member": "Consulting Team Member",
  "SOC-HOD": "SOC HOD",
  "SOC-Senior Manager": "SOC Senior Manager",
  "SOC-Manager": "SOC Manager",
  "SOC-Team Leader": "SOC Team Leader",
  "SOC-Team Member": "SOC Team Member",
  "R&D - Team member": "R&D Team Member",
  // Legacy keys
  senior_pm: "Senior Project Manager",
  engagement_manager: "Engagement Manager",
  pmo: "PMO",
  hod: "Head of Department",
  business_owner: "Business Owner",
  dhanshree: "Admin",
  employee: "Employee",
  pm: "Project Manager",
  hr: "HR",
  accounts_finance: "Accounts & Finance",
  sales_bd: "Sales & BD",
};
