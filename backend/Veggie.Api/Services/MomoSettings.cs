using System.Security.Cryptography;
using System.Text;

namespace Veggie.Api.Services;

public sealed class MomoSettings(IConfiguration configuration)
{
    public string PartnerCode => configuration["MoMo:PartnerCode"] ?? "";
    public string AccessKey => configuration["MoMo:AccessKey"] ?? "";
    public string SecretKey => configuration["MoMo:SecretKey"] ?? "";
    public string PublicUrl => (configuration["MoMo:PublicUrl"] ?? "").TrimEnd('/');
    public bool Ready => !string.IsNullOrWhiteSpace(PartnerCode) &&
        !string.IsNullOrWhiteSpace(AccessKey) && !string.IsNullOrWhiteSpace(SecretKey) &&
        Uri.TryCreate(PublicUrl, UriKind.Absolute, out var uri) && uri.Scheme == "https";

    public string Sign(string value) =>
        Convert.ToHexStringLower(HMACSHA256.HashData(Encoding.UTF8.GetBytes(SecretKey), Encoding.UTF8.GetBytes(value)));
}
