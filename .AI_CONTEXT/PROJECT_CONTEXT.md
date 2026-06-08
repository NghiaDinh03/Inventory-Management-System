# Project Context – Quản Lý Hàng Tồn Kho

Đồ án **IE103 – Quản lý Thông tin**, ĐH Công nghệ Thông tin – ĐHQG TP.HCM.
Nhóm 3 – Đề tài: Quản lý Hàng tồn kho.

---

## 1. Bài Toán

Xây dựng hệ thống quản lý hàng tồn kho cho doanh nghiệp vừa và nhỏ.
Hệ thống bao gồm CSDL trên SQL Server và Website demo tương tác trực tiếp database.

### Đối tượng sử dụng
- **Admin:** toàn quyền hệ thống, phân quyền, báo cáo, backup/restore
- **Nhân viên kho:** tạo phiếu nhập/xuất, kiểm kê tồn kho

### Quy trình nghiệp vụ

**Nhập kho:**
1. NV kho tạo phiếu nhập (trạng thái Nháp), chọn NCC, kho
2. Thêm chi tiết: sản phẩm, số lượng, đơn giá
3. Duyệt phiếu → trigger cập nhật tồn kho

**Xuất kho:**
1. NV kho tạo phiếu xuất (trạng thái Nháp), chọn kho xuất
2. Thêm chi tiết: sản phẩm, số lượng
3. Duyệt phiếu → trigger kiểm tra tồn, nếu đủ → trừ tồn, nếu không → chặn

**Kiểm kê:**
1. Xem tồn kho hiện tại qua view `v_TonKhoHienTai`
2. Báo cáo theo kho + khoảng thời gian: tồn đầu, nhập, xuất, tồn cuối

---

## 2. Yêu Cầu Đề Bài

| Hạng mục | Tối thiểu | Trạng thái |
|----------|-----------|------------|
| Stored Procedure | 5 | 8 SP đã thiết kế |
| Trigger | 5 | 7 trigger đã thiết kế |
| Function | 3 | 5 function đã thiết kế |
| Cursor | 2 | 2 cursor đã thiết kế |
| View | (không giới hạn) | 9 view đã thiết kế |
| Report | 5 | 5 report đã thiết kế |

### An toàn thông tin
- Xác thực đăng nhập (hash mật khẩu)
- Phân quyền role-based (Admin, NVKho)
- Import / Export dữ liệu
- Backup / Restore database

### Website Demo
- Mỗi chức năng trình bày theo flow B1→B5
- Bắt buộc tương tác trực tiếp SQL Server, không cache dữ liệu sẵn

---

## 3. Công Nghệ

| Thành phần | Công nghệ |
|-----------|-----------|
| CSDL | SQL Server 2022 (bắt buộc) |
| Backend + Frontend | ASP.NET Core 8 MVC |
| ORM | Entity Framework Core 8 |
| UI Framework | Bootstrap 5, DataTables, Chart.js, SweetAlert2 |
| Reports | Chart.js (visualize trên web, load từ DB) |
| Container | Docker + Docker Compose |
| DB UI | DbGate |

---

## 4. Nguyên Tắc Thiết Kế Quan Trọng

### Trigger chỉ fire khi phiếu được duyệt
Phiếu nhập/xuất có lifecycle: `Nháp → ĐãDuyệt → ĐãHủy`.
Trigger cập nhật tồn kho chỉ chạy trên chi tiết phiếu có `TrangThai = N'ĐãDuyệt'`.
SP `sp_DuyetPhieu` là nơi duy nhất chuyển trạng thái → kích hoạt trigger.

### SP không trực tiếp cập nhật tồn
SP chỉ INSERT/UPDATE dữ liệu phiếu + chi tiết.
Trigger AFTER INSERT trên CT_PhieuNhap/CT_PhieuXuat tự động cập nhật bảng TonKho.
Tránh double-update giữa SP và Trigger.

### Audit trail bắt buộc
Mọi thay đổi trên SanPham, PhieuNhap, PhieuXuat đều ghi vào bảng `LichSuHoatDong`.

---

## 5. Nộp Bài

- `BaoCao_Nhom3.pdf` – 20-25 trang
- `Slides_Nhom3.pdf` – 15-20 slides
- `Video_Nhom3.txt` – link video demo 15-20 phút
- `Source.zip` – source code + SQL scripts
