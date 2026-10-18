import { allClients, allProjects } from "@/lib/workspace-store";
import type { Client, Project } from "@/lib/domain-models";
import { fetchClients, mapApiClient } from "@/modules/customers/api/clients";
import {
  fetchProject,
  fetchProjectInvoices,
  fetchProjectServices,
  mapApiProjectToProject,
} from "@/modules/projects/api/projects";

export async function loadProjectDetail(projectId: string): Promise<{ project?: Project; client?: Client }> {
  const rawId = projectId ? decodeURIComponent(projectId).trim() : "";

  let project: Project | undefined;

  if (rawId) {
    try {
      const apiProj = await fetchProject(rawId);
      if (apiProj) {
        let apiServices: unknown[] = [];
        let apiInvoices: unknown[] = [];
        try {
          apiServices = await fetchProjectServices(apiProj.id);
        } catch (svcErr) {
          console.warn("Could not fetch project services from backend", svcErr);
        }
        try {
          apiInvoices = await fetchProjectInvoices(apiProj.id);
        } catch (invErr) {
          console.warn("Could not fetch project invoices from backend", invErr);
        }
        project = mapApiProjectToProject(apiProj, apiServices, apiInvoices);
      }
    } catch (err) {
      console.warn("Could not fetch project from backend", err);
    }
  }

  if (!project) {
    project = allProjects().find(
      (p) =>
        p.id === rawId ||
        p.id.toLowerCase() === rawId.toLowerCase() ||
        p.wbsId === rawId ||
        p.projectSeqId?.toLowerCase() === rawId.toLowerCase(),
    );
  }

  let client: Client | undefined;
  if (project?.clientId) {
    try {
      const dbClients = await fetchClients(1, 200);
      const matched = dbClients.find((c) => c.id === project!.clientId);
      if (matched) client = mapApiClient(matched);
    } catch {
      // fallback below
    }
    if (!client) {
      client = allClients().find((c) => c.id === project!.clientId);
    }
  }

  return { project, client };
}
