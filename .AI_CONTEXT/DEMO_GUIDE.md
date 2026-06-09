# HƯỚNG DẪN KỊCH BẢN DEMO HỆ THỐNG IMS LOGISTICS (UI/UX)
### Đồ án môn học: Hệ thống quản lý hàng tồn kho (Logistics WMS)
### Địa chỉ truy cập: Web App (http://localhost:8080) | DbGate (http://localhost:3000)

Tài liệu này cung cấp kịch bản từng bước (step-by-step) giúp bạn demo trơn tru trước giáo viên hướng dẫn và hội đồng chấm thi, nêu bật các tính năng nâng cao của SQL Server thông qua giao diện Web UI đẹp mắt và trực quan.

---

## I. CHUẨN BỊ TRƯỚC KHI DEMO

1. **Khởi động hệ thống sạch bằng Docker**:
   Mở terminal tại thư mục gốc dự án và chạy lệnh dưới đây để dọn dẹp các container/volume cũ và chạy mới từ đầu (Database sẽ được seed dữ liệu tiếng Việt đầy đủ):
   ```bash
   docker-compose down -v
   docker-compose up --build -d
   ```
2. **Chuẩn bị các tài khoản đăng nhập**:
   - **Tài khoản Thủ kho (Nhân viên kho)**: Đăng nhập bằng `nvkho` / mật khẩu: `nvkho123` (Vai trò tạo phiếu, chỉ được chạy SP nghiệp vụ, không có quyền xóa database).
   - **Tài khoản Quản trị (Admin)**: Đăng nhập bằng `admin` / mật khẩu: `admin123` (Có toàn quyền hệ thống, duyệt phiếu, sao lưu, phục hồi).

---

## II. KỊCH BẢN 1: QUY TRÌNH LIÊN THÔNG NGHIỆP VỤ NHẬP/XUẤT KHO

Kịch bản này chứng minh luồng nghiệp vụ thực tế trong kho và cách các **Triggers** của SQL Server tự động kiểm soát logic nghiệp vụ.

### Bước 1: Tạo Phiếu Nhập Kho (Trạng thái Nháp)
1. Đăng nhập tài khoản thủ kho `nvkho`.
2. Vào menu **Goods Receipt (Phiếu nhập)** -> Nhấn **Create New Receipt**.
3. Chọn các thông số:
   - Nhà cung cấp: **Logitech Việt Nam**
   - Kho nhận: **Kho 1**
   - Thêm dòng sản phẩm: **Chuột Không Dây Logitech M331** -> Nhập số lượng **10**, đơn giá **180,000 đ**.
4. Nhấn **Save**. Phiếu nhập được lưu ở trạng thái **Draft (Nháp)**.
5. **Thuyết minh với giáo viên**: 
   - *"Lúc này, trigger cập nhật tồn kho chưa kích hoạt vì phiếu mới chỉ ở trạng thái Nháp (chưa duyệt thực tế)."*
   - Bạn mở menu **Inventory (Tồn kho)** -> Chọn Kho 1 để chỉ ra cho giáo viên thấy số lượng tồn của Logitech M331 **chưa hề tăng lên**.

### Bước 2: Phê Duyệt Phiếu Nhập & Tự Động Cập Nhật Tồn Kho (Trigger 1)
1. Đăng nhập tài khoản Quản lý/Admin `admin` (hoặc tiếp tục nếu tài khoản có quyền duyệt).
2. Vào lại danh sách phiếu nhập, nhấp vào nút **Details (Chi tiết)** của phiếu vừa tạo.
3. Nhấn nút **Approve (Duyệt)**. Trạng thái phiếu chuyển sang **Approved (Đã Duyệt)**.
4. **Thuyết minh với giáo viên**:
   - *"Khi quản lý nhấn Duyệt, stored procedure `sp_DuyetPhieu` cập nhật trạng thái phiếu nhập sang 'Đã Duyệt', từ đó kích hoạt trigger `trg_PhieuNhap_CapNhatTonKho` trên SQL Server."*
5. Quay lại trang **Inventory (Tồn kho)** hoặc **Products (Sản phẩm)**:
   - Số lượng tồn của chuột Logitech M331 tại Kho 1 đã tăng thêm **10** cái.
   - Cột trọng lượng tồn kho tự động cộng thêm tương ứng (`10 * TrongLuongSP`) nhờ trigger tính toán.
   - Bảng **Price History (Lịch sử giá)** tự động chèn một dòng mới ghi nhận giá nhập tại thời điểm duyệt là 180,000 đ (phục vụ tính giá bình quân gia quyền).

### Bước 3: Tạo Phiếu Xuất Kho & Chống Xuất Âm (Trigger 2 - Chặn Giao Dịch)
Đây là tính năng quan quan trọng chứng minh CSDL tự động bảo vệ tính toàn vẹn, chống thất thoát hàng hóa.
1. Vào menu **Goods Issue (Phiếu xuất)** -> Nhấn **Create New Issue**.
2. Chọn Kho xuất hàng: **Kho 1**.
3. **Thử nghiệm xuất thành công (Đủ hàng)**:
   - Thêm sản phẩm **Logitech M331** -> Nhập số lượng **2** cái.
   - Nhấn **Save** (Trạng thái Nháp).
   - Nhấn **Approve (Duyệt)** -> Phiếu được duyệt thành công, tồn kho giảm từ 10 xuống còn 8 cái.
4. **Thử nghiệm xuất thất bại (Chặn xuất âm - RAISERROR)**:
   - Tạo một phiếu xuất khác từ **Kho 1**.
   - Thêm sản phẩm **Logitech M331** -> Nhập số lượng **100** cái (vượt quá lượng tồn hiện tại là 8 cái).
   - Nhấn **Save** (Trạng thái Nháp).
   - Nhấn **Approve (Duyệt)**.
   - **Kết quả**: Hệ thống lập tức hiện thông báo lỗi màu đỏ (SweetAlert2): *"Không đủ hàng tồn kho để xuất"* (hoặc lỗi quăng về từ trigger `trg_PhieuXuat_CapNhatTonKho`). Giao dịch tự động bị **ROLLBACK** (hủy bỏ hoàn toàn), giữ cho số lượng tồn kho không bao giờ bị âm.

---

## III. KỊCH BẢN 2: DEMO CÁC TÍNH NĂNG SQL SERVER NÂNG CAO (TRANG /DEMO)

Trang **Demo SQL Server (B1-B5)** được thiết kế chuyên biệt để bạn biểu diễn 4 nhóm cấu trúc CSDL nâng cao theo quy chuẩn 5 bước (B1: Đề bài -> B2: SQL -> B3: Dữ liệu trước -> B4: Nút chạy -> B5: Dữ liệu sau).

### 1. Demo Stored Procedure (`sp_TaoPhieuNhap`)
1. Click tab **Stored Procedure** trên Web.
2. Chỉ vào khối mã SQL (B2) hiển thị câu lệnh gọi SP kèm tham số Table-Valued Parameter.
3. Cho giáo viên xem bảng dữ liệu hiện tại trước khi chạy (B3).
4. Nhấn **Execute sp_TaoPhieuNhap** (B4).
5. Kết quả (B5) tự động hiển thị: Phiếu nhập mới được tạo, trigger tự động sinh số phiếu (PN-YYYY-0000X) và tự tính tổng tiền dòng chi tiết.

### 2. Demo Trigger (`trg_PhieuXuat_CapNhatTonKho`)
1. Click tab **Trigger**.
2. Thuyết minh: *"Trigger này kiểm tra và trừ tồn kho khi phê duyệt phiếu xuất kho"*.
3. Bấm nút **Approve - SUFFICIENT Stock** (Đủ hàng): Hệ thống chạy thành công, bảng dữ liệu sau (B5) hiển thị số lượng tồn giảm đi 2 cái.
4. Bấm nút **Approve - INSUFFICIENT Stock** (Thiếu hàng): Hệ thống bị SQL Server chặn đứng giao dịch và trả về lỗi nguyên bản của trigger được quăng lên giao diện web.

### 3. Demo Function (`fn_TinhGiaTriTonKho` & `fn_TinhGiaXuatBinhQuan`)
1. Click tab **Function**.
2. Thuyết minh: *"Chúng em sử dụng hàm Scalar để tính giá trị tiền hàng tồn kho thời gian thực và giá vốn xuất bình quân gia quyền để tính giá bán"*.
3. Nhấn **Execute SQL Functions**.
4. Kết quả trả về lập tức hiển thị: Tổng giá trị hàng hóa hiện tại trong Kho 1 và Giá vốn xuất bình quân của sản phẩm dựa trên lịch sử các lần nhập hàng trước đó.

### 4. Demo Cursor (`sp_CursorCanhBaoTon` duyệt con trỏ)
1. Click tab **Cursor**.
2. Thuyết minh: *"Chúng em cài đặt con trỏ duyệt tuần tự danh sách tồn kho của các sản phẩm đang dưới ngưỡng tối thiểu để in ra các cảnh báo nghiệp vụ cho bộ phận mua hàng"*.
3. Nhấn **Execute Cursor Procedure**.
4. Kết quả: Cursor duyệt từng dòng và in ra danh sách các dòng thông báo cảnh báo chi tiết (ví dụ: *"Cảnh báo: Sản phẩm [Chuột Logitech M331] tại kho [Kho 1] đang tồn 8 cái, dưới mức tối thiểu là 10!"*).

---

## IV. KỊCH BẢN 3: QUẢN TRỊ HỆ THỐNG (TRANSMISSION & SECURITY)

Chứng minh khả năng bảo mật, xác thực tài khoản và sao lưu dữ liệu chống thiên tai/sự cố.

### 1. Demo Backup & Restore (Sao lưu và Phục hồi)
1. Đăng nhập tài khoản `admin`. Vào menu **System Admin** -> Chọn **Backup & Restore**.
2. **Sao lưu (Backup)**:
   - Nhấn nút **Backup Now**.
   - Hệ thống thực thi SP `sp_BackupDatabase` và hiển thị thông báo thành công kèm tên file sao lưu (ví dụ: `InventoryDB_Backup_20260610_021000.bak`).
3. **Phục hồi (Restore)**:
   - Copy tên file `.bak` vừa được tạo ra ở bước trên.
   - Dán vào ô input phục hồi ở cột bên phải.
   - Nhấn **Restore Now** -> Click **Đồng ý khôi phục**.
   - Hệ thống thực thi SP `sp_RestoreDatabase` trên database `master`, ngắt mọi kết nối hiện tại và khôi phục database về mốc thời gian đó thành công.

### 2. Demo Phân Quyền Hạn Chế Thao Tác (Security)
1. Đăng nhập tài khoản thủ kho `nvkho`.
2. Mở trình duyệt truy cập công cụ quản lý cơ sở dữ liệu **DbGate** tại **`http://localhost:3000`**.
3. Thử mở bảng `TonKho` hoặc `PhieuNhap` và dùng chuột để xóa/sửa dữ liệu trực tiếp trên bảng.
4. Nhấn **Save** -> Kết quả: DbGate báo lỗi **Permission Denied**.
5. **Thuyết minh**: *"Để bảo mật, nhân viên kho chỉ có quyền đọc dữ liệu (`SELECT`) và gọi Stored Procedure, họ bị cấm sửa/xóa bảng trực tiếp (`DENY INSERT, UPDATE, DELETE`) để tránh gian lận số liệu hàng tồn"*.

---

## V. CÁC ĐIỂM CỘNG LỚN KHI TRÌNH BÀY ĐỒ ÁN (ĐỘC QUYỀN)

Khi giáo viên hỏi về tính ứng dụng thực tế của đồ án, hãy nêu bật **2 điểm sáng giá** sau:
1. **Thiết kế chống nghẽn và Deadlock (Production Database)**:
   - *"Hệ thống Demo đang dùng Trigger cập nhật bảng tĩnh `TonKho`. Tuy nhiên, nếu đưa vào vận hành thực tế (Production) với hàng trăm thiết bị quét mã vạch cùng lúc, việc tranh chấp khóa dòng trên bảng `TonKho` sẽ gây nghẽn mạng (Deadlock)"*.
   - *"Do đó, trong tài liệu thiết kế, chúng em đã đề xuất mô hình **Stock Ledger (Sổ cái giao dịch)**. Mọi thao tác nhập xuất chỉ là thao tác `INSERT` nối đuôi vào bảng `GiaoDichKho` thay vì `UPDATE` ghi đè, giúp hệ thống chịu tải cực cao và không bao giờ bị Deadlock"*.
2. **Quản lý bãi kho chi tiết (Bin Location)**:
   - *"Mô hình sản xuất của chúng em hỗ trợ định vị chính xác vị trí hàng hóa tới tận từng ô kệ (Dãy - Rack - Tầng - Ô) và quản lý date lô hàng cận hạn sử dụng (FEFO) chuẩn mô hình WMS của Smartlog, thay vì chỉ quản lý chung chung theo kho vật lý"*.
