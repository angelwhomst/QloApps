$(document).ready(function() {
    // only expand/collapse when the Filter button is clicked

    // show/hide date filter
    $('.date-filter-toggle').click(function(e) {
        e.preventDefault();
        $('.date-filter-row').toggle();
    });

    // apply date range presets
    $('.js-date-range').click(function(e) {
        e.preventDefault();
        $('.date-filter-row').show();

        var range = $(this).data('range');
        var fromDate = new Date();
        var toDate = new Date();

        // set date range based on selection
        switch(range) {
            case 'today':
                // Today is already set
                break;
            case 'week':
                fromDate.setDate(fromDate.getDate() - fromDate.getDay()); // First day of current week
                break;
            case 'month':
                fromDate.setDate(1); // First day of current month
                break;
            case 'year':
                fromDate.setMonth(0); // January
                fromDate.setDate(1); // First day of year
                break;
        }

        // format dates for input fields (YYYY-MM-DD)
        $('input[name="date_from"]').val(formatDate(fromDate));
        $('input[name="date_to"]').val(formatDate(toDate));
    });

    // hide date filter
    $('.toggle-date-filter').click(function() {
        $('.date-filter-row').hide();
    });

    // reset filter action
    $('#resetFilter').click(function(e) {
        e.preventDefault();
        $('#submitResetSOP').click();
    });

    // format date to YYYY-MM-DD
    function formatDate(date) {
        var year = date.getFullYear();
        var month = (date.getMonth() + 1).toString().padStart(2, '0');
        var day = date.getDate().toString().padStart(2, '0');
        return year + '-' + month + '-' + day;
    }

    // Show date filter row if dates are already set
    if ($('input[name="date_from"]').val() || $('input[name="date_to"]').val()) {
        $('.date-filter-row').show();
    }

    // export confirmation
    jQuery('.btn-export-sop').on('click', function(e) {
        e.preventDefault();
        var exportUrl = jQuery(this).attr('href');
        
        // Check if Swal is defined
        if (typeof Swal !== 'undefined') {
            Swal.fire({
                title: 'Export SOP Data?',
                text: 'Are you sure you want to export the SOP data?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, export',
                cancelButtonText: 'Cancel'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = exportUrl;
                }
            });
        } else {
            // Fallback if SweetAlert isn't loaded
            if (confirm('Are you sure you want to export the SOP data?')) {
                window.location.href = exportUrl;
            }
        }
    });
});