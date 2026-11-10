using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Identity;
using Veggie.Api.Models.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using Veggie.Api.Models.EF;
using Veggie.Api.Services;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddUserSecrets<Program>(optional: true).AddEnvironmentVariables();
builder.Services.AddScoped<MomoSettings>();
builder.Services.AddControllersWithViews();
builder.Services.AddHttpClient();
builder.Services.AddScoped<AccountEmailService>();
builder.Services.AddHostedService<StoreEmailWorker>();
builder.Services.AddScoped<SessionValidation>();
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = 429;
    options.AddPolicy("account", context => RateLimitPartition.GetFixedWindowLimiter(
        context.Connection.RemoteIpAddress?.ToString() ?? "local",
        _ => new FixedWindowRateLimiterOptions { PermitLimit = 20, Window = TimeSpan.FromMinutes(1), QueueLimit = 0 }));
});
builder.Services.AddAuthentication("VeggieSession")
    .AddPolicyScheme("VeggieSession", null, options =>
    {
        options.ForwardDefaultSelector = context => context.Request.Path.StartsWithSegments("/admin")
            ? "VeggieAdmin" : CookieAuthenticationDefaults.AuthenticationScheme;
    })
        .AddCookie(options =>
    {
        options.Cookie.SameSite = SameSiteMode.Strict;
        options.LoginPath = "/clients/login.html";
        options.EventsType = typeof(SessionValidation);
        options.ExpireTimeSpan = TimeSpan.FromHours(8);
    });
builder.Services.AddAuthentication().AddCookie("VeggieAdmin", options =>
{
    options.Cookie.SameSite = SameSiteMode.Strict;
    options.LoginPath = "/admin/login";
    options.EventsType = typeof(SessionValidation);
    options.ExpireTimeSpan = TimeSpan.FromHours(8);
});
builder.Services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>();
builder.Services.AddDbContext<VeggieDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("Veggie")));
builder.Services.AddScoped<CatalogService>();
builder.Services.AddScoped<PromotionPricingService>();
builder.Services.AddScoped<LoyaltyPointsService>();

var app = builder.Build();
if (app.Environment.IsDevelopment())
{
    await using var schemaScope = app.Services.CreateAsyncScope();
    var schemaDb = schemaScope.ServiceProvider.GetRequiredService<VeggieDbContext>();
    await DevelopmentSchemaInitializer.EnsurePromotionsAndLoyaltyAsync(schemaDb);
}
var adminFiles = new PhysicalFileProvider(Path.Combine(AppContext.BaseDirectory, "wwwroot", "admin-assets"));
app.Lifetime.ApplicationStopped.Register(adminFiles.Dispose);
app.UseStaticFiles(new StaticFileOptions { FileProvider = adminFiles, RequestPath = "/admin-assets" });
var clientRoot = Path.Combine(AppContext.BaseDirectory, "wwwroot", "clients");
var clientFiles = new PhysicalFileProvider(clientRoot);
app.Lifetime.ApplicationStopped.Register(clientFiles.Dispose);
var uploadRoot = Path.Combine(app.Environment.ContentRootPath, "uploads");
Directory.CreateDirectory(uploadRoot);
var uploadFiles = new PhysicalFileProvider(uploadRoot);
app.Lifetime.ApplicationStopped.Register(uploadFiles.Dispose);
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = uploadFiles,
    RequestPath = "/product-uploads",
    OnPrepareResponse = response => response.Context.Response.Headers["X-Content-Type-Options"] = "nosniff"
});
app.UseRouting();
app.UseRateLimiter();
app.UseWhen(context => context.GetEndpoint() is null &&
    !string.Equals(Path.GetExtension(context.Request.Path.Value), ".html", StringComparison.OrdinalIgnoreCase),
    branch => branch.UseStaticFiles(new StaticFileOptions { FileProvider = clientFiles, RequestPath = "/clients" }));
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();








