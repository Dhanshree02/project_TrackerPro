import React from "react";
import { ChevronDown } from "lucide-react";
import { cn } from "@/lib/utils";

/** Shared label + control look for onboard / create forms. */
export const FORM_LABEL_CLS = "mb-1 block text-xs font-medium text-muted-foreground";
export const FORM_ERROR_CLS = "mt-1 text-[11px] text-destructive";
export const FORM_CONTROL_CLS =
  "h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none transition-colors placeholder:text-muted-foreground focus-visible:ring-2 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-60";

export interface FieldProps {
  label: string;
  required?: boolean;
  children?: React.ReactNode;
  value?: React.ReactNode;
  className?: string;
  error?: string;
}

export function Field({ label, required, children, value, className, error }: FieldProps) {
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
      <span className={FORM_LABEL_CLS}>
        {label}{required && <span className="text-destructive"> *</span>}
      </span>
      {children}
      {error ? <p className={FORM_ERROR_CLS}>{error}</p> : null}
    </label>
  );
}

export function FormRow({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <label className="block">
      <span className={FORM_LABEL_CLS}>{label}</span>
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

export interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  containerClassName?: string;
}

export const Select = React.forwardRef<HTMLSelectElement, SelectProps>(
  ({ className, containerClassName, children, ...props }, ref) => {
    return (
      <div className={cn("relative flex w-full items-center", containerClassName)}>
        <select
          ref={ref}
          autoComplete="off"
          className={cn(FORM_CONTROL_CLS, "cursor-pointer appearance-none pr-8", className)}
          {...props}
        >
          {children}
        </select>
        <ChevronDown className="pointer-events-none absolute right-2.5 top-1/2 h-3.5 w-3.5 shrink-0 -translate-y-1/2 text-muted-foreground" />
      </div>
    );
  },
);
Select.displayName = "Select";
