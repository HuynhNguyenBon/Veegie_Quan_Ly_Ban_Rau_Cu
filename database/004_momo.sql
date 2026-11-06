USE Veggie;
GO
IF COL_LENGTH('dbo.Payments', 'GatewayOrderId') IS NULL
    ALTER TABLE dbo.Payments ADD GatewayOrderId nvarchar(100) NULL;
IF COL_LENGTH('dbo.Payments', 'GatewayPayUrl') IS NULL
    ALTER TABLE dbo.Payments ADD GatewayPayUrl nvarchar(2000) NULL;
GO
