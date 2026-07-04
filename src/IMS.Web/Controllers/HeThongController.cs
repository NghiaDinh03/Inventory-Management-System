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
            ViewData["Title"] = "Sao lÆ°u & Phá»¥c há»“i há»‡ thá»‘ng";
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Backup()
        {
            
            string backupFolder = "/var/opt/mssql/data/";
            
            
            bool success = await _heThongService.BackupDatabaseAsync(backupFolder);
            
            if (success)
            {

                string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
                string generatedFilename = $"InventoryDB_Backup_{timestamp}.bak";
                
                TempData["Success"] = $"Sao lÆ°u dá»¯ liá»‡u thÃ nh cÃ´ng! File Ä‘Ã£ Ä‘Æ°á»£c lÆ°u vÃ o container SQL Server.";
                TempData["BackupFilename"] = generatedFilename;
            }
            else
            {
                TempData["Error"] = "Sao lÆ°u dá»¯ liá»‡u tháº¥t báº¡i. Vui lÃ²ng kiá»ƒm tra quyá»n ghi cá»§a SQL Server trÃªn thÆ° má»¥c.";
            }

            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Restore(string backupFilename)
        {
            if (string.IsNullOrEmpty(backupFilename))
            {
                TempData["Error"] = "Vui lÃ²ng nháº­p tÃªn file backup (.bak) cáº§n phá»¥c há»“i.";
                return RedirectToAction(nameof(Index));
            }

            string fullBackupPath = $"/var/opt/mssql/data/{backupFilename.Trim()}";

            bool success = await _heThongService.RestoreDatabaseAsync(fullBackupPath);
            if (success)
            {
                TempData["Success"] = $"Phá»¥c há»“i cÆ¡ sá»Ÿ dá»¯ liá»‡u thÃ nh cÃ´ng tá»« file: {backupFilename}!";
            }
            else
            {
                TempData["Error"] = $"Phá»¥c há»“i tháº¥t báº¡i. Vui lÃ²ng Ä‘áº£m báº£o file '{backupFilename}' tá»“n táº¡i trong thÆ° má»¥c dá»¯ liá»‡u SQL Server (/var/opt/mssql/data/).";
            }

            return RedirectToAction(nameof(Index));
        }
    }
}
