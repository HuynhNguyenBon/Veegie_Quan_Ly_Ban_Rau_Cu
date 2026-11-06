param([string]$Base='http://127.0.0.1:5510',[string]$Database='VeggieMailQA')
$ErrorActionPreference='Stop'
$results=[Collections.Generic.List[string]]::new()
function Check($condition,$text){if(!$condition){throw "FAIL: $text"};$results.Add("PASS: $text");Write-Host "PASS: $text"}
function Request($path,$session,$method='GET',$body=$null){$args=@{Uri="$Base$path";WebSession=$session;Method=$method;SkipHttpErrorCheck=$true};if($body -is [string]){$args.ContentType='application/json';$args.Body=$body}elseif($null-ne $body){$args.Form=$body}; $response=Invoke-WebRequest @args;$content=if($response.Content-is[byte[]]){[Text.Encoding]::UTF8.GetString($response.Content)}else{$response.Content};[pscustomobject]@{StatusCode=$response.StatusCode;Content=[Net.WebUtility]::HtmlDecode($content)}}
function Token($path,$session){$r=Request $path $session;[regex]::Match($r.Content,'name="__RequestVerificationToken"[^>]*value="([^"]+)"').Groups[1].Value}
$admin=[Microsoft.PowerShell.Commands.WebRequestSession]::new();$customer=[Microsoft.PowerShell.Commands.WebRequestSession]::new();$guest=[Microsoft.PowerShell.Commands.WebRequestSession]::new()
$login=@{email='admin@gmail.com';password=$env:VEGGIE_TEST_PASSWORD}|ConvertTo-Json
$r=Request '/api/account/login' $admin POST $login;Check ($r.StatusCode-eq200) 'Admin login'
foreach($path in @('/admin/dashboard','/admin/users','/admin/categories','/admin/products','/admin/orders','/admin/contacts','/admin/newsletter','/admin/notifications')){$r=Request $path $admin;Check ($r.StatusCode-eq200) "$path loads"}
$email='video-test-'+[guid]::NewGuid().ToString('N')+'@example.test'
$query="INSERT dbo.Users(Name,Email,PasswordHash,RoleId,Status,EmailConfirmed) SELECT N'Video QA', '$email',PasswordHash,(SELECT Id FROM dbo.Roles WHERE Name='Customer'),1,1 FROM dbo.Users WHERE Email='admin@gmail.com';"
& sqlcmd -S 'MSI\SQLEXPRESS' -d $Database -E -C -b -Q $query | Out-Null
try{
$r=Request '/api/account/login' $customer POST (@{email=$email;password=$env:VEGGIE_TEST_PASSWORD}|ConvertTo-Json);Check ($r.StatusCode-eq200) 'Test customer login'
$r=Request '/admin/products' $customer;Check ($r.StatusCode-ne200) 'Customer cannot access product administration'
$csrf=Token '/admin/products' $admin
$r=Request '/admin/products/create' $admin POST @{__RequestVerificationToken=$csrf;name='Video QA '+$email;categoryId='1';price='1000';stock='6';unit='kg';description='San pham kiem thu video'};Check ($r.StatusCode-eq200) 'Create product with description'
$catalog=(Request '/api/catalog' $admin).Content|ConvertFrom-Json;$product=$catalog.products|Where-Object name -eq ('Video QA '+$email);Check ($product.description-eq'San pham kiem thu video') 'Catalog uses new description'
function Place($method){$payload=@{name='Video QA';phone='0900000000';address='Dia chi kiem thu';city='Ha Noi';note='KIEM THU - KHONG GIAO HANG';paymentMethod=$method;requestId=[guid]::NewGuid();items=@(@{id=$product.id;quantity=1})}|ConvertTo-Json -Depth 5;$r=Request '/api/orders' $customer POST $payload;Check ($r.StatusCode-eq200) 'Place test order';($r.Content|ConvertFrom-Json).code.Substring(2)}
$id=Place 'BankTransfer';$csrf=Token '/admin/orders' $admin
$r=Request "/admin/orders/$id" $admin POST @{__RequestVerificationToken=$csrf;current='pending'};Check ($r.StatusCode-eq409) 'Unpaid bank order cannot advance'
$r=Request "/admin/orders/$id/bank-paid" $admin POST @{__RequestVerificationToken=$csrf};Check ($r.Content-match'Cần nhập mã giao dịch') 'Missing bank verification rejected'
$r=Request "/admin/orders/$id/bank-paid" $admin POST @{__RequestVerificationToken=$csrf;transactionId='QA-'+$id;receivedAmount='1';checkedBank='true'};Check ($r.Content-match'số tiền thực nhận không khớp') 'Wrong amount rejected'
$hist=(Request '/api/orders' $customer).Content|ConvertFrom-Json;Check (($hist|Where-Object code -eq "VG$id").paymentStatus-eq'pending') 'Payment remains pending after rejected checks'
$r=Request "/admin/orders/$id/bank-paid" $admin POST @{__RequestVerificationToken=$csrf;transactionId='QA-'+$id;receivedAmount='26000';checkedBank='true'};Check ($r.StatusCode-eq200) 'Test-only bank reconciliation accepted'
$id2=Place 'BankTransfer';$csrf=Token '/admin/orders' $admin
$r=Request "/admin/orders/$id2/bank-paid" $admin POST @{__RequestVerificationToken=$csrf;transactionId='QA-'+$id;receivedAmount='26000';checkedBank='true'};Check ($r.Content-match'Mã giao dịch đã') 'Duplicate bank reference rejected'
$r=Request "/api/orders/$id2/cancel" $customer POST;Check ($r.StatusCode-eq204) 'Customer cancels pending unpaid order'
$r=Request "/api/orders/$id2/cancel" $customer POST;Check ($r.StatusCode-eq409) 'Repeat cancellation rejected'
$r=Request "/api/products/$($product.id)/reviews" $customer PUT '{"rating":5,"comment":"QA"}';Check ($r.StatusCode-eq403) 'Review before delivery rejected'
$csrf=Token '/admin/orders' $admin
$r=Request "/admin/orders/$id" $admin POST @{__RequestVerificationToken=$csrf;current='pending'};Check ($r.StatusCode-eq200) 'Admin confirms reconciled order'
$r=Request "/admin/orders/$id" $admin POST @{__RequestVerificationToken=$csrf;current='confirmed'};Check ($r.StatusCode-eq200) 'Admin starts shipping'
$r=Request "/api/orders/$id/received" $customer POST;Check ($r.StatusCode-eq204) 'Customer confirms received shipment'
$r=Request "/api/products/$($product.id)/reviews" $customer PUT '{"rating":5,"comment":"QA"}';Check ($r.StatusCode-eq204) 'Delivered buyer can review'
$r=Request "/api/products/$($product.id)/reviews" $customer PUT '{"rating":5,"comment":"QA repeat"}';Check ($r.StatusCode-eq409) 'Second review rejected'
$r=Request "/admin/orders/$id/details" $admin;Check ($r.StatusCode-eq200-and$r.Content-match'Chi tiết sản phẩm') 'Admin order details render'
$r=Request "/api/orders/$id" $guest;Check ($r.StatusCode-eq401) 'Order details protected from anonymous access'
$r=Request '/api/chat/history' $guest;Check ($r.StatusCode-eq200) 'Guest chat history supported'
$userId=(& sqlcmd -S 'MSI\SQLEXPRESS' -d $Database -E -C -h -1 -W -Q "SET NOCOUNT ON;SELECT Id FROM dbo.Users WHERE Email='$email'").Trim()|Where-Object {$_-match'^\d+$'}
$csrf=Token '/admin/users' $admin
$r=Request "/admin/users/$userId/role" $admin POST @{__RequestVerificationToken=$csrf;role='Staff'};Check ($r.StatusCode-eq200) 'Admin can assign Staff role'
$r=Request '/api/account/login' $customer POST (@{email=$email;password=$env:VEGGIE_TEST_PASSWORD}|ConvertTo-Json)
$r=Request '/admin/products' $customer;Check ($r.StatusCode-eq200) 'Staff can view products'
$staffToken=Token '/admin/products' $customer
$r=Request "/admin/products/$($product.id)" $customer POST @{__RequestVerificationToken=$staffToken;price='1';stock='1';active='true'};Check ($r.StatusCode-eq403) 'Staff cannot edit products'
$r=Request '/admin/users' $customer;Check ($r.StatusCode-ne200) 'Staff cannot manage users'
$r=Request '/admin/orders' $customer;Check ($r.StatusCode-ne200) 'Staff cannot manage orders'
$r=Request '/admin/contacts' $customer;Check ($r.StatusCode-eq200) 'Staff can manage contacts'
$csrf=Token '/admin/users' $admin
$r=Request "/admin/users/$userId/status" $admin POST @{__RequestVerificationToken=$csrf;active='false'};Check ($r.StatusCode-eq200) 'Admin can block test user'
$r=Request '/api/account/me' $customer;Check ($r.StatusCode-eq401) 'Blocked session invalidated'
}finally{
if($product){& sqlcmd -S 'MSI\SQLEXPRESS' -d $Database -E -C -b -Q "UPDATE dbo.Products SET Status=0 WHERE Id=$($product.id);"|Out-Null}
& sqlcmd -S 'MSI\SQLEXPRESS' -d $Database -E -C -b -Q "UPDATE dbo.Users SET Status=0,SecurityStamp=CONVERT(nvarchar(36),NEWID()) WHERE Email='$email';"|Out-Null
$results|Set-Content (Join-Path $PSScriptRoot '../docs/video-features-tests.txt')
}





