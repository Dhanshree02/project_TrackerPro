# Security and RBAC

> **Status:** 🔲 Not yet implemented  
> **Last Updated:** 2026-06-16

---

## Current State

**No security exists.** The frontend uses `RoleContext` with a dropdown role switcher — any user can switch to any role. There is no:
- Authentication (no login, no JWT)
- Authorization (no API guards)
- Session management
- Password handling
- CSRF protection
- Rate limiting

## Planned Security Architecture

### Authentication
- **Strategy:** JWT (JSON Web Tokens)
- **Flow:** Login → access token (30 min) + rotating refresh token (7 days, stored hashed)
- **Token refresh:** Rotation with reuse-detection (revoked-token reuse revokes the family)
- **Session duration:** 8 hours (configurable)

### Authorization (RBAC)
- **Model:** Role-Based Access Control
- **Implementation:** Middleware guard on every API endpoint
- **Roles table:** `roles(id, name, permissions JSONB)`
- **User-role mapping:** `user_roles(user_id, role_id)`

### Permission Granularity

In the .NET implementation these are C# constants in `apps/backend/Shared/Constants/Permissions.cs` and guards are applied with an attribute:

```csharp
[RequirePermission(Permissions.ClientsRead)]
[HttpGet]
public ActionResult<ApiResponse<...>> List() => ...;
```

The role → permission mapping lives in the database seeder (`Role.Permissions` JSONB). Roles and their permission sets are documented in [[04_Roles_and_Permissions]] and seeded in `apps/backend/Infrastructure/Persistence/Seeding/DbSeeder.cs`.

### API Security Measures
1. Input validation via Pydantic schemas
2. SQL injection prevention via EF Core (parameterized queries)
3. XSS prevention via output encoding
4. CORS policy (restrict to frontend origin)
5. Rate limiting per IP and per user
6. Request size limits
7. HTTPS enforcement
8. Audit logging for all state changes

---

## Related Documents
- [[04_Roles_and_Permissions]]
- [[22_Backend_Architecture_Draft]]
- [[24_Audit_Logging]]
