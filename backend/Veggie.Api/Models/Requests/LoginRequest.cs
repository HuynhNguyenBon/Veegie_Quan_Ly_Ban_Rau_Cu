using System.ComponentModel.DataAnnotations;

namespace Veggie.Api.Models.Requests;

public class LoginRequest
{
    [Required, EmailAddress, StringLength(254)]
    public string Email { get; set; } = "";
    [Required, StringLength(128)]
    public string Password { get; set; } = "";
}

public sealed class RegisterRequest : LoginRequest
{
    [Required, StringLength(60)]
    public string FirstName { get; set; } = "";
    [Required, StringLength(59)]
    public string LastName { get; set; } = "";
    [Required, Compare(nameof(Password))]
    public string ConfirmPassword { get; set; } = "";
    public bool AcceptPrivacyPolicy { get; set; }
}

