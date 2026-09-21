import { Users, Info, ShieldAlert, Sparkles } from "lucide-react";
import { Badge } from "@/components/ui/badge";

export function ResourceMastersSection() {
  return (
    <div className="rounded-xl border border-border bg-card p-8 shadow-sm text-center">
      <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/10 text-primary mb-4">
        <Users className="h-7 w-7" />
      </div>

      <h2 className="text-base font-semibold text-foreground">Resource Masters</h2>
      <p className="mt-1.5 text-xs text-muted-foreground max-w-md mx-auto">
        No resource masters configured yet.
      </p>

      <div className="mt-6 mx-auto max-w-lg rounded-lg border border-dashed border-border/80 bg-muted/20 p-4 text-left">
        <div className="flex items-start gap-3">
          <Info className="h-4 w-4 text-primary shrink-0 mt-0.5" />
          <div className="text-xs text-muted-foreground leading-relaxed">
            <span className="font-medium text-foreground">Extensible Master Container:</span> Resource master schemas and attribute mappings are currently under architectural discussion. When finalized, new resource masters (such as band grades, skill taxonomies, or billing tiers) can be plugged into this container without modifying other master sections.
          </div>
        </div>
      </div>
    </div>
  );
}
