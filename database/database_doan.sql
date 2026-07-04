CREATE DATABASE QuanLyKho;
GO

USE QuanLyKho;
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

SET IDENTITY_INSERT DanhMucSanPham ON;
INSERT INTO DanhMucSanPham (MaDanhMucSP, TenDanhMucSP, MoTa) VALUES
(1,  N'Trái cây',      N'Các loại trái cây tươi'),
(2,  N'Rau củ',        N'Các loại rau củ quả'),
(3,  N'Thịt cá',       N'Thịt, cá, hải sản tươi sống và đông lạnh'),
(4,  N'Gia vị',        N'Gia vị, nước chấm, sốt nấu ăn'),
(5,  N'Đồ hộp',        N'Thực phẩm đóng hộp, chế biến sẵn'),
(6,  N'Bánh kẹo',      N'Bánh, kẹo, snack đóng gói'),
(7,  N'Sữa',           N'Sữa tươi, sữa đặc, sản phẩm từ sữa'),
(8,  N'Dầu ăn',        N'Dầu ăn và chất béo thực vật'),
(9,  N'Nước giải khát',N'Nước ngọt, cà phê lon, nước đóng chai'),
(10, N'Hóa mỹ phẩm',   N'Chăm sóc cá nhân, mỹ phẩm'),
(11, N'Tẩy rửa',       N'Nước giặt, nước xả, nước rửa chén'),
(12, N'Điện tử',       N'Thiết bị điện tử, điện gia dụng nhỏ'),
(13, N'Gia dụng điện', N'Quạt, nồi cơm, máy xay, bàn ủi'),
(14, N'Thời trang',    N'Quần áo, phụ kiện cơ bản'),
(15, N'Văn phòng phẩm',N'Bút, vở, giấy, dụng cụ học tập'),
(16, N'Đồ gia dụng',   N'Vật dụng gia đình không dùng điện'),
(17, N'Thực phẩm khô', N'Gạo, mì, đường, muối, ngũ cốc'),
(18, N'Chăm sóc sức khỏe', N'Thực phẩm bổ sung, khẩu trang, vitamin');
SET IDENTITY_INSERT DanhMucSanPham OFF;

SET IDENTITY_INSERT Kho ON;
INSERT INTO Kho (MaKho, TenKho, DiaChi, TrangThai) VALUES
(1, N'Kho Lạnh A', N'KCN Biên Hòa 1, Đồng Nai', 1),
(2, N'Kho Lạnh B', N'KCN Biên Hòa 2, Đồng Nai', 1),
(3, N'Kho Thịt Cá', N'Long Bình, Biên Hòa, Đồng Nai', 1),
(4, N'Kho Trung Chuyển', N'Tam Phước, Biên Hòa, Đồng Nai', 1),
(5, N'Kho Khô Tổng', N'KCN Amata, Đồng Nai', 1),
(6, N'Kho Hàng Tiêu Dùng', N'Long Thành, Đồng Nai', 1);
SET IDENTITY_INSERT Kho OFF;

SET IDENTITY_INSERT NhaCungCap ON;
INSERT INTO NhaCungCap (MaNCC, TenNCC, DiaChi, SoDienThoai, Email, NguoiLienHe, TrangThai) VALUES
(1,  N'HTX Rau sạch Đà Lạt', N'Đà Lạt, Lâm Đồng', '0263381234', 'rau.dalat@demo.vn', N'Nguyễn Bạch Lan', 1),
(2,  N'Công ty Nông sản Miền Tây', N'Cái Răng, Cần Thơ', '0292381122', 'mientay@demo.vn', N'Trần Văn Hậu', 1),
(3,  N'Công ty Thực phẩm Đồng Nai', N'Biên Hòa, Đồng Nai', '0251388999', 'tpdn@demo.vn', N'Lê Thị Mai', 1),
(4,  N'Công ty Thủy sản Cửu Long', N'Ninh Kiều, Cần Thơ', '0292388777', 'thuysan@demo.vn', N'Phạm Minh Châu', 1),
(5,  N'Cholimex Foods', N'Bình Chánh, TP.HCM', '0283766555', 'sales@cholimex.vn', N'Phan Thị Thủy', 1),
(6,  N'Nhà máy Đồ hộp Hạ Long', N'Hạ Long, Quảng Ninh', '0203388666', 'halong@demo.vn', N'Vũ Đình Nam', 1),
(7,  N'Kinh Đô Bình Dương', N'Thuận An, Bình Dương', '0274388333', 'kinhdo@demo.vn', N'Ngô Thành Sơn', 1),
(8,  N'Vinamilk Bình Dương', N'Dĩ An, Bình Dương', '0274377444', 'vinamilk@demo.vn', N'Võ Thị Lan', 1),
(9,  N'Tường An', N'Tân Phú, TP.HCM', '0283812777', 'tuongan@demo.vn', N'Đặng Quốc Huy', 1),
(10, N'Suntory PepsiCo', N'Q.12, TP.HCM', '0283711222', 'pepsi@demo.vn', N'Nguyễn Minh Đức', 1),
(11, N'Unilever Việt Nam', N'Thủ Đức, TP.HCM', '0283899111', 'unilever@demo.vn', N'Bùi Thị Hoa', 1),
(12, N'Thiên Long', N'Q.11, TP.HCM', '0283856000', 'thienlong@demo.vn', N'Lý Văn Thành', 1),
(13, N'Nhà phân phối Điện máy SG', N'Q.5, TP.HCM', '0283834777', 'dienmay@demo.vn', N'Ngô Minh Khoa', 1),
(14, N'Nutri Health', N'Phú Nhuận, TP.HCM', '0283878000', 'nutri@demo.vn', N'Đỗ Kim Anh', 1);
SET IDENTITY_INSERT NhaCungCap OFF;

SET IDENTITY_INSERT VaiTro ON;
INSERT INTO VaiTro (MaVT, TenVaiTro, MoTa, TrangThai) VALUES
(1, N'QuanTriVien', N'Quản trị toàn hệ thống', 1),
(2, N'ThuKho', N'Quản lý nhập xuất và tồn kho', 1),
(3, N'KeToan', N'Theo dõi giá và báo cáo', 1),
(4, N'KiemKe', N'Thực hiện kiểm kê kho', 1),
(5, N'GiamSat', N'Giám sát vận hành kho', 1);
SET IDENTITY_INSERT VaiTro OFF;

SET IDENTITY_INSERT NhanVien ON;
INSERT INTO NhanVien (
    MaNV,
    HoTen,
    ChucVu,
    SoDienThoai,
    NgaySinh,
    CCCD,
    NgayCap,
    NoiCap,
    GioiTinh,
    Email,
    TrangThai
) VALUES
(1, N'Nguyễn Văn An',    N'Quản lý kho',       '0901234561', '1985-03-12', '012345678901',
    '2016-05-18', N'Cục Cảnh sát ĐKQL cư trú và DLQG về dân cư', 1, 'an.nv@qlkho.vn', 1),

(2, N'Trần Thị Bích',    N'Thủ kho lạnh',      '0901234562', '1990-07-22', '012345678902',
    '2018-09-07', N'Công an tỉnh Đồng Nai',                           0, 'bich.tt@qlkho.vn', 1),

(3, N'Lê Hoàng Cường',   N'Thủ kho khô',       '0901234563', '1992-11-05', '012345678903',
    '2017-11-21', N'Công an tỉnh Đồng Nai',                           1, 'cuong.lh@qlkho.vn', 1),

(4, N'Phạm Thị Dung',    N'Kế toán kho',       '0901234564', '1988-05-30', '012345678904',
    '2016-12-14', N'Cục Cảnh sát ĐKQL cư trú và DLQG về dân cư', 0, 'dung.pt@qlkho.vn', 1),

(5, N'Hoàng Minh Đức',   N'Nhân viên kiểm kê', '0901234565', '1995-09-18', '012345678905',
    '2019-03-26', N'Công an tỉnh Bình Dương',                        1, 'duc.hm@qlkho.vn', 1),

(6, N'Vũ Thị Hà',        N'Giám sát ca',       '0901234566', '1993-02-14', '012345678906',
    '2018-01-19', N'Công an TP.HCM',                                  0, 'ha.vt@qlkho.vn', 1),

(7, N'Đặng Quốc Hùng',   N'Bốc xếp',           '0901234567', '1998-06-25', '012345678907',
    '2020-06-11', N'Công an tỉnh Đồng Nai',                           1, 'hung.dq@qlkho.vn', 1),

(8, N'Bùi Thị Lan',      N'Bốc xếp',           '0901234568', '1997-08-10', '012345678908',
    '2021-08-03', N'Công an tỉnh Bến Tre',                            0, 'lan.bt@qlkho.vn', 1);
SET IDENTITY_INSERT NhanVien OFF;

SET IDENTITY_INSERT TaiKhoan ON;
INSERT INTO TaiKhoan (MaTK, TenDangNhap, MatKhau, MaNV, MaVT, TrangThai) VALUES
(1, 'admin',   'Admin123', 1, 1, 1),
(2, 'thukho_a','Thukhoa@123',    2, 2, 1),
(3, 'thukho_b','Thukhoab@345',    3, 2, 1),
(4, 'ketoan',  'Ketoan@055',    4, 3, 1),
(5, 'kiemke',  'Kiemke@657',    5, 4, 1),
(6, 'giamsat', 'Giamsat@999',    6, 5, 1);
SET IDENTITY_INSERT TaiKhoan OFF;

SET IDENTITY_INSERT SanPham ON;
INSERT INTO SanPham (MaSP, TenSP, MaDanhMucSP, TrongLuong, DonVi, MaVach, GiaBan, TonToiThieu, HinhAnh, MoTa, TrangThai, NgayTao, NgayCapNhat) VALUES
(1,  N'Táo Fuji nhập khẩu',           1, 0.200, N'kg',   '8936001750011',  45000, 50, NULL, N'Trái cây bán theo kg, size vừa', 1, '2018-01-02', '2018-01-02'),
(2,  N'Chuối già Nam Bộ',             1, 0.150, N'kg',   '8936001750012',  25000, 50, NULL, N'Chuối chín thương phẩm', 1, '2018-01-02', '2018-01-02'),
(3,  N'Cam sành',                     1, 0.250, N'kg',   '8936001750013',  35000, 50, NULL, N'Cam nội địa phân loại 1', 1, '2018-01-03', '2018-01-03'),
(4,  N'Xoài cát Hòa Lộc',             1, 0.350, N'kg',   '8936001750014',  68000, 30, NULL, N'Xoài tuyển chọn', 1, '2018-01-03', '2018-01-03'),
(5,  N'Nho xanh không hạt',           1, 0.500, N'kg',   '8936001750015', 125000, 20, NULL, N'Nho khay 500g', 1, '2018-01-03', '2018-01-03'),
(6,  N'Cải xanh',                     2, 0.500, N'kg',   '8936001750021',  15000, 50, NULL, N'Rau lá bán theo bó/quy đổi kg', 1, '2018-01-04', '2018-01-04'),
(7,  N'Cà rốt Đà Lạt',                2, 0.500, N'kg',   '8936001750022',  22000, 40, NULL, N'Cà rốt củ size trung', 1, '2018-01-04', '2018-01-04'),
(8,  N'Khoai tây',                    2, 1.000, N'kg',   '8936001750023',  24000, 40, NULL, N'Khoai tây bao lưới', 1, '2018-01-04', '2018-01-04'),
(9,  N'Cà chua bi',                   2, 0.300, N'kg',   '8936001750024',  38000, 30, NULL, N'Cà chua bi hộp nhỏ', 1, '2018-01-05', '2018-01-05'),
(10, N'Súp lơ xanh',                  2, 0.600, N'kg',   '8936001750025',  32000, 30, NULL, N'Súp lơ loại 1', 1, '2018-01-05', '2018-01-05'),
(11, N'Thịt heo ba chỉ',              3, 1.000, N'kg',   '8936001750031', 145000, 25, NULL, N'Thịt mát đóng khay', 1, '2018-01-05', '2018-01-05'),
(12, N'Thịt bò Úc',                   3, 1.000, N'kg',   '8936001750032', 355000, 15, NULL, N'Thịt bò đông lạnh nhập khẩu', 1, '2018-01-06', '2018-01-06'),
(13, N'Cá hồi phi lê',                3, 1.000, N'kg',   '8936001750033', 425000, 15, NULL, N'Cá hồi phi lê bảo quản lạnh', 1, '2018-01-06', '2018-01-06'),
(14, N'Tôm thẻ chân trắng',           3, 1.000, N'kg',   '8936001750034', 215000, 20, NULL, N'Tôm đông lạnh size 40/50', 1, '2018-01-06', '2018-01-06'),
(15, N'Mực ống làm sạch',             3, 1.000, N'kg',   '8936001750035', 185000, 20, NULL, N'Mực đông lạnh nguyên con', 1, '2018-01-07', '2018-01-07'),
(16, N'Nước mắm Phú Quốc 500ml',      4, 0.680, N'chai', '8934673000011',  65000, 20, NULL, N'Chai thủy tinh 500ml', 1, '2018-01-07', '2018-01-07'),
(17, N'Dầu hào chai 600g',            4, 0.600, N'chai', '8934673000012',  55000, 20, NULL, N'Gia vị nấu ăn dạng sệt', 1, '2018-01-07', '2018-01-07'),
(18, N'Tương ớt Cholimex 830g',       4, 0.830, N'chai', '8934673000013',  35000, 30, NULL, N'Chai nhựa 830g', 1, '2018-01-08', '2018-01-08'),
(19, N'Cá hộp sốt cà',                5, 0.155, N'hộp',  '8934673000014',  28000, 30, NULL, N'Hộp thiếc 155g', 1, '2018-01-08', '2018-01-08'),
(20, N'Bắp ngọt đóng hộp',            5, 0.340, N'hộp',  '8934673000015',  32000, 25, NULL, N'Hộp thiếc 340g', 1, '2018-01-08', '2018-01-08'),
(21, N'Bánh Oreo 137g',               6, 0.137, N'gói',  '8801059000011',  25000, 50, NULL, N'Bánh quy kẹp kem', 1, '2018-01-09', '2018-01-09'),
(22, N'Kẹo dừa Bến Tre 200g',         6, 0.200, N'gói',  '8936001200011',  42000, 40, NULL, N'Đặc sản Bến Tre', 1, '2018-01-09', '2018-01-09'),
(23, N'Sữa tươi tiệt trùng 1L',       7, 1.000, N'hộp',  '8936079000011',  38000, 50, NULL, N'Hộp giấy 1 lít', 1, '2018-01-09', '2018-01-09'),
(24, N'Sữa đặc Ông Thọ 380g',         7, 0.380, N'hộp',  '8936079000012',  32000, 50, NULL, N'Hộp thiếc 380g', 1, '2018-01-09', '2018-01-09'),
(25, N'Dầu ăn Tường An 5L',           8, 4.600, N'can',  '8934528000011', 215000, 20, NULL, N'Can nhựa 5 lít', 1, '2018-01-10', '2018-01-10'),
(26, N'Cà phê sữa lon 330ml',         9, 0.330, N'lon',  '8934868000011',  25000, 60, NULL, N'Lon nhôm 330ml', 1, '2018-01-10', '2018-01-10'),
(27, N'Nước ngọt Pepsi 330ml',        9, 0.330, N'lon',  '8934868000012',  12000, 100, NULL, N'Lon nhôm 330ml', 1, '2018-01-10', '2018-01-10'),
(28, N'Bột giặt OMO 3kg',             11,3.000, N'túi',  '8936046100011', 145000, 20, NULL, N'Túi bột giặt 3kg', 1, '2018-01-11', '2018-01-11'),
(29, N'Nước xả Comfort 2L',           11,2.000, N'chai', '8936046100012',  95000, 20, NULL, N'Chai nước xả 2 lít', 1, '2018-01-11', '2018-01-11'),
(30, N'Nước rửa chén Sunlight 750g',  11,0.750, N'chai', '8936046100013',  45000, 30, NULL, N'Chai nhựa 750g', 1, '2018-01-11', '2018-01-11'),
(31, N'Bút bi Thiên Long TL-027',     15,0.012, N'cây',  '8935001800011',   5000, 100, NULL, N'Bút bi mực xanh', 1, '2018-01-12', '2018-01-12');
SET IDENTITY_INSERT SanPham OFF;

INSERT INTO NCC_SanPham (MaNCC, MaSP, GiaNhap, NgayCapNhat) VALUES
(1,1,30000,'2018-01-02'),(1,6,8000,'2018-01-04'),(1,7,12000,'2018-01-04'),(1,9,18000,'2018-01-05'),
(2,2,15000,'2018-01-02'),(2,3,20000,'2018-01-03'),(2,4,42000,'2018-01-03'),(2,8,14000,'2018-01-04'),(2,10,18000,'2018-01-05'),
(3,11,95000,'2018-01-05'),(3,12,280000,'2018-01-06'),
(4,13,330000,'2018-01-06'),(4,14,155000,'2018-01-06'),(4,15,135000,'2018-01-07'),
(5,16,45000,'2018-01-07'),(5,17,36000,'2018-01-07'),(5,18,22000,'2018-01-08'),
(6,19,18000,'2018-01-08'),(6,20,20000,'2018-01-08'),
(7,21,18000,'2018-01-09'),(7,22,28000,'2018-01-09'),
(8,23,27000,'2018-01-09'),(8,24,22000,'2018-01-09'),
(9,25,165000,'2018-01-10'),
(10,26,12000,'2018-01-10'),(10,27,6000,'2018-01-10'),
(11,28,105000,'2018-01-11'),(11,29,65000,'2018-01-11'),(11,30,30000,'2018-01-11'),
(12,31,2500,'2018-01-12');

SET IDENTITY_INSERT PhieuNhap ON;
INSERT INTO PhieuNhap (MaPN, SoPhieu, NgayLap, NgayDuyet, MaNCC, MaKho, MaNV, MaNV_Duyet, TrangThai, TongTien, GhiChu) VALUES
(1, N'PN-20180102-01', '2018-01-02 08:10:00', '2018-01-02 09:00:00', 1, 1, 2, 1, N'Đã duyệt', 15000000, N'Nhập trái cây đầu ngày'),
(2, N'PN-20180103-01', '2018-01-03 07:40:00', '2018-01-03 08:20:00', 2, 1, 2, 1, N'Đã duyệt', 20300000, N'Nhập bổ sung trái cây và rau'),
(3, N'PN-20180105-01', '2018-01-05 05:50:00', '2018-01-05 06:30:00', 3, 3, 2, 1, N'Đã duyệt', 28500000, N'Nhập thịt heo'),
(4, N'PN-20180106-01', '2018-01-06 06:00:00', '2018-01-06 06:40:00', 4, 3, 2, 1, N'Đã duyệt', 66000000, N'Nhập cá hồi'),
(5, N'PN-20180107-01', '2018-01-07 09:00:00', '2018-01-07 09:30:00', 5, 5, 3, 1, N'Đã duyệt', 15400000, N'Nhập gia vị'),
(6, N'PN-20180108-01', '2018-01-08 10:15:00', '2018-01-08 10:45:00', 6, 5, 3, 1, N'Đã duyệt', 11400000, N'Nhập đồ hộp'),
(7, N'PN-20180109-01', '2018-01-09 08:20:00', '2018-01-09 09:00:00', 8, 6, 3, 1, N'Đã duyệt', 24500000, N'Nhập sữa'),
(8, N'PN-20180110-01', '2018-01-10 08:40:00', '2018-01-10 09:10:00', 10, 6, 3, 1, N'Đã duyệt', 18000000, N'Nhập nước giải khát'),
(9, N'PN-20180111-01', '2018-01-11 14:10:00', '2018-01-11 14:30:00', 11, 6, 3, 1, N'Đã duyệt', 40000000, N'Nhập hàng tẩy rửa'),
(10,N'PN-20180112-01', '2018-01-12 15:00:00', '2018-01-12 15:20:00', 12, 6, 3, 1, N'Đã duyệt', 2500000, N'Nhập văn phòng phẩm');
SET IDENTITY_INSERT PhieuNhap OFF;

SET IDENTITY_INSERT CT_PhieuNhap ON;
INSERT INTO CT_PhieuNhap (MaCTPN, MaPN, MaSP, SoLuong, TrongLuong, DonGia) VALUES
(1,1,1,300,60.000,30000),(2,1,2,400,60.000,15000),(3,1,3,300,75.000,20000),
(4,2,4,200,70.000,42000),(5,2,6,500,250.000,8000),(6,2,7,300,150.000,12000),(7,2,8,400,400.000,14000),
(8,3,11,300,300.000,95000),
(9,4,13,200,200.000,330000),
(10,5,16,120,81.600,45000),(11,5,17,160,96.000,36000),(12,5,18,180,149.400,22000),
(13,6,19,250,38.750,18000),(14,6,20,345,117.300,20000),
(15,7,23,500,500.000,27000),(16,7,24,500,190.000,22000),
(17,8,26,600,198.000,12000),(18,8,27,1800,594.000,6000),
(19,9,28,200,600.000,105000),(20,9,29,220,440.000,65000),(21,9,30,240,180.000,30000),
(22,10,31,1000,12.000,2500);
SET IDENTITY_INSERT CT_PhieuNhap OFF;

SET IDENTITY_INSERT PhieuXuat ON;
INSERT INTO PhieuXuat (MaPX, SoPhieu, NgayLap, NgayDuyet, MaKho, MaNV, MaNV_Duyet, NguoiNhan, TrangThai, TongTien, GhiChu) VALUES
(1, N'PX-20180112-01', '2018-01-12 10:00:00', '2018-01-12 10:20:00', 1, 2, 1, N'Siêu thị BigC Biên Hòa', N'Đã duyệt', 12800000, N'Xuất trái cây và rau'),
(2, N'PX-20180113-01', '2018-01-13 06:20:00', '2018-01-13 06:40:00', 3, 2, 1, N'Co.opmart Đồng Nai', N'Đã duyệt', 23200000, N'Xuất thịt cá'),
(3, N'PX-20180114-01', '2018-01-14 09:20:00', '2018-01-14 09:40:00', 5, 3, 1, N'Cửa hàng tiện lợi khu Amata', N'Đã duyệt', 8600000, N'Xuất gia vị và đồ hộp'),
(4, N'PX-20180115-01', '2018-01-15 13:10:00', '2018-01-15 13:30:00', 6, 3, 1, N'Siêu thị mini Long Thành', N'Đã duyệt', 19600000, N'Xuất sữa, nước và tẩy rửa'),
(5, N'PX-20180116-01', '2018-01-16 16:00:00', '2018-01-16 16:20:00', 6, 3, 1, N'Khối văn phòng nội bộ', N'Đã duyệt', 1200000, N'Xuất văn phòng phẩm');
SET IDENTITY_INSERT PhieuXuat OFF;

SET IDENTITY_INSERT CT_PhieuXuat ON;
INSERT INTO CT_PhieuXuat (MaCTPX, MaPX, MaSP, SoLuong, TrongLuong, DonGia) VALUES
(1,1,1,120,24.000,45000),(2,1,3,100,25.000,35000),(3,1,6,320,160.000,15000),(4,1,7,150,75.000,22000),
(5,2,11,80,80.000,145000),(6,2,13,20,20.000,425000),(7,2,14,30,30.000,215000),(8,2,15,10,10.000,185000),
(9,3,16,40,27.200,65000),(10,3,18,60,49.800,35000),(11,3,19,80,12.400,28000),(12,3,20,50,17.000,32000),
(13,4,23,180,180.000,38000),(14,4,24,120,45.600,32000),(15,4,26,200,66.000,25000),(16,4,27,600,198.000,12000),(17,4,29,40,80.000,95000),
(18,5,31,240,2.880,5000);
SET IDENTITY_INSERT CT_PhieuXuat OFF;

SET IDENTITY_INSERT Gia ON;
INSERT INTO Gia (MaGia, MaSP, NgayLap, DonGiaNhap) VALUES
(1,1,'2018-01-02',30000),(2,2,'2018-01-02',15000),(3,3,'2018-01-02',20000),(4,4,'2018-01-03',42000),(5,5,'2018-01-03',95000),
(6,6,'2018-01-04',8000),(7,7,'2018-01-04',12000),(8,8,'2018-01-04',14000),(9,9,'2018-01-05',18000),(10,10,'2018-01-05',18000),
(11,11,'2018-01-05',95000),(12,12,'2018-01-06',280000),(13,13,'2018-01-06',330000),(14,14,'2018-01-06',155000),(15,15,'2018-01-07',135000),
(16,16,'2018-01-07',45000),(17,17,'2018-01-07',36000),(18,18,'2018-01-08',22000),(19,19,'2018-01-08',18000),(20,20,'2018-01-08',20000),
(21,21,'2018-01-09',18000),(22,22,'2018-01-09',28000),(23,23,'2018-01-09',27000),(24,24,'2018-01-09',22000),(25,25,'2018-01-10',165000),
(26,26,'2018-01-10',12000),(27,27,'2018-01-10',6000),(28,28,'2018-01-11',105000),(29,29,'2018-01-11',65000),(30,30,'2018-01-11',30000),
(31,31,'2018-01-12',2500);
SET IDENTITY_INSERT Gia OFF;

SET IDENTITY_INSERT TonKho ON;
INSERT INTO TonKho (MaTonKho, MaSP, MaKho, SoLuongTon, TrongLuongTon) VALUES
(1,1,1,180,36.000),(2,2,1,400,60.000),(3,3,1,200,50.000),(4,4,1,200,70.000),(5,6,1,180,90.000),(6,7,1,150,75.000),(7,8,1,400,400.000),
(8,11,3,220,220.000),(9,13,3,180,180.000),(10,14,3,170,170.000),(11,15,3,110,110.000),
(12,16,5,80,54.400),(13,17,5,160,96.000),(14,18,5,120,99.600),(15,19,5,170,26.350),(16,20,5,295,100.300),
(17,23,6,320,320.000),(18,24,6,380,144.400),(19,26,6,400,132.000),(20,27,6,1200,396.000),(21,28,6,200,600.000),(22,29,6,180,360.000),(23,30,6,240,180.000),(24,31,6,760,9.120);
SET IDENTITY_INSERT TonKho OFF;

INSERT INTO LichSuHoatDong (BangLienQuan, MaBanGhi, HanhDong, MaPhieu, NoiDungCu, NoiDungMoi, MaNV, ThoiGian) VALUES
('PhieuNhap', 1, 'INSERT', 'PN-20180102-01', NULL, N'Tạo phiếu nhập trái cây đầu ngày', 2, '2018-01-02 08:10:00'),
('PhieuNhap', 1, 'UPDATE', 'PN-20180102-01', N'TrangThai=Nháp', N'TrangThai=Đã duyệt', 1, '2018-01-02 09:00:00'),
('PhieuNhap', 3, 'INSERT', 'PN-20180105-01', NULL, N'Tạo phiếu nhập thịt heo kho lạnh', 2, '2018-01-05 05:50:00'),
('PhieuNhap', 4, 'INSERT', 'PN-20180106-01', NULL, N'Tạo phiếu nhập cá hồi', 2, '2018-01-06 06:00:00'),
('PhieuXuat', 1, 'INSERT', 'PX-20180112-01', NULL, N'Tạo phiếu xuất cho BigC Biên Hòa', 2, '2018-01-12 10:00:00'),
('PhieuXuat', 2, 'INSERT', 'PX-20180113-01', NULL, N'Tạo phiếu xuất cho Co.opmart Đồng Nai', 2, '2018-01-13 06:20:00'),
('PhieuXuat', 4, 'UPDATE', 'PX-20180115-01', N'TrangThai=Nháp', N'TrangThai=Đã duyệt', 1, '2018-01-15 13:30:00'),
('TonKho', 17, 'UPDATE', NULL, N'SoLuongTon=500', N'SoLuongTon=320 sau xuất hàng', 3, '2018-01-15 13:35:00'),
('Gia', 25, 'INSERT', NULL, NULL, N'Cập nhật giá nhập dầu ăn Tường An 5L', 4, '2018-01-10 11:00:00'),
('TaiKhoan', 6, 'INSERT', NULL, NULL, N'Tạo tài khoản giám sát kho', 1, '2018-01-12 08:00:00');

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
    -- Giá trị: NhậpKho / XuấtKho / ChuyểnBin / KiểmKê / SốDầuKỳ
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


SET IDENTITY_INSERT BinLocation ON;
INSERT INTO BinLocation (MaBin, MaKho, KhuVuc, Day, Ke, Tang, O, TheTichToiDa, TrongLuongToiDa, TrangThai) VALUES
-- Kho 1 (Kho Lạnh A – Rau Củ Quả): 8 bin, nhiệt độ 4-8°C / khu lạnh sâu -5°C
(1,  1, N'Khu Mát (4–8°C)',      'A', 'K1', '1', 'O1', 8.00,  500.00, N'ĐangSửDụng'),
(2,  1, N'Khu Mát (4–8°C)',      'A', 'K1', '2', 'O1', 8.00,  500.00, N'ĐangSửDụng'),
(3,  1, N'Khu Mát (4–8°C)',      'A', 'K2', '1', 'O1', 8.00,  500.00, N'ĐangSửDụng'),
(4,  1, N'Khu Mát (4–8°C)',      'A', 'K2', '2', 'O1', 8.00,  500.00, N'ĐangSửDụng'),
(5,  1, N'Khu Mát (4–8°C)',      'B', 'K1', '1', 'O1', 8.00,  500.00, N'ĐangSửDụng'),
(6,  1, N'Khu Mát (4–8°C)',      'B', 'K1', '2', 'O1', 8.00,  500.00, N'ĐangSửDụng'),
(7,  1, N'Khu Lạnh Sâu (-5°C)', 'C', 'K1', '1', 'O1', 6.00,  300.00, N'ĐangSửDụng'),
(8,  1, N'Khu Lạnh Sâu (-5°C)', 'C', 'K1', '2', 'O1', 6.00,  300.00, N'Trống'),
-- Kho 2 (Kho Lạnh B – dự phòng): 5 bin, phần lớn Trống
(9,  2, N'Khu Mát (4–8°C)',      'A', 'K1', '1', 'O1', 8.00,  500.00, N'Trống'),
(10, 2, N'Khu Mát (4–8°C)',      'A', 'K1', '2', 'O1', 8.00,  500.00, N'Trống'),
(11, 2, N'Khu Mát (4–8°C)',      'A', 'K2', '1', 'O1', 8.00,  500.00, N'Trống'),
(12, 2, N'Khu Lạnh Sâu (-5°C)', 'B', 'K1', '1', 'O1', 6.00,  300.00, N'Khóa'),
(13, 2, N'Khu Lạnh Sâu (-5°C)', 'B', 'K1', '2', 'O1', 6.00,  300.00, N'Trống'),
-- Kho 3 (Kho Thịt Cá – Đông lạnh -18°C): 6 bin
(14, 3, N'Khu Đông Lạnh (-18°C)', 'A', 'K1', '1', 'O1', 10.00, 800.00, N'ĐangSửDụng'),
(15, 3, N'Khu Đông Lạnh (-18°C)', 'A', 'K1', '2', 'O1', 10.00, 800.00, N'ĐangSửDụng'),
(16, 3, N'Khu Đông Lạnh (-18°C)', 'A', 'K2', '1', 'O1', 10.00, 800.00, N'ĐangSửDụng'),
(17, 3, N'Khu Đông Lạnh (-18°C)', 'B', 'K1', '1', 'O1', 10.00, 800.00, N'ĐangSửDụng'),
(18, 3, N'Khu Đông Lạnh (-18°C)', 'B', 'K1', '2', 'O1', 10.00, 800.00, N'Trống'),
(19, 3, N'Khu Đông Lạnh (-18°C)', 'B', 'K2', '1', 'O1', 10.00, 800.00, N'Trống'),
-- Kho 4 (Kho Trung Chuyển): 3 bin, dạng sàn phân phối
(20, 4, N'Khu Chờ Phân Phối',   'A', 'S1', '1', 'O1', 20.00, 2000.00, N'Trống'),
(21, 4, N'Khu Chờ Phân Phối',   'A', 'S1', '1', 'O2', 20.00, 2000.00, N'Trống'),
(22, 4, N'Khu Chờ Phân Phối',   'A', 'S1', '1', 'O3', 20.00, 2000.00, N'Trống'),
-- Kho 5 (Kho Hàng Khô Tổng Hợp): 10 bin – Khu Khô A active, Khu Khô B reserve
(23, 5, N'Khu Khô A',           'A', 'K1', '1', 'O1', 12.00, 1000.00, N'ĐangSửDụng'),
(24, 5, N'Khu Khô A',           'A', 'K1', '2', 'O1', 12.00, 1000.00, N'ĐangSửDụng'),
(25, 5, N'Khu Khô A',           'A', 'K2', '1', 'O1', 12.00, 1000.00, N'ĐangSửDụng'),
(26, 5, N'Khu Khô A',           'A', 'K2', '2', 'O1', 12.00, 1000.00, N'ĐangSửDụng'),
(27, 5, N'Khu Khô A',           'B', 'K1', '1', 'O1', 12.00, 1000.00, N'ĐangSửDụng'),
(28, 5, N'Khu Khô B',           'B', 'K1', '2', 'O1', 12.00, 1000.00, N'Trống'),
(29, 5, N'Khu Khô B',           'B', 'K2', '1', 'O1', 12.00, 1000.00, N'Trống'),
(30, 5, N'Khu Khô B',           'B', 'K2', '2', 'O1', 12.00, 1000.00, N'Trống'),
(31, 5, N'Khu Khô B',           'C', 'K1', '1', 'O1', 12.00, 1000.00, N'Trống'),
(32, 5, N'Khu Khô B',           'C', 'K1', '2', 'O1', 12.00, 1000.00, N'Trống'),
-- Kho 6 (Kho Tiêu Dùng Nhanh – FMCG): 8 bin
(33, 6, N'Khu FMCG',            'A', 'K1', '1', 'O1', 15.00, 1200.00, N'ĐangSửDụng'),
(34, 6, N'Khu FMCG',            'A', 'K1', '2', 'O1', 15.00, 1200.00, N'ĐangSửDụng'),
(35, 6, N'Khu FMCG',            'A', 'K2', '1', 'O1', 15.00, 1200.00, N'ĐangSửDụng'),
(36, 6, N'Khu FMCG',            'A', 'K2', '2', 'O1', 15.00, 1200.00, N'ĐangSửDụng'),
(37, 6, N'Khu FMCG',            'B', 'K1', '1', 'O1', 15.00, 1200.00, N'ĐangSửDụng'),
(38, 6, N'Khu FMCG',            'B', 'K1', '2', 'O1', 15.00, 1200.00, N'ĐangSửDụng'),
(39, 6, N'Khu FMCG',            'B', 'K2', '1', 'O1', 15.00, 1200.00, N'ĐangSửDụng'),
(40, 6, N'Khu FMCG',            'B', 'K2', '2', 'O1', 15.00, 1200.00, N'ĐangSửDụng');
SET IDENTITY_INSERT BinLocation OFF;
GO

SET IDENTITY_INSERT LoHang ON;
INSERT INTO LoHang (MaLo, SoLo, MaSP, NgaySanXuat, NgayHetHan, TrangThai) VALUES
-- SP1 Táo Fuji (Kho1)
(1,  'FJ-20171220-A01', 1,  '2017-12-20', '2018-03-20', N'KhảDụng'),
-- SP2 Cà rốt (Kho1)
(2,  'DL-CR-20180102-01', 2, '2018-01-02', '2018-02-15', N'KhảDụng'),
-- SP3 Súp lơ xanh (Kho1)
(3,  'DL-SL-20180103-01', 3, '2018-01-03', '2018-01-31', N'KhảDụng'),
-- SP4 Dâu tây (Kho1)
(4,  'DL-DT-20180104-01', 4, '2018-01-04', '2018-01-20', N'KhảDụng'),
-- SP5 Dưa leo (Kho1)
(5,  'DL-DLC-20180105-01', 5, '2018-01-05', '2018-01-25', N'KhảDụng'),
-- SP6 Ớt chuông đỏ (Kho1)
(6,  'DL-OC-20180106-01', 6, '2018-01-06', '2018-02-06', N'KhảDụng'),
-- SP13 Cá hồi Na Uy (Kho3) – Mowi ASA lot format
(7,  'NORSAL-171218-S04', 13, '2017-12-18', '2018-03-18', N'KhảDụng'),
-- SP14 Tôm sú đông lạnh (Kho3) – VASEP seafood lot
(8,  'VASEP-TS-20171228-014', 14, '2017-12-28', '2019-12-28', N'KhảDụng'),
-- SP15 Cá tra fillet (Kho3) – VASEP seafood lot
(9,  'VASEP-CT-20171230-015', 15, '2017-12-30', '2019-12-30', N'KhảDụng'),
-- SP16 Sữa tươi Vinamilk TH (Kho5) – VNM lot
(10, 'VNM-20180101-L016', 16, '2018-01-01', '2018-02-01', N'KhảDụng'),
-- SP17 Sữa đặc Ông Thọ (Kho5) – VNM lot
(11, 'VNM-20171201-L017', 17, '2017-12-01', '2019-06-01', N'KhảDụng'),
-- SP18 Nước cam Twister (Kho5) – PepsiCo Julian date (17L = 2017 lot)
(12, 'PEP-17L4501A',      18, '2017-12-22', '2018-06-22', N'KhảDụng'),
-- SP19 Nước mắm Cholimex (Kho5)
(13, 'CHO-201712-L019',   19, '2017-12-01', '2020-12-01', N'KhảDụng'),
-- SP20 Dầu ăn Tường An (Kho5)
(14, 'TA-20171215-L020',  20, '2017-12-15', '2019-12-15', N'KhảDụng'),
-- SP21 Bột giặt OMO (Kho5) – Unilever VN lot
(15, 'UNI-VN-20171220-021', 21, '2017-12-20', '2019-12-20', N'KhảDụng'),
-- SP22 Kem đánh răng P/S (Kho5)
(16, 'UNI-VN-20171210-022', 22, '2017-12-10', '2020-12-10', N'KhảDụng'),
-- SP23 Mỳ Hảo Hảo (Kho6)
(17, 'AVN-HH-20171225-023', 23, '2017-12-25', '2018-12-25', N'KhảDụng'),
-- SP24 Bánh Oreo (Kho6)
(18, 'MND-OR-20171215-024', 24, '2017-12-15', '2018-12-15', N'KhảDụng'),
-- SP25 Cà phê G7 (Kho6)
(19, 'TRG-G7-20171201-025', 25, '2017-12-01', '2019-12-01', N'KhảDụng'),
-- SP26 Trà Lipton (Kho6)
(20, 'UNI-VN-20171205-026', 26, '2017-12-05', '2020-12-05', N'KhảDụng'),
-- SP27 Pepsi 1.5L (Kho6)
(21, 'PEP-17L4501B',      27, '2017-12-22', '2018-06-22', N'KhảDụng'),
-- SP28 Bút Bi Thiên Long (Kho6)
(22, 'TL-BBI-20171201-028', 28, '2017-12-01', '2022-12-01', N'KhảDụng'),
-- SP29 Tập học sinh (Kho6)
(23, 'TL-THS-20171201-029', 29, '2017-12-01', '2022-12-01', N'KhảDụng'),
-- SP30 Xà phòng Dove (Kho6)
(24, 'UNI-VN-20171210-030', 30, '2017-12-10', '2020-12-10', N'KhảDụng');
SET IDENTITY_INSERT LoHang OFF;
GO

SET IDENTITY_INSERT TonKhoTheoBin ON;
INSERT INTO TonKhoTheoBin (MaTonBin, MaSP, MaBin, MaLo, SoLuong, NgayNhapBin) VALUES
-- Kho 1 (Bin 1–7, SP1–SP6)
(1,  1,  1, 1,  200, '2018-01-02 08:00:00'),
(2,  2,  2, 2,  350, '2018-01-02 08:30:00'),
(3,  3,  3, 3,  310, '2018-01-03 09:00:00'),
(4,  4,  4, 4,  280, '2018-01-04 09:00:00'),
(5,  5,  5, 5,  200, '2018-01-05 09:30:00'),
(6,  6,  6, 6,  210, '2018-01-06 10:00:00'),
(7,  5,  7, 5,  160, '2018-01-05 09:30:00'),
-- Kho 3 (Bin 14–17, SP13–SP15)
(8,  13, 14, 7, 200, '2017-12-28 07:00:00'),
(9,  14, 15, 8, 150, '2017-12-29 07:00:00'),
(10, 15, 16, 9, 180, '2017-12-31 07:00:00'),
(11, 13, 17, 7, 150, '2017-12-28 07:30:00'),
-- Kho 5 (Bin 23–27, SP16–SP22)
(12, 16, 23, 10, 150, '2018-01-02 08:00:00'),
(13, 17, 24, 11, 150, '2018-01-02 08:00:00'),
(14, 18, 25, 12, 130, '2018-01-02 08:30:00'),
(15, 19, 26, 13, 120, '2018-01-02 09:00:00'),
(16, 20, 27, 14, 130, '2018-01-02 09:00:00'),
(17, 21, 23, 15, 85,  '2018-01-02 09:30:00'),
(18, 22, 24, 16, 60,  '2018-01-02 09:30:00'),
-- Kho 6 (Bin 33–40, SP23–SP30)
(19, 23, 33, 17, 500, '2018-01-02 07:00:00'),
(20, 24, 34, 18, 480, '2018-01-02 07:00:00'),
(21, 25, 35, 19, 460, '2018-01-02 07:30:00'),
(22, 26, 36, 20, 480, '2018-01-02 07:30:00'),
(23, 27, 37, 21, 560, '2018-01-02 08:00:00'),
(24, 28, 38, 22, 600, '2018-01-02 08:00:00');
SET IDENTITY_INSERT TonKhoTheoBin OFF;
GO

SET IDENTITY_INSERT GiaoDichKho ON;
INSERT INTO GiaoDichKho (MaGiaoDich, MaSP, MaKho, MaBin, MaLo, LoaiGiaoDich, MaPhieuThamChieu, SoLuongThayDoi, SoLuongSauThayDoi, MaNV, ThoiGian) VALUES
-- Số dầu kỳ (01/01/2018) – SP14 Tôm sú & SP15 Cá tra
(1,  14, 3, 15, 8,  N'SốDầuKỳ', 'SOLUODAUKY-2018', 150,  150,  1, '2018-01-01 07:00:00'),
(2,  15, 3, 16, 9,  N'SốDầuKỳ', 'SOLUODAUKY-2018', 180,  180,  1, '2018-01-01 07:00:00'),

-- NhậpKho từ 10 PhieuNhap (PN-20180102 … PN-20180112)
(3,  1,  1, 1,  1,  N'NhậpKho', 'PN-20180102', 200,  200,  3, '2018-01-02 08:00:00'),
(4,  2,  1, 2,  2,  N'NhậpKho', 'PN-20180102', 350,  350,  3, '2018-01-02 08:00:00'),
(5,  3,  1, 3,  3,  N'NhậpKho', 'PN-20180103', 310,  310,  3, '2018-01-03 09:00:00'),
(6,  4,  1, 4,  4,  N'NhậpKho', 'PN-20180103', 280,  280,  3, '2018-01-03 09:00:00'),
(7,  5,  1, 5,  5,  N'NhậpKho', 'PN-20180104', 200,  200,  3, '2018-01-04 09:00:00'),
(8,  5,  1, 7,  5,  N'NhậpKho', 'PN-20180104', 160,  160,  3, '2018-01-04 09:00:00'),
(9,  6,  1, 6,  6,  N'NhậpKho', 'PN-20180105', 210,  210,  3, '2018-01-05 10:00:00'),
(10, 13, 3, 14, 7,  N'NhậpKho', 'PN-20180105', 200,  200,  3, '2018-01-05 10:00:00'),
(11, 13, 3, 17, 7,  N'NhậpKho', 'PN-20180106', 150,  150,  3, '2018-01-06 08:00:00'),
(12, 16, 5, 23, 10, N'NhậpKho', 'PN-20180106', 150,  150,  3, '2018-01-06 08:30:00'),
(13, 17, 5, 24, 11, N'NhậpKho', 'PN-20180107', 150,  150,  3, '2018-01-07 08:00:00'),
(14, 18, 5, 25, 12, N'NhậpKho', 'PN-20180107', 130,  130,  3, '2018-01-07 08:00:00'),
(15, 19, 5, 26, 13, N'NhậpKho', 'PN-20180108', 120,  120,  3, '2018-01-08 09:00:00'),
(16, 20, 5, 27, 14, N'NhậpKho', 'PN-20180108', 130,  130,  3, '2018-01-08 09:00:00'),
(17, 21, 5, 23, 15, N'NhậpKho', 'PN-20180109', 85,   85,   3, '2018-01-09 08:00:00'),
(18, 22, 5, 24, 16, N'NhậpKho', 'PN-20180109', 60,   60,   3, '2018-01-09 08:00:00'),
(19, 23, 6, 33, 17, N'NhậpKho', 'PN-20180110', 500,  500,  3, '2018-01-10 07:00:00'),
(20, 24, 6, 34, 18, N'NhậpKho', 'PN-20180110', 480,  480,  3, '2018-01-10 07:00:00'),
(21, 25, 6, 35, 19, N'NhậpKho', 'PN-20180111', 460,  460,  3, '2018-01-11 07:30:00'),
(22, 26, 6, 36, 20, N'NhậpKho', 'PN-20180111', 480,  480,  3, '2018-01-11 07:30:00'),
(23, 27, 6, 37, 21, N'NhậpKho', 'PN-20180112', 560,  560,  3, '2018-01-12 08:00:00'),
(24, 28, 6, 38, 22, N'NhậpKho', 'PN-20180112', 600,  600,  3, '2018-01-12 08:00:00'),

-- XuấtKho từ 5 PhieuXuat (PX-20180112 … PX-20180116)
(25, 1,  1, 1,  1,  N'XuấtKho', 'PX-20180112', -50,  150,  5, '2018-01-12 14:00:00'),
(26, 16, 5, 23, 10, N'XuấtKho', 'PX-20180112', -30,  120,  5, '2018-01-12 14:00:00'),
(27, 17, 5, 24, 11, N'XuấtKho', 'PX-20180112', -20,  130,  5, '2018-01-12 14:00:00'),
(28, 23, 6, 33, 17, N'XuấtKho', 'PX-20180113', -100, 400,  5, '2018-01-13 10:00:00'),
(29, 24, 6, 34, 18, N'XuấtKho', 'PX-20180113', -80,  400,  5, '2018-01-13 10:00:00'),
(30, 25, 6, 35, 19, N'XuấtKho', 'PX-20180114', -60,  400,  5, '2018-01-14 09:00:00'),
(31, 26, 6, 36, 20, N'XuấtKho', 'PX-20180114', -80,  400,  5, '2018-01-14 09:00:00'),
(32, 2,  1, 2,  2,  N'XuấtKho', 'PX-20180115', -100, 250,  5, '2018-01-15 11:00:00'),
(33, 3,  1, 3,  3,  N'XuấtKho', 'PX-20180115', -100, 210,  5, '2018-01-15 11:00:00'),
(34, 13, 3, 14, 7,  N'XuấtKho', 'PX-20180115', -100, 100,  5, '2018-01-15 11:00:00'),
(35, 14, 3, 15, 8,  N'XuấtKho', 'PX-20180115', -50,  100,  5, '2018-01-15 11:30:00'),
(36, 27, 6, 37, 21, N'XuấtKho', 'PX-20180116', -60,  500,  5, '2018-01-16 10:00:00'),
(37, 28, 6, 38, 22, N'XuấtKho', 'PX-20180116', -100, 500,  5, '2018-01-16 10:00:00'),
(38, 4,  1, 4,  4,  N'XuấtKho', 'PX-20180116', -30,  250,  5, '2018-01-16 11:00:00'),
(39, 19, 5, 26, 13, N'XuấtKho', 'PX-20180116', -20,  100,  5, '2018-01-16 11:00:00'),
(40, 20, 5, 27, 14, N'XuấtKho', 'PX-20180116', -30,  100,  5, '2018-01-16 11:00:00'),
(41, 15, 3, 16, 9,  N'XuấtKho', 'PX-20180116', -30,  150,  5, '2018-01-16 11:30:00'),
(42, 6,  1, 6,  6,  N'XuấtKho', 'PX-20180116', -10,  200,  5, '2018-01-16 14:00:00');
SET IDENTITY_INSERT GiaoDichKho OFF;
GO

SET IDENTITY_INSERT PhieuKiemKe ON;
INSERT INTO PhieuKiemKe (MaPKK, SoPhieu, NgayLap, MaKho, MaNV_Kiem, MaNV_Duyet, TrangThai) VALUES
(1, 'KK-20180131-01', '2018-01-31 08:00:00', 1, 5, 6, N'ĐãDuyệt'),
(2, 'KK-20180131-02', '2018-01-31 10:00:00', 5, 5, 6, N'ĐãDuyệt');
SET IDENTITY_INSERT PhieuKiemKe OFF;
GO

SET IDENTITY_INSERT CT_PhieuKiemKe ON;
INSERT INTO CT_PhieuKiemKe (MaCTKK, MaPKK, MaSP, MaBin, MaLo, SoLuongHeThong, SoLuongThucTe, LyDoLech) VALUES
-- Phiếu 1 – Kho 1 (Rau củ quả)
(1, 1, 1, 1,  1,  150, 148, N'Hao hụt tự nhiên do bay hơi'),
(2, 1, 2, 2,  2,  250, 250, NULL),
(3, 1, 3, 3,  3,  210, 209, N'1 đơn vị hư hỏng do vỡ'),
(4, 1, 6, 6,  6,  200, 200, NULL),
-- Phiếu 2 – Kho 5 (Hàng khô tổng hợp)
(5, 2, 16, 23, 10, 120, 120, NULL),
(6, 2, 17, 24, 11, 130, 128, N'2 đơn vị vỡ hỏng do rơi kệ'),
(7, 2, 18, 25, 12, 130, 130, NULL);
SET IDENTITY_INSERT CT_PhieuKiemKe OFF;
GO

SET IDENTITY_INSERT PhieuChuyenKho ON;
INSERT INTO PhieuChuyenKho (MaPCK, SoPhieu, NgayLap, MaKhoNguon, MaKhoDich, MaNV, TrangThai) VALUES
(1, 'CK-20180120-01', '2018-01-20 09:00:00', 1, 2, 3, N'ChờXuất'),
(2, 'CK-20180125-01', '2018-01-25 10:00:00', 5, 4, 3, N'ChờXuất');
SET IDENTITY_INSERT PhieuChuyenKho OFF;
GO

SET IDENTITY_INSERT CT_PhieuChuyenKho ON;
INSERT INTO CT_PhieuChuyenKho (MaCTCK, MaPCK, MaSP, MaLo, MaBinNguon, MaBinDich, SoLuong) VALUES
(1, 1, 3,  3,  3,  9,  50),
(2, 2, 16, 10, 23, 20, 30);
SET IDENTITY_INSERT CT_PhieuChuyenKho OFF;
GO

SET IDENTITY_INSERT NhaVanChuyen ON;
INSERT INTO NhaVanChuyen (MaNVC, TenNVC, SoDienThoai, TrangThai) VALUES
(1, N'Giao Hàng Nhanh (GHN)',          '1900636677', 1),
(2, N'Giao Hàng Tiết Kiệm (GHTK)',     '1900636056', 1),
(3, N'J&T Express Việt Nam',            '1900636949', 1),
(4, N'Viettel Post',                    '18001511',   1),
(5, N'Vietnam Post (VN Post)',          '18001255',   1);
SET IDENTITY_INSERT NhaVanChuyen OFF;
GO

SET IDENTITY_INSERT VanDon ON;
INSERT INTO VanDon (MaVD, MaPX, MaNVC, SoVanDon, PhiVanChuyen, TrangThaiGiaoHang, NgayGiaoThucTe) VALUES
(1, 1, 1, 'GHNBH20180112-0001', 1500000.00, N'ThànhCông', '2018-01-14 15:30:00'),
(2, 2, 4, 'VTP-201801-0002',    2200000.00, N'ThànhCông', '2018-01-15 10:00:00'),
(3, 3, 2, 'S-GHTK-20180114-03',  800000.00, N'ThànhCông', '2018-01-16 11:30:00'),
(4, 4, 3, 'JT-VN32020180115-04',1200000.00, N'ThànhCông', '2018-01-17 09:00:00'),
(5, 5, 4, 'VTP-201801-0005',     150000.00, N'ThànhCông', '2018-01-18 14:00:00');
SET IDENTITY_INSERT VanDon OFF;
GO

SET IDENTITY_INSERT Quyen ON;
INSERT INTO Quyen (MaQuyen, TenQuyen, MoTa) VALUES
(1,  'XemDanhSachSP',       N'Xem danh sách và thông tin sản phẩm'),
(2,  'ThemSuaXoaSP',        N'Thêm, sửa, xóa thông tin sản phẩm'),
(3,  'QuanLyDanhMuc',       N'Quản lý danh mục sản phẩm'),
(4,  'TaoPhieuNhap',        N'Tạo phiếu nhập kho'),
(5,  'DuyetPhieuNhap',      N'Duyệt phiếu nhập kho'),
(6,  'HuyPhieuNhap',        N'Hủy phiếu nhập kho đã duyệt'),
(7,  'XemPhieuNhapXuat',    N'Xem phiếu nhập/xuất kho'),
(8,  'TaoPhieuXuat',        N'Tạo phiếu xuất kho'),
(9,  'DuyetPhieuXuat',      N'Duyệt phiếu xuất kho'),
(10, 'TaoPhieuChuyenKho',   N'Tạo phiếu điều chuyển kho'),
(11, 'DuyetPhieuChuyenKho', N'Duyệt phiếu điều chuyển kho'),
(12, 'TaoPhieuKiemKe',      N'Tạo và thực hiện phiếu kiểm kê'),
(13, 'DuyetPhieuKiemKe',    N'Duyệt kết quả kiểm kê'),
(14, 'QuanLyNCC',           N'Quản lý nhà cung cấp'),
(15, 'QuanLyNhanVien',      N'Quản lý thông tin nhân viên'),
(16, 'XemBaoCao',           N'Xem báo cáo tồn kho và giao dịch'),
(17, 'QuanLyTaiKhoan',      N'Quản lý tài khoản và phân quyền');
SET IDENTITY_INSERT Quyen OFF;
GO

INSERT INTO VaiTro_Quyen (MaVT, MaQuyen) VALUES
-- QuảnTrịViên: tất cả 17 quyền
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),
(1,11),(1,12),(1,13),(1,14),(1,15),(1,16),(1,17),
-- ThủKho: tạo phiếu nhập, duyệt xuất, xem, tạo chuyển kho, duyệt chuyển kho
(2,1),(2,4),(2,7),(2,8),(2,10),(2,11),
-- KếToán: xem phiếu, xem báo cáo
(3,7),(3,16),
-- KiểmKê: xem phiếu, tạo phiếu kiểm kê
(4,7),(4,12),
-- GiámSát: xem SP, duyệt nhập, xem phiếu, tạo chuyển kho, duyệt kiểm kê, xem báo cáo
(5,1),(5,5),(5,7),(5,10),(5,13),(5,16);
GO
