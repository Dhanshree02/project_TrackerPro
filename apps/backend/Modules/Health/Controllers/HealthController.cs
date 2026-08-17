using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Health.Controllers;

[ApiController]
[Route("api/v1/health")]
[AllowAnonymous]
public class HealthController(ILogger<HealthController> logger) : ControllerBase
{
    [HttpGet]
    public ActionResult<ApiResponse<object>> Get()
    {
        logger.LogInformation("Health check requested");
        return Ok(ApiResponse<object>.Ok(new
        {
            status = "ok",
            service = "trackerpro-api",
            version = typeof(Program).Assembly.GetName().Version?.ToString() ?? "1.0.0",
            utcNow = DateTime.UtcNow,
        }));
    }
}
