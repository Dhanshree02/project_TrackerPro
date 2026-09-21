import { useState, useMemo } from "react";
import {
  Building2,
  Plus,
  Search,
  Pencil,
  Trash2,
  Globe,
  MapPin,
  Briefcase,
  UserCheck,
  Tag,
  AlertCircle,
  X,
  Layers,
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
import type { CustomerMasterCategory, CustomerMastersState, SimpleMasterItem } from "@/lib/masters/types";

interface CustomerMastersSectionProps {
  customerMasters: CustomerMastersState;
  onAdd: (category: CustomerMasterCategory, name: string, extra?: { code?: string; description?: string }) => { success: boolean; error?: string };
  onUpdate: (category: CustomerMasterCategory, id: string, name: string, extra?: { code?: string; description?: string }) => { success: boolean; error?: string };
  onDelete: (category: CustomerMasterCategory, id: string) => void;
}

interface MasterCategoryConfig {
  id: CustomerMasterCategory;
  title: string;
  singular: string;
  placeholder: string;
  description: string;
  icon: typeof UserCheck;
  hasCode?: boolean;
  hasDescription?: boolean;
}

const CATEGORIES: MasterCategoryConfig[] = [
  {
    id: "designations",
    title: "Contact Designations",
    singular: "Designation",
    placeholder: "e.g. Managing Director, CEO, CTO",
    description: "Job titles and roles for customer contacts and stakeholder mapping",
    icon: UserCheck,
  },
  {
    id: "industries",
    title: "Industries",
    singular: "Industry",
    placeholder: "e.g. Information Technology, Healthcare, BFSI",
    description: "Industry verticals and business domains for client categorization",
    icon: Briefcase,
  },
  {
    id: "countries",
    title: "Countries",
    singular: "Country",
    placeholder: "e.g. India, United States, Germany",
    description: "Country list with ISO Alpha codes for client locations & billing",
    icon: Globe,
    hasCode: true,
  },
  {
    id: "cities",
    title: "Cities",
    singular: "City",
    placeholder: "e.g. Pune, Mumbai, New York, London",
    description: "Operational delivery and office locations for clients",
    icon: MapPin,
    hasCode: true,
  },
  {
    id: "contactTypes",
    title: "Contact Types",
    singular: "Contact Type",
    placeholder: "e.g. Primary Contact, Billing Lead, Escalation",
    description: "Classification of stakeholder touchpoints and communications",
    icon: Tag,
    hasDescription: true,
  },
];

export function CustomerMastersSection({
  customerMasters,
  onAdd,
  onUpdate,
  onDelete,
}: CustomerMastersSectionProps) {
  // Active Category sub-tab (or "all" for side-by-side grid)
  const [activeCategory, setActiveCategory] = useState<CustomerMasterCategory | "all">("all");

  return (
    <div className="space-y-6">
      {/* ── Sub-category selection bar ───────────────────────────────────── */}
      <div className="flex flex-wrap items-center gap-1.5 p-1 rounded-xl bg-muted/60 border border-border">
        <button
          onClick={() => setActiveCategory("all")}
          className={cn(
            "flex items-center gap-2 px-3.5 py-1.5 text-xs font-medium rounded-lg transition-all",
            activeCategory === "all"
              ? "bg-card text-foreground shadow-sm font-semibold border border-border/80"
              : "text-muted-foreground hover:text-foreground",
          )}
        >
          <Layers className="h-3.5 w-3.5" />
          <span>All Masters Overview</span>
        </button>

        {CATEGORIES.map((cat) => {
          const Icon = cat.icon;
          const count = customerMasters[cat.id]?.length || 0;
          return (
            <button
              key={cat.id}
              onClick={() => setActiveCategory(cat.id)}
              className={cn(
                "flex items-center gap-2 px-3.5 py-1.5 text-xs font-medium rounded-lg transition-all",
                activeCategory === cat.id
                  ? "bg-card text-foreground shadow-sm font-semibold border border-border/80"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              <Icon className="h-3.5 w-3.5" />
              <span>{cat.title}</span>
              <span className={cn(
                "ml-0.5 rounded-full px-1.5 py-0.2 text-[10px]",
                activeCategory === cat.id ? "bg-primary/15 text-primary font-semibold" : "bg-muted text-muted-foreground"
              )}>
                {count}
              </span>
            </button>
          );
        })}
      </div>

      {/* ── Cards Grid / Selected Category View ──────────────────────────── */}
      {activeCategory === "all" ? (
        <div className="grid grid-cols-1 gap-5 lg:grid-cols-2">
          {CATEGORIES.map((cat) => (
            <ReusableMasterCard
              key={cat.id}
              config={cat}
              items={customerMasters[cat.id] || []}
              onAdd={(name, extra) => onAdd(cat.id, name, extra)}
              onUpdate={(id, name, extra) => onUpdate(cat.id, id, name, extra)}
              onDelete={(id) => onDelete(cat.id, id)}
            />
          ))}
        </div>
      ) : (
        <div className="max-w-4xl mx-auto">
          {(() => {
            const cat = CATEGORIES.find((c) => c.id === activeCategory)!;
            return (
              <ReusableMasterCard
                config={cat}
                items={customerMasters[cat.id] || []}
                onAdd={(name, extra) => onAdd(cat.id, name, extra)}
                onUpdate={(id, name, extra) => onUpdate(cat.id, id, name, extra)}
                onDelete={(id) => onDelete(cat.id, id)}
                isExpandedView
              />
            );
          })()}
        </div>
      )}
    </div>
  );
}

// ─── Reusable Master Card Component ─────────────────────────────────────────
interface ReusableMasterCardProps {
  config: MasterCategoryConfig;
  items: SimpleMasterItem[];
  isExpandedView?: boolean;
  onAdd: (name: string, extra?: { code?: string; description?: string }) => { success: boolean; error?: string };
  onUpdate: (id: string, name: string, extra?: { code?: string; description?: string }) => { success: boolean; error?: string };
  onDelete: (id: string) => void;
}

function ReusableMasterCard({
  config,
  items,
  isExpandedView,
  onAdd,
  onUpdate,
  onDelete,
}: ReusableMasterCardProps) {
  const Icon = config.icon;
  const [inputName, setInputName] = useState("");
  const [inputCode, setInputCode] = useState("");
  const [inputDescription, setInputDescription] = useState("");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");

  // Edit modal state
  const [editingItem, setEditingItem] = useState<SimpleMasterItem | null>(null);
  const [editName, setEditName] = useState("");
  const [editCode, setEditCode] = useState("");
  const [editDescription, setEditDescription] = useState("");
  const [editError, setEditError] = useState<string | null>(null);

  // Delete dialog state
  const [deletingId, setDeletingId] = useState<string | null>(null);

  // Filtered list
  const filteredItems = useMemo(() => {
    if (!searchQuery.trim()) return items;
    const q = searchQuery.toLowerCase();
    return items.filter(
      (item) =>
        item.name.toLowerCase().includes(q) ||
        (item.code && item.code.toLowerCase().includes(q)) ||
        (item.description && item.description.toLowerCase().includes(q)),
    );
  }, [items, searchQuery]);

  const handleAdd = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg(null);

    if (!inputName.trim()) {
      setErrorMsg(`Please enter a ${config.singular.toLowerCase()} name.`);
      return;
    }

    const res = onAdd(inputName.trim(), {
      code: inputCode.trim() || undefined,
      description: inputDescription.trim() || undefined,
    });

    if (res.success) {
      setInputName("");
      setInputCode("");
      setInputDescription("");
      setErrorMsg(null);
    } else {
      setErrorMsg(res.error || "Failed to add item.");
    }
  };

  const openEdit = (item: SimpleMasterItem) => {
    setEditingItem(item);
    setEditName(item.name);
    setEditCode(item.code || "");
    setEditDescription(item.description || "");
    setEditError(null);
  };

  const handleEditSubmit = () => {
    if (!editingItem) return;
    if (!editName.trim()) {
      setEditError("Name is required.");
      return;
    }

    const res = onUpdate(editingItem.id, editName.trim(), {
      code: editCode.trim() || undefined,
      description: editDescription.trim() || undefined,
    });

    if (res.success) {
      setEditingItem(null);
    } else {
      setEditError(res.error || "Failed to update item.");
    }
  };

  return (
    <div className="flex flex-col rounded-xl border border-border bg-card p-5 shadow-sm">
      {/* Header */}
      <div className="flex items-start justify-between pb-3.5 border-b border-border/70">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary">
            <Icon className="h-4 w-4" />
          </div>
          <div>
            <h3 className="text-sm font-semibold text-foreground">{config.title}</h3>
            <p className="text-[11px] text-muted-foreground">{config.description}</p>
          </div>
        </div>
        <Badge variant="secondary" className="text-xs font-normal">
          {items.length} Total
        </Badge>
      </div>

      {/* Add Form */}
      <form onSubmit={handleAdd} className="mt-4 space-y-2.5">
        {errorMsg && (
          <div className="flex items-center gap-1.5 rounded-md border border-destructive/30 bg-destructive/10 px-2.5 py-1.5 text-xs text-destructive">
            <AlertCircle className="h-3.5 w-3.5 shrink-0" />
            <span>{errorMsg}</span>
          </div>
        )}

        <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
          <div className="flex-1">
            <Input
              placeholder={config.placeholder}
              value={inputName}
              onChange={(e) => setInputName(e.target.value)}
              className="h-8 text-xs"
            />
          </div>

          {config.hasCode && (
            <div className="w-full sm:w-28">
              <Input
                placeholder="Code (opt)"
                value={inputCode}
                onChange={(e) => setInputCode(e.target.value)}
                className="h-8 text-xs uppercase"
                maxLength={8}
              />
            </div>
          )}

          <Button type="submit" size="sm" className="h-8 text-xs gap-1 shrink-0">
            <Plus className="h-3.5 w-3.5" />
            Add {config.singular}
          </Button>
        </div>

        {config.hasDescription && (
          <Input
            placeholder="Optional description / notes..."
            value={inputDescription}
            onChange={(e) => setInputDescription(e.target.value)}
            className="h-7 text-xs text-muted-foreground"
          />
        )}
      </form>

      {/* Search & Items List */}
      <div className="mt-4 flex flex-col flex-1 space-y-2.5 pt-3 border-t border-border/60">
        <div className="flex items-center justify-between gap-2">
          <span className="text-xs font-medium text-muted-foreground">
            Existing {config.title} ({filteredItems.length})
          </span>
          <div className="relative w-40 sm:w-48">
            <Search className="absolute left-2 top-1/2 -translate-y-1/2 h-3 w-3 text-muted-foreground" />
            <Input
              placeholder={`Filter ${config.title.toLowerCase()}...`}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="h-7 pl-7 text-[11px] bg-muted/20"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery("")}
                className="absolute right-1.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
              >
                <X className="h-3 w-3" />
              </button>
            )}
          </div>
        </div>

        {filteredItems.length === 0 ? (
          <div className="rounded-lg border border-dashed border-border/80 py-6 text-center text-xs text-muted-foreground">
            {searchQuery ? "No matching master items found" : `No ${config.title.toLowerCase()} configured yet.`}
          </div>
        ) : (
          <div className={cn("divide-y divide-border/60 rounded-lg border border-border/80 overflow-y-auto", isExpandedView ? "max-h-96" : "max-h-64")}>
            {filteredItems.map((item) => (
              <div
                key={item.id}
                className="group flex items-center justify-between gap-3 px-3 py-2 text-xs hover:bg-muted/40 transition-colors"
              >
                <div className="min-w-0 flex-1 flex items-center gap-2">
                  <span className="h-1.5 w-1.5 rounded-full bg-primary/60 shrink-0" />
                  <span className="font-medium text-foreground truncate">{item.name}</span>
                  {item.code && (
                    <Badge variant="outline" className="text-[10px] px-1.5 py-0 font-mono text-muted-foreground">
                      {item.code}
                    </Badge>
                  )}
                  {item.description && (
                    <span className="text-[11px] text-muted-foreground truncate hidden sm:inline">
                      — {item.description}
                    </span>
                  )}
                </div>

                <div className="flex items-center gap-1 opacity-80 group-hover:opacity-100 transition-opacity">
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-6 w-6 text-muted-foreground hover:text-foreground"
                    onClick={() => openEdit(item)}
                    title="Edit item"
                  >
                    <Pencil className="h-3 w-3" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-6 w-6 text-muted-foreground hover:text-destructive"
                    onClick={() => setDeletingId(item.id)}
                    title="Delete item"
                  >
                    <Trash2 className="h-3 w-3" />
                  </Button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Edit Modal */}
      <Dialog open={!!editingItem} onOpenChange={(open) => !open && setEditingItem(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold">Edit {config.singular}</DialogTitle>
            <DialogDescription className="text-xs">
              Modify the master name and parameters.
            </DialogDescription>
          </DialogHeader>

          {editError && (
            <div className="flex items-center gap-1.5 rounded-md border border-destructive/30 bg-destructive/10 px-2.5 py-1.5 text-xs text-destructive">
              <AlertCircle className="h-3.5 w-3.5 shrink-0" />
              <span>{editError}</span>
            </div>
          )}

          <div className="space-y-3 py-2">
            <div className="space-y-1">
              <span className="text-xs font-medium text-foreground">{config.singular} Name</span>
              <Input
                value={editName}
                onChange={(e) => setEditName(e.target.value)}
                className="h-8 text-xs"
              />
            </div>

            {config.hasCode && (
              <div className="space-y-1">
                <span className="text-xs font-medium text-foreground">Code (Optional)</span>
                <Input
                  value={editCode}
                  onChange={(e) => setEditCode(e.target.value)}
                  className="h-8 text-xs uppercase"
                  maxLength={8}
                />
              </div>
            )}

            {config.hasDescription && (
              <div className="space-y-1">
                <span className="text-xs font-medium text-foreground">Description (Optional)</span>
                <Input
                  value={editDescription}
                  onChange={(e) => setEditDescription(e.target.value)}
                  className="h-8 text-xs"
                />
              </div>
            )}
          </div>

          <DialogFooter>
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

      {/* Delete Confirmation Alert Dialog */}
      <AlertDialog open={!!deletingId} onOpenChange={(open) => !open && setDeletingId(null)}>
        <AlertDialogContent className="sm:max-w-md">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-sm font-semibold">Delete {config.singular}</AlertDialogTitle>
            <AlertDialogDescription className="text-xs">
              Are you sure you want to delete this master item?
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
