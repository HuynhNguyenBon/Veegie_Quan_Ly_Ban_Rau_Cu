using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;

namespace Veggie.Api.Controllers;

[Authorize(Roles = "Admin,Staff"), Route("admin/account")]
public sealed class AdminAccountController(VeggieDbContext db) : Controller
{
    [HttpGet]
    public async Task<IActionResult> Index(CancellationToken token)
    {
        var id = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var user = await db.Users.AsNoTracking().SingleOrDefaultAsync(u => u.Id == id, token);
        return user is null ? NotFound() : View(user);
    }
}