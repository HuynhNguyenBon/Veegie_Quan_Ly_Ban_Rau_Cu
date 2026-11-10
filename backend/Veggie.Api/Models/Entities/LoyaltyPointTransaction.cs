namespace Veggie.Api.Models.Entities;

public sealed class LoyaltyPointTransaction
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int PointsDelta { get; set; }
    public string Type { get; set; } = null!;
    public int? OrderId { get; set; }
    public int? RedemptionId { get; set; }
    public string Note { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
}
