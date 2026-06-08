using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using IMS.Web.Services;

namespace IMS.Web.Controllers
{
    [Authorize]
    public class TonKhoController : Controller
    {
        private readonly ITonKhoService _tonKhoService;
        private readonly IKhoService _khoService;

        public TonKhoController(ITonKhoService tonKhoService, IKhoService khoService)
        {
            _tonKhoService = tonKhoService;
            _khoService = khoService;
        }

        public async Task<IActionResult> Index(int? maKho)
        {
            ViewData["Title"] = "Báo cáo tồn kho hiện tại";

            var khos = await _khoService.GetAllAsync();
            ViewBag.Khos = new SelectList(khos.Where(k => k.TrangThai), "MaKho", "TenKho", maKho);

            var list = await _tonKhoService.GetTonKhoHienTaiAsync(maKho);
            
            return View(list);
        }
    }
}
