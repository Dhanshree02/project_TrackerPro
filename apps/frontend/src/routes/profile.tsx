import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/app-shell";
import { useAuth } from "@/lib/auth-context";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/profile")({
  head: () => ({
    meta: [{ title: "My profile — Pulse PMO" }],
  }),
  component: ProfilePage,
});

function initials(name: string) {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  return parts.slice(0, 2).map((part) => part[0]?.toUpperCase() ?? "").join("") || "P";
}

function display(value?: string | null) {
  const text = value?.trim();
  return text || "—";
}

function Group({
  title,
  rows,
  className,
}: {
  title: string;
  rows: { label: string; value?: string | null }[];
  className?: string;
}) {
  return (
    <section className={cn("flex h-full flex-col", className)}>
      <h2 className="mb-1.5 h-5 px-5 text-[13px] leading-5 text-muted-foreground">{title}</h2>
      <div className="flex flex-1 flex-col overflow-hidden rounded-xl bg-card">
        {rows.map((row, index) => (
          <div
            key={row.label}
            className={cn(
              "grid min-h-12 grid-cols-[11rem_minmax(0,1fr)] items-center gap-4 px-5",
              index > 0 && "border-t border-border",
            )}
          >
            <span className="text-sm text-muted-foreground">{row.label}</span>
            <span className="min-w-0 text-sm text-foreground break-words">{display(row.value)}</span>
          </div>
        ))}
      </div>
    </section>
  );
}

function ProfilePage() {
  const { user, status } = useAuth();

  if (status === "loading" || !user) {
    return (
      <AppShell title="My profile">
        <p className="text-sm text-muted-foreground">Loading profile…</p>
      </AppShell>
    );
  }

  const active = /^active/i.test(user.status?.trim() ?? "");
  const subtitle = [user.designation, user.department].filter(Boolean).join(" · ");

  return (
    <AppShell title="My profile">
      <div className="flex w-full flex-col gap-6">
        <header className="flex items-center gap-5 rounded-xl bg-card px-6 py-5">
          <div className="flex h-16 w-16 shrink-0 items-center justify-center rounded-full bg-primary text-xl font-semibold text-primary-foreground">
            {initials(user.name)}
          </div>
          <div className="min-w-0 flex-1">
            <h1 className="truncate text-2xl font-semibold tracking-tight text-foreground">{user.name}</h1>
            {subtitle && <p className="mt-1 truncate text-sm text-muted-foreground">{subtitle}</p>}
          </div>
          {user.status?.trim() && (
            <span
              className={cn(
                "shrink-0 rounded-full px-2.5 py-0.5 text-xs font-medium",
                active ? "bg-success/15 text-success" : "bg-muted text-muted-foreground",
              )}
            >
              {user.status.trim()}
            </span>
          )}
        </header>

        <div className="grid items-stretch gap-6 lg:grid-cols-2">
          <Group
            title="Organization"
            rows={[
              { label: "Department", value: user.department },
              { label: "Sub-department", value: user.subDepartment },
              { label: "Designation", value: user.designation },
              { label: "Reporting manager", value: user.reportingManager },
              { label: "Work location", value: user.workLocation },
            ]}
          />
          <div className="flex h-full flex-col gap-6">
            <Group
              title="Contact"
              rows={[
                { label: "Work email", value: user.email },
                { label: "Phone", value: user.phone },
              ]}
            />
            <Group
              className="flex-1"
              title="Account"
              rows={[
                { label: "TK ID", value: user.employeeCode },
                { label: "Access role", value: user.role },
              ]}
            />
          </div>
        </div>
      </div>
    </AppShell>
  );
}
