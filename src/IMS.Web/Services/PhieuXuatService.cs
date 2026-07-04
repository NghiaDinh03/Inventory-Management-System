using IMS.Web.Data;
using IMS.Web.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace IMS.Web.Services
{
    public class PhieuXuatService : IPhieuXuatService
    {
        private readonly AppDbContext _context;

        public PhieuXuatService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<PhieuXuat>> GetAllAsync()
        {
            return await _context.PhieuXuats
                .Include(p => p.Kho)
                .Include(p => p.NhanVien)
                .OrderByDescending(p => p.NgayLap)
                .AsNoTracking()
                .ToListAsync();
        }

        public async Task<PhieuXuat?> GetByIdAsync(int id)
        {
            return await _context.PhieuXuats
                .Include(p => p.Kho)
                .Include(p => p.NhanVien)
                .Include(p => p.NhanVienDuyet)
                .Include(p => p.ChiTietPhieuXuats!)
                    .ThenInclude(ct => ct.SanPham)
                .FirstOrDefaultAsync(p => p.MaPX == id);
        }

        public async Task<int> CreatePhieuXuatAsync(int maKho, int maNV, string? nguoiNhan, string? ghiChu, List<(int MaSP, int SoLuong, decimal DonGia)> chiTiet)
        {
            
            var table = new DataTable();
            table.Columns.Add("MaSP", typeof(int));
            table.Columns.Add("SoLuong", typeof(int));
            table.Columns.Add("DonGia", typeof(decimal));

            foreach (var item in chiTiet)
            {
                table.Rows.Add(item.MaSP, item.SoLuong, item.DonGia);
            }

            
            var maKhoParam = new SqlParameter("@MaKho", maKho);
            var maNVParam = new SqlParameter("@MaNV", maNV);
            var nguoiNhanParam = new SqlParameter("@NguoiNhan", (object?)nguoiNhan ?? DBNull.Value);
            var ghiChuParam = new SqlParameter("@GhiChu", (object?)ghiChu ?? DBNull.Value);
            var chiTietParam = new SqlParameter("@ChiTiet", table)
            {
                SqlDbType = SqlDbType.Structured,
                TypeName = "dbo.ChiTietPhieuType"
            };

            
            var ids = await _context.Database
                .SqlQueryRaw<int>("EXEC sp_TaoPhieuXuat @MaKho, @MaNV, @NguoiNhan, @GhiChu, @ChiTiet",
                    maKhoParam, maNVParam, nguoiNhanParam, ghiChuParam, chiTietParam)
                .ToListAsync();

            return ids.FirstOrDefault();
        }

        public async Task<bool> DuyetPhieuAsync(int maPhieu, int maNV)
        {
            try
            {
                var loaiParam = new SqlParameter("@LoaiPhieu", "PX");
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
                var loaiParam = new SqlParameter("@LoaiPhieu", "PX");
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
