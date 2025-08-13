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
                    <i class="icon-search"></i> {l s='Filter Rooms' mod='housekeepingmanagement'}
                </div>
                <div class="panel-body">
                    <form id="filter-form" class="form-inline" method="post">
                        <div class="form-group">
                            <label for="filter-status">{l s='Status:' mod='housekeepingmanagement'}</label>
                            <select id="filter-status" class="form-control">
                                <option value="">{l s='All' mod='housekeepingmanagement'}</option>
                                <option value="{$cleaned_status}">{l s='Cleaned' mod='housekeepingmanagement'}</option>
                                <option value="{$not_cleaned_status}">{l s='Not Cleaned' mod='housekeepingmanagement'}</option>
                                <option value="{$failed_inspection_status}">{l s='Failed Inspection' mod='housekeepingmanagement'}</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="filter-hotel">{l s='Hotel:' mod='housekeepingmanagement'}</label>
                            <select id="filter-hotel" class="form-control">
                                <option value="">{l s='All' mod='housekeepingmanagement'}</option>
                                {assign var=hotels value=[]}
                                {foreach from=$rooms item=room}
                                    {if !in_array($room.hotel_name, $hotels)}
                                        {append var=hotels value=$room.hotel_name}
                                        <option value="{$room.hotel_name|escape:'html':'UTF-8'}">{$room.hotel_name|escape:'html':'UTF-8'}</option>
                                    {/if}
                                {/foreach}
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="filter-room-type">{l s='Room Type:' mod='housekeepingmanagement'}</label>
                            <select id="filter-room-type" class="form-control">
                                <option value="">{l s='All' mod='housekeepingmanagement'}</option>
                                {assign var=roomTypes value=[]}
                                {foreach from=$rooms item=room}
                                    {if !in_array($room.room_type, $roomTypes)}
                                        {append var=roomTypes value=$room.room_type}
                                        <option value="{$room.room_type|escape:'html':'UTF-8'}">{$room.room_type|escape:'html':'UTF-8'}</option>
                                    {/if}
                                {/foreach}
                            </select>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <div class="table-responsive">
        <table id="room-status-table" class="table">
            <thead>
                <tr>
                    <th>{l s='Room Number' mod='housekeepingmanagement'}</th>
                    <th>{l s='Room Type' mod='housekeepingmanagement'}</th>
                    <th>{l s='Hotel' mod='housekeepingmanagement'}</th>
                    <th>{l s='Status' mod='housekeepingmanagement'}</th>
                    <th>{l s='Actions' mod='housekeepingmanagement'}</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$rooms item=room}
                    <tr data-id-room="{$room.id}" data-hotel="{$room.hotel_name|escape:'html':'UTF-8'}" data-room-type="{$room.room_type|escape:'html':'UTF-8'}" data-status="{$room.status|escape:'html':'UTF-8'}">
                        <td>{$room.room_num|escape:'html':'UTF-8'}</td>
                        <td>{$room.room_type|escape:'html':'UTF-8'}</td>
                        <td>{$room.hotel_name|escape:'html':'UTF-8'}</td>
                        <td>
                            {if $room.status == $cleaned_status}
                                <span class="label label-success">{l s='Cleaned' mod='housekeepingmanagement'}</span>
                            {elseif $room.status == $not_cleaned_status}
                                <span class="label label-warning">{l s='Not Cleaned' mod='housekeepingmanagement'}</span>
                            {elseif $room.status == $failed_inspection_status}
                                <span class="label label-danger">{l s='Failed Inspection' mod='housekeepingmanagement'}</span>
                            {/if}
                        </td>
                        <td>
                            <div class="btn-group">
                                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                                    {l s='Change Status' mod='housekeepingmanagement'} <span class="caret"></span>
                                </button>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a href="#" class="update-status" data-status="{$cleaned_status}">
                                            <i class="icon-check text-success"></i> {l s='Mark as Cleaned' mod='housekeepingmanagement'}
                                        </a>
                                    </li>
                                    <li>
                                        <a href="#" class="update-status" data-status="{$not_cleaned_status}">
                                            <i class="icon-times text-warning"></i> {l s='Mark as Not Cleaned' mod='housekeepingmanagement'}
                                        </a>
                                    </li>
                                    <li>
                                        <a href="#" class="update-status" data-status="{$failed_inspection_status}">
                                            <i class="icon-warning text-danger"></i> {l s='Mark as Failed Inspection' mod='housekeepingmanagement'}
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function() {
        // Filter table
        function filterTable() {
            var statusFilter = $('#filter-status').val();
            var hotelFilter = $('#filter-hotel').val();
            var roomTypeFilter = $('#filter-room-type').val();
            
            $('#room-status-table tbody tr').each(function() {
                var show = true;
                
                if (statusFilter && $(this).data('status') != statusFilter) {
                    show = false;
                }
                
                if (hotelFilter && $(this).data('hotel') != hotelFilter) {
                    show = false;
                }
                
                if (roomTypeFilter && $(this).data('room-type') != roomTypeFilter) {
                    show = false;
                }
                
                if (show) {
                    $(this).show();
                } else {
                    $(this).hide();
                }
            });
        }
        
        $('#filter-status, #filter-hotel, #filter-room-type').change(function() {
            filterTable();
        });
        
        // Update room status
        $('.update-status').click(function(e) {
            e.preventDefault();
            
            var btn = $(this);
            var row = btn.closest('tr');
            var idRoom = row.data('id-room');
            var status = btn.data('status');
            
            $.ajax({
                url: '{$current_url|escape:'javascript':'UTF-8'}&ajax=1&action=UpdateRoomStatus',
                type: 'POST',
                data: {
                    id_room: idRoom,
                    status: status
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        // Update row status
                        row.data('status', status);
                        
                        // Update status label
                        var statusCell = row.find('td:eq(3)');
                        statusCell.empty();
                        
                        if (status == '{$cleaned_status}') {
                            statusCell.html('<span class="label label-success">{l s='Cleaned' mod='housekeepingmanagement'}</span>');
                        } else if (status == '{$not_cleaned_status}') {
                            statusCell.html('<span class="label label-warning">{l s='Not Cleaned' mod='housekeepingmanagement'}</span>');
                        } else if (status == '{$failed_inspection_status}') {
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