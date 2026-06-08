USE master;
GO

-- 1. Create server logins
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ims_admin_login')
BEGIN
    CREATE LOGIN ims_admin_login WITH PASSWORD = 'Admin_login_password_2026', DEFAULT_DATABASE = InventoryDB;
END;
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ims_nvkho_login')
BEGIN
    CREATE LOGIN ims_nvkho_login WITH PASSWORD = 'Nvkho_login_password_2026', DEFAULT_DATABASE = InventoryDB;
END;
GO

-- 2. Create users for InventoryDB
USE InventoryDB;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ims_admin')
BEGIN
    CREATE USER ims_admin FOR LOGIN ims_admin_login;
END;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ims_nvkho')
BEGIN
    CREATE USER ims_nvkho FOR LOGIN ims_nvkho_login;
END;
GO

-- 3. Create database roles
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_ims_admin' AND type = 'R')
BEGIN
    CREATE ROLE db_ims_admin;
END;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_ims_nvkho' AND type = 'R')
BEGIN
    CREATE ROLE db_ims_nvkho;
END;
GO

-- 4. Grant permissions for Admin role
GRANT ALTER, CONTROL, INSERT, UPDATE, DELETE, SELECT, EXECUTE TO db_ims_admin;
GO

-- 5. Grant permissions for Warehouse Staff role
GRANT SELECT TO db_ims_nvkho;
GO


GRANT EXECUTE ON sp_TaoPhieuNhap TO db_ims_nvkho;
GRANT EXECUTE ON sp_TaoPhieuXuat TO db_ims_nvkho;
GRANT EXECUTE ON sp_DuyetPhieu TO db_ims_nvkho;
GRANT EXECUTE ON sp_HuyPhieu TO db_ims_nvkho;
GRANT EXECUTE ON sp_BaoCaoTonKho TO db_ims_nvkho;
GRANT EXECUTE ON sp_BaoCaoNhapTheoNCC TO db_ims_nvkho;
GRANT EXECUTE ON sp_BaoCaoXuatTheoSP TO db_ims_nvkho;
GRANT EXECUTE ON sp_DoiMatKhau TO db_ims_nvkho;
GRANT EXECUTE ON sp_CursorCanhBaoTon TO db_ims_nvkho;
GRANT EXECUTE ON sp_CursorTonCuoiKy TO db_ims_nvkho;
GO

-- Deny direct DML operations on core tables (must go through SPs/Triggers)
DENY INSERT, UPDATE, DELETE ON TonKho TO db_ims_nvkho;
DENY INSERT, UPDATE, DELETE ON PhieuNhap TO db_ims_nvkho;
DENY INSERT, UPDATE, DELETE ON PhieuXuat TO db_ims_nvkho;
DENY INSERT, UPDATE, DELETE ON CT_PhieuNhap TO db_ims_nvkho;
DENY INSERT, UPDATE, DELETE ON CT_PhieuXuat TO db_ims_nvkho;
GO

-- 6. Add users to database roles
ALTER ROLE db_ims_admin ADD MEMBER ims_admin;

ALTER ROLE db_ims_nvkho ADD MEMBER ims_nvkho;
GO
