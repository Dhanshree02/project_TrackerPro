import { createContext, useContext, useEffect, useMemo, useState, useCallback, type ReactNode } from "react";
import type { Role, Client, Project, Issue, Timesheet } from "@/lib/domain-models";
import {
  assignments,
  getPerson,
  people,
  issues,
} from "@/lib/domain-models";
import { fetchClients, mapApiClient } from "@/lib/api/clients";
import { fetchProjects, mapApiProjectToProject } from "@/lib/api/projects";
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
  isItAdmin: boolean;
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
  assignedClients: Client[];
  assignedProjects: Project[];
  assignedIssues: Issue[];
  pendingTimesheets: Timesheet[];
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

const fallbackRole: Role = "Admin";

function mapBackendRole(role?: string | null): Role {
  return (role && roleFromBackend[role]) || fallbackRole;
}

export const backendRoleLabels: Record<string, string> = {
  CEO: "Chief Executive Officer",
  COO: "Chief Operating Officer",
  CTO: "Chief Technology Officer",
  "IT Admin": "IT Administrator (restricted)",
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
  Admin: "Super Administrator (full access)",
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

  const isItAdmin =
    !!authUser &&
    status === "authed" &&
    (backendRole === "IT Admin" || role === "IT Admin");

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

  const [dbProjects, setDbProjects] = useState<Project[]>([]);
  const [dbClients, setDbClients] = useState<Client[]>([]);

  useEffect(() => {
    if (typeof window === "undefined") return;
    let active = true;
    Promise.all([
      fetchProjects({ perPage: 500 }).catch(() => null),
      fetchClients(1, 200).catch(() => null),
    ]).then(([projRes, clientRes]) => {
      if (!active) return;
      setDbProjects((projRes?.items ?? []).map((p) => mapApiProjectToProject(p)));
      setDbClients((clientRes ?? []).map(mapApiClient));
    });
    return () => {
      active = false;
    };
  }, [authUser?.id, status]);

  const directoryPersonId =
    authUser?.employeeId ??
    people.find(
      (p) => p.email.toLowerCase() === (authUser?.email ?? "").toLowerCase(),
    )?.id ??
    null;
  const employeePersonId = isEmployee ? directoryPersonId : null;
  const pmPersonId = isProjectManager ? directoryPersonId : null;

  const employeeProjectIds = useMemo(() => {
    if (!isEmployee || !employeePersonId) return null;
    const empId = employeePersonId.toLowerCase();
    const ids = new Set<string>();
    dbProjects.forEach((p) => {
      if (
        p.pmId?.toLowerCase() === empId ||
        p.tlId?.toLowerCase() === empId ||
        (p.teamLeads ?? []).some((tl) => tl.employeeId.toLowerCase() === empId) ||
        p.teamIds.some((id) => id.toLowerCase() === empId) ||
        (p.shadowTeamIds ?? []).some((id) => id.toLowerCase() === empId)
      ) {
        ids.add(p.id);
      }
    });
    return ids.size > 0 ? ids : null;
  }, [isEmployee, employeePersonId, dbProjects]);

  const assignedClientIds = assignments[role] ?? [];
  const assignedProjects = useMemo(() => {
    const empId = (directoryPersonId ?? "").toLowerCase();
    const empName = (authUser?.name ?? "").trim().toLowerCase();

    if (isEmployee && employeeProjectIds) {
      return dbProjects.filter((p) => employeeProjectIds.has(p.id));
    }
    if ((isProjectManager || isSeniorPm) && (empId || empName)) {
      const matched = dbProjects.filter(
        (p) =>
          (empId && p.pmId?.toLowerCase() === empId) ||
          (p.projectManagers ?? []).some(
            (m) =>
              (empId && m.employeeId.toLowerCase() === empId) ||
              (empName && m.name.trim().toLowerCase() === empName),
          ) ||
          (p.seniorProjectManagers ?? []).some(
            (m) =>
              (empId && m.employeeId.toLowerCase() === empId) ||
              (empName && m.name.trim().toLowerCase() === empName),
          ),
      );
      if (matched.length > 0) return matched;
    }
    if (isEngagementManager && empName) {
      const matched = dbProjects.filter(
        (p) => (p.engagementManager ?? "").trim().toLowerCase() === empName,
      );
      if (matched.length > 0) return matched;
    }
    return dbProjects;
  }, [
    dbProjects,
    isEmployee,
    employeeProjectIds,
    isProjectManager,
    isSeniorPm,
    isEngagementManager,
    directoryPersonId,
    authUser?.name,
  ]);

  const assignedClients = useMemo(() => {
    if (isEmployee && employeeProjectIds) {
      const clientIds = new Set(
        dbProjects.filter((p) => employeeProjectIds.has(p.id)).map((p) => p.clientId),
      );
      return dbClients.filter((c) => clientIds.has(c.id));
    }
    return dbClients;
  }, [isEmployee, employeeProjectIds, dbProjects, dbClients]);

  const projectIds = new Set(assignedProjects.map((p) => p.id));
  const assignedIssues = issues.filter((i) => projectIds.has(i.projectId));
  const pendingTimesheets: Timesheet[] = [];

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
        isItAdmin,
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
