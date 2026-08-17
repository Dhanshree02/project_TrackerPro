using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Hosting;
using PMS.API.Modules.Auth.DTOs;
using PMS.API.Modules.Customers.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.IntegrationTests;

/// <summary>
/// End-to-end Customer (Clients) module tests against a real PostgreSQL.
/// The test host sets <c>Database:AutoMigrate=true</c>, so migrations are applied and
/// demo data is seeded (idempotent) — same behaviour as running the API in Development.
/// Requires PostgreSQL (see apps/backend/README.md).
/// </summary>
public class CustomerModuleTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public CustomerModuleTests(WebApplicationFactory<Program> factory)
    {
        factory = factory.WithWebHostBuilder(b =>
            b.UseSetting("Database:AutoMigrate", "true"));
        _client = factory.CreateClient();
    }

    private async Task<string> LoginAsync()
    {
        var response = await _client.PostAsJsonAsync("/api/v1/auth/login",
            new LoginRequest("dhanshree@acme.co", "Password@123"));
        response.EnsureSuccessStatusCode();

        var envelope = await response.Content.ReadFromJsonAsync<ApiResponse<AuthResult>>();
        Assert.NotNull(envelope?.Data);
        return envelope!.Data!.AccessToken;
    }

    [Fact]
    public async Task CustomerCrud_RoundTrip()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        // ---- Create ----
        var name = "IntegrationTest-" + Guid.NewGuid().ToString("N")[..8];
        var createResponse = await _client.PostAsJsonAsync("/api/v1/clients",
            new CreateClientRequest(
                Name: name,
                Industry: "Technology",
                Logo: null,
                ContactEmail: null,
                ClientType: null,
                EngagementManager: null,
                ContactName: null,
                ContactPhone: null,
                ContactDesignation: null,
                ContactType: null,
                City: null,
                Country: null,
                BusinessType: null,
                Notes: null,
                KycDocumentName: null,
                SubVentures: null,
                Contacts: null));

        Assert.Equal(HttpStatusCode.Created, createResponse.StatusCode);
        var created = await createResponse.Content.ReadFromJsonAsync<ApiResponse<ClientDto>>();
        Assert.NotNull(created?.Data);
        var id = created!.Data!.Id;

        var deleted = false;
        try
        {
            // ---- Get by id ----
            var getResponse = await _client.GetAsync($"/api/v1/clients/{id}");
            Assert.Equal(HttpStatusCode.OK, getResponse.StatusCode);
            var fetched = await getResponse.Content.ReadFromJsonAsync<ApiResponse<ClientDto>>();
            Assert.Equal(name, fetched!.Data!.Name);

            // ---- Update (status -> Inactive) ----
            var updateResponse = await _client.PutAsJsonAsync($"/api/v1/clients/{id}",
                new UpdateClientRequest(
                    Name: null,
                    Industry: null,
                    Logo: null,
                    ContactEmail: null,
                    ClientType: null,
                    Status: "Inactive",
                    EngagementManager: null,
                    ContactName: null,
                    ContactPhone: null,
                    ContactDesignation: null,
                    ContactType: null,
                    City: null,
                    Country: null,
                    BusinessType: null,
                    Notes: null,
                    KycDocumentName: null,
                    SubVentures: null,
                    Contacts: null));
            Assert.Equal(HttpStatusCode.OK, updateResponse.StatusCode);
            var updated = await updateResponse.Content.ReadFromJsonAsync<ApiResponse<ClientDto>>();
            Assert.Equal("Inactive", updated!.Data!.Status);

            // ---- List (search finds it) ----
            var listResponse = await _client.GetAsync(
                "/api/v1/clients?perPage=100&search=" + Uri.EscapeDataString(name));
            Assert.Equal(HttpStatusCode.OK, listResponse.StatusCode);
            var list = await listResponse.Content.ReadFromJsonAsync<ApiResponse<PagedResult<ClientDto>>>();
            Assert.Contains(list!.Data!.Items, c => c.Id == id);

            // ---- Soft delete ----
            var deleteResponse = await _client.DeleteAsync($"/api/v1/clients/{id}");
            Assert.Equal(HttpStatusCode.NoContent, deleteResponse.StatusCode);
            deleted = true;
        }
        finally
        {
            // Clean up the dev DB even when an assertion above failed.
            if (!deleted)
            {
                await _client.DeleteAsync($"/api/v1/clients/{id}");
            }
        }

        // ---- Deleted client is no longer visible ----
        var afterDelete = await _client.GetAsync($"/api/v1/clients/{id}");
        Assert.Equal(HttpStatusCode.NotFound, afterDelete.StatusCode);
    }

    [Fact]
    public async Task Update_AddingSubVenture_DoesNotThrowConcurrencyError()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        // ---- Create a client WITH an initial sub-venture ----
        var name = "SubVentureTest-" + Guid.NewGuid().ToString("N")[..8];
        var createResponse = await _client.PostAsJsonAsync("/api/v1/clients",
            new CreateClientRequest(
                Name: name,
                Industry: "Technology",
                Logo: null,
                ContactEmail: null,
                ClientType: null,
                EngagementManager: null,
                ContactName: null,
                ContactPhone: null,
                ContactDesignation: null,
                ContactType: null,
                City: null,
                Country: null,
                BusinessType: null,
                Notes: null,
                KycDocumentName: null,
                SubVentures: [new SubVentureInput("Initial Division", null)],
                Contacts: null));

        Assert.Equal(HttpStatusCode.Created, createResponse.StatusCode);
        var created = await createResponse.Content.ReadFromJsonAsync<ApiResponse<ClientDto>>();
        Assert.NotNull(created?.Data);
        var id = created!.Data!.Id;

        try
        {
            // ---- Update: add a second sub-venture (regression: this used to throw
            //      DbUpdateConcurrencyException because the new sub-venture was
            //      discovered by DetectChanges as Modified instead of Added) ----
            var updateResponse = await _client.PutAsJsonAsync($"/api/v1/clients/{id}",
                new UpdateClientRequest(
                    Name: null,
                    Industry: null,
                    Logo: null,
                    ContactEmail: null,
                    ClientType: null,
                    Status: null,
                    EngagementManager: null,
                    ContactName: null,
                    ContactPhone: null,
                    ContactDesignation: null,
                    ContactType: null,
                    City: null,
                    Country: null,
                    BusinessType: null,
                    Notes: null,
                    KycDocumentName: null,
                    SubVentures:
                    [
                        new SubVentureInput("Initial Division", null),
                        new SubVentureInput("Second Division", null),
                    ],
                    Contacts: null));

            Assert.Equal(HttpStatusCode.OK, updateResponse.StatusCode);
            var updated = await updateResponse.Content.ReadFromJsonAsync<ApiResponse<ClientDto>>();
            Assert.NotNull(updated?.Data);
            Assert.Equal(2, updated!.Data!.SubVentures.Count);
            Assert.Contains(updated.Data.SubVentures, sv => sv.Name == "Second Division");
        }
        finally
        {
            await _client.DeleteAsync($"/api/v1/clients/{id}");
        }
    }

    [Fact]
    public async Task Create_WithEmptyName_ReturnsValidationError()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var response = await _client.PostAsJsonAsync("/api/v1/clients",
            new CreateClientRequest(
                Name: "",
                Industry: "",
                Logo: null,
                ContactEmail: null,
                ClientType: null,
                EngagementManager: null,
                ContactName: null,
                ContactPhone: null,
                ContactDesignation: null,
                ContactType: null,
                City: null,
                Country: null,
                BusinessType: null,
                Notes: null,
                KycDocumentName: null,
                SubVentures: null,
                Contacts: null));

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task List_Clients_RequiresAuthentication()
    {
        // No Authorization header on purpose.
        var response = await _client.GetAsync("/api/v1/clients");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
