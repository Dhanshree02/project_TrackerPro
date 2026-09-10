using System.Globalization;
using ClosedXML.Excel;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Resources.DTOs;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Resources.Validators;
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
        "Marital Status",
        "Address",
        "Emergency Contact Name",
        "Emergency Contact Number",
        "Emergency Contact Relation",
        "Nationality",
        "Department",
        "Designation",
        "Role",
        "Reporting Manager Code",
        "Business Unit",
        "Work Location",
        "Location (Onsite)",
        "Joining Date",
        "Employee Status",
        "Worker Type",
        "Bond Delivered",
        "Bond Duration (Months)",
        "Bond Expiry Date",
        "Previous Company",
        "PAN",
        "Aadhaar",
        "UAN",
        "Bank Account",
        "Salary Band",
        "Highest Qualification",
        "Graduation Passing Year",
        "Post Graduation Degree",
        "Post Graduation Passing Year",
        "Experience Type",
        "Prior Total Exp (Years)",
        "Prior Total Exp (Months)",
        "Prior Relevant Exp (Years)",
        "Prior Relevant Exp (Months)",
        "Skills",
        "Certifications",
        "Languages",
        "PMO Department",
        "Sub Department",
        "Billable Status",
        "Client Location",
        "Project Type",
        "Project Allocated",
        "Client Engagement Manager",
    ];

    public static async Task<byte[]> BuildSampleAsync(AppDbContext db, CancellationToken ct = default)
    {
        // 1. Fetch live master options from database
        var departments = await db.Departments
            .Where(d => d.DeletedAtUtc == null && d.IsActive)
            .OrderBy(d => d.Name)
            .Select(d => d.Name)
            .ToListAsync(ct);

        var designations = await db.Designations
            .Where(d => d.DeletedAtUtc == null && d.IsActive)
            .OrderBy(d => d.Name)
            .Select(d => d.Name)
            .ToListAsync(ct);

        var roles = await db.JobRoles
            .Where(r => r.DeletedAtUtc == null && r.IsActive)
            .OrderBy(r => r.Name)
            .Select(r => r.Name)
            .ToListAsync(ct);

        var workLocations = await db.WorkLocations
            .Where(w => w.DeletedAtUtc == null && w.IsActive)
            .OrderBy(w => w.SortOrder).ThenBy(w => w.Name)
            .Select(w => w.Name)
            .ToListAsync(ct);
        if (workLocations.Count == 0)
            workLocations = ["Suvidha Square, Andheri", "Navare Plaza, Dombivli", "Onsite"];

        var businessUnits = await db.BusinessUnits
            .Where(b => b.DeletedAtUtc == null && b.IsActive)
            .OrderBy(b => b.Name)
            .Select(b => b.Name)
            .ToListAsync(ct);
        if (businessUnits.Count == 0)
            businessUnits = ["Talakunchi Networks Private Limited"];

        var employeeStatuses = await db.EmployeeStatuses
            .Where(s => s.DeletedAtUtc == null && s.IsActive)
            .OrderBy(s => s.SortOrder).ThenBy(s => s.Name)
            .Select(s => s.Name)
            .ToListAsync(ct);
        if (employeeStatuses.Count == 0)
            employeeStatuses = ["Active", "Terminated", "Absconded", "Resigned", "Resignation Under Review"];

        var gradDegrees = await db.GraduationDegrees
            .Where(g => g.DeletedAtUtc == null && g.IsActive)
            .OrderBy(g => g.Name)
            .Select(g => g.Name)
            .ToListAsync(ct);
        if (gradDegrees.Count == 0)
            gradDegrees = ["BE", "B.Tech", "B.Sc", "BCA", "B.Com", "BBA", "BA"];

        var postGradDegrees = await db.PostGraduationDegrees
            .Where(p => p.DeletedAtUtc == null && p.IsActive)
            .OrderBy(p => p.Name)
            .Select(p => p.Name)
            .ToListAsync(ct);
        if (postGradDegrees.Count == 0)
            postGradDegrees = ["NA", "M.Tech", "ME", "M.Sc", "MCA", "M.Com", "MBA"];

        var salaryBands = await db.SalaryBands
            .Where(s => s.DeletedAtUtc == null && s.IsActive)
            .OrderBy(s => s.Name)
            .Select(s => s.Name)
            .ToListAsync(ct);
        if (salaryBands.Count == 0)
            salaryBands = ["L1", "L2", "L3", "L4", "L5"];

        var nationalities = await db.Nationalities
            .Where(n => n.DeletedAtUtc == null && n.IsActive)
            .OrderBy(n => n.Name)
            .Select(n => n.Name)
            .ToListAsync(ct);
        if (nationalities.Count == 0)
            nationalities = ["Indian"];

        var managerCodes = await db.Employees
            .Where(e => e.DeletedAtUtc == null && !string.IsNullOrEmpty(e.EmployeeCode))
            .OrderBy(e => e.EmployeeCode)
            .Select(e => e.EmployeeCode)
            .ToListAsync(ct);
        if (managerCodes.Count == 0)
            managerCodes = ["TK-0001"];

        // Fixed categorical options matching frontend options
        string[] genders = ["Male", "Female", "Other"];
        string[] maritalStatuses = ["Single", "Married", "Divorced", "Widowed"];
        string[] emergencyRelations = ["Father", "Mother", "Spouse", "Sibling", "Guardian", "Friend", "Other"];
        string[] workerTypes = ["Permanent", "Intern", "Contract"];
        string[] bondDeliveredOptions = ["Yes", "No"];
        string[] bondDurationOptions = ["0", "12", "24", "36"];
        string[] expTypes = ["Fresher", "Experienced"];
        string[] pmoDepartments =
        [
            "Core",
            "Functional - Accounts",
            "Functional - HR",
            "Functional - IT Admin",
            "Functional - Sales",
            "PMO",
            "R&D",
            "Services - Consulting",
            "Services - Operations",
            "Services - Testing",
        ];
        string[] billableStatuses = ["Billable", "Non-Billable"];
        string[] projectTypes = ["Long Term", "Short Term", "Internal", "POC"];

        using var workbook = new XLWorkbook();

        // ── Sheet 1: Employees ──
        var sheet = workbook.Worksheets.Add("Employees");
        for (var i = 0; i < Headers.Length; i++)
        {
            var cell = sheet.Cell(1, i + 1);
            cell.Value = Headers[i];
            cell.Style.Font.Bold = true;
            cell.Style.Fill.BackgroundColor = XLColor.FromHtml("#DBEAFE");
            cell.Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
            cell.Style.Border.OutsideBorderColor = XLColor.FromHtml("#BFDBFE");
        }

        // Example data row
        var example = new[]
        {
            "TK-9999",                                                // 1. TK ID
            "Sample",                                                 // 2. First Name
            "Employee",                                               // 3. Last Name
            "sample.employee@talakunchi.com",                         // 4. Work Email
            "sample.personal@gmail.com",                              // 5. Personal Email
            "9820099999",                                             // 6. Phone
            "9820099998",                                             // 7. Alternate Phone
            "Female",                                                 // 8. Gender
            "1995-06-15",                                             // 9. Date of Birth
            "Single",                                                 // 10. Marital Status
            "Suvidha Square, Andheri East, Mumbai",                   // 11. Address
            "Sanjay Employee",                                        // 12. Emergency Contact Name
            "9811099999",                                             // 13. Emergency Contact Number
            "Father",                                                 // 14. Emergency Contact Relation
            "Indian",                                                 // 15. Nationality
            departments.FirstOrDefault() ?? "Services - Testing",     // 16. Department
            designations.FirstOrDefault() ?? "PenTester - I",         // 17. Designation
            roles.FirstOrDefault() ?? "Employee",                     // 18. Role
            managerCodes.FirstOrDefault() ?? "TK-0001",               // 19. Reporting Manager Code
            businessUnits.FirstOrDefault() ?? "Talakunchi Networks Private Limited", // 20. Business Unit
            workLocations.FirstOrDefault() ?? "Suvidha Square, Andheri",             // 21. Work Location
            "",                                                       // 22. Location (Onsite)
            DateTime.UtcNow.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),    // 23. Joining Date
            "Active",                                                 // 24. Employee Status
            "Permanent",                                              // 25. Worker Type
            "No",                                                     // 26. Bond Delivered
            "0",                                                      // 27. Bond Duration (Months)
            "",                                                       // 28. Bond Expiry Date
            "Tata Consultancy Services",                              // 29. Previous Company
            "ABCDE9999F",                                             // 30. PAN
            "234567899999",                                           // 31. Aadhaar
            "100987659999",                                           // 32. UAN
            "501234569999",                                           // 33. Bank Account
            salaryBands.FirstOrDefault() ?? "L3",                     // 34. Salary Band
            gradDegrees.FirstOrDefault() ?? "B.Tech",                 // 35. Highest Qualification
            "2018",                                                   // 36. Graduation Passing Year
            "NA",                                                     // 37. Post Graduation Degree
            "NA",                                                     // 38. Post Graduation Passing Year
            "Experienced",                                            // 39. Experience Type
            "2",                                                      // 40. Prior Total Exp (Years)
            "6",                                                      // 41. Prior Total Exp (Months)
            "2",                                                      // 42. Prior Relevant Exp (Years)
            "0",                                                      // 43. Prior Relevant Exp (Months)
            "C#, React, SQL",                                         // 44. Skills
            "ISO 27001",                                              // 45. Certifications
            "English, Hindi",                                         // 46. Languages
            "Services - Testing",                                     // 47. PMO Department
            "Services - Testing - AppSec",                            // 48. Sub Department
            "Billable",                                               // 49. Billable Status
            "Andheri",                                                // 50. Client Location
            "Long Term",                                              // 51. Project Type
            "Internal / Bench",                                       // 52. Project Allocated
            "",                                                       // 53. Client Engagement Manager
        };

        for (var i = 0; i < example.Length; i++)
            sheet.Cell(2, i + 1).Value = example[i];

        // ── Sheet 2: Lookups ──
        var lookups = workbook.Worksheets.Add("Lookups");

        int WriteLookupColumn(int col, string header, IReadOnlyList<string> items)
        {
            lookups.Cell(1, col).Value = header;
            lookups.Cell(1, col).Style.Font.Bold = true;
            for (var r = 0; r < items.Count; r++)
                lookups.Cell(r + 2, col).Value = items[r];
            return items.Count;
        }

        var lCol = 1;
        var countGenders = WriteLookupColumn(lCol++, "Gender", genders);
        var countMarital = WriteLookupColumn(lCol++, "MaritalStatus", maritalStatuses);
        var countRelations = WriteLookupColumn(lCol++, "EmergencyRelation", emergencyRelations);
        var countNationalities = WriteLookupColumn(lCol++, "Nationality", nationalities);
        var countDepartments = WriteLookupColumn(lCol++, "Department", departments);
        var countDesignations = WriteLookupColumn(lCol++, "Designation", designations);
        var countRoles = WriteLookupColumn(lCol++, "Role", roles);
        var countManagers = WriteLookupColumn(lCol++, "ReportingManagerCode", managerCodes);
        var countBusinessUnits = WriteLookupColumn(lCol++, "BusinessUnit", businessUnits);
        var countWorkLocations = WriteLookupColumn(lCol++, "WorkLocation", workLocations);
        var countStatuses = WriteLookupColumn(lCol++, "EmployeeStatus", employeeStatuses);
        var countWorkerTypes = WriteLookupColumn(lCol++, "WorkerType", workerTypes);
        var countBondDelivered = WriteLookupColumn(lCol++, "BondDelivered", bondDeliveredOptions);
        var countBondDurations = WriteLookupColumn(lCol++, "BondDurationMonths", bondDurationOptions);
        var countSalaryBands = WriteLookupColumn(lCol++, "SalaryBand", salaryBands);
        var countGradDegrees = WriteLookupColumn(lCol++, "GraduationDegree", gradDegrees);
        var countPostGradDegrees = WriteLookupColumn(lCol++, "PostGraduationDegree", postGradDegrees);
        var countExpTypes = WriteLookupColumn(lCol++, "ExperienceType", expTypes);
        var countPmoDepts = WriteLookupColumn(lCol++, "PmoDepartment", pmoDepartments);
        var countBillable = WriteLookupColumn(lCol++, "BillableStatus", billableStatuses);
        var countProjectTypes = WriteLookupColumn(lCol++, "ProjectType", projectTypes);

        lookups.Columns().AdjustToContents();

        // ── Apply Data Validations with Stop Style (Must pick from dropdown only) ──
        void SetListValidation(int targetCol, int lookupCol, int count, string fieldName)
        {
            if (count <= 0) return;
            var colLetter = lookups.Column(lookupCol).ColumnLetter();
            var range = sheet.Range(2, targetCol, MaxRows, targetCol);
            var validation = range.CreateDataValidation();
            validation.List($"=Lookups!${colLetter}$2:${colLetter}${count + 1}", true);
            validation.ErrorStyle = XLErrorStyle.Stop;
            validation.ErrorTitle = $"Invalid {fieldName}";
            validation.ErrorMessage = $"Please select a valid {fieldName} from the dropdown list.";
            validation.ShowErrorMessage = true;
            validation.ShowInputMessage = true;
            validation.InputTitle = fieldName;
            validation.InputMessage = $"Choose {fieldName} from the list.";
        }

        SetListValidation(8, 1, countGenders, "Gender");
        SetListValidation(10, 2, countMarital, "Marital Status");
        SetListValidation(14, 3, countRelations, "Emergency Contact Relation");
        SetListValidation(15, 4, countNationalities, "Nationality");
        SetListValidation(16, 5, countDepartments, "Department");
        SetListValidation(17, 6, countDesignations, "Designation");
        SetListValidation(18, 7, countRoles, "Role");
        SetListValidation(19, 8, countManagers, "Reporting Manager Code");
        SetListValidation(20, 9, countBusinessUnits, "Business Unit");
        SetListValidation(21, 10, countWorkLocations, "Work Location");
        SetListValidation(24, 11, countStatuses, "Employee Status");
        SetListValidation(25, 12, countWorkerTypes, "Worker Type");
        SetListValidation(26, 13, countBondDelivered, "Bond Delivered");
        SetListValidation(27, 14, countBondDurations, "Bond Duration (Months)");
        SetListValidation(34, 15, countSalaryBands, "Salary Band");
        SetListValidation(35, 16, countGradDegrees, "Highest Qualification");
        SetListValidation(37, 17, countPostGradDegrees, "Post Graduation Degree");
        SetListValidation(39, 18, countExpTypes, "Experience Type");
        SetListValidation(47, 19, countPmoDepts, "PMO Department");
        SetListValidation(49, 20, countBillable, "Billable Status");
        SetListValidation(51, 21, countProjectTypes, "Project Type");

        sheet.SheetView.FreezeRows(1);
        sheet.Range(1, 1, 1, Headers.Length).SetAutoFilter();
        sheet.Columns().AdjustToContents(1, 40);

        // ── Sheet 3: Instructions ──
        var notes = workbook.Worksheets.Add("Instructions");
        notes.Cell(1, 1).Value = "How to use this Bulk Upload Template";
        notes.Cell(1, 1).Style.Font.Bold = true;
        notes.Cell(1, 1).Style.Font.FontSize = 14;

        string[] instructions =
        [
            "1. Keep the header row exactly as provided on the Employees sheet. Do not rename or reorder columns.",
            "2. Upload .xlsx files only. Other file formats are rejected.",
            "3. Required fields: TK ID, First Name, Last Name, Work Email.",
            "4. Dropdown fields: Cells with drop-down validation restrict input to allowed master values. In Excel, select directly from the drop-down menu.",
            "5. Dynamic Master Values: The Lookups sheet reflects live masters from the system. When new options are added in settings/masters, downloading a fresh template reflects them immediately.",
            "6. Unique Constraints: Work Email, Personal Email, Phone, Alternate Phone, PAN, Aadhaar, and UAN must be unique across all existing records in TrackerPro.",
            "7. Date Format: Dates must be formatted as YYYY-MM-DD (e.g. 1995-06-15).",
            "8. Phone Numbers: Must be valid 10-digit mobile numbers without country code prefix.",
            "9. Experience: If Prior Total / Relevant Exp Years and Months are provided, they will be formatted automatically (e.g. '2 yrs 6 mos').",
            "10. Up to 500 rows can be imported in a single upload file.",
        ];

        for (var i = 0; i < instructions.Length; i++)
        {
            notes.Cell(i + 3, 1).Value = instructions[i];
            notes.Cell(i + 3, 1).Style.Font.FontSize = 11;
        }

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
                    !w.Name.Equals("Instructions", StringComparison.OrdinalIgnoreCase)
                    && !w.Name.Equals("Lookups", StringComparison.OrdinalIgnoreCase))
                ?? workbook.Worksheets.FirstOrDefault()
                ?? throw new ConflictException("The Excel file has no worksheets.");

            var headerMap = ReadHeaders(sheet);
            if (!headerMap.ContainsKey("employeecode")
                || !headerMap.ContainsKey("firstname")
                || !headerMap.ContainsKey("lastname")
                || !headerMap.ContainsKey("workemail"))
            {
                throw new ConflictException(
                    "The Excel file is missing required columns: TK ID, First Name, Last Name, Work Email. Download the sample and try again.");
            }

            var lastRow = sheet.LastRowUsed()?.RowNumber() ?? 1;
            if (lastRow < 2)
                return new EmployeeBulkUploadResult(0, 0, []);

            var departments = await db.Departments.ToListAsync(ct);
            var designations = await db.Designations.ToListAsync(ct);
            var roles = await db.JobRoles.ToListAsync(ct);
            var nationalities = await db.Nationalities.ToListAsync(ct);
            var salaryBands = await db.SalaryBands.ToListAsync(ct);
            var employeeStatuses = await db.EmployeeStatuses.ToListAsync(ct);
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
                if (string.IsNullOrWhiteSpace(code)) rowErrors.Add("TK ID is required.");
                else if (!EmployeeCodeRules.IsValid(code)) rowErrors.Add(EmployeeCodeRules.FormatMessage + ".");
                if (string.IsNullOrWhiteSpace(firstName)) rowErrors.Add("First Name is required.");
                if (string.IsNullOrWhiteSpace(lastName)) rowErrors.Add("Last Name is required.");
                if (string.IsNullOrWhiteSpace(workEmail)) rowErrors.Add("Work Email is required.");
                else if (!EmailRules.IsValid(workEmail)) rowErrors.Add("Work Email is not a valid email address.");

                var personalEmail = GetValue(values, "personalemail");
                if (!string.IsNullOrWhiteSpace(personalEmail) && !EmailRules.IsValid(personalEmail))
                    rowErrors.Add("Personal Email is not a valid email address.");

                var phone = GetValue(values, "phone");
                if (!string.IsNullOrWhiteSpace(phone) && !PhoneRules.IsValid(phone))
                    rowErrors.Add("Phone must be a valid 10-digit Indian mobile number.");
                var altPhone = GetValue(values, "alternatephone");
                if (!string.IsNullOrWhiteSpace(altPhone) && !PhoneRules.IsValid(altPhone))
                    rowErrors.Add("Alternate Phone must be a valid 10-digit Indian mobile number.");

                var identity = new EmployeeIdentity(
                    code,
                    EmployeeIdentityGuard.NormalizeEmail(workEmail),
                    EmployeeIdentityGuard.NormalizeEmail(personalEmail),
                    PhoneRules.NullIfEmpty(phone),
                    PhoneRules.NullIfEmpty(altPhone),
                    EmployeeIdentityGuard.NormalizePan(GetValue(values, "pan")),
                    EmployeeIdentityGuard.NormalizeAadhaar(GetValue(values, "aadhaar")),
                    EmployeeIdentityGuard.NormalizeUan(GetValue(values, "uan")));

                rowErrors.AddRange(snapshot.Conflicts(identity));

                Guid? departmentId = null;
                var departmentName = GetValue(values, "department");
                if (!string.IsNullOrWhiteSpace(departmentName))
                {
                    var dept = departments.FirstOrDefault(d =>
                        d.Name.Equals(departmentName, StringComparison.OrdinalIgnoreCase));
                    if (dept is null) rowErrors.Add($"Department '{departmentName}' was not found.");
                    else departmentId = dept.Id;
                }

                Guid? designationId = null;
                var designationName = GetValue(values, "designation");
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
                var roleName = GetValue(values, "role");
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
                var nationalityName = GetValue(values, "nationality");
                if (!string.IsNullOrWhiteSpace(nationalityName))
                {
                    var nationality = nationalities.FirstOrDefault(n =>
                        n.Name.Equals(nationalityName, StringComparison.OrdinalIgnoreCase));
                    if (nationality is null) rowErrors.Add($"Nationality '{nationalityName}' was not found.");
                    else nationalityId = nationality.Id;
                }

                Guid? salaryBandId = null;
                var salaryBandName = GetValue(values, "salaryband");
                if (!string.IsNullOrWhiteSpace(salaryBandName))
                {
                    var band = salaryBands.FirstOrDefault(b =>
                        b.Name.Equals(salaryBandName, StringComparison.OrdinalIgnoreCase));
                    if (band is null) rowErrors.Add($"Salary Band '{salaryBandName}' was not found.");
                    else salaryBandId = band.Id;
                }

                Guid? reportingManagerId = null;
                var managerCode = GetValue(values, "reportingmanagercode");
                if (!string.IsNullOrWhiteSpace(managerCode))
                {
                    var manager = managers.FirstOrDefault(m =>
                        m.EmployeeCode.Equals(managerCode, StringComparison.OrdinalIgnoreCase)
                        || m.Name.Equals(managerCode, StringComparison.OrdinalIgnoreCase)
                        || $"{m.EmployeeCode} - {m.Name}".Equals(managerCode, StringComparison.OrdinalIgnoreCase));
                    if (manager is null) rowErrors.Add($"Reporting manager '{managerCode}' was not found.");
                    else reportingManagerId = manager.Id;
                }

                Guid? employeeStatusId = null;
                var statusName = GetValue(values, "status");
                if (!string.IsNullOrWhiteSpace(statusName))
                {
                    var st = employeeStatuses.FirstOrDefault(s =>
                        s.Name.Equals(statusName, StringComparison.OrdinalIgnoreCase));
                    if (st is not null) employeeStatusId = st.Id;
                }

                if (rowErrors.Count > 0)
                {
                    errors.Add(new EmployeeBulkRowError(excelRow, NullIfEmpty(code), string.Join(" ", rowErrors)));
                    continue;
                }

                // Experience mapping
                var totalYearsStr = GetValue(values, "priortotalexpyears");
                var totalMonthsStr = GetValue(values, "priortotalexpmonths");
                var relYearsStr = GetValue(values, "priorrelevantexpyears");
                var relMonthsStr = GetValue(values, "priorrelevantexpmonths");

                string? priorTotalExp = null;
                if (!string.IsNullOrWhiteSpace(totalYearsStr) || !string.IsNullOrWhiteSpace(totalMonthsStr))
                {
                    var y = int.TryParse(totalYearsStr, out var ty) ? ty : 0;
                    var m = int.TryParse(totalMonthsStr, out var tm) ? tm : 0;
                    priorTotalExp = (y == 0 && m == 0) ? "Fresher" : $"{y} yrs {m} mos";
                }
                else
                {
                    priorTotalExp = NullIfEmpty(GetValue(values, "experience"));
                }

                string? priorRelevantExp = null;
                if (!string.IsNullOrWhiteSpace(relYearsStr) || !string.IsNullOrWhiteSpace(relMonthsStr))
                {
                    var ry = int.TryParse(relYearsStr, out var rty) ? rty : 0;
                    var rm = int.TryParse(relMonthsStr, out var rtm) ? rtm : 0;
                    priorRelevantExp = (ry == 0 && rm == 0) ? "Fresher" : $"{ry} yrs {rm} mos";
                }

                var expType = NullIfEmpty(GetValue(values, "exptype"));
                if (string.IsNullOrWhiteSpace(expType))
                {
                    expType = (priorTotalExp == "Fresher" || string.IsNullOrWhiteSpace(priorTotalExp)) ? "Fresher" : "Experienced";
                }

                // Worker Type & Bond mapping
                var workerType = NullIfEmpty(GetValue(values, "workertype")) ?? "Permanent";
                var bondDelivered = NullIfEmpty(GetValue(values, "bonddelivered")) ?? "No";
                var bondDurationStr = GetValue(values, "bonddurationmonths");
                int? bondDurationMonths = int.TryParse(bondDurationStr, out var bdm) ? bdm : (bondDelivered == "Yes" ? 24 : 0);
                var bondExpiryDate = ParseDate(GetValue(values, "bondexpirydate"));
                var bondStatus = bondDelivered == "Yes" ? "Active" : "No";
                var category = workerType == "Permanent"
                    ? (bondDelivered == "Yes" ? "Permanent - Bond" : "Permanent - Without Bond")
                    : workerType;

                var request = new CreateEmployeeRequest(
                    EmployeeCode: code.Trim(),
                    FirstName: firstName.Trim(),
                    LastName: lastName.Trim(),
                    WorkEmail: workEmail.Trim(),
                    PersonalEmail: NullIfEmpty(personalEmail),
                    Phone: PhoneRules.NullIfEmpty(phone),
                    AltPhone: PhoneRules.NullIfEmpty(altPhone),
                    Gender: NullIfEmpty(GetValue(values, "gender")),
                    DateOfBirth: ParseDate(GetValue(values, "dateofbirth")),
                    Address: NullIfEmpty(GetValue(values, "address")),
                    EmergencyContact: PhoneRules.NullIfEmpty(GetValue(values, "emergencycontact")),
                    EmergencyContactName: NullIfEmpty(GetValue(values, "emergencycontactname")),
                    MaritalStatus: NullIfEmpty(GetValue(values, "maritalstatus")),
                    Nationality: NullIfEmpty(nationalityName),
                    NationalityId: nationalityId,
                    DepartmentId: departmentId,
                    DesignationId: designationId,
                    Role: NullIfEmpty(roleName),
                    JobRoleId: jobRoleId,
                    ReportingManagerId: reportingManagerId,
                    BusinessUnit: NullIfEmpty(GetValue(values, "businessunit")),
                    WorkLocation: NullIfEmpty(GetValue(values, "worklocation")),
                    OfficeBranch: null,
                    Category: category,
                    Team: NullIfEmpty(GetValue(values, "team")),
                    JoiningDate: ParseDate(GetValue(values, "joiningdate")),
                    Status: NullIfEmpty(statusName) ?? "Active",
                    ConfirmationStatus: NullIfEmpty(statusName) ?? "Active",
                    ProbationStatus: null,
                    Experience: priorTotalExp,
                    PreviousCompany: NullIfEmpty(GetValue(values, "previouscompany")),
                    EmploymentType: workerType,
                    ContractType: null,
                    BondStatus: bondStatus,
                    NoticePeriod: null,
                    ProjectSite: NullIfEmpty(GetValue(values, "projectsite")),
                    AssetId: null,
                    ExitType: "NA",
                    ExitReason: "NA",
                    Education: null,
                    Skills: SplitList(GetValue(values, "skills")),
                    Certifications: SplitList(GetValue(values, "certifications")),
                    Languages: SplitList(GetValue(values, "languages")),
                    KpiScore: null,
                    QuarterlyKpi: null,
                    AnnualRating: null,
                    GoalCompletion: null,
                    Attendance: null,
                    ReportingEfficiency: null,
                    PromotionReadiness: null,
                    ManagerFeedback: null,
                    Pan: EmployeeIdentityGuard.NormalizePan(GetValue(values, "pan")),
                    BankAccount: NullIfEmpty(GetValue(values, "bankaccount")),
                    SalaryBand: NullIfEmpty(salaryBandName),
                    PfUan: EmployeeIdentityGuard.NormalizeUan(GetValue(values, "uan")),
                    TaxRegime: null,
                    ComplianceStatus: null,
                    SalaryBandId: salaryBandId,
                    ProbationPeriod: null,
                    Aadhaar: EmployeeIdentityGuard.NormalizeAadhaar(GetValue(values, "aadhaar")),
                    EmployeeStatusId: employeeStatusId,
                    BondDelivered: bondDelivered,
                    BondDurationMonths: bondDurationMonths,
                    BondExpiryDate: bondExpiryDate,
                    EmergencyContactRelation: NullIfEmpty(GetValue(values, "emergencycontactrelation")),
                    PmoDepartment: NullIfEmpty(GetValue(values, "pmodepartment")),
                    SubDepartment: NullIfEmpty(GetValue(values, "subdepartment")),
                    BillableStatus: NullIfEmpty(GetValue(values, "billablestatus")),
                    ClientLocation: NullIfEmpty(GetValue(values, "clientlocation")),
                    ProjectType: NullIfEmpty(GetValue(values, "projecttype")),
                    ProjectAllocated: NullIfEmpty(GetValue(values, "projectallocated")),
                    ClientEngManagerMapping: NullIfEmpty(GetValue(values, "clientengmanagermapping")),
                    GradDegree: NullIfEmpty(GetValue(values, "graddegree")),
                    GradYear: NullIfEmpty(GetValue(values, "gradyear")),
                    PostGradDegree: NullIfEmpty(GetValue(values, "postgraddegree")),
                    PostGradYear: NullIfEmpty(GetValue(values, "postgradyear")),
                    ExpType: expType,
                    PriorTotalExp: priorTotalExp,
                    PriorRelevantExp: priorRelevantExp);

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

        // Aliases for robustness across different template versions
        if (map.TryGetValue("tkid", out var tkCol)) map.TryAdd("employeecode", tkCol);
        if (map.TryGetValue("employeeid", out var empIdCol)) map.TryAdd("employeecode", empIdCol);
        if (map.TryGetValue("reportingmanagertkid", out var mgrTkCol)) map.TryAdd("reportingmanagercode", mgrTkCol);
        if (map.TryGetValue("reportingmanagerid", out var mgrEmpIdCol)) map.TryAdd("reportingmanagercode", mgrEmpIdCol);
        if (map.TryGetValue("reportingmanager", out var mgrCol)) map.TryAdd("reportingmanagercode", mgrCol);
        if (map.TryGetValue("pfuan", out var pfCol)) map.TryAdd("uan", pfCol);
        if (map.TryGetValue("aadhar", out var aadharCol)) map.TryAdd("aadhaar", aadharCol);
        if (map.TryGetValue("mobile", out var mobileCol)) map.TryAdd("phone", mobileCol);
        if (map.TryGetValue("altphone", out var altCol)) map.TryAdd("alternatephone", altCol);
        if (map.TryGetValue("onfloorrole", out var onFloorCol)) map.TryAdd("role", onFloorCol);
        if (map.TryGetValue("locationonsite", out var locOnsiteCol)) map.TryAdd("projectsite", locOnsiteCol);
        if (map.TryGetValue("onsitelocation", out var onsiteCol)) map.TryAdd("projectsite", onsiteCol);
        if (map.TryGetValue("employeestatus", out var empStatusCol)) map.TryAdd("status", empStatusCol);
        if (map.TryGetValue("bondduration", out var bdCol)) map.TryAdd("bonddurationmonths", bdCol);
        if (map.TryGetValue("highestqualification", out var hqCol)) map.TryAdd("graddegree", hqCol);
        if (map.TryGetValue("graduationdegree", out var gdCol)) map.TryAdd("graddegree", gdCol);
        if (map.TryGetValue("graduationpassingyear", out var gpyCol)) map.TryAdd("gradyear", gpyCol);
        if (map.TryGetValue("graduationyear", out var gyCol)) map.TryAdd("gradyear", gyCol);
        if (map.TryGetValue("postgraduationpassingyear", out var pgpyCol)) map.TryAdd("postgradyear", pgpyCol);
        if (map.TryGetValue("postgraduationyear", out var pgyCol)) map.TryAdd("postgradyear", pgyCol);
        if (map.TryGetValue("experiencetype", out var etCol)) map.TryAdd("exptype", etCol);
        if (map.TryGetValue("totalexpyears", out var teyCol)) map.TryAdd("priortotalexpyears", teyCol);
        if (map.TryGetValue("totalexpmonths", out var temCol)) map.TryAdd("priortotalexpmonths", temCol);
        if (map.TryGetValue("totalexperienceyears", out var tey2Col)) map.TryAdd("priortotalexpyears", tey2Col);
        if (map.TryGetValue("totalexperiencemonths", out var tem2Col)) map.TryAdd("priortotalexpmonths", tem2Col);
        if (map.TryGetValue("relevantexpyears", out var reyCol)) map.TryAdd("priorrelevantexpyears", reyCol);
        if (map.TryGetValue("relevantexpmonths", out var remCol)) map.TryAdd("priorrelevantexpmonths", remCol);
        if (map.TryGetValue("relevantexperienceyears", out var rey2Col)) map.TryAdd("priorrelevantexpyears", rey2Col);
        if (map.TryGetValue("relevantexperiencemonths", out var rem2Col)) map.TryAdd("priorrelevantexpmonths", rem2Col);
        if (map.TryGetValue("emergencycontactnumber", out var ecnCol)) map.TryAdd("emergencycontact", ecnCol);
        if (map.TryGetValue("emergencycontactphone", out var ecpCol)) map.TryAdd("emergencycontact", ecpCol);
        if (map.TryGetValue("emergencyrelation", out var erCol)) map.TryAdd("emergencycontactrelation", erCol);
        if (map.TryGetValue("clientengagementmanager", out var cemCol)) map.TryAdd("clientengmanagermapping", cemCol);

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
