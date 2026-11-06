SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
USE Veggie;
GO
-- Không dùng cùng một giao dịch ngân hàng để thanh toán nhiều đơn.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Payments_BankTransaction' AND object_id = OBJECT_ID('dbo.Payments'))
    CREATE UNIQUE INDEX UX_Payments_BankTransaction
    ON dbo.Payments(TransactionId)
    WHERE TransactionId IS NOT NULL AND PaymentMethod = 'BankTransfer';
GO

