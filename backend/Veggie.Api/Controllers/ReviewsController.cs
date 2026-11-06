using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Controllers;

[ApiController, Route("api/products/{id:int}/reviews")]
public sealed class ReviewsController(VeggieDbContext db) : ControllerBase
{
    public sealed record ReviewRequest([Range(1, 5)] byte Rating, [Required, StringLength(2000)] string Comment);

    [HttpGet]
    public async Task<IActionResult> Index(int id, CancellationToken token) =>
        Ok(await db.Reviews.AsNoTracking().Where(r => r.ProductId == id && r.Product.Status)
            .OrderByDescending(r => r.Id).Take(30)
            .Select(r => new { r.Rating, r.Comment, r.CreatedAt, r.User.Avatar, Name = r.User.Name }).ToListAsync(token));

    [Authorize, HttpPut]
    public async Task<IActionResult> Save(int id, ReviewRequest request, CancellationToken token)
    {
        if (!await db.Products.AnyAsync(p => p.Id == id && p.Status, token)) return NotFound();
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await using var transaction = await db.Database.BeginTransactionAsync(token);
        await db.Users.Where(u => u.Id == userId)
            .ExecuteUpdateAsync(s => s.SetProperty(u => u.UpdatedAt, u => u.UpdatedAt), token);
        if (!await db.OrderItems.AnyAsync(i=>i.ProductId==id && i.Order.UserId==userId && i.Order.Status=="delivered",token)) return StatusCode(403,new{message="Chỉ đánh giá sau khi đã mua và nhận sản phẩm."});
        var review = await db.Reviews.SingleOrDefaultAsync(r => r.UserId == userId && r.ProductId == id, token);
        if(review is not null)return Conflict(new{message="Bạn đã đánh giá sản phẩm này. Mỗi tài khoản chỉ gửi một đánh giá."});
        if (review is null)
        {
            review = new Review { UserId = userId, ProductId = id };
            db.Reviews.Add(review);
        }
        review.Rating = request.Rating;
        review.Comment = request.Comment.Trim();
        await db.SaveChangesAsync(token);
        await transaction.CommitAsync(token);
        return NoContent();
    }
}

