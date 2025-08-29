{*
  Housekeeper Task Detail View - Modern Professional UI
  - Room info, checklist, progress, toggle switches, Done button
  - Accessible, responsive, color contrast
*}

{* Include the CSS file *}
<link rel="stylesheet" href="{$module_dir|default:''}views/css/housekeeping-front.css">

<a href="{$back_link|default:'javascript:history.back()'}" class="hk-back-btn">← Back to Dashboard</a>

<div class="hk-task-wrapper" data-id-task="{$task.id_task|intval}" data-ajax-url="{$current_url|default:''}">
    <div class="hk-task-header">
        <div class="hk-task-room">
            <div class="hk-room-line">
                <span class="hk-room-number" id="hk-room-number">Room {$task.room_num|escape:'html'}</span>
                <span class="hk-sep">•</span>
                <span class="hk-room-type" id="hk-room-type">{$task.room_type_name|escape:'html'}</span>
            </div>
            <div class="hk-task-details">
                <div class="hk-detail-row">
                    <div class="hk-detail-item">
                        <span class="hk-label">Priority:</span> 
                        <span class="hk-priority {$task.priority|strtolower|escape:'html'}" id="hk-priority">{$task.priority|escape:'html'}</span>
                    </div>
                    <div class="hk-detail-item">
                        <span class="hk-label">Assigned:</span> 
                        <span id="hk-staff">{$task.employee_name|escape:'html'}</span>
                    </div>
                </div>
                <div class="hk-dates">
                    <div class="hk-date-item"><span class="hk-label">Start:</span> <span id="hk-start">{$task.date_add|date_format:"%m/%d/%Y %H:%M"}</span></div>
                    <div class="hk-date-item"><span class="hk-label">Due:</span> <span id="hk-due">{$task.deadline|date_format:"%m/%d/%Y %H:%M"}</span></div>
                </div>
            </div>
        </div>
        <div class="hk-task-meta">
            <span class="hk-status hk-status-{if $task.status=='in_progress'}progress{elseif $task.status=='done'}done{else}not-started{/if}" id="hk-status-badge" aria-live="polite">
                {if $task.status=='in_progress'}In Progress{elseif $task.status=='done'}Done{else}To Do{/if}
            </span>
            {assign var=doneCount value=$task.completion.completed|default:0}
            {assign var=totalCount value=$task.completion.total|default:0}
            <span class="hk-progress" id="hk-progress" aria-live="polite">
                Checklist Done: {$doneCount}/{$totalCount}
            </span>
        </div>
    </div>

    {* show disclaimer if task failed inspection and is now reassigned as to_do, but all steps are already passed *}
    {if $task.status == 'to_do' && $task.completion.completed == $task.completion.total && $task.completion.total > 0}
        <div class="hk-failed-inspection-disclaimer" style="background:#fff3cd; color:#856404; border:1px solid #ffeeba; border-radius:6px; padding:16px; margin:16px 0; font-size:15px; display:flex; align-items:center; gap:10px;">
            <i class="fas fa-exclamation-triangle" style="font-size:20px; color:#f5a623;"></i>
            <span>
                This task failed inspection. Please take time to carefully redo the cleaning and checklist before marking as done again.
            </span>
        </div>
    {/if}

    {if isset($task.special_notes) && $task.special_notes}
    <div class="hk-task-note" id="hk-task-note">
        <p class="hk-note-text">{$task.special_notes|escape:'html'}</p>
    </div>
    {/if}

    <div class="hk-checklist" id="hk-checklist" aria-live="polite">
        {if isset($task.steps) && $task.steps|@count > 0}
            {assign var=stepsCount value=$task.steps|@count}
            {if $stepsCount > 5}
                {assign var=half value=ceil($stepsCount/2)}
                <div class="hk-checklist-columns">
                    <div class="hk-checklist-col">
                        {section name=left start=0 loop=$half}
                            {assign var=step value=$task.steps[left]}
                            <div class="hk-checklist-item {$step.status}" data-step-id="{$step.id_task_step|intval}">
                                <div class="hk-step-content">
                                    <span class="hk-item-label">{$step.step_description|escape:'html'}</span>
                                    <span class="hk-step-status {$step.status}">
                                        {if $step.status == 'passed'}Passed{elseif $step.status == 'failed'}Failed{else}Not Started{/if}
                                    </span>
                                </div>
                                <div class="hk-step-actions">
                                    <div class="hk-toggle-switch-group">
                                        <div class="hk-toggle-switch pass-fail-toggle">
                                            <input type="checkbox" 
                                                  id="toggle-{$step.id_task_step}" 
                                                  class="toggle-input"
                                                  data-step-id="{$step.id_task_step|intval}"
                                                  {if $step.status == 'passed'}checked{/if}
                                                  aria-label="Toggle pass/fail for step: {$step.step_description|escape:'html'}">
                                            <label for="toggle-{$step.id_task_step}" class="toggle-label"></label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        {/section}
                    </div>
                    <div class="hk-checklist-col">
                        {section name=right start=$half loop=$stepsCount}
                            {assign var=step value=$task.steps[right]}
                            <div class="hk-checklist-item {$step.status}" data-step-id="{$step.id_task_step|intval}">
                                <div class="hk-step-content">
                                    <span class="hk-item-label">{$step.step_description|escape:'html'}</span>
                                    <span class="hk-step-status {$step.status}">
                                        {if $step.status == 'passed'}Passed{elseif $step.status == 'failed'}Failed{else}Not Started{/if}
                                    </span>
                                </div>
                                <div class="hk-step-actions">
                                    <div class="hk-toggle-switch-group">
                                        <div class="hk-toggle-switch pass-fail-toggle">
                                            <input type="checkbox" 
                                                  id="toggle-{$step.id_task_step}" 
                                                  class="toggle-input"
                                                  data-step-id="{$step.id_task_step|intval}"
                                                  {if $step.status == 'passed'}checked{/if}
                                                  aria-label="Toggle pass/fail for step: {$step.step_description|escape:'html'}">
                                            <label for="toggle-{$step.id_task_step}" class="toggle-label"></label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        {/section}
                    </div>
                </div>
            {else}
                {foreach from=$task.steps item=step}
                    <div class="hk-checklist-item {$step.status}" data-step-id="{$step.id_task_step|intval}">
                        <div class="hk-step-content">
                            <span class="hk-item-label">{$step.step_description|escape:'html'}</span>
                            <span class="hk-step-status {$step.status}">
                                {if $step.status == 'passed'}Passed{elseif $step.status == 'failed'}Failed{else}Not Started{/if}
                            </span>
                        </div>
                        <div class="hk-step-actions">
                            <div class="hk-toggle-switch-group">
                                <div class="hk-toggle-switch pass-fail-toggle">
                                    <input type="checkbox" 
                                          id="toggle-{$step.id_task_step}" 
                                          class="toggle-input"
                                          data-step-id="{$step.id_task_step|intval}"
                                          {if $step.status == 'passed'}checked{/if}
                                          aria-label="Toggle pass/fail for step: {$step.step_description|escape:'html'}">
                                    <label for="toggle-{$step.id_task_step}" class="toggle-label"></label>
                                </div>
                            </div>
                        </div>
                    </div>
                {/foreach}
            {/if}
        {else}
            <div class="hk-empty">
                <div style="margin-bottom:8px;">📋</div>
                <div>No checklist steps found for this task.</div>
            </div>
        {/if}
    </div>

    <div class="hk-actions">
        <button type="button" 
                id="hk-btn-submit" 
                class="hk-btn hk-btn-primary" 
                aria-label="Submit checklist and mark task as done" 
                {if $task.status=='done'}disabled{/if}>
            {if $task.status=='done'}Task Completed{else}Mark Task as Done{/if}
        </button>
    </div>

    <div class="hk-toast" id="hk-toast" role="status" aria-live="polite" aria-atomic="true"></div>
</div>

<style>
/* Standard toggle switch style */
.hk-toggle-switch {
    position: relative;
    display: inline-block;
    width: 46px;
    height: 26px;
}
.toggle-input {
    opacity: 0;
    width: 0;
    height: 0;
}
.toggle-label {
    position: absolute;
    cursor: pointer;
    top: 0; left: 0;
    right: 0; bottom: 0;
    background-color: #d1d5db;
    transition: background-color 0.3s;
    border-radius: 26px;
}
.toggle-label:before {
    position: absolute;
    content: "";
    height: 22px;
    width: 22px;
    left: 2px;
    bottom: 2px;
    background-color: #fff;
    transition: .3s;
    border-radius: 50%;
    box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}
.toggle-input:checked + .toggle-label {
    background-color: #22c55e;
}
.toggle-input:not(:checked) + .toggle-label {
    background-color: #9ca3af;
}
.toggle-input:checked + .toggle-label:before {
    transform: translateX(20px);
}
.toggle-input:focus + .toggle-label {
    box-shadow: 0 0 0 2px #0ea5e9;
    outline: none;
}
.hk-toggle-switch-group {
    display: flex;
    align-items: center;
}
.hk-step-actions {
    display: flex;
    gap: 8px;
    margin-left: 16px;
}
.hk-checklist-item {
    display: flex;
    align-items: center;
    padding: 12px 16px;
    border-radius: 8px;
    border: 1px solid #e5e7eb;
    margin-bottom: 12px;
    transition: all 0.2s;
}
.hk-checklist-item.passed {
    border-left: 4px solid #22c55e;
    background-color: #f0fdf4;
}
.hk-checklist-item.failed {
    border-left: 4px solid #9ca3af;
    background-color: #f9fafb;
}
.hk-step-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 4px;
}
.hk-item-label {
    font-size: 14px;
    font-weight: 500;
    color: #374151;
}
.hk-step-status.passed {
    background: #dcfce7;
    color: #166534;
padding: 2px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
}
.hk-step-status.failed {
    background: #f3f4f6;
    color: #6b7280;
    padding: 2px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
}
.hk-step-status.not_started {
    background: #f0f0f0;
    color: #888;
    padding: 2px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
}
.hk-checklist-columns {
    display: flex;
    gap: 24px;
}
.hk-checklist-col {
    flex: 1 1 0;
    min-width: 0;
}
@media (max-width: 700px) {
    .hk-checklist-columns {
        flex-direction: column;
        gap: 0;
    }
    .hk-checklist-col {
        width: 100%;
    }
}
</style>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
{literal}
<script>
document.addEventListener('DOMContentLoaded', function() {
    const taskWrapper = document.querySelector('.hk-task-wrapper');
    const taskId = taskWrapper.dataset.idTask;
    const submitBtn = document.getElementById('hk-btn-submit');
    const statusBadge = document.getElementById('hk-status-badge');
    const progressText = document.getElementById('hk-progress');
    
    // Function to show SweetAlert toast messages
    function showToast(message, isError = false) {
        Swal.fire({
            toast: true,
            position: 'bottom',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true,
            icon: isError ? 'error' : 'success',
            title: message,
            background: isError ? '#fee' : '#efe',
            color: isError ? '#c33' : '#363',
        });
    }
    
    // Function to handle AJAX errors with SweetAlert
    function handleAjaxError(error) {
        console.error('AJAX Error:', error);
        Swal.fire({
            icon: 'error',
            title: 'Communication Error',
            text: 'Failed to communicate with the server. Please try again.',
            confirmButtonColor: '#dc2626'
        });
    }
    
    // Function to safely parse JSON responses
    function safelyParseJson(text) {
        try {
            return JSON.parse(text);
        } catch (e) {
            console.error('Invalid JSON response:', text);
            throw new Error('Invalid server response');
        }
    }
    
    // Function to update step status
    function updateStepStatus(stepId, status) {
        const formData = new FormData();
        formData.append('ajax', '1');
        formData.append('action', 'updateStepStatus');
        formData.append('id_task_step', stepId);
        formData.append('status', status);
        formData.append('id_task', taskId);
        formData.append('token', '{/literal}{$current_token|escape:'javascript'}{literal}');
        
        fetch(window.location.href, {
            method: 'POST',
            body: formData
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.text();
        })
        .then(text => {
            try {
                const data = safelyParseJson(text);
                if (data.success) {
                    // Update the step visual status
                    const stepItem = document.querySelector('[data-step-id="' + stepId + '"]');
                    if (stepItem) {
                        stepItem.className = 'hk-checklist-item ' + status;
                        const statusSpan = stepItem.querySelector('.hk-step-status');
                        if (statusSpan) {
                            statusSpan.className = 'hk-step-status ' + status;
                            statusSpan.textContent = status === 'passed' ? 'Passed' : (status === 'failed' ? 'Failed' : 'Not Started');
                        }
                    }
                    
                    if (data.completion) {
                        progressText.textContent = 'Checklist Done: ' + data.completion.completed + '/' + data.completion.total;
                    }
                    
                    // Update status to in progress if needed
                    if (statusBadge.textContent.trim() === 'To Do') {
                        statusBadge.textContent = 'In Progress';
                        statusBadge.className = 'hk-status hk-status-progress';
                    }
                    
                    showToast('Step updated successfully');
                } else {
                    showToast(data.message || 'Error updating step', true);
                }
            } catch (e) {
                handleAjaxError(e);
            }
        })
        .catch(handleAjaxError);
    }
    
    // Function to mark task as done
    function markTaskAsDone() {
        // Show loading state
        Swal.fire({
            title: 'Processing...',
            text: 'Marking task as done',
            allowOutsideClick: false,
            allowEscapeKey: false,
            showConfirmButton: false,
            didOpen: () => {
                Swal.showLoading();
            }
        });
        
        const formData = new FormData();
        formData.append('ajax', '1');
        formData.append('action', 'markTaskDone');
        formData.append('id_task', taskId);
        formData.append('token', '{/literal}{$current_token|escape:'javascript'}{literal}');
        
        fetch(window.location.href, {
            method: 'POST',
            body: formData
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.text();
        })
        .then(text => {
            try {
                const data = safelyParseJson(text);
                if (data.success) {
                    // Update UI
                    submitBtn.disabled = true;
                    submitBtn.textContent = 'Task Completed';
                    
                    // Update status badge
                    statusBadge.textContent = 'Done';
                    statusBadge.className = 'hk-status hk-status-done';
                    
                    // Show success message
                    Swal.fire({
                        icon: 'success',
                        title: 'Task Completed!',
                        text: data.message || 'Task marked as done successfully',
                        confirmButtonColor: '#22c55e',
                        timer: 2000,
                        timerProgressBar: true
                    });
                } else {
                    // Show error message
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: data.message || 'Failed to mark task as done',
                        confirmButtonColor: '#dc2626'
                    });
                }
            } catch (e) {
                handleAjaxError(e);
            }
        })
        .catch(error => {
            handleAjaxError(error);
        });
    }
    
    // Add event listeners for toggle inputs (checkbox behavior for pass/fail)
    document.querySelectorAll('.toggle-input').forEach(input => {
        input.addEventListener('change', function() {
            const stepId = this.getAttribute('data-step-id');
            const stepItem = this.closest('.hk-checklist-item');
            const currentStatus = stepItem.classList.contains('passed') ? 'passed' : 
                                 stepItem.classList.contains('failed') ? 'failed' : 'not_started';
            
            let newStatus;
            if (this.checked) {
                // If checking, set to passed
                newStatus = 'passed';
            } else {
                // If unchecking from passed, set to failed
                if (currentStatus === 'passed') {
                    newStatus = 'failed';
                    // Keep checkbox unchecked for failed state
                } else {
                    // If unchecking from failed or not_started, set to not_started
                    newStatus = 'not_started';
                }
            }
            
            updateStepStatus(stepId, newStatus);
        });
    });
    
    // Add event listener for submit button with SweetAlert confirmation
    if (submitBtn && !submitBtn.disabled) {
        submitBtn.addEventListener('click', function() {
            // First, check if all checklist items are in "Passed" status
            const allSteps = document.querySelectorAll('.hk-checklist-item');
            const passedSteps = document.querySelectorAll('.hk-checklist-item.passed');
            const failedSteps = document.querySelectorAll('.hk-checklist-item.failed');
            const notStartedSteps = document.querySelectorAll('.hk-checklist-item:not(.passed):not(.failed)');
            
            const totalSteps = allSteps.length;
            const passedCount = passedSteps.length;
            const failedCount = failedSteps.length;
            const notStartedCount = notStartedSteps.length;
            
            // Check if there are any steps that are not "Passed"
            if (failedCount > 0 || notStartedCount > 0) {
                let warningText = 'You cannot mark this task as done.\n\n';
                
                warningText += '\nPlease complete all checklist items and make sure they are marked as "Passed" before marking the task as done.';
                
                Swal.fire({
                    icon: 'warning',
                    title: 'Checklist Incomplete',
                    text: warningText,
                    confirmButtonColor: '#f59e0b',
                    confirmButtonText: 'I understand',
                    allowOutsideClick: true,
                    width: '400px'
                });
                
                return; // Stop execution here
            }
            
            // If all steps are passed, show confirmation dialog
            Swal.fire({
                title: 'Confirm Task Completion',
                html: 'All <strong>' + totalSteps + '</strong> checklist items are completed successfully.<br><br>Are you sure you want to mark this task as done?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#22c55e',
                cancelButtonColor: '#6b7280',
                confirmButtonText: 'Yes, mark as done',
                cancelButtonText: 'Cancel',
                reverseButtons: true
            }).then((result) => {
                if (result.isConfirmed) {
                    markTaskAsDone();
                }
            });
        });
    }
});
</script>
{/literal}