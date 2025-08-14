<div class="task-assign-dashboard" style="padding: 20px; font-family: Arial, sans-serif; background: #f5f6f7; min-height: 100vh; display: flex; justify-content: center; align-items: center;">

    <style>
        .task-assign-card {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            max-width: 800px;
            width: 100%;
            box-sizing: border-box;
        }
        .task-assign-card h2 {
            font-size: 25px;
            margin-bottom: 20px;
            color: #333;
        }
        .task-assign-card label {
            display: block;
            margin-bottom: 6px;
            font-size: 13px;
            font-weight: bold;
            color: #555;
        }
        .task-assign-card input[type="text"],
        .task-assign-card select,
        .task-assign-card input[type="date"],
        .task-assign-card textarea {
            width: 100%;
            padding: 8px 10px;
            border-radius: 6px;
            border: 1px solid #ccc;
            margin-bottom: 15px;
            font-size: 14px;
            box-sizing: border-box;
        }
        .task-assign-card textarea {
            resize: vertical;
            min-height: 80px;
        }
        .task-assign-card select {
            height: 40px;      
            padding: 6px 10px; 
            font-size: 14px;    
        }
        .form-buttons {
            display: flex;
            justify-content: space-between;
            gap: 10px;
        }
        .form-buttons .btn {
            flex: 1;
            padding: 10px 0;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            color: #fff;
            border: none;
        }
        .form-buttons .btn-cancel {
            background: #6c757d;
        }
        .form-buttons .btn-cancel:hover {
            background: #5a6268;
        }
        .form-buttons .btn-submit {
            background: #007bff;
        }
        .form-buttons .btn-submit:hover {
            background: #0056b3;
        }
        .select2-container--default .select2-selection--multiple {
            min-height: 40px;       
            max-height: 60px;       
            overflow-y: hidden;      
            padding: 3px 5px;        
            box-sizing: border-box;
            margin-bottom: 15px;
        }
    </style>

    <div class="task-assign-card">
        <h2>Assign Staff to Room</h2>
        <form method="post" action="">

            <!-- Time Slot Dropdown -->
            <label for="time_slot">Time Slot</label>
            <select id="time_slot" name="time_slot">
                <option value="">-- Select Time Slot --</option>
                <option value="08:00-10:00">08:00 AM - 10:00 AM</option>
                <option value="10:00-12:00">10:00 AM - 12:00 PM</option>
                <option value="12:00-14:00">12:00 PM - 02:00 PM</option>
                <option value="14:00-16:00">02:00 PM - 04:00 PM</option>
                <option value="16:00-18:00">04:00 PM - 06:00 PM</option>
            </select>
            
            <!-- Deadline Date -->
            <label for="deadline">Deadline</label>
            <input type="date" id="deadline" name="deadline">
            
            <!-- Room Number Multi-Select -->
            <label for="room_number">Room Number</label>
            <select id="room_number" name="room_number[]" multiple="multiple" style="width: 100%;">
                <option value="101">101</option>
                <option value="102">102</option>
                <option value="103">103</option>
                <option value="104">104</option>
            </select>

            <!-- Assign Staff Dropdown -->
            <label for="assigned_staff">Assign Staff</label>
            <select id="assigned_staff" name="assigned_staff">
                <option value="">-- Select Staff --</option>
                <option value="John Doe">John Doe</option>
                <option value="Jane Smith">Jane Smith</option>
                <option value="Mark Lee">Mark Lee</option>
            </select>

            <!-- Priority Dropdown -->
            <label for="priority">Priority</label>
            <select id="priority" name="priority">
                <option value="High">High</option>
                <option value="Medium">Medium</option>
                <option value="Low">Low</option>
            </select>

            <!-- Special Notes -->
            <label for="special_notes">Special Notes</label>
            <textarea id="special_notes" name="special_notes" placeholder="Any special instructions..."></textarea>

            <!-- Buttons -->
            <div class="form-buttons">
                <a href="{$currentIndex}&token={$token}" class="btn btn-cancel">Cancel</a>
                <button type="submit" name="submit_task" class="btn btn-submit">Assign Task</button>
            </div>
        </form>
    </div>

</div>

<!-- Include jQuery and Select2 CSS/JS for Room Multi-Select -->
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
$(document).ready(function() {
    $('#room_number').select2({
        placeholder: "-- Select Room --",
        allowClear: true
    });
});
</script>
