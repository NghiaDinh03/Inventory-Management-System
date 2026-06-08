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

        // Action API phục vụ lấy dữ liệu trước/sau (B3/B5) và thực thi câu lệnh (B4) qua AJAX
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
                    // Lấy 5 phiếu nhập mới nhất để xem trước
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT TOP 5 MaPN, SoPhieu, NgayLap, TrangThai, TongTien, GhiChu FROM PhieuNhap ORDER BY MaPN DESC");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_SP")
                {
                    // Chạy SP tạo phiếu nhập kho bằng cách chèn trực tiếp raw SQL
                    // Ở đây để đơn giản và minh hoạ rõ ràng: Ta khai báo TVP ngay trong đoạn code và gọi SP
                    string sql = @"
                        DECLARE @Details ChiTietPhieuType;
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (1, 10, 180000); -- Logitech G213
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (2, 5, 850000);  -- Logitech M331
                        EXEC sp_TaoPhieuNhap @MaNCC = 1, @MaKho = 1, @MaNV = 1, @GhiChu = N'Phiếu nhập Demo chạy qua Web UI', @ChiTiet = @Details;
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
                    // Xem tồn kho của sản phẩm có MaSP = 1 (Chuột Logitech) ở Kho = 3 trước
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT tk.MaKho, k.TenKho, tk.MaSP, sp.TenSP, tk.SoLuong FROM TonKho tk JOIN Kho k ON tk.MaKho = k.MaKho JOIN SanPham sp ON tk.MaSP = sp.MaSP WHERE tk.MaSP = 1 AND tk.MaKho = 3");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_TRIGGER_PASS")
                {
                    // Tạo một phiếu xuất nháp ở Kho 3 có số lượng xuất = 2 (tồn kho Kho 3 hiện tại là 5 -> Đủ hàng)
                    // Sau đó tiến hành Duyệt phiếu xuất để kích hoạt trigger trừ tồn kho!
                    string sql = @"
                        DECLARE @Details ChiTietPhieuType;
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (1, 2, 250000);
                        
                        DECLARE @OutID TABLE (ID INT);
                        INSERT INTO PhieuXuat (MaKho, MaNV, NguoiNhan, TrangThai, GhiChu)
                        OUTPUT inserted.MaPX INTO @OutID
                        VALUES (3, 1, N'Khách mua Demo', N'Nháp', N'Demo xuất kho đủ hàng');

                        DECLARE @MaPX INT = (SELECT TOP 1 ID FROM @OutID);
                        INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia)
                        SELECT @MaPX, MaSP, SoLuong, DonGia FROM @Details;

                        -- Kích hoạt trigger trừ tồn kho bằng cách duyệt phiếu
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
                    // Lập phiếu xuất và duyệt với số lượng = 100 (tồn kho hiện tại ở Kho 3 tối đa là 5 -> Thiếu hàng!)
                    // Việc duyệt phiếu sẽ kích hoạt trigger, trigger kiểm tra không đủ hàng sẽ quăng lỗi RAISERROR và ROLLBACK TRANSACTION!
                    string sql = @"
                        DECLARE @Details ChiTietPhieuType;
                        INSERT INTO @Details (MaSP, SoLuong, DonGia) VALUES (1, 100, 250000);
                        
                        DECLARE @OutID TABLE (ID INT);
                        INSERT INTO PhieuXuat (MaKho, MaNV, NguoiNhan, TrangThai, GhiChu)
                        OUTPUT inserted.MaPX INTO @OutID
                        VALUES (3, 1, N'Khách mua Demo', N'Nháp', N'Demo xuất kho thiếu hàng');

                        DECLARE @MaPX INT = (SELECT TOP 1 ID FROM @OutID);
                        INSERT INTO CT_PhieuXuat (MaPX, MaSP, SoLuong, DonGia)
                        SELECT @MaPX, MaSP, SoLuong, DonGia FROM @Details;

                        -- Bước này kích hoạt trigger kiểm tra tồn và sẽ quăng lỗi
                        EXEC sp_DuyetPhieu @LoaiPhieu = 'PX', @MaPhieu = @MaPX, @MaNV = 1;
                    ";
                    await _sqlService.ExecuteNonQueryAsync(sql);
                    return Json(new { success = true, message = "Thành công?" }); // Dòng này thực tế không chạy tới vì CSDL quăng lỗi
                }
                else if (request.ActionType == "GET_BEFORE_FUNCTION")
                {
                    // Xem thông tin giá trị tồn mặc định trong bảng SanPham (để đối chiếu)
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT MaSP, TenSP, GiaNhap, GiaBan FROM SanPham WHERE MaSP IN (1, 2)");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_FUNCTION")
                {
                    // Chạy câu lệnh SELECT sử dụng các hàm scalar function fn_TinhGiaTriTonKho và fn_TinhGiaXuatBinhQuan
                    string sql = "SELECT dbo.fn_TinhGiaTriTonKho(1) AS [Tổng giá trị tồn Kho 1 (VND)], dbo.fn_TinhGiaXuatBinhQuan(1) AS [Giá xuất bình quân SP 1 (VND)]";
                    var dt = await _sqlService.ExecuteQueryAsync(sql);
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "GET_BEFORE_CURSOR")
                {
                    // Xem bảng TonKho của tất cả sản phẩm đang dưới hạn mức tối thiểu
                    var dt = await _sqlService.ExecuteQueryAsync("SELECT tk.MaSP, sp.TenSP, tk.SoLuong, sp.TonToiThieu FROM TonKho tk JOIN SanPham sp ON tk.MaSP = sp.MaSP WHERE tk.SoLuong < sp.TonToiThieu");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }
                else if (request.ActionType == "RUN_CURSOR")
                {
                    // Chạy SP sp_CursorCanhBaoTon chứa cursor
                    var dt = await _sqlService.ExecuteQueryAsync("EXEC sp_CursorCanhBaoTon");
                    return Json(new { success = true, data = ConvertDataTableToList(dt) });
                }

                return Json(new { success = false, message = "Hành động không hợp lệ." });
            }
            catch (Exception ex)
            {
                // Trả về lỗi chi tiết từ SQL Server (bao gồm cả lỗi RAISERROR từ trigger!)
                return Json(new { success = false, message = "LỖI SQL SERVER: " + ex.Message });
            }
        }

        // Helper chuyển đổi DataTable sang List Dictionary để dễ dàng JSON hóa
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
