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
            ViewData["Title"] = "NhÃ  cung cáº¥p";
            var list = await _nhaCungCapService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public IActionResult Create()
        {
            ViewData["Title"] = "ThÃªm nhÃ  cung cáº¥p";
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
                    TempData["Success"] = "ThÃªm nhÃ  cung cáº¥p má»›i thÃ nh cÃ´ng!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "ÄÃ£ xáº£y ra lá»—i khi lÆ°u nhÃ  cung cáº¥p.");
            }
            ViewData["Title"] = "ThÃªm nhÃ  cung cáº¥p";
            return View(ncc);
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["Title"] = "Sá»­a nhÃ  cung cáº¥p";
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
                    TempData["Success"] = "Cáº­p nháº­t thÃ´ng tin nhÃ  cung cáº¥p thÃ nh cÃ´ng!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "ÄÃ£ xáº£y ra lá»—i khi cáº­p nháº­t thÃ´ng tin nhÃ  cung cáº¥p.");
            }
            ViewData["Title"] = "Sá»­a nhÃ  cung cáº¥p";
            return View(ncc);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            bool success = await _nhaCungCapService.DeleteAsync(id);
            if (success)
            {
                TempData["Success"] = "XÃ³a nhÃ  cung cáº¥p thÃ nh cÃ´ng!";
            }
            else
            {
                TempData["Error"] = "KhÃ´ng thá»ƒ xÃ³a nhÃ  cung cáº¥p nÃ y do Ä‘ang cÃ³ phiáº¿u nháº­p kho liÃªn quan.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
