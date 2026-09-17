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

    /// <summary>
    /// Exact 35 fields present in Sections 1–4 of the Employee Onboarding Form.
    /// Excludes PMO section (Section 5) and non-onboarding profile fields.
    /// </summary>
    public static readonly string[] Headers =
    [
        "TK ID",                           // 1
        "First Name",                      // 2
        "Last Name",                       // 3
        "Work Email",                      // 4
        "Phone (Personal)",                // 5
        "Alternate Contact Number",        // 6
        "Current Address - City",          // 7  (Dropdown: Mumbai Stations)
        "Emergency Contact Name",          // 8
        "Emergency Contact Number",        // 9
        "Relation with Emergency Contact", // 10 (Dropdown: Emergency Relations)
        "Department",                      // 11 (Dropdown: Live db.Departments)
        "Designation",                     // 12 (Dropdown: Live db.Designations)
        "On Floor Role",                   // 13 (Dropdown: Live db.JobRoles)
        "Business Unit",                   // 14 (Dropdown: Live db.BusinessUnits)
        "Reporting Manager Code",          // 15 (Dropdown: Live manager codes)
        "Work Location",                   // 16 (Dropdown: Live db.WorkLocations)
        "Location (Onsite)",               // 17
        "Date of Joining",                 // 18
        "Asset ID",                        // 19
        "Employee Status",                 // 20 (Dropdown: Live db.EmployeeStatuses)
        "Worker Type",                     // 21 (Dropdown: Worker Types)
        "Bond Delivered",                  // 22 (Dropdown: Yes / No)
        "Bond Duration (Months)",          // 23 (Dropdown: 0, 12, 24, 36)
        "Bond Expiry Date",                // 24
        "Bond Status",                     // 25 (Dropdown: Active, Completed, No Bond)
        "Graduation Degree Name",          // 26 (Dropdown: Live db.GraduationDegrees)
        "Graduation - Passing Year",       // 27 (Dropdown: Passing Years)
        "Post Graduation Degree Name",     // 28 (Dropdown: Live db.PostGraduationDegrees + NA)
        "Post Graduation - Passing Year",  // 29 (Dropdown: NA + Passing Years)
        "Exp / Fresher",                   // 30 (Dropdown: Fresher / Experienced)
        "Prior Total Exp (Years)",         // 31
        "Prior Total Exp (Months)",        // 32 (Dropdown: 0..11)
        "Prior Relevant Exp (Years)",      // 33
        "Prior Relevant Exp (Months)",     // 34 (Dropdown: 0..11)
        "Certification Details",           // 35
    ];

    private static readonly string[] MumbaiStations =
    [
        // Western Line
        "Churchgate (Western Line)",
        "Marine Lines (Western Line)",
        "Charni Road (Western Line)",
        "Grant Road (Western Line)",
        "Mumbai Central (Western Line)",
        "Mahalaxmi (Western Line)",
        "Lower Parel (Western Line)",
        "Prabhadevi (Western Line)",
        "Dadar (Western Line)",
        "Matunga Road (Western Line)",
        "Mahim (Western Line)",
        "Bandra (Western Line)",
        "Khar Road (Western Line)",
        "Santacruz (Western Line)",
        "Vile Parle (Western Line)",
        "Andheri (Western Line)",
        "Jogeshwari (Western Line)",
        "Ram Mandir (Western Line)",
        "Goregaon (Western Line)",
        "Malad (Western Line)",
        "Kandivali (Western Line)",
        "Borivali (Western Line)",
        "Dahisar (Western Line)",
        "Mira Road (Western Line)",
        "Bhayandar (Western Line)",
        "Naigaon (Western Line)",
        "Vasai Road (Western Line)",
        "Nallasopara (Western Line)",
        "Virar (Western Line)",
        "Vaitarna (Western Line)",
        "Saphale (Western Line)",
        "Kelve Road (Western Line)",
        "Palghar (Western Line)",
        "Umroli (Western Line)",
        "Boisar (Western Line)",
        "Vangaon (Western Line)",
        "Dahanu Road (Western Line)",
        // Central Line
        "CSMT (Central Line)",
        "Masjid (Central Line)",
        "Sandhurst Road (Central Line)",
        "Byculla (Central Line)",
        "Chinchpokli (Central Line)",
        "Currey Road (Central Line)",
        "Parel (Central Line)",
        "Dadar (Central Line)",
        "Matunga (Central Line)",
        "Sion (Central Line)",
        "Kurla (Central Line)",
        "Vidyavihar (Central Line)",
        "Ghatkopar (Central Line)",
        "Vikhroli (Central Line)",
        "Kanjurmarg (Central Line)",
        "Bhandup (Central Line)",
        "Nahur (Central Line)",
        "Mulund (Central Line)",
        "Thane (Central Line)",
        "Kalwa (Central Line)",
        "Mumbra (Central Line)",
        "Diva (Central Line)",
        "Kopar (Central Line)",
        "Dombivli (Central Line)",
        "Thakurli (Central Line)",
        "Kalyan (Central Line)",
        "Shahad (Central Line)",
        "Ambivli (Central Line)",
        "Titwala (Central Line)",
        "Khadavli (Central Line)",
        "Vasind (Central Line)",
        "Asangaon (Central Line)",
        "Atgaon (Central Line)",
        "Thansit (Central Line)",
        "Khardi (Central Line)",
        "Umbermali (Central Line)",
        "Kasara (Central Line)",
        "Vithalwadi (Central Line)",
        "Ulhasnagar (Central Line)",
        "Ambernath (Central Line)",
        "Badlapur (Central Line)",
        "Vangani (Central Line)",
        "Shelu (Central Line)",
        "Neral (Central Line)",
        "Bhivpuri Road (Central Line)",
        "Karjat (Central Line)",
        "Palasdari (Central Line)",
        "Kelavli (Central Line)",
        "Dolavli (Central Line)",
        "Lowjee (Central Line)",
        "Khopoli (Central Line)",
        // Harbour Line
        "CSMT (Harbour Line)",
        "Masjid (Harbour Line)",
        "Sandhurst Road (Harbour Line)",
        "Dockyard Road (Harbour Line)",
        "Reay Road (Harbour Line)",
        "Cotton Green (Harbour Line)",
        "Sewri (Harbour Line)",
        "Vadala Road (Harbour Line)",
        "Kings Circle (Harbour Line)",
        "GTB Nagar (Harbour Line)",
        "Chunabhatti (Harbour Line)",
        "Kurla (Harbour Line)",
        "Tilak Nagar (Harbour Line)",
        "Chembur (Harbour Line)",
        "Govandi (Harbour Line)",
        "Mankhurd (Harbour Line)",
        "Vashi (Harbour Line)",
        "Sanpada (Harbour Line)",
        "Juinagar (Harbour Line)",
        "Nerul (Harbour Line)",
        "Seawoods-Darave (Harbour Line)",
        "CBD Belapur (Harbour Line)",
        "Kharghar (Harbour Line)",
        "Mansarovar (Harbour Line)",
        "Khandeshwar (Harbour Line)",
        "Panvel (Harbour Line)",
        // Trans-Harbour Line
        "Thane (Trans-Harbour Line)",
        "Digha Gaon (Trans-Harbour Line)",
        "Airoli (Trans-Harbour Line)",
        "Rabale (Trans-Harbour Line)",
        "Ghansoli (Trans-Harbour Line)",
        "Kopar Khairane (Trans-Harbour Line)",
        "Turbhe (Trans-Harbour Line)",
        "Sanpada (Trans-Harbour Line)",
        "Vashi (Trans-Harbour Line)",
        "Juinagar (Trans-Harbour Line)",
        "Nerul (Trans-Harbour Line)",
        "Seawoods-Darave (Trans-Harbour Line)",
        "CBD Belapur (Trans-Harbour Line)",
        "Panvel (Trans-Harbour Line)",
    ];

    public static async Task<byte[]> BuildSampleAsync(AppDbContext db, CancellationToken ct = default)
    {
        // 1. Fetch live master options from database (dynamically reflects any additions in settings/masters)
        var departments = await db.Departments
            .Where(d => d.DeletedAtUtc == null && d.IsActive)
            .OrderBy(d => d.Name)
            .Select(d => d.Name)
            .ToListAsync(ct);
        if (departments.Count == 0)
            departments = ["Services - Testing", "Services - Consulting", "R&D", "PMO", "Core"];

        var designations = await db.Designations
            .Where(d => d.DeletedAtUtc == null && d.IsActive)
            .OrderBy(d => d.Name)
            .Select(d => d.Name)
            .ToListAsync(ct);
        if (designations.Count == 0)
            designations = ["PenTester - I", "Senior PenTester", "Consultant", "Lead"];

        var roles = await db.JobRoles
            .Where(r => r.DeletedAtUtc == null && r.IsActive)
            .OrderBy(r => r.Name)
            .Select(r => r.Name)
            .ToListAsync(ct);
        if (roles.Count == 0)
            roles = ["Employee", "Team Lead", "Project Manager"];

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
            employeeStatuses = ["Active", "Active - Probation", "Terminated", "Absconded", "Resigned", "Resignation Under Review"];

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
        if (!postGradDegrees.Contains("NA", StringComparer.OrdinalIgnoreCase))
            postGradDegrees.Insert(0, "NA");
        if (postGradDegrees.Count == 1)
            postGradDegrees = ["NA", "M.Tech", "ME", "M.Sc", "MCA", "M.Com", "MBA"];

        var managerCodes = await db.Employees
            .Where(e => e.DeletedAtUtc == null && !string.IsNullOrEmpty(e.EmployeeCode))
            .OrderBy(e => e.EmployeeCode)
            .Select(e => e.EmployeeCode)
            .ToListAsync(ct);
        if (managerCodes.Count == 0)
            managerCodes = ["TK-0001"];

        // Fixed categorical options matching onboarding form
        string[] emergencyRelations = ["Father", "Mother", "Spouse", "Sibling", "Guardian", "Friend", "Other"];
        string[] workerTypes = ["Permanent", "Intern", "Contract"];
        string[] bondDeliveredOptions = ["Yes", "No"];
        string[] bondDurationOptions = ["0", "12", "24", "36"];
        string[] bondStatusOptions = ["Active", "Completed", "No Bond"];
        string[] expTypes = ["Fresher", "Experienced"];
        string[] expMonthOptions = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"];

        var currentYear = DateTime.UtcNow.Year;
        var gradYears = Enumerable.Range(0, 55).Select(i => (currentYear - i).ToString(CultureInfo.InvariantCulture)).ToArray();
        var postGradYears = new[] { "NA" }.Concat(gradYears).ToArray();

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

        // Example data row matching all 35 onboarding fields
        var example = new[]
        {
            "TK-9999",                                                // 1. TK ID
            "Sample",                                                 // 2. First Name
            "Employee",                                               // 3. Last Name
            "sample.employee@talakunchi.com",                         // 4. Work Email
            "9820099999",                                             // 5. Phone (Personal)
            "9820099998",                                             // 6. Alternate Contact Number
            "Andheri (Western Line)",                                 // 7. Current Address - City
            "Sanjay Employee",                                        // 8. Emergency Contact Name
            "9811099999",                                             // 9. Emergency Contact Number
            "Father",                                                 // 10. Relation with Emergency Contact
            departments.FirstOrDefault() ?? "Services - Testing",     // 11. Department
            designations.FirstOrDefault() ?? "PenTester - I",         // 12. Designation
            roles.FirstOrDefault() ?? "Employee",                     // 13. On Floor Role
            businessUnits.FirstOrDefault() ?? "Talakunchi Networks Private Limited", // 14. Business Unit
            managerCodes.FirstOrDefault() ?? "TK-0001",               // 15. Reporting Manager Code
            workLocations.FirstOrDefault() ?? "Suvidha Square, Andheri",             // 16. Work Location
            "",                                                       // 17. Location (Onsite)
            DateTime.UtcNow.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),    // 18. Date of Joining
            "AST-1001",                                               // 19. Asset ID
            employeeStatuses.FirstOrDefault() ?? "Active",            // 20. Employee Status
            "Permanent",                                              // 21. Worker Type
            "Yes",                                                    // 22. Bond Delivered
            "24",                                                     // 23. Bond Duration (Months)
            DateTime.UtcNow.AddYears(2).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture), // 24. Bond Expiry Date
            "Active",                                                 // 25. Bond Status
            gradDegrees.FirstOrDefault() ?? "BE",                     // 26. Graduation Degree Name
            "2022",                                                   // 27. Graduation - Passing Year
            "NA",                                                     // 28. Post Graduation Degree Name
            "NA",                                                     // 29. Post Graduation - Passing Year
            "Experienced",                                            // 30. Exp / Fresher
            "2",                                                      // 31. Prior Total Exp (Years)
            "6",                                                      // 32. Prior Total Exp (Months)
            "2",                                                      // 33. Prior Relevant Exp (Years)
            "0",                                                      // 34. Prior Relevant Exp (Months)
            "ISO 27001, CEH",                                         // 35. Certification Details
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
        var countStations = WriteLookupColumn(lCol++, "CurrentAddressCity", MumbaiStations);
        var countRelations = WriteLookupColumn(lCol++, "EmergencyRelation", emergencyRelations);
        var countDepartments = WriteLookupColumn(lCol++, "Department", departments);
        var countDesignations = WriteLookupColumn(lCol++, "Designation", designations);
        var countRoles = WriteLookupColumn(lCol++, "OnFloorRole", roles);
        var countBusinessUnits = WriteLookupColumn(lCol++, "BusinessUnit", businessUnits);
        var countManagers = WriteLookupColumn(lCol++, "ReportingManagerCode", managerCodes);
        var countWorkLocations = WriteLookupColumn(lCol++, "WorkLocation", workLocations);
        var countStatuses = WriteLookupColumn(lCol++, "EmployeeStatus", employeeStatuses);
        var countWorkerTypes = WriteLookupColumn(lCol++, "WorkerType", workerTypes);
        var countBondDelivered = WriteLookupColumn(lCol++, "BondDelivered", bondDeliveredOptions);
        var countBondDurations = WriteLookupColumn(lCol++, "BondDurationMonths", bondDurationOptions);
        var countBondStatuses = WriteLookupColumn(lCol++, "BondStatus", bondStatusOptions);
        var countGradDegrees = WriteLookupColumn(lCol++, "GraduationDegree", gradDegrees);
        var countGradYears = WriteLookupColumn(lCol++, "GraduationPassingYear", gradYears);
        var countPostGradDegrees = WriteLookupColumn(lCol++, "PostGraduationDegree", postGradDegrees);
        var countPostGradYears = WriteLookupColumn(lCol++, "PostGraduationPassingYear", postGradYears);
        var countExpTypes = WriteLookupColumn(lCol++, "ExpFresher", expTypes);
        var countExpMonths = WriteLookupColumn(lCol++, "ExpMonths", expMonthOptions);

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

        // 1. Personal Information dropdowns
        SetListValidation(7, 1, countStations, "Current Address - City");
        SetListValidation(10, 2, countRelations, "Relation with Emergency Contact");

        // 2. Organization Assignment dropdowns
        SetListValidation(11, 3, countDepartments, "Department");
        SetListValidation(12, 4, countDesignations, "Designation");
        SetListValidation(13, 5, countRoles, "On Floor Role");
        SetListValidation(14, 6, countBusinessUnits, "Business Unit");
        SetListValidation(15, 7, countManagers, "Reporting Manager Code");
        SetListValidation(16, 8, countWorkLocations, "Work Location");

        // 3. Employment Information dropdowns
        SetListValidation(20, 9, countStatuses, "Employee Status");
        SetListValidation(21, 10, countWorkerTypes, "Worker Type");
        SetListValidation(22, 11, countBondDelivered, "Bond Delivered");
        SetListValidation(23, 12, countBondDurations, "Bond Duration (Months)");
        SetListValidation(25, 13, countBondStatuses, "Bond Status");

        // 4. Education & Experience dropdowns
        SetListValidation(26, 14, countGradDegrees, "Graduation Degree Name");
        SetListValidation(27, 15, countGradYears, "Graduation - Passing Year");
        SetListValidation(28, 16, countPostGradDegrees, "Post Graduation Degree Name");
        SetListValidation(29, 17, countPostGradYears, "Post Graduation - Passing Year");
        SetListValidation(30, 18, countExpTypes, "Exp / Fresher");
        SetListValidation(32, 19, countExpMonths, "Prior Total Exp (Months)");
        SetListValidation(34, 19, countExpMonths, "Prior Relevant Exp (Months)");

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
            "3. The template strictly reflects the 4 canonical sections of the Onboarding Form (Personal Info, Organization Assignment, Employment Info, Education & Experience).",
            "4. Required fields: TK ID, First Name, Last Name, Work Email, Phone (Personal), Current Address - City, Emergency Contact Name, Emergency Contact Number, Relation with Emergency Contact, Department, Designation, Reporting Manager Code, Work Location, Date of Joining, Employee Status, Worker Type, Bond Delivered, Exp / Fresher.",
            "5. Dropdown validation: Every dropdown column is strictly restricted to its allowed options with ErrorStyle = Stop. Select values directly from the dropdown menu in Excel.",
            "6. Dynamic Master Values: The Lookups sheet reflects live masters from the system (Departments, Designations, Roles, Business Units, Work Locations, Employee Statuses, Degrees, Managers). When new options are added in Settings/Masters, downloading a fresh template reflects them immediately.",
            "7. Date Format: Dates must be formatted as YYYY-MM-DD (e.g. 2026-09-10).",
            "8. Phone Numbers: Must be valid 10-digit mobile numbers without country code prefix.",
            "9. Experience: If Prior Total and Relevant Exp Years and Months are provided, they are formatted automatically (e.g. '2 yrs 6 mos').",
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
                var altPhone = GetValue(values, "altphone");
                if (!string.IsNullOrWhiteSpace(altPhone) && !PhoneRules.IsValid(altPhone))
                    rowErrors.Add("Alternate Phone must be a valid 10-digit Indian mobile number.");

                var identity = new EmployeeIdentity(
                    code,
                    EmployeeIdentityGuard.NormalizeEmail(workEmail),
                    EmployeeIdentityGuard.NormalizeEmail(personalEmail),
                    PhoneRules.NullIfEmpty(phone),
                    PhoneRules.NullIfEmpty(altPhone),
                    null,
                    null,
                    null);

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
                    if (st is not null)
                    {
                        employeeStatusId = st.Id;
                        statusName = st.Name;
                    }
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
                    priorTotalExp = (y == 0 && m == 0) ? "0" : $"{y} yrs {m} mos";
                }

                string? priorRelevantExp = null;
                if (!string.IsNullOrWhiteSpace(relYearsStr) || !string.IsNullOrWhiteSpace(relMonthsStr))
                {
                    var ry = int.TryParse(relYearsStr, out var rty) ? rty : 0;
                    var rm = int.TryParse(relMonthsStr, out var rtm) ? rtm : 0;
                    priorRelevantExp = (ry == 0 && rm == 0) ? "0" : $"{ry} yrs {rm} mos";
                }

                var expType = NullIfEmpty(GetValue(values, "exptype")) ?? "Fresher";
                if (expType == "Fresher")
                {
                    priorTotalExp = "0";
                    priorRelevantExp = "0";
                }

                var experienceString = expType == "Fresher"
                    ? "Fresher"
                    : $"{priorTotalExp ?? "0"} (Relevant: {priorRelevantExp ?? "0"})";

                // Education mapping
                var gradDegree = NullIfEmpty(GetValue(values, "graddegree"));
                var gradYear = NullIfEmpty(GetValue(values, "gradyear"));
                var postGradDegree = NullIfEmpty(GetValue(values, "postgraddegree"));
                var postGradYear = NullIfEmpty(GetValue(values, "postgradyear"));

                string? educationString = null;
                if (!string.IsNullOrWhiteSpace(gradDegree))
                {
                    educationString = gradDegree + (!string.IsNullOrWhiteSpace(gradYear) && gradYear != "NA" ? $" ({gradYear})" : "");
                    if (!string.IsNullOrWhiteSpace(postGradDegree) && postGradDegree != "NA")
                    {
                        educationString += $", {postGradDegree}" + (!string.IsNullOrWhiteSpace(postGradYear) && postGradYear != "NA" ? $" ({postGradYear})" : "");
                    }
                }

                // Worker Type & Bond mapping
                var workerType = NullIfEmpty(GetValue(values, "workertype")) ?? "Permanent";
                var bondDelivered = NullIfEmpty(GetValue(values, "bonddelivered")) ?? "No";
                var bondDurationStr = GetValue(values, "bonddurationmonths");
                int? bondDurationMonths = (bondDelivered == "Yes" && int.TryParse(bondDurationStr, out var bdm))
                    ? bdm
                    : (bondDelivered == "Yes" ? 24 : 0);

                var joiningDate = ParseDate(GetValue(values, "joiningdate"));
                var bondExpiryDate = ParseDate(GetValue(values, "bondexpirydate"));
                if (bondExpiryDate == null && bondDelivered == "Yes" && joiningDate.HasValue && bondDurationMonths > 0)
                {
                    bondExpiryDate = joiningDate.Value.AddMonths(bondDurationMonths.Value);
                }

                var bondStatus = NullIfEmpty(GetValue(values, "bondstatus"));
                if (string.IsNullOrWhiteSpace(bondStatus))
                {
                    if (bondDelivered != "Yes")
                        bondStatus = "No Bond";
                    else if (bondExpiryDate.HasValue && bondExpiryDate.Value < DateOnly.FromDateTime(DateTime.UtcNow))
                        bondStatus = "Completed";
                    else
                        bondStatus = "Active";
                }

                var category = workerType == "Intern"
                    ? "Intern - Paid"
                    : workerType == "Contract"
                        ? "Contract-based"
                        : (bondDelivered == "Yes" ? "Permanent - Bond" : "Permanent - Without Bond");

                var request = new CreateEmployeeRequest(
                    EmployeeCode: code.Trim(),
                    FirstName: firstName.Trim(),
                    LastName: lastName.Trim(),
                    WorkEmail: workEmail.Trim(),
                    PersonalEmail: NullIfEmpty(personalEmail),
                    Phone: PhoneRules.NullIfEmpty(phone),
                    AltPhone: PhoneRules.NullIfEmpty(altPhone),
                    Gender: null,
                    DateOfBirth: null,
                    Address: NullIfEmpty(GetValue(values, "address")),
                    EmergencyContact: PhoneRules.NullIfEmpty(GetValue(values, "emergencycontact")),
                    EmergencyContactName: NullIfEmpty(GetValue(values, "emergencycontactname")),
                    MaritalStatus: null,
                    Nationality: null,
                    NationalityId: null,
                    DepartmentId: departmentId,
                    DesignationId: designationId,
                    Role: NullIfEmpty(roleName),
                    JobRoleId: jobRoleId,
                    ReportingManagerId: reportingManagerId,
                    BusinessUnit: NullIfEmpty(GetValue(values, "businessunit")),
                    WorkLocation: NullIfEmpty(GetValue(values, "worklocation")),
                    OfficeBranch: null,
                    Category: category,
                    Team: null,
                    JoiningDate: joiningDate,
                    Status: NullIfEmpty(statusName) ?? "Active",
                    ConfirmationStatus: NullIfEmpty(statusName) ?? "Active",
                    ProbationStatus: (statusName == "Active - Probation" ? "Ongoing" : "Completed"),
                    Experience: experienceString,
                    PreviousCompany: null,
                    EmploymentType: workerType,
                    ContractType: null,
                    BondStatus: bondStatus,
                    NoticePeriod: null,
                    ProjectSite: NullIfEmpty(GetValue(values, "projectsite")),
                    AssetId: NullIfEmpty(GetValue(values, "assetid")),
                    ExitType: "NA",
                    ExitReason: "NA",
                    Education: educationString,
                    Skills: null,
                    Certifications: SplitList(GetValue(values, "certifications")),
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
                    ComplianceStatus: null,
                    SalaryBandId: null,
                    ProbationPeriod: null,
                    Aadhaar: null,
                    EmployeeStatusId: employeeStatusId,
                    BondDelivered: bondDelivered,
                    BondDurationMonths: bondDurationMonths,
                    BondExpiryDate: bondExpiryDate,
                    EmergencyContactRelation: NullIfEmpty(GetValue(values, "emergencycontactrelation")),
                    PmoDepartment: null,
                    SubDepartment: null,
                    BillableStatus: null,
                    ClientLocation: null,
                    ProjectType: null,
                    ProjectAllocated: null,
                    ClientEngManagerMapping: null,
                    GradDegree: gradDegree,
                    GradYear: gradYear,
                    PostGradDegree: postGradDegree,
                    PostGradYear: postGradYear,
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
        if (map.TryGetValue("phonepersonal", out var ppCol)) map.TryAdd("phone", ppCol);
        if (map.TryGetValue("mobile", out var mobCol)) map.TryAdd("phone", mobCol);
        if (map.TryGetValue("alternatecontactnumber", out var acnCol)) map.TryAdd("altphone", acnCol);
        if (map.TryGetValue("alternatephone", out var altpCol)) map.TryAdd("altphone", altpCol);
        if (map.TryGetValue("altphone", out var altCol)) map.TryAdd("altphone", altCol);
        if (map.TryGetValue("currentaddresscity", out var cacCol)) map.TryAdd("address", cacCol);
        if (map.TryGetValue("currentaddress", out var caCol)) map.TryAdd("address", caCol);
        if (map.TryGetValue("address", out var addrCol)) map.TryAdd("address", addrCol);
        if (map.TryGetValue("city", out var cityCol)) map.TryAdd("address", cityCol);
        if (map.TryGetValue("emergencycontactnumber", out var ecnCol)) map.TryAdd("emergencycontact", ecnCol);
        if (map.TryGetValue("emergencycontactphone", out var ecpCol)) map.TryAdd("emergencycontact", ecpCol);
        if (map.TryGetValue("emergencyphone", out var epCol)) map.TryAdd("emergencycontact", epCol);
        if (map.TryGetValue("relationwithemergencycontact", out var rweCol)) map.TryAdd("emergencycontactrelation", rweCol);
        if (map.TryGetValue("emergencyrelation", out var erCol)) map.TryAdd("emergencycontactrelation", erCol);
        if (map.TryGetValue("onfloorrole", out var onFloorCol)) map.TryAdd("role", onFloorCol);
        if (map.TryGetValue("reportingmanagercode", out var rmcCol)) map.TryAdd("reportingmanagercode", rmcCol);
        if (map.TryGetValue("reportingmanagertkid", out var mgrTkCol)) map.TryAdd("reportingmanagercode", mgrTkCol);
        if (map.TryGetValue("reportingmanagerid", out var mgrEmpIdCol)) map.TryAdd("reportingmanagercode", mgrEmpIdCol);
        if (map.TryGetValue("reportingmanager", out var mgrCol)) map.TryAdd("reportingmanagercode", mgrCol);
        if (map.TryGetValue("locationonsite", out var locOnsiteCol)) map.TryAdd("projectsite", locOnsiteCol);
        if (map.TryGetValue("onsitelocation", out var onsiteCol)) map.TryAdd("projectsite", onsiteCol);
        if (map.TryGetValue("location", out var locCol)) map.TryAdd("projectsite", locCol);
        if (map.TryGetValue("dateofjoining", out var dojCol)) map.TryAdd("joiningdate", dojCol);
        if (map.TryGetValue("employeestatus", out var empStatusCol)) map.TryAdd("status", empStatusCol);
        if (map.TryGetValue("workertype", out var wtCol)) map.TryAdd("workertype", wtCol);
        if (map.TryGetValue("bondduration", out var bdCol)) map.TryAdd("bonddurationmonths", bdCol);
        if (map.TryGetValue("bonddurationmonths", out var bdmCol)) map.TryAdd("bonddurationmonths", bdmCol);
        if (map.TryGetValue("highestqualification", out var hqCol)) map.TryAdd("graddegree", hqCol);
        if (map.TryGetValue("graduationdegreename", out var gdnCol)) map.TryAdd("graddegree", gdnCol);
        if (map.TryGetValue("graduationdegree", out var gdCol)) map.TryAdd("graddegree", gdCol);
        if (map.TryGetValue("graduationpassingyear", out var gpyCol)) map.TryAdd("gradyear", gpyCol);
        if (map.TryGetValue("graduationyear", out var gyCol)) map.TryAdd("gradyear", gyCol);
        if (map.TryGetValue("postgraduationdegreename", out var pgdnCol)) map.TryAdd("postgraddegree", pgdnCol);
        if (map.TryGetValue("postgraduationdegree", out var pgdCol)) map.TryAdd("postgraddegree", pgdCol);
        if (map.TryGetValue("postgraduationpassingyear", out var pgpyCol)) map.TryAdd("postgradyear", pgpyCol);
        if (map.TryGetValue("postgraduationyear", out var pgyCol)) map.TryAdd("postgradyear", pgyCol);
        if (map.TryGetValue("expfresher", out var efCol)) map.TryAdd("exptype", efCol);
        if (map.TryGetValue("experiencetype", out var etCol)) map.TryAdd("exptype", etCol);
        if (map.TryGetValue("priortotalexpyears", out var teyCol)) map.TryAdd("priortotalexpyears", teyCol);
        if (map.TryGetValue("totalexpyears", out var teyCol2)) map.TryAdd("priortotalexpyears", teyCol2);
        if (map.TryGetValue("totalexperienceyears", out var teyCol3)) map.TryAdd("priortotalexpyears", teyCol3);
        if (map.TryGetValue("priortotalexpmonths", out var temCol)) map.TryAdd("priortotalexpmonths", temCol);
        if (map.TryGetValue("totalexpmonths", out var temCol2)) map.TryAdd("priortotalexpmonths", temCol2);
        if (map.TryGetValue("totalexperiencemonths", out var temCol3)) map.TryAdd("priortotalexpmonths", temCol3);
        if (map.TryGetValue("priorrelevantexpyears", out var reyCol)) map.TryAdd("priorrelevantexpyears", reyCol);
        if (map.TryGetValue("relevantexpyears", out var reyCol2)) map.TryAdd("priorrelevantexpyears", reyCol2);
        if (map.TryGetValue("relevantexperienceyears", out var reyCol3)) map.TryAdd("priorrelevantexpyears", reyCol3);
        if (map.TryGetValue("priorrelevantexpmonths", out var remCol)) map.TryAdd("priorrelevantexpmonths", remCol);
        if (map.TryGetValue("relevantexpmonths", out var remCol2)) map.TryAdd("priorrelevantexpmonths", remCol2);
        if (map.TryGetValue("relevantexperiencemonths", out var remCol3)) map.TryAdd("priorrelevantexpmonths", remCol3);
        if (map.TryGetValue("certificationdetails", out var cdCol)) map.TryAdd("certifications", cdCol);
        if (map.TryGetValue("certification", out var certCol)) map.TryAdd("certifications", certCol);
        if (map.TryGetValue("assetid", out var assetCol)) map.TryAdd("assetid", assetCol);

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
