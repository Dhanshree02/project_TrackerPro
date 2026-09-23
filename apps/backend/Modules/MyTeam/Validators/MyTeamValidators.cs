using FluentValidation;
using PMS.API.Modules.MyTeam.DTOs;

namespace PMS.API.Modules.MyTeam.Validators;

public sealed class UpsertTeamDaysRequestValidator : AbstractValidator<UpsertTeamDaysRequest>
{
    private static readonly HashSet<string> Attendance =
        new(StringComparer.OrdinalIgnoreCase) { "onsite", "wfh", "leave", "clear" };

    private static readonly HashSet<string> Shifts =
        new(StringComparer.Ordinal) { "Morning", "Afternoon", "Night", "General" };

    public UpsertTeamDaysRequestValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty();
        RuleFor(x => x.Dates).NotEmpty().Must(d => d.Count <= 62)
            .WithMessage("A day update can cover at most 62 dates.");
        RuleForEach(x => x.Dates).Must(d => d != default)
            .WithMessage("Each date is required.");
        RuleFor(x => x.Attendance)
            .Must(v => v is null || Attendance.Contains(v.Trim()))
            .WithMessage("Attendance must be onsite, wfh, leave, or clear.");
        RuleFor(x => x.Shift)
            .Must(v => v is null || Shifts.Contains(v.Trim()))
            .WithMessage("Shift must be Morning, Afternoon, Night, or General.");
        RuleFor(x => x)
            .Must(x => !string.IsNullOrWhiteSpace(x.Attendance) || !string.IsNullOrWhiteSpace(x.Shift))
            .WithMessage("Set attendance, shift, or both.");
    }
}

public sealed class SaveTeamScheduleRequestValidator : AbstractValidator<SaveTeamScheduleRequest>
{
    public SaveTeamScheduleRequestValidator()
    {
        RuleFor(x => x.WorkingDays)
            .NotEmpty()
            .Must(days => days.Distinct().Count() == days.Count)
            .WithMessage("Working days cannot repeat.");
        RuleForEach(x => x.WorkingDays)
            .InclusiveBetween((short)0, (short)6)
            .WithMessage("Working days are 0 (Sunday) through 6 (Saturday).");
        RuleFor(x => x.Notes).MaximumLength(2000);
        RuleFor(x => x.Holidays)
            .Must(h => h.Select(x => x.Date).Distinct().Count() == h.Count)
            .WithMessage("A holiday date can only be listed once.");
        RuleForEach(x => x.Holidays).ChildRules(holiday =>
        {
            holiday.RuleFor(h => h.Date).Must(d => d != default).WithMessage("Holiday date is required.");
            holiday.RuleFor(h => h.Name).NotEmpty().MaximumLength(200);
            holiday.RuleFor(h => h.Comment).MaximumLength(500);
        });
    }
}
