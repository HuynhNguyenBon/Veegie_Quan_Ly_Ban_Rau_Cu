using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
namespace Veggie.Api.Controllers;
[Authorize(Roles="Admin,Staff"),Route("admin/notifications")]
public sealed class AdminNotificationsController(VeggieDbContext db):Controller
{
 private int UserId=>int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
 [HttpGet] public async Task<IActionResult> Index(CancellationToken token)=>View(await db.Notifications.AsNoTracking().Where(n=>n.UserId==UserId).OrderByDescending(n=>n.Id).Take(100).ToListAsync(token));
 [HttpPost("{id:int}/read"),ValidateAntiForgeryToken] public async Task<IActionResult> Read(int id,CancellationToken token){await db.Notifications.Where(n=>n.UserId==UserId&&n.Id==id).ExecuteUpdateAsync(s=>s.SetProperty(n=>n.IsRead,true),token);return RedirectToAction(nameof(Index));}
}
