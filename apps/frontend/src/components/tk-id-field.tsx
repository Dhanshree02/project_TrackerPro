import { ChevronDown } from "lucide-react";
import { cn } from "@/lib/utils";
import { FORM_CONTROL_CLS, FORM_ERROR_CLS, FORM_LABEL_CLS } from "@/components/form-row";
import { TK_ID_DIGITS, TK_ID_PREFIXES, type TkIdPrefix } from "@/lib/form-validation";

interface TkIdFieldProps {
  label?: string;
  required?: boolean;
  prefix: TkIdPrefix;
  digits: string;
  onChange: (prefix: TkIdPrefix, digits: string) => void;
  onBlur?: () => void;
  error?: string;
  disabled?: boolean;
  className?: string;
  /** Extra classes for the numeric input (edit form passes its own control look). */
  inputClassName?: string;
}

/** TK ID control: `[TK | TKI]` dropdown + 4-digit number box, producing `TK-0001` / `TKI-0001`. */
export function TkIdField({
  label = "TK ID",
  required,
  prefix,
  digits,
  onChange,
  onBlur,
  error,
  disabled,
  className,
  inputClassName,
}: TkIdFieldProps) {
  return (
    <div className={className}>
      <label className="block">
        <span className={FORM_LABEL_CLS}>
          {label}
          {required ? <span className="text-destructive"> *</span> : null}
        </span>
        <div className="relative flex rounded-md">
          <div className="relative shrink-0">
            <select
              value={prefix}
              disabled={disabled}
              onChange={(e) => onChange(e.target.value as TkIdPrefix, digits)}
              className={cn(
                "h-9 appearance-none rounded-l-md border border-input bg-muted/70 pl-3 pr-8 text-xs font-semibold text-foreground outline-none transition-colors hover:bg-muted focus-visible:border-primary focus-visible:ring-2 focus-visible:ring-ring",
                disabled ? "cursor-not-allowed opacity-60" : "cursor-pointer",
                error && "border-destructive",
              )}
              aria-label="TK ID prefix"
            >
              {TK_ID_PREFIXES.map((p) => (
                <option key={p} value={p}>
                  {p}
                </option>
              ))}
            </select>
            <ChevronDown className="pointer-events-none absolute right-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
          </div>
          <span
            className={cn(
              "flex h-9 items-center border-y border-input bg-muted/40 px-1.5 text-sm text-muted-foreground",
              error && "border-destructive",
            )}
            aria-hidden
          >
            -
          </span>
          <input
            type="text"
            inputMode="numeric"
            autoComplete="off"
            placeholder="0001"
            maxLength={TK_ID_DIGITS}
            disabled={disabled}
            value={digits}
            onChange={(e) => onChange(prefix, e.target.value.replace(/\D/g, "").slice(0, TK_ID_DIGITS))}
            onBlur={onBlur}
            className={cn(
              FORM_CONTROL_CLS,
              "rounded-l-none border-l-0 font-mono tracking-wider",
              inputClassName,
              error && "border-destructive focus-visible:ring-destructive",
            )}
            aria-label="TK ID number"
          />
        </div>
        {error ? <p className={FORM_ERROR_CLS}>{error}</p> : null}
      </label>
    </div>
  );
}
