using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;
namespace Veggie.Api.Controllers;
[Authorize(Roles="Admin"),Route("admin/orders")]
public class AdminOrderDetailsController(VeggieDbContext db):Controller
{
 [HttpGet("{id:int}/details")] public async Task<IActionResult> Details(int id,CancellationToken token){var order=await db.Orders.AsNoTracking().Include(o=>o.User).Include(o=>o.ShippingAddress).Include(o=>o.Payment).Include(o=>o.OrderItems).ThenInclude(i=>i.Product).ThenInclude(p=>p.ProductImages).Include(o=>o.OrderStatusHistories).SingleOrDefaultAsync(o=>o.Id==id,token);if(order is null)return NotFound();var subject=$"Chi tiết đơn hàng VG{id} · Veggie";ViewData["Mail"]=await db.StoreEmailQueue.AsNoTracking().Where(e=>e.Subject==subject).OrderByDescending(e=>e.Id).FirstOrDefaultAsync(token);return View(order);}
 [HttpPost("{id:int}/invoice"),ValidateAntiForgeryToken] public async Task<IActionResult> Invoice(int id,CancellationToken token){
 await using var tx=await db.Database.BeginTransactionAsync(token);await db.Orders.Where(o=>o.Id==id).ExecuteUpdateAsync(s=>s.SetProperty(o=>o.Status,o=>o.Status),token);
 var o=await db.Orders.AsNoTracking().Include(o=>o.User).Include(o=>o.ShippingAddress).Include(o=>o.Payment).Include(o=>o.OrderItems).ThenInclude(i=>i.Product).ThenInclude(p=>p.ProductImages).SingleOrDefaultAsync(o=>o.Id==id,token);
 if(o is null)return NotFound();if(o.Status is "cancelled" or "pending")return BadRequest("Chỉ gửi hóa đơn cho đơn đã xác nhận.");
 var subject=$"Chi tiết đơn hàng VG{id} · Veggie";if(await db.StoreEmailQueue.AnyAsync(e=>e.Subject==subject&&e.CreatedAt>DateTime.UtcNow.AddMinutes(-5),token)){TempData["AdminMessage"]="Hóa đơn đã được yêu cầu gửi trong 5 phút vừa qua.";return Redirect($"/admin/orders/{id}/details");}
 var subtotal=o.OrderItems.Sum(i=>i.Price*i.Quantity);
 string Encode(string? value)=>System.Net.WebUtility.HtmlEncode(value??"");
 var rows=string.Join("",o.OrderItems.Select(i=>$"<tr><td>{Encode(i.Product.Name)}</td><td>{i.Price:N0} ₫</td><td>{i.Quantity}</td><td>{i.Price*i.Quantity:N0} ₫</td></tr>"));
 var method=o.Payment?.PaymentMethod switch{"COD"=>"Thanh toán khi nhận hàng","BankTransfer"=>"Chuyển khoản ngân hàng","MoMo"=>"MoMo",_=>"Chưa có thông tin"};
 var body=$""" 
 <!doctype html><html lang="vi"><body style="font-family:Arial;color:#173329">
 <div style="max-width:680px;margin:auto;padding:24px">
 <p>Xin chào {Encode(o.User.Name)},</p>
 <h1 style="background:#238346;color:white;padding:14px">Hóa đơn mua hàng VG{id}</h1>
 <p>Ngày đặt: {o.CreatedAt:dd/MM/yyyy HH:mm}</p>
 <p>Người nhận: {Encode(o.ShippingAddress.FullName)}<br>{Encode(o.ShippingAddress.Address)}, {Encode(o.ShippingAddress.City)}<br>{Encode(o.ShippingAddress.Phone)}</p>
 <h2>Chi tiết đơn hàng</h2>
 <table cellpadding="8" cellspacing="0" style="width:100%;border:1px solid #ddd"><thead style="background:#238346;color:white"><tr><th>Sản phẩm</th><th>Giá</th><th>Số lượng</th><th>Thành tiền</th></tr></thead><tbody>{rows}</tbody></table>
 <p>Phương thức thanh toán: {method}</p>
 <p>Tiền hàng: {subtotal:N0} ₫<br>Phí giao hàng: {o.TotalPrice-subtotal:N0} ₫</p>
 <p style="background:#238346;color:white;padding:12px"><strong>Tổng tiền: {o.TotalPrice:N0} ₫</strong></p>
 <p>Cảm ơn bạn đã mua sắm tại Veggie.</p></div></body></html>
 """;
 db.StoreEmailQueue.Add(new StoreEmail{ToEmail=o.User.Email,Subject=subject,Body=body});
 await db.SaveChangesAsync(token);await tx.CommitAsync(token);TempData["AdminMessage"]="Đã đưa chi tiết đơn hàng vào hàng đợi gửi email.";return Redirect($"/admin/orders/{id}/details");}
}
