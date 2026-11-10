namespace Veggie.Api.Models.Entities;

public sealed class LoyaltySettings
{
    public int Id { get; set; }
    public int CurrencyPerPoint { get; set; }
    public DateTime UpdatedAt { get; set; }
}
