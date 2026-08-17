namespace PMS.API.Shared.Exceptions;

/// <summary>Maps to 404 Not Found.</summary>
public sealed class NotFoundException(string message) : Exception(message);

/// <summary>Maps to 409 Conflict (e.g. duplicate email).</summary>
public sealed class ConflictException(string message) : Exception(message);

/// <summary>Maps to 403 Forbidden.</summary>
public sealed class ForbiddenException(string message) : Exception(message);
