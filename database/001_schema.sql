IF DB_ID(N'Veggie') IS NULL CREATE DATABASE Veggie;
GO
USE Veggie;
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID(N'dbo.Roles', N'U') IS NULL
CREATE TABLE dbo.Roles (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Name nvarchar(80) NOT NULL UNIQUE
);

IF OBJECT_ID(N'dbo.Permissions', N'U') IS NULL
CREATE TABLE dbo.Permissions (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Name nvarchar(100) NOT NULL UNIQUE
);

IF OBJECT_ID(N'dbo.Categories', N'U') IS NULL
CREATE TABLE dbo.Categories (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Name nvarchar(120) NOT NULL,
    Slug nvarchar(140) NOT NULL UNIQUE,
    Description nvarchar(max),
    Image nvarchar(500),
    UpdatedAt datetime2
);

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
CREATE TABLE dbo.Users (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Name nvarchar(120) NOT NULL,
    Email nvarchar(254) NOT NULL UNIQUE,
    PasswordHash nvarchar(500),
    Status bit NOT NULL DEFAULT 1,
    PhoneNumber nvarchar(25),
    Avatar nvarchar(500),
    CoverImage nvarchar(500),
    Address nvarchar(400),
    RoleId int NOT NULL REFERENCES dbo.Roles(Id),
    ActivationToken nvarchar(256),
    GoogleId nvarchar(255),
    UpdatedAt datetime2
);

IF OBJECT_ID(N'dbo.Products', N'U') IS NULL
CREATE TABLE dbo.Products (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Name nvarchar(180) NOT NULL,
    Slug nvarchar(200) NOT NULL UNIQUE,
    CategoryId int NOT NULL REFERENCES dbo.Categories(Id),
    Description nvarchar(max),
    Price decimal(18,2) NOT NULL CHECK (Price >= 0),
    Stock int NOT NULL CHECK (Stock >= 0),
    Status bit NOT NULL DEFAULT 1,
    Unit nvarchar(30) NOT NULL,
    UpdatedAt datetime2
);

IF OBJECT_ID(N'dbo.ProductImages', N'U') IS NULL
CREATE TABLE dbo.ProductImages (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    ProductId int NOT NULL REFERENCES dbo.Products(Id),
    Image nvarchar(500) NOT NULL
);

IF OBJECT_ID(N'dbo.ShippingAddresses', N'U') IS NULL
CREATE TABLE dbo.ShippingAddresses (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UserId int NOT NULL REFERENCES dbo.Users(Id),
    FullName nvarchar(120) NOT NULL,
    Phone nvarchar(25) NOT NULL,
    Address nvarchar(400) NOT NULL,
    City nvarchar(100) NOT NULL,
    IsDefault bit NOT NULL DEFAULT 0,
    UNIQUE (Id,
    UserId)
);

IF OBJECT_ID(N'dbo.Orders', N'U') IS NULL
CREATE TABLE dbo.Orders (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UserId int NOT NULL REFERENCES dbo.Users(Id),
    TotalPrice decimal(18,2) NOT NULL CHECK (TotalPrice >= 0),
    Status nvarchar(30) NOT NULL DEFAULT 'pending',
    ShippingAddressId int NOT NULL,
    FOREIGN KEY (ShippingAddressId,
    UserId) REFERENCES dbo.ShippingAddresses(Id,
    UserId)
);

IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NULL
CREATE TABLE dbo.OrderItems (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    OrderId int NOT NULL REFERENCES dbo.Orders(Id),
    ProductId int NOT NULL REFERENCES dbo.Products(Id),
    Quantity int NOT NULL CHECK (Quantity > 0),
    Price decimal(18,2) NOT NULL CHECK (Price >= 0),
    UNIQUE (OrderId,
    ProductId)
);

IF OBJECT_ID(N'dbo.OrderStatusHistory', N'U') IS NULL
CREATE TABLE dbo.OrderStatusHistory (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    OrderId int NOT NULL REFERENCES dbo.Orders(Id),
    Status nvarchar(30) NOT NULL,
    ChangedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Note nvarchar(500)
);

IF OBJECT_ID(N'dbo.Payments', N'U') IS NULL
CREATE TABLE dbo.Payments (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    OrderId int NOT NULL UNIQUE REFERENCES dbo.Orders(Id),
    PaymentMethod nvarchar(40) NOT NULL,
    TransactionId nvarchar(150),
    Amount decimal(18,2) NOT NULL CHECK (Amount >= 0),
    Status nvarchar(30) NOT NULL DEFAULT 'pending',
    PaidAt datetime2
);

IF OBJECT_ID(N'dbo.CartItems', N'U') IS NULL
CREATE TABLE dbo.CartItems (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UserId int NOT NULL REFERENCES dbo.Users(Id),
    ProductId int NOT NULL REFERENCES dbo.Products(Id),
    Quantity int NOT NULL CHECK (Quantity > 0),
    UNIQUE (UserId,
    ProductId)
);

IF OBJECT_ID(N'dbo.Wishlists', N'U') IS NULL
CREATE TABLE dbo.Wishlists (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UserId int NOT NULL REFERENCES dbo.Users(Id),
    ProductId int NOT NULL REFERENCES dbo.Products(Id),
    UNIQUE (UserId,
    ProductId)
);

IF OBJECT_ID(N'dbo.Reviews', N'U') IS NULL
CREATE TABLE dbo.Reviews (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UserId int NOT NULL REFERENCES dbo.Users(Id),
    ProductId int NOT NULL REFERENCES dbo.Products(Id),
    Rating tinyint NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment nvarchar(2000),
    UNIQUE (UserId,
    ProductId)
);

IF OBJECT_ID(N'dbo.Notifications', N'U') IS NULL
CREATE TABLE dbo.Notifications (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UserId int NOT NULL REFERENCES dbo.Users(Id),
    Type nvarchar(50) NOT NULL,
    Message nvarchar(1000) NOT NULL,
    IsRead bit NOT NULL DEFAULT 0
);

IF OBJECT_ID(N'dbo.Contacts', N'U') IS NULL
CREATE TABLE dbo.Contacts (
    Id int IDENTITY PRIMARY KEY,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    FullName nvarchar(120) NOT NULL,
    PhoneNumber nvarchar(25),
    Email nvarchar(254) NOT NULL,
    Message nvarchar(2000) NOT NULL,
    IsReply bit NOT NULL DEFAULT 0
);

IF OBJECT_ID(N'dbo.RolePermissions', N'U') IS NULL
CREATE TABLE dbo.RolePermissions (
    RoleId int NOT NULL REFERENCES dbo.Roles(Id),
    PermissionId int NOT NULL REFERENCES dbo.Permissions(Id),
    PRIMARY KEY (RoleId, PermissionId)
);
COMMIT;

