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
            ViewData["Title"] = "Sáº£n pháº©m";
            var list = await _sanPhamService.GetAllAsync();
            return View(list);
        }

        [HttpGet]
        public async Task<IActionResult> Create()
        {
            ViewData["Title"] = "ThÃªm sáº£n pháº©m";
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
                    TempData["Success"] = "ThÃªm sáº£n pháº©m má»›i thÃ nh cÃ´ng!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "ÄÃ£ xáº£y ra lá»—i khi táº¡o sáº£n pháº©m má»›i.");
            }
            
            var categories = await _danhMucService.GetAllAsync();
            ViewBag.DanhMucs = new SelectList(categories, "MaDanhMuc", "TenDanhMuc", sanPham.MaDanhMuc);
            ViewData["Title"] = "ThÃªm sáº£n pháº©m";
            return View(sanPham);
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["Title"] = "Sá»­a sáº£n pháº©m";
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
                    TempData["Success"] = "Cáº­p nháº­t thÃ´ng tin sáº£n pháº©m thÃ nh cÃ´ng!";
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "ÄÃ£ xáº£y ra lá»—i khi cáº­p nháº­t sáº£n pháº©m.");
            }

            var categories = await _danhMucService.GetAllAsync();
            ViewBag.DanhMucs = new SelectList(categories, "MaDanhMuc", "TenDanhMuc", sanPham.MaDanhMuc);
            ViewData["Title"] = "Sá»­a sáº£n pháº©m";
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
                    TempData["Success"] = "XÃ³a sáº£n pháº©m thÃ nh cÃ´ng!";
                }
                else
                {
                    TempData["Error"] = "XÃ³a sáº£n pháº©m tháº¥t báº¡i.";
                }
            }
            catch (Exception)
            {
                TempData["Error"] = "KhÃ´ng thá»ƒ xÃ³a sáº£n pháº©m nÃ y do Ä‘Ã£ phÃ¡t sinh trong cÃ¡c giao dá»‹ch nháº­p/xuáº¥t kho.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
