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

-- 1. View current stock level
CREATE OR ALTER VIEW v_TonKhoHienTai AS
SELECT
    tk.MaTonKho,
    sp.MaSP,
    sp.TenSP,
    sp.DonVi,
    sp.MaVach,
    dm.TenDanhMuc,
    k.MaKho,
    k.TenKho,
    tk.SoLuong,
    sp.TonToiThieu,
    sp.GiaNhap,
    CAST(tk.SoLuong * sp.GiaNhap AS DECIMAL(18,2)) AS GiaTri
FROM TonKho tk
    INNER JOIN SanPham sp ON tk.MaSP = sp.MaSP
    INNER JOIN DanhMuc dm ON sp.MaDanhMuc = dm.MaDanhMuc
    INNER JOIN Kho k ON tk.MaKho = k.MaKho
WHERE sp.TrangThai = 1;
GO

-- 2. View products below minimum stock level
CREATE OR ALTER VIEW v_SanPhamDuoiTonToiThieu AS
SELECT
    sp.MaSP,
    sp.TenSP,
    sp.DonVi,
    dm.TenDanhMuc,
    k.TenKho,
    tk.SoLuong,
    sp.TonToiThieu,
    (sp.TonToiThieu - tk.SoLuong) AS CanNhapThem
FROM TonKho tk
    INNER JOIN SanPham sp ON tk.MaSP = sp.MaSP
    INNER JOIN DanhMuc dm ON sp.MaDanhMuc = dm.MaDanhMuc
    INNER JOIN Kho k ON tk.MaKho = k.MaKho
WHERE tk.SoLuong < sp.TonToiThieu
    AND sp.TrangThai = 1;
GO

-- 3. View import/export metrics grouped by date
CREATE OR ALTER VIEW v_NhapXuatTheoNgay AS
SELECT
    Ngay,
    SUM(TongNhap) AS TongNhap,
    SUM(TongXuat) AS TongXuat
FROM (
    SELECT
        CAST(pn.NgayLap AS DATE) AS Ngay,
        SUM(ct.SoLuong) AS TongNhap,
        0 AS TongXuat
    FROM PhieuNhap pn
        INNER JOIN CT_PhieuNhap ct ON pn.MaPN = ct.MaPN
    WHERE pn.TrangThai = N'ĐãDuyệt'
    GROUP BY CAST(pn.NgayLap AS DATE)

    UNION ALL

    SELECT
        CAST(px.NgayLap AS DATE) AS Ngay,
        0 AS TongNhap,
        SUM(ct.SoLuong) AS TongXuat
    FROM PhieuXuat px
        INNER JOIN CT_PhieuXuat ct ON px.MaPX = ct.MaPX
    WHERE px.TrangThai = N'ĐãDuyệt'
    GROUP BY CAST(px.NgayLap AS DATE)
) AS Combined
GROUP BY Ngay;
GO

-- 4. View purchase order details
CREATE OR ALTER VIEW v_ChiTietPhieuNhap AS
SELECT
    pn.MaPN,
    pn.SoPhieu,
    pn.NgayLap,
    pn.NgayDuyet,
    pn.TrangThai,
    pn.TongTien,
    pn.GhiChu,
    ncc.MaNCC,
    ncc.TenNCC,
    k.TenKho,
    nv.HoTen AS NguoiLap,
    ct.MaCTPN,
    sp.MaSP,
    sp.TenSP,
    sp.DonVi,
    ct.SoLuong,
    ct.DonGia,
    ct.ThanhTien
FROM PhieuNhap pn
    INNER JOIN NhaCungCap ncc ON pn.MaNCC = ncc.MaNCC
    INNER JOIN Kho k ON pn.MaKho = k.MaKho
    INNER JOIN NhanVien nv ON pn.MaNV = nv.MaNV
    LEFT JOIN CT_PhieuNhap ct ON pn.MaPN = ct.MaPN
    LEFT JOIN SanPham sp ON ct.MaSP = sp.MaSP;
GO

-- 5. View goods issue details
CREATE OR ALTER VIEW v_ChiTietPhieuXuat AS
SELECT
    px.MaPX,
    px.SoPhieu,
    px.NgayLap,
    px.NgayDuyet,
    px.TrangThai,
    px.TongTien,
    px.GhiChu,
    px.NguoiNhan,
    k.TenKho,
    nv.HoTen AS NguoiLap,
    ct.MaCTPX,
    sp.MaSP,
    sp.TenSP,
    sp.DonVi,
    ct.SoLuong,
    ct.DonGia,
    ct.ThanhTien
FROM PhieuXuat px
    INNER JOIN Kho k ON px.MaKho = k.MaKho
    INNER JOIN NhanVien nv ON px.MaNV = nv.MaNV
    LEFT JOIN CT_PhieuXuat ct ON px.MaPX = ct.MaPX
    LEFT JOIN SanPham sp ON ct.MaSP = sp.MaSP;
GO

-- 6. View monthly revenue/costs
CREATE OR ALTER VIEW v_DoanhThuTheoThang AS
SELECT
    YEAR(px.NgayLap) AS Nam,
    MONTH(px.NgayLap) AS Thang,
    COUNT(DISTINCT px.MaPX) AS SoPhieu,
    SUM(ct.SoLuong) AS TongSoLuong,
    SUM(ct.ThanhTien) AS TongDoanhThu
FROM PhieuXuat px
    INNER JOIN CT_PhieuXuat ct ON px.MaPX = ct.MaPX
WHERE px.TrangThai = N'ĐãDuyệt'
GROUP BY YEAR(px.NgayLap), MONTH(px.NgayLap);
GO

-- 7. View top exported products
CREATE OR ALTER VIEW v_TopSanPhamXuatNhieu AS
SELECT TOP 10
    sp.MaSP,
    sp.TenSP,
    sp.DonVi,
    dm.TenDanhMuc,
    SUM(ct.SoLuong) AS TongSoLuongXuat,
    SUM(ct.ThanhTien) AS TongGiaTriXuat
FROM CT_PhieuXuat ct
    INNER JOIN PhieuXuat px ON ct.MaPX = px.MaPX
    INNER JOIN SanPham sp ON ct.MaSP = sp.MaSP
    INNER JOIN DanhMuc dm ON sp.MaDanhMuc = dm.MaDanhMuc
WHERE px.TrangThai = N'ĐãDuyệt'
GROUP BY sp.MaSP, sp.TenSP, sp.DonVi, dm.TenDanhMuc
ORDER BY TongSoLuongXuat DESC;
GO

-- 8. View recent orders (top 10 newest)
CREATE OR ALTER VIEW v_PhieuGanDay AS
SELECT TOP 10 *
FROM (
    SELECT
        MaPN AS MaPhieu,
        SoPhieu,
        N'Nhập' AS LoaiPhieu,
        NgayLap,
        TrangThai,
        TongTien,
        (SELECT nv.HoTen FROM NhanVien nv WHERE nv.MaNV = pn.MaNV) AS NguoiLap
    FROM PhieuNhap pn

    UNION ALL

    SELECT
        MaPX AS MaPhieu,
        SoPhieu,
        N'Xuất' AS LoaiPhieu,
        NgayLap,
        TrangThai,
        TongTien,
        (SELECT nv.HoTen FROM NhanVien nv WHERE nv.MaNV = px.MaNV) AS NguoiLap
    FROM PhieuXuat px
) AS AllPhieu
ORDER BY NgayLap DESC;
GO

-- 9. View aggregate statistics for Dashboard cards
CREATE OR ALTER VIEW v_ThongKeTongQuat AS
SELECT
    (SELECT COUNT(*) FROM SanPham WHERE TrangThai = 1) AS TongSanPham,
    (SELECT COUNT(*) FROM NhaCungCap WHERE TrangThai = 1) AS TongNCC,
    (SELECT COUNT(*) FROM Kho WHERE TrangThai = 1) AS TongKho,
    (SELECT ISNULL(SUM(CAST(SoLuong * sp.GiaNhap AS DECIMAL(18,2))), 0)
     FROM TonKho tk INNER JOIN SanPham sp ON tk.MaSP = sp.MaSP) AS TongGiaTriTon,
    (SELECT COUNT(*) FROM v_SanPhamDuoiTonToiThieu) AS SoSPCanhBao,
    (SELECT COUNT(*) FROM PhieuNhap WHERE TrangThai = N'Nháp') AS PhieuNhapChuaDuyet,
    (SELECT COUNT(*) FROM PhieuXuat WHERE TrangThai = N'Nháp') AS PhieuXuatChuaDuyet;
GO

PRINT N'02_create-views.sql completed.';
GO
