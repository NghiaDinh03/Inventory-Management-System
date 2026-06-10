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

-- 1. Trigger: Tự động tính trọng lượng chi tiết phiếu nhập khi thêm/sửa
CREATE OR ALTER TRIGGER trg_CTPhieuNhap_TinhTrongLuong
ON CT_PhieuNhap
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE ct
    SET ct.TrongLuong = ct.SoLuong * sp.TrongLuong
    FROM CT_PhieuNhap ct
    INNER JOIN inserted i ON ct.MaCTPN = i.MaCTPN
    INNER JOIN SanPham sp ON ct.MaSP = sp.MaSP;
END;
GO

-- 2. Trigger: Tự động tính trọng lượng chi tiết phiếu xuất khi thêm/sửa
CREATE OR ALTER TRIGGER trg_CTPhieuXuat_TinhTrongLuong
ON CT_PhieuXuat
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE ct
    SET ct.TrongLuong = ct.SoLuong * sp.TrongLuong
    FROM CT_PhieuXuat ct
    INNER JOIN inserted i ON ct.MaCTPX = i.MaCTPX
    INNER JOIN SanPham sp ON ct.MaSP = sp.MaSP;
END;
GO

-- 3. Trigger: Tính tổng tiền phiếu nhập
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

-- 4. Trigger: Tính tổng tiền phiếu xuất
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

-- 5. Trigger: Tự động sinh số phiếu nhập
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

-- 6. Trigger: Tự động sinh số phiếu xuất
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

-- 7. Trigger: Chặn xóa sản phẩm khi đã phát sinh chứng từ
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
    
    -- Xóa liên kết tồn kho và liên kết NCC trước
    DELETE FROM TonKho WHERE MaSP IN (SELECT MaSP FROM deleted);
    DELETE FROM NCC_SanPham WHERE MaSP IN (SELECT MaSP FROM deleted);
    DELETE FROM Gia WHERE MaSP IN (SELECT MaSP FROM deleted);
    
    -- Xóa sản phẩm
    DELETE FROM SanPham WHERE MaSP IN (SELECT MaSP FROM deleted);
END;
GO

-- 8. Trigger: Cập nhật Số lượng tồn, Trọng lượng tồn và Giá nhập lịch sử khi duyệt/hủy phiếu nhập
CREATE OR ALTER TRIGGER trg_PhieuNhap_CapNhatTonKho
ON PhieuNhap
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Trường hợp 1: Duyệt phiếu nhập (Nháp -> ĐãDuyệt)
    IF EXISTS (
        SELECT 1 FROM inserted i JOIN deleted d ON i.MaPN = d.MaPN
        WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp'
    )
    BEGIN
        -- Cập nhật tồn kho hiện có
        UPDATE tk
        SET tk.SoLuongTon = tk.SoLuongTon + ct.SoLuong,
            tk.TrongLuongTon = tk.TrongLuongTon + (ct.SoLuong * sp.TrongLuong)
        FROM TonKho tk
        INNER JOIN CT_PhieuNhap ct ON tk.MaSP = ct.MaSP
        INNER JOIN SanPham sp ON ct.MaSP = sp.MaSP
        INNER JOIN inserted i ON ct.MaPN = i.MaPN
        INNER JOIN deleted d ON i.MaPN = d.MaPN
        WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp' AND tk.MaKho = i.MaKho;
        
        -- Tạo mới bản ghi tồn kho nếu sản phẩm chưa từng tồn tại ở kho này
        INSERT INTO TonKho (MaSP, MaKho, SoLuongTon, TrongLuongTon)
        SELECT ct.MaSP, i.MaKho, ct.SoLuong, (ct.SoLuong * sp.TrongLuong)
        FROM CT_PhieuNhap ct
        INNER JOIN SanPham sp ON ct.MaSP = sp.MaSP
        INNER JOIN inserted i ON ct.MaPN = i.MaPN
        INNER JOIN deleted d ON i.MaPN = d.MaPN
        WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp'
          AND NOT EXISTS (
              SELECT 1 FROM TonKho tk 
              WHERE tk.MaSP = ct.MaSP AND tk.MaKho = i.MaKho
          );

        -- Tự động chèn lịch sử giá nhập mới vào bảng Gia
        INSERT INTO Gia (MaSP, NgayLap, DonGiaNhap)
        SELECT ct.MaSP, GETDATE(), ct.DonGia
        FROM CT_PhieuNhap ct
        INNER JOIN inserted i ON ct.MaPN = i.MaPN
        INNER JOIN deleted d ON i.MaPN = d.MaPN
        WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp';
    END;
    
    -- Trường hợp 2: Hủy phiếu nhập đã duyệt (ĐãDuyệt -> ĐãHủy)
    IF EXISTS (
        SELECT 1 FROM inserted i JOIN deleted d ON i.MaPN = d.MaPN
        WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt'
    )
    BEGIN
        -- Kiểm tra xem nếu hủy thì tồn kho có bị âm không
        IF EXISTS (
            SELECT 1 
            FROM CT_PhieuNhap ct
            INNER JOIN inserted i ON ct.MaPN = i.MaPN
            INNER JOIN deleted d ON i.MaPN = d.MaPN
            INNER JOIN TonKho tk ON ct.MaSP = tk.MaSP AND tk.MaKho = i.MaKho
            WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt'
              AND (tk.SoLuongTon - ct.SoLuong) < 0
        )
        BEGIN
            RAISERROR (N'Không thể hủy phiếu nhập vì số lượng tồn kho sẽ bị âm.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Trừ tồn kho
        UPDATE tk
        SET tk.SoLuongTon = tk.SoLuongTon - ct.SoLuong,
            tk.TrongLuongTon = tk.TrongLuongTon - (ct.SoLuong * sp.TrongLuong)
        FROM TonKho tk
        INNER JOIN CT_PhieuNhap ct ON tk.MaSP = ct.MaSP
        INNER JOIN SanPham sp ON ct.MaSP = sp.MaSP
        INNER JOIN inserted i ON ct.MaPN = i.MaPN
        INNER JOIN deleted d ON i.MaPN = d.MaPN
        WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt' AND tk.MaKho = i.MaKho;
    END;
END;
GO

-- 9. Trigger: Cập nhật Số lượng tồn, Trọng lượng tồn khi duyệt/hủy phiếu xuất
CREATE OR ALTER TRIGGER trg_PhieuXuat_CapNhatTonKho
ON PhieuXuat
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Trường hợp 1: Duyệt phiếu xuất (Nháp -> ĐãDuyệt)
    IF EXISTS (
        SELECT 1 FROM inserted i JOIN deleted d ON i.MaPX = d.MaPX
        WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp'
    )
    BEGIN
        -- Kiểm tra xem đủ tồn kho để xuất không
        IF EXISTS (
            SELECT 1 
            FROM CT_PhieuXuat ct
            INNER JOIN inserted i ON ct.MaPX = i.MaPX
            INNER JOIN deleted d ON i.MaPX = d.MaPX
            LEFT JOIN TonKho tk ON ct.MaSP = tk.MaSP AND tk.MaKho = i.MaKho
            WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp'
              AND (tk.SoLuongTon IS NULL OR tk.SoLuongTon < ct.SoLuong)
        )
        BEGIN
            RAISERROR (N'Không đủ hàng tồn kho để xuất.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Trừ tồn kho
        UPDATE tk
        SET tk.SoLuongTon = tk.SoLuongTon - ct.SoLuong,
            tk.TrongLuongTon = tk.TrongLuongTon - (ct.SoLuong * sp.TrongLuong)
        FROM TonKho tk
        INNER JOIN CT_PhieuXuat ct ON tk.MaSP = ct.MaSP
        INNER JOIN SanPham sp ON ct.MaSP = sp.MaSP
        INNER JOIN inserted i ON ct.MaPX = i.MaPX
        INNER JOIN deleted d ON i.MaPX = d.MaPX
        WHERE i.TrangThai = N'ĐãDuyệt' AND d.TrangThai = N'Nháp' AND tk.MaKho = i.MaKho;
    END;
    
    -- Trường hợp 2: Hủy phiếu xuất đã duyệt (ĐãDuyệt -> ĐãHủy)
    IF EXISTS (
        SELECT 1 FROM inserted i JOIN deleted d ON i.MaPX = d.MaPX
        WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt'
    )
    BEGIN
        -- Cộng lại tồn kho
        UPDATE tk
        SET tk.SoLuongTon = tk.SoLuongTon + ct.SoLuong,
            tk.TrongLuongTon = tk.TrongLuongTon + (ct.SoLuong * sp.TrongLuong)
        FROM TonKho tk
        INNER JOIN CT_PhieuXuat ct ON tk.MaSP = ct.MaSP
        INNER JOIN SanPham sp ON ct.MaSP = sp.MaSP
        INNER JOIN inserted i ON ct.MaPX = i.MaPX
        INNER JOIN deleted d ON i.MaPX = d.MaPX
        WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt' AND tk.MaKho = i.MaKho;
        
        -- Thêm tồn kho mới nếu trước đó đã bị xóa (hiếm gặp nhưng vẫn phòng ngừa)
        INSERT INTO TonKho (MaSP, MaKho, SoLuongTon, TrongLuongTon)
        SELECT ct.MaSP, i.MaKho, ct.SoLuong, (ct.SoLuong * sp.TrongLuong)
        FROM CT_PhieuXuat ct
        INNER JOIN SanPham sp ON ct.MaSP = sp.MaSP
        INNER JOIN inserted i ON ct.MaPX = i.MaPX
        INNER JOIN deleted d ON i.MaPX = d.MaPX
        WHERE i.TrangThai = N'ĐãHủy' AND d.TrangThai = N'ĐãDuyệt'
          AND NOT EXISTS (
              SELECT 1 FROM TonKho tk 
              WHERE tk.MaSP = ct.MaSP AND tk.MaKho = i.MaKho
          );
    END;
END;
GO

-- 10. Trigger: Prevent UPDATE/DELETE on GiaoDichKho (Append-Only Transaction Ledger)
CREATE OR ALTER TRIGGER trg_GiaoDichKho_AppendOnly
ON GiaoDichKho
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    RAISERROR (N'Lỗi: Bảng sổ cái giao dịch GiaoDichKho chỉ được phép INSERT dữ liệu, không được phép sửa đổi hoặc xóa bỏ lịch sử.', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO

-- 11. Trigger: Auto-update BinLocation status based on stock level changes
CREATE OR ALTER TRIGGER trg_BinLocation_AutoStatus
ON TonKhoTheoBin
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update bin status to 'ĐangSửDụng' if count > 0
    UPDATE bl
    SET bl.TrangThai = N'ĐangSửDụng'
    FROM BinLocation bl
    INNER JOIN inserted i ON bl.MaBin = i.MaBin
    WHERE i.SoLuong > 0;
    
    -- Update bin status to 'Trống' if total stock in bin is 0
    UPDATE bl
    SET bl.TrangThai = N'Trống'
    FROM BinLocation bl
    INNER JOIN inserted i ON bl.MaBin = i.MaBin
    WHERE NOT EXISTS (
        SELECT 1 FROM TonKhoTheoBin
        WHERE MaBin = bl.MaBin AND SoLuong > 0
    );
END;
GO

PRINT N'05_create-triggers.sql completed.';
GO

