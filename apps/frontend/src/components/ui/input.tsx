import * as React from "react";

import { cn } from "@/lib/utils";

const Input = React.forwardRef<HTMLInputElement, React.ComponentProps<"input">>(
  ({ className, type, autoComplete = "off", autoCorrect = "off", spellCheck = false, ...props }, ref) => {
    return (
      <input
        type={type}
        autoComplete={autoComplete}
        autoCorrect={autoCorrect}
        spellCheck={spellCheck}
        className={cn(
          "flex h-9 w-full rounded-md border border-input bg-card px-3 py-1 text-base transition-[border-color,box-shadow] file:border-0 file:bg-transparent file:text-sm file:font-medium file:text-foreground placeholder:text-muted-foreground focus-visible:border-primary focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/25 disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
          className,
        )}
        ref={ref}
        {...props}
      />
    );
  },
);
Input.displayName = "Input";

export { Input };
