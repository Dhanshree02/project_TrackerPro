namespace PMS.API.Shared.Common.Wrappers;

/// <summary>
/// Paged result returned by list endpoints. Frontend pagination expects
/// <c>page</c>/<c>per_page</c> params and <c>total</c> metadata.
/// </summary>
public sealed record PagedResult<T>(IReadOnlyList<T> Items, int Page, int PerPage, int Total)
{
    public int TotalPages => PerPage <= 0 ? 0 : (int)Math.Ceiling(Total / (double)PerPage);
}
