import { useCallback, useEffect, useMemo, useState } from "react";
import {
  CalendarDays,
  Plus,
  Search,
  Pencil,
  Trash2,
  ChevronLeft,
  ChevronRight,
  Sparkles,
  Calendar as CalendarIcon,
  ListFilter,
  Check,
  Tag,
  Palette,
  Info,
} from "lucide-react";
import { toast } from "sonner";
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
import {
  bulkCreateLeaveCalendarHolidays,
  createLeaveCalendarHoliday,
  DEFAULT_HOLIDAY_PRESETS,
  deleteLeaveCalendarHoliday,
  fetchLeaveCalendarHolidays,
  PRESET_COLORS,
  PRESET_TAGS,
  updateLeaveCalendarHoliday,
  type LeaveCalendarHoliday,
  type UpsertLeaveCalendarHolidayPayload,
} from "@/modules/settings/api/leave-calendar";

interface LeaveCalendarSectionProps {
  onCountChange?: (count: number) => void;
}

export function LeaveCalendarSection({ onCountChange }: LeaveCalendarSectionProps) {
  const currentYear = new Date().getFullYear();
  const [selectedYear, setSelectedYear] = useState<number>(currentYear);
  const [holidays, setHolidays] = useState<LeaveCalendarHoliday[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [selectedTagFilter, setSelectedTagFilter] = useState<string>("all");
  const [activeView, setActiveView] = useState<"table" | "calendar">("table");

  // Dialog state
  const [isDialogOpen, setIsDialogOpen] = useState<boolean>(false);
  const [editingHoliday, setEditingHoliday] = useState<LeaveCalendarHoliday | null>(null);
  const [formData, setFormData] = useState<UpsertLeaveCalendarHolidayPayload>({
    date: "",
    name: "",
    tag: "Public Holiday",
    color: "#10b981",
    description: "",
  });
  const [formError, setFormError] = useState<string | null>(null);
  const [saving, setSaving] = useState<boolean>(false);

  // Delete dialog state
  const [deletingHoliday, setDeletingHoliday] = useState<LeaveCalendarHoliday | null>(null);

  const loadHolidays = useCallback(async (year: number) => {
    setLoading(true);
    try {
      const data = await fetchLeaveCalendarHolidays(year);
      setHolidays(data);
      onCountChange?.(data.length);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to load leave calendar holidays");
    } finally {
      setLoading(false);
    }
  }, [onCountChange]);

  useEffect(() => {
    void loadHolidays(selectedYear);
  }, [loadHolidays, selectedYear]);

  // Available unique tags for filter
  const availableTags = useMemo(() => {
    const set = new Set<string>();
    for (const h of holidays) {
      if (h.tag) set.add(h.tag);
    }
    return Array.from(set);
  }, [holidays]);

  // Filtered holidays
  const filteredHolidays = useMemo(() => {
    return holidays.filter((h) => {
      const matchesSearch =
        searchQuery === "" ||
        h.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        h.tag.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (h.description && h.description.toLowerCase().includes(searchQuery.toLowerCase()));

      const matchesTag = selectedTagFilter === "all" || h.tag === selectedTagFilter;

      return matchesSearch && matchesTag;
    });
  }, [holidays, searchQuery, selectedTagFilter]);

  // Statistics
  const stats = useMemo(() => {
    const total = holidays.length;
    const national = holidays.filter((h) => h.tag.toLowerCase().includes("national")).length;
    const festivals = holidays.filter((h) => h.tag.toLowerCase().includes("festival")).length;
    const others = total - national - festivals;
    return { total, national, festivals, others };
  }, [holidays]);

  const handleOpenAddDialog = (initialDate?: string) => {
    const defaultDate = initialDate ?? `${selectedYear}-01-01`;
    setEditingHoliday(null);
    setFormData({
      date: defaultDate,
      name: "",
      tag: "Public Holiday",
      color: "#10b981",
      description: "",
    });
    setFormError(null);
    setIsDialogOpen(true);
  };

  const handleOpenEditDialog = (holiday: LeaveCalendarHoliday) => {
    setEditingHoliday(holiday);
    setFormData({
      date: holiday.date,
      name: holiday.name,
      tag: holiday.tag || "Public Holiday",
      color: holiday.color || "#10b981",
      description: holiday.description || "",
    });
    setFormError(null);
    setIsDialogOpen(true);
  };

  const handleSaveHoliday = async () => {
    if (!formData.date) {
      setFormError("Holiday date is required.");
      return;
    }
    if (!formData.name.trim()) {
      setFormError("Holiday name is required.");
      return;
    }

    setSaving(true);
    setFormError(null);

    try {
      if (editingHoliday) {
        const updated = await updateLeaveCalendarHoliday(editingHoliday.id, formData);
        toast.success(`Holiday "${updated.name}" updated successfully.`);
      } else {
        const created = await createLeaveCalendarHoliday(formData);
        toast.success(`Holiday "${created.name}" created successfully.`);
      }
      setIsDialogOpen(false);
      await loadHolidays(selectedYear);
    } catch (err) {
      setFormError(err instanceof Error ? err.message : "Failed to save holiday");
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteHoliday = async () => {
    if (!deletingHoliday) return;
    try {
      await deleteLeaveCalendarHoliday(deletingHoliday.id);
      toast.success(`Holiday "${deletingHoliday.name}" deleted.`);
      setDeletingHoliday(null);
      await loadHolidays(selectedYear);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to delete holiday");
    }
  };

  const handlePrepopulatePresets = async () => {
    const presetsForYear = DEFAULT_HOLIDAY_PRESETS.map((p) => ({
      ...p,
      date: `${selectedYear}-${p.date.slice(5)}`,
    }));

    try {
      setLoading(true);
      await bulkCreateLeaveCalendarHolidays(presetsForYear);
      toast.success(`Pre-populated ${presetsForYear.length} holidays for ${selectedYear}.`);
      await loadHolidays(selectedYear);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to pre-populate holidays");
      setLoading(false);
    }
  };

  const formatDateLabel = (isoDate: string) => {
    try {
      const parts = isoDate.split("-");
      const d = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
      return d.toLocaleDateString("en-US", {
        weekday: "short",
        day: "numeric",
        month: "short",
        year: "numeric",
      });
    } catch {
      return isoDate;
    }
  };

  return (
    <div className="space-y-6">
      {/* ── Top Bar: Year Navigation, View Toggle & Actions ─ */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2">
            <h2 className="text-xl font-bold tracking-tight text-foreground">Leave Calendar</h2>
            <Badge variant="outline" className="font-mono text-xs font-semibold px-2">
              {selectedYear}
            </Badge>
          </div>
          <p className="text-xs text-muted-foreground mt-0.5">
            Configure full year holidays with name tags and custom colors. Reflects across the Team Dashboard.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {/* Year Switcher */}
          <div className="flex items-center rounded-lg border border-border bg-card p-0.5 shadow-2xs">
            <Button
              variant="ghost"
              size="icon"
              className="h-7 w-7"
              onClick={() => setSelectedYear((y) => y - 1)}
              title="Previous Year"
            >
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <span className="px-2.5 text-xs font-bold tabular-nums">{selectedYear}</span>
            <Button
              variant="ghost"
              size="icon"
              className="h-7 w-7"
              onClick={() => setSelectedYear((y) => y + 1)}
              title="Next Year"
            >
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>

          {/* View Switcher */}
          <div className="flex items-center rounded-lg border border-border bg-card p-0.5 shadow-2xs">
            <Button
              variant={activeView === "table" ? "secondary" : "ghost"}
              size="sm"
              className="h-7 px-2.5 text-xs gap-1.5"
              onClick={() => setActiveView("table")}
            >
              <ListFilter className="h-3.5 w-3.5" />
              <span>List View</span>
            </Button>
            <Button
              variant={activeView === "calendar" ? "secondary" : "ghost"}
              size="sm"
              className="h-7 px-2.5 text-xs gap-1.5"
              onClick={() => setActiveView("calendar")}
            >
              <CalendarIcon className="h-3.5 w-3.5" />
              <span>Full Year View</span>
            </Button>
          </div>

          {/* Pre-populate Button */}
          <Button
            variant="outline"
            size="sm"
            onClick={handlePrepopulatePresets}
            className="h-7 text-xs gap-1.5 border-dashed"
            title="Auto-load standard national and festival holidays for the year"
          >
            <Sparkles className="h-3.5 w-3.5 text-amber-500" />
            <span>Load Sample Holidays</span>
          </Button>

          {/* Add Holiday Button */}
          <Button
            size="sm"
            onClick={() => handleOpenAddDialog()}
            className="h-7 text-xs gap-1.5 shadow-2xs bg-primary hover:bg-primary/90 text-primary-foreground"
          >
            <Plus className="h-3.5 w-3.5" />
            <span>Add Holiday</span>
          </Button>
        </div>
      </div>

      {/* ── Metric Cards ─────────────────────────────────────────────── */}
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <div className="rounded-xl border border-border/70 bg-card p-3 shadow-2xs">
          <div className="text-[11px] font-medium text-muted-foreground uppercase tracking-wider">
            Total Holidays
          </div>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-foreground">{stats.total}</span>
            <span className="text-[11px] text-muted-foreground font-medium">days in {selectedYear}</span>
          </div>
        </div>

        <div className="rounded-xl border border-emerald-500/20 bg-emerald-50/30 dark:bg-emerald-950/20 p-3 shadow-2xs">
          <div className="text-[11px] font-medium text-emerald-800 dark:text-emerald-400 uppercase tracking-wider">
            National Holidays
          </div>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-emerald-700 dark:text-emerald-300">
              {stats.national}
            </span>
            <span className="text-[11px] text-emerald-600 dark:text-emerald-400 font-medium">gazetted</span>
          </div>
        </div>

        <div className="rounded-xl border border-purple-500/20 bg-purple-50/30 dark:bg-purple-950/20 p-3 shadow-2xs">
          <div className="text-[11px] font-medium text-purple-800 dark:text-purple-400 uppercase tracking-wider">
            Festivals
          </div>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-purple-700 dark:text-purple-300">
              {stats.festivals}
            </span>
            <span className="text-[11px] text-purple-600 dark:text-purple-400 font-medium">cultural</span>
          </div>
        </div>

        <div className="rounded-xl border border-amber-500/20 bg-amber-50/30 dark:bg-amber-950/20 p-3 shadow-2xs">
          <div className="text-[11px] font-medium text-amber-800 dark:text-amber-400 uppercase tracking-wider">
            Public & Optional
          </div>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-amber-700 dark:text-amber-300">
              {stats.others}
            </span>
            <span className="text-[11px] text-amber-600 dark:text-amber-400 font-medium">regional / other</span>
          </div>
        </div>
      </div>

      {/* ── Search & Filter Controls ─────────────────────────────────── */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Search holiday by name, tag, or description..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="h-8 pl-8 text-xs bg-background"
          />
        </div>

        <div className="flex flex-wrap items-center gap-1.5">
          <span className="text-[11px] font-medium text-muted-foreground mr-1">Filter Tag:</span>
          <Button
            variant={selectedTagFilter === "all" ? "secondary" : "ghost"}
            size="sm"
            onClick={() => setSelectedTagFilter("all")}
            className="h-6 px-2 text-[11px]"
          >
            All ({holidays.length})
          </Button>
          {availableTags.map((tag) => (
            <Button
              key={tag}
              variant={selectedTagFilter === tag ? "secondary" : "ghost"}
              size="sm"
              onClick={() => setSelectedTagFilter(tag)}
              className="h-6 px-2 text-[11px]"
            >
              {tag}
            </Button>
          ))}
        </div>
      </div>

      {/* ── Table / List View ────────────────────────────────────────── */}
      {activeView === "table" && (
        <div className="rounded-xl border border-border bg-card shadow-2xs overflow-hidden">
          {loading ? (
            <div className="p-12 text-center text-xs text-muted-foreground">
              Loading Leave Calendar for {selectedYear}...
            </div>
          ) : filteredHolidays.length === 0 ? (
            <div className="p-12 text-center">
              <CalendarDays className="mx-auto h-8 w-8 text-muted-foreground/50 mb-2" />
              <div className="text-sm font-semibold text-foreground">No holidays found</div>
              <p className="text-xs text-muted-foreground mt-1 max-w-sm mx-auto">
                No holidays registered for {selectedYear} matching your criteria. Click &quot;Add Holiday&quot; or &quot;Load Sample Holidays&quot; to configure full year holidays.
              </p>
              <div className="mt-4 flex justify-center gap-2">
                <Button size="sm" onClick={() => handleOpenAddDialog()} className="h-7 text-xs">
                  <Plus className="h-3 w-3 mr-1" /> Add Holiday
                </Button>
                <Button variant="outline" size="sm" onClick={handlePrepopulatePresets} className="h-7 text-xs">
                  <Sparkles className="h-3 w-3 mr-1 text-amber-500" /> Load Sample Holidays
                </Button>
              </div>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead>
                  <tr className="border-b border-border bg-muted/40 font-semibold text-muted-foreground">
                    <th className="py-2.5 px-4 w-44">Date</th>
                    <th className="py-2.5 px-4">Holiday Name</th>
                    <th className="py-2.5 px-4 w-48">Name Tag</th>
                    <th className="py-2.5 px-4 w-36">Color Tag</th>
                    <th className="py-2.5 px-4">Description</th>
                    <th className="py-2.5 px-4 text-right w-24">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border/60">
                  {filteredHolidays.map((holiday) => {
                    return (
                      <tr
                        key={holiday.id}
                        className="transition-colors hover:bg-muted/30"
                      >
                        <td className="py-3 px-4 font-medium whitespace-nowrap">
                          <div className="flex items-center gap-2">
                            <span
                              className="h-2.5 w-2.5 shrink-0 rounded-full"
                              style={{ backgroundColor: holiday.color || "#10b981" }}
                            />
                            <span>{formatDateLabel(holiday.date)}</span>
                          </div>
                        </td>
                        <td className="py-3 px-4 font-semibold text-foreground">
                          {holiday.name}
                        </td>
                        <td className="py-3 px-4">
                          <span
                            className="inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-[11px] font-medium border"
                            style={{
                              borderColor: `${holiday.color}40`,
                              backgroundColor: `${holiday.color}15`,
                              color: holiday.color,
                            }}
                          >
                            <Tag className="h-3 w-3" />
                            {holiday.tag}
                          </span>
                        </td>
                        <td className="py-3 px-4">
                          <div className="flex items-center gap-2">
                            <span
                              className="h-5 w-5 rounded-md border border-black/10 shadow-2xs flex items-center justify-center text-[10px] text-white font-bold"
                              style={{ backgroundColor: holiday.color }}
                            >
                              ✓
                            </span>
                            <span className="font-mono text-[11px] text-muted-foreground">
                              {holiday.color}
                            </span>
                          </div>
                        </td>
                        <td className="py-3 px-4 text-muted-foreground max-w-xs truncate">
                          {holiday.description || "—"}
                        </td>
                        <td className="py-3 px-4 text-right whitespace-nowrap">
                          <div className="flex items-center justify-end gap-1">
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-7 w-7 text-muted-foreground hover:text-foreground"
                              onClick={() => handleOpenEditDialog(holiday)}
                              title="Edit Holiday"
                            >
                              <Pencil className="h-3.5 w-3.5" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-7 w-7 text-muted-foreground hover:text-destructive"
                              onClick={() => setDeletingHoliday(holiday)}
                              title="Delete Holiday"
                            >
                              <Trash2 className="h-3.5 w-3.5" />
                            </Button>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {/* ── Full Year 12-Month Calendar Grid View ────────────────────── */}
      {activeView === "calendar" && (
        <FullYearCalendarView
          year={selectedYear}
          holidays={holidays}
          onAddDate={(dateStr) => handleOpenAddDialog(dateStr)}
          onEditHoliday={(hol) => handleOpenEditDialog(hol)}
        />
      )}

      {/* ── Add / Edit Holiday Dialog ─────────────────────────────────── */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>
              {editingHoliday ? "Edit Leave Calendar Holiday" : "Add Leave Calendar Holiday"}
            </DialogTitle>
            <DialogDescription>
              Holidays entered here will be marked across the Team Dashboard with the selected tag and colour.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-2">
            {formError && (
              <div className="rounded-md border border-destructive/30 bg-destructive/10 p-2.5 text-xs text-destructive">
                {formError}
              </div>
            )}

            {/* Date */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-foreground">Holiday Date *</label>
              <Input
                type="date"
                value={formData.date}
                onChange={(e) => setFormData((prev) => ({ ...prev, date: e.target.value }))}
                className="h-8 text-xs"
              />
            </div>

            {/* Name */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-foreground">Holiday Name *</label>
              <Input
                placeholder="e.g. Republic Day, Independence Day, Diwali"
                value={formData.name}
                onChange={(e) => setFormData((prev) => ({ ...prev, name: e.target.value }))}
                className="h-8 text-xs"
              />
            </div>

            {/* Tag Selection */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-foreground">Name Tag / Category *</label>
              <Input
                placeholder="Type or select a tag..."
                value={formData.tag}
                onChange={(e) => setFormData((prev) => ({ ...prev, tag: e.target.value }))}
                className="h-8 text-xs"
              />
              <div className="flex flex-wrap gap-1 pt-1">
                {PRESET_TAGS.map((t) => (
                  <button
                    key={t.name}
                    type="button"
                    onClick={() =>
                      setFormData((prev) => ({
                        ...prev,
                        tag: t.name,
                        color: prev.color === "#10b981" ? t.defaultColor : prev.color,
                      }))
                    }
                    className={cn(
                      "rounded-full border px-2 py-0.5 text-[10px] font-medium transition-colors",
                      formData.tag === t.name
                        ? "border-primary bg-primary/10 text-primary font-semibold"
                        : "border-border text-muted-foreground hover:bg-muted"
                    )}
                  >
                    {t.name}
                  </button>
                ))}
              </div>
            </div>

            {/* Colour Tag */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-foreground flex items-center justify-between">
                <span>Reflected Colour *</span>
                <span className="font-mono text-[11px] text-muted-foreground">{formData.color}</span>
              </label>

              <div className="flex items-center gap-2">
                <input
                  type="color"
                  value={formData.color}
                  onChange={(e) => setFormData((prev) => ({ ...prev, color: e.target.value }))}
                  className="h-8 w-12 cursor-pointer rounded border border-border p-0.5 bg-transparent"
                  title="Pick custom color"
                />
                <div className="grid grid-cols-6 gap-1 flex-1">
                  {PRESET_COLORS.map((c) => (
                    <button
                      key={c.hex}
                      type="button"
                      onClick={() => setFormData((prev) => ({ ...prev, color: c.hex }))}
                      className={cn(
                        "h-6 rounded-md border border-black/10 transition-transform flex items-center justify-center text-[10px] text-white font-bold",
                        formData.color.toLowerCase() === c.hex.toLowerCase()
                          ? "ring-2 ring-primary ring-offset-1 scale-105"
                          : "hover:scale-105"
                      )}
                      style={{ backgroundColor: c.hex }}
                      title={c.label}
                    >
                      {formData.color.toLowerCase() === c.hex.toLowerCase() && <Check className="h-3 w-3" />}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* Description / Notes */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-foreground">
                Description / Notes <span className="text-muted-foreground font-normal">(optional)</span>
              </label>
              <Input
                placeholder="Optional notes or comment"
                value={formData.description ?? ""}
                onChange={(e) => setFormData((prev) => ({ ...prev, description: e.target.value }))}
                className="h-8 text-xs"
              />
            </div>

            {/* Live Preview on Dashboard */}
            <div className="rounded-lg border border-border/80 bg-muted/30 p-3 space-y-2">
              <div className="flex items-center gap-1.5 text-[11px] font-semibold text-muted-foreground">
                <Palette className="h-3.5 w-3.5" />
                <span>Team Dashboard Appearance Preview</span>
              </div>
              <div className="flex items-center gap-3">
                <div
                  className="flex h-8 w-8 items-center justify-center rounded-full text-xs font-bold text-white shadow-xs"
                  style={{ backgroundColor: formData.color || "#10b981" }}
                >
                  {formData.date ? formData.date.split("-")[2] || "26" : "26"}
                </div>
                <div>
                  <div className="text-xs font-bold text-foreground">
                    {formData.name || "Holiday Name"}
                  </div>
                  <div className="text-[11px] text-muted-foreground flex items-center gap-1.5">
                    <span
                      className="inline-block h-2 w-2 rounded-full"
                      style={{ backgroundColor: formData.color || "#10b981" }}
                    />
                    <span>{formData.tag || "Public Holiday"}</span>
                    <span>· Marked on team calendar in this colour</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setIsDialogOpen(false)}
              disabled={saving}
              className="h-8 text-xs"
            >
              Cancel
            </Button>
            <Button
              size="sm"
              onClick={handleSaveHoliday}
              disabled={saving}
              className="h-8 text-xs bg-primary hover:bg-primary/90 text-primary-foreground"
            >
              {saving ? "Saving..." : editingHoliday ? "Update Holiday" : "Create Holiday"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Delete Confirmation Dialog ─────────────────────────────────── */}
      <AlertDialog open={Boolean(deletingHoliday)} onOpenChange={(open) => !open && setDeletingHoliday(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Holiday</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to remove &quot;{deletingHoliday?.name}&quot; on {deletingHoliday?.date}?
              This will unmark this date on the Team Dashboard.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="h-8 text-xs">Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleDeleteHoliday}
              className="h-8 text-xs bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

// ── Full Year 12-Month Calendar Grid Sub-component ────────────────────────────
interface FullYearCalendarViewProps {
  year: number;
  holidays: LeaveCalendarHoliday[];
  onAddDate: (dateStr: string) => void;
  onEditHoliday: (holiday: LeaveCalendarHoliday) => void;
}

function FullYearCalendarView({
  year,
  holidays,
  onAddDate,
  onEditHoliday,
}: FullYearCalendarViewProps) {
  const months = useMemo(() => {
    return Array.from({ length: 12 }, (_, i) => {
      const monthDate = new Date(year, i, 1);
      const monthName = monthDate.toLocaleString("en-US", { month: "long" });
      const daysInMonth = new Date(year, i + 1, 0).getDate();
      const firstDayWeekday = new Date(year, i, 1).getDay(); // 0 = Sun
      return { monthIndex: i, monthName, daysInMonth, firstDayWeekday };
    });
  }, [year]);

  const holidayMap = useMemo(() => {
    const map = new Map<string, LeaveCalendarHoliday>();
    for (const h of holidays) {
      map.set(h.date, h);
    }
    return map;
  }, [holidays]);

  return (
    <div className="space-y-4">
      <div className="rounded-lg border border-border bg-card p-3 shadow-2xs flex items-center justify-between text-xs">
        <div className="flex items-center gap-2 text-muted-foreground">
          <Info className="h-4 w-4 text-primary" />
          <span>Click any holiday to edit its details, tag, or color. Click any empty date to quickly add a new holiday.</span>
        </div>
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1.5">
            <span className="h-2.5 w-2.5 rounded-full bg-emerald-500" />
            <span className="text-[11px] text-muted-foreground">National</span>
          </div>
          <div className="flex items-center gap-1.5">
            <span className="h-2.5 w-2.5 rounded-full bg-pink-500" />
            <span className="text-[11px] text-muted-foreground">Festival</span>
          </div>
          <div className="flex items-center gap-1.5">
            <span className="h-2.5 w-2.5 rounded-full bg-blue-500" />
            <span className="text-[11px] text-muted-foreground">Public</span>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {months.map(({ monthIndex, monthName, daysInMonth, firstDayWeekday }) => {
          const daysArray = Array.from({ length: daysInMonth }, (_, d) => d + 1);
          const emptyLeadSlots = Array.from({ length: firstDayWeekday }, (_, i) => i);

          return (
            <div
              key={monthName}
              className="rounded-xl border border-border bg-card p-3 shadow-2xs space-y-2 flex flex-col"
            >
              <div className="flex items-center justify-between border-b border-border/60 pb-1.5">
                <span className="text-xs font-bold text-foreground">{monthName}</span>
                <span className="text-[10px] font-mono text-muted-foreground">{year}</span>
              </div>

              {/* Day headers */}
              <div className="grid grid-cols-7 text-center text-[10px] font-semibold text-muted-foreground">
                <span>Su</span>
                <span>Mo</span>
                <span>Tu</span>
                <span>We</span>
                <span>Th</span>
                <span>Fr</span>
                <span>Sa</span>
              </div>

              {/* Day cells */}
              <div className="grid grid-cols-7 gap-1 text-center text-xs flex-1">
                {emptyLeadSlots.map((slot) => (
                  <div key={`empty-${slot}`} className="h-6 w-full" />
                ))}

                {daysArray.map((dayNum) => {
                  const mm = String(monthIndex + 1).padStart(2, "0");
                  const dd = String(dayNum).padStart(2, "0");
                  const dateStr = `${year}-${mm}-${dd}`;
                  const holiday = holidayMap.get(dateStr);

                  if (holiday) {
                    return (
                      <button
                        key={dateStr}
                        type="button"
                        onClick={() => onEditHoliday(holiday)}
                        className="group relative flex h-6 w-full items-center justify-center rounded-md font-bold text-white shadow-2xs transition-transform hover:scale-110"
                        style={{ backgroundColor: holiday.color || "#10b981" }}
                        title={`${holiday.name} [${holiday.tag}] · Click to edit`}
                      >
                        <span className="text-[10px] leading-none">{dayNum}</span>
                      </button>
                    );
                  }

                  return (
                    <button
                      key={dateStr}
                      type="button"
                      onClick={() => onAddDate(dateStr)}
                      className="flex h-6 w-full items-center justify-center rounded-md text-[10px] font-medium text-foreground hover:bg-muted transition-colors"
                      title={`Add holiday on ${dateStr}`}
                    >
                      {dayNum}
                    </button>
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

