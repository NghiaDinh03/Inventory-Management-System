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
            ViewData["Title"] = "Danh má»¥c sáº£n pháº©m";
            var list = await _danhMucService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public IActionResult Create()
        {
            ViewData["Title"] = "ThÃªm danh má»¥c";
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
                    TempData["Success"] = "ThÃªm danh má»¥c má»›i thÃ nh cÃ´ng!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "ÄÃ£ xáº£y ra lá»—i khi táº¡o danh má»¥c. CÃ³ thá»ƒ tÃªn danh má»¥c Ä‘Ã£ bá»‹ trÃ¹ng.");
            }
            ViewData["Title"] = "ThÃªm danh má»¥c";
            return View(danhMuc);
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["Title"] = "Sá»­a danh má»¥c";
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
                    TempData["Success"] = "Cáº­p nháº­t danh má»¥c thÃ nh cÃ´ng!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "ÄÃ£ xáº£y ra lá»—i khi cáº­p nháº­t danh má»¥c.");
            }
            ViewData["Title"] = "Sá»­a danh má»¥c";
            return View(danhMuc);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            bool success = await _danhMucService.DeleteAsync(id);
            if (success)
            {
                TempData["Success"] = "XÃ³a danh má»¥c thÃ nh cÃ´ng!";
            }
            else
            {
                TempData["Error"] = "KhÃ´ng thá»ƒ xÃ³a danh má»¥c nÃ y do cÃ³ rÃ ng buá»™c dá»¯ liá»‡u.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
