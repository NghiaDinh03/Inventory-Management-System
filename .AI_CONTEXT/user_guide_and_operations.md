# HƯỚNG DẪN SỬ DỤNG & LOGIC VẬN HÀNH HỆ THỐNG IMS
### Dự án: Hệ Thống Quản Lý Hàng Tồn Kho (IMS Antigravity)
### Địa chỉ ứng dụng: Web App (http://localhost:8080) | DbGate (http://localhost:3000)

Tài liệu này cung cấp hướng dẫn chi tiết về cách vận hành hệ thống, giải nghĩa các thông số trên Dashboard, vai trò chuyên môn của các báo cáo dành cho kế toán và quản lý, các kịch bản nghiệp vụ (Use Cases) thực tế trong kho, và hướng dẫn chi tiết sử dụng công cụ DbGate.

---

## 1. Giải Nghĩa Các Thông Số Trên Dashboard (100% Dynamic)

Tất cả các số liệu hiển thị trên Dashboard được truy vấn **100% thời gian thực (real-time)** từ cơ sở dữ liệu SQL Server thông qua các Database Views, hoàn toàn không có giá trị nào được gán tĩnh (hardcoded). 

| Thông số | Nguồn truy vấn (SQL View) | Ý nghĩa nghiệp vụ & Tác dụng |
| :--- | :--- | :--- |
| **Tổng sản phẩm** | `v_ThongKeTongQuat` | Đếm số lượng sản phẩm đang hoạt động (`TrangThai = 1`). Giúp nhà quản lý nắm bắt quy mô danh mục hàng hóa đang kinh doanh. |
| **Nhà cung cấp** | `v_ThongKeTongQuat` | Đếm số đối tác cung ứng đang hoạt động (`TrangThai = 1`). Theo dõi số lượng mối quan hệ chuỗi cung ứng. |
| **Kho chứa hàng** | `v_ThongKeTongQuat` | Đếm số kho bãi vật lý hoạt động. Thể hiện mạng lưới phân phối và lưu trữ của doanh nghiệp. |
| **Giá trị tồn kho** | `v_ThongKeTongQuat` | Tính tổng `SoLuong * GiaNhap` của tất cả mặt hàng trong các kho. Đây là thông số tài chính cực kỳ quan trọng cho **Kế toán** để ghi nhận giá trị tài sản lưu động và vốn đang bị đọng trong kho. |
| **Công việc chờ duyệt** | `v_ThongKeTongQuat` | Đếm số phiếu nhập/xuất kho đang ở trạng thái `Nháp`. Đây là danh sách công việc cần xử lý ngay của **Quản lý kho/Thủ kho trưởng** để duyệt nhập/xuất hàng thực tế. |
| **Cảnh báo tồn kho thấp**| `v_SanPhamDuoiTonToiThieu` | Danh sách sản phẩm có số lượng tồn hiện tại thấp hơn định mức an toàn (`TonToiThieu`). Giúp bộ phận **Mua hàng (Purchasing)** tự động nhận diện mặt hàng sắp hết để lên đơn đặt hàng kịp thời. |
| **Xu hướng Nhập/Xuất** | `v_NhapXuatTheoNgay` | Biểu đồ cột thể hiện lượng hàng hóa nhập và xuất theo từng ngày. Chỉ thống kê các phiếu **Đã Duyệt** (giao dịch thực tế đã hoàn thành). Giúp quản lý đánh giá tần suất vận hành và những ngày cao điểm. |

---

## 2. Vai Trò Của Các Báo Cáo Đối Với Kế Toán & Quản Lý Vận Hành

Hệ thống cung cấp 5 công cụ báo cáo đặc thù. Dưới đây là phân tích vai trò thực tế của chúng trong doanh nghiệp:

### 2.1. Báo cáo Tồn Kho (sp_BaoCaoTonKho)
*   **Dành cho Kế toán**: Đối chiếu số dư tài sản tồn kho cuối kỳ trên sổ sách kế toán với số lượng thực tế trong kho. Tính toán dự phòng giảm giá hàng tồn kho dựa trên giá nhập đầu vào.
*   **Dành cho Quản lý vận hành**: Biết chính xác sản phẩm nào đang nằm ở kho nào, số lượng bao nhiêu để điều chuyển nội bộ giữa các kho, tránh tình trạng kho này thừa hàng nhưng kho kia cháy hàng.

### 2.2. Báo cáo Nhập Kho theo Nhà Cung Cấp (sp_BaoCaoNhapTheoNCC)
*   **Dành cho Kế toán**: Theo dõi công nợ phải trả cho từng nhà cung cấp. Kiểm tra tính chính xác của các hóa đơn mua hàng đầu vào trong kỳ.
*   **Dành cho Quản lý vận hành**: Đánh giá năng lực cung ứng của từng đối tác (tần suất giao hàng, sản lượng mua từ nhà cung cấp nào nhiều nhất để thương lượng chiết khấu thương mại).

### 2.3. Báo cáo Xuất Kho theo Sản Phẩm (sp_BaoCaoXuatTheoSP)
*   **Dành cho Kế toán**: Tính toán Giá vốn hàng bán (COGS) trong kỳ phục vụ lập Báo cáo kết quả hoạt động kinh doanh.
*   **Dành cho Quản lý vận hành**: Phân tích tốc độ tiêu thụ của từng sản phẩm. Xác định mặt hàng nào bán chạy để ưu tiên vị trí xếp dỡ trong kho và tăng định mức tồn trữ an toàn.

### 2.4. Báo cáo Top Sản Phẩm Xuất Nhiều (v_TopSanPhamXuatNhieu)
*   **Dành cho Quản lý vận hành**: Nhận diện 10 sản phẩm cốt lõi mang lại dòng tiền nhanh nhất cho doanh nghiệp để tập trung nguồn lực lưu kho và bảo quản đặc biệt.

### 2.5. Báo cáo Doanh Thu theo Tháng (v_DoanhThuTheoThang)
*   **Dành cho Quản lý & Kế toán**: Theo dõi sự tăng trưởng doanh số xuất kho theo từng tháng trong năm, từ đó dự báo nhu cầu thị trường và lập kế hoạch ngân sách nhập hàng cho năm tiếp theo.

---

## 3. Các Use Cases Nghiệp Vụ Thực Tế & Xử Lý Phát Sinh (Exceptions)

Trong quá trình vận hành kho thực tế của doanh nghiệp startup, hệ thống tự động xử lý các tình huống phát sinh thông qua logic nghiệp vụ cứng (Triggers & Constraints):

### Use Case 1: Xuất quá số lượng tồn (Ngăn chặn xuất âm)
*   **Tình huống**: Nhân viên cố tình hoặc nhập nhầm số lượng xuất kho lớn hơn số lượng hàng hiện có trong kho.
*   **Xử lý hệ thống**: Trigger `trg_PhieuXuat_Duyet` sẽ tự động chặn đứng hành động này khi Quản lý nhấn "Duyệt". Hệ thống sẽ hủy giao dịch (`ROLLBACK`), đưa ra thông báo lỗi tiếng Việt cụ thể: *"Không đủ số lượng tồn kho cho sản phẩm X trong kho Y"*. Hàng tồn kho của doanh nghiệp không bao giờ bị âm trên hệ thống.

### Use Case 2: Tự động hóa cập nhật tồn kho khi Duyệt phiếu
*   **Tình huống**: Hàng hóa bốc dỡ thực tế xong, thủ kho nhấn "Duyệt" phiếu nhập hoặc xuất trên web.
*   **Xử lý hệ thống**: 
    *   Đối với phiếu nhập kho: Trigger `trg_PhieuNhap_Duyet` tự động cộng dồn số lượng vào bảng `TonKho` tương ứng với mã kho nhận hàng.
    *   Đối với phiếu xuất kho: Trigger `trg_PhieuXuat_Duyet` tự động trừ số lượng tồn trong bảng `TonKho`.
    *   *Lợi ích*: Loại bỏ sai sót do thủ kho phải vào sửa tay từng bảng tồn kho sau khi tạo phiếu, đảm bảo dữ liệu luôn nhất quán 100%.

### Use Case 3: Chặn xóa sản phẩm/danh mục đã phát sinh giao dịch
*   **Tình huống**: Quản lý muốn xóa một danh mục sản phẩm cũ để dọn dẹp hệ thống, nhưng danh mục đó đã có các sản phẩm phát sinh phiếu nhập/xuất trong năm.
*   **Xử lý hệ thống**: Hệ thống sử dụng ràng buộc khóa ngoại (`FOREIGN KEY`) và Trigger chặn xóa. Khi cố tình xóa, SQL Server sẽ từ chối và trả về lỗi toàn vẹn tham chiếu. Dữ liệu lịch sử mua bán/kế toán được bảo toàn tuyệt đối phục vụ thanh tra thuế.

### Use Case 4: Tạo mã số phiếu tự động theo chuẩn doanh nghiệp
*   **Tình huống**: Khi tạo mới phiếu nhập/xuất kho, người dùng không cần tự gõ số phiếu (tránh trùng lặp hoặc gõ sai định dạng).
*   **Xử lý hệ thống**: Trigger `trg_PhieuNhap_AutoNumber` và `trg_PhieuXuat_AutoNumber` tự động sinh mã số phiếu theo định dạng chuỗi: `PN-YYYY-XXXXX` và `PX-YYYY-XXXXX` (trong đó YYYY là năm hiện tại, XXXXX là số thứ tự tăng dần tự động).

---

## 4. Hướng Dẫn Sử Dụng Trực Quan Công Cụ DbGate (http://localhost:3000)

DbGate là một ứng dụng quản trị cơ sở dữ liệu trực quan chạy trên nền Web. Hệ thống đã được cấu hình nạp sẵn kết nối.

### 4.1. Đăng nhập và xem CSDL
1.  Truy cập vào địa chỉ **[http://localhost:3000](http://localhost:3000)**.
2.  Ở thanh sidebar bên trái, dưới mục **CONNECTIONS**, bạn sẽ nhìn thấy kết nối **"CSDL Quản Lý Hàng Tồn Kho (sa)"** đã được cấu hình sẵn.
3.  Nhấp đúp chuột vào kết nối này để mở rộng cấu trúc. Chọn database **InventoryDB**.

### 4.2. Xem mô hình quan hệ (ERD Diagram)
1.  Nhấp chuột phải vào tên Database **InventoryDB** -> Chọn **Schema Diagram**.
2.  DbGate sẽ tự động vẽ toàn bộ sơ đồ mối quan hệ giữa 12 bảng (Primary Key, Foreign Key) một cách trực quan giống hệt SQL Server Management Studio (SSMS). Bạn có thể kéo thả các bảng để xem luồng liên kết.

### 4.3. Thêm, Xóa, Sửa dữ liệu trực tiếp như Excel (Data Editor)
1.  Trong danh sách bảng (Tables), nhấp đúp vào một bảng (ví dụ: `SanPham`).
2.  Nhấp vào tab **Data** ở trên cùng.
3.  **Sửa dữ liệu**: Nhấp đúp vào bất kỳ ô nào (ví dụ: đổi `TenSP`), sửa nội dung và nhấn phím `Enter`. Nhấn nút **Save** (icon hình đĩa mềm) ở góc trên để lưu vào cơ sở dữ liệu thực tế.
4.  **Thêm dòng mới**: Nhấp vào dòng trống có dấu cộng ở cuối bảng, điền dữ liệu và nhấn **Save**.
5.  **Xóa dòng**: Chọn dòng muốn xóa, nhấp chuột phải -> Chọn **Delete row** -> Nhấn **Save**.

### 4.4. Truy vấn SQL trực tiếp (SQL Console)
1.  Nhấn vào nút **New Query** (hoặc tổ hợp phím `Ctrl + Q`) ở thanh công cụ phía trên.
2.  Viết câu lệnh SQL của bạn, ví dụ:
    ```sql
    SELECT * FROM v_TonKhoHienTai WHERE SoLuong < TonToiThieu;
    ```
3.  Nhấn nút **Execute** (hoặc phím `F5`) để chạy và xem bảng kết quả bên dưới.
