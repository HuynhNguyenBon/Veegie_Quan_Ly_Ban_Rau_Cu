namespace Veggie.Api.Models.Responses;

public record CatalogCategory(string Id, string Name, int Icon);
public record CatalogProduct(int Id, string Name, string Category, decimal Price, string Unit,
    int Stock, string? Image, string? Description, double Rating, int SoldQuantity = 0);
public record CatalogResponse(IReadOnlyList<CatalogCategory> Categories, IReadOnlyList<CatalogProduct> Products);

