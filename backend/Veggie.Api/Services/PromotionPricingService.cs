using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Services;

public sealed record PromotionCalculation(
    bool IsValid,
    string? Error,
    int? PromotionId,
    string? Code,
    string? Description,
    decimal DiscountAmount);

public sealed class PromotionPricingService(VeggieDbContext db)
{
    public async Task<PromotionCalculation> CalculateAsync(
        int userId, decimal subtotal, string? requestedCode, bool reserve, CancellationToken token)
    {
        var code = requestedCode?.Trim().ToUpperInvariant();
        if (string.IsNullOrEmpty(code))
            return new(true, null, null, null, null, 0);
        if (code.Length > 40)
            return Invalid("Mã khuyến mãi không hợp lệ.");

        var promotion = await db.Promotions.SingleOrDefaultAsync(p => p.Code == code, token);
        var now = DateTime.UtcNow;
        if (promotion is null || !promotion.IsActive || promotion.StartsAt > now || promotion.ExpiresAt <= now)
            return Invalid("Mã khuyến mãi không tồn tại hoặc đã hết hạn.");
        if (promotion.AssignedUserId is not null && promotion.AssignedUserId != userId)
            return Invalid("Mã này được cấp cho tài khoản khác.");
        if (subtotal < promotion.MinimumSubtotal)
            return Invalid($"Đơn hàng cần đạt {promotion.MinimumSubtotal:N0}₫ để dùng mã này.");
        if (promotion.UsageLimit is int totalLimit && promotion.UsageCount >= totalLimit)
            return Invalid("Mã khuyến mãi đã hết lượt sử dụng.");

        var userUses = await db.PromotionUsages.CountAsync(u => u.PromotionId == promotion.Id && u.UserId == userId, token);
        if (userUses >= promotion.MaxUsesPerUser)
            return Invalid("Tài khoản đã sử dụng mã này đủ số lần cho phép.");

        var discount = promotion.DiscountType == "percent"
            ? decimal.Floor(subtotal * promotion.DiscountValue / 100m)
            : promotion.DiscountValue;
        if (promotion.MaximumDiscount is decimal cap)
            discount = Math.Min(discount, cap);
        discount = Math.Clamp(discount, 0, subtotal);

        if (reserve)
        {
            var reserved = await db.Promotions
                .Where(p => p.Id == promotion.Id && p.IsActive && p.StartsAt <= now && p.ExpiresAt > now &&
                    (p.UsageLimit == null || p.UsageCount < p.UsageLimit))
                .ExecuteUpdateAsync(set => set.SetProperty(p => p.UsageCount, p => p.UsageCount + 1), token);
            if (reserved != 1)
                return Invalid("Mã khuyến mãi vừa hết lượt. Hãy thử mã khác.");
        }

        return new(true, null, promotion.Id, promotion.Code, promotion.Description, discount);
    }

    private static PromotionCalculation Invalid(string error) => new(false, error, null, null, null, 0);
}
