using System;
using System.Collections.Generic;

namespace Veggie.Api.Models.Entities;

public partial class Permission
{
    public int Id { get; set; }

    public DateTime CreatedAt { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<Role> Roles { get; set; } = new List<Role>();
}
