USE Veggie;

-- Danh mục và số sản phẩm đang bán
SELECT c.Name AS DanhMuc, COUNT(p.Id) AS SoSanPham
FROM dbo.Categories c
LEFT JOIN dbo.Products p ON p.CategoryId = c.Id AND p.Status = 1
GROUP BY c.Id, c.Name
ORDER BY c.Id;

-- Chi tiết sản phẩm từ banner
SELECT p.Name, c.Name AS DanhMuc, p.Price, p.Stock, i.Image
FROM dbo.Products p
JOIN dbo.Categories c ON c.Id = p.CategoryId
LEFT JOIN dbo.ProductImages i ON i.ProductId = p.Id
WHERE p.Id = 181;

-- Các bảng dùng cho luồng đặt hàng
SELECT COUNT(*) AS SoDonHang FROM dbo.Orders;
DBCC CHECKCONSTRAINTS WITH ALL_CONSTRAINTS;