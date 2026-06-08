# Coding Guidelines – Quản Lý Hàng Tồn Kho

---

## 1. Quy Tắc Chung

- Giao diện hiển thị tiếng Việt
- Không thêm comment/tag liên quan AI
- PascalCase cho class, method, property. camelCase cho biến local. UPPER_CASE cho constants
- Tên entity tiếng Việt không dấu trong code C#: `SanPham`, `PhieuNhap`, `ChiTietPhieuNhap`
- Tên bảng SQL giữ nguyên tiếng Việt: `SanPham`, `PhieuNhap`, `CT_PhieuNhap`

---

## 2. C# / ASP.NET Core

### Controller
- 1 controller / 1 entity chính
- Inject service qua constructor
- Validate `ModelState.IsValid` trước mọi thao tác ghi
- Return `IActionResult`

### Service
- Interface + Implementation cho mỗi service
- Đăng ký DI trong `Program.cs`: `builder.Services.AddScoped<ISanPhamService, SanPhamService>()`
- Business logic nằm trong Service, Controller chỉ điều phối

### Model
- Data Annotations cho validation cơ bản
- Navigation properties cho quan hệ FK
- ErrorMessage bằng tiếng Việt

```csharp
public class SanPham
{
    public int MaSP { get; set; }

    [Required(ErrorMessage = "Tên sản phẩm không được để trống")]
    [StringLength(200)]
    public string TenSP { get; set; }

    [Required(ErrorMessage = "Vui lòng chọn danh mục")]
    public int MaDanhMuc { get; set; }
    public DanhMuc DanhMuc { get; set; }

    [Required(ErrorMessage = "Đơn vị tính không được để trống")]
    [StringLength(50)]
    public string DonVi { get; set; }

    [Range(0, double.MaxValue)]
    public decimal GiaNhap { get; set; }

    [Range(0, double.MaxValue)]
    public decimal GiaBan { get; set; }

    public int TonToiThieu { get; set; } = 10;
    public bool TrangThai { get; set; } = true;
    public DateTime NgayTao { get; set; } = DateTime.Now;
    public DateTime NgayCapNhat { get; set; } = DateTime.Now;

    public ICollection<ChiTietPhieuNhap> ChiTietPhieuNhaps { get; set; }
    public ICollection<ChiTietPhieuXuat> ChiTietPhieuXuats { get; set; }
    public ICollection<TonKho> TonKhos { get; set; }
}
```

### ViewModel
- Tạo riêng cho màn hình phức tạp (tạo phiếu, báo cáo, dashboard)
- Không expose entity trực tiếp ra View khi cần thêm data

---

## 3. Entity Framework Core

- Code-First, Fluent API cho quan hệ phức tạp trong `OnModelCreating`
- `AsNoTracking()` cho query chỉ đọc
- Transaction cho thao tác phiếu nhập/xuất

```csharp
using var transaction = await _context.Database.BeginTransactionAsync();
try
{
    _context.PhieuNhaps.Add(phieu);
    await _context.SaveChangesAsync();
    await transaction.CommitAsync();
}
catch
{
    await transaction.RollbackAsync();
    throw;
}
```

### Gọi Stored Procedure từ EF Core
```csharp
var result = await _context.Database
    .SqlQueryRaw<BaoCaoTonKhoResult>(
        "EXEC sp_BaoCaoTonKho @MaKho, @TuNgay, @DenNgay",
        new SqlParameter("@MaKho", maKho),
        new SqlParameter("@TuNgay", tuNgay),
        new SqlParameter("@DenNgay", denNgay))
    .ToListAsync();
```

### Gọi View từ EF Core
```csharp
// Đăng ký View như entity không có key
modelBuilder.Entity<TonKhoHienTaiView>().HasNoKey().ToView("v_TonKhoHienTai");

// Query
var tonKho = await _context.Set<TonKhoHienTaiView>().AsNoTracking().ToListAsync();
```

---

## 4. Frontend (Razor Views)

- **Layout:** `_Layout.cshtml` với sidebar trái, navbar trên
- **Partial Views:** `_Sidebar`, `_Navbar`, `_Pagination`
- **Bootstrap 5:** responsive, dark/light theme
- **DataTables:** bảng có search, sort, pagination client-side
- **Chart.js:** biểu đồ dashboard và báo cáo
- **SweetAlert2:** confirm dialog xóa/hủy phiếu
- **jQuery Validation Unobtrusive:** validation form client-side

### Trang demo B1-B5
```html
<!-- B1: Bài toán -->
<div class="card"><p>Mô tả bài toán...</p></div>
<!-- B2: Câu SQL -->
<pre><code class="sql">EXEC sp_TaoPhieuNhap ...</code></pre>
<!-- B3: Data trước -->
<table id="before-table">...</table>
<!-- B4: Nút thực thi -->
<button id="btn-execute">Thực thi</button>
<!-- B5: Data sau -->
<table id="after-table">...</table>
```

---

## 5. Docker

- Multi-stage build cho web Dockerfile
- Environment variables cho connection string: `ConnectionStrings__DefaultConnection`
- SQL Server health check trước khi start web
- SQL scripts chạy tuần tự 01→09 khi init

```yaml
services:
  sqlserver:
    healthcheck:
      test: /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $$SA_PASSWORD -C -Q "SELECT 1"
      interval: 10s
      retries: 10
  web:
    depends_on:
      sqlserver:
        condition: service_healthy
```

---

## 6. Quy Ước Commit

```
feat: thêm tính năng mới
fix: sửa lỗi
docs: cập nhật tài liệu
refactor: tái cấu trúc code
style: sửa format, không thay đổi logic
```
