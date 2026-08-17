import React from "react";
import { Link } from "@tanstack/react-router";
import { ChevronRight, Calendar, Wallet, Building2, FolderOpen } from "lucide-react";
import { StatusPill, HealthPill, ProgressBar } from "@/components/pills";
import { StageTracker } from "@/components/stage-tracker";
import { formatDate } from "@/lib/utils";
import type { Project, Client } from "@/lib/mock-data";

interface ProjectHeaderProps {
  project: Project;
  client: Client;
  stages: any[];
  activeStageId?: string;
  onSelectStage?: (id: string) => void;
}

export function ProjectHeader({ project, client, stages, activeStageId, onSelectStage }: ProjectHeaderProps) {
  return (
    <div className="space-y-4 mb-6">
      {/* Breadcrumb Navigation */}
      <nav className="flex items-center gap-1.5 text-xs text-muted-foreground">
        <Link to="/projects" className="hover:text-foreground transition-colors">Projects</Link>
        <ChevronRight className="h-3 w-3" />
        <Link to="/customers/$clientId" params={{ clientId: client.id }} className="hover:text-foreground transition-colors">
          {client.name}
        </Link>
        <ChevronRight className="h-3 w-3" />
        <span className="text-foreground font-medium truncate">{project.name}</span>
      </nav>

      {/* Main Header Banner */}
      <div className="flex flex-col gap-4 rounded-xl border border-border bg-card p-5 shadow-sm md:flex-row md:items-center md:justify-between">
        <div className="flex items-start gap-4">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-info text-primary-foreground font-bold text-lg shadow-sm">
            <FolderOpen className="h-6 w-6" />
          </div>
          <div>
            <div className="flex items-center gap-2.5 flex-wrap">
              <h1 className="text-xl font-bold tracking-tight text-foreground">{project.name}</h1>
              <StatusPill status={project.status} />
              <HealthPill status={project.health} />
            </div>
            <p className="mt-1 text-xs text-muted-foreground">
              Customer: <Link to="/customers/$clientId" params={{ clientId: client.id }} className="font-semibold text-primary hover:underline">{client.name}</Link> · Industry: {client.industry}
            </p>
          </div>
        </div>

        {/* Top Summary Metrics */}
        <div className="flex items-center gap-6 border-t border-border pt-4 md:border-t-0 md:pt-0">
          <div>
            <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground flex items-center gap-1">
              <Calendar className="h-3 w-3" /> Timeline
            </span>
            <p className="text-xs font-semibold mt-0.5">{formatDate(project.startDate)} → {formatDate(project.endDate)}</p>
          </div>
          <div>
            <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground flex items-center gap-1">
              <Wallet className="h-3 w-3" /> Budget
            </span>
            <p className="text-xs font-semibold mt-0.5">{project.currency ?? "INR"} {project.budget?.toLocaleString()}</p>
          </div>
          <div className="min-w-[120px]">
            <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">Overall Progress</span>
            <div className="mt-1">
              <ProgressBar value={project.progress} />
            </div>
          </div>
        </div>
      </div>

      {/* Stage Tracker Bar */}
      {stages && stages.length > 0 && (
        <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
          <StageTracker stages={stages} />
        </div>
      )}
    </div>
  );
}
