using IMS.Web.Data;
using IMS.Web.Models;
using Microsoft.EntityFrameworkCore;

namespace IMS.Web.Services
{
    public class KhoService : IKhoService
    {
        private readonly AppDbContext _context;

        public KhoService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Kho>> GetAllAsync()
        {
            return await _context.Khos.AsNoTracking().ToListAsync();
        }

        public async Task<Kho?> GetByIdAsync(int id)
        {
            return await _context.Khos.FindAsync(id);
        }

        public async Task<bool> CreateAsync(Kho kho)
        {
            _context.Khos.Add(kho);
            return await _context.SaveChangesAsync() > 0;
        }

        public async Task<bool> UpdateAsync(Kho kho)
        {
            _context.Entry(kho).State = EntityState.Modified;
            return await _context.SaveChangesAsync() > 0;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var kho = await _context.Khos.FindAsync(id);
            if (kho == null) return false;
            _context.Khos.Remove(kho);
            return await _context.SaveChangesAsync() > 0;
        }
    }
}
