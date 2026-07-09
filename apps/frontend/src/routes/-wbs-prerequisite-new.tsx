// NEW WBS PREREQUISITE SECTION - 5 STEP FLOW FOR DHANSHREE ROLE
// This file contains the updated WbsPrerequisiteSection and WbsAssignmentModal
// Ready to replace the old components in projects.$projectId.tsx

import { useMemo, useState } from "react";
import { Search, X, Check, UserPlus, AlertTriangle } from "lucide-react";
import { toast } from "sonner";
import { useRoleContext } from "@/lib/role-context";
import { getPerson, projects, type Project, type Person, type Client } from "@/lib/mock-data";
import { useDhStore, dhStore, type DhProjectPrereq } from "@/lib/dh-store";
import { Modal, Field } from "@/routes/projects.index";
import { Avatar, StatusPill } from "@/components/pills";
import { cn } from "@/lib/utils";

// Helper: Calculate ongoing project count for a PM/SPM
function getOngoingProjectCountForPM(pmId: string): number {
  return projects.filter(p => p.pmId === pmId && p.status === "ongoing").length;
}

// Helper: Get client info with type
function getClientInfo(clientId: string): { name: string; type: "NEW" | "OLD"; previousPmIds: string[] } | null {
  // This would come from clients in mock-data, which now has clientType and previousPmIds
  const clientsData: Record<string, { name: string; type: "NEW" | "OLD"; previousPmIds: string[] }> = {
    c1: { name: "Northwind Bank", type: "OLD", previousPmIds: ["u3", "u4"] },
    c2: { name: "Helix Pharma", type: "OLD", previousPmIds: ["u3", "u4", "u5"] },
    c3: { name: "Orbit Retail", type: "OLD", previousPmIds: ["u3"] },
    c4: { name: "Zenith Logistics", type: "NEW", previousPmIds: [] },
    c5: { name: "Lumen Energy", type: "OLD", previousPmIds: ["u4", "u5"] },
    c6: { name: "CloudSync AI", type: "NEW", previousPmIds: [] },
    c7: { name: "FinTech Global", type: "OLD", previousPmIds: ["u3", "u4"] },
    c8: { name: "MediCare Plus", type: "NEW", previousPmIds: [] },
    c9: { name: "EcoGreen Solutions", type: "OLD", previousPmIds: ["u5"] },
    c10: { name: "AutoDrive Systems", type: "OLD", previousPmIds: ["u3", "u4", "u5"] },
  };
  return clientsData[clientId] || null;
}

function WbsPrerequisiteSection({ project }: { project: Project }) {
  const store = useDhStore((s) => s);
  const { user } = useRoleContext();
  const [showAssignModal, setShowAssignModal] = useState(false);

  const prereq = store.prereqs[project.id] ?? {
    projectId: project.id,
    validation: "Validation Pending",
    collection: "NA",
    assignedPmIds: [],
    assignedSpmIds: [],
    isProjectReadyToStart: false,
  };

  // Get client info
  const clientInfo = getClientInfo(project.clientId);
  
  // Determine eligibility
  const canUpdateCollection = user.role === "pmo" || user.role === "dhanshree";
  const canUpdateValidation = user.role === "engagement_manager" || user.role === "dhanshree";
  const isCollectionReceived = prereq.collection === "Received";
  const isValidationNeeded = isCollectionReceived;
  const canShowAssignment = isCollectionReceived && prereq.validation === "Validated";
  const canProjectStart = isCollectionReceived && prereq.validation === "Validated" && prereq.assignedPmIds.length > 0 && prereq.assignedSpmIds.length > 0;

  // Get team pool
  const teamPool = useMemo(() => {
    const ids = Array.from(new Set([project.pmId, project.tlId, ...project.teamIds]));
    return ids.map(getPerson);
  }, [project]);

  const pmPeople = teamPool.filter(p => prereq.assignedPmIds.includes(p.id));
  const spmPeople = teamPool.filter(p => prereq.assignedSpmIds.includes(p.id));

  const statusColor = (status: string) => {
    if (status === "Received") return "border-primary/30 bg-primary/10 text-primary";
    if (status === "Validated") return "border-success/30 bg-success/10 text-success";
    if (status === "Validation Pending") return "border-amber-200/30 bg-amber-50/30 text-amber-900";
    if (status === "Pending") return "border-muted-foreground/30 bg-muted text-muted-foreground";
    return "border-muted-foreground/30 bg-muted text-muted-foreground";
  };

  return (
    <>
      <div className="space-y-4 border-t border-border pt-5">
        <h3 className="text-sm font-semibold">Prerequisite & Assignment Workflow</h3>

        {/* STEP 1: CLIENT PROFILE INFORMATION */}
        <div className="rounded-lg border border-border bg-card p-4">
          <div className="flex items-center gap-2 mb-3">
            <span className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-blue-500/20 text-xs font-semibold text-blue-600">1</span>
            <h4 className="text-sm font-semibold">Client Profile Information</h4>
          </div>
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-xs text-muted-foreground">Client ID</span>
              <span className="text-sm font-medium">{project.clientId}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-xs text-muted-foreground">Client Name</span>
              <span className="text-sm font-medium">{clientInfo?.name}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-xs text-muted-foreground">Client Type</span>
              <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-[10px] font-medium", clientInfo?.type === "NEW" ? "border-green-200/50 bg-green-50/50 text-green-700" : "border-blue-200/50 bg-blue-50/50 text-blue-700")}>
                {clientInfo?.type === "NEW" ? "🆕 NEW" : "🔄 OLD"}
              </span>
            </div>

            {/* Show previous PMs if OLD client */}
            {clientInfo?.type === "OLD" && clientInfo.previousPmIds.length > 0 && (
              <div className="mt-3 pt-3 border-t border-border">
                <p className="text-xs font-semibold text-muted-foreground mb-2">Previously Assigned Project Managers</p>
                <div className="space-y-1.5">
                  {clientInfo.previousPmIds.map(pmId => {
                    const pm = getPerson(pmId);
                    const ongoingCount = getOngoingProjectCountForPM(pmId);
                    return (
                      <div key={pmId} className="flex items-center justify-between rounded-md bg-muted/30 px-2 py-1.5">
                        <div className="flex items-center gap-2">
                          <Avatar name={pm.name} size={20} />
                          <span className="text-xs font-medium">{pm.name}</span>
                        </div>
                        <span className="text-[10px] text-muted-foreground">{ongoingCount} Ongoing Projects</span>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* STEP 2: PM/SPM INTELLIGENT ASSIGNMENT FLOW */}
        <div className="rounded-lg border border-border bg-card p-4">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <span className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-purple-500/20 text-xs font-semibold text-purple-600">2</span>
              <h4 className="text-sm font-semibold">Assign WBS - Project Managers & Senior PMs</h4>
            </div>
          </div>

          {/* Current Assignments Display */}
          {(pmPeople.length > 0 || spmPeople.length > 0) && (
            <div className="grid gap-3 md:grid-cols-2 mb-3">
              <div>
                <p className="text-xs font-medium text-muted-foreground mb-2">Assigned Project Managers</p>
                <div className="flex flex-wrap gap-1.5">
                  {pmPeople.length > 0 ? (
                    pmPeople.map(p => (
                      <span key={p.id} className="inline-flex items-center gap-1 rounded-full border border-border bg-accent/30 px-2 py-0.5 text-xs">
                        <Avatar name={p.name} size={16} /> {p.name}
                      </span>
                    ))
                  ) : (
                    <span className="text-xs text-muted-foreground">None assigned yet</span>
                  )}
                </div>
              </div>
              <div>
                <p className="text-xs font-medium text-muted-foreground mb-2">Assigned Senior PMs</p>
                <div className="flex flex-wrap gap-1.5">
                  {spmPeople.length > 0 ? (
                    spmPeople.map(p => (
                      <span key={p.id} className="inline-flex items-center gap-1 rounded-full border border-border bg-accent/30 px-2 py-0.5 text-xs">
                        <Avatar name={p.name} size={16} /> {p.name}
                      </span>
                    ))
                  ) : (
                    <span className="text-xs text-muted-foreground">None assigned yet</span>
                  )}
                </div>
              </div>
            </div>
          )}

          <button
            onClick={() => setShowAssignModal(true)}
            disabled={!canShowAssignment}
            className={cn(
              "inline-flex items-center gap-2 rounded-md px-3 py-2 text-xs font-medium transition-colors",
              canShowAssignment
                ? "bg-primary text-primary-foreground hover:bg-primary/90"
                : "bg-muted text-muted-foreground cursor-not-allowed"
            )}
          >
            <UserPlus className="h-3.5 w-3.5" /> Assign PM/SPM
          </button>

          {!canShowAssignment && (
            <p className="text-[10px] text-muted-foreground mt-2">Enable when Collection Status = Received & Validation = Validated</p>
          )}
        </div>

        {/* STEP 3 & 4: PREREQUISITE COLLECTION & VALIDATION STATUS - Side by Side */}
        <div className="flex gap-4">
          {/* STEP 3: PREREQUISITE COLLECTION STATUS */}
          <div className="flex-1 rounded-lg border border-border bg-card p-4 min-w-0">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <span className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-orange-500/20 text-xs font-semibold text-orange-600">3</span>
                <h4 className="text-sm font-semibold">Prerequisite Collection Status</h4>
              </div>
            </div>
            <select
              value={prereq.collection}
              onChange={(e) => {
                dhStore.setPrereqCollection(project.id, e.target.value as any);
                toast.success("Prerequisite collection status updated");
              }}
              className="w-full h-8 rounded-md border border-input bg-card px-2 text-[10px] outline-none focus-visible:ring-2 focus-visible:ring-ring"
            >
              {(["Initiated", "Waiting For Client Response", "Received"] as const).map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
            <p className="text-[11px] text-muted-foreground mt-2">
              {prereq.collection === "Initiated" && "⚠️ Validation & assignment disabled until status = Received"}
              {prereq.collection === "Waiting For Client Response" && "⏳ Awaiting client input. Validation & assignment disabled until status = Received"}
              {prereq.collection === "Received" && "✓ Validation section enabled"}
            </p>
          </div>

          {/* STEP 4: PREREQUISITE VALIDATION STATUS - Always visible */}
          <div className="flex-1 rounded-lg border border-border bg-card p-4 min-w-0">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <span className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-cyan-500/20 text-xs font-semibold text-cyan-600">4</span>
                <h4 className="text-sm font-semibold">Prerequisite Validation Status</h4>
              </div>
            </div>
            <select
              value={prereq.validation}
              onChange={(e) => {
                dhStore.setPrereqValidation(project.id, e.target.value as any);
                toast.success("Validation status updated");
              }}
              disabled={!isValidationNeeded}
              className={cn(
                "w-full h-8 rounded-md border border-input bg-card px-2 text-[10px] outline-none focus-visible:ring-2 focus-visible:ring-ring",
                !isValidationNeeded && "opacity-50 cursor-not-allowed"
              )}
            >
              {(["Validation Pending", "Validated"] as const).map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
            <p className="text-[11px] text-muted-foreground mt-2">
              {canUpdateValidation ? "You can update this status" : "Only Engagement Manager or Dhanshree can update this status"}
            </p>
          </div>
        </div>

        {/* STEP 5: PROJECT READY TO START */}
        {canProjectStart && (
          <div className="rounded-lg border border-success/30 bg-success/10 p-4">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <span className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-success/30 text-xs font-semibold text-success">5</span>
                <h4 className="text-sm font-semibold text-success">Project Ready To Start</h4>
              </div>
              <button
                onClick={() => {
                  dhStore.setProjectReadyToStart(project.id, true);
                  toast.success("Project marked ready to start! Notifications sent to PM, SPM, HOD, and Engagement Manager.");
                }}
                className="rounded-md bg-success px-3 py-2 text-xs font-medium text-white hover:bg-success/90"
              >
                Ready To Start
              </button>
            </div>
            <p className="text-[11px] text-success/70">✓ All conditions met. PM/SPM can now assign team and begin execution.</p>
          </div>
        )}

        {/* Progress Info Box */}
        {!canProjectStart && (
          <div className="rounded-lg border border-amber-200/30 bg-amber-50/30 p-4">
            <div className="flex gap-2">
              <AlertTriangle className="h-4 w-4 flex-shrink-0 text-amber-600 mt-0.5" />
              <div className="text-xs text-amber-900/70">
                <p className="font-semibold mb-1">Workflow Progress:</p>
                <ul className="space-y-0.5">
                  <li className={cn(isCollectionReceived ? "text-amber-900" : "text-amber-600")}>
                    {isCollectionReceived ? "✓" : "○"} Collection Status = Received
                  </li>
                  <li className={cn(prereq.validation === "Validated" ? "text-amber-900" : "text-amber-600")}>
                    {prereq.validation === "Validated" ? "✓" : "○"} Validation Status = Validated
                  </li>
                  <li className={cn(prereq.assignedPmIds.length > 0 ? "text-amber-900" : "text-amber-600")}>
                    {prereq.assignedPmIds.length > 0 ? "✓" : "○"} PM(s) Assigned ({prereq.assignedPmIds.length})
                  </li>
                  <li className={cn(prereq.assignedSpmIds.length > 0 ? "text-amber-900" : "text-amber-600")}>
                    {prereq.assignedSpmIds.length > 0 ? "✓" : "○"} SPM(s) Assigned ({prereq.assignedSpmIds.length})
                  </li>
                </ul>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* WBS Assignment Modal */}
      {showAssignModal && (
        <WbsAssignmentModal
          project={project}
          prereq={prereq}
          teamPool={teamPool}
          clientInfo={clientInfo}
          onClose={() => setShowAssignModal(false)}
        />
      )}
    </>
  );
}

// Updated Assignment Modal with intelligent filtering
function WbsAssignmentModal({
  project,
  prereq,
  teamPool,
  clientInfo,
  onClose,
}: {
  project: Project;
  prereq: DhProjectPrereq;
  teamPool: Person[];
  clientInfo: { name: string; type: "NEW" | "OLD"; previousPmIds: string[] } | null;
  onClose: () => void;
}) {
  const store = useDhStore((s) => s);
  const [selectedPMs, setSelectedPMs] = useState<string[]>(prereq.assignedPmIds);
  const [selectedSPMs, setSelectedSPMs] = useState<string[]>(prereq.assignedSpmIds);
  const [pmQuery, setPmQuery] = useState("");
  const [spmQuery, setSpmQuery] = useState("");

  // Filter pool based on client history
  const filteredPool = useMemo(() => {
    if (clientInfo?.type === "OLD" && clientInfo.previousPmIds.length > 0) {
      // OLD client: only show previous PMs/SPMs
      const pmIds = new Set(clientInfo.previousPmIds);
      return teamPool.filter(p => pmIds.has(p.id));
    }
    // NEW client: show all team members
    return teamPool;
  }, [teamPool, clientInfo]);

  const pmVisiblePool = filteredPool.filter(p => !pmQuery.trim() || p.name.toLowerCase().includes(pmQuery.toLowerCase()));
  const spmVisiblePool = filteredPool.filter(p => !spmQuery.trim() || p.name.toLowerCase().includes(spmQuery.toLowerCase()));

  const selectedPMPeople = filteredPool.filter(p => selectedPMs.includes(p.id));
  const selectedSPMPeople = filteredPool.filter(p => selectedSPMs.includes(p.id));

  const togglePM = (id: string) => {
    setSelectedPMs(s => (s.includes(id) ? s.filter(x => x !== id) : [...s, id]));
  };

  const toggleSPM = (id: string) => {
    setSelectedSPMs(s => (s.includes(id) ? s.filter(x => x !== id) : [...s, id]));
  };

  const handleSubmit = () => {
    if (selectedPMs.length === 0 || selectedSPMs.length === 0) {
      toast.error("Validation", { description: "Please select at least one PM and one SPM" });
      return;
    }

    dhStore.assignPMs(project.id, selectedPMs, selectedSPMs);
    toast.success("WBS Assignment Completed", {
      description: `${selectedPMs.length} PM(s) and ${selectedSPMs.length} SPM(s) assigned. Notifications sent to HOD and PM/SPM buckets.`,
    });
    onClose();
  };

  return (
    <Modal title="Assign WBS - Project Managers & Senior PMs" onClose={onClose}>
      <div className="space-y-4">
        <p className="text-xs text-muted-foreground">
          {clientInfo?.type === "OLD"
            ? `Showing PMs/SPMs who previously worked with ${clientInfo?.name}`
            : `Showing all available PMs/SPMs`}
        </p>

        <div className="grid gap-4 md:grid-cols-2">
          {/* Project Managers Selection */}
          <div className="space-y-2">
            <label className="text-xs font-medium text-muted-foreground">Project Managers</label>
            <div className="relative">
              <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
              <input
                value={pmQuery}
                onChange={(e) => setPmQuery(e.target.value)}
                placeholder="Search PM..."
                className="h-9 w-full rounded-md border border-input bg-background pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              />
            </div>
            {selectedPMPeople.length > 0 && (
              <div className="flex flex-wrap gap-1.5 mb-2">
                {selectedPMPeople.map(p => (
                  <span key={p.id} className="inline-flex items-center gap-1 rounded-full border border-border bg-primary/10 px-2 py-0.5 text-xs">
                    <Avatar name={p.name} size={16} /> {p.name}
                    <button onClick={() => togglePM(p.id)} className="ml-1 text-muted-foreground hover:text-foreground">
                      <X className="h-3 w-3" />
                    </button>
                  </span>
                ))}
              </div>
            )}
            <ul className="max-h-40 divide-y divide-border overflow-y-auto rounded-md border border-border">
              {pmVisiblePool.map(p => {
                const isSel = selectedPMs.includes(p.id);
                const ongoingCount = getOngoingProjectCountForPM(p.id);
                return (
                  <li key={p.id}>
                    <button
                      onClick={() => togglePM(p.id)}
                      className={cn("flex w-full items-center gap-2 px-3 py-2 text-left hover:bg-accent/40 text-xs", isSel && "bg-primary/5")}
                    >
                      <Avatar name={p.name} size={22} />
                      <div className="flex-1 min-w-0">
                        <div className="font-medium">{p.name}</div>
                        <div className="text-[10px] text-muted-foreground">{ongoingCount} Ongoing Projects</div>
                      </div>
                      {isSel && <Check className="h-4 w-4 flex-shrink-0 text-primary" />}
                    </button>
                  </li>
                );
              })}
              {pmVisiblePool.length === 0 && <li className="px-3 py-4 text-center text-xs text-muted-foreground">No match</li>}
            </ul>
          </div>

          {/* Senior PMs Selection */}
          <div className="space-y-2">
            <label className="text-xs font-medium text-muted-foreground">Senior Project Managers</label>
            <div className="relative">
              <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
              <input
                value={spmQuery}
                onChange={(e) => setSpmQuery(e.target.value)}
                placeholder="Search SPM..."
                className="h-9 w-full rounded-md border border-input bg-background pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              />
            </div>
            {selectedSPMPeople.length > 0 && (
              <div className="flex flex-wrap gap-1.5 mb-2">
                {selectedSPMPeople.map(p => (
                  <span key={p.id} className="inline-flex items-center gap-1 rounded-full border border-border bg-primary/10 px-2 py-0.5 text-xs">
                    <Avatar name={p.name} size={16} /> {p.name}
                    <button onClick={() => toggleSPM(p.id)} className="ml-1 text-muted-foreground hover:text-foreground">
                      <X className="h-3 w-3" />
                    </button>
                  </span>
                ))}
              </div>
            )}
            <ul className="max-h-40 divide-y divide-border overflow-y-auto rounded-md border border-border">
              {spmVisiblePool.map(p => {
                const isSel = selectedSPMs.includes(p.id);
                const ongoingCount = getOngoingProjectCountForPM(p.id);
                return (
                  <li key={p.id}>
                    <button
                      onClick={() => toggleSPM(p.id)}
                      className={cn("flex w-full items-center gap-2 px-3 py-2 text-left hover:bg-accent/40 text-xs", isSel && "bg-primary/5")}
                    >
                      <Avatar name={p.name} size={22} />
                      <div className="flex-1 min-w-0">
                        <div className="font-medium">{p.name}</div>
                        <div className="text-[10px] text-muted-foreground">{ongoingCount} Ongoing Projects</div>
                      </div>
                      {isSel && <Check className="h-4 w-4 flex-shrink-0 text-primary" />}
                    </button>
                  </li>
                );
              })}
              {spmVisiblePool.length === 0 && <li className="px-3 py-4 text-center text-xs text-muted-foreground">No match</li>}
            </ul>
          </div>
        </div>

        <div className="flex justify-end gap-2 border-t border-border pt-3">
          <button onClick={onClose} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">
            Cancel
          </button>
          <button
            onClick={handleSubmit}
            className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
          >
            Submit WBS Assignment
          </button>
        </div>
      </div>
    </Modal>
  );
}

export { WbsPrerequisiteSection, WbsAssignmentModal };
