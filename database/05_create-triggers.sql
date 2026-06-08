USE InventoryDB;
GO

-- =============================================
-- 1. TRIGGER: CẬP NHẬT TỒN KHO SAU KHI NHẬP (TRÊN CT_PHIEUNHAP)
-- =============================================
CREATE OR ALTER TRIGGER trg_CapNhatTonKho_SauNhap
ON CT_PhieuNhap
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Chỉ cập nhật nếu phiếu nhập đã được duyệt
    UPDATE tk
    SET tk.SoLuong = tk.SoLuong + i.SoLuong
    FROM TonKho tk
    JOIN inserted i ON tk.MaSP = i.MaSP
    JOIN PhieuNhap pn ON i.MaPN = pn.MaPN
    WHERE pn.TrangThai = N'ĐãDuyệt' AND tk.MaKho = pn.MaKho;

    -- Thêm mới dòng TonKho nếu chưa tồn tại
    INSERT INTO TonKho (MaSP, MaKho, SoLuong)
    SELECT i.MaSP, pn.MaKho, i.SoLuong
    FROM inserted i
    JOIN PhieuNhap pn ON i.MaPN = pn.MaPN
    WHERE pn.TrangThai = N'ĐãDuyệt'
      AND NOT EXISTS (
          SELECT 1 FROM TonKho tk WHERE tk.MaSP = i.MaSP AND tk.MaKho = pn.MaKho
      );
END;
GO

-- =============================================
-- 2. TRIGGER: CẬP NHẬT TỒN KHO SAU KHI XUẤT (TRÊN CT_PHIEUXUAT)
-- =============================================
CREATE OR ALTER TRIGGER trg_XuatKho_KiemTraVaCapNhat
ON CT_PhieuXuat
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 1. Với phiếu chưa duyệt: INSERT bình thường, không kiểm tra tồn kho
    INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia)
    SELECT i.MaPX, i.MaSP, i.SoLuong, i.DonGia
    FROM inserted i
    JOIN PhieuXuat px ON i.MaPX = px.MaPX
    WHERE px.TrangThai != N'ĐãDuyệt';
    
    -- 2. Với phiếu đã duyệt: cần kiểm tra tồn kho và cập nhật trừ tồn kho
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN PhieuXuat px ON i.MaPX = px.MaPX
        WHERE px.TrangThai = N'ĐãDuyệt'
    )
    BEGIN
        -- Kiểm tra xem có mặt hàng nào bị thiếu hàng không
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN PhieuXuat px ON i.MaPX = px.MaPX
            LEFT JOIN TonKho tk ON i.MaSP = tk.MaSP AND px.MaKho = tk.MaKho
            WHERE px.TrangThai = N'ĐãDuyệt'
              AND (tk.SoLuong IS NULL OR tk.SoLuong < i.SoLuong)
        )
        BEGIN
            RAISERROR (N'Không đủ hàng tồn kho để xuất.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Thực hiện trừ tồn kho
        UPDATE tk
        SET tk.SoLuong = tk.SoLuong - i.SoLuong
        FROM TonKho tk
        JOIN inserted i ON tk.MaSP = i.MaSP
        JOIN PhieuXuat px ON i.MaPX = px.MaPX
        WHERE px.TrangThai = N'ĐãDuyệt' AND tk.MaKho = px.MaKho;
        
        -- INSERT chi tiết phiếu xuất vào bảng
        INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia)
        SELECT i.MaPX, i.MaSP, i.SoLuong, i.DonGia
        FROM inserted i
        JOIN PhieuXuat px ON i.MaPX = px.MaPX
        WHERE px.TrangThai = N'ĐãDuyệt';
    END;
END;
GO

-- =============================================
-- 3. TRIGGER: TỰ ĐỘNG CẬP NHẬT TỔNG TIỀN PHIẾU NHẬP
-- =============================================
CREATE OR ALTER TRIGGER trg_CapNhatTongTien_PN
ON CT_PhieuNhap
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE pn
    SET pn.TongTien = COALESCE((SELECT SUM(ct.ThanhTien) FROM CT_PhieuNhap ct WHERE ct.MaPN = pn.MaPN), 0)
    FROM PhieuNhap pn
    WHERE pn.MaPN IN (
        SELECT DISTINCT MaPN FROM inserted UNION SELECT DISTINCT MaPN FROM deleted
    );
END;
GO

-- =============================================
-- 4. TRIGGER: TỰ ĐỘNG CẬP NHẬT TỔNG TIỀN PHIẾU XUẤT
-- =============================================
CREATE OR ALTER TRIGGER trg_CapNhatTongTien_PX
ON CT_PhieuXuat
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE px
    SET px.TongTien = COALESCE((SELECT SUM(ct.ThanhTien) FROM CT_PhieuXuat ct WHERE ct.MaPX = px.MaPX), 0)
    FROM PhieuXuat px
    WHERE px.MaPX IN (
        SELECT DISTINCT MaPX FROM inserted UNION SELECT DISTINCT MaPX FROM deleted
    );
END;
GO

-- =============================================
-- 5. TRIGGER: TỰ ĐỘNG TẠO SỐ PHIẾU NHẬP
-- =============================================
CREATE OR ALTER TRIGGER trg_TaoSoPhieu_PN
ON PhieuNhap
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Year CHAR(4) = CAST(YEAR(GETDATE()) AS CHAR(4));
    DECLARE @Prefix VARCHAR(10) = 'PN-' + @Year + '-';
    
    UPDATE pn
    SET pn.SoPhieu = CONCAT(@Prefix, RIGHT('00000' + CAST(
        (SELECT COUNT(*) 
         FROM PhieuNhap p 
         WHERE p.SoPhieu LIKE @Prefix + '%' AND p.MaPN <= pn.MaPN) AS VARCHAR(5)), 5))
    FROM PhieuNhap pn
    JOIN inserted i ON pn.MaPN = i.MaPN
    WHERE pn.SoPhieu IS NULL OR pn.SoPhieu = '';
END;
GO

-- =============================================
-- 6. TRIGGER: TỰ ĐỘNG TẠO SỐ PHIẾU XUẤT
-- =============================================
CREATE OR ALTER TRIGGER trg_TaoSoPhieu_PX
ON PhieuXuat
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Year CHAR(4) = CAST(YEAR(GETDATE()) AS CHAR(4));
    DECLARE @Prefix VARCHAR(10) = 'PX-' + @Year + '-';
    
    UPDATE px
    SET px.SoPhieu = CONCAT(@Prefix, RIGHT('00000' + CAST(
        (SELECT COUNT(*) 
         FROM PhieuXuat p 
         WHERE p.SoPhieu LIKE @Prefix + '%' AND p.MaPX <= px.MaPX) AS VARCHAR(5)), 5))
    FROM PhieuXuat px
    JOIN inserted i ON px.MaPX = i.MaPX
    WHERE px.SoPhieu IS NULL OR px.SoPhieu = '';
END;
GO

-- =============================================
-- 7. TRIGGER: CHẶN XÓA SẢN PHẨM ĐÃ CÓ PHIẾU PHÁT SINH
-- =============================================
CREATE OR ALTER TRIGGER trg_ChanXoaSP_DaCoPhieu
ON SanPham
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM deleted d
        WHERE EXISTS (SELECT 1 FROM CT_PhieuNhap WHERE MaSP = d.MaSP)
           OR EXISTS (SELECT 1 FROM CT_PhieuXuat WHERE MaSP = d.MaSP)
    )
    BEGIN
        RAISERROR (N'Không thể xóa sản phẩm vì sản phẩm đã phát sinh trong các phiếu nhập/xuất kho.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    
    -- Xóa các dòng TonKho liên quan trước
    DELETE FROM TonKho WHERE MaSP IN (SELECT MaSP FROM deleted);
    
    -- Xóa sản phẩm
    DELETE FROM SanPham WHERE MaSP IN (SELECT MaSP FROM deleted);
END;
GO

-- =============================================
-- 8. TRIGGER: PHIẾU NHẬP - CẬP NHẬT TỒN KHO KHI DUYỆT/HỦY
-- =============================================
CREATE OR ALTER TRIGGER trg_PhieuNhap_CapNhatTonKho
ON PhieuNhap
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Case 1: Duyệt phiếu (Nháp -> ĐãDuyệt)
    IF EXISTS (
        SELECT 1 FROM inserted i JOIN deleted d ON i.MaPN = d.MaPN
        WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp'
    )
    BEGIN
        -- Cập nhật cộng tồn kho cho các bản ghi đã có
        UPDATE tk
        SET tk.SoLuong = tk.SoLuong + ct.SoLuong
        FROM TonKho tk
        JOIN CT_PhieuNhap ct ON tk.MaSP = ct.MaSP
        JOIN inserted i ON ct.MaPN = i.MaPN
        JOIN deleted d ON i.MaPN = d.MaPN
        WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp' AND tk.MaKho = i.MaKho;
        
        -- Chèn mới nếu chưa từng có tồn kho cho sản phẩm ở kho này
        INSERT INTO TonKho (MaSP, MaKho, SoLuong)
        SELECT ct.MaSP, i.MaKho, ct.SoLuong
        FROM CT_PhieuNhap ct
        JOIN inserted i ON ct.MaPN = i.MaPN
        JOIN deleted d ON i.MaPN = d.MaPN
        WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp'
          AND NOT EXISTS (
              SELECT 1 FROM TonKho tk 
              WHERE tk.MaSP = ct.MaSP AND tk.MaKho = i.MaKho
          );
    END;
    
    -- Case 2: Hủy phiếu (ĐãDuyệt -> ĐãHủy)
    IF EXISTS (
        SELECT 1 FROM inserted i JOIN deleted d ON i.MaPN = d.MaPN
        WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt'
    )
    BEGIN
        -- Kiểm tra xem trừ xong có âm không
        IF EXISTS (
            SELECT 1 
            FROM CT_PhieuNhap ct
            JOIN inserted i ON ct.MaPN = i.MaPN
            JOIN deleted d ON i.MaPN = d.MaPN
            JOIN TonKho tk ON ct.MaSP = tk.MaSP AND tk.MaKho = i.MaKho
            WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt'
              AND (tk.SoLuong - ct.SoLuong) < 0
        )
        BEGIN
            RAISERROR (N'Không thể hủy phiếu nhập vì số lượng tồn kho sẽ bị âm.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Trừ tồn kho
        UPDATE tk
        SET tk.SoLuong = tk.SoLuong - ct.SoLuong
        FROM TonKho tk
        JOIN CT_PhieuNhap ct ON tk.MaSP = ct.MaSP
        JOIN inserted i ON ct.MaPN = i.MaPN
        JOIN deleted d ON i.MaPN = d.MaPN
        WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt' AND tk.MaKho = i.MaKho;
    END;
END;
GO

-- =============================================
-- 9. TRIGGER: PHIẾU XUẤT - CẬP NHẬT TỒN KHO KHI DUYỆT/HỦY
-- =============================================
CREATE OR ALTER TRIGGER trg_PhieuXuat_CapNhatTonKho
ON PhieuXuat
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Case 1: Duyệt phiếu (Nháp -> ĐãDuyệt)
    IF EXISTS (
        SELECT 1 FROM inserted i JOIN deleted d ON i.MaPX = d.MaPX
        WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp'
    )
    BEGIN
        -- Kiểm tra xem đủ tồn kho không
        IF EXISTS (
            SELECT 1 
            FROM CT_PhieuXuat ct
            JOIN inserted i ON ct.MaPX = i.MaPX
            JOIN deleted d ON i.MaPX = d.MaPX
            LEFT JOIN TonKho tk ON ct.MaSP = tk.MaSP AND tk.MaKho = i.MaKho
            WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp'
              AND (tk.SoLuong IS NULL OR tk.SoLuong < ct.SoLuong)
        )
        BEGIN
            RAISERROR (N'Không đủ hàng tồn kho để xuất.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Trừ tồn kho
        UPDATE tk
        SET tk.SoLuong = tk.SoLuong - ct.SoLuong
        FROM TonKho tk
        JOIN CT_PhieuXuat ct ON tk.MaSP = ct.MaSP
        JOIN inserted i ON ct.MaPX = i.MaPX
        JOIN deleted d ON i.MaPX = d.MaPX
        WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp' AND tk.MaKho = i.MaKho;
    END;
    
    -- Case 2: Hủy phiếu (ĐãDuyệt -> ĐãHủy)
    IF EXISTS (
        SELECT 1 FROM inserted i JOIN deleted d ON i.MaPX = d.MaPX
        WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt'
    )
    BEGIN
        -- Cộng lại tồn kho
        UPDATE tk
        SET tk.SoLuong = tk.SoLuong + ct.SoLuong
        FROM TonKho tk
        JOIN CT_PhieuXuat ct ON tk.MaSP = ct.MaSP
        JOIN inserted i ON ct.MaPX = i.MaPX
        JOIN deleted d ON i.MaPX = d.MaPX
        WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt' AND tk.MaKho = i.MaKho;
        
        -- Chèn mới nếu chưa từng có tồn kho cho sản phẩm ở kho này (hiếm gặp nhưng đảm bảo an toàn)
        INSERT INTO TonKho (MaSP, MaKho, SoLuong)
        SELECT ct.MaSP, i.MaKho, ct.SoLuong
        FROM CT_PhieuXuat ct
        JOIN inserted i ON ct.MaPX = i.MaPX
        JOIN deleted d ON i.MaPX = d.MaPX
        WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt'
          AND NOT EXISTS (
              SELECT 1 FROM TonKho tk 
              WHERE tk.MaSP = ct.MaSP AND tk.MaKho = i.MaKho
          );
    END;
END;
GO
