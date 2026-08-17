using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Middleware;

/// <summary>
/// Runs FluentValidation validators on controller action arguments (registered via
/// <c>AddValidatorsFromAssembly</c>). Returns a 400 with the standard error
/// envelope when validation fails — keeps services free of validation plumbing.
/// </summary>
public sealed class ValidationFilter(IServiceProvider services) : IAsyncActionFilter
{
    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        foreach (var argument in context.ActionArguments.Values)
        {
            if (argument is null) continue;

            var validator = ResolveValidator(argument.GetType());
            if (validator is null) continue;

            var validationResult = await validator.ValidateAsync(
                new ValidationContext<object>(argument));

            if (!validationResult.IsValid)
            {
                context.Result = new BadRequestObjectResult(ApiResponse<object>.Fail(
                    validationResult.Errors.Select(e =>
                        new ApiError("VALIDATION_ERROR", e.PropertyName, e.ErrorMessage))));
                return;
            }
        }

        await next();
    }

    private IValidator? ResolveValidator(Type type)
    {
        var validatorType = typeof(IValidator<>).MakeGenericType(type);
        return services.GetService(validatorType) as IValidator;
    }
}
