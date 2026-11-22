import { CheckCircle2, CircleAlert } from "lucide-react";
import { Toaster as Sonner } from "sonner";

type ToasterProps = React.ComponentProps<typeof Sonner>;

const Toaster = ({ ...props }: ToasterProps) => {
  return (
    <Sonner
      position="top-right"
      offset={20}
      gap={10}
      visibleToasts={4}
      className="toaster group"
      icons={{
        success: <CheckCircle2 className="h-5 w-5 shrink-0" strokeWidth={2.25} />,
        error: <CircleAlert className="h-5 w-5 shrink-0" strokeWidth={2.25} />,
      }}
      toastOptions={{
        duration: 3000,
        classNames: {
          toast:
            "group toast !rounded-[20px] !border !border-border/70 !bg-card !text-foreground !shadow-[0_10px_30px_rgba(0,0,0,0.12),0_2px_8px_rgba(0,0,0,0.06)] !px-4 !py-3.5",
          title: "!text-[15px] !font-semibold !tracking-[-0.016em] !text-foreground",
          description: "!text-[13px] !font-normal !leading-snug !text-muted-foreground",
          success:
            "!bg-success !text-success-foreground !border-success [&_[data-icon]]:!text-success-foreground [&_[data-title]]:!text-success-foreground [&_[data-description]]:!text-success-foreground",
          error:
            "!bg-destructive !text-destructive-foreground !border-destructive [&_[data-icon]]:!text-destructive-foreground [&_[data-title]]:!text-destructive-foreground [&_[data-description]]:!text-destructive-foreground",
          warning:
            "!bg-warning !text-warning-foreground !border-warning [&_[data-icon]]:!text-warning-foreground [&_[data-title]]:!text-warning-foreground [&_[data-description]]:!text-warning-foreground",
          info: "!bg-card !text-foreground !border-border/70 [&_[data-icon]]:!text-primary",
          default: "!bg-card !text-foreground !border-border/70",
          actionButton: "!rounded-full !bg-primary !px-3 !text-primary-foreground",
          cancelButton: "!rounded-full !bg-muted !text-muted-foreground",
          icon: "!size-5",
        },
      }}
      {...props}
    />
  );
};

export { Toaster };
