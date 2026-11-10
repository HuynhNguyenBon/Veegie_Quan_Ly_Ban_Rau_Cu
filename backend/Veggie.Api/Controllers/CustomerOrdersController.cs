using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;
using Veggie.Api.Services;
namespace Veggie.Api.Controllers;
[ApiController,Authorize,Route("api/orders")]
public sealed class CustomerOrdersController(VeggieDbContext db, LoyaltyPointsService loyaltyPoints):ControllerBase
{
 private int UserId=>int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
 [HttpGet("{id:int}")]
 public async Task<IActionResult> Details(int id,CancellationToken token){var o=await db.Orders.AsNoTracking().Where(o=>o.Id==id&&o.UserId==UserId).Select(o=>new{o.Id,o.Status,o.TotalPrice,o.Subtotal,o.DiscountAmount,o.ShippingFee,o.PromotionCode,o.CreatedAt,Address=new{o.ShippingAddress.FullName,o.ShippingAddress.Phone,o.ShippingAddress.Address,o.ShippingAddress.City},Items=o.OrderItems.Select(i=>new{i.ProductId,Name=i.Product.Name,i.Quantity,i.Price,Image=i.Product.ProductImages.OrderBy(p=>p.Id).Select(p=>p.Image).FirstOrDefault()}),History=o.OrderStatusHistories.Select(h=>new{h.Status,h.CreatedAt})}).SingleOrDefaultAsync(token);return o is null?NotFound():Ok(o);}
 [HttpPost("{id:int}/cancel")]
 public async Task<IActionResult> Cancel(int id,CancellationToken token){await using var tx=await db.Database.BeginTransactionAsync(token);
 var changed=await db.Orders.Where(o=>o.Id==id&&o.UserId==UserId&&o.Status=="pending"&&(o.Payment==null||o.Payment.Status!="paid")).ExecuteUpdateAsync(s=>s.SetProperty(o=>o.Status,"cancelled"),token);
 if(changed!=1)return Conflict(new{message="Chỉ hủy được đơn chưa xác nhận và chưa thanh toán. Nếu đã chuyển tiền, hãy liên hệ cửa hàng."});
 var items=await db.OrderItems.Where(i=>i.OrderId==id).OrderBy(i=>i.ProductId).ToListAsync(token);foreach(var i in items)await db.Products.Where(p=>p.Id==i.ProductId).ExecuteUpdateAsync(s=>s.SetProperty(p=>p.Stock,p=>p.Stock+i.Quantity),token);
 var promoUsage=await db.PromotionUsages.SingleOrDefaultAsync(u=>u.OrderId==id,token);if(promoUsage is not null){await db.Promotions.Where(p=>p.Id==promoUsage.PromotionId&&p.UsageCount>0).ExecuteUpdateAsync(s=>s.SetProperty(p=>p.UsageCount,p=>p.UsageCount-1),token);db.PromotionUsages.Remove(promoUsage);}
 await db.Payments.Where(p=>p.OrderId==id&&p.Status=="pending").ExecuteUpdateAsync(s=>s.SetProperty(p=>p.Status,"cancelled"),token);
 db.OrderStatusHistories.Add(new OrderStatusHistory{OrderId=id,Status="cancelled",ChangedAt=DateTime.UtcNow,Note="Khách hàng hủy đơn trước xác nhận."});db.Notifications.Add(new Notification{UserId=UserId,Type="order",Message=$"Đơn VG{id} đã hủy."});await db.SaveChangesAsync(token);await tx.CommitAsync(token);return NoContent();}
 [HttpPost("{id:int}/received")]
 public async Task<IActionResult> Received(int id,CancellationToken token){await using var tx=await db.Database.BeginTransactionAsync(token);var changed=await db.Orders.Where(o=>o.Id==id&&o.UserId==UserId&&o.Status=="shipping"&&(o.Payment==null||o.Payment.PaymentMethod=="COD"||o.Payment.Status=="paid")).ExecuteUpdateAsync(s=>s.SetProperty(o=>o.Status,"delivered"),token);if(changed!=1)return Conflict(new{message="Đơn không ở trạng thái đang giao."});
 await db.Payments.Where(p=>p.OrderId==id&&p.PaymentMethod=="COD"&&p.Status=="pending").ExecuteUpdateAsync(s=>s.SetProperty(p=>p.Status,"paid").SetProperty(p=>p.PaidAt,DateTime.UtcNow),token);
 db.OrderStatusHistories.Add(new OrderStatusHistory{OrderId=id,Status="delivered",ChangedAt=DateTime.UtcNow,Note="Khách hàng xác nhận đã nhận hàng."});db.Notifications.Add(new Notification{UserId=UserId,Type="order",Message=$"Đơn VG{id} đã hoàn thành. Bạn có thể đánh giá sản phẩm."});await loyaltyPoints.AwardForDeliveredOrderAsync(id,token);await db.SaveChangesAsync(token);await tx.CommitAsync(token);return NoContent();}
}
