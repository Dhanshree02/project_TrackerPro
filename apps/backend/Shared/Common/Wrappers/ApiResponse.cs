namespace PMS.API.Shared.Common.Wrappers;

/// <summary>
/// Standard API error item, matching the API convention in
/// <c>wiki/21_API_Design_Draft.md</c>.
/// </summary>
public sealed record ApiError(string Code, string? Field, string Message);

/// <summary>
/// Standard API response envelope: <c>{ data, meta, errors }</c>.
/// </summary>
public sealed record ApiResponse<T>
{
    public T? Data { get; init; }

    public ApiMeta? Meta { get; init; }

    public List<ApiError>? Errors { get; init; }

    public static ApiResponse<T> Ok(T data, ApiMeta? meta = null) => new() { Data = data, Meta = meta };

    public static ApiResponse<T> Fail(IEnumerable<ApiError> errors) => new() { Errors = errors.ToList() };

    public static ApiResponse<T> Fail(string code, string message) =>
        new() { Errors = [new ApiError(code, null, message)] };
}

public sealed record ApiMeta
{
    public int? Total { get; init; }

    public int? Page { get; init; }

    public int? PerPage { get; init; }

    public int? TotalPages { get; init; }
}
