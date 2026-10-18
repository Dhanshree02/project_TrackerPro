import { useEffect, useMemo, useState } from "react";
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
import type { ProjectMasterItem } from "@/modules/settings/masters/types";
import type { CatalogServiceItem } from "@/modules/settings/masters/project-catalog-store";

function nameAlreadyAdded(names: string[], value: string) {
  const trimmed = value.trim().toLowerCase();
  return trimmed.length > 0 && names.some((name) => name.trim().toLowerCase() === trimmed);
}

function EmptySelectNote({ title, hint }: { title: string; hint: string }) {
  return (
    <div className="px-3 py-4 text-center text-xs text-muted-foreground">
      <p className="font-medium text-foreground">{title}</p>
      <p className="mt-1">{hint}</p>
    </div>
  );
}

function storedName(names: string[], value: string) {
  const trimmed = value.trim().toLowerCase();
  return names.find((name) => name.trim().toLowerCase() === trimmed) ?? value.trim();
}

function SearchableNameField({
  id,
  label,
  existing,
  value,
  onValueChange,
  onUseExisting,
  placeholder,
  emptyHint,
}: {
  id: string;
  label: string;
  existing: string[];
  value: string;
  onValueChange: (value: string) => void;
  onUseExisting: (name: string) => void;
  placeholder: string;
  emptyHint: string;
}) {
  const query = value.trim().toLowerCase();
  const matches = existing.filter((name) => !query || name.toLowerCase().includes(query));

  return (
    <div className="space-y-1.5">
      <Label htmlFor={id} className="text-xs font-medium">
        {label} <span className="text-destructive">*</span>
      </Label>
      <div className="relative">
        <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
        <Input
          id={id}
          value={value}
          onChange={(e) => onValueChange(e.target.value)}
          placeholder={placeholder}
          className="h-9 pl-8 text-xs"
          autoFocus
        />
      </div>
      <div className="max-h-40 overflow-y-auto rounded-md border border-border bg-muted/20">
        {existing.length === 0 ? (
          <p className="px-3 py-3 text-xs text-muted-foreground">{emptyHint}</p>
        ) : matches.length === 0 ? (
          <p className="px-3 py-3 text-xs text-muted-foreground">No saved name matches this search. Add it as new.</p>
        ) : (
          matches.map((name) => (
            <button
              key={name}
              type="button"
              onClick={() => onUseExisting(name)}
              className="flex w-full items-center justify-between gap-2 px-3 py-2 text-left text-xs hover:bg-muted"
            >
              <span className="truncate text-foreground">{name}</span>
              <span className="shrink-0 text-[10px] text-muted-foreground">Already saved</span>
            </button>
          ))
        )}
      </div>
    </div>
  );
}

interface ProjectMastersSectionProps {
  items: ProjectMasterItem[];
  contractTypes?: string[];
  groups?: string[];
  departments?: string[];
  services?: string[];
  getDepartmentsForContract?: (contractType: string) => string[];
  getSubDepartments?: (contractType: string, department: string) => string[];
  getServicesForSubDepartment?: (contractType: string, department: string, subDepartment: string) => CatalogServiceItem[];
  getGroupId?: (contractType: string) => string | undefined;
  getDepartmentId?: (contractType: string, department: string) => string | undefined;
  getSubDepartmentId?: (contractType: string, department: string, subDepartment: string) => string | undefined;
  onSave: (input: {
    serviceId?: string;
    subDepartmentId?: string;
    service: string;
    tools: string;
    duration: string;
    unitPrice: number;
  }) => Promise<{ success: boolean; error?: string }>;
  onUpdate: (
    id: string,
    item: Omit<ProjectMasterItem, "id" | "createdAt"> & { subDepartmentId?: string },
  ) => Promise<{ success: boolean; error?: string }>;
  onDelete: (id: string) => Promise<void> | void;
  onAddContractType?: (name: string) => Promise<{ success: boolean; error?: string }>;
  onAddDepartment?: (name: string, groupId?: string) => Promise<{ success: boolean; error?: string }>;
  onAddSubDepartment?: (name: string, departmentId?: string) => Promise<{ success: boolean; error?: string }>;
  onAddService?: (
    dept: string,
    service: { name: string; tool?: string; unitPrice?: number; days?: number },
    placement?: { contractType?: string; subDepartment?: string; subDepartmentId?: string },
  ) => Promise<{ success: boolean; error?: string }>;
}

export function ProjectMastersSection({
  items,
  contractTypes: propsContractTypes,
  groups: propsGroups,
  getDepartmentsForContract = () => [],
  getSubDepartments = () => [],
  getServicesForSubDepartment = () => [],
  getGroupId = () => undefined,
  getDepartmentId = () => undefined,
  getSubDepartmentId = () => undefined,
  onSave,
  onUpdate,
  onDelete,
  onAddContractType,
  onAddDepartment,
  onAddSubDepartment,
  onAddService,
}: ProjectMastersSectionProps) {
  const availableContractTypes = propsContractTypes || propsGroups || [];

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
  const [page, setPage] = useState(1);
  const pageSize = 8;

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
  const [addDepartmentError, setAddDepartmentError] = useState<string | null>(null);

  const [showAddSubDepartmentModal, setShowAddSubDepartmentModal] = useState(false);
  const [newSubDepartmentName, setNewSubDepartmentName] = useState("");
  const [addSubDepartmentError, setAddSubDepartmentError] = useState<string | null>(null);

  const [showAddServiceModal, setShowAddServiceModal] = useState(false);
  const [newServiceName, setNewServiceName] = useState("");
  const [addServiceError, setAddServiceError] = useState<string | null>(null);

  // Filtered Services for currently selected department
  const departmentsForContract = useMemo(
    () => (selectedContractType ? getDepartmentsForContract(selectedContractType) : []),
    [selectedContractType, getDepartmentsForContract],
  );
  const subDepartmentsForDepartment = useMemo(
    () => (selectedContractType && selectedDepartment ? getSubDepartments(selectedContractType, selectedDepartment) : []),
    [selectedContractType, selectedDepartment, getSubDepartments],
  );
  const servicesForSubDepartment = useMemo(
    () =>
      selectedContractType && selectedDepartment && selectedSubDepartment
        ? getServicesForSubDepartment(selectedContractType, selectedDepartment, selectedSubDepartment)
        : [],
    [selectedContractType, selectedDepartment, selectedSubDepartment, getServicesForSubDepartment],
  );

  const filteredItems = useMemo(() => {
    return items.filter((item) => {
      const itemContractType = item.contractType || item.group || "";
      const matchesSearch =
        searchQuery === "" ||
        itemContractType.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.department.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (item.subDepartment || "").toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.service.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.tools.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.duration.toLowerCase().includes(searchQuery.toLowerCase());

      const matchesContractType = filterContractType === "all" || itemContractType === filterContractType;

      return matchesSearch && matchesContractType;
    });
  }, [items, searchQuery, filterContractType]);

  const pageCount = Math.max(1, Math.ceil(filteredItems.length / pageSize));
  const safePage = Math.min(page, pageCount);
  const pageRows = filteredItems.slice((safePage - 1) * pageSize, safePage * pageSize);

  useEffect(() => {
    setPage(1);
  }, [searchQuery, filterContractType]);

  const editDepartments = useMemo(
    () => (editContractType ? getDepartmentsForContract(editContractType) : []),
    [editContractType, getDepartmentsForContract],
  );
  const editSubDepartments = useMemo(
    () => (editContractType && editDepartment ? getSubDepartments(editContractType, editDepartment) : []),
    [editContractType, editDepartment, getSubDepartments],
  );
  const editServices = useMemo(
    () =>
      editContractType && editDepartment && editSubDepartment
        ? getServicesForSubDepartment(editContractType, editDepartment, editSubDepartment)
        : [],
    [editContractType, editDepartment, editSubDepartment, getServicesForSubDepartment],
  );

  const clearValueFields = () => {
    setTools("");
    setDuration("");
    setUnitPrice("");
  };

  const handleContractTypeChange = (value: string) => {
    setSelectedContractType(value);
    setSelectedDepartment("");
    setSelectedSubDepartment("");
    setSelectedService("");
    clearValueFields();
  };

  const handleDepartmentChange = (dept: string) => {
    setSelectedDepartment(dept);
    setSelectedSubDepartment("");
    setSelectedService("");
    clearValueFields();
  };

  const handleSubDepartmentChange = (subDepartment: string) => {
    setSelectedSubDepartment(subDepartment);
    setSelectedService("");
    clearValueFields();
  };

  const handleServiceChange = (serviceName: string) => {
    setSelectedService(serviceName);
    const matched = servicesForSubDepartment.find((service) => service.name === serviceName);
    if (matched) {
      setTools(matched.tool);
      setUnitPrice(String(matched.unitPrice));
      setDuration(matched.days ? `${matched.days} Days` : "");
    }
  };

  // ── Save New Contract Type ────────────────────────────────────────────────
  const handleSaveNewContractType = async () => {
    setAddContractTypeError(null);
    const trimmed = newContractTypeName.trim();
    if (!trimmed) {
      setAddContractTypeError("Contract type name is required.");
      return;
    }
    if (nameAlreadyAdded(availableContractTypes, trimmed)) {
      setAddContractTypeError(`"${trimmed}" is already added.`);
      return;
    }
    const adder = onAddContractType;
    if (!adder) {
      setAddContractTypeError("Adding a contract type is unavailable.");
      return;
    }
    const res = await adder(newContractTypeName);
    if (res.success) {
      handleContractTypeChange(newContractTypeName.trim());
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
    if (nameAlreadyAdded(departmentsForContract, trimmed)) {
      setSelectedDepartment(storedName(departmentsForContract, trimmed));
      setSelectedSubDepartment("");
      setSelectedService("");
      setTools("");
      setDuration("");
      setUnitPrice("");
      setShowAddDepartmentModal(false);
      setNewDepartmentName("");
      return;
    }
    const adder = onAddDepartment;
    if (!adder) {
      setAddDepartmentError("Adding a department is unavailable.");
      return;
    }
    const res = await adder(newDepartmentName, getGroupId(selectedContractType));
    if (res.success) {
      setSelectedDepartment(newDepartmentName.trim());
      setSelectedSubDepartment("");
      setSelectedService("");
      setTools("");
      setDuration("");
      setUnitPrice("");
      setShowAddDepartmentModal(false);
      setNewDepartmentName("");
    } else {
      setAddDepartmentError(res.error || "Failed to add Department.");
    }
  };

  const handleSaveNewSubDepartment = async () => {
    setAddSubDepartmentError(null);
    const trimmed = newSubDepartmentName.trim();
    if (!trimmed) {
      setAddSubDepartmentError("Sub-department name is required.");
      return;
    }
    if (nameAlreadyAdded(subDepartmentsForDepartment, trimmed)) {
      setSelectedSubDepartment(storedName(subDepartmentsForDepartment, trimmed));
      setSelectedService("");
      setTools("");
      setDuration("");
      setUnitPrice("");
      setShowAddSubDepartmentModal(false);
      setNewSubDepartmentName("");
      return;
    }
    const adder = onAddSubDepartment;
    if (!adder) {
      setAddSubDepartmentError("Adding a sub-department is unavailable.");
      return;
    }
    const res = await adder(newSubDepartmentName, getDepartmentId(selectedContractType, selectedDepartment));
    if (res.success) {
      setSelectedSubDepartment(newSubDepartmentName.trim());
      setSelectedService("");
      setTools("");
      setDuration("");
      setUnitPrice("");
      setShowAddSubDepartmentModal(false);
      setNewSubDepartmentName("");
    } else {
      setAddSubDepartmentError(res.error || "Failed to add Sub-Department.");
    }
  };

  const handleSaveNewService = async () => {
    setAddServiceError(null);
    const trimmed = newServiceName.trim();
    if (!selectedSubDepartment) {
      setAddServiceError("Select a sub-department on the form first.");
      return;
    }
    if (!trimmed) {
      setAddServiceError("Service name is required.");
      return;
    }
    if (nameAlreadyAdded(servicesForSubDepartment.map((service) => service.name), trimmed)) {
      const existing = storedName(
        servicesForSubDepartment.map((service) => service.name),
        trimmed,
      );
      setSelectedService(existing);
      const matched = servicesForSubDepartment.find((service) => service.name === existing);
      setTools(matched?.tool ?? "");
      setUnitPrice(matched ? String(matched.unitPrice || "") : "");
      setDuration(matched?.days ? `${matched.days} Days` : "");
      setShowAddServiceModal(false);
      setNewServiceName("");
      return;
    }
    const adder = onAddService;
    if (!adder) {
      setAddServiceError("Adding a service is unavailable.");
      return;
    }
    const res = await adder(
      selectedDepartment,
      { name: newServiceName },
      {
        contractType: selectedContractType,
        subDepartment: selectedSubDepartment,
        subDepartmentId: getSubDepartmentId(selectedContractType, selectedDepartment, selectedSubDepartment),
      },
    );

    if (res.success) {
      setSelectedService(newServiceName.trim());
      setTools("");
      setDuration("");
      setUnitPrice("");
      setShowAddServiceModal(false);
      setNewServiceName("");
    } else {
      setAddServiceError(res.error || "Failed to add Service.");
    }
  };

  // Handle Add Submit
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
    if (!selectedSubDepartment) {
      setFormError("Please select a Sub-Department.");
      return;
    }
    if (!selectedService) {
      setFormError("Please select a Service.");
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

    const matched = servicesForSubDepartment.find((service) => service.name === selectedService);
    const res = await onSave({
      serviceId: matched?.id,
      subDepartmentId: getSubDepartmentId(selectedContractType, selectedDepartment, selectedSubDepartment),
      service: selectedService,
      tools: tools.trim(),
      duration: duration.trim(),
      unitPrice: priceNum,
    });

    if (res.success) {
      setSelectedContractType("");
      setSelectedDepartment("");
      setSelectedSubDepartment("");
      setSelectedService("");
      setTools("");
      setDuration("");
      setUnitPrice("");
      setFormError(null);
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
    if (!editSubDepartment) {
      setEditError("Please select a Sub-Department.");
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

    const res = await onUpdate(editingItem.id, {
      contractType: editContractType,
      group: editContractType,
      department: editDepartment,
      subDepartment: editSubDepartment,
      subDepartmentId: getSubDepartmentId(editContractType, editDepartment, editSubDepartment),
      service: editService,
      tools: editTools.trim(),
      duration: editDuration.trim(),
      unitPrice: priceNum,
    });

    if (res.success) {
      setEditingItem(null);
    } else {
      setEditError(res.error || "Failed to update master.");
    }
  };

  return (
    <div className="space-y-6">
      {/* ── Top Add Form (Project Masters Configuration) ───────────────── */}
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

          {/* Row 1: Dropdowns with [+] buttons - Contract Type, Department, Service */}
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            {/* Contract Type [+] */}
            <div className="space-y-1.5">
              <div className="flex items-center justify-between">
                <Label htmlFor="master-contract-type" className="text-xs font-medium text-foreground">
                  Contract Type <span className="text-destructive">*</span>
                </Label>
              </div>
              <div className="flex items-center gap-1.5">
                <Select value={selectedContractType} onValueChange={handleContractTypeChange}>
                  <SelectTrigger id="master-contract-type" className="h-9 text-xs flex-1">
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
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary hover:bg-primary/10 hover:border-primary transition-all"
                  title="Add new Contract Type"
                  onClick={() => {
                    setNewContractTypeName("");
                    setAddContractTypeError(null);
                    setShowAddContractTypeModal(true);
                  }}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
            </div>

            {/* Department [+] */}
            <div className="space-y-1.5">
              <div className="flex items-center justify-between">
                <Label htmlFor="master-department" className="text-xs font-medium text-foreground">
                  Department <span className="text-destructive">*</span>
                </Label>
              </div>
              <div className="flex items-center gap-1.5">
                <Select value={selectedDepartment} onValueChange={handleDepartmentChange} disabled={!selectedContractType}>
                  <SelectTrigger id="master-department" className="h-9 text-xs flex-1">
                    <SelectValue
                      placeholder={
                        selectedContractType
                          ? departmentsForContract.length === 0
                            ? "No departments yet"
                            : "Select Department"
                          : "Select contract type first"
                      }
                    />
                  </SelectTrigger>
                  <SelectContent>
                    {departmentsForContract.length === 0 ? (
                      <EmptySelectNote title="No departments yet" hint="Use + to add a department under this contract type." />
                    ) : (
                      departmentsForContract.map((dept) => (
                        <SelectItem key={dept} value={dept} className="text-xs">
                          {dept}
                        </SelectItem>
                      ))
                    )}
                  </SelectContent>
                </Select>
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary hover:bg-primary/10 hover:border-primary transition-all"
                  title="Add new Department"
                  disabled={!selectedContractType}
                  onClick={() => {
                    setNewDepartmentName("");
                    setAddDepartmentError(null);
                    setShowAddDepartmentModal(true);
                  }}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
            </div>

            {/* Sub-Department */}
            <div className="space-y-1.5">
              <Label htmlFor="master-sub-department" className="text-xs font-medium text-foreground">
                Sub-Department <span className="text-destructive">*</span>
              </Label>
              <div className="flex items-center gap-1.5">
                <Select value={selectedSubDepartment} onValueChange={handleSubDepartmentChange} disabled={!selectedDepartment}>
                  <SelectTrigger id="master-sub-department" className="h-9 text-xs flex-1">
                    <SelectValue
                      placeholder={
                        selectedDepartment
                          ? subDepartmentsForDepartment.length === 0
                            ? "No sub-departments yet"
                            : "Select Sub-Department"
                          : "Select department first"
                      }
                    />
                  </SelectTrigger>
                  <SelectContent>
                    {subDepartmentsForDepartment.length === 0 ? (
                      <EmptySelectNote title="No sub-departments yet" hint="Use + to add a sub-department under this department." />
                    ) : (
                      subDepartmentsForDepartment.map((sub) => (
                        <SelectItem key={sub} value={sub} className="text-xs">
                          {sub}
                        </SelectItem>
                      ))
                    )}
                  </SelectContent>
                </Select>
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary hover:bg-primary/10 hover:border-primary transition-all"
                  title="Add new Sub-Department"
                  disabled={!selectedDepartment}
                  onClick={() => {
                    setNewSubDepartmentName("");
                    setAddSubDepartmentError(null);
                    setShowAddSubDepartmentModal(true);
                  }}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
            </div>

            {/* Service [+] */}
            <div className="space-y-1.5">
              <div className="flex items-center justify-between">
                <Label htmlFor="master-service" className="text-xs font-medium text-foreground">
                  Service <span className="text-destructive">*</span>
                </Label>
              </div>
              <div className="flex items-center gap-1.5">
                <Select value={selectedService} onValueChange={handleServiceChange} disabled={!selectedSubDepartment}>
                  <SelectTrigger id="master-service" className="h-9 text-xs flex-1">
                    <SelectValue
                      placeholder={
                        selectedSubDepartment
                          ? servicesForSubDepartment.length === 0
                            ? "No services yet"
                            : "Select Service"
                          : "Select sub-department first"
                      }
                    />
                  </SelectTrigger>
                  <SelectContent>
                    {servicesForSubDepartment.length === 0 ? (
                      <EmptySelectNote title="No services yet" hint="Use + to add a service under this sub-department." />
                    ) : (
                      servicesForSubDepartment.map((srv) => (
                        <SelectItem key={srv.id} value={srv.name} className="text-xs">
                          {srv.name}
                        </SelectItem>
                      ))
                    )}
                  </SelectContent>
                </Select>
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary hover:bg-primary/10 hover:border-primary transition-all"
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
                disabled={!selectedService}
                className="h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5 sm:col-span-3">
              <Label htmlFor="master-duration" className="text-xs font-medium text-foreground">
                Duration <span className="text-destructive">*</span>
              </Label>
              <Input
                id="master-duration"
                placeholder="e.g. 5 Days"
                value={duration}
                onChange={(e) => setDuration(e.target.value)}
                disabled={!selectedService}
                className="h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5 sm:col-span-3">
              <Label htmlFor="master-price" className="text-xs font-medium text-foreground">
                Unit Price (₹) <span className="text-destructive">*</span>
              </Label>
              <div className="relative">
                <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">₹</span>
                <Input
                  id="master-price"
                  type="number"
                  min="0"
                  step="500"
                  placeholder="50000"
                  value={unitPrice}
                  onChange={(e) => setUnitPrice(e.target.value)}
                  disabled={!selectedService}
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
                  <th className="py-2.5 px-3">Unit Price (₹)</th>
                  <th className="py-2.5 px-3 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border/60">
                {pageRows.map((item) => (
                  <tr key={item.id} className="hover:bg-muted/30 transition-colors">
                    <td className="py-3 px-3 align-top font-medium">
                      <Badge variant="outline" className="text-[11px] font-normal border-primary/20 bg-primary/5 text-primary">
                        {item.contractType || item.group}
                      </Badge>
                    </td>
                    <td className="py-3 px-3 align-top font-medium text-foreground">{item.department}</td>
                    <td className="py-3 px-3 align-top text-foreground">{item.subDepartment || "—"}</td>
                    <td className="py-3 px-3 align-top font-medium text-foreground">{item.service}</td>
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
                      ₹{item.unitPrice.toLocaleString("en-IN")}
                    </td>
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
                  </tr>
                ))}
              </tbody>
            </table>
            <div className="flex flex-col gap-2 border-t border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-xs text-muted-foreground">
                Showing {(safePage - 1) * pageSize + 1}–{Math.min(safePage * pageSize, filteredItems.length)} of {filteredItems.length}
              </p>
              <div className="flex items-center gap-2">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  className="h-7 text-xs"
                  disabled={safePage <= 1}
                  onClick={() => setPage(safePage - 1)}
                >
                  Previous
                </Button>
                <span className="text-xs text-muted-foreground">
                  Page {safePage} of {pageCount}
                </span>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  className="h-7 text-xs"
                  disabled={safePage >= pageCount}
                  onClick={() => setPage(safePage + 1)}
                >
                  Next
                </Button>
              </div>
            </div>
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
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold flex items-center gap-2">
              <Building className="h-4 w-4 text-primary" />
              Add New Department
            </DialogTitle>
            <DialogDescription className="text-xs">
              Add a department under {selectedContractType || "the selected contract type"}.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2">
            {addDepartmentError && (
              <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
                <AlertCircle className="h-4 w-4 shrink-0" />
                <span>{addDepartmentError}</span>
              </div>
            )}
            <SearchableNameField
              id="new-department-name"
              label="Department"
              existing={departmentsForContract}
              value={newDepartmentName}
              onValueChange={(next) => {
                setNewDepartmentName(next);
                setAddDepartmentError(null);
              }}
              onUseExisting={(name) => {
                setSelectedDepartment(name);
                setSelectedSubDepartment("");
                setSelectedService("");
                setTools("");
                setDuration("");
                setUnitPrice("");
                setShowAddDepartmentModal(false);
                setNewDepartmentName("");
                setAddDepartmentError(null);
              }}
              placeholder="Search saved departments or type a new name"
              emptyHint="No departments are saved under this contract type yet. Type a name to add one."
            />
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="text-xs h-8"
              onClick={() => setShowAddDepartmentModal(false)}
            >
              Cancel
            </Button>
            <Button type="button" size="sm" className="text-xs h-8 gap-1.5" onClick={handleSaveNewDepartment}>
              <Plus className="h-3.5 w-3.5" />
              {nameAlreadyAdded(departmentsForContract, newDepartmentName) ? "Use existing" : "Add Department"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Add New Sub-Department Dialog ────────────────────────────────── */}
      <Dialog open={showAddSubDepartmentModal} onOpenChange={setShowAddSubDepartmentModal}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold flex items-center gap-2">
              <Building className="h-4 w-4 text-primary" />
              Add New Sub-Department
            </DialogTitle>
            <DialogDescription className="text-xs">
              Add a sub-department under {selectedDepartment || "the selected department"}.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2">
            {addSubDepartmentError && (
              <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
                <AlertCircle className="h-4 w-4 shrink-0" />
                <span>{addSubDepartmentError}</span>
              </div>
            )}
            <SearchableNameField
              id="new-sub-department-name"
              label="Sub-Department"
              existing={subDepartmentsForDepartment}
              value={newSubDepartmentName}
              onValueChange={(next) => {
                setNewSubDepartmentName(next);
                setAddSubDepartmentError(null);
              }}
              onUseExisting={(name) => {
                setSelectedSubDepartment(name);
                setSelectedService("");
                setTools("");
                setDuration("");
                setUnitPrice("");
                setShowAddSubDepartmentModal(false);
                setNewSubDepartmentName("");
                setAddSubDepartmentError(null);
              }}
              placeholder="Search saved sub-departments or type a new name"
              emptyHint="No sub-departments are saved under this department yet. Type a name to add one."
            />
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="text-xs h-8"
              onClick={() => setShowAddSubDepartmentModal(false)}
            >
              Cancel
            </Button>
            <Button type="button" size="sm" className="text-xs h-8 gap-1.5" onClick={() => void handleSaveNewSubDepartment()}>
              <Plus className="h-3.5 w-3.5" />
              {nameAlreadyAdded(subDepartmentsForDepartment, newSubDepartmentName) ? "Use existing" : "Add Sub-Department"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Add New Service Dialog ───────────────────────────────────────── */}
      <Dialog open={showAddServiceModal} onOpenChange={setShowAddServiceModal}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold flex items-center gap-2">
              <Wrench className="h-4 w-4 text-primary" />
              Add New Service
            </DialogTitle>
            <DialogDescription className="text-xs">
              Add a service under {selectedSubDepartment || "the selected sub-department"}. Fill tools, duration, and unit price on the form.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2">
            {addServiceError && (
              <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
                <AlertCircle className="h-4 w-4 shrink-0" />
                <span>{addServiceError}</span>
              </div>
            )}
            <SearchableNameField
              id="new-service-name"
              label="Service"
              existing={servicesForSubDepartment.map((service) => service.name)}
              value={newServiceName}
              onValueChange={(next) => {
                setNewServiceName(next);
                setAddServiceError(null);
              }}
              onUseExisting={(name) => {
                const matched = servicesForSubDepartment.find((service) => service.name === name);
                setSelectedService(name);
                setTools(matched?.tool ?? "");
                setUnitPrice(matched ? String(matched.unitPrice || "") : "");
                setDuration(matched?.days ? `${matched.days} Days` : "");
                setShowAddServiceModal(false);
                setNewServiceName("");
                setAddServiceError(null);
              }}
              placeholder="Search saved services or type a new name"
              emptyHint="No services are saved under this sub-department yet. Type a name to add one."
            />
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="text-xs h-8"
              onClick={() => setShowAddServiceModal(false)}
            >
              Cancel
            </Button>
            <Button type="button" size="sm" className="text-xs h-8 gap-1.5" onClick={handleSaveNewService}>
              <Plus className="h-3.5 w-3.5" />
              {nameAlreadyAdded(servicesForSubDepartment.map((service) => service.name), newServiceName) ? "Use existing" : "Add Service"}
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
              Update contract type, department, sub-department, service, tools, duration, or unit price.
            </DialogDescription>
          </DialogHeader>

          {editError && (
            <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
              <AlertCircle className="h-4 w-4 shrink-0" />
              <span>{editError}</span>
            </div>
          )}

          <div className="space-y-3.5 py-2">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <Label className="text-xs">Contract Type</Label>
                <Select
                  value={editContractType}
                  onValueChange={(value) => {
                    setEditContractType(value);
                    setEditDepartment("");
                    setEditSubDepartment("");
                    setEditService("");
                    setEditTools("");
                    setEditDuration("");
                    setEditUnitPrice("");
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

              <div className="space-y-1">
                <Label className="text-xs">Department</Label>
                <Select
                  value={editDepartment}
                  disabled={!editContractType}
                  onValueChange={(value) => {
                    setEditDepartment(value);
                    setEditSubDepartment("");
                    setEditService("");
                    setEditTools("");
                    setEditDuration("");
                    setEditUnitPrice("");
                  }}
                >
                  <SelectTrigger className="h-8 text-xs">
                    <SelectValue placeholder={editContractType ? "Select Department" : "Select contract type first"} />
                  </SelectTrigger>
                  <SelectContent>
                    {(editDepartment && !editDepartments.includes(editDepartment) ? [editDepartment, ...editDepartments] : editDepartments).map((d) => (
                      <SelectItem key={d} value={d} className="text-xs">
                        {d}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <Label className="text-xs">Sub-Department</Label>
                <Select
                  value={editSubDepartment}
                  disabled={!editDepartment}
                  onValueChange={(value) => {
                    setEditSubDepartment(value);
                    setEditService("");
                    setEditTools("");
                    setEditDuration("");
                    setEditUnitPrice("");
                  }}
                >
                  <SelectTrigger className="h-8 text-xs">
                    <SelectValue placeholder={editDepartment ? "Select Sub-Department" : "Select department first"} />
                  </SelectTrigger>
                  <SelectContent>
                    {(editSubDepartment && !editSubDepartments.includes(editSubDepartment)
                      ? [editSubDepartment, ...editSubDepartments]
                      : editSubDepartments
                    ).map((sub) => (
                      <SelectItem key={sub} value={sub} className="text-xs">
                        {sub}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-1">
                <Label className="text-xs">Service</Label>
                <Select
                  value={editService}
                  disabled={!editSubDepartment}
                  onValueChange={(value) => {
                    setEditService(value);
                    const matched = editServices.find((service) => service.name === value);
                    if (matched) {
                      setEditTools(matched.tool);
                      setEditUnitPrice(String(matched.unitPrice));
                      setEditDuration(matched.days ? `${matched.days} Days` : "");
                    }
                  }}
                >
                  <SelectTrigger className="h-8 text-xs">
                    <SelectValue placeholder={editSubDepartment ? "Select Service" : "Select sub-department first"} />
                  </SelectTrigger>
                  <SelectContent>
                    {(editService && !editServices.some((service) => service.name === editService)
                      ? [{ id: editService, name: editService, tool: "", unitPrice: 0, days: 0 }, ...editServices]
                      : editServices
                    ).map((service) => (
                      <SelectItem key={service.id} value={service.name} className="text-xs">
                        {service.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="space-y-1">
              <Label className="text-xs">Tools & Technologies</Label>
              <Input
                value={editTools}
                onChange={(e) => setEditTools(e.target.value)}
                disabled={!editService}
                className="h-8 text-xs"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <Label className="text-xs">Duration</Label>
                <Input
                  value={editDuration}
                  onChange={(e) => setEditDuration(e.target.value)}
                  placeholder="e.g. 5 Days"
                  disabled={!editService}
                  className="h-8 text-xs"
                />
              </div>
              <div className="space-y-1">
                <Label className="text-xs">Unit Price (₹)</Label>
                <div className="relative">
                  <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">₹</span>
                  <Input
                    type="number"
                    min="0"
                    step="500"
                    value={editUnitPrice}
                    onChange={(e) => setEditUnitPrice(e.target.value)}
                    disabled={!editService}
                    className="h-8 pl-6 text-xs"
                  />
                </div>
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
            <DialogTitle className="text-sm font-semibold">Delete Project Master</DialogTitle>
            <AlertDialogDescription className="text-xs">
              Are you sure you want to delete this project master entry? This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="text-xs h-8">Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="text-xs h-8 bg-destructive text-destructive-foreground hover:bg-destructive/90"
              onClick={() => {
                if (deletingId) {
                  onDelete(deletingId);
                  setDeletingId(null);
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
