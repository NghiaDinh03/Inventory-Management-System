# Báo Cáo Đánh Giá An Toàn Thông Tin (Security Assessment Report)
### Dự án: Hệ Thống Quản Lý Hàng Tồn Kho (IMS Antigravity)

Tài liệu này đánh giá hiện trạng an ninh mạng, kiến trúc bảo mật của ứng dụng Web ASP.NET Core 8 MVC và Cơ sở dữ liệu SQL Server 2022. Báo cáo đưa ra các phát hiện lỗi bảo mật tĩnh (Static Application Security Testing - SAST), đánh giá rủi ro và khuyến nghị khắc phục chuẩn bị cho Go-Live.

---

## 1. Tóm Tắt Chung (Executive Summary)

Hệ thống có nền tảng bảo mật tương đối tốt nhờ việc áp dụng các công nghệ hiện đại:
*   **Data Access Layer**: Sử dụng Entity Framework Core 8 cho hầu hết các tác vụ CRUD, tự động tham số hóa các câu lệnh SQL để chống lỗi **SQL Injection (SQLi)**.
*   **Stored Procedures**: Các hàm gọi thủ tục lưu trữ phức tạp hoặc gọi Cursor trong `BaoCaoService` sử dụng ADO.NET `SqlParameter` tường minh, triệt tiêu nguy cơ SQLi.
*   **Authentication & Authorization**: Áp dụng Cookie Authentication chuẩn của ASP.NET Core, kết hợp kiểm soát quyền truy cập theo vai trò (Role-based Authorization: `Admin`, `NVKho`) cả ở lớp Web (C# Controller `[Authorize]`) và lớp Database (SQL Role `db_ims_admin`, `db_ims_nvkho`).

Tuy nhiên, có một số phát hiện quan trọng liên quan đến các tính năng thử nghiệm và cơ chế băm mật khẩu cần được xử lý trước khi đưa hệ thống lên môi trường Product.

---

## 2. Các Phát Hiện Bảo Mật Quan Trọng & Biện Pháp Khắc Phục

### Phát hiện 1: Tính Năng Thực Thi SQL Tự Do (Arbitrary SQL Execution) - MỨC ĐỘ: NGUY HIỂM (CRITICAL)
*   **Vị trí**: `SqlExecuteService.cs` và `DemoController.cs`.
*   **Mô tả**: Để phục vụ cho việc trình diễn luồng nghiệp vụ B1-B5 của đồ án, hệ thống cung cấp trang Demo cho phép người dùng nhập trực tiếp câu lệnh SQL và gửi lên server chạy raw qua phương thức `ExecuteQueryAsync`. 
*   **Rủi ro**: Bất kỳ người dùng nào đã đăng nhập (kể cả tài khoản `NVKho` với đặc quyền thấp) đều có thể truy cập trang này để thực thi các lệnh phá hoại như `DROP TABLE`, `TRUNCATE TABLE`, đọc dữ liệu nhạy cảm hoặc chiếm quyền quản trị DB.
*   **Biện pháp khắc phục**:
    1.  **Chỉ bật trong môi trường Development**: Bao bọc `DemoController` trong chỉ thị biên dịch phát triển `#if DEBUG` hoặc kiểm tra cấu hình môi trường:
        ```csharp
        if (!_env.IsDevelopment()) { return NotFound(); }
        ```
    2.  **Giới hạn quyền truy cập**: Áp dụng `[Authorize(Roles = "Admin")]` cho `DemoController` để chỉ quản trị viên tối cao mới được quyền chạy thử nghiệm.

### Phát hiện 2: Cơ Chế Băm Mật Khẩu Không Sử Dụng Salt (Unsalted Password Hashing) - MỨC ĐỘ: TRUNG BÌNH (MEDIUM)
*   **Vị trí**: `TaiKhoanService.cs` và `07_seed-data.sql`.
*   **Mô tả**: Mật khẩu được băm một chiều bằng thuật toán `SHA-256` nhưng **không sử dụng Salt** (chuỗi ngẫu nhiên duy nhất cho mỗi tài khoản).
*   **Rủi ro**: Nếu kẻ tấn công đánh cắp được cơ sở dữ liệu, họ có thể sử dụng các bảng tra cứu băm sẵn (Rainbow Tables) để giải mã nhanh chóng các mật khẩu thông dụng. Nếu hai người dùng đặt mật khẩu giống nhau, mã hash của họ trong DB cũng giống hệt nhau.
*   **Biện pháp khắc phục**:
    1.  Nâng cấp thuật toán băm mật khẩu bằng các thư viện tiêu chuẩn như `BCrypt.Net` hoặc `Microsoft.AspNetCore.Identity.IPasswordHasher`.
    2.  Nếu tự triển khai SHA-256, hãy tạo một cột `Salt` (chuỗi ngẫu nhiên 32 ký tự) trong bảng `TaiKhoan`, ghép `Mật_khẩu + Salt` trước khi băm và lưu trữ.

### Phát hiện 3: Thiếu ValidateAntiForgeryToken ở Một Số API/Action - MỨC ĐỘ: THẤP (LOW)
*   **Vị trí**: Các POST endpoints trong các CRUD Controller (`SanPhamController`, `DanhMucController`, `KhoController`...).
*   **Mô tả**: Trang Đăng nhập (`TaiKhoanController`) có thuộc tính `[ValidateAntiForgeryToken]` bảo vệ chống tấn công giả mạo yêu cầu từ chéo trang (CSRF), nhưng một số form chỉnh sửa danh mục hoặc tạo phiếu nghiệp vụ chưa được khai báo rõ thuộc tính này trên C# Action.
*   **Rủi ro**: Kẻ tấn công có thể lừa người dùng đã đăng nhập nhấn vào liên kết độc hại để tạo/xóa sản phẩm ngoài ý muốn.
*   **Biện pháp khắc phục**:
    *   Thêm thẻ `[ValidateAntiForgeryToken]` lên tất cả các Action xử lý HTTP POST trong toàn bộ hệ thống.
    *   Đảm bảo các View chứa form đều có `@Html.AntiForgeryToken()` (mặc định thẻ form của ASP.NET Core Tag Helper tự động chèn).

### Phát hiện 4: Cấu Hình Cookie & Session Chưa Đạt Chuẩn Hardening - MỨC ĐỘ: THẤP (LOW)
*   **Vị trí**: `Program.cs`.
*   **Mô tả**: Cấu hình Cookie Authentication và Session chưa chỉ định các thuộc tính bảo mật nâng cao như Secure (chỉ truyền qua HTTPS) và SameSite.
*   **Biện pháp khắc phục**:
    *   Cập nhật cấu hình Cookie trong `Program.cs`:
        ```csharp
        builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
            .AddCookie(options =>
            {
                options.Cookie.HttpOnly = true;
                options.Cookie.SecurePolicy = CookieSecurePolicy.Always; // Chỉ truyền qua HTTPS
                options.Cookie.SameSite = SameSiteMode.Lax;
                // ...
            });
        ```

---

## 3. Các Cơ Chế Phòng Thủ Hiện Có (Security Controls)

Hệ thống đã được thiết kế sẵn các lớp phòng thủ chủ động:
1.  **Ngăn Chặn Xuất Âm (Database Triggers)**: Trigger `trg_PhieuXuat_Duyet` tự động kiểm tra số lượng tồn kho của từng mặt hàng trước khi cho phép duyệt phiếu xuất. Nếu số lượng xuất vượt quá số lượng hiện có trong kho, giao dịch sẽ bị cuộn ngược (`ROLLBACK TRANSACTION`) kèm thông báo lỗi tiếng Việt trực quan.
2.  **Khóa Phân Quyền SQL Server**:
    *   Tài khoản Web sử dụng login quản trị mức thấp hoặc ứng dụng dùng SP.
    *   Đã tạo sẵn Login và Role phân quyền cụ thể trong Database: `ims_nvkho_login` chỉ có quyền thực thi (`EXECUTE`) các Stored Procedure được chỉ định (`sp_TaoPhieuNhap`, `sp_BaoCaoTonKho`,...) và bị từ chối thẳng (`DENY`) các quyền tương tác trực tiếp dữ liệu (`INSERT`, `UPDATE`, `DELETE`) trên các bảng cốt lõi như `TonKho`, `PhieuNhap`.
3.  **Audit Log tự động**: Bảng `LichSuHoatDong` ghi nhận lại toàn bộ thay đổi dữ liệu của các bảng quan trọng (Hành động, Nội dung cũ dưới dạng JSON, Nội dung mới dưới dạng JSON, Mã nhân viên thực hiện và Thời gian).

---

## 4. Định Dạng Lưu Trữ Tệp Báo Cáo Bảo Mật

*   **Tên tệp**: `security_assessment.md`
*   **Định dạng**: Markdown (.md) chuẩn GitHub.
*   **Thư mục lưu trữ**: Thư mục tài liệu thiết kế `.AI_CONTEXT/` tại gốc dự án (`e:\VSC\Inventory-Management-System\.AI_CONTEXT/security_assessment.md`).
