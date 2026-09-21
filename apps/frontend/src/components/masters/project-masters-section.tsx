import { useState, useMemo } from "react";
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
import type { ProjectMasterItem } from "@/lib/masters/types";
import { useProjectCatalogStore } from "@/lib/masters/project-catalog-store";

interface ProjectMastersSectionProps {
  items: ProjectMasterItem[];
  contractTypes?: string[];
  groups?: string[];
  departments?: string[];
  services?: string[];
  onAdd: (item: Omit<ProjectMasterItem, "id" | "createdAt">) => { success: boolean; error?: string };
  onUpdate: (id: string, item: Omit<ProjectMasterItem, "id" | "createdAt">) => { success: boolean; error?: string };
  onDelete: (id: string) => void;
  onAddContractType?: (name: string) => { success: boolean; error?: string };
  onAddDepartment?: (name: string, group?: "Resource" | "Scope") => { success: boolean; error?: string };
  onAddService?: (dept: string, service: { name: string; tool?: string; unitPrice?: number; days?: number }) => { success: boolean; error?: string };
}

export function ProjectMastersSection({
  items,
  contractTypes: propsContractTypes,
  groups: propsGroups,
  departments: propsDepartments,
  services: propsServices,
  onAdd,
  onUpdate,
  onDelete,
  onAddContractType,
  onAddDepartment,
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
    addService: storeAddService,
    getServicesForDepartment,
  } = useProjectCatalogStore();

  const availableContractTypes = propsContractTypes || storeContractTypes || propsGroups || [];
  const availableDepartments = propsDepartments || storeDepartments || [];
  const availableServices = propsServices || storeAllServices || [];

  // Form State for new entry
  const [selectedContractType, setSelectedContractType] = useState<string>("");
  const [selectedDepartment, setSelectedDepartment] = useState<string>("");
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

  // 3. Service Modal
  const [showAddServiceModal, setShowAddServiceModal] = useState(false);
  const [newServiceDept, setNewServiceDept] = useState("");
  const [newServiceName, setNewServiceName] = useState("");
  const [newServiceTools, setNewServiceTools] = useState("");
  const [newServiceDays, setNewServiceDays] = useState("");
  const [newServicePrice, setNewServicePrice] = useState("");
  const [addServiceError, setAddServiceError] = useState<string | null>(null);

  // Filtered Services for currently selected department
  const filteredServicesForDept = useMemo(() => {
    if (!selectedDepartment) return availableServices;
    const deptItems = getServicesForDepartment(selectedDepartment);
    if (deptItems.length > 0) {
      return deptItems.map((s) => s.name);
    }
    return availableServices;
  }, [selectedDepartment, getServicesForDepartment, availableServices]);

  // Filtered Items for Table
  const filteredItems = useMemo(() => {
    return items.filter((item) => {
      const itemContractType = item.contractType || item.group || "";
      const matchesSearch =
        searchQuery === "" ||
        itemContractType.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.department.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.service.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.tools.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.duration.toLowerCase().includes(searchQuery.toLowerCase());

      const matchesContractType = filterContractType === "all" || itemContractType === filterContractType;

      return matchesSearch && matchesContractType;
    });
  }, [items, searchQuery, filterContractType]);

  // Handle department change in Add Form -> auto-populate tools/unitPrice if matching service exists
  const handleDepartmentChange = (dept: string) => {
    setSelectedDepartment(dept);
    // If selected service does not belong to new dept, reset it
    const deptSvcs = getServicesForDepartment(dept);
    if (deptSvcs.length > 0) {
      const matched = deptSvcs.find((s) => s.name === selectedService);
      if (matched) {
        if (!tools) setTools(matched.tool);
        if (!unitPrice) setUnitPrice(String(matched.unitPrice));
        if (!duration) setDuration(`${matched.days} Days`);
      }
    }
  };

  const handleServiceChange = (serviceName: string) => {
    setSelectedService(serviceName);
    // Auto-fill tools and unitPrice from catalog if available
    if (selectedDepartment) {
      const deptSvcs = getServicesForDepartment(selectedDepartment);
      const matched = deptSvcs.find((s) => s.name === serviceName);
      if (matched) {
        setTools(matched.tool);
        setUnitPrice(String(matched.unitPrice));
        setDuration(`${matched.days} Days`);
      }
    }
  };

  // ── Save New Contract Type ────────────────────────────────────────────────
  const handleSaveNewContractType = () => {
    setAddContractTypeError(null);
    const adder = onAddContractType || storeAddContractType;
    const res = adder(newContractTypeName);
    if (res.success) {
      setSelectedContractType(newContractTypeName.trim());
      setShowAddContractTypeModal(false);
      setNewContractTypeName("");
    } else {
      setAddContractTypeError(res.error || "Failed to add Contract Type.");
    }
  };

  // ── Save New Department ───────────────────────────────────────────────────
  const handleSaveNewDepartment = () => {
    setAddDepartmentError(null);
    const adder = onAddDepartment || storeAddDepartment;
    const res = adder(newDepartmentName, newDeptGroup);
    if (res.success) {
      setSelectedDepartment(newDepartmentName.trim());
      setShowAddDepartmentModal(false);
      setNewDepartmentName("");
    } else {
      setAddDepartmentError(res.error || "Failed to add Department.");
    }
  };

  // ── Save New Service ──────────────────────────────────────────────────────
  const handleSaveNewService = () => {
    setAddServiceError(null);
    const targetDept = newServiceDept || selectedDepartment;
    if (!targetDept) {
      setAddServiceError("Please select a Department first.");
      return;
    }
    const adder = onAddService || storeAddService;
    const priceNum = Number(newServicePrice);
    const daysNum = Number(newServiceDays);

    const res = adder(targetDept, {
      name: newServiceName,
      tool: newServiceTools,
      unitPrice: !Number.isNaN(priceNum) && priceNum > 0 ? priceNum : 50000,
      days: !Number.isNaN(daysNum) && daysNum > 0 ? daysNum : 5,
    });

    if (res.success) {
      setSelectedDepartment(targetDept);
      setSelectedService(newServiceName.trim());
      if (newServiceTools.trim()) setTools(newServiceTools.trim());
      if (newServiceDays.trim()) setDuration(`${newServiceDays.trim()} Days`);
      if (newServicePrice.trim()) setUnitPrice(newServicePrice.trim());

      setShowAddServiceModal(false);
      setNewServiceName("");
      setNewServiceTools("");
      setNewServiceDays("");
      setNewServicePrice("");
    } else {
      setAddServiceError(res.error || "Failed to add Service.");
    }
  };

  // Handle Add Submit
  const handleAddSubmit = (e: React.FormEvent) => {
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

    const res = onAdd({
      contractType: selectedContractType,
      group: selectedContractType,
      department: selectedDepartment,
      service: selectedService,
      tools: tools.trim(),
      duration: duration.trim(),
      unitPrice: priceNum,
    });

    if (res.success) {
      // Clear inputs
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
    setEditService(item.service);
    setEditTools(item.tools);
    setEditDuration(item.duration);
    setEditUnitPrice(String(item.unitPrice));
    setEditError(null);
  };

  // Handle Edit Submit
  const handleEditSubmit = () => {
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

    const res = onUpdate(editingItem.id, {
      contractType: editContractType,
      group: editContractType,
      department: editDepartment,
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
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            {/* Contract Type [+] */}
            <div className="space-y-1.5">
              <div className="flex items-center justify-between">
                <Label htmlFor="master-contract-type" className="text-xs font-medium text-foreground">
                  Contract Type <span className="text-destructive">*</span>
                </Label>
              </div>
              <div className="flex items-center gap-1.5">
                <Select value={selectedContractType} onValueChange={setSelectedContractType}>
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
                <Select value={selectedDepartment} onValueChange={handleDepartmentChange}>
                  <SelectTrigger id="master-department" className="h-9 text-xs flex-1">
                    <SelectValue placeholder="Select Department" />
                  </SelectTrigger>
                  <SelectContent>
                    {availableDepartments.map((dept) => (
                      <SelectItem key={dept} value={dept} className="text-xs">
                        {dept}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary hover:bg-primary/10 hover:border-primary transition-all"
                  title="Add new Department"
                  onClick={() => {
                    setNewDepartmentName("");
                    setNewDeptGroup("Scope");
                    setAddDepartmentError(null);
                    setShowAddDepartmentModal(true);
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
                <Select value={selectedService} onValueChange={handleServiceChange}>
                  <SelectTrigger id="master-service" className="h-9 text-xs flex-1">
                    <SelectValue placeholder={selectedDepartment ? "Select Service" : "Select Dept first or pick Service"} />
                  </SelectTrigger>
                  <SelectContent>
                    {filteredServicesForDept.map((srv) => (
                      <SelectItem key={srv} value={srv} className="text-xs">
                        {srv}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  className="h-9 w-9 shrink-0 border-dashed border-primary/40 text-primary hover:bg-primary/10 hover:border-primary transition-all"
                  title="Add new Service"
                  onClick={() => {
                    setNewServiceDept(selectedDepartment || availableDepartments[0] || "");
                    setNewServiceName("");
                    setNewServiceTools("");
                    setNewServiceDays("");
                    setNewServicePrice("");
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
                  <th className="py-2.5 px-3">Department & Service</th>
                  <th className="py-2.5 px-3">Tools & Tech</th>
                  <th className="py-2.5 px-3">Duration</th>
                  <th className="py-2.5 px-3">Unit Price</th>
                  <th className="py-2.5 px-3 text-right">Actions</th>
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
                    <td className="py-3 px-3 align-top">
                      <div className="font-medium text-foreground">{item.service}</div>
                      <div className="text-[11px] text-muted-foreground mt-0.5">{item.department}</div>
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
              Enter a new department name and classification group for the Project Onboarding Form.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2">
            {addDepartmentError && (
              <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
                <AlertCircle className="h-4 w-4 shrink-0" />
                <span>{addDepartmentError}</span>
              </div>
            )}
            <div className="space-y-1.5">
              <Label htmlFor="new-department-name" className="text-xs font-medium">
                Department Name <span className="text-destructive">*</span>
              </Label>
              <Input
                id="new-department-name"
                placeholder="e.g. Cloud Security, DevSecOps, IoT Security"
                value={newDepartmentName}
                onChange={(e) => setNewDepartmentName(e.target.value)}
                className="h-9 text-xs"
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    handleSaveNewDepartment();
                  }
                }}
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="new-dept-group" className="text-xs font-medium">
                Group Classification
              </Label>
              <Select value={newDeptGroup} onValueChange={(val: "Scope" | "Resource") => setNewDeptGroup(val)}>
                <SelectTrigger id="new-dept-group" className="h-9 text-xs">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Scope" className="text-xs">
                    Scope Based
                  </SelectItem>
                  <SelectItem value="Resource" className="text-xs">
                    Resource Based
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
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
              Add Department
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Add New Service Dialog ───────────────────────────────────────── */}
      <Dialog open={showAddServiceModal} onOpenChange={setShowAddServiceModal}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold flex items-center gap-2">
              <Wrench className="h-4 w-4 text-primary" />
              Add New Service
            </DialogTitle>
            <DialogDescription className="text-xs">
              Configure a new delivery service under a department for Project Masters and the Project Onboarding Form.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3 py-2">
            {addServiceError && (
              <div className="flex items-center gap-2 rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-xs text-destructive">
                <AlertCircle className="h-4 w-4 shrink-0" />
                <span>{addServiceError}</span>
              </div>
            )}
            <div className="space-y-1.5">
              <Label className="text-xs font-medium">
                Target Department <span className="text-destructive">*</span>
              </Label>
              <Select value={newServiceDept} onValueChange={setNewServiceDept}>
                <SelectTrigger className="h-9 text-xs">
                  <SelectValue placeholder="Select Department" />
                </SelectTrigger>
                <SelectContent>
                  {availableDepartments.map((dept) => (
                    <SelectItem key={dept} value={dept} className="text-xs">
                      {dept}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="new-service-name" className="text-xs font-medium">
                Service Name <span className="text-destructive">*</span>
              </Label>
              <Input
                id="new-service-name"
                placeholder="e.g. Container Security Assessment, Kubernetes Audit"
                value={newServiceName}
                onChange={(e) => setNewServiceName(e.target.value)}
                className="h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="new-service-tools" className="text-xs font-medium">
                Default Tools & Technologies (Optional)
              </Label>
              <Input
                id="new-service-tools"
                placeholder="e.g. Trivy, Aqua Security, Sysdig"
                value={newServiceTools}
                onChange={(e) => setNewServiceTools(e.target.value)}
                className="h-9 text-xs"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <Label htmlFor="new-service-days" className="text-xs font-medium">
                  Estimated Days (Optional)
                </Label>
                <Input
                  id="new-service-days"
                  type="number"
                  min="1"
                  placeholder="5"
                  value={newServiceDays}
                  onChange={(e) => setNewServiceDays(e.target.value)}
                  className="h-9 text-xs"
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="new-service-price" className="text-xs font-medium">
                  Default Unit Price ($)
                </Label>
                <Input
                  id="new-service-price"
                  type="number"
                  min="0"
                  step="500"
                  placeholder="50000"
                  value={newServicePrice}
                  onChange={(e) => setNewServicePrice(e.target.value)}
                  className="h-9 text-xs"
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
              onClick={() => setShowAddServiceModal(false)}
            >
              Cancel
            </Button>
            <Button type="button" size="sm" className="text-xs h-8 gap-1.5" onClick={handleSaveNewService}>
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
              Update contract type, department, service configuration, tools, duration, or unit price.
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
                <Select value={editContractType} onValueChange={setEditContractType}>
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
                <Select value={editDepartment} onValueChange={setEditDepartment}>
                  <SelectTrigger className="h-8 text-xs">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {availableDepartments.map((d) => (
                      <SelectItem key={d} value={d} className="text-xs">
                        {d}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="space-y-1">
              <Label className="text-xs">Service</Label>
              <Select value={editService} onValueChange={setEditService}>
                <SelectTrigger className="h-8 text-xs">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {availableServices.map((s) => (
                    <SelectItem key={s} value={s} className="text-xs">
                      {s}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
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
