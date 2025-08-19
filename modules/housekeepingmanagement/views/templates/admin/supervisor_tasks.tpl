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
        /* Inspection UI styles */
        .inspection-badge { background:#E0F0FF; color:#007bff; font-weight:bold; border-radius:12px; padding:4px 8px; display:inline-block; }
        .state-indicator { margin-left:8px; display:inline-block; padding:4px 8px; border-radius:12px; font-weight:bold; }
        .state-pass { background:#E7F8F0; color:#2e7d32; }
        .state-fail { background:#FFF5E0; color:#b26a00; }
        .toast-fixed { position:fixed; right:20px; bottom:20px; z-index:9999; min-width:260px; display:none; }
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

    <!-- Inspections (Frontend-only with mock data) -->
    <div class="panel" style="margin-top:10px; margin-bottom:20px;">
        <div class="panel-heading">
            <i class="icon-search"></i> Inspections
        </div>
        <div id="inspections-empty" class="alert alert-info" style="display:none;" role="status" aria-live="polite">
            No rooms are currently pending inspection. Once housekeeping marks rooms as cleaned, they will appear here for inspection.
        </div>
        <div class="table-responsive-row clearfix">
            <table class="table" id="inspections-table" aria-label="Rooms to be inspected">
                <thead>
                    <tr>
                        <th>Room#</th>
                        <th>Assigned Staff</th>
                        <th>Room Type</th>
                        <th>Completed Time</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody id="inspections-body"></tbody>
            </table>
        </div>
    </div>

    <!-- Toast -->
    <div id="inspection-toast" class="toast-fixed alert" role="status" aria-live="polite"></div>

    <!-- Inspection Detail Modal -->
    <div class="modal fade" id="inspectionDetailModal" tabindex="-1" role="dialog" aria-labelledby="inspectionDetailTitle" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="inspectionDetailTitle">Room Inspection</h4>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-lg-6">
                            <h3 style="margin-top:0;">
                                <span id="insp-room-number">Room —</span>
                                <small>— <span id="insp-room-type">Type</span></small>
                            </h3>
                        </div>
                        <div class="col-lg-6 text-right">
                            <span class="inspection-badge" id="insp-status-badge">To Be Inspected</span>
                        </div>
                    </div>
                    <div class="row" style="margin-top:10px;">
                        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
                            <div class="well" style="margin:0;">
                                <div style="color:#666;">Assigned Staff</div>
                                <div style="font-weight:700;" id="insp-staff">—</div>
                            </div>
                        </div>
                        <div class="col-lg-3 col-md-6" style="margin-bottom:10px;">
                            <div class="well" style="margin:0;">
                                <div style="color:#666;">Completed Cleaning</div>
                                <div style="font-weight:700;" id="insp-completed">—</div>
                            </div>
                        </div>
                        <div class="col-lg-6 col-md-12" style="margin-bottom:10px;">
                            <div class="well" id="insp-progress" aria-live="polite" style="margin:0;display:flex;justify-content:space-between;align-items:center;">
                                <strong>Checklist Progress</strong>
                                <span id="insp-progress-text">00/00 tasks done</span>
                            </div>
                        </div>
                    </div>

                    <div class="row" id="insp-checklist"></div>
                </div>
                <div class="modal-footer" style="display:flex; gap:10px; flex-wrap:wrap;">
                    <button type="button" class="btn btn-default" id="insp-add-remarks" aria-haspopup="dialog"><i class="icon-edit"></i> Add Remarks</button>
                    <button type="button" class="btn btn-danger" id="insp-reject"><i class="icon-remove"></i> Reject</button>
                    <button type="button" class="btn btn-success" id="insp-approve"><i class="icon-check"></i> Approve</button>
                    <span id="insp-loading" class="label label-info" style="display:none;">Submitting...</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Remarks Modal -->
    <div class="modal fade" id="remarksModal" tabindex="-1" role="dialog" aria-labelledby="remarksTitle" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="remarksTitle">Inspection Remarks</h4>
                </div>
                <div class="modal-body">
                    <textarea id="remarksText" class="form-control" rows="5" placeholder="Optional notes..."></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Save</button>
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
        // =====================
        // Inspection UI (mock)
        // =====================
        var inspectionRooms = [
            { id: 1, roomNumber: '101', staff: 'Jane Cooper', roomType: 'Deluxe', completedAt: '2025-08-19 15:22', checklist: [
                { id: 'beds', label: 'Bed linen fresh and tidy', passed: false },
                { id: 'bath', label: 'Bathroom sanitized', passed: false },
                { id: 'dust', label: 'No dust on surfaces', passed: false },
                { id: 'trash', label: 'Trash emptied', passed: false },
                { id: 'amen', label: 'Amenities replenished', passed: false },
                { id: 'vac', label: 'Floor vacuumed/mopped', passed: false },
                { id: 'mini', label: 'Minibar checked', passed: false },
                { id: 'tv', label: 'TV and remote working', passed: false },
                { id: 'ac', label: 'AC/heater functioning', passed: false },
                { id: 'win', label: 'Windows clean', passed: false }
            ]},
            { id: 2, roomNumber: '205', staff: 'Ralph Edwards', roomType: 'Suite', completedAt: '2025-08-19 14:05', checklist: [
                { id: 'beds', label: 'Bed linen fresh and tidy', passed: false },
                { id: 'bath', label: 'Bathroom sanitized', passed: true },
                { id: 'dust', label: 'No dust on surfaces', passed: true },
                { id: 'trash', label: 'Trash emptied', passed: false },
                { id: 'amen', label: 'Amenities replenished', passed: false },
                { id: 'vac', label: 'Floor vacuumed/mopped', passed: false },
                { id: 'mini', label: 'Minibar checked', passed: false },
                { id: 'tv', label: 'TV and remote working', passed: true },
                { id: 'ac', label: 'AC/heater functioning', passed: true },
                { id: 'win', label: 'Windows clean', passed: false }
            ]},
            { id: 3, roomNumber: '310', staff: 'Devon Lane', roomType: 'Standard', completedAt: '2025-08-19 16:10', checklist: [
                { id: 'beds', label: 'Bed linen fresh and tidy', passed: true },
                { id: 'bath', label: 'Bathroom sanitized', passed: true },
                { id: 'dust', label: 'No dust on surfaces', passed: true },
                { id: 'trash', label: 'Trash emptied', passed: true },
                { id: 'amen', label: 'Amenities replenished', passed: true },
                { id: 'vac', label: 'Floor vacuumed/mopped', passed: true },
                { id: 'mini', label: 'Minibar checked', passed: false },
                { id: 'tv', label: 'TV and remote working', passed: true },
                { id: 'ac', label: 'AC/heater functioning', passed: true },
                { id: 'win', label: 'Windows clean', passed: true }
            ]}
        ];

        var inspTableBody = document.getElementById('inspections-body');
        var inspTable = document.getElementById('inspections-table');
        var inspEmpty = document.getElementById('inspections-empty');
        var toast = document.getElementById('inspection-toast');

        var modal = document.getElementById('inspectionDetailModal');
        var inspRoomNumber = document.getElementById('insp-room-number');
        var inspRoomType = document.getElementById('insp-room-type');
        var inspStaff = document.getElementById('insp-staff');
        var inspCompleted = document.getElementById('insp-completed');
        var inspProgressText = document.getElementById('insp-progress-text');
        var inspChecklist = document.getElementById('insp-checklist');
        var inspApprove = document.getElementById('insp-approve');
        var inspReject = document.getElementById('insp-reject');
        var inspAddRemarks = document.getElementById('insp-add-remarks');
        var inspLoading = document.getElementById('insp-loading');
        var remarksText = document.getElementById('remarksText');

        var currentRoomId = null;

        function showToast(message, type) {
            toast.className = 'toast-fixed alert ' + (type === 'success' ? 'alert-success' : (type === 'error' ? 'alert-danger' : 'alert-info'));
            toast.textContent = message;
            toast.style.display = 'block';
            setTimeout(function(){ toast.style.display = 'none'; }, 2500);
        }

        function pad(num, size) {
            var s = String(num);
            while (s.length < size) s = '0' + s;
            return s;
        }

        function renderList() {
            inspTableBody.innerHTML = '';
            if (!inspectionRooms.length) {
                inspTable.style.display = 'none';
                inspEmpty.style.display = 'block';
                return;
            }
            inspTable.style.display = '';
            inspEmpty.style.display = 'none';
            inspectionRooms.forEach(function(r){
                var tr = document.createElement('tr');
                tr.innerHTML = '<td>'+r.roomNumber+'</td>'+
                    '<td>'+r.staff+'</td>'+
                    '<td>'+r.roomType+'</td>'+
                    '<td>'+r.completedAt+'</td>'+
                    '<td class="text-right">'+
                        '<button class="btn btn-default btn-sm inspect-btn" data-id="'+r.id+'" aria-label="Inspect room '+r.roomNumber+'">'+
                            '<i class="icon-eye-open"></i> Inspect'+
                        '</button>'+
                    '</td>';
                inspTableBody.appendChild(tr);
            });
        }

        function openDetail(roomId) {
            var r = inspectionRooms.find(function(x){ return x.id === roomId; });
            if (!r) return;
            currentRoomId = roomId;
            inspRoomNumber.textContent = 'Room '+r.roomNumber;
            inspRoomType.textContent = r.roomType;
            inspStaff.textContent = r.staff;
            inspCompleted.textContent = r.completedAt;

            inspChecklist.innerHTML = '';
            r.checklist.forEach(function(item){
                var col = document.createElement('div');
                col.className = 'col-lg-6 col-md-12';
                col.style.marginBottom = '10px';
                col.innerHTML =
                    '<div class="well" style="display:flex; align-items:center; justify-content:space-between;">'+
                        '<div><label class="control-label" style="margin:0;">'+item.label+'</label></div>'+
                        '<div>'+ 
                            '<input type="checkbox" '+(item.passed?'checked':'')+' class="insp-toggle" role="switch" aria-checked="'+(item.passed?'true':'false')+'" aria-label="'+item.label+'" data-id="'+item.id+'" />'+
                            '<span class="state-indicator '+(item.passed?'state-pass':'state-fail')+'">'+(item.passed?'Passed':'Failed')+'</span>'+
                        '</div>'+ 
                    '</div>';
                inspChecklist.appendChild(col);
            });

            updateProgress();

            if (window.jQuery && jQuery.fn.modal) {
                jQuery(modal).modal('show');
            }
        }

        function updateProgress() {
            var r = inspectionRooms.find(function(x){ return x.id === currentRoomId; });
            if (!r) return;
            var total = r.checklist.length;
            var digits = String(total).length;
            var passed = r.checklist.filter(function(i){ return !!i.passed; }).length;
            inspProgressText.textContent = pad(passed, digits) + '/' + pad(total, digits) + ' tasks done';
        }

        function attachRowHandlers() {
            inspTableBody.addEventListener('click', function(e){
                var btn = e.target.closest('.inspect-btn');
                if (!btn) return;
                openDetail(parseInt(btn.getAttribute('data-id')));
            });
        }

        function attachChecklistHandlers() {
            inspChecklist.addEventListener('change', function(e){
                if (!e.target.classList.contains('insp-toggle')) return;
                var id = e.target.getAttribute('data-id');
                var r = inspectionRooms.find(function(x){ return x.id === currentRoomId; });
                if (!r) return;
                var item = r.checklist.find(function(i){ return i.id === id; });
                if (!item) return;
                item.passed = e.target.checked;
                e.target.setAttribute('aria-checked', item.passed ? 'true' : 'false');
                var label = e.target.parentNode.querySelector('.state-indicator');
                label.textContent = item.passed ? 'Passed' : 'Failed';
                label.className = 'state-indicator ' + (item.passed ? 'state-pass' : 'state-fail');
                updateProgress();
            });
        }

        function simulateSubmit(decision) {
            inspLoading.style.display = 'inline-block';
            inspApprove.disabled = true;
            inspReject.disabled = true;
            var startTextA = inspApprove.innerHTML;
            var startTextR = inspReject.innerHTML;
            inspApprove.innerHTML = '<i class="icon-refresh icon-spin"></i> Approving...';
            inspReject.innerHTML = '<i class="icon-refresh icon-spin"></i> Rejecting...';
            setTimeout(function(){
                inspectionRooms = inspectionRooms.filter(function(x){ return x.id !== currentRoomId; });
                renderList();
                inspLoading.style.display = 'none';
                inspApprove.disabled = false;
                inspReject.disabled = false;
                inspApprove.innerHTML = startTextA;
                inspReject.innerHTML = startTextR;
                if (window.jQuery && jQuery.fn.modal) { jQuery(modal).modal('hide'); }
                showToast(decision === 'approve' ? 'Inspection approved' : 'Inspection rejected', 'success');
            }, 1200);
        }

        // Bind footer actions
        inspApprove.addEventListener('click', function(){ simulateSubmit('approve'); });
        inspReject.addEventListener('click', function(){ simulateSubmit('reject'); });
        inspAddRemarks.addEventListener('click', function(){ if (window.jQuery && jQuery.fn.modal) { jQuery('#remarksModal').modal('show'); } });

        // Initialize
        renderList();
        attachRowHandlers();
        attachChecklistHandlers();

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
</div>
