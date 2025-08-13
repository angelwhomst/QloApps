<div class="panel">
    <div class="panel-heading">
        <i class="icon-bar-chart"></i> {l s='Room Status Summary' mod='housekeepingmanagement'}
    </div>
    
    <div class="row">
        <div class="col-md-6">
            <div class="panel">
                <div class="panel-heading">
                    <i class="icon-dashboard"></i> {l s='Overall Status' mod='housekeepingmanagement'}
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="col-xs-6 text-center">
                                            <div class="huge">{$summary.total}</div>
                                            <div>{l s='Total Rooms' mod='housekeepingmanagement'}</div>
                                        </div>
                                        <div class="col-xs-6">
                                            <div class="progress">
                                                <div class="progress-bar progress-bar-success" role="progressbar" 
                                                    style="width: {math equation="(c/t)*100" c=$summary.cleaned t=$summary.total}%">
                                                    {$summary.cleaned} {l s='Cleaned' mod='housekeepingmanagement'}
                                                </div>
                                            </div>
                                            <div class="progress">
                                                <div class="progress-bar progress-bar-warning" role="progressbar" 
                                                    style="width: {math equation="(nc/t)*100" nc=$summary.not_cleaned t=$summary.total}%">
                                                    {$summary.not_cleaned} {l s='Not Cleaned' mod='housekeepingmanagement'}
                                                </div>
                                            </div>
                                            <div class="progress">
                                                <div class="progress-bar progress-bar-danger" role="progressbar" 
                                                    style="width: {math equation="(f/t)*100" f=$summary.failed_inspection t=$summary.total}%">
                                                    {$summary.failed_inspection} {l s='Failed' mod='housekeepingmanagement'}
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="panel">
                <div class="panel-heading">
                    <i class="icon-bell"></i> {l s='Rooms Needing Attention' mod='housekeepingmanagement'}
                </div>
                <div class="panel-body">
                    {if $needs_attention}
                        <div class="alert alert-warning">
                            <strong>{l s='There are' mod='housekeepingmanagement'} {count($needs_attention)} {l s='rooms that need attention.' mod='housekeepingmanagement'}</strong>
                        </div>
                        <div class="list-group">
                            {foreach from=$needs_attention item=room name=rooms}
                                {if $smarty.foreach.rooms.index < 5}
                                    <a href="{$link->getAdminLink('AdminRoomStatusManagement')|escape:'html':'UTF-8'}&viewroom=1&id_room={$room.id}" class="list-group-item">
                                        <strong>{$room.room_num}</strong> - {$room.hotel_name} ({$room.room_type})
                                    </a>
                                {/if}
                            {/foreach}
                            {if count($needs_attention) > 5}
                                <div class="list-group-item text-center">
                                    <a href="{$link->getAdminLink('AdminRoomStatusManagement')|escape:'html':'UTF-8'}&needs_attention=1">
                                        {l s='View all' mod='housekeepingmanagement'} {count($needs_attention)} {l s='rooms' mod='housekeepingmanagement'}
                                    </a>
                                </div>
                            {/if}
                        </div>
                    {else}
                        <div class="alert alert-success">
                            <strong>{l s='All rooms are in good status.' mod='housekeepingmanagement'}</strong>
                        </div>
                    {/if}
                </div>
            </div>
        </div>
    </div>
    
    <div class="panel">
        <div class="panel-heading">
            <i class="icon-building"></i> {l s='Status by Hotel' mod='housekeepingmanagement'}
        </div>
        <div class="panel-body">
            <table class="table">
                <thead>
                    <tr>
                        <th>{l s='Hotel' mod='housekeepingmanagement'}</th>
                        <th class="text-center">{l s='Total Rooms' mod='housekeepingmanagement'}</th>
                        <th class="text-center">{l s='Cleaned' mod='housekeepingmanagement'}</th>
                        <th class="text-center">{l s='Not Cleaned' mod='housekeepingmanagement'}</th>
                        <th class="text-center">{l s='Failed Inspection' mod='housekeepingmanagement'}</th>
                        <th class="text-center">{l s='Progress' mod='housekeepingmanagement'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$status_by_hotel item=hotel}
                        <tr>
                            <td>{$hotel.hotel_name|escape:'html':'UTF-8'}</td>
                            <td class="text-center">{$hotel.total}</td>
                            <td class="text-center text-success">{$hotel.cleaned}</td>
                            <td class="text-center text-warning">{$hotel.not_cleaned}</td>
                            <td class="text-center text-danger">{$hotel.failed_inspection}</td>
                            <td>
                                <div class="progress">
                                    <div class="progress-bar progress-bar-success" role="progressbar" 
                                        style="width: {math equation="(c/t)*100" c=$hotel.cleaned t=$hotel.total}%">
                                    </div>
                                    <div class="progress-bar progress-bar-warning" role="progressbar" 
                                        style="width: {math equation="(nc/t)*100" nc=$hotel.not_cleaned t=$hotel.total}%">
                                    </div>
                                    <div class="progress-bar progress-bar-danger" role="progressbar" 
                                        style="width: {math equation="(f/t)*100" f=$hotel.failed_inspection t=$hotel.total}%">
                                    </div>
                                </div>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    </div>
    
    <div class="panel-footer">
        <a href="{$link->getAdminLink('AdminRoomStatusManagement')|escape:'html':'UTF-8'}" class="btn btn-default">
            <i class="process-icon-back"></i> {l s='Back to list' mod='housekeepingmanagement'}
        </a>
        <a href="{$link->getAdminLink('AdminRoomStatusManagement')|escape:'html':'UTF-8'}" class="btn btn-primary pull-right">
            <i class="process-icon-refresh"></i> {l s='Refresh Data' mod='housekeepingmanagement'}
        </a>
    </div>
</div>