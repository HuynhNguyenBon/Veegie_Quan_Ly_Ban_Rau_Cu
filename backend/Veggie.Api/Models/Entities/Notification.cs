using System;
using System.Collections.Generic;

namespace Veggie.Api.Models.Entities;

public partial class Notification
{
    public int Id { get; set; }

    public DateTime CreatedAt { get; set; }

    public int UserId { get; set; }

    public string Type { get; set; } = null!;

    public string Message { get; set; } = null!;

    public bool IsRead { get; set; }

    public virtual User User { get; set; } = null!;
}
