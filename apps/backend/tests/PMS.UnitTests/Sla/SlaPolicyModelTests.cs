using PMS.API.Modules.Sla.Models;

namespace PMS.UnitTests.Sla;

public class SlaPolicyModelTests
{
    [Fact]
    public void SlaPolicy_JsonProperties_SerializeAndDeserializeCorrectly()
    {
        var policy = new SlaPolicy
        {
            Module = "ActionCentre",
            ActivityType = "ResourceAllocationApproval",
            Stage = "PendingApproval",
            Name = "Resource Allocation SLA Policy",
            TatDurationMinutes = 2880,
            CalculationMode = SlaCalculationMode.WorkingHours,
            ReminderIntervals = [240, 120, 30],
            ResponsibleRoles = ["ReportingManager", "Manager"],
            FirstEscalationRoles = ["EngagementManager", "PMO"],
            SecondEscalationRoles = ["CEO", "Admin"]
        };

        Assert.Equal("[240,120,30]", policy.ReminderIntervalsMinutesJson);
        Assert.Equal("[\"ReportingManager\",\"Manager\"]", policy.ResponsibleRolesJson);
        Assert.Equal("[\"EngagementManager\",\"PMO\"]", policy.FirstEscalationRolesJson);
        Assert.Equal("[\"CEO\",\"Admin\"]", policy.SecondEscalationRolesJson);

        Assert.Equal([240, 120, 30], policy.ReminderIntervals);
        Assert.Equal(["ReportingManager", "Manager"], policy.ResponsibleRoles);
        Assert.Equal(["EngagementManager", "PMO"], policy.FirstEscalationRoles);
        Assert.Equal(["CEO", "Admin"], policy.SecondEscalationRoles);
    }

    [Fact]
    public void SlaEvent_JsonProperties_SerializeAndDeserializeCorrectly()
    {
        var targetGuid1 = Guid.NewGuid();
        var targetGuid2 = Guid.NewGuid();

        var evt = new SlaEvent
        {
            EventType = SlaEventType.EscalationL1,
            StageAtExecution = "PendingApproval",
            TargetRoles = ["PMO", "HOD"],
            TargetRecipientIds = [targetGuid1, targetGuid2]
        };

        Assert.Equal(["PMO", "HOD"], evt.TargetRoles);
        Assert.Equal([targetGuid1, targetGuid2], evt.TargetRecipientIds);
    }
}
