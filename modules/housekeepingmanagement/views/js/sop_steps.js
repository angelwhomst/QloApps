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
        var emptySteps = 0;
        $('.step-input').each(function() {
            if ($(this).val().trim() === '') {
                emptySteps++;
                $(this).addClass('border-danger');
            } else {
                $(this).removeClass('border-danger');
            }
        });
        
        if (emptySteps > 0) {
            e.preventDefault();
            Swal.fire({
                title: empty_steps_error_title,
                text: empty_steps_error_msg,
                icon: 'error',
                confirmButtonColor: '#25B9D7'
            });
            return false;
        }
        
        return true;
    });

    // Confirm deletion
    $(document).on('click', '.btn-delete-sop', function(e) {
        e.preventDefault();
        var deleteUrl = $(this).attr('href');
        Swal.fire({
            title: delete_sop_title,
            text: delete_sop_confirm,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#E74C3C',
            cancelButtonColor: '#7A7A7A',
            confirmButtonText: delete_confirm_btn,
            cancelButtonText: delete_cancel_btn
        }).then((result) => {
            if (result.isConfirmed) {
                // proceed to delete URL (with token)
                window.location.href = deleteUrl;
            }
        });
    });

    // Form submission confirmation for SOP edit/update
    $('button[name="submitAddhousekeeping_sop"]').on('click', function(e) {
        e.preventDefault();
        
        // Get the form
        var form = $(this).closest('form');
        
        // First validate that all steps have content
        var hasEmptySteps = false;
        $('.step-item textarea').each(function() {
            if ($(this).val().trim() === '') {
                hasEmptySteps = true;
                return false;
            }
        });
        
        if (hasEmptySteps) {
            Swal.fire({
                title: typeof empty_steps_error_title !== 'undefined' ? empty_steps_error_title : 'Form Error',
                text: typeof empty_steps_error_msg !== 'undefined' ? empty_steps_error_msg : 'All steps must have a description',
                icon: 'error',
                width: '400px'
            });
            return;
        }
        
        // Show confirmation dialog
        Swal.fire({
            title: 'Save SOP?',
            text: 'Are you sure you want to save changes to this SOP?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Yes, save it',
            cancelButtonText: 'Cancel',
            width: '400px'
        }).then((result) => {
            if (result.isConfirmed) {
                // Submit the form
                form.submit();
            }
        });
    });

    // Apply animation to SOP list items
    $('.list-sop-item').each(function(index) {
        $(this).css('opacity', 0);
        setTimeout(function(element) {
            $(element).animate({opacity: 1}, 300);
        }, 50 * index, this);
    });

    // Highlight active tab
    $('.sop-tab-link').on('click', function() {
        $('.sop-tab-link').removeClass('active');
        $(this).addClass('active');
    });
});