using FluentValidation.TestHelper;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Services;
using PMS.API.Modules.Projects.Validators;

namespace PMS.UnitTests;

public class ProjectNamingAndValidationTests
{
    [Theory]
    [InlineData("Acme Corp", "Division 1", new[] { "Network Penetration Testing" }, 1, "Acme Corp(Division 1)_NetworkPenetrationTesting_01")]
    [InlineData("Acme Corp", null, new[] { "Network Penetration Testing" }, 1, "Acme Corp_NetworkPenetrationTesting_01")]
    [InlineData("Beta Tech", "Subsidiary", new[] { "AWS Security Assessment", "AWS Security Assessment" }, 2, "Beta Tech(Subsidiary)_AWSSecurityAssessment_02")]
    [InlineData("Gamma LLC", null, new[] { "Web App PT", "Mobile App PT" }, 5, "Gamma LLC_Mixed_05")]
    [InlineData("Delta Inc", "Div A", null, 10, "Delta Inc(Div A)_General_10")]
    public void BuildProjectName_GeneratesExpectedFormat(
        string clientName,
        string? subVentureName,
        string[]? subDepts,
        int count,
        string expected)
    {
        var result = ProjectAppService.BuildProjectName(clientName, subVentureName, subDepts, count);
        Assert.Equal(expected, result);
    }

    [Fact]
    public void ProjectNameDescriptor_WithSingleSubDept_RemovesWhitespace()
    {
        var descriptor = ProjectAppService.ProjectNameDescriptor(["Cloud Infrastructure Vulnerability Assessment"]);
        Assert.Equal("CloudInfrastructureVulnerabilityAssessment", descriptor);
    }

    [Fact]
    public void ProjectNameDescriptor_WithMultipleUniqueSubDepts_ReturnsMixed()
    {
        var descriptor = ProjectAppService.ProjectNameDescriptor(["Network PT", "Web App PT"]);
        Assert.Equal("Mixed", descriptor);
    }

    [Fact]
    public void CreateProjectValidator_RequiresClientId()
    {
        var validator = new CreateProjectRequestValidator();
        var request = new CreateProjectRequest(ClientId: Guid.Empty);

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.ClientId);
    }

    [Fact]
    public void CreateProjectValidator_ValidatesStatusEnum()
    {
        var validator = new CreateProjectRequestValidator();
        var request = new CreateProjectRequest(ClientId: Guid.NewGuid(), Status: "InvalidStatus");

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.Status);
    }

    [Fact]
    public void UpdateProjectValidator_ValidatesProgressRange()
    {
        var validator = new UpdateProjectRequestValidator();
        var request = new UpdateProjectRequest(Name: "Valid Name", Progress: 150);

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.Progress);
    }

    [Fact]
    public void CreateProjectServiceValidator_ValidatesQtyMinimum()
    {
        var validator = new CreateProjectServiceValidator();
        var request = new CreateProjectServiceRequest(Qty: 0);

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.Qty);
    }

    [Fact]
    public void CreateProjectServiceValidator_ValidatesResourceLevelSum()
    {
        var validator = new CreateProjectServiceValidator();
        var request = new CreateProjectServiceRequest(
            Qty: 4,
            ResourceLevels:
            [
                new ResourceLevelInput("L1", 2),
                new ResourceLevelInput("L2", 1) // sum = 3, but Qty = 4
            ]);

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x);
    }

    [Fact]
    public void CreateProjectServiceValidator_PassesWhenResourceLevelSumMatchesQty()
    {
        var validator = new CreateProjectServiceValidator();
        var request = new CreateProjectServiceRequest(
            Qty: 3,
            ResourceLevels:
            [
                new ResourceLevelInput("L1", 1),
                new ResourceLevelInput("L2", 1),
                new ResourceLevelInput("Senior", 1) // sum = 3 == Qty
            ]);

        var result = validator.TestValidate(request);
        result.ShouldNotHaveValidationErrorFor(x => x);
    }

    [Fact]
    public void CreateProjectTaskValidator_RequiresTitle()
    {
        var validator = new CreateProjectTaskValidator();
        var request = new CreateProjectTaskRequest(Title: "");

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.Title);
    }

    [Fact]
    public void CreateProjectTaskValidator_ValidatesStageEnum()
    {
        var validator = new CreateProjectTaskValidator();
        var request = new CreateProjectTaskRequest(Title: "Task 1", Stage: "UnknownStage");

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.Stage);
    }

    [Fact]
    public void CreateProjectTaskValidator_AcceptsValidStage()
    {
        var validator = new CreateProjectTaskValidator();
        var request = new CreateProjectTaskRequest(Title: "Task 1", Stage: "Ready to Start");

        var result = validator.TestValidate(request);
        result.ShouldNotHaveValidationErrorFor(x => x.Stage);
    }

    [Fact]
    public void CreateProjectTaskValidator_ValidatesPriorityEnum()
    {
        var validator = new CreateProjectTaskValidator();
        var request = new CreateProjectTaskRequest(Title: "Task 1", Priority: "urgent"); // only low/medium/high/critical

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.Priority);
    }

    [Fact]
    public void UpdateProjectTaskValidator_ValidatesProgressRange()
    {
        var validator = new UpdateProjectTaskValidator();
        var request = new UpdateProjectTaskRequest(Progress: 120);

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.Progress);
    }

    [Fact]
    public void UpdateTaskStageValidator_ValidatesValidStage()
    {
        var validator = new UpdateTaskStageValidator();
        var validReq = new UpdateTaskStageRequest("Ongoing");
        var invalidReq = new UpdateTaskStageRequest("InvalidStage");

        validator.TestValidate(validReq).ShouldNotHaveValidationErrorFor(x => x.Stage);
        validator.TestValidate(invalidReq).ShouldHaveValidationErrorFor(x => x.Stage);
    }

    [Fact]
    public void AssignTaskResourceValidator_RequiresEmployeeId()
    {
        var validator = new AssignTaskResourceValidator();
        var request = new AssignTaskResourceRequest(EmployeeId: Guid.Empty);

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.EmployeeId);
    }

    [Fact]
    public void AssignTaskResourceValidator_ValidatesAllocatedHoursNonNegative()
    {
        var validator = new AssignTaskResourceValidator();
        var request = new AssignTaskResourceRequest(EmployeeId: Guid.NewGuid(), AllocatedHours: -5m);

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.AllocatedHours);
    }

    [Fact]
    public void UpdateTaskAssignmentValidator_ValidatesUtilizedHoursNonNegative()
    {
        var validator = new UpdateTaskAssignmentValidator();
        var request = new UpdateTaskAssignmentRequest(UtilizedHours: -10m);

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.UtilizedHours);
    }

    [Fact]
    public void CreateProjectInvoiceValidator_RequiresMilestoneName()
    {
        var validator = new CreateProjectInvoiceValidator();
        var request = new CreateProjectInvoiceRequest(MilestoneName: "");

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.MilestoneName);
    }

    [Fact]
    public void CreateProjectInvoiceValidator_ValidatesPercentageRange()
    {
        var validator = new CreateProjectInvoiceValidator();
        var request = new CreateProjectInvoiceRequest(MilestoneName: "M1", Percentage: 150);

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.Percentage);
    }

    [Fact]
    public void CreateProjectInvoiceValidator_ValidatesStatusEnum()
    {
        var validator = new CreateProjectInvoiceValidator();
        var request = new CreateProjectInvoiceRequest(MilestoneName: "M1", Status: "UnknownStatus");

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.Status);
    }

    [Fact]
    public void CreateProjectInvoiceValidator_AcceptsValidStatus()
    {
        var validator = new CreateProjectInvoiceValidator();
        var request = new CreateProjectInvoiceRequest(MilestoneName: "M1", Status: "Paid");

        var result = validator.TestValidate(request);
        result.ShouldNotHaveValidationErrorFor(x => x.Status);
    }

    [Fact]
    public void UploadProjectDocumentValidator_ValidatesDocumentTypeEnum()
    {
        var validator = new UploadProjectDocumentValidator();
        var request = new UploadProjectDocumentRequest(DocumentType: "InvalidDocType");

        var result = validator.TestValidate(request);
        result.ShouldHaveValidationErrorFor(x => x.DocumentType);
    }

    [Fact]
    public void UploadProjectDocumentValidator_AcceptsValidDocumentType()
    {
        var validator = new UploadProjectDocumentValidator();
        var request = new UploadProjectDocumentRequest(DocumentType: "PO");

        var result = validator.TestValidate(request);
        result.ShouldNotHaveValidationErrorFor(x => x.DocumentType);
    }
}




