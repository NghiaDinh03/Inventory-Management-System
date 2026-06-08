USE InventoryDB;
GO

-- =============================================
-- 1. STORED PROCEDURE WRAPPING CURSOR: CẢNH BÁO SẢN PHẨM DƯỚI TỒN TỐI THIỂU
-- =============================================
CREATE OR ALTER PROCEDURE sp_CursorCanhBaoTon
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Bảng tạm chứa kết quả cảnh báo để trả về cho Client / Web UI
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
            
    -- Khai báo Cursor duyệt qua các sản phẩm có số lượng tồn dưới mức tối thiểu
    DECLARE cur_CanhBao CURSOR LOCAL FAST_FORWARD FOR
    SELECT tk.MaSP, sp.TenSP, k.TenKho, tk.SoLuong, sp.TonToiThieu
    FROM TonKho tk
    JOIN SanPham sp ON tk.MaSP = sp.MaSP
    JOIN Kho k ON tk.MaKho = k.MaKho
    WHERE tk.SoLuong < sp.TonToiThieu;
    
    OPEN cur_CanhBao;
    FETCH NEXT FROM cur_CanhBao INTO @MaSP, @TenSP, @TenKho, @SoLuong, @TonToiThieu;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Ghi thông tin cảnh báo vào bảng tạm
        INSERT INTO @Result (MaSP, TenSP, TenKho, SoLuong, TonToiThieu, CanhBao)
        VALUES (
            @MaSP, 
            @TenSP, 
            @TenKho, 
            @SoLuong, 
            @TonToiThieu, 
            CONCAT(N'Cảnh báo: Sản phẩm [', @TenSP, N'] tại kho [', @TenKho, N'] có số lượng tồn hiện tại là ', @SoLuong, N', dưới mức tối thiểu là ', @TonToiThieu, N'!')
        );
        
        -- In thông báo ra cửa sổ Messages của SQL Server (đáp ứng đúng yêu cầu của Cursor truyền thống)
        PRINT CONCAT(N'Cảnh báo: Sản phẩm [', @TenSP, N'] tại kho [', @TenKho, N'] có số lượng tồn hiện tại là ', @SoLuong, N', dưới mức tối thiểu là ', @TonToiThieu, N'!');
        
        FETCH NEXT FROM cur_CanhBao INTO @MaSP, @TenSP, @TenKho, @SoLuong, @TonToiThieu;
    END;
    
    CLOSE cur_CanhBao;
    DEALLOCATE cur_CanhBao;
    
    -- Trả về tập kết quả để Web UI có thể hiển thị
    SELECT * FROM @Result;
END;
GO

-- =============================================
-- 2. STORED PROCEDURE WRAPPING CURSOR: TÍNH TỒN KHO CUỐI KỲ CỦA CÁC SẢN PHẨM
-- =============================================
CREATE OR ALTER PROCEDURE sp_CursorTonCuoiKy
    @MaKho INT = NULL,
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Bảng tạm chứa kết quả báo cáo
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
            
    -- Khai báo Cursor duyệt qua toàn bộ các mặt hàng đang có trong từng kho
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
        -- 1. Lấy tồn kho hiện tại làm điểm tựa
        DECLARE @TonHienTai INT = 0;
        SELECT @TonHienTai = SoLuong FROM TonKho WHERE MaSP = @CurMaSP AND MaKho = @CurMaKho;
        
        -- 2. Tính số lượng đã nhập kể từ TuNgay đến hiện tại
        DECLARE @NhapSauTuNgay INT = 0;
        SELECT @NhapSauTuNgay = COALESCE(SUM(ct.SoLuong), 0)
        FROM CT_PhieuNhap ct
        JOIN PhieuNhap pn ON ct.MaPN = pn.MaPN
        WHERE pn.TrangThai = N'ĐãDuyệt' 
          AND pn.MaKho = @CurMaKho 
          AND ct.MaSP = @CurMaSP 
          AND CAST(pn.NgayDuyet AS DATE) >= @TuNgay;
          
        -- 3. Tính số lượng đã xuất kể từ TuNgay đến hiện tại
        DECLARE @XuatSauTuNgay INT = 0;
        SELECT @XuatSauTuNgay = COALESCE(SUM(ct.SoLuong), 0)
        FROM CT_PhieuXuat ct
        JOIN PhieuXuat px ON ct.MaPX = px.MaPX
        WHERE px.TrangThai = N'ĐãDuyệt' 
          AND px.MaKho = @CurMaKho 
          AND ct.MaSP = @CurMaSP 
          AND CAST(px.NgayDuyet AS DATE) >= @TuNgay;
          
        -- 4. Tính số lượng nhập trong kỳ (giữa TuNgay và DenNgay)
        DECLARE @NhapTrongKy INT = 0;
        SELECT @NhapTrongKy = COALESCE(SUM(ct.SoLuong), 0)
        FROM CT_PhieuNhap ct
        JOIN PhieuNhap pn ON ct.MaPN = pn.MaPN
        WHERE pn.TrangThai = N'ĐãDuyệt' 
          AND pn.MaKho = @CurMaKho 
          AND ct.MaSP = @CurMaSP 
          AND CAST(pn.NgayDuyet AS DATE) BETWEEN @TuNgay AND @DenNgay;
          
        -- 5. Tính số lượng xuất trong kỳ (giữa TuNgay và DenNgay)
        DECLARE @XuatTrongKy INT = 0;
        SELECT @XuatTrongKy = COALESCE(SUM(ct.SoLuong), 0)
        FROM CT_PhieuXuat ct
        JOIN PhieuXuat px ON ct.MaPX = px.MaPX
        WHERE px.TrangThai = N'ĐãDuyệt' 
          AND px.MaKho = @CurMaKho 
          AND ct.MaSP = @CurMaSP 
          AND CAST(px.NgayDuyet AS DATE) BETWEEN @TuNgay AND @DenNgay;
          
        -- 6. Tính ngược về tồn đầu kỳ
        DECLARE @TonDauKy INT = @TonHienTai - @NhapSauTuNgay + @XuatSauTuNgay;
        
        -- 7. Tính tồn cuối kỳ
        DECLARE @TonCuoiKy INT = @TonDauKy + @NhapTrongKy - @XuatTrongKy;
        
        -- Đưa kết quả vào bảng tạm
        INSERT INTO @Result (MaKho, TenKho, MaSP, TenSP, DonVi, TonDauKy, NhapTrongKy, XuatTrongKy, TonCuoiKy)
        VALUES (@CurMaKho, @CurTenKho, @CurMaSP, @CurTenSP, @CurDonVi, @TonDauKy, @NhapTrongKy, @XuatTrongKy, @TonCuoiKy);
        
        FETCH NEXT FROM cur_TonKho INTO @CurMaKho, @CurTenKho, @CurMaSP, @CurTenSP, @CurDonVi;
    END;
    
    CLOSE cur_TonKho;
    DEALLOCATE cur_TonKho;
    
    -- Trả ra kết quả
    SELECT * FROM @Result ORDER BY TenKho, TenSP;
END;
GO
