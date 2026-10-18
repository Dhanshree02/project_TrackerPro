import { useCallback, useEffect, useMemo, useState } from "react";
import { AlertCircle, MapPin, Plus, Search, Trash2, X } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
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
import {
  createAddressCity,
  deleteAddressCity,
  fetchAddressCities,
  type AddressCityOption,
} from "@/lib/api/catalogs";

export function ResourceMastersSection() {
  const [items, setItems] = useState<AddressCityOption[]>([]);
  const [loading, setLoading] = useState(true);
  const [name, setName] = useState("");
  const [line, setLine] = useState("");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState<AddressCityOption | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      setItems(await fetchAddressCities());
      setErrorMsg(null);
    } catch (error) {
      setErrorMsg(error instanceof Error ? error.message : "Could not load address cities");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const filteredItems = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();
    if (!query) return items;
    return items.filter(
      (item) =>
        item.name.toLowerCase().includes(query) ||
        (item.line ?? "").toLowerCase().includes(query),
    );
  }, [items, searchQuery]);

  const handleAdd = async (event: React.FormEvent) => {
    event.preventDefault();
    const trimmed = name.trim();
    if (!trimmed) {
      setErrorMsg("Please enter a city name.");
      return;
    }

    setSaving(true);
    setErrorMsg(null);
    try {
      const created = await createAddressCity(trimmed, line);
      setItems((prev) => {
        const without = prev.filter((item) => item.id !== created.id);
        return [...without, created].sort((a, b) => a.sortOrder - b.sortOrder || a.name.localeCompare(b.name));
      });
      setName("");
      setLine("");
      toast.success(`Added "${created.name}" to Current Address - City`);
    } catch (error) {
      setErrorMsg(error instanceof Error ? error.message : "Could not add this city");
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!deleting) return;
    const target = deleting;
    setDeleting(null);
    try {
      await deleteAddressCity(target.id);
      setItems((prev) => prev.filter((item) => item.id !== target.id));
      toast.success(`Removed "${target.name}"`);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not remove this city");
    }
  };

  return (
    <div className="max-w-4xl">
      <div className="flex flex-col rounded-xl border border-border bg-card p-5 shadow-sm">
        <div className="flex items-start justify-between gap-3 border-b border-border/70 pb-3.5">
          <div className="flex items-center gap-2.5">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary">
              <MapPin className="h-4 w-4" />
            </div>
            <div>
              <h3 className="text-sm font-semibold text-foreground">Current Address - City</h3>
              <p className="text-[11px] text-muted-foreground">
                Cities in this list are the Current Address - City dropdown on Onboard New Employee.
              </p>
            </div>
          </div>
          <Badge variant="secondary" className="text-xs font-normal">
            {items.length} Total
          </Badge>
        </div>

        <form onSubmit={(event) => void handleAdd(event)} className="mt-4 space-y-2.5">
          {errorMsg && (
            <div className="flex items-center gap-1.5 rounded-md border border-destructive/30 bg-destructive/10 px-2.5 py-1.5 text-xs text-destructive">
              <AlertCircle className="h-3.5 w-3.5 shrink-0" />
              <span>{errorMsg}</span>
            </div>
          )}

          <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
            <Input
              placeholder="e.g. Andheri or Pune"
              value={name}
              onChange={(event) => setName(event.target.value)}
              className="h-8 flex-1 text-xs"
              maxLength={200}
            />
            <Input
              placeholder="Line (optional), e.g. Western Line"
              value={line}
              onChange={(event) => setLine(event.target.value)}
              className="h-8 w-full text-xs sm:w-64"
              maxLength={80}
            />
            <Button type="submit" size="sm" className="h-8 shrink-0 gap-1 text-xs" disabled={saving}>
              <Plus className="h-3.5 w-3.5" />
              Add City
            </Button>
          </div>
        </form>

        <div className="mt-4 space-y-2.5 border-t border-border/60 pt-3">
          <div className="flex items-center justify-between gap-2">
            <span className="text-xs font-medium text-muted-foreground">
              Existing cities ({filteredItems.length})
            </span>
            <div className="relative w-40 sm:w-48">
              <Search className="absolute left-2 top-1/2 h-3 w-3 -translate-y-1/2 text-muted-foreground" />
              <Input
                placeholder="Filter cities..."
                value={searchQuery}
                onChange={(event) => setSearchQuery(event.target.value)}
                className="h-7 bg-muted/20 pl-7 text-[11px]"
              />
              {searchQuery && (
                <button
                  type="button"
                  onClick={() => setSearchQuery("")}
                  className="absolute right-1.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                >
                  <X className="h-3 w-3" />
                </button>
              )}
            </div>
          </div>

          {loading ? (
            <div className="rounded-lg border border-dashed border-border/80 py-6 text-center text-xs text-muted-foreground">
              Loading cities…
            </div>
          ) : filteredItems.length === 0 ? (
            <div className="rounded-lg border border-dashed border-border/80 py-6 text-center text-xs text-muted-foreground">
              {searchQuery ? "No matching cities" : "No address cities configured yet."}
            </div>
          ) : (
            <div className="max-h-96 divide-y divide-border/60 overflow-y-auto rounded-lg border border-border/80">
              {filteredItems.map((item) => (
                <div
                  key={item.id}
                  className="group flex items-center justify-between gap-3 px-3 py-2 text-xs transition-colors hover:bg-muted/40"
                >
                  <div className="flex min-w-0 flex-1 items-center gap-2">
                    <span className="h-1.5 w-1.5 shrink-0 rounded-full bg-primary/60" />
                    <span className="truncate font-medium text-foreground">{item.name}</span>
                    {item.line && (
                      <Badge variant="outline" className="px-1.5 py-0 text-[10px] text-muted-foreground">
                        {item.line}
                      </Badge>
                    )}
                  </div>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-6 w-6 text-muted-foreground opacity-80 transition-opacity hover:text-destructive group-hover:opacity-100"
                    onClick={() => setDeleting(item)}
                    title="Remove city"
                  >
                    <Trash2 className="h-3 w-3" />
                  </Button>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <AlertDialog open={deleting !== null} onOpenChange={(open) => !open && setDeleting(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Remove this city?</AlertDialogTitle>
            <AlertDialogDescription>
              {deleting
                ? `"${deleting.name}" will disappear from the Current Address - City dropdown. Employees who already have it keep that saved value.`
                : ""}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={() => void handleDelete()}>Remove</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
