using IMS.Web.Data;
using IMS.Web.Models;
using Microsoft.EntityFrameworkCore;

namespace IMS.Web.Services
{
    public class NhaCungCapService : INhaCungCapService
    {
        private readonly AppDbContext _context;

        public NhaCungCapService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<NhaCungCap>> GetAllAsync()
        {
            return await _context.NhaCungCaps.AsNoTracking().ToListAsync();
        }

        public async Task<NhaCungCap?> GetByIdAsync(int id)
        {
            return await _context.NhaCungCaps.FindAsync(id);
        }

        public async Task<bool> CreateAsync(NhaCungCap ncc)
        {
            _context.NhaCungCaps.Add(ncc);
            return await _context.SaveChangesAsync() > 0;
        }

        public async Task<bool> UpdateAsync(NhaCungCap ncc)
        {
            _context.Entry(ncc).State = EntityState.Modified;
            return await _context.SaveChangesAsync() > 0;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var ncc = await _context.NhaCungCaps.FindAsync(id);
            if (ncc == null) return false;
            _context.NhaCungCaps.Remove(ncc);
            return await _context.SaveChangesAsync() > 0;
        }
    }
}
