using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using IMS.Web.Models;
using IMS.Web.Services;

namespace IMS.Web.Controllers
{
    [Authorize]
    public class SanPhamController : Controller
    {
        private readonly ISanPhamService _sanPhamService;
        private readonly IDanhMucService _danhMucService;

        public SanPhamController(ISanPhamService sanPhamService, IDanhMucService danhMucService)
        {
            _sanPhamService = sanPhamService;
            _danhMucService = danhMucService;
        }

        public async Task<IActionResult> Index()
        {
            ViewData["Title"] = "Sản phẩm";
            var list = await _sanPhamService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public async Task<IActionResult> Create()
        {
            ViewData["Title"] = "Thêm sản phẩm";
            var categories = await _danhMucService.GetAllAsync();
            ViewBag.DanhMucs = new SelectList(categories, "MaDanhMuc", "TenDanhMuc");
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(SanPham sanPham)
        {
            if (ModelState.IsValid)
            {
                bool success = await _sanPhamService.CreateAsync(sanPham);
                if (success)
                {
                    TempData["Success"] = "Thêm sản phẩm mới thành công!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "Đã xảy ra lỗi khi tạo sản phẩm mới.");
            }
            
            var categories = await _danhMucService.GetAllAsync();
            ViewBag.DanhMucs = new SelectList(categories, "MaDanhMuc", "TenDanhMuc", sanPham.MaDanhMuc);
            ViewData["Title"] = "Thêm sản phẩm";
            return View(sanPham);
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["Title"] = "Sửa sản phẩm";
            var sp = await _sanPhamService.GetByIdAsync(id);
            if (sp == null)
            {
                return NotFound();
            }
            
            var categories = await _danhMucService.GetAllAsync();
            ViewBag.DanhMucs = new SelectList(categories, "MaDanhMuc", "TenDanhMuc", sp.MaDanhMuc);
            return View(sp);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(SanPham sanPham)
        {
            if (ModelState.IsValid)
            {
                bool success = await _sanPhamService.UpdateAsync(sanPham);
                if (success)
                {
                    TempData["Success"] = "Cập nhật thông tin sản phẩm thành công!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "Đã xảy ra lỗi khi cập nhật sản phẩm.");
            }

            var categories = await _danhMucService.GetAllAsync();
            ViewBag.DanhMucs = new SelectList(categories, "MaDanhMuc", "TenDanhMuc", sanPham.MaDanhMuc);
            ViewData["Title"] = "Sửa sản phẩm";
            return View(sanPham);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                bool success = await _sanPhamService.DeleteAsync(id);
                if (success)
                {
                    TempData["Success"] = "Xóa sản phẩm thành công!";
                }
                else
                {
                    TempData["Error"] = "Xóa sản phẩm thất bại.";
                }
            }
            catch (Exception)
            {
                TempData["Error"] = "Không thể xóa sản phẩm này do đã phát sinh trong các giao dịch nhập/xuất kho.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
