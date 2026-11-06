using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Controllers;

[ApiController, Authorize, Route("api/cart")]
public sealed class CartController(VeggieDbContext db) : ControllerBase
{
    private int UserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet]
    public async Task<IActionResult> Read(CancellationToken token) =>
        Ok(await db.CartItems.AsNoTracking().Where(x => x.UserId == UserId)
            .Select(x => new { id = x.ProductId, x.Quantity }).ToListAsync(token));

    [HttpPut]
    public async Task<IActionResult> Save(CheckoutLine[] items, CancellationToken token)
    {
        if (items.Length > 100 || items.Any(x => x is null) ||
            items.Select(x => x.Id).Distinct().Count() != items.Length)
            return BadRequest();

        var ids = items.Select(x => x.Id).ToArray();
        if (await db.Products.CountAsync(p => ids.Contains(p.Id), token) != ids.Length)
            return BadRequest();

        await using var transaction = await db.Database.BeginTransactionAsync(token);
        await db.Users.Where(u => u.Id == UserId)
            .ExecuteUpdateAsync(s => s.SetProperty(u => u.UpdatedAt, u => u.UpdatedAt), token);
        await db.CartItems.Where(x => x.UserId == UserId).ExecuteDeleteAsync(token);
        db.CartItems.AddRange(items.Select(x => new CartItem { UserId = UserId, ProductId = x.Id, Quantity = x.Quantity }));
        await db.SaveChangesAsync(token);
        await transaction.CommitAsync(token);
        return NoContent();
    }
}
