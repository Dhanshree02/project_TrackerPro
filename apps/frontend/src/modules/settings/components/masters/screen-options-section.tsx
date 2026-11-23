import { useCallback, useEffect, useMemo, useState } from "react";
import { Pencil, Plus, Trash2 } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  createScreenOption,
  deleteScreenOption,
  fetchScreenOptions,
  updateScreenOption,
  type ScreenOption,
} from "@/lib/api/catalogs";

export interface ScreenOptionGroup {
  category: string;
  title: string;
  singular: string;
  placeholder: string;
  parentLabel?: string;
  parents?: string[];
  parentCategory?: string;
}

export const RESOURCE_SCREEN_OPTIONS: ScreenOptionGroup[] = [
  { category: "WorkerType", title: "Worker Type", singular: "Worker type", placeholder: "e.g. Permanent" },
  { category: "BondDelivered", title: "Bond Delivered", singular: "Bond delivered", placeholder: "e.g. Yes" },
  { category: "ExperienceType", title: "Experience / Fresher", singular: "Experience", placeholder: "e.g. Fresher" },
  { category: "BillableStatus", title: "Billable Status", singular: "Billable status", placeholder: "e.g. Billable" },
  { category: "EmployeeProjectType", title: "Project Type", singular: "Project type", placeholder: "e.g. Long Term" },
];

export const CUSTOMER_SCREEN_OPTIONS: ScreenOptionGroup[] = [
  { category: "BillingMedium", title: "Billing Medium", singular: "Billing medium", placeholder: "e.g. Portal Based" },
];

export const PROJECT_SCREEN_OPTIONS: ScreenOptionGroup[] = [
  {
    category: "WbsProjectType",
    title: "Project Type",
    singular: "Project type",
    placeholder: "e.g. Long Term",
    parentLabel: "Contract group",
    parents: ["Resource", "Scope"],
  },
  {
    category: "BillingModel",
    title: "Billing Model",
    singular: "Billing model",
    placeholder: "e.g. Monthly Arrears",
    parentLabel: "Project type",
    parentCategory: "WbsProjectType",
  },
  {
    category: "PaymentTerm",
    title: "Payment Terms",
    singular: "Payment term",
    placeholder: "e.g. End of Each Month",
    parentLabel: "Billing model",
    parentCategory: "BillingModel",
  },
];

export function ScreenOptionsSection({ groups }: { groups: ScreenOptionGroup[] }) {
  const [rows, setRows] = useState<ScreenOption[]>([]);

  const reload = useCallback(async () => {
    try {
      setRows(await fetchScreenOptions());
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not load choice lists");
    }
  }, []);

  useEffect(() => {
    void reload();
  }, [reload]);

  return (
    <div className="mt-8 space-y-3">
      <h3 className="text-sm font-semibold text-foreground">Choice lists</h3>
      <p className="text-xs text-muted-foreground">
        These lists are stored in the database and used on the employee, customer, and project screens.
      </p>
      <div className="grid grid-cols-1 gap-5 lg:grid-cols-2">
        {groups.map((group) => (
          <ScreenOptionCard key={group.category} group={group} rows={rows} onChanged={reload} />
        ))}
      </div>
    </div>
  );
}

function ScreenOptionCard({
  group,
  rows,
  onChanged,
}: {
  group: ScreenOptionGroup;
  rows: ScreenOption[];
  onChanged: () => Promise<void>;
}) {
  const items = rows.filter((row) => row.category === group.category);
  const parentChoices = useMemo(() => {
    if (group.parents?.length) return group.parents;
    if (!group.parentCategory) return [];
    return [...new Set(rows.filter((row) => row.category === group.parentCategory).map((row) => row.name))];
  }, [group.parentCategory, group.parents, rows]);

  const [name, setName] = useState("");
  const [parentName, setParentName] = useState("");
  const [editing, setEditing] = useState<ScreenOption | null>(null);
  const [editName, setEditName] = useState("");
  const [editParent, setEditParent] = useState("");
  const [saving, setSaving] = useState(false);

  const saveNew = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!name.trim()) {
      toast.error(`Enter a ${group.singular.toLowerCase()}.`);
      return;
    }
    if (group.parentLabel && !parentName) {
      toast.error(`Select ${group.parentLabel.toLowerCase()}.`);
      return;
    }
    setSaving(true);
    try {
      await createScreenOption(group.category, name.trim(), parentName);
      setName("");
      setParentName("");
      toast.success(`Added "${name.trim()}"`);
      await onChanged();
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not save this choice");
    } finally {
      setSaving(false);
    }
  };

  const saveEdit = async () => {
    if (!editing) return;
    if (!editName.trim()) {
      toast.error("Name is required.");
      return;
    }
    if (group.parentLabel && !editParent) {
      toast.error(`Select ${group.parentLabel.toLowerCase()}.`);
      return;
    }
    setSaving(true);
    try {
      await updateScreenOption(editing.id, group.category, editName.trim(), editParent);
      setEditing(null);
      toast.success(`Updated "${editName.trim()}"`);
      await onChanged();
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not update this choice");
    } finally {
      setSaving(false);
    }
  };

  const remove = async (row: ScreenOption) => {
    try {
      await deleteScreenOption(row.id);
      toast.success(`Removed "${row.name}"`);
      await onChanged();
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not remove this choice");
    }
  };

  return (
    <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="mb-3 flex items-center justify-between">
        <h4 className="text-sm font-semibold text-foreground">{group.title}</h4>
        <span className="text-[11px] text-muted-foreground">{items.length}</span>
      </div>
      <form onSubmit={(event) => void saveNew(event)} className="mb-3 flex flex-col gap-2 sm:flex-row">
        {group.parentLabel && (
          <select
            value={parentName}
            onChange={(event) => setParentName(event.target.value)}
            className="h-8 rounded-md border border-input bg-card px-2 text-xs text-foreground sm:w-40"
          >
            <option value="">{group.parentLabel}</option>
            {parentChoices.map((choice) => (
              <option key={choice} value={choice}>
                {choice}
              </option>
            ))}
          </select>
        )}
        <Input
          value={name}
          onChange={(event) => setName(event.target.value)}
          placeholder={group.placeholder}
          className="h-8 text-xs"
        />
        <Button type="submit" size="sm" className="h-8 shrink-0 text-xs" disabled={saving}>
          <Plus className="h-3.5 w-3.5" />
          Add
        </Button>
      </form>
      <div className="max-h-56 divide-y divide-border/60 overflow-y-auto rounded-lg border border-border/80">
        {items.length === 0 ? (
          <p className="px-3 py-4 text-center text-xs text-muted-foreground">No rows yet.</p>
        ) : (
          items.map((row) => (
            <div key={row.id} className="flex items-center justify-between gap-2 px-3 py-2 text-xs">
              <span className="min-w-0 truncate text-foreground">
                {row.name}
                {row.parentName ? <span className="text-muted-foreground"> · {row.parentName}</span> : null}
              </span>
              <span className="flex shrink-0 items-center gap-1">
                <Button
                  type="button"
                  variant="ghost"
                  size="icon"
                  className="h-6 w-6"
                  onClick={() => {
                    setEditing(row);
                    setEditName(row.name);
                    setEditParent(row.parentName || "");
                  }}
                >
                  <Pencil className="h-3 w-3" />
                </Button>
                <Button type="button" variant="ghost" size="icon" className="h-6 w-6" onClick={() => void remove(row)}>
                  <Trash2 className="h-3 w-3" />
                </Button>
              </span>
            </div>
          ))
        )}
      </div>
      {editing && (
        <div className="mt-3 space-y-2 rounded-lg border border-border bg-muted/20 p-3">
          <p className="text-xs font-medium text-foreground">Edit {group.singular}</p>
          {group.parentLabel && (
            <select
              value={editParent}
              onChange={(event) => setEditParent(event.target.value)}
              className="h-8 w-full rounded-md border border-input bg-card px-2 text-xs text-foreground"
            >
              <option value="">{group.parentLabel}</option>
              {parentChoices.map((choice) => (
                <option key={choice} value={choice}>
                  {choice}
                </option>
              ))}
            </select>
          )}
          <Input value={editName} onChange={(event) => setEditName(event.target.value)} className="h-8 text-xs" />
          <div className="flex justify-end gap-2">
            <Button type="button" variant="outline" size="sm" className="h-7 text-xs" onClick={() => setEditing(null)}>
              Cancel
            </Button>
            <Button type="button" size="sm" className="h-7 text-xs" disabled={saving} onClick={() => void saveEdit()}>
              Save
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
