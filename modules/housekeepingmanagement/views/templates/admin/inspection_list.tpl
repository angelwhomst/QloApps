<<<<<<< HEAD
{* Supervisor - Rooms To Be Inspected List *}
<div class="panel">
    <div class="panel-heading">
        <i class="icon-search"></i> {l s='Rooms To Be Inspected' mod='housekeepingmanagement'}
    </div>

    <div class="row" style="margin:10px 0 20px;">
        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
            <div class="well" style="display:flex;justify-content:space-between;align-items:center;">
                <div>
                    <div style="color:#666;">{l s='Cleaned Rooms' mod='housekeepingmanagement'}</div>
                    <div style="font-size:24px;font-weight:700;">{$counts.Cleaned|intval}</div>
                </div>
                <i class="icon-check" style="color:#41C588;font-size:22px;"></i>
            </div>
        </div>
        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
            <div class="well" style="display:flex;justify-content:space-between;align-items:center;">
                <div>
                    <div style="color:#666;">{l s='Not Cleaned' mod='housekeepingmanagement'}</div>
                    <div style="font-size:24px;font-weight:700;">{$counts['Not Cleaned']|intval}</div>
                </div>
                <i class="icon-ban" style="color:#F5A623;font-size:22px;"></i>
            </div>
        </div>
        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
            <div class="well" style="display:flex;justify-content:space-between;align-items:center;">
                <div>
                    <div style="color:#666;">{l s='To Be Inspected' mod='housekeepingmanagement'}</div>
                    <div style="font-size:24px;font-weight:700;">{$counts['To Be Inspected']|intval}</div>
                </div>
                <i class="icon-search" style="color:#007bff;font-size:22px;"></i>
            </div>
        </div>
        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
            <div class="well" style="display:flex;justify-content:space-between;align-items:center;">
                <div>
                    <div style="color:#666;">{l s='Failed Inspections' mod='housekeepingmanagement'}</div>
                    <div style="font-size:24px;font-weight:700;">{$counts['Failed Inspection']|intval}</div>
                </div>
                <i class="icon-remove" style="color:#F36960;font-size:22px;"></i>
            </div>
        </div>
    </div>

    {if isset($rooms) && $rooms|@count}
        <div class="table-responsive-row clearfix">
            <table class="table">
                <thead>
                    <tr>
                        <th>{l s='Room#' mod='housekeepingmanagement'}</th>
                        <th>{l s='Assigned Staff' mod='housekeepingmanagement'}</th>
                        <th>{l s='Room Type' mod='housekeepingmanagement'}</th>
                        <th>{l s='Completed Time' mod='housekeepingmanagement'}</th>
                        <th>{l s='Status' mod='housekeepingmanagement'}</th>
                        <th class="text-right">{l s='Actions' mod='housekeepingmanagement'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$rooms item=room}
                        <tr>
                            <td>{$room.room_number|escape:'html':'UTF-8'}</td>
                            <td>{if $room.staff_name}{$room.staff_name|escape:'html':'UTF-8'}{else}{l s='Unassigned' mod='housekeepingmanagement'}{/if}</td>
                            <td>{$room.room_type|escape:'html':'UTF-8'}</td>
                            <td>{$room.completed_time|date_format:"%Y-%m-%d %H:%M"}</td>
                            <td>
                                <span class="badge" style="background:#E0F0FF; color:#007bff;">{$room.status|escape:'html':'UTF-8'}</span>
                            </td>
                            <td class="text-right">
                                <a class="btn btn-default" href="{$currentIndex|escape:'html':'UTF-8'}&token={$token|escape:'html':'UTF-8'}&inspect_room=1&id_room={$room.id_room|intval}">
                                    <i class="icon-eye-open"></i> {l s='Inspect' mod='housekeepingmanagement'}
                                </a>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    {else}
        <div class="alert alert-info" role="status" aria-live="polite">
            {l s='No rooms are currently pending inspection. Once housekeeping marks rooms as cleaned, they will appear here for inspection.' mod='housekeepingmanagement'}
        </div>
    {/if}
</div>

=======
{* Supervisor - Rooms To Be Inspected List *}
<div class="panel">
    <div class="panel-heading">
        <i class="icon-search"></i> {l s='Rooms To Be Inspected' mod='housekeepingmanagement'}
    </div>

    <div class="row" style="margin:10px 0 20px;">
        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
            <div class="well" style="display:flex;justify-content:space-between;align-items:center;">
                <div>
                    <div style="color:#666;">{l s='Cleaned Rooms' mod='housekeepingmanagement'}</div>
                    <div style="font-size:24px;font-weight:700;">{$counts.Cleaned|intval}</div>
                </div>
                <i class="icon-check" style="color:#41C588;font-size:22px;"></i>
            </div>
        </div>
        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
            <div class="well" style="display:flex;justify-content:space-between;align-items:center;">
                <div>
                    <div style="color:#666;">{l s='Not Cleaned' mod='housekeepingmanagement'}</div>
                    <div style="font-size:24px;font-weight:700;">{$counts['Not Cleaned']|intval}</div>
                </div>
                <i class="icon-ban" style="color:#F5A623;font-size:22px;"></i>
            </div>
        </div>
        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
            <div class="well" style="display:flex;justify-content:space-between;align-items:center;">
                <div>
                    <div style="color:#666;">{l s='To Be Inspected' mod='housekeepingmanagement'}</div>
                    <div style="font-size:24px;font-weight:700;">{$counts['To Be Inspected']|intval}</div>
                </div>
                <i class="icon-search" style="color:#007bff;font-size:22px;"></i>
            </div>
        </div>
        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
            <div class="well" style="display:flex;justify-content:space-between;align-items:center;">
                <div>
                    <div style="color:#666;">{l s='Failed Inspections' mod='housekeepingmanagement'}</div>
                    <div style="font-size:24px;font-weight:700;">{$counts['Failed Inspection']|intval}</div>
                </div>
                <i class="icon-remove" style="color:#F36960;font-size:22px;"></i>
            </div>
        </div>
    </div>

    {if isset($rooms) && $rooms|@count}
        <div class="table-responsive-row clearfix">
            <table class="table">
                <thead>
                    <tr>
                        <th>{l s='Room#' mod='housekeepingmanagement'}</th>
                        <th>{l s='Assigned Staff' mod='housekeepingmanagement'}</th>
                        <th>{l s='Room Type' mod='housekeepingmanagement'}</th>
                        <th>{l s='Completed Time' mod='housekeepingmanagement'}</th>
                        <th>{l s='Status' mod='housekeepingmanagement'}</th>
                        <th class="text-right">{l s='Actions' mod='housekeepingmanagement'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$rooms item=room}
                        <tr>
                            <td>{$room.room_number|escape:'html':'UTF-8'}</td>
                            <td>{if $room.staff_name}{$room.staff_name|escape:'html':'UTF-8'}{else}{l s='Unassigned' mod='housekeepingmanagement'}{/if}</td>
                            <td>{$room.room_type|escape:'html':'UTF-8'}</td>
                            <td>{$room.completed_time|date_format:"%Y-%m-%d %H:%M"}</td>
                            <td>
                                <span class="badge" style="background:#E0F0FF; color:#007bff;">{$room.status|escape:'html':'UTF-8'}</span>
                            </td>
                            <td class="text-right">
                                <a class="btn btn-default" href="{$currentIndex|escape:'html':'UTF-8'}&token={$token|escape:'html':'UTF-8'}&inspect_room=1&id_room={$room.id_room|intval}">
                                    <i class="icon-eye-open"></i> {l s='Inspect' mod='housekeepingmanagement'}
                                </a>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    {else}
        <div class="alert alert-info" role="status" aria-live="polite">
            {l s='No rooms are currently pending inspection. Once housekeeping marks rooms as cleaned, they will appear here for inspection.' mod='housekeepingmanagement'}
        </div>
    {/if}
</div>

>>>>>>> ef0e6f8df519dd8d25eb267d874b793c47bd87b1
