import { useState } from "react";
import { cn } from "@/lib/utils";

export interface CatalogSelectOption {
  id: string;
  name: string;
}

const INPUT_CLS =
  "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring";

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
  const ADD_VALUE = "__add__";

  const addNew = async () => {
    const trimmed = newName.trim();
    if (!trimmed || creating) return;
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
      <span className="mb-1 block text-xs font-medium text-muted-foreground">{label}</span>
      <select
        className={cn(
          INPUT_CLS,
          error && "border-destructive focus-visible:ring-destructive",
          disabled && "cursor-not-allowed bg-muted text-muted-foreground",
        )}
        disabled={disabled}
        value={adding ? ADD_VALUE : valueId}
        onChange={(e) => {
          const next = e.target.value;
          if (next === ADD_VALUE) {
            setAdding(true);
            setNewName("");
            return;
          }
          setAdding(false);
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
        {!disabled ? <option value={ADD_VALUE}>+ Add new…</option> : null}
      </select>
      {adding && !disabled ? (
        <div className="mt-1.5 flex gap-1.5">
          <input
            className={INPUT_CLS}
            autoComplete="off"
            maxLength={150}
            placeholder="Enter name"
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter") {
                e.preventDefault();
                void addNew();
              }
            }}
          />
          <button
            type="button"
            className="h-9 shrink-0 rounded-md bg-primary px-3 text-sm font-medium text-primary-foreground disabled:opacity-60"
            disabled={!newName.trim() || creating}
            onClick={() => void addNew()}
          >
            Add
          </button>
        </div>
      ) : null}
      {error ? <p className="mt-1 text-[11px] text-destructive">{error}</p> : null}
    </label>
  );
}
