USE master;
GO

-- =============================================
-- 1. TẠO CÁC LOGINS Ở MỨC SERVER (NẾU CHƯA TỒN TẠI)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ims_admin_login')
BEGIN
    CREATE LOGIN ims_admin_login WITH PASSWORD = 'AdminLogin@2026', DEFAULT_DATABASE = InventoryDB;
END;
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ims_nvkho_login')
BEGIN
    CREATE LOGIN ims_nvkho_login WITH PASSWORD = 'NVKhoLogin@2026', DEFAULT_DATABASE = InventoryDB;
END;
GO

-- =============================================
-- 2. TẠO CÁC USERS CHO CƠ SỞ DỮ LIỆU INVENTORYDB
-- =============================================
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

-- =============================================
-- 3. TẠO CÁC DATABASE ROLES (VAI TRÒ TRONG CSDL)
-- =============================================
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

-- =============================================
-- 4. PHÂN QUYỀN CHO VAI TRÒ ADMIN (db_ims_admin)
-- =============================================
-- Admin được toàn quyền trên toàn bộ schema dbo
GRANT ALTER, CONTROL, INSERT, UPDATE, DELETE, SELECT, EXECUTE TO db_ims_admin;
GO

-- =============================================
-- 5. PHÂN QUYỀN CHO VAI TRÒ THỦ KHO (db_ims_nvkho)
-- =============================================
-- Cho phép đọc tất cả các bảng và views để hiển thị thông tin
GRANT SELECT TO db_ims_nvkho;
GO

-- Cho phép gọi các stored procedures nghiệp vụ và báo cáo
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

-- Từ chối việc THAY ĐỔI trực tiếp dữ liệu (INSERT, UPDATE, DELETE) trên các bảng cốt lõi
-- Nhân viên kho bắt buộc phải thao tác thông qua Stored Procedure và Trigger đã thiết lập
DENY INSERT, UPDATE, DELETE ON TonKho TO db_ims_nvkho;
DENY INSERT, UPDATE, DELETE ON PhieuNhap TO db_ims_nvkho;
DENY INSERT, UPDATE, DELETE ON PhieuXuat TO db_ims_nvkho;
DENY INSERT, UPDATE, DELETE ON CT_PhieuNhap TO db_ims_nvkho;
DENY INSERT, UPDATE, DELETE ON CT_PhieuXuat TO db_ims_nvkho;
GO

-- =============================================
-- 6. THÊM USERS VÀO ROLES TƯƠNG ỨNG
-- =============================================
-- Thêm ims_admin vào nhóm db_ims_admin
ALTER ROLE db_ims_admin ADD MEMBER ims_admin;
-- Thêm ims_nvkho vào nhóm db_ims_nvkho
ALTER ROLE db_ims_nvkho ADD MEMBER ims_nvkho;
GO
