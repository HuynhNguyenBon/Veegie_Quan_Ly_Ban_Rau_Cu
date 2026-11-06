using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;

namespace Veggie.Api.Controllers;

public sealed record ContactRequest(
    [Required, StringLength(120)] string Name,
    [Required, EmailAddress, StringLength(254)] string Email,
    [StringLength(25)] string? Phone,
    [Required, StringLength(2000)] string Message);

[ApiController, Route("api/contacts")]
public sealed class ContactsController(VeggieDbContext db, IConfiguration config) : ControllerBase
{
    [HttpPost, EnableRateLimiting("account")]
    public async Task<IActionResult> Create(ContactRequest request, CancellationToken token)
    {
        db.Contacts.Add(new Contact
        {
            FullName = request.Name.Trim(), Email = request.Email.Trim(),
            PhoneNumber = request.Phone?.Trim(), Message = request.Message.Trim()
        });
        db.StoreEmailQueue.Add(new StoreEmail
        {
            ToEmail = config["Email:ContactTo"] ?? "huynhnguyenbon@gmail.com",
            ReplyTo = request.Email.Trim(),
            Subject = request.Message.StartsWith("[Yêu cầu báo giá]", StringComparison.Ordinal) ? "Veggie · Yêu cầu báo giá mới" : "Veggie · Lời nhắn mới từ khách hàng",
            Body = $"Họ tên: {request.Name.Trim()}\nEmail: {request.Email.Trim()}\nĐiện thoại: {request.Phone?.Trim()}\n\n{request.Message.Trim()}\n\nBạn cũng có thể xem và quản lý yêu cầu tại trang Admin /admin/contacts."
        });
        foreach(var adminId in await db.Users.Where(u=>u.Status && (u.Role.Name=="Admin"||u.Role.Name=="Staff")).Select(u=>u.Id).ToListAsync(token))
            db.Notifications.Add(new Notification{UserId=adminId,Type="admin-contact",Message="Liên hệ mới từ "+request.Name.Trim()});
        await db.SaveChangesAsync(token);
        return NoContent();
    }
}
