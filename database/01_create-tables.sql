USE master;
GO

IF DB_ID('InventoryDB') IS NOT NULL
BEGIN
    ALTER DATABASE InventoryDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE InventoryDB;
END
GO

CREATE DATABASE InventoryDB;
GO

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

-- 1. Category table
CREATE TABLE DanhMucSanPham (
    MaDanhMucSP   INT IDENTITY(1,1) PRIMARY KEY,
    TenDanhMucSP  NVARCHAR(100) NOT NULL UNIQUE,
    MoTa        NVARCHAR(255) NULL
);
GO

-- 2. Supplier table
CREATE TABLE NhaCungCap (
    MaNCC       INT IDENTITY(1,1) PRIMARY KEY,
    TenNCC      NVARCHAR(100) NOT NULL,
    DiaChi      NVARCHAR(255) NULL,
    SoDienThoai VARCHAR(20)   NULL,
    Email       VARCHAR(100)  NULL,
    NguoiLienHe NVARCHAR(100) NULL,
    TrangThai   BIT DEFAULT 1
);
GO

-- 3. Warehouse table
CREATE TABLE Kho (
    MaKho       INT IDENTITY(1,1) PRIMARY KEY,
    TenKho      NVARCHAR(100) NOT NULL,
    DiaChi      NVARCHAR(300) NULL,
    TrangThai   BIT DEFAULT 1
);
GO

-- 4. Product table
CREATE TABLE SanPham (
    MaSP        INT IDENTITY(1,1) PRIMARY KEY,
    TenSP       NVARCHAR(200) NOT NULL,
    MaDanhMucSP   INT NOT NULL,
    TrongLuong  DECIMAL(10,3) NOT NULL DEFAULT 0 CHECK (TrongLuong >= 0),
    DonVi       NVARCHAR(50) NOT NULL,
    MaVach      VARCHAR(50) NULL UNIQUE,
    GiaNhap     DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (GiaNhap >= 0),
    GiaBan      DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (GiaBan >= 0),
    TonToiThieu INT DEFAULT 10,
    HinhAnh     NVARCHAR(255) NULL,
    MoTa        NVARCHAR(255) NULL,
    TrangThai   BIT DEFAULT 1,
    NgayTao     DATETIME DEFAULT GETDATE(),
    NgayCapNhat DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_SanPham_DanhMuc FOREIGN KEY (MaDanhMucSP) REFERENCES DanhMucSanPham(MaDanhMucSP)
);
GO

CREATE NONCLUSTERED INDEX IX_SanPham_TenSP ON SanPham(TenSP);
CREATE NONCLUSTERED INDEX IX_SanPham_MaVach ON SanPham(MaVach) WHERE MaVach IS NOT NULL;
GO

-- 5. Supplier Product link table
CREATE TABLE NCC_SanPham (
    MaNCC       INT NOT NULL,
    MaSP        INT NOT NULL,
    GiaNhap     DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (GiaNhap >= 0),
    NgayCapNhat DATETIME DEFAULT GETDATE(),

    CONSTRAINT PK_NCC_SanPham PRIMARY KEY (MaNCC, MaSP),
    CONSTRAINT FK_NCCSP_NCC FOREIGN KEY (MaNCC) REFERENCES NhaCungCap(MaNCC),
    CONSTRAINT FK_NCCSP_SP FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

-- 6. Employee table
CREATE TABLE NhanVien (
    MaNV        INT IDENTITY(1,1) PRIMARY KEY,
    HoTen       NVARCHAR(100) NOT NULL,
    ChucVu      NVARCHAR(50) NULL,
    SoDienThoai VARCHAR(20) NULL,
    NgaySinh    DATE NULL,
    CCCD        VARCHAR(12) NULL UNIQUE,
    NgayCap     DATE NULL,
    NoiCap      NVARCHAR(100) NULL,
    GioiTinh    BIT NULL,
    Email       VARCHAR(100) NULL,
    TrangThai   BIT DEFAULT 1
);
GO

-- 7. Role table
CREATE TABLE VaiTro (
    MaVT        INT IDENTITY(1,1) PRIMARY KEY,
    TenVaiTro   NVARCHAR(50) NOT NULL UNIQUE,
    MoTa        NVARCHAR(200) NULL,
    TrangThai   BIT DEFAULT 1
);
GO

-- 8. Account table
CREATE TABLE TaiKhoan (
    MaTK        INT IDENTITY(1,1) PRIMARY KEY,
    TenDangNhap VARCHAR(50) NOT NULL UNIQUE,
    MatKhau     VARCHAR(256) NOT NULL,
    MaNV        INT NOT NULL UNIQUE,
    MaVT        INT NOT NULL,
    TrangThai   BIT DEFAULT 1,

    CONSTRAINT FK_TaiKhoan_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_TaiKhoan_VaiTro FOREIGN KEY (MaVT) REFERENCES VaiTro(MaVT)
);
GO

-- 9. Purchase Order table
CREATE TABLE PhieuNhap (
    MaPN        INT IDENTITY(1,1) PRIMARY KEY,
    SoPhieu     VARCHAR(20) NULL UNIQUE,
    NgayLap     DATETIME NOT NULL DEFAULT GETDATE(),
    NgayDuyet   DATETIME NULL,
    MaNCC       INT NOT NULL,
    MaKho       INT NOT NULL,
    MaNV        INT NOT NULL,
    MaNV_Duyet  INT NULL,
    TrangThai   NVARCHAR(20) NOT NULL DEFAULT N'Nháp',
    TongTien    DECIMAL(18,2) DEFAULT 0,
    GhiChu      NVARCHAR(500) NULL,

    CONSTRAINT FK_PhieuNhap_NCC FOREIGN KEY (MaNCC) REFERENCES NhaCungCap(MaNCC),
    CONSTRAINT FK_PhieuNhap_Kho FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
    CONSTRAINT FK_PhieuNhap_NV  FOREIGN KEY (MaNV)  REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_PhieuNhap_NV_Duyet FOREIGN KEY (MaNV_Duyet) REFERENCES NhanVien(MaNV),
    CONSTRAINT CK_PhieuNhap_TrangThai CHECK (TrangThai IN (N'Nháp', N'ĐãDuyệt', N'ĐãHủy'))
);
GO

CREATE NONCLUSTERED INDEX IX_PhieuNhap_NgayLap ON PhieuNhap(NgayLap);
GO

-- 10. Purchase Order Details table
CREATE TABLE CT_PhieuNhap (
    MaCTPN      INT IDENTITY(1,1) PRIMARY KEY,
    MaPN        INT NOT NULL,
    MaSP        INT NOT NULL,
    SoLuong     INT NOT NULL CHECK (SoLuong > 0),
    TrongLuong  DECIMAL(10,3) NULL CHECK (TrongLuong >= 0),
    DonGia      DECIMAL(18,2) NOT NULL CHECK (DonGia >= 0),
    ThanhTien   AS (SoLuong * DonGia) PERSISTED,

    CONSTRAINT FK_CTPN_PhieuNhap FOREIGN KEY (MaPN) REFERENCES PhieuNhap(MaPN) ON DELETE CASCADE,
    CONSTRAINT FK_CTPN_SanPham   FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

CREATE NONCLUSTERED INDEX IX_CTPN_MaPN ON CT_PhieuNhap(MaPN);
GO

-- 11. Goods Issue table
CREATE TABLE PhieuXuat (
    MaPX        INT IDENTITY(1,1) PRIMARY KEY,
    SoPhieu     VARCHAR(20) NULL UNIQUE,
    NgayLap     DATETIME NOT NULL DEFAULT GETDATE(),
    NgayDuyet   DATETIME NULL,
    MaKho       INT NOT NULL,
    MaNV        INT NOT NULL,
    MaNV_Duyet  INT NULL,
    NguoiNhan   NVARCHAR(200) NULL,
    TrangThai   NVARCHAR(20) NOT NULL DEFAULT N'Nháp',
    TongTien    DECIMAL(18,2) DEFAULT 0,
    GhiChu      NVARCHAR(500) NULL,

    CONSTRAINT FK_PhieuXuat_Kho FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
    CONSTRAINT FK_PhieuXuat_NV  FOREIGN KEY (MaNV)  REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_PhieuXuat_NV_Duyet FOREIGN KEY (MaNV_Duyet) REFERENCES NhanVien(MaNV),
    CONSTRAINT CK_PhieuXuat_TrangThai CHECK (TrangThai IN (N'Nháp', N'ĐãDuyệt', N'ĐãHủy'))
);
GO

CREATE NONCLUSTERED INDEX IX_PhieuXuat_NgayLap ON PhieuXuat(NgayLap);
GO

-- 12. Goods Issue Details table
CREATE TABLE CT_PhieuXuat (
    MaCTPX      INT IDENTITY(1,1) PRIMARY KEY,
    MaPX        INT NOT NULL,
    MaSP        INT NOT NULL,
    SoLuong     INT NOT NULL CHECK (SoLuong > 0),
    TrongLuong  DECIMAL(10,3) NULL CHECK (TrongLuong >= 0),
    DonGia      DECIMAL(18,2) NOT NULL CHECK (DonGia >= 0),
    ThanhTien   AS (SoLuong * DonGia) PERSISTED,

    CONSTRAINT FK_CTPX_PhieuXuat FOREIGN KEY (MaPX) REFERENCES PhieuXuat(MaPX) ON DELETE CASCADE,
    CONSTRAINT FK_CTPX_SanPham   FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

CREATE NONCLUSTERED INDEX IX_CTPX_MaPX ON CT_PhieuXuat(MaPX);
GO

-- 13. Price History table
CREATE TABLE Gia (
    MaGia       INT IDENTITY(1,1) PRIMARY KEY,
    MaSP        INT NOT NULL,
    NgayLap     DATETIME DEFAULT GETDATE(),
    DonGiaNhap  DECIMAL(18,2) NOT NULL CHECK (DonGiaNhap >= 0),

    CONSTRAINT FK_Gia_SanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

-- 14. Stock table
CREATE TABLE TonKho (
    MaTonKho    INT IDENTITY(1,1) PRIMARY KEY,
    MaSP        INT NOT NULL,
    MaKho       INT NOT NULL,
    SoLuongTon  INT NOT NULL DEFAULT 0 CHECK (SoLuongTon >= 0),
    TrongLuongTon DECIMAL(12,3) NOT NULL DEFAULT 0 CHECK (TrongLuongTon >= 0),

    CONSTRAINT FK_TonKho_SanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
    CONSTRAINT FK_TonKho_Kho     FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
    CONSTRAINT UQ_TonKho_SP_Kho  UNIQUE (MaSP, MaKho)
);
GO

-- 15. Activity Log table
CREATE TABLE LichSuHoatDong (
    MaLog           BIGINT IDENTITY(1,1) PRIMARY KEY,
    BangLienQuan    VARCHAR(50) NOT NULL,
    MaBanGhi        INT NOT NULL,
    HanhDong        VARCHAR(10) NOT NULL,
    MaPhieu         VARCHAR(20) NULL,
    NoiDungCu       NVARCHAR(MAX) NULL,
    NoiDungMoi      NVARCHAR(MAX) NULL,
    MaNV            INT NULL,
    ThoiGian        DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_LichSuHoatDong_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

PRINT N'01_create-tables.sql completed.';
GO
