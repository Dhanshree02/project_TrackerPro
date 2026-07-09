import { Upload } from "lucide-react";

interface UploadDocumentButtonProps {
  onClick: () => void;
}

export function UploadDocumentButton({ onClick }: UploadDocumentButtonProps) {
  return (
    <button
      onClick={onClick}
      className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground shadow-sm transition-all hover:bg-primary/90"
    >
      <Upload className="h-4 w-4" />
      Upload Document
    </button>
  );
}
