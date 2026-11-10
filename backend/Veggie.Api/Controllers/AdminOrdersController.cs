using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;
using Veggie.Api.Services;

namespace Veggie.Api.Controllers;

[Authorize(Roles = "Admin"), Route("admin/orders")]
public sealed class AdminOrdersController(VeggieDbContext db, LoyaltyPointsService loyaltyPoints) : Controller
{
    [HttpGet]
    public async Task<IActionResult> Index(CancellationToken token) =>
        View(await db.Orders.AsNoTracking().Include(o => o.Payment).Include(o => o.User).Include(o => o.ShippingAddress).OrderByDescending(o => o.Id).Take(100).ToListAsync(token));


    [HttpPost("{id:int}/bank-paid"), ValidateAntiForgeryToken]
    public async Task<IActionResult> ConfirmBankPayment(int id, string? transactionId, decimal receivedAmount, bool checkedBank, CancellationToken token)
    {
        transactionId = transactionId?.Trim().ToUpperInvariant();
        if (!ModelState.IsValid || !checkedBank || string.IsNullOrWhiteSpace(transactionId) ||
            !System.Text.RegularExpressions.Regex.IsMatch(transactionId, @"^[A-Z0-9][A-Z0-9._/-]{3,149}$") || receivedAmount <= 0)
        {
            TempData["PaymentError"] = "Cần nhập mã giao dịch hợp lệ, số tiền thực nhận và xác nhận đã kiểm tra ngân hàng.";
            return RedirectToAction(nameof(Index));
        }
        await using var transaction = await db.Database.BeginTransactionAsync(token);
        var locked = await db.Orders.Where(o => o.Id == id && o.Status == "pending")
            .ExecuteUpdateAsync(set => set.SetProperty(o => o.Status, "pending"), token);
        if (locked != 1) return Conflict("Đơn không còn chờ xác nhận.");
        var payment = await db.Payments.AsNoTracking().SingleOrDefaultAsync(p => p.OrderId == id, token);
        var total = await db.Orders.Where(o => o.Id == id).Select(o => o.TotalPrice).SingleAsync(token);
        if (payment is null || payment.PaymentMethod != "BankTransfer" || payment.Status != "pending" ||
            payment.Amount != receivedAmount || total != receivedAmount)
        {
            TempData["PaymentError"] = "Không thể xác nhận: đơn không chờ chuyển khoản hoặc số tiền thực nhận không khớp tổng đơn.";
            return RedirectToAction(nameof(Index));
        }
        if (await db.Payments.AnyAsync(p => p.PaymentMethod == "BankTransfer" && p.BankTransactionId == transactionId, token))
        {
            TempData["PaymentError"] = "Mã giao dịch đã được dùng cho một đơn hàng. Hãy kiểm tra lại ngân hàng.";
            return RedirectToAction(nameof(Index));
        }
        int changed;
        try
        {
        changed = await db.Payments.Where(p => p.OrderId == id && p.PaymentMethod == "BankTransfer" && p.Status == "pending")
            .ExecuteUpdateAsync(set => set.SetProperty(p => p.Status, "paid")
                .SetProperty(p => p.BankTransactionId, transactionId)
                .SetProperty(p => p.PaidAt, DateTime.UtcNow), token);
        }
        catch (Microsoft.Data.SqlClient.SqlException ex) when (ex.Number is 2601 or 2627)
        {
            TempData["PaymentError"] = "Mã giao dịch đã được xác nhận cho đơn khác. Không thể dùng lại.";
            return RedirectToAction(nameof(Index));
        }
        if (changed == 1)
        {
            var userId = await db.Orders.Where(o => o.Id == id).Select(o => o.UserId).SingleAsync(token);
            db.Notifications.Add(new Notification { UserId = userId, Type = "payment", Message = $"Đã xác nhận chuyển khoản cho đơn VG{id}." });
            db.OrderStatusHistories.Add(new OrderStatusHistory { OrderId = id, Status = "pending", ChangedAt = DateTime.UtcNow,
                Note = $"Admin {User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value} đối chiếu ngân hàng: {transactionId}; thực nhận {receivedAmount:0} VND." });
            await db.SaveChangesAsync(token);
        }
        await transaction.CommitAsync(token);
        TempData["PaymentSuccess"] = $"Đã ghi nhận đối chiếu chuyển khoản đơn VG{id}.";
        return RedirectToAction(nameof(Index));
    }

    [HttpPost("{id:int}"), ValidateAntiForgeryToken]
    public async Task<IActionResult> Advance(int id, string current, CancellationToken token)
    {
        var next = current switch
        {
            "pending" => "confirmed",
            "confirmed" => "shipping",
            "shipping" => "delivered",
            _ => null
        };
        if (next is null) return BadRequest();
        await using var transaction = await db.Database.BeginTransactionAsync(token);
        var changed = await db.Orders.Where(o => o.Id == id && o.Status == current && (o.Payment == null || (o.Payment.PaymentMethod != "MoMo" && o.Payment.PaymentMethod != "BankTransfer") || o.Payment.Status == "paid"))
            .ExecuteUpdateAsync(set => set.SetProperty(o => o.Status, next), token);
        if (changed != 1) return Conflict();
        db.OrderStatusHistories.Add(new OrderStatusHistory { OrderId = id, Status = next });
        if (next == "delivered")
            await db.Payments.Where(p => p.OrderId == id && p.PaymentMethod == "COD" && p.Status == "pending")
                .ExecuteUpdateAsync(set => set.SetProperty(p => p.Status, "paid").SetProperty(p => p.PaidAt, DateTime.UtcNow), token);
        var userId = await db.Orders.Where(o => o.Id == id).Select(o => o.UserId).SingleAsync(token);
        var description = next switch
        {
            "confirmed" => "đã được xác nhận",
            "shipping" => "đang được giao",
            _ => "đã giao thành công"
        };
        db.Notifications.Add(new Notification
        {
            UserId = userId, Type = "order", Message = $"Đơn VG{id} {description}."
        });
        if (next == "delivered")
            await loyaltyPoints.AwardForDeliveredOrderAsync(id, token);
        await db.SaveChangesAsync(token);
        await transaction.CommitAsync(token);
        return RedirectToAction(nameof(Index));
    }
}



