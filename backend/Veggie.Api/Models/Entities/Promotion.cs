namespace Veggie.Api.Models.Entities;

public sealed class Promotion
{
    public int Id { get; set; }
    public string Code { get; set; } = null!;
    public string Description { get; set; } = null!;
    public string DiscountType { get; set; } = null!;
    public decimal DiscountValue { get; set; }
    public decimal MinimumSubtotal { get; set; }
    public decimal? MaximumDiscount { get; set; }
    public DateTime StartsAt { get; set; }
    public DateTime ExpiresAt { get; set; }
    public int? UsageLimit { get; set; }
    public int UsageCount { get; set; }
    public int MaxUsesPerUser { get; set; } = 1;
    public int? AssignedUserId { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
}
