import { useState, useMemo, useRef, useEffect } from "react";
import {
  Users,
  Building2,
  Network,
  Mail,
  MapPin,
  Briefcase,
  GraduationCap,
  Award,
  Search,
  Plus,
  Pencil,
  Trash2,
  Filter,
  Check,
  CheckCircle2,
  X,
  Layers,
  ChevronDown,
  ChevronUp,
  ChevronRight,
  ShieldCheck,
  RotateCcw,
  Sparkles,
  Hash,
  AlertCircle,
  Building,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { SearchableSelect } from "@/components/creatable-catalog-select";
import { toast } from "sonner";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { cn } from "@/lib/utils";
import type {
  ResourceMastersState,
  ResourceMasterCategory,
  DepartmentHierarchyItem,
  EmailDomainItem,
  SimpleResourceMasterItem,
} from "@/lib/masters/types";
import {
  MASTER_DEPARTMENTS_LIST,
  MASTER_ON_FLOOR_ROLES_LIST,
  MASTER_ALL_RBAC_ROLES,
} from "@/lib/masters/resource-mock-data";

export interface ResourceMastersSectionProps {
  canManage?: boolean;
  resourceMasters: ResourceMastersState;
  onAddHierarchy: (item: Omit<DepartmentHierarchyItem, "id" | "createdAt">) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onUpdateHierarchy: (id: string, item: Partial<Omit<DepartmentHierarchyItem, "id" | "createdAt">>) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onDeleteHierarchy: (id: string) => Promise<void> | void;

  onAddEmailDomain: (domain: string, extra?: { displayName?: string; code?: string }) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onUpdateEmailDomain: (id: string, domain: string, extra?: { displayName?: string; code?: string; isActive?: boolean }) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onDeleteEmailDomain: (id: string) => Promise<void> | void;

  onAddSimpleItem: (category: "businessUnits" | "workLocations" | "graduationDegrees" | "postGraduationDegrees" | "certifications", name: string, extra?: { code?: string; description?: string }) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onUpdateSimpleItem: (category: "businessUnits" | "workLocations" | "graduationDegrees" | "postGraduationDegrees" | "certifications", id: string, name: string, extra?: { code?: string; description?: string; isActive?: boolean }) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onDeleteSimpleItem: (category: "businessUnits" | "workLocations" | "graduationDegrees" | "postGraduationDegrees" | "certifications", id: string) => Promise<void> | void;
}

interface CategoryMeta {
  id: ResourceMasterCategory | "all";
  title: string;
  shortTitle: string;
  icon: typeof Network;
  count: number;
  description: string;
}

export function ResourceMastersSection({
  canManage = true,
  resourceMasters,
  onAddHierarchy,
  onUpdateHierarchy,
  onDeleteHierarchy,
  onAddEmailDomain,
  onUpdateEmailDomain,
  onDeleteEmailDomain,
  onAddSimpleItem,
  onUpdateSimpleItem,
  onDeleteSimpleItem,
}: ResourceMastersSectionProps) {
  const [activeCategory, setActiveCategory] = useState<ResourceMasterCategory | "all">("hierarchy");

  const categories: CategoryMeta[] = useMemo(
    () => [
      {
        id: "hierarchy",
        title: "Department Hierarchy",
        shortTitle: "Dept Hierarchy",
        icon: Network,
        count: resourceMasters.departmentHierarchy.length,
        description: "Department → Designation → On Floor Role → Assigned RBAC Role mapping",
      },
      {
        id: "emailDomains",
        title: "Work Email Domain",
        shortTitle: "Email Domains",
        icon: Mail,
        count: resourceMasters.emailDomains.length,
        description: "Authorized corporate email domains for resource onboarding",
      },
      {
        id: "businessUnits",
        title: "Business Unit",
        shortTitle: "Business Units",
        icon: Building2,
        count: resourceMasters.businessUnits.length,
        description: "Operating business entities and organizational subsidiaries",
      },
      {
        id: "workLocations",
        title: "Work Location",
        shortTitle: "Work Locations",
        icon: Briefcase,
        count: resourceMasters.workLocations.length,
        description: "Physical office campuses, delivery centers, and onsite locations",
      },
      {
        id: "graduationDegrees",
        title: "Graduation Degree Name",
        shortTitle: "Grad Degrees",
        icon: GraduationCap,
        count: resourceMasters.graduationDegrees.length,
        description: "Undergraduate degree programs recognized across engineering and operations",
      },
      {
        id: "postGraduationDegrees",
        title: "Post Graduation Degree Name",
        shortTitle: "Post Grad Degrees",
        icon: GraduationCap,
        count: resourceMasters.postGraduationDegrees.length,
        description: "Master's degrees and postgraduate credentials",
      },
      {
        id: "certifications",
        title: "Certification Details",
        shortTitle: "Certifications",
        icon: Award,
        count: resourceMasters.certifications.length,
        description: "Cybersecurity, cloud, and project management technical accreditations",
      },
    ],
    [resourceMasters],
  );

  return (
    <div className="space-y-6">
      {/* ── Sub-category selection bar ───────────────────────────────────── */}
      <div className="flex flex-wrap items-center gap-1.5 p-1 rounded-xl bg-muted/60 border border-border">
        <button
          onClick={() => setActiveCategory("all")}
          className={cn(
            "flex items-center gap-2 px-3 py-1.5 text-xs font-medium rounded-lg transition-all",
            activeCategory === "all"
              ? "bg-card text-foreground shadow-sm font-semibold border border-border/80"
              : "text-muted-foreground hover:text-foreground",
          )}
        >
          <Layers className="h-3.5 w-3.5" />
          <span>All Masters Overview</span>
        </button>

        {categories.map((cat) => {
          const Icon = cat.icon;
          const isActive = activeCategory === cat.id;
          return (
            <button
              key={cat.id}
              onClick={() => setActiveCategory(cat.id as ResourceMasterCategory)}
              className={cn(
                "flex items-center gap-2 px-3 py-1.5 text-xs font-medium rounded-lg transition-all",
                isActive
                  ? "bg-card text-foreground shadow-sm font-semibold border border-border/80"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              <Icon className="h-3.5 w-3.5" />
              <span>{cat.shortTitle}</span>
              <span
                className={cn(
                  "ml-0.5 rounded-full px-1.5 py-0.2 text-[10px]",
                  isActive ? "bg-primary/15 text-primary font-semibold" : "bg-muted text-muted-foreground",
                )}
              >
                {cat.count}
              </span>
            </button>
          );
        })}
      </div>

      {/* ── Active View ──────────────────────────────────────────────────── */}
      {activeCategory === "all" ? (
        <div className="space-y-6">
          <DepartmentHierarchyCard
            canManage={canManage}
            items={resourceMasters.departmentHierarchy}
            onAdd={onAddHierarchy}
            onUpdate={onUpdateHierarchy}
            onDelete={onDeleteHierarchy}
          />

          <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
            <EmailDomainsCard
              canManage={canManage}
              items={resourceMasters.emailDomains}
              onAdd={onAddEmailDomain}
              onUpdate={onUpdateEmailDomain}
              onDelete={onDeleteEmailDomain}
            />

            <SimpleMasterCard
              canManage={canManage}
              categoryKey="businessUnits"
              title="Business Unit"
              singular="Business Unit"
              description="Legal and operating business subsidiaries"
              icon={Building2}
              placeholder="e.g. Talakunchi Networks Private Limited"
              items={resourceMasters.businessUnits}
              onAdd={(name, extra) => onAddSimpleItem("businessUnits", name, extra)}
              onUpdate={(id, name, extra) => onUpdateSimpleItem("businessUnits", id, name, extra)}
              onDelete={(id) => onDeleteSimpleItem("businessUnits", id)}
            />

            <SimpleMasterCard
              canManage={canManage}
              categoryKey="workLocations"
              title="Work Location"
              singular="Work Location"
              description="Physical office centers and client site locations"
              icon={Briefcase}
              placeholder="e.g. Navare Plaza, Dombivli, Onsite, Suvidha Square"
              items={resourceMasters.workLocations}
              onAdd={(name, extra) => onAddSimpleItem("workLocations", name, extra)}
              onUpdate={(id, name, extra) => onUpdateSimpleItem("workLocations", id, name, extra)}
              onDelete={(id) => onDeleteSimpleItem("workLocations", id)}
            />

            <SimpleMasterCard
              canManage={canManage}
              categoryKey="graduationDegrees"
              title="Graduation Degree Name"
              singular="Graduation Degree"
              description="Undergraduate degree qualifications"
              icon={GraduationCap}
              placeholder="e.g. B.Tech, B.E., B.Sc, B.Com, BBA"
              items={resourceMasters.graduationDegrees}
              onAdd={(name, extra) => onAddSimpleItem("graduationDegrees", name, extra)}
              onUpdate={(id, name, extra) => onUpdateSimpleItem("graduationDegrees", id, name, extra)}
              onDelete={(id) => onDeleteSimpleItem("graduationDegrees", id)}
            />

            <SimpleMasterCard
              canManage={canManage}
              categoryKey="postGraduationDegrees"
              title="Post Graduation Degree Name"
              singular="Post Graduation Degree"
              description="Master's degree qualifications"
              icon={GraduationCap}
              placeholder="e.g. M.Tech, ME, M.Sc, M.Com, MBA, MCA"
              items={resourceMasters.postGraduationDegrees}
              onAdd={(name, extra) => onAddSimpleItem("postGraduationDegrees", name, extra)}
              onUpdate={(id, name, extra) => onUpdateSimpleItem("postGraduationDegrees", id, name, extra)}
              onDelete={(id) => onDeleteSimpleItem("postGraduationDegrees", id)}
            />

            <SimpleMasterCard
              canManage={canManage}
              categoryKey="certifications"
              title="Certification Details"
              singular="Certification"
              description="Industry technical accreditations & credentials"
              icon={Award}
              placeholder="e.g. CISSP, CEH, CCSP, OSCP, CompTIA Security+"
              items={resourceMasters.certifications}
              onAdd={(name, extra) => onAddSimpleItem("certifications", name, extra)}
              onUpdate={(id, name, extra) => onUpdateSimpleItem("certifications", id, name, extra)}
              onDelete={(id) => onDeleteSimpleItem("certifications", id)}
            />
          </div>
        </div>
      ) : activeCategory === "hierarchy" ? (
        <DepartmentHierarchyCard
          canManage={canManage}
          items={resourceMasters.departmentHierarchy}
          onAdd={onAddHierarchy}
          onUpdate={onUpdateHierarchy}
          onDelete={onDeleteHierarchy}
          isExpandedView
        />
      ) : activeCategory === "emailDomains" ? (
        <EmailDomainsCard
          canManage={canManage}
          items={resourceMasters.emailDomains}
          onAdd={onAddEmailDomain}
          onUpdate={onUpdateEmailDomain}
          onDelete={onDeleteEmailDomain}
          isExpandedView
        />
      ) : activeCategory === "businessUnits" ? (
        <SimpleMasterCard
          canManage={canManage}
          categoryKey="businessUnits"
          title="Business Unit"
          singular="Business Unit"
          description="Legal and operating business subsidiaries"
          icon={Building2}
          placeholder="e.g. Talakunchi Networks Private Limited"
          items={resourceMasters.businessUnits}
          onAdd={(name, extra) => onAddSimpleItem("businessUnits", name, extra)}
          onUpdate={(id, name, extra) => onUpdateSimpleItem("businessUnits", id, name, extra)}
          onDelete={(id) => onDeleteSimpleItem("businessUnits", id)}
          isExpandedView
        />
      ) : activeCategory === "workLocations" ? (
        <SimpleMasterCard
          canManage={canManage}
          categoryKey="workLocations"
          title="Work Location"
          singular="Work Location"
          description="Physical office centers and client site locations"
          icon={Briefcase}
          placeholder="e.g. Navare Plaza, Dombivli, Onsite, Suvidha Square"
          items={resourceMasters.workLocations}
          onAdd={(name, extra) => onAddSimpleItem("workLocations", name, extra)}
          onUpdate={(id, name, extra) => onUpdateSimpleItem("workLocations", id, name, extra)}
          onDelete={(id) => onDeleteSimpleItem("workLocations", id)}
          isExpandedView
        />
      ) : activeCategory === "graduationDegrees" ? (
        <SimpleMasterCard
          canManage={canManage}
          categoryKey="graduationDegrees"
          title="Graduation Degree Name"
          singular="Graduation Degree"
          description="Undergraduate degree qualifications"
          icon={GraduationCap}
          placeholder="e.g. B.Tech, B.E., B.Sc, B.Com, BBA"
          items={resourceMasters.graduationDegrees}
          onAdd={(name, extra) => onAddSimpleItem("graduationDegrees", name, extra)}
          onUpdate={(id, name, extra) => onUpdateSimpleItem("graduationDegrees", id, name, extra)}
          onDelete={(id) => onDeleteSimpleItem("graduationDegrees", id)}
          isExpandedView
        />
      ) : activeCategory === "postGraduationDegrees" ? (
        <SimpleMasterCard
          canManage={canManage}
          categoryKey="postGraduationDegrees"
          title="Post Graduation Degree Name"
          singular="Post Graduation Degree"
          description="Master's degree qualifications"
          icon={GraduationCap}
          placeholder="e.g. M.Tech, ME, M.Sc, M.Com, MBA, MCA"
          items={resourceMasters.postGraduationDegrees}
          onAdd={(name, extra) => onAddSimpleItem("postGraduationDegrees", name, extra)}
          onUpdate={(id, name, extra) => onUpdateSimpleItem("postGraduationDegrees", id, name, extra)}
          onDelete={(id) => onDeleteSimpleItem("postGraduationDegrees", id)}
          isExpandedView
        />
      ) : (
        <SimpleMasterCard
          canManage={canManage}
          categoryKey="certifications"
          title="Certification Details"
          singular="Certification"
          description="Industry technical accreditations & credentials"
          icon={Award}
          placeholder="e.g. CISSP, CEH, CCSP, OSCP, CompTIA Security+"
          items={resourceMasters.certifications}
          onAdd={(name, extra) => onAddSimpleItem("certifications", name, extra)}
          onUpdate={(id, name, extra) => onUpdateSimpleItem("certifications", id, name, extra)}
          onDelete={(id) => onDeleteSimpleItem("certifications", id)}
          isExpandedView
        />
      )}
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 1. Department Hierarchy Card Component
// ══════════════════════════════════════════════════════════════════════════════
function DepartmentHierarchyCard({
  canManage = true,
  items,
  onAdd,
  onUpdate,
  onDelete,
  isExpandedView,
}: {
  canManage?: boolean;
  items: DepartmentHierarchyItem[];
  onAdd: (item: Omit<DepartmentHierarchyItem, "id" | "createdAt">) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onUpdate: (id: string, item: Partial<Omit<DepartmentHierarchyItem, "id" | "createdAt">>) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onDelete: (id: string) => Promise<void> | void;
  isExpandedView?: boolean;
}) {
  const formRef = useRef<HTMLFormElement>(null);

  // ── Cascaded Form State (Add New Hierarchy Mapping) ──────────────────────
  const [selectedDepartment, setSelectedDepartment] = useState<string>("");
  const [selectedDesignation, setSelectedDesignation] = useState<string>("");
  const [selectedFloorRole, setSelectedFloorRole] = useState<string>("");
  const [selectedRbacRole, setSelectedRbacRole] = useState<string>("");
  const [formError, setFormError] = useState<string | null>(null);

  // ── In-session Custom Entities Created via [+] Buttons ───────────────────
  const [customDepartments, setCustomDepartments] = useState<string[]>([]);
  const [customDesignationsByDept, setCustomDesignationsByDept] = useState<Record<string, string[]>>({});
  const [customFloorRolesByDesig, setCustomFloorRolesByDesig] = useState<Record<string, string[]>>({});
  const [customRbacRoles, setCustomRbacRoles] = useState<Array<{ id: string; name: string; displayName: string }>>([]);

  // ── Modal 1: Add Department ──────────────────────────────────────────────
  const [showAddDeptModal, setShowAddDeptModal] = useState(false);
  const [newDeptName, setNewDeptName] = useState("");
  const [addDeptError, setAddDeptError] = useState<string | null>(null);

  // ── Modal 2: Add Designation (under selected Department) ─────────────────
  const [showAddDesigModal, setShowAddDesigModal] = useState(false);
  const [newDesigName, setNewDesigName] = useState("");
  const [addDesigError, setAddDesigError] = useState<string | null>(null);

  // ── Modal 3: Add On Floor Role (under selected Designation) ──────────────
  const [showAddFloorRoleModal, setShowAddFloorRoleModal] = useState(false);
  const [newFloorRoleName, setNewFloorRoleName] = useState("");
  const [addFloorRoleError, setAddFloorRoleError] = useState<string | null>(null);

  // ── Modal 4: Add RBAC Role ───────────────────────────────────────────────
  const [showAddRbacRoleModal, setShowAddRbacRoleModal] = useState(false);
  const [newRbacRoleDisplayName, setNewRbacRoleDisplayName] = useState("");
  const [addRbacRoleError, setAddRbacRoleError] = useState<string | null>(null);

  // ── Edit Modal State ─────────────────────────────────────────────────────
  const [editingItem, setEditingItem] = useState<DepartmentHierarchyItem | null>(null);
  const [editDepartment, setEditDepartment] = useState<string>("");
  const [editDesignation, setEditDesignation] = useState<string>("");
  const [editFloorRole, setEditFloorRole] = useState<string>("");
  const [editRbacRole, setEditRbacRole] = useState<string>("");
  const [editError, setEditError] = useState<string | null>(null);

  // ── Delete Dialog ────────────────────────────────────────────────────────
  const [deleteId, setDeleteId] = useState<string | null>(null);

  // ── Filter & Search State ────────────────────────────────────────────────
  const [search, setSearch] = useState("");
  const [selectedDeptFilter, setSelectedDeptFilter] = useState<string>("ALL");
  const [selectedDesigFilter, setSelectedDesigFilter] = useState<string>("ALL");
  const [selectedRoleFilter, setSelectedRoleFilter] = useState<string>("ALL");

  // ── Level 1: Available Departments ───────────────────────────────────────
  const availableDepartments = useMemo(() => {
    const map = new Map<string, string>();
    MASTER_DEPARTMENTS_LIST.forEach((d) => {
      if (d) map.set(d.trim().toLowerCase(), d.trim());
    });
    items.forEach((item) => {
      if (item.departmentName) {
        map.set(item.departmentName.trim().toLowerCase(), item.departmentName.trim());
      }
    });
    customDepartments.forEach((d) => {
      if (d) map.set(d.trim().toLowerCase(), d.trim());
    });
    return Array.from(map.values()).sort((a, b) => a.localeCompare(b));
  }, [items, customDepartments]);

  // ── Level 2: Available Designations (Dependent on Selected Department) ────
  const availableDesignationsForDept = useMemo(() => {
    if (!selectedDepartment) return [];
    const map = new Map<string, string>();
    const deptNorm = selectedDepartment.trim().toLowerCase();

    // From current items matching selected department
    items.forEach((item) => {
      if (
        item.departmentName &&
        item.departmentName.trim().toLowerCase() === deptNorm &&
        item.designationName
      ) {
        map.set(item.designationName.trim().toLowerCase(), item.designationName.trim());
      }
    });

    // From custom designations created for this department
    const customList = customDesignationsByDept[selectedDepartment] || [];
    customList.forEach((desig) => {
      if (desig) map.set(desig.trim().toLowerCase(), desig.trim());
    });

    return Array.from(map.values()).sort((a, b) => a.localeCompare(b));
  }, [items, selectedDepartment, customDesignationsByDept]);

  // ── Level 3: Available On Floor Roles (Dependent on Selected Designation) ─
  const availableFloorRolesForDesig = useMemo(() => {
    if (!selectedDesignation) return [];
    const map = new Map<string, string>();
    const deptNorm = (selectedDepartment || "").trim().toLowerCase();
    const desigNorm = selectedDesignation.trim().toLowerCase();

    // 1. Existing mappings for this dept & designation
    items.forEach((item) => {
      if (
        item.departmentName &&
        item.departmentName.trim().toLowerCase() === deptNorm &&
        item.designationName &&
        item.designationName.trim().toLowerCase() === desigNorm &&
        item.onFloorRoleName
      ) {
        map.set(item.onFloorRoleName.trim().toLowerCase(), item.onFloorRoleName.trim());
      }
    });

    // 2. Custom floor roles added for this designation
    const customRoles = customFloorRolesByDesig[selectedDesignation] || [];
    customRoles.forEach((role) => {
      if (role) map.set(role.trim().toLowerCase(), role.trim());
    });

    // 3. Always provide standard operational on-floor roles so choices are immediately available
    MASTER_ON_FLOOR_ROLES_LIST.forEach((r) => {
      if (r) map.set(r.trim().toLowerCase(), r.trim());
    });

    return Array.from(map.values()).sort((a, b) => a.localeCompare(b));
  }, [items, selectedDepartment, selectedDesignation, customFloorRolesByDesig]);

  // ── Level 4: Available RBAC Roles (Dependent on On Floor Role) ────────────
  const availableRbacRoles = useMemo(() => {
    const map = new Map<string, { id: string; name: string; displayName: string }>();

    MASTER_ALL_RBAC_ROLES.forEach((r) => {
      map.set(r.displayName.trim().toLowerCase(), r);
    });

    customRbacRoles.forEach((r) => {
      map.set(r.displayName.trim().toLowerCase(), r);
    });

    items.forEach((item) => {
      if (item.assignedRbacRoleName && !map.has(item.assignedRbacRoleName.trim().toLowerCase())) {
        map.set(item.assignedRbacRoleName.trim().toLowerCase(), {
          id: item.assignedRbacRoleId || `rbac-${Date.now()}`,
          name: item.assignedRbacRoleCode || item.assignedRbacRoleName,
          displayName: item.assignedRbacRoleName.trim(),
        });
      }
    });

    return Array.from(map.values()).sort((a, b) => a.displayName.localeCompare(b.displayName));
  }, [items, customRbacRoles]);

  const rbacSelectOptions = useMemo(() => {
    return availableRbacRoles.map((r) => ({
      value: r.displayName,
      label: r.displayName,
      subLabel: r.name ? `Code: ${r.name}` : undefined,
    }));
  }, [availableRbacRoles]);

  // ── Designations for Edit Dialog (Dependent on Edit Department) ───────────
  const editDesignationsForDept = useMemo(() => {
    if (!editDepartment) return [];
    const map = new Map<string, string>();
    const deptNorm = editDepartment.trim().toLowerCase();

    items.forEach((item) => {
      if (
        item.departmentName &&
        item.departmentName.trim().toLowerCase() === deptNorm &&
        item.designationName
      ) {
        map.set(item.designationName.trim().toLowerCase(), item.designationName.trim());
      }
    });

    const customList = customDesignationsByDept[editDepartment] || [];
    customList.forEach((desig) => {
      if (desig) map.set(desig.trim().toLowerCase(), desig.trim());
    });

    if (editDesignation) {
      map.set(editDesignation.trim().toLowerCase(), editDesignation.trim());
    }

    return Array.from(map.values()).sort((a, b) => a.localeCompare(b));
  }, [items, editDepartment, customDesignationsByDept, editDesignation]);

  // ── On Floor Roles for Edit Dialog (Dependent on Edit Designation) ────────
  const editFloorRolesForDesig = useMemo(() => {
    if (!editDesignation) return [];
    const map = new Map<string, string>();

    MASTER_ON_FLOOR_ROLES_LIST.forEach((r) => {
      if (r) map.set(r.trim().toLowerCase(), r.trim());
    });

    items.forEach((item) => {
      if (item.onFloorRoleName) {
        map.set(item.onFloorRoleName.trim().toLowerCase(), item.onFloorRoleName.trim());
      }
    });

    if (editFloorRole) {
      map.set(editFloorRole.trim().toLowerCase(), editFloorRole.trim());
    }

    return Array.from(map.values()).sort((a, b) => a.localeCompare(b));
  }, [items, editDesignation, editFloorRole]);

  // ── Step Completion Status ────────────────────────────────────────────────
  const isStep1Done = Boolean(selectedDepartment);
  const isStep2Done = Boolean(selectedDesignation);
  const isStep3Done = Boolean(selectedFloorRole);
  const isStep4Done = Boolean(selectedRbacRole);
  const canSubmit = isStep1Done && isStep2Done && isStep3Done && isStep4Done;

  // ── Cascading Handlers ────────────────────────────────────────────────────
  const handleDepartmentChange = (dept: string) => {
    setSelectedDepartment(dept);
    setSelectedDesignation("");
    setSelectedFloorRole("");
    setSelectedRbacRole("");
    setFormError(null);
  };

  const handleDesignationChange = (desig: string) => {
    setSelectedDesignation(desig);
    setSelectedFloorRole("");
    setSelectedRbacRole("");
    setFormError(null);
  };

  const handleFloorRoleChange = (role: string) => {
    setSelectedFloorRole(role);
    setSelectedRbacRole("");
    setFormError(null);
  };

  const handleRbacRoleChange = (role: string) => {
    setSelectedRbacRole(role);
    setFormError(null);
  };

  // ── Modal Submissions ─────────────────────────────────────────────────────
  const handleCreateDepartment = () => {
    const trimmed = newDeptName.trim();
    if (!trimmed) {
      setAddDeptError("Please enter a department name.");
      return;
    }
    const duplicate = availableDepartments.some(
      (d) => d.toLowerCase() === trimmed.toLowerCase(),
    );
    if (duplicate) {
      setAddDeptError(`Department "${trimmed}" already exists.`);
      return;
    }

    setCustomDepartments((prev) => [...prev, trimmed]);
    setSelectedDepartment(trimmed);
    setSelectedDesignation("");
    setSelectedFloorRole("");
    setSelectedRbacRole("");
    setFormError(null);
    setShowAddDeptModal(false);
    setNewDeptName("");
    setAddDeptError(null);
    toast.success(`Department "${trimmed}" created and selected.`);
  };

  const handleCreateDesignation = () => {
    const trimmed = newDesigName.trim();
    if (!trimmed) {
      setAddDesigError("Please enter a designation name.");
      return;
    }
    const targetDept = selectedDepartment || editDepartment;
    if (!targetDept) {
      setAddDesigError("Please select a department first.");
      return;
    }

    const existingInDept = availableDesignationsForDept.some(
      (d) => d.toLowerCase() === trimmed.toLowerCase(),
    );
    if (existingInDept) {
      setAddDesigError(`Designation "${trimmed}" already exists in ${targetDept}.`);
      return;
    }

    setCustomDesignationsByDept((prev) => ({
      ...prev,
      [targetDept]: [...(prev[targetDept] || []), trimmed],
    }));

    if (editingItem) {
      setEditDesignation(trimmed);
    } else {
      setSelectedDesignation(trimmed);
      setSelectedFloorRole("");
      setSelectedRbacRole("");
    }

    setFormError(null);
    setShowAddDesigModal(false);
    setNewDesigName("");
    setAddDesigError(null);
    toast.success(`Designation "${trimmed}" added to ${targetDept}.`);
  };

  const handleCreateFloorRole = () => {
    const trimmed = newFloorRoleName.trim();
    if (!trimmed) {
      setAddFloorRoleError("Please enter an on-floor role name.");
      return;
    }
    const targetDesig = selectedDesignation || editDesignation;

    setCustomFloorRolesByDesig((prev) => ({
      ...prev,
      [targetDesig]: [...(prev[targetDesig] || []), trimmed],
    }));

    if (editingItem) {
      setEditFloorRole(trimmed);
    } else {
      setSelectedFloorRole(trimmed);
      setSelectedRbacRole("");
    }

    setFormError(null);
    setShowAddFloorRoleModal(false);
    setNewFloorRoleName("");
    setAddFloorRoleError(null);
    toast.success(`On-floor role "${trimmed}" added.`);
  };

  const handleCreateRbacRole = () => {
    const dispTrim = newRbacRoleDisplayName.trim();

    if (!dispTrim) {
      setAddRbacRoleError("Please enter an RBAC role display name.");
      return;
    }

    const duplicate = availableRbacRoles.some(
      (r) => r.displayName.toLowerCase() === dispTrim.toLowerCase(),
    );
    if (duplicate) {
      setAddRbacRoleError(`RBAC role "${dispTrim}" already exists.`);
      return;
    }

    // Auto-generate clean programmatic Role Key / Code from the display name
    const autoCode = dispTrim.replace(/[^a-zA-Z0-9]/g, "") || `Role_${Date.now()}`;

    const newRoleObj = {
      id: `rbac-custom-${Date.now()}`,
      name: autoCode,
      displayName: dispTrim,
    };

    setCustomRbacRoles((prev) => [...prev, newRoleObj]);

    if (editingItem) {
      setEditRbacRole(dispTrim);
    } else {
      setSelectedRbacRole(dispTrim);
    }

    setFormError(null);
    setShowAddRbacRoleModal(false);
    setNewRbacRoleDisplayName("");
    setAddRbacRoleError(null);
    toast.success(`RBAC role "${dispTrim}" created and selected.`);
  };

  // ── Submit New Hierarchy Mapping ──────────────────────────────────────────
  const handleAddSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedDepartment) {
      setFormError("Step 1: Please select or add a Department.");
      return;
    }
    if (!selectedDesignation) {
      setFormError("Step 2: Please select or add a Designation.");
      return;
    }
    if (!selectedFloorRole) {
      setFormError("Step 3: Please select or add an On Floor Role.");
      return;
    }
    if (!selectedRbacRole) {
      setFormError("Step 4: Please select or add an Assigned RBAC Role.");
      return;
    }

    // Duplicate check
    const duplicate = items.some(
      (h) =>
        h.departmentName.toLowerCase().trim() === selectedDepartment.toLowerCase().trim() &&
        h.designationName.toLowerCase().trim() === selectedDesignation.toLowerCase().trim() &&
        h.onFloorRoleName.toLowerCase().trim() === selectedFloorRole.toLowerCase().trim(),
    );

    if (duplicate) {
      setFormError(
        `Hierarchy mapping for "${selectedDepartment} → ${selectedDesignation} → ${selectedFloorRole}" already exists.`,
      );
      return;
    }

    const rbacMeta = availableRbacRoles.find((r) => r.displayName === selectedRbacRole);

    const res = await onAdd({
      departmentName: selectedDepartment.trim(),
      designationName: selectedDesignation.trim(),
      onFloorRoleName: selectedFloorRole.trim(),
      assignedRbacRoleName: selectedRbacRole.trim(),
      assignedRbacRoleId: rbacMeta?.id,
      assignedRbacRoleCode: rbacMeta?.name,
      isActive: true,
    });

    if (!res.success) {
      setFormError(res.error || "Failed to add hierarchy mapping.");
    } else {
      // Keep Department & Designation for rapid entry of subsequent floor roles
      setSelectedFloorRole("");
      setSelectedRbacRole("");
      setFormError(null);
    }
  };

  // ── Edit Mapping ──────────────────────────────────────────────────────────
  const openEdit = (item: DepartmentHierarchyItem) => {
    setEditingItem(item);
    setEditDepartment(item.departmentName);
    setEditDesignation(item.designationName);
    setEditFloorRole(item.onFloorRoleName);
    setEditRbacRole(item.assignedRbacRoleName);
    setEditError(null);
  };

  const handleSaveEdit = async () => {
    if (!editingItem) return;
    if (!editDepartment.trim() || !editDesignation.trim() || !editFloorRole.trim() || !editRbacRole.trim()) {
      setEditError("All four hierarchy tiers are required.");
      return;
    }

    const rbacMeta = availableRbacRoles.find((r) => r.displayName === editRbacRole);

    const res = await onUpdate(editingItem.id, {
      departmentName: editDepartment.trim(),
      designationName: editDesignation.trim(),
      onFloorRoleName: editFloorRole.trim(),
      assignedRbacRoleName: editRbacRole.trim(),
      assignedRbacRoleId: rbacMeta?.id,
      assignedRbacRoleCode: rbacMeta?.name,
    });

    if (!res.success) {
      setEditError(res.error || "Failed to update hierarchy mapping.");
    } else {
      setEditingItem(null);
    }
  };

  // ── Cascaded Table Filter Calculations ────────────────────────────────────
  const filterDesignations = useMemo(() => {
    const set = new Set<string>();
    items.forEach((item) => {
      if (
        selectedDeptFilter === "ALL" ||
        item.departmentName.toLowerCase() === selectedDeptFilter.toLowerCase()
      ) {
        if (item.designationName) set.add(item.designationName);
      }
    });
    return Array.from(set).sort();
  }, [items, selectedDeptFilter]);

  const filterFloorRoles = useMemo(() => {
    const set = new Set<string>();
    items.forEach((item) => {
      const matchDept =
        selectedDeptFilter === "ALL" ||
        item.departmentName.toLowerCase() === selectedDeptFilter.toLowerCase();
      const matchDesig =
        selectedDesigFilter === "ALL" ||
        item.designationName.toLowerCase() === selectedDesigFilter.toLowerCase();

      if (matchDept && matchDesig && item.onFloorRoleName) {
        set.add(item.onFloorRoleName);
      }
    });
    return Array.from(set).sort();
  }, [items, selectedDeptFilter, selectedDesigFilter]);

  const filteredItems = useMemo(() => {
    return items.filter((item) => {
      const matchSearch =
        !search ||
        item.departmentName.toLowerCase().includes(search.toLowerCase()) ||
        item.designationName.toLowerCase().includes(search.toLowerCase()) ||
        item.onFloorRoleName.toLowerCase().includes(search.toLowerCase()) ||
        item.assignedRbacRoleName.toLowerCase().includes(search.toLowerCase());

      const matchDept = selectedDeptFilter === "ALL" || item.departmentName === selectedDeptFilter;
      const matchDesig = selectedDesigFilter === "ALL" || item.designationName === selectedDesigFilter;
      const matchRole = selectedRoleFilter === "ALL" || item.onFloorRoleName === selectedRoleFilter;

      return matchSearch && matchDept && matchDesig && matchRole;
    });
  }, [items, search, selectedDeptFilter, selectedDesigFilter, selectedRoleFilter]);

  return (
    <div className="space-y-6">
      {/* ══════════════════════════════════════════════════════════════════════ */}
      {/* Top Configuration Form: 4-Tier Cascading Hierarchy (Project Master Style) */}
      {/* ══════════════════════════════════════════════════════════════════════ */}
      {canManage && (
        <div className="rounded-xl border border-border bg-card p-5 shadow-sm space-y-4">
          {/* Header */}
          <div className="flex flex-col gap-3 border-b border-border pb-4 sm:flex-row sm:items-center sm:justify-between">
            <div className="flex items-start gap-3">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                <Network className="h-5 w-5" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h2 className="text-sm font-semibold text-foreground">
                    Department Hierarchy Configuration
                  </h2>
                  <Badge variant="secondary" className="text-[11px] font-normal bg-primary/10 text-primary">
                    {items.length} Configured
                  </Badge>
                </div>
                <p className="text-xs text-muted-foreground mt-0.5">
                  Define four-tier dependent mapping: Department ➔ Designation ➔ On Floor Role ➔ Assigned RBAC Role
                </p>
              </div>
            </div>

            <div className="text-xs text-muted-foreground hidden sm:block">
              Select or add each level sequentially
            </div>
          </div>

          <form ref={formRef} onSubmit={handleAddSubmit} className="space-y-4">
            {formError && (
              <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
                <AlertCircle className="h-4 w-4 shrink-0" />
                <span>{formError}</span>
              </div>
            )}

            {/* Visual Stepper / Breadcrumb Progress Banner */}
            <div className="flex flex-wrap items-center gap-2 p-2.5 rounded-lg bg-muted/40 border border-border/70 text-xs">
              <span className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mr-1">
                Hierarchy Chain:
              </span>

              {/* Step 1: Department */}
              <div
                className={cn(
                  "flex items-center gap-1.5 px-2.5 py-1 rounded-md transition-all font-medium text-xs",
                  isStep1Done
                    ? "bg-primary/15 text-primary border border-primary/30"
                    : "bg-card text-foreground border border-border",
                )}
              >
                <span
                  className={cn(
                    "flex h-4 w-4 items-center justify-center rounded-full text-[10px]",
                    isStep1Done
                      ? "bg-primary text-primary-foreground font-bold"
                      : "bg-muted-foreground/20 text-muted-foreground",
                  )}
                >
                  {isStep1Done ? "✓" : "1"}
                </span>
                <span>Department</span>
                {selectedDepartment && (
                  <span className="font-semibold text-foreground max-w-[130px] truncate">
                    ({selectedDepartment})
                  </span>
                )}
              </div>

              <ChevronRight className="h-3.5 w-3.5 text-muted-foreground/60 shrink-0" />

              {/* Step 2: Designation */}
              <div
                className={cn(
                  "flex items-center gap-1.5 px-2.5 py-1 rounded-md transition-all font-medium text-xs",
                  isStep2Done
                    ? "bg-primary/15 text-primary border border-primary/30"
                    : isStep1Done
                    ? "bg-card text-foreground border border-border"
                    : "opacity-50 text-muted-foreground bg-muted/20 border border-transparent",
                )}
              >
                <span
                  className={cn(
                    "flex h-4 w-4 items-center justify-center rounded-full text-[10px]",
                    isStep2Done
                      ? "bg-primary text-primary-foreground font-bold"
                      : "bg-muted-foreground/20 text-muted-foreground",
                  )}
                >
                  {isStep2Done ? "✓" : "2"}
                </span>
                <span>Designation</span>
                {selectedDesignation && (
                  <span className="font-semibold text-foreground max-w-[130px] truncate">
                    ({selectedDesignation})
                  </span>
                )}
              </div>

              <ChevronRight className="h-3.5 w-3.5 text-muted-foreground/60 shrink-0" />

              {/* Step 3: On Floor Role */}
              <div
                className={cn(
                  "flex items-center gap-1.5 px-2.5 py-1 rounded-md transition-all font-medium text-xs",
                  isStep3Done
                    ? "bg-primary/15 text-primary border border-primary/30"
                    : isStep2Done
                    ? "bg-card text-foreground border border-border"
                    : "opacity-50 text-muted-foreground bg-muted/20 border border-transparent",
                )}
              >
                <span
                  className={cn(
                    "flex h-4 w-4 items-center justify-center rounded-full text-[10px]",
                    isStep3Done
                      ? "bg-primary text-primary-foreground font-bold"
                      : "bg-muted-foreground/20 text-muted-foreground",
                  )}
                >
                  {isStep3Done ? "✓" : "3"}
                </span>
                <span>On Floor Role</span>
                {selectedFloorRole && (
                  <span className="font-semibold text-foreground max-w-[130px] truncate">
                    ({selectedFloorRole})
                  </span>
                )}
              </div>

              <ChevronRight className="h-3.5 w-3.5 text-muted-foreground/60 shrink-0" />

              {/* Step 4: Assigned RBAC Role */}
              <div
                className={cn(
                  "flex items-center gap-1.5 px-2.5 py-1 rounded-md transition-all font-medium text-xs",
                  isStep4Done
                    ? "bg-primary/15 text-primary border border-primary/30"
                    : isStep3Done
                    ? "bg-card text-foreground border border-border"
                    : "opacity-50 text-muted-foreground bg-muted/20 border border-transparent",
                )}
              >
                <span
                  className={cn(
                    "flex h-4 w-4 items-center justify-center rounded-full text-[10px]",
                    isStep4Done
                      ? "bg-primary text-primary-foreground font-bold"
                      : "bg-muted-foreground/20 text-muted-foreground",
                  )}
                >
                  {isStep4Done ? "✓" : "4"}
                </span>
                <span>Assigned RBAC Role</span>
                {selectedRbacRole && (
                  <span className="font-semibold text-foreground max-w-[130px] truncate">
                    ({selectedRbacRole})
                  </span>
                )}
              </div>
            </div>

            {/* 4 Cascading Dropdown Columns with [+] Buttons */}
            <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2 lg:grid-cols-4 min-w-0">
              {/* 1. Department [+] */}
              <div className="space-y-1.5 min-w-0">
                <div className="flex items-center justify-between">
                  <Label className="text-xs font-medium text-foreground">
                    1. Department <span className="text-destructive">*</span>
                  </Label>
                  <span className="text-[10px] text-muted-foreground">
                    {availableDepartments.length} depts
                  </span>
                </div>
                <div className="flex items-center gap-1.5 min-w-0 w-full">
                  <SearchableSelect
                    options={availableDepartments}
                    value={selectedDepartment}
                    onChange={handleDepartmentChange}
                    placeholder="Select Department"
                    searchPlaceholder="Search department..."
                    showSearch={true}
                    buttonClassName="h-9 text-xs bg-card border-border hover:bg-muted/30"
                    className="flex-1 min-w-0"
                    clearable={false}
                  />
                  <Button
                    type="button"
                    variant="outline"
                    size="icon"
                    className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary hover:bg-primary/10 hover:border-primary transition-all"
                    title="Add new Department"
                    onClick={() => {
                      setNewDeptName("");
                      setAddDeptError(null);
                      setShowAddDeptModal(true);
                    }}
                  >
                    <Plus className="h-4 w-4" />
                  </Button>
                </div>
              </div>

              {/* 2. Designation [+] - dependent on Department */}
              <div className="space-y-1.5 min-w-0">
                <div className="flex items-center justify-between">
                  <Label className="text-xs font-medium text-foreground">
                    2. Designation <span className="text-destructive">*</span>
                  </Label>
                  {selectedDepartment && (
                    <span className="text-[10px] text-muted-foreground">
                      {availableDesignationsForDept.length} in dept
                    </span>
                  )}
                </div>
                <div className="flex items-center gap-1.5 min-w-0 w-full">
                  <SearchableSelect
                    options={availableDesignationsForDept}
                    value={selectedDesignation}
                    onChange={handleDesignationChange}
                    placeholder={
                      selectedDepartment
                        ? availableDesignationsForDept.length > 0
                          ? "Select Designation"
                          : "Click [+] to add designation"
                        : "Select Department first"
                    }
                    searchPlaceholder="Search designation..."
                    showSearch={true}
                    disabled={!selectedDepartment}
                    disabledHint="Select Department first"
                    buttonClassName="h-9 text-xs bg-card border-border hover:bg-muted/30"
                    className="flex-1 min-w-0"
                    clearable={false}
                  />
                  <Button
                    type="button"
                    variant="outline"
                    size="icon"
                    className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary hover:bg-primary/10 hover:border-primary transition-all disabled:opacity-50"
                    title={
                      selectedDepartment
                        ? `Add new Designation in ${selectedDepartment}`
                        : "Select Department first"
                    }
                    disabled={!selectedDepartment}
                    onClick={() => {
                      setNewDesigName("");
                      setAddDesigError(null);
                      setShowAddDesigModal(true);
                    }}
                  >
                    <Plus className="h-4 w-4" />
                  </Button>
                </div>
              </div>

              {/* 3. On Floor Role [+] - dependent on Designation */}
              <div className="space-y-1.5 min-w-0">
                <div className="flex items-center justify-between">
                  <Label className="text-xs font-medium text-foreground">
                    3. On Floor Role <span className="text-destructive">*</span>
                  </Label>
                  {selectedDesignation && (
                    <span className="text-[10px] text-muted-foreground">
                      {availableFloorRolesForDesig.length} roles
                    </span>
                  )}
                </div>
                <div className="flex items-center gap-1.5 min-w-0 w-full">
                  <SearchableSelect
                    options={availableFloorRolesForDesig}
                    value={selectedFloorRole}
                    onChange={handleFloorRoleChange}
                    placeholder={
                      selectedDesignation
                        ? "Select On Floor Role"
                        : selectedDepartment
                        ? "Select Designation first"
                        : "Select Department first"
                    }
                    searchPlaceholder="Search on floor role..."
                    showSearch={true}
                    disabled={!selectedDesignation}
                    disabledHint={
                      selectedDepartment
                        ? "Select Designation first"
                        : "Select Department first"
                    }
                    buttonClassName="h-9 text-xs bg-card border-border hover:bg-muted/30"
                    className="flex-1 min-w-0"
                    clearable={false}
                  />
                  <Button
                    type="button"
                    variant="outline"
                    size="icon"
                    className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary hover:bg-primary/10 hover:border-primary transition-all disabled:opacity-50"
                    title={
                      selectedDesignation
                        ? `Add new On Floor Role for ${selectedDesignation}`
                        : "Select Designation first"
                    }
                    disabled={!selectedDesignation}
                    onClick={() => {
                      setNewFloorRoleName("");
                      setAddFloorRoleError(null);
                      setShowAddFloorRoleModal(true);
                    }}
                  >
                    <Plus className="h-4 w-4" />
                  </Button>
                </div>
              </div>

              {/* 4. Assigned RBAC Role [+] - dependent on On Floor Role */}
              <div className="space-y-1.5 min-w-0">
                <div className="flex items-center justify-between">
                  <Label className="text-xs font-medium text-foreground">
                    4. Assigned RBAC Role <span className="text-destructive">*</span>
                  </Label>
                  {selectedFloorRole && (
                    <span className="text-[10px] text-muted-foreground">
                      {availableRbacRoles.length} system roles
                    </span>
                  )}
                </div>
                <div className="flex items-center gap-1.5 min-w-0 w-full">
                  <SearchableSelect
                    options={rbacSelectOptions}
                    value={selectedRbacRole}
                    onChange={handleRbacRoleChange}
                    placeholder={
                      selectedFloorRole
                        ? "Select Assigned RBAC Role"
                        : selectedDesignation
                        ? "Select On Floor Role first"
                        : "Select previous steps first"
                    }
                    searchPlaceholder="Search RBAC role..."
                    showSearch={true}
                    disabled={!selectedFloorRole}
                    disabledHint={
                      selectedDesignation
                        ? "Select On Floor Role first"
                        : "Select previous steps first"
                    }
                    buttonClassName="h-9 text-xs bg-card border-border hover:bg-muted/30"
                    className="flex-1 min-w-0"
                    clearable={false}
                  />
                  <Button
                    type="button"
                    variant="outline"
                    size="icon"
                    className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary hover:bg-primary/10 hover:border-primary transition-all disabled:opacity-50"
                    title={
                      selectedFloorRole
                        ? "Add new RBAC Role"
                        : "Select On Floor Role first"
                    }
                    disabled={!selectedFloorRole}
                    onClick={() => {
                      setNewRbacRoleDisplayName("");
                      setAddRbacRoleError(null);
                      setShowAddRbacRoleModal(true);
                    }}
                  >
                    <Plus className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            </div>

            {/* Bottom Form Actions */}
            <div className="flex flex-wrap items-center justify-between gap-3 pt-1">
              <div className="flex items-center gap-2">
                {(selectedDepartment || selectedDesignation || selectedFloorRole || selectedRbacRole) && (
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={() => {
                      setSelectedDepartment("");
                      setSelectedDesignation("");
                      setSelectedFloorRole("");
                      setSelectedRbacRole("");
                      setFormError(null);
                    }}
                    className="h-8 text-xs text-muted-foreground hover:text-foreground"
                  >
                    <RotateCcw className="h-3 w-3 mr-1.5" />
                    Reset Selection
                  </Button>
                )}
              </div>

              <Button
                type="submit"
                size="sm"
                disabled={!canSubmit}
                className="h-8 gap-1.5 text-xs shadow-sm bg-primary hover:bg-primary/90 text-primary-foreground disabled:opacity-50"
              >
                <Plus className="h-3.5 w-3.5" />
                Add Hierarchy Mapping
              </Button>
            </div>
          </form>
        </div>
      )}

      {/* ══════════════════════════════════════════════════════════════════════ */}
      {/* Existing Mappings Table & Filter Section */}
      {/* ══════════════════════════════════════════════════════════════════════ */}
      <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden">
        {/* Table Subheader */}
        <div className="flex flex-col gap-3 border-b border-border p-4 sm:flex-row sm:items-center sm:justify-between bg-muted/20">
          <div>
            <h3 className="text-sm font-semibold text-foreground">
              Configured Department Hierarchy Mappings
            </h3>
            <p className="text-xs text-muted-foreground">
              {filteredItems.length} of {items.length} mapping{items.length === 1 ? "" : "s"} visible
            </p>
          </div>

          <div className="flex items-center gap-2">
            {canManage && (
              <Button
                size="sm"
                variant="outline"
                onClick={() => {
                  formRef.current?.scrollIntoView({ behavior: "smooth" });
                }}
                className="h-8 gap-1.5 text-xs shrink-0"
              >
                <Plus className="h-3.5 w-3.5" />
                Add New
              </Button>
            )}
          </div>
        </div>

        {/* Cascaded Filter Bar */}
        <div className="p-4 border-b border-border/80 bg-background/50 flex flex-wrap items-center gap-3">
          {/* Search */}
          <div className="relative flex-1 min-w-[200px]">
            <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground" />
            <Input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search department, designation, or role..."
              className="h-8 pl-8 text-xs bg-card"
            />
          </div>

          {/* Department Filter */}
          <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
            <span className="shrink-0 font-medium text-foreground">Dept:</span>
            <select
              value={selectedDeptFilter}
              onChange={(e) => {
                setSelectedDeptFilter(e.target.value);
                setSelectedDesigFilter("ALL");
              }}
              className="h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring max-w-[180px] truncate"
            >
              <option value="ALL">All Departments ({availableDepartments.length})</option>
              {availableDepartments.map((d) => (
                <option key={d} value={d}>
                  {d}
                </option>
              ))}
            </select>
          </div>

          {/* Designation Filter (Cascaded by Department) */}
          <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
            <span className="shrink-0 font-medium text-foreground">Designation:</span>
            <select
              value={selectedDesigFilter}
              onChange={(e) => setSelectedDesigFilter(e.target.value)}
              className="h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring max-w-[180px] truncate"
            >
              <option value="ALL">All Designations ({filterDesignations.length})</option>
              {filterDesignations.map((desig) => (
                <option key={desig} value={desig}>
                  {desig}
                </option>
              ))}
            </select>
          </div>

          {/* Floor Role Filter */}
          <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
            <span className="shrink-0 font-medium text-foreground">Floor Role:</span>
            <select
              value={selectedRoleFilter}
              onChange={(e) => setSelectedRoleFilter(e.target.value)}
              className="h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring max-w-[160px] truncate"
            >
              <option value="ALL">All Floor Roles ({filterFloorRoles.length})</option>
              {filterFloorRoles.map((r) => (
                <option key={r} value={r}>
                  {r}
                </option>
              ))}
            </select>
          </div>

          {(search || selectedDeptFilter !== "ALL" || selectedDesigFilter !== "ALL" || selectedRoleFilter !== "ALL") && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                setSearch("");
                setSelectedDeptFilter("ALL");
                setSelectedDesigFilter("ALL");
                setSelectedRoleFilter("ALL");
              }}
              className="h-8 px-2 text-xs text-muted-foreground hover:text-foreground"
            >
              <X className="h-3 w-3 mr-1" />
              Reset
            </Button>
          )}
        </div>

        {/* Table View */}
        <div className={cn("overflow-x-auto", isExpandedView ? "max-h-[600px]" : "max-h-[420px]")}>
          <table className="w-full text-left text-xs">
            <thead className="sticky top-0 z-10 border-b border-border bg-muted/40 font-medium text-muted-foreground backdrop-blur-sm">
              <tr>
                <th className="py-2.5 px-4 font-semibold">Department</th>
                <th className="py-2.5 px-4 font-semibold">Designation</th>
                <th className="py-2.5 px-4 font-semibold">On Floor Role</th>
                <th className="py-2.5 px-4 font-semibold">Assigned RBAC Role</th>
                {canManage && <th className="py-2.5 px-4 text-right font-semibold">Actions</th>}
              </tr>
            </thead>
            <tbody className="divide-y divide-border/60">
              {filteredItems.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-10 text-center text-muted-foreground">
                    No hierarchy mappings match the current filters.
                  </td>
                </tr>
              ) : (
                filteredItems.map((item) => (
                  <tr key={item.id} className="hover:bg-muted/30 transition-colors group">
                    <td className="py-2.5 px-4 font-medium text-foreground">
                      <span className="inline-flex items-center gap-1.5">
                        <Building2 className="h-3.5 w-3.5 text-muted-foreground shrink-0" />
                        {item.departmentName}
                      </span>
                    </td>
                    <td className="py-2.5 px-4 text-foreground/90 font-medium">
                      {item.designationName}
                    </td>
                    <td className="py-2.5 px-4">
                      <Badge variant="outline" className="text-[11px] font-medium bg-muted/40 border-border">
                        {item.onFloorRoleName}
                      </Badge>
                    </td>
                    <td className="py-2.5 px-4">
                      <span className="inline-flex items-center gap-1.5 font-medium text-primary bg-primary/10 border border-primary/20 px-2 py-0.5 rounded-md text-[11px]">
                        <ShieldCheck className="h-3 w-3 text-primary shrink-0" />
                        {item.assignedRbacRoleName}
                      </span>
                    </td>
                    {canManage && (
                      <td className="py-2.5 px-4 text-right">
                        <div className="flex items-center justify-end gap-1">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => openEdit(item)}
                            className="h-7 w-7 p-0 text-muted-foreground hover:text-foreground"
                            title="Edit hierarchy mapping"
                          >
                            <Pencil className="h-3.5 w-3.5" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => setDeleteId(item.id)}
                            className="h-7 w-7 p-0 text-muted-foreground hover:text-destructive"
                            title="Delete hierarchy mapping"
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                          </Button>
                        </div>
                      </td>
                    )}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* ══════════════════════════════════════════════════════════════════════ */}
      {/* Dedicated Add Modals (Level 1 to Level 4) */}
      {/* ══════════════════════════════════════════════════════════════════════ */}

      {/* Modal 1: Add Department */}
      <Dialog open={showAddDeptModal} onOpenChange={setShowAddDeptModal}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-base">
              <Building2 className="h-4 w-4 text-primary" />
              Add New Department
            </DialogTitle>
            <DialogDescription className="text-xs">
              Create a new operational or functional department in the resource hierarchy.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2 text-xs">
            {addDeptError && (
              <div className="flex items-center gap-2 rounded-lg bg-destructive/10 border border-destructive/20 p-2.5 text-destructive text-xs">
                <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                <span>{addDeptError}</span>
              </div>
            )}

            <div className="space-y-1.5">
              <Label htmlFor="new-dept-name" className="text-xs font-medium text-foreground">
                Department Name <span className="text-destructive">*</span>
              </Label>
              <Input
                id="new-dept-name"
                placeholder="e.g. Cloud Security, Core Operations, Legal"
                value={newDeptName}
                onChange={(e) => {
                  setNewDeptName(e.target.value);
                  setAddDeptError(null);
                }}
                className="h-9 text-xs"
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    handleCreateDepartment();
                  }
                }}
              />
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowAddDeptModal(false)}
              className="h-8 text-xs"
            >
              Cancel
            </Button>
            <Button size="sm" onClick={handleCreateDepartment} className="h-8 text-xs">
              Create & Select
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Modal 2: Add Designation (under selected Department) */}
      <Dialog open={showAddDesigModal} onOpenChange={setShowAddDesigModal}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-base">
              <Briefcase className="h-4 w-4 text-primary" />
              Add New Designation
            </DialogTitle>
            <DialogDescription className="text-xs">
              Define a job designation linked to the selected department.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2 text-xs">
            <div className="flex items-center gap-2 p-2 rounded-md bg-muted/50 border border-border text-xs">
              <span className="text-muted-foreground">Department:</span>
              <span className="font-semibold text-foreground">
                {selectedDepartment || editDepartment || "None"}
              </span>
            </div>

            {addDesigError && (
              <div className="flex items-center gap-2 rounded-lg bg-destructive/10 border border-destructive/20 p-2.5 text-destructive text-xs">
                <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                <span>{addDesigError}</span>
              </div>
            )}

            <div className="space-y-1.5">
              <Label htmlFor="new-desig-name" className="text-xs font-medium text-foreground">
                Designation Name <span className="text-destructive">*</span>
              </Label>
              <Input
                id="new-desig-name"
                placeholder="e.g. Lead Penetration Tester, DevOps Lead, PMO Specialist"
                value={newDesigName}
                onChange={(e) => {
                  setNewDesigName(e.target.value);
                  setAddDesigError(null);
                }}
                className="h-9 text-xs"
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    handleCreateDesignation();
                  }
                }}
              />
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowAddDesigModal(false)}
              className="h-8 text-xs"
            >
              Cancel
            </Button>
            <Button size="sm" onClick={handleCreateDesignation} className="h-8 text-xs">
              Create & Select
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Modal 3: Add On Floor Role (under selected Designation) */}
      <Dialog open={showAddFloorRoleModal} onOpenChange={setShowAddFloorRoleModal}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-base">
              <Users className="h-4 w-4 text-primary" />
              Add New On Floor Role
            </DialogTitle>
            <DialogDescription className="text-xs">
              Define an operational floor role for team scheduling and floor hierarchies.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2 text-xs">
            <div className="flex flex-col gap-1 p-2 rounded-md bg-muted/50 border border-border text-xs">
              <div className="flex items-center gap-2">
                <span className="text-muted-foreground">Department:</span>
                <span className="font-semibold text-foreground">
                  {selectedDepartment || editDepartment || "None"}
                </span>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-muted-foreground">Designation:</span>
                <span className="font-semibold text-foreground">
                  {selectedDesignation || editDesignation || "None"}
                </span>
              </div>
            </div>

            {addFloorRoleError && (
              <div className="flex items-center gap-2 rounded-lg bg-destructive/10 border border-destructive/20 p-2.5 text-destructive text-xs">
                <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                <span>{addFloorRoleError}</span>
              </div>
            )}

            <div className="space-y-1.5">
              <Label htmlFor="new-floor-role-name" className="text-xs font-medium text-foreground">
                On Floor Role Name <span className="text-destructive">*</span>
              </Label>
              <Input
                id="new-floor-role-name"
                placeholder="e.g. Associate Lead (AL), SME, Technical Specialist"
                value={newFloorRoleName}
                onChange={(e) => {
                  setNewFloorRoleName(e.target.value);
                  setAddFloorRoleError(null);
                }}
                className="h-9 text-xs"
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    handleCreateFloorRole();
                  }
                }}
              />
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowAddFloorRoleModal(false)}
              className="h-8 text-xs"
            >
              Cancel
            </Button>
            <Button size="sm" onClick={handleCreateFloorRole} className="h-8 text-xs">
              Create & Select
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Modal 4: Add RBAC Role */}
      <Dialog open={showAddRbacRoleModal} onOpenChange={setShowAddRbacRoleModal}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-base">
              <ShieldCheck className="h-4 w-4 text-primary" />
              Add New RBAC Role
            </DialogTitle>
            <DialogDescription className="text-xs">
              Create an RBAC system security role linked to this hierarchy node.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2 text-xs">
            {addRbacRoleError && (
              <div className="flex items-center gap-2 rounded-lg bg-destructive/10 border border-destructive/20 p-2.5 text-destructive text-xs">
                <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                <span>{addRbacRoleError}</span>
              </div>
            )}

            <div className="space-y-1.5">
              <Label htmlFor="new-rbac-disp" className="text-xs font-medium text-foreground">
                Role Display Name <span className="text-destructive">*</span>
              </Label>
              <Input
                id="new-rbac-disp"
                placeholder="e.g. Lead Consultant, Security Auditor"
                value={newRbacRoleDisplayName}
                onChange={(e) => {
                  setNewRbacRoleDisplayName(e.target.value);
                  setAddRbacRoleError(null);
                }}
                className="h-9 text-xs"
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    handleCreateRbacRole();
                  }
                }}
              />
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowAddRbacRoleModal(false)}
              className="h-8 text-xs"
            >
              Cancel
            </Button>
            <Button size="sm" onClick={handleCreateRbacRole} className="h-8 text-xs">
              Create & Assign
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ══════════════════════════════════════════════════════════════════════ */}
      {/* Dialog: Edit Hierarchy Mapping (Cascaded 4-Tier) */}
      {/* ══════════════════════════════════════════════════════════════════════ */}
      <Dialog open={!!editingItem} onOpenChange={(open) => !open && setEditingItem(null)}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-base">
              <Pencil className="h-4 w-4 text-primary" />
              Edit Department Hierarchy Mapping
            </DialogTitle>
            <DialogDescription className="text-xs">
              Update the four-tier mapping: Department ➔ Designation ➔ On Floor Role ➔ Assigned RBAC Role.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-2 text-xs">
            {editError && (
              <div className="flex items-center gap-2 rounded-lg bg-destructive/10 border border-destructive/20 p-2.5 text-destructive text-xs">
                <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                <span>{editError}</span>
              </div>
            )}

            {/* 1. Edit Department */}
            <div className="space-y-1.5">
              <div className="flex items-center justify-between">
                <Label className="text-xs font-medium text-foreground">
                  1. Department <span className="text-destructive">*</span>
                </Label>
              </div>
              <div className="flex items-center gap-1.5">
                <SearchableSelect
                  options={availableDepartments}
                  value={editDepartment}
                  onChange={(d) => {
                    setEditDepartment(d);
                    setEditDesignation("");
                    setEditFloorRole("");
                  }}
                  placeholder="Select Department"
                  searchPlaceholder="Search department..."
                  showSearch={true}
                  buttonClassName="h-9 text-xs bg-card border-border"
                  className="flex-1"
                  clearable={false}
                />
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary"
                  title="Add new Department"
                  onClick={() => {
                    setNewDeptName("");
                    setAddDeptError(null);
                    setShowAddDeptModal(true);
                  }}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
            </div>

            {/* 2. Edit Designation (Dependent on Edit Department) */}
            <div className="space-y-1.5">
              <div className="flex items-center justify-between">
                <Label className="text-xs font-medium text-foreground">
                  2. Designation <span className="text-destructive">*</span>
                </Label>
              </div>
              <div className="flex items-center gap-1.5">
                <SearchableSelect
                  options={editDesignationsForDept}
                  value={editDesignation}
                  onChange={(desig) => {
                    setEditDesignation(desig);
                    setEditFloorRole("");
                  }}
                  placeholder={editDepartment ? "Select Designation" : "Select Department first"}
                  searchPlaceholder="Search designation..."
                  showSearch={true}
                  disabled={!editDepartment}
                  disabledHint="Select Department first"
                  buttonClassName="h-9 text-xs bg-card border-border"
                  className="flex-1"
                  clearable={false}
                />
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary disabled:opacity-50"
                  title="Add new Designation"
                  disabled={!editDepartment}
                  onClick={() => {
                    setNewDesigName("");
                    setAddDesigError(null);
                    setShowAddDesigModal(true);
                  }}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
            </div>

            {/* 3. Edit On Floor Role (Dependent on Edit Designation) */}
            <div className="space-y-1.5">
              <div className="flex items-center justify-between">
                <Label className="text-xs font-medium text-foreground">
                  3. On Floor Role <span className="text-destructive">*</span>
                </Label>
              </div>
              <div className="flex items-center gap-1.5">
                <SearchableSelect
                  options={editFloorRolesForDesig}
                  value={editFloorRole}
                  onChange={setEditFloorRole}
                  placeholder={editDesignation ? "Select On Floor Role" : "Select Designation first"}
                  searchPlaceholder="Search on floor role..."
                  showSearch={true}
                  disabled={!editDesignation}
                  disabledHint="Select Designation first"
                  buttonClassName="h-9 text-xs bg-card border-border"
                  className="flex-1"
                  clearable={false}
                />
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary disabled:opacity-50"
                  title="Add new On Floor Role"
                  disabled={!editDesignation}
                  onClick={() => {
                    setNewFloorRoleName("");
                    setAddFloorRoleError(null);
                    setShowAddFloorRoleModal(true);
                  }}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
            </div>

            {/* 4. Edit Assigned RBAC Role */}
            <div className="space-y-1.5">
              <div className="flex items-center justify-between">
                <Label className="text-xs font-medium text-foreground">
                  4. Assigned RBAC Role <span className="text-destructive">*</span>
                </Label>
              </div>
              <div className="flex items-center gap-1.5">
                <SearchableSelect
                  options={rbacSelectOptions}
                  value={editRbacRole}
                  onChange={setEditRbacRole}
                  placeholder="Select Assigned RBAC Role"
                  searchPlaceholder="Search RBAC role..."
                  showSearch={true}
                  buttonClassName="h-9 text-xs bg-card border-border"
                  className="flex-1"
                  clearable={false}
                />
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary"
                  title="Add new RBAC Role"
                  onClick={() => {
                    setNewRbacRoleDisplayName("");
                    setAddRbacRoleError(null);
                    setShowAddRbacRoleModal(true);
                  }}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setEditingItem(null)}
              className="h-8 text-xs"
            >
              Cancel
            </Button>
            <Button size="sm" onClick={handleSaveEdit} className="h-8 text-xs">
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Confirm Delete Dialog ───────────────────────────────────────────── */}
      <AlertDialog open={!!deleteId} onOpenChange={(open) => !open && setDeleteId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="text-sm">Delete Hierarchy Mapping?</AlertDialogTitle>
            <AlertDialogDescription className="text-xs">
              Are you sure you want to remove this department-designation-role mapping? This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="h-8 text-xs">Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                if (deleteId) onDelete(deleteId);
                setDeleteId(null);
              }}
              className="h-8 text-xs bg-destructive hover:bg-destructive/90 text-destructive-foreground"
            >
              Delete Mapping
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 2. Work Email Domains Card
// ══════════════════════════════════════════════════════════════════════════════
function EmailDomainsCard({
  canManage = true,
  items,
  onAdd,
  onUpdate,
  onDelete,
  isExpandedView,
}: {
  canManage?: boolean;
  items: EmailDomainItem[];
  onAdd: (domain: string, extra?: { displayName?: string; code?: string }) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onUpdate: (id: string, domain: string, extra?: { displayName?: string; code?: string; isActive?: boolean }) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onDelete: (id: string) => Promise<void> | void;
  isExpandedView?: boolean;
}) {
  const [search, setSearch] = useState("");
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [editItem, setEditItem] = useState<EmailDomainItem | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  const [formDomain, setFormDomain] = useState("");
  const [formDisplayName, setFormDisplayName] = useState("");
  const [formError, setFormError] = useState<string | null>(null);

  const filtered = useMemo(() => {
    return items.filter(
      (item) =>
        !search ||
        item.domainName.toLowerCase().includes(search.toLowerCase()) ||
        item.displayName.toLowerCase().includes(search.toLowerCase()),
    );
  }, [items, search]);

  const openAdd = () => {
    setFormDomain("");
    setFormDisplayName("");
    setFormError(null);
    setIsAddOpen(true);
  };

  const openEdit = (item: EmailDomainItem) => {
    setEditItem(item);
    setFormDomain(item.domainName);
    setFormDisplayName(item.displayName);
    setFormError(null);
  };

  const handleSaveAdd = async () => {
    if (!formDomain.trim()) {
      setFormError("Domain name is required.");
      return;
    }
    const res = await onAdd(formDomain, { displayName: formDisplayName.trim() });
    if (!res.success) {
      setFormError(res.error || "Failed to add domain.");
    } else {
      setIsAddOpen(false);
    }
  };

  const handleSaveEdit = async () => {
    if (!editItem) return;
    if (!formDomain.trim()) {
      setFormError("Domain name is required.");
      return;
    }
    const res = await onUpdate(editItem.id, formDomain, { displayName: formDisplayName.trim() });
    if (!res.success) {
      setFormError(res.error || "Failed to update domain.");
    } else {
      setEditItem(null);
    }
  };

  return (
    <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden">
      <div className="flex flex-col gap-3 border-b border-border p-4 sm:flex-row sm:items-center sm:justify-between bg-muted/20">
        <div className="flex items-center gap-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
            <Mail className="h-4.5 w-4.5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="text-sm font-semibold text-foreground">2. Work Email Domain</h3>
              <Badge variant="secondary" className="text-[10px] bg-primary/10 text-primary">
                {items.length} Domains
              </Badge>
            </div>
            <p className="text-[11px] text-muted-foreground">Authorized corporate email domains for talent onboarding</p>
          </div>
        </div>

        {canManage && (
          <Button size="sm" onClick={openAdd} className="h-7 gap-1 text-xs shrink-0">
            <Plus className="h-3 w-3" />
            Add Domain
          </Button>
        )}
      </div>

      {/* Existing Dropdown & Search Bar */}
      <div className="p-3 border-b border-border/80 bg-background/50 flex items-center gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground" />
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search email domains..."
            className="h-7 pl-8 text-xs bg-card"
          />
        </div>

        {/* Existing Domains Dropdown Selector */}
        <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
          <span className="font-medium text-foreground shrink-0">Existing:</span>
          <select
            onChange={(e) => {
              const selected = items.find((i) => i.id === e.target.value);
              if (selected) openEdit(selected);
            }}
            value=""
            className="h-7 rounded-md border border-input bg-card px-2 text-xs text-foreground focus:outline-none"
          >
            <option value="">-- Choose to Edit ({items.length}) --</option>
            {items.map((d) => (
              <option key={d.id} value={d.id}>
                {d.displayName} ({d.domainName})
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Table */}
      <div className={cn("overflow-x-auto", isExpandedView ? "max-h-[500px]" : "max-h-[260px]")}>
        <table className="w-full text-left text-xs">
          <thead className="sticky top-0 z-10 border-b border-border bg-muted/40 font-medium text-muted-foreground backdrop-blur-sm">
            <tr>
              <th className="py-2 px-3 font-semibold">Domain Name</th>
              <th className="py-2 px-3 font-semibold">Display Format</th>
              <th className="py-2 px-3 font-semibold">Status</th>
              {canManage && <th className="py-2 px-3 text-right font-semibold">Actions</th>}
            </tr>
          </thead>
          <tbody className="divide-y divide-border/60">
            {filtered.map((item) => (
              <tr key={item.id} className="hover:bg-muted/30 transition-colors">
                <td className="py-2 px-3 font-medium text-foreground">{item.domainName}</td>
                <td className="py-2 px-3 text-muted-foreground">
                  <Badge variant="outline" className="text-[11px] bg-muted/30">
                    {item.displayName}
                  </Badge>
                </td>
                <td className="py-2 px-3">
                  <Badge
                    variant="secondary"
                    className={cn(
                      "text-[10px] px-1.5 py-0",
                      item.isActive
                        ? "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20"
                        : "bg-muted text-muted-foreground",
                    )}
                  >
                    {item.isActive ? "Active" : "Inactive"}
                  </Badge>
                </td>
                {canManage && (
                  <td className="py-2 px-3 text-right">
                    <div className="flex items-center justify-end gap-1">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openEdit(item)}
                        className="h-6 w-6 p-0 text-muted-foreground hover:text-foreground"
                      >
                        <Pencil className="h-3 w-3" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setDeleteId(item.id)}
                        className="h-6 w-6 p-0 text-muted-foreground hover:text-destructive"
                      >
                        <Trash2 className="h-3 w-3" />
                      </Button>
                    </div>
                  </td>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Add Dialog */}
      <Dialog open={isAddOpen} onOpenChange={setIsAddOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm">Add Work Email Domain</DialogTitle>
            <DialogDescription className="text-xs">
              Add a new corporate email domain (e.g. talakunchi.in, talakunchi.com).
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-3 py-2 text-xs">
            {formError && (
              <div className="rounded-lg bg-destructive/10 border border-destructive/20 p-2 text-destructive text-xs">
                {formError}
              </div>
            )}
            <div className="space-y-1">
              <label className="font-medium text-foreground">Domain Name (FQDN)</label>
              <Input
                value={formDomain}
                onChange={(e) => {
                  setFormDomain(e.target.value);
                  if (!formDisplayName) {
                    setFormDisplayName(e.target.value ? `@${e.target.value.toLowerCase().replace(/^@/, "")}` : "");
                  }
                }}
                placeholder="e.g. talakunchi.in"
                className="h-8 text-xs"
              />
            </div>
            <div className="space-y-1">
              <label className="font-medium text-foreground">Display Name / Prefix</label>
              <Input
                value={formDisplayName}
                onChange={(e) => setFormDisplayName(e.target.value)}
                placeholder="e.g. @talakunchi.in"
                className="h-8 text-xs"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" size="sm" onClick={() => setIsAddOpen(false)} className="h-7 text-xs">
              Cancel
            </Button>
            <Button size="sm" onClick={handleSaveAdd} className="h-7 text-xs">
              Add Domain
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Edit Dialog */}
      <Dialog open={!!editItem} onOpenChange={(open) => !open && setEditItem(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm">Edit Work Email Domain</DialogTitle>
            <DialogDescription className="text-xs">Update domain configuration.</DialogDescription>
          </DialogHeader>
          <div className="space-y-3 py-2 text-xs">
            {formError && (
              <div className="rounded-lg bg-destructive/10 border border-destructive/20 p-2 text-destructive text-xs">
                {formError}
              </div>
            )}
            <div className="space-y-1">
              <label className="font-medium text-foreground">Domain Name</label>
              <Input
                value={formDomain}
                onChange={(e) => setFormDomain(e.target.value)}
                className="h-8 text-xs"
              />
            </div>
            <div className="space-y-1">
              <label className="font-medium text-foreground">Display Name</label>
              <Input
                value={formDisplayName}
                onChange={(e) => setFormDisplayName(e.target.value)}
                className="h-8 text-xs"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" size="sm" onClick={() => setEditItem(null)} className="h-7 text-xs">
              Cancel
            </Button>
            <Button size="sm" onClick={handleSaveEdit} className="h-7 text-xs">
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Dialog */}
      <AlertDialog open={!!deleteId} onOpenChange={(open) => !open && setDeleteId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="text-sm">Delete Email Domain?</AlertDialogTitle>
            <AlertDialogDescription className="text-xs">
              Are you sure you want to remove this domain?
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="h-7 text-xs">Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                if (deleteId) onDelete(deleteId);
                setDeleteId(null);
              }}
              className="h-7 text-xs bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 3–7. Simple Master Card Component (Business Unit, Work Location, Grad, Post Grad, Certs)
// ══════════════════════════════════════════════════════════════════════════════
function SimpleMasterCard({
  canManage = true,
  categoryKey,
  title,
  singular,
  description,
  icon: Icon,
  placeholder,
  items,
  onAdd,
  onUpdate,
  onDelete,
  isExpandedView,
}: {
  canManage?: boolean;
  categoryKey: string;
  title: string;
  singular: string;
  description: string;
  icon: typeof Building2;
  placeholder: string;
  items: SimpleResourceMasterItem[];
  onAdd: (name: string, extra?: { code?: string; description?: string }) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onUpdate: (id: string, name: string, extra?: { code?: string; description?: string; isActive?: boolean }) => Promise<{ success: boolean; error?: string }> | { success: boolean; error?: string };
  onDelete: (id: string) => Promise<void> | void;
  isExpandedView?: boolean;
}) {
  const [search, setSearch] = useState("");
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [editItem, setEditItem] = useState<SimpleResourceMasterItem | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  const [formName, setFormName] = useState("");
  const [formCode, setFormCode] = useState("");
  const [formDesc, setFormDesc] = useState("");
  const [formError, setFormError] = useState<string | null>(null);

  const filtered = useMemo(() => {
    return items.filter(
      (item) =>
        !search ||
        item.name.toLowerCase().includes(search.toLowerCase()) ||
        (item.code && item.code.toLowerCase().includes(search.toLowerCase())) ||
        (item.description && item.description.toLowerCase().includes(search.toLowerCase())),
    );
  }, [items, search]);

  const openAdd = () => {
    setFormName("");
    setFormCode("");
    setFormDesc("");
    setFormError(null);
    setIsAddOpen(true);
  };

  const openEdit = (item: SimpleResourceMasterItem) => {
    setEditItem(item);
    setFormName(item.name);
    setFormCode(item.code || "");
    setFormDesc(item.description || "");
    setFormError(null);
  };

  const handleSaveAdd = async () => {
    if (!formName.trim()) {
      setFormError(`${singular} name is required.`);
      return;
    }
    const res = await onAdd(formName, {
      code: formCode.trim(),
      description: formDesc.trim(),
    });
    if (!res.success) {
      setFormError(res.error || `Failed to add ${singular.toLowerCase()}.`);
    } else {
      setIsAddOpen(false);
    }
  };

  const handleSaveEdit = async () => {
    if (!editItem) return;
    if (!formName.trim()) {
      setFormError(`${singular} name is required.`);
      return;
    }
    const res = await onUpdate(editItem.id, formName, {
      code: formCode.trim(),
      description: formDesc.trim(),
    });
    if (!res.success) {
      setFormError(res.error || `Failed to update ${singular.toLowerCase()}.`);
    } else {
      setEditItem(null);
    }
  };

  return (
    <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden">
      <div className="flex flex-col gap-3 border-b border-border p-4 sm:flex-row sm:items-center sm:justify-between bg-muted/20">
        <div className="flex items-center gap-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
            <Icon className="h-4.5 w-4.5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="text-sm font-semibold text-foreground">{title}</h3>
              <Badge variant="secondary" className="text-[10px] bg-primary/10 text-primary">
                {items.length}
              </Badge>
            </div>
            <p className="text-[11px] text-muted-foreground">{description}</p>
          </div>
        </div>

        {canManage && (
          <Button size="sm" onClick={openAdd} className="h-7 gap-1 text-xs shrink-0">
            <Plus className="h-3 w-3" />
            Add {singular}
          </Button>
        )}
      </div>

      {/* Existing Dropdown & Search Bar */}
      <div className="p-3 border-b border-border/80 bg-background/50 flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[170px]">
          <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground" />
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={`Search ${title.toLowerCase()}...`}
            className="h-7 pl-8 text-xs bg-card"
          />
        </div>

        {/* Existing Dropdown Selector */}
        <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
          <span className="font-medium text-foreground shrink-0">Existing {title}:</span>
          <select
            onChange={(e) => {
              const selected = items.find((i) => i.id === e.target.value);
              if (selected) openEdit(selected);
            }}
            value=""
            className="h-7 rounded-md border border-input bg-card px-2 text-xs text-foreground focus:outline-none max-w-[200px]"
          >
            <option value="">-- Choose to Edit ({items.length}) --</option>
            {items.map((i) => (
              <option key={i.id} value={i.id}>
                {i.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Table */}
      <div className={cn("overflow-x-auto", isExpandedView ? "max-h-[500px]" : "max-h-[260px]")}>
        <table className="w-full text-left text-xs">
          <thead className="sticky top-0 z-10 border-b border-border bg-muted/40 font-medium text-muted-foreground backdrop-blur-sm">
            <tr>
              <th className="py-2 px-3 font-semibold">Name</th>
              <th className="py-2 px-3 font-semibold">Code / Key</th>
              {canManage && <th className="py-2 px-3 text-right font-semibold">Actions</th>}
            </tr>
          </thead>
          <tbody className="divide-y divide-border/60">
            {filtered.map((item) => (
              <tr key={item.id} className="hover:bg-muted/30 transition-colors">
                <td className="py-2 px-3 font-medium text-foreground">{item.name}</td>
                <td className="py-2 px-3 text-muted-foreground font-mono text-[11px]">{item.code || "—"}</td>
                {canManage && (
                  <td className="py-2 px-3 text-right">
                    <div className="flex items-center justify-end gap-1">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openEdit(item)}
                        className="h-6 w-6 p-0 text-muted-foreground hover:text-foreground"
                      >
                        <Pencil className="h-3 w-3" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setDeleteId(item.id)}
                        className="h-6 w-6 p-0 text-muted-foreground hover:text-destructive"
                      >
                        <Trash2 className="h-3 w-3" />
                      </Button>
                    </div>
                  </td>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Add Dialog */}
      <Dialog open={isAddOpen} onOpenChange={setIsAddOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm flex items-center gap-2">
              <Icon className="h-4 w-4 text-primary" />
              Add {singular}
            </DialogTitle>
            <DialogDescription className="text-xs">
              Add a new standard entry to {title.toLowerCase()}.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-3 py-2 text-xs">
            {formError && (
              <div className="rounded-lg bg-destructive/10 border border-destructive/20 p-2 text-destructive text-xs">
                {formError}
              </div>
            )}
            <div className="space-y-1">
              <label className="font-medium text-foreground">
                {singular} Name <span className="text-destructive">*</span>
              </label>
              <Input
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder={placeholder}
                className="h-8 text-xs"
                autoFocus
              />
            </div>
            <div className="space-y-1">
              <label className="font-medium text-foreground">Code / Key (Optional)</label>
              <Input
                value={formCode}
                onChange={(e) => setFormCode(e.target.value)}
                placeholder="e.g. btech, cisp, bu_01"
                className="h-8 text-xs font-mono"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" size="sm" onClick={() => setIsAddOpen(false)} className="h-7 text-xs">
              Cancel
            </Button>
            <Button size="sm" onClick={handleSaveAdd} className="h-7 text-xs">
              Add {singular}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Edit Dialog */}
      <Dialog open={!!editItem} onOpenChange={(open) => !open && setEditItem(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm flex items-center gap-2">
              <Pencil className="h-4 w-4 text-primary" />
              Edit {singular}
            </DialogTitle>
            <DialogDescription className="text-xs">Update existing {singular.toLowerCase()} entry.</DialogDescription>
          </DialogHeader>
          <div className="space-y-3 py-2 text-xs">
            {formError && (
              <div className="rounded-lg bg-destructive/10 border border-destructive/20 p-2 text-destructive text-xs">
                {formError}
              </div>
            )}
            <div className="space-y-1">
              <label className="font-medium text-foreground">
                {singular} Name <span className="text-destructive">*</span>
              </label>
              <Input
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                className="h-8 text-xs"
              />
            </div>
            <div className="space-y-1">
              <label className="font-medium text-foreground">Code / Key</label>
              <Input
                value={formCode}
                onChange={(e) => setFormCode(e.target.value)}
                className="h-8 text-xs font-mono"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" size="sm" onClick={() => setEditItem(null)} className="h-7 text-xs">
              Cancel
            </Button>
            <Button size="sm" onClick={handleSaveEdit} className="h-7 text-xs">
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Dialog */}
      <AlertDialog open={!!deleteId} onOpenChange={(open) => !open && setDeleteId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="text-sm">Delete {singular}?</AlertDialogTitle>
            <AlertDialogDescription className="text-xs">
              Are you sure you want to remove this {singular.toLowerCase()} from the master list?
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="h-7 text-xs">Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                if (deleteId) onDelete(deleteId);
                setDeleteId(null);
              }}
              className="h-7 text-xs bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
