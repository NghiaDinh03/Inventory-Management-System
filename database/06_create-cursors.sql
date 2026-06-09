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

-- 1. SP wrapping cursor: Alert on low stock
CREATE OR ALTER PROCEDURE sp_CursorCanhBaoTon
AS
BEGIN
    SET NOCOUNT ON;
    

    DECLARE @Result TABLE (
        MaSP INT,
        TenSP NVARCHAR(200),
        TenKho NVARCHAR(100),
        SoLuong INT,
        TonToiThieu INT,
        CanhBao NVARCHAR(500)
    );
    
    DECLARE @MaSP INT, 
            @TenSP NVARCHAR(200), 
            @TenKho NVARCHAR(100), 
            @SoLuong INT, 
            @TonToiThieu INT;
            
    -- Cursor for low stock products
    DECLARE cur_CanhBao CURSOR LOCAL FAST_FORWARD FOR
    SELECT tk.MaSP, sp.TenSP, k.TenKho, tk.SoLuongTon, sp.TonToiThieu
    FROM TonKho tk
    JOIN SanPham sp ON tk.MaSP = sp.MaSP
    JOIN Kho k ON tk.MaKho = k.MaKho
    WHERE tk.SoLuongTon < sp.TonToiThieu;
    
    OPEN cur_CanhBao;
    FETCH NEXT FROM cur_CanhBao INTO @MaSP, @TenSP, @TenKho, @SoLuong, @TonToiThieu;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN

        INSERT INTO @Result (MaSP, TenSP, TenKho, SoLuong, TonToiThieu, CanhBao)
        VALUES (
            @MaSP, 
            @TenSP, 
            @TenKho, 
            @SoLuong, 
            @TonToiThieu, 
            CONCAT(N'Cảnh báo: Sản phẩm [', @TenSP, N'] tại kho [', @TenKho, N'] có số lượng tồn hiện tại là ', @SoLuong, N', dưới mức tối thiểu là ', @TonToiThieu, N'!')
        );
        
        -- Print alert message to SQL Server Messages window
        PRINT CONCAT(N'Cảnh báo: Sản phẩm [', @TenSP, N'] tại kho [', @TenKho, N'] có số lượng tồn hiện tại là ', @SoLuong, N', dưới mức tối thiểu là ', @TonToiThieu, N'!');
        
        FETCH NEXT FROM cur_CanhBao INTO @MaSP, @TenSP, @TenKho, @SoLuong, @TonToiThieu;
    END;
    
    CLOSE cur_CanhBao;
    DEALLOCATE cur_CanhBao;
    

    SELECT * FROM @Result;
END;
GO

-- 2. SP wrapping cursor: Calculate closing stock
CREATE OR ALTER PROCEDURE sp_CursorTonCuoiKy
    @MaKho INT = NULL,
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;
    

    DECLARE @Result TABLE (
        MaKho INT,
        TenKho NVARCHAR(100),
        MaSP INT,
        TenSP NVARCHAR(200),
        DonVi NVARCHAR(50),
        TonDauKy INT,
        NhapTrongKy INT,
        XuatTrongKy INT,
        TonCuoiKy INT
    );
    
    DECLARE @CurMaKho INT, 
            @CurTenKho NVARCHAR(100), 
            @CurMaSP INT, 
            @CurTenSP NVARCHAR(200), 
            @CurDonVi NVARCHAR(50);
            
    -- Cursor for warehouse stock
    DECLARE cur_TonKho CURSOR LOCAL FAST_FORWARD FOR
    SELECT tk.MaKho, k.TenKho, tk.MaSP, sp.TenSP, sp.DonVi
    FROM TonKho tk
    JOIN Kho k ON tk.MaKho = k.MaKho
    JOIN SanPham sp ON tk.MaSP = sp.MaSP
    WHERE (@MaKho IS NULL OR tk.MaKho = @MaKho);
    
    OPEN cur_TonKho;
    FETCH NEXT FROM cur_TonKho INTO @CurMaKho, @CurTenKho, @CurMaSP, @CurTenSP, @CurDonVi;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN

        DECLARE @TonHienTai INT = 0;
        SELECT @TonHienTai = SoLuongTon FROM TonKho WHERE MaSP = @CurMaSP AND MaKho = @CurMaKho;
        
        -- 2. Calculate imported qty since @TuNgay to present
        DECLARE @NhapSauTuNgay INT = 0;
        SELECT @NhapSauTuNgay = COALESCE(SUM(ct.SoLuong), 0)
        FROM CT_PhieuNhap ct
        JOIN PhieuNhap pn ON ct.MaPN = pn.MaPN
        WHERE pn.TrangThai = N'ĐãDuyệt' 
          AND pn.MaKho = @CurMaKho 
          AND ct.MaSP = @CurMaSP 
          AND CAST(pn.NgayDuyet AS DATE) >= @TuNgay;
          
        -- 3. Calculate exported qty since @TuNgay to present
        DECLARE @XuatSauTuNgay INT = 0;
        SELECT @XuatSauTuNgay = COALESCE(SUM(ct.SoLuong), 0)
        FROM CT_PhieuXuat ct
        JOIN PhieuXuat px ON ct.MaPX = px.MaPX
        WHERE px.TrangThai = N'ĐãDuyệt' 
          AND px.MaKho = @CurMaKho 
          AND ct.MaSP = @CurMaSP 
          AND CAST(px.NgayDuyet AS DATE) >= @TuNgay;
          
        -- 4. Calculate period imports
        DECLARE @NhapTrongKy INT = 0;
        SELECT @NhapTrongKy = COALESCE(SUM(ct.SoLuong), 0)
        FROM CT_PhieuNhap ct
        JOIN PhieuNhap pn ON ct.MaPN = pn.MaPN
        WHERE pn.TrangThai = N'ĐãDuyệt' 
          AND pn.MaKho = @CurMaKho 
          AND ct.MaSP = @CurMaSP 
          AND CAST(pn.NgayDuyet AS DATE) BETWEEN @TuNgay AND @DenNgay;
          
        -- 5. Calculate period exports
        DECLARE @XuatTrongKy INT = 0;
        SELECT @XuatTrongKy = COALESCE(SUM(ct.SoLuong), 0)
        FROM CT_PhieuXuat ct
        JOIN PhieuXuat px ON ct.MaPX = px.MaPX
        WHERE px.TrangThai = N'ĐãDuyệt' 
          AND px.MaKho = @CurMaKho 
          AND ct.MaSP = @CurMaSP 
          AND CAST(px.NgayDuyet AS DATE) BETWEEN @TuNgay AND @DenNgay;
          
        -- 6. Calculate opening stock
        DECLARE @TonDauKy INT = @TonHienTai - @NhapSauTuNgay + @XuatSauTuNgay;
        
        -- 7. Calculate closing stock
        DECLARE @TonCuoiKy INT = @TonDauKy + @NhapTrongKy - @XuatTrongKy;
        

        INSERT INTO @Result (MaKho, TenKho, MaSP, TenSP, DonVi, TonDauKy, NhapTrongKy, XuatTrongKy, TonCuoiKy)
        VALUES (@CurMaKho, @CurTenKho, @CurMaSP, @CurTenSP, @CurDonVi, @TonDauKy, @NhapTrongKy, @XuatTrongKy, @TonCuoiKy);
        
        FETCH NEXT FROM cur_TonKho INTO @CurMaKho, @CurTenKho, @CurMaSP, @CurTenSP, @CurDonVi;
    END;
    
    CLOSE cur_TonKho;
    DEALLOCATE cur_TonKho;
    

    SELECT * FROM @Result ORDER BY TenKho, TenSP;
END;
GO
