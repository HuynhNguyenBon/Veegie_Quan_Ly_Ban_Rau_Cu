using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.EntityFrameworkCore;
using MimeKit;
using Veggie.Api.Models.EF;

namespace Veggie.Api.Services;

public sealed class StoreEmailWorker(IServiceScopeFactory scopes, IConfiguration config, IWebHostEnvironment environment,
    ILogger<StoreEmailWorker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try { await Process(stoppingToken); }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested) { break; }
            catch (Exception ex) { logger.LogWarning("Store mail queue unavailable ({Type}).", ex.GetType().Name); }
            try { await Task.Delay(TimeSpan.FromSeconds(15), stoppingToken); }
            catch (OperationCanceledException) { break; }
        }
    }

    private async Task Process(CancellationToken token)
    {
        var pickup = environment.IsDevelopment() && config["Email:Delivery"] == "Pickup";
        if (!pickup && string.IsNullOrWhiteSpace(config["Email:Password"])) return;
        using var scope = scopes.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<VeggieDbContext>();
        var now = DateTime.UtcNow;
        var pending = await db.StoreEmailQueue.AsNoTracking().Where(e => e.SentAt == null && e.Attempts < 5 && e.NextAttemptAt <= now)
            .OrderBy(e => e.Id).Take(5).ToListAsync(token);
        foreach (var item in pending)
        {
            var claimed = await db.StoreEmailQueue.Where(e => e.Id == item.Id && e.SentAt == null && e.Attempts == item.Attempts && e.NextAttemptAt <= now)
                .ExecuteUpdateAsync(s => s.SetProperty(e => e.Attempts, e => e.Attempts + 1)
                    .SetProperty(e => e.NextAttemptAt, now.AddMinutes(5)), token);
            if (claimed != 1) continue;
            try
            {
                var mail = new MimeMessage();
                mail.From.Add(new MailboxAddress("Veggie", config["Email:From"] ?? "veggie@example.test"));
                mail.To.Add(MailboxAddress.Parse(item.ToEmail));
                if (!string.IsNullOrWhiteSpace(item.ReplyTo)) mail.ReplyTo.Add(MailboxAddress.Parse(item.ReplyTo));
                mail.Subject = item.Subject;
                mail.Body = new TextPart(item.Body.StartsWith("<!doctype html>", StringComparison.Ordinal) ? "html" : "plain") { Text = item.Body };
                if (pickup)
                {
                    var directory = config["Email:PickupDirectory"] ?? Path.Combine(environment.ContentRootPath, "email-preview");
                    Directory.CreateDirectory(directory);
                    await mail.WriteToAsync(Path.Combine(directory, "store-" + item.Id + ".eml"), token);
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
                await db.StoreEmailQueue.Where(e => e.Id == item.Id).ExecuteUpdateAsync(s => s.SetProperty(e => e.SentAt, DateTime.UtcNow), token);
            }
            catch (Exception ex) when (ex is not OperationCanceledException || !token.IsCancellationRequested)
            {
                logger.LogWarning("Store email {Id} delivery failed ({Type}).", item.Id, ex.GetType().Name);
            }
        }
    }
}

