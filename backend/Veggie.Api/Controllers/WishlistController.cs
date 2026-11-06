using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Controllers;

[ApiController, Authorize, Route("api/wishlist")]
public sealed class WishlistController(VeggieDbContext db) : ControllerBase
{
    private int UserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet]
    public async Task<IActionResult> Index(CancellationToken token) =>
        Ok(await db.Wishlists.AsNoTracking().Where(w => w.UserId == UserId && w.Product.Status)
            .OrderBy(w => w.Id).Select(w => w.ProductId).ToListAsync(token));

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Add(int id, CancellationToken token)
    {
        if (!await db.Products.AnyAsync(p => p.Id == id && p.Status, token)) return NotFound();
        if (await db.Wishlists.AnyAsync(w => w.UserId == UserId && w.ProductId == id, token)) return NoContent();
        db.Wishlists.Add(new Wishlist { UserId = UserId, ProductId = id });
        try { await db.SaveChangesAsync(token); }
        catch (DbUpdateException ex) when (ex.InnerException is SqlException { Number: 2601 or 2627 }) { }
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Remove(int id, CancellationToken token)
    {
        await db.Wishlists.Where(w => w.UserId == UserId && w.ProductId == id).ExecuteDeleteAsync(token);
        return NoContent();
    }
}
