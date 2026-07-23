import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { LayoutGrid, List, Search, ArrowRight, X, Building2, Plus, ChevronRight, Check } from "lucide-react";
import { toast } from "sonner";
import { format } from "date-fns";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { type Client } from "@/lib/mock-data";
import { HealthPill, StatusPill, ProgressBar } from "@/components/pills";
import { Modal, Field } from "@/routes/projects.index";
import { dhStore, useDhStore, allClients, allProjects } from "@/lib/dh-store";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/customers")({
  head: () => ({
    meta: [
      { title: "Customers — Pulse PMO" },
      { name: "description", content: "All customers, projects and engagement health." },
    ],
  }),
  component: CustomersPage,
});

function CustomersPage() {
  const { isDhanshree } = useRoleContext();
  const [view, setView] = useState<"card" | "list">("card");
  const [q, setQ] = useState("");
  const [openId, setOpenId] = useState<string | null>(null);
  const [openNew, setOpenNew] = useState(false);

  // Subscribe to store so newly created clients/projects appear immediately
  const extraCount = useDhStore((s) => s.extraClients.length + s.extraProjects.length);
  const clients = useMemo(() => allClients(), [extraCount]);
  const projects = useMemo(() => allProjects(), [extraCount]);

  if (!isDhanshree) return <Navigate to="/" />;

  const enriched = useMemo(() => clients.map((c) => {
    const projs = projects.filter((p) => p.clientId === c.id);
    return {
      client: c,
      total: projs.length,
      active: projs.filter((p) => p.status === "ongoing").length,
      completed: projs.filter((p) => p.status === "completed").length,
    };
  }), [clients, projects]);

  const filtered = enriched.filter(({ client: c }) =>
    !q.trim() || [c.name, c.industry].some((v) => v.toLowerCase().includes(q.toLowerCase())));

  const open = openId ? clients.find((c) => c.id === openId) : null;

  return (
    <AppShell title="Customers" subtitle="Client directory with active and completed engagements">
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative max-w-xs flex-1">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input value={q} onChange={(e) => setQ(e.target.value)}
            placeholder="Search customer or industry…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" />
        </div>
        <div className="ml-auto flex items-center gap-2">
          <div className="flex gap-1 rounded-lg border border-border bg-card p-1 text-xs shadow-sm">
            <button onClick={() => setView("card")}
              className={cn("inline-flex items-center gap-1 rounded-md px-2.5 py-1",
                view === "card" ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}>
              <LayoutGrid className="h-3.5 w-3.5" /> Card
            </button>
            <button onClick={() => setView("list")}
              className={cn("inline-flex items-center gap-1 rounded-md px-2.5 py-1",
                view === "list" ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}>
              <List className="h-3.5 w-3.5" /> List
            </button>
          </div>
          <button onClick={() => setOpenNew(true)}
            className="inline-flex items-center gap-1 rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">
            <Plus className="h-3.5 w-3.5" /> New Client
          </button>
        </div>
      </div>

      {view === "card" ? (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          {filtered.map(({ client: c, total, active }) => (
            <article key={c.id} className="rounded-xl border border-border bg-card p-4 shadow-sm transition-shadow hover:shadow-md">
              <header className="flex items-center gap-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-gradient-to-br from-primary to-info text-base font-semibold text-primary-foreground">
                  {c.logo}
                </div>
                <div className="min-w-0 flex-1">
                  <div className="truncate text-sm font-semibold">{c.name}</div>
                  <div className="text-xs text-muted-foreground">{c.industry}</div>
                </div>
              </header>
              <dl className="mt-3 grid grid-cols-2 gap-2 text-xs">
                <div><dt className="text-muted-foreground">Projects</dt><dd className="font-semibold tabular-nums">{total}</dd></div>
                <div><dt className="text-muted-foreground">Active</dt><dd className="font-semibold tabular-nums text-info">{active}</dd></div>
              </dl>
              <Link to="/customer-detail/$clientId" params={{ clientId: c.id }}
                className="mt-4 inline-flex w-full items-center justify-center gap-1 rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">
                View Details <ArrowRight className="h-3 w-3" />
              </Link>
            </article>
          ))}
        </div>
      ) : (
        <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
          <table className="w-full text-sm">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-3 py-2 font-medium">Client</th>
                <th className="px-3 py-2 font-medium">Industry</th>
                <th className="px-3 py-2 font-medium">Total</th>
                <th className="px-3 py-2 font-medium">Active</th>
                <th className="px-3 py-2 font-medium">Completed</th>
                <th className="px-3 py-2 font-medium">Status</th>
                <th className="px-3 py-2 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {filtered.map(({ client: c, total, active, completed }) => (
                <tr key={c.id} className="hover:bg-accent/30">
                  <td className="px-3 py-2.5">
                    <div className="flex items-center gap-2">
                      <span className="flex h-7 w-7 items-center justify-center rounded-md bg-gradient-to-br from-primary to-info text-[11px] font-semibold text-primary-foreground">{c.logo}</span>
                      <span className="font-medium">{c.name}</span>
                    </div>
                  </td>
                  <td className="px-3 py-2.5 text-muted-foreground">{c.industry}</td>
                  <td className="px-3 py-2.5 tabular-nums">{total}</td>
                  <td className="px-3 py-2.5 tabular-nums text-info">{active}</td>
                  <td className="px-3 py-2.5 tabular-nums text-success">{completed}</td>
                  <td className="px-3 py-2.5">
                    <span className="inline-flex items-center gap-1 rounded-full border border-success/30 bg-success/10 px-2 py-0.5 text-[11px] font-medium text-success">Active</span>
                  </td>
                  <td className="px-3 py-2.5 text-right">
                    <Link to="/customer-detail/$clientId" params={{ clientId: c.id }} className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent">
                      Open <ArrowRight className="h-3 w-3" />
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {open && <CustomerDrawer client={open} onClose={() => setOpenId(null)} />}
      {openNew && <NewClientModal onClose={() => setOpenNew(false)} />}
    </AppShell>
  );
}

// ---------- New Client onboarding (stepper) ----------
interface ContactEntry { name: string; email: string; phone: string; designation: string; }
interface NewClientState {
  clientName: string; companyName: string; customerId: string;
  engagementManager: string; phoneNumber: string; city: string; country: string;
  industry: string; businessType: string;
  createdAt: string; createdBy: string;
  kycFile: File | null;
  contacts: ContactEntry[];
  notes: string;
}

const inputCls = "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring";
const Row = ({ label, v }: { label: string; v: string }) => (<><dt className="text-muted-foreground">{label}</dt><dd className="font-medium">{v || "—"}</dd></>);

function NewClientModal({ onClose }: { onClose: () => void }) {
  const { user } = useRoleContext();
  const [step, setStep] = useState(1);
  const [submitting, setSubmitting] = useState(false);

  // ── TK Customer search state ──
  const existingClients = allClients();
  const [tkSearch, setTkSearch] = useState("");
  const [tkDropOpen, setTkDropOpen] = useState(false);
  const [selectedExisting, setSelectedExisting] = useState<typeof existingClients[0] | null>(null);

  // ── Sub-venture search state (only when existing client selected) ──
  const [svSearch, setSvSearch] = useState("");
  const [svDropOpen, setSvDropOpen] = useState(false);
  const [svAlreadyExists, setSvAlreadyExists] = useState(false);

  const filteredTk = existingClients.filter((c) =>
    tkSearch.trim() === "" ||
    c.name.toLowerCase().includes(tkSearch.toLowerCase())
  );

  const [s, setS] = useState<NewClientState>(() => ({
    clientName: "", companyName: "",
    customerId: "C" + String(allClients().length + 1).padStart(3, "0"),
    engagementManager: "", phoneNumber: "", city: "", country: "",
    industry: "", businessType: "",
    createdAt: new Date().toISOString(),
    createdBy: user?.name ?? "Unknown",
    kycFile: null,
    contacts: [{ name: "", email: "", phone: "", designation: "", contactType: "" }],
    notes: "",
  }));

  const u = (k: keyof Omit<NewClientState, "contacts" | "kycFile">, v: string) =>
    setS((p) => ({ ...p, [k]: v }));

  const MAX_CONTACTS = 4;

  const addContact = () =>
    setS((p) =>
      p.contacts.length >= MAX_CONTACTS
        ? p
        : { ...p, contacts: [...p.contacts, { name: "", email: "", phone: "", designation: "", contactType: "" }] }
    );

  const removeContact = (idx: number) =>
    setS((p) => ({ ...p, contacts: p.contacts.filter((_, i) => i !== idx) }));

  const updateContact = (idx: number, field: keyof ContactEntry, val: string) =>
    setS((p) => ({
      ...p,
      contacts: p.contacts.map((c, i) => (i === idx ? { ...c, [field]: val } : c)),
    }));

  // Validates a phone number.
  // Rejects fake numbers (0000000000), wrong digit counts, impossible formats.
  const isValidPhone = (val: string): boolean => {
    const cleaned = val.trim();
    if (!cleaned) return false;
    const phoneRegex = /^[+]?[(]?[0-9]{1,4}[)]?[-\s./0-9]{6,15}$/;
    const digitsOnly = cleaned.replace(/\D/g, "");
    return phoneRegex.test(cleaned) && digitsOnly.length >= 7 && !/^(.)\1+$/.test(digitsOnly);
  };

  // Returns the first missing required field label, or null if all valid
  const getStep1Error = (): string | null => {
    if (!s.companyName.trim()) return "End Customer / Sub-venture Name is required";
    if (selectedExisting) return null; // existing client — rest auto-filled
    if (!s.clientName.trim()) return "TK Customer / Partner Name is required";
    if (!s.engagementManager.trim()) return "Engagement Manager is required";
    if (!s.phoneNumber.trim()) return "Phone Number is required";
    if (!isValidPhone(s.phoneNumber)) return "Please enter a real, valid phone number (e.g. +91 98765 432XXX)";
    if (!s.city.trim()) return "City is required";
    if (!s.country.trim()) return "Country is required";
    if (!s.industry.trim()) return "Industry is required";
    return null;
  };

  const getStep2Error = (): string | null => {
    for (let i = 0; i < s.contacts.length; i++) {
      const c = s.contacts[i];
      const n = s.contacts.length > 1 ? ` (Contact ${i + 1})` : "";
      if (!c.name.trim()) return `Contact Name${n} is required`;
      if (!c.contactType?.trim()) return `Contact Type${n} is required`;
      if (!c.email.trim()) return `Contact Email${n} is required`;
      if (!c.phone.trim()) return `Contact Phone${n} is required`;
      if (!isValidPhone(c.phone)) return `Contact Phone${n} — please enter a real, valid phone number (e.g. +91 98765 432XXX)`;
      if (!c.designation.trim()) return `Designation${n} is required`;
    }
    if (!s.kycFile) return "KYC Document is required";
    return null;
  };

  const isStep1Valid = () => getStep1Error() === null;
  const isStep2Valid = () => getStep2Error() === null;

  const handleNext = () => {
    if (step === 1) {
      const err = getStep1Error();
      if (err) { toast.error(err); return; }
    }
    if (step === 2) {
      const err = getStep2Error();
      if (err) { toast.error(err); return; }
    }
    setStep((prev) => prev + 1);
  };

  const readOnlyCls = cn(inputCls, "bg-muted text-muted-foreground cursor-not-allowed");

  const submit = () => {
    setSubmitting(true);
    setTimeout(() => {
      const validContacts = s.contacts.filter((c) => c.name.trim() && c.email.trim());
      const primary = validContacts[0] ?? s.contacts[0];

      if (selectedExisting) {
        if (svAlreadyExists) {
          // Sub-venture already exists — nothing to add, just acknowledge
          toast.info("Sub-venture already exists", { description: `${s.companyName} is already under ${selectedExisting.name}.` });
        } else {
          // Adding a new sub-venture to an existing TK customer
          dhStore.addSubVenture(selectedExisting.id, s.companyName.trim(), validContacts);
          toast.success("Sub-venture added", { description: `${s.companyName} added under ${selectedExisting.name}.` });
        }
      } else {
        // Creating a brand new TK customer
        dhStore.addClient({
          name: s.clientName || s.companyName,
          industry: s.industry || "Other",
          contact: primary?.email ?? "",
          contactName: primary?.name ?? "",
          contactPhone: primary?.phone ?? "",
          contactDesignation: primary?.designation ?? "",
          contactType: primary?.contactType || "Primary",
          contacts: validContacts.length > 0 ? validContacts : undefined,
          engagementManager: s.engagementManager,
          companyName: s.companyName,
        });
        toast.success("Client onboarded", { description: `${s.clientName} added to your directory.` });
      }
      setSubmitting(false);
      onClose();
    }, 500);
  };

  return (
    <Modal title="New Customer Onboarding" onClose={onClose} wide draggable>
      {/* Stepper */}
      <div className="mb-5 flex items-center gap-2 text-xs">
        {["Company", "Contact", "Review"].map((label, i) => {
          const n = i + 1;
          const active = step === n;
          const done = step > n;
          return (
            <div key={label} className="flex items-center gap-2">
              <div className={cn(
                "flex h-6 w-6 items-center justify-center rounded-full border text-[11px] font-semibold",
                done
                  ? "border-success bg-success text-success-foreground"
                  : active
                    ? "border-primary bg-primary text-primary-foreground"
                    : "border-border bg-card text-muted-foreground"
              )}>
                {done ? <Check className="h-3 w-3" /> : n}
              </div>
              <span className={cn("font-medium", active ? "text-foreground" : "text-muted-foreground")}>
                {label}
              </span>
              {i < 2 && <ChevronRight className="mx-1 h-3.5 w-3.5 text-muted-foreground" />}
            </div>
          );
        })}
      </div>

      {/* Step 1 — Company details */}
      {step === 1 && (
        <div className="space-y-4">
          {/* ── TK Customer search ── */}
          <div>
            <span className="mb-1 block text-xs font-medium text-muted-foreground">
              TK Customer / Partner Name <span className="text-destructive">*</span>
            </span>
            <div className="relative">
              <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <input
                className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-8 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
                placeholder="Search existing TK customers or type a new name…"
                value={tkSearch}
                onFocus={() => setTkDropOpen(true)}
                onChange={(e) => {
                  // Only allow alphabets, spaces, hyphens, and apostrophes
                  const filtered = e.target.value.replace(/[^a-zA-Z\s\-']/g, "");
                  setTkSearch(filtered);
                  setTkDropOpen(true);
                  // If user edits after selecting, deselect
                  if (selectedExisting && filtered !== selectedExisting.name) {
                    setSelectedExisting(null);
                    setSvSearch(""); setSvDropOpen(false); setSvAlreadyExists(false);
                    setS((p) => ({ ...p, clientName: filtered, companyName: "", engagementManager: "", phoneNumber: "", city: "", country: "", industry: "", businessType: "", customerId: "C" + String(allClients().length + 1).padStart(3, "0") }));
                  } else {
                    setS((p) => ({ ...p, clientName: filtered }));
                  }
                }}
                onBlur={() => setTimeout(() => setTkDropOpen(false), 150)}
              />
              {selectedExisting && (
                <button
                  type="button"
                  className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                  onClick={() => { setSelectedExisting(null); setTkSearch(""); setS((p) => ({ ...p, clientName: "", engagementManager: "", phoneNumber: "", city: "", country: "", industry: "", businessType: "", customerId: "C" + String(allClients().length + 1).padStart(3, "0") })); setSvSearch(""); setSvDropOpen(false); setSvAlreadyExists(false); }}
                  title="Clear selection"
                ><X className="h-3.5 w-3.5" /></button>
              )}
              {tkDropOpen && (
                <div className="absolute left-0 right-0 top-full z-50 mt-1 max-h-56 overflow-y-auto rounded-md border border-border bg-popover shadow-lg">
                  {filteredTk.length > 0 && (
                    <>
                      <div className="px-3 py-1.5 text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">Existing Customers</div>
                      {filteredTk.map((c) => (
                        <button
                          key={c.id}
                          type="button"
                          className="flex w-full items-center gap-3 px-3 py-2 text-left text-sm hover:bg-accent"
                          onMouseDown={() => {
                            setSelectedExisting(c);
                            setTkSearch(c.name);
                            setTkDropOpen(false);
                            setS((p) => ({
                              ...p,
                              clientName: c.name,
                              customerId: c.id,
                              engagementManager: c.engagementManager ?? p.engagementManager,
                              phoneNumber: (c as any).phoneNumber ?? p.phoneNumber,
                              city: (c as any).city ?? p.city,
                              country: (c as any).country ?? p.country,
                              industry: c.industry ?? p.industry,
                              businessType: (c as any).businessType ?? p.businessType,
                              // Do NOT pre-fill contacts — user should enter fresh SPOC details
                              contacts: [{ name: "", email: "", phone: "", designation: "", contactType: "" }],
                            }));
                          }}
                        >
                          <span className="flex h-7 w-7 items-center justify-center rounded-md bg-gradient-to-br from-primary to-info text-[11px] font-semibold text-primary-foreground shrink-0">{c.logo}</span>
                          <div className="min-w-0 flex-1">
                            <div className="truncate font-medium">{c.name}</div>
                            <div className="truncate text-[11px] text-muted-foreground">{c.industry} · {c.id}</div>
                          </div>
                          <span className="shrink-0 rounded-full bg-success/10 px-2 py-0.5 text-[10px] font-medium text-success">Existing</span>
                        </button>
                      ))}
                    </>
                  )}
                  {tkSearch.trim() && (
                    <button
                      type="button"
                      className="flex w-full items-center gap-2 border-t border-border px-3 py-2 text-left text-sm text-primary hover:bg-accent"
                      onMouseDown={() => {
                        setSelectedExisting(null);
                        setSvSearch("");
                        setSvDropOpen(false);
                        setSvAlreadyExists(false);
                        setS((p) => ({ ...p, clientName: tkSearch.trim(), companyName: "" }));
                        setTkDropOpen(false);
                      }}
                    >
                      <Plus className="h-3.5 w-3.5" />
                      Add <span className="font-semibold">"{tkSearch.trim()}"</span> as new TK Customer
                    </button>
                  )}
                </div>
              )}
            </div>
            {selectedExisting && (
              <p className="mt-1 text-[11px] text-success">
                ✓ Existing customer selected — details auto-filled. Add a new sub-venture below.
              </p>
            )}
          </div>

          {/* ── Existing client info banner ── */}
          {selectedExisting && (
            <div className="rounded-lg border border-info/30 bg-info/5 px-3 py-2.5 text-xs space-y-1">
              <p className="font-semibold text-foreground">{selectedExisting.name}</p>
              <p className="text-muted-foreground">{selectedExisting.industry} · ID: {selectedExisting.id}</p>
              {selectedExisting.engagementManager && <p className="text-muted-foreground">EM: {selectedExisting.engagementManager}</p>}
            </div>
          )}

          {/* ── Sub-venture name — searchable when existing client, plain input for new ── */}
          {selectedExisting ? (
            <div>
              <span className="mb-1 block text-xs font-medium text-muted-foreground">
                End Customer Name / Sub-venture Name <span className="text-destructive">*</span>
              </span>
              {/* Existing sub-ventures of this client */}
              {(selectedExisting.subVentures?.length ?? 0) > 0 && (
                <p className="mb-1.5 text-[11px] text-muted-foreground">
                  {selectedExisting.subVentures!.length} sub-venture(s) already under {selectedExisting.name}
                </p>
              )}
              <div className="relative">
                <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  className={cn("h-9 w-full rounded-md border border-input bg-card pl-8 pr-8 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring",
                    !s.companyName.trim() && "border-destructive/60")}
                  placeholder="Search existing or type new sub-venture name…"
                  value={svSearch}
                  onFocus={() => setSvDropOpen(true)}
                  onChange={(e) => {
                    setSvSearch(e.target.value);
                    setSvDropOpen(true);
                    setSvAlreadyExists(false);
                    setS((p) => ({ ...p, companyName: e.target.value }));
                  }}
                  onBlur={() => setTimeout(() => setSvDropOpen(false), 150)}
                />
                {s.companyName && (
                  <button
                    type="button"
                    className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                    onClick={() => { setSvSearch(""); setSvAlreadyExists(false); setS((p) => ({ ...p, companyName: "" })); }}
                  ><X className="h-3.5 w-3.5" /></button>
                )}
                {svDropOpen && (
                  <div className="absolute left-0 right-0 top-full z-50 mt-1 max-h-52 overflow-y-auto rounded-md border border-border bg-popover shadow-lg">
                    {/* Existing sub-ventures matching search */}
                    {(selectedExisting.subVentures ?? [])
                      .filter((sv) => !svSearch.trim() || sv.toLowerCase().includes(svSearch.toLowerCase()))
                      .map((sv) => (
                        <button
                          key={sv}
                          type="button"
                          className="flex w-full items-center justify-between px-3 py-2 text-left text-sm hover:bg-accent"
                          onMouseDown={() => {
                            setSvSearch(sv);
                            setSvAlreadyExists(true);
                            setSvDropOpen(false);
                            setS((p) => ({ ...p, companyName: sv }));
                          }}
                        >
                          <span>{sv}</span>
                          <span className="rounded-full bg-warning/10 px-2 py-0.5 text-[10px] font-medium text-warning-foreground">Already exists</span>
                        </button>
                      ))}
                    {/* Create new option when typed name not in list */}
                    {svSearch.trim() &&
                      !(selectedExisting.subVentures ?? []).some(
                        (sv) => sv.toLowerCase() === svSearch.trim().toLowerCase()
                      ) && (
                        <button
                          type="button"
                          className="flex w-full items-center gap-2 border-t border-border px-3 py-2 text-left text-sm text-primary hover:bg-accent"
                          onMouseDown={() => {
                            setSvAlreadyExists(false);
                            setSvDropOpen(false);
                            setS((p) => ({ ...p, companyName: svSearch.trim() }));
                          }}
                        >
                          <Plus className="h-3.5 w-3.5" />
                          Create <span className="font-semibold">"{svSearch.trim()}"</span> as new sub-venture
                        </button>
                      )}
                    {/* Empty state */}
                    {!svSearch.trim() && (selectedExisting.subVentures ?? []).length === 0 && (
                      <div className="px-3 py-3 text-xs text-muted-foreground">
                        No sub-ventures yet — type a name to create the first one
                      </div>
                    )}
                  </div>
                )}
              </div>
              {svAlreadyExists && (
                <p className="mt-1 text-[11px] text-warning-foreground">
                  ⚠ This sub-venture already exists under {selectedExisting.name}. Proceeding will not create a duplicate.
                </p>
              )}
              {!svAlreadyExists && s.companyName.trim() && (
                <p className="mt-1 text-[11px] text-success">
                  ✓ New sub-venture will be added under {selectedExisting.name}
                </p>
              )}
            </div>
          ) : (
            <Field label="End Customer Name / Sub-venture Name" required>
              <input className={inputCls} value={s.companyName} onChange={(e) => u("companyName", e.target.value)} placeholder="Enter sub-venture or end customer name…" />
            </Field>
          )}

          {/* ── New TK customer fields — only shown when not selecting existing ── */}
          {!selectedExisting && (
            <div className="grid gap-3 sm:grid-cols-2">
              <Field label="Customer ID">
                <input className={readOnlyCls} value={s.customerId} readOnly />
              </Field>
              <Field label="Engagement Manager" required>
                <input
                  className={inputCls}
                  value={s.engagementManager}
                  onChange={(e) => u("engagementManager", e.target.value.replace(/[^a-zA-Z\s\-']/g, ""))}
                />
              </Field>
              <Field label="Phone Number" required>
                <input
                  className={inputCls}
                  type="tel"
                  inputMode="tel"
                  placeholder="e.g. +91 98765 43XXX"
                  value={s.phoneNumber}
                  onChange={(e) => {
                    // Only allow digits, +, spaces, and hyphens
                    const filtered = e.target.value.replace(/[^\d\s+\-]/g, "");
                    u("phoneNumber", filtered);
                  }}
                />
                {s.phoneNumber.trim() && !isValidPhone(s.phoneNumber) && (
                  <p className="mt-1 text-[11px] text-destructive">Please enter a real, valid phone number (e.g. +91 98765 43XXX)</p>
                )}
              </Field>
              <Field label="City" required>
                <input
                  className={inputCls}
                  value={s.city}
                  onChange={(e) => u("city", e.target.value.replace(/[^a-zA-Z\s\-']/g, ""))}
                />
              </Field>
              <Field label="Country / Region" required>
                <input
                  className={inputCls}
                  value={s.country}
                  onChange={(e) => u("country", e.target.value.replace(/[^a-zA-Z\s\-']/g, ""))}
                />
              </Field>
              <Field label="Industry" required>
                <select className={inputCls} value={s.industry} onChange={(e) => u("industry", e.target.value)}>
                  <option value="">Select industry</option>
                  {["Banking", "Healthcare", "Retail", "Logistics", "Energy", "Manufacturing", "Telecom", "Media"].map((o) => (
                    <option key={o}>{o}</option>
                  ))}
                </select>
              </Field>
              <Field label="Business Type">
                <select className={cn(inputCls, "bg-muted text-muted-foreground cursor-not-allowed")} value={s.businessType} disabled>
                  <option value="">Select business type</option>
                  {["Enterprise", "Mid-Market", "SMB", "Public Sector"].map((o) => (
                    <option key={o}>{o}</option>
                  ))}
                </select>
              </Field>
              <Field label="Created At">
                <input className={readOnlyCls} value={format(new Date(s.createdAt), "dd MMM yyyy, HH:mm")} readOnly />
              </Field>
              <Field label="Created By">
                <input className={readOnlyCls} value={s.createdBy} readOnly />
              </Field>
            </div>
          )}

          {/* ── Existing client — show locked ID + created info ── */}
          {selectedExisting && (
            <div className="grid gap-3 sm:grid-cols-2">
              <Field label="Customer ID">
                <input className={readOnlyCls} value={selectedExisting.id} readOnly />
              </Field>
              <Field label="Created By">
                <input className={readOnlyCls} value={s.createdBy} readOnly />
              </Field>
            </div>
          )}
        </div>
      )}

      {/* Step 2 — Contacts + registration numbers */}
      {step === 2 && (
        <div className="space-y-3">
          {s.contacts.map((ct, idx) => (
            <div key={idx} className="rounded-lg border border-border bg-background p-3">
              <div className="mb-2 flex items-center justify-between">
                <span className="text-xs font-medium text-muted-foreground">
                  Contact {s.contacts.length > 1 ? `${idx + 1}` : "Person"}
                </span>
                {idx > 0 && (
                  <button
                    type="button"
                    onClick={() => removeContact(idx)}
                    className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2 py-0.5 text-xs text-muted-foreground hover:bg-accent hover:text-foreground"
                  >
                    <X className="h-3 w-3" /> Remove
                  </button>
                )}
              </div>
              <div className="grid gap-3 sm:grid-cols-2">
                <Field label="Contact Person" required>
                  <input
                    className={inputCls}
                    value={ct.name}
                    placeholder="Full name"
                    onChange={(e) => {
                      // Only allow alphabets, spaces, hyphens, and apostrophes
                      const filtered = e.target.value.replace(/[^a-zA-Z\s\-']/g, "");
                      updateContact(idx, "name", filtered);
                    }}
                  />
                </Field>
                <Field label="Contact Type" required>
                  <select
                    className={inputCls}
                    value={ct.contactType}
                    onChange={(e) => updateContact(idx, "contactType", e.target.value)}
                  >
                    <option value="">Select contact type</option>
                    {["Accounts", "Procurement", "Technical", "Legal"].map((o) => (
                      <option key={o} value={o}>{o}</option>
                    ))}
                  </select>
                </Field>
                <Field label="Email" required>
                  <input type="email" className={inputCls} value={ct.email} onChange={(e) => updateContact(idx, "email", e.target.value)} />
                </Field>
                <Field label="Phone" required>
                  <div>
                    <input
                      className={inputCls}
                      type="tel"
                      inputMode="tel"
                      placeholder="e.g. +91 98765 43XXX"
                      value={ct.phone}
                      onChange={(e) => {
                        // Only allow digits, +, spaces, and hyphens
                        const filtered = e.target.value.replace(/[^\d\s+\-]/g, "");
                        updateContact(idx, "phone", filtered);
                      }}
                    />
                    {ct.phone.trim() && !isValidPhone(ct.phone) && (
                      <p className="mt-1 text-[11px] text-destructive">Please enter a real, valid phone number (e.g. +91 98765 43XXX)</p>
                    )}
                  </div>
                </Field>
                <Field label="Designation" required>
                  <input className={inputCls} placeholder="eg ciso/spoc etc." value={ct.designation} onChange={(e) => updateContact(idx, "designation", e.target.value)} />
                </Field>
              </div>
              <div className="mt-3 flex items-center gap-2">
                <button
                  type="button"
                  onClick={addContact}
                  disabled={s.contacts.length >= MAX_CONTACTS}
                  className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent disabled:cursor-not-allowed disabled:opacity-50"
                >
                  <Plus className="h-3 w-3" /> Add
                </button>
                {s.contacts.length >= MAX_CONTACTS && (
                  <span className="text-[11px] text-muted-foreground">Maximum of 4 contacts</span>
                )}
              </div>
            </div>
          ))}
          <div className="mt-4 pt-4 border-t border-border">
            <Field label="KYC Document" required>
              <div className="relative">
                <label className={cn(
                  "flex h-9 w-full cursor-pointer items-center gap-2 rounded-md border border-dashed border-input bg-card px-3 text-sm transition-colors hover:bg-accent",
                  s.kycFile && "border-success/50 bg-success/5"
                )}>
                  <input
                    type="file"
                    accept="*/*"
                    className="absolute inset-0 h-full w-full cursor-pointer opacity-0"
                    onChange={(e) => setS((p) => ({ ...p, kycFile: e.target.files?.[0] ?? null }))}
                  />
                  {s.kycFile ? (
                    <>
                      <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-success/15 text-success">
                        <Check className="h-3 w-3" />
                      </span>
                      <span className="flex-1 truncate text-xs font-medium text-foreground">{s.kycFile.name}</span>
                      <span className="text-[10px] text-muted-foreground">{(s.kycFile.size / 1024).toFixed(0)} KB</span>
                      <button
                        type="button"
                        onClick={(e) => { e.preventDefault(); setS((p) => ({ ...p, kycFile: null })); }}
                        className="ml-1 rounded p-0.5 hover:bg-destructive/10 hover:text-destructive"
                        aria-label="Remove file"
                      >
                        <X className="h-3 w-3" />
                      </button>
                    </>
                  ) : (
                    <>
                      <span className="text-muted-foreground">📎</span>
                      <span className="text-xs text-muted-foreground">Click to attach KYC document — any format accepted</span>
                    </>
                  )}
                </label>
              </div>
              <p className="mt-1 text-[11px] text-muted-foreground">Required · PDF, image, Word, or any other format</p>
            </Field>
          </div>
          <Field label="Notes" className="pt-1">
            <textarea rows={3} className={cn(inputCls, "py-2")} value={s.notes} onChange={(e) => u("notes", e.target.value)} />
          </Field>
        </div>
      )}

      {/* Step 3 — Review */}
      {step === 3 && (
        <div className="rounded-lg border border-border bg-accent/20 p-4">
          <h4 className="mb-3 text-sm font-semibold">
            {selectedExisting ? "Adding Sub-venture to Existing Customer" : "New Customer Summary"}
          </h4>
          <dl className="grid grid-cols-2 gap-x-4 gap-y-2 text-xs">
            <Row label="TK Customer" v={s.clientName || selectedExisting?.name || "—"} />
            <Row label="Sub-venture Name" v={s.companyName} />
            <Row label="Customer ID" v={selectedExisting ? selectedExisting.id : s.customerId} />
            {!selectedExisting && (
              <>
                <Row label="Engagement Manager" v={s.engagementManager} />
                <Row label="Phone Number" v={s.phoneNumber} />
                <Row label="City" v={s.city} />
                <Row label="Country / Region" v={s.country} />
                <Row label="Industry" v={s.industry} />
              </>
            )}
            <Row label="Created At" v={format(new Date(s.createdAt), "dd MMM yyyy, HH:mm")} />
            <Row label="Created By" v={s.createdBy} />
            <Row label="KYC Document" v={s.kycFile ? s.kycFile.name : "—"} />
          </dl>
          <div className="mt-3 space-y-2">
            <p className="text-xs font-medium text-muted-foreground">Contacts</p>
            {s.contacts.map((ct, idx) => (
              <dl key={idx} className="grid grid-cols-2 gap-x-4 gap-y-1 rounded-md border border-border bg-card px-3 py-2 text-xs">
                <Row label="Name" v={ct.name} />
                <Row label="Contact Type" v={ct.contactType || "—"} />
                <Row label="Email" v={ct.email} />
                <Row label="Phone" v={ct.phone || "—"} />
                <Row label="Designation" v={ct.designation || "—"} />
              </dl>
            ))}
          </div>
          {s.notes && (
            <div className="mt-3">
              <p className="text-xs font-medium text-muted-foreground">Notes</p>
              <p className="mt-0.5 text-xs">{s.notes}</p>
            </div>
          )}
        </div>
      )}

      {/* Footer navigation */}
      <div className="mt-6 flex items-center justify-between border-t border-border pt-4">
        <button
          onClick={() => (step === 1 ? onClose() : setStep(step - 1))}
          className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent"
        >
          {step === 1 ? "Cancel" : "Back"}
        </button>
        {step < 3 ? (
          <button
            onClick={handleNext}
            className="inline-flex items-center gap-1 rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
          >
            Next <ArrowRight className="h-3 w-3" />
          </button>
        ) : (
          <button
            disabled={submitting}
            onClick={submit}
            className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            {submitting ? "Submitting…" : "Submit"}
          </button>
        )}
      </div>
    </Modal>
  );
}

function CustomerDrawer({ client, onClose }: { client: Client; onClose: () => void }) {
  const projects = allProjects();
  const projs = projects.filter((p) => p.clientId === client.id);
  const active = projs.filter((p) => p.status !== "completed");
  const completed = projs.filter((p) => p.status === "completed");
  return (
    <div className="fixed inset-0 z-40 flex items-stretch justify-end bg-black/30" onClick={onClose}>
      <div className="w-full max-w-2xl overflow-y-auto bg-card shadow-xl" onClick={(e) => e.stopPropagation()}>
        <header className="sticky top-0 z-10 flex items-center gap-3 border-b border-border bg-card p-4">
          <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-gradient-to-br from-primary to-info text-base font-semibold text-primary-foreground">{client.logo}</div>
          <div className="flex-1">
            <h2 className="text-base font-semibold">{client.name}</h2>
            <p className="text-xs text-muted-foreground">{client.industry} · {client.contact}</p>
          </div>
          <button onClick={onClose} className="rounded-md p-2 hover:bg-accent" aria-label="Close"><X className="h-4 w-4" /></button>
        </header>
        <Section title="Active Projects" projs={active} empty="No active projects" />
        <Section title="Completed Projects" projs={completed} empty="No completed projects" />
      </div>
    </div>
  );
}

function Section({ title, projs, empty }: { title: string; projs: ReturnType<typeof allProjects>; empty: string }) {
  return (
    <section className="border-b border-border p-4">
      <h3 className="mb-3 flex items-center gap-2 text-sm font-semibold">
        <Building2 className="h-4 w-4 text-muted-foreground" />{title} · {projs.length}
      </h3>
      {projs.length === 0 ? (
        <p className="text-sm text-muted-foreground">{empty}</p>
      ) : (
        <ul className="space-y-2">
          {projs.map((p) => (
            <li key={p.id}>
              <Link to="/projects/$projectId" params={{ projectId: p.id }}
                className="block rounded-lg border border-border bg-background p-3 hover:bg-accent/40">
                <div className="flex flex-wrap items-center gap-2">
                  <span className="text-sm font-medium">{p.name}</span>
                  <HealthPill status={p.health} />
                  <StatusPill status={p.status} />
                  <span className="ml-auto text-xs tabular-nums text-muted-foreground">{p.progress}%</span>
                </div>
                <p className="mt-1 line-clamp-1 text-xs text-muted-foreground">{p.description}</p>
                <ProgressBar value={p.progress} className="mt-2" />
              </Link>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
