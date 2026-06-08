using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IMS.Web.Models;
using IMS.Web.Services;

namespace IMS.Web.Controllers
{
    [Authorize]
    public class NhaCungCapController : Controller
    {
        private readonly INhaCungCapService _nhaCungCapService;

        public NhaCungCapController(INhaCungCapService nhaCungCapService)
        {
            _nhaCungCapService = nhaCungCapService;
        }

        public async Task<IActionResult> Index()
        {
            ViewData["Title"] = "Nhà cung cấp";
            var list = await _nhaCungCapService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public IActionResult Create()
        {
            ViewData["Title"] = "Thêm nhà cung cấp";
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(NhaCungCap ncc)
        {
            if (ModelState.IsValid)
            {
                bool success = await _nhaCungCapService.CreateAsync(ncc);
                if (success)
                {
                    TempData["Success"] = "Thêm nhà cung cấp mới thành công!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "Đã xảy ra lỗi khi lưu nhà cung cấp.");
            }
            ViewData["Title"] = "Thêm nhà cung cấp";
            return View(ncc);
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["Title"] = "Sửa nhà cung cấp";
            var ncc = await _nhaCungCapService.GetByIdAsync(id);
            if (ncc == null)
            {
                return NotFound();
            }
            return View(ncc);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(NhaCungCap ncc)
        {
            if (ModelState.IsValid)
            {
                bool success = await _nhaCungCapService.UpdateAsync(ncc);
                if (success)
                {
                    TempData["Success"] = "Cập nhật thông tin nhà cung cấp thành công!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "Đã xảy ra lỗi khi cập nhật thông tin nhà cung cấp.");
            }
            ViewData["Title"] = "Sửa nhà cung cấp";
            return View(ncc);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            bool success = await _nhaCungCapService.DeleteAsync(id);
            if (success)
            {
                TempData["Success"] = "Xóa nhà cung cấp thành công!";
            }
            else
            {
                TempData["Error"] = "Không thể xóa nhà cung cấp này do đang có phiếu nhập kho liên quan.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
