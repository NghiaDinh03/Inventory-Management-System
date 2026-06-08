using IMS.Web.Models.Views;

namespace IMS.Web.Models
{
    public class DashboardViewModel
    {
        public ThongKeTongQuatView ThongKe { get; set; } = null!;
        public List<PhieuGanDayView> PhieuGanDay { get; set; } = new();
        public List<NhapXuatTheoNgayView> NhapXuatTheoNgay { get; set; } = new();
        public List<SanPhamDuoiTonToiThieuView> SpDuoiTonToiThieu { get; set; } = new();
    }
}
