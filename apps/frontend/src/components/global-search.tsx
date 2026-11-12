import { useCallback, useEffect, useMemo, useRef, useState, type KeyboardEvent } from "react";
import { useNavigate } from "@tanstack/react-router";
import { Briefcase, Building2, FileText, ListTodo, Search, Split, UserRound } from "lucide-react";
import { fetchClients } from "@/modules/customers/api/clients";
import { fetchEmployees } from "@/modules/employees/api/employees";
import { fetchProjects, searchProjectTasks } from "@/modules/projects/api/projects";
import { fetchRepositoryDocuments } from "@/modules/repository/api/repository";
import { cn } from "@/lib/utils";

type SearchKind = "employee" | "tk-id" | "customer" | "sub-venture" | "project" | "task" | "document";

type SearchHit = {
  key: string;
  kind: SearchKind;
  id: string;
  title: string;
  subtitle: string;
  start?: string | null;
  end?: string | null;
  /** Financial-year start year taken from a WBS id such as IN-2026-27. */
  fyYear?: number | null;
  hash?: string;
};

const RECENT_KEY = "pulse-global-search-recent";
const LIMIT = 5;
const KIND_ORDER: SearchKind[] = ["employee", "tk-id", "customer", "sub-venture", "project", "task", "document"];

const KIND_LABEL: Record<SearchKind, string> = {
  employee: "Employees",
  "tk-id": "TK IDs",
  customer: "Customers",
  "sub-venture": "Sub-ventures",
  project: "Projects",
  task: "Tasks",
  document: "Documents",
};

const KIND_ICON = {
  employee: UserRound,
  "tk-id": UserRound,
  customer: Building2,
  "sub-venture": Split,
  project: Briefcase,
  task: ListTodo,
  document: FileText,
} as const;

function initials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  const first = parts[0]?.[0] ?? "";
  const last = parts.length > 1 ? parts[parts.length - 1]?.[0] ?? "" : "";
  return (first + last).toUpperCase() || "?";
}

function fyFromWbs(wbs?: string | null): number | null {
  const match = wbs?.match(/IN-(\d{4})-\d{2}/i);
  if (!match) return null;
  const year = Number(match[1]);
  return Number.isFinite(year) ? year : null;
}

function readRecent(): SearchHit[] {
  try {
    const raw = localStorage.getItem(RECENT_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw) as SearchHit[];
    if (!Array.isArray(parsed)) return [];
    return parsed.filter((row) => row && row.id && row.title && row.kind).slice(0, 8);
  } catch {
    return [];
  }
}

function writeRecent(hit: SearchHit) {
  const next = [hit, ...readRecent().filter((row) => row.key !== hit.key)].slice(0, 8);
  localStorage.setItem(RECENT_KEY, JSON.stringify(next));
}

function Highlight({ text, query }: { text: string; query: string }) {
  const needle = query.trim();
  if (!needle) return <>{text}</>;
  const at = text.toLowerCase().indexOf(needle.toLowerCase());
  if (at < 0) return <>{text}</>;
  return (
    <>
      {text.slice(0, at)}
      <mark className="bg-transparent font-semibold text-primary">{text.slice(at, at + needle.length)}</mark>
      {text.slice(at + needle.length)}
    </>
  );
}

async function searchAll(query: string): Promise<SearchHit[]> {
  const needle = query.trim().toLowerCase();
  const [employees, customers, projects, tasks, documents] = await Promise.allSettled([
    fetchEmployees({ search: query, page: 1, perPage: LIMIT }),
    fetchClients(1, LIMIT, query),
    fetchProjects({ search: query, page: 1, perPage: LIMIT }),
    searchProjectTasks(query, LIMIT),
    fetchRepositoryDocuments({ search: query, page: 1, perPage: LIMIT }),
  ]);

  const hits: SearchHit[] = [];

  if (employees.status === "fulfilled") {
    for (const person of employees.value.items ?? []) {
      const when = person.joiningDate || person.createdAtUtc;
      const meta = [person.employeeCode, person.designation, person.department].filter(Boolean).join(" · ");
      hits.push({
        key: `employee:${person.id}`,
        kind: "employee",
        id: person.id,
        title: person.fullName || person.employeeCode,
        subtitle: meta || person.workEmail || "Employee",
        start: when,
        end: when,
      });
      if (person.employeeCode) {
        hits.push({
          key: `tk-id:${person.id}`,
          kind: "tk-id",
          id: person.id,
          title: person.employeeCode,
          subtitle: [person.fullName, person.designation].filter(Boolean).join(" · ") || "Employee",
          start: when,
          end: when,
        });
      }
    }
  }

  if (customers.status === "fulfilled") {
    for (const client of customers.value ?? []) {
      const when = client.customerSince || client.createdAtUtc;
      const meta = [client.clientCode, client.industry, client.city].filter(Boolean).join(" · ");
      hits.push({
        key: `customer:${client.id}`,
        kind: "customer",
        id: client.id,
        title: client.name,
        subtitle: meta || "Customer",
        start: when,
        end: when,
      });
      let subVentureCount = 0;
      for (const venture of client.subVentures ?? []) {
        if (subVentureCount >= LIMIT) break;
        const blob = [venture.name, venture.subVentureCode, venture.notes].filter(Boolean).join(" ").toLowerCase();
        if (!blob.includes(needle)) continue;
        subVentureCount += 1;
        hits.push({
          key: `sub-venture:${client.id}:${venture.id}`,
          kind: "sub-venture",
          id: client.id,
          title: venture.name,
          subtitle: [venture.subVentureCode, client.name, client.clientCode].filter(Boolean).join(" · ") || "Sub-venture",
          start: when,
          end: when,
          hash: `sv=${encodeURIComponent(venture.name)}`,
        });
      }
    }
  }

  if (projects.status === "fulfilled") {
    for (const project of projects.value.items ?? []) {
      const meta = [project.wbsId || project.projectCode, project.clientName, project.status].filter(Boolean).join(" · ");
      hits.push({
        key: `project:${project.id}`,
        kind: "project",
        id: project.id,
        title: project.name,
        subtitle: meta || "Project",
        start: project.startDate || project.createdAtUtc,
        end: project.endDate || project.startDate || project.createdAtUtc,
        fyYear: fyFromWbs(project.wbsId),
      });
    }
  }

  if (tasks.status === "fulfilled") {
    for (const task of tasks.value ?? []) {
      const meta = [task.projectName, task.wbsId || task.projectCode].filter(Boolean).join(" · ");
      hits.push({
        key: `task:${task.id}`,
        kind: "task",
        id: task.projectId,
        title: task.title,
        subtitle: meta || "Task",
        start: task.plannedStartDate || task.projectStartDate,
        end: task.plannedEndDate || task.projectEndDate || task.plannedStartDate || task.projectStartDate,
        fyYear: fyFromWbs(task.wbsId),
        hash: "tasks",
      });
    }
  }

  if (documents.status === "fulfilled") {
    for (const doc of documents.value.items ?? []) {
      const when = doc.createdAtUtc || doc.lastUpdated;
      hits.push({
        key: `document:${doc.id}`,
        kind: "document",
        id: doc.id,
        title: doc.fileName,
        subtitle: [doc.category, doc.uploadedBy].filter(Boolean).join(" · ") || "Repository",
        start: when,
        end: when,
        hash: `q=${encodeURIComponent(doc.fileName)}`,
      });
    }
  }

  return hits.slice(0, LIMIT * KIND_ORDER.length);
}

export function GlobalSearch() {
  const navigate = useNavigate();
  const rootRef = useRef<HTMLDivElement>(null);
  const barRef = useRef<HTMLInputElement>(null);
  const panelRef = useRef<HTMLInputElement>(null);
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [hits, setHits] = useState<SearchHit[]>([]);
  const [recent, setRecent] = useState<SearchHit[]>([]);
  const [active, setActive] = useState(0);
  const requestId = useRef(0);

  const showingRecent = query.trim().length === 0;
  const rows = showingRecent ? recent : hits;

  const groups = useMemo(() => {
    if (showingRecent) return recent.length ? [{ kind: "recent" as const, label: "Recent", rows: recent }] : [];
    return KIND_ORDER.map((kind) => ({
      kind,
      label: KIND_LABEL[kind],
      rows: hits.filter((hit) => hit.kind === kind),
    })).filter((group) => group.rows.length > 0);
  }, [hits, showingRecent, recent]);

  useEffect(() => {
    const onPointer = (event: MouseEvent) => {
      if (!rootRef.current?.contains(event.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", onPointer);
    return () => document.removeEventListener("mousedown", onPointer);
  }, []);

  useEffect(() => {
    const needle = query.trim();
    if (!needle) {
      setHits([]);
      setLoading(false);
      setActive(0);
      return;
    }
    const id = ++requestId.current;
    setLoading(true);
    const timer = window.setTimeout(() => {
      void searchAll(needle)
        .then((next) => {
          if (requestId.current !== id) return;
          setHits(next);
          setActive(0);
        })
        .finally(() => {
          if (requestId.current === id) setLoading(false);
        });
    }, 250);
    return () => window.clearTimeout(timer);
  }, [query]);

  const openHit = useCallback(
    (hit: SearchHit) => {
      writeRecent(hit);
      setRecent(readRecent());
      setOpen(false);
      setQuery("");
      barRef.current?.blur();
      panelRef.current?.blur();
      const hash = hit.hash;
      if (hit.kind === "employee" || hit.kind === "tk-id") {
        void navigate({ to: "/employee-directory/$id", params: { id: hit.id } });
      } else if (hit.kind === "customer" || hit.kind === "sub-venture") {
        void navigate({ to: "/customers/$clientId", params: { clientId: hit.id }, hash });
      } else if (hit.kind === "document") {
        void navigate({ to: "/repository", hash });
      } else {
        void navigate({ to: "/projects/$projectId", params: { projectId: hit.id }, hash });
      }
    },
    [navigate],
  );

  const focusSearch = () => {
    setRecent(readRecent());
    setOpen(true);
    window.requestAnimationFrame(() => {
      const wide = window.matchMedia("(min-width: 768px)").matches;
      (wide ? barRef : panelRef).current?.focus();
    });
  };

  const onInputKeyDown = (event: KeyboardEvent<HTMLInputElement>) => {
    if (event.key === "Escape") {
      setOpen(false);
      barRef.current?.blur();
      panelRef.current?.blur();
      return;
    }
    if (!open) return;
    if (event.key === "ArrowDown") {
      event.preventDefault();
      setActive((index) => (rows.length === 0 ? 0 : (index + 1) % rows.length));
    } else if (event.key === "ArrowUp") {
      event.preventDefault();
      setActive((index) => (rows.length === 0 ? 0 : (index - 1 + rows.length) % rows.length));
    } else if (event.key === "Enter") {
      const hit = rows[active];
      if (!hit) return;
      event.preventDefault();
      openHit(hit);
    }
  };

  let rowIndex = -1;

  return (
    <div ref={rootRef} className="relative min-w-0 w-full max-w-2xl flex-1">
        <button
          type="button"
          className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border bg-card shadow-2xs hover:bg-accent md:hidden"
          aria-label="Global search"
          onClick={focusSearch}
        >
          <Search className="h-4 w-4" />
        </button>
        <div className="group relative hidden md:block">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground group-focus-within:text-primary" />
          <input
            ref={barRef}
            type="search"
            value={query}
            autoComplete="off"
            placeholder="Search name, TK ID, task, document"
            aria-label="Global search"
            aria-expanded={open}
            aria-controls="global-search-results"
            className="h-9 w-full rounded-full border border-border/80 bg-muted/60 pl-9 pr-3 text-xs outline-none transition-all hover:bg-muted/90 focus-visible:border-primary focus-visible:bg-card focus-visible:ring-2 focus-visible:ring-primary/20 shadow-2xs text-foreground placeholder:text-muted-foreground"
            onChange={(event) => {
              setQuery(event.target.value);
              setOpen(true);
            }}
            onFocus={() => {
              setRecent(readRecent());
              setOpen(true);
            }}
            onKeyDown={onInputKeyDown}
          />
        </div>

        {open && (
          <div
            id="global-search-results"
            role="listbox"
            className="absolute left-0 top-full z-50 mt-2 max-h-[min(28rem,70vh)] w-[min(36rem,calc(100vw-2rem))] overflow-y-auto rounded-xl border border-border bg-popover text-popover-foreground shadow-2xl max-md:fixed max-md:inset-x-3 max-md:top-16 max-md:w-auto"
          >
            <div className="border-b border-border p-2 md:hidden">
              <input
                ref={panelRef}
                type="search"
                value={query}
                autoComplete="off"
                placeholder="Search name, TK ID, task, document"
                aria-label="Global search"
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
                onChange={(event) => setQuery(event.target.value)}
                onKeyDown={onInputKeyDown}
              />
            </div>
            {showingRecent && groups.length === 0 && (
              <p className="px-4 py-6 text-center text-xs text-muted-foreground">
                Search employees, TK IDs, customers, sub-ventures, projects, tasks, or repository documents.
              </p>
            )}

            {!showingRecent && loading && hits.length === 0 && (
              <p className="px-4 py-6 text-center text-xs text-muted-foreground">Searching…</p>
            )}

            {!showingRecent && !loading && hits.length === 0 && (
              <p className="px-4 py-6 text-center text-xs text-muted-foreground">
                No matches for “{query.trim()}”
              </p>
            )}

            {groups.map((group) => (
              <div key={group.label} className="border-b border-border/70 last:border-b-0">
                <p className="px-3 pb-1 pt-2.5 text-[10px] font-semibold uppercase tracking-wider text-muted-foreground">
                  {group.label}
                </p>
                <ul>
                  {group.rows.map((hit) => {
                    rowIndex += 1;
                    const index = rowIndex;
                    const Icon = KIND_ICON[hit.kind];
                    const selected = index === active;
                    return (
                      <li key={hit.key}>
                        <button
                          type="button"
                          role="option"
                          aria-selected={selected}
                          className={cn(
                            "flex w-full items-center gap-3 px-3 py-2 text-left",
                            selected ? "bg-primary/10" : "hover:bg-accent",
                          )}
                          onMouseEnter={() => setActive(index)}
                          onClick={() => openHit(hit)}
                        >
                          <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-muted text-[11px] font-semibold text-foreground">
                            {initials(hit.title)}
                          </span>
                          <span className="min-w-0 flex-1">
                            <span className="block truncate text-sm font-medium text-foreground">
                              <Highlight text={hit.title} query={showingRecent ? "" : query} />
                            </span>
                            <span className="block truncate text-[11px] text-muted-foreground">{hit.subtitle}</span>
                          </span>
                          <Icon className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                        </button>
                      </li>
                    );
                  })}
                </ul>
              </div>
            ))}

            <div className="sticky bottom-0 flex items-center justify-between bg-muted/80 px-3 py-1.5 text-[10px] text-muted-foreground">
              <span>↑↓ move</span>
              <span>Enter open</span>
              <span>Esc close</span>
            </div>
          </div>
        )}
    </div>
  );
}
