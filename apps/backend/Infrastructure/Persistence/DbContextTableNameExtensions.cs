using Microsoft.EntityFrameworkCore;

namespace PMS.API.Infrastructure.Persistence;

public static class DbContextTableNameExtensions
{
    /// <summary>
    /// Quoted <c>"schema"."table"</c> for an entity, taken from the EF model, for use in raw SQL.
    /// Keeps hand-written SQL on the same table the mappings point at.
    /// </summary>
    public static string TableName<TEntity>(this DbContext db) where TEntity : class
    {
        var entityType = db.Model.FindEntityType(typeof(TEntity))
            ?? throw new InvalidOperationException($"{typeof(TEntity).Name} is not part of the EF model.");
        var table = entityType.GetTableName()
            ?? throw new InvalidOperationException($"{typeof(TEntity).Name} has no table mapping.");
        var schema = entityType.GetSchema();
        return string.IsNullOrEmpty(schema) ? Quote(table) : $"{Quote(schema)}.{Quote(table)}";
    }

    private static string Quote(string identifier) => "\"" + identifier.Replace("\"", "\"\"") + "\"";
}
