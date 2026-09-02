# Stage 1: Build .NET Web API
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy project file and restore
COPY ["PMS.API.csproj", "./"]
RUN dotnet restore "PMS.API.csproj"

# Copy source code and build release
COPY . .
RUN dotnet publish "PMS.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

# Uploaded documents (Storage:RootPath=storage) — mounted as a named volume in docker-compose.
RUN mkdir -p /app/storage
VOLUME ["/app/storage"]

EXPOSE 8080
ENTRYPOINT ["dotnet", "PMS.API.dll"]
