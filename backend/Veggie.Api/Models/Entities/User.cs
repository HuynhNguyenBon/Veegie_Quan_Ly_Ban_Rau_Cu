using System;
using System.Collections.Generic;

namespace Veggie.Api.Models.Entities;

public partial class User
{
    public int Id { get; set; }

    public DateTime CreatedAt { get; set; }

    public string Name { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string? PasswordHash { get; set; }

    public bool Status { get; set; }

    public string? PhoneNumber { get; set; }

    public string? Avatar { get; set; }
    public string? CoverImage { get; set; }

    public string? Address { get; set; }

    public int RoleId { get; set; }

    public string? ActivationToken { get; set; }

    public string? GoogleId { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ICollection<CartItem> CartItems { get; set; } = new List<CartItem>();

    public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();

    public virtual ICollection<Order> Orders { get; set; } = new List<Order>();

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual Role Role { get; set; } = null!;

    public virtual ICollection<ShippingAddress> ShippingAddresses { get; set; } = new List<ShippingAddress>();

    public virtual ICollection<Wishlist> Wishlists { get; set; } = new List<Wishlist>();
}

