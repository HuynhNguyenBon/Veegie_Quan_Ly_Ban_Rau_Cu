using System.ComponentModel.DataAnnotations;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;
using Veggie.Api.Services;

namespace Veggie.Api.Controllers;

[ApiController, Route("api/account"), EnableRateLimiting("account")]
public sealed class AccountSecurityController(VeggieDbContext db, AccountEmailService emails, IPasswordHasher<User> passwords) : ControllerBase
{
    public sealed record EmailRequest([Required, EmailAddress, StringLength(254)] string Email);
    public sealed record TokenRequest([Required, RegularExpression("^[A-Fa-f0-9]{64}$")] string Token);
    public sealed record VerificationCodeRequest([Required, EmailAddress, StringLength(254)] string Email,
        [Required, RegularExpression("^\\d{8}$")] string Code);
    public sealed record ResetRequest([Required, RegularExpression("^[A-Fa-f0-9]{64}$")] string Token,
        [Required, StringLength(128, MinimumLength = 8)] string Password,
        [Required, StringLength(128)] string ConfirmPassword);

    [HttpPost("forgot-password")]
    public Task<IActionResult> Forgot(EmailRequest request, CancellationToken token) => Send(request, "reset", token);

    [HttpPost("resend-verification")]
    public Task<IActionResult> Resend(EmailRequest request, CancellationToken token) => Send(request, "verify", token);

    private async Task<IActionResult> Send(EmailRequest request, string purpose, CancellationToken token)
    {
        if (!emails.IsReady(Request, purpose)) return StatusCode(503, new { message = "Chức năng gửi email chưa sẵn sàng. Vui lòng thử lại sau hoặc liên hệ cửa hàng." });
        var email = request.Email.Trim().ToLowerInvariant();
        var user = await db.Users.SingleOrDefaultAsync(u => u.Email == email && u.Status, token);
        if (user is not null && (purpose == "verify" ? !user.EmailConfirmed : user.EmailConfirmed))
            await emails.SendAsync(user, purpose, Request, token);
        // Same response for unknown, disabled, already verified, cooldown and delivery failure.
        return Ok(new { message = purpose == "verify"
            ? "Nếu email hợp lệ và cần xác minh, mã sẽ được gửi đến hộp thư. Hãy kiểm tra cả thư rác; chờ ít nhất một phút trước khi gửi lại."
            : "Nếu email hợp lệ và đủ điều kiện, liên kết đặt lại sẽ được gửi đến hộp thư. Hãy kiểm tra cả thư rác; chờ ít nhất một phút trước khi gửi lại." });
    }

    [HttpPost("verify-email")]
    public async Task<IActionResult> Verify(VerificationCodeRequest request, CancellationToken token)
    {
        var email = request.Email.Trim().ToLowerInvariant();
        var user = await db.Users.SingleOrDefaultAsync(u => u.Email == email && u.Status && !u.EmailConfirmed, token);
        var now = DateTime.UtcNow;
        var record = user is null ? null : await db.AccountTokens
            .Where(t => t.UserId == user.Id && t.Purpose == "verify" && t.UsedAt == null && t.ExpiresAt > now)
            .OrderByDescending(t => t.CreatedAt).FirstOrDefaultAsync(token);
        var suppliedHash = AccountEmailService.Hash(request.Code);
        if (user is null || record is null || !CryptographicOperations.FixedTimeEquals(
                Encoding.ASCII.GetBytes(suppliedHash), Encoding.ASCII.GetBytes(record.TokenHash)))
            return BadRequest(new { message = "Mã không đúng hoặc đã hết hạn. Hãy kiểm tra email hoặc gửi mã mới." });

        await using var transaction = await db.Database.BeginTransactionAsync(token);
        var used = await db.AccountTokens.Where(t => t.Id == record.Id && t.UsedAt == null && t.ExpiresAt > now)
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.UsedAt, now), token);
        if (used != 1) return BadRequest(new { message = "Mã không đúng hoặc đã hết hạn. Hãy gửi mã mới." });
        user.EmailConfirmed = true;
        user.UpdatedAt = now;
        await db.SaveChangesAsync(token);
        await transaction.CommitAsync(token);
        return Ok(new { message = "Email đã được xác minh. Bạn có thể đăng nhập." });
    }

    [HttpPost("reset-password")]
    public Task<IActionResult> Reset(ResetRequest request, CancellationToken token)
    {
        if (request.Password != request.ConfirmPassword)
            return Task.FromResult<IActionResult>(BadRequest(new { message = "Mật khẩu nhập lại không khớp." }));
        return Consume(request.Token, "reset", request.Password, token);
    }

    private async Task<IActionResult> Consume(string raw, string purpose, string? password, CancellationToken token)
    {
        var hash = AccountEmailService.Hash(raw);
        var now = DateTime.UtcNow;
        await using var transaction = await db.Database.BeginTransactionAsync(token);
        var record = await db.AccountTokens.AsNoTracking().SingleOrDefaultAsync(t => t.TokenHash == hash && t.Purpose == purpose, token);
        if (record is null) return InvalidLink();
        await db.Users.Where(u => u.Id == record.UserId)
            .ExecuteUpdateAsync(s => s.SetProperty(u => u.UpdatedAt, u => u.UpdatedAt), token);
        var user = await db.Users.SingleOrDefaultAsync(u => u.Id == record.UserId && u.Status, token);
        if (user is null || (purpose == "reset" && !user.EmailConfirmed)) return InvalidLink();
        var used = await db.AccountTokens.Where(t => t.Id == record.Id && t.UsedAt == null && t.ExpiresAt > now)
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.UsedAt, now), token);
        if (used != 1) return InvalidLink();
        if (purpose == "verify") user.EmailConfirmed = true;
        else
        {
            user.PasswordHash = passwords.HashPassword(user, password!);
            user.SecurityStamp = Guid.NewGuid().ToString();
            await db.AccountTokens.Where(t => t.UserId == user.Id && t.Purpose == "reset" && t.UsedAt == null)
                .ExecuteUpdateAsync(s => s.SetProperty(t => t.UsedAt, now), token);
        }
        user.UpdatedAt = now;
        await db.SaveChangesAsync(token);
        await transaction.CommitAsync(token);
        return Ok(new { message = purpose == "verify" ? "Email đã được xác minh. Bạn có thể đăng nhập." : "Đã đổi mật khẩu. Vui lòng đăng nhập lại bằng mật khẩu mới." });
    }

    private BadRequestObjectResult InvalidLink() => BadRequest(new { message = "Liên kết không hợp lệ, đã hết hạn hoặc đã được sử dụng. Vui lòng yêu cầu liên kết mới." });
}
