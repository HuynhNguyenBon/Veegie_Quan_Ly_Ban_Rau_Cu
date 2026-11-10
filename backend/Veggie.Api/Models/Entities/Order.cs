using System;
using System.Collections.Generic;

namespace Veggie.Api.Models.Entities;

public partial class Order
{
    public int Id { get; set; }

    public DateTime CreatedAt { get; set; }

    public int UserId { get; set; }

    public decimal TotalPrice { get; set; }

    public decimal Subtotal { get; set; }

    public decimal DiscountAmount { get; set; }

    public decimal ShippingFee { get; set; }

    public string? PromotionCode { get; set; }

    public string Status { get; set; } = null!;

    public int ShippingAddressId { get; set; }

    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

    public virtual ICollection<OrderStatusHistory> OrderStatusHistories { get; set; } = new List<OrderStatusHistory>();

    public virtual Payment? Payment { get; set; }

    public virtual ShippingAddress ShippingAddress { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
