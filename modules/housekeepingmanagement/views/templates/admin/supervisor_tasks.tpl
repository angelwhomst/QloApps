<!-- Housekeeping Management - Supervisor UI dashboard -->
<div class="housekeeping-dashboard" style="padding: 20px; font-family: Arial, sans-serif; background: #f5f6f7;">

    <style>
        .date-filter-wrapper { position: relative; display: inline-block; }
        .date-filter-dropdown { display: none; position: absolute; right: 0; margin-top: 5px; background: #fff; border: 1px solid #ccc; border-radius: 6px; padding: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.15); z-index: 10; width: 220px; }
        .date-filter-dropdown input { width: 100%; padding: 6px 30px 6px 10px; border: 1px solid #ccc; border-radius: 6px; margin-bottom: 8px; font-size: 14px; }
        .date-filter-dropdown .icon { position: absolute; right: 12px; top: 9px; pointer-events: none; color: #666; }
        .date-input-container { position: relative; background: #eee; }
        table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 8px; overflow: hidden; table-layout: fixed; }
        th, td { padding: 12px; border-bottom: 1px solid #eee; text-align: left; word-wrap: break-word; }
        thead { background: #f9f9f9; }
        th { font-weight: 600; color: #555; }
        tbody tr:hover { background: #f4f8ff; }
        .btn { background: #eee; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; }
        .btn.active { background: #007bff; color: white; }
        select { padding: 6px 10px; border-radius: 4px; border: 1px solid #ccc; }
        input[type="date"]::-webkit-calendar-picker-indicator { opacity: 0; cursor: pointer; }
        input[type="date"]::-webkit-inner-spin-button { display: none; }
        #dateFilterBtn {
            background: #fff;               
            border: 1px solid #ccc; 
            padding: 6px 10px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
        }
        #dateFilterBtn:hover {
            background: #f0f0f0;    
        }
        
        /* Action buttons styling */
        .action-buttons {
            display: flex;
            gap: 5px;
            justify-content: center;
        }
        .btn-action {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            padding: 6px 8px;
            cursor: pointer;
            font-size: 12px;
            color: #495057;
            transition: all 0.2s;
        }
        .btn-action:hover {
            background: #e9ecef;
            transform: translateY(-1px);
        }
        .view-btn:hover { color: #007bff; border-color: #007bff; }
        .edit-btn:hover { color: #28a745; border-color: #28a745; }
        .delete-btn:hover { color: #dc3545; border-color: #dc3545; }
        
        /* Enhanced SOP button styling */
        .btn-sop-details {
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            cursor: pointer;
            width: 18ch; 
            min-width: 10ch;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            gap: 4px;
        }
        .btn-sop-details i {
            flex: 0 0 auto;
            margin-left: 0;
            min-width: 16px;
            text-align: center;
        }
        .btn-sop-details span {
            flex: 1 1 auto;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .btn-sop-details:hover {
            background: linear-gradient(135deg, #138496 0%, #117a8b 100%);
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }

        /* Enhanced modal step styling */
        #modalSopSteps {
            margin: 0;
            padding-left: 0;
            list-style: none;
            counter-reset: step-counter;
        }
        #modalSopSteps li {
            counter-increment: step-counter;
            margin-bottom: 16px;
            padding: 16px;
            background: white;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            position: relative;
            padding-left: 60px;
            line-height: 1.5;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        #modalSopSteps li:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        #modalSopSteps li::before {
            content: counter(step-counter);
            position: absolute;
            left: 16px;
            top: 16px;
            background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
            color: white;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 12px;
        }
        #modalSopSteps li:nth-child(even) {
            background: #f8f9fa;
        }
    </style>

    <!-- Summary Cards -->
    <div class="summary-cards" style="display: flex; gap: 20px; margin-bottom: 20px;">
        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">Cleaned Rooms</div>
                <div style="font-size: 28px; font-weight: bold;">{if isset($summary.cleaned)}{$summary.cleaned}{else}0{/if}</div>
            </div>
            <i class="fas fa-check-circle" style="font-size: 32px; color: green; margin-left: 15px;"></i>
        </div>

        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">Not Cleaned</div>
                <div style="font-size: 28px; font-weight: bold;">{if isset($summary.not_cleaned)}{$summary.not_cleaned}{else}0{/if}</div>
            </div>
            <i class="fas fa-ban" style="font-size: 32px; color: orange; margin-left: 15px;"></i>
        </div>

        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">To Be Inspected</div>
                <div style="font-size: 28px; font-weight: bold;">{if isset($summary.to_be_inspected)}{$summary.to_be_inspected}{else}0{/if}</div>
            </div>
            <i class="fas fa-search" style="font-size: 32px; color: #007bff; margin-left: 15px;"></i>
        </div>

        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">Failed Inspections</div>
                <div style="font-size: 28px; font-weight: bold;">{if isset($summary.failed_inspections)}{$summary.failed_inspections}{else}0{/if}</div>
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
            {if !isset($is_housekeeper) || !$is_housekeeper}
            <a href="{$link->getAdminLink('SupervisorInspection')|escape:'html':'UTF-8'}" class="btn" style="background: #E0F0FF; color: #007bff; font-weight: 500; margin-left: 22rem;">
                <i class="fas fa-search"></i> Rooms to Inspect ({if isset($summary.to_be_inspected)}{$summary.to_be_inspected}{else}0{/if})
            </a>
            {/if}
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
                <th style="width: 8%;">Room#</th>
                <th style="width: 16%;">Assigned Staff</th>
                <th style="width: 8%;">Floor</th>
                <th style="width: 10%;">Due Date</th>
                <th style="width: 10%;">Start Time</th>
                <th style="width: 8%;">Priority</th>
                <th style="width: 10%;">Status</th>
                <th style="width: 12%;">SOP</th>
                {if !isset($is_housekeeper) || !$is_housekeeper}
                    <th style="width: 10%;">Actions</th>
                {/if}
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
                <td>
                    {if isset($task.time_slot) && $task.time_slot}
                        {$task.time_slot}
                    {else}
                        Not Set
                    {/if}
                </td>
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
                    {else}
                        {assign var=statusColor value="#999"}
                        {assign var=statusBg value="#F0F0F0"}
                    {/if}

                    <span style="color:{$statusColor}; background:{$statusBg}; font-weight:bold; border-radius:12px; padding:4px 8px; display:inline-block;">
                        {if $task.room_status}{$task.room_status}{else}Unknown{/if}
                    </span>
                </td>
                
                {* SOP Column - Always visible for all users *}
                <td>
                    {if isset($task.sop_title) && $task.sop_title}
                        <button class="btn-sop-details" 
                                data-sop-title="{if isset($task.sop_full_title)}{$task.sop_full_title|escape:'html':'UTF-8'}{else}{$task.sop_title|escape:'html':'UTF-8'}{/if}" 
                                data-sop-steps='{if isset($task.sop_steps)}{$task.sop_steps|json_encode}{else}[]{/if}' 
                                title="{if isset($task.sop_full_title)}{$task.sop_full_title|escape:'html':'UTF-8'}{else}{$task.sop_title|escape:'html':'UTF-8'}{/if}">
                            <i class="fas fa-clipboard-list"></i>
                            <span>{$task.sop_title|escape:'html':'UTF-8'}</span>
                        </button>
                    {else}
                        <span style="color: #999; font-style: italic;">No SOP</span>
                    {/if}
                </td>
                
                {* Actions Column - Only visible for supervisors *}
                {if !isset($is_housekeeper) || !$is_housekeeper}
                <td>
                    <div class="action-buttons">
                        <button class="btn-action view-btn" title="View" data-task-id="{$task.id_task}">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn-action edit-btn" title="Edit" data-task-id="{$task.id_task}">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn-action delete-btn" title="Delete" data-task-id="{$task.id_task}">
                            <i class="fas fa-trash"></i>
                        </button>
                        {if $task.room_status == "To Be Inspected"}
                        <a href="{$link->getAdminLink('SupervisorInspection')|escape:'html':'UTF-8'}&inspect_task=1&id_task={$task.id_task|intval}" 
                        class="btn-action" title="Inspect Room">
                            <i class="fas fa-search"></i>
                        </a>
                        {/if}
                    </div>
                </td>
                {/if}
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

    <!-- SOP Steps Modal - Always available -->
    <div id="sopStepsModal" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.4); align-items:center; justify-content:center; z-index:9999;">
        <div style="background:#fff; border-radius:8px; max-width:600px; width:90%; margin:auto; padding:0; position:relative; max-height:80vh; overflow:hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">
            {* Modal Header *}
            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px 24px; border-radius: 8px 8px 0 0; display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <h3 id="modalSopTitle" style="margin: 0; font-size: 18px; font-weight: 600;"></h3>
                    <p style="margin: 4px 0 0 0; opacity: 0.9; font-size: 14px;">Standard Operating Procedure</p>
                </div>
                <button id="closeSopModal" style="background: rgba(255,255,255,0.2); border: none; color: white; font-size: 24px; cursor: pointer; border-radius: 50%; width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; transition: background 0.2s;" onmouseover="this.style.background='rgba(255,255,255,0.3)'" onmouseout="this.style.background='rgba(255,255,255,0.2)'">
                    &times;
                </button>
            </div>
            
            {* Modal Body *}
            <div style="padding: 24px; max-height: 60vh; overflow-y: auto;">
                <div style="margin-bottom: 16px;">
                    <div style="display: flex; align-items: center; margin-bottom: 16px; padding: 12px; background: #f8f9fa; border-radius: 6px; border-left: 4px solid #007bff;">
                        <i class="fas fa-info-circle" style="color: #007bff; margin-right: 8px; font-size: 16px;"></i>
                        <span style="color: #495057; font-size: 14px; font-weight: 500;">Follow these steps in order to complete the task</span>
                    </div>
                    <ol id="modalSopSteps"></ol>
                </div>
            </div>
            
           
        </div>
    </div>

    <!-- External dependencies -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    {literal}
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        const from = document.querySelector('.from-date');
        const to = document.querySelector('.to-date');
        const btn = document.getElementById('dateFilterBtn');
        const dropdown = document.getElementById('dateFilterDropdown');
        const tabs = document.querySelectorAll('.tabs .btn');
        const prioritySelect = document.querySelector('.filters select');
        const tableBody = document.getElementById('roomTableBody');
        const paginationContainer = document.querySelector('div[style*="text-align: right"]');

        const rowsPerPage = 7;
        let currentPage = 1;
        let filteredRows = [];

        // Date input behavior
        function setDateBehavior(input) {
            if (input) {
                input.addEventListener('focus', () => input.type = 'date');
                input.addEventListener('blur', () => { if (!input.value) input.type = 'text'; });
            }
        }
        setDateBehavior(from);
        setDateBehavior(to);

        // Date filter dropdown
        if (btn && dropdown) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
            });
            document.addEventListener('click', () => dropdown.style.display = 'none');
        }

        // Get filtered rows
        function getFilteredRows() {
            const statusFilter = document.querySelector('.tabs .btn.active')?.getAttribute('data-filter') || 'all';
            const priorityFilter = prioritySelect ? prioritySelect.value : '';
            const fromDate = from && from.value ? new Date(from.value) : null;
            const toDate = to && to.value ? new Date(to.value) : null;

            return Array.from(tableBody.querySelectorAll('tr')).filter(row => {
                const statusCell = row.querySelector('td:nth-child(7)');
                const priorityCell = row.querySelector('td:nth-child(6)');
                const deadlineCell = row.querySelector('td:nth-child(4)');
                
                if (!statusCell || !priorityCell || !deadlineCell) return false;
                
                const status = statusCell.innerText.trim();
                const priority = priorityCell.innerText.trim();
                const deadlineText = deadlineCell.innerText.trim();
                const deadline = deadlineText ? new Date(deadlineText) : null;

                let show = true;
                if (statusFilter !== 'all' && status !== statusFilter) show = false;
                if (priorityFilter && priority !== priorityFilter) show = false;
                if (fromDate && deadline && deadline < fromDate) show = false;
                if (toDate && deadline && deadline > toDate) show = false;

                return show;
            });
        }

        // Render table with pagination
        function renderTable() {
            filteredRows = getFilteredRows();
            const totalPages = Math.ceil(filteredRows.length / rowsPerPage);
            if (currentPage > totalPages) currentPage = totalPages || 1;

            tableBody.querySelectorAll('tr').forEach(row => row.style.display = 'none');

            const start = (currentPage - 1) * rowsPerPage;
            const end = start + rowsPerPage;
            filteredRows.slice(start, end).forEach(row => row.style.display = '');

            renderPagination(totalPages);
        }

        // Render pagination buttons dynamically
        function renderPagination(totalPages) {
            if (!paginationContainer) return;
            
            paginationContainer.innerHTML = '';

            const prevBtn = document.createElement('button');
            prevBtn.className = 'btn';
            prevBtn.innerText = 'Previous';
            prevBtn.disabled = currentPage === 1;
            prevBtn.addEventListener('click', () => { currentPage--; renderTable(); });
            paginationContainer.appendChild(prevBtn);

            for (let i = 1; i <= totalPages; i++) {
                const pageBtn = document.createElement('button');
                pageBtn.className = 'btn';
                pageBtn.innerText = i;
                if (i === currentPage) pageBtn.classList.add('active');
                pageBtn.addEventListener('click', () => { currentPage = i; renderTable(); });
                paginationContainer.appendChild(pageBtn);
            }

            const nextBtn = document.createElement('button');
            nextBtn.className = 'btn';
            nextBtn.innerText = 'Next';
            nextBtn.disabled = currentPage === totalPages || totalPages === 0;
            nextBtn.addEventListener('click', () => { currentPage++; renderTable(); });
            paginationContainer.appendChild(nextBtn);
        }

        // Event listeners for filters
        tabs.forEach(tab => tab.addEventListener('click', () => { 
            tabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            currentPage = 1;
            renderTable();
        }));

        if (prioritySelect) {
            prioritySelect.addEventListener('change', () => { currentPage = 1; renderTable(); });
        }
        [from, to].forEach(el => {
            if (el) {
                el.addEventListener('change', () => { currentPage = 1; renderTable(); });
            }
        });

        // Enhanced SOP Modal functionality
        const sopModal = document.getElementById('sopStepsModal');
        if (sopModal) {
            document.querySelectorAll('.btn-sop-details').forEach(function(btn) {
                btn.addEventListener('click', function() {
                    var title = btn.getAttribute('data-sop-title');
                    var stepsJson = btn.getAttribute('data-sop-steps');
                    var steps = [];
                    
                    try {
                        steps = JSON.parse(stepsJson || '[]');
                    } catch(e) {
                        console.error('Error parsing SOP steps:', e);
                        steps = [];
                    }
                    
                    document.getElementById('modalSopTitle').innerText = title || 'SOP Details';
                    var ol = document.getElementById('modalSopSteps');
                    ol.innerHTML = '';
                    
                    if (steps.length > 0) {
                        steps.forEach(function(step, index) {
                            var li = document.createElement('li');
                            li.innerHTML = '<strong>Step ' + (index + 1) + ':</strong> ' + (step.step_description || step);
                            ol.appendChild(li);
                        });
                    } else {
                        ol.innerHTML = '<li style="text-align: center; color: #999; font-style: italic; border: 2px dashed #dee2e6;">No steps available for this SOP</li>';
                    }
                    
                    sopModal.style.display = 'flex';
                });
            });
            
            // Close modal events
            document.getElementById('closeSopModal').onclick = function() {
                sopModal.style.display = 'none';
            };
            
            sopModal.onclick = function(e) {
                if (e.target === this) {
                    this.style.display = 'none';
                }
            };
            
            // ESC key to close modal
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape' && sopModal.style.display === 'flex') {
                    sopModal.style.display = 'none';
                }
            });
        }

        // Action buttons functionality (for supervisors)
        document.querySelectorAll('.view-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const taskId = this.getAttribute('data-task-id');
                window.location.href = '{/literal}{$link->getAdminLink('SupervisorInspection')|escape:'javascript'}{literal}&viewtask=1&id_task=' + taskId;
            });
        });

        document.querySelectorAll('.edit-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const taskId = this.getAttribute('data-task-id');
                window.location.href = '{/literal}{$link->getAdminLink('SupervisorTasks')|escape:'javascript'}{literal}&edit_task=1&id_task=' + taskId;
            });
        });

        document.querySelectorAll('.delete-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const taskId = this.getAttribute('data-task-id');
                
                Swal.fire({
                    title: 'Are you sure?',
                    text: "You won't be able to revert this!",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33',
                    cancelButtonColor: '#3085d6',
                    confirmButtonText: 'Yes, delete it!'
                }).then((result) => {
                    if (result.isConfirmed) {
                        // Send AJAX request to delete
                        fetch('{/literal}{$link->getAdminLink('SupervisorTasks')|escape:'javascript'}{literal}', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                            },
                            body: 'ajax=1&action=deleteTask&id_task=' + taskId + '&token={/literal}{$token|escape:'javascript'}{literal}'
                        })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                Swal.fire('Deleted!', data.message, 'success').then(() => {
                                    location.reload();
                                });
                            } else {
                                Swal.fire('Error!', data.message, 'error');
                            }
                        })
                        .catch(error => {
                            Swal.fire('Error!', 'Failed to delete task', 'error');
                        });
                    }
                });
            });
        });

        // Initial render
        renderTable();
    });
    </script>
    {/literal}
</div>