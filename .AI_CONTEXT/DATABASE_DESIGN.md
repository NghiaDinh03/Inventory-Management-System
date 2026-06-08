# Database Design – Quản Lý Hàng Tồn Kho

SQL Server 2022. Tên database: `InventoryDB`.

---

## 1. Bảng Dữ Liệu

### DanhMuc
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaDanhMuc | INT | PK, IDENTITY(1,1) | |
| TenDanhMuc | NVARCHAR(100) | NOT NULL, UNIQUE | |
| MoTa | NVARCHAR(300) | NULL | |

### NhaCungCap
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaNCC | INT | PK, IDENTITY(1,1) | |
| TenNCC | NVARCHAR(200) | NOT NULL | |
| DiaChi | NVARCHAR(300) | NULL | |
| SoDienThoai | VARCHAR(20) | NULL | |
| Email | VARCHAR(100) | NULL | |
| NguoiLienHe | NVARCHAR(100) | NULL | |
| TrangThai | BIT | DEFAULT 1 | Đang hợp tác |

### Kho
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaKho | INT | PK, IDENTITY(1,1) | |
| TenKho | NVARCHAR(100) | NOT NULL | |
| DiaChi | NVARCHAR(300) | NULL | |
| TrangThai | BIT | DEFAULT 1 | Đang hoạt động |

### SanPham
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaSP | INT | PK, IDENTITY(1,1) | |
| TenSP | NVARCHAR(200) | NOT NULL | |
| MaDanhMuc | INT | FK → DanhMuc | |
| DonVi | NVARCHAR(50) | NOT NULL | cái, kg, hộp, thùng... |
| MaVach | VARCHAR(50) | UNIQUE, NULL | |
| GiaNhap | DECIMAL(18,2) | CHECK >= 0 | Giá nhập tham khảo |
| GiaBan | DECIMAL(18,2) | CHECK >= 0 | Giá bán tham khảo |
| TonToiThieu | INT | DEFAULT 10 | Mức cảnh báo |
| HinhAnh | NVARCHAR(500) | NULL | Đường dẫn ảnh |
| MoTa | NVARCHAR(500) | NULL | |
| TrangThai | BIT | DEFAULT 1 | Đang kinh doanh |
| NgayTao | DATETIME | DEFAULT GETDATE() | |
| NgayCapNhat | DATETIME | DEFAULT GETDATE() | |

### NhanVien
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaNV | INT | PK, IDENTITY(1,1) | |
| HoTen | NVARCHAR(100) | NOT NULL | |
| ChucVu | NVARCHAR(50) | NULL | |
| SoDienThoai | VARCHAR(20) | NULL | |
| Email | VARCHAR(100) | NULL | |
| TrangThai | BIT | DEFAULT 1 | |

### TaiKhoan
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaTK | INT | PK, IDENTITY(1,1) | |
| TenDangNhap | VARCHAR(50) | NOT NULL, UNIQUE | |
| MatKhau | VARCHAR(256) | NOT NULL | HASHBYTES SHA2_256 |
| MaNV | INT | FK → NhanVien, UNIQUE | 1 NV = 1 TK |
| VaiTro | VARCHAR(20) | CHECK IN ('Admin','NVKho') | |
| TrangThai | BIT | DEFAULT 1 | |

### PhieuNhap
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaPN | INT | PK, IDENTITY(1,1) | |
| SoPhieu | VARCHAR(20) | UNIQUE | PN-YYYY-NNNNN (auto) |
| NgayLap | DATETIME | DEFAULT GETDATE() | |
| NgayDuyet | DATETIME | NULL | |
| MaNCC | INT | FK → NhaCungCap | |
| MaKho | INT | FK → Kho | |
| MaNV | INT | FK → NhanVien | Người lập |
| TrangThai | NVARCHAR(20) | DEFAULT N'Nháp' | Nháp / ĐãDuyệt / ĐãHủy |
| TongTien | DECIMAL(18,2) | DEFAULT 0 | Trigger tự tính |
| GhiChu | NVARCHAR(500) | NULL | |

### ChiTietPhieuNhap (CT_PhieuNhap)
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaCTPN | INT | PK, IDENTITY(1,1) | |
| MaPN | INT | FK → PhieuNhap | ON DELETE CASCADE |
| MaSP | INT | FK → SanPham | |
| SoLuong | INT | NOT NULL, CHECK > 0 | |
| DonGia | DECIMAL(18,2) | NOT NULL, CHECK >= 0 | |
| ThanhTien | AS (SoLuong * DonGia) PERSISTED | | Computed column |

### PhieuXuat
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaPX | INT | PK, IDENTITY(1,1) | |
| SoPhieu | VARCHAR(20) | UNIQUE | PX-YYYY-NNNNN (auto) |
| NgayLap | DATETIME | DEFAULT GETDATE() | |
| NgayDuyet | DATETIME | NULL | |
| MaKho | INT | FK → Kho | |
| MaNV | INT | FK → NhanVien | Người lập |
| NguoiNhan | NVARCHAR(200) | NULL | |
| TrangThai | NVARCHAR(20) | DEFAULT N'Nháp' | Nháp / ĐãDuyệt / ĐãHủy |
| TongTien | DECIMAL(18,2) | DEFAULT 0 | |
| GhiChu | NVARCHAR(500) | NULL | |

### ChiTietPhieuXuat (CT_PhieuXuat)
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaCTPX | INT | PK, IDENTITY(1,1) | |
| MaPX | INT | FK → PhieuXuat | ON DELETE CASCADE |
| MaSP | INT | FK → SanPham | |
| SoLuong | INT | NOT NULL, CHECK > 0 | |
| DonGia | DECIMAL(18,2) | NOT NULL, CHECK >= 0 | |
| ThanhTien | AS (SoLuong * DonGia) PERSISTED | | |

### TonKho
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaTonKho | INT | PK, IDENTITY(1,1) | |
| MaSP | INT | FK → SanPham | |
| MaKho | INT | FK → Kho | |
| SoLuong | INT | NOT NULL, DEFAULT 0, CHECK >= 0 | |
| UNIQUE(MaSP, MaKho) | | | 1 dòng/SP/kho |

### LichSuHoatDong
| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|-------|
| MaLog | BIGINT | PK, IDENTITY(1,1) | |
| BangLienQuan | VARCHAR(50) | NOT NULL | Tên bảng |
| MaBanGhi | INT | NOT NULL | ID record |
| HanhDong | VARCHAR(10) | NOT NULL | INSERT / UPDATE / DELETE |
| NoiDungCu | NVARCHAR(MAX) | NULL | JSON trước thay đổi |
| NoiDungMoi | NVARCHAR(MAX) | NULL | JSON sau thay đổi |
| MaNV | INT | NULL | Người thực hiện |
| ThoiGian | DATETIME | DEFAULT GETDATE() | |

---

## 2. Quan Hệ (ERD)

```
DanhMuc        1──N  SanPham
NhaCungCap     1──N  PhieuNhap
Kho            1──N  PhieuNhap
Kho            1──N  PhieuXuat
Kho            1──N  TonKho
NhanVien       1──N  PhieuNhap
NhanVien       1──N  PhieuXuat
NhanVien       1──1  TaiKhoan
SanPham        1──N  ChiTietPhieuNhap
SanPham        1──N  ChiTietPhieuXuat
SanPham        1──N  TonKho
PhieuNhap      1──N  ChiTietPhieuNhap  (CASCADE DELETE)
PhieuXuat      1──N  ChiTietPhieuXuat  (CASCADE DELETE)
```

---

## 3. Views (9)

| # | View | Mô tả |
|---|------|-------|
| 1 | `v_TonKhoHienTai` | JOIN TonKho + SanPham + Kho + DanhMuc. Cột: MaSP, TenSP, DanhMuc, Kho, SoLuong, TonToiThieu, GiaNhap, GiaTri |
| 2 | `v_SanPhamDuoiTonToiThieu` | WHERE SoLuong < TonToiThieu. Dùng cho badge cảnh báo dashboard |
| 3 | `v_NhapXuatTheoNgay` | GROUP BY CAST(NgayLap AS DATE), SUM nhập, SUM xuất. Dùng cho chart xu hướng |
| 4 | `v_ChiTietPhieuNhap` | JOIN PhieuNhap + CT + NCC + SanPham + NhanVien. Hiển thị đầy đủ 1 phiếu nhập |
| 5 | `v_ChiTietPhieuXuat` | JOIN PhieuXuat + CT + SanPham + NhanVien. Hiển thị đầy đủ 1 phiếu xuất |
| 6 | `v_DoanhThuTheoThang` | GROUP BY YEAR+MONTH, SUM ThanhTien xuất. Dùng cho báo cáo |
| 7 | `v_TopSanPhamXuatNhieu` | TOP 10 SanPham theo SUM SoLuong xuất (chỉ phiếu ĐãDuyệt) |
| 8 | `v_PhieuGanDay` | UNION phiếu nhập + xuất, ORDER BY NgayLap DESC, TOP 10. Dùng cho dashboard |
| 9 | `v_ThongKeTongQuat` | COUNT SanPham, NhaCungCap, Kho, SUM giá trị tồn. Dùng cho dashboard cards |

---

## 4. Functions (5)

| # | Function | Loại | Tham số | Return |
|---|----------|------|---------|--------|
| 1 | `fn_TinhTonKho` | Scalar | @MaSP INT, @MaKho INT | INT – số lượng tồn |
| 2 | `fn_TinhGiaTriTonKho` | Scalar | @MaKho INT | DECIMAL – SUM(SoLuong * GiaNhap) |
| 3 | `fn_TinhGiaXuatBinhQuan` | Scalar | @MaSP INT | DECIMAL – tổng tiền nhập / tổng SL nhập |
| 4 | `fn_LayDanhSachSPTheoKho` | Table-Valued | @MaKho INT | TABLE(MaSP, TenSP, DonVi, SoLuong, GiaNhap) |
| 5 | `fn_TongNhapXuatTrongKy` | Table-Valued | @TuNgay DATE, @DenNgay DATE | TABLE(Ngay, TongNhap, TongXuat) |

---

## 5. Stored Procedures (8)

| # | SP | Tham số | Mô tả |
|---|-----|---------|-------|
| 1 | `sp_TaoPhieuNhap` | @MaNCC, @MaKho, @MaNV, @GhiChu, @ChiTiet (TVP: MaSP, SoLuong, DonGia) | INSERT PhieuNhap + CT. TrangThai = Nháp. Trigger tính TongTien |
| 2 | `sp_TaoPhieuXuat` | @MaKho, @MaNV, @NguoiNhan, @GhiChu, @ChiTiet (TVP) | INSERT PhieuXuat + CT. TrangThai = Nháp |
| 3 | `sp_DuyetPhieu` | @LoaiPhieu VARCHAR(2) ('PN'/'PX'), @MaPhieu INT, @MaNV INT | UPDATE TrangThai → ĐãDuyệt, NgayDuyet. Trigger tự cập nhật tồn |
| 4 | `sp_HuyPhieu` | @LoaiPhieu, @MaPhieu, @MaNV, @LyDo | UPDATE TrangThai → ĐãHủy. Nếu phiếu đã duyệt → hoàn tồn kho |
| 5 | `sp_BaoCaoTonKho` | @MaKho INT = NULL, @TuNgay DATE, @DenNgay DATE | Trả tồn đầu kỳ + nhập trong kỳ + xuất trong kỳ = tồn cuối kỳ |
| 6 | `sp_BaoCaoNhapTheoNCC` | @MaNCC INT = NULL, @TuNgay DATE, @DenNgay DATE | Chi tiết nhập theo NCC, tổng tiền |
| 7 | `sp_BaoCaoXuatTheoSP` | @MaSP INT = NULL, @TuNgay DATE, @DenNgay DATE | Chi tiết xuất theo SP, tổng tiền |
| 8 | `sp_DoiMatKhau` | @MaTK INT, @MatKhauCu VARCHAR, @MatKhauMoi VARCHAR | Kiểm tra hash cũ, update hash mới |

---

## 6. Triggers (7)

### Nguyên tắc: Trigger chỉ cập nhật tồn kho khi phiếu có TrangThai = N'ĐãDuyệt'

| # | Trigger | Bảng | Sự kiện | Logic |
|---|---------|------|---------|-------|
| 1 | `trg_CapNhatTonKho_SauNhap` | CT_PhieuNhap | AFTER INSERT | Kiểm tra PhieuNhap.TrangThai = ĐãDuyệt → UPSERT TonKho (+SoLuong) |
| 2 | `trg_XuatKho_KiemTraVaCapNhat` | CT_PhieuXuat | INSTEAD OF INSERT | Kiểm tra PhieuXuat.TrangThai. Nếu ĐãDuyệt → check tồn kho đủ không → nếu đủ INSERT + trừ tồn, nếu thiếu RAISERROR |
| 3 | `trg_CapNhatTongTien_PN` | CT_PhieuNhap | AFTER INSERT, UPDATE, DELETE | Recalc PhieuNhap.TongTien = SUM(ThanhTien) |
| 4 | `trg_CapNhatTongTien_PX` | CT_PhieuXuat | AFTER INSERT, UPDATE, DELETE | Recalc PhieuXuat.TongTien = SUM(ThanhTien) |
| 5 | `trg_TaoSoPhieu_PN` | PhieuNhap | AFTER INSERT | Generate SoPhieu: PN-YYYY-NNNNN |
| 6 | `trg_TaoSoPhieu_PX` | PhieuXuat | AFTER INSERT | Generate SoPhieu: PX-YYYY-NNNNN |
| 7 | `trg_ChanXoaSP_DaCoPhieu` | SanPham | INSTEAD OF DELETE | Nếu SP đã xuất hiện trong CT_PhieuNhap hoặc CT_PhieuXuat → RAISERROR, không cho xóa |

---

## 7. Cursors (2)

| # | Cursor | Mô tả | Kết quả |
|---|--------|-------|---------|
| 1 | `cur_CanhBaoTonToiThieu` | DECLARE CURSOR duyệt TonKho WHERE SoLuong < SanPham.TonToiThieu. FETCH từng dòng, PRINT cảnh báo | Output: danh sách SP cần nhập thêm |
| 2 | `cur_TinhTonCuoiKy` | Nhận @MaKho, @TuNgay, @DenNgay. Duyệt từng SP trong kho, tính: tồn đầu kỳ + SUM nhập trong kỳ - SUM xuất trong kỳ = tồn cuối kỳ. INSERT kết quả vào temp table | Output: bảng tồn kho cuối kỳ |

Cursor được wrap trong SP để demo qua website: `sp_CursorCanhBaoTon`, `sp_CursorTonCuoiKy`.

---

## 8. Reports (5)

| # | Report | Dữ liệu từ | Hiển thị |
|---|--------|-------------|----------|
| 1 | Tồn kho theo kho + thời gian | `sp_BaoCaoTonKho` | Bảng: SP, tồn đầu, nhập, xuất, tồn cuối |
| 2 | Nhập hàng theo NCC | `sp_BaoCaoNhapTheoNCC` | Bảng + tổng tiền theo NCC |
| 3 | Xuất hàng theo SP | `sp_BaoCaoXuatTheoSP` | Bảng + tổng tiền theo SP |
| 4 | Cảnh báo tồn thấp | `v_SanPhamDuoiTonToiThieu` | Bảng SP có tồn < mức tối thiểu |
| 5 | Xu hướng nhập/xuất | `v_NhapXuatTheoNgay` + `v_DoanhThuTheoThang` | Chart.js bar/line chart |

---

## 9. An Toàn Thông Tin

| Hạng mục | Cách thực hiện |
|----------|----------------|
| Xác thực | Hash password bằng HASHBYTES('SHA2_256'). SP `sp_DoiMatKhau` |
| Phân quyền | SQL Server: CREATE LOGIN/USER/ROLE. GRANT EXEC trên SP, SELECT trên View |
| Import | BCP / BULK INSERT từ CSV |
| Export | BCP OUT / SELECT INTO file |
| Backup | `BACKUP DATABASE InventoryDB TO DISK = @Path` |
| Restore | `RESTORE DATABASE InventoryDB FROM DISK = @Path` |

---

## 10. Index

| Bảng | Cột | Loại | Lý do |
|------|-----|------|-------|
| SanPham | TenSP | NONCLUSTERED | Tìm kiếm theo tên |
| SanPham | MaVach | NONCLUSTERED | Quét mã vạch |
| PhieuNhap | NgayLap | NONCLUSTERED | Filter theo ngày |
| PhieuXuat | NgayLap | NONCLUSTERED | Filter theo ngày |
| TonKho | (MaSP, MaKho) | UNIQUE | Đã có |
| ChiTietPhieuNhap | MaPN | NONCLUSTERED | JOIN performance |
| ChiTietPhieuXuat | MaPX | NONCLUSTERED | JOIN performance |
