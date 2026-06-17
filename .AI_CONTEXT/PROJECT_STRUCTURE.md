# Project Structure – Quản Lý Hàng Tồn Kho

---

## 1. Cấu Trúc Thư Mục

```text
Inventory-Management-System/
│
├── .AI_CONTEXT/                         # Ngữ cảnh và tài liệu hướng dẫn AI
│   ├── CODING_GUIDELINES.md             # Quy tắc coding
│   ├── DATABASE_DESIGN.md               # Thiết kế database chi tiết
│   ├── DEMO_GUIDE.md                    # Kịch bản demo hệ thống
│   ├── PROJECT_CONTEXT.md               # Bối cảnh & Nghiệp vụ cốt lõi
│   ├── PROJECT_STRUCTURE.md             # Cấu trúc thư mục này
│   ├── security_assessment.md           # Đánh giá bảo mật
│   ├── user_guide_and_operations.md     # Hướng dẫn vận hành
│   ├── TEST_REPORT.md                   # Báo cáo kiểm thử DOM & WMS
│   └── AI_SELECT/                       # Nhật ký tự trị AI
│       └── 17062026-AI.md
│
├── src/
│   └── IMS.Web/                         # ASP.NET Core 8 MVC
│       ├── Program.cs                   # Entry point, DI, middleware
│       ├── appsettings.json             # Connection string, config
│       ├── IMS.Web.csproj
│       │
│       ├── Data/
│       │   ├── AppDbContext.cs           # EF Core DbContext
│       │   └── Migrations/
│       │
│       ├── Models/                      # Entity Models
│       │   ├── SanPham.cs
│       │   ├── DanhMuc.cs
│       │   ├── NhaCungCap.cs
│       │   ├── Kho.cs
│       │   ├── NhanVien.cs
│       │   ├── TaiKhoan.cs
│       │   ├── PhieuNhap.cs
│       │   ├── ChiTietPhieuNhap.cs
│       │   ├── PhieuXuat.cs
│       │   ├── ChiTietPhieuXuat.cs
│       │   ├── TonKho.cs
│       │   └── LichSuHoatDong.cs
│       │
│       ├── ViewModels/
│       │   ├── DashboardViewModel.cs
│       │   ├── PhieuNhapViewModel.cs
│       │   ├── PhieuXuatViewModel.cs
│       │   ├── BaoCaoTonKhoViewModel.cs
│       │   ├── DemoViewModel.cs         # ViewModel cho trang demo B1-B5
│       │   └── LoginViewModel.cs
│       │
│       ├── Services/
│       │   ├── ISanPhamService.cs
│       │   ├── SanPhamService.cs
│       │   ├── IPhieuNhapService.cs
│       │   ├── PhieuNhapService.cs
│       │   ├── IPhieuXuatService.cs
│       │   ├── PhieuXuatService.cs
│       │   ├── ITonKhoService.cs
│       │   ├── TonKhoService.cs
│       │   ├── IBaoCaoService.cs
│       │   ├── BaoCaoService.cs
│       │   ├── ITaiKhoanService.cs
│       │   ├── TaiKhoanService.cs
│       │   └── SqlExecuteService.cs     # Thực thi raw SQL cho demo B1-B5
│       │
│       ├── Controllers/
│       │   ├── HomeController.cs        # Dashboard
│       │   ├── SanPhamController.cs
│       │   ├── DanhMucController.cs
│       │   ├── NhaCungCapController.cs
│       │   ├── KhoController.cs
│       │   ├── PhieuNhapController.cs
│       │   ├── PhieuXuatController.cs
│       │   ├── TonKhoController.cs
│       │   ├── BaoCaoController.cs
│       │   ├── TaiKhoanController.cs
│       │   ├── DemoController.cs        # Trang demo SP/Trigger/Function/Cursor
│       │   └── HeThongController.cs     # Backup/Restore/Import/Export
│       │
│       ├── Views/
│       │   ├── Shared/
│       │   │   ├── _Layout.cshtml       # Layout chính với sidebar
│       │   │   ├── _Sidebar.cshtml
│       │   │   ├── _Navbar.cshtml
│       │   │   ├── _Pagination.cshtml
│       │   │   └── _ValidationScripts.cshtml
│       │   ├── Home/
│       │   │   └── Index.cshtml         # Dashboard: chart, thống kê, cảnh báo
│       │   ├── SanPham/
│       │   │   ├── Index.cshtml         # Danh sách + tìm kiếm
│       │   │   ├── Create.cshtml
│       │   │   └── Edit.cshtml
│       │   ├── DanhMuc/
│       │   ├── NhaCungCap/
│       │   ├── Kho/
│       │   ├── PhieuNhap/
│       │   │   ├── Index.cshtml         # Danh sách phiếu
│       │   │   ├── Create.cshtml        # Tạo phiếu + thêm chi tiết
│       │   │   └── Details.cshtml       # Xem chi tiết + duyệt/hủy
│       │   ├── PhieuXuat/
│       │   ├── TonKho/
│       │   │   └── Index.cshtml         # Bảng tồn kho + filter
│       │   ├── BaoCao/
│       │   │   ├── TonKho.cshtml        # BC tồn kho theo kho + thời gian
│       │   │   ├── NhapTheoNCC.cshtml
│       │   │   ├── XuatTheoSP.cshtml
│       │   │   ├── CanhBaoTon.cshtml
│       │   │   └── XuHuong.cshtml       # Biểu đồ xu hướng
│       │   ├── TaiKhoan/
│       │   │   ├── Login.cshtml
│       │   │   └── DoiMatKhau.cshtml
│       │   ├── Demo/
│       │   │   ├── Index.cshtml         # Menu demo
│       │   │   └── Execute.cshtml       # Trang B1-B5: hiển thị SQL + thực thi
│       │   └── HeThong/
│       │       ├── Backup.cshtml
│       │       └── ImportExport.cshtml
│       │
│       └── wwwroot/
│           ├── css/
│           │   └── site.css
│           ├── js/
│           │   ├── site.js
│           │   ├── dashboard-chart.js
│           │   └── phieu-detail.js      # Dynamic thêm/xóa dòng chi tiết
│           ├── lib/                     # Bootstrap, jQuery, DataTables, Chart.js
│           └── images/
│
├── database/                            # SQL Scripts (chạy khi init container)
│   ├── 01_create-tables.sql            # CREATE TABLE + constraints
│   ├── 02_create-views.sql             # CREATE VIEW
│   ├── 03_create-functions.sql         # CREATE FUNCTION
│   ├── 04_create-stored-procedures.sql # CREATE PROCEDURE
│   ├── 05_create-triggers.sql          # CREATE TRIGGER
│   ├── 06_create-cursors.sql           # Cursor scripts (wrapped in SP)
│   ├── 07_seed-data.sql                # Dữ liệu mẫu 10-20 dòng/bảng
│   ├── 08_create-users-roles.sql       # SQL Server User + Role + GRANT
│   └── 09_backup-restore.sql           # Script backup/restore demo
│
├── docker/
│   ├── web.Dockerfile                   # Multi-stage build ASP.NET Core
│   └── sqlserver-init/
│       └── init.sh                      # Chạy tuần tự 01→09 SQL scripts
│
├── docker-compose.yml
├── .dockerignore
├── .gitignore
└── README.md
```

---

## 2. Docker Compose Services

| Service | Image | Port | Mô tả |
|---------|-------|------|-------|
| `web` | Build từ `docker/web.Dockerfile` | 8080 | ASP.NET Core MVC |
| `sqlserver` | `mcr.microsoft.com/mssql/server:2022-latest` | 1433 | SQL Server |
| `dbgate` | `dbgate/dbgate` | 3000 | Web UI quản lý DB |

**Thứ tự khởi động:** `sqlserver` (healthy) → `init scripts 01-09` → `web` → `dbgate`

---

## 3. Luồng Xử Lý

```text
Browser → Controller → Service → EF Core / Raw SQL → SQL Server
              ↓                                          ↑
         ViewModel                              Trigger tự fire
              ↓                               (cập nhật TonKho)
         Razor View
              ↓
          Browser
```

### Trang quản lý: dùng EF Core qua Service layer
### Trang demo B1-B5: dùng `SqlExecuteService` chạy raw SQL trực tiếp

---

## 4. Quy Tắc Đặt Tên File SQL

| File | Nội dung |
|------|----------|
| `01_create-tables.sql` | Tạo bảng theo đúng thứ tự dependency |
| `02_create-views.sql` | Tạo view (phụ thuộc bảng) |
| `03_create-functions.sql` | Tạo function (phụ thuộc bảng + view) |
| `04_create-stored-procedures.sql` | Tạo SP (phụ thuộc bảng + function) |
| `05_create-triggers.sql` | Tạo trigger (phụ thuộc bảng) |
| `06_create-cursors.sql` | Cursor scripts (wrapped trong SP) |
| `07_seed-data.sql` | INSERT dữ liệu mẫu |
| `08_create-users-roles.sql` | Tạo user/role SQL Server |
| `09_backup-restore.sql` | Script demo backup/restore |

Đánh số đảm bảo chạy tuần tự không lỗi dependency.
