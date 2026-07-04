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
            ViewData["Title"] = "Kho hÃ ng";
            var list = await _khoService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public IActionResult Create()
        {
            ViewData["Title"] = "ThÃªm kho hÃ ng";
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
                    TempData["Success"] = "ThÃªm kho hÃ ng má»›i thÃ nh cÃ´ng!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "ÄÃ£ xáº£y ra lá»—i khi táº¡o kho hÃ ng má»›i.");
            }
            ViewData["Title"] = "ThÃªm kho hÃ ng";
            return View(kho);
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["Title"] = "Sá»­a kho hÃ ng";
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
                    TempData["Success"] = "Cáº­p nháº­t thÃ´ng tin kho hÃ ng thÃ nh cÃ´ng!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "ÄÃ£ xáº£y ra lá»—i khi cáº­p nháº­t thÃ´ng tin kho hÃ ng.");
            }
            ViewData["Title"] = "Sá»­a kho hÃ ng";
            return View(kho);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            bool success = await _khoService.DeleteAsync(id);
            if (success)
            {
                TempData["Success"] = "XÃ³a kho hÃ ng thÃ nh cÃ´ng!";
            }
            else
            {
                TempData["Error"] = "KhÃ´ng thá»ƒ xÃ³a kho hÃ ng nÃ y do cÃ³ dá»¯ liá»‡u liÃªn quan phÃ¡t sinh.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
