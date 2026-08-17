import { createFileRoute, Link, Navigate, notFound } from "@tanstack/react-router";
import { ArrowLeft } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { people, type Person } from "@/lib/mock-data";
import { getDept } from "@/lib/dh-helpers";
import { Avatar } from "@/components/pills";

export const Route = createFileRoute("/resources/$employeeId")({
  head: () => ({
    meta: [
      { title: "Employee Details — Pulse PMO" },
      { name: "description", content: "Basic employee information from the resource directory." },
    ],
  }),
  loader: ({ params }) => {
    const person = people.find((p) => p.id === params.employeeId);
    if (!person) throw notFound();
    return { person };
  },
  component: EmployeeDetailsPage,
});

function Detail({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="border-b border-border py-2.5 last:border-0">
      <div className="text-[11px] font-medium uppercase tracking-wider text-muted-foreground">
        {label}
      </div>
      <div className="mt-1 text-sm text-foreground">{value ?? "—"}</div>
    </div>
  );
}

function EmployeeDetailsPage() {
  const { isEmployee, isPMO, isHOD, isBO } = useRoleContext();
  const { hasPermission } = usePermissions();
  const { person } = Route.useLoaderData() as { person: Person };

  // Basic directory access — same rule as the Resources page. Read-only, no management actions.
  if (!isEmployee && !isPMO && !isHOD && !isBO && !hasPermission("resources.view"))
    return <Navigate to="/" />;

  return (
    <AppShell title={person.name} subtitle="Employee details · view only">
      {/* Breadcrumb */}
      <div className="mb-4 flex items-center gap-2 text-xs text-muted-foreground">
        <Link
          to="/resources"
          className="inline-flex items-center gap-1 transition-colors hover:text-foreground"
        >
          <ArrowLeft className="h-3.5 w-3.5" /> Resources
        </Link>
        <span>/</span>
        <span className="text-foreground">{person.name}</span>
      </div>

      {/* Basic info — read-only */}
      <div className="rounded-xl border border-border bg-card shadow-sm">
        <div className="flex items-center gap-4 border-b border-border p-6">
          <Avatar name={person.name} size={52} />
          <div>
            <h1 className="text-xl font-semibold tracking-tight">{person.name}</h1>
            <p className="mt-0.5 text-sm text-muted-foreground">
              {person.role} · {getDept(person)}
            </p>
          </div>
        </div>
        <div className="grid grid-cols-1 gap-x-8 p-6 sm:grid-cols-2">
          <Detail label="Employee ID" value={<span className="font-mono">{person.id}</span>} />
          <Detail label="Employee Name" value={person.name} />
          <Detail label="Department" value={getDept(person)} />
          <Detail label="Designation" value={person.role} />
          <Detail label="Email" value={person.email || "—"} />
        </div>
      </div>
    </AppShell>
  );
}
