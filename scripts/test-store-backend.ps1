param([string]$BaseUrl='http://127.0.0.1:5101')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot
$suffix=[guid]::NewGuid().ToString('N')
$email='store-'+$suffix+'@example.test'
$password='Test!'+$suffix
$session=New-Object Microsoft.PowerShell.Commands.WebRequestSession
$customer=New-Object Microsoft.PowerShell.Commands.WebRequestSession
$report=[Collections.Generic.List[string]]::new()
function Sql($query) {
    $out=sqlcmd -S 'MSI\SQLEXPRESS' -E -C -b -d Veggie -h -1 -W -Q "SET NOCOUNT ON; $query"
    if($LASTEXITCODE -ne 0){throw 'SQL test operation failed.'}
    return ($out -join "`n").Trim()
}
function Json($path,$body,$expected=200,$use=$session) {
    $r=Invoke-WebRequest ($BaseUrl+$path) -Method Post -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes(($body|ConvertTo-Json -Depth 6))) -WebSession $use -SkipHttpErrorCheck
    if([int]$r.StatusCode -ne $expected){throw "Expected $expected at $path got $($r.StatusCode)"}
    if($r.Content){return $r.Content|ConvertFrom-Json}
}
function AdminPost($path,$body,$expected=200){
    $page=Invoke-WebRequest ($BaseUrl+'/admin/orders') -WebSession $session
    $csrf=[regex]::Match($page.Content,'name="__RequestVerificationToken"[^>]*value="([^"]+)"').Groups[1].Value
    if(!$csrf){throw 'Missing antiforgery token'}
    $body['__RequestVerificationToken']=[Net.WebUtility]::HtmlDecode($csrf)
    $r=Invoke-WebRequest ($BaseUrl+$path) -Method Post -ContentType 'application/x-www-form-urlencoded' -Body $body -WebSession $session -SkipHttpErrorCheck
    if([int]$r.StatusCode -ne $expected){throw "Expected $expected at $path got $($r.StatusCode)"}
}
function Check($ok,$message){if(!$ok){throw $message};$report.Add('PASS '+$message)}
$productId=$null
try {
    Json '/api/account/register' @{email=$email;password=$password;confirmPassword=$password;firstName='Store';lastName='Test';acceptPrivacyPolicy=$true}|Out-Null
    $file=Get-ChildItem (Join-Path $root 'backend/Veggie.Api/email-preview') -Filter '*.eml'|Where-Object{(Get-Content $_.FullName -Raw)-match [regex]::Escape($email)}|Sort-Object LastWriteTime -Descending|Select-Object -First 1
    $text=(Get-Content $file.FullName -Raw)-replace '=\r?\n','' -replace '=3D','='
    $verify=[regex]::Match($text,'token=([A-F0-9]{64})').Groups[1].Value
    # Expired verification cannot be used; restore only this test token for remaining checks.
    Sql "UPDATE t SET ExpiresAt=DATEADD(minute,-1,SYSUTCDATETIME()) FROM AccountTokens t JOIN Users u ON u.Id=t.UserId WHERE u.Email=N'$email';"|Out-Null
    Json '/api/account/verify-email' @{token=$verify} 400|Out-Null
    Sql "UPDATE t SET ExpiresAt=DATEADD(minute,20,SYSUTCDATETIME()) FROM AccountTokens t JOIN Users u ON u.Id=t.UserId WHERE u.Email=N'$email';"|Out-Null
    Json '/api/account/verify-email' @{token=$verify}|Out-Null
    Json '/api/account/login' @{email=$email;password=$password}|Out-Null
    $forbidden=Invoke-WebRequest ($BaseUrl+'/admin/products') -WebSession $session -SkipHttpErrorCheck
    Check ([int]$forbidden.StatusCode -eq 403) 'Customer cannot open product administration; expired email link rejected'
    # Assign Admin only to the disposable account created by this script.
    Sql "UPDATE Users SET RoleId=(SELECT Id FROM Roles WHERE Name='Admin') WHERE Email=N'$email';"|Out-Null
    $stale=Invoke-WebRequest ($BaseUrl+'/api/account/me') -WebSession $session -SkipHttpErrorCheck
    Check ([int]$stale.StatusCode -eq 401) 'Cookie invalidated after role change'
    Json '/api/account/login' @{email=$email;password=$password}|Out-Null
    $missing=Invoke-WebRequest ($BaseUrl+'/admin/products/create') -Method Post -Body @{name='forged'} -WebSession $session -SkipHttpErrorCheck
    Check ([int]$missing.StatusCode -eq 400) 'Admin write rejects missing antiforgery token'
    $category=[int](Sql 'SELECT TOP(1) Id FROM Categories ORDER BY Id;')
    $name='QA Store '+$suffix
    AdminPost '/admin/products/create' @{name=$name;categoryId=$category;price=32000;stock=3;unit='kg';image='img/product/1.png'}
    $productId=[int](Sql "SELECT Id FROM Products WHERE Name=N'$name';")
    AdminPost "/admin/products/$productId" @{price=35000;stock=3;active='true';image='img/product/1.png'}
    $catalog=Invoke-RestMethod ($BaseUrl+'/api/catalog')
    $product=$catalog.products|Where-Object id -eq $productId
    Check ($product.price -eq 35000 -and $product.stock -eq 3) 'Admin create and update reflected in SQL catalogue'
    $productPage=Invoke-WebRequest ($BaseUrl+'/admin/products') -WebSession $session
    $csrf=[Net.WebUtility]::HtmlDecode([regex]::Match($productPage.Content,'name="__RequestVerificationToken"[^>]*value="([^"]+)"').Groups[1].Value)
    $upload=Get-Item (Join-Path $root 'clients/img/payments/vietcombank-qr.png')
    $imageResult=Invoke-WebRequest ($BaseUrl+"/admin/products/$productId") -Method Post -Form @{__RequestVerificationToken=$csrf;price='35000';stock='3';active='true';photo=$upload} -WebSession $session -SkipHttpErrorCheck
    $catalog=Invoke-RestMethod ($BaseUrl+'/api/catalog')
    $updated=$catalog.products|Where-Object id -eq $productId
    $imageResponse=Invoke-WebRequest ($BaseUrl+$updated.image) -SkipHttpErrorCheck
    Check ($imageResult.StatusCode -eq 200 -and $updated.image.StartsWith('/product-uploads/') -and $imageResponse.Headers['Content-Type'] -match 'image/png') 'Product image upload served correctly and catalogue updated'
    Json '/api/account/login' @{email='chat-bb67f3fb-c371-44fe-84e0-25b386903711@example.test';password='bb67f3fb-c371-44fe-84e0-25b386903711'} 200 $customer|Out-Null
    $order=@{name='TEST ONLY';phone='0900000000';address='TEST ONLY';city='TEST';note='AUTOMATED TEST - NO DELIVERY OR MONEY';items=@(@{id=$productId;quantity=1});requestId=[guid]::NewGuid().ToString();paymentMethod='COD'}
    $cod=Json '/api/orders' $order 200 $customer
    $replay=Json '/api/orders' $order 200 $customer
    Check ($cod.code -eq $replay.code -and $cod.total -eq 60000) 'COD total calculated on server; repeated request creates one order'
    $codId=[int]$cod.code.Substring(2)
    Json '/api/orders/track' @{code=$cod.code;email='chat-bb67f3fb-c371-44fe-84e0-25b386903711@example.test'} 404 $session|Out-Null
    Check $true 'Another account cannot track customer order'
    foreach($current in @('pending','confirmed','shipping')){AdminPost "/admin/orders/$codId" @{current=$current}}
    AdminPost "/admin/orders/$codId" @{current='pending'} 409
    Check ((Sql "SELECT Status FROM Payments WHERE OrderId=$codId;") -eq 'paid') 'COD delivered and paid; stale transition rejected'
    $order.requestId=[guid]::NewGuid().ToString();$order.paymentMethod='BankTransfer'
    $bank=Json '/api/orders' $order 200 $customer
    $bankId=[int]$bank.code.Substring(2)
    AdminPost "/admin/orders/$bankId" @{current='pending'} 409
    AdminPost "/admin/orders/$bankId/bank-paid" @{}
    AdminPost "/admin/orders/$bankId/bank-paid" @{}
    AdminPost "/admin/orders/$bankId" @{current='pending'}
    Check ((Sql "SELECT COUNT(*) FROM Notifications WHERE UserId=(SELECT UserId FROM Orders WHERE Id=$bankId) AND Type='payment' AND Message LIKE N'%VG$bankId.%';") -eq '1') 'Bank transfer blocked before confirmation; duplicate confirmation produces one notification (simulated only)'
    $notifications=Invoke-RestMethod ($BaseUrl+'/api/notifications') -WebSession $customer
    Check (@($notifications).Count -gt 0) 'Customer receives order notifications'
    AdminPost "/admin/products/$productId" @{price=35000;stock=0;active='true'}
    $order.requestId=[guid]::NewGuid().ToString()
    Json '/api/orders' $order 409 $customer|Out-Null
    Check $true 'Out of stock order rejected'
    AdminPost "/admin/products/$productId" @{price=35000;stock=0;active='false'}
    $catalog=Invoke-RestMethod ($BaseUrl+'/api/catalog')
    Check (!($catalog.products|Where-Object id -eq $productId)) 'Hidden product removed from storefront catalogue'
    $contacts=Invoke-WebRequest ($BaseUrl+'/admin/contacts') -WebSession $session
    Check ([int]$contacts.StatusCode -eq 200) 'Admin contact inbox accessible'
    Json '/api/contacts' @{name='QA Contact';email=$email;phone='0900000000';message='TEST CONTACT '+$suffix} 204|Out-Null
    $contactId=[int](Sql "SELECT Id FROM Contacts WHERE Email=N'$email';")
    AdminPost "/admin/contacts/$contactId/replied" @{}
    Check ((Sql "SELECT CONVERT(int,IsReply) FROM Contacts WHERE Id=$contactId;") -eq '1') 'Contact submitted and marked replied by Admin'
    $report.Add('Scope: isolated local fixtures; no real email, transfer or delivery. Test orders retained and marked TEST.')
    $report|Set-Content (Join-Path $root 'docs/store-backend-test.txt') -Encoding utf8
    $report
} finally {
    if($productId){Sql "UPDATE Products SET Status=0 WHERE Id=$productId AND Name LIKE N'QA Store %';"|Out-Null}
    Sql "UPDATE Users SET Status=0,RoleId=(SELECT Id FROM Roles WHERE Name='Customer'),SecurityStamp=CONVERT(nvarchar(36),NEWID()) WHERE Email=N'$email';"|Out-Null
}

