{* Supervisor - Room Inspection Detail *}
<div class="panel" id="inspection-detail" data-room="{$room.id_room|intval}">
    <div class="panel-heading">
        <i class="icon-eye-open"></i> {l s='Room Inspection' mod='housekeepingmanagement'}
    </div>

    <div class="row">
        <div class="col-lg-6">
            <h3 style="margin-top:0;">
                {l s='Room' mod='housekeepingmanagement'} #{$room.room_num|escape:'html':'UTF-8'}
                <small>— {$room.room_type|escape:'html':'UTF-8'}</small>
            </h3>
        </div>
        <div class="col-lg-6 text-right">
            <span class="badge" style="background:#E0F0FF; color:#007bff;" aria-label="{l s='Status To Be Inspected' mod='housekeepingmanagement'}">{l s='To Be Inspected' mod='housekeepingmanagement'}</span>
        </div>
    </div>

    <div class="row" style="margin-top:10px;">
        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
            <div class="well" style="margin:0;">
                <div style="color:#666;">{l s='Assigned Staff' mod='housekeepingmanagement'}</div>
                <div style="font-weight:700;">{$room.staff_name|escape:'html':'UTF-8'}</div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
            <div class="well" style="margin:0;">
                <div style="color:#666;">{l s='Completed Cleaning' mod='housekeepingmanagement'}</div>
                <div style="font-weight:700;">{$room.completed_time|date_format:"%Y-%m-%d %H:%M"}</div>
            </div>
        </div>
        <div class="col-lg-6 col-md-12" style="margin-bottom:10px;">
            <div class="well" id="progress-summary" aria-live="polite" style="margin:0;display:flex;justify-content:space-between;align-items:center;">
                <strong>{l s='Checklist Progress' mod='housekeepingmanagement'}:</strong>
                <span id="progress-text">0/{$totalSteps|intval} {l s='tasks done' mod='housekeepingmanagement'}</span>
            </div>
        </div>
    </div>

    <hr/>

    <form id="inspection-form" aria-describedby="inspection-help">
        <p id="inspection-help" class="help-block">{l s='Review each item. Toggle pass/fail. Use keyboard Tab to navigate and Space/Enter to toggle.' mod='housekeepingmanagement'}</p>

        <div class="row">
            {foreach from=$steps item=step}
                <div class="col-lg-6 col-md-12" style="margin-bottom:10px;">
                    <div class="well" style="display:flex; align-items:center; justify-content:space-between;">
                        <div>
                            <label for="step-{$step.id_sop_step|intval}" class="control-label" style="margin:0;">{$step.step_description|escape:'html':'UTF-8'}</label>
                        </div>
                        <div>
                            <div class="switch" style="display:inline-block;">
                                <input type="checkbox" id="step-{$step.id_sop_step|intval}" class="inspection-toggle" role="switch" aria-checked="false" aria-label="{$step.step_description|escape:'html':'UTF-8'}" data-id="{$step.id_sop_step|intval}" data-label="{$step.step_description|escape:'html':'UTF-8'}" />
                            </div>
                            <span class="label state-indicator" style="margin-left:8px; background:#FFF5E0; color:#F5A623;">{l s='Failed' mod='housekeepingmanagement'}</span>
                        </div>
                    </div>
                </div>
            {/foreach}
        </div>

        <div class="form-group">
            <button type="button" class="btn btn-default" id="add-remarks" aria-haspopup="dialog">
                <i class="icon-edit"></i> {l s='Add Remarks' mod='housekeepingmanagement'}
            </button>
            <div id="remarks-modal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="remarksTitle" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="{l s='Close' mod='housekeepingmanagement'}"><span aria-hidden="true">&times;</span></button>
                            <h4 class="modal-title" id="remarksTitle">{l s='Inspection Remarks' mod='housekeepingmanagement'}</h4>
                        </div>
                        <div class="modal-body">
                            <textarea id="remarks-text" class="form-control" rows="5" placeholder="{l s='Optional notes...' mod='housekeepingmanagement'}"></textarea>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">{l s='Close' mod='housekeepingmanagement'}</button>
                            <button type="button" class="btn btn-primary" data-dismiss="modal">{l s='Save' mod='housekeepingmanagement'}</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="panel-footer" style="display:flex; gap:10px; flex-wrap:wrap;">
            <button type="button" id="reject-btn" class="btn btn-danger" aria-label="{l s='Reject inspection' mod='housekeepingmanagement'}">
                <i class="icon-remove"></i> {l s='Reject' mod='housekeepingmanagement'}
            </button>
            <button type="button" id="approve-btn" class="btn btn-success" aria-label="{l s='Approve inspection' mod='housekeepingmanagement'}">
                <i class="icon-check"></i> {l s='Approve' mod='housekeepingmanagement'}
            </button>
            <span id="loading" class="label label-info" style="display:none;">{l s='Submitting...' mod='housekeepingmanagement'}</span>
        </div>
    </form>

    {literal}
    <script>
    (function() {
        var toggles = document.querySelectorAll('.inspection-toggle');
        var progressText = document.getElementById('progress-text');
        var remarksBtn = document.getElementById('add-remarks');
        var approveBtn = document.getElementById('approve-btn');
        var rejectBtn = document.getElementById('reject-btn');
        var loading = document.getElementById('loading');
        var roomId = document.getElementById('inspection-detail').getAttribute('data-room');
        var remarksText = document.getElementById('remarks-text');

        function pad(num, size){
            var s = String(num);
            while (s.length < size) s = '0' + s;
            return s;
        }
        function updateProgress() {
            var total = toggles.length;
            var digits = String(total).length; // pad width based on total
            var passed = 0;
            toggles.forEach(function(t){ if (t.checked) passed++; });
            progressText.textContent = pad(passed, digits) + '/' + pad(total, digits) + ' tasks done';
        }

        function updateIndicator(toggle) {
            var label = toggle.closest('.well').querySelector('.state-indicator');
            if (toggle.checked) {
                label.textContent = 'Passed';
                label.style.background = '#E7F8F0';
                label.style.color = '#41C588';
                toggle.setAttribute('aria-checked', 'true');
            } else {
                label.textContent = 'Failed';
                label.style.background = '#FFF5E0';
                label.style.color = '#F5A623';
                toggle.setAttribute('aria-checked', 'false');
            }
        }

        toggles.forEach(function(t){
            t.addEventListener('change', function(){
                updateIndicator(t);
                updateProgress();
            });
            // init
            updateIndicator(t);
        });
        updateProgress();

        if (remarksBtn) {
            remarksBtn.addEventListener('click', function(){
                if (window.jQuery && jQuery.fn.modal) {
                    jQuery('#remarks-modal').modal('show');
                } else {
                    alert('Enter remarks in the next prompt');
                    var v = prompt('Remarks:');
                    if (v !== null) { remarksText.value = v; }
                }
            });
        }

        function submit(decision) {
            loading.style.display = 'inline-block';
            approveBtn.disabled = true;
            rejectBtn.disabled = true;

            var items = [];
            toggles.forEach(function(t){
                items.push({ id: t.getAttribute('data-id'), label: t.getAttribute('data-label'), passed: t.checked ? 1 : 0 });
            });

            var xhr = new XMLHttpRequest();
            xhr.open('POST', window.location.href, true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');

            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    loading.style.display = 'none';
                    approveBtn.disabled = false;
                    rejectBtn.disabled = false;
                    try {
                        var res = JSON.parse(xhr.responseText);
                        if (res && res.success) {
                            if (window.jQuery && jQuery.fn.toast) {
                                jQuery('.bootstrap .alert').remove();
                                jQuery('<div class="alert alert-success" role="alert">').text('Inspection submitted').prependTo('.panel');
                            } else {
                                alert('Inspection submitted');
                            }
                            // reload to list
                            var url = new URL(window.location.href);
                            url.searchParams.delete('inspect_room');
                            url.searchParams.delete('id_room');
                            window.location.href = url.toString();
                        } else {
                            alert((res && res.message) ? res.message : 'Error');
                        }
                    } catch (e) {
                        alert('Unexpected response');
                    }
                }
            };

            var params = [];
            params.push('ajax=1');
            params.push('action=SubmitInspection');
            params.push('id_room=' + encodeURIComponent(roomId));
            params.push('decision=' + encodeURIComponent(decision));
            params.push('remarks=' + encodeURIComponent(remarksText.value || ''));
            params.push('items=' + encodeURIComponent(JSON.stringify(items)));

            xhr.send(params.join('&'));
        }

        approveBtn.addEventListener('click', function(){ submit('approve'); });
        rejectBtn.addEventListener('click', function(){ submit('reject'); });
    })();
    </script>
    {/literal}
</div>

