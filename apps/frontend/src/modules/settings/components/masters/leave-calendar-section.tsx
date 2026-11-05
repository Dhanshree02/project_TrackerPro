import { useCallback, useEffect, useMemo, useState } from "react";
import {
  CalendarDays,
  Plus,
  Search,
  Pencil,
  Trash2,
  ChevronLeft,
  ChevronRight,
  History,
  Calendar as CalendarIcon,
  ListFilter,
  Info,
} from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
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
import {
  bulkCreateLeaveCalendarHolidays,
  clearLeaveCalendarYear,
  createLeaveCalendarHoliday,
  deleteLeaveCalendarHoliday,
  fetchLeaveCalendarHolidays,
  updateLeaveCalendarHoliday,
  type LeaveCalendarHoliday,
  type UpsertLeaveCalendarHolidayPayload,
} from "@/modules/settings/api/leave-calendar";

// Standard company holiday green matching Team Dashboard
const HOLIDAY_COLOR = "#a6c63a";

interface LeaveCalendarSectionProps {
  onCountChange?: (count: number) => void;
}

export function LeaveCalendarSection({ onCountChange }: LeaveCalendarSectionProps) {
  const currentYear = new Date().getFullYear();
  // Switching to a year back is only available for the last one (currentYear - 1)
  const minYear = currentYear - 1;

  const [selectedYear, setSelectedYear] = useState<number>(currentYear);
  const [holidays, setHolidays] = useState<LeaveCalendarHoliday[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [searchQuery, setSearchQuery] = useState<string>("");
  // Full Year View is default, List View is secondary
  const [activeView, setActiveView] = useState<"calendar" | "table">("calendar");

  // Dialog state
  const [isDialogOpen, setIsDialogOpen] = useState<boolean>(false);
  const [editingHoliday, setEditingHoliday] = useState<LeaveCalendarHoliday | null>(null);
  const [formData, setFormData] = useState<UpsertLeaveCalendarHolidayPayload>({
    date: "",
    name: "",
  });
  const [formError, setFormError] = useState<string | null>(null);
  const [saving, setSaving] = useState<boolean>(false);

  // Delete dialog state
  const [deletingHoliday, setDeletingHoliday] = useState<LeaveCalendarHoliday | null>(null);

  // Reset year dialog state (triggered from top Masters header "Reset" button)
  const [isResetDialogOpen, setIsResetDialogOpen] = useState<boolean>(false);
  const [clearingYear, setClearingYear] = useState<boolean>(false);

  const loadHolidays = useCallback(async (year: number) => {
    setLoading(true);
    try {
      const data = await fetchLeaveCalendarHolidays(year);
      setHolidays(data);
      onCountChange?.(data.length);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to load holiday calendar");
    } finally {
      setLoading(false);
    }
  }, [onCountChange]);

  useEffect(() => {
    void loadHolidays(selectedYear);
  }, [loadHolidays, selectedYear]);

  // Listen for reset trigger from top Masters header "Reset" button
  useEffect(() => {
    const handleResetEvent = () => {
      setIsResetDialogOpen(true);
    };
    window.addEventListener("tk:reset-holiday-calendar", handleResetEvent);
    return () => window.removeEventListener("tk:reset-holiday-calendar", handleResetEvent);
  }, []);

  // Filtered holidays
  const filteredHolidays = useMemo(() => {
    if (!searchQuery.trim()) return holidays;
    const q = searchQuery.toLowerCase();
    return holidays.filter((h) => h.name.toLowerCase().includes(q));
  }, [holidays, searchQuery]);

  const handleOpenAddDialog = (initialDate?: string) => {
    const defaultDate = initialDate ?? `${selectedYear}-01-01`;
    setEditingHoliday(null);
    setFormData({
      date: defaultDate,
      name: "",
    });
    setFormError(null);
    setIsDialogOpen(true);
  };

  const handleOpenEditDialog = (holiday: LeaveCalendarHoliday) => {
    setEditingHoliday(holiday);
    setFormData({
      date: holiday.date,
      name: holiday.name,
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

  const handleClearYear = async () => {
    try {
      setClearingYear(true);
      await clearLeaveCalendarYear(selectedYear);
      setHolidays([]);
      onCountChange?.(0);
      toast.success(`All holidays for ${selectedYear} have been cleared.`);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to clear holidays");
    } finally {
      setClearingYear(false);
      setIsResetDialogOpen(false);
    }
  };

  const handleLoadPreviousHolidays = async () => {
    const prevYear = selectedYear - 1;
    try {
      setLoading(true);
      const prevHolidays = await fetchLeaveCalendarHolidays(prevYear);
      if (!prevHolidays || prevHolidays.length === 0) {
        toast.info(`No holidays found in ${prevYear} to load.`);
        return;
      }

      const isLeap = (y: number) => (y % 4 === 0 && y % 100 !== 0) || y % 400 === 0;

      const mapped: UpsertLeaveCalendarHolidayPayload[] = prevHolidays.map((h) => {
        let mmdd = h.date.slice(5);
        if (mmdd === "02-29" && !isLeap(selectedYear)) {
          mmdd = "02-28";
        }
        return {
          date: `${selectedYear}-${mmdd}`,
          name: h.name,
        };
      });

      // Deduplicate by date
      const mapByDate = new Map<string, UpsertLeaveCalendarHolidayPayload>();
      for (const item of mapped) {
        mapByDate.set(item.date, item);
      }
      const uniquePayload = Array.from(mapByDate.values());

      await bulkCreateLeaveCalendarHolidays(uniquePayload);
      toast.success(`Loaded ${uniquePayload.length} holidays from ${prevYear} into ${selectedYear}.`);
      await loadHolidays(selectedYear);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to load previous year holidays");
    } finally {
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
            <h2 className="text-xl font-bold tracking-tight text-foreground">Holiday Calendar</h2>
            <Badge variant="outline" className="font-mono text-xs font-semibold px-2">
              {selectedYear}
            </Badge>
          </div>
          <p className="text-xs text-muted-foreground mt-0.5">
            Configure full year holidays. Reflects across the Team Dashboard.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {/* Year Switcher (restricted to maximum 1 year back: minYear = currentYear - 1) */}
          <div className="flex items-center rounded-lg border border-border bg-card p-0.5 shadow-2xs">
            <Button
              variant="ghost"
              size="icon"
              className="h-7 w-7 disabled:opacity-40 disabled:cursor-not-allowed"
              onClick={() => setSelectedYear((y) => Math.max(minYear, y - 1))}
              disabled={selectedYear <= minYear}
              title={selectedYear <= minYear ? `Cannot navigate earlier than ${minYear}` : "Previous Year"}
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

          {/* View Switcher: Full Year View first (default), List View secondary */}
          <div className="flex items-center rounded-lg border border-border bg-card p-0.5 shadow-2xs">
            <Button
              variant={activeView === "calendar" ? "secondary" : "ghost"}
              size="sm"
              className="h-7 px-2.5 text-xs gap-1.5"
              onClick={() => setActiveView("calendar")}
            >
              <CalendarIcon className="h-3.5 w-3.5" />
              <span>Full Year View</span>
            </Button>
            <Button
              variant={activeView === "table" ? "secondary" : "ghost"}
              size="sm"
              className="h-7 px-2.5 text-xs gap-1.5"
              onClick={() => setActiveView("table")}
            >
              <ListFilter className="h-3.5 w-3.5" />
              <span>List View</span>
            </Button>
          </div>

          {/* Load Previous Holidays Button */}
          <Button
            variant="outline"
            size="sm"
            onClick={handleLoadPreviousHolidays}
            className="h-7 text-xs gap-1.5 border-dashed"
            title={`Load holidays from ${selectedYear - 1} into ${selectedYear}`}
          >
            <History className="h-3.5 w-3.5 text-blue-500" />
            <span>Load Previous Holidays</span>
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

      {/* ── Metric Summary: Total Holidays with info icon & legend ────── */}
      <div className="flex items-center justify-between gap-3">
        <div className="rounded-xl border border-border/70 bg-card p-3 shadow-2xs min-w-[200px]">
          <div className="flex items-center gap-1.5 text-[11px] font-medium text-muted-foreground uppercase tracking-wider">
            <span>Total Holidays</span>
            <TooltipProvider delayDuration={150}>
              <Tooltip>
                <TooltipTrigger asChild>
                  <button
                    type="button"
                    className="inline-flex items-center justify-center text-muted-foreground hover:text-foreground transition-colors cursor-help"
                    title="Click any holiday to edit. Click any empty date to quickly add a new holiday."
                  >
                    <Info className="h-3.5 w-3.5" />
                    <span className="sr-only">Holiday instructions</span>
                  </button>
                </TooltipTrigger>
                <TooltipContent side="top" className="text-xs max-w-xs shadow-md">
                  Click any holiday to edit. Click any empty date to quickly add a new holiday.
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </div>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-foreground">{holidays.length}</span>
            <span className="text-[11px] text-muted-foreground font-medium">days in {selectedYear}</span>
          </div>
        </div>

        {activeView === "calendar" && (
          <div className="flex items-center gap-2 text-xs font-medium text-muted-foreground">
            <span
              className="h-2.5 w-2.5 rounded-full"
              style={{ backgroundColor: HOLIDAY_COLOR }}
            />
            <span>Holiday</span>
          </div>
        )}
      </div>

      {/* ── Search Bar (only shown in table view or available across views) ─ */}
      {activeView === "table" && (
        <div className="flex items-center justify-between">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
            <Input
              placeholder="Search holiday by name..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="h-8 pl-8 text-xs"
            />
          </div>
        </div>
      )}

      {/* ── Full Year 12-Month Calendar View (Primary / Default) ──────── */}
      {activeView === "calendar" && (
        <FullYearCalendarView
          year={selectedYear}
          holidays={filteredHolidays}
          onAddDate={(dateStr) => handleOpenAddDialog(dateStr)}
          onEditHoliday={(holiday) => handleOpenEditDialog(holiday)}
        />
      )}

      {/* ── Table / List View (Secondary) ─────────────────────────────── */}
      {activeView === "table" && (
        <div className="rounded-xl border border-border bg-card shadow-2xs overflow-hidden">
          {loading ? (
            <div className="p-12 text-center text-xs text-muted-foreground">
              Loading Holiday Calendar for {selectedYear}...
            </div>
          ) : filteredHolidays.length === 0 ? (
            <div className="p-12 text-center">
              <CalendarDays className="mx-auto h-8 w-8 text-muted-foreground/50 mb-2" />
              <div className="text-sm font-semibold text-foreground">No holidays found</div>
              <p className="text-xs text-muted-foreground mt-1 max-w-sm mx-auto">
                No holidays registered for {selectedYear} matching your criteria. Click &quot;Add Holiday&quot; or &quot;Load Previous Holidays&quot; to configure holidays.
              </p>
              <div className="mt-4 flex justify-center gap-2">
                <Button size="sm" onClick={() => handleOpenAddDialog()} className="h-7 text-xs">
                  <Plus className="h-3 w-3 mr-1" /> Add Holiday
                </Button>
                <Button variant="outline" size="sm" onClick={handleLoadPreviousHolidays} className="h-7 text-xs">
                  <History className="h-3 w-3 mr-1 text-blue-500" /> Load Previous Holidays
                </Button>
              </div>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead>
                  <tr className="border-b border-border bg-muted/40 font-semibold text-muted-foreground">
                    <th className="py-2.5 px-4 w-56">Date</th>
                    <th className="py-2.5 px-4">Holiday Name</th>
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
                        <td className="py-3 px-4 font-medium whitespace-nowrap text-foreground">
                          <div className="flex items-center gap-2">
                            <span
                              className="h-2.5 w-2.5 shrink-0 rounded-full"
                              style={{ backgroundColor: HOLIDAY_COLOR }}
                            />
                            <span>{formatDateLabel(holiday.date)}</span>
                          </div>
                        </td>
                        <td className="py-3 px-4 font-semibold text-foreground">
                          {holiday.name}
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

      {/* ── Add / Edit Holiday Dialog ─────────────────────────────────── */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>
              {editingHoliday ? "Edit Holiday" : "Add Holiday"}
            </DialogTitle>
            <DialogDescription>
              Holidays configured here will be marked across the Team Dashboard.
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

      {/* ── Reset Year Confirmation Dialog ────────────────────────────── */}
      <AlertDialog open={isResetDialogOpen} onOpenChange={setIsResetDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Reset {selectedYear} Holidays?</AlertDialogTitle>
            <AlertDialogDescription>
              This will clear all {holidays.length} holiday{holidays.length === 1 ? "" : "s"} for the year {selectedYear}. This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={clearingYear} className="h-8 text-xs">
              Cancel
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={handleClearYear}
              disabled={clearingYear}
              className="h-8 text-xs bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              {clearingYear ? "Clearing..." : "Reset & Clear"}
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
                        style={{ backgroundColor: HOLIDAY_COLOR }}
                        title={`${holiday.name} · Click to edit`}
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
