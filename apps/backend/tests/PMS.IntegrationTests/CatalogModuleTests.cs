using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using PMS.API.Modules.Auth.DTOs;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.IntegrationTests;

public class CatalogModuleTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public CatalogModuleTests(WebApplicationFactory<Program> factory)
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
    public async Task Countries_ReturnsSeededIndia()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var response = await _client.GetAsync("/api/v1/catalogs/countries");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var envelope = await response.Content.ReadFromJsonAsync<ApiResponse<List<CatalogOptionDto>>>();
        Assert.NotNull(envelope?.Data);
        Assert.Contains(envelope.Data, c => c.Code == "IN" && c.Name == "India");
    }

    [Fact]
    public async Task Nationalities_ReturnsSeededIndian()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var response = await _client.GetAsync("/api/v1/catalogs/nationalities");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var envelope = await response.Content.ReadFromJsonAsync<ApiResponse<List<CatalogOptionDto>>>();
        Assert.NotNull(envelope?.Data);
        Assert.Contains(envelope.Data, n => n.Code == "indian" && n.Name == "Indian");
    }

    [Fact]
    public async Task Cities_FiltersByCountry()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var countriesResponse = await _client.GetAsync("/api/v1/catalogs/countries");
        var countries = await countriesResponse.Content.ReadFromJsonAsync<ApiResponse<List<CatalogOptionDto>>>();
        var india = countries!.Data!.First(c => c.Code == "IN");

        var citiesResponse = await _client.GetAsync($"/api/v1/catalogs/cities?countryId={india.Id}");
        Assert.Equal(HttpStatusCode.OK, citiesResponse.StatusCode);

        var cities = await citiesResponse.Content.ReadFromJsonAsync<ApiResponse<List<CityCatalogOptionDto>>>();
        Assert.NotNull(cities?.Data);
        Assert.Contains(cities.Data, c => c.Name == "Mumbai" && c.CountryId == india.Id);
        Assert.DoesNotContain(cities.Data, c => c.Name == "London");
    }

    [Fact]
    public async Task ClientMeta_Countries_RequiresClientsRead()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", await LoginAsync());

        var response = await _client.GetAsync("/api/v1/clients/meta/countries");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
