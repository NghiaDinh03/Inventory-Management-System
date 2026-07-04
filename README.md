# Quản Lý Hàng Tồn Kho – Đồ Án Môn IE103

Đồ án môn học **Quản lý Thông tin (IE103)** – Trường Đại học Công nghệ Thông tin, ĐHQG TP.HCM.

Phân tích, thiết kế và triển khai hệ thống Quản lý Hàng tồn kho trên SQL Server, kèm Website demo tương tác trực tiếp database.

---

## Mô Tả Bài Toán

Hệ thống quản lý hàng tồn kho cho doanh nghiệp vừa và nhỏ:

- **Quản lý danh mục:** sản phẩm, nhà cung cấp, kho hàng, nhân viên
- **Nghiệp vụ nhập kho:** tạo phiếu nhập → thêm chi tiết → duyệt phiếu → cập nhật tồn
- **Nghiệp vụ xuất kho:** tạo phiếu xuất → kiểm tra tồn → duyệt → trừ tồn (ngăn xuất âm)
- **Kiểm kê:** tồn kho real-time, tồn đầu kỳ / nhập / xuất / tồn cuối kỳ
- **Báo cáo:** 5 loại báo cáo + biểu đồ xu hướng
- **Bảo mật:** đăng nhập, phân quyền, backup/restore, import/export

---

## Công Nghệ

| Thành phần | Công nghệ |
|-----------|-----------|
| Database | SQL Server 2022 |
| Backend + Frontend | ASP.NET Core 8 MVC |
| ORM | Entity Framework Core 8 |
| UI | Bootstrap 5, DataTables, Chart.js, SweetAlert2 |
| Container | Docker + Docker Compose |
| DB UI | DbGate |

---

## Chạy Dự Án

```bash
git clone <repo-url>
docker-compose up --build -d
```

| Dịch vụ | URL |
|---------|-----|
| Web App | http://localhost:8080 |
| DbGate | http://localhost:3000 |

Tài khoản mặc định đăng nhập Web:
- **Tài khoản:** `admin` / **Mật khẩu:** `Admin_password_2026`
- **Tài khoản:** `nvkho1` / **Mật khẩu:** `Nvkho_password_2026`

Thông tin kết nối Database trên DbGate (http://localhost:3000):
- **DBMS:** Microsoft SQL Server
- **Server/Host:** `sqlserver`
- **Port:** `1433`
- **User:** `sa`
- **Password:** `Sa_strong_password_2026`
- **Database:** `InventoryDB`

Thư mục lưu log debug (được mount ra máy host):
- `./logs/app.log` (Log của ứng dụng Web)
- `./logs/db_init.log` (Log của quá trình khởi tạo Database)

---

## Cấu Trúc

```
├── src/IMS.Web/          # ASP.NET Core MVC
│   ├── Controllers/      # 12 controllers
│   ├── Models/           # 12 entity models
│   ├── Services/         # Business logic layer
│   ├── Views/            # Razor views + layout
│   └── Data/             # EF Core DbContext
│
├── database/             # SQL Scripts (01→09, chạy tuần tự)
│   ├── 01_create-tables.sql
│   ├── 02_create-views.sql
│   ├── 03_create-functions.sql
│   ├── 04_create-stored-procedures.sql
│   ├── 05_create-triggers.sql
│   ├── 06_create-cursors.sql
│   ├── 07_seed-data.sql
│   ├── 08_create-users-roles.sql
│   └── 09_backup-restore.sql
│
├── docker/               # Dockerfile + init scripts
├── docker-compose.yml
└── README.md
```

---

## CSDL (27 bảng)

Hệ thống được thiết kế với 27 bảng hoàn chỉnh đáp ứng đầy đủ nghiệp vụ quản lý kho chuyên sâu:

| Nhóm | Các Bảng Chi Tiết |
|------|-------------------|
| **Người Dùng & Phân Quyền** | `VaiTro`, `TaiKhoan`, `NhanVien` |
| **Đối Tác & Danh Mục** | `NhaCungCap`, `KhachHang`, `DoiTacVanChuyen`, `DanhMuc`, `SanPham`, `NCC_SanPham` (Liên kết SP - NCC), `Gia` (Lịch sử giá nhập) |
| **Nghiệp Vụ Nhập/Xuất Kho** | `PhieuNhap`, `CT_PhieuNhap`, `PhieuXuat`, `CT_PhieuXuat`, `Voucher` |
| **Vận Hành & Điều Chuyển** | `TonKho`, `ChuyenKho`, `CT_ChuyenKho`, `TraHang`, `CT_TraHang`, `KiemKe`, `CT_KiemKe`, `NhanVien_Kho` |
| **Đơn Hàng & Nhật Ký** | `DonDatHang`, `CT_DonDatHang`, `LichSuHoatDong` |

---

## Xử Lý Thông Tin

| Loại | SL | Ví dụ |
|------|----|-------|
| Stored Procedure | 8 | sp_TaoPhieuNhap, sp_DuyetPhieu, sp_BaoCaoTonKho, sp_DoiMatKhau... |
| Trigger | 7 | Cập nhật tồn kho khi duyệt, chặn xuất âm, tự tạo số phiếu, chặn xóa SP đã dùng... |
| Function | 5 | Tính tồn kho, giá trị tồn, giá xuất bình quân, danh sách SP theo kho... |
| Cursor | 2 | Cảnh báo tồn thấp, tính tồn cuối kỳ |
| View | 9 | Tồn kho, chi tiết phiếu, doanh thu tháng, top SP xuất, dashboard... |

---

## Website Demo (Flow B1→B5)

Mỗi SP/Trigger/Function/Cursor demo theo:

1. **B1:** Trình bày bài toán
2. **B2:** Hiển thị câu SQL
3. **B3:** Dữ liệu trước khi thực thi
4. **B4:** Nút thực thi (tương tác trực tiếp SQL Server)
5. **B5:** Kết quả sau khi thực thi

---

## Thành Viên Nhóm 3

| MSSV | Họ tên | Phân công |
|------|--------|-----------|
| | | |
| | | |
| | | |

**Giảng viên hướng dẫn:**

---

## Nộp Bài

- `BaoCao_Nhom3.pdf` – 20-25 trang
- `Slides_Nhom3.pdf` – 15-20 slides
- `Video_Nhom3.txt` – link video demo 15-20 phút
- `Source.zip` – source code + SQL scripts
