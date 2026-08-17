# Modules

Each business module lives in its own folder under `Modules/`. Modules are
delivered one at a time (see the roadmap in `wiki/31_Backend_Plan_DotNet.md`).

```
Modules/
├── Auth/          # login, refresh, logout, me, change-password
├── Customers/     # clients — CRUD + data scoping (sub-ventures, SPOC contacts)
├── Users/         # users & roles management, permissions
├── Health/        # health endpoint
├── ActionCentre/  # reserved
├── Dashboard/     # reserved
├── MyTeam/        # reserved
├── Projects/      # reserved
├── Reports/       # reserved
├── Repository/    # reserved
├── Resources/     # reserved — workload, bench, onboarding/offboarding
└── Settings/      # reserved
```

## Convention per module

```
Modules/<Module>/
├── Controllers/   # API controllers
├── DTOs/          # Request/response models
├── Models/        # Domain entities / enums
├── Services/      # Contracts + business logic implementations
├── Validators/    # FluentValidation validators
└── Mappings/      # AutoMapper profiles (if any)
```
