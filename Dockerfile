FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY backend/ ./backend/
COPY admin/ ./admin/
COPY clients/ ./clients/
RUN dotnet publish backend/Veggie.Api/Veggie.Api.csproj -c Release -o /out

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /out/ ./
CMD ["sh", "-c", "exec dotnet Veggie.Api.dll --urls http://0.0.0.0:${PORT:-8080}"]
