using Microsoft.OpenApi;

namespace PMS.API.Infrastructure.Swagger;

/// <summary>
/// OpenAPI (Swagger) documentation setup with JWT bearer auth support.
/// </summary>
public static class SwaggerExtensions
{
    public static IServiceCollection AddSwaggerDocs(this IServiceCollection services)
    {
        services.AddSwaggerGen(c =>
        {
            c.SwaggerDoc("v1", new OpenApiInfo
            {
                Title = "PMS API",
                Version = "v1",
                Description = "Pulse PMO backend — project lifecycle, resource management, timesheets, approvals, finance.",
            });

            c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                Name = "Authorization",
                Type = SecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                In = ParameterLocation.Header,
                Description = "Enter 'Bearer {your JWT}' to authenticate.",
            });

            c.AddSecurityRequirement(_ => new OpenApiSecurityRequirement
            {
                {
                    new OpenApiSecuritySchemeReference("Bearer"),
                    new List<string>()
                },
            });
        });

        return services;
    }
}
