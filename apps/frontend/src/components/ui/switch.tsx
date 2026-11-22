import * as React from "react";
import * as SwitchPrimitives from "@radix-ui/react-switch";

import { cn } from "@/lib/utils";

/**
 * Apple-style switch. On is system green (#34C759 light, #30D158 dark).
 * Off is the iOS track gray. The knob slides and widens slightly while pressed.
 */
const Switch = React.forwardRef<
  React.ElementRef<typeof SwitchPrimitives.Root>,
  React.ComponentPropsWithoutRef<typeof SwitchPrimitives.Root>
>(({ className, ...props }, ref) => (
  <SwitchPrimitives.Root
    className={cn(
      "group relative inline-flex h-[31px] w-[51px] shrink-0 cursor-pointer items-center rounded-full p-[2px]",
      "transition-colors duration-200 ease-out",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--switch-on)]/45 focus-visible:ring-offset-2 focus-visible:ring-offset-background",
      "disabled:cursor-not-allowed disabled:opacity-40",
      "data-[state=checked]:bg-[var(--switch-on)] data-[state=unchecked]:bg-[var(--switch-off)]",
      className,
    )}
    {...props}
    ref={ref}
  >
    <SwitchPrimitives.Thumb
      className={cn(
        "pointer-events-none block h-[27px] w-[27px] rounded-full bg-white",
        "shadow-[0_3px_8px_rgba(0,0,0,0.15),0_1px_1px_rgba(0,0,0,0.16)]",
        "transition-[transform,width] duration-[250ms] ease-[cubic-bezier(0.2,0.85,0.3,1.1)]",
        "group-active:w-[32px]",
        "data-[state=unchecked]:translate-x-0",
        "data-[state=checked]:translate-x-[20px] group-active:data-[state=checked]:translate-x-[15px]",
      )}
    />
  </SwitchPrimitives.Root>
));
Switch.displayName = SwitchPrimitives.Root.displayName;

export { Switch };
