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

-- =============================================
-- DANH MỤC
-- =============================================
CREATE TABLE DanhMuc (
    MaDanhMuc   INT IDENTITY(1,1) PRIMARY KEY,
    TenDanhMuc  NVARCHAR(100) NOT NULL UNIQUE,
    MoTa        NVARCHAR(300) NULL
);
GO

-- =============================================
-- NHÀ CUNG CẤP
-- =============================================
CREATE TABLE NhaCungCap (
    MaNCC       INT IDENTITY(1,1) PRIMARY KEY,
    TenNCC      NVARCHAR(200) NOT NULL,
    DiaChi      NVARCHAR(300) NULL,
    SoDienThoai VARCHAR(20)   NULL,
    Email       VARCHAR(100)  NULL,
    NguoiLienHe NVARCHAR(100) NULL,
    TrangThai   BIT DEFAULT 1
);
GO

-- =============================================
-- KHO
-- =============================================
CREATE TABLE Kho (
    MaKho       INT IDENTITY(1,1) PRIMARY KEY,
    TenKho      NVARCHAR(100) NOT NULL,
    DiaChi      NVARCHAR(300) NULL,
    TrangThai   BIT DEFAULT 1
);
GO

-- =============================================
-- SẢN PHẨM
-- =============================================
CREATE TABLE SanPham (
    MaSP        INT IDENTITY(1,1) PRIMARY KEY,
    TenSP       NVARCHAR(200) NOT NULL,
    MaDanhMuc   INT NOT NULL,
    DonVi       NVARCHAR(50) NOT NULL,
    MaVach      VARCHAR(50) NULL UNIQUE,
    GiaNhap     DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (GiaNhap >= 0),
    GiaBan      DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (GiaBan >= 0),
    TonToiThieu INT DEFAULT 10,
    HinhAnh     NVARCHAR(500) NULL,
    MoTa        NVARCHAR(500) NULL,
    TrangThai   BIT DEFAULT 1,
    NgayTao     DATETIME DEFAULT GETDATE(),
    NgayCapNhat DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_SanPham_DanhMuc FOREIGN KEY (MaDanhMuc) REFERENCES DanhMuc(MaDanhMuc)
);
GO

CREATE NONCLUSTERED INDEX IX_SanPham_TenSP ON SanPham(TenSP);
CREATE NONCLUSTERED INDEX IX_SanPham_MaVach ON SanPham(MaVach) WHERE MaVach IS NOT NULL;
GO

-- =============================================
-- NHÂN VIÊN
-- =============================================
CREATE TABLE NhanVien (
    MaNV        INT IDENTITY(1,1) PRIMARY KEY,
    HoTen       NVARCHAR(100) NOT NULL,
    ChucVu      NVARCHAR(50) NULL,
    SoDienThoai VARCHAR(20) NULL,
    Email       VARCHAR(100) NULL,
    TrangThai   BIT DEFAULT 1
);
GO

-- =============================================
-- TÀI KHOẢN
-- =============================================
CREATE TABLE TaiKhoan (
    MaTK        INT IDENTITY(1,1) PRIMARY KEY,
    TenDangNhap VARCHAR(50) NOT NULL UNIQUE,
    MatKhau     VARCHAR(256) NOT NULL,
    MaNV        INT NOT NULL UNIQUE,
    VaiTro      VARCHAR(20) NOT NULL CHECK (VaiTro IN ('Admin', 'NVKho')),
    TrangThai   BIT DEFAULT 1,

    CONSTRAINT FK_TaiKhoan_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

-- =============================================
-- PHIẾU NHẬP
-- =============================================
CREATE TABLE PhieuNhap (
    MaPN        INT IDENTITY(1,1) PRIMARY KEY,
    SoPhieu     VARCHAR(20) NULL UNIQUE,
    NgayLap     DATETIME NOT NULL DEFAULT GETDATE(),
    NgayDuyet   DATETIME NULL,
    MaNCC       INT NOT NULL,
    MaKho       INT NOT NULL,
    MaNV        INT NOT NULL,
    TrangThai   NVARCHAR(20) NOT NULL DEFAULT N'Nháp',
    TongTien    DECIMAL(18,2) DEFAULT 0,
    GhiChu      NVARCHAR(500) NULL,

    CONSTRAINT FK_PhieuNhap_NCC FOREIGN KEY (MaNCC) REFERENCES NhaCungCap(MaNCC),
    CONSTRAINT FK_PhieuNhap_Kho FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
    CONSTRAINT FK_PhieuNhap_NV  FOREIGN KEY (MaNV)  REFERENCES NhanVien(MaNV),
    CONSTRAINT CK_PhieuNhap_TrangThai CHECK (TrangThai IN (N'Nháp', N'ĐãDuyệt', N'ĐãHủy'))
);
GO

CREATE NONCLUSTERED INDEX IX_PhieuNhap_NgayLap ON PhieuNhap(NgayLap);
GO

-- =============================================
-- CHI TIẾT PHIẾU NHẬP
-- =============================================
CREATE TABLE CT_PhieuNhap (
    MaCTPN      INT IDENTITY(1,1) PRIMARY KEY,
    MaPN        INT NOT NULL,
    MaSP        INT NOT NULL,
    SoLuong     INT NOT NULL CHECK (SoLuong > 0),
    DonGia      DECIMAL(18,2) NOT NULL CHECK (DonGia >= 0),
    ThanhTien   AS (SoLuong * DonGia) PERSISTED,

    CONSTRAINT FK_CTPN_PhieuNhap FOREIGN KEY (MaPN) REFERENCES PhieuNhap(MaPN) ON DELETE CASCADE,
    CONSTRAINT FK_CTPN_SanPham   FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

CREATE NONCLUSTERED INDEX IX_CTPN_MaPN ON CT_PhieuNhap(MaPN);
GO

-- =============================================
-- PHIẾU XUẤT
-- =============================================
CREATE TABLE PhieuXuat (
    MaPX        INT IDENTITY(1,1) PRIMARY KEY,
    SoPhieu     VARCHAR(20) NULL UNIQUE,
    NgayLap     DATETIME NOT NULL DEFAULT GETDATE(),
    NgayDuyet   DATETIME NULL,
    MaKho       INT NOT NULL,
    MaNV        INT NOT NULL,
    NguoiNhan   NVARCHAR(200) NULL,
    TrangThai   NVARCHAR(20) NOT NULL DEFAULT N'Nháp',
    TongTien    DECIMAL(18,2) DEFAULT 0,
    GhiChu      NVARCHAR(500) NULL,

    CONSTRAINT FK_PhieuXuat_Kho FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
    CONSTRAINT FK_PhieuXuat_NV  FOREIGN KEY (MaNV)  REFERENCES NhanVien(MaNV),
    CONSTRAINT CK_PhieuXuat_TrangThai CHECK (TrangThai IN (N'Nháp', N'ĐãDuyệt', N'ĐãHủy'))
);
GO

CREATE NONCLUSTERED INDEX IX_PhieuXuat_NgayLap ON PhieuXuat(NgayLap);
GO

-- =============================================
-- CHI TIẾT PHIẾU XUẤT
-- =============================================
CREATE TABLE CT_PhieuXuat (
    MaCTPX      INT IDENTITY(1,1) PRIMARY KEY,
    MaPX        INT NOT NULL,
    MaSP        INT NOT NULL,
    SoLuong     INT NOT NULL CHECK (SoLuong > 0),
    DonGia      DECIMAL(18,2) NOT NULL CHECK (DonGia >= 0),
    ThanhTien   AS (SoLuong * DonGia) PERSISTED,

    CONSTRAINT FK_CTPX_PhieuXuat FOREIGN KEY (MaPX) REFERENCES PhieuXuat(MaPX) ON DELETE CASCADE,
    CONSTRAINT FK_CTPX_SanPham   FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

CREATE NONCLUSTERED INDEX IX_CTPX_MaPX ON CT_PhieuXuat(MaPX);
GO

-- =============================================
-- TỒN KHO
-- =============================================
CREATE TABLE TonKho (
    MaTonKho    INT IDENTITY(1,1) PRIMARY KEY,
    MaSP        INT NOT NULL,
    MaKho       INT NOT NULL,
    SoLuong     INT NOT NULL DEFAULT 0 CHECK (SoLuong >= 0),

    CONSTRAINT FK_TonKho_SanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
    CONSTRAINT FK_TonKho_Kho     FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
    CONSTRAINT UQ_TonKho_SP_Kho  UNIQUE (MaSP, MaKho)
);
GO

-- =============================================
-- LỊCH SỬ HOẠT ĐỘNG
-- =============================================
CREATE TABLE LichSuHoatDong (
    MaLog           BIGINT IDENTITY(1,1) PRIMARY KEY,
    BangLienQuan    VARCHAR(50) NOT NULL,
    MaBanGhi        INT NOT NULL,
    HanhDong        VARCHAR(10) NOT NULL,
    NoiDungCu       NVARCHAR(MAX) NULL,
    NoiDungMoi      NVARCHAR(MAX) NULL,
    MaNV            INT NULL,
    ThoiGian        DATETIME DEFAULT GETDATE()
);
GO

PRINT N'01_create-tables.sql hoàn tất.';
GO
