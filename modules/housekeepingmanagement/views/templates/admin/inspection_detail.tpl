{*
  Room Inspection Detail View
  - Shows room details, cleaning checklist, and inspection actions
*}

{* Include the CSS file *}
<link rel="stylesheet" href="{$module_dir|default:''}views/css/housekeeping-front.css">

<div class="panel">
    <div class="panel-heading">
        <i class="icon-search"></i> {l s='Room Inspection' mod='housekeepingmanagement'}
        <div class="panel-heading-action">
            <a href="{$back_link|default:'javascript:history.back()'}" class="btn btn-default">
                <i class="icon-arrow-left"></i> {l s='Back to Inspection List' mod='housekeepingmanagement'}
            </a>
        </div>
    </div>
    
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
                        <div class="hk-date-item"><span class="hk-label">Cleaned:</span> <span id="hk-completed">{$task.date_upd|date_format:"%m/%d/%Y %H:%M"}</span></div>
                        <div class="hk-date-item"><span class="hk-label">Due:</span> <span id="hk-due">{$task.deadline|date_format:"%m/%d/%Y %H:%M"}</span></div>
                    </div>
                </div>
            </div>
            <div class="hk-task-meta">
                <span class="hk-status hk-status-pending" id="hk-status-badge" aria-live="polite">
                    {l s='To Be Inspected' mod='housekeepingmanagement'}
                </span>
                {assign var=doneCount value=$task.completion.completed|default:0}
                {assign var=totalCount value=$task.completion.total|default:0}
                <span class="hk-progress" id="hk-progress" aria-live="polite">
                    {l s='Checklist Done:' mod='housekeepingmanagement'} {$doneCount}/{$totalCount}
                </span>
            </div>
        </div>

        {if isset($task.special_notes) && $task.special_notes}
        <div class="hk-task-note" id="hk-task-note">
            <p class="hk-note-text">{$task.special_notes|escape:'html'}</p>
        </div>
        {/if}

        <div class="hk-checklist" id="hk-checklist" aria-live="polite">
            <h4>{l s='Cleaning Checklist' mod='housekeepingmanagement'}</h4>
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
                                            {if $step.status == 'passed'}
                                                {l s='Passed' mod='housekeepingmanagement'}
                                            {elseif $step.status == 'failed'}
                                                {l s='Failed' mod='housekeepingmanagement'}
                                            {else}
                                                {l s='Not Started' mod='housekeepingmanagement'}
                                            {/if}
                                        </span>
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
                                            {if $step.status == 'passed'}
                                                {l s='Passed' mod='housekeepingmanagement'}
                                            {elseif $step.status == 'failed'}
                                                {l s='Failed' mod='housekeepingmanagement'}
                                            {else}
                                                {l s='Not Started' mod='housekeepingmanagement'}
                                            {/if}
                                        </span>
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
                                    {if $step.status == 'passed'}
                                        {l s='Passed' mod='housekeepingmanagement'}
                                    {elseif $step.status == 'failed'}
                                        {l s='Failed' mod='housekeepingmanagement'}
                                    {else}
                                        {l s='Not Started' mod='housekeepingmanagement'}
                                    {/if}
                                </span>
                            </div>
                        </div>
                    {/foreach}
                {/if}
            {else}
                <div class="hk-empty">
                    <div style="margin-bottom:8px;">📋</div>
                    <div>{l s='No checklist steps found for this task.' mod='housekeepingmanagement'}</div>
                </div>
            {/if}
        </div>

        {if isset($view_only) && $view_only}
            <div class="alert alert-info" style="margin-top: 25px;">
                <i class="icon-info-sign"></i>
                {l s='This room is not yet up for inspection. You can only view the cleaning details and checklist at this time.' mod='housekeepingmanagement'}
            </div>
        {else}
            <div class="hk-inspection-form">
                <h4>{l s='Inspection Remarks' mod='housekeepingmanagement'}</h4>
                <div class="form-group">
                    <textarea id="inspection-remarks" class="form-control" rows="4" placeholder="{l s='Enter any remarks or feedback about the cleaning quality...' mod='housekeepingmanagement'}"></textarea>
                </div>
                
                <div class="hk-actions">
                    <button type="button" id="btn-reject-inspection" class="btn btn-danger">
                        <i class="icon-times"></i> {l s='Reject & Return for Cleaning' mod='housekeepingmanagement'}
                    </button>
                    <button type="button" id="btn-approve-inspection" class="btn btn-success">
                        <i class="icon-check"></i> {l s='Approve Cleaning' mod='housekeepingmanagement'}
                    </button>
                </div>
            </div>
        {/if}
    </div>
</div>

<style>
.hk-task-wrapper {
    background: #fff;
    border-radius: 8px;
    margin-bottom: 20px;
}

.hk-task-header {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    align-items: flex-start;
    gap: 20px;
    margin-bottom: 20px;
}

.hk-task-room {
    flex: 1;
    min-width: 250px;
}

.hk-room-line {
    display: flex;
    align-items: center;
    margin-bottom: 10px;
}

.hk-room-number {
    font-size: 20px;
    font-weight: 600;
    color: #333;
}

.hk-sep {
    margin: 0 8px;
    color: #aaa;
}

.hk-room-type {
    font-size: 16px;
    color: #666;
}

.hk-task-details {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.hk-detail-row {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;
}

.hk-detail-item {
    display: flex;
    align-items: center;
    gap: 5px;
}

.hk-label {
    color: #777;
    font-weight: 500;
}

.hk-priority {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 12px;
    font-weight: 600;
    font-size: 12px;
}

.hk-priority.high {
    background: #FEECEB;
    color: #F36960;
}

.hk-priority.medium {
    background: #FFF5E0;
    color: orange;
}

.hk-priority.low {
    background: #E7F8F0;
    color: #41C588;
}

.hk-dates {
    display: flex;
    gap: 15px;
    margin-top: 5px;
}

.hk-task-meta {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 8px;
}

.hk-status {
    display: inline-block;
    padding: 5px 12px;
    border-radius: 16px;
    font-weight: 600;
    font-size: 13px;
}

.hk-status-pending {
    background: #E0F0FF;
    color: #007bff;
}

.hk-progress {
    color: #666;
    font-size: 14px;
}

.hk-task-note {
    background: #FFF9E6;
    border-left: 4px solid #FFD43B;
    padding: 15px;
    margin-bottom: 20px;
    border-radius: 4px;
}

.hk-note-text {
    margin: 0;
    color: #555;
}

.hk-checklist {
    margin-bottom: 25px;
}

.hk-checklist h4 {
    font-weight: 600;
    margin-bottom: 15px;
    color: #333;
    font-size: 16px;
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
    border-left: 4px solid #ef4444;
    background-color: #fef2f2;
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

.hk-step-status {
    align-self: flex-start;
    font-size: 12px;
    font-weight: 600;
    padding: 2px 8px;
    border-radius: 12px;
}

.hk-step-status.passed {
    background: #dcfce7;
    color: #166534;
}

.hk-step-status.failed {
    background: #fee2e2;
    color: #b91c1c;
}

.hk-step-status.not_started {
    background: #f3f4f6;
    color: #6b7280;
}

.hk-checklist-columns {
    display: flex;
    gap: 24px;
}

.hk-checklist-col {
    flex: 1 1 0;
    min-width: 0;
}

.hk-inspection-form {
    background: #f9f9f9;
    padding: 20px;
    border-radius: 8px;
    margin-top: 25px;
    border: 1px solid #eee;
}

.hk-inspection-form h4 {
    font-weight: 600;
    margin-bottom: 15px;
    color: #333;
    font-size: 16px;
}

.hk-actions {
    display: flex;
    justify-content: flex-end;
    gap: 15px;
    margin-top: 15px;
}

@media (max-width: 768px) {
    .hk-task-header {
        flex-direction: column;
    }
    
    .hk-task-meta {
        align-items: flex-start;
    }
    
    .hk-checklist-columns {
        flex-direction: column;
    }
}
</style>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
{literal}
<script>
document.addEventListener('DOMContentLoaded', function() {
    const taskWrapper = document.querySelector('.hk-task-wrapper');
    const taskId = taskWrapper.dataset.idTask;
    const remarksField = document.getElementById('inspection-remarks');
    const approveBtn = document.getElementById('btn-approve-inspection');
    const rejectBtn = document.getElementById('btn-reject-inspection');
    
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
    
    // Function to validate completed checklist
    function validateChecklist() {
        const allSteps = document.querySelectorAll('.hk-checklist-item');
        const notStartedSteps = document.querySelectorAll('.hk-checklist-item:not(.passed):not(.failed)');
        
        return notStartedSteps.length === 0;
    }
    
    // Function to handle inspection approval
    function approveInspection() {
        // Check if all steps are either passed or failed (not in "not started" state)
        if (!validateChecklist()) {
            Swal.fire({
                icon: 'warning',
                title: 'Incomplete Checklist',
                text: 'All checklist items must be marked as Passed or Failed before approving.',
                confirmButtonColor: '#f59e0b'
            });
            return;
        }
        
        // Show confirmation
        Swal.fire({
            title: 'Approve Cleaning?',
            text: 'This will mark the room as clean and complete the task.',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#22c55e',
            cancelButtonColor: '#6b7280',
            confirmButtonText: 'Yes, Approve',
            cancelButtonText: 'Cancel'
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Processing...',
                    text: 'Submitting inspection result',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    showConfirmButton: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Submit approval via AJAX
                const formData = new FormData();
                formData.append('ajax', '1');
                formData.append('action', 'approveInspection');
                formData.append('id_task', taskId);
                formData.append('remarks', remarksField.value);
                formData.append('token', '{/literal}{$current_token|escape:'javascript'}{literal}');
                
                fetch(window.location.href, {
                    method: 'POST',
                    body: formData
                })
                .then(response => {
                    if (!response.ok) throw new Error('Network response was not ok');
                    return response.text();
                })
                .then(text => {
                    const data = safelyParseJson(text);
                    
                    if (data.success) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Inspection Approved',
                            text: data.message || 'The room has been approved as clean.',
                            confirmButtonColor: '#22c55e'
                        }).then(() => {
                            // Dispatch event to update task list
                            if (data.tasks) {
                                window.dispatchEvent(new CustomEvent('refresh-inspection-tasks', {
                                    detail: { tasks: data.tasks }
                                }));
                            }
                            
                            // Redirect back to inspection list
                            window.location.href = '{/literal}{$back_link|escape:'javascript'}{literal}';
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: data.message || 'Failed to approve inspection.',
                            confirmButtonColor: '#dc2626'
                        });
                    }
                })
                .catch(handleAjaxError);
            }
        });
    }
    
    // Function to handle inspection rejection
    function rejectInspection() {
        // Check if all steps are either passed or failed (not in "not started" state)
        if (!validateChecklist()) {
            Swal.fire({
                icon: 'warning',
                title: 'Incomplete Checklist',
                text: 'All checklist items must be marked as Passed or Failed before rejecting.',
                confirmButtonColor: '#f59e0b'
            });
            return;
        }
        
        // Check if remarks are provided
        if (!remarksField.value.trim()) {
            Swal.fire({
                icon: 'warning',
                title: 'Remarks Required',
                text: 'Please provide remarks explaining why the cleaning was rejected.',
                confirmButtonColor: '#f59e0b'
            });
            remarksField.focus();
            return;
        }
        
        // Show confirmation
        Swal.fire({
            title: 'Reject Cleaning?',
            text: 'This will mark the room as failed inspection and return it for cleaning.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc2626',
            cancelButtonColor: '#6b7280',
            confirmButtonText: 'Yes, Reject',
            cancelButtonText: 'Cancel'
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Processing...',
                    text: 'Submitting inspection result',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    showConfirmButton: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Submit rejection via AJAX
                const formData = new FormData();
                formData.append('ajax', '1');
                formData.append('action', 'rejectInspection');
                formData.append('id_task', taskId);
                formData.append('remarks', remarksField.value);
                formData.append('token', '{/literal}{$current_token|escape:'javascript'}{literal}');
                
                fetch(window.location.href, {
                    method: 'POST',
                    body: formData
                })
                .then(response => {
                    if (!response.ok) throw new Error('Network response was not ok');
                    return response.text();
                })
                .then(text => {
                    const data = safelyParseJson(text);
                    
                    if (data.success) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Inspection Rejected',
                            text: data.message || 'The room has been marked as failed inspection.',
                            confirmButtonColor: '#4b5563'
                        }).then(() => {
                            // Dispatch event to update task list
                            if (data.tasks) {
                                window.dispatchEvent(new CustomEvent('refresh-inspection-tasks', {
                                    detail: { tasks: data.tasks }
                                }));
                            }
                            
                            // Redirect back to inspection list
                            window.location.href = '{/literal}{$back_link|escape:'javascript'}{literal}';
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: data.message || 'Failed to reject inspection.',
                            confirmButtonColor: '#dc2626'
                        });
                    }
                })
                .catch(handleAjaxError);
            }
        });
    }
    
    // Attach event listeners to buttons
    if (approveBtn) {
        approveBtn.addEventListener('click', approveInspection);
    }
    
    if (rejectBtn) {
        rejectBtn.addEventListener('click', rejectInspection);
    }
});
</script>
{/literal}