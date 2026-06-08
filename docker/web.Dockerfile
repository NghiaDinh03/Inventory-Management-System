# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app

# Sao chép file csproj và restore các dependencies
COPY src/IMS.Web/*.csproj ./src/IMS.Web/
RUN dotnet restore src/IMS.Web/IMS.Web.csproj

# Sao chép toàn bộ mã nguồn và thực hiện publish
COPY src/IMS.Web/ ./src/IMS.Web/
WORKDIR /app/src/IMS.Web
RUN dotnet publish -c Release -o /app/out

# Stage 2: Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build-env /app/out .
EXPOSE 8080
ENTRYPOINT ["dotnet", "IMS.Web.dll"]
