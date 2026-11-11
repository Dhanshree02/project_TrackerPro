import { describe, it, expect } from "vitest";
import {
  computeOverallProjectProgress,
  calculateServiceProgressFromTasks,
  isActiveService,
} from "./project-progress";

describe("project-progress", () => {
  describe("computeOverallProjectProgress", () => {
    it("calculates exact user example: 4 services (20%, 40%, 60%, 0%) = 30%", () => {
      const services = [
        { serviceName: "Network Vulnerability Assessment", progress: 20 },
        { serviceName: "Internal Network Penetration Testing", progress: 40 },
        { serviceName: "Thick Client Penetration Testing", progress: 60 },
        { serviceName: "External Network Penetration Testing", progress: 0 },
      ];
      expect(computeOverallProjectProgress(services)).toBe(30);
    });

    it("calculates 3 services: 100%, 50%, 0% = 50%", () => {
      const services = [
        { serviceName: "Service A", progress: 100 },
        { serviceName: "Service B", progress: 50 },
        { serviceName: "Service C", progress: 0 },
      ];
      expect(computeOverallProjectProgress(services)).toBe(50);
    });

    it("calculates 1 service: 75% = 75%", () => {
      const services = [{ serviceName: "Service A", progress: 75 }];
      expect(computeOverallProjectProgress(services)).toBe(75);
    });

    it("calculates all services at 0% = 0%", () => {
      const services = [
        { serviceName: "Service A", progress: 0 },
        { serviceName: "Service B", progress: 0 },
        { serviceName: "Service C", progress: 0 },
      ];
      expect(computeOverallProjectProgress(services)).toBe(0);
    });

    it("returns 0% when there are no active services", () => {
      expect(computeOverallProjectProgress([])).toBe(0);
    });

    it("excludes deleted services from both numerator and denominator", () => {
      const services = [
        { serviceName: "Service A", progress: 20 },
        { serviceName: "Service B", progress: 40 },
        // Deleted variants:
        { serviceName: "Service C", progress: 100, isDeleted: true },
        { serviceName: "Service D", progress: 90, changeStatus: "Deleted" },
        { serviceName: "Service E", progress: 80, deletedAtUtc: "2026-11-10T00:00:00Z" },
      ];
      // Only Service A (20) and Service B (40) are active -> (20 + 40) / 2 = 30%
      expect(computeOverallProjectProgress(services)).toBe(30);
    });

    it("excludes inactive services from both numerator and denominator", () => {
      const services = [
        { serviceName: "Service A", progress: 30 },
        { serviceName: "Service B", progress: 50 },
        { serviceName: "Service C", progress: 100, status: "Inactive" },
      ];
      // Only Service A (30) and Service B (50) -> (30 + 50) / 2 = 40%
      expect(computeOverallProjectProgress(services)).toBe(40);
    });

    it("rounds to the nearest whole percentage using Math.round", () => {
      const services = [
        { serviceName: "Service A", progress: 25 },
        { serviceName: "Service B", progress: 40 },
      ];
      // (25 + 40) / 2 = 32.5 -> 33%
      expect(computeOverallProjectProgress(services)).toBe(33);
    });

    it("ensures every active service carries equal weight regardless of hours or task count", () => {
      // Service A has 100 tasks and 1000 hours, at 20%
      // Service B has 1 task and 2 hours, at 80%
      // Equal weight arithmetic average = (20 + 80) / 2 = 50%
      const services = [
        { serviceName: "Large Service", progress: 20 },
        { serviceName: "Small Service", progress: 80 },
      ];
      expect(computeOverallProjectProgress(services)).toBe(50);
    });
  });

  describe("calculateServiceProgressFromTasks", () => {
    it("weights Completed as 1.0, Ongoing as 0.5, and Not Started as 0.0", () => {
      const tasks = [
        { stage: "Completed" }, // +1
        { stage: "Ongoing" },   // +0.5
        { stage: "Not Started" }, // +0
        { stage: "Stopped" },     // +0
      ];
      // 1.5 / 4 = 37.5% -> 38%
      const res = calculateServiceProgressFromTasks(tasks);
      expect(res.progress).toBe(38);
      expect(res.totalTasks).toBe(4);
      expect(res.completedTasks).toBe(1);
      expect(res.ongoingTasks).toBe(1);
    });

    it("excludes Cancelled tasks completely from total count and sum", () => {
      const tasks = [
        { stage: "Completed" }, // +1
        { stage: "Cancelled" }, // excluded
        { stage: "Cancelled" }, // excluded
      ];
      // 1 / 1 = 100%
      const res = calculateServiceProgressFromTasks(tasks);
      expect(res.progress).toBe(100);
      expect(res.totalTasks).toBe(1);
      expect(res.completedTasks).toBe(1);
      expect(res.ongoingTasks).toBe(0);
    });

    it("returns 0% if all tasks are cancelled or list is empty", () => {
      expect(calculateServiceProgressFromTasks([]).progress).toBe(0);
      expect(calculateServiceProgressFromTasks([{ stage: "Cancelled" }]).progress).toBe(0);
    });
  });

  describe("isActiveService", () => {
    it("correctly identifies active vs inactive/deleted services", () => {
      expect(isActiveService({})).toBe(true);
      expect(isActiveService({ status: "Active" })).toBe(true);
      expect(isActiveService({ isDeleted: true })).toBe(false);
      expect(isActiveService({ changeStatus: "Deleted" })).toBe(false);
      expect(isActiveService({ deletedAtUtc: "2026-11-10" })).toBe(false);
      expect(isActiveService({ status: "Inactive" })).toBe(false);
      expect(isActiveService({ status: "inactive" })).toBe(false);
    });
  });
});
