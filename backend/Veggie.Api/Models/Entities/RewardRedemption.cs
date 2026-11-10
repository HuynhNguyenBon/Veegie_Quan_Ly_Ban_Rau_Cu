namespace Veggie.Api.Models.Entities;

public sealed class RewardRedemption
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int RewardId { get; set; }
    public int? PromotionId { get; set; }
    public int PointsSpent { get; set; }
    public string Status { get; set; } = null!;
    public DateTime RedeemedAt { get; set; }
    public User User { get; set; } = null!;
    public Reward Reward { get; set; } = null!;
    public Promotion? Promotion { get; set; }
}
