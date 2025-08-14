<!-- Housekeeping Management - Admin UI -->
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
            <button class="btn" data-filter="Unassigned Room">Unassigned Room</button>
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
            </tr>
        </thead>
        <tbody id="roomTableBody"></tbody>
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
        const mockRoomData = [
            { 
                roomNumber: "#001", 
                assignedStaff: "Deluxe Room", 
                floor: "Floor - 1", 
                dueDate: "01/01/25", 
                startTime: "8:00 AM", 
                priority: { label: "High", color: "#F36960", bg: "#FEECEB" }, 
                status: { label: "Failed Inspection", color: "#F36960", bg: "#FEECEB" } 
            },
            { 
                roomNumber: "#002", 
                assignedStaff: "Standard Room", 
                floor: "Floor - 2", 
                dueDate: "01/01/25", 
                startTime: "9:00 AM", 
                priority: { label: "Medium", color: "orange", bg: "#FFF5E0" }, 
                status: { label: "Cleaned", color: "#41C588", bg: "#E7F8F0"} 
            },
            { 
                roomNumber: "#003", 
                assignedStaff: "",  // no staff assigned
                floor: "Floor - 3", 
                dueDate: "01/02/25", 
                startTime: "10:00 AM", 
                priority: { label: "Low", color: "#41C588", bg: "#E7F8F0" }, 
                status: { label: "Unassigned", color: "#999", bg: "#F0F0F0" } 
            },
            { 
                roomNumber: "#004", 
                assignedStaff: "John Doe", 
                floor: "Floor - 1", 
                dueDate: "01/03/25", 
                startTime: "11:00 AM", 
                priority: { label: "High", color: "#F36960", bg: "#FEECEB" }, 
                status: { label: "Not Cleaned", color: "#F5A623", bg: "#FFF5E0" } 
            },
            { 
                roomNumber: "#005", 
                assignedStaff: "Jane Smith", 
                floor: "Floor - 2", 
                dueDate: "01/03/25", 
                startTime: "12:00 PM", 
                priority: { label: "Medium", color: "orange", bg: "#FFF5E0" }, 
                status: { label: "To Be Inspected", color: "#007bff", bg: "#E0F0FF" } 
            },
            { 
                roomNumber: "#006", 
                assignedStaff: "Michael Lee", 
                floor: "Floor - 3", 
                dueDate: "01/04/25", 
                startTime: "1:00 PM", 
                priority: { label: "Low", color: "#41C588", bg: "#E7F8F0" }, 
                status: { label: "Cleaned", color: "#41C588", bg: "#E7F8F0"} 
            },
            { 
                roomNumber: "#007", 
                assignedStaff: "",  // no staff assigned
                floor: "Floor - 1", 
                dueDate: "01/05/25", 
                startTime: "2:00 PM", 
                priority: { label: "High", color: "#F36960", bg: "#FEECEB" }, 
                status: { label: "Unassigned", color: "#999", bg: "#F0F0F0" } 
            },
            { 
                roomNumber: "#008", 
                assignedStaff: "Emma Watson", 
                floor: "Floor - 2", 
                dueDate: "01/05/25", 
                startTime: "3:00 PM", 
                priority: { label: "Medium", color: "orange", bg: "#FFF5E0" }, 
                status: { label: "Failed Inspection", color: "#F36960", bg: "#FEECEB" } 
            }
        ];

        document.addEventListener('DOMContentLoaded', function() {
            const tableBody = document.getElementById('roomTableBody');

            function renderTable(data) {
                tableBody.innerHTML = '';
                data.forEach(function(room) {
                    const assignedStaffDisplay = room.assignedStaff ? room.assignedStaff : "No Assigned Staff";

                    const tr = document.createElement('tr');
                    tr.innerHTML = 
                        '<td>' + room.roomNumber + '</td>' +
                        '<td>' + assignedStaffDisplay + '</td>' +
                        '<td>' + room.floor + '</td>' +
                        '<td>' + room.dueDate + '</td>' +
                        '<td>' + room.startTime + '</td>' +
                        '<td><span style="color:' + room.priority.color + '; background:' + room.priority.bg + '; font-weight:bold; border-radius:12px; padding:4px 8px; display:inline-block;">' + room.priority.label + '</span></td>' +
                        '<td><span style="color:' + room.status.color + '; background:' + room.status.bg + '; font-weight:bold; border-radius:12px; padding:4px 8px; display:inline-block;">' + room.status.label + '</span></td>';
                    tableBody.appendChild(tr);
                });
            }

            renderTable(mockRoomData);
        });


        document.addEventListener('DOMContentLoaded', function() {
            const from = document.querySelector('.from-date');
            const to = document.querySelector('.to-date');
            const btn = document.getElementById('dateFilterBtn');
            const dropdown = document.getElementById('dateFilterDropdown');

            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
            });

            document.addEventListener('click', function() {
                dropdown.style.display = 'none';
            });

            function setDateBehavior(input) {
                input.addEventListener('focus', () => input.type = 'date');
                input.addEventListener('blur', () => {
                    if (!input.value) {
                        input.type = 'text';
                    }
                });
            }
            setDateBehavior(from);
            setDateBehavior(to);
        });
    </script>
    {/literal}
</div>
