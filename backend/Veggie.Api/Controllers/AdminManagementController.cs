using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
namespace Veggie.Api.Controllers;
[Authorize(Roles="Admin"),Route("admin")]
public sealed class AdminManagementController(VeggieDbContext db,IWebHostEnvironment environment):Controller
{
 [HttpPost("products/{id:int}/archive"),ValidateAntiForgeryToken]
 public async Task<IActionResult> ArchiveProduct(int id,CancellationToken token)
 {
     var changed=await db.Products.Where(p=>p.Id==id).ExecuteUpdateAsync(s=>s.SetProperty(p=>p.Status,false),token);
     if(changed==0)return NotFound();
     TempData["AdminMessage"]="Đã ẩn sản phẩm khỏi cửa hàng.";
     return Redirect("/admin/products");
 }

 [HttpPost("categories/{id:int}/delete"),ValidateAntiForgeryToken]
 public async Task<IActionResult> DeleteCategory(int id,CancellationToken token)
 {
     try
     {
         var changed=await db.Categories.Where(c=>c.Id==id&&!c.Products.Any()).ExecuteDeleteAsync(token);
         TempData[changed==1?"AdminMessage":"AdminError"]=changed==1?"Đã xóa danh mục.":"Chỉ xóa được danh mục không có sản phẩm.";
     }
     catch (Exception e) when (e is Microsoft.Data.SqlClient.SqlException { Number:547 } || e.InnerException is Microsoft.Data.SqlClient.SqlException { Number:547 })
     {
         TempData["AdminError"]="Danh mục đang được sử dụng.";
     }
     return Redirect("/admin/categories");
 }

 [HttpPost("users/{id:int}/status"), ValidateAntiForgeryToken]
 public async Task<IActionResult> Status(int id, bool active, CancellationToken token)
 {
     var stamp = Guid.NewGuid().ToString();
     var changed = await ManageableUser(id).Where(u => u.DeletedAt == null)
         .ExecuteUpdateAsync(update => update.SetProperty(u => u.Status, active)
             .SetProperty(u => u.SecurityStamp, stamp), token);
     return UserResult(changed, active ? "Đã mở tài khoản." : "Đã chặn tài khoản.");
 }

 [HttpPost("users/{id:int}/role"), ValidateAntiForgeryToken]
 public async Task<IActionResult> Role(int id, string role, CancellationToken token)
 {
     if (role is not ("Staff" or "Customer")) return BadRequest();
     var roleId = await db.Roles.Where(r => r.Name == role).Select(r => r.Id).SingleAsync(token);
     var stamp = Guid.NewGuid().ToString();
     var changed = await ManageableUser(id).Where(u => u.DeletedAt == null)
         .ExecuteUpdateAsync(update => update.SetProperty(u => u.RoleId, roleId)
             .SetProperty(u => u.SecurityStamp, stamp), token);
     return UserResult(changed, "Đã cập nhật vai trò. Người dùng cần đăng nhập lại.");
 }

 [HttpPost("users/{id:int}/archive"), ValidateAntiForgeryToken]
 public async Task<IActionResult> ArchiveUser(int id, CancellationToken token)
 {
     var deletedAt = DateTime.UtcNow;
     var stamp = Guid.NewGuid().ToString();
     var changed = await ManageableUser(id).Where(u => u.DeletedAt == null)
         .ExecuteUpdateAsync(update => update.SetProperty(u => u.DeletedAt, deletedAt)
             .SetProperty(u => u.Status, false)
             .SetProperty(u => u.SecurityStamp, stamp), token);
     return UserResult(changed, "Đã xóa tài khoản. Lịch sử đơn hàng vẫn được lưu.");
 }

 [HttpPost("users/{id:int}/restore"), ValidateAntiForgeryToken]
 public async Task<IActionResult> RestoreUser(int id, CancellationToken token)
 {
     var stamp = Guid.NewGuid().ToString();
     var changed = await ManageableUser(id).Where(u => u.DeletedAt != null)
         .ExecuteUpdateAsync(update => update.SetProperty(u => u.DeletedAt, (DateTime?)null)
             .SetProperty(u => u.Status, true)
             .SetProperty(u => u.SecurityStamp, stamp), token);
     return UserResult(changed, "Đã khôi phục tài khoản.");
 }

 private IQueryable<Veggie.Api.Models.Entities.User> ManageableUser(int id)
 {
     var self = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
     return db.Users.Where(u => u.Id == id && u.Id != self && u.Role.Name != "Admin");
 }

 private IActionResult UserResult(int changed, string message)
 {
     TempData[changed == 1 ? "AdminMessage" : "AdminError"] =
         changed == 1 ? message : "Không thể thực hiện thao tác với tài khoản này.";
     return Redirect("/admin/users");
 }

 [HttpPost("categories/{id:int}"),ValidateAntiForgeryToken]
 public async Task<IActionResult> Category(int id,string? name,string? description,IFormFile? photo,CancellationToken token){
 if(string.IsNullOrWhiteSpace(name)||name.Trim().Length>100||description?.Length>2000)return BadRequest("Thông tin danh mục không hợp lệ.");
 var category=await db.Categories.SingleOrDefaultAsync(c=>c.Id==id,token);if(category is null)return NotFound();
 if(photo is { Length: > 0 })
 {
     if(photo.Length is < 8 or > 5242880)return BadRequest("Ảnh tối đa 5 MB.");
     await using var source=photo.OpenReadStream();
     var bytes=new byte[8];
     await source.ReadExactlyAsync(bytes,token);
     var extension=bytes.AsSpan().SequenceEqual(new byte[]{137,80,78,71,13,10,26,10})?".png":
         bytes[0]==255&&bytes[1]==216&&bytes[2]==255?".jpg":null;
     if(extension is null)return BadRequest("Chỉ chọn ảnh PNG hoặc JPEG.");
     var directory=Path.Combine(environment.ContentRootPath,"uploads");
     Directory.CreateDirectory(directory);
     var filename=Guid.NewGuid().ToString("N")+extension;
     await using(var target=System.IO.File.Create(Path.Combine(directory,filename)))
     {
         await target.WriteAsync(bytes,token);
         await source.CopyToAsync(target,token);
     }
     category.Image="/product-uploads/"+filename;
 }
 category.Name=name.Trim();category.Description=description?.Trim();category.UpdatedAt=DateTime.UtcNow;await db.SaveChangesAsync(token);
 TempData["AdminMessage"]="Đã cập nhật danh mục.";return Redirect("/admin/categories");}
}
