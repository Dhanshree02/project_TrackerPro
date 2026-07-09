import { createFileRoute, Link, Navigate, useNavigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { LayoutGrid, List, Search, ArrowRight, Calendar, Plus, X, ChevronRight, Check, Trash2, Calculator, FileText, Clock, User } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { allClients, allProjects, dhStore, useDhStore, type WbsDraft } from "@/lib/dh-store";
import { HealthPill, StatusPill, ProgressBar, PriorityPill, Avatar } from "@/components/pills";
import { getProjectEMs, getProjectPMs, getProjectTLs, formatPeopleSummary } from "@/lib/dh-helpers";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/projects/")({
  head: () => ({
    meta: [
      { title: "Projects — Pulse PMO" },
      { name: "description", content: "Active, archived and all projects in one workspace." },
    ],
  }),
  component: ProjectsPage,
});

const tabs = ["Active Projects", "Archived Projects", "All Projects"] as const;
type Tab = (typeof tabs)[number];

function ProjectsPage() {
  const { isDhanshree } = useRoleContext();
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>("Active Projects");
  const [view, setView] = useState<"card" | "list">("card");
  const [q, setQ] = useState("");
  const [draftsOpen, setDraftsOpen] = useState(false);

  if (!isDhanshree) return <Navigate to="/" />;

  const extraCount = useDhStore((s) => s.extraClients.length + s.extraProjects.length);
  const drafts = useDhStore((s) => s.wbsDrafts);
  const projects = useMemo(() => allProjects(), [extraCount]);
  const clients = useMemo(() => allClients(), [extraCount]);

  const visible = useMemo(() => {
    return projects.filter((p) => {
      if (tab === "Active Projects" && p.status !== "ongoing") return false;
      if (tab === "Archived Projects" && p.status !== "completed") return false;
      if (!q.trim()) return true;
      const c = clients.find((c) => c.id === p.clientId);
      return [p.name, c?.name ?? "", p.description].some((v) => v.toLowerCase().includes(q.toLowerCase()));
    });
  }, [tab, q, projects, clients]);

  const priorities: Array<"low" | "medium" | "high" | "critical"> = ["high", "medium", "critical", "medium", "high", "low", "medium", "high", "critical"];

  return (
    <AppShell title="Projects" subtitle="Active, archived and all projects across your portfolio">
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="flex gap-1 rounded-lg border border-border bg-card p-1 text-sm shadow-sm">
          {tabs.map((t) => (
            <button key={t} onClick={() => setTab(t)}
              className={cn("rounded-md px-3 py-1.5 font-medium",
                tab === t ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}>
              {t}
            </button>
          ))}
        </div>
        <div className="relative max-w-xs flex-1">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input value={q} onChange={(e) => setQ(e.target.value)}
            placeholder="Search project or client…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" />
        </div>
        <div className="ml-auto flex items-center gap-2">
          {/* Drafts button */}
          <button
            onClick={() => setDraftsOpen(true)}
            className={cn(
              "relative inline-flex items-center gap-1.5 rounded-md border border-border bg-card px-3 py-1.5 text-xs font-medium hover:bg-accent",
              draftsOpen && "bg-accent"
            )}
          >
            <FileText className="h-3.5 w-3.5" />
            Drafts
            {drafts.length > 0 && (
              <span className="flex h-4 min-w-4 items-center justify-center rounded-full bg-warning/80 px-1 text-[10px] font-bold text-white">
                {drafts.length}
              </span>
            )}
          </button>
          <div className="flex gap-1 rounded-lg border border-border bg-card p-1 text-xs shadow-sm">
            <button onClick={() => setView("card")} aria-label="Card view"
              className={cn("inline-flex items-center gap-1 rounded-md px-2.5 py-1",
                view === "card" ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}>
              <LayoutGrid className="h-3.5 w-3.5" /> Card
            </button>
            <button onClick={() => setView("list")} aria-label="List view"
              className={cn("inline-flex items-center gap-1 rounded-md px-2.5 py-1",
                view === "list" ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}>
              <List className="h-3.5 w-3.5" /> List
            </button>
          </div>
          <button onClick={() => navigate({ to: "/projects/new" })}
            className="inline-flex items-center gap-1 rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">
            <Plus className="h-3.5 w-3.5" /> New Project
          </button>
        </div>
      </div>

      {view === "card" ? (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          {visible.map((p, i) => {
            const client = clients.find((c) => c.id === p.clientId)!;
            const ems = getProjectEMs(p);
            const pms = getProjectPMs(p);
            const tls = getProjectTLs(p);
            return (
              <article key={p.id} className="flex flex-col rounded-xl border border-border bg-card p-4 shadow-sm transition-shadow hover:shadow-md">
                <header className="flex items-start gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-gradient-to-br from-primary to-info text-sm font-semibold text-primary-foreground">
                    {client.logo}
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-1.5 text-[11px] text-muted-foreground">
                      <span className="font-mono">{p.id.toUpperCase()}</span>
                      <span>•</span>
                      <span>{client.name}</span>
                    </div>
                    <div className="truncate text-sm font-semibold">{p.name}</div>
                  </div>
                </header>
                <div className="mt-3 flex flex-wrap items-center gap-1.5">
                  <HealthPill status={p.health} />
                  <StatusPill status={p.status} />
                  <PriorityPill priority={priorities[i % priorities.length]} />
                </div>
                <div className="mt-3">
                  <div className="mb-1 flex justify-between text-[11px] tabular-nums text-muted-foreground">
                    <span>Progress</span><span>{p.progress}%</span>
                  </div>
                  <ProgressBar value={p.progress} />
                </div>
                <dl className="mt-3 grid grid-cols-2 gap-x-3 gap-y-2 text-xs">
                  <div><dt className="text-muted-foreground">Start</dt><dd className="font-medium tabular-nums">{new Date(p.startDate).toLocaleDateString()}</dd></div>
                  <div><dt className="text-muted-foreground">End</dt><dd className="font-medium tabular-nums">{new Date(p.endDate).toLocaleDateString()}</dd></div>
                  <div className="col-span-2"><dt className="text-muted-foreground">Engagement Mgr</dt><dd><PeopleSummary list={ems} /></dd></div>
                  <div className="col-span-2"><dt className="text-muted-foreground">Project Mgr</dt><dd><PeopleSummary list={pms} /></dd></div>
                  <div className="col-span-2"><dt className="text-muted-foreground">Team Lead</dt><dd><PeopleSummary list={tls} /></dd></div>
                </dl>
                <Link to="/projects/$projectId" params={{ projectId: p.id }}
                  className="mt-4 inline-flex items-center justify-center gap-1 rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">
                  Open Project <ArrowRight className="h-3 w-3" />
                </Link>
              </article>
            );
          })}
          {visible.length === 0 && (
            <p className="col-span-full py-10 text-center text-sm text-muted-foreground">No projects in this view</p>
          )}
        </div>
      ) : (
        <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
          <table className="w-full text-sm">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-3 py-2 font-medium">Project ID</th>
                <th className="px-3 py-2 font-medium">Project</th>
                <th className="px-3 py-2 font-medium">Client</th>
                <th className="px-3 py-2 font-medium">Status</th>
                <th className="px-3 py-2 font-medium">Progress</th>
                <th className="px-3 py-2 font-medium">Start</th>
                <th className="px-3 py-2 font-medium">End</th>
                <th className="px-3 py-2 font-medium">Engagement Mgr</th>
                <th className="px-3 py-2 font-medium">Project Mgr</th>
                <th className="px-3 py-2 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {visible.map((p) => {
                const client = clients.find((c) => c.id === p.clientId)!;
                const ems = getProjectEMs(p);
                const pms = getProjectPMs(p);
                return (
                  <tr key={p.id} className="hover:bg-accent/30">
                    <td className="px-3 py-2.5 font-mono text-xs text-muted-foreground">{p.id.toUpperCase()}</td>
                    <td className="px-3 py-2.5 font-medium">{p.name}</td>
                    <td className="px-3 py-2.5 text-muted-foreground">{client.name}</td>
                    <td className="px-3 py-2.5"><StatusPill status={p.status} /></td>
                    <td className="px-3 py-2.5">
                      <div className="flex items-center gap-2">
                        <ProgressBar value={p.progress} className="w-24" />
                        <span className="text-xs tabular-nums text-muted-foreground">{p.progress}%</span>
                      </div>
                    </td>
                    <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">{new Date(p.startDate).toLocaleDateString()}</td>
                    <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">{new Date(p.endDate).toLocaleDateString()}</td>
                    <td className="px-3 py-2.5"><PeopleSummary list={ems} /></td>
                    <td className="px-3 py-2.5"><PeopleSummary list={pms} /></td>
                    <td className="px-3 py-2.5 text-right">
                      <Link to="/projects/$projectId" params={{ projectId: p.id }}
                        className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent">
                        Open <ArrowRight className="h-3 w-3" />
                      </Link>
                    </td>
                  </tr>
                );
              })}
              {visible.length === 0 && (
                <tr><td colSpan={10} className="px-3 py-10 text-center text-sm text-muted-foreground">No projects in this view</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* New Project navigates to /projects/new (full WBS form) */}

      {/* ── Drafts panel ── */}
      {draftsOpen && (
        <div className="fixed inset-0 z-50 flex justify-end" onClick={() => setDraftsOpen(false)}>
          <aside
            className="flex h-full w-full max-w-md flex-col border-l border-border bg-card shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="flex items-center justify-between border-b border-border px-4 py-3">
              <div>
                <h2 className="text-sm font-semibold">Saved Drafts</h2>
                <p className="text-[11px] text-muted-foreground">{drafts.length} draft{drafts.length !== 1 ? "s" : ""} saved</p>
              </div>
              <button onClick={() => setDraftsOpen(false)} className="rounded-md p-1.5 hover:bg-accent" aria-label="Close">
                <X className="h-4 w-4" />
              </button>
            </div>

            {/* List */}
            <div className="flex-1 overflow-y-auto">
              {drafts.length === 0 ? (
                <div className="flex flex-col items-center justify-center gap-3 py-16 text-center">
                  <FileText className="h-10 w-10 text-muted-foreground/40" />
                  <p className="text-sm text-muted-foreground">No drafts saved yet</p>
                  <p className="text-xs text-muted-foreground">Use "Save Draft" on the New Project page to save your work</p>
                </div>
              ) : (
                <ul className="divide-y divide-border">
                  {drafts.map((d: WbsDraft) => (
                    <li key={d.id} className="group px-4 py-3 hover:bg-accent/40">
                      <div className="flex items-start gap-3">
                        <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                          <FileText className="h-4 w-4" />
                        </div>
                        <div className="min-w-0 flex-1">
                          <p className="truncate text-sm font-semibold">{d.projectName}</p>
                          <div className="mt-0.5 flex flex-wrap items-center gap-x-2 gap-y-0.5 text-[11px] text-muted-foreground">
                            <span className="flex items-center gap-1">
                              <User className="h-3 w-3" />{d.clientName}
                            </span>
                            {d.salesPerson && (
                              <span className="flex items-center gap-1">
                                · Sales: {d.salesPerson}
                              </span>
                            )}
                          </div>
                          <div className="mt-1 flex items-center gap-1 text-[10px] text-muted-foreground">
                            <Clock className="h-3 w-3" />
                            Saved by {d.savedBy} · {new Date(d.savedAt).toLocaleString("en-IN", { day: "2-digit", month: "short", year: "numeric", hour: "2-digit", minute: "2-digit" })}
                          </div>
                        </div>
                        <div className="flex shrink-0 flex-col gap-1.5">
                          <button
                            onClick={() => {
                              setDraftsOpen(false);
                              navigate({ to: "/projects/new", search: { draftId: d.id } as any });
                            }}
                            className="inline-flex items-center gap-1 rounded-md bg-primary px-2.5 py-1 text-[11px] font-medium text-primary-foreground hover:bg-primary/90"
                          >
                            <ArrowRight className="h-3 w-3" /> Open
                          </button>
                          <button
                            onClick={() => {
                              dhStore.deleteDraft(d.id);
                              toast.success("Draft deleted");
                            }}
                            className="inline-flex items-center gap-1 rounded-md border border-destructive/30 bg-destructive/5 px-2.5 py-1 text-[11px] font-medium text-destructive hover:bg-destructive/10"
                          >
                            <Trash2 className="h-3 w-3" /> Delete
                          </button>
                        </div>
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </aside>
        </div>
      )}
    </AppShell>
  );
}

function PeopleSummary({ list }: { list: ReturnType<typeof getProjectEMs> }) {
  const s = formatPeopleSummary(list);
  if (s.primary === "—") return <span className="text-muted-foreground">—</span>;
  return (
    <div className="flex items-center gap-1.5">
      <Avatar name={list[0].name} size={20} />
      <span className="truncate text-xs">{s.primary}</span>
      {s.more > 0 && (
        <span className="rounded-full border border-border bg-muted px-1.5 py-0.5 text-[10px] font-medium text-muted-foreground">+{s.more}</span>
      )}
    </div>
  );
}

// ---------- New WBS Project Modal ----------
type ClientMode = "existing" | "new";
interface WbsServiceState {
  id: string;
  department: string;
  serviceName: string;
  qty: number;
  description: string;
  frequency: string;
  location: string;
  serviceModel: string;
  deliveryModel: string;
  finalDeliveryFormat: string;
  billingModel: string;
  tools: string;
  startDate: string;
  endDate: string;
  duration: number;
  unitPrice: number;
  total: number;
}

interface WbsInvoiceState {
  id: string;
  milestone: string;
  amount: number;
  invoiceDate: string;
  remarks: string;
}

interface NewProjectState {
  clientMode: ClientMode;
  existingClientId: string;
  newClient: { name: string; industry: string; contact: string; email: string };
  proj: { name: string; description: string; startDate: string; endDate: string; budget: string };
  wbsHeader: { contractType: string; projectType: string; salesPerson: string; currency: string };
  wbsServices: WbsServiceState[];
  wbsAccounts: { poStatus: string; poNumber: string; poDate: string; billingModel: string; paymentTerms: string; targetDate: string; contactName: string; contactNumber: string; contactEmail: string };
  wbsInvoices: WbsInvoiceState[];
}

// DEPT_SERVICES moved to /projects/new route (full WBS form)
// Kept here for backward-compat with NewWBSProjectModal
const DEPT_SERVICES: Record<string, string[]> = {
  "Creative": ["Brand Design", "UI/UX Design", "Copywriting", "Video Production"],
  "Technology": ["Web Development", "Mobile App Development", "API Integration", "Cloud Architecture"],
  "Marketing": ["SEO Optimization", "Performance Marketing", "Social Media Management", "Content Strategy"],
  "Consulting": ["Digital Transformation", "Process Optimization", "Market Research"],
  "Penetration Testing": ["External Network Penetration Testing", "Internal Network Penetration Testing", "Web Application Penetration Testing"],
  "Vulnerability Assessment": ["Network Vulnerability Assessment", "Web Application Vulnerability Assessment"],
  "Cloud Security": ["AWS Security Assessment", "Azure Security Assessment"],
};

function NewWBSProjectModal({ onClose }: { onClose: () => void }) {
  const [step, setStep] = useState(1);
  const [submitting, setSubmitting] = useState(false);
  const clients = allClients();
  const [s, setS] = useState<NewProjectState>({
    clientMode: "existing",
    existingClientId: clients[0]?.id ?? "",
    newClient: { name: "", industry: "", contact: "", email: "" },
    proj: { name: "", description: "", startDate: "", endDate: "", budget: "" },
    wbsHeader: { contractType: "Fixed Price", projectType: "New Implementation", salesPerson: "", currency: "USD" },
    wbsServices: [],
    wbsAccounts: { poStatus: "Not Raised", poNumber: "", poDate: "", billingModel: "Milestone", paymentTerms: "Net 30", targetDate: "", contactName: "", contactNumber: "", contactEmail: "" },
    wbsInvoices: [],
  });

  const [showServicePicker, setShowServicePicker] = useState(false);
  const [tempService, setTempService] = useState({ dept: "Creative", service: "Brand Design" });

  const updateProj = (k: keyof NewProjectState["proj"], v: string) => setS(p => ({ ...p, proj: { ...p.proj, [k]: v } }));
  const updateWbsHeader = (k: keyof NewProjectState["wbsHeader"], v: string) => setS(p => ({ ...p, wbsHeader: { ...p.wbsHeader, [k]: v } }));
  const updateWbsAccounts = (k: keyof NewProjectState["wbsAccounts"], v: string) => setS(p => ({ ...p, wbsAccounts: { ...p.wbsAccounts, [k]: v } }));

  const clientValid = s.clientMode === "existing" ? !!s.existingClientId : !!s.newClient.name;
  const projValid = !!s.proj.name && !!s.proj.startDate && !!s.proj.endDate;
  const isHeaderComplete = clientValid && projValid;

  const submit = () => {
    if (!isHeaderComplete || s.wbsServices.length === 0) { 
      toast.error("Please complete client, project, and at least one service"); 
      return; 
    }
    setSubmitting(true);
    setTimeout(() => {
      let clientId = s.existingClientId;
      if (s.clientMode === "new") {
        const c = dhStore.addClient({ name: s.newClient.name, industry: s.newClient.industry || "Other", contact: s.newClient.email });
        clientId = c.id;
      }
      
      const overallBudget = s.wbsServices.reduce((acc, curr) => acc + curr.total, 0);

      dhStore.addProject({
        name: s.proj.name,
        clientId,
        description: s.proj.description,
        startDate: s.proj.startDate,
        endDate: s.proj.endDate,
        budget: overallBudget,
        wbsDetails: {
          contractType: s.wbsHeader.contractType,
          projectType: s.wbsHeader.projectType,
          salesPerson: s.wbsHeader.salesPerson,
          currency: s.wbsHeader.currency,
          services: s.wbsServices,
          accounts: {
            poStatus: s.wbsAccounts.poStatus,
            poNumber: s.wbsAccounts.poNumber,
            poDate: s.wbsAccounts.poDate,
            billingModel: s.wbsAccounts.billingModel,
            paymentTerms: s.wbsAccounts.paymentTerms,
            targetDate: s.wbsAccounts.targetDate,
            contactName: s.wbsAccounts.contactName,
            contactNumber: s.wbsAccounts.contactNumber,
            contactEmail: s.wbsAccounts.contactEmail,
            invoices: s.wbsInvoices,
          }
        }
      });
      toast.success("WBS Project created", { description: "Prerequisites initialized and project active." });
      setSubmitting(false);
      onClose();
    }, 500);
  };

  const addService = () => {
    setS(p => ({
      ...p, wbsServices: [...p.wbsServices, {
        id: "srv_" + Date.now(),
        department: tempService.dept, serviceName: tempService.service,
        qty: 1, description: "", frequency: "One-Time", location: "Offshore",
        serviceModel: "Fixed", deliveryModel: "Agile", finalDeliveryFormat: "Code",
        billingModel: "Milestone", tools: "Jira, GitHub",
        startDate: p.proj.startDate, endDate: p.proj.endDate, duration: 1, unitPrice: 0, total: 0
      }]
    }));
    setShowServicePicker(false);
  };

  const updateService = (id: string, field: string, val: any) => {
    setS(p => {
      const svcs = p.wbsServices.map(svc => {
        if (svc.id === id) {
          const updated = { ...svc, [field]: val };
          updated.total = updated.qty * updated.unitPrice;
          return updated;
        }
        return svc;
      });
      return { ...p, wbsServices: svcs };
    });
  };

  const removeService = (id: string) => setS(p => ({ ...p, wbsServices: p.wbsServices.filter(x => x.id !== id) }));

  const addInvoice = () => {
    setS(p => ({
      ...p, wbsInvoices: [...p.wbsInvoices, { id: "inv_" + Date.now(), milestone: "", amount: 0, invoiceDate: "", remarks: "" }]
    }));
  };

  const updateInvoice = (id: string, field: string, val: any) => {
    setS(p => ({
      ...p, wbsInvoices: p.wbsInvoices.map(inv => inv.id === id ? { ...inv, [field]: val } : inv)
    }));
  };

  const removeInvoice = (id: string) => setS(p => ({ ...p, wbsInvoices: p.wbsInvoices.filter(x => x.id !== id) }));

  const totalServices = s.wbsServices.reduce((a, b) => a + b.total, 0);
  const tax = totalServices * 0.18;
  const grandTotal = totalServices + tax;
  const totalInvoices = s.wbsInvoices.reduce((a, b) => a + Number(b.amount || 0), 0);

  return (
    <Modal title="Create New Project (WBS)" onClose={onClose} fullScreen>
      <div className="pb-8 space-y-8 max-w-[1400px] mx-auto">
        <div className="grid gap-6 md:grid-cols-2">
          {/* Client Details */}
          <section className="space-y-4 rounded-lg border border-border bg-card p-5">
            <h3 className="text-sm font-semibold border-b border-border pb-2">Client Details</h3>
            <div className="flex gap-2 mb-4">
              {(["existing", "new"] as ClientMode[]).map((m) => (
                <button key={m} onClick={() => setS((p) => ({ ...p, clientMode: m }))} className={cn("flex-1 rounded-md border p-2 text-center text-xs font-medium", s.clientMode === m ? "border-primary bg-primary/10 text-primary" : "border-border bg-muted/50 hover:bg-accent/30")}>
                  {m === "existing" ? "Existing Client" : "Add New Client"}
                </button>
              ))}
            </div>
            {s.clientMode === "existing" ? (
              <Field label="Select Client" required><select value={s.existingClientId} onChange={(e) => setS(p => ({ ...p, existingClientId: e.target.value }))} className={inputCls}>{clients.map((c) => <option key={c.id} value={c.id}>{c.name} — {c.industry}</option>)}</select></Field>
            ) : (
              <div className="grid gap-3 sm:grid-cols-2">
                <Field label="Client Name" required><input className={inputCls} value={s.newClient.name} onChange={(e) => setS(p => ({...p, newClient: {...p.newClient, name: e.target.value}}))} /></Field>
                <Field label="Industry"><input className={inputCls} value={s.newClient.industry} onChange={(e) => setS(p => ({...p, newClient: {...p.newClient, industry: e.target.value}}))} /></Field>
                <Field label="Contact Person"><input className={inputCls} value={s.newClient.contact} onChange={(e) => setS(p => ({...p, newClient: {...p.newClient, contact: e.target.value}}))} /></Field>
                <Field label="Email"><input type="email" className={inputCls} value={s.newClient.email} onChange={(e) => setS(p => ({...p, newClient: {...p.newClient, email: e.target.value}}))} /></Field>
              </div>
            )}
          </section>
          
          {/* Project Details */}
          <section className="space-y-4 rounded-lg border border-border bg-card p-5">
            <h3 className="text-sm font-semibold border-b border-border pb-2">Project Details</h3>
            <div className="grid gap-3 sm:grid-cols-2">
              <Field label="Project Name" required className="sm:col-span-2"><input className={inputCls} value={s.proj.name} onChange={(e) => updateProj("name", e.target.value)} /></Field>
              <Field label="Start Date" required><input type="date" className={inputCls} value={s.proj.startDate} onChange={(e) => updateProj("startDate", e.target.value)} /></Field>
              <Field label="End Date" required><input type="date" className={inputCls} value={s.proj.endDate} onChange={(e) => updateProj("endDate", e.target.value)} /></Field>
              <Field label="Description" className="sm:col-span-2"><textarea rows={1} className={cn(inputCls, "py-1.5")} value={s.proj.description} onChange={(e) => updateProj("description", e.target.value)} /></Field>
            </div>
          </section>
        </div>

        {isHeaderComplete && (
          <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            {/* WBS Info Cards */}
            <div className="grid gap-6 md:grid-cols-2">
              <div className="rounded-lg border border-border bg-card p-5">
                <h3 className="mb-4 text-sm font-semibold">WBS Details</h3>
                <div className="space-y-3">
                  <HorizontalField label="Contract Type"><select className={inputCls} value={s.wbsHeader.contractType} onChange={(e) => updateWbsHeader("contractType", e.target.value)}>{["Fixed Price", "Time & Material", "Retainer", "Staff Augmentation"].map(o => <option key={o}>{o}</option>)}</select></HorizontalField>
                  <HorizontalField label="Project Type"><select className={inputCls} value={s.wbsHeader.projectType} onChange={(e) => updateWbsHeader("projectType", e.target.value)}>{["New Implementation", "Enhancement", "Maintenance", "Consulting"].map(o => <option key={o}>{o}</option>)}</select></HorizontalField>
                  <HorizontalField label="Sales Person"><input className={inputCls} value={s.wbsHeader.salesPerson} onChange={(e) => updateWbsHeader("salesPerson", e.target.value)} /></HorizontalField>
                </div>
              </div>
              <div className="rounded-lg border border-border bg-card p-5">
                <h3 className="mb-4 text-sm font-semibold">Billing Information</h3>
                <div className="space-y-3">
                  <HorizontalField label="Currency"><select className={inputCls} value={s.wbsHeader.currency} onChange={(e) => updateWbsHeader("currency", e.target.value)}>{["USD", "EUR", "GBP", "INR"].map(o => <option key={o}>{o}</option>)}</select></HorizontalField>
                  <HorizontalField label="Billing Model"><select className={inputCls} value={s.wbsAccounts.billingModel} onChange={e => updateWbsAccounts("billingModel", e.target.value)}>{["Milestone based", "Monthly", "Quarterly", "On Completion"].map(o => <option key={o}>{o}</option>)}</select></HorizontalField>
                  <HorizontalField label="Payment Terms"><select className={inputCls} value={s.wbsAccounts.paymentTerms} onChange={e => updateWbsAccounts("paymentTerms", e.target.value)}>{["Net 15", "Net 30", "Net 45", "Net 60", "Due on Receipt"].map(o => <option key={o}>{o}</option>)}</select></HorizontalField>
                  <HorizontalField label="Total Amount"><div className="h-9 flex items-center px-3 font-semibold bg-muted/30 rounded border border-border">{s.wbsHeader.currency} {totalServices.toLocaleString()}</div></HorizontalField>
                </div>
              </div>
            </div>

            {/* Services Table */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-semibold">Services & Deliverables from WBS</h3>
                <button onClick={() => setShowServicePicker(true)} className="inline-flex items-center gap-1 rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"><Plus className="h-3.5 w-3.5" /> Add Service</button>
              </div>

              {showServicePicker && (
                <div className="rounded-lg border border-border bg-accent/20 p-3 mb-4 flex items-end gap-3 max-w-xl">
                  <Field label="Department" className="flex-1">
                    <select className={inputCls} value={tempService.dept} onChange={e => {
                      const dept = e.target.value;
                      const svcs = DEPT_SERVICES[dept as keyof typeof DEPT_SERVICES];
                      setTempService({ dept, service: svcs[0] });
                    }}>
                      {Object.keys(DEPT_SERVICES).map(d => <option key={d}>{d}</option>)}
                    </select>
                  </Field>
                  <Field label="Service" className="flex-1">
                    <select className={inputCls} value={tempService.service} onChange={e => setTempService(p => ({...p, service: e.target.value}))}>
                      {DEPT_SERVICES[tempService.dept as keyof typeof DEPT_SERVICES].map(s => <option key={s}>{s}</option>)}
                    </select>
                  </Field>
                  <div className="flex gap-2">
                    <button onClick={addService} className="h-9 rounded-md bg-primary px-3 text-xs font-medium text-primary-foreground hover:bg-primary/90">Add</button>
                    <button onClick={() => setShowServicePicker(false)} className="h-9 rounded-md border border-input bg-card px-3 text-xs font-medium hover:bg-accent">Cancel</button>
                  </div>
                </div>
              )}

              <div className="overflow-x-auto rounded-lg border border-border bg-card">
                <table className="w-full text-xs whitespace-nowrap">
                  <thead className="bg-muted/40 text-left uppercase tracking-wide text-muted-foreground">
                    <tr>
                      <th className="px-3 py-2 font-medium">Department</th>
                      <th className="px-3 py-2 font-medium">Service Name</th>
                      <th className="px-3 py-2 font-medium w-20">Qty</th>
                      <th className="px-3 py-2 font-medium w-24">Unit Price</th>
                      <th className="px-3 py-2 font-medium w-32">Description</th>
                      <th className="px-3 py-2 font-medium w-28">Frequency</th>
                      <th className="px-3 py-2 font-medium w-28">Location</th>
                      <th className="px-3 py-2 font-medium w-32">Start Date</th>
                      <th className="px-3 py-2 font-medium w-32">End Date</th>
                      <th className="px-3 py-2 font-medium text-right w-28">Total</th>
                      <th className="px-3 py-2 font-medium w-10"></th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {s.wbsServices.map((svc) => (
                      <tr key={svc.id} className="hover:bg-accent/10">
                        <td className="px-3 py-2">{svc.department}</td>
                        <td className="px-3 py-2 font-medium">{svc.serviceName}</td>
                        <td className="px-3 py-2"><input type="number" min={1} className={cn(inputCls, "h-7 px-2")} value={svc.qty} onChange={e => updateService(svc.id, "qty", Number(e.target.value))} /></td>
                        <td className="px-3 py-2"><input type="number" min={0} className={cn(inputCls, "h-7 px-2")} value={svc.unitPrice} onChange={e => updateService(svc.id, "unitPrice", Number(e.target.value))} /></td>
                        <td className="px-3 py-2"><input className={cn(inputCls, "h-7 px-2")} value={svc.description} onChange={e => updateService(svc.id, "description", e.target.value)} /></td>
                        <td className="px-3 py-2"><select className={cn(inputCls, "h-7 px-2")} value={svc.frequency} onChange={e => updateService(svc.id, "frequency", e.target.value)}>{["One-Time", "Monthly", "Quarterly", "Annually"].map(o => <option key={o}>{o}</option>)}</select></td>
                        <td className="px-3 py-2"><select className={cn(inputCls, "h-7 px-2")} value={svc.location} onChange={e => updateService(svc.id, "location", e.target.value)}>{["Onsite", "Offshore", "Hybrid"].map(o => <option key={o}>{o}</option>)}</select></td>
                        <td className="px-3 py-2"><input type="date" className={cn(inputCls, "h-7 px-2")} value={svc.startDate} onChange={e => updateService(svc.id, "startDate", e.target.value)} /></td>
                        <td className="px-3 py-2"><input type="date" className={cn(inputCls, "h-7 px-2")} value={svc.endDate} onChange={e => updateService(svc.id, "endDate", e.target.value)} /></td>
                        <td className="px-3 py-2 text-right font-medium">{s.wbsHeader.currency} {svc.total.toLocaleString()}</td>
                        <td className="px-3 py-2 text-center"><button onClick={() => removeService(svc.id)} className="text-muted-foreground hover:text-destructive"><Trash2 className="h-4 w-4" /></button></td>
                      </tr>
                    ))}
                    {s.wbsServices.length === 0 && (
                      <tr><td colSpan={11} className="px-3 py-8 text-center text-sm text-muted-foreground">No services added. Click "Add Service" to build the WBS.</td></tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Totals */}
            <div className="grid gap-4 md:grid-cols-4 rounded-lg border border-border bg-muted/30 p-5">
              <div>
                <div className="text-xs font-semibold text-muted-foreground mb-1 uppercase tracking-wider">Subtotal</div>
                <div className="text-lg font-bold">{s.wbsHeader.currency} {totalServices.toLocaleString()}</div>
              </div>
              <div>
                <div className="text-xs font-semibold text-muted-foreground mb-1 uppercase tracking-wider">Tax (18%)</div>
                <div className="text-lg font-bold">{s.wbsHeader.currency} {tax.toLocaleString()}</div>
              </div>
              <div>
                <div className="text-xs font-semibold text-muted-foreground mb-1 uppercase tracking-wider">Total Duration</div>
                <div className="text-lg font-bold">~</div>
              </div>
              <div>
                <div className="text-xs font-semibold text-muted-foreground mb-1 uppercase tracking-wider">Grand Total</div>
                <div className="text-lg font-bold text-primary">{s.wbsHeader.currency} {grandTotal.toLocaleString()}</div>
              </div>
            </div>

            {/* Invoice Schedule */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-semibold">Invoice Schedule</h3>
                <button onClick={addInvoice} className="inline-flex items-center gap-1 rounded-md bg-secondary text-secondary-foreground px-3 py-1.5 text-xs font-medium hover:bg-secondary/80"><Plus className="h-3.5 w-3.5" /> Add Milestone</button>
              </div>
              
              <div className="overflow-x-auto rounded-lg border border-border bg-card">
                <table className="w-full text-sm">
                  <thead className="bg-muted/40 text-xs uppercase tracking-wide text-muted-foreground text-left">
                    <tr>
                      <th className="px-3 py-2">Milestone / Description</th>
                      <th className="px-3 py-2 w-48">Amount ({s.wbsHeader.currency})</th>
                      <th className="px-3 py-2 w-48">Target Date</th>
                      <th className="px-3 py-2">Remarks</th>
                      <th className="px-3 py-2 w-10"></th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {s.wbsInvoices.map((inv) => (
                      <tr key={inv.id} className="hover:bg-accent/10">
                        <td className="px-3 py-2"><input className={cn(inputCls, "h-8")} placeholder="E.g., 25% Advance" value={inv.milestone} onChange={e => updateInvoice(inv.id, "milestone", e.target.value)} /></td>
                        <td className="px-3 py-2"><input type="number" className={cn(inputCls, "h-8")} value={inv.amount || ""} onChange={e => updateInvoice(inv.id, "amount", Number(e.target.value))} /></td>
                        <td className="px-3 py-2"><input type="date" className={cn(inputCls, "h-8")} value={inv.invoiceDate} onChange={e => updateInvoice(inv.id, "invoiceDate", e.target.value)} /></td>
                        <td className="px-3 py-2"><input className={cn(inputCls, "h-8")} value={inv.remarks} onChange={e => updateInvoice(inv.id, "remarks", e.target.value)} /></td>
                        <td className="px-3 py-2 text-center"><button onClick={() => removeInvoice(inv.id)} className="text-muted-foreground hover:text-destructive"><Trash2 className="h-4 w-4" /></button></td>
                      </tr>
                    ))}
                    {s.wbsInvoices.length === 0 && <tr><td colSpan={5} className="px-3 py-8 text-center text-sm text-muted-foreground">No invoices scheduled. Add milestones to match the Total Services Value.</td></tr>}
                  </tbody>
                </table>
              </div>
              {totalInvoices !== totalServices && (
                <div className="mt-3 rounded-lg border border-warning/30 bg-warning/5 p-3 text-xs text-warning-foreground">
                  <strong>Warning:</strong> The invoice schedule total ({totalInvoices}) does not match the total services value ({totalServices}).
                </div>
              )}
            </div>

            <div className="flex justify-end border-t border-border pt-6 pb-2">
              <button onClick={onClose} className="mr-3 rounded-md border border-input bg-card px-4 py-2 text-sm font-medium hover:bg-accent">Cancel</button>
              <button disabled={submitting || totalInvoices !== totalServices} onClick={submit} className="inline-flex items-center gap-2 rounded-md bg-primary px-6 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50">
                {submitting ? "Submitting…" : "Submit WBS"}
              </button>
            </div>
          </div>
        )}
      </div>
    </Modal>
  );
}


const inputCls = "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring";

export function Field({ label, required, children, className }: { label: string; required?: boolean; children: React.ReactNode; className?: string }) {
  return (
    <label className={cn("block", className)}>
      <span className="mb-1 block text-xs font-medium text-muted-foreground">
        {label}{required && <span className="text-destructive"> *</span>}
      </span>
      {children}
    </label>
  );
}

export function HorizontalField({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between text-sm">
      <span className="text-muted-foreground font-medium w-1/3">{label}</span>
      <div className="w-2/3">{children}</div>
    </div>
  );
}

function SummaryRow({ label, value }: { label: string; value: string }) {
  return (
    <>
      <dt className="text-muted-foreground">{label}</dt>
      <dd className="font-medium">{value}</dd>
    </>
  );
}

export function Modal({ title, children, onClose, wide, fullScreen }: { title: string; children: React.ReactNode; onClose: () => void; wide?: boolean; fullScreen?: boolean }) {
  return (
    <div className={cn("fixed inset-0 z-50 flex items-center justify-center", fullScreen ? "bg-background p-0" : "bg-black/40 p-4")} onClick={!fullScreen ? onClose : undefined}>
      <div className={cn("overflow-y-auto bg-card flex flex-col", fullScreen ? "w-full h-full rounded-none shadow-none" : "max-h-[90vh] w-full rounded-xl shadow-xl", !fullScreen && wide ? "max-w-3xl" : !fullScreen ? "max-w-lg" : "")}
        onClick={(e) => e.stopPropagation()}>
        <header className="sticky top-0 z-10 flex items-center gap-3 border-b border-border bg-card px-5 py-4">
          <h2 className="flex-1 text-lg font-semibold">{title}</h2>
          <button onClick={onClose} className="rounded-md p-1.5 hover:bg-accent" aria-label="Close"><X className="h-5 w-5" /></button>
        </header>
        <div className={cn("flex-1 p-6", fullScreen ? "mx-auto w-full max-w-5xl" : "")}>{children}</div>
      </div>
    </div>
  );
}
