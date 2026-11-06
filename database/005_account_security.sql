USE Veggie;
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF COL_LENGTH('dbo.Users', 'EmailConfirmed') IS NULL
    ALTER TABLE dbo.Users ADD EmailConfirmed bit NOT NULL CONSTRAINT DF_Users_EmailConfirmed DEFAULT 1;
IF COL_LENGTH('dbo.Users', 'SecurityStamp') IS NULL
    ALTER TABLE dbo.Users ADD SecurityStamp nvarchar(36) NOT NULL CONSTRAINT DF_Users_SecurityStamp DEFAULT CONVERT(nvarchar(36), NEWID());
IF OBJECT_ID('dbo.AccountTokens', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AccountTokens (
        Id int IDENTITY PRIMARY KEY,
        UserId int NOT NULL REFERENCES dbo.Users(Id),
        Purpose nvarchar(20) NOT NULL CHECK (Purpose IN ('verify', 'reset')),
        TokenHash nvarchar(64) NOT NULL UNIQUE,
        CreatedAt datetime2 NOT NULL,
        ExpiresAt datetime2 NOT NULL,
        UsedAt datetime2 NULL
    );
    CREATE INDEX IX_AccountTokens_UserPurpose ON dbo.AccountTokens(UserId, Purpose, CreatedAt);
END;
COMMIT;
GO
