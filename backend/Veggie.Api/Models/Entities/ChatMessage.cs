namespace Veggie.Api.Models.Entities;
public sealed class ChatMessage
{
 public int Id {get;set;} public int? UserId {get;set;} public string? GuestToken {get;set;}
 public string Question {get;set;}=""; public string Answer {get;set;}=""; public DateTime CreatedAt {get;set;}=DateTime.UtcNow;
}
