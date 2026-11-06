using System.Security.Claims;
using System.Security.Cryptography;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.EF;
using Veggie.Api.Services;

namespace Veggie.Api.Controllers;

[ApiController, Route("api/momo")]
public sealed class MomoController(VeggieDbContext db, MomoSettings settings, IHttpClientFactory clients) : ControllerBase
{
    [Authorize, HttpPost("{orderId:int}")]
    public async Task<IActionResult> Create(int orderId, CancellationToken token)
    {
        if (!settings.Ready) return StatusCode(503, new { message = "MoMo Test chưa được cấu hình." });
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await using var transaction = await db.Database.BeginTransactionAsync(token);
        var locked = await db.Orders.Where(o => o.Id == orderId && o.UserId == userId && o.Status == "pending")
            .ExecuteUpdateAsync(set => set.SetProperty(o => o.Status, "pending"), token);
        if (locked != 1) return Conflict(new { message = "Chỉ thanh toán MoMo cho đơn đang chờ xác nhận." });
        var payment = await db.Payments.SingleAsync(p => p.OrderId == orderId, token);
        if (payment.Status == "paid") return Conflict(new { message = "Đơn đã thanh toán." });
        if (!string.IsNullOrEmpty(payment.GatewayPayUrl)) return Ok(new { payUrl = payment.GatewayPayUrl });
        payment.GatewayOrderId ??= $"VG{orderId}-{Guid.NewGuid():N}";
        payment.PaymentMethod = "MoMo";
        await db.SaveChangesAsync(token);
        await transaction.CommitAsync(token);

        var gatewayId = payment.GatewayOrderId;
        var amount = decimal.ToInt64(payment.Amount);
        var orderInfo = $"Thanh toan don VG{orderId}";
        var redirectUrl = settings.PublicUrl + "/api/momo/return";
        var ipnUrl = settings.PublicUrl + "/api/momo/ipn";
        var signature = settings.Sign($"accessKey={settings.AccessKey}&amount={amount}&extraData=&ipnUrl={ipnUrl}&orderId={gatewayId}&orderInfo={orderInfo}&partnerCode={settings.PartnerCode}&redirectUrl={redirectUrl}&requestId={gatewayId}&requestType=captureWallet");
        using var client = clients.CreateClient();
        client.Timeout = TimeSpan.FromSeconds(20);
        try
        {
            using var response = await client.PostAsJsonAsync("https://test-payment.momo.vn/v2/gateway/api/create", new
            {
                partnerCode = settings.PartnerCode, requestId = gatewayId, orderId = gatewayId,
                amount, orderInfo, redirectUrl, ipnUrl, requestType = "captureWallet",
                extraData = "", lang = "vi", autoCapture = true, signature
            }, token);
            if (response.IsSuccessStatusCode)
            {
                using var json = await JsonDocument.ParseAsync(await response.Content.ReadAsStreamAsync(token), cancellationToken: token);
                var root = json.RootElement;
                if (root.TryGetProperty("resultCode", out var code) && code.GetInt32() == 0 &&
                    root.TryGetProperty("payUrl", out var link) &&
                    Uri.TryCreate(link.GetString(), UriKind.Absolute, out var url) &&
                    url.Scheme == "https" && url.Host == "test-payment.momo.vn")
                {
                    var payUrl = url.AbsoluteUri;
                    await db.Payments.Where(p => p.Id == payment.Id)
                        .ExecuteUpdateAsync(set => set.SetProperty(p => p.GatewayPayUrl, payUrl), token);
                    return Ok(new { payUrl });
                }
            }
        }
        catch (HttpRequestException) { }
        catch (OperationCanceledException) when (!token.IsCancellationRequested) { }
        return StatusCode(502, new { message = "Chưa lấy được trang thanh toán MoMo. Kiểm tra trạng thái đơn trước khi thử lại." });
    }

    [HttpGet("return")]
    public IActionResult Return() => Redirect("/clients/account.html");

    public sealed record Notification(string PartnerCode, string OrderId, string RequestId, long Amount,
        string OrderInfo, string OrderType, long TransId, int ResultCode, string Message,
        string PayType, long ResponseTime, string ExtraData, string Signature);

    [HttpPost("ipn")]
    public async Task<IActionResult> Notify(Notification notice, CancellationToken token)
    {
        if (!settings.Ready) return StatusCode(503);
        if (notice.PartnerCode != settings.PartnerCode || notice.Signature?.Length != 64 ||
            notice.OrderId != notice.RequestId) return BadRequest();
        var raw = $"accessKey={settings.AccessKey}&amount={notice.Amount}&extraData={notice.ExtraData}&message={notice.Message}&orderId={notice.OrderId}&orderInfo={notice.OrderInfo}&orderType={notice.OrderType}&partnerCode={notice.PartnerCode}&payType={notice.PayType}&requestId={notice.RequestId}&responseTime={notice.ResponseTime}&resultCode={notice.ResultCode}&transId={notice.TransId}";
        byte[] supplied;
        try { supplied = Convert.FromHexString(notice.Signature); }
        catch (FormatException) { return BadRequest(); }
        if (!CryptographicOperations.FixedTimeEquals(supplied, Convert.FromHexString(settings.Sign(raw)))) return BadRequest();

        await using var transaction = await db.Database.BeginTransactionAsync(token);
        var orderId = await db.Payments.Where(p => p.GatewayOrderId == notice.OrderId).Select(p => (int?)p.OrderId).SingleOrDefaultAsync(token);
        if (orderId is null) return NotFound();
        await db.Orders.Where(o => o.Id == orderId).ExecuteUpdateAsync(set => set.SetProperty(o => o.Status, o => o.Status), token);
        var payment = await db.Payments.SingleAsync(p => p.OrderId == orderId, token);
        if (payment.Amount != notice.Amount || payment.PaymentMethod != "MoMo") return BadRequest();
        if (notice.ResultCode == 0 && payment.Status != "paid")
        {
            payment.Status = "paid";
            payment.PaidAt = DateTime.UtcNow;
            // Keep the checkout reference for order retry detection.
            await db.SaveChangesAsync(token);
        }
        await transaction.CommitAsync(token);
        return NoContent();
    }

    [HttpGet("availability")]
    public IActionResult Availability() => Ok(new { enabled = settings.Ready });
}
