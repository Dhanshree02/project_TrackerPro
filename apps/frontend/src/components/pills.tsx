import { cn } from "@/lib/utils";
import type { HealthStatus, ProjectStatus, IssuePriority, IssueStatus, TaskStatus, TimesheetStatus } from "@/lib/mock-data";

const base = "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-medium border";

export function HealthPill({ status }: { status: HealthStatus }) {
  const map: Record<HealthStatus, string> = {
    green: "bg-success/10 text-success border-success/30",
    amber: "bg-warning/15 text-warning-foreground border-warning/40",
    red: "bg-destructive/10 text-destructive border-destructive/30",
  };
  const label = { green: "Healthy", amber: "At Risk", red: "Critical" }[status];
  return (
    <span className={cn(base, map[status])}>
      <span className={cn("h-1.5 w-1.5 rounded-full", {
        "bg-success": status === "green",
        "bg-warning": status === "amber",
        "bg-destructive": status === "red",
      })} />
      {label}
    </span>
  );
}

export function StatusPill({ status }: { status: ProjectStatus }) {
  const map: Record<ProjectStatus, string> = {
    ongoing: "bg-info/10 text-info border-info/30",
    completed: "bg-success/10 text-success border-success/30",
    on_hold: "bg-muted text-muted-foreground border-border",
  };
  const label = { ongoing: "Ongoing", completed: "Completed", on_hold: "On Hold" }[status];
  return <span className={cn(base, map[status])}>{label}</span>;
}

export function PriorityPill({ priority }: { priority: IssuePriority }) {
  const map: Record<IssuePriority, string> = {
    low: "bg-muted text-muted-foreground border-border",
    medium: "bg-info/10 text-info border-info/30",
    high: "bg-warning/15 text-warning-foreground border-warning/40",
    critical: "bg-destructive/10 text-destructive border-destructive/30",
  };
  return <span className={cn(base, map[priority])}>{priority.toUpperCase()}</span>;
}

export function IssueStatusPill({ status }: { status: IssueStatus }) {
  const map: Record<IssueStatus, string> = {
    open: "bg-destructive/10 text-destructive border-destructive/30",
    in_progress: "bg-info/10 text-info border-info/30",
    resolved: "bg-success/10 text-success border-success/30",
    closed: "bg-muted text-muted-foreground border-border",
  };
  const label = { open: "Open", in_progress: "In Progress", resolved: "Resolved", closed: "Closed" }[status];
  return <span className={cn(base, map[status])}>{label}</span>;
}

export function TaskStatusPill({ status }: { status: TaskStatus }) {
  const map: Record<TaskStatus, string> = {
    todo: "bg-muted text-muted-foreground border-border",
    in_progress: "bg-info/10 text-info border-info/30",
    review: "bg-warning/15 text-warning-foreground border-warning/40",
    done: "bg-success/10 text-success border-success/30",
  };
  const label = { todo: "To Do", in_progress: "In Progress", review: "Review", done: "Done" }[status];
  return <span className={cn(base, map[status])}>{label}</span>;
}

export function TimesheetStatusPill({ status }: { status: TimesheetStatus }) {
  const map: Record<TimesheetStatus, string> = {
    draft: "bg-muted text-muted-foreground border-border",
    submitted: "bg-info/10 text-info border-info/30",
    approved: "bg-success/10 text-success border-success/30",
    rejected: "bg-destructive/10 text-destructive border-destructive/30",
  };
  const label = { draft: "Draft", submitted: "Submitted", approved: "Approved", rejected: "Rejected" }[status];
  return <span className={cn(base, map[status])}>{label}</span>;
}

export function ProgressBar({ value, className }: { value: number; className?: string }) {
  return (
    <div className={cn("h-1.5 w-full overflow-hidden rounded-full bg-muted", className)}>
      <div
        className={cn(
          "h-full rounded-full transition-all",
          value >= 80 ? "bg-success" : value >= 40 ? "bg-info" : "bg-warning",
        )}
        style={{ width: `${Math.min(100, Math.max(0, value))}%` }}
      />
    </div>
  );
}

export function Avatar({ name, size = 28, className }: { name: string; size?: number; className?: string }) {
  const initials = name.split(" ").map((p) => p[0]).slice(0, 2).join("");
  return (
    <span
      className={cn(
        "inline-flex items-center justify-center rounded-full bg-accent text-accent-foreground text-[11px] font-semibold ring-2 ring-card",
        className
      )}
      style={{ width: size, height: size }}
    >
      {initials}
    </span>
  );
}
