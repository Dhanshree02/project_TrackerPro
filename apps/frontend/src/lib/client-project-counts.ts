import type { Project } from "@/lib/mock-data";

/** Mutually exclusive project buckets for a customer. Total = sum of the five. */
export type ClientProjectBuckets = {
  new: Project[];
  ongoing: Project[];
  completed: Project[];
  onHold: Project[];
  archived: Project[];
  atRisk: Project[];
  total: number;
};

/**
 * New = not started yet (ongoing + 0% progress)
 * Ongoing = in delivery (ongoing + progress > 0)
 * Completed = delivered to the client
 * On Hold = paused
 * Archived = payment received / fully closed
 */
export function categorizeClientProjects(projects: Project[]): ClientProjectBuckets {
  const newProjs = projects.filter((p) => p.status === "ongoing" && p.progress === 0);
  const ongoing = projects.filter((p) => p.status === "ongoing" && p.progress > 0);
  const completed = projects.filter((p) => p.status === "completed");
  const onHold = projects.filter((p) => p.status === "on_hold");
  const archived = projects.filter((p) => p.status === "archived");
  const atRisk = projects.filter(
    (p) => p.status === "ongoing" && (p.health === "red" || p.health === "amber"),
  );

  return {
    new: newProjs,
    ongoing,
    completed,
    onHold,
    archived,
    atRisk,
    total: newProjs.length + ongoing.length + completed.length + onHold.length + archived.length,
  };
}
