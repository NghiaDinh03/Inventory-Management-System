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

CREATE TABLE DanhMucSanPham (
    MaDanhMucSP     INT             PRIMARY KEY IDENTITY(1,1),
    TenDanhMucSP    NVARCHAR(100)   NOT NULL UNIQUE,
    MoTa            NVARCHAR(255)   NULL
);

CREATE TABLE SanPham (
    MaSP            INT             PRIMARY KEY IDENTITY(1,1),
    TenSP           NVARCHAR(200)   NOT NULL,
    MaDanhMucSP     INT             NULL,
    TrongLuong      DECIMAL(10,3)   NOT NULL CHECK (TrongLuong >= 0),
    DonVi           NVARCHAR(50)    NOT NULL,
    MaVach          VARCHAR(50)     UNIQUE NULL,
    GiaBan          DECIMAL(18,2)   NULL CHECK (GiaBan >= 0),
    TonToiThieu     INT             DEFAULT 10,
    HinhAnh         NVARCHAR(255)   NULL,
    MoTa            NVARCHAR(255)   NULL,
    TrangThai       BIT             DEFAULT 1,
    NgayTao         DATETIME        DEFAULT GETDATE(),
    NgayCapNhat     DATETIME        DEFAULT GETDATE(),
    CONSTRAINT FK_SanPham_DanhMuc FOREIGN KEY (MaDanhMucSP)
        REFERENCES DanhMucSanPham(MaDanhMucSP)
);

CREATE TABLE NhaCungCap (
    MaNCC           INT             PRIMARY KEY IDENTITY(1,1),
    TenNCC          NVARCHAR(100)   NOT NULL,
    DiaChi          NVARCHAR(255)   NULL,
    SoDienThoai     VARCHAR(20)     NULL,
    Email           VARCHAR(100)    NULL,
    NguoiLienHe     NVARCHAR(100)   NULL,
    TrangThai       BIT             DEFAULT 1
);

CREATE TABLE Kho (
    MaKho           INT             PRIMARY KEY IDENTITY(1,1),
    TenKho          NVARCHAR(100)   NOT NULL,
    DiaChi          NVARCHAR(300)   NULL,
    TrangThai       BIT             DEFAULT 1
);

CREATE TABLE NCC_SanPham (
    MaNCC           INT             NOT NULL,
    MaSP            INT             NOT NULL,
    GiaNhap         DECIMAL(18,2)   NULL CHECK (GiaNhap >= 0),
    NgayCapNhat     DATETIME        DEFAULT GETDATE(),
    CONSTRAINT PK_NCC_SanPham PRIMARY KEY (MaNCC, MaSP),
    CONSTRAINT FK_NCCSP_NCC FOREIGN KEY (MaNCC)
        REFERENCES NhaCungCap(MaNCC),
    CONSTRAINT FK_NCCSP_SP FOREIGN KEY (MaSP)
        REFERENCES SanPham(MaSP)
);

CREATE TABLE NhanVien (
    MaNV            INT             PRIMARY KEY IDENTITY(1,1),
    HoTen           NVARCHAR(100)   NOT NULL,
    ChucVu          NVARCHAR(50)    NULL,
    SoDienThoai     VARCHAR(20)     NULL,
    NgaySinh        DATE            NULL,
    CCCD            VARCHAR(12)     UNIQUE NULL,
    NgayCap         DATE            NULL,
    NoiCap          NVARCHAR(100)   NULL,
    GioiTinh        BIT             NULL,
    Email           VARCHAR(100)    NULL,
    TrangThai       BIT             DEFAULT 1
);

CREATE TABLE VaiTro (
    MaVT            INT             PRIMARY KEY IDENTITY(1,1),
    TenVaiTro       NVARCHAR(50)    NOT NULL UNIQUE,
    MoTa            NVARCHAR(200)   NULL,
    TrangThai       BIT             DEFAULT 1
);

CREATE TABLE TaiKhoan (
    MaTK            INT             PRIMARY KEY IDENTITY(1,1),
    TenDangNhap     VARCHAR(50)     NOT NULL UNIQUE,
    MatKhau         VARCHAR(256)    NOT NULL,
    MaNV            INT             UNIQUE NULL,
    MaVT            INT             NOT NULL,
    TrangThai       BIT             DEFAULT 1,
    CONSTRAINT FK_TaiKhoan_NhanVien FOREIGN KEY (MaNV)
        REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_TaiKhoan_VaiTro FOREIGN KEY (MaVT)
        REFERENCES VaiTro(MaVT)
);

CREATE TABLE PhieuNhap (
    MaPN            INT             PRIMARY KEY IDENTITY(1,1),
    SoPhieu         VARCHAR(20)     UNIQUE NULL,
    NgayLap         DATETIME        DEFAULT GETDATE(),
    NgayDuyet       DATETIME        NULL,
    MaNCC           INT             NULL,
    MaKho           INT             NULL,
    MaNV            INT             NULL,
    MaNV_Duyet      INT             NULL,
    TrangThai       NVARCHAR(20)    DEFAULT N'Nháp',
    TongTien        DECIMAL(18,2)   DEFAULT 0,
    GhiChu          NVARCHAR(500)   NULL,
    CONSTRAINT FK_PhieuNhap_NCC FOREIGN KEY (MaNCC)
        REFERENCES NhaCungCap(MaNCC),
    CONSTRAINT FK_PhieuNhap_Kho FOREIGN KEY (MaKho)
        REFERENCES Kho(MaKho),
    CONSTRAINT FK_PhieuNhap_NV FOREIGN KEY (MaNV)
        REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_PhieuNhap_NVDuyet FOREIGN KEY (MaNV_Duyet)
        REFERENCES NhanVien(MaNV)
);

CREATE TABLE CT_PhieuNhap (
    MaCTPN          INT             PRIMARY KEY IDENTITY(1,1),
    MaPN            INT             NOT NULL,
    MaSP            INT             NOT NULL,
    SoLuong         INT             NOT NULL CHECK (SoLuong > 0),
    TrongLuong      DECIMAL(10,3)   NULL CHECK (TrongLuong >= 0),
    DonGia          DECIMAL(18,2)   NOT NULL CHECK (DonGia >= 0),
    ThanhTien       AS (SoLuong * DonGia) PERSISTED,
    CONSTRAINT FK_CTPN_PhieuNhap FOREIGN KEY (MaPN)
        REFERENCES PhieuNhap(MaPN) ON DELETE CASCADE,
    CONSTRAINT FK_CTPN_SanPham FOREIGN KEY (MaSP)
        REFERENCES SanPham(MaSP)
);

CREATE TABLE PhieuXuat (
    MaPX            INT             PRIMARY KEY IDENTITY(1,1),
    SoPhieu         VARCHAR(20)     UNIQUE NULL,
    NgayLap         DATETIME        DEFAULT GETDATE(),
    NgayDuyet       DATETIME        NULL,
    MaKho           INT             NULL,
    MaNV            INT             NULL,
    MaNV_Duyet      INT             NULL,
    NguoiNhan       NVARCHAR(200)   NULL,
    TrangThai       NVARCHAR(20)    DEFAULT N'Nháp',
    TongTien        DECIMAL(18,2)   DEFAULT 0,
    GhiChu          NVARCHAR(500)   NULL,
    CONSTRAINT FK_PhieuXuat_Kho FOREIGN KEY (MaKho)
        REFERENCES Kho(MaKho),
    CONSTRAINT FK_PhieuXuat_NV FOREIGN KEY (MaNV)
        REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_PhieuXuat_NVDuyet FOREIGN KEY (MaNV_Duyet)
        REFERENCES NhanVien(MaNV)
);

CREATE TABLE CT_PhieuXuat (
    MaCTPX          INT             PRIMARY KEY IDENTITY(1,1),
    MaPX            INT             NOT NULL,
    MaSP            INT             NOT NULL,
    SoLuong         INT             NOT NULL CHECK (SoLuong > 0),
    TrongLuong      DECIMAL(10,3)   NULL CHECK (TrongLuong >= 0),
    DonGia          DECIMAL(18,2)   NOT NULL CHECK (DonGia >= 0),
    ThanhTien       AS (SoLuong * DonGia) PERSISTED,
    CONSTRAINT FK_CTPX_PhieuXuat FOREIGN KEY (MaPX)
        REFERENCES PhieuXuat(MaPX) ON DELETE CASCADE,
    CONSTRAINT FK_CTPX_SanPham FOREIGN KEY (MaSP)
        REFERENCES SanPham(MaSP)
);

CREATE TABLE Gia (
    MaGia           INT             PRIMARY KEY IDENTITY(1,1),
    MaSP            INT             NOT NULL,
    NgayLap         DATETIME        DEFAULT GETDATE(),
    DonGiaNhap      DECIMAL(18,2)   NOT NULL CHECK (DonGiaNhap >= 0),
    CONSTRAINT FK_Gia_SanPham FOREIGN KEY (MaSP)
        REFERENCES SanPham(MaSP)
);

CREATE TABLE TonKho (
    MaTonKho        INT             PRIMARY KEY IDENTITY(1,1),
    MaSP            INT             NOT NULL,
    MaKho           INT             NOT NULL,
    SoLuongTon      INT             NOT NULL DEFAULT 0,
    TrongLuongTon   DECIMAL(12,3)   NOT NULL DEFAULT 0,
    CONSTRAINT FK_TonKho_SanPham FOREIGN KEY (MaSP)
        REFERENCES SanPham(MaSP),
    CONSTRAINT FK_TonKho_Kho FOREIGN KEY (MaKho)
        REFERENCES Kho(MaKho),
    CONSTRAINT UQ_TonKho_SP_Kho UNIQUE (MaSP, MaKho)
);

CREATE TABLE LichSuHoatDong (
    MaLog           BIGINT          PRIMARY KEY IDENTITY(1,1),
    BangLienQuan    VARCHAR(50)     NOT NULL,
    MaBanGhi        INT             NOT NULL,
    HanhDong        VARCHAR(10)     NOT NULL,
    MaPhieu         VARCHAR(20)     NULL,
    NoiDungCu       NVARCHAR(MAX)   NULL,
    NoiDungMoi      NVARCHAR(MAX)   NULL,
    MaNV            INT             NULL,
    ThoiGian        DATETIME        DEFAULT GETDATE(),
    CONSTRAINT FK_Log_NhanVien FOREIGN KEY (MaNV)
        REFERENCES NhanVien(MaNV)
);
GO

CREATE TABLE BinLocation (
    MaBin               INT             PRIMARY KEY IDENTITY(1,1),
    MaKho               INT             NOT NULL,
    KhuVuc              NVARCHAR(50)    NULL,
    Day                 VARCHAR(10)     NULL,
    Ke                  VARCHAR(10)     NULL,
    Tang                VARCHAR(10)     NULL,
    O                   VARCHAR(10)     NULL,
    TheTichToiDa        DECIMAL(10,2)   DEFAULT 0,
    TrongLuongToiDa     DECIMAL(10,2)   DEFAULT 0,
    TrangThai           NVARCHAR(20)    DEFAULT N'Trống',
    CONSTRAINT FK_Bin_Kho FOREIGN KEY (MaKho) REFERENCES Kho(MaKho)
);
GO

CREATE TABLE LoHang (
    MaLo                INT             PRIMARY KEY IDENTITY(1,1),
    SoLo                VARCHAR(50)     NOT NULL UNIQUE,
    MaSP                INT             NOT NULL,
    NgaySanXuat         DATE            NULL,
    NgayHetHan          DATE            NOT NULL,
    TrangThai           NVARCHAR(20)    DEFAULT N'KhảDụng',
    CONSTRAINT FK_LoHang_SanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

CREATE TABLE TonKhoTheoBin (
    MaTonBin            INT             PRIMARY KEY IDENTITY(1,1),
    MaSP                INT             NOT NULL,
    MaBin               INT             NOT NULL,
    MaLo                INT             NOT NULL,
    SoLuong             INT             NOT NULL DEFAULT 0 CHECK (SoLuong >= 0),
    NgayNhapBin         DATETIME        DEFAULT GETDATE(),
    CONSTRAINT FK_TonBin_SanPham FOREIGN KEY (MaSP)  REFERENCES SanPham(MaSP),
    CONSTRAINT FK_TonBin_Bin     FOREIGN KEY (MaBin)  REFERENCES BinLocation(MaBin),
    CONSTRAINT FK_TonBin_Lo      FOREIGN KEY (MaLo)   REFERENCES LoHang(MaLo)
);
GO

CREATE TABLE GiaoDichKho (
    MaGiaoDich          BIGINT          PRIMARY KEY IDENTITY(1,1),
    MaSP                INT             NOT NULL,
    MaKho               INT             NOT NULL,
    MaBin               INT             NULL,
    MaLo                INT             NULL,
    LoaiGiaoDich        NVARCHAR(30)    NOT NULL,
    MaPhieuThamChieu    VARCHAR(30)     NOT NULL,
    SoLuongThayDoi      INT             NOT NULL,
    SoLuongSauThayDoi   INT             NOT NULL CHECK (SoLuongSauThayDoi >= 0),
    MaNV                INT             NULL,
    ThoiGian            DATETIME        DEFAULT GETDATE(),
    CONSTRAINT FK_GD_SanPham  FOREIGN KEY (MaSP)  REFERENCES SanPham(MaSP),
    CONSTRAINT FK_GD_Kho      FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
    CONSTRAINT FK_GD_Bin      FOREIGN KEY (MaBin) REFERENCES BinLocation(MaBin),
    CONSTRAINT FK_GD_Lo       FOREIGN KEY (MaLo)  REFERENCES LoHang(MaLo),
    CONSTRAINT FK_GD_NhanVien FOREIGN KEY (MaNV)  REFERENCES NhanVien(MaNV)
);
GO

CREATE TABLE PhieuKiemKe (
    MaPKK               INT             PRIMARY KEY IDENTITY(1,1),
    SoPhieu             VARCHAR(20)     UNIQUE NULL,
    NgayLap             DATETIME        DEFAULT GETDATE(),
    MaKho               INT             NOT NULL,
    MaNV_Kiem           INT             NULL,
    MaNV_Duyet          INT             NULL,
    TrangThai           NVARCHAR(20)    DEFAULT N'Nháp',
    CONSTRAINT FK_PKK_Kho      FOREIGN KEY (MaKho)      REFERENCES Kho(MaKho),
    CONSTRAINT FK_PKK_NVKiem   FOREIGN KEY (MaNV_Kiem)  REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_PKK_NVDuyet  FOREIGN KEY (MaNV_Duyet) REFERENCES NhanVien(MaNV)
);
GO

CREATE TABLE CT_PhieuKiemKe (
    MaCTKK              INT             PRIMARY KEY IDENTITY(1,1),
    MaPKK               INT             NOT NULL,
    MaSP                INT             NOT NULL,
    MaBin               INT             NULL,
    MaLo                INT             NULL,
    SoLuongHeThong      INT             NOT NULL,
    SoLuongThucTe       INT             NOT NULL,
    SoLuongLech         AS (SoLuongThucTe - SoLuongHeThong) PERSISTED,
    LyDoLech            NVARCHAR(255)   NULL,
    CONSTRAINT FK_CTKK_PKK     FOREIGN KEY (MaPKK) REFERENCES PhieuKiemKe(MaPKK) ON DELETE CASCADE,
    CONSTRAINT FK_CTKK_SanPham FOREIGN KEY (MaSP)  REFERENCES SanPham(MaSP),
    CONSTRAINT FK_CTKK_Bin     FOREIGN KEY (MaBin) REFERENCES BinLocation(MaBin),
    CONSTRAINT FK_CTKK_Lo      FOREIGN KEY (MaLo)  REFERENCES LoHang(MaLo)
);
GO

CREATE TABLE PhieuChuyenKho (
    MaPCK               INT             PRIMARY KEY IDENTITY(1,1),
    SoPhieu             VARCHAR(20)     UNIQUE NULL,
    NgayLap             DATETIME        DEFAULT GETDATE(),
    MaKhoNguon          INT             NOT NULL,
    MaKhoDich           INT             NOT NULL,
    MaNV                INT             NULL,
    TrangThai           NVARCHAR(20)    DEFAULT N'ChờXuất',
    CONSTRAINT FK_PCK_KhoNguon  FOREIGN KEY (MaKhoNguon) REFERENCES Kho(MaKho),
    CONSTRAINT FK_PCK_KhoDich   FOREIGN KEY (MaKhoDich)  REFERENCES Kho(MaKho),
    CONSTRAINT FK_PCK_NhanVien  FOREIGN KEY (MaNV)       REFERENCES NhanVien(MaNV)
);
GO

CREATE TABLE CT_PhieuChuyenKho (
    MaCTCK              INT             PRIMARY KEY IDENTITY(1,1),
    MaPCK               INT             NOT NULL,
    MaSP                INT             NOT NULL,
    MaLo                INT             NULL,
    MaBinNguon          INT             NULL,
    MaBinDich           INT             NULL,
    SoLuong             INT             NOT NULL CHECK (SoLuong > 0),
    CONSTRAINT FK_CTCK_PCK      FOREIGN KEY (MaPCK)      REFERENCES PhieuChuyenKho(MaPCK) ON DELETE CASCADE,
    CONSTRAINT FK_CTCK_SanPham  FOREIGN KEY (MaSP)       REFERENCES SanPham(MaSP),
    CONSTRAINT FK_CTCK_Lo       FOREIGN KEY (MaLo)       REFERENCES LoHang(MaLo),
    CONSTRAINT FK_CTCK_BinNguon FOREIGN KEY (MaBinNguon) REFERENCES BinLocation(MaBin),
    CONSTRAINT FK_CTCK_BinDich  FOREIGN KEY (MaBinDich)  REFERENCES BinLocation(MaBin)
);
GO

CREATE TABLE NhaVanChuyen (
    MaNVC               INT             PRIMARY KEY IDENTITY(1,1),
    TenNVC              NVARCHAR(100)   NOT NULL,
    SoDienThoai         VARCHAR(20)     NULL,
    TrangThai           BIT             DEFAULT 1
);
GO

CREATE TABLE VanDon (
    MaVD                INT             PRIMARY KEY IDENTITY(1,1),
    MaPX                INT             NOT NULL,
    MaNVC               INT             NOT NULL,
    SoVanDon            VARCHAR(50)     NOT NULL UNIQUE,
    PhiVanChuyen        DECIMAL(18,2)   DEFAULT 0,
    TrangThaiGiaoHang   NVARCHAR(30)    DEFAULT N'ChờGiao',
    NgayGiaoThucTe      DATETIME        NULL,
    CONSTRAINT FK_VD_PhieuXuat FOREIGN KEY (MaPX)  REFERENCES PhieuXuat(MaPX),
    CONSTRAINT FK_VD_NVC       FOREIGN KEY (MaNVC) REFERENCES NhaVanChuyen(MaNVC)
);
GO

CREATE TABLE Quyen (
    MaQuyen             INT             PRIMARY KEY IDENTITY(1,1),
    TenQuyen            VARCHAR(50)     NOT NULL UNIQUE,
    MoTa                NVARCHAR(200)   NULL
);
GO

CREATE TABLE VaiTro_Quyen (
    MaVT                INT             NOT NULL,
    MaQuyen             INT             NOT NULL,
    CONSTRAINT PK_VaiTroQuyen PRIMARY KEY (MaVT, MaQuyen),
    CONSTRAINT FK_VTQ_VaiTro FOREIGN KEY (MaVT)    REFERENCES VaiTro(MaVT),
    CONSTRAINT FK_VTQ_Quyen  FOREIGN KEY (MaQuyen) REFERENCES Quyen(MaQuyen)
);
GO

PRINT N'01_create-tables.sql completed.';
GO
