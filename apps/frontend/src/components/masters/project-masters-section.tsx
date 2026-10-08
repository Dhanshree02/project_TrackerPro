import { useState, useMemo, useEffect, useRef, useCallback } from "react";
import {
  FolderKanban,
  Plus,
  Search,
  Pencil,
  Trash2,
  Check,
  X,
  Clock,
  AlertCircle,
  FolderPlus,
  Building,
  Wrench,
  ChevronDown,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
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
import { Badge } from "@/components/ui/badge";
import type { ProjectMasterItem } from "@/lib/masters/types";
import { useProjectCatalogStore } from "@/lib/masters/project-catalog-store";
import { fetchServiceHierarchy, type ServiceHierarchyGroup } from "@/lib/api/catalogs";
import { cn } from "@/lib/utils";
import { SearchableSelect } from "@/components/creatable-catalog-select";

interface CreatableSearchDropdownProps {
  id?: string;
  label: string;
  placeholder?: string;
  value: string;
  onChange: (value: string) => void;
  options: string[];
  itemType: string;
  contextHint?: string;
  onEnterSubmit?: () => void;
  autoFocus?: boolean;
}

function CreatableSearchDropdown({
  id,
  label,
  placeholder,
  value,
  onChange,
  options,
  itemType,
  contextHint,
  onEnterSubmit,
  autoFocus,
}: CreatableSearchDropdownProps) {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const trimmedQuery = value.trim().toLowerCase();

  const filteredOptions = useMemo(() => {
    if (!trimmedQuery) return options;
    return options.filter((opt) => opt.toLowerCase().includes(trimmedQuery));
  }, [options, trimmedQuery]);

  const isDuplicate = useMemo(() => {
    if (!trimmedQuery) return false;
    return options.some((opt) => opt.toLowerCase().trim() === trimmedQuery);
  }, [options, trimmedQuery]);

  return (
    <div className="space-y-1.5 relative" ref={containerRef}>
      <div className="flex items-center justify-between">
        <Label htmlFor={id} className="text-xs font-medium">
          {label} <span className="text-destructive">*</span>
        </Label>
        <span className="text-[11px] text-muted-foreground font-normal">
          {options.length} existing {itemType.toLowerCase()}{options.length === 1 ? "" : "s"}
        </span>
      </div>

      <div className="relative">
        <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground pointer-events-none" />
        <Input
          ref={inputRef}
          id={id}
          placeholder={placeholder}
          value={value}
          autoFocus={autoFocus}
          onChange={(e) => {
            onChange(e.target.value);
            if (!isOpen) setIsOpen(true);
          }}
          onFocus={() => setIsOpen(true)}
          onKeyDown={(e) => {
            if (e.key === "Enter") {
              e.preventDefault();
              if (!isDuplicate && value.trim()) {
                onEnterSubmit?.();
              }
            } else if (e.key === "Escape") {
              setIsOpen(false);
            }
          }}
          className={cn(
            "h-9 text-xs pl-8 pr-14",
            isDuplicate && "border-destructive focus-visible:ring-destructive"
          )}
        />
        <div className="absolute right-1.5 top-1/2 -translate-y-1/2 flex items-center gap-0.5">
          {value && (
            <button
              type="button"
              tabIndex={-1}
              onMouseDown={(e) => e.preventDefault()}
              onClick={() => {
                onChange("");
                inputRef.current?.focus();
              }}
              className="p-1 text-muted-foreground hover:text-foreground transition-colors rounded-sm"
              title="Clear input"
            >
              <X className="h-3.5 w-3.5" />
            </button>
          )}
          <button
            type="button"
            tabIndex={-1}
            onMouseDown={(e) => e.preventDefault()}
            onClick={() => {
              setIsOpen((prev) => !prev);
              inputRef.current?.focus();
            }}
            className="p-1 text-muted-foreground hover:text-foreground transition-colors rounded-sm"
            title={`Toggle existing ${itemType.toLowerCase()}s`}
          >
            <ChevronDown className={cn("h-3.5 w-3.5 transition-transform duration-150", isOpen && "rotate-180")} />
          </button>
        </div>
      </div>

      {isOpen && (
        <div className="rounded-lg border border-border/80 bg-muted/20 text-foreground shadow-sm overflow-hidden animate-in fade-in-50 duration-100">
          <div className="px-3 py-1.5 border-b border-border/60 bg-muted/50 flex items-center justify-between text-[11px] font-medium text-muted-foreground">
            <span>
              {trimmedQuery ? `Matches for "${value.trim()}":` : `Existing ${itemType}s:`} ({filteredOptions.length})
            </span>
            <span className="text-[10px] text-muted-foreground/80">Click to select</span>
          </div>

          <div className="max-h-40 overflow-y-auto p-1 divide-y divide-border/20 text-xs">
            {filteredOptions.length > 0 ? (
              filteredOptions.map((opt) => {
                const isExact = opt.toLowerCase().trim() === trimmedQuery;
                return (
                  <button
                    key={opt}
                    type="button"
                    onMouseDown={(e) => e.preventDefault()}
                    onClick={() => {
                      onChange(opt);
                    }}
                    className={cn(
                      "w-full text-left px-2.5 py-1.5 rounded-md flex items-center justify-between text-xs transition-colors",
                      isExact
                        ? "bg-destructive/15 text-destructive font-semibold"
                        : "hover:bg-muted text-foreground"
                    )}
                  >
                    <span className="truncate">{opt}</span>
                    {isExact && (
                      <span className="text-[10px] font-semibold text-destructive shrink-0 ml-2 px-1.5 py-0.5 rounded bg-destructive/15 border border-destructive/30">
                        Already Exists
                      </span>
                    )}
                  </button>
                );
              })
            ) : options.length === 0 ? (
              <div className="p-3 text-center text-xs text-muted-foreground">
                No existing {itemType.toLowerCase()}s found.
                <div className="text-[11px] text-primary font-medium mt-0.5">
                  Type a name and click Add to create the first one!
                </div>
              </div>
            ) : (
              <div className="p-3 text-center text-xs text-muted-foreground">
                No existing {itemType.toLowerCase()} matches &quot;{value.trim()}&quot;.
                <div className="text-[11px] text-primary font-medium mt-0.5">
                  ✓ You can add this as a new {itemType.toLowerCase()}!
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      {isDuplicate && (
        <div className="flex items-center gap-1.5 text-[11px] text-destructive font-medium pt-0.5 animate-in fade-in duration-100">
          <AlertCircle className="h-3.5 w-3.5 shrink-0" />
          <span>
            {itemType} &quot;{value.trim()}&quot; already exists{contextHint ? ` ${contextHint}` : ""}. You cannot add duplicate data.
          </span>
        </div>
      )}
    </div>
  );
}

interface ProjectMastersSectionProps {
  canManage?: boolean;
  items: ProjectMasterItem[];
  contractTypes?: string[];
  groups?: string[];
  departments?: string[];
  subDepartments?: string[];
  services?: string[];
  onAdd: (item: Omit<ProjectMasterItem, "id" | "createdAt">) => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
  onUpdate: (id: string, item: Omit<ProjectMasterItem, "id" | "createdAt">) => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
  onDelete: (id: string) => void | Promise<void>;
  onAddContractType?: (name: string) => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
  onAddDepartment?: (name: string, group?: "Resource" | "Scope") => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
  onAddSubDepartment?: (dept: string, subDept: string) => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
  onAddService?: (dept: string, service: { name: string; tool?: string; unitPrice?: number; days?: number; subDept?: string }) => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
}

export function ProjectMastersSection({
  canManage = true,
  items,
  contractTypes: propsContractTypes,
  groups: propsGroups,
  departments: propsDepartments,
  subDepartments: propsSubDepartments,
  services: propsServices,
  onAdd,
  onUpdate,
  onDelete,
  onAddContractType,
  onAddDepartment,
  onAddSubDepartment,
  onAddService,
}: ProjectMastersSectionProps) {
  // Shared catalog store
  const {
    contractTypes: storeContractTypes,
    departments: storeDepartments,
    deptServices,
    allServices: storeAllServices,
    addContractType: storeAddContractType,
    addDepartment: storeAddDepartment,
    addSubDepartment: storeAddSubDepartment,
    addService: storeAddService,
    getServicesForDepartment,
    getSubDepartmentsForDepartment,
  } = useProjectCatalogStore();

  // Live database hierarchy fetched from mst_service_groups -> mst_service_departments -> mst_service_sub_departments -> mst_service_catalog
  const [hierarchy, setHierarchy] = useState<ServiceHierarchyGroup[]>([]);
  const [isLoadingHierarchy, setIsLoadingHierarchy] = useState(false);

  useEffect(() => {
    let active = true;
    setIsLoadingHierarchy(true);
    fetchServiceHierarchy()
      .then((data) => {
        if (active && data && data.length > 0) {
          setHierarchy(data);
        }
      })
      .catch((err) => {
        console.warn("Could not load service hierarchy, falling back to local masters:", err);
      })
      .finally(() => {
        if (active) setIsLoadingHierarchy(false);
      });
    return () => {
      active = false;
    };
  }, []);

  const reloadHierarchy = useCallback(async () => {
    try {
      const data = await fetchServiceHierarchy();
      if (data && data.length > 0) {
        setHierarchy(data);
      }
    } catch (e) {
      console.warn("Could not reload service hierarchy:", e);
    }
  }, []);

  // Form State for new entry
  const [selectedContractType, setSelectedContractType] = useState<string>("");
  const [selectedDepartment, setSelectedDepartment] = useState<string>("");
  const [selectedSubDepartment, setSelectedSubDepartment] = useState<string>("");
  const [selectedService, setSelectedService] = useState<string>("");
  const [tools, setTools] = useState<string>("");
  const [duration, setDuration] = useState<string>("");
  const [unitPrice, setUnitPrice] = useState<string>("");
  const [formError, setFormError] = useState<string | null>(null);

  // Search & Filter State
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [filterContractType, setFilterContractType] = useState<string>("all");

  // Edit Modal State
  const [editingItem, setEditingItem] = useState<ProjectMasterItem | null>(null);
  const [editContractType, setEditContractType] = useState<string>("");
  const [editDepartment, setEditDepartment] = useState<string>("");
  const [editSubDepartment, setEditSubDepartment] = useState<string>("");
  const [editService, setEditService] = useState<string>("");
  const [editTools, setEditTools] = useState<string>("");
  const [editDuration, setEditDuration] = useState<string>("");
  const [editUnitPrice, setEditUnitPrice] = useState<string>("");
  const [editError, setEditError] = useState<string | null>(null);

  // Delete Dialog State
  const [deletingId, setDeletingId] = useState<string | null>(null);

  // --- Add New Value Modal States ---
  // 1. Contract Type Modal
  const [showAddContractTypeModal, setShowAddContractTypeModal] = useState(false);
  const [newContractTypeName, setNewContractTypeName] = useState("");
  const [addContractTypeError, setAddContractTypeError] = useState<string | null>(null);

  // 2. Department Modal
  const [showAddDepartmentModal, setShowAddDepartmentModal] = useState(false);
  const [newDepartmentName, setNewDepartmentName] = useState("");
  const [newDeptGroup, setNewDeptGroup] = useState<"Scope" | "Resource">("Scope");
  const [addDepartmentError, setAddDepartmentError] = useState<string | null>(null);

  // 3. Sub-Department Modal
  const [showAddSubDepartmentModal, setShowAddSubDepartmentModal] = useState(false);
  const [newSubDeptTargetDept, setNewSubDeptTargetDept] = useState("");
  const [newSubDepartmentName, setNewSubDepartmentName] = useState("");
  const [addSubDepartmentError, setAddSubDepartmentError] = useState<string | null>(null);

  // 4. Service Modal State
  const [showAddServiceModal, setShowAddServiceModal] = useState(false);
  const [newServiceName, setNewServiceName] = useState("");
  const [addServiceError, setAddServiceError] = useState<string | null>(null);

  // 1. Contract Types fetched from mst_service_groups
  const availableContractTypes = useMemo(() => {
    if (hierarchy.length > 0) {
      return hierarchy.map((g) => g.name);
    }
    const raw = propsContractTypes || storeContractTypes || propsGroups || [];
    return raw.length > 0 ? raw : ["Scope", "Resource"];
  }, [hierarchy, propsContractTypes, storeContractTypes, propsGroups]);

  // All departments in hierarchy + store + props + items without group filtering (for dialogs, etc.)
  const allDepartmentsList = useMemo(() => {
    const map = new Map<string, string>();
    if (hierarchy.length > 0) {
      hierarchy.forEach((g) =>
        g.departments.forEach((d) => {
          if (d.name && !map.has(d.name.toLowerCase().trim())) {
            map.set(d.name.toLowerCase().trim(), d.name.trim());
          }
        })
      );
    }
    (propsDepartments || []).forEach((d) => {
      if (d && !map.has(d.toLowerCase().trim())) map.set(d.toLowerCase().trim(), d.trim());
    });
    (storeDepartments || []).forEach((d) => {
      if (d && !map.has(d.toLowerCase().trim())) map.set(d.toLowerCase().trim(), d.trim());
    });
    Object.keys(deptServices || {}).forEach((d) => {
      if (d && !map.has(d.toLowerCase().trim())) map.set(d.toLowerCase().trim(), d.trim());
    });
    items.forEach((it) => {
      if (it.department && !map.has(it.department.toLowerCase().trim())) {
        map.set(it.department.toLowerCase().trim(), it.department.trim());
      }
    });
    return Array.from(map.values()).sort((a, b) => a.localeCompare(b));
  }, [hierarchy, propsDepartments, storeDepartments, deptServices, items]);

  // 2. Departments fetched from mst_service_departments (optionally filtered by mst_service_group)
  const availableDepartments = useMemo(() => {
    if (hierarchy.length > 0 && selectedContractType) {
      const normCt = selectedContractType.toLowerCase().replace(" based", "").trim();
      const matchedGroup = hierarchy.find(
        (g) =>
          g.name.toLowerCase().trim() === normCt ||
          g.name.toLowerCase().includes(normCt) ||
          normCt.includes(g.name.toLowerCase().trim())
      );
      if (matchedGroup && matchedGroup.departments.length > 0) {
        const groupDepts = new Map<string, string>();
        matchedGroup.departments.forEach((d) => {
          if (d.name && !groupDepts.has(d.name.toLowerCase().trim())) {
            groupDepts.set(d.name.toLowerCase().trim(), d.name.trim());
          }
        });
        items.forEach((it) => {
          const itemCt = (it.contractType || it.group || "").toLowerCase().replace(" based", "").trim();
          if (itemCt === normCt && it.department && !groupDepts.has(it.department.toLowerCase().trim())) {
            groupDepts.set(it.department.toLowerCase().trim(), it.department.trim());
          }
        });
        return Array.from(groupDepts.values()).sort((a, b) => a.localeCompare(b));
      }
    }
    return allDepartmentsList;
  }, [hierarchy, selectedContractType, allDepartmentsList, items]);

  // 3. Sub-Departments fetched from mst_service_sub_departments for selected Department
  const activeSubDeptTarget = selectedDepartment || newSubDeptTargetDept;
  const availableSubDepartmentsForDept = useMemo(() => {
    if (!activeSubDeptTarget) return [];
    const map = new Map<string, string>();
    if (hierarchy.length > 0) {
      for (const group of hierarchy) {
        const foundDept = group.departments.find(
          (d) => d.name.toLowerCase().trim() === activeSubDeptTarget.toLowerCase().trim()
        );
        if (foundDept && foundDept.subDepartments) {
          foundDept.subDepartments.forEach((s) => {
            if (s.name && !map.has(s.name.toLowerCase().trim())) {
              map.set(s.name.toLowerCase().trim(), s.name.trim());
            }
          });
        }
      }
    }
    const fromStore = getSubDepartmentsForDepartment(activeSubDeptTarget);
    fromStore.forEach((s) => {
      if (s && !map.has(s.toLowerCase().trim())) map.set(s.toLowerCase().trim(), s.trim());
    });
    (propsSubDepartments || []).forEach((s) => {
      if (s && !map.has(s.toLowerCase().trim())) map.set(s.toLowerCase().trim(), s.trim());
    });
    items.forEach((it) => {
      if (
        it.department.toLowerCase().trim() === activeSubDeptTarget.toLowerCase().trim() &&
        it.subDepartment &&
        !map.has(it.subDepartment.toLowerCase().trim())
      ) {
        map.set(it.subDepartment.toLowerCase().trim(), it.subDepartment.trim());
      }
    });
    return Array.from(map.values()).sort((a, b) => a.localeCompare(b));
  }, [hierarchy, activeSubDeptTarget, getSubDepartmentsForDepartment, propsSubDepartments, items]);

  // 4. Services fetched from mst_service_catalog for selected Department & Sub-Department
  const catalogServicesForDept = useMemo(() => {
    if (!selectedDepartment) return [];
    const svcMap = new Map<string, { id?: string; name: string; tool: string; unitPrice: number; days: number; subDept?: string }>();
    if (hierarchy.length > 0) {
      for (const group of hierarchy) {
        const foundDept = group.departments.find(
          (d) => d.name.toLowerCase() === selectedDepartment.toLowerCase()
        );
        if (foundDept) {
          if (selectedSubDepartment) {
            const foundSub = foundDept.subDepartments.find(
              (s) => s.name.toLowerCase() === selectedSubDepartment.toLowerCase()
            );
            if (foundSub) {
              foundSub.services.forEach((svc) => {
                svcMap.set(svc.name.toLowerCase().trim(), {
                  id: svc.id,
                  name: svc.name,
                  tool: svc.defaultTools || "",
                  unitPrice: svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 50000,
                  days: svc.defaultDurationDays || 5,
                  subDept: foundSub.name,
                });
              });
            }
          } else {
            foundDept.subDepartments.forEach((sub) => {
              sub.services.forEach((svc) => {
                svcMap.set(svc.name.toLowerCase().trim(), {
                  id: svc.id,
                  name: svc.name,
                  tool: svc.defaultTools || "",
                  unitPrice: svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 50000,
                  days: svc.defaultDurationDays || 5,
                  subDept: sub.name,
                });
              });
            });
          }
        }
      }
    }

    const storeSvcs = getServicesForDepartment(selectedDepartment, selectedSubDepartment || undefined);
    storeSvcs.forEach((svc) => {
      if (!svcMap.has(svc.name.toLowerCase().trim())) {
        svcMap.set(svc.name.toLowerCase().trim(), svc);
      }
    });

    items.forEach((it) => {
      if (
        it.department.toLowerCase().trim() === selectedDepartment.toLowerCase().trim() &&
        (!selectedSubDepartment || (it.subDepartment || "").toLowerCase().trim() === selectedSubDepartment.toLowerCase().trim()) &&
        it.service &&
        !svcMap.has(it.service.toLowerCase().trim())
      ) {
        svcMap.set(it.service.toLowerCase().trim(), {
          name: it.service,
          tool: it.tools || "",
          unitPrice: it.unitPrice || 50000,
          days: parseInt(it.duration.replace(/\D/g, ""), 10) || 5,
          subDept: it.subDepartment,
        });
      }
    });

    return Array.from(svcMap.values());
  }, [hierarchy, selectedDepartment, selectedSubDepartment, getServicesForDepartment, items]);

  // Filtered service names for dropdown
  const filteredServicesForDept = useMemo(() => {
    let list: string[] = [];
    if (catalogServicesForDept.length > 0) {
      list = catalogServicesForDept.map((s) => s.name);
    } else {
      list = propsServices || storeAllServices || [];
    }
    if (selectedService && !list.some((s) => s.toLowerCase().trim() === selectedService.toLowerCase().trim())) {
      list = [selectedService, ...list];
    }
    return Array.from(new Set(list));
  }, [catalogServicesForDept, propsServices, storeAllServices, selectedService]);


  // Sub-departments for Edit Modal
  const availableSubDepartmentsForEditDept = useMemo(() => {
    if (!editDepartment) return [];
    if (hierarchy.length > 0) {
      for (const group of hierarchy) {
        const foundDept = group.departments.find(
          (d) => d.name.toLowerCase() === editDepartment.toLowerCase()
        );
        if (foundDept && foundDept.subDepartments.length > 0) {
          return foundDept.subDepartments.map((s) => s.name);
        }
      }
    }
    return getSubDepartmentsForDepartment(editDepartment);
  }, [hierarchy, editDepartment, getSubDepartmentsForDepartment]);

  // Catalog services for Edit Modal
  const catalogServicesForEditDept = useMemo(() => {
    if (!editDepartment) return [];
    if (hierarchy.length > 0) {
      for (const group of hierarchy) {
        const foundDept = group.departments.find(
          (d) => d.name.toLowerCase() === editDepartment.toLowerCase()
        );
        if (foundDept) {
          if (editSubDepartment) {
            const foundSub = foundDept.subDepartments.find(
              (s) => s.name.toLowerCase() === editSubDepartment.toLowerCase()
            );
            if (foundSub) {
              return foundSub.services.map((svc) => ({
                id: svc.id,
                name: svc.name,
                tool: svc.defaultTools || "",
                unitPrice: svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 50000,
                days: svc.defaultDurationDays || 5,
                subDept: foundSub.name,
              }));
            }
          }
          return foundDept.subDepartments.flatMap((sub) =>
            sub.services.map((svc) => ({
              id: svc.id,
              name: svc.name,
              tool: svc.defaultTools || "",
              unitPrice: svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 50000,
              days: svc.defaultDurationDays || 5,
              subDept: sub.name,
            }))
          );
        }
      }
    }
    return getServicesForDepartment(editDepartment, editSubDepartment || undefined);
  }, [hierarchy, editDepartment, editSubDepartment, getServicesForDepartment]);

  // Authoritative items derived directly from PostgreSQL database (projectMasters items prop, with fallback to hierarchy)
  const effectiveItems = useMemo(() => {
    if (items && items.length > 0) {
      return items;
    }
    if (hierarchy && hierarchy.length > 0) {
      const list: ProjectMasterItem[] = [];
      for (const group of hierarchy) {
        for (const dept of group.departments) {
          if (!dept.subDepartments || dept.subDepartments.length === 0) {
            list.push({
              id: dept.id,
              contractType: group.name,
              group: group.name,
              department: dept.name,
              subDepartment: "—",
              service: "—",
              tools: "—",
              duration: "—",
              unitPrice: 0,
              createdAt: new Date().toISOString(),
            });
          } else {
            for (const sub of dept.subDepartments) {
              if (!sub.services || sub.services.length === 0) {
                list.push({
                  id: sub.id,
                  contractType: group.name,
                  group: group.name,
                  department: dept.name,
                  subDepartment: sub.name,
                  service: "—",
                  tools: "—",
                  duration: "—",
                  unitPrice: 0,
                  createdAt: new Date().toISOString(),
                });
              } else {
                for (const svc of sub.services) {
                  list.push({
                    id: svc.id,
                    contractType: group.name,
                    group: group.name,
                    department: dept.name,
                    subDepartment: sub.name,
                    service: svc.name,
                    tools: svc.defaultTools || "—",
                    duration: svc.defaultDurationDays ? `${svc.defaultDurationDays} Days` : "5 Days",
                    unitPrice: svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 50000,
                    createdAt: new Date().toISOString(),
                  });
                }
              }
            }
          }
        }
      }
      return list;
    }
    return items;
  }, [hierarchy, items]);

  // Filtered Items for Table directly sourced from PostgreSQL
  const filteredItems = useMemo(() => {
    return effectiveItems.filter((item) => {
      const itemContractType = item.contractType || item.group || "";
      const matchesSearch =
        searchQuery === "" ||
        itemContractType.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.department.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (item.subDepartment && item.subDepartment.toLowerCase().includes(searchQuery.toLowerCase())) ||
        item.service.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.tools.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.duration.toLowerCase().includes(searchQuery.toLowerCase());

      const normFilter = filterContractType.toLowerCase().replace(" based", "").trim();
      const normItem = itemContractType.toLowerCase().replace(" based", "").trim();

      const matchesContractType =
        filterContractType === "all" ||
        itemContractType === filterContractType ||
        normItem === normFilter ||
        normItem.includes(normFilter) ||
        normFilter.includes(normItem);

      return matchesSearch && matchesContractType;
    });
  }, [effectiveItems, searchQuery, filterContractType]);

  // Contract Type change handler -> strictly resets department, sub-department, and service
  const handleContractTypeChange = (ct: string) => {
    setSelectedContractType(ct);
    setSelectedDepartment("");
    setSelectedSubDepartment("");
    setSelectedService("");
    setTools("");
    setDuration("");
    setUnitPrice("");
  };

  // Department change handler -> strictly resets sub-department and service
  const handleDepartmentChange = (dept: string) => {
    setSelectedDepartment(dept);
    setSelectedSubDepartment("");
    setSelectedService("");
    setTools("");
    setDuration("");
    setUnitPrice("");
  };

  // Sub-Department change handler -> strictly resets service
  const handleSubDepartmentChange = (subDept: string) => {
    setSelectedSubDepartment(subDept);
    setSelectedService("");
    setTools("");
    setDuration("");
    setUnitPrice("");
  };

  // Service change handler -> auto-populates tools, duration, unitPrice from mst_service_catalog
  const handleServiceChange = (serviceName: string) => {
    setSelectedService(serviceName);
    const matched = catalogServicesForDept.find((s) => s.name === serviceName);
    if (matched) {
      if (matched.subDept && !selectedSubDepartment) {
        setSelectedSubDepartment(matched.subDept);
      }
      setTools(matched.tool || "");
      setUnitPrice(String(matched.unitPrice || "50000"));
      setDuration(`${matched.days || 5} Days`);
    }
  };

  // ── Save New Contract Type ────────────────────────────────────────────────
  const handleSaveNewContractType = () => {
    setAddContractTypeError(null);
    const trimmed = newContractTypeName.trim();
    if (!trimmed) {
      setAddContractTypeError("Contract Type name is required.");
      return;
    }
    const isDup = availableContractTypes.some((c) => c.toLowerCase().trim() === trimmed.toLowerCase());
    if (isDup) {
      setAddContractTypeError(`Contract Type "${trimmed}" already exists.`);
      return;
    }
    const adder = onAddContractType || storeAddContractType;
    const res = adder(trimmed);
    if (res.success) {
      setSelectedContractType(trimmed);
      setShowAddContractTypeModal(false);
      setNewContractTypeName("");
    } else {
      setAddContractTypeError(res.error || "Failed to add Contract Type.");
    }
  };

  // ── Save New Department ───────────────────────────────────────────────────
  const handleSaveNewDepartment = async () => {
    setAddDepartmentError(null);
    const trimmed = newDepartmentName.trim();
    if (!trimmed) {
      setAddDepartmentError("Department name is required.");
      return;
    }

    // Check duplicate against all known departments (case-insensitive)
    const existingDepts = new Set<string>();
    allDepartmentsList.forEach((d) => existingDepts.add(d.toLowerCase().trim()));
    availableDepartments.forEach((d) => existingDepts.add(d.toLowerCase().trim()));
    if (storeDepartments) {
      storeDepartments.forEach((d) => existingDepts.add(d.toLowerCase().trim()));
    }
    if (propsDepartments) {
      propsDepartments.forEach((d) => existingDepts.add(d.toLowerCase().trim()));
    }
    if (hierarchy.length > 0) {
      hierarchy.forEach((g) =>
        g.departments.forEach((d) => existingDepts.add(d.name.toLowerCase().trim()))
      );
    }
    Object.keys(deptServices).forEach((d) => existingDepts.add(d.toLowerCase().trim()));

    if (existingDepts.has(trimmed.toLowerCase())) {
      setAddDepartmentError(`Department "${trimmed}" already exists. Please enter a different name.`);
      return;
    }

    const adder = onAddDepartment || storeAddDepartment;
    const res = await Promise.resolve(adder(trimmed, newDeptGroup));
    if (res.success) {
      setSelectedDepartment(trimmed);
      setSelectedSubDepartment("");
      setShowAddDepartmentModal(false);
      setNewDepartmentName("");
      reloadHierarchy();
    } else {
      setAddDepartmentError(res.error || "Failed to add Department.");
    }
  };

  // ── Save New Sub-Department ───────────────────────────────────────────────
  const handleSaveNewSubDepartment = async () => {
    setAddSubDepartmentError(null);
    const targetDept = (newSubDeptTargetDept || selectedDepartment || "").trim();
    if (!targetDept) {
      setAddSubDepartmentError("Please select a Department first.");
      return;
    }
    const trimmed = newSubDepartmentName.trim();
    if (!trimmed) {
      setAddSubDepartmentError("Sub Department name is required.");
      return;
    }

    // Check duplicate against existing sub-departments for target department (case-insensitive)
    const existingSubs = new Set<string>();
    // From hierarchy
    if (hierarchy.length > 0) {
      for (const group of hierarchy) {
        const foundDept = group.departments.find(
          (d) => d.name.toLowerCase().trim() === targetDept.toLowerCase()
        );
        if (foundDept) {
          foundDept.subDepartments.forEach((s) => existingSubs.add(s.name.toLowerCase().trim()));
        }
      }
    }
    // From store
    getSubDepartmentsForDepartment(targetDept).forEach((s) => existingSubs.add(s.toLowerCase().trim()));
    // If selectedDepartment matches targetDept, check availableSubDepartmentsForDept
    if (selectedDepartment && selectedDepartment.toLowerCase().trim() === targetDept.toLowerCase()) {
      availableSubDepartmentsForDept.forEach((s) => existingSubs.add(s.toLowerCase().trim()));
    }
    items.forEach((it) => {
      if (it.department.toLowerCase().trim() === targetDept.toLowerCase() && it.subDepartment) {
        existingSubs.add(it.subDepartment.toLowerCase().trim());
      }
    });

    if (existingSubs.has(trimmed.toLowerCase())) {
      setAddSubDepartmentError(`Sub-Department "${trimmed}" already exists in ${targetDept}. Please enter a different name.`);
      return;
    }

    const adder = onAddSubDepartment || storeAddSubDepartment;
    const res = await Promise.resolve(adder(targetDept, trimmed));
    if (res.success) {
      setSelectedDepartment(targetDept);
      setSelectedSubDepartment(trimmed);
      setShowAddSubDepartmentModal(false);
      setNewSubDepartmentName("");
      reloadHierarchy();
    } else {
      setAddSubDepartmentError(res.error || "Failed to add Sub-Department.");
    }
  };

  // ── Save New Service ──────────────────────────────────────────────────────
  const handleSaveNewService = async () => {
    setAddServiceError(null);
    const targetDept = selectedDepartment.trim();
    const trimmed = newServiceName.trim();

    if (!targetDept) {
      setAddServiceError("Please select a Department first.");
      return;
    }
    if (!trimmed) {
      setAddServiceError("Service name is required.");
      return;
    }

    // Check duplicate against existing services for target department (case-insensitive)
    const existingServices = new Set<string>();
    if (hierarchy.length > 0) {
      for (const group of hierarchy) {
        const foundDept = group.departments.find(
          (d) => d.name.toLowerCase().trim() === targetDept.toLowerCase()
        );
        if (foundDept) {
          foundDept.subDepartments.forEach((sub) => {
            sub.services.forEach((svc) => existingServices.add(svc.name.toLowerCase().trim()));
          });
        }
      }
    }
    getServicesForDepartment(targetDept).forEach((s) => existingServices.add(s.name.toLowerCase().trim()));
    catalogServicesForDept.forEach((s) => existingServices.add(s.name.toLowerCase().trim()));
    filteredServicesForDept.forEach((s) => existingServices.add(s.toLowerCase().trim()));
    items.forEach((it) => {
      if (it.department.toLowerCase().trim() === targetDept.toLowerCase() && it.service) {
        existingServices.add(it.service.toLowerCase().trim());
      }
    });

    if (existingServices.has(trimmed.toLowerCase())) {
      setAddServiceError(`Service "${trimmed}" already exists in ${targetDept}. Please enter a different name.`);
      return;
    }

    const adder = onAddService || storeAddService;
    const res = await Promise.resolve(
      adder(targetDept, {
        name: trimmed,
        tool: tools.trim() || undefined,
        unitPrice: unitPrice ? parseFloat(unitPrice) : undefined,
        days: duration ? parseInt(duration.replace(/\D/g, ""), 10) : undefined,
        subDept: (selectedSubDepartment || "").trim() || undefined,
      })
    );
    if (res.success) {
      setSelectedService(trimmed);
      setShowAddServiceModal(false);
      setNewServiceName("");
      reloadHierarchy();
    } else {
      setAddServiceError(res.error || "Failed to add Service.");
    }
  };

  // Handle Add Submit (Save Master)
  const handleAddSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);

    const priceNum = Number(unitPrice);
    if (!selectedContractType) {
      setFormError("Please select a Contract Type.");
      return;
    }
    if (!selectedDepartment) {
      setFormError("Please select a Department.");
      return;
    }
    if (!selectedService.trim()) {
      setFormError("Please select or enter a Service.");
      return;
    }
    if (!tools.trim()) {
      setFormError("Please specify the Tools/Technologies.");
      return;
    }
    if (!duration.trim()) {
      setFormError("Please enter standard Duration.");
      return;
    }
    if (!unitPrice.trim() || Number.isNaN(priceNum) || priceNum <= 0) {
      setFormError("Please enter a valid numeric Unit Price (greater than 0).");
      return;
    }

    const targetDept = selectedDepartment.trim();
    const trimmedService = selectedService.trim();

    // Pre-validate duplicate against existing project masters items
    const isDuplicate = items.some(
      (p) =>
        (p.contractType || p.group || "").toLowerCase().trim() === selectedContractType.toLowerCase().trim() &&
        p.department.toLowerCase().trim() === targetDept.toLowerCase() &&
        (p.subDepartment || "").toLowerCase().trim() === selectedSubDepartment.toLowerCase().trim() &&
        p.service.toLowerCase().trim() === trimmedService.toLowerCase()
    );
    if (isDuplicate) {
      const subText = selectedSubDepartment.trim() ? ` → ${selectedSubDepartment.trim()}` : "";
      setFormError(
        `A project master for ${selectedContractType} → ${targetDept}${subText} → ${trimmedService} already exists.`
      );
      return;
    }

    // If newly entered service not in catalog, also save it to catalog with the tools, price, duration, and sub-department entered!
    const serviceExistsInCatalog = catalogServicesForDept.some(
      (s) => s.name.toLowerCase().trim() === trimmedService.toLowerCase()
    );
    if (!serviceExistsInCatalog) {
      const adder = onAddService || storeAddService;
      const parsedDays = parseInt(duration.replace(/\D/g, ""), 10);
      await Promise.resolve(
        adder(targetDept, {
          name: trimmedService,
          tool: tools.trim(),
          unitPrice: priceNum,
          days: !Number.isNaN(parsedDays) && parsedDays > 0 ? parsedDays : 5,
          subDept: selectedSubDepartment.trim() || undefined,
        })
      );
    }

    const res = await Promise.resolve(
      onAdd({
        contractType: selectedContractType,
        group: selectedContractType,
        department: targetDept,
        subDepartment: selectedSubDepartment.trim() || undefined,
        service: trimmedService,
        tools: tools.trim(),
        duration: duration.trim(),
        unitPrice: priceNum,
      })
    );

    if (res.success) {
      // Clear inputs
      setSelectedService("");
      setTools("");
      setDuration("");
      setUnitPrice("");
      setSelectedSubDepartment("");
      setFormError(null);
      reloadHierarchy();
    } else {
      setFormError(res.error || "Failed to add project master.");
    }
  };

  // Open Edit Modal
  const openEditModal = (item: ProjectMasterItem) => {
    setEditingItem(item);
    setEditContractType(item.contractType || item.group || "");
    setEditDepartment(item.department);
    setEditSubDepartment(item.subDepartment || "");
    setEditService(item.service);
    setEditTools(item.tools);
    setEditDuration(item.duration);
    setEditUnitPrice(String(item.unitPrice));
    setEditError(null);
  };

  // Handle Edit Submit
  const handleEditSubmit = async () => {
    if (!editingItem) return;
    setEditError(null);

    const priceNum = Number(editUnitPrice);
    if (!editContractType) {
      setEditError("Please select a Contract Type.");
      return;
    }
    if (!editDepartment) {
      setEditError("Please select a Department.");
      return;
    }
    if (!editService) {
      setEditError("Please select a Service.");
      return;
    }
    if (!editTools.trim()) {
      setEditError("Please specify Tools.");
      return;
    }
    if (!editDuration.trim()) {
      setEditError("Please specify Duration.");
      return;
    }
    if (!editUnitPrice.trim() || Number.isNaN(priceNum) || priceNum <= 0) {
      setEditError("Please enter a valid positive numeric Unit Price.");
      return;
    }

    const res = await Promise.resolve(
      onUpdate(editingItem.id, {
        contractType: editContractType,
        group: editContractType,
        department: editDepartment,
        subDepartment: editSubDepartment.trim() || undefined,
        service: editService,
        tools: editTools.trim(),
        duration: editDuration.trim(),
        unitPrice: priceNum,
      })
    );

    if (res.success) {
      setEditingItem(null);
      reloadHierarchy();
    } else {
      setEditError(res.error || "Failed to update master.");
    }
  };

  return (
    <div className="space-y-6">
      {/* ── Top Add Form (Project Masters Configuration) ───────────────── */}
      {canManage && (
      <div className="rounded-xl border border-border bg-card p-5 shadow-sm">
        <div className="flex items-center justify-between pb-4 mb-4 border-b border-border/70">
          <div className="flex items-center gap-2.5">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10 text-primary">
              <FolderKanban className="h-4 w-4" />
            </div>
            <div>
              <h2 className="text-sm font-semibold text-foreground">Project Master Configuration</h2>
              <p className="text-xs text-muted-foreground">
                Define standardized delivery packages, department mappings, tools, and billing rates from Project Onboarding Form
              </p>
            </div>
          </div>
          <Badge variant="secondary" className="text-xs font-normal">
            {items.length} Configured
          </Badge>
        </div>

        <form onSubmit={handleAddSubmit} className="space-y-4">
          {formError && (
            <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
              <AlertCircle className="h-4 w-4 shrink-0" />
              <span>{formError}</span>
            </div>
          )}

          {/* Row 1: Dropdowns with [+] buttons - Contract Type, Department, Sub Department, Service */}
          <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2 lg:grid-cols-4 min-w-0">
            {/* Contract Type (from mst_service_groups, without [+] button) */}
            <div className="space-y-1.5 min-w-0">
              <div className="flex items-center justify-between">
                <Label htmlFor="master-contract-type" className="text-xs font-medium text-foreground">
                  Contract Type <span className="text-destructive">*</span>
                </Label>
              </div>
              <Select value={selectedContractType} onValueChange={handleContractTypeChange}>
                <SelectTrigger id="master-contract-type" className="h-9 text-xs w-full min-w-0 overflow-hidden [&>span]:truncate">
                  <SelectValue placeholder="Select Contract Type" />
                </SelectTrigger>
                <SelectContent>
                  {availableContractTypes.map((ct) => (
                    <SelectItem key={ct} value={ct} className="text-xs">
                      {ct}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Department [+] - enabled only after Contract Type is selected */}
            <div className="space-y-1.5 min-w-0">
              <div className="flex items-center justify-between">
                <Label htmlFor="master-department" className="text-xs font-medium text-foreground">
                  Department <span className="text-destructive">*</span>
                </Label>
              </div>
              <div className="flex items-center gap-1.5 min-w-0 w-full">
                <SearchableSelect
                  options={availableDepartments}
                  value={selectedDepartment}
                  onChange={handleDepartmentChange}
                  placeholder={selectedContractType ? "Select Department" : "Select Contract Type first"}
                  searchPlaceholder="Search department..."
                  showSearch={true}
                  disabled={!selectedContractType}
                  disabledHint="Select Contract Type first"
                  buttonClassName="h-9 text-xs bg-card border-border hover:bg-muted/30"
                  className="flex-1 min-w-0"
                  clearable={false}
                />
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary hover:bg-primary/10 hover:border-primary transition-all disabled:opacity-50"
                  title="Add new Department"
                  disabled={!selectedContractType}
                  onClick={() => {
                    setNewDepartmentName("");
                    setNewDeptGroup(selectedContractType.toLowerCase().includes("resource") ? "Resource" : "Scope");
                    setAddDepartmentError(null);
                    setShowAddDepartmentModal(true);
                  }}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
            </div>

            {/* Sub Department [+] - enabled only after Department is selected */}
            <div className="space-y-1.5 min-w-0">
              <div className="flex items-center justify-between">
                <Label htmlFor="master-sub-department" className="text-xs font-medium text-foreground">
                  Sub Department
                </Label>
              </div>
              <div className="flex items-center gap-1.5 min-w-0 w-full">
                <SearchableSelect
                  options={availableSubDepartmentsForDept}
                  value={selectedSubDepartment}
                  onChange={handleSubDepartmentChange}
                  placeholder={selectedDepartment ? "Select Sub Department" : "Select Department first"}
                  searchPlaceholder="Search sub department..."
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
                  title="Add new Sub Department"
                  disabled={!selectedDepartment}
                  onClick={() => {
                    setNewSubDeptTargetDept(selectedDepartment || availableDepartments[0] || "");
                    setNewSubDepartmentName("");
                    setAddSubDepartmentError(null);
                    setShowAddSubDepartmentModal(true);
                  }}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
            </div>

            {/* Service [+] - enabled only after Sub Department is selected */}
            <div className="space-y-1.5 min-w-0">
              <div className="flex items-center justify-between">
                <Label htmlFor="master-service" className="text-xs font-medium text-foreground">
                  Service <span className="text-destructive">*</span>
                </Label>
              </div>
              <div className="flex items-center gap-1.5 min-w-0 w-full">
                <SearchableSelect
                  options={filteredServicesForDept}
                  value={selectedService}
                  onChange={handleServiceChange}
                  placeholder={
                    selectedSubDepartment
                      ? "Select Service"
                      : selectedDepartment
                      ? "Select Sub Department first"
                      : "Select Department first"
                  }
                  searchPlaceholder="Search service..."
                  showSearch={true}
                  disabled={!selectedSubDepartment}
                  disabledHint={
                    selectedDepartment
                      ? "Select Sub Department first"
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
                  title="Add new Service"
                  disabled={!selectedSubDepartment}
                  onClick={() => {
                    setNewServiceName("");
                    setAddServiceError(null);
                    setShowAddServiceModal(true);
                  }}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
            </div>
          </div>

          {/* Row 2: Inputs - Tools, Duration, Unit Price */}
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-12">
            <div className="space-y-1.5 sm:col-span-6">
              <Label htmlFor="master-tools" className="text-xs font-medium text-foreground">
                Tools & Technologies <span className="text-destructive">*</span>
              </Label>
              <Input
                id="master-tools"
                placeholder="e.g. Burp Suite, Nessus, Metasploit"
                value={tools}
                onChange={(e) => setTools(e.target.value)}
                className="h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5 sm:col-span-3">
              <Label htmlFor="master-duration" className="text-xs font-medium text-foreground">
                Duration <span className="text-destructive">*</span>
              </Label>
              <Input
                id="master-duration"
                placeholder="e.g. 5 Days / 40 Hours"
                value={duration}
                onChange={(e) => setDuration(e.target.value)}
                className="h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5 sm:col-span-3">
              <Label htmlFor="master-price" className="text-xs font-medium text-foreground">
                Unit Price ($) <span className="text-destructive">*</span>
              </Label>
              <div className="relative">
                <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">$</span>
                <Input
                  id="master-price"
                  type="number"
                  min="0"
                  step="500"
                  placeholder="50000"
                  value={unitPrice}
                  onChange={(e) => setUnitPrice(e.target.value)}
                  className="h-9 pl-6 text-xs"
                />
              </div>
            </div>
          </div>

          {/* Form Actions */}
          <div className="flex items-center justify-end gap-2 pt-2 border-t border-border/50">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="text-xs h-8"
              onClick={() => {
                setSelectedContractType("");
                setSelectedDepartment("");
                setSelectedSubDepartment("");
                setSelectedService("");
                setTools("");
                setDuration("");
                setUnitPrice("");
                setFormError(null);
              }}
            >
              Clear Form
            </Button>
            <Button type="submit" size="sm" className="gap-1.5 text-xs h-8">
              <Plus className="h-3.5 w-3.5" />
              Save Master
            </Button>
          </div>
        </form>
      </div>
      )}

      {/* ── Existing Configured Master Records ───────────────────────────── */}
      <div className="rounded-xl border border-border bg-card p-5 shadow-sm space-y-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h3 className="text-sm font-semibold text-foreground">Existing Project Masters</h3>
            <p className="text-xs text-muted-foreground">
              Review, search, edit, or remove configured project master definitions
            </p>
          </div>

          {/* Filter & Search Controls */}
          <div className="flex items-center gap-2">
            <div className="relative w-48 sm:w-64">
              <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground" />
              <Input
                placeholder="Search masters..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="h-8 pl-8 text-xs bg-muted/30"
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery("")}
                  className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                >
                  <X className="h-3 w-3" />
                </button>
              )}
            </div>

            <Select value={filterContractType} onValueChange={setFilterContractType}>
              <SelectTrigger className="h-8 text-xs w-44">
                <SelectValue placeholder="All Contract Types" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all" className="text-xs">
                  All Contract Types
                </SelectItem>
                {availableContractTypes.map((ct) => (
                  <SelectItem key={ct} value={ct} className="text-xs">
                    {ct}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>

        {/* List / Table */}
        {filteredItems.length === 0 ? (
          <div className="rounded-lg border border-dashed border-border py-12 text-center">
            <FolderKanban className="mx-auto h-8 w-8 text-muted-foreground/60" />
            <p className="mt-2 text-sm font-medium text-foreground">No project masters found</p>
            <p className="mt-1 text-xs text-muted-foreground">
              {searchQuery || filterContractType !== "all"
                ? "Try adjusting your search query or contract type filter."
                : "Use the form above to add your first project master configuration."}
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto rounded-lg border border-border">
            <table className="w-full text-left text-xs">
              <thead className="bg-muted/50 border-b border-border text-muted-foreground font-medium">
                <tr>
                  <th className="py-2.5 px-3">Contract Type</th>
                  <th className="py-2.5 px-3">Department</th>
                  <th className="py-2.5 px-3">Sub-Department</th>
                  <th className="py-2.5 px-3">Service</th>
                  <th className="py-2.5 px-3">Tools & Tech</th>
                  <th className="py-2.5 px-3">Duration</th>
                  <th className="py-2.5 px-3">Unit Price</th>
                  {canManage && <th className="py-2.5 px-3 text-right">Actions</th>}
                </tr>
              </thead>
              <tbody className="divide-y divide-border/60">
                {filteredItems.map((item) => (
                  <tr key={item.id} className="hover:bg-muted/30 transition-colors">
                    <td className="py-3 px-3 align-top font-medium">
                      <Badge variant="outline" className="text-[11px] font-normal border-primary/20 bg-primary/5 text-primary">
                        {item.contractType || item.group}
                      </Badge>
                    </td>
                    <td className="py-3 px-3 align-top font-medium text-foreground">
                      {item.department}
                    </td>
                    <td className="py-3 px-3 align-top">
                      {item.subDepartment ? (
                        <span className="text-xs text-foreground font-medium">{item.subDepartment}</span>
                      ) : (
                        <span className="text-muted-foreground/60">—</span>
                      )}
                    </td>
                    <td className="py-3 px-3 align-top">
                      <div className="font-medium text-foreground">{item.service}</div>
                    </td>
                    <td className="py-3 px-3 align-top max-w-xs">
                      <p className="text-muted-foreground line-clamp-2 leading-relaxed">{item.tools}</p>
                    </td>
                    <td className="py-3 px-3 align-top whitespace-nowrap">
                      <span className="inline-flex items-center gap-1 text-foreground font-medium">
                        <Clock className="h-3 w-3 text-muted-foreground" />
                        {item.duration}
                      </span>
                    </td>
                    <td className="py-3 px-3 align-top whitespace-nowrap font-medium text-foreground">
                      ${item.unitPrice.toLocaleString()}
                    </td>
                    {canManage && (
                    <td className="py-3 px-3 align-top text-right whitespace-nowrap">
                      <div className="inline-flex items-center gap-1">
                        <Button
                          variant="ghost"
                          size="icon"
                          className="h-7 w-7 text-muted-foreground hover:text-foreground"
                          onClick={() => openEditModal(item)}
                          title="Edit Master"
                        >
                          <Pencil className="h-3.5 w-3.5" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          className="h-7 w-7 text-muted-foreground hover:text-destructive"
                          onClick={() => setDeletingId(item.id)}
                          title="Delete Master"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </Button>
                      </div>
                    </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* ── Add New Contract Type Dialog ─────────────────────────────────── */}
      <Dialog open={showAddContractTypeModal} onOpenChange={setShowAddContractTypeModal}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold flex items-center gap-2">
              <FolderPlus className="h-4 w-4 text-primary" />
              Add New Contract Type
            </DialogTitle>
            <DialogDescription className="text-xs">
              Enter a new contract type. It will immediately appear in Project Masters and the Project Onboarding Form.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2">
            {addContractTypeError && (
              <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
                <AlertCircle className="h-4 w-4 shrink-0" />
                <span>{addContractTypeError}</span>
              </div>
            )}
            <div className="space-y-1.5">
              <Label htmlFor="new-contract-type" className="text-xs font-medium">
                Contract Type Name <span className="text-destructive">*</span>
              </Label>
              <Input
                id="new-contract-type"
                placeholder="e.g. Fixed Price, Retainer, Dedicated Team"
                value={newContractTypeName}
                onChange={(e) => setNewContractTypeName(e.target.value)}
                className="h-9 text-xs"
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    handleSaveNewContractType();
                  }
                }}
              />
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="text-xs h-8"
              onClick={() => setShowAddContractTypeModal(false)}
            >
              Cancel
            </Button>
            <Button type="button" size="sm" className="text-xs h-8 gap-1.5" onClick={handleSaveNewContractType}>
              <Plus className="h-3.5 w-3.5" />
              Add Contract Type
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Add New Department Dialog ────────────────────────────────────── */}
      <Dialog open={showAddDepartmentModal} onOpenChange={setShowAddDepartmentModal}>
        <DialogContent className="sm:max-w-md max-h-[85vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold flex items-center gap-2">
              <Building className="h-4 w-4 text-primary" />
              Add New Department
            </DialogTitle>
            <DialogDescription className="text-xs">
              Enter a new department name for the Project Onboarding Form.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2">
            {addDepartmentError && (
              <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
                <AlertCircle className="h-4 w-4 shrink-0" />
                <span>{addDepartmentError}</span>
              </div>
            )}

            <CreatableSearchDropdown
              id="new-department-name"
              label="Department Name"
              placeholder="Type or search department (e.g. Cloud Security)..."
              value={newDepartmentName}
              onChange={(val) => {
                setNewDepartmentName(val);
                if (addDepartmentError) setAddDepartmentError(null);
              }}
              options={allDepartmentsList}
              itemType="Department"
              onEnterSubmit={handleSaveNewDepartment}
              autoFocus
            />
          </div>

          <DialogFooter className="pt-3 border-t border-border/40 gap-2 sm:gap-0 mt-2">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="text-xs h-8"
              onClick={() => setShowAddDepartmentModal(false)}
            >
              Cancel
            </Button>
            <Button
              type="button"
              size="sm"
              className="text-xs h-8 gap-1.5"
              onClick={handleSaveNewDepartment}
              disabled={
                !newDepartmentName.trim() ||
                allDepartmentsList.some(
                  (d) => d.toLowerCase().trim() === newDepartmentName.trim().toLowerCase()
                )
              }
            >
              <Plus className="h-3.5 w-3.5" />
              Add Department
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Add New Sub Department Dialog ─────────────────────────────────── */}
      <Dialog open={showAddSubDepartmentModal} onOpenChange={setShowAddSubDepartmentModal}>
        <DialogContent className="sm:max-w-md max-h-[85vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold flex items-center gap-2">
              <Building className="h-4 w-4 text-primary" />
              Add New Sub Department
            </DialogTitle>
            <DialogDescription className="text-xs">
              Enter a new sub-department name under {activeSubDeptTarget || "the selected department"}.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2">
            {addSubDepartmentError && (
              <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
                <AlertCircle className="h-4 w-4 shrink-0" />
                <span>{addSubDepartmentError}</span>
              </div>
            )}

            <div className="rounded-lg border border-border/60 bg-muted/40 p-2.5 text-xs space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground font-medium">Department:</span>
                <span className="font-semibold text-primary px-2 py-0.5 rounded bg-primary/10 border border-primary/20">
                  {activeSubDeptTarget || "None"}
                </span>
              </div>
              {allDepartmentsList.length > 0 && (
                <div className="space-y-1 pt-1 border-t border-border/30">
                  <div className="flex items-center justify-between">
                    <Label className="text-[11px] text-muted-foreground">Change Department:</Label>
                    <Select
                      value={activeSubDeptTarget || allDepartmentsList[0] || ""}
                      onValueChange={(dept) => {
                        setNewSubDeptTargetDept(dept);
                        setSelectedDepartment(dept);
                        setSelectedSubDepartment("");
                        setSelectedService("");
                      }}
                    >
                      <SelectTrigger className="h-7 text-xs w-[180px]">
                        <SelectValue placeholder="Select Department" />
                      </SelectTrigger>
                      <SelectContent>
                        {allDepartmentsList.map((d) => (
                          <SelectItem key={d} value={d} className="text-xs">
                            {d}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              )}
            </div>

            <CreatableSearchDropdown
              id="new-sub-department-name"
              label="Sub Department Name"
              placeholder="Type or search sub department (e.g. Penetration Testing)..."
              value={newSubDepartmentName}
              onChange={(val) => {
                setNewSubDepartmentName(val);
                if (addSubDepartmentError) setAddSubDepartmentError(null);
              }}
              options={availableSubDepartmentsForDept}
              itemType="Sub-Department"
              contextHint={activeSubDeptTarget ? `under ${activeSubDeptTarget}` : undefined}
              onEnterSubmit={handleSaveNewSubDepartment}
              autoFocus
            />
          </div>

          <DialogFooter className="pt-3 border-t border-border/40 gap-2 sm:gap-0 mt-2">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="text-xs h-8"
              onClick={() => setShowAddSubDepartmentModal(false)}
            >
              Cancel
            </Button>
            <Button
              type="button"
              size="sm"
              className="text-xs h-8 gap-1.5"
              onClick={handleSaveNewSubDepartment}
              disabled={
                !newSubDepartmentName.trim() ||
                availableSubDepartmentsForDept.some(
                  (s) => s.toLowerCase().trim() === newSubDepartmentName.trim().toLowerCase()
                )
              }
            >
              <Plus className="h-3.5 w-3.5" />
              Add Sub Department
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Add New Service Dialog ───────────────────────────────────────── */}
      <Dialog open={showAddServiceModal} onOpenChange={setShowAddServiceModal}>
        <DialogContent className="sm:max-w-md max-h-[85vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold flex items-center gap-2">
              <Wrench className="h-4 w-4 text-primary" />
              Add New Service
            </DialogTitle>
            <DialogDescription className="text-xs">
              Enter a new service name under {selectedDepartment || "the selected department"}.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2">
            {addServiceError && (
              <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
                <AlertCircle className="h-4 w-4 shrink-0" />
                <span>{addServiceError}</span>
              </div>
            )}

            <div className="rounded-lg border border-border/60 bg-muted/40 p-2.5 space-y-1.5 text-xs">
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">Department:</span>
                <span className="font-semibold text-foreground">{selectedDepartment || "None"}</span>
              </div>
              {selectedSubDepartment && (
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">Sub Department:</span>
                  <span className="font-semibold text-foreground">{selectedSubDepartment}</span>
                </div>
              )}
            </div>

            <CreatableSearchDropdown
              id="new-service-name"
              label="Service Name"
              placeholder="Type or search service (e.g. Container Security)..."
              value={newServiceName}
              onChange={(val) => {
                setNewServiceName(val);
                if (addServiceError) setAddServiceError(null);
              }}
              options={filteredServicesForDept}
              itemType="Service"
              contextHint={selectedDepartment ? `under ${selectedDepartment}` : undefined}
              onEnterSubmit={handleSaveNewService}
              autoFocus
            />
          </div>

          <DialogFooter className="pt-3 border-t border-border/40 gap-2 sm:gap-0 mt-2">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="text-xs h-8"
              onClick={() => setShowAddServiceModal(false)}
            >
              Cancel
            </Button>
            <Button
              type="button"
              size="sm"
              className="text-xs h-8 gap-1.5"
              onClick={handleSaveNewService}
              disabled={
                !newServiceName.trim() ||
                filteredServicesForDept.some(
                  (s) => s.toLowerCase().trim() === newServiceName.trim().toLowerCase()
                )
              }
            >
              <Plus className="h-3.5 w-3.5" />
              Add Service
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Edit Project Master Dialog ───────────────────────────────────── */}
      <Dialog open={!!editingItem} onOpenChange={(open) => !open && setEditingItem(null)}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold">Edit Project Master</DialogTitle>
            <DialogDescription className="text-xs">
              Update contract type, department, sub-department, service configuration, tools, duration, or unit price.
            </DialogDescription>
          </DialogHeader>

          {editError && (
            <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
              <AlertCircle className="h-4 w-4 shrink-0" />
              <span>{editError}</span>
            </div>
          )}

          <div className="space-y-3.5 py-2">
            <div className="space-y-1">
              <Label className="text-xs">Contract Type</Label>
              <Select
                value={editContractType}
                onValueChange={(ct) => {
                  setEditContractType(ct);
                  setEditDepartment("");
                  setEditSubDepartment("");
                  setEditService("");
                }}
              >
                <SelectTrigger className="h-8 text-xs">
                  <SelectValue placeholder="Select Contract Type" />
                </SelectTrigger>
                <SelectContent>
                  {availableContractTypes.map((ct) => (
                    <SelectItem key={ct} value={ct} className="text-xs">
                      {ct}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Department (left) and Sub Department (right) side by side */}
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <Label className="text-xs">Department</Label>
                <SearchableSelect
                  options={allDepartmentsList}
                  value={editDepartment}
                  onChange={(d) => {
                    setEditDepartment(d);
                    setEditSubDepartment("");
                    setEditService("");
                  }}
                  placeholder={editContractType ? "Select Department" : "Select Contract Type first"}
                  searchPlaceholder="Search department..."
                  showSearch={true}
                  disabled={!editContractType}
                  disabledHint="Select Contract Type first"
                  buttonClassName="h-8 text-xs bg-card border-border hover:bg-muted/30"
                  className="w-full min-w-0"
                  clearable={false}
                  menuZIndex={999999}
                />
              </div>

              <div className="space-y-1">
                <Label className="text-xs">Sub Department</Label>
                <SearchableSelect
                  options={availableSubDepartmentsForEditDept}
                  value={editSubDepartment}
                  onChange={(sub) => {
                    setEditSubDepartment(sub);
                    setEditService("");
                  }}
                  placeholder={editDepartment ? "Select Sub Department" : "Select Department first"}
                  searchPlaceholder="Search sub department..."
                  showSearch={true}
                  disabled={!editDepartment}
                  disabledHint="Select Department first"
                  buttonClassName="h-8 text-xs bg-card border-border hover:bg-muted/30"
                  className="w-full min-w-0"
                  clearable={false}
                  menuZIndex={999999}
                />
              </div>
            </div>

            <div className="space-y-1">
              <Label className="text-xs">Service</Label>
              <SearchableSelect
                options={catalogServicesForEditDept.map((s) => s.name)}
                value={editService}
                onChange={(serviceName) => {
                  setEditService(serviceName);
                  const matched = catalogServicesForEditDept.find((s) => s.name === serviceName);
                  if (matched) {
                    if (matched.subDept && !editSubDepartment) {
                      setEditSubDepartment(matched.subDept);
                    }
                    if (matched.tool) setEditTools(matched.tool);
                    if (matched.days) setEditDuration(`${matched.days} Days`);
                    if (matched.unitPrice) setEditUnitPrice(String(matched.unitPrice));
                  }
                }}
                placeholder={
                  editSubDepartment
                    ? "Select Service"
                    : editDepartment
                    ? "Select Sub Department first"
                    : "Select Department first"
                }
                searchPlaceholder="Search service..."
                showSearch={true}
                disabled={!editSubDepartment}
                disabledHint={
                  editDepartment
                    ? "Select Sub Department first"
                    : "Select Department first"
                }
                buttonClassName="h-8 text-xs bg-card border-border hover:bg-muted/30"
                className="w-full min-w-0"
                clearable={false}
                menuZIndex={999999}
              />
            </div>

            <div className="space-y-1">
              <Label className="text-xs">Tools & Technologies</Label>
              <Input
                value={editTools}
                onChange={(e) => setEditTools(e.target.value)}
                className="h-8 text-xs"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <Label className="text-xs">Duration</Label>
                <Input
                  value={editDuration}
                  onChange={(e) => setEditDuration(e.target.value)}
                  className="h-8 text-xs"
                />
              </div>
              <div className="space-y-1">
                <Label className="text-xs">Unit Price ($)</Label>
                <Input
                  type="number"
                  min="0"
                  step="500"
                  value={editUnitPrice}
                  onChange={(e) => setEditUnitPrice(e.target.value)}
                  className="h-8 text-xs"
                />
              </div>
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="text-xs h-8"
              onClick={() => setEditingItem(null)}
            >
              Cancel
            </Button>
            <Button type="button" size="sm" className="text-xs h-8" onClick={handleEditSubmit}>
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Delete Confirmation Alert Dialog ─────────────────────────────── */}
      <AlertDialog open={!!deletingId} onOpenChange={(open) => !open && setDeletingId(null)}>
        <AlertDialogContent className="sm:max-w-md">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-sm font-semibold">Delete Project Master</AlertDialogTitle>
            <AlertDialogDescription className="text-xs">
              Are you sure you want to delete this project master entry? This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="text-xs h-8">Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="text-xs h-8 bg-destructive text-destructive-foreground hover:bg-destructive/90"
              onClick={async () => {
                if (deletingId) {
                  const idToDelete = deletingId;
                  setDeletingId(null);
                  await Promise.resolve(onDelete(idToDelete));
                  reloadHierarchy();
                }
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
