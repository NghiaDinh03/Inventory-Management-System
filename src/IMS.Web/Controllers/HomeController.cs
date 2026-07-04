using System.Diagnostics;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IMS.Web.Models;
using IMS.Web.Services;

namespace IMS.Web.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        private readonly IDashboardService _dashboardService;
        private readonly ILogger<HomeController> _logger;

        public HomeController(IDashboardService dashboardService, ILogger<HomeController> logger)
        {
            _dashboardService = dashboardService;
            _logger = logger;
        }

        public async Task<IActionResult> Index()
        {
            ViewData["Title"] = "Tá»•ng quan";
            
            var model = new DashboardViewModel
            {
                ThongKe = await _dashboardService.GetThongKeTongQuatAsync(),
                PhieuGanDay = await _dashboardService.GetPhieuGanDayAsync(),
                NhapXuatTheoNgay = await _dashboardService.GetNhapXuatTheoNgayAsync(),
                SpDuoiTonToiThieu = await _dashboardService.GetSpDuoiTonToiThieuAsync()
            };

            return View(model);
        }

        public IActionResult Privacy()
        {
            ViewData["Title"] = "ChÃ­nh sÃ¡ch báº£o máº­t";
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}

