namespace Veggie.Api.Models.Entities;

public sealed class NewsletterSubscription
{
    public int Id { get; set; }
    public string Email { get; set; } = "";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public sealed class StoreEmail
{
    public int Id { get; set; }
    public string ToEmail { get; set; } = "";
    public string? ReplyTo { get; set; }
    public string Subject { get; set; } = "";
    public string Body { get; set; } = "";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? SentAt { get; set; }
    public int Attempts { get; set; }
    public DateTime NextAttemptAt { get; set; } = DateTime.UtcNow;
}
