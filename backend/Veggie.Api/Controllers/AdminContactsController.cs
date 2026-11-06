using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;
namespace Veggie.Api.Controllers;
[Authorize(Roles="Admin,Staff"),Route("admin/contacts")]
public sealed class AdminContactsController(VeggieDbContext db):Controller
{
 [HttpGet] public async Task<IActionResult> Index(int page,CancellationToken token){page=Math.Clamp(page,1,1000000);var list=await db.Contacts.AsNoTracking().OrderByDescending(c=>c.Id).Skip((page-1)*25).Take(26).ToListAsync(token);ViewData["Page"]=page;ViewData["HasNext"]=list.Count>25;return View(list.Take(25).ToList());}
 [HttpPost("{id:int}/reply"),ValidateAntiForgeryToken]
 public async Task<IActionResult> Reply(int id,string? reply,CancellationToken token){
 if(string.IsNullOrWhiteSpace(reply)||reply.Length>4000){TempData["AdminError"]="Nhập nội dung phản hồi, tối đa 4000 ký tự.";return Redirect("/admin/contacts#contact-"+id);}
 await using var tx=await db.Database.BeginTransactionAsync(token);
 var updated=await db.Contacts.Where(c=>c.Id==id&&!c.IsReply).ExecuteUpdateAsync(s=>s.SetProperty(c=>c.IsReply,true),token);
 if(updated!=1){TempData["AdminMessage"]="Liên hệ đã được phản hồi hoặc không tồn tại.";return Redirect("/admin/contacts#contact-"+id);}
 var contact=await db.Contacts.AsNoTracking().SingleAsync(c=>c.Id==id,token);
 db.StoreEmailQueue.Add(new StoreEmail{ToEmail=contact.Email,Subject="Veggie phản hồi yêu cầu liên hệ #"+id,Body=$"Phản hồi từ Quản trị viên Website Veggie\n\nXin chào {contact.FullName},\n\n{reply.Trim()}\n\nYêu cầu của bạn:\n{contact.Message}\n\nTrân trọng,\nCửa hàng Veggie"});
 await db.SaveChangesAsync(token);await tx.CommitAsync(token);TempData["AdminMessage"]="Phản hồi đã được đưa vào hàng đợi gửi email cho khách.";return Redirect("/admin/contacts#contact-"+id);}
}
