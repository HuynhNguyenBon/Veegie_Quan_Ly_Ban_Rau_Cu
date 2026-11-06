using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using Veggie.Api.Models.Responses;

namespace Veggie.Api.Services;

public static class ChatFallback
{
    public static string Answer(string question, IReadOnlyList<CatalogProduct> products)
    {
        var query = Normalize(question);
        var answers = new List<string>();
        if (Has(query, "giao hang", "phi ship", "van chuyen", "freeship", "mien phi", "phi giao"))
            answers.Add("Phí giao hàng là 25.000 ₫; miễn phí với đơn từ 300.000 ₫.");
        if (Has(query, "thanh toan", "chuyen khoan", "cod", "tra tien", "vietcombank"))
            answers.Add("Veggie hỗ trợ COD (trả tiền khi nhận hàng) và chuyển khoản Vietcombank. Khi đặt đơn chuyển khoản, bạn sẽ thấy QR, số tiền và nội dung theo mã đơn. Cửa hàng kiểm tra tiền nhận được rồi xác nhận; quét QR chưa có nghĩa là đã thanh toán.");
        if (Has(query, "don hang", "lich su", "theo doi don"))
            answers.Add("Bạn xem lịch sử mua hàng và trạng thái đơn trong mục Tài khoản. Tôi không xác nhận trạng thái đơn cá nhân trong khung chat này.");
        if (Has(query, "mua hang", "dat hang", "them vao gio"))
            answers.Add("Chọn sản phẩm ở Cửa hàng, thêm vào giỏ, mở Thanh toán, nhập địa chỉ và chọn phương thức thanh toán rồi đặt hàng.");

        var ignored = new HashSet<string>("gia bao nhieu tien san pham con hang khong cho toi minh ban cua veggie muon mua xem tim voi nao duoc the nao la co va mot kg tui hop qua".Split(' '));
        var words = query.Split(' ', StringSplitOptions.RemoveEmptyEntries).Where(w => !ignored.Contains(w)).Distinct().ToArray();
        var matches = products.Select(p => new
            {
                Product = p,
                Score = words.Count(w => (" " + Normalize(p.Name) + " ").Contains(" " + w + " ", StringComparison.Ordinal))
            })
            .Where(p => p.Score > 0 &&
                (p.Score == words.Length || Has(query, Normalize(p.Product.Name))))
            .OrderByDescending(p => p.Score).ThenBy(p => p.Product.Id).ToList();
        if (matches.Count > 0)
        {
            var best = matches[0].Score;
            var selected = matches.Where(p => p.Score == best).Take(5).Select(p => p.Product);
            answers.Add("Sản phẩm liên quan trong cửa hàng:\n" + string.Join("\n", selected.Select(p =>
                $"• {p.Name}: {p.Price.ToString("N0", CultureInfo.GetCultureInfo("vi-VN"))} ₫/{p.Unit} — {(p.Stock > 0 ? $"còn {p.Stock} {p.Unit}" : "hết hàng")}.")) + "\nGiá và tồn kho được đọc từ cửa hàng tại thời điểm trả lời; hệ thống kiểm tra lại khi đặt đơn.");
        }
        if (answers.Count == 0)
            answers.Add("Tôi có thể tra giá, tồn kho theo tên sản phẩm và hướng dẫn giao hàng, thanh toán, mua hàng. Bạn hãy ghi rõ tên sản phẩm hoặc nội dung cần hỗ trợ. Với yêu cầu khác, vui lòng dùng trang Liên hệ.");
        return string.Join("\n\n", answers);
    }

    private static bool Has(string query, params string[] phrases) => phrases.Any(p =>
        (" " + query + " ").Contains(" " + p + " ", StringComparison.Ordinal));

    private static string Normalize(string value)
    {
        var text = new StringBuilder();
        foreach (var c in value.ToLowerInvariant().Normalize(NormalizationForm.FormD))
            if (CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark)
                text.Append(c == 'đ' ? 'd' : c);
        return Regex.Replace(text.ToString(), "[^a-z0-9]+", " ").Trim();
    }
}
