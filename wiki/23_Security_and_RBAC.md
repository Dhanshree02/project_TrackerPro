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
- **Flow:** Login → JWT issued → stored in httpOnly cookie → sent with every request
- **Token refresh:** Sliding window with refresh tokens
- **Session duration:** 8 hours (configurable)

### Authorization (RBAC)
- **Model:** Role-Based Access Control
- **Implementation:** Middleware guard on every API endpoint
- **Roles table:** `roles(id, name, permissions JSONB)`
- **User-role mapping:** `user_roles(user_id, role_id)`

### Permission Granularity

```python
PERMISSIONS = {
    "clients:read": ["pmo", "hod", "bo", "spm", "em", "dhanshree"],
    "clients:write": ["sales", "dhanshree"],
    "clients:approve": ["hod"],
    "projects:read": ["pmo", "hod", "bo", "spm", "em", "pm", "dhanshree"],
    "projects:write": ["sales", "pm", "dhanshree"],
    "wbs:allocate": ["pmo"],
    "timesheets:submit": ["employee", "tl", "pm", "spm", "em"],
    "timesheets:approve": ["spm", "em", "hod", "dhanshree"],
    "timesheets:monitor": ["pmo"],
    "issues:raise": ["tl", "pm", "spm", "em"],
    "issues:manage": ["pm", "spm", "em", "pmo", "hod"],
    "invoices:raise": ["accounts", "dhanshree"],
    "invoices:payment": ["accounts", "dhanshree"],
    "approvals:manage": ["hod", "dhanshree"],
    "resources:manage": ["pmo", "hr", "dhanshree"],
}
```

### API Security Measures
1. Input validation via Pydantic schemas
2. SQL injection prevention via SQLAlchemy ORM
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
