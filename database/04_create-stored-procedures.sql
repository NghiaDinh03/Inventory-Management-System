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

-- Create Table-Valued Parameter Type for Order Details
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

-- 1. SP: Create Purchase Order
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
        

        INSERT INTO PhieuNhap (MaNCC, MaKho, MaNV, TrangThai, GhiChu)
        VALUES (@MaNCC, @MaKho, @MaNV, N'Nháp', @GhiChu);
        
        SET @MaPN = SCOPE_IDENTITY();
        

        INSERT INTO CT_PhieuNhap (MaPN, MaSP, SoLuong, DonGia)
        SELECT @MaPN, MaSP, SoLuong, DonGia FROM @ChiTiet;
        
        COMMIT TRANSACTION;
        

        SELECT @MaPN AS MaPN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 2. SP: Create Goods Issue
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
        

        INSERT INTO PhieuXuat (MaKho, MaNV, NguoiNhan, TrangThai, GhiChu)
        VALUES (@MaKho, @MaNV, @NguoiNhan, N'Nháp', @GhiChu);
        
        SET @MaPX = SCOPE_IDENTITY();
        

        INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia)
        SELECT @MaPX, MaSP, SoLuong, DonGia FROM @ChiTiet;
        
        COMMIT TRANSACTION;
        

        SELECT @MaPX AS MaPX;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 3. SP: Approve Purchase Order or Goods Issue
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

            IF EXISTS (SELECT 1 FROM PhieuNhap WHERE MaPN = @MaPhieu AND TrangThai = N'ĐãDuyệt')
            BEGIN
                THROW 50001, N'Phiếu nhập này đã được duyệt trước đó.', 1;
            END
            

            UPDATE PhieuNhap
            SET TrangThai = N'ĐãDuyệt', 
                NgayDuyet = GETDATE(), 
                MaNV_Duyet = @MaNV
            WHERE MaPN = @MaPhieu;
        END
        ELSE IF @LoaiPhieu = 'PX'
        BEGIN

            IF EXISTS (SELECT 1 FROM PhieuXuat WHERE MaPX = @MaPhieu AND TrangThai = N'ĐãDuyệt')
            BEGIN
                THROW 50002, N'Phiếu xuất này đã được duyệt trước đó.', 1;
            END
            

            UPDATE PhieuXuat
            SET TrangThai = N'ĐãDuyệt', 
                NgayDuyet = GETDATE(), 
                MaNV_Duyet = @MaNV
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

-- 4. SP: Cancel Purchase Order or Goods Issue
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
            

            UPDATE PhieuNhap
            SET TrangThai = N'ĐãHủy', 
                GhiChu = CONCAT(GhiChu, N' | Lý do hủy: ', @LyDo),
                MaNV_Duyet = @MaNV
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
            

            UPDATE PhieuXuat
            SET TrangThai = N'ĐãHủy', 
                GhiChu = CONCAT(GhiChu, N' | Lý do hủy: ', @LyDo),
                MaNV_Duyet = @MaNV
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

-- 5. SP: Detailed Stock Report
CREATE OR ALTER PROCEDURE sp_BaoCaoTonKho
    @MaKho INT = NULL,
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;
    

    WITH CurrentStock AS (
        SELECT 
            tk.MaKho,
            k.TenKho,
            tk.MaSP,
            sp.TenSP,
            sp.DonVi,
            tk.SoLuongTon AS TonHienTai,
            COALESCE((SELECT TOP 1 DonGiaNhap FROM Gia g WHERE g.MaSP = sp.MaSP ORDER BY g.NgayLap DESC), 0) AS GiaNhap
        FROM TonKho tk
        JOIN SanPham sp ON tk.MaSP = sp.MaSP
        JOIN Kho k ON tk.MaKho = k.MaKho
        WHERE (@MaKho IS NULL OR tk.MaKho = @MaKho)
    ),
    -- Total imported qty from @TuNgay to present
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
    -- Total exported qty from @TuNgay to present
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
    -- Imports within period
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
    -- Exports within period
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
        -- Opening Qty = Current - Imports to Date + Exports to Date
        (cs.TonHienTai - COALESCE(ns.SLNhap, 0) + COALESCE(xs.SLXuat, 0)) AS TonDauKy,
        COALESCE(ntk.SLNhap, 0) AS NhapTrongKy,
        COALESCE(xtk.SLXuat, 0) AS XuatTrongKy,
        -- Closing Qty = Opening + Period Imports - Period Exports
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

-- 6. SP: Purchase Report by Supplier
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

-- 7. SP: Goods Issue Report by Product
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

-- 8. SP: Change Account Password
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

-- 9. SP: Write stock transaction ledger (anti-deadlock append-only design)
CREATE OR ALTER PROCEDURE sp_GhiGiaoDichKho
    @MaSP INT,
    @MaKho INT,
    @MaBin INT,
    @MaLo INT,
    @LoaiGiaoDich NVARCHAR(30),
    @MaPhieuThamChieu VARCHAR(30),
    @SoLuongThayDoi INT,
    @MaNV INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @SoLuongSauThayDoi INT = 0;
        
        -- Get current stock in the specific bin-lot
        SELECT @SoLuongSauThayDoi = COALESCE(SoLuong, 0)
        FROM TonKhoTheoBin
        WHERE MaSP = @MaSP AND MaBin = @MaBin AND MaLo = @MaLo;
        
        SET @SoLuongSauThayDoi = @SoLuongSauThayDoi + @SoLuongThayDoi;
        
        IF @SoLuongSauThayDoi < 0
        BEGIN
            THROW 50012, N'Lỗi: Số lượng tồn kho theo vị trí không được âm.', 1;
        END
        
        -- Update the static stock-by-bin table
        IF EXISTS (SELECT 1 FROM TonKhoTheoBin WHERE MaSP = @MaSP AND MaBin = @MaBin AND MaLo = @MaLo)
        BEGIN
            UPDATE TonKhoTheoBin
            SET SoLuong = @SoLuongSauThayDoi
            WHERE MaSP = @MaSP AND MaBin = @MaBin AND MaLo = @MaLo;
        END
        ELSE
        BEGIN
            INSERT INTO TonKhoTheoBin (MaSP, MaBin, MaLo, SoLuong, NgayNhapBin)
            VALUES (@MaSP, @MaBin, @MaLo, @SoLuongSauThayDoi, GETDATE());
        END
        
        -- Insert ledger transaction record
        INSERT INTO GiaoDichKho (MaSP, MaKho, MaBin, MaLo, LoaiGiaoDich, MaPhieuThamChieu, SoLuongThayDoi, SoLuongSauThayDoi, MaNV, ThoiGian)
        VALUES (@MaSP, @MaKho, @MaBin, @MaLo, @LoaiGiaoDich, @MaPhieuThamChieu, @SoLuongThayDoi, @SoLuongSauThayDoi, @MaNV, GETDATE());
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 10. SP: Putaway stock to physical location (checking weight & volume)
CREATE OR ALTER PROCEDURE sp_PutawayStock
    @MaSP INT,
    @MaLo INT,
    @MaBin INT,
    @SoLuong INT,
    @MaNV INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @MaKho INT;
        DECLARE @TrongLuongSP DECIMAL(10,3);
        
        SELECT @MaKho = MaKho FROM BinLocation WHERE MaBin = @MaBin;
        SELECT @TrongLuongSP = TrongLuong FROM SanPham WHERE MaSP = @MaSP;
        
        IF @MaKho IS NULL
        BEGIN
            THROW 50013, N'Lỗi: Vị trí kệ không tồn tại.', 1;
        END
        
        -- Check remaining weight capability
        DECLARE @TrongLuongConLai DECIMAL(10,2);
        SELECT @TrongLuongConLai = dbo.fn_TinhTrongLuongConLai(@MaBin);
        
        IF @TrongLuongConLai < (@SoLuong * @TrongLuongSP)
        BEGIN
            THROW 50014, N'Lỗi: Vị trí ô kệ này đã quá tải, không thể xếp thêm hàng.', 1;
        END
        
        -- Write to ledger using sp_GhiGiaoDichKho
        EXEC sp_GhiGiaoDichKho 
            @MaSP = @MaSP,
            @MaKho = @MaKho,
            @MaBin = @MaBin,
            @MaLo = @MaLo,
            @LoaiGiaoDich = N'NhậpKho',
            @MaPhieuThamChieu = 'PUTAWAY-AUTO',
            @SoLuongThayDoi = @SoLuong,
            @MaNV = @MaNV;
            
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 11. SP: Cycle count/physical stock audit
CREATE OR ALTER PROCEDURE sp_KiemKeCuonChieu
    @MaPKK INT,
    @MaBin INT,
    @MaSP INT,
    @MaLo INT,
    @SoLuongThucTe INT,
    @MaNV INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @SoLuongHeThong INT = 0;
        DECLARE @MaKho INT;
        
        SELECT @MaKho = MaKho FROM BinLocation WHERE MaBin = @MaBin;
        
        SELECT @SoLuongHeThong = COALESCE(SoLuong, 0)
        FROM TonKhoTheoBin
        WHERE MaSP = @MaSP AND MaBin = @MaBin AND MaLo = @MaLo;
        
        DECLARE @SoLuongLech INT = @SoLuongThucTe - @SoLuongHeThong;
        
        -- Insert details
        INSERT INTO CT_PhieuKiemKe (MaPKK, MaSP, MaBin, MaLo, SoLuongHeThong, SoLuongThucTe, LyDoLech)
        VALUES (@MaPKK, @MaSP, @MaBin, @MaLo, @SoLuongHeThong, @SoLuongThucTe, 
                CASE WHEN @SoLuongLech = 0 THEN N'Khớp số liệu' ELSE N'Lệch thừa/thiếu khi kiểm kê' END);
                
        -- Adjust stock in ledger if there is deviation
        IF @SoLuongLech <> 0
        BEGIN
            EXEC sp_GhiGiaoDichKho
                @MaSP = @MaSP,
                @MaKho = @MaKho,
                @MaBin = @MaBin,
                @MaLo = @MaLo,
                @LoaiGiaoDich = N'KiểmKê',
                @MaPhieuThamChieu = 'ADJUST-STOCK',
                @SoLuongThayDoi = @SoLuongLech,
                @MaNV = @MaNV;
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

PRINT N'04_create-stored-procedures.sql completed.';
GO

