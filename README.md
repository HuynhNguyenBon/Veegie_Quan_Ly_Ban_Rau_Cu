# Veggie — Website bán rau củ

Veggie gồm cửa hàng dành cho khách và trang quản trị dành cho Admin, Nhân viên. Dự án dùng ASP.NET Core MVC (.NET 10), Entity Framework Core Database First, SQL Server và HTML/CSS/JavaScript.

## Chức năng

- **Khách hàng** — Tìm và lọc sản phẩm, quản lý giỏ hàng và yêu thích, đặt hàng COD hoặc chuyển khoản QR, theo dõi đơn và đánh giá sau khi nhận hàng.
- **Tài khoản** — Đăng ký, xác minh email, đặt lại mật khẩu, chỉnh sửa hồ sơ và quản lý địa chỉ giao hàng.
- **Quản trị** — Quản lý người dùng, danh mục, sản phẩm, đơn hàng, liên hệ và thông báo. Admin đối chiếu sao kê trước khi xác nhận chuyển khoản.
- **Hỗ trợ mua hàng** — Chatbot dùng Gemini khi có cấu hình và có thể trả lời từ dữ liệu cửa hàng.

## Cài đặt trên Windows

Cần .NET SDK 10, SQL Server Express hoặc Developer và SSMS. Có thể mở dự án bằng Veggie.sln trong Visual Studio hoặc mở thư mục gốc trong VS Code.

1. Kết nối SQL Server trong SSMS. Chạy lần lượt các script sau để tạo cơ sở dữ liệu Veggie và nạp dữ liệu mẫu.

   | Thứ tự | Script |
   |---|---|
   | 1 | [001_schema.sql](database/001_schema.sql) |
   | 2 | [002_seed.sql](database/002_seed.sql) |
   | 3 | [003_profile_cover.sql](database/003_profile_cover.sql) |
   | 4 | [004_momo.sql](database/004_momo.sql) |
   | 5 | [005_account_security.sql](database/005_account_security.sql) |
   | 6 | [006_store_messages.sql](database/006_store_messages.sql) |
   | 7 | [007_bank_payment_verification.sql](database/007_bank_payment_verification.sql) |
   | 8 | [008_video_features.sql](database/008_video_features.sql) |

   Nếu đã có sqlcmd, có thể chạy scripts/Initialize-Database.ps1 với tham số -Server trỏ tới instance SQL Server của bạn. File csdl_veggie.sql là bản schema tham khảo.

2. Từ thư mục gốc, cấu hình kết nối cho máy của bạn. Đổi .\SQLEXPRESS nếu tên instance khác.

   ~~~powershell
   dotnet user-secrets set "ConnectionStrings:Veggie" 'Server=.\SQLEXPRESS;Database=Veggie;Integrated Security=True;TrustServerCertificate=True' --project backend/Veggie.Api
   ~~~

3. Khởi động ứng dụng.

   ~~~powershell
   dotnet run --project backend/Veggie.Api --no-launch-profile --urls http://127.0.0.1:5500
   ~~~

   Có thể chạy bằng Mo-Veggie.cmd. Giữ cửa sổ chạy ứng dụng mở trong lúc sử dụng web.

   - [Cửa hàng](http://127.0.0.1:5500/clients/index.html)
   - [Quản trị](http://127.0.0.1:5500/admin/dashboard) — yêu cầu tài khoản được cấp quyền.
   - [API danh mục](http://127.0.0.1:5500/api/catalog) — kiểm tra dữ liệu trả về từ SQL Server.

### Cấu hình dịch vụ

- **Email** — Đặt Email:Host, Email:Port, Email:From, Email:Username, Email:Password và Email:PublicUrl trong User Secrets. Khi chạy cục bộ, Email:PublicUrl là http://127.0.0.1:5500. Cấu hình này phục vụ xác minh email, đặt lại mật khẩu, phản hồi liên hệ và gửi hóa đơn.
- **Gemini** — Gemini:ApiKey và Gemini:Model là cấu hình tùy chọn. Lưu khóa ở backend.
- **Admin đầu tiên** — Đăng ký, xác minh một tài khoản của nhóm, sau đó người quản trị SQL gán vai trò Admin cho đúng tài khoản đó. Đăng nhập lại để nhận quyền.

## Cấu trúc và phân công

| Thành viên | Phần phụ trách | Vị trí |
|---|---|---|
| Tú | Giao diện cửa hàng | clients/ |
| Bổn | Giao diện quản trị | admin/ và backend/Veggie.Api/Views/ |
| Bảo | ASP.NET, API, dịch vụ và DbContext | backend/ ngoài thư mục Views đã giao cho Bổn |
| Quy | Schema, dữ liệu mẫu và khởi tạo SQL | database/ và scripts/Initialize-Database.ps1 |
| Đạt | Tích hợp, kiểm tra và triển khai | Các script còn lại, README, Veggie.sln và cấu hình ở gốc repo |

Cả nhóm dùng chung một repo. Mỗi người tạo nhánh cho phần phụ trách, commit đúng phạm vi và mở Pull Request vào main. Giữ admin/, backend/ và clients/ ngang cấp để dự án đóng gói được tài nguyên giao diện.

Đưa lên GitHub năm thư mục admin/, backend/, clients/, database/, scripts/ cùng các file gốc .gitignore, README.md, Veggie.sln, package.json và Mo-Veggie.cmd. Bỏ qua docs/, .vscode/, .vs/, node_modules/, bin/, obj/, uploads/, email-preview/ và template-audit.json. Giữ mật khẩu, API key và dữ liệu khách hàng ngoài repo.

## Kiểm tra

~~~powershell
dotnet build backend/Veggie.Api
npm run check:all
~~~

Lệnh npm cần Node.js và kiểm tra liên kết, tài nguyên, danh mục, bộ lọc, giỏ hàng và các thành phần giao diện. Để kiểm tra với SQL Server, chạy ứng dụng ASP.NET và thử đặt đơn, xử lý đơn trong Admin, sau đó xem lại trạng thái ở tài khoản khách.

## Triển khai

Railway có thể build và chạy Veggie bằng Dockerfile .NET 10 đặt ở gốc repo. Chuẩn bị SQL Server mà Railway truy cập được và chạy các script SQL theo thứ tự trên. Cấu hình ConnectionStrings__Veggie trong biến môi trường của Railway, cho ASP.NET lắng nghe trên 0.0.0.0 và cổng PORT, rồi tạo domain cho service.

URL Railway phục vụ cả cửa hàng và Admin. Vercel là tùy chọn để chuyển tiếp URL sang Railway bằng external rewrite. Khi triển khai, cập nhật Email__PublicUrl theo URL truy cập chính thức và kiểm tra khả năng gửi SMTP của môi trường chạy.

- [Dockerfile trên Railway](https://docs.railway.com/builds/dockerfiles)
- [Tạo domain trên Railway](https://docs.railway.com/networking/public-networking)
- [Chuyển tiếp URL trên Vercel](https://vercel.com/docs/routing/rewrites)
