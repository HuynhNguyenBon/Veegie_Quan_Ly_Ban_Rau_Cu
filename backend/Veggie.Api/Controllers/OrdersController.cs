using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Controllers;

public sealed record CheckoutLine([Range(1, int.MaxValue)] int Id, [Range(1, 100)] int Quantity);
public sealed record CheckoutRequest(
    [Required, StringLength(120)] string Name,
    [Required, StringLength(25)] string Phone,
    [Required, StringLength(400)] string Address,
    [Required, StringLength(100)] string City,
    [StringLength(500)] string? Note,
    [Required, MinLength(1), MaxLength(100)] CheckoutLine[] Items, Guid? RequestId, string PaymentMethod = "COD");

[ApiController, Authorize, Route("api/orders")]
public sealed class OrdersController(VeggieDbContext db) : ControllerBase
{
    private int UserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpPost]
    public async Task<IActionResult> Place(CheckoutRequest request, CancellationToken token)
    {
        if (request.PaymentMethod is not ("COD" or "BankTransfer"))
            return BadRequest(new { message = "Phương thức thanh toán không hợp lệ." });
        if (request.Items.Any(i => i is null) || request.Items.Select(i => i.Id).Distinct().Count() != request.Items.Length)
            return BadRequest(new { message = "Danh sách sản phẩm không hợp lệ." });

        await using var transaction = await db.Database.BeginTransactionAsync(token);
        await db.Users.Where(u => u.Id == UserId)
            .ExecuteUpdateAsync(set => set.SetProperty(u => u.UpdatedAt, u => u.UpdatedAt), token);
        var requestReference = request.RequestId is { } key ? $"checkout:{key:N}" : null;
        if (requestReference is not null)
        {
            var existing = await db.Payments.AsNoTracking()
                .Where(p => p.Order.UserId == UserId && p.TransactionId == requestReference)
                .Select(p => new { p.OrderId, p.Order.TotalPrice }).FirstOrDefaultAsync(token);
            if (existing is not null)
                return Ok(new { code = $"VG{existing.OrderId}", total = existing.TotalPrice });
        }
        var order = new Order { UserId = UserId, Status = "pending" };
        foreach (var line in request.Items.OrderBy(i => i.Id))
        {
            var product = db.Products.Where(p => p.Id == line.Id && p.Status && p.Stock >= line.Quantity);
            var updated = await product.ExecuteUpdateAsync(s => s.SetProperty(p => p.Stock, p => p.Stock - line.Quantity), token);
            if (updated != 1)
                return Conflict(new { message = "Sản phẩm không đủ tồn kho." });
            var price = await db.Products.Where(p => p.Id == line.Id).Select(p => p.Price).SingleAsync(token);
            order.OrderItems.Add(new OrderItem { ProductId = line.Id, Quantity = line.Quantity, Price = price });
            order.TotalPrice += price * line.Quantity;
        }

        if (order.TotalPrice < 300000) order.TotalPrice += 25000;
        var address = await db.ShippingAddresses.Where(a => a.UserId == UserId &&
            a.FullName == request.Name.Trim() && a.Phone == request.Phone.Trim() &&
            a.Address == request.Address.Trim() && a.City == request.City.Trim())
            .OrderByDescending(a => a.IsDefault).ThenByDescending(a => a.Id).FirstOrDefaultAsync(token);
        if (address is null)
        {
            address = new ShippingAddress { UserId = UserId, FullName = request.Name.Trim(), Phone = request.Phone.Trim(),
                Address = request.Address.Trim(), City = request.City.Trim() };
            db.ShippingAddresses.Add(address);
        }
        await db.SaveChangesAsync(token);
        order.ShippingAddressId = address.Id;
        order.OrderStatusHistories.Add(new OrderStatusHistory { Status = "pending", Note = request.Note });
        order.Payment = new Payment { PaymentMethod = request.PaymentMethod, TransactionId = requestReference, Amount = order.TotalPrice, Status = "pending" };
        db.Orders.Add(order);
        await db.SaveChangesAsync(token);
        var productIds = request.Items.Select(line => line.Id).ToArray();
        await db.CartItems.Where(item => item.UserId == UserId && productIds.Contains(item.ProductId))
            .ExecuteDeleteAsync(token);
        foreach(var adminId in await db.Users.Where(u=>u.Status && u.Role.Name=="Admin").Select(u=>u.Id).ToListAsync(token))
            db.Notifications.Add(new Notification{UserId=adminId,Type="admin-order",Message="Đơn hàng mới VG"+order.Id});
        await db.SaveChangesAsync(token);
        await transaction.CommitAsync(token);
        return Ok(new { code = $"VG{order.Id}", total = order.TotalPrice });
    }

    public sealed record TrackingRequest([Required, StringLength(12)] string Code,
        [Required, EmailAddress, StringLength(254)] string Email);

    [HttpPost("track")]
    public async Task<IActionResult> Track(TrackingRequest request, CancellationToken token)
    {
        var code = request.Code.Trim();
        if (!code.StartsWith("VG", StringComparison.OrdinalIgnoreCase) ||
            !int.TryParse(code.AsSpan(2), out var id) || id < 1)
            return BadRequest(new { message = "Mã đơn phải có dạng VG1." });
        var email = request.Email.Trim().ToLowerInvariant();
        var order = await db.Orders.AsNoTracking()
            .Where(o => o.Id == id && o.UserId == UserId && o.User.Email == email)
            .Select(o => new { o.TotalPrice, o.Status, o.CreatedAt }).SingleOrDefaultAsync(token);
        if (order is null) return NotFound(new { message = "Không tìm thấy đơn khớp với tài khoản và email." });
        return Ok(new { code = $"VG{id}", total = order.TotalPrice, order.Status, order.CreatedAt });
    }

    [HttpGet]
    public async Task<IActionResult> History(CancellationToken token)
    {
        var orders = await db.Orders.AsNoTracking().Where(o => o.UserId == UserId)
            .OrderByDescending(o => o.Id)
            .Select(o => new { o.Id, o.TotalPrice, o.Status, o.CreatedAt, PaymentStatus = o.Payment == null ? "" : o.Payment.Status, PaymentMethod = o.Payment == null ? "" : o.Payment.PaymentMethod }).ToListAsync(token);
        return Ok(orders.Select(o => new { code = $"VG{o.Id}", total = o.TotalPrice, o.Status, o.CreatedAt, o.PaymentStatus, o.PaymentMethod }));
    }
}




