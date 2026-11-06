USE Veggie;
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Name = N'Admin') INSERT dbo.Roles(Name) VALUES (N'Admin');
IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Name = N'Customer') INSERT dbo.Roles(Name) VALUES (N'Customer');
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'rau-cu') INSERT dbo.Categories(Name,Slug) VALUES (N'Rau củ',N'rau-cu');
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'trai-cay') INSERT dbo.Categories(Name,Slug) VALUES (N'Trái cây',N'trai-cay');
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'thit') INSERT dbo.Categories(Name,Slug) VALUES (N'Thịt',N'thit');
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'ca') INSERT dbo.Categories(Name,Slug) VALUES (N'Cá & hải sản',N'ca');
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'thuc-pham-khac') INSERT dbo.Categories(Name,Slug) VALUES (N'Thực phẩm khác',N'thuc-pham-khac');
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-1')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đào tươi',N'sp-1',Id,N'Đào tươi được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',45000,18,N'kg' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/1.png' FROM dbo.Products WHERE Slug=N'sp-1';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-2')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đu đủ chín',N'sp-2',Id,N'Đu đủ chín được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',50000,19,N'kg' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/2.png' FROM dbo.Products WHERE Slug=N'sp-2';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-3')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Dâu tây',N'sp-3',Id,N'Dâu tây là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',63000,21,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-strawberries.png' FROM dbo.Products WHERE Slug=N'sp-3';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-4')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bơ sáp',N'sp-4',Id,N'Bơ sáp được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',60000,21,N'kg' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/4.png' FROM dbo.Products WHERE Slug=N'sp-4';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-5')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Xoài chín',N'sp-5',Id,N'Xoài chín được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',65000,22,N'kg' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/5.png' FROM dbo.Products WHERE Slug=N'sp-5';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-6')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Lê tươi',N'sp-6',Id,N'Lê tươi được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',70000,23,N'kg' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/6.png' FROM dbo.Products WHERE Slug=N'sp-6';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-7')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Kiwi xanh',N'sp-7',Id,N'Kiwi xanh được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',75000,24,N'kg' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/7.png' FROM dbo.Products WHERE Slug=N'sp-7';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-8')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt óc chó',N'sp-8',Id,N'Hạt óc chó được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',63000,25,N'túi' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/8.png' FROM dbo.Products WHERE Slug=N'sp-8';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-9')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Măng cụt',N'sp-9',Id,N'Măng cụt được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',45000,26,N'kg' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/9.png' FROM dbo.Products WHERE Slug=N'sp-9';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-10')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cam',N'sp-10',Id,N'Cam là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',53000,28,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-orange.png' FROM dbo.Products WHERE Slug=N'sp-10';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-11')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Chanh vàng',N'sp-11',Id,N'Chanh vàng là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',58000,29,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-lemon.png' FROM dbo.Products WHERE Slug=N'sp-11';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-12')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bông cải xanh',N'sp-12',Id,N'Bông cải xanh được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',33000,29,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/12.png' FROM dbo.Products WHERE Slug=N'sp-12';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-13')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Chanh dây',N'sp-13',Id,N'Chanh dây được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',65000,30,N'kg' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/13.png' FROM dbo.Products WHERE Slug=N'sp-13';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-14')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hành tây tím',N'sp-14',Id,N'Hành tây tím được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',43000,31,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/14.png' FROM dbo.Products WHERE Slug=N'sp-14';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-15')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Xà lách xanh',N'sp-15',Id,N'Xà lách xanh được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',48000,32,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/15.png' FROM dbo.Products WHERE Slug=N'sp-15';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-16')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Mơ tươi',N'sp-16',Id,N'Mơ tươi được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',80000,33,N'kg' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/product/16.png' FROM dbo.Products WHERE Slug=N'sp-16';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-17')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cà tím',N'sp-17',Id,N'Cà tím được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',18000,34,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/aubergine.png' FROM dbo.Products WHERE Slug=N'sp-17';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-18')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Măng tây',N'sp-18',Id,N'Măng tây được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',23000,35,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/asparagus.png' FROM dbo.Products WHERE Slug=N'sp-18';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-19')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cần tây',N'sp-19',Id,N'Cần tây được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',28000,36,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/celery.png' FROM dbo.Products WHERE Slug=N'sp-19';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-20')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Gừng tươi',N'sp-20',Id,N'Gừng tươi được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',33000,37,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/ginger.png' FROM dbo.Products WHERE Slug=N'sp-20';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-21')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bắp cải',N'sp-21',Id,N'Bắp cải được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',38000,38,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/cabbage.png' FROM dbo.Products WHERE Slug=N'sp-21';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-22')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Chanh xanh',N'sp-22',Id,N'Chanh xanh là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',68000,40,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-lime.png' FROM dbo.Products WHERE Slug=N'sp-22';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-23')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Rau chân vịt',N'sp-23',Id,N'Rau chân vịt được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',48000,40,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/spinach.png' FROM dbo.Products WHERE Slug=N'sp-23';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-24')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bí đỏ',N'sp-24',Id,N'Bí đỏ được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',53000,41,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/pumpkin.png' FROM dbo.Products WHERE Slug=N'sp-24';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-25')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bí ngòi',N'sp-25',Id,N'Bí ngòi được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',18000,42,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/zucchini.png' FROM dbo.Products WHERE Slug=N'sp-25';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-26')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Khoai tây nâu',N'sp-26',Id,N'Khoai tây nâu được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',23000,43,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/sweetPotato.png' FROM dbo.Products WHERE Slug=N'sp-26';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-27')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Nấm mỡ',N'sp-27',Id,N'Nấm mỡ được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',28000,44,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/mushroom.png' FROM dbo.Products WHERE Slug=N'sp-27';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-28')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Nấm hương',N'sp-28',Id,N'Nấm hương được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',33000,45,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/shiitake.png' FROM dbo.Products WHERE Slug=N'sp-28';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-29')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Củ cải đỏ',N'sp-29',Id,N'Củ cải đỏ được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',38000,46,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/radish.png' FROM dbo.Products WHERE Slug=N'sp-29';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-30')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu cô ve',N'sp-30',Id,N'Đậu cô ve được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',43000,47,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/greenBeans.png' FROM dbo.Products WHERE Slug=N'sp-30';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-31')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Dưa leo',N'sp-31',Id,N'Dưa leo được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',48000,48,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/cucumber.png' FROM dbo.Products WHERE Slug=N'sp-31';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-32')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cà rốt',N'sp-32',Id,N'Cà rốt được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',53000,49,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/carrots.png' FROM dbo.Products WHERE Slug=N'sp-32';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-33')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Tỏi',N'sp-33',Id,N'Tỏi được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',18000,50,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/garlic.png' FROM dbo.Products WHERE Slug=N'sp-33';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-34')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hành lá',N'sp-34',Id,N'Hành lá được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',23000,51,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/scallion.png' FROM dbo.Products WHERE Slug=N'sp-34';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-35')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Ớt chuông đỏ',N'sp-35',Id,N'Ớt chuông đỏ được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',28000,52,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/redPepper.png' FROM dbo.Products WHERE Slug=N'sp-35';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-36')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Anh đào',N'sp-36',Id,N'Anh đào là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',48000,54,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-cherry.png' FROM dbo.Products WHERE Slug=N'sp-36';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-37')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bắp ngọt đóng hộp',N'sp-37',Id,N'Bắp ngọt đóng hộp được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',38000,54,N'hộp' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/sweetcorn.png' FROM dbo.Products WHERE Slug=N'sp-37';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-38')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu Hà Lan',N'sp-38',Id,N'Đậu Hà Lan được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',43000,55,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/peas.png' FROM dbo.Products WHERE Slug=N'sp-38';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-39')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Củ dền',N'sp-39',Id,N'Củ dền được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',48000,56,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/beetroot.png' FROM dbo.Products WHERE Slug=N'sp-39';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-40')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cải xoăn',N'sp-40',Id,N'Cải xoăn được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',53000,57,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/kale.png' FROM dbo.Products WHERE Slug=N'sp-40';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-41')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Thì là',N'sp-41',Id,N'Thì là được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',18000,58,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/dill.png' FROM dbo.Products WHERE Slug=N'sp-41';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-42')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Húng tây',N'sp-42',Id,N'Húng tây được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',23000,59,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/basil.png' FROM dbo.Products WHERE Slug=N'sp-42';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-43')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Ngò tây',N'sp-43',Id,N'Ngò tây được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',28000,60,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/parsley.png' FROM dbo.Products WHERE Slug=N'sp-43';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-44')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Củ cải tròn',N'sp-44',Id,N'Củ cải tròn được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',33000,61,N'kg' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/turnips.png' FROM dbo.Products WHERE Slug=N'sp-44';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-45')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Chuối vàng',N'sp-45',Id,N'Chuối vàng được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',65000,62,N'nải' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/banana.png' FROM dbo.Products WHERE Slug=N'sp-45';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-46')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Việt quất',N'sp-46',Id,N'Việt quất được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',70000,63,N'hộp' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/blueberry.png' FROM dbo.Products WHERE Slug=N'sp-46';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-47')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Phúc bồn tử',N'sp-47',Id,N'Phúc bồn tử được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',75000,64,N'hộp' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/raspberry.png' FROM dbo.Products WHERE Slug=N'sp-47';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-48')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Lựu đỏ',N'sp-48',Id,N'Lựu đỏ được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',80000,65,N'kg' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/pomegranate.png' FROM dbo.Products WHERE Slug=N'sp-48';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-49')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bưởi chùm',N'sp-49',Id,N'Bưởi chùm được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',45000,18,N'quả' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/grapefruit.png' FROM dbo.Products WHERE Slug=N'sp-49';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-50')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Sườn cốt lết heo',N'sp-50',Id,N'Sườn cốt lết heo được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',70000,19,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/porkChops.png' FROM dbo.Products WHERE Slug=N'sp-50';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-51')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Quả sung',N'sp-51',Id,N'Quả sung là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',78000,22,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-figs.png' FROM dbo.Products WHERE Slug=N'sp-51';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-52')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Dâu đen',N'sp-52',Id,N'Dâu đen là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',83000,23,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-blackberries.png' FROM dbo.Products WHERE Slug=N'sp-52';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-53')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Táo',N'sp-53',Id,N'Táo là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',88000,24,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-bramley-apples.png' FROM dbo.Products WHERE Slug=N'sp-53';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-54')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Thăn bò phi lê',N'sp-54',Id,N'Thăn bò phi lê được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',90000,23,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/beefFillet.png' FROM dbo.Products WHERE Slug=N'sp-54';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-55')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Quả chà là',N'sp-55',Id,N'Quả chà là là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',53000,26,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-medjool-dates.png' FROM dbo.Products WHERE Slug=N'sp-55';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-56')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cánh gà tẩm sốt',N'sp-56',Id,N'Cánh gà tẩm sốt được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',100000,25,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/chickenWings.png' FROM dbo.Products WHERE Slug=N'sp-56';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-57')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Gan gà',N'sp-57',Id,N'Gan gà được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',65000,26,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/chickenLiver.png' FROM dbo.Products WHERE Slug=N'sp-57';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-58')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Thịt vịt pha lóc',N'sp-58',Id,N'Thịt vịt pha lóc được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',70000,27,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/duck.png' FROM dbo.Products WHERE Slug=N'sp-58';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-59')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Sườn cừu',N'sp-59',Id,N'Sườn cừu được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',75000,28,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/lambChops.png' FROM dbo.Products WHERE Slug=N'sp-59';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-60')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cá hồi phi lê',N'sp-60',Id,N'Cá hồi phi lê được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',90000,29,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/salmon.png' FROM dbo.Products WHERE Slug=N'sp-60';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-61')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cá ngừ phi lê',N'sp-61',Id,N'Cá ngừ phi lê được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',95000,30,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/tuna.png' FROM dbo.Products WHERE Slug=N'sp-61';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-62')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cá thu nguyên con',N'sp-62',Id,N'Cá thu nguyên con được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',100000,31,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/mackerel.png' FROM dbo.Products WHERE Slug=N'sp-62';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-63')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Phi lê cá tuyết',N'sp-63',Id,N'Phi lê cá tuyết được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',105000,32,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/cod.png' FROM dbo.Products WHERE Slug=N'sp-63';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-64')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cá mòi',N'sp-64',Id,N'Cá mòi được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',110000,33,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/sardines.png' FROM dbo.Products WHERE Slug=N'sp-64';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-65')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Phi lê cá chẽm',N'sp-65',Id,N'Phi lê cá chẽm được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',75000,34,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/seaBass.png' FROM dbo.Products WHERE Slug=N'sp-65';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-66')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cá hồi vân',N'sp-66',Id,N'Cá hồi vân được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',80000,35,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/trout.png' FROM dbo.Products WHERE Slug=N'sp-66';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-67')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Tôm bóc nõn',N'sp-67',Id,N'Tôm bóc nõn được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',85000,36,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/prawns.png' FROM dbo.Products WHERE Slug=N'sp-67';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-68')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Mực đóng hộp',N'sp-68',Id,N'Mực đóng hộp được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',90000,37,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/squid.png' FROM dbo.Products WHERE Slug=N'sp-68';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-69')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Vẹm đông lạnh',N'sp-69',Id,N'Vẹm đông lạnh được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',95000,38,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/mussels.png' FROM dbo.Products WHERE Slug=N'sp-69';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-70')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Nghêu đông lạnh',N'sp-70',Id,N'Nghêu đông lạnh được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',100000,39,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/clams.png' FROM dbo.Products WHERE Slug=N'sp-70';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-71')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu phụ',N'sp-71',Id,N'Đậu phụ được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',58000,40,N'hộp' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/tofu.png' FROM dbo.Products WHERE Slug=N'sp-71';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-72')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Sữa chua nguyên vị',N'sp-72',Id,N'Sữa chua nguyên vị được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',63000,41,N'hộp' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/yogurt.png' FROM dbo.Products WHERE Slug=N'sp-72';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-73')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bơ sữa',N'sp-73',Id,N'Bơ sữa được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',28000,42,N'hộp' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/butter.png' FROM dbo.Products WHERE Slug=N'sp-73';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-74')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bánh quy yến mạch',N'sp-74',Id,N'Bánh quy yến mạch được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',33000,43,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/oats.png' FROM dbo.Products WHERE Slug=N'sp-74';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-75')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu phộng',N'sp-75',Id,N'Đậu phộng được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',38000,44,N'túi' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/peanuts.png' FROM dbo.Products WHERE Slug=N'sp-75';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-76')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Trứng gà',N'sp-76',Id,N'Trứng gà được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',43000,45,N'quả' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/eggs.png' FROM dbo.Products WHERE Slug=N'sp-76';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-77')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Gạo trắng',N'sp-77',Id,N'Gạo trắng được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',48000,46,N'túi' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/rice.png' FROM dbo.Products WHERE Slug=N'sp-77';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-78')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Mật ong',N'sp-78',Id,N'Mật ong được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',53000,47,N'lọ' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/honey.png' FROM dbo.Products WHERE Slug=N'sp-78';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-79')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Sữa tươi',N'sp-79',Id,N'Sữa tươi được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',58000,48,N'chai' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/milk.png' FROM dbo.Products WHERE Slug=N'sp-79';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-80')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Phô mai Cheddar',N'sp-80',Id,N'Phô mai Cheddar được lựa chọn và đóng gói cẩn thận. Bảo quản theo hướng dẫn trên bao bì, sử dụng sớm sau khi mở để giữ chất lượng. Giá và số lượng là dữ liệu minh họa giao diện.',63000,49,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/cheese.png' FROM dbo.Products WHERE Slug=N'sp-80';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-81')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Nho khô',N'sp-81',Id,N'Nho khô là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',48000,52,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-raisins.png' FROM dbo.Products WHERE Slug=N'sp-81';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-82')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Mận khô',N'sp-82',Id,N'Mận khô là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',53000,53,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-prunes.png' FROM dbo.Products WHERE Slug=N'sp-82';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-83')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Nam việt quất',N'sp-83',Id,N'Nam việt quất là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',58000,54,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-cranberry.png' FROM dbo.Products WHERE Slug=N'sp-83';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-84')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Sa kê',N'sp-84',Id,N'Sa kê là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',63000,55,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-breadfruit.png' FROM dbo.Products WHERE Slug=N'sp-84';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-85')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Dứa đóng hộp',N'sp-85',Id,N'Dứa đóng hộp là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',68000,56,N'túi' FROM dbo.Categories WHERE Slug=N'trai-cay';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-pineapple-chunks.png' FROM dbo.Products WHERE Slug=N'sp-85';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-86')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Tỏi tây',N'sp-86',Id,N'Tỏi tây là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',43000,57,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-leek.png' FROM dbo.Products WHERE Slug=N'sp-86';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-87')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Củ cải vàng',N'sp-87',Id,N'Củ cải vàng là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',48000,58,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-parsnips.png' FROM dbo.Products WHERE Slug=N'sp-87';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-88')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Củ cần tây',N'sp-88',Id,N'Củ cần tây là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',53000,59,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-celeriac.png' FROM dbo.Products WHERE Slug=N'sp-88';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-89')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Atisô Jerusalem',N'sp-89',Id,N'Atisô Jerusalem là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',58000,60,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-jerusalem-artichokes.png' FROM dbo.Products WHERE Slug=N'sp-89';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-90')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cải Brussels',N'sp-90',Id,N'Cải Brussels là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',18000,61,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-brussels-sprouts.png' FROM dbo.Products WHERE Slug=N'sp-90';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-91')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Giá đỗ ngâm đóng lọ',N'sp-91',Id,N'Giá đỗ ngâm đóng lọ là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',23000,62,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-bean-sprouts.png' FROM dbo.Products WHERE Slug=N'sp-91';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-92')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Măng đóng gói',N'sp-92',Id,N'Măng đóng gói là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',28000,63,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-bamboo-shoot.png' FROM dbo.Products WHERE Slug=N'sp-92';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-93')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Củ năng',N'sp-93',Id,N'Củ năng là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',33000,64,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-water-chestnut.png' FROM dbo.Products WHERE Slug=N'sp-93';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-94')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Nấm bào ngư',N'sp-94',Id,N'Nấm bào ngư là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',38000,18,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-oyster-mushrooms.png' FROM dbo.Products WHERE Slug=N'sp-94';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-95')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cải thìa',N'sp-95',Id,N'Cải thìa là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',43000,19,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-pak-choi.png' FROM dbo.Products WHERE Slug=N'sp-95';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-96')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cải thảo',N'sp-96',Id,N'Cải thảo là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',48000,20,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-chinese-cabbage.png' FROM dbo.Products WHERE Slug=N'sp-96';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-97')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Củ sắn',N'sp-97',Id,N'Củ sắn là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',53000,21,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-cassava.png' FROM dbo.Products WHERE Slug=N'sp-97';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-98')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Xà lách rocket',N'sp-98',Id,N'Xà lách rocket là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',58000,22,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-rocket.png' FROM dbo.Products WHERE Slug=N'sp-98';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-99')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bạc hà',N'sp-99',Id,N'Bạc hà là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',18000,23,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-mint.png' FROM dbo.Products WHERE Slug=N'sp-99';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-100')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hương thảo',N'sp-100',Id,N'Hương thảo là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',23000,24,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-rosemary.png' FROM dbo.Products WHERE Slug=N'sp-100';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-101')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cỏ xạ hương',N'sp-101',Id,N'Cỏ xạ hương là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',28000,25,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-thyme.png' FROM dbo.Products WHERE Slug=N'sp-101';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-102')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Xô thơm',N'sp-102',Id,N'Xô thơm là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',33000,26,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-sage.png' FROM dbo.Products WHERE Slug=N'sp-102';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-103')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Kinh giới cay',N'sp-103',Id,N'Kinh giới cay là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',38000,27,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-oregano.png' FROM dbo.Products WHERE Slug=N'sp-103';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-104')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Kinh giới ngọt',N'sp-104',Id,N'Kinh giới ngọt là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',43000,28,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-marjoram.png' FROM dbo.Products WHERE Slug=N'sp-104';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-105')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Ngải thơm',N'sp-105',Id,N'Ngải thơm là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',48000,29,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-tarragon-leaves.png' FROM dbo.Products WHERE Slug=N'sp-105';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-106')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Lá nguyệt quế',N'sp-106',Id,N'Lá nguyệt quế là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',53000,30,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-bay-leaf.png' FROM dbo.Products WHERE Slug=N'sp-106';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-107')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Ngò rí',N'sp-107',Id,N'Ngò rí là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',58000,31,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-coriander.png' FROM dbo.Products WHERE Slug=N'sp-107';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-108')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Sả',N'sp-108',Id,N'Sả là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',18000,32,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-lemongrass.png' FROM dbo.Products WHERE Slug=N'sp-108';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-109')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Riềng',N'sp-109',Id,N'Riềng là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',23000,33,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-galangal.png' FROM dbo.Products WHERE Slug=N'sp-109';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-110')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bột nghệ',N'sp-110',Id,N'Bột nghệ là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',28000,34,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-turmeric.png' FROM dbo.Products WHERE Slug=N'sp-110';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-111')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cải ngựa',N'sp-111',Id,N'Cải ngựa là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',33000,35,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-horseradish.png' FROM dbo.Products WHERE Slug=N'sp-111';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-112')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hẹ tây',N'sp-112',Id,N'Hẹ là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',38000,36,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-chives.png' FROM dbo.Products WHERE Slug=N'sp-112';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-113')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Mứt bụp giấm',N'sp-113',Id,N'Mứt bụp giấm là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',43000,37,N'túi' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-sorrel-jam.png' FROM dbo.Products WHERE Slug=N'sp-113';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-114')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đọt cọ',N'sp-114',Id,N'Đọt cọ là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',48000,38,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-palm-hearts.png' FROM dbo.Products WHERE Slug=N'sp-114';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-115')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bột cacao',N'sp-115',Id,N'Bột cacao dùng pha đồ uống và làm bánh. Bảo quản kín ở nơi khô ráo, tránh ánh nắng trực tiếp.',53000,39,N'hộp' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-cocoa.png' FROM dbo.Products WHERE Slug=N'sp-115';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-116')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu đũa',N'sp-116',Id,N'Đậu đũa là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',58000,40,N'túi' FROM dbo.Categories WHERE Slug=N'rau-cu';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-chinese-long-beans.png' FROM dbo.Products WHERE Slug=N'sp-116';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-117')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Ức gà tây',N'sp-117',Id,N'Ức gà tây là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',69000,41,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-turkey.png' FROM dbo.Products WHERE Slug=N'sp-117';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-118')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Thịt dê',N'sp-118',Id,N'Thịt dê là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',74000,42,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-goat-meat.png' FROM dbo.Products WHERE Slug=N'sp-118';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-119')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Thịt xông khói',N'sp-119',Id,N'Thịt xông khói là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',79000,43,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-bacon.png' FROM dbo.Products WHERE Slug=N'sp-119';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-120')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Xúc xích',N'sp-120',Id,N'Xúc xích là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',84000,44,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-sausages.png' FROM dbo.Products WHERE Slug=N'sp-120';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-121')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Dồi huyết',N'sp-121',Id,N'Dồi huyết là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',89000,45,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-black-pudding.png' FROM dbo.Products WHERE Slug=N'sp-121';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-122')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Thịt nguội',N'sp-122',Id,N'Thịt nguội là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',94000,46,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-ham.png' FROM dbo.Products WHERE Slug=N'sp-122';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-123')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Dạ dày bò đóng hộp',N'sp-123',Id,N'Dạ dày bò đóng hộp là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',99000,47,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-tripe.png' FROM dbo.Products WHERE Slug=N'sp-123';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-124')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cật bò',N'sp-124',Id,N'Cật bò là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',104000,48,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-beef-kidney.png' FROM dbo.Products WHERE Slug=N'sp-124';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-125')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đùi ếch',N'sp-125',Id,N'Đùi ếch là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',109000,49,N'khay' FROM dbo.Categories WHERE Slug=N'thit';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-frogs-legs.png' FROM dbo.Products WHERE Slug=N'sp-125';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-126')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cá haddock',N'sp-126',Id,N'Cá haddock là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',79000,50,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-haddock.png' FROM dbo.Products WHERE Slug=N'sp-126';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-127')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cá trích',N'sp-127',Id,N'Cá trích là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',84000,51,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-herring.png' FROM dbo.Products WHERE Slug=N'sp-127';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-128')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cá monkfish',N'sp-128',Id,N'Cá monkfish là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',89000,52,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-monkfish.png' FROM dbo.Products WHERE Slug=N'sp-128';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-129')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cá hồng',N'sp-129',Id,N'Cá hồng là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',94000,53,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-red-snapper.png' FROM dbo.Products WHERE Slug=N'sp-129';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-130')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cá hake',N'sp-130',Id,N'Cá hake là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',99000,54,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-hake.png' FROM dbo.Products WHERE Slug=N'sp-130';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-131')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Cá cơm',N'sp-131',Id,N'Cá cơm là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',104000,55,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-anchovy-fillet.png' FROM dbo.Products WHERE Slug=N'sp-131';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-132')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hàu',N'sp-132',Id,N'Hàu là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',109000,56,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-oysters.png' FROM dbo.Products WHERE Slug=N'sp-132';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-133')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đuôi tôm hùm đóng hộp',N'sp-133',Id,N'Đuôi tôm hùm đóng hộp là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',114000,57,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-lobster.png' FROM dbo.Products WHERE Slug=N'sp-133';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-134')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Thịt cua đóng gói',N'sp-134',Id,N'Thịt cua đóng gói là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',119000,58,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-crab-meay.png' FROM dbo.Products WHERE Slug=N'sp-134';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-135')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Ốc biển đóng hộp',N'sp-135',Id,N'Ốc biển đóng hộp là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',79000,59,N'khay' FROM dbo.Categories WHERE Slug=N'ca';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-conchs.png' FROM dbo.Products WHERE Slug=N'sp-135';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-136')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt hạnh nhân',N'sp-136',Id,N'Hạt hạnh nhân là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',34000,60,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-almonds.png' FROM dbo.Products WHERE Slug=N'sp-136';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-137')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt điều',N'sp-137',Id,N'Hạt điều là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',39000,61,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-cashew-nuts.png' FROM dbo.Products WHERE Slug=N'sp-137';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-138')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt hồ đào',N'sp-138',Id,N'Hạt hồ đào là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',44000,62,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-pecan-nuts.png' FROM dbo.Products WHERE Slug=N'sp-138';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-139')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt thông',N'sp-139',Id,N'Hạt thông là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',49000,63,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-pine-nuts.png' FROM dbo.Products WHERE Slug=N'sp-139';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-140')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt dẻ cười',N'sp-140',Id,N'Hạt dẻ cười là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',54000,64,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-pistachio.png' FROM dbo.Products WHERE Slug=N'sp-140';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-141')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt dẻ',N'sp-141',Id,N'Hạt dẻ là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',59000,18,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-chestnuts.png' FROM dbo.Products WHERE Slug=N'sp-141';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-142')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt phỉ',N'sp-142',Id,N'Hạt phỉ là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',64000,19,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-hazlenuts.png' FROM dbo.Products WHERE Slug=N'sp-142';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-143')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt mè',N'sp-143',Id,N'Hạt mè là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',69000,20,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-sesame-seed.png' FROM dbo.Products WHERE Slug=N'sp-143';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-144')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt anh túc',N'sp-144',Id,N'Hạt anh túc là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',29000,21,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-poppy-seeds.png' FROM dbo.Products WHERE Slug=N'sp-144';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-145')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Dầu hướng dương',N'sp-145',Id,N'Dầu hướng dương là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',34000,22,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-sunflower-oil.png' FROM dbo.Products WHERE Slug=N'sp-145';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-146')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Dầu ô liu',N'sp-146',Id,N'Dầu ô liu là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',39000,23,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-olive-oil.png' FROM dbo.Products WHERE Slug=N'sp-146';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-147')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Dầu dừa',N'sp-147',Id,N'Dầu dừa là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',44000,24,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-coconut-oil.png' FROM dbo.Products WHERE Slug=N'sp-147';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-148')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Dầu mè',N'sp-148',Id,N'Dầu mè là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',49000,25,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-sesame-seed-oil.png' FROM dbo.Products WHERE Slug=N'sp-148';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-149')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu đen đóng hộp',N'sp-149',Id,N'Đậu đen đóng hộp là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',54000,26,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-black-beans.png' FROM dbo.Products WHERE Slug=N'sp-149';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-150')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu đỏ',N'sp-150',Id,N'Đậu đỏ là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',59000,27,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-kidney-beans.png' FROM dbo.Products WHERE Slug=N'sp-150';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-151')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu gà',N'sp-151',Id,N'Đậu gà là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',64000,28,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-chickpeas.png' FROM dbo.Products WHERE Slug=N'sp-151';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-152')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu lăng',N'sp-152',Id,N'Đậu lăng là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',69000,29,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-brown-lentils.png' FROM dbo.Products WHERE Slug=N'sp-152';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-153')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu xanh',N'sp-153',Id,N'Đậu xanh là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',29000,30,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-mung-beans.png' FROM dbo.Products WHERE Slug=N'sp-153';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-154')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu nành đóng lọ',N'sp-154',Id,N'Đậu nành đóng lọ là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',34000,31,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-soya-bean.png' FROM dbo.Products WHERE Slug=N'sp-154';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-155')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu tằm',N'sp-155',Id,N'Đậu tằm là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',39000,32,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-broad-beans.png' FROM dbo.Products WHERE Slug=N'sp-155';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-156')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu bơ đóng hộp',N'sp-156',Id,N'Đậu bơ đóng hộp là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',44000,33,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-butter-beans.png' FROM dbo.Products WHERE Slug=N'sp-156';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-157')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu pinto đóng hộp',N'sp-157',Id,N'Đậu pinto đóng hộp là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',49000,34,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-pinto-beans.png' FROM dbo.Products WHERE Slug=N'sp-157';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-158')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu mắt đen',N'sp-158',Id,N'Đậu mắt đen là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',54000,35,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-black-eyed-peas.png' FROM dbo.Products WHERE Slug=N'sp-158';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-159')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đậu lima',N'sp-159',Id,N'Đậu lima là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',59000,36,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-lima-beans.png' FROM dbo.Products WHERE Slug=N'sp-159';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-160')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt diêm mạch',N'sp-160',Id,N'Hạt diêm mạch là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',64000,37,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-quinoa.png' FROM dbo.Products WHERE Slug=N'sp-160';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-161')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Kiều mạch',N'sp-161',Id,N'Kiều mạch là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',69000,38,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-buckwheat.png' FROM dbo.Products WHERE Slug=N'sp-161';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-162')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt couscous',N'sp-162',Id,N'Hạt couscous là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',29000,39,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-couscous.png' FROM dbo.Products WHERE Slug=N'sp-162';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-163')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt lúa mạch đen',N'sp-163',Id,N'Hạt lúa mạch đen là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',34000,40,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-rye-grain.png' FROM dbo.Products WHERE Slug=N'sp-163';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-164')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bột mì',N'sp-164',Id,N'Bột mì là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',39000,41,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-plain-flour.png' FROM dbo.Products WHERE Slug=N'sp-164';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-165')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đường',N'sp-165',Id,N'Đường là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',44000,42,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-sugar.png' FROM dbo.Products WHERE Slug=N'sp-165';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-166')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Muối',N'sp-166',Id,N'Muối là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',49000,43,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-salt.png' FROM dbo.Products WHERE Slug=N'sp-166';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-167')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Tiêu đen',N'sp-167',Id,N'Tiêu đen là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',54000,44,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-black-pepper.png' FROM dbo.Products WHERE Slug=N'sp-167';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-168')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bột thì là Ai Cập',N'sp-168',Id,N'Bột thì là Ai Cập là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',59000,45,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-cumin-seeds.png' FROM dbo.Products WHERE Slug=N'sp-168';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-169')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt tiểu hồi',N'sp-169',Id,N'Hạt tiểu hồi là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',64000,46,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-fennel-seeds.png' FROM dbo.Products WHERE Slug=N'sp-169';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-170')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt mù tạt',N'sp-170',Id,N'Hạt mù tạt là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',69000,47,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-mustard-seeds.png' FROM dbo.Products WHERE Slug=N'sp-170';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-171')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hạt cỏ cà ri',N'sp-171',Id,N'Cỏ cà ri là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',29000,48,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-fenugreek.png' FROM dbo.Products WHERE Slug=N'sp-171';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-172')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bạch đậu khấu',N'sp-172',Id,N'Bạch đậu khấu là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',34000,49,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-cardamom.png' FROM dbo.Products WHERE Slug=N'sp-172';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-173')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Đinh hương',N'sp-173',Id,N'Đinh hương là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',39000,50,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-cloves.png' FROM dbo.Products WHERE Slug=N'sp-173';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-174')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Quế thanh',N'sp-174',Id,N'Quế thanh là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',44000,51,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-cinnamon-stick.png' FROM dbo.Products WHERE Slug=N'sp-174';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-175')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Hoa hồi',N'sp-175',Id,N'Hoa hồi là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',49000,52,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-star-anise.png' FROM dbo.Products WHERE Slug=N'sp-175';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-176')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bột nhục đậu khấu',N'sp-176',Id,N'Bột nhục đậu khấu là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',54000,53,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-nutmeg.png' FROM dbo.Products WHERE Slug=N'sp-176';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-177')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Tiêu Jamaica',N'sp-177',Id,N'Tiêu Jamaica là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',59000,54,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-allspice.png' FROM dbo.Products WHERE Slug=N'sp-177';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-178')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bột ớt paprika',N'sp-178',Id,N'Bột ớt paprika là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',64000,55,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-paprika.png' FROM dbo.Products WHERE Slug=N'sp-178';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-179')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Bột ớt cayenne',N'sp-179',Id,N'Bột ớt cayenne là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',69000,56,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-cayenne-pepper.png' FROM dbo.Products WHERE Slug=N'sp-179';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-180')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Vani',N'sp-180',Id,N'Vani là mặt hàng riêng trong danh mục cửa hàng. Đóng gói phù hợp từng loại thực phẩm; xem thông tin bảo quản và thành phần trên nhãn trước khi sử dụng.',29000,57,N'gói' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/distinct-vanilla.png' FROM dbo.Products WHERE Slug=N'sp-180';
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Slug=N'sp-181')
BEGIN
    INSERT dbo.Products(Name,Slug,CategoryId,Description,Price,Stock,Unit)
    SELECT N'Nước ép chanh xanh và cam',N'sp-181',Id,N'Nước ép trái cây đóng chai vị chanh xanh và cam.',39000,30,N'chai' FROM dbo.Categories WHERE Slug=N'thuc-pham-khac';
    INSERT dbo.ProductImages(ProductId,Image) SELECT Id,N'img/catalog/nuoc-ep-chanh-cam.png' FROM dbo.Products WHERE Slug=N'sp-181';
END;
COMMIT;
