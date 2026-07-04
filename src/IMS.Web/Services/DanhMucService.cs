using IMS.Web.Data;
using IMS.Web.Models;
using Microsoft.EntityFrameworkCore;

namespace IMS.Web.Services
{
    public class DanhMucService : IDanhMucService
    {
        private readonly AppDbContext _context;

        public DanhMucService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<DanhMuc>> GetAllAsync()
        {
            return await _context.DanhMucs.AsNoTracking().ToListAsync();
        }

        public async Task<DanhMuc?> GetByIdAsync(int id)
        {
            return await _context.DanhMucs.FindAsync(id);
        }

        public async Task<bool> CreateAsync(DanhMuc danhMuc)
        {
            _context.DanhMucs.Add(danhMuc);
            return await _context.SaveChangesAsync() > 0;
        }

        public async Task<bool> UpdateAsync(DanhMuc danhMuc)
        {
            _context.Entry(danhMuc).State = EntityState.Modified;
            return await _context.SaveChangesAsync() > 0;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var dm = await _context.DanhMucs.FindAsync(id);
            if (dm == null) return false;
            _context.DanhMucs.Remove(dm);
            return await _context.SaveChangesAsync() > 0;
        }
    }
}
