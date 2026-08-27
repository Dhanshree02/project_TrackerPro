using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using PMS.API.Modules.Auth.DTOs;
using PMS.API.Modules.Resources.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.IntegrationTests;

public class ResourceModuleTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public ResourceModuleTests(WebApplicationFactory<Program> factory)
    {
        factory = factory.WithWebHostBuilder(b =>
            b.UseSetting("Database:AutoMigrate", "true"));
        _client = factory.CreateClient();
    }

    private async Task<string> LoginAsync()
    {
        var response = await _client.PostAsJsonAsync("/api/v1/auth/login",
            new LoginRequest("dhanshree@acme.co", "Password@123"));
        response.EnsureSuccessStatusCode();

        var envelope = await response.Content.ReadFromJsonAsync<ApiResponse<AuthResult>>();
        return envelope!.Data!.AccessToken;
    }

    [Fact]
    public async Task EmployeeCrud_And_Offboard_RoundTrip()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var code = "EMP-" + Random.Shared.Next(2000, 9999);
        var create = new CreateEmployeeRequest(
            EmployeeCode: code,
            FirstName: "Integration",
            LastName: "Resource",
            WorkEmail: $"integration.resource.{Guid.NewGuid():N}@acme.co",
            PersonalEmail: null,
            Phone: null,
            AltPhone: null,
            Gender: null,
            DateOfBirth: null,
            Address: null,
            EmergencyContact: null,
            MaritalStatus: null,
            Nationality: null,
            NationalityId: null,
            DepartmentId: null,
            DesignationId: null,
            Role: "Employee",
            JobRoleId: null,
            ReportingManagerId: null,
            BusinessUnit: null,
            WorkLocation: null,
            OfficeBranch: null,
            Category: null,
            Team: null,
            JoiningDate: null,
            Status: "Active",
            ConfirmationStatus: null,
            ProbationStatus: null,
            Experience: null,
            PreviousCompany: null,
            EmploymentType: null,
            ContractType: null,
            BondStatus: null,
            NoticePeriod: null,
            ProjectSite: null,
            AssetId: null,
            ExitType: null,
            ExitReason: null,
            Education: null,
            Skills: ["C#"],
            Certifications: null,
            Languages: null,
            KpiScore: null,
            QuarterlyKpi: null,
            AnnualRating: null,
            GoalCompletion: null,
            Attendance: null,
            ReportingEfficiency: null,
            PromotionReadiness: null,
            ManagerFeedback: null,
            Pan: null,
            BankAccount: null,
            SalaryBand: null,
            PfUan: null,
            TaxRegime: null,
            ComplianceStatus: null);

        var createResponse = await _client.PostAsJsonAsync("/api/v1/employees", create);
        Assert.Equal(HttpStatusCode.Created, createResponse.StatusCode);
        var created = await createResponse.Content.ReadFromJsonAsync<ApiResponse<EmployeeDetailDto>>();
        Assert.NotNull(created?.Data);
        var id = created!.Data!.Id;

        var getResponse = await _client.GetAsync($"/api/v1/employees/{id}");
        Assert.Equal(HttpStatusCode.OK, getResponse.StatusCode);

        var updateResponse = await _client.PutAsJsonAsync($"/api/v1/employees/{id}",
            new UpdateEmployeeRequest(
                FirstName: null,
                LastName: null,
                WorkEmail: null,
                PersonalEmail: null,
                Phone: null,
                AltPhone: null,
                Gender: null,
                DateOfBirth: null,
                Address: null,
                EmergencyContact: null,
                MaritalStatus: null,
                Nationality: null,
                NationalityId: null,
                DepartmentId: null,
                DesignationId: null,
                Department: null,
                Designation: null,
                Role: null,
                JobRoleId: null,
                ReportingManagerId: null,
                BusinessUnit: null,
                WorkLocation: null,
                OfficeBranch: null,
                Category: "Permanent - Without Bond",
                Team: null,
                JoiningDate: null,
                Status: "Probation",
                ConfirmationStatus: null,
                ProbationStatus: null,
                Experience: null,
                PreviousCompany: null,
                EmploymentType: null,
                ContractType: null,
                BondStatus: null,
                NoticePeriod: null,
                ProjectSite: null,
                AssetId: null,
                ExitType: null,
                ExitReason: null,
                Education: null,
                Skills: null,
                Certifications: null,
                Languages: null,
                KpiScore: null,
                QuarterlyKpi: null,
                AnnualRating: null,
                GoalCompletion: null,
                Attendance: null,
                ReportingEfficiency: null,
                PromotionReadiness: null,
                ManagerFeedback: null,
                Pan: null,
                BankAccount: null,
                SalaryBand: null,
                PfUan: null,
                TaxRegime: null,
                ComplianceStatus: null));
        Assert.Equal(HttpStatusCode.OK, updateResponse.StatusCode);

        var offboardResponse = await _client.PostAsJsonAsync($"/api/v1/employees/{id}/offboard",
            new OffboardEmployeeRequest(
                ResignationDate: DateOnly.FromDateTime(DateTime.UtcNow),
                LastWorkingDay: DateOnly.FromDateTime(DateTime.UtcNow.AddDays(30)),
                ReasonForLeaving: "Integration test",
                NoticePeriodServed: "30 days",
                ExitChecklistJson: "{}",
                AssetReturnJson: "{}",
                FinalSettlementJson: "{}",
                ExitType: "Resign",
                ExitReason: "Integration test"));
        Assert.Equal(HttpStatusCode.OK, offboardResponse.StatusCode);

        var duringNotice = await _client.GetAsync($"/api/v1/employees/{id}");
        Assert.Equal(HttpStatusCode.OK, duringNotice.StatusCode);

        var pastCode = "EMP-" + Random.Shared.Next(2000, 9999);
        var pastCreate = create with
        {
            EmployeeCode = pastCode,
            WorkEmail = $"integration.resource.{Guid.NewGuid():N}@acme.co",
        };
        var pastCreateResponse = await _client.PostAsJsonAsync("/api/v1/employees", pastCreate);
        Assert.Equal(HttpStatusCode.Created, pastCreateResponse.StatusCode);
        var pastCreated = await pastCreateResponse.Content.ReadFromJsonAsync<ApiResponse<EmployeeDetailDto>>();
        var pastId = pastCreated!.Data!.Id;

        var pastOffboard = await _client.PostAsJsonAsync($"/api/v1/employees/{pastId}/offboard",
            new OffboardEmployeeRequest(
                ResignationDate: DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-10)),
                LastWorkingDay: DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-1)),
                ReasonForLeaving: "Notice already ended",
                NoticePeriodServed: "30 days",
                ExitChecklistJson: "{}",
                AssetReturnJson: "{}",
                FinalSettlementJson: "{}",
                ExitType: "Resign",
                ExitReason: "Notice already ended"));
        Assert.Equal(HttpStatusCode.OK, pastOffboard.StatusCode);

        var afterNotice = await _client.GetAsync($"/api/v1/employees/{pastId}");
        Assert.Equal(HttpStatusCode.NotFound, afterNotice.StatusCode);
    }

    [Fact]
    public async Task EmployeeCatalogs_Filter_And_Create()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var nationalities = await _client.GetFromJsonAsync<ApiResponse<List<MetaOptionDto>>>(
            "/api/v1/employees/meta/nationalities");
        Assert.NotNull(nationalities?.Data);
        Assert.Contains(nationalities.Data, n => n.Name == "Indian");

        var salaryBands = await _client.GetFromJsonAsync<ApiResponse<List<MetaOptionDto>>>(
            "/api/v1/employees/meta/salary-bands");
        Assert.NotNull(salaryBands?.Data);
        Assert.Equal(5, salaryBands.Data.Count);
        Assert.Contains(salaryBands.Data, b => b.Name == "L1");

        var departments = await _client.GetFromJsonAsync<ApiResponse<List<MetaOptionDto>>>(
            "/api/v1/employees/meta/departments");
        Assert.NotNull(departments?.Data);
        var engineering = Assert.Single(departments.Data, d => d.Code == "engineering");

        var designations = await _client.GetFromJsonAsync<ApiResponse<List<MetaOptionDto>>>(
            $"/api/v1/employees/meta/designations?departmentId={engineering.Id}");
        Assert.NotNull(designations?.Data);
        Assert.NotEmpty(designations.Data);
        Assert.All(designations.Data, d => Assert.Equal(engineering.Id, d.ParentId));

        var softwareEngineer = Assert.Single(designations.Data, d => d.Code == "software_engineer");
        var roles = await _client.GetFromJsonAsync<ApiResponse<List<MetaOptionDto>>>(
            $"/api/v1/employees/meta/roles?designationId={softwareEngineer.Id}");
        Assert.NotNull(roles?.Data);
        Assert.NotEmpty(roles.Data);
        Assert.All(roles.Data, r => Assert.Equal(softwareEngineer.Id, r.ParentId));

        var deptResponse = await _client.PostAsJsonAsync("/api/v1/employees/meta/departments",
            new CreateCatalogItemRequest("Engineering"));
        Assert.Equal(HttpStatusCode.OK, deptResponse.StatusCode);
        var dept = (await deptResponse.Content.ReadFromJsonAsync<ApiResponse<MetaOptionDto>>())!.Data!;
        Assert.Equal(engineering.Id, dept.Id);

        var desigResponse = await _client.PostAsJsonAsync("/api/v1/employees/meta/designations",
            new CreateCatalogItemRequest("Software Engineer", engineering.Id));
        Assert.Equal(HttpStatusCode.OK, desigResponse.StatusCode);
        var desig = (await desigResponse.Content.ReadFromJsonAsync<ApiResponse<MetaOptionDto>>())!.Data!;
        Assert.Equal(softwareEngineer.Id, desig.Id);

        var roleResponse = await _client.PostAsJsonAsync("/api/v1/employees/meta/roles",
            new CreateCatalogItemRequest("Developer", softwareEngineer.Id));
        Assert.Equal(HttpStatusCode.OK, roleResponse.StatusCode);
        var role = (await roleResponse.Content.ReadFromJsonAsync<ApiResponse<MetaOptionDto>>())!.Data!;
        Assert.Equal(softwareEngineer.Id, role.ParentId);

        var tooYoung = new CreateEmployeeRequest(
            EmployeeCode: "EMP-" + Random.Shared.Next(2000, 9999),
            FirstName: "TooYoung",
            LastName: "Person",
            WorkEmail: $"too.young.{Guid.NewGuid():N}@acme.co",
            PersonalEmail: null,
            Phone: null,
            AltPhone: null,
            Gender: null,
            DateOfBirth: DateOnly.FromDateTime(DateTime.UtcNow.Date.AddYears(-10)),
            Address: null,
            EmergencyContact: null,
            MaritalStatus: null,
            Nationality: null,
            NationalityId: null,
            DepartmentId: null,
            DesignationId: null,
            Role: null,
            JobRoleId: null,
            ReportingManagerId: null,
            BusinessUnit: null,
            WorkLocation: null,
            OfficeBranch: null,
            Category: null,
            Team: null,
            JoiningDate: null,
            Status: "Active",
            ConfirmationStatus: null,
            ProbationStatus: null,
            Experience: null,
            PreviousCompany: null,
            EmploymentType: null,
            ContractType: null,
            BondStatus: null,
            NoticePeriod: null,
            ProjectSite: null,
            AssetId: null,
            ExitType: null,
            ExitReason: null,
            Education: null,
            Skills: null,
            Certifications: null,
            Languages: null,
            KpiScore: null,
            QuarterlyKpi: null,
            AnnualRating: null,
            GoalCompletion: null,
            Attendance: null,
            ReportingEfficiency: null,
            PromotionReadiness: null,
            ManagerFeedback: null,
            Pan: null,
            BankAccount: null,
            SalaryBand: null,
            PfUan: null,
            TaxRegime: null,
            ComplianceStatus: null);
        var youngResponse = await _client.PostAsJsonAsync("/api/v1/employees", tooYoung);
        Assert.Equal(HttpStatusCode.BadRequest, youngResponse.StatusCode);
    }

    [Theory]
    [InlineData("sahil@")]
    [InlineData("@gmail.com")]
    [InlineData("sahil@gmail")]
    [InlineData("sahil gmail.com")]
    [InlineData("sahil@.com")]
    [InlineData("sahil#test@gmail.com")]
    [InlineData("sahil$test@gmail.com")]
    [InlineData("sahil%test@gmail.com")]
    [InlineData("sahil^test@gmail.com")]
    [InlineData("sahil+tag@gmail.com")]
    public async Task CreateEmployee_RejectsInvalidWorkEmail(string workEmail)
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var response = await _client.PostAsJsonAsync("/api/v1/employees", new
        {
            employeeCode = "EMP-" + Random.Shared.Next(2000, 9999),
            firstName = "Sahil",
            lastName = "Lad",
            workEmail,
        });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var json = await response.Content.ReadAsStringAsync();
        Assert.Contains("valid email", json, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("\"data\":{", json, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task CreateEmployee_PersistsOnboardProfileFields()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var departments = (await _client.GetFromJsonAsync<ApiResponse<List<MetaOptionDto>>>(
            "/api/v1/employees/meta/departments"))!.Data!;
        var engineering = Assert.Single(departments, d => d.Code == "engineering");
        var designations = (await _client.GetFromJsonAsync<ApiResponse<List<MetaOptionDto>>>(
            $"/api/v1/employees/meta/designations?departmentId={engineering.Id}"))!.Data!;
        var softwareEngineer = Assert.Single(designations, d => d.Code == "software_engineer");
        var roles = (await _client.GetFromJsonAsync<ApiResponse<List<MetaOptionDto>>>(
            $"/api/v1/employees/meta/roles?designationId={softwareEngineer.Id}"))!.Data!;
        var jobRole = Assert.Single(roles, r => r.Name == "Developer");
        var nationalities = (await _client.GetFromJsonAsync<ApiResponse<List<MetaOptionDto>>>(
            "/api/v1/catalogs/nationalities"))!.Data!;
        var indian = Assert.Single(nationalities, n => n.Name == "Indian");
        var salaryBands = (await _client.GetFromJsonAsync<ApiResponse<List<MetaOptionDto>>>(
            "/api/v1/employees/meta/salary-bands"))!.Data!;
        var l2 = Assert.Single(salaryBands, b => b.Name == "L2");

        var code = "EMP-" + Random.Shared.Next(2000, 9999);
        var payload = new
        {
            employeeCode = code,
            firstName = "Priya",
            lastName = "Shah",
            workEmail = $"priya.shah.{Guid.NewGuid():N}@acme.co",
            gender = "Female",
            dateOfBirth = "1994-03-12",
            address = "Andheri East, Mumbai",
            emergencyContact = "9876543210",
            maritalStatus = "Married",
            nationalityId = indian.Id,
            departmentId = engineering.Id,
            designationId = softwareEngineer.Id,
            jobRoleId = jobRole.Id,
            businessUnit = "Enterprise",
            team = "Platform",
            workLocation = "Mumbai",
            officeBranch = "HQ Tower",
            projectSite = "Offsite",
            probationStatus = "6 months",
            probationPeriod = "6 months",
            experience = "5 years",
            previousCompany = "Acme",
            employmentType = "Full-time",
            contractType = "Permanent",
            bondStatus = "No",
            salaryBandId = l2.Id,
            assetId = "TK-4029",
            education = "B.Tech",
            skills = new[] { "React", "Mentoring" },
            certifications = new[] { "AWS" },
            languages = new[] { "English", "Hindi" },
            status = "Active",
        };

        var createResponse = await _client.PostAsJsonAsync("/api/v1/employees", payload);
        Assert.Equal(HttpStatusCode.Created, createResponse.StatusCode);
        var created = await createResponse.Content.ReadFromJsonAsync<ApiResponse<EmployeeDetailDto>>();
        Assert.NotNull(created?.Data);
        var emp = created!.Data!;

        Assert.Equal("Female", emp.Gender);
        Assert.Equal(new DateOnly(1994, 3, 12), emp.DateOfBirth);
        Assert.Equal("Andheri East, Mumbai", emp.Address);
        Assert.Equal("9876543210", emp.EmergencyContact);
        Assert.Equal("Married", emp.MaritalStatus);
        Assert.Equal("Indian", emp.Nationality);
        Assert.Equal(engineering.Name, emp.Department);
        Assert.Equal(softwareEngineer.Name, emp.Designation);
        Assert.Equal("Enterprise", emp.BusinessUnit);
        Assert.Equal("Mumbai", emp.WorkLocation);
        Assert.Equal("HQ Tower", emp.OfficeBranch);
        Assert.Equal("Platform", emp.Team);
        Assert.Equal("6 months", emp.ProbationStatus);
        Assert.Equal("5 years", emp.Experience);
        Assert.Equal("Acme", emp.PreviousCompany);
        Assert.Equal("Full-time", emp.EmploymentType);
        Assert.Equal("Permanent", emp.ContractType);
        Assert.Equal("No", emp.BondStatus);
        Assert.Equal("L2", emp.SalaryBand);
        Assert.Equal("TK-4029", emp.AssetId);
        Assert.Equal("B.Tech", emp.Education);
        Assert.Equal(new[] { "React", "Mentoring" }, emp.Skills.ToArray());
        Assert.Equal(new[] { "AWS" }, emp.Certifications.ToArray());
        Assert.Equal(new[] { "English", "Hindi" }, emp.Languages.ToArray());
    }

    [Fact]
    public async Task CreateEmployee_RejectsPastJoiningDate()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var pastJoin = DateOnly.FromDateTime(DateTime.UtcNow.Date.AddDays(-2));
        var payload = new
        {
            employeeCode = "EMP-" + Random.Shared.Next(2000, 9999),
            firstName = "Past",
            lastName = "Joiner",
            workEmail = $"past.join.{Guid.NewGuid():N}@acme.co",
            joiningDate = pastJoin.ToString("yyyy-MM-dd"),
            status = "Active",
        };

        var response = await _client.PostAsJsonAsync("/api/v1/employees", payload);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task CreateEmployee_RejectsDuplicateWorkEmailAndPhone()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var suffix = Guid.NewGuid().ToString("N")[..8];
        var workEmail = $"dup.identity.{suffix}@acme.co";
        var phone = "9" + Random.Shared.Next(100000000, 999999999).ToString();
        var aadhaar = "2" + Random.Shared.Next(100000000, 999999999).ToString() + Random.Shared.Next(10, 99).ToString();
        var uan = "1" + Random.Shared.Next(100000000, 999999999).ToString() + Random.Shared.Next(10, 99).ToString();

        var first = new
        {
            employeeCode = "EMP-" + Random.Shared.Next(2000, 9999),
            firstName = "Dup",
            lastName = "One",
            workEmail,
            phone,
            pan = $"BBBBB{Random.Shared.Next(1000, 9999)}B",
            aadhaar,
            pfUan = uan,
        };
        var firstResponse = await _client.PostAsJsonAsync("/api/v1/employees", first);
        Assert.Equal(HttpStatusCode.Created, firstResponse.StatusCode);

        var dupEmail = new
        {
            employeeCode = "EMP-" + Random.Shared.Next(2000, 9999),
            firstName = "Dup",
            lastName = "Two",
            workEmail,
            phone = "8" + phone[1..],
        };
        var emailResponse = await _client.PostAsJsonAsync("/api/v1/employees", dupEmail);
        Assert.Equal(HttpStatusCode.Conflict, emailResponse.StatusCode);
        var emailJson = await emailResponse.Content.ReadAsStringAsync();
        Assert.Contains("work email", emailJson, StringComparison.OrdinalIgnoreCase);

        var dupPhone = new
        {
            employeeCode = "EMP-" + Random.Shared.Next(2000, 9999),
            firstName = "Dup",
            lastName = "Three",
            workEmail = $"dup.phone.{suffix}@acme.co",
            phone,
        };
        var phoneResponse = await _client.PostAsJsonAsync("/api/v1/employees", dupPhone);
        Assert.Equal(HttpStatusCode.Conflict, phoneResponse.StatusCode);
        var phoneJson = await phoneResponse.Content.ReadAsStringAsync();
        Assert.Contains("phone", phoneJson, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task EmployeeBulk_SampleDownload_And_DuplicateUploadRejected()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var sample = await _client.GetAsync("/api/v1/employees/bulk/sample");
        Assert.Equal(HttpStatusCode.OK, sample.StatusCode);
        Assert.Contains("spreadsheetml.sheet", sample.Content.Headers.ContentType?.MediaType ?? "");
        var bytes = await sample.Content.ReadAsByteArrayAsync();
        Assert.True(bytes.Length > 0);

        async Task<ApiResponse<EmployeeBulkUploadResult>> UploadAsync()
        {
            using var content = new MultipartFormDataContent();
            var file = new ByteArrayContent(bytes);
            file.Headers.ContentType = new MediaTypeHeaderValue(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            content.Add(file, "file", "employee-bulk-upload-sample.xlsx");
            var response = await _client.PostAsync("/api/v1/employees/bulk", content);
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            return (await response.Content.ReadFromJsonAsync<ApiResponse<EmployeeBulkUploadResult>>())!;
        }

        var first = await UploadAsync();
        Assert.NotNull(first.Data);
        var second = await UploadAsync();
        Assert.NotNull(second.Data);
        Assert.Equal(0, second.Data!.Created);
        Assert.True(second.Data.Failed >= 1);
        Assert.Contains(second.Data.Errors, e =>
            e.Message.Contains("already exists", StringComparison.OrdinalIgnoreCase));
    }
}
