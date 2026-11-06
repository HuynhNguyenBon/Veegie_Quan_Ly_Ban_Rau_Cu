using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;

namespace Veggie.Api.Controllers;

[Authorize(Roles = "Admin,Staff"), Route("admin/products")]
public sealed class AdminProductsController(VeggieDbContext db, IWebHostEnvironment environment) : Controller
{
    [HttpGet]
    public async Task<IActionResult> Index(string? q, CancellationToken token)
    {
        var products = db.Products.AsNoTracking().Where(p =>
            !p.Name.StartsWith("QA Store ") && !p.Name.StartsWith("Video QA video-test-") &&
            p.Name != "QA diagnose" && p.Name != "Veggie concurrency test" &&
            p.Name != "Veggie race test" && p.Name != "Veggie QA sản phẩm");
        var query = products;
        if (!string.IsNullOrWhiteSpace(q)) query = query.Where(p => p.Name.Contains(q) || (p.Description != null && p.Description.Contains(q)) || p.Category.Name.Contains(q));
        ViewData["Query"] = q;
        ViewData["Categories"] = await db.Categories.AsNoTracking().OrderBy(c => c.Name).ToListAsync(token);
        return View(await query.Include(p => p.ProductImages).OrderBy(p => p.Name).ToListAsync(token));
    }

    [HttpPost("create"), ValidateAntiForgeryToken, RequestSizeLimit(35*1024*1024)]
    public async Task<IActionResult> Create(string? name, int categoryId, decimal price, int stock, string? unit, IFormFile? photo, CancellationToken token, string? description = null, List<IFormFile>? photos = null)
    {
        name = name?.Trim();
        unit = unit?.Trim();
        if (!ModelState.IsValid || string.IsNullOrEmpty(name) || name.Length > 180 ||
            string.IsNullOrEmpty(unit) || unit.Length > 30 || price < 0 || price > 999999999 ||
            stock < 0 || description?.Length > 10000 || !await db.Categories.AnyAsync(c => c.Id == categoryId, token))
            return BadRequest("Thông tin sản phẩm không hợp lệ.");

        var product = new Veggie.Api.Models.Entities.Product
        {
            Name = name, Slug = $"sp-{Guid.NewGuid():N}", CategoryId = categoryId,
            Price = price, Stock = stock, Unit = unit, Status = true, Description = description?.Trim()
        };
        if (!await SetImages(product, photo, photos, token)) return BadRequest("Ảnh không hợp lệ.");
        db.Products.Add(product);
        await db.SaveChangesAsync(token);
        return RedirectToAction(nameof(Index), new { q = name });
    }

    [Authorize(Roles="Admin"), HttpPost("{id:int}"), ValidateAntiForgeryToken, RequestSizeLimit(35*1024*1024)]
    public async Task<IActionResult> Update(int id, decimal price, int stock, bool active, IFormFile? photo, CancellationToken token, string? description = null, List<IFormFile>? photos = null, string? name = null, int? categoryId = null, string? unit = null)
    {
        if (!ModelState.IsValid || price < 0 || price > 999999999 || stock < 0)
            return BadRequest("Giá hoặc tồn kho không hợp lệ.");
        var product = await db.Products.Include(p => p.ProductImages).SingleOrDefaultAsync(p => p.Id == id, token);
        if (product is null) return NotFound();
        if (name is not null) { if(string.IsNullOrWhiteSpace(name)||name.Length>180)return BadRequest();product.Name=name.Trim(); }
        if(categoryId is not null) {if(!await db.Categories.AnyAsync(c=>c.Id==categoryId,token))return BadRequest();product.CategoryId=categoryId.Value;}
        if(unit is not null){if(string.IsNullOrWhiteSpace(unit)||unit.Length>30)return BadRequest();product.Unit=unit.Trim();}
        if(description is not null){if(description.Length>10000)return BadRequest();product.Description=description.Trim();}
        if (!await SetImages(product, photo, photos, token)) return BadRequest("Ảnh không hợp lệ.");
        product.Price = price;
        product.Stock = stock;
        product.Status = active;
        product.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(token);
        return RedirectToAction(nameof(Index));
    }

    private async Task<bool> SetImages(Veggie.Api.Models.Entities.Product product,IFormFile? photo,List<IFormFile>? photos,CancellationToken token)
    {
        var files=(photos??[]).ToList();if(photo is not null)files.Insert(0,photo);
        if(files.Count>6)return false;
        foreach(var file in files){if(Path.GetExtension(file.FileName).ToLowerInvariant() is not (".png" or ".jpg" or ".jpeg") || file.Length is <8 or >5242880)return false;await using var stream=file.OpenReadStream();var h=new byte[8];await stream.ReadExactlyAsync(h,token);if(!h.AsSpan().SequenceEqual(new byte[]{137,80,78,71,13,10,26,10}) && !(h[0]==255&&h[1]==216&&h[2]==255))return false;}
        if(!await SetImage(product,files.FirstOrDefault(),token))return false;
        foreach(var file in files.Skip(1)){var extra=new Veggie.Api.Models.Entities.Product();if(!await SetImage(extra,file,token))return false;product.ProductImages.Add(extra.ProductImages.Single());}
        return true;
    }
    private async Task<bool> SetImage(Veggie.Api.Models.Entities.Product product, IFormFile? photo, CancellationToken token)
    {
        if (photo is null) return true;
        string image;
        {
            if (photo.Length < 8 || photo.Length > 5 * 1024 * 1024) return false;
            await using var source = photo.OpenReadStream();
            var header = new byte[8];
            await source.ReadExactlyAsync(header, token);
            var extension = header.AsSpan().SequenceEqual(new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 }) ? ".png"
                : header[0] == 255 && header[1] == 216 && header[2] == 255 ? ".jpg" : null;
            if (extension is null) return false;

            var directory = Path.Combine(environment.ContentRootPath, "uploads");
            Directory.CreateDirectory(directory);
            var name = Guid.NewGuid().ToString("N") + extension;
            await using var destination = System.IO.File.Create(Path.Combine(directory, name));
            await destination.WriteAsync(header, token);
            await source.CopyToAsync(destination, token);
            image = "/product-uploads/" + name;
        }
        var primary = product.ProductImages.OrderBy(i => i.Id).FirstOrDefault();
        if (primary is null)
            product.ProductImages.Add(new Veggie.Api.Models.Entities.ProductImage { Image = image });
        else
            primary.Image = image;
        return true;
    }
}






