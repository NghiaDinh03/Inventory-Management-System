using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IMS.Web.Models;
using IMS.Web.Services;

namespace IMS.Web.Controllers
{
    [Authorize]
    public class DanhMucController : Controller
    {
        private readonly IDanhMucService _danhMucService;

        public DanhMucController(IDanhMucService danhMucService)
        {
            _danhMucService = danhMucService;
        }

        public async Task<IActionResult> Index()
        {
            ViewData["Title"] = "Danh mục sản phẩm";
            var list = await _danhMucService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public IActionResult Create()
        {
            ViewData["Title"] = "Thêm danh mục";
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(DanhMuc danhMuc)
        {
            if (ModelState.IsValid)
            {
                bool success = await _danhMucService.CreateAsync(danhMuc);
                if (success)
                {
                    TempData["Success"] = "Thêm danh mục mới thành công!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "Đã xảy ra lỗi khi tạo danh mục. Có thể tên danh mục đã bị trùng.");
            }
            ViewData["Title"] = "Thêm danh mục";
            return View(danhMuc);
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["Title"] = "Sửa danh mục";
            var dm = await _danhMucService.GetByIdAsync(id);
            if (dm == null)
            {
                return NotFound();
            }
            return View(dm);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(DanhMuc danhMuc)
        {
            if (ModelState.IsValid)
            {
                bool success = await _danhMucService.UpdateAsync(danhMuc);
                if (success)
                {
                    TempData["Success"] = "Cập nhật danh mục thành công!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "Đã xảy ra lỗi khi cập nhật danh mục.");
            }
            ViewData["Title"] = "Sửa danh mục";
            return View(danhMuc);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            bool success = await _danhMucService.DeleteAsync(id);
            if (success)
            {
                TempData["Success"] = "Xóa danh mục thành công!";
            }
            else
            {
                TempData["Error"] = "Không thể xóa danh mục này do có ràng buộc dữ liệu.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
