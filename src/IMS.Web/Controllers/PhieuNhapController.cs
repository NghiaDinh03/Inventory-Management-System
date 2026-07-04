using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using IMS.Web.Services;

namespace IMS.Web.Controllers
{
    [Authorize]
    public class PhieuNhapController : Controller
    {
        private readonly IPhieuNhapService _phieuNhapService;
        private readonly INhaCungCapService _nhaCungCapService;
        private readonly IKhoService _khoService;
        private readonly ISanPhamService _sanPhamService;

        public PhieuNhapController(
            IPhieuNhapService phieuNhapService,
            INhaCungCapService nhaCungCapService,
            IKhoService khoService,
            ISanPhamService sanPhamService)
        {
            _phieuNhapService = phieuNhapService;
            _nhaCungCapService = nhaCungCapService;
            _khoService = khoService;
            _sanPhamService = sanPhamService;
        }

        public async Task<IActionResult> Index()
        {
            ViewData["Title"] = "Phiáº¿u nháº­p kho";
            var list = await _phieuNhapService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public async Task<IActionResult> Details(int id)
        {
            ViewData["Title"] = "Chi tiáº¿t phiáº¿u nháº­p";
            var phieu = await _phieuNhapService.GetByIdAsync(id);
            if (phieu == null)
            {
                return NotFound();
            }
            return View(phieu);
        }

        [HttpGet]
        public async Task<IActionResult> Create()
        {
            ViewData["Title"] = "Táº¡o phiáº¿u nháº­p kho";
            
            var nccs = await _nhaCungCapService.GetAllAsync();
            var khos = await _khoService.GetAllAsync();
            var products = await _sanPhamService.GetAllAsync();

            ViewBag.NhaCungCaps = new SelectList(nccs.Where(n => n.TrangThai), "MaNCC", "TenNCC");
            ViewBag.Khos = new SelectList(khos.Where(k => k.TrangThai), "MaKho", "TenKho");
            ViewBag.SanPhams = products.Where(p => p.TrangThai).ToList();

            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(int maNCC, int maKho, string? ghiChu, List<int> maSP, List<int> soLuong, List<decimal> donGia)
        {
            if (maSP == null || !maSP.Any())
            {
                TempData["Error"] = "Vui lÃ²ng thÃªm Ã­t nháº¥t má»™t sáº£n pháº©m vÃ o phiáº¿u nháº­p.";
                return RedirectToAction(nameof(Create));
            }

            var chiTiet = new List<(int MaSP, int SoLuong, decimal DonGia)>();
            for (int i = 0; i < maSP.Count; i++)
            {
                if (soLuong[i] <= 0 || donGia[i] < 0)
                {
                    TempData["Error"] = "Sá»‘ lÆ°á»£ng pháº£i lá»›n hÆ¡n 0 vÃ  Ä‘Æ¡n giÃ¡ khÃ´ng Ä‘Æ°á»£c Ã¢m.";
                    return RedirectToAction(nameof(Create));
                }
                chiTiet.Add((maSP[i], soLuong[i], donGia[i]));
            }

            
            string? maNVClaim = User.FindFirst("MaNV")?.Value;
            if (string.IsNullOrEmpty(maNVClaim) || !int.TryParse(maNVClaim, out int maNV))
            {
                return RedirectToAction("Logout", "TaiKhoan");
            }

            try
            {
                int maPN = await _phieuNhapService.CreatePhieuNhapAsync(maNCC, maKho, maNV, ghiChu, chiTiet);
                TempData["Success"] = "Táº¡o phiáº¿u nháº­p má»›i thÃ nh cÃ´ng!";
                return RedirectToAction(nameof(Details), new { id = maPN });
            }
            catch (Exception ex)
            {
                TempData["Error"] = "ÄÃ£ xáº£y ra lá»—i khi láº­p phiáº¿u nháº­p: " + ex.Message;
                return RedirectToAction(nameof(Create));
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Duyet(int id)
        {
            string? maNVClaim = User.FindFirst("MaNV")?.Value;
            if (string.IsNullOrEmpty(maNVClaim) || !int.TryParse(maNVClaim, out int maNV))
            {
                return RedirectToAction("Logout", "TaiKhoan");
            }

            bool success = await _phieuNhapService.DuyetPhieuAsync(id, maNV);
            if (success)
            {
                TempData["Success"] = "Duyá»‡t phiáº¿u nháº­p kho thÃ nh cÃ´ng! Sá»‘ lÆ°á»£ng tá»“n kho Ä‘Ã£ Ä‘Æ°á»£c cáº­p nháº­t.";
            }
            else
            {
                TempData["Error"] = "Duyá»‡t phiáº¿u tháº¥t báº¡i. Vui lÃ²ng thá»­ láº¡i.";
            }
            return RedirectToAction(nameof(Details), new { id });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Huy(int id, string lyDo)
        {
            if (string.IsNullOrEmpty(lyDo))
            {
                TempData["Error"] = "Vui lÃ²ng nháº­p lÃ½ do há»§y phiáº¿u.";
                return RedirectToAction(nameof(Details), new { id });
            }

            string? maNVClaim = User.FindFirst("MaNV")?.Value;
            if (string.IsNullOrEmpty(maNVClaim) || !int.TryParse(maNVClaim, out int maNV))
            {
                return RedirectToAction("Logout", "TaiKhoan");
            }

            bool success = await _phieuNhapService.HuyPhieuAsync(id, maNV, lyDo);
            if (success)
            {
                TempData["Success"] = "Há»§y phiáº¿u nháº­p kho thÃ nh cÃ´ng! ÄÃ£ hoÃ n tráº£ láº¡i sá»‘ lÆ°á»£ng tá»“n kho.";
            }
            else
            {
                TempData["Error"] = "Há»§y phiáº¿u tháº¥t báº¡i. CÃ³ thá»ƒ do sá»‘ lÆ°á»£ng tá»“n kho sáº½ bá»‹ Ã¢m khi hoÃ n tráº£.";
            }
            return RedirectToAction(nameof(Details), new { id });
        }
    }
}
