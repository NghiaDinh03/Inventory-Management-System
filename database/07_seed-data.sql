USE InventoryDB;
GO

-- Xóa dữ liệu cũ để tránh trùng lặp nếu chạy lại script
DELETE FROM LichSuHoatDong;
DELETE FROM TonKho;
DELETE FROM CT_PhieuXuat;
DELETE FROM PhieuXuat;
DELETE FROM CT_PhieuNhap;
DELETE FROM PhieuNhap;
DELETE FROM TaiKhoan;
DELETE FROM NhanVien;
DELETE FROM SanPham;
DELETE FROM Kho;
DELETE FROM NhaCungCap;
DELETE FROM DanhMuc;
GO

-- Reset identity values
DBCC CHECKIDENT ('DanhMuc', RESEED, 0);
DBCC CHECKIDENT ('NhaCungCap', RESEED, 0);
DBCC CHECKIDENT ('Kho', RESEED, 0);
DBCC CHECKIDENT ('SanPham', RESEED, 0);
DBCC CHECKIDENT ('NhanVien', RESEED, 0);
DBCC CHECKIDENT ('TaiKhoan', RESEED, 0);
DBCC CHECKIDENT ('PhieuNhap', RESEED, 0);
DBCC CHECKIDENT ('CT_PhieuNhap', RESEED, 0);
DBCC CHECKIDENT ('PhieuXuat', RESEED, 0);
DBCC CHECKIDENT ('CT_PhieuXuat', RESEED, 0);
DBCC CHECKIDENT ('TonKho', RESEED, 0);
DBCC CHECKIDENT ('LichSuHoatDong', RESEED, 0);
GO

-- =============================================
-- 1. SEED DATA FOR: DANHMUC (DANH MỤC SẢN PHẨM)
-- =============================================
INSERT INTO DanhMuc (TenDanhMuc, MoTa, TrangThai) VALUES
(N'Điện tử & Linh kiện', N'Điện thoại, máy tính, linh kiện phần cứng', 1),
(N'Thiết bị Gia dụng', N'Tủ lạnh, tivi, máy giặt, lò vi sóng', 1),
(N'Hóa mỹ phẩm', N'Bột giặt, dầu gội, nước rửa chén', 1),
(N'Thực phẩm & Đồ uống', N'Sữa, bánh kẹo, nước giải khát, mì gói', 1),
(N'Văn phòng phẩm', N'Giấy, bút, sổ tay, file hồ sơ', 1);
GO

-- =============================================
-- 2. SEED DATA FOR: NHACUNGCAP (NHÀ CUNG CẤP)
-- =============================================
INSERT INTO NhaCungCap (TenNCC, DiaChi, SoDienThoai, Email, NguoiLienHe, TrangThai) VALUES
(N'Công ty TNHH Phân Phối Hoàng Gia', N'123 Đường Láng, Đống Đa, Hà Nội', '0243999888', 'contact@hoanggiadist.vn', N'Nguyễn Hoàng Gia', 1),
(N'Công ty CP Đầu Tư Phát Triển Minh Phát', N'456 Nguyễn Thị Minh Khai, Quận 3, TP.HCM', '0283888777', 'sales@minhphatcorp.vn', N'Trần Minh Phát', 1),
(N'Công ty CP Sữa Vinamilk Việt Nam', N'10 Tân Trào, Tân Phú, Quận 7, TP.HCM', '02854155555', 'vinamilk@vinamilk.com.vn', N'Lê Hoàng Nam', 1),
(N'Công ty TNHH Unilever Việt Nam', N'156 Nguyễn Lương Bằng, Quận 7, TP.HCM', '02854135686', 'tuvankhachhang@unilever.com', N'Phạm Thu Trang', 1),
(N'Tổng Kho Văn Phòng Phẩm Hồng Hà', N'25 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', '02438253151', 'sales@hongha.vn', N'Nguyễn Minh Anh', 1);
GO

-- =============================================
-- 3. SEED DATA FOR: KHO (KHO CHỨA HÀNG)
-- =============================================
INSERT INTO Kho (TenKho, DiaChi, TrangThai) VALUES
(N'Kho Tổng TP.HCM', N'Lô C12, Đường số 7, KCN Cát Lái, Quận 2, TP.HCM', 1),
(N'Kho Sơ Cấp Bình Dương', N'Số 8 Đại lộ Độc Lập, KCN Sóng Thần, Dĩ An, Bình Dương', 1),
(N'Kho Trung Chuyển Hà Nội', N'Số 15 Ngọc Hồi, Hoàng Mai, Hà Nội', 1);
GO

-- =============================================
-- 4. SEED DATA FOR: SANPHAM (SẢN PHẨM)
-- =============================================
INSERT INTO SanPham (TenSP, MaDanhMuc, DonVi, MaVach, GiaNhap, GiaBan, TonToiThieu, HinhAnh, MoTa, TrangThai) VALUES
-- Điện tử & Linh kiện (MaDanhMuc = 1)
(N'Chuột không dây Logitech M331', 1, N'Cái', '8936012345001', 180000.00, 250000.00, 15, '/images/products/logitech_m331.jpg', N'Chuột không dây Silent mượt mà', 1),
(N'Bàn phím cơ Logitech G213', 1, N'Cái', '8936012345002', 850000.00, 1200000.00, 5, '/images/products/logitech_g213.jpg', N'Bàn phím giả cơ chuyên game RGB', 1),
(N'Tai nghe chụp tai Sony WH-CH520', 1, N'Cái', '8936012345003', 900000.00, 1300000.00, 5, '/images/products/sony_wh_ch520.jpg', N'Tai nghe chụp tai bluetooth không dây thời lượng pin 50h', 1),

-- Thiết bị Gia dụng (MaDanhMuc = 2)
(N'Nồi cơm điện Tefal 1.8L', 2, N'Cái', '8936012345004', 1200000.00, 1750000.00, 8, '/images/products/tefal_cooker.jpg', N'Nồi cơm điện lòng niêu cao cấp', 1),
(N'Quạt đứng Senko DTS1607', 2, N'Cái', '8936012345005', 320000.00, 450000.00, 20, '/images/products/senko_dts1607.jpg', N'Quạt đứng 5 cánh gió mạnh mẽ', 1),

-- Hóa mỹ phẩm (MaDanhMuc = 3)
(N'Nước lau sàn Sunlight Hương Hoa Thiên Nhiên 3.8kg', 3, N'Chai', '8936012345006', 65000.00, 85000.00, 30, '/images/products/sunlight_floor.jpg', N'Nước lau sàn thơm mát sạch bóng', 1),
(N'Nước rửa chén Sunlight Chanh 3.6kg', 3, N'Chai', '8936012345007', 85000.00, 115000.00, 25, '/images/products/sunlight_dish.jpg', N'Nước rửa chén sạch dầu mỡ nhanh chóng', 1),
(N'Dầu gội Clear Bạc Hà Thơm Mát 630ml', 3, N'Chai', '8936012345008', 135000.00, 175000.00, 20, '/images/products/clear_shampoo.jpg', N'Dầu gội sạch gàu sảng khoái mát lạnh', 1),

-- Thực phẩm & Đồ uống (MaDanhMuc = 4)
(N'Sữa tươi Vinamilk Có Đường 180ml', 4, N'Thùng', '8936012345009', 315000.00, 370000.00, 50, '/images/products/vinamilk_180.jpg', N'Thùng 48 hộp sữa tươi tiệt trùng', 1),
(N'Sữa đặc Ông Thọ Đỏ 380g', 4, N'Hộp', '8936012345010', 20000.00, 25000.00, 100, '/images/products/ong_tho_do.jpg', N'Sữa đặc có đường thơm ngon', 1),
(N'Nước ngọt Coca Cola 320ml', 4, N'Thùng', '8936012345011', 170000.00, 210000.00, 40, '/images/products/coca_320.jpg', N'Thùng 24 lon Coca Cola giải khát', 1),

-- Văn phòng phẩm (MaDanhMuc = 5)
(N'Giấy in Double A A4 70gsm', 5, N'Ram', '8936012345012', 55000.00, 75000.00, 100, '/images/products/double_a_a4.jpg', N'Giấy in chất lượng cao Thái Lan', 1),
(N'Bút bi Thiên Long 0.27mm TL-027', 5, N'Hộp', '8936012345013', 50000.00, 72000.00, 50, '/images/products/but_bi_tl027.jpg', N'Hộp 20 cây bút bi mực xanh', 1);
GO

-- =============================================
-- 5. SEED DATA FOR: NHANVIEN (NHÂN VIÊN)
-- =============================================
INSERT INTO NhanVien (HoTen, ChucVu, SoDienThoai, Email, TrangThai) VALUES
(N'Nguyễn Văn Trị', N'Quản lý hệ thống', '0901234567', 'tri.nguyen@inventory.com', 1),
(N'Trần Minh Khoa', N'Thủ kho TP.HCM', '0912345678', 'khoa.tran@inventory.com', 1),
(N'Lê Thị Bình', N'Thủ kho Bình Dương', '0923456789', 'binh.le@inventory.com', 1),
(N'Hoàng Văn Nam', N'Nhân viên kiểm kho', '0934567890', 'nam.hoang@inventory.com', 1);
GO

-- =============================================
-- 6. SEED DATA FOR: TAIKHOAN (TÀI KHOẢN)
-- Mật khẩu mặc định:
-- - admin: Admin@2026 -> hash SHA2_256 (uppercase)
-- - nvkho1: NVKho@2026 -> hash SHA2_256 (uppercase)
-- - nvkho2: NVKho@2026 -> hash SHA2_256 (uppercase)
-- =============================================
INSERT INTO TaiKhoan (TenDangNhap, MatKhau, MaNV, VaiTro, TrangThai) VALUES
('admin', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Admin@2026'), 2), 1, 'Admin', 1),
('nvkho1', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'NVKho@2026'), 2), 2, 'NVKho', 1),
('nvkho2', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'NVKho@2026'), 2), 3, 'NVKho', 1);
GO

-- =============================================
-- 7. SEED DATA FOR: TONKHO (TỒN KHO BAN ĐẦU)
-- Thiết lập số lượng ban đầu trong các kho
-- =============================================
INSERT INTO TonKho (MaSP, MaKho, SoLuong) VALUES
-- Kho Tổng TP.HCM (MaKho = 1)
(1, 1, 50),   -- Chuột Logitech
(2, 1, 10),   -- Bàn phím cơ
(3, 1, 15),   -- Tai nghe Sony
(4, 1, 20),   -- Nồi cơm Tefal
(6, 1, 120),  -- Lau sàn Sunlight
(7, 1, 100),  -- Rửa chén Sunlight
(9, 1, 300),  -- Sữa tươi Vinamilk
(10, 1, 400), -- Sữa đặc Ông Thọ
(12, 1, 250), -- Giấy A4 Double A

-- Kho Sơ Cấp Bình Dương (MaKho = 2)
(1, 2, 30),   -- Chuột Logitech
(5, 2, 45),   -- Quạt Senko
(6, 2, 60),   -- Lau sàn Sunlight
(8, 2, 80),   -- Dầu gội Clear
(9, 2, 150),  -- Sữa tươi Vinamilk
(11, 2, 200), -- Coca Cola
(12, 2, 150), -- Giấy A4 Double A
(13, 2, 120), -- Bút bi Thiên Long

-- Kho Trung Chuyển Hà Nội (MaKho = 3)
(1, 3, 5),    -- Chuột Logitech (Đang ở dưới mức tối thiểu 15)
(2, 3, 2),    -- Bàn phím cơ (Dưới mức tối thiểu 5)
(4, 3, 1),    -- Nồi cơm Tefal (Dưới mức tối thiểu 8)
(9, 3, 80),   -- Sữa tươi Vinamilk
(11, 3, 50);  -- Coca Cola
GO

-- =============================================
-- 8. SEED DATA FOR: PHIEUNHAP (PHIẾU NHẬP) VÀ CHI TIẾT
-- =============================================
-- Phiếu 1: Đã Duyệt, nhập hàng từ Unilever cho Kho Tổng TP.HCM vào tháng 5/2026
INSERT INTO PhieuNhap (SoPhieu, NgayLap, NgayDuyet, MaNCC, MaKho, MaNV, TrangThai, TongTien, GhiChu) VALUES
('PN-2026-00001', '2026-05-10 09:00:00', '2026-05-10 10:30:00', 4, 1, 2, N'ĐãDuyệt', 22750000.00, N'Nhập hàng hóa mỹ phẩm định kỳ Unilever');

INSERT INTO CT_PhieuNhap (MaPN, MaSP, SoLuong, DonGia) VALUES
(1, 6, 100, 65000.00), -- 100 chai lau sàn Sunlight
(1, 7, 100, 85000.00), -- 100 chai rửa chén Sunlight
(1, 8, 50, 135000.00); -- 50 chai dầu gội Clear

-- Phiếu 2: Đã Duyệt, nhập sữa Vinamilk cho Kho Sơ Cấp Bình Dương vào tháng 5/2026
INSERT INTO PhieuNhap (SoPhieu, NgayLap, NgayDuyet, MaNCC, MaKho, MaNV, TrangThai, TongTien, GhiChu) VALUES
('PN-2026-00002', '2026-05-15 14:00:00', '2026-05-15 15:00:00', 3, 2, 3, N'ĐãDuyệt', 51250000.00, N'Nhập sữa tươi sữa đặc Vinamilk');

INSERT INTO CT_PhieuNhap (MaPN, MaSP, SoLuong, DonGia) VALUES
(2, 9, 150, 315000.00), -- 150 thùng sữa tươi
(2, 10, 200, 20000.00);  -- 200 hộp sữa đặc Ông Thọ

-- Phiếu 3: Nháp, phiếu nháp nhập linh kiện điện tử từ Hoàng Gia
INSERT INTO PhieuNhap (SoPhieu, NgayLap, NgayDuyet, MaNCC, MaKho, MaNV, TrangThai, TongTien, GhiChu) VALUES
('PN-2026-00003', '2026-06-05 08:30:00', NULL, 1, 1, 2, N'Nháp', 15700000.00, N'Nhập bổ sung chuột phím Sony và Logitech');

INSERT INTO CT_PhieuNhap (MaPN, MaSP, SoLuong, DonGia) VALUES
(3, 1, 40, 180000.00),
(3, 2, 10, 850000.00);

-- Phiếu 4: Đã Hủy, phiếu nhập từ Hồng Hà bị hủy do sai đơn giá
INSERT INTO PhieuNhap (SoPhieu, NgayLap, NgayDuyet, MaNCC, MaKho, MaNV, TrangThai, TongTien, GhiChu) VALUES
('PN-2026-00004', '2026-06-06 10:00:00', NULL, 5, 3, 4, N'ĐãHủy', 8000000.00, N'Nhập giấy in Hồng Hà | Lý do hủy: Sai đơn giá thỏa thuận');

INSERT INTO CT_PhieuNhap (MaPN, MaSP, SoLuong, DonGia) VALUES
(4, 12, 100, 80000.00); -- Giá nhập bị sai, đáng lẽ 55000
GO

-- =============================================
-- 9. SEED DATA FOR: PHIEUXUAT (PHIẾU XUẤT) VÀ CHI TIẾT
-- =============================================
-- Phiếu 1: Đã Duyệt, xuất bán văn phòng phẩm cho trường học từ Kho Tổng TP.HCM vào tháng 5/2026
INSERT INTO PhieuXuat (SoPhieu, NgayLap, NgayDuyet, MaKho, MaNV, NguoiNhan, TrangThai, TongTien, GhiChu) VALUES
('PX-2026-00001', '2026-05-20 08:00:00', '2026-05-20 09:30:00', 1, 2, N'Nguyễn Thị Hồng (Trường ĐH CNTT)', N'ĐãDuyệt', 3750000.00, N'Xuất cấp phát văn phòng phẩm kỳ thi học kỳ');

INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia) VALUES
(1, 12, 50, 75000.00); -- 50 ram giấy A4

-- Phiếu 2: Đã Duyệt, xuất Coca Cola cho đại lý từ Kho Bình Dương vào cuối tháng 5/2026
INSERT INTO PhieuXuat (SoPhieu, NgayLap, NgayDuyet, MaKho, MaNV, NguoiNhan, TrangThai, TongTien, GhiChu) VALUES
('PX-2026-00002', '2026-05-28 15:00:00', '2026-05-28 16:00:00', 2, 3, N'Lê Minh Hoàng (Đại lý Sóng Thần)', N'ĐãDuyệt', 21000000.00, N'Xuất bán Coca Cola số lượng lớn đại lý');

INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia) VALUES
(2, 11, 100, 210000.00); -- 100 thùng Coca Cola

-- Phiếu 3: Nháp, xuất bán thiết bị gia dụng Senko
INSERT INTO PhieuXuat (SoPhieu, NgayLap, NgayDuyet, MaKho, MaNV, NguoiNhan, TrangThai, TongTien, GhiChu) VALUES
('PX-2026-00003', '2026-06-07 11:00:00', NULL, 2, 3, N'Nguyễn Văn Long', N'Nháp', 4500000.00, N'Xuất bán lẻ quạt Senko khách hàng tự chở');

INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia) VALUES
(3, 5, 10, 450000.00);
GO

-- =============================================
-- 10. SEED DATA FOR: LICHSUHOATDONG (LỊCH SỬ HOẠT ĐỘNG)
-- =============================================
INSERT INTO LichSuHoatDong (BangLienQuan, MaBanGhi, HanhDong, NoiDungCu, NoiDungMoi, MaNV, ThoiGian) VALUES
('TaiKhoan', 1, 'INSERT', NULL, N'{"TenDangNhap":"admin","VaiTro":"Admin"}', 1, '2026-05-01 08:00:00'),
('PhieuNhap', 1, 'INSERT', NULL, N'{"SoPhieu":"PN-2026-00001","TrangThai":"Nháp"}', 2, '2026-05-10 09:00:00'),
('PhieuNhap', 1, 'UPDATE', N'{"TrangThai":"Nháp"}', N'{"TrangThai":"ĐãDuyệt"}', 2, '2026-05-10 10:30:00'),
('PhieuXuat', 1, 'INSERT', NULL, N'{"SoPhieu":"PX-2026-00001","TrangThai":"Nháp"}', 2, '2026-05-20 08:00:00'),
('PhieuXuat', 1, 'UPDATE', N'{"TrangThai":"Nháp"}', N'{"TrangThai":"ĐãDuyệt"}', 2, '2026-05-20 09:30:00');
GO
