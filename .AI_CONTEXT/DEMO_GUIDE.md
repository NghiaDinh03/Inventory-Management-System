# HƯỚNG DẪN KỊCH BẢN DEMO HỆ THỐNG IMS LOGISTICS

### Đồ án môn học: Hệ thống quản lý hàng tồn kho (Logistics WMS)
### Địa chỉ truy cập: Web App (http://localhost:8080) | DbGate (http://localhost:3000)

Tài liệu này cung cấp kịch bản từng bước (step-by-step) giúp bạn thực hiện quay video hoặc trực tiếp demo trơn tru trước giảng viên hướng dẫn và hội đồng chấm thi. Kịch bản nêu bật các tính năng nâng cao của SQL Server thông qua giao diện Web UI đẹp mắt, hiện đại và đã được dịch sang tiếng Việt 100%.

---

## I. CHUẨN BỊ TRƯỚC KHI DEMO

1. **Khởi động hệ thống sạch bằng Docker**:
   Mở terminal tại thư mục gốc dự án và chạy lệnh dưới đây để dọn dẹp các container/volume cũ và chạy mới từ đầu. Hệ thống sẽ tự động khởi tạo cơ sở dữ liệu **Production Go-Live 27 bảng** và nạp dữ liệu mẫu Tiếng Việt đầy đủ:
   ```bash
   docker-compose down -v
   docker-compose up --build -d
   ```
2. **Các tài khoản đăng nhập thử nghiệm**:
   - **Tài khoản Quản trị (Admin)**: Đăng nhập bằng `admin` / mật khẩu: `Admin_password_2026` (Quyền tối cao: duyệt phiếu, xem báo cáo, sao lưu, phục hồi).
   - **Tài khoản Thủ kho**: Đăng nhập bằng `nvkho1` / mật khẩu: `Nvkho_password_2026` (Quyền lập phiếu, xem báo cáo, không có quyền duyệt phiếu hoặc sao lưu).

---

## II. KỊCH BẢN 1: QUY TRÌNH LIÊN THÔNG NGHIỆP VỤ NHẬP/XUẤT KHO

Kịch bản này chứng minh luồng nghiệp vụ thực tế trong kho và cách các **Triggers** của SQL Server tự động kiểm soát logic nghiệp vụ tĩnh (UPSERT tồn kho, chặn xuất âm).

### Bước 1: Tạo Phiếu Nhập Kho (Trạng thái Nháp)
1. Đăng nhập tài khoản thủ kho `nvkho1`.
2. Vào menu **Phiếu nhập kho** -> Nhấn nút **Thêm mới phiếu nhập**.
3. Chọn các thông số:
   - Nhà cung cấp: **Công ty TNHH Unilever Việt Nam**
   - Kho nhận: **Kho Tổng TP.HCM**
   - Thêm sản phẩm: **Dầu gội Clear Bạc Hà Thơm Mát 630ml** -> Nhập số lượng **10**, đơn giá **135,000 đ**.
4. Nhấn **Lưu phiếu**. Phiếu nhập được lưu ở trạng thái **Nháp**.
5. **Kịch bản nói (Voiceover)**: 
   - *"Lúc này, phiếu nhập kho mới được tạo ở trạng thái Nháp. Số lượng tồn kho vật lý chưa được cập nhật vì phiếu chưa được duyệt thực tế. Hãy cùng kiểm tra tồn kho."*
   - Bạn mở menu **Tồn kho** -> Xem tồn kho của sản phẩm tại **Kho Tổng TP.HCM** để chỉ ra số lượng tồn chưa hề tăng lên (giữ nguyên là 80 chai như mặc định).

### Bước 2: Phê Duyệt Phiếu Nhập & Tự Động Cập Nhật Tồn Kho (Trigger 1)
1. Đăng nhập tài khoản Admin `admin` để thực hiện duyệt.
2. Vào menu **Phiếu nhập kho**, nhấp vào nút **Chi tiết** (biểu tượng mắt/xem) của phiếu vừa tạo.
3. Nhấn nút **Duyệt phiếu**. Trạng thái phiếu chuyển sang **Đã duyệt**.
4. **Kịch bản nói (Voiceover)**:
   - *"Khi quản trị viên nhấn Duyệt phiếu, hệ thống gọi Stored Procedure `sp_DuyetPhieu` trên SQL Server để cập nhật trạng thái phiếu nhập sang 'Đã duyệt'. Hành động cập nhật này kích hoạt Trigger `trg_PhieuNhap_CapNhatTonKho` thực hiện cộng số lượng tồn, trọng lượng tồn vào bảng TonKho và tự động ghi lịch sử giá nhập vào bảng Gia."*
5. Quay lại trang **Tồn kho** hoặc **Sản phẩm**:
   - Số lượng tồn của Dầu gội Clear tại Kho Tổng TP.HCM đã tăng từ 80 lên **90** chai.
   - Trọng lượng tồn kho tự động cộng dồn thêm tương ứng (`10 * 0.7 kg = 7 kg`) nhờ trigger tính toán.
   - Bảng lịch sử giá đã tự động chèn một dòng mới ghi nhận giá nhập dầu gội là 135,000 đ.

### Bước 3: Tạo Phiếu Xuất Kho & Chống Xuất Âm (Trigger 2 - Chặn Giao Dịch)
Đây là tính năng quan trọng chứng minh CSDL tự động bảo vệ tính toàn vẹn, tránh thất thoát hàng hóa.
1. Vào menu **Phiếu xuất kho** -> Nhấn **Thêm mới phiếu xuất**.
2. Chọn Kho xuất hàng: **Kho Tổng TP.HCM**.
3. **Thử nghiệm xuất thành công (Đủ hàng)**:
   - Thêm sản phẩm **Dầu gội Clear Bạc Hà Thơm Mát 630ml** -> Nhập số lượng **2** chai.
   - Nhấn **Lưu phiếu** (Trạng thái Nháp).
   - Vào chi tiết phiếu xuất, nhấn **Duyệt phiếu** -> Phiếu được duyệt thành công, tồn kho giảm từ 90 xuống còn 88 chai.
4. **Thử nghiệm xuất thất bại (Chặn xuất âm - RAISERROR)**:
   - Tạo một phiếu xuất khác từ **Kho Tổng TP.HCM**.
   - Thêm sản phẩm **Dầu gội Clear Bạc Hà Thơm Mát 630ml** -> Nhập số lượng **100** chai (vượt quá lượng tồn hiện tại là 88 chai).
   - Nhấn **Lưu phiếu** (Trạng thái Nháp).
   - Vào chi tiết phiếu xuất, nhấn **Duyệt phiếu**.
   - **Kết quả**: Hệ thống lập tức hiện thông báo lỗi màu đỏ từ SweetAlert2: *"Không đủ hàng tồn kho để xuất"*. 
   - **Kịch bản nói (Voiceover)**: *"SQL Server đã lập tức chặn đứng hành động này thông qua trigger `trg_PhieuXuat_CapNhatTonKho` nhờ kiểm tra lượng tồn khả dụng, tự động ROLLBACK toàn bộ giao dịch để đảm bảo kho hàng không bao giờ bị xuất âm."*

---

## III. KỊCH BẢN 2: DEMO CÁC TÍNH NĂNG SQL SERVER NÂNG CAO (MENU DEMO SQL)

Trang **Demo SQL Server (B1-B5)** được thiết kế chuyên biệt để bạn biểu diễn 4 nhóm cấu trúc CSDL nâng cao theo quy chuẩn 5 bước của đồ án.

### 1. Demo Stored Procedure (`sp_TaoPhieuNhap`)
1. Click tab **Stored Procedure** trên Web.
2. Thuyết minh: *"Tại bước B1 và B2, hệ thống mô tả kịch bản tạo phiếu nhập và khai báo câu lệnh SQL gọi Stored Procedure `sp_TaoPhieuNhap` kèm tham số dạng bảng (Table-Valued Parameter) để truyền nhiều dòng chi tiết sản phẩm cùng lúc."*
3. Cho giáo viên xem bảng dữ liệu hiện tại trước khi chạy ở bước **B3**.
4. Nhấn **Chạy thủ tục sp_TaoPhieuNhap** ở bước **B4**.
5. Kết quả ở bước **B5** tự động hiển thị: Phiếu nhập mới được tạo thành công, trigger tự động sinh số phiếu (PN-2026-0000X) và tự tính tổng tiền các dòng chi tiết.

### 2. Demo Trigger (`trg_PhieuXuat_CapNhatTonKho`)
1. Click tab **Trigger**.
2. Bấm nút **Duyệt phiếu - ĐỦ TỒN KHO**: Hệ thống chạy thành công, bảng dữ liệu sau (B5) hiển thị số lượng tồn giảm đi 2 cái.
3. Bấm nút **Duyệt phiếu - THIẾU TỒN KHO**: Hệ thống bị SQL Server chặn đứng giao dịch và trả về lỗi nguyên bản của trigger được quăng lên giao diện web.

### 3. Demo Function (`fn_TinhGiaTriTonKho` & `fn_TinhGiaXuatBinhQuan`)
1. Click tab **Function**.
2. Thuyết minh: *"Chúng em sử dụng hàm Scalar để tính giá trị tiền hàng tồn kho thời gian thực và giá vốn xuất bình quan gia quyền của sản phẩm dựa trên lịch sử các lần nhập hàng trước đó"*.
3. Nhấn **Chạy các hàm Function SQL**.
4. Kết quả trả về lập tức hiển thị: Tổng giá trị hàng hóa hiện tại trong Kho 1 và Giá xuất bình quan của sản phẩm 1.

### 4. Demo Cursor (`sp_CursorCanhBaoTon` duyệt con trỏ)
1. Click tab **Cursor**.
2. Thuyết minh: *"Chúng em cài đặt con trỏ (Cursor) duyệt tuần tự danh sách tồn kho dưới ngưỡng tối thiểu để in ra các cảnh báo nghiệp vụ mua hàng"*.
3. Nhấn **Chạy thủ tục chứa Cursor**.
4. Kết quả: Cursor duyệt từng dòng và in ra danh sách các dòng thông báo cảnh báo chi tiết (ví dụ: *"Cảnh báo: Sản phẩm [Chuột không dây Logitech M331] tại kho [Kho Tổng TP.HCM] có số lượng tồn hiện tại là 8, dưới mức tối thiểu là 15!"*).

---

## IV. KỊCH BẢN 3: QUẢN TRỊ HỆ THỐNG (BACKUP & RESTORE & SECURITY)

Chứng minh khả năng bảo mật, xác thực tài khoản và sao lưu dữ liệu chống sự cố.

### 1. Demo Backup & Restore (Sao lưu và Phục hồi)
1. Đăng nhập tài khoản `admin`. Vào menu **Hệ thống** -> **Sao lưu & Phục hồi**.
2. **Sao lưu (Backup)**:
   - Nhấn nút **Sao lưu ngay**.
   - Hệ thống thực thi SP `sp_BackupDatabase` và hiển thị thông báo thành công kèm tên file sao lưu (ví dụ: `InventoryDB_Backup_20260610_021000.bak`).
3. **Phục hồi (Restore)**:
   - Copy tên file `.bak` vừa được tạo ra ở bước trên.
   - Dán vào ô input phục hồi ở cột bên phải.
   - Nhấn **Phục hồi ngay** -> Click **Đồng ý phục hồi**.
   - Hệ thống thực thi SP `sp_RestoreDatabase` trên database `master`, ngắt mọi kết nối hiện tại và khôi phục database về mốc thời gian đó thành công.

### 2. Demo Phân Quyền Hạn Chế Thao Tác (Security)
1. Mở công cụ quản lý cơ sở dữ liệu **DbGate** tại **`http://localhost:3000`**.
2. Tạo kết nối mới với database `InventoryDB` bằng user phân quyền **`db_ims_nvkho`** (nếu có) hoặc thử đăng nhập bằng user này.
3. Thử thực hiện lệnh `DELETE FROM SanPham` hoặc `UPDATE TonKho SET SoLuongTon = 1000`.
4. Kết quả: SQL Server trả về lỗi **Permission Denied**.
5. **Thuyết minh**: *"Để bảo mật dữ liệu, nhân viên kho chỉ có quyền SELECT đọc thông tin và EXECUTE Stored Procedure. Hệ thống DENY trực tiếp quyền thao tác thủ công (INSERT, UPDATE, DELETE) trên các bảng cốt lõi để tránh gian lận số liệu hàng tồn"*.

---

## V. CÁC ĐIỂM CỘNG LỚN KHI TRÌNH BÀY ĐỒ ÁN (WMS GO-LIVE)

Khi giảng viên đặt câu hỏi chuyên sâu về tính thực tế, hãy trình bày các điểm sáng giá sau:
1. **Thiết kế chống nghẽn và Deadlock (Sổ cái giao dịch kho)**:
   - *"Hệ thống Web đang chạy cơ chế Trigger cập nhật trực tiếp bảng số dư `TonKho`. Tuy nhiên, khi Go-Live thực tế với hàng trăm thủ kho quét PDA đồng thời, việc tranh chấp khóa dòng trên bảng số dư sẽ gây nghẽn mạng (Deadlock) nghiêm trọng"*.
   - *"Để giải quyết vấn đề này, cơ sở dữ liệu Go-Live của chúng em đã thiết kế bảng **`GiaoDichKho` (Inventory Transaction Ledger)**. Mọi thao tác biến động kho chỉ thực hiện `INSERT` nối đuôi (Append-only) thay vì `UPDATE` ghi đè dòng. Hệ thống chống deadlock tuyệt đối và lưu vết lịch sử 100%"*.
2. **Quản lý bãi kho chi tiết tới cấp ô kệ (Bin Location)**:
   - *"CSDL Go-live của chúng em thiết lập đầy đủ bảng **`BinLocation` (Layout kho chi tiết)** và **`TonKhoTheoBin`**. Giúp quản lý chính xác vị trí hàng hóa nằm ở dãy nào, kệ nào, tầng nào, ô nào trong kho, hỗ trợ định vị Putaway/Picking cực kỳ hiệu quả"*.
3. **Theo dõi hạn sử dụng theo số Lô (LoHang - FEFO)**:
   - *"Bảng **`LoHang`** hỗ trợ quản lý số lô sản xuất, ngày sản xuất và hạn sử dụng của từng đợt hàng, giúp hệ thống hỗ trợ chiến lược xuất kho **FEFO** (Hàng hết hạn trước xuất trước), ngăn chặn tối đa việc hàng bị hết hạn sử dụng trong kho"*.
   - Bạn có thể mở DbGate truy vấn bảng `LoHang` hoặc `TonKhoTheoBin` để chứng minh sự tồn tại của các dữ liệu mở rộng này.
