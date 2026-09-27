import { useEffect, useState } from "react";
import { cn } from "@/lib/utils";

/** Quiet hours cell: no spinner, blank when zero, accepts one decimal. */
export function HourField({
  value,
  onChange,
  label,
}: {
  value: number;
  onChange: (hours: number) => void;
  label: string;
}) {
  const [text, setText] = useState(value === 0 ? "" : String(value));

  useEffect(() => {
    const parsed = text === "" || text === "." ? 0 : Number(text);
    if (parsed !== value) setText(value === 0 ? "" : String(value));
  }, [value, text]);

  return (
    <input
      type="text"
      inputMode="decimal"
      aria-label={label}
      value={text}
      placeholder="0"
      onChange={(event) => {
        const raw = event.target.value;
        if (raw !== "" && !/^\d{0,2}(\.\d?)?$/.test(raw)) return;
        setText(raw);
        const numeric = raw === "" || raw === "." || raw.endsWith(".") ? Number.parseFloat(raw) : Number(raw);
        const next = Number.isFinite(numeric) ? Math.max(0, Math.min(24, numeric)) : 0;
        onChange(next);
      }}
      className={cn(
        "h-8 w-11 rounded-md bg-muted/40 text-center text-sm tabular-nums text-foreground outline-none",
        "placeholder:text-muted-foreground/35",
        "focus:bg-background focus:ring-2 focus:ring-primary/25",
      )}
    />
  );
}
