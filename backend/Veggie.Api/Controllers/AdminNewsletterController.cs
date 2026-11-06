using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;

namespace Veggie.Api.Controllers;

[Authorize(Roles = "Admin"), Route("admin/newsletter")]
public sealed class AdminNewsletterController(VeggieDbContext db) : Controller
{
    [HttpGet]
    public async Task<IActionResult> Index(int page = 1, CancellationToken token = default)
    {
        page = Math.Clamp(page, 1, 100000);
        ViewData["Page"] = page;
        ViewData["Total"] = await db.NewsletterSubscriptions.CountAsync(token);
        return View(await db.NewsletterSubscriptions.AsNoTracking().OrderByDescending(s => s.Id)
            .Skip((page - 1) * 25).Take(25).ToListAsync(token));
    }
}
