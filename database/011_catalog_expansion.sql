USE Veggie;
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-1')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Bông cải xanh gói 500g',N'bo-sung-20261113-1',Id,N'Bông cải xanh gói 500g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',24000,60,N'gói' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/12.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-1';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-2')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Cà rốt gói 500g',N'bo-sung-20261113-2',Id,N'Cà rốt gói 500g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',18000,60,N'gói' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/carrots.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-2';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-3')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Dưa leo gói 500g',N'bo-sung-20261113-3',Id,N'Dưa leo gói 500g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',16000,60,N'gói' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/cucumber.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-3';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-4')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Bí đỏ gói 500g',N'bo-sung-20261113-4',Id,N'Bí đỏ gói 500g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',19000,60,N'gói' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/pumpkin.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-4';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-5')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Cải thìa gói 300g',N'bo-sung-20261113-5',Id,N'Cải thìa gói 300g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',17000,60,N'gói' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-pak-choi.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-5';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-6')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Nấm bào ngư gói 200g',N'bo-sung-20261113-6',Id,N'Nấm bào ngư gói 200g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',24000,60,N'gói' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-oyster-mushrooms.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-6';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-7')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Nấm hương gói 200g',N'bo-sung-20261113-7',Id,N'Nấm hương gói 200g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',28000,60,N'gói' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/shiitake.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-7';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-8')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Rau chân vịt gói 300g',N'bo-sung-20261113-8',Id,N'Rau chân vịt gói 300g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',22000,60,N'gói' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/spinach.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-8';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-9')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Cà tím gói 500g',N'bo-sung-20261113-9',Id,N'Cà tím gói 500g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',19000,60,N'gói' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/aubergine.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-9';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-10')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Bí ngòi gói 500g',N'bo-sung-20261113-10',Id,N'Bí ngòi gói 500g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',26000,60,N'gói' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/zucchini.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-10';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-11')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Đậu phụ hộp 300g',N'bo-sung-20261113-11',Id,N'Đậu phụ hộp 300g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',16000,60,N'hộp' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/tofu.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-11';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-12')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Trứng gà hộp 10 quả',N'bo-sung-20261113-12',Id,N'Trứng gà hộp 10 quả. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',35000,60,N'hộp' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/eggs.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-12';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-13')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Tôm bóc nõn khay 250g',N'bo-sung-20261113-13',Id,N'Tôm bóc nõn khay 250g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',65000,60,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/prawns.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-13';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-14')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Cá hồi phi lê khay 200g',N'bo-sung-20261113-14',Id,N'Cá hồi phi lê khay 200g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',89000,60,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/salmon.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-14';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-15')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Thăn bò phi lê khay 250g',N'bo-sung-20261113-15',Id,N'Thăn bò phi lê khay 250g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',85000,60,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/beefFillet.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-15';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-16')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Sườn cốt lết heo khay 300g',N'bo-sung-20261113-16',Id,N'Sườn cốt lết heo khay 300g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',52000,60,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/porkChops.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-16';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-17')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Cam túi 1kg',N'bo-sung-20261113-17',Id,N'Cam túi 1kg. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',42000,60,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-orange.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-17';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-18')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Táo túi 1kg',N'bo-sung-20261113-18',Id,N'Táo túi 1kg. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',49000,60,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-bramley-apples.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-18';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-19')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Chuối vàng gói 500g',N'bo-sung-20261113-19',Id,N'Chuối vàng gói 500g. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',18000,60,N'gói' FROM dbo.Categories WHERE Slug=N'trai-cay';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/banana.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-19';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'bo-sung-20261113-20')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Sữa chua nguyên vị lốc 4 hộp',N'bo-sung-20261113-20',Id,N'Sữa chua nguyên vị lốc 4 hộp. Quy cách được ghi rõ trong tên sản phẩm. Bảo quản theo hướng dẫn trên bao bì. Giá và tồn kho minh họa.',28000,60,N'lốc' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/yogurt.png' FROM dbo.Products WHERE Slug=N'bo-sung-20261113-20';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'mat-hang-20261113-1')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Thịt bò xay',N'mat-hang-20261113-1',Id,N'Thịt bò xay, dùng để chế biến các món ăn gia đình. Giá và tồn kho minh họa.',89000,65,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/mincedBeef.png' FROM dbo.Products WHERE Slug=N'mat-hang-20261113-1';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'mat-hang-20261113-2')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Thịt heo xay',N'mat-hang-20261113-2',Id,N'Thịt heo xay, dùng để chế biến các món ăn gia đình. Giá và tồn kho minh họa.',59000,65,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/mincedPork.png' FROM dbo.Products WHERE Slug=N'mat-hang-20261113-2';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'mat-hang-20261113-3')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Ba chỉ heo',N'mat-hang-20261113-3',Id,N'Ba chỉ heo, dùng để chế biến các món ăn gia đình. Giá và tồn kho minh họa.',69000,65,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/porkBelly.png' FROM dbo.Products WHERE Slug=N'mat-hang-20261113-3';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'mat-hang-20261113-4')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Thăn heo',N'mat-hang-20261113-4',Id,N'Thăn heo, dùng để chế biến các món ăn gia đình. Giá và tồn kho minh họa.',65000,65,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/porkTenderloin.png' FROM dbo.Products WHERE Slug=N'mat-hang-20261113-4';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'mat-hang-20261113-5')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Bắp cải tím',N'mat-hang-20261113-5',Id,N'Bắp cải tím, dùng để chế biến các món ăn gia đình. Giá và tồn kho minh họa.',42000,65,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/redCabbage.png' FROM dbo.Products WHERE Slug=N'mat-hang-20261113-5';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WITH (UPDLOCK, HOLDLOCK) WHERE Slug=N'mat-hang-20261113-6')
BEGIN
INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit) SELECT N'Ớt chuông vàng',N'mat-hang-20261113-6',Id,N'Ớt chuông vàng, dùng để chế biến các món ăn gia đình. Giá và tồn kho minh họa.',55000,65,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/yellowPepper.png' FROM dbo.Products WHERE Slug=N'mat-hang-20261113-6';
END;
COMMIT;
