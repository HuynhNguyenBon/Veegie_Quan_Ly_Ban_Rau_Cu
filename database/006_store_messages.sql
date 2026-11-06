USE Veggie;
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID('dbo.NewsletterSubscriptions','U') IS NULL
CREATE TABLE dbo.NewsletterSubscriptions (
    Id int IDENTITY PRIMARY KEY,
    Email nvarchar(254) NOT NULL UNIQUE,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME()
);
IF OBJECT_ID('dbo.StoreEmailQueue','U') IS NULL
CREATE TABLE dbo.StoreEmailQueue (
    Id int IDENTITY PRIMARY KEY,
    ToEmail nvarchar(254) NOT NULL,
    ReplyTo nvarchar(254) NULL,
    Subject nvarchar(200) NOT NULL,
    Body nvarchar(max) NOT NULL,
    CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    SentAt datetime2 NULL,
    Attempts int NOT NULL DEFAULT 0,
    NextAttemptAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME()
);
COMMIT;
GO
