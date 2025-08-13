/**
* NOTICE OF LICENSE
*
* This source file is subject to the Open Software License version 3.0
* that is bundled with this package in the file LICENSE.md
* It is also available through the world-wide-web at this URL:
* https://opensource.org/license/osl-3-0-php
*/

$(document).ready(function() {
    // Prevent form submission if no steps
    $('form#housekeeping_sop_form').on('submit', function(e) {
        if ($('.step-row').length < 1) {
            e.preventDefault();
            alert('At least one step is required');
            return false;
        }
        return true;
    });
});