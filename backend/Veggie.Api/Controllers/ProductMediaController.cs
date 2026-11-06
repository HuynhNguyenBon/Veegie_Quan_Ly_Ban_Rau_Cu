using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
namespace Veggie.Api.Controllers;
[ApiController,Route("api/products")]
public sealed class ProductMediaController(VeggieDbContext db):ControllerBase
{
 [HttpGet("{id:int}/images")]public async Task<IActionResult> Images(int id,CancellationToken token)=>Ok(await db.ProductImages.Where(i=>i.ProductId==id&&i.Product.Status).OrderBy(i=>i.Id).Select(i=>i.Image).ToListAsync(token));
}
