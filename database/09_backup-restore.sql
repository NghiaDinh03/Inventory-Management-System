USE InventoryDB;
GO

-- =============================================
-- 1. STORED PROCEDURE: SAO LƯU CƠ SỞ DỮ LIỆU (BACKUP)
-- =============================================
CREATE OR ALTER PROCEDURE sp_BackupDatabase
    @BackupFolder NVARCHAR(500) = N'/var/opt/mssql/data/'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BackupFilePath NVARCHAR(1000);
    DECLARE @DateStr NVARCHAR(20);
    
    -- Tạo chuỗi thời gian yyyymmdd_hhmmss để phân biệt các bản backup
    SET @DateStr = CONVERT(NVARCHAR(20), GETDATE(), 112) + '_' + REPLACE(CONVERT(NVARCHAR(20), GETDATE(), 108), ':', '');
    SET @BackupFilePath = @BackupFolder + 'InventoryDB_Backup_' + @DateStr + '.bak';
    
    BEGIN TRY
        BACKUP DATABASE InventoryDB
        TO DISK = @BackupFilePath
        WITH FORMAT, INIT, NAME = N'InventoryDB Full Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10;
        
        -- Trả về thông tin file backup để Web UI sử dụng
        SELECT @BackupFilePath AS BackupFilePath, N'Thành công' AS TrangThai;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- =============================================
-- 2. STORED PROCEDURE TRÊN MASTER: PHỤC HỒI CƠ SỞ DỮ LIỆU (RESTORE)
-- Phục hồi database yêu cầu ngắt toàn bộ kết nối hiện tại đến DB đó.
-- Do đó, Stored Procedure này bắt buộc phải lưu trú ở hệ thống 'master'.
-- =============================================
USE master;
GO

CREATE OR ALTER PROCEDURE sp_RestoreDatabase
    @BackupFilePath NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- 1. Đưa database về chế độ đơn người dùng và ngắt kết nối ngay lập tức các phiên hiện tại
        ALTER DATABASE InventoryDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        
        -- 2. Thực hiện phục hồi từ đường dẫn file backup
        RESTORE DATABASE InventoryDB
        FROM DISK = @BackupFilePath
        WITH REPLACE, STATS = 10;
        
        -- 3. Trả database về chế độ đa người dùng bình thường
        ALTER DATABASE InventoryDB SET MULTI_USER;
        
        SELECT N'Thành công' AS TrangThai, @BackupFilePath AS RestoredFromFile;
    END TRY
    BEGIN CATCH
        -- Nếu xảy ra lỗi giữa chừng, cố gắng trả DB về MULTI_USER để tránh deadlock / khoá cứng DB
        IF EXISTS (SELECT * FROM sys.databases WHERE name = 'InventoryDB')
        BEGIN
            ALTER DATABASE InventoryDB SET MULTI_USER;
        END
        THROW;
    END CATCH
END;
GO
