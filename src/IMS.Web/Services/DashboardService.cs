using IMS.Web.Data;
using IMS.Web.Models.Views;
using Microsoft.EntityFrameworkCore;

namespace IMS.Web.Services
{
    public class DashboardService : IDashboardService
    {
        private readonly AppDbContext _context;

        public DashboardService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<ThongKeTongQuatView> GetThongKeTongQuatAsync()
        {
            var thongKe = await _context.ThongKeTongQuatViews.AsNoTracking().FirstOrDefaultAsync();
            return thongKe ?? new ThongKeTongQuatView();
        }

        public async Task<List<PhieuGanDayView>> GetPhieuGanDayAsync()
        {
            return await _context.PhieuGanDayViews.AsNoTracking().ToListAsync();
        }

        public async Task<List<NhapXuatTheoNgayView>> GetNhapXuatTheoNgayAsync()
        {
            return await _context.NhapXuatTheoNgayViews.AsNoTracking().ToListAsync();
        }

        public async Task<List<SanPhamDuoiTonToiThieuView>> GetSpDuoiTonToiThieuAsync()
        {
            return await _context.SanPhamDuoiTonToiThieuViews.AsNoTracking().ToListAsync();
        }
    }
}
