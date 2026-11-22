import * as React from "react";
import * as CollapsiblePrimitive from "@radix-ui/react-collapsible";
import { ChevronDown, ChevronRight, ChevronUp } from "lucide-react";
import { cn } from "@/lib/utils";

const motionSafe = "transition-transform duration-200 ease-out motion-reduce:transition-none";

/**
 * Apple HIG disclosure triangle: points along the leading edge when collapsed,
 * rotates down when expanded. Use for hierarchies (sidebar, trees, accordions).
 */
export function DisclosureTriangleIcon({
  expanded,
  className,
  size = "sm",
}: {
  expanded: boolean;
  className?: string;
  size?: "xs" | "sm" | "md";
}) {
  const dim = size === "xs" ? "h-2.5 w-2.5" : size === "md" ? "h-4 w-4" : "h-3.5 w-3.5";
  return (
    <ChevronRight
      aria-hidden
      className={cn(
        dim,
        "shrink-0 text-muted-foreground",
        motionSafe,
        expanded && "rotate-90",
        className,
      )}
    />
  );
}

export function DisclosureTriangleButton({
  expanded,
  onToggle,
  label,
  ariaLabel,
  className,
  children,
  iconClassName,
  iconSize = "sm",
  disabled,
}: {
  expanded: boolean;
  onToggle: () => void;
  label?: string;
  ariaLabel?: string;
  className?: string;
  children?: React.ReactNode;
  iconClassName?: string;
  iconSize?: "xs" | "sm" | "md";
  disabled?: boolean;
}) {
  const computedLabel = ariaLabel ?? (label ? `${expanded ? "Collapse" : "Expand"} ${label}` : undefined);
  return (
    <button
      type="button"
      disabled={disabled}
      aria-expanded={expanded}
      aria-label={computedLabel}
      onClick={onToggle}
      className={cn(
        "inline-flex shrink-0 items-center justify-center rounded-md text-muted-foreground",
        "hover:bg-muted/80 hover:text-foreground",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-1",
        "disabled:pointer-events-none disabled:opacity-40",
        children ? "gap-1.5 px-1 py-1 text-left" : "size-7",
        className,
      )}
    >
      <DisclosureTriangleIcon expanded={expanded} size={iconSize} className={iconClassName} />
      {children ?? (label ? <span className="truncate text-sm text-foreground">{label}</span> : null)}
    </button>
  );
}

/**
 * Apple HIG disclosure button: chevron points down when content is hidden, up when visible.
 * Place beside the control whose extra options it reveals.
 */
export function DisclosureButtonIcon({
  expanded,
  className,
  size = "sm",
}: {
  expanded: boolean;
  className?: string;
  size?: "sm" | "md";
}) {
  const dim = size === "md" ? "h-4 w-4" : "h-3.5 w-3.5";
  const Icon = expanded ? ChevronUp : ChevronDown;
  return <Icon aria-hidden className={cn(dim, "shrink-0 text-muted-foreground", motionSafe, className)} />;
}

/** Collapsible section with leading disclosure triangle on the trigger (SwiftUI DisclosureGroup-style). */
export function DisclosureGroup({
  className,
  ...props
}: React.ComponentProps<typeof CollapsiblePrimitive.Root>) {
  return (
    <CollapsiblePrimitive.Root
      data-slot="disclosure-group"
      className={cn("group/disclosure flex flex-col", className)}
      {...props}
    />
  );
}

export const DisclosureGroupTrigger = React.forwardRef<
  React.ElementRef<typeof CollapsiblePrimitive.CollapsibleTrigger>,
  React.ComponentPropsWithoutRef<typeof CollapsiblePrimitive.CollapsibleTrigger> & {
    hideChevron?: boolean;
  }
>(({ className, children, hideChevron, ...props }, ref) => (
  <CollapsiblePrimitive.CollapsibleTrigger
    ref={ref}
    data-slot="disclosure-group-trigger"
    className={cn(
      "flex w-full items-center gap-2 rounded-lg px-2 py-2.5 text-left text-sm font-medium text-foreground",
      "outline-none select-none hover:bg-muted/50",
      "focus-visible:ring-2 focus-visible:ring-ring/60",
      "disabled:opacity-40",
      "data-[state=open]:[&_.disclosure-triangle]:rotate-90",
      className,
    )}
    {...props}
  >
    {!hideChevron ? (
      <ChevronRight
        aria-hidden
        className={cn("disclosure-triangle h-3.5 w-3.5 shrink-0 text-muted-foreground", motionSafe)}
      />
    ) : null}
    <span className="min-w-0 flex-1">{children}</span>
  </CollapsiblePrimitive.CollapsibleTrigger>
));
DisclosureGroupTrigger.displayName = "DisclosureGroupTrigger";

export const DisclosureGroupContent = React.forwardRef<
  React.ElementRef<typeof CollapsiblePrimitive.CollapsibleContent>,
  React.ComponentPropsWithoutRef<typeof CollapsiblePrimitive.CollapsibleContent>
>(({ className, children, ...props }, ref) => (
  <CollapsiblePrimitive.CollapsibleContent
    ref={ref}
    data-slot="disclosure-group-content"
    className={cn(
      "overflow-hidden text-sm text-muted-foreground",
      "data-[state=closed]:animate-accordion-up data-[state=open]:animate-accordion-down",
      "motion-reduce:animate-none",
      className,
    )}
    {...props}
  >
    <div className="pb-3 pl-6 pt-1">{children}</div>
  </CollapsiblePrimitive.CollapsibleContent>
));
DisclosureGroupContent.displayName = "DisclosureGroupContent";