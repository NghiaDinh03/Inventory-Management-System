USE InventoryDB;
GO

-- =============================================
-- TẠO TABLE-VALUED PARAMETER TYPE CHO CHI TIẾT PHIẾU
-- =============================================
IF EXISTS (SELECT * FROM sys.types WHERE name = 'ChiTietPhieuType' AND is_table_type = 1)
BEGIN
    DROP TYPE ChiTietPhieuType;
END;
GO

CREATE TYPE ChiTietPhieuType AS TABLE (
    MaSP INT,
    SoLuong INT,
    DonGia DECIMAL(18,2)
);
GO

-- =============================================
-- 1. STORED PROCEDURE: TẠO PHIẾU NHẬP
-- =============================================
CREATE OR ALTER PROCEDURE sp_TaoPhieuNhap
    @MaNCC INT,
    @MaKho INT,
    @MaNV INT,
    @GhiChu NVARCHAR(500),
    @ChiTiet ChiTietPhieuType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @MaPN INT;
        
        -- Thêm phiếu nhập mới ở trạng thái Nháp
        INSERT INTO PhieuNhap (MaNCC, MaKho, MaNV, TrangThai, GhiChu)
        VALUES (@MaNCC, @MaKho, @MaNV, N'Nháp', @GhiChu);
        
        SET @MaPN = SCOPE_IDENTITY();
        
        -- Thêm các dòng chi tiết phiếu nhập
        INSERT INTO CT_PhieuNhap (MaPN, MaSP, SoLuong, DonGia)
        SELECT @MaPN, MaSP, SoLuong, DonGia FROM @ChiTiet;
        
        COMMIT TRANSACTION;
        
        -- Trả về ID của phiếu nhập vừa tạo
        SELECT @MaPN AS MaPN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- 2. STORED PROCEDURE: TẠO PHIẾU XUẤT
-- =============================================
CREATE OR ALTER PROCEDURE sp_TaoPhieuXuat
    @MaKho INT,
    @MaNV INT,
    @NguoiNhan NVARCHAR(200),
    @GhiChu NVARCHAR(500),
    @ChiTiet ChiTietPhieuType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @MaPX INT;
        
        -- Thêm phiếu xuất mới ở trạng thái Nháp
        INSERT INTO PhieuXuat (MaKho, MaNV, NguoiNhan, TrangThai, GhiChu)
        VALUES (@MaKho, @MaNV, @NguoiNhan, N'Nháp', @GhiChu);
        
        SET @MaPX = SCOPE_IDENTITY();
        
        -- Thêm các dòng chi tiết phiếu xuất
        INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia)
        SELECT @MaPX, MaSP, SoLuong, DonGia FROM @ChiTiet;
        
        COMMIT TRANSACTION;
        
        -- Trả về ID của phiếu xuất vừa tạo
        SELECT @MaPX AS MaPX;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- 3. STORED PROCEDURE: DUYỆT PHIẾU (NHẬP/XUẤT)
-- =============================================
CREATE OR ALTER PROCEDURE sp_DuyetPhieu
    @LoaiPhieu VARCHAR(2), -- 'PN' hoặc 'PX'
    @MaPhieu INT,
    @MaNV INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF @LoaiPhieu = 'PN'
        BEGIN
            -- Kiểm tra xem đã duyệt chưa
            IF EXISTS (SELECT 1 FROM PhieuNhap WHERE MaPN = @MaPhieu AND TrangThai = N'ĐãDuyệt')
            BEGIN
                THROW 50001, N'Phiếu nhập này đã được duyệt trước đó.', 1;
            END
            
            -- Cập nhật trạng thái phiếu nhập
            UPDATE PhieuNhap
            SET TrangThai = N'ĐãDuyệt', 
                NgayDuyet = GETDATE(), 
                MaNV = @MaNV
            WHERE MaPN = @MaPhieu;
        END
        ELSE IF @LoaiPhieu = 'PX'
        BEGIN
            -- Kiểm tra xem đã duyệt chưa
            IF EXISTS (SELECT 1 FROM PhieuXuat WHERE MaPX = @MaPhieu AND TrangThai = N'ĐãDuyệt')
            BEGIN
                THROW 50002, N'Phiếu xuất này đã được duyệt trước đó.', 1;
            END
            
            -- Cập nhật trạng thái phiếu xuất
            UPDATE PhieuXuat
            SET TrangThai = N'ĐãDuyệt', 
                NgayDuyet = GETDATE(), 
                MaNV = @MaNV
            WHERE MaPX = @MaPhieu;
        END
        ELSE
        BEGIN
            THROW 50003, N'Loại phiếu không hợp lệ (chỉ chấp nhận PN hoặc PX).', 1;
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- 4. STORED PROCEDURE: HỦY PHIỆU (NHẬP/XUẤT)
-- =============================================
CREATE OR ALTER PROCEDURE sp_HuyPhieu
    @LoaiPhieu VARCHAR(2), -- 'PN' hoặc 'PX'
    @MaPhieu INT,
    @MaNV INT,
    @LyDo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF @LoaiPhieu = 'PN'
        BEGIN
            DECLARE @PNTrangThai NVARCHAR(20);
            SELECT @PNTrangThai = TrangThai FROM PhieuNhap WHERE MaPN = @MaPhieu;
            
            IF @PNTrangThai IS NULL
            BEGIN
                THROW 50004, N'Phiếu nhập không tồn tại.', 1;
            END
            IF @PNTrangThai = N'ĐãHủy'
            BEGIN
                THROW 50005, N'Phiếu nhập này đã bị hủy trước đó.', 1;
            END
            
            -- Cập nhật trạng thái phiếu nhập sang ĐãHủy
            UPDATE PhieuNhap
            SET TrangThai = N'ĐãHủy', 
                GhiChu = CONCAT(GhiChu, N' | Lý do hủy: ', @LyDo),
                MaNV = @MaNV
            WHERE MaPN = @MaPhieu;
        END
        ELSE IF @LoaiPhieu = 'PX'
        BEGIN
            DECLARE @PXTrangThai NVARCHAR(20);
            SELECT @PXTrangThai = TrangThai FROM PhieuXuat WHERE MaPX = @MaPhieu;
            
            IF @PXTrangThai IS NULL
            BEGIN
                THROW 50007, N'Phiếu xuất không tồn tại.', 1;
            END
            IF @PXTrangThai = N'ĐãHủy'
            BEGIN
                THROW 50008, N'Phiếu xuất này đã bị hủy trước đó.', 1;
            END
            
            -- Cập nhật trạng thái phiếu xuất sang ĐãHủy
            UPDATE PhieuXuat
            SET TrangThai = N'ĐãHủy', 
                GhiChu = CONCAT(GhiChu, N' | Lý do hủy: ', @LyDo),
                MaNV = @MaNV
            WHERE MaPX = @MaPhieu;
        END
        ELSE
        BEGIN
            THROW 50009, N'Loại phiếu không hợp lệ.', 1;
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- 5. STORED PROCEDURE: BÁO CÁO TỒN KHO CHI TIẾT
-- =============================================
CREATE OR ALTER PROCEDURE sp_BaoCaoTonKho
    @MaKho INT = NULL,
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Lấy tồn kho hiện tại làm mốc
    WITH CurrentStock AS (
        SELECT 
            tk.MaKho,
            k.TenKho,
            tk.MaSP,
            sp.TenSP,
            sp.DonVi,
            tk.SoLuong AS TonHienTai,
            sp.GiaNhap
        FROM TonKho tk
        JOIN SanPham sp ON tk.MaSP = sp.MaSP
        JOIN Kho k ON tk.MaKho = k.MaKho
        WHERE (@MaKho IS NULL OR tk.MaKho = @MaKho)
    ),
    -- Tổng số lượng nhập tính từ mốc TuNgay đến thời điểm hiện tại
    NhapSauTuNgay AS (
        SELECT 
            pn.MaKho,
            ct.MaSP,
            SUM(ct.SoLuong) AS SLNhap
        FROM CT_PhieuNhap ct
        JOIN PhieuNhap pn ON ct.MaPN = pn.MaPN
        WHERE pn.TrangThai = N'ĐãDuyệt' AND CAST(pn.NgayDuyet AS DATE) >= @TuNgay
        GROUP BY pn.MaKho, ct.MaSP
    ),
    -- Tổng số lượng xuất tính từ mốc TuNgay đến thời điểm hiện tại
    XuatSauTuNgay AS (
        SELECT 
            px.MaKho,
            ct.MaSP,
            SUM(ct.SoLuong) AS SLXuat
        FROM CT_PhieuXuat ct
        JOIN PhieuXuat px ON ct.MaPX = px.MaPX
        WHERE px.TrangThai = N'ĐãDuyệt' AND CAST(px.NgayDuyet AS DATE) >= @TuNgay
        GROUP BY px.MaKho, ct.MaSP
    ),
    -- Nhập trong kỳ (từ TuNgay đến DenNgay)
    NhapTrongKy AS (
        SELECT 
            pn.MaKho,
            ct.MaSP,
            SUM(ct.SoLuong) AS SLNhap
        FROM CT_PhieuNhap ct
        JOIN PhieuNhap pn ON ct.MaPN = pn.MaPN
        WHERE pn.TrangThai = N'ĐãDuyệt' AND CAST(pn.NgayDuyet AS DATE) BETWEEN @TuNgay AND @DenNgay
        GROUP BY pn.MaKho, ct.MaSP
    ),
    -- Xuất trong kỳ (từ TuNgay đến DenNgay)
    XuatTrongKy AS (
        SELECT 
            px.MaKho,
            ct.MaSP,
            SUM(ct.SoLuong) AS SLXuat
        FROM CT_PhieuXuat ct
        JOIN PhieuXuat px ON ct.MaPX = px.MaPX
        WHERE px.TrangThai = N'ĐãDuyệt' AND CAST(px.NgayDuyet AS DATE) BETWEEN @TuNgay AND @DenNgay
        GROUP BY px.MaKho, ct.MaSP
    )
    SELECT 
        cs.MaKho,
        cs.TenKho,
        cs.MaSP,
        cs.TenSP,
        cs.DonVi,
        -- Tồn đầu kỳ = Tồn hiện tại - Nhập từ mốc TuNgay đến nay + Xuất từ mốc TuNgay đến nay
        (cs.TonHienTai - COALESCE(ns.SLNhap, 0) + COALESCE(xs.SLXuat, 0)) AS TonDauKy,
        COALESCE(ntk.SLNhap, 0) AS NhapTrongKy,
        COALESCE(xtk.SLXuat, 0) AS XuatTrongKy,
        -- Tồn cuối kỳ = Tồn đầu kỳ + Nhập trong kỳ - Xuất trong kỳ
        (cs.TonHienTai - COALESCE(ns.SLNhap, 0) + COALESCE(xs.SLXuat, 0) + COALESCE(ntk.SLNhap, 0) - COALESCE(xtk.SLXuat, 0)) AS TonCuoiKy,
        cs.GiaNhap,
        ((cs.TonHienTai - COALESCE(ns.SLNhap, 0) + COALESCE(xs.SLXuat, 0) + COALESCE(ntk.SLNhap, 0) - COALESCE(xtk.SLXuat, 0)) * cs.GiaNhap) AS GiaTriCuoiKy
    FROM CurrentStock cs
    LEFT JOIN NhapSauTuNgay ns ON cs.MaKho = ns.MaKho AND cs.MaSP = ns.MaSP
    LEFT JOIN XuatSauTuNgay xs ON cs.MaKho = xs.MaKho AND cs.MaSP = xs.MaSP
    LEFT JOIN NhapTrongKy ntk ON cs.MaKho = ntk.MaKho AND cs.MaSP = ntk.MaSP
    LEFT JOIN XuatTrongKy xtk ON cs.MaKho = xtk.MaKho AND cs.MaSP = xtk.MaSP
    ORDER BY cs.TenKho, cs.TenSP;
END;
GO

-- =============================================
-- 6. STORED PROCEDURE: BÁO CÁO NHẬP HÀNG THEO NHÀ CUNG CẤP
-- =============================================
CREATE OR ALTER PROCEDURE sp_BaoCaoNhapTheoNCC
    @MaNCC INT = NULL,
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        pn.SoPhieu,
        pn.NgayLap,
        pn.NgayDuyet,
        ncc.TenNCC,
        k.TenKho,
        sp.TenSP,
        ct.SoLuong,
        ct.DonGia,
        ct.ThanhTien,
        nv.HoTen AS NguoiLap
    FROM CT_PhieuNhap ct
    JOIN PhieuNhap pn ON ct.MaPN = pn.MaPN
    JOIN NhaCungCap ncc ON pn.MaNCC = ncc.MaNCC
    JOIN Kho k ON pn.MaKho = k.MaKho
    JOIN SanPham sp ON ct.MaSP = sp.MaSP
    JOIN NhanVien nv ON pn.MaNV = nv.MaNV
    WHERE pn.TrangThai = N'ĐãDuyệt'
      AND (@MaNCC IS NULL OR pn.MaNCC = @MaNCC)
      AND CAST(pn.NgayDuyet AS DATE) BETWEEN @TuNgay AND @DenNgay
    ORDER BY pn.NgayDuyet DESC, pn.SoPhieu;
END;
GO

-- =============================================
-- 7. STORED PROCEDURE: BÁO CÁO XUẤT HÀNG THEO SẢN PHẨM
-- =============================================
CREATE OR ALTER PROCEDURE sp_BaoCaoXuatTheoSP
    @MaSP INT = NULL,
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        px.SoPhieu,
        px.NgayLap,
        px.NgayDuyet,
        k.TenKho,
        sp.TenSP,
        ct.SoLuong,
        ct.DonGia,
        ct.ThanhTien,
        px.NguoiNhan,
        nv.HoTen AS NguoiLap
    FROM CT_PhieuXuat ct
    JOIN PhieuXuat px ON ct.MaPX = px.MaPX
    JOIN Kho k ON px.MaKho = k.MaKho
    JOIN SanPham sp ON ct.MaSP = sp.MaSP
    JOIN NhanVien nv ON px.MaNV = nv.MaNV
    WHERE px.TrangThai = N'ĐãDuyệt'
      AND (@MaSP IS NULL OR ct.MaSP = @MaSP)
      AND CAST(px.NgayDuyet AS DATE) BETWEEN @TuNgay AND @DenNgay
    ORDER BY px.NgayDuyet DESC, px.SoPhieu;
END;
GO

-- =============================================
-- 8. STORED PROCEDURE: ĐỔI MẬT KHẨU
-- =============================================
CREATE OR ALTER PROCEDURE sp_DoiMatKhau
    @MaTK INT,
    @MatKhauCu VARCHAR(256),
    @MatKhauMoi VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MatKhauHienTai VARCHAR(256);
    SELECT @MatKhauHienTai = MatKhau FROM TaiKhoan WHERE MaTK = @MaTK;
    
    IF @MatKhauHienTai IS NULL
    BEGIN
        THROW 50010, N'Tài khoản không tồn tại.', 1;
    END
    
    IF @MatKhauHienTai != @MatKhauCu
    BEGIN
        THROW 50011, N'Mật khẩu cũ không chính xác.', 1;
    END
    
    UPDATE TaiKhoan
    SET MatKhau = @MatKhauMoi
    WHERE MaTK = @MaTK;
END;
GO
