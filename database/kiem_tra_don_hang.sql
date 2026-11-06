USE Veggie;
SELECT o.Id, o.TotalPrice, o.Status, i.Quantity, p.Stock
FROM dbo.Orders o
JOIN dbo.OrderItems i ON i.OrderId = o.Id
JOIN dbo.Products p ON p.Id = i.ProductId
WHERE o.Id = 1;