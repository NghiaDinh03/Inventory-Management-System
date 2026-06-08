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

        // Action API to get data before/after (B3/B5) and execute commands (B4) via AJAX
        [HttpPost]
        public async Task<IActionResult> ExecuteDemo([FromBody] DemoRequest request)
        {
            if (request == null || string.IsNullOrEmpty(request.ActionType))
            {
                return Json(new { success = false, message = "Yêu cầu không hợp lệ." });
            }

            try
            {
                if (request.ActionType == "GET_BEFORE_SP")
                {
                    // Execute SP to create purchase order by inserting raw SQL directly
                    // TVP is defined and passed directly to simplify the demonstration
                    string sql = @"
                        DECLARE @Details ChiTietPhieuType;
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (1, 10, 180000); -- Logitech G213
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (2, 5, 850000);  -- Logitech M331
                        EXEC sp_TaoPhieuNhap @MaNCC = 1, @MaKho = 1, @MaNV = 1, @GhiChu = N'Demo purchase order executed via Web UI', @ChiTiet = @Details;
                    ";
                    await _sqlService.ExecuteNonQueryAsync(sql);
                    return Json(new { success = true, message = "Thực thi sp_TaoPhieuNhap thành công! Phiếu đã được tạo ở trạng thái Nháp." });
                }
                else if (request.ActionType == "GET_AFTER_SP")
                {
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT TOP 5 MaPN, SoPhieu, NgayLap, TrangThai, TongTien, GhiChu FROM PhieuNhap ORDER BY MaPN DESC");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "GET_BEFORE_TRIGGER_PASS")
                {
                    // Check stock of MaSP = 1 (Logitech Mouse) in Kho = 3 beforehand
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT tk.MaKho, k.TenKho, tk.MaSP, sp.TenSP, tk.SoLuong FROM TonKho tk JOIN Kho k ON tk.MaKho = k.MaKho JOIN SanPham sp ON tk.MaSP = sp.MaSP WHERE tk.MaSP = 1 AND tk.MaKho = 3");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_TRIGGER_PASS")
                {
                    // Create draft goods issue in Kho 3 with qty = 2 (sufficient stock)
                    // Then approve it to trigger stock deduction trigger
                    string sql = @"
                        DECLARE @Details ChiTietPhieuType;
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (1, 2, 250000);
                        
                        DECLARE @OutID TABLE (ID INT);
                        INSERT INTO PhieuXuat (MaKho, MaNV, NguoiNhan, TrangThai, GhiChu)
                        OUTPUT inserted.MaPX INTO @OutID
                        VALUES (3, 1, N'Demo Buyer', N'Nháp', N'Demo sufficient stock issue');

                        DECLARE @MaPX INT = (SELECT TOP 1 ID FROM @OutID);
                        INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia)
                        SELECT @MaPX, MaSP, SoLuong, DonGia FROM @Details;

                        -- Approve issue to trigger stock deduction
                        EXEC sp_DuyetPhieu @LoaiPhieu = 'PX', @MaPhieu = @MaPX, @MaNV = 1;
                    ";
                    await _sqlService.ExecuteNonQueryAsync(sql);
                    return Json(new { success = true, message = "Thực thi duyệt phiếu xuất đủ hàng thành công! Trigger trg_PhieuXuat_CapNhatTonKho đã tự động trừ 2 sản phẩm trong TonKho." });
                }
                else if (request.ActionType == "GET_AFTER_TRIGGER_PASS")
                {
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT tk.MaKho, k.TenKho, tk.MaSP, sp.TenSP, tk.SoLuong FROM TonKho tk JOIN Kho k ON tk.MaKho = k.MaKho JOIN SanPham sp ON tk.MaSP = sp.MaSP WHERE tk.MaSP = 1 AND tk.MaKho = 3");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_TRIGGER_FAIL")
                {
                    // Attempt goods issue with qty = 100 (insufficient stock)
                    // Trigger will raise error and rollback transaction
                    string sql = @"
                        DECLARE @Details ChiTietPhieuType;
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (1, 100, 250000);
                        
                        DECLARE @OutID TABLE (ID INT);
                        INSERT INTO PhieuXuat (MaKho, MaNV, NguoiNhan, TrangThai, GhiChu)
                        OUTPUT inserted.MaPX INTO @OutID
                        VALUES (3, 1, N'Demo Buyer', N'Nháp', N'Demo insufficient stock issue');

                        DECLARE @MaPX INT = (SELECT TOP 1 ID FROM @OutID);
                        INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia)
                        SELECT @MaPX, MaSP, SoLuong, DonGia FROM @Details;

                        -- This triggers stock validation and raises error
                        EXEC sp_DuyetPhieu @LoaiPhieu = 'PX', @MaPhieu = @MaPX, @MaNV = 1;
                    ";
                    await _sqlService.ExecuteNonQueryAsync(sql);
                    return Json(new { success = true, message = "Success?" }); // This line is unreachable due to SQL error
                }
                else if (request.ActionType == "GET_BEFORE_FUNCTION")
                {
                    // Check original stock values in SanPham table for comparison
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT MaSP, TenSP, GiaNhap, GiaBan FROM SanPham WHERE MaSP IN (1, 2)");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_FUNCTION")
                {
                    // Execute SELECT using fn_TinhGiaTriTonKho and fn_TinhGiaXuatBinhQuan scalar functions
                    string sql = "SELECT dbo.fn_TinhGiaTriTonKho(1) AS [Tổng giá trị tồn Kho 1 (VND)], dbo.fn_TinhGiaXuatBinhQuan(1) AS [Giá xuất bình quân SP 1 (VND)]";
                    var dt = await _sqlService.ExecuteQueryAsync(sql);
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "GET_BEFORE_CURSOR")
                {
                    // View TonKho records where quantity is below minimum stock
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT tk.MaSP, sp.TenSP, tk.SoLuong, sp.TonToiThieu FROM TonKho tk JOIN SanPham sp ON tk.MaSP = sp.MaSP WHERE tk.SoLuong < sp.TonToiThieu");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_CURSOR")
                {
                    // Execute cursor-based SP sp_CursorCanhBaoTon
                    var dt = await _sqlService.ExecuteQueryAsync("EXEC sp_CursorCanhBaoTon");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }

                return Json(new { success = false, message = "Hành động không hợp lệ." });
            }
            catch (Exception ex)
            {
                // Return detailed error from SQL Server (including RAISERROR from trigger)
                return Json(new { success = false, message = "LỖI SQL SERVER: " + ex.Message });
            }
        }

        // Helper to convert DataTable to List of Dictionaries for JSON serialization
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
