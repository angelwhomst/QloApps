{* Supervisor - Rooms To Be Inspected List *}
<div class="housekeeping-dashboard" style="padding: 20px; font-family: Arial, sans-serif; background: #f5f6f7;">

    <style>
        table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 8px; overflow: hidden; table-layout: fixed; }
        th, td { padding: 12px; border-bottom: 1px solid #eee; text-align: left; word-wrap: break-word; }
        thead { background: #f9f9f9; }
        th { font-weight: 600; color: #555; }
        tbody tr:hover { background: #f4f8ff; }
        .btn { background: #eee; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; }
        .btn.active { background: #007bff; color: white; }
        .action-buttons {
            display: flex;
            gap: 5px;
            justify-content: flex-start;
        }
        /* Inspect Room button style */
        .btn-inspect-room {
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
            color: white;
            border: none;
            padding: 6px 14px 6px 10px;
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            gap: 6px;
            font-weight: 500;
        }
        .btn-inspect-room i {
            flex: 0 0 auto;
            margin-right: 4px;
            margin-left: 0;
            min-width: 16px;
            text-align: center;
        }
        .btn-inspect-room,
        .btn-inspect-room:visited,
        .btn-inspect-room:active {
            color: #fff !important;
            text-decoration: none !important;
        }
        .btn-inspect-room i {
            color: #fff !important;
        }
        .btn-inspect-room:hover, .btn-inspect-room:focus {
            color: #fff !important;
        }
        /* Summary cards */
        .summary-cards {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        .summary-cards .card {
            flex: 1;
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        /* Fix Actions column width to be more balanced */
        th.actions-col, td.actions-col {
            width: 16%;
            text-align: left;
        }
    </style>

    <!-- Summary Cards -->
    <div class="summary-cards">
        <div class="card">
            <div>
                <div style="font-size: 14px; color: #666;">{l s='Cleaned Rooms' mod='housekeepingmanagement'}</div>
                <div style="font-size: 28px; font-weight: bold;">{$counts.Cleaned|intval}</div>
            </div>
            <i class="fas fa-check-circle" style="font-size: 32px; color: #41C588; margin-left: 15px;"></i>
        </div>
        <div class="card">
            <div>
                <div style="font-size: 14px; color: #666;">{l s='Not Cleaned' mod='housekeepingmanagement'}</div>
                <div style="font-size: 28px; font-weight: bold;">{$counts['Not Cleaned']|intval}</div>
            </div>
            <i class="fas fa-ban" style="font-size: 32px; color: #F5A623; margin-left: 15px;"></i>
        </div>
        <div class="card">
            <div>
                <div style="font-size: 14px; color: #666;">{l s='To Be Inspected' mod='housekeepingmanagement'}</div>
                <div style="font-size: 28px; font-weight: bold;">{$counts['To Be Inspected']|intval}</div>
            </div>
            <i class="fas fa-search" style="font-size: 32px; color: #007bff; margin-left: 15px;"></i>
        </div>
        <div class="card">
            <div>
                <div style="font-size: 14px; color: #666;">{l s='Failed Inspections' mod='housekeepingmanagement'}</div>
                <div style="font-size: 28px; font-weight: bold;">{$counts['Failed Inspection']|intval}</div>
            </div>
            <i class="fas fa-times-circle" style="font-size: 32px; color: #F36960; margin-left: 15px;"></i>
        </div>
    </div>

    {if isset($rooms) && $rooms|@count}
        <div class="table-responsive-row clearfix">
            <table>
                <thead>
                    <tr>
                        <th style="width: 12%;">{l s='Room#' mod='housekeepingmanagement'}</th>
                        <th style="width: 18%;">{l s='Assigned Staff' mod='housekeepingmanagement'}</th>
                        <th style="width: 18%;">{l s='Room Type' mod='housekeepingmanagement'}</th>
                        <th style="width: 18%;">{l s='Completed Time' mod='housekeepingmanagement'}</th>
                        <th style="width: 14%;">{l s='Status' mod='housekeepingmanagement'}</th>
                        <th class="actions-col">{l s='Actions' mod='housekeepingmanagement'}</th>
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
                                {assign var=statusColor value=""}
                                {assign var=statusBg value=""}
                                {if $room.status == "Failed Inspection"}
                                    {assign var=statusColor value="#F36960"}
                                    {assign var=statusBg value="#FEECEB"}
                                {elseif $room.status == "Cleaned"}
                                    {assign var=statusColor value="#41C588"}
                                    {assign var=statusBg value="#E7F8F0"}
                                {elseif $room.status == "Unassigned"}
                                    {assign var=statusColor value="#999"}
                                    {assign var=statusBg value="#F0F0F0"}
                                {elseif $room.status == "Not Cleaned"}
                                    {assign var=statusColor value="#F5A623"}
                                    {assign var=statusBg value="#FFF5E0"}
                                {elseif $room.status == "To Be Inspected"}
                                    {assign var=statusColor value="#007bff"}
                                    {assign var=statusBg value="#E0F0FF"}
                                {else}
                                    {assign var=statusColor value="#999"}
                                    {assign var=statusBg value="#F0F0F0"}
                                {/if}
                                <span style="color:{$statusColor}; background:{$statusBg}; font-weight:bold; border-radius:12px; padding:4px 8px; display:inline-block;">
                                    {if $room.status}{$room.status}{else}Unknown{/if}
                                </span>
                            </td>
                            <td class="actions-col">
                                <div class="action-buttons">
                                    <a class="btn-inspect-room" href="{$currentIndex|escape:'html':'UTF-8'}&token={$token|escape:'html':'UTF-8'}&inspect_task=1&id_task={$room.id_task|intval}" title="{l s='Inspect Room' mod='housekeepingmanagement'}">
                                        <i class="fas fa-search"></i>
                                        <span>{l s='Inspect Room' mod='housekeepingmanagement'}</span>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    {else}
        <div class="alert alert-info" role="status" aria-live="polite" style="margin-top:20px;">
            {l s='No rooms are currently pending inspection. Once housekeeping marks rooms as cleaned, they will appear here for inspection.' mod='housekeepingmanagement'}
        </div>
    {/if}

    <!-- External dependencies for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
</div>