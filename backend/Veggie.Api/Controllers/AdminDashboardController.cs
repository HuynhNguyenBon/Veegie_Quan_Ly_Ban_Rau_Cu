using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
namespace Veggie.Api.Controllers;
[Authorize(Roles="Admin,Staff"),Route("admin")]
public class AdminDashboardController(VeggieDbContext db):Controller
{
 [HttpGet(""),HttpGet("dashboard")]
 public async Task<IActionResult> Index(CancellationToken token)
 {
 var users=db.Users.AsNoTracking().Where(u=>!u.Email.StartsWith("video-test-") || !u.Email.EndsWith("@example.test"));
 var products=db.Products.AsNoTracking().Where(p=>!p.Name.StartsWith("QA Store ")&&!p.Name.StartsWith("Video QA video-test-"));
 var orders=db.Orders.AsNoTracking().Where(o=>users.Any(u=>u.Id==o.UserId)&&!o.OrderItems.Any(i=>i.Product.Name.StartsWith("QA Store ")||i.Product.Name.StartsWith("Video QA video-test-")));
 ViewData["Users"]=await users.CountAsync(token);
 ViewData["Products"]=await products.CountAsync(token);
 ViewData["Orders"]=await orders.CountAsync(token);
 ViewData["Revenue"]=await orders.Where(o=>o.Payment!=null && o.Payment.Status=="paid").SumAsync(o=>(decimal?)o.TotalPrice,token)??0;
 ViewData["Categories"]=await db.Categories.Select(c=>new CategorySummary(c.Name,products.Count(p=>p.CategoryId==c.Id))).ToListAsync(token);
 ViewData["RecentUsers"]=await users.OrderByDescending(u=>u.Id).Take(5).ToListAsync(token);
 ViewData["RecentOrders"]=await orders.Include(o=>o.User).OrderByDescending(o=>o.Id).Take(5).ToListAsync(token);
 var sellers=await db.OrderItems.Where(i=>i.Order.Status=="delivered"&&orders.Any(o=>o.Id==i.OrderId)&&products.Any(p=>p.Id==i.ProductId)).GroupBy(i=>new{i.ProductId,i.Product.Name,i.Product.Price}).Select(g=>new {Id=g.Key.ProductId,Name=g.Key.Name,Quantity=g.Sum(i=>i.Quantity),Price=g.Key.Price,Image=g.Select(i=>i.Product.ProductImages.OrderBy(x=>x.Id).Select(x=>x.Image).FirstOrDefault()).FirstOrDefault()}).OrderByDescending(s=>s.Quantity).Take(5).ToListAsync(token);
 ViewData["BestSellers"]=sellers.Select(s=>new SellerSummary(s.Id,s.Name,s.Quantity,s.Price,s.Image)).ToList();
 var start=DateTime.UtcNow.Date.AddDays(-6); var paid=await orders.Where(o=>o.CreatedAt>=start && o.Payment!=null && o.Payment.Status=="paid").Select(o=>new{o.CreatedAt,o.TotalPrice}).ToListAsync(token);
 ViewData["Chart"]=Enumerable.Range(0,7).Select(n=>new RevenueSummary(start.AddDays(n),paid.Where(o=>o.CreatedAt.Date==start.AddDays(n)).Sum(o=>o.TotalPrice))).ToList();
 return View();
 }
 [Authorize(Roles="Admin"),HttpGet("users")] public async Task<IActionResult> Users(CancellationToken token)=>View(await db.Users.AsNoTracking().Include(u=>u.Role).OrderByDescending(u=>u.Id).ToListAsync(token));
 [Authorize(Roles="Admin"),HttpGet("categories")] public async Task<IActionResult> Categories(CancellationToken token)=>View(await db.Categories.AsNoTracking().Include(c=>c.Products).ToListAsync(token));
 public record CategorySummary(string Name,int Count);
 public record SellerSummary(int Id,string Name,int Quantity,decimal Price,string? Image);
 public record RevenueSummary(DateTime Day,decimal Amount);
}


