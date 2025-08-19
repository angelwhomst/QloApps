<!-- Housekeeping Management - Supervisor UI dashboard -->
<div class="housekeeping-dashboard" style="padding: 20px; font-family: Arial, sans-serif; background: #f5f6f7;">

    <!-- Summary Cards -->
    <div class="summary-cards" style="display: flex; gap: 20px; margin-bottom: 20px;">
        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">Cleaned Rooms</div>
                <div style="font-size: 28px; font-weight: bold;">{$summary.cleaned}</div>
            </div>
            <i class="fas fa-check-circle" style="font-size: 32px; color: green; margin-left: 15px;"></i>
        </div>

        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">Not Cleaned</div>
                <div style="font-size: 28px; font-weight: bold;">{$summary.not_cleaned}</div>
            </div>
            <i class="fas fa-ban" style="font-size: 32px; color: orange; margin-left: 15px;"></i>
        </div>

        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">To Be Inspected</div>
                <div style="font-size: 28px; font-weight: bold;">{$summary.to_be_inspected}</div>
            </div>
            <i class="fas fa-search" style="font-size: 32px; color: #007bff; margin-left: 15px;"></i>
        </div>

        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">Failed Inspections</div>
                <div style="font-size: 28px; font-weight: bold;">{$summary.failed_inspections}</div>
            </div>
            <i class="fas fa-times-circle" style="font-size: 32px; color: red; margin-left: 15px;"></i>
        </div>
    </div>


    <!-- Tabs and Filters -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <div class="tabs" style="display: flex; gap: 5px;">
            <button class="btn active" data-filter="all">All room</button>
            <button class="btn" data-filter="Unassigned">Unassigned</button>
            <button class="btn" data-filter="Cleaned">Cleaned</button>
            <button class="btn" data-filter="Not Cleaned">Not Cleaned</button>
            <button class="btn" data-filter="To Be Inspected">To Be Inspected</button>
            <button class="btn" data-filter="Failed Inspection">Failed Inspection</button>
        </div>
        <div class="filters" style="display: flex; gap: 10px; align-items: center;">
            <select>
                <option value="">Priority</option>
                <option value="High">High</option>
                <option value="Medium">Medium</option>
                <option value="Low">Low</option>
            </select>
            <div class="date-filter-wrapper">
                <button id="dateFilterBtn" class="btn">Filter by Date</button>
                <div class="date-filter-dropdown" id="dateFilterDropdown">
                    <div class="date-input-container">
                        <input type="text" class="from-date" placeholder="From">
                        <span class="icon">&#128197;</span>
                    </div>
                    <div class="date-input-container">
                        <input type="text" class="to-date" placeholder="To">
                        <span class="icon">&#128197;</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Table -->
    <table>
        <thead>
            <tr>
                <th style="width: 10%;">Room#</th>
                <th style="width: 20%;">Assigned Staff</th>
                <th style="width: 15%;">Room Floor</th>
                <th style="width: 15%;">Due Date</th>
                <th style="width: 15%;">Start Time</th>
                <th style="width: 10%;">Priority</th>
                <th style="width: 15%;">Task Status</th>
                <th style="width: 15%;">Actions</th>
            </tr>
        </thead>
        <tbody id="roomTableBody">
        {foreach from=$tasks item=task}
            <tr>
                <td>{$task.room_number}</td>
                <td>
                    {if $task.staff_firstname}
                        {$task.staff_firstname} {$task.staff_lastname}
                    {else}
                        No Assigned Staff
                    {/if}
                </td>
                <td>
                    {if isset($task.floor_number) && $task.floor_number != ""}
                        {$task.floor_number}
                    {else}
                        Not Set
                    {/if}
                </td>
                <td>{$task.deadline|date_format:"%m/%d/%Y"}</td>
                <td>Not Yet Started</td>
                <td>
                    {assign var=priorityColor value=""}
                    {assign var=priorityBg value=""}
                    {if $task.priority == "High"}
                        {assign var=priorityColor value="#F36960"}
                        {assign var=priorityBg value="#FEECEB"}
                    {elseif $task.priority == "Medium"}
                        {assign var=priorityColor value="orange"}
                        {assign var=priorityBg value="#FFF5E0"}
                    {elseif $task.priority == "Low"}
                        {assign var=priorityColor value="#41C588"}
                        {assign var=priorityBg value="#E7F8F0"}
                    {/if}

                    <span style="color:{$priorityColor}; background:{$priorityBg}; font-weight:bold; border-radius:12px; padding:4px 8px; display:inline-block;">
                        {$task.priority}
                    </span>
                </td>

                <td>
                    {assign var=statusColor value=""}
                    {assign var=statusBg value=""}
                    {if $task.room_status == "Failed Inspection"}
                        {assign var=statusColor value="#F36960"}
                        {assign var=statusBg value="#FEECEB"}
                    {elseif $task.room_status == "Cleaned"}
                        {assign var=statusColor value="#41C588"}
                        {assign var=statusBg value="#E7F8F0"}
                    {elseif $task.room_status == "Unassigned"}
                        {assign var=statusColor value="#999"}
                        {assign var=statusBg value="#F0F0F0"}
                    {elseif $task.room_status == "Not Cleaned"}
                        {assign var=statusColor value="#F5A623"}
                        {assign var=statusBg value="#FFF5E0"}
                    {elseif $task.room_status == "To Be Inspected"}
                        {assign var=statusColor value="#007bff"}
                        {assign var=statusBg value="#E0F0FF"}
                    {/if}

                    <span style="color:{$statusColor}; background:{$statusBg}; font-weight:bold; border-radius:12px; padding:4px 8px; display:inline-block;">
                        {$task.room_status}
                    </span>
                </td>
                <td>
                    <div class="action-buttons">
                        <button class="btn-action view-btn" title="View" data-task-id="{$task.id_task}"><i class="fas fa-eye"></i></button>
                        <button class="btn-action edit-btn" title="Edit" data-task-id="{$task.id_task}"><i class="fas fa-edit"></i></button>
                        <button class="btn-action delete-btn" title="Delete" data-task-id="{$task.id_task}"><i class="fas fa-trash"></i></button>
                    </div>
                </td>
            </tr>
        {/foreach}
        </tbody>
    </table>

    <!-- Pagination -->
    <div style="margin-top: 15px; text-align: right;">
        <button class="btn">Previous</button>
        <button class="btn active">1</button>
        <button class="btn">2</button>
        <button class="btn">Next</button>
    </div>

    <!-- Link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</div>
