using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;

namespace Veggie.Api.Services;

public static partial class DevelopmentSchemaInitializer
{
    public static async Task EnsurePromotionsAndLoyaltyAsync(VeggieDbContext db, CancellationToken token = default)
    {
        await db.Database.OpenConnectionAsync(token);
        try
        {
            var connection = db.Database.GetDbConnection();
            await using var check = connection.CreateCommand();
            check.CommandText = """
                SELECT CASE WHEN
                    OBJECT_ID(N'dbo.Promotions', N'U') IS NOT NULL AND
                    OBJECT_ID(N'dbo.PromotionUsages', N'U') IS NOT NULL AND
                    OBJECT_ID(N'dbo.Rewards', N'U') IS NOT NULL AND
                    OBJECT_ID(N'dbo.RewardRedemptions', N'U') IS NOT NULL AND
                    OBJECT_ID(N'dbo.LoyaltyPointTransactions', N'U') IS NOT NULL AND
                    OBJECT_ID(N'dbo.LoyaltySettings', N'U') IS NOT NULL AND
                    COL_LENGTH(N'dbo.Orders', N'Subtotal') IS NOT NULL
                THEN 1 ELSE 0 END;
                """;
            var schemaReady = Convert.ToInt32(await check.ExecuteScalarAsync(token));
            if (schemaReady == 1) return;

            var scriptPath = Path.Combine(AppContext.BaseDirectory, "010_promotions_loyalty.sql");
            if (!File.Exists(scriptPath))
                throw new FileNotFoundException("Không tìm thấy migration database/010_promotions_loyalty.sql trong thư mục chạy ứng dụng.", scriptPath);

            var script = await File.ReadAllTextAsync(scriptPath, token);
            foreach (var batch in GoBatch().Split(script).Where(batch => !string.IsNullOrWhiteSpace(batch)))
            {
                await using var command = connection.CreateCommand();
                command.CommandText = batch;
                await command.ExecuteNonQueryAsync(token);
            }
        }
        catch (Exception ex) when (ex is System.Data.Common.DbException or IOException)
        {
            throw new InvalidOperationException(
                "Không cập nhật được schema khuyến mãi/tích điểm. Kiểm tra quyền tạo bảng của SQL Server hoặc chạy database/010_promotions_loyalty.sql trong SSMS.", ex);
        }
        finally
        {
            await db.Database.CloseConnectionAsync();
        }
    }

    [GeneratedRegex("(?im)^\\s*GO\\s*(?:--.*)?$", RegexOptions.CultureInvariant)]
    private static partial Regex GoBatch();
}
