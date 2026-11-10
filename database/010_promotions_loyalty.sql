USE Veggie;
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF COL_LENGTH(N'dbo.Orders', N'Subtotal') IS NULL
    ALTER TABLE dbo.Orders ADD Subtotal decimal(18,2) NOT NULL CONSTRAINT DF_Orders_Subtotal DEFAULT (0);
IF COL_LENGTH(N'dbo.Orders', N'DiscountAmount') IS NULL
    ALTER TABLE dbo.Orders ADD DiscountAmount decimal(18,2) NOT NULL CONSTRAINT DF_Orders_DiscountAmount DEFAULT (0);
IF COL_LENGTH(N'dbo.Orders', N'ShippingFee') IS NULL
    ALTER TABLE dbo.Orders ADD ShippingFee decimal(18,2) NOT NULL CONSTRAINT DF_Orders_ShippingFee DEFAULT (0);
IF COL_LENGTH(N'dbo.Orders', N'PromotionCode') IS NULL
    ALTER TABLE dbo.Orders ADD PromotionCode nvarchar(40) NULL;
IF OBJECT_ID(N'dbo.Promotions', N'U') IS NULL
CREATE TABLE dbo.Promotions (
    Id int IDENTITY PRIMARY KEY,
    Code nvarchar(40) NOT NULL,
    Description nvarchar(240) NOT NULL,
    DiscountType nvarchar(12) NOT NULL CHECK (DiscountType IN (N'percent', N'amount')),
    DiscountValue decimal(18,2) NOT NULL CHECK (DiscountValue > 0),
    MinimumSubtotal decimal(18,2) NOT NULL DEFAULT (0) CHECK (MinimumSubtotal >= 0),
    MaximumDiscount decimal(18,2) NULL CHECK (MaximumDiscount IS NULL OR MaximumDiscount > 0),
    StartsAt datetime2 NOT NULL,
    ExpiresAt datetime2 NOT NULL,
    UsageLimit int NULL CHECK (UsageLimit IS NULL OR UsageLimit > 0),
    UsageCount int NOT NULL DEFAULT (0) CHECK (UsageCount >= 0),
    MaxUsesPerUser int NOT NULL DEFAULT (1) CHECK (MaxUsesPerUser > 0),
    AssignedUserId int NULL REFERENCES dbo.Users(Id),
    IsActive bit NOT NULL DEFAULT (1),
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT UQ_Promotions_Code UNIQUE (Code),
    CONSTRAINT CK_Promotions_Percentage CHECK (DiscountType <> N'percent' OR DiscountValue <= 100),
    CONSTRAINT CK_Promotions_DateRange CHECK (ExpiresAt > StartsAt)
);

IF OBJECT_ID(N'dbo.PromotionUsages', N'U') IS NULL
CREATE TABLE dbo.PromotionUsages (
    Id int IDENTITY PRIMARY KEY,
    PromotionId int NOT NULL REFERENCES dbo.Promotions(Id),
    UserId int NOT NULL REFERENCES dbo.Users(Id),
    OrderId int NOT NULL UNIQUE REFERENCES dbo.Orders(Id),
    DiscountAmount decimal(18,2) NOT NULL CHECK (DiscountAmount >= 0),
    UsedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME()
);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.PromotionUsages') AND name=N'IX_PromotionUsages_PromotionId_UserId')
    CREATE INDEX IX_PromotionUsages_PromotionId_UserId ON dbo.PromotionUsages(PromotionId, UserId);

IF OBJECT_ID(N'dbo.Rewards', N'U') IS NULL
CREATE TABLE dbo.Rewards (
    Id int IDENTITY PRIMARY KEY,
    Name nvarchar(120) NOT NULL,
    Description nvarchar(500) NOT NULL,
    PointsCost int NOT NULL CHECK (PointsCost > 0),
    RewardType nvarchar(12) NOT NULL CHECK (RewardType IN (N'voucher', N'physical')),
    Stock int NULL CHECK (Stock IS NULL OR Stock >= 0),
    DiscountAmount decimal(18,2) NULL,
    MinimumOrderAmount decimal(18,2) NOT NULL DEFAULT (0) CHECK (MinimumOrderAmount >= 0),
    ValidityDays int NOT NULL DEFAULT (30) CHECK (ValidityDays BETWEEN 1 AND 365),
    IsActive bit NOT NULL DEFAULT (1),
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_Rewards_VoucherAmount CHECK
        ((RewardType=N'voucher' AND DiscountAmount > 0) OR (RewardType=N'physical' AND DiscountAmount IS NULL))
);

IF OBJECT_ID(N'dbo.RewardRedemptions', N'U') IS NULL
CREATE TABLE dbo.RewardRedemptions (
    Id int IDENTITY PRIMARY KEY,
    UserId int NOT NULL REFERENCES dbo.Users(Id),
    RewardId int NOT NULL REFERENCES dbo.Rewards(Id),
    PromotionId int NULL REFERENCES dbo.Promotions(Id),
    PointsSpent int NOT NULL CHECK (PointsSpent > 0),
    Status nvarchar(20) NOT NULL CHECK (Status IN (N'issued', N'pending', N'fulfilled')),
    RedeemedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME()
);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.RewardRedemptions') AND name=N'UX_RewardRedemptions_PromotionId')
    CREATE UNIQUE INDEX UX_RewardRedemptions_PromotionId ON dbo.RewardRedemptions(PromotionId) WHERE PromotionId IS NOT NULL;

IF OBJECT_ID(N'dbo.LoyaltyPointTransactions', N'U') IS NULL
CREATE TABLE dbo.LoyaltyPointTransactions (
    Id int IDENTITY PRIMARY KEY,
    UserId int NOT NULL REFERENCES dbo.Users(Id),
    PointsDelta int NOT NULL CHECK (PointsDelta <> 0),
    Type nvarchar(12) NOT NULL CHECK (Type IN (N'EARN', N'REDEEM', N'ADJUST')),
    OrderId int NULL REFERENCES dbo.Orders(Id),
    RedemptionId int NULL REFERENCES dbo.RewardRedemptions(Id),
    Note nvarchar(240) NOT NULL,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_LoyaltyPointTransactions_References CHECK
        ((Type=N'EARN' AND OrderId IS NOT NULL AND RedemptionId IS NULL AND PointsDelta > 0)
         OR (Type=N'REDEEM' AND OrderId IS NULL AND RedemptionId IS NOT NULL AND PointsDelta < 0)
         OR (Type=N'ADJUST' AND OrderId IS NULL AND RedemptionId IS NULL))
);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.LoyaltyPointTransactions') AND name=N'UX_LoyaltyPoints_OrderId')
    CREATE UNIQUE INDEX UX_LoyaltyPoints_OrderId ON dbo.LoyaltyPointTransactions(OrderId) WHERE OrderId IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.LoyaltyPointTransactions') AND name=N'UX_LoyaltyPoints_RedemptionId')
    CREATE UNIQUE INDEX UX_LoyaltyPoints_RedemptionId ON dbo.LoyaltyPointTransactions(RedemptionId) WHERE RedemptionId IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.LoyaltyPointTransactions') AND name=N'IX_LoyaltyPointTransactions_UserId_CreatedAt')
    CREATE INDEX IX_LoyaltyPointTransactions_UserId_CreatedAt ON dbo.LoyaltyPointTransactions(UserId, CreatedAt DESC);

IF OBJECT_ID(N'dbo.LoyaltySettings', N'U') IS NULL
CREATE TABLE dbo.LoyaltySettings (
    Id int NOT NULL PRIMARY KEY CHECK (Id=1),
    CurrencyPerPoint int NOT NULL CHECK (CurrencyPerPoint BETWEEN 100 AND 1000000),
    UpdatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME()
);
IF NOT EXISTS (SELECT 1 FROM dbo.LoyaltySettings WHERE Id=1)
    INSERT dbo.LoyaltySettings(Id, CurrencyPerPoint) VALUES (1, 10000);

IF NOT EXISTS (SELECT 1 FROM dbo.Promotions WHERE Code=N'VEGGIE10')
    INSERT dbo.Promotions(Code, Description, DiscountType, DiscountValue, MinimumSubtotal, MaximumDiscount, StartsAt, ExpiresAt, UsageLimit, MaxUsesPerUser)
    VALUES (N'VEGGIE10', N'Giảm 10% cho đơn từ 150.000₫ (tối đa 50.000₫)', N'percent', 10, 150000, 50000,
        DATEADD(day, -1, SYSUTCDATETIME()), '2099-12-31T23:59:59', 10000, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Promotions WHERE Code=N'FRESH20K')
    INSERT dbo.Promotions(Code, Description, DiscountType, DiscountValue, MinimumSubtotal, StartsAt, ExpiresAt, UsageLimit, MaxUsesPerUser)
    VALUES (N'FRESH20K', N'Giảm 20.000₫ cho đơn từ 100.000₫', N'amount', 20000, 100000,
        DATEADD(day, -1, SYSUTCDATETIME()), '2099-12-31T23:59:59', 10000, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.Rewards WHERE Name=N'Voucher giảm 20.000₫')
    INSERT dbo.Rewards(Name, Description, PointsCost, RewardType, DiscountAmount, MinimumOrderAmount, ValidityDays)
    VALUES (N'Voucher giảm 20.000₫', N'Mã voucher cá nhân, dùng một lần cho đơn từ 100.000₫. Hạn dùng 30 ngày từ khi đổi.', 200, N'voucher', 20000, 100000, 30);
IF NOT EXISTS (SELECT 1 FROM dbo.Rewards WHERE Name=N'Voucher giảm 50.000₫')
    INSERT dbo.Rewards(Name, Description, PointsCost, RewardType, DiscountAmount, MinimumOrderAmount, ValidityDays)
    VALUES (N'Voucher giảm 50.000₫', N'Mã voucher cá nhân, dùng một lần cho đơn từ 250.000₫. Hạn dùng 30 ngày từ khi đổi.', 450, N'voucher', 50000, 250000, 30);
IF NOT EXISTS (SELECT 1 FROM dbo.Rewards WHERE Name=N'Túi rau củ theo mùa')
    INSERT dbo.Rewards(Name, Description, PointsCost, RewardType, Stock)
    VALUES (N'Túi rau củ theo mùa', N'Quà vật lý do cửa hàng xác nhận và sắp xếp giao cùng đơn gần nhất.', 350, N'physical', 100);

COMMIT TRANSACTION;
GO
