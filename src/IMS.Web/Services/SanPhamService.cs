using IMS.Web.Data;
using IMS.Web.Models;
using Microsoft.EntityFrameworkCore;

namespace IMS.Web.Services
{
    public class SanPhamService : ISanPhamService
    {
        private readonly AppDbContext _context;

        public SanPhamService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<SanPham>> GetAllAsync()
        {
            return await _context.SanPhams
                .Include(s => s.DanhMuc)
                .Include(s => s.GiaNhaps)
                .AsNoTracking()
                .ToListAsync();
        }

        public async Task<SanPham?> GetByIdAsync(int id)
        {
            return await _context.SanPhams
                .Include(s => s.DanhMuc)
                .Include(s => s.GiaNhaps)
                .FirstOrDefaultAsync(s => s.MaSP == id);
        }

        public async Task<bool> CreateAsync(SanPham sanPham)
        {
            sanPham.NgayTao = DateTime.Now;
            sanPham.NgayCapNhat = DateTime.Now;

            var giaNhapMoi = sanPham.GiaNhap;

            _context.SanPhams.Add(sanPham);
            var saved = await _context.SaveChangesAsync() > 0;

            if (saved && giaNhapMoi > 0)
            {
                var gia = new Gia
                {
                    MaSP = sanPham.MaSP,
                    NgayLap = DateTime.Now,
                    DonGiaNhap = giaNhapMoi
                };
                _context.Gias.Add(gia);
                await _context.SaveChangesAsync();
            }
            return saved;
        }

        public async Task<bool> UpdateAsync(SanPham sanPham)
        {
            var existing = await _context.SanPhams
                .Include(s => s.GiaNhaps)
                .FirstOrDefaultAsync(s => s.MaSP == sanPham.MaSP);
            if (existing == null) return false;

            existing.TenSP = sanPham.TenSP;
            existing.MaDanhMuc = sanPham.MaDanhMuc;
            existing.DonVi = sanPham.DonVi;
            existing.MaVach = sanPham.MaVach;
            existing.GiaBan = sanPham.GiaBan;
            existing.TonToiThieu = sanPham.TonToiThieu;
            existing.HinhAnh = sanPham.HinhAnh;
            existing.MoTa = sanPham.MoTa;
            existing.TrangThai = sanPham.TrangThai;
            existing.NgayCapNhat = DateTime.Now;

            var giaNhapCu = existing.GiaNhaps?.OrderByDescending(g => g.NgayLap).FirstOrDefault()?.DonGiaNhap ?? 0;
            if (sanPham.GiaNhap != giaNhapCu)
            {
                var giaMoi = new Gia
                {
                    MaSP = existing.MaSP,
                    NgayLap = DateTime.Now,
                    DonGiaNhap = sanPham.GiaNhap
                };
                _context.Gias.Add(giaMoi);
            }

            _context.Entry(existing).State = EntityState.Modified;
            return await _context.SaveChangesAsync() > 0;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var sp = await _context.SanPhams.FindAsync(id);
            if (sp == null) return false;
            
            
            
            _context.SanPhams.Remove(sp);
            return await _context.SaveChangesAsync() > 0;
        }
    }
}
