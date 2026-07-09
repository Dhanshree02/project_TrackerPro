import { UploadDocumentButton } from "./UploadDocumentButton";

interface MyOrgHeaderProps {
  onUploadClick: () => void;
}

export function MyOrgHeader({ onUploadClick }: MyOrgHeaderProps) {
  return (
    <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
      <p className="text-xs text-muted-foreground">
        Manage organizational documents, SOPs, and policy resources.
      </p>
      <UploadDocumentButton onClick={onUploadClick} />
    </div>
  );
}
