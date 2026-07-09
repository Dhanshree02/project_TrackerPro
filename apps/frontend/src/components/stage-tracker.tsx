import React, { useState } from "react";
import { ChevronRight, Circle, CheckCircle2, AlertCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import type { ProjectStageData, StageHistoryEntry } from "@/lib/dh-store";

export interface StageTrackerProps {
  stages: ProjectStageData[];
  /** Optional: sub-status string keyed by stageName e.g. { Sales: "WBS Approval Completed", PMO: "Validation Completed" } */
  subStatusMap?: Record<string, string>;
  onStageClick?: (stage: ProjectStageData) => void;
}

export function StageTracker({ stages, subStatusMap, onStageClick }: StageTrackerProps) {
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
    if (status === "Completed" || status === "Approval" || status === "Invoice Raised" || status === "PO Raised" || status === "PO Received" || status === "WBS Approval Completed" || status === "Project Allocation Completed" || status === "Payment Received") {
      return "bg-emerald-100 text-emerald-800";
    }
    if (status === "Cancelled" || status === "On Hold Internally" || status === "On Hold Externally") {
      return "bg-red-100 text-red-800";
    }
    if (status === "Ongoing" || status === "Assigned" || status === "Validation" || status === "Ready To Start Project" || status === "Validation Completed" || status === "Payment Pending" || status === "Invoice Not Raised" || status === "PO Pending") {
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
      subStatus.includes("Approval")
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
                  <Badge className={`${getStatusBadgeColor(stage.currentStatus)} text-[10px] font-medium px-1.5 py-0.5`}>
                    {stage.currentStatus}
                  </Badge>

                  {/* Sub-Status line */}
                  {subStatus && (
                    <p className={`mt-1 text-[10px] leading-snug truncate ${getSubStatusColor(subStatus)}`}>
                      {subStatus}
                    </p>
                  )}
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

      {/* Selected Stage Details */}
      {selectedStage && (
        <StageDetailView stage={selectedStage} subStatus={subStatusMap?.[selectedStage.stageName]} onClose={() => setSelectedStage(null)} />
      )}
    </div>
  );
}

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
