import { useCallback, useEffect, useMemo, useState } from "react";
import {
  AlertCircle,
  AtSign,
  Award,
  BookOpen,
  Building,
  GraduationCap,
  Layers,
  MapPin,
  MapPinned,
  Network,
  Pencil,
  Plus,
  Search,
  Trash2,
  X,
} from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { SearchableSelect } from "@/components/creatable-catalog-select";
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
import {
  countResourceMasters,
  createAddressCityMaster,
  createBusinessUnit,
  createCertification,
  createEmailDomain,
  createGraduationDegree,
  createHierarchy,
  createPostGraduationDegree,
  createWorkLocation,
  deleteAddressCityMaster,
  deleteBusinessUnit,
  deleteCertification,
  deleteEmailDomain,
  deleteGraduationDegree,
  deleteHierarchy,
  deletePostGraduationDegree,
  deleteWorkLocation,
  explainResourceMasterError,
  fetchResourceMasters,
  updateAddressCityMaster,
  updateBusinessUnit,
  updateCertification,
  updateEmailDomain,
  updateGraduationDegree,
  updateHierarchy,
  updatePostGraduationDegree,
  updateWorkLocation,
  type AddressCityMaster,
  type DepartmentHierarchyRow,
  type HierarchyDesignationOption,
  type NamedMaster,
  type RbacRoleOption,
  type ResourceMastersSnapshot,
} from "@/modules/settings/api/resource-masters";

type ResourceCategory =
  | "hierarchy"
  | "emailDomains"
  | "businessUnits"
  | "workLocations"
  | "graduationDegrees"
  | "postGraduationDegrees"
  | "certifications"
  | "addressCities";

type SaveResult = { success: boolean; error?: string };

interface ResourceMastersSectionProps {
  onCountChange?: (count: number) => void;
}

export function ResourceMastersSection({ onCountChange }: ResourceMastersSectionProps) {
  const [activeCategory, setActiveCategory] = useState<ResourceCategory | "all">("all");
  const [snapshot, setSnapshot] = useState<ResourceMastersSnapshot | null>(null);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const next = await fetchResourceMasters();
      setSnapshot(next);
      setLoadError(null);
      onCountChange?.(countResourceMasters(next));
    } catch (error) {
      setLoadError(explainResourceMasterError(error, "Could not load resource masters."));
    } finally {
      setLoading(false);
    }
  }, [onCountChange]);

  useEffect(() => {
    void load();
  }, [load]);

  const reloadAfterSave = useCallback(async () => {
    const next = await fetchResourceMasters();
    setSnapshot(next);
    setLoadError(null);
    onCountChange?.(countResourceMasters(next));
  }, [onCountChange]);

  const runSave = useCallback(
    async (action: () => Promise<unknown>, successMessage: string): Promise<SaveResult> => {
      try {
        await action();
      } catch (error) {
        return { success: false, error: explainResourceMasterError(error, "Could not save this master.") };
      }
      toast.success(successMessage);
      try {
        await reloadAfterSave();
      } catch (error) {
        setLoadError(explainResourceMasterError(error, "Saved, but the list could not refresh."));
      }
      return { success: true };
    },
    [reloadAfterSave],
  );

  const categories: Array<{
    id: ResourceCategory;
    title: string;
    icon: typeof Network;
    count: number;
  }> = [
    { id: "hierarchy", title: "Department Hierarchy", icon: Network, count: snapshot?.hierarchy.rows.length ?? 0 },
    { id: "emailDomains", title: "Work Email Domain", icon: AtSign, count: snapshot?.emailDomains.length ?? 0 },
    { id: "businessUnits", title: "Business Unit", icon: Building, count: snapshot?.businessUnits.length ?? 0 },
    { id: "workLocations", title: "Work Location", icon: MapPinned, count: snapshot?.workLocations.length ?? 0 },
    { id: "graduationDegrees", title: "Graduation Degree", icon: GraduationCap, count: snapshot?.graduationDegrees.length ?? 0 },
    { id: "postGraduationDegrees", title: "Post Graduation", icon: BookOpen, count: snapshot?.postGraduationDegrees.length ?? 0 },
    { id: "certifications", title: "Certifications", icon: Award, count: snapshot?.certifications.length ?? 0 },
    { id: "addressCities", title: "Address City", icon: MapPin, count: snapshot?.addressCities.length ?? 0 },
  ];

  if (loading && !snapshot) {
    return (
      <div className="rounded-xl border border-dashed border-border py-16 text-center text-sm text-muted-foreground">
        Loading resource masters…
      </div>
    );
  }

  if (!snapshot) {
    return (
      <div className="rounded-xl border border-destructive/30 bg-destructive/5 p-6 text-sm text-destructive">
        <div className="flex items-start gap-2">
          <AlertCircle className="mt-0.5 h-4 w-4 shrink-0" />
          <div className="space-y-3">
            <p>{loadError ?? "Could not load resource masters."}</p>
            <Button type="button" size="sm" variant="outline" className="h-8 text-xs" onClick={() => void load()}>
              Retry
            </Button>
          </div>
        </div>
      </div>
    );
  }

  const hierarchyCard = (
    <HierarchyCard
      rows={snapshot.hierarchy.rows}
      departments={snapshot.hierarchy.departments}
      designations={snapshot.hierarchy.designations}
      rbacRoles={snapshot.hierarchy.rbacRoles}
      isExpanded={activeCategory === "hierarchy"}
      onCreate={(input) =>
        runSave(
          () => createHierarchy(input),
          `Added ${input.designation} under ${input.department}`,
        )
      }
      onUpdate={(id, input) =>
        runSave(
          () => updateHierarchy(id, input),
          `Updated ${input.designation}`,
        )
      }
      onDelete={(id, label) => runSave(() => deleteHierarchy(id), `Removed ${label}`)}
    />
  );

  const nameCards = (
    <>
      <NameMasterCard
        title="Work Email Domain"
        singular="Domain"
        description="Domains available on the work email field when onboarding an employee."
        placeholder="e.g. talakunchi.com"
        icon={AtSign}
        items={snapshot.emailDomains}
        isExpanded={activeCategory === "emailDomains"}
        onCreate={(name) => runSave(() => createEmailDomain(name), `Added ${name}`)}
        onUpdate={(id, name) => runSave(() => updateEmailDomain(id, name), `Updated ${name}`)}
        onDelete={(id, name) => runSave(() => deleteEmailDomain(id), `Removed ${name}`)}
      />
      <NameMasterCard
        title="Business Unit"
        singular="Business Unit"
        description="Business unit names for the employee profile."
        placeholder="e.g. Talakunchi Networks Private Limited"
        icon={Building}
        items={snapshot.businessUnits}
        isExpanded={activeCategory === "businessUnits"}
        onCreate={(name) => runSave(() => createBusinessUnit(name), `Added ${name}`)}
        onUpdate={(id, name) => runSave(() => updateBusinessUnit(id, name), `Updated ${name}`)}
        onDelete={(id, name) => runSave(() => deleteBusinessUnit(id), `Removed ${name}`)}
      />
      <NameMasterCard
        title="Work Location"
        singular="Work Location"
        description="Work locations for the employee profile. Onsite still asks for a site location on the form."
        placeholder="e.g. Onsite"
        icon={MapPinned}
        items={snapshot.workLocations}
        isExpanded={activeCategory === "workLocations"}
        onCreate={(name) => runSave(() => createWorkLocation(name), `Added ${name}`)}
        onUpdate={(id, name) => runSave(() => updateWorkLocation(id, name), `Updated ${name}`)}
        onDelete={(id, name) => runSave(() => deleteWorkLocation(id), `Removed ${name}`)}
      />
      <NameMasterCard
        title="Graduation Degree Name"
        singular="Degree"
        description="Graduation degree names on Onboard New Employee."
        placeholder="e.g. B.Tech, B.Com, B.Sc"
        icon={GraduationCap}
        items={snapshot.graduationDegrees}
        isExpanded={activeCategory === "graduationDegrees"}
        onCreate={(name) => runSave(() => createGraduationDegree(name), `Added ${name}`)}
        onUpdate={(id, name) => runSave(() => updateGraduationDegree(id, name), `Updated ${name}`)}
        onDelete={(id, name) => runSave(() => deleteGraduationDegree(id), `Removed ${name}`)}
      />
      <NameMasterCard
        title="Post Graduation Degree Name"
        singular="Degree"
        description="Post graduation degree names on Onboard New Employee."
        placeholder="e.g. M.Tech, MBA, M.Sc"
        icon={BookOpen}
        items={snapshot.postGraduationDegrees}
        isExpanded={activeCategory === "postGraduationDegrees"}
        onCreate={(name) => runSave(() => createPostGraduationDegree(name), `Added ${name}`)}
        onUpdate={(id, name) => runSave(() => updatePostGraduationDegree(id, name), `Updated ${name}`)}
        onDelete={(id, name) => runSave(() => deletePostGraduationDegree(id), `Removed ${name}`)}
      />
      <NameMasterCard
        title="Certification Details"
        singular="Certification"
        description="Certification names an employee can pick on the profile."
        placeholder="e.g. AWS Solutions Architect"
        icon={Award}
        items={snapshot.certifications}
        isExpanded={activeCategory === "certifications"}
        onCreate={(name) => runSave(() => createCertification(name), `Added ${name}`)}
        onUpdate={(id, name) => runSave(() => updateCertification(id, name), `Updated ${name}`)}
        onDelete={(id, name) => runSave(() => deleteCertification(id), `Removed ${name}`)}
      />
      <NameMasterCard
        title="Current Address - City"
        singular="City"
        description="Cities in the Current Address - City dropdown on Onboard New Employee."
        placeholder="e.g. Andheri or Pune"
        icon={MapPin}
        items={snapshot.addressCities}
        hasLine
        isExpanded={activeCategory === "addressCities"}
        onCreate={(name, line) => runSave(() => createAddressCityMaster(name, line), `Added ${name}`)}
        onUpdate={(id, name, line) => runSave(() => updateAddressCityMaster(id, name, line), `Updated ${name}`)}
        onDelete={(id, name) => runSave(() => deleteAddressCityMaster(id), `Removed ${name}`)}
      />
    </>
  );

  return (
    <div className="space-y-6">
      {loadError && (
        <div className="flex items-center gap-1.5 rounded-md border border-destructive/30 bg-destructive/10 px-2.5 py-1.5 text-xs text-destructive">
          <AlertCircle className="h-3.5 w-3.5 shrink-0" />
          <span>{loadError}</span>
        </div>
      )}

      <div className="flex flex-wrap items-center gap-1.5 rounded-xl border border-border bg-muted/60 p-1">
        <button
          type="button"
          onClick={() => setActiveCategory("all")}
          className={cn(
            "flex items-center gap-2 rounded-lg px-3.5 py-1.5 text-xs font-medium transition-all",
            activeCategory === "all"
              ? "border border-border/80 bg-card font-semibold text-foreground shadow-sm"
              : "text-muted-foreground hover:text-foreground",
          )}
        >
          <Layers className="h-3.5 w-3.5" />
          <span>All Masters Overview</span>
        </button>
        {categories.map((cat) => {
          const Icon = cat.icon;
          return (
            <button
              key={cat.id}
              type="button"
              onClick={() => setActiveCategory(cat.id)}
              className={cn(
                "flex items-center gap-2 rounded-lg px-3.5 py-1.5 text-xs font-medium transition-all",
                activeCategory === cat.id
                  ? "border border-border/80 bg-card font-semibold text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              <Icon className="h-3.5 w-3.5" />
              <span>{cat.title}</span>
              <span
                className={cn(
                  "ml-0.5 rounded-full px-1.5 py-0.2 text-[10px]",
                  activeCategory === cat.id ? "bg-primary/15 font-semibold text-primary" : "bg-muted text-muted-foreground",
                )}
              >
                {cat.count}
              </span>
            </button>
          );
        })}
      </div>

      {activeCategory === "all" ? (
        <div className="grid grid-cols-1 gap-5 lg:grid-cols-2">
          <div className="lg:col-span-2">{hierarchyCard}</div>
          {nameCards}
        </div>
      ) : activeCategory === "hierarchy" ? (
        <div className="mx-auto max-w-5xl">{hierarchyCard}</div>
      ) : (
        <div className="mx-auto max-w-4xl">
          {activeCategory === "emailDomains" && (
            <NameMasterCard
              title="Work Email Domain"
              singular="Domain"
              description="Domains available on the work email field when onboarding an employee."
              placeholder="e.g. talakunchi.com"
              icon={AtSign}
              items={snapshot.emailDomains}
              isExpanded
              onCreate={(name) => runSave(() => createEmailDomain(name), `Added ${name}`)}
              onUpdate={(id, name) => runSave(() => updateEmailDomain(id, name), `Updated ${name}`)}
              onDelete={(id, name) => runSave(() => deleteEmailDomain(id), `Removed ${name}`)}
            />
          )}
          {activeCategory === "businessUnits" && (
            <NameMasterCard
              title="Business Unit"
              singular="Business Unit"
              description="Business unit names for the employee profile."
              placeholder="e.g. Talakunchi Networks Private Limited"
              icon={Building}
              items={snapshot.businessUnits}
              isExpanded
              onCreate={(name) => runSave(() => createBusinessUnit(name), `Added ${name}`)}
              onUpdate={(id, name) => runSave(() => updateBusinessUnit(id, name), `Updated ${name}`)}
              onDelete={(id, name) => runSave(() => deleteBusinessUnit(id), `Removed ${name}`)}
            />
          )}
          {activeCategory === "workLocations" && (
            <NameMasterCard
              title="Work Location"
              singular="Work Location"
              description="Work locations for the employee profile. Onsite still asks for a site location on the form."
              placeholder="e.g. Onsite"
              icon={MapPinned}
              items={snapshot.workLocations}
              isExpanded
              onCreate={(name) => runSave(() => createWorkLocation(name), `Added ${name}`)}
              onUpdate={(id, name) => runSave(() => updateWorkLocation(id, name), `Updated ${name}`)}
              onDelete={(id, name) => runSave(() => deleteWorkLocation(id), `Removed ${name}`)}
            />
          )}
          {activeCategory === "graduationDegrees" && (
            <NameMasterCard
              title="Graduation Degree Name"
              singular="Degree"
              description="Graduation degree names on Onboard New Employee."
              placeholder="e.g. B.Tech, B.Com, B.Sc"
              icon={GraduationCap}
              items={snapshot.graduationDegrees}
              isExpanded
              onCreate={(name) => runSave(() => createGraduationDegree(name), `Added ${name}`)}
              onUpdate={(id, name) => runSave(() => updateGraduationDegree(id, name), `Updated ${name}`)}
              onDelete={(id, name) => runSave(() => deleteGraduationDegree(id), `Removed ${name}`)}
            />
          )}
          {activeCategory === "postGraduationDegrees" && (
            <NameMasterCard
              title="Post Graduation Degree Name"
              singular="Degree"
              description="Post graduation degree names on Onboard New Employee."
              placeholder="e.g. M.Tech, MBA, M.Sc"
              icon={BookOpen}
              items={snapshot.postGraduationDegrees}
              isExpanded
              onCreate={(name) => runSave(() => createPostGraduationDegree(name), `Added ${name}`)}
              onUpdate={(id, name) => runSave(() => updatePostGraduationDegree(id, name), `Updated ${name}`)}
              onDelete={(id, name) => runSave(() => deletePostGraduationDegree(id), `Removed ${name}`)}
            />
          )}
          {activeCategory === "certifications" && (
            <NameMasterCard
              title="Certification Details"
              singular="Certification"
              description="Certification names an employee can pick on the profile."
              placeholder="e.g. AWS Solutions Architect"
              icon={Award}
              items={snapshot.certifications}
              isExpanded
              onCreate={(name) => runSave(() => createCertification(name), `Added ${name}`)}
              onUpdate={(id, name) => runSave(() => updateCertification(id, name), `Updated ${name}`)}
              onDelete={(id, name) => runSave(() => deleteCertification(id), `Removed ${name}`)}
            />
          )}
          {activeCategory === "addressCities" && (
            <NameMasterCard
              title="Current Address - City"
              singular="City"
              description="Cities in the Current Address - City dropdown on Onboard New Employee."
              placeholder="e.g. Andheri or Pune"
              icon={MapPin}
              items={snapshot.addressCities}
              hasLine
              isExpanded
              onCreate={(name, line) => runSave(() => createAddressCityMaster(name, line), `Added ${name}`)}
              onUpdate={(id, name, line) => runSave(() => updateAddressCityMaster(id, name, line), `Updated ${name}`)}
              onDelete={(id, name) => runSave(() => deleteAddressCityMaster(id), `Removed ${name}`)}
            />
          )}
        </div>
      )}
    </div>
  );
}

function uniqueSorted(values: Array<string | null | undefined>): string[] {
  const seen = new Set<string>();
  const out: string[] = [];
  for (const value of values) {
    const trimmed = (value ?? "").trim();
    if (!trimmed) continue;
    const key = trimmed.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(trimmed);
  }
  return out.sort((a, b) => a.localeCompare(b, undefined, { sensitivity: "base" }));
}

function designationNamesFor(department: string, designations: HierarchyDesignationOption[]): string[] {
  const needle = department.trim().toLowerCase();
  const pool = needle
    ? designations.filter((item) => item.department.trim().toLowerCase() === needle)
    : designations;
  return uniqueSorted(pool.map((item) => item.name));
}

function findHierarchyDuplicate(
  rows: DepartmentHierarchyRow[],
  department: string,
  designation: string,
  exceptId?: string,
) {
  const dept = department.trim().toLowerCase();
  const title = designation.trim().toLowerCase();
  if (!dept || !title) return undefined;
  return rows.find(
    (row) =>
      row.id !== exceptId &&
      row.department.trim().toLowerCase() === dept &&
      row.designation.trim().toLowerCase() === title,
  );
}

function splitSubDepartments(value?: string | null): string[] {
  return (value ?? "")
    .split(",")
    .map((part) => part.replace(/\s+/g, " ").trim())
    .filter(Boolean);
}

function subDepartmentNamesFor(
  department: string,
  designations: HierarchyDesignationOption[],
  rows: DepartmentHierarchyRow[],
): string[] {
  const dept = department.trim().toLowerCase();
  const inDepartment = (name: string) => !dept || name.trim().toLowerCase() === dept;
  return uniqueSorted([
    ...designations
      .filter((item) => inDepartment(item.department))
      .flatMap((item) => splitSubDepartments(item.subDepartment)),
    ...rows
      .filter((row) => inDepartment(row.department))
      .flatMap((row) => splitSubDepartments(row.subDepartment)),
  ]);
}

function storedSubDepartment(
  department: string,
  designation: string,
  rows: DepartmentHierarchyRow[],
): string {
  const dept = department.trim().toLowerCase();
  const title = designation.trim().toLowerCase();
  const row = rows.find(
    (item) =>
      item.department.trim().toLowerCase() === dept &&
      item.designation.trim().toLowerCase() === title,
  );
  const parts = splitSubDepartments(row?.subDepartment);
  return parts.length === 1 ? parts[0] : "";
}

function rbacLabel(role: RbacRoleOption): string {
  return role.displayName?.trim() || role.name;
}

function rememberTypedName(name: string) {
  const trimmed = name.trim();
  return Promise.resolve({ id: trimmed, name: trimmed });
}

function HierarchyFields({
  department,
  designation,
  subDepartment,
  rbacRoleId,
  onDepartment,
  onDesignation,
  onSubDepartment,
  onFloor,
  onRbac,
  departmentSuggestions,
  designationSuggestions,
  subDepartmentSuggestions,
  rbacRoles,
  subDepartmentForDesignation,
}: {
  department: string;
  designation: string;
  subDepartment: string;
  rbacRoleId: string;
  onDepartment: (value: string) => void;
  onDesignation: (value: string) => void;
  onSubDepartment: (value: string) => void;
  onFloor: (value: string) => void;
  onRbac: (value: string) => void;
  departmentSuggestions: string[];
  designationSuggestions: string[];
  subDepartmentSuggestions: string[];
  rbacRoles: RbacRoleOption[];
  subDepartmentForDesignation: (designationName: string) => string;
}) {
  const same = (left: string, right: string) => left.trim().toLowerCase() === right.trim().toLowerCase();

  const changeDepartment = (value: string) => {
    onDepartment(value);
    if (!same(value, department)) {
      onDesignation("");
      onSubDepartment("");
      onFloor("");
      onRbac("");
    }
  };

  const changeDesignation = (value: string) => {
    onDesignation(value);
    if (!same(value, designation)) {
      onSubDepartment(subDepartmentForDesignation(value));
      onFloor("");
      onRbac("");
    }
  };

  const changeSubDepartment = (value: string) => {
    onSubDepartment(value);
    if (!same(value, subDepartment)) {
      onFloor("");
      onRbac("");
    }
  };

  return (
    <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
      <SearchableSelect
        label="Department"
        required
        clearable={false}
        showSearch
        options={departmentSuggestions}
        value={department}
        onChange={changeDepartment}
        onCreate={rememberTypedName}
        placeholder="Select a department"
      />
      <SearchableSelect
        label="Designation"
        required
        clearable={false}
        showSearch
        disabled={!department.trim()}
        disabledHint="Select a department first"
        options={designationSuggestions}
        value={designation}
        onChange={changeDesignation}
        onCreate={rememberTypedName}
        placeholder="Select a designation"
      />
      <SearchableSelect
        label="Sub-Department"
        required
        clearable={false}
        showSearch
        disabled={!designation.trim()}
        disabledHint="Select a designation first"
        options={subDepartmentSuggestions}
        value={subDepartment}
        onChange={changeSubDepartment}
        onCreate={rememberTypedName}
        placeholder="Select a sub-department"
      />
      <SearchableSelect
        label="Assigned RBAC Role"
        required
        clearable={false}
        showSearch
        disabled={!subDepartment.trim()}
        disabledHint="Select a sub-department first"
        options={rbacRoles.map((role) => ({ value: role.id, label: rbacLabel(role) }))}
        value={rbacRoleId}
        onChange={onRbac}
        placeholder="Select an access role"
      />
    </div>
  );
}

function HierarchyCard({
  rows,
  departments,
  designations,
  rbacRoles,
  isExpanded,
  onCreate,
  onUpdate,
  onDelete,
}: {
  rows: DepartmentHierarchyRow[];
  departments: NamedMaster[];
  designations: HierarchyDesignationOption[];
  rbacRoles: RbacRoleOption[];
  isExpanded?: boolean;
  onCreate: (input: {
    department: string;
    designation: string;
    subDepartment: string;
    onFloorRole: string;
    rbacRoleId: string;
  }) => Promise<SaveResult>;
  onUpdate: (
    id: string,
    input: {
      department: string;
      designation: string;
      subDepartment: string;
      onFloorRole: string;
      rbacRoleId: string;
    },
  ) => Promise<SaveResult>;
  onDelete: (id: string, label: string) => Promise<SaveResult>;
}) {
  const [department, setDepartment] = useState("");
  const [designation, setDesignation] = useState("");
  const [subDepartment, setSubDepartment] = useState("");
  const [onFloorRole, setOnFloorRole] = useState("");
  const [rbacRoleId, setRbacRoleId] = useState("");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [editing, setEditing] = useState<DepartmentHierarchyRow | null>(null);
  const [editDepartment, setEditDepartment] = useState("");
  const [editDesignation, setEditDesignation] = useState("");
  const [editSubDepartment, setEditSubDepartment] = useState("");
  const [editOnFloor, setEditOnFloor] = useState("");
  const [editRbac, setEditRbac] = useState("");
  const [editError, setEditError] = useState<string | null>(null);
  const [editSaving, setEditSaving] = useState(false);
  const [deleting, setDeleting] = useState<DepartmentHierarchyRow | null>(null);

  const departmentSuggestions = useMemo(
    () => uniqueSorted([...departments.map((item) => item.name), ...rows.map((row) => row.department)]),
    [departments, rows],
  );
  const addDesignations = useMemo(
    () => designationNamesFor(department, designations),
    [department, designations],
  );
  const editDesignations = useMemo(
    () => designationNamesFor(editDepartment, designations),
    [editDepartment, designations],
  );
  const addSubDepartments = useMemo(
    () => subDepartmentNamesFor(department, designations, rows),
    [department, designations, rows],
  );
  const editSubDepartments = useMemo(
    () => subDepartmentNamesFor(editDepartment, designations, rows),
    [editDepartment, designations, rows],
  );

  const filtered = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();
    if (!query) return rows;
    return rows.filter((row) =>
      [row.department, row.designation, row.subDepartment, row.onFloorRole, row.rbacRoleDisplayName, row.rbacRoleName]
        .filter(Boolean)
        .some((value) => value!.toLowerCase().includes(query)),
    );
  }, [rows, searchQuery]);

  const duplicate = findHierarchyDuplicate(rows, department, designation);

  const submit = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!department.trim() || !designation.trim() || !subDepartment.trim() || !rbacRoleId) {
      setErrorMsg("Department, Designation, Sub-Department, and Assigned RBAC Role are required.");
      return;
    }
    if (duplicate) {
      setErrorMsg("This designation already exists under that department. Use Edit on the list.");
      return;
    }
    setSaving(true);
    setErrorMsg(null);
    const result = await onCreate({
      department: department.trim(),
      designation: designation.trim(),
      subDepartment: subDepartment.trim(),
      onFloorRole: onFloorRole.trim(),
      rbacRoleId,
    });
    setSaving(false);
    if (result.success) {
      setDepartment("");
      setDesignation("");
      setSubDepartment("");
      setOnFloorRole("");
      setRbacRoleId("");
    } else {
      setErrorMsg(result.error ?? "Could not save this hierarchy.");
    }
  };

  const openEdit = (row: DepartmentHierarchyRow) => {
    setEditing(row);
    setEditDepartment(row.department);
    setEditDesignation(row.designation);
    setEditSubDepartment(row.subDepartment ?? "");
    setEditOnFloor(row.onFloorRole ?? "");
    setEditRbac(row.rbacRoleId ?? "");
    setEditError(null);
  };

  const saveEdit = async () => {
    if (!editing) return;
    if (!editDepartment.trim() || !editDesignation.trim() || !editSubDepartment.trim() || !editRbac) {
      setEditError("Department, Designation, Sub-Department, and Assigned RBAC Role are required.");
      return;
    }
    if (findHierarchyDuplicate(rows, editDepartment, editDesignation, editing.id)) {
      setEditError("Another designation with this name already exists under that department.");
      return;
    }
    setEditSaving(true);
    const result = await onUpdate(editing.id, {
      department: editDepartment.trim(),
      designation: editDesignation.trim(),
      subDepartment: editSubDepartment.trim(),
      onFloorRole: editOnFloor.trim(),
      rbacRoleId: editRbac,
    });
    setEditSaving(false);
    if (result.success) setEditing(null);
    else setEditError(result.error ?? "Could not update this hierarchy.");
  };

  return (
    <div className="flex flex-col rounded-xl border border-border bg-card p-5 shadow-sm">
      <div className="flex items-start justify-between gap-3 border-b border-border/70 pb-3.5">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary">
            <Network className="h-4 w-4" />
          </div>
          <div>
            <h3 className="text-sm font-semibold text-foreground">Department Hierarchy Configuration</h3>
            <p className="text-[11px] text-muted-foreground">
              Designation sits under Department. Sub-Department sits under Designation. Assigned RBAC Role sits under Sub-Department.
            </p>
          </div>
        </div>
        <Badge variant="secondary" className="text-xs font-normal">
          {rows.length} Total
        </Badge>
      </div>

      <form onSubmit={(event) => void submit(event)} className="mt-4 space-y-3">
        {errorMsg && <InlineError message={errorMsg} />}
        {duplicate && !errorMsg && (
          <InlineError message="This designation already exists under that department. Use Edit on the list." />
        )}
        <HierarchyFields
          department={department}
          designation={designation}
          subDepartment={subDepartment}
          rbacRoleId={rbacRoleId}
          onDepartment={setDepartment}
          onDesignation={setDesignation}
          onSubDepartment={setSubDepartment}
          onFloor={setOnFloorRole}
          onRbac={setRbacRoleId}
          departmentSuggestions={departmentSuggestions}
          designationSuggestions={addDesignations}
          subDepartmentSuggestions={addSubDepartments}
          rbacRoles={rbacRoles}
          subDepartmentForDesignation={(name) => storedSubDepartment(department, name, rows)}
        />
        <div className="flex justify-end">
          <Button type="submit" size="sm" className="h-8 gap-1 text-xs" disabled={saving}>
            <Plus className="h-3.5 w-3.5" />
            Submit
          </Button>
        </div>
      </form>

      <MasterList
        title="Existing hierarchy"
        count={filtered.length}
        search={searchQuery}
        onSearch={setSearchQuery}
        placeholder="Filter hierarchy..."
        empty={searchQuery ? "No matching hierarchy rows" : "No department hierarchy configured yet."}
        isExpanded={isExpanded}
      >
        {filtered.map((row) => (
          <div
            key={row.id}
            className="group flex items-center justify-between gap-3 px-3 py-2 text-xs transition-colors hover:bg-muted/40"
          >
            <div className="flex min-w-0 flex-1 flex-wrap items-center gap-1.5">
              <span className="h-1.5 w-1.5 shrink-0 rounded-full bg-primary/60" />
              <span className="font-medium text-foreground">{row.department || "—"}</span>
              <span className="text-muted-foreground">/</span>
              <span className="font-medium text-foreground">{row.designation}</span>
              <span className="text-muted-foreground">/</span>
              <span className="text-foreground">{row.subDepartment || "—"}</span>
              <span className="text-muted-foreground">/</span>
              <Badge variant="secondary" className="px-1.5 py-0 text-[10px] font-normal">
                {row.rbacRoleDisplayName || row.rbacRoleName || "No RBAC role"}
              </Badge>
            </div>
            <RowActions onEdit={() => openEdit(row)} onDelete={() => setDeleting(row)} />
          </div>
        ))}
      </MasterList>

      <Dialog open={editing !== null} onOpenChange={(open) => !open && setEditing(null)}>
        <DialogContent className="sm:max-w-xl">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold">Edit department hierarchy</DialogTitle>
            <DialogDescription className="text-xs">
              Update the department, designation, sub-department, and assigned RBAC role.
            </DialogDescription>
          </DialogHeader>
          {editError && <InlineError message={editError} />}
          <HierarchyFields
            department={editDepartment}
            designation={editDesignation}
            subDepartment={editSubDepartment}
            rbacRoleId={editRbac}
            onDepartment={setEditDepartment}
            onDesignation={setEditDesignation}
            onSubDepartment={setEditSubDepartment}
            onFloor={setEditOnFloor}
            onRbac={setEditRbac}
            departmentSuggestions={departmentSuggestions}
            designationSuggestions={editDesignations}
            subDepartmentSuggestions={editSubDepartments}
            rbacRoles={rbacRoles}
            subDepartmentForDesignation={(name) => storedSubDepartment(editDepartment, name, rows)}
          />
          <DialogFooter>
            <Button type="button" variant="outline" size="sm" className="h-8 text-xs" onClick={() => setEditing(null)}>
              Cancel
            </Button>
            <Button type="button" size="sm" className="h-8 text-xs" disabled={editSaving} onClick={() => void saveEdit()}>
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <AlertDialog open={deleting !== null} onOpenChange={(open) => !open && setDeleting(null)}>
        <AlertDialogContent className="sm:max-w-md">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-sm font-semibold">Delete hierarchy row</AlertDialogTitle>
            <AlertDialogDescription className="text-xs">
              {deleting
                ? `This removes ${deleting.designation} from ${deleting.department || "its department"}. Employees who already have this designation must be moved first.`
                : ""}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="h-8 text-xs">Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="h-8 bg-destructive text-xs text-destructive-foreground hover:bg-destructive/90"
              onClick={() => {
                if (!deleting) return;
                const target = deleting;
                setDeleting(null);
                void onDelete(target.id, target.designation).then((result) => {
                  if (!result.success) toast.error(result.error ?? "Could not delete this hierarchy row.");
                });
              }}
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

function NameMasterCard({
  title,
  singular,
  description,
  placeholder,
  icon: Icon,
  items,
  hasLine,
  isExpanded,
  onCreate,
  onUpdate,
  onDelete,
}: {
  title: string;
  singular: string;
  description: string;
  placeholder: string;
  icon: typeof Network;
  items: Array<NamedMaster | AddressCityMaster>;
  hasLine?: boolean;
  isExpanded?: boolean;
  onCreate: (name: string, line?: string) => Promise<SaveResult>;
  onUpdate: (id: string, name: string, line?: string) => Promise<SaveResult>;
  onDelete: (id: string, name: string) => Promise<SaveResult>;
}) {
  const [name, setName] = useState("");
  const [line, setLine] = useState("");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [editing, setEditing] = useState<(NamedMaster | AddressCityMaster) | null>(null);
  const [editName, setEditName] = useState("");
  const [editLine, setEditLine] = useState("");
  const [editError, setEditError] = useState<string | null>(null);
  const [editSaving, setEditSaving] = useState(false);
  const [deleting, setDeleting] = useState<(NamedMaster | AddressCityMaster) | null>(null);

  const filtered = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();
    if (!query) return items;
    return items.filter((item) => {
      const cityLine = "line" in item ? item.line ?? "" : "";
      return item.name.toLowerCase().includes(query) || cityLine.toLowerCase().includes(query);
    });
  }, [items, searchQuery]);

  const submit = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!name.trim()) {
      setErrorMsg(`Please enter a ${singular.toLowerCase()} name.`);
      return;
    }
    setSaving(true);
    setErrorMsg(null);
    const result = await onCreate(name.trim(), hasLine ? line.trim() : undefined);
    setSaving(false);
    if (result.success) {
      setName("");
      setLine("");
    } else {
      setErrorMsg(result.error ?? "Could not add this item.");
    }
  };

  const openEdit = (item: NamedMaster | AddressCityMaster) => {
    setEditing(item);
    setEditName(item.name);
    setEditLine("line" in item ? item.line ?? "" : "");
    setEditError(null);
  };

  const saveEdit = async () => {
    if (!editing) return;
    if (!editName.trim()) {
      setEditError("Name is required.");
      return;
    }
    setEditSaving(true);
    const result = await onUpdate(editing.id, editName.trim(), hasLine ? editLine.trim() : undefined);
    setEditSaving(false);
    if (result.success) setEditing(null);
    else setEditError(result.error ?? "Could not update this item.");
  };

  return (
    <div className="flex flex-col rounded-xl border border-border bg-card p-5 shadow-sm">
      <div className="flex items-start justify-between gap-3 border-b border-border/70 pb-3.5">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary">
            <Icon className="h-4 w-4" />
          </div>
          <div>
            <h3 className="text-sm font-semibold text-foreground">{title}</h3>
            <p className="text-[11px] text-muted-foreground">{description}</p>
          </div>
        </div>
        <Badge variant="secondary" className="text-xs font-normal">
          {items.length} Total
        </Badge>
      </div>

      <form onSubmit={(event) => void submit(event)} className="mt-4 space-y-2.5">
        {errorMsg && <InlineError message={errorMsg} />}
        <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
          <Input
            placeholder={placeholder}
            value={name}
            onChange={(event) => setName(event.target.value)}
            className="h-8 flex-1 text-xs"
            maxLength={200}
          />
          {hasLine && (
            <Input
              placeholder="Line (optional), e.g. Western Line"
              value={line}
              onChange={(event) => setLine(event.target.value)}
              className="h-8 w-full text-xs sm:w-56"
              maxLength={80}
            />
          )}
          <Button type="submit" size="sm" className="h-8 shrink-0 gap-1 text-xs" disabled={saving}>
            <Plus className="h-3.5 w-3.5" />
            Add {singular}
          </Button>
        </div>
      </form>

      <MasterList
        title={`Existing ${title}`}
        count={filtered.length}
        search={searchQuery}
        onSearch={setSearchQuery}
        placeholder={`Filter ${title.toLowerCase()}...`}
        empty={searchQuery ? "No matching master items found" : `No ${title.toLowerCase()} configured yet.`}
        isExpanded={isExpanded}
      >
        {filtered.map((item) => {
          const cityLine = "line" in item ? item.line : undefined;
          return (
            <div
              key={item.id}
              className="group flex items-center justify-between gap-3 px-3 py-2 text-xs transition-colors hover:bg-muted/40"
            >
              <div className="flex min-w-0 flex-1 items-center gap-2">
                <span className="h-1.5 w-1.5 shrink-0 rounded-full bg-primary/60" />
                <span className="truncate font-medium text-foreground">{item.name}</span>
                {cityLine && (
                  <Badge variant="outline" className="px-1.5 py-0 text-[10px] text-muted-foreground">
                    {cityLine}
                  </Badge>
                )}
              </div>
              <RowActions onEdit={() => openEdit(item)} onDelete={() => setDeleting(item)} />
            </div>
          );
        })}
      </MasterList>

      <Dialog open={editing !== null} onOpenChange={(open) => !open && setEditing(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold">Edit {singular}</DialogTitle>
            <DialogDescription className="text-xs">Update the master value. The list reloads from the database.</DialogDescription>
          </DialogHeader>
          {editError && <InlineError message={editError} />}
          <div className="space-y-3 py-1">
            <div className="space-y-1">
              <span className="text-xs font-medium text-foreground">{singular} Name</span>
              <Input value={editName} onChange={(event) => setEditName(event.target.value)} className="h-8 text-xs" maxLength={200} />
            </div>
            {hasLine && (
              <div className="space-y-1">
                <span className="text-xs font-medium text-foreground">Line (optional)</span>
                <Input value={editLine} onChange={(event) => setEditLine(event.target.value)} className="h-8 text-xs" maxLength={80} />
              </div>
            )}
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" size="sm" className="h-8 text-xs" onClick={() => setEditing(null)}>
              Cancel
            </Button>
            <Button type="button" size="sm" className="h-8 text-xs" disabled={editSaving} onClick={() => void saveEdit()}>
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <AlertDialog open={deleting !== null} onOpenChange={(open) => !open && setDeleting(null)}>
        <AlertDialogContent className="sm:max-w-md">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-sm font-semibold">Delete {singular}</AlertDialogTitle>
            <AlertDialogDescription className="text-xs">
              {deleting
                ? `"${deleting.name}" will leave this master list. Employees who already saved it keep that value.`
                : ""}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="h-8 text-xs">Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="h-8 bg-destructive text-xs text-destructive-foreground hover:bg-destructive/90"
              onClick={() => {
                if (!deleting) return;
                const target = deleting;
                setDeleting(null);
                void onDelete(target.id, target.name).then((result) => {
                  if (!result.success) toast.error(result.error ?? "Could not delete this item.");
                });
              }}
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

function MasterList({
  title,
  count,
  search,
  onSearch,
  placeholder,
  empty,
  isExpanded,
  children,
}: {
  title: string;
  count: number;
  search: string;
  onSearch: (value: string) => void;
  placeholder: string;
  empty: string;
  isExpanded?: boolean;
  children: React.ReactNode;
}) {
  const hasRows = count > 0;
  return (
    <div className="mt-4 space-y-2.5 border-t border-border/60 pt-3">
      <div className="flex items-center justify-between gap-2">
        <span className="text-xs font-medium text-muted-foreground">
          {title} ({count})
        </span>
        <div className="relative w-40 sm:w-48">
          <Search className="absolute left-2 top-1/2 h-3 w-3 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder={placeholder}
            value={search}
            onChange={(event) => onSearch(event.target.value)}
            className="h-7 bg-muted/20 pl-7 text-[11px]"
          />
          {search && (
            <button
              type="button"
              onClick={() => onSearch("")}
              className="absolute right-1.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
            >
              <X className="h-3 w-3" />
            </button>
          )}
        </div>
      </div>
      {hasRows ? (
        <div
          className={cn(
            "divide-y divide-border/60 overflow-y-auto rounded-lg border border-border/80",
            isExpanded ? "max-h-96" : "max-h-64",
          )}
        >
          {children}
        </div>
      ) : (
        <div className="rounded-lg border border-dashed border-border/80 py-6 text-center text-xs text-muted-foreground">
          {empty}
        </div>
      )}
    </div>
  );
}

function RowActions({ onEdit, onDelete }: { onEdit: () => void; onDelete: () => void }) {
  return (
    <div className="flex items-center gap-1 opacity-80 transition-opacity group-hover:opacity-100">
      <Button variant="ghost" size="icon" className="h-6 w-6 text-muted-foreground hover:text-foreground" onClick={onEdit} title="Edit">
        <Pencil className="h-3 w-3" />
      </Button>
      <Button variant="ghost" size="icon" className="h-6 w-6 text-muted-foreground hover:text-destructive" onClick={onDelete} title="Delete">
        <Trash2 className="h-3 w-3" />
      </Button>
    </div>
  );
}

function InlineError({ message }: { message: string }) {
  return (
    <div className="flex items-center gap-1.5 rounded-md border border-destructive/30 bg-destructive/10 px-2.5 py-1.5 text-xs text-destructive">
      <AlertCircle className="h-3.5 w-3.5 shrink-0" />
      <span>{message}</span>
    </div>
  );
}
