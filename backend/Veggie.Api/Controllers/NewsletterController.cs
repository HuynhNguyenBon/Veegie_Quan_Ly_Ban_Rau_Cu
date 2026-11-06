using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Controllers;

[ApiController, Route("api/newsletter")]
public sealed class NewsletterController(VeggieDbContext db) : ControllerBase
{
    public sealed record Subscription([Required, EmailAddress, StringLength(254)] string Email);
    [HttpPost, EnableRateLimiting("account")]
    public async Task<IActionResult> Subscribe(Subscription request, CancellationToken token)
    {
        var email = request.Email.Trim().ToLowerInvariant();
        if (!await db.NewsletterSubscriptions.AnyAsync(s => s.Email == email, token))
        {
            db.NewsletterSubscriptions.Add(new NewsletterSubscription { Email = email });
            try { await db.SaveChangesAsync(token); }
            catch (DbUpdateException ex) when (ex.InnerException is SqlException { Number: 2601 or 2627 }) { }
        }
        return Ok(new { message = "Đã đăng ký nhận bản tin Veggie. Cảm ơn bạn!" });
    }
}
