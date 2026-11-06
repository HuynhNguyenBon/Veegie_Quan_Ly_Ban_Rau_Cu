# Database SQL Server của Veggie

Database First: các bảng được tạo từ SQL, DbContext/Entities ánh xạ schema. Không dùng EF migrations để tự tạo một schema khác.

Cài mới hoặc cập nhật theo thứ tự:
1. 001_schema.sql — schema nghiệp vụ.
2. 002_seed.sql — vai trò, danh mục, 181 sản phẩm.
3. 003_profile_cover.sql — ảnh bìa hồ sơ.
4. 004_momo.sql — thông tin tham chiếu cổng thanh toán (tích hợp tùy chọn).
5. 005_account_security.sql — trạng thái xác minh email, dấu bảo mật phiên, token email dùng một lần.
6. 006_store_messages.sql — đăng ký bản tin và hàng đợi gửi lời nhắn/báo giá tới cửa hàng.

Có thể dùng scripts/Initialize-Database.ps1. Không chạy csdl_veggie.sql cùng bộ script này trên database đã có; đây là bản SQL trình bày ban đầu.

Token thô không lưu trong SQL: chỉ lưu SHA-256, thời gian hết hạn và thời điểm sử dụng. Tài khoản cũ được giữ EmailConfirmed=1 khi nâng cấp, tài khoản đăng ký mới bắt đầu ở 0. SecurityStamp thay đổi khi đặt lại mật khẩu; middleware cũng kiểm tra tài khoản bị khóa và thay vai trò.

Kết nối trên máy MSI là MSI\SQLEXPRESS; máy khác phải đặt ConnectionStrings:Veggie trong User Secrets. Xem docs/cai-dat.md để chạy trên máy khác và cấu hình gửi email.
