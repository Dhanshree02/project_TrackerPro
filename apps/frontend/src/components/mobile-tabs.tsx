import { Link, useRouterState } from "@tanstack/react-router";
import { MoreHorizontal } from "lucide-react";
import { cn } from "@/lib/utils";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { NAV_ITEMS, DH_NAV_ITEMS, filterNavItems, type NavItem } from "@/lib/navigation";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

const MAX_TABS = 5;

export function MobileTabs() {
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const search = useRouterState({ select: (s) => s.location.search }) as any;
  const { isDhanshree, isEmployee, isHr, isPmFamily, isPmoFamily, isAccounts, isSales } =
    useRoleContext();
  const { hasPermission, hasAny } = usePermissions();

  const items: NavItem[] = filterNavItems(
    isDhanshree ? DH_NAV_ITEMS : NAV_ITEMS,
    hasPermission,
    hasAny,
    { isEmployee, isHr, isPmFamily, isPmoFamily, isAccounts, isSales },
  );
  const primary = items.slice(0, MAX_TABS);
  const overflow = items.slice(MAX_TABS);

  const isSubActive = (subTo: string, subSearch?: Record<string, any>) => {
    if (!pathname.startsWith(subTo)) return false;
    if (subTo === "/dh-employee-directory") {
      const activeTab = search.tab || "directory";
      const expectedTab = subSearch?.tab || "directory";
      return activeTab === expectedTab;
    }
    return true;
  };

  const renderTab = (it: NavItem) => {
    if (it.subItems) {
      const isParentActive = it.subItems.some((sub) => isSubActive(sub.to, sub.search));
      return (
        <DropdownMenu key={it.label}>
          <DropdownMenuTrigger asChild>
            <button
              className={cn(
                "flex flex-col items-center gap-1 py-2 text-[10px] outline-none transition-colors",
                isParentActive
                  ? "text-blue-600 dark:text-blue-400 font-semibold"
                  : isResourceRoute
                    ? "text-blue-950/70 dark:text-blue-200/70 hover:text-blue-600"
                    : "text-muted-foreground hover:text-foreground",
              )}
            >
              <it.icon className="h-5 w-5" />
              {it.label}
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent
            align="end"
            className="w-56 bg-popover text-popover-foreground shadow-md border border-border"
          >
            {it.subItems.map((sub) => {
              const subActive = isSubActive(sub.to, sub.search);
              return (
                <DropdownMenuItem key={sub.to + (sub.search?.tab || "")} asChild>
                  <Link
                    to={sub.to}
                    search={sub.search as any}
                    className={cn(
                      "w-full cursor-pointer justify-start text-xs py-2 px-3",
                      subActive && "bg-accent text-accent-foreground font-semibold",
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
          "flex flex-col items-center gap-1 py-2 text-[10px] transition-colors",
          active
            ? "text-blue-600 dark:text-blue-400 font-semibold"
            : isResourceRoute
              ? "text-blue-950/70 dark:text-blue-200/70 hover:text-blue-600"
              : "text-muted-foreground hover:text-foreground",
        )}
      >
        <it.icon className="h-5 w-5" />
        {it.label}
      </Link>
    );
  };

  const isResourceRoute =
    pathname.startsWith("/dh-employee-directory") ||
    pathname.startsWith("/resources") ||
    pathname.startsWith("/dh-exit-summary");

  return (
    <nav
      className={cn(
        "md:hidden sticky bottom-0 z-20 grid backdrop-blur-xl transition-colors",
        isResourceRoute
          ? "border-t border-slate-300 dark:border-slate-700 bg-blue-50/85 dark:bg-blue-950/60"
          : "border-t border-border/80 bg-background/85",
        overflow.length > 0
          ? "grid-cols-6"
          : items.length === 6
            ? "grid-cols-6"
            : items.length === 5
              ? "grid-cols-5"
              : "grid-cols-4",
      )}
    >
      {primary.map(renderTab)}

      {overflow.length > 0 && (
        <DropdownMenu key="more">
          <DropdownMenuTrigger asChild>
            <button
              className={cn(
                "flex flex-col items-center gap-1 py-2 text-[10px] outline-none",
                "text-muted-foreground",
              )}
            >
              <MoreHorizontal className="h-5 w-5" />
              More
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent
            align="end"
            className="w-56 bg-popover text-popover-foreground shadow-md border border-border"
          >
            {overflow.map((it) => (
              <DropdownMenuItem key={it.label + (it.to ?? "")} asChild>
                {it.subItems ? (
                  <div className="w-full cursor-pointer px-3 py-2">
                    <div className="mb-1 flex items-center gap-2 text-xs font-semibold text-foreground">
                      <it.icon className="h-4 w-4" />
                      {it.label}
                    </div>
                    <div className="space-y-0.5">
                      {it.subItems.map((sub) => (
                        <Link
                          key={sub.to + (sub.search?.tab || "")}
                          to={sub.to}
                          search={sub.search as any}
                          className="flex w-full items-center rounded-md px-2 py-1.5 text-xs text-muted-foreground hover:bg-accent hover:text-foreground"
                        >
                          {sub.label}
                        </Link>
                      ))}
                    </div>
                  </div>
                ) : (
                  <Link
                    to={it.to!}
                    className="flex w-full cursor-pointer items-center gap-2 text-xs py-2 px-3"
                  >
                    <it.icon className="h-4 w-4" />
                    {it.label}
                  </Link>
                )}
              </DropdownMenuItem>
            ))}
          </DropdownMenuContent>
        </DropdownMenu>
      )}
    </nav>
  );
}
