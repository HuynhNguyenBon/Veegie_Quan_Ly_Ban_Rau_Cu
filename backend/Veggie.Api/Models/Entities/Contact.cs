using System;
using System.Collections.Generic;

namespace Veggie.Api.Models.Entities;

public partial class Contact
{
    public int Id { get; set; }

    public DateTime CreatedAt { get; set; }

    public string FullName { get; set; } = null!;

    public string? PhoneNumber { get; set; }

    public string Email { get; set; } = null!;

    public string Message { get; set; } = null!;

    public bool IsReply { get; set; }
}
