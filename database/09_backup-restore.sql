USE InventoryDB;
GO

-- 1. SP for backing up database
CREATE OR ALTER PROCEDURE sp_BackupDatabase
    @BackupFolder NVARCHAR(500) = N'/var/opt/mssql/data/'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BackupFilePath NVARCHAR(1000);
    DECLARE @DateStr NVARCHAR(20);
    
    -- Generate timestamp string
    SET @DateStr = CONVERT(NVARCHAR(20), GETDATE(), 112) + '_' + REPLACE(CONVERT(NVARCHAR(20), GETDATE(), 108), ':', '');
    SET @BackupFilePath = @BackupFolder + 'InventoryDB_Backup_' + @DateStr + '.bak';
    
    BEGIN TRY
        BACKUP DATABASE InventoryDB
        TO DISK = @BackupFilePath
        WITH FORMAT, INIT, NAME = N'InventoryDB Full Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10;
        
        -- Return backup info to Web UI
        SELECT @BackupFilePath AS BackupFilePath, N'Thành công' AS TrangThai;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- 2. SP on master database for restoring database
USE master;
GO

CREATE OR ALTER PROCEDURE sp_RestoreDatabase
    @BackupFilePath NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- 1. Force database to single-user mode to disconnect active sessions
        ALTER DATABASE InventoryDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        
        -- 2. Restore database from backup path
        RESTORE DATABASE InventoryDB
        FROM DISK = @BackupFilePath
        WITH REPLACE, STATS = 10;
        
        -- 3. Return database to multi-user mode
        ALTER DATABASE InventoryDB SET MULTI_USER;
        
        SELECT N'Thành công' AS TrangThai, @BackupFilePath AS RestoredFromFile;
    END TRY
    BEGIN CATCH
        -- Set to multi-user on error to prevent locking database
        IF EXISTS (SELECT * FROM sys.databases WHERE name = 'InventoryDB')
        BEGIN
            ALTER DATABASE InventoryDB SET MULTI_USER;
        END
        ;THROW;
    END CATCH
END;
GO
