namespace PMS.API.Shared.Exceptions;

/// <summary>Maps to 404 Not Found.</summary>
public sealed class NotFoundException(string message) : Exception(message);

/// <summary>Maps to 409 Conflict (e.g. duplicate email).</summary>
public sealed class ConflictException(string message) : Exception(message);

/// <summary>Maps to 403 Forbidden.</summary>
public sealed class ForbiddenException(string message) : Exception(message);

/// <summary>Maps to 401 Unauthorized.</summary>
public sealed class UnauthorizedException(string message) : Exception(message);

/// <summary>Maps to 400 Bad Request.</summary>
public sealed class BadRequestException(string message) : Exception(message);
