# Stage 1: Build .NET Web API
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src

# Copy project file and restore
COPY ["PMS.API.csproj", "./"]
RUN dotnet restore "PMS.API.csproj"

# Copy source code and build release
COPY . .
RUN dotnet publish "PMS.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0-preview AS runtime
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 8080
ENTRYPOINT ["dotnet", "PMS.API.dll"]
