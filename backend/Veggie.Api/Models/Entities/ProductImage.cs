using System;
using System.Collections.Generic;

namespace Veggie.Api.Models.Entities;

public partial class ProductImage
{
    public int Id { get; set; }

    public DateTime CreatedAt { get; set; }

    public int ProductId { get; set; }

    public string Image { get; set; } = null!;

    public virtual Product Product { get; set; } = null!;
}
