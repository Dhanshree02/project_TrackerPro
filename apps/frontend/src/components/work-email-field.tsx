import { ChevronDown } from "lucide-react";
import { cn } from "@/lib/utils";
import { FORM_ERROR_CLS, FORM_LABEL_CLS } from "@/components/form-row";
import type { ApiMetaOption } from "@/lib/api/employees";

interface WorkEmailFieldProps {
  label?: string;
  required?: boolean;
  prefix: string;
  domain: string;
  domainOptions: ApiMetaOption[];
  onPrefixChange: (prefix: string) => void;
  onDomainChange: (domain: string) => void;
  onPrefixBlur?: () => void;
  error?: string;
  id?: string;
  className?: string;
  prefixPlaceholder?: string;
  prefixMaxLength?: number;
  prefixInputProps?: Omit<
    React.InputHTMLAttributes<HTMLInputElement>,
    "value" | "onChange" | "onBlur" | "id" | "className"
  >;
}

/** Work email: username + `@domain` picker in one control. */
export function WorkEmailField({
  label = "Work Email",
  required,
  prefix,
  domain,
  domainOptions,
  onPrefixChange,
  onDomainChange,
  onPrefixBlur,
  error,
  id,
  className,
  prefixPlaceholder = "john.doe",
  prefixMaxLength = 64,
  prefixInputProps,
}: WorkEmailFieldProps) {
  const fullEmail = prefix && domain ? `${prefix}@${domain}` : prefix;

  return (
    <div className={cn("md:col-span-2 lg:col-span-2", className)}>
      <label className="block">
        <span className={FORM_LABEL_CLS}>
          {label}
          {required ? <span className="text-destructive"> *</span> : null}
        </span>
        <div
          className={cn(
            "grid h-9 grid-cols-[3fr_2fr] overflow-hidden rounded-md border border-input bg-card transition-colors",
            "focus-within:ring-2 focus-within:ring-ring",
            error && "border-destructive focus-within:ring-destructive/30",
          )}
        >
          <input
            id={id}
            type="text"
            inputMode="text"
            placeholder={prefixPlaceholder}
            autoComplete="off"
            autoCorrect="off"
            autoCapitalize="off"
            spellCheck={false}
            maxLength={prefixMaxLength}
            value={prefix}
            title={fullEmail || undefined}
            onChange={(e) => onPrefixChange(e.target.value)}
            onBlur={onPrefixBlur}
            className="h-full min-w-0 border-0 bg-transparent px-3 text-sm text-foreground outline-none placeholder:text-muted-foreground focus-visible:ring-0"
            aria-label="Email username"
            aria-invalid={Boolean(error)}
            {...prefixInputProps}
          />
          <div className="relative border-l border-input">
            <select
              value={domain}
              onChange={(e) => onDomainChange(e.target.value)}
              className="h-full w-full appearance-none border-0 bg-muted/70 pl-2.5 pr-8 text-sm font-semibold text-foreground outline-none transition-colors hover:bg-muted focus-visible:ring-0 cursor-pointer"
              aria-label="Email domain"
            >
              {domainOptions.length === 0 ? (
                <option value="" disabled>
                  Loading…
                </option>
              ) : (
                domainOptions.map((opt) => {
                  const domainVal = opt.code.replace(/^@/, "");
                  return (
                    <option key={opt.id || opt.code} value={domainVal}>
                      {opt.name.startsWith("@") ? opt.name : `@${opt.name}`}
                    </option>
                  );
                })
              )}
            </select>
            <ChevronDown className="pointer-events-none absolute right-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
          </div>
        </div>
        {error ? <p className={FORM_ERROR_CLS}>{error}</p> : null}
      </label>
    </div>
  );
}
