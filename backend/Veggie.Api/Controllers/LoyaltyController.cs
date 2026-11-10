using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Controllers;

[ApiController, Authorize, Route("api/loyalty")]
public sealed class LoyaltyController(VeggieDbContext db) : ControllerBase
{
    private int UserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet]
    public async Task<IActionResult> Summary(CancellationToken token)
    {
        var userId = UserId;
        var settings = await db.LoyaltySettings.AsNoTracking().SingleAsync(s => s.Id == 1, token);
        var balance = await db.LoyaltyPointTransactions.AsNoTracking()
            .Where(p => p.UserId == userId).SumAsync(p => (int?)p.PointsDelta, token) ?? 0;
        var rewards = await db.Rewards.AsNoTracking().Where(r => r.IsActive)
            .OrderBy(r => r.PointsCost)
            .Select(r => new { r.Id, r.Name, r.Description, r.PointsCost, r.RewardType, r.Stock, r.DiscountAmount, r.MinimumOrderAmount })
            .ToListAsync(token);
        var redemptions = await db.RewardRedemptions.AsNoTracking().Where(r => r.UserId == userId)
            .OrderByDescending(r => r.Id).Take(50)
            .Select(r => new
            {
                r.Id,
                Status = r.PromotionId == null ? r.Status : db.PromotionUsages.Any(u => u.PromotionId == r.PromotionId)
                    ? "used" : db.Promotions.Where(p => p.Id == r.PromotionId).Select(p => p.ExpiresAt <= DateTime.UtcNow).FirstOrDefault()
                        ? "expired" : r.Status,
                r.PointsSpent, r.RedeemedAt, RewardName = r.Reward.Name,
                Code = r.PromotionId == null ? null : db.Promotions.Where(p => p.Id == r.PromotionId).Select(p => p.Code).FirstOrDefault(),
                ExpiresAt = r.PromotionId == null ? null : db.Promotions.Where(p => p.Id == r.PromotionId).Select(p => (DateTime?)p.ExpiresAt).FirstOrDefault()
            }).ToListAsync(token);
        var transactions = await db.LoyaltyPointTransactions.AsNoTracking().Where(p => p.UserId == userId)
            .OrderByDescending(p => p.Id).Take(30)
            .Select(p => new { p.PointsDelta, p.Type, p.Note, p.CreatedAt }).ToListAsync(token);

        return Ok(new { balance, settings.CurrencyPerPoint, rewards, redemptions, transactions });
    }

    [HttpPost("rewards/{id:int}/redeem")]
    public async Task<IActionResult> Redeem(int id, CancellationToken token)
    {
        var userId = UserId;
        await using var transaction = await db.Database.BeginTransactionAsync(token);
        await db.Users.Where(u => u.Id == userId)
            .ExecuteUpdateAsync(set => set.SetProperty(u => u.UpdatedAt, u => u.UpdatedAt), token);

        var reward = await db.Rewards.SingleOrDefaultAsync(r => r.Id == id && r.IsActive, token);
        if (reward is null) return NotFound(new { message = "Quà này hiện không còn khả dụng." });
        var balance = await db.LoyaltyPointTransactions.Where(p => p.UserId == userId)
            .SumAsync(p => (int?)p.PointsDelta, token) ?? 0;
        if (balance < reward.PointsCost)
            return Conflict(new { message = $"Bạn cần {reward.PointsCost - balance} điểm nữa để đổi quà này.", balance });

        var stockUpdated = await db.Rewards.Where(r => r.Id == id && r.IsActive && (r.Stock == null || r.Stock > 0))
            .ExecuteUpdateAsync(set => set.SetProperty(r => r.Stock, r => r.Stock - 1), token);
        if (stockUpdated != 1)
            return Conflict(new { message = "Quà vừa hết. Vui lòng chọn phần thưởng khác." });

        var now = DateTime.UtcNow;
        Promotion? voucher = null;
        if (reward.RewardType == "voucher")
        {
            voucher = new Promotion
            {
                Code = "VEG" + Guid.NewGuid().ToString("N")[..12].ToUpperInvariant(),
                Description = $"Voucher đổi điểm: {reward.Name}",
                DiscountType = "amount",
                DiscountValue = reward.DiscountAmount!.Value,
                MinimumSubtotal = reward.MinimumOrderAmount,
                StartsAt = now,
                ExpiresAt = now.AddDays(reward.ValidityDays),
                UsageLimit = 1,
                MaxUsesPerUser = 1,
                AssignedUserId = userId,
                IsActive = true
            };
            db.Promotions.Add(voucher);
            await db.SaveChangesAsync(token);
        }

        var redemption = new RewardRedemption
        {
            UserId = userId,
            RewardId = reward.Id,
            PromotionId = voucher?.Id,
            PointsSpent = reward.PointsCost,
            Status = voucher is null ? "pending" : "issued"
        };
        db.RewardRedemptions.Add(redemption);
        await db.SaveChangesAsync(token);
        db.LoyaltyPointTransactions.Add(new LoyaltyPointTransaction
        {
            UserId = userId,
            PointsDelta = -reward.PointsCost,
            Type = "REDEEM",
            RedemptionId = redemption.Id,
            Note = $"Đổi quà: {reward.Name}."
        });
        await db.SaveChangesAsync(token);
        await transaction.CommitAsync(token);

        return Ok(new
        {
            message = voucher is null ? "Đã đổi quà. Cửa hàng sẽ liên hệ để sắp xếp nhận quà." : "Đã đổi quà. Mã voucher đã có trong tài khoản của bạn.",
            balance = balance - reward.PointsCost,
            code = voucher?.Code,
            redemptionId = redemption.Id
        });
    }
}
