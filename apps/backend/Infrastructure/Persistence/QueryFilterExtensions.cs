using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore.Metadata;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Infrastructure.Persistence;

internal static class QueryFilterExtensions
{
    /// <summary>
    /// Applies <c>e.DeletedAtUtc == null</c> as a global query filter for any
    /// entity deriving from <see cref="BaseEntity"/> that has a soft-delete column.
    /// </summary>
    public static void AddSoftDeleteFilter(this IMutableEntityType entityType)
    {
        if (!typeof(BaseEntity).IsAssignableFrom(entityType.ClrType))
            return;

        if (entityType.FindProperty(nameof(BaseEntity.DeletedAtUtc)) is null)
            return;

        var parameter = Expression.Parameter(entityType.ClrType, "e");
        var property = Expression.Property(parameter, nameof(BaseEntity.DeletedAtUtc));
        var comparison = Expression.Equal(property, Expression.Constant(null, typeof(DateTime?)));
        var filter = Expression.Lambda(comparison, parameter);

        entityType.SetQueryFilter(filter);
    }
}
