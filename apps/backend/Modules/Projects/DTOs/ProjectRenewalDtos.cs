namespace PMS.API.Modules.Projects.DTOs;

public sealed record RenewProjectRequest(
    DateOnly? StartDate = null,
    DateOnly? EndDate = null,
    string? Name = null,
    bool CloneServices = true,
    bool CloneTasks = true,
    string? PoNumber = null,
    DateOnly? PoDate = null);
