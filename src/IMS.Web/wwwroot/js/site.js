$(document).ready(function () {
    // Toggle sidebar on mobile screen size
    $('#sidebarToggle').click(function (e) {
        e.stopPropagation();
        $('.app-sidebar').toggleClass('show');
    });

    // Close sidebar when clicking outside on mobile
    $(document).click(function (e) {
        if (!$(e.target).closest('.app-sidebar').length && $('.app-sidebar').hasClass('show')) {
            $('.app-sidebar').removeClass('show');
        }
    });

    // Initialize DataTables with Vietnamese language localization
    if ($.fn.DataTable) {
        $('.datatable-custom').DataTable({
            language: {
                processing: "Đang xử lý...",
                search: "Tìm kiếm:",
                lengthMenu: "Hiển thị _MENU_ mục",
                info: "Hiển thị từ _START_ đến _END_ trong tổng số _TOTAL_ mục",
                infoEmpty: "Hiển thị 0 mục trong tổng số 0 mục",
                infoFiltered: "(được lọc từ _MAX_ mục hệ thống)",
                loadingRecords: "Đang tải dữ liệu...",
                zeroRecords: "Không tìm thấy kết quả phù hợp",
                emptyTable: "Không có dữ liệu trong bảng",
                paginate: {
                    first: "Đầu tiên",
                    previous: "Trước",
                    next: "Tiếp theo",
                    last: "Cuối cùng"
                }
            },
            pageLength: 10,
            responsive: true,
            order: [] // Disable default sort on first column
        });
    }
});
