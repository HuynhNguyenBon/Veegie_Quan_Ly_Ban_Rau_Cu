using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;

namespace Veggie.Api.Controllers;

[ApiController, Authorize, Route("api/promotions")]
public sealed class PromotionsController(VeggieDbContext db) : ControllerBase
{
    private int UserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet("available")]
    public async Task<IActionResult> Available(CancellationToken token)
    {
        var userId = UserId;
        var now = DateTime.UtcNow;
        var candidates = await db.Promotions.AsNoTracking()
            .Where(p => p.IsActive && p.StartsAt <= now && p.ExpiresAt > now &&
                (p.AssignedUserId == null || p.AssignedUserId == userId) &&
                (p.UsageLimit == null || p.UsageCount < p.UsageLimit))
            .OrderBy(p => p.ExpiresAt)
            .Take(100)
            .Select(p => new
            {
                p.Code, p.Description, p.DiscountType, p.DiscountValue, p.MinimumSubtotal,
                p.MaximumDiscount, p.ExpiresAt, p.MaxUsesPerUser,
                UsesByUser = db.PromotionUsages.Count(u => u.PromotionId == p.Id && u.UserId == userId)
            })
            .ToListAsync(token);

        return Ok(candidates.Where(p => p.UsesByUser < p.MaxUsesPerUser)
            .Select(p => new { p.Code, p.Description, p.DiscountType, p.DiscountValue, p.MinimumSubtotal, p.MaximumDiscount, p.ExpiresAt }));
    }
}
