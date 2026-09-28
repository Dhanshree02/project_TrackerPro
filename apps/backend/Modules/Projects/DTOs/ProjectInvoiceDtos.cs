namespace PMS.API.Modules.Projects.DTOs;

public sealed record ProjectInvoiceDto(
    Guid Id,
    Guid ProjectId,
    string MilestoneName,
    decimal? Percentage,
    decimal Amount,
    decimal TaxAmount,
    decimal TotalAmount,
    string Status,
    string? InvoiceNumber,
    DateOnly? InvoiceDate,
    DateOnly? DueDate,
    DateOnly? PaymentDate,
    string? Remarks,
    int SortOrder,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);

public sealed record CreateProjectInvoiceRequest(
    string MilestoneName,
    decimal? Percentage = null,
    decimal Amount = 0,
    decimal? TaxPercent = null,
    decimal? TaxAmount = null,
    decimal? TotalAmount = null,
    string? Status = "Pending",
    string? InvoiceNumber = null,
    DateOnly? InvoiceDate = null,
    DateOnly? DueDate = null,
    DateOnly? PaymentDate = null,
    string? Remarks = null,
    int SortOrder = 0);

public sealed record UpdateProjectInvoiceRequest(
    string? MilestoneName = null,
    decimal? Percentage = null,
    decimal? Amount = null,
    decimal? TaxPercent = null,
    decimal? TaxAmount = null,
    decimal? TotalAmount = null,
    string? Status = null,
    string? InvoiceNumber = null,
    DateOnly? InvoiceDate = null,
    DateOnly? DueDate = null,
    DateOnly? PaymentDate = null,
    string? Remarks = null,
    int? SortOrder = null);

public sealed record AutoGenerateInvoicesSummaryDto(
    Guid ProjectId,
    int InvoicesCreated,
    decimal TotalInvoiceValue,
    IReadOnlyList<ProjectInvoiceDto> GeneratedInvoices);
