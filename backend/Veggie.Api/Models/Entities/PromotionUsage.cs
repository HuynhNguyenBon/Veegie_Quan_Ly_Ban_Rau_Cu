namespace Veggie.Api.Models.Entities;

public sealed class PromotionUsage
{
    public int Id { get; set; }
    public int PromotionId { get; set; }
    public int UserId { get; set; }
    public int OrderId { get; set; }
    public decimal DiscountAmount { get; set; }
    public DateTime UsedAt { get; set; }
}
