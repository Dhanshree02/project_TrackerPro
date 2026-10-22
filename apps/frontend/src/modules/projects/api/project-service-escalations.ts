import { apiFetch } from "@/lib/api-client";

export interface ServiceEscalationStakeholder {
  employeeId: string;
  name: string;
  employeeCode?: string | null;
  subDepartment: string;
  status: string;
}

export interface ProjectServiceEscalation {
  id: string;
  projectId: string;
  projectServiceId?: string | null;
  projectCode?: string | null;
  projectName: string;
  customerName?: string | null;
  serviceName: string;
  escalationType: string;
  priority: string;
  subject: string;
  description: string;
  expectedResolutionDate?: string | null;
  attachmentFileName?: string | null;
  attachmentPath?: string | null;
  status: string;
  raisedByName: string;
  createdAtUtc: string;
  stakeholders: ServiceEscalationStakeholder[];
}

export async function fetchServiceEscalationStakeholders(): Promise<ServiceEscalationStakeholder[]> {
  const res = await apiFetch<ServiceEscalationStakeholder[]>("/api/v1/projects/service-escalation-stakeholders");
  return res ?? [];
}

export async function fetchProjectServiceEscalations(projectId: string): Promise<ProjectServiceEscalation[]> {
  const res = await apiFetch<ProjectServiceEscalation[]>(`/api/v1/projects/${projectId}/service-escalations`);
  return res ?? [];
}

export async function createProjectServiceEscalation(projectId: string, form: FormData): Promise<ProjectServiceEscalation> {
  return apiFetch<ProjectServiceEscalation>(`/api/v1/projects/${projectId}/service-escalations`, {
    method: "POST",
    body: form,
  });
}
