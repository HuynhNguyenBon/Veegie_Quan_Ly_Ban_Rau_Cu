using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Controllers;

public sealed record AdminLoyaltyRedemption(int Id, string Customer, string Email, string Reward,
    string Status, string? Code, DateTime RedeemedAt, int PointsSpent);
public sealed record AdminLoyaltyPageModel(IReadOnlyList<Promotion> Promotions, IReadOnlyList<Reward> Rewards,
    IReadOnlyList<AdminLoyaltyRedemption> Redemptions, int CurrencyPerPoint);

[Authorize(Roles = "Admin"), Route("admin/loyalty")]
public sealed class AdminLoyaltyController(VeggieDbContext db) : Controller
{
    [HttpGet]
    public async Task<IActionResult> Index(CancellationToken token)
    {
        var promotions = await db.Promotions.AsNoTracking().Where(p => p.AssignedUserId == null)
            .OrderByDescending(p => p.Id).Take(100).ToListAsync(token);
        var rewards = await db.Rewards.AsNoTracking().OrderBy(r => r.PointsCost).ToListAsync(token);
        var redemptions = await db.RewardRedemptions.AsNoTracking()
            .OrderByDescending(r => r.Id).Take(200)
            .Select(r => new AdminLoyaltyRedemption(r.Id, r.User.Name, r.User.Email, r.Reward.Name,
                r.PromotionId == null ? r.Status : db.PromotionUsages.Any(u => u.PromotionId == r.PromotionId)
                    ? "used" : db.Promotions.Where(p => p.Id == r.PromotionId).Select(p => p.ExpiresAt <= DateTime.UtcNow).FirstOrDefault()
                        ? "expired" : r.Status,
                r.PromotionId == null ? null : db.Promotions.Where(p => p.Id == r.PromotionId).Select(p => p.Code).FirstOrDefault(),
                r.RedeemedAt, r.PointsSpent))
            .ToListAsync(token);
        var setting = await db.LoyaltySettings.AsNoTracking().SingleAsync(s => s.Id == 1, token);
        return View(new AdminLoyaltyPageModel(promotions, rewards, redemptions, setting.CurrencyPerPoint));
    }

    [HttpPost("points-rate"), ValidateAntiForgeryToken]
    public async Task<IActionResult> UpdatePointsRate(int currencyPerPoint, CancellationToken token)
    {
        if (currencyPerPoint is < 100 or > 1_000_000)
        {
            TempData["AdminError"] = "Mức tích điểm phải từ 100₫ đến 1.000.000₫ cho mỗi điểm.";
            return RedirectToAction(nameof(Index));
        }
        await db.LoyaltySettings.Where(s => s.Id == 1)
            .ExecuteUpdateAsync(set => set.SetProperty(s => s.CurrencyPerPoint, currencyPerPoint)
                .SetProperty(s => s.UpdatedAt, DateTime.UtcNow), token);
        TempData["AdminMessage"] = "Đã cập nhật mức tích điểm cho các đơn giao thành công tiếp theo.";
        return RedirectToAction(nameof(Index));
    }

    [HttpPost("promotions"), ValidateAntiForgeryToken]
    public async Task<IActionResult> CreatePromotion(string? code, string? description, string? discountType,
        decimal discountValue, decimal minimumSubtotal, decimal? maximumDiscount, int? usageLimit,
        int maxUsesPerUser, DateTime expiresAt, CancellationToken token)
    {
        code = code?.Trim().ToUpperInvariant();
        description = description?.Trim();
        if (string.IsNullOrWhiteSpace(code) || !Regex.IsMatch(code, "^[A-Z0-9][A-Z0-9_-]{1,39}$") ||
            string.IsNullOrWhiteSpace(description) || description.Length > 240 ||
            discountType is not ("percent" or "amount") || discountValue <= 0 ||
            (discountType == "percent" && discountValue > 100) || minimumSubtotal < 0 || maximumDiscount is <= 0 ||
            usageLimit is <= 0 || maxUsesPerUser is < 1 or > 100 || expiresAt.Date <= DateTime.UtcNow.Date ||
            await db.Promotions.AnyAsync(p => p.Code == code, token))
        {
            TempData["AdminError"] = "Thông tin mã khuyến mãi không hợp lệ, ngày hết hạn phải ở tương lai và mã không được trùng.";
            return RedirectToAction(nameof(Index));
        }

        var expiry = DateTime.SpecifyKind(expiresAt.Date.AddDays(1).AddTicks(-1), DateTimeKind.Utc);
        db.Promotions.Add(new Promotion
        {
            Code = code,
            Description = description,
            DiscountType = discountType,
            DiscountValue = discountValue,
            MinimumSubtotal = minimumSubtotal,
            MaximumDiscount = discountType == "percent" ? maximumDiscount : null,
            StartsAt = DateTime.UtcNow,
            ExpiresAt = expiry,
            UsageLimit = usageLimit,
            MaxUsesPerUser = maxUsesPerUser,
            IsActive = true
        });
        await db.SaveChangesAsync(token);
        TempData["AdminMessage"] = $"Đã tạo mã {code}.";
        return RedirectToAction(nameof(Index));
    }

    [HttpPost("promotions/{id:int}/status"), ValidateAntiForgeryToken]
    public async Task<IActionResult> SetPromotionStatus(int id, bool active, CancellationToken token)
    {
        var changed = await db.Promotions.Where(p => p.Id == id && p.AssignedUserId == null)
            .ExecuteUpdateAsync(set => set.SetProperty(p => p.IsActive, active), token);
        if (changed != 1) return NotFound();
        TempData["AdminMessage"] = active ? "Đã bật mã khuyến mãi." : "Đã tắt mã khuyến mãi.";
        return RedirectToAction(nameof(Index));
    }

    [HttpPost("rewards"), ValidateAntiForgeryToken]
    public async Task<IActionResult> CreateReward(string? name, string? description, string? rewardType,
        int pointsCost, int? stock, decimal? discountAmount, decimal minimumOrderAmount, int validityDays,
        CancellationToken token)
    {
        name = name?.Trim();
        description = description?.Trim();
        if (string.IsNullOrWhiteSpace(name) || name.Length > 120 || string.IsNullOrWhiteSpace(description) ||
            description.Length > 500 || rewardType is not ("voucher" or "physical") || pointsCost is < 1 or > 1_000_000 ||
            stock is < 0 || minimumOrderAmount < 0 || validityDays is < 1 or > 365 ||
            (rewardType == "voucher" && discountAmount is <= 0))
        {
            TempData["AdminError"] = "Thông tin quà tặng không hợp lệ.";
            return RedirectToAction(nameof(Index));
        }
        db.Rewards.Add(new Reward
        {
            Name = name,
            Description = description,
            PointsCost = pointsCost,
            RewardType = rewardType,
            Stock = stock,
            DiscountAmount = rewardType == "voucher" ? discountAmount : null,
            MinimumOrderAmount = minimumOrderAmount,
            ValidityDays = validityDays,
            IsActive = true
        });
        await db.SaveChangesAsync(token);
        TempData["AdminMessage"] = $"Đã thêm quà {name}.";
        return RedirectToAction(nameof(Index));
    }

    [HttpPost("rewards/{id:int}/status"), ValidateAntiForgeryToken]
    public async Task<IActionResult> UpdateReward(int id, bool active, int? stock, CancellationToken token)
    {
        if (stock is < 0)
        {
            TempData["AdminError"] = "Tồn quà không thể âm.";
            return RedirectToAction(nameof(Index));
        }
        var changed = await db.Rewards.Where(r => r.Id == id)
            .ExecuteUpdateAsync(set => set.SetProperty(r => r.IsActive, active)
                .SetProperty(r => r.Stock, stock), token);
        if (changed != 1) return NotFound();
        TempData["AdminMessage"] = "Đã cập nhật trạng thái và tồn quà.";
        return RedirectToAction(nameof(Index));
    }

    [HttpPost("redemptions/{id:int}/fulfill"), ValidateAntiForgeryToken]
    public async Task<IActionResult> Fulfill(int id, CancellationToken token)
    {
        var changed = await db.RewardRedemptions.Where(r => r.Id == id && r.Status == "pending" && r.Reward.RewardType == "physical")
            .ExecuteUpdateAsync(set => set.SetProperty(r => r.Status, "fulfilled"), token);
        if (changed != 1) return Conflict("Yêu cầu đổi quà không còn chờ xử lý.");
        TempData["AdminMessage"] = "Đã đánh dấu quà vật lý là đã giao/đã nhận.";
        return RedirectToAction(nameof(Index));
    }
}
