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
            ViewData["Title"] = "Phiếu nhập kho";
            var list = await _phieuNhapService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public async Task<IActionResult> Details(int id)
        {
            ViewData["Title"] = "Chi tiết phiếu nhập";
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
            ViewData["Title"] = "Tạo phiếu nhập kho";
            
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
                TempData["Error"] = "Vui lòng thêm ít nhất một sản phẩm vào phiếu nhập.";
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

            // Lấy MaNV từ Claims
            string? maNVClaim = User.FindFirst("MaNV")?.Value;
            if (string.IsNullOrEmpty(maNVClaim) || !int.TryParse(maNVClaim, out int maNV))
            {
                return RedirectToAction("Logout", "TaiKhoan");
            }

            try
            {
                int maPN = await _phieuNhapService.CreatePhieuNhapAsync(maNCC, maKho, maNV, ghiChu, chiTiet);
                TempData["Success"] = "Tạo phiếu nhập mới thành công!";
                return RedirectToAction(nameof(Details), new { id = maPN });
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Đã xảy ra lỗi khi lập phiếu nhập: " + ex.Message;
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
                TempData["Success"] = "Duyệt phiếu nhập kho thành công! Số lượng tồn kho đã được cập nhật.";
            }
            else
            {
                TempData["Error"] = "Duyệt phiếu thất bại. Vui lòng thử lại.";
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

            bool success = await _phieuNhapService.HuyPhieuAsync(id, maNV, lyDo);
            if (success)
            {
                TempData["Success"] = "Hủy phiếu nhập kho thành công! Đã hoàn trả lại số lượng tồn kho.";
            }
            else
            {
                TempData["Error"] = "Hủy phiếu thất bại. Có thể do số lượng tồn kho sẽ bị âm khi hoàn trả.";
            }
            return RedirectToAction(nameof(Details), new { id });
        }
    }
}
