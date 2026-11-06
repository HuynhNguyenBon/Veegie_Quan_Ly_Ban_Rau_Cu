namespace Veggie.Api.Models.Entities;

public partial class Payment
{
    public string? GatewayOrderId { get; set; }
    public string? GatewayPayUrl { get; set; }
}
