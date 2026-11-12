using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Sla.Models;

namespace PMS.API.Modules.Sla.Services;

public sealed class SlaRecipientResolver(AppDbContext db) : ISlaRecipientResolver
{
    public async Task<IReadOnlyList<Guid>> ResolveRecipientsAsync(
        SlaInstance instance,
        IReadOnlyList<string> targetRoles,
        CancellationToken ct = default)
    {
        if (targetRoles == null || targetRoles.Count == 0)
        {
            return [];
        }

        var recipientIds = new HashSet<Guid>();

        // 1. Resolve Senior Project Manager (L1 Escalation)
        if (ContainsRole(targetRoles, "SeniorProjectManager", "Sr. PM", "SPM", "Assigned Senior Project Manager"))
        {
            var spmIds = await ResolveSeniorProjectManagersAsync(instance, ct);
            foreach (var id in spmIds)
            {
                recipientIds.Add(id);
            }
        }

        // 2. Resolve Head Of Department (L2 Escalation)
        if (ContainsRole(targetRoles, "HeadOfDepartment", "Head Of Department", "HOD"))
        {
            var hodIds = await ResolveHeadOfDepartmentsAsync(instance, ct);
            foreach (var id in hodIds)
            {
                recipientIds.Add(id);
            }
        }

        // 3. Resolve Project Leadership context (PM, TL, EM)
        if (instance.ProjectId.HasValue)
        {
            var proj = await db.Projects
                .AsNoTracking()
                .Include(p => p.Client)
                .Where(p => p.Id == instance.ProjectId.Value && p.DeletedAtUtc == null)
                .Select(p => new
                {
                    p.Id,
                    p.ProjectManagerId,
                    p.TeamLeadId,
                    p.EngagementManagerId,
                    ClientEngagementManagerId = p.Client != null ? p.Client.EngagementManagerId : (Guid?)null
                })
                .FirstOrDefaultAsync(ct);

            if (proj != null)
            {
                if (ContainsRole(targetRoles, "ProjectManager", "PM", "Assigned Project Manager") && proj.ProjectManagerId.HasValue && proj.ProjectManagerId.Value != Guid.Empty)
                {
                    recipientIds.Add(proj.ProjectManagerId.Value);
                }

                if (ContainsRole(targetRoles, "TeamLead", "TL", "TeamLeader", "Team Leader", "Project Team Leader") && proj.TeamLeadId.HasValue && proj.TeamLeadId.Value != Guid.Empty)
                {
                    recipientIds.Add(proj.TeamLeadId.Value);
                }

                if (ContainsRole(targetRoles, "EngagementManager", "EM", "Assigned Engagement Manager"))
                {
                    var emId = proj.EngagementManagerId ?? proj.ClientEngagementManagerId;
                    if (emId.HasValue && emId.Value != Guid.Empty)
                    {
                        recipientIds.Add(emId.Value);
                    }
                }

                // Check team members allocated to this project
                var teamLeadership = await db.ProjectTeamMembers
                    .AsNoTracking()
                    .Include(tm => tm.Employee)
                    .Where(tm => tm.ProjectId == instance.ProjectId.Value && tm.DeletedAtUtc == null)
                    .ToListAsync(ct);

                foreach (var tm in teamLeadership)
                {
                    var memberRole = tm.MemberRole?.Trim() ?? "";
                    var empRole = tm.Employee?.Role?.Trim() ?? "";

                    if (ContainsRole(targetRoles, "ProjectManager", "PM", "Assigned Project Manager") &&
                        (memberRole.Equals("ProjectManager", StringComparison.OrdinalIgnoreCase)
                         || memberRole.Equals("Project Manager", StringComparison.OrdinalIgnoreCase)
                         || memberRole.Equals("PM", StringComparison.OrdinalIgnoreCase)))
                    {
                        recipientIds.Add(tm.EmployeeId);
                    }

                    if (ContainsRole(targetRoles, "EngagementManager", "EM", "Assigned Engagement Manager") &&
                        (memberRole.Equals("EngagementManager", StringComparison.OrdinalIgnoreCase)
                         || memberRole.Equals("Engagement Manager", StringComparison.OrdinalIgnoreCase)
                         || memberRole.Equals("EM", StringComparison.OrdinalIgnoreCase)
                         || empRole.Equals("EngagementManager", StringComparison.OrdinalIgnoreCase)
                         || empRole.Equals("Engagement Manager", StringComparison.OrdinalIgnoreCase)))
                    {
                        recipientIds.Add(tm.EmployeeId);
                    }

                    if (ContainsRole(targetRoles, "TeamLead", "TL", "TeamLeader", "Team Leader", "Project Team Leader") &&
                        (tm.IsTeamLead
                         || memberRole.Equals("TeamLead", StringComparison.OrdinalIgnoreCase)
                         || memberRole.Equals("Team Leader", StringComparison.OrdinalIgnoreCase)
                         || memberRole.Equals("Team-Leader", StringComparison.OrdinalIgnoreCase)))
                    {
                        recipientIds.Add(tm.EmployeeId);
                    }
                }
            }
        }

        // 4. Resolve direct employee context (e.g. Reporting Manager)
        if (instance.RecipientEmployeeId.HasValue)
        {
            var emp = await db.Employees
                .AsNoTracking()
                .Where(e => e.Id == instance.RecipientEmployeeId.Value && e.DeletedAtUtc == null)
                .Select(e => new
                {
                    e.Id,
                    e.ReportingManagerId,
                    e.EngagementManagerEmployeeId,
                    e.ProjectManagerId
                })
                .FirstOrDefaultAsync(ct);

            if (emp != null)
            {
                if (ContainsRole(targetRoles, "ReportingManager", "Manager") && emp.ReportingManagerId.HasValue)
                {
                    recipientIds.Add(emp.ReportingManagerId.Value);
                }

                if (ContainsRole(targetRoles, "EngagementManager") && emp.EngagementManagerEmployeeId.HasValue)
                {
                    recipientIds.Add(emp.EngagementManagerEmployeeId.Value);
                }

                if (ContainsRole(targetRoles, "ProjectManager") && emp.ProjectManagerId.HasValue)
                {
                    recipientIds.Add(emp.ProjectManagerId.Value);
                }
            }
        }

        // 5. Resolve organizational / RBAC roles (Admin, CEO, CTO, COO, PMO, IT Admin)
        var organizationalRoles = targetRoles
            .Where(r => !IsContextualRole(r))
            .ToList();

        if (organizationalRoles.Count > 0)
        {
            var userIds = await db.Users
                .AsNoTracking()
                .Where(u => u.DeletedAtUtc == null
                            && u.Role != null
                            && organizationalRoles.Contains(u.Role.Name))
                .Select(u => u.Id)
                .ToListAsync(ct);

            foreach (var uid in userIds)
            {
                recipientIds.Add(uid);
            }
        }

        return recipientIds.ToList();
    }

    private async Task<List<Guid>> ResolveSeniorProjectManagersAsync(SlaInstance instance, CancellationToken ct)
    {
        var result = new List<Guid>();

        if (instance.ProjectId.HasValue)
        {
            // 1. Team members allocated with role "SeniorProjectManager"
            var spmMembers = await db.ProjectTeamMembers
                .AsNoTracking()
                .Where(tm => tm.ProjectId == instance.ProjectId.Value
                             && (tm.MemberRole == ProjectMemberRoles.SeniorProjectManager
                                 || tm.MemberRole == "Senior Project Manager"
                                 || (tm.MemberRole != null && tm.MemberRole.ToLower().Contains("senior project manager"))
                                 || (tm.MemberRole != null && tm.MemberRole.ToLower().Contains("spm")))
                             && tm.DeletedAtUtc == null)
                .Select(tm => tm.EmployeeId)
                .ToListAsync(ct);

            if (spmMembers.Count > 0)
            {
                return spmMembers;
            }

            // 2. Fallback: Check the Project Manager's Reporting Manager
            var proj = await db.Projects
                .AsNoTracking()
                .Where(p => p.Id == instance.ProjectId.Value && p.DeletedAtUtc == null)
                .Select(p => new { p.ProjectManagerId })
                .FirstOrDefaultAsync(ct);

            if (proj?.ProjectManagerId.HasValue == true && proj.ProjectManagerId.Value != Guid.Empty)
            {
                var pmEmployee = await db.Employees
                    .AsNoTracking()
                    .Where(e => e.Id == proj.ProjectManagerId.Value && e.DeletedAtUtc == null)
                    .Select(e => new { e.ReportingManagerId })
                    .FirstOrDefaultAsync(ct);

                if (pmEmployee?.ReportingManagerId.HasValue == true && pmEmployee.ReportingManagerId.Value != Guid.Empty)
                {
                    result.Add(pmEmployee.ReportingManagerId.Value);
                    return result;
                }
            }
        }

        // 3. Fallback: Any active employee with Senior Project Manager designation or role
        var fallbackSpm = await db.Employees
            .AsNoTracking()
            .Include(e => e.Designation)
            .Where(e => e.DeletedAtUtc == null
                        && ((e.Role != null && (e.Role == "SeniorProjectManager" || e.Role.ToLower().Contains("senior project manager") || e.Role.ToLower() == "spm"))
                            || (e.Designation != null && (e.Designation.Name.Contains("Senior Project Manager") || e.Designation.Name.ToLower().Contains("senior project manager")))))
            .Select(e => e.Id)
            .Take(1)
            .ToListAsync(ct);

        return fallbackSpm;
    }

    private async Task<List<Guid>> ResolveHeadOfDepartmentsAsync(SlaInstance instance, CancellationToken ct)
    {
        // 1. Query OnFloorRoles configured as "Head Of Department"
        var hodOnFloorRoles = await db.OnFloorRoles
            .AsNoTracking()
            .Where(o => o.DeletedAtUtc == null && (
                o.Name.ToLower() == "head of department"
                || o.Name.ToLower() == "hod"
                || o.Name.ToLower().Contains("head of department")
                || o.Name.Contains("Head Of Department")
            ))
            .Select(o => new { o.DesignationId, o.DepartmentId, o.SubDepartment })
            .ToListAsync(ct);

        var hodDesignationIds = hodOnFloorRoles.Select(o => o.DesignationId).Distinct().ToList();

        // 2. Query users with HOD RBAC role
        var hodRoleUsers = await (
            from u in db.Users.AsNoTracking()
            join r in db.Roles.AsNoTracking() on u.RoleId equals r.Id
            where u.DeletedAtUtc == null && r.DeletedAtUtc == null && (
                r.Name.ToLower().Contains("hod") ||
                r.Name.ToLower().Contains("head of department") ||
                r.DisplayName.ToLower().Contains("hod") ||
                r.DisplayName.ToLower().Contains("head of department")
            )
            select new { u.Id, u.EmployeeId, u.Email }
        ).ToListAsync(ct);

        var hodUserEmpCodes = hodRoleUsers.Where(u => !string.IsNullOrWhiteSpace(u.EmployeeId)).Select(u => u.EmployeeId).Distinct().ToList();
        var hodUserEmails = hodRoleUsers.Where(u => !string.IsNullOrWhiteSpace(u.Email)).Select(u => u.Email.ToLower()).Distinct().ToList();
        var hodUserIds = hodRoleUsers.Select(u => u.Id).Distinct().ToList();

        // 3. Query all active employees matching HOD designations, OnFloorRole, Role, or linked HOD user
        var hodEmployees = await db.Employees
            .AsNoTracking()
            .Include(e => e.Designation)
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || !e.Status.ToLower().StartsWith("inactive")))
            .Where(e =>
                (e.DesignationId.HasValue && hodDesignationIds.Contains(e.DesignationId.Value))
                || (e.Role != null && (
                    e.Role.ToLower() == "head of department" ||
                    e.Role.ToLower() == "hod" ||
                    e.Role.ToLower().Contains("head of department") ||
                    e.Role.ToLower().Contains("-hod")
                ))
                || (e.Designation != null && (
                    e.Designation.Name.ToLower().Contains("head of department") ||
                    e.Designation.Name.ToLower().Contains("hod")
                ))
                || (e.EmployeeCode != null && hodUserEmpCodes.Contains(e.EmployeeCode))
                || (e.UserId.HasValue && hodUserIds.Contains(e.UserId.Value))
                || (e.WorkEmail != null && hodUserEmails.Contains(e.WorkEmail.ToLower()))
            )
            .Select(e => new
            {
                e.Id,
                e.FirstName,
                e.LastName,
                e.DepartmentId,
                e.SubDepartmentId,
                e.SubDepartment,
                e.DesignationId
            })
            .ToListAsync(ct);

        if (hodEmployees.Count == 0)
        {
            return [];
        }

        // 4. If instance has ProjectId, attempt to match department / subdepartment
        if (instance.ProjectId.HasValue)
        {
            var serviceDepts = await db.ProjectServices
                .AsNoTracking()
                .Where(s => s.ProjectId == instance.ProjectId.Value && s.DeletedAtUtc == null)
                .Select(s => s.Department)
                .ToListAsync(ct);

            var matchingByServiceName = hodEmployees.Where(e =>
                serviceDepts.Any(sd => !string.IsNullOrWhiteSpace(sd) && e.SubDepartment != null &&
                    (e.SubDepartment.Contains(sd, StringComparison.OrdinalIgnoreCase) || sd.Contains(e.SubDepartment, StringComparison.OrdinalIgnoreCase)))
            ).ToList();

            if (matchingByServiceName.Count > 0)
            {
                return matchingByServiceName.Select(e => e.Id).Distinct().ToList();
            }
        }

        // 5. If instance has RecipientEmployeeId (e.g. assigned resource), match resource department
        if (instance.RecipientEmployeeId.HasValue)
        {
            var resEmp = await db.Employees
                .AsNoTracking()
                .Where(e => e.Id == instance.RecipientEmployeeId.Value && e.DeletedAtUtc == null)
                .Select(e => new { e.DepartmentId, e.SubDepartment })
                .FirstOrDefaultAsync(ct);

            if (resEmp?.DepartmentId.HasValue == true)
            {
                var deptMatch = hodEmployees.Where(e => e.DepartmentId == resEmp.DepartmentId.Value).ToList();
                if (deptMatch.Count > 0)
                {
                    return deptMatch.Select(e => e.Id).Distinct().ToList();
                }
            }

            if (!string.IsNullOrWhiteSpace(resEmp?.SubDepartment))
            {
                var subDeptMatch = hodEmployees.Where(e =>
                    !string.IsNullOrWhiteSpace(e.SubDepartment) &&
                    (e.SubDepartment.Contains(resEmp.SubDepartment, StringComparison.OrdinalIgnoreCase) ||
                     resEmp.SubDepartment.Contains(e.SubDepartment, StringComparison.OrdinalIgnoreCase))).ToList();

                if (subDeptMatch.Count > 0)
                {
                    return subDeptMatch.Select(e => e.Id).Distinct().ToList();
                }
            }
        }

        // 6. Default: return all active HODs
        return hodEmployees.Select(e => e.Id).Distinct().ToList();
    }

    public async Task<IReadOnlyList<Guid>> ResolveLeadershipRecipientsAsync(
        Guid projectId,
        IReadOnlyList<string> targetRoles,
        CancellationToken ct = default)
    {
        var dummyInstance = new SlaInstance
        {
            ProjectId = projectId
        };
        return await ResolveRecipientsAsync(dummyInstance, targetRoles, ct);
    }

    private static bool ContainsRole(IReadOnlyList<string> roles, params string[] matchers)
    {
        return roles.Any(r => matchers.Any(m => string.Equals(r.Trim(), m, StringComparison.OrdinalIgnoreCase)));
    }

    private static bool IsContextualRole(string role)
    {
        var normalized = role.Trim();
        return normalized.Equals("ReportingManager", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("Manager", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("ProjectManager", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("PM", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("Assigned Project Manager", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("TeamLead", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("TL", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("TeamLeader", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("Team Leader", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("Project Team Leader", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("EngagementManager", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("EM", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("Assigned Engagement Manager", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("SeniorProjectManager", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("Sr. PM", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("SPM", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("Assigned Senior Project Manager", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("HeadOfDepartment", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("Head Of Department", StringComparison.OrdinalIgnoreCase)
               || normalized.Equals("HOD", StringComparison.OrdinalIgnoreCase);
    }
}
