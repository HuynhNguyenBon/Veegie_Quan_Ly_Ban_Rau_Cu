USE Veggie;
GO
IF COL_LENGTH('dbo.Users', 'DeletedAt') IS NULL
    ALTER TABLE dbo.Users ADD DeletedAt datetime2 NULL;
GO
