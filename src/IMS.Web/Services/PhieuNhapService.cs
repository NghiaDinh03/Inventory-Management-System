using IMS.Web.Data;
using IMS.Web.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace IMS.Web.Services
{
    public class PhieuNhapService : IPhieuNhapService
    {
        private readonly AppDbContext _context;

        public PhieuNhapService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<PhieuNhap>> GetAllAsync()
        {
            return await _context.PhieuNhaps
                .Include(p => p.NhaCungCap)
                .Include(p => p.Kho)
                .Include(p => p.NhanVien)
                .OrderByDescending(p => p.NgayLap)
                .AsNoTracking()
                .ToListAsync();
        }

        public async Task<PhieuNhap?> GetByIdAsync(int id)
        {
            return await _context.PhieuNhaps
                .Include(p => p.NhaCungCap)
                .Include(p => p.Kho)
                .Include(p => p.NhanVien)
                .Include(p => p.NhanVienDuyet)
                .Include(p => p.ChiTietPhieuNhaps!)
                    .ThenInclude(ct => ct.SanPham)
                .FirstOrDefaultAsync(p => p.MaPN == id);
        }

        public async Task<int> CreatePhieuNhapAsync(int maNCC, int maKho, int maNV, string? ghiChu, List<(int MaSP, int SoLuong, decimal DonGia)> chiTiet)
        {
            // 1. Create DataTable compatible with Table-Valued Parameter (TVP) ChiTietPhieuType
            var table = new DataTable();
            table.Columns.Add("MaSP", typeof(int));
            table.Columns.Add("SoLuong", typeof(int));
            table.Columns.Add("DonGia", typeof(decimal));

            foreach (var item in chiTiet)
            {
                table.Rows.Add(item.MaSP, item.SoLuong, item.DonGia);
            }

            // 2. Define SQL parameters
            var maNCCParam = new SqlParameter("@MaNCC", maNCC);
            var maKhoParam = new SqlParameter("@MaKho", maKho);
            var maNVParam = new SqlParameter("@MaNV", maNV);
            var ghiChuParam = new SqlParameter("@GhiChu", (object?)ghiChu ?? DBNull.Value);
            var chiTietParam = new SqlParameter("@ChiTiet", table)
            {
                SqlDbType = SqlDbType.Structured,
                TypeName = "dbo.ChiTietPhieuType"
            };

            // 3. Execute Stored Procedure and return the newly generated purchase order ID
            var ids = await _context.Database
                .SqlQueryRaw<int>("EXEC sp_TaoPhieuNhap @MaNCC, @MaKho, @MaNV, @GhiChu, @ChiTiet",
                    maNCCParam, maKhoParam, maNVParam, ghiChuParam, chiTietParam)
                .ToListAsync();

            return ids.FirstOrDefault();
        }

        public async Task<bool> DuyetPhieuAsync(int maPhieu, int maNV)
        {
            try
            {
                var loaiParam = new SqlParameter("@LoaiPhieu", "PN");
                var maPhieuParam = new SqlParameter("@MaPhieu", maPhieu);
                var maNVParam = new SqlParameter("@MaNV", maNV);

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC sp_DuyetPhieu @LoaiPhieu, @MaPhieu, @MaNV",
                    loaiParam, maPhieuParam, maNVParam);

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> HuyPhieuAsync(int maPhieu, int maNV, string lyDo)
        {
            try
            {
                var loaiParam = new SqlParameter("@LoaiPhieu", "PN");
                var maPhieuParam = new SqlParameter("@MaPhieu", maPhieu);
                var maNVParam = new SqlParameter("@MaNV", maNV);
                var lyDoParam = new SqlParameter("@LyDo", lyDo);

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC sp_HuyPhieu @LoaiPhieu, @MaPhieu, @MaNV, @LyDo",
                    loaiParam, maPhieuParam, maNVParam, lyDoParam);

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
