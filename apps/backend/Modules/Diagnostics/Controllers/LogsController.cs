using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PMS.API.Modules.Diagnostics.DTOs;
using Serilog;
using Serilog.Events;

namespace PMS.API.Modules.Diagnostics.Controllers;

[ApiController]
[Route("api/v1/logs")]
[AllowAnonymous]
public class LogsController : ControllerBase
{
    private static readonly Serilog.ILogger Logger = Log.ForContext("SourceContext", "FrontendLogger");

    [HttpPost("frontend")]
    public IActionResult LogFrontendMessage([FromBody] FrontendLogDto dto)
    {
        if (dto == null || string.IsNullOrWhiteSpace(dto.Message))
        {
            return BadRequest(new { message = "Log message is required." });
        }

        var level = (dto.Level?.ToUpperInvariant()) switch
        {
            "ERROR" => LogEventLevel.Error,
            "WARN" or "WARNING" => LogEventLevel.Warning,
            "DEBUG" => LogEventLevel.Debug,
            _ => LogEventLevel.Information
        };

        var detailsJson = dto.Details != null ? JsonSerializer.Serialize(dto.Details) : null;
        var logContext = Logger
            .ForContext("IsFrontend", true)
            .ForContext("Module", string.IsNullOrWhiteSpace(dto.Module) ? "System" : dto.Module);

        var logMessage = $"[UI] {dto.Message}" +
                         (!string.IsNullOrEmpty(dto.Url) ? $" | URL: {dto.Url}" : "") +
                         (!string.IsNullOrEmpty(dto.UserEmail) ? $" | User: {dto.UserEmail}" : "") +
                         (detailsJson != null ? $" | Details: {detailsJson}" : "");

        logContext.Write(level, "{Message}", logMessage);

        return Ok(new { success = true });
    }
}
