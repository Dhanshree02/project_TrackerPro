import React from "react";
import { cn } from "@/lib/utils";

export interface FieldProps {
  label: string;
  required?: boolean;
  children?: React.ReactNode;
  value?: React.ReactNode;
  className?: string;
}

export function Field({ label, required, children, value, className }: FieldProps) {
  if (value !== undefined && children === undefined) {
    return (
      <div className={cn("block", className)}>
        <span className="text-[10px] uppercase font-bold text-muted-foreground block">{label}</span>
        <span className="text-sm font-semibold text-foreground mt-0.5 block">{value}</span>
      </div>
    );
  }

  return (
    <label className={cn("block", className)}>
      <span className="mb-1 block text-xs font-medium text-muted-foreground">
        {label}{required && <span className="text-destructive"> *</span>}
      </span>
      {children}
    </label>
  );
}

export function FormRow({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <label className="block">
      <span className="mb-1 block text-xs font-medium text-muted-foreground">{label}</span>
      {children}
    </label>
  );
}

export function HorizontalField({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between text-sm">
      <span className="text-muted-foreground">{label}</span>
      <span className="font-medium">{children}</span>
    </div>
  );
}

import { ChevronDown } from "lucide-react";

export interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  containerClassName?: string;
}

export const Select = React.forwardRef<HTMLSelectElement, SelectProps>(
  ({ className, containerClassName, children, ...props }, ref) => {
    return (
      <div className={cn("relative flex items-center w-full", containerClassName)}>
        <select
          ref={ref}
          className={cn(
            "h-9 w-full appearance-none rounded-md border border-input bg-card pl-3 pr-8 text-xs font-medium text-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring cursor-pointer hover:bg-accent/40 transition-colors",
            className
          )}
          {...props}
        >
          {children}
        </select>
        <ChevronDown className="pointer-events-none absolute right-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground shrink-0" />
      </div>
    );
  }
);
Select.displayName = "Select";
