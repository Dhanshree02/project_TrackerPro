import { createContext, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from "react";
import { CalendarDays } from "lucide-react";
import { cn } from "@/lib/utils";

const STORAGE_KEY = "pulse-financial-years";

export function currentFyStart(today = new Date()): number {
  return today.getMonth() >= 3 ? today.getFullYear() : today.getFullYear() - 1;
}

export function fyOptions(today = new Date()): number[] {
  const current = currentFyStart(today);
  const years: number[] = [];
  for (let year = current + 1; year >= current - 6; year -= 1) years.push(year);
  return years;
}

export function fyLabel(start: number): string {
  return `FY ${start}-${String(start + 1).slice(-2)}`;
}

export function fyFromWbs(wbs?: string | null): number | null {
  const match = wbs?.match(/IN-(\d{4})-\d{2}/i);
  if (!match) return null;
  const year = Number(match[1]);
  return Number.isFinite(year) ? year : null;
}

function parseIso(value?: string | null): Date | null {
  if (!value) return null;
  const text = value.includes("T") ? value : `${value.slice(0, 10)}T00:00:00`;
  const date = new Date(text);
  return Number.isNaN(date.getTime()) ? null : date;
}

function fyOf(date: Date): number {
  return date.getMonth() >= 3 ? date.getFullYear() : date.getFullYear() - 1;
}

/** Empty years keeps every record. A missing end date counts as today, so people still employed stay in the current year. */
export function inFinancialYears(
  start?: string | null,
  end?: string | null,
  years: number[] = [],
  fyYear?: number | null,
): boolean {
  if (years.length === 0) return true;
  if (fyYear != null && years.includes(fyYear)) return true;
  const from = parseIso(start);
  if (!from) return false;
  const to = parseIso(end) ?? new Date();
  const selected = new Set(years);
  const first = Math.min(fyOf(from), fyOf(to));
  const last = Math.max(fyOf(from), fyOf(to));
  for (let year = first; year <= last; year += 1) {
    if (selected.has(year)) return true;
  }
  return false;
}

type FinancialYearContextValue = {
  years: number[];
  setYears: (next: number[]) => void;
  /** Latest selected start year. Dashboard graphs cover one financial year. */
  chartYear: number | null;
};

const FinancialYearContext = createContext<FinancialYearContextValue | null>(null);

function readStoredYears(): number[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw) as unknown;
    if (!Array.isArray(parsed)) return [];
    return parsed.filter((year): year is number => Number.isInteger(year));
  } catch {
    return [];
  }
}

export function FinancialYearProvider({ children }: { children: ReactNode }) {
  const [years, setYears] = useState<number[]>([]);
  const skipPersist = useRef(true);

  useEffect(() => {
    setYears(readStoredYears());
  }, []);

  useEffect(() => {
    if (skipPersist.current) {
      skipPersist.current = false;
      return;
    }
    localStorage.setItem(STORAGE_KEY, JSON.stringify(years));
  }, [years]);

  const value = useMemo<FinancialYearContextValue>(() => {
    const chartYear = years.length === 0 ? null : Math.max(...years);
    return { years, setYears, chartYear };
  }, [years]);

  return <FinancialYearContext.Provider value={value}>{children}</FinancialYearContext.Provider>;
}

export function useFinancialYear(): FinancialYearContextValue {
  const value = useContext(FinancialYearContext);
  if (!value) return { years: [], setYears: () => {}, chartYear: null };
  return value;
}

function fyButtonLabel(years: number[]): string {
  if (years.length === 0) return "All years";
  const sorted = [...years].sort((a, b) => b - a);
  if (sorted.length === 1) return fyLabel(sorted[0]);
  return `${sorted.length} years`;
}

export function FinancialYearFilter() {
  const { years, setYears } = useFinancialYear();
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const options = useMemo(() => fyOptions(), []);

  useEffect(() => {
    const onPointer = (event: MouseEvent) => {
      if (!ref.current?.contains(event.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", onPointer);
    return () => document.removeEventListener("mousedown", onPointer);
  }, []);

  return (
    <div ref={ref} className="relative shrink-0">
      <button
        type="button"
        aria-label="Financial year"
        aria-expanded={open}
        onClick={() => setOpen((value) => !value)}
        className={cn(
          "inline-flex h-9 items-center gap-1.5 rounded-full border px-2.5 text-xs font-medium shadow-2xs",
          years.length > 0
            ? "border-primary bg-primary/10 text-primary"
            : "border-border bg-card text-foreground hover:bg-accent",
        )}
      >
        <CalendarDays className="h-4 w-4" />
        <span className="max-w-[7.5rem] truncate">{fyButtonLabel(years)}</span>
      </button>
      {open && (
        <div className="absolute right-0 top-full z-50 mt-2 w-64 overflow-hidden rounded-xl border border-border bg-popover p-2 text-popover-foreground shadow-2xl">
          <p className="px-2 pb-0.5 text-[10px] font-semibold uppercase tracking-wider text-muted-foreground">
            Financial year
          </p>
          <p className="px-2 pb-2 text-[10px] text-muted-foreground">
            April to March. One or more years filter the app. Charts use the latest year.
          </p>
          <ul className="max-h-64 overflow-y-auto">
            {options.map((year) => {
              const checked = years.includes(year);
              return (
                <li key={year}>
                  <label className="flex cursor-pointer items-center gap-2 rounded-md px-2 py-1.5 text-sm hover:bg-accent">
                    <input
                      type="checkbox"
                      checked={checked}
                      onChange={() =>
                        setYears(
                          checked ? years.filter((item) => item !== year) : [...years, year].sort((a, b) => b - a),
                        )
                      }
                    />
                    {fyLabel(year)}
                  </label>
                </li>
              );
            })}
          </ul>
          {years.length > 0 && (
            <button
              type="button"
              className="mt-1 w-full rounded-md px-2 py-1.5 text-left text-xs text-muted-foreground hover:bg-accent"
              onClick={() => setYears([])}
            >
              All years
            </button>
          )}
        </div>
      )}
    </div>
  );
}
