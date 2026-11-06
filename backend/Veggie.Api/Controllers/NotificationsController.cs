using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;

namespace Veggie.Api.Controllers;

[ApiController, Authorize, Route("api/notifications")]
public sealed class NotificationsController(VeggieDbContext db) : ControllerBase
{
    private int UserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet]
    public async Task<IActionResult> Index(CancellationToken token) =>
        Ok(await db.Notifications.AsNoTracking().Where(n => n.UserId == UserId)
            .OrderByDescending(n => n.Id).Take(30)
            .Select(n => new { n.Id, n.Message, n.IsRead, n.CreatedAt }).ToListAsync(token));

    [HttpPut("{id:int}/read")]
    public async Task<IActionResult> Read(int id, CancellationToken token)
    {
        var count = await db.Notifications.Where(n => n.Id == id && n.UserId == UserId)
            .ExecuteUpdateAsync(set => set.SetProperty(n => n.IsRead, true), token);
        return count == 0 ? NotFound() : NoContent();
    }
}
