using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using IMS.Web.Services;

namespace IMS.Web.Controllers
{
    [Authorize]
    public class PhieuXuatController : Controller
    {
        private readonly IPhieuXuatService _phieuXuatService;
        private readonly IKhoService _khoService;
        private readonly ISanPhamService _sanPhamService;
        private readonly ITonKhoService _tonKhoService;

        public PhieuXuatController(
            IPhieuXuatService phieuXuatService,
            IKhoService khoService,
            ISanPhamService sanPhamService,
            ITonKhoService tonKhoService)
        {
            _phieuXuatService = phieuXuatService;
            _khoService = khoService;
            _sanPhamService = sanPhamService;
            _tonKhoService = tonKhoService;
        }

        public async Task<IActionResult> Index()
        {
            ViewData["Title"] = "Phiáº¿u xuáº¥t kho";
            var list = await _phieuXuatService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public async Task<IActionResult> Details(int id)
        {
            ViewData["Title"] = "Chi tiáº¿t phiáº¿u xuáº¥t";
            var phieu = await _phieuXuatService.GetByIdAsync(id);
            if (phieu == null)
            {
                return NotFound();
            }
            return View(phieu);
        }

        [HttpGet]
        public async Task<IActionResult> Create()
        {
            ViewData["Title"] = "Láº­p phiáº¿u xuáº¥t kho";
            
            var khos = await _khoService.GetAllAsync();
            var products = await _sanPhamService.GetAllAsync();

            ViewBag.Khos = new SelectList(khos.Where(k => k.TrangThai), "MaKho", "TenKho");
            ViewBag.SanPhams = products.Where(p => p.TrangThai).ToList();

            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(int maKho, string? nguoiNhan, string? ghiChu, List<int> maSP, List<int> soLuong, List<decimal> donGia)
        {
            if (maSP == null || !maSP.Any())
            {
                TempData["Error"] = "Vui lÃ²ng thÃªm Ã­t nháº¥t má»™t sáº£n pháº©m vÃ o phiáº¿u xuáº¥t.";
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
                int maPX = await _phieuXuatService.CreatePhieuXuatAsync(maKho, maNV, nguoiNhan, ghiChu, chiTiet);
                TempData["Success"] = "Táº¡o phiáº¿u xuáº¥t má»›i thÃ nh cÃ´ng!";
                return RedirectToAction(nameof(Details), new { id = maPX });
            }
            catch (Exception ex)
            {
                TempData["Error"] = "ÄÃ£ xáº£y ra lá»—i khi láº­p phiáº¿u xuáº¥t: " + ex.Message;
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

            bool success = await _phieuXuatService.DuyetPhieuAsync(id, maNV);
            if (success)
            {
                TempData["Success"] = "Duyá»‡t phiáº¿u xuáº¥t kho thÃ nh cÃ´ng! Sá»‘ lÆ°á»£ng tá»“n kho Ä‘Ã£ Ä‘Æ°á»£c trá»«.";
            }
            else
            {
                TempData["Error"] = "Duyá»‡t phiáº¿u tháº¥t báº¡i. Vui lÃ²ng kiá»ƒm tra láº¡i sá»‘ lÆ°á»£ng tá»“n kho cÃ³ Ä‘á»§ khÃ´ng.";
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

            bool success = await _phieuXuatService.HuyPhieuAsync(id, maNV, lyDo);
            if (success)
            {
                TempData["Success"] = "Há»§y phiáº¿u xuáº¥t thÃ nh cÃ´ng! ÄÃ£ cá»™ng hoÃ n tráº£ láº¡i sá»‘ lÆ°á»£ng tá»“n kho.";
            }
            else
            {
                TempData["Error"] = "Há»§y phiáº¿u tháº¥t báº¡i. Vui lÃ²ng thá»­ láº¡i.";
            }
            return RedirectToAction(nameof(Details), new { id });
        }

        
        [HttpGet]
        public async Task<IActionResult> GetStockLevel(int maSP, int maKho)
        {
            var tonKhoList = await _tonKhoService.GetTonKhoHienTaiAsync(maKho);
            var record = tonKhoList.FirstOrDefault(t => t.MaSP == maSP);
            int tonKho = record?.SoLuong ?? 0;
            return Json(new { tonKho });
        }
    }
}
