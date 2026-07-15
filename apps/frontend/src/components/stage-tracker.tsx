import React, { useState } from "react";
import { ChevronRight, Circle, CheckCircle2, AlertCircle, CheckCheck } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import type { ProjectStageData, StageHistoryEntry } from "@/lib/dh-store";

// ── Sub-stage types (Dhanshree role only) ────────────────────────────────────

export interface SubStageItem {
  /** Display label shown in the checklist. */
  label: string;
  /** completed = green tick, active = blue dot, pending = grey circle */
  status: "completed" | "active" | "pending";
}

export interface StageTrackerProps {
  stages: ProjectStageData[];
  /** Optional: sub-status string keyed by stageName e.g. { Sales: "WBS Stabilized" } */
  subStatusMap?: Record<string, string>;
  /**
   * Optional: ordered sub-stage checklist items keyed by stageName.
   * When provided, clicking a stage shows the checklist panel instead of
   * the plain history view.
   * e.g. { Sales: [{label:"WBS Created",status:"completed"}, …], … }
   */
  subStagesMap?: Record<string, SubStageItem[]>;
  onStageClick?: (stage: ProjectStageData) => void;
}

export function StageTracker({ stages, subStatusMap, subStagesMap, onStageClick }: StageTrackerProps) {
  const [selectedStage, setSelectedStage] = useState<ProjectStageData | null>(null);

  const getStageColor = (index: number) => {
    const colors = [
      "from-blue-500 to-blue-600",     // Sales - Blue
      "from-purple-500 to-purple-600", // PMO - Purple
      "from-orange-500 to-orange-600", // Delivery - Orange
      "from-emerald-500 to-emerald-600", // Accounts - Green
    ];
    return colors[index];
  };

  const getStatusBadgeColor = (status: string) => {
    if (
      status === "Completed" || status === "Approval" ||
      status === "Invoice Raised" || status === "PO Raised" || status === "PO Received" ||
      status === "WBS Approval Completed" || status === "Project Allocation Completed" ||
      status === "Payment Received" || status === "WBS Created" || status === "WBS Stabilized" ||
      status === "WBS Modified" || status === "Ready To Start" || status === "Sr. PM Assigned" ||
      status === "PM Assigned" || status === "Prerequisite Collected" ||
      status === "Prerequisite Validated" || status === "Billing Validation" ||
      status === "After Released" ||
      status === "Certification Released" || status === "PO Not Required"
    ) {
      return "bg-emerald-100 text-emerald-800";
    }
    if (status === "Cancelled" || status === "On Hold Internally" || status === "On Hold Externally") {
      return "bg-red-100 text-red-800";
    }
    if (
      status === "Ongoing" || status === "Assigned" || status === "Validation" ||
      status === "Ready To Start Project" || status === "Validation Completed" ||
      status === "Payment Pending" || status === "Invoice Not Raised" || status === "PO Pending" ||
      status === "Senior PM Assigned" || status === "Project Manager Assigned" ||
      status === "Initial Testing Completed" || status === "Re-testing Completed" ||
      status === "Meta Data Completed"
    ) {
      return "bg-blue-100 text-blue-800";
    }
    if (status === "After Release") {
      return "bg-purple-100 text-purple-800";
    }
    return "bg-gray-100 text-gray-800";
  };

  const getSubStatusColor = (subStatus: string) => {
    if (
      subStatus.includes("Completed") ||
      subStatus.includes("Received") ||
      subStatus.includes("Validated") ||
      subStatus.includes("Approval") ||
      subStatus.includes("Released") ||
      subStatus.includes("Stabilized")
    ) return "text-emerald-600 font-semibold";
    if (
      subStatus.includes("Pending") ||
      subStatus.includes("Cancelled") ||
      subStatus.includes("Hold")
    ) return "text-amber-600 font-semibold";
    return "text-blue-600 font-semibold";
  };

  const getStageIcon = (stage: ProjectStageData) => {
    if (stage.isCompleted) {
      return <CheckCircle2 className="w-6 h-6 text-emerald-500" />;
    }
    if (stage.isActive) {
      return <AlertCircle className="w-6 h-6 text-blue-500 animate-pulse" />;
    }
    return <Circle className="w-6 h-6 text-gray-300" />;
  };

  const handleStageClick = (stage: ProjectStageData) => {
    setSelectedStage(selectedStage?.stageName === stage.stageName ? null : stage);
    onStageClick?.(stage);
  };

  return (
    <div className="w-full">
      {/* Main Tracker */}
      <div className="relative w-full px-2 py-4">
        {/* Background connecting line */}
        <div className="absolute top-[32px] left-0 right-0 h-0.5 bg-gray-200 z-0" />

        {/* Stages Container */}
        <div className="relative z-10 flex justify-between items-start gap-2">
          {stages.map((stage, index) => {
            const subStatus = subStatusMap?.[stage.stageName];
            return (
              <div key={index} className="flex flex-col items-center group flex-1 min-w-0">
                {/* Stage Circle/Icon */}
                <button
                  onClick={() => handleStageClick(stage)}
                  className={`relative mb-2 p-1.5 rounded-full transition-all duration-300 ${
                    selectedStage?.stageName === stage.stageName
                      ? "bg-primary/10 ring-2 ring-primary"
                      : stage.isActive ? "bg-blue-50 ring-1.5 ring-blue-400" : "bg-white ring-1.5 ring-gray-200"
                  } hover:ring-1.5 hover:ring-blue-400 cursor-pointer`}
                >
                  {getStageIcon(stage)}
                </button>

                {/* Stage Label */}
                <div className="text-center w-full px-1">
                  <p className="text-xs font-semibold text-gray-900 mb-1 truncate">{stage.stageName}</p>

                  {/* Sub-Status line — shows last completed sub-stage name */}
                  {(() => {
                    const subStages = subStagesMap?.[stage.stageName];
                    if (subStages && subStages.length > 0) {
                      const completedStages = subStages.filter(s => s.status === "completed");
                      const lastCompleted = completedStages.length > 0 ? completedStages[completedStages.length - 1] : null;
                      if (lastCompleted) {
                        return (
                          <p className="mt-1 text-[10px] leading-snug truncate text-emerald-600 font-semibold">
                            {lastCompleted.label}
                          </p>
                        );
                      }
                      // No sub-stage completed yet — show first active or pending
                      const activeStage = subStages.find(s => s.status === "active");
                      if (activeStage) {
                        return (
                          <p className="mt-1 text-[10px] leading-snug truncate text-blue-600 font-semibold">
                            {activeStage.label}
                          </p>
                        );
                      }
                    }
                    // Fallback to subStatusMap if no subStagesMap
                    if (subStatus) {
                      return (
                        <p className={`mt-1 text-[10px] leading-snug truncate ${getSubStatusColor(subStatus)}`}>
                          {subStatus}
                        </p>
                      );
                    }
                    return null;
                  })()}
                </div>

                {/* Completion indicator */}
                <div className="mt-1.5 text-center text-[10px]">
                  {stage.isCompleted && <span className="text-emerald-600 font-semibold">✓ Complete</span>}
                  {stage.isActive && !stage.isCompleted && <span className="text-blue-600 font-semibold">• Active</span>}
                  {!stage.isCompleted && !stage.isActive && <span className="text-gray-400">Pending</span>}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Selected Stage Details Panel */}
      {selectedStage && (
        subStagesMap?.[selectedStage.stageName]
          ? (
            <SubStagePanel
              stage={selectedStage}
              subStages={subStagesMap[selectedStage.stageName]}
              subStatus={subStatusMap?.[selectedStage.stageName]}
              onClose={() => setSelectedStage(null)}
            />
          ) : (
            <StageDetailView
              stage={selectedStage}
              subStatus={subStatusMap?.[selectedStage.stageName]}
              onClose={() => setSelectedStage(null)}
            />
          )
      )}
    </div>
  );
}

// ── Sub-stage Checklist Panel ─────────────────────────────────────────────────

interface SubStagePanelProps {
  stage: ProjectStageData;
  subStages: SubStageItem[];
  subStatus?: string;
  onClose: () => void;
}

function SubStagePanel({ stage, subStages, subStatus, onClose }: SubStagePanelProps) {
  const completedCount = subStages.filter(s => s.status === "completed").length;

  return (
    <div className="mt-2 p-4 bg-gray-50 rounded-lg border border-gray-200">
      {/* Header */}
      <div className="flex justify-between items-center mb-3">
        <div>
          <h3 className="text-sm font-bold text-gray-900">{stage.stageName} Stage</h3>
          <p className="text-xs text-gray-600 mt-0.5">
            Status: <span className="font-semibold text-gray-900">{stage.currentStatus}</span>
            {subStatus && <span className="ml-2 text-blue-600 font-semibold">· {subStatus}</span>}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-[10px] font-medium text-gray-500">
            {completedCount}/{subStages.length} completed
          </span>
          <Button variant="ghost" size="sm" onClick={onClose} className="h-6 w-6 p-0">✕</Button>
        </div>
      </div>

      {/* Progress bar */}
      <div className="mb-3 h-1.5 w-full rounded-full bg-gray-200 overflow-hidden">
        <div
          className="h-full rounded-full bg-emerald-500 transition-all duration-500"
          style={{ width: `${subStages.length > 0 ? (completedCount / subStages.length) * 100 : 0}%` }}
        />
      </div>

      {/* Sub-stage checklist */}
      <div className="space-y-1.5">
        {subStages.map((item, idx) => (
          <SubStageRow key={idx} item={item} />
        ))}
      </div>
    </div>
  );
}

function SubStageRow({ item }: { item: SubStageItem }) {
  if (item.status === "completed") {
    return (
      <div className="flex items-center gap-2.5 rounded-md bg-white border border-emerald-100 px-3 py-2">
        <CheckCheck className="h-3.5 w-3.5 shrink-0 text-emerald-500" />
        <span className="text-xs font-medium text-emerald-700">{item.label}</span>
        <span className="ml-auto text-[10px] font-medium text-emerald-500">Done</span>
      </div>
    );
  }
  if (item.status === "active") {
    return (
      <div className="flex items-center gap-2.5 rounded-md bg-blue-50 border border-blue-200 px-3 py-2">
        <AlertCircle className="h-3.5 w-3.5 shrink-0 text-blue-500 animate-pulse" />
        <span className="text-xs font-semibold text-blue-700">{item.label}</span>
        <span className="ml-auto text-[10px] font-medium text-blue-500">Active</span>
      </div>
    );
  }
  return (
    <div className="flex items-center gap-2.5 rounded-md bg-white border border-gray-100 px-3 py-2 opacity-60">
      <Circle className="h-3.5 w-3.5 shrink-0 text-gray-300" />
      <span className="text-xs font-medium text-gray-500">{item.label}</span>
      <span className="ml-auto text-[10px] font-medium text-gray-400">Pending</span>
    </div>
  );
}

// ── Legacy detail view (used when subStagesMap is not provided) ───────────────

interface StageDetailViewProps {
  stage: ProjectStageData;
  subStatus?: string;
  onClose: () => void;
}

function StageDetailView({ stage, subStatus, onClose }: StageDetailViewProps) {
  return (
    <div className="mt-2 p-4 bg-gray-50 rounded-lg border border-gray-200">
      <div className="flex justify-between items-center mb-4">
        <div>
          <h3 className="text-sm font-bold text-gray-900">{stage.stageName} Stage</h3>
          <p className="text-xs text-gray-600 mt-0.5">
            Status: <span className="font-semibold text-gray-900">{stage.currentStatus}</span>
            {subStatus && <span className="ml-2 text-blue-600 font-semibold">· {subStatus}</span>}
          </p>
        </div>
        <Button variant="ghost" size="sm" onClick={onClose} className="h-6 w-6 p-0">✕</Button>
      </div>

      {/* Status History */}
      <div className="space-y-2">
        <h4 className="text-xs font-semibold text-gray-900">Status History</h4>
        {stage.history && stage.history.length > 0 ? (
          <div className="space-y-2">
            {stage.history.map((entry, index) => (
              <HistoryEntry key={entry.id} entry={entry} isLatest={index === stage.history.length - 1} />
            ))}
          </div>
        ) : (
          <p className="text-xs text-gray-500">No history available for this stage.</p>
        )}
      </div>
    </div>
  );
}

interface HistoryEntryProps {
  entry: StageHistoryEntry;
  isLatest: boolean;
}

function HistoryEntry({ entry, isLatest }: HistoryEntryProps) {
  const timestamp = new Date(entry.timestamp);
  const formattedTime = timestamp.toLocaleString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });

  return (
    <div className={`p-2.5 rounded-md border-l-2 ${isLatest ? "bg-white border-blue-500" : "bg-white border-gray-200"}`}>
      <div className="flex items-start justify-between gap-2">
        <div className="flex-1 min-w-0">
          <p className="text-xs font-semibold text-gray-900">{entry.action}</p>
          <p className="text-[11px] text-gray-600 mt-0.5">
            Updated by <span className="font-medium">{entry.updatedByName}</span>
          </p>
          {entry.previousStatus && (
            <p className="text-[11px] text-gray-600 mt-1">
              <span className="line-through text-red-500">{entry.previousStatus}</span>
              {" → "}
              <span className="font-semibold text-emerald-600">{entry.newStatus}</span>
            </p>
          )}
        </div>
        <div className="text-right whitespace-nowrap">
          <p className="text-[10px] text-gray-500">{formattedTime}</p>
          {isLatest && <Badge className="mt-1 bg-blue-100 text-blue-800 text-[10px]">Latest</Badge>}
        </div>
      </div>
    </div>
  );
}
