using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;
using Veggie.Api.Models.Requests;
using Veggie.Api.Services;
using Microsoft.AspNetCore.RateLimiting;

namespace Veggie.Api.Controllers;

[ApiController]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
[Route("api/account")]
public sealed class AccountController(VeggieDbContext db, IPasswordHasher<User> passwords, IWebHostEnvironment environment, AccountEmailService emailService) : ControllerBase
{
    [HttpPost("register"), EnableRateLimiting("account")]
    public async Task<IActionResult> Register(RegisterRequest request, CancellationToken token)
    {
        if (!request.AcceptPrivacyPolicy)
            return BadRequest(new { message = "Bạn cần đồng ý với chính sách riêng tư để đăng ký." });
        if (request.Password.Length < 8)
            return BadRequest(new { message = "Mật khẩu phải có ít nhất 8 ký tự." });
        if (!emailService.Ready)
            return StatusCode(503, new { message = "Chức năng email chưa sẵn sàng. Vui lòng liên hệ cửa hàng trước khi đăng ký." });
        var email = request.Email.Trim().ToLowerInvariant();
        var role = await db.Roles.SingleAsync(r => r.Name == "Customer", token);
        var user = new User { Email = email, Name = request.LastName.Trim() + " " + request.FirstName.Trim(), RoleId = role.Id, Status = true, EmailConfirmed = false };
        user.PasswordHash = passwords.HashPassword(user, request.Password);
        db.Users.Add(user);
        try { await db.SaveChangesAsync(token); }
        catch (DbUpdateException ex) when (ex.InnerException is SqlException { Number: 2601 or 2627 })
        {
            return Conflict(new { message = "Email đã được đăng ký." });
        }
        if (!await emailService.SendAsync(user, "verify", token))
            return StatusCode(503, new { message = "Tài khoản đã tạo nhưng chưa gửi được email. Vui lòng dùng Gửi lại email xác minh ở trang đăng nhập." });
        return Ok(new
        {
            message = emailService.UsesLocalPreview
                ? "Đã tạo tài khoản. Mở thư .eml mới nhất trong thư mục email-preview của Veggie.Api để xác minh."
                : "Đã tạo tài khoản. Hãy mở email xác minh trước khi đăng nhập."
        });
    }

    [HttpPost("login"), HttpPost("/admin/session/login"), EnableRateLimiting("account")]
    public async Task<IActionResult> Login(LoginRequest request, CancellationToken token)
    {
        var email = request.Email.Trim().ToLowerInvariant();
        var user = await db.Users.Include(u => u.Role).SingleOrDefaultAsync(u => u.Email == email && u.Status, token);
        if (user?.PasswordHash is null || passwords.VerifyHashedPassword(user, user.PasswordHash, request.Password) == PasswordVerificationResult.Failed)
            return Unauthorized(new { message = "Email hoặc mật khẩu không đúng." });
        var adminPortal = Request.Path.StartsWithSegments("/admin");
        var privileged = user.Role.Name is "Admin" or "Staff";
        if (adminPortal != privileged)
            return StatusCode(403, new
            {
                message = adminPortal ? "Tài khoản này không có quyền quản trị." : "Hãy đăng nhập tại cổng quản trị.",
                adminPortal = privileged
            });
        if (!user.EmailConfirmed)
            return StatusCode(403, new { message = "Bạn cần xác minh email trước khi đăng nhập. Hãy kiểm tra email hoặc chọn Gửi lại email xác minh." });
        var identity = new ClaimsIdentity(
            [new(ClaimTypes.NameIdentifier, user.Id.ToString()), new(ClaimTypes.Name, user.Name), new(ClaimTypes.Role, user.Role.Name), new("security_stamp", user.SecurityStamp)],
            CookieAuthenticationDefaults.AuthenticationScheme);
        await HttpContext.SignInAsync(new ClaimsPrincipal(identity));
        return Ok(new { user.Name });
    }

    public sealed record ChangePasswordRequest(string CurrentPassword, string NewPassword, string ConfirmPassword);

    [Microsoft.AspNetCore.Authorization.Authorize, HttpPost("change-password"), HttpPost("/admin/session/change-password"), EnableRateLimiting("account")]
    public async Task<IActionResult> ChangePassword(ChangePasswordRequest request, CancellationToken token)
    {
        if (request.CurrentPassword.Length is < 1 or > 128 || request.NewPassword.Length is < 8 or > 128 ||
            request.NewPassword != request.ConfirmPassword || request.NewPassword == request.CurrentPassword)
            return BadRequest(new { message = "Mật khẩu mới phải khác mật khẩu hiện tại, dài từ 8 đến 128 ký tự và khớp với ô nhập lại." });

        var id = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var user = await db.Users.AsNoTracking().SingleOrDefaultAsync(u => u.Id == id && u.Status, token);
        if (user is null) return Unauthorized();
        if (user.PasswordHash is null || passwords.VerifyHashedPassword(user, user.PasswordHash, request.CurrentPassword) == PasswordVerificationResult.Failed)
            return BadRequest(new { message = "Mật khẩu hiện tại không đúng." });

        var hash = passwords.HashPassword(user, request.NewPassword);
        var stamp = Guid.NewGuid().ToString("N");
        var updated = await db.Users.Where(u => u.Id == id && u.Status && u.SecurityStamp == user.SecurityStamp)
            .ExecuteUpdateAsync(set => set.SetProperty(u => u.PasswordHash, hash)
                .SetProperty(u => u.SecurityStamp, stamp), token);
        if (updated == 0) return Conflict(new { message = "Tài khoản vừa thay đổi. Vui lòng đăng nhập lại." });
        await HttpContext.SignOutAsync();
        return Ok(new { message = "Đã đổi mật khẩu. Vui lòng đăng nhập lại." });
    }

    [Microsoft.AspNetCore.Authorization.Authorize, HttpGet("me")]
    public async Task<IActionResult> Me(CancellationToken token)
    {
        var id = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var profile = await db.Users.AsNoTracking().Where(u => u.Id == id && u.Status)
            .Select(u => new { u.Name, u.Email, u.PhoneNumber, u.Address, u.Avatar, u.CoverImage, Role = u.Role.Name }).SingleOrDefaultAsync(token);
        return profile is null ? Unauthorized() : Ok(profile);
    }

    [Microsoft.AspNetCore.Authorization.Authorize, HttpPut("profile"), HttpPut("/admin/session/profile")]
    public async Task<IActionResult> UpdateProfile([FromForm] string name, [FromForm] string? phone, [FromForm] string? address, IFormFile? avatar, [FromForm] bool cover, CancellationToken token)
    {
        name = name.Trim();
        if (name.Length is < 1 or > 120 || phone?.Length > 25 || address?.Length > 400) return BadRequest();
        var id = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var user = await db.Users.SingleOrDefaultAsync(u => u.Id == id && u.Status, token);
        if (user is null) return Unauthorized();
        string? uploadedPath = null;
        if (avatar is not null)
        {
            if (avatar.Length is < 8 or > 2097152) return BadRequest();
            await using var source = avatar.OpenReadStream();
            var header = new byte[8];
            await source.ReadExactlyAsync(header, token);
            var extension = header.AsSpan().SequenceEqual(new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 }) ? ".png"
                : header[0] == 255 && header[1] == 216 && header[2] == 255 ? ".jpg" : null;
            if (extension is null) return BadRequest();
            var filename = Guid.NewGuid().ToString("N") + extension;
            uploadedPath = Path.Combine(environment.ContentRootPath, "uploads", filename);
            try
            {
                await using var destination = System.IO.File.Create(uploadedPath);
                await destination.WriteAsync(header, token);
                await source.CopyToAsync(destination, token);
            }
            catch
            {
                System.IO.File.Delete(uploadedPath);
                throw;
            }
            if (cover) user.CoverImage = "/product-uploads/" + filename;
            else user.Avatar = "/product-uploads/" + filename;
        }
        user.Name = name;
        user.PhoneNumber = phone?.Trim();
        if (Request.Form.ContainsKey("address"))
            user.Address = address?.Trim();
        user.UpdatedAt = DateTime.UtcNow;
        try { await db.SaveChangesAsync(token); }
        catch
        {
            if (uploadedPath is not null) System.IO.File.Delete(uploadedPath);
            throw;
        }
        return NoContent();
    }

    [Microsoft.AspNetCore.Authorization.Authorize, HttpGet("addresses")]
    public async Task<IActionResult> Addresses(CancellationToken token)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var addresses = await db.ShippingAddresses.AsNoTracking().Where(a => a.UserId == userId)
            .Select(a => new { a.Id, a.FullName, a.Phone, a.Address, a.City, a.IsDefault }).ToListAsync(token);
        var distinct = addresses.GroupBy(a => string.Join("|", a.FullName.Trim().ToLowerInvariant(), a.Phone.Trim(), a.Address.Trim().ToLowerInvariant(), a.City.Trim().ToLowerInvariant()))
            .Select(group => group.OrderByDescending(a => a.IsDefault).ThenByDescending(a => a.Id).First());
        return Ok(distinct);
    }

    public sealed record AddressRequest(
        [System.ComponentModel.DataAnnotations.Required, System.ComponentModel.DataAnnotations.StringLength(120)] string FullName,
        [System.ComponentModel.DataAnnotations.Required, System.ComponentModel.DataAnnotations.StringLength(25)] string Phone,
        [System.ComponentModel.DataAnnotations.Required, System.ComponentModel.DataAnnotations.StringLength(400)] string Address,
        [System.ComponentModel.DataAnnotations.Required, System.ComponentModel.DataAnnotations.StringLength(100)] string City);

    [Microsoft.AspNetCore.Authorization.Authorize, HttpPost("addresses")]
    public async Task<IActionResult> AddAddress(AddressRequest request, CancellationToken token)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await using var transaction = await db.Database.BeginTransactionAsync(token);
        await db.Users.Where(u => u.Id == userId).ExecuteUpdateAsync(s => s.SetProperty(u => u.UpdatedAt, u => u.UpdatedAt), token);
        if (await db.ShippingAddresses.AnyAsync(a => a.UserId == userId && a.FullName == request.FullName.Trim()
            && a.Phone == request.Phone.Trim() && a.Address == request.Address.Trim() && a.City == request.City.Trim(), token))
            return NoContent();
        db.ShippingAddresses.Add(new ShippingAddress
        {
            UserId = userId, FullName = request.FullName.Trim(), Phone = request.Phone.Trim(),
            Address = request.Address.Trim(), City = request.City.Trim()
        });
        await db.SaveChangesAsync(token);
        await transaction.CommitAsync(token);
        return NoContent();
    }

    [Microsoft.AspNetCore.Authorization.Authorize, HttpPut("addresses/{id:int}/default")]
    public async Task<IActionResult> SetDefaultAddress(int id, CancellationToken token)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await using var transaction = await db.Database.BeginTransactionAsync(token);
        await db.Users.Where(u => u.Id == userId)
            .ExecuteUpdateAsync(set => set.SetProperty(u => u.UpdatedAt, u => u.UpdatedAt), token);
        var addresses = db.ShippingAddresses.Where(a => a.UserId == userId);
        if (!await addresses.AnyAsync(a => a.Id == id, token)) return NotFound();
        await addresses.Where(a => a.IsDefault || a.Id == id)
            .ExecuteUpdateAsync(set => set.SetProperty(a => a.IsDefault, a => a.Id == id), token);
        await transaction.CommitAsync(token);
        return NoContent();
    }

    [Microsoft.AspNetCore.Authorization.Authorize, HttpPut("addresses/{id:int}")]
    public async Task<IActionResult> UpdateAddress(int id, AddressRequest request, CancellationToken token)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await using var transaction = await db.Database.BeginTransactionAsync(token);
        await db.Users.Where(u => u.Id == userId)
            .ExecuteUpdateAsync(set => set.SetProperty(u => u.UpdatedAt, u => u.UpdatedAt), token);
        var address = await db.ShippingAddresses.SingleOrDefaultAsync(a => a.Id == id && a.UserId == userId, token);
        if (address is null) return NotFound();

        if (await db.Orders.AnyAsync(o => o.ShippingAddressId == id, token))
        {
            var replacement = new ShippingAddress { UserId = userId, IsDefault = address.IsDefault };
            address.IsDefault = false;
            db.ShippingAddresses.Add(replacement);
            address = replacement;
        }

        address.FullName = request.FullName.Trim();
        address.Phone = request.Phone.Trim();
        address.Address = request.Address.Trim();
        address.City = request.City.Trim();
        await db.SaveChangesAsync(token);
        await transaction.CommitAsync(token);
        return NoContent();
    }

    [HttpPost("logout"), HttpPost("/admin/session/logout")]
    public async Task<IActionResult> Logout()
    {
        await HttpContext.SignOutAsync();
        return NoContent();
    }
}







