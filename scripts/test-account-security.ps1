param([string]$BaseUrl = 'http://127.0.0.1:5101')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot
$preview = Join-Path $root 'backend/Veggie.Api/email-preview'
$email = 'security-' + [guid]::NewGuid().ToString('N') + '@example.test'
$password = 'Test!' + [guid]::NewGuid().ToString('N')
$newPassword = 'New!' + [guid]::NewGuid().ToString('N')
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$results = [System.Collections.Generic.List[string]]::new()
function Call($path, $body, $expected, $useSession = $session) {
    $response = Invoke-WebRequest ($BaseUrl + $path) -Method Post -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes(($body | ConvertTo-Json -Depth 6))) -WebSession $useSession -SkipHttpErrorCheck
    if ([int]$response.StatusCode -ne $expected) { throw "Expected $expected at $path; got $($response.StatusCode)" }
    return $response
}
function CheckGet($path, $expected, $useSession = $session) {
    $response = Invoke-WebRequest ($BaseUrl + $path) -WebSession $useSession -SkipHttpErrorCheck
    if ([int]$response.StatusCode -ne $expected) { throw "Expected $expected at $path; got $($response.StatusCode)" }
}
function LinkToken($purpose) {
    $file = Get-ChildItem -LiteralPath $preview -Filter '*.eml' | Where-Object { (Get-Content -LiteralPath $_.FullName -Raw) -match [regex]::Escape($email) } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (!$file) { throw 'No email preview found.' }
    $text = (Get-Content -LiteralPath $file.FullName -Raw) -replace '=\r?\n','' -replace '=3D','='
    if ($text -notmatch ('purpose=' + $purpose + '&token=([A-F0-9]{64})')) { throw 'Email token not found.' }
    return $Matches[1]
}
try {
    Call '/api/account/register' @{email=$email;password=$password;confirmPassword=$password;firstName='Test';lastName='Security';acceptPrivacyPolicy=$false} 400 | Out-Null
    Call '/api/account/register' @{email=$email;password=$password;confirmPassword=$password;firstName='Test';lastName='Security';acceptPrivacyPolicy=$true} 200 | Out-Null
    $results.Add('PASS registration requires privacy consent and produces verification email preview')
    Call '/api/account/login' @{email=$email;password=$password} 403 | Out-Null
    Call '/api/account/verify-email' @{token=('0'*64)} 400 | Out-Null
    $verify = LinkToken 'verify'
    Call '/api/account/verify-email' @{token=$verify} 200 | Out-Null
    Call '/api/account/verify-email' @{token=$verify} 400 | Out-Null
    Call '/api/account/login' @{email=$email;password=$password} 200 | Out-Null
    $results.Add('PASS unverified login denied; verification token valid once; invalid token rejected')
    Call '/api/account/forgot-password' @{email=$email} 200 | Out-Null
    $reset = LinkToken 'reset'
    Call '/api/account/reset-password' @{token=$reset;password=$newPassword;confirmPassword='different'} 400 | Out-Null
    Call '/api/account/reset-password' @{token=$reset;password=$newPassword;confirmPassword=$newPassword} 200 | Out-Null
    Call '/api/account/reset-password' @{token=$reset;password=$newPassword;confirmPassword=$newPassword} 400 | Out-Null
    CheckGet '/api/account/me' 401
    Call '/api/account/login' @{email=$email;password=$password} 401 | Out-Null
    Call '/api/account/login' @{email=$email;password=$newPassword} 200 | Out-Null
    $results.Add('PASS reset confirmation; one-use reset token; old password and old session invalidated')
    Call '/api/account/forgot-password' @{email='unknown-'+[guid]::NewGuid().ToString('N')+'@example.test'} 200 | Out-Null
    CheckGet '/api/orders' 401 (New-Object Microsoft.PowerShell.Commands.WebRequestSession)
    $results.Add('PASS unknown email generic response; guest cannot read orders')
    # This account belongs only to this disposable local test workflow.
    sqlcmd -S 'MSI\SQLEXPRESS' -E -C -b -Q "USE Veggie; UPDATE dbo.Users SET Status=0 WHERE Email=N'$email';" | Out-Null
    CheckGet '/api/account/me' 401
    $results.Add('PASS disabled account cookie immediately rejected')
    $results.Add('Email delivery mode: local .eml preview ONLY; no real SMTP delivery tested.')
    $results | Set-Content -LiteralPath (Join-Path $root 'docs/account-security-test.txt') -Encoding utf8
    $results
} finally {
    sqlcmd -S 'MSI\SQLEXPRESS' -E -C -b -Q "USE Veggie; UPDATE dbo.Users SET Status=0, SecurityStamp=CONVERT(nvarchar(36),NEWID()) WHERE Email=N'$email';" | Out-Null
}
