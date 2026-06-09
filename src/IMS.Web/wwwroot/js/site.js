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
                processing: "Processing...",
                search: "Search:",
                lengthMenu: "Show _MENU_ entries",
                info: "Showing _START_ to _END_ of _TOTAL_ entries",
                infoEmpty: "Showing 0 to 0 of 0 entries",
                infoFiltered: "(filtered from _MAX_ total entries)",
                loadingRecords: "Loading...",
                zeroRecords: "No matching records found",
                emptyTable: "No data available in table",
                paginate: {
                    first: "First",
                    previous: "Previous",
                    next: "Next",
                    last: "Last"
                }
            },
            pageLength: 10,
            responsive: true,
            order: [] // Disable default sort on first column
        });
    }
});
