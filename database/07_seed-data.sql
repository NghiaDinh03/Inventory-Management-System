USE InventoryDB;
GO

SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Seed data: DanhMucSanPham
INSERT INTO DanhMucSanPham (TenDanhMucSP, MoTa) VALUES
(N'Điện tử & Linh kiện', N'Điện thoại, máy tính, linh kiện phần cứng'),
(N'Thiết bị Gia dụng', N'Tủ lạnh, tivi, máy giặt, lò vi sóng'),
(N'Hóa mỹ phẩm', N'Bột giặt, dầu gội, nước rửa chén'),
(N'Thực phẩm & Đồ uống', N'Sữa, bánh kẹo, nước giải khát, mì gói'),
(N'Văn phòng phẩm', N'Giấy, bút, sổ tay, file hồ sơ');
GO

-- 2. Seed data: NhaCungCap
INSERT INTO NhaCungCap (TenNCC, DiaChi, SoDienThoai, Email, NguoiLienHe, TrangThai) VALUES
(N'Công ty TNHH Phân Phối Hoàng Gia', N'123 Đường Láng, Đống Đa, Hà Nội', '0243999888', 'contact@hoanggiadist.vn', N'Nguyễn Hoàng Gia', 1),
(N'Công ty CP Đầu Tư Phát Triển Minh Phát', N'456 Nguyễn Thị Minh Khai, Quận 3, TP.HCM', '0283888777', 'sales@minhphatcorp.vn', N'Trần Minh Phát', 1),
(N'Công ty CP Sữa Vinamilk Việt Nam', N'10 Tân Trào, Tân Phú, Quận 7, TP.HCM', '02854155555', 'vinamilk@vinamilk.com.vn', N'Lê Hoàng Nam', 1),
(N'Công ty TNHH Unilever Việt Nam', N'156 Nguyễn Lương Bằng, Quận 7, TP.HCM', '02854135686', 'tuvankhachhang@unilever.com', N'Phạm Thu Trang', 1),
(N'Tổng Kho Văn Phòng Phẩm Hồng Hà', N'25 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', '02438253151', 'sales@hongha.vn', N'Nguyễn Minh Anh', 1);
GO

-- 3. Seed data: Kho
INSERT INTO Kho (TenKho, DiaChi, TrangThai) VALUES
(N'Kho Tổng TP.HCM', N'Lô C12, Đường số 7, KCN Cát Lái, Quận 2, TP.HCM', 1),
(N'Kho Bình Dương', N'Số 8 Đại lộ Độc Lập, KCN Sóng Thần, Dĩ An, Bình Dương', 1),
(N'Kho Trung Chuyển Hà Nội', N'Số 15 Ngọc Hồi, Hoàng Mai, Hà Nội', 1);
GO

-- 4. Seed data: SanPham
INSERT INTO SanPham (TenSP, MaDanhMucSP, TrongLuong, DonVi, MaVach, GiaNhap, GiaBan, TonToiThieu, HinhAnh, MoTa, TrangThai) VALUES
-- Electronics (MaDanhMucSP = 1)
(N'Chuột không dây Logitech M331', 1, 0.150, N'Cái', '5099206066274', 180000.00, 250000.00, 15, '/images/products/logitech_m331.jpg', N'Chuột không dây Silent mượt mà', 1),
(N'Bàn phím cơ Logitech G213', 1, 1.100, N'Cái', '5099206067943', 850000.00, 1200000.00, 5, '/images/products/logitech_g213.jpg', N'Bàn phím giả cơ chuyên game RGB', 1),
(N'Tai nghe chụp tai Sony WH-CH520', 1, 0.350, N'Cái', '4548736140134', 900000.00, 1300000.00, 5, '/images/products/sony_wh_ch520.jpg', N'Tai nghe chụp tai bluetooth không dây thời lượng pin 50h', 1),

-- Appliances (MaDanhMucSP = 2)
(N'Nồi cơm điện Tefal 1.8L', 2, 3.500, N'Cái', '3016661156824', 1200000.00, 1750000.00, 8, '/images/products/tefal_cooker.jpg', N'Nồi cơm điện lòng niêu cao cấp', 1),
(N'Quạt đứng Senko DTS1607', 2, 4.200, N'Cái', '8936034151745', 320000.00, 450000.00, 20, '/images/products/senko_dts1607.jpg', N'Quạt đứng 5 cánh gió mạnh mẽ', 1),

-- Cosmetics (MaDanhMucSP = 3)
(N'Nước lau sàn Sunlight Hương Hoa 3.8kg', 3, 3.800, N'Chai', '8934839121972', 65000.00, 85000.00, 30, '/images/products/sunlight_floor.jpg', N'Nước lau sàn thơm mát sạch bóng', 1),
(N'Nước rửa chén Sunlight Chanh 3.6kg', 3, 3.600, N'Chai', '8934839111812', 85000.00, 115000.00, 25, '/images/products/sunlight_dish.jpg', N'Nước rửa chén sạch dầu mỡ nhanh chóng', 1),
(N'Dầu gội Clear Bạc Hà Thơm Mát 630ml', 3, 0.700, N'Chai', '8934839123847', 135000.00, 175000.00, 20, '/images/products/clear_shampoo.jpg', N'Dầu gội sạch gàu sảng khoái mát lạnh', 1),

-- F&B (MaDanhMucSP = 4)
(N'Sữa tươi Vinamilk Có Đường 180ml', 4, 9.600, N'Thùng', '8934673151833', 315000.00, 370000.00, 50, '/images/products/vinamilk_180.jpg', N'Thùng 48 hộp sữa tươi tiệt trùng', 1),
(N'Sữa đặc Ông Thọ Đỏ 380g', 4, 0.440, N'Hộp', '8934673270030', 20000.00, 25000.00, 100, '/images/products/ong_tho_do.jpg', N'Sữa đặc có đường thơm ngon', 1),
(N'Nước ngọt Coca Cola 320ml', 4, 8.500, N'Thùng', '8935049500466', 170000.00, 210000.00, 40, '/images/products/coca_320.jpg', N'Thùng 24 lon Coca Cola giải khát', 1),

-- Office supplies (MaDanhMucSP = 5)
(N'Giấy in Double A A4 70gsm', 5, 2.200, N'Ram', '8851351110174', 55000.00, 75000.00, 100, '/images/products/double_a_a4.jpg', N'Giấy in chất lượng cao Thái Lan', 1),
(N'Bút bi Thiên Long 0.27mm TL-027', 5, 0.150, N'Hộp', '8935001800160', 50000.00, 72000.00, 50, '/images/products/but_bi_tl027.jpg', N'Hộp 20 cây bút bi mực xanh', 1);
GO

-- 5. Seed data: NCC_SanPham
INSERT INTO NCC_SanPham (MaNCC, MaSP, GiaNhap, NgayCapNhat) VALUES
(1, 1, 180000.00, GETDATE()),
(1, 2, 850000.00, GETDATE()),
(1, 3, 900000.00, GETDATE()),
(2, 4, 1200000.00, GETDATE()),
(2, 5, 320000.00, GETDATE()),
(4, 6, 65000.00, GETDATE()),
(4, 7, 85000.00, GETDATE()),
(4, 8, 135000.00, GETDATE()),
(3, 9, 315000.00, GETDATE()),
(3, 10, 20000.00, GETDATE()),
(3, 11, 170000.00, GETDATE()),
(5, 12, 55000.00, GETDATE()),
(5, 13, 50000.00, GETDATE());
GO

-- 6. Seed data: NhanVien
INSERT INTO NhanVien (HoTen, ChucVu, SoDienThoai, NgaySinh, CCCD, NgayCap, NoiCap, GioiTinh, Email, TrangThai) VALUES
(N'Nguyễn Văn Trị', N'Quản lý hệ thống', '0901234567', '1985-05-15', '030085012345', '2021-10-20', N'Cục CSQLHC về TTXH', 1, 'tri.nguyen@inventory.com', 1),
(N'Trần Minh Khoa', N'Thủ kho TP.HCM', '0912345678', '1990-09-22', '030090098765', '2022-03-12', N'Công an TP.HCM', 1, 'khoa.tran@inventory.com', 1),
(N'Lê Thị Bình', N'Thủ kho Bình Dương', '0923456789', '1993-11-04', '035093001234', '2022-06-18', N'Công an tỉnh Bình Dương', 0, 'binh.le@inventory.com', 1),
(N'Hoàng Văn Nam', N'Nhân viên kiểm kho', '0934567890', '1995-02-28', '038095055555', '2023-01-05', N'Cục CSQLHC về TTXH', 1, 'nam.hoang@inventory.com', 1);
GO

-- 7. Seed data: VaiTro
INSERT INTO VaiTro (TenVaiTro, MoTa, TrangThai) VALUES
(N'Admin', N'Quản trị viên toàn quyền hệ thống', 1),
(N'NVKho', N'Nhân viên kho thực thi xuất nhập kho', 1);
GO

-- 8. Seed data: TaiKhoan
INSERT INTO TaiKhoan (TenDangNhap, MatKhau, MaNV, MaVT, TrangThai) VALUES
('admin', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Admin_password_2026'), 2), 1, 1, 1),
('nvkho1', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Nvkho_password_2026'), 2), 2, 2, 1),
('nvkho2', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Nvkho_password_2026'), 2), 3, 2, 1);
GO

-- 9. Seed data: TonKho
INSERT INTO TonKho (MaSP, MaKho, SoLuongTon, TrongLuongTon) VALUES
-- Kho Tong TP.HCM (MaKho = 1)
(1, 1, 50, 50 * 0.150),
(2, 1, 10, 10 * 1.100),
(3, 1, 15, 15 * 0.350),
(4, 1, 20, 20 * 3.500),
(6, 1, 120, 120 * 3.800),
(7, 1, 100, 100 * 3.600),
(9, 1, 300, 300 * 9.600),
(10, 1, 400, 400 * 0.440),
(12, 1, 250, 250 * 2.200),

-- Kho Binh Duong (MaKho = 2)
(1, 2, 30, 30 * 0.150),
(5, 2, 45, 45 * 4.200),
(6, 2, 60, 60 * 3.800),
(8, 2, 80, 80 * 0.700),
(9, 2, 150, 150 * 9.600),
(11, 2, 200, 200 * 8.500),
(12, 2, 150, 150 * 2.200),
(13, 2, 120, 120 * 0.150),

-- Kho Ha Noi (MaKho = 3)
(1, 3, 5, 5 * 0.150),
(2, 3, 2, 2 * 1.100),
(4, 3, 1, 1 * 3.500),
(9, 3, 80, 80 * 9.600),
(11, 3, 50, 50 * 8.500);
GO

-- 10. Seed data: PhieuNhap and CT_PhieuNhap
-- PO 1: Approved, Unilever import (5 days ago), Duyệt bởi Admin
INSERT INTO PhieuNhap (SoPhieu, NgayLap, NgayDuyet, MaNCC, MaKho, MaNV, MaNV_Duyet, TrangThai, TongTien, GhiChu) VALUES
('PN-2026-00001', DATEADD(day, -5, GETDATE()), DATEADD(minute, 30, DATEADD(day, -5, GETDATE())), 4, 1, 2, 1, N'ĐãDuyệt', 22750000.00, N'Nhập hàng hóa mỹ phẩm Unilever');

INSERT INTO CT_PhieuNhap (MaPN, MaSP, SoLuong, DonGia) VALUES
(1, 6, 100, 65000.00),
(1, 7, 100, 85000.00),
(1, 8, 50, 135000.00);

-- PO 2: Approved, Vinamilk import (3 days ago), Duyệt bởi Admin
INSERT INTO PhieuNhap (SoPhieu, NgayLap, NgayDuyet, MaNCC, MaKho, MaNV, MaNV_Duyet, TrangThai, TongTien, GhiChu) VALUES
('PN-2026-00002', DATEADD(day, -3, GETDATE()), DATEADD(minute, 45, DATEADD(day, -3, GETDATE())), 3, 2, 3, 1, N'ĐãDuyệt', 51250000.00, N'Nhập sữa tươi sữa đặc Vinamilk');

INSERT INTO CT_PhieuNhap (MaPN, MaSP, SoLuong, DonGia) VALUES
(2, 9, 150, 315000.00),
(2, 10, 200, 20000.00);

-- PO 3: Draft, Hoang Gia import (1 day ago)
INSERT INTO PhieuNhap (SoPhieu, NgayLap, NgayDuyet, MaNCC, MaKho, MaNV, MaNV_Duyet, TrangThai, TongTien, GhiChu) VALUES
('PN-2026-00003', DATEADD(day, -1, GETDATE()), NULL, 1, 1, 2, NULL, N'Nháp', 15700000.00, N'Nhập bổ sung chuột phím Sony và Logitech');

INSERT INTO CT_PhieuNhap (MaPN, MaSP, SoLuong, DonGia) VALUES
(3, 1, 40, 180000.00),
(3, 2, 10, 850000.00);

-- PO 4: Cancelled, Hong Ha import (6 days ago)
INSERT INTO PhieuNhap (SoPhieu, NgayLap, NgayDuyet, MaNCC, MaKho, MaNV, MaNV_Duyet, TrangThai, TongTien, GhiChu) VALUES
('PN-2026-00004', DATEADD(day, -6, GETDATE()), NULL, 5, 3, 4, 1, N'ĐãHủy', 8000000.00, N'Nhập giấy in Hồng Hà | Hủy do sai đơn giá');

INSERT INTO CT_PhieuNhap (MaPN, MaSP, SoLuong, DonGia) VALUES
(4, 12, 100, 80000.00);
GO

-- 11. Seed data: PhieuXuat and CT_PhieuXuat
-- GI 1: Approved, School export (4 days ago), Duyệt bởi Admin
INSERT INTO PhieuXuat (SoPhieu, NgayLap, NgayDuyet, MaKho, MaNV, MaNV_Duyet, NguoiNhan, TrangThai, TongTien, GhiChu) VALUES
('PX-2026-00001', DATEADD(day, -4, GETDATE()), DATEADD(minute, 60, DATEADD(day, -4, GETDATE())), 1, 2, 1, N'Nguyễn Thị Hồng (Trường ĐH CNTT)', N'ĐãDuyệt', 3750000.00, N'Xuất cấp phát văn phòng phẩm kỳ thi học kỳ');

INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia) VALUES
(1, 12, 50, 75000.00);

-- GI 2: Approved, Coca Cola export (2 days ago), Duyệt bởi Admin
INSERT INTO PhieuXuat (SoPhieu, NgayLap, NgayDuyet, MaKho, MaNV, MaNV_Duyet, NguoiNhan, TrangThai, TongTien, GhiChu) VALUES
('PX-2026-00002', DATEADD(day, -2, GETDATE()), DATEADD(minute, 30, DATEADD(day, -2, GETDATE())), 2, 3, 1, N'Lê Minh Hoàng (Đại lý Sóng Thần)', N'ĐãDuyệt', 21000000.00, N'Xuất bán Coca Cola số lượng lớn đại lý');

INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia) VALUES
(2, 11, 100, 210000.00);

-- GI 3: Draft, Senko export (Today)
INSERT INTO PhieuXuat (SoPhieu, NgayLap, NgayDuyet, MaKho, MaNV, MaNV_Duyet, NguoiNhan, TrangThai, TongTien, GhiChu) VALUES
('PX-2026-00003', DATEADD(minute, -30, GETDATE()), NULL, 2, 3, NULL, N'Nguyễn Văn Long', N'Nháp', 4500000.00, N'Xuất bán lẻ quạt Senko');

INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia) VALUES
(3, 5, 10, 450000.00);
GO

-- 12. Seed data: Gia
-- Seed giá lịch sử từ các phiếu nhập đã duyệt
INSERT INTO Gia (MaSP, NgayLap, DonGiaNhap) VALUES
(6, DATEADD(day, -5, GETDATE()), 65000.00),
(7, DATEADD(day, -5, GETDATE()), 85000.00),
(8, DATEADD(day, -5, GETDATE()), 135000.00),
(9, DATEADD(day, -3, GETDATE()), 315000.00),
(10, DATEADD(day, -3, GETDATE()), 20000.00);
GO

-- 13. Seed data: LichSuHoatDong
INSERT INTO LichSuHoatDong (BangLienQuan, MaBanGhi, HanhDong, MaPhieu, NoiDungCu, NoiDungMoi, MaNV, ThoiGian) VALUES
('TaiKhoan', 1, 'INSERT', NULL, NULL, N'{"TenDangNhap":"admin","MaVT":1}', 1, DATEADD(day, -10, GETDATE())),
('PhieuNhap', 1, 'INSERT', 'PN-2026-00001', NULL, N'{"SoPhieu":"PN-2026-00001","TrangThai":"Nháp"}', 2, DATEADD(day, -5, GETDATE())),
('PhieuNhap', 1, 'UPDATE', 'PN-2026-00001', N'{"TrangThai":"Nháp"}', N'{"TrangThai":"ĐãDuyệt"}', 2, DATEADD(minute, 30, DATEADD(day, -5, GETDATE()))),
('PhieuXuat', 1, 'INSERT', 'PX-2026-00001', NULL, N'{"SoPhieu":"PX-2026-00001","TrangThai":"Nháp"}', 2, DATEADD(day, -4, GETDATE())),
('PhieuXuat', 1, 'UPDATE', 'PX-2026-00001', N'{"TrangThai":"Nháp"}', N'{"TrangThai":"ĐãDuyệt"}', 2, DATEADD(minute, 60, DATEADD(day, -4, GETDATE())));
GO

PRINT N'07_seed-data.sql completed.';
GO
