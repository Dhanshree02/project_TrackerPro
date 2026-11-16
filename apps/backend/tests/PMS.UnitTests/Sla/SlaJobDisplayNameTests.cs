using Hangfire.Common;
using PMS.API.Modules.Sla.Jobs;
using PMS.API.Modules.Sla.Models;
using Xunit;

namespace PMS.UnitTests.Sla;

public sealed class SlaJobDisplayNameTests
{
    [Fact]
    public void TaskStartSla_L1Escalation_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Task Start After Assigning",
            nameof(SlaEventType.EscalationL1),
            1,
            "Security Vulnerability Assessment",
            "Kotak Securities",
            ["Assigned Senior Project Manager"]);

        Assert.Equal("Task Start SLA | L1 Escalation | Senior Project Manager | Security Vulnerability Assessment | Kotak Securities", name);
    }

    [Fact]
    public void TaskStartSla_L2Escalation_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Task Start After Assigning",
            nameof(SlaEventType.EscalationL2),
            2,
            "Security Vulnerability Assessment",
            "Kotak Securities",
            ["Head of Department"]);

        Assert.Equal("Task Start SLA | L2 Escalation | Head of Department | Security Vulnerability Assessment | Kotak Securities", name);
    }

    [Fact]
    public void TaskStartSla_BreachCheck_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Task Start After Assigning",
            nameof(SlaEventType.BreachCheck),
            null,
            "Security Vulnerability Assessment",
            "Kotak Securities");

        Assert.Equal("Task Start SLA | Breach Check | Security Vulnerability Assessment | Kotak Securities", name);
    }

    [Fact]
    public void TaskStartSla_ImmediateNotification_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Task Start After Assigning",
            "ImmediateNotification",
            null,
            "Security Vulnerability Assessment",
            "Kotak Securities",
            ["EngagementManager", "ProjectManager", "TeamLead"]);

        Assert.Equal("Task Start SLA | Immediate Notification | EM, PM & TL | Security Vulnerability Assessment | Kotak Securities", name);
    }

    [Fact]
    public void TaskDeadlineSla_UpcomingReminder_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Task Deadline",
            nameof(SlaEventType.Reminder),
            null,
            "Database Schema Migration",
            "Apex Banking Portal",
            ["Assigned Project Manager"]);

        Assert.Equal("Task Deadline SLA | Upcoming Deadline Reminder | Database Schema Migration | Apex Banking Portal", name);
    }

    [Fact]
    public void TaskDeadlineSla_L1Escalation_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Task Deadline",
            nameof(SlaEventType.EscalationL1),
            1,
            "Database Schema Migration",
            "Apex Banking Portal",
            ["Assigned Senior Project Manager"]);

        Assert.Equal("Task Deadline SLA | L1 Escalation | Senior Project Manager | Database Schema Migration | Apex Banking Portal", name);
    }

    [Fact]
    public void TaskDeadlineSla_L2Escalation_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Task Deadline",
            nameof(SlaEventType.EscalationL2),
            2,
            "Database Schema Migration",
            "Apex Banking Portal",
            ["Head of Department"]);

        Assert.Equal("Task Deadline SLA | L2 Escalation | Head of Department | Database Schema Migration | Apex Banking Portal", name);
    }

    [Fact]
    public void TaskPauseSla_DailyReminder_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Task Pause",
            nameof(SlaEventType.Reminder),
            null,
            "API Authentication Implementation",
            "FinTech Core Service",
            ["Assigned Resource"]);

        Assert.Equal("Task Pause SLA | Daily Reminder | Assigned Resource | API Authentication Implementation | FinTech Core Service", name);
    }

    [Fact]
    public void ProjectIssueSla_Reminder_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Resolution of Issues",
            nameof(SlaEventType.Reminder),
            null,
            "Payment Gateway Integration Bug",
            "Kotak Securities",
            ["EngagementManager", "ProjectManager", "TeamLead"]);

        Assert.Equal("Project Issue SLA | Reminder | EM, PM & TL | Payment Gateway Integration Bug | Kotak Securities", name);
    }

    [Fact]
    public void ProjectIssueSla_L1Escalation_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Resolution of Issues",
            nameof(SlaEventType.EscalationL1),
            1,
            "Payment Gateway Integration Bug",
            "Kotak Securities",
            ["SeniorProjectManager"]);

        Assert.Equal("Project Issue SLA | L1 Escalation | Senior Project Manager | Payment Gateway Integration Bug | Kotak Securities", name);
    }

    [Fact]
    public void ProjectIssueSla_L2Escalation_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Resolution of Issues",
            nameof(SlaEventType.EscalationL2),
            2,
            "Payment Gateway Integration Bug",
            "Kotak Securities",
            ["HOD"]);

        Assert.Equal("Project Issue SLA | L2 Escalation | Head of Department | Payment Gateway Integration Bug | Kotak Securities", name);
    }

    [Fact]
    public void ProjectIssueSla_BreachCheck_BuildsExpectedJobName()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            "Resolution of Issues",
            nameof(SlaEventType.BreachCheck),
            null,
            "Payment Gateway Integration Bug",
            "Kotak Securities");

        Assert.Equal("Project Issue SLA | Breach Check | Payment Gateway Integration Bug | Kotak Securities", name);
    }

    [Fact]
    public void SlaJobDisplayNameAttribute_ResolvesRegisteredName_FromJobArguments()
    {
        var instanceId = Guid.NewGuid();
        var eventId = Guid.NewGuid();

        var expectedTitle = "Task Start SLA | L1 Escalation | Senior Project Manager | Initial Setup | Test Project";
        SlaJobDisplayNameFormatter.Register(instanceId, eventId, expectedTitle);

        var method = typeof(SlaBackgroundJobWorker).GetMethod(nameof(SlaBackgroundJobWorker.ExecuteEscalationAsync))!;
        var attr = (SlaJobDisplayNameAttribute)Attribute.GetCustomAttribute(method, typeof(SlaJobDisplayNameAttribute))!;
        Assert.NotNull(attr);

        var job = new Job(typeof(SlaBackgroundJobWorker), method, instanceId, eventId, 1);
        var formatted = attr.Format(null!, job);

        Assert.Equal(expectedTitle, formatted);
    }

    [Fact]
    public void SlaJobDisplayNameAttribute_HandlesEmptyOrMissingValues_WithSafeFallback()
    {
        var name = SlaJobDisplayNameFormatter.BuildJobName(
            null,
            nameof(SlaEventType.BreachCheck),
            null,
            null,
            null);

        Assert.Equal("SLA | Breach Check | General | Project", name);
    }
}
