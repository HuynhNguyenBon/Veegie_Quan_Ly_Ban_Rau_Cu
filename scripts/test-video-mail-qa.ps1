$ErrorActionPreference='Stop';$base='http://127.0.0.1:5510';$s=[Microsoft.PowerShell.Commands.WebRequestSession]::new();$checks=[Collections.Generic.List[string]]::new()
function Check($ok,$name){if(!$ok){throw "FAIL $name"};$checks.Add("PASS $name");Write-Host "PASS $name"}
function Req($path,$method='GET',$body=$null,$form=$null){$a=@{Uri=$base+$path;WebSession=$s;Method=$method;SkipHttpErrorCheck=$true};if($body){$a.Body=$body;$a.ContentType='application/json'}if($form){$a.Form=$form};Invoke-WebRequest @a}
function Token($path){[regex]::Match((Req $path).Content,'name="__RequestVerificationToken"[^>]*value="([^"]+)"').Groups[1].Value}
$r=Req '/api/account/login' POST (@{email='admin@gmail.com';password=$env:VEGGIE_TEST_PASSWORD}|ConvertTo-Json);Check ($r.StatusCode-eq200) 'isolated QA login'
$csrf=Token '/admin/products';$photo=Get-Item (Join-Path $PSScriptRoot '../clients/img/product/1.png');$photo2=Get-Item (Join-Path $PSScriptRoot '../clients/img/product/2.png')
$r=Req '/admin/products/create' POST -form @{__RequestVerificationToken=$csrf;name='QA Multiple Photos';categoryId='1';price='12345';stock='5';unit='kg';description='QA original';photos=@($photo,$photo2)};Check ($r.StatusCode-eq200) 'multiple image create'
$p=((Req '/api/catalog').Content|ConvertFrom-Json).products|Where-Object name -eq 'QA Multiple Photos';$r=Req "/api/products/$($p.id)/images";Check (($r.Content|ConvertFrom-Json).Count-eq2) 'both uploaded images stored'
$csrf=Token '/admin/products';$r=Req "/admin/products/$($p.id)" POST -form @{__RequestVerificationToken=$csrf;name='QA Product Updated';categoryId='2';price='15000';stock='7';unit='hop';description='Updated description';active='true'};Check ($r.StatusCode-eq200) 'full product metadata update'
$p=((Req '/api/catalog').Content|ConvertFrom-Json).products|Where-Object name -eq 'QA Product Updated';Check ($p.description-eq'Updated description'-and$p.unit-eq'hop'-and$p.price-eq15000) 'store reflects metadata update'
$r=Req '/api/contacts' POST '{"name":"QA Sender","email":"qa-recipient@example.test","phone":"0900000000","message":"QA contact"}';Check ($r.StatusCode-eq204) 'contact stored'
$id=(& sqlcmd -S 'MSI\SQLEXPRESS' -d VeggieMailQA -E -C -h -1 -W -Q "SET NOCOUNT ON;SELECT MAX(Id) FROM dbo.Contacts").Trim()|Where-Object {$_-match'^\d+$'}
$csrf=Token '/admin/contacts';$r=Req "/admin/contacts/$id/reply" POST -form @{__RequestVerificationToken=$csrf;reply='QA reply from Veggie'};Check ($r.StatusCode-eq200) 'contact reply queued'
$r=Req "/admin/contacts/$id/reply" POST -form @{__RequestVerificationToken=$csrf;reply='QA duplicate reply'};Check ($r.StatusCode-eq200) 'duplicate reply handled'
$count=(& sqlcmd -S 'MSI\SQLEXPRESS' -d VeggieMailQA -E -C -h -1 -W -Q "SET NOCOUNT ON;SELECT COUNT(*) FROM dbo.StoreEmailQueue WHERE ToEmail='qa-recipient@example.test'").Trim()|Where-Object {$_-match'^\d+$'};Check ($count-eq1) 'only one reply email queued'
$order=@{name='QA Admin';phone='0900000000';address='QA local';city='Ha Noi';note='QA ONLY';requestId=[guid]::NewGuid();items=@(@{id=$p.id;quantity=1});paymentMethod='COD'}|ConvertTo-Json -Depth 5
$r=Req '/api/orders' POST $order;$id=($r.Content|ConvertFrom-Json).code.Substring(2);Check ($r.StatusCode-eq200) 'QA invoice order created'
$r=Req '/api/orders' POST $order;Check (($r.Content|ConvertFrom-Json).code-eq"VG$id") 'idempotent checkout'
$csrf=Token '/admin/orders';$r=Req "/admin/orders/$id" POST -form @{__RequestVerificationToken=$csrf;current='pending'};Check ($r.StatusCode-eq200) 'QA invoice order confirmed'
$csrf=Token "/admin/orders/$id/details";$r=Req "/admin/orders/$id/invoice" POST -form @{__RequestVerificationToken=$csrf};Check ($r.StatusCode-eq200) 'invoice queued'
$r=Req "/admin/orders/$id/invoice" POST -form @{__RequestVerificationToken=$csrf};Check ($r.StatusCode-eq200) 'invoice cooldown handled'
$count=(& sqlcmd -S 'MSI\SQLEXPRESS' -d VeggieMailQA -E -C -h -1 -W -Q "SET NOCOUNT ON;SELECT COUNT(*) FROM dbo.StoreEmailQueue WHERE Subject LIKE N'%VG$id %'").Trim()|Where-Object {$_-match'^\d+$'};Check ($count-eq1) 'invoice not duplicated'
$checks|Set-Content (Join-Path $PSScriptRoot '../docs/video-mail-qa-tests.txt')

