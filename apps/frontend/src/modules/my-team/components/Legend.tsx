// ─── My Team — Legend ────────────────────────────────────────────────────────

import { shiftChipClass } from "../constants";

interface LegendProps {
  color: string;
  text: string;
}

/** Full-size coloured circle legend item used for attendance types. */
export function Legend({ color, text }: LegendProps) {
  return (
    <div className="flex items-center gap-[7px] whitespace-nowrap">
      <span
        className="h-[11px] w-[11px] rounded-full"
        style={{ backgroundColor: color }}
      />
      <span>{text}</span>
    </div>
  );
}

interface SmallDotProps {
  color: string;
  text: string;
}

/** Tiny dot used for day-header indicator legend items. */
export function SmallDot({ color, text }: SmallDotProps) {
  return (
    <div className="flex items-center gap-[7px] whitespace-nowrap">
      <span
        className="h-[3px] w-[3px] rounded-full"
        style={{ backgroundColor: color }}
      />
      <span>{text}</span>
    </div>
  );
}

interface ShiftChipLegendProps {
  chip: string;
  text: string;
}

/** Compact letter chip used for shift types. */
export function ShiftChipLegend({ chip, text }: ShiftChipLegendProps) {
  return (
    <div className="flex items-center gap-[7px] whitespace-nowrap">
      <span className={shiftChipClass}>
        {chip}
      </span>
      <span>{text}</span>
    </div>
  );
}
