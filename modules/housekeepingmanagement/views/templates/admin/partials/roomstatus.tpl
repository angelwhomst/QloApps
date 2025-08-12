<div class="room-status">
    <h3>Room Status</h3>
    <div>
        <label for="roomFilter">Filter Rooms:</label>
        <select id="roomFilter" class="form-control" onchange="fetchRooms()">
            <option value="all">All Rooms</option>
            <option value="cleaned">Cleaned</option>
            <option value="not_cleaned">Not Cleaned</option>
            <option value="failed_inspection">Failed Inspection</option>
        </select>
    </div>
    <table id="roomTable" class="table">
        <thead>
            <tr>
                <th>Room Number</th>
                <th>Room Type</th>
                <th>Current Status</th>
                <th>Assigned Staff</th>
                <th>Last Updated</th>
            </tr>
        </thead>
        <tbody>
            <!-- Populate with existing rooms via JavaScript -->
        </tbody>
    </table>
</div>