using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;

namespace Veggie.Api.Services;

public sealed class SessionValidation(VeggieDbContext db) : CookieAuthenticationEvents
{
    public override Task RedirectToLogin(RedirectContext<CookieAuthenticationOptions> context)
    {
        if (!context.Request.Path.StartsWithSegments("/admin/session"))
            return base.RedirectToLogin(context);

        context.Response.StatusCode = StatusCodes.Status401Unauthorized;
        return Task.CompletedTask;
    }

    public override Task RedirectToAccessDenied(RedirectContext<CookieAuthenticationOptions> context)
    {
        context.Response.StatusCode = StatusCodes.Status403Forbidden;
        return Task.CompletedTask;
    }
    public override async Task ValidatePrincipal(CookieValidatePrincipalContext context)
    {
        var principal = context.Principal;
        if (int.TryParse(principal?.FindFirstValue(ClaimTypes.NameIdentifier), out var id))
        {
            try
            {
                var user = await db.Users.AsNoTracking().Where(u => u.Id == id && u.Status && u.EmailConfirmed)
                    .Select(u => new { u.SecurityStamp, Role = u.Role.Name })
                    .SingleOrDefaultAsync(context.HttpContext.RequestAborted);
                if (user is not null && user.SecurityStamp == principal?.FindFirstValue("security_stamp")
                    && user.Role == principal.FindFirstValue(ClaimTypes.Role)) return;
            }
            catch (OperationCanceledException) when (context.HttpContext.RequestAborted.IsCancellationRequested)
            {
                // The browser canceled this request (commonly during navigation); do not invalidate the session.
                return;
            }
        }
        context.RejectPrincipal();
        await context.HttpContext.SignOutAsync(context.Scheme.Name);
    }
}
