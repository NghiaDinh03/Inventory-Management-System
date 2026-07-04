using IMS.Web.Models;
using IMS.Web.Models.Views;
using System.Data;

namespace IMS.Web.Services
{
    public interface ITaiKhoanService
    {
        Task<TaiKhoan?> LoginAsync(string username, string password);
        Task<bool> DoiMatKhauAsync(int maTK, string matKhauCu, string matKhauMoi);
    }

    public interface IDanhMucService
    {
        Task<List<DanhMuc>> GetAllAsync();
        Task<DanhMuc?> GetByIdAsync(int id);
        Task<bool> CreateAsync(DanhMuc danhMuc);
        Task<bool> UpdateAsync(DanhMuc danhMuc);
        Task<bool> DeleteAsync(int id);
    }

    public interface INhaCungCapService
    {
        Task<List<NhaCungCap>> GetAllAsync();
        Task<NhaCungCap?> GetByIdAsync(int id);
        Task<bool> CreateAsync(NhaCungCap ncc);
        Task<bool> UpdateAsync(NhaCungCap ncc);
        Task<bool> DeleteAsync(int id);
    }

    public interface IKhoService
    {
        Task<List<Kho>> GetAllAsync();
        Task<Kho?> GetByIdAsync(int id);
        Task<bool> CreateAsync(Kho kho);
        Task<bool> UpdateAsync(Kho kho);
        Task<bool> DeleteAsync(int id);
    }

    public interface ISanPhamService
    {
        Task<List<SanPham>> GetAllAsync();
        Task<SanPham?> GetByIdAsync(int id);
        Task<bool> CreateAsync(SanPham sanPham);
        Task<bool> UpdateAsync(SanPham sanPham);
        Task<bool> DeleteAsync(int id);
    }

    public interface IPhieuNhapService
    {
        Task<List<PhieuNhap>> GetAllAsync();
        Task<PhieuNhap?> GetByIdAsync(int id);
        Task<int> CreatePhieuNhapAsync(int maNCC, int maKho, int maNV, string? ghiChu, List<(int MaSP, int SoLuong, decimal DonGia)> chiTiet);
        Task<bool> DuyetPhieuAsync(int maPhieu, int maNV);
        Task<bool> HuyPhieuAsync(int maPhieu, int maNV, string lyDo);
    }

    public interface IPhieuXuatService
    {
        Task<List<PhieuXuat>> GetAllAsync();
        Task<PhieuXuat?> GetByIdAsync(int id);
        Task<int> CreatePhieuXuatAsync(int maKho, int maNV, string? nguoiNhan, string? ghiChu, List<(int MaSP, int SoLuong, decimal DonGia)> chiTiet);
        Task<bool> DuyetPhieuAsync(int maPhieu, int maNV);
        Task<bool> HuyPhieuAsync(int maPhieu, int maNV, string lyDo);
    }

    public interface ITonKhoService
    {
        Task<List<TonKhoHienTaiView>> GetTonKhoHienTaiAsync(int? maKho = null);
        Task<List<SanPhamDuoiTonToiThieuView>> GetSpDuoiTonToiThieuAsync();
    }

    public interface IDashboardService
    {
        Task<ThongKeTongQuatView> GetThongKeTongQuatAsync();
        Task<List<PhieuGanDayView>> GetPhieuGanDayAsync();
        Task<List<NhapXuatTheoNgayView>> GetNhapXuatTheoNgayAsync();
        Task<List<SanPhamDuoiTonToiThieuView>> GetSpDuoiTonToiThieuAsync();
    }

    public interface IBaoCaoService
    {
        Task<DataTable> GetBaoCaoTonKhoAsync(int? maKho, DateTime tuNgay, DateTime denNgay);
        Task<DataTable> GetBaoCaoNhapTheoNCCAsync(int? maNCC, DateTime tuNgay, DateTime denNgay);
        Task<DataTable> GetBaoCaoXuatTheoSPAsync(int? maSP, DateTime tuNgay, DateTime denNgay);
        Task<List<TopSanPhamXuatNhieuView>> GetTopSanPhamXuatNhieuAsync();
        Task<List<DoanhThuTheoThangView>> GetDoanhThuTheoThangAsync();
        
        
        Task<DataTable> ExecuteCursorCanhBaoTonAsync();
        Task<DataTable> ExecuteCursorTonCuoiKyAsync(int? maKho, DateTime tuNgay, DateTime denNgay);
    }

    public interface ISqlExecuteService
    {
        Task<DataTable> ExecuteQueryAsync(string sql);
        Task<int> ExecuteNonQueryAsync(string sql);
    }

    public interface IHeThongService
    {
        Task<bool> BackupDatabaseAsync(string path);
        Task<bool> RestoreDatabaseAsync(string path);
    }
}
