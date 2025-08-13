<div class="panel">
    <div class="panel-heading">
        <i class="icon-building"></i> {l s='Room Status Management' mod='housekeepingmanagement'}
    </div>
    
    <div class="row">
        <div class="col-md-12">
            <div class="alert alert-info">
                {l s='Manage the cleaning status of all rooms in your hotel. You can mark rooms as cleaned, not cleaned, or failed inspection.' mod='housekeepingmanagement'}
            </div>
        </div>
    </div>
    
    <div class="row">
        <div class="col-md-3">
            <div class="panel">
                <div class="panel-heading">
                    <i class="icon-bar-chart"></i> {l s='Summary' mod='housekeepingmanagement'}
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-xs-6 text-right">{l s='Total Rooms:' mod='housekeepingmanagement'}</div>
                        <div class="col-xs-6"><strong>{$summary.total}</strong></div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 text-right">{l s='Cleaned:' mod='housekeepingmanagement'}</div>
                        <div class="col-xs-6"><strong class="text-success">{$summary.cleaned}</strong></div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 text-right">{l s='Not Cleaned:' mod='housekeepingmanagement'}</div>
                        <div class="col-xs-6"><strong class="text-warning">{$summary.not_cleaned}</strong></div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 text-right">{l s='Failed Inspection:' mod='housekeepingmanagement'}</div>
                        <div class="col-xs-6"><strong class="text-danger">{$summary.failed_inspection}</strong></div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-9">
            <div class="panel">
                <div class="panel-heading">
                    <i class="icon-list"></i> {l s='Room Status List' mod='housekeepingmanagement'}
                </div>
                <div class="panel-body">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>{l s='Room Number' mod='housekeepingmanagement'}</th>
                                    <th>{l s='Hotel' mod='housekeepingmanagement'}</th>
                                    <th>{l s='Room Type' mod='housekeepingmanagement'}</th>
                                    <th>{l s='Status' mod='housekeepingmanagement'}</th>
                                    <th>{l s='Last Updated' mod='housekeepingmanagement'}</th>
                                    <th>{l s='Actions' mod='housekeepingmanagement'}</th>
                                </tr>
                            </thead>
                            <tbody>
                                {if isset($rooms) && $rooms}
                                    {foreach from=$rooms item=room}
                                        <tr id="room-{$room.id}">
                                            <td>{$room.room_num}</td>
                                            <td>{$room.hotel_name}</td>
                                            <td>{$room.room_type_name}</td>
                                            <td class="status-cell">
                                                {if isset($room.status)}
                                                    {if $room.status == $status_cleaned}
                                                        <span class="label label-success">{l s='Cleaned' mod='housekeepingmanagement'}</span>
                                                    {elseif $room.status == $status_failed_inspection}
                                                        <span class="label label-danger">{l s='Failed Inspection' mod='housekeepingmanagement'}</span>
                                                    {else}
                                                        <span class="label label-warning">{l s='Not Cleaned' mod='housekeepingmanagement'}</span>
                                                    {/if}
                                                {else}
                                                    <span class="label label-warning">{l s='Not Cleaned' mod='housekeepingmanagement'}</span>
                                                {/if}
                                            </td>
                                            <td>
                                                {if isset($room.date_upd)}
                                                    {$room.date_upd|date_format:"%Y-%m-%d %H:%M"}
                                                {else}
                                                    -
                                                {/if}
                                            </td>
                                            <td>
                                                <div class="btn-group">
                                                    <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                                                        {l s='Update Status' mod='housekeepingmanagement'} <span class="caret"></span>
                                                    </button>
                                                    <ul class="dropdown-menu" role="menu">
                                                        <li>
                                                            <a href="#" class="update-status" data-room-id="{$room.id}" data-status="{$status_cleaned}">
                                                                <i class="icon-check text-success"></i> {l s='Mark as Cleaned' mod='housekeepingmanagement'}
                                                            </a>
                                                        </li>
                                                        <li>
                                                            <a href="#" class="update-status" data-room-id="{$room.id}" data-status="{$status_not_cleaned}">
                                                                <i class="icon-times text-warning"></i> {l s='Mark as Not Cleaned' mod='housekeepingmanagement'}
                                                            </a>
                                                        </li>
                                                        <li>
                                                            <a href="#" class="update-status" data-room-id="{$room.id}" data-status="{$status_failed_inspection}">
                                                                <i class="icon-warning text-danger"></i> {l s='Mark as Failed Inspection' mod='housekeepingmanagement'}
                                                            </a>
                                                        </li>
                                                    </ul>
                                                </div>
                                            </td>
                                        </tr>
                                    {/foreach}
                                {else}
                                    <tr>
                                        <td colspan="6" class="text-center">{l s='No rooms found' mod='housekeepingmanagement'}</td>
                                    </tr>
                                {/if}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function() {
        $('.update-status').click(function(e) {
            e.preventDefault();
            
            var roomId = $(this).data('room-id');
            var status = $(this).data('status');
            var statusCell = $('#room-' + roomId + ' .status-cell');
            
            $.ajax({
                url: '{$link->getAdminLink('AdminHousekeepingManagement')|escape:'javascript':'UTF-8'}&ajax=1&action=updateRoomStatus',
                type: 'POST',
                data: {
                    id_room: roomId,
                    status: status
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        // Update status cell
                        if (status == '{$status_cleaned}') {
                            statusCell.html('<span class="label label-success">{l s='Cleaned' mod='housekeepingmanagement'}</span>');
                        } else if (status == '{$status_not_cleaned}') {
                            statusCell.html('<span class="label label-warning">{l s='Not Cleaned' mod='housekeepingmanagement'}</span>');
                        } else if (status == '{$status_failed_inspection}') {
                            statusCell.html('<span class="label label-danger">{l s='Failed Inspection' mod='housekeepingmanagement'}</span>');
                        }
                        
                        // Update summary
                        $('.panel-body .row:eq(1) strong').text(response.summary.cleaned);
                        $('.panel-body .row:eq(2) strong').text(response.summary.not_cleaned);
                        $('.panel-body .row:eq(3) strong').text(response.summary.failed_inspection);
                        
                        // Show success message
                        showSuccessMessage(response.message);
                    } else {
                        // Show error message
                        showErrorMessage(response.message);
                    }
                },
                error: function() {
                    showErrorMessage('{l s='An error occurred while updating room status' mod='housekeepingmanagement'}');
                }
            });
        });
    });
</script>