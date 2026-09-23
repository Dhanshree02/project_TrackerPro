// ─── My Team — Member Schedule & Holidays Dialog ─────────────────────────────

import { useEffect, useMemo, useState } from "react";
import {
  Calendar,
  CalendarDays,
  Check,
  Clock,
  Info,
  MessageSquare,
  Plus,
  Trash2,
  X,
} from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { formatDateDMY } from "@/lib/utils";
import type {
  MemberHoliday,
  MemberScheduleConfig,
  TeamMember,
} from "../types";
import { DEFAULT_MEMBER_SCHEDULE_CONFIG } from "../types";

interface MemberScheduleDialogProps {
  member: TeamMember | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  config?: MemberScheduleConfig;
  onSave: (memberId: string, updatedConfig: MemberScheduleConfig) => void;
}

const DAYS_OF_WEEK = [
  { day: 1, label: "Mon", full: "Monday" },
  { day: 2, label: "Tue", full: "Tuesday" },
  { day: 3, label: "Wed", full: "Wednesday" },
  { day: 4, label: "Thu", full: "Thursday" },
  { day: 5, label: "Fri", full: "Friday" },
  { day: 6, label: "Sat", full: "Saturday" },
  { day: 0, label: "Sun", full: "Sunday" },
];

export function MemberScheduleDialog({
  member,
  open,
  onOpenChange,
  config,
  onSave,
}: MemberScheduleDialogProps) {
  // Local draft state
  const [workingDays, setWorkingDays] = useState<number[]>([1, 2, 3, 4, 5]);
  const [holidays, setHolidays] = useState<MemberHoliday[]>([]);
  const [notes, setNotes] = useState("");

  // New holiday form state
  const [newHolidayDate, setNewHolidayDate] = useState("");
  const [newHolidayName, setNewHolidayName] = useState("");
  const [newHolidayComment, setNewHolidayComment] = useState("");
  const [formError, setFormError] = useState("");

  // Synchronize draft state whenever dialog opens with a new member/config
  useEffect(() => {
    if (open && member) {
      const initial = config || DEFAULT_MEMBER_SCHEDULE_CONFIG;
      setWorkingDays(initial.workingDays || [1, 2, 3, 4, 5]);
      setHolidays(initial.holidays || []);
      setNotes(initial.notes || "");
      setNewHolidayDate("");
      setNewHolidayName("");
      setNewHolidayComment("");
      setFormError("");
    }
  }, [open, member, config]);

  // Today's minimum selectable date for new holidays (YYYY-MM-DD)
  const todayKey = useMemo(() => {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
  }, []);

  if (!member) return null;

  const toggleDay = (day: number) => {
    setWorkingDays((prev) => {
      if (prev.includes(day)) {
        if (prev.length <= 1) return prev; // Keep at least 1 working day
        return prev.filter((d) => d !== day);
      }
      return [...prev, day].sort((a, b) => (a === 0 ? 7 : a) - (b === 0 ? 7 : b));
    });
  };

  const setPreset = (presetDays: number[]) => {
    setWorkingDays(presetDays);
  };

  const handleAddHoliday = () => {
    if (!newHolidayDate) {
      setFormError("Please select a date for the holiday.");
      return;
    }
    if (!newHolidayName.trim()) {
      setFormError("Please enter a name for the holiday.");
      return;
    }
    if (holidays.some((h) => h.date === newHolidayDate)) {
      setFormError("A holiday is already added for this date.");
      return;
    }

    const entry: MemberHoliday = {
      date: newHolidayDate,
      name: newHolidayName.trim(),
      comment: newHolidayComment.trim() || undefined,
    };

    setHolidays((prev) => [...prev, entry].sort((a, b) => a.date.localeCompare(b.date)));
    setNewHolidayDate("");
    setNewHolidayName("");
    setNewHolidayComment("");
    setFormError("");
  };

  const handleRemoveHoliday = (date: string) => {
    setHolidays((prev) => prev.filter((h) => h.date !== date));
  };

  const handleSave = () => {
    onSave(member.id, {
      workingDays,
      holidays,
      notes: notes.trim() || undefined,
    });
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-xl max-h-[90vh] overflow-y-auto p-0 gap-0 rounded-2xl border border-white/60 bg-white shadow-2xl dark:bg-slate-900 dark:border-white/10">
        {/* Header */}
        <div className="relative border-b border-[#edf0f4] bg-slate-50/80 px-6 py-4 dark:border-slate-800 dark:bg-slate-900/80">
          <div className="flex items-center gap-3">
            <div
              className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full text-xs font-bold text-white shadow-xs"
              style={{ backgroundColor: member.avatarColor }}
            >
              {member.initials}
            </div>
            <div className="min-w-0 flex-1">
              <div className="flex items-center gap-2">
                <DialogTitle className="text-base font-bold text-[#1e293b] dark:text-white">
                  Schedule & Holidays
                </DialogTitle>
                <span className="rounded-full bg-primary/10 px-2 py-0.5 text-[10px] font-semibold text-primary">
                  {member.name}
                </span>
              </div>
              <DialogDescription className="mt-0.5 text-xs text-muted-foreground">
                {member.designation} · {member.department}
              </DialogDescription>
            </div>
          </div>
        </div>

        <div className="space-y-5 px-6 py-5">
          {/* Section 1: Working Days */}
          <section className="rounded-xl border border-[#edf0f4] bg-white p-4 shadow-2xs dark:border-slate-800 dark:bg-slate-900/50">
            <div className="flex items-center justify-between gap-2 mb-2.5">
              <div className="flex items-center gap-1.5">
                <Clock className="h-4 w-4 text-[#5a49b8]" />
                <h3 className="text-xs font-bold uppercase tracking-wider text-[#3d3d5c] dark:text-slate-200">
                  Working Days & Weekly Offs
                </h3>
              </div>
              <span className="text-[11px] font-medium text-muted-foreground">
                {workingDays.length} working days / week
              </span>
            </div>

            <p className="text-[11.5px] text-muted-foreground mb-3">
              Configure which days {member.name} works. Days unselected will be treated as{" "}
              <strong className="text-[#3d3d5c] dark:text-slate-200">Weekly Off</strong>.
            </p>

            {/* Quick Presets */}
            <div className="flex flex-wrap gap-1.5 mb-3">
              <span className="text-[10px] font-semibold text-slate-400 self-center mr-1">
                Presets:
              </span>
              <button
                type="button"
                onClick={() => setPreset([1, 2, 3, 4, 5])}
                className="rounded-lg border border-slate-200 bg-slate-50 px-2.5 py-1 text-[10.5px] font-medium text-slate-700 hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300"
              >
                Mon–Fri (Standard)
              </button>
              <button
                type="button"
                onClick={() => setPreset([0, 1, 2, 3, 4])}
                className="rounded-lg border border-slate-200 bg-slate-50 px-2.5 py-1 text-[10.5px] font-medium text-slate-700 hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300"
              >
                Sun–Thu (Middle East / Onsite)
              </button>
              <button
                type="button"
                onClick={() => setPreset([1, 2, 3, 4, 5, 6])}
                className="rounded-lg border border-slate-200 bg-slate-50 px-2.5 py-1 text-[10.5px] font-medium text-slate-700 hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300"
              >
                Mon–Sat (6-Day)
              </button>
            </div>

            {/* Day Chips */}
            <div className="grid grid-cols-7 gap-1.5">
              {DAYS_OF_WEEK.map(({ day, label, full }) => {
                const isWorking = workingDays.includes(day);
                return (
                  <button
                    key={day}
                    type="button"
                    onClick={() => toggleDay(day)}
                    title={`${full}: ${isWorking ? "Working Day" : "Weekly Off"}`}
                    className={`flex flex-col items-center justify-center rounded-xl py-2 px-1 text-center transition-all ${
                      isWorking
                        ? "bg-[#5a49b8] text-white shadow-xs font-bold"
                        : "border border-slate-200 bg-slate-100/70 text-slate-500 hover:bg-slate-200/60 dark:border-slate-800 dark:bg-slate-800/40"
                    }`}
                  >
                    <span className="text-[11.5px]">{label}</span>
                    <span
                      className={`text-[9px] font-medium mt-0.5 ${
                        isWorking ? "text-white/85" : "text-slate-400"
                      }`}
                    >
                      {isWorking ? "Work" : "Off"}
                    </span>
                  </button>
                );
              })}
            </div>
          </section>

          {/* Section 2: Custom Holidays */}
          <section className="rounded-xl border border-[#edf0f4] bg-white p-4 shadow-2xs dark:border-slate-800 dark:bg-slate-900/50">
            <div className="flex items-center justify-between gap-2 mb-2.5">
              <div className="flex items-center gap-1.5">
                <CalendarDays className="h-4 w-4 text-[#5a49b8]" />
                <h3 className="text-xs font-bold uppercase tracking-wider text-[#3d3d5c] dark:text-slate-200">
                  Custom Holidays (Onsite / Regional / Client)
                </h3>
              </div>
            </div>

            <p className="text-[11.5px] text-muted-foreground mb-3">
              Add custom holidays specific to {member.name}&apos;s location, onsite client schedule, or regional calendar.
            </p>

            {/* Add Holiday Form */}
            <div className="space-y-2 rounded-lg border border-slate-200 bg-slate-50/70 p-3 dark:border-slate-800 dark:bg-slate-800/40">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                <div>
                  <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-500 mb-1">
                    Date
                  </label>
                  <input
                    type="date"
                    value={newHolidayDate}
                    min={todayKey}
                    onChange={(e) => {
                      setNewHolidayDate(e.target.value);
                      setFormError("");
                    }}
                    className="w-full rounded-md border border-slate-200 bg-white px-2.5 py-1.5 text-xs text-slate-800 shadow-2xs outline-none focus:border-[#5a49b8] focus:ring-1 focus:ring-[#5a49b8] dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100"
                  />
                </div>
                <div>
                  <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-500 mb-1">
                    Holiday Name
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. US Thanksgiving, Client Holiday"
                    value={newHolidayName}
                    onChange={(e) => {
                      setNewHolidayName(e.target.value);
                      setFormError("");
                    }}
                    className="w-full rounded-md border border-slate-200 bg-white px-2.5 py-1.5 text-xs text-slate-800 shadow-2xs outline-none focus:border-[#5a49b8] focus:ring-1 focus:ring-[#5a49b8] dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-500 mb-1">
                  Comment / Reason (Optional)
                </label>
                <div className="flex gap-2">
                  <input
                    type="text"
                    placeholder="e.g. Client office closed; remote support only"
                    value={newHolidayComment}
                    onChange={(e) => setNewHolidayComment(e.target.value)}
                    className="flex-1 rounded-md border border-slate-200 bg-white px-2.5 py-1.5 text-xs text-slate-800 shadow-2xs outline-none focus:border-[#5a49b8] focus:ring-1 focus:ring-[#5a49b8] dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100"
                  />
                  <button
                    type="button"
                    onClick={handleAddHoliday}
                    className="inline-flex items-center gap-1 rounded-md bg-[#5a49b8] px-3 py-1.5 text-xs font-semibold text-white shadow-2xs transition hover:bg-[#4e3fa4]"
                  >
                    <Plus className="h-3.5 w-3.5" />
                    Add
                  </button>
                </div>
              </div>

              {formError && (
                <p className="text-[10.5px] font-medium text-red-500">{formError}</p>
              )}
            </div>

            {/* Configured Holidays List */}
            <div className="mt-3 space-y-1.5">
              <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                Configured Holidays ({holidays.length})
              </p>
              {holidays.length === 0 ? (
                <p className="py-2 text-center text-xs text-muted-foreground italic">
                  No custom holidays added yet for this employee.
                </p>
              ) : (
                <div className="max-h-44 space-y-1.5 overflow-y-auto pr-1">
                  {holidays.map((h) => (
                    <div
                      key={h.date}
                      className="flex items-center justify-between rounded-lg border border-[#edf0f4] bg-slate-50/70 px-3 py-2 text-xs dark:border-slate-800 dark:bg-slate-800/50"
                    >
                      <div className="min-w-0 flex-1 pr-2">
                        <div className="flex items-center gap-2">
                          <span className="rounded bg-slate-200/80 px-2 py-0.5 text-[10.5px] font-bold text-slate-700 dark:bg-slate-700 dark:text-slate-200">
                            {formatDateDMY(h.date)}
                          </span>
                          <span className="font-semibold text-slate-800 dark:text-slate-200">
                            {h.name}
                          </span>
                        </div>
                        {h.comment && (
                          <div className="mt-1 flex items-center gap-1 text-[11px] text-muted-foreground">
                            <MessageSquare className="h-3 w-3 shrink-0 text-slate-400" />
                            <span className="truncate italic">{h.comment}</span>
                          </div>
                        )}
                      </div>
                      <button
                        type="button"
                        onClick={() => handleRemoveHoliday(h.date)}
                        className="rounded p-1 text-slate-400 transition hover:bg-red-50 hover:text-red-500 dark:hover:bg-red-950/30"
                        title={`Remove ${h.name}`}
                      >
                        <Trash2 className="h-3.5 w-3.5" />
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </section>

          {/* Section 3: Schedule Notes / Comments */}
          <section className="rounded-xl border border-[#edf0f4] bg-white p-4 shadow-2xs dark:border-slate-800 dark:bg-slate-900/50">
            <div className="flex items-center gap-1.5 mb-2">
              <MessageSquare className="h-4 w-4 text-[#5a49b8]" />
              <h3 className="text-xs font-bold uppercase tracking-wider text-[#3d3d5c] dark:text-slate-200">
                Schedule Notes & Comments
              </h3>
            </div>
            <p className="text-[11.5px] text-muted-foreground mb-2">
              Add any general context or remarks regarding this employee&apos;s schedule, client timezone, or onsite deployment.
            </p>
            <textarea
              rows={2}
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="e.g. Onsite deployment at New York client office until Q4. Follows US Eastern client calendar."
              className="w-full rounded-md border border-slate-200 bg-white p-2.5 text-xs text-slate-800 shadow-2xs outline-none focus:border-[#5a49b8] focus:ring-1 focus:ring-[#5a49b8] dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100 resize-none"
            />
          </section>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-end gap-2.5 border-t border-[#edf0f4] bg-slate-50/80 px-6 py-3.5 dark:border-slate-800 dark:bg-slate-900/80">
          <button
            type="button"
            onClick={() => onOpenChange(false)}
            className="rounded-lg border border-slate-200 bg-white px-3.5 py-1.5 text-xs font-semibold text-slate-600 transition hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={handleSave}
            className="inline-flex items-center gap-1.5 rounded-lg bg-[#5a49b8] px-4 py-1.5 text-xs font-bold text-white shadow-xs transition hover:bg-[#4e3fa4]"
          >
            <Check className="h-3.5 w-3.5" />
            Save Schedule & Holidays
          </button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
