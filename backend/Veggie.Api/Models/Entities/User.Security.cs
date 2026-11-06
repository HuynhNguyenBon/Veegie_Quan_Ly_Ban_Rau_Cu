namespace Veggie.Api.Models.Entities;

public partial class User
{
    public bool EmailConfirmed { get; set; }
    public string SecurityStamp { get; set; } = Guid.NewGuid().ToString();
}

public sealed class AccountToken
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string Purpose { get; set; } = "";
    public string TokenHash { get; set; } = "";
    public DateTime CreatedAt { get; set; }
    public DateTime ExpiresAt { get; set; }
    public DateTime? UsedAt { get; set; }
}
