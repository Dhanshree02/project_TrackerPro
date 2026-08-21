import { useState } from "react";
import { ChevronDown } from "lucide-react";
import { FORM_CONTROL_CLS, FORM_ERROR_CLS, FORM_LABEL_CLS } from "@/components/form-row";
import { cn } from "@/lib/utils";

export interface CatalogSelectOption {
  id: string;
  name: string;
}

export function CreatableCatalogSelect({
  label,
  options,
  valueId,
  disabled,
  disabledHint,
  placeholder = "Select…",
  error,
  onSelect,
  onCreate,
}: {
  label: string;
  options: CatalogSelectOption[];
  valueId: string;
  disabled?: boolean;
  disabledHint?: string;
  placeholder?: string;
  error?: string;
  onSelect: (id: string, name: string) => void;
  onCreate: (name: string) => Promise<CatalogSelectOption>;
}) {
  const [adding, setAdding] = useState(false);
  const [newName, setNewName] = useState("");
  const [creating, setCreating] = useState(false);

  const addNew = async () => {
    const trimmed = newName.trim();
    if (!trimmed || creating || disabled) return;
    setCreating(true);
    try {
      const created = await onCreate(trimmed);
      onSelect(created.id, created.name);
      setAdding(false);
      setNewName("");
    } catch {
      // Caller surfaces the error (toast).
    } finally {
      setCreating(false);
    }
  };

  return (
    <label className="block">
      <span className={FORM_LABEL_CLS}>{label}</span>
      <div className="flex h-9 w-full items-stretch">
        <div className="relative min-w-0 flex-1">
          <select
            autoComplete="off"
            className={cn(
              FORM_CONTROL_CLS,
              "rounded-r-none border-r-0 appearance-none pr-8",
              !valueId && "text-muted-foreground",
              error && "border-destructive focus-visible:ring-destructive",
            )}
            disabled={disabled || adding}
            value={valueId}
            onChange={(e) => {
              const next = e.target.value;
              setAdding(false);
              setNewName("");
              const match = options.find((o) => o.id === next);
              onSelect(next, match?.name ?? "");
            }}
          >
            <option value="">{disabled ? disabledHint ?? placeholder : placeholder}</option>
            {options.map((o) => (
              <option key={o.id} value={o.id}>
                {o.name}
              </option>
            ))}
          </select>
          <ChevronDown className="pointer-events-none absolute right-2.5 top-1/2 h-3.5 w-3.5 shrink-0 -translate-y-1/2 text-muted-foreground" />
        </div>
        <button
          type="button"
          disabled={disabled}
          className={cn(
            "h-9 shrink-0 rounded-r-md border border-input bg-card px-3 text-sm font-medium text-foreground transition-colors",
            "hover:bg-accent disabled:cursor-not-allowed disabled:opacity-60",
            adding && !disabled && "border-primary bg-primary text-primary-foreground hover:bg-primary/90",
            error && "border-destructive",
          )}
          onClick={() => {
            if (disabled) return;
            setAdding(true);
            setNewName("");
          }}
        >
          + Add
        </button>
      </div>
      {adding && !disabled ? (
        <div className="mt-1.5 flex gap-1.5">
          <input
            className={cn(FORM_CONTROL_CLS, error && "border-destructive")}
            autoComplete="off"
            autoFocus
            maxLength={150}
            placeholder="Enter name"
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter") {
                e.preventDefault();
                void addNew();
              }
              if (e.key === "Escape") {
                setAdding(false);
                setNewName("");
              }
            }}
          />
          <button
            type="button"
            className="h-9 shrink-0 rounded-md bg-primary px-3 text-sm font-medium text-primary-foreground disabled:opacity-60"
            disabled={!newName.trim() || creating}
            onClick={() => void addNew()}
          >
            {creating ? "…" : "Save"}
          </button>
          <button
            type="button"
            className="h-9 shrink-0 rounded-md border border-input bg-card px-3 text-sm font-medium text-muted-foreground hover:bg-accent"
            onClick={() => {
              setAdding(false);
              setNewName("");
            }}
          >
            Cancel
          </button>
        </div>
      ) : null}
      {error ? <p className={FORM_ERROR_CLS}>{error}</p> : null}
    </label>
  );
}
