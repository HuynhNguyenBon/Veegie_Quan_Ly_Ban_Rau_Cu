using System.Security.Cryptography;
using System.Text;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.EntityFrameworkCore;
using MimeKit;
using Veggie.Api.Models.EF;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Services;

public sealed class AccountEmailService(VeggieDbContext db, IConfiguration config, IWebHostEnvironment environment,
    ILogger<AccountEmailService> logger)
{
    private bool Pickup => environment.IsDevelopment() && config["Email:Delivery"] == "Pickup";
    public bool IsPickupPreview => Pickup;
    private bool SmtpReady => Pickup || (!string.IsNullOrWhiteSpace(config["Email:Host"])
        && !string.IsNullOrWhiteSpace(config["Email:Password"])
        && !string.IsNullOrWhiteSpace(config["Email:From"]));

    public bool IsReady(HttpRequest request, string purpose = "reset") => SmtpReady
        && (purpose == "verify" || GetPublicBaseUrl(request) is not null);

    public static string Hash(string token) => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token)));

    public async Task<bool> SendAsync(User user, string purpose, HttpRequest request, CancellationToken token)
    {
        var publicBaseUrl = purpose == "verify" ? null : GetPublicBaseUrl(request);
        if (!SmtpReady || (purpose != "verify" && publicBaseUrl is null)) return false;
        var now = DateTime.UtcNow;
        await using (var transaction = await db.Database.BeginTransactionAsync(token))
        {
            await db.Users.Where(u => u.Id == user.Id).ExecuteUpdateAsync(s => s.SetProperty(u => u.UpdatedAt, u => u.UpdatedAt), token);
            if (await db.AccountTokens.AnyAsync(t => t.UserId == user.Id && t.Purpose == purpose && t.CreatedAt > now.AddMinutes(-1), token))
                return true;
            await db.AccountTokens.Where(t => t.UserId == user.Id && t.Purpose == purpose && t.UsedAt == null)
                .ExecuteUpdateAsync(s => s.SetProperty(t => t.UsedAt, now), token);
            var raw = purpose == "verify"
                ? RandomNumberGenerator.GetInt32(0, 100_000_000).ToString("D8")
                : Convert.ToHexString(RandomNumberGenerator.GetBytes(32));
            var record = new AccountToken { UserId = user.Id, Purpose = purpose, TokenHash = Hash(raw), CreatedAt = now,
                ExpiresAt = now.AddMinutes(purpose == "verify" ? 10 : 20) };
            db.AccountTokens.Add(record);
            await db.SaveChangesAsync(token);
            await transaction.CommitAsync(token);
            var link = publicBaseUrl + "/clients/account-security.html#purpose=" + purpose + "&token=" + raw;
            var mail = new MimeMessage();
            mail.From.Add(new MailboxAddress("Veggie", config["Email:From"] ?? "veggie@example.test"));
            mail.To.Add(MailboxAddress.Parse(user.Email));
            mail.Subject = purpose == "verify" ? "Xác minh email tài khoản Veggie" : "Đặt lại mật khẩu Veggie";
            mail.Body = new TextPart("plain") { Text = purpose == "verify"
                ? $"Mã xác minh tài khoản Veggie của bạn là: {raw}\n\nMã chỉ dùng một lần và hết hạn sau 10 phút. Nhập mã này trên trang đăng ký để kích hoạt tài khoản. Nếu bạn không yêu cầu, hãy bỏ qua email này."
                : $"{mail.Subject}\n\nMở liên kết sau:\n{link}\n\nLiên kết chỉ dùng một lần, hết hạn sau 20 phút. Nếu bạn không yêu cầu, hãy bỏ qua email này." };
            try
            {
                if (Pickup)
                {
                    var directory = Path.Combine(environment.ContentRootPath, "email-preview");
                    Directory.CreateDirectory(directory);
                    await mail.WriteToAsync(Path.Combine(directory, record.Id + ".eml"), token);
                }
                else
                {
                    using var smtp = new SmtpClient { Timeout = 15000 };
                    var port = config.GetValue("Email:Port", 587);
                    await smtp.ConnectAsync(config["Email:Host"]!, port, port == 465 ? SecureSocketOptions.SslOnConnect : SecureSocketOptions.StartTls, token);
                    await smtp.AuthenticateAsync((config["Email:Username"] ?? config["Email:From"])!, config["Email:Password"]!, token);
                    await smtp.SendAsync(mail, token);
                    await smtp.DisconnectAsync(true, token);
                }
                return true;
            }
            catch (Exception ex) when (ex is not OperationCanceledException || !token.IsCancellationRequested)
            {
                // Do not log email contents, tokens, credentials or SMTP server responses.
                logger.LogWarning("Account email delivery failed ({Type}).", ex.GetType().Name);
                await db.AccountTokens.Where(t => t.Id == record.Id).ExecuteUpdateAsync(s => s.SetProperty(t => t.CreatedAt, now.AddMinutes(-2)).SetProperty(t => t.UsedAt, now), token);
                return false;
            }
        }
    }

    private string? GetPublicBaseUrl(HttpRequest request)
    {
        var configuredUrl = config["Email:PublicUrl"]?.Trim();
        if (!string.IsNullOrWhiteSpace(configuredUrl))
        {
            if (!Uri.TryCreate(configuredUrl, UriKind.Absolute, out var configuredUri)
                || (configuredUri.Scheme != Uri.UriSchemeHttps && !configuredUri.IsLoopback))
                return null;

            return configuredUri.GetLeftPart(UriPartial.Authority).TrimEnd('/');
        }

        if (!request.Host.HasValue
            || !Uri.TryCreate($"{request.Scheme}://{request.Host.Value}", UriKind.Absolute, out var requestUri)
            || (requestUri.Scheme != Uri.UriSchemeHttps && requestUri.Scheme != Uri.UriSchemeHttp))
            return null;

        // Local HTTP is useful for development; public deployments must use HTTPS or a configured HTTPS URL.
        if (requestUri.Scheme != Uri.UriSchemeHttps && !requestUri.IsLoopback && !environment.IsDevelopment())
            return null;

        return requestUri.GetLeftPart(UriPartial.Authority).TrimEnd('/');
    }
}

