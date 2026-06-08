using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IMS.Web.Services;

namespace IMS.Web.Controllers
{
    [Authorize(Roles = "Admin")]
    public class HeThongController : Controller
    {
        private readonly IHeThongService _heThongService;

        public HeThongController(IHeThongService heThongService)
        {
            _heThongService = heThongService;
        }

        [HttpGet]
        public IActionResult Index()
        {
            ViewData["Title"] = "Sao lưu & Phục hồi hệ thống";
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Backup()
        {
            // Default directory in SQL Server container
            string backupFolder = "/var/opt/mssql/data/";
            
            // For local setup, this path can be customized. Under Docker-compose, "/var/opt/mssql/data/" is standard.
            bool success = await _heThongService.BackupDatabaseAsync(backupFolder);
            
            if (success)
            {

                string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
                string generatedFilename = $"InventoryDB_Backup_{timestamp}.bak";
                
                TempData["Success"] = $"Sao lưu dữ liệu thành công! File đã được lưu vào container SQL Server.";
                TempData["BackupFilename"] = generatedFilename;
            }
            else
            {
                TempData["Error"] = "Sao lưu dữ liệu thất bại. Vui lòng kiểm tra quyền ghi của SQL Server trên thư mục.";
            }

            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Restore(string backupFilename)
        {
            if (string.IsNullOrEmpty(backupFilename))
            {
                TempData["Error"] = "Vui lòng nhập tên file backup (.bak) cần phục hồi.";
                return RedirectToAction(nameof(Index));
            }

            string fullBackupPath = $"/var/opt/mssql/data/{backupFilename.Trim()}";

            bool success = await _heThongService.RestoreDatabaseAsync(fullBackupPath);
            if (success)
            {
                TempData["Success"] = $"Phục hồi cơ sở dữ liệu thành công từ file: {backupFilename}!";
            }
            else
            {
                TempData["Error"] = $"Phục hồi thất bại. Vui lòng đảm bảo file '{backupFilename}' tồn tại trong thư mục dữ liệu SQL Server (/var/opt/mssql/data/).";
            }

            return RedirectToAction(nameof(Index));
        }
    }
}
