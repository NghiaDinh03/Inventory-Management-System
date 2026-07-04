using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IMS.Web.Services;
using System.Data;

namespace IMS.Web.Controllers
{
    [Authorize]
    public class DemoController : Controller
    {
        private readonly ISqlExecuteService _sqlService;

        public DemoController(ISqlExecuteService sqlService)
        {
            _sqlService = sqlService;
        }

        [HttpGet]
        public IActionResult Index()
        {
            ViewData["Title"] = "Demo SQL Server (B1-B5)";
            return View();
        }

        
        [HttpPost]
        public async Task<IActionResult> ExecuteDemo([FromBody] DemoRequest request)
        {
            if (request == null || string.IsNullOrEmpty(request.ActionType))
            {
                return Json(new { success = false, message = "YÃªu cáº§u khÃ´ng há»£p lá»‡." });
            }

            try
            {
                if (request.ActionType == "GET_BEFORE_SP")
                {
                    string sql = @"
                        DECLARE @Details ChiTietPhieuType;
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (1, 10, 30000);
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (6, 5, 8000);
                        EXEC sp_TaoPhieuNhap @MaNCC = 1, @MaKho = 1, @MaNV = 1, @GhiChu = N'Demo purchase order executed via Web UI', @ChiTiet = @Details;
                    ";
                    await _sqlService.ExecuteNonQueryAsync(sql);
                    return Json(new { success = true, message = "Thá»±c thi sp_TaoPhieuNhap thÃ nh cÃ´ng! Phiáº¿u Ä‘Ã£ Ä‘Æ°á»£c táº¡o á»Ÿ tráº¡ng thÃ¡i NhÃ¡p." });
                }
                else if (request.ActionType == "GET_AFTER_SP")
                {
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT TOP 5 MaPN, SoPhieu, NgayLap, TrangThai, TongTien, GhiChu FROM PhieuNhap ORDER BY MaPN DESC");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "GET_BEFORE_TRIGGER_PASS")
                {
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT tk.MaKho, k.TenKho, tk.MaSP, sp.TenSP, tk.SoLuongTon AS SoLuong FROM TonKho tk JOIN Kho k ON tk.MaKho = k.MaKho JOIN SanPham sp ON tk.MaSP = sp.MaSP WHERE tk.MaSP = 1 AND tk.MaKho = 1");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_TRIGGER_PASS")
                {
                    string sql = @"
                        DECLARE @Details ChiTietPhieuType;
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (1, 2, 45000);
                        
                        DECLARE @OutID TABLE (ID INT);
                        INSERT INTO PhieuXuat (MaKho, MaNV, NguoiNhan, TrangThai, GhiChu)
                        OUTPUT inserted.MaPX INTO @OutID
                        VALUES (1, 1, N'Demo Buyer', N'NhÃ¡p', N'Demo sufficient stock issue');

                        DECLARE @MaPX INT = (SELECT TOP 1 ID FROM @OutID);
                        INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia)
                        SELECT @MaPX, MaSP, SoLuong, DonGia FROM @Details;

                        EXEC sp_DuyetPhieu @LoaiPhieu = 'PX', @MaPhieu = @MaPX, @MaNV = 1;
                    ";
                    await _sqlService.ExecuteNonQueryAsync(sql);
                    return Json(new { success = true, message = "Thá»±c thi duyá»‡t phiáº¿u xuáº¥t Ä‘á»§ hÃ ng thÃ nh cÃ´ng! Trigger trg_PhieuXuat_CapNhatTonKho Ä‘Ã£ tá»± Ä‘á»™ng trá»« 2 sáº£n pháº©m trong TonKho." });
                }
                else if (request.ActionType == "GET_AFTER_TRIGGER_PASS")
                {
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT tk.MaKho, k.TenKho, tk.MaSP, sp.TenSP, tk.SoLuongTon AS SoLuong FROM TonKho tk JOIN Kho k ON tk.MaKho = k.MaKho JOIN SanPham sp ON tk.MaSP = sp.MaSP WHERE tk.MaSP = 1 AND tk.MaKho = 1");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_TRIGGER_FAIL")
                {
                    string sql = @"
                        DECLARE @Details ChiTietPhieuType;
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (1, 500, 45000);
                        
                        DECLARE @OutID TABLE (ID INT);
                        INSERT INTO PhieuXuat (MaKho, MaNV, NguoiNhan, TrangThai, GhiChu)
                        OUTPUT inserted.MaPX INTO @OutID
                        VALUES (1, 1, N'Demo Buyer', N'NhÃ¡p', N'Demo insufficient stock issue');

                        DECLARE @MaPX INT = (SELECT TOP 1 ID FROM @OutID);
                        INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia)
                        SELECT @MaPX, MaSP, SoLuong, DonGia FROM @Details;

                        EXEC sp_DuyetPhieu @LoaiPhieu = 'PX', @MaPhieu = @MaPX, @MaNV = 1;
                    ";
                    await _sqlService.ExecuteNonQueryAsync(sql);
                    return Json(new { success = true, message = "Success?" }); 
                }
                else if (request.ActionType == "GET_BEFORE_FUNCTION")
                {
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT MaSP, TenSP, COALESCE((SELECT TOP 1 DonGiaNhap FROM Gia WHERE MaSP = SanPham.MaSP ORDER BY NgayLap DESC), 0) AS GiaNhap, GiaBan FROM SanPham WHERE MaSP IN (1, 2)");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_FUNCTION")
                {
                    string sql = "SELECT dbo.fn_TinhGiaTriTonKho(1) AS [Tá»•ng giÃ¡ trá»‹ tá»“n Kho 1 (VND)], dbo.fn_TinhGiaXuatBinhQuan(1) AS [GiÃ¡ xuáº¥t bÃ¬nh quan SP 1 (VND)]";
                    var dt = await _sqlService.ExecuteQueryAsync(sql);
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "GET_BEFORE_CURSOR")
                {
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT tk.MaSP, sp.TenSP, tk.SoLuongTon AS SoLuong, sp.TonToiThieu FROM TonKho tk JOIN SanPham sp ON tk.MaSP = sp.MaSP WHERE tk.SoLuongTon < sp.TonToiThieu");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_CURSOR")
                {
                    var dt = await _sqlService.ExecuteQueryAsync("EXEC sp_CursorCanhBaoTon");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }

                return Json(new { success = false, message = "HÃ nh Ä‘á»™ng khÃ´ng há»£p lá»‡." });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Lá»–I SQL SERVER: " + ex.Message });
            }
        }

        
        private List<Dictionary<string, object>> ConvertDataTableToList(DataTable dt)
        {
            var list = new List<Dictionary<string, object>>();
            foreach (DataRow row in dt.Rows)
            {
                var dict = new Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                {
                    dict[col.ColumnName] = row[col] == DBNull.Value ? "NULL" : row[col];
                }
                list.Add(dict);
            }
            return list;
        }
    }

    public class DemoRequest
    {
        public string ActionType { get; set; } = null!;
    }
}
