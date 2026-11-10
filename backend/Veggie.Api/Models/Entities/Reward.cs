namespace Veggie.Api.Models.Entities;

public sealed class Reward
{
    public int Id { get; set; }
    public string Name { get; set; } = null!;
    public string Description { get; set; } = null!;
    public int PointsCost { get; set; }
    public string RewardType { get; set; } = null!;
    public int? Stock { get; set; }
    public decimal? DiscountAmount { get; set; }
    public decimal MinimumOrderAmount { get; set; }
    public int ValidityDays { get; set; } = 30;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
}
