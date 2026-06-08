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
            ViewData["Title"] = "Phiếu xuất kho";
            var list = await _phieuXuatService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public async Task<IActionResult> Details(int id)
        {
            ViewData["Title"] = "Chi tiết phiếu xuất";
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
            ViewData["Title"] = "Lập phiếu xuất kho";
            
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
                TempData["Error"] = "Vui lòng thêm ít nhất một sản phẩm vào phiếu xuất.";
                return RedirectToAction(nameof(Create));
            }

            var chiTiet = new List<(int MaSP, int SoLuong, decimal DonGia)>();
            for (int i = 0; i < maSP.Count; i++)
            {
                if (soLuong[i] <= 0 || donGia[i] < 0)
                {
                    TempData["Error"] = "Số lượng phải lớn hơn 0 và đơn giá không được âm.";
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
                TempData["Success"] = "Tạo phiếu xuất mới thành công!";
                return RedirectToAction(nameof(Details), new { id = maPX });
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Đã xảy ra lỗi khi lập phiếu xuất: " + ex.Message;
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
                TempData["Success"] = "Duyệt phiếu xuất kho thành công! Số lượng tồn kho đã được trừ.";
            }
            else
            {
                TempData["Error"] = "Duyệt phiếu thất bại. Vui lòng kiểm tra lại số lượng tồn kho có đủ không.";
            }
            return RedirectToAction(nameof(Details), new { id });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Huy(int id, string lyDo)
        {
            if (string.IsNullOrEmpty(lyDo))
            {
                TempData["Error"] = "Vui lòng nhập lý do hủy phiếu.";
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
                TempData["Success"] = "Hủy phiếu xuất thành công! Đã cộng hoàn trả lại số lượng tồn kho.";
            }
            else
            {
                TempData["Error"] = "Hủy phiếu thất bại. Vui lòng thử lại.";
            }
            return RedirectToAction(nameof(Details), new { id });
        }

        // Action API to check current stock level of a product in a specific warehouse (called via AJAX in view)
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
