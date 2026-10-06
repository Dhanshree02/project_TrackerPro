import { useState, useMemo, useRef, useEffect } from "react";
import {
  Users,
  Building2,
  Network,
  Mail,
  MapPin,
  IdCard,
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
  Train,
  Hash,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
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
  CityMasterItem,
  TkIdFormatItem,
  TkIdMasterItem,
  SimpleResourceMasterItem,
} from "@/lib/masters/types";
import {
  MASTER_DEPARTMENTS_LIST,
  MASTER_ON_FLOOR_ROLES_LIST,
  MASTER_ALL_RBAC_ROLES,
  MASTER_RAILWAY_LINES_LIST,
} from "@/lib/masters/resource-mock-data";

export interface ResourceMastersSectionProps {
  canManage?: boolean;
  resourceMasters: ResourceMastersState;
  onAddHierarchy: (item: Omit<DepartmentHierarchyItem, "id" | "createdAt">) => { success: boolean; error?: string };
  onUpdateHierarchy: (id: string, item: Partial<Omit<DepartmentHierarchyItem, "id" | "createdAt">>) => { success: boolean; error?: string };
  onDeleteHierarchy: (id: string) => void;

  onAddEmailDomain: (domain: string, extra?: { displayName?: string; code?: string }) => { success: boolean; error?: string };
  onUpdateEmailDomain: (id: string, domain: string, extra?: { displayName?: string; code?: string; isActive?: boolean }) => { success: boolean; error?: string };
  onDeleteEmailDomain: (id: string) => void;

  onAddCity: (name: string, extra?: { line?: string; code?: string; stationName?: string }) => { success: boolean; error?: string };
  onUpdateCity: (id: string, name: string, extra?: { line?: string; code?: string; stationName?: string; isActive?: boolean }) => { success: boolean; error?: string };
  onDeleteCity: (id: string) => void;

  onAddTkIdFormat?: (item: Omit<TkIdFormatItem, "id" | "createdAt" | "sampleFormat">) => { success: boolean; error?: string };
  onUpdateTkIdFormat?: (id: string, item: Partial<Omit<TkIdFormatItem, "id" | "createdAt">>) => { success: boolean; error?: string };
  onDeleteTkIdFormat?: (id: string) => void;

  onAddTkId?: (code: string, extra?: { prefix?: string; assignedTo?: string; status?: "Assigned" | "Available" | "Reserved" }) => { success: boolean; error?: string };
  onUpdateTkId?: (id: string, code: string, extra?: { prefix?: string; assignedTo?: string; status?: "Assigned" | "Available" | "Reserved" }) => { success: boolean; error?: string };
  onDeleteTkId?: (id: string) => void;

  onAddSimpleItem: (category: "businessUnits" | "workLocations" | "graduationDegrees" | "postGraduationDegrees" | "certifications", name: string, extra?: { code?: string; description?: string }) => { success: boolean; error?: string };
  onUpdateSimpleItem: (category: "businessUnits" | "workLocations" | "graduationDegrees" | "postGraduationDegrees" | "certifications", id: string, name: string, extra?: { code?: string; description?: string; isActive?: boolean }) => { success: boolean; error?: string };
  onDeleteSimpleItem: (category: "businessUnits" | "workLocations" | "graduationDegrees" | "postGraduationDegrees" | "certifications", id: string) => void;
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
  onAddCity,
  onUpdateCity,
  onDeleteCity,
  onAddTkIdFormat,
  onUpdateTkIdFormat,
  onDeleteTkIdFormat,
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
        id: "cities",
        title: "Current Address – City",
        shortTitle: "Current Address - City",
        icon: MapPin,
        count: resourceMasters.cities.length,
        description: "Mumbai suburban railway stations & corridors (Western, Central, Harbour & Trans-Harbour)",
      },
      {
        id: "tkIds",
        title: "TK ID Format Master",
        shortTitle: "TK ID Formats",
        icon: IdCard,
        count: resourceMasters.tkIdFormats?.length || 3,
        description: "Employee ID prefix configurations (TK for full-time staff, TKI for interns)",
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
          <span>All 9 Masters Overview</span>
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

            <CitiesCard
              canManage={canManage}
              items={resourceMasters.cities}
              onAdd={onAddCity}
              onUpdate={onUpdateCity}
              onDelete={onDeleteCity}
            />

            <TkIdFormatsCard
              canManage={canManage}
              formats={resourceMasters.tkIdFormats || []}
              onAdd={onAddTkIdFormat || (() => ({ success: true }))}
              onUpdate={onUpdateTkIdFormat || (() => ({ success: true }))}
              onDelete={onDeleteTkIdFormat || (() => {})}
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
      ) : activeCategory === "cities" ? (
        <CitiesCard
          canManage={canManage}
          items={resourceMasters.cities}
          onAdd={onAddCity}
          onUpdate={onUpdateCity}
          onDelete={onDeleteCity}
          isExpandedView
        />
      ) : activeCategory === "tkIds" ? (
        <TkIdFormatsCard
          canManage={canManage}
          formats={resourceMasters.tkIdFormats || []}
          onAdd={onAddTkIdFormat || (() => ({ success: true }))}
          onUpdate={onUpdateTkIdFormat || (() => ({ success: true }))}
          onDelete={onDeleteTkIdFormat || (() => {})}
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
  onAdd: (item: Omit<DepartmentHierarchyItem, "id" | "createdAt">) => { success: boolean; error?: string };
  onUpdate: (id: string, item: Partial<Omit<DepartmentHierarchyItem, "id" | "createdAt">>) => { success: boolean; error?: string };
  onDelete: (id: string) => void;
  isExpandedView?: boolean;
}) {
  const [search, setSearch] = useState("");
  const [selectedDeptFilter, setSelectedDeptFilter] = useState<string>("ALL");
  const [selectedRoleFilter, setSelectedRoleFilter] = useState<string>("ALL");
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [editItem, setEditItem] = useState<DepartmentHierarchyItem | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  // Form states for Add/Edit
  const [formDept, setFormDept] = useState("");
  const [formCustomDept, setFormCustomDept] = useState("");
  const [formDesig, setFormDesig] = useState("");
  const [formFloorRole, setFormFloorRole] = useState("");
  const [formRbacRole, setFormRbacRole] = useState("");
  const [formError, setFormError] = useState<string | null>(null);

  const existingDepartments = useMemo(() => {
    const set = new Set<string>();
    MASTER_DEPARTMENTS_LIST.forEach((d) => set.add(d));
    items.forEach((i) => {
      if (i.departmentName) set.add(i.departmentName);
    });
    return Array.from(set).sort();
  }, [items]);

  const existingDesignationsForDept = useMemo(() => {
    const dept = formDept === "__custom__" ? formCustomDept : formDept;
    if (!dept) return [];
    const set = new Set<string>();
    items
      .filter((i) => i.departmentName.toLowerCase() === dept.toLowerCase())
      .forEach((i) => {
        if (i.designationName) set.add(i.designationName);
      });
    return Array.from(set).sort();
  }, [items, formDept, formCustomDept]);

  const existingFloorRoles = useMemo(() => {
    const set = new Set<string>();
    MASTER_ON_FLOOR_ROLES_LIST.forEach((r) => set.add(r));
    items.forEach((i) => {
      if (i.onFloorRoleName) set.add(i.onFloorRoleName);
    });
    return Array.from(set).sort();
  }, [items]);

  const filteredItems = useMemo(() => {
    return items.filter((item) => {
      const matchSearch =
        !search ||
        item.departmentName.toLowerCase().includes(search.toLowerCase()) ||
        item.designationName.toLowerCase().includes(search.toLowerCase()) ||
        item.onFloorRoleName.toLowerCase().includes(search.toLowerCase()) ||
        item.assignedRbacRoleName.toLowerCase().includes(search.toLowerCase());

      const matchDept = selectedDeptFilter === "ALL" || item.departmentName === selectedDeptFilter;
      const matchRole = selectedRoleFilter === "ALL" || item.onFloorRoleName === selectedRoleFilter;

      return matchSearch && matchDept && matchRole;
    });
  }, [items, search, selectedDeptFilter, selectedRoleFilter]);

  const openAdd = () => {
    setFormDept(existingDepartments[0] || "");
    setFormCustomDept("");
    setFormDesig("");
    setFormFloorRole(existingFloorRoles[0] || "Team Member (TM)");
    setFormRbacRole(MASTER_ALL_RBAC_ROLES[0]?.displayName || "Admin");
    setFormError(null);
    setIsAddOpen(true);
  };

  const openEdit = (item: DepartmentHierarchyItem) => {
    setEditItem(item);
    setFormDept(item.departmentName);
    setFormCustomDept("");
    setFormDesig(item.designationName);
    setFormFloorRole(item.onFloorRoleName);
    setFormRbacRole(item.assignedRbacRoleName);
    setFormError(null);
  };

  const handleSaveAdd = () => {
    const finalDept = formDept === "__custom__" ? formCustomDept.trim() : formDept.trim();
    if (!finalDept) {
      setFormError("Please select or enter a Department.");
      return;
    }
    if (!formDesig.trim()) {
      setFormError("Please enter or select a Designation.");
      return;
    }
    if (!formFloorRole.trim()) {
      setFormError("Please select an On Floor Role.");
      return;
    }
    if (!formRbacRole.trim()) {
      setFormError("Please select an Assigned RBAC Role.");
      return;
    }

    const rbacMeta = MASTER_ALL_RBAC_ROLES.find((r) => r.displayName === formRbacRole);

    const res = onAdd({
      departmentName: finalDept,
      designationName: formDesig.trim(),
      onFloorRoleName: formFloorRole.trim(),
      assignedRbacRoleName: formRbacRole.trim(),
      assignedRbacRoleId: rbacMeta?.id,
      assignedRbacRoleCode: rbacMeta?.name,
      isActive: true,
    });

    if (!res.success) {
      setFormError(res.error || "Failed to add hierarchy mapping.");
    } else {
      setIsAddOpen(false);
    }
  };

  const handleSaveEdit = () => {
    if (!editItem) return;
    const finalDept = formDept === "__custom__" ? formCustomDept.trim() : formDept.trim();
    if (!finalDept || !formDesig.trim() || !formFloorRole.trim() || !formRbacRole.trim()) {
      setFormError("All hierarchy fields are required.");
      return;
    }

    const rbacMeta = MASTER_ALL_RBAC_ROLES.find((r) => r.displayName === formRbacRole);

    const res = onUpdate(editItem.id, {
      departmentName: finalDept,
      designationName: formDesig.trim(),
      onFloorRoleName: formFloorRole.trim(),
      assignedRbacRoleName: formRbacRole.trim(),
      assignedRbacRoleId: rbacMeta?.id,
      assignedRbacRoleCode: rbacMeta?.name,
    });

    if (!res.success) {
      setFormError(res.error || "Failed to update hierarchy mapping.");
    } else {
      setEditItem(null);
    }
  };

  return (
    <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden">
      {/* ── Card Header ── */}
      <div className="flex flex-col gap-4 border-b border-border p-5 sm:flex-row sm:items-center sm:justify-between bg-muted/20">
        <div className="flex items-start gap-3">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
            <Network className="h-5 w-5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="text-sm font-semibold text-foreground">
                1. Department → Designation → On Floor Role → Assigned RBAC Role
              </h3>
              <Badge variant="secondary" className="text-[11px] font-medium bg-primary/10 text-primary">
                {items.length} Mappings
              </Badge>
            </div>
            <p className="mt-0.5 text-xs text-muted-foreground">
              Core dependent hierarchy linking organizational departments to designations, operational floor ranks, and system RBAC privileges.
            </p>
          </div>
        </div>

        {canManage && (
          <Button size="sm" onClick={openAdd} className="h-8 gap-1.5 text-xs shrink-0 shadow-sm">
            <Plus className="h-3.5 w-3.5" />
            Add Hierarchy Mapping
          </Button>
        )}
      </div>

      {/* ── Filters & Existing Data Dropdown Bar ── */}
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

        {/* Existing Department Dropdown Filter */}
        <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
          <span className="shrink-0 font-medium text-foreground">Dept:</span>
          <select
            value={selectedDeptFilter}
            onChange={(e) => setSelectedDeptFilter(e.target.value)}
            className="h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
          >
            <option value="ALL">All Departments ({existingDepartments.length})</option>
            {existingDepartments.map((d) => (
              <option key={d} value={d}>
                {d}
              </option>
            ))}
          </select>
        </div>

        {/* Existing Floor Role Dropdown Filter */}
        <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
          <span className="shrink-0 font-medium text-foreground">Floor Role:</span>
          <select
            value={selectedRoleFilter}
            onChange={(e) => setSelectedRoleFilter(e.target.value)}
            className="h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
          >
            <option value="ALL">All Floor Roles ({existingFloorRoles.length})</option>
            {existingFloorRoles.map((r) => (
              <option key={r} value={r}>
                {r}
              </option>
            ))}
          </select>
        </div>

        {(search || selectedDeptFilter !== "ALL" || selectedRoleFilter !== "ALL") && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {
              setSearch("");
              setSelectedDeptFilter("ALL");
              setSelectedRoleFilter("ALL");
            }}
            className="h-8 px-2 text-xs text-muted-foreground hover:text-foreground"
          >
            <X className="h-3 w-3 mr-1" />
            Reset
          </Button>
        )}
      </div>

      {/* ── Table View ── */}
      <div className={cn("overflow-x-auto", isExpandedView ? "max-h-[600px]" : "max-h-[380px]")}>
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
                <td colSpan={5} className="py-8 text-center text-muted-foreground">
                  No hierarchy mappings match the current filters.
                </td>
              </tr>
            ) : (
              filteredItems.map((item) => (
                <tr key={item.id} className="hover:bg-muted/30 transition-colors group">
                  <td className="py-2 px-4 font-medium text-foreground">
                    <span className="inline-flex items-center gap-1.5">
                      <Building2 className="h-3.5 w-3.5 text-muted-foreground shrink-0" />
                      {item.departmentName}
                    </span>
                  </td>
                  <td className="py-2 px-4 text-foreground/90 font-medium">
                    {item.designationName}
                  </td>
                  <td className="py-2 px-4">
                    <Badge variant="outline" className="text-[11px] font-medium bg-muted/40 border-border">
                      {item.onFloorRoleName}
                    </Badge>
                  </td>
                  <td className="py-2 px-4">
                    <span className="inline-flex items-center gap-1.5 font-medium text-primary bg-primary/10 border border-primary/20 px-2 py-0.5 rounded-md text-[11px]">
                      <ShieldCheck className="h-3 w-3 text-primary shrink-0" />
                      {item.assignedRbacRoleName}
                    </span>
                  </td>
                  {canManage && (
                    <td className="py-2 px-4 text-right">
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

      {/* ── Dialog: Add Hierarchy Mapping ── */}
      <Dialog open={isAddOpen} onOpenChange={setIsAddOpen}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-base">
              <Network className="h-4 w-4 text-primary" />
              Add Department Hierarchy Mapping
            </DialogTitle>
            <DialogDescription className="text-xs">
              Link a Department to a Designation, On Floor Role, and its Assigned RBAC Role.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-2 text-xs">
            {formError && (
              <div className="rounded-lg bg-destructive/10 border border-destructive/20 p-2.5 text-destructive text-xs">
                {formError}
              </div>
            )}

            {/* 1. Department Dropdown */}
            <div className="space-y-1.5">
              <label className="font-medium text-foreground">
                1. Department <span className="text-destructive">*</span>
              </label>
              <select
                value={formDept}
                onChange={(e) => setFormDept(e.target.value)}
                className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
              >
                {existingDepartments.map((d) => (
                  <option key={d} value={d}>
                    {d}
                  </option>
                ))}
                <option value="__custom__">+ Add New Department...</option>
              </select>
              {formDept === "__custom__" && (
                <Input
                  value={formCustomDept}
                  onChange={(e) => setFormCustomDept(e.target.value)}
                  placeholder="Enter new department name..."
                  className="h-8 text-xs mt-1.5"
                  autoFocus
                />
              )}
            </div>

            {/* 2. Designation Dropdown / Entry */}
            <div className="space-y-1.5">
              <label className="font-medium text-foreground">
                2. Designation Name <span className="text-destructive">*</span>
              </label>
              {existingDesignationsForDept.length > 0 && (
                <div className="mb-1 text-[11px] text-muted-foreground flex items-center gap-1.5">
                  <span>Quick pick existing:</span>
                  <select
                    value=""
                    onChange={(e) => {
                      if (e.target.value) setFormDesig(e.target.value);
                    }}
                    className="h-6 rounded border border-input bg-muted/40 px-2 text-[11px] text-foreground"
                  >
                    <option value="">-- Choose from {existingDesignationsForDept.length} in this Dept --</option>
                    {existingDesignationsForDept.map((des) => (
                      <option key={des} value={des}>
                        {des}
                      </option>
                    ))}
                  </select>
                </div>
              )}
              <Input
                value={formDesig}
                onChange={(e) => setFormDesig(e.target.value)}
                placeholder="e.g. Senior Security Analyst, Project Manager, Accountant - I"
                className="h-8 text-xs"
              />
            </div>

            {/* 3. On Floor Role Dropdown */}
            <div className="space-y-1.5">
              <label className="font-medium text-foreground">
                3. On Floor Role <span className="text-destructive">*</span>
              </label>
              <select
                value={formFloorRole}
                onChange={(e) => setFormFloorRole(e.target.value)}
                className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
              >
                {existingFloorRoles.map((r) => (
                  <option key={r} value={r}>
                    {r}
                  </option>
                ))}
              </select>
            </div>

            {/* 4. Assigned RBAC Role Dropdown */}
            <div className="space-y-1.5">
              <label className="font-medium text-foreground">
                4. Assigned RBAC Role <span className="text-destructive">*</span>
              </label>
              <select
                value={formRbacRole}
                onChange={(e) => setFormRbacRole(e.target.value)}
                className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
              >
                {MASTER_ALL_RBAC_ROLES.map((role) => (
                  <option key={role.id} value={role.displayName}>
                    {role.displayName} ({role.name})
                  </option>
                ))}
              </select>
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button variant="outline" size="sm" onClick={() => setIsAddOpen(false)} className="h-8 text-xs">
              Cancel
            </Button>
            <Button size="sm" onClick={handleSaveAdd} className="h-8 text-xs">
              Add Mapping
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Dialog: Edit Hierarchy Mapping ── */}
      <Dialog open={!!editItem} onOpenChange={(open) => !open && setEditItem(null)}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-base">
              <Pencil className="h-4 w-4 text-primary" />
              Edit Department Hierarchy Mapping
            </DialogTitle>
            <DialogDescription className="text-xs">
              Update the department, designation, on-floor operational role, or RBAC role link.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-2 text-xs">
            {formError && (
              <div className="rounded-lg bg-destructive/10 border border-destructive/20 p-2.5 text-destructive text-xs">
                {formError}
              </div>
            )}

            {/* Department */}
            <div className="space-y-1.5">
              <label className="font-medium text-foreground">1. Department</label>
              <select
                value={formDept}
                onChange={(e) => setFormDept(e.target.value)}
                className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
              >
                {existingDepartments.map((d) => (
                  <option key={d} value={d}>
                    {d}
                  </option>
                ))}
                <option value="__custom__">+ Add Custom Department...</option>
              </select>
              {formDept === "__custom__" && (
                <Input
                  value={formCustomDept}
                  onChange={(e) => setFormCustomDept(e.target.value)}
                  placeholder="Enter new department name..."
                  className="h-8 text-xs mt-1.5"
                />
              )}
            </div>

            {/* Designation */}
            <div className="space-y-1.5">
              <label className="font-medium text-foreground">2. Designation Name</label>
              {existingDesignationsForDept.length > 0 && (
                <div className="mb-1 text-[11px] text-muted-foreground flex items-center gap-1.5">
                  <span>Pick existing:</span>
                  <select
                    value=""
                    onChange={(e) => {
                      if (e.target.value) setFormDesig(e.target.value);
                    }}
                    className="h-6 rounded border border-input bg-muted/40 px-2 text-[11px] text-foreground"
                  >
                    <option value="">-- Choose from {existingDesignationsForDept.length} in this Dept --</option>
                    {existingDesignationsForDept.map((des) => (
                      <option key={des} value={des}>
                        {des}
                      </option>
                    ))}
                  </select>
                </div>
              )}
              <Input
                value={formDesig}
                onChange={(e) => setFormDesig(e.target.value)}
                className="h-8 text-xs"
              />
            </div>

            {/* On Floor Role */}
            <div className="space-y-1.5">
              <label className="font-medium text-foreground">3. On Floor Role</label>
              <select
                value={formFloorRole}
                onChange={(e) => setFormFloorRole(e.target.value)}
                className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
              >
                {existingFloorRoles.map((r) => (
                  <option key={r} value={r}>
                    {r}
                  </option>
                ))}
              </select>
            </div>

            {/* Assigned RBAC Role */}
            <div className="space-y-1.5">
              <label className="font-medium text-foreground">4. Assigned RBAC Role</label>
              <select
                value={formRbacRole}
                onChange={(e) => setFormRbacRole(e.target.value)}
                className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
              >
                {MASTER_ALL_RBAC_ROLES.map((role) => (
                  <option key={role.id} value={role.displayName}>
                    {role.displayName} ({role.name})
                  </option>
                ))}
              </select>
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button variant="outline" size="sm" onClick={() => setEditItem(null)} className="h-8 text-xs">
              Cancel
            </Button>
            <Button size="sm" onClick={handleSaveEdit} className="h-8 text-xs">
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Confirm Delete ── */}
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
  onAdd: (domain: string, extra?: { displayName?: string; code?: string }) => { success: boolean; error?: string };
  onUpdate: (id: string, domain: string, extra?: { displayName?: string; code?: string; isActive?: boolean }) => { success: boolean; error?: string };
  onDelete: (id: string) => void;
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

  const handleSaveAdd = () => {
    if (!formDomain.trim()) {
      setFormError("Domain name is required.");
      return;
    }
    const res = onAdd(formDomain, { displayName: formDisplayName.trim() });
    if (!res.success) {
      setFormError(res.error || "Failed to add domain.");
    } else {
      setIsAddOpen(false);
    }
  };

  const handleSaveEdit = () => {
    if (!editItem) return;
    if (!formDomain.trim()) {
      setFormError("Domain name is required.");
      return;
    }
    const res = onUpdate(editItem.id, formDomain, { displayName: formDisplayName.trim() });
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
// 3. Current Address – City Card (Matches Attached Image with Custom Searchable Dropdown)
// ══════════════════════════════════════════════════════════════════════════════
function CitiesCard({
  canManage = true,
  items,
  onAdd,
  onUpdate,
  onDelete,
  isExpandedView,
}: {
  canManage?: boolean;
  items: CityMasterItem[];
  onAdd: (name: string, extra?: { line?: string; code?: string; stationName?: string }) => { success: boolean; error?: string };
  onUpdate: (id: string, name: string, extra?: { line?: string; code?: string; stationName?: string; isActive?: boolean }) => { success: boolean; error?: string };
  onDelete: (id: string) => void;
  isExpandedView?: boolean;
}) {
  const [selectedStationId, setSelectedStationId] = useState<string>("stn-16"); // Defaults to Andheri
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [dropdownSearch, setDropdownSearch] = useState("");
  const dropdownRef = useRef<HTMLDivElement>(null);

  const [tableSearch, setTableSearch] = useState("");
  const [selectedLineFilter, setSelectedLineFilter] = useState<string>("ALL");
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [editItem, setEditItem] = useState<CityMasterItem | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  const [formCityName, setFormCityName] = useState("");
  const [formLine, setFormLine] = useState("Western Line");
  const [formStationCode, setFormStationCode] = useState("");
  const [formError, setFormError] = useState<string | null>(null);

  // Close custom dropdown on outside click
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const selectedStation = useMemo(() => {
    return items.find((i) => i.id === selectedStationId) || items[0] || null;
  }, [items, selectedStationId]);

  // Filter for the custom dropdown (as in the screenshot)
  const dropdownFilteredStations = useMemo(() => {
    if (!dropdownSearch.trim()) return items;
    const q = dropdownSearch.toLowerCase();
    return items.filter(
      (s) =>
        s.name.toLowerCase().includes(q) ||
        (s.line && s.line.toLowerCase().includes(q)) ||
        (s.value && s.value.toLowerCase().includes(q)),
    );
  }, [items, dropdownSearch]);

  // Filter for table view
  const tableFilteredStations = useMemo(() => {
    return items.filter((item) => {
      const matchSearch =
        !tableSearch ||
        item.name.toLowerCase().includes(tableSearch.toLowerCase()) ||
        (item.line && item.line.toLowerCase().includes(tableSearch.toLowerCase())) ||
        (item.stationName && item.stationName.toLowerCase().includes(tableSearch.toLowerCase()));

      const matchLine = selectedLineFilter === "ALL" || item.line === selectedLineFilter;
      return matchSearch && matchLine;
    });
  }, [items, tableSearch, selectedLineFilter]);

  const openAdd = () => {
    setFormCityName("");
    setFormLine("Western Line");
    setFormStationCode("");
    setFormError(null);
    setIsAddOpen(true);
  };

  const openEdit = (item: CityMasterItem) => {
    setEditItem(item);
    setFormCityName(item.name);
    setFormLine(item.line || "Western Line");
    setFormStationCode(item.stationName || item.code || "");
    setFormError(null);
  };

  const handleSaveAdd = () => {
    if (!formCityName.trim()) {
      setFormError("City / Station name is required.");
      return;
    }
    const res = onAdd(formCityName, {
      line: formLine,
      stationName: formStationCode.trim() || formCityName.trim(),
      code: formCityName.toLowerCase().replace(/\s+/g, "_"),
    });
    if (!res.success) {
      setFormError(res.error || "Failed to add station / city.");
    } else {
      setIsAddOpen(false);
    }
  };

  const handleSaveEdit = () => {
    if (!editItem) return;
    if (!formCityName.trim()) {
      setFormError("City / Station name is required.");
      return;
    }
    const res = onUpdate(editItem.id, formCityName, {
      line: formLine,
      stationName: formStationCode.trim() || formCityName.trim(),
      code: formCityName.toLowerCase().replace(/\s+/g, "_"),
    });
    if (!res.success) {
      setFormError(res.error || "Failed to update station / city.");
    } else {
      setEditItem(null);
    }
  };

  // Distinct corridor lines with counts
  const lineStats = useMemo(() => {
    const map: Record<string, number> = {};
    items.forEach((i) => {
      const line = i.line || "Other";
      map[line] = (map[line] || 0) + 1;
    });
    return map;
  }, [items]);

  return (
    <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden">
      {/* ── Card Header ── */}
      <div className="flex flex-col gap-3 border-b border-border p-4 sm:flex-row sm:items-center sm:justify-between bg-muted/20">
        <div className="flex items-center gap-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
            <MapPin className="h-4.5 w-4.5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="text-sm font-semibold text-foreground">3. Current Address – City</h3>
              <Badge variant="secondary" className="text-[10px] bg-primary/10 text-primary font-semibold">
                {items.length} Stations & Localities
              </Badge>
            </div>
            <p className="text-[11px] text-muted-foreground">
              Suburban railway stations and transit lines (Western, Central, Harbour & Trans-Harbour lines)
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {canManage && selectedStation && (
            <Button
              variant="outline"
              size="sm"
              onClick={() => openEdit(selectedStation)}
              className="h-7 gap-1 text-xs text-primary border-primary/30 hover:bg-primary/5"
            >
              <Pencil className="h-3 w-3" />
              Edit Selected ({selectedStation.name})
            </Button>
          )}

          {canManage && (
            <Button size="sm" onClick={openAdd} className="h-7 gap-1 text-xs shrink-0 shadow-sm">
              <Plus className="h-3 w-3" />
              Add New City / Station
            </Button>
          )}
        </div>
      </div>

      {/* ── SCREENSHOT REPRODUCTION: Interactive Searchable Dropdown ── */}
      <div className="p-4 border-b border-border bg-muted/10">
        <div className="max-w-md" ref={dropdownRef}>
          <label className="block text-xs font-semibold text-foreground mb-1.5 flex items-center gap-1">
            <span>Current Address - City</span>
            <span className="text-destructive">*</span>
          </label>

          {/* Trigger Button mimicking the user's screenshot */}
          <div className="relative">
            <button
              type="button"
              onClick={() => setIsDropdownOpen((prev) => !prev)}
              className={cn(
                "w-full h-9 px-3 rounded-lg border bg-card text-left text-xs font-medium flex items-center justify-between transition-all",
                isDropdownOpen
                  ? "border-primary ring-2 ring-primary/20 shadow-sm"
                  : "border-input hover:border-foreground/40",
              )}
            >
              <span className={cn(selectedStation ? "text-foreground font-semibold" : "text-muted-foreground")}>
                {selectedStation ? selectedStation.name : "Select current address - city..."}
              </span>
              <div className="flex items-center gap-1.5 text-muted-foreground">
                {selectedStation && (
                  <span
                    onClick={(e) => {
                      e.stopPropagation();
                      setSelectedStationId("");
                    }}
                    className="hover:text-foreground p-0.5 rounded cursor-pointer"
                    title="Clear selection"
                  >
                    <X className="h-3.5 w-3.5" />
                  </span>
                )}
                {isDropdownOpen ? (
                  <ChevronUp className="h-3.5 w-3.5" />
                ) : (
                  <ChevronDown className="h-3.5 w-3.5" />
                )}
              </div>
            </button>

            {/* Custom Popover Dropdown (Pixel-perfect to screenshot) */}
            {isDropdownOpen && (
              <div className="absolute left-0 top-full mt-1.5 w-full z-50 rounded-lg border border-border bg-popover shadow-xl overflow-hidden animate-in fade-in-50 zoom-in-95">
                {/* Search Input inside Dropdown */}
                <div className="p-2 border-b border-border bg-muted/30 flex items-center gap-2">
                  <Search className="h-3.5 w-3.5 text-muted-foreground shrink-0 ml-1" />
                  <input
                    type="text"
                    value={dropdownSearch}
                    onChange={(e) => setDropdownSearch(e.target.value)}
                    placeholder="Search current address - city..."
                    className="w-full bg-transparent text-xs text-foreground placeholder:text-muted-foreground focus:outline-none"
                    autoFocus
                  />
                  {dropdownSearch && (
                    <button
                      onClick={() => setDropdownSearch("")}
                      className="text-muted-foreground hover:text-foreground text-xs"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  )}
                </div>

                {/* Items List */}
                <div className="max-h-60 overflow-y-auto divide-y divide-border/40 p-1">
                  {dropdownFilteredStations.length === 0 ? (
                    <div className="p-4 text-center text-xs text-muted-foreground">
                      No matching stations found.
                    </div>
                  ) : (
                    dropdownFilteredStations.map((station) => {
                      const isSelected = selectedStation?.id === station.id;
                      return (
                        <div
                          key={station.id}
                          onClick={() => {
                            setSelectedStationId(station.id);
                            setIsDropdownOpen(false);
                            setDropdownSearch("");
                          }}
                          className={cn(
                            "px-3 py-2 text-left cursor-pointer transition-colors rounded-md flex items-center justify-between",
                            isSelected
                              ? "bg-primary/10 text-primary font-medium"
                              : "hover:bg-muted/60 text-foreground",
                          )}
                        >
                          <div>
                            <div className="text-xs font-semibold leading-snug">{station.name}</div>
                            <div className="text-[11px] text-muted-foreground leading-tight">
                              {station.line || station.subLabel || "Mumbai Suburban"}
                            </div>
                          </div>
                          {isSelected && <Check className="h-3.5 w-3.5 text-primary shrink-0" />}
                        </div>
                      );
                    })
                  )}
                </div>

                {/* Bottom Action inside Dropdown */}
                <div className="p-2 border-t border-border bg-muted/20 flex items-center justify-between text-[11px]">
                  <span className="text-muted-foreground">
                    Showing {dropdownFilteredStations.length} of {items.length} stations
                  </span>
                  <button
                    onClick={() => {
                      setIsDropdownOpen(false);
                      openAdd();
                    }}
                    className="text-primary hover:underline font-medium inline-flex items-center gap-1"
                  >
                    <Plus className="h-3 w-3" /> Add New
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* ── Table Toolbar & Corridor Line Filters ── */}
      <div className="p-3 border-b border-border/80 bg-background/50 flex flex-wrap items-center gap-3">
        {/* Search */}
        <div className="relative flex-1 min-w-[180px]">
          <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground" />
          <Input
            value={tableSearch}
            onChange={(e) => setTableSearch(e.target.value)}
            placeholder="Filter list by station or line..."
            className="h-7 pl-8 text-xs bg-card"
          />
        </div>

        {/* Corridor Line Pills */}
        <div className="flex flex-wrap items-center gap-1">
          <button
            onClick={() => setSelectedLineFilter("ALL")}
            className={cn(
              "px-2 py-0.5 rounded text-[11px] font-medium border transition-colors",
              selectedLineFilter === "ALL"
                ? "bg-primary text-primary-foreground border-primary"
                : "bg-card text-muted-foreground border-border hover:text-foreground",
            )}
          >
            All Lines ({items.length})
          </button>
          {MASTER_RAILWAY_LINES_LIST.slice(0, 4).map((line) => {
            const count = lineStats[line] || 0;
            const isLineActive = selectedLineFilter === line;
            return (
              <button
                key={line}
                onClick={() => setSelectedLineFilter(line)}
                className={cn(
                  "px-2 py-0.5 rounded text-[11px] font-medium border transition-colors",
                  isLineActive
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-card text-muted-foreground border-border hover:text-foreground",
                )}
              >
                {line.replace(" Line", "")} ({count})
              </button>
            );
          })}
        </div>
      </div>

      {/* Table */}
      <div className={cn("overflow-x-auto", isExpandedView ? "max-h-[500px]" : "max-h-[300px]")}>
        <table className="w-full text-left text-xs">
          <thead className="sticky top-0 z-10 border-b border-border bg-muted/40 font-medium text-muted-foreground backdrop-blur-sm">
            <tr>
              <th className="py-2 px-3 font-semibold">Station / City Name</th>
              <th className="py-2 px-3 font-semibold">Corridor / Line</th>
              <th className="py-2 px-3 font-semibold">Formatted Value</th>
              {canManage && <th className="py-2 px-3 text-right font-semibold">Actions</th>}
            </tr>
          </thead>
          <tbody className="divide-y divide-border/60">
            {tableFilteredStations.length === 0 ? (
              <tr>
                <td colSpan={4} className="py-8 text-center text-muted-foreground">
                  No stations match the filter.
                </td>
              </tr>
            ) : (
              tableFilteredStations.slice(0, 100).map((item) => {
                const isSelected = selectedStation?.id === item.id;
                return (
                  <tr
                    key={item.id}
                    className={cn(
                      "hover:bg-muted/30 transition-colors group cursor-pointer",
                      isSelected && "bg-primary/5",
                    )}
                    onClick={() => setSelectedStationId(item.id)}
                  >
                    <td className="py-2 px-3 font-medium text-foreground">
                      <span className="inline-flex items-center gap-1.5">
                        <Train className="h-3 w-3 text-primary/70 shrink-0" />
                        <span className={cn(isSelected && "font-bold text-primary")}>{item.name}</span>
                      </span>
                    </td>
                    <td className="py-2 px-3">
                      <Badge
                        variant="outline"
                        className={cn(
                          "text-[10px] px-1.5 py-0 font-medium",
                          item.line === "Western Line"
                            ? "bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-500/20"
                            : item.line === "Central Line"
                            ? "bg-rose-500/10 text-rose-600 dark:text-rose-400 border-rose-500/20"
                            : item.line === "Harbour Line"
                            ? "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/20"
                            : "bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/20",
                        )}
                      >
                        {item.line}
                      </Badge>
                    </td>
                    <td className="py-2 px-3 text-muted-foreground font-mono text-[11px]">
                      {item.value || `${item.name} (${item.line})`}
                    </td>
                    {canManage && (
                      <td className="py-2 px-3 text-right" onClick={(e) => e.stopPropagation()}>
                        <div className="flex items-center justify-end gap-1">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => openEdit(item)}
                            className="h-6 w-6 p-0 text-muted-foreground hover:text-foreground"
                            title="Edit Station / City Name"
                          >
                            <Pencil className="h-3 w-3" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => setDeleteId(item.id)}
                            className="h-6 w-6 p-0 text-muted-foreground hover:text-destructive"
                            title="Delete Station"
                          >
                            <Trash2 className="h-3 w-3" />
                          </Button>
                        </div>
                      </td>
                    )}
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>

      {/* Add City / Station Modal */}
      <Dialog open={isAddOpen} onOpenChange={setIsAddOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm flex items-center gap-2">
              <Plus className="h-4 w-4 text-primary" />
              Add New Current Address – City / Station
            </DialogTitle>
            <DialogDescription className="text-xs">
              Add a new railway station or locality to the Current Address - City master.
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
                Station / Locality Name <span className="text-destructive">*</span>
              </label>
              <Input
                value={formCityName}
                onChange={(e) => setFormCityName(e.target.value)}
                placeholder="e.g. Andheri, Churchgate, Thane, Dombivli"
                className="h-8 text-xs"
                autoFocus
              />
            </div>
            <div className="space-y-1">
              <label className="font-medium text-foreground">Railway Line / Corridor</label>
              <select
                value={formLine}
                onChange={(e) => setFormLine(e.target.value)}
                className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
              >
                {MASTER_RAILWAY_LINES_LIST.map((line) => (
                  <option key={line} value={line}>
                    {line}
                  </option>
                ))}
              </select>
            </div>
            <div className="space-y-1">
              <label className="font-medium text-foreground">Short Code (Optional)</label>
              <Input
                value={formStationCode}
                onChange={(e) => setFormStationCode(e.target.value.toUpperCase())}
                placeholder="e.g. ADH, CSTM, TNA"
                className="h-8 text-xs font-mono uppercase"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" size="sm" onClick={() => setIsAddOpen(false)} className="h-7 text-xs">
              Cancel
            </Button>
            <Button size="sm" onClick={handleSaveAdd} className="h-7 text-xs">
              Add Station
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Edit City / Station Modal */}
      <Dialog open={!!editItem} onOpenChange={(open) => !open && setEditItem(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm flex items-center gap-2">
              <Pencil className="h-4 w-4 text-primary" />
              Edit Current Address – City / Station
            </DialogTitle>
            <DialogDescription className="text-xs">
              Update existing station name or change its associated railway line.
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
                Station / Locality Name <span className="text-destructive">*</span>
              </label>
              <Input
                value={formCityName}
                onChange={(e) => setFormCityName(e.target.value)}
                className="h-8 text-xs"
              />
            </div>
            <div className="space-y-1">
              <label className="font-medium text-foreground">Railway Line / Corridor</label>
              <select
                value={formLine}
                onChange={(e) => setFormLine(e.target.value)}
                className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
              >
                {MASTER_RAILWAY_LINES_LIST.map((line) => (
                  <option key={line} value={line}>
                    {line}
                  </option>
                ))}
              </select>
            </div>
            <div className="space-y-1">
              <label className="font-medium text-foreground">Short Code</label>
              <Input
                value={formStationCode}
                onChange={(e) => setFormStationCode(e.target.value.toUpperCase())}
                placeholder="e.g. ADH, BOM"
                className="h-8 text-xs font-mono uppercase"
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
            <AlertDialogTitle className="text-sm">Delete Station / City?</AlertDialogTitle>
            <AlertDialogDescription className="text-xs">
              Are you sure you want to remove this station from the Current Address - City master?
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
              Delete Station
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 4. TK ID Format Master Card (Configuring TK, TKI, etc.)
// ══════════════════════════════════════════════════════════════════════════════
function TkIdFormatsCard({
  canManage = true,
  formats,
  onAdd,
  onUpdate,
  onDelete,
  isExpandedView,
}: {
  canManage?: boolean;
  formats: TkIdFormatItem[];
  onAdd: (item: Omit<TkIdFormatItem, "id" | "createdAt" | "sampleFormat">) => { success: boolean; error?: string };
  onUpdate: (id: string, item: Partial<Omit<TkIdFormatItem, "id" | "createdAt">>) => { success: boolean; error?: string };
  onDelete: (id: string) => void;
  isExpandedView?: boolean;
}) {
  const [search, setSearch] = useState("");
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [editItem, setEditItem] = useState<TkIdFormatItem | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  // Form fields
  const [formPrefix, setFormPrefix] = useState("");
  const [formName, setFormName] = useState("");
  const [formCategory, setFormCategory] = useState("Full-Time Employee");
  const [formDelimiter, setFormDelimiter] = useState("-");
  const [formDigits, setFormDigits] = useState(4);
  const [formSequence, setFormSequence] = useState(1);
  const [formDesc, setFormDesc] = useState("");
  const [formError, setFormError] = useState<string | null>(null);

  const filtered = useMemo(() => {
    return formats.filter((f) => {
      if (!search.trim()) return true;
      const q = search.toLowerCase();
      return (
        f.prefix.toLowerCase().includes(q) ||
        f.name.toLowerCase().includes(q) ||
        f.targetCategory.toLowerCase().includes(q) ||
        (f.description && f.description.toLowerCase().includes(q))
      );
    });
  }, [formats, search]);

  const liveSample = useMemo(() => {
    const pfx = formPrefix.trim().toUpperCase() || "TK";
    const delim = formDelimiter !== undefined ? formDelimiter : "-";
    const dgt = formDigits || 4;
    const seq = formSequence || 1;
    return `${pfx}${delim}${String(seq).padStart(dgt, "0")}`;
  }, [formPrefix, formDelimiter, formDigits, formSequence]);

  const openAdd = () => {
    setFormPrefix("");
    setFormName("");
    setFormCategory("Full-Time Employee");
    setFormDelimiter("-");
    setFormDigits(4);
    setFormSequence(1);
    setFormDesc("");
    setFormError(null);
    setIsAddOpen(true);
  };

  const openEdit = (item: TkIdFormatItem) => {
    setEditItem(item);
    setFormPrefix(item.prefix);
    setFormName(item.name);
    setFormCategory(item.targetCategory);
    setFormDelimiter(item.delimiter);
    setFormDigits(item.digits);
    setFormSequence(item.currentSequence);
    setFormDesc(item.description || "");
    setFormError(null);
  };

  const handleSaveAdd = () => {
    if (!formPrefix.trim()) {
      setFormError("Prefix code (e.g. TK, TKI) is required.");
      return;
    }
    const res = onAdd({
      prefix: formPrefix.trim().toUpperCase(),
      name: formName.trim() || `${formPrefix.trim().toUpperCase()} Format`,
      targetCategory: formCategory,
      delimiter: formDelimiter,
      digits: Number(formDigits) || 4,
      currentSequence: Number(formSequence) || 1,
      isActive: true,
      description: formDesc.trim(),
    });
    if (!res.success) {
      setFormError(res.error || "Failed to add TK ID format.");
    } else {
      setIsAddOpen(false);
    }
  };

  const handleSaveEdit = () => {
    if (!editItem) return;
    if (!formPrefix.trim()) {
      setFormError("Prefix code (e.g. TK, TKI) is required.");
      return;
    }
    const res = onUpdate(editItem.id, {
      prefix: formPrefix.trim().toUpperCase(),
      name: formName.trim() || `${formPrefix.trim().toUpperCase()} Format`,
      targetCategory: formCategory,
      delimiter: formDelimiter,
      digits: Number(formDigits) || 4,
      currentSequence: Number(formSequence) || 1,
      description: formDesc.trim(),
    });
    if (!res.success) {
      setFormError(res.error || "Failed to update TK ID format.");
    } else {
      setEditItem(null);
    }
  };

  return (
    <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden">
      <div className="flex flex-col gap-3 border-b border-border p-4 sm:flex-row sm:items-center sm:justify-between bg-muted/20">
        <div className="flex items-center gap-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
            <IdCard className="h-4.5 w-4.5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="text-sm font-semibold text-foreground">4. TK ID Format Master</h3>
              <div className="flex items-center gap-1.5">
                <Badge variant="secondary" className="text-[10px] bg-primary/10 text-primary font-mono font-bold">
                  TK
                </Badge>
                <Badge variant="secondary" className="text-[10px] bg-amber-500/10 text-amber-600 dark:text-amber-400 font-mono font-bold">
                  TKI
                </Badge>
                <Badge variant="outline" className="text-[10px]">
                  {formats.length} Formats
                </Badge>
              </div>
            </div>
            <p className="text-[11px] text-muted-foreground">
              Configure employee identification prefixes (e.g. TK for permanent staff, TKI for interns, TKC for consultants)
            </p>
          </div>
        </div>

        {canManage && (
          <Button size="sm" onClick={openAdd} className="h-7 gap-1 text-xs shrink-0 shadow-sm">
            <Plus className="h-3 w-3" />
            Add ID Format Prefix
          </Button>
        )}
      </div>

      {/* Existing Formats Selector Dropdown Bar */}
      <div className="p-3 border-b border-border/80 bg-background/50 flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[160px]">
          <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground" />
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search formats by prefix or category..."
            className="h-7 pl-8 text-xs bg-card"
          />
        </div>

        {/* Existing Formats Dropdown */}
        <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
          <span className="font-medium text-foreground shrink-0">Select Format to Edit:</span>
          <select
            onChange={(e) => {
              const selected = formats.find((f) => f.id === e.target.value);
              if (selected) openEdit(selected);
            }}
            value=""
            className="h-7 rounded-md border border-input bg-card px-2 text-xs text-foreground focus:outline-none"
          >
            <option value="">-- Choose Existing Format ({formats.length}) --</option>
            {formats.map((f) => (
              <option key={f.id} value={f.id}>
                {f.prefix} — {f.targetCategory} ({f.sampleFormat})
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
              <th className="py-2 px-3 font-semibold">Prefix Code</th>
              <th className="py-2 px-3 font-semibold">Format Name & Target Category</th>
              <th className="py-2 px-3 font-semibold">Pattern & Sample</th>
              <th className="py-2 px-3 font-semibold">Current Sequence</th>
              <th className="py-2 px-3 font-semibold">Status</th>
              {canManage && <th className="py-2 px-3 text-right font-semibold">Actions</th>}
            </tr>
          </thead>
          <tbody className="divide-y divide-border/60">
            {filtered.map((item) => (
              <tr key={item.id} className="hover:bg-muted/30 transition-colors">
                <td className="py-2.5 px-3">
                  <span
                    className={cn(
                      "font-mono font-bold text-xs px-2 py-0.5 rounded-md border inline-flex items-center gap-1",
                      item.prefix === "TK"
                        ? "bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-500/20"
                        : item.prefix === "TKI"
                        ? "bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/20"
                        : "bg-purple-500/10 text-purple-600 dark:text-purple-400 border-purple-500/20",
                    )}
                  >
                    <Hash className="h-3 w-3 shrink-0" />
                    {item.prefix}
                  </span>
                </td>
                <td className="py-2.5 px-3">
                  <div className="font-medium text-foreground">{item.name}</div>
                  <div className="text-[11px] text-muted-foreground">{item.targetCategory}</div>
                </td>
                <td className="py-2.5 px-3">
                  <span className="font-mono font-semibold text-primary bg-primary/5 px-2 py-0.5 rounded border border-primary/20 text-[11px]">
                    {item.sampleFormat}
                  </span>
                </td>
                <td className="py-2.5 px-3 font-mono text-muted-foreground">
                  #{item.currentSequence}
                </td>
                <td className="py-2.5 px-3">
                  <Badge
                    variant="secondary"
                    className="text-[10px] bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20"
                  >
                    Active
                  </Badge>
                </td>
                {canManage && (
                  <td className="py-2.5 px-3 text-right">
                    <div className="flex items-center justify-end gap-1">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openEdit(item)}
                        className="h-6 w-6 p-0 text-muted-foreground hover:text-foreground"
                        title="Edit TK ID Format"
                      >
                        <Pencil className="h-3 w-3" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setDeleteId(item.id)}
                        className="h-6 w-6 p-0 text-muted-foreground hover:text-destructive"
                        title="Delete Format"
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

      {/* Add Format Dialog */}
      <Dialog open={isAddOpen} onOpenChange={setIsAddOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm flex items-center gap-2">
              <IdCard className="h-4 w-4 text-primary" />
              Add TK ID Format Prefix
            </DialogTitle>
            <DialogDescription className="text-xs">
              Define a new employee ID prefix format (e.g. TK for full-time, TKI for intern).
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-3 py-2 text-xs">
            {formError && (
              <div className="rounded-lg bg-destructive/10 border border-destructive/20 p-2 text-destructive text-xs">
                {formError}
              </div>
            )}

            {/* Live Preview Box */}
            <div className="rounded-lg border border-primary/20 bg-primary/5 p-3 flex items-center justify-between">
              <div>
                <div className="text-[10px] uppercase font-semibold text-primary tracking-wide">
                  Live Generated Sample
                </div>
                <div className="text-sm font-mono font-bold text-foreground mt-0.5">{liveSample}</div>
              </div>
              <Badge variant="outline" className="text-[10px] bg-primary/10 text-primary border-primary/30">
                Pattern Preview
              </Badge>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <label className="font-medium text-foreground">
                  Prefix Code <span className="text-destructive">*</span>
                </label>
                <Input
                  value={formPrefix}
                  onChange={(e) => setFormPrefix(e.target.value.toUpperCase())}
                  placeholder="e.g. TK, TKI, TKC"
                  className="h-8 text-xs font-mono uppercase"
                  autoFocus
                />
              </div>

              <div className="space-y-1">
                <label className="font-medium text-foreground">Delimiter</label>
                <select
                  value={formDelimiter}
                  onChange={(e) => setFormDelimiter(e.target.value)}
                  className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none"
                >
                  <option value="-">Hyphen (-)</option>
                  <option value="">None (No separator)</option>
                  <option value="/">Slash (/)</option>
                </select>
              </div>
            </div>

            <div className="space-y-1">
              <label className="font-medium text-foreground">Format Name</label>
              <Input
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="e.g. Full-Time Staff Employee ID"
                className="h-8 text-xs"
              />
            </div>

            <div className="space-y-1">
              <label className="font-medium text-foreground">Target Role / Category</label>
              <select
                value={formCategory}
                onChange={(e) => setFormCategory(e.target.value)}
                className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none"
              >
                <option value="Full-Time Employee">Full-Time Employee</option>
                <option value="Intern">Intern / Trainee</option>
                <option value="Consultant / Contractor">Consultant / Contractor</option>
                <option value="Probationary">Probationary Staff</option>
              </select>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <label className="font-medium text-foreground">Padding Digits</label>
                <Input
                  type="number"
                  min="3"
                  max="6"
                  value={formDigits}
                  onChange={(e) => setFormDigits(parseInt(e.target.value, 10) || 4)}
                  className="h-8 text-xs font-mono"
                />
              </div>
              <div className="space-y-1">
                <label className="font-medium text-foreground">Next Sequence #</label>
                <Input
                  type="number"
                  min="1"
                  value={formSequence}
                  onChange={(e) => setFormSequence(parseInt(e.target.value, 10) || 1)}
                  className="h-8 text-xs font-mono"
                />
              </div>
            </div>

            <div className="space-y-1">
              <label className="font-medium text-foreground">Description</label>
              <Input
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="e.g. Standard permanent employee prefix"
                className="h-8 text-xs"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" size="sm" onClick={() => setIsAddOpen(false)} className="h-7 text-xs">
              Cancel
            </Button>
            <Button size="sm" onClick={handleSaveAdd} className="h-7 text-xs">
              Add Format
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Edit Format Dialog */}
      <Dialog open={!!editItem} onOpenChange={(open) => !open && setEditItem(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm flex items-center gap-2">
              <Pencil className="h-4 w-4 text-primary" />
              Edit TK ID Format ({editItem?.prefix})
            </DialogTitle>
            <DialogDescription className="text-xs">
              Modify prefix code, delimiter, digits, or current sequence number.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-3 py-2 text-xs">
            {formError && (
              <div className="rounded-lg bg-destructive/10 border border-destructive/20 p-2 text-destructive text-xs">
                {formError}
              </div>
            )}

            {/* Live Preview Box */}
            <div className="rounded-lg border border-primary/20 bg-primary/5 p-3 flex items-center justify-between">
              <div>
                <div className="text-[10px] uppercase font-semibold text-primary tracking-wide">
                  Live Generated Sample
                </div>
                <div className="text-sm font-mono font-bold text-foreground mt-0.5">{liveSample}</div>
              </div>
              <Badge variant="outline" className="text-[10px] bg-primary/10 text-primary border-primary/30">
                Pattern Preview
              </Badge>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <label className="font-medium text-foreground">Prefix Code</label>
                <Input
                  value={formPrefix}
                  onChange={(e) => setFormPrefix(e.target.value.toUpperCase())}
                  className="h-8 text-xs font-mono uppercase"
                />
              </div>

              <div className="space-y-1">
                <label className="font-medium text-foreground">Delimiter</label>
                <select
                  value={formDelimiter}
                  onChange={(e) => setFormDelimiter(e.target.value)}
                  className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none"
                >
                  <option value="-">Hyphen (-)</option>
                  <option value="">None (No separator)</option>
                  <option value="/">Slash (/)</option>
                </select>
              </div>
            </div>

            <div className="space-y-1">
              <label className="font-medium text-foreground">Format Name</label>
              <Input
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                className="h-8 text-xs"
              />
            </div>

            <div className="space-y-1">
              <label className="font-medium text-foreground">Target Role / Category</label>
              <select
                value={formCategory}
                onChange={(e) => setFormCategory(e.target.value)}
                className="w-full h-8 rounded-md border border-input bg-card px-2.5 text-xs text-foreground focus:outline-none"
              >
                <option value="Full-Time Employee">Full-Time Employee</option>
                <option value="Intern">Intern / Trainee</option>
                <option value="Consultant / Contractor">Consultant / Contractor</option>
                <option value="Probationary">Probationary Staff</option>
              </select>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <label className="font-medium text-foreground">Padding Digits</label>
                <Input
                  type="number"
                  min="3"
                  max="6"
                  value={formDigits}
                  onChange={(e) => setFormDigits(parseInt(e.target.value, 10) || 4)}
                  className="h-8 text-xs font-mono"
                />
              </div>
              <div className="space-y-1">
                <label className="font-medium text-foreground">Current Sequence #</label>
                <Input
                  type="number"
                  min="1"
                  value={formSequence}
                  onChange={(e) => setFormSequence(parseInt(e.target.value, 10) || 1)}
                  className="h-8 text-xs font-mono"
                />
              </div>
            </div>

            <div className="space-y-1">
              <label className="font-medium text-foreground">Description</label>
              <Input
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
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
            <AlertDialogTitle className="text-sm">Delete TK ID Format?</AlertDialogTitle>
            <AlertDialogDescription className="text-xs">
              Are you sure you want to remove this ID format prefix?
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
// 5–9. Simple Master Card Component (Business Unit, Work Location, Grad, Post Grad, Certs)
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
  onAdd: (name: string, extra?: { code?: string; description?: string }) => { success: boolean; error?: string };
  onUpdate: (id: string, name: string, extra?: { code?: string; description?: string; isActive?: boolean }) => { success: boolean; error?: string };
  onDelete: (id: string) => void;
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

  const handleSaveAdd = () => {
    if (!formName.trim()) {
      setFormError(`${singular} name is required.`);
      return;
    }
    const res = onAdd(formName, {
      code: formCode.trim(),
      description: formDesc.trim(),
    });
    if (!res.success) {
      setFormError(res.error || `Failed to add ${singular.toLowerCase()}.`);
    } else {
      setIsAddOpen(false);
    }
  };

  const handleSaveEdit = () => {
    if (!editItem) return;
    if (!formName.trim()) {
      setFormError(`${singular} name is required.`);
      return;
    }
    const res = onUpdate(editItem.id, formName, {
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
