USE Veggie;
GO
IF COL_LENGTH('dbo.Users', 'CoverImage') IS NULL
    ALTER TABLE dbo.Users ADD CoverImage nvarchar(500) NULL;
GO
