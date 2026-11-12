# Changelog - Issue Resolution SLA Escalation Alert Request & Multi-Party Communication

## Summary of Changes
Extended the Issue Resolution SLA escalation workflow in Hangfire and Action Centre so that when Level 1 and Level 2 escalations trigger, recipients do not merely receive notification cards—they are assigned full Alert requests in their Action Centre Alerts tab. This grants Assigned Senior Project Managers (Level 1) and Heads of Department (Level 2) direct visibility into all previous conversation history from initial project leadership (Project Team Leader, Assigned Project Manager, Assigned Engagement Manager), the ability to communicate directly via the discussion thread, and permission to update governance/status (e.g., In Progress, Resolved, Closed).

---

## Affected Files
- `apps/backend/Modules/Sla/Jobs/SlaBackgroundJobWorker.cs`:
  - Updated `ExecuteIssueEscalationAsync` to resolve recipients and deliver Alert requests directly into `ProjectAlert.AudienceUserIds` and `ProjectAlert.EscalatedTo`.
  - Appends audit trail entries to `ProjectAlert.HistoryJson` with exact role attribution (`Assigned Senior Project Manager`, `Head of Department`).
  - Sets `Priority = "Critical"`, synchronizes `ChatJson` between `ProjectAlert` and `ProjectServiceEscalation`, and registers recipients in `tbl_project_service_escalation_stakeholders`.
  - Populates notification `HistoryJson` so Action Centre notification modals reflect full history.
- `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`:
  - Added fallback module code `"action-centre"` to `[RequireRbac]` attribute for alert endpoints (`GetAlerts`, `UpdateAlertGovernance`, `DownloadAlertAttachment`) ensuring all authenticated and assigned stakeholders can access alert actions.
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`:
  - Enhanced `UpdateAlertGovernanceAsync` with fine-grained authorization checks allowing assigned alert audience members, project leadership, and escalation stakeholders to participate in chat and change status.
- `apps/backend/Modules/Projects/DTOs/ProjectIssueDtos.cs`:
  - Updated `UpdateAlertStatusRequest` record to accept an optional `Comment` string.
- `apps/backend/Modules/Projects/Services/IProjectIssueService.cs` & `ProjectIssueService.cs`:
  - Updated `UpdateAlertStatusAsync` to accept optional comments, append them to `alert.ChatJson`, record them in `alert.HistoryJson`, and sync to `ProjectServiceEscalation.ChatJson`.
- `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`:
  - Passed `request.Comment` through to `projectIssueService.UpdateAlertStatusAsync`.
- `apps/backend/tests/PMS.IntegrationTests/IssueResolutionSlaIntegrationTests.cs`:
  - Added comprehensive end-to-end integration test `IssueResolution_Level1AndLevel2Escalation_AssignsAlertRequestAndChatAccess` verifying issue creation, initial alert audience, Level 1 escalation assignment to Assigned Senior Project Manager with chat communication, Level 2 escalation assignment to Head of Department with complete message history visibility, status transition to Resolved, and SLA instance completion.
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
  - Updated `canActOnAlert` to evaluate `isAlertAudience`, granting assigned alert audience members access to the Actions column, Review details modal, discussion thread chat, and status updates.

---

## Database Changes and Migrations
- **No schema migrations required**:
  - Leveraged existing JSON fields (`AudienceUserIds`, `EscalatedTo`, `ChatJson`, `HistoryJson`) on `project.tbl_project_alerts`.
  - Leveraged `project.tbl_project_service_escalation_stakeholders` table to store relational stakeholder entries for escalated employees.

---

## API Changes
- `PATCH /api/v1/projects/{projectId}/issues/{issueId}/alerts/{alertId}/status`:
  - Request body: `{ "status": string, "comment": string? }`
- `PATCH /api/v1/action-centre/alerts/{alertId}/governance`:
  - Authorized for all assigned audience members and stakeholders.
  - Allows concurrent status transitions and commentary.

---

## Business Logic
1. **Initial Issue Creation**:
   - Alert request and immediate notifications are delivered to Assigned Engagement Manager, Assigned Project Manager, and Project Team Leader.
   - SLA tracking begins with Scheduled breach check and Level 1 escalation events.
2. **Level 1 Escalation (Breach Execution)**:
   - Target role: `Assigned Senior Project Manager`.
   - Notification dispatched: Critical Level 1 SLA Escalation notification.
   - Alert request assigned: Senior Project Manager employee ID appended to `ProjectAlert.AudienceUserIds` and name to `ProjectAlert.EscalatedTo`.
   - Access: Assigned Senior Project Manager views the Alert in Action Centre Alerts tab, reads prior chat, participates in discussion thread, and can change status.
   - Scheduling: Schedules Level 2 escalation for the end of the next working day (6:00 PM IST) taking into account holidays and weekends.
3. **Level 2 Escalation (Follow-up Breach Execution)**:
   - Target role: `Head of Department`.
   - Notification dispatched: Critical Level 2 SLA Escalation notification.
   - Alert request assigned: Head of Department employee ID appended to `ProjectAlert.AudienceUserIds` and name to `ProjectAlert.EscalatedTo`.
   - Access: Head of Department views the Alert in Action Centre Alerts tab, reads all past communications from Project Team Leader, Assigned Project Manager, Assigned Engagement Manager, and Assigned Senior Project Manager, participates in discussion thread, and can change status.
4. **Resolution**:
   - Once marked "Resolved" or "Closed" by any authorized party, `slaTrackingService.CompleteTrackingAsync` completes the SLA instance and cancels pending Hangfire jobs.

---

## Preserved Functionality
- Task Start After Assigning SLA calculation, reminders, and escalations.
- Task Pause SLA reminders and notifications.
- Task Deadline SLA reminders and escalations.
- Exact role nomenclature enforcement (`Assigned Project Manager`, `Assigned Engagement Manager`, `Project Team Leader`, `Assigned Senior Project Manager`, `Head of Department`).
