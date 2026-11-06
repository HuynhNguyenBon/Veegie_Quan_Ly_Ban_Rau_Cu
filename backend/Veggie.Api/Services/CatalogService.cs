using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Responses;

namespace Veggie.Api.Services;

public class CatalogService(VeggieDbContext db)
{
    public async Task<CatalogResponse> ReadAsync(CancellationToken cancellationToken)
    {
        var categories = await db.Categories.AsNoTracking().OrderBy(c => c.Id)
            .Select(c => new { c.Slug, c.Name }).ToListAsync(cancellationToken);
        var products = await db.Products.AsNoTracking().Where(p => p.Status).OrderBy(p => p.Id)
            .Select(p => new CatalogProduct(p.Id, p.Name, p.Category.Slug, p.Price, p.Unit, p.Stock,
                p.ProductImages.OrderBy(i => i.Id).Select(i => i.Image).FirstOrDefault(),
                p.Description, p.Reviews.Select(r => (double?)r.Rating).Average() ?? 0, p.OrderItems.Where(i=>i.Order.Status=="delivered").Sum(i=>i.Quantity)))
            .ToListAsync(cancellationToken);
        return new CatalogResponse(categories.Select((c, i) => new CatalogCategory(c.Slug, c.Name, i + 2)).ToList(), products);
    }
}

