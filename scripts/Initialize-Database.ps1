param([string]$Server='.\SQLEXPRESS')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot
if(!(Get-Command sqlcmd -ErrorAction SilentlyContinue)){throw 'Cần cài sqlcmd hoặc chạy các file SQL trong SSMS theo README.'}
foreach($file in @('001_schema.sql','002_seed.sql','003_profile_cover.sql','004_momo.sql','005_account_security.sql','006_store_messages.sql','007_bank_payment_verification.sql','008_video_features.sql','009_user_archive.sql','010_promotions_loyalty.sql','011_catalog_expansion.sql')){
    & sqlcmd -S $Server -E -C -b -f 65001 -i (Join-Path $root "database/$file")
    if($LASTEXITCODE -ne 0){throw "Không chạy được $file. Dừng để tránh bỏ qua lỗi."}
}
'Đã tạo/cập nhật database Veggie.'

