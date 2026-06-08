using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using IMS.Web.Services;
using System.Data;

namespace IMS.Web.Controllers
{
    [Authorize]
    public class BaoCaoController : Controller
    {
        private readonly IBaoCaoService _baocaoService;
        private readonly IKhoService _khoService;
        private readonly INhaCungCapService _nhaCungCapService;
        private readonly ISanPhamService _sanPhamService;

        public BaoCaoController(
            IBaoCaoService baocaoService,
            IKhoService khoService,
            INhaCungCapService nhaCungCapService,
            ISanPhamService sanPhamService)
        {
            _baocaoService = baocaoService;
            _khoService = khoService;
            _nhaCungCapService = nhaCungCapService;
            _sanPhamService = sanPhamService;
        }

        // Báo cáo 1: Báo cáo tồn kho chi tiết đầu/cuối kỳ (Gọi SP sp_BaoCaoTonKho)
        [HttpGet]
        public async Task<IActionResult> TonKhoKy(int? maKho, DateTime? tuNgay, DateTime? denNgay)
        {
            ViewData["Title"] = "Báo cáo tồn kho theo kỳ";

            var khos = await _khoService.GetAllAsync();
            ViewBag.Khos = new SelectList(khos.Where(k => k.TrangThai), "MaKho", "TenKho", maKho);

            // Mặc định khoảng thời gian 30 ngày gần nhất nếu không truyền
            var end = denNgay ?? DateTime.Now;
            var start = tuNgay ?? end.AddDays(-30);
            ViewBag.TuNgay = start.ToString("yyyy-MM-dd");
            ViewBag.DenNgay = end.ToString("yyyy-MM-dd");

            var dataTable = await _baocaoService.GetBaoCaoTonKhoAsync(maKho, start, end);
            return View(dataTable);
        }

        // Báo cáo 2: Báo cáo nhập hàng theo nhà cung cấp (Gọi SP sp_BaoCaoNhapTheoNCC)
        [HttpGet]
        public async Task<IActionResult> NhapNCC(int? maNCC, DateTime? tuNgay, DateTime? denNgay)
        {
            ViewData["Title"] = "Báo cáo nhập hàng theo NCC";

            var nccs = await _nhaCungCapService.GetAllAsync();
            ViewBag.NhaCungCaps = new SelectList(nccs.Where(n => n.TrangThai), "MaNCC", "TenNCC", maNCC);

            var end = denNgay ?? DateTime.Now;
            var start = tuNgay ?? end.AddDays(-30);
            ViewBag.TuNgay = start.ToString("yyyy-MM-dd");
            ViewBag.DenNgay = end.ToString("yyyy-MM-dd");

            var dataTable = await _baocaoService.GetBaoCaoNhapTheoNCCAsync(maNCC, start, end);
            return View(dataTable);
        }

        // Báo cáo 3: Báo cáo xuất hàng theo sản phẩm (Gọi SP sp_BaoCaoXuatTheoSP)
        [HttpGet]
        public async Task<IActionResult> XuatSP(int? maSP, DateTime? tuNgay, DateTime? denNgay)
        {
            ViewData["Title"] = "Báo cáo xuất hàng theo sản phẩm";

            var spps = await _sanPhamService.GetAllAsync();
            ViewBag.SanPhams = new SelectList(spps.Where(s => s.TrangThai), "MaSP", "TenSP", maSP);

            var end = denNgay ?? DateTime.Now;
            var start = tuNgay ?? end.AddDays(-30);
            ViewBag.TuNgay = start.ToString("yyyy-MM-dd");
            ViewBag.DenNgay = end.ToString("yyyy-MM-dd");

            var dataTable = await _baocaoService.GetBaoCaoXuatTheoSPAsync(maSP, start, end);
            return View(dataTable);
        }

        // Báo cáo 4: Cảnh báo tồn thấp sử dụng Cursor (Gọi SP sp_CursorCanhBaoTon)
        [HttpGet]
        public async Task<IActionResult> CanhBaoCursor()
        {
            ViewData["Title"] = "Cảnh báo tồn kho thấp (Báo cáo Cursor)";
            var dataTable = await _baocaoService.ExecuteCursorCanhBaoTonAsync();
            return View(dataTable);
        }

        // Báo cáo 5: Xu hướng nhập xuất & doanh thu (Gọi các View v_TopSanPhamXuatNhieu và v_DoanhThuTheoThang)
        [HttpGet]
        public async Task<IActionResult> XuHuong()
        {
            ViewData["Title"] = "Phân tích xu hướng & Doanh số";
            
            var topSp = await _baocaoService.GetTopSanPhamXuatNhieuAsync();
            var doanhThu = await _baocaoService.GetDoanhThuTheoThangAsync();

            ViewBag.TopSanPham = topSp;
            ViewBag.DoanhThuTheoThang = doanhThu;

            return View();
        }
    }
}
