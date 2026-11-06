USE Veggie;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
GO
-- Giữ TransactionId cho chống đặt đơn trùng; mã ngân hàng lưu riêng.
IF COL_LENGTH('dbo.Payments','BankTransactionId') IS NULL
    ALTER TABLE dbo.Payments ADD BankTransactionId nvarchar(150) NULL;
GO
IF EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_Payments_BankTransaction' AND object_id=OBJECT_ID('dbo.Payments'))
    DROP INDEX UX_Payments_BankTransaction ON dbo.Payments;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_Payments_BankReference' AND object_id=OBJECT_ID('dbo.Payments'))
    CREATE UNIQUE INDEX UX_Payments_BankReference ON dbo.Payments(BankTransactionId) WHERE BankTransactionId IS NOT NULL;
IF NOT EXISTS(SELECT 1 FROM dbo.Roles WHERE Name='Staff') INSERT INTO dbo.Roles(Name) VALUES('Staff');
IF OBJECT_ID('dbo.ChatMessages','U') IS NULL
BEGIN
 CREATE TABLE dbo.ChatMessages(Id int IDENTITY PRIMARY KEY, UserId int NULL, GuestToken nvarchar(64) NULL,
 Question nvarchar(500) NOT NULL, Answer nvarchar(4000) NOT NULL, CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
 FOREIGN KEY(UserId) REFERENCES dbo.Users(Id));
 CREATE INDEX IX_ChatMessages_User ON dbo.ChatMessages(UserId,Id);
 CREATE INDEX IX_ChatMessages_Guest ON dbo.ChatMessages(GuestToken,Id);
END;
GO
