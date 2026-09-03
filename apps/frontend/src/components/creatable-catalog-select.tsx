import { useState, useRef, useEffect, useMemo } from "react";
import { ChevronDown, Search, Plus, Check, X } from "lucide-react";
import { FORM_CONTROL_CLS, FORM_ERROR_CLS, FORM_LABEL_CLS } from "@/components/form-row";
import { cn } from "@/lib/utils";

export interface CatalogSelectOption {
  id: string;
  name: string;
}

export interface SearchableSelectOption {
  value: string;
  label: string;
  subLabel?: string;
}

/**
 * Universal Searchable Dropdown with integrated live search,
 * checkmark highlighting, click-outside dismissal, and optional inline creation.
 */
export function SearchableSelect({
  label,
  options,
  value,
  onChange,
  placeholder = "Select…",
  searchPlaceholder,
  disabled,
  disabledHint,
  error,
  required,
  className,
  buttonClassName,
  clearable,
  onCreate,
  showSearch: showSearchProp,
}: {
  label?: string;
  options: Array<string | SearchableSelectOption>;
  value?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
  searchPlaceholder?: string;
  disabled?: boolean;
  disabledHint?: string;
  error?: string;
  required?: boolean;
  className?: string;
  buttonClassName?: string;
  clearable?: boolean;
  onCreate?: (name: string) => Promise<{ id: string; name: string } | void>;
  showSearch?: boolean;
}) {
  const [isOpen, setIsOpen] = useState(false);
  const [search, setSearch] = useState("");
  const [isCreating, setIsCreating] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const searchInputRef = useRef<HTMLInputElement>(null);

  const normalizedOptions: SearchableSelectOption[] = useMemo(
    () =>
      options.map((o) =>
        typeof o === "string" ? { value: o, label: o } : o,
      ),
    [options],
  );

  const showSearch = showSearchProp !== undefined ? showSearchProp : normalizedOptions.length >= 5;

  const selectedOption = useMemo(
    () => normalizedOptions.find((o) => o.value === value),
    [normalizedOptions, value],
  );

  const filteredOptions = useMemo(() => {
    if (!showSearch) return normalizedOptions;
    const q = search.trim().toLowerCase();
    if (!q) return normalizedOptions;
    return normalizedOptions.filter(
      (o) =>
        o.label.toLowerCase().includes(q) ||
        (o.subLabel && o.subLabel.toLowerCase().includes(q)) ||
        o.value.toLowerCase().includes(q),
    );
  }, [normalizedOptions, search, showSearch]);

  useEffect(() => {
    if (!isOpen) {
      setSearch("");
      return;
    }
    const handlePointerDown = (e: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handlePointerDown);
    return () => document.removeEventListener("mousedown", handlePointerDown);
  }, [isOpen]);

  useEffect(() => {
    if (isOpen && showSearch) {
      setTimeout(() => {
        searchInputRef.current?.focus();
      }, 50);
    }
  }, [isOpen, showSearch]);

  const handleSelect = (val: string) => {
    onChange?.(val);
    setIsOpen(false);
    setSearch("");
  };

  const handleCreate = async () => {
    const query = search.trim();
    if (!query || !onCreate || isCreating) return;
    setIsCreating(true);
    try {
      const res = await onCreate(query);
      if (res && res.id) {
        onChange?.(res.id);
      }
      setIsOpen(false);
      setSearch("");
    } catch {
      // Caller handles error notification
    } finally {
      setIsCreating(false);
    }
  };

  return (
    <div className={cn("relative block", className)} ref={containerRef}>
      {label ? (
        <span className={FORM_LABEL_CLS}>
          {label}
          {required ? <span className="text-destructive"> *</span> : null}
        </span>
      ) : null}

      <div className="relative">
        <button
          type="button"
          disabled={disabled}
          onClick={() => {
            if (!disabled) setIsOpen((prev) => !prev);
          }}
          className={cn(
            FORM_CONTROL_CLS,
            "flex w-full items-center justify-between gap-2 text-left font-normal transition-colors select-none",
            !value && "text-muted-foreground",
            disabled && "cursor-not-allowed opacity-60 bg-muted/40",
            isOpen && "border-primary ring-2 ring-primary/20",
            error && "border-destructive focus-visible:ring-destructive",
            buttonClassName,
          )}
          aria-haspopup="listbox"
          aria-expanded={isOpen}
        >
          <span className="truncate">
            {disabled
              ? disabledHint ?? placeholder
              : selectedOption
                ? selectedOption.label
                : placeholder}
          </span>
          <div className="flex shrink-0 items-center gap-1">
            {value && !disabled && (clearable ?? true) && (
              <span
                role="button"
                tabIndex={0}
                onClick={(e) => {
                  e.stopPropagation();
                  onChange?.("");
                }}
                className="rounded p-0.5 text-muted-foreground hover:bg-muted hover:text-foreground"
                title="Clear selection"
              >
                <X className="h-3 w-3" />
              </span>
            )}
            <ChevronDown
              className={cn(
                "h-3.5 w-3.5 text-muted-foreground transition-transform duration-200",
                isOpen && "rotate-180",
              )}
            />
          </div>
        </button>

        {isOpen && !disabled && (
          <div
            className="absolute left-0 top-full z-50 mt-1 max-h-60 w-full min-w-[220px] rounded-lg border border-border bg-popover text-popover-foreground shadow-lg animate-in fade-in zoom-in-95 duration-100 flex flex-col overflow-hidden"
            role="listbox"
          >
            {/* Search Input */}
            {showSearch && (
              <div className="sticky top-0 z-10 border-b border-border bg-popover p-1.5">
                <div className="relative flex items-center">
                  <Search className="absolute left-2.5 h-3.5 w-3.5 text-muted-foreground" />
                  <input
                    ref={searchInputRef}
                    type="text"
                    maxLength={200}
                    placeholder={searchPlaceholder ?? `Search ${label ? label.toLowerCase() : "options"}…`}
                    value={search}
                    onChange={(e) => setSearch(e.target.value.slice(0, 200))}
                    onKeyDown={(e) => {
                      if (e.key === "Escape") {
                        setIsOpen(false);
                      } else if (e.key === "Enter" && filteredOptions.length === 1) {
                        e.preventDefault();
                        handleSelect(filteredOptions[0].value);
                      } else if (
                        e.key === "Enter" &&
                        filteredOptions.length === 0 &&
                        onCreate &&
                        search.trim()
                      ) {
                        e.preventDefault();
                        void handleCreate();
                      }
                    }}
                    className="h-8 w-full rounded-md bg-muted/50 pl-8 pr-2 text-xs font-normal text-foreground placeholder:text-muted-foreground focus:bg-background focus:outline-none focus:ring-1 focus:ring-primary"
                  />
                </div>
              </div>
            )}

            {/* Options List */}
            <div className="flex-1 overflow-y-auto p-1 text-xs">
              {filteredOptions.length > 0 ? (
                filteredOptions.map((opt) => {
                  const isSelected = opt.value === value;
                  return (
                    <button
                      key={opt.value}
                      type="button"
                      onClick={() => handleSelect(opt.value)}
                      className={cn(
                        "flex w-full items-center justify-between gap-2 rounded-md px-2.5 py-1.5 text-left text-xs font-medium transition-colors",
                        isSelected
                          ? "bg-primary/10 text-primary font-semibold"
                          : "text-foreground hover:bg-muted hover:text-foreground",
                      )}
                      role="option"
                      aria-selected={isSelected}
                    >
                      <div className="min-w-0 flex-1 truncate">
                        <div>{opt.label}</div>
                        {opt.subLabel && (
                          <div className="text-[10px] text-muted-foreground truncate font-normal">
                            {opt.subLabel}
                          </div>
                        )}
                      </div>
                      {isSelected ? (
                        <Check className="h-3.5 w-3.5 shrink-0 text-primary" />
                      ) : null}
                    </button>
                  );
                })
              ) : (
                <div className="p-3 text-center text-xs text-muted-foreground">
                  No matching options
                </div>
              )}

              {/* Inline Create Option */}
              {onCreate && search.trim() && !filteredOptions.some((o) => o.label.toLowerCase() === search.trim().toLowerCase()) && (
                <div className="border-t border-border mt-1 pt-1">
                  <button
                    type="button"
                    disabled={isCreating}
                    onClick={() => void handleCreate()}
                    className="flex w-full items-center gap-2 rounded-md bg-primary/5 px-2.5 py-1.5 text-left text-xs font-medium text-primary hover:bg-primary/15 transition-colors disabled:opacity-60"
                  >
                    <Plus className="h-3.5 w-3.5 shrink-0" />
                    <span className="truncate">
                      Add &ldquo;<strong>{search.trim()}</strong>&rdquo;
                    </span>
                  </button>
                </div>
              )}
            </div>
          </div>
        )}
      </div>

      {error ? <p className={FORM_ERROR_CLS}>{error}</p> : null}
    </div>
  );
}

/**
 * Creatable Catalog Select with Searchable Dropdown + Quick Add Button
 */
export function CreatableCatalogSelect({
  label,
  options,
  valueId,
  disabled,
  disabledHint,
  placeholder = "Select…",
  error,
  required,
  className,
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
  required?: boolean;
  className?: string;
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

  const selectOptions: SearchableSelectOption[] = useMemo(
    () => options.map((o) => ({ value: o.id, label: o.name })),
    [options],
  );

  return (
    <div className={cn("block", className)}>
      <span className={FORM_LABEL_CLS}>
        {label}
        {required ? <span className="text-destructive"> *</span> : null}
      </span>
      <div className="flex h-9 w-full items-stretch">
        <div className="min-w-0 flex-1">
          <SearchableSelect
            options={selectOptions}
            value={valueId}
            disabled={disabled || adding}
            disabledHint={disabledHint}
            placeholder={disabled ? disabledHint ?? placeholder : placeholder}
            error={error}
            onChange={(selectedId) => {
              setAdding(false);
              setNewName("");
              const match = options.find((o) => o.id === selectedId);
              onSelect(selectedId, match?.name ?? "");
            }}
            onCreate={async (name) => {
              const created = await onCreate(name);
              onSelect(created.id, created.name);
              return created;
            }}
          />
        </div>
        <button
          type="button"
          disabled={disabled}
          className={cn(
            "ml-1.5 h-9 shrink-0 rounded-md bg-blue-600 px-3 text-xs font-semibold text-white transition-all duration-150 shadow-xs",
            "hover:bg-blue-700 active:scale-[0.98] active:bg-blue-800",
            "disabled:cursor-not-allowed disabled:opacity-40 disabled:bg-muted disabled:border-border disabled:text-muted-foreground disabled:shadow-none",
            adding && !disabled && "bg-blue-700 ring-2 ring-blue-500/30 shadow-xs",
            error && "bg-destructive hover:bg-destructive/90 text-destructive-foreground",
          )}
          onClick={() => {
            if (disabled) return;
            setAdding(true);
            setNewName("");
          }}
        >
          <Plus className="mr-1 inline h-3.5 w-3.5 shrink-0 text-white" />
          Add
        </button>
      </div>

      {adding && !disabled ? (
        <div className="mt-2 flex gap-1.5 animate-in fade-in duration-100">
          <input
            className={cn(FORM_CONTROL_CLS, "text-xs", error && "border-destructive")}
            autoComplete="off"
            autoFocus
            maxLength={200}
            placeholder={`Enter new ${label.toLowerCase()}`}
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
            className="h-9 shrink-0 rounded-md bg-blue-600 px-3.5 text-xs font-semibold text-white shadow-xs hover:bg-blue-700 active:bg-blue-800 disabled:opacity-50 transition-colors"
            disabled={!newName.trim() || creating}
            onClick={() => void addNew()}
          >
            {creating ? "…" : "Save"}
          </button>
          <button
            type="button"
            className="h-9 shrink-0 rounded-md border border-input bg-card px-3 text-xs font-medium text-muted-foreground hover:bg-accent"
            onClick={() => {
              setAdding(false);
              setNewName("");
            }}
          >
            Cancel
          </button>
        </div>
      ) : null}
    </div>
  );
}
