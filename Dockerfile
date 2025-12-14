# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0-preview AS build

WORKDIR /src

# Copy project files and restore dependencies
COPY *.sln .

COPY BlazorSample/*.csproj ./BlazorSample/

RUN dotnet restore ./BlazorSample/BlazorSample.csproj

# Copy all source code
COPY BlazorSample/. ./BlazorSample/

# Build the project in Release mode
RUN dotnet publish ./BlazorSample/BlazorSample.csproj -c Release -o /app/publish

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0-preview AS runtime
WORKDIR /app

# Copy the published output from the build stage
COPY --from=build /app/publish .

# Expose port 80
EXPOSE 8080

# Set the entrypoint
ENTRYPOINT ["dotnet", "BlazorSample.dll"]
