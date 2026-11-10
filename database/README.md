# Cơ sở dữ liệu SQL Server của Veggie

Veggie dùng Database First. Các script SQL tạo và cập nhật cấu trúc bảng. Entity Framework Core ánh xạ các bảng đó qua `VeggieDbContext`.

## Cài database mới

Mở SQL Server Management Studio (SSMS), kết nối tới SQL Server và chạy các file theo thứ tự dưới đây.

| Thứ tự | Script | Nội dung |
| --- | --- | --- |
| 1 | [001_schema.sql](001_schema.sql) | Tạo database và các bảng nghiệp vụ. |
| 2 | [002_seed.sql](002_seed.sql) | Nạp vai trò, danh mục và 181 sản phẩm ban đầu. |
| 3 | [003_profile_cover.sql](003_profile_cover.sql) | Thêm ảnh bìa hồ sơ. |
| 4 | [004_momo.sql](004_momo.sql) | Bổ sung dữ liệu tham chiếu cho tích hợp MoMo. |
| 5 | [005_account_security.sql](005_account_security.sql) | Bổ sung xác minh email, dấu bảo mật phiên và token tài khoản. |
| 6 | [006_store_messages.sql](006_store_messages.sql) | Lưu đăng ký bản tin và hàng đợi gửi email. |
| 7 | [007_bank_payment_verification.sql](007_bank_payment_verification.sql) | Thêm chỉ mục duy nhất hỗ trợ đối soát giao dịch ngân hàng. |
| 8 | [008_video_features.sql](008_video_features.sql) | Thêm mã giao dịch ngân hàng riêng và bảng lưu tin nhắn chatbot. |
| 9 | [009_user_archive.sql](009_user_archive.sql) | Thêm cột `Users.DeletedAt` cho chức năng Xóa và Khôi phục tài khoản. |

Nếu dùng SQL Server Express với xác thực Windows và đã có `sqlcmd`, chạy lệnh sau trong PowerShell tại thư mục gốc của repo.

```powershell
.\scripts\Initialize-Database.ps1 -Server '.\SQLEXPRESS'
```

Đổi `-Server` theo tên instance thực tế. [Xem script cài đặt](../scripts/Initialize-Database.ps1)

## Nâng cấp database đang dùng

Chạy các script còn thiếu theo thứ tự. Nếu đã chạy đến `008_video_features.sql`, chỉ cần chạy `009_user_archive.sql` trên **SQL Server mà Veggie đang kết nối**, rồi khởi động phiên bản web mới. Script 009 kiểm tra cột đã tồn tại trước khi thêm. Khi Admin xóa tài khoản, ứng dụng ghi `DeletedAt` và vô hiệu hóa đăng nhập. Lịch sử đơn hàng vẫn được giữ.

`csdl_veggie.sql` là bản SQL tham khảo ban đầu. Các file `truy_van_veggie.sql` và `kiem_tra_don_hang.sql` dùng để tra cứu và kiểm tra dữ liệu.

## Kết nối ứng dụng

Khi chạy bằng Visual Studio, đặt `ConnectionStrings:Veggie` trong User Secrets của dự án `Veggie.Api`. Khi chạy bằng Docker, đặt biến môi trường `ConnectionStrings__Veggie` cho container web. [Xem hướng dẫn chạy Veggie](../README.md)
