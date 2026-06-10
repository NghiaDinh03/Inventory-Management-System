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

    // Column Resizer for Tables
    function initTableResizer() {
        $('table.table-custom').each(function () {
            var table = $(this);
            var headers = table.find('thead th');
            
            headers.each(function () {
                var header = $(this);
                // Ensure header is positioned relatively for resizer placement
                if (header.css('position') === 'static') {
                    header.css('position', 'relative');
                }
                
                // Prevent duplicate resizers
                if (header.find('.col-resizer').length === 0) {
                    var resizer = $('<div class="col-resizer"></div>');
                    header.append(resizer);
                    
                    var startX, startWidth;
                    
                    resizer.on('mousedown', function (e) {
                        startX = e.pageX;
                        startWidth = header.outerWidth();
                        
                        $(document).on('mousemove', doDrag);
                        $(document).on('mouseup', stopDrag);
                        
                        resizer.addClass('resizing');
                        $('body').css('cursor', 'col-resize');
                        e.preventDefault();
                    });
                    
                    function doDrag(e) {
                        var width = startWidth + (e.pageX - startX);
                        if (width > 60) { // Keep minimum width of 60px
                            header.css('width', width + 'px');
                            header.css('min-width', width + 'px');
                        }
                    }
                    
                    function stopDrag() {
                        $(document).off('mousemove', doDrag);
                        $(document).off('mouseup', stopDrag);
                        resizer.removeClass('resizing');
                        $('body').css('cursor', '');
                    }
                }
            });
        });
    }

    // Initialize DataTables
    if ($.fn.DataTable) {
        var dt = $('.datatable-custom').DataTable({
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

        // Re-initialize resizer on Datatable draw (paging, sorting, searching)
        dt.on('draw', function () {
            initTableResizer();
        });
    }

    // Run table column resizer on load
    initTableResizer();
});
