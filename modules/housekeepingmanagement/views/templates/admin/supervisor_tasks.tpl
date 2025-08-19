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
    </style>

    <!-- Summary Cards -->
    <div class="summary-cards" style="display: flex; gap: 20px; margin-bottom: 20px;">
        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">Cleaned Rooms</div>
                <div style="font-size: 28px; font-weight: bold;">100</div>
            </div>
            <i class="fas fa-check-circle" style="font-size: 32px; color: green; margin-left: 15px;"></i>
        </div>

        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">Not Cleaned</div>
                <div style="font-size: 28px; font-weight: bold;">10</div>
            </div>
            <i class="fas fa-ban" style="font-size: 32px; color: orange; margin-left: 15px;"></i>
        </div>

        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">To Be Inspected</div>
                <div style="font-size: 28px; font-weight: bold;">100</div>
            </div>
            <i class="fas fa-search" style="font-size: 32px; color: #007bff; margin-left: 15px;"></i>
        </div>

        <div class="card" style="flex: 1; background: #fff; padding: 20px; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <div>
                <div style="font-size: 14px; color: #666;">Failed Inspections</div>
                <div style="font-size: 28px; font-weight: bold;">10</div>
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
                <th style="width: 15%;">SOP</th>
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
                    {if $task.sop_title}
                        <button class="btn btn-info btn-sop-details" data-sop-title="{$task.sop_title|escape:'html':'UTF-8'}" data-sop-steps='{json_encode($task.sop_steps)}'>
                            {$task.sop_title|escape:'html':'UTF-8'}
                        </button>
                    {else}
                        N/A
                    {/if}
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
    
    <!-- Script -->
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
            input.addEventListener('focus', () => input.type = 'date');
            input.addEventListener('blur', () => { if (!input.value) input.type = 'text'; });
        }
        setDateBehavior(from);
        setDateBehavior(to);

        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
        });
        document.addEventListener('click', () => dropdown.style.display = 'none');

        // Get filtered rows
        function getFilteredRows() {
            const statusFilter = document.querySelector('.tabs .btn.active')?.getAttribute('data-filter') || 'all';
            const priorityFilter = prioritySelect.value;
            const fromDate = from.value ? new Date(from.value) : null;
            const toDate = to.value ? new Date(to.value) : null;

            return Array.from(tableBody.querySelectorAll('tr')).filter(row => {
                const status = row.querySelector('td:nth-child(7)').innerText.trim();
                const priority = row.querySelector('td:nth-child(6)').innerText.trim();
                const deadlineText = row.querySelector('td:nth-child(4)').innerText.trim();
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
            paginationContainer.innerHTML = ''; // Clear old buttons

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

        [prioritySelect, from, to].forEach(el => el.addEventListener('change', () => { currentPage = 1; renderTable(); }));

        // Initial render
        renderTable();
    });
    </script>
    {/literal}

    <!-- SOP Steps Modal -->
    <div id="sopStepsModal" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.4); align-items:center; justify-content:center; z-index:9999;">
        <div style="background:#fff; border-radius:8px; max-width:400px; width:90%; margin:auto; padding:24px; position:relative;">
            <h3 id="modalSopTitle"></h3>
            <ol id="modalSopSteps"></ol>
            <button id="closeSopModal" class="btn" style="margin-top:16px;">Close</button>
        </div>
    </div>

    {literal}
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.btn-sop-details').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var title = btn.getAttribute('data-sop-title');
                var steps = JSON.parse(btn.getAttribute('data-sop-steps'));
                document.getElementById('modalSopTitle').innerText = title;
                var ol = document.getElementById('modalSopSteps');
                ol.innerHTML = '';
                steps.forEach(function(step) {
                    var li = document.createElement('li');
                    li.textContent = step.step_description;
                    ol.appendChild(li);
                });
                document.getElementById('sopStepsModal').style.display = 'flex';
            });
        });
        document.getElementById('closeSopModal').onclick = function() {
            document.getElementById('sopStepsModal').style.display = 'none';
        };
        document.getElementById('sopStepsModal').onclick = function(e) {
            if (e.target === this) this.style.display = 'none';
        };
    });
    </script>
    {/literal}
</div>
