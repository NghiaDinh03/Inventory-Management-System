using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IMS.Web.Models;
using IMS.Web.Services;

namespace IMS.Web.Controllers
{
    [Authorize]
    public class KhoController : Controller
    {
        private readonly IKhoService _khoService;

        public KhoController(IKhoService khoService)
        {
            _khoService = khoService;
        }

        public async Task<IActionResult> Index()
        {
            ViewData["Title"] = "Kho hàng";
            var list = await _khoService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public IActionResult Create()
        {
            ViewData["Title"] = "Thêm kho hàng";
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Kho kho)
        {
            if (ModelState.IsValid)
            {
                bool success = await _khoService.CreateAsync(kho);
                if (success)
                {
                    TempData["Success"] = "Thêm kho hàng mới thành công!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "Đã xảy ra lỗi khi tạo kho hàng mới.");
            }
            ViewData["Title"] = "Thêm kho hàng";
            return View(kho);
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["Title"] = "Sửa kho hàng";
            var kho = await _khoService.GetByIdAsync(id);
            if (kho == null)
            {
                return NotFound();
            }
            return View(kho);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Kho kho)
        {
            if (ModelState.IsValid)
            {
                bool success = await _khoService.UpdateAsync(kho);
                if (success)
                {
                    TempData["Success"] = "Cập nhật thông tin kho hàng thành công!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "Đã xảy ra lỗi khi cập nhật thông tin kho hàng.");
            }
            ViewData["Title"] = "Sửa kho hàng";
            return View(kho);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            bool success = await _khoService.DeleteAsync(id);
            if (success)
            {
                TempData["Success"] = "Xóa kho hàng thành công!";
            }
            else
            {
                TempData["Error"] = "Không thể xóa kho hàng này do có dữ liệu liên quan phát sinh.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
