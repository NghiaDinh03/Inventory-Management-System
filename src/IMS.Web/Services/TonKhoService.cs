using IMS.Web.Data;
using IMS.Web.Models.Views;
using Microsoft.EntityFrameworkCore;

namespace IMS.Web.Services
{
    public class TonKhoService : ITonKhoService
    {
        private readonly AppDbContext _context;

        public TonKhoService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<TonKhoHienTaiView>> GetTonKhoHienTaiAsync(int? maKho = null)
        {
            var query = _context.TonKhoHienTaiViews.AsNoTracking();
            
            if (maKho.HasValue)
            {
                query = query.Where(t => t.MaKho == maKho.Value);
            }
            
            return await query.ToListAsync();
        }

        public async Task<List<SanPhamDuoiTonToiThieuView>> GetSpDuoiTonToiThieuAsync()
        {
            return await _context.SanPhamDuoiTonToiThieuViews.AsNoTracking().ToListAsync();
        }
    }
}
