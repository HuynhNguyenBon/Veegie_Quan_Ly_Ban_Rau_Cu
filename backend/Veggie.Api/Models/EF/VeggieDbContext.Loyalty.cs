using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Models.EF;

public partial class VeggieDbContext
{
    public DbSet<Promotion> Promotions => Set<Promotion>();
    public DbSet<PromotionUsage> PromotionUsages => Set<PromotionUsage>();
    public DbSet<Reward> Rewards => Set<Reward>();
    public DbSet<RewardRedemption> RewardRedemptions => Set<RewardRedemption>();
    public DbSet<LoyaltyPointTransaction> LoyaltyPointTransactions => Set<LoyaltyPointTransaction>();
    public DbSet<LoyaltySettings> LoyaltySettings => Set<LoyaltySettings>();
}
