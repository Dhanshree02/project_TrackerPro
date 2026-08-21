# Database README

## Source of truth

The live schema is managed by Entity Framework Core migrations under:

- `apps/backend/Migrations`

Apply migrations with:

```powershell
dotnet ef database update --project "apps/backend/PMS.API.csproj" --startup-project "apps/backend/PMS.API.csproj"
```

## Phase I scope

- Add master catalogs (`mst_departments`, `mst_designations`, `mst_industries`, `mst_countries`, `mst_cities`)
- Add resources tables (`employees`, `exited_employees`)
- Align customers to normalized model (`client_contacts`, FK columns on `clients`)

## Auth note

Auth database design is frozen in this phase. Microsoft 365 integration will drive future auth schema changes.
