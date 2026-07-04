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

        
        [HttpGet]
        public async Task<IActionResult> TonKhoKy(int? maKho, DateTime? tuNgay, DateTime? denNgay)
        {
            ViewData["Title"] = "BÃ¡o cÃ¡o tá»“n kho theo ká»³";

            var khos = await _khoService.GetAllAsync();
            ViewBag.Khos = new SelectList(khos.Where(k => k.TrangThai), "MaKho", "TenKho", maKho);

            
            var end = denNgay ?? DateTime.Now;
            var start = tuNgay ?? end.AddDays(-30);
            ViewBag.TuNgay = start.ToString("yyyy-MM-dd");
            ViewBag.DenNgay = end.ToString("yyyy-MM-dd");

            var dataTable = await _baocaoService.GetBaoCaoTonKhoAsync(maKho, start, end);
            return View(dataTable);
        }

        
        [HttpGet]
        public async Task<IActionResult> NhapNCC(int? maNCC, DateTime? tuNgay, DateTime? denNgay)
        {
            ViewData["Title"] = "BÃ¡o cÃ¡o nháº­p hÃ ng theo NCC";

            var nccs = await _nhaCungCapService.GetAllAsync();
            ViewBag.NhaCungCaps = new SelectList(nccs.Where(n => n.TrangThai), "MaNCC", "TenNCC", maNCC);

            var end = denNgay ?? DateTime.Now;
            var start = tuNgay ?? end.AddDays(-30);
            ViewBag.TuNgay = start.ToString("yyyy-MM-dd");
            ViewBag.DenNgay = end.ToString("yyyy-MM-dd");

            var dataTable = await _baocaoService.GetBaoCaoNhapTheoNCCAsync(maNCC, start, end);
            return View(dataTable);
        }

        
        [HttpGet]
        public async Task<IActionResult> XuatSP(int? maSP, DateTime? tuNgay, DateTime? denNgay)
        {
            ViewData["Title"] = "BÃ¡o cÃ¡o xuáº¥t hÃ ng theo sáº£n pháº©m";

            var spps = await _sanPhamService.GetAllAsync();
            ViewBag.SanPhams = new SelectList(spps.Where(s => s.TrangThai), "MaSP", "TenSP", maSP);

            var end = denNgay ?? DateTime.Now;
            var start = tuNgay ?? end.AddDays(-30);
            ViewBag.TuNgay = start.ToString("yyyy-MM-dd");
            ViewBag.DenNgay = end.ToString("yyyy-MM-dd");

            var dataTable = await _baocaoService.GetBaoCaoXuatTheoSPAsync(maSP, start, end);
            return View(dataTable);
        }

        
        [HttpGet]
        public async Task<IActionResult> CanhBaoCursor()
        {
            ViewData["Title"] = "Cáº£nh bÃ¡o tá»“n kho tháº¥p (BÃ¡o cÃ¡o Cursor)";
            var dataTable = await _baocaoService.ExecuteCursorCanhBaoTonAsync();
            return View(dataTable);
        }

        
        [HttpGet]
        public async Task<IActionResult> XuHuong()
        {
            ViewData["Title"] = "PhÃ¢n tÃ­ch xu hÆ°á»›ng & Doanh sá»‘";
            
            var topSp = await _baocaoService.GetTopSanPhamXuatNhieuAsync();
            var doanhThu = await _baocaoService.GetDoanhThuTheoThangAsync();

            ViewBag.TopSanPham = topSp;
            ViewBag.DoanhThuTheoThang = doanhThu;

            return View();
        }
    }
}
