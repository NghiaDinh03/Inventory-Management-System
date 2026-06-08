USE InventoryDB;
GO

-- =============================================
-- 1. SCALAR FUNCTION: TÍNH TỒN KHO CỦA SẢN PHẨM TẠI KHO
-- =============================================
CREATE OR ALTER FUNCTION fn_TinhTonKho (
    @MaSP INT,
    @MaKho INT
)
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT = 0;
    
    SELECT @SoLuong = COALESCE(SoLuong, 0)
    FROM TonKho
    WHERE MaSP = @MaSP AND MaKho = @MaKho;
    
    RETURN @SoLuong;
END;
GO

-- =============================================
-- 2. SCALAR FUNCTION: TÍNH TỔNG GIÁ TRỊ TỒN KHO CỦA MỘT KHO
-- =============================================
CREATE OR ALTER FUNCTION fn_TinhGiaTriTonKho (
    @MaKho INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongGiaTri DECIMAL(18,2) = 0;
    
    SELECT @TongGiaTri = COALESCE(SUM(tk.SoLuong * sp.GiaNhap), 0)
    FROM TonKho tk
    JOIN SanPham sp ON tk.MaSP = sp.MaSP
    WHERE tk.MaKho = @MaKho;
    
    RETURN @TongGiaTri;
END;
GO

-- =============================================
-- 3. SCALAR FUNCTION: TÍNH GIÁ XUẤT BÌNH QUÂN GIA QUYỀN
-- =============================================
CREATE OR ALTER FUNCTION fn_TinhGiaXuatBinhQuan (
    @MaSP INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @GiaBinhQuan DECIMAL(18,2) = 0;
    
    SELECT @GiaBinhQuan = COALESCE(SUM(ct.SoLuong * ct.DonGia) / NULLIF(SUM(ct.SoLuong), 0), 0)
    FROM CT_PhieuNhap ct
    JOIN PhieuNhap pn ON ct.MaPN = pn.MaPN
    WHERE ct.MaSP = @MaSP AND pn.TrangThai = N'ĐãDuyệt';
    
    -- Nếu chưa từng nhập hàng (hoặc chưa duyệt phiếu nào), lấy giá nhập mặc định từ bảng SanPham
    IF @GiaBinhQuan = 0
    BEGIN
        SELECT @GiaBinhQuan = COALESCE(GiaNhap, 0)
        FROM SanPham
        WHERE MaSP = @MaSP;
    END
    
    RETURN @GiaBinhQuan;
END;
GO

-- =============================================
-- 4. TABLE-VALUED FUNCTION: DANH SÁCH SẢN PHẨM THEO KHO
-- =============================================
CREATE OR ALTER FUNCTION fn_LayDanhSachSPTheoKho (
    @MaKho INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        sp.MaSP,
        sp.TenSP,
        sp.DonVi,
        COALESCE(tk.SoLuong, 0) AS SoLuong,
        sp.GiaNhap
    FROM SanPham sp
    LEFT JOIN TonKho tk ON sp.MaSP = tk.MaSP AND tk.MaKho = @MaKho
    WHERE sp.TrangThai = 1
);
GO

-- =============================================
-- 5. TABLE-VALUED FUNCTION: TỔNG NHẬP XUẤT TRONG KỲ THEO NGÀY
-- =============================================
CREATE OR ALTER FUNCTION fn_TongNhapXuatTrongKy (
    @TuNgay DATE,
    @DenNgay DATE
)
RETURNS TABLE
AS
RETURN (
    WITH Dates AS (
        -- Tạo danh sách các ngày trong khoảng từ TuNgay đến DenNgay
        SELECT @TuNgay AS Ngay
        UNION ALL
        SELECT DATEADD(DAY, 1, Ngay)
        FROM Dates
        WHERE Ngay < @DenNgay
    ),
    Nhap AS (
        SELECT 
            CAST(NgayLap AS DATE) AS Ngay,
            SUM(TongTien) AS TongNhap
        FROM PhieuNhap
        WHERE TrangThai = N'ĐãDuyệt' AND CAST(NgayLap AS DATE) BETWEEN @TuNgay AND @DenNgay
        GROUP BY CAST(NgayLap AS DATE)
    ),
    Xuat AS (
        SELECT 
            CAST(NgayLap AS DATE) AS Ngay,
            SUM(TongTien) AS TongXuat
        FROM PhieuXuat
        WHERE TrangThai = N'ĐãDuyệt' AND CAST(NgayLap AS DATE) BETWEEN @TuNgay AND @DenNgay
        GROUP BY CAST(NgayLap AS DATE)
    )
    SELECT 
        d.Ngay,
        COALESCE(n.TongNhap, 0) AS TongNhap,
        COALESCE(x.TongXuat, 0) AS TongXuat
    FROM Dates d
    LEFT JOIN Nhap n ON d.Ngay = n.Ngay
    LEFT JOIN Xuat x ON d.Ngay = x.Ngay
);
GO
