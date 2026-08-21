using System.Net;
using System.Text.Json;
using FluentValidation;
using PMS.API.Shared.Exceptions;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Infrastructure.Authentication;

namespace PMS.API.Middleware;

/// <summary>
/// Converts unhandled exceptions into the standard
/// <c>{ data, meta, errors }</c> envelope and logs the details.
/// </summary>
public sealed class ExceptionHandlingMiddleware(
    RequestDelegate next,
    ILogger<ExceptionHandlingMiddleware> logger,
    IHostEnvironment environment)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (UnauthorizedException ex)
        {
            logger.LogWarning(ex, "Authentication failure on {Method} {Path}", context.Request.Method, context.Request.Path);
            await WriteAsync(context, HttpStatusCode.Unauthorized, "UNAUTHORIZED",
                [new ApiError("UNAUTHORIZED", null, ex.Message)]);
        }
        catch (ForbiddenException ex)
        {
            await WriteAsync(context, HttpStatusCode.Forbidden, "FORBIDDEN",
                [new ApiError("FORBIDDEN", null, ex.Message)]);
        }
        catch (NotFoundException ex)
        {
            await WriteAsync(context, HttpStatusCode.NotFound, "NOT_FOUND",
                [new ApiError("NOT_FOUND", null, ex.Message)]);
        }
        catch (ConflictException ex)
        {
            await WriteAsync(context, HttpStatusCode.Conflict, "CONFLICT",
                [new ApiError("CONFLICT", null, ex.Message)]);
        }
        catch (ValidationException ex)
        {
            await WriteAsync(context, HttpStatusCode.BadRequest, "VALIDATION_ERROR",
                ex.Errors.Select(e => new ApiError("VALIDATION_ERROR", e.PropertyName, e.ErrorMessage)));
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled exception on {Method} {Path}", context.Request.Method, context.Request.Path);

            var message = environment.IsDevelopment()
                ? ex.InnerException?.Message ?? ex.Message
                : "An unexpected error occurred.";

            await WriteAsync(context, HttpStatusCode.InternalServerError, "INTERNAL_ERROR",
                [new ApiError("INTERNAL_ERROR", null, message)]);
        }
    }

    private static async Task WriteAsync(
        HttpContext context,
        HttpStatusCode status,
        string code,
        IEnumerable<ApiError> errors)
    {
        context.Response.StatusCode = (int)status;
        context.Response.ContentType = "application/json";

        // Web defaults keep the envelope camelCase, matching controller serialization.
        var payload = ApiResponse<object>.Fail(errors);
        await context.Response.WriteAsync(JsonSerializer.Serialize(payload, JsonSerializerOptions.Web));
    }
}
