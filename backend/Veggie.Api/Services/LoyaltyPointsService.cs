using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Services;

public sealed class LoyaltyPointsService(VeggieDbContext db)
{
    public async Task<int> AwardForDeliveredOrderAsync(int orderId, CancellationToken token)
    {
        if (await db.LoyaltyPointTransactions.AnyAsync(p => p.OrderId == orderId, token))
            return 0;

        var order = await db.Orders.AsNoTracking()
            .Where(o => o.Id == orderId && o.Status == "delivered" && o.Payment != null && o.Payment.Status == "paid")
            .Select(o => new { o.UserId, EligibleAmount = o.Subtotal - o.DiscountAmount })
            .SingleOrDefaultAsync(token);
        if (order is null) return 0;

        var settings = await db.LoyaltySettings.AsNoTracking().SingleAsync(s => s.Id == 1, token);
        var points = (int)decimal.Floor(Math.Max(0, order.EligibleAmount) / settings.CurrencyPerPoint);
        if (points <= 0) return 0;

        db.LoyaltyPointTransactions.Add(new LoyaltyPointTransaction
        {
            UserId = order.UserId,
            PointsDelta = points,
            Type = "EARN",
            OrderId = orderId,
            Note = $"Tích điểm đơn VG{orderId} đã giao thành công."
        });
        db.Notifications.Add(new Notification
        {
            UserId = order.UserId,
            Type = "loyalty",
            Message = $"Bạn nhận được {points} điểm từ đơn VG{orderId}."
        });
        return points;
    }
}
