using System;
using System.Collections.Generic;

namespace Veggie.Api.Models.Entities;

public partial class Wishlist
{
    public int Id { get; set; }

    public DateTime CreatedAt { get; set; }

    public int UserId { get; set; }

    public int ProductId { get; set; }

    public virtual Product Product { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
