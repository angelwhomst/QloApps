<div class="panel">
    <div class="panel-heading">
        <i class="icon-building"></i> {l s='Room Details' mod='housekeepingmanagement'}: {$room.room_num|escape:'html':'UTF-8'}
    </div>
    
    <div class="row">
        <div class="col-md-6">
            <div class="panel">
                <div class="panel-heading">
                    <i class="icon-info-circle"></i> {l s='Room Information' mod='housekeepingmanagement'}
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-xs-4 text-right"><strong>{l s='Room Number:' mod='housekeepingmanagement'}</strong></div>
                        <div class="col-xs-8">{$room.room_num|escape:'html':'UTF-8'}</div>
                    </div>
                    <div class="row">
                        <div class="col-xs-4 text-right"><strong>{l s='Hotel:' mod='housekeepingmanagement'}</strong></div>
                        <div class="col-xs-8">{$room.hotel_name|escape:'html':'UTF-8'}</div>
                    </div>
                    <div class="row">
                        <div class="col-xs-4 text-right"><strong>{l s='Room Type:' mod='housekeepingmanagement'}</strong></div>
                        <div class="col-xs-8">{$room.room_type|escape:'html':'UTF-8'}</div>
                    </div>
                    <div class="row">
                        <div class="col-xs-4 text-right"><strong>{l s='Floor:' mod='housekeepingmanagement'}</strong></div>
                        <div class="col-xs-8">{$room.floor|escape:'html':'UTF-8'}</div>
                    </div>
                    {if $room.comment}
                        <div class="row">
                            <div class="col-xs-4 text-right"><strong>{l s='Comment:' mod='housekeepingmanagement'}</strong></div>
                            <div class="col-xs-8">{$room.comment|escape:'html':'UTF-8'}</div>
                        </div>
                    {/if}
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="panel">
                <div class="panel-heading">
                    <i class="icon-refresh"></i> {l s='Current Status' mod='housekeepingmanagement'}
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-xs-4 text-right"><strong>{l s='Status:' mod='housekeepingmanagement'}</strong></div>
                        <div class="col-xs-8">
                            {if $current_status.status == $status_cleaned}
                                <span class="badge badge-success">{l s='Cleaned' mod='housekeepingmanagement'}</span>
                            {elseif $current_status.status == $status_not_cleaned}
                                <span class="badge badge-warning">{l s='Not Cleaned' mod='housekeepingmanagement'}</span>
                            {elseif $current_status.status == $status_failed}
                                <span class="badge badge-danger">{l s='Failed Inspection' mod='housekeepingmanagement'}</span>
                            {/if}
                        </div>
                    </div>
                    {if $current_status.date_upd}
                        <div class="row">
                            <div class="col-xs-4 text-right"><strong>{l s='Last Updated:' mod='housekeepingmanagement'}</strong></div>
                            <div class="col-xs-8">{$current_status.date_upd|date_format:'%Y-%m-%d %H:%M:%S'}</div>
                        </div>
                    {/if}
                    {if $current_status.employee_name}
                        <div class="row">
                            <div class="col-xs-4 text-right"><strong>{l s='Updated By:' mod='housekeepingmanagement'}</strong></div>
                            <div class="col-xs-8">{$current_status.employee_name|escape:'html':'UTF-8'}</div>
                        </div>
                    {/if}
                    
                    <div class="row" style="margin-top: 20px;">
                        <div class="col-xs-12">
                            <form id="update-status-form" class="form-inline">
                                <input type="hidden" name="id_room" value="{$room.id|intval}">
                                <div class="form-group">
                                    <label for="status">{l s='Update Status:' mod='housekeepingmanagement'}</label>
                                    <select name="status" id="status" class="form-control">
                                        <option value="{$status_cleaned}">{l s='Cleaned' mod='housekeepingmanagement'}</option>
                                        <option value="{$status_not_cleaned}">{l s='Not Cleaned' mod='housekeepingmanagement'}</option>
                                        <option value="{$status_failed}">{l s='Failed Inspection' mod='housekeepingmanagement'}</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label for="notes">{l s='Notes:' mod='housekeepingmanagement'}</label>
                                    <input type="text" name="notes" id="notes" class="form-control" placeholder="{l s='Optional notes' mod='housekeepingmanagement'}">
                                </div>
                                <button type="submit" class="btn btn-primary">{l s='Update' mod='housekeepingmanagement'}</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="panel">
        <div class="panel-heading">
            <i class="icon-list"></i> {l s='Status History' mod='housekeepingmanagement'}
        </div>
        <div class="panel-body">
            {if $status_history}
                <table class="table">
                    <thead>
                        <tr>
                            <th>{l s='Date' mod='housekeepingmanagement'}</th>
                            <th>{l s='Status' mod='housekeepingmanagement'}</th>
                            <th>{l s='Updated By' mod='housekeepingmanagement'}</th>
                            <th>{l s='Notes' mod='housekeepingmanagement'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$status_history item=entry}
                            <tr>
                                <td>{$entry.date_upd|date_format:'%Y-%m-%d %H:%M:%S'}</td>
                                <td>
                                    {if $entry.status == $status_cleaned}
                                        <span class="badge badge-success">{l s='Cleaned' mod='housekeepingmanagement'}</span>
                                    {elseif $entry.status == $status_not_cleaned}
                                        <span class="badge badge-warning">{l s='Not Cleaned' mod='housekeepingmanagement'}</span>
                                    {elseif $entry.status == $status_failed}
                                        <span class="badge badge-danger">{l s='Failed Inspection' mod='housekeepingmanagement'}</span>
                                    {/if}
                                </td>
                                <td>{$entry.employee_name|escape:'html':'UTF-8'}</td>
                                <td>{$entry.notes|escape:'html':'UTF-8'}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {else}
                <div class="alert alert-info">
                    {l s='No status history available for this room.' mod='housekeepingmanagement'}
                </div>
            {/if}
        </div>
    </div>
    
    <div class="panel">
        <div class="panel-heading">
            <i class="icon-book"></i> {l s='Applicable SOPs' mod='housekeepingmanagement'}
        </div>
        <div class="panel-body">
            {if $sops}
                <div class="list-group">
                    {foreach from=$sops item=sop}
                        <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&viewsop=1" class="list-group-item">
                            <h4 class="list-group-item-heading">{$sop.title|escape:'html':'UTF-8'}</h4>
                            <p class="list-group-item-text">{$sop.description|truncate:100:'...'|escape:'html':'UTF-8'}</p>
                        </a>
                    {/foreach}
                </div>
            {else}
                <div class="alert alert-info">
                    {l s='No SOPs available for this room type.' mod='housekeepingmanagement'}
                </div>
            {/if}
        </div>
    </div>
    
    <div class="panel-footer">
        <a href="{$link->getAdminLink('AdminRoomStatusManagement')|escape:'html':'UTF-8'}" class="btn btn-default">
            <i class="process-icon-back"></i> {l s='Back to list' mod='housekeepingmanagement'}
        </a>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function() {
        $('#update-status-form').submit(function(e) {
            e.preventDefault();
            
            $.ajax({
                url: '{$link->getAdminLink('AdminRoomStatusManagement')|escape:'javascript':'UTF-8'}&ajax=1&action=updateRoomStatus',
                type: 'POST',
                data: $(this).serialize(),
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        showSuccessMessage(response.message);
                        setTimeout(function() {
                            location.reload();
                        }, 1000);
                    } else {
                        showErrorMessage(response.message);
                    }
                },
                error: function() {
                    showErrorMessage('{l s='An error occurred while updating room status' mod='housekeepingmanagement' js=1}');
                }
            });
        });
    });
</script>