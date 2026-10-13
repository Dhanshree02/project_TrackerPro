namespace PMS.API.Modules.Diagnostics.DTOs;

public class FrontendLogDto
{
    public string Module { get; set; } = "System";
    public string Level { get; set; } = "Information";
    public string Message { get; set; } = string.Empty;
    public string? Url { get; set; }
    public string? UserEmail { get; set; }
    public object? Details { get; set; }
}
