using Microsoft.AspNetCore.Mvc;
using Veggie.Api.Services;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace Veggie.Api.Controllers;

public class StoreController(CatalogService catalog) : Controller
{
    [HttpGet("/")]
    [HttpGet("/clients")]
    [HttpGet("/clients/")]
    public IActionResult Index() => Redirect("/clients/index.html");

    [HttpGet("/clients/{page}.html")]
    public async Task<IActionResult> Page(string page, CancellationToken cancellationToken)
    {
        Response.Headers.CacheControl = "no-store";
        if (page.Length == 0 || page.Any(c => !char.IsAsciiLetterOrDigit(c) && c != '-'))
            return NotFound();
        var path = Path.Combine(AppContext.BaseDirectory, "wwwroot", "clients", page + ".html");
        if (!System.IO.File.Exists(path))
            return NotFound();
        string html;
        try
        {
            html = await System.IO.File.ReadAllTextAsync(path, cancellationToken);
        }
        catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
        {
            // A browser can cancel a page request while navigating; this is not an application failure.
            return new EmptyResult();
        }
        html = MarkCurrentNavigationLink(html, page + ".html", "class=\"ltn__main-menu\"");
        html = MarkCurrentNavigationLink(html, page + ".html", "id=\"ltn__utilize-mobile-menu\"");
        html = html.Replace("</body>", "<script src=\"js/veggie-bank.js\"></script><script src=\"js/veggie-voice-search.js\"></script></body>");
        html = html.Replace("</body>", "<script src=\"js/veggie-navigation.js\"></script></body>");
        if (page is "login" or "register")
            html = html.Replace("</body>", "<script src=\"js/veggie-account-server.js\"></script></body>");
        if (page == "login")
            html = html.Replace("</body>", "<script src=\"js/veggie-verification.js\"></script></body>");
        if (page == "account")
            html = html.Replace("</body>", "<script src=\"js/veggie-profile-server.js?v=6\"></script></body>");
        if (page == "checkout")
            html = html.Replace("</body>", "<script src=\"js/veggie-checkout-server.js\"></script></body>");
        html = html.Replace("</body>", "<script src=\"js/veggie-cart-server.js\"></script></body>");
        if (page == "order-tracking")
            html = html.Replace("</body>", "<script src=\"js/veggie-tracking-server.js\"></script></body>");
        if (page is "contact" or "quote")
            html = html.Replace("</body>", "<script src=\"js/veggie-contact-server.js\"></script></body>");
        html = html.Replace("</body>", "<script>window.VeggieWishlist?.connect();</script></body>");
        if (page == "product-details")
            html = html.Replace("</body>", "<script src=\"js/veggie-reviews-server.js\"></script><script src=\"js/veggie-product-extras.js\"></script></body>");
        html = Regex.Replace(html, "(?<prefix>(?:src|href)=\"(?<path>(?:js|css)/veggie[^\"?]+\\.(?:js|css)))(?:\\?[^\"]*)?\"", match =>
        {
            var asset = Path.Combine(AppContext.BaseDirectory, "wwwroot", "clients", match.Groups["path"].Value);
            return match.Groups["prefix"].Value + "?v=" + System.IO.File.GetLastWriteTimeUtc(asset).Ticks.ToString("x") + "\"";
        });
        return View("Template", html);
    }

    private static string MarkCurrentNavigationLink(string html, string pageFile, string menuMarker)
    {
        var menuStart = html.IndexOf(menuMarker, StringComparison.OrdinalIgnoreCase);
        if (menuStart < 0)
            return html;

        var hrefMarker = $"href=\"{pageFile}\"";
        var hrefIndex = html.IndexOf(hrefMarker, menuStart, StringComparison.OrdinalIgnoreCase);
        if (hrefIndex < 0)
            return html;

        var anchorStart = html.LastIndexOf("<a", hrefIndex, StringComparison.OrdinalIgnoreCase);
        var anchorEnd = html.IndexOf('>', hrefIndex);
        if (anchorStart < menuStart || anchorEnd < 0)
            return html;

        var anchor = html[anchorStart..(anchorEnd + 1)];
        var classMatch = Regex.Match(anchor, "\\bclass=\"(?<classes>[^\"]*)\"", RegexOptions.IgnoreCase);
        if (classMatch.Success)
        {
            var classes = classMatch.Groups["classes"].Value;
            if (!classes.Split(' ', StringSplitOptions.RemoveEmptyEntries)
                    .Contains("veggie-current-page-link", StringComparer.OrdinalIgnoreCase))
            {
                var updatedClasses = string.IsNullOrWhiteSpace(classes)
                    ? "veggie-current-page-link"
                    : classes + " veggie-current-page-link";
                anchor = anchor[..classMatch.Index]
                    + $"class=\"{updatedClasses}\""
                    + anchor[(classMatch.Index + classMatch.Length)..];
            }
        }
        else
        {
            anchor = anchor.Insert(2, " class=\"veggie-current-page-link\"");
        }

        if (Regex.IsMatch(anchor, "\\baria-current=\"[^\"]*\"", RegexOptions.IgnoreCase))
            anchor = Regex.Replace(anchor, "\\baria-current=\"[^\"]*\"", "aria-current=\"page\"", RegexOptions.IgnoreCase);
        else
            anchor = anchor.Insert(anchor.Length - 1, " aria-current=\"page\"");

        return html[..anchorStart] + anchor + html[(anchorEnd + 1)..];
    }

    [HttpGet("/api/catalog")]
    public async Task<IActionResult> Catalog(CancellationToken cancellationToken) =>
        Ok(await catalog.ReadAsync(cancellationToken));

    [HttpGet("/clients/js/veggie-catalog.js")]
    public async Task<IActionResult> CatalogScript(CancellationToken cancellationToken)
    {
        Response.Headers.CacheControl = "no-store";
        var data = await catalog.ReadAsync(cancellationToken);
        return Content("window.VeggieCatalog = " + JsonSerializer.Serialize(data, JsonSerializerOptions.Web) + ";", "text/javascript");
    }
}














