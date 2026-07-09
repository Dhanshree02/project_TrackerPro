import { Link, useRouterState } from "@tanstack/react-router";
import { LayoutDashboard, Briefcase, Activity, CheckCircle2, Users, Layers, BarChart3, ListChecks, FolderKanban, Building2, ContactRound, Settings } from "lucide-react";
import { cn } from "@/lib/utils";
import { useRoleContext } from "@/lib/role-context";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

type SubItem = { to: string; label: string };
type Item = {
  to?: string;
  label: string;
  icon: typeof LayoutDashboard;
  exact?: boolean;
  subItems?: SubItem[];
};

const baseItems: Item[] = [
  { to: "/", label: "Home", icon: LayoutDashboard, exact: true },
  { to: "/clients", label: "Clients", icon: Briefcase },
];
const tail: Item[] = [
  { to: "/health", label: "Health", icon: Activity },
  { to: "/approvals", label: "Approvals", icon: CheckCircle2 },
];

export function MobileTabs() {
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const { isPMO, isHOD, isBO, isDhanshree } = useRoleContext();

  const items: Item[] = isDhanshree
    ? [
        { to: "/", label: "Home", icon: LayoutDashboard, exact: true },
        { to: "/action-centre", label: "Action", icon: ListChecks },
        { to: "/projects", label: "Projects", icon: FolderKanban },
        { to: "/customers", label: "Clients", icon: Building2 },
        {
          label: "Resources",
          icon: Users,
          subItems: [
            { to: "/dh-employee-directory", label: "Employee Directory" },
            { to: "/dh-resource-pool", label: "Resource Pool" },
            { to: "/dh-exit-summary", label: "Employee Exit Summary" },
            { to: "/dh-org-tree", label: "Organization Tree" },
          ],
        },
        { to: "/dh-settings", label: "Settings", icon: Settings },
      ]
    : isBO
    ? [
        { to: "/", label: "Home", icon: LayoutDashboard, exact: true },
        { to: "/portfolio", label: "Portfolio", icon: Layers },
        { to: "/clients", label: "Clients", icon: Briefcase },
        { to: "/health", label: "Health", icon: Activity },
        { to: "/reports", label: "Reports", icon: BarChart3 },
      ]
    : isHOD
      ? [
          { to: "/", label: "Home", icon: LayoutDashboard, exact: true },
          { to: "/portfolio", label: "Portfolio", icon: Layers },
          { to: "/resources", label: "Resources", icon: Users },
          { to: "/health", label: "Health", icon: Activity },
          { to: "/reports", label: "Reports", icon: BarChart3 },
        ]
      : isPMO
        ? [...baseItems, { to: "/resources", label: "Resources", icon: Users }, ...tail]
        : [...baseItems, ...tail];

  return (
    <nav
      className={cn(
        "md:hidden sticky bottom-0 z-20 grid border-t border-border bg-background",
        items.length === 6 ? "grid-cols-6" : items.length === 5 ? "grid-cols-5" : "grid-cols-4",
      )}
    >
      {items.map((it) => {
        if (it.subItems) {
          const isParentActive = it.subItems.some((sub) => pathname.startsWith(sub.to));

          return (
            <DropdownMenu key={it.label}>
              <DropdownMenuTrigger asChild>
                <button
                  className={cn(
                    "flex flex-col items-center gap-1 py-2 text-[10px] outline-none",
                    isParentActive ? "text-primary" : "text-muted-foreground"
                  )}
                >
                  <it.icon className="h-5 w-5" />
                  {it.label}
                </button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56 bg-popover text-popover-foreground shadow-md border border-border">
                {it.subItems.map((sub) => {
                  const subActive = pathname.startsWith(sub.to);
                  return (
                    <DropdownMenuItem key={sub.to} asChild>
                      <Link
                        to={sub.to}
                        className={cn(
                          "w-full cursor-pointer justify-start text-xs py-2 px-3",
                          subActive && "bg-accent text-accent-foreground font-semibold"
                        )}
                      >
                        {sub.label}
                      </Link>
                    </DropdownMenuItem>
                  );
                })}
              </DropdownMenuContent>
            </DropdownMenu>
          );
        }

        const active = it.to && (it.exact ? pathname === it.to : pathname.startsWith(it.to));
        return (
          <Link
            key={it.to}
            to={it.to!}
            className={cn(
              "flex flex-col items-center gap-1 py-2 text-[10px]",
              active ? "text-primary" : "text-muted-foreground",
            )}
          >
            <it.icon className="h-5 w-5" />
            {it.label}
          </Link>
        );
      })}
    </nav>
  );
}
