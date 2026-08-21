import { CheckCircle2, CircleAlert } from "lucide-react";
import { Toaster as Sonner } from "sonner";

type ToasterProps = React.ComponentProps<typeof Sonner>;

const Toaster = ({ ...props }: ToasterProps) => {
  return (
    <Sonner
      position="top-right"
      offset={16}
      visibleToasts={4}
      className="toaster group"
      icons={{
        success: <CheckCircle2 className="h-5 w-5 shrink-0" strokeWidth={2.5} />,
        error: <CircleAlert className="h-5 w-5 shrink-0" strokeWidth={2.5} />,
      }}
      toastOptions={{
        duration: 4000,
        classNames: {
          toast: "group toast group-[.toaster]:shadow-lg group-[.toaster]:border",
          title: "text-sm font-medium",
          description: "text-sm opacity-90",
          success:
            "!bg-green-600 !text-white !border-green-700 [&_[data-icon]]:!text-white",
          error: "!bg-red-600 !text-white !border-red-700 [&_[data-icon]]:!text-white",
          warning: "!bg-amber-500 !text-white !border-amber-600",
          info: "group-[.toaster]:bg-background group-[.toaster]:text-foreground group-[.toaster]:border-border",
          default:
            "group-[.toaster]:bg-background group-[.toaster]:text-foreground group-[.toaster]:border-border",
          actionButton: "group-[.toast]:bg-primary group-[.toast]:text-primary-foreground",
          cancelButton: "group-[.toast]:bg-muted group-[.toast]:text-muted-foreground",
          icon: "size-5",
        },
      }}
      {...props}
    />
  );
};

export { Toaster };
