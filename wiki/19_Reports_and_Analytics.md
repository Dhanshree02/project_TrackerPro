# Reports and Analytics

> **Route Files:** `reports.tsx`, `dh-reports.tsx`  
> **Technology:** Recharts  
> **Last Updated:** 2026-06-16

---

## Responsibilities
- Visual analytics dashboards for project portfolio
- KPI tracking and trend analysis
- Resource utilization reports
- Financial performance reporting
- Health status distribution

## Available Reports

### Standard Reports (`reports.tsx`)
Available to: HOD, Business Owner
- Project health distribution (green/amber/red)
- Budget utilization across projects
- Resource allocation heatmap
- Project status mix (ongoing/completed/on hold)
- Issue trend analysis

### Dhanshree Reports (`dh-reports.tsx`)
Available to: Dhanshree role
- Cross-client project status overview
- Resource utilization by department
- Invoice and payment analytics
- Onboarding/offboarding trends
- Alert and escalation analytics

## Dashboard KPIs

| KPI | Roles | Description |
|-----|-------|-------------|
| Ongoing Projects | All | Count of `status: "ongoing"` projects |
| At Risk + Critical | All | Count of `health: "amber" or "red"` |
| Pending Approvals | SPM/EM/PMO/HOD | Pending timesheets count |
| Open Escalations | BO | Open issues count |
| People on Projects | SPM/EM | Unique team members |
| PM Buckets | PMO/BO | Capacity vs allocation |
| On-Bench Resources | PMO/BO | Available for allocation |
| Invoice Status | PMO/BO | Raised/Paid/Overdue/Pending |

## Chart Technology
- **Library:** Recharts 2.15.4
- **Chart types used:** Bar, Line, Pie, Area, RadialBar
- **Responsive:** Charts adapt to container width

## Future Backend Considerations
- Real-time analytics aggregation
- Custom report builder
- Scheduled report generation (PDF/Excel export)
- Trend forecasting with ML
- Benchmark comparison across projects
- Drill-down capabilities from summary to detail

---

## Related Documents
- [[18_Finance_Module]]
- [[12_Resource_Management]]
- [[17_Health_and_Governance]]
