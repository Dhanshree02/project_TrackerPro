import type { OrgCategory } from "@/modules/my-org/types";

// ─── Seed Categories ──────────────────────────────────────────────────────────
// iconName must match a key in ICON_MAP inside CategoryCard.tsx
// accentColor must be a valid AccentColor

export const seedCategories: OrgCategory[] = [
  {
    id: "tech-sops",
    name: "Tech. SOPs",
    description: "Technical Standard Operating Procedures for engineering and infrastructure.",
    iconName: "Code2",
    accentColor: "blue",
  },
  {
    id: "pms-sops",
    name: "PMS. SOPs",
    description: "Project Management System Standard Operating Procedures.",
    iconName: "ClipboardList",
    accentColor: "purple",
  },
  {
    id: "policy-docs",
    name: "IMP Templates",
    description: "Important templates, company-wide policies, guidelines, and compliance documents.",
    iconName: "FileText",
    accentColor: "green",
  },
  {
    id: "help-desk",
    name: "Help Desk",
    description: "Help desk resources, FAQs, and support guides for employees.",
    iconName: "Headphones",
    accentColor: "amber",
  },
];
