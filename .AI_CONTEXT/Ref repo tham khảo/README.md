# Repo Tham Khảo – Hệ Thống Quản Lý Hàng Tồn Kho

Các repo bên dưới được phân loại theo mục đích tham khảo. Mỗi nhóm tập trung vào một khía cạnh khác nhau của hệ thống.

---

## Nhóm A – Thiết kế CSDL & Domain Inventory

Tham khảo cấu trúc database, domain model, stored procedure và flow nghiệp vụ nhập/xuất kho.

| # | Thư mục | Repo gốc | Điểm tham khảo |
|---|---------|-----------|-----------------|
| 1 | `A_CSDL_Domain_Inventory/01_NathKoch-Inventory_Management_System` | [NathKoch/Inventory_Management_System](https://github.com/NathKoch/Inventory_Management_System) | Cấu trúc bảng SQL Server: `Inventory`, `Users`. Script `StartDatabase.sql` sẵn dùng. CRUD đơn giản với ADO.NET |
| 2 | `A_CSDL_Domain_Inventory/02_Ehsan-IMS-WinForms-SQLServer` | [Ehsan-999/IMS-Cs-WinForms-SQL-Server](https://github.com/Ehsan-999/Inventory-Management-System-Cs-WinForms-and-SQL-Server) | Bảng `Products`, `Categories`, `Transactions`, `Users`. Tính stock real-time bằng `SUM(CASE WHEN type='IN' ... ) - SUM(CASE WHEN type='OUT' ...)`. Kiểm tra tồn kho trước khi xuất |
| 3 | `A_CSDL_Domain_Inventory/03_safnimj-Inventory-Management-System` | [safnimj/Inventory-Management-System](https://github.com/safnimj/Inventory-Management-System) | Flow nhập kho → chi tiết phiếu → cập nhật tồn. Module: Customer, Category, Product, Order, User. Domain sát nhất với bài toán quản lý hàng tồn kho |

---

## Nhóm B – Web App / UI Layout

Tham khảo cấu trúc MVC, layout admin, responsive design cho web application.

| # | Thư mục | Repo gốc | Điểm tham khảo |
|---|---------|-----------|-----------------|
| 4 | `B_WebApp_UI_Layout/04_Rizvi-IMS-ASPNET-MVC` | [Rizvi-Faiz/IMS-ASP.NET-MVC](https://github.com/Rizvi-Faiz/Inventory-Management-Syetem-inASP.NET-MVC) | Cấu trúc Controller/View ASP.NET MVC đơn giản, dễ đọc |
| 5 | `B_WebApp_UI_Layout/05_AlrzAmini-SuperMarket-ASPNET-Core6` | [AlrzAmini/SuperMarketManagement](https://github.com/AlrzAmini/SuperMarketManagement-With-ASP.NET-Core-6) | Layout admin responsive đẹp, ASP.NET Core 6 chuẩn. Chỉ lấy UI layout, bỏ logic tiếng Ba Tư |

---

## Nhóm C – Web Demo Flow

Tham khảo kiến trúc REST API kết hợp SQL Server, endpoint pattern.

| # | Thư mục | Repo gốc | Điểm tham khảo |
|---|---------|-----------|-----------------|
| 6 | `C_Web_Demo_Flow/06_PawelCyrklaf-shop-warehouse-api` | [PawelCyrklaf/shop-warehouse-api](https://github.com/PawelCyrklaf/shop-warehouse-api) | Kiến trúc REST API + SQL Server nhẹ. Cấu trúc: Controllers, Data (Models, DbContext), Core (Dto, Interfaces, Services). Dễ mở rộng endpoint `/execute` gọi SP |

---

## Nhóm D – Docker Compose & DB UI

Tham khảo cách containerize và quản lý DB bằng giao diện web.

| # | Tool | URL | Mục đích |
|---|------|-----|----------|
| 7 | DbGate Docker Image | [dbgate/dbgate](https://hub.docker.com/r/dbgate/dbgate) | Web UI quản lý SQL Server trong browser, thêm vào `docker-compose.yml` để demo DB trực quan |
| 8 | Docker Compose .NET Core + SQL Server | [Dev.to Guide](https://dev.to/quocbahuynh/containerize-aspnet-core-api-entity-framework-with-sql-lets-encrypt-docker-and-nginx-part-1-m1g) | Hướng dẫn containerize ASP.NET Core + SQL Server đầy đủ |

> Nhóm D không clone repo mà lưu link tham khảo. DbGate sẽ được tích hợp trực tiếp trong `docker-compose.yml` của project.

---

## Cách sử dụng

1. Đọc README của từng repo trong thư mục tương ứng để hiểu feature
2. Xem cấu trúc database từ Nhóm A để thiết kế schema
3. Tham khảo UI layout từ Nhóm B cho giao diện admin
4. Áp dụng kiến trúc API từ Nhóm C cho backend
5. Dùng Docker guide từ Nhóm D để containerize toàn bộ
