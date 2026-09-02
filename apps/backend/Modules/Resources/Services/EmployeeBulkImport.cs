using System.Globalization;
using ClosedXML.Excel;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Resources.DTOs;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Exceptions;
using PMS.API.Shared.Validation;

namespace PMS.API.Modules.Resources.Services;

internal static class EmployeeBulkWorkbook
{
    public const int MaxRows = 500;
    public const long MaxBytes = 5 * 1024 * 1024;

    public static readonly string[] Headers =
    [
        "TK ID",
        "First Name",
        "Last Name",
        "Work Email",
        "Personal Email",
        "Phone",
        "Alternate Phone",
        "Gender",
        "Date of Birth",
        "Address",
        "Emergency Contact",
        "Marital Status",
        "Nationality",
        "Department",
        "Designation",
        "Role",
        "Reporting Manager Code",
        "Business Unit",
        "Work Location",
        "Office Branch",
        "Category",
        "Team",
        "Joining Date",
        "Status",
        "Employment Type",
        "Experience",
        "Previous Company",
        "PAN",
        "Aadhaar",
        "UAN",
        "Bank Account",
        "Salary Band",
        "Skills",
        "Languages",
    ];

    public static byte[] BuildSample()
    {
        using var workbook = new XLWorkbook();
        var sheet = workbook.Worksheets.Add("Employees");
        for (var i = 0; i < Headers.Length; i++)
        {
            var cell = sheet.Cell(1, i + 1);
            cell.Value = Headers[i];
            cell.Style.Font.Bold = true;
            cell.Style.Fill.BackgroundColor = XLColor.FromHtml("#DBEAFE");
        }

        var example = new[]
        {
            "TK-0001",
            "Sample",
            "Employee",
            "sample.employee@talakunchi.com",
            "sample.personal@gmail.com",
            "9999911111",
            "",
            "Female",
            "1995-06-15",
            "Andheri East, Mumbai",
            "9876543210",
            "Single",
            "Indian",
            "Services - Testing",
            "PenTester - I",
            "Employee",
            "TK-0004",
            "Enterprise",
            "Andheri",
            "Suvidha Square",
            "Permanent - Without Bond",
            "Platform",
            DateOnly.FromDateTime(DateTime.UtcNow.Date).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
            "Active",
            "Full-Time",
            "4 years",
            "",
            "AAAAA9999A",
            "234567890124",
            "100987654321",
            "501234567890",
            "L2",
            "C#, React",
            "English, Hindi",
        };
        for (var i = 0; i < example.Length; i++)
            sheet.Cell(2, i + 1).Value = example[i];

        sheet.SheetView.FreezeRows(1);
        sheet.Range(1, 1, 1, Headers.Length).SetAutoFilter();
        sheet.Columns().AdjustToContents(1, 40);

        var notes = workbook.Worksheets.Add("Instructions");
        notes.Cell(1, 1).Value = "How to use this template";
        notes.Cell(1, 1).Style.Font.Bold = true;
        notes.Cell(2, 1).Value = "1. Keep the header row exactly as provided on the Employees sheet.";
        notes.Cell(3, 1).Value = "2. Upload .xlsx only. Other file types are rejected.";
        notes.Cell(4, 1).Value = "3. Required columns: Employee Code, First Name, Last Name, Work Email.";
        notes.Cell(5, 1).Value = "4. Work email, personal email, phone, PAN, Aadhaar, and UAN must be unique across the file and the database. Duplicate rows are skipped and an error is shown.";
        notes.Cell(6, 1).Value = "5. Department, Designation, Role, Nationality, Salary Band, and Reporting Manager Code must match existing values when filled.";
        notes.Cell(7, 1).Value = "6. Dates should be YYYY-MM-DD. Phone numbers should be 10-digit Indian mobiles.";
        notes.Columns().AdjustToContents();

        using var stream = new MemoryStream();
        workbook.SaveAs(stream);
        return stream.ToArray();
    }
}

internal sealed class EmployeeBulkImporter(AppDbContext db, EmployeeService employees)
{
    public async Task<EmployeeBulkUploadResult> ImportAsync(Stream stream, CancellationToken ct)
    {
        XLWorkbook workbook;
        try
        {
            workbook = new XLWorkbook(stream);
        }
        catch (Exception)
        {
            throw new ConflictException("Could not read the file. Upload a valid Excel (.xlsx) workbook.");
        }

        using (workbook)
        {
            var sheet = workbook.Worksheets.FirstOrDefault(w =>
                w.Name.Equals("Employees", StringComparison.OrdinalIgnoreCase))
                ?? workbook.Worksheets.FirstOrDefault(w =>
                    !w.Name.Equals("Instructions", StringComparison.OrdinalIgnoreCase))
                ?? workbook.Worksheets.FirstOrDefault()
                ?? throw new ConflictException("The Excel file has no worksheets.");

            var headerMap = ReadHeaders(sheet);
            if (!headerMap.ContainsKey("employeecode")
                || !headerMap.ContainsKey("firstname")
                || !headerMap.ContainsKey("lastname")
                || !headerMap.ContainsKey("workemail"))
            {
                throw new ConflictException(
                    "The Excel file is missing required columns: Employee Code, First Name, Last Name, Work Email. Download the sample and try again.");
            }

            var lastRow = sheet.LastRowUsed()?.RowNumber() ?? 1;
            if (lastRow < 2)
                return new EmployeeBulkUploadResult(0, 0, []);

            var departments = await db.Departments.ToListAsync(ct);
            var designations = await db.Designations.ToListAsync(ct);
            var roles = await db.JobRoles.ToListAsync(ct);
            var nationalities = await db.Nationalities.ToListAsync(ct);
            var salaryBands = await db.SalaryBands.ToListAsync(ct);
            var managers = await db.Employees
                .Select(e => new { e.Id, e.EmployeeCode, Name = e.FirstName + " " + e.LastName })
                .ToListAsync(ct);

            var snapshot = await EmployeeIdentityGuard.LoadSnapshotAsync(db, null, ct);
            var errors = new List<EmployeeBulkRowError>();
            var created = 0;
            var dataRows = 0;

            for (var excelRow = 2; excelRow <= lastRow; excelRow++)
            {
                var row = sheet.Row(excelRow);
                if (row.IsEmpty()) continue;

                dataRows++;
                if (dataRows > EmployeeBulkWorkbook.MaxRows)
                {
                    errors.Add(new EmployeeBulkRowError(
                        excelRow, null, $"Only the first {EmployeeBulkWorkbook.MaxRows} rows can be imported."));
                    continue;
                }

                var values = ReadRow(row, headerMap);
                var code = GetValue(values, "employeecode");
                var firstName = GetValue(values, "firstname");
                var lastName = GetValue(values, "lastname");
                var workEmail = GetValue(values, "workemail");

                if (string.IsNullOrWhiteSpace(code)
                    && string.IsNullOrWhiteSpace(firstName)
                    && string.IsNullOrWhiteSpace(lastName)
                    && string.IsNullOrWhiteSpace(workEmail))
                {
                    continue;
                }

                var rowErrors = new List<string>();
                if (string.IsNullOrWhiteSpace(code)) rowErrors.Add("Employee Code is required.");
                if (string.IsNullOrWhiteSpace(firstName)) rowErrors.Add("First Name is required.");
                if (string.IsNullOrWhiteSpace(lastName)) rowErrors.Add("Last Name is required.");
                if (string.IsNullOrWhiteSpace(workEmail)) rowErrors.Add("Work Email is required.");
                else if (!EmailRules.IsValid(workEmail)) rowErrors.Add("Work Email is not a valid email address.");

                var personalEmail = GetValue(values,"personalemail");
                if (!string.IsNullOrWhiteSpace(personalEmail) && !EmailRules.IsValid(personalEmail))
                    rowErrors.Add("Personal Email is not a valid email address.");

                var phone = GetValue(values,"phone");
                if (!string.IsNullOrWhiteSpace(phone) && !PhoneRules.IsValid(phone))
                    rowErrors.Add("Phone must be a valid 10-digit Indian mobile number.");
                var altPhone = GetValue(values,"alternatephone");
                if (!string.IsNullOrWhiteSpace(altPhone) && !PhoneRules.IsValid(altPhone))
                    rowErrors.Add("Alternate Phone must be a valid 10-digit Indian mobile number.");

                var identity = new EmployeeIdentity(
                    code,
                    EmployeeIdentityGuard.NormalizeEmail(workEmail),
                    EmployeeIdentityGuard.NormalizeEmail(personalEmail),
                    PhoneRules.NullIfEmpty(phone),
                    PhoneRules.NullIfEmpty(altPhone),
                    EmployeeIdentityGuard.NormalizePan(GetValue(values,"pan")),
                    EmployeeIdentityGuard.NormalizeAadhaar(GetValue(values,"aadhaar")),
                    EmployeeIdentityGuard.NormalizeUan(GetValue(values,"uan")));

                rowErrors.AddRange(snapshot.Conflicts(identity));

                Guid? departmentId = null;
                var departmentName = GetValue(values,"department");
                if (!string.IsNullOrWhiteSpace(departmentName))
                {
                    var dept = departments.FirstOrDefault(d =>
                        d.Name.Equals(departmentName, StringComparison.OrdinalIgnoreCase));
                    if (dept is null) rowErrors.Add($"Department '{departmentName}' was not found.");
                    else departmentId = dept.Id;
                }

                Guid? designationId = null;
                var designationName = GetValue(values,"designation");
                if (!string.IsNullOrWhiteSpace(designationName))
                {
                    var matches = designations.Where(d =>
                        d.Name.Equals(designationName, StringComparison.OrdinalIgnoreCase));
                    var desig = departmentId is Guid deptId
                        ? matches.FirstOrDefault(d => d.DepartmentId == deptId) ?? matches.FirstOrDefault()
                        : matches.FirstOrDefault();
                    if (desig is null) rowErrors.Add($"Designation '{designationName}' was not found.");
                    else designationId = desig.Id;
                }

                Guid? jobRoleId = null;
                var roleName = GetValue(values,"role");
                if (!string.IsNullOrWhiteSpace(roleName))
                {
                    var matches = roles.Where(r => r.Name.Equals(roleName, StringComparison.OrdinalIgnoreCase));
                    var role = designationId is Guid desigId
                        ? matches.FirstOrDefault(r => r.DesignationId == desigId) ?? matches.FirstOrDefault()
                        : matches.FirstOrDefault();
                    if (role is null) rowErrors.Add($"Role '{roleName}' was not found.");
                    else jobRoleId = role.Id;
                }

                Guid? nationalityId = null;
                var nationalityName = GetValue(values,"nationality");
                if (!string.IsNullOrWhiteSpace(nationalityName))
                {
                    var nationality = nationalities.FirstOrDefault(n =>
                        n.Name.Equals(nationalityName, StringComparison.OrdinalIgnoreCase));
                    if (nationality is null) rowErrors.Add($"Nationality '{nationalityName}' was not found.");
                    else nationalityId = nationality.Id;
                }

                Guid? salaryBandId = null;
                var salaryBandName = GetValue(values,"salaryband");
                if (!string.IsNullOrWhiteSpace(salaryBandName))
                {
                    var band = salaryBands.FirstOrDefault(b =>
                        b.Name.Equals(salaryBandName, StringComparison.OrdinalIgnoreCase));
                    if (band is null) rowErrors.Add($"Salary Band '{salaryBandName}' was not found.");
                    else salaryBandId = band.Id;
                }

                Guid? reportingManagerId = null;
                var managerCode = GetValue(values,"reportingmanagercode");
                if (!string.IsNullOrWhiteSpace(managerCode))
                {
                    var manager = managers.FirstOrDefault(m =>
                        m.EmployeeCode.Equals(managerCode, StringComparison.OrdinalIgnoreCase)
                        || m.Name.Equals(managerCode, StringComparison.OrdinalIgnoreCase));
                    if (manager is null) rowErrors.Add($"Reporting manager '{managerCode}' was not found.");
                    else reportingManagerId = manager.Id;
                }

                if (rowErrors.Count > 0)
                {
                    errors.Add(new EmployeeBulkRowError(excelRow, NullIfEmpty(code), string.Join(" ", rowErrors)));
                    continue;
                }

                var request = new CreateEmployeeRequest(
                    EmployeeCode: code.Trim(),
                    FirstName: firstName.Trim(),
                    LastName: lastName.Trim(),
                    WorkEmail: workEmail.Trim(),
                    PersonalEmail: NullIfEmpty(personalEmail),
                    Phone: PhoneRules.NullIfEmpty(phone),
                    AltPhone: PhoneRules.NullIfEmpty(altPhone),
                    Gender: NullIfEmpty(GetValue(values,"gender")),
                    DateOfBirth: ParseDate(GetValue(values,"dateofbirth")),
                    Address: NullIfEmpty(GetValue(values,"address")),
                    EmergencyContact: PhoneRules.NullIfEmpty(GetValue(values,"emergencycontact")) ?? NullIfEmpty(GetValue(values,"emergencycontact")),
                    MaritalStatus: NullIfEmpty(GetValue(values,"maritalstatus")),
                    Nationality: NullIfEmpty(nationalityName),
                    NationalityId: nationalityId,
                    DepartmentId: departmentId,
                    DesignationId: designationId,
                    Role: NullIfEmpty(roleName),
                    JobRoleId: jobRoleId,
                    ReportingManagerId: reportingManagerId,
                    BusinessUnit: NullIfEmpty(GetValue(values,"businessunit")),
                    WorkLocation: NullIfEmpty(GetValue(values,"worklocation")),
                    OfficeBranch: NullIfEmpty(GetValue(values,"officebranch")),
                    Category: NullIfEmpty(GetValue(values,"category")),
                    Team: NullIfEmpty(GetValue(values,"team")),
                    JoiningDate: ParseDate(GetValue(values,"joiningdate")),
                    Status: NullIfEmpty(GetValue(values,"status")) ?? "Active",
                    ConfirmationStatus: NullIfEmpty(GetValue(values,"status")) ?? "Active",
                    ProbationStatus: null,
                    Experience: NullIfEmpty(GetValue(values,"experience")),
                    PreviousCompany: NullIfEmpty(GetValue(values,"previouscompany")),
                    EmploymentType: NullIfEmpty(GetValue(values,"employmenttype")),
                    ContractType: null,
                    BondStatus: null,
                    NoticePeriod: null,
                    ProjectSite: null,
                    AssetId: null,
                    ExitType: "NA",
                    ExitReason: "NA",
                    Education: null,
                    Skills: SplitList(GetValue(values,"skills")),
                    Certifications: null,
                    Languages: SplitList(GetValue(values,"languages")),
                    KpiScore: null,
                    QuarterlyKpi: null,
                    AnnualRating: null,
                    GoalCompletion: null,
                    Attendance: null,
                    ReportingEfficiency: null,
                    PromotionReadiness: null,
                    ManagerFeedback: null,
                    Pan: EmployeeIdentityGuard.NormalizePan(GetValue(values,"pan")),
                    BankAccount: NullIfEmpty(GetValue(values,"bankaccount")),
                    SalaryBand: NullIfEmpty(salaryBandName),
                    PfUan: EmployeeIdentityGuard.NormalizeUan(GetValue(values,"uan")),
                    TaxRegime: null,
                    ComplianceStatus: null,
                    SalaryBandId: salaryBandId,
                    ProbationPeriod: null,
                    Aadhaar: EmployeeIdentityGuard.NormalizeAadhaar(GetValue(values,"aadhaar")));

                try
                {
                    var createdEmp = await employees.CreateEmployeeAsync(request, checkIdentity: false, ct);
                    snapshot.Add(identity);
                    created++;
                    managers.Add(new
                    {
                        createdEmp.Id,
                        createdEmp.EmployeeCode,
                        Name = createdEmp.FirstName + " " + createdEmp.LastName,
                    });
                }
                catch (ConflictException ex)
                {
                    errors.Add(new EmployeeBulkRowError(excelRow, NullIfEmpty(code), ex.Message));
                }
                catch (Exception ex)
                {
                    errors.Add(new EmployeeBulkRowError(
                        excelRow, NullIfEmpty(code), ex.InnerException?.Message ?? ex.Message));
                }
            }

            return new EmployeeBulkUploadResult(created, errors.Count, errors);
        }
    }

    private static Dictionary<string, int> ReadHeaders(IXLWorksheet sheet)
    {
        var map = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
        var lastCol = sheet.LastColumnUsed()?.ColumnNumber() ?? 0;
        for (var col = 1; col <= lastCol; col++)
        {
            var key = NormalizeHeader(sheet.Cell(1, col).GetString());
            if (key.Length == 0 || map.ContainsKey(key)) continue;
            map[key] = col;
        }

        if (map.TryGetValue("tkid", out var tkCol)) map.TryAdd("employeecode", tkCol);
        if (map.TryGetValue("employeeid", out var empIdCol)) map.TryAdd("employeecode", empIdCol);
        if (map.TryGetValue("reportingmanagertkid", out var mgrTkCol)) map.TryAdd("reportingmanagercode", mgrTkCol);
        if (map.TryGetValue("reportingmanagerid", out var mgrEmpIdCol)) map.TryAdd("reportingmanagercode", mgrEmpIdCol);
        if (map.TryGetValue("pfuan", out var pfCol)) map.TryAdd("uan", pfCol);
        if (map.TryGetValue("aadhar", out var aadharCol)) map.TryAdd("aadhaar", aadharCol);
        if (map.TryGetValue("mobile", out var mobileCol)) map.TryAdd("phone", mobileCol);
        if (map.TryGetValue("altphone", out var altCol)) map.TryAdd("alternatephone", altCol);
        if (map.TryGetValue("reportingmanager", out var mgrCol)) map.TryAdd("reportingmanagercode", mgrCol);
        return map;
    }

    private static Dictionary<string, string> ReadRow(IXLRow row, Dictionary<string, int> headerMap)
    {
        var values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var (key, col) in headerMap)
            values[key] = ReadCell(row.Cell(col));
        return values;
    }

    private static string ReadCell(IXLCell cell)
    {
        if (cell.IsEmpty()) return "";
        if (cell.DataType == XLDataType.DateTime)
            return cell.GetDateTime().ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        if (cell.DataType == XLDataType.Number)
        {
            if (cell.TryGetValue(out DateTime dateTime) && dateTime.Year > 1900)
                return dateTime.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            return cell.GetDouble().ToString("0", CultureInfo.InvariantCulture);
        }

        return cell.GetString().Trim();
    }

    private static string NormalizeHeader(string raw)
    {
        var chars = raw.Trim().ToLowerInvariant()
            .Replace("pf/uan", "uan", StringComparison.Ordinal)
            .Replace("pf uan", "uan", StringComparison.Ordinal)
            .Where(c => char.IsAsciiLetterOrDigit(c))
            .ToArray();
        return new string(chars);
    }

    private static string GetValue(Dictionary<string, string> values, string key) =>
        values.TryGetValue(key, out var value) ? value.Trim() : "";

    private static string? NullIfEmpty(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    private static DateOnly? ParseDate(string raw)
    {
        if (string.IsNullOrWhiteSpace(raw)) return null;
        if (DateOnly.TryParse(raw, CultureInfo.InvariantCulture, DateTimeStyles.None, out var date))
            return date;
        if (DateTime.TryParse(raw, CultureInfo.InvariantCulture, DateTimeStyles.None, out var dateTime))
            return DateOnly.FromDateTime(dateTime);
        return null;
    }

    private static List<string>? SplitList(string raw)
    {
        if (string.IsNullOrWhiteSpace(raw)) return null;
        var items = raw.Split(',', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries)
            .ToList();
        return items.Count == 0 ? null : items;
    }
}
